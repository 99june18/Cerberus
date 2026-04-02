#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <iostream>
#include <cstdlib>
#include <vector>
#include <set>
#include <algorithm>
#include <math.h>
#include <cstring>
#include <unordered_map>
#include <unordered_set>
#include <cstdint>

using namespace std;

#define SYMBOL_SIZE 16

// On-die ECC configuration //
#define OECC_CW_LEN   296     // on-die codeword length (bits)
#define OECC_DATA_LEN 280     // on-die data length (bits)
#define OECC_REDUN_LEN 16     // on-die redundancy (bits)

// System ECC configuration //
#define SECC_CW_LEN   296     // system codeword length (bits)
#define SECC_DATA_LEN 256     // system data length (bits)
#define SECC_REDUN_LEN 40     // system redundancy (bits)

#define SECC_REDUN_LEN_BASE 16

static const int M_BITS   = SYMBOL_SIZE;                         // 16
static const int TWO_M    = 40;                                  // Hsecc row count
static const int N_COLS   = SECC_CW_LEN;                         // 296
static const int N_BLOCKS = (SECC_CW_LEN + M_BITS - 1) / M_BITS; // 19
static const int LAST_BSZ = SECC_CW_LEN - (N_BLOCKS - 1)*M_BITS; // 8

#define RUN_NUM 10000000     // simulation runs

// ------------------------------------------------------------------------------------
// Error types
// ------------------------------------------------------------------------------------
enum STORAGE_FAULT_TYPE {NE_O = 0, SE   = 1, SE_SE = 2, SWL_16E = 3, SWD_32E = 4};
enum LINK_FAULT_TYPE    {NE_L = 0, SE_L = 1, DQS   = 2, DQ  = 3};
enum PERI_FAULT_TYPE    {NE_P = 0, SE_P = 1, DE_P  = 2};
enum RESULT_TYPE        {NE   = 0, CE   = 1, DUE   = 2, SDC = 3};

// ------------------------------------------------------------------------------------
// Matrices
// ------------------------------------------------------------------------------------
unsigned int H_Matrix_OECC_16bound[OECC_REDUN_LEN][OECC_CW_LEN]; // 16x296

// Hsecc for SECC SSC+DEC (binary 40x296)
static unsigned char Hsecc[TWO_M][N_COLS];         
static uint64_t      Hcol_mask[N_COLS];               

static std::vector<int> g_block_offsets; 
static std::vector<int> g_block_sizes;   

static std::vector<std::vector<uint64_t>> Hblock_col_mask;
static std::vector<std::vector<uint64_t>> Lmask;          

// DEC LUT
static std::unordered_map<uint64_t, uint32_t> DEC_LUT_UNIQUE;

// ------------------------------------------------------------------------------------
// Helpers
// ------------------------------------------------------------------------------------
static inline uint32_t pack_cols(uint16_t c1, uint16_t c2) {
    return ( (uint32_t)c1 << 16 ) | (uint32_t)c2;
}
static inline void unpack_cols(uint32_t p, uint16_t &c1, uint16_t &c2) {
    c1 = (uint16_t)(p >> 16);
    c2 = (uint16_t)(p & 0xFFFFu);
}
static inline unsigned int parity64(uint64_t x) {
    unsigned int p = 0;
    while (x) { p ^= (unsigned int)(x & 1ULL); x >>= 1; }
    return p;
}

static bool load_Hsecc_from_file(const char* path) {
    FILE* fp = fopen(path, "r");
    if (!fp) return false;
    for (int r=0; r<TWO_M; ++r) {
        for (int c=0; c<N_COLS; ++c) {
            unsigned int v=0;
            if (fscanf(fp, "%u", &v) != 1) { fclose(fp); return false; }
            Hsecc[r][c] = (unsigned char)(v & 1u);
        }
    }
    fclose(fp);
    return true;
}

static void compute_block_partition() {
    g_block_offsets.clear();
    g_block_sizes.clear();
    int off = 0;
    for (int b = 0; b < N_BLOCKS; ++b) {
        int remain = N_COLS - off;
        int bsz = std::min(M_BITS, remain);
        g_block_offsets.push_back(off);
        g_block_sizes.push_back(bsz);
        off += bsz;
    }
}

static void precompute_packed_columns() {
    for (int c=0; c<N_COLS; ++c) {
        uint64_t m = 0ULL;
        for (int r=0; r<TWO_M; ++r) if (Hsecc[r][c]) m |= (1ULL<<r);
        Hcol_mask[c] = m;
    }
}

static void build_block_col_masks() {
    Hblock_col_mask.assign(N_BLOCKS, std::vector<uint64_t>(M_BITS, 0ULL));
    for (int b=0; b<N_BLOCKS; ++b) {
        int off = g_block_offsets[b];
        int bsz = g_block_sizes[b];
        for (int t=0; t<bsz; ++t) {
            Hblock_col_mask[b][t] = Hcol_mask[off + t];
        }
        for (int t=bsz; t<M_BITS; ++t) {
            Hblock_col_mask[b][t] = 0ULL;
        }
    }
}

static uint64_t gf2_solve_mxN(const std::vector<uint64_t>& A_rows, const std::vector<unsigned char>& b) {
    const int rows = (int)A_rows.size(); 
    const int cols = TWO_M;               
    std::vector<uint64_t> A(rows);
    std::vector<unsigned char> rhs(rows);
    for (int r=0; r<rows; ++r) { A[r] = A_rows[r]; rhs[r] = (unsigned char)(b[r]&1u); }

    int r = 0;
    int pivot_col_of_row[64]; for (int i=0;i<64;++i) pivot_col_of_row[i] = -1;

    for (int c=0; c<cols && r<rows; ++c) {
        int pivot = -1;
        for (int rr=r; rr<rows; ++rr) if ((A[rr]>>c)&1ULL) { pivot = rr; break; }
        if (pivot < 0) continue;
        if (pivot != r) { std::swap(A[pivot], A[r]); std::swap(rhs[pivot], rhs[r]); }
        for (int rr=0; rr<rows; ++rr) if (rr!=r && ((A[rr]>>c)&1ULL)) {
            A[rr] ^= A[r];
            rhs[rr] ^= rhs[r];
        }
        pivot_col_of_row[r] = c; ++r;
    }

    uint64_t y = 0ULL;
    for (int rr=0; rr<r; ++rr) {
        int pc = pivot_col_of_row[rr];
        if (pc>=0 && rhs[rr]) y |= (1ULL<<pc);
    }
    return y;
}

static bool build_left_inverses() {
    Lmask.clear();
    Lmask.resize(N_BLOCKS);
    for (int b=0; b<N_BLOCKS; ++b) {
        int off = g_block_offsets[b];
        int bsz = g_block_sizes[b];

        std::vector<uint64_t> At_rows(bsz, 0ULL);
        for (int i=0; i<bsz; ++i) {
            uint64_t mask = 0ULL;
            for (int c=0; c<TWO_M; ++c) if (Hsecc[c][off + i]) mask |= (1ULL<<c);
            At_rows[i] = mask;
        }

        Lmask[b].assign(M_BITS, 0ULL);
        for (int i=0; i<bsz; ++i) {
            std::vector<unsigned char> rhs(bsz, 0);
            rhs[i] = 1;
            uint64_t ymask = gf2_solve_mxN(At_rows, rhs);
            Lmask[b][i] = ymask;
        }

        for (int i=0; i<bsz; ++i) {
            for (int j=0; j<bsz; ++j) {
                unsigned int dot = parity64(Lmask[b][i] & Hblock_col_mask[b][j]);
                if (dot != (unsigned int)(i==j)) return false;
            }
        }
    }
    return true;
}

static void build_DEC_LUT_unique() {
    DEC_LUT_UNIQUE.clear();
    std::unordered_set<uint64_t> ambiguous;

    for (int bi=0; bi<N_BLOCKS; ++bi) {
        int s1 = g_block_offsets[bi], e1 = s1 + g_block_sizes[bi];
        for (int bj=bi+1; bj<N_BLOCKS; ++bj) {
            int s2 = g_block_offsets[bj], e2 = s2 + g_block_sizes[bj];
            for (int c1=s1; c1<e1; ++c1) {
                uint64_t m1 = Hcol_mask[c1];
                for (int c2=s2; c2<e2; ++c2) {
                    uint64_t key = m1 ^ Hcol_mask[c2];
                    if (ambiguous.find(key) != ambiguous.end()) continue;
                    auto it = DEC_LUT_UNIQUE.find(key);
                    if (it == DEC_LUT_UNIQUE.end()) {
                        DEC_LUT_UNIQUE.emplace(key, pack_cols((uint16_t)c1,(uint16_t)c2));
                    } else {
                        DEC_LUT_UNIQUE.erase(key);
                        ambiguous.insert(key);
                    }
                }
            }
        }
    }
}

static inline uint64_t compute_syndrome_packed(const unsigned int receive_codeword[SECC_CW_LEN]) {
    uint64_t synd = 0ULL;
    for (int c=0; c<N_COLS; ++c) if (receive_codeword[c] & 1u) synd ^= Hcol_mask[c];
    return synd;
}

static bool init_ssc_dec_from_Hsecc(const char* hsecc_path) {
    if (!load_Hsecc_from_file(hsecc_path)) {
        fprintf(stderr, "[ERR] Failed to load H' from %s\n", hsecc_path);
        return false;
    }
    compute_block_partition();
    precompute_packed_columns();
    build_block_col_masks();
    if (!build_left_inverses()) {
        fprintf(stderr, "[ERR] Left-inverse verification failed. Check H' block ranks.\n");
        return false;
    }
    build_DEC_LUT_unique();
    return true;
}

// ------------------------------------------------------------------------------------
// Error injection
// ------------------------------------------------------------------------------------
// Storage
void error_injection_SE(unsigned int codeword[OECC_CW_LEN]) {
    int Fault_pos = rand() % OECC_CW_LEN;
    codeword[Fault_pos] ^= 1u;
}

void error_injection_SE_SE(unsigned int codeword[OECC_CW_LEN]) {
    int Fault_pos1 = rand()%OECC_CW_LEN;
    int Fault_pos2; do{ Fault_pos2 = rand() % OECC_CW_LEN; } while(Fault_pos2==Fault_pos1);
    codeword[Fault_pos1] ^= 1u; codeword[Fault_pos2] ^= 1u;
}

// Subwordline 16b burst
void error_injection_SWL_16E(unsigned int codeword[OECC_CW_LEN]) {
    int sym_idx = rand() % 18; 
    while (1) {
        int cnt = 0;
        int base = sym_idx * 16;
        uint32_t mask = 0;
        for (int i = 0; i < 16; ++i) {
            unsigned int flip = rand() & 1u;
            mask |= (flip << (15 - i));
            cnt += flip;
        }
        if (cnt >= 1) {
            for (int i = 0; i < 16; ++i) {
                if ( (mask >> (15 - i)) & 1u ) {
                    codeword[base + i] ^= 1u;
                }
            }
            break;
        }
    }
}

// Subwordline driver 32b burst
void error_injection_SWD_32E(unsigned int codeword[OECC_CW_LEN]) {
    int sym_idx = rand() % 9; 
    while (1) {
        int cnt = 0;
        int base = sym_idx * 32;
        uint32_t mask = 0;
        for (int i = 0; i < 32; ++i) {
            unsigned int flip = rand() & 1u;
            mask |= (flip << (31 - i));
            cnt += flip;
        }
        if (cnt >= 1) {
            for (int i = 0; i < 32; ++i) {
                if ( (mask >> (31 - i)) & 1u ) {
                    codeword[base + i] ^= 1u;
                }
            }
            break;
        }
    }
}

// ------------------------------------------------------------------------------------
// Peri error injection
// ------------------------------------------------------------------------------------
void error_injection_Link_SE(unsigned int codeword[OECC_CW_LEN]) {
    int Fault_pos = rand() % SECC_CW_LEN;
    codeword[Fault_pos] ^= 1u;
}

void error_injection_Link_DE(unsigned int codeword[OECC_CW_LEN]) {
    int Fault_pos1 = rand()%SECC_CW_LEN;
    int Fault_pos2; do{ Fault_pos2 = rand() % SECC_CW_LEN; } while(Fault_pos2==Fault_pos1);
    codeword[Fault_pos1] ^= 1u; codeword[Fault_pos2] ^= 1u;
}

void error_injection_Link_DQ(unsigned int codeword[SECC_CW_LEN]) {
    int lanes = SECC_CW_LEN / 8;
    int dq = rand() % lanes;
    while (1) {
        int cnt = 0;
        unsigned char mask = 0;
        for (int i = 0; i < 8; ++i) {
            unsigned int flip = rand() & 1u;
            mask |= (flip << i);
            cnt += flip;
        }
        if (cnt >= 1) {
            for (int i = 0; i < 8; ++i) {
                if ((mask >> i) & 1u) {
                    int idx = dq*8 + i;
                    codeword[idx] ^= 1u;
                }
            }
            break;
        }
    }
}
void error_injection_Link_DQS(unsigned int codeword[SECC_CW_LEN]) {
    int lane = rand() % 8;   
    while (1) {
        int cnt = 0;
        uint64_t mask = 0;   

        for (int s = 0; s < 37; ++s) {
            unsigned int flip = rand() & 1u;
            mask |= (uint64_t)flip << s;  
            cnt += flip;
        }

        if (cnt >= 1) {  
            for (int s = 0; s < 37; ++s) {
                if ((mask >> s) & 1u) {
                    int idx = lane + s*8;  
                    codeword[idx] ^= 1u;
                }
            }
            break;
        }
    }
}

// ------------------------------------------------------------------------------------
// OECC (SECDED_16bound)
// ------------------------------------------------------------------------------------
void error_correction_oecc (int *result_type_oecc, unsigned int codeword[OECC_CW_LEN]) {
    unsigned int Syndromes[OECC_REDUN_LEN] = {0};
    for(int row=0; row<OECC_REDUN_LEN; row++){
        unsigned int row_value=0;
        for(int column=0; column<OECC_CW_LEN; column++)
            row_value ^= (H_Matrix_OECC_16bound[row][column] * codeword[column]);
        Syndromes[row]=row_value;
    }
    bool all_zero = true;
    for (int i = 0; i < OECC_REDUN_LEN; i++) if (Syndromes[i] != 0) { all_zero = false; break; }
    if (all_zero) { *result_type_oecc = NE; return; }

    for(int error_pos=0; error_pos<OECC_CW_LEN; error_pos++){
        int cnt=0;
        for(int row=0; row<OECC_REDUN_LEN; row++){
            if(Syndromes[row]==H_Matrix_OECC_16bound[row][error_pos]) cnt++;
            else break;
        }
        if(cnt == OECC_REDUN_LEN) {
            codeword[error_pos]^=1u;
            *result_type_oecc = CE;
            return;
        }
    }
    *result_type_oecc = DUE;
}

// Detect-only
void detection_only_oecc (int *result_type_detect, const unsigned int codeword[OECC_CW_LEN]) {
    unsigned int Syndromes[OECC_REDUN_LEN] = {0};
    for(int row=0; row<OECC_REDUN_LEN; row++){
        unsigned int row_value=0;
        for(int column=0; column<OECC_CW_LEN; column++)
            row_value ^= (H_Matrix_OECC_16bound[row][column] * codeword[column]);
        Syndromes[row]=row_value;
    }
    bool all_zero = true;
    for (int i = 0; i < OECC_REDUN_LEN; i++) if (Syndromes[i] != 0) { all_zero = false; break; }
    *result_type_detect = all_zero ? NE : DUE;
}

// ------------------------------------------------------------------------------------
// SDC check
// ------------------------------------------------------------------------------------
int SDC_check(unsigned int codeword[SECC_CW_LEN], unsigned int codeword1[SECC_CW_LEN]) {
    for(int pos=0; pos<SECC_CW_LEN; pos++) if(codeword[pos] != codeword1[pos]) return 1;
    return 0;
}

// ------------------------------------------------------------------------------------
// SECC: SSC + DEC
// ------------------------------------------------------------------------------------
void error_correction_secc_SSC_DEC(int *result_type_secc, unsigned int receive_codeword[SECC_CW_LEN]) {
    uint64_t synd = compute_syndrome_packed(receive_codeword);
    if (synd == 0ULL) { *result_type_secc = NE; return; }

    for (int b=0; b<N_BLOCKS; ++b) {
        int off = g_block_offsets[b];
        int bsz = g_block_sizes[b];

        std::vector<unsigned char> E(bsz, 0);
        for (int i=0; i<bsz; ++i) E[i] = (unsigned char)parity64(Lmask[b][i] & synd);

        uint64_t s_hat = 0ULL;
        for (int i=0; i<bsz; ++i) if (E[i]) s_hat ^= Hblock_col_mask[b][i];

        if (s_hat == synd) {
            for (int i=0; i<bsz; ++i) if (E[i]) receive_codeword[off + i] ^= 1u;
            uint64_t synd_after = compute_syndrome_packed(receive_codeword);
            *result_type_secc = (synd_after==0ULL) ? CE : DUE;
            return;
        }
    }

    auto it = DEC_LUT_UNIQUE.find(synd);
    if (it != DEC_LUT_UNIQUE.end()) {
        uint16_t c1, c2; unpack_cols(it->second, c1, c2);
        receive_codeword[c1] ^= 1u;
        receive_codeword[c2] ^= 1u;
        uint64_t synd_after = compute_syndrome_packed(receive_codeword);
        *result_type_secc = (synd_after==0ULL) ? CE : DUE;
        return;
    }

    *result_type_secc = DUE;
}

// ------------------------------------------------------------------------------------
// Main
// ------------------------------------------------------------------------------------
int main(int argc, char* argv[]) {
    if (argc < 5) {
        fprintf(stderr, "Usage: %s <LINK1_FAULT> <STOR_FAULT> <PERI_FAULT> <LINK2_FAULT> [Hsecc_path]\n", argv[0]);
        fprintf(stderr, "       LINK*_FAULT: 0=NE_L, 1=SE_L, 2=DQS,   3=DQ\n");
        fprintf(stderr, "       PERI*_FAULT: 0=NE_P, 1=SE_P, 2=DE_P\n");
        fprintf(stderr, "       STOR_FAULT : 0=NE_O, 1=SE,   2=SE_SE, 3=SWL_16E,  4=SWD_32E\n");
        return 1;
    }

    // --- Load matrices ---
    {
        FILE *fp4=fopen("H2_matrix.txt","r");
        if(!fp4){ fprintf(stderr,"[ERR] Cannot open H2_matrix.txt\n"); return 1; }
        for(int row=0; row<OECC_REDUN_LEN; row++){
            for(int column=0; column<OECC_CW_LEN; column++){
                unsigned int value=0;
                if (fscanf(fp4,"%u",&value)!=1){ fclose(fp4); fprintf(stderr,"[ERR] Bad H2_matrix.txt format (expected 16 x 296)\n"); return 1; }
                H_Matrix_OECC_16bound[row][column]=value;
            }
        }
        fclose(fp4);
    }

    const char* hsecc_path = (argc >= 6) ? argv[5] : "Hsecc.txt";
    if (!init_ssc_dec_from_Hsecc(hsecc_path)) return 1;

    // --- Parse fault types with separated switches (Link vs Peri) ---
    int link1_arg = atoi(argv[1]);
    int stor_arg  = atoi(argv[2]);
    int peri_arg  = atoi(argv[3]);
    int link2_arg = atoi(argv[4]);

    string L1_STR, ST_STR, P_STR, L2_STR;
    int link1_type, storage_fault_type, peri_type, link2_type;

    // LINK1
    switch (link1_arg) {
        case NE_L: L1_STR="NE_L"; link1_type=NE_L; break;
        case SE_L: L1_STR="SE_L"; link1_type=SE_L; break;
        case DQS : L1_STR="DQS";  link1_type=DQS;  break;
        case DQ:   L1_STR="DQ";   link1_type=DQ;   break;
        default:   L1_STR="NE_L"; link1_type=NE_L; break;
    }
    // STORAGE
    switch (stor_arg) {
        case NE_O:      ST_STR="NE_O";      storage_fault_type=NE_O;    break;
        case SE:        ST_STR="SE";        storage_fault_type=SE;      break;
        case SE_SE:     ST_STR="SE_SE";     storage_fault_type=SE_SE;   break;
        case SWL_16E:   ST_STR="SWL_16E";   storage_fault_type=SWL_16E; break;
        case SWD_32E:   ST_STR="SWD_32E";   storage_fault_type=SWD_32E; break;
        default:        ST_STR="NE_O";      storage_fault_type=NE_O;    break;
    }
    // PERI
    switch (peri_arg) {
        case NE_P: P_STR="NE_P"; peri_type=NE_P; break;
        case SE_P: P_STR="SE_P"; peri_type=SE_P; break;
        case DE_P: P_STR="DE_P"; peri_type=DE_P; break;
        default:   P_STR="NE_P"; peri_type=NE_P; break;
    }
    // LINK2
    switch (link2_arg) {
        case NE_L: L2_STR="NE_L"; link2_type=NE_L; break;
        case SE_L: L2_STR="SE_L"; link2_type=SE_L; break;
        case DQS : L2_STR="DQS";  link2_type=DQS;  break;
        case DQ:   L2_STR="DQ";   link2_type=DQ;   break;
        default:   L2_STR="NE_L"; link2_type=NE_L; break;
    }

    // --- Output file ---
    string Result_file_name = "Result/Cerberus_" + L1_STR + "_" + ST_STR + "_" + P_STR + "_" + L2_STR + ".S";
    FILE *fp3=fopen(Result_file_name.c_str(),"w");
    if (!fp3) { fprintf(stderr,"[ERR] Cannot open result file\n"); return 1; }

    // --- Simulation loop ---
    unsigned int codeword[OECC_CW_LEN];
    unsigned int codeword1[OECC_CW_LEN];

    int WRDET_NE=0, WRDET_DUE=0;                       // write-link detect-only
    int NE_cnt=0,  CE_cnt=0,  DUE_cnt=0,  SDC_cnt=0;   // OECC
    int NE_cnt1=0, CE_cnt1=0, DUE_cnt1=0, SDC_cnt1=0;  // SECC
    int NE_cnt2=0, CE_cnt2=0, DUE_cnt2=0, SDC_cnt2=0;  // Total

    int RUN_WRDET = RUN_NUM;
    int RUN_OECC  = 0;
    int RUN_SECC  = 0;

    srand((unsigned int)time(NULL));

    for(int runtime=0; runtime<RUN_NUM; runtime++){
        if(runtime%1000000==0){
            fprintf(fp3,"\n===============\n");
            fprintf(fp3,"Runtime : %d/%d\n",runtime,RUN_NUM);
            fprintf(fp3,"[WR-DET] NE:%d DUE:%d\n", WRDET_NE, WRDET_DUE);
            fprintf(fp3,"[OECC]   CE:%d DUE:%d SDC:%d\n", CE_cnt, DUE_cnt, SDC_cnt);
            fprintf(fp3,"[SECC]   CE:%d DUE:%d SDC:%d\n", CE_cnt1, DUE_cnt1, SDC_cnt1);
            fprintf(fp3,"[TOTAL]  NE:%d CE:%d DUE:%d SDC:%d\n", NE_cnt2, CE_cnt2, DUE_cnt2, SDC_cnt2);
            fprintf(fp3,"===============\n");
            fflush(fp3);
        }

        unsigned int data_bits[SECC_DATA_LEN];
        for (int i = 0; i < SECC_CW_LEN; i++) codeword[i] = 0;
        for (int i = 0; i < SECC_CW_LEN; i++) codeword1[i] = codeword[i];

        unsigned int codeword_L1_clean[OECC_CW_LEN];
        for (int i = 0; i < SECC_CW_LEN; ++i) codeword_L1_clean[i] = codeword[i];
        int wr_link1_detected = 0;

        // 2) WRITE LINK (Link1)
        switch (link1_type){
            case NE_L: break;
            case SE_L: error_injection_Link_SE(codeword);  break;
            case DQS : error_injection_Link_DQS(codeword); break;
            case DQ  : error_injection_Link_DQ(codeword);  break;
            default:  break;
        }

        // 3) Detect-only with H2
        int result_type_wrdet;
        detection_only_oecc(&result_type_wrdet, codeword);
        if (result_type_wrdet == DUE) {
            WRDET_DUE++;
            wr_link1_detected = 1;
            for (int i = 0; i < SECC_CW_LEN; ++i) codeword[i] = codeword_L1_clean[i];
        } else {
            WRDET_NE++;
        }

        // 4) STORAGE
        switch (storage_fault_type){
            case NE_O:                                        break;
            case SE:       error_injection_SE(codeword);      break;
            case SE_SE:    error_injection_SE_SE(codeword);   break;
            case SWL_16E:  error_injection_SWL_16E(codeword); break;
            case SWD_32E:  error_injection_SWD_32E(codeword); break;
        }

        // 5) O-ECC decode (correction)
        RUN_OECC++;
        int result_type_oecc;
        error_correction_oecc(&result_type_oecc, codeword);

        for (int i = 0; i < SECC_CW_LEN; i++) {
            if(codeword[i] == 1 && (result_type_oecc == CE || result_type_oecc == NE)) {
                result_type_oecc = SDC;
                break;
            }
        }
        
        NE_cnt   += (result_type_oecc==NE)  ? 1 : 0;
        CE_cnt   += (result_type_oecc==CE)  ? 1 : 0;
        DUE_cnt  += (result_type_oecc==DUE) ? 1 : 0;
        SDC_cnt  += (result_type_oecc==SDC) ? 1 : 0;

        unsigned int cw_base[SECC_CW_LEN];
        for (int i = 0; i < SECC_CW_LEN; ++i) cw_base[i] = codeword[i];

        for (int i = 0; i < SECC_CW_LEN; ++i) codeword[i] = cw_base[i];

        // 6) PERI
        switch (peri_type){
            case NE_P: break;
            case SE_P: error_injection_Link_SE(codeword);  break;
            case DE_P: error_injection_Link_DE(codeword);  break;
            default:  break;
        }

        // 7) READ LINK
        switch (link2_type){
            case NE_L: break;
            case SE_L: error_injection_Link_SE(codeword);  break;
            case DQS : error_injection_Link_DQS(codeword); break;
            case DQ  : error_injection_Link_DQ(codeword);  break;
            default:  break;
        }

        // 8) S-ECC decode (SSC+DEC)
        RUN_SECC++;
        int result_type_secc;
        error_correction_secc_SSC_DEC(&result_type_secc, codeword);
        if(result_type_secc==CE || result_type_secc==NE){
            if(SDC_check(codeword, codeword1)) result_type_secc=SDC;
        }

        // retry policy
        if (result_type_secc == DUE) {
            unsigned int retry_cw[SECC_CW_LEN];
            for (int i = 0; i < SECC_CW_LEN; ++i) retry_cw[i] = cw_base[i];

            int retry_result_secc;
            error_correction_secc_SSC_DEC(&retry_result_secc, retry_cw);

            if (retry_result_secc == CE || retry_result_secc == NE) {
                if (SDC_check(retry_cw, codeword1)) retry_result_secc = SDC;
            }

            if (retry_result_secc == NE || retry_result_secc == CE) {
                for (int i = 0; i < SECC_CW_LEN; ++i) codeword[i] = retry_cw[i];
                result_type_secc = CE;
            } else if (retry_result_secc == SDC) {
                for (int i = 0; i < SECC_CW_LEN; ++i) codeword[i] = retry_cw[i];
                result_type_secc = SDC;
            } else {
                result_type_secc = DUE;
            }
        }

        NE_cnt1   += (result_type_secc==NE)  ? 1 : 0;
        CE_cnt1   += (result_type_secc==CE)  ? 1 : 0;
        DUE_cnt1  += (result_type_secc==DUE) ? 1 : 0;
        SDC_cnt1  += (result_type_secc==SDC) ? 1 : 0;

        // 9) Final
        int total_result;
        if (result_type_secc == SDC) {
            total_result = SDC;
        } else if (result_type_secc == DUE) {
            total_result = DUE;
        } else if (result_type_secc == CE) {
            total_result = CE;
        } else {
            if      (result_type_oecc == SDC) total_result = SDC;
            else if (result_type_oecc == DUE) total_result = DUE;
            else if (result_type_oecc == CE ) total_result = CE;
            else {
                total_result = wr_link1_detected ? CE : NE;
            }
        }
        
        NE_cnt2   += (total_result==NE)  ? 1 : 0;
        CE_cnt2   += (total_result==CE)  ? 1 : 0;
        DUE_cnt2  += (total_result==DUE) ? 1 : 0;
        SDC_cnt2  += (total_result==SDC) ? 1 : 0;
    }

    // --- Reports ---
    fprintf(fp3,"\n=====WRITE_LINK_DETECT_only=====\n");
    fprintf(fp3,"Runtime : %d\n",RUN_WRDET);
    fprintf(fp3,"NE : %d\n",WRDET_NE);
    fprintf(fp3,"DUE: %d\n",WRDET_DUE);
    fprintf(fp3,"===============================\n");
    fflush(fp3);

    fprintf(fp3,"\n=====OECC_count==========\n");
    fprintf(fp3,"Runtime : %d\n",RUN_OECC);
    fprintf(fp3,"NE : %d\n",NE_cnt);
    fprintf(fp3,"CE : %d\n",CE_cnt);
    fprintf(fp3,"DUE: %d\n",DUE_cnt);
    fprintf(fp3,"SDC: %d\n",SDC_cnt);
    fprintf(fp3,"=========================\n");
    fflush(fp3);

    fprintf(fp3,"\n=====SECC_count=========\n");
    fprintf(fp3,"Runtime : %d\n",RUN_SECC);
    fprintf(fp3,"NE : %d\n",NE_cnt1);
    fprintf(fp3,"CE : %d\n",CE_cnt1);
    fprintf(fp3,"DUE: %d\n",DUE_cnt1);
    fprintf(fp3,"SDC: %d\n",SDC_cnt1);
    fprintf(fp3,"========================\n");
    fflush(fp3);

    fprintf(fp3,"\n=====Total_count========\n");
    fprintf(fp3,"Runtime : %d\n",RUN_NUM);
    fprintf(fp3,"NE : %d\n",NE_cnt2);
    fprintf(fp3,"CE : %d\n",CE_cnt2);
    fprintf(fp3,"DUE: %d\n",DUE_cnt2);
    fprintf(fp3,"SDC: %d\n",SDC_cnt2);
    fprintf(fp3,"Total : %d\n",CE_cnt2 + DUE_cnt2 + SDC_cnt2);
    fprintf(fp3,"========================\n");
    fflush(fp3);

    fprintf(fp3,"\n=====Total_Final==========\n");
    fprintf(fp3,"Runtime : %d\n",RUN_NUM);
    fprintf(fp3,"NE  : %.7f\n", 100.0*(double)NE_cnt2 /(double)RUN_NUM);
    fprintf(fp3,"CE  : %.7f\n", 100.0*(double)CE_cnt2 /(double)RUN_NUM);
    fprintf(fp3,"DUE : %.7f\n", 100.0*(double)DUE_cnt2/(double)RUN_NUM);
    fprintf(fp3,"SDC : %.7f\n", 100.0*(double)SDC_cnt2/(double)RUN_NUM);
    fprintf(fp3,"==========================\n");
    fflush(fp3);

    fclose(fp3);
    return 0;
}

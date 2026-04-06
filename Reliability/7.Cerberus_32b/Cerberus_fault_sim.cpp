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
#define OECC_CW_LEN 288     // on-die codeword length (bits)
#define OECC_DATA_LEN 272   // on-die data length (bits)
#define OECC_REDUN_LEN 16   // on-die redundancy (bits)

// System ECC configuration //
#define SECC_CW_LEN 288     // system codeword length (bits)
#define SECC_DATA_LEN 256   // system data length (bits)
#define SECC_REDUN_LEN 32   // system redundancy (bits)

#define SECC_REDUN_LEN_BASE 16

#define SECC_CW_SYMBOL 18   // system codeword in symbols
#define SECC_DATA_SYMBOL 16 // system data in symbols
#define SECC_REDUN_SYMBOL 2 // system redundancy in symbols

#define RUN_NUM 10000000    // simulation runs

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
unsigned int H_Matrix_OECC_16bound[OECC_REDUN_LEN][OECC_CW_LEN]; // 16x288

// Hsecc for SECC DEC (binary 32x288)
static const int M_BITS = SYMBOL_SIZE;               // 16
static const int TWO_M  = 2 * SYMBOL_SIZE;           // 32
static const int N_SYM  = SECC_CW_SYMBOL;            // 18
static const int N_COLS = SECC_CW_LEN;               // 288

// ------------------------------------------------------------------------------------
// Hsecc containers (for DEC)
// ------------------------------------------------------------------------------------
static unsigned char Hsecc[TWO_M][N_COLS];
static unsigned int  Hcol_mask[N_COLS];
static unsigned int  Hblock_col_mask[N_SYM][M_BITS];
static std::unordered_map<unsigned int, unsigned int> DEC_LUT_UNIQUE;

// ------------------------------------------------------------------------------------
// Helpers
// ------------------------------------------------------------------------------------
static inline unsigned int pack_pair(unsigned int i, unsigned int bi, unsigned int j, unsigned int bj) {
    return ( (i & 0xFFu) << 24 ) | ( (bi & 0xFFu) << 16 ) | ( (j & 0xFFu) << 8 ) | (bj & 0xFFu);
}
static inline void unpack_pair(unsigned int p, unsigned int &i, unsigned int &bi, unsigned int &j, unsigned int &bj) {
    i  = (p >> 24) & 0xFFu;
    bi = (p >> 16) & 0xFFu;
    j  = (p >>  8) & 0xFFu;
    bj =  p        & 0xFFu;
}
static inline unsigned int parity32(unsigned int x) {
    unsigned int p = 0;
    while (x) { p ^= (x & 1u); x >>= 1; }
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

static void precompute_packed_columns() {
    for (int c=0; c<N_COLS; ++c) {
        unsigned int m = 0u;
        for (int r=0; r<TWO_M; ++r) if (Hsecc[r][c]) m |= (1u<<r);
        Hcol_mask[c] = m;
    }
    for (int j=0; j<N_SYM; ++j) for (int b=0; b<M_BITS; ++b)
        Hblock_col_mask[j][b] = Hcol_mask[j*M_BITS + b];
}
static void build_DEC_LUT_unique() {
    DEC_LUT_UNIQUE.clear();
    std::unordered_set<unsigned int> ambiguous;
    for (int i=0; i<N_SYM; ++i) for (int j=i+1; j<N_SYM; ++j)
        for (int bi=0; bi<M_BITS; ++bi) {
            unsigned int si = Hblock_col_mask[i][bi];
            for (int bj=0; bj<M_BITS; ++bj) {
                unsigned int sj = Hblock_col_mask[j][bj];
                unsigned int key = si ^ sj;
                if (ambiguous.find(key) != ambiguous.end()) continue;
                auto it = DEC_LUT_UNIQUE.find(key);
                if (it == DEC_LUT_UNIQUE.end()) {
                    DEC_LUT_UNIQUE.emplace(key, pack_pair((unsigned int)i,(unsigned int)bi,(unsigned int)j,(unsigned int)bj));
                } else {
                    DEC_LUT_UNIQUE.erase(key);
                    ambiguous.insert(key);
                }
            }
        }
}
static inline unsigned int compute_syndrome_packed(const unsigned int receive_codeword[SECC_CW_LEN]) {
    unsigned int synd = 0;
    for (int c=0; c<N_COLS; ++c) if (receive_codeword[c] & 1u) synd ^= Hcol_mask[c];
    return synd;
}

// ============================================================================
// GF(2^16) with primitive polynomial 0x1100B (x^16 + x^12 + x^3 + x + 1)
// (for SSC: BM(t=1)+Chien over GF domain)
// ============================================================================
static const uint32_t GF_POLY_16 = 0x1100B;
static const int      GF_M       = 16;
static const int      GF_SIZE    = (1 << GF_M);      // 65536
static const int      GF_ORDER   = GF_SIZE - 1;      // 65535
static const uint16_t GF_ZERO_SENT = (uint16_t)GF_ORDER; // sentinel for 0 (when using exponents)

static uint16_t gf_exp[2*GF_ORDER];
static uint16_t gf_log[GF_SIZE];

//GF table
static inline void gf_init() {
    uint32_t x = 1u;
    for (int i=0;i<GF_ORDER;++i) {
        gf_exp[i] = (uint16_t)x;
        gf_log[x] = (uint16_t)i;
        x <<= 1u;
        if (x & GF_SIZE) x ^= GF_POLY_16;
        x &= (GF_SIZE-1u);
    }
    for (int i=GF_ORDER;i<2*GF_ORDER;++i) gf_exp[i] = gf_exp[i-GF_ORDER];
    gf_log[0] = GF_ZERO_SENT;
}


static inline uint16_t gf_pow_alpha(int e) { e%=GF_ORDER; if(e<0) e+=GF_ORDER; return gf_exp[e]; }
static inline uint16_t gf_mul(uint16_t a, uint16_t b) { if(!a||!b) return 0; return gf_exp[(gf_log[a]+gf_log[b])%GF_ORDER]; }
static inline uint16_t gf_div(uint16_t a, uint16_t b) { if(!a) return 0; if(!b) return 0; int e=(int)gf_log[a]-(int)gf_log[b]; e%=GF_ORDER; if(e<0)e+=GF_ORDER; return gf_exp[e]; }


static inline uint16_t load_symbol16(const unsigned int *bits, int base) {
    uint16_t v=0; for(int b=0;b<16;++b) v |= ((bits[base+b]&1u)<<(15-b)); return v;
}
static inline void store_symbol16(unsigned int *bits, int base, uint16_t val) {
    for(int b=0;b<16;++b){ unsigned bit=(val>>(15-b))&1u; bits[base+b]=bit; }
}

static uint16_t H_Matrix_SSC_DEC[2][SECC_CW_SYMBOL]; 
static uint16_t H_A[SECC_CW_SYMBOL]; 
static uint16_t H_B[SECC_CW_SYMBOL]; 
static uint16_t H_ratio[SECC_CW_SYMBOL]; 

static inline void ssc_precompute_AB_ratio() {
    for (int j=0;j<SECC_CW_SYMBOL;++j) {
        H_A[j] = (H_Matrix_SSC_DEC[0][j]==GF_ZERO_SENT)? 0 : gf_pow_alpha((int)H_Matrix_SSC_DEC[0][j]);
        H_B[j] = (H_Matrix_SSC_DEC[1][j]==GF_ZERO_SENT)? 0 : gf_pow_alpha((int)H_Matrix_SSC_DEC[1][j]);
        H_ratio[j] = (H_A[j] && H_B[j]) ? gf_div(H_B[j], H_A[j]) : GF_ZERO_SENT;
    }
}
static inline void ssc_compute_syndrome_GF(const unsigned int cw[SECC_CW_LEN], uint16_t &S0, uint16_t &S1) {
    S0=0; S1=0;
    for (int j=0;j<SECC_CW_SYMBOL;++j) {
        uint16_t r = load_symbol16(cw, j*SYMBOL_SIZE);
        if (!r) continue;
        if (H_A[j]) S0 ^= gf_mul(r, H_A[j]);
        if (H_B[j]) S1 ^= gf_mul(r, H_B[j]);
    }
}

// BM(t=1)+Chien
static inline RESULT_TYPE secc_try_ssc_bm_chien(unsigned int cw[SECC_CW_LEN]) {
    uint16_t S0,S1; ssc_compute_syndrome_GF(cw, S0, S1);
    if (S0==0 && S1==0) return NE;

    struct Cand { int j; uint16_t e; };
    vector<Cand> cands;

    if (S0!=0 && S1!=0) {
        uint16_t rho = gf_div(S1, S0);
        for (int j=0;j<SECC_CW_SYMBOL;++j) {
            if (H_ratio[j]==rho && H_A[j]!=0) {
                uint16_t e = gf_div(S0, H_A[j]);
                uint16_t v0 = (uint16_t)(S0 ^ gf_mul(e, H_A[j]));
                uint16_t v1 = (uint16_t)(S1 ^ gf_mul(e, H_B[j]));
                if (v0==0 && v1==0) cands.push_back({j,e});
            }
        }
    } else if (S0!=0 && S1==0) {
        for (int j=0;j<SECC_CW_SYMBOL;++j) if (H_B[j]==0 && H_A[j]!=0) {
            uint16_t e = gf_div(S0, H_A[j]);
            uint16_t v0 = (uint16_t)(S0 ^ gf_mul(e, H_A[j]));
            uint16_t v1 = (uint16_t)(S1 ^ gf_mul(e, H_B[j])); // == S1
            if (v0==0 && v1==0) cands.push_back({j,e});
        }
    } else if (S0==0 && S1!=0) {
        for (int j=0;j<SECC_CW_SYMBOL;++j) if (H_A[j]==0 && H_B[j]!=0) {
            uint16_t e = gf_div(S1, H_B[j]);
            uint16_t v0 = (uint16_t)(S0 ^ gf_mul(e, H_A[j])); // == S0
            uint16_t v1 = (uint16_t)(S1 ^ gf_mul(e, H_B[j]));
            if (v0==0 && v1==0) cands.push_back({j,e});
        }
    }

    if (cands.size()==1) {
        int j = cands[0].j; uint16_t e = cands[0].e;
        uint16_t rj = load_symbol16(cw, j*SYMBOL_SIZE);
        rj ^= e;
        store_symbol16(cw, j*SYMBOL_SIZE, rj);
        return CE;
    }
    return DUE;
}

// ------------------------------------------------------------------------------------
// Error injection
// ------------------------------------------------------------------------------------
// Storage
void error_injection_SE(unsigned int codeword[OECC_CW_LEN]) {
    int Fault_pos = rand() % OECC_CW_LEN;
    codeword[Fault_pos] ^= 1;
}

void error_injection_SE_SE(unsigned int codeword[OECC_CW_LEN]) {
    int Fault_pos1 = rand()%OECC_CW_LEN;
    int Fault_pos2; do{ Fault_pos2 = rand() % OECC_CW_LEN; } while(Fault_pos2==Fault_pos1);
    codeword[Fault_pos1] ^= 1; codeword[Fault_pos2] ^= 1;
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
    codeword[Fault_pos] ^= 1;
}

void error_injection_Link_DE(unsigned int codeword[OECC_CW_LEN]) {
    int Fault_pos1 = rand()%SECC_CW_LEN;
    int Fault_pos2; do{ Fault_pos2 = rand() % SECC_CW_LEN; } while(Fault_pos2==Fault_pos1);
    codeword[Fault_pos1] ^= 1u; codeword[Fault_pos2] ^= 1u;
}

void error_injection_Link_DQ(unsigned int codeword[SECC_CW_LEN]) {
    int dq = rand() % 36;  
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

        for (int s = 0; s < 36; ++s) {
            unsigned int flip = rand() & 1u;
            mask |= (uint64_t)flip << s;  
            cnt += flip;
        }

        if (cnt >= 1) {  
            for (int s = 0; s < 36; ++s) {
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
// OECC
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
            codeword[error_pos]^=1;
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
// S-ECC: SSC + DEC
// ------------------------------------------------------------------------------------
static bool init_ssc_dec_from_Hsecc(const char* hsecc_path) {
    if (!load_Hsecc_from_file(hsecc_path)) {
        fprintf(stderr, "[ERR] Failed to load H' from %s\n", hsecc_path);
        return false;
    }
    precompute_packed_columns();
    build_DEC_LUT_unique();  
    return true;
}

void error_correction_secc_SSC_DEC(int *result_type_secc, unsigned int receive_codeword[SECC_CW_LEN]) {
    uint16_t S0,S1; ssc_compute_syndrome_GF(receive_codeword, S0, S1);
    if (S0==0 && S1==0) {
        unsigned int bin_syn = compute_syndrome_packed(receive_codeword);
        if (bin_syn==0u) { *result_type_secc = NE; return; }
    } else {
        RESULT_TYPE r = secc_try_ssc_bm_chien(receive_codeword);
        if (r==CE) {
            *result_type_secc = CE;
            return;
        }
    }

    unsigned int synd = compute_syndrome_packed(receive_codeword);
    if (synd == 0u) { *result_type_secc = NE; return; }

    auto it = DEC_LUT_UNIQUE.find(synd);
    if (it != DEC_LUT_UNIQUE.end()) {
        unsigned int i,bi,j,bj; unpack_pair(it->second, i,bi,j,bj);
        receive_codeword[i*SYMBOL_SIZE + bi] ^= 1u;
        receive_codeword[j*SYMBOL_SIZE + bj] ^= 1u;
        unsigned int synd_after = compute_syndrome_packed(receive_codeword);
        *result_type_secc = (synd_after==0u) ? CE : DUE;
        return;
    }
    *result_type_secc = DUE;
}

// ------------------------------------------------------------------------------------
// Main
// ------------------------------------------------------------------------------------
int main(int argc, char* argv[]) {
    if (argc < 5) {
        fprintf(stderr, "Usage: %s <LINK1_FAULT> <STOR_FAULT> <PERI_FAULT> <LINK2_FAULT> [Hprime_path]\n", argv[0]);
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
                if (fscanf(fp4,"%u",&value)!=1){ fclose(fp4); fprintf(stderr,"[ERR] Bad H2_matrix.txt format\n"); return 1; }
                H_Matrix_OECC_16bound[row][column]=value;
            }
        }
        fclose(fp4);
    }

    const char* hsecc_path = (argc >= 6) ? argv[5] : "Hsecc.txt";
    if (!init_ssc_dec_from_Hsecc(hsecc_path)) return 1;

    gf_init();

    for (int j=0;j<SECC_CW_SYMBOL;++j) {
        H_Matrix_SSC_DEC[0][j] = GF_ZERO_SENT; 
        H_Matrix_SSC_DEC[1][j] = GF_ZERO_SENT;
    }

    if (SECC_CW_SYMBOL == 18) {
        H_Matrix_SSC_DEC[0][0]=8737;              H_Matrix_SSC_DEC[1][0]=17014;
        H_Matrix_SSC_DEC[0][1]=25040;             H_Matrix_SSC_DEC[1][1]=34191;
        H_Matrix_SSC_DEC[0][2]=35330;             H_Matrix_SSC_DEC[1][2]=33012;
        H_Matrix_SSC_DEC[0][3]=51047;             H_Matrix_SSC_DEC[1][3]=30645;
        H_Matrix_SSC_DEC[0][4]=5611;              H_Matrix_SSC_DEC[1][4]=53194;
        H_Matrix_SSC_DEC[0][5]=46405;             H_Matrix_SSC_DEC[1][5]=57850;
        H_Matrix_SSC_DEC[0][6]=35973;             H_Matrix_SSC_DEC[1][6]=29336;
        H_Matrix_SSC_DEC[0][7]=38034;             H_Matrix_SSC_DEC[1][7]=11476;
        H_Matrix_SSC_DEC[0][8]=43571;             H_Matrix_SSC_DEC[1][8]=54584;
        H_Matrix_SSC_DEC[0][9]=23874;             H_Matrix_SSC_DEC[1][9]=56173;
        H_Matrix_SSC_DEC[0][10]=51071;            H_Matrix_SSC_DEC[1][10]=40759;
        H_Matrix_SSC_DEC[0][11]=51321;            H_Matrix_SSC_DEC[1][11]=48027;
        H_Matrix_SSC_DEC[0][12]=34825;            H_Matrix_SSC_DEC[1][12]=57106;
        H_Matrix_SSC_DEC[0][13]=5137;             H_Matrix_SSC_DEC[1][13]=35740;
        H_Matrix_SSC_DEC[0][14]=38482;            H_Matrix_SSC_DEC[1][14]=60702;
        H_Matrix_SSC_DEC[0][15]=17656;            H_Matrix_SSC_DEC[1][15]=3508;
        H_Matrix_SSC_DEC[0][16]=22904;            H_Matrix_SSC_DEC[1][16]=56958; 
        H_Matrix_SSC_DEC[0][17]=42213;            H_Matrix_SSC_DEC[1][17]=39862;
    }

    ssc_precompute_AB_ratio();

    int link1_arg = atoi(argv[1]);
    int stor_arg  = atoi(argv[2]);
    int peri_arg = atoi(argv[3]);
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
    string Result_file_name = "Result/Cerberus_" + L1_STR  + "_" + ST_STR + "_" + P_STR + "_" + L2_STR + ".S";
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

        // 1) setting
        unsigned int data_bits[SECC_DATA_LEN];
        for (int i=0;i<SECC_CW_LEN;++i) codeword[i]=0;

        for (int i = 0; i < SECC_CW_LEN; ++i) codeword1[i] = codeword[i];

        unsigned int codeword_L1_clean[OECC_CW_LEN];
        for (int i = 0; i < SECC_CW_LEN; ++i) codeword_L1_clean[i] = codeword[i];
        int wr_link1_detected = 0;

        // 2) WRITE LINK
        switch (link1_type){
            case NE_L: break;
            case SE_L: error_injection_Link_SE(codeword);  break;
            case DQS : error_injection_Link_DQS(codeword); break;
            case DQ  : error_injection_Link_DQ(codeword);  break;
            default:  break;
        }

        // 3) Detect-only with H_matrix
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

        for (int i = 0; i < 288; i++) {
            if(codeword[i] == 1 && (result_type_oecc == CE)) {
                result_type_oecc = SDC;
            }
        }
        
        NE_cnt   += (result_type_oecc==NE)  ? 1 : 0;
        CE_cnt   += (result_type_oecc==CE)  ? 1 : 0;
        DUE_cnt  += (result_type_oecc==DUE) ? 1 : 0;
        SDC_cnt  += (result_type_oecc==SDC) ? 1 : 0;

        unsigned int cw_base[SECC_CW_LEN];
        for (int i = 0; i < SECC_CW_LEN; ++i) cw_base[i] = codeword[i];

        // 6) READ side faults for attempt #1: start from cw_base
        for (int i = 0; i < SECC_CW_LEN; ++i) codeword[i] = cw_base[i];

        // 7) PERI2
        switch (peri_type){
            case NE_P: break;
            case SE_P: error_injection_Link_SE(codeword);  break;
            case DE_P: error_injection_Link_DE(codeword);  break;
            default:  break;
        }

        // 8) READ LINK
        switch (link2_type){
            case NE_L: break;
            case SE_L: error_injection_Link_SE(codeword);  break;
            case DQS : error_injection_Link_DQS(codeword); break;
            case DQ  : error_injection_Link_DQ(codeword);  break;
            default:  break;
        }

        // 9) S-ECC decode (SSC+DEC)
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

        // 10) Final
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

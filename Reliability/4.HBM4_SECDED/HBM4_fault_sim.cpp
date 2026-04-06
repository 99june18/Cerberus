#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <iostream>
#include <vector>
#include <algorithm>
#include <set>
#include <stdint.h>

using namespace std;

// ----------------------------------------------------------------------------
// Dimensions
// ----------------------------------------------------------------------------
#define SYMBOL_SIZE          16     // 16-bit symbol for on-die SSC

#define CW_LEN               304    // total on-die codeword (bits)
#define SSC_N                19     // (19,17) over full 304b
#define SSC_K                17
#define SSC_PARITY_SYMS      2
#define TOTAL_SYMBOLS        (CW_LEN / SYMBOL_SIZE) // 19

#define DATA_LEN             272    // system data region seen by link/S-ECC (payload 256b + 16b parity)
#define DATA_PAYLOAD_BITS    256    // user payload
#define SECC_CRC_BITS        16     // (historic; not used now)

#define LINK_CW_LEN          280    // 272 + 8 parity (8-way 34B XOR parity)
#define LINK_PARITY_BITS     8

// ---- S-ECC(SEC-DED) matrix dimensions ----
#define SECC_REDUN_LEN       16     // 16 parity-check rows
#define SECC_CW_LEN          DATA_LEN  // 272 columns (256 data + 16 parity)

//#define RUN_NUM              1
#define RUN_NUM              1000000000

// ----------------------------------------------------------------------------
// Enumerations / Result types
// ----------------------------------------------------------------------------
enum STORAGE_FAULT_TYPE {NE_O = 0, SE   = 1, SE_SE = 2, SWL_16E = 3, SWD_32E = 4};
enum LINK_FAULT_TYPE    {NE_L = 0, SE_L = 1, DQS   = 2, DQ  = 3};
enum PERI_FAULT_TYPE    {NE_P = 0, SE_P = 1, DE_P  = 2};
enum RESULT_TYPE        {NE   = 0, CE   = 1, DUE   = 2, SDC = 3};

// ----------------------------------------------------------------------------
// GF(2^16) tables for poly x^16 + x^12 + x^3 + x + 1 (0x1100B)
// ----------------------------------------------------------------------------
static uint16_t gf16_exp[2 * 65535];
static uint16_t gf16_log[65536];

static inline void gf16_init_0x1100B() {
    uint32_t x = 1;
    for (int i = 0; i < 65535; ++i) {
        uint16_t a = (uint16_t)(x & 0xFFFF);
        gf16_exp[i] = a;
        gf16_log[a] = (uint16_t)i;

        x <<= 1;
        if (x & 0x10000u) x ^= 0x1100Bu;
        x &= 0xFFFFu;
    }
    for (int i = 65535; i < 2 * 65535; ++i) {
        gf16_exp[i] = gf16_exp[i - 65535];
    }
    gf16_log[0] = 0xFFFF;
}

static inline uint16_t gf16_mul(uint16_t a, uint16_t b) {
    if (a == 0 || b == 0) return 0;
    return gf16_exp[ gf16_log[a] + gf16_log[b] ];
}

// α^i (mod 65535)
static inline uint16_t gf16_pow_alpha(int i) {
    i %= 65535;
    if (i < 0) i += 65535;
    return gf16_exp[i];
}

// division a/b in GF(2^16)
static inline uint16_t gf16_div(uint16_t a, uint16_t b) {
    if (a == 0) return 0;
    if (b == 0) { return 0; }
    int la = gf16_log[a];
    int lb = gf16_log[b];
    if (la == 0xFFFF || lb == 0xFFFF) return 0;
    int idx = la - lb;
    idx %= 65535; if (idx < 0) idx += 65535;
    return gf16_exp[idx];
}

static inline int any_one_bits(const unsigned int *arr, int nbits) {
    for (int i=0; i<nbits; ++i) if (arr[i] & 1u) return 1;
    return 0;
}

// ----------------------------------------------------------------------------
// Bit/Symbol helpers
// ----------------------------------------------------------------------------
static inline uint16_t load_symbol(const unsigned int *bits, int base_bit) {
    uint16_t v = 0;
    for (int b = 0; b < SYMBOL_SIZE; ++b) {
        v |= ((bits[base_bit + b] & 1u) << (SYMBOL_SIZE - 1 - b));
    }
    return v;
}

static inline void store_symbol(unsigned int *bits, int base_bit, uint16_t val) {
    for (int b = 0; b < SYMBOL_SIZE; ++b) {
        unsigned int bit = (val >> (SYMBOL_SIZE - 1 - b)) & 1u;
        bits[base_bit + b] = bit;
    }
}

// ----------------------------------------------------------------------------
// Storage Error injection
// ----------------------------------------------------------------------------
void error_injection_SE(unsigned int codeword[CW_LEN]) {
    int p1 = rand() % CW_LEN;
    codeword[p1] ^= 1u;
}

void error_injection_SE_SE(unsigned int codeword[CW_LEN]) {
    int p1 = rand() % CW_LEN;
    int p2; do { p2 = rand() % CW_LEN; } while (p2==p1);
    codeword[p1] ^= 1u; codeword[p2] ^= 1u;
}

// Subwordline 16b burst
void error_injection_SWL_16E(unsigned int codeword[CW_LEN]) {
    int sym_idx = rand() % 19; 
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
void error_injection_SWD_32E(unsigned int codeword[CW_LEN]) {
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

// ----------------------------------------------------------------------------
// Peri Error injection
// ----------------------------------------------------------------------------
static inline void peri_error_injection_SE(unsigned int data272[DATA_LEN]) {
    int p1 = rand() % DATA_LEN;
    data272[p1] ^= 1u;
}

static inline void peri_error_injection_DE(unsigned int data272[DATA_LEN]) {
    int p1 = rand() % DATA_LEN;
    int p2; do { p2 = rand() % DATA_LEN; } while (p2==p1);
    data272[p1] ^= 1u; data272[p2] ^= 1u;
}

// ----------------------------------------------------------------------------
// Link Error injection
// ----------------------------------------------------------------------------
void error_injection_Link_SE(unsigned int codeword[LINK_CW_LEN]) {
    int p1 = rand() % LINK_CW_LEN;
    codeword[p1] ^= 1u;
}

// DQSE
void error_injection_Link_DQS(unsigned int codeword[LINK_CW_LEN]) {
    int lane = rand() % 8;   
    while (1) {
        int cnt = 0;
        uint64_t mask = 0;   

        for (int s = 0; s < 35; ++s) {
            unsigned int flip = rand() & 1u;
            mask |= (flip << s);   
            cnt += flip;
        }

        if (cnt >= 1) {  
            for (int s = 0; s < 35; ++s) {
                if ((mask >> s) & 1u) {
                    int idx = lane + s * 8;  
                    codeword[idx] ^= 1u;
                }
            }
            break;
        }
    }
}

// DQE
void error_injection_Link_DQ(unsigned int codeword[LINK_CW_LEN]) {
    int dq = rand() % 35;  
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


// ----------------------------------------------------------------------------
// On-die SSC (16b, (19,17))
// ----------------------------------------------------------------------------
static inline void ondie_ssc_encode_full16(const unsigned int data272[DATA_LEN],
                                           unsigned int cw_bits_out[CW_LEN]) {
    for (int i = 0; i < DATA_LEN; ++i) cw_bits_out[i] = data272[i] & 1u;

    uint16_t d0 = 0, d1 = 0;
    for (int i = 0; i < SSC_K; ++i) {
        int base = i * SYMBOL_SIZE;
        uint16_t di = load_symbol(data272, base);
        d0 ^= di;
        d1 ^= gf16_mul(di, gf16_pow_alpha(i));
    }

    const uint16_t a17 = gf16_pow_alpha(17);
    const uint16_t a18 = gf16_pow_alpha(18);
    uint16_t denom = a17 ^ a18;

    uint16_t numer = d1 ^ gf16_mul(a18, d0);
    uint16_t p0 = gf16_div(numer, denom);
    uint16_t p1 = d0 ^ p0;

    store_symbol(cw_bits_out, 17 * SYMBOL_SIZE, p0);
    store_symbol(cw_bits_out, 18 * SYMBOL_SIZE, p1);
}

void ondie_ssc_decode_full16(int *result_type, unsigned int cw_bits[CW_LEN]) {
    uint16_t S0 = 0, S1 = 0;
    for (int i = 0; i < SSC_N; ++i) {
        const int sym_base = i * SYMBOL_SIZE;
        const uint16_t ri = load_symbol(cw_bits, sym_base);
        if (ri == 0) continue;
        const uint16_t ei = gf16_log[ri];
        if (ei == 0xFFFF) continue;
        S0 ^= gf16_exp[ei];
        const int e_shift = (ei + i) % 65535;
        S1 ^= gf16_exp[e_shift];
    }
    if (S0 == 0 && S1 == 0) { *result_type = NE;  return; }
    if (S0 == 0 || S1 == 0) { *result_type = DUE; return; }

    int err_pos = -1;
    for (int j = 0; j < SSC_N; ++j) {
        if (gf16_mul(S0, gf16_exp[j]) == S1) { err_pos = j; break; }
    }
    if (err_pos < 0) {
        const uint16_t p = gf16_log[S0], q = gf16_log[S1];
        if (p == 0xFFFF || q == 0xFFFF) { *result_type = DUE; return; }
        int pos = (int)q - (int)p;
        pos %= 65535; if (pos < 0) pos += 65535;
        if (0 <= pos && pos < SSC_N) err_pos = pos;
    }

    if (0 <= err_pos && err_pos < SSC_N) {
        const int sym_base = err_pos * SYMBOL_SIZE;
        uint16_t rj = load_symbol(cw_bits, sym_base);
        rj ^= S0;                            // 단일-심볼 교정
        store_symbol(cw_bits, sym_base, rj);
        *result_type = CE;
    } else {
        *result_type = DUE;
    }
}

// ----------------------------------------------------------------------------
// Link parity encode/decode helpers
// ----------------------------------------------------------------------------
// parity[i] = XOR of bit-lane i across 34 bytes (272/8)
static inline void link_make_parity_8(const unsigned int data272[DATA_LEN], unsigned int parity8[LINK_PARITY_BITS]) {
    for (int i = 0; i < LINK_PARITY_BITS; ++i) {
        unsigned int x = 0;
        for (int blk = 0; blk < (DATA_LEN / 8); ++blk) {
            int bit_idx = blk * 8 + i; // 0..271
            x ^= (data272[bit_idx] & 1u);
        }
        parity8[i] = x & 1u;
    }
}
static inline void link_build_280(const unsigned int data272[DATA_LEN], const unsigned int parity8[LINK_PARITY_BITS],
                                  unsigned int out280[LINK_CW_LEN]) {
    for (int i = 0; i < DATA_LEN; ++i) out280[i] = data272[i] & 1u;
    for (int i = 0; i < LINK_PARITY_BITS; ++i) out280[DATA_LEN + i] = parity8[i] & 1u;
}

static inline int link_detect_result(const unsigned int recv280[LINK_CW_LEN]) {
    int mismatch = 0;
    for (int i = 0; i < LINK_PARITY_BITS; ++i) {
        unsigned int x = 0;
        for (int blk = 0; blk < (DATA_LEN / 8); ++blk) {
            int bit_idx = blk * 8 + i;
            x ^= (recv280[bit_idx] & 1u);
        }
        unsigned int parity_rx = recv280[DATA_LEN + i] & 1u;
        if ((x & 1u) != parity_rx) { mismatch = 1; break; }
    }
    return mismatch ? DUE : NE; // DUE == "detected" flag here
}

// ----------------------------------------------------------------------------
// S-ECC SEC-DED
// ----------------------------------------------------------------------------
static unsigned int H_Matrix_SECC[SECC_REDUN_LEN][SECC_CW_LEN];

static bool load_secc_h_matrix(const char* fname) {
    FILE* fh = fopen(fname, "r");
    if (!fh) return false;
    for (int r=0; r<SECC_REDUN_LEN; ++r) {
        for (int c=0; c<SECC_CW_LEN; ++c) {
            unsigned int v;
            if (fscanf(fh, "%u", &v) != 1) { fclose(fh); return false; }
            H_Matrix_SECC[r][c] = (v & 1u);
        }
    }
    fclose(fh);
    return true;
}

static void error_correction_secc (int *result_type_secc, unsigned int codeword[SECC_CW_LEN]) {
    unsigned int Syndromes[SECC_REDUN_LEN] = {0};

    for (int row = 0; row < SECC_REDUN_LEN; row++) {
        unsigned int row_value = 0;
        for (int column = 0; column < SECC_CW_LEN; column++) {
            row_value ^= (H_Matrix_SECC[row][column] & 1u) & (codeword[column] & 1u);
        }
        Syndromes[row] = row_value & 1u;
    }

    bool all_zero = true;
    for (int i = 0; i < SECC_REDUN_LEN; i++) {
        if (Syndromes[i] != 0) { all_zero = false; break; }
    }
    if (all_zero) { *result_type_secc = NE; return; }

    for (int error_pos = 0; error_pos < SECC_CW_LEN; error_pos++) {
        int cnt = 0;
        for (int row = 0; row < SECC_REDUN_LEN; row++) {
            if ((int)Syndromes[row] == (int)H_Matrix_SECC[row][error_pos]) cnt++;
            else break;
        }
        if (cnt == SECC_REDUN_LEN) {
            codeword[error_pos] ^= 1u;
            *result_type_secc = CE;
            return;
        }
    }

    *result_type_secc = DUE;
}

// ----------------------------------------------------------------------------
// Fault type naming
// ----------------------------------------------------------------------------
void fault_type_assignment_wr(
    string &L1_STR,  string &STOR_STR, string &P_STR,  string &L2_STR,
    int *link1_type, int *stor_type,   int *peri_type, int *link2_type,
    int link1_arg,   int stor_arg,     int peri_arg,   int link2_arg)
{
    // LINK1
    switch (link1_arg) {
        case NE_L: L1_STR="NE_L"; *link1_type=NE_L; break;
        case SE_L: L1_STR="SE_L"; *link1_type=SE_L; break;
        case DQS : L1_STR="DQS";  *link1_type=DQS;  break;
        case DQ:   L1_STR="DQ";   *link1_type=DQ;   break;
        default:   L1_STR="NE_L"; *link1_type=NE_L; break;
    }
    // STORAGE
    switch (stor_arg) {
        case NE_O:      STOR_STR="NE_O";    *stor_type=NE_O;    break;
        case SE:        STOR_STR="SE";      *stor_type=SE;      break;
        case SE_SE:     STOR_STR="SE_SE";   *stor_type=SE_SE;   break;
        case SWL_16E:   STOR_STR="SWL_16E"; *stor_type=SWL_16E; break;
        case SWD_32E:   STOR_STR="SWD_32E"; *stor_type=SWD_32E; break;
        default:        STOR_STR="NE_O";    *stor_type=NE_O;    break;
    }
    // PERI
    switch (peri_arg) {
        case NE_P: P_STR="NE_P"; *peri_type=NE_P; break;
        case SE_P: P_STR="SE_P"; *peri_type=SE_P; break;
        case DE_P: P_STR="DE_P"; *peri_type=DE_P; break;
        default:   P_STR="NE_P"; *peri_type=NE_P; break;
    }
    // LINK2
    switch (link2_arg) {
        case NE_L: L2_STR="NE_L"; *link2_type=NE_L; break;
        case SE_L: L2_STR="SE_L"; *link2_type=SE_L; break;
        case DQS : L2_STR="DQS";  *link2_type=DQS;  break;
        case DQ:   L2_STR="DQ";   *link2_type=DQ;   break;
        default:   L2_STR="NE_L"; *link2_type=NE_L; break;
    }
}

// ----------------------------------------------------------------------------
// Main
// ----------------------------------------------------------------------------
int main(int argc, char* argv[]) {
    if (argc < 5) {
        fprintf(stderr, "Usage: %s <LINK1_FAULT> <STOR_FAULT> <PERI_FAULT> <LINK2_FAULT>\n", argv[0]);
        fprintf(stderr, "       LINK*_FAULT: 0=NE_L, 1=SE_L, 2=DQS, 3=DQ\n");
        fprintf(stderr, "       PERI*_FAULT: 0=NE_P, 1=SE_P, 2=DE_P\n");
        fprintf(stderr, "       STOR_FAULT : 0=NE_O, 1=SE,   2=SE_SE,   3=SWL_16E,  4=SWD_32E\n");
        return 1;
    }

    // GF(2^16) init
    gf16_init_0x1100B();

    // S-ECC(Hsiao) H matrix load
    if (!load_secc_h_matrix("H_matrix_SECC_SECDED_Hsiao.txt")) {
        fprintf(stderr, "[ERR] Cannot open or parse H_matrix_SECC_SECDED_Hsiao.txt (need 16x272 of 0/1)\n");
        return 1;
    }

    // Parse fault types & prepare output
    string L1_STR="X", STOR_STR="X", P_STR="X", L2_STR="X";
    int link1_fault_type=NE_L, storage_fault_type=NE_O, peri_fault_type=NE_P, link2_fault_type=NE_L;
    fault_type_assignment_wr(
        L1_STR, STOR_STR, P_STR, L2_STR,
        &link1_fault_type, &storage_fault_type, &peri_fault_type, &link2_fault_type,
        atoi(argv[1]), atoi(argv[2]), atoi(argv[3]), atoi(argv[4])
    );

    string Result_file_name = "Result/HBM4_SECDED_" + L1_STR + "_" + STOR_STR + "_" + P_STR + "_" + L2_STR + ".S";
    FILE *fp = fopen(Result_file_name.c_str(), "w");
    if (!fp) { fprintf(stderr,"[ERR] Cannot open result file\n"); return 1; }

    // Counters
    // Link1/Link2 detection
    int LINK1_PASS=0, LINK1_DET=0;
    int LINK2_PASS=0, LINK2_DET=0;

    // OECC and SECC counters
    int OECC_NE=0, OECC_CE=0, OECC_DUE=0, OECC_SDC=0;
    int SECC_NE=0, SECC_CE=0, SECC_DUE=0, SECC_SDC=0;

    // Totals
    int TOT_NE=0, TOT_CE=0, TOT_DUE=0, TOT_SDC=0;

    srand((unsigned int)time(NULL));

    // Working buffers
    unsigned int data_272[DATA_LEN];         
    unsigned int link_parity8[LINK_PARITY_BITS];
    unsigned int link_cw[LINK_CW_LEN];    
    unsigned int cw[CW_LEN];                
    unsigned int msg_272_for_secc[DATA_LEN]; 
    unsigned int data_256[DATA_PAYLOAD_BITS];

    unsigned int link_cw_L1_clean[LINK_CW_LEN];
    unsigned int link_cw_L2_clean[LINK_CW_LEN];
    
    for (int run=0; run<RUN_NUM; ++run) {
        if (run % 10000000 == 0) {
            fprintf(fp,"\n===============\n");
            fprintf(fp,"Runtime : %d/%d\n", run, RUN_NUM);
            fprintf(fp,"LINK1: PASS=%d DET=%d\n", LINK1_PASS, LINK1_DET);
            fprintf(fp,"OECC : NE=%d CE=%d DUE=%d SDC=%d\n", OECC_NE, OECC_CE, OECC_DUE, OECC_SDC);
            fprintf(fp,"LINK2: PASS=%d DET=%d\n", LINK2_PASS, LINK2_DET);
            fprintf(fp,"SECC : NE=%d CE=%d DUE=%d SDC=%d\n", SECC_NE, SECC_CE, SECC_DUE, SECC_SDC);
            fprintf(fp,"TOT  : NE=%d CE=%d DUE=%d SDC=%d\n", TOT_NE, TOT_CE, TOT_DUE, TOT_SDC);
            fprintf(fp,"===============\n");
            fflush(fp);
        }

        // 1) init 272b = 0
        memset(data_272, 0, sizeof(unsigned int)*DATA_LEN);

        // 2) Link encode: 272 -> 280
        link_make_parity_8(data_272, link_parity8);
        link_build_280(data_272, link_parity8, link_cw);

        for (int i=0; i<LINK_CW_LEN; ++i) link_cw_L1_clean[i] = link_cw[i];

        // 3) Link#1 error inject
        switch (link1_fault_type) {
            case NE_L: /* none */                  break;
            case SE_L: error_injection_Link_SE(link_cw); break;
            case DQS:  error_injection_Link_DQS(link_cw); break;
            case DQ:   error_injection_Link_DQ(link_cw); break;
            default:                                   break;
        }

        // 4) Link#1 detect
        int link1_detected = 0;
        if (link_detect_result(link_cw) != NE) {
            ++LINK1_DET;
            link1_detected = 1;
            for (int i=0; i<DATA_LEN; ++i) data_272[i] = link_cw_L1_clean[i] & 1u;
        } else {
            ++LINK1_PASS;
            for (int i=0; i<DATA_LEN; ++i) data_272[i] = link_cw[i] & 1u;
        }

        unsigned int data_272_1[DATA_LEN];
        for (int i = 0; i < DATA_LEN; i++) data_272_1[i] = data_272[i];
        
        // 5) O-ECC(SSC) encode: 272 -> 304
        ondie_ssc_encode_full16(data_272, cw);

        // 6) Storage error
        switch (storage_fault_type) {
            case NE_O: break;
            case SE:       error_injection_SE(cw);      break;
            case SE_SE:    error_injection_SE_SE(cw);   break;
            case SWL_16E:  error_injection_SWL_16E(cw); break;
            case SWD_32E:  error_injection_SWD_32E(cw); break;
        }

        // 7) O-ECC(SSC) decode over 304b
        int res_oecc = NE;
        ondie_ssc_decode_full16(&res_oecc, cw);

        for (int i = 0; i < DATA_LEN; i++) {
            if ( (data_272_1[i] != (cw[i] & 1u)) & (res_oecc == CE || res_oecc == NE) ) {
                res_oecc = SDC;
            }
        }
        if      (res_oecc==NE)  ++OECC_NE;
        else if (res_oecc==CE)  ++OECC_CE;
        else if (res_oecc==DUE) ++OECC_DUE;
        else                    ++OECC_SDC;

        for (int i=0; i<DATA_LEN; ++i) data_272[i] = cw[i] & 1u;

        // 8) Peri error
        switch (peri_fault_type) {
            case NE_P: /* none */                         break;
            case SE_P: peri_error_injection_SE(data_272); break;
            case DE_P: peri_error_injection_DE(data_272); break;
            default:                                      break;
        }

        // 9) Link encode
        link_make_parity_8(data_272, link_parity8);
        link_build_280(data_272, link_parity8, link_cw);

        for (int i=0; i<LINK_CW_LEN; ++i) link_cw_L2_clean[i] = link_cw[i];

        // 10) Link#2 error inject
        switch (link2_fault_type) {
            case NE_L: /* none */                        break;
            case SE_L: error_injection_Link_SE(link_cw); break;
            case DQS:  error_injection_Link_DQS(link_cw); break;
            case DQ:   error_injection_Link_DQ(link_cw); break;
            default:                                     break;
        }

        // 11) Link#2 detect
        int link2_detected = 0;
        if (link_detect_result(link_cw) != NE) {
            ++LINK2_DET;
            link2_detected = 1;
            for (int i=0; i<DATA_LEN; ++i) msg_272_for_secc[i] = link_cw_L2_clean[i] & 1u;
        } else {
            ++LINK2_PASS;
            for (int i=0; i<DATA_LEN; ++i) msg_272_for_secc[i] = link_cw[i] & 1u;
        }

        // 12) S-ECC: SEC-DED(Hsiao)
        int result_secc = NE;
        error_correction_secc(&result_secc, msg_272_for_secc);

        if ((result_secc == NE || result_secc == CE) && any_one_bits(msg_272_for_secc, DATA_LEN) && (res_oecc == CE || res_oecc == NE || res_oecc == SDC))
            result_secc = SDC;

        if      (result_secc == NE)  ++SECC_NE;
        else if (result_secc == CE)  ++SECC_CE;
        else if (result_secc == DUE) ++SECC_DUE;
        else if (result_secc == SDC) ++SECC_SDC;

        // 13) Final TOT 
        int final_tot = ((link1_detected || link2_detected) ? CE : NE);

        if (res_oecc == DUE) { //SEV
            final_tot = DUE; 
        } else {
            if (result_secc == SDC) {
                final_tot = SDC;
            } else if (result_secc == DUE) {
                final_tot = DUE;
            } else if (result_secc == CE) {
                final_tot = CE;
            } else {
                if      (res_oecc == SDC) final_tot = SDC;
                else if (res_oecc == DUE) final_tot = DUE;
                else if (res_oecc == CE ) final_tot = CE;
                else {
                    final_tot = ((link1_detected || link2_detected) ? CE : NE);
                }
            }
        }

        if      (final_tot == NE ) ++TOT_NE;
        else if (final_tot == CE ) ++TOT_CE;
        else if (final_tot == DUE) ++TOT_DUE;
        else if (final_tot == SDC) ++TOT_SDC;
    }

    // Final reports
    fprintf(fp, "\n=====LINK1_count=========\n");
    fprintf(fp, "Runtime: %d\n", RUN_NUM);
    fprintf(fp, "NDET: %d\n", LINK1_PASS);
    fprintf(fp, "DET : %d\n", LINK1_DET);
    fprintf(fp, "=========================\n");
    fflush(fp);

    fprintf(fp, "\n=====OECC_count==========\n");
    fprintf(fp, "Runtime: %d\n", RUN_NUM);
    fprintf(fp, "NE : %d\n",  OECC_NE);
    fprintf(fp, "CE : %d\n",  OECC_CE);
    fprintf(fp, "DUE: %d\n",  OECC_DUE);
    fprintf(fp, "SDC: %d\n",  OECC_SDC);
    fprintf(fp, "=========================\n");
    fflush(fp);

    fprintf(fp, "\n=====LINK2_count=========\n");
    fprintf(fp, "Runtime: %d\n", RUN_NUM);
    fprintf(fp, "NDET: %d\n", LINK2_PASS);
    fprintf(fp, "DET : %d\n", LINK2_DET);
    fprintf(fp, "=========================\n");
    fflush(fp);

    fprintf(fp, "\n=====SECC_count==========\n");
    fprintf(fp, "Runtime: %d\n", RUN_NUM);
    fprintf(fp, "NE : %d\n",  SECC_NE);
    fprintf(fp, "CE : %d\n",  SECC_CE);
    fprintf(fp, "DUE: %d\n",  SECC_DUE);
    fprintf(fp, "SDC: %d\n",  SECC_SDC);
    fprintf(fp, "=========================\n");
    fflush(fp);

    fprintf(fp, "\n=====Total_count=========\n");
    fprintf(fp, "Runtime: %d\n", RUN_NUM);
    fprintf(fp, "NE : %d\n",  TOT_NE);
    fprintf(fp, "CE : %d\n",  TOT_CE);
    fprintf(fp, "DUE: %d\n",  TOT_DUE);
    fprintf(fp, "SDC: %d\n",  TOT_SDC);
    fprintf(fp, "Total : %d\n", TOT_NE + TOT_CE + TOT_DUE + TOT_SDC);
    fprintf(fp, "=========================\n");
    fflush(fp);

    // Rates
    double denom = (RUN_NUM>0) ? (double)RUN_NUM : 1.0;
    fprintf(fp, "\n=====Final_Rates_(%% over Runs)=====\n");
    fprintf(fp, "LINK1: PASS=%.7f DET=%.7f\n",
            100.0*LINK1_PASS/denom, 100.0*LINK1_DET/denom);
    fprintf(fp, "OECC : NE=%.7f CE=%.7f DUE=%.7f SDC=%.7f\n",
            100.0*OECC_NE/denom, 100.0*OECC_CE/denom, 100.0*OECC_DUE/denom, 100.0*OECC_SDC/denom);
    fprintf(fp, "LINK2: PASS=%.7f DET=%.7f\n",
            100.0*LINK2_PASS/denom, 100.0*LINK2_DET/denom);
    fprintf(fp, "SECC : NE=%.7f CE=%.7f DUE=%.7f SDC=%.7f\n",
            100.0*SECC_NE/denom, 100.0*SECC_CE/denom, 100.0*SECC_DUE/denom, 100.0*SECC_SDC/denom);
    fprintf(fp, "TOT  : NE=%.7f CE=%.7f DUE=%.7f SDC=%.7f\n",
            100.0*TOT_NE/denom, 100.0*TOT_CE/denom, 100.0*TOT_DUE/denom, 100.0*TOT_SDC/denom);
    fprintf(fp, "===================================\n");
    fflush(fp);

    fclose(fp);
    return 0;
}

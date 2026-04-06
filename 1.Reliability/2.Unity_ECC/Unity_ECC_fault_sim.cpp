#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <iostream>
#include <vector>
#include <set>
#include <algorithm>
#include <cstdint>

using namespace std;

// ----------------------------------------------------------------------------
// Configuration
// ----------------------------------------------------------------------------
#define SYMBOL_SIZE        16
#define SECC_CW_SYMBOL     18
#define SECC_CW_LEN        288

// simulation runs
#define RUN_NUM 10000000

// ----------------------------------------------------------------------------
// Fault type enums
// ----------------------------------------------------------------------------
enum STORAGE_FAULT_TYPE {NE_O = 0, SE   = 1, SE_SE = 2, SWL_16E = 3, SWD_32E = 4};
enum LINK_FAULT_TYPE    {NE_L = 0, SE_L = 1, DQS   = 2, DQ  = 3};
enum PERI_FAULT_TYPE    {NE_P = 0, SE_P = 1, DE_P  = 2};
enum RESULT_TYPE        {NE   = 0, CE   = 1, DUE   = 2, SDC = 3};

// ----------------------------------------------------------------------------
// Fault type assignment
// ----------------------------------------------------------------------------
void rs_wr_fault_type_assignment(
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
    // PERI2
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

// ------------------------------------------------------------------------------------
// Storage error injection
// ------------------------------------------------------------------------------------
void error_injection_SE(unsigned int codeword[SECC_CW_LEN]) {
    int Fault_pos = rand() % SECC_CW_LEN; 
    codeword[Fault_pos] ^= 1;
}

void error_injection_SE_SE(unsigned int codeword[SECC_CW_LEN]) {
    int Fault_pos1 = rand() % SECC_CW_LEN;
    int Fault_pos2; do { Fault_pos2 = rand() % SECC_CW_LEN; } while (Fault_pos2 == Fault_pos1);
    codeword[Fault_pos1] ^= 1; codeword[Fault_pos2] ^= 1;
}

// Subwordline 16b burst
void error_injection_SWL_16E(unsigned int codeword[SECC_CW_LEN]) {
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
void error_injection_SWD_32E(unsigned int codeword[SECC_CW_LEN]) {
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
static inline void peri_error_injection_SE(unsigned int codeword[SECC_CW_LEN]) {
    int p1 = rand() % SECC_CW_LEN;
    codeword[p1] ^= 1u;
}

static inline void peri_error_injection_DE(unsigned int codeword[SECC_CW_LEN]) {
    int p1 = rand() % SECC_CW_LEN;
    int p2; do { p2 = rand() % SECC_CW_LEN; } while (p2==p1);
    codeword[p1] ^= 1u; codeword[p2] ^= 1u;
}

// ------------------------------------------------------------------------------------
// Link error injection
// ------------------------------------------------------------------------------------
void error_injection_Link_SE(unsigned int codeword[SECC_CW_LEN]) {
    int Fault_pos = rand() % SECC_CW_LEN; 
    codeword[Fault_pos] ^= 1;
}

// DQSE
void error_injection_Link_DQS(unsigned int codeword[SECC_CW_LEN]) {
    int lane = rand() % 8;   
    while (1) {
        int cnt = 0;
        uint64_t mask = 0;   

        for (int s = 0; s < 36; ++s) {
            unsigned int flip = rand() & 1u;
            mask |= (flip << s);   
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

// DQE
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
// ------------------------------------------------------------------------------------
// SDC check (baseline all-zero)
// ------------------------------------------------------------------------------------
int SDC_check(const unsigned int cw[SECC_CW_LEN]) {
    for (int i=0;i<SECC_CW_LEN;++i) if (cw[i]) return 1;
    return 0;
}

// ============================================================================
// GF(2^16) with primitive polynomial 0x1100B
// ============================================================================
static const uint32_t GF_POLY_16 = 0x1100B;       // x^16 + x^12 + x^3 + x + 1
static const int      GF_M       = 16;
static const int      GF_SIZE    = (1 << GF_M);   // 65536
static const int      GF_ORDER   = GF_SIZE - 1;   // 65535
static const uint16_t GF_ZERO_SENT = (uint16_t)GF_ORDER;

static uint16_t gf_exp[2*GF_ORDER];
static uint16_t gf_log[GF_SIZE];

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
static inline uint16_t gf_pow_alpha(int i) {
    i%=GF_ORDER; if(i<0) i+=GF_ORDER; return gf_exp[i];
}
static inline uint16_t gf_mul(uint16_t a, uint16_t b) {
    if (!a || !b) return 0; return gf_exp[(gf_log[a]+gf_log[b])%GF_ORDER];
}
static inline uint16_t gf_div(uint16_t a, uint16_t b) {
    if (!a) return 0; if (!b) return 0;
    int idx = (int)gf_log[a] - (int)gf_log[b];
    idx%=GF_ORDER; if(idx<0) idx+=GF_ORDER;
    return gf_exp[idx];
}

// ----------------------------------------------------------------------------
// Bit/Symbol helpers
// ----------------------------------------------------------------------------
static inline uint16_t load_symbol16(const unsigned int *bits, int base) {
    uint16_t v=0; for(int b=0;b<16;++b) v|=((bits[base+b]&1u)<<(15-b)); return v;
}
static inline void store_symbol16(unsigned int *bits, int base, uint16_t val) {
    for(int b=0;b<16;++b){ unsigned bit=(val>>(15-b))&1u; bits[base+b]=bit; }
}


static uint16_t H_Matrix_SSC_DEC[2][SECC_CW_SYMBOL]; // row=0..1, col=0..N-1

// DEC table: syn = S0 | (S1<<16)
static uint32_t DEC_SYNDROME[SECC_CW_SYMBOL][SECC_CW_SYMBOL][16][16];

static inline void secc_build_DEC_table() {
    // init zero
    for (int i=0;i<SECC_CW_SYMBOL;++i)
        for (int j=0;j<SECC_CW_SYMBOL;++j)
            for (int n=0;n<16;++n)
                for (int m=0;m<16;++m)
                    DEC_SYNDROME[i][j][n][m]=0;

    // i<j만 유효
    for (int i=0;i<SECC_CW_SYMBOL;++i) {
        for (int j=i+1;j<SECC_CW_SYMBOL;++j) {
            for (int n=0;n<16;++n) {
                for (int m=0;m<16;++m) {
                    uint16_t S0=0, S1=0;
                    if (H_Matrix_SSC_DEC[0][i]!=GF_ZERO_SENT) S0^=gf_pow_alpha((int)H_Matrix_SSC_DEC[0][i]+n);
                    if (H_Matrix_SSC_DEC[1][i]!=GF_ZERO_SENT) S1^=gf_pow_alpha((int)H_Matrix_SSC_DEC[1][i]+n);
                    if (H_Matrix_SSC_DEC[0][j]!=GF_ZERO_SENT) S0^=gf_pow_alpha((int)H_Matrix_SSC_DEC[0][j]+m);
                    if (H_Matrix_SSC_DEC[1][j]!=GF_ZERO_SENT) S1^=gf_pow_alpha((int)H_Matrix_SSC_DEC[1][j]+m);
                    DEC_SYNDROME[i][j][n][m] = (uint32_t)S0 | ((uint32_t)S1<<16);
                }
            }
        }
    }
}
static inline void secc_init_tables() {
    gf_init();
    secc_build_DEC_table();
}

// Compute S0,S1
static inline void secc_compute_syndrome(const unsigned int cw[SECC_CW_LEN], uint16_t &S0, uint16_t &S1) {
    S0=0; S1=0;
    for (int j=0;j<SECC_CW_SYMBOL;++j) {
        uint16_t r = load_symbol16(cw, j*16);
        if (!r) continue;
        uint16_t e = gf_log[r]; // exponent of r
        if (H_Matrix_SSC_DEC[0][j]!=GF_ZERO_SENT) S0 ^= gf_pow_alpha((int)H_Matrix_SSC_DEC[0][j]+(int)e);
        if (H_Matrix_SSC_DEC[1][j]!=GF_ZERO_SENT) S1 ^= gf_pow_alpha((int)H_Matrix_SSC_DEC[1][j]+(int)e);
    }
}

// SSC path
static inline RESULT_TYPE secc_try_ssc(unsigned int cw[SECC_CW_LEN]) {
    uint16_t S0,S1; secc_compute_syndrome(cw,S0,S1);
    if (S0==0 && S1==0) return NE;

    if (S0!=0 && S1!=0) {
        int p=gf_log[S0], q=gf_log[S1];
        int diff=q-p; diff%=GF_ORDER; if(diff<0) diff+=GF_ORDER;

        int j_found=-1;
        for (int j=0;j<SECC_CW_SYMBOL;++j) {
            if (H_Matrix_SSC_DEC[0][j]==GF_ZERO_SENT || H_Matrix_SSC_DEC[1][j]==GF_ZERO_SENT) continue;
            int d = (int)H_Matrix_SSC_DEC[1][j] - (int)H_Matrix_SSC_DEC[0][j];
            d%=GF_ORDER; if(d<0) d+=GF_ORDER;
            if (d==diff){ j_found=j; break; }
        }
        if (j_found>=0){
            int eexp = p - (int)H_Matrix_SSC_DEC[0][j_found]; eexp%=GF_ORDER; if(eexp<0) eexp+=GF_ORDER;
            uint16_t e = gf_pow_alpha(eexp);
            uint16_t rj=load_symbol16(cw,j_found*16); rj^=e; store_symbol16(cw,j_found*16,rj);
            secc_compute_syndrome(cw,S0,S1);
            return (S0|S1)? DUE : CE;
        }
        return DUE;
    }

    if (S0!=0 && S1==0) {
        int p=gf_log[S0]; int j_found=-1;
        for (int j=0;j<SECC_CW_SYMBOL;++j) {
            if (H_Matrix_SSC_DEC[1][j]==GF_ZERO_SENT && H_Matrix_SSC_DEC[0][j]!=GF_ZERO_SENT) { j_found=j; break; }
        }
        if (j_found>=0){
            int eexp=p-(int)H_Matrix_SSC_DEC[0][j_found]; eexp%=GF_ORDER; if(eexp<0) eexp+=GF_ORDER;
            uint16_t e=gf_pow_alpha(eexp);
            uint16_t rj=load_symbol16(cw,j_found*16); rj^=e; store_symbol16(cw,j_found*16,rj);
            secc_compute_syndrome(cw,S0,S1);
            return (S0|S1)? DUE : CE;
        }
        return DUE;
    }

    if (S0==0 && S1!=0) {
        int q=gf_log[S1]; int j_found=-1;
        for (int j=0;j<SECC_CW_SYMBOL;++j) {
            if (H_Matrix_SSC_DEC[0][j]==GF_ZERO_SENT && H_Matrix_SSC_DEC[1][j]!=GF_ZERO_SENT) { j_found=j; break; }
        }
        if (j_found>=0){
            int eexp=q-(int)H_Matrix_SSC_DEC[1][j_found]; eexp%=GF_ORDER; if(eexp<0) eexp+=GF_ORDER;
            uint16_t e=gf_pow_alpha(eexp);
            uint16_t rj=load_symbol16(cw,j_found*16); rj^=e; store_symbol16(cw,j_found*16,rj);
            uint16_t _S0,_S1; secc_compute_syndrome(cw,_S0,_S1);
            return (_S0|_S1)? DUE : CE;
        }
        return DUE;
    }
    return DUE;
}

// DEC path (bit-error model with precomputed table)
static inline RESULT_TYPE secc_try_dec(unsigned int cw[SECC_CW_LEN]) {
    uint16_t S0,S1; secc_compute_syndrome(cw,S0,S1);
    if (S0==0 && S1==0) return NE;
    uint32_t syn = (uint32_t)S0 | ((uint32_t)S1<<16);

    for (int i=0;i<SECC_CW_SYMBOL;++i) {
        for (int j=i+1;j<SECC_CW_SYMBOL;++j) {
            for (int n=0;n<16;++n) {
                for (int m=0;m<16;++m) {
                    if (DEC_SYNDROME[i][j][n][m]==syn) {
                        // toggle bit (MSB-first): position = 15-n, 15-m
                        cw[i*16 + (15-n)] ^= 1u;
                        cw[j*16 + (15-m)] ^= 1u;
                        uint16_t _S0,_S1; secc_compute_syndrome(cw,_S0,_S1);
                        return (_S0|_S1)? DUE : CE;
                    }
                }
            }
        }
    }
    return DUE;
}

// Top-level S-ECC
static inline void secc_decode_apply(int *result_type, unsigned int cw[SECC_CW_LEN]) {
    RESULT_TYPE r = secc_try_ssc(cw);
    if (r==NE || r==CE) { *result_type=r; return; }
    r = secc_try_dec(cw);
    *result_type = r;
}

// ====================================================================================
// Main
// ====================================================================================
int main(int argc, char* argv[]) {
    if (argc < 5) {
        fprintf(stderr, "Usage: %s <LINK1_FAULT> <STOR_FAULT> <PERI_FAULT> <LINK2_FAULT>\n", argv[0]);
        fprintf(stderr, "       LINK*_FAULT: 0=NE_L, 1=SE_L, 2=DQS,   3=DQ\n");
        fprintf(stderr, "       PERI*_FAULT: 0=NE_P, 1=SE_P, 2=DE_P\n");
        fprintf(stderr, "       STOR_FAULT : 0=NE_O, 1=SE,   2=SE_SE, 3=SWL_16E,  4=SWD_32E\n");
        return 1;
    }

    string L1_STR="X", STOR_STR="X", P_STR="X", L2_STR="X";
    int link1_fault_type=NE_L, storage_fault_type=NE_O, peri_fault_type=NE_P, link2_fault_type=NE_L;

    rs_wr_fault_type_assignment(
        L1_STR, STOR_STR, P_STR, L2_STR,
        &link1_fault_type, &storage_fault_type, &peri_fault_type, &link2_fault_type,
        atoi(argv[1]), atoi(argv[2]), atoi(argv[3]), atoi(argv[4])
    );

    // Output file
    string Result_file_name = "Result/Unity_ECC_" + L1_STR + "_" + STOR_STR + "_" + P_STR + "_" + L2_STR + ".S";
    FILE *fp = fopen(Result_file_name.c_str(), "w");
    if (!fp) { fprintf(stderr,"[ERR] Cannot open result file\n"); return 1; }

    // -------- GF & H init --------
    gf_init();

    // H_Matrix_SSC_DEC
    for (int j=0;j<SECC_CW_SYMBOL;++j){ H_Matrix_SSC_DEC[0][j]=GF_ZERO_SENT; H_Matrix_SSC_DEC[1][j]=GF_ZERO_SENT; }

    if (SECC_CW_SYMBOL>=10) {
        H_Matrix_SSC_DEC[0][0]=16;              H_Matrix_SSC_DEC[1][0]=32;
        H_Matrix_SSC_DEC[0][1]=32;              H_Matrix_SSC_DEC[1][1]=64;
        H_Matrix_SSC_DEC[0][2]=48;              H_Matrix_SSC_DEC[1][2]=96;
        H_Matrix_SSC_DEC[0][3]=64;              H_Matrix_SSC_DEC[1][3]=128;
        H_Matrix_SSC_DEC[0][4]=80;              H_Matrix_SSC_DEC[1][4]=160;
        H_Matrix_SSC_DEC[0][5]=96;              H_Matrix_SSC_DEC[1][5]=192;
        H_Matrix_SSC_DEC[0][6]=112;             H_Matrix_SSC_DEC[1][6]=224;
        H_Matrix_SSC_DEC[0][7]=128;             H_Matrix_SSC_DEC[1][7]=256;
        H_Matrix_SSC_DEC[0][8]=144;             H_Matrix_SSC_DEC[1][8]=288;
        H_Matrix_SSC_DEC[0][9]=160;             H_Matrix_SSC_DEC[1][9]=320;
        H_Matrix_SSC_DEC[0][10]=176;            H_Matrix_SSC_DEC[1][10]=352;
        H_Matrix_SSC_DEC[0][11]=192;            H_Matrix_SSC_DEC[1][11]=384;
        H_Matrix_SSC_DEC[0][12]=208;            H_Matrix_SSC_DEC[1][12]=416;
        H_Matrix_SSC_DEC[0][13]=224;            H_Matrix_SSC_DEC[1][13]=448;
        H_Matrix_SSC_DEC[0][14]=240;            H_Matrix_SSC_DEC[1][14]=480;
        H_Matrix_SSC_DEC[0][15]=256;            H_Matrix_SSC_DEC[1][15]=512;
        H_Matrix_SSC_DEC[0][16]=0;              H_Matrix_SSC_DEC[1][16]=GF_ZERO_SENT; // (a^0, 0)
        H_Matrix_SSC_DEC[0][17]=GF_ZERO_SENT;   H_Matrix_SSC_DEC[1][17]=0;   // (0, a^0)
    }

    // DEC 테이블 생성
    secc_build_DEC_table();

    // Counters
    int SECC_NE=0, SECC_CE=0, SECC_DUE=0, SECC_SDC=0;

    // Work buffer
    unsigned int codeword[SECC_CW_LEN];
    srand((unsigned int)time(NULL));

    for (int runtime=0; runtime<RUN_NUM; ++runtime) {
        if (runtime % 1000000 == 0) {
            fprintf(fp, "\n===============\n");
            fprintf(fp, "Runtime : %d/%d\n", runtime, RUN_NUM);
            fprintf(fp, "SECC: NE=%d CE=%d DUE=%d SDC=%d\n", SECC_NE, SECC_CE, SECC_DUE, SECC_SDC);
            fprintf(fp, "===============\n");
            fflush(fp);
        }

        // 1) Init all-zero
        for (int i=0;i<SECC_CW_LEN;++i) codeword[i]=0;

        // 2) Link1 fault
        switch (link1_fault_type) {
            case NE_L: break;
            case SE_L: error_injection_Link_SE(codeword); break;
            case DQS:  error_injection_Link_DQS(codeword); break;
            case DQ:   error_injection_Link_DQ(codeword); break;
        }

        // 4) Storage fault (payload-only, functions kept as-is)
        switch (storage_fault_type) {
            case NE_O: break;
            case SE:       error_injection_SE(codeword);      break;
            case SE_SE:    error_injection_SE_SE(codeword);   break;
            case SWL_16E:  error_injection_SWL_16E(codeword); break;
            case SWD_32E:  error_injection_SWD_32E(codeword); break;
        }

        // 5) Peri2 fault
        switch (peri_fault_type) {
            case NE_P: break;
            case SE_P: peri_error_injection_SE(codeword); break;
            case DE_P: peri_error_injection_DE(codeword); break;
        }

        // 6) Link2 fault
        switch (link2_fault_type) {
            case NE_L:                                     break;
            case SE_L: error_injection_Link_SE(codeword);  break;
            case DQS:  error_injection_Link_DQS(codeword); break;
            case DQ:   error_injection_Link_DQ(codeword);  break;
        }

        // 7) S-ECC (SSC + DEC)
        int result_type_secc;
        secc_decode_apply(&result_type_secc, codeword);

        // SDC check (baseline=0)
        if (result_type_secc==NE || result_type_secc==CE) {
            if (SDC_check(codeword)) result_type_secc = SDC;
        }

        // Count
        if      (result_type_secc==NE)  ++SECC_NE;
        else if (result_type_secc==CE)  ++SECC_CE;
        else if (result_type_secc==DUE) ++SECC_DUE;
        else if (result_type_secc==SDC) ++SECC_SDC;
    }

    // Final report
    fprintf(fp,"\n=====SECC_count==========\n");
    fprintf(fp,"Runtime: %d\n", RUN_NUM);
    fprintf(fp,"NE : %d\n",  SECC_NE);
    fprintf(fp,"CE : %d\n",  SECC_CE);
    fprintf(fp,"DUE: %d\n",  SECC_DUE);
    fprintf(fp,"SDC: %d\n",  SECC_SDC);
    fprintf(fp,"Total: %d\n", SECC_NE + SECC_CE + SECC_DUE + SECC_SDC);
    fprintf(fp,"=========================\n");
    fflush(fp);

    double denom = (RUN_NUM>0) ? (double)RUN_NUM : 1.0;
    fprintf(fp,"\n=====Total_Rates_(%%)=====\n");
    fprintf(fp,"NE = %.7f\n", 100.0*SECC_NE/denom);
    fprintf(fp,"CE = %.7f\n", 100.0*SECC_CE/denom);
    fprintf(fp,"DUE= %.7f\n", 100.0*SECC_DUE/denom);
    fprintf(fp,"SDC= %.7f\n", 100.0*SECC_SDC/denom);
    fprintf(fp,"=========================\n");
    fflush(fp);

    fclose(fp);
    return 0;
}

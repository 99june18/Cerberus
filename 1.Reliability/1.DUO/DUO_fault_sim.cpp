#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <iostream>
#include <vector>
#include <set>
#include <algorithm>
#include <math.h>
#include <unordered_map>
#include <unordered_set>
#include <cstdint>
#include <filesystem>

using namespace std;

// ----------------------------------------------------------------------------
// Symbol/length constants (RS(38,32), 48b redundancy)
// ----------------------------------------------------------------------------
#define SYMBOL_SIZE         8

#define SECC8_DATA_SYMBOL   32
#define SECC8_REDUN_SYMBOL   6
#define SECC8_CW_SYMBOL    (SECC8_DATA_SYMBOL + SECC8_REDUN_SYMBOL) // 38

#define SECC_DATA_LEN      (SECC8_DATA_SYMBOL * SYMBOL_SIZE)        // 256
#define SECC_REDUN_LEN     (SECC8_REDUN_SYMBOL * SYMBOL_SIZE)       // 48
#define SECC_CW_LEN        (SECC8_CW_SYMBOL * SYMBOL_SIZE)          // 304

#define RUN_NUM      10000000  // simulation runs

// ----------------------------------------------------------------------------
// Fault types
// ----------------------------------------------------------------------------
enum STORAGE_FAULT_TYPE {NE_O = 0, SE   = 1, SE_SE = 2, SWL_16E = 3, SWD_32E = 4};
enum LINK_FAULT_TYPE    {NE_L = 0, SE_L = 1, DQS   = 2, DQ  = 3};
enum PERI_FAULT_TYPE    {NE_P = 0, SE_P = 1, DE_P  = 2};
enum RESULT_TYPE        {NE   = 0, CE   = 1, DUE   = 2, SDC = 3};

// ----------------------------------------------------------------------------
// Fault type assignment for 5-arg write-path (file naming & enums)
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

        for (int s = 0; s < 38; ++s) {
            unsigned int flip = rand() & 1u;
            mask |= (flip << s);   
            cnt += flip;
        }

        if (cnt >= 1) {  
            for (int s = 0; s < 38; ++s) {
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
    int dq = rand() % 38;  
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
// SDC check
// ------------------------------------------------------------------------------------
int SDC_check(unsigned int codeword[SECC_CW_LEN]) {
    for (int pos = 0; pos < SECC_CW_LEN; ++pos) if (codeword[pos] == 1) return 1;
    return 0;
}

// ====================================================================================
// GF(2^8) (poly 0x11D) — exp/log
// ====================================================================================
static unsigned char gf8_exp[512];  
static unsigned char gf8_log[256];

static inline void gf8_init() {
    unsigned int x = 1u;
    for (int i = 0; i < 255; ++i) {
        unsigned char a = (unsigned char)(x & 0xFFu);
        gf8_exp[i] = a;
        gf8_log[a] = (unsigned char)i;

        x <<= 1u;
        if (x & 0x100u) x ^= 0x11Du;
        x &= 0xFFu;
    }
    for (int i = 255; i < 512; ++i) gf8_exp[i] = gf8_exp[i - 255];
    gf8_log[0] = 255;
}

static inline unsigned char gf8_mul(unsigned char a, unsigned char b) {
    if (a == 0 || b == 0) return 0;
    return gf8_exp[ gf8_log[a] + gf8_log[b] ];
}

static inline unsigned char gf8_div(unsigned char a, unsigned char b) {
    if (a == 0) return 0;
    if (b == 0) return 0;
    int la = gf8_log[a], lb = gf8_log[b];
    int idx = la - lb;
    idx %= 255; if (idx < 0) idx += 255;
    return gf8_exp[idx];
}

static inline unsigned char gf8_pow_alpha(int i) {
    i %= 255; if (i < 0) i += 255;
    return gf8_exp[i];
}

// ------------------------------------------------------------------------------------
// Bit/Symbol helpers
// ------------------------------------------------------------------------------------
static inline unsigned char load_symbol8(const unsigned int *bits, int base_bit /*symbol base*/) {
    unsigned char v = 0;
    for (int b = 0; b < 8; ++b) {
        v |= ((bits[base_bit + b] & 1u) << (7 - b));
    }
    return v;
}
static inline void store_symbol8(unsigned int *bits, int base_bit /*symbol base*/, unsigned char val) {
    for (int b = 0; b < 8; ++b) {
        unsigned int bit = (val >> (7 - b)) & 1u;
        bits[base_bit + b] = bit;
    }
}

static inline unsigned char gf8_poly_eval(const vector<unsigned char> &poly, unsigned char x) {
    unsigned char y = 0;
    for (int i = (int)poly.size() - 1; i >= 0; --i) {
        if (y != 0) y = gf8_mul(y, x);
        y ^= poly[i];
    }
    return y;
}

static inline unsigned char gf8_poly_eval_derivative(const vector<unsigned char> &lambda, unsigned char x) {
    unsigned char sum = 0;
    unsigned char xpow = 1; // x^(i-1), start with i=1 → x^0
    for (int i = 1; i < (int)lambda.size(); ++i) {
        if ((i & 1) == 1) { // odd degree only
            if (lambda[i]) sum ^= gf8_mul(lambda[i], xpow);
        }
        xpow = gf8_mul(xpow, x);
    }
    return sum;
}

// Compute 2t syndromes (t=3 → 6)
static inline void compute_syndromes_2t_TSC(const unsigned int *cw_bits, unsigned char *S /*len=6*/) {
    for (int j = 0; j < 6; ++j) S[j] = 0;
    for (int i = 0; i < SECC8_CW_SYMBOL; ++i) {
        int base = i * 8;
        unsigned char ri = load_symbol8(cw_bits, base);
        if (!ri) continue;
        for (int j = 1; j <= 6; ++j) {
            unsigned char a = gf8_pow_alpha(i * j);
            S[j-1] ^= gf8_mul(ri, a);
        }
    }
}

// Berlekamp–Massey over GF(2^8), error-only, up to 2t syndromes
static void berlekamp_massey_8(const vector<unsigned char> &S, vector<unsigned char> &lambda, int &L_out) {
    const int N = (int)S.size(); // 2t
    vector<unsigned char> C(N+1, 0), B(N+1, 0);
    C[0] = 1; B[0] = 1;
    int L = 0, m = 1;
    unsigned char b = 1;

    for (int n = 0; n < N; ++n) {
        unsigned char d = S[n];
        for (int i = 1; i <= L; ++i) d ^= gf8_mul(C[i], S[n - i]);

        if (d == 0) { m += 1; continue; }

        vector<unsigned char> T = C;
        unsigned char db = gf8_div(d, b);
        for (int i = 0; i <= N; ++i) {
            unsigned char bi = (i >= m) ? B[i - m] : 0;
            if (bi) C[i] ^= gf8_mul(db, bi);
        }

        if (2*L <= n) {
            L = n + 1 - L;
            B = T;
            b = d;
            m = 1;
        } else {
            m += 1;
        }
    }
    C.resize(L + 1);
    lambda = C;
    L_out = L;
}

// Ω(x) = (Λ(x) * S(x)) mod x^{2t}, S(x) = S1 + S2 x + ... + S_{2t} x^{2t-1}
static vector<unsigned char> compute_omega_TSC(const vector<unsigned char> &lambda, const vector<unsigned char> &S) {
    const int two_t = (int)S.size();
    vector<unsigned char> omega(two_t, 0);
    for (int i = 0; i < (int)lambda.size(); ++i) {
        if (lambda[i] == 0) continue;
        for (int j = 0; j < two_t; ++j) {
            int deg = i + j;
            if (deg >= two_t) break;
            omega[deg] ^= gf8_mul(lambda[i], S[j]);
        }
    }
    return omega;
}

// Chien search over 38 positions: roots of Λ(α^{-i})
static int chien_search_TSC(const vector<unsigned char> &lambda, vector<int> &error_pos) {
    error_pos.clear();
    for (int i = 0; i < SECC8_CW_SYMBOL; ++i) {
        int exp_idx = 255 - (i % 255);
        if (exp_idx == 255) exp_idx = 0;
        unsigned char x = gf8_exp[exp_idx];
        if (gf8_poly_eval(lambda, x) == 0) error_pos.push_back(i);
    }
    return (int)error_pos.size();
}

// ---- TSC decoder body (replaces the old DSC) ----
void secc_rs8_dsc_decode(int *result_type, unsigned int cw_bits[SECC_CW_LEN]) {
    // 1) Syndromes S1..S6
    unsigned char S_arr[6];
    compute_syndromes_2t_TSC(cw_bits, S_arr);
    bool all_zero = true;
    for (int j = 0; j < 6; ++j) if (S_arr[j] != 0) { all_zero = false; break; }
    if (all_zero) { *result_type = NE; return; }

    // 2) BM → Λ(x), degree L
    vector<unsigned char> S_vec(6);
    for (int i = 0; i < 6; ++i) S_vec[i] = S_arr[i];

    vector<unsigned char> lambda;
    int L = 0;
    berlekamp_massey_8(S_vec, lambda, L);
    if (L == 0 || L > 3) { *result_type = DUE; return; } // t=3

    // 3) Chien search
    vector<int> error_pos;
    int roots = chien_search_TSC(lambda, error_pos);
    if (roots != L) { *result_type = DUE; return; }

    // 4) Ω(x), Λ'(x), Forney magnitudes
    vector<unsigned char> omega = compute_omega_TSC(lambda, S_vec);

    for (int k = 0; k < (int)error_pos.size(); ++k) {
        int i = error_pos[k];

        int exp_idx = 255 - (i % 255);
        if (exp_idx == 255) exp_idx = 0;
        unsigned char x = gf8_exp[exp_idx];

        unsigned char omega_x = gf8_poly_eval(omega, x);
        unsigned char lambda_dx = gf8_poly_eval_derivative(lambda, x);
        if (lambda_dx == 0) { *result_type = DUE; return; }

        unsigned char e_i = gf8_div(omega_x, lambda_dx);

        int base = i * 8;
        unsigned char r = load_symbol8(cw_bits, base);
        r ^= e_i;
        store_symbol8(cw_bits, base, r);
    }

    // 5) Verify: recompute syndromes (must be all zero)
    compute_syndromes_2t_TSC(cw_bits, S_arr);
    all_zero = true;
    for (int j = 0; j < 6; ++j) if (S_arr[j] != 0) { all_zero = false; break; }
    *result_type = all_zero ? CE : DUE;
}

// ====================================================================================
// Main
// ====================================================================================
int main(int argc, char* argv[]) {
    if (argc < 5) {
        fprintf(stderr, "Usage: %s <LINK1_FAULT> <STOR_FAULT> <PERI_FAULT> <LINK2_FAULT>\n", argv[0]);
        fprintf(stderr, "       LINK*_FAULT: 0=NE_L, 1=SE_L, 2=DQS, 3=DQ\n");
        fprintf(stderr, "       PERI*_FAULT: 0=NE_P, 1=SE_P, 2=DE_P\n");
        fprintf(stderr, "       STOR_FAULT : 0=NE_O, 1=SE,   2=SE_SE,   3=SWL_16E,  4=SWD_32E\n");
        return 1;
    }

    // GF(2^8) init
    gf8_init();

    // Parse args
    string L1_STR="X", STOR_STR="X", P_STR="X", L2_STR="X";
    int link1_fault_type=NE_L, storage_fault_type=NE_O, peri_fault_type=NE_P, link2_fault_type=NE_L;

    rs_wr_fault_type_assignment(
        L1_STR, STOR_STR, P_STR, L2_STR,
        &link1_fault_type, &storage_fault_type, &peri_fault_type, &link2_fault_type,
        atoi(argv[1]), atoi(argv[2]), atoi(argv[3]), atoi(argv[4])
    );

    // Output file
    //std::filesystem::create_directories("single_result");
    string Result_file_name = "Result/DUO_" + L1_STR +  "_" + STOR_STR + "_" + P_STR + "_" + L2_STR + ".S";
    FILE *fp = fopen(Result_file_name.c_str(), "w");
    if (!fp) { fprintf(stderr,"[ERR] Cannot open result file\n"); return 1; }

    // Counters
    int SECC_NE=0, SECC_CE=0, SECC_DUE=0, SECC_SDC=0;

    // Work buffer
    unsigned int codeword[SECC_CW_LEN];

    srand((unsigned int)time(NULL));

    for (int runtime = 0; runtime < RUN_NUM; ++runtime) {
        if (runtime % 1000000 == 0) {
            fprintf(fp, "\n===============\n");
            fprintf(fp, "Runtime : %d/%d\n", runtime, RUN_NUM);
            fprintf(fp, "SECC: NE=%d CE=%d DUE=%d SDC=%d\n", SECC_NE, SECC_CE, SECC_DUE, SECC_SDC);
            fprintf(fp, "===============\n");
            fflush(fp);
        }

        // 1) Init codeword all-zero (304b)
        for (int i = 0; i < SECC_CW_LEN; ++i) codeword[i] = 0;

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

        // 7) S-ECC decode (RS(38,32), t=3 TSC)
        int result_type_secc;
        secc_rs8_dsc_decode(&result_type_secc, codeword);

        // Post-check for SDC (baseline payload=0)
        if (result_type_secc == NE || result_type_secc == CE) {
            if (SDC_check(codeword)) result_type_secc = SDC;
        }

        // Count
        if      (result_type_secc == NE)  ++SECC_NE;
        else if (result_type_secc == CE)  ++SECC_CE;
        else if (result_type_secc == DUE) ++SECC_DUE;
        else if (result_type_secc == SDC) ++SECC_SDC;
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

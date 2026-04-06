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

// --------------------------- Dimensions & Files ------------------------------
#define DATA_LEN            272
#define PAYLOAD_BITS        256
#define CRC_BITS            16
#define LINK_N              288    
#define OECC_N              288    
#define H_ROWS              16
#define RUN_NUM             10000000

#define F_G_LINK  "G_matrix_LINK.txt"
#define F_H_LINK  "H_matrix_LINK.txt"
#define F_G_OECC  "G_matrix_OECC.txt"
#define F_H_OECC  "H_matrix_OECC.txt"

// --------------------------- Enums / Results --------------------------------
enum STORAGE_FAULT_TYPE {NE_O = 0, SE   = 1, SE_SE = 2, SWL_16E = 3, SWD_32E = 4};
enum LINK_FAULT_TYPE    {NE_L = 0, SE_L = 1, DQS   = 2, DQ  = 3};
enum PERI_FAULT_TYPE    {NE_P = 0, SE_P = 1, DE_P  = 2};
enum RESULT_TYPE        {NE   = 0, CE   = 1, DUE   = 2, SDC = 3};


// --------------------------- Small utils ------------------------------------
static inline int any_one_bits(const unsigned int *arr, int nbits) {
    for (int i=0; i<nbits; ++i) if (arr[i] & 1u) return 1;
    return 0;
}

// --------------------------- Matrix storage ----------------------------------
static uint8_t G_LINK[DATA_LEN][LINK_N];
static uint8_t H_LINK[H_ROWS][LINK_N];

static uint8_t G_OECC[DATA_LEN][OECC_N];
static uint8_t H_OECC[H_ROWS][OECC_N];

static bool load_matrix_link(const char* fname, int rows, int cols, uint8_t M[][LINK_N]) {
    if (cols != LINK_N) return false;
    FILE* fh = fopen(fname, "r"); if (!fh) return false;
    for (int r=0; r<rows; ++r)
        for (int c=0; c<cols; ++c) {
            unsigned int v; if (fscanf(fh, "%u", &v) != 1) { fclose(fh); return false; }
            M[r][c] = (uint8_t)(v & 1u);
        }
    fclose(fh); return true;
}

static bool load_matrix_oecc(const char* fname, int rows, int cols, uint8_t M[][OECC_N]) {
    if (cols != OECC_N) return false;
    FILE* fh = fopen(fname, "r"); if (!fh) return false;
    for (int r=0; r<rows; ++r)
        for (int c=0; c<cols; ++c) {
            unsigned int v; if (fscanf(fh, "%u", &v) != 1) { fclose(fh); return false; }
            M[r][c] = (uint8_t)(v & 1u);
        }
    fclose(fh); return true;
}

// --------------------------- Encode --------------------------------------
static inline void encode_G_LINK(const unsigned int data272[DATA_LEN], unsigned int cwN[LINK_N], uint8_t G[][LINK_N]) {
    for (int c=0; c<LINK_N; ++c) {
        unsigned int acc = 0;
        for (int r=0; r<DATA_LEN; ++r) acc ^= ((G[r][c] & 1u) & (data272[r] & 1u));
        cwN[c] = acc & 1u;
    }
}
static inline void encode_G_OECC(const unsigned int data272[DATA_LEN], unsigned int cwN[OECC_N], uint8_t G[][OECC_N]) {
    for (int c=0; c<OECC_N; ++c) {
        unsigned int acc = 0;
        for (int r=0; r<DATA_LEN; ++r) acc ^= ((G[r][c] & 1u) & (data272[r] & 1u));
        cwN[c] = acc & 1u;
    }
}


static inline void syndrome_H_LINK(const unsigned int cwN[LINK_N], uint8_t H[][LINK_N], unsigned int syn_out[H_ROWS]) {
    for (int r=0; r<H_ROWS; ++r) {
        unsigned int acc=0;
        for (int c=0; c<LINK_N; ++c) acc ^= ((H[r][c] & 1u) & (cwN[c] & 1u));
        syn_out[r] = acc & 1u;
    }
}
static inline bool syn_all_zero16(const unsigned int syn[H_ROWS]) {
    for (int r=0; r<H_ROWS; ++r) if (syn[r]) return false;
    return true;
}

// ------------------------------------------------------------------------------------
// Peri error injection
// ------------------------------------------------------------------------------------
static inline void peri_error_injection_SE(unsigned int data272[DATA_LEN]) {
    int p1 = rand() % DATA_LEN;
    data272[p1] ^= 1u;
}
static inline void peri_error_injection_DE(unsigned int data272[DATA_LEN]) {
    int p1 = rand() % DATA_LEN;
    int p2; do { p2 = rand() % DATA_LEN; } while (p2==p1);
    data272[p1] ^= 1u; data272[p2] ^= 1u;
}

// ------------------------------------------------------------------------------------
// Link error injection
// ------------------------------------------------------------------------------------
void error_injection_Link_SE(unsigned int cw[LINK_N]) {
    int p1 = rand() % LINK_N;
    cw[p1] ^= 1u;
}

void error_injection_Link_DQ(unsigned int cw[LINK_N]) {
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
                    cw[idx] ^= 1u;
                }
            }
            break;
        }
    }
}

void error_injection_Link_DQS(unsigned int cw[LINK_N]) {
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
                    int idx = lane + s * 8;
                    cw[idx] ^= 1u;
                }
            }
            break;
        }
    }
}


// ------------------------------------------------------------------------------------
// Storage error injection
// ------------------------------------------------------------------------------------
void error_injection_SE(unsigned int cw[OECC_N]) {
    int p1 = rand() % OECC_N;
    cw[p1] ^= 1u;
}

void error_injection_SE_SE(unsigned int cw[OECC_N]) {
    int p1 = rand() % OECC_N;
    int p2; do { p2 = rand() % OECC_N; } while (p2==p1);
    cw[p1] ^= 1u; cw[p2] ^= 1u;
}

// Subwordline 16b burst
void error_injection_SWL_16E(unsigned int cw[OECC_N]) {
    int sym_idx = rand() % 18;
    while (1) {
        int cnt = 0;
        int base = sym_idx * 16;
        uint32_t mask = 0;
        for (int i=0; i<16; ++i) {
            unsigned int flip = rand() & 1u;
            mask |= (flip << (15 - i));
            cnt += flip;
        }
        if (cnt >= 1) {
            for (int i=0; i<16; ++i) {
                if ((mask >> (15 - i)) & 1u) cw[base + i] ^= 1u;
            }
            break;
        }
    }
}

// Subwordline driver 32b burst
void error_injection_SWD_32E(unsigned int cw[OECC_N]) {
    int blk = rand() % 9;      
    while (1) {
        int cnt = 0;
        int base = blk * 32;
        uint32_t mask = 0;
        for (int i=0; i<32; ++i) {
            unsigned int flip = rand() & 1u;
            mask |= (flip << (31 - i));
            cnt += flip;
        }
        if (cnt >= 1) {
            for (int i=0; i<32; ++i) {
                if ((mask >> (31 - i)) & 1u) cw[base + i] ^= 1u;
            }
            break;
        }
    }
}

// --------------------------- O-ECC SEC-DED (Hsiao) ---------------------------
static void oecc_sec_ded_decode (int *result_type, unsigned int cw[OECC_N]) {
    unsigned int syn[H_ROWS] = {0};

    // syndrome
    for (int r=0; r<H_ROWS; ++r) {
        unsigned int acc = 0;
        for (int c=0; c<OECC_N; ++c) acc ^= ((H_OECC[r][c] & 1u) & (cw[c] & 1u));
        syn[r] = acc & 1u;
    }

    // all-zero -> NE
    bool allz = true;
    for (int r=0; r<H_ROWS; ++r) if (syn[r]) { allz = false; break; }
    if (allz) { *result_type = NE; return; }

    // column match -> single-bit location
    for (int pos=0; pos<OECC_N; ++pos) {
        int cnt=0;
        for (int r=0; r<H_ROWS; ++r) {
            if ((int)syn[r] == (int)H_OECC[r][pos]) ++cnt; else break;
        }
        if (cnt == H_ROWS) {
            cw[pos] ^= 1u;   // correct
            *result_type = CE;
            return;
        }
    }

    // otherwise: multi-bit -> DUE
    *result_type = DUE;
}

// --------------------------- S-ECC CRC16 (detect-only) -----------------------
static inline uint16_t crc16_ccitt_bits(const unsigned int *bits, int nbits) {
    uint16_t crc = 0x0000;           // init
    const uint16_t POLY = 0x1021;    // x^16 + x^12 + x^5 + 1

    for (int i = 0; i < nbits; ++i) {
        uint8_t inbit = (uint8_t)(bits[i] & 1u);
        uint8_t msb   = (uint8_t)((crc >> 15) & 1u);
        crc <<= 1;
        crc &= 0xFFFF;
        if (msb ^ inbit) crc ^= POLY;
    }
    return crc;
}

static inline uint16_t load_crc16_from_data272(const unsigned int *data272) {
    uint16_t v = 0;
    for (int i = 0; i < CRC_BITS; ++i) {
        v = (uint16_t)((v << 1) | (data272[PAYLOAD_BITS + i] & 1u));
    }
    return v;
}

// --------------------------- Fault type naming -------------------------------
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

// --------------------------- Main --------------------------------------------
int main(int argc, char* argv[]) {
    if (argc < 5) {
        fprintf(stderr, "Usage: %s <LINK1_FAULT> <STOR_FAULT> <PERI_FAULT> <LINK2_FAULT>\n", argv[0]);
        fprintf(stderr, "       LINK*_FAULT: 0=NE_L, 1=SE_L, 2=DQS,   3=DQ\n");
        fprintf(stderr, "       PERI*_FAULT: 0=NE_P, 1=SE_P, 2=DE_P\n");
        fprintf(stderr, "       STOR_FAULT : 0=NE_O, 1=SE,   2=SE_SE, 3=SWL_16E,  4=SWD_32E\n");
        return 1;
    }

    // Load matrices
    if (!load_matrix_link(F_G_LINK, DATA_LEN, LINK_N, G_LINK)) {
        fprintf(stderr, "[ERR] Cannot open %s (need 272x288 of 0/1)\n", F_G_LINK); return 1;
    }
    if (!load_matrix_link(F_H_LINK, H_ROWS, LINK_N, H_LINK)) {
        fprintf(stderr, "[ERR] Cannot open %s (need 16x288 of 0/1)\n", F_H_LINK); return 1;
    }
    if (!load_matrix_oecc(F_G_OECC, DATA_LEN, OECC_N, G_OECC)) {
        fprintf(stderr, "[ERR] Cannot open %s (need 272x288 of 0/1)\n", F_G_OECC); return 1;
    }
    if (!load_matrix_oecc(F_H_OECC, H_ROWS, OECC_N, H_OECC)) {
        fprintf(stderr, "[ERR] Cannot open %s (need 16x288 of 0/1)\n", F_H_OECC); return 1;
    }

    // Parse fault types & prepare output
    string L1_STR="X", STOR_STR="X", P_STR="X", L2_STR="X";
    int link1_fault_type=NE_L, storage_fault_type=NE_O, peri_fault_type=NE_P, link2_fault_type=NE_L;
    fault_type_assignment_wr(
        L1_STR, STOR_STR, P_STR, L2_STR,
        &link1_fault_type, &storage_fault_type, &peri_fault_type, &link2_fault_type,
        atoi(argv[1]), atoi(argv[2]), atoi(argv[3]), atoi(argv[4])
    );

    string Result_file_name = "Result/LPDDR6_CRC16_" + L1_STR + "_" + STOR_STR + "_" + P_STR + "_" + L2_STR + ".S";
    FILE *fp = fopen(Result_file_name.c_str(), "w");
    if (!fp) { fprintf(stderr,"[ERR] Cannot open result file\n"); return 1; }

    // Counters
    int LINK1_PASS=0, LINK1_DET=0;
    int LINK2_PASS=0, LINK2_DET=0;

    int OECC_NE=0, OECC_CE=0, OECC_DUE=0, OECC_SDC=0;
    int SECC_NE=0, SECC_CE=0, SECC_DUE=0, SECC_SDC=0;

    int TOT_NE=0, TOT_CE=0, TOT_DUE=0, TOT_SDC=0;

    srand((unsigned int)time(NULL));

    // Working buffers
    unsigned int data_272[DATA_LEN];         
    unsigned int cw_link[LINK_N], cw_link_clean[LINK_N], cw_link_clean2[LINK_N];   
    unsigned int cw_oecc[OECC_N], cw_oecc_clean[OECC_N];                           

    for (int run=0; run<RUN_NUM; ++run) {
        if (run % 1000000 == 0) {
            fprintf(fp,"\n===============\n");
            fprintf(fp,"Runtime : %d/%d\n", run, RUN_NUM);
            fprintf(fp,"LINK1: PASS=%d DET=%d\n", LINK1_PASS, LINK1_DET);
            fprintf(fp,"OECC : NE=%d CE=%d DUE=%d SDC=%d\n", OECC_NE, OECC_CE, OECC_DUE, OECC_SDC);
            fprintf(fp,"LINK2: PASS=%d DET=%d\n", LINK2_PASS, LINK2_DET);
            fprintf(fp,"SECC(CRC16): NE=%d CE=%d DUE=%d SDC=%d\n", SECC_NE, SECC_CE, SECC_DUE, SECC_SDC);
            fprintf(fp,"TOT  : NE=%d CE=%d DUE=%d SDC=%d\n", TOT_NE, TOT_CE, TOT_DUE, TOT_SDC);
            fprintf(fp,"===============\n");
            fflush(fp);
        }

        // 1) init 272b = 0
        memset(data_272, 0, sizeof(unsigned int)*DATA_LEN);

        // 2) Link encode (G_LINK)
        encode_G_LINK(data_272, cw_link, G_LINK);
        for (int i = 0; i < LINK_N; i++) cw_link_clean[i] = cw_link[i];

        // 3) Link#1 error inject (on 288b)
        switch (link1_fault_type) {
            case NE_L: /* none */ break;
            case SE_L: error_injection_Link_SE(cw_link); break;
            case DQS : error_injection_Link_DQS(cw_link); break;
            case DQ  : error_injection_Link_DQ (cw_link); break;
            default  : break;
        }

        // 4) Link#1 detect by H_LINK
        unsigned int synL[H_ROWS];
        syndrome_H_LINK(cw_link, H_LINK, synL);
        int link1_detected = 0;
        if (!syn_all_zero16(synL)) {   // DET
            ++LINK1_DET; link1_detected = 1;
            for (int i=0; i<DATA_LEN; ++i) data_272[i] = cw_link_clean[i] & 1u;
        } else {                        // PASS
            ++LINK1_PASS;
            for (int i=0; i<DATA_LEN; ++i) data_272[i] = cw_link[i] & 1u;
        }

        // 5) O-ECC encode (G_OECC)
        encode_G_OECC(data_272, cw_oecc, G_OECC);
        for (int i = 0; i < OECC_N; i++) cw_oecc_clean[i] = cw_oecc[i];

        // 6) Storage error on 288b
        switch (storage_fault_type) {
            case NE_O: break;
            case SE:       error_injection_SE(cw_oecc);      break;
            case SE_SE:    error_injection_SE_SE(cw_oecc);   break;
            case SWL_16E:  error_injection_SWL_16E(cw_oecc); break;
            case SWD_32E:  error_injection_SWD_32E(cw_oecc); break;
            default  :                                       break;
        }

        // 7) O-ECC SEC-DED decode
        int res_oecc = NE;
        oecc_sec_ded_decode(&res_oecc, cw_oecc);

        // SDC
        for (int i = 0; i < OECC_N; i++) {
            if ((cw_oecc[i] != cw_oecc_clean[i]) && (res_oecc == NE || res_oecc == CE)) {
                res_oecc = SDC;
                break;
            }
        }

        if      (res_oecc==NE)  ++OECC_NE;
        else if (res_oecc==CE)  ++OECC_CE;
        else if (res_oecc==DUE) ++OECC_DUE;
        else                    ++OECC_SDC;

        for (int i=0; i<DATA_LEN; ++i) data_272[i] = cw_oecc[i] & 1u;

        // 8) Peri error on 272b
        switch (peri_fault_type) {
            case NE_P: /* none */ break;
            case SE_P: peri_error_injection_SE(data_272); break;
            case DE_P: peri_error_injection_DE(data_272); break;
            default  : break;
        }

        // 9) Link encode
        encode_G_LINK(data_272, cw_link, G_LINK);
        
        for (int i = 0; i < LINK_N; i++) cw_link_clean2[i] = cw_link[i];

        // 10) Link#2 error inject
        switch (link2_fault_type) {
            case NE_L: /* none */ break;
            case SE_L: error_injection_Link_SE(cw_link); break;
            case DQS : error_injection_Link_DQS(cw_link); break;
            case DQ  : error_injection_Link_DQ (cw_link); break;
            default  : break;
        }

        // 11) Link#2 detect
        unsigned int synL2[H_ROWS];
        syndrome_H_LINK(cw_link, H_LINK, synL2);
        int link2_detected = 0;
        if (!syn_all_zero16(synL2)) {   
            ++LINK2_DET; link2_detected = 1;
            for (int i=0; i<DATA_LEN; ++i) data_272[i] = cw_link_clean2[i] & 1u;
        } else {                   
            ++LINK2_PASS;
            for (int i=0; i<DATA_LEN; ++i) data_272[i] = cw_link[i] & 1u;
        }

        // 12) S-ECC: CRC16
        int result_secc = NE;
        uint16_t crc_calc   = crc16_ccitt_bits(data_272, PAYLOAD_BITS);     
        uint16_t crc_stored = load_crc16_from_data272(data_272);           
        if (crc_calc != crc_stored) {
            result_secc = DUE;
        } else {
            if (any_one_bits(data_272, DATA_LEN)) result_secc = SDC;
            else result_secc = NE;
        }

        if      (result_secc == NE)  ++SECC_NE;
        else if (result_secc == CE)  ++SECC_CE;
        else if (result_secc == DUE) ++SECC_DUE;
        else if (result_secc == SDC) ++SECC_SDC;

        // 13) Final TOT
        int final_tot = ((link1_detected || link2_detected) ? CE : NE);

        if      (result_secc == SDC) final_tot = SDC;
        else if (result_secc == DUE) final_tot = DUE;
        else if (result_secc == CE ) final_tot = CE;
        else { // SECC == NE
            if      (res_oecc == SDC) final_tot = SDC;
            else if (res_oecc == DUE) final_tot = DUE;
            else if (res_oecc == CE ) final_tot = CE;
            else                      final_tot = ((link1_detected || link2_detected) ? CE : NE);
        }

        if      (final_tot == NE ) ++TOT_NE;
        else if (final_tot == CE ) ++TOT_CE;
        else if (final_tot == DUE) ++TOT_DUE;
        else if (final_tot == SDC) ++TOT_SDC;
    }

    // Reports
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

    fprintf(fp, "\n=====SECC(CRC16)_count===\n");
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
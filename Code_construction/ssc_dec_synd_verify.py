#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
import os
import sys
from time import time

# Usage: python3 ssc_dec_synd_verify.py

# ---------------------------
# Utility: pack a length-32 "column vector" into a 32-bit integer
# ---------------------------
def pack_col_32bits(bits32_col: np.ndarray) -> int:
    out = 0
    for r in range(32):
        if bits32_col[r]:
            out |= 1 << (31 - r)
    return out

# ---------------------------
# Utility: generate the XOR closure (non-empty subsets) for 16 32-bit integers
# ---------------------------
def xor_closure_u32(cols16_u32):
    assert len(cols16_u32) == 16
    size = 1 << 16  # 65536
    dp = [0] * size
    out = set()
    for mask in range(1, size):
        lsb = mask & -mask
        b = (lsb.bit_length() - 1)      # 0..15
        prev = mask ^ lsb
        dp[mask] = dp[prev] ^ cols16_u32[b]
        out.add(dp[mask])
    return out  # expected size: 65535


def gf2_rank(A: np.ndarray) -> int:
    A = (A.copy().astype(np.uint8) & 1)
    m, n = A.shape
    r = 0
    for c in range(n):
        pivot = r + np.argmax(A[r:, c])
        if A[pivot, c]:
            if pivot != r:
                A[[r, pivot]] = A[[pivot, r]]
            for i in range(m):
                if i != r and A[i, c]:
                    A[i] ^= A[r]
            r += 1
            if r == min(m, n):
                break
    return r

# ---------------------------
# Main checking routine (uses the full 32x288 hsecc, grouped into 16-column blocks)
# + Adds DEC checking (2-column XOR by selecting one column from each of two different blocks)
# ---------------------------
def check_ssc_disjoint_hsecc(hsecc_path: str,
                             save_each_block_syndrome: bool = False,
                             out_dir: str = "ssc_out"):
    """
    SSC:
      Split hsecc (32×288) into 18 blocks of 16 columns each.
      The number of such syndrome is 18*(2^16 - 1) = 1,179,630.
      For the 16 columns in each block (each column is a 32-bit vector),
      compute all non-empty XOR combinations (= 2^16 - 1 of them), and check whether
      1) all are unique and non-zero within the block (internal SSC condition)
      2) they are mutually disjoint across blocks

    DEC:
      Select one column from each of two different blocks and form a 2-column XOR syndrome.
      The number of such syndromes is C(288,2) - 18*C(16,2) = 39,168.
      Check whether they are 1) all unique, 2) non-zero, and 3) disjoint from the SSC global syndromes.
      After checking, merge DEC syndromes into global_set and print the final SSC+DEC union size.
    """
    if not os.path.isfile(hsecc_path):
        raise FileNotFoundError(f"Cannot find file: {hsecc_path}")

    H = np.loadtxt(hsecc_path, dtype=np.uint8) & 1
    if H.ndim != 2 or H.shape[0] != 32 or H.shape[1] != 288:
        raise ValueError(f"Invalid hsecc shape: expected (32, 288), got {H.shape}")

    m, n = H.shape  # 32, 288
    if n % 16 != 0:
        raise ValueError("The number of columns (288) must be a multiple of 16.")

    nblocks = n // 16  # 18
    t0 = time()
    global_set = set()
    ok_all_blocks_internal = True
    ok_all_blocks_disjoint = True

    if save_each_block_syndrome:
        os.makedirs(out_dir, exist_ok=True)

    # Pre-pack all columns into 32-bit integers (shared by SSC/DEC)
    cols_u32_all = [pack_col_32bits(H[:, j]) for j in range(n)]

    print("=== SSC check based on hsecc (16-column blocks, internal uniqueness + cross-block disjointness) ===")
    for blk in range(nblocks):
        c0 = blk * 16
        c1 = c0 + 16
        block_32 = H[:, c0:c1]               # (32,16)
        cols_u32 = cols_u32_all[c0:c1]       # length 16

        # print(block_32[0])
        # Build the XOR closure within the block
        synd = xor_closure_u32(cols_u32)     # expected size 65535
        size = len(synd)

        # Internal condition: all 2^16 - 1 are unique and non-zero
        internal_ok = (size == 65535) and (0 not in synd)

        # Check intersection with previous blocks
        inter = synd & global_set
        disjoint_ok = (len(inter) == 0)

        print(f"[Block {blk:2d}] closure size = {size:6d}  "
              f"internal uniqueness & non-zero = {'OK' if internal_ok else 'FAIL'}  "
              f"intersection with previous blocks = {len(inter):6d}  "
              f"disjoint = {'OK' if disjoint_ok else 'FAIL'}")

        # Extra: directly check whether rank=16 as well (warn if inconsistent)
        rank16_ok = (gf2_rank(block_32) == 16)
        if internal_ok != rank16_ok:
            print(f"[DEBUG] Block {blk}: closure check and direct rank check do not match!")

        if save_each_block_syndrome:
            with open(os.path.join(out_dir, f"hsecc_block_{blk:02d}_syndromes.txt"), "w") as f:
                for v in synd:
                    f.write(f"{v:08X}\n")

        ok_all_blocks_internal &= internal_ok
        ok_all_blocks_disjoint &= disjoint_ok

        # Merge into the global set (always accumulate at the end to avoid self-overlap counting)
        global_set |= synd
        print(f"Global syndrome count (accumulated / SSC): {len(global_set):,}")

    # SSC summary
    expected_ssc = nblocks * ((1 << 16) - 1)  # 18 * 65535 = 1,179,630
    print("------------------------------------------------------------")
    print(f"SSC global syndrome count (expected {expected_ssc:,}) = {len(global_set):,}")
    print(f"Block-internal uniqueness (all blocks): {'OK' if ok_all_blocks_internal else 'FAIL'}")
    print(f"Cross-block disjointness (all blocks): {'OK' if ok_all_blocks_disjoint else 'FAIL'}")

    # ============================================================
    # DEC check: 2-column XOR syndromes from different blocks
    # ============================================================
    print("\n=== DEC check (one column from each of two different blocks -> 2-column XOR) ===")

    # Total number of pairs: C(288,2) - 18*C(16,2) = 39,168
    total_pairs_all = n * (n - 1) // 2
    same_block_pairs = nblocks * (16 * 15 // 2)
    expected_dec = total_pairs_all - same_block_pairs  # 39,168

    dec_set = set()
    zero_cnt = 0

    for b1 in range(nblocks):
        s1, e1 = b1 * 16, b1 * 16 + 16
        for b2 in range(b1 + 1, nblocks):
            s2, e2 = b2 * 16, b2 * 16 + 16
            for j in range(s1, e1):
                vj = cols_u32_all[j]
                for k in range(s2, e2):
                    vk = cols_u32_all[k]
                    s = vj ^ vk
                    if s == 0:
                        zero_cnt += 1
                    dec_set.add(s)

    # Check uniqueness / non-zero / disjointness
    unique_ok = (len(dec_set) == expected_dec)
    nonzero_ok = (0 not in dec_set)
    inter_with_ssc = dec_set & global_set
    disjoint_ok_dec_ssc = (len(inter_with_ssc) == 0)

    print(f"DEC pair count (theoretical)        : {expected_dec:,}")
    print(f"Unique DEC syndrome count           : {len(dec_set):,} "
          f"(duplicate count = {expected_dec - len(dec_set):,})")
    print(f"Zero syndrome exists                : {'YES' if not nonzero_ok else 'NO'} "
          f"(zero occurrence count by pairs = {zero_cnt:,})")
    print(f"Intersection with SSC global set    : {len(inter_with_ssc):,} "
          f"-> {'Disjoint OK' if disjoint_ok_dec_ssc else 'Overlap detected'}")

    # Requested: also add DEC syndromes to the global set and print the final union size
    before_union = len(global_set)
    global_set |= dec_set
    final_total = len(global_set)
    expected_total_no_overlap = expected_ssc + expected_dec  # 1,218,798

    print("\n------------- Global syndrome union (SSC+DEC) --------------")
    print(f"SSC syndrome count                            : {before_union:,}")
    print(f"DEC syndrome count                            : {len(dec_set):,}")
    print(f"Union syndrome count (actual)                 : {final_total:,}")
    print(f"Union syndrome count (theoretical, no overlap): {expected_total_no_overlap:,}")
    if final_total < expected_total_no_overlap:
        print(f"NOTE: The result is smaller than expected due to overlap between SSC and DEC "
              f"(overlap count ≈ {expected_total_no_overlap - final_total:,})")

    t1 = time()
    print("------------------------------------------------------------")
    print(f"Total elapsed time: {t1 - t0:.3f} s")

    # Final pass/fail
    ssc_ok = ok_all_blocks_internal and ok_all_blocks_disjoint
    dec_ok = unique_ok and nonzero_ok and disjoint_ok_dec_ssc
    print(f"\nFinal result: SSC = {'OK' if ssc_ok else 'FAIL'}, DEC = {'OK' if dec_ok else 'FAIL'}")

    return ssc_ok and dec_ok

if __name__ == "__main__":
    hsecc_file = "Hsecc.txt" if len(sys.argv) < 2 else sys.argv[1]
    save_flag = False if len(sys.argv) < 3 else (sys.argv[2].lower() in ("1", "true", "yes", "y"))
    ok = check_ssc_disjoint_hsecc(hsecc_file, save_each_block_syndrome=save_flag)
    sys.exit(0 if ok else 1)

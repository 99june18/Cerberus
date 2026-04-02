#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import argparse
import numpy as np
import time

# GF(2) rank.
def gf2_rank(A):
    A = (A.copy() & 1).astype(np.uint8)
    m, n = A.shape
    r = 0; row = 0
    for col in range(n):
        pivot = None
        for i in range(row, m):
            if A[i, col]:
                pivot = i; break
        if pivot is None:
            continue
        if pivot != row:
            A[[row, pivot]] = A[[pivot, row]]
        for i in range(m):
            if i != row and A[i, col]:
                A[i, :] ^= A[row, :]
        row += 1; r += 1
        if row == m:
            break
    return r

# GF(2) RREF and pivots.
def gf2_rref(A):
    A = (A.copy() & 1).astype(np.uint8)
    m, n = A.shape
    row=0; pivots=[]
    for col in range(n):
        pivot=None
        for r in range(row,m):
            if A[r,col]:
                pivot=r; break
        if pivot is None: continue
        if pivot!=row: A[[row,pivot]] = A[[pivot,row]]
        for r in range(m):
            if r!=row and A[r,col]:
                A[r,:] ^= A[row,:]
        pivots.append(col); row+=1
        if row==m: break
    return A, pivots

# Basis of Null(A).
def nullspace_basis(A):
    R, piv = gf2_rref(A)
    m, n = A.shape
    piv_set=set(piv)
    free_cols=[j for j in range(n) if j not in piv_set]
    basis=[]
    for f in free_cols:
        x = np.zeros(n, dtype=np.uint8)
        x[f]=1
        for r, pc in enumerate(piv):
            if R[r,f]: x[pc] ^= 1
        basis.append(x)
    return basis

# GF(2^16) parameters.
N=16
IRR16 = (1<<16)|(1<<12)|(1<<3)|(1<<1)|1  # x^16 + x^12 + x^3 + x + 1

# GF(2^16) multiply with reduction.
def gf2n_mul(a,b,n=N,irr_poly=IRR16):
    res=0; x=a & ((1<<n)-1); y=b & ((1<<n)-1)
    for _ in range(n):
        if y & 1: res ^= x
        y >>= 1
        carry = x & (1<<(n-1))
        x = (x<<1) & ((1<<n)-1)
        if carry: x ^= (irr_poly & ((1<<n)-1))
    return res

# Multiplication-by-alpha as a binary matrix.
def gf2n_mult_matrix(alpha,n=N,irr_poly=IRR16):
    M = np.zeros((n,n), dtype=np.uint8)
    for i in range(n):
        e = 1<<i
        w = gf2n_mul(alpha, e, n, irr_poly)
        for r in range(n):
            M[r,i] = (w>>r) & 1
    return M

# Pack a 32-bit vector into an integer.
def pack32(v32):
    x=0
    for i in range(32):
        if v32[i]: x |= (1<<i)
    return x

# Unpack an integer into a 32-bit vector.
def unpack32(x):
    v = np.zeros(32, dtype=np.uint8)
    for i in range(32):
        if (x>>i)&1: v[i]=1
    return v

# Build top subspace generators GE.
def build_E_family(num_blocks):
    E=[]; alpha=1
    S_top=np.eye(N,8,dtype=np.uint8)
    tried=0
    while len(E)<num_blocks:
        tried+=1
        GE = (gf2n_mult_matrix(alpha,N,IRR16) @ S_top) & 1  # 16x8
        ok=True
        for H in E:
            if gf2_rank(np.concatenate([GE,H],axis=1))!=16:
                ok=False; break
        if ok:
            p = ((np.ones((1,16),dtype=np.uint8) @ GE) & 1).reshape(-1)
            if p.any(): E.append(GE)
        alpha=(alpha+1)&0xFFFF
        if alpha==0: alpha=1
        if tried>500000 and len(E)<num_blocks:
            raise RuntimeError("Failed to construct E_family")
    return E

# Build bottom subspace generators GZ.
def build_Z_family(num_blocks):
    Z=[]; beta=2
    S_bot=np.zeros((N,8),dtype=np.uint8)
    for j,c in enumerate(range(8,16)):
        S_bot[c,j]=1
    tried=0
    while len(Z)<num_blocks:
        tried+=1
        GZ = (gf2n_mult_matrix(beta,N,IRR16) @ S_bot) & 1  # 16x8
        ok=True
        for H in Z:
            if gf2_rank(np.concatenate([GZ,H],axis=1))!=16:
                ok=False; break
        if ok: Z.append(GZ)
        beta=(beta+1)&0xFFFF
        if beta==0: beta=1
        if tried>500000 and len(Z)<num_blocks:
            raise RuntimeError("Failed to construct Z_family")
    return Z

# Sample an invertible 8x8 matrix.
def random_GL8(rng):
    while True:
        R=rng.integers(0,2,size=(8,8),dtype=np.uint8)
        if gf2_rank(R)==8: return R

# Rank of the last L coefficient vectors.
def _rank_last_L_coeffs(seq_coeffs, L):
    if L <= 0: return 0
    M = np.stack(seq_coeffs[-L:], axis=1)  # 8 x L
    return gf2_rank(M)

# Search a length-16 CRC-valid coefficient sequence.
def find_crc8_coeff_sequence(GE, target_len=16, time_budget_ms=4000, seed=0):
    """Find a CRC-valid odd-weight coefficient sequence for one GE."""
    rng = np.random.default_rng(seed)
    pprime = ((GE.T @ np.ones((16,1), dtype=np.uint8)) & 1).reshape(-1)
    assert pprime.any()
    cand = []
    for x in range(1, 1<<8):
        vec = np.array([(x>>i)&1 for i in range(8)], dtype=np.uint8)
        if (int(pprime @ vec) % 2) == 1:
            cand.append(vec)
    rng.shuffle(cand)

    seq = []
    used = set()
    deadline = time.time() + (time_budget_ms/1000.0)

    def ok_with(v):
        seq_coeffs = seq + [v]
        m = len(seq_coeffs)
        lim = min(8, m)
        for L in range(1, lim+1):
            if _rank_last_L_coeffs(seq_coeffs, L) != L:
                return False
        return True

    def dfs():
        nonlocal seq, used
        if time.time() > deadline:
            return False
        if len(seq) == target_len:
            return True
        rng.shuffle(cand)
        for vec in cand:
            key = int(sum(int(vec[i])<<i for i in range(8)))
            if key in used: continue
            if ok_with(vec):
                used.add(key)
                seq.append(vec)
                if dfs(): return True
                seq.pop()
                used.remove(key)
        return False

    if dfs():
        return seq
    return None

# Build one block [E T; W Z].
def build_block_with_crc8(GE, GZ, rng, per_block_ms=4000, seed_for_crc=0):
    """Build one 32x16 block and its packed representations."""
    seq_coeffs = find_crc8_coeff_sequence(GE, target_len=16, time_budget_ms=per_block_ms, seed=seed_for_crc)
    if seq_coeffs is None:
        raise RuntimeError("Failed to construct CRC-8 coefficient sequence")

    top_cols = [ (GE @ x) & 1 for x in seq_coeffs ]  # list of 16 columns (each 16x1)
    E_top = np.stack(top_cols[:8], axis=1)   # 16x8
    T_top = np.stack(top_cols[8:], axis=1)   # 16x8

    Rz = random_GL8(rng)
    Zb = (GZ @ Rz) & 1
    for _ in range(8192):
        X = random_GL8(rng)
        EX = E_top ^ ((T_top @ X) & 1)
        if gf2_rank(EX) == 8:
            break
    else:
        raise RuntimeError("Failed to find a suitable X (EB rank 8 failed)")
    W = (Zb @ X) & 1

    block = np.zeros((32,16),dtype=np.uint8)
    cols_bits = []
    for j in range(16):
        block[:16, j] = top_cols[j]
        if j < 8:  block[16:, j] = W[:, j]
        else:      block[16:, j] = Zb[:, j-8]
        cols_bits.append(pack32(block[:, j]))
    assert gf2_rank(block) == 16

    Ubasis_bits=[]
    for j in range(8):
        v=np.zeros(32,dtype=np.uint8); v[:16]=GE[:,j]; Ubasis_bits.append(pack32(v))
    for j in range(8):
        v=np.zeros(32,dtype=np.uint8); v[16:]=Zb[:,j]; Ubasis_bits.append(pack32(v))

    return block, cols_bits, Ubasis_bits

# Build parity checks for U_b.
def parity_checks_from_Ubasis(Ubasis_bits):
    B = np.zeros((32,16), dtype=np.uint8)
    for j,packed in enumerate(Ubasis_bits):
        for i in range(32):
            if (packed>>i)&1: B[i,j]=1
    H = nullspace_basis(B.T)  # 16 rows
    return [pack32(h) for h in H]

# Evaluate DEC duplicates and single-space hits.
def eval_cross_two_metrics(cols_bits, H_rows):
    total_pairs=0; seen={}
    dup=0; hits=0
    hits_by_block=[0]*len(cols_bits)
    dup_by_block=[0]*len(cols_bits)
    for i in range(len(cols_bits)):
        for j in range(i+1,len(cols_bits)):
            ci=cols_bits[i]; cj=cols_bits[j]
            for a in range(16):
                for b in range(16):
                    total_pairs+=1
                    s=ci[a]^cj[b]
                    if s in seen:
                        dup+=1
                        (i0,j0,a0,b0)=seen[s]
                        dup_by_block[i]+=1; dup_by_block[j]+=1
                        dup_by_block[i0]+=1; dup_by_block[j0]+=1
                    else:
                        seen[s]=(i,j,a,b)
                    bad=False
                    for k in range(len(cols_bits)):
                        if k==i or k==j: continue
                        ok=True
                        for hr in H_rows[k]:
                            if (int(bin(hr & s).count("1")) & 1) != 0:
                                ok=False; break
                        if ok:
                            bad=True; break
                    if bad:
                        hits+=1
                        hits_by_block[i]+=1
                        hits_by_block[j]+=1
    return total_pairs, dup, hits, hits_by_block, dup_by_block

# Build all blocks and greedily reduce DEC collisions.
def build_matrices_with_twoEC_and_crc8(num_blocks=18, seed=0xC0FFEE,
                                       time_limit_sec=300, per_block_ms=4000):
    rng = np.random.default_rng(seed)
    E_list = build_E_family(num_blocks)
    Z_list = build_Z_family(num_blocks)

    blocks=[]; cols_bits=[]; Ubasis_bits=[]
    for b in range(num_blocks):
        Blk, Cb, Ub = build_block_with_crc8(E_list[b], Z_list[b], rng,
                                            per_block_ms=per_block_ms,
                                            seed_for_crc=seed + 100*b + 7)
        blocks.append(Blk); cols_bits.append(Cb); Ubasis_bits.append(Ub)

    H_rows = [parity_checks_from_Ubasis(Ub) for Ub in Ubasis_bits]
    total_pairs, dup, hits, hits_by_block, dup_by_block = eval_cross_two_metrics(cols_bits, H_rows)

    start = time.time()
    iters = 0

    while (hits>0 or dup>0) and (time.time()-start < time_limit_sec):
        iters += 1
        if hits>0:
            b = int(np.argmax(hits_by_block))
        else:
            b = int(np.argmax(dup_by_block))
        Blk, Cb, Ub = build_block_with_crc8(E_list[b], Z_list[b],
                                            np.random.default_rng(seed + 10000 + iters),
                                            per_block_ms=per_block_ms,
                                            seed_for_crc=seed ^ (0x9E37 + iters*17))
        cols_bits2 = list(cols_bits); cols_bits2[b]=Cb
        Ubasis_bits2 = list(Ubasis_bits); Ubasis_bits2[b]=Ub
        H_rows2 = [parity_checks_from_Ubasis(Ubb) for Ubb in Ubasis_bits2]
        total_pairs2, dup2, hits2, hits_by_block2, dup_by_block2 = eval_cross_two_metrics(cols_bits2, H_rows2)
        if (hits2 < hits) or (hits2 == hits and dup2 < dup):
            blocks[b] = Blk
            cols_bits = cols_bits2
            Ubasis_bits = Ubasis_bits2
            H_rows = H_rows2
            hits, dup = hits2, dup2
            hits_by_block, dup_by_block = hits_by_block2, dup_by_block2

    Hsecc = np.zeros((32, num_blocks*16), dtype=np.uint8)
    for b in range(num_blocks):
        Hsecc[:, 16*b:16*(b+1)] = np.stack([unpack32(x) for x in cols_bits[b]], axis=1)
    H2 = Hsecc[:16, :]

    stats = dict(total_pairs=total_pairs, dup=dup, hits=hits, iters=iters)
    return Hsecc, H2, Ubasis_bits, stats

# Verify CRC-n window ranks on H2.
def is_crc_n(H2, n):
    rows, cols = H2.shape
    for L in range(1, n+1):
        for s in range(0, cols - L + 1):
            if gf2_rank(H2[:, s:s+L]) != L:
                return False, (L, s)
    return True, None

# Check unique, nonzero, odd-weight H2 columns. (SEC-DED)
def verify_unique_nonzero_odd(H2):
    cols = [tuple(H2[:, j].tolist()) for j in range(H2.shape[1])]
    if len(set(cols)) != len(cols):
        return False, "duplicate columns"
    for j in range(H2.shape[1]):
        v = H2[:, j]
        if v.sum() == 0:
            return False, f"zero column at {j}"
        if (int(v.sum()) % 2) != 1:
            return False, f"even-weight column at {j}"
    return True, None

# Test whether v lies in span(basis_cols).
def in_span(basis_cols, v):
    if basis_cols.shape[1] == 0:
        return not np.any(v)
    M = np.concatenate([basis_cols, v.reshape(-1,1)], axis=1) & 1
    return gf2_rank(M) == gf2_rank(basis_cols)

# Verify bounded-fault separation across blocks.
def verify_bounded_fault(H2, block_size=16):
    B = H2.shape[1] // block_size
    for b in range(B):
        blk = H2[:, block_size*b:block_size*(b+1)]
        R, piv = gf2_rref(blk)
        basis_cols = blk[:, piv]
        for j in range(H2.shape[1]):
            if block_size*b <= j < block_size*(b+1):
                continue
            v = H2[:, j]
            if in_span(basis_cols, v):
                return False, (b, j)
    return True, None

# Verify SSC conditions on HSECC.
def verify_ssc(Hsecc, block_size=16):
    B = Hsecc.shape[1] // block_size
    for b in range(B):
        if gf2_rank(Hsecc[:, 16*b:16*(b+1)]) != 16:
            return False, f"Block rank !=16 at {b}"
    for i in range(B):
        for j in range(i+1, B):
            M = np.concatenate([Hsecc[:, 16*i:16*(i+1)],
                                Hsecc[:, 16*j:16*(j+1)]], axis=1)
            if gf2_rank(M) != 32:
                return False, f"Blocks {i},{j} not disjoint"
    return True, None

# Save a matrix as text.
def save_txt(M, path):
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    np.savetxt(path, M.astype(np.uint8), fmt="%d", delimiter=" ")

# CLI entry point.
def main():
    ap = argparse.ArgumentParser(description="Build HSECC/H2 with SSC + DEC + bounded fault + CRC-8 windows on H2.")
    ap.add_argument("--blocks", type=int, default=18)
    ap.add_argument("--seed", type=int, default=0x0)
    ap.add_argument("--time-limit-sec", type=int, default=600)
    ap.add_argument("--per-block-ms", type=int, default=4000, help="CRC-8 search time per block")
    ap.add_argument("--out-dir", type=str, default=".")
    ap.add_argument("--hs", "--hp", dest="hs", type=str, default="Hsecc.txt")
    ap.add_argument("--h2", type=str, default="H2.txt")
    ap.add_argument("--crc-n", type=int, default=8)
    args = ap.parse_args()

    if args.crc_n > 8:
        raise SystemExit("In the current structure (8-dimensional block top part), the maximum CRC-n is 8. Set --crc-n <= 8.")

    Hsecc, H2, Ubasis_bits, stats = build_matrices_with_twoEC_and_crc8(
        num_blocks=args.blocks, seed=args.seed,
        time_limit_sec=args.time_limit_sec, per_block_ms=args.per_block_ms
    )

    ok_ssc, where_ssc   = verify_ssc(Hsecc, block_size=16)
    ok_uo, where_uo     = verify_unique_nonzero_odd(H2)
    ok_bf, where_bf     = verify_bounded_fault(H2, block_size=16)
    ok_crc, where_crc   = is_crc_n(H2, n=args.crc_n)

    H_rows = [parity_checks_from_Ubasis(Ub) for Ub in Ubasis_bits]
    total_pairs, dup, hits, *_ = eval_cross_two_metrics(
        [ [pack32(Hsecc[:, 16*b + j]) for j in range(16)] for b in range(args.blocks) ],
        H_rows
    )

    if not (ok_ssc and ok_uo and ok_bf and ok_crc and dup==0 and hits==0):
        print("Verification failed:")
        print("  SSC :", ok_ssc, where_ssc)
        print("  U/O :", ok_uo,  where_uo)
        print("  B.F.:", ok_bf,  where_bf)
        print("  CRC :", ok_crc, where_crc)
        print("  DEC dup/hits:", dup, hits)
        raise SystemExit("Verification failed")

    hs_path = os.path.join(args.out_dir, args.hs)
    h2_path = os.path.join(args.out_dir, args.h2)
    save_txt(Hsecc, hs_path)
    save_txt(H2, h2_path)

    print("✅ Built OK")
    print("  Hsecc:", Hsecc.shape, "H2:", H2.shape)
    print("  SSC :", ok_ssc, where_ssc)
    print("  U/O :", ok_uo,  where_uo)
    print("  B.F.:", ok_bf,  where_bf)
    print("  CRC :", ok_crc, where_crc)
    print("  DEC dup/hits:", dup, hits)
    print("  CRC-n windows (n={}): OK".format(args.crc_n))
    print("  DEC pairs:", total_pairs, "| dup:", dup, "| hits(single):", hits)
    print("  Saved to:")
    print("    ", hs_path)
    print("    ", h2_path)

if __name__ == "__main__":
    main()

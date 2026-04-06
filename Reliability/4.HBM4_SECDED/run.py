#!/usr/bin/env python3
import subprocess
import os
from multiprocessing import Pool, cpu_count

EXE = "./HBM4_fault_sim"

# Sequence: [LINK1 STOR, PERI, LINK2]
DOMAINS = {
    0: [0,1,2,3],      # LINK1: 0=NE_L, 1=SE_L, 2=DQS,   3=DQ
    1: [0,1,2,3,4],    # STOR : 0=NE_O, 1=SE,   2=SE_SE, 3=SWL_16E, 4=SWD_32E
    2: [0,1,2],        # PERI:  0=NE_P, 1=SE_P, 2=DE_P
    3: [0,2,3],        # LINK2: 0=NE_L, 1=SE_L, 2=DQS,   3=DQ
}

def build_single_active_cases():
    cases = []
    for pos in range(4):
        for v in DOMAINS[pos]:
            if v == 0:
                continue
            args = [0, 0, 0, 0]
            args[pos] = v
            cases.append(args)
    return cases

def run_case(args):
    cmd = [EXE] + list(map(str, args))
    print("Running:", " ".join(cmd))
    try:
        res = subprocess.run(cmd, check=False)
        return (args, res.returncode)
    except Exception as e:
        return (args, f"EXC:{e}")

def main(parallel=True):
    cases = build_single_active_cases()
    print(f"Total single-active cases: {len(cases)}")

    if parallel:
        procs = max(1, min(len(cases), cpu_count()))
        with Pool(processes=procs) as pool:
            results = pool.map(run_case, cases)
    else:
        results = [run_case(c) for c in cases]

    ok = sum(1 for _, rc in results if rc == 0)
    fail = [(args, rc) for args, rc in results if rc != 0]
    print(f"\nSucceeded: {ok} / {len(results)}")
    if fail:
        print("Failed cases:")
        for args, rc in fail:
            print(f"  args={args} -> return={rc}")

if __name__ == "__main__":
    main(parallel=True)
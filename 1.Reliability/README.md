# Reliability Evaluation

This directory contains the artifact used to reproduce the **reliability evaluation** of **Cerberus: Cross-Layer ECC Co-Design for Robust and Efficient Memory Protection**.

The reliability evaluation is implemented as a set of **Monte Carlo-based error injection simulators**, one for each ECC scheme evaluated in the paper. These simulators estimate the probability of three final outcomes under different fault scenarios:

- **CE**: Correctable Error
- **DUE**: Detected Uncorrectable Error
- **SDC**: Silent Data Corruption

Using these outputs, this artifact reproduces the reliability results reported in:

- **Table II**: Single-location fault evaluation
- **Table III**: Multiple-location fault evaluation

---

## 1. Directory Organization

The `Reliability/` directory is organized by ECC scheme.

```text
Reliability/
├── 1.DUO/
├── 2.Unity_ECC/
├── 3.HBM4_CRC16/
├── 4.HBM4_SECDED/
├── 5.LPDDR6_CRC16/
├── 6.LPDDR6_SECDED/
├── 7.Cerberus_32b/
└── 8.Cerberus_40b/
```

Each scheme directory contains the same basic components:

- **`<scheme>_fault_sim.cpp`**  
  C++ source code for the Monte Carlo fault-injection simulator of the target ECC scheme.

- **`Makefile`**  
  Compiles the simulator source into an executable.

- **`run.py`**  
  Runs the predefined **single-location reliability evaluation** and parses the results.

- **`Result/`**  
  Stores generated result files.

The artifact is designed so that each ECC scheme can be evaluated independently.

---

## 2. Evaluation Methodology

The reliability artifact models fault scenarios by injecting combinations of faults into different protection locations in the memory system and then observing the final ECC outcome.

At a high level, each simulation trial proceeds as follows:

1. Generate a valid codeword or protected data block for the target ECC scheme.
2. Inject one or more faults according to the selected fault model.
3. Apply the corresponding decoding and checking procedure of the evaluated ECC design.
4. Classify the final outcome as:
   - **CE** if the fault is successfully corrected,
   - **DUE** if the fault is detected but cannot be corrected, or
   - **SDC** if corrupted data escapes detection and reaches the final output.

A large number of Monte Carlo trials are repeated to estimate the probability of each outcome.

---

## 3. System Requirements

No special hardware is required. Any modern Linux machine with a standard C++ compiler is sufficient for the reliability evaluation.

### Tested Environment

- **OS**: Ubuntu 18.04.6 LTS
- **Compiler**: gcc / g++
- **Interpreter**: Python 3

### Recommended Environment

- Linux workstation or server
- Multi-core CPU recommended for faster repeated runs
- Sufficient disk space for generated logs and result files

---

## 4. Build Instructions

Move into the target ECC-scheme directory and compile the simulator with `make`.

Example:

```bash
cd Reliability/1.DUO
make
```

This generates the simulator executable for that scheme.

Repeat the same process in other scheme directories if you want to evaluate multiple ECC configurations.

---

## 5. Single-Location Reliability Evaluation

The **single-location evaluation** corresponds to the results reported in **Table II**.

This mode is automated through `run.py`, which executes the compiled simulator for the predefined single-fault scenarios used in the paper and stores the parsed results under `Result/`.

### Example

```bash
cd Reliability/1.DUO
make
python3 run.py
```

### What `run.py` does

`run.py` performs the following steps:

1. Invokes the corresponding simulator executable
2. Runs the set of predefined single-location fault scenarios
3. Collects the raw simulator outputs
4. Parses the results into summarized CE / DUE / SDC statistics
5. Saves the generated outputs in `Result/`

### Reproducing Table II

To reproduce the full single-location comparison in Table II, run the same workflow in each scheme directory:

- `1.DUO/`
- `2.Unity_ECC/`
- `3.HBM4_CRC16/`
- `4.HBM4_SECDED/`
- `5.LPDDR6_CRC16/`
- `6.LPDDR6_SECDED/`
- `7.Cerberus_32b/`
- `8.Cerberus_40b/`

---

## 6. Multiple-Location Reliability Evaluation

The **multiple-location evaluation** corresponds to the results reported in **Table III**.

Unlike the single-location evaluation, this mode is not wrapped by `run.py`. Instead, the user directly executes the simulator binary and specifies the desired fault combination through command-line arguments.

### Example

```bash
cd Reliability/1.DUO
make
./<scheme>_fault_sim <LINK1_FAULT> <STOR_FAULT> <PERI_FAULT> <LINK2_FAULT>
```

Replace `<scheme>_fault_sim` with the actual simulator executable name in that directory.

This interface allows the user to inject arbitrary combinations of faults across multiple locations and evaluate the final CE / DUE / SDC behavior of the target ECC scheme.

---

## 7. Fault Encoding Interface

The simulator supports the following fault encodings.

```text
LINK*_FAULT: 0=NE_L, 1=SE_L, 2=DQS, 3=DQ
PERI_FAULT : 0=NE_P, 1=SE_P, 2=DE_P
STOR_FAULT : 0=NE_O, 1=SE, 2=SE_SE, 3=SWL_16E, 4=SWD_32E
```

### Meaning of fault classes

#### Link fault
Faults injected on the transfer path.

- **NE_L**: No link error
- **SE_L**: Single-bit link error
- **DQS**: DQS-related burst/transfer fault pattern
- **DQ**: DQ-related burst/transfer fault pattern

#### Peripheral fault
Faults injected in peripheral logic or associated circuitry.

- **NE_P**: No peripheral error
- **SE_P**: Single-bit peripheral error
- **DE_P**: Double-bit peripheral error

#### Storage fault
Faults injected in the stored data or memory cell array.

- **NE_O**: No storage error
- **SE**: Single-bit storage error
- **SE_SE**: Two independent single-bit storage errors
- **SWL_16E**: 16-bit subwordline-correlated storage fault
- **SWD_32E**: 32-bit storage fault pattern

---

## 8. Example Fault-Injection Runs

### Example 1: Single link fault only

```bash
./<scheme>_fault_sim 1 0 0 0
```

This injects:

- `LINK1_FAULT = SE_L`
- `STOR_FAULT = NE_O`
- `PERI_FAULT = NE_P`
- `LINK2_FAULT = NE_L`

### Example 2: Storage fault with peripheral error

```bash
./<scheme>_fault_sim 0 3 1 0
```

This injects:

- `LINK1_FAULT = NE_L`
- `STOR_FAULT = SWL_16E`
- `PERI_FAULT = SE_P`
- `LINK2_FAULT = NE_L`

### Example 3: Multi-location fault combination

```bash
./<scheme>_fault_sim 2 4 2 3
```

This injects:

- `LINK1_FAULT = DQS`
- `STOR_FAULT = SWD_32E`
- `PERI_FAULT = DE_P`
- `LINK2_FAULT = DQ`

Such combinations are used to analyze the robustness of each ECC scheme under more challenging fault scenarios.

---

## 9. Output Interpretation

For each evaluated scenario, the simulator reports the probability of the following final outcomes:

- **CE (Correctable Error)**  
  The ECC scheme successfully corrects the injected fault and recovers the original data.

- **DUE (Detected Uncorrectable Error)**  
  The ECC scheme detects that an error exists, but it cannot safely recover the original data.

- **SDC (Silent Data Corruption)**  
  Corrupted data escapes detection and remains in the final output.

In general:

- A **higher CE** is desirable when correction is possible.
- A **lower DUE** is desirable, though DUE is still safer than undetected corruption.
- A **lower SDC** is the most critical goal for robust memory protection.

---

## 10. Expected Results

This artifact is intended to reproduce the following reliability results from the paper:

- **Table II**: Reliability comparison under single-location fault scenarios
- **Table III**: Reliability comparison under multiple-location fault scenarios

Across ECC schemes and fault combinations, the final result of each experiment is a set of CE / DUE / SDC probabilities.

### Expected qualitative outcome

The main expected observation is that **Cerberus** provides stronger reliability than the baseline ECC schemes, especially under challenging multi-location error scenarios, while maintaining robust protection against silent data corruption.

---

## 11. Reproducibility Workflow

A typical workflow to reproduce the reliability results is:

### Step 1. Choose a scheme

For example:

```bash
cd Reliability/7.Cerberus_32b
```

### Step 2. Build the simulator

```bash
make
```

### Step 3. Reproduce single-location results

```bash
python3 run.py
```

### Step 4. Evaluate custom multi-location fault scenarios

```bash
./<scheme>_fault_sim <LINK1_FAULT> <STOR_FAULT> <PERI_FAULT> <LINK2_FAULT>
```

### Step 5. Repeat for other schemes

Run the same process in the remaining directories to compare all ECC configurations.

---

## 12. Notes

- The reliability evaluation is lightweight compared with the performance and hardware-overhead artifacts.
- Each ECC scheme is evaluated independently through its own simulator implementation.
- Users may first run a small number of sanity-check experiments before launching the full set of evaluations.
- Generated outputs are stored under each scheme's `Result/` directory.

---

## 13. Citation

If you use this artifact, please cite the ISCA 2026 paper:

**Cerberus: Cross-Layer ECC Co-Design for Robust and Efficient Memory Protection**

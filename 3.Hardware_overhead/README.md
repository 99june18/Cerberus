# Hardware Overhead Evaluation

This directory contains the artifact used to reproduce the **hardware-overhead evaluation** of **Cerberus: Cross-Layer ECC Co-Design for Robust and Efficient Memory Protection**.

This part of the artifact evaluates the implementation cost of the ECC schemes studied in the paper by providing RTL source code, testbenches, and synthesis scripts for the main encoder and decoder blocks.

The hardware-overhead artifact reproduces:

- **Table VI**: Area overhead comparison of the evaluated ECC schemes

The main purpose of this artifact is to enable users to:

1. verify the functionality of each encoder and decoder block through RTL simulation, and
2. reproduce the relative hardware cost through logic synthesis.

---

## 1. Directory Organization

The `Hardware_overhead/` directory is organized by ECC scheme.

```text
Hardware_overhead/
├── 1.DUO/
├── 2.Unity_ECC/
├── 3.Cerberus_32b/
└── 4.Cerberus_40b/
```

Each ECC-scheme directory contains both an **Encoder** block and a **Decoder** block.

For example:

```text
Hardware_overhead/1.DUO/
├── Encoder/
└── Decoder/
```

Each encoder or decoder block contains the following components:

- **`rtl/`**  
  SystemVerilog RTL source files for the target block.

- **`sim/`**  
  Testbench files and simulation scripts used for functional verification.

- **`syn/`**  
  Synthesis scripts and synthesis-related files used for hardware cost evaluation.

- **`common.sh`**  
  Common setup script used by the simulation and synthesis flow.

This organization allows users to evaluate each scheme independently and compare both encoder and decoder costs across designs.

---

## 2. Evaluated ECC Schemes

The hardware-overhead artifact includes the following ECC configurations:

- **DUO**
- **Unity ECC**
- **Cerberus (32b)**
- **Cerberus (40b)**

For each configuration, both the encoder and decoder implementations are provided.

This enables a block-level comparison of implementation overhead and allows the final area numbers to be combined into the comparison reported in the paper.

---

## 3. Evaluation Goal

The goal of this artifact is to measure the hardware implementation cost of the ECC blocks used in the evaluated schemes.

More specifically, this artifact is designed to support:

- functional verification of the provided RTL implementations,
- synthesis-based hardware cost comparison, and
- reproduction of the relative area overhead trends reported in **Table VI**.

The primary metric of interest is:

- **Area overhead**

The main expected outcome is that the synthesized reports allow users to compare the relative hardware cost of the evaluated ECC schemes and verify the trends presented in the paper.

---

## 4. Evaluation Methodology

The hardware-overhead evaluation is performed in two stages.

### 4.1 RTL simulation

First, each encoder or decoder block is compiled and simulated to verify that the RTL and testbench operate correctly.

This stage checks the functional behavior of the block before synthesis.

### 4.2 Logic synthesis

Second, the same encoder or decoder block is synthesized using **Synopsys Design Compiler** with the provided synthesis scripts and target standard-cell library.

This stage generates the reports used to compare the implementation overhead across ECC schemes.

At a high level, the workflow is:

```text
RTL source
   ↓
Testbench-based simulation
   ↓
Synthesis with Design Compiler
   ↓
Area report generation
   ↓
Comparison across ECC schemes
```

---

## 5. System Requirements

A Linux workstation or server capable of RTL simulation and logic synthesis is required.

### Tested Environment

- **OS**: Ubuntu 18.04.6 LTS
- **Simulator**: VCS
- **Synthesis tool**: Synopsys Design Compiler
- **Library**: UMC 28nm standard-cell library
- **Shell**: bash

### Required Dependencies

The hardware-overhead evaluation depends on:

- **VCS**
- **Synopsys Design Compiler**
- **UMC 28nm standard-cell library**
- **bash**

### Important note

This part of the artifact requires **commercial EDA tools** and a **valid standard-cell library**.  
Therefore, users must prepare an appropriate licensed environment before running the provided flow.

---

## 6. Block-Level Workflow

Each encoder or decoder block can be evaluated independently.

A typical target directory looks like:

```text
Hardware_overhead/<scheme>/<block>/
```

where:

- `<scheme>` is one of:
  - `1.DUO`
  - `2.Unity_ECC`
  - `3.Cerberus_32b`
  - `4.Cerberus_40b`

- `<block>` is one of:
  - `Encoder`
  - `Decoder`

For each target block, the evaluation can be divided into:

1. simulation under `sim/`
2. synthesis under `syn/`

---

## 7. Running RTL Simulation

To functionally verify a block, move to its `sim/` directory and run the provided script.

### Example

```bash
cd Hardware_overhead/1.DUO/Decoder/sim
./run compile
./run tb
```

### Meaning of the commands

- **`./run compile`**  
  Compiles the RTL and testbench for the target block.

- **`./run tb`**  
  Runs the testbench simulation.

This flow is used to verify that the provided RTL implementation behaves as expected before synthesis.

### Cleaning the simulation directory

If needed, the simulation directory can be cleaned with:

```bash
./run clean
```

This is useful when re-running the flow from a clean state.

---

## 8. Running Logic Synthesis

To evaluate the hardware overhead of a block, move to its `syn/` directory and run the synthesis script.

### Example

```bash
cd Hardware_overhead/1.DUO/Decoder/syn
./run clean
./run synth
```

### Meaning of the commands

- **`./run clean`**  
  Removes previously generated synthesis files and resets the working directory.

- **`./run synth`**  
  Launches the synthesis flow for the target block using Synopsys Design Compiler and the provided setup.

This flow generates the reports used to compare the hardware cost of the evaluated ECC blocks.

---

## 9. Role of Each Subdirectory

### `rtl/`

Contains the SystemVerilog implementation of the encoder or decoder block.

This is the actual hardware description used for both simulation and synthesis.

### `sim/`

Contains the simulation environment, including the testbench and helper scripts.

This directory is used to verify that the block operates correctly at the RTL level.

### `syn/`

Contains the synthesis environment, including scripts and setup files required to run Design Compiler.

This directory is used to derive the area-related reports for the block.

### `common.sh`

Provides shared environment setup used by the simulation and synthesis flows.

This helps keep the workflow consistent across different ECC schemes and blocks.

---

## 10. Reproducing Table VI

The hardware-overhead artifact reproduces:

- **Table VI**: Area overheads for the evaluated ECC schemes

To reproduce the comparison, users should perform synthesis for the encoder and decoder blocks of:

- `1.DUO`
- `2.Unity_ECC`
- `3.Cerberus_32b`
- `4.Cerberus_40b`

The generated synthesis reports can then be used to compare the relative hardware cost across schemes.

Because the final table is based on synthesized implementation cost, the synthesis stage is the key part of this artifact.

---

## 11. Expected Output

The expected outputs of this artifact include:

- successful compilation and testbench execution for the evaluated blocks,
- synthesis results for encoder and decoder blocks, and
- reports that can be used to compare the relative area overhead across ECC schemes.

### Expected qualitative outcome

The main expected observation is that the synthesized reports reproduce the relative implementation-cost trends reported in **Table VI**.

---

## 12. Reproducibility Workflow

A typical workflow to reproduce the hardware-overhead evaluation is:

### Step 1. Choose a target scheme and block

For example:

```bash
cd Hardware_overhead/3.Cerberus_32b/Decoder
```

### Step 2. Run RTL simulation

```bash
cd sim
./run compile
./run tb
```

### Step 3. Run synthesis

```bash
cd ../syn
./run clean
./run synth
```

### Step 4. Inspect the generated reports

Use the synthesis outputs to compare the target block against the other ECC schemes.

### Step 5. Repeat for other blocks and schemes

Repeat the same process for:

- both **Encoder** and **Decoder**, and
- all evaluated ECC schemes

to reproduce the comparison used in **Table VI**.

---

## 13. Practical Notes

- The hardware-overhead evaluation depends on licensed commercial tools.
- It is recommended to verify RTL simulation first before running synthesis.
- Each block can be evaluated independently, which makes it possible to debug problems at the block level.
- Users may begin with a single encoder or decoder as a sanity check before launching the full evaluation across all schemes.
- The exact generated files may depend on the local tool environment, but the provided scripts define the intended flow.

---

## 14. Limitations

This artifact provides the RTL implementations and synthesis flow used for evaluation, but successful reproduction requires:

- access to VCS,
- access to Synopsys Design Compiler, and
- access to a compatible UMC 28nm standard-cell library.

If these prerequisites are not available, users may still inspect the RTL and simulation structure, but they may not be able to reproduce the full synthesis-based area comparison.

---

## 15. Citation

If you use this artifact, please cite the ISCA 2026 paper:

**Cerberus: Cross-Layer ECC Co-Design for Robust and Efficient Memory Protection**

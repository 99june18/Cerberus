# Performance and DRAM Energy Evaluation

This directory contains the artifact used to reproduce the **performance** and **DRAM energy** evaluation of **Cerberus: Cross-Layer ECC Co-Design for Robust and Efficient Memory Protection**.

This part of the artifact reproduces the following results from the paper:

- **Figure 7(a)**: IPC normalized to HBM4
- **Figure 7(b)**: DRAM energy normalized to HBM4

The evaluation is divided into two closely related parts:

1. **Performance evaluation** using **Accel-Sim**
2. **DRAM energy calculation** using the collected simulation statistics

The performance artifact generates the benchmark execution results for each ECC configuration.  
The energy artifact then uses the **instruction numbers collected from Accel-Sim** together with the **current values** used in the paper’s DRAM energy model, and computes final DRAM energy through an **Excel sheet that reflects the Micron power calculator methodology**.

---

## 1. Directory Organization

The `Performance_Energy/` directory is organized into separate subdirectories for performance simulation and energy calculation.

```text
Performance_Energy/
├── Performance/
│   └── Cerberus_script/
│       ├── run.sh
│       ├── run_script.py
│       ├── Cerberus.yaml
│       ├── result/
│       ├── run_status/
│       └── make_excel.py
└── Energy/
```

### Performance directory

The main performance workflow is located under:

```text
Performance_Energy/Performance/Cerberus_script/
```

This directory contains:

- **`run.sh`**  
  Shell script that launches the evaluation workflow.

- **`run_script.py`**  
  Python script that executes the benchmark simulation flow.

- **`Cerberus.yaml`**  
  Accel-Sim configuration file used for the evaluation.

- **`result/`**  
  Stores generated performance results for each ECC scheme and benchmark.

- **`run_status/`**  
  Stores status files, execution progress, and run logs.

- **`make_excel.py`**  
  Collects the simulation outputs and exports aggregated results into an Excel file.

### Energy directory

The DRAM energy calculation files are provided under:

```text
Performance_Energy/Energy/
```

This directory contains the Excel files used to calculate DRAM energy from the collected performance results.

---

## 2. Evaluation Goal

The goal of this artifact is to reproduce how different ECC designs affect:

- GPU performance
- DRAM energy consumption

The evaluated ECC configurations include:

- **Unity ECC**
- **DUO**
- **HBM4**
- **Cerberus (32b)**
- **Cerberus (40b)**

The main expected outcome is that **Cerberus improves performance while maintaining competitive DRAM energy consumption** across the evaluated workloads and ECC configurations.

---

## 3. Evaluation Methodology

### 3.1 Performance evaluation

Performance is evaluated using **Accel-Sim**.  
The provided scripts automate the execution of the benchmark suite under the ECC-aware simulation configuration used in the paper.

At a high level, the performance workflow proceeds as follows:

1. Launch the Accel-Sim environment
2. Execute the benchmark simulations for each ECC configuration
3. Collect the raw outputs for all workloads
4. Aggregate the results
5. Export them into an Excel file for final comparison and plotting

The final performance metric reported in the paper is:

- **IPC normalized to HBM4**

### 3.2 DRAM energy calculation

The DRAM energy evaluation is derived from the performance results.

Specifically, the DRAM energy is calculated using:

- the **instruction numbers collected from Accel-Sim**,
- the **current values used for the DRAM energy model**, and
- an **Excel sheet that reflects the Micron power calculator methodology**.

In other words, the artifact does **not** estimate DRAM energy directly inside Accel-Sim.  
Instead, it first collects the relevant simulation statistics from Accel-Sim, and then uses those values as inputs to the Excel-based DRAM energy model.

At a high level, the energy flow is:

```text
Accel-Sim simulation
        ↓
Collection of instruction numbers
        ↓
Application of DRAM current values
        ↓
Excel-based calculation reflecting Micron power calculator
        ↓
Final DRAM energy values
```

The final energy metric reported in the paper is:

- **DRAM energy normalized to HBM4**

---

## 4. System Requirements

Because the performance evaluation runs a large number of cycle-level simulations, a reasonably capable Linux server or workstation is recommended.

### Tested Environment

**Host environment**
- **OS**: Ubuntu 18.04.6 LTS
- **Runtime**: Docker

### Recommended host hardware

- Modern multicore x86_64 CPU
- Sufficient main memory for Accel-Sim execution and post-processing
- Enough disk space for simulation outputs and logs

### Required Dependencies

We tested the evaluation with the following tools:

- **Docker**
- **Python 3**
- **bash**
- **Accel-Sim**

---

## 5. Performance Workflow

The performance workflow is executed under:

```bash
cd Performance_Energy/Performance/Cerberus_script
```

### Step 1. Launch the evaluation

Run:

```bash
bash ./run.sh
```

This script launches the main simulation workflow.

### What `run.sh` does

`run.sh` serves as the entry point of the performance artifact.  
It invokes `run_script.py` with the configuration specified in `Cerberus.yaml` inside the prepared Accel-Sim environment.

At a high level, it performs the following tasks:

1. Sets up the execution environment
2. Loads the Accel-Sim configuration
3. Starts the benchmark simulation flow
4. Stores results and logs in the designated directories

### What `run_script.py` does

`run_script.py` is responsible for the benchmark-level execution flow.  
It runs the simulations for the evaluated ECC configurations and manages result generation for the benchmark suite used in the paper.

### Role of `Cerberus.yaml`

`Cerberus.yaml` defines the Accel-Sim configuration used to reproduce the paper’s performance results.  
This file controls the experiment setup and simulation parameters used by the workflow.

---

## 6. Output Structure

After execution, the generated simulation results are stored in:

```text
Performance_Energy/Performance/Cerberus_script/result/
```

The results are organized by ECC scheme under directories such as:

- `Unity/`
- `DUO/`
- `HBM4/`
- `Cerberus/`
- `Cerberus40b/`

Each scheme directory contains the simulation results for the **16 evaluated benchmarks**.

Aggregated outputs are stored under:

- `final_result/`

Execution progress and logs are stored under:

```text
Performance_Energy/Performance/Cerberus_script/run_status/
```

This allows users to monitor running jobs and inspect execution logs if needed.

---

## 7. Exporting Aggregated Results

After the simulations finish, run the following command to collect the raw outputs and export them to an Excel file.

```bash
cd Performance_Energy/Performance/Cerberus_script
python3 make_excel.py
```

### What `make_excel.py` does

This script:

1. Collects the generated performance results
2. Parses the relevant metrics
3. Aggregates the results across the evaluated workloads
4. Exports the summarized outputs to an Excel file

The generated Excel file is saved in:

```text
Performance_Energy/Performance/Cerberus_script/run_status/
```

This file provides the summarized performance data used to verify **Figure 7(a)** and to prepare the inputs required for DRAM energy calculation.

---

## 8. DRAM Energy Calculation Workflow

The DRAM energy calculation files are located under:

```text
Performance_Energy/Energy/
```

The energy evaluation is based on the performance results obtained from Accel-Sim.

More specifically, the DRAM energy values are computed as follows:

1. Run the Accel-Sim performance simulations
2. Collect the relevant **instruction numbers** from the simulation outputs
3. Use the **current values** defined for the DRAM energy model
4. Enter these values into the provided **Excel sheet**
5. Use the Excel sheet, which reflects the **Micron power calculator** methodology, to calculate final DRAM energy

Therefore, the DRAM energy results are produced through an **offline Excel-based post-processing step**, not through direct simulation-time power estimation inside Accel-Sim.

### Important note

The DRAM energy results are **not generated independently** of the performance results.  
They are derived from the performance evaluation outputs. Therefore, the performance workflow must be completed first.

---

## 9. Expected Results

This artifact is designed to reproduce:

- **Figure 7(a)**: IPC normalized to HBM4
- **Figure 7(b)**: DRAM energy normalized to HBM4

### Expected performance outputs

The performance outputs include:

- Per-benchmark results for all **16 workloads**
- Results for:
  - `Unity ECC`
  - `DUO`
  - `HBM4`
  - `Cerberus (32b)`
  - `Cerberus (40b)`
- Aggregated outputs exported to Excel

### Expected energy outputs

The energy outputs include:

- DRAM energy values calculated from the **Accel-Sim instruction numbers** and **current values**
- Excel files containing the final energy calculations
- Normalized comparisons across the evaluated ECC configurations

### Expected qualitative outcome

The main expected observation is that **Cerberus improves performance while maintaining competitive DRAM energy consumption** relative to the baseline ECC schemes.

---

## 10. Reproducibility Workflow

A typical workflow to reproduce the performance and DRAM energy evaluation is:

### Step 1. Move to the performance script directory

```bash
cd Performance_Energy/Performance/Cerberus_script
```

### Step 2. Launch the Accel-Sim evaluation

```bash
bash ./run.sh
```

### Step 3. Monitor run progress

Inspect files under:

```text
run_status/
```

### Step 4. Export aggregated performance results

```bash
python3 make_excel.py
```

### Step 5. Use the generated statistics for DRAM energy calculation

Check the Excel files under:

```text
Performance_Energy/Energy/
```

### Step 6. Verify the final normalized results

Compare the generated outputs against:

- **Figure 7(a)** for IPC
- **Figure 7(b)** for DRAM energy

---

## 11. Notes on the Docker Environment

The performance artifact is designed around a **Docker-based Accel-Sim workflow**.

### Important note

The Docker image itself is **not included** in this repository because the image size is too large to distribute through GitHub.

However, this repository provides:

- the scripts,
- the configuration files, and
- the workflow structure

used in the paper.

Therefore, if you prepare a compatible Docker environment that supports Accel-Sim, you can use the provided files to reproduce the performance evaluation flow.

---

## 12. Practical Notes

- The performance evaluation is the most time-consuming part of the artifact.
- Users are encouraged to run a small sanity-check subset before launching the full simulation set.
- The `run_status/` directory is useful for checking progress and debugging failed runs.
- The DRAM energy calculation depends on the performance outputs, so the performance workflow should be completed first.
- The energy calculation is performed in Excel using Accel-Sim instruction statistics and current values.
- Sufficient storage is recommended because simulation outputs and logs can accumulate across workloads and ECC configurations.

---

## 13. Citation

If you use this artifact, please cite the ISCA 2026 paper:

**Cerberus: Cross-Layer ECC Co-Design for Robust and Efficient Memory Protection**

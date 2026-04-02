# Artifact Evaluation for "Cerberus: Cross-Layer ECC Co-Design for Robust and Efficient Memory Protection" (ISCA 2026)

## Overview   (초안)

This repository provides the artifact for the ISCA 2026 paper **Cerberus: Cross-Layer ECC Co-Design for Robust and Efficient Memory Protection**.

* List of experiments to reproduce:
  * Reliability evaluation of Cerberus
  * Performance and DRAM energy evaluation of Cerberus and baseline ECC schemes
  * Hardware overhead evaluation of Cerberus

* Structure of this repository:
  * `reliability_eval`: Cerberus reliability evaluation directory (Table II, Table III)
  * `perf_simulation`: Cerberus performance and DRAM energy evaluation directory (Figure 7)
  * `hardware_eval`: Cerberus hardware overhead evaluation directory (Table VI)

> **Note:** This README follows the organization style of the RowArmor artifact repository. If your local file names or script names differ, replace the example commands below accordingly.

---

## Reliability Evaluation

This artifact consists of the following components:

* `Fault_sim.cpp`: A Monte Carlo-based error injection simulator
* `inputs/`: ECC input files for the simulation
* `scripts/`: Scripts to run the simulation and parse the results
* `results/`: Directory for simulation results

### System specification

No special hardware requirements. Any modern CPU is sufficient.

### Required Dependencies

We tested our evaluation under the following.

* OS: Ubuntu 18.04.6 LTS
* Compiler: gcc/g++
* Interpreter: Python 3

### Setting up Configuration Files

To run the reliability simulation, you need to configure the evaluated ECC schemes, error locations, and fault scenarios.

First, set the ECC and fault parameters in `run.py`. We provide customizable lists to define the target ECC schemes and fault scenarios.

```python
scheme = [
    "unity", "duo",
    "lpddr6_secded", "lpddr6_crc",
    "hbm4_secded", "hbm4_crc",
    "cerberus32", "cerberus40",
]

location = [
    "in_bank", "write_link", "out_bank", "multi_location",
]

scenario = [
    "SE", "16E", "32E", "SE+SE", "DQE", "DQSE", "DE",
    "16E+DQE", "32E+DQSE", "SE+SE+SE", "SE+DE", "SE+DQE+DQSE",
]
```

Then, set the number of simulation iterations. To change the number of fault injections per experiment, edit the following line in `Fault_sim.cpp`:

```cpp
#define RUN_NUM 10000000
```

### Run the reliability evaluation

To run the simulation, use the shell script provided in the `reliability_eval/scripts/` directory.
The simulation runs Monte Carlo-based error injections by varying ECC and fault parameters.

```bash
cd reliability_eval/scripts
bash ./sim.sh
```

This script launches multiple simulation processes in parallel and parses the results after the simulations complete.

To launch the simulations and parse the results manually, you can run the following commands.

```bash
cd reliability_eval

# 1. Build the simulator
make

# 2. Run a simulation
./Fault_sim_start <scheme> <location> <scenario> <path-to-output>

# 3. Parse the results
python3 scripts/parse_results.py
```

### Expected output

The reliability evaluation reproduces:

* **Table II**: A comparison of reliability against single-location error scenarios
* **Table III**: A comparison of reliability against multiple-location error scenarios

The final output should report, for each ECC configuration and fault scenario:

* CE: Correctable Error probability
* DUE: Detected Uncorrectable Error probability
* SDC: Silent Data Corruption probability

The expected trend is that Cerberus provides strong correction and detection capability across both single-location and multi-location error scenarios while maintaining the same or lower redundancy budget than prior multi-layer baselines.

---

## Performance and DRAM Energy Evaluation

This artifact consists of the following components:

* `Dockerfile`: Docker environment for Accel-Sim
* `configs/`: Machine and memory configuration files
* `workloads/`: Workload input files or wrappers
* `scripts/`: Simulation scripts and post-processing scripts
* `results/`: Directory for simulation results

### System specification

Since a large number of simulations may need to be executed, we recommend running them on a multicore server/workstation with sufficient memory capacity.

We tested and ran the simulation in the following environment.

**Host environment**
* OS: Ubuntu 18.04.6 LTS
* Runtime: Docker

**Recommended host hardware**
* CPU: modern multicore x86_64 server/workstation
* Memory: sufficient DRAM capacity for parallel Docker-based simulation and post-processing

### Required Dependencies

We tested our simulator under the following.

* Docker
* Python 3
* bash
* Accel-Sim

### Setting up Configuration Files

This evaluation uses **Accel-Sim** to reproduce the GPU performance results and a post-processing flow to reproduce the DRAM energy results.

First, prepare the simulation configuration files in `configs/`.

The baseline model follows the paper configuration:

* NVIDIA V100-like GPU
* 32 HBM channels
* HBM4 timing configuration
* ECC-specific timing changes applied to `tCL` and `tWL`

We also provide scripts to run the evaluated workloads from:

* Rodinia
* Parboil
* GraphBIG
* PolyBench

### Building the Docker-based Accel-Sim environment

To build the Docker image:

```bash
cd perf_simulation
docker build -t cerberus-accelsim .
```

To launch the container:

```bash
docker run --rm -it \
  -v $(pwd):/workspace \
  cerberus-accelsim
```

### Running experiments

Inside the container, run the provided simulation script.

```bash
cd /workspace
bash ./scripts/run_all.sh
```

This script executes all simulations for the following configurations:

* HBM4
* Unity ECC
* DUO
* Cerberus (32b)
* Cerberus (40b)

### Parse results

After running simulations, parse the raw results files.

```bash
cd /workspace
python3 ./scripts/parse_results.py
python3 ./scripts/plot_figure7.py
```

The raw output files are saved in the `results/` directory.
These raw outputs are post-processed to generate CSV files and plots used for Figure 7.

### DRAM energy estimation

The DRAM energy evaluation uses the operating currents defined in the paper and the Micron DDR4 power calculator.

To generate the normalized DRAM energy results:

```bash
cd /workspace
python3 ./scripts/estimate_energy.py
python3 ./scripts/plot_energy.py
```

### Expected output

The performance and energy evaluation reproduces:

* **Figure 7(a)**: IPC normalized to HBM4
* **Figure 7(b)**: DRAM energy normalized to HBM4

Expected trends:

* **Cerberus (32b)**
  * IPC improvement: **0.7% geomean** over HBM4
  * DRAM energy reduction: **1.84% average** relative to HBM4

* **Cerberus (40b)**
  * IPC improvement: **0.5% geomean** over HBM4
  * DRAM energy increase: **0.86% average** relative to HBM4

The main expected result is that Cerberus improves performance through its Encode-Once, Decode-Many (EODM) organization while also reducing or controlling DRAM energy depending on the redundancy configuration.

---

## Hardware Overhead Evaluation

This artifact consists of the following components:

* `rtl/`: SystemVerilog RTL for the Cerberus encoder and decoders
* `scripts/`: Synthesis scripts
* `reports/`: Output synthesis reports
* `results/`: Parsed synthesis summaries

### System specification

A Linux server/workstation capable of RTL synthesis is required.

### Required Dependencies

We tested our synthesis flow under the following.

* Synopsys Design Compiler
* UMC 28nm standard-cell library
* Python 3 (optional, for report parsing)

### Setting up Configuration Files

The hardware overhead evaluation synthesizes:

* shared encoder
* Decoder 1 (L-ECC)
* Decoder 2 (O-ECC)
* Decoder 3 (S-ECC)

for both:

* Cerberus (32b)
* Cerberus (40b)

The synthesis scripts are located in `hardware_eval/scripts/`.

### Running synthesis

To run the full synthesis flow:

```bash
cd hardware_eval
dc_shell -f scripts/synth_all.tcl
```

If you want to synthesize each block separately, use the corresponding TCL scripts in the `scripts/` directory.

### Parse results

After synthesis, parse the reports and summarize the final area results.

```bash
cd hardware_eval
python3 scripts/parse_area.py
```

The final results should report:

* area in `um^2`
* area normalized to NAND2 equivalents

### Expected output

The hardware overhead evaluation reproduces:

* **Table VI**: Area overheads (in NAND2 equivalents)

The expected outputs include the following results.

#### Cerberus (32b)
* Encoder: 1632.79 μm² (3240 NAND2 equivalents)
* Decoder 1 (L-ECC): 1205.40 μm² (2392 NAND2 equivalents)
* Decoder 2 (O-ECC): 6199.87 μm² (12301 NAND2 equivalents)
* Decoder 3 (S-ECC): 62669.04 μm² (124343 NAND2 equivalents)

#### Cerberus (40b)
* Encoder: 2015.49 μm² (3999 NAND2 equivalents)
* Decoder 1 (L-ECC): 1398.43 μm² (2775 NAND2 equivalents)
* Decoder 2 (O-ECC): 6495.15 μm² (12887 NAND2 equivalents)
* Decoder 3 (S-ECC): 82633.15 μm² (163955 NAND2 equivalents)

The key expected trend is that the L-ECC and O-ECC logic remain modest, while the S-ECC decoder dominates the total area overhead.

---

## Repository structure

A recommended repository structure is as follows.

```text
.
├── reliability_eval
│   ├── inputs
│   ├── scripts
│   ├── results
│   ├── Fault_sim.cpp
│   ├── run.py
│   └── Makefile
├── perf_simulation
│   ├── configs
│   ├── workloads
│   ├── scripts
│   ├── results
│   └── Dockerfile
├── hardware_eval
│   ├── rtl
│   ├── scripts
│   ├── reports
│   └── results
└── README.md
```

If your repository uses a different directory structure, please update the commands and paths accordingly.

---

## Contact

For questions or issues, please contact:

* [Author 1 Name] [author1@email.com]
* [Author 2 Name] [author2@email.com]

---

## Notes

* The performance evaluation is designed around a Docker-based Accel-Sim workflow on Ubuntu 18.04.6 LTS.
* The DRAM energy estimation uses HBM2E operating currents together with the Micron DDR4 power calculator.
* The hardware overhead evaluation requires commercial EDA tools and a valid standard-cell library.
* For long-running simulations, partial runs and reduced-size sanity checks are recommended before launching the full workflow.

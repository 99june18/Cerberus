# Artifact Evaluation for "Cerberus: Cross-Layer ECC Co-Design for Robust and Efficient Memory Protection" (ISCA 2026)

[![DOI](https://zenodo.org/badge/1202489380.svg)](https://doi.org/10.5281/zenodo.19435338)

This repository provides the artifact for the ISCA 2026 paper **Cerberus: Cross-Layer ECC Co-Design for Robust and Efficient Memory Protection**.

## Overview

This artifact supports reproduction of three parts of the paper:

- **Reliability evaluation**
- **Performance and DRAM energy evaluation**

## Repository Structure

- `Reliability/`  
  Reproduces the reliability results in **Table II** and **Table III**

- `Performance_Energy/`  
  Reproduces the performance and DRAM energy results in **Figure 7(a)** and **Figure 7(b)**


## Notes

- `Reliability/` provides Monte Carlo-based fault-injection simulators for each ECC scheme.
- `Performance_Energy/` provides the Accel-Sim workflow and Excel-based DRAM energy calculation.
- Please refer to the `README.md` file inside each directory for detailed instructions.
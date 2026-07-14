# Phased-Array Automatic Calibration Tool

This repository contains a MATLAB-based automatic calibration tool for active phased-array antennas.

The program reads phase measurements obtained from an anechoic chamber, generates calibration codebooks, performs iterative phase calibration using circular statistics, and finally exports FPGA configuration files.

---

## Features

- Automatic processing of measured phase data
- Support for dual-polarized phased arrays
- Circular-statistics-based flatness evaluation
- Multi-frequency calibration
- Automatic codebook generation
- FPGA initialization code generation
- Automatic calibration iteration

---

## Calibration Workflow

1. Import measured phase data.
2. Generate the initial calibration codebook.
3. Evaluate phase consistency using circular statistics.
4. Detect frequencies requiring further calibration.
5. Update phase-shifter control codes.
6. Export the new calibration codebook.
7. Generate FPGA configuration files.
8. Repeat until all frequencies satisfy the calibration criterion.

---

## Calibration Criterion

The calibration quality is evaluated using the circular standard deviation

σ < 3°

Once all operating frequencies satisfy this requirement, the calibration process terminates automatically.

---

## Repository Structure

```
Automatic-Calibration

│
├── calibration.m
├── generate_fpga_code.m
├── calibration_value_256_x.xlsx
├── fpga256_x_xx.txt
└── README.md
```

---

## Input

The program requires

- measured phase files
- dual-polarization measurements
- multiple operating frequencies

The input data should be organized as

```
testdata/

    vertical/

        1.txt

        2.txt

        ...

    horizontal/

        1.txt

        2.txt

        ...
```

---

## Output

The program automatically generates

- Updated calibration codebooks (.xlsx)
- FPGA initialization files (.txt)

---

## Design Highlights

The calibration algorithm

- evaluates phase consistency using circular statistics;
- automatically skips frequency points that have already converged;
- performs independent calibration for V and H polarizations;
- iteratively updates phase-shifter control codes until the required calibration accuracy is achieved.

---

## Notes

This repository contains the complete implementation used for automatic phase calibration.

Some project-specific hardware interfaces and measurement files are omitted.

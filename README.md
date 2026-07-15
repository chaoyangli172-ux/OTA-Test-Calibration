# Phased-Array Automatic Calibration Tool
***MATLAB • OTA Calibration • Active Phased Array • FPGA • Circular Statistics***  

This repository contains a MATLAB-based automatic calibration tool for active phased-array antennas.

The program reads phase measurements obtained from an anechoic chamber, generates phase-shifter codebooks, performs iterative phase calibration using circular statistics, and automatically exports FPGA initialization code.  

<img width="379" height="88" alt="image" src="https://github.com/user-attachments/assets/a7179ac1-947a-412a-96d6-c068d2b35bd8" />  

*Figure 1. Example of the measured phase data format imported into MATLAB using regular-expression parsing.*

**Using the measure data shown in Figure 1 as input, the calibration tool automatically generates the FPGA initialization code shown in Figure 2**  

<img width="547" height="500" alt="image" src="https://github.com/user-attachments/assets/37a93e75-0b50-446c-941a-6605de83298a" />  

*Figure 2. Example of the generated FPGA initialization code ready to be integrated into an FPGA project.*

---

## Features

- Automatic processing of measured phase data  
- Support for dual-polarized phased arrays antennas  
- Circular-statistics-based flatness evaluation  
- Multi-frequency calibration  
- Automatic FPGA initialization code generation
- Iterative calibration workflow
- User-configurable antenna mapping and SPI configuration

---

## Usage Guide
### 1. Baseline Script

`OTA_Calibration_code.m` is the baseline implementation.

It assumes a fixed antenna configuration, including the SPI communication order, antenna numbering, sequential-rotation arrangement, and power-divider configuration.

---
### 2. Graphical Calibration Tool

To support different hardware configurations, a GUI version (`OtaMapCalibrationApp.m`) has been developed.  

Running the application displays the interface below, allowing users to configure antenna mappings, SPI order, and calibration parameters without modifying the source code.  
<img width="1412" height="600" alt="image" src="https://github.com/user-attachments/assets/78fe5ca7-f5c1-4b81-b04c-a1f110bc9e6f" />  
*Figure 3. Calibration application interface.*  

Download `OtaMapCalibrationApp.m` together with the five PNG files included in this repository.  

These images explain the antenna numbering, mapping modes, and SPI configuration options shown in Figure 3.  

### What Is the Map?

The **map** defines the relationship between the antenna measurement sequence in the anechoic chamber and the corresponding FPGA (or phase-shifter) channel indices.

Because the measurement order is usually different from the physical RF-channel order, the **map** depends on the antenna architecture, RF-chip layout, SPI configuration, and power-divider topology.

---

## Calibration Workflow

1. Import the measured data into the specifed folders.  
2. Load the phase-shifter hexadecimal codebook.  
3. Configure the operating frequencies and array parameters.  
4. Select the appropriate SPI configuration and mirror mode.
5. Click **Run Calibration** to generate the FPGA initialization file.
6. Perform the next OTA measurement using the generated calibration values.  
7. Import the new measurement results.
8. Increase the **Calibration Pass** number and repeat the calibration until the flatness criterion is satisfied.

---

## Calibration Criterion

Calibration quality is evaluated using the circular standard deviation.

**Circular Standard Deviation < 3°**

The calibration process terminates automatically once all operating frequencies satisfy this criterion.

---


## Input

The input data should be organized as follows:

```
testdata<n>/

    vertical/

        1.txt

        2.txt

        ...

    horizontal/

        1.txt

        2.txt

        ...
```

where **n** denotes the calibration iteration number.

---

## Output

The program automatically generates

- Updated calibration codebooks (.xlsx)
- FPGA initialization files (.txt)

---

## Design Highlights

The calibration algorithm

- evaluates phase consistency using circular statistics;
- automatically detects frequencies that have already converged;
- skips recalibration of converged frequencies;
- independently calibrates V and H polarizations;
- iteratively updates the phase-shifter codebook until the required calibration accuracy is achieved.

---

## Notes

This repository contains the complete calibration algorithm.

Some project-specific measurement data and hardware configurations have been omitted.

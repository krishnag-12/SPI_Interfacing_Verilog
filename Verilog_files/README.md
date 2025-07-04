# Verilog Files

This folder contains all the core **Verilog HDL source files** for the project **"SPI Protocol and Interfacing using Verilog"**. These modules implement SPI communication logic and handle interfacing with onboard peripherals such as ADC, DAC, and Amplifier.

---

## 📁 Files in this Folder

### 1. `spi_state.v`
- Implements a basic SPI Master protocol using a finite state machine (FSM).
- Transmits 16-bit parallel data serially over SPI.
- Handles clock generation (`spi_sclk`), chip select (`spi_cs_l`), and data (`spi_data`).

### 2. `adc.v`
- Interfaces with an Analog-to-Digital Converter (ADC) over SPI.
- Includes amplifier gain configuration via SPI.
- Converts 50 MHz clock to ~2 MHz for ADC timing.
- Reads two channels of ADC data and outputs 14-bit values.

### 3. `dac.v`
- Interfaces with a Digital-to-Analog Converter (DAC) over SPI.
- Builds a 32-bit SPI data frame with command, address, and data.
- Controls data transmission and provides `send` signal after completion.

---

## 📌 Purpose

These modules are written in **Verilog HDL** and are structured to be:
- Portable across FPGA platforms (especially Spartan-3E).
- Compatible with Xilinx Vivado and other standard Verilog tools.
- Modular and reusable for various SPI-based interfacing projects.

---

## 🧪 Usage

- These files are included in the Vivado project (see `/Vivado files` folder).
- Simulate using any Verilog simulator like Vivado, ModelSim, or Icarus Verilog.
- Testbench for `spi_state.v` is included in the main directory.

---

## 📌 Requirements

- FPGA Board: Spartan-3E or similar
- SPI-enabled peripherals (ADC, DAC, Amplifier)
- Simulation and Synthesis tools: Vivado / ModelSim / Icarus Verilog

---

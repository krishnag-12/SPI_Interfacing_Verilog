# SPI Protocol and Interfacing using Verilog

This project demonstrates the implementation of the **SPI (Serial Peripheral Interface) protocol** using Verilog HDL and showcases how to interface various on-board peripherals such as **ADC**, **DAC**, and **Amplifier** on the **Spartan-3E FPGA** platform.

---

## 📌 Project Highlights

- ✅ SPI Master using FSM-based bit-banging approach.
- ✅ Interfacing:
  - **ADC** (Analog to Digital Converter)
  - **DAC** (Digital to Analog Converter)
  - **Amplifier** gain control via SPI
- ✅ Verified using testbenches.
- ✅ Clock division logic and state-machine-driven control flow.
- ✅ Modular design approach using clean Verilog structure.

---

## 📁 Module Overview

### `spi_state.v`
Implements a basic SPI Master protocol that transmits 16-bit data using FSM. Includes:
- SPI Clock (`spi_sclk`)
- Chip Select (`spi_cs_l`)
- Data Output (`spi_data`)
- FSM with three states for idle, loading, and transmitting data.

### `adc.v`
Controls ADC interfacing through SPI:
- Initializes amplifier gain via SPI.
- Generates a ~2 MHz clock from 50 MHz using counters.
- Reads two channels of ADC data (`adc_data1`, `adc_data2`).
- FSM manages amplifier setup, ADC conversion trigger, and SPI read.

### `dac.v`
Controls DAC interfacing:
- Prepares 32-bit SPI data word with command, address, and data.
- Transfers data serially to DAC via SPI.
- Includes FSM with 8 states to manage SPI write cycle and post-transmission signal handling.

---

## 🧪 Testbench

### `spi_state_tb.v`
Testbench for verifying the `spi_state` module:
- Generates clock and reset signals.
- Sends multiple 16-bit test values to be transmitted via SPI.
- Can be simulated on ModelSim, Vivado, or any Verilog simulator.

---

## 🛠️ Requirements

- Verilog HDL Support
- Simulation Tool: ModelSim / Vivado / Icarus Verilog
- FPGA: Spartan-3E (preferred for on-board interfacing)
- Basic understanding of FSMs, SPI protocol, and clock division.

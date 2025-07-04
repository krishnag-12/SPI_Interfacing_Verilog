# Vivado Files

This folder contains all the project-related files and configurations used in **Xilinx Vivado** for implementing and testing the **SPI Protocol & Interfacing using Verilog** project.

---

## 📁 Contents

The folder may include:

- `*.xpr` – Vivado project file
- `*.xdc` – Constraints file (pin mappings for Spartan-3E or other FPGA boards)
- `sources_1/` – HDL source files (e.g., `spi_state.v`, `adc.v`, `dac.v`)
- `sim_1/` – Simulation sources and testbenches (e.g., `spi_state_tb.v`)
- `ip/` – Any IP cores used (if applicable)
- `bitstream/` – Bitstream files for FPGA programming (`*.bit`)
- `runs/` – Implementation and synthesis runs

---

## 🛠 How to Use

1. Open Vivado and click **File → Open Project**.
2. Navigate to this folder and open the `.xpr` file.
3. Use **Simulation** or **Program and Debug** to test or deploy the design.

---

## ⚙️ Board Info

- **FPGA Board**: Spartan-3E (or compatible)
- **Clock**: 50 MHz
- **Interfaces Used**:
  - SPI
  - ADC
  - DAC
  - Amplifier

---

## 📌 Notes

- Ensure your XDC file correctly maps the I/O pins based on your development board.
- This folder is mainly for FPGA implementation and not just simulation.
- All Verilog files used here are also available in the main source directory.

---


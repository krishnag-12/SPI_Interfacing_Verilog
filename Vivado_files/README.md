# Vivado Files

This folder contains all the files generated and used by **Xilinx Vivado** for implementing the project **"SPI Protocol and Interfacing using Verilog"**.

These files are required to recreate, simulate, synthesize, and implement the design on FPGA hardware.

---

## 📁 Contents

### Main Files:
- `*.xpr` – Vivado project file (entry point to open your project)
- `*.jou` – Journal file (Vivado's internal log of executed commands)
- `*.log` – Project log file containing tool outputs and messages
- `*.str` – Strategy file containing synthesis/implementation strategies

---

## 🛠 How to Use

1. Open **Xilinx Vivado**.
2. Select **File → Open Project** and choose the `.xpr` file from this folder.
3. Run simulation, synthesis, and implementation as required.
4. Generate bitstream and program your FPGA board.

---

## ⚙️ Target Platform

- **FPGA Board**: Spartan-3E or compatible
- **Design Modules**:
  - SPI State Machine
  - ADC Interfacing
  - DAC Communication

---

## 📌 Notes

- Do **not delete or rename** the `.jou`, `.log`, or `.str` files—they help Vivado resume or regenerate your sessions.
- Pin constraints must be updated in the `.xdc` file according to your specific FPGA board.

---

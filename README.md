# RISC-V Otter: A Custom RISC-V Microprocessor

## Overview
RISC-V Otter is a custom microprocessor built with interrupt architecture, implemented in SystemVerilog, and deployed on an FPGA. This project showcases the design, implementation, and functionality of a RISC-V-based processor with custom enhancements to its instruction set and hardware for improved performance and adaptability.

The project includes multiple assembly programs that demonstrate the capabilities of the processor, such as handling interrupts, performing arithmetic computations, and solving real-world computational problems.

---

## Features
- **Interrupt Architecture:** Supports hardware interrupts for efficient event handling.
- **Custom Assembly Programs:** Includes examples for arithmetic, data manipulation, and interrupt handling.
- **FPGA Implementation:** Synthesized and tested using Xilinx Vivado on an FPGA board.
- **Optimized Design:** Modified instruction set and hardware for specific use cases and enhanced performance.

---

## Project Structure
RISC-V-Otter/ ├── src/ # SystemVerilog source files for the processor ├── asm/ # Custom assembly programs ├── sim/ # Testbenches for simulation ├── docs/ # Design documentation and diagrams ├── constraints/ # FPGA constraints files ├── build/ # Scripts for synthesis and implementation └── README.md # Project overview and usage instructions

yaml
Copy code

---

## Getting Started

### Prerequisites
- **Hardware:** FPGA development board (tested with [your FPGA board model])
- **Software:**
  - Xilinx Vivado for synthesis and simulation
  - Assembly tools for RISC-V programming ([specific assembler or emulator if applicable])

### Setup Instructions
1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/riscv-otter.git
   cd riscv-otter
Open the project in Xilinx Vivado:

Navigate to the build/ directory.
Use the included TCL scripts or manually load the project.
Compile and upload the design to your FPGA board.

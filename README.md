# 💻 MIPS 32 Microprocessor (Single-Cycle) in VHDL

This repository contains the hardware implementation of a 32-bit Single-Cycle MIPS microprocessor. The project was developed in **VHDL** and validated through synthesis and implementation using the **Xilinx Vivado** environment, ready for testing on an FPGA development board.

## 📌 Project Description

The processor is capable of fetching, decoding, and executing a core subset of instructions from the MIPS32 architecture. As a hardware validation test, a program (written in machine code) is loaded into the processor's ROM memory, calculating the **sum of numbers that are powers of 2 from a given array, conditionally restricted to the interval $[a, b]$**.

### Implemented Instruction Set
The architecture supports the decoding and execution of the following instructions (R-Type, I-Type, and J-Type):
* **Arithmetic and logical:** `add`, `and`, `slt`, `sll`, `addi`
* **Memory access:** `lw`, `sw`
* **Control flow (Branches/Jumps):** `beq`, `bne`, `j`

> **Note:** Compared to the classic Single-Cycle MIPS datapath, the control unit and branch address selection logic were custom extended to support the `bne` (Branch Not Equal) instruction.

## ⚙️ Hardware Architecture

The project is modularly structured, with each stage of instruction execution having its dedicated VHDL component:

* `IFetch.vhd` (Instruction Fetch) - Manages the Program Counter (PC) and ROM memory.
* `IDecode.vhd` (Instruction Decode) - Contains the Register File and the sign-extension module.
* `EX.vhd` (Execution Unit) - Implements the Arithmetic Logic Unit (ALU) and branch address calculation.
* `MEM.vhd` (Data Memory) - Manages the interface with the RAM data memory.
* `UC.vhd` (Control Unit) - Decodes the opcode and generates the control signals for the entire datapath.
* `test_env.vhd` (Top-Level) - Instantiates and interconnects all components above, mapping I/O ports to the FPGA board pins (Buttons, Switches, LEDs, 7-Segment Display).

## 🚀 Testing Algorithm (Software)

The program natively run by the processor implements the following logic (C++ equivalent):
```cpp
int a = 2, b = 90, n = 7;
int x[] = {0, 1, 2, 3, 256, 14, 16};
int sum = 0;

for (int i = 0; i < n; i++) {
    int val = x[i]; 
    if (val >= a && val <= b && val > 0) {
        if ((val & (val - 1)) == 0) { // Check power of 2
            sum += val;
        }
    }
}
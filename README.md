# 💻 MIPS 32 Microprocessor (Single-Cycle & Pipeline)

This repository contains the hardware implementation of a 32-bit MIPS microprocessor, developed in **VHDL** and validated on **Artix-7 FPGA** (Nexys A7 board) using **Xilinx Vivado**. The project has evolved from a foundational Single-Cycle architecture to a high-performance 5-stage Pipelined architecture.

## 📌 Project Evolution

### Phase 1: Single-Cycle Architecture
* **Design:** Executes one instruction per clock cycle.
* **Datapath:** Implements the classic 5-stage execution path (IF, ID, EX, MEM, WB) compressed into a single cycle.
* **Extension:** The control unit and branch logic were extended to support `bne` (Branch Not Equal) instructions.

### Phase 2: Pipelined Architecture
* **Design:** Implements a 5-stage pipeline (IF, ID, EX, MEM, WB) to allow concurrent execution of up to 5 instructions.
* **Performance:** Significant increase in clock frequency by reducing the critical path through pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB).
* **Hazard Resolution:** * **Data Hazards (RAW):** Resolved via software by inserting `NoOp` (pseudo-instruction `sll $0, $0, 0`) and setting Register File writes on the falling edge of the clock.
    * **Control Hazards:** Resolved by inserting 3 `NoOp` delay slots for branches and 1 `NoOp` for jumps to prevent pipeline flush errors.

## ⚙️ Hardware Architecture Components

The design is modular, allowing easy transition between architectures:

* `IFetch.vhd`: Manages the PC and Instruction ROM (contains the test program in machine code).
* `IDecode.vhd`: Implements the Register File and signal distribution. In the Pipelined version, the `RegDst` MUX was relocated to the `EX` stage to optimize hazard handling.
* `EX.vhd`: Execution Unit containing the ALU and branch address calculator.
* `MEM.vhd`: Data Memory unit (RAM) for storage and loading operations.
* `UC.vhd`: Main Control Unit, decoding opcodes into control signals.
* `test_env.vhd` (Top-Level): Orchestrates the pipeline stages, instantiates the pipeline registers, and maps inputs (MPG for stepping) and outputs (SSD for status monitoring).

## 🚀 Testing Logic
The processor runs a program designed to solve a conditional accumulation problem:
1. **Filtering:** Selects numbers within the interval [a, b] that are also powers of 2.
2. **Execution:** Performs the sum in a loop using `beq`/`bne` for branching.
3. **Verification:** The sum is stored in memory and displayed on the board's 7-segment display.

[Image of MIPS pipeline datapath]

## 🛠 Usage
1. **Simulation:** Use the provided `test_env` to run behavioral simulations in Vivado. The `MPG` (MonoPulse Generator) component is essential for step-by-step execution to trace signal propagation through pipeline stages.
2. **FPGA Implementation:**
    * Program the `.bit` file onto the Nexys A7 board.
    * Use `btn(0)` to trigger the clock (step-by-step execution).
    * Use the `sw(7:5)` switches to multiplex different signals (`Instruction`, `RD1`, `ALURes`, etc.) to the 7-segment display for real-time debugging.
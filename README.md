# Generic N-bit Hierarchical ALU

## Overview

This repository contains a fully parameterized, hierarchical **N-bit Arithmetic Logic Unit (ALU)** implemented in **Verilog**.

The design emphasizes:

* **Modularity**
* **Scalability**
* **Reusability**
* **Robust verification using SystemVerilog Assertions (SVA)**

Each functional block is implemented as an independent module, enabling easier testing, debugging, and integration into larger **SoC (System on Chip)** architectures.

---

## Architecture

The ALU is implemented using a **hierarchical modular structure**.
Each functional group is encapsulated in its own module, allowing independent unit testing and flexible system integration.

### Functional Units

#### `adder_subtractor`

Performs **N-bit addition and subtraction**.

Features:

* Carry-Out detection
* Overflow detection
* Shared arithmetic datapath

#### `logic_unit`

Implements standard **bitwise logic operations**:

* AND
* OR
* XOR
* NOR
* NAND
* XNOR

#### `shifter_unit`

Performs **bit shifting operations**:

* Logical Shift Left
* Logical Shift Right
* Arithmetic Shift Right

---

## Technical Features

### Parameterized Design

The ALU bit width is controlled by a single parameter:

```verilog
parameter WIDTH = N;
```

The design dynamically adapts internal logic using:

```verilog
$clog2(WIDTH)
```

This allows the shifter and control logic to **scale automatically** with the defined width.

---

### Synchronized Status Flags

The ALU provides the following status flags:

| Flag | Meaning       |
| ---- | ------------- |
| Z    | Zero Flag     |
| N    | Negative Flag |
| C    | Carry Flag    |
| V    | Overflow Flag |

The flags are **synchronized with the final multiplexer output**, ensuring they represent the **actual selected operation result**, and preventing incorrect readings from inactive functional units.

---

### Formal Verification (SVA)

The design integrates **SystemVerilog Assertions (SVA)** for real-time verification.

Assertions verify:

* Mathematical correctness of arithmetic operations
* Proper overflow detection
* Flag consistency
* Correct output selection

These checks run automatically during simulation and immediately flag violations.

---

## Project Structure

```
GENERIC-ALU-Project/

├── src/                      # Source Files (Design Under Test)
│   ├── alu_generic.v         # Top-level ALU module
│   ├── adder_subtractor.v    # Arithmetic unit
│   ├── logic_unit.v          # Logic operations
│   └── shifter_unit.v        # Shift operations
│
├── tb/                       # Verification Environment
│   ├── alu_dual_system_tb.v  # Full ALU system testbench
│   ├── adder_subtractor_tb.v
│   ├── logic_unit_tb.v
│   └── shifter_unit_tb.v
│
└── README.md
```

---

## Simulation & Verification

The project is compatible with:

* **Icarus Verilog**
* **GTKWave**

### 1. Compilation

Compile the design with SystemVerilog support:

```bash
iverilog -g2012 -o alu_sim src/*.v tb/alu_dual_system_tb.v
```

### 2. Execution

Run the simulation and check assertions:

```bash
vvp alu_sim
```

### 3. Waveform Analysis

View the signal timing diagrams:

```bash
gtkwave alu_dual_results.vcd
```

This allows detailed inspection of signal transitions and verification of ALU behavior.

---

## Design Goals

* Create a **scalable ALU architecture**
* Encourage **clean modular hardware design**
* Demonstrate **assertion-based verification**
* Provide a reusable **educational reference implementation**

---

## Author

**Guy Ben Moshe**
Electrical Engineering Student

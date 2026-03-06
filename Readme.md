# Multi-Master Shared Memory System with Round-Robin Arbitration (FPGA Implementation)

## Overview
This project implements a **multi-master shared memory subsystem** using a **Round-Robin arbitration algorithm** to ensure fair access to memory among multiple requesting masters.

The design was developed in **Verilog RTL**, verified through **simulation using Icarus Verilog and GTKWave**, and successfully **implemented on an Artix-7 FPGA (Nexys A7-100T)** using Vivado.

The system ensures:
- Fair scheduling of memory requests
- Starvation-free arbitration
- Correct read/write operations through synchronous RAM
- Efficient FPGA resource utilization

---

## Key Features
- Parameterized **multi-master architecture**
- **Round-Robin arbitration** for fair memory access
- **Valid-Ready handshake protocol**
- **Synchronous shared memory**
- **Self-checking testbench with scoreboard**
- Simulation verification using **GTKWave**
- FPGA deployment on **Artix-7**
- Timing-clean implementation at **100 MHz**

---

## System Architecture


Components:

1. Multiple masters generating read/write requests
2. Round-Robin arbiter selecting one master per cycle
3. Multiplexer routing selected master signals
4. Shared synchronous memory
5. Performance monitoring counters

---

## Round-Robin Arbitration

The arbiter ensures **fair access among all requesting masters**.

Example for three masters:

| Cycle | Requests | Granted Master |
|------|----------|----------------|
| 1 | 111 | Master 0 |
| 2 | 111 | Master 1 |
| 3 | 111 | Master 2 |
| 4 | 111 | Master 0 |

This guarantees that **no master starves**.

---

## Memory Design

The shared memory is implemented as **synchronous RAM**.

### Interface
Inputs:
- `clk`
- `we`
- `addr`
- `wdata`

Output:
- `rdata`

The memory has **1-cycle read latency**.

During FPGA synthesis, the memory was inferred as **distributed RAM (LUTRAM)**.

---

## Simulation and Verification

Functional verification was performed using:

- **Icarus Verilog**
- **GTKWave**

### Simulation Flow

```bash
iverilog -o sim.out RTL/*.v TB/*.v
vvp sim.out
gtkwave wave.vcd
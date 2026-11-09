# ALU UVM testbench

A UVM 1.2 testbench around a small ALU, written while working through *The UVM Primer* (Ray Salemi), chapters 9 to 18.
The testbench keeps the book's structure for its `tinyalu`: an interface that holds the bus functional model, monitors
that push transactions out on analysis ports, a scoreboard and a coverage collector as subscribers, a tester and a
driver joined by a TLM FIFO, and tests that choose the tester through the factory. The code is mine, written from the
book's figures rather than copied, and the section "Where it differs from the book" lists what I changed.

## The DUT

[`rtl/alu.sv`](rtl/alu.sv): 8-bit operands, 16-bit result, four operations (`OP_ADD`, `OP_AND`, `OP_XOR`, `OP_MUL`).
`start` latches the command. Add, and, xor are done in the next clock; multiply goes through two more states
(`MUL_C1`, `MUL_C2`); `done` is high for one clock in `DONE`. The command is a packed struct `{op, a, b}` from
[`alu_pkg`](tb/alu_pkg.svh), and the DUT connects to the interface through a `dut` modport.

## Testbench

```
alu_tb_top                clk, reset_n, config_db set of the interface, run_test()
└── alu_if                signals, clocking block, send_op() task, and two always blocks
    │                     that hand every new command and result to the monitors
    └── env
        ├── tester ──put──▶ uvm_tlm_fifo ──get──▶ driver ──▶ alu_if.send_op()
        ├── command_monitor ──ap──┬──▶ coverage          covergroup sampled in write()
        │                        └──▶ scoreboard.cmd_f  uvm_tlm_analysis_fifo
        └── result_monitor  ──ap─────▶ scoreboard        compares with expected_result()
```

* **Tester and driver** are two components. The tester builds commands and `put`s them into a `uvm_tlm_fifo`; the
  driver `get`s them and drives the bus through the clocking block. The blocking `get` is the back-pressure: while the
  driver is busy the tester waits.
* **The monitors have no virtual interface.** Each monitor registers itself in the interface during `build_phase`, and
  the interface calls `write_to_monitor()` when `start` or `done` rises. One `config_db` entry, the interface, is all
  the testbench needs.
* **Scoreboard**: a `uvm_subscriber #(result_t)` with a `uvm_tlm_analysis_fifo` for the commands. Every result is
  matched with the command at the front of the FIFO and compared with `expected_result()`. Pass and fail counts are
  printed in `report_phase`.
* **Coverage**: the operation, operand bins (zero, low, mid, high, max), `a == b`, carry out of an add, and a cross of
  operation × a × b. The carry coverpoint extends both operands to 9 bits before adding; without that the sum is
  truncated to 8 bits before the compare and the bin never hits.
* **Tests**: `random_test` runs the env as built, with `random_tester`. `add_test` swaps in `add_tester` with
  `set_type_override`, so both tests run the same env.

## Results

Both tests run 10,000 commands. The logs are in [`sim/`](sim/).

| Test | Commands | Scoreboard | `cg_alu` coverage | UVM_ERROR / UVM_FATAL |
|---|---|---|---|---|
| [`random_test`](sim/random_test_pass.log) | 10,000 | PASS 10000/10000 | 94.50 % | 0 / 0 |
| [`add_test`](sim/add_test_pass.log) | 10,000 | PASS 10000/10000 | 74.33 % | 0 / 0 |

`add_test` drives one operation, so most of its cross is empty by design. In `random_test` the missing bins are in
the operation × a × b cross: `zero` and `max` are one value out of 256 for each operand, and 10,000 random commands
do not reach every pairing of them with every operation.

## Where it differs from the book

1. The DUT is my own SystemVerilog module, one FSM with two multiply states and a packed command struct. The book's
   `tinyalu` is VHDL, with a single-cycle block and a three-cycle multiplier.
2. `clk` and `reset_n` are inputs of the interface and come from `alu_tb_top`. The book's BFM makes its own clock and
   has a `reset_alu()` task.
3. The interface has a clocking block, `send_op()` drives through it, and the DUT sits on a `dut` modport.
4. The analysis ports are built in `new()`, not in `build_phase`.
5. The coverage model is mine: operand range bins, `a == b` and the carry bin, instead of the book's bins on
   operation sequences.

## Running

Vivado xsim with the UVM 1.2 library that ships with it:

```
xvlog -sv -L uvm -i tb tb/alu_pkg.svh rtl/alu.sv tb/alu_if.sv tb/alu_tb_top.sv
xelab -L uvm alu_tb_top -s sim --debug off
xsim sim -testplusarg UVM_TESTNAME=random_test -runall
xsim sim -testplusarg UVM_TESTNAME=add_test -runall
```

## Not here yet

No sequences, sequencer or agent: the tester is a component that makes the commands itself. That is the next chapter
of the book and the next change to this repo. Coverage is not closed, and there is no SVA on the `start` / `done`
handshake.

## Layout

```
rtl/alu.sv
tb/alu_pkg.svh          types, the command struct, the class includes in dependency order
tb/alu_if.sv            interface: signals, clocking block, send_op(), the two monitor hooks
tb/alu_tb_top.sv
tb/alu_classes/         tester, driver, monitors, scoreboard, coverage, env, tests
sim/                    xsim logs of the two tests
```

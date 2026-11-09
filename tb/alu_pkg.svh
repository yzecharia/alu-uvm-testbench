package alu_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    localparam RAND_TEST_NUM = 1000;

    typedef enum logic [1:0] {OP_ADD, OP_AND, OP_XOR, OP_MUL} alu_op_e;
    typedef struct packed {
        alu_op_e op;
        logic [7:0] a;
        logic [7:0] b;
    } command_t;
    typedef logic [15:0] result_t;
    typedef enum logic [1:0] {IDLE, MUL_C1, MUL_C2, DONE} state_e;

    `include "alu_classes/command_monitor.svh"   // no deps on other classes
    `include "alu_classes/result_monitor.svh"    // no deps on other classes
    `include "alu_classes/coverage.svh"          // no class deps
    `include "alu_classes/scoreboard.svh"        // no class deps
    `include "alu_classes/driver.svh"            // no class deps (NEW: ch.18)
    `include "alu_classes/base_tester.svh"       // no class deps
    `include "alu_classes/random_tester.svh"     // extends base_tester
    `include "alu_classes/add_tester.svh"        // extends base_tester
    `include "alu_classes/env.svh"               // uses ALL monitors/cov/sb/driver/testers
    `include "alu_classes/random_test.svh"       // uses env, random_tester
    `include "alu_classes/add_test.svh"          // uses env, add_tester

endpackage : alu_pkg

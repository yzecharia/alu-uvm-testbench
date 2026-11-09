class coverage extends uvm_subscriber #(command_t);
    `uvm_component_utils(coverage)

    command_t cmd_in;

    covergroup cg_alu;
        cp_op: coverpoint cmd_in.op;
        cp_a: coverpoint cmd_in.a {
            bins zero = {0};
            bins low = {[1:15]};
            bins mid = {[16:239]};
            bins high = {[240:254]};
            bins max = {255};
        }
        cp_b: coverpoint cmd_in.b {
            bins zero = {0};
            bins low = {[1:15]};
            bins mid = {[16:239]};
            bins high = {[240:254]};
            bins max = {255};
        }
        cp_a_eq_b: coverpoint (cmd_in.a == cmd_in.b) {
            bins equal = {1};
            bins different = {0};
        }
        cp_carry: coverpoint ((cmd_in.op == OP_ADD) && ({1'b0, cmd_in.a} + {1'b0, cmd_in.b} > 9'hFF)) {
            bins carry = {1};
            bins no_carry = {0};
        }
        cross_op_a_b: cross cp_op, cp_a, cp_b;
    endgroup : cg_alu

    function new(string name = "coverage", uvm_component parent = null);
        super.new(name, parent);
        cg_alu = new();
    endfunction : new

    function void write(command_t t);
        cmd_in = t;
        cg_alu.sample();
    endfunction : write

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Coverage is: %0.2f%%", cg_alu.get_inst_coverage()), UVM_LOW);
    endfunction : report_phase
endclass : coverage
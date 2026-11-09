class scoreboard extends uvm_subscriber #(result_t);
    `uvm_component_utils(scoreboard)

    uvm_tlm_analysis_fifo #(command_t) cmd_f;

    int pass, fail;

    function new(string name = "scoreboard", uvm_component parent = null);
        super.new(name, parent);
        pass = 0;
        fail = 0;
    endfunction : new

    function void build_phase(uvm_phase phase);
        cmd_f = new("cmd_f", this);  // construct analysis_fifo (new, not factory)
    endfunction : build_phase

    function void write(result_t t);
        command_t cmd_in;
        result_t exp_res;

        if (!cmd_f.try_get(cmd_in)) begin
            `uvm_error(get_type_name(), "Failed to get command from tlm");
            fail++;
        end else begin
            exp_res = res_calc(cmd_in);
            if (exp_res === t) pass++;
            else fail++;
        end
    endfunction : write

    function result_t res_calc(command_t cmd_in);
        case(cmd_in.op)
            OP_ADD: return cmd_in.a + cmd_in.b;
            OP_AND: return cmd_in.a & cmd_in.b;
            OP_XOR: return cmd_in.a ^ cmd_in.b;
            OP_MUL: return cmd_in.a * cmd_in.b;
        endcase 
    endfunction : res_calc

    function void report_phase(uvm_phase phase);
        if (fail == 0) `uvm_info(get_type_name(), $sformatf("Test PASS: %0d/%0d", pass, pass+fail), UVM_LOW)
        else `uvm_info(get_type_name(), $sformatf("Test FAIL: %0d/%0d", fail, pass+fail), UVM_LOW)
    endfunction : report_phase

endclass : scoreboard
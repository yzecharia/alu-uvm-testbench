module alu_tb_top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import alu_pkg::*;

    logic clk, reset_n;

    alu_if aluif(.clk(clk), .reset_n(reset_n));
    alu dut (.bus(aluif.dut));

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset_n = 1'b0;
        repeat (3) begin
            @(posedge clk);
        end
        reset_n = 1'b1;
    end

    initial begin
        uvm_config_db #(virtual alu_if)::set(null, "*", "aluif", aluif);
        run_test();
    end

endmodule : alu_tb_top
interface alu_if (input clk, reset_n);
    import alu_pkg::*;

    command_monitor command_monitor_h;
    result_monitor result_monitor_h;

    
    command_t cmd;
    result_t res;
    logic start, done;

    bit new_command;
    bit new_result;

    modport dut (input cmd, clk, reset_n, start, output res, done);
    modport tb (clocking cb);

    clocking cb @(posedge clk);
        default input #1step output #1;
        input res, reset_n, done;
        output cmd, start;
    endclocking : cb

    initial start = 1'b0;

    always @(posedge clk) begin : write_command
        if (!start)
            new_command = 1'b1;
        else begin
            if (new_command) begin
                command_monitor_h.write_to_monitor(cmd);
                new_command = 1'b0;
            end
        end
    end

    always @(posedge clk) begin : write_result
        if (!done)
            new_result = 1'b1;
        else begin
            if (new_result) begin
                result_monitor_h.write_to_monitor(res);
                new_result = 1'b0;
            end
        end
    end

    task send_op (input command_t cmd_in);
        cb.cmd <= cmd_in;
        cb.start <= 1'b1;
        @(cb iff cb.done);
        cb.start <= 1'b0;
        @(cb);
    endtask : send_op
endinterface : alu_if
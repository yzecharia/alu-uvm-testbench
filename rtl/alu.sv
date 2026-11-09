import alu_pkg::*;
module alu (alu_if.dut bus);

    state_e state, next_state;

    logic [15:0] res_reg, res_comb;
    logic [7:0] a_reg, b_reg;
    logic op_valid;


    always_ff @(posedge bus.clk) begin
        if (!bus.reset_n) begin
            state <= IDLE;
            res_reg <= '0;
        end else begin
            state <= next_state;
            if (state == IDLE && bus.start) begin
                case (bus.cmd.op)
                    OP_ADD: res_reg <= bus.cmd.a + bus.cmd.b;
                    OP_AND: res_reg <= bus.cmd.a & bus.cmd.b;
                    OP_XOR: res_reg <= bus.cmd.a ^ bus.cmd.b;
                    OP_MUL: res_reg <= bus.cmd.a * bus.cmd.b;
                    default: res_reg <= '0;
                endcase
            end
        end
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (bus.start) begin
                    case (bus.cmd.op)
                        OP_ADD, OP_AND, OP_XOR: next_state = DONE;
                        OP_MUL: next_state = MUL_C1;
                        default: next_state = IDLE;
                    endcase
                end
            end
            MUL_C1: next_state = MUL_C2;
            MUL_C2: next_state = DONE;
            DONE: next_state = IDLE;
        endcase
    end

    assign bus.done = (state == DONE);
    assign bus.res = res_reg;
endmodule : alu
virtual class base_tester extends uvm_component;
    `uvm_component_utils(base_tester)

    uvm_put_port #(command_t) put_port_h;

    function new(string name = "base_tester", uvm_component parent = null);
        super.new(name, parent);
        put_port_h = new("put_port_h", this);
    endfunction : new

    task run_phase(uvm_phase phase);
        command_t cmd;
        phase.raise_objection(this);
            repeat (10000) begin
                cmd = '{
                    op: get_op(),
                    a: get_operand(),
                    b: get_operand()
                };
                put_port_h.put(cmd);
            end
            #500;
        phase.drop_objection(this);
    endtask : run_phase

    pure virtual function alu_op_e  get_op();
    pure virtual function logic [7:0]  get_operand();

endclass : base_tester
class driver extends uvm_component;
    `uvm_component_utils(driver)

    uvm_get_port #(command_t) get_port_h;

    virtual alu_if aluif;

    function new (string name = "driver", uvm_component parent = null);
        super.new(name, parent);
        get_port_h = new("get_port_h", this);
    endfunction : new

    function void build_phase(uvm_phase phase);
        if (!uvm_config_db #(virtual alu_if)::get(this, "", "aluif", aluif))
            $fatal("Failed to get aluif");
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        command_t cmd;
        @(aluif.cb iff aluif.cb.reset_n);
        forever begin
            get_port_h.get(cmd);
            aluif.send_op(cmd);
        end
    endtask : run_phase

endclass : driver
class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

    uvm_analysis_port #(command_t) ap;

    function new(string name = "command_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction : new

    function void build_phase(uvm_phase phase);
        virtual alu_if aluif;
        if (!uvm_config_db #(virtual alu_if)::get(this, "", "aluif", aluif))
            `uvm_fatal("NOALUIF", "Failed to get aluif");
        aluif.command_monitor_h = this;
    endfunction : build_phase

    function void write_to_monitor(command_t cmd);
        ap.write(cmd);
    endfunction : write_to_monitor

endclass : command_monitor
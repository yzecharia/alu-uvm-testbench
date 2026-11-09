class result_monitor extends uvm_component;
    `uvm_component_utils(result_monitor)

    uvm_analysis_port #(result_t) ap;

    function new(string name = "result_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction : new

    function void build_phase(uvm_phase phase);
        virtual alu_if aluif;
        if (!uvm_config_db #(virtual alu_if)::get(this, "", "aluif", aluif))
            $fatal("Failed to get aluif");
        aluif.result_monitor_h = this;
    endfunction : build_phase

    function void write_to_monitor(result_t res);
        ap.write(res);
    endfunction : write_to_monitor
endclass : result_monitor
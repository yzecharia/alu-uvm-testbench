class random_test extends uvm_test;
    `uvm_component_utils(random_test)
    
    env env_h;

    function new(string name="random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env_h = env::type_id::create("env", this);
    endfunction : build_phase

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Random Test Finished", UVM_LOW);
    endfunction : report_phase
endclass : random_test
class add_test extends uvm_test;
    `uvm_component_utils(add_test)

    env env_h;

    function new(string name = "add_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        random_tester::type_id::set_type_override(add_tester::get_type());
        env_h = env::type_id::create("env_h", this);
    endfunction : build_phase

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "add_test FINISHED", UVM_LOW);
    endfunction : report_phase
endclass : add_test
class env extends uvm_env;
    `uvm_component_utils(env)

    coverage coverage_h;
    scoreboard scoreboard_h;
    command_monitor command_monitor_h;
    result_monitor result_monitor_h;
    random_tester tester_h;
    uvm_tlm_fifo #(command_t) cmd_f;
    driver driver_h;

    function new(string name = "env", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        cmd_f = new("cmd_f", this);  // construct tlm_fifo (new, not factory)
        coverage_h = coverage::type_id::create("coverage_h", this);
        scoreboard_h = scoreboard::type_id::create("scoreboard_h", this);
        tester_h = random_tester::type_id::create("tester_h", this);
        driver_h = driver::type_id::create("driver_h", this);
        command_monitor_h = command_monitor::type_id::create("command_monitor_h", this);
        result_monitor_h = result_monitor::type_id::create("result_monitor_h", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        command_monitor_h.ap.connect(coverage_h.analysis_export);
        command_monitor_h.ap.connect(scoreboard_h.cmd_f.analysis_export);
        result_monitor_h.ap.connect(scoreboard_h.analysis_export);
        tester_h.put_port_h.connect(cmd_f.put_export);
        driver_h.get_port_h.connect(cmd_f.get_export);
    endfunction : connect_phase


endclass : env
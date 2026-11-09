class add_tester extends random_tester;
    `uvm_component_utils(add_tester)

    function new(string name = "add_tester", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual function alu_op_e get_op();
        return OP_ADD;
    endfunction : get_op
endclass : add_tester
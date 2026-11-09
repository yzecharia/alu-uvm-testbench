class random_tester extends base_tester;
    `uvm_component_utils(random_tester)

    function new(string name = "random_tester", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual function alu_op_e get_op();
        return alu_op_e'($urandom_range(0,3));
    endfunction : get_op

    virtual function logic [7:0] get_operand();
        return $urandom() & 8'hFF;
    endfunction : get_operand
endclass : random_tester
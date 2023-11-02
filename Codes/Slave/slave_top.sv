import uvm_pkg::*;
`include "uvm_macros.svh"
import slave_test_pkg::*;

module slave_top ();
    bit clk;
    localparam MEM_DEPTH = 256;

    slave_intf #(MEM_DEPTH) s_if(clk);
    slave DUT (s_if);

    initial begin
        clk = 1;
        forever 
            #1 clk = ~clk;
    end
    
    initial begin
        uvm_config_db #(virtual slave_intf #(MEM_DEPTH).slave_TEST)::set(null, "uvm_test_top", "slave_intf", s_if);
        run_test("slave_test");
    end
endmodule
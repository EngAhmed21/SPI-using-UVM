import uvm_pkg::*;
`include "uvm_macros.svh"
import RAM_test_pkg::*;

module RAM_top ();
    bit clk;
    localparam MEM_DEPTH = 256;

    RAM_intf #(MEM_DEPTH) R_if(clk);
    RAM DUT (R_if);
    bind RAM RAM_SVA SVA (R_if);

    initial begin
        $readmemh("RAM_data.dat", DUT.mem, 0, 255);
        clk = 1;
        forever 
            #1 clk = ~clk;
    end
    
    initial begin
        uvm_config_db #(virtual RAM_intf #(MEM_DEPTH).TEST)::set(null, "uvm_test_top", "RAM_intf", R_if);
        run_test("RAM_test");
    end
endmodule
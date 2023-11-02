import uvm_pkg::*;
`include "uvm_macros.svh"
import wrapper_test_pkg::*;

module wrapper_top ();
    bit clk;
    localparam MEM_DEPTH = 256;

    initial begin
        $readmemh("RAM_data.dat", DUT.MEMORY.mem, 0, 255);
        clk = 1;
        forever 
            #1 clk = ~clk;
    end

    RAM_intf #(MEM_DEPTH) R_if (clk);
    slave_intf #(MEM_DEPTH) S_if (clk);
    wrapper_intf #(MEM_DEPTH) W_if (clk);

    wrapper DUT (W_if);
    bind RAM RAM_SVA SVA (R_if);
    
    initial begin
        uvm_config_db #(virtual RAM_intf.TEST)::set(null, "uvm_test_top", "RAM_if", R_if);
        uvm_config_db #(virtual slave_intf.TEST)::set(null, "uvm_test_top", "slave_if", S_if);
        uvm_config_db #(virtual wrapper_intf.TEST)::set(null, "uvm_test_top", "wrapper_if", W_if);
        run_test("wrapper_test");
    end

    assign S_if.rst_n         = DUT.rst_n;
    assign S_if.SS_n          = DUT.SS_n;
    assign S_if.MOSI          = DUT.MOSI;
    assign S_if.rx_valid      = DUT.rx_valid;
    assign S_if.rx_data       = DUT.rx_data;
    assign S_if.tx_valid      = DUT.tx_valid;
    assign S_if.tx_data       = DUT.tx_data;
    assign S_if.MISO          = DUT.MISO;

    assign R_if.rst_n         = DUT.rst_n;
    assign R_if.rx_valid      = DUT.rx_valid;
    assign R_if.rx_data       = DUT.rx_data;
    assign R_if.tx_valid      = DUT.tx_valid;
    assign R_if.tx_data       = DUT.tx_data;
endmodule
interface wrapper_intf #(parameter MEM_DEPTH = 256) (input clk);
    logic rst_n, SS_n, MOSI, MISO;

    modport DUT (
    input clk, rst_n, SS_n, MOSI,
    output MISO
    );

    modport TEST (
    input clk, MISO,
    output rst_n, SS_n, MOSI
    );
endinterface //
interface slave_intf #(parameter MEM_DEPTH = 256) (input clk);
    localparam ADDR_SIZE = $clog2(MEM_DEPTH);

    logic rst_n, SS_n, MOSI, rx_valid, tx_valid, MISO;
    logic [ADDR_SIZE + 1 : 0] rx_data;
    logic [ADDR_SIZE - 1 : 0] tx_data; 

    modport DUT (
    input clk, rst_n, SS_n, MOSI, tx_valid, tx_data,
    output rx_valid, rx_data, MISO
    );

    modport TEST (
    input clk, rx_valid, rx_data, MISO,
    output rst_n, SS_n, MOSI, tx_valid, tx_data
    );
endinterface //
interface RAM_intf #(parameter MEM_DEPTH = 256) (input clk);
    localparam ADDR_SIZE = $clog2(MEM_DEPTH);

    logic rst_n, rx_valid, tx_valid;
    logic [ADDR_SIZE + 1 : 0] rx_data;
    logic [ADDR_SIZE - 1 : 0] tx_data;

    modport DUT (
    input  clk, rst_n, rx_valid, rx_data,
    output tx_data, tx_valid
    );

    modport TEST (
    input  clk, tx_data, tx_valid,
    output rst_n, rx_valid, rx_data
    );
endinterface //
module RAM_SVA (RAM_intf.DUT R_if);
    localparam MEM_DEPTH = R_if.MEM_DEPTH;
	localparam ADDR_SIZE = $clog2(MEM_DEPTH);

	logic clk, rst_n, rx_valid, tx_valid;
	logic [ADDR_SIZE + 1 : 0] rx_data;
    logic [ADDR_SIZE - 1 : 0] tx_data, wr_addr, rd_addr;
    logic [ADDR_SIZE - 1 : 0] mem_test [MEM_DEPTH];

	assign clk 		= R_if.clk;
	assign rst_n 	= R_if.rst_n;
	assign rx_valid = R_if.rx_valid;
	assign rx_data 	= R_if.rx_data;
	assign tx_data 	= R_if.tx_data;
	assign tx_valid = R_if.tx_valid;

    // Check the reset values
    always_comb begin
        if (!rst_n) begin
            rstn_tx_data_a:  assert final (~(|tx_data));
            rstn_tx_a:    assert final (!tx_valid);
        end
    end

    // Check the value of tx_valid when the operation is read data
    property rd_data_tx_pr;
        @(posedge clk) disable iff(!rst_n) ((rx_valid) && (&(rx_data [ADDR_SIZE + 1 : ADDR_SIZE]))) |=> (tx_valid);
    endproperty
    rd_data_tx_a:         assert property (rd_data_tx_pr);
    rd_data_tx_cov:       cover  property (rd_data_tx_pr);

    // Check the value of tx_valid when the operation isn't read data 
    property not_rd_data_tx_pr;
        @(posedge clk) disable iff(!rst_n) ((rx_valid) && (!(&(rx_data [ADDR_SIZE + 1 : ADDR_SIZE])))) |=> (!tx_valid);
    endproperty
    not_rd_data_tx_a:    assert property (not_rd_data_tx_pr);
    not_rd_data_tx_cov:  cover  property (not_rd_data_tx_pr);

    // Check tx_data when the operation is read data
    property rd_data_tx_data_pr;
        @(posedge clk) disable iff(!rst_n) ((rx_valid) && (&(rx_data [ADDR_SIZE + 1 : ADDR_SIZE]))) |=> (tx_data === $past(mem_test [$past(rd_addr)]));
    endproperty
    rd_data_tx_data_a:      assert property (rd_data_tx_data_pr);
    rd_data_tx_data_cov:    cover  property (rd_data_tx_data_pr);

    // Check that the value of tx_data doesn't change if the operation isn't read data
    property no_change_tx_data_pr;
        @(posedge clk) disable iff(!rst_n) ((!rx_valid) || (!(&(rx_data [ADDR_SIZE + 1 : ADDR_SIZE])))) |=> (tx_data === $past(tx_data));
    endproperty
    no_change_tx_data_a:     assert property (no_change_tx_data_pr);
    no_change_tx_data_cov:   cover  property (no_change_tx_data_pr);

    // Reference
    initial begin
        $readmemh("RAM_data.dat", mem_test, 0, 255);
    end
    always_comb begin
        if (!rst_n) begin
            wr_addr = 0;
            rd_addr = 0;
        end
        else if (rx_valid) 
            case (rx_data [ADDR_SIZE + 1 : ADDR_SIZE])
                2'b00:  wr_addr            = rx_data [ADDR_SIZE - 1 : 0];
                2'b01:  mem_test [wr_addr] = rx_data [ADDR_SIZE - 1 : 0];
                2'b10:  rd_addr            = rx_data [ADDR_SIZE - 1 : 0];
            endcase
    end
endmodule
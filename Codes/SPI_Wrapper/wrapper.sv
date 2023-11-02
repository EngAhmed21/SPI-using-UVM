module wrapper (wrapper_intf.DUT W_if);
  localparam MEM_DEPTH = W_if.MEM_DEPTH;
	localparam ADDR_SIZE = $clog2(MEM_DEPTH);

  logic clk, rst_n, SS_n, MOSI, rx_valid, tx_valid, MISO;
  logic [ADDR_SIZE - 1 : 0] tx_data;
  logic [ADDR_SIZE + 1 : 0] rx_data;

  slave_intf #(MEM_DEPTH) S_if (clk);
  RAM_intf   #(MEM_DEPTH) R_if (clk);

  assign clk            = W_if.clk;
  assign rst_n          = W_if.rst_n;
  assign SS_n           = W_if.SS_n;
  assign MOSI           = W_if.MOSI;
  assign W_if.MISO      = MISO;

  assign S_if.rst_n     = rst_n;  
  assign S_if.SS_n      = SS_n;
  assign S_if.MOSI      = MOSI;
  assign S_if.tx_valid  = tx_valid;
  assign S_if.tx_data   = tx_data;
  assign rx_valid       = S_if.rx_valid;
  assign rx_data        = S_if.rx_data;
  assign MISO           = S_if.MISO;

  assign R_if.rst_n     = rst_n;  
  assign R_if.rx_valid  = rx_valid;
  assign R_if.rx_data   = rx_data;
  assign tx_valid       = R_if.tx_valid;
  assign tx_data        = R_if.tx_data;
  
  slave SLAVE (S_if);
  RAM MEMORY  (R_if);

  // Assertions for the internal signals
	`ifdef WRAPPER_SIM 
		// Check reset values
		always_comb begin
			if (!rst_n) begin
				wrap_rst_tx_valid_a:	assert final (tx_valid == 0);
				wrap_rst_rx_valid_a:	assert final (rx_valid == 0);
				wrap_rst_tx_data_a:   assert final (tx_data  == 0);
				wrap_rst_rx_data_a:	  assert final (rx_data  == 0);
			end
		end

    // Check rx_valid
    property wrap_rx_valid_pr;
      @(posedge clk) disable iff(!rst_n) (SS_n) ##1 (!SS_n) [*12] |=> (rx_valid);  
    endproperty
    wrap_rx_valid_a:	  assert property (wrap_rx_valid_pr);
		wrap_rx_valid_cov:  cover  property (wrap_rx_valid_pr);

    // Check tx_valid
    property wrap_tx_valid_pr;
      @(posedge clk) disable iff(!rst_n) (SS_n) ##1 (!SS_n) [*12] ##1 ((!SS_n) && 
       ({$past(MOSI, 10), $past(MOSI, 9)} == 2'b11)) |=> (tx_valid);  
    endproperty
    wrap_tx_valid_a:	  assert property (wrap_tx_valid_pr);
		wrap_tx_valid_cov:  cover  property (wrap_tx_valid_pr);

    // Check rx_data
    property wrap_rx_data_pr;
      @(posedge clk) disable iff(!rst_n) (SS_n) ##1 (!SS_n) [*12] |=> (rx_data == 
       {$past(MOSI, 10), $past(MOSI, 9), $past(MOSI, 8), $past(MOSI, 7), 
       $past(MOSI, 6), $past(MOSI, 5), $past(MOSI, 4), $past(MOSI, 3),
       $past(MOSI, 2), $past(MOSI)});  
    endproperty
    wrap_rx_data_a:	   assert property (wrap_rx_data_pr);
		wrap_rx_data_cov:  cover  property (wrap_rx_data_pr);
	`endif 
endmodule

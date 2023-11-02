module RAM(RAM_intf.DUT R_if);
	localparam MEM_DEPTH = R_if.MEM_DEPTH;
	localparam ADDR_SIZE = $clog2(MEM_DEPTH);

	logic clk, rst_n, rx_valid, tx_valid;
	logic [ADDR_SIZE + 1 : 0] rx_data;
    logic [ADDR_SIZE - 1 : 0] tx_data;

	assign clk 				= R_if.clk;
	assign rst_n 			= R_if.rst_n;
	assign rx_valid 		= R_if.rx_valid;
	assign rx_data 			= R_if.rx_data;
	assign R_if.tx_data 	= tx_data;
	assign R_if.tx_valid 	= tx_valid;

	logic [ADDR_SIZE - 1 : 0] mem [MEM_DEPTH - 1 : 0];
	logic [ADDR_SIZE - 1 : 0] wr_addr, rd_addr;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			tx_data 	 <= 0;
			wr_addr  <= 0;
			rd_addr  <= 0;
		end
		else if (rx_valid)
			case (rx_data [ADDR_SIZE + 1 : ADDR_SIZE])
				2'b00:	wr_addr 	  <= rx_data [ADDR_SIZE - 1 : 0];						
				2'b01:	mem [wr_addr] <= rx_data [ADDR_SIZE - 1 : 0];
				2'b10:	rd_addr 	  <= rx_data [ADDR_SIZE - 1 : 0];
				2'b11:  tx_data 	  <= mem [rd_addr];
			endcase
	end

	always @(posedge clk, negedge rst_n) begin
		if (!rst_n)
			tx_valid <= 0;
		else if (rx_valid) 
			if (&(rx_data [ADDR_SIZE + 1 : ADDR_SIZE]))
				tx_valid <= 1;
			else
				tx_valid <= 0;
	end

	// Assertions for the internal signals
	`ifdef SIM
		// Check reset values
		always_comb begin
			if (!rst_n) begin
				rst_wr_addr_a:	assert final (wr_addr == 0);
				rst_rd_addr_a:	assert final (rd_addr == 0);
			end
		end

		// wr_addr
		property wr_addr_pr;
			@(posedge clk) disable iff(!rst_n) (((rx_valid) && (rx_data [ADDR_SIZE + 1 : ADDR_SIZE] == 2'b00))) |=> 
			 (wr_addr == $past(rx_data [ADDR_SIZE - 1 : 0]));
		endproperty
		wr_addr_a:	  assert property (wr_addr_pr);
		wr_addr_cov:  cover  property (wr_addr_pr);

		// rd_addr
		property rd_addr_pr;
			@(posedge clk) disable iff(!rst_n) (((rx_valid) && (rx_data [ADDR_SIZE + 1 : ADDR_SIZE] == 2'b10))) |=> 
			 (rd_addr == $past(rx_data [ADDR_SIZE - 1 : 0]));
		endproperty
		rd_addr_a:	  assert property (rd_addr_pr);
		rd_addr_cov:  cover  property (rd_addr_pr);

		// mem
		property mem_pr;
			@(posedge clk) disable iff(!rst_n) (((rx_valid) && (rx_data [ADDR_SIZE + 1 : ADDR_SIZE] == 2'b01))) |=>
			 (mem [wr_addr] == $past(rx_data [ADDR_SIZE - 1 : 0]));
		endproperty
		mem_a:	  assert property (mem_pr);
		mem_cov:  cover  property (mem_pr);
	`endif 
endmodule
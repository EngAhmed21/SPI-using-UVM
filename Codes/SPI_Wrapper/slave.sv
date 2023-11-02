module slave (slave_intf.DUT s_if);
	typedef enum bit [2 : 0] {IDLE, CHK_CMD, WRITE, READ_ADD, READ_DATA} STATE_e;

	localparam MEM_DEPTH = s_if.MEM_DEPTH;
	localparam ADDR_SIZE = $clog2(MEM_DEPTH);

	logic clk, rst_n, SS_n, MOSI, tx_valid, rx_valid, MISO;
	logic [ADDR_SIZE - 1 : 0] tx_data;
	logic [ADDR_SIZE + 1 : 0] rx_data;

	logic rd_flag, rx_valid_in_RD, MISO_int;
	logic [$clog2(ADDR_SIZE) : 0] count_tx, count_rx;
	logic [ADDR_SIZE + 1 : 0] bus_rx;

	STATE_e cs, ns;

	assign clk 					= s_if.clk;
	assign rst_n 				= s_if.rst_n;
	assign SS_n 				= s_if.SS_n;
	assign MOSI 				= s_if.MOSI;
	assign tx_valid 			= s_if.tx_valid;
	assign tx_data 				= s_if.tx_data;
	assign s_if.rx_valid 	    = rx_valid;
	assign s_if.rx_data 		= rx_data;
	assign s_if.MISO 		    = MISO;

	// rd_flag
	always @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            rd_flag <= 0;
        else if ((cs == READ_ADD)  && (count_rx == 0))
            rd_flag <= 1;
        else if ((cs == READ_DATA) && (count_tx == 0))
            rd_flag <= 0;
    end

	// next state logic
	always @(*) begin
		case(cs)
			IDLE: 		ns = (SS_n) ? IDLE : CHK_CMD;
			CHK_CMD: 
				if(SS_n) 
					ns = IDLE;
				else if (!MOSI)
					ns = WRITE;
				else
					if (!rd_flag) 
						ns = READ_ADD;
					else
						ns = READ_DATA;
			WRITE:		ns = (SS_n) ? IDLE : WRITE;	 
			READ_ADD:   ns = (SS_n) ? IDLE : READ_ADD;
			READ_DATA:  ns = (SS_n) ? IDLE : READ_DATA;
			default:    ns = IDLE;
		endcase
	end

	// current state memory
	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) 
			cs <= IDLE;
		else 
			cs <= ns;
	end 

	// rx
	always @(posedge clk, negedge rst_n) begin
		if ((!rst_n) || (cs == IDLE)) begin
			count_rx <= ADDR_SIZE + 2;
			bus_rx   <= 0;
		end
		else if (((cs == WRITE) || (cs == READ_ADD) || (cs == READ_DATA)) && (count_rx != 0)) begin
			bus_rx [count_rx - 1] <= MOSI;
			count_rx <= count_rx - 1;
		end
	end

	// tx
	always @(posedge clk, negedge rst_n) begin
		if ((!rst_n) || (cs == IDLE)) begin
			count_tx <= ADDR_SIZE;
			MISO_int   <= 0;
		end
		else if ((cs == READ_DATA) && (tx_valid) && (count_rx == 0) && (count_tx != 0)) begin
			MISO_int <= tx_data [count_tx - 1];
			count_tx <= count_tx - 1;
		end
	end

	// rx_valid_in_RD: to ensure that rx_valid is high for only one clock 
	always @(posedge clk, negedge rst_n) begin
        if ((!rst_n) || (count_rx == (ADDR_SIZE + 2)))
            rx_valid_in_RD <= 0;
        else if (count_rx == 0)
            rx_valid_in_RD <= 1;
    end

	// outputs
	assign rx_valid = (((cs == WRITE) || (cs == READ_ADD) || ((cs == READ_DATA) && (!rx_valid_in_RD))) && (count_rx == 0));
	assign rx_data  = bus_rx;
	assign MISO     = MISO_int;

	// Assertions for the internal signals
	`ifdef SLAVE_SIM 
		// Check reset values
		always_comb begin
			if (!rst_n) begin
				rst_count_rx_a:	assert final (count_rx == ADDR_SIZE + 2);
				rst_count_tx_a:	assert final (count_tx == ADDR_SIZE);
				rst_cs_a:		assert final (cs == IDLE);
				rst_rd_flag_a:	assert final (rd_flag == 0);
			end
		end

		// cs
		property cs_idle_pr;
			@(posedge clk) disable iff(!rst_n) (SS_n) |=> (cs == IDLE);
		endproperty
		cs_idle_a:	  assert property (cs_idle_pr);
		cs_idle_cov:  cover  property (cs_idle_pr);

		property cs_chk_pr;
			@(posedge clk) disable iff(!rst_n) ((cs == IDLE) && (!SS_n)) |=> (cs == CHK_CMD);
		endproperty
		cs_chk_a:	  assert property (cs_chk_pr);
		cs_chk_cov:   cover  property (cs_chk_pr);

		property cs_wr_pr;
			@(posedge clk) disable iff(!rst_n) ((cs == CHK_CMD) && (!SS_n) && (!MOSI)) |=> (cs == WRITE);
		endproperty
		cs_wr_a:	  assert property (cs_wr_pr);
		cs_wr_cov:    cover  property (cs_wr_pr);

		property cs_ra_pr;
			@(posedge clk) disable iff(!rst_n) ((cs == CHK_CMD) && (!SS_n) && (MOSI) && (!rd_flag)) |=> (cs == READ_ADD);
		endproperty
		cs_ra_a:	  assert property (cs_ra_pr);
		cs_ra_cov:    cover  property (cs_ra_pr);

		property cs_rd_pr;
			@(posedge clk) disable iff(!rst_n) ((cs == CHK_CMD) && (!SS_n) && (MOSI) && (rd_flag)) |=> (cs == READ_DATA);
		endproperty
		cs_rd_a:	  assert property (cs_rd_pr);
		cs_rd_cov:    cover  property (cs_rd_pr);

		// read data flag
		property rd_flag_ra_pr;
			@(posedge clk) disable iff(!rst_n) ((cs == READ_ADD) && (count_rx == 0)) |=> (rd_flag);
		endproperty
		rd_flag_ra_a:	   assert property (rd_flag_ra_pr);
		rd_flag_ra_cov:    cover  property (rd_flag_ra_pr);

		property rd_flag_rd_pr;
			@(posedge clk) disable iff(!rst_n) ((cs == READ_DATA) && (count_tx == 0)) |=> (!rd_flag);
		endproperty
		rd_flag_rd_a:	   assert property (rd_flag_rd_pr);
		rd_flag_rd_cov:    cover  property (rd_flag_rd_pr);
	`endif 
endmodule
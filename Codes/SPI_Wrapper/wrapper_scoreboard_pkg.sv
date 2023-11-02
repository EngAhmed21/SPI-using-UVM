package wrapper_scoreboard_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import wrapper_seq_item_pkg::*;
    import shared_pkg::*;

    class wrapper_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(wrapper_scoreboard)

        uvm_analysis_export #(wrapper_seq_item) sb_export;
        uvm_tlm_analysis_fifo #(wrapper_seq_item) sb_fifo;
        wrapper_seq_item seq_item_sb;
        
        STATE_e cs_ref;
        logic MISO_ref;
        bit [ADDR_SIZE + 1 : 0] rx_data_ref;
        bit [$clog2(ADDR_SIZE) : 0] count_rx_ref, count_tx_ref;
        bit rd_flag_ref, rx_valid_in_RD, rx_valid_ref, tx_valid_ref;
        logic [ADDR_SIZE - 1 : 0] mem_ref [MEM_DEPTH - 1 : 0];
        bit [ADDR_SIZE - 1 : 0] wa_ref, ra_ref, tx_data_ref;
 
        int error_count = 0;
        int correct_count = 0;

        function new(string name = "wrapper_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new()

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sb_export = new("sb_export", this);
            sb_fifo = new("sb_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            sb_export.connect(sb_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            $readmemh("RAM_data.dat", mem_ref, 0, 255);
            forever begin
                sb_fifo.get(seq_item_sb);
                ref_model(seq_item_sb);
                if (seq_item_sb.MISO != MISO_ref) begin
                    `uvm_error("run_phase", $sformatf("comparsion failed, Transaction received by the DUT:%s  While the reference:  = %0b",
                     seq_item_sb.convert2string(), MISO_ref))
                    error_count++;
                end 
                else begin
                    `uvm_info("run_phase", $sformatf("Correct wrapper tx_data: %s", seq_item_sb.convert2string()), UVM_HIGH)
                    correct_count++;
                end
            end
        endtask //

        task ref_model(wrapper_seq_item seq_item_chk);
            // rx_data && MISO
            if (!seq_item_chk.rst_n) begin
                cs_ref         = IDLE;
                count_rx_ref   = ADDR_SIZE + 2;
                count_tx_ref   = ADDR_SIZE;
                rd_flag_ref    = 0;
                rx_data_ref    = 0;
                rx_valid_in_RD = 0;
                MISO_ref       = 0;
                tx_valid_ref   = 0;
                rx_valid_ref   = 0;  
            end
            else begin
                case (cs_ref)
                    IDLE: begin
                        count_rx_ref = ADDR_SIZE + 2;
                        count_tx_ref = ADDR_SIZE;
                        rx_data_ref  = 0;
                        MISO_ref     = 0;
                        if (!seq_item_chk.SS_n)
                            cs_ref = CHK_CMD;
                    end
                    CHK_CMD: begin
                        if (seq_item_chk.SS_n)
                            cs_ref = IDLE;
                        else if (!seq_item_chk.MOSI)
                            cs_ref = WRITE;
                        else if (!rd_flag_ref)
                            cs_ref = READ_ADD;
                        else
                            cs_ref = READ_DATA;
                    end
                    WRITE: begin
                        if (seq_item_chk.SS_n) 
                            cs_ref = IDLE;
                        if (count_rx_ref != 0) begin
                            rx_data_ref [count_rx_ref - 1] = seq_item_chk.MOSI;
                            count_rx_ref--;
                        end
                    end
                    READ_ADD: begin
                        if (seq_item_chk.SS_n) begin
                            cs_ref = IDLE;
                            if (count_rx_ref == 0)
                                rd_flag_ref = 1;
                        end
                        if (count_rx_ref != 0) begin
                            rx_data_ref [count_rx_ref - 1] = seq_item_chk.MOSI;
                            count_rx_ref--;
                        end
                    end
                    READ_DATA: begin
                        if (seq_item_chk.SS_n) begin
                            cs_ref = IDLE;
                            if (count_tx_ref == 0)
                                rd_flag_ref = 0;
                        end
                        if (count_rx_ref != 0) begin
                            rx_data_ref [count_rx_ref - 1] = seq_item_chk.MOSI;
                            count_rx_ref--;
                        end
                        else if ((count_tx_ref != 0) && (tx_valid_ref)) begin
                            MISO_ref = tx_data_ref [count_tx_ref - 1];
                            count_tx_ref--;
                        end
                    end
                endcase 
            end

            // RAM
            if (!seq_item_chk.rst_n) begin
                wa_ref 	       = 0;
                ra_ref         = 0;
                tx_data_ref    = 0;
                tx_valid_ref   = 0;
            end
            else if (rx_valid_ref) begin
                case (rx_data_ref [ADDR_SIZE + 1 : ADDR_SIZE])
                    2'b00:	wa_ref 	  		  = rx_data_ref [ADDR_SIZE - 1 : 0];						
                    2'b01:	mem_ref [wa_ref]  = rx_data_ref [ADDR_SIZE - 1 : 0];
                    2'b10:	ra_ref 	          = rx_data_ref [ADDR_SIZE - 1 : 0];
                    2'b11:  tx_data_ref 	  = mem_ref [ra_ref];
                endcase
                tx_valid_ref = (&(rx_data_ref [ADDR_SIZE + 1 : ADDR_SIZE]));
            end

            // rx_valid
            rx_valid_ref = (((cs_ref == WRITE) || (cs_ref == READ_ADD) || ((cs_ref == READ_DATA) && (!rx_valid_in_RD))) && (count_rx_ref == 0));
            if (count_rx_ref == (ADDR_SIZE + 2))
                rx_valid_in_RD = 0;
            else if (count_rx_ref == 0)
                rx_valid_in_RD = 1;
        endtask //

        function void report_phase (uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("report_phase", $sformatf("Total successful transactions: %0d", correct_count), UVM_MEDIUM)
            `uvm_info("report_phase", $sformatf("Total failed transactions: %0d", error_count), UVM_MEDIUM)
        endfunction
    endclass 
endpackage
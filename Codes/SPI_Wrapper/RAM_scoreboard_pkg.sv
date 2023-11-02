package RAM_scoreboard_pkg;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import RAM_seq_item_pkg::*;

    class RAM_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(RAM_scoreboard)

        uvm_analysis_export #(RAM_seq_item) sb_export;
        uvm_tlm_analysis_fifo #(RAM_seq_item) sb_fifo;
        RAM_seq_item seq_item_sb;
        
        bit tx_valid_ref;
        bit [ADDR_SIZE - 1 : 0] tx_data_ref, wr_addr, rd_addr;
        bit [ADDR_SIZE - 1 : 0] mem_test [MEM_DEPTH];
        bit rx_valid_reg;
        bit [ADDR_SIZE + 1 : 0] rx_data_reg;
 

        int error_count = 0;
        int correct_count = 0;

        function new(string name = "RAM_scoreboard", uvm_component parent = null);
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
            $readmemh("RAM_data.dat", mem_test, 0, 255);
            forever begin
                sb_fifo.get(seq_item_sb);
                if (!seq_item_sb.rst_n) begin
                    rx_data_reg  = 0;
                    rx_valid_reg = 0;
                end
                else begin
                    rx_data_reg  <= seq_item_sb.rx_data;
                    rx_valid_reg <= seq_item_sb.rx_valid;
                end
                ref_model(seq_item_sb);
                if ((seq_item_sb.tx_data != tx_data_ref) || (seq_item_sb.tx_valid != tx_valid_ref)) begin
                    `uvm_error("run_phase", $sformatf("comparsion failed, Transaction received by the DUT:%s  While the reference tx_data: tx_data_ref = %0h, tx_valid_ref = %0b",
                     seq_item_sb.convert2string(), tx_data_ref, tx_valid_ref))
                    error_count++;
                end 
                else begin
                    `uvm_info("run_phase", $sformatf("Correct RAM Transaction: %s", seq_item_sb.convert2string()), UVM_HIGH)
                    correct_count++;
                end
            end
        endtask //

        task ref_model(RAM_seq_item seq_item_chk);
            if (!seq_item_chk.rst_n) begin
                wr_addr = 0;
                rd_addr = 0;
                tx_data_ref = 0;
            end
            else if (rx_valid_reg) begin
                case (rx_data_reg [ADDR_SIZE + 1 : ADDR_SIZE])
                    2'b00: wr_addr = rx_data_reg [ADDR_SIZE - 1 : 0];
                    2'b01: mem_test [wr_addr] = rx_data_reg [ADDR_SIZE - 1 : 0];
                    2'b10: rd_addr = rx_data_reg [ADDR_SIZE - 1 : 0];
                    2'b11: tx_data_ref = mem_test [rd_addr];
                endcase
            end
            
            if (!seq_item_chk.rst_n) 
                tx_valid_ref = 0;
            else if (rx_valid_reg) 
                if (rx_data_reg [ADDR_SIZE + 1 : ADDR_SIZE] == 2'b11)
                    tx_valid_ref = 1;
                else
                    tx_valid_ref = 0;
        endtask //

        function void report_phase (uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("report_phase", $sformatf("Total successful transactions: %0d", correct_count), UVM_MEDIUM)
            `uvm_info("report_phase", $sformatf("Total failed transactions: %0d", error_count), UVM_MEDIUM)
        endfunction
    endclass 
endpackage
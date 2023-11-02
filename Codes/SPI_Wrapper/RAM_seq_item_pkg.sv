package RAM_seq_item_pkg;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class RAM_seq_item extends uvm_sequence_item;
        `uvm_object_utils(RAM_seq_item)

        rand bit clk, rst_n, rx_valid;
        rand bit [ADDR_SIZE + 1 : 0] rx_data;
        bit [ADDR_SIZE - 1 : 0] wa_idx, ra_idx;
        bit [ADDR_SIZE - 1 : 0] wa_arr [MEM_DEPTH], ra_arr [MEM_DEPTH];
        bit wr_addr_occur, rd_addr_occur;
        bit tx_valid;
        bit [ADDR_SIZE - 1 : 0] tx_data;

        constraint rst_c    {rst_n dist {1 :/ 95, 0 :/ 5};}
        constraint rx_c     {rx_valid dist {1 :/ 90, 0 :/ 10};}

        constraint rx_data_c {
            rx_data [ADDR_SIZE + 1]  dist {1 :/ 40, 0 :/ 60};
            rx_data [ADDR_SIZE]      dist {1 :/ 40, 0 :/ 60};

            if (rx_data[ADDR_SIZE + 1] == 0) {
                if (!wr_addr_occur) 
                    rx_data[ADDR_SIZE] == 0;
            }
            else {
                if (!rd_addr_occur) 
                    rx_data[ADDR_SIZE] == 0;
            }

            if (rx_data [ADDR_SIZE + 1 : ADDR_SIZE] == 2'b00)
                rx_data [ADDR_SIZE - 1 : 0] == wa_arr [wa_idx];
            else if (rx_data [ADDR_SIZE + 1 : ADDR_SIZE] == 2'b10)
                rx_data [ADDR_SIZE - 1 : 0] == ra_arr [ra_idx];
        }

        function void post_randomize();
            if (wa_idx == MEM_DEPTH - 1) 
                wa_arr.shuffle();
            else if (rx_data [ADDR_SIZE + 1 : ADDR_SIZE] == 2'b00)
                wa_idx++;

            if (ra_idx == MEM_DEPTH - 1)
                ra_arr.shuffle();
            else if (rx_data [ADDR_SIZE + 1 : ADDR_SIZE] == 2'b10) 
                ra_idx++;

            if (rx_data [ADDR_SIZE + 1 : ADDR_SIZE] == 2'b00) 
                wr_addr_occur = 1;
            else if (rx_data [ADDR_SIZE + 1 : ADDR_SIZE] == 2'b10) 
                rd_addr_occur = 1;
        endfunction

        function new(string name = "RAM_seq_item");
            super.new(name);

            for (int i = 0; i < MEM_DEPTH; i++) begin
                wa_arr [i] = i;
                ra_arr [i] = i;
            end
            wa_arr.shuffle();
            ra_arr.shuffle();
        endfunction //

        function string convert2string();
            return $sformatf("%s rst_n = %0b, rx_valid = %0b, rx_data = %0h, tx_valid = %0b, tx_data = %0h",
             super.convert2string(), rst_n, rx_valid, rx_data, tx_valid, tx_data);
        endfunction

        function string convert2string_stimulus();
            return $sformatf("rst_n = %0b, rx_valid = %0b, rx_data = %0h", rst_n, rx_valid, rx_data);
        endfunction
    endclass // 
endpackage
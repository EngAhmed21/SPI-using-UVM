package slave_seq_item_pkg;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class slave_seq_item extends uvm_sequence_item;
        `uvm_object_utils(slave_seq_item)

        rand bit rst_n, SS_n, tx_valid, MOSI;
        rand bit [ADDR_SIZE - 1 : 0] tx_data;
        rand bit MOSI_arr [(2 * ADDR_SIZE) + 5];
        bit [$clog2((2 * ADDR_SIZE) + 4) - 1 : 0] count;
        bit rd_flag;
        bit rx_valid, MISO;
        bit [ADDR_SIZE + 1 : 0] rx_data;

        constraint rst_c {rst_n dist {1 :/ 99, 0 :/ 1};}

        constraint SS_c {
            if ((MOSI_arr[2]) && (MOSI_arr[3])) 
                if (count == ((2 * ADDR_SIZE) + 4))
                    SS_n == 1;
                else
                    SS_n == 0;
            else
                if (count == (ADDR_SIZE + 4))
                    SS_n == 1;
                else
                    SS_n == 0;
        }

        constraint tx_valid_c {
            if (((MOSI_arr[2]) && (MOSI_arr[3]))  && (count > ADDR_SIZE + 3) && (count < (2 * ADDR_SIZE) + 4))
                tx_valid == 1;
            else
                tx_valid == 0;
        }      

        constraint MOSI_arr_c {
            MOSI_arr[1] dist {0 :/ 60, 1 :/ 40};
            MOSI_arr[2] == MOSI_arr[1];
            if (MOSI_arr[2]) 
                if (rd_flag)
                    MOSI_arr[3] == 1;
                else 
                    MOSI_arr[3] == 0;
            else
                MOSI_arr[3] dist {0 :/ 60, 1 :/ 40};
        }

        constraint MOSI_c {MOSI == MOSI_arr[count];}

        function void pre_randomize();
            if (count == 0) 
                MOSI_arr.rand_mode(1);
            else
                MOSI_arr.rand_mode(0);

            if (((MOSI_arr[2]) && (MOSI_arr[3])) && (count == (ADDR_SIZE + 4)))
                tx_data.rand_mode(1);
            else 
                tx_data.rand_mode(0);

            if (!rst_n)
                rd_flag = 0;
            else if (count == 0)
                if ((MOSI_arr[2]) && (MOSI_arr[3]))
                    rd_flag = 0;
                else if ((MOSI_arr[2]) && (!MOSI_arr[3]))
                    rd_flag = 1;
        endfunction

        function void post_randomize();
            if (SS_n || (!rst_n))
                count = 0;
            else 
                count++;
        endfunction

        
        function new(string name = "slave_seq_item");
            super.new(name);
        endfunction //

        function string convert2string();
            return $sformatf("%s rst_n = %0b, SS_n = %0b, MOSI = %0b, tx_valid = %0b, tx_data = %0h, rx_valid = %0b, rx_data = %0h, MISO = %0b",
             super.convert2string(), rst_n, SS_n, MOSI, tx_valid, tx_data, rx_valid, rx_data, MISO);
        endfunction

        function string convert2string_stimulus();
            return $sformatf("rst_n = %0b, SS_n = %0b, MOSI = %0b, tx_valid = %0b, tx_data = %0h", rst_n, SS_n, MOSI, tx_valid, tx_data);
        endfunction
    endclass // 
endpackage
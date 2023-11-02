package wrapper_seq_item_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import shared_pkg::*;
    import cs_shared_pkg::*;

    class wrapper_seq_item extends uvm_sequence_item;
        `uvm_object_utils(wrapper_seq_item)
        
        rand bit rst_n, SS_n, MOSI;
        rand bit MOSI_arr [(2 * ADDR_SIZE) + 6];
        bit [$clog2((2 * ADDR_SIZE) + 5) - 1 : 0] count;
        bit rd_flag;
        bit MISO;

        constraint rst_c {rst_n dist {1 :/ 99, 0 :/ 1};}

        constraint SS_c {
            if ((MOSI_arr[2]) && (MOSI_arr[3])) 
                if (count == ((2 * ADDR_SIZE) + 5))
                    SS_n == 1;
                else
                    SS_n == 0;
            else
                if (count == (ADDR_SIZE + 4))
                    SS_n == 1;
                else
                    SS_n == 0;
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

            if ((!rst_n) || SS_n)
                cs_cov = IDLE_cov;
            else if (count == ADDR_SIZE + 4) begin
                if ((!MOSI_arr[2]) && (!MOSI_arr[3])) 
                    cs_cov = WRITE_ADD_cov;
                else if ((!MOSI_arr[2]) && (MOSI_arr[3])) 
                    cs_cov = WRITE_DATA_cov;
                else if ((MOSI_arr[2]) && (!MOSI_arr[3]))  
                    cs_cov = READ_ADD_cov;
            end
            else if (count == (2 * ADDR_SIZE) + 5)
                if ((MOSI_arr[2]) && (MOSI_arr[3])) 
                    cs_cov = READ_DATA_cov;
        endfunction

        function new(string name = "wrapper_seq_item");
            super.new(name);
        endfunction //new()

        function string convert2string();
            return $sformatf("%s rst_n = %0b, SS_n = %0b, MOSI = %0b, MISO = %0b", super.convert2string(), rst_n, SS_n, MOSI, MISO);
        endfunction

        function string convert2string_stimulus();
            return $sformatf("rst_n = %0b, SS_n = %0b MOSI = %0b", rst_n, SS_n, MOSI);
        endfunction
    endclass // 
endpackage
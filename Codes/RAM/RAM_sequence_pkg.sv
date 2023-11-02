package RAM_sequence_pkg;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import RAM_seq_item_pkg::*;

    class RAM_rst_sequence extends uvm_sequence #(RAM_seq_item);
        `uvm_object_utils(RAM_rst_sequence);

        RAM_seq_item seq_item;

        function new(string name = "RAM_rst_sequence");
            super.new(name);
        endfunction //new()

        task pre_body;
            seq_item = RAM_seq_item::type_id::create("seq_item");
        endtask //

        task body;
            start_item(seq_item);
                seq_item.rst_n    = 0;         
                seq_item.rx_valid = 0;
                seq_item.rx_data  = 0;         
            finish_item(seq_item);
        endtask //
    endclass //

    class RAM_write_only_sequence extends uvm_sequence #(RAM_seq_item);
        `uvm_object_utils(RAM_write_only_sequence)

        RAM_seq_item seq_item;

        function new(string name = "RAM_write_only_sequence");
            super.new();
        endfunction //new()

        task pre_body;
            seq_item = RAM_seq_item::type_id::create("seq_item");
        endtask //

        task body;
            repeat(4000) begin
                start_item(seq_item);
                    assert(seq_item.randomize() with {seq_item.rx_data[ADDR_SIZE+1:ADDR_SIZE] inside {2'b00, 2'b01};});
                finish_item(seq_item);
            end
        endtask //
    endclass //

    class RAM_read_only_sequence extends uvm_sequence #(RAM_seq_item);
        `uvm_object_utils(RAM_read_only_sequence)

        RAM_seq_item seq_item;

        function new(string name = "RAM_read_only_sequence");
            super.new();
        endfunction //new()

        task pre_body;
            seq_item = RAM_seq_item::type_id::create("seq_item");
        endtask //

        task body;
            repeat(4000) begin
                start_item(seq_item);
                    assert(seq_item.randomize() with {seq_item.rx_data[ADDR_SIZE+1:ADDR_SIZE] inside {2'b10, 2'b11};});
                finish_item(seq_item);
            end
        endtask //
    endclass //
    
    class RAM_write_read_sequence extends uvm_sequence #(RAM_seq_item);
        `uvm_object_utils(RAM_write_read_sequence)

        RAM_seq_item seq_item;

        function new(string name = "RAM_write_read_sequence");
            super.new();
        endfunction //new()

        task pre_body;
            seq_item = RAM_seq_item::type_id::create("seq_item");
        endtask //

        task body;
            repeat(6000) begin
                start_item(seq_item);
                    assert(seq_item.randomize());
                finish_item(seq_item);
            end
        endtask //
    endclass //
endpackage
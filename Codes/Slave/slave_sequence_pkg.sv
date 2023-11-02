package slave_sequence_pkg;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import slave_seq_item_pkg::*;

    class slave_rst_sequence extends uvm_sequence #(slave_seq_item);
        `uvm_object_utils(slave_rst_sequence);

        slave_seq_item seq_item;

        function new(string name = "slave_rst_sequence");
            super.new(name);
        endfunction //new()

        task pre_body;
            seq_item = slave_seq_item::type_id::create("seq_item");
        endtask //

        task body;
            start_item(seq_item);
                seq_item.rst_n    = 0;        
                seq_item.SS_n     = 0;
                seq_item.MOSI     = 0;
                seq_item.tx_valid = 0;
                seq_item.tx_data  = 0;         
            finish_item(seq_item);
        endtask //
    endclass //

    class slave_main_sequence extends uvm_sequence #(slave_seq_item);
        `uvm_object_utils(slave_main_sequence)

        slave_seq_item seq_item;

        function new(string name = "slave_main_sequence");
            super.new();
        endfunction //new()

        task pre_body;
            seq_item = slave_seq_item::type_id::create("seq_item");
        endtask //

        task body;
            repeat(12000) begin
                start_item(seq_item);
                    assert(seq_item.randomize());
                finish_item(seq_item);
            end
        endtask //
    endclass //
endpackage
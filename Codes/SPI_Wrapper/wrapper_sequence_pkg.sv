package wrapper_sequence_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import wrapper_seq_item_pkg::*;

    class wrapper_rst_sequence extends uvm_sequence #(wrapper_seq_item);
        `uvm_object_utils(wrapper_rst_sequence);
        wrapper_seq_item seq_item;

        function new(string name = "wrapper_rst_sequence");
            super.new(name);
        endfunction //new()

        task pre_body;
            seq_item = wrapper_seq_item::type_id::create("seq_item");
        endtask //

        task body;
            start_item(seq_item);
                seq_item.rst_n = 0;         
                seq_item.SS_n  = 0;
                seq_item.MOSI  = 0;         
            finish_item(seq_item);
        endtask //
    endclass //

    class wrapper_main_sequence extends uvm_sequence #(wrapper_seq_item);
        `uvm_object_utils(wrapper_main_sequence)
        wrapper_seq_item seq_item;

        function new(string name = "wrapper_main_sequence");
            super.new();
        endfunction //new()

        task pre_body;
            seq_item = wrapper_seq_item::type_id::create("seq_item");
        endtask //

        task body;
            repeat(20000) begin
                start_item(seq_item);
                    assert(seq_item.randomize());
                finish_item(seq_item);
            end
        endtask //
    endclass //
endpackage
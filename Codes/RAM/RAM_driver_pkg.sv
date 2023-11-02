package RAM_driver_pkg;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import RAM_seq_item_pkg::*;

    class RAM_driver extends uvm_driver #(RAM_seq_item);
        `uvm_component_utils(RAM_driver)

        virtual RAM_intf #(MEM_DEPTH) RAM_driver_if;
        RAM_seq_item stim_seq_item;

        function new(string name = "RAM_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new()

        task run_phase (uvm_phase phase);
            super.run_phase(phase);
            forever begin
                stim_seq_item = RAM_seq_item::type_id::create("stim_seq_item");
                seq_item_port.get_next_item(stim_seq_item);
                RAM_driver_if.rst_n    = stim_seq_item.rst_n;
                RAM_driver_if.rx_valid = stim_seq_item.rx_valid;
                RAM_driver_if.rx_data  = stim_seq_item.rx_data;
                @(negedge RAM_driver_if.clk);
                seq_item_port.item_done();
                `uvm_info("run_phase", stim_seq_item.convert2string(), UVM_HIGH)
            end
        endtask //
    endclass //
endpackage
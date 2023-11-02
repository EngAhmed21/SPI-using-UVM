package slave_driver_pkg;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import slave_seq_item_pkg::*;

    class slave_driver extends uvm_driver #(slave_seq_item);
        `uvm_component_utils(slave_driver)

        virtual slave_intf #(MEM_DEPTH) slave_driver_if;
        slave_seq_item stim_seq_item;

        function new(string name = "slave_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new()

        task run_phase (uvm_phase phase);
            super.run_phase(phase);
            forever begin
                stim_seq_item = slave_seq_item::type_id::create("stim_seq_item");
                seq_item_port.get_next_item(stim_seq_item);
                slave_driver_if.rst_n    = stim_seq_item.rst_n;
                slave_driver_if.SS_n     = stim_seq_item.SS_n;
                slave_driver_if.MOSI     = stim_seq_item.MOSI;
                slave_driver_if.tx_valid = stim_seq_item.tx_valid;
                slave_driver_if.tx_data  = stim_seq_item.tx_data;
                @(negedge slave_driver_if.clk);
                seq_item_port.item_done();
                `uvm_info("run_phase", stim_seq_item.convert2string(), UVM_HIGH)
            end
        endtask //
    endclass //
endpackage
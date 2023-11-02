package wrapper_driver_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import shared_pkg::*;
    import wrapper_seq_item_pkg::*;
    import wrapper_config_obj_pkg::*;

    class wrapper_driver extends uvm_driver #(wrapper_seq_item);
        `uvm_component_utils(wrapper_driver)

        virtual wrapper_intf #(MEM_DEPTH) wrapper_driver_if;
        wrapper_seq_item stim_seq_item;

        function new(string name = "wrapper_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new()

        task run_phase (uvm_phase phase);
            super.run_phase(phase);
            forever begin
                stim_seq_item = wrapper_seq_item::type_id::create("stim_seq_item");
                seq_item_port.get_next_item(stim_seq_item);
                wrapper_driver_if.rst_n = stim_seq_item.rst_n;
                wrapper_driver_if.SS_n  = stim_seq_item.SS_n;
                wrapper_driver_if.MOSI  = stim_seq_item.MOSI;
                @(negedge wrapper_driver_if.clk);
                seq_item_port.item_done();
                `uvm_info("run_phase", stim_seq_item.convert2string(), UVM_HIGH)
            end
        endtask //
    endclass //
endpackage
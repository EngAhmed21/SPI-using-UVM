package slave_monitor_pkg;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import slave_seq_item_pkg::*;

    class slave_monitor extends uvm_monitor;
        `uvm_component_utils(slave_monitor)

        virtual slave_intf #(MEM_DEPTH) slave_monitor_if;
        slave_seq_item rsp_seq_item;
        uvm_analysis_port #(slave_seq_item) mon_ap;

        function new(string name = "slave_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new()

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            mon_ap = new("mon_ap", this);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                rsp_seq_item = slave_seq_item::type_id::create("rsp_seq_item");
                @(negedge slave_monitor_if.clk);
                rsp_seq_item.rst_n    = slave_monitor_if.rst_n;
                rsp_seq_item.SS_n     = slave_monitor_if.SS_n;
                rsp_seq_item.MOSI     = slave_monitor_if.MOSI;
                rsp_seq_item.tx_valid = slave_monitor_if.tx_valid;
                rsp_seq_item.tx_data  = slave_monitor_if.tx_data;
                rsp_seq_item.rx_valid = slave_monitor_if.rx_valid;
                rsp_seq_item.rx_data  = slave_monitor_if.rx_data;
                rsp_seq_item.MISO     = slave_monitor_if.MISO;
                mon_ap.write(rsp_seq_item);
                `uvm_info("run_phase", rsp_seq_item.convert2string(), UVM_HIGH)
            end
        endtask //
    endclass //
endpackage
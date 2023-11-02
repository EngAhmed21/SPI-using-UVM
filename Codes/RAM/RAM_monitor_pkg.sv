package RAM_monitor_pkg;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import RAM_seq_item_pkg::*;

    class RAM_monitor extends uvm_monitor;
        `uvm_component_utils(RAM_monitor)

        virtual RAM_intf #(MEM_DEPTH) RAM_monitor_if;
        RAM_seq_item rsp_seq_item;
        uvm_analysis_port #(RAM_seq_item) mon_ap;

        function new(string name = "RAM_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new()

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            mon_ap = new("mon_ap", this);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                rsp_seq_item = RAM_seq_item::type_id::create("rsp_seq_item");
                @(negedge RAM_monitor_if.clk);
                rsp_seq_item.rst_n    = RAM_monitor_if.rst_n;
                rsp_seq_item.rx_valid = RAM_monitor_if.rx_valid;
                rsp_seq_item.rx_data  = RAM_monitor_if.rx_data;
                rsp_seq_item.tx_valid = RAM_monitor_if.tx_valid;
                rsp_seq_item.tx_data  = RAM_monitor_if.tx_data;
                mon_ap.write(rsp_seq_item);
                `uvm_info("run_phase", rsp_seq_item.convert2string(), UVM_HIGH)
            end
        endtask //
    endclass //
endpackage
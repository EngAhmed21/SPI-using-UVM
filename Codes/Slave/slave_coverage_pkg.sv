package slave_coverage_pkg;
    import shared_pkg::*;
    import cs_shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import slave_seq_item_pkg::*;

    class slave_coverage extends uvm_component;
        `uvm_component_utils(slave_coverage)

        uvm_analysis_export #(slave_seq_item) cov_export;
        uvm_tlm_analysis_fifo #(slave_seq_item) cov_fifo;
        slave_seq_item seq_item_cov;

        covergroup cvgrp;
            tx_cp:       coverpoint seq_item_cov.tx_valid iff (seq_item_cov.rst_n);
            cs_cov_cp:   coverpoint cs_cov iff (seq_item_cov.rst_n) {
                bins wr_addr = {WRITE_ADD_cov};
                bins wr_data = {WRITE_DATA_cov};
                bins rd_addr = {READ_ADD_cov};
                bins rd_data = {READ_DATA_cov};
            }
        endgroup

        function new(string name = "slave_coverage", uvm_component parent = null);
            super.new(name, parent);
            cvgrp = new;
        endfunction //new()

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            cov_export = new("cov_export", this);
            cov_fifo = new("cov_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            cov_export.connect(cov_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                cov_fifo.get(seq_item_cov);
                cvgrp.sample();
            end
        endtask //
    endclass //
endpackage
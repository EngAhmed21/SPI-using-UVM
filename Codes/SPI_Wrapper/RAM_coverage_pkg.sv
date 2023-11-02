package RAM_coverage_pkg;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import RAM_seq_item_pkg::*;

    class RAM_coverage extends uvm_component;
        `uvm_component_utils(RAM_coverage)

        uvm_analysis_export #(RAM_seq_item) cov_export;
        uvm_tlm_analysis_fifo #(RAM_seq_item) cov_fifo;
        RAM_seq_item seq_item_cov;

        covergroup cvgrp;
            R_rx_cp:       coverpoint seq_item_cov.rx_valid;
            R_din_cp:      coverpoint seq_item_cov.rx_data [ADDR_SIZE + 1 : ADDR_SIZE];
            R_din_addr_cp: coverpoint seq_item_cov.rx_data [ADDR_SIZE - 1 : 0];
            
            R_wr_addr_cr: cross R_rx_cp, R_din_cp iff (seq_item_cov.rst_n) {
                option.cross_auto_bin_max = 0;
               bins wr_addr_bin = binsof(R_rx_cp) intersect {1} && binsof(R_din_cp) intersect {0};
            }
            R_wr_data_cr: cross R_rx_cp, R_din_cp iff (seq_item_cov.rst_n) {
                option.cross_auto_bin_max = 0;
               bins wr_data_bin = binsof(R_rx_cp) intersect {1} && binsof(R_din_cp) intersect {1};
            }
            R_rd_addr_cr: cross R_rx_cp, R_din_cp iff (seq_item_cov.rst_n) {
                option.cross_auto_bin_max = 0;
               bins rd_addr_bin = binsof(R_rx_cp) intersect {1} && binsof(R_din_cp) intersect {2};
            }
            R_rd_data_cr: cross R_rx_cp, R_din_cp iff (seq_item_cov.rst_n) {
                option.cross_auto_bin_max = 0;
               bins rd_data_bin = binsof(R_rx_cp) intersect {1} && binsof(R_din_cp) intersect {3};
            }

            R_wr_mem_addresses_cr: cross R_rx_cp, R_din_cp, R_din_addr_cp iff (seq_item_cov.rst_n) {
               ignore_bins rx_low = binsof(R_rx_cp) intersect {0};
               ignore_bins din_cp_not_wa = binsof(R_din_cp) intersect {1, 2, 3};
            }
            R_rd_mem_addresses_cr: cross R_rx_cp, R_din_cp, R_din_addr_cp iff (seq_item_cov.rst_n) {
               ignore_bins rx_low = binsof(R_rx_cp) intersect {0};
               ignore_bins din_cp_not_wa = binsof(R_din_cp) intersect {0, 1, 3};
            }
        endgroup

        function new(string name = "RAM_coverage", uvm_component parent = null);
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
package wrapper_agent_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import wrapper_driver_pkg::*;
    import wrapper_sequencer_pkg::*;
    import wrapper_monitor_pkg::*;
    import wrapper_config_obj_pkg::*;
    import wrapper_seq_item_pkg::*;

    class wrapper_agent extends uvm_agent;
        `uvm_component_utils(wrapper_agent)

        wrapper_sequencer sqr;
        wrapper_driver drv;
        wrapper_monitor mon;
        wrapper_config_obj wrapper_cfg;
        uvm_analysis_port #(wrapper_seq_item) agt_ap;

        function new(string name = "wrapper_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new()

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db #(wrapper_config_obj)::get(this, "", "W_CFG", wrapper_cfg))
                `uvm_fatal("build_phase", "Agent-unable to get the virtual interface of the wrapper from the uvm_config_db")

            if (wrapper_cfg.active == UVM_ACTIVE) begin
                sqr    = wrapper_sequencer::type_id::create("sqr", this);
                drv    = wrapper_driver::type_id::create("drv", this);
            end
            mon    = wrapper_monitor::type_id::create("mon", this);
            agt_ap = new("agt_ap", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            mon.mon_ap.connect(agt_ap);
            mon.wrapper_monitor_if = wrapper_cfg.wrapper_config_if;
            if (wrapper_cfg.active == UVM_ACTIVE) begin
                drv.wrapper_driver_if  = wrapper_cfg.wrapper_config_if;
                drv.seq_item_port.connect(sqr.seq_item_export);
            end
        endfunction
    endclass //
endpackage
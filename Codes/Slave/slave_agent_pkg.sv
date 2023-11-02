package slave_agent_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import slave_driver_pkg::*;
    import slave_sequencer_pkg::*;
    import slave_monitor_pkg::*;
    import slave_config_obj_pkg::*;
    import slave_seq_item_pkg::*;

    class slave_agent extends uvm_agent;
        `uvm_component_utils(slave_agent)

        slave_sequencer sqr;
        slave_driver drv;
        slave_monitor mon;
        slave_config_obj slave_cfg;
        uvm_analysis_port #(slave_seq_item) agt_ap;

        function new(string name = "slave_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new()

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db #(slave_config_obj)::get(this, "", "CONFIG", slave_cfg))
                `uvm_fatal("build_phase", "Agent-unable to get the virtual interface of the slave from the uvm_config_db")
            sqr    = slave_sequencer::type_id::create("sqr", this);
            drv    = slave_driver::type_id::create("drv", this);
            mon    = slave_monitor::type_id::create("mon", this);
            agt_ap = new("agt_ap", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            mon.mon_ap.connect(agt_ap);
            drv.slave_driver_if  = slave_cfg.slave_config_if;
            mon.slave_monitor_if = slave_cfg.slave_config_if;
            drv.seq_item_port.connect(sqr.seq_item_export);
        endfunction
    endclass //
endpackage
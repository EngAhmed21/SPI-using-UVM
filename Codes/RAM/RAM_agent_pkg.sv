package RAM_agent_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import RAM_driver_pkg::*;
    import RAM_sequencer_pkg::*;
    import RAM_monitor_pkg::*;
    import RAM_config_obj_pkg::*;
    import RAM_seq_item_pkg::*;

    class RAM_agent extends uvm_agent;
        `uvm_component_utils(RAM_agent)

        RAM_sequencer sqr;
        RAM_driver drv;
        RAM_monitor mon;
        RAM_config_obj RAM_cfg;
        uvm_analysis_port #(RAM_seq_item) agt_ap;

        function new(string name = "RAM_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new()

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db #(RAM_config_obj)::get(this, "", "CONFIG", RAM_cfg))
                `uvm_fatal("build_phase", "Agent-unable to get the virtual interface of the RAM from the uvm_config_db")
            sqr    = RAM_sequencer::type_id::create("sqr", this);
            drv    = RAM_driver::type_id::create("drv", this);
            mon    = RAM_monitor::type_id::create("mon", this);
            agt_ap = new("agt_ap", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            mon.mon_ap.connect(agt_ap);
            drv.RAM_driver_if  = RAM_cfg.RAM_config_if;
            mon.RAM_monitor_if = RAM_cfg.RAM_config_if;
            drv.seq_item_port.connect(sqr.seq_item_export);
        endfunction
    endclass //
endpackage
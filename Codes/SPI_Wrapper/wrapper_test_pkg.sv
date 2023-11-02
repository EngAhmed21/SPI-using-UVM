package wrapper_test_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import RAM_config_obj_pkg::*;
    import slave_config_obj_pkg::*;
    import wrapper_config_obj_pkg::*;
    import RAM_env_pkg::*;
    import slave_env_pkg::*;
    import wrapper_env_pkg::*;
    import wrapper_sequence_pkg::*;
    
    class wrapper_test extends uvm_test;
        `uvm_component_utils(wrapper_test)

        RAM_config_obj R_cfg;
        slave_config_obj S_cfg;
        wrapper_config_obj W_cfg;

        RAM_env R_env;
        slave_env S_env;
        wrapper_env W_env;
        
        wrapper_rst_sequence rst_seq;
        wrapper_main_sequence main_seq;

        function new(string name = "wrapper_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new()

        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            R_cfg    = RAM_config_obj::type_id::create("R_cfg");
            S_cfg    = slave_config_obj::type_id::create("S_cfg");
            W_cfg    = wrapper_config_obj::type_id::create("W_cfg");
            
            R_env    = RAM_env::type_id::create("R_env", this);
            S_env    = slave_env::type_id::create("S_env", this);
            W_env    = wrapper_env::type_id::create("W_env", this);
            
            rst_seq  = wrapper_rst_sequence::type_id::create("rst_seq");
            main_seq = wrapper_main_sequence::type_id::create("main_seq");

            if (!uvm_config_db #(virtual RAM_intf.TEST)::get(this, "", "RAM_if", R_cfg.RAM_config_if))
                `uvm_fatal("build_phase", "Test-unable to get the virtual interface of the alsu from the uvm_config_db")
            R_cfg.active = UVM_PASSIVE;
            uvm_config_db #(RAM_config_obj)::set(this, "*", "R_CFG", R_cfg);

            if (!uvm_config_db #(virtual slave_intf.TEST)::get(this, "", "slave_if", S_cfg.slave_config_if))
                `uvm_fatal("build_phase", "Test-unable to get the virtual interface of the alsu from the uvm_config_db")
            R_cfg.active = UVM_PASSIVE;
            uvm_config_db #(slave_config_obj)::set(this, "*", "S_CFG", S_cfg);

            if (!uvm_config_db #(virtual wrapper_intf.TEST)::get(this, "", "wrapper_if", W_cfg.wrapper_config_if))
                `uvm_fatal("build_phase", "Test-unable to get the virtual interface of the alsu from the uvm_config_db")
            W_cfg.active = UVM_ACTIVE;
            uvm_config_db #(wrapper_config_obj)::set(this, "*", "W_CFG", W_cfg);

            
        endfunction

        task run_phase (uvm_phase phase);
            super.run_phase(phase);
            phase.raise_objection(this);
                `uvm_info("run_phase", "Reset Asserted", UVM_LOW);
                rst_seq.start(W_env.agt.sqr);
                `uvm_info("run_phase", "Reset Deasserted", UVM_LOW);

                `uvm_info("run_phase", "Stimulus Generation Started", UVM_LOW);
                main_seq.start(W_env.agt.sqr);
                `uvm_info("run_phase", "Stimulus Generation Ended", UVM_LOW);
            phase.drop_objection(this);
        endtask //
    endclass //
endpackage
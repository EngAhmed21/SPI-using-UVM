package slave_test_pkg;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import slave_env_pkg::*;
    import slave_config_obj_pkg::*;
    import slave_sequence_pkg::*;

    class slave_test extends uvm_test;
        `uvm_component_utils(slave_test)

        slave_env env;
        slave_config_obj config_obj_test;
        slave_rst_sequence rst_seq;
        slave_main_sequence main_seq;

        function new(string name = "slave_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new()

        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            env             = slave_env::type_id::create("env", this);
            config_obj_test = slave_config_obj::type_id::create("config_obj_test");
            rst_seq         = slave_rst_sequence::type_id::create("rst_seq");
            main_seq        = slave_main_sequence::type_id::create("main_seq");

            if (!uvm_config_db #(virtual slave_intf #(MEM_DEPTH).slave_TEST)::get(this, "", "slave_intf", config_obj_test.slave_config_if))
                `uvm_fatal("build_phase", "Test-unable to get the virtual interface of the slave from the uvm_config_db")
            uvm_config_db #(slave_config_obj)::set(this, "*", "CONFIG", config_obj_test);
        endfunction


        task run_phase (uvm_phase phase);
            super.run_phase(phase);
            phase.raise_objection(this);
                `uvm_info("run_phase", "Reset Asserted", UVM_LOW);
                rst_seq.start(env.agt.sqr);
                `uvm_info("run_phase", "Reset Deasserted", UVM_LOW);

                `uvm_info("run_phase", "Stimulus Generation Started", UVM_LOW);
                main_seq.start(env.agt.sqr);
                `uvm_info("run_phase", "Stimulus Generation Ended", UVM_LOW);
            phase.drop_objection(this);
        endtask //
    endclass //
endpackage
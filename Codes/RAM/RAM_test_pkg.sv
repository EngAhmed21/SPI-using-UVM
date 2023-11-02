package RAM_test_pkg;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import RAM_env_pkg::*;
    import RAM_config_obj_pkg::*;
    import RAM_sequence_pkg::*;

    class RAM_test extends uvm_test;
        `uvm_component_utils(RAM_test)

        RAM_env env;
        RAM_config_obj config_obj_test;
        RAM_rst_sequence rst_seq;
        RAM_write_only_sequence write_only_seq;
        RAM_read_only_sequence read_only_seq;
        RAM_write_read_sequence write_read_seq;

        function new(string name = "RAM_test", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new()

        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            env             = RAM_env::type_id::create("env", this);
            config_obj_test = RAM_config_obj::type_id::create("config_obj_test");
            rst_seq         = RAM_rst_sequence::type_id::create("rst_seq");
            write_only_seq  = RAM_write_only_sequence::type_id::create("write_only_seq");
            read_only_seq   = RAM_read_only_sequence::type_id::create("read_only_seq");
            write_read_seq  = RAM_write_read_sequence::type_id::create("write_read_seq");

            if (!uvm_config_db #(virtual RAM_intf #(MEM_DEPTH).TEST)::get(this, "", "RAM_intf", config_obj_test.RAM_config_if))
                `uvm_fatal("build_phase", "Test-unable to get the virtual interface of the RAM from the uvm_config_db")
            uvm_config_db #(RAM_config_obj)::set(this, "*", "CONFIG", config_obj_test);
        endfunction


        task run_phase (uvm_phase phase);
            super.run_phase(phase);
            phase.raise_objection(this);
                `uvm_info("run_phase", "Reset Asserted", UVM_LOW);
                rst_seq.start(env.agt.sqr);
                `uvm_info("run_phase", "Reset Deasserted", UVM_LOW);

                `uvm_info("run_phase", "Stimulus Generation Started", UVM_LOW);

                `uvm_info("run_phase", "Write Only Sequence Started", UVM_LOW);
                write_only_seq.start(env.agt.sqr);
                `uvm_info("run_phase", "Write Only Sequence Ended", UVM_LOW);

                `uvm_info("run_phase", "Read Only Sequence Started", UVM_LOW);
                read_only_seq.start(env.agt.sqr);
                `uvm_info("run_phase", "Read Only Sequence Ended", UVM_LOW);

                `uvm_info("run_phase", "Write-Read Sequence Started", UVM_LOW);
                write_read_seq.start(env.agt.sqr);
                `uvm_info("run_phase", "Write-Read Sequence Ended", UVM_LOW);

                `uvm_info("run_phase", "Stimulus Generation Ended", UVM_LOW);
            phase.drop_objection(this);
        endtask //
    endclass //
endpackage
package RAM_config_obj_pkg;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class RAM_config_obj extends uvm_object;
        `uvm_object_utils(RAM_config_obj)

        virtual RAM_intf#(MEM_DEPTH) RAM_config_if;
        uvm_active_passive_enum active;

        function new(string name = "RAM_config_obj");
            super.new(name);
        endfunction //new()
    endclass //
    
endpackage
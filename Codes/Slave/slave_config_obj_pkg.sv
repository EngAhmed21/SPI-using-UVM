package slave_config_obj_pkg;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class slave_config_obj extends uvm_object;
        `uvm_object_utils(slave_config_obj)

        virtual slave_intf #(MEM_DEPTH) slave_config_if;

        function new(string name = "slave_config_obj");
            super.new(name);
        endfunction //new()
    endclass //
    
endpackage
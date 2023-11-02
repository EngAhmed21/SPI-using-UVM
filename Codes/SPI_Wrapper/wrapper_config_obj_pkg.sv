package wrapper_config_obj_pkg;
    import uvm_pkg::*;
    import shared_pkg::*;
    `include "uvm_macros.svh"

    class wrapper_config_obj extends uvm_object;
        `uvm_object_utils(wrapper_config_obj)

        virtual wrapper_intf #(MEM_DEPTH) wrapper_config_if;
        uvm_active_passive_enum active;

        function new(string name = "wrapper_config_obj");
            super.new(name);
        endfunction //new()
    endclass //
    
endpackage
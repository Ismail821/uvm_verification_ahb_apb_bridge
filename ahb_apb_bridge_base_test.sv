
class ahb_apb_bridge_base_test extends uvm_test;
    `uvm_component_utils (ahb_apb_bridge_base_test)

    ahb_apb_bridge_env_config env_config_h;
    ahb_apb_bridge_environment environment_h;

    function new(string name = "ahb_apb_base_test",uvm_component parent = null);
   
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);

        env_config_h = ahb_apb_bridge_env_config::type_id::create("env_config_h");
        uvm_config_db #(ahb_apb_bridge_env_config)::set(this,"*","ahb_apb_bridge_env_config",env_config_h);

        if(!uvm_config_db #(virtual ahb_interface)::get(this,"","ahb_vif",env_config_h.ahb_vif))
            `uvm_fatal (get_type_name,"cannot get () ahb_interface - ahb_vif from uvm_config_db");
        if(!uvm_config_db #(virtual apb_interface)::get(this,"","apb_vif",env_config_h.apb_vif))
            `uvm_fatal (get_type_name,"cannot get () apb_interface - apb_vif from uvm_config_db");

        env_config_h.has_ahb_agent  = 1;
        env_config_h.has_apb_agent  = 1;
        env_config_h.has_scoreboard = 1;

        env_config_h.ahb_agent_is_active = UVM_ACTIVE;
        env_config_h.apb_agent_is_active = UVM_ACTIVE;

        environment_h   = ahb_apb_bridge_environment::type_id::create("env_h",this);
    endfunction
endclass

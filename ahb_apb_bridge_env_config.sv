class ahb_apb_bridge_env_config extends uvm_object;
    `uvm_object_utils(ahb_apb_bridge_env_config)

    bit has_ahb_agent;
    bit has_apb_agent;
    bit has_scoreboard;

    uvm_active_passive_enum ahb_agent_is_active;
    uvm_active_passive_enum apb_agent_is_active;

    virtual ahb_interface ahb_vif;
    virtual apb_interface apb_vif;

    function new (string name = "ahb_apb_bridge_env_config");

        super.new(name);

    endfunction

endclass
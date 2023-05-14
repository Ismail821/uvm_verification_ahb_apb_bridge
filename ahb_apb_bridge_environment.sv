class ahb_apb_bridge_environment extends uvm_env;
    `uvm_component_utils(ahb_apb_bridge_environment)

    ahb_apb_bridge_env_config   env_config_h;
    ahb_agent                   ahb_agent_h;
    apb_agent                   apb_agent_h;
    ahb_apb_bridge_scoreboard   scoreboard_h;

    function new (string name = "ahb_apb_bridge_environment", uvm_component parent = null);

        super.new(name,parent);

    endfunction

    function void build_phase(uvm_phase phase);

        if(!uvm_config_db # (ahb_apb_bridge_env_config) :: get (this,"*","ahb_apb_bridge_env_config",env_config_h))
            `uvm_fatal(get_type_name, "cannot get from config db. Have you set() it?")

        if(env_config_h.has_ahb_agent)
            ahb_agent_h = ahb_agent::type_id::create("ahb_agent_h",this);
        if(env_config_h.has_apb_agent)
            apb_agent_h = apb_agent::type_id::create("apb_agent_h",this);
        if(env_config_h.has_scoreboard)
            scoreboard_h = ahb_apb_bridge_scoreboard::type_id::create("scoreboard_h",this);

        super.build_phase(phase);

    endfunction

    function void connect_phase(uvm_phase phase);

        uvm_top.print_topology();

        if(env_config_h.has_ahb_agent && env_config_h.has_scoreboard)
            ahb_agent_h.monitor_h.monitor_port.connect(scoreboard_h.ahb_monitor_fifo.analysis_export);
        if(env_config_h.has_apb_agent && env_config_h.has_scoreboard)
            apb_agent_h.monitor_h.monitor_port.connect(scoreboard_h.apb_monitor_fifo.analysis_export);

    endfunction

endclass
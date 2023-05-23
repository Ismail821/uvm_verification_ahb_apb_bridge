/*
-----------AHB AGENT--------------
AHB Agent is responsible for emulating the AHB side of the transaction
for the AHB - APB bridge. It consists of a Driver and a monitor to drive 
and observe signals
*/


class ahb_agent extends uvm_agent;
    `uvm_component_utils(ahb_agent)

    ahb_driver      driver_h;
    ahb_sequencer   sequencer_h;
    ahb_monitor     monitor_h;
    ahb_apb_bridge_env_config   env_config_h;


    function new (string name = "ahb_agent", uvm_component parent=null);

        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if(!uvm_config_db #(ahb_apb_bridge_env_config)::get(this,"","ahb_apb_bridge_env_config",env_config_h))
            `uvm_fatal("CONFIG","Cannot Get environment configuration from uvm_config_db. Have you set () it")
        monitor_h   = ahb_monitor::type_id::create("monitor_h",this);
        
        if(env_config_h.ahb_agent_is_active == UVM_ACTIVE)
        begin
            driver_h    = ahb_driver::type_id::create("driver_h",this);
            sequencer_h = ahb_sequencer::type_id::create("sequencer_h",this);
        end
    endfunction

    function void connect_phase (uvm_phase phase);

        if(env_config_h.ahb_agent_is_active == UVM_ACTIVE)
        begin
            driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
        end
    endfunction
endclass

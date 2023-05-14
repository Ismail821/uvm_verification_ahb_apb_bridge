class ahb_monitor extends uvm_monitor;
    `uvm_component_utils(ahb_monitor)

    virtual ahb_interface.AHB_MONITOR monitor_interface;

    ahb_sequence_item           monitor2scoreboard_pkt;
    ahb_apb_bridge_env_config   env_config_h;

    uvm_analysis_port # (ahb_sequence_item) monitor_port;

    function new (string name = "ahb_monitor", uvm_component parent);

        super.new(name,parent);

    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if(!uvm_config_db # (ahb_apb_bridge_env_config) :: get(this,"","ahb_apb_bridge_env_config",env_config_h))
            `uvm_fatal(get_type_name, "cannot get () env_config_h")

        monitor_port = new("monitor_port",this);

    endfunction

    function void connect_phase(uvm_phase phase);

        monitor_interface = env_config_h.ahb_vif;

    endfunction

    task run_phase (uvm_phase phase);

        @(posedge monitor_interface.clock);
        forever
            monitor();

    endtask

    task monitor();

        begin
            
            @(posedge monitor_interface.clock);
            monitor2scoreboard_pkt = ahb_sequence_item::type_id::create("monitor2scoreboard_pkt",this);

            monitor2scoreboard_pkt.HRESETn  = monitor_interface.ahb_monitor_cb.HRESETn;
            monitor2scoreboard_pkt.HADDR    = monitor_interface.ahb_monitor_cb.HADDR;
            monitor2scoreboard_pkt.HTRANS   = monitor_interface.ahb_monitor_cb.HTRANS;
            monitor2scoreboard_pkt.HWRITE   = monitor_interface.ahb_monitor_cb.HWRITE;
            monitor2scoreboard_pkt.HWDATA   = monitor_interface.ahb_monitor_cb.HWDATA;
            monitor2scoreboard_pkt.HSELAHB  = monitor_interface.ahb_monitor_cb.HSELAHB;
            monitor2scoreboard_pkt.HRDATA   = monitor_interface.ahb_monitor_cb.HRDATA;
            monitor2scoreboard_pkt.HREADY   = monitor_interface.ahb_monitor_cb.HREADY;
            monitor2scoreboard_pkt.HRESP    = monitor_interface.ahb_monitor_cb.HRESP;

            `uvm_info(get_type_name, $sformatf("ahb monitor has captured below transaction \n%s", monitor2scoreboard_pkt.sprint()),UVM_MEDIUM)

            monitor_port.write(monitor2scoreboard_pkt);
        end     
    endtask
endclass
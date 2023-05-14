class apb_monitor extends uvm_monitor;
    `uvm_component_utils(apb_monitor)

    virtual apb_interface.APB_MONITOR monitor_interface;

    apb_sequence_item           monitor2scoreboard_pkt;
    ahb_apb_bridge_env_config   env_config_h;

    uvm_analysis_port # (apb_sequence_item) monitor_port;

    function new (string name = "apb_monitor", uvm_component parent);

        super.new(name,parent);

    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if(!uvm_config_db # (ahb_apb_bridge_env_config) :: get(this,"","ahb_apb_bridge_env_config",env_config_h))
            `uvm_fatal(get_type_name, "cannot get () env_config_h")

        monitor_port = new("monitor_port",this);

    endfunction

    function void connect_phase(uvm_phase phase);

        monitor_interface = env_config_h.apb_vif;

    endfunction

    task run_phase (uvm_phase phase);

        @(posedge monitor_interface.clock);
        forever
            monitor();

    endtask

    task monitor();

        begin
            
            @(posedge monitor_interface.clock);
            monitor2scoreboard_pkt = apb_sequence_item::type_id::create("monitor2scoreboard_pkt",this);

            monitor2scoreboard_pkt.PRDATA   = monitor_interface.apb_monitor_cb.PRDATA;
            monitor2scoreboard_pkt.PSLVERR  = monitor_interface.apb_monitor_cb.PSLVERR;
            monitor2scoreboard_pkt.PREADY   = monitor_interface.apb_monitor_cb.PREADY;
            monitor2scoreboard_pkt.PWDATA   = monitor_interface.apb_monitor_cb.PWDATA;
            monitor2scoreboard_pkt.PENABLE  = monitor_interface.apb_monitor_cb.PENABLE;
            monitor2scoreboard_pkt.PSELx    = monitor_interface.apb_monitor_cb.PSELx;
            monitor2scoreboard_pkt.PADDR    = monitor_interface.apb_monitor_cb.PADDR;
            monitor2scoreboard_pkt.PWRITE   = monitor_interface.apb_monitor_cb.PWRITE;


            `uvm_info(get_type_name, $sformatf("apb monitor has captured below transaction \n%s", monitor2scoreboard_pkt.sprint()),UVM_MEDIUM)

            monitor_port.write(monitor2scoreboard_pkt);

        end     

    endtask

endclass
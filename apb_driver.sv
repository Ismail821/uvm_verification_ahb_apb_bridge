class apb_driver extends uvm_driver # (apb_sequence_item);
    `uvm_component_utils(apb_driver)

    virtual apb_interface.APB_DRIVER driver_interface;

    apb_sequence_item   driver2dut_pkt;
    ahb_apb_bridge_env_config   env_config_h;


    function new (string name = "apb_driver", uvm_component parent = null);

        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);
        
        if(!uvm_config_db # (ahb_apb_bridge_env_config) :: get(this,"","ahb_apb_bridge_env_config", env_config_h))
            `uvm_fatal ("CONFIG","cannot get () env_config_h from uvm_config_db. Have you set() it? ")
    endfunction


    function void connect_phase(uvm_phase phase);

        driver_interface = env_config_h.apb_vif;
    endfunction

    task run_phase(uvm_phase phase);

        forever 
        begin

            seq_item_port.get_next_item(req);
            drive_packet(req);
            seq_item_port.item_done();
        end
    endtask

    virtual task drive_packet (apb_sequence_item driver2dut_pkt);

        @(posedge driver_interface.clock);

        driver_interface.apb_driver_cb.PRDATA   <= driver2dut_pkt.PRDATA;
        driver_interface.apb_driver_cb.PSLVERR  <= driver2dut_pkt.PSLVERR;
        driver_interface.apb_driver_cb.PREADY   <= driver2dut_pkt.PREADY;

        `uvm_info(get_type_name, $sformatf("apb driver has captured below transaction \n%s", driver2dut_pkt.sprint()),UVM_MEDIUM)
    endtask
endclass
`ifndef READ
    `define READ 1'b0
`endif 
`ifndef T_IDLE
    `define T_IDLE      2'b00
`endif
`ifndef T_BUSY
    `define T_BUSY      2'b01
`endif
`ifndef T_NONSEQ
    `define T_NONSEQ    2'b10
`endif
`ifndef T_SEQ
    `define T_SEQ       2'b11
`endif
`ifndef DATA_WIDTH
    `define DATA_WIDTH  32
`endif
// `ifndef READY
//     `define READY       1'b1;
// `endif


class ahb_driver extends uvm_driver #(ahb_sequence_item);
    `uvm_component_utils(ahb_driver)

    virtual ahb_interface.AHB_DRIVER driver_interface;
    ahb_sequence_item driver2dut_pkt;
    ahb_apb_bridge_env_config env_config_h;

    static bit [`DATA_WIDTH-1:0] HWDATA_Temp;
    static int Write_Pending;

    function new (string name = "ahb_driver",uvm_component parent);

        super.new (name, parent);
    endfunction

    function void build_phase (uvm_phase phase);

        super.build_phase(phase);
        if(!uvm_config_db #(ahb_apb_bridge_env_config)::get (this,"","ahb_apb_bridge_env_config",env_config_h))
            `uvm_fatal ("CONFIG", "cannot get() configuration from uvm_config_db. Have you set it?")
    endfunction

    function void connect_phase (uvm_phase phase);

        driver_interface = env_config_h.ahb_vif;
    endfunction

    task run_phase (uvm_phase phase);

        forever
        begin

            seq_item_port.get_next_item(req);
            drive_packet(req);
            seq_item_port.item_done();    
        end
    endtask


    virtual task drive_packet (ahb_sequence_item driver2dut_pkt);
        
        @(posedge driver_interface.clock)

        wait((driver_interface.ahb_driver_cb.HREADY));
        driver2dut_pkt.HREADY = driver_interface.ahb_driver_cb.HREADY;
        

        if(!(driver2dut_pkt.HTRANS == `T_BUSY))
        begin      

            driver_interface.ahb_driver_cb.HRESETn <=  driver2dut_pkt.HRESETn;
            driver_interface.ahb_driver_cb.HSELAHB <=  driver2dut_pkt.HSELAHB;

            driver_interface.ahb_driver_cb.HADDR   <=  driver2dut_pkt.HADDR;
            driver_interface.ahb_driver_cb.HTRANS  <=  driver2dut_pkt.HTRANS;
            driver_interface.ahb_driver_cb.HWRITE  <=  driver2dut_pkt.HWRITE;

            if(driver2dut_pkt.HWRITE == `READ)
                driver_interface.ahb_driver_cb.HWDATA  <=  `DATA_WIDTH'hxxxx_xxxx;
            else
            begin
                if(driver2dut_pkt.HTRANS == `T_NONSEQ)
                begin

                    HWDATA_Temp  <=  driver2dut_pkt.HWDATA;
                    Write_Pending <= 1;
                end
                else if (driver2dut_pkt.HTRANS == `T_SEQ)
                begin

                    HWDATA_Temp                             <= driver2dut_pkt.HWDATA;
                    driver_interface.ahb_driver_cb.HWDATA   <= HWDATA_Temp;
                    Write_Pending <= 1;
                end
                else if (driver2dut_pkt.HTRANS == `T_IDLE)
                begin
                    if(Write_Pending == 1)
                    begin
                        driver_interface.ahb_driver_cb.HWDATA   <= HWDATA_Temp;
                        Write_Pending   <= 0;
                    end
                end
            end 
        end
        `uvm_info(get_type_name,$sformatf("Driver has driven the following transaction\n%s" ,driver2dut_pkt.sprint()), UVM_MEDIUM)
    endtask
endclass
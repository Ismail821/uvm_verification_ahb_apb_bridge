
class ahb_apb_bridge_scoreboard extends uvm_scoreboard;
    `uvm_component_utils (ahb_apb_bridge_scoreboard)

    uvm_tlm_analysis_fifo #(ahb_sequence_item) ahb_monitor_fifo;
    uvm_tlm_analysis_fifo #(apb_sequence_item) apb_monitor_fifo;

    ahb_sequence_item ahb_monitor_packet;
    apb_sequence_item apb_monitor_packet;
    ahb_sequence_item expected_ahb_packet;
    apb_sequence_item expected_apb_packet;
    ahb_sequence_item coverage_data_packet;

    ahb_sequence_item ahb_transaction_temp1;

    int data_verified = 0;
    int ahb_monitor_packet_count = 0;
    int apb_monitor_packet_count = 0;
    bit skip_transaction;
    int Slave_number;
    

    covergroup coverage; 

        option.per_instance = 1;

        DUT_RESET   : coverpoint coverage_data_packet.HRESETn   {bins dev_reset = {0};  }

        WRITE       : coverpoint coverage_data_packet.HWRITE    {bins write = {1};      }

        READ        : coverpoint coverage_data_packet.HWRITE    {bins read  = {0};      }

        ADDRESS_GROUP : coverpoint coverage_data_packet.HADDR   {bins APB_SLAVE1 = {[32'h000:32'h0FF]};
                                                                 bins APB_SLAVE2 = {[32'h100:32'h1FF]};
                                                                 bins APB_SLAVE3 = {[32'h200:32'h2FF]};
                                                                 bins APB_SLAVE4 = {[32'h300:32'h3FF]};
                                                                 bins APB_SLAVE5 = {[32'h400:32'h4FF]};
                                                                 bins APB_SLAVE6 = {[32'h500:32'h5FF]};
                                                                 bins APB_SLAVE7 = {[32'h600:32'h6FF]};
                                                                 bins APB_SLAVE8 = {[32'h700:32'h7FF]};
                                                                }        

        TRANSACTION  : coverpoint coverage_data_packet.HTRANS   {bins idle      = {2'b00};
                                                                 bins nonseq    = {2'b10};
                                                                 bins sequen    = {2'b11};
                                                                }

        WRITE_CROSS_COVERAGE: cross WRITE, ADDRESS_GROUP;

        READ_CROSS_COVERAGE: cross READ, ADDRESS_GROUP;


    endgroup

    function new (string name, uvm_component parent);

        super.new(name, parent);
        
        ahb_monitor_fifo    = new("ahb_monitor_fifo", this);
        apb_monitor_fifo    = new("apb_monitor_fifo", this);
        expected_ahb_packet = ahb_sequence_item::type_id::create("expected_ahb_packet"      ,this);
        expected_apb_packet = apb_sequence_item::type_id::create("expected_apb_packet"      ,this);
        ahb_transaction_temp1  = ahb_sequence_item::type_id::create("ahb_transaction_temp1" ,this);
        coverage = new;
    endfunction

    task run_phase (uvm_phase phase);

        forever
        begin

            ahb_monitor_fifo.get(ahb_monitor_packet);
            ahb_monitor_packet_count++;
            `uvm_info (get_type_name,$sformatf("[%0d] Scoreboard has got the following packet from the ahb_monitor\n%s",ahb_monitor_packet_count, ahb_monitor_packet.sprint()), UVM_MEDIUM)

            apb_monitor_fifo.get(apb_monitor_packet);
            apb_monitor_packet_count++;
            `uvm_info (get_type_name,$sformatf("[%0d] Scoreboard has got the following packet from the apb_monitor\n%s",apb_monitor_packet_count, apb_monitor_packet.sprint()), UVM_MEDIUM)
        
            reference_model();
            coverage_data_packet = ahb_monitor_packet;
            coverage.sample();
        end
    endtask

    task reference_model();

        if(ahb_monitor_packet.HRESETn == 1'b0)
        begin
            //skip_transaction
        end
        else
            if(ahb_monitor_packet.HTRANS == 2'b10)
            begin
                
                ahb_transaction_temp1.HADDR     = ahb_monitor_packet.HADDR;
                ahb_transaction_temp1.HWRITE    = ahb_monitor_packet.HWRITE;
            end
            else if (ahb_monitor_packet.HTRANS == 2'b11)
            begin
                
                expected_apb_packet.PADDR    = ahb_transaction_temp1.HADDR;
                expected_apb_packet.PWRITE   = ahb_transaction_temp1.HWRITE;
                expected_apb_packet.PWDATA   = ahb_monitor_packet.HWDATA;

                if(ahb_transaction_temp1.HADDR >= 32'h000 && ahb_transaction_temp1.HADDR < 32'h0FF)
                    expected_apb_packet.PSELx = 8'h01;
                else if (ahb_transaction_temp1.HADDR >= 32'h100 && ahb_transaction_temp1.HADDR < 32'h1FF)
                    expected_apb_packet.PSELx = 8'h02;
                else if (ahb_transaction_temp1.HADDR >= 32'h200 && ahb_transaction_temp1.HADDR < 32'h2FF)
                    expected_apb_packet.PSELx = 8'h04;
                else if (ahb_transaction_temp1.HADDR >= 32'h300 && ahb_transaction_temp1.HADDR < 32'h3FF)
                    expected_apb_packet.PSELx = 8'h08;
                else if (ahb_transaction_temp1.HADDR >= 32'h400 && ahb_transaction_temp1.HADDR < 32'h4FF)
                    expected_apb_packet.PSELx = 8'h10;
                else if (ahb_transaction_temp1.HADDR >= 32'h500 && ahb_transaction_temp1.HADDR < 32'h5FF)
                    expected_apb_packet.PSELx = 8'h20;
                else if (ahb_transaction_temp1.HADDR >= 32'h600 && ahb_transaction_temp1.HADDR < 32'h6FF)
                    expected_apb_packet.PSELx = 8'h40;
                else if (ahb_transaction_temp1.HADDR >= 32'h700 && ahb_transaction_temp1.HADDR < 32'h7FF)
                    expected_apb_packet.PSELx = 8'h80;

                ahb_transaction_temp1.HADDR     = ahb_monitor_packet.HADDR;
                ahb_transaction_temp1.HWRITE    = ahb_monitor_packet.HWRITE;          
                validate_apb();  
            end
            else if(ahb_monitor_packet.HTRANS == 2'b00)
            begin
                
                expected_apb_packet.PADDR    = ahb_transaction_temp1.HADDR;
                expected_apb_packet.PWRITE   = ahb_transaction_temp1.HWRITE;
                expected_apb_packet.PWDATA   = ahb_monitor_packet.HWDATA;

                if(ahb_transaction_temp1.HADDR >= 32'h000 && ahb_transaction_temp1.HADDR < 32'h0FF)
                    expected_apb_packet.PSELx = 8'h01;
                else if (ahb_transaction_temp1.HADDR >= 32'h100 && ahb_transaction_temp1.HADDR < 32'h1FF)
                    expected_apb_packet.PSELx = 8'h02;
                else if (ahb_transaction_temp1.HADDR >= 32'h200 && ahb_transaction_temp1.HADDR < 32'h2FF)
                    expected_apb_packet.PSELx = 8'h04;
                else if (ahb_transaction_temp1.HADDR >= 32'h300 && ahb_transaction_temp1.HADDR < 32'h3FF)
                    expected_apb_packet.PSELx = 8'h08;
                else if (ahb_transaction_temp1.HADDR >= 32'h400 && ahb_transaction_temp1.HADDR < 32'h4FF)
                    expected_apb_packet.PSELx = 8'h10;
                else if (ahb_transaction_temp1.HADDR >= 32'h500 && ahb_transaction_temp1.HADDR < 32'h5FF)
                    expected_apb_packet.PSELx = 8'h20;
                else if (ahb_transaction_temp1.HADDR >= 32'h600 && ahb_transaction_temp1.HADDR < 32'h6FF)
                    expected_apb_packet.PSELx = 8'h40;
                else if (ahb_transaction_temp1.HADDR >= 32'h700 && ahb_transaction_temp1.HADDR < 32'h7FF)
                    expected_apb_packet.PSELx = 8'h80;
                
                validate_apb();
            end

            if(apb_monitor_packet.PENABLE == 1'b1 & apb_monitor_packet.PWRITE == 1'b0)
            begin
                
                if(apb_monitor_packet.PADDR >= 32'h000 && apb_monitor_packet.PADDR < 32'h0FF)
                    Slave_number = 3'd1;
                else if (apb_monitor_packet.PADDR >= 32'h100 && apb_monitor_packet.PADDR < 32'h1FF)
                    Slave_number = 3'd1;
                else if (apb_monitor_packet.PADDR >= 32'h200 && apb_monitor_packet.PADDR < 32'h2FF)
                    Slave_number = 3'd2;
                else if (apb_monitor_packet.PADDR >= 32'h300 && apb_monitor_packet.PADDR < 32'h3FF)
                    Slave_number = 3'd3;
                else if (apb_monitor_packet.PADDR >= 32'h400 && apb_monitor_packet.PADDR < 32'h4FF)
                    Slave_number = 3'd4;
                else if (apb_monitor_packet.PADDR >= 32'h500 && apb_monitor_packet.PADDR < 32'h5FF)
                    Slave_number = 3'd5;
                else if (apb_monitor_packet.PADDR >= 32'h600 && apb_monitor_packet.PADDR < 32'h6FF)
                    Slave_number = 3'd6;
                else if (apb_monitor_packet.PADDR >= 32'h700 && apb_monitor_packet.PADDR < 32'h7FF)
                    Slave_number = 3'd7;

                expected_ahb_packet.HRDATA   = apb_monitor_packet.PRDATA[Slave_number];
                validate_ahb();
            end
    endtask

    task validate_apb();

        if(expected_apb_packet.PADDR    == apb_monitor_packet.PADDR);
        if(expected_apb_packet.PWRITE   == apb_monitor_packet.PWRITE);
        if(expected_apb_packet.PSELx    == apb_monitor_packet.PSELx);
        if(expected_apb_packet.PWDATA   == apb_monitor_packet.PWDATA);
            data_verified++;
    endtask

    task validate_ahb();

        if(expected_ahb_packet.HRDATA   == ahb_monitor_packet.HRDATA);
            data_verified++;
    endtask

    function void report_phase (uvm_phase phase);

        $display("\n---Scoreboard done---\n");
        $display ("Input monitor packet count = %0d, output monitor packet count = %0d, no of successful comparisions = %d\n", ahb_monitor_packet_count, apb_monitor_packet_count ,data_verified);
        $display ("-----------------------\n");
        $display ("---- Coverage-----\n");
        $display ("RESET Coverage: \t %0f", coverage.DUT_RESET.get_coverage());
        $display ("Address Coverage: \t %0f", coverage.ADDRESS_GROUP.get_coverage());
        $display ("Read Coverage: \t %0f", coverage.READ.get_coverage());
        $display ("Write Coverage: \t %0f", coverage.WRITE.get_coverage());
        $display ("Address Write Coverage: \t %0f", coverage.WRITE_CROSS_COVERAGE.get_coverage());
        $display ("Address Read Coverage: \t %0f\n", coverage.READ_CROSS_COVERAGE.get_coverage());


    endfunction
endclass

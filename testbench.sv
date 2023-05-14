
module ahb_apb_bridge_top();

	import ahb_apb_bridge_pkg :: *;
	import uvm_pkg :: *;
	
	parameter time_period = 10;
	reg clock;
	
	ahb_interface	AHB_INF (clock);
	apb_interface	APB_INF (clock);
	ahb2apb		DUT	(.HCLK (clock),
						 .HRESETn 	(AHB_INF.HRESETn),
						 .HADDR		(AHB_INF.HADDR),
						 .HTRANS	(AHB_INF.HTRANS),
						 .HWRITE	(AHB_INF.HWRITE),
						 .HWDATA	(AHB_INF.HWDATA),
						 .HSELAHB	(AHB_INF.HSELAHB),
						 
						 .HRDATA	(AHB_INF.HRDATA),
						 .HREADY	(AHB_INF.HREADY),
						 .HRESP		(AHB_INF.HRESP),

						 .PRDATA	(APB_INF.PRDATA),
						 .PSLVERR	(APB_INF.PSLVERR),
						 .PREADY	(APB_INF.PREADY),

						 .PWDATA	(APB_INF.PWDATA),
						 .PENABLE	(APB_INF.PENABLE),
						 .PSELx		(APB_INF.PSELx),
						 .PADDR		(APB_INF.PADDR),
						 .PWRITE	(APB_INF.PWRITE)
						);
	
	initial	begin
	
		$dumpfile("ahb_apb_bridge.vcd");
		$dumpvars;
		
		uvm_config_db # (virtual ahb_interface) :: set(null,"*","ahb_vif",AHB_INF);
		uvm_config_db # (virtual apb_interface) :: set(null,"*","apb_vif",APB_INF);
		
		run_test();
	
	end
	
	initial	begin
	
		clock = 1'b0;
		forever
			#(time_period/2) clock = ~clock;
	
	end

endmodule

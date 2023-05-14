	
//	MACROS
	`define	T_IDLE		2'b00
	`define	T_BUSY 		2'b01
	`define	T_NONSEQ	2'b10
	`define	T_SEQ		2'b11

	`define	PSELx_Default	8'b0

	`define VALID	1'b1
	`define INVALID	1'b0

	`define ENABLE	1'b1
	`define DISABLE_	1'b0

	`define READY		1'b1
	`define NOT_READY	1'b0

	`define	WRITE	1'b1
	`define	READ	1'b0

	`define	RESET	1'b0
	
	`define ERROR		1'b1
	`define NO_ERROR	1'b0
	
	`define SLAVE_1	8'h01
	`define SLAVE_2	8'h02
	`define SLAVE_3	8'h04
	`define SLAVE_4	8'h08
	`define SLAVE_5	8'h10
	`define SLAVE_6	8'h20
	`define SLAVE_7	8'h40
	`define SLAVE_8	8'h80
	`define SLAVE_DEFAULT	8'h01
	
	`define SLAVE_NO_1	3'd0
	`define SLAVE_NO_2	3'd1
	`define SLAVE_NO_3	3'd2
	`define SLAVE_NO_4	3'd3
	`define SLAVE_NO_5	3'd4
	`define SLAVE_NO_6	3'd5
	`define SLAVE_NO_7	3'd6
	`define SLAVE_NO_8	3'd7
	`define SLAVE_NO_DEFAULT	3'd0

module ahb2apb 
			   #(parameter NO_OF_SLAVES = 8,
			   	 parameter ADDR_WIDTH = 32,
			   	 parameter DATA_WIDTH = 32,
			   	 parameter SLAVE_START_ADDR_0 = 32'h000,
			   	 parameter SLAVE_END_ADDR_0 = 32'h0ff,
			   	 parameter SLAVE_START_ADDR_1 = 32'h100,
			   	 parameter SLAVE_END_ADDR_1 = 32'h1ff,
			   	 parameter SLAVE_START_ADDR_2 = 32'h200,
			   	 parameter SLAVE_END_ADDR_2 = 32'h2ff,
			   	 parameter SLAVE_START_ADDR_3 = 32'h300,
			   	 parameter SLAVE_END_ADDR_3 = 32'h3ff,
			   	 parameter SLAVE_START_ADDR_4 = 32'h400,
			   	 parameter SLAVE_END_ADDR_4 = 32'h4ff,
			   	 parameter SLAVE_START_ADDR_5 = 32'h500,
			   	 parameter SLAVE_END_ADDR_5 = 32'h5ff,
			   	 parameter SLAVE_START_ADDR_6 = 32'h600,
			   	 parameter SLAVE_END_ADDR_6 = 32'h6ff,
			   	 parameter SLAVE_START_ADDR_7 = 32'h700,
			   	 parameter SLAVE_END_ADDR_7 = 32'h7ff)
			   
			    (HCLK, HRESETn, HADDR, HTRANS, HWRITE, HWDATA, HSELAHB,
				 HRDATA, HREADY, HRESP,
				 PRDATA, PSLVERR, PREADY,
				 PWDATA, PENABLE, PSELx, PADDR, PWRITE);

// AHB SIGNALS

	input	wire 						HCLK;
	input	wire 						HRESETn;
	input	wire 	[ADDR_WIDTH - 1:0]	HADDR;
	input	wire 	[1:0]				HTRANS;
	input	wire						HWRITE;
	input	wire	[DATA_WIDTH - 1:0]	HWDATA;
	input	wire						HSELAHB;
	
	output	reg 	[DATA_WIDTH - 1:0]	HRDATA;
	output	reg 						HREADY;
	output	reg 						HRESP;
	
// APB SIGNALS
	
	input	wire 	[DATA_WIDTH - 1:0]  PRDATA	[NO_OF_SLAVES - 1:0];
	input	wire	[NO_OF_SLAVES - 1:0]PSLVERR;
	input 	wire 	[NO_OF_SLAVES - 1:0]PREADY;
	
	output	reg 	[DATA_WIDTH - 1:0]	PWDATA;
	output	reg 						PENABLE;
	output	reg 	[NO_OF_SLAVES - 1:0]PSELx;
	output	reg 	[ADDR_WIDTH - 1:0]	PADDR;
	output	reg 						PWRITE;
	
// INTERNAL SIGNALS

			reg		[ADDR_WIDTH - 1:0]	HADDR_Temp;
			reg		[DATA_WIDTH - 1:0]	HWDATA_Temp;
			reg		[NO_OF_SLAVES - 1:0]PSELx_Temp;
			reg		[NO_OF_SLAVES - 1:0]PSELx_Curr;
			reg		[2:0]				Slave_number;
			
// STATES
			
	typedef enum {IDLE, READ, W_WAIT, WRITE,
				  WRITE_P, W_ENABLE, W_ENABLE_P, R_ENABLE} states;
				  
			states	current_state;
			states	next_state;
			
// CONTROL SIGNALS
			
			reg		valid;
			reg		HWRITE_Reg;
		
// CONTROL SIGNALS ASSIGNMENT
			
	always @ (*)
	begin
		
		if(HSELAHB && (HTRANS == `T_NONSEQ || HTRANS == `T_SEQ))
			valid = `VALID;
		else
			valid = `INVALID;
		
		if(HRESETn == `RESET)
			next_state = IDLE; 
	end

//STATE CHANGE ASSIGNMENT 

	always @ (posedge HCLK)
	begin
		
		if(PSLVERR[Slave_number] == `NO_ERROR)
		begin
			current_state 	= next_state;
			HRESP			= `NO_ERROR;
		end
		else
		begin
			current_state 	= IDLE;
			HRESP			= `ERROR;
		end
	
	end	

//MAIN FSM		

	always @ (posedge HCLK)
	begin
	
		case (current_state)
		
			IDLE:	begin
			
				PSELx 	= `PSELx_Default;
				PENABLE = `DISABLE_;
				HREADY	= `READY;
				
				if(valid == `INVALID)
					next_state = IDLE;
				else if (valid == `VALID)
					if(HWRITE == `READ)
						next_state = READ;
					else if (HWRITE == `WRITE)
						next_state = W_WAIT;
			end
			
			READ:	begin
			
				PSELx	= PSELx_Curr;
				PADDR	= HADDR;
				PWRITE	= `READ;
				PENABLE	= `DISABLE_;
				HREADY	= `NOT_READY;

				next_state = R_ENABLE;	
			end
			
			W_WAIT:	begin

				PENABLE		= `DISABLE_;
				HADDR_Temp	= HADDR;
				PSELx_Temp	= PSELx_Curr;
				HWRITE_Reg	= HWRITE;

				if(valid == `INVALID)
					next_state = WRITE;
				else if(valid == `VALID)
					next_state = WRITE_P;
			end
			
			WRITE:	begin

				PSELx 	= PSELx_Temp;
				PADDR 	= HADDR_Temp;
				PWDATA 	= HWDATA;
				PWRITE 	= `WRITE;
				PENABLE = `DISABLE_;
				HREADY 	= `NOT_READY;

				if(valid == `INVALID)
					next_state = W_ENABLE;
				else if (valid == `VALID)
					next_state = W_ENABLE_P;
			end
			
			WRITE_P:	begin

				PSELx 		= PSELx_Temp;
				PADDR 		= HADDR_Temp;
				PWDATA		= HWDATA;
				PWRITE		= `WRITE;
				PENABLE		= `DISABLE_;
				HREADY		= `NOT_READY;
				HADDR_Temp	= HADDR;
				HWRITE_Reg	= HWRITE;
				PSELx_Temp	= PSELx_Curr;

				next_state = W_ENABLE_P;
			end
			
			W_ENABLE:	begin
				if(PREADY[Slave_number]==`READY)
				begin
					PENABLE	= `ENABLE;
					HREADY	= `READY;
	
					if(valid == `VALID && HWRITE == `READ)
						next_state = READ;
					else if (valid == `VALID && HWRITE ==`WRITE)
						next_state = W_WAIT;
						 else if (valid == `INVALID)
							next_state = IDLE;
				end
				else
					next_state = W_ENABLE;
			end
			
			W_ENABLE_P:	begin
				if(PREADY[Slave_number]==`READY)
				begin
					PENABLE = `ENABLE;
					HREADY 	= `READY;
	
					if(valid == `INVALID && HWRITE == `WRITE)
						next_state = WRITE;
					else if (valid == `VALID && HWRITE == `WRITE)
						next_state = WRITE_P;
						else if(HWRITE == `READ)
							next_state = READ;
				end
				else
					next_state = W_ENABLE_P;			
			end
			
			R_ENABLE:	begin
				if(PREADY[Slave_number]==`READY)
				begin
					PENABLE	= `ENABLE;
					HRDATA 	= PRDATA[Slave_number];
					HREADY	= `READY;
	
					if(valid == `INVALID)
						next_state = IDLE;
					else if(HWRITE == `READ)
						next_state = READ;
					else if (HWRITE == `WRITE)
						next_state = W_WAIT;
				end
				else
					next_state = R_ENABLE;					
			end
		endcase
	end
	
//SLAVE SELECTOR

	always @(*)
	begin

		PSELx_Curr			= `SLAVE_DEFAULT;
		Slave_number		= `SLAVE_NO_DEFAULT;
		if((HADDR >= SLAVE_START_ADDR_0) && (HADDR <= SLAVE_END_ADDR_0) && (NO_OF_SLAVES >= 1)) 
		begin
			PSELx_Curr 		= `SLAVE_1;
			Slave_number	= `SLAVE_NO_1;
		end
		if((HADDR >= SLAVE_START_ADDR_1) && (HADDR <= SLAVE_END_ADDR_1) && (NO_OF_SLAVES >= 2)) 
		begin	
			PSELx_Curr 		= `SLAVE_2;
			Slave_number	= `SLAVE_NO_2;
		end
		if((HADDR >= SLAVE_START_ADDR_2) && (HADDR <= SLAVE_END_ADDR_2) && (NO_OF_SLAVES >= 3)) 
		begin
			PSELx_Curr 		= `SLAVE_3;
			Slave_number	= `SLAVE_NO_3;
		end
		if((HADDR >= SLAVE_START_ADDR_3) && (HADDR <= SLAVE_END_ADDR_3) && (NO_OF_SLAVES >= 4)) 
		begin
			PSELx_Curr 		= `SLAVE_4;
			Slave_number	= `SLAVE_NO_4;
		end
		if((HADDR >= SLAVE_START_ADDR_4) && (HADDR <= SLAVE_END_ADDR_4) && (NO_OF_SLAVES >= 5)) 
		begin
			PSELx_Curr 		= `SLAVE_5;
			Slave_number	= `SLAVE_NO_5;
		end
		if((HADDR >= SLAVE_START_ADDR_5) && (HADDR <= SLAVE_END_ADDR_5) && (NO_OF_SLAVES >= 6)) 
		begin
			PSELx_Curr 		= `SLAVE_6;
			Slave_number	= `SLAVE_NO_6;
		end
		if((HADDR >= SLAVE_START_ADDR_6) && (HADDR <= SLAVE_END_ADDR_6) && (NO_OF_SLAVES >= 7)) 
		begin
			PSELx_Curr 		= `SLAVE_7;
			Slave_number	= `SLAVE_NO_7;
		end
		if((HADDR >= SLAVE_START_ADDR_7) && (HADDR <= SLAVE_END_ADDR_7) && (NO_OF_SLAVES >= 8)) 
		begin
			PSELx_Curr 		= `SLAVE_8;
			Slave_number	= `SLAVE_NO_8;
		end
	end

endmodule
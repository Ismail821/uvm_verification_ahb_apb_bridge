
`ifndef ADDRESS_WIDTH
    `define ADDRESS_WIDTH 32
`endif
`ifndef DATA_WIDTH
    `define DATA_WIDTH 32
`endif

class ahb_sequence_item extends uvm_sequence_item;
    `uvm_object_utils(ahb_sequence_item)

    rand bit                       HRESETn;
    rand bit [`ADDRESS_WIDTH-1:0]  HADDR;
    rand bit [1:0]                 HTRANS;
    rand bit                       HWRITE;
    rand bit [`DATA_WIDTH-1:0]     HWDATA;
    rand bit                       HSELAHB;
         bit [`DATA_WIDTH-1:0]     HRDATA;
         bit                       HREADY;
         bit                       HRESP;

static int ahb_no_of_transaction;


//constraints

constraint LOW_RESET        {HRESETn dist   {1:=9, 0:=1};}
constraint VALID_ADDRESS    {HADDR   inside {[32'h0:32'h7ff]}; }
constraint SELECT_BRIDGE    {HSELAHB dist   {1:=99, 0:=1};}

    function new(string name = "ahb_sequence_item");

        super.new(name);
    endfunction


//do print

    function void do_print(uvm_printer printer);

        super.do_print(printer);
        printer.print_field ("RESETn",this.HRESETn,     1, UVM_DEC);
        printer.print_field ("HADDR",this.HADDR,        3, UVM_DEC);
        printer.print_field ("HTRANS",this.HTRANS,      1, UVM_DEC);
        printer.print_field ("HWRITE",this.HWRITE,      1, UVM_DEC);
        printer.print_field ("HWDATA",this.HWDATA,      3, UVM_DEC);
        printer.print_field ("HSELAHB",this.HSELAHB,    1, UVM_DEC);
        printer.print_field ("HREADY",this.HREADY,    1, UVM_DEC);
    endfunction


//post randomize

    function void post_randomize();

        ahb_no_of_transaction ++;
        `uvm_info("AHB_SEQUENCE_ITEM", $sformatf("randomized transaction [%0d] is %s\n" ,ahb_no_of_transaction, this.sprint()),UVM_MEDIUM)
    endfunction
endclass



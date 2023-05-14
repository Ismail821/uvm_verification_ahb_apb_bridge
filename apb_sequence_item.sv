
class apb_sequence_item extends uvm_sequence_item;
    `uvm_object_utils(apb_sequence_item)

    rand bit [`DATA_WIDTH-1:0]     PRDATA [`NO_OF_SLAVES-1:0];
    rand bit [`NO_OF_SLAVES-1:0]   PSLVERR;
    rand bit [`NO_OF_SLAVES-1:0]   PREADY;
         bit [`NO_OF_SLAVES-1:0]   PWDATA;
         bit                       PENABLE;
         bit [`NO_OF_SLAVES-1:0]   PSELx;
         bit [`NO_OF_SLAVES-1:0]   PADDR;
         bit                       PWRITE;

     static int apb_no_of_transaction;

     constraint VALID_READY       {PREADY   dist {8'hFF:= 99, 8'h00:= 1};}
     constraint LOW_APB_ERROR     {PSLVERR  dist {8'hFF:= 99, 8'h00:= 1};}


     function new(string name = "apb_sequence_item");

          super.new(name);
     endfunction


     function void do_print(uvm_printer printer);

          super.do_print(printer);
          // printer.print_field("PRDATA",this.PRDATA    ,3,UVM_DEC);
          printer.print_field("PSLVERR",this.PSLVERR   ,1,UVM_DEC);
          printer.print_field("PREADY",this.PREADY     ,1,UVM_DEC);
     endfunction

     function void post_randomize();

          apb_no_of_transaction++;
           `uvm_info("APB_SEQUENCE_ITEM", $sformatf("randomized transaction [%0d] is %s\n" ,apb_no_of_transaction, this.sprint()),UVM_HIGH)
     endfunction
endclass
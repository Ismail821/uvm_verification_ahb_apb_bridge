`ifndef ADDRESS_WIDTH
    `define ADDRESS_WIDTH 32
`endif
`ifndef DATA_WIDTH
    `define DATA_WIDTH 32
`endif
`ifndef NO_OF_SLAVES
    `define NO_OF_SLAVES 8
`endif

interface apb_interface (input logic clock);

    logic [`DATA_WIDTH-1:0]     PRDATA [`NO_OF_SLAVES-1:0];
    logic [`NO_OF_SLAVES-1:0]   PSLVERR;
    logic [`NO_OF_SLAVES-1:0]   PREADY;
    logic [`DATA_WIDTH-1:0]     PWDATA;
    logic                       PENABLE;
    logic [`NO_OF_SLAVES-1:0]   PSELx;
    logic [`ADDRESS_WIDTH-1:0]  PADDR;
    logic                       PWRITE;

    
    //APB DRIVER
    clocking apb_driver_cb @(posedge clock);

        default input #1 output #1;

        output  PRDATA;
        output  PSLVERR;
        output  PREADY;
    endclocking

    //APB MONITOR
    clocking apb_monitor_cb @(posedge clock);

        default input #1 output #1;
        
        input PRDATA;
        input PSLVERR;
        input PREADY;
        input PWDATA;
        input PENABLE;
        input PSELx;
        input PADDR;
        input PWRITE;
    endclocking


    //MODPORTS
    modport APB_DRIVER  (clocking apb_driver_cb, input clock);
    modport APB_MONITOR (clocking apb_monitor_cb, input clock);
endinterface

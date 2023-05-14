`ifndef ADDRESS_WIDTH
    `define ADDRESS_WIDTH 32
`endif
`ifndef DATA_WIDTH
    `define DATA_WIDTH 32
`endif

interface ahb_interface (input logic clock);

    logic                       HRESETn;
    logic [`ADDRESS_WIDTH-1:0]  HADDR;
    logic [1:0]                 HTRANS;
    logic                       HWRITE;
    logic [`DATA_WIDTH-1:0]     HWDATA;
    logic                       HSELAHB;
    logic [`DATA_WIDTH-1:0]     HRDATA;
    logic                       HREADY;
    logic                       HRESP;


    //AHB Driver
    clocking ahb_driver_cb @(posedge clock);
        
        default input #1 output #1;

        output HRESETn;
        output HADDR;
        output HTRANS;
        output HWRITE;
        output HWDATA;
        output HSELAHB;

        input  HREADY;
    endclocking


    //AHB Monitor
    clocking ahb_monitor_cb @(posedge clock);

        default input #1 output #1;

        input HRESETn;
        input HADDR;
        input HTRANS;
        input HWRITE;
        input HWDATA;
        input HSELAHB;
        input HRDATA;
        input HREADY;
        input HRESP;
    endclocking

    //MODPORTS

    modport AHB_DRIVER  (clocking ahb_driver_cb,  input clock);
    modport AHB_MONITOR (clocking ahb_monitor_cb, input clock);

endinterface


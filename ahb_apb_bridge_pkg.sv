package ahb_apb_bridge_pkg;

    int number_of_transactions = 1000;

    import uvm_pkg :: *;
    `include "uvm_macros.svh"

    `include "ahb_sequence_item.sv"
    `include "apb_sequence_item.sv"
    `include "ahb_apb_bridge_env_config.sv"

    `include "ahb_sequencer.sv"
    `include "ahb_driver.sv"
    `include "ahb_monitor.sv"
    `include "ahb_agent.sv"

    `include "apb_sequencer.sv"
    `include "apb_driver.sv"
    `include "apb_monitor.sv"
    `include "apb_agent.sv"

    `include "ahb_apb_bridge_scoreboard.sv"
    `include "ahb_apb_bridge_environment.sv"
    
    `include "ahb_sequence.sv"
    `include "apb_sequence.sv"

    `include "ahb_apb_bridge_base_test.sv"

    `include "ahb_apb_bridge_single_write_test.sv"
    `include "ahb_apb_bridge_single_read_test.sv"
    `include "ahb_apb_bridge_burst_write_test.sv"
    `include "ahb_apb_bridge_burst_read_test.sv"
    `include "ahb_apb_bridge_random_test.sv"

endpackage
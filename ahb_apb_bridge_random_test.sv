class ahb_apb_bridge_random_test extends ahb_apb_bridge_base_test;
    `uvm_component_utils(ahb_apb_bridge_random_test)

    ahb_random_sequence ahb_random_sequence_h;
    apb_random_sequence apb_random_sequence_h;

    function new(string name = "ahb_apb_bridge_random_test", uvm_component parent);

        super.new(name,parent);

    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        ahb_random_sequence_h = ahb_random_sequence :: type_id :: create("ahb_random_sequence_h");
        apb_random_sequence_h = apb_random_sequence :: type_id :: create("apb_random_sequence_h");

    endfunction

    task run_phase (uvm_phase phase);

        phase.raise_objection(this);

        fork
        ahb_random_sequence_h.start(environment_h.ahb_agent_h.sequencer_h);
        apb_random_sequence_h.start(environment_h.apb_agent_h.sequencer_h);
        join

        phase.drop_objection(this);
        phase.phase_done.set_drain_time(this,50);

    endtask

endclass
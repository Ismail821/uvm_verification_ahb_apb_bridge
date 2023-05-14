class apb_sequence extends uvm_sequence # (apb_sequence_item);
    `uvm_object_utils(apb_sequence)

    function new (string name = "apb_sequence");

        super.new(name);

    endfunction

    task body();

        repeat(number_of_transactions)  begin

            req = apb_sequence_item::type_id::create("req");
        
            start_item(req);
            assert(req.randomize());
            finish_item(req);
        
        end

    endtask

endclass

class apb_random_sequence extends uvm_sequence # (apb_sequence_item);
    `uvm_object_utils(apb_random_sequence)

    function new (string name = "apb_random_sequence");

        super.new(name);

    endfunction

    virtual task body();

        begin

            repeat(number_of_transactions - 8)
                `uvm_do_with(req,{req.PSLVERR == 8'b0;})
            
            repeat(10)
            `uvm_do_with(req,{req.PSLVERR == 8'b1;})

            `uvm_do_with(req,{req.PSLVERR == 8'b0;})

        end

    endtask

endclass

class apb_single_write_sequence extends uvm_sequence # (apb_sequence_item);
    `uvm_object_utils(apb_single_write_sequence)

    function new (string name = "apb_single_write_sequence");

        super.new(name);

    endfunction

    virtual task body();

        begin

            repeat(3)
                `uvm_do_with(req,{req.PSLVERR == 8'b0;})

        end

    endtask

endclass

class apb_single_read_sequence extends uvm_sequence # (apb_sequence_item);
    `uvm_object_utils(apb_single_read_sequence)

    function new (string name = "apb_single_read_sequence");

        super.new(name);

    endfunction

    virtual task body();

        begin

            repeat(3)
                `uvm_do_with(req,{req.PSLVERR == 8'b0;})
        end
    endtask
endclass

class apb_burst_write_sequence extends uvm_sequence # (apb_sequence_item);
    `uvm_object_utils(apb_burst_write_sequence)

    function new (string name = "apb_burst_write_sequence");

        super.new(name);

    endfunction

    virtual task body();

        begin

            repeat(number_of_transactions + 3)
                `uvm_do_with(req,{req.PSLVERR == 8'b0;})

        end

    endtask

endclass

class apb_burst_read_sequence extends uvm_sequence # (apb_sequence_item);
    `uvm_object_utils(apb_burst_read_sequence)

    function new (string name = "apb_burst_read_sequence");

        super.new(name);

    endfunction

    virtual task body();

        begin

            repeat(number_of_transactions + 2)
                `uvm_do_with(req,{req.PSLVERR == 8'b0;})
        end
    endtask
endclass

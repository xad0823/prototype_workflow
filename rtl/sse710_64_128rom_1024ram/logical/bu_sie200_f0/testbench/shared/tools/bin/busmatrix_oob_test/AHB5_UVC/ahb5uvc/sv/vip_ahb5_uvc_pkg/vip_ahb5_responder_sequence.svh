// *********************************************************************
//  The confidential and proprietary information contained in this file may
//  only be used by a person authorised under and to the extent permitted
//  by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//             (C) COPYRIGHT 2012-2016 ARM Limited or its affiliates.
//                 ALL RIGHTS RESERVED
//
//  This entire notice must be reproduced on all copies of this file
//  and copies of this file may only be made by a person if such person is
//  permitted to do so under the terms of a subsisting license agreement
//  from ARM Limited or its affiliates.
//
//   File Revision       :$Revision: $
//   File Date           :$Date: $
//
//   Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
// *********************************************************************

`ifndef VIP_AHB5_RESPONDER_SEQUENCE_SVH
`define VIP_AHB5_RESPONDER_SEQUENCE_SVH



typedef vip_ahb5_responder_sequence;

class vip_ahb5_reactive_subsequence extends uvm_sequence#(vip_ahb5_transaction);
       `uvm_object_utils(vip_ahb5_reactive_subsequence)

    vip_ahb5_responder_sequence interfacing_sequence;

    static uvm_sequence_item template_request;

    vip_ahb5_transaction linking_request;

    uvm_event linking_request_event;


    function new(string name = "");
        super.new(name);
        if (template_request == null)
        begin
            template_request = new("template_request");
        end
        linking_request_event = new("linking_request_event");
        this.use_response_handler(1);
    endfunction : new

    virtual task
    init_start_seq(uvm_sequencer_base sequencer_,
        vip_ahb5_responder_sequence parent_);
        interfacing_sequence = parent_;
        start(sequencer_);
    endtask : init_start_seq

    virtual task body();
        begin
            `vip_ahb5_info(("Sending linking request item"),UVM_FULL)
            linking_request = vip_ahb5_transaction::type_id::create("linking_request");
            start_item(linking_request);
            finish_item(linking_request);

            linking_request_event.wait_trigger();
            linking_request_event.reset();
        end
    endtask : body

    virtual function
    void response_handler(uvm_sequence_item response);
        vip_ahb5_transaction item;
        if ($cast(item, response) != 0)
            put_request(item);
        else begin
            `vip_ahb5_fatal(("Received an invalid type for an incoming reactive request"))
        end
    endfunction : response_handler

    virtual function
    void put_request(vip_ahb5_transaction incoming_request);
        incoming_request.set_id_info(template_request);
        void'(interfacing_sequence.incoming_fifo.try_put(incoming_request));
        interfacing_sequence.incoming_item_event.trigger();
    endfunction : put_request

endclass: vip_ahb5_reactive_subsequence

class vip_ahb5_responder_sequence extends uvm_sequence#(vip_ahb5_transaction);
    `uvm_object_utils(vip_ahb5_responder_sequence)
    local bit cancelled;

    local bit finished;

    uvm_event finished_event;

    uvm_event cancelled_event;

    local bit in_reset;

    uvm_event reset_event;

    uvm_event incoming_item_event;

    vip_ahb5_types::vip_ahb5_physical_properties_t physical_properties;

    vip_ahb5_types::address_t addr[$];

    vip_ahb5_control_knobs responder_control_knobs;

    string slave_response_sequence_map [int unsigned];

    protected vip_ahb5_memory_model memory_model;

    mailbox #(vip_ahb5_transaction) incoming_fifo;

    vip_ahb5_reactive_subsequence reactive_sequence;


    int active_transaction_count;


    function new(string name="");
        super.new(name);
        incoming_fifo = new(0);
        set_response_queue_depth(-1);
        cancelled_event  = new("cancelled_event ");
        reset_event      = new("reset_even");
        finished_event   = new("finished_even");
        incoming_item_event = new("incoming_item_event");
    endfunction

    virtual function
    bit has_memory_model();
        return (memory_model != null);
    endfunction : has_memory_model

    virtual task
    put_item(vip_ahb5_transaction item_);
        start_item(item_);
        finish_item(item_);
    endtask : put_item

    virtual task
    get_item(output vip_ahb5_transaction item_);
        incoming_fifo.get(item_);
        if (has_items())
        begin
            incoming_item_event.trigger();
        end
    endtask : get_item

    virtual function
    bit has_items();
        return (incoming_fifo.num() > 0);
    endfunction : has_items

    virtual task pre_start();
        vip_ahb5_sequencer slave_sequencer;

        super.pre_start();

        if($cast(slave_sequencer, m_sequencer))
        begin
            physical_properties = slave_sequencer.get_physical_properties();
        end
        reactive_sequence = vip_ahb5_reactive_subsequence::type_id::create("sequence_");
        fork
            begin
                reactive_sequence.init_start_seq(m_sequencer, this);
            end
        join_none
    endtask

    virtual task
    body();
        fork
            process_requests();
        join
    endtask

    virtual task
    process_requests();
        vip_ahb5_transaction transaction;
        while (!is_cancelled())
        begin
            fork
                begin
                    if (incoming_fifo.num() == 0)
                    begin
                        incoming_item_event.wait_trigger();
                        incoming_item_event.reset();
                    end
                end
                begin
                    cancelled_event.wait_trigger();
                    cancelled_event.reset();
                end
            join_any
            disable fork;
            if (!is_cancelled())
            begin
                if(get_responder_control_knobs() == null)
                begin
                    responder_control_knobs = vip_ahb5_control_knobs::type_id::create("responder_control_knobs");
                end

                get_item(transaction);
                transaction.set_node_type(vip_ahb5_types::SLAVE_NODE);
                responder_control_knobs.set_max_slave_number(physical_properties.hselx_width);
                transaction.set_control_knobs(responder_control_knobs);
                update_request(transaction);

                if (!is_in_reset())
                begin
                    generate_response(transaction);
                end
                else
                begin
                    `vip_ahb5_warning(("Received a transaction whilst in reset\n%0s",transaction.sprint()))
                end
            end
        end
    endtask : process_requests

    virtual task
    process_request_transaction(vip_ahb5_transaction transaction_);
        make_transaction_active(transaction_);
    endtask : process_request_transaction

    virtual task
    process_responses();
        while (!is_cancelled())
        begin
            vip_ahb5_transaction transaction;
            transaction = null;

            fork
                get_response(transaction);
                reset_event.wait_trigger();
                cancelled_event.wait_trigger();
            join_any
            disable fork;

            if( transaction != null)
            begin
                if (!is_in_reset())
                begin
                    process_response_transaction(transaction);
                end
                else
                begin
                    `vip_ahb5_warning(("Received a transaction whilst in reset\n%0s",transaction.sprint()))
                end
            end
        end
    endtask : process_responses

    virtual task process_response_transaction(ref vip_ahb5_transaction transaction_);

        if(transaction_.request_type == vip_ahb5_types::REQUEST_WRITE)
        begin
            if(has_memory_model())
            begin
                foreach(transaction_.data.data[i])
                begin
                    memory_model.write_data(transaction_.request_beats[i].Address,
                                            transaction_.secure_transfer,
                                            transaction_.valid_byte_strobes,
                                            transaction_.data.data[i],
                                            transaction_.resp[i]);
                end
            end
        end
    endtask : process_response_transaction

    virtual task
    make_transaction_active(vip_ahb5_transaction transaction_);
        begin
            put_item(transaction_);
            decrement_active_transaction_count();
        end
    endtask

    protected function void update_request(ref vip_ahb5_transaction transaction_);
        vip_ahb5_types::request_beat_struct_t req_beat;

        req_beat = transaction_.request_beats[0];
        transaction_.set_physical_properties(physical_properties);
        transaction_.set_address(req_beat.Address);
        transaction_.set_request_type(vip_ahb5_types::request_t'(req_beat.Direction));
        transaction_.set_burst_type(vip_ahb5_types::burst_t'(req_beat.Burst));
        transaction_.set_transfer_size(vip_ahb5_types::size_t'(req_beat.Size));
        transaction_.set_protection(vip_ahb5_types::ahb5_prot_t'(req_beat.Prot));
        transaction_.set_exclusive_transfer(vip_ahb5_types::trans_attr_t'(req_beat.Exclusive));
        transaction_.set_secure_transfer(vip_ahb5_types::access_attr_t'(req_beat.Secure));
        transaction_.set_exclusive_master_id(req_beat.MasterId);
        transaction_.set_slave_select(req_beat.Select);
    endfunction : update_request

    protected function void create_address_queue(ref vip_ahb5_transaction transaction_);
        int unsigned data_byte_width;
        int unsigned transaction_size;
        bit wrapping_burst;
        vip_ahb5_types::address_t wrap_boundary_;
        vip_ahb5_types::address_t next_address_;
        vip_ahb5_types::address_t current_address_;

        addr.delete();
        data_byte_width  = vip_ahb5_types::get_data_width_from_hsize(transaction_.transfer_size);
        transaction_size =  (data_byte_width)*(transaction_.burst_length);
        wrapping_burst   = ((transaction_.burst_type == vip_ahb5_types::BURST_WRAP4)
                            ||(transaction_.burst_type == vip_ahb5_types::BURST_WRAP8)
                            ||(transaction_.burst_type == vip_ahb5_types::BURST_WRAP16));
        wrap_boundary_    = (transaction_.address / transaction_size)*transaction_size ;

        current_address_ = transaction_.address;
        addr.push_back(current_address_);
        for(int i =1; i< transaction_.burst_length;++i)
        begin
            next_address_ = current_address_ + data_byte_width;
            if(wrapping_burst)
            begin
                if(next_address_  >= (wrap_boundary_ + transaction_size))
                begin
                    next_address_ = next_address_ - transaction_size ;
                end
            end
            addr.push_back(next_address_);
            current_address_ = next_address_;
        end
    endfunction: create_address_queue



    virtual task generate_response(ref vip_ahb5_transaction transaction_);
        bit [7:0]mem_data[];
        bit error_;
        bit result;
        bit[63:0] address;
        bit[7:0] rd_data[];
        int unsigned index_;
        uvm_object object;
        string seq_name;

        vip_ahb5_slave_base_response_sequence slave_response_seq;

        result = transaction_.randomize();
        if(!result)
        begin
            `vip_ahb5_fatal((" Response randomization failed"))
        end
        create_address_queue(transaction_);

        if (transaction_.slave_select > responder_control_knobs.max_slave_number) begin
            `vip_ahb5_fatal(("Slave select should be within maximum slave number(%0d) boundary!",responder_control_knobs.max_slave_number))
        end
        else begin
            if (responder_control_knobs.slave_response_sequence_map.exists(transaction_.slave_select)) begin
                seq_name = responder_control_knobs.slave_response_sequence_map[transaction_.slave_select];
            end
            else begin
                seq_name = "vip_ahb5_slave_base_response_sequence";
            end
        end
        `uvm_info(get_name(),$sformatf("Slave_select %0h",transaction_.slave_select),UVM_LOW)
        `uvm_info(get_name(),$sformatf("Creating object by name %s",seq_name),UVM_LOW)
        object = factory.create_object_by_name(seq_name);
        if(object == null) begin
            `vip_ahb5_fatal(("slave_response_seq is null"))
        end
        else begin
            if($cast(slave_response_seq,object)) begin
                slave_response_seq.initialize(transaction_,memory_model,this.addr,starting_phase);
                transaction_.address_beats = this.addr;
                slave_response_seq.start(this.m_sequencer);
            end
            else begin
                `vip_ahb5_error(("Received object is not cast compatible with vip_ahb5_slave_base_response_sequence"))
            end
        end
    endtask : generate_response

    protected function
    void increment_active_transaction_count();
        if (++active_transaction_count == 1)
        begin
            starting_phase.raise_objection(this, "UVC Responder Incoming Transaction");
            `vip_ahb5_info(("Received a transaction - Switching from Idle"),UVM_HIGH)
        end
    endfunction : increment_active_transaction_count

    protected function
    void decrement_active_transaction_count();
        if (active_transaction_count > 0)
        begin
            if (--active_transaction_count == 0)
            begin
                starting_phase.drop_objection(this, "UVC Responder Idle");
                `vip_ahb5_info(("Empty transaction queues - Switching to Idle"),UVM_HIGH)
            end
        end
        else
        begin
            `vip_ahb5_fatal(("Attempt to decrease the active transaction count below 0"))
        end
    endfunction : decrement_active_transaction_count


    virtual task
    post_start();
        if (reactive_sequence != null)
        begin
            reactive_sequence.kill();
            reactive_sequence = null;
        end
    endtask : post_start

    virtual function
    bit is_cancelled();
        return cancelled;
    endfunction : is_cancelled

    virtual function
    void set_finished();
        `vip_ahb5_info(("Finished sequence"),UVM_HIGH)
        finished = 1;
        finished_event.trigger();
    endfunction : set_finished

    virtual function
    bit is_finished();
        return finished;
    endfunction : is_finished

    virtual function
    void set_cancelled();
        `vip_ahb5_info(("Cancelling sequence"),UVM_HIGH)
        cancelled = 1;
        cancelled_event.trigger();
    endfunction : set_cancelled

    virtual function
    bit is_in_reset();
        return in_reset;
    endfunction : is_in_reset

    `VIP_AHB5_ACCESSOR(vip_ahb5_memory_model,memory_model)
    `VIP_AHB5_ACCESSOR(vip_ahb5_control_knobs,responder_control_knobs)
    `VIP_AHB5_ACCESSOR(vip_ahb5_types::vip_ahb5_physical_properties_t, physical_properties)
endclass: vip_ahb5_responder_sequence
`endif

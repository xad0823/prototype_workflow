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

`ifndef VIP_AHB5_MASTER_DRIVER_SVH
`define VIP_AHB5_MASTER_DRIVER_SVH


class vip_ahb5_master_driver extends uvm_driver#(vip_ahb5_transaction);

    `uvm_component_utils(vip_ahb5_master_driver)


    vip_ahb5_configuration configuration;

    vip_ahb5_transaction_layer transaction_layer;

    vip_ahb5_if_wrapper intf;

    bit transfer_terminated;

    bit data_beat_pending;

    bit in_reset;

    event stop_driving;

    vip_ahb5_types::states_t state;


    local vip_ahb5_transaction new_request;

    local vip_ahb5_transaction ongoing_request;

    mailbox  #(vip_ahb5_transaction) transaction_fifo;

    mailbox  #(vip_ahb5_transaction) sampled_transaction_fifo;

    local vip_ahb5_types::request_beat_struct_t tx_req;

    local vip_ahb5_types::response_beat_struct_t rx_resp;

    local bit [7:0] sampled_data[];

    vip_ahb5_types::hdatauser_t sampled_user;

    local bit [7:0] write_data[];

    local vip_ahb5_types::hdatauser_t write_data_user;

    local bit valid_byte_strobes[];

    protected bit address_change_permitted;

    local bit transfer_in_progress;

    local bit transfer_sampling;

    event new_item_received_event;

    int unsigned cycle;

    function new(string name = "vip_ahb5_master_driver",uvm_component parent = null);
        super.new(name,parent);
        transaction_fifo = new(0);
        sampled_transaction_fifo = new(0);
    endfunction: new


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(vip_ahb5_configuration)::get(this, "","configuration",configuration))
        begin
            `vip_ahb5_fatal(("Configuration object not set."))
        end
        if(!uvm_config_db#(vip_ahb5_if_wrapper)::get(this,"","vif",intf))
        begin
            `vip_ahb5_fatal(("Interface wrapper not set."))
        end
        intf.set_default_slave(configuration.get_default_slave());
        intf.set_idle_mode(configuration.get_idle_mode());
        transaction_layer = vip_ahb5_transaction_layer::type_id::create("trans_layer",this);
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        intf.drive_bus_idle(vip_ahb5_types::DRIVE_X_ZERO);
        set_state(vip_ahb5_types::ACTIVE);
        fork
            process_requests();
            handle_responses();
        join_none
        @(stop_driving);
        disable fork;
    endtask: run_phase


    protected task process_requests();

        intf.wait_for_reset_exit();
        set_in_reset(1'b0);

        while(get_state() != vip_ahb5_types::STOPPED)
        begin
            start_new_request();

            if((get_state() != vip_ahb5_types::STOPPED)&&(!is_in_reset())&&(transaction_fifo.num() !=0))
            begin
                fork
                    drive_beats();
                    intf.wait_for_reset(in_reset);
                join_any
                disable fork;
            end

            if(is_in_reset())
            begin
               `vip_ahb5_warning(("Reset detected, master driver terminating ongoing transaction."))
                set_state(vip_ahb5_types::ABORT);
                intf.wait_for_reset_exit();
                clear_driver_flags();
            end
        end

    endtask : process_requests

    protected task start_new_request();

        fork
            begin
                seq_item_port.try_next_item(new_request);

                if(new_request != null)
                begin

                    if((is_address_change_permitted())&&(configuration.get_allow_address_change_during_wait()))
                    begin
                        set_address_change_permitted(0);
                        intf.clk_sync(1);
                        start_burst();
                    end
                    else
                    begin
                        intf.wait_for_ready();
                        fork
                            start_burst();
                            drive_last_data_beat();
                        join
                    end
                end
                else
                begin
                    intf.wait_for_ready();
                    fork
                        intf.drive_request_idle(configuration.idle_mode);
                        drive_last_data_beat();
                    join

                    intf.wait_for_ready();
                    intf.drive_bus_idle(configuration.idle_mode);
                    set_transfer_in_progress(0);
                end
            end
            intf.wait_for_reset(in_reset);
        join_any
        disable fork;
    endtask : start_new_request

    protected task start_burst();
        vip_ahb5_transaction transaction;
        set_state(vip_ahb5_types::ACTIVE);
        set_transfer_in_progress(1);

        transaction_layer.create_request(new_request);

        $cast(transaction,new_request.clone());
        transaction.set_id_info(new_request);
        seq_item_port.item_done();

        tx_req = transaction.request_beats.pop_front();
        intf.start_transfer(tx_req);
        transaction_fifo.put(transaction);
        sampled_transaction_fifo.put(transaction);
        -> new_item_received_event;

        set_transfer_terminated(0);
    endtask : start_burst

    protected task drive_beats();
        vip_ahb5_types::request_beat_struct_t prev_tx_req;

        transaction_fifo.get(ongoing_request);
        while((ongoing_request.request_beats.size() !== 0)&&(!get_transfer_terminated()))
        begin
            intf.sample_response(rx_resp);
            case(rx_resp.State)
                vip_ahb5_types::ERROR_RESP_1ST_CYCLE:
                begin
                   if(ongoing_request.get_terminate_burst_on_error())
                   begin
                       intf.drive_request_idle(configuration.idle_mode);
                       set_transfer_terminated(1);
                       `vip_ahb5_warning(("Error response received, Master terminating the burst !!"))
                   end
                end
                vip_ahb5_types::ERROR_RESP_EXCLUSIVE,
                vip_ahb5_types::ERROR_RESP_2ND_CYCLE:
                begin
                    if(!ongoing_request.get_terminate_burst_on_error())
                    begin
                        tx_req = ongoing_request.request_beats.pop_front();
                        intf.drive_request_beat(tx_req);
                        if(prev_tx_req.Transfer != vip_ahb5_types::TRANSFER_BUSY)
                        begin
                            drive_intermediate_data_beats();
                        end
                    end
                end
                vip_ahb5_types::TRANS_SUCCESS:
                begin
                    tx_req = ongoing_request.request_beats.pop_front();
                    intf.drive_request_beat(tx_req);

                    if(prev_tx_req.Transfer != vip_ahb5_types::TRANSFER_BUSY)
                    begin
                        drive_intermediate_data_beats();
                    end

                    set_address_change_permitted(((tx_req.Transfer == vip_ahb5_types::TRANSFER_IDLE)||
                                                  (tx_req.Transfer == vip_ahb5_types::TRANSFER_BUSY)
                                                  ));
                end
            endcase


            prev_tx_req = tx_req;
        end
        set_data_beat_pending(1);
    endtask : drive_beats


    protected task drive_intermediate_data_beats();
        if(ongoing_request.request_type == vip_ahb5_types::REQUEST_WRITE)
        begin
            write_data = ongoing_request.data.data.pop_front();
            valid_byte_strobes = ongoing_request.valid_byte_strobes;
            write_data_user = ongoing_request.data.user.pop_front();
            intf.drive_data_beat(write_data, write_data_user);
        end
        else
        begin
            intf.drive_data_idle(configuration.idle_mode);
        end
    endtask : drive_intermediate_data_beats

    protected task drive_last_data_beat();
        if(is_data_beat_pending())
        begin
            if(!is_transfer_terminated())
            begin
                if(ongoing_request.request_type == vip_ahb5_types::REQUEST_WRITE)
                begin
                    write_data = ongoing_request.data.data.pop_front();
                    valid_byte_strobes = ongoing_request.valid_byte_strobes;
                    write_data_user = ongoing_request.data.user.pop_front();
                    intf.drive_data_beat(write_data, write_data_user);
                    if((ongoing_request.data.data.size() !== 0)&&(!ongoing_request.get_terminate_incr_with_busy()))
                    begin
                      `vip_ahb5_fatal(("Data queue not empty at the end of burst."))
                    end
                end
                set_state(vip_ahb5_types::COMPLETE);
            end
            else
            begin
                set_state(vip_ahb5_types::ABORT);
            end
            set_data_beat_pending(0);
        end
    endtask : drive_last_data_beat

    protected task handle_responses();
        vip_ahb5_transaction transaction_,clone_tr;
        while(get_state() != vip_ahb5_types::STOPPED)
        begin
            sampled_transaction_fifo.get(transaction_);
            $cast(clone_tr,transaction_.clone());
            clone_tr.set_id_info(transaction_);
            intf.wait_for_ready();
            set_transfer_sampling(1);

            fork
                sample_intermediate_beats(clone_tr);
                intf.wait_for_reset(in_reset);
                @new_item_received_event;
            join_any
            disable fork;
            fork
                sample_last_beat(clone_tr);
                intf.wait_for_reset(in_reset);
            join_any
            disable fork;

            if(!is_in_reset())
            begin
                if(is_transfer_terminated())
                begin
                    clone_tr.set_transaction_terminated(1'b1);
                end
                else
                begin
                    clone_tr.set_transaction_complete(1'b1);
                end
                clone_tr.populate_response();
                seq_item_port.put(clone_tr);
            end
            else
            begin
                clone_tr.set_reset_detected(1'b1);
                clone_tr.populate_response();
                seq_item_port.put(clone_tr);
                intf.wait_for_reset_exit();
                set_in_reset(1'b0);
                clear_driver_flags();
            end
            set_transfer_sampling(0);

        end
    endtask : handle_responses

    protected task sample_intermediate_beats(vip_ahb5_transaction request_);
        int unsigned beats_to_sample;
        vip_ahb5_types::request_beat_struct_t req_;
        vip_ahb5_types::request_beat_struct_t preq_;
        vip_ahb5_types::response_beat_struct_t resp_;

        beats_to_sample = (request_.get_burst_length() -1);

        while((beats_to_sample !=0)&&(!is_transfer_terminated()))
        begin
            intf.sample_response(resp_);
            if(resp_.ReadyOut)
            begin
                intf.sample_transfer(req_);
                if(preq_.Transfer != vip_ahb5_types::TRANSFER_BUSY)
                begin
                    if(request_.request_type == vip_ahb5_types::REQUEST_READ)
                    begin
                        intf.sample_read_data(sampled_data, sampled_user);
                        request_.data.data.push_back(sampled_data);
                        request_.data.user.push_back(sampled_user);
                    end
                    request_.response_beats.push_back(resp_);
                    --beats_to_sample;
                end
                preq_ = req_;
            end
        end
    endtask : sample_intermediate_beats

    protected task sample_last_beat(vip_ahb5_transaction request_);
        vip_ahb5_types::request_beat_struct_t req_;
        vip_ahb5_types::request_beat_struct_t preq_;
        vip_ahb5_types::response_beat_struct_t resp_;

        intf.sample_response(resp_);
        while(!resp_.ReadyOut)
        begin
            intf.sample_response(resp_);
        end
        request_.response_beats.push_back(resp_);

        intf.sample_transfer(req_);
        if(req_.Transfer == vip_ahb5_types::TRANSFER_BUSY)
        begin
            while(req_.Transfer == vip_ahb5_types::TRANSFER_BUSY)
            begin
                intf.wait_for_ready();
                intf.sample_transfer(req_);
            end
            intf.wait_for_ready();
        end
        if(request_.request_type == vip_ahb5_types::REQUEST_READ)
        begin
            intf.sample_read_data(sampled_data, sampled_user);
            request_.data.data.push_back(sampled_data);
            request_.data.user.push_back(sampled_user);
        end
    endtask : sample_last_beat

    function void phase_ready_to_end(uvm_phase phase);
        if (phase.get_name() == "run")
        begin
            if (is_transfer_in_progress())
            begin
                phase.raise_objection(this,"Activity pending");
                fork
                    begin
                        stoping_driver(phase);
                    end
                join_none
            end
        end
    endfunction : phase_ready_to_end

    task automatic stoping_driver(uvm_phase phase);
       wait ((!transfer_in_progress)&&(!transfer_sampling));
       intf.clk_sync(2);
       set_state(vip_ahb5_types::STOPPED);
       -> stop_driving;
       phase.drop_objection(this,"All activities completed");
    endtask:stoping_driver

    protected function void clear_driver_flags();
        set_transfer_terminated(0);
        set_data_beat_pending(0);
        set_transfer_in_progress(0);
        set_transfer_sampling(0);
        set_in_reset(0);
        set_state(vip_ahb5_types::ACTIVE);
        set_address_change_permitted(1);
    endfunction: clear_driver_flags


    `VIP_AHB5_FLAG_ACCESSOR(transfer_terminated)
    `VIP_AHB5_FLAG_ACCESSOR(data_beat_pending)
    `VIP_AHB5_FLAG_ACCESSOR(transfer_in_progress)
    `VIP_AHB5_FLAG_ACCESSOR(transfer_sampling)
    `VIP_AHB5_FLAG_ACCESSOR(in_reset)
    `VIP_AHB5_ACCESSOR(vip_ahb5_types::states_t,state)
    `VIP_AHB5_FLAG_ACCESSOR(address_change_permitted)

endclass: vip_ahb5_master_driver

`endif

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

`ifndef VIP_AHB5_SLAVE_DRIVER_SVH
`define VIP_AHB5_SLAVE_DRIVER_SVH



class vip_ahb5_slave_driver extends uvm_driver#(vip_ahb5_transaction);

   `uvm_component_utils(vip_ahb5_slave_driver)


    vip_ahb5_configuration configuration;

    vip_ahb5_transaction_layer transaction_layer;

    vip_ahb5_if_wrapper intf;

    vip_ahb5_transaction linking_request;

    local vip_ahb5_types::response_beat_struct_t okay_response;

    local vip_ahb5_types::response_beat_struct_t busy_response;

    static int unsigned transfer_id;

    int unsigned cycle;

    bit in_reset;

    vip_ahb5_types::states_t state;

    bit new_transfer_sampled;

    bit transfer_terminated;

    bit transfer_completed;

    vip_ahb5_transaction new_request;

    vip_ahb5_transaction response;

    vip_ahb5_transaction response_tr;

    vip_ahb5_types::request_beat_struct_t rx_req;

    vip_ahb5_types::request_beat_struct_t prev_rx_req;

    vip_ahb5_types::response_beat_struct_t tx_resp;

    vip_ahb5_types::response_beat_struct_t rx_resp;

    vip_ahb5_types::response_beat_struct_t rx_resp_q[$];

    bit [7:0] sampled_data[];

    vip_ahb5_types::hdatauser_t sampled_user;

    function new(string name = "vip_ahb5_slave_driver", uvm_component parent = null);
        super.new(name,parent);
        okay_response.ReadyOut = vip_ahb5_types::SLAVE_READY;
        okay_response.Response = vip_ahb5_types::RESP_OKAY;
        okay_response.ExclResponse = vip_ahb5_types::EXCL_FAIL;
        okay_response.State    = vip_ahb5_types::TRANS_SUCCESS;
        busy_response.ReadyOut = vip_ahb5_types::SLAVE_WAIT;
        busy_response.Response = vip_ahb5_types::RESP_OKAY;
        busy_response.ExclResponse = vip_ahb5_types::EXCL_FAIL;
        busy_response.State    = vip_ahb5_types::TRANS_PENDING;
        transfer_id = 0;
        set_transfer_terminated(0);
    endfunction: new


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(vip_ahb5_configuration)::get(this, "","configuration",configuration))
        begin
            `vip_ahb5_fatal(("Configuration object not set."))
        end
        if(!uvm_config_db#(vip_ahb5_if_wrapper)::get(this,"","vif",intf))
        begin
            `vip_ahb5_fatal(("Interface wrapper object not set."))
        end
        intf.set_idle_mode(configuration.get_idle_mode());
        transaction_layer = vip_ahb5_transaction_layer::type_id::create("trans_layer",this);
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        intf.drive_bus_idle(vip_ahb5_types::DRIVE_X_ZERO);
        set_state(vip_ahb5_types::ACTIVE);
        fork
            process_responses();
            cycle_counter();
        join_any
        disable fork;
    endtask: run_phase

    protected task static cycle_counter();
        forever
        begin
            intf.clk_sync(1);
            ++cycle;
        end
    endtask : cycle_counter

    virtual task get_linking_request();
        seq_item_port.get_next_item(linking_request);
        seq_item_port.item_done();
    endtask : get_linking_request

    protected task process_responses();
        get_linking_request();

        intf.wait_for_reset_exit();

        while(state != vip_ahb5_types::STOPPED)
        begin

            fork
                sample_new_transfer();
                intf.wait_for_reset(in_reset);
            join_any
            disable fork;

            get_response_item();

            if((get_state() == vip_ahb5_types::ACTIVE)&&(!is_in_reset()))
            begin
                fork
                    drive_response_beats();
                    intf.wait_for_reset(in_reset);
                join_any
                disable fork;
            end

            if((is_in_reset())&&(response != null))
            begin
                response.set_reset_detected(get_in_reset());
                seq_item_port.put(response);
                intf.wait_for_reset_exit();
                clear_driver_flags();
                set_state(vip_ahb5_types::ACTIVE);
            end
        end
    endtask : process_responses

    protected task sample_new_transfer();

        new_request = null;
        if(!is_new_transfer_sampled())
        begin
            intf.sample_start_of_transfer(rx_req);
        end
        set_state(vip_ahb5_types::ACTIVE);
    endtask: sample_new_transfer

    protected task get_response_item();
        if(get_state() == vip_ahb5_types::ACTIVE)
        begin
            new_request = new("new_sampled_request");
            new_request.request_beats.push_back(rx_req);
            new_request.set_id_info(linking_request);
            new_request.set_endianness(configuration.get_endianness());
            seq_item_port.put(new_request);

            seq_item_port.try_next_item(response_tr);
            if(response_tr == null) begin
                intf.drive_response_beat(busy_response);
                seq_item_port.get_next_item(response_tr);
            end
            $cast(response,response_tr.clone());
            response.set_id_info(response_tr);
            seq_item_port.item_done();

            response.request_beats.delete();
            response.request_beats.push_back(rx_req);
            transaction_layer.create_responses(response);
        end

    endtask: get_response_item

    protected task drive_response_beats();

        clear_driver_flags();
        rx_resp_q.delete();

        drive_response_beat_check_size();

        if(response.request_type == vip_ahb5_types::REQUEST_READ)
        begin
            drive_data_beat();
        end
        while(((!is_transfer_terminated())&&(!is_new_transfer_sampled())&&(!is_transfer_completed())))
        begin
            intf.sample_response(rx_resp);
            if(rx_resp.ReadyOut == vip_ahb5_types::SLAVE_READY)
            begin
                intf.sample_transfer(rx_req);
                rx_resp_q.push_back(rx_resp);
                case(rx_req.Transfer)

                    vip_ahb5_types::TRANSFER_NONSEQ:
                    begin
                        check_nonseq_transfer_state();
                        if(prev_rx_req.Transfer != vip_ahb5_types::TRANSFER_BUSY)
                        begin
                            handle_data();
                        end
                    end

                    vip_ahb5_types::TRANSFER_IDLE:
                    begin
                        check_idle_transfer_state();
                        intf.drive_response_beat(okay_response);
                        update_request_and_handle_data(rx_req,prev_rx_req);
                    end

                    vip_ahb5_types::TRANSFER_BUSY:
                    begin
                        intf.drive_response_beat(okay_response);
                        update_request_and_handle_data(rx_req,prev_rx_req);
                    end

                    vip_ahb5_types::TRANSFER_SEQ:
                    begin
                        drive_response_beat_check_size();
                        update_request_and_handle_data(rx_req,prev_rx_req);
                    end
                endcase
                prev_rx_req = rx_req;
            end
            else
            begin
                drive_response_beat_check_size();
            end
        end

        response.response_beats.delete();
        response.response_beats = rx_resp_q;
        if(!is_transfer_terminated())
        begin
            response.set_transaction_complete(get_transfer_completed());
           `vip_ahb5_info(("Transfer completed"),UVM_HIGH)
            set_state(vip_ahb5_types::COMPLETE);
        end
        else
        begin
            response.set_transaction_terminated(1);
           `vip_ahb5_info(("Transfer terminated"),UVM_HIGH)
            set_transfer_terminated(0);
            set_state(vip_ahb5_types::ABORT);
        end

        if(response.request_type == vip_ahb5_types::REQUEST_WRITE)
        begin
            transaction_layer.update_incoming_data(response);
        end
        seq_item_port.put(response);

        ++transfer_id;

    endtask: drive_response_beats


    protected task handle_data();
        if(response.request_type == vip_ahb5_types::REQUEST_READ)
        begin
            drive_data_beat();
        end
        else
        begin
            intf.sample_write_data(sampled_data, sampled_user);
            response.data.data.push_back(sampled_data);
            response.data.user.push_back(sampled_user);
        end
    endtask: handle_data

    protected task update_request_and_handle_data
                    (vip_ahb5_types::request_beat_struct_t rx_req,
                     vip_ahb5_types::request_beat_struct_t prev_rx_req
                    );
        if(prev_rx_req.Transfer != vip_ahb5_types::TRANSFER_BUSY)
        begin
            response.request_beats.push_back(rx_req);
            handle_data();
        end
    endtask : update_request_and_handle_data

    protected function void check_nonseq_transfer_state();
        if(rx_req.Select)
        begin
            if((response.response_beats.size() != 0)
                &&(response.burst_type != vip_ahb5_types::BURST_SINGLE)
                &&(response.burst_type != vip_ahb5_types::BURST_INCR)
            )begin
                set_transfer_terminated(1);
               `vip_ahb5_fatal(("Unexpected NONSEQ transfer in middle of a burst"))
            end
            else
            begin
                set_new_transfer_sampled(1);
            end
        end
    endfunction: check_nonseq_transfer_state

    protected function void check_idle_transfer_state();
        if(response.response_beats.size() == 0)
        begin
            set_transfer_completed(1);
        end
        else
        begin
            set_transfer_terminated(1);
        end
    endfunction: check_idle_transfer_state

    protected function void clear_driver_flags();
        set_transfer_completed(0);
        set_transfer_terminated(0);
        set_in_reset(0);
        set_new_transfer_sampled(0);
    endfunction: clear_driver_flags

    protected task
    drive_data_beat();
        if (response.data.data.size() == 0)
        begin
            intf.drive_data_idle(configuration.get_idle_mode());
        end
        else
        begin
            intf.drive_data_beat(response.data.data.pop_front(),
                                 response.data.user.pop_front());
        end
    endtask : drive_data_beat

    protected task
    drive_response_beat_check_size();
        if (response.response_beats.size() > 0)
        begin
            intf.drive_response_beat(response.response_beats.pop_front());
        end
        else
        begin
            intf.drive_bus_idle(configuration.get_idle_mode());
        end
    endtask : drive_response_beat_check_size


    `VIP_AHB5_FLAG_ACCESSOR(new_transfer_sampled)
    `VIP_AHB5_FLAG_ACCESSOR(transfer_terminated)
    `VIP_AHB5_FLAG_ACCESSOR(transfer_completed)
    `VIP_AHB5_ACCESSOR(vip_ahb5_types::states_t,state)
    `VIP_AHB5_FLAG_ACCESSOR(in_reset)

endclass: vip_ahb5_slave_driver

`endif

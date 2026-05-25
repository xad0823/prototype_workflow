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

`ifndef VIP_AHB5_MONITOR_SVH
`define VIP_AHB5_MONITOR_SVH


class vip_ahb5_monitor extends uvm_monitor;

    `uvm_component_utils(vip_ahb5_monitor)

    vip_ahb5_configuration configuration;

    vip_ahb5_coverage coverage;

    uvm_analysis_port #(vip_ahb5_transaction) item_collected_port;

    uvm_analysis_port #(vip_ahb5_channel_cov_item) channel_item_collected_port;

    uvm_analysis_port #(vip_ahb5_transaction) address_phase_port;

    vip_ahb5_if_wrapper vif;

    vip_ahb5_transaction transfer;

    vip_ahb5_types::request_beat_struct_t rx_req;

    vip_ahb5_types::request_beat_struct_t new_rx_req;

    vip_ahb5_types::response_beat_struct_t rx_resp;

    vip_ahb5_types::request_beat_struct_t request_beats[$];

    vip_ahb5_types::response_beat_struct_t response_beats[$];

    bit [7:0] sampled_data[];

    vip_ahb5_types::hdatauser_t sampled_user;

    vip_ahb5_types::vip_ahb5_data_struct_t sampled_data_q;

    bit transfer_type;


    bit new_transfer_detected;

    bit idle_transfer_detected;

    bit reset_detected;

    vip_ahb5_types::size_t transfer_size_max;

    int unsigned cycle;

    bit  cancel_transfer;

    time start_time;

    time new_trans_start_time;

    time end_time;

    vip_ahb5_transaction_record_base record;

    function new(string name = "vip_ahb5_monitor",uvm_component parent =null);
        super.new(name,parent);
        item_collected_port = new("ahb_item_collected_port",this);
        address_phase_port = new("address_phase_port",this);
        channel_item_collected_port = new("ahb_transfer_collected_port",this);
        set_cancel_transfer (1'b0);
    endfunction: new


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(vip_ahb5_if_wrapper)::get(this,"","vif",vif))
        begin
            `vip_ahb5_fatal(("Interface wrapper not set."))
        end

        if(!uvm_config_db#(vip_ahb5_configuration)::get(this,"","configuration",configuration))
        begin
            `vip_ahb5_fatal(("Agent configuration not set."))
        end

        transfer_size_max = vip_ahb5_types::get_hsize_from_data_width(vif.get_data_byte_width());
        uvm_config_db #(vip_ahb5_types::size_t)::set(this,"*", "transfer_size_max", transfer_size_max);

        if(configuration.is_enable_coverage())
        begin
            coverage = vip_ahb5_coverage::type_id::create("coverage",this);
        end

        record = vip_ahb5_transaction_record_base::create_default("record", this);
        record.set_enabled(configuration.get_enable_recording());
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(coverage != null)
        begin
            this.item_collected_port.connect(coverage.transaction_coverage_port);
            this.channel_item_collected_port.connect(coverage.channel_coverage_port);
        end
    endfunction: connect_phase


    task run_phase(uvm_phase phase);
        fork
            sample_transactions();
            cycle_counter();
            sample_channel_transfers();
        join_any
        disable fork;
    endtask: run_phase

    task cycle_counter();
        forever
        begin
            vif.clk_sync(1);
            ++cycle;
            record.get_time_on_clk_edge();
        end
    endtask: cycle_counter

    protected task sample_transactions();
        vip_ahb5_types::request_beat_struct_t prev_rx_req;
        vip_ahb5_transaction address_phase_tr;

        vif.wait_for_reset_exit();
        reset_detected = 0;
        while(!is_cancel_transfer())
        begin

            fork
                begin
                    if(!is_new_transfer_detected())
                    begin
                        vif.sample_start_of_transfer(new_rx_req);

                        address_phase_tr = vip_ahb5_transaction::type_id::create("address_phase_tr");
                        address_phase_tr.request_beats.push_back(new_rx_req);
                        address_phase_tr.populate_transaction();
                        address_phase_port.write(address_phase_tr);

                        transfer_type = new_rx_req.Direction;
                        set_start_time($time);
                    end
                    else
                    begin
                        set_start_time(get_new_trans_start_time());
                    end
                    request_beats.push_back(new_rx_req);
                    set_new_transfer_detected(0);
                    set_idle_transfer_detected(0);
                    record.record_new_request(new_rx_req);
                end
                vif.wait_for_reset(reset_detected);
                join_any
            disable fork;

            fork
                begin
                    while((!is_new_transfer_detected())&&(!is_idle_transfer_detected()))
                    begin
                        vif.sample_response(rx_resp);
                        response_beats.push_back(rx_resp);
                        if(rx_resp.ReadyOut == vip_ahb5_types::SLAVE_READY)
                        begin
                            vif.sample_transfer(rx_req);
                            case(rx_req.Transfer)
                                vip_ahb5_types::TRANSFER_NONSEQ:
                                begin
                                    if(rx_req.Select)
                                    begin
                                        set_new_transfer_detected(1);
                                        set_new_trans_start_time($time);
                                        new_rx_req = rx_req;
                                    end
                                    sample_data(prev_rx_req);
                                    transfer_type = new_rx_req.Direction;
                                end
                                vip_ahb5_types::TRANSFER_IDLE:
                                begin
                                    set_idle_transfer_detected(1);
                                    sample_data(prev_rx_req);
                                end
                                vip_ahb5_types::TRANSFER_BUSY,
                                vip_ahb5_types::TRANSFER_SEQ:
                                begin
                                    request_beats.push_back(rx_req);
                                    sample_data(prev_rx_req);
                                end
                            endcase
                        end
                        prev_rx_req = rx_req;
                    end
                    set_end_time($time);
                    build_complete_transfer();
                    transfer.set_transaction_complete(1);
                    record.record_complete_transaction(transfer);
                    broadcast();
                end
                vif.wait_for_reset(reset_detected);
            join_any
            disable fork;

            if(reset_detected)
            begin
                 set_end_time($time);
                 build_complete_transfer();
                 transfer.set_reset_detected(reset_detected);
                 record.record_complete_transaction(transfer);
                 broadcast();

                 reset_detected = 0;
            end
        end
    endtask : sample_transactions

    protected task sample_data(vip_ahb5_types::request_beat_struct_t prev_req);

        if(prev_req.Transfer != vip_ahb5_types::TRANSFER_BUSY)
        begin
            if(transfer_type == vip_ahb5_types::REQUEST_READ)
            begin
                vif.sample_read_data(sampled_data, sampled_user);
            end
            else
            begin
                vif.sample_write_data(sampled_data, sampled_user);
            end
            sampled_data_q.data.push_back(sampled_data);
            sampled_data_q.user.push_back(sampled_user);

            record.record_data(sampled_data_q, response_beats);
        end

    endtask:sample_data


    protected function void build_complete_transfer();

        transfer = new("sampled_transaction");
        transfer.set_node_type(configuration.node_type);
        transfer.set_start_time(get_start_time());
        transfer.set_finish_time(get_end_time());
        transfer.request_beats  = request_beats;
        transfer.response_beats = response_beats;
        transfer.data           = sampled_data_q;
        transfer.populate_transaction();

    endfunction : build_complete_transfer

    protected function void broadcast();

        if(reset_detected)
        begin
            transfer.set_reset_detected(1);
        end
        else
        begin
            transfer.set_transaction_complete(1);
        end
        item_collected_port.write(transfer);

        transfer = null;
        request_beats.delete();
        response_beats.delete();
        sampled_data_q.data.delete();
        sampled_data_q.user.delete();
    endfunction : broadcast

    protected task sample_channel_transfers();
        vip_ahb5_channel_cov_item channel_transfer;
        vif.wait_for_reset_exit();
        reset_detected = 0;
        while(!is_cancel_transfer()) begin
            channel_transfer = new("new_transfer");
            fork
                begin
                    vif.sample_response(channel_transfer.resp_beat);
                    vif.sample_transfer(channel_transfer.req_beat);
                    vif.sample_write_data(channel_transfer.wr_data,
                                          channel_transfer.data_user);
                    vif.sample_read_data(channel_transfer.rd_data,
                                         channel_transfer.data_user);
                end
                begin
                    vif.wait_for_reset(channel_transfer.reset);
                end
            join_any
            disable fork;
            channel_item_collected_port.write(channel_transfer);
            channel_transfer = null;
        end

    endtask: sample_channel_transfers



    `VIP_AHB5_FLAG_ACCESSOR(new_transfer_detected)
    `VIP_AHB5_FLAG_ACCESSOR(cancel_transfer)
    `VIP_AHB5_FLAG_ACCESSOR(idle_transfer_detected)
    `VIP_AHB5_ACCESSOR(time, start_time)
    `VIP_AHB5_ACCESSOR(time, new_trans_start_time)
    `VIP_AHB5_ACCESSOR(time, end_time)


endclass : vip_ahb5_monitor

`endif

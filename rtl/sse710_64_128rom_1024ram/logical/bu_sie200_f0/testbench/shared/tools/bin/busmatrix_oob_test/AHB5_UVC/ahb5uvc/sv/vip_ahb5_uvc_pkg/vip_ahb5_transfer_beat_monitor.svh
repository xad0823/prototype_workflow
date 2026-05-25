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

`ifndef VIP_AHB5_TRANSFER_BEAT_MONITOR
`define VIP_AHB5_TRANSFER_BEAT_MONITOR



class vip_ahb5_transfer_beat_monitor extends uvm_subscriber #(vip_ahb5_channel_cov_item);

    `uvm_component_utils(vip_ahb5_transfer_beat_monitor)

    uvm_analysis_port #(vip_ahb5_transaction) transfer_beat_collected_port;

    vip_ahb5_configuration configuration;

    vip_ahb5_channel_cov_item current_beat;

    vip_ahb5_channel_cov_item previous_beat;

    vip_ahb5_types::transfer_t current_transfer;

    vip_ahb5_types::transfer_t previous_transfer;

    vip_ahb5_channel_cov_item completed_beat;

    vip_ahb5_transaction transaction_;


    function new(string name = "vip_ahb5_transfer_beat_monitor", uvm_component parent = null);
        super.new(name,parent);
        transfer_beat_collected_port = new("transfer_beat_collected_port",this);
        current_transfer = vip_ahb5_types::TRANSFER_IDLE;
        previous_transfer = vip_ahb5_types::TRANSFER_IDLE;
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(vip_ahb5_configuration)::get(this,"","configuration",configuration))
        begin
            `vip_ahb5_fatal(("Agent configuration not set."))
        end

    endfunction: build_phase



    virtual function void write(vip_ahb5_channel_cov_item t);
        current_beat = t;
        current_transfer = vip_ahb5_types::transfer_t'(current_beat.req_beat.Transfer);
        if(current_beat.resp_beat.ReadyOut)
        begin
            if(is_valid_data_phase())
            begin
                update_item();
            end

            if(is_valid_address_phase())
            begin
                previous_beat = current_beat;
            end

            previous_transfer = current_transfer;
            current_beat = null;
        end
    endfunction: write

    virtual function
    bit is_valid_data_phase();
        return((previous_transfer != vip_ahb5_types::TRANSFER_IDLE)&&
               (previous_transfer != vip_ahb5_types::TRANSFER_BUSY)
              );
    endfunction: is_valid_data_phase

    virtual function
    bit is_valid_address_phase();
        return((current_transfer != vip_ahb5_types::TRANSFER_IDLE)&&
               (current_transfer != vip_ahb5_types::TRANSFER_BUSY)
              );
    endfunction: is_valid_address_phase

    virtual function
    void update_item();
        completed_beat = previous_beat;

        completed_beat.rd_data = current_beat.rd_data;
        completed_beat.wr_data = current_beat.wr_data;

        completed_beat.resp_beat = current_beat.resp_beat;

        populate_transaction();
        transfer_beat_collected_port.write(transaction_);
        transaction_ = null;
    endfunction : update_item

    virtual function
    void populate_transaction();
        transaction_ = new("vip_ahb5_transaction");
        transaction_.request_beats.delete();
        transaction_.response_beats.delete();
        transaction_.data.data.delete();

        transaction_.request_beats.push_back(completed_beat.req_beat);
        transaction_.response_beats.push_back(completed_beat.resp_beat);

        if(completed_beat.req_beat.Direction)
        begin
            transaction_.data.data.push_back(completed_beat.wr_data);
        end
        else begin
            transaction_.data.data.push_back(completed_beat.rd_data);
        end
    endfunction: populate_transaction


endclass: vip_ahb5_transfer_beat_monitor

`endif



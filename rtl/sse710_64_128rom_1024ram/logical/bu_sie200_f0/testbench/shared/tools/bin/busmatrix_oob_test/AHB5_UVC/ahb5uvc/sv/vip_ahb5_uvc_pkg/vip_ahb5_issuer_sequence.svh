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

`ifndef VIP_AHB5_ISSUER_SEQUENCE_SVH
`define VIP_AHB5_ISSUER_SEQUENCE_SVH



class vip_ahb5_issuer_sequence extends uvm_sequence#(vip_ahb5_transaction);

    `uvm_object_utils(vip_ahb5_issuer_sequence)

    vip_ahb5_control_knobs issuer_control_knobs;

    vip_ahb5_transaction request;

    vip_ahb5_transaction response;

    int unsigned data_byte_width;

    vip_ahb5_control_knobs default_issuer_control_knobs;

    vip_ahb5_types::vip_ahb5_physical_properties_t physical_properties;

    function new(string name = "vip_ahb5_issuer_sequence");
        super.new(name);
        default_issuer_control_knobs = vip_ahb5_control_knobs::type_id::create("default_issuer_control_knobs");
    endfunction : new

    function void initialize(vip_ahb5_control_knobs ctrl_knobs);
        issuer_control_knobs = ctrl_knobs;
    endfunction : initialize

    virtual task process_requests();
        request = vip_ahb5_transaction::type_id::create("request");
        request.set_node_type(vip_ahb5_types::MASTER_NODE);
        if(get_issuer_control_knobs() == null)
        begin
            set_issuer_control_knobs(default_issuer_control_knobs);
        end
        request.set_control_knobs(issuer_control_knobs);
        request.set_physical_properties(physical_properties);

        generate_requests();
    endtask: process_requests

    virtual task pre_start();
        vip_ahb5_sequencer master_sequencer;

        super.pre_start();

        if($cast(master_sequencer, m_sequencer))
        begin
            physical_properties = master_sequencer.get_physical_properties();
        end

    endtask:pre_start

    virtual task  body();
        process_requests();
    endtask : body

    function bit set_user_data (vip_ahb5_transaction request_,bit[7:0] data_[]);
        int index_;
        int data_byte_width;
        bit[7:0] req_data [];

        if(data_.size() == 0) begin
            `uvm_error(get_name(),"Input user data is empty array")
            return 0;
        end

        data_byte_width = physical_properties.data_byte_width;
        request_.data.data.delete();
        for(int i =0 ; i < data_.size() ; i++) begin
            req_data = new[data_byte_width];
            for(int j=0; j<data_byte_width; j++) begin
                req_data[j] = data_[index_];
                ++index_;
            end
            request_.data.data.push_back(req_data);
            if(index_ >= data_.size())
                break;
        end
        return 1;
    endfunction : set_user_data


    virtual task generate_requests();
    endtask : generate_requests

   `VIP_AHB5_ACCESSOR(vip_ahb5_control_knobs, issuer_control_knobs)




endclass: vip_ahb5_issuer_sequence

`endif

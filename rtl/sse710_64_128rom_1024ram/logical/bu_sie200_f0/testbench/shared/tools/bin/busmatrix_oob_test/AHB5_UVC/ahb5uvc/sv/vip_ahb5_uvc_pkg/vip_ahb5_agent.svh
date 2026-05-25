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

`ifndef VIP_AHB5_AGENT_SVH
`define VIP_AHB5_AGENT_SVH


class vip_ahb5_agent extends uvm_agent;

    `uvm_component_utils(vip_ahb5_agent)


    vip_ahb5_configuration configuration;

    vip_ahb5_master_driver master_drv;

    vip_ahb5_slave_driver slave_drv;

    vip_ahb5_monitor monitor;

    vip_ahb5_transfer_beat_monitor transfer_beat_monitor;

    vip_ahb5_sequencer sequencer;

    vip_ahb5_if_wrapper intf;

    vip_ahb5_memory_model memory_model;

    vip_ahb5_responder_sequence slave_responder_seq;

    vip_ahb5_types::vip_ahb5_physical_properties_t physical_properties;

    uvm_analysis_port #(vip_ahb5_transaction) item_collected_port;

    uvm_analysis_port #(vip_ahb5_channel_cov_item) channel_item_collected_port;

    uvm_analysis_port #(vip_ahb5_transaction) transfer_beat_collected_port;

    vip_ahb5_control_knobs slave_control_knobs;


    function new(string name = "vip_ahb5_agent", uvm_component parent=null);
        super.new(name,parent);
        item_collected_port = new("ahb_transaction_analysis_port",this);
        channel_item_collected_port = new("ahb_transfer_collected_port",this);
        transfer_beat_collected_port = new("ahb_transfer_beat_collected_port",this);
    endfunction: new


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(vip_ahb5_configuration)::get(this,"","configuration",configuration))
        begin
            configuration = vip_ahb5_configuration::type_id::create(
                "default_configuration", this);
        end

        if (!uvm_config_db #(vip_ahb5_if_wrapper)::get(this,"","vif", intf))
        begin
            `vip_ahb5_fatal(("Valid interface wrapper not set."))
        end

        uvm_config_db #(vip_ahb5_configuration)::set(this,"*","configuration",configuration);
        uvm_config_db #(vip_ahb5_if_wrapper)::set(this,"*", "vif", intf);

        physical_properties.data_byte_width = intf.get_data_byte_width();
        physical_properties.hselx_width = intf.get_number_of_slaves();

        if(get_is_active() == UVM_ACTIVE)
        begin
            sequencer = vip_ahb5_sequencer::type_id::create("sequencer",this);
            sequencer.set_physical_properties(physical_properties);

            if(configuration.node_type == vip_ahb5_types::MASTER_NODE)
            begin
                master_drv = vip_ahb5_master_driver::type_id::create("master_driver",this);
            end
            else
            begin
                slave_drv = vip_ahb5_slave_driver::type_id::create("slave_driver",this);
                if(get_memory_model() == null)
                begin
                    memory_model = vip_ahb5_memory_model::type_id::create("slave_memory_model",this);
                end
                else
                begin
                    memory_model = get_memory_model();
                end
                slave_responder_seq = vip_ahb5_responder_sequence::type_id::create("slave_responder_seq", this);
                slave_responder_seq.set_memory_model(memory_model);
                slave_responder_seq.set_physical_properties(physical_properties);
                if (uvm_config_db#(vip_ahb5_control_knobs)::get(this, "",
                        "responder_control_knobs", slave_control_knobs))
                begin
                    slave_responder_seq.set_responder_control_knobs(slave_control_knobs);
                end
                uvm_config_db#(uvm_sequence_base)::set(this,"sequencer.run_phase","default_sequence",slave_responder_seq);
            end
        end

        monitor = vip_ahb5_monitor::type_id::create("monitor",this);
        transfer_beat_monitor = vip_ahb5_transfer_beat_monitor::type_id::create("transfer_beat_monitor",this);
    endfunction: build_phase


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        monitor.item_collected_port.connect(this.item_collected_port);
        monitor.channel_item_collected_port.connect(this.channel_item_collected_port);

        monitor.channel_item_collected_port.connect(transfer_beat_monitor.analysis_export);

        transfer_beat_monitor.transfer_beat_collected_port.connect(this.transfer_beat_collected_port);

        if(get_is_active() == UVM_ACTIVE)
        begin
            if(configuration.node_type == vip_ahb5_types::MASTER_NODE)
            begin
                master_drv.seq_item_port.connect(sequencer.seq_item_export);
            end
            else
            begin
                slave_drv.seq_item_port.connect(sequencer.seq_item_export);
            end
        end
    endfunction : connect_phase

    `VIP_AHB5_ACCESSOR(vip_ahb5_memory_model,memory_model)


endclass: vip_ahb5_agent



`endif

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

`ifndef VIP_AHB5_COVERAGE_SVH
`define VIP_AHB5_COVERAGE_SVH



`uvm_analysis_imp_decl(_transaction)
`uvm_analysis_imp_decl(_channel)

class vip_ahb5_coverage extends uvm_component;

    `uvm_component_utils(vip_ahb5_coverage)

    uvm_analysis_imp_transaction#(vip_ahb5_transaction, vip_ahb5_coverage) transaction_coverage_port;

    uvm_analysis_imp_channel#(vip_ahb5_channel_cov_item, vip_ahb5_coverage) channel_coverage_port;

    vip_ahb5_coverage_configuration coverage_configuration;

    vip_ahb5_coverage_configuration default_configuration;

    vip_ahb5_transaction_coverage transaction_coverage;

    vip_ahb5_channel_coverage channel_coverage;

    function new(string name = "vip_ahb5_coverage", uvm_component parent = null);
        super.new(name,parent);
        transaction_coverage_port = new("transaction_cov_port",this);
        channel_coverage_port = new("channel_cov_port",this);
        default_configuration = new("default_coverage_configuration");
    endfunction: new

    virtual function void start_of_simulation_phase(uvm_phase phase);
        vip_ahb5_types::size_t transfer_size_max;

        if(get_coverage_configuration() ==  null)
        begin
            set_coverage_configuration(default_configuration);
        end

        if(!uvm_config_db#(vip_ahb5_types::size_t)::get(this,"","transfer_size_max",transfer_size_max))
        begin
            `vip_ahb5_fatal(("Max transfer size not set."))
        end
        else
        begin
            coverage_configuration.set_limit_parameter(vip_ahb5_types::PARAM_HSIZE_MAX,transfer_size_max);
        end

        transaction_coverage = new(get_full_name(),get_coverage_configuration());

        channel_coverage = new(get_full_name(),get_coverage_configuration());
    endfunction: start_of_simulation_phase



    function void write_transaction(vip_ahb5_transaction trans_);
        transaction_coverage.update(trans_);
    endfunction: write_transaction

    function void write_channel(vip_ahb5_channel_cov_item trans_);
        channel_coverage.update(trans_);
    endfunction: write_channel

   `VIP_AHB5_ACCESSOR(vip_ahb5_coverage_configuration,coverage_configuration)
   `VIP_AHB5_ACCESSOR(vip_ahb5_coverage_configuration,default_configuration)

endclass: vip_ahb5_coverage

`endif



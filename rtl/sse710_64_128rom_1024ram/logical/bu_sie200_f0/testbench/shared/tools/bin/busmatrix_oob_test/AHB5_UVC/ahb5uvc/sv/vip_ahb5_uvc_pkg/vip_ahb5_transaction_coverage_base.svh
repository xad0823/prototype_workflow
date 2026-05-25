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

`ifndef VIP_AHB5_TRANSACTION_COVERAGE_BASE_SVH
`define VIP_AHB5_TRANSACTION_COVERAGE_BASE_SVH



class vip_ahb5_transaction_coverage_base extends uvm_object;

    `uvm_object_utils(vip_ahb5_transaction_coverage_base)

    vip_ahb5_transaction transaction;

    vip_ahb5_coverage_configuration cov_config_;

    function new(string name_ = "vip_ahb5_channel_coverage_base");
        super.new(name_);
    endfunction : new

    virtual function void update(vip_ahb5_transaction trans_);
        this.transaction = new trans_;
        if(!get_cov_config_())
        begin
            cov_config_ = new("cov_config_");
        end
    endfunction: update

    `VIP_AHB5_ACCESSOR(vip_ahb5_coverage_configuration,cov_config_)

endclass: vip_ahb5_transaction_coverage_base

`endif


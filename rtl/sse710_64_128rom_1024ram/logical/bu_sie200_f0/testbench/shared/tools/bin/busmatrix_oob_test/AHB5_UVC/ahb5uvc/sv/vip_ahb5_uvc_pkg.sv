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

`ifndef VIP_AHB5_UVC_PKG_SV
`define VIP_AHB5_UVC_PKG_SV

`include "uvm_macros.svh"
`include "vip_ahb5_macros.svh"
package vip_ahb5_uvc_pkg;
    import uvm_pkg::*;
    import vip_ahb5_common_pkg::*;

    `include "vip_ahb5_uvc_pkg/vip_ahb5_configuration.svh"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_control_knobs.svh"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_transaction.svh"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_exclusive_monitor.sv"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_transaction_layer.svh"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_sequencer.svh"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_master_driver.svh"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_slave_driver.svh"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_coverage_macros.svh"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_coverage_configuration.svh"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_transaction_coverage_base.svh"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_transaction_coverage.svh"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_channel_coverage_item.svh"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_channel_coverage_base.svh"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_channel_coverage.svh"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_coverage.svh"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_transaction_record_base.svh"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_transaction_mti_record.svh"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_monitor.svh"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_transfer_beat_monitor.svh"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_issuer_sequence.svh"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_slave_base_response_sequence.sv"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_responder_sequence.svh"
    `include "vip_ahb5_uvc_pkg/vip_ahb5_agent.svh"

endpackage

`endif


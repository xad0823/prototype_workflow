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

`ifndef VIP_AHB5_COMMON_PKG_SV
`define VIP_AHB5_COMMON_PKG_SV

`include "uvm_macros.svh"
`include "vip_ahb5_macros.svh"

package vip_ahb5_common_pkg;
    import uvm_pkg::*;

    `include "vip_ahb5_common_pkg/vip_ahb5_types.svh"

    `include "vip_ahb5_common_pkg/vip_ahb5_if_wrapper.svh"
    `include "vip_ahb5_common_pkg/vip_ahb5_master_if_wrapper.svh"
    `include "vip_ahb5_common_pkg/vip_ahb5_slave_if_wrapper.svh"
    `include "vip_ahb5_common_pkg/vip_ahb5_system_address_map.sv"
    `include "vip_ahb5_common_pkg/vip_ahb5_memory_element.svh"
    `include "vip_ahb5_common_pkg/vip_ahb5_memory_model.svh"
endpackage

`endif


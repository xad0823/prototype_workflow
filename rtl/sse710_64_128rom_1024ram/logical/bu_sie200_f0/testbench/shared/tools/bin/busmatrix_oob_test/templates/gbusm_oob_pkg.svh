// *********************************************************************
//  The confidential and proprietary information contained in this file may
//  only be used by a person authorised under and to the extent permitted
//  by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//             (C) COPYRIGHT 2015-2016 ARM Limited or its affiliates.
//                 ALL RIGHTS RESERVED
//
//  This entire notice must be reproduced on all copies of this file
//  and copies of this file may only be made by a person if such person is
//  permitted to do so under the terms of a subsisting license agreement
//  from ARM Limited or its affiliates.
//
//   Revision            : 3ed9556
//   Checked In          : Mon Sep 12 15:21:46 2016 +0100
//
//   Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
// *********************************************************************


`include "uvm_macros.svh"
`include "ggve_defines.sv"

package gbusm_oob_pkg;



    import uvm_pkg::*;
    import vip_ahb5_common_pkg::*;
    import vip_ahb5_uvc_pkg::*;


    `include "uvm_data.svh"
    `include "scoreboard_basic.sv"

    `include "gbusm_addr_range.svh"
    `include "gbusm_addr_map.svh"
    `include "gbusm_ref_model.svh"
    `include "gbusm_env.svh"

    `include "gbusm_vip_ahb5_master_sequence.sv"
    `include "generic_busmatrix_oob_test.sv"




endpackage : gbusm_oob_pkg

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

`ifndef VIP_AHB5_CONTROL_KNOBS_SVH
`define VIP_AHB5_CONTROL_KNOBS_SVH


class vip_ahb5_control_knobs extends uvm_object;

    `uvm_object_utils(vip_ahb5_control_knobs)

    vip_ahb5_types::resp_mode_t response_mode;

    vip_ahb5_types::timing_mode_t timing_mode;

    int unsigned wait_state_delay_cycle_min;

    int unsigned wait_state_delay_cycle_max;

    bit generate_random_data;

    int unsigned max_burst_length;

    bit support_v8_memory;

    bit support_secure_transfer;

    string slave_response_sequence_map [int unsigned];

    bit[31:0] max_slave_number;

    vip_ahb5_types::user_mode_t user_generation_mode;

    function new(string name = "vip_ahb5_control_knobs");
        super.new(name);
        set_timing_mode(vip_ahb5_types::TIMING_ASAP);
        set_response_mode(vip_ahb5_types::RESP_MODE_OKAY);
        set_wait_state_delay_cycle_min(1);
        set_wait_state_delay_cycle_max(16);
        set_generate_random_data(1);
        set_max_burst_length(256);
        set_support_v8_memory(1);
        set_support_secure_transfer(1);
        set_user_generation_mode(vip_ahb5_types::USER_RANDOM);
    endfunction : new

    `VIP_AHB5_ACCESSOR(vip_ahb5_types::timing_mode_t,timing_mode)

    `VIP_AHB5_ACCESSOR(vip_ahb5_types::resp_mode_t,response_mode)

    `VIP_AHB5_ACCESSOR(int unsigned, wait_state_delay_cycle_min)

    `VIP_AHB5_ACCESSOR(int unsigned, wait_state_delay_cycle_max)

    `VIP_AHB5_ACCESSOR(bit,generate_random_data)

    `VIP_AHB5_ACCESSOR(bit[31:0],max_slave_number)

    `VIP_AHB5_ACCESSOR(int unsigned,max_burst_length)

    `VIP_AHB5_ACCESSOR(bit,support_v8_memory)

    `VIP_AHB5_ACCESSOR(bit,support_secure_transfer)

    `VIP_AHB5_ACCESSOR(vip_ahb5_types::user_mode_t,user_generation_mode)


endclass: vip_ahb5_control_knobs

`endif

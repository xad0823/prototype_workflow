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

`ifndef VIP_AHB5_CONFIGURATION_SVH
`define VIP_AHB5_CONFIGURATION_SVH



class vip_ahb5_configuration extends uvm_object;

    `uvm_object_utils(vip_ahb5_configuration)

    vip_ahb5_types::node_t node_type;

    bit enable_coverage;

    bit enable_recording;

    vip_ahb5_types::idle_mode_t idle_mode;

    protected vip_ahb5_types:: memory_mode_t mem_model_default_init_mode;

    protected vip_ahb5_types:: error_mode_t mem_model_default_error_mode;

    protected bit mem_model_corrupt_write_data_on_error;

    protected bit mem_model_corrupt_read_data;

    protected bit mem_model_create_mem_on_read;

    protected bit[7:0] mem_model_default_data;

    bit [3:0] default_slave;

    bit support_exclusives;

    bit bypass_exclusive_monitor;

    vip_ahb5_system_address_map sam;

  bit allow_address_change_during_wait;

    protected vip_ahb5_types::endianness_t  endianness;

    function new(string name = "vip_ahb5_configuration");
        super.new(name);
        set_enable_coverage(1);
        set_support_exclusives(1);
        set_bypass_exclusive_monitor(0);
        set_default_slave(1);
        set_allow_address_change_during_wait(0);
    endfunction : new

    function void register_address_range(int unsigned slave_id,
                                    vip_ahb5_types::address_t start_address,
                                    vip_ahb5_types::address_t end_address,
                                    vip_ahb5_types::memory_v8_t memory_type,
                                    vip_ahb5_types::access_attr_t access_attr);
        vip_ahb5_types::address_range_struct_t address_range;
        address_range.start_address = start_address;
        address_range.end_address   = end_address;
        address_range.memory_type   = memory_type;
        address_range.access_type   = access_attr;
        if(sam != null) begin
            sam.register_address_range(address_range,slave_id);
        end
        else begin
            `vip_ahb5_fatal(("System address Map is Null. Please pass SAM handle to master configuration class"))
        end
    endfunction : register_address_range

    `VIP_AHB5_ACCESSOR(vip_ahb5_types:: memory_mode_t,mem_model_default_init_mode)
    `VIP_AHB5_ACCESSOR(vip_ahb5_types::error_mode_t,mem_model_default_error_mode)
    `VIP_AHB5_ACCESSOR(bit,mem_model_corrupt_write_data_on_error)
    `VIP_AHB5_ACCESSOR(bit,mem_model_corrupt_read_data)
    `VIP_AHB5_ACCESSOR(bit,mem_model_create_mem_on_read)
    `VIP_AHB5_ACCESSOR(bit[7:0],mem_model_default_data)
    `VIP_AHB5_ACCESSOR(bit[3:0],default_slave)
    `VIP_AHB5_ACCESSOR(vip_ahb5_types::node_t,node_type)
    `VIP_AHB5_ACCESSOR(vip_ahb5_types::idle_mode_t,idle_mode)
    `VIP_AHB5_FLAG_ACCESSOR(support_exclusives)
    `VIP_AHB5_FLAG_ACCESSOR(bypass_exclusive_monitor)
    `VIP_AHB5_FLAG_ACCESSOR(enable_coverage)
    `VIP_AHB5_FLAG_ACCESSOR(enable_recording)
    `VIP_AHB5_FLAG_ACCESSOR(allow_address_change_during_wait)
    `VIP_AHB5_ACCESSOR(vip_ahb5_types::endianness_t,endianness)

endclass: vip_ahb5_configuration

`endif

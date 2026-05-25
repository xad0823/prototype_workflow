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

`ifndef VIP_AHB5_MEMORY_ELEMENT_SVH
`define VIP_AHB5_MEMORY_ELEMENT_SVH


class vip_ahb5_memory_element extends uvm_object;

    local vip_ahb5_types::mem_unit_struct_t beat_data;
    local vip_ahb5_types::mem_unit_struct_t previous_data;

    local bit beat_error_;

    function new(string name ="memory_element");
        super.new(name);
    endfunction : new

    function void write_data(vip_ahb5_types::mem_unit_struct_t wdata,bit store_previous_data);

            if(store_previous_data) begin
                previous_data = beat_data;
            end
            this.beat_data = wdata;
    endfunction : write_data

    function vip_ahb5_types::mem_unit_struct_t read_data();
        return this.beat_data;
    endfunction : read_data



endclass : vip_ahb5_memory_element


`endif

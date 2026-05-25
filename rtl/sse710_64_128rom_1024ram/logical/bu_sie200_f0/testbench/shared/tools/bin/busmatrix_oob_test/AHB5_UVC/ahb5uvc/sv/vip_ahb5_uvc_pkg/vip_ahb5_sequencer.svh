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

`ifndef VIP_AHB5_SEQUENCER_SVH
`define VIP_AHB5_SEQUENCER_SVH


class vip_ahb5_sequencer extends uvm_sequencer #(vip_ahb5_transaction);

    `uvm_component_utils(vip_ahb5_sequencer)

    vip_ahb5_types::vip_ahb5_physical_properties_t physical_properties;

    function new(string name = "vip_ahb5_sequencer", uvm_component parent=null);
        super.new(name,parent);
        set_arbitration(SEQ_ARB_WEIGHTED);
    endfunction: new

   `VIP_AHB5_ACCESSOR(vip_ahb5_types::vip_ahb5_physical_properties_t, physical_properties)


endclass: vip_ahb5_sequencer

`endif

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

 <Master analysis ports declaration by macro>
 <Slave analysis ports declaration by macro>


class busmtrx_ref_model extends uvm_component;
`uvm_component_utils(busmtrx_ref_model)

    <master_aports_decl>
    <slave_aports_decl>

    uvm_analysis_port #(vip_ahb5_transaction) aport_mst_to_scbd[int unsigned][int unsigned];
    uvm_analysis_port #(vip_ahb5_transaction) aport_slv_to_scbd[int unsigned];

    busmtrx_addr_map addr_map;

    scoreboard_basic scbd[int unsigned];


    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        addr_map = busmtrx_addr_map::type_id::create("addr_map",this);
        uvm_config_db#(busmtrx_addr_map)::set(uvm_root::get(),"*","addr_map",addr_map);

    <Build scoreboards, analysis ports>
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        foreach (scbd[i]) begin
            aport_slv_to_scbd[i].connect(scbd[i].aport_slave_ahb5[0]);
      foreach (aport_mst_to_scbd[j, k])begin
        if(k==i) begin
            aport_mst_to_scbd[j][k].connect(scbd[k].aport_master_ahb5[j]);
        end
      end
        end
    endfunction

    <write functions for master and slave analysis ports>

endclass

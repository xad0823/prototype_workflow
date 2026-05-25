// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//               (C) COPYRIGHT 2016 ARM Limited or its affiliates.
//                   ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
// Checked In : Tue Aug 9 08:12:07 2016 +0100
// Revision : 8ac0ed4
//
// Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
// -----------------------------------------------------------------------------


`ifndef _AHB5_TO_APB_ASYNC_TEST_SVH_
`define _AHB5_TO_APB_ASYNC_TEST_SVH_


class generic_busmatrix_oob_test extends uvm_test;

    gbusm_env env;
    `ifdef NUM_AHB5_MASTERS
      gbusm_vip_ahb5_master_sequence mst_seq[0:`NUM_AHB5_MASTERS];
    `endif

    `uvm_component_utils(generic_busmatrix_oob_test)

    virtual busmtrx_remap_if #(.REMAP_WIDTH(REMAP_WIDTH)) remap_vif;

    function new(string name="", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = gbusm_env::type_id::create("env",this);
        if(!uvm_config_db#(virtual busmtrx_remap_if#(.REMAP_WIDTH(REMAP_WIDTH)))::get(this,"","remap_vif",remap_vif))
        begin
            `uvm_fatal("REMAP", "Remap interface not set.")
        end
    remap_vif.REMAP = 0;

    endfunction



  task run_phase(uvm_phase phase);
        for(int i=0; i < `NUM_AHB5_MASTERS; i++) begin
          mst_seq[i] = gbusm_vip_ahb5_master_sequence::type_id::create({"mst_seq",$sformatf("%0d",i)});
      mst_seq[i].set_master_num(i);
        end
        phase.raise_objection(this,"Starting the test");
        $display("Sequence started");

        for(int i=0; i < `NUM_AHB5_MASTERS; i++) begin
           automatic int idx = i;
           fork
             mst_seq[idx].start(env.ahb5_master_agent[idx].sequencer);
           join_none
         end
         wait fork;
        #50ns;

        phase.drop_objection(this,"Ending the test");
        $display("Sequence stopped");
    endtask

endclass : generic_busmatrix_oob_test

`endif


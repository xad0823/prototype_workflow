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
`ifdef MTI_SIM
    `include "ggve_defines.sv"
`endif

module tb_sie200_ahb5_busmatrix;

   import uvm_pkg::*;
   import vip_ahb5_common_pkg::*;
   import vip_ahb5_uvc_pkg::*;
   import gbusm_oob_pkg::*;


   reg ggve_clk;
   reg ggve_resetn;
   reg tbench_clken;

   parameter GGVE_CLK_PERIOD = 10;
   initial begin
      ggve_clk  = 1'b0;
      tbench_clken = 1'b1;
   end
   always #(GGVE_CLK_PERIOD/2) ggve_clk = ~ggve_clk;

   initial begin
      ggve_resetn = 1'b0;
      repeat (5) @(posedge ggve_clk);
      ggve_resetn <= 1'b1;
   end

    typedef virtual vip_ahb5_interface #(.DATA_BITS(DATA_WIDTH),.HSEL_WIDTH(HSEL_WIDTH),.HMASTER_WIDTH(MASTER_WIDTH),.HAUSER_WIDTH(USER_WIDTH),.HRUSER_WIDTH(USER_WIDTH),.HWUSER_WIDTH(USER_WIDTH)) vip_ahb5_vif_t;

    vip_ahb5_interface #(.DATA_BITS(DATA_WIDTH),.HSEL_WIDTH(HSEL_WIDTH),.HMASTER_WIDTH(MASTER_WIDTH),.HAUSER_WIDTH(USER_WIDTH),.HRUSER_WIDTH(USER_WIDTH),.HWUSER_WIDTH(USER_WIDTH))  ahb5_mstr_rtl_if[0:`NUM_AHB5_MASTERS-1](ggve_clk,ggve_resetn);

    vip_ahb5_interface #(.DATA_BITS(DATA_WIDTH),.HSEL_WIDTH(HSEL_WIDTH),.HMASTER_WIDTH(MASTER_WIDTH),.HAUSER_WIDTH(USER_WIDTH),.HRUSER_WIDTH(USER_WIDTH),.HWUSER_WIDTH(USER_WIDTH)) ahb5_slv_rtl_if[0:`NUM_AHB5_SLAVES-1](ggve_clk,ggve_resetn);



    busmtrx_remap_if #(.REMAP_WIDTH(REMAP_WIDTH)) remap_if();





// START_OF_DUT_INST

// END_OF_DUT_INST

   initial
   begin
      uvm_config_db#(virtual busmtrx_remap_if#(.REMAP_WIDTH(REMAP_WIDTH)))::set(uvm_root::get(),"","remap_vif",remap_if);
      run_test();
   end

   `ifdef NUM_AHB5_MASTERS
      for(genvar i=0; i <`NUM_AHB5_MASTERS; i++) begin
         initial begin
            vip_ahb5_common_pkg::vip_ahb5_master_if_wrapper#(vip_ahb5_vif_t) master_vif_wrapper;
            master_vif_wrapper = new(ahb5_mstr_rtl_if[i]);
            uvm_config_db#(vip_ahb5_common_pkg::vip_ahb5_if_wrapper)::set(uvm_root::get(),{"uvm_test_top.env.ahb5_master",$sformatf("%0d",i)},"vif",master_vif_wrapper);
         end
      end
   `endif

   `ifdef NUM_AHB5_SLAVES
      for(genvar i=0; i <`NUM_AHB5_SLAVES; i++) begin
         initial begin
            vip_ahb5_common_pkg::vip_ahb5_slave_if_wrapper#(vip_ahb5_vif_t) slave_vif_wrapper;
            slave_vif_wrapper = new(ahb5_slv_rtl_if[i]);
            uvm_config_db#(vip_ahb5_common_pkg::vip_ahb5_if_wrapper)::set(uvm_root::get(),{"uvm_test_top.env.ahb5_slave",$sformatf("%0d",i)},"vif",slave_vif_wrapper);
         end
      end
   `endif

   `ifdef NUM_APB_MASTERS
      for(genvar i=0; i <`NUM_APB_MASTERS; i++) begin
         initial begin
            uvm_config_db#(apb4_vif_t)::set(uvm_root::get(),{"uvm_test_top.env.apb_master",$sformatf("%0d",i)},"VIF",apb_mstr_rtl_if[i]);
         end
      end
   `endif

   `ifdef NUM_APB_SLAVES
      for(genvar i=0; i <`NUM_APB_SLAVES; i++) begin
         initial begin
            uvm_config_db#(apb4_vif_t)::set(uvm_root::get(),{"uvm_test_top.env.apb_slave",$sformatf("%0d",i)},"VIF",apb_slv_rtl_if[i]);
         end
      end
   `endif






endmodule

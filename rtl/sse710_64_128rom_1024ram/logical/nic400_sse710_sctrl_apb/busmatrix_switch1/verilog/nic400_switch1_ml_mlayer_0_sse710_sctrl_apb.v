//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------


module nic400_switch1_ml_mlayer_0_sse710_sctrl_apb
  (
    awid_m,
    awaddr_m,
    awlen_m,
    awsize_m,
    awburst_m,
    awlock_m,
    awcache_m,
    awprot_m,
    awvalid_m,
    awvalid_vect_m,
    awready_m,
    aw_qv_m,
   
    wdata_m,
    wstrb_m,
    wlast_m,
    wvalid_m,
    wready_m,

    bid_m,
    bresp_m,
    bvalid_m,
    bready_m,

    arid_m,
    araddr_m,
    arlen_m,
    arsize_m,
    arburst_m,
    arlock_m,
    arcache_m,
    arprot_m,
    arvalid_m,
    arvalid_vect_m,
    arready_m,
    ar_qv_m,
   
    rid_m,
    rdata_m,
    rresp_m,
    rlast_m,
    rvalid_m,
    rready_m,

    awid_s0,
    awaddr_s0,
    awlen_s0,
    awsize_s0,
    awburst_s0,
    awlock_s0,
    awcache_s0,
    awprot_s0,
    awvalid_s0,
    awvalid_vect_s0,
    awready_s0,
    aw_qv_s0,
   
    wdata_s0,
    wstrb_s0,   
    wlast_s0,
    wvalid_s0,
    wready_s0,

    bid_s0,
    bresp_s0,
    bvalid_s0,
    bready_s0,  

    arid_s0,
    araddr_s0,
    arlen_s0,
    arsize_s0,
    arburst_s0,
    arlock_s0,
    arcache_s0,
    arprot_s0,
    arvalid_s0,
    arvalid_vect_s0,
    arready_s0,
    ar_qv_s0,
   
    rid_s0,
    rdata_s0,
    rresp_s0,
    rlast_s0,
    rvalid_s0,
    rready_s0,

    aclk,
    aresetn
  );




  output [11:0]      awid_m;
  output [31:0]     awaddr_m;
  output [7:0]      awlen_m;
  output [2:0]      awsize_m;
  output [1:0]      awburst_m;
  output            awlock_m;
  output [3:0]      awcache_m;
  output [2:0]      awprot_m;
  output            awvalid_m;
  output            awvalid_vect_m;
  input             awready_m;
  output [3:0]      aw_qv_m;
   
  output  [31:0]    wdata_m;
  output  [3:0]     wstrb_m;
  output            wlast_m;
  output            wvalid_m;
  input             wready_m;

  input [11:0]       bid_m;
  input [1:0]       bresp_m;
  input             bvalid_m;
  output            bready_m;

  output [11:0]      arid_m;
  output [31:0]     araddr_m;
  output [7:0]      arlen_m;
  output [2:0]      arsize_m;
  output [1:0]      arburst_m;
  output            arlock_m;
  output [3:0]      arcache_m;
  output [2:0]      arprot_m;
  output            arvalid_m;
  output            arvalid_vect_m;
  input             arready_m;
  output [3:0]      ar_qv_m;
   
  input [11:0]       rid_m;
  input [31:0]      rdata_m;
  input [1:0]       rresp_m;
  input             rlast_m;
  input             rvalid_m;
  output            rready_m;


  input  [11:0]      awid_s0;
  input  [31:0]     awaddr_s0;
  input  [7:0]      awlen_s0;
  input  [2:0]      awsize_s0;
  input  [1:0]      awburst_s0;
  input             awlock_s0;
  input  [3:0]      awcache_s0;
  input  [2:0]      awprot_s0;
  input             awvalid_s0;
  input             awvalid_vect_s0;
  output            awready_s0;
  input  [3:0]      aw_qv_s0;
   
  input  [31:0]     wdata_s0;
  input  [3:0]      wstrb_s0;   
  input             wlast_s0;
  input             wvalid_s0;
  output            wready_s0;

  output [11:0]      bid_s0;
  output [1:0]      bresp_s0;
  output            bvalid_s0;
  input             bready_s0;  

  input  [11:0]      arid_s0;
  input  [31:0]     araddr_s0;
  input  [7:0]      arlen_s0;
  input  [2:0]      arsize_s0;
  input  [1:0]      arburst_s0;
  input             arlock_s0;
  input  [3:0]      arcache_s0;
  input  [2:0]      arprot_s0;
  input             arvalid_s0;
  input             arvalid_vect_s0;
  output            arready_s0;
  input  [3:0]      ar_qv_s0;

  output  [11:0]     rid_s0;
  output  [31:0]    rdata_s0;
  output [1:0]      rresp_s0;
  output            rlast_s0;
  output            rvalid_s0;
  input             rready_s0;

  input             aclk;
  input             aresetn;


  wire              wr_cnt_empty;




nic400_switch1_add_sel_ml0_sse710_sctrl_apb u_nic400_switch1_add_sel_ml0_sse710_sctrl_apb (
        .awid_m         (awid_m),
        .awaddr_m       (awaddr_m),
        .awlen_m        (awlen_m),
        .awsize_m       (awsize_m),
        .awburst_m      (awburst_m),
        .awlock_m       (awlock_m),
        .awcache_m      (awcache_m),
        .awprot_m       (awprot_m),
        .awvalid_m      (awvalid_m),
        .awvalid_vect_m (awvalid_vect_m),
        .awready_m      (awready_m),
        .aw_qv_m        (aw_qv_m),
        
        .arid_m         (arid_m),
        .araddr_m       (araddr_m),
        .arlen_m        (arlen_m),
        .arsize_m       (arsize_m),
        .arburst_m      (arburst_m),
        .arlock_m       (arlock_m),
        .arcache_m      (arcache_m),
        .arprot_m       (arprot_m),
        .arvalid_m      (arvalid_m),
        .arvalid_vect_m (arvalid_vect_m),
        .arready_m      (arready_m),
        .ar_qv_m        (ar_qv_m),
        .bvalid_m       (bvalid_m),
        .bready_m       (bready_m),
        .rvalid_m       (rvalid_m),
        .rready_m       (rready_m),
        .rlast_m        (rlast_m),
        .awid_s0         (awid_s0),
        .awaddr_s0       (awaddr_s0),
        .awlen_s0        (awlen_s0),
        .awsize_s0       (awsize_s0),
        .awburst_s0      (awburst_s0),
        .awlock_s0       (awlock_s0),
        .awcache_s0      (awcache_s0),
        .awprot_s0       (awprot_s0),
        .awvalid_s0      (awvalid_s0),
        .awvalid_vect_s0 (awvalid_vect_s0),
        .awready_s0      (awready_s0),
        .aw_qv_s0        (aw_qv_s0),
        .arid_s0         (arid_s0),
        .araddr_s0       (araddr_s0),
        .arlen_s0        (arlen_s0),
        .arsize_s0       (arsize_s0),
        .arburst_s0      (arburst_s0),
        .arlock_s0       (arlock_s0),
        .arcache_s0      (arcache_s0),
        .arprot_s0       (arprot_s0),
        .arvalid_s0      (arvalid_s0),
        .arvalid_vect_s0 (arvalid_vect_s0),
        .arready_s0      (arready_s0),
        .ar_qv_s0        (ar_qv_s0),

        .wr_cnt_empty   (wr_cnt_empty),
        .aclk           (aclk),
        .aresetn        (aresetn)
);

nic400_switch1_wr_sel_ml0_sse710_sctrl_apb u_nic400_switch1_wr_sel_ml0_sse710_sctrl_apb (
        .wdata_s0     (wdata_s0),
        .wstrb_s0     (wstrb_s0),
        .wlast_s0     (wlast_s0),
        .wvalid_s0    (wvalid_s0),
        .wready_s0    (wready_s0),

        .wdata_m      (wdata_m),
        .wstrb_m      (wstrb_m),
        .wlast_m      (wlast_m),
        .wvalid_m     (wvalid_m),
        .wready_m     (wready_m)
);



nic400_switch1_ret_sel_ml0_sse710_sctrl_apb u_nic400_switch1_ret_sel_ml0_sse710_sctrl_apb (
        .wr_cnt_empty (wr_cnt_empty),
        .bid_s0       (bid_s0),
        .bresp_s0     (bresp_s0),
        .bvalid_s0    (bvalid_s0),
        .bready_s0    (bready_s0),
        .rid_s0       (rid_s0),
        .rdata_s0     (rdata_s0),
        .rresp_s0     (rresp_s0),
        .rlast_s0     (rlast_s0),
        .rvalid_s0    (rvalid_s0),
        .rready_s0    (rready_s0),
        .bid_m        (bid_m),
        .bresp_m      (bresp_m),
        .bvalid_m     (bvalid_m),
        .bready_m     (bready_m),
        .rid_m        (rid_m),
        .rdata_m      (rdata_m),
        .rresp_m      (rresp_m),
        .rlast_m      (rlast_m),
        .rvalid_m     (rvalid_m),
        .rready_m     (rready_m)
);


 
    `ifdef ARM_ASSERT_ON


    `endif

  endmodule



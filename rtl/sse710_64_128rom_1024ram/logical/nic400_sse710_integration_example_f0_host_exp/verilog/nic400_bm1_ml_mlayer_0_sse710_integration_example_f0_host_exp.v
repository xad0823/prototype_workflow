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


module nic400_bm1_ml_mlayer_0_sse710_integration_example_f0_host_exp
  (
    awuser_m,
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

    aruser_m,
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

    awuser_s0,
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

    aruser_s0,
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

    awuser_s1,
    awid_s1,
    awaddr_s1,
    awlen_s1,
    awsize_s1,
    awburst_s1,
    awlock_s1,
    awcache_s1,
    awprot_s1,
    awvalid_s1,
    awvalid_vect_s1,
    awready_s1,
    aw_qv_s1,
   
    wdata_s1,
    wstrb_s1,   
    wlast_s1,
    wvalid_s1,
    wready_s1,

    bid_s1,
    bresp_s1,
    bvalid_s1,
    bready_s1,  

    aruser_s1,
    arid_s1,
    araddr_s1,
    arlen_s1,
    arsize_s1,
    arburst_s1,
    arlock_s1,
    arcache_s1,
    arprot_s1,
    arvalid_s1,
    arvalid_vect_s1,
    arready_s1,
    ar_qv_s1,
   
    rid_s1,
    rdata_s1,
    rresp_s1,
    rlast_s1,
    rvalid_s1,
    rready_s1,

    aclk,
    aresetn
  );




  output [3:0]      awuser_m;
  output [17:0]      awid_m;
  output [31:0]     awaddr_m;
  output [7:0]      awlen_m;
  output [2:0]      awsize_m;
  output [1:0]      awburst_m;
  output            awlock_m;
  output [3:0]      awcache_m;
  output [2:0]      awprot_m;
  output            awvalid_m;
  output [1:0]      awvalid_vect_m;
  input             awready_m;
  output [3:0]      aw_qv_m;
   
  output  [63:0]    wdata_m;
  output  [7:0]     wstrb_m;
  output            wlast_m;
  output            wvalid_m;
  input             wready_m;

  input [17:0]       bid_m;
  input [1:0]       bresp_m;
  input             bvalid_m;
  output            bready_m;

  output [3:0]      aruser_m;
  output [17:0]      arid_m;
  output [31:0]     araddr_m;
  output [7:0]      arlen_m;
  output [2:0]      arsize_m;
  output [1:0]      arburst_m;
  output            arlock_m;
  output [3:0]      arcache_m;
  output [2:0]      arprot_m;
  output            arvalid_m;
  output [1:0]      arvalid_vect_m;
  input             arready_m;
  output [3:0]      ar_qv_m;
   
  input [17:0]       rid_m;
  input [63:0]      rdata_m;
  input [1:0]       rresp_m;
  input             rlast_m;
  input             rvalid_m;
  output            rready_m;


  input  [3:0]      awuser_s0;
  input  [17:0]      awid_s0;
  input  [31:0]     awaddr_s0;
  input  [7:0]      awlen_s0;
  input  [2:0]      awsize_s0;
  input  [1:0]      awburst_s0;
  input             awlock_s0;
  input  [3:0]      awcache_s0;
  input  [2:0]      awprot_s0;
  input             awvalid_s0;
  input  [1:0]      awvalid_vect_s0;
  output            awready_s0;
  input  [3:0]      aw_qv_s0;
   
  input  [63:0]     wdata_s0;
  input  [7:0]      wstrb_s0;   
  input             wlast_s0;
  input             wvalid_s0;
  output            wready_s0;

  output [17:0]      bid_s0;
  output [1:0]      bresp_s0;
  output            bvalid_s0;
  input             bready_s0;  

  input  [3:0]      aruser_s0;
  input  [17:0]      arid_s0;
  input  [31:0]     araddr_s0;
  input  [7:0]      arlen_s0;
  input  [2:0]      arsize_s0;
  input  [1:0]      arburst_s0;
  input             arlock_s0;
  input  [3:0]      arcache_s0;
  input  [2:0]      arprot_s0;
  input             arvalid_s0;
  input  [1:0]      arvalid_vect_s0;
  output            arready_s0;
  input  [3:0]      ar_qv_s0;

  output  [17:0]     rid_s0;
  output  [63:0]    rdata_s0;
  output [1:0]      rresp_s0;
  output            rlast_s0;
  output            rvalid_s0;
  input             rready_s0;

  input  [3:0]      awuser_s1;
  input  [17:0]      awid_s1;
  input  [31:0]     awaddr_s1;
  input  [7:0]      awlen_s1;
  input  [2:0]      awsize_s1;
  input  [1:0]      awburst_s1;
  input             awlock_s1;
  input  [3:0]      awcache_s1;
  input  [2:0]      awprot_s1;
  input             awvalid_s1;
  input  [1:0]      awvalid_vect_s1;
  output            awready_s1;
  input  [3:0]      aw_qv_s1;
   
  input  [63:0]     wdata_s1;
  input  [7:0]      wstrb_s1;   
  input             wlast_s1;
  input             wvalid_s1;
  output            wready_s1;

  output [17:0]      bid_s1;
  output [1:0]      bresp_s1;
  output            bvalid_s1;
  input             bready_s1;  

  input  [3:0]      aruser_s1;
  input  [17:0]      arid_s1;
  input  [31:0]     araddr_s1;
  input  [7:0]      arlen_s1;
  input  [2:0]      arsize_s1;
  input  [1:0]      arburst_s1;
  input             arlock_s1;
  input  [3:0]      arcache_s1;
  input  [2:0]      arprot_s1;
  input             arvalid_s1;
  input  [1:0]      arvalid_vect_s1;
  output            arready_s1;
  input  [3:0]      ar_qv_s1;

  output  [17:0]     rid_s1;
  output  [63:0]    rdata_s1;
  output [1:0]      rresp_s1;
  output            rlast_s1;
  output            rvalid_s1;
  input             rready_s1;

  input             aclk;
  input             aresetn;


  wire   [1:0]      aw_sel;
  wire              wr_cnt_empty;




nic400_bm1_add_sel_ml0_sse710_integration_example_f0_host_exp u_nic400_bm1_add_sel_ml0_sse710_integration_example_f0_host_exp (
        .awuser_m       (awuser_m),
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
        
        .aruser_m       (aruser_m),
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
        .aw_sel         (aw_sel),
        .wvalid_m       (wvalid_m),
        .wready_m       (wready_m),
        .wlast_m        (wlast_m),
        .bvalid_m       (bvalid_m),
        .bready_m       (bready_m),
        .rvalid_m       (rvalid_m),
        .rready_m       (rready_m),
        .rlast_m        (rlast_m),
        .awuser_s0       (awuser_s0),
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
        .aruser_s0       (aruser_s0),
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

        .awuser_s1       (awuser_s1),
        .awid_s1         (awid_s1),
        .awaddr_s1       (awaddr_s1),
        .awlen_s1        (awlen_s1),
        .awsize_s1       (awsize_s1),
        .awburst_s1      (awburst_s1),
        .awlock_s1       (awlock_s1),
        .awcache_s1      (awcache_s1),
        .awprot_s1       (awprot_s1),
        .awvalid_s1      (awvalid_s1),
        .awvalid_vect_s1 (awvalid_vect_s1),
        .awready_s1      (awready_s1),
        .aw_qv_s1        (aw_qv_s1),
        .aruser_s1       (aruser_s1),
        .arid_s1         (arid_s1),
        .araddr_s1       (araddr_s1),
        .arlen_s1        (arlen_s1),
        .arsize_s1       (arsize_s1),
        .arburst_s1      (arburst_s1),
        .arlock_s1       (arlock_s1),
        .arcache_s1      (arcache_s1),
        .arprot_s1       (arprot_s1),
        .arvalid_s1      (arvalid_s1),
        .arvalid_vect_s1 (arvalid_vect_s1),
        .arready_s1      (arready_s1),
        .ar_qv_s1        (ar_qv_s1),

        .wr_cnt_empty   (wr_cnt_empty),
        .aclk           (aclk),
        .aresetn        (aresetn)
);

nic400_bm1_wr_sel_ml0_sse710_integration_example_f0_host_exp u_nic400_bm1_wr_sel_ml0_sse710_integration_example_f0_host_exp (
        .wdata_s0     (wdata_s0),
        .wstrb_s0     (wstrb_s0),
        .wlast_s0     (wlast_s0),
        .wvalid_s0    (wvalid_s0),
        .wready_s0    (wready_s0),

        .wdata_s1     (wdata_s1),
        .wstrb_s1     (wstrb_s1),
        .wlast_s1     (wlast_s1),
        .wvalid_s1    (wvalid_s1),
        .wready_s1    (wready_s1),

        .aw_sel       (aw_sel),
        .awready_m    (awready_m),
        .aclk         (aclk),
        .aresetn      (aresetn),
        .wdata_m      (wdata_m),
        .wstrb_m      (wstrb_m),
        .wlast_m      (wlast_m),
        .wvalid_m     (wvalid_m),
        .wready_m     (wready_m)
);



nic400_bm1_ret_sel_ml0_sse710_integration_example_f0_host_exp u_nic400_bm1_ret_sel_ml0_sse710_integration_example_f0_host_exp (
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
        .bid_s1       (bid_s1),
        .bresp_s1     (bresp_s1),
        .bvalid_s1    (bvalid_s1),
        .bready_s1    (bready_s1),
        .rid_s1       (rid_s1),
        .rdata_s1     (rdata_s1),
        .rresp_s1     (rresp_s1),
        .rlast_s1     (rlast_s1),
        .rvalid_s1    (rvalid_s1),
        .rready_s1    (rready_s1),
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

 wire [1:0] rsel;
 wire [1:0] bsel;
 assign rsel = u_nic400_bm1_ret_sel_ml0_sse710_integration_example_f0_host_exp.rsel;
 assign bsel = u_nic400_bm1_ret_sel_ml0_sse710_integration_example_f0_host_exp.rsel;

      assert_zero_one_hot #(0,2,0,"ERROR, More than one read response destination")
         ovl_rsel_en0
           (
            .clk       (aclk),
            .reset_n   (aresetn),
            .test_expr (rsel)
            );
      assert_zero_one_hot #(0,2,0,"ERROR, More than one buffered response destination")
         ovl_bsel_en0
           (
            .clk       (aclk),
            .reset_n   (aresetn),
            .test_expr (bsel)
            );


    `endif

  endmodule



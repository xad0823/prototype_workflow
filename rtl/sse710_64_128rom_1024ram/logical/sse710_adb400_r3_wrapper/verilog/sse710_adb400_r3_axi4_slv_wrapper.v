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

module sse710_adb400_r3_axi4_slv_wrapper
  #(
   parameter ADDR_WIDTH          = 40,
   parameter DATA_WIDTH          = 128,
   parameter AWID_WIDTH          = 1,
   parameter ARID_WIDTH          = 1,
   parameter AWUSER_WIDTH        = 1,
   parameter WUSER_WIDTH         = 1,
   parameter BUSER_WIDTH         = 1,
   parameter ARUSER_WIDTH        = 1,
   parameter RUSER_WIDTH         = 1,
   parameter AW_FIFO_DEPTH       = 4,
   parameter W_FIFO_DEPTH        = 6,
   parameter B_FIFO_DEPTH        = 2,
   parameter AR_FIFO_DEPTH       = 4,
   parameter R_FIFO_DEPTH        = 6,
   parameter B_OPREG             = 1,
   parameter R_OPREG             = 1,
   parameter SI_SYNC_LEVELS      = 2,
   parameter AW_PAYLOAD_WIDTH    = 236,
   parameter W_PAYLOAD_WIDTH     = 222,
   parameter B_PAYLOAD_WIDTH     = 24,
   parameter AR_PAYLOAD_WIDTH    = 236,
   parameter R_PAYLOAD_WIDTH     = 264
  )
  (

    input  wire                 pwrq_permit_deny_sar_i,

    input  wire                      aclks,
    input  wire                      aresetns,

    input  wire                      pwrqreqns_i,
    output wire                      pwrqacceptns_o,
    output wire                      pwrqdenys_o,

    input  wire                      clkqreqns_i,
    output wire                      clkqacceptns_o,
    output wire                      clkqdenys_o,

    output wire                      clkqactives_o,

    output wire                      pwrqactives_o,

    input  wire                      wakeups_i,

    input  wire                      awvalids,
    output wire                      awreadys,
    input  wire [((AWUSER_WIDTH>0)?(AWUSER_WIDTH-1):0):0] awusers,
    input  wire [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0] awids,
    input  wire [ADDR_WIDTH-1:0]     awaddrs,
    input  wire [3:0]                awregions,
    input  wire [7:0]                awlens,
    input  wire [2:0]                awsizes,
    input  wire [1:0]                awbursts,
    input  wire                      awlocks,
    input  wire [3:0]                awcaches,
    input  wire [2:0]                awprots,
    input  wire [3:0]                awqoss,

    input  wire                      wvalids,
    output wire                      wreadys,
    input  wire [((WUSER_WIDTH>0)?(WUSER_WIDTH-1):0):0] wusers,
    input  wire [DATA_WIDTH-1:0]     wdatas,
    input  wire [(DATA_WIDTH/8)-1:0] wstrbs,
    input  wire                      wlasts,

    output wire                      bvalids,
    input  wire                      breadys,
    output wire [((BUSER_WIDTH>0)?(BUSER_WIDTH-1):0):0] busers,
    output wire [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0] bids,
    output wire [1:0]                bresps,

    input  wire                      arvalids,
    output wire                      arreadys,
    input  wire [((ARUSER_WIDTH>0)?(ARUSER_WIDTH-1):0):0] arusers,
    input  wire [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0] arids,
    input  wire [ADDR_WIDTH-1:0]     araddrs,
    input  wire [3:0]                arregions,
    input  wire [7:0]                arlens,
    input  wire [2:0]                arsizes,
    input  wire [1:0]                arbursts,
    input  wire                      arlocks,
    input  wire [3:0]                arcaches,
    input  wire [2:0]                arprots,
    input  wire [3:0]                arqoss,

    output wire                      rvalids,
    input  wire                      rreadys,
    output wire [((RUSER_WIDTH>0)?(RUSER_WIDTH-1):0):0] rusers,
    output wire [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0] rids,
    output wire [DATA_WIDTH-1:0]     rdatas,
    output wire [1:0]                rresps,
    output wire                      rlasts,




    output wire                   slvmustacceptreqn_async,
    output wire                   slvcandenyreqn_async,
    input  wire                   slvacceptn_async,
    input  wire                   slvdeny_async,

    output wire                   si_to_mi_wakeup_async,
    input  wire                   mi_to_si_wakeup_async,


    output wire [AW_FIFO_DEPTH-1:0] aw_wr_ptr_async,
    input  wire [AW_FIFO_DEPTH-1:0] aw_rd_ptr_async,
    output wire [AW_PAYLOAD_WIDTH-1:0] aw_payld_async,

    output wire [ W_FIFO_DEPTH-1:0]  w_wr_ptr_async,
    input  wire [ W_FIFO_DEPTH-1:0]  w_rd_ptr_async,
    output wire [ W_PAYLOAD_WIDTH-1:0] w_payld_async,

    input  wire [ B_FIFO_DEPTH-1:0]  b_wr_ptr_async,
    output wire [ B_FIFO_DEPTH-1:0]  b_rd_ptr_async,
    input  wire [ B_PAYLOAD_WIDTH-1:0] b_payld_async,

    output wire [AR_FIFO_DEPTH-1:0] ar_wr_ptr_async,
    input  wire [AR_FIFO_DEPTH-1:0] ar_rd_ptr_async,
    output wire [AR_PAYLOAD_WIDTH-1:0] ar_payld_async,

    input  wire [ R_FIFO_DEPTH-1:0]  r_wr_ptr_async,
    output wire [ R_FIFO_DEPTH-1:0]  r_rd_ptr_async,
    input  wire [ R_PAYLOAD_WIDTH-1:0] r_payld_async,


    input  wire                      dftrstdisables
);

  
  wire [((BUSER_WIDTH>0)?(BUSER_WIDTH-1):0):0] busers_int;
  wire [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0]   bids_int;
  wire [1:0]                                   bresps_int;
  
  wire [((RUSER_WIDTH>0)?(RUSER_WIDTH-1):0):0] rusers_int;
  wire [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0]   rids_int;
  wire [DATA_WIDTH-1:0]                        rdatas_int;
  wire [1:0]                                   rresps_int;
  wire                                         rlasts_int;


  adb400_r3_axi4_slv #(
    .ADDR_WIDTH             (ADDR_WIDTH),
    .DATA_WIDTH             (DATA_WIDTH),
    .AWID_WIDTH             (AWID_WIDTH),
    .ARID_WIDTH             (ARID_WIDTH),
    .AWUSER_WIDTH           (AWUSER_WIDTH),
    .WUSER_WIDTH            (WUSER_WIDTH),
    .BUSER_WIDTH            (BUSER_WIDTH),
    .ARUSER_WIDTH           (ARUSER_WIDTH),
    .RUSER_WIDTH            (RUSER_WIDTH),
    .AW_FIFO_DEPTH          (AW_FIFO_DEPTH),
    .W_FIFO_DEPTH           (W_FIFO_DEPTH),
    .B_FIFO_DEPTH           (B_FIFO_DEPTH),
    .AR_FIFO_DEPTH          (AR_FIFO_DEPTH),
    .R_FIFO_DEPTH           (R_FIFO_DEPTH),
    .B_OPREG                (B_OPREG),
    .R_OPREG                (R_OPREG),
    .SI_SYNC_LEVELS         (SI_SYNC_LEVELS)
) u_adb400_r3_axi4_slv (
    .pwrq_permit_deny_sar_i         (pwrq_permit_deny_sar_i),
    .aclks                          (aclks),
    .aresetns                       (aresetns),
    .pwrqreqns_i                    (pwrqreqns_i),
    .pwrqacceptns_o                 (pwrqacceptns_o),
    .pwrqdenys_o                    (pwrqdenys_o),
    .clkqreqns_i                    (clkqreqns_i),
    .clkqacceptns_o                 (clkqacceptns_o),
    .clkqdenys_o                    (clkqdenys_o),
    .clkqactives_o                  (clkqactives_o),
    .pwrqactives_o                  (pwrqactives_o),
    .wakeups_i                      (wakeups_i),
    .awvalids                       (awvalids),
    .awreadys                       (awreadys),
    .awusers                        (awusers),
    .awids                          (awids),
    .awaddrs                        (awaddrs),
    .awregions                      (awregions),
    .awlens                         (awlens),
    .awsizes                        (awsizes),
    .awbursts                       (awbursts),
    .awlocks                        (awlocks),
    .awcaches                       (awcaches),
    .awprots                        (awprots),
    .awqoss                         (awqoss),
    .wvalids                        (wvalids),
    .wreadys                        (wreadys),
    .wusers                         (wusers),
    .wdatas                         (wdatas),
    .wstrbs                         (wstrbs),
    .wlasts                         (wlasts),
    .bvalids                        (bvalids),
    .breadys                        (breadys),
    .busers                         (busers_int),
    .bids                           (bids_int),
    .bresps                         (bresps_int),
    .arvalids                       (arvalids),
    .arreadys                       (arreadys),
    .arusers                        (arusers),
    .arids                          (arids),
    .araddrs                        (araddrs),
    .arregions                      (arregions),
    .arlens                         (arlens),
    .arsizes                        (arsizes),
    .arbursts                       (arbursts),
    .arlocks                        (arlocks),
    .arcaches                       (arcaches),
    .arprots                        (arprots),
    .arqoss                         (arqoss),
    .rvalids                        (rvalids),
    .rreadys                        (rreadys),
    .rusers                         (rusers_int),
    .rids                           (rids_int),
    .rdatas                         (rdatas_int),
    .rresps                         (rresps_int),
    .rlasts                         (rlasts_int),
    .slvmustacceptreqn_async        (slvmustacceptreqn_async),
    .slvcandenyreqn_async           (slvcandenyreqn_async),
    .slvacceptn_async               (slvacceptn_async),
    .slvdeny_async                  (slvdeny_async),
    .si_to_mi_wakeup_async          (si_to_mi_wakeup_async),
    .mi_to_si_wakeup_async          (mi_to_si_wakeup_async),
    .aw_wr_ptr_async                (aw_wr_ptr_async),
    .aw_rd_ptr_async                (aw_rd_ptr_async),
    .aw_payld_async                 (aw_payld_async),
    .w_wr_ptr_async                 (w_wr_ptr_async),
    .w_rd_ptr_async                 (w_rd_ptr_async),
    .w_payld_async                  (w_payld_async),
    .b_wr_ptr_async                 (b_wr_ptr_async),
    .b_rd_ptr_async                 (b_rd_ptr_async),
    .b_payld_async                  (b_payld_async),
    .ar_wr_ptr_async                (ar_wr_ptr_async),
    .ar_rd_ptr_async                (ar_rd_ptr_async),
    .ar_payld_async                 (ar_payld_async),
    .r_wr_ptr_async                 (r_wr_ptr_async),
    .r_rd_ptr_async                 (r_rd_ptr_async),
    .r_payld_async                  (r_payld_async),
    .dftrstdisables                 (dftrstdisables)
  );


  
  arm_element_cdc_comb_and2 #(
    .WIDTH (((BUSER_WIDTH>0)?(BUSER_WIDTH):1))
  ) u_arm_element_cdc_comb_and2_busers (
    .din1_async   (busers_int),
    .din2_async   ({((BUSER_WIDTH>0)?(BUSER_WIDTH):1){bvalids}}),
    .dout_async   (busers)
  );
  
  arm_element_cdc_comb_and2 #(
    .WIDTH (((AWID_WIDTH>0)?(AWID_WIDTH):1))
  ) u_arm_element_cdc_comb_and2_bids (
    .din1_async   (bids_int),
    .din2_async   ({((AWID_WIDTH>0)?(AWID_WIDTH):1){bvalids}}),
    .dout_async   (bids)
  );
  
  arm_element_cdc_comb_and2 #(
    .WIDTH (2)
  ) u_arm_element_cdc_comb_and2_bresp (
    .din1_async   (bresps_int),
    .din2_async   ({2{bvalids}}),
    .dout_async   (bresps)
  );
  
  arm_element_cdc_comb_and2 #(
    .WIDTH (((RUSER_WIDTH>0)?(RUSER_WIDTH):1))
  ) u_arm_element_cdc_comb_and2_rusers (
    .din1_async   (rusers_int),
    .din2_async   ({((RUSER_WIDTH>0)?(RUSER_WIDTH):1){rvalids}}),
    .dout_async   (rusers)
  );

  arm_element_cdc_comb_and2 #(
    .WIDTH (((ARID_WIDTH>0)?(ARID_WIDTH):1))
  ) u_arm_element_cdc_comb_and2_rids (
    .din1_async   (rids_int),
    .din2_async   ({((ARID_WIDTH>0)?(ARID_WIDTH):1){rvalids}}),
    .dout_async   (rids)
  );

  arm_element_cdc_comb_and2 #(
    .WIDTH (DATA_WIDTH)
  ) u_arm_element_cdc_comb_and2_rdatas (
    .din1_async   (rdatas_int),
    .din2_async   ({(DATA_WIDTH){rvalids}}),
    .dout_async   (rdatas)
  );

  arm_element_cdc_comb_and2 #(
    .WIDTH (2)
  ) u_arm_element_cdc_comb_and2_rresps (
    .din1_async   (rresps_int),
    .din2_async   ({2{rvalids}}),
    .dout_async   (rresps)
  );  
  
  arm_element_cdc_comb_and2 #(
    .WIDTH (1)
  ) u_arm_element_cdc_comb_and2_rlasts (
    .din1_async   (rlasts_int),
    .din2_async   (rvalids),
    .dout_async   (rlasts)
  );  
    
endmodule

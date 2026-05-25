//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

// This is the specification for the interface between the BIU and the DPU for
// imprecise aborts.
// Inputs and outputs are from the point of view of the BIU.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_biu_dpu_defs.v"
`include "cortexa53params.v"

module ca53_biu_dpu #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input         dpu_dcache_on_i,
  input   [1:0] dpu_ramode_cnt_l1_i,
  input   [1:0] dpu_ramode_cnt_l2_i,
  input         dpu_disable_device_split_throttle_i,
  input   [2:0] dpu_enable_data_prefetch_i,
  input   [1:0] dpu_enable_data_prefetch_streams_i,
  input         dpu_data_prefetch_stride_detect_i,
  input         dpu_disable_data_prefetch_stores_pattern_i,
  input         dpu_disable_data_prefetch_readunique_i,
  input         dpu_kill_wr_i,
  input         dpu_flush_i,
  input         dpu_ready_wr_i,
  input         dpu_ready_cc_fail_wr_i,
  input [39:12] dpu_pa_dc1_i,
  input  [11:4] dpu_va_dc1_i,
  input         dpu_ns_dsc_dc1_i,
  input         dcu_load_dc1_i,
  input         biu_w_imp_abort_i,
  input   [1:0] biu_w_imp_fault_i,
  input   [1:0] biu_evnt_ext_mem_req_i,
  input   [1:0] biu_evnt_ext_mem_req_nc_i,
  input         biu_evnt_rw_lf_i,
  input         biu_evnt_pf_lf_i,
  input         biu_evnt_ramode_i,
  input         biu_evnt_ramode_enter_i);


  wire         dpu_dcache_on = dpu_dcache_on_i;
  wire   [1:0] dpu_ramode_cnt_l1 = dpu_ramode_cnt_l1_i;
  wire   [1:0] dpu_ramode_cnt_l2 = dpu_ramode_cnt_l2_i;
  wire         dpu_disable_device_split_throttle = dpu_disable_device_split_throttle_i;
  wire   [2:0] dpu_enable_data_prefetch = dpu_enable_data_prefetch_i;
  wire   [1:0] dpu_enable_data_prefetch_streams = dpu_enable_data_prefetch_streams_i;
  wire         dpu_data_prefetch_stride_detect = dpu_data_prefetch_stride_detect_i;
  wire         dpu_disable_data_prefetch_stores_pattern = dpu_disable_data_prefetch_stores_pattern_i;
  wire         dpu_disable_data_prefetch_readunique = dpu_disable_data_prefetch_readunique_i;
  wire         dpu_kill_wr = dpu_kill_wr_i;
  wire         dpu_flush = dpu_flush_i;
  wire         dpu_ready_wr = dpu_ready_wr_i;
  wire         dpu_ready_cc_fail_wr = dpu_ready_cc_fail_wr_i;
  wire [39:12] dpu_pa_dc1 = dpu_pa_dc1_i;
  wire  [11:4] dpu_va_dc1 = dpu_va_dc1_i;
  wire         dpu_ns_dsc_dc1 = dpu_ns_dsc_dc1_i;
  wire         dcu_load_dc1 = dcu_load_dc1_i;
  wire         biu_w_imp_abort = biu_w_imp_abort_i;
  wire   [1:0] biu_w_imp_fault = biu_w_imp_fault_i;
  wire   [1:0] biu_evnt_ext_mem_req = biu_evnt_ext_mem_req_i;
  wire   [1:0] biu_evnt_ext_mem_req_nc = biu_evnt_ext_mem_req_nc_i;
  wire         biu_evnt_rw_lf = biu_evnt_rw_lf_i;
  wire         biu_evnt_pf_lf = biu_evnt_pf_lf_i;
  wire         biu_evnt_ramode = biu_evnt_ramode_i;
  wire         biu_evnt_ramode_enter = biu_evnt_ramode_enter_i;





  // Indicates an imprecise abort from the AXI master when asserted.
  //  output biu_w_imp_abort valid always timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "biu_w_imp_abort X or Z")
  u_ovl_intf_x_biu_w_imp_abort (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_w_imp_abort));


  // Indicates if the imprecise abort on the AXI master was caused by
  // a slave error (SLVERR), a decode error (DECERR), or a ECC error (ECCERR).
  // Note that an ECCERR or DECERR overwrites the SLVERR.
  // Encoding:
  //   2'b00 SLVERR
  //   2'b10 ECCERR 
  //   2'b01 DECERR 
  //   2'b11 ECCERR & DECERR
  //  output [1:0] biu_w_imp_fault valid biu_w_imp_abort timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "biu_w_imp_fault X or Z")
  u_ovl_intf_x_biu_w_imp_fault (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (biu_w_imp_abort),
    .test_expr (biu_w_imp_fault));


  // Event signal for external memory request.
  // bit [1] - read request
  // bit [0] - write request
  //  output [1:0] biu_evnt_ext_mem_req valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "biu_evnt_ext_mem_req X or Z")
  u_ovl_intf_x_biu_evnt_ext_mem_req (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_evnt_ext_mem_req));


  // Event signal for external memory request to non-cacheable memory.
  // bit [1] - non-cacheable read request
  // bit [0] - non-cacheable write request
  //
  // For dside reads, non-cacheable implies:
  // - inner WT, NC, SO, Dev
  // - inner WB when the cache is off
  //
  // For iside reads, non-cacheable implies:
  // - inner NC, SO, Dev
  // - inner WB/WT when the cache is off
  // - inner WB/WT during cache maintenance operations
  //
  // For writes, non-cacheable implies:
  // - inner WT, NC, SO, Dev
  // - inner WB when the cache is off (except for evictions)
  //  output [1:0] biu_evnt_ext_mem_req_nc valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "biu_evnt_ext_mem_req_nc X or Z")
  u_ovl_intf_x_biu_evnt_ext_mem_req_nc (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_evnt_ext_mem_req_nc));


  // Event signal for a linefill started due to a read or a write.
  //  output biu_evnt_rw_lf valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "biu_evnt_rw_lf X or Z")
  u_ovl_intf_x_biu_evnt_rw_lf (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_evnt_rw_lf));


  // Event signal for a linefill started due to a data prefetch.
  //  output biu_evnt_pf_lf valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "biu_evnt_pf_lf X or Z")
  u_ovl_intf_x_biu_evnt_pf_lf (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_evnt_pf_lf));


  // Event signal for each cycle the BIU is in read allocate mode.
  //  output biu_evnt_ramode valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "biu_evnt_ramode X or Z")
  u_ovl_intf_x_biu_evnt_ramode (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_evnt_ramode));


  // Event signal for the BIU entering read allocate mode.
  //  output biu_evnt_ramode_enter valid always timing 65%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "biu_evnt_ramode_enter X or Z")
  u_ovl_intf_x_biu_evnt_ramode_enter (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (biu_evnt_ramode_enter));


  // Data cache enabled.
  //  input dpu_dcache_on valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dpu_dcache_on X or Z")
  u_ovl_intf_x_dpu_dcache_on (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_dcache_on));


  // Write streaming no-L1-allocate threshold Write streaming no-L1-allocate threshold. The possible values are:
  // 2'b00 4th consecutive streaming cache line does not allocate in the L1 cache.
  // 2'b01 64th consecutive streaming cache line does not allocate in the L1 cache.
  // 2'b10 128th consecutive streaming cache line does not allocate in the L1 cache.
  // 2'b11 Disables streaming. All write-allocate lines allocate in the L1 cache.
  //  input [1:0] dpu_ramode_cnt_l1 valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "dpu_ramode_cnt_l1 X or Z")
  u_ovl_intf_x_dpu_ramode_cnt_l1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_ramode_cnt_l1));


  // Write streaming no-allocate threshold Write streaming no-allocate threshold. The possible values are:
  // 2'b00 16th consecutive streaming cache line does not allocate in the L1 or L2 cache.
  // 2'b01 128th consecutive streaming cache line does not allocate in the L1 or L2 cache.
  // 2'b10 512th consecutive streaming cache line does not allocate in the L1 or L2 cache.
  // 2'b11 Disables streaming. All write-allocate lines allocate in the L1 or L2 cache.
  //  input [1:0] dpu_ramode_cnt_l2 valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "dpu_ramode_cnt_l2 X or Z")
  u_ovl_intf_x_dpu_ramode_cnt_l2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_ramode_cnt_l2));


  // Disable the throttle of the outstanding device load accesses that can be generated by the BIU device split logic:
  // o 1'b0: one outstanding device split transaction allowed
  // o 1'b1: multiple device split outstanding transactions based on the availability of the BIU read buffers
  //  input dpu_disable_device_split_throttle valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dpu_disable_device_split_throttle X or Z")
  u_ovl_intf_x_dpu_disable_device_split_throttle (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_disable_device_split_throttle));


  // Enable number of outstanding data prefetches, including disabling the data prefetches completely.
  // 3'b000: disable the data prefetches
  // 3'b001..3'b110: max 1..6 data prefetches outstanding
  // 3'b111: max 8 data prefetches outstanding
  //  input [2:0] dpu_enable_data_prefetch valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 3, INOPTIONS, "dpu_enable_data_prefetch X or Z")
  u_ovl_intf_x_dpu_enable_data_prefetch (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_enable_data_prefetch));


  // Enable number of independent data prefetch streams (ie from 1 to 4 independent streams)
  //  input [1:0] dpu_enable_data_prefetch_streams valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "dpu_enable_data_prefetch_streams X or Z")
  u_ovl_intf_x_dpu_enable_data_prefetch_streams (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_enable_data_prefetch_streams));


  // Configure the number of consecutives strides detected before starting a data prefetch stream:
  // o 1'b0: 2 consecutive strides
  // o 1'b1: 3 consecutive strides
  //  input dpu_data_prefetch_stride_detect valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dpu_data_prefetch_stride_detect X or Z")
  u_ovl_intf_x_dpu_data_prefetch_stride_detect (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_data_prefetch_stride_detect));


  // Disable the prefetch streams initiated from the STB accesses
  // o 1'b0: enable the prefetch streams initiated from the STB accesses
  // o 1'b1: disable the prefetch streams initiated from the STB accesses
  //  input dpu_disable_data_prefetch_stores_pattern valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dpu_disable_data_prefetch_stores_pattern X or Z")
  u_ovl_intf_x_dpu_disable_data_prefetch_stores_pattern (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_disable_data_prefetch_stores_pattern));


  // Disable the read unique request for the prefetch linefill streams initiated by the STB accesses
  // o 1'b0: Read unique used for the prefetch streams initiated from the STB accesses
  // o 1'b1: Read shared used for the prefetch streams initiated from the STB accesses
  //  input dpu_disable_data_prefetch_readunique valid always timing 20%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dpu_disable_data_prefetch_readunique X or Z")
  u_ovl_intf_x_dpu_disable_data_prefetch_readunique (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_disable_data_prefetch_readunique));


  // Kill or flush the request in the Wr stage.  Caused by a general
  // flush (asserted with dpu_flush).
  //  input dpu_kill_wr valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dpu_kill_wr X or Z")
  u_ovl_intf_x_dpu_kill_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_kill_wr));


  // Flush all outstanding memory requests except for the one in Wr.
  //  input dpu_flush valid always timing 50%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dpu_flush X or Z")
  u_ovl_intf_x_dpu_flush (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_flush));


  // The LS instruction is in the Wr stage of the DPU and the DPU is
  // ready to retire the transaction.
  //  input dpu_ready_wr valid always timing 17%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dpu_ready_wr X or Z")
  u_ovl_intf_x_dpu_ready_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_ready_wr));


  // Timing optimized signal that combines dpu_ready_wr and dpu_cc_fail_wr:
  // The LS instruction is in the Wr stage of the DPU and the DPU is
  // ready to retire the transaction, which has also CC failed.
  //  input dpu_ready_cc_fail_wr valid always timing 17%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dpu_ready_cc_fail_wr X or Z")
  u_ovl_intf_x_dpu_ready_cc_fail_wr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (dpu_ready_cc_fail_wr));


  // Can't have a dpu_kill_wr without a dpu_flush

  assert_implication #(`OVL_FATAL, INOPTIONS, "dpu_kill_wr  => dpu_flush")
  u_ovl_intf_assume_e39ed8a2d4b36c61f8ede86260c0fe163012702d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (dpu_kill_wr ),
    .consequent_expr (dpu_flush));



  // Address information in DC1
  //  input [39:12] dpu_pa_dc1     valid dcu_load_dc1 timing 30%

  assert_never_unknown #(`OVL_FATAL, 28, INOPTIONS, "dpu_pa_dc1 X or Z")
  u_ovl_intf_x_dpu_pa_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_load_dc1),
    .test_expr (dpu_pa_dc1));

  //  input [11:4]  dpu_va_dc1     valid dcu_load_dc1 timing 20%

  assert_never_unknown #(`OVL_FATAL, 8, INOPTIONS, "dpu_va_dc1 X or Z")
  u_ovl_intf_x_dpu_va_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_load_dc1),
    .test_expr (dpu_va_dc1));

  //  input         dpu_ns_dsc_dc1 valid dcu_load_dc1 timing 40%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "dpu_ns_dsc_dc1 X or Z")
  u_ovl_intf_x_dpu_ns_dsc_dc1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (dcu_load_dc1),
    .test_expr (dpu_ns_dsc_dc1));



endmodule

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_biu_dpu_defs.v"
`undef CA53_UNDEFINE

`endif


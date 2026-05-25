//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2014 ARM Limited.
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
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract: Control for inserting NEON & FPU special instructions
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_special `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire                             clk,
  input  wire                             clk_fp_ctl,
  input  wire                             reset_n,
  input  wire                             issue_to_iss_i,
  input  wire                             issue_to_iss_fpu_i,
  input  wire                       [1:0] fp_div_busy_nxt_cyc_i,
  input  wire                       [1:0] valid_instrs_iss_i,
  input  wire                       [1:0] valid_instrs_ex1_i,
  input  wire                       [1:0] valid_instrs_ex2_i,
  input  wire                       [1:0] valid_instrs_wr_i,
  input  wire                       [1:0] pre_valid_instrs_wr_i,
  input  wire                             slot1_fp_ex2_i,
  input  wire                             cc_pass_instr0_ex2_i,
  input  wire                             cc_pass_instr1_ex2_i,
  input  wire                             no_insert_iss_i,
  input  wire                             flush_ret_i,
  input  wire                             flush_wr_i,
  input  wire                             quash_wr_special_i,
  input  wire                             slot0_br_flush_wr_i,
  input  wire                             stall_wr_i,
  input  wire                             stall_slot0_iss_i,
  input  wire                             ilock_stall_div_iss_i,
  input  wire                             lsm_skidding_i,
  input  wire                       [1:0] fdivs_valid_iss_i,
  input  wire                       [1:0] fdivs_valid_f1_i,
  input  wire                       [1:0] fdivs_valid_f2_i,
  input  wire                       [1:0] fdivs_valid_f3_i,
  input  wire [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr0_de_i,
  input  wire [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr1_de_i,
  input  wire [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr2_de_i,
  input  wire [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr3_de_i,
  input  wire [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr4_de_i,
  input  wire [`CA53_FP_RF_RD_ADDR_W-1:0] rf_rd_addr_fr5_de_i,
  input  wire                       [1:0] rf_rd_en_fr0_de_i,
  input  wire                       [1:0] rf_rd_en_fr1_de_i,
  input  wire                       [1:0] rf_rd_en_fr2_de_i,
  input  wire                       [1:0] rf_rd_en_fr3_de_i,
  input  wire                       [1:0] rf_rd_en_fr4_de_i,
  input  wire                       [1:0] rf_rd_en_fr5_de_i,
  input  wire [`CA53_FP_RF_WR_ADDR_W-1:0] pre_rf_wr_addr_fw0_iss_i,
  input  wire [`CA53_FP_RF_WR_ADDR_W-1:0] raw_rf_wr_addr_fw1_iss_i,
  input  wire                       [3:0] raw_rf_wr_en_fw0_iss_i,
  input  wire                       [3:0] raw_rf_wr_en_fw1_iss_i,
  input  wire                       [1:0] fmac_valid_sp_iss_i,
  input  wire    [`CA53_FP_EX_PIPE_W-1:0] raw_fp_ex_pipe_iss_i,
  input  wire    [`CA53_FP_PIPECTL_W-1:0] fp0_pipectl_iss_i,
  input  wire    [`CA53_FP_PIPECTL_W-1:0] fp1_pipectl_iss_i,
  input  wire                             fp_serialize_iss_i,
  input  wire                             wfx_serialize_iss_i,
  input  wire     [`CA53_SEL_FAD_A_W-1:0] sel_fad0_a_iss_i,
  input  wire     [`CA53_SEL_FAD_A_W-1:0] sel_fad1_a_iss_i,
  // Outputs
  output wire                       [1:0] unflushable_sfmac_iss_o,
  output wire                             unflushable_sfdiv_iss_o,
  output wire                             special_stall_iss_o,
  output wire                       [1:0] special_insert_iss_o,
  output wire                             special_interlock_iss_o,
  output reg      [`CA53_SEL_FAD_A_W-1:0] special_sel_fad0_a_iss_o,
  output reg      [`CA53_SEL_FAD_B_W-1:0] special_sel_fad0_b_iss_o,
  output reg      [`CA53_SEL_FAD_A_W-1:0] special_sel_fad1_a_iss_o,
  output reg      [`CA53_SEL_FAD_B_W-1:0] special_sel_fad1_b_iss_o,
  output reg                        [1:0] special_rf_rd_en_fr2_iss_o,
  output reg                        [1:0] special_rf_rd_en_fr5_iss_o,
  output reg  [`CA53_FP_RF_RD_ADDR_W-1:0] special_rf_rd_addr_fr2_iss_o,
  output reg  [`CA53_FP_RF_RD_ADDR_W-1:0] special_rf_rd_addr_fr5_iss_o,
  output reg                        [3:0] special_rf_wr_en_fw0_iss_o,
  output reg                        [3:0] special_rf_wr_en_fw1_iss_o,
  output reg  [`CA53_FP_RF_WR_ADDR_W-1:0] special_rf_wr_addr_fw0_iss_o,
  output reg  [`CA53_FP_RF_WR_ADDR_W-1:0] special_rf_wr_addr_fw1_iss_o,
  output reg     [`CA53_RF_FWR_SRC_W-1:0] special_rf_wr_src_fw0_iss_o,
  output reg     [`CA53_RF_FWR_SRC_W-1:0] special_rf_wr_src_fw1_iss_o,
  output reg     [`CA53_FP_ADD_CTL_W-1:0] special_fp_add0_ctl_iss_o,
  output reg     [`CA53_FP_ADD_CTL_W-1:0] special_fp_add1_ctl_iss_o,
  output wire                             fmac_valid_f3_o,
  output wire                             fp_special_in_flight_o,
  output wire                       [1:0] fp_div_active_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg                               vdiv0_committed;
  reg                               vdiv1_committed;
  reg                         [2:0] vdiv0_rf_wr_en_fw0_f1;
  reg                         [2:0] vdiv1_rf_wr_en_fw1_f1;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] vdiv0_rf_wr_addr_fw0_f1;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] vdiv1_rf_wr_addr_fw1_f1;
  reg                               fmac0_valid_f1;
  reg                               fmac0_valid_f2;
  reg                               fmac0_valid_f3;
  reg                               fmac0_valid_f4;
  reg                               fmac1_valid_f1;
  reg                               fmac1_valid_f2;
  reg                               fmac1_valid_f3;
  reg                               fmac1_valid_f4;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] fmac0_wr_addr_fw0_f1;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] fmac0_wr_addr_fw0_f2;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] fmac0_wr_addr_fw0_f3;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] fmac0_wr_addr_fw0_f4;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] fmac1_wr_addr_fw1_f1;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] fmac1_wr_addr_fw1_f2;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] fmac1_wr_addr_fw1_f3;
  reg   [`CA53_FP_RF_WR_ADDR_W-1:0] fmac1_wr_addr_fw1_f4;
  reg                         [2:0] fmac0_wr_en_fw0_f1;
  reg                         [2:0] fmac0_wr_en_fw0_f2;
  reg                         [2:0] fmac0_wr_en_fw0_f3;
  reg                         [2:0] fmac0_wr_en_fw0_f4;
  reg                         [2:0] fmac1_wr_en_fw1_f1;
  reg                         [2:0] fmac1_wr_en_fw1_f2;
  reg                         [2:0] fmac1_wr_en_fw1_f3;
  reg                         [2:0] fmac1_wr_en_fw1_f4;
  reg   [`CA53_FP_RF_RD_ADDR_W-1:0] fmac0_rd_addr_fr2_f1;
  reg   [`CA53_FP_RF_RD_ADDR_W-1:0] fmac0_rd_addr_fr2_f2;
  reg   [`CA53_FP_RF_RD_ADDR_W-1:0] fmac0_rd_addr_fr2_f3;
  reg   [`CA53_FP_RF_RD_ADDR_W-1:0] fmac0_rd_addr_fr2_f4;
  reg   [`CA53_FP_RF_RD_ADDR_W-1:0] fmac1_rd_addr_fr5_f1;
  reg   [`CA53_FP_RF_RD_ADDR_W-1:0] fmac1_rd_addr_fr5_f2;
  reg   [`CA53_FP_RF_RD_ADDR_W-1:0] fmac1_rd_addr_fr5_f3;
  reg   [`CA53_FP_RF_RD_ADDR_W-1:0] fmac1_rd_addr_fr5_f4;
  reg                               fmac0_sign_f1;
  reg                               fmac0_sign_f2;
  reg                               fmac0_sign_f3;
  reg                               fmac0_sign_f4;
  reg                               fmac1_sign_f1;
  reg                               fmac1_sign_f2;
  reg                               fmac1_sign_f3;
  reg                               fmac1_sign_f4;
  reg                               fmac0_dp_f1;
  reg                               fmac0_dp_f2;
  reg                               fmac0_dp_f3;
  reg                               fmac0_dp_f4;
  reg                               fmac1_dp_f1;
  reg                               fmac1_dp_f2;
  reg                               fmac1_dp_f3;
  reg                               fmac1_dp_f4;
  reg       [`CA53_SEL_FAD_A_W-1:0] fmac0_sel_fad0_a_f1;
  reg       [`CA53_SEL_FAD_A_W-1:0] fmac0_sel_fad0_a_f2;
  reg       [`CA53_SEL_FAD_A_W-1:0] fmac0_sel_fad0_a_f3;
  reg       [`CA53_SEL_FAD_A_W-1:0] fmac0_sel_fad0_a_f4;
  reg       [`CA53_SEL_FAD_A_W-1:0] fmac1_sel_fad1_a_f1;
  reg       [`CA53_SEL_FAD_A_W-1:0] fmac1_sel_fad1_a_f2;
  reg       [`CA53_SEL_FAD_A_W-1:0] fmac1_sel_fad1_a_f3;
  reg       [`CA53_SEL_FAD_A_W-1:0] fmac1_sel_fad1_a_f4;
  reg                         [1:0] fp_div_busy;
  reg   [`CA53_FP_RF_RD_ADDR_W-1:0] raw_rf_rd_addr_fr0_iss;
  reg   [`CA53_FP_RF_RD_ADDR_W-1:0] raw_rf_rd_addr_fr1_iss;
  reg   [`CA53_FP_RF_RD_ADDR_W-1:0] raw_rf_rd_addr_fr2_iss;
  reg   [`CA53_FP_RF_RD_ADDR_W-1:0] raw_rf_rd_addr_fr3_iss;
  reg   [`CA53_FP_RF_RD_ADDR_W-1:0] raw_rf_rd_addr_fr4_iss;
  reg   [`CA53_FP_RF_RD_ADDR_W-1:0] raw_rf_rd_addr_fr5_iss;
  reg                         [1:0] raw_rf_rd_en_fr0_iss;
  reg                         [1:0] raw_rf_rd_en_fr1_iss;
  reg                         [1:0] raw_rf_rd_en_fr2_iss;
  reg                         [1:0] raw_rf_rd_en_fr3_iss;
  reg                         [1:0] raw_rf_rd_en_fr4_iss;
  reg                         [1:0] raw_rf_rd_en_fr5_iss;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire     [`CA53_FP_MUL_CTL_W-1:0] fp_mul0_ctl_iss;
  wire     [`CA53_FP_MUL_CTL_W-1:0] fp_mul1_ctl_iss;
  wire     [`CA53_FP_ADD_CTL_W-1:0] fp_add0_ctl_iss;
  wire     [`CA53_FP_ADD_CTL_W-1:0] fp_add1_ctl_iss;
  wire                              en_vdiv0_committed;
  wire                              nxt_vdiv0_committed;
  wire                              en_vdiv1_committed;
  wire                              nxt_vdiv1_committed;
  wire                              vdiv0_stall_iss;
  wire                              vdiv1_stall_iss;
  wire                              vdiv0_valid_masked_iss;
  wire                              vdiv1_valid_masked_iss;
  wire                              vdiv0_struct_hazard;
  wire                              vdiv1_struct_hazard;
  wire                              vdiv0_write_hazard;
  wire                              vdiv1_write_hazard;
  wire  [`CA53_FP_RF_WR_ADDR_W-1:0] vdiv0_rf_wr_addr_fw0_iss;
  wire  [`CA53_FP_RF_WR_ADDR_W-1:0] vdiv1_rf_wr_addr_fw1_iss;
  wire                        [2:0] vdiv0_rf_wr_en_fw0_iss;
  wire                        [2:0] vdiv1_rf_wr_en_fw1_iss;
  wire                              vdiv0_f1_read_hazard;
  wire                              vdiv1_f1_read_hazard;
  wire                              vdiv0_read_hazard;
  wire                              vdiv1_read_hazard;
  wire                              fdivs_interlock_iss;
  wire                        [1:0] fp_div_busy_qual;
  wire                              nxt_fmac0_sign_f1;
  wire                              nxt_fmac1_sign_f1;
  wire                              nxt_fmac0_dp_f1;
  wire                              nxt_fmac1_dp_f1;
  wire                        [2:0] nxt_fmac0_wr_en_fw0_f1;
  wire                        [2:0] nxt_fmac1_wr_en_fw1_f1;
  wire  [`CA53_FP_RF_WR_ADDR_W-1:0] nxt_fmac0_wr_addr_fw0_f1;
  wire  [`CA53_FP_RF_WR_ADDR_W-1:0] nxt_fmac1_wr_addr_fw1_f1;
  wire                              fmac0_insert_iss;
  wire                              fmac1_insert_iss;
  wire                              fmac_interlock_iss;
  wire                              fmac0_valid_iss;
  wire                              fmac1_valid_iss;
  wire                              fmac0_f1_read_hazard;
  wire                              fmac0_f2_read_hazard;
  wire                              fmac0_f3_read_hazard;
  wire                              fmac0_f4_read_hazard;
  wire                              fmac1_f1_read_hazard;
  wire                              fmac1_f2_read_hazard;
  wire                              fmac1_f3_read_hazard;
  wire                              fmac1_f4_read_hazard;
  wire                              fmac_read_hazard;
  wire                              fmac_write_hazard;
  wire                              fmac0_struct_hazard;
  wire                              fmac1_struct_hazard;
  wire                              fmac0_valid_en;
  wire                              fmac1_valid_en;
  wire                              fmac1_cc_pass_ex2;
  wire                              nxt_fmac0_valid_f1;
  wire                              nxt_fmac0_valid_f2;
  wire                              nxt_fmac0_valid_f3;
  wire                              nxt_fmac0_valid_f4;
  wire                              nxt_fmac1_valid_f1;
  wire                              nxt_fmac1_valid_f2;
  wire                              nxt_fmac1_valid_f3;
  wire                              nxt_fmac1_valid_f4;
  wire                              fmac_in_flight;
  wire                              fdivs_in_flight;
  wire                              fp_special_in_flight;
  wire                              fpscr_interlock_iss;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Address/Enable storage
  // ------------------------------------------------------
  //
  // Register the read address and read enables in to Issue for special interlocking
  always @(posedge clk_fp_ctl)
    if (issue_to_iss_fpu_i) begin
      raw_rf_rd_addr_fr0_iss <= rf_rd_addr_fr0_de_i[(`CA53_FP_RF_RD_ADDR_W-1):0];
      raw_rf_rd_addr_fr1_iss <= rf_rd_addr_fr1_de_i[(`CA53_FP_RF_RD_ADDR_W-1):0];
      raw_rf_rd_addr_fr2_iss <= rf_rd_addr_fr2_de_i[(`CA53_FP_RF_RD_ADDR_W-1):0];
      raw_rf_rd_addr_fr3_iss <= rf_rd_addr_fr3_de_i[(`CA53_FP_RF_RD_ADDR_W-1):0];
      raw_rf_rd_addr_fr4_iss <= rf_rd_addr_fr4_de_i[(`CA53_FP_RF_RD_ADDR_W-1):0];
      raw_rf_rd_addr_fr5_iss <= rf_rd_addr_fr5_de_i[(`CA53_FP_RF_RD_ADDR_W-1):0];
    end  

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      raw_rf_rd_en_fr0_iss <= 2'b00;
      raw_rf_rd_en_fr1_iss <= 2'b00;
      raw_rf_rd_en_fr2_iss <= 2'b00;
      raw_rf_rd_en_fr3_iss <= 2'b00;
      raw_rf_rd_en_fr4_iss <= 2'b00;
      raw_rf_rd_en_fr5_iss <= 2'b00;
    end else if (issue_to_iss_i) begin
      raw_rf_rd_en_fr0_iss <= rf_rd_en_fr0_de_i;
      raw_rf_rd_en_fr1_iss <= rf_rd_en_fr1_de_i;
      raw_rf_rd_en_fr2_iss <= rf_rd_en_fr2_de_i;
      raw_rf_rd_en_fr3_iss <= rf_rd_en_fr3_de_i;
      raw_rf_rd_en_fr4_iss <= rf_rd_en_fr4_de_i;
      raw_rf_rd_en_fr5_iss <= rf_rd_en_fr5_de_i;
    end

  // ------------------------------------------------------
  // Hazard check functions
  // ------------------------------------------------------
  //
  // The approach used to check read hazards is common to the FDIV/FSQRT and
  // double precision Mul instructions.

  function automatic check_read_hazard;
    input [`CA53_FP_RF_RD_ADDR_W-1:0] rd_addr;
    input                       [1:0] rd_en;
    input [`CA53_FP_RF_WR_ADDR_W-1:0] wr_addr;
    input                       [2:0] wr_en;

    check_read_hazard = (rd_addr[`CA53_FP_RF_RD_ADDR_W-1:1] == wr_addr[`CA53_FP_RF_WR_ADDR_W-1:1]) &
                        ((rd_addr[0] == wr_addr[0]) | wr_en[2]) &
                        (|(rd_en & (wr_en[1:0] | {2{wr_en[2]}})));
  endfunction

  // ===========================================================================
  // == Divide/Square Root Control                                            ==
  // ===========================================================================

  // ------------------------------------------------------
  // FPU Divider committed flag
  // ------------------------------------------------------
  //
  // The commited flag is asserted once the divide phantom reaches Ret.
  //
  // We assert the nxt_div_committed signal when the phantom is in Wr, has
  // passed its condition codes and the stall signal is not asserted so we
  // can move into the Ret stage.
  //
  // The committed flag is cleared when the special is inserted but not until
  // any flush has cleared.

  assign en_vdiv0_committed = ((vdiv0_stall_iss |
                                (fdivs_valid_f3_i[0] & pre_valid_instrs_wr_i[0])) &
                               ~(stall_wr_i & ~flush_ret_i));

  assign nxt_vdiv0_committed = (fdivs_valid_f3_i[0] &
                                ~quash_wr_special_i &
                                ~vdiv0_stall_iss);

  always @(posedge clk_fp_ctl or negedge reset_n)
    if (~reset_n)
      vdiv0_committed <= 1'b0;
    else if (en_vdiv0_committed)
      vdiv0_committed <= nxt_vdiv0_committed;

  assign en_vdiv1_committed = ((vdiv1_stall_iss |
                                (fdivs_valid_f3_i[1] & pre_valid_instrs_wr_i[0])) &
                               ~(stall_wr_i & ~flush_ret_i));

  assign nxt_vdiv1_committed = (fdivs_valid_f3_i[1] &
                                ~quash_wr_special_i &
                                ~vdiv1_stall_iss);

  always @(posedge clk_fp_ctl or negedge reset_n)
    if (~reset_n)
      vdiv1_committed <= 1'b0;
    else if (en_vdiv1_committed)
      vdiv1_committed <= nxt_vdiv1_committed;

  always @(posedge clk_fp_ctl or negedge reset_n)
    if(~reset_n)
      fp_div_busy <= 2'b00;
    else
      fp_div_busy <= fp_div_busy_nxt_cyc_i;

  assign fp_div_busy_qual = fp_div_busy & {vdiv1_committed, vdiv0_committed};

  // ------------------------------------------------------
  // FPU Divider special stall
  // ------------------------------------------------------
  //
  // To insert the sVDIV we need to stall the issue stage with the vdiv_stall_iss signal.
  // However we can not stall if a higher priority FMACs special is inserted.
  //
  // Also, the no_insert_iss signal must be over-ridden in the case that the instruction in
  // Iss that is signalling no_insert is also interlocking due to read or write hazard
  // against the VDIV instruction that is already in the pipeline.  
  assign vdiv0_stall_iss = ~(|fp_div_busy_qual) & vdiv0_committed & ~fmac0_insert_iss & ~fmac1_insert_iss;
  assign vdiv1_stall_iss = ~(|fp_div_busy_qual) & vdiv1_committed & ~fmac0_insert_iss & ~fmac1_insert_iss;

  // ------------------------------------------------------
  // DIV/SQRT Hazard Checking
  // ------------------------------------------------------
  // There are three types of hazard that we need to check against
  // 1. A structural hazard where a DIV/SQRT is in Iss when one is already
  //    underway.
  // 2. A read hazard where the result of an outstanding DIV/SQRT is needed.
  // 3. A write hazard where the outstanding DIV/SQRT needs to be written
  //    before the instruction in Iss can proceed.

  // Register the DIV/SQRT Write Address
  // The write address needs to be registered when we have a valid div/sqrt
  // instruction in Iss.  However, we must be careful to not overwrite a
  // previously registered address for an outstanding div/sqrt.
  assign vdiv0_valid_masked_iss = (fdivs_valid_iss_i[0] &
                                   ~fdivs_valid_f1_i[0] &
                                   ~fdivs_valid_f2_i[0] &
                                   ~fdivs_valid_f3_i[0] &
                                   ~vdiv0_committed &
                                   ~stall_slot0_iss_i);

  always @(posedge clk)
    if (vdiv0_valid_masked_iss) begin
      vdiv0_rf_wr_en_fw0_f1   <= vdiv0_rf_wr_en_fw0_iss;
      vdiv0_rf_wr_addr_fw0_f1 <= vdiv0_rf_wr_addr_fw0_iss;
    end

  assign vdiv1_valid_masked_iss = (fdivs_valid_iss_i[1] &
                                   ~fdivs_valid_f1_i[1] &
                                   ~fdivs_valid_f2_i[1] &
                                   ~fdivs_valid_f3_i[1] &
                                   ~vdiv1_committed &
                                   ~stall_slot0_iss_i);

  always @(posedge clk)
    if (vdiv1_valid_masked_iss) begin
      vdiv1_rf_wr_en_fw1_f1   <= vdiv1_rf_wr_en_fw1_iss;
      vdiv1_rf_wr_addr_fw1_f1 <= vdiv1_rf_wr_addr_fw1_iss;
    end

  // Structural Hazard
  assign vdiv0_struct_hazard = fdivs_valid_iss_i[0] & (fdivs_valid_f1_i[0] |
                                                       fdivs_valid_f2_i[0] |
                                                       fdivs_valid_f3_i[0] |
                                                       vdiv0_committed);

  assign vdiv1_struct_hazard = fdivs_valid_iss_i[1] & (fdivs_valid_f1_i[1] |
                                                       fdivs_valid_f2_i[1] |
                                                       fdivs_valid_f3_i[1] |
                                                       vdiv1_committed);

  // VDIV Read Hazard Check
  //
  // Check incoming read addresses against the stored write address of an ongoing VDIV
  //
  // To improve timing portions of the checking are moved back in to the De stage
  assign vdiv0_rf_wr_addr_fw0_iss = pre_rf_wr_addr_fw0_iss_i;
  assign vdiv0_rf_wr_en_fw0_iss   = {raw_rf_wr_en_fw0_iss_i[3], raw_rf_wr_en_fw0_iss_i[1:0]};

  assign vdiv1_rf_wr_addr_fw1_iss = raw_rf_wr_addr_fw1_iss_i;
  assign vdiv1_rf_wr_en_fw1_iss   = {raw_rf_wr_en_fw1_iss_i[3], raw_rf_wr_en_fw1_iss_i[1:0]};

  assign vdiv0_f1_read_hazard = {check_read_hazard(raw_rf_rd_addr_fr5_iss, raw_rf_rd_en_fr5_iss, vdiv0_rf_wr_addr_fw0_f1, vdiv0_rf_wr_en_fw0_f1) |
                                 check_read_hazard(raw_rf_rd_addr_fr4_iss, raw_rf_rd_en_fr4_iss, vdiv0_rf_wr_addr_fw0_f1, vdiv0_rf_wr_en_fw0_f1) |
                                 check_read_hazard(raw_rf_rd_addr_fr3_iss, raw_rf_rd_en_fr3_iss, vdiv0_rf_wr_addr_fw0_f1, vdiv0_rf_wr_en_fw0_f1) |
                                 check_read_hazard(raw_rf_rd_addr_fr2_iss, raw_rf_rd_en_fr2_iss, vdiv0_rf_wr_addr_fw0_f1, vdiv0_rf_wr_en_fw0_f1) |
                                 check_read_hazard(raw_rf_rd_addr_fr1_iss, raw_rf_rd_en_fr1_iss, vdiv0_rf_wr_addr_fw0_f1, vdiv0_rf_wr_en_fw0_f1) |
                                 check_read_hazard(raw_rf_rd_addr_fr0_iss, raw_rf_rd_en_fr0_iss, vdiv0_rf_wr_addr_fw0_f1, vdiv0_rf_wr_en_fw0_f1)};

  assign vdiv1_f1_read_hazard = {check_read_hazard(raw_rf_rd_addr_fr5_iss, raw_rf_rd_en_fr5_iss, vdiv1_rf_wr_addr_fw1_f1, vdiv1_rf_wr_en_fw1_f1) |
                                 check_read_hazard(raw_rf_rd_addr_fr4_iss, raw_rf_rd_en_fr4_iss, vdiv1_rf_wr_addr_fw1_f1, vdiv1_rf_wr_en_fw1_f1) |
                                 check_read_hazard(raw_rf_rd_addr_fr3_iss, raw_rf_rd_en_fr3_iss, vdiv1_rf_wr_addr_fw1_f1, vdiv1_rf_wr_en_fw1_f1) |
                                 check_read_hazard(raw_rf_rd_addr_fr2_iss, raw_rf_rd_en_fr2_iss, vdiv1_rf_wr_addr_fw1_f1, vdiv1_rf_wr_en_fw1_f1) |
                                 check_read_hazard(raw_rf_rd_addr_fr1_iss, raw_rf_rd_en_fr1_iss, vdiv1_rf_wr_addr_fw1_f1, vdiv1_rf_wr_en_fw1_f1) |
                                 check_read_hazard(raw_rf_rd_addr_fr0_iss, raw_rf_rd_en_fr0_iss, vdiv1_rf_wr_addr_fw1_f1, vdiv1_rf_wr_en_fw1_f1)};

  assign vdiv0_read_hazard = (vdiv0_f1_read_hazard &
                              (fdivs_valid_f1_i[0] |
                               fdivs_valid_f2_i[0] |
                               fdivs_valid_f3_i[0] |
                               vdiv0_committed) & valid_instrs_iss_i[0]);

  assign vdiv1_read_hazard = (vdiv1_f1_read_hazard &
                              (fdivs_valid_f1_i[1] |
                               fdivs_valid_f2_i[1] |
                               fdivs_valid_f3_i[1] |
                               vdiv1_committed) & valid_instrs_iss_i[0]);

  // Write Hazard
  // Check incoming write addresses against stored write address,
  // but only when busy & not when inserting sFDIV.
  function automatic fdivs_check_write_hazard;
    input [`CA53_FP_RF_WR_ADDR_W-1:0] wr_addr_iss;
    input                       [3:0] wr_en_iss;
    input [`CA53_FP_RF_WR_ADDR_W-1:0] wr_addr_f1;
    input                       [2:0] wr_en_f1;

    fdivs_check_write_hazard = (wr_addr_iss[(`CA53_FP_RF_WR_ADDR_W-1):1] == wr_addr_f1[(`CA53_FP_RF_WR_ADDR_W-1):1]) &
                               ((wr_addr_iss[0] == wr_addr_f1[0]) | (|wr_en_iss[3:2]) | wr_en_f1[2]) &
                               ((|(wr_en_iss[1:0] & wr_en_f1[1:0])) | ((|wr_en_iss[3:2]) & (|wr_en_f1[1:0])) | (wr_en_f1[2] & (|wr_en_iss[1:0])));
  endfunction

  assign vdiv0_write_hazard = ((fdivs_check_write_hazard(pre_rf_wr_addr_fw0_iss_i, raw_rf_wr_en_fw0_iss_i, vdiv0_rf_wr_addr_fw0_f1, vdiv0_rf_wr_en_fw0_f1) |
                                fdivs_check_write_hazard(raw_rf_wr_addr_fw1_iss_i, raw_rf_wr_en_fw1_iss_i, vdiv0_rf_wr_addr_fw0_f1, vdiv0_rf_wr_en_fw0_f1)) &
                              (fdivs_valid_f1_i[0] |
                               fdivs_valid_f2_i[0] |
                               fdivs_valid_f3_i[0] |
                               vdiv0_committed) & valid_instrs_iss_i[0]);

  assign vdiv1_write_hazard = ((fdivs_check_write_hazard(pre_rf_wr_addr_fw0_iss_i, raw_rf_wr_en_fw0_iss_i, vdiv1_rf_wr_addr_fw1_f1, vdiv1_rf_wr_en_fw1_f1) |
                                fdivs_check_write_hazard(raw_rf_wr_addr_fw1_iss_i, raw_rf_wr_en_fw1_iss_i, vdiv1_rf_wr_addr_fw1_f1, vdiv1_rf_wr_en_fw1_f1)) &
                              (fdivs_valid_f1_i[1] |
                               fdivs_valid_f2_i[1] |
                               fdivs_valid_f3_i[1] |
                               vdiv1_committed) & valid_instrs_iss_i[0]);

  // ------------------------------------------------------
  // FDIV/SQRT Interlock Generation
  // ------------------------------------------------------

  assign fdivs_interlock_iss = (vdiv0_struct_hazard |
                                vdiv0_read_hazard   |
                                vdiv0_write_hazard  |
                                vdiv1_struct_hazard |
                                vdiv1_read_hazard   |
                                vdiv1_write_hazard);

  // ===========================================================================
  // == FMAC Control                                                          ==
  // ===========================================================================
  //
  // The following logic generates control and interlock signals for
  // FMAC instructions.

  assign fp_mul0_ctl_iss = fp0_pipectl_iss_i[`CA53_FP_PIPECTL_MUL_CTL_BITS];
  assign fp_add0_ctl_iss = fp0_pipectl_iss_i[`CA53_FP_PIPECTL_ADD_CTL_BITS];

  assign fp_mul1_ctl_iss = fp1_pipectl_iss_i[`CA53_FP_PIPECTL_MUL_CTL_BITS];
  assign fp_add1_ctl_iss = fp1_pipectl_iss_i[`CA53_FP_PIPECTL_ADD_CTL_BITS];

  assign fmac0_valid_iss = raw_fp_ex_pipe_iss_i[`CA53_FP_EX_PIPE_MUL0] & valid_instrs_iss_i[0] & fmac_valid_sp_iss_i[0] & ~stall_slot0_iss_i;
  assign fmac1_valid_iss = raw_fp_ex_pipe_iss_i[`CA53_FP_EX_PIPE_MUL1] & valid_instrs_iss_i[0] & fmac_valid_sp_iss_i[1] & ~stall_slot0_iss_i;

  assign fmac0_valid_en = ((fmac0_valid_iss |
                            fmac0_valid_f1  |
                            fmac0_valid_f2  |
                            fmac0_valid_f3  |
                            fmac0_valid_f4) & ~(stall_wr_i & ~flush_ret_i));

  assign fmac1_valid_en = ((fmac1_valid_iss |
                            fmac1_valid_f1  |
                            fmac1_valid_f2  |
                            fmac1_valid_f3  |
                            fmac1_valid_f4) & ~(stall_wr_i & ~flush_ret_i));

  assign nxt_fmac0_valid_f1 = fmac0_valid_iss & valid_instrs_iss_i[0]                        & ~flush_wr_i & ~ilock_stall_div_iss_i;
  assign nxt_fmac0_valid_f2 = fmac0_valid_f1  & valid_instrs_ex1_i[0]                        & ~flush_wr_i;
  assign nxt_fmac0_valid_f3 = fmac0_valid_f2  & valid_instrs_ex2_i[0] & cc_pass_instr0_ex2_i & ~flush_wr_i;
  assign nxt_fmac0_valid_f4 = fmac0_valid_f3  & valid_instrs_wr_i[0]                         & ~quash_wr_special_i;

  assign fmac1_cc_pass_ex2 = slot1_fp_ex2_i ? cc_pass_instr1_ex2_i : cc_pass_instr0_ex2_i;

  assign nxt_fmac1_valid_f1 = fmac1_valid_iss & valid_instrs_iss_i[0]                        & ~flush_wr_i & ~ilock_stall_div_iss_i;
  assign nxt_fmac1_valid_f2 = fmac1_valid_f1  & valid_instrs_ex1_i[0]                        & ~flush_wr_i;
  assign nxt_fmac1_valid_f3 = fmac1_valid_f2  & valid_instrs_ex2_i[0] & fmac1_cc_pass_ex2    & ~flush_wr_i;
  assign nxt_fmac1_valid_f4 = fmac1_valid_f3  & valid_instrs_wr_i[0]                         & ~quash_wr_special_i & ~slot0_br_flush_wr_i;

  assign nxt_fmac0_sign_f1        = (fp_add0_ctl_iss[`CA53_FP_ADD_FP_OP_BITS] == `CA53_FP_OP_RSB);
  assign nxt_fmac0_dp_f1          = fp_mul0_ctl_iss[`CA53_FP_MUL_PRECISION_BITS];
  assign nxt_fmac0_wr_en_fw0_f1   = {raw_rf_wr_en_fw0_iss_i[3], raw_rf_wr_en_fw0_iss_i[1:0]};
  assign nxt_fmac0_wr_addr_fw0_f1 = pre_rf_wr_addr_fw0_iss_i;

  assign nxt_fmac1_sign_f1        = (fp_add1_ctl_iss[`CA53_FP_ADD_FP_OP_BITS] == `CA53_FP_OP_RSB);
  assign nxt_fmac1_dp_f1          = fp_mul1_ctl_iss[`CA53_FP_MUL_PRECISION_BITS];
  assign nxt_fmac1_wr_en_fw1_f1   = {raw_rf_wr_en_fw1_iss_i[3], raw_rf_wr_en_fw1_iss_i[1:0]};
  assign nxt_fmac1_wr_addr_fw1_f1 = raw_rf_wr_addr_fw1_iss_i;

  always @(posedge clk or negedge reset_n) // Non-Regionally gated clock
    if (~reset_n) begin
      fmac0_valid_f1       <= 1'b0;
      fmac0_valid_f2       <= 1'b0;
      fmac0_valid_f3       <= 1'b0;
      fmac0_valid_f4       <= 1'b0;
    end else if (fmac0_valid_en) begin
      fmac0_valid_f1       <= nxt_fmac0_valid_f1;
      fmac0_valid_f2       <= nxt_fmac0_valid_f2;
      fmac0_valid_f3       <= nxt_fmac0_valid_f3;
      fmac0_valid_f4       <= nxt_fmac0_valid_f4;
    end

  always @(posedge clk_fp_ctl or negedge reset_n) // Regionally gated clock
    if (~reset_n) begin
      fmac0_sign_f1        <= 1'b0;
      fmac0_sign_f2        <= 1'b0;
      fmac0_sign_f3        <= 1'b0;
      fmac0_sign_f4        <= 1'b0;
      fmac0_wr_addr_fw0_f4 <= {`CA53_FP_RF_WR_ADDR_W{1'b0}};
      fmac0_wr_en_fw0_f4   <= {3{1'b0}};
    end else if (fmac0_valid_en) begin
      fmac0_sign_f1        <= nxt_fmac0_sign_f1;
      fmac0_sign_f2        <= fmac0_sign_f1;
      fmac0_sign_f3        <= fmac0_sign_f2;
      fmac0_sign_f4        <= fmac0_sign_f3;
      fmac0_wr_addr_fw0_f4 <= fmac0_wr_addr_fw0_f3;
      fmac0_wr_en_fw0_f4   <= fmac0_wr_en_fw0_f3;
    end

  always @(posedge clk or negedge reset_n) // Non-Regionally gated clock
    if(~reset_n) begin
      fmac1_valid_f1       <= 1'b0;
      fmac1_valid_f2       <= 1'b0;
      fmac1_valid_f3       <= 1'b0;
      fmac1_valid_f4       <= 1'b0;
    end else if (fmac1_valid_en) begin
      fmac1_valid_f1       <= nxt_fmac1_valid_f1;
      fmac1_valid_f2       <= nxt_fmac1_valid_f2;
      fmac1_valid_f3       <= nxt_fmac1_valid_f3;
      fmac1_valid_f4       <= nxt_fmac1_valid_f4;
    end

  always @(posedge clk_fp_ctl or negedge reset_n) // Regionally gated clock
    if(~reset_n) begin
      fmac1_sign_f1        <= 1'b0;
      fmac1_sign_f2        <= 1'b0;
      fmac1_sign_f3        <= 1'b0;
      fmac1_sign_f4        <= 1'b0;
      fmac1_wr_addr_fw1_f4 <= {`CA53_FP_RF_WR_ADDR_W{1'b0}};
      fmac1_wr_en_fw1_f4   <= {3{1'b0}};
    end else if (fmac1_valid_en) begin
      fmac1_sign_f1        <= nxt_fmac1_sign_f1;
      fmac1_sign_f2        <= fmac1_sign_f1;
      fmac1_sign_f3        <= fmac1_sign_f2;
      fmac1_sign_f4        <= fmac1_sign_f3;
      fmac1_wr_addr_fw1_f4 <= fmac1_wr_addr_fw1_f3;
      fmac1_wr_en_fw1_f4   <= fmac1_wr_en_fw1_f3;
    end

  always @(posedge clk_fp_ctl)
    if (fmac0_valid_en) begin
      fmac0_dp_f1           <= nxt_fmac0_dp_f1;
      fmac0_dp_f2           <= fmac0_dp_f1;
      fmac0_dp_f3           <= fmac0_dp_f2;
      fmac0_dp_f4           <= fmac0_dp_f3;
      fmac0_wr_addr_fw0_f1  <= nxt_fmac0_wr_addr_fw0_f1;
      fmac0_wr_addr_fw0_f2  <= fmac0_wr_addr_fw0_f1;
      fmac0_wr_addr_fw0_f3  <= fmac0_wr_addr_fw0_f2;
      fmac0_wr_en_fw0_f1    <= nxt_fmac0_wr_en_fw0_f1;
      fmac0_wr_en_fw0_f2    <= fmac0_wr_en_fw0_f1;
      fmac0_wr_en_fw0_f3    <= fmac0_wr_en_fw0_f2;
      fmac0_rd_addr_fr2_f1  <= raw_rf_rd_addr_fr2_iss;
      fmac0_rd_addr_fr2_f2  <= fmac0_rd_addr_fr2_f1;
      fmac0_rd_addr_fr2_f3  <= fmac0_rd_addr_fr2_f2;
      fmac0_rd_addr_fr2_f4  <= fmac0_rd_addr_fr2_f3;
      fmac0_sel_fad0_a_f1   <= sel_fad0_a_iss_i;
      fmac0_sel_fad0_a_f2   <= fmac0_sel_fad0_a_f1;
      fmac0_sel_fad0_a_f3   <= fmac0_sel_fad0_a_f2;
      fmac0_sel_fad0_a_f4   <= fmac0_sel_fad0_a_f3;
    end

  always @(posedge clk_fp_ctl)
    if (fmac1_valid_en) begin
      fmac1_dp_f1           <= nxt_fmac1_dp_f1;
      fmac1_dp_f2           <= fmac1_dp_f1;
      fmac1_dp_f3           <= fmac1_dp_f2;
      fmac1_dp_f4           <= fmac1_dp_f3;
      fmac1_wr_addr_fw1_f1  <= nxt_fmac1_wr_addr_fw1_f1;
      fmac1_wr_addr_fw1_f2  <= fmac1_wr_addr_fw1_f1;
      fmac1_wr_addr_fw1_f3  <= fmac1_wr_addr_fw1_f2;
      fmac1_wr_en_fw1_f1    <= nxt_fmac1_wr_en_fw1_f1;
      fmac1_wr_en_fw1_f2    <= fmac1_wr_en_fw1_f1;
      fmac1_wr_en_fw1_f3    <= fmac1_wr_en_fw1_f2;
      fmac1_rd_addr_fr5_f1  <= raw_rf_rd_addr_fr5_iss;
      fmac1_rd_addr_fr5_f2  <= fmac1_rd_addr_fr5_f1;
      fmac1_rd_addr_fr5_f3  <= fmac1_rd_addr_fr5_f2;
      fmac1_rd_addr_fr5_f4  <= fmac1_rd_addr_fr5_f3;
      fmac1_sel_fad1_a_f1   <= sel_fad1_a_iss_i;
      fmac1_sel_fad1_a_f2   <= fmac1_sel_fad1_a_f1;
      fmac1_sel_fad1_a_f3   <= fmac1_sel_fad1_a_f2;
      fmac1_sel_fad1_a_f4   <= fmac1_sel_fad1_a_f3;
    end

  // Insert the special when the instruction leaves wr, and hasn't ccfailed.
  assign fmac0_insert_iss = fmac0_valid_f4;
  assign fmac1_insert_iss = fmac1_valid_f4;

  // ------------------------------------------------------
  // FMAC Hazard Checking
  // ------------------------------------------------------
  // We must check for any RAW hazards between the instruction in Iss and the
  // write address in F1/F2/F3/F4. The write address will become the read/write
  // address for the accumulator so we must interlock until the special is
  // inserted.
  //
  // We also need to check for WAW hazards to prevent a special being inserted
  // after a later instruction that writes the same destination.  If the fmacs
  // ccfails then the special will not be inserted, therefore no need to
  // interlock in this case.

  // FMAC read hazard checking
  assign fmac0_f1_read_hazard =  check_read_hazard(raw_rf_rd_addr_fr0_iss, raw_rf_rd_en_fr0_iss, fmac0_wr_addr_fw0_f1, fmac0_wr_en_fw0_f1) |
                                 check_read_hazard(raw_rf_rd_addr_fr1_iss, raw_rf_rd_en_fr1_iss, fmac0_wr_addr_fw0_f1, fmac0_wr_en_fw0_f1) |
                                 check_read_hazard(raw_rf_rd_addr_fr2_iss, raw_rf_rd_en_fr2_iss, fmac0_wr_addr_fw0_f1, fmac0_wr_en_fw0_f1) |
                                 check_read_hazard(raw_rf_rd_addr_fr3_iss, raw_rf_rd_en_fr3_iss, fmac0_wr_addr_fw0_f1, fmac0_wr_en_fw0_f1) |
                                 check_read_hazard(raw_rf_rd_addr_fr4_iss, raw_rf_rd_en_fr4_iss, fmac0_wr_addr_fw0_f1, fmac0_wr_en_fw0_f1) |
                                 check_read_hazard(raw_rf_rd_addr_fr5_iss, raw_rf_rd_en_fr5_iss, fmac0_wr_addr_fw0_f1, fmac0_wr_en_fw0_f1);

  assign fmac0_f2_read_hazard =  check_read_hazard(raw_rf_rd_addr_fr0_iss, raw_rf_rd_en_fr0_iss, fmac0_wr_addr_fw0_f2, fmac0_wr_en_fw0_f2) |
                                 check_read_hazard(raw_rf_rd_addr_fr1_iss, raw_rf_rd_en_fr1_iss, fmac0_wr_addr_fw0_f2, fmac0_wr_en_fw0_f2) |
                                 check_read_hazard(raw_rf_rd_addr_fr2_iss, raw_rf_rd_en_fr2_iss, fmac0_wr_addr_fw0_f2, fmac0_wr_en_fw0_f2) |
                                 check_read_hazard(raw_rf_rd_addr_fr3_iss, raw_rf_rd_en_fr3_iss, fmac0_wr_addr_fw0_f2, fmac0_wr_en_fw0_f2) |
                                 check_read_hazard(raw_rf_rd_addr_fr4_iss, raw_rf_rd_en_fr4_iss, fmac0_wr_addr_fw0_f2, fmac0_wr_en_fw0_f2) |
                                 check_read_hazard(raw_rf_rd_addr_fr5_iss, raw_rf_rd_en_fr5_iss, fmac0_wr_addr_fw0_f2, fmac0_wr_en_fw0_f2);

  assign fmac0_f3_read_hazard =  check_read_hazard(raw_rf_rd_addr_fr0_iss, raw_rf_rd_en_fr0_iss, fmac0_wr_addr_fw0_f3, fmac0_wr_en_fw0_f3) |
                                 check_read_hazard(raw_rf_rd_addr_fr1_iss, raw_rf_rd_en_fr1_iss, fmac0_wr_addr_fw0_f3, fmac0_wr_en_fw0_f3) |
                                 check_read_hazard(raw_rf_rd_addr_fr2_iss, raw_rf_rd_en_fr2_iss, fmac0_wr_addr_fw0_f3, fmac0_wr_en_fw0_f3) |
                                 check_read_hazard(raw_rf_rd_addr_fr3_iss, raw_rf_rd_en_fr3_iss, fmac0_wr_addr_fw0_f3, fmac0_wr_en_fw0_f3) |
                                 check_read_hazard(raw_rf_rd_addr_fr4_iss, raw_rf_rd_en_fr4_iss, fmac0_wr_addr_fw0_f3, fmac0_wr_en_fw0_f3) |
                                 check_read_hazard(raw_rf_rd_addr_fr5_iss, raw_rf_rd_en_fr5_iss, fmac0_wr_addr_fw0_f3, fmac0_wr_en_fw0_f3);

  assign fmac0_f4_read_hazard =  check_read_hazard(raw_rf_rd_addr_fr0_iss, raw_rf_rd_en_fr0_iss, fmac0_wr_addr_fw0_f4, fmac0_wr_en_fw0_f4) |
                                 check_read_hazard(raw_rf_rd_addr_fr1_iss, raw_rf_rd_en_fr1_iss, fmac0_wr_addr_fw0_f4, fmac0_wr_en_fw0_f4) |
                                (check_read_hazard(raw_rf_rd_addr_fr2_iss, raw_rf_rd_en_fr2_iss, fmac0_wr_addr_fw0_f4, fmac0_wr_en_fw0_f4) & ~fmac_valid_sp_iss_i[0]) |
                                 check_read_hazard(raw_rf_rd_addr_fr3_iss, raw_rf_rd_en_fr3_iss, fmac0_wr_addr_fw0_f4, fmac0_wr_en_fw0_f4) |
                                 check_read_hazard(raw_rf_rd_addr_fr4_iss, raw_rf_rd_en_fr4_iss, fmac0_wr_addr_fw0_f4, fmac0_wr_en_fw0_f4) |
                                (check_read_hazard(raw_rf_rd_addr_fr5_iss, raw_rf_rd_en_fr5_iss, fmac0_wr_addr_fw0_f4, fmac0_wr_en_fw0_f4) & ~fmac_valid_sp_iss_i[1]);


  assign fmac1_f1_read_hazard =  check_read_hazard(raw_rf_rd_addr_fr0_iss, raw_rf_rd_en_fr0_iss, fmac1_wr_addr_fw1_f1, fmac1_wr_en_fw1_f1) |
                                 check_read_hazard(raw_rf_rd_addr_fr1_iss, raw_rf_rd_en_fr1_iss, fmac1_wr_addr_fw1_f1, fmac1_wr_en_fw1_f1) |
                                 check_read_hazard(raw_rf_rd_addr_fr2_iss, raw_rf_rd_en_fr2_iss, fmac1_wr_addr_fw1_f1, fmac1_wr_en_fw1_f1) |
                                 check_read_hazard(raw_rf_rd_addr_fr3_iss, raw_rf_rd_en_fr3_iss, fmac1_wr_addr_fw1_f1, fmac1_wr_en_fw1_f1) |
                                 check_read_hazard(raw_rf_rd_addr_fr4_iss, raw_rf_rd_en_fr4_iss, fmac1_wr_addr_fw1_f1, fmac1_wr_en_fw1_f1) |
                                 check_read_hazard(raw_rf_rd_addr_fr5_iss, raw_rf_rd_en_fr5_iss, fmac1_wr_addr_fw1_f1, fmac1_wr_en_fw1_f1);

  assign fmac1_f2_read_hazard =  check_read_hazard(raw_rf_rd_addr_fr0_iss, raw_rf_rd_en_fr0_iss, fmac1_wr_addr_fw1_f2, fmac1_wr_en_fw1_f2) |
                                 check_read_hazard(raw_rf_rd_addr_fr1_iss, raw_rf_rd_en_fr1_iss, fmac1_wr_addr_fw1_f2, fmac1_wr_en_fw1_f2) |
                                 check_read_hazard(raw_rf_rd_addr_fr2_iss, raw_rf_rd_en_fr2_iss, fmac1_wr_addr_fw1_f2, fmac1_wr_en_fw1_f2) |
                                 check_read_hazard(raw_rf_rd_addr_fr3_iss, raw_rf_rd_en_fr3_iss, fmac1_wr_addr_fw1_f2, fmac1_wr_en_fw1_f2) |
                                 check_read_hazard(raw_rf_rd_addr_fr4_iss, raw_rf_rd_en_fr4_iss, fmac1_wr_addr_fw1_f2, fmac1_wr_en_fw1_f2) |
                                 check_read_hazard(raw_rf_rd_addr_fr5_iss, raw_rf_rd_en_fr5_iss, fmac1_wr_addr_fw1_f2, fmac1_wr_en_fw1_f2);

  assign fmac1_f3_read_hazard =  check_read_hazard(raw_rf_rd_addr_fr0_iss, raw_rf_rd_en_fr0_iss, fmac1_wr_addr_fw1_f3, fmac1_wr_en_fw1_f3) |
                                 check_read_hazard(raw_rf_rd_addr_fr1_iss, raw_rf_rd_en_fr1_iss, fmac1_wr_addr_fw1_f3, fmac1_wr_en_fw1_f3) |
                                 check_read_hazard(raw_rf_rd_addr_fr2_iss, raw_rf_rd_en_fr2_iss, fmac1_wr_addr_fw1_f3, fmac1_wr_en_fw1_f3) |
                                 check_read_hazard(raw_rf_rd_addr_fr3_iss, raw_rf_rd_en_fr3_iss, fmac1_wr_addr_fw1_f3, fmac1_wr_en_fw1_f3) |
                                 check_read_hazard(raw_rf_rd_addr_fr4_iss, raw_rf_rd_en_fr4_iss, fmac1_wr_addr_fw1_f3, fmac1_wr_en_fw1_f3) |
                                 check_read_hazard(raw_rf_rd_addr_fr5_iss, raw_rf_rd_en_fr5_iss, fmac1_wr_addr_fw1_f3, fmac1_wr_en_fw1_f3);

  assign fmac1_f4_read_hazard =  check_read_hazard(raw_rf_rd_addr_fr0_iss, raw_rf_rd_en_fr0_iss, fmac1_wr_addr_fw1_f4, fmac1_wr_en_fw1_f4) |
                                 check_read_hazard(raw_rf_rd_addr_fr1_iss, raw_rf_rd_en_fr1_iss, fmac1_wr_addr_fw1_f4, fmac1_wr_en_fw1_f4) |
                                (check_read_hazard(raw_rf_rd_addr_fr2_iss, raw_rf_rd_en_fr2_iss, fmac1_wr_addr_fw1_f4, fmac1_wr_en_fw1_f4) & ~fmac_valid_sp_iss_i[0]) |
                                 check_read_hazard(raw_rf_rd_addr_fr3_iss, raw_rf_rd_en_fr3_iss, fmac1_wr_addr_fw1_f4, fmac1_wr_en_fw1_f4) |
                                 check_read_hazard(raw_rf_rd_addr_fr4_iss, raw_rf_rd_en_fr4_iss, fmac1_wr_addr_fw1_f4, fmac1_wr_en_fw1_f4) |
                                (check_read_hazard(raw_rf_rd_addr_fr5_iss, raw_rf_rd_en_fr5_iss, fmac1_wr_addr_fw1_f4, fmac1_wr_en_fw1_f4) & ~fmac_valid_sp_iss_i[1]);


  assign fmac_read_hazard = valid_instrs_iss_i[0] &
                            ((fmac0_valid_f1 & fmac0_f1_read_hazard) |
                             (fmac0_valid_f2 & fmac0_f2_read_hazard) |
                             (fmac0_valid_f3 & fmac0_f3_read_hazard) |
                             (fmac0_valid_f4 & fmac0_f4_read_hazard) |
                             (fmac1_valid_f1 & fmac1_f1_read_hazard) |
                             (fmac1_valid_f2 & fmac1_f2_read_hazard) |
                             (fmac1_valid_f3 & fmac1_f3_read_hazard) |
                             (fmac1_valid_f4 & fmac1_f4_read_hazard));  

  // FMACS write hazard checking
  function automatic fmac_check_waw_hazard;
    input [`CA53_FP_RF_WR_ADDR_W-1:0] wr_addr_iss;
    input                       [3:0] wr_en_iss;
    input [`CA53_FP_RF_WR_ADDR_W-1:0] wr_addr;
    input                       [2:0] wr_en;
    input                             fmac_valid;

    fmac_check_waw_hazard = fmac_valid &
                            (wr_addr_iss[`CA53_FP_RF_WR_ADDR_W-1:1] == wr_addr[`CA53_FP_RF_WR_ADDR_W-1:1]) &
                            (((|(wr_en_iss[1:0] & wr_en[1:0])) & (wr_addr_iss[0] == wr_addr[0])) |
                             ((|wr_en_iss[3:2]) & ((|wr_en[1:0])))                               |
                             (wr_en[2] & (|wr_en_iss[1:0])));
  endfunction

  function automatic fmac_check_war_hazard;
    input [`CA53_FP_RF_WR_ADDR_W-1:0] wr_addr_iss;
    input                       [3:0] wr_en_iss;
    input [`CA53_FP_RF_RD_ADDR_W-1:0] rd_addr;
    input                       [2:0] wr_en;
    input                             fmac_valid;

    fmac_check_war_hazard = fmac_valid &
                            (wr_addr_iss[`CA53_FP_RF_WR_ADDR_W-1:1] == rd_addr[`CA53_FP_RF_RD_ADDR_W-1:1]) &
                            (((|(wr_en_iss[1:0] & wr_en[1:0])) & (wr_addr_iss[0] == rd_addr[0])) |
                             ((|wr_en_iss[3:2]) & ((|wr_en[1:0]))));
  endfunction

  assign fmac_write_hazard =
          // Check for write-after-write hazards
           fmac_check_waw_hazard(pre_rf_wr_addr_fw0_iss_i, raw_rf_wr_en_fw0_iss_i, fmac0_wr_addr_fw0_f1, fmac0_wr_en_fw0_f1, fmac0_valid_f1) |
           fmac_check_waw_hazard(raw_rf_wr_addr_fw1_iss_i, raw_rf_wr_en_fw1_iss_i, fmac0_wr_addr_fw0_f1, fmac0_wr_en_fw0_f1, fmac0_valid_f1) |
           fmac_check_waw_hazard(pre_rf_wr_addr_fw0_iss_i, raw_rf_wr_en_fw0_iss_i, fmac0_wr_addr_fw0_f2, fmac0_wr_en_fw0_f2, fmac0_valid_f2) |
           fmac_check_waw_hazard(raw_rf_wr_addr_fw1_iss_i, raw_rf_wr_en_fw1_iss_i, fmac0_wr_addr_fw0_f2, fmac0_wr_en_fw0_f2, fmac0_valid_f2) |
           fmac_check_waw_hazard(pre_rf_wr_addr_fw0_iss_i, raw_rf_wr_en_fw0_iss_i, fmac0_wr_addr_fw0_f3, fmac0_wr_en_fw0_f3, fmac0_valid_f3) |
           fmac_check_waw_hazard(raw_rf_wr_addr_fw1_iss_i, raw_rf_wr_en_fw1_iss_i, fmac0_wr_addr_fw0_f3, fmac0_wr_en_fw0_f3, fmac0_valid_f3) |
          (fmac_check_waw_hazard(pre_rf_wr_addr_fw0_iss_i, raw_rf_wr_en_fw0_iss_i, fmac0_wr_addr_fw0_f4, fmac0_wr_en_fw0_f4, fmac0_valid_f4) & ~fmac_valid_sp_iss_i[0]) |
          (fmac_check_waw_hazard(raw_rf_wr_addr_fw1_iss_i, raw_rf_wr_en_fw1_iss_i, fmac0_wr_addr_fw0_f4, fmac0_wr_en_fw0_f4, fmac0_valid_f4) & ~fmac_valid_sp_iss_i[1]) |
           fmac_check_waw_hazard(pre_rf_wr_addr_fw0_iss_i, raw_rf_wr_en_fw0_iss_i, fmac1_wr_addr_fw1_f1, fmac1_wr_en_fw1_f1, fmac1_valid_f1) |
           fmac_check_waw_hazard(raw_rf_wr_addr_fw1_iss_i, raw_rf_wr_en_fw1_iss_i, fmac1_wr_addr_fw1_f1, fmac1_wr_en_fw1_f1, fmac1_valid_f1) |
           fmac_check_waw_hazard(pre_rf_wr_addr_fw0_iss_i, raw_rf_wr_en_fw0_iss_i, fmac1_wr_addr_fw1_f2, fmac1_wr_en_fw1_f2, fmac1_valid_f2) |
           fmac_check_waw_hazard(raw_rf_wr_addr_fw1_iss_i, raw_rf_wr_en_fw1_iss_i, fmac1_wr_addr_fw1_f2, fmac1_wr_en_fw1_f2, fmac1_valid_f2) |
           fmac_check_waw_hazard(pre_rf_wr_addr_fw0_iss_i, raw_rf_wr_en_fw0_iss_i, fmac1_wr_addr_fw1_f3, fmac1_wr_en_fw1_f3, fmac1_valid_f3) |
           fmac_check_waw_hazard(raw_rf_wr_addr_fw1_iss_i, raw_rf_wr_en_fw1_iss_i, fmac1_wr_addr_fw1_f3, fmac1_wr_en_fw1_f3, fmac1_valid_f3) |
          (fmac_check_waw_hazard(pre_rf_wr_addr_fw0_iss_i, raw_rf_wr_en_fw0_iss_i, fmac1_wr_addr_fw1_f4, fmac1_wr_en_fw1_f4, fmac1_valid_f4) & ~fmac_valid_sp_iss_i[0]) |
          (fmac_check_waw_hazard(raw_rf_wr_addr_fw1_iss_i, raw_rf_wr_en_fw1_iss_i, fmac1_wr_addr_fw1_f4, fmac1_wr_en_fw1_f4, fmac1_valid_f4) & ~fmac_valid_sp_iss_i[1]) |
          // Check for write-after-read hazards on the accumulator
           fmac_check_war_hazard(pre_rf_wr_addr_fw0_iss_i, raw_rf_wr_en_fw0_iss_i, fmac0_rd_addr_fr2_f1, fmac0_wr_en_fw0_f1, fmac0_valid_f1) |
           fmac_check_war_hazard(raw_rf_wr_addr_fw1_iss_i, raw_rf_wr_en_fw1_iss_i, fmac0_rd_addr_fr2_f1, fmac0_wr_en_fw0_f1, fmac0_valid_f1) |
           fmac_check_war_hazard(pre_rf_wr_addr_fw0_iss_i, raw_rf_wr_en_fw0_iss_i, fmac0_rd_addr_fr2_f2, fmac0_wr_en_fw0_f2, fmac0_valid_f2) |
           fmac_check_war_hazard(raw_rf_wr_addr_fw1_iss_i, raw_rf_wr_en_fw1_iss_i, fmac0_rd_addr_fr2_f2, fmac0_wr_en_fw0_f2, fmac0_valid_f2) |
           fmac_check_war_hazard(pre_rf_wr_addr_fw0_iss_i, raw_rf_wr_en_fw0_iss_i, fmac0_rd_addr_fr2_f3, fmac0_wr_en_fw0_f3, fmac0_valid_f3) |
           fmac_check_war_hazard(raw_rf_wr_addr_fw1_iss_i, raw_rf_wr_en_fw1_iss_i, fmac0_rd_addr_fr2_f3, fmac0_wr_en_fw0_f3, fmac0_valid_f3) |
          (fmac_check_war_hazard(pre_rf_wr_addr_fw0_iss_i, raw_rf_wr_en_fw0_iss_i, fmac0_rd_addr_fr2_f4, fmac0_wr_en_fw0_f4, fmac0_valid_f4) & ~fmac_valid_sp_iss_i[0]) |
          (fmac_check_war_hazard(raw_rf_wr_addr_fw1_iss_i, raw_rf_wr_en_fw1_iss_i, fmac0_rd_addr_fr2_f4, fmac0_wr_en_fw0_f4, fmac0_valid_f4) & ~fmac_valid_sp_iss_i[1]) |
           fmac_check_war_hazard(pre_rf_wr_addr_fw0_iss_i, raw_rf_wr_en_fw0_iss_i, fmac1_rd_addr_fr5_f1, fmac1_wr_en_fw1_f1, fmac1_valid_f1) |
           fmac_check_war_hazard(raw_rf_wr_addr_fw1_iss_i, raw_rf_wr_en_fw1_iss_i, fmac1_rd_addr_fr5_f1, fmac1_wr_en_fw1_f1, fmac1_valid_f1) |
           fmac_check_war_hazard(pre_rf_wr_addr_fw0_iss_i, raw_rf_wr_en_fw0_iss_i, fmac1_rd_addr_fr5_f2, fmac1_wr_en_fw1_f2, fmac1_valid_f2) |
           fmac_check_war_hazard(raw_rf_wr_addr_fw1_iss_i, raw_rf_wr_en_fw1_iss_i, fmac1_rd_addr_fr5_f2, fmac1_wr_en_fw1_f2, fmac1_valid_f2) |
           fmac_check_war_hazard(pre_rf_wr_addr_fw0_iss_i, raw_rf_wr_en_fw0_iss_i, fmac1_rd_addr_fr5_f3, fmac1_wr_en_fw1_f3, fmac1_valid_f3) |
           fmac_check_war_hazard(raw_rf_wr_addr_fw1_iss_i, raw_rf_wr_en_fw1_iss_i, fmac1_rd_addr_fr5_f3, fmac1_wr_en_fw1_f3, fmac1_valid_f3) |
          (fmac_check_war_hazard(pre_rf_wr_addr_fw0_iss_i, raw_rf_wr_en_fw0_iss_i, fmac1_rd_addr_fr5_f4, fmac1_wr_en_fw1_f4, fmac1_valid_f4) & ~fmac_valid_sp_iss_i[0]) |
          (fmac_check_war_hazard(raw_rf_wr_addr_fw1_iss_i, raw_rf_wr_en_fw1_iss_i, fmac1_rd_addr_fr5_f4, fmac1_wr_en_fw1_f4, fmac1_valid_f4) & ~fmac_valid_sp_iss_i[1]);

  // FMACS structural hazard checking
  assign fmac0_struct_hazard = fmac0_insert_iss & (raw_fp_ex_pipe_iss_i[`CA53_FP_EX_PIPE_ADD0] |
                                                   ((|raw_rf_wr_en_fw0_iss_i) & valid_instrs_iss_i[0] & ~fmac_valid_sp_iss_i[0]) |
                                                   ((|raw_rf_rd_en_fr2_iss)   & valid_instrs_iss_i[0] & ~fmac_valid_sp_iss_i[0]));

  assign fmac1_struct_hazard = fmac1_insert_iss & (raw_fp_ex_pipe_iss_i[`CA53_FP_EX_PIPE_ADD1] |
                                                   ((|raw_rf_wr_en_fw1_iss_i) & valid_instrs_iss_i[0] & ~fmac_valid_sp_iss_i[1]) |
                                                   ((|raw_rf_rd_en_fr5_iss)   & valid_instrs_iss_i[0] & ~fmac_valid_sp_iss_i[1]) |
                                                   lsm_skidding_i);

  // ------------------------------------------------------
  // FMACS Interlock Generation
  // ------------------------------------------------------

  // If forcing in order, then stall the NOP until we are ready to insert the sFMAC
  assign fmac_interlock_iss = fmac_read_hazard |
                              fmac_write_hazard |
                              fmac0_struct_hazard |
                              fmac1_struct_hazard |
                              (no_insert_iss_i & (fmac0_valid_f1 | fmac0_valid_f2 | fmac0_valid_f3 |
                                                  fmac1_valid_f1 | fmac1_valid_f2 | fmac1_valid_f3));

  // ===========================================================================
  // == Interlock Generation for serializing (FMXR/FMRX) Instructions  ==
  // ===========================================================================
  //
  // We must generate an interlock for instructions that write the FPSCR
  // (certain types of FMXR) to prevent the control signals changing while FPU
  // phantom instructions are in the pipeline (or the instruction is 'commited')
  // and the subsequent special has not been issued.
  //
  // We must also generate an interlock for instructions that read the FPSCR
  // registers (FMRX) while FPU phantom instructions are in the
  // pipeline (or the instruction is 'commited') since the subsequent special
  // may modify the FPSCR.
  //
  // Finally we must also serialize WFX instructions as these can break if
  // bisected by a special (and WFX instructions cannot be marked as no_insert).
  //
  // In all cases we must wait until the special has been issued before we
  // can allow the FMRX/FMXR instruction to proceed.

  assign fmac_in_flight = (fmac0_valid_f1 |
                           fmac0_valid_f2 |
                           fmac0_valid_f3 |
                           fmac0_valid_f4 |
                           fmac1_valid_f1 |
                           fmac1_valid_f2 |
                           fmac1_valid_f3 |
                           fmac1_valid_f4);

  assign fdivs_in_flight = ((|fdivs_valid_f1_i) |
                            (|fdivs_valid_f2_i) |
                            (|fdivs_valid_f3_i) |
                            vdiv0_committed     |
                            vdiv1_committed);

  assign fp_special_in_flight = fmac_in_flight | fdivs_in_flight;

  // Create the interlock - the fp_serialize_iss signal catches all cases except for
  // when we copy the FPSCR to the integer register file with an FMRX instruction.
  assign fpscr_interlock_iss = fp_special_in_flight & (fp_serialize_iss_i | wfx_serialize_iss_i);

  // ------------------------------------------------------
  // Combined Interlock and Type Signal
  // ------------------------------------------------------

  // Priority of special intructions is as follows:
  // 1: sFMAC  for FMAC
  // 2: sFDIV  for FDIV/FSQRT

  assign special_interlock_iss_o = fdivs_interlock_iss | fmac_interlock_iss | fpscr_interlock_iss;
  assign special_insert_iss_o[0] = vdiv0_stall_iss | fmac0_insert_iss;
  assign special_insert_iss_o[1] = vdiv1_stall_iss | fmac1_insert_iss;
  assign special_stall_iss_o     = vdiv0_stall_iss | vdiv1_stall_iss;

  always @* begin
    special_sel_fad0_a_iss_o        = `CA53_SEL_FAD_A_ZERO;
    special_sel_fad0_b_iss_o        = `CA53_SEL_FAD_B_ZERO;
    special_rf_rd_en_fr2_iss_o      = 2'b00;
    special_rf_rd_addr_fr2_iss_o    = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
    special_rf_wr_en_fw0_iss_o      = 4'b0000;
    special_rf_wr_addr_fw0_iss_o    = {`CA53_FP_RF_WR_ADDR_W{1'b0}};
    special_rf_wr_src_fw0_iss_o     = {`CA53_RF_FWR_SRC_W{1'b0}};
    special_fp_add0_ctl_iss_o       = {`CA53_FP_ADD_CTL_W{1'b0}};

    case ({fmac0_insert_iss, (~(|fp_div_busy_qual) & vdiv0_committed)})
      `ca53dpu_sel_1x : begin
        special_sel_fad0_a_iss_o        = fmac0_sel_fad0_a_f4;
        special_sel_fad0_b_iss_o        = `CA53_SEL_FAD_B_FML_Q;
        special_rf_rd_en_fr2_iss_o      = fmac0_wr_en_fw0_f4[1:0];
        special_rf_rd_addr_fr2_iss_o    = fmac0_rd_addr_fr2_f4;
        special_rf_wr_en_fw0_iss_o      = {fmac0_wr_en_fw0_f4[2], 1'b0, fmac0_wr_en_fw0_f4[1:0]};
        special_rf_wr_addr_fw0_iss_o    = fmac0_wr_addr_fw0_f4;
        special_rf_wr_src_fw0_iss_o     = `CA53_RF_FWR_SRC_FAD_Q;

        special_fp_add0_ctl_iss_o[`CA53_FP_NEON_ADD_SIZE_SEL_BITS]     = fmac0_dp_f4   ? 2'b11           : 2'b10;
        special_fp_add0_ctl_iss_o[`CA53_FP_ADD_FP_OP_BITS]             = fmac0_sign_f4 ? `CA53_FP_OP_RSB : `CA53_FP_OP_ADD;
        special_fp_add0_ctl_iss_o[`CA53_FP_NEON_ADD_NEON_MUX_SEL_BITS] = `CA53_NEON_MUX_SEL_AU;
      end
      2'b01           : begin
        special_rf_wr_en_fw0_iss_o      = {vdiv0_rf_wr_en_fw0_f1[2], 1'b0, vdiv0_rf_wr_en_fw0_f1[1:0]};
        special_rf_wr_addr_fw0_iss_o    = vdiv0_rf_wr_addr_fw0_f1;
        special_rf_wr_src_fw0_iss_o     = `CA53_RF_FWR_SRC_FML_Q;
      end
      2'b00           : begin
        // Pick up defaults
      end
      default         : begin
        special_sel_fad0_a_iss_o        = {`CA53_SEL_FAD_A_W{1'bx}};
        special_sel_fad0_b_iss_o        = {`CA53_SEL_FAD_B_W{1'bx}};
        special_rf_rd_en_fr2_iss_o      = 2'bxx;
        special_rf_rd_addr_fr2_iss_o    = {`CA53_FP_RF_RD_ADDR_W{1'bx}};
        special_rf_wr_en_fw0_iss_o      = 4'bxxxx;
        special_rf_wr_addr_fw0_iss_o    = {`CA53_FP_RF_WR_ADDR_W{1'bx}};
        special_rf_wr_src_fw0_iss_o     = {`CA53_RF_FWR_SRC_W{1'bx}};
        special_fp_add0_ctl_iss_o       = {`CA53_FP_ADD_CTL_W{1'bx}};
      end
    endcase
  end

  always @* begin
    special_sel_fad1_a_iss_o        = `CA53_SEL_FAD_A_ZERO;
    special_sel_fad1_b_iss_o        = `CA53_SEL_FAD_B_ZERO;
    special_rf_rd_en_fr5_iss_o      = 2'b00;
    special_rf_rd_addr_fr5_iss_o    = {`CA53_FP_RF_RD_ADDR_W{1'b0}};
    special_rf_wr_en_fw1_iss_o      = 4'b0000;
    special_rf_wr_addr_fw1_iss_o    = {`CA53_FP_RF_WR_ADDR_W{1'b0}};
    special_rf_wr_src_fw1_iss_o     = {`CA53_RF_FWR_SRC_W{1'b0}};
    special_fp_add1_ctl_iss_o       = {`CA53_FP_ADD_CTL_W{1'b0}};

    case ({fmac1_insert_iss, (~(|fp_div_busy_qual) & vdiv1_committed)})
      `ca53dpu_sel_1x : begin
        special_sel_fad1_a_iss_o        = fmac1_sel_fad1_a_f4;
        special_sel_fad1_b_iss_o        = `CA53_SEL_FAD_B_FML_Q;
        special_rf_rd_en_fr5_iss_o      = fmac1_wr_en_fw1_f4[1:0];
        special_rf_rd_addr_fr5_iss_o    = fmac1_rd_addr_fr5_f4;
        special_rf_wr_en_fw1_iss_o      = {fmac1_wr_en_fw1_f4[2], 1'b0, fmac1_wr_en_fw1_f4[1:0]};
        special_rf_wr_addr_fw1_iss_o    = fmac1_wr_addr_fw1_f4;
        special_rf_wr_src_fw1_iss_o     = `CA53_RF_FWR_SRC_FAD_Q;

        special_fp_add1_ctl_iss_o[`CA53_FP_NEON_ADD_SIZE_SEL_BITS]     = fmac1_dp_f4   ? 2'b11           : 2'b10;
        special_fp_add1_ctl_iss_o[`CA53_FP_ADD_FP_OP_BITS]             = fmac1_sign_f4 ? `CA53_FP_OP_RSB : `CA53_FP_OP_ADD;
        special_fp_add1_ctl_iss_o[`CA53_FP_NEON_ADD_NEON_MUX_SEL_BITS] = `CA53_NEON_MUX_SEL_AU;
      end
      2'b01           : begin
        special_rf_wr_en_fw1_iss_o      = {vdiv1_rf_wr_en_fw1_f1[2], 1'b0, vdiv1_rf_wr_en_fw1_f1[1:0] };
        special_rf_wr_addr_fw1_iss_o    = vdiv1_rf_wr_addr_fw1_f1;
        special_rf_wr_src_fw1_iss_o     = `CA53_RF_FWR_SRC_FML_Q;
      end
      2'b00           : begin
        // Pick up defaults
      end
      default         : begin
        special_sel_fad1_a_iss_o        = {`CA53_SEL_FAD_A_W{1'bx}};
        special_sel_fad1_b_iss_o        = {`CA53_SEL_FAD_B_W{1'bx}};
        special_rf_rd_en_fr5_iss_o      = 2'bxx;
        special_rf_rd_addr_fr5_iss_o    = {`CA53_FP_RF_RD_ADDR_W{1'bx}};
        special_rf_wr_en_fw1_iss_o      = 4'bxxxx;
        special_rf_wr_addr_fw1_iss_o    = {`CA53_FP_RF_WR_ADDR_W{1'bx}};
        special_rf_wr_src_fw1_iss_o     = {`CA53_RF_FWR_SRC_W{1'bx}};
        special_fp_add1_ctl_iss_o       = {`CA53_FP_ADD_CTL_W{1'bx}};
      end
    endcase
  end

  // ------------------------------------------------------
  // Assign to module outputs
  // ------------------------------------------------------

  assign unflushable_sfmac_iss_o    = {fmac1_insert_iss, fmac0_insert_iss};
  assign unflushable_sfdiv_iss_o    = vdiv0_stall_iss  | vdiv1_stall_iss;
  assign fmac_valid_f3_o            = fmac0_valid_f3   | fmac1_valid_f3;
  assign fp_special_in_flight_o     = fp_special_in_flight;
  assign fp_div_active_o            = {vdiv1_committed, vdiv0_committed};

  //----------------------------------------------------------------------------
  //                     OVL definitions
  //----------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_to_iss_fpu_i")
  u_ovl_x_issue_to_iss_fpu_i (.clk       (clk_fp_ctl),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (issue_to_iss_fpu_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: issue_to_iss_i")
  u_ovl_x_issue_to_iss_i (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (issue_to_iss_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_vdiv0_committed")
  u_ovl_x_en_vdiv0_committed (.clk       (clk_fp_ctl),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (en_vdiv0_committed));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_vdiv1_committed")
  u_ovl_x_en_vdiv1_committed (.clk       (clk_fp_ctl),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (en_vdiv1_committed));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: fmac0_valid_en")
  u_ovl_x_fmac0_valid_en (.clk       (clk_fp_ctl),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (fmac0_valid_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: fmac1_valid_en")
  u_ovl_x_fmac1_valid_en (.clk       (clk_fp_ctl),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (fmac1_valid_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: vdiv0_valid_masked_iss")
  u_ovl_x_vdiv0_valid_masked_iss (.clk       (clk_fp_ctl),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (vdiv0_valid_masked_iss));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: vdiv1_valid_masked_iss")
  u_ovl_x_vdiv1_valid_masked_iss (.clk       (clk_fp_ctl),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (vdiv1_valid_masked_iss));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"special_insert_iss is incorrect")
    ovl_special_insert (.clk             (clk_fp_ctl),
                        .reset_n         (reset_n),
                        .antecedent_expr (special_stall_iss_o),
                        .consequent_expr (|special_insert_iss_o));

  assert_zero_one_hot #(`OVL_FATAL,2,`OVL_ASSERT,"Pipe 0 insert special signals not one hot")
    ovl_special_onehot0 (.clk       (clk_fp_ctl),
                         .reset_n   (reset_n),
                         .test_expr ({vdiv0_stall_iss, fmac0_insert_iss}));

  assert_zero_one_hot #(`OVL_FATAL,2,`OVL_ASSERT,"Pipe 1 insert special signals not one hot")
    ovl_special_onehot1 (.clk       (clk_fp_ctl),
                         .reset_n   (reset_n),
                         .test_expr ({vdiv1_stall_iss, fmac1_insert_iss}));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"FR2 read enable for an FMAC operation is incorrect")
  ovl_fmac_rd_en_fr2 (
    .clk             (clk_fp_ctl),
    .reset_n         (reset_n),
    .antecedent_expr (fmac0_valid_iss),
    .consequent_expr (raw_rf_rd_en_fr2_iss == raw_rf_wr_en_fw0_iss_i[1:0])
  );

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"FR5 read enable for an FMAC operation is incorrect")
  ovl_fmac_rd_en_fr5 (
    .clk             (clk_fp_ctl),
    .reset_n         (reset_n),
    .antecedent_expr (fmac1_valid_iss),
    .consequent_expr (raw_rf_rd_en_fr5_iss == raw_rf_wr_en_fw1_iss_i[1:0])
  );

`endif

endmodule // ca53dpu_special

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/

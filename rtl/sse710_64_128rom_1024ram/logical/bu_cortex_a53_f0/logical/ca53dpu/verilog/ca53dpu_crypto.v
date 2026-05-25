//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2014 ARM Limited.
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
// Abstract: Crypto extensions pipeline
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_crypto (
  input  wire                         clk_crypto,
  input  wire                         reset_n,
  input  wire                         advance_pipeline_i,
  input  wire                         crypto_enable_f1_i,
  input  wire [`CA53_CRYPTO_OP_W-1:0] crypto_op_f1_i,
  input  wire                 [127:0] crypto_a_data_f1_i,
  input  wire                 [127:0] crypto_b_data_f1_i,
  input  wire                 [127:0] crypto_c_data_f1_i,
  output wire                         crypto_active_o,
  output wire                 [127:0] crypto_data_f3_o,
  output reg                  [127:0] crypto_data_f5_o
);

  // -----------------------------
  // Genvar declaration
  // -----------------------------
  genvar i;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg                           aes_invmixcols_f3;
  reg                  [127: 0] crypto_a_data_f2;
  reg                  [127: 0] crypto_a_data_f3;
  reg                  [127:64] crypto_a_data_f4;
  reg                  [127:96] crypto_a_data_f5;
  reg                  [127: 0] crypto_b_data_f2;
  reg                  [127: 0] crypto_b_data_f3;
  reg                  [127: 0] crypto_b_data_f4;
  reg                   [95: 0] crypto_b_data_f5;
  reg                  [127: 0] crypto_c_data_f2;
  reg                  [127: 0] crypto_c_data_f3;
  reg                  [127: 0] crypto_c_data_f4;
  reg                  [127: 0] crypto_c_data_f5;
  reg                           crypto_enable_f2;
  reg                           crypto_enable_f3;
  reg                           crypto_enable_f4;
  reg  [`CA53_CRYPTO_OP_W-1: 0] crypto_op_f2;
  reg  [`CA53_CRYPTO_OP_W-1: 0] crypto_op_f3;
  reg  [`CA53_CRYPTO_OP_W-1: 0] crypto_op_f4;
  reg  [`CA53_CRYPTO_OP_W-1: 0] crypto_op_f5;
  reg                  [127: 0] nxt_crypto_a_data_f2;
  reg                  [127: 0] nxt_crypto_a_data_f3;
  reg                  [127: 0] nxt_crypto_b_data_f3;
  reg                  [127: 0] nxt_crypto_b_data_f4;
  reg                   [95: 0] nxt_crypto_b_data_f5;
  reg                  [127: 0] nxt_crypto_c_data_f3;
  reg                  [127: 0] nxt_crypto_c_data_f4;
  reg                  [127: 0] nxt_crypto_c_data_f5;
  reg                    [1: 0] res_sel_a_f3;
  reg                    [1: 0] res_sel_mc_f3;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                 [127: 0] aes_add_roundkey_f1;
  wire                 [127: 0] aes_fwd_sbox_res_f2;
  wire                 [127: 0] aes_inv_sbox_res_f2;
  wire                          aes_invmixcols_f2;
  wire                 [127: 0] aes_invshiftrows_f2;
  wire                 [127: 0] aes_mixcol_data_f3;
  wire                 [127: 0] aes_shiftrows_f2;
  wire                          en_hi_c_data_f2;
  wire                          en_hi_c_data_f3;
  wire                          en_hi_c_data_f4;
  wire                          en_hi_c_data_f5;
  wire                          en_lo_bc_data_f2;
  wire                          en_lo_bc_data_f3;
  wire                          en_crypto_op_f2;
  wire                          en_crypto_op_f3;
  wire                          en_crypto_op_f4;
  wire                 [255: 0] hash_data_f2;
  wire                 [255: 0] hash_data_f3;
  wire                 [255: 0] hash_data_f4;
  wire                 [159: 0] hash_data_sha1_f5;
  wire                 [255: 0] hash_data_sha256_f5;
  wire                 [127: 0] nxt_crypto_c_data_f2;
  wire                          nxt_crypto_enable_f4;
  wire                 [126: 0] pmull64_res_f2;
  wire                          res_sel_a_f2;
  wire                          res_sel_mc_f2;
  wire                 [127: 0] sha1su1_t_f2;
  wire                 [127: 0] sha1su1_res_f2;
  wire                 [159: 0] sha1cpm_res_f2;
  wire                 [159: 0] sha1cpm_res_f3;
  wire                 [159: 0] sha1cpm_res_f4;
  wire                 [159: 0] sha1cpm_res_f5;
  wire                 [255: 0] sha256h_res_f2;
  wire                 [255: 0] sha256h_res_f3;
  wire                 [255: 0] sha256h_res_f4;
  wire                 [255: 0] sha256h_res_f5;
  wire                  [63: 0] sha256su1_res_f2;
  wire                  [63: 0] sha256su1_res_f3;

  //-----------------------------------------------------------------------------
  // F1 pipeline stage
  //-----------------------------------------------------------------------------

  assign aes_add_roundkey_f1 = crypto_a_data_f1_i ^ crypto_b_data_f1_i;

  always @*
    case (crypto_op_f1_i)
      `CA53_CRYPTO_OP_SHA1C,
      `CA53_CRYPTO_OP_SHA1P,
      `CA53_CRYPTO_OP_SHA1M,
      `CA53_CRYPTO_OP_SHA1SU1,
      `CA53_CRYPTO_OP_SHA256H,
      `CA53_CRYPTO_OP_SHA256H2,
      `CA53_CRYPTO_OP_AESMC,
      `CA53_CRYPTO_OP_AESIMC:
        nxt_crypto_a_data_f2 = crypto_a_data_f1_i;

      `CA53_CRYPTO_OP_SHA256SU1:
        nxt_crypto_a_data_f2 = { {64{1'b0}}, crypto_c_data_f1_i[127:64]};

      `CA53_CRYPTO_OP_AESE,
      `CA53_CRYPTO_OP_AESD,
      `CA53_CRYPTO_OP_AESE_AESMC,
      `CA53_CRYPTO_OP_AESD_AESIMC:
        nxt_crypto_a_data_f2 = aes_add_roundkey_f1;

      `CA53_CRYPTO_OP_PMULL64:
        nxt_crypto_a_data_f2 = {crypto_b_data_f1_i[63:0], crypto_a_data_f1_i[63:0]};

      default:
        nxt_crypto_a_data_f2 = {128{1'bx}};
    endcase

  assign nxt_crypto_c_data_f2 = (crypto_op_f1_i == `CA53_CRYPTO_OP_SHA256SU1) ? {crypto_c_data_f1_i[31:0],
                                                                                 crypto_a_data_f1_i[127:32]}
                                                                              : crypto_c_data_f1_i;

  assign en_lo_bc_data_f2 = crypto_enable_f1_i & advance_pipeline_i &
                            ((crypto_op_f1_i == `CA53_CRYPTO_OP_SHA1M)    |
                             (crypto_op_f1_i == `CA53_CRYPTO_OP_SHA1P)    |
                             (crypto_op_f1_i == `CA53_CRYPTO_OP_SHA1C)    |
                             (crypto_op_f1_i == `CA53_CRYPTO_OP_SHA256H)  |
                             (crypto_op_f1_i == `CA53_CRYPTO_OP_SHA256H2) |
                             (crypto_op_f1_i == `CA53_CRYPTO_OP_SHA256SU1));

  assign en_hi_c_data_f2  = crypto_enable_f1_i & advance_pipeline_i &
                            ((crypto_op_f1_i == `CA53_CRYPTO_OP_SHA1SU1)   |
                             (crypto_op_f1_i == `CA53_CRYPTO_OP_SHA256H)   |
                             (crypto_op_f1_i == `CA53_CRYPTO_OP_SHA256H2)  |
                             (crypto_op_f1_i == `CA53_CRYPTO_OP_SHA256SU1));

  always @(posedge clk_crypto)
    if (advance_pipeline_i)
      crypto_enable_f2 <= crypto_enable_f1_i;

  assign en_crypto_op_f2 = crypto_enable_f1_i & advance_pipeline_i;

  always @(posedge clk_crypto)
    if (en_crypto_op_f2) begin
      crypto_op_f2      <= crypto_op_f1_i;
      crypto_a_data_f2  <= nxt_crypto_a_data_f2;
    end

  always @(posedge clk_crypto)
    if (en_lo_bc_data_f2) begin
      crypto_b_data_f2[127: 0] <= crypto_b_data_f1_i;
      crypto_c_data_f2[ 31: 0] <= nxt_crypto_c_data_f2[31: 0];
    end

  always @(posedge clk_crypto)
    if (en_hi_c_data_f2)
      crypto_c_data_f2[127:32] <= nxt_crypto_c_data_f2[127:32];

  //-----------------------------------------------------------------------------
  // F2 pipeline stage
  //-----------------------------------------------------------------------------

  generate for (i = 0 ; i < 16; i = i + 1) begin : g_aes_sbox

    ca53dpu_crypto_aes_sbox u_aes_sbox (
      .crypto_a_data_f2_i     (crypto_a_data_f2[i*8+:8]),
      .aes_fwd_sbox_res_f2_o  (aes_fwd_sbox_res_f2[i*8+:8]),
      .aes_inv_sbox_res_f2_o  (aes_inv_sbox_res_f2[i*8+:8])
    );

  end endgenerate

  assign aes_shiftrows_f2    = {aes_fwd_sbox_res_f2[ 95: 88],  // S'3,3 = S3,2
                                aes_fwd_sbox_res_f2[ 55: 48],  // S'2,3 = S2,1
                                aes_fwd_sbox_res_f2[ 15:  8],  // S'1,3 = S1,0
                                aes_fwd_sbox_res_f2[103: 96],  // S'0,3 = S0,3
                                aes_fwd_sbox_res_f2[ 63: 56],  // S'3,2 = S3,1
                                aes_fwd_sbox_res_f2[ 23: 16],  // S'2,2 = S2,0
                                aes_fwd_sbox_res_f2[111:104],  // S'1,2 = S1,3
                                aes_fwd_sbox_res_f2[ 71: 64],  // S'0,2 = S0,2
                                aes_fwd_sbox_res_f2[ 31: 24],  // S'3,1 = S3,0
                                aes_fwd_sbox_res_f2[119:112],  // S'2,1 = S2,3
                                aes_fwd_sbox_res_f2[ 79: 72],  // S'1,1 = S1,2
                                aes_fwd_sbox_res_f2[ 39: 32],  // S'0,1 = S0,1
                                aes_fwd_sbox_res_f2[127:120],  // S'3,0 = S3,3
                                aes_fwd_sbox_res_f2[ 87: 80],  // S'2,0 = S2,2
                                aes_fwd_sbox_res_f2[ 47: 40],  // S'1,0 = S1,1
                                aes_fwd_sbox_res_f2[  7:  0]}; // S'0,0 = S0,0

  assign aes_invshiftrows_f2 = {aes_inv_sbox_res_f2[ 31: 24],  // S'3,3 = S3,0
                                aes_inv_sbox_res_f2[ 55: 48],  // S'2,3 = S2,1
                                aes_inv_sbox_res_f2[ 79: 72],  // S'1,3 = S1,2
                                aes_inv_sbox_res_f2[103: 96],  // S'0,3 = S0,3
                                aes_inv_sbox_res_f2[127:120],  // S'3,2 = S3,3
                                aes_inv_sbox_res_f2[ 23: 16],  // S'2,2 = S2,0
                                aes_inv_sbox_res_f2[ 47: 40],  // S'1,2 = S1,1
                                aes_inv_sbox_res_f2[ 71: 64],  // S'0,2 = S0,2
                                aes_inv_sbox_res_f2[ 95: 88],  // S'3,1 = S3,2
                                aes_inv_sbox_res_f2[119:112],  // S'2,1 = S2,3
                                aes_inv_sbox_res_f2[ 15:  8],  // S'1,1 = S1,0
                                aes_inv_sbox_res_f2[ 39: 32],  // S'0,1 = S0,1
                                aes_inv_sbox_res_f2[ 63: 56],  // S'3,0 = S3,1
                                aes_inv_sbox_res_f2[ 87: 80],  // S'2,0 = S2,2
                                aes_inv_sbox_res_f2[111:104],  // S'1,0 = S1,3
                                aes_inv_sbox_res_f2[  7:  0]}; // S'0,0 = S0,0

  assign hash_data_f2 = {crypto_c_data_f2, crypto_b_data_f2};

  ca53dpu_crypto_sha1cpm u_sha1cpm_f2 (
    .crypto_op_i      (crypto_op_f2),
    .hash_data_i      (hash_data_f2[159:0]),
    .schedule_data_i  (crypto_a_data_f2[31:0]),
    .sha1cpm_res_o    (sha1cpm_res_f2[159:0])
  );

  ca53dpu_crypto_sha256h u_sha256h_f2 (
    .hash_data_i      (hash_data_f2[255:0]),
    .schedule_data_i  (crypto_a_data_f2[31:0]),
    .sha256h_res_o    (sha256h_res_f2[255:0])
  );

  ca53dpu_crypto_sha256su1 u_sha256su1_f2 (
    .op1_data_i       (crypto_b_data_f2[63:0]),
    .t0_data_i        (crypto_c_data_f2[63:0]),
    .t1_data_i        (crypto_a_data_f2[63:0]),
    .sha256su1_res_o  (sha256su1_res_f2[63:0])
  );

  ca53dpu_crypto_pmull64 u_pmull64 (
    .opa_i          (crypto_a_data_f2[ 63: 0]),
    .opb_i          (crypto_a_data_f2[127:64]),
    .pmull64_res_o  (pmull64_res_f2[126:0])
  );

  assign sha1su1_t_f2 = crypto_a_data_f2[127: 0] ^ { {32{1'b0}}, crypto_c_data_f2[127:32]};

  assign sha1su1_res_f2[ 31: 0] = {sha1su1_t_f2[ 30: 0], sha1su1_t_f2[ 31]};
  assign sha1su1_res_f2[ 63:32] = {sha1su1_t_f2[ 62:32], sha1su1_t_f2[ 63]};
  assign sha1su1_res_f2[ 95:64] = {sha1su1_t_f2[ 94:64], sha1su1_t_f2[ 95]};
  assign sha1su1_res_f2[127:96] = {sha1su1_t_f2[126:96], sha1su1_t_f2[127]} ^ {sha1su1_t_f2[29: 0], sha1su1_t_f2[31:30]};

  assign aes_invmixcols_f2 = (crypto_op_f2 == `CA53_CRYPTO_OP_AESIMC) |
                             (crypto_op_f2 == `CA53_CRYPTO_OP_AESD_AESIMC);

  assign res_sel_a_f2  = (crypto_op_f2 == `CA53_CRYPTO_OP_AESD)    |
                         (crypto_op_f2 == `CA53_CRYPTO_OP_AESE)    |
                         (crypto_op_f2 == `CA53_CRYPTO_OP_PMULL64) |
                         (crypto_op_f2 == `CA53_CRYPTO_OP_SHA1SU1);

  assign res_sel_mc_f2 = (crypto_op_f2 == `CA53_CRYPTO_OP_AESMC)       |
                         (crypto_op_f2 == `CA53_CRYPTO_OP_AESIMC)      |
                         (crypto_op_f2 == `CA53_CRYPTO_OP_AESD_AESIMC) |
                         (crypto_op_f2 == `CA53_CRYPTO_OP_AESE_AESMC);


  always @*
    case (crypto_op_f2)
      `CA53_CRYPTO_OP_SHA1C,
      `CA53_CRYPTO_OP_SHA1P,
      `CA53_CRYPTO_OP_SHA1M,
      `CA53_CRYPTO_OP_SHA256H,
      `CA53_CRYPTO_OP_SHA256H2,
      `CA53_CRYPTO_OP_AESMC,
      `CA53_CRYPTO_OP_AESIMC:
        nxt_crypto_a_data_f3 = crypto_a_data_f2;

      `CA53_CRYPTO_OP_SHA256SU1:
        nxt_crypto_a_data_f3 = { {64{1'b0}}, sha256su1_res_f2};

      `CA53_CRYPTO_OP_AESE,
      `CA53_CRYPTO_OP_AESE_AESMC:
        nxt_crypto_a_data_f3 = aes_shiftrows_f2;

      `CA53_CRYPTO_OP_AESD,
      `CA53_CRYPTO_OP_AESD_AESIMC:
        nxt_crypto_a_data_f3 = aes_invshiftrows_f2;

      `CA53_CRYPTO_OP_PMULL64:
        nxt_crypto_a_data_f3 = {1'b0, pmull64_res_f2};

      `CA53_CRYPTO_OP_SHA1SU1:
        nxt_crypto_a_data_f3 = sha1su1_res_f2;

      default:
        nxt_crypto_a_data_f3 = {128{1'bx}};
    endcase

  always @*
    case (crypto_op_f2)
      `CA53_CRYPTO_OP_SHA1C,
      `CA53_CRYPTO_OP_SHA1P,
      `CA53_CRYPTO_OP_SHA1M: begin
        nxt_crypto_b_data_f3 = sha1cpm_res_f2[127:0];
        nxt_crypto_c_data_f3 = { {96{1'b0}}, sha1cpm_res_f2[159:128]};
      end

      `CA53_CRYPTO_OP_SHA256H,
      `CA53_CRYPTO_OP_SHA256H2: begin
        nxt_crypto_b_data_f3 = sha256h_res_f2[127:  0];
        nxt_crypto_c_data_f3 = sha256h_res_f2[255:128];
      end

      `CA53_CRYPTO_OP_SHA256SU1: begin
        nxt_crypto_b_data_f3 = crypto_b_data_f2;
        nxt_crypto_c_data_f3 = crypto_c_data_f2;
      end

      default: begin
        nxt_crypto_b_data_f3 = {128{1'bx}};
        nxt_crypto_c_data_f3 = {128{1'bx}};
      end
    endcase

  assign en_lo_bc_data_f3 = crypto_enable_f2 & advance_pipeline_i &
                            ((crypto_op_f2 == `CA53_CRYPTO_OP_SHA1M)    |
                             (crypto_op_f2 == `CA53_CRYPTO_OP_SHA1P)    |
                             (crypto_op_f2 == `CA53_CRYPTO_OP_SHA1C)    |
                             (crypto_op_f2 == `CA53_CRYPTO_OP_SHA256H)  |
                             (crypto_op_f2 == `CA53_CRYPTO_OP_SHA256H2) |
                             (crypto_op_f2 == `CA53_CRYPTO_OP_SHA256SU1));

  assign en_hi_c_data_f3  = en_lo_bc_data_f3 &
                            ((crypto_op_f2 == `CA53_CRYPTO_OP_SHA256H)   |
                             (crypto_op_f2 == `CA53_CRYPTO_OP_SHA256H2)  |
                             (crypto_op_f2 == `CA53_CRYPTO_OP_SHA256SU1));

  always @(posedge clk_crypto)
    if (advance_pipeline_i)
      crypto_enable_f3 <= crypto_enable_f2;

  assign en_crypto_op_f3 = crypto_enable_f2 & advance_pipeline_i;

  always @(posedge clk_crypto)
    if (en_crypto_op_f3) begin
      crypto_op_f3      <= crypto_op_f2;
      crypto_a_data_f3  <= nxt_crypto_a_data_f3;
      aes_invmixcols_f3 <= aes_invmixcols_f2;
    end

  always @(posedge clk_crypto or negedge reset_n)
    if (~reset_n) begin
      res_sel_a_f3[1]   <= 1'b1;
      res_sel_a_f3[0]   <= 1'b0;
      res_sel_mc_f3[1]  <= 1'b1;
      res_sel_mc_f3[0]  <= 1'b0;
    end else if (en_crypto_op_f3) begin
      res_sel_a_f3[1]   <= res_sel_a_f2;
      res_sel_a_f3[0]   <= res_sel_a_f2;
      res_sel_mc_f3[1]  <= res_sel_mc_f2;
      res_sel_mc_f3[0]  <= res_sel_mc_f2;
    end

  always @(posedge clk_crypto)
    if (en_lo_bc_data_f3) begin
      crypto_b_data_f3[127: 0] <= nxt_crypto_b_data_f3;
      crypto_c_data_f3[ 31: 0] <= nxt_crypto_c_data_f3[31: 0];
    end

  always @(posedge clk_crypto)
    if (en_hi_c_data_f3)
      crypto_c_data_f3[127:32] <= nxt_crypto_c_data_f3[127:32];

  //-----------------------------------------------------------------------------
  // F3 pipeline stage
  //-----------------------------------------------------------------------------

  ca53dpu_crypto_aes_mixcol u_aes_mixcol_0 (
    .aes_invmixcols_f3_i  (aes_invmixcols_f3),
    .crypto_a_data_f3_i   (crypto_a_data_f3[31: 0]),
    .aes_mixcol_data_f3_o (aes_mixcol_data_f3[31: 0])
  );

  ca53dpu_crypto_aes_mixcol u_aes_mixcol_1 (
    .aes_invmixcols_f3_i  (aes_invmixcols_f3),
    .crypto_a_data_f3_i   (crypto_a_data_f3[63:32]),
    .aes_mixcol_data_f3_o (aes_mixcol_data_f3[63:32])
  );

  ca53dpu_crypto_aes_mixcol u_aes_mixcol_2 (
    .aes_invmixcols_f3_i  (aes_invmixcols_f3),
    .crypto_a_data_f3_i   (crypto_a_data_f3[95:64]),
    .aes_mixcol_data_f3_o (aes_mixcol_data_f3[95:64])
  );

  ca53dpu_crypto_aes_mixcol u_aes_mixcol_3 (
    .aes_invmixcols_f3_i  (aes_invmixcols_f3),
    .crypto_a_data_f3_i   (crypto_a_data_f3[127:96]),
    .aes_mixcol_data_f3_o (aes_mixcol_data_f3[127:96])
  );

  assign hash_data_f3 = {crypto_c_data_f3, crypto_b_data_f3};

  ca53dpu_crypto_sha1cpm u_sha1cpm_f3 (
    .crypto_op_i      (crypto_op_f3),
    .hash_data_i      (hash_data_f3[159:0]),
    .schedule_data_i  (crypto_a_data_f3[63:32]),
    .sha1cpm_res_o    (sha1cpm_res_f3[159:0])
  );

  ca53dpu_crypto_sha256h u_sha256h_f3 (
    .hash_data_i      (hash_data_f3[255:0]),
    .schedule_data_i  (crypto_a_data_f3[63:32]),
    .sha256h_res_o    (sha256h_res_f3[255:0])
  );

  ca53dpu_crypto_sha256su1 u_sha256su1_f3 (
    .op1_data_i       (crypto_b_data_f3[127:64]),
    .t0_data_i        (crypto_c_data_f3[127:64]),
    .t1_data_i        (crypto_a_data_f3[63:0]),
    .sha256su1_res_o  (sha256su1_res_f3[63:0])
  );

  // Produce the "early" result for those operations which produce a result in F3

  assign crypto_data_f3_o[ 63: 0] = ({64{res_sel_a_f3[0]}}  & crypto_a_data_f3[ 63: 0]) |
                                    ({64{res_sel_mc_f3[0]}} & aes_mixcol_data_f3[ 63: 0]);  

  assign crypto_data_f3_o[127:64] = ({64{res_sel_a_f3[1]}}  & crypto_a_data_f3[127:64]) |
                                    ({64{res_sel_mc_f3[1]}} & aes_mixcol_data_f3[127:64]);  

  always @*
    case (crypto_op_f3)
      `CA53_CRYPTO_OP_SHA1C,
      `CA53_CRYPTO_OP_SHA1P,
      `CA53_CRYPTO_OP_SHA1M: begin
        nxt_crypto_b_data_f4 = sha1cpm_res_f3[127:0];
        nxt_crypto_c_data_f4 = { {96{1'b0}}, sha1cpm_res_f3[159:128]};
      end

      `CA53_CRYPTO_OP_SHA256H,
      `CA53_CRYPTO_OP_SHA256H2: begin
        nxt_crypto_b_data_f4 = sha256h_res_f3[127:  0];
        nxt_crypto_c_data_f4 = sha256h_res_f3[255:128];
      end

      `CA53_CRYPTO_OP_SHA256SU1: begin
        nxt_crypto_b_data_f4 = {sha256su1_res_f3[63:0], crypto_a_data_f3[63:0]};
        nxt_crypto_c_data_f4 = {128{1'b0}};
      end

      default: begin
        nxt_crypto_b_data_f4 = {128{1'bx}};
        nxt_crypto_c_data_f4 = {128{1'bx}};
      end
    endcase

  assign nxt_crypto_enable_f4 = crypto_enable_f3 & advance_pipeline_i &
                                ((crypto_op_f3 == `CA53_CRYPTO_OP_SHA1C)    |
                                 (crypto_op_f3 == `CA53_CRYPTO_OP_SHA1P)    |
                                 (crypto_op_f3 == `CA53_CRYPTO_OP_SHA1M)    |
                                 (crypto_op_f3 == `CA53_CRYPTO_OP_SHA256H)  |
                                 (crypto_op_f3 == `CA53_CRYPTO_OP_SHA256H2) |
                                 (crypto_op_f3 == `CA53_CRYPTO_OP_SHA256SU1));

  assign en_hi_c_data_f4      = nxt_crypto_enable_f4 &
                                ((crypto_op_f3 == `CA53_CRYPTO_OP_SHA256H)  |
                                 (crypto_op_f3 == `CA53_CRYPTO_OP_SHA256H2));

  always @(posedge clk_crypto)
    if (advance_pipeline_i)
      crypto_enable_f4 <= nxt_crypto_enable_f4;

  always @(posedge clk_crypto)
    if (nxt_crypto_enable_f4) begin
      crypto_op_f4             <= crypto_op_f3;
      crypto_a_data_f4[127:64] <= crypto_a_data_f3[127:64];
      crypto_b_data_f4[127: 0] <= nxt_crypto_b_data_f4;
      crypto_c_data_f4[ 31: 0] <= nxt_crypto_c_data_f4[31: 0];
    end

  always @(posedge clk_crypto)
    if (en_hi_c_data_f4)
      crypto_c_data_f4[127:32] <= nxt_crypto_c_data_f4[127:32];

  //-----------------------------------------------------------------------------
  // F4 pipeline stage
  //-----------------------------------------------------------------------------

  assign hash_data_f4 = {crypto_c_data_f4, crypto_b_data_f4};

  ca53dpu_crypto_sha1cpm u_sha1cpm_f4 (
    .crypto_op_i      (crypto_op_f4),
    .hash_data_i      (hash_data_f4[159:0]),
    .schedule_data_i  (crypto_a_data_f4[95:64]),
    .sha1cpm_res_o    (sha1cpm_res_f4[159:0])
  );

  ca53dpu_crypto_sha256h u_sha256h_f4 (
    .hash_data_i      (hash_data_f4[255:0]),
    .schedule_data_i  (crypto_a_data_f4[95:64]),
    .sha256h_res_o    (sha256h_res_f4[255:0])
  );

  always @*
    case (crypto_op_f4)
      `CA53_CRYPTO_OP_SHA1C,
      `CA53_CRYPTO_OP_SHA1P,
      `CA53_CRYPTO_OP_SHA1M: begin
        nxt_crypto_b_data_f5 = sha1cpm_res_f4[95:0];
        nxt_crypto_c_data_f5 = { {64{1'b0}}, sha1cpm_res_f4[159:96]};
      end

      // For SHA256, {h', g', f', e'} depends on {h, g, f, e, d}, while
      // {d', c', b', a'} depends on {h, g, f, e, c, b, a} - therefore
      // it's not necessary to register both d and c

      `CA53_CRYPTO_OP_SHA256H: begin
        nxt_crypto_b_data_f5 = sha256h_res_f4[ 95:  0];
        nxt_crypto_c_data_f5 = sha256h_res_f4[255:128];
      end

       `CA53_CRYPTO_OP_SHA256H2: begin
        nxt_crypto_b_data_f5 = {sha256h_res_f4[127: 96], sha256h_res_f4[63: 0]};
        nxt_crypto_c_data_f5 = sha256h_res_f4[255:128];
      end

       `CA53_CRYPTO_OP_SHA256SU1: begin
        nxt_crypto_b_data_f5 = crypto_b_data_f4[95:0];
        nxt_crypto_c_data_f5 = { {96{1'b0}}, crypto_b_data_f4[127:96]};
       end

      default: begin
        nxt_crypto_b_data_f5 = { 96{1'bx}};
        nxt_crypto_c_data_f5 = {128{1'bx}};
      end
    endcase

  assign en_hi_c_data_f5 = crypto_enable_f4 & advance_pipeline_i &
                           ((crypto_op_f4 == `CA53_CRYPTO_OP_SHA256H) |
                            (crypto_op_f4 == `CA53_CRYPTO_OP_SHA256H2));

  assign en_crypto_op_f4 = crypto_enable_f4 & advance_pipeline_i;

  always @(posedge clk_crypto)
    if (en_crypto_op_f4) begin
      crypto_op_f5             <= crypto_op_f4;
      crypto_a_data_f5[127:96] <= crypto_a_data_f4[127:96];
      crypto_b_data_f5[ 95: 0] <= nxt_crypto_b_data_f5;
      crypto_c_data_f5[ 63: 0] <= nxt_crypto_c_data_f5[63: 0];
    end

  always @(posedge clk_crypto)
    if (en_hi_c_data_f5)
      crypto_c_data_f5[127:64] <= nxt_crypto_c_data_f5[127:64];

  //-----------------------------------------------------------------------------
  // F5 pipeline stage
  //-----------------------------------------------------------------------------

  assign hash_data_sha1_f5 = {crypto_c_data_f5[63:0], crypto_b_data_f5[95:0]};

  ca53dpu_crypto_sha1cpm u_sha1cpm_f5 (
    .crypto_op_i      (crypto_op_f5),
    .hash_data_i      (hash_data_sha1_f5[159:0]),
    .schedule_data_i  (crypto_a_data_f5[127:96]),
    .sha1cpm_res_o    (sha1cpm_res_f5[159:0])
  );

  assign hash_data_sha256_f5 = {crypto_c_data_f5[127:0], crypto_b_data_f5[95:64], crypto_b_data_f5[95:0]};

  ca53dpu_crypto_sha256h u_sha256h_f5 (
    .hash_data_i      (hash_data_sha256_f5[255:0]),
    .schedule_data_i  (crypto_a_data_f5[127:96]),
    .sha256h_res_o    (sha256h_res_f5[255:0])
  );

  always @*
    case (crypto_op_f5)
      `CA53_CRYPTO_OP_SHA1C,
      `CA53_CRYPTO_OP_SHA1P,
      `CA53_CRYPTO_OP_SHA1M:
        crypto_data_f5_o = sha1cpm_res_f5[127:  0];

      `CA53_CRYPTO_OP_SHA256H:
        crypto_data_f5_o = sha256h_res_f5[127:  0];

      `CA53_CRYPTO_OP_SHA256H2:
        crypto_data_f5_o = sha256h_res_f5[255:128];

      `CA53_CRYPTO_OP_SHA256SU1:
        crypto_data_f5_o = {crypto_c_data_f5[31:0], crypto_b_data_f5[95:0]};

      default:
        crypto_data_f5_o = {128{1'bx}};
    endcase

  // Generate active term for clock gating

  assign crypto_active_o = crypto_enable_f2 | nxt_crypto_enable_f4;

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: advance_pipeline_i")
  u_ovl_x_advance_pipeline_i (.clk       (clk_crypto),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (advance_pipeline_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_crypto_op_f2")
  u_ovl_x_en_crypto_op_f2 (.clk       (clk_crypto),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (en_crypto_op_f2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_crypto_op_f3")
  u_ovl_x_en_crypto_op_f3 (.clk       (clk_crypto),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (en_crypto_op_f3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_crypto_op_f4")
  u_ovl_x_en_crypto_op_f4 (.clk       (clk_crypto),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (en_crypto_op_f4));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_hi_c_data_f2")
  u_ovl_x_en_hi_c_data_f2 (.clk       (clk_crypto),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (en_hi_c_data_f2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_hi_c_data_f3")
  u_ovl_x_en_hi_c_data_f3 (.clk       (clk_crypto),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (en_hi_c_data_f3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_hi_c_data_f4")
  u_ovl_x_en_hi_c_data_f4 (.clk       (clk_crypto),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (en_hi_c_data_f4));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_hi_c_data_f5")
  u_ovl_x_en_hi_c_data_f5 (.clk       (clk_crypto),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (en_hi_c_data_f5));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_lo_bc_data_f2")
  u_ovl_x_en_lo_bc_data_f2 (.clk       (clk_crypto),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (en_lo_bc_data_f2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_lo_bc_data_f3")
  u_ovl_x_en_lo_bc_data_f3 (.clk       (clk_crypto),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (en_lo_bc_data_f3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: nxt_crypto_enable_f4")
  u_ovl_x_nxt_crypto_enable_f4 (.clk       (clk_crypto),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (nxt_crypto_enable_f4));

  // ------------------------------------------------------
  // Assertions on valid states in case statements
  // ------------------------------------------------------

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"crypto_op_f1 is in an illegal state")
    ovl_crypto_op_f1_illegal_state (.clk              (clk_crypto),
                                    .reset_n          (reset_n),
                                    .antecedent_expr  (crypto_enable_f1_i),
                                    .consequent_expr  ((crypto_op_f1_i == `CA53_CRYPTO_OP_SHA1C)       |
                                                       (crypto_op_f1_i == `CA53_CRYPTO_OP_SHA1P)       |
                                                       (crypto_op_f1_i == `CA53_CRYPTO_OP_SHA1M)       |
                                                       (crypto_op_f1_i == `CA53_CRYPTO_OP_SHA1SU1)     |
                                                       (crypto_op_f1_i == `CA53_CRYPTO_OP_SHA256H)     |
                                                       (crypto_op_f1_i == `CA53_CRYPTO_OP_SHA256H2)    |
                                                       (crypto_op_f1_i == `CA53_CRYPTO_OP_AESMC)       |
                                                       (crypto_op_f1_i == `CA53_CRYPTO_OP_AESIMC)      |
                                                       (crypto_op_f1_i == `CA53_CRYPTO_OP_SHA256SU1)   |
                                                       (crypto_op_f1_i == `CA53_CRYPTO_OP_AESE)        |
                                                       (crypto_op_f1_i == `CA53_CRYPTO_OP_AESD)        |
                                                       (crypto_op_f1_i == `CA53_CRYPTO_OP_AESE_AESMC)  |
                                                       (crypto_op_f1_i == `CA53_CRYPTO_OP_AESD_AESIMC) |
                                                       (crypto_op_f1_i == `CA53_CRYPTO_OP_PMULL64)));

`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/

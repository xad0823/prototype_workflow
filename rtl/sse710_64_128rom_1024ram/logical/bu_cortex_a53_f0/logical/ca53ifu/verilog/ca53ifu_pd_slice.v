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
//      Checked In          : $Date: 2011-12-16 14:57:00 +0000 (Fri, 16 Dec 2011) $
//
//      Revision            : $Revision: 195717 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Pre-decoder logic transforming an AXI 64 bit data into 80 bit of
// pre-decoded data.
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53ifu_pd_slice
  (// Inputs
   input         clk,
   input         reset_n, // Global reset

   input         pd_a32_data_en_i, // Enable term for a32
   input         pd_a64_data_en_i, // Enable term for a64
   input         pd_t32_data_en_0_i, // Enable term for t32 Predecoder0
   input         pd_t32_data_en_1_i, // Enable term for t32 Predecoder1

   input [1:0]   pd_pcoffset_i, // PC-offset
   input         ifu_rready_i,
   input [63:0]  biu_i_rdata_i, // external data
   input         ctl_pd_ack_i,
   input [39:0]  dbg_data_i,
   input         dbg_data_req_i,

   // Outputs
   output        pd_data_req_pd1_o,
   output [79:0] pd_data_o
   );

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [79:0]     pd_data_a32;
  wire [28:0]     pd_a32_to_t32_l;
  wire            pd_a32_armonly_l;
  wire [5:0]      pd_a32_sideband_l;
  wire [28:0]     pd_a32_to_t32_h;
  wire            pd_a32_armonly_h;
  wire [5:0]      pd_a32_sideband_h;
  wire            pd_a64_sf_l;
  wire            pd_a64_m_l;
  wire            pd_a64_n_l;
  wire            pd_a64_d_l;


  wire [79:0]     pd_data_a64;
  wire [28:0]     pd_a64_to_t32_l;
  wire            pd_a64_armonly_l;
  wire [5:0]      pd_a64_sideband_l;
  wire [28:0]     pd_a64_to_t32_h;
  wire            pd_a64_armonly_h;
  wire [5:0]      pd_a64_sideband_h;
  wire            pd_a64_sf_h;
  wire            pd_a64_m_h;
  wire            pd_a64_n_h;
  wire            pd_a64_d_h;

  wire [79:0]     pd_data_thumb;
  wire            pd_t32_data_req_pd1;

  wire            pd_a64_req;
  wire            pd_a64_en;
  wire            pd_a32_req;
  wire            pd_a32_en;

  // -----------------------------
  // Reg declarations
  // -----------------------------
  reg [63:0]     pd_rdata_a32;
  reg [63:0]     pd_rdata_a64;
  reg            pd_a32_data_req_pd1;
  reg            pd_a64_data_req_pd1;

  // ------------------------------------------------------
  // A32 pre-decoder
  // ------------------------------------------------------
  // PD0 cycle
  always @(posedge clk)
    if (pd_a32_data_en_i)
      pd_rdata_a32[63:0] <= biu_i_rdata_i[63:0];

  // PD1 cycle Enable for A32

  assign pd_a32_req = pd_a32_data_en_i | (pd_a32_data_req_pd1 & !ctl_pd_ack_i);
  assign pd_a32_en  = pd_a32_data_en_i | (pd_a32_data_req_pd1 & ctl_pd_ack_i);


  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      pd_a32_data_req_pd1 <= 1'b0;
    else if (pd_a32_en)
      pd_a32_data_req_pd1 <= pd_a32_req;


  ca53ifu_pd_a32 u_ca53ifu_pd_a32_0 (.raw_encoding_i (pd_rdata_a32[31:0]),
                                     .a32_to_t32_o   (pd_a32_to_t32_l[28:0]),
                                     .arm_only_o     (pd_a32_armonly_l),
                                     .sideband_o     (pd_a32_sideband_l));

  ca53ifu_pd_a32 u_ca53ifu_pd_a32_1(.raw_encoding_i (pd_rdata_a32[63:32]),
                                    .a32_to_t32_o   (pd_a32_to_t32_h[28:0]),
                                    .arm_only_o     (pd_a32_armonly_h),
                                    .sideband_o     (pd_a32_sideband_h));

  // Pre-Decode Data
  // 3|3|3|3|3|3|3|3|3|3|2|2|2|2|2|2|2|2|2|2|1|1|1|1|1|1|1|1|1|1|
  // 9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
  // -+-+-+-+-------------------------------+-+-----------+-------------------------+
  // N|Z|C|V|         Opcode[15:0]          |A|  Sid[5:0] |     Opcode[28:16]       |
  // -+-+-+-+---------------------------------------------+-------------------------+

  assign pd_data_a32[79]     = pd_rdata_a32[63];
  assign pd_data_a32[78]     = pd_rdata_a32[62];
  assign pd_data_a32[77]     = pd_rdata_a32[61];
  assign pd_data_a32[76]     = pd_rdata_a32[60];
  assign pd_data_a32[75:60]  = pd_a32_to_t32_h[15:0];
  assign pd_data_a32[59]     = pd_a32_armonly_h;
  assign pd_data_a32[58:53]  = pd_a32_sideband_h;
  assign pd_data_a32[52:40]  = pd_a32_to_t32_h[28:16];

  assign pd_data_a32[39]     = pd_rdata_a32[31];
  assign pd_data_a32[38]     = pd_rdata_a32[30];
  assign pd_data_a32[37]     = pd_rdata_a32[29];
  assign pd_data_a32[36]     = pd_rdata_a32[28];
  assign pd_data_a32[35:20]  = pd_a32_to_t32_l[15:0];
  assign pd_data_a32[19]     = pd_a32_armonly_l;
  assign pd_data_a32[18:13]  = pd_a32_sideband_l;
  assign pd_data_a32[12:0]   = pd_a32_to_t32_l[28:16];

  // ------------------------------------------------------
  // A64 pre-decoder
  // ------------------------------------------------------
  // PD1 cycle Enable for A64
  assign pd_a64_req = pd_a64_data_en_i | (pd_a64_data_req_pd1 & !ctl_pd_ack_i);
  assign pd_a64_en  = pd_a64_data_en_i | (pd_a64_data_req_pd1 &  ctl_pd_ack_i);

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      pd_a64_data_req_pd1 <= 1'b0;
    else if (pd_a64_en)
      pd_a64_data_req_pd1 <= pd_a64_req;

  //PD0 cycle
  always @(posedge clk)
    if (pd_a64_data_en_i)
      pd_rdata_a64[63:0] <= biu_i_rdata_i[63:0];

  ca53ifu_pd_a64 u_ca53ifu_pd_a64_0(.raw_encoding_i (pd_rdata_a64[31:0]),
                                    .a64_to_t32_o   (pd_a64_to_t32_l[28:0]),
                                    .arm_only_o     (pd_a64_armonly_l),
                                    .sideband_o     (pd_a64_sideband_l),
                                    .sf_o           (pd_a64_sf_l),
                                    .m_o            (pd_a64_m_l),
                                    .n_o            (pd_a64_n_l),
                                    .d_o            (pd_a64_d_l));

  ca53ifu_pd_a64 u_ca53ifu_pd_a64_1(.raw_encoding_i (pd_rdata_a64[63:32]),
                                    .a64_to_t32_o   (pd_a64_to_t32_h[28:0]),
                                    .arm_only_o     (pd_a64_armonly_h),
                                    .sideband_o     (pd_a64_sideband_h),
                                    .sf_o           (pd_a64_sf_h),
                                    .m_o            (pd_a64_m_h),
                                    .n_o            (pd_a64_n_h),
                                    .d_o            (pd_a64_d_h));
  // Pre-Decode Data
  // 3|3|3|3|3|3|3|3|3|3|2|2|2|2|2|2|2|2|2|2|1|1|1|1|1|1|1|1|1|1|
  // 9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
  // -+-+-+-+-------------------------------+-+-----------+-------------------------+
  //sf|m|n|d|         Opcode[15:0]          |A|  Sid[5:0] |     Opcode[28:16]       |
  // -+-+-+-+---------------------------------------------+-------------------------+

  assign pd_data_a64[79]     = pd_a64_sf_h;
  assign pd_data_a64[78]     = pd_a64_m_h;
  assign pd_data_a64[77]     = pd_a64_n_h;
  assign pd_data_a64[76]     = pd_a64_d_h;
  assign pd_data_a64[75:60]  = pd_a64_to_t32_h[15:0];
  assign pd_data_a64[59]     = pd_a64_armonly_h;
  assign pd_data_a64[58:53]  = pd_a64_sideband_h;
  assign pd_data_a64[52:40]  = pd_a64_to_t32_h[28:16];

  assign pd_data_a64[39]     = pd_a64_sf_l;
  assign pd_data_a64[38]     = pd_a64_m_l;
  assign pd_data_a64[37]     = pd_a64_n_l;
  assign pd_data_a64[36]     = pd_a64_d_l;
  assign pd_data_a64[35:20]  = pd_a64_to_t32_l[15:0];
  assign pd_data_a64[19]     = pd_a64_armonly_l;
  assign pd_data_a64[18:13]  = pd_a64_sideband_l;
  assign pd_data_a64[12:0]   = pd_a64_to_t32_l[28:16];

  // ------------------------------------------------------
  // T32 pre-decoder
  // ------------------------------------------------------
  // final mux between ISAs is embedded within the final T32
  // mux for timing reason.

  ca53ifu_pd_thumb u_ca53ifu_pd_thumb_0
   (//Inputs
    .clk                     (clk),
    .reset_n                 (reset_n),
    .pd_t32_data_en_0_i      (pd_t32_data_en_0_i),
    .pd_t32_data_en_1_i      (pd_t32_data_en_1_i),
    .pd_pcoffset_i           (pd_pcoffset_i),
    .ifu_rready_i            (ifu_rready_i),
    .rdata_thumb_i           (biu_i_rdata_i),
    .ctl_pd_ack_i            (ctl_pd_ack_i),
    // Outputs
    .pd_data_thumb_o         (pd_data_thumb),
    .pd_t32_data_req_pd1_o   (pd_t32_data_req_pd1)
    );

  // outputs



  assign pd_data_req_pd1_o = pd_t32_data_req_pd1 | pd_a64_data_req_pd1 | pd_a32_data_req_pd1 | dbg_data_req_i;
  assign pd_data_o        = ({80{pd_t32_data_req_pd1}} & pd_data_thumb) |
                            ({80{pd_a64_data_req_pd1}} & pd_data_a64) |
                            ({80{pd_a32_data_req_pd1}} & pd_data_a32) |
                            ({80{dbg_data_req_i}} & {{40{1'b0}},dbg_data_i});

  // ------------------------------------------------------
  // OVL
  // ------------------------------------------------------
`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pd_a32_en")
  u_ovl_x_pd_a32_en (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (pd_a32_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pd_a64_en")
  u_ovl_x_pd_a64_en (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (pd_a64_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pd_a32_data_en_i")
  u_ovl_x_pd_a32_data_en_i (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (pd_a32_data_en_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pd_a64_data_en_i")
  u_ovl_x_pd_a64_data_en_i (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (pd_a64_data_en_i));


  // Check that inputs of casez statements in the A32 and A64 decoders are never
  // unknown during a handshake.
  assert_never_unknown #(`OVL_FATAL, 32, `OVL_ASSERT, "Casez unknown check on u_ca53ifu_pd_a64_0.raw_encoding_i")
    u_ovl_pd_a64_0_casez  (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (pd_a64_data_req_pd1),
                           .test_expr (u_ca53ifu_pd_a64_0.raw_encoding_i));

  assert_never_unknown #(`OVL_FATAL, 32, `OVL_ASSERT, "Casez unknown check on u_ca53ifu_pd_a64_1.raw_encoding_i")
    u_ovl_pd_a64_1_casez  (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (pd_a64_data_req_pd1),
                           .test_expr (u_ca53ifu_pd_a64_1.raw_encoding_i));

  assert_never_unknown #(`OVL_FATAL, 28, `OVL_ASSERT, "Casez unknown check on u_ca53ifu_pd_a32_0.raw_encoding_i")
    u_ovl_pd_a32_0_casez_raw  (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (pd_a32_data_req_pd1),
                               .test_expr (u_ca53ifu_pd_a32_0.raw_encoding_i[27:0]));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Casez unknown check on u_ca53ifu_pd_a32_0.cond_code_nv")
    u_ovl_pd_a32_0_casez_ccnv (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (pd_a32_data_req_pd1),
                               .test_expr (u_ca53ifu_pd_a32_0.cond_code_nv));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Casez unknown check on u_ca53ifu_pd_a32_0.sat_arm_only")
    u_ovl_pd_a32_0_casez_ao  (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (pd_a32_data_req_pd1),
                              .test_expr (u_ca53ifu_pd_a32_0.sat_arm_only));

  assert_never_unknown #(`OVL_FATAL, 28, `OVL_ASSERT, "Casez unknown check on u_ca53ifu_pd_a32_1.raw_encoding_i")
    u_ovl_pd_a32_1_casez     (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (pd_a32_data_req_pd1),
                              .test_expr (u_ca53ifu_pd_a32_1.raw_encoding_i[27:0]));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Casez unknown check on u_ca53ifu_pd_a32_1.cond_code_nv")
    u_ovl_pd_a32_1_casez_ccnv (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (pd_a32_data_req_pd1),
                               .test_expr (u_ca53ifu_pd_a32_1.cond_code_nv));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Casez unknown check on u_ca53ifu_pd_a32_1.sat_arm_only")
    u_ovl_pd_a32_1_casez_ao   (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (pd_a32_data_req_pd1),
                               .test_expr (u_ca53ifu_pd_a32_1.sat_arm_only));
`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/

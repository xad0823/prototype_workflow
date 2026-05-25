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


module sse710_bas_ic_top
  (
  aclk,
  aresetn,

  qactive_cg0,
  qreqn_cg0,
  qacceptn_cg0,
  qdeny_cg0,

  qactive_cg1,
  qreqn_cg1,
  qacceptn_cg1,
  qdeny_cg1,

  tvalid_dti_dn_s0,
  tready_dti_dn_s0,
  tdata_dti_dn_s0,
  tkeep_dti_dn_s0,
  tid_dti_dn_s0,
  tlast_dti_dn_s0,

  tvalid_dti_dn_s1,
  tready_dti_dn_s1,
  tdata_dti_dn_s1,
  tkeep_dti_dn_s1,
  tid_dti_dn_s1,
  tlast_dti_dn_s1,

  tvalid_dti_dn_s2,
  tready_dti_dn_s2,
  tdata_dti_dn_s2,
  tkeep_dti_dn_s2,
  tid_dti_dn_s2,
  tlast_dti_dn_s2,

  tvalid_dti_dn_s3,
  tready_dti_dn_s3,
  tdata_dti_dn_s3,
  tkeep_dti_dn_s3,
  tid_dti_dn_s3,
  tlast_dti_dn_s3,

  tvalid_dti_dn_s4,
  tready_dti_dn_s4,
  tdata_dti_dn_s4,
  tkeep_dti_dn_s4,
  tid_dti_dn_s4,
  tlast_dti_dn_s4,

  tvalid_dti_dn_s5,
  tready_dti_dn_s5,
  tdata_dti_dn_s5,
  tkeep_dti_dn_s5,
  tid_dti_dn_s5,
  tlast_dti_dn_s5,

  tvalid_dti_dn_s6,
  tready_dti_dn_s6,
  tdata_dti_dn_s6,
  tkeep_dti_dn_s6,
  tid_dti_dn_s6,
  tlast_dti_dn_s6,

  tvalid_dti_dn_s7,
  tready_dti_dn_s7,
  tdata_dti_dn_s7,
  tkeep_dti_dn_s7,
  tid_dti_dn_s7,
  tlast_dti_dn_s7,

  tvalid_dti_dn_s8,
  tready_dti_dn_s8,
  tdata_dti_dn_s8,
  tkeep_dti_dn_s8,
  tid_dti_dn_s8,
  tlast_dti_dn_s8,

  tvalid_dti_dn_s9,
  tready_dti_dn_s9,
  tdata_dti_dn_s9,
  tkeep_dti_dn_s9,
  tid_dti_dn_s9,
  tlast_dti_dn_s9,

  tvalid_dti_dn_s10,
  tready_dti_dn_s10,
  tdata_dti_dn_s10,
  tkeep_dti_dn_s10,
  tid_dti_dn_s10,
  tlast_dti_dn_s10,

  tvalid_dti_dn_s11,
  tready_dti_dn_s11,
  tdata_dti_dn_s11,
  tkeep_dti_dn_s11,
  tid_dti_dn_s11,
  tlast_dti_dn_s11,

  tvalid_dti_dn_s12,
  tready_dti_dn_s12,
  tdata_dti_dn_s12,
  tkeep_dti_dn_s12,
  tid_dti_dn_s12,
  tlast_dti_dn_s12,

  tvalid_dti_dn_m,
  tready_dti_dn_m,
  tdata_dti_dn_m,
  tkeep_dti_dn_m,
  tid_dti_dn_m,
  tlast_dti_dn_m,

  tvalid_dti_up_s0,
  tready_dti_up_s0,
  tdata_dti_up_s0,
  tkeep_dti_up_s0,
  tdest_dti_up_s0,
  tlast_dti_up_s0,

  tvalid_dti_up_s1,
  tready_dti_up_s1,
  tdata_dti_up_s1,
  tkeep_dti_up_s1,
  tdest_dti_up_s1,
  tlast_dti_up_s1,

  tvalid_dti_up_s2,
  tready_dti_up_s2,
  tdata_dti_up_s2,
  tkeep_dti_up_s2,
  tdest_dti_up_s2,
  tlast_dti_up_s2,

  tvalid_dti_up_s3,
  tready_dti_up_s3,
  tdata_dti_up_s3,
  tkeep_dti_up_s3,
  tdest_dti_up_s3,
  tlast_dti_up_s3,

  tvalid_dti_up_s4,
  tready_dti_up_s4,
  tdata_dti_up_s4,
  tkeep_dti_up_s4,
  tdest_dti_up_s4,
  tlast_dti_up_s4,

  tvalid_dti_up_s5,
  tready_dti_up_s5,
  tdata_dti_up_s5,
  tkeep_dti_up_s5,
  tdest_dti_up_s5,
  tlast_dti_up_s5,

  tvalid_dti_up_s6,
  tready_dti_up_s6,
  tdata_dti_up_s6,
  tkeep_dti_up_s6,
  tdest_dti_up_s6,
  tlast_dti_up_s6,

  tvalid_dti_up_s7,
  tready_dti_up_s7,
  tdata_dti_up_s7,
  tkeep_dti_up_s7,
  tdest_dti_up_s7,
  tlast_dti_up_s7,

  tvalid_dti_up_s8,
  tready_dti_up_s8,
  tdata_dti_up_s8,
  tkeep_dti_up_s8,
  tdest_dti_up_s8,
  tlast_dti_up_s8,

  tvalid_dti_up_s9,
  tready_dti_up_s9,
  tdata_dti_up_s9,
  tkeep_dti_up_s9,
  tdest_dti_up_s9,
  tlast_dti_up_s9,

  tvalid_dti_up_s10,
  tready_dti_up_s10,
  tdata_dti_up_s10,
  tkeep_dti_up_s10,
  tdest_dti_up_s10,
  tlast_dti_up_s10,

  tvalid_dti_up_s11,
  tready_dti_up_s11,
  tdata_dti_up_s11,
  tkeep_dti_up_s11,
  tdest_dti_up_s11,
  tlast_dti_up_s11,

  tvalid_dti_up_s12,
  tready_dti_up_s12,
  tdata_dti_up_s12,
  tkeep_dti_up_s12,
  tdest_dti_up_s12,
  tlast_dti_up_s12,

  tvalid_dti_up_m,
  tready_dti_up_m,
  tdata_dti_up_m,
  tkeep_dti_up_m,
  tdest_dti_up_m,
  tlast_dti_up_m,

  twakeup_dti_dn_s0,
  twakeup_dti_dn_s1,
  twakeup_dti_dn_s2,
  twakeup_dti_dn_s3,
  twakeup_dti_dn_s4,
  twakeup_dti_dn_s5,
  twakeup_dti_dn_s6,
  twakeup_dti_dn_s7,
  twakeup_dti_dn_s8,
  twakeup_dti_dn_s9,
  twakeup_dti_dn_s10,
  twakeup_dti_dn_s11,
  twakeup_dti_dn_s12,
  twakeup_dti_dn_m,

  twakeup_dti_up_s0,
  twakeup_dti_up_s1,
  twakeup_dti_up_s2,
  twakeup_dti_up_s3,
  twakeup_dti_up_s4,
  twakeup_dti_up_s5,
  twakeup_dti_up_s6,
  twakeup_dti_up_s7,
  twakeup_dti_up_s8,
  twakeup_dti_up_s9,
  twakeup_dti_up_s10,
  twakeup_dti_up_s11,
  twakeup_dti_up_s12,
  twakeup_dti_up_m
  );

  parameter DATA_WIDTH = 8;
  parameter ID_WIDTH   = 2;

  localparam KEEP_WIDTH = DATA_WIDTH / 8;
  localparam SID_WIDTH = ID_WIDTH;
  localparam MID_WIDTH = ID_WIDTH;


  input  wire aclk;
  input  wire aresetn;

  output  wire   qactive_cg0;
  input   wire   qreqn_cg0;
  output  wire   qacceptn_cg0;
  output  wire   qdeny_cg0;

  output  wire   qactive_cg1;
  input   wire   qreqn_cg1;
  output  wire   qacceptn_cg1;
  output  wire   qdeny_cg1;


  input  wire                  tvalid_dti_dn_s0;
  output wire                  tready_dti_dn_s0;
  input  wire [DATA_WIDTH-1:0] tdata_dti_dn_s0;
  input  wire [KEEP_WIDTH-1:0] tkeep_dti_dn_s0;
  input  wire  [SID_WIDTH-1:0] tid_dti_dn_s0;
  input  wire                  tlast_dti_dn_s0;

  input  wire                  tvalid_dti_dn_s1;
  output wire                  tready_dti_dn_s1;
  input  wire [DATA_WIDTH-1:0] tdata_dti_dn_s1;
  input  wire [KEEP_WIDTH-1:0] tkeep_dti_dn_s1;
  input  wire  [SID_WIDTH-1:0] tid_dti_dn_s1;
  input  wire                  tlast_dti_dn_s1;

  input  wire                  tvalid_dti_dn_s2;
  output wire                  tready_dti_dn_s2;
  input  wire [DATA_WIDTH-1:0] tdata_dti_dn_s2;
  input  wire [KEEP_WIDTH-1:0] tkeep_dti_dn_s2;
  input  wire  [SID_WIDTH-1:0] tid_dti_dn_s2;
  input  wire                  tlast_dti_dn_s2;

  input  wire                  tvalid_dti_dn_s3;
  output wire                  tready_dti_dn_s3;
  input  wire [DATA_WIDTH-1:0] tdata_dti_dn_s3;
  input  wire [KEEP_WIDTH-1:0] tkeep_dti_dn_s3;
  input  wire  [SID_WIDTH-1:0] tid_dti_dn_s3;
  input  wire                  tlast_dti_dn_s3;

  input  wire                  tvalid_dti_dn_s4;
  output wire                  tready_dti_dn_s4;
  input  wire [DATA_WIDTH-1:0] tdata_dti_dn_s4;
  input  wire [KEEP_WIDTH-1:0] tkeep_dti_dn_s4;
  input  wire  [SID_WIDTH-1:0] tid_dti_dn_s4;
  input  wire                  tlast_dti_dn_s4;

  input  wire                  tvalid_dti_dn_s5;
  output wire                  tready_dti_dn_s5;
  input  wire [DATA_WIDTH-1:0] tdata_dti_dn_s5;
  input  wire [KEEP_WIDTH-1:0] tkeep_dti_dn_s5;
  input  wire  [SID_WIDTH-1:0] tid_dti_dn_s5;
  input  wire                  tlast_dti_dn_s5;

  input  wire                  tvalid_dti_dn_s6;
  output wire                  tready_dti_dn_s6;
  input  wire [DATA_WIDTH-1:0] tdata_dti_dn_s6;
  input  wire [KEEP_WIDTH-1:0] tkeep_dti_dn_s6;
  input  wire  [SID_WIDTH-1:0] tid_dti_dn_s6;
  input  wire                  tlast_dti_dn_s6;

  input  wire                  tvalid_dti_dn_s7;
  output wire                  tready_dti_dn_s7;
  input  wire [DATA_WIDTH-1:0] tdata_dti_dn_s7;
  input  wire [KEEP_WIDTH-1:0] tkeep_dti_dn_s7;
  input  wire  [SID_WIDTH-1:0] tid_dti_dn_s7;
  input  wire                  tlast_dti_dn_s7;

  input  wire                  tvalid_dti_dn_s8;
  output wire                  tready_dti_dn_s8;
  input  wire [DATA_WIDTH-1:0] tdata_dti_dn_s8;
  input  wire [KEEP_WIDTH-1:0] tkeep_dti_dn_s8;
  input  wire  [SID_WIDTH-1:0] tid_dti_dn_s8;
  input  wire                  tlast_dti_dn_s8;

  input  wire                  tvalid_dti_dn_s9;
  output wire                  tready_dti_dn_s9;
  input  wire [DATA_WIDTH-1:0] tdata_dti_dn_s9;
  input  wire [KEEP_WIDTH-1:0] tkeep_dti_dn_s9;
  input  wire  [SID_WIDTH-1:0] tid_dti_dn_s9;
  input  wire                  tlast_dti_dn_s9;

  input  wire                  tvalid_dti_dn_s10;
  output wire                  tready_dti_dn_s10;
  input  wire [DATA_WIDTH-1:0] tdata_dti_dn_s10;
  input  wire [KEEP_WIDTH-1:0] tkeep_dti_dn_s10;
  input  wire  [SID_WIDTH-1:0] tid_dti_dn_s10;
  input  wire                  tlast_dti_dn_s10;

  input  wire                  tvalid_dti_dn_s11;
  output wire                  tready_dti_dn_s11;
  input  wire [DATA_WIDTH-1:0] tdata_dti_dn_s11;
  input  wire [KEEP_WIDTH-1:0] tkeep_dti_dn_s11;
  input  wire  [SID_WIDTH-1:0] tid_dti_dn_s11;
  input  wire                  tlast_dti_dn_s11;

  input  wire                  tvalid_dti_dn_s12;
  output wire                  tready_dti_dn_s12;
  input  wire [DATA_WIDTH-1:0] tdata_dti_dn_s12;
  input  wire [KEEP_WIDTH-1:0] tkeep_dti_dn_s12;
  input  wire  [SID_WIDTH-1:0] tid_dti_dn_s12;
  input  wire                  tlast_dti_dn_s12;


  output wire                  tvalid_dti_dn_m;
  input  wire                  tready_dti_dn_m;
  output wire [DATA_WIDTH-1:0] tdata_dti_dn_m;
  output wire [KEEP_WIDTH-1:0] tkeep_dti_dn_m;
  output wire  [MID_WIDTH-1:0] tid_dti_dn_m;
  output wire                  tlast_dti_dn_m;

  
  output wire                  tvalid_dti_up_s0;
  input  wire                  tready_dti_up_s0;
  output wire [DATA_WIDTH-1:0] tdata_dti_up_s0;
  output wire [KEEP_WIDTH-1:0] tkeep_dti_up_s0;
  output wire  [SID_WIDTH-1:0] tdest_dti_up_s0;
  output wire                  tlast_dti_up_s0;

  output wire                  tvalid_dti_up_s1;
  input  wire                  tready_dti_up_s1;
  output wire [DATA_WIDTH-1:0] tdata_dti_up_s1;
  output wire [KEEP_WIDTH-1:0] tkeep_dti_up_s1;
  output wire  [SID_WIDTH-1:0] tdest_dti_up_s1;
  output wire                  tlast_dti_up_s1;

  output wire                  tvalid_dti_up_s2;
  input  wire                  tready_dti_up_s2;
  output wire [DATA_WIDTH-1:0] tdata_dti_up_s2;
  output wire [KEEP_WIDTH-1:0] tkeep_dti_up_s2;
  output wire  [SID_WIDTH-1:0] tdest_dti_up_s2;
  output wire                  tlast_dti_up_s2;

  output wire                  tvalid_dti_up_s3;
  input  wire                  tready_dti_up_s3;
  output wire [DATA_WIDTH-1:0] tdata_dti_up_s3;
  output wire [KEEP_WIDTH-1:0] tkeep_dti_up_s3;
  output wire  [SID_WIDTH-1:0] tdest_dti_up_s3;
  output wire                  tlast_dti_up_s3;

  output wire                  tvalid_dti_up_s4;
  input  wire                  tready_dti_up_s4;
  output wire [DATA_WIDTH-1:0] tdata_dti_up_s4;
  output wire [KEEP_WIDTH-1:0] tkeep_dti_up_s4;
  output wire  [SID_WIDTH-1:0] tdest_dti_up_s4;
  output wire                  tlast_dti_up_s4;

  output wire                  tvalid_dti_up_s5;
  input  wire                  tready_dti_up_s5;
  output wire [DATA_WIDTH-1:0] tdata_dti_up_s5;
  output wire [KEEP_WIDTH-1:0] tkeep_dti_up_s5;
  output wire  [SID_WIDTH-1:0] tdest_dti_up_s5;
  output wire                  tlast_dti_up_s5;

  output wire                  tvalid_dti_up_s6;
  input  wire                  tready_dti_up_s6;
  output wire [DATA_WIDTH-1:0] tdata_dti_up_s6;
  output wire [KEEP_WIDTH-1:0] tkeep_dti_up_s6;
  output wire  [SID_WIDTH-1:0] tdest_dti_up_s6;
  output wire                  tlast_dti_up_s6;

  output wire                  tvalid_dti_up_s7;
  input  wire                  tready_dti_up_s7;
  output wire [DATA_WIDTH-1:0] tdata_dti_up_s7;
  output wire [KEEP_WIDTH-1:0] tkeep_dti_up_s7;
  output wire  [SID_WIDTH-1:0] tdest_dti_up_s7;
  output wire                  tlast_dti_up_s7;

  output wire                  tvalid_dti_up_s8;
  input  wire                  tready_dti_up_s8;
  output wire [DATA_WIDTH-1:0] tdata_dti_up_s8;
  output wire [KEEP_WIDTH-1:0] tkeep_dti_up_s8;
  output wire  [SID_WIDTH-1:0] tdest_dti_up_s8;
  output wire                  tlast_dti_up_s8;

  output wire                  tvalid_dti_up_s9;
  input  wire                  tready_dti_up_s9;
  output wire [DATA_WIDTH-1:0] tdata_dti_up_s9;
  output wire [KEEP_WIDTH-1:0] tkeep_dti_up_s9;
  output wire  [SID_WIDTH-1:0] tdest_dti_up_s9;
  output wire                  tlast_dti_up_s9;

  output wire                  tvalid_dti_up_s10;
  input  wire                  tready_dti_up_s10;
  output wire [DATA_WIDTH-1:0] tdata_dti_up_s10;
  output wire [KEEP_WIDTH-1:0] tkeep_dti_up_s10;
  output wire  [SID_WIDTH-1:0] tdest_dti_up_s10;
  output wire                  tlast_dti_up_s10;

  output wire                  tvalid_dti_up_s11;
  input  wire                  tready_dti_up_s11;
  output wire [DATA_WIDTH-1:0] tdata_dti_up_s11;
  output wire [KEEP_WIDTH-1:0] tkeep_dti_up_s11;
  output wire  [SID_WIDTH-1:0] tdest_dti_up_s11;
  output wire                  tlast_dti_up_s11;

  output wire                  tvalid_dti_up_s12;
  input  wire                  tready_dti_up_s12;
  output wire [DATA_WIDTH-1:0] tdata_dti_up_s12;
  output wire [KEEP_WIDTH-1:0] tkeep_dti_up_s12;
  output wire  [SID_WIDTH-1:0] tdest_dti_up_s12;
  output wire                  tlast_dti_up_s12;


  input  wire                  tvalid_dti_up_m;
  output wire                  tready_dti_up_m;
  input  wire [DATA_WIDTH-1:0] tdata_dti_up_m;
  input  wire [KEEP_WIDTH-1:0] tkeep_dti_up_m;
  input  wire  [MID_WIDTH-1:0] tdest_dti_up_m;
  input  wire                  tlast_dti_up_m;

  input  wire twakeup_dti_dn_s0;
  input  wire twakeup_dti_dn_s1;
  input  wire twakeup_dti_dn_s2;
  input  wire twakeup_dti_dn_s3;
  input  wire twakeup_dti_dn_s4;
  input  wire twakeup_dti_dn_s5;
  input  wire twakeup_dti_dn_s6;
  input  wire twakeup_dti_dn_s7;
  input  wire twakeup_dti_dn_s8;
  input  wire twakeup_dti_dn_s9;
  input  wire twakeup_dti_dn_s10;
  input  wire twakeup_dti_dn_s11;
  input  wire twakeup_dti_dn_s12;
  output wire twakeup_dti_dn_m;

  output wire twakeup_dti_up_s0;
  output wire twakeup_dti_up_s1;
  output wire twakeup_dti_up_s2;
  output wire twakeup_dti_up_s3;
  output wire twakeup_dti_up_s4;
  output wire twakeup_dti_up_s5;
  output wire twakeup_dti_up_s6;
  output wire twakeup_dti_up_s7;
  output wire twakeup_dti_up_s8;
  output wire twakeup_dti_up_s9;
  output wire twakeup_dti_up_s10;
  output wire twakeup_dti_up_s11;
  output wire twakeup_dti_up_s12;
  input  wire twakeup_dti_up_m;


sse710_bas_switch_16x1
  #(
   .DECMIN_SI0  (0),
   .DECMAX_SI0  (0),

   .DECMIN_SI1  (1),
   .DECMAX_SI1  (1),

   .DECMIN_SI2  (2),
   .DECMAX_SI2  (2),

   .DECMIN_SI3  (3),
   .DECMAX_SI3  (3),

   .DECMIN_SI4  (4),
   .DECMAX_SI4  (4),

   .DECMIN_SI5  (5),
   .DECMAX_SI5  (5),

   .DECMIN_SI6  (6),
   .DECMAX_SI6  (6),

   .DECMIN_SI7  (7),
   .DECMAX_SI7  (7),

   .DECMIN_SI8  (8),
   .DECMAX_SI8  (8),

   .DECMIN_SI9  (9),
   .DECMAX_SI9  (9),

   .DECMIN_SI10  (10),
   .DECMAX_SI10  (10),

   .DECMIN_SI11  (11),
   .DECMAX_SI11  (11),

   .DECMIN_SI12  (12),
   .DECMAX_SI12  (12),

   .DECMIN_SI13  (13),
   .DECMAX_SI13  (13),

   .DECMIN_SI14  (14),
   .DECMAX_SI14  (14),

   .DECMIN_SI15  (15),
   .DECMAX_SI15  (15),

   .DATA_WIDTH  (DATA_WIDTH),
   .ID_WIDTH    (ID_WIDTH)
  )
  u_sse710_bas_switch_16x1
  (
  .aclk       (aclk),
  .aresetn    (aresetn),

  .tvalid_dti_dn_s0    (tvalid_dti_dn_s0),
  .tready_dti_dn_s0    (tready_dti_dn_s0),
  .tdata_dti_dn_s0     (tdata_dti_dn_s0),
  .tkeep_dti_dn_s0     (tkeep_dti_dn_s0),
  .tid_dti_dn_s0       (tid_dti_dn_s0),
  .tlast_dti_dn_s0     (tlast_dti_dn_s0),

  .tvalid_dti_dn_s1    (tvalid_dti_dn_s1),
  .tready_dti_dn_s1    (tready_dti_dn_s1),
  .tdata_dti_dn_s1     (tdata_dti_dn_s1),
  .tkeep_dti_dn_s1     (tkeep_dti_dn_s1),
  .tid_dti_dn_s1       (tid_dti_dn_s1),
  .tlast_dti_dn_s1     (tlast_dti_dn_s1),

  .tvalid_dti_dn_s2    (tvalid_dti_dn_s2),
  .tready_dti_dn_s2    (tready_dti_dn_s2),
  .tdata_dti_dn_s2     (tdata_dti_dn_s2),
  .tkeep_dti_dn_s2     (tkeep_dti_dn_s2),
  .tid_dti_dn_s2       (tid_dti_dn_s2),
  .tlast_dti_dn_s2     (tlast_dti_dn_s2),

  .tvalid_dti_dn_s3    (tvalid_dti_dn_s3),
  .tready_dti_dn_s3    (tready_dti_dn_s3),
  .tdata_dti_dn_s3     (tdata_dti_dn_s3),
  .tkeep_dti_dn_s3     (tkeep_dti_dn_s3),
  .tid_dti_dn_s3       (tid_dti_dn_s3),
  .tlast_dti_dn_s3     (tlast_dti_dn_s3),

  .tvalid_dti_dn_s4    (tvalid_dti_dn_s4),
  .tready_dti_dn_s4    (tready_dti_dn_s4),
  .tdata_dti_dn_s4     (tdata_dti_dn_s4),
  .tkeep_dti_dn_s4     (tkeep_dti_dn_s4),
  .tid_dti_dn_s4       (tid_dti_dn_s4),
  .tlast_dti_dn_s4     (tlast_dti_dn_s4),

  .tvalid_dti_dn_s5    (tvalid_dti_dn_s5),
  .tready_dti_dn_s5    (tready_dti_dn_s5),
  .tdata_dti_dn_s5     (tdata_dti_dn_s5),
  .tkeep_dti_dn_s5     (tkeep_dti_dn_s5),
  .tid_dti_dn_s5       (tid_dti_dn_s5),
  .tlast_dti_dn_s5     (tlast_dti_dn_s5),

  .tvalid_dti_dn_s6    (tvalid_dti_dn_s6),
  .tready_dti_dn_s6    (tready_dti_dn_s6),
  .tdata_dti_dn_s6     (tdata_dti_dn_s6),
  .tkeep_dti_dn_s6     (tkeep_dti_dn_s6),
  .tid_dti_dn_s6       (tid_dti_dn_s6),
  .tlast_dti_dn_s6     (tlast_dti_dn_s6),

  .tvalid_dti_dn_s7    (tvalid_dti_dn_s7),
  .tready_dti_dn_s7    (tready_dti_dn_s7),
  .tdata_dti_dn_s7     (tdata_dti_dn_s7),
  .tkeep_dti_dn_s7     (tkeep_dti_dn_s7),
  .tid_dti_dn_s7       (tid_dti_dn_s7),
  .tlast_dti_dn_s7     (tlast_dti_dn_s7),

  .tvalid_dti_dn_s8    (tvalid_dti_dn_s8),
  .tready_dti_dn_s8    (tready_dti_dn_s8),
  .tdata_dti_dn_s8     (tdata_dti_dn_s8),
  .tkeep_dti_dn_s8     (tkeep_dti_dn_s8),
  .tid_dti_dn_s8       (tid_dti_dn_s8),
  .tlast_dti_dn_s8     (tlast_dti_dn_s8),

  .tvalid_dti_dn_s9    (tvalid_dti_dn_s9),
  .tready_dti_dn_s9    (tready_dti_dn_s9),
  .tdata_dti_dn_s9     (tdata_dti_dn_s9),
  .tkeep_dti_dn_s9     (tkeep_dti_dn_s9),
  .tid_dti_dn_s9       (tid_dti_dn_s9),
  .tlast_dti_dn_s9     (tlast_dti_dn_s9),

  .tvalid_dti_dn_s10    (tvalid_dti_dn_s10),
  .tready_dti_dn_s10    (tready_dti_dn_s10),
  .tdata_dti_dn_s10     (tdata_dti_dn_s10),
  .tkeep_dti_dn_s10     (tkeep_dti_dn_s10),
  .tid_dti_dn_s10       (tid_dti_dn_s10),
  .tlast_dti_dn_s10     (tlast_dti_dn_s10),

  .tvalid_dti_dn_s11    (tvalid_dti_dn_s11),
  .tready_dti_dn_s11    (tready_dti_dn_s11),
  .tdata_dti_dn_s11     (tdata_dti_dn_s11),
  .tkeep_dti_dn_s11     (tkeep_dti_dn_s11),
  .tid_dti_dn_s11       (tid_dti_dn_s11),
  .tlast_dti_dn_s11     (tlast_dti_dn_s11),

  .tvalid_dti_dn_s12    (tvalid_dti_dn_s12),
  .tready_dti_dn_s12    (tready_dti_dn_s12),
  .tdata_dti_dn_s12     (tdata_dti_dn_s12),
  .tkeep_dti_dn_s12     (tkeep_dti_dn_s12),
  .tid_dti_dn_s12       (tid_dti_dn_s12),
  .tlast_dti_dn_s12     (tlast_dti_dn_s12),

  .tvalid_dti_dn_s13    (1'b0        ),
  .tready_dti_dn_s13    (            ),
  .tdata_dti_dn_s13     (32'h00000000),
  .tkeep_dti_dn_s13     (4'h0        ),
  .tid_dti_dn_s13       (4'h0        ),
  .tlast_dti_dn_s13     (1'b0        ),

  .tvalid_dti_dn_s14    (1'b0        ),
  .tready_dti_dn_s14    (            ),
  .tdata_dti_dn_s14     (32'h00000000),
  .tkeep_dti_dn_s14     (4'h0        ),
  .tid_dti_dn_s14       (4'h0        ),
  .tlast_dti_dn_s14     (1'b0        ),

  .tvalid_dti_dn_s15    (1'b0        ),
  .tready_dti_dn_s15    (            ),
  .tdata_dti_dn_s15     (32'h00000000),
  .tkeep_dti_dn_s15     (4'h0        ),
  .tid_dti_dn_s15       (4'h0        ),
  .tlast_dti_dn_s15     (1'b0        ),

  .tvalid_dti_dn_m    (tvalid_dti_dn_m),
  .tready_dti_dn_m    (tready_dti_dn_m),
  .tdata_dti_dn_m     (tdata_dti_dn_m),
  .tkeep_dti_dn_m     (tkeep_dti_dn_m),
  .tid_dti_dn_m       (tid_dti_dn_m),
  .tlast_dti_dn_m     (tlast_dti_dn_m),

  .tvalid_dti_up_s0    (tvalid_dti_up_s0),
  .tready_dti_up_s0    (tready_dti_up_s0),
  .tdata_dti_up_s0     (tdata_dti_up_s0),
  .tkeep_dti_up_s0     (tkeep_dti_up_s0),
  .tdest_dti_up_s0     (tdest_dti_up_s0),
  .tlast_dti_up_s0     (tlast_dti_up_s0),

  .tvalid_dti_up_s1    (tvalid_dti_up_s1),
  .tready_dti_up_s1    (tready_dti_up_s1),
  .tdata_dti_up_s1     (tdata_dti_up_s1),
  .tkeep_dti_up_s1     (tkeep_dti_up_s1),
  .tdest_dti_up_s1     (tdest_dti_up_s1),
  .tlast_dti_up_s1     (tlast_dti_up_s1),

  .tvalid_dti_up_s2    (tvalid_dti_up_s2),
  .tready_dti_up_s2    (tready_dti_up_s2),
  .tdata_dti_up_s2     (tdata_dti_up_s2),
  .tkeep_dti_up_s2     (tkeep_dti_up_s2),
  .tdest_dti_up_s2     (tdest_dti_up_s2),
  .tlast_dti_up_s2     (tlast_dti_up_s2),

  .tvalid_dti_up_s3    (tvalid_dti_up_s3),
  .tready_dti_up_s3    (tready_dti_up_s3),
  .tdata_dti_up_s3     (tdata_dti_up_s3),
  .tkeep_dti_up_s3     (tkeep_dti_up_s3),
  .tdest_dti_up_s3     (tdest_dti_up_s3),
  .tlast_dti_up_s3     (tlast_dti_up_s3),

  .tvalid_dti_up_s4    (tvalid_dti_up_s4),
  .tready_dti_up_s4    (tready_dti_up_s4),
  .tdata_dti_up_s4     (tdata_dti_up_s4),
  .tkeep_dti_up_s4     (tkeep_dti_up_s4),
  .tdest_dti_up_s4     (tdest_dti_up_s4),
  .tlast_dti_up_s4     (tlast_dti_up_s4),

  .tvalid_dti_up_s5    (tvalid_dti_up_s5),
  .tready_dti_up_s5    (tready_dti_up_s5),
  .tdata_dti_up_s5     (tdata_dti_up_s5),
  .tkeep_dti_up_s5     (tkeep_dti_up_s5),
  .tdest_dti_up_s5     (tdest_dti_up_s5),
  .tlast_dti_up_s5     (tlast_dti_up_s5),

  .tvalid_dti_up_s6    (tvalid_dti_up_s6),
  .tready_dti_up_s6    (tready_dti_up_s6),
  .tdata_dti_up_s6     (tdata_dti_up_s6),
  .tkeep_dti_up_s6     (tkeep_dti_up_s6),
  .tdest_dti_up_s6     (tdest_dti_up_s6),
  .tlast_dti_up_s6     (tlast_dti_up_s6),

  .tvalid_dti_up_s7    (tvalid_dti_up_s7),
  .tready_dti_up_s7    (tready_dti_up_s7),
  .tdata_dti_up_s7     (tdata_dti_up_s7),
  .tkeep_dti_up_s7     (tkeep_dti_up_s7),
  .tdest_dti_up_s7     (tdest_dti_up_s7),
  .tlast_dti_up_s7     (tlast_dti_up_s7),

  .tvalid_dti_up_s8    (tvalid_dti_up_s8),
  .tready_dti_up_s8    (tready_dti_up_s8),
  .tdata_dti_up_s8     (tdata_dti_up_s8),
  .tkeep_dti_up_s8     (tkeep_dti_up_s8),
  .tdest_dti_up_s8     (tdest_dti_up_s8),
  .tlast_dti_up_s8     (tlast_dti_up_s8),

  .tvalid_dti_up_s9    (tvalid_dti_up_s9),
  .tready_dti_up_s9    (tready_dti_up_s9),
  .tdata_dti_up_s9     (tdata_dti_up_s9),
  .tkeep_dti_up_s9     (tkeep_dti_up_s9),
  .tdest_dti_up_s9     (tdest_dti_up_s9),
  .tlast_dti_up_s9     (tlast_dti_up_s9),

  .tvalid_dti_up_s10    (tvalid_dti_up_s10),
  .tready_dti_up_s10    (tready_dti_up_s10),
  .tdata_dti_up_s10     (tdata_dti_up_s10),
  .tkeep_dti_up_s10     (tkeep_dti_up_s10),
  .tdest_dti_up_s10     (tdest_dti_up_s10),
  .tlast_dti_up_s10     (tlast_dti_up_s10),

  .tvalid_dti_up_s11    (tvalid_dti_up_s11),
  .tready_dti_up_s11    (tready_dti_up_s11),
  .tdata_dti_up_s11     (tdata_dti_up_s11),
  .tkeep_dti_up_s11     (tkeep_dti_up_s11),
  .tdest_dti_up_s11     (tdest_dti_up_s11),
  .tlast_dti_up_s11     (tlast_dti_up_s11),

  .tvalid_dti_up_s12    (tvalid_dti_up_s12),
  .tready_dti_up_s12    (tready_dti_up_s12),
  .tdata_dti_up_s12     (tdata_dti_up_s12),
  .tkeep_dti_up_s12     (tkeep_dti_up_s12),
  .tdest_dti_up_s12     (tdest_dti_up_s12),
  .tlast_dti_up_s12     (tlast_dti_up_s12),

  .tvalid_dti_up_s13    (    ),
  .tready_dti_up_s13    (1'b0),
  .tdata_dti_up_s13     (    ),
  .tkeep_dti_up_s13     (    ),
  .tdest_dti_up_s13     (    ),
  .tlast_dti_up_s13     (    ),

  .tvalid_dti_up_s14    (    ),
  .tready_dti_up_s14    (1'b0),
  .tdata_dti_up_s14     (    ),
  .tkeep_dti_up_s14     (    ),
  .tdest_dti_up_s14     (    ),
  .tlast_dti_up_s14     (    ),

  .tvalid_dti_up_s15    (    ),
  .tready_dti_up_s15    (1'b0),
  .tdata_dti_up_s15     (    ),
  .tkeep_dti_up_s15     (    ),
  .tdest_dti_up_s15     (    ),
  .tlast_dti_up_s15     (    ),

  .tvalid_dti_up_m    (tvalid_dti_up_m),
  .tready_dti_up_m    (tready_dti_up_m),
  .tdata_dti_up_m     (tdata_dti_up_m),
  .tkeep_dti_up_m     (tkeep_dti_up_m),
  .tdest_dti_up_m     (tdest_dti_up_m),
  .tlast_dti_up_m     (tlast_dti_up_m),

  .twakeup_dti_dn_s0   (twakeup_dti_dn_s0), 
  .twakeup_dti_dn_s1   (twakeup_dti_dn_s1), 
  .twakeup_dti_dn_s2   (twakeup_dti_dn_s2), 
  .twakeup_dti_dn_s3   (twakeup_dti_dn_s3), 
  .twakeup_dti_dn_s4   (twakeup_dti_dn_s4), 
  .twakeup_dti_dn_s5   (twakeup_dti_dn_s5), 
  .twakeup_dti_dn_s6   (twakeup_dti_dn_s6), 
  .twakeup_dti_dn_s7   (twakeup_dti_dn_s7), 
  .twakeup_dti_dn_s8   (twakeup_dti_dn_s8), 
  .twakeup_dti_dn_s9   (twakeup_dti_dn_s9), 
  .twakeup_dti_dn_s10   (twakeup_dti_dn_s10), 
  .twakeup_dti_dn_s11   (twakeup_dti_dn_s11), 
  .twakeup_dti_dn_s12   (twakeup_dti_dn_s12), 
  .twakeup_dti_dn_s13   (1'b0),
  .twakeup_dti_dn_s14   (1'b0),
  .twakeup_dti_dn_s15   (1'b0),
  .twakeup_dti_dn_m    (twakeup_dti_dn_m),

  .twakeup_dti_up_s0   (twakeup_dti_up_s0), 
  .twakeup_dti_up_s1   (twakeup_dti_up_s1), 
  .twakeup_dti_up_s2   (twakeup_dti_up_s2), 
  .twakeup_dti_up_s3   (twakeup_dti_up_s3), 
  .twakeup_dti_up_s4   (twakeup_dti_up_s4), 
  .twakeup_dti_up_s5   (twakeup_dti_up_s5), 
  .twakeup_dti_up_s6   (twakeup_dti_up_s6), 
  .twakeup_dti_up_s7   (twakeup_dti_up_s7), 
  .twakeup_dti_up_s8   (twakeup_dti_up_s8), 
  .twakeup_dti_up_s9   (twakeup_dti_up_s9), 
  .twakeup_dti_up_s10   (twakeup_dti_up_s10), 
  .twakeup_dti_up_s11   (twakeup_dti_up_s11), 
  .twakeup_dti_up_s12   (twakeup_dti_up_s12), 
  .twakeup_dti_up_s13   ( ),
  .twakeup_dti_up_s14   ( ),
  .twakeup_dti_up_s15   ( ),
  .twakeup_dti_up_m    (twakeup_dti_up_m)
  );

  assign qactive_cg0  = 1'b0;
  assign qacceptn_cg0 = qreqn_cg0;
  assign qdeny_cg0    = 1'b0;

  assign qactive_cg1  = 1'b0;
  assign qacceptn_cg1 = qreqn_cg1;
  assign qdeny_cg1    = 1'b0;


endmodule

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




module firewall_f0_bas_switch_16x1
  (
  aclk,
  aresetn,


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

  tvalid_dti_dn_s13,
  tready_dti_dn_s13,
  tdata_dti_dn_s13,
  tkeep_dti_dn_s13,
  tid_dti_dn_s13,
  tlast_dti_dn_s13,

  tvalid_dti_dn_s14,
  tready_dti_dn_s14,
  tdata_dti_dn_s14,
  tkeep_dti_dn_s14,
  tid_dti_dn_s14,
  tlast_dti_dn_s14,

  tvalid_dti_dn_s15,
  tready_dti_dn_s15,
  tdata_dti_dn_s15,
  tkeep_dti_dn_s15,
  tid_dti_dn_s15,
  tlast_dti_dn_s15,

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

  tvalid_dti_up_s13,
  tready_dti_up_s13,
  tdata_dti_up_s13,
  tkeep_dti_up_s13,
  tdest_dti_up_s13,
  tlast_dti_up_s13,

  tvalid_dti_up_s14,
  tready_dti_up_s14,
  tdata_dti_up_s14,
  tkeep_dti_up_s14,
  tdest_dti_up_s14,
  tlast_dti_up_s14,

  tvalid_dti_up_s15,
  tready_dti_up_s15,
  tdata_dti_up_s15,
  tkeep_dti_up_s15,
  tdest_dti_up_s15,
  tlast_dti_up_s15,

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
  twakeup_dti_dn_s13,
  twakeup_dti_dn_s14,
  twakeup_dti_dn_s15,
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
  twakeup_dti_up_s13,
  twakeup_dti_up_s14,
  twakeup_dti_up_s15,
  twakeup_dti_up_m

  );


  parameter DATA_WIDTH = 8;  
  parameter ID_WIDTH   = 4;  

  parameter DECMIN_SI0  = 0;
  parameter DECMAX_SI0  = DECMIN_SI0;
  parameter DECMIN_SI1  = 1;
  parameter DECMAX_SI1  = DECMIN_SI1;
  parameter DECMIN_SI2  = 2;
  parameter DECMAX_SI2  = DECMIN_SI2;
  parameter DECMIN_SI3  = 3;
  parameter DECMAX_SI3  = DECMIN_SI3;
  parameter DECMIN_SI4  = 4;
  parameter DECMAX_SI4  = DECMIN_SI4;
  parameter DECMIN_SI5  = 5;
  parameter DECMAX_SI5  = DECMIN_SI5;
  parameter DECMIN_SI6  = 6;
  parameter DECMAX_SI6  = DECMIN_SI6;
  parameter DECMIN_SI7  = 7;
  parameter DECMAX_SI7  = DECMIN_SI7;
  parameter DECMIN_SI8  = 8;
  parameter DECMAX_SI8  = DECMIN_SI8;
  parameter DECMIN_SI9  = 9;
  parameter DECMAX_SI9  = DECMIN_SI9;
  parameter DECMIN_SI10  = 10;
  parameter DECMAX_SI10  = DECMIN_SI10;
  parameter DECMIN_SI11  = 11;
  parameter DECMAX_SI11  = DECMIN_SI11;
  parameter DECMIN_SI12  = 12;
  parameter DECMAX_SI12  = DECMIN_SI12;
  parameter DECMIN_SI13  = 13;
  parameter DECMAX_SI13  = DECMIN_SI13;
  parameter DECMIN_SI14  = 14;
  parameter DECMAX_SI14  = DECMIN_SI14;
  parameter DECMIN_SI15  = 15;
  parameter DECMAX_SI15  = DECMIN_SI15;



  localparam NUM_SI = 16;

  localparam KEEP_WIDTH = DATA_WIDTH / 8;
  localparam LAST_WIDTH = 1;  
  localparam SID_WIDTH = ID_WIDTH;
  localparam MID_WIDTH = ID_WIDTH;


  input  wire aclk;
  input  wire aresetn;


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

  input  wire                  tvalid_dti_dn_s13;
  output wire                  tready_dti_dn_s13;
  input  wire [DATA_WIDTH-1:0] tdata_dti_dn_s13;
  input  wire [KEEP_WIDTH-1:0] tkeep_dti_dn_s13;
  input  wire  [SID_WIDTH-1:0] tid_dti_dn_s13;
  input  wire                  tlast_dti_dn_s13;

  input  wire                  tvalid_dti_dn_s14;
  output wire                  tready_dti_dn_s14;
  input  wire [DATA_WIDTH-1:0] tdata_dti_dn_s14;
  input  wire [KEEP_WIDTH-1:0] tkeep_dti_dn_s14;
  input  wire  [SID_WIDTH-1:0] tid_dti_dn_s14;
  input  wire                  tlast_dti_dn_s14;

  input  wire                  tvalid_dti_dn_s15;
  output wire                  tready_dti_dn_s15;
  input  wire [DATA_WIDTH-1:0] tdata_dti_dn_s15;
  input  wire [KEEP_WIDTH-1:0] tkeep_dti_dn_s15;
  input  wire  [SID_WIDTH-1:0] tid_dti_dn_s15;
  input  wire                  tlast_dti_dn_s15;

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

  output wire                  tvalid_dti_up_s13;
  input  wire                  tready_dti_up_s13;
  output wire [DATA_WIDTH-1:0] tdata_dti_up_s13;
  output wire [KEEP_WIDTH-1:0] tkeep_dti_up_s13;
  output wire  [SID_WIDTH-1:0] tdest_dti_up_s13;
  output wire                  tlast_dti_up_s13;

  output wire                  tvalid_dti_up_s14;
  input  wire                  tready_dti_up_s14;
  output wire [DATA_WIDTH-1:0] tdata_dti_up_s14;
  output wire [KEEP_WIDTH-1:0] tkeep_dti_up_s14;
  output wire  [SID_WIDTH-1:0] tdest_dti_up_s14;
  output wire                  tlast_dti_up_s14;

  output wire                  tvalid_dti_up_s15;
  input  wire                  tready_dti_up_s15;
  output wire [DATA_WIDTH-1:0] tdata_dti_up_s15;
  output wire [KEEP_WIDTH-1:0] tkeep_dti_up_s15;
  output wire  [SID_WIDTH-1:0] tdest_dti_up_s15;
  output wire                  tlast_dti_up_s15;

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
  input  wire twakeup_dti_dn_s13;
  input  wire twakeup_dti_dn_s14;
  input  wire twakeup_dti_dn_s15;
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
  output wire twakeup_dti_up_s13;
  output wire twakeup_dti_up_s14;
  output wire twakeup_dti_up_s15;
  input  wire twakeup_dti_up_m;




  wire [NUM_SI-1:0]              tvalid_dti_dn_s_vector;
  wire [NUM_SI-1:0]              tready_dti_dn_s_vector;
  wire [(DATA_WIDTH*NUM_SI)-1:0] tdata_dti_dn_s_vector;
  wire [(KEEP_WIDTH*NUM_SI)-1:0] tkeep_dti_dn_s_vector;
  wire [(SID_WIDTH*NUM_SI)-1:0]  tid_dti_dn_s_vector;
  wire [(LAST_WIDTH*NUM_SI)-1:0] tlast_dti_dn_s_vector;

  wire [DATA_WIDTH-1:0] tdata_dti_dn_s_array [NUM_SI-1:0];
  wire [KEEP_WIDTH-1:0] tkeep_dti_dn_s_array [NUM_SI-1:0];
  wire [SID_WIDTH-1:0]  tid_dti_dn_s_array   [NUM_SI-1:0];
  wire [LAST_WIDTH-1:0] tlast_dti_dn_s_array [NUM_SI-1:0];

  wire [NUM_SI-1:0]              tvalid_dti_up_s_vector;
  wire [NUM_SI-1:0]              tready_dti_up_s_vector;
  wire [(DATA_WIDTH*NUM_SI)-1:0] tdata_dti_up_s_vector;
  wire [(KEEP_WIDTH*NUM_SI)-1:0] tkeep_dti_up_s_vector;
  wire [(SID_WIDTH*NUM_SI)-1:0]  tdest_dti_up_s_vector;
  wire [(LAST_WIDTH*NUM_SI)-1:0] tlast_dti_up_s_vector;

  wire [DATA_WIDTH-1:0] tdata_dti_up_s_array [NUM_SI-1:0];
  wire [KEEP_WIDTH-1:0] tkeep_dti_up_s_array [NUM_SI-1:0];
  wire [SID_WIDTH-1:0]  tdest_dti_up_s_array [NUM_SI-1:0];
  wire [LAST_WIDTH-1:0] tlast_dti_up_s_array [NUM_SI-1:0];

  wire [NUM_SI-1:0] twakeup_dti_dn_s_vector;
  wire [NUM_SI-1:0] twakeup_dti_up_s_vector;


  assign tvalid_dti_dn_s_vector = {tvalid_dti_dn_s15,
                                   tvalid_dti_dn_s14,
                                   tvalid_dti_dn_s13,
                                   tvalid_dti_dn_s12,
                                   tvalid_dti_dn_s11,
                                   tvalid_dti_dn_s10,
                                   tvalid_dti_dn_s9,
                                   tvalid_dti_dn_s8,
                                   tvalid_dti_dn_s7,
                                   tvalid_dti_dn_s6,
                                   tvalid_dti_dn_s5,
                                   tvalid_dti_dn_s4,
                                   tvalid_dti_dn_s3,
                                   tvalid_dti_dn_s2,
                                   tvalid_dti_dn_s1,
                                   tvalid_dti_dn_s0};

  assign {tready_dti_dn_s15,
          tready_dti_dn_s14,
          tready_dti_dn_s13,
          tready_dti_dn_s12,
          tready_dti_dn_s11,
          tready_dti_dn_s10,
          tready_dti_dn_s9,
          tready_dti_dn_s8,
          tready_dti_dn_s7,
          tready_dti_dn_s6,
          tready_dti_dn_s5,
          tready_dti_dn_s4,
          tready_dti_dn_s3,
          tready_dti_dn_s2,
          tready_dti_dn_s1,
          tready_dti_dn_s0} = tready_dti_dn_s_vector;


  assign tdata_dti_dn_s_array[0] = tdata_dti_dn_s0;
  assign tdata_dti_dn_s_array[1] = tdata_dti_dn_s1;
  assign tdata_dti_dn_s_array[2] = tdata_dti_dn_s2;
  assign tdata_dti_dn_s_array[3] = tdata_dti_dn_s3;
  assign tdata_dti_dn_s_array[4] = tdata_dti_dn_s4;
  assign tdata_dti_dn_s_array[5] = tdata_dti_dn_s5;
  assign tdata_dti_dn_s_array[6] = tdata_dti_dn_s6;
  assign tdata_dti_dn_s_array[7] = tdata_dti_dn_s7;
  assign tdata_dti_dn_s_array[8] = tdata_dti_dn_s8;
  assign tdata_dti_dn_s_array[9] = tdata_dti_dn_s9;
  assign tdata_dti_dn_s_array[10] = tdata_dti_dn_s10;
  assign tdata_dti_dn_s_array[11] = tdata_dti_dn_s11;
  assign tdata_dti_dn_s_array[12] = tdata_dti_dn_s12;
  assign tdata_dti_dn_s_array[13] = tdata_dti_dn_s13;
  assign tdata_dti_dn_s_array[14] = tdata_dti_dn_s14;
  assign tdata_dti_dn_s_array[15] = tdata_dti_dn_s15;
  assign tkeep_dti_dn_s_array[0] = tkeep_dti_dn_s0;
  assign tkeep_dti_dn_s_array[1] = tkeep_dti_dn_s1;
  assign tkeep_dti_dn_s_array[2] = tkeep_dti_dn_s2;
  assign tkeep_dti_dn_s_array[3] = tkeep_dti_dn_s3;
  assign tkeep_dti_dn_s_array[4] = tkeep_dti_dn_s4;
  assign tkeep_dti_dn_s_array[5] = tkeep_dti_dn_s5;
  assign tkeep_dti_dn_s_array[6] = tkeep_dti_dn_s6;
  assign tkeep_dti_dn_s_array[7] = tkeep_dti_dn_s7;
  assign tkeep_dti_dn_s_array[8] = tkeep_dti_dn_s8;
  assign tkeep_dti_dn_s_array[9] = tkeep_dti_dn_s9;
  assign tkeep_dti_dn_s_array[10] = tkeep_dti_dn_s10;
  assign tkeep_dti_dn_s_array[11] = tkeep_dti_dn_s11;
  assign tkeep_dti_dn_s_array[12] = tkeep_dti_dn_s12;
  assign tkeep_dti_dn_s_array[13] = tkeep_dti_dn_s13;
  assign tkeep_dti_dn_s_array[14] = tkeep_dti_dn_s14;
  assign tkeep_dti_dn_s_array[15] = tkeep_dti_dn_s15;
  assign tid_dti_dn_s_array[0]   = tid_dti_dn_s0;
  assign tid_dti_dn_s_array[1]   = tid_dti_dn_s1;
  assign tid_dti_dn_s_array[2]   = tid_dti_dn_s2;
  assign tid_dti_dn_s_array[3]   = tid_dti_dn_s3;
  assign tid_dti_dn_s_array[4]   = tid_dti_dn_s4;
  assign tid_dti_dn_s_array[5]   = tid_dti_dn_s5;
  assign tid_dti_dn_s_array[6]   = tid_dti_dn_s6;
  assign tid_dti_dn_s_array[7]   = tid_dti_dn_s7;
  assign tid_dti_dn_s_array[8]   = tid_dti_dn_s8;
  assign tid_dti_dn_s_array[9]   = tid_dti_dn_s9;
  assign tid_dti_dn_s_array[10]   = tid_dti_dn_s10;
  assign tid_dti_dn_s_array[11]   = tid_dti_dn_s11;
  assign tid_dti_dn_s_array[12]   = tid_dti_dn_s12;
  assign tid_dti_dn_s_array[13]   = tid_dti_dn_s13;
  assign tid_dti_dn_s_array[14]   = tid_dti_dn_s14;
  assign tid_dti_dn_s_array[15]   = tid_dti_dn_s15;
  assign tlast_dti_dn_s_array[0] = tlast_dti_dn_s0;
  assign tlast_dti_dn_s_array[1] = tlast_dti_dn_s1;
  assign tlast_dti_dn_s_array[2] = tlast_dti_dn_s2;
  assign tlast_dti_dn_s_array[3] = tlast_dti_dn_s3;
  assign tlast_dti_dn_s_array[4] = tlast_dti_dn_s4;
  assign tlast_dti_dn_s_array[5] = tlast_dti_dn_s5;
  assign tlast_dti_dn_s_array[6] = tlast_dti_dn_s6;
  assign tlast_dti_dn_s_array[7] = tlast_dti_dn_s7;
  assign tlast_dti_dn_s_array[8] = tlast_dti_dn_s8;
  assign tlast_dti_dn_s_array[9] = tlast_dti_dn_s9;
  assign tlast_dti_dn_s_array[10] = tlast_dti_dn_s10;
  assign tlast_dti_dn_s_array[11] = tlast_dti_dn_s11;
  assign tlast_dti_dn_s_array[12] = tlast_dti_dn_s12;
  assign tlast_dti_dn_s_array[13] = tlast_dti_dn_s13;
  assign tlast_dti_dn_s_array[14] = tlast_dti_dn_s14;
  assign tlast_dti_dn_s_array[15] = tlast_dti_dn_s15;

  assign {tvalid_dti_up_s15,
          tvalid_dti_up_s14,
          tvalid_dti_up_s13,
          tvalid_dti_up_s12,
          tvalid_dti_up_s11,
          tvalid_dti_up_s10,
          tvalid_dti_up_s9,
          tvalid_dti_up_s8,
          tvalid_dti_up_s7,
          tvalid_dti_up_s6,
          tvalid_dti_up_s5,
          tvalid_dti_up_s4,
          tvalid_dti_up_s3,
          tvalid_dti_up_s2,
          tvalid_dti_up_s1,
          tvalid_dti_up_s0} = tvalid_dti_up_s_vector;

  assign tready_dti_up_s_vector = {tready_dti_up_s15,
                                   tready_dti_up_s14,
                                   tready_dti_up_s13,
                                   tready_dti_up_s12,
                                   tready_dti_up_s11,
                                   tready_dti_up_s10,
                                   tready_dti_up_s9,
                                   tready_dti_up_s8,
                                   tready_dti_up_s7,
                                   tready_dti_up_s6,
                                   tready_dti_up_s5,
                                   tready_dti_up_s4,
                                   tready_dti_up_s3,
                                   tready_dti_up_s2,
                                   tready_dti_up_s1,
                                   tready_dti_up_s0};


  assign tdata_dti_up_s0 = tdata_dti_up_s_array[0];
  assign tdata_dti_up_s1 = tdata_dti_up_s_array[1];
  assign tdata_dti_up_s2 = tdata_dti_up_s_array[2];
  assign tdata_dti_up_s3 = tdata_dti_up_s_array[3];
  assign tdata_dti_up_s4 = tdata_dti_up_s_array[4];
  assign tdata_dti_up_s5 = tdata_dti_up_s_array[5];
  assign tdata_dti_up_s6 = tdata_dti_up_s_array[6];
  assign tdata_dti_up_s7 = tdata_dti_up_s_array[7];
  assign tdata_dti_up_s8 = tdata_dti_up_s_array[8];
  assign tdata_dti_up_s9 = tdata_dti_up_s_array[9];
  assign tdata_dti_up_s10 = tdata_dti_up_s_array[10];
  assign tdata_dti_up_s11 = tdata_dti_up_s_array[11];
  assign tdata_dti_up_s12 = tdata_dti_up_s_array[12];
  assign tdata_dti_up_s13 = tdata_dti_up_s_array[13];
  assign tdata_dti_up_s14 = tdata_dti_up_s_array[14];
  assign tdata_dti_up_s15 = tdata_dti_up_s_array[15];
  assign tkeep_dti_up_s0 = tkeep_dti_up_s_array[0];
  assign tkeep_dti_up_s1 = tkeep_dti_up_s_array[1];
  assign tkeep_dti_up_s2 = tkeep_dti_up_s_array[2];
  assign tkeep_dti_up_s3 = tkeep_dti_up_s_array[3];
  assign tkeep_dti_up_s4 = tkeep_dti_up_s_array[4];
  assign tkeep_dti_up_s5 = tkeep_dti_up_s_array[5];
  assign tkeep_dti_up_s6 = tkeep_dti_up_s_array[6];
  assign tkeep_dti_up_s7 = tkeep_dti_up_s_array[7];
  assign tkeep_dti_up_s8 = tkeep_dti_up_s_array[8];
  assign tkeep_dti_up_s9 = tkeep_dti_up_s_array[9];
  assign tkeep_dti_up_s10 = tkeep_dti_up_s_array[10];
  assign tkeep_dti_up_s11 = tkeep_dti_up_s_array[11];
  assign tkeep_dti_up_s12 = tkeep_dti_up_s_array[12];
  assign tkeep_dti_up_s13 = tkeep_dti_up_s_array[13];
  assign tkeep_dti_up_s14 = tkeep_dti_up_s_array[14];
  assign tkeep_dti_up_s15 = tkeep_dti_up_s_array[15];
  assign tdest_dti_up_s0 = tdest_dti_up_s_array[0];
  assign tdest_dti_up_s1 = tdest_dti_up_s_array[1];
  assign tdest_dti_up_s2 = tdest_dti_up_s_array[2];
  assign tdest_dti_up_s3 = tdest_dti_up_s_array[3];
  assign tdest_dti_up_s4 = tdest_dti_up_s_array[4];
  assign tdest_dti_up_s5 = tdest_dti_up_s_array[5];
  assign tdest_dti_up_s6 = tdest_dti_up_s_array[6];
  assign tdest_dti_up_s7 = tdest_dti_up_s_array[7];
  assign tdest_dti_up_s8 = tdest_dti_up_s_array[8];
  assign tdest_dti_up_s9 = tdest_dti_up_s_array[9];
  assign tdest_dti_up_s10 = tdest_dti_up_s_array[10];
  assign tdest_dti_up_s11 = tdest_dti_up_s_array[11];
  assign tdest_dti_up_s12 = tdest_dti_up_s_array[12];
  assign tdest_dti_up_s13 = tdest_dti_up_s_array[13];
  assign tdest_dti_up_s14 = tdest_dti_up_s_array[14];
  assign tdest_dti_up_s15 = tdest_dti_up_s_array[15];
  assign tlast_dti_up_s0 = tlast_dti_up_s_array[0];
  assign tlast_dti_up_s1 = tlast_dti_up_s_array[1];
  assign tlast_dti_up_s2 = tlast_dti_up_s_array[2];
  assign tlast_dti_up_s3 = tlast_dti_up_s_array[3];
  assign tlast_dti_up_s4 = tlast_dti_up_s_array[4];
  assign tlast_dti_up_s5 = tlast_dti_up_s_array[5];
  assign tlast_dti_up_s6 = tlast_dti_up_s_array[6];
  assign tlast_dti_up_s7 = tlast_dti_up_s_array[7];
  assign tlast_dti_up_s8 = tlast_dti_up_s_array[8];
  assign tlast_dti_up_s9 = tlast_dti_up_s_array[9];
  assign tlast_dti_up_s10 = tlast_dti_up_s_array[10];
  assign tlast_dti_up_s11 = tlast_dti_up_s_array[11];
  assign tlast_dti_up_s12 = tlast_dti_up_s_array[12];
  assign tlast_dti_up_s13 = tlast_dti_up_s_array[13];
  assign tlast_dti_up_s14 = tlast_dti_up_s_array[14];
  assign tlast_dti_up_s15 = tlast_dti_up_s_array[15];

  genvar dti_si;

  generate
    for (dti_si = 0; dti_si < NUM_SI; dti_si = dti_si + 1)
    begin : g_dti_dn_s_vectors
      assign tdata_dti_dn_s_vector[(dti_si*DATA_WIDTH)+:DATA_WIDTH] = tdata_dti_dn_s_array[dti_si];
      assign tkeep_dti_dn_s_vector[(dti_si*KEEP_WIDTH)+:KEEP_WIDTH] = tkeep_dti_dn_s_array[dti_si];
      assign tid_dti_dn_s_vector[(dti_si*ID_WIDTH)+:ID_WIDTH] = tid_dti_dn_s_array[dti_si];
      assign tlast_dti_dn_s_vector[(dti_si*LAST_WIDTH)+:LAST_WIDTH] = tlast_dti_dn_s_array[dti_si];

      assign tdata_dti_up_s_array[dti_si] = tdata_dti_up_s_vector[(dti_si*DATA_WIDTH)+:DATA_WIDTH];
      assign tkeep_dti_up_s_array[dti_si] = tkeep_dti_up_s_vector[(dti_si*KEEP_WIDTH)+:KEEP_WIDTH];
      assign tdest_dti_up_s_array[dti_si] = tdest_dti_up_s_vector[(dti_si*SID_WIDTH)+:SID_WIDTH];
      assign tlast_dti_up_s_array[dti_si] = tlast_dti_up_s_vector[(dti_si*LAST_WIDTH)+:LAST_WIDTH];
    end
  endgenerate

  assign twakeup_dti_dn_s_vector = {twakeup_dti_dn_s15,
                                   twakeup_dti_dn_s14,
                                   twakeup_dti_dn_s13,
                                   twakeup_dti_dn_s12,
                                   twakeup_dti_dn_s11,
                                   twakeup_dti_dn_s10,
                                   twakeup_dti_dn_s9,
                                   twakeup_dti_dn_s8,
                                   twakeup_dti_dn_s7,
                                   twakeup_dti_dn_s6,
                                   twakeup_dti_dn_s5,
                                   twakeup_dti_dn_s4,
                                   twakeup_dti_dn_s3,
                                   twakeup_dti_dn_s2,
                                   twakeup_dti_dn_s1,
                                   twakeup_dti_dn_s0};

  assign {twakeup_dti_up_s15,
          twakeup_dti_up_s14,
          twakeup_dti_up_s13,
          twakeup_dti_up_s12,
          twakeup_dti_up_s11,
          twakeup_dti_up_s10,
          twakeup_dti_up_s9,
          twakeup_dti_up_s8,
          twakeup_dti_up_s7,
          twakeup_dti_up_s6,
          twakeup_dti_up_s5,
          twakeup_dti_up_s4,
          twakeup_dti_up_s3,
          twakeup_dti_up_s2,
          twakeup_dti_up_s1,
          twakeup_dti_up_s0} = twakeup_dti_up_s_vector;


  firewall_f0_bas_switch_core
   #(
     .NUM_SI        (NUM_SI),
     .DATA_WIDTH    (DATA_WIDTH),
     .ID_WIDTH      (ID_WIDTH),
     .DECMIN_SI0  (DECMIN_SI0),
     .DECMIN_SI1  (DECMIN_SI1),
     .DECMIN_SI2  (DECMIN_SI2),
     .DECMIN_SI3  (DECMIN_SI3),
     .DECMIN_SI4  (DECMIN_SI4),
     .DECMIN_SI5  (DECMIN_SI5),
     .DECMIN_SI6  (DECMIN_SI6),
     .DECMIN_SI7  (DECMIN_SI7),
     .DECMIN_SI8  (DECMIN_SI8),
     .DECMIN_SI9  (DECMIN_SI9),
     .DECMIN_SI10  (DECMIN_SI10),
     .DECMIN_SI11  (DECMIN_SI11),
     .DECMIN_SI12  (DECMIN_SI12),
     .DECMIN_SI13  (DECMIN_SI13),
     .DECMIN_SI14  (DECMIN_SI14),
     .DECMIN_SI15  (DECMIN_SI15),
     .DECMAX_SI0  (DECMAX_SI0),
     .DECMAX_SI1  (DECMAX_SI1),
     .DECMAX_SI2  (DECMAX_SI2),
     .DECMAX_SI3  (DECMAX_SI3),
     .DECMAX_SI4  (DECMAX_SI4),
     .DECMAX_SI5  (DECMAX_SI5),
     .DECMAX_SI6  (DECMAX_SI6),
     .DECMAX_SI7  (DECMAX_SI7),
     .DECMAX_SI8  (DECMAX_SI8),
     .DECMAX_SI9  (DECMAX_SI9),
     .DECMAX_SI10  (DECMAX_SI10),
     .DECMAX_SI11  (DECMAX_SI11),
     .DECMAX_SI12  (DECMAX_SI12),
     .DECMAX_SI13  (DECMAX_SI13),
     .DECMAX_SI14  (DECMAX_SI14),
     .DECMAX_SI15  (DECMAX_SI15)
    )
  u_bas_switch_core
    (
     .aclk              (aclk),
     .aresetn           (aresetn),

     .tvalid_dti_dn_s  (tvalid_dti_dn_s_vector),
     .tready_dti_dn_s  (tready_dti_dn_s_vector),
     .tdata_dti_dn_s   (tdata_dti_dn_s_vector),
     .tkeep_dti_dn_s   (tkeep_dti_dn_s_vector),
     .tid_dti_dn_s     (tid_dti_dn_s_vector),
     .tlast_dti_dn_s   (tlast_dti_dn_s_vector),

     .tvalid_dti_dn_m  (tvalid_dti_dn_m),
     .tready_dti_dn_m  (tready_dti_dn_m),
     .tdata_dti_dn_m   (tdata_dti_dn_m),
     .tkeep_dti_dn_m   (tkeep_dti_dn_m),
     .tid_dti_dn_m     (tid_dti_dn_m),
     .tlast_dti_dn_m   (tlast_dti_dn_m),

     .tvalid_dti_up_s  (tvalid_dti_up_s_vector),
     .tready_dti_up_s  (tready_dti_up_s_vector),
     .tdata_dti_up_s   (tdata_dti_up_s_vector),
     .tkeep_dti_up_s   (tkeep_dti_up_s_vector),
     .tdest_dti_up_s   (tdest_dti_up_s_vector),
     .tlast_dti_up_s   (tlast_dti_up_s_vector),

     .tvalid_dti_up_m  (tvalid_dti_up_m),
     .tready_dti_up_m  (tready_dti_up_m),
     .tdata_dti_up_m   (tdata_dti_up_m),
     .tkeep_dti_up_m   (tkeep_dti_up_m),
     .tdest_dti_up_m   (tdest_dti_up_m),
     .tlast_dti_up_m   (tlast_dti_up_m),

     .twakeup_dti_dn_s (twakeup_dti_dn_s_vector),
     .twakeup_dti_dn_m (twakeup_dti_dn_m),
     .twakeup_dti_up_s (twakeup_dti_up_s_vector),
     .twakeup_dti_up_m (twakeup_dti_up_m)

    );

endmodule

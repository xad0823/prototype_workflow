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




module sse710_bas_switch_2x1
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

  tvalid_dti_up_m,
  tready_dti_up_m,
  tdata_dti_up_m,
  tkeep_dti_up_m,
  tdest_dti_up_m,
  tlast_dti_up_m,


  twakeup_dti_dn_s0,
  twakeup_dti_dn_s1,
  twakeup_dti_dn_m,

  twakeup_dti_up_s0,
  twakeup_dti_up_s1,
  twakeup_dti_up_m

  );


  parameter DATA_WIDTH = 8;
  parameter ID_WIDTH   = 1;

  parameter DECMIN_SI0  = 0;
  parameter DECMAX_SI0  = DECMIN_SI0;
  parameter DECMIN_SI1  = 1;
  parameter DECMAX_SI1  = DECMIN_SI1;



  localparam NUM_SI = 2;

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

  input  wire                  tvalid_dti_up_m;
  output wire                  tready_dti_up_m;
  input  wire [DATA_WIDTH-1:0] tdata_dti_up_m;
  input  wire [KEEP_WIDTH-1:0] tkeep_dti_up_m;
  input  wire  [MID_WIDTH-1:0] tdest_dti_up_m;
  input  wire                  tlast_dti_up_m;


  input  wire twakeup_dti_dn_s0;
  input  wire twakeup_dti_dn_s1;
  output wire twakeup_dti_dn_m;

  output wire twakeup_dti_up_s0;
  output wire twakeup_dti_up_s1;
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


  assign tvalid_dti_dn_s_vector = {tvalid_dti_dn_s1,
                                   tvalid_dti_dn_s0};

  assign {tready_dti_dn_s1,
          tready_dti_dn_s0} = tready_dti_dn_s_vector;


  assign tdata_dti_dn_s_array[0] = tdata_dti_dn_s0;
  assign tdata_dti_dn_s_array[1] = tdata_dti_dn_s1;
  assign tkeep_dti_dn_s_array[0] = tkeep_dti_dn_s0;
  assign tkeep_dti_dn_s_array[1] = tkeep_dti_dn_s1;
  assign tid_dti_dn_s_array[0]   = tid_dti_dn_s0;
  assign tid_dti_dn_s_array[1]   = tid_dti_dn_s1;
  assign tlast_dti_dn_s_array[0] = tlast_dti_dn_s0;
  assign tlast_dti_dn_s_array[1] = tlast_dti_dn_s1;

  assign {tvalid_dti_up_s1,
          tvalid_dti_up_s0} = tvalid_dti_up_s_vector;

  assign tready_dti_up_s_vector = {tready_dti_up_s1,
                                   tready_dti_up_s0};


  assign tdata_dti_up_s0 = tdata_dti_up_s_array[0];
  assign tdata_dti_up_s1 = tdata_dti_up_s_array[1];
  assign tkeep_dti_up_s0 = tkeep_dti_up_s_array[0];
  assign tkeep_dti_up_s1 = tkeep_dti_up_s_array[1];
  assign tdest_dti_up_s0 = tdest_dti_up_s_array[0];
  assign tdest_dti_up_s1 = tdest_dti_up_s_array[1];
  assign tlast_dti_up_s0 = tlast_dti_up_s_array[0];
  assign tlast_dti_up_s1 = tlast_dti_up_s_array[1];

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

  assign twakeup_dti_dn_s_vector = {twakeup_dti_dn_s1,
                                   twakeup_dti_dn_s0};

  assign {twakeup_dti_up_s1,
          twakeup_dti_up_s0} = twakeup_dti_up_s_vector;


  sse710_bas_switch_core
   #(
     .NUM_SI        (NUM_SI),
     .DATA_WIDTH    (DATA_WIDTH),
     .ID_WIDTH      (ID_WIDTH),
     .DECMIN_SI0  (DECMIN_SI0),
     .DECMIN_SI1  (DECMIN_SI1),
     .DECMAX_SI0  (DECMAX_SI0),
     .DECMAX_SI1  (DECMAX_SI1)
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


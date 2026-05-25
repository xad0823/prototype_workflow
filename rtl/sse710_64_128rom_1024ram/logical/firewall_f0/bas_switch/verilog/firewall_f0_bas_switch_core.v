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


module firewall_f0_bas_switch_core
  (
  aclk,
  aresetn,


  tvalid_dti_dn_s,
  tready_dti_dn_s,
  tdata_dti_dn_s,
  tkeep_dti_dn_s,
  tid_dti_dn_s,
  tlast_dti_dn_s,

  tvalid_dti_dn_m,
  tready_dti_dn_m,
  tdata_dti_dn_m,
  tkeep_dti_dn_m,
  tid_dti_dn_m,
  tlast_dti_dn_m,


  tvalid_dti_up_s,
  tready_dti_up_s,
  tdata_dti_up_s,
  tkeep_dti_up_s,
  tdest_dti_up_s,
  tlast_dti_up_s,

  tvalid_dti_up_m,
  tready_dti_up_m,
  tdata_dti_up_m,
  tkeep_dti_up_m,
  tdest_dti_up_m,
  tlast_dti_up_m,

  twakeup_dti_dn_s,
  twakeup_dti_dn_m,

  twakeup_dti_up_s,
  twakeup_dti_up_m

  );


  parameter NUM_SI      = 2;  
  parameter DATA_WIDTH  = 8;  
  parameter ID_WIDTH    = 1;  

  parameter DECMIN_SI0  = 0;
  parameter DECMIN_SI1  = 1;
  parameter DECMIN_SI2  = 2;
  parameter DECMIN_SI3  = 3;
  parameter DECMIN_SI4  = 4;
  parameter DECMIN_SI5  = 5;
  parameter DECMIN_SI6  = 6;
  parameter DECMIN_SI7  = 7;
  parameter DECMIN_SI8  = 8;
  parameter DECMIN_SI9  = 9;
  parameter DECMIN_SI10 = 10;
  parameter DECMIN_SI11 = 11;
  parameter DECMIN_SI12 = 12;
  parameter DECMIN_SI13 = 13;
  parameter DECMIN_SI14 = 14;
  parameter DECMIN_SI15 = 15;

  parameter DECMAX_SI0  = 0;
  parameter DECMAX_SI1  = 1;
  parameter DECMAX_SI2  = 2;
  parameter DECMAX_SI3  = 3;
  parameter DECMAX_SI4  = 4;
  parameter DECMAX_SI5  = 5;
  parameter DECMAX_SI6  = 6;
  parameter DECMAX_SI7  = 7;
  parameter DECMAX_SI8  = 8;
  parameter DECMAX_SI9  = 9;
  parameter DECMAX_SI10 = 10;
  parameter DECMAX_SI11 = 11;
  parameter DECMAX_SI12 = 12;
  parameter DECMAX_SI13 = 13;
  parameter DECMAX_SI14 = 14;
  parameter DECMAX_SI15 = 15;


  localparam KEEP_WIDTH = DATA_WIDTH / 8;
  localparam LAST_WIDTH = 1;  
  localparam SID_WIDTH = ID_WIDTH;
  localparam MID_WIDTH = ID_WIDTH;
  localparam SPAYLOAD_WIDTH = DATA_WIDTH + KEEP_WIDTH + SID_WIDTH + LAST_WIDTH;
  localparam MPAYLOAD_WIDTH = DATA_WIDTH + KEEP_WIDTH + MID_WIDTH + LAST_WIDTH;

  localparam DATA_LSB = 0;
  localparam DATA_MSB = DATA_WIDTH - 1;
  localparam KEEP_LSB = DATA_MSB + 1;
  localparam KEEP_MSB = KEEP_LSB + KEEP_WIDTH - 1;
  localparam DEST_LSB = KEEP_MSB + 1;
  localparam DEST_MSB = DEST_LSB + SID_WIDTH - 1;
  localparam LAST_LSB = DEST_MSB + 1;
  localparam LAST_MSB = LAST_LSB + LAST_WIDTH - 1;

  localparam NUM_ENDPOINTS_SI0  = DECMAX_SI0  - DECMIN_SI0  + 1;
  localparam NUM_ENDPOINTS_SI1  = DECMAX_SI1  - DECMIN_SI1  + 1;
  localparam NUM_ENDPOINTS_SI2  = DECMAX_SI2  - DECMIN_SI2  + 1;
  localparam NUM_ENDPOINTS_SI3  = DECMAX_SI3  - DECMIN_SI3  + 1;
  localparam NUM_ENDPOINTS_SI4  = DECMAX_SI4  - DECMIN_SI4  + 1;
  localparam NUM_ENDPOINTS_SI5  = DECMAX_SI5  - DECMIN_SI5  + 1;
  localparam NUM_ENDPOINTS_SI6  = DECMAX_SI6  - DECMIN_SI6  + 1;
  localparam NUM_ENDPOINTS_SI7  = DECMAX_SI7  - DECMIN_SI7  + 1;
  localparam NUM_ENDPOINTS_SI8  = DECMAX_SI8  - DECMIN_SI8  + 1;
  localparam NUM_ENDPOINTS_SI9  = DECMAX_SI9  - DECMIN_SI9  + 1;
  localparam NUM_ENDPOINTS_SI10 = DECMAX_SI10 - DECMIN_SI10 + 1;
  localparam NUM_ENDPOINTS_SI11 = DECMAX_SI11 - DECMIN_SI11 + 1;
  localparam NUM_ENDPOINTS_SI12 = DECMAX_SI12 - DECMIN_SI12 + 1;
  localparam NUM_ENDPOINTS_SI13 = DECMAX_SI13 - DECMIN_SI13 + 1;
  localparam NUM_ENDPOINTS_SI14 = DECMAX_SI14 - DECMIN_SI14 + 1;
  localparam NUM_ENDPOINTS_SI15 = DECMAX_SI15 - DECMIN_SI15 + 1;

  localparam [511:0]     DECMIN = {DECMIN_SI15[31:0],
                                   DECMIN_SI14[31:0],
                                   DECMIN_SI13[31:0],
                                   DECMIN_SI12[31:0],
                                   DECMIN_SI11[31:0],
                                   DECMIN_SI10[31:0],
                                   DECMIN_SI9[31:0],
                                   DECMIN_SI8[31:0],
                                   DECMIN_SI7[31:0],
                                   DECMIN_SI6[31:0],
                                   DECMIN_SI5[31:0],
                                   DECMIN_SI4[31:0],
                                   DECMIN_SI3[31:0],
                                   DECMIN_SI2[31:0],
                                   DECMIN_SI1[31:0],
                                   DECMIN_SI0[31:0]};

  localparam [511:0]     DECMAX = {DECMAX_SI15[31:0],
                                   DECMAX_SI14[31:0],
                                   DECMAX_SI13[31:0],
                                   DECMAX_SI12[31:0],
                                   DECMAX_SI11[31:0],
                                   DECMAX_SI10[31:0],
                                   DECMAX_SI9[31:0],
                                   DECMAX_SI8[31:0],
                                   DECMAX_SI7[31:0],
                                   DECMAX_SI6[31:0],
                                   DECMAX_SI5[31:0],
                                   DECMAX_SI4[31:0],
                                   DECMAX_SI3[31:0],
                                   DECMAX_SI2[31:0],
                                   DECMAX_SI1[31:0],
                                   DECMAX_SI0[31:0]};

  localparam [511:0]  ENDPOINTS = {NUM_ENDPOINTS_SI15[31:0],
                                   NUM_ENDPOINTS_SI14[31:0],
                                   NUM_ENDPOINTS_SI13[31:0],
                                   NUM_ENDPOINTS_SI12[31:0],
                                   NUM_ENDPOINTS_SI11[31:0],
                                   NUM_ENDPOINTS_SI10[31:0],
                                   NUM_ENDPOINTS_SI9[31:0],
                                   NUM_ENDPOINTS_SI8[31:0],
                                   NUM_ENDPOINTS_SI7[31:0],
                                   NUM_ENDPOINTS_SI6[31:0],
                                   NUM_ENDPOINTS_SI5[31:0],
                                   NUM_ENDPOINTS_SI4[31:0],
                                   NUM_ENDPOINTS_SI3[31:0],
                                   NUM_ENDPOINTS_SI2[31:0],
                                   NUM_ENDPOINTS_SI1[31:0],
                                   NUM_ENDPOINTS_SI0[31:0]};

  input  wire aclk;
  input  wire aresetn;


  input  wire              [NUM_SI-1:0] tvalid_dti_dn_s;
  output wire              [NUM_SI-1:0] tready_dti_dn_s;
  input  wire [(NUM_SI*DATA_WIDTH)-1:0] tdata_dti_dn_s;

  input  wire [(NUM_SI*KEEP_WIDTH)-1:0] tkeep_dti_dn_s;



  input  wire  [(NUM_SI*SID_WIDTH)-1:0] tid_dti_dn_s;


  input  wire              [NUM_SI-1:0] tlast_dti_dn_s;


  output wire                           tvalid_dti_dn_m;
  input  wire                           tready_dti_dn_m;
  output wire          [DATA_WIDTH-1:0] tdata_dti_dn_m;
  output wire          [KEEP_WIDTH-1:0] tkeep_dti_dn_m;
  output wire           [MID_WIDTH-1:0] tid_dti_dn_m;
  output wire                           tlast_dti_dn_m;


  output wire              [NUM_SI-1:0] tvalid_dti_up_s;
  input  wire              [NUM_SI-1:0] tready_dti_up_s;
  output wire [(NUM_SI*DATA_WIDTH)-1:0] tdata_dti_up_s;
  output wire [(NUM_SI*KEEP_WIDTH)-1:0] tkeep_dti_up_s;
  output wire  [(NUM_SI*SID_WIDTH)-1:0] tdest_dti_up_s;
  output wire              [NUM_SI-1:0] tlast_dti_up_s;

  input  wire                           tvalid_dti_up_m;
  output wire                           tready_dti_up_m;
  input  wire          [DATA_WIDTH-1:0] tdata_dti_up_m;
  input  wire          [KEEP_WIDTH-1:0] tkeep_dti_up_m;
  input  wire           [MID_WIDTH-1:0] tdest_dti_up_m;
  input  wire                           tlast_dti_up_m;


  input  wire [NUM_SI-1:0] twakeup_dti_dn_s;
  output wire              twakeup_dti_dn_m;

  output reg  [NUM_SI-1:0] twakeup_dti_up_s;
  input  wire              twakeup_dti_up_m;


  wire [MPAYLOAD_WIDTH-1:0] tpayld_dn_array [NUM_SI-1:0];
  wire [MPAYLOAD_WIDTH-1:0] tpayld_dn_m;
  wire [NUM_SI-1:0]         dn_grant_vector;
  wire [ID_WIDTH-1:0]       tid_dti_dn_s_internal [NUM_SI-1:0];

  wire set_stickiness;
  wire clear_stickiness;
  reg  sticky_q;
  wire sticky_nxt;
  wire sticky_en;

  wire [NUM_SI-1:0] dn_req_vector;
  reg  [NUM_SI-1:0] req_mask_q;
  wire [NUM_SI-1:0] req_mask_nxt;

  wire [NUM_SI-1:0] tpayld_dn_array_t [MPAYLOAD_WIDTH-1:0];

  wire [SPAYLOAD_WIDTH-1:0] tpayld_up_array [NUM_SI-1:0];
  wire [SPAYLOAD_WIDTH-1:0] tpayld_up_m;
  wire [NUM_SI-1:0]         id_gte_min;
  wire [NUM_SI-1:0]         id_lte_max;
  wire [NUM_SI-1:0]         up_sel_vector;


  wire                     unused_twakeup_dti_up_m;
  reg                      twakeup_dti_dn;

  genvar dti_si;


  generate
    for (dti_si = 0; dti_si < NUM_SI; dti_si = dti_si + 1)
    begin : g_tpayld_dn_concat

      assign tpayld_dn_array[dti_si] = {tlast_dti_dn_s[(dti_si*LAST_WIDTH)+:LAST_WIDTH],
                                        tid_dti_dn_s_internal[dti_si],
                                        tkeep_dti_dn_s[(dti_si*KEEP_WIDTH)+:KEEP_WIDTH],
                                        tdata_dti_dn_s[(dti_si*DATA_WIDTH)+:DATA_WIDTH]};

    end
  endgenerate

  assign {tlast_dti_dn_m,
          tid_dti_dn_m,
          tkeep_dti_dn_m,
          tdata_dti_dn_m} = tpayld_dn_m;

  generate
    for (dti_si = 0; dti_si < NUM_SI; dti_si = dti_si + 1)
    begin : g_tpayld_up_concat

      assign tlast_dti_up_s[(dti_si*LAST_WIDTH)+:LAST_WIDTH] = tpayld_up_array[dti_si][LAST_MSB:LAST_LSB];
      assign tdest_dti_up_s[(dti_si*SID_WIDTH )+:SID_WIDTH ] = tpayld_up_array[dti_si][DEST_MSB:DEST_LSB];
      assign tkeep_dti_up_s[(dti_si*KEEP_WIDTH)+:KEEP_WIDTH] = tpayld_up_array[dti_si][KEEP_MSB:KEEP_LSB];
      assign tdata_dti_up_s[(dti_si*DATA_WIDTH)+:DATA_WIDTH] = tpayld_up_array[dti_si][DATA_MSB:DATA_LSB];


    end
  endgenerate

  assign tpayld_up_m = {tlast_dti_up_m,
                        tdest_dti_up_m,
                        tkeep_dti_up_m,
                        tdata_dti_up_m};


  assign set_stickiness = |tvalid_dti_dn_s;

  assign clear_stickiness = tvalid_dti_dn_m & tready_dti_dn_m & tlast_dti_dn_m;

  assign dn_req_vector = tvalid_dti_dn_s & req_mask_q;

  assign tvalid_dti_dn_m = |dn_req_vector;

  assign tready_dti_dn_s = dn_grant_vector & {NUM_SI{tready_dti_dn_m}};

  assign req_mask_nxt = dn_grant_vector | ({NUM_SI{clear_stickiness}});

  assign sticky_nxt = ~clear_stickiness & (set_stickiness | sticky_q);

  assign sticky_en = sticky_q ? clear_stickiness : set_stickiness;

  always @(posedge aclk or negedge aresetn)
  begin
    if (!aresetn)
    begin
      sticky_q <= 1'b0;                 
      req_mask_q <= {NUM_SI{1'b1}};     
    end
    else if (sticky_en)
    begin
      sticky_q <= sticky_nxt;
      req_mask_q <= req_mask_nxt;
    end
  end

  genvar data_bit;
  generate
    for(data_bit = 0; data_bit<MPAYLOAD_WIDTH; data_bit = data_bit + 1)
    begin : g_transpose_width
      for(dti_si = 0; dti_si<NUM_SI; dti_si = dti_si + 1)
      begin : g_transpose_ways
        assign tpayld_dn_array_t[data_bit][dti_si] = tpayld_dn_array[dti_si][data_bit];
      end
      assign tpayld_dn_m[data_bit] = |(tpayld_dn_array_t[data_bit] & dn_grant_vector);

    end
  endgenerate

  firewall_f0_arbiter_fair
   #(
     .WAYS (NUM_SI),
     .ARBITER_POLICY (3) 
    )
  u_arb
    (
     .clk       (aclk),
     .resetn    (aresetn),
     .update_i  (clear_stickiness),
     .request_i (dn_req_vector),
     .grant_o   (dn_grant_vector)
    );

  generate
    for (dti_si = 0; dti_si < NUM_SI; dti_si = dti_si + 1)
    begin : g_downstream_dti_si
      if (ENDPOINTS[dti_si*32 +: 32] == 1) begin : g_single_endpoint

        wire  [(NUM_SI*SID_WIDTH)-1:0] unused_tid_dti_dn_s;

        assign unused_tid_dti_dn_s = tid_dti_dn_s;


        assign tid_dti_dn_s_internal[dti_si] = DECMIN[32*dti_si +: SID_WIDTH];

      end
      else
      begin : g_multi_endpoint
        wire [ID_WIDTH:0] tid_dti_dn_s_internal_snc;

        assign tid_dti_dn_s_internal_snc     = {1'b0, tid_dti_dn_s[(dti_si*SID_WIDTH)+:SID_WIDTH]} +
                                               {1'b0, DECMIN[32*dti_si +: SID_WIDTH]};


        assign tid_dti_dn_s_internal[dti_si] = tid_dti_dn_s_internal_snc[ID_WIDTH-1:0];

        wire unused_tid_dti_dn_s_internal_snc_ovflw;

        assign unused_tid_dti_dn_s_internal_snc_ovflw = tid_dti_dn_s_internal_snc[ID_WIDTH];


      end
    end
  endgenerate

  assign tvalid_dti_up_s = {NUM_SI{tvalid_dti_up_m}} & up_sel_vector;

  assign tready_dti_up_m = tvalid_dti_up_m & |(tready_dti_up_s & up_sel_vector);

  generate
    for (dti_si = 0; dti_si < NUM_SI; dti_si = dti_si + 1)
    begin : g_upstream_dti_si

      assign tpayld_up_array[dti_si][LAST_MSB:LAST_LSB] = tpayld_up_m[LAST_MSB:LAST_LSB];
      assign tpayld_up_array[dti_si][DEST_MSB:DEST_LSB] = tpayld_up_m[DEST_MSB:DEST_LSB] - DECMIN[dti_si*32 +:SID_WIDTH];
      assign tpayld_up_array[dti_si][KEEP_MSB:KEEP_LSB] = tpayld_up_m[KEEP_MSB:KEEP_LSB];
      assign tpayld_up_array[dti_si][DATA_MSB:DATA_LSB] = tpayld_up_m[DATA_MSB:DATA_LSB];

      assign id_gte_min[dti_si] = (tdest_dti_up_m >= DECMIN[dti_si*32 +: MID_WIDTH]);
      assign id_lte_max[dti_si] = (tdest_dti_up_m <= DECMAX[dti_si*32 +: MID_WIDTH]);


    end
  endgenerate

  assign up_sel_vector = id_gte_min & id_lte_max;


  always @(posedge aclk or negedge aresetn)
  begin
    if (!aresetn)
      twakeup_dti_dn <= 1'b0;
    else
      twakeup_dti_dn <= tvalid_dti_dn_m;
  end

  firewall_f0_or_tree #(
    .ACTIVE_WIDTH (NUM_SI+1)
  ) u_firewall_f0_bas_switch_dn_m_wakeup_or2tree (
    .actives_i ({twakeup_dti_dn_s, twakeup_dti_dn}),
    .active_o  (twakeup_dti_dn_m)
  );

  assign unused_twakeup_dti_up_m = twakeup_dti_up_m;

  always @(posedge aclk or negedge aresetn)
  begin
    if (!aresetn)
      twakeup_dti_up_s <= {NUM_SI{1'b0}};
    else
      twakeup_dti_up_s <= tvalid_dti_up_s;
  end

endmodule

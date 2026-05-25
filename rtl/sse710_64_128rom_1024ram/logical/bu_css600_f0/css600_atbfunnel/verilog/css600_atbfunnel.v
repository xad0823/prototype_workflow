//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Top level of css600_atbfunnel
//
//----------------------------------------------------------------------------


module css600_atbfunnel #(parameter
  ATB_DATA_WIDTH = 32,
  NUM_ATB_SLAVES = 8
)
(
  clk,
  reset_n,

  atwakeup_s,
  atvalid_s,
  afready_s,
  atid_s,
  atdata_s,
  atbytes_s,

  atready_m,
  afvalid_m,
  syncreq_m,

  atwakeup_m,
  atvalid_m,
  afready_m,
  atid_m,
  atdata_m,
  atbytes_m,

  atready_s,
  afvalid_s,
  syncreq_s,

  clk_qactive

);

function integer atb_clog2 (input integer num);
  integer i;
  begin
    atb_clog2 = 0;
    for(i=num; i>1; i=i>>1)
      atb_clog2 = atb_clog2 + 1;
  end
endfunction


  localparam ATB_DATA_WIDTH_LOC =  (
                                          (ATB_DATA_WIDTH ==  8)  ||
                                          (ATB_DATA_WIDTH == 16)  ||
                                          (ATB_DATA_WIDTH == 32)  ||
                                          (ATB_DATA_WIDTH == 64)  ||
                                          (ATB_DATA_WIDTH == 128)
                                         ) ? ATB_DATA_WIDTH : 32;

  localparam NUM_ATB_SLAVES_LOC =  (
                                          (NUM_ATB_SLAVES == 2)  ||
                                          (NUM_ATB_SLAVES == 3)  ||
                                          (NUM_ATB_SLAVES == 4)  ||
                                          (NUM_ATB_SLAVES == 5)  ||
                                          (NUM_ATB_SLAVES == 6)  ||
                                          (NUM_ATB_SLAVES == 7)  ||
                                          (NUM_ATB_SLAVES == 8)
                                         ) ? NUM_ATB_SLAVES : 8;


  localparam ATBYTES_WIDTH = (ATB_DATA_WIDTH_LOC > 8) ? (atb_clog2(ATB_DATA_WIDTH_LOC)-3) : 1;


  localparam CSS600_FUNNEL_FIXED_CONFIG_HOLD_TIME = 4'b0011;

  localparam NUM_OR_IN_QACTIVE = NUM_ATB_SLAVES_LOC + 1;


  input wire         clk;
  input wire         reset_n;

  input wire [NUM_ATB_SLAVES_LOC-1:0]                     atwakeup_s;
  input wire [NUM_ATB_SLAVES_LOC-1:0]                     atvalid_s;
  input wire [NUM_ATB_SLAVES_LOC-1:0]                     afready_s;
  input wire [7*NUM_ATB_SLAVES_LOC-1:0]                     atid_s;
  input wire [NUM_ATB_SLAVES_LOC*ATB_DATA_WIDTH_LOC-1:0]  atdata_s;
  input wire [NUM_ATB_SLAVES_LOC*ATBYTES_WIDTH-1:0]       atbytes_s;

  input wire                            atready_m;
  input wire                            afvalid_m;
  input wire                            syncreq_m;


  output wire                           atwakeup_m;
  output wire                           atvalid_m;
  output wire                           afready_m;
  output wire [6:0]                     atid_m;
  output wire [ATB_DATA_WIDTH_LOC-1:0]  atdata_m;
  output wire [ATBYTES_WIDTH-1:0]       atbytes_m;

  output wire [NUM_ATB_SLAVES_LOC-1:0]  atready_s;
  output wire [NUM_ATB_SLAVES_LOC-1:0]  afvalid_s;
  output wire [NUM_ATB_SLAVES_LOC-1:0]  syncreq_s;

  output wire                           clk_qactive;


  wire [NUM_ATB_SLAVES_LOC-1:0]   en_port;
  wire [3*NUM_ATB_SLAVES_LOC-1:0] pri_port;

  wire [3:0]                      min_hold_time;


  assign min_hold_time = CSS600_FUNNEL_FIXED_CONFIG_HOLD_TIME;
  assign en_port = {NUM_ATB_SLAVES_LOC{1'b1}};
  assign pri_port = {NUM_ATB_SLAVES_LOC{3'b000}};

  css600_atbfunnel_arbiter
    #(
     .ATB_DATA_WIDTH           (ATB_DATA_WIDTH_LOC),
     .ATBYTES_WIDTH            (ATBYTES_WIDTH),
     .NUM_ATB_SLAVES           (NUM_ATB_SLAVES_LOC))
    u_css600_atbfunnel_arbiter
     (
     .clk                               (clk),
     .reset_n                           (reset_n),

     .atvalid_s                         (atvalid_s),
     .afready_s                         (afready_s),
     .atid_s                            (atid_s),
     .atdata_s                          (atdata_s),
     .atbytes_s                         (atbytes_s),

     .atready_m                         (atready_m),
     .afvalid_m                         (afvalid_m),
     .syncreq_m                         (syncreq_m),

     .afready_m                         (afready_m),
     .atvalid_m                         (atvalid_m),
     .atbytes_m                         (atbytes_m),
     .atid_m                            (atid_m),
     .atdata_m                          (atdata_m),

     .atready_s                         (atready_s),
     .afvalid_s                         (afvalid_s),
     .syncreq_s                         (syncreq_s),

     .min_hold_time                     (min_hold_time),
     .en_port                           (en_port),
     .pri_port                          (pri_port),

     .atwakeup_s                        (atwakeup_s),
     .atwakeup_m                        (atwakeup_m)
    );

  css600_or_tree
  #(
    .NUM_OR_INPUTS (NUM_OR_IN_QACTIVE)
  ) u_qactive_async
  (
    .or_inputs({atwakeup_s, afvalid_m}),
    .or_output(clk_qactive)
  );


endmodule

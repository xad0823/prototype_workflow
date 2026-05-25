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
//   Top level of css600_atbbuffer
//
//----------------------------------------------------------------------------


module css600_atbbuffer #(parameter
  ATB_DATA_WIDTH = 32,
  BUFFER_DEPTH   = 2,
  MIN_HOLD_TIME  = 1
)
(
  clk,
  reset_n,
  atwakeup_s,
  atvalid_s,
  atready_s,
  atid_s,
  atdata_s,
  atbytes_s,
  afready_s,
  afvalid_s,
  afready_m,
  afvalid_m,
  syncreq_s,
  atwakeup_m,
  atvalid_m,
  atready_m,
  atid_m,
  atdata_m,
  atbytes_m,
  syncreq_m,
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

  localparam BUFFER_DEPTH_LOC =  (
                                          (BUFFER_DEPTH == 2)  ||
                                          (BUFFER_DEPTH == 4)  ||
                                          (BUFFER_DEPTH == 8)  ||
                                          (BUFFER_DEPTH == 16)  ||
                                          (BUFFER_DEPTH == 32)  ||
                                          (BUFFER_DEPTH == 64)  ||
                                          (BUFFER_DEPTH == 128) ||
                                          (BUFFER_DEPTH == 256)
                                         ) ? BUFFER_DEPTH : 2;

  localparam MIN_HOLD_TIME_LOC =  (
                                          (MIN_HOLD_TIME <  17)  &&
                                          (MIN_HOLD_TIME >   1)
                                         ) ? MIN_HOLD_TIME : 1;


  localparam ATBYTES_WIDTH = (ATB_DATA_WIDTH_LOC > 8) ? (atb_clog2(ATB_DATA_WIDTH_LOC)-3) : 1;


  input wire                        clk;
  input wire                        reset_n;

  input wire                        atwakeup_s;
  input wire                        atvalid_s;
  input wire                        atready_m;
  input wire [6:0]                  atid_s;
  input wire [ATB_DATA_WIDTH_LOC-1:0]   atdata_s;
  input wire [ATBYTES_WIDTH-1:0]    atbytes_s;

  input wire                        afready_s;
  input wire                        afvalid_m;
  input wire                        syncreq_m;
  output wire                       atwakeup_m;
  output wire                       atvalid_m;
  output wire                       atready_s;
  output wire [6:0]                 atid_m;
  output wire [ATB_DATA_WIDTH_LOC-1:0]  atdata_m;
  output wire  [ATBYTES_WIDTH-1:0]  atbytes_m;

  output wire                       afready_m;
  output wire                       afvalid_s;

  output wire                       syncreq_s;

  output wire                       clk_qactive;


  css600_or u_qactive_async (
    .in_a(atwakeup_s),
    .in_b(afvalid_m),
    .out_y(clk_qactive)
  );

  css600_atbbuffer_core
  #(
  .ATB_DATA_WIDTH(ATB_DATA_WIDTH_LOC),
  .BUFFER_DEPTH(BUFFER_DEPTH_LOC),
  .MIN_HOLD_TIME(MIN_HOLD_TIME_LOC)
  )
  u_css600_tbuff_core
  (
    .clk        (clk),
    .reset_n    (reset_n),

    .atvalid_s  (atvalid_s),
    .atready_s  (atready_s),
    .atid_s     (atid_s),
    .atdata_s   (atdata_s),
    .atbytes_s  (atbytes_s),

    .afready_s  (afready_s),
    .afvalid_s  (afvalid_s),

    .afready_m  (afready_m),
    .afvalid_m  (afvalid_m),

    .syncreq_s  (syncreq_s),
    .atwakeup_s (atwakeup_s),
    .atwakeup_m (atwakeup_m),

    .atvalid_m  (atvalid_m),
    .atready_m  (atready_m),
    .atid_m     (atid_m),
    .atdata_m   (atdata_m),
    .atbytes_m  (atbytes_m),

    .syncreq_m  (syncreq_m)

  );

endmodule

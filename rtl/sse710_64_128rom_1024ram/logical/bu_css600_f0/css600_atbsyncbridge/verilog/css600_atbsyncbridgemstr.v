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
//   Sub-module of css600_atbsyncbridge
//
//----------------------------------------------------------------------------


module css600_atbsyncbridgemstr #(parameter
  ATB_DATA_WIDTH = 32
)

(
  clk_m,

  reset_m_n,

  afready_m,
  afvalid_m,

  atwakeup_m,
  atvalid_m,
  atready_m,
  atid_m,
  atbytes_m,
  atdata_m,

  syncreq_m,
  syncreq_req,
  syncreq_ack,

  atb_fwd_data,
  flush_req,
  flush_done,
  wr_pointer,
  rd_pointer,
  sync_clear,
  sync_done

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

  localparam ATBYTES_WIDTH = (ATB_DATA_WIDTH_LOC > 8) ? (atb_clog2(ATB_DATA_WIDTH_LOC)-3) : 1;
  localparam PAYLD_WIDTH     = (ATBYTES_WIDTH+ATB_DATA_WIDTH_LOC+7+1);


  input   wire clk_m;
  input   wire reset_m_n;

  output  wire atwakeup_m;
  output  wire atvalid_m;
  output  wire [6:0] atid_m;
  output  wire [ATBYTES_WIDTH-1:0] atbytes_m;
  output  wire [ATB_DATA_WIDTH_LOC - 1:0] atdata_m;
  input   wire atready_m;

  output  wire afready_m;
  input   wire afvalid_m;

  input   wire syncreq_m;
  output  wire syncreq_req;
  input   wire syncreq_ack;

  input   wire [2*PAYLD_WIDTH-1:0] atb_fwd_data;
  output  wire flush_req;
  input   wire flush_done;
  input   wire [1:0] wr_pointer;
  output  wire [1:0] rd_pointer;
  input   wire sync_clear;
  output  wire sync_done;


  wire pulse_done_w;


assign atwakeup_m = atvalid_m;

css600_atbsyncbridgemstr_core #(
    .ATB_DATA_WIDTH(ATB_DATA_WIDTH_LOC)
)
u_css600_atbsyncbridgemstr_core
(
  .clk_m(clk_m),

  .reset_m_n(reset_m_n),

  .afready_m(afready_m),
  .afvalid_m(afvalid_m),

  .atvalid_m(atvalid_m),
  .atready_m(atready_m),
  .atid_m(atid_m),
  .atbytes_m(atbytes_m),
  .atdata_m(atdata_m),

  .atb_fwd_data(atb_fwd_data),
  .flush_req(flush_req),
  .flush_done(flush_done),
  .wr_pointer(wr_pointer),
  .rd_pointer(rd_pointer),
  .sync_clear(sync_clear),
  .sync_done(sync_done),
  .pulse_done(pulse_done_w)

);

css600_pulsesyncbridgeslv
  #( .WIDTH(1),
    .WAKE_ON_PULSE(0),
    .FF_SYNC_DEPTH(2)
  )
u_css600_pulsesyncbridgeslv
  (
    .clk_s(clk_m),
    .reset_s_n(reset_m_n),
    .pulse_in(syncreq_m),
    .pulse_req(syncreq_req),
    .pulse_ack(syncreq_ack),
    .clk_s_qactive(),
    .pwr_qreq_n(~sync_clear),
    .pwr_qaccept_n(pulse_done_w),
    .pwr_qactive()
  );


endmodule

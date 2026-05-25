//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2010-2014, 2016-2017 Arm Limited or its affiliates.
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
//   Top level of css600_atbreplicator
//
//----------------------------------------------------------------------------


module css600_atbreplicator_prog #(parameter
  ATB_DATA_WIDTH = 32,
  REVAND         = 4'h0
)
(
  clk,
  reset_n,


  psel_s,
  penable_s,
  pwrite_s,

  paddr_s,
  pwdata_s,
  pwakeup_s,
  pready_s,
  pslverr_s,
  prdata_s,

  atwakeup_s,
  atvalid_s,
  atid_s,

  atbytes_s,
  atdata_s,

  afready_s,
  atready_m,
  afvalid_m,
  syncreq_m,

  atready_s,
  afvalid_s,
  atwakeup_m,
  atvalid_m,
  atid_m,

  atbytes_m,
  atdata_m,

  afready_m,
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

  localparam ATBYTES_WIDTH = (ATB_DATA_WIDTH_LOC > 8) ? (atb_clog2(ATB_DATA_WIDTH_LOC)-4) : 0;

  input wire         clk;
  input wire         reset_n;

  input wire         psel_s;
  input wire         penable_s;
  input wire         pwrite_s;
  input wire  [11:0] paddr_s;
  input wire  [31:0] pwdata_s;
  input wire         pwakeup_s;
  output wire        pready_s;
  output wire        pslverr_s;
  output wire [31:0] prdata_s;

  input wire         atwakeup_s;
  input wire         atvalid_s;
  input wire   [6:0] atid_s;

  input wire  [ATBYTES_WIDTH:0]         atbytes_s;
  input wire  [ATB_DATA_WIDTH_LOC-1:0]  atdata_s;
  input wire         afready_s;
  input wire  [1:0]  atready_m;
  input wire  [1:0]  afvalid_m;
  input wire  [1:0]  syncreq_m;
  output wire        atready_s;
  output wire        afvalid_s;
  output wire [1:0]  atwakeup_m;
  output wire [1:0]  atvalid_m;
  output wire [13:0] atid_m;

  output wire [2*ATBYTES_WIDTH+1:0] atbytes_m;
  output wire [2*ATB_DATA_WIDTH_LOC-1:0] atdata_m;

  output wire [1:0]  afready_m;
  output wire        syncreq_s;

  output wire        clk_qactive;


  wire [3:0] w_revand;

  css600_atbreplicator_core#
  (
    .ATB_DATA_WIDTH(ATB_DATA_WIDTH_LOC),
    .ATBYTES_WIDTH(ATBYTES_WIDTH)
  )
  u_atbreplicator (

    .clk(clk),
    .reset_n(reset_n),


    .psel(psel_s),
    .penable(penable_s),
    .pwrite(pwrite_s),

    .paddr(paddr_s),
    .pwdata(pwdata_s[7:0]),
    .pready(pready_s),
    .pslverr(pslverr_s),
    .prdata(prdata_s),


    .atvalid_s(atvalid_s),
    .atid_s(atid_s),

    .atbytes_s(atbytes_s),
    .atdata_s(atdata_s),

    .afready_s(afready_s),
    .atready_m(atready_m),
    .afvalid_m(afvalid_m),
    .syncreq_m(syncreq_m),

    .atready_s(atready_s),
    .afvalid_s(afvalid_s),
    .atvalid_m(atvalid_m),
    .atid_m(atid_m),

    .atbytes_m(atbytes_m),
    .atdata_m(atdata_m),

    .afready_m(afready_m),
    .syncreq_s(syncreq_s),

    .atwakeup_s(atwakeup_s),
    .atwakeup_m(atwakeup_m),

    .revand (w_revand)
  );

css600_or_tree
#(
  .NUM_OR_INPUTS (4)
)
u_qactive_async
(
  .or_inputs({afvalid_m, atwakeup_s, pwakeup_s}),
  .or_output(clk_qactive)
);

  css600_ecorevnum #(.WIDTH(4), .ECOREVVAL(REVAND))
    u_css600_ecorevnum (.ecorevnum(w_revand));


endmodule

//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017, 2019-2020 Arm Limited or its affiliates.
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
//   Sub-module of css600_cti
//
//----------------------------------------------------------------------------


module css600_cti_apb_if
#(
  parameter APB_DATA_WIDTH = 32
)(
  input  wire                       clk,
  input  wire                       reset_n,
  input  wire                       dev_run,
  input  wire                       psel_s,
  input  wire                       penable_s,
  input  wire                       pwrite_s,
  output wire [APB_DATA_WIDTH-1:0]  prdata_s,
  output wire                       pready_s,
  output wire                       pslverr_s,
  input  wire [APB_DATA_WIDTH-1:0]  apb_rdata,
  output wire                       apb_write,
  output wire                       apb_read
);

  reg  [APB_DATA_WIDTH-1:0]         prdata_q;

  wire                          nxt_penable_reconst;
  reg                               penable_reconst;
  wire                              apb_setup_normal;
  wire                              apb_setup_wake;
  wire                              apb_select;

  wire                              apb_setup;
  wire                          nxt_apb_valid;
  reg                               apb_valid;


  always @(posedge clk or negedge reset_n)
  begin : reg_prdata
    if (!reset_n)
      prdata_q <= {APB_DATA_WIDTH{1'b0}};
    else if  (apb_read)
      prdata_q <= apb_rdata;
  end


  always @(posedge clk or negedge reset_n)
  begin : p_penable_reconst
    if (!reset_n)
      penable_reconst <= 1'b0;
    else if (dev_run)
      penable_reconst <= nxt_penable_reconst;
  end

  assign  nxt_penable_reconst = psel_s & pready_s ;

  assign apb_setup_normal = (psel_s & ~penable_s) & dev_run;

  assign apb_setup_wake = (psel_s & ~penable_reconst) & dev_run;

  assign apb_select = (apb_setup_normal | apb_setup_wake);

  assign apb_setup = (apb_select & ~penable_s)
                   | (apb_select &  penable_s & ~apb_valid)
                   ;
  assign nxt_apb_valid = apb_setup;

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n)
      apb_valid  <= 1'b0;
    else
      apb_valid  <= nxt_apb_valid;
  end

  assign apb_write =  pwrite_s & apb_valid;
  assign apb_read  = ~pwrite_s & apb_setup;
  assign prdata_s  = prdata_q;
  assign pready_s  = apb_valid;
  assign pslverr_s = 1'b0;

endmodule


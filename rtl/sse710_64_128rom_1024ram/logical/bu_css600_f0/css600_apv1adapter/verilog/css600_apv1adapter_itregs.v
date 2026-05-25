//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016 Arm Limited or its affiliates.
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
//   Sub-module of css600_apv1adapter
//
//----------------------------------------------------------------------------


module css600_apv1adapter_itregs (
  input  wire clk,
  input  wire reset_n,
  input  wire ime,
  input  wire itdapabort_rd,
  output wire itdapabort_rd_data,
  input  wire dp_abort,
  output wire dapabort
  );


  reg  itdapabort;
  reg  dp_abort_q;
  reg  itdapabort_next;
  wire dp_abort_edge;

  always @(dp_abort_edge or ime or itdapabort_rd or itdapabort) begin
    if ((itdapabort_rd || !ime) && itdapabort)
      itdapabort_next = 1'b0;
    else
      itdapabort_next = ime & (dp_abort_edge | itdapabort);
  end

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      dp_abort_q <= 1'b0;
      itdapabort <= 1'b0;
    end
    else begin
      dp_abort_q <= dp_abort;
      itdapabort <= itdapabort_next;
    end
  end

  assign dp_abort_edge = dp_abort & ~dp_abort_q;

  assign itdapabort_rd_data = itdapabort_rd & itdapabort;

  assign dapabort = !ime & dp_abort;


endmodule

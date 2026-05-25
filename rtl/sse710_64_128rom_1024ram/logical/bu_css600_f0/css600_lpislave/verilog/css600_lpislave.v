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
//   Top level of css600_lpislave
//
//----------------------------------------------------------------------------


module css600_lpislave
(
  input  wire clk,
  input  wire reset_n,
  input  wire qreq_sync_n,
  output wire qaccept_n,
  output wire qdeny,
  output wire lp_request,
  input  wire dev_active,
  input  wire lp_done,
  output wire dev_run,
  output wire cg_en
);


  css600_lpislave_fsm u_css600_lpislave_fsm
  (
    .clk          (clk),
    .reset_n      (reset_n),
    .qreq_sync_n  (qreq_sync_n),
    .qaccept_n    (qaccept_n),
    .qdeny        (qdeny),
    .lp_request   (lp_request),
    .dev_active   (dev_active),
    .lp_done      (lp_done),
    .dev_run      (dev_run),
    .cg_en        (cg_en)
  );


endmodule

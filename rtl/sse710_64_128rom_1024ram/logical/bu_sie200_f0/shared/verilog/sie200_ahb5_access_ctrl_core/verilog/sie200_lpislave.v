// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2015-2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Fri Sep 2 12:22:10 2016 +0100
//
//      Revision            : 9b3072b
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//----------------------------------------------------------------------------

module sie200_lpislave
(
  input  wire                     clk,
  input  wire                     reset_n,
  input  wire                     qreq_sync_n,
  output wire                     qaccept_n,
  output wire                     qdeny,
  output wire                     qactive,
  input  wire                     wake_up,
  output wire                     lp_request,
  input  wire                     dev_active,
  input  wire                     lp_done,
  output wire                     dev_run,
  output wire                     cg_en
);


  sie200_lpislave_fsm u_sie200_lpislave_fsm
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

  sie200_or u_sie200_or (
    .in_a  (dev_active),
    .in_b  (wake_up),
    .out_y (qactive)
  );

endmodule

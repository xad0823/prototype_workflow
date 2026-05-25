//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2019 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//
//      Version Information
//
//      Checked In          : Mon Jul 29 14:50:07 2019 +0100
//
//      Revision            : aec093fa
//
//      Release Information : CoreLink SIE-300 Generic Global Bundle r1p2-00rel0
//
//----------------------------------------------------------------------------

module sie300_axi5_sram_ctrl_cvm_clamp
(
  input  wire logic                                           clk,
  input  wire logic                                           resetn,

  input  wire logic [22-1     :0]                             memaddr_arb,
  input  wire logic                                           memcen_arb,
  input  wire logic [8-1     :0]                              memwen_arb,
  input  wire logic                                           memrd_arb,
  input  wire logic [64-1     :0]                             memd_wbeat,
  output      logic [64-1     :0]                             memq_clamp,

  output      logic [22-1     :0]                             memaddr,
  output      logic                                           memcen,
  output      logic [8-1     :0]                              memwen,
  output      logic [64-1     :0]                             memd,
  input  wire logic [64-1     :0]                             memq,

  input  wire logic                                           stopped
);

  logic memq_valid;
  logic memq_gate;

  always_ff @ (posedge clk or negedge resetn) begin
    if (~resetn) begin
      memq_valid <= 1'b0;
    end
    else begin
      memq_valid <= memrd_arb;
    end
  end

  assign memq_gate = ~stopped & memq_valid;


  sie300_arm_or2 u_arm_or2 (
    .a_i  ( stopped        ),
    .b_i  ( memcen_arb      ),
    .y_o  ( memcen          )
  );

  genvar i;
  generate

    for (i=0; i< 8; i=i+1) begin: g_clamp_wen
      sie300_arm_or2 u_arm_or2 (
        .a_i  ( stopped        ),
        .b_i  ( memwen_arb[i]   ),
        .y_o  ( memwen[i]       )
      );
    end

    for (i=0; i< 22; i=i+1) begin: g_clamp_addr
      sie300_arm_and2 u_arm_and2 (
        .a_i  ( ~stopped        ),
        .b_i  ( memaddr_arb[i]  ),
        .y_o  ( memaddr[i]      )
      );
    end

    for (i=0; i< 64; i=i+1) begin: g_clamp_d
      sie300_arm_and2 u_arm_and2 (
        .a_i  ( ~stopped        ),
        .b_i  ( memd_wbeat[i]   ),
        .y_o  ( memd[i]         )
      );
    end

    for (i=0; i< 64; i=i+1) begin: g_clamp_q
      sie300_arm_and2 u_arm_and2 (
        .a_i  ( memq_gate       ),
        .b_i  ( memq[i]         ),
        .y_o  ( memq_clamp[i]   )
      );
    end
  endgenerate

endmodule

// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2017 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Mon Sep 18 16:19:59 2017 +0100
//
//      Revision            : 927aee9
//
//      Release Information : Vultan Generic Flash Controller - Global Bundle r0p0-00rel0
//
//-----------------------------------------------------------------------------
module vultan_pchan_mstr(
   input  wire             clk,
   input  wire             resetn,

   input  wire             qreqn_flash,
   output wire             qacceptn_flash,
   output wire             qdeny_flash,
   output wire             qactive_flash,

   output wire             preq,
   output wire             pstate,
   input  wire             paccept,
   input  wire             pdeny,
   input  wire             pactive
);

localparam  PCH_STABLE       = 3'd0,
            PCH_REQUEST      = 3'd1,
            PCH_COMPLETE     = 3'd2,
            PCH_CONTINUE_ON  = 3'd3,
            PCH_CONTINUE_OFF = 3'd4,
            PCH_UNUSED5      = 3'd5,
            PCH_UNUSED6      = 3'd6,
            PCH_UNUSED7      = 3'd7;


wire        paccept_sync;
wire        pdeny_sync;
wire        pactive_sync;
reg         qreqn_flash_d;
reg  [2:0]  pch_fsm, pch_fsm_nxt;
reg         preq_reg, preq_nxt;
reg         pstate_reg, pstate_nxt;
reg         qacceptn_reg, qacceptn_nxt;
reg         qdeny_reg, qdeny_nxt;


vultan_sync  u_syn_paccept (.clk(clk), .reset_n(resetn), .d(paccept), .q(paccept_sync));
vultan_sync  u_syn_pdeny   (.clk(clk), .reset_n(resetn), .d(pdeny  ), .q(pdeny_sync  ));
vultan_sync  u_syn_pactive (.clk(clk), .reset_n(resetn), .d(pactive), .q(pactive_sync));


always @(posedge clk or negedge resetn) begin
   if (!resetn) begin
      qreqn_flash_d  <= 1'b0;
   end
   else begin
      qreqn_flash_d <= qreqn_flash;
   end
end


always @*
begin
   pch_fsm_nxt = pch_fsm;
   preq_nxt = preq_reg;
   pstate_nxt = pstate_reg;
   qacceptn_nxt = qacceptn_reg;
   qdeny_nxt = qdeny_reg;
   case(pch_fsm)
      PCH_STABLE:
        begin
          if (qreqn_flash ^ qreqn_flash_d) begin
            pch_fsm_nxt = PCH_REQUEST;
            preq_nxt = 1'b1;
            pstate_nxt = qreqn_flash;
          end
        end

      PCH_REQUEST:
        begin
           if (paccept_sync) begin
             pch_fsm_nxt = PCH_COMPLETE;
             preq_nxt = 1'b0;
           end
           else if (pdeny_sync) begin
             pch_fsm_nxt = qreqn_flash ? PCH_CONTINUE_ON : PCH_CONTINUE_OFF;
             preq_nxt = 1'b0;
             pstate_nxt = ~pstate_reg;
             qdeny_nxt = ~qreqn_flash;
           end
        end

      PCH_COMPLETE:
        begin
          if(!paccept_sync) begin
            pch_fsm_nxt = PCH_STABLE;
            qacceptn_nxt = qreqn_flash;
          end
        end

      PCH_CONTINUE_OFF:
        begin
          if(!pdeny_sync & qreqn_flash) begin
             pch_fsm_nxt = PCH_STABLE;
             qdeny_nxt = 1'b0;
          end
        end

      PCH_CONTINUE_ON:
        begin
          if(!pdeny_sync) begin
            pch_fsm_nxt = PCH_REQUEST;
            preq_nxt = 1'b1;
            pstate_nxt = qreqn_flash;
          end
        end

      PCH_UNUSED5,
      PCH_UNUSED6,
      PCH_UNUSED7:
        begin
          pch_fsm_nxt = PCH_STABLE;
        end

      default:
        begin
          pch_fsm_nxt = 3'bxxx;
        end
   endcase
end


always @(posedge clk or negedge resetn) begin
   if (!resetn) begin
     pch_fsm <= PCH_STABLE;
     preq_reg <= 1'b0;
     pstate_reg <= 1'b0;
     qacceptn_reg <= 1'b0;
     qdeny_reg <= 1'b0;
   end
   else begin
     pch_fsm <= pch_fsm_nxt;
     preq_reg <= preq_nxt;
     pstate_reg <= pstate_nxt;
     qacceptn_reg <= qacceptn_nxt;
     qdeny_reg <= qdeny_nxt;
   end
end


assign preq             = preq_reg;
assign pstate           = pstate_reg;

assign qdeny_flash      = qdeny_reg;
assign qacceptn_flash   = qacceptn_reg;
assign qactive_flash    = pactive_sync;

endmodule

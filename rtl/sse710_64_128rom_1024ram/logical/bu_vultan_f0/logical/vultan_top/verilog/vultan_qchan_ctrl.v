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
//      Checked In          : Fri Nov 10 12:16:39 2017 +0000
//
//      Revision            : 779ce3e
//
//      Release Information : Vultan Generic Flash Controller - Global Bundle r0p0-00rel0
//
//-----------------------------------------------------------------------------
module vultan_qchan_ctrl(
   input  wire             clk,
   input  wire             resetn,

   input  wire             qreqn_clk,
   output wire             qacceptn_clk,
   output wire             qdeny_clk,
   output wire             qactive_clk,

   input  wire             qreqn_pwr ,
   output wire             qacceptn_pwr,
   output wire             qdeny_pwr,
   output wire             qactive_pwr,

   output wire             qreqn_apb,
   input  wire             qacceptn_apb,
   input  wire             qdeny_apb,
   input  wire             qactive_apb,

   output wire             qreqn_gfb,
   input  wire             qacceptn_gfb,
   input  wire             qdeny_gfb,
   input  wire             qactive_gfb,

   output wire             qreqn_flash,
   input  wire             qacceptn_flash,
   input  wire             qdeny_flash,
   input  wire             qactive_flash,

   output wire             flash_pwr_rdy

);




localparam  QFSM_QSTOPPED        = 4'b0000,
            QFSM_QEXIT           = 4'b0001,
            QFSM_QRUN            = 4'b0101,
            QFSM_QWAIT           = 4'b0111,
            QFSM_QREQUEST        = 4'b0100,
            QFSM_QREQUEST_FLASH  = 4'b0110,
            QFSM_QDENIED         = 4'b1100,
            QFSM_QCONTINUE       = 4'b1101,
            QFSM_UNUSED2         = 4'b0010,
            QFSM_UNUSED3         = 4'b0011,
            QFSM_UNUSED8         = 4'b1000,
            QFSM_UNUSED9         = 4'b1001,
            QFSM_UNUSED10        = 4'b1010,
            QFSM_UNUSED11        = 4'b1011,
            QFSM_UNUSED14        = 4'b1110,
            QFSM_UNUSED15        = 4'b1111;


wire        qreqn_clk_sync;
wire        qreqn_pwr_sync;
wire        qreqn_reg_clk;
wire        qreqn_reg_pwr;
wire        qacceptn_int;
wire        qreqn_int;
wire        qdeny_int;
wire        qactive_int;
wire        pwr_ext_wake_xor;
wire        pwr_ext_wake;
reg  [3:0]  qclk_fsm;
reg  [3:0]  qclk_fsm_nxt;
reg  [3:0]  qpwr_fsm;
reg  [3:0]  qpwr_fsm_nxt;


always @* begin
   qclk_fsm_nxt = qclk_fsm;
   case(qclk_fsm)
      QFSM_QSTOPPED: begin
         if (qreqn_clk_sync) begin
            qclk_fsm_nxt = (qpwr_fsm == QFSM_QSTOPPED) ? QFSM_QRUN : QFSM_QEXIT;
         end
      end

      QFSM_QEXIT: begin
         if(qacceptn_int) begin
            qclk_fsm_nxt = QFSM_QRUN;
         end
      end

      QFSM_QRUN: begin
         if(!qreqn_clk_sync) begin
            if(qpwr_fsm == QFSM_QSTOPPED) begin
               qclk_fsm_nxt = QFSM_QSTOPPED;
            end
            else begin
               qclk_fsm_nxt = (!qreqn_int | !qreqn_pwr_sync) ? QFSM_QWAIT : QFSM_QREQUEST;
            end
         end
      end

      QFSM_QWAIT: begin
         if(qreqn_int) begin
            qclk_fsm_nxt = QFSM_QREQUEST;
         end
      end

      QFSM_QREQUEST: begin
         if(qdeny_int) begin
            qclk_fsm_nxt = QFSM_QDENIED;
         end
         else if (!qacceptn_int) begin
            qclk_fsm_nxt = QFSM_QSTOPPED;
         end
      end

      QFSM_QDENIED: begin
         if(qreqn_clk_sync) begin
            qclk_fsm_nxt = QFSM_QCONTINUE;
         end
      end

      QFSM_QCONTINUE: begin
         if(!qdeny_int) begin
            qclk_fsm_nxt = QFSM_QRUN;
         end
      end

      QFSM_QREQUEST_FLASH,
      QFSM_UNUSED2,
      QFSM_UNUSED3,
      QFSM_UNUSED8,
      QFSM_UNUSED9,
      QFSM_UNUSED10,
      QFSM_UNUSED11,
      QFSM_UNUSED14,
      QFSM_UNUSED15: begin
         qclk_fsm_nxt = QFSM_QSTOPPED;
      end

      default: begin
         qclk_fsm_nxt = 4'bxxxx;
      end
   endcase
end

always @* begin
   qpwr_fsm_nxt = qpwr_fsm;
   case(qpwr_fsm)
      QFSM_QSTOPPED: begin
         if (qreqn_pwr_sync) begin
            qpwr_fsm_nxt = QFSM_QEXIT;
         end
      end

      QFSM_QEXIT: begin
         if(qacceptn_int & qacceptn_flash) begin
            qpwr_fsm_nxt = QFSM_QRUN;
         end
      end

      QFSM_QRUN: begin
         if(!qreqn_pwr_sync) begin
            qpwr_fsm_nxt = !qreqn_int ? QFSM_QWAIT : QFSM_QREQUEST;
         end
      end

      QFSM_QWAIT: begin
         if(qreqn_int) begin
            qpwr_fsm_nxt = QFSM_QREQUEST;
         end
      end

      QFSM_QREQUEST: begin
         if(qdeny_int) begin
            qpwr_fsm_nxt = QFSM_QDENIED;
         end
         else if (!qacceptn_int) begin
            qpwr_fsm_nxt = QFSM_QREQUEST_FLASH;
         end
      end

      QFSM_QREQUEST_FLASH: begin
         if(qdeny_flash) begin
            qpwr_fsm_nxt = QFSM_QDENIED;
         end
         else if (!qacceptn_flash) begin
            qpwr_fsm_nxt = QFSM_QSTOPPED;
         end
      end

      QFSM_QDENIED: begin
         if(qreqn_pwr_sync) begin
            qpwr_fsm_nxt = QFSM_QCONTINUE;
         end
      end

      QFSM_QCONTINUE: begin
         if(!qdeny_int & !qdeny_flash) begin
            qpwr_fsm_nxt = QFSM_QRUN;
         end
      end

      QFSM_UNUSED2,
      QFSM_UNUSED3,
      QFSM_UNUSED8,
      QFSM_UNUSED9,
      QFSM_UNUSED10,
      QFSM_UNUSED11,
      QFSM_UNUSED14,
      QFSM_UNUSED15: begin
         qpwr_fsm_nxt = QFSM_QSTOPPED;
      end

      default: begin
         qpwr_fsm_nxt = 4'bxxxx;
      end
   endcase
end


always @(posedge clk or negedge resetn) begin
   if (~resetn) begin
      qclk_fsm <= QFSM_QSTOPPED;
      qpwr_fsm <= QFSM_QSTOPPED;
   end
   else begin
      qclk_fsm <= qclk_fsm_nxt;
      qpwr_fsm <= qpwr_fsm_nxt;
   end
end


assign qacceptn_int  = qacceptn_apb & qacceptn_gfb;
assign qdeny_int     = qdeny_apb    | qdeny_gfb;

assign qreqn_reg_clk = qclk_fsm[0];
assign qreqn_reg_pwr = qpwr_fsm[0];
assign qreqn_int     = qreqn_reg_clk & qreqn_reg_pwr;
assign qreqn_apb     = qreqn_int;
assign qreqn_gfb     = qreqn_int;
assign qreqn_flash   = !((qpwr_fsm == QFSM_QREQUEST_FLASH) || (qpwr_fsm == QFSM_QSTOPPED));

assign qacceptn_clk  = qclk_fsm[2];
assign qdeny_clk     = qclk_fsm[3];
assign qacceptn_pwr  = qpwr_fsm[2];
assign qdeny_pwr     = qpwr_fsm[3];

assign flash_pwr_rdy = qacceptn_flash;


vultan_sync  u_syn_qreqn_clk     (.clk(clk), .reset_n(resetn), .d(qreqn_clk), .q(qreqn_clk_sync));
vultan_sync  u_syn_qreqn_pwr     (.clk(clk), .reset_n(resetn), .d(qreqn_pwr), .q(qreqn_pwr_sync));

vultan_xor   u_xor_pwr_ext_wake  (.in_a(qreqn_pwr),   .in_b(qacceptn_pwr),    .out_y(pwr_ext_wake_xor));
vultan_or    u_or_pwr_ext_wake   (.in_a(qdeny_pwr),   .in_b(pwr_ext_wake_xor),.out_y(pwr_ext_wake));
vultan_or    u_or_qactive_int    (.in_a(qactive_apb), .in_b(qactive_gfb),     .out_y(qactive_int));
vultan_or    u_or_qactive_pwr    (.in_a(qactive_int), .in_b(qactive_flash),   .out_y(qactive_pwr));
vultan_or    u_or_qactive_clk    (.in_a(qactive_pwr), .in_b(pwr_ext_wake),    .out_y(qactive_clk));












endmodule

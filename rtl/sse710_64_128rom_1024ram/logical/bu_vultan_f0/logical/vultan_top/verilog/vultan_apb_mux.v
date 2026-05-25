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
//      Checked In          : Thu Oct 26 20:14:53 2017 +0100
//
//      Revision            : 599abeb
//
//      Release Information : Vultan Generic Flash Controller - Global Bundle r0p0-00rel0
//
//-----------------------------------------------------------------------------

module vultan_apb_mux(
   input  wire           resetn,
   input  wire           clk,
   input  wire           psel_s,
   input  wire           penable_s,
   input  wire  [12:0]   paddr_s,
   input  wire           pwrite_s,
   input  wire  [31:0]   pwdata_s,
   input  wire   [3:0]   pstrb_s,
   output wire  [31:0]   prdata_s,
   output wire           pready_s,
   output wire           pslverr_s,
   output wire           psel_m,
   output wire           penable_m,
   output wire  [11:0]   paddr_m,
   output wire           pwrite_m,
   output wire  [31:0]   pwdata_m,
   output wire   [3:0]   pstrb_m,
   input  wire  [31:0]   prdata_m,
   input  wire           pready_m,
   input  wire           pslverr_m,
   output wire           psel_rb,
   output wire           penable_rb,
   output wire  [11:0]   paddr_rb,
   output wire           pwrite_rb,
   output wire  [31:0]   pwdata_rb,
   output wire   [3:0]   pstrb_rb,
   input  wire  [31:0]   prdata_rb,
   input  wire           pready_rb,
   input  wire           pslverr_rb,

   input  wire           irq_raw,
   output wire           irq,
   input  wire           qreqn_apb,
   output wire           qacceptn_apb,
   output wire           qdeny_apb,
   output wire           qactive_apb
);


localparam FSM_QSTOPPED = 2'b00;
localparam FSM_QRUN     = 2'b01;
localparam FSM_QDENIED  = 2'b11;
localparam FSM_UNUSED   = 2'b10;

wire [31:0]  prdata_int;
wire         pready_int;
wire         pslverr_int;
reg   [1:0]  pwr_state, pwr_state_nxt;
reg          qacceptn_apb_d;

assign psel_rb = psel_s & ~paddr_s[12] & qacceptn_apb;
assign penable_rb = penable_s & qacceptn_apb & qacceptn_apb_d;
assign paddr_rb = paddr_s[11:0];
assign pwrite_rb = pwrite_s;
assign pwdata_rb = pwdata_s;
assign pstrb_rb = pstrb_s;

assign psel_m = psel_s & paddr_s[12] & qacceptn_apb;
assign penable_m = penable_s & qacceptn_apb & qacceptn_apb_d;
assign paddr_m = paddr_s[11:0];
assign pwrite_m = pwrite_s;
assign pwdata_m = pwdata_s;
assign pstrb_m = pstrb_s;

assign prdata_int = paddr_s[12] ? prdata_m : prdata_rb;
assign pready_int = paddr_s[12] ? pready_m : pready_rb;
assign pslverr_int = paddr_s[12] ? pslverr_m : pslverr_rb;

assign prdata_s = prdata_int & {32{qacceptn_apb}} & {32{qacceptn_apb_d}};
assign pready_s = pready_int & qacceptn_apb & qacceptn_apb_d;
assign pslverr_s = pslverr_int & qacceptn_apb & qacceptn_apb_d;

assign irq = irq_raw & qacceptn_apb;
assign qactive_apb  = psel_s | irq_raw;
assign qacceptn_apb = pwr_state[0];
assign qdeny_apb    = pwr_state[1];

always @*
begin
  pwr_state_nxt = pwr_state;
  case (pwr_state)
    FSM_QSTOPPED:
      begin
        if (qreqn_apb) begin
          pwr_state_nxt = FSM_QRUN;
        end
      end

    FSM_QRUN:
      begin
        if (!qreqn_apb) begin
          pwr_state_nxt = qactive_apb ? FSM_QDENIED : FSM_QSTOPPED;
        end
      end

    FSM_QDENIED:
      begin
        if (qreqn_apb) begin
          pwr_state_nxt = FSM_QRUN;
        end
      end

    FSM_UNUSED:
      begin
        pwr_state_nxt = FSM_QSTOPPED;
      end

    default:
      begin
        pwr_state_nxt = 2'bxx;
      end
  endcase
end

always @ (negedge resetn or posedge clk)
begin
  if (!resetn) begin
    pwr_state <= FSM_QSTOPPED;
  end
  else begin
    pwr_state <= pwr_state_nxt;
  end
end

always @ (negedge resetn or posedge clk)
begin
  if (!resetn) begin
    qacceptn_apb_d <= 1'b0;
  end
  else begin
    qacceptn_apb_d <= qacceptn_apb;
  end
end


endmodule

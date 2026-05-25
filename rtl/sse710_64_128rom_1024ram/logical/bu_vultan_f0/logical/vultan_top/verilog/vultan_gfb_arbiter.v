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
//      Checked In          : Thu Dec 21 10:25:33 2017 +0000
//
//      Revision            : 4afdb24
//
//      Release Information : Vultan Generic Flash Controller - Global Bundle r0p0-00rel0
//
//-----------------------------------------------------------------------------

module vultan_gfb_arbiter(
   input  wire           resetn,
   input  wire           clk,
   input  wire  [21:0]   faddr_ahb,
   input  wire           freq_ahb,
   input  wire           freq_locked_ahb,
   output wire           fgnt_ahb,
   input  wire   [2:0]   fcmd_apb,
   input  wire           fabort_apb,
   input  wire  [21:0]   faddr_apb,
   input  wire  [31:0]   fwdata_apb,
   input  wire           freq_apb,
   output wire           fgnt_apb,
   output wire           arbitration_locked,
   output wire [127:0]   frdata_int,
   output wire           fresp_int,
   output wire           fready_int,
   output reg    [2:0]   fcmd,
   output wire           fabort,
   output reg   [21:0]   faddr,
   output wire  [31:0]   fwdata,
   input  wire [127:0]   frdata,
   input  wire           fresp,
   input  wire           fready,
   input  wire           qreqn_gfb,
   output wire           qacceptn_gfb,
   output wire           qdeny_gfb,
   output wire           qactive_gfb
);


localparam GFB_IDLE       = 3'b000;
localparam GFB_READ       = 3'b001;

localparam AHB_SEL = 2'b10;
localparam APB_SEL = 2'b01;
localparam NO_SEL  = 2'b00;

localparam FSM_QSTOPPED = 2'b00;
localparam FSM_QRUN     = 2'b01;
localparam FSM_QDENIED  = 2'b11;
localparam FSM_UNUSED   = 2'b10;

wire         arbiter_idle;
wire         gfb_inactive;
reg          arbitration_locked_reg;
reg   [1:0]  fgnt;
reg   [1:0]  sel_reg;
reg          last_access_reg;
reg   [1:0]  pwr_state, pwr_state_nxt;
reg          fready_d;


assign fwdata = fwdata_apb;
assign fabort = fabort_apb;
assign frdata_int = frdata;
assign fresp_int = fresp;
assign fready_int = fready;

assign {fgnt_ahb, fgnt_apb} = fgnt;
assign arbitration_locked = arbitration_locked_reg;

always @ (posedge clk or negedge resetn)
begin
  if (!resetn) begin
    arbitration_locked_reg <= 1'b0;
  end
  else if (fgnt_ahb) begin
    arbitration_locked_reg <= freq_locked_ahb;
  end
  else begin
    arbitration_locked_reg <= 1'b0;
  end
end

always @ (posedge clk or negedge resetn)
begin
  if (!resetn) begin
    sel_reg <= NO_SEL;
  end
  else if (fready) begin
    sel_reg <= NO_SEL;
  end
  else begin
    sel_reg <= fgnt;
  end
end

always @ (posedge clk or negedge resetn)
begin
  if (!resetn) begin
    last_access_reg <= 1'b0;
  end
  else if (fready && fgnt != NO_SEL) begin
    last_access_reg <= fgnt_ahb;
  end
end

always @*
begin
  if (!qacceptn_gfb) begin
    fcmd = GFB_IDLE;
    faddr = 22'h0;
    fgnt = NO_SEL;
  end
  else if (sel_reg == AHB_SEL) begin
    fcmd = freq_ahb ? GFB_READ : GFB_IDLE;
    faddr = freq_ahb ? faddr_ahb : 22'h0;
    fgnt = freq_ahb ? AHB_SEL : NO_SEL;
  end
  else if (sel_reg == APB_SEL) begin
    fcmd = fcmd_apb;
    faddr = faddr_apb;
    fgnt = APB_SEL;
  end
  else if (freq_locked_ahb) begin
    fcmd = freq_ahb ? GFB_READ : GFB_IDLE;
    faddr = freq_ahb ? faddr_ahb : 22'h0;
    fgnt = freq_ahb ? AHB_SEL : NO_SEL;
  end
  else if (freq_ahb && freq_apb) begin
    if (last_access_reg) begin
      fcmd = fcmd_apb;
      faddr = faddr_apb;
      fgnt = APB_SEL;
    end
    else begin
      fcmd = GFB_READ;
      faddr = faddr_ahb;
      fgnt = AHB_SEL;
    end
  end
  else if (freq_apb) begin
    fcmd = fcmd_apb;
    faddr = faddr_apb;
    fgnt = APB_SEL;
  end
  else if (freq_ahb) begin
    fcmd = GFB_READ;
    faddr = faddr_ahb;
    fgnt = AHB_SEL;
  end
  else begin
    fcmd = GFB_IDLE;
    faddr = 22'h0;
    fgnt = NO_SEL;
  end
end

always @ (posedge clk or negedge resetn)
begin
  if (!resetn) begin
    fready_d <= 1'b0;
  end
  else begin
    fready_d <= fready;
  end
end


assign arbiter_idle = ~freq_ahb & ~freq_locked_ahb & ~freq_apb;
assign gfb_inactive = arbiter_idle & fready & fready_d;

assign qactive_gfb  = ~arbiter_idle;
assign qacceptn_gfb = pwr_state[0];
assign qdeny_gfb    = pwr_state[1];

always @*
begin
  pwr_state_nxt = pwr_state;
  case (pwr_state)
    FSM_QSTOPPED:
      begin
        if (qreqn_gfb) begin
          pwr_state_nxt = FSM_QRUN;
        end
      end

    FSM_QRUN:
      begin
        if (!qreqn_gfb) begin
          pwr_state_nxt = gfb_inactive ? FSM_QSTOPPED : FSM_QDENIED;
        end
      end

    FSM_QDENIED:
      begin
        if (qreqn_gfb) begin
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

always @ (posedge clk or negedge resetn)
begin
  if (!resetn) begin
    pwr_state <= FSM_QSTOPPED;
  end
  else begin
    pwr_state <= pwr_state_nxt;
  end
end








endmodule

// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2018-2019  Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//  Release Information : PCK600-r0p4-00eac0
//
// -----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
// -----------------------------------------------------------------------------


module pck600_ppu_piu_sse710_clus
#(
  parameter PCSM_PREQ_DLY = 2'b01,
  parameter DEF_PWR_POLICY = 4'h0,
  parameter PCSMPSTATE_WIDTH = 4
)
(

  //Clock and Reset
  input wire                  clk,
  input wire                  reset_n,

  //PCSM P-Channel
  output wire                 pcsm_preq_o,
  output wire [PCSMPSTATE_WIDTH-1:0] pcsm_pstate_o,
  input wire                  pcsm_paccept_i,

  //PSM Interface
  input wire                  piu_req_i,
  input wire [3:0]            piu_pwr_mode_i,
  output wire                 piu_comp_o

);

`include "pck600_ppu_enum_sse710_clus.v"

  localparam P_STABLE = 2'b00;
  localparam P_DELAY = 2'b01;
  localparam P_REQUEST = 2'b10;
  localparam P_ACCEPT = 2'b11;


  reg [1:0]                   state;
  reg [1:0]                   nxt_state;
  reg                         state_en;
  reg                         piu_comp_r;
  reg                         pcsm_preq_r;
  reg [PCSMPSTATE_WIDTH-1:0]  pcsm_pstate_r;
  reg                         nxt_piu_comp_r;
  reg                         nxt_pcsm_preq_r;
  reg [PCSMPSTATE_WIDTH-1:0]  nxt_pcsm_pstate_r;

  wire                        pcsm_preq_dly_enable;
  wire                        pcsm_preq_dly_expire;



  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      state[1:0] <= P_STABLE;
      piu_comp_r <= 1'b1;
      pcsm_preq_r <= 1'b0;
      pcsm_pstate_r[PCSMPSTATE_WIDTH-1:0] <= DEF_PWR_POLICY[3:0];
    end
    else if(state_en)
    begin
      state[1:0] <= nxt_state[1:0];
      piu_comp_r <= nxt_piu_comp_r;
      pcsm_preq_r <= nxt_pcsm_preq_r;
      pcsm_pstate_r[PCSMPSTATE_WIDTH-1:0] <= nxt_pcsm_pstate_r[PCSMPSTATE_WIDTH-1:0];
    end
  end

  always@*
  begin
    case(state[1:0])
    P_STABLE:
    begin
      nxt_state[1:0] = (pcsm_preq_dly_enable)? P_DELAY:P_REQUEST;
      state_en = piu_req_i;
      nxt_pcsm_preq_r = (pcsm_preq_dly_enable)? 1'b0:1'b1;
      nxt_pcsm_pstate_r[PCSMPSTATE_WIDTH-1:0] = piu_pwr_mode_i[3:0];
      nxt_piu_comp_r = 1'b0;
    end
    P_DELAY:
    begin
      nxt_state[1:0] = P_REQUEST;
      state_en = pcsm_preq_dly_expire;
      nxt_pcsm_preq_r = 1'b1;
      nxt_pcsm_pstate_r[PCSMPSTATE_WIDTH-1:0] = pcsm_pstate_r[PCSMPSTATE_WIDTH-1:0];
      nxt_piu_comp_r = 1'b0;
    end
    P_REQUEST:
    begin
      nxt_state[1:0] = P_ACCEPT;
      state_en = pcsm_paccept_i;
      nxt_pcsm_preq_r = 1'b0;
      nxt_pcsm_pstate_r[PCSMPSTATE_WIDTH-1:0] = pcsm_pstate_r[PCSMPSTATE_WIDTH-1:0];
      nxt_piu_comp_r = 1'b0;
    end
    P_ACCEPT:
    begin
      nxt_state[1:0] = P_STABLE;
      state_en = ~pcsm_paccept_i;
      nxt_pcsm_preq_r = 1'b0;
      nxt_pcsm_pstate_r[PCSMPSTATE_WIDTH-1:0] = pcsm_pstate_r[PCSMPSTATE_WIDTH-1:0];
      nxt_piu_comp_r = 1'b1;
    end
    default:
    begin
      nxt_state[1:0] = 2'bxx;
      state_en = 1'bx;
      nxt_pcsm_preq_r = 1'bx;
      nxt_pcsm_pstate_r[PCSMPSTATE_WIDTH-1:0] = {PCSMPSTATE_WIDTH{1'bx}};
      nxt_piu_comp_r = 1'bx;
    end
    endcase
  end


generate
if(PCSM_PREQ_DLY > 0)
begin:pcsm_preq_dly_counter

  reg [1:0]                   pcsm_preq_dly_r;
  reg [1:0]                   nxt_pcsm_preq_dly_r;
  wire                        pcsm_preq_dly_en;
  wire                        pcsm_preq_dly_dec;
  wire                        pcsm_preq_dly_rst;

  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      pcsm_preq_dly_r[1:0] <= PCSM_PREQ_DLY[1:0];
    end
    else if(pcsm_preq_dly_en)
    begin
      pcsm_preq_dly_r[1:0] <= nxt_pcsm_preq_dly_r[1:0];
    end
  end

  assign pcsm_preq_dly_dec = (state[1:0] == P_DELAY);

  assign pcsm_preq_dly_rst = (state[1:0] == P_REQUEST);

  assign pcsm_preq_dly_en = pcsm_preq_dly_dec | (pcsm_preq_dly_rst & ~|(pcsm_preq_dly_r[1:0]));

  always@*
  begin
    case({pcsm_preq_dly_rst,pcsm_preq_dly_dec})
    2'b00: nxt_pcsm_preq_dly_r[1:0] = pcsm_preq_dly_r[1:0];
    2'b01: nxt_pcsm_preq_dly_r[1:0] = pcsm_preq_dly_r[1:0] - 2'b01;
    2'b10: nxt_pcsm_preq_dly_r[1:0] = PCSM_PREQ_DLY[1:0];
    default: nxt_pcsm_preq_dly_r[1:0] = 2'bxx;
    endcase
  end

  assign pcsm_preq_dly_expire = (pcsm_preq_dly_r[1:0] == 2'b01);

  assign pcsm_preq_dly_enable = 1'b1;

end
else
begin:no_pcsm_preq_dly_counter

  assign pcsm_preq_dly_expire = 1'b1;
  assign pcsm_preq_dly_enable = 1'b0;

end
endgenerate


  assign pcsm_preq_o = pcsm_preq_r;
  assign pcsm_pstate_o[PCSMPSTATE_WIDTH-1:0] = pcsm_pstate_r[PCSMPSTATE_WIDTH-1:0];

  assign piu_comp_o = piu_comp_r;

endmodule

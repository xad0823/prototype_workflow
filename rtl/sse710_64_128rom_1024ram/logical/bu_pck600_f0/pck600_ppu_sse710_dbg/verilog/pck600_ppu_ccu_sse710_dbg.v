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


module pck600_ppu_ccu_sse710_dbg
#(
  parameter NUM_PWR_DEVACTIVE = 11,
  parameter DEVACTIVE_LSB = 1
)
(

  //Clock and Reset
  input wire                  clk,
  input wire                  reset_n,

  //PPUCLK Q-Channel Interface
  input wire                  ppuclk_qreqn_i,
  output wire                 ppuclk_qacceptn_o,
  output wire                 ppuclk_qdeny_o,
  output wire                 ppuclk_qactive_o,

  //Module Clock Requests
  input wire                  reg_clk_req_i,
  input wire                  edge_clk_req_i,
  input wire                  mtu_clk_req_i,

  //External Clock Request
  input wire [NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB] pwr_devactive_async_i,
  input wire [NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB] pwr_devactive_st_i,
  input wire                  pwakeup_i,

  //Clock Gate Enable
  output wire                 cg_enable_o,

  //Clock Enable
  output wire                 clk_enable_o

);

  localparam Q_STOPPED = 2'b00;
  localparam Q_RUN     = 2'b01;
  localparam Q_DENIED  = 2'b10;


  reg [1:0]                   state;
  reg [1:0]                   nxt_state;
  reg                         clk_enable;
  reg                         state_en;

  wire                        clk_required;

  reg                         ppuclk_qacceptn_r;
  reg                         ppuclk_qdeny_r;
  reg                         ppuclk_qactive_r;

  reg                         nxt_ppuclk_qacceptn_r;
  reg                         nxt_ppuclk_qdeny_r;
  wire                        nxt_ppuclk_qactive_r;



  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      state[1:0] <= Q_STOPPED;
    end
    else if(state_en)
    begin
      state[1:0] <= nxt_state[1:0];
    end
  end

  always@*
  begin
    case(state[1:0])
    Q_STOPPED:
    begin
      nxt_state[1:0] = Q_RUN;
      state_en = ppuclk_qreqn_i;
      nxt_ppuclk_qacceptn_r = 1'b1;
      nxt_ppuclk_qdeny_r = 1'b0;
      clk_enable = ppuclk_qreqn_i;
    end
    Q_RUN:
    begin
      state_en = ~ppuclk_qreqn_i;
      clk_enable = 1'b1;
      case(clk_required)
      1'b0:
      begin
        nxt_state[1:0] = Q_STOPPED;
        nxt_ppuclk_qacceptn_r = 1'b0;
        nxt_ppuclk_qdeny_r = 1'b0;
      end
      1'b1:
      begin
        nxt_state[1:0] = Q_DENIED;
        nxt_ppuclk_qacceptn_r = 1'b1;
        nxt_ppuclk_qdeny_r = 1'b1;
      end
      default:
      begin
        nxt_state[1:0] = 2'bxx;
        nxt_ppuclk_qacceptn_r = 1'bx;
        nxt_ppuclk_qdeny_r = 1'bx;
      end
      endcase
    end
    Q_DENIED:
    begin
      nxt_state[1:0] = Q_RUN;
      state_en = ppuclk_qreqn_i;
      nxt_ppuclk_qacceptn_r = 1'b1;
      nxt_ppuclk_qdeny_r = 1'b0;
      clk_enable = 1'b1;
    end
    default:
    begin
      nxt_state[1:0] = 2'bxx;
      state_en = 1'bx;
      nxt_ppuclk_qacceptn_r = 1'bx;
      nxt_ppuclk_qdeny_r = 1'bx;
      clk_enable = 1'bx;
    end
    endcase
  end

  assign clk_required = ppuclk_qactive_r | nxt_ppuclk_qactive_r | edge_clk_req_i;


  pck600_ppu_ccu_async_sse710_dbg
  #(
    .NUM_PWR_DEVACTIVE(NUM_PWR_DEVACTIVE),
    .DEVACTIVE_LSB    (DEVACTIVE_LSB)
  )
  u_pck600_ppu_ccu_async
  (
    //Async DEVxACTIVEs
    .pwr_devactive_async_i(pwr_devactive_async_i),
    //Sync DEVxACTIVEs and PWAKEUP
    .pwr_devactive_st_i   (pwr_devactive_st_i),
    .pwakeup_i            (pwakeup_i),
    //Internal QACTIVE
    .ppuclk_qactive_int_i (ppuclk_qactive_r),
    //QACTIVE
    .ppuclk_qactive_o     (ppuclk_qactive_o)
  );


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      ppuclk_qacceptn_r <= 1'b0;
      ppuclk_qdeny_r <= 1'b0;
    end
    else if(state_en)
    begin
      ppuclk_qacceptn_r <= nxt_ppuclk_qacceptn_r;
      ppuclk_qdeny_r <= nxt_ppuclk_qdeny_r;
    end
  end

  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      ppuclk_qactive_r <= 1'b1;
    end
    else
    begin
      ppuclk_qactive_r <= nxt_ppuclk_qactive_r;
    end
  end

  assign nxt_ppuclk_qactive_r = reg_clk_req_i | mtu_clk_req_i;


  assign ppuclk_qacceptn_o = ppuclk_qacceptn_r;
  assign ppuclk_qdeny_o = ppuclk_qdeny_r;

  assign cg_enable_o = nxt_ppuclk_qactive_r | edge_clk_req_i;

  assign clk_enable_o = clk_enable;

endmodule

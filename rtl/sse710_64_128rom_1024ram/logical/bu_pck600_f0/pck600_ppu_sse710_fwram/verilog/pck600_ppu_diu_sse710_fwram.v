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


module pck600_ppu_diu_sse710_fwram
#(
  parameter DEV_PREQ_DLY = 2'b00,
  parameter DEVPSTATE_WIDTH = 4,
  parameter NUM_DEV_LPI = 1
)
(

  //Clock and Reset
  input wire                  clk,
  input wire                  reset_n,

  //Device Interface
  output wire                 dev_preq_o,
  output wire [DEVPSTATE_WIDTH-1:0] dev_pstate_o,
  input wire                  dev_paccept_i,
  input wire                  dev_pdeny_i,

  //PSM Interface
  input wire [1:0]            diu_req_i,
  input wire [3:0]            diu_pwr_mode_i,
  input wire                  diu_stall_i,
  output wire                 diu_accept_o,
  output wire                 diu_comp_o,
  output wire                 diu_req_high_o,

  //REG Interface
  input wire [NUM_DEV_LPI-1:0] devreqen_i

);


  localparam P_STABLE = 3'b000;
  localparam P_STABLE0 = 3'b000;
  localparam P_STABLE1 = 3'b001;
  localparam P_DELAY = 3'b010;
  localparam P_REQUEST = 3'b011;
  localparam P_ACCEPT = 3'b100;
  localparam P_DENIED_DELAY = 3'b101;
  localparam P_DENIED = 3'b110;


  reg [2:0]                   state;
  reg [2:0]                   nxt_state;
  reg                         state_en;
  reg                         diu_comp_r;
  reg                         diu_accept_r;
  reg                         nxt_diu_comp_r;
  reg                         nxt_diu_accept_r;
  reg [DEVPSTATE_WIDTH-1:0]   prev_dev_pstate_r;

  wire                        dev_preq_dly_enable;
  wire                        dev_preq_dly_expire;

  reg                         dev_preq_r;
  reg [DEVPSTATE_WIDTH-1:0]   dev_pstate_r;

  reg                         nxt_dev_preq_r;
  reg [DEVPSTATE_WIDTH-1:0]   nxt_dev_pstate_r;



  always@(posedge clk)
  begin
    if(diu_req_i[0])
    begin
      prev_dev_pstate_r[DEVPSTATE_WIDTH-1:0] <= dev_pstate_r[DEVPSTATE_WIDTH-1:0];
    end
  end


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      state[2:0] <= P_STABLE0;
      dev_preq_r <= 1'b0;
      dev_pstate_r[DEVPSTATE_WIDTH-1:0] <= {DEVPSTATE_WIDTH{1'b0}};
      diu_comp_r <= 1'b0;
      diu_accept_r <= 1'b1;
    end
    else if(state_en)
    begin
      state[2:0] <= nxt_state[2:0];
      dev_preq_r <= nxt_dev_preq_r;
      dev_pstate_r[DEVPSTATE_WIDTH-1:0] <= nxt_dev_pstate_r[DEVPSTATE_WIDTH-1:0];
      diu_comp_r <= nxt_diu_comp_r;
      diu_accept_r <= nxt_diu_accept_r;
    end
  end

  always@*
  begin
    case(state[2:0])
    P_STABLE0,P_STABLE1:
    begin
      state_en = diu_req_i[1];
      case({diu_req_i[0],devreqen_i[0],dev_preq_dly_enable})
      3'b000,3'b001,3'b100,3'b101:
      begin
        nxt_state[2:0] = {P_STABLE[2:1],state[0]};
        nxt_dev_preq_r = 1'b0;
        nxt_dev_pstate_r[DEVPSTATE_WIDTH-1:0] = dev_pstate_r[DEVPSTATE_WIDTH-1:0];
        nxt_diu_comp_r = 1'b1;
        nxt_diu_accept_r = 1'b1;
      end
      3'b010,3'b011:
      begin
        nxt_state[2:0] = {P_STABLE[2:1],~state[0]};
        nxt_dev_preq_r = 1'b0;
        nxt_dev_pstate_r[DEVPSTATE_WIDTH-1:0] = diu_pwr_mode_i[3:0];
        nxt_diu_comp_r = 1'b1;
        nxt_diu_accept_r = 1'b1;
      end
      3'b110:
      begin
        nxt_state[2:0] = P_REQUEST;
        nxt_dev_preq_r = 1'b1;
        nxt_dev_pstate_r[DEVPSTATE_WIDTH-1:0] = diu_pwr_mode_i[3:0];
        nxt_diu_comp_r = 1'b0;
        nxt_diu_accept_r = 1'b0;
      end
      3'b111:
      begin
        nxt_state[2:0] = P_DELAY;
        nxt_dev_preq_r = 1'b0;
        nxt_dev_pstate_r[DEVPSTATE_WIDTH-1:0] = diu_pwr_mode_i[3:0];
        nxt_diu_comp_r = 1'b0;
        nxt_diu_accept_r = 1'b0;
      end
      default:
      begin
        nxt_state[2:0] = 3'bxxx;
        nxt_dev_preq_r = 1'bx;
        nxt_dev_pstate_r[DEVPSTATE_WIDTH-1:0] = {DEVPSTATE_WIDTH{1'bx}};
        nxt_diu_comp_r = 1'bx;
        nxt_diu_accept_r = 1'bx;
      end
      endcase
    end
    P_DELAY:
    begin
      nxt_state[2:0] = P_REQUEST;
      state_en = dev_preq_dly_expire;
      nxt_dev_preq_r = 1'b1;
      nxt_dev_pstate_r[DEVPSTATE_WIDTH-1:0] = dev_pstate_r[DEVPSTATE_WIDTH-1:0];
      nxt_diu_comp_r = 1'b0;
      nxt_diu_accept_r = 1'b0;
    end
    P_REQUEST:
    begin
      state_en = (dev_paccept_i | dev_pdeny_i) & ~diu_stall_i;
      nxt_diu_comp_r = 1'b0;
      nxt_diu_accept_r = 1'b0;
      case({dev_paccept_i,dev_preq_dly_enable})
      2'b00:
      begin
        nxt_state[2:0] = P_DENIED;
        nxt_dev_preq_r = 1'b0;
        nxt_dev_pstate_r[DEVPSTATE_WIDTH-1:0] = prev_dev_pstate_r[DEVPSTATE_WIDTH-1:0];
      end
      2'b01:
      begin
        nxt_state[2:0] = P_DENIED_DELAY;
        nxt_dev_preq_r = 1'b1;
        nxt_dev_pstate_r[DEVPSTATE_WIDTH-1:0] = prev_dev_pstate_r[DEVPSTATE_WIDTH-1:0];
      end
      2'b10,2'b11:
      begin
        nxt_state[2:0] = P_ACCEPT;
        nxt_dev_preq_r = 1'b0;
        nxt_dev_pstate_r[DEVPSTATE_WIDTH-1:0] = dev_pstate_r[DEVPSTATE_WIDTH-1:0];
      end
      default:
      begin
        nxt_state[2:0] = 3'bxxx;
        nxt_dev_preq_r = 1'bx;
        nxt_dev_pstate_r[DEVPSTATE_WIDTH-1:0] = {DEVPSTATE_WIDTH{1'bx}};
      end
      endcase
    end
    P_ACCEPT:
    begin
      nxt_state[2:0] = P_STABLE0;
      state_en = ~dev_paccept_i;
      nxt_dev_preq_r = 1'b0;
      nxt_dev_pstate_r[DEVPSTATE_WIDTH-1:0] = dev_pstate_r[DEVPSTATE_WIDTH-1:0];
      nxt_diu_comp_r = 1'b1;
      nxt_diu_accept_r = 1'b1;
    end
    P_DENIED_DELAY:
    begin
      nxt_state[2:0] = P_DENIED;
      state_en = dev_preq_dly_expire;
      nxt_dev_preq_r = 1'b0;
      nxt_dev_pstate_r[DEVPSTATE_WIDTH-1:0] = dev_pstate_r[DEVPSTATE_WIDTH-1:0];
      nxt_diu_comp_r = 1'b0;
      nxt_diu_accept_r = 1'b0;
    end
    P_DENIED:
    begin
      nxt_state[2:0] = P_STABLE0;
      state_en = ~dev_pdeny_i;
      nxt_dev_preq_r = 1'b0;
      nxt_dev_pstate_r[DEVPSTATE_WIDTH-1:0] = dev_pstate_r[DEVPSTATE_WIDTH-1:0];
      nxt_diu_comp_r = 1'b1;
      nxt_diu_accept_r = 1'b0;
    end
    default:
    begin
      nxt_state[2:0] = 3'bxxx;
      state_en = 1'bx;
      nxt_dev_preq_r = 1'bx;
      nxt_dev_pstate_r[DEVPSTATE_WIDTH-1:0] = {DEVPSTATE_WIDTH{1'bx}};
      nxt_diu_comp_r = 1'bx;
      nxt_diu_accept_r = 1'bx;
    end
    endcase
  end


generate
if(DEV_PREQ_DLY > 0)
begin:dev_preq_dly_counter

  reg [1:0]                   dev_preq_dly_r;
  reg [1:0]                   nxt_dev_preq_dly_r;
  wire                        dev_preq_dly_en;
  wire                        dev_preq_dly_dec;
  wire                        dev_preq_dly_rst;

  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      dev_preq_dly_r[1:0] <= DEV_PREQ_DLY[1:0];
    end
    else if(dev_preq_dly_en)
    begin
      dev_preq_dly_r[1:0] <= nxt_dev_preq_dly_r[1:0];
    end
  end

  assign dev_preq_dly_dec = (state[2:0] == P_DELAY) | (state[2:0] == P_DENIED_DELAY);

  assign dev_preq_dly_rst = (state[2:0] == P_REQUEST) | (state[2:0] == P_DENIED);

  assign dev_preq_dly_en = dev_preq_dly_dec | dev_preq_dly_rst;

  always@*
  begin
    case({dev_preq_dly_rst,dev_preq_dly_dec})
    2'b00: nxt_dev_preq_dly_r[1:0] = dev_preq_dly_r[1:0];
    2'b01: nxt_dev_preq_dly_r[1:0] = dev_preq_dly_r[1:0] - 2'b01;
    2'b10: nxt_dev_preq_dly_r[1:0] = DEV_PREQ_DLY[1:0];
    default: nxt_dev_preq_dly_r[1:0] = 2'bxx;
    endcase
  end

  assign dev_preq_dly_expire = (dev_preq_dly_r[1:0] == 2'b01);

  assign dev_preq_dly_enable = 1'b1;

end
else
begin:no_dev_preq_dly_counter

  assign dev_preq_dly_expire = 1'b1;
  assign dev_preq_dly_enable = 1'b0;

end
endgenerate


  assign dev_preq_o = dev_preq_r;
  assign dev_pstate_o[DEVPSTATE_WIDTH-1:0] = dev_pstate_r[DEVPSTATE_WIDTH-1:0];

  assign diu_comp_o = diu_comp_r;
  assign diu_accept_o = diu_accept_r;
  assign diu_req_high_o = (state[2:0] == P_REQUEST) | ((state[2:1] == P_STABLE[2:1]) & ~devreqen_i[0]);

endmodule


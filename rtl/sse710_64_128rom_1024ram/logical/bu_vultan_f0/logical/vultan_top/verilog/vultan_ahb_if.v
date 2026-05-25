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
//      Checked In          : Wed Oct 25 12:39:08 2017 +0100
//
//      Revision            : 25f33d1
//
//      Release Information : Vultan Generic Flash Controller - Global Bundle r0p0-00rel0
//
//-----------------------------------------------------------------------------
module vultan_ahb_if(
   input  wire             clk,
   input  wire             resetn,

   input  wire             hsel,
   input  wire [21:0]      haddr,
   input  wire [1:0]       htrans,
   input  wire             hwrite,
   input  wire [2:0]       hsize,
   input  wire [2:0]       hburst,
   input  wire             hmastlock,
   input  wire             hready,
   output wire             hreadyout,
   output wire             hresp,
   output wire [127:0]     hrdata,

   output reg  [21:0]      faddr_ahb,
   output reg              freq_locked_ahb,
   output reg              freq_ahb,
   input  wire             fgnt_ahb,
   input  wire [127:0]     frdata_ahb,
   input  wire             fresp_ahb,
   input  wire             fready_ahb
);


localparam FSM_IDLE   = 2'b00;
localparam FSM_BUFFER = 2'b01;
localparam FSM_ACCEPT = 2'b10;
localparam FSM_REJECT = 2'b11;

wire         unsupported_ahb_cmd;
reg   [1:0]  gfb_state, gfb_state_nxt;
reg  [21:0]  faddr_reg, faddr_nxt;
reg          hresp_reg, hresp_nxt;



assign unsupported_ahb_cmd = htrans[1] & (hwrite | (hsize != 3'b100));

assign hreadyout = (fready_ahb & (gfb_state == FSM_ACCEPT)) | (gfb_state == FSM_IDLE);
assign hresp = (fresp_ahb & (gfb_state == FSM_ACCEPT)) | (hresp_reg & (gfb_state != FSM_ACCEPT));
assign hrdata = frdata_ahb;

always @*
begin
  gfb_state_nxt = gfb_state;
  freq_ahb = 1'b0;
  freq_locked_ahb = 1'b0;
  faddr_ahb = 22'h0;
  faddr_nxt = faddr_reg;
  hresp_nxt = 1'b0;
  case (gfb_state)
    FSM_IDLE:
      begin
        if (hready && hsel) begin
          if (unsupported_ahb_cmd) begin
            gfb_state_nxt = FSM_REJECT;
            hresp_nxt = 1'b1;
          end
          else begin
            freq_ahb = htrans[1];
            freq_locked_ahb = hmastlock | ((hburst != 3'h0) & (htrans != 2'h0));
            faddr_ahb = haddr;
            if (htrans[1]) begin
              if (fgnt_ahb && fready_ahb) begin
                 gfb_state_nxt = FSM_ACCEPT;
              end
              else begin
                gfb_state_nxt = FSM_BUFFER;
                faddr_nxt = haddr;
              end
            end
          end
        end
      end

    FSM_BUFFER:
      begin
        if (fgnt_ahb && fready_ahb) begin
          gfb_state_nxt = FSM_ACCEPT;
        end
        freq_ahb = 1'b1;
        freq_locked_ahb = hsel & (hmastlock | ((hburst != 3'h0) & (htrans != 2'h0)));
        faddr_ahb = faddr_reg;
      end

    FSM_ACCEPT:
      begin
        if (hsel && !unsupported_ahb_cmd) begin
          freq_ahb = htrans[1];
          freq_locked_ahb = hmastlock | ((hburst != 3'h0) & (htrans != 2'h0));
          faddr_ahb = haddr;
        end
        if (fready_ahb) begin
          if (hsel && unsupported_ahb_cmd) begin
            gfb_state_nxt = FSM_REJECT;
            hresp_nxt = 1'b1;
          end
          else if (!htrans[1] || !hsel) begin
            gfb_state_nxt = FSM_IDLE;
          end
          else if (fgnt_ahb) begin
            gfb_state_nxt = FSM_ACCEPT;
          end
          else begin
            gfb_state_nxt = FSM_BUFFER;
            faddr_nxt = haddr;
          end
        end
      end

    FSM_REJECT:
      begin
        gfb_state_nxt = FSM_IDLE;
        hresp_nxt = 1'b1;
      end

    default:
      begin
        gfb_state_nxt = 2'bxx;
      end
  endcase
end

always @ (posedge clk or negedge resetn)
begin
  if (!resetn) begin
    gfb_state <= FSM_IDLE;
    faddr_reg <= 22'h0;
    hresp_reg <= 1'b0;
  end
  else begin
    gfb_state <= gfb_state_nxt;
    faddr_reg <= faddr_nxt;
    hresp_reg <= hresp_nxt;
  end
end

endmodule

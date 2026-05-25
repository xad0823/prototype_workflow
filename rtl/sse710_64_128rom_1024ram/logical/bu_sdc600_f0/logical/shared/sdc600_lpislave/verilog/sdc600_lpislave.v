//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2017-2018 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//      Version Information
//
//      Checked In          : Mon Jun 18 15:48:10 2018 +0100
//
//      Revision            : 3b74199
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//-----------------------------------------------------------------------------

module sdc600_lpislave
(
  input  wire clk,
  input  wire reset_n,
  input  wire qreq_sync_n,
  output wire qaccept_n,
  output wire qdeny,
  output wire lp_request,
  input  wire int_dev_active,
  input  wire ext_dev_active,
  input  wire lp_done,
  output wire dev_run,
  output wire cg_en
);


wire      state_en;
reg [3:0] lpi_state, lpi_state_nxt;

localparam Q_STOPPED  = 4'b0000;
localparam Q_EXIT     = 4'b0001;
localparam Q_RUN      = 4'b1100;
localparam Q_REQUEST  = 4'b1101;
localparam DEVICE_OFF = 4'b0100;
localparam Q_DENY     = 4'b1110;
localparam UNUSED_0   = 4'b0010;
localparam UNUSED_1   = 4'b0011;
localparam UNUSED_2   = 4'b0101;
localparam UNUSED_3   = 4'b0110;
localparam UNUSED_4   = 4'b0111;
localparam UNUSED_5   = 4'b1000;
localparam UNUSED_6   = 4'b1001;
localparam UNUSED_7   = 4'b1010;
localparam UNUSED_8   = 4'b1011;
localparam UNUSED_9   = 4'b1111;


assign lp_request = ((lpi_state == Q_STOPPED) & ~qreq_sync_n) |
                    ((lpi_state == Q_RUN) & ~qreq_sync_n & ~int_dev_active) |
                    (lpi_state == Q_REQUEST) |
                    (lpi_state == DEVICE_OFF);

assign cg_en = (lpi_state != Q_STOPPED) | qreq_sync_n;

always @*
begin
  lpi_state_nxt = lpi_state;
  case (lpi_state)
    Q_STOPPED:
      begin
        if (qreq_sync_n) begin
          if (lp_done) begin
            lpi_state_nxt = Q_EXIT;
          end
          else begin
            lpi_state_nxt = Q_RUN;
          end
        end
      end

    Q_EXIT:
      begin
        if (!lp_done) begin
          lpi_state_nxt = Q_RUN;
        end
      end

    Q_RUN:
      begin
        if (!qreq_sync_n) begin
          if (int_dev_active) begin
            lpi_state_nxt = Q_DENY;
          end
          else if (lp_done) begin
            lpi_state_nxt = DEVICE_OFF;
          end
          else begin
            lpi_state_nxt = Q_REQUEST;
          end
        end
      end

    Q_REQUEST:
      begin
        if (lp_done) begin
          lpi_state_nxt = ext_dev_active ? Q_DENY : DEVICE_OFF;
        end
      end

    DEVICE_OFF:
      begin
        lpi_state_nxt = Q_STOPPED;
      end

    Q_DENY:
      begin
        if (qreq_sync_n && !lp_done) begin
          lpi_state_nxt = Q_RUN;
        end
      end

    UNUSED_0, UNUSED_1, UNUSED_2, UNUSED_3, UNUSED_4,
    UNUSED_5, UNUSED_6, UNUSED_7, UNUSED_8, UNUSED_9:
      begin
        lpi_state_nxt = Q_STOPPED;
      end

    default:
      begin
        lpi_state_nxt = 4'bxxxx;
      end
  endcase
end


assign state_en = (lpi_state_nxt != lpi_state);

always @(posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    lpi_state <= Q_STOPPED;
  end
  else if (state_en) begin
    lpi_state <= lpi_state_nxt;
  end
end

assign dev_run   = lpi_state[3];

assign qaccept_n = lpi_state[2];
assign qdeny     = lpi_state[1];


endmodule

//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------

module firewall_f0_ax_gate #(
    parameter AX_PAYLOAD_WIDTH     = 64,
    parameter W_PAYLOAD_WIDTH      = 40,
    parameter RD_NWR               = 0 
) (
    input  wire                        clk,
    input  wire                        reset_n,

    input  wire                        ax_valid_s,
    input  wire                        ax_wakeup_s,
    input  wire [AX_PAYLOAD_WIDTH-1:0] ax_payload_in,
    output wire                        ax_ready_s,

    output wire                        ax_valid_m,
    output wire                        ax_wakeup_m,
    output wire [AX_PAYLOAD_WIDTH-1:0] ax_payload_out,
    input  wire                        ax_ready_m,

    input  wire                        wvalid_s,
    input  wire                        wlast_s,
    input  wire [W_PAYLOAD_WIDTH-1:0]  wpayload_in,
    output wire                        wready_s,

    output wire                        wvalid_m,
    output wire                        wlast_m,
    output wire [W_PAYLOAD_WIDTH-1:0]  wpayload_out,
    input  wire                        wready_m,

    input  wire                        bvalid_m,
    input  wire                        rvalid_m,
    output wire                        bvalid_s,
    output wire                        rvalid_s,

    output  wire                       bready_m,
    output  wire                       rready_m,
    input   wire                       bready_s,
    input   wire                       rready_s,

    input  wire                        ax_tracker_full,

    input  wire                        next_hold_req,
    output reg                         next_hold_ack,
    output wire                        busy
);

  wire allow_next_trans;

generate

  if (RD_NWR == 1) begin : READ
    assign allow_next_trans = ~(next_hold_req | ax_tracker_full);

    assign ax_valid_m = allow_next_trans & ax_valid_s;
    assign ax_wakeup_m = allow_next_trans & ax_wakeup_s;

    assign ax_payload_out = ax_payload_in;

    assign ax_ready_s = allow_next_trans & ax_ready_m;

    assign rvalid_s = rvalid_m ;
    assign bvalid_s = 1'b0;
    assign rready_m = rready_s;
    assign bready_m = 1'b0;

    assign busy =  ax_valid_s; 

    always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        next_hold_ack <= 1'b0;
      end else begin
        next_hold_ack <= next_hold_req;
      end
    end

    assign wready_s = 1'b0;
    assign wvalid_m = 1'b0;
    assign wlast_m = 1'b0;
    assign wpayload_out = {W_PAYLOAD_WIDTH{1'b0}};

  end else begin : WRITE

    reg wdata_block;
    reg axready_recd;
    reg trans_progress;
    wire axready_recd_cmb;
    wire wdata_block_cmb;

    always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        wdata_block <= 1'b0;
        axready_recd <= 1'b0;
      end else begin

        if (ax_valid_s && ax_ready_s) begin 
          axready_recd <= 1'b0;
        end else if (wvalid_s && ax_valid_s && !trans_progress && allow_next_trans) begin 
          axready_recd <= 1'b1;
        end

        if (wvalid_s && wlast_s && wready_s ) begin  
          wdata_block <= 1'b0;
        end else if (wvalid_s && ax_valid_s && !trans_progress && allow_next_trans) begin
          wdata_block <= 1'b1;
        end
      end
    end

    assign wdata_block_cmb = wvalid_s && ax_valid_s && !trans_progress && allow_next_trans;
    assign axready_recd_cmb = ax_valid_s & wvalid_s & !trans_progress & allow_next_trans;
    assign allow_next_trans = ~(next_hold_req | ax_tracker_full );


    assign bvalid_s = bvalid_m ;

    assign rvalid_s = 1'b0;
    assign bready_m = bready_s;

    assign rready_m = 1'b0;

    assign ax_valid_m = ax_valid_s & (axready_recd_cmb |  axready_recd)  ;

    assign ax_wakeup_m = ax_wakeup_s & (axready_recd_cmb |  axready_recd);

    assign ax_payload_out = ax_payload_in;

    assign ax_ready_s = ax_ready_m & (axready_recd_cmb |  axready_recd)  ;

    assign busy = ax_valid_s | wvalid_s; 

    assign wvalid_m = wvalid_s & (wdata_block | wdata_block_cmb);
    assign wlast_m = wlast_s & (wdata_block | wdata_block_cmb);
    assign wpayload_out = (wdata_block | wdata_block_cmb) ? wpayload_in : {W_PAYLOAD_WIDTH{1'b0}};

    assign wready_s = wready_m & (wdata_block | wdata_block_cmb);

    always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        next_hold_ack <= 1'b0;
        trans_progress <= 1'b0;
      end else begin
        next_hold_ack <= next_hold_req;
        trans_progress <= wdata_block | wdata_block_cmb | axready_recd | axready_recd_cmb;
      end
    end
  end
endgenerate

endmodule

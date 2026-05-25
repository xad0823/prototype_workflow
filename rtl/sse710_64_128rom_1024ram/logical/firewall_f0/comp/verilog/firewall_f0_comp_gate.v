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

module firewall_f0_comp_gate #(
  parameter FC_SINGLE_MST       = 1,
  parameter FC_ME_LVL           = 2,
  parameter FC_ADDR_WIDTH       = 64,
  parameter FC_AXIDATA_WIDTH    = 64,
  parameter FC_AXIID_WIDTH      = 9 ,
  parameter FC_MST_ID_WIDTH     = 8,
  parameter FC_NUM_READ_OS      = 16,
  parameter FC_NUM_WRITE_OS     = 16,
  parameter FC_AXIUSER_AR_WIDTH = 1,
  parameter FC_AXIUSER_AW_WIDTH = 1,
  parameter FC_AXIUSER_W_WIDTH  = 1,
  parameter FC_AXIUSER_R_WIDTH  = 1,
  parameter FC_AXIUSER_B_WIDTH  = 1,
  parameter TRACKER_PAYLOAD_WIDTH_AR = 4,  
  parameter TRACKER_PAYLOAD_WIDTH_AW = 4
) (
    input  wire                       clk,
    input  wire                       reset_n,

    input  wire [FC_AXIID_WIDTH-1:0]              arid_s_i    ,
    input  wire [FC_ADDR_WIDTH-1:0]               araddr_s_i  ,
    input  wire [7:0]                             arlen_s_i   ,
    input  wire [2:0]                             arsize_s_i  ,
    input  wire [1:0]                             arburst_s_i ,
    input  wire                                   arlock_s_i  ,
    input  wire [3:0]                             arcache_s_i ,
    input  wire [2:0]                             arprot_s_i  ,
    input  wire [3:0]                             arqos_s_i   ,
    input  wire [3:0]                             arregion_s_i,
    input  wire [FC_AXIUSER_AR_WIDTH-1:0]         aruser_s_i  ,
    input  wire                                   arvalid_s_i ,
    output wire                                   arready_s_o ,
    input  wire [FC_MST_ID_WIDTH-1:0]             armmusid_s_i,

    input  wire [FC_AXIID_WIDTH-1:0]              awid_s_i    ,
    input  wire [FC_ADDR_WIDTH-1:0]               awaddr_s_i  ,
    input  wire [7:0]                             awlen_s_i   ,
    input  wire [2:0]                             awsize_s_i  ,
    input  wire [1:0]                             awburst_s_i ,
    input  wire                                   awlock_s_i  ,
    input  wire [3:0]                             awcache_s_i ,
    input  wire [2:0]                             awprot_s_i  ,
    input  wire [3:0]                             awqos_s_i   ,
    input  wire [3:0]                             awregion_s_i,
    input  wire [FC_AXIUSER_AW_WIDTH-1:0]         awuser_s_i  ,
    input  wire                                   awvalid_s_i ,
    output wire                                   awready_s_o ,
    input  wire [FC_MST_ID_WIDTH-1:0]             awmmusid_s_i,

    input  wire [FC_AXIDATA_WIDTH-1:0]            wdata_s_i   ,
    input  wire [FC_AXIDATA_WIDTH/8-1:0]          wstrb_s_i   ,
    input  wire                                   wlast_s_i   ,
    input  wire [FC_AXIUSER_W_WIDTH-1:0]          wuser_s_i   ,
    input  wire                                   wvalid_s_i  ,
    output wire                                   wready_s_o  ,

    output wire [FC_AXIID_WIDTH-1:0]              bid_s_o     ,
    output wire [1:0]                             bresp_s_o   ,
    output wire [FC_AXIUSER_B_WIDTH-1:0]          buser_s_o   ,
    output wire                                   bvalid_s_o  ,
    input  wire                                   bready_s_i  ,

    output wire [FC_AXIID_WIDTH-1:0]              rid_s_o     ,
    output wire [FC_AXIDATA_WIDTH-1:0]            rdata_s_o   ,
    output wire [1:0]                             rresp_s_o   ,
    output wire                                   rlast_s_o   ,
    output wire [FC_AXIUSER_R_WIDTH-1:0]          ruser_s_o   ,
    output wire                                   rvalid_s_o  ,
    input  wire                                   rready_s_i  ,

    input  wire                                   awakeup_s_i ,

    output wire [FC_AXIID_WIDTH-1:0]              arid_m_o    ,
    output wire [FC_ADDR_WIDTH-1:0]               araddr_m_o  ,
    output wire [7:0]                             arlen_m_o   ,
    output wire [2:0]                             arsize_m_o  ,
    output wire [1:0]                             arburst_m_o ,
    output wire                                   arlock_m_o  ,
    output wire [3:0]                             arcache_m_o ,
    output wire [2:0]                             arprot_m_o  ,
    output wire [3:0]                             arqos_m_o   ,
    output wire [3:0]                             arregion_m_o,
    output wire [FC_AXIUSER_AR_WIDTH-1:0]         aruser_m_o  ,
    output wire                                   arvalid_m_o ,
    input  wire                                   arready_m_i ,
    output wire [FC_MST_ID_WIDTH-1:0]             armmusid_m_o,

    output wire [FC_AXIID_WIDTH-1:0]              awid_m_o    ,
    output wire [FC_ADDR_WIDTH-1:0]               awaddr_m_o  ,
    output wire [7:0]                             awlen_m_o   ,
    output wire [2:0]                             awsize_m_o  ,
    output wire [1:0]                             awburst_m_o ,
    output wire                                   awlock_m_o  ,
    output wire [3:0]                             awcache_m_o ,
    output wire [2:0]                             awprot_m_o  ,
    output wire [3:0]                             awqos_m_o   ,
    output wire [3:0]                             awregion_m_o,
    output wire [FC_AXIUSER_AW_WIDTH-1:0]         awuser_m_o  ,
    output wire                                   awvalid_m_o ,
    input  wire                                   awready_m_i ,
    output wire [FC_MST_ID_WIDTH-1:0]             awmmusid_m_o,

    output wire [FC_AXIDATA_WIDTH-1:0]            wdata_m_o   ,
    output wire [FC_AXIDATA_WIDTH/8-1:0]          wstrb_m_o   ,
    output wire                                   wlast_m_o   ,
    output wire [FC_AXIUSER_W_WIDTH-1:0]          wuser_m_o   ,
    output wire                                   wvalid_m_o  ,
    input  wire                                   wready_m_i  ,

    input  wire [FC_AXIID_WIDTH-1:0]              bid_m_i     ,
    input  wire [1:0]                             bresp_m_i   ,
    input  wire [FC_AXIUSER_B_WIDTH-1:0]          buser_m_i   ,
    input  wire                                   bvalid_m_i  ,
    output wire                                   bready_m_o  ,

    input  wire [FC_AXIID_WIDTH-1:0]              rid_m_i     ,
    input  wire [FC_AXIDATA_WIDTH-1:0]            rdata_m_i   ,
    input  wire [1:0]                             rresp_m_i   ,
    input  wire                                   rlast_m_i   ,
    input  wire [FC_AXIUSER_R_WIDTH-1:0]          ruser_m_i   ,
    input  wire                                   rvalid_m_i  ,
    output wire                                   rready_m_o  ,

    output wire                                   awakeup_m_o ,

    input  wire                                   gate_hold_req_i,
    output wire                                   gate_hold_ack_o,
    output wire                                   gate_busy_o,

    output wire                                   tracker_al_empty_rd_o,
    output wire                                   tracker_al_empty_wr_o,
    output wire                                   tracker_empty_rd_o,
    output wire                                   tracker_empty_wr_o,

    input  wire [FC_AXIID_WIDTH-1:0]              tracker_id_rd_ch_i,
    input  wire [FC_AXIID_WIDTH-1:0]              tracker_id_wr_ch_i,
    input  wire                                   tracker_read_rd_ch_i,
    input  wire                                   tracker_read_wr_ch_i,
    output wire [TRACKER_PAYLOAD_WIDTH_AR-1:0]    tracker_dout_rd_ch_o,
    output wire [TRACKER_PAYLOAD_WIDTH_AW-1:0]    tracker_dout_wr_ch_o,

    output wire                                   tracker_dout_rd_ch_vld_o,
    output wire                                   tracker_dout_wr_ch_vld_o
);


localparam GATE_PAYLOAD_WIDTH_AR = FC_ADDR_WIDTH + FC_AXIID_WIDTH +
                                   FC_MST_ID_WIDTH + FC_AXIUSER_AR_WIDTH +
                                   8 + 3 + 2 + 1 + 4 + 3 + 4 + 4;

localparam GATE_PAYLOAD_WIDTH_AW = FC_ADDR_WIDTH + FC_AXIID_WIDTH +
                                   FC_MST_ID_WIDTH + FC_AXIUSER_AW_WIDTH +
                                   8 + 3 + 2 + 1 + 4 + 3 + 4 + 4;

localparam GATE_PAYLOAD_WIDTH_W = FC_AXIDATA_WIDTH + FC_AXIDATA_WIDTH/8 + FC_AXIUSER_W_WIDTH;

wire [GATE_PAYLOAD_WIDTH_AR-1:0]    ar_payload_in_wire;
wire [GATE_PAYLOAD_WIDTH_AR-1:0]    ar_payload_out_wire;

wire [GATE_PAYLOAD_WIDTH_AW-1:0]    aw_payload_in_wire;
wire [GATE_PAYLOAD_WIDTH_AW-1:0]    aw_payload_out_wire;

wire [GATE_PAYLOAD_WIDTH_W-1:0]     w_payload_in_wire;
wire [GATE_PAYLOAD_WIDTH_W-1:0]     w_payload_out_wire;

wire                                ar_wakeup;
wire                                aw_wakeup;
wire                                ar_tracker_full;
wire                                aw_tracker_full;
wire                                ar_hold_ack;
wire                                aw_hold_ack;
wire                                ar_busy_gate;
wire                                aw_busy_gate;
wire                                ar_busy_tracker;
wire                                aw_busy_tracker;

wire [TRACKER_PAYLOAD_WIDTH_AR-1:0] trk_data_in_r_wire;
wire [TRACKER_PAYLOAD_WIDTH_AR-1:0] trk_data_in_w_wire;

assign w_payload_in_wire                 = {wdata_s_i, wstrb_s_i, wuser_s_i};
assign {wdata_m_o, wstrb_m_o, wuser_m_o} = w_payload_out_wire;


assign awakeup_m_o = awakeup_s_i;

assign gate_busy_o = ar_busy_gate |
                     aw_busy_gate |
                     ar_busy_tracker |
                     aw_busy_tracker;


assign gate_hold_ack_o = ar_hold_ack & aw_hold_ack;

assign ar_payload_in_wire = {araddr_s_i, arid_s_i, armmusid_s_i, aruser_s_i,
                             arlen_s_i, arsize_s_i, arburst_s_i, arlock_s_i,
                             arcache_s_i, arprot_s_i, arqos_s_i, arregion_s_i};

assign aw_payload_in_wire = {awaddr_s_i, awid_s_i, awmmusid_s_i, awuser_s_i,
                             awlen_s_i, awsize_s_i, awburst_s_i, awlock_s_i,
                             awcache_s_i, awprot_s_i, awqos_s_i, awregion_s_i};

assign  {araddr_m_o, arid_m_o, armmusid_m_o, aruser_m_o,
         arlen_m_o, arsize_m_o, arburst_m_o, arlock_m_o,
         arcache_m_o, arprot_m_o, arqos_m_o, arregion_m_o} = ar_payload_out_wire;

assign  {awaddr_m_o, awid_m_o, awmmusid_m_o, awuser_m_o,
         awlen_m_o, awsize_m_o, awburst_m_o, awlock_m_o,
         awcache_m_o, awprot_m_o, awqos_m_o, awregion_m_o} = aw_payload_out_wire;


generate
if (FC_SINGLE_MST == 0) begin : NO_SM_R

  if (FC_ME_LVL == 0) begin : MON0_R
    assign trk_data_in_r_wire = {TRACKER_PAYLOAD_WIDTH_AR{1'b0}};
  end else if (FC_ME_LVL == 1) begin : MON1_R
    assign trk_data_in_r_wire = {armmusid_s_i, arprot_s_i};
  end else if (FC_ME_LVL == 2) begin : MON2_R
    assign trk_data_in_r_wire = {armmusid_s_i, araddr_s_i, arprot_s_i};
  end

end else begin : SM_R

  if (FC_ME_LVL == 0) begin : MON0_R
    assign trk_data_in_r_wire = {TRACKER_PAYLOAD_WIDTH_AR{1'b0}};
  end else if (FC_ME_LVL == 1) begin : MON1_R
    assign trk_data_in_r_wire = {arprot_s_i};
  end else if (FC_ME_LVL == 2) begin : MON2_R
    assign trk_data_in_r_wire = {araddr_s_i, arprot_s_i};
  end

end
endgenerate

generate
if (FC_SINGLE_MST == 0) begin : NO_SM_W

  if (FC_ME_LVL == 0) begin : MON0_W
    assign trk_data_in_w_wire = {TRACKER_PAYLOAD_WIDTH_AR{1'b0}};
  end else if (FC_ME_LVL == 1) begin : MON1_W
    assign trk_data_in_w_wire = {awmmusid_s_i, awprot_s_i};
  end else if (FC_ME_LVL == 2) begin : MON2_W
    assign trk_data_in_w_wire = {awmmusid_s_i, awaddr_s_i, awprot_s_i};
  end

end else begin : SM_W

  if (FC_ME_LVL == 0) begin : MON0_W
    assign trk_data_in_w_wire = {TRACKER_PAYLOAD_WIDTH_AR{1'b0}};
  end else if (FC_ME_LVL == 1) begin : MON1_W
    assign trk_data_in_w_wire = {awprot_s_i};
  end else if (FC_ME_LVL == 2) begin : MON2_W
    assign trk_data_in_w_wire = {awaddr_s_i, awprot_s_i};
  end

end

endgenerate


firewall_f0_ax_gate #(
  .AX_PAYLOAD_WIDTH (GATE_PAYLOAD_WIDTH_AR),
  .W_PAYLOAD_WIDTH  (GATE_PAYLOAD_WIDTH_W),
  .RD_NWR (1) 
)
u_ax_gate_ar      (
  .clk            (clk),
  .reset_n        (reset_n),
  .ax_valid_s     (arvalid_s_i),
  .ax_wakeup_s    (awakeup_s_i),
  .ax_payload_in  (ar_payload_in_wire),
  .ax_ready_s     (arready_s_o),
  .ax_valid_m     (arvalid_m_o),
  .ax_wakeup_m    (ar_wakeup),
  .ax_payload_out (ar_payload_out_wire),
  .ax_ready_m     (arready_m_i),

  .wvalid_s       (1'b0),
  .wlast_s        (1'b0),
  .wpayload_in    ({GATE_PAYLOAD_WIDTH_W{1'b0}}),
  .wready_s       (), 

  .wvalid_m       (), 
  .wlast_m        (), 
  .wpayload_out   (), 
  .wready_m       (1'b0),

  .bvalid_m       (1'b0),
  .rvalid_m       (rvalid_m_i),
  .bvalid_s       ( ),  
  .rvalid_s       (rvalid_s_o),

  .bready_m       (), 
  .rready_m       (rready_m_o),
  .bready_s       (1'b0),
  .rready_s       (rready_s_i),

  .ax_tracker_full(ar_tracker_full),
  .next_hold_req  (gate_hold_req_i),
  .next_hold_ack  (ar_hold_ack),
  .busy           (ar_busy_gate)
);

firewall_f0_ax_tracker #(
    .PAYLOAD_WIDTH   (TRACKER_PAYLOAD_WIDTH_AR),
    .NUM_OUTSTAND    (FC_NUM_READ_OS),
    .FC_ME_LVL       (FC_ME_LVL),
    .ID_WIDTH        (FC_AXIID_WIDTH)
)
u_ax_tracker_ar  (
    .clk         (clk),
    .reset_n     (reset_n),
    .load        (arvalid_s_i & arready_s_o),
    .unload      (rvalid_s_o && rlast_s_o & rready_s_i),

    .trk_id_wr_i   (arid_s_i),
    .trk_data_in_i (trk_data_in_r_wire),

    .trk_rd_i      (tracker_read_rd_ch_i),
    .trk_id_rd_i   (tracker_id_rd_ch_i),
    .trk_data_out_o(tracker_dout_rd_ch_o),
    .trk_data_vld_o(tracker_dout_rd_ch_vld_o),

    .trk_full    (ar_tracker_full),
    .trk_al_empty(tracker_al_empty_rd_o),
    .trk_empty   (tracker_empty_rd_o),
    .busy        (ar_busy_tracker)
);


firewall_f0_ax_gate #(
  .AX_PAYLOAD_WIDTH (GATE_PAYLOAD_WIDTH_AW),
  .W_PAYLOAD_WIDTH  (GATE_PAYLOAD_WIDTH_W),
  .RD_NWR           (0) 
)
u_ax_gate_aw (
  .clk            (clk),
  .reset_n        (reset_n),
  .ax_valid_s     (awvalid_s_i),
  .ax_wakeup_s    (awakeup_s_i),
  .ax_payload_in  (aw_payload_in_wire),
  .ax_ready_s     (awready_s_o),
  .ax_valid_m     (awvalid_m_o),
  .ax_wakeup_m    (aw_wakeup),
  .ax_payload_out (aw_payload_out_wire),
  .ax_ready_m     (awready_m_i),

  .wvalid_s       (wvalid_s_i),
  .wlast_s        (wlast_s_i),
  .wpayload_in    (w_payload_in_wire),
  .wready_s       (wready_s_o),

  .wvalid_m       (wvalid_m_o),
  .wlast_m        (wlast_m_o),
  .wpayload_out   (w_payload_out_wire),
  .wready_m       (wready_m_i),

  .bvalid_m       (bvalid_m_i),
  .rvalid_m       (1'b0),
  .bvalid_s       (bvalid_s_o),
  .rvalid_s       (), 

  .bready_m       (bready_m_o),
  .rready_m       (), 
  .bready_s       (bready_s_i),
  .rready_s       (1'b0),



  .ax_tracker_full(aw_tracker_full),
  .next_hold_req  (gate_hold_req_i),
  .next_hold_ack  (aw_hold_ack),
  .busy           (aw_busy_gate)
);

firewall_f0_ax_tracker #(
    .PAYLOAD_WIDTH   (TRACKER_PAYLOAD_WIDTH_AW),
    .NUM_OUTSTAND    (FC_NUM_WRITE_OS),
    .FC_ME_LVL       (FC_ME_LVL),
    .ID_WIDTH        (FC_AXIID_WIDTH)
)
u_ax_tracker_aw(
    .clk         (clk),
    .reset_n     (reset_n),

    .load        (awvalid_s_i & awready_s_o),
    .unload      (bvalid_s_o & bready_s_i),

    .trk_id_wr_i   (awid_s_i),
    .trk_data_in_i (trk_data_in_w_wire),

    .trk_rd_i      (tracker_read_wr_ch_i),
    .trk_id_rd_i   (tracker_id_wr_ch_i),
    .trk_data_out_o(tracker_dout_wr_ch_o),
    .trk_data_vld_o(tracker_dout_wr_ch_vld_o),

    .trk_full    (aw_tracker_full),
    .trk_al_empty(tracker_al_empty_wr_o),
    .trk_empty   (tracker_empty_wr_o),
    .busy        (aw_busy_tracker)
);

assign  bid_s_o    = bid_m_i   ;
assign  bresp_s_o  = bresp_m_i ;
assign  buser_s_o  = buser_m_i ;

assign  rid_s_o    = rid_m_i   ;
assign  rdata_s_o  = rdata_m_i ;
assign  rresp_s_o  = rresp_m_i ;
assign  rlast_s_o  = rlast_m_i ;
assign  ruser_s_o  = ruser_m_i ;

endmodule

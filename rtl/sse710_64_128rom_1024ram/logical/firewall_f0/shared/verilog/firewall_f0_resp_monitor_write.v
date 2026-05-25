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

module firewall_f0_resp_monitor_write #(
  parameter FC_MST_ID_SINGLE_MST = 0,
  parameter FC_SINGLE_MST       = 1,
  parameter FC_ME_LVL           = 2,
  parameter FW_SE_LVL           = 2'h1, 
  parameter FC_INST_SPT         = 0,
  parameter FC_PRIV_SPT         = 0,
  parameter FC_ADDR_WIDTH       = 32,
  parameter FC_MST_ID_WIDTH     = 8,
  parameter FC_AXIID_WIDTH      = 9,
  parameter FC_AXIUSER_B_WIDTH  = 1,
  parameter TRACKER_PAYLOAD_WIDTH_AW = 4
)
(
    input  wire                                clk,
    input  wire                                reset_n,
    input  wire [FC_AXIID_WIDTH-1:0]           bid_m_i    ,
    input  wire [1:0]                          bresp_m_i  ,
    input  wire [FC_AXIUSER_B_WIDTH-1:0]       buser_m_i  ,
    input  wire                                bvalid_m_i ,
    output wire                                bready_m_o ,
    output wire [FC_AXIID_WIDTH-1:0]           bid_rh_o   ,
    output wire [1:0]                          bresp_rh_o ,
    output reg  [FC_AXIUSER_B_WIDTH-1:0]       buser_rh_o ,
    output wire                                bvalid_rh_o,
    input  wire                                bready_rh_i,
    output wire [FC_AXIID_WIDTH-1:0]           tracker_id_wr_ch_o,
    output wire                                tracker_read_wr_ch_o,
    input  wire [TRACKER_PAYLOAD_WIDTH_AW-1:0] tracker_dout_wr_ch_i,
    input  wire                                tracker_dout_wr_ch_vld_i,

    input  wire                                rb_st_me_en_i,

    output wire                                wr_edr_wen_o,
    output wire [31:0]                         wr_edr_addr_lwr_o,
    output wire [31:0]                         wr_edr_addr_uppr_o,
    output wire [FC_MST_ID_WIDTH+4-1:0]        wr_edr_prop_o
);

localparam AW = (FC_ME_LVL == 1) ? 0 : FC_ADDR_WIDTH;

generate


  if (FC_ME_LVL == 0) begin : NO_MON
    assign wr_edr_wen_o         = 1'b0;
    assign wr_edr_addr_uppr_o   = {32 {1'b0}};
    assign wr_edr_addr_lwr_o    = {32 {1'b0}};
    assign wr_edr_prop_o        = {FC_MST_ID_WIDTH+4 {1'b0}};
    assign bid_rh_o             = bid_m_i;
    assign bresp_rh_o           = bresp_m_i;
    always@(*) buser_rh_o       = buser_m_i;
    assign bvalid_rh_o          = bvalid_m_i;
    assign bready_m_o           = bready_rh_i;
    assign tracker_id_wr_ch_o   = {FC_AXIID_WIDTH {1'b0}};
    assign tracker_read_wr_ch_o = 1'b0;

  end else if (FC_ME_LVL > 0) begin : MON

    wire fault;
    wire no_fault;
    reg  busy;


    assign fault    = rb_st_me_en_i && (bresp_m_i == 2'b10 || bresp_m_i == 2'b11) && (buser_m_i[0] == 1'b0);
    assign no_fault = ~fault;


    assign wr_edr_wen_o = fault && tracker_read_wr_ch_o;  

    if (FC_ME_LVL == 1) begin : MON1
      assign {wr_edr_addr_uppr_o, wr_edr_addr_lwr_o} = 64'b0;
    end else if (AW == 64) begin : MON2_AW_EQ64
      assign {wr_edr_addr_uppr_o, wr_edr_addr_lwr_o} = tracker_dout_wr_ch_i[AW+3-1:3];
    end else begin : AW_LT_64 
      assign {wr_edr_addr_uppr_o, wr_edr_addr_lwr_o} = {{64-AW {1'b0}}, tracker_dout_wr_ch_i[AW+3-1:3]};
    end


    if (FC_SINGLE_MST == 0) begin : NO_SM_PROP
      if (FC_ME_LVL == 1) begin : ME1
        assign wr_edr_prop_o[FC_MST_ID_WIDTH+4-1:4]      = tracker_dout_wr_ch_i[FC_MST_ID_WIDTH+3-1:3]; 

      end else begin : ME2 
        assign wr_edr_prop_o[FC_MST_ID_WIDTH+4-1:4]      = tracker_dout_wr_ch_i[FC_MST_ID_WIDTH+AW+3-1:AW+3] ; 
      end 
    end else begin : SM_PROP  
      assign wr_edr_prop_o[FC_MST_ID_WIDTH+4-1:4]      = FC_MST_ID_SINGLE_MST[FC_MST_ID_WIDTH-1:0]; 
    end

    assign wr_edr_prop_o[3] = 1'b1;  
    assign wr_edr_prop_o[2] = (FC_INST_SPT == 1) ? tracker_dout_wr_ch_i[2] : 1'b0;
    assign wr_edr_prop_o[1] = (FC_PRIV_SPT == 1) ? tracker_dout_wr_ch_i[0] : 1'b0;
    assign wr_edr_prop_o[0] = (FW_SE_LVL   == 1) ? tracker_dout_wr_ch_i[1] : 1'b0;

    assign tracker_read_wr_ch_o = bvalid_m_i & bready_m_o;
    assign tracker_id_wr_ch_o   = bid_m_i;

    assign bvalid_rh_o = bvalid_m_i;
    assign bid_rh_o    = bid_m_i;
    assign bresp_rh_o  = bresp_m_i;
    always@(*) begin
      buser_rh_o       = buser_m_i;
      buser_rh_o[0]    = buser_m_i[0] || fault; 
    end

    assign bready_m_o = bready_rh_i;

  end
endgenerate
endmodule

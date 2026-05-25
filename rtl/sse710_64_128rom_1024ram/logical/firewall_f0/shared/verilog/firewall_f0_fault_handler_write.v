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

module firewall_f0_fault_handler_write #(
  parameter FC_ADDR_WIDTH       = 64,
  parameter FC_AXIID_WIDTH      = 9,
  parameter FC_MST_ID_WIDTH     = 8,
  parameter FC_AXIUSER_AW_WIDTH = 1,
  parameter FC_AXIUSER_B_WIDTH  = 1,
  `include "firewall_f0_reg_width_params.vh"
  ,
  `include "firewall_f0_ctlr_reg_addr_params.vh"

)
(
    input  wire                              clk,
    input  wire                              reset_n,

    input  wire [FC_AXIID_WIDTH-1:0]         axid_flt_i    ,
    input  wire [FC_ADDR_WIDTH-1:0]          axaddr_flt_i  ,
    input  wire [2:0]                        axprot_flt_i  ,
    output  reg                              axready_flt_o ,
    input  wire [FC_MST_ID_WIDTH-1:0]        axmmusid_flt_i,
    input  wire                              filter_result_vld_i,
    input  wire [1:0]                        filter_result_val_i, 

    output  reg [FC_AXIID_WIDTH-1:0]         bid_o   ,
    output wire [1:0]                        bresp_o ,
    output wire [FC_AXIUSER_B_WIDTH-1:0]     buser_o ,
    output  reg                              bvalid_o,
    input  wire                              bready_i,

    input  wire                              wlast_i,
    input  wire                              wvalid_i,
    input  wire                              wready_i,

    input  wire                              tracker_al_empty_wr_i,
    input  wire                              tracker_empty_wr_i ,
    output wire                              tracker_rd_o,
    output wire [FC_AXIID_WIDTH-1:0]         tracker_rd_bid_o,


    input  wire [1:0]                        pe_st_flt_cfg_i, 
    output reg [FE_TAL_WIDTH-1:0]            fe_tal_o,
    output wire [FE_TAU_WIDTH-1:0]           fe_tau_o,
    output reg [FE_TP_WIDTH-1:0]             fe_tp_o,
    output reg [FC_MST_ID_WIDTH-1:0]         fe_mid_o,
    output reg                               fe_valid_o,
    output reg                               fe_type_o,  
    output wire                              tmp_reg_err

);
reg [FC_AXIID_WIDTH-1:0] axid_reg;
reg [FC_ADDR_WIDTH-1:0] axaddr_reg;
reg [2:0] axprot_reg;
reg [FC_MST_ID_WIDTH-1:0] axmst_id_reg;
reg wdata_end;
reg int_err_aw;
reg int_err_w;
wire wr_in_prog;
reg wr_in_prog_reg;

assign tracker_rd_o = bvalid_o & bready_i;
assign tracker_rd_bid_o = bid_o;

always @(posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    axready_flt_o <= 1'b0;
    axid_reg <= {FC_AXIID_WIDTH{1'b0}};
    axaddr_reg <= {FC_ADDR_WIDTH{1'b0}};
    axprot_reg <= 3'b000;
    axmst_id_reg <= {FC_MST_ID_WIDTH{1'b0}};

  end else begin

    if (filter_result_vld_i && (filter_result_val_i == 2'b01 || filter_result_val_i == 2'b10) && tracker_empty_wr_i && !axready_flt_o ) begin
      axready_flt_o <= 1'b1;
      axid_reg <= axid_flt_i;  
      axaddr_reg <= axaddr_flt_i;
      axprot_reg <= axprot_flt_i;
      axmst_id_reg <= axmmusid_flt_i;
    end else begin
      axready_flt_o <= 1'b0;
    end
  end
end


always @(posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    int_err_aw <= 1'b0;
    int_err_w <= 1'b0;
    wr_in_prog_reg <= 1'b0;
  end else begin

    if (int_err_aw && axready_flt_o) begin
      int_err_aw <= 1'b0;
    end else if (filter_result_vld_i && (filter_result_val_i == 2'b01 || filter_result_val_i == 2'b10) && tracker_empty_wr_i) begin
      int_err_aw <= 1'b1;
    end

    if (int_err_w && wready_i && wlast_i && wvalid_i) begin
      int_err_w <= 1'b0;
    end else if (filter_result_vld_i && (filter_result_val_i == 2'b01 || filter_result_val_i == 2'b10) && tracker_empty_wr_i && wvalid_i && ~wlast_i ) begin
      int_err_w <= 1'b1;
    end

    wr_in_prog_reg <= wr_in_prog;
  end
end

assign wr_in_prog = int_err_aw | int_err_w;

assign bresp_o = 2'b11; 
assign buser_o = {FC_AXIUSER_B_WIDTH{1'b0}}; 

always @(posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    bid_o    <= {FC_AXIID_WIDTH{1'b0}};
    bvalid_o <= 1'b0;
  end else if (~wr_in_prog && wr_in_prog_reg ) begin
    bvalid_o <= 1'b1;
    bid_o <= axid_reg;
  end else if (bready_i) begin
    bvalid_o <= 1'b0;
  end
end

generate
  if (FC_ADDR_WIDTH <= 32) begin : NO_TAU
    assign fe_tau_o = {FE_TAU_WIDTH{1'b0}};

    always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        fe_tal_o <= {FE_TAL_WIDTH{1'b0}};
      end else begin
        if (axready_flt_o && pe_st_flt_cfg_i==2'b10) begin 
          fe_tal_o[FC_ADDR_WIDTH-1:0] <= axaddr_reg[FC_ADDR_WIDTH-1:0];
        end else begin
          fe_tal_o <= {FE_TAL_WIDTH{1'b0}};
        end
      end
    end


  end else if (FC_ADDR_WIDTH == 64) begin : TAU64

  reg [FE_TAU_WIDTH-1:0] fe_tau_o_reg;

    assign fe_tau_o = fe_tau_o_reg;

    always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        fe_tau_o_reg <= {FE_TAU_WIDTH{1'b0}};
        fe_tal_o <= {FE_TAL_WIDTH{1'b0}};
      end else begin
        if (axready_flt_o && pe_st_flt_cfg_i==2'b10) begin 
          fe_tau_o_reg <= axaddr_reg[63:32];
          fe_tal_o <= axaddr_reg[31:0];
        end else begin
          fe_tau_o_reg <= {FE_TAU_WIDTH{1'b0}};
          fe_tal_o <= {FE_TAL_WIDTH{1'b0}};
        end
      end
    end

  end else if (FC_ADDR_WIDTH > 32 && FC_ADDR_WIDTH < 64 )begin : TAU64P
    reg [FE_TAU_WIDTH-1:0] fe_tau_o_reg;

    assign fe_tau_o = fe_tau_o_reg;

    always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        fe_tau_o_reg <= {FE_TAU_WIDTH{1'b0}};
        fe_tal_o <= {FE_TAL_WIDTH{1'b0}};

      end else begin
        if (axready_flt_o && pe_st_flt_cfg_i==2'b10) begin 
          fe_tau_o_reg[FC_ADDR_WIDTH-32-1:0] <= axaddr_reg[FC_ADDR_WIDTH-1:32];
          fe_tal_o <= axaddr_reg[31:0];
        end else begin
          fe_tau_o_reg <= {FE_TAU_WIDTH{1'b0}};
          fe_tal_o <= {FE_TAL_WIDTH{1'b0}};
        end
      end
    end
  end
endgenerate

assign tmp_reg_err = 1'b0;

always @(posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    fe_tp_o <= {FE_TP_WIDTH{1'b0}};
    fe_mid_o <= {FC_MST_ID_WIDTH{1'b0}};
    fe_valid_o <= 1'b0;
    fe_type_o  <= 1'b0;
  end else begin
    if (axready_flt_o && pe_st_flt_cfg_i==2'b10) begin 
      fe_tp_o[3] <=  1'b1; 
      fe_valid_o <= 1'b1;

      fe_tp_o[2] <= axprot_reg[2];
      fe_tp_o[1] <= axprot_reg[0];
      fe_tp_o[0] <= axprot_reg[1];

      fe_mid_o <= axmst_id_reg;

      if (filter_result_val_i == 2'b01) begin 
        fe_type_o  <= 1'b0;
      end else begin
        fe_type_o  <= 1'b1; 
      end

    end else begin
      fe_valid_o <= 1'b0;
      fe_tp_o <= {FE_TP_WIDTH{1'b0}};
      fe_mid_o <= {FC_MST_ID_WIDTH{1'b0}};
      fe_type_o  <= 1'b0;
    end

  end
end


endmodule

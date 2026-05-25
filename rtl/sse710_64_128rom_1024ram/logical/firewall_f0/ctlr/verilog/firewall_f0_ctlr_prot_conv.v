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

module firewall_f0_ctlr_prot_conv #(
    parameter FC_AXIID_WIDTH     = 2,
    parameter REG_ADDR_WIDTH     = 10,
    parameter REG_DATA_WIDTH     = 32,
    parameter FC_AXIUSER_B_WIDTH = 2,
    parameter FC_AXIUSER_R_WIDTH = 2,
    parameter FC_MST_ID_WIDTH    = 8,
    parameter LOG2_FW_NUM_FC     = 5,
    parameter FW_NUM_FC          = 15,
    parameter REG_ENUM_WIDTH     = 116,
    parameter FW_ID_WIDTH        = 6
) (
    input  wire                          clk,
    input  wire                          reset_n,

    input  wire [FC_AXIID_WIDTH-1:0]     prot_conv_arid_i,
    input  wire [REG_ADDR_WIDTH-1:0]     prot_conv_araddr_i,
    input  wire                          prot_conv_arvalid_i,
    output wire                          prot_conv_arready_o,
    input  wire [FC_AXIID_WIDTH-1:0]     prot_conv_awid_i,
    input  wire [REG_ADDR_WIDTH-1:0]     prot_conv_awaddr_i,
    input  wire                          prot_conv_awvalid_i,
    output wire                          prot_conv_awready_o,
    input  wire [REG_DATA_WIDTH-1:0]     prot_conv_wdata_i,
    input  wire                          prot_conv_wvalid_i,
    output wire                          prot_conv_wready_o,
    output wire [FC_AXIID_WIDTH-1:0]     prot_conv_bid_o,
    output wire [1:0]                    prot_conv_bresp_o,
    output wire [FC_AXIUSER_B_WIDTH-1:0] prot_conv_buser_o,
    output wire                          prot_conv_bvalid_o,
    input  wire                          prot_conv_bready_i,
    output wire [FC_AXIID_WIDTH-1:0]     prot_conv_rid_o,
    output wire [REG_DATA_WIDTH-1:0]     prot_conv_rdata_o,
    output wire [1:0]                    prot_conv_rresp_o,
    output wire                          prot_conv_rlast_o,
    output wire [FC_AXIUSER_R_WIDTH-1:0] prot_conv_ruser_o,
    output wire                          prot_conv_rvalid_o,
    input  wire                          prot_conv_rready_i,
    input  wire [FW_ID_WIDTH-1:0]        prot_conv_w_fw_id_i,
    input  wire [FW_ID_WIDTH-1:0]        prot_conv_r_fw_id_i,
    input  wire [FC_MST_ID_WIDTH-1:0]    prot_conv_w_mst_id_i,
    input  wire [FC_MST_ID_WIDTH-1:0]    prot_conv_r_mst_id_i,
    output wire [FC_MST_ID_WIDTH-1:0]    prot_conv_r_mst_id_o,
    input  wire [REG_ENUM_WIDTH-1:0]     prot_conv_enum_w_addr_i,
    input  wire [REG_ENUM_WIDTH-1:0]     prot_conv_enum_r_addr_i,
    input  wire [1:0]                    prot_conv_awprot_i,
    input  wire [1:0]                    prot_conv_arprot_i,

    output wire                          prot_conv_reg_tamp_o,
    output wire                          prot_conv_reg_tamp_w_o,

    output wire [REG_ADDR_WIDTH-1:0]     prot_conv_reg_addr_o,
    output wire                          prot_conv_rw_o,
    output wire [FW_ID_WIDTH-1:0]        prot_conv_fw_id_o,
    output wire [LOG2_FW_NUM_FC-1:0]     prot_conv_fc_id_o,
    output wire [REG_DATA_WIDTH-1:0]     prot_conv_wr_data_o,
    output wire                          prot_conv_acc_valid_o,
    output wire [REG_ENUM_WIDTH-1:0]     prot_conv_reg_enum_addr_o,
    output wire                          prot_conv_cfg_active_o,
    output wire [FC_MST_ID_WIDTH-1:0]    prot_conv_mst_id_o,
    output wire [1:0]                    prot_conv_axprot_o,

    input  wire                          prot_conv_pwr_block_i,
    output wire                          prot_conv_trkr_o,
    input  wire                          prot_conv_hndshk_pend_i,
    output wire                          prot_conv_cfg_pend_o,

    input  wire                          prot_conv_dn_prot_block_i,

    input  wire                          prot_conv_shdw_block_i,

    input  wire [1:0]                    prot_conv_wr_rsp_i,
    input  wire                          prot_conv_wr_tamp_i,
    input  wire                          prot_conv_wr_valid_i,
    input  wire [FC_AXIID_WIDTH-1:0]     prot_conv_wr_bid_i,
    output wire [FC_AXIID_WIDTH-1:0]     prot_conv_wr_bid_o,

    input  wire [1:0]                    prot_conv_rd_rsp_i,
    input  wire                          prot_conv_rd_tamp_i,
    input  wire                          prot_conv_rd_valid_i,
    input  wire [REG_DATA_WIDTH-1:0]     prot_conv_rd_data_i,
    input  wire [FC_MST_ID_WIDTH-1:0]    prot_conv_rd_mst_id_i,
    output wire [FC_MST_ID_WIDTH-1:0]    prot_conv_rd_mst_id_o,
    input  wire [FC_AXIID_WIDTH-1:0]     prot_conv_rd_rid_i,
    output wire [FC_AXIID_WIDTH-1:0]     prot_conv_rd_rid_o,

    output wire                          prot_conv_clk_busy_o
);


localparam IN_SM_SIZE = 2;
localparam IN_IDLE_W  = 2'b00;
localparam IN_IDLE_R  = 2'b01;
localparam IN_WRITE   = 2'b10;
localparam IN_READ    = 2'b11;

localparam RSP_SM_SIZE = 3;
localparam RSP_IDLE    = 3'b000;
localparam RSP_WHOLD   = 3'b001;
localparam RSP_WBLOCK  = 3'b010;
localparam RSP_RBLOCK  = 3'b011;
localparam RSP_RHOLD   = 3'b100;

localparam MAX_ID_WIDTH = FC_AXIID_WIDTH;

localparam PROT_REG_SLICE = 0;


reg [IN_SM_SIZE-1:0] in_sm_r;
reg [IN_SM_SIZE-1:0] in_sm_nxt;

reg [RSP_SM_SIZE-1:0] rsp_sm_r;
reg [RSP_SM_SIZE-1:0] rsp_sm_nxt;

reg wr_rsp_valid_nxt;
reg rd_rsp_valid_nxt;

wire prot_block;
wire prot_block_idle;

wire axi_rsp_valid;

wire req_idle;

wire ax_wr_valid;

wire write_input_accepted;

wire [FW_ID_WIDTH-1:0]     cfg_fw_id_nxt;
wire [REG_ADDR_WIDTH-1:0]  cfg_addr_nxt;
wire [REG_ENUM_WIDTH-1:0]  cfg_addr_enum_nxt;
wire [REG_DATA_WIDTH-1:0]  cfg_data_nxt;
wire [MAX_ID_WIDTH-1:0]    cfg_id_nxt;
wire [1:0]                 cfg_axprot_nxt;
wire                       cfg_rw_nxt;
wire [FW_ID_WIDTH-1:0]     cfg_fw_id_sel;
wire [FC_MST_ID_WIDTH-1:0] cfg_mst_id_nxt;

wire [MAX_ID_WIDTH-1:0] cfg_id_rsp;

genvar i;

reg wr_wait;

wire nxt_valid;

integer num_fc;
reg [LOG2_FW_NUM_FC-1:0] cfg_fc_id_nxt;

wire rsp_block;


assign prot_block = prot_conv_pwr_block_i || prot_conv_dn_prot_block_i ||
                    prot_conv_shdw_block_i;

assign prot_block_idle = prot_block || prot_conv_hndshk_pend_i;

assign ax_wr_valid = prot_conv_awvalid_i && prot_conv_wvalid_i;

always @ (posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    in_sm_r <= IN_IDLE_W;
  end
  else begin
    in_sm_r <= in_sm_nxt;
  end
end

always @* begin
  case (in_sm_r)
    IN_IDLE_W: begin
      case ({prot_conv_arvalid_i, ax_wr_valid, axi_rsp_valid, prot_block_idle})
        4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0101, 4'b0110, 4'b0111, 4'b1001,
        4'b1010, 4'b1110, 4'b1011, 4'b1101, 4'b1111: begin
          in_sm_nxt = IN_IDLE_W;
        end
        4'b0100, 4'b1100: begin
          in_sm_nxt = IN_WRITE;
        end
        4'b1000: begin
          in_sm_nxt = IN_READ;
        end
        default: begin
          in_sm_nxt = {IN_SM_SIZE{1'bx}};
        end
      endcase
    end
    IN_IDLE_R: begin
      case ({prot_conv_arvalid_i, ax_wr_valid, axi_rsp_valid, prot_block_idle})
        4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0101, 4'b0110, 4'b0111, 4'b1001,
        4'b1010, 4'b1110, 4'b1011, 4'b1101, 4'b1111: begin
          in_sm_nxt = IN_IDLE_R;
        end
        4'b1000, 4'b1100: begin
          in_sm_nxt = IN_READ;
        end
        4'b0100: begin
          in_sm_nxt = IN_WRITE;
        end
        default: begin
          in_sm_nxt = {IN_SM_SIZE{1'bx}};
        end
      endcase
    end
    IN_WRITE: begin
      case ({axi_rsp_valid, prot_block})
        2'b00, 2'b01, 2'b11: begin
          in_sm_nxt = IN_WRITE;
        end
        2'b10: begin
          in_sm_nxt = IN_IDLE_R;
        end
        default: begin
          in_sm_nxt = {IN_SM_SIZE{1'bx}};
        end
      endcase
    end
    IN_READ: begin
      case ({axi_rsp_valid, prot_block})
        2'b00, 2'b01, 2'b11: begin
          in_sm_nxt = IN_READ;
        end
        2'b10: begin
          in_sm_nxt = IN_IDLE_W;
        end
        default: begin
          in_sm_nxt = {IN_SM_SIZE{1'bx}};
        end
      endcase
    end
    default: begin
      in_sm_nxt = {IN_SM_SIZE{1'bx}};
    end
  endcase
end

assign prot_conv_wready_o  = (in_sm_r == IN_WRITE) &&
  ((in_sm_nxt == IN_IDLE_W) || (in_sm_nxt == IN_IDLE_R));
assign prot_conv_awready_o = (in_sm_r == IN_WRITE) &&
  ((in_sm_nxt == IN_IDLE_W) || (in_sm_nxt == IN_IDLE_R));

assign prot_conv_arready_o = (in_sm_r == IN_READ) &&
  ((in_sm_nxt == IN_IDLE_W) || (in_sm_nxt == IN_IDLE_R));

assign write_input_accepted = (in_sm_nxt == IN_WRITE) || (in_sm_r == IN_WRITE);

assign req_idle = (in_sm_r != IN_READ) || (in_sm_r != IN_WRITE);

assign prot_conv_cfg_active_o = (in_sm_r == IN_READ) ||
  (in_sm_r == IN_WRITE) || nxt_valid;

assign prot_conv_cfg_pend_o = prot_conv_arvalid_i || ax_wr_valid;


assign nxt_valid = (((in_sm_r == IN_IDLE_R) || (in_sm_r == IN_IDLE_W))) &&
                   ((in_sm_nxt == IN_WRITE) || (in_sm_nxt == IN_READ));

assign cfg_fw_id_nxt     = write_input_accepted ? prot_conv_w_fw_id_i : prot_conv_r_fw_id_i;
assign cfg_mst_id_nxt    = write_input_accepted ? prot_conv_w_mst_id_i : prot_conv_r_mst_id_i;
assign cfg_addr_nxt      = write_input_accepted ? prot_conv_awaddr_i : prot_conv_araddr_i;
assign cfg_addr_enum_nxt = write_input_accepted ? prot_conv_enum_w_addr_i : prot_conv_enum_r_addr_i;
assign cfg_data_nxt      = prot_conv_wdata_i;
assign cfg_id_nxt        = write_input_accepted ? prot_conv_awid_i : prot_conv_arid_i;
assign cfg_axprot_nxt    = write_input_accepted ? prot_conv_awprot_i : prot_conv_arprot_i;
assign cfg_rw_nxt        = write_input_accepted ? 1'b1 : 1'b0;

generate
  if (PROT_REG_SLICE == 1) begin : SLICE_ENABLED

    reg  nxt_valid_r;

    always @ (posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        nxt_valid_r <= 1'b0;
      end
      else begin
        nxt_valid_r <= nxt_valid;
      end
    end

    reg  [FW_ID_WIDTH-1:0]     cfg_fw_id_r;
    reg  [LOG2_FW_NUM_FC-1:0]  cfg_fc_id_r;
    reg  [FC_MST_ID_WIDTH-1:0] cfg_mst_id_r;
    reg  [REG_ADDR_WIDTH-1:0]  cfg_addr_r;
    reg  [REG_ENUM_WIDTH-1:0]  cfg_addr_enum_r;
    reg  [REG_DATA_WIDTH-1:0]  cfg_data_r;
    reg  [MAX_ID_WIDTH-1:0]    cfg_id_r;
    reg  [1:0]                 cfg_axprot_r;
    reg                        cfg_rw_r;

    always @ (posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        cfg_fw_id_r     <= {FW_ID_WIDTH{1'b0}};
        cfg_fc_id_r     <= {LOG2_FW_NUM_FC{1'b0}};
        cfg_mst_id_r    <= {FC_MST_ID_WIDTH{1'b0}};
        cfg_addr_r      <= {REG_ADDR_WIDTH{1'b0}};
        cfg_addr_enum_r <= {REG_ENUM_WIDTH{1'b0}};
        cfg_data_r      <= {REG_DATA_WIDTH{1'b0}};
        cfg_id_r        <= {MAX_ID_WIDTH{1'b0}};
        cfg_axprot_r    <= {2{1'b0}};
        cfg_rw_r        <= 1'b0;
      end
      else begin
        if (nxt_valid) begin
          cfg_fw_id_r     <= cfg_fw_id_nxt;
          cfg_fc_id_r     <= cfg_fc_id_nxt;
          cfg_mst_id_r    <= cfg_mst_id_nxt;
          cfg_addr_r      <= cfg_addr_nxt;
          cfg_addr_enum_r <= cfg_addr_enum_nxt;
          cfg_data_r      <= cfg_data_nxt;
          cfg_id_r        <= cfg_id_nxt;
          cfg_axprot_r    <= cfg_axprot_nxt;
          cfg_rw_r        <= cfg_rw_nxt;
        end
      end
    end
    assign prot_conv_reg_addr_o      = cfg_addr_r;
    assign prot_conv_reg_enum_addr_o = cfg_addr_enum_r;
    assign prot_conv_rw_o            = cfg_rw_r;
    assign prot_conv_fw_id_o         = cfg_fw_id_r;
    assign cfg_fw_id_sel             = cfg_fw_id_r;
    assign prot_conv_fc_id_o         = cfg_fc_id_r;
    assign prot_conv_wr_data_o       = cfg_data_r;
    assign prot_conv_acc_valid_o     = nxt_valid_r;
    assign cfg_id_rsp                = cfg_id_r;
    assign prot_conv_axprot_o        = cfg_axprot_r;
    assign prot_conv_rd_mst_id_o     = cfg_mst_id_r;
    assign prot_conv_mst_id_o        = cfg_mst_id_r;
  end
  else begin: SLICE_BYPASSED
    assign prot_conv_reg_addr_o      = cfg_addr_nxt;
    assign prot_conv_reg_enum_addr_o = cfg_addr_enum_nxt;
    assign prot_conv_rw_o            = cfg_rw_nxt;
    assign prot_conv_fw_id_o         = cfg_fw_id_nxt;
    assign cfg_fw_id_sel             = cfg_fw_id_nxt;
    assign prot_conv_fc_id_o         = cfg_fc_id_nxt;
    assign prot_conv_wr_data_o       = cfg_data_nxt;
    assign cfg_id_rsp                = cfg_id_nxt;
    assign prot_conv_axprot_o        = cfg_axprot_nxt;
    assign prot_conv_acc_valid_o     = nxt_valid;
    assign prot_conv_rd_mst_id_o     = cfg_mst_id_nxt;
    assign prot_conv_mst_id_o        = cfg_mst_id_nxt;
  end
endgenerate


always @* begin
  cfg_fc_id_nxt = {LOG2_FW_NUM_FC{1'b0}};
  for (num_fc=0; num_fc<FW_NUM_FC; num_fc=num_fc+1) begin
    if ((num_fc+1) == cfg_fw_id_nxt) begin
      cfg_fc_id_nxt = num_fc[LOG2_FW_NUM_FC-1:0];
    end
  end
end


assign rsp_block = prot_block ||
  ((in_sm_r != IN_IDLE_R) && (in_sm_r != IN_IDLE_W));

always @ (posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    rsp_sm_r <= RSP_IDLE;
  end
  else begin
    rsp_sm_r <= rsp_sm_nxt;
  end
end

always @* begin
  case (rsp_sm_r)
    RSP_IDLE: begin
      case ({prot_conv_wr_valid_i, prot_conv_rd_valid_i})
        2'b00: begin
          rsp_sm_nxt = RSP_IDLE;
        end
        2'b10: begin
          rsp_sm_nxt = RSP_WBLOCK;
        end
        2'b01: begin
          rsp_sm_nxt = RSP_RBLOCK;
        end
        default: begin
          rsp_sm_nxt = {RSP_SM_SIZE{1'bx}};
        end
      endcase
    end
    RSP_WBLOCK: begin
      case (rsp_block)
        1'b1: begin
          rsp_sm_nxt = RSP_WBLOCK;
        end
        1'b0: begin
          rsp_sm_nxt = RSP_WHOLD;
        end
        default: begin
          rsp_sm_nxt = {RSP_SM_SIZE{1'bx}};
        end
      endcase
    end
    RSP_RBLOCK: begin
      case (rsp_block)
        1'b1: begin
          rsp_sm_nxt = RSP_RBLOCK;
        end
        1'b0: begin
          rsp_sm_nxt = RSP_RHOLD;
        end
        default: begin
          rsp_sm_nxt = {RSP_SM_SIZE{1'bx}};
        end
      endcase
    end
    RSP_WHOLD: begin
      case ({prot_conv_bready_i, req_idle})
        2'b00, 2'b01, 2'b10: begin
          rsp_sm_nxt = RSP_WHOLD;
        end
        2'b11: begin
          rsp_sm_nxt = RSP_IDLE;
        end
        default: begin
          rsp_sm_nxt = {RSP_SM_SIZE{1'bx}};
        end
      endcase
    end
    RSP_RHOLD: begin
      case ({prot_conv_rready_i, req_idle})
        2'b00, 2'b01, 2'b10: begin
          rsp_sm_nxt = RSP_RHOLD;
        end
        2'b11: begin
          rsp_sm_nxt = RSP_IDLE;
        end
        default: begin
          rsp_sm_nxt = {RSP_SM_SIZE{1'bx}};
        end
      endcase
    end
    default: begin
      rsp_sm_nxt = {RSP_SM_SIZE{1'bx}};
    end
  endcase
end

assign prot_conv_bvalid_o = rsp_sm_r == RSP_WHOLD;
assign prot_conv_rvalid_o = rsp_sm_r == RSP_RHOLD;

assign axi_rsp_valid = (rsp_sm_r == RSP_WHOLD) || (rsp_sm_r == RSP_RHOLD) ||
                       (rsp_sm_r == RSP_WBLOCK) || (rsp_sm_r == RSP_RBLOCK);

assign prot_conv_bid_o = prot_conv_wr_bid_i;
assign prot_conv_rid_o = prot_conv_rd_rid_i;

assign prot_conv_wr_bid_o = cfg_id_rsp;
assign prot_conv_rd_rid_o = cfg_id_rsp;

assign prot_conv_bresp_o = prot_conv_wr_rsp_i;
assign prot_conv_rresp_o = prot_conv_rd_rsp_i;

assign prot_conv_buser_o = prot_conv_wr_rsp_i[1];
assign prot_conv_ruser_o = prot_conv_rd_rsp_i[1];

assign prot_conv_rdata_o = prot_conv_rd_data_i;
assign prot_conv_rlast_o = 1'b1;

assign prot_conv_r_mst_id_o = prot_conv_rd_mst_id_i;


assign prot_conv_reg_tamp_o   = prot_conv_wr_tamp_i || prot_conv_rd_tamp_i;
assign prot_conv_reg_tamp_w_o = prot_conv_wr_tamp_i;


assign prot_conv_trkr_o = (in_sm_r != IN_IDLE_R) && (in_sm_r != IN_IDLE_W);


assign prot_conv_clk_busy_o = ((in_sm_r != IN_IDLE_R) && (in_sm_r != IN_IDLE_W)) ||
                              (rsp_sm_r != RSP_IDLE) ||
                              prot_conv_wr_valid_i ||
                              prot_conv_rd_valid_i ||
                              prot_conv_arvalid_i ||
                              prot_conv_awvalid_i ||
                              prot_conv_wvalid_i;

endmodule

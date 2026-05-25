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

module firewall_f0_ctlr_access_router #(
    parameter REG_ADDR_WIDTH   = 10,
    parameter REG_DATA_WIDTH   = 32,
    parameter FW_NUM_FC        = 32,
    parameter LOG2_FW_NUM_FC   = 5,
    parameter READ_DATA_SIZE   = 7,
    parameter CHECK_TYPE_WIDTH = 3,
    parameter LOG2_SRAM_WIDTH  = 5,
    parameter FW_SRE_LVL       = 1,
    parameter LOG2_SRAM_SIZE   = 12,
    parameter FW_ID_WIDTH      = 6,
    parameter FW_LDE_LVL       = 1
) (
    input  wire [REG_ADDR_WIDTH-1:0]   acc_rtr_reg_addr_i,
    input  wire                        acc_rtr_rw_i,
    input  wire [FW_ID_WIDTH-1:0]      acc_rtr_fw_id_i,
    input  wire [LOG2_FW_NUM_FC-1:0]   acc_rtr_fc_id_i,
    input  wire [REG_DATA_WIDTH-1:0]   acc_rtr_reg_rd_data_i,
    input  wire [REG_DATA_WIDTH-1:0]   acc_rtr_wr_data_i,
    input  wire                        acc_rtr_hit_i,
    input  wire                        acc_rtr_hit_chk_need_i,
    input  wire [CHECK_TYPE_WIDTH-1:0] acc_rtr_hit_chk_type_i,
    input  wire [LOG2_SRAM_SIZE-1:0]   acc_rtr_sram_row_i,
    input  wire [LOG2_SRAM_WIDTH-1:0]  acc_rtr_sram_col_i,
    input  wire [READ_DATA_SIZE-1:0]   acc_rtr_reg_size_i,
    input  wire                        acc_rtr_wr_rsp_pend_i,
    input  wire                        acc_rtr_acc_valid_i,
    input  wire                        acc_rtr_fixed_i,
    input  wire                        acc_rtr_read_only_i,
    input  wire                        acc_rtr_tamper_i,
    input  wire                        acc_rtr_wr_allow_fctlr_i,
    input  wire                        acc_rtr_ctlr_n_comp_i,

    output wire                        acc_rtr_shdw_hit_chk_need_o,
    output wire [CHECK_TYPE_WIDTH-1:0] acc_rtr_shdw_hit_chk_type_o,
    output wire [LOG2_SRAM_SIZE-1:0]   acc_rtr_shdw_sram_row_o,
    output wire [LOG2_SRAM_WIDTH-1:0]  acc_rtr_shdw_sram_col_o,
    output wire [READ_DATA_SIZE-1:0]   acc_rtr_shdw_reg_size_o,
    output wire                        acc_rtr_shdw_wr_rsp_pend_o,
    output wire                        acc_rtr_shdw_hit_valid_o,
    output wire                        acc_rtr_shdw_fixed_o,

    output wire                        acc_rtr_msg_valid_o,
    output wire [READ_DATA_SIZE-1:0]   acc_rtr_msg_reg_size_o,

    output wire                        acc_rtr_reg_ctlr_valid_o,

    output wire                        acc_rtr_rd_hndlr_rsp_o,
    output wire                        acc_rtr_rd_hndlr_tamp_o,
    output wire [REG_DATA_WIDTH-1:0]   acc_rtr_rd_hndlr_data_o,
    output wire                        acc_rtr_rd_hndlr_valid_o,

    output wire                        acc_rtr_wr_hndlr_rsp_o,
    output wire                        acc_rtr_wr_hndlr_tamp_o,
    output wire                        acc_rtr_wr_hndlr_valid_o,

    output wire [REG_ADDR_WIDTH-1:0]   acc_rtr_reg_addr_o,
    output wire                        acc_rtr_rw_o,
    output wire [FW_ID_WIDTH-1:0]      acc_rtr_fw_id_o,
    output wire [LOG2_FW_NUM_FC-1:0]   acc_rtr_fc_id_o,
    output wire [REG_DATA_WIDTH-1:0]   acc_rtr_wr_data_o,

    output wire                        acc_rtr_clk_busy_o,

    input  wire [FW_NUM_FC-1:0]        acc_rtr_comp_pwr_st_i
);


reg acc_rtr_msg_valid_o_int;
reg acc_rtr_rd_hndlr_valid_o_int;
reg acc_rtr_reg_ctlr_valid_o_int;
reg acc_rtr_wr_hndlr_valid_o_int;
reg acc_rtr_rd_hndlr_rsp_o_int;
reg acc_rtr_wr_hndlr_rsp_o_int;
reg acc_rtr_wr_hndlr_tamp_o_int;
reg acc_rtr_rd_hndlr_tamp_o_int;

wire comp_discon;

wire [4:0] rule;

wire shdw_hit;


assign acc_rtr_reg_addr_o = acc_rtr_reg_addr_i;
assign acc_rtr_rw_o       = acc_rtr_rw_i;
assign acc_rtr_fw_id_o    = acc_rtr_fw_id_i;
assign acc_rtr_fc_id_o    = acc_rtr_fc_id_i;
assign acc_rtr_wr_data_o  = acc_rtr_wr_data_i;

assign acc_rtr_rd_hndlr_data_o = acc_rtr_reg_rd_data_i;

assign acc_rtr_msg_reg_size_o = acc_rtr_reg_size_i;

assign comp_discon = acc_rtr_ctlr_n_comp_i ? 1'b0 :
                     !acc_rtr_comp_pwr_st_i[acc_rtr_fc_id_i];

assign shdw_hit = acc_rtr_hit_i &&
  !acc_rtr_ctlr_n_comp_i && !acc_rtr_tamper_i &&
  !(!acc_rtr_rw_i && acc_rtr_fixed_i);

assign rule[0] = acc_rtr_acc_valid_i && shdw_hit;

assign rule[1] = acc_rtr_acc_valid_i && !shdw_hit &&
                 !comp_discon &&
                 !acc_rtr_ctlr_n_comp_i;

assign rule[2] = acc_rtr_acc_valid_i && !shdw_hit &&
                 comp_discon &&
                 !acc_rtr_ctlr_n_comp_i;

assign rule[3] = acc_rtr_acc_valid_i && !shdw_hit &&
                 acc_rtr_ctlr_n_comp_i;

assign rule[4] = !acc_rtr_acc_valid_i;

always @(*)
begin: APPLY_RULES
  case (rule)
    5'b00001: begin
      acc_rtr_msg_valid_o_int = (!acc_rtr_hit_chk_need_i ||
        acc_rtr_wr_rsp_pend_i) && !comp_discon && !acc_rtr_ctlr_n_comp_i &&
        acc_rtr_rw_i;
      acc_rtr_rd_hndlr_valid_o_int = 1'b0;
      acc_rtr_reg_ctlr_valid_o_int = 1'b0;
      acc_rtr_wr_hndlr_valid_o_int = 1'b0;
      acc_rtr_wr_hndlr_rsp_o_int   = 1'b0;
      acc_rtr_rd_hndlr_rsp_o_int   = 1'b0;
      acc_rtr_wr_hndlr_tamp_o_int  = 1'b0;
      acc_rtr_rd_hndlr_tamp_o_int  = 1'b0;

    end
    5'b00010: begin
      acc_rtr_msg_valid_o_int = (!acc_rtr_fixed_i ||
        (acc_rtr_fixed_i && acc_rtr_rw_i && FW_SRE_LVL == 0 &&
          acc_rtr_hit_chk_need_i)) &&
        !acc_rtr_tamper_i && !(acc_rtr_rw_i && acc_rtr_read_only_i);
      acc_rtr_wr_hndlr_valid_o_int = acc_rtr_rw_i &&
        (acc_rtr_fixed_i && !(acc_rtr_rw_i && FW_SRE_LVL == 0 &&
        acc_rtr_hit_chk_need_i) ||
        acc_rtr_tamper_i || acc_rtr_read_only_i);
      acc_rtr_wr_hndlr_rsp_o_int = acc_rtr_rw_i && acc_rtr_tamper_i;
      acc_rtr_rd_hndlr_valid_o_int = !acc_rtr_rw_i && acc_rtr_fixed_i;
      acc_rtr_reg_ctlr_valid_o_int = 1'b0;
      acc_rtr_rd_hndlr_rsp_o_int   = 1'b0;
      acc_rtr_wr_hndlr_tamp_o_int  = acc_rtr_tamper_i;
      acc_rtr_rd_hndlr_tamp_o_int  = 1'b0;

    end
    5'b00100: begin
      acc_rtr_wr_hndlr_valid_o_int = acc_rtr_rw_i;
      acc_rtr_rd_hndlr_valid_o_int = !acc_rtr_rw_i;
      acc_rtr_wr_hndlr_rsp_o_int   = (FW_SRE_LVL == 0) ?
        1'b1 : acc_rtr_rw_i && acc_rtr_tamper_i;
      acc_rtr_rd_hndlr_rsp_o_int   = (FW_SRE_LVL == 0) ? 1'b1 : 1'b0;
      acc_rtr_msg_valid_o_int      = 1'b0;
      acc_rtr_reg_ctlr_valid_o_int = 1'b0;
      acc_rtr_wr_hndlr_tamp_o_int  = acc_rtr_tamper_i;
      acc_rtr_rd_hndlr_tamp_o_int  = 1'b0;

    end
    5'b01000: begin
      acc_rtr_reg_ctlr_valid_o_int = acc_rtr_rw_i &&
        !acc_rtr_tamper_i && acc_rtr_wr_allow_fctlr_i && !acc_rtr_read_only_i;
      acc_rtr_rd_hndlr_valid_o_int = !acc_rtr_rw_i;
      acc_rtr_msg_valid_o_int      = 1'b0;
      acc_rtr_wr_hndlr_valid_o_int = acc_rtr_rw_i &&
        (acc_rtr_tamper_i || !acc_rtr_wr_allow_fctlr_i || acc_rtr_read_only_i);
      acc_rtr_wr_hndlr_rsp_o_int   = acc_rtr_rw_i &&
        (acc_rtr_tamper_i || !acc_rtr_wr_allow_fctlr_i);
      acc_rtr_rd_hndlr_rsp_o_int   = acc_rtr_tamper_i;
      acc_rtr_wr_hndlr_tamp_o_int  = acc_rtr_tamper_i;
      acc_rtr_rd_hndlr_tamp_o_int  = acc_rtr_tamper_i;

    end
    5'b10000: begin

      acc_rtr_msg_valid_o_int      = 1'b0;
      acc_rtr_rd_hndlr_valid_o_int = 1'b0;
      acc_rtr_reg_ctlr_valid_o_int = 1'b0;
      acc_rtr_wr_hndlr_valid_o_int = 1'b0;
      acc_rtr_wr_hndlr_rsp_o_int   = 1'b0;
      acc_rtr_rd_hndlr_rsp_o_int   = 1'b0;
      acc_rtr_wr_hndlr_tamp_o_int  = 1'b0;
      acc_rtr_rd_hndlr_tamp_o_int  = 1'b0;

    end
    default: begin

      acc_rtr_msg_valid_o_int      = 1'bx;
      acc_rtr_rd_hndlr_valid_o_int = 1'bx;
      acc_rtr_reg_ctlr_valid_o_int = 1'bx;
      acc_rtr_wr_hndlr_valid_o_int = 1'bx;
      acc_rtr_wr_hndlr_rsp_o_int   = 1'bx;
      acc_rtr_rd_hndlr_rsp_o_int   = 1'bx;
      acc_rtr_wr_hndlr_tamp_o_int  = 1'bx;
      acc_rtr_rd_hndlr_tamp_o_int  = 1'bx;

    end
  endcase
end


assign acc_rtr_msg_valid_o      = acc_rtr_msg_valid_o_int;
assign acc_rtr_rd_hndlr_valid_o = acc_rtr_rd_hndlr_valid_o_int;
assign acc_rtr_reg_ctlr_valid_o = acc_rtr_reg_ctlr_valid_o_int;
assign acc_rtr_wr_hndlr_valid_o = acc_rtr_wr_hndlr_valid_o_int;
assign acc_rtr_wr_hndlr_rsp_o   = acc_rtr_wr_hndlr_rsp_o_int;
assign acc_rtr_wr_hndlr_tamp_o  = acc_rtr_wr_hndlr_tamp_o_int;
assign acc_rtr_rd_hndlr_rsp_o   = acc_rtr_rd_hndlr_rsp_o_int;
assign acc_rtr_rd_hndlr_tamp_o   = acc_rtr_rd_hndlr_tamp_o_int;

assign acc_rtr_shdw_hit_chk_need_o = acc_rtr_hit_chk_need_i;
assign acc_rtr_shdw_hit_chk_type_o = acc_rtr_hit_chk_type_i;
assign acc_rtr_shdw_sram_row_o     = acc_rtr_sram_row_i;
assign acc_rtr_shdw_sram_col_o     = acc_rtr_sram_col_i;
assign acc_rtr_shdw_reg_size_o     = acc_rtr_reg_size_i;
assign acc_rtr_shdw_wr_rsp_pend_o  = acc_rtr_wr_rsp_pend_i;
assign acc_rtr_shdw_hit_valid_o    = shdw_hit;
assign acc_rtr_shdw_fixed_o        = acc_rtr_fixed_i;

assign acc_rtr_clk_busy_o = acc_rtr_msg_valid_o      ||
                            acc_rtr_rd_hndlr_valid_o ||
                            acc_rtr_reg_ctlr_valid_o ||
                            acc_rtr_wr_hndlr_valid_o;

endmodule

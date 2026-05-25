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

module firewall_f0_ctlr_shdw_ctlr #(
    parameter REG_ADDR_WIDTH      = 10,
    parameter REG_DATA_WIDTH      = 32,
    parameter SRAM_WIDTH          = 32,
    parameter LOG2_SRAM_WIDTH     = 5,
    parameter READ_DATA_SIZE      = 6,
    parameter FW_NUM_FC           = 3,
    parameter LOG2_FW_NUM_FC      = 2,
    parameter LOG2_SRAM_SIZE      = 12,
    parameter FC_PE_LVL           = 1,
    parameter FW_LDE_LVL          = 1,
    parameter FC_MXRS             = 1,
    parameter FC_TE_LVL           = 1,
    parameter FC_RSE_LVL          = 1,
    parameter FC_MA_SPT           = 1,
    parameter FC_INST_SPT         = 1,
    parameter FC_PRIV_SPT         = 1,
    parameter FC_SH_SPT           = 1,
    parameter FC_SEC_SPT          = 1,
    parameter FC_NUM_MPE          = 1,
    parameter FC_SINGLE_MST       = 1,
    parameter FC_ME_LVL           = 1,
    parameter FW_SRE_LVL          = 1,
    parameter FC_ID               = 0,
    parameter RGN_TCFG2_WIDTH     = 1,
    parameter FC_NUM_RGN          = 1,
    parameter RGN_CTRL0_WIDTH     = 1,
    parameter RGN_CTRL1_WIDTH     = 1,
    parameter RGN_LCTRL_WIDTH     = 1,
    parameter RGN_SIZE_WIDTH      = 1,
    parameter RGN_MPL0_WIDTH      = 1,
    parameter RGN_MPL1_WIDTH      = 1,
    parameter RGN_MPL2_WIDTH      = 1,
    parameter RGN_MPL3_WIDTH      = 1,
    parameter RGN_TCFG0_WIDTH     = 1,
    parameter RGN_TCFG1_WIDTH     = 1,
    parameter RGN_CFG0_WIDTH      = 1,
    parameter RGN_CFG1_WIDTH      = 1,
    parameter PE_CTRL_WIDTH       = 1,
    parameter ME_CTRL_WIDTH       = 1,
    parameter RWE_CTRL_WIDTH      = 1,
    parameter CHECK_TYPE_WIDTH    = 3,
    parameter FC_SEC_SPT_EXT      = 65535,
    parameter FC_MA_SPT_EXT       = 65535,
    parameter FC_SH_SPT_EXT       = 0,
    parameter FC_INST_SPT_EXT     = 65535,
    parameter FC_PRIV_SPT_EXT     = 65535,
    parameter FC_NUM_RGN_EXT      = 545394752,
    parameter FC_MNRS_EXT         = 6340743,
    parameter FC_MXRS_EXT         = 61296285,
    parameter FC_NUM_MPE_EXT      = 100748,
    parameter FC_ME_LVL_EXT       = 34,
    parameter FC_RSE_LVL_EXT      = 34,
    parameter FC_PE_LVL_EXT       = 38,
    parameter FC_TE_LVL_EXT       = 38,
    parameter FC_SINGLE_MST_EXT   = 2,
    parameter FW_ID_WIDTH         = 2,
    parameter CHECK_RWE_DATA      = 3'b000,
    parameter CHECK_RWE_MPL       = 3'b001,
    parameter CHECK_RWE_EN        = 3'b010,
    parameter CHECK_RWE_LOCK      = 3'b011,
    parameter CHECK_FW_LOCK       = 3'b100,
    parameter CHECK_LDE           = 3'b101,
    parameter FW_MAX_MST_ID_WIDTH = 8

) (
    input  wire                                  clk,
    input  wire                                  reset_n,

    input  wire                                  shdw_ctlr_rw_i,
    input  wire [FW_ID_WIDTH-1:0]                shdw_ctlr_fw_id_i,
    input  wire [LOG2_FW_NUM_FC-1:0]             shdw_ctlr_fc_id_i,
    input  wire [REG_DATA_WIDTH-1:0]             shdw_ctlr_wr_data_i,
    input  wire                                  shdw_ctlr_chk_need_i,
    input  wire [CHECK_TYPE_WIDTH-1:0]           shdw_ctlr_chk_type_i,
    input  wire [LOG2_SRAM_SIZE-1:0]             shdw_ctlr_sram_row_i,
    input  wire [LOG2_SRAM_WIDTH-1:0]            shdw_ctlr_sram_col_i,
    input  wire [READ_DATA_SIZE-1:0]             shdw_ctlr_reg_size_i,
    input  wire                                  shdw_ctlr_wr_rsp_pend_i,
    input  wire                                  shdw_ctlr_acc_valid_i,
    input  wire                                  shdw_ctlr_fixed_i,

    input  wire                                  shdw_ctlr_restore_req_i,
    input  wire [LOG2_FW_NUM_FC-1:0]             shdw_ctlr_restore_req_id_i,
    input  wire                                  shdw_ctlr_restore_req_valid_i,
    output wire                                  shdw_ctlr_restore_done_o,
    output wire [LOG2_FW_NUM_FC-1:0]             shdw_ctlr_restore_fw_id_o,
    output wire [FW_NUM_FC-1:0]                  shdw_ctlr_wr_aft_dsc_o,
    output wire [FW_NUM_FC-1:0]                  shdw_ctlr_wr_aft_rst_o,
    input  wire                                  shdw_ctlr_con_valid_i,
    input  wire [LOG2_FW_NUM_FC-1:0]             shdw_ctlr_con_fw_id_i,

    output wire [(RWE_CTRL_WIDTH*FW_NUM_FC)-1:0] shdw_ctlr_rgn_o,
    input  wire [RWE_CTRL_WIDTH-1:0]             shdw_ctlr_rgn_i,
    input  wire [FW_NUM_FC-1:0]                  shdw_ctlr_rgn_en_i,
    input  wire                                  shdw_ctlr_rd_rgn_st_i,
    input  wire [LOG2_SRAM_SIZE-1:0]             shdw_ctlr_rgn_lctrl_op1_i,
    input  wire [LOG2_SRAM_SIZE-1:0]             shdw_ctlr_rgn_lctrl_op2_i,
    input  wire [LOG2_SRAM_WIDTH-1:0]            shdw_ctlr_rgn_lctrl_col_i,
    input  wire [LOG2_SRAM_SIZE-1:0]             shdw_ctlr_rgn_ctrl0_op1_i,
    input  wire [LOG2_SRAM_SIZE-1:0]             shdw_ctlr_rgn_ctrl0_op2_i,
    input  wire [LOG2_SRAM_WIDTH-1:0]            shdw_ctlr_rgn_ctrl0_col_i,
    input  wire [LOG2_SRAM_SIZE-1:0]             shdw_ctlr_rgn_ctrl1_op1_i,
    input  wire [LOG2_SRAM_SIZE-1:0]             shdw_ctlr_rgn_ctrl1_op2_i,
    input  wire [LOG2_SRAM_WIDTH-1:0]            shdw_ctlr_rgn_ctrl1_col_i,
    input  wire [3:0]                            shdw_ctlr_mpe_i,

    output wire [LOG2_FW_NUM_FC-1:0]             shdw_ctlr_fw_id_o,
    output wire [SRAM_WIDTH-1:0]                 shdw_ctlr_restore_data_o,
    output wire                                  shdw_ctlr_first_restore_data_o,
    output wire                                  shdw_ctlr_restore_valid_o,
    output wire                                  shdw_ctlr_cfg_valid_o,

    output wire                                  shdw_ctlr_wr_rsp_o,
    output wire                                  shdw_ctlr_wr_tamp_o,
    output wire                                  shdw_ctlr_wr_valid_o,

    output wire [REG_DATA_WIDTH-1:0]             shdw_ctlr_rd_data_o,
    output wire                                  shdw_ctlr_rd_valid_o,

    input  wire                                  shdw_ctlr_wr_rsp_i,
    input  wire                                  shdw_ctlr_wr_valid_i,

    output wire                                  shdw_ctlr_prot_block_o,

    input  wire [FW_NUM_FC-1:0]                  shdw_ctlr_cmp_pwr_st_i,
    input  wire [8*FW_NUM_FC-1:0]                prot_size_i,
    output wire                                  sram_init_done_o,

    input  wire                                  shdw_ctlr_up_pkt_sent_i,
    output wire                                  shdw_ctlr_us_last_pkt_o,

    output wire                                  shdw_ctlr_lpi_ram_req_o,
    input  wire                                  shdw_ctlr_lpi_ram_ack_i,
    output wire                                  shdw_ctlr_clk_busy_o,
    input  wire                                  shdw_ctlr_lpi_ram_init_i,
    input  wire                                  shdw_ctlr_lpi_default_state_i,

    output wire [LOG2_SRAM_SIZE-1:0]             shdw_ctlr_add_op1_o,
    output wire [LOG2_SRAM_SIZE-1:0]             shdw_ctlr_add_op2_o,
    output wire                                  shdw_ctlr_add_en_o,
    input  wire [LOG2_SRAM_SIZE-1:0]             shdw_ctlr_add_rslt_i,

    output wire [LOG2_SRAM_SIZE-1:0]             shdw_ctlr_sram_addr_o,
    output wire                                  shdw_ctlr_sram_cenn_o,
    output wire                                  shdw_ctlr_sram_wenn_o,
    output wire [SRAM_WIDTH-1:0]                 shdw_ctlr_sram_data_o,
    input  wire [SRAM_WIDTH-1:0]                 shdw_ctlr_sram_data_i
);


`include "firewall_f0_log2.vh"
`include "firewall_f0_ceil_divide.vh"


localparam FIFO_WIDTH      = SRAM_WIDTH;
localparam FIFO_DEPTH      = 2;
localparam LOG2_FIFO_DEPTH = firewall_f0_log2(FIFO_DEPTH);

localparam LOG2_RSTR_DEPTH = firewall_f0_log2(FIFO_DEPTH+1);


localparam SIZE      = 3     ; 
localparam IDLE      = 3'b001; 
localparam SRAM_INIT = 3'b010; 
localparam COMP_RSTR = 3'b100; 

localparam COUNTER_SIZE = LOG2_SRAM_SIZE;

localparam FC_PE_LVL_RSTR     = FC_PE_LVL_EXT;
localparam FC_MXRS_RSTR       = FC_MXRS_EXT;
localparam FC_RSE_LVL_RSTR    = FC_RSE_LVL_EXT;
localparam FC_TE_LVL_RSTR     = FC_TE_LVL_EXT;
localparam FC_NUM_MPE_RSTR    = FC_NUM_MPE_EXT;
localparam FC_SINGLE_MST_RSTR = FC_SINGLE_MST_EXT;
localparam FC_ME_LVL_RSTR     = FC_ME_LVL_EXT;
localparam FC_INST_SPT_RSTR   = FC_INST_SPT_EXT;
localparam FC_MA_SPT_RSTR     = FC_MA_SPT_EXT;
localparam FC_SEC_SPT_RSTR    = FC_SEC_SPT_EXT;
localparam FC_PRIV_SPT_RSTR   = FC_PRIV_SPT_EXT;
localparam FC_SH_SPT_RSTR     = FC_SH_SPT_EXT;
localparam FC_NUM_RGN_RSTR    = FC_NUM_RGN_EXT;
localparam FC_ID_RSTR         = FC_ID;
localparam RGN_MID0_WIDTH     = FW_MAX_MST_ID_WIDTH;
localparam RGN_MID1_WIDTH     = FW_MAX_MST_ID_WIDTH;
localparam RGN_MID2_WIDTH     = FW_MAX_MST_ID_WIDTH;
localparam RGN_MID3_WIDTH     = FW_MAX_MST_ID_WIDTH;

`include "firewall_f0_reg_exists_localparams.vh"
`include "firewall_f0_sram_reg_lut_localparams.vh"

`include "firewall_f0_reset_values.vh"


localparam [6:0] LOCAL_PE_CTRL_RST_VAL     =
  {1'b0, PE_CTRL_BYPASSMSK_RST_VAL, PE_CTRL_FEPWR_RST_VAL,
  PE_CTRL_FLTCFG_RST_VAL, PE_CTRL_RAZ_RST_VAL, PE_CTRL_ERR_RST_VAL};

localparam DEF_PE_CTRL_LN_VL   =
  {{(SRAM_WIDTH-(PE_CTRL_WIDTH*PE_CTRL_PER_ROW)){1'b0}},{PE_CTRL_PER_ROW{LOCAL_PE_CTRL_RST_VAL}}};

localparam SRAM_RW_SM_SIZE = 2;
localparam SRAM_RW_IDLE    = 2'b00;
localparam SRAM_RW_READ    = 2'b01;
localparam SRAM_RW_WRITE   = 2'b10;

localparam RW_SM_SIZE = 2;
localparam RW_IDLE    = 2'b00;
localparam RW_READ    = 2'b01;
localparam RW_WRITE   = 2'b10;
localparam RW_DONE    = 2'b11;

localparam LOCK_SM_SIZE = 2;
localparam LOCK_IDLE    = 2'b00;
localparam LOCK_CHK     = 2'b01;
localparam LOCK_DONE    = 2'b10;

localparam WR_CHK_SM_SIZE  = 3;
localparam WR_CHK_IDLE     = 3'b000;
localparam WR_CHK_RGN      = 3'b001;
localparam WR_CHK_MPE      = 3'b010;
localparam WR_CHK_RGN_DONE = 3'b011;
localparam WR_CHK_MPE_DONE = 3'b100;

localparam RD_ST_SM_SIZE = 2;
localparam RD_ST_IDLE    = 2'b00;
localparam RD_ST_EN      = 2'b01;
localparam RD_ST_MPE     = 2'b10;
localparam RD_ST_DONE    = 2'b11;

localparam RAM_REG_SLICE = 1;


reg                       shdw_ctlr_restore_done_o_int;
reg                       shdw_ctlr_init_o_int;
reg  [SRAM_WIDTH-1:0]     shdw_ctlr_restore_data_o_int;
reg                       shdw_ctlr_first_restore_data_o_int;
reg                       shdw_ctlr_restore_valid_o_int;
reg                       shdw_ctlr_us_last_pkt_o_int;
reg                       shdw_ctlr_clk_busy_o_int;
reg  [LOG2_FW_NUM_FC-1:0] shdw_ctlr_restore_fw_id_o_int;
wire                      shdw_ctlr_prot_block_o_int;

wire                      fifo_rstr_push;
reg [LOG2_RSTR_DEPTH-1:0] fifo_rstr_count_r;
wire                      fifo_rstr_full_nxt;

reg  [LOG2_SRAM_SIZE-1:0]  sram_addr;
reg                        sram_cenn;
reg                        sram_wenn;
reg  [SRAM_WIDTH-1:0]      sram_datai;
wire [SRAM_WIDTH-1:0]      sram_datao;

wire [LOG2_SRAM_SIZE-1:0] shdw_ctlr_sram_addr_sel;
wire                      shdw_ctlr_sram_cenn_sel;
wire                      shdw_ctlr_sram_wenn_sel;
wire [SRAM_WIDTH-1:0]     shdw_ctlr_sram_data_sel;

wire [LOG2_SRAM_SIZE-1:0] shdw_ctlr_sram_addr;
wire                      shdw_ctlr_sram_cenn;
wire                      shdw_ctlr_sram_wenn;
wire [SRAM_WIDTH-1:0]     shdw_ctlr_sram_data;

wire [LOG2_SRAM_SIZE-1:0]  sram_addr_cfg_acc;
wire                       sram_cenn_cfg_acc;
wire                       sram_wenn_cfg_acc;
wire [SRAM_WIDTH-1:0]      sram_data_cfg_acc;

wire                       fifo_pop;
wire                       fifo_push;
wire [FIFO_WIDTH-1:0]      fifo_datain;
wire [FIFO_WIDTH-1:0]      fifo_dataout;
wire                       fifo_empty;
wire                       fifo_full;
wire [LOG2_FIFO_DEPTH-1:0] fifo_writeptr;
wire [LOG2_FIFO_DEPTH-1:0] fifo_readptr;

reg                        fifo_pop_rstr_init;
reg                        fifo_push_rstr_init;
reg                        fifo_push_rstr_hdr;
reg  [FIFO_WIDTH-1:0]      fifo_datain_rstr_init;

wire                       fifo_pop_cfg_acc;
wire                       fifo_push_cfg_acc;
wire [FIFO_WIDTH-1:0]      fifo_datain_cfg_acc;

reg  [SIZE-1:0] state;
reg  [SIZE-1:0] nxt_state;
reg  [SIZE-1:0] last_state;

reg [SRAM_RW_SM_SIZE-1:0] sram_rw_sm_r;
reg [SRAM_RW_SM_SIZE-1:0] sram_rw_sm_nxt;

reg [RW_SM_SIZE-1:0] rw_sm_r;
reg [RW_SM_SIZE-1:0] rw_sm_nxt;

wire [LOCK_SM_SIZE-1:0] lock_sm_r;
wire [LOCK_SM_SIZE-1:0] lock_sm_nxt;

reg [WR_CHK_SM_SIZE-1:0] wr_chk_sm_r;
reg [WR_CHK_SM_SIZE-1:0] wr_chk_sm_nxt;

reg [RD_ST_SM_SIZE-1:0] rd_st_sm_r;
reg [RD_ST_SM_SIZE-1:0] rd_st_sm_nxt;

wire rd_wr_done;

wire lock_sram_read_req;
wire lock_sram_done;
wire lock_fifo_pop;
wire lock_write_chk_req;
wire lock_write_tamper;
wire lock_simple_write;

wire wr_chk_ok;
wire wr_chk_rgn_en;
wire wr_chk_mpe_en;
reg  mpe_en_bit;
reg  wr_chk_sram_read_req;
reg  wr_chk_sram_done;
reg  wr_chk_fifo_pop;
reg  wr_chk_err;
reg  wr_chk_simple_write;

reg rgn_st_sram_read_req;
reg rgn_st_sram_done;
reg rgn_st_fifo_pop;

wire sram_read_req;
wire sram_write_req;
wire sram_acc_done;
reg  sram_rw_cenn;
reg  sram_rw_wenn;
reg  sram_rw_fifo_push;

wire simple_write_req;
wire simple_read_req;
reg  simple_sram_read_req;
reg  simple_sram_write_req;
reg  simple_sram_done;
reg  simple_fifo_pop;

reg        rgn_st_0;
wire [4:0] rgn_st_rd_data;

wire [SRAM_WIDTH-1:0] sram_write_data;
wire [SRAM_WIDTH-1:0] sram_read_data;
wire [SRAM_WIDTH-1:0] sram_write_data_mid;
wire [SRAM_WIDTH-1:0] sram_read_data_mid;
reg  [SRAM_WIDTH-1:0] sram_write_data_int;
reg  [SRAM_WIDTH-1:0] sram_read_data_int;
wire                  sram_rw_sel;

reg [LOG2_SRAM_WIDTH-1:0] sram_column_num;

reg  [LOG2_SRAM_SIZE-1:0]  op1_int;
reg  [LOG2_SRAM_SIZE-1:0]  op2_int;
reg                        add_en_int;
reg  [LOG2_SRAM_SIZE-1:0]  op1_acc;
reg  [LOG2_SRAM_SIZE-1:0]  op2_acc;
wire [LOG2_SRAM_SIZE-1:0]  op1_lock;
wire [LOG2_SRAM_SIZE-1:0]  op2_lock;
wire [LOG2_SRAM_SIZE-1:0]  op1_rgn_en;
wire [LOG2_SRAM_SIZE-1:0]  op2_rgn_en;
wire [LOG2_SRAM_SIZE-1:0]  op1_mpe_en;
wire [LOG2_SRAM_SIZE-1:0]  op2_mpe_en;
wire                       add_en_acc;
wire [LOG2_SRAM_SIZE-1:0]  rslt_int;

reg [LOG2_SRAM_SIZE-1:0]  reg_add;
reg                       reg_add_en;
reg                       reg_add_rst;

wire                    counter_max;
reg                     last_in_fifo;

wire [(RWE_CTRL_WIDTH*FW_NUM_FC)-1:0] rgn_pntr;

wire [FW_NUM_FC-1:0] wr_after_reset;
wire [FW_NUM_FC-1:0] wr_after_discon;

reg [READ_DATA_SIZE-1:0] reg_size_int;

wire lock_write_req;
wire chk_write_req;
wire write_check;
wire lock_write_ok;

wire rgn_st_read_req;

integer i;
integer size1;
integer size3;
integer size4;
integer size8;
integer size13;
integer size16;
integer size18;
integer size27;
integer size32;
integer sizemid;
integer rgn_num;
integer fw_id_1;
integer fw_id_2;

wire shdw_ctlr_acc_valid_int;
wire shdw_ctlr_acc_valid_r;
wire shdw_ctlr_restore_req_valid_r;

wire ram_req1;
wire ram_req2;

reg acc_valid;
reg restore_req_valid;

reg  wr_pend_r;
wire wr_pend_nxt;
wire wr_pend_en;
wire wr_comp_check_req;
wire wr_skip_check;

reg packet_sent_r;


firewall_f0_fifo #(
    .FIFO_WIDTH      (FIFO_WIDTH     ),
    .FIFO_DEPTH      (FIFO_DEPTH     ),
    .LOG2_FIFO_DEPTH (LOG2_FIFO_DEPTH)
) u_shdw_fifo (
    .clk          (clk          ),
    .reset_n      (reset_n      ),
    .fifo_pop     (fifo_pop     ),
    .fifo_dataout (fifo_dataout ),
    .fifo_empty   (fifo_empty   ),
    .fifo_push    (fifo_push    ),
    .fifo_datain  (fifo_datain  ),
    .fifo_full    (fifo_full    ),
    .fifo_writeptr(fifo_writeptr),
    .fifo_readptr (fifo_readptr )
);


assign fifo_push = fifo_push_cfg_acc || fifo_push_rstr_init || fifo_push_rstr_hdr;
assign fifo_pop  = fifo_pop_cfg_acc || fifo_pop_rstr_init;
assign fifo_datain = (state == IDLE) ? fifo_datain_cfg_acc : fifo_datain_rstr_init;

assign rslt_int = shdw_ctlr_add_rslt_i;

always @(posedge clk or negedge reset_n)
begin:REG_ADDER_OUTPUT
  if (!reset_n) begin
    reg_add <= {LOG2_SRAM_SIZE{1'b0}};
  end else begin
    if (reg_add_rst) begin
      reg_add <= {LOG2_SRAM_SIZE{1'b0}};
    end else begin
      if (reg_add_en) begin
        if (state==COMP_RSTR && last_state!=state) begin
          reg_add <=
            SRAM_COMP_OFFSET[ shdw_ctlr_restore_req_id_i*SRAM_OFFSET_SIZE +:
              LOG2_SRAM_SIZE];
        end else begin
          reg_add <= rslt_int;
        end
      end
    end
  end
end


always @(posedge clk or negedge reset_n)
begin: TRACK_LAST_LINE
  if (!reset_n) begin
    last_in_fifo <= 1'b0;
  end else begin
    if (counter_max && !sram_cenn) begin
      last_in_fifo <= 1'b1;
    end
    else if (state == IDLE) begin
      last_in_fifo <= 1'b0;
    end
  end
end


always @ (posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    packet_sent_r <= 1'b0;
  end
  else begin
    packet_sent_r <= shdw_ctlr_up_pkt_sent_i;
  end
end


assign wr_comp_check_req = (shdw_ctlr_acc_valid_i || wr_pend_r) &&
  shdw_ctlr_rw_i && shdw_ctlr_wr_rsp_pend_i &&
  shdw_ctlr_cmp_pwr_st_i[shdw_ctlr_fc_id_i];

assign shdw_ctlr_acc_valid_int = wr_comp_check_req ?
  shdw_ctlr_wr_valid_i && !shdw_ctlr_wr_rsp_i && !shdw_ctlr_fixed_i :
  shdw_ctlr_acc_valid_i;

assign wr_skip_check = shdw_ctlr_rw_i && shdw_ctlr_chk_need_i &&
  shdw_ctlr_wr_rsp_pend_i && shdw_ctlr_cmp_pwr_st_i[shdw_ctlr_fc_id_i];

always @ (posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    wr_pend_r <= 1'b0;
  end
  else begin
    if (wr_pend_en) begin
      wr_pend_r <= wr_pend_nxt;
    end
  end
end

assign wr_pend_en = (shdw_ctlr_acc_valid_i && shdw_ctlr_rw_i &&
  shdw_ctlr_chk_need_i && shdw_ctlr_wr_rsp_pend_i &&
  shdw_ctlr_cmp_pwr_st_i[shdw_ctlr_fc_id_i]) || shdw_ctlr_wr_valid_i;

assign wr_pend_nxt = !shdw_ctlr_wr_valid_i;


always @(posedge clk or negedge reset_n)
begin:ACC_VALID_FLOP
  if (!reset_n) begin
    acc_valid <= 1'b0;
  end else begin
    if (!shdw_ctlr_lpi_ram_ack_i && shdw_ctlr_acc_valid_int) begin
      acc_valid <= 1'b1;
    end else if (shdw_ctlr_lpi_ram_ack_i) begin
      acc_valid <= 1'b0;
    end
  end
end

always @(posedge clk or negedge reset_n)
begin:RESTORE_VALID_FLOP
  if (!reset_n) begin
    restore_req_valid <= 1'b0;
  end else begin
    if (!shdw_ctlr_lpi_ram_ack_i && shdw_ctlr_restore_req_valid_i) begin
      restore_req_valid <= 1'b1;
    end else if (shdw_ctlr_lpi_ram_ack_i) begin
      restore_req_valid <= 1'b0;
    end
  end
end

assign shdw_ctlr_acc_valid_r =
  shdw_ctlr_lpi_ram_ack_i ? (acc_valid || shdw_ctlr_acc_valid_int) : 1'b0;

assign shdw_ctlr_restore_req_valid_r =
  shdw_ctlr_lpi_ram_ack_i ? (restore_req_valid || shdw_ctlr_restore_req_valid_i) : 1'b0;

assign ram_req1 = shdw_ctlr_acc_valid_int       ||
                  shdw_ctlr_restore_req_valid_i ||
                  acc_valid                     ||
                  restore_req_valid;

assign ram_req2 = (state!= IDLE || sram_rw_sm_r!= SRAM_RW_IDLE ||
  rw_sm_r!= RW_IDLE || lock_sm_r!= LOCK_IDLE || wr_chk_sm_r!= WR_CHK_IDLE ||
  rd_st_sm_r!= RD_ST_IDLE);

assign shdw_ctlr_lpi_ram_req_o = ram_req1 || ram_req2 || !shdw_ctlr_sram_cenn;


assign shdw_ctlr_sram_addr_sel = !sram_cenn_cfg_acc ? sram_addr_cfg_acc : sram_addr;
assign shdw_ctlr_sram_cenn_sel = !sram_cenn_cfg_acc ? sram_cenn_cfg_acc : sram_cenn;
assign shdw_ctlr_sram_data_sel = !sram_cenn_cfg_acc ? sram_data_cfg_acc : sram_datai;
assign shdw_ctlr_sram_wenn_sel = !sram_cenn_cfg_acc ? sram_wenn_cfg_acc : sram_wenn;

always @ (posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    fifo_rstr_count_r <= {LOG2_RSTR_DEPTH{1'b0}};
  end
  else begin
    if (state == COMP_RSTR) begin
      if (shdw_ctlr_first_restore_data_o_int) begin
        fifo_rstr_count_r <= fifo_rstr_count_r + {{(LOG2_RSTR_DEPTH-1){1'b0}}, 1'b1};
      end
      else if (!sram_cenn && !fifo_pop_rstr_init) begin
        fifo_rstr_count_r <= fifo_rstr_count_r + {{(LOG2_RSTR_DEPTH-1){1'b0}}, 1'b1};
      end
      else if (sram_cenn && fifo_pop_rstr_init) begin
        fifo_rstr_count_r <= fifo_rstr_count_r - {{(LOG2_RSTR_DEPTH-1){1'b0}}, 1'b1};
      end
    end
  end
end

assign fifo_rstr_full_nxt = (fifo_rstr_count_r == FIFO_DEPTH) && !fifo_pop_rstr_init;

generate
  if (RAM_REG_SLICE == 1) begin : REG_RAM_OUTPUTS
    reg [LOG2_SRAM_SIZE-1:0] shdw_ctlr_sram_addr_r;
    reg                      shdw_ctlr_sram_cenn_r;
    reg                      shdw_ctlr_sram_wenn_r;
    reg [SRAM_WIDTH-1:0]     shdw_ctlr_sram_data_r;
    reg                      rd_wr_done_1_r;
    reg                      rd_wr_done_2_r;
    wire                     rd_wr_done_nxt;
    reg                      rstr_push_1_r;
    reg                      rstr_push_2_r;

    always @ (posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        shdw_ctlr_sram_cenn_r <= 1'b1;
        shdw_ctlr_sram_wenn_r <= 1'b1;
      end
      else begin
        shdw_ctlr_sram_cenn_r <= shdw_ctlr_sram_cenn_sel;
        shdw_ctlr_sram_wenn_r <= shdw_ctlr_sram_wenn_sel;
      end
    end

    always @ (posedge clk) begin
      if (!shdw_ctlr_sram_cenn_sel) begin
        shdw_ctlr_sram_addr_r <= shdw_ctlr_sram_addr_sel;
        shdw_ctlr_sram_data_r <= shdw_ctlr_sram_data_sel;
      end
    end

    assign rd_wr_done_nxt = simple_sram_read_req || lock_sram_read_req ||
      wr_chk_sram_read_req || rgn_st_sram_read_req;

    always @ (posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        rd_wr_done_1_r <= 1'b0;
        rd_wr_done_2_r <= 1'b0;
      end
      else begin
        rd_wr_done_1_r <= rd_wr_done_nxt;
        rd_wr_done_2_r <= rd_wr_done_1_r;
      end
    end

    always @ (posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        rstr_push_1_r <= 1'b0;
        rstr_push_2_r <= 1'b0;
      end
      else begin
        rstr_push_1_r <= ~sram_cenn;
        rstr_push_2_r <= rstr_push_1_r;
      end
    end

    assign shdw_ctlr_sram_addr    = shdw_ctlr_sram_addr_r;
    assign shdw_ctlr_sram_cenn    = shdw_ctlr_sram_cenn_r;
    assign shdw_ctlr_sram_data    = shdw_ctlr_sram_data_r;
    assign shdw_ctlr_sram_wenn    = shdw_ctlr_sram_wenn_r;
    assign rd_wr_done             = rd_wr_done_2_r;
    assign fifo_rstr_push         = rstr_push_2_r;

  end
  else begin: NO_REG_RAM_OUTPUTS

    reg rstr_push_1_r;

    always @ (posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        rstr_push_1_r <= 1'b0;
      end
      else begin
        rstr_push_1_r <= ~sram_cenn;
      end
    end

    assign shdw_ctlr_sram_addr    = shdw_ctlr_sram_addr_sel;
    assign shdw_ctlr_sram_cenn    = shdw_ctlr_sram_cenn_sel;
    assign shdw_ctlr_sram_data    = shdw_ctlr_sram_data_sel;
    assign shdw_ctlr_sram_wenn    = shdw_ctlr_sram_wenn_sel;
    assign rd_wr_done             = 1'b1;
    assign fifo_rstr_push         = rstr_push_1_r;

  end
endgenerate


always @(posedge clk or negedge reset_n)
begin: GO_TO_NEXT_STATE
  if (!reset_n) begin
    state      <= IDLE;
    last_state <= IDLE;
  end else begin
    state      <= nxt_state;
    last_state <= state;
  end
end

always @(*)
begin:CALCULATE_NEXT_STATE
  case (state)
    IDLE: begin
      if (shdw_ctlr_restore_req_i && shdw_ctlr_restore_req_valid_r) begin
        nxt_state = COMP_RSTR;
      end else begin
        if (shdw_ctlr_lpi_ram_init_i) begin
          nxt_state = SRAM_INIT;
        end else begin
          nxt_state = IDLE;
        end
      end
    end
    SRAM_INIT: begin
      if (!shdw_ctlr_init_o_int) begin
        nxt_state = IDLE;
      end else begin
        nxt_state = SRAM_INIT;
      end
    end
    COMP_RSTR: begin
      if (shdw_ctlr_restore_done_o_int) begin
        nxt_state = IDLE;
      end else begin
        nxt_state = COMP_RSTR;
      end
    end
    default: begin
      nxt_state = {SIZE{1'bx}};
    end
  endcase
end

always @(*)
begin:DRIVE_OUTPUTS
  case (state)
    IDLE: begin
      reg_add_rst                        = 1'b1;
      reg_add_en                         = 1'b0;
      add_en_int                         = 1'b0;
      op1_int                            = {COUNTER_SIZE{1'b0}};
      op2_int                            = {COUNTER_SIZE{1'b0}};
      shdw_ctlr_first_restore_data_o_int = 1'b0;
      fifo_push_rstr_init                = 1'b0;
      fifo_push_rstr_hdr                 = 1'b0;
      fifo_pop_rstr_init                 = 1'b0;
      sram_addr                          = {COUNTER_SIZE{1'b0}};
      sram_cenn                          = 1'b1;
      sram_wenn                          = 1'b1;
      fifo_datain_rstr_init              = {FIFO_WIDTH{1'b0}};
      shdw_ctlr_restore_data_o_int       = {SRAM_WIDTH{1'b0}};
      shdw_ctlr_restore_fw_id_o_int      = {LOG2_FW_NUM_FC{1'b0}};
      shdw_ctlr_restore_valid_o_int      = 1'b0;
      shdw_ctlr_restore_done_o_int       = 1'b0;
      shdw_ctlr_us_last_pkt_o_int        = 1'b0;
      shdw_ctlr_clk_busy_o_int           = 1'b0;
      sram_datai                         = {SRAM_WIDTH{1'b0}};
      shdw_ctlr_init_o_int               = 1'b0;

    end
    COMP_RSTR: begin

      sram_datai         = {SRAM_WIDTH{1'b0}};
      fifo_push_rstr_hdr = 1'b0;

      if ((state != last_state) || shdw_ctlr_restore_req_valid_r) begin
        add_en_int = 1'b0;
        reg_add_en = 1'b1;
        shdw_ctlr_first_restore_data_o_int = 1'b1;
        fifo_pop_rstr_init                 = 1'b0;
        fifo_push_rstr_hdr  = 1'b1;
        fifo_push_rstr_init = 1'b0;
        fifo_datain_rstr_init = {{(FIFO_WIDTH-2){1'b0}}, 2'b01};
        shdw_ctlr_restore_data_o_int  = fifo_datain_rstr_init;
        shdw_ctlr_restore_valid_o_int = 1'b1;
        sram_cenn = 1'b1;
      end else begin
        add_en_int = !fifo_rstr_full_nxt && !counter_max;
        reg_add_en = add_en_int;
        shdw_ctlr_first_restore_data_o_int = 1'b0;
        fifo_push_rstr_init = fifo_rstr_push;
        fifo_pop_rstr_init = (!fifo_empty) && shdw_ctlr_up_pkt_sent_i;
        fifo_datain_rstr_init = sram_datao;
        shdw_ctlr_restore_data_o_int  = fifo_dataout;
        shdw_ctlr_restore_valid_o_int = !fifo_empty;
        sram_cenn = fifo_rstr_full_nxt || last_in_fifo;
      end

      op1_int = reg_add;
      op2_int = {{(COUNTER_SIZE-1){1'b0}}, 1'b1};

      sram_addr = reg_add;
      sram_wenn = 1'b1;

      shdw_ctlr_restore_fw_id_o_int = shdw_ctlr_restore_req_id_i;
      shdw_ctlr_restore_done_o_int  = last_in_fifo && (fifo_rstr_count_r == 0);

      shdw_ctlr_us_last_pkt_o_int = last_in_fifo && (fifo_rstr_count_r == 1);

      shdw_ctlr_clk_busy_o_int = 1'b1;
      shdw_ctlr_init_o_int     = 1'b0;

      reg_add_rst = 1'b0;
    end
    SRAM_INIT: begin

      reg_add_en = 1'b1;
      add_en_int = 1'b1;

      shdw_ctlr_first_restore_data_o_int = 1'b0;
      fifo_push_rstr_init                = 1'b0;
      fifo_push_rstr_hdr                 = 1'b0;
      fifo_pop_rstr_init                 = 1'b0;
      sram_addr                          = {COUNTER_SIZE{1'b0}};
      sram_cenn                          = 1'b1;
      sram_wenn                          = 1'b1;
      fifo_datain_rstr_init              = {FIFO_WIDTH{1'b0}};
      shdw_ctlr_restore_data_o_int       = {SRAM_WIDTH{1'b0}};
      shdw_ctlr_restore_fw_id_o_int      = {LOG2_FW_NUM_FC{1'b0}};
      shdw_ctlr_restore_valid_o_int      = 1'b0;
      shdw_ctlr_restore_done_o_int       = 1'b0;
      shdw_ctlr_us_last_pkt_o_int        = 1'b0;
      shdw_ctlr_clk_busy_o_int           = 1'b1;
      sram_datai                         = {SRAM_WIDTH{1'b0}};
      reg_add_rst                        = 1'b0;
      sram_addr                          = {LOG2_SRAM_SIZE{1'b0}};
      sram_cenn                          = 1'b1;
      sram_wenn                          = 1'b1;
      sram_datai                         = {SRAM_WIDTH{1'b0}};

      if (reg_add == (RGN_SIZE_START[(SRAM_OFFSET_SIZE*FW_NUM_FC)-1 -: SRAM_OFFSET_SIZE] +
          SRAM_COMP_OFFSET[(FW_NUM_FC*SRAM_OFFSET_SIZE)-1-:SRAM_OFFSET_SIZE])) begin
        shdw_ctlr_init_o_int = 1'b0;
      end else begin
        shdw_ctlr_init_o_int = 1'b1;
      end

      op1_int = reg_add;
      op2_int = {{(COUNTER_SIZE-1){1'b0}}, 1'b1};

      for (i=0;i<FW_NUM_FC;i=i+1) begin

        if ((reg_add == (SRAM_COMP_OFFSET[((i+1)*SRAM_OFFSET_SIZE)-1-:SRAM_OFFSET_SIZE] +
            RGN_SIZE_START[((i+1)*SRAM_OFFSET_SIZE)-1-:SRAM_OFFSET_SIZE])) && (i != (FW_NUM_FC-1)) &&
            (reg_add != SRAM_COMP_OFFSET[(i+2)*SRAM_OFFSET_SIZE-1-:SRAM_OFFSET_SIZE])) begin
          op1_int = {(COUNTER_SIZE){1'b0}};
          op2_int = SRAM_COMP_OFFSET[(i+1)*SRAM_OFFSET_SIZE +: LOG2_SRAM_SIZE];
        end
        if ((reg_add == (SRAM_COMP_OFFSET[((i+1)*SRAM_OFFSET_SIZE)-1-:SRAM_OFFSET_SIZE] +
            PROT_SIZE_START[(i+1)*SRAM_OFFSET_SIZE-1-:SRAM_OFFSET_SIZE])) &&
            (PROT_SIZE_EXISTS[i] && !PROT_SIZE_FIXED[i])) begin

          sram_addr  = reg_add;
          sram_cenn  = 1'b0;
          sram_wenn  = 1'b0;
          sram_datai = {{(SRAM_WIDTH-8){1'b0}}, prot_size_i[8*(i+1)-1 -: 8]};

        end
        else if ((reg_add == (SRAM_COMP_OFFSET[((i+1)*SRAM_OFFSET_SIZE)-1-:SRAM_OFFSET_SIZE] +
            PE_CTRL_START[(i+1)*SRAM_OFFSET_SIZE-1-:SRAM_OFFSET_SIZE])) &&
            (PE_CTRL_EXISTS[i] && !PE_CTRL_FIXED[i])) begin

          sram_addr  = reg_add;
          sram_cenn  = 1'b0;
          sram_wenn  = 1'b0;
          sram_datai = DEF_PE_CTRL_LN_VL;

        end
        else if ((RGN_TCFG2_EXISTS[i] && !RGN_TCFG2_FIXED[i]) &&
            (reg_add >= (SRAM_COMP_OFFSET[(i+1)*SRAM_OFFSET_SIZE-1-:SRAM_OFFSET_SIZE] +
            RGN_TCFG2_START[(i+1)*SRAM_OFFSET_SIZE-1-:SRAM_OFFSET_SIZE])) &&
            (reg_add <= (SRAM_COMP_OFFSET[(i+1)*SRAM_OFFSET_SIZE-1-:SRAM_OFFSET_SIZE] +
            RGN_TCFG2_END[(i+1)*SRAM_OFFSET_SIZE-1-:SRAM_OFFSET_SIZE]))) begin

          sram_addr  = reg_add;
          sram_cenn  = 1'b0;
          sram_wenn  = 1'b0;
          sram_datai = {{14{1'b0}}, RGN_TCFG2_RST_VAL};
        end
        else if (((ME_CTRL_EXISTS[i] && !ME_CTRL_FIXED[i]) ||
            (RGN_CTRL0_EXISTS[i] && !RGN_CTRL0_FIXED[i]) ||
            (RGN_CTRL1_EXISTS[i] && !RGN_CTRL1_FIXED[i]) ||
            (RGN_LCTRL_EXISTS[i] && !RGN_LCTRL_FIXED[i]) ||
            (RWE_CTRL_EXISTS[i] && !RWE_CTRL_FIXED[i])) &&
            ((reg_add >= (SRAM_COMP_OFFSET[(i+1)*SRAM_OFFSET_SIZE-1-:SRAM_OFFSET_SIZE] +
            ME_CTRL_START[(i+1)*SRAM_OFFSET_SIZE-1-:SRAM_OFFSET_SIZE])) &&
            (reg_add <= (SRAM_COMP_OFFSET[(i+1)*SRAM_OFFSET_SIZE-1-:SRAM_OFFSET_SIZE] +
            RWE_CTRL_END[(i+1)*SRAM_OFFSET_SIZE-1-:SRAM_OFFSET_SIZE])))) begin
          sram_addr  = reg_add;
          sram_cenn  = 1'b0;
          sram_wenn  = 1'b0;
          sram_datai = {SRAM_WIDTH{1'b0}};
        end
        else if ((reg_add == (SRAM_COMP_OFFSET[(i+1)*SRAM_OFFSET_SIZE-1-:SRAM_OFFSET_SIZE] +
            RGN_SIZE_START[(i+1)*SRAM_OFFSET_SIZE-1-:SRAM_OFFSET_SIZE])) &&
            (RGN_SIZE_EXISTS[i] && !RGN_SIZE_FIXED[i])) begin
          sram_addr  = reg_add;
          sram_cenn  = 1'b0;
          sram_wenn  = 1'b0;
          sram_datai = {{(SRAM_WIDTH-16){1'b0}}, 8'b0, prot_size_i[8*(i+1)-1 -: 8]};
        end

      end

    end
    default: begin
      reg_add_rst                        = 1'bx;
      reg_add_en                         = 1'bx;
      add_en_int                         = 1'bx;
      op1_int                            = {COUNTER_SIZE{1'bx}};
      op2_int                            = {COUNTER_SIZE{1'bx}};
      shdw_ctlr_first_restore_data_o_int = 1'bx;
      fifo_push_rstr_init                = 1'bx;
      fifo_push_rstr_hdr                 = 1'bx;
      fifo_pop_rstr_init                 = 1'bx;
      sram_addr                          = {COUNTER_SIZE{1'bx}};
      sram_cenn                          = 1'bx;
      sram_wenn                          = 1'bx;
      fifo_datain_rstr_init              = {FIFO_WIDTH{1'bx}};
      shdw_ctlr_restore_data_o_int       = {SRAM_WIDTH{1'bx}};
      shdw_ctlr_restore_fw_id_o_int      = {LOG2_FW_NUM_FC{1'bx}};
      shdw_ctlr_restore_valid_o_int      = 1'bx;
      shdw_ctlr_restore_done_o_int       = 1'bx;
      shdw_ctlr_us_last_pkt_o_int        = 1'bx;
      shdw_ctlr_clk_busy_o_int           = 1'bx;
      sram_datai                         = {SRAM_WIDTH{1'bx}};
      shdw_ctlr_init_o_int               = 1'bx;

    end
  endcase
end

assign counter_max =
  (reg_add == RGN_CFG1_END[shdw_ctlr_restore_req_id_i*SRAM_OFFSET_SIZE +:
    SRAM_OFFSET_SIZE] +
      SRAM_COMP_OFFSET[shdw_ctlr_restore_req_id_i*SRAM_OFFSET_SIZE +:
        SRAM_OFFSET_SIZE]);

assign sram_init_done_o = (reg_add == (RGN_SIZE_START[(SRAM_OFFSET_SIZE*FW_NUM_FC)-1 -: SRAM_OFFSET_SIZE] +
  SRAM_COMP_OFFSET[(FW_NUM_FC*SRAM_OFFSET_SIZE)-1-:SRAM_OFFSET_SIZE])) && state == SRAM_INIT;




always @ (posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    sram_rw_sm_r <= SRAM_RW_IDLE;
  end
  else begin
    sram_rw_sm_r <= sram_rw_sm_nxt;
  end
end

always @* begin
  case (sram_rw_sm_r)
    SRAM_RW_IDLE: begin
      case (sram_read_req)
        1'b0: begin
          sram_rw_sm_nxt    = SRAM_RW_IDLE;
          sram_rw_cenn      = 1'b1;
          sram_rw_wenn      = 1'b1;
          sram_rw_fifo_push = 1'b0;
        end
        1'b1: begin
          sram_rw_sm_nxt    = SRAM_RW_READ;
          sram_rw_cenn      = 1'b0;
          sram_rw_wenn      = 1'b1;
          sram_rw_fifo_push = 1'b0;
        end
        default: begin
          sram_rw_sm_nxt    = {SRAM_RW_SM_SIZE{1'bx}};
          sram_rw_cenn      = 1'bx;
          sram_rw_wenn      = 1'bx;
          sram_rw_fifo_push = 1'bx;
        end
      endcase
    end
    SRAM_RW_READ: begin
      case ({sram_read_req, sram_write_req, sram_acc_done})
        3'b100: begin
          sram_rw_sm_nxt    = SRAM_RW_READ;
          sram_rw_cenn      = 1'b0;
          sram_rw_wenn      = 1'b1;
          sram_rw_fifo_push = 1'b1;
        end
        3'b000: begin
          sram_rw_sm_nxt    = SRAM_RW_READ;
          sram_rw_cenn      = 1'b1;
          sram_rw_wenn      = 1'b1;
          sram_rw_fifo_push = 1'b0;
        end
        3'b001: begin
          sram_rw_sm_nxt    = SRAM_RW_IDLE;
          sram_rw_cenn      = 1'b1;
          sram_rw_wenn      = 1'b1;
          sram_rw_fifo_push = 1'b1;
        end
        3'b010, 3'b011: begin
          sram_rw_sm_nxt    = SRAM_RW_WRITE;
          sram_rw_cenn      = 1'b1;
          sram_rw_wenn      = 1'b1;
          sram_rw_fifo_push = 1'b1;
        end
        default: begin
          sram_rw_sm_nxt    = {SRAM_RW_SM_SIZE{1'bx}};
          sram_rw_cenn      = 1'bx;
          sram_rw_wenn      = 1'bx;
          sram_rw_fifo_push = 1'bx;
        end
      endcase
    end
    SRAM_RW_WRITE: begin
      sram_rw_sm_nxt    = SRAM_RW_IDLE;
      sram_rw_cenn      = 1'b0;
      sram_rw_wenn      = 1'b0;
      sram_rw_fifo_push = 1'b0;
    end
    default: begin
      sram_rw_sm_nxt    = {SRAM_RW_SM_SIZE{1'bx}};
      sram_rw_cenn      = 1'bx;
      sram_rw_wenn      = 1'bx;
      sram_rw_fifo_push = 1'bx;
    end
  endcase
end



generate
  if (FW_LDE_LVL == 2) begin : LDE_2

    reg [LOCK_SM_SIZE-1:0] lock_sm_r_int;
    reg [LOCK_SM_SIZE-1:0] lock_sm_nxt_int;

    reg lock_sram_read_req_int;
    reg lock_sram_done_int;
    reg lock_fifo_pop_int;
    reg lock_write_chk_req_int;
    reg lock_write_tamper_int;
    reg lock_simple_write_int;

    always @ (posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        lock_sm_r_int <= LOCK_IDLE;
      end
      else begin
        lock_sm_r_int <= lock_sm_nxt_int;
      end
    end

    always @* begin
      case (lock_sm_r_int)
        LOCK_IDLE: begin
          case (lock_write_req)
            1'b0: begin
              lock_sm_nxt_int        = LOCK_IDLE;
              lock_sram_read_req_int = 1'b0;
              lock_sram_done_int     = 1'b0;
              lock_fifo_pop_int      = 1'b0;
              lock_write_chk_req_int = 1'b0;
              lock_write_tamper_int  = 1'b0;
              lock_simple_write_int  = 1'b0;
            end
            1'b1: begin
              lock_sm_nxt_int        = LOCK_CHK;
              lock_sram_read_req_int = 1'b1;
              lock_sram_done_int     = 1'b0;
              lock_fifo_pop_int      = 1'b0;
              lock_write_chk_req_int = 1'b0;
              lock_write_tamper_int  = 1'b0;
              lock_simple_write_int  = 1'b0;
            end
            default: begin
              lock_sm_nxt_int        = {LOCK_SM_SIZE{1'bx}};
              lock_sram_read_req_int = 1'bx;
              lock_sram_done_int     = 1'bx;
              lock_fifo_pop_int      = 1'bx;
              lock_write_chk_req_int = 1'bx;
              lock_write_tamper_int  = 1'bx;
              lock_simple_write_int  = 1'bx;
            end
          endcase
        end
        LOCK_CHK: begin
          case (rd_wr_done)
            1'b0: begin
              lock_sm_nxt_int        = LOCK_CHK;
              lock_sram_read_req_int = 1'b0;
              lock_sram_done_int     = 1'b0;
              lock_fifo_pop_int      = 1'b0;
              lock_write_chk_req_int = 1'b0;
              lock_write_tamper_int  = 1'b0;
              lock_simple_write_int  = 1'b0;
            end
            1'b1: begin
              lock_sm_nxt_int        = LOCK_DONE;
              lock_sram_read_req_int = 1'b0;
              lock_sram_done_int     = 1'b1;
              lock_fifo_pop_int      = 1'b0;
              lock_write_chk_req_int = 1'b0;
              lock_write_tamper_int  = 1'b0;
              lock_simple_write_int  = 1'b0;
            end
            default: begin
              lock_sm_nxt_int        = {LOCK_SM_SIZE{1'bx}};
              lock_sram_read_req_int = 1'bx;
              lock_sram_done_int     = 1'bx;
              lock_fifo_pop_int      = 1'bx;
              lock_write_chk_req_int = 1'bx;
              lock_write_tamper_int  = 1'bx;
              lock_simple_write_int  = 1'bx;
            end
          endcase
        end
        LOCK_DONE: begin
          case ({write_check, lock_write_ok})
            2'b00, 2'b10: begin
              lock_sm_nxt_int        = LOCK_IDLE;
              lock_sram_read_req_int = 1'b0;
              lock_sram_done_int     = 1'b0;
              lock_fifo_pop_int      = 1'b1;
              lock_write_chk_req_int = 1'b0;
              lock_write_tamper_int  = 1'b1;
              lock_simple_write_int  = 1'b0;
            end
            2'b01: begin
              lock_sm_nxt_int        = LOCK_IDLE;
              lock_sram_read_req_int = 1'b0;
              lock_sram_done_int     = 1'b0;
              lock_fifo_pop_int      = 1'b1;
              lock_write_chk_req_int = 1'b0;
              lock_write_tamper_int  = 1'b0;
              lock_simple_write_int  = 1'b1;
            end
            2'b11: begin
              lock_sm_nxt_int        = LOCK_IDLE;
              lock_sram_read_req_int = 1'b0;
              lock_sram_done_int     = 1'b0;
              lock_fifo_pop_int      = 1'b1;
              lock_write_chk_req_int = 1'b1;
              lock_write_tamper_int  = 1'b0;
              lock_simple_write_int  = 1'b0;
            end
            default: begin
              lock_sm_nxt_int        = {LOCK_SM_SIZE{1'bx}};
              lock_sram_read_req_int = 1'bx;
              lock_sram_done_int     = 1'bx;
              lock_fifo_pop_int      = 1'bx;
              lock_write_chk_req_int = 1'bx;
              lock_write_tamper_int  = 1'bx;
              lock_simple_write_int  = 1'bx;
            end
          endcase
        end
        default: begin
          lock_sm_nxt_int        = {LOCK_SM_SIZE{1'bx}};
          lock_sram_read_req_int = 1'bx;
          lock_sram_done_int     = 1'bx;
          lock_fifo_pop_int      = 1'bx;
          lock_write_chk_req_int = 1'bx;
          lock_write_tamper_int  = 1'bx;
          lock_simple_write_int  = 1'bx;
        end
      endcase
    end

    assign lock_sm_r          = lock_sm_r_int;
    assign lock_sm_nxt        = lock_sm_nxt_int;
    assign lock_sram_read_req = lock_sram_read_req_int;
    assign lock_sram_done     = lock_sram_done_int;
    assign lock_fifo_pop      = lock_fifo_pop_int;
    assign lock_write_chk_req = lock_write_chk_req_int;
    assign lock_write_tamper  = lock_write_tamper_int;
    assign lock_simple_write  = lock_simple_write_int;

  end
  else begin : LDE_0_1

    wire [LOCK_SM_SIZE-1:0] lock_sm_r_int;
    wire [LOCK_SM_SIZE-1:0] lock_sm_nxt_int;

    wire lock_sram_read_req_int;
    wire lock_sram_done_int;
    wire lock_fifo_pop_int;
    wire lock_write_chk_req_int;
    wire lock_write_tamper_int;
    wire lock_simple_write_int;

    assign lock_sm_r          = LOCK_IDLE;
    assign lock_sm_nxt        = LOCK_IDLE;
    assign lock_sram_read_req = 1'b0;
    assign lock_sram_done     = 1'b0;
    assign lock_fifo_pop      = 1'b0;
    assign lock_write_chk_req = 1'b0;
    assign lock_write_tamper  = 1'b0;
    assign lock_simple_write  = 1'b0;

  end
endgenerate



assign wr_chk_rgn_en = chk_write_req ?
  shdw_ctlr_chk_type_i == CHECK_RWE_DATA : 1'b0;
assign wr_chk_mpe_en = chk_write_req ?
  shdw_ctlr_chk_type_i == CHECK_RWE_MPL : 1'b0;

always @ (posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    wr_chk_sm_r <= WR_CHK_IDLE;
  end
  else begin
    wr_chk_sm_r <= wr_chk_sm_nxt;
  end
end

always @* begin
  case (wr_chk_sm_r)
    WR_CHK_IDLE: begin
      case ({wr_chk_rgn_en, wr_chk_mpe_en})
        2'b00: begin
          wr_chk_sm_nxt        = WR_CHK_IDLE;
          wr_chk_sram_read_req = 1'b0;
          wr_chk_sram_done     = 1'b0;
          wr_chk_fifo_pop      = 1'b0;
          wr_chk_err           = 1'b0;
          wr_chk_simple_write  = 1'b0;
        end
        2'b01: begin
          wr_chk_sm_nxt        = WR_CHK_MPE;
          wr_chk_sram_read_req = 1'b1;
          wr_chk_sram_done     = 1'b0;
          wr_chk_fifo_pop      = 1'b0;
          wr_chk_err           = 1'b0;
          wr_chk_simple_write  = 1'b0;
        end
        2'b10: begin
          wr_chk_sm_nxt        = WR_CHK_RGN;
          wr_chk_sram_read_req = 1'b1;
          wr_chk_sram_done     = 1'b0;
          wr_chk_fifo_pop      = 1'b0;
          wr_chk_err           = 1'b0;
          wr_chk_simple_write  = 1'b0;
        end
        default: begin
          wr_chk_sm_nxt        = {WR_CHK_SM_SIZE{1'bx}};
          wr_chk_sram_read_req = 1'bx;
          wr_chk_sram_done     = 1'bx;
          wr_chk_fifo_pop      = 1'bx;
          wr_chk_err           = 1'bx;
          wr_chk_simple_write  = 1'bx;
        end
      endcase
    end
    WR_CHK_RGN: begin
      case (rd_wr_done)
        1'b0: begin
          wr_chk_sm_nxt        = WR_CHK_RGN;
          wr_chk_sram_read_req = 1'b0;
          wr_chk_sram_done     = 1'b0;
          wr_chk_fifo_pop      = 1'b0;
          wr_chk_err           = 1'b0;
          wr_chk_simple_write  = 1'b0;
        end
        1'b1: begin
          wr_chk_sm_nxt        = WR_CHK_RGN_DONE;
          wr_chk_sram_read_req = 1'b0;
          wr_chk_sram_done     = 1'b1;
          wr_chk_fifo_pop      = 1'b0;
          wr_chk_err           = 1'b0;
          wr_chk_simple_write  = 1'b0;
        end
        default: begin
          wr_chk_sm_nxt        = {WR_CHK_SM_SIZE{1'bx}};
          wr_chk_sram_read_req = 1'bx;
          wr_chk_sram_done     = 1'bx;
          wr_chk_fifo_pop      = 1'bx;
          wr_chk_err           = 1'bx;
          wr_chk_simple_write  = 1'bx;
        end
      endcase
    end
    WR_CHK_MPE: begin
      case (rd_wr_done)
        1'b0: begin
          wr_chk_sm_nxt        = WR_CHK_MPE;
          wr_chk_sram_read_req = 1'b0;
          wr_chk_sram_done     = 1'b0;
          wr_chk_fifo_pop      = 1'b0;
          wr_chk_err           = 1'b0;
          wr_chk_simple_write  = 1'b0;
        end
        1'b1: begin
          wr_chk_sm_nxt        = WR_CHK_MPE_DONE;
          wr_chk_sram_read_req = 1'b0;
          wr_chk_sram_done     = 1'b1;
          wr_chk_fifo_pop      = 1'b0;
          wr_chk_err           = 1'b0;
          wr_chk_simple_write  = 1'b0;
        end
        default: begin
          wr_chk_sm_nxt        = {WR_CHK_SM_SIZE{1'bx}};
          wr_chk_sram_read_req = 1'bx;
          wr_chk_sram_done     = 1'bx;
          wr_chk_fifo_pop      = 1'bx;
          wr_chk_err           = 1'bx;
          wr_chk_simple_write  = 1'bx;
        end
      endcase
    end
    WR_CHK_RGN_DONE: begin
      case (wr_chk_ok)
        1'b0: begin
          wr_chk_sm_nxt        = WR_CHK_IDLE;
          wr_chk_sram_read_req = 1'b0;
          wr_chk_sram_done     = 1'b0;
          wr_chk_fifo_pop      = 1'b1;
          wr_chk_err           = 1'b1;
          wr_chk_simple_write  = 1'b0;
        end
        1'b1: begin
          wr_chk_sm_nxt        = WR_CHK_IDLE;
          wr_chk_sram_read_req = 1'b0;
          wr_chk_sram_done     = 1'b0;
          wr_chk_fifo_pop      = 1'b1;
          wr_chk_err           = 1'b0;
          wr_chk_simple_write  = 1'b1;
        end
        default: begin
          wr_chk_sm_nxt        = {WR_CHK_SM_SIZE{1'bx}};
          wr_chk_sram_read_req = 1'bx;
          wr_chk_sram_done     = 1'bx;
          wr_chk_fifo_pop      = 1'bx;
          wr_chk_err           = 1'bx;
          wr_chk_simple_write  = 1'bx;
        end
      endcase
    end
    WR_CHK_MPE_DONE: begin
      case (wr_chk_ok)
        1'b0: begin
          wr_chk_sm_nxt        = WR_CHK_IDLE;
          wr_chk_sram_read_req = 1'b0;
          wr_chk_sram_done     = 1'b0;
          wr_chk_fifo_pop      = 1'b1;
          wr_chk_err           = 1'b1;
          wr_chk_simple_write  = 1'b0;
        end
        1'b1: begin
          wr_chk_sm_nxt        = WR_CHK_IDLE;
          wr_chk_sram_read_req = 1'b0;
          wr_chk_sram_done     = 1'b0;
          wr_chk_fifo_pop      = 1'b1;
          wr_chk_err           = 1'b0;
          wr_chk_simple_write  = 1'b1;
        end
        default: begin
          wr_chk_sm_nxt        = {WR_CHK_SM_SIZE{1'bx}};
          wr_chk_sram_read_req = 1'bx;
          wr_chk_sram_done     = 1'bx;
          wr_chk_fifo_pop      = 1'bx;
          wr_chk_err           = 1'bx;
          wr_chk_simple_write  = 1'bx;
        end
      endcase
    end
    default: begin
      wr_chk_sm_nxt        = {WR_CHK_SM_SIZE{1'bx}};
      wr_chk_sram_read_req = 1'bx;
      wr_chk_sram_done     = 1'bx;
      wr_chk_fifo_pop      = 1'bx;
      wr_chk_err           = 1'bx;
      wr_chk_simple_write  = 1'bx;
    end
  endcase
end



always @ (posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    rd_st_sm_r <= RD_ST_IDLE;
  end
  else begin
    rd_st_sm_r <= rd_st_sm_nxt;
  end
end

always @* begin
  case (rd_st_sm_r)
    RD_ST_IDLE: begin
      case (rgn_st_read_req)
        1'b0: begin
          rd_st_sm_nxt         = RD_ST_IDLE;
          rgn_st_sram_read_req = 1'b0;
          rgn_st_sram_done     = 1'b0;
          rgn_st_fifo_pop      = 1'b0;
        end
        1'b1: begin
          rd_st_sm_nxt         = RD_ST_EN;
          rgn_st_sram_read_req = 1'b1;
          rgn_st_sram_done     = 1'b0;
          rgn_st_fifo_pop      = 1'b0;
        end
        default: begin
          rd_st_sm_nxt         = {RD_ST_SM_SIZE{1'bx}};
          rgn_st_sram_read_req = 1'bx;
          rgn_st_sram_done     = 1'bx;
          rgn_st_fifo_pop      = 1'bx;
        end
      endcase
    end
    RD_ST_EN: begin
      case (rd_wr_done)
        1'b0: begin
          rd_st_sm_nxt         = RD_ST_EN;
          rgn_st_sram_read_req = 1'b0;
          rgn_st_sram_done     = 1'b0;
          rgn_st_fifo_pop      = 1'b0;
        end
        1'b1: begin
          rd_st_sm_nxt         = RD_ST_MPE;
          rgn_st_sram_read_req = 1'b1;
          rgn_st_sram_done     = 1'b0;
          rgn_st_fifo_pop      = 1'b0;
        end
        default: begin
          rd_st_sm_nxt         = {RD_ST_SM_SIZE{1'bx}};
          rgn_st_sram_read_req = 1'bx;
          rgn_st_sram_done     = 1'bx;
          rgn_st_fifo_pop      = 1'bx;
        end
      endcase
    end
    RD_ST_MPE: begin
      case (rd_wr_done)
        1'b0: begin
          rd_st_sm_nxt         = RD_ST_MPE;
          rgn_st_sram_read_req = 1'b0;
          rgn_st_sram_done     = 1'b0;
          rgn_st_fifo_pop      = 1'b0;
        end
        1'b1: begin
          rd_st_sm_nxt         = RD_ST_DONE;
          rgn_st_sram_read_req = 1'b0;
          rgn_st_sram_done     = 1'b1;
          rgn_st_fifo_pop      = 1'b1;
        end
        default: begin
          rd_st_sm_nxt         = {RD_ST_SM_SIZE{1'bx}};
          rgn_st_sram_read_req = 1'bx;
          rgn_st_sram_done     = 1'bx;
          rgn_st_fifo_pop      = 1'bx;
        end
      endcase
    end
    RD_ST_DONE: begin
      rd_st_sm_nxt         = RD_ST_IDLE;
      rgn_st_sram_read_req = 1'b0;
      rgn_st_sram_done     = 1'b0;
      rgn_st_fifo_pop      = 1'b1;
    end
    default: begin
      rd_st_sm_nxt         = {RD_ST_SM_SIZE{1'bx}};
      rgn_st_sram_read_req = 1'bx;
      rgn_st_sram_done     = 1'bx;
      rgn_st_fifo_pop      = 1'bx;
    end
  endcase
end

always @ (posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    rgn_st_0 <= 1'b0;
  end
  else begin
    if (rd_st_sm_r == RD_ST_MPE) begin
      rgn_st_0 <= sram_read_data[0];
    end
  end
end

assign rgn_st_rd_data = {sram_read_data[3:0], rgn_st_0};



always @ (posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    rw_sm_r <= RW_IDLE;
  end
  else begin
    rw_sm_r <= rw_sm_nxt;
  end
end

always @* begin
  case (rw_sm_r)
    RW_IDLE: begin
      case ({simple_write_req, simple_read_req})
        2'b00: begin
          rw_sm_nxt             = RW_IDLE;
          simple_sram_read_req  = 1'b0;
          simple_sram_write_req = 1'b0;
          simple_sram_done      = 1'b0;
          simple_fifo_pop       = 1'b0;
        end
        2'b01, 2'b11: begin
          rw_sm_nxt             = RW_READ;
          simple_sram_read_req  = 1'b1;
          simple_sram_write_req = 1'b0;
          simple_sram_done      = 1'b0;
          simple_fifo_pop       = 1'b0;
        end
        2'b10: begin
          rw_sm_nxt             = RW_WRITE;
          simple_sram_read_req  = 1'b1;
          simple_sram_write_req = 1'b0;
          simple_sram_done      = 1'b0;
          simple_fifo_pop       = 1'b0;
        end
        default: begin
          rw_sm_nxt             = {RW_SM_SIZE{1'bx}};
          simple_sram_read_req  = 1'bx;
          simple_sram_write_req = 1'bx;
          simple_sram_done      = 1'bx;
          simple_fifo_pop       = 1'bx;
        end
      endcase
    end
    RW_READ: begin
      case (rd_wr_done)
        1'b0: begin
          rw_sm_nxt             = RW_READ;
          simple_sram_read_req  = 1'b0;
          simple_sram_write_req = 1'b0;
          simple_sram_done      = 1'b0;
          simple_fifo_pop       = 1'b0;
        end
        1'b1: begin
          rw_sm_nxt             = RW_DONE;
          simple_sram_read_req  = 1'b0;
          simple_sram_write_req = 1'b0;
          simple_sram_done      = 1'b1;
          simple_fifo_pop       = 1'b0;
        end
        default: begin
          rw_sm_nxt             = {RW_SM_SIZE{1'bx}};
          simple_sram_read_req  = 1'bx;
          simple_sram_write_req = 1'bx;
          simple_sram_done      = 1'bx;
          simple_fifo_pop       = 1'bx;
        end
      endcase
    end
    RW_WRITE: begin
      case (rd_wr_done)
        1'b0: begin
          rw_sm_nxt             = RW_WRITE;
          simple_sram_read_req  = 1'b0;
          simple_sram_write_req = 1'b0;
          simple_sram_done      = 1'b0;
          simple_fifo_pop       = 1'b0;
        end
        1'b1: begin
          rw_sm_nxt             = RW_DONE;
          simple_sram_read_req  = 1'b0;
          simple_sram_write_req = 1'b1;
          simple_sram_done      = 1'b1;
          simple_fifo_pop       = 1'b0;
        end
        default: begin
          rw_sm_nxt             = {RW_SM_SIZE{1'bx}};
          simple_sram_read_req  = 1'bx;
          simple_sram_write_req = 1'bx;
          simple_sram_done      = 1'bx;
          simple_fifo_pop       = 1'bx;
        end
      endcase
    end
    RW_DONE: begin
      rw_sm_nxt             = RW_IDLE;
      simple_sram_read_req  = 1'b0;
      simple_sram_write_req = 1'b0;
      simple_sram_done      = 1'b0;
      simple_fifo_pop       = 1'b1;
    end
    default: begin
      rw_sm_nxt             = {RW_SM_SIZE{1'bx}};
      simple_sram_read_req  = 1'bx;
      simple_sram_write_req = 1'bx;
      simple_sram_done      = 1'bx;
      simple_fifo_pop       = 1'bx;
    end
  endcase
end


assign write_check = shdw_ctlr_rw_i && shdw_ctlr_chk_need_i &&
  (shdw_ctlr_chk_type_i == CHECK_RWE_DATA ||
    shdw_ctlr_chk_type_i == CHECK_RWE_MPL);

assign lock_write_req = (FW_LDE_LVL == 2) ?
  shdw_ctlr_acc_valid_r ? shdw_ctlr_rw_i && shdw_ctlr_chk_need_i &&
  !(shdw_ctlr_wr_rsp_pend_i && shdw_ctlr_cmp_pwr_st_i[shdw_ctlr_fc_id_i]) &&
  (shdw_ctlr_chk_type_i == CHECK_RWE_DATA ||
    shdw_ctlr_chk_type_i == CHECK_RWE_MPL ||
    shdw_ctlr_chk_type_i == CHECK_RWE_EN ||
    shdw_ctlr_chk_type_i == CHECK_RWE_LOCK) : 1'b0 : 1'b0;

assign lock_write_ok = !sram_read_data[0];

assign chk_write_req = shdw_ctlr_acc_valid_r ? shdw_ctlr_rw_i &&
  !lock_write_req && shdw_ctlr_chk_need_i &&
  !(shdw_ctlr_wr_rsp_pend_i && shdw_ctlr_cmp_pwr_st_i[shdw_ctlr_fc_id_i]) &&
  (shdw_ctlr_chk_type_i == CHECK_RWE_DATA ||
    shdw_ctlr_chk_type_i == CHECK_RWE_MPL) : lock_write_chk_req;

assign wr_chk_ok = (wr_chk_sm_r == WR_CHK_RGN_DONE) ? !sram_read_data[0] :
  (wr_chk_sm_r == WR_CHK_MPE_DONE) ? !mpe_en_bit :
  !mpe_en_bit;

always @* begin
  mpe_en_bit = 1'b1;

  if (shdw_ctlr_mpe_i[0]) begin
    mpe_en_bit = sram_read_data[0];
  end
  else if (shdw_ctlr_mpe_i[1]) begin
    mpe_en_bit = sram_read_data[1];
  end
  else if (shdw_ctlr_mpe_i[2]) begin
    mpe_en_bit = sram_read_data[2];
  end
  else if (shdw_ctlr_mpe_i[3]) begin
    mpe_en_bit = sram_read_data[3];
  end

end

assign simple_write_req = shdw_ctlr_acc_valid_r ? shdw_ctlr_rw_i &&
  !lock_write_req && !chk_write_req :
  (lock_simple_write || wr_chk_simple_write) && !shdw_ctlr_fixed_i;

assign rgn_st_read_req = shdw_ctlr_acc_valid_r ? !shdw_ctlr_rw_i &&
  shdw_ctlr_rd_rgn_st_i : 1'b0;

assign simple_read_req  = shdw_ctlr_acc_valid_r ? !shdw_ctlr_rw_i &&
  !rgn_st_read_req : 1'b0;


assign sram_read_req = simple_sram_read_req || lock_sram_read_req ||
  wr_chk_sram_read_req || rgn_st_sram_read_req;
assign sram_acc_done = simple_sram_done || lock_sram_done ||
  wr_chk_sram_done || rgn_st_sram_done;
assign sram_write_req = simple_sram_write_req;

assign fifo_pop_cfg_acc = simple_fifo_pop || lock_fifo_pop ||
  wr_chk_fifo_pop || rgn_st_fifo_pop;
assign fifo_push_cfg_acc = sram_rw_fifo_push;
assign fifo_datain_cfg_acc = shdw_ctlr_sram_data_i;

assign sram_addr_cfg_acc = shdw_ctlr_sram_row_i;
assign sram_cenn_cfg_acc = sram_rw_cenn;
assign sram_wenn_cfg_acc = sram_rw_wenn;
assign sram_data_cfg_acc = sram_write_data;

always @* begin
  sram_column_num = shdw_ctlr_sram_col_i;

  if (lock_sm_r == LOCK_DONE) begin
    sram_column_num = shdw_ctlr_rgn_lctrl_col_i;
  end
  else if (wr_chk_sm_r == WR_CHK_RGN_DONE) begin
    sram_column_num = shdw_ctlr_rgn_ctrl0_col_i;
  end
  else if (wr_chk_sm_r == WR_CHK_MPE_DONE) begin
    sram_column_num = shdw_ctlr_rgn_ctrl1_col_i;
  end
  else if (rd_st_sm_r == RD_ST_MPE) begin
    sram_column_num = shdw_ctlr_rgn_ctrl0_col_i;
  end
  else if (rd_st_sm_r == RD_ST_DONE) begin
    sram_column_num = shdw_ctlr_rgn_ctrl1_col_i;
  end

end

assign shdw_ctlr_prot_block_o_int = (sram_rw_sm_r != SRAM_RW_IDLE) ||
  acc_valid || wr_pend_r;

assign op1_lock = shdw_ctlr_rgn_lctrl_op1_i;
assign op2_lock = shdw_ctlr_rgn_lctrl_op2_i;
assign op1_rgn_en = shdw_ctlr_rgn_ctrl0_op1_i;
assign op2_rgn_en = shdw_ctlr_rgn_ctrl0_op2_i;
assign op1_mpe_en = shdw_ctlr_rgn_ctrl1_op1_i;
assign op2_mpe_en = shdw_ctlr_rgn_ctrl1_op2_i;

assign add_en_acc = lock_write_req || wr_chk_rgn_en || wr_chk_mpe_en ||
  rgn_st_read_req || (rd_st_sm_r == RD_ST_EN);

always @* begin
  op1_acc = {LOG2_SRAM_SIZE{1'b0}};
  op2_acc = {LOG2_SRAM_SIZE{1'b0}};

  if (lock_write_req) begin
    op1_acc = op1_lock;
    op2_acc = op2_lock;
  end
  else if (wr_chk_rgn_en || rgn_st_read_req) begin
    op1_acc = op1_rgn_en;
    op2_acc = op2_rgn_en;
  end
  else if (wr_chk_mpe_en || (rd_st_sm_r == RD_ST_EN)) begin
    op1_acc = op1_mpe_en;
    op2_acc = op2_mpe_en;
  end

end



always @* begin
  reg_size_int = shdw_ctlr_reg_size_i;

  if (lock_sm_r == LOCK_DONE) begin
    reg_size_int = 6'h1;
  end
  else if (wr_chk_sm_r == WR_CHK_RGN_DONE) begin
    reg_size_int = 6'h1;
  end
  else if (wr_chk_sm_r == WR_CHK_MPE_DONE) begin
    reg_size_int = 6'h4;
  end
  else if (rd_st_sm_r == RD_ST_MPE) begin
    reg_size_int = 6'h1;
  end
  else if (rd_st_sm_r == RD_ST_DONE) begin
    reg_size_int = 6'h4;
  end

end

always @* begin
  case (reg_size_int)
    6'h1: begin
      sram_write_data_int = fifo_dataout;
      sram_read_data_int  = {SRAM_WIDTH{1'b0}};
      for (size1=0; size1<SRAM_WIDTH; size1=size1+1) begin
        if (sram_column_num == size1) begin
          sram_write_data_int[size1] = shdw_ctlr_wr_data_i[0];
          sram_read_data_int[0] = fifo_dataout[size1];
        end
      end
    end
    6'h3: begin
      sram_write_data_int = {fifo_dataout[FIFO_WIDTH-1:3], shdw_ctlr_wr_data_i[2:0]};
      sram_read_data_int = {{SRAM_WIDTH-3{1'b0}}, fifo_dataout[2:0]};
    end
    6'h4: begin
      sram_write_data_int = fifo_dataout;
      sram_read_data_int  = {SRAM_WIDTH{1'b0}};
      for (size4=0; size4<SRAM_WIDTH/4; size4=size4+1) begin
        if (sram_column_num == size4) begin
          sram_write_data_int[4*(size4+1)-1 -: 4] = shdw_ctlr_wr_data_i[3:0];
          sram_read_data_int[3:0] = fifo_dataout[4*(size4+1)-1 -: 4];
        end
      end
    end
    6'h7: begin
      sram_write_data_int = {fifo_dataout[FIFO_WIDTH-1:7], shdw_ctlr_wr_data_i[6:0]};
      sram_read_data_int = {{SRAM_WIDTH-7{1'b0}}, fifo_dataout[6:0]};
    end
    6'h8: begin
      sram_write_data_int = fifo_dataout;
      sram_read_data_int  = {SRAM_WIDTH{1'b0}};
      for (size8=0; size8<SRAM_WIDTH/8; size8=size8+1) begin
        if (sram_column_num == size8) begin
          sram_write_data_int[8*(size8+1)-1 -: 8] = shdw_ctlr_wr_data_i[7:0];
          sram_read_data_int[7:0] = fifo_dataout[8*(size8+1)-1 -: 8];
        end
      end
    end
    6'hD: begin
      sram_write_data_int = fifo_dataout;
      sram_read_data_int  = {SRAM_WIDTH{1'b0}};
      for (size13=0; size13<SRAM_WIDTH/13; size13=size13+1) begin
        if (sram_column_num == size13) begin
          sram_write_data_int[13*(size13+1)-1 -: 13] = shdw_ctlr_wr_data_i[12:0];
          sram_read_data_int[12:0] = fifo_dataout[13*(size13+1)-1 -: 13];
        end
      end
    end
    6'h10: begin
      sram_write_data_int = fifo_dataout;
      sram_read_data_int  = {SRAM_WIDTH{1'b0}};
      for (size16=0; size16<SRAM_WIDTH/16; size16=size16+1) begin
        if (sram_column_num == size16) begin
          sram_write_data_int[16*(size16+1)-1 -: 16] = shdw_ctlr_wr_data_i[15:0];
          sram_read_data_int[15:0] = fifo_dataout[16*(size16+1)-1 -: 16];
        end
      end
    end
    6'h12: begin
      sram_write_data_int = fifo_dataout;
      sram_read_data_int  = {SRAM_WIDTH{1'b0}};
      for (size18=0; size18<SRAM_WIDTH/18; size18=size18+1) begin
        if (sram_column_num == size18) begin
          sram_write_data_int[18*(size18+1)-1 -: 18] = shdw_ctlr_wr_data_i[17:0];
          sram_read_data_int[17:0] = fifo_dataout[18*(size18+1)-1 -: 18];
        end
      end
    end
    6'h1B: begin
      sram_write_data_int = fifo_dataout;
      sram_read_data_int  = {SRAM_WIDTH{1'b0}};
      for (size27=0; size27<SRAM_WIDTH/27; size27=size27+1) begin
        if (sram_column_num == size27) begin
          sram_write_data_int[27*(size27+1)-1 -: 27] = shdw_ctlr_wr_data_i[26:0];
          sram_read_data_int[26:0] = fifo_dataout[27*(size27+1)-1 -: 27];
        end
      end
    end
    6'h20: begin
      sram_write_data_int = fifo_dataout;
      sram_read_data_int  = {SRAM_WIDTH{1'b0}};
      for (size32=0; size32<SRAM_WIDTH/32; size32=size32+1) begin
        if (sram_column_num == size32) begin
          sram_write_data_int[32*(size32+1)-1 -: 32] = shdw_ctlr_wr_data_i[31:0];
          sram_read_data_int[31:0] = fifo_dataout[32*(size32+1)-1 -: 32];
        end
      end
    end
    default: begin
      sram_write_data_int = {SRAM_WIDTH{1'bx}};
      sram_read_data_int  = {SRAM_WIDTH{1'bx}};
    end
  endcase
end

generate
  if ((FW_MAX_MST_ID_WIDTH != 32) && (FW_MAX_MST_ID_WIDTH != 27) &&
      (FW_MAX_MST_ID_WIDTH != 18) && (FW_MAX_MST_ID_WIDTH != 16) &&
      (FW_MAX_MST_ID_WIDTH != 13) && (FW_MAX_MST_ID_WIDTH != 8)  &&
      (FW_MAX_MST_ID_WIDTH != 7)  && (FW_MAX_MST_ID_WIDTH != 4)  &&
      (FW_MAX_MST_ID_WIDTH != 3)  && (FW_MAX_MST_ID_WIDTH != 1)) begin : MID_COL_SEL

    reg [SRAM_WIDTH-1:0] sram_write_data_mid_int;
    reg [SRAM_WIDTH-1:0] sram_read_data_mid_int;
    reg                  sram_rw_sel_int;

    always @* begin
      sram_rw_sel_int = 1'b1;
      sram_write_data_mid_int = fifo_dataout;
      sram_read_data_mid_int  = {SRAM_WIDTH{1'b0}};

      if (reg_size_int == FW_MAX_MST_ID_WIDTH) begin
        sram_rw_sel_int = 1'b0;
        for (sizemid=0; sizemid<SRAM_WIDTH/FW_MAX_MST_ID_WIDTH; sizemid=sizemid+1) begin
          if (sram_column_num == sizemid) begin
            sram_write_data_mid_int[FW_MAX_MST_ID_WIDTH*(sizemid+1)-1 -: FW_MAX_MST_ID_WIDTH] = shdw_ctlr_wr_data_i[FW_MAX_MST_ID_WIDTH-1:0];
            sram_read_data_mid_int[FW_MAX_MST_ID_WIDTH-1:0] = fifo_dataout[FW_MAX_MST_ID_WIDTH*(sizemid+1)-1 -: FW_MAX_MST_ID_WIDTH];
          end
        end
      end

    end

    assign sram_write_data_mid = sram_write_data_mid_int;
    assign sram_read_data_mid  = sram_read_data_mid_int;
    assign sram_rw_sel         = sram_rw_sel_int;
  end
  else begin : NO_MID_COL_SEL
    assign sram_write_data_mid = {SRAM_WIDTH{1'b0}};
    assign sram_read_data_mid  = {SRAM_WIDTH{1'b0}};
    assign sram_rw_sel         = 1'b1;
  end
endgenerate

assign sram_write_data = sram_rw_sel ? sram_write_data_int : sram_write_data_mid;
assign sram_read_data  = sram_rw_sel ? sram_read_data_int  : sram_read_data_mid;


generate
  if (FW_SRE_LVL == 1) begin : SRE_1_RGN
    reg [(RWE_CTRL_WIDTH*FW_NUM_FC)-1:0] rgn_pntr_r;
    reg [(RWE_CTRL_WIDTH*FW_NUM_FC)-1:0] rgn_pntr_nxt;

    always @* begin
      rgn_pntr_nxt = rgn_pntr_r;
      for (rgn_num=0; rgn_num<FW_NUM_FC; rgn_num=rgn_num+1) begin
        if (shdw_ctlr_rgn_en_i[rgn_num]) begin
          rgn_pntr_nxt[rgn_num*RWE_CTRL_WIDTH +: RWE_CTRL_WIDTH] = shdw_ctlr_rgn_i;
        end
      end
    end

    always @ (posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        rgn_pntr_r <= {RWE_CTRL_WIDTH*FW_NUM_FC{1'b0}};
      end
      else begin
        if (shdw_ctlr_lpi_default_state_i) begin
          rgn_pntr_r <= {RWE_CTRL_WIDTH*FW_NUM_FC{1'b0}};
        end
        else if (|shdw_ctlr_rgn_en_i) begin
          rgn_pntr_r <= rgn_pntr_nxt;
        end
      end
    end

    assign rgn_pntr = rgn_pntr_r;

  end
  else begin: SRE_0_RGN
    assign rgn_pntr = {RWE_CTRL_WIDTH*FW_NUM_FC{1'b0}};
  end
endgenerate



generate
  if (FW_SRE_LVL == 1) begin : SRE_1_WR_RST

    reg  [FW_NUM_FC-1:0] wr_after_reset_r;
    reg  [FW_NUM_FC-1:0] wr_after_reset_nxt;

    always @* begin
      wr_after_reset_nxt = wr_after_reset_r;
      for (fw_id_1=0; fw_id_1<FW_NUM_FC; fw_id_1=fw_id_1+1) begin
        if ((fw_id_1+1 == shdw_ctlr_fw_id_i) && simple_write_req) begin
          wr_after_reset_nxt[fw_id_1] = 1'b1;
        end
      end
    end

    always @ (posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        wr_after_reset_r <= {FW_NUM_FC{1'b0}};
      end
      else begin
        if (shdw_ctlr_lpi_default_state_i) begin
          wr_after_reset_r <= {FW_NUM_FC{1'b0}};
        end
        else if (simple_write_req && shdw_ctlr_rw_i) begin
          wr_after_reset_r <= wr_after_reset_nxt;
        end
      end
    end

    assign wr_after_reset = wr_after_reset_r;

  end
  else begin: SRE_0_WR_RST

    assign wr_after_reset = {FW_NUM_FC{1'b0}};

  end
endgenerate


generate
  if (FW_SRE_LVL == 1) begin : SRE_1_WR_DSC

    reg [FW_NUM_FC-1:0] wr_after_discon_r;
    reg [FW_NUM_FC-1:0] wr_after_discon_nxt;

    always @* begin
      wr_after_discon_nxt = wr_after_discon_r;
      for (fw_id_2=0; fw_id_2<FW_NUM_FC; fw_id_2=fw_id_2+1) begin
        if ((fw_id_2+1 == shdw_ctlr_fw_id_i) && simple_write_req) begin
          wr_after_discon_nxt[fw_id_2] = 1'b1;
        end
        else if ((fw_id_2 == shdw_ctlr_restore_req_id_i) && shdw_ctlr_restore_done_o_int) begin
          wr_after_discon_nxt[fw_id_2] = 1'b0;
        end
        else if ((fw_id_2 == shdw_ctlr_con_fw_id_i) && shdw_ctlr_con_valid_i) begin
          wr_after_discon_nxt[fw_id_2] = 1'b0;
        end
      end
    end

    always @ (posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        wr_after_discon_r <= {FW_NUM_FC{1'b0}};
      end
      else begin
        if (shdw_ctlr_lpi_default_state_i) begin
          wr_after_discon_r <= {FW_NUM_FC{1'b0}};
        end
        else if ((simple_write_req && shdw_ctlr_rw_i && !shdw_ctlr_cmp_pwr_st_i[shdw_ctlr_fc_id_i]) |
            shdw_ctlr_restore_done_o_int | shdw_ctlr_con_valid_i) begin
          wr_after_discon_r <= wr_after_discon_nxt;
        end
      end
    end

    assign wr_after_discon = wr_after_discon_r;

  end
  else begin: SRE_0_WR_DSC

    assign wr_after_discon = {FW_NUM_FC{1'b0}};

  end
endgenerate


assign shdw_ctlr_restore_done_o = shdw_ctlr_restore_done_o_int;

assign shdw_ctlr_fw_id_o              = shdw_ctlr_fc_id_i;
assign shdw_ctlr_restore_data_o       = shdw_ctlr_restore_data_o_int;
assign shdw_ctlr_first_restore_data_o = shdw_ctlr_first_restore_data_o_int;
assign shdw_ctlr_restore_valid_o      = shdw_ctlr_restore_valid_o_int;
assign shdw_ctlr_prot_block_o         = shdw_ctlr_prot_block_o_int;
assign shdw_ctlr_us_last_pkt_o        = shdw_ctlr_us_last_pkt_o_int;

assign shdw_ctlr_clk_busy_o       = shdw_ctlr_clk_busy_o_int;
assign shdw_ctlr_restore_fw_id_o  = shdw_ctlr_restore_fw_id_o_int;

assign shdw_ctlr_sram_addr_o  = shdw_ctlr_sram_addr;
assign shdw_ctlr_sram_cenn_o  = shdw_ctlr_sram_cenn;
assign shdw_ctlr_sram_data_o  = shdw_ctlr_sram_data;
assign shdw_ctlr_sram_wenn_o  = shdw_ctlr_sram_wenn;

assign shdw_ctlr_add_op1_o = add_en_acc ? op1_acc : op1_int;
assign shdw_ctlr_add_op2_o = add_en_acc ? op2_acc : op2_int;
assign shdw_ctlr_add_en_o  = add_en_int || add_en_acc;

assign shdw_ctlr_rgn_o = rgn_pntr;

assign shdw_ctlr_wr_aft_rst_o = wr_after_reset;
assign shdw_ctlr_wr_aft_dsc_o = wr_after_discon;

assign shdw_ctlr_wr_rsp_o = lock_write_tamper || wr_chk_err;
assign shdw_ctlr_wr_tamp_o = lock_write_tamper;
assign shdw_ctlr_wr_valid_o =
  ((rw_sm_r == RW_DONE) && shdw_ctlr_rw_i &&
  (!shdw_ctlr_cmp_pwr_st_i[shdw_ctlr_fc_id_i]))
    ||
  ((lock_sm_r == LOCK_DONE) && shdw_ctlr_rw_i && (!lock_write_ok || (shdw_ctlr_fixed_i && !write_check)))
    ||
  (((wr_chk_sm_r == WR_CHK_RGN_DONE) || (wr_chk_sm_r == WR_CHK_MPE_DONE)) &&
  shdw_ctlr_rw_i && (!wr_chk_ok || shdw_ctlr_fixed_i));
assign shdw_ctlr_cfg_valid_o = shdw_ctlr_rw_i &&
  shdw_ctlr_cmp_pwr_st_i[shdw_ctlr_fc_id_i] && simple_write_req &&
  shdw_ctlr_chk_need_i && !shdw_ctlr_fixed_i && !shdw_ctlr_wr_rsp_pend_i;

assign shdw_ctlr_rd_data_o  = (rd_st_sm_r == RD_ST_DONE) ?
  {{REG_DATA_WIDTH-5{1'b0}}, rgn_st_rd_data} :
  sram_read_data[REG_DATA_WIDTH-1:0];
assign shdw_ctlr_rd_valid_o = ((rw_sm_r == RW_DONE) && !shdw_ctlr_rw_i) ||
  ((rd_st_sm_r == RD_ST_DONE) && !shdw_ctlr_rw_i);

assign sram_datao = shdw_ctlr_sram_data_i;

endmodule

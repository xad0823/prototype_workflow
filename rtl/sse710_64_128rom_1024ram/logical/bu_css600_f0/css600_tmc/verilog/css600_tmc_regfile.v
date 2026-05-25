//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2020 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Sub-module of css600_tmc
//
//----------------------------------------------------------------------------


module css600_tmc_regfile
#(
  parameter TMC_CONFIG     = 0,
  parameter MEM_SIZE       = 31'h0000_0080,
  parameter WBUFFER_DEPTH  = 1,
  parameter WB_DATA_WIDTH  = 64,
  parameter ATB_DATA_WIDTH = 64,
  parameter AXI_ADDR_WIDTH = 40,
  parameter MEM_BYTE_ADDR_WIDTH = 9,
  parameter MEM_ADDR_WIDTH = 7,
  parameter TMC_TRG_WIDTH  = 7,
  parameter ATBYTES_WIDTH  = 2,
  parameter ITATBDATA0_WIDTH = 5,
  parameter FILL_LEVEL_WIDTH = 8
)
(
  input  wire                           clk,
  input  wire                           cg_en,
  input  wire                           reset_n,

  input  wire                           psel_s,
  input  wire                           penable_s,
  input  wire [11:0]                    paddr_s,
  input  wire                           pwrite_s,
  input  wire [31:0]                    pwdata_s,
  output reg  [31:0]                    prdata_s,
  output reg                            pready_s,
  output wire                           pslverr_s,

  input  wire                           dbgen,
  input  wire                           spiden,

  output wire                           dbgen_q,
  output wire                           spiden_q,

  output wire [30:0]                    rsz,
  output reg                            ctl_trace_capt_en,
  output reg                            tmc_ready,
  output wire                           circ_buf_mode,
  output wire                           hw_fifo_mode,
  output wire                           sw_fifo_mode2,
  output reg                            stall_on_stop,
  output wire [FILL_LEVEL_WIDTH-2:0]    buf_wm,
  output wire [3:0]                     wr_burst_len,
  output wire [3:0]                     axictl_wcache,
  output wire [3:0]                     axictl_rcache,
  output wire [1:0]                     axictl_prot_ctrl,
  output wire [MEM_BYTE_ADDR_WIDTH-1:0] dba,
  output wire                           ffcr_drain_buffer_en,
  output wire                           ffcr_embed_flush_masked,
  output wire                           ffcr_stop_on_trig_evt_masked,
  output reg                            ffcr_stop_on_fl,
  output wire                           ffcr_trig_on_fl_masked,
  output wire                           ffcr_trig_on_trig_evt_masked,
  output wire                           ffcr_trig_on_trigin_masked,
  output reg                            ffcr_flush_man,
  output wire                           ffcr_flsh_on_trig_evt_masked,
  output reg                            ffcr_flsh_on_flshin,
  output reg                            ffcr_en_trig_ins,
  output wire                           ffcr_en_formatting_masked,
  output wire                           pscr_embed_sync,
  output reg [4:0]                      pscr_pscount,

  output wire                           sts_full_wr_en,
  output wire                           rrp_wr_en,
  output wire                           rwp_wr_en,
  output wire                           trg_wr_en,
  output wire                           rrp_hi_wr_en,
  output wire                           rwp_hi_wr_en,
  output wire                           rurp_wr_en,
  output reg  [31:0]                    apb_wdata_p,
  output wire                           unprog_sts,
  output wire                           unprog_rrp,
  output wire                           unprog_rwp,
  output reg                            unprog_trg,
  output wire                           unprog_rrphi,
  output wire                           unprog_rwphi,
  output wire                           ptr_prog,

  input  wire                           mem_err,
  input  wire                           sts_triggered,
  input  wire                           trace_mem_empty,
  input  wire                           sts_full,
  input  wire [MEM_BYTE_ADDR_WIDTH-1:0] rrp,
  input  wire [MEM_BYTE_ADDR_WIDTH-1:0] rwp,
  input  wire [TMC_TRG_WIDTH-1:0]       trg,
  input  wire [FILL_LEVEL_WIDTH-1:0]    l_buf_level,
  input  wire [FILL_LEVEL_WIDTH-1:0]    c_buf_level,
  input  wire                           ft_stopped,
  input  wire                           flush_fsm_busy,

  output reg                            itctrl_ime,
  output wire                           integ_mode_entry,
  output wire                           it_atb_m_data_0_wr_en,
  output wire                           it_atb_m_ctr_1_wr_en,
  output wire                           it_atb_m_ctr_0_wr_en,
  output wire                           it_evt_intr_wr_en,
  output wire                           it_tr_fl_in_rd_en,
  output wire                           it_atb_ctr_2_wr_en,
  input  wire                           syncreq_m,
  input  wire                           afvalid_m,
  input  wire                           atready_m,
  input  wire                           it_flushin,
  input  wire                           it_trigin,
  input  wire [ITATBDATA0_WIDTH-1:0]    it_atb_data_0,
  input  wire [6:0]                     it_atids,
  input  wire [ATBYTES_WIDTH-1:0]       it_atbytess,
  input  wire                           it_atwakeups,
  input  wire                           it_afreadys,
  input  wire                           it_atvalids,

  output wire                           rrd_rd_req,
  input  wire                           rrd_rd_ack,
  input  wire [31:0]                    rrd_rd_data,

  output wire                           rwd_wr_req,
  output wire [31:0]                    rwd_wr_data,
  input  wire                           wb_ready,

  output wire                           ctl_trace_capt_en_rise,
  output wire                           ctl_trace_capt_en_rise_pre,
  output wire                       nxt_tmc_enabled,
  output wire                           tmc_enabled,
  output wire                           tmc_abort,
  output wire                           unformatter_en,
  output wire                           unformatter_stop,
  output wire                           atbm_flush_mon,
  output reg                            acqcomp,
  output wire                           l_buf_level_rd_done,
  output wire                           apbreadfifo_clr,
  output wire                           mem_err_clr,

  input  wire                           flush_man_clr,
  input  wire                           wb_empty,
  input  wire                           unformatter_empty,
  input  wire                           axi_intf_ready,
  input  wire                           flushcomp,
  input  wire                           nxt_afreadym,
  input  wire                           afready_m,

  input  wire                           dev_run,
  input  wire                           lp_done,

  output wire                           int_clk_en,

  input  wire [3:0]                     revand
);

  `include "css600_tmc_localparams.v"

  localparam REGV_DEVID1_RMC         = 1'b1;
  localparam REGV_DEVID_CACHETYPE    = 2'b00;
  localparam REGV_DEVID_MODES        = (TMC_CONFIG == ETS) ? 3'b010 :
                                       (TMC_CONFIG == ETR) ? 3'b001 : 3'b000;
  localparam REGV_DEVID_NOSCAT       = (TMC_CONFIG == ETR) ? 1'b1 : 1'b0;

  localparam REGV_DEVID_AW           = (TMC_CONFIG != ETR) ? 7'h00 :
                                       ((AXI_ADDR_WIDTH == 32) ? 7'h20 :
                                        (AXI_ADDR_WIDTH == 40) ? 7'h28 :
                                        (AXI_ADDR_WIDTH == 44) ? 7'h2C :
                                        (AXI_ADDR_WIDTH == 48) ? 7'h30 :
                                                                 7'h34);

  localparam REGV_DEVID_AW_VALID     = ((TMC_CONFIG == ETR) || (TMC_CONFIG == ETS)) ? 1'b1 : 1'b0;

  localparam REGV_DEVID_WBUF_DEPTH   = (WBUFFER_DEPTH == 1)  ? 3'b000 :
                                       (WBUFFER_DEPTH == 2)  ? 3'b001 :
                                       (WBUFFER_DEPTH == 4)  ? 3'b010 :
                                       (WBUFFER_DEPTH == 8)  ? 3'b011 :
                                       (WBUFFER_DEPTH == 16) ? 3'b100 : 3'b101;

  localparam REGV_DEVID_MEMWIDTH     = (WB_DATA_WIDTH == 32)  ? 3'b010 :
                                       (WB_DATA_WIDTH == 64)  ? 3'b011 :
                                       (WB_DATA_WIDTH == 128) ? 3'b100 : 3'b101;

  localparam REGV_DEVID_CONFIGTYPE   = (TMC_CONFIG == ETB) ? 2'b00 :
                                       (TMC_CONFIG == ETR) ? 2'b01 :
                                       (TMC_CONFIG == ETF) ? 2'b10 : 2'b11;

  localparam REGV_DEVID_CLKSCHEME    = 1'b0;
  localparam REGV_DEVID_ATBPORTCOUNT = 5'h00;

  localparam REGV_DEVTYPE_SUB        = (TMC_CONFIG != ETF) ? 4'h2 : 4'h3;
  localparam REGV_DEVTYPE_MAJOR      = (TMC_CONFIG != ETF) ? 4'h1 : 4'h2;

  localparam REGV_PIDR0_PART0        = (TMC_CONFIG == ETB) ? 8'hE9 :
                                       (TMC_CONFIG == ETF) ? 8'hEA : 8'hE8;
  localparam REGV_PIDR1_DES0         = 4'hB;
  localparam REGV_PIDR1_PART1        = 4'h9;
  localparam REGV_PIDR2_REVISION     = 4'h5;
  localparam REGV_PIDR2_JEDEC        = 1'b1;
  localparam REGV_PIDR2_DES1         = 3'h3;
  localparam REGV_PIDR3_CMOD         = 4'h0;
  localparam REGV_PIDR4_SIZE         = 4'h0;
  localparam REGV_PIDR4_DES2         = 4'h4;

  localparam REGV_CIDR0_PRMBL0       = 8'h0D;
  localparam REGV_CIDR1_CLASS        = 4'h9;
  localparam REGV_CIDR1_PRMBL1       = 4'h0;
  localparam REGV_CIDR2_PRMBL2       = 8'h05;
  localparam REGV_CIDR3_PRMBL3       = 8'hB1;

  localparam WBUFFER_DEPTH_BIN = (WBUFFER_DEPTH == 4) ? 4'b0011 :
                                 (WBUFFER_DEPTH == 8) ? 4'b0111 : 4'b1111;

  localparam RSZ_LSB = (WB_DATA_WIDTH == 32) ? 0 :
                       (WB_DATA_WIDTH == 64) ? 1 : 2;

  localparam HI_ADDR_WIDTH = (AXI_ADDR_WIDTH - 32);

  localparam DBA_PAD = 4;


  wire rsz_sel;
  wire sts_sel;
  wire rrd_sel;
  wire rrp_sel;
  wire rwp_sel;
  wire trg_sel;
  wire ctl_sel;
  wire rwd_sel;
  wire mode_sel;
  wire l_buf_level_sel;
  wire c_buf_level_sel;
  wire buf_wm_sel;
  wire rrp_hi_sel;
  wire rwp_hi_sel;
  wire axi_ctl_sel;
  wire dba_lo_sel;
  wire dba_hi_sel;
  wire rurp_sel;
  wire ffsr_sel;
  wire ffcr_sel;
  wire pscr_sel;
  wire it_atb_m_data_0_sel;
  wire it_atb_m_ctr_2_sel;
  wire it_atb_m_ctr_1_sel;
  wire it_atb_m_ctr_0_sel;
  wire it_evt_intr_sel;
  wire it_tr_fl_in_sel;
  wire it_atb_data_0_sel;
  wire it_atb_ctr_2_sel;
  wire it_atb_ctr_1_sel;
  wire it_atb_ctr_0_sel;
  wire it_ctrl_sel;
  wire claimset_sel;
  wire claimclr_sel;
  wire authstatus_sel;
  wire devid1_sel;
  wire devid_sel;
  wire devtype_sel;
  wire [4:0] pidr_sel;
  wire [3:0] cidr_sel;
  wire rsz_sel_p;
  wire sts_sel_p;
  wire rrp_sel_p;
  wire rwp_sel_p;
  wire rrp_hi_sel_p;
  wire rwp_hi_sel_p;
  wire axi_ctl_sel_p;
  wire rurp_sel_p;

  wire rsz_wr_en;
  wire ctl_wr_en;
  wire mode_wr_en;
  wire buf_wm_wr_en;
  wire axi_ctl_wr_en;
  wire dba_lo_wr_en;
  wire dba_hi_wr_en;
  wire ffcr_wr_en;
  wire ffcr_wr_en_bits01;
  wire ffcr_flush_man_wr_en;
  wire pscr_wr_en;
  wire it_ctrl_wr_en;
  wire claimset_wr_en;
  wire claimclr_wr_en;

  wire rsz_rd_en;
  wire sts_rd_en;
  wire rrp_rd_en;
  wire rwp_rd_en;
  wire trg_rd_en;
  wire ctl_rd_en;
  wire mode_rd_en;
  wire l_buf_level_rd_en;
  wire c_buf_level_rd_en;
  wire buf_wm_rd_en;
  wire rrp_hi_rd_en;
  wire rwp_hi_rd_en;
  wire axi_ctl_rd_en;
  wire dba_lo_rd_en;
  wire dba_hi_rd_en;
  wire ffsr_rd_en;
  wire ffcr_rd_en;
  wire pscr_rd_en;
  wire it_atb_m_ctr_2_rd_en;
  wire it_atb_data_0_rd_en;
  wire it_atb_ctr_1_rd_en;
  wire it_atb_ctr_0_rd_en;
  wire it_ctrl_rd_en;
  wire claimset_rd_en;
  wire claimclr_rd_en;
  wire authstatus_rd_en;
  wire devid1_rd_en;
  wire devid_rd_en;
  wire devtype_rd_en;
  wire [4:0] pidr_rd_en;
  wire [3:0] cidr_rd_en;

  wire [31:0] rsz_rd_data;
  wire [31:0] sts_rd_data;
  wire [31:0] rrp_rd_data;
  wire [31:0] rwp_rd_data;
  wire [31:0] trg_rd_data;
  wire [31:0] ctl_rd_data;
  wire [31:0] mode_rd_data;
  wire [31:0] l_buf_level_rd_data;
  wire [31:0] c_buf_level_rd_data;
  wire [31:0] buf_wm_rd_data;
  wire [31:0] rrp_hi_rd_data;
  wire [31:0] rwp_hi_rd_data;
  wire [31:0] axi_ctl_rd_data;
  wire [31:0] dba_lo_rd_data;
  wire [31:0] dba_hi_rd_data;
  wire [31:0] ffsr_rd_data;
  wire [31:0] ffcr_rd_data;
  wire [31:0] pscr_rd_data;
  wire [31:0] it_atb_m_ctr_2_rd_data;
  wire [31:0] it_tr_fl_in_rd_data;
  wire [31:0] it_atb_data_0_rd_data;
  wire [31:0] it_atb_ctr_1_rd_data;
  wire [31:0] it_atb_ctr_0_rd_data;
  wire [31:0] it_ctrl_rd_data;
  wire [31:0] claimset_rd_data;
  wire [31:0] claimclr_rd_data;
  wire [31:0] authstatus_rd_data;
  wire [31:0] devid1_rd_data;
  wire [31:0] devid_rd_data;
  wire [31:0] devtype_rd_data;
  wire [31:0] pidr0_rd_data;
  wire [31:0] pidr1_rd_data;
  wire [31:0] pidr2_rd_data;
  wire [31:0] pidr3_rd_data;
  wire [31:0] pidr4_rd_data;
  wire [31:0] cidr0_rd_data;
  wire [31:0] cidr1_rd_data;
  wire [31:0] cidr2_rd_data;
  wire [31:0] cidr3_rd_data;

  wire        reg_access;
  wire        mem_access;
  wire        reg_write;
  wire        reg_read;
  wire        mem_write;
  wire        mem_read;

  wire        apb_pipe_we;
  wire [9:0]  apb_addr;

  wire        rrd_rd_en;
  wire        rwd_wr_en;
  wire        rrd_rd_deny;
  wire        rwd_wr_deny;
  wire        rwd_wr_valid;
  wire        rwd_wr_ack;
  wire        rrd_rdata_en;
  wire        rrd_rd_err;
  wire        nxt_penable_reconst;
  wire        apb_setup_normal;
  wire        apb_setup_wake;
  wire        apb_select;
  wire        state_en;
  wire        ft_empty;
  wire        mode_default;
  wire        sw_fifo_mode1;
  wire        nxt_tmc_ready;
  wire        acqcomp_func;
  wire        tmc_disabled;
  wire        nxt_ctl_trace_capt_en;
  wire        ctl_trace_capt_en_fall;
  wire        sts_triggered_masked;
  wire        nxt_ffcr_flush_man;
  wire [4:0]  nxt_pscr_pscount;
  wire        nxt_acqcomp;
  wire        prdata_we;
  wire [31:0] nxt_prdata;
  wire        nxt_pready;
  wire        nxt_rwd_wr_req_hold;
  wire [1:0]  mode;


  wire        unprog_trg_clr;
  wire        unprog_rsz;
  wire        unprog_rsz_init;
  wire        unprog_mode;
  wire        unprog_mode_init;
  wire        unprog_bufwm;
  wire        unprog_bufwm_init;
  wire        unprog_axictl;
  wire        unprog_axictl_init;
  wire        unprog_dbalo;
  wire        unprog_dbalo_init;
  wire        unprog_dbahi;
  wire        unprog_dbahi_init;

  wire [1:0] curr_state;
  reg  [1:0] nxt_state;
  reg        penable_reconst;
  reg        reg_write_p;
  reg  [9:0] apb_addr_p;
  reg        ctl_trace_capt_en_q;
  reg        tmc_enabled_r;
  reg        ffcr_embed_flush;
  reg        ffcr_stop_on_trig_evt;
  reg        ffcr_trig_on_fl;
  reg        ffcr_trig_on_trig_evt;
  reg        ffcr_trig_on_trigin;
  reg        ffcr_flsh_on_trig_evt;
  reg        ffcr_en_formatting;


  generate
    if (TMC_CONFIG == ETR)
      begin : gen_auth_reg
        reg dbgen_q_etr;
        reg spiden_q_etr;

        always @ (posedge clk or negedge reset_n)
        begin : s_auth
          if (!reset_n)
            begin
              dbgen_q_etr  <= 1'b0;
              spiden_q_etr <= 1'b0;
            end
          else if (cg_en)
            begin
              dbgen_q_etr  <= dbgen;
              spiden_q_etr <= spiden;
            end
        end

        assign dbgen_q  = dbgen_q_etr;
        assign spiden_q = spiden_q_etr;
      end
    else
      begin : dont_gen_auth_reg
        assign dbgen_q  = 1'b0;
        assign spiden_q = 1'b0;
      end
  endgenerate


  assign rsz_sel             = ({paddr_s[11:2],2'b00} == REGA_RSZ);
  assign sts_sel             = ({paddr_s[11:2],2'b00} == REGA_STS);
  assign rrd_sel             = ({paddr_s[11:2],2'b00} == REGA_RRD);
  assign rrp_sel             = ({paddr_s[11:2],2'b00} == REGA_RRP);
  assign rwp_sel             = ({paddr_s[11:2],2'b00} == REGA_RWP);
  assign trg_sel             = ({paddr_s[11:2],2'b00} == REGA_TRG);
  assign ctl_sel             = ({paddr_s[11:2],2'b00} == REGA_CTL);
  assign rwd_sel             = ({paddr_s[11:2],2'b00} == REGA_RWD);
  assign mode_sel            = ({paddr_s[11:2],2'b00} == REGA_MODE);
  assign l_buf_level_sel     = ({paddr_s[11:2],2'b00} == REGA_LBUFLEVEL);
  assign c_buf_level_sel     = ({paddr_s[11:2],2'b00} == REGA_CBUFLEVEL);
  assign buf_wm_sel          = ({paddr_s[11:2],2'b00} == REGA_BUFWM);
  assign rrp_hi_sel          = ({paddr_s[11:2],2'b00} == REGA_RRPHI);
  assign rwp_hi_sel          = ({paddr_s[11:2],2'b00} == REGA_RWPHI);
  assign axi_ctl_sel         = ({paddr_s[11:2],2'b00} == REGA_AXICTL);
  assign dba_lo_sel          = ({paddr_s[11:2],2'b00} == REGA_DBALO);
  assign dba_hi_sel          = ({paddr_s[11:2],2'b00} == REGA_DBAHI);
  assign rurp_sel            = ({paddr_s[11:2],2'b00} == REGA_RURP);
  assign ffsr_sel            = ({paddr_s[11:2],2'b00} == REGA_FFSR);
  assign ffcr_sel            = ({paddr_s[11:2],2'b00} == REGA_FFCR);
  assign pscr_sel            = ({paddr_s[11:2],2'b00} == REGA_PSCR);
  assign it_atb_m_data_0_sel = ({paddr_s[11:2],2'b00} == REGA_ITATBMDATA0);
  assign it_atb_m_ctr_2_sel  = ({paddr_s[11:2],2'b00} == REGA_ITATBMCTR2);
  assign it_atb_m_ctr_1_sel  = ({paddr_s[11:2],2'b00} == REGA_ITATBMCTR1);
  assign it_atb_m_ctr_0_sel  = ({paddr_s[11:2],2'b00} == REGA_ITATBMCTR0);
  assign it_evt_intr_sel     = ({paddr_s[11:2],2'b00} == REGA_ITEVTINTR);
  assign it_tr_fl_in_sel     = ({paddr_s[11:2],2'b00} == REGA_ITTRFLIN);
  assign it_atb_data_0_sel   = ({paddr_s[11:2],2'b00} == REGA_ITATBDATA0);
  assign it_atb_ctr_2_sel    = ({paddr_s[11:2],2'b00} == REGA_ITATBCTR2);
  assign it_atb_ctr_1_sel    = ({paddr_s[11:2],2'b00} == REGA_ITATBCTR1);
  assign it_atb_ctr_0_sel    = ({paddr_s[11:2],2'b00} == REGA_ITATBCTR0);
  assign it_ctrl_sel         = ({paddr_s[11:2],2'b00} == REGA_ITCTRL);
  assign claimset_sel        = ({paddr_s[11:2],2'b00} == REGA_CLAIMSET);
  assign claimclr_sel        = ({paddr_s[11:2],2'b00} == REGA_CLAIMCLR);
  assign authstatus_sel      = ({paddr_s[11:2],2'b00} == REGA_AUTHSTATUS);
  assign devid1_sel          = ({paddr_s[11:2],2'b00} == REGA_DEVID1);
  assign devid_sel           = ({paddr_s[11:2],2'b00} == REGA_DEVID);
  assign devtype_sel         = ({paddr_s[11:2],2'b00} == REGA_DEVTYPE);
  assign pidr_sel[0]         = ({paddr_s[11:2],2'b00} == REGA_PID0);
  assign pidr_sel[1]         = ({paddr_s[11:2],2'b00} == REGA_PID1);
  assign pidr_sel[2]         = ({paddr_s[11:2],2'b00} == REGA_PID2);
  assign pidr_sel[3]         = ({paddr_s[11:2],2'b00} == REGA_PID3);
  assign pidr_sel[4]         = ({paddr_s[11:2],2'b00} == REGA_PID4);
  assign cidr_sel[0]         = ({paddr_s[11:2],2'b00} == REGA_CID0);
  assign cidr_sel[1]         = ({paddr_s[11:2],2'b00} == REGA_CID1);
  assign cidr_sel[2]         = ({paddr_s[11:2],2'b00} == REGA_CID2);
  assign cidr_sel[3]         = ({paddr_s[11:2],2'b00} == REGA_CID3);

  assign rsz_sel_p           = ({apb_addr_p,2'b00} == REGA_RSZ);
  assign sts_sel_p           = ({apb_addr_p,2'b00} == REGA_STS);
  assign rrp_sel_p           = ({apb_addr_p,2'b00} == REGA_RRP);
  assign rwp_sel_p           = ({apb_addr_p,2'b00} == REGA_RWP);
  assign rrp_hi_sel_p        = ({apb_addr_p,2'b00} == REGA_RRPHI);
  assign rwp_hi_sel_p        = ({apb_addr_p,2'b00} == REGA_RWPHI);
  assign axi_ctl_sel_p       = ({apb_addr_p,2'b00} == REGA_AXICTL);
  assign rurp_sel_p          = ({apb_addr_p,2'b00} == REGA_RURP);


  generate
    if (TMC_CONFIG == ETB)
      begin : gen_reg_acc_etb
        assign reg_access =       (rsz_sel | sts_sel | rrp_sel | rwp_sel |
                                   trg_sel | ctl_sel | mode_sel |
                                   l_buf_level_sel | c_buf_level_sel | buf_wm_sel |
                                   ffsr_sel | ffcr_sel | pscr_sel |
                                   it_evt_intr_sel | it_tr_fl_in_sel | it_atb_data_0_sel |
                                   it_atb_ctr_2_sel | it_atb_ctr_1_sel | it_atb_ctr_0_sel |
                                   it_ctrl_sel | claimset_sel | claimclr_sel |
                                   devid1_sel | devid_sel | devtype_sel |
                                   (|pidr_sel) | (|cidr_sel));
      end
    else if (TMC_CONFIG == ETF)
      begin : gen_reg_acc_etf
        assign reg_access =       (rsz_sel | sts_sel | rrp_sel | rwp_sel |
                                   trg_sel | ctl_sel | mode_sel |
                                   l_buf_level_sel | c_buf_level_sel | buf_wm_sel |
                                   ffsr_sel | ffcr_sel | pscr_sel |
                                   it_atb_m_data_0_sel | it_atb_m_ctr_2_sel |
                                   it_atb_m_ctr_1_sel | it_atb_m_ctr_0_sel |
                                   it_evt_intr_sel | it_tr_fl_in_sel | it_atb_data_0_sel |
                                   it_atb_ctr_2_sel | it_atb_ctr_1_sel | it_atb_ctr_0_sel |
                                   it_ctrl_sel | claimset_sel | claimclr_sel |
                                   devid1_sel | devid_sel | devtype_sel |
                                   (|pidr_sel) | (|cidr_sel));
      end
    else if (TMC_CONFIG == ETR)
      begin : gen_reg_acc_etr
        assign reg_access =       (rsz_sel | sts_sel | rrp_sel | rwp_sel |
                                   trg_sel | ctl_sel | mode_sel |
                                   l_buf_level_sel | c_buf_level_sel | buf_wm_sel |
                                   rrp_hi_sel | rwp_hi_sel | axi_ctl_sel |
                                   dba_lo_sel | dba_hi_sel | rurp_sel |
                                   ffsr_sel | ffcr_sel | pscr_sel |
                                   it_evt_intr_sel | it_tr_fl_in_sel | it_atb_data_0_sel |
                                   it_atb_ctr_2_sel | it_atb_ctr_1_sel | it_atb_ctr_0_sel |
                                   it_ctrl_sel | claimset_sel | claimclr_sel | authstatus_sel |
                                   devid1_sel | devid_sel | devtype_sel |
                                   (|pidr_sel) | (|cidr_sel));
      end
    else
      begin : gen_reg_acc_ets
        assign reg_access =       (rsz_sel | sts_sel | trg_sel | ctl_sel | mode_sel |
                                   ffsr_sel | ffcr_sel | pscr_sel |
                                   it_evt_intr_sel | it_tr_fl_in_sel | it_atb_data_0_sel |
                                   it_atb_ctr_2_sel | it_atb_ctr_1_sel | it_atb_ctr_0_sel |
                                   it_ctrl_sel | claimset_sel | claimclr_sel | authstatus_sel |
                                   devid1_sel | devid_sel | devtype_sel |
                                   (|pidr_sel) | (|cidr_sel));
      end
  endgenerate


  always @(posedge clk or negedge reset_n)
  begin : s_penable_reconst
    if (!reset_n)
      penable_reconst <= 1'b0;
    else if (cg_en && dev_run)
      penable_reconst <= nxt_penable_reconst;
  end

  assign nxt_penable_reconst = psel_s & (curr_state != ST_APBSLV_RDY);

  assign apb_setup_normal = (psel_s & ~penable_s) & dev_run;

  assign apb_setup_wake = (psel_s & ~penable_reconst) & dev_run;

  assign apb_select = (apb_setup_normal | apb_setup_wake);


  assign reg_write = cg_en & apb_select &  pwrite_s & reg_access;
  assign reg_read  =          apb_select & ~pwrite_s & reg_access;

  assign apb_pipe_we = reg_write | cg_en & reg_write_p;

  assign apb_addr = {10{reg_write}} & paddr_s[11:2];

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n)
      begin
        reg_write_p <= 1'b0;
        apb_addr_p  <= {10{1'b0}};
      end
    else if (cg_en)
      begin
        reg_write_p <= reg_write;

        if (apb_pipe_we)
          apb_addr_p <= apb_addr;
      end
  end

  always @(posedge clk)
  begin
    if (reg_write)
        apb_wdata_p <= pwdata_s;
  end

  assign mem_write  = apb_select &  pwrite_s & rwd_sel;
  assign mem_read   = apb_select & ~pwrite_s & rrd_sel;
  assign mem_access = mem_write | mem_read;

  assign tmc_disabled = tmc_ready & ~ctl_trace_capt_en;


  always @*
  begin : c_nxt_state
    case (curr_state)
      ST_APBSLV_IDLE :
        case ({apb_select, mem_access})
          2'b00   : nxt_state =  ST_APBSLV_IDLE;
          2'b10   : nxt_state =  ST_APBSLV_RDY;
          2'b11   : nxt_state = (rrd_rd_deny || rwd_wr_deny) ? ST_APBSLV_RDY : ST_APBSLV_MEM;
          default : nxt_state =  ST_APBSLV_UNDEF;
        endcase
      ST_APBSLV_MEM  :
            nxt_state = (rrd_rd_ack || rwd_wr_ack) ? ST_APBSLV_RDY : ST_APBSLV_MEM;
      ST_APBSLV_RDY  :
            nxt_state = ST_APBSLV_IDLE;
      default        :
            nxt_state = ST_APBSLV_UNDEF;
    endcase
  end

  generate
    if (TMC_CONFIG == ETS)
      begin : gen_apb_state_ets
        reg  curr_state_ets;

        always @ (posedge clk or negedge reset_n)
        begin : s_curr_state_ets
          if (!reset_n)
            curr_state_ets <= ST_APBSLV_IDLE[0];
          else if (state_en)
              curr_state_ets <= nxt_state[0];
        end

        assign curr_state = {1'b0,curr_state_ets};
      end
    else
      begin : gen_apb_state_nonets
        reg [1:0] curr_state_nonets;

        always @ (posedge clk or negedge reset_n)
        begin : s_curr_state_nonets
          if (!reset_n)
            curr_state_nonets <= ST_APBSLV_IDLE;
          else if (state_en)
              curr_state_nonets <= nxt_state;
        end

        assign curr_state = curr_state_nonets;
      end
  endgenerate

  assign state_en = cg_en & dev_run;


  generate
    if (TMC_CONFIG == ETR)
      begin : gen_rsz_etr
        assign rsz_wr_en = cg_en & reg_write_p & rsz_sel_p & tmc_disabled;

        if (ATB_DATA_WIDTH==32)
          begin : gen_rsz_axi_32_align
            wire [30:0] nxt_rsz_etr;
            reg  [30:0]     rsz_etr;

            assign nxt_rsz_etr = (apb_wdata_p[30] ^ (|apb_wdata_p[29:0])) ?  apb_wdata_p[30:0] : 31'h0000_0001;

            always @ (posedge clk)
            begin : s_rsz_etr
              if (rsz_wr_en)
                rsz_etr <= nxt_rsz_etr;
              else if (unprog_rsz_init)
                rsz_etr <= rsz;
            end

            assign rsz = rsz_etr & {{30{~unprog_rsz}},1'b1} | {{30{1'b0}},unprog_rsz};

            assign rsz_rd_data = {1'b0,
                                  rsz_etr};
          end
        else if (ATB_DATA_WIDTH==64)
          begin : gen_rsz_axi_64_align
            wire [29:0] nxt_rsz_etr;
            reg  [29:0]     rsz_etr;

            assign nxt_rsz_etr = (apb_wdata_p[30] ^ (|apb_wdata_p[29:1])) ? apb_wdata_p[30:1] : 30'h0000_0001;

            always @ (posedge clk)
            begin : s_rsz_etr
              if (rsz_wr_en)
                rsz_etr <= nxt_rsz_etr;
              else if (unprog_rsz_init)
                rsz_etr <= rsz[30:1];
            end

            assign rsz = {rsz_etr,1'b0} & {{29{~unprog_rsz}},{2{1'b1}}} | {{29{1'b0}},unprog_rsz,1'b0};

            assign rsz_rd_data = {1'b0,
                                  rsz_etr,1'b0};
          end
        else
          begin : gen_rsz_axi_128_align
            wire [28:0] nxt_rsz_etr;
            reg  [28:0]     rsz_etr;

            assign nxt_rsz_etr = (apb_wdata_p[30] ^ (|apb_wdata_p[29:2])) ? apb_wdata_p[30:2] : 29'h0000_0001;

            always @ (posedge clk)
            begin : s_rsz_etr
              if (rsz_wr_en)
                rsz_etr <= nxt_rsz_etr;
              else if (unprog_rsz_init)
                rsz_etr <= rsz[30:2];
            end

            assign rsz = {rsz_etr,2'b00} & {{28{~unprog_rsz}},{3{1'b1}}} | {{28{1'b0}},unprog_rsz,{2{1'b0}}};

            assign rsz_rd_data = {1'b0,
                                  rsz_etr,2'b00};
          end
      end

    else if (TMC_CONFIG == ETS)
      begin : gen_rsz_ets
        assign rsz = ATB_DATA_WIDTH[30:0] >> 5;
        assign rsz_rd_data = {1'b0,
                              rsz};

      end

    else
      begin : gen_rsz_etb_etf
        assign rsz = MEM_SIZE[30:0];
        assign rsz_rd_data = {1'b0,
                              rsz};
      end
  endgenerate

  assign rsz_rd_en = reg_read & rsz_sel;

  generate
    if (TMC_CONFIG == ETR)
      begin : gen_mem_err_clr
        assign mem_err_clr = (reg_write_p & sts_sel_p & apb_wdata_p[5] & tmc_ready) | ctl_trace_capt_en_rise;
      end
    else
      begin : dont_gen_mem_err_clr
        assign mem_err_clr = 1'b0;
      end
  endgenerate

  assign sts_triggered_masked = sts_triggered & ~ctl_trace_capt_en_rise;

  generate
    if ((TMC_CONFIG == ETR) || (TMC_CONFIG == ETS))
      begin : gen_sts_full_wr
        assign sts_full_wr_en = cg_en & reg_write_p & sts_sel_p & tmc_disabled;
      end
    else
      begin : dont_gen_sts_full_wr
        assign sts_full_wr_en = 1'b0;
      end
  endgenerate

  assign sts_rd_en = reg_read & sts_sel;
  assign sts_rd_data = {26'h0,
                        mem_err,
                        trace_mem_empty,
                        ft_empty,
                        tmc_ready,
                        sts_triggered_masked,
                        sts_full};

  generate
    if (TMC_CONFIG != ETS)
      begin : gen_rrp_rrphi
        assign rrp_wr_en = cg_en & reg_write_p & rrp_sel_p & tmc_disabled;
        assign rrp_rd_en = reg_read & rrp_sel;

        if (MEM_BYTE_ADDR_WIDTH > 32)
          begin : gen_rrp_rrphi_gt32
            assign rrp_hi_wr_en = cg_en & reg_write_p & rrp_hi_sel_p & tmc_disabled;
            assign rrp_hi_rd_en = reg_read & rrp_hi_sel;

            assign rrp_rd_data    = rrp[31:0];
            assign rrp_hi_rd_data = {{(32-HI_ADDR_WIDTH){1'b0}},
                                     rrp[AXI_ADDR_WIDTH-1:32]};
          end
        else if (MEM_BYTE_ADDR_WIDTH == 32)
          begin : gen_rrp_rrphi_eq32
            wire [3:0] dummy_net;
            assign dummy_net = {rrp_hi_sel_p,rwp_hi_sel_p,unprog_dbahi,unprog_dbahi_init};
            assign rrp_hi_wr_en = 1'b0;
            assign rrp_hi_rd_en = 1'b0;

            assign rrp_rd_data    = rrp[31:0];
            assign rrp_hi_rd_data = 32'h0;
          end
        else
          begin : gen_rrp_rrphi_lt32
            assign rrp_hi_wr_en = 1'b0;
            assign rrp_hi_rd_en = 1'b0;

            assign rrp_rd_data    = {{(32-MEM_BYTE_ADDR_WIDTH){1'b0}},
                                     rrp};
            assign rrp_hi_rd_data = 32'h0;
          end
      end
    else
      begin : dont_gen_rrp_rrphi
        assign rrp_wr_en      = 1'b0;
        assign rrp_rd_en      = 1'b0;
        assign rrp_hi_wr_en   = 1'b0;
        assign rrp_hi_rd_en   = 1'b0;
        assign rrp_rd_data    = 32'h0;
        assign rrp_hi_rd_data = 32'h0;
      end
  endgenerate

  generate
    if (TMC_CONFIG != ETS)
      begin : gen_rwp_rwphi
        assign rwp_wr_en = cg_en & reg_write_p & rwp_sel_p & tmc_disabled;
        assign rwp_rd_en = reg_read & rwp_sel;

        if (MEM_BYTE_ADDR_WIDTH > 32)
          begin : gen_rwp_rwphi_gt32
            assign rwp_hi_wr_en = cg_en & reg_write_p & rwp_hi_sel_p & tmc_disabled;
            assign rwp_hi_rd_en = reg_read & rwp_hi_sel;

            assign rwp_rd_data    = rwp[31:0];
            assign rwp_hi_rd_data = {{(32-HI_ADDR_WIDTH){1'b0}},
                                     rwp[AXI_ADDR_WIDTH-1:32]};
          end
        else if (MEM_BYTE_ADDR_WIDTH == 32)
          begin : gen_rwp_rwphi_eq32
            assign rwp_hi_wr_en = 1'b0;
            assign rwp_hi_rd_en = 1'b0;

            assign rwp_rd_data    = rwp[31:0];
            assign rwp_hi_rd_data = 32'h0;
          end
        else
          begin : gen_rwp_rwphi_lt32
            assign rwp_hi_wr_en = 1'b0;
            assign rwp_hi_rd_en = 1'b0;

            assign rwp_rd_data    = {{(32-MEM_BYTE_ADDR_WIDTH){1'b0}},
                                     rwp};
            assign rwp_hi_rd_data = 32'h0;
          end
      end
    else
      begin : dont_gen_rwp_rwphi
        assign rwp_wr_en      = 1'b0;
        assign rwp_rd_en      = 1'b0;
        assign rwp_hi_wr_en   = 1'b0;
        assign rwp_hi_rd_en   = 1'b0;
        assign rwp_rd_data    = 32'h0;
        assign rwp_hi_rd_data = 32'h0;
      end
  endgenerate

  assign trg_wr_en = cg_en & reg_write_p & trg_sel & tmc_disabled;
  assign trg_rd_en = reg_read & trg_sel;

  generate
    if ((TMC_CONFIG == ETR) || (TMC_CONFIG == ETS))
      begin : gen_trg_etr_ets
        assign trg_rd_data = trg;
      end
    else
      begin : gen_trg_etb_etf
        assign trg_rd_data = {{32-TMC_TRG_WIDTH{1'b0}},
                              trg};
      end
  endgenerate

  assign ctl_wr_en = reg_write & ctl_sel;
  assign nxt_ctl_trace_capt_en = (ctl_wr_en) ? pwdata_s[0] : ctl_trace_capt_en;
  always @ (posedge clk or negedge reset_n)
  begin : s_ctl
    if (!reset_n)
      ctl_trace_capt_en <= 1'b0;
    else
      ctl_trace_capt_en <= nxt_ctl_trace_capt_en;
  end

  assign ctl_rd_en = reg_read & ctl_sel;
  assign ctl_rd_data = {31'h0,
                        ctl_trace_capt_en};

  always @ (posedge clk or negedge reset_n)
  begin : s_ctl_q
    if (!reset_n)
      ctl_trace_capt_en_q <= 1'b0;
    else if (cg_en)
      ctl_trace_capt_en_q <= ctl_trace_capt_en;
  end

  assign ctl_trace_capt_en_rise_pre = ctl_wr_en & pwdata_s[0] & ~ctl_trace_capt_en;
  assign ctl_trace_capt_en_rise = ctl_trace_capt_en & ~ctl_trace_capt_en_q;
  assign ctl_trace_capt_en_fall = ~ctl_trace_capt_en & ctl_trace_capt_en_q;

  assign mode_wr_en = cg_en & reg_write_p & mode_sel & tmc_disabled;

  generate
    if (TMC_CONFIG == ETS)
      begin : gen_mode_ets
        assign mode = 2'b00;

        assign mode_rd_data = {27'h0,
                               stall_on_stop,
                               2'b00,
                               mode};
      end
    else
      begin : gen_mode_non_ets
        reg [1:0] mode_int;

        always @ (posedge clk)
        begin : s_mode_mode
          if (mode_wr_en)
            mode_int <= apb_wdata_p[1:0];
          else if (unprog_mode_init)
            mode_int <= mode;
        end

        assign mode = mode_int & {~unprog_mode,1'b1} | {1'b0,unprog_mode};

        assign mode_rd_data = {27'h0,
                               stall_on_stop,
                               2'b00,
                               mode_int};
      end
  endgenerate

  always @ (posedge clk or negedge reset_n)
  begin : s_mode_stall_on_stop
    if (!reset_n)
      stall_on_stop <= 1'b0;
    else if (mode_wr_en)
      stall_on_stop <= apb_wdata_p[4];
  end

  assign mode_rd_en = reg_read & mode_sel;

  generate
    if (TMC_CONFIG == ETF)
      begin : gen_hwf_mode
        assign hw_fifo_mode = (mode == 2'b10);
      end
    else
      begin : dont_gen_hwf_mode
        assign hw_fifo_mode = 1'b0;
      end
  endgenerate

  generate
    if (TMC_CONFIG == ETR)
      begin : gen_swf2_mode
        assign sw_fifo_mode2 = (mode == 2'b11);
      end
    else
      begin : dont_gen_swf2_mode
        assign sw_fifo_mode2 = 1'b0;
      end
  endgenerate

  assign circ_buf_mode = (mode == 2'b00);
  assign sw_fifo_mode1 = (mode == 2'b01) | mode_default;
  assign mode_default = ~(circ_buf_mode | hw_fifo_mode | sw_fifo_mode2);

  generate
    if (TMC_CONFIG != ETS)
      begin : gen_lbuflevel
        assign l_buf_level_rd_en = reg_read & l_buf_level_sel;
        assign l_buf_level_rd_data = {{32-FILL_LEVEL_WIDTH{1'b0}},
                                      l_buf_level};

        assign l_buf_level_rd_done = tmc_enabled & l_buf_level_sel & ~pwrite_s &
                                     (curr_state == ST_APBSLV_RDY);
      end
    else
      begin : dont_gen_lbuflevel
        assign l_buf_level_rd_en   = 1'b0;
        assign l_buf_level_rd_data = 32'h0;
        assign l_buf_level_rd_done = 1'b0;
      end
  endgenerate

  generate
    if (TMC_CONFIG != ETS)
      begin : gen_cbuflevel
        assign c_buf_level_rd_en = reg_read & c_buf_level_sel;
        assign c_buf_level_rd_data = {{32-FILL_LEVEL_WIDTH{1'b0}},
                                      c_buf_level};
      end
    else
      begin : dont_gen_cbuflevel
        assign c_buf_level_rd_en   = 1'b0;
        assign c_buf_level_rd_data = 32'h0;
      end
  endgenerate

  generate
    if (TMC_CONFIG != ETS)
      begin : gen_bufwm
        reg [FILL_LEVEL_WIDTH-2:0] buf_wm_int;

        assign buf_wm_wr_en = cg_en & reg_write_p & buf_wm_sel & tmc_disabled;

        always @ (posedge clk)
        begin : s_buf_wm
          if (buf_wm_wr_en)
            buf_wm_int <= apb_wdata_p[FILL_LEVEL_WIDTH-2:0];
          else if (unprog_bufwm_init)
            buf_wm_int <= buf_wm;
        end

        assign buf_wm = buf_wm_int & {FILL_LEVEL_WIDTH-1{~unprog_bufwm}};

        assign buf_wm_rd_en = reg_read & buf_wm_sel;
        assign buf_wm_rd_data = {{32-FILL_LEVEL_WIDTH+1{1'b0}},
                                 buf_wm_int};
      end
    else
      begin : dont_gen_bufwm
        assign buf_wm         = {FILL_LEVEL_WIDTH-1{1'b0}};
        assign buf_wm_rd_en   = 1'b0;
        assign buf_wm_rd_data = 32'h0;
      end
  endgenerate

  generate
    if (TMC_CONFIG == ETR)
      begin : gen_axi_ctl
        wire [3:0]          nxt_axictl_wcache;
        wire [3:0]          nxt_axictl_rcache;

        wire [30-RSZ_LSB:0] rsz_in_axi_datawords;

        reg  [3:0]          axictl_wrburstlen;
        reg  [1:0]          axictl_prot_ctrl_int;
        reg  [3:0]          axictl_wcache_int;
        reg  [3:0]          axictl_rcache_int;

        wire [3:0]          wr_burst_len_int;
        wire [1:0]          prot_ctrl_int;

        assign axi_ctl_wr_en = cg_en & reg_write_p & axi_ctl_sel_p & tmc_disabled;

        always @ (posedge clk)
        begin : s_axictl_part1
          if (axi_ctl_wr_en)
            begin
              axictl_wrburstlen    <= apb_wdata_p[11:8];
              axictl_prot_ctrl_int <= apb_wdata_p[1:0];
            end
          else if (unprog_axictl_init)
            begin
              axictl_wrburstlen    <= wr_burst_len_int;
              axictl_prot_ctrl_int <= prot_ctrl_int;
            end
        end

        assign wr_burst_len_int = axictl_wrburstlen    & {4{~unprog_axictl}};
        assign prot_ctrl_int    = axictl_prot_ctrl_int | {2{unprog_axictl}};

        assign rsz_in_axi_datawords = rsz[30:RSZ_LSB] - {{(31-RSZ_LSB-1){1'b0}}, 1'b1};

        assign wr_burst_len = !tmc_enabled ? 4'h0 :
                              (({{(31-RSZ_LSB-4){1'b0}}, wr_burst_len_int} <= rsz_in_axi_datawords) &&
                               (wr_burst_len_int <= WBUFFER_DEPTH_BIN)) ? wr_burst_len_int :
                              (WBUFFER_DEPTH_BIN <= wr_burst_len_int)   ? WBUFFER_DEPTH_BIN :
                                                                          rsz_in_axi_datawords[3:0];

        always @ (posedge clk or negedge reset_n)
        begin : s_axictl_part2
          if (!reset_n)
            begin
              axictl_wcache_int <= AWCACHE_RST_VAL;
              axictl_rcache_int <= ARCACHE_RST_VAL;
            end
          else if (axi_ctl_wr_en)
            begin
              axictl_wcache_int <= nxt_axictl_wcache;
              axictl_rcache_int <= nxt_axictl_rcache;
          end
        end

        assign nxt_axictl_wcache = ((apb_wdata_p[5:4] == 2'b00)   || apb_wdata_p[3])  ? apb_wdata_p[5:2]   : AWCACHE_RST_VAL;
        assign nxt_axictl_rcache = ((apb_wdata_p[19:18] == 2'b00) || apb_wdata_p[17]) ? apb_wdata_p[19:16] : ARCACHE_RST_VAL;

        assign axictl_prot_ctrl = prot_ctrl_int;
        assign axictl_wcache    = axictl_wcache_int;
        assign axictl_rcache    = axictl_rcache_int;

        assign axi_ctl_rd_en   = reg_read & axi_ctl_sel;
        assign axi_ctl_rd_data = {12'b0,
                                  axictl_rcache,
                                  4'b0,
                                  wr_burst_len_int,
                                  2'b0,
                                  axictl_wcache,
                                  axictl_prot_ctrl_int};
      end
    else
      begin : dont_gen_axi_ctl
        assign axi_ctl_rd_en    = 1'b0;
        assign axi_ctl_rd_data  = 32'h0;

        assign axictl_rcache    = 4'h0;
        assign axictl_wcache    = 4'h0;
        assign axictl_prot_ctrl = 2'b00;
        assign wr_burst_len     = 4'h0;
      end
  endgenerate

  generate
    if (TMC_CONFIG == ETR)
      begin : gen_dba
        reg  [31-DBA_PAD:0] dba_lo_int;
        wire [31-DBA_PAD:0] dba_lo_init;
        wire [31-DBA_PAD:0] dba_lo;

        assign dba_lo_wr_en = cg_en & reg_write_p & dba_lo_sel & tmc_disabled;

        always @ (posedge clk)
        begin : s_dba_lo
          if (dba_lo_wr_en)
            dba_lo_int <= apb_wdata_p[31:DBA_PAD];
          else if (unprog_dbalo_init)
            dba_lo_int <= dba_lo;
        end

        assign dba_lo_init    = {(32-DBA_PAD){1'b0}};
        assign dba_lo         = unprog_dbalo ? dba_lo_init : dba_lo_int;
        assign dba_lo_rd_en   = reg_read & dba_lo_sel;
        assign dba_lo_rd_data = {dba_lo,{DBA_PAD{1'b0}}};

        if (AXI_ADDR_WIDTH > 32)
          begin : gen_dba_hi
            reg  [HI_ADDR_WIDTH-1:0] dba_hi_int;
            wire  [HI_ADDR_WIDTH-1:0] dba_hi;

            assign dba_hi_wr_en = cg_en & reg_write_p & dba_hi_sel & tmc_disabled;

            always @ (posedge clk)
            begin : s_dba_hi
              if (dba_hi_wr_en)
                dba_hi_int <= apb_wdata_p[HI_ADDR_WIDTH-1:0];
              else if (unprog_dbahi_init)
                dba_hi_int <= dba_hi;
            end

            assign dba_hi = dba_hi_int & {HI_ADDR_WIDTH{~unprog_dbahi}};

            assign dba = {dba_hi,dba_lo,{DBA_PAD{1'b0}}};

            assign dba_hi_rd_en   = reg_read & dba_hi_sel;
            assign dba_hi_rd_data = {{(32-HI_ADDR_WIDTH){1'b0}},
                                     dba_hi};
          end
        else
          begin : dont_gen_dba_hi
            assign dba = {dba_lo,{DBA_PAD{1'b0}}};

            assign dba_hi_rd_en   = 1'b0;
            assign dba_hi_rd_data = 32'h0;
          end
      end
    else
      begin : dont_gen_dba
        assign dba = {MEM_BYTE_ADDR_WIDTH{1'b0}};

        assign dba_lo_rd_en   = 1'b0;
        assign dba_hi_rd_en   = 1'b0;
        assign dba_lo_rd_data = 32'h0;
        assign dba_hi_rd_data = 32'h0;
      end
  endgenerate

  generate
    if (TMC_CONFIG == ETR)
      begin : gen_rurp
        assign rurp_wr_en = cg_en & reg_write_p & rurp_sel_p & tmc_enabled & ~tmc_abort;
      end
    else
      begin : dont_gen_rurp
        assign rurp_wr_en = 1'b0;
      end
  endgenerate

  assign ffsr_rd_en = reg_read & ffsr_sel;
  assign ffsr_rd_data = {30'b0,
                         ft_empty,
                         flush_fsm_busy};

  assign ffcr_wr_en        = cg_en & reg_write_p & ffcr_sel;
  assign ffcr_wr_en_bits01 = cg_en & reg_write_p & ffcr_sel & tmc_disabled;

  always @ (posedge clk or negedge reset_n)
  begin : s_ffcr
    if (!reset_n)
      begin
        ffcr_embed_flush      <= 1'b0;
        ffcr_stop_on_trig_evt <= 1'b0;
        ffcr_stop_on_fl       <= 1'b0;
        ffcr_trig_on_fl       <= 1'b0;
        ffcr_trig_on_trig_evt <= 1'b0;
        ffcr_trig_on_trigin   <= 1'b0;
        ffcr_flsh_on_trig_evt <= 1'b0;
        ffcr_flsh_on_flshin   <= 1'b0;
      end
    else if (ffcr_wr_en)
      begin
        ffcr_embed_flush      <= apb_wdata_p[15];
        ffcr_stop_on_trig_evt <= apb_wdata_p[13];
        ffcr_stop_on_fl       <= apb_wdata_p[12];
        ffcr_trig_on_fl       <= apb_wdata_p[10];
        ffcr_trig_on_trig_evt <= apb_wdata_p[9];
        ffcr_trig_on_trigin   <= apb_wdata_p[8];
        ffcr_flsh_on_trig_evt <= apb_wdata_p[5];
        ffcr_flsh_on_flshin   <= apb_wdata_p[4];
      end
  end

  always @ (posedge clk or negedge reset_n)
  begin : s_ffcr_bits01
    if (!reset_n)
      begin
        ffcr_en_trig_ins   <= 1'b0;
        ffcr_en_formatting <= 1'b0;
      end
    else if (ffcr_wr_en_bits01)
      begin
        ffcr_en_trig_ins   <= apb_wdata_p[1];
        ffcr_en_formatting <= apb_wdata_p[0];
      end
  end

  assign ffcr_flush_man_wr_en = cg_en & (ffcr_wr_en | flush_man_clr);
  assign nxt_ffcr_flush_man   = ~flush_man_clr &
                                (ffcr_flush_man | (ffcr_wr_en & apb_wdata_p[6] & ctl_trace_capt_en));

  always @ (posedge clk or negedge reset_n)
  begin : s_ffcr_flush_man
    if (!reset_n)
      ffcr_flush_man <= 1'b0;
    else if (ffcr_flush_man_wr_en)
      ffcr_flush_man <=  nxt_ffcr_flush_man;
  end

  generate
    if (TMC_CONFIG == ETF)
      begin : gen_ffcr_drain_buffer
        wire nxt_drain_buffer;
        reg  drain_buffer;

        assign nxt_drain_buffer = (ffcr_wr_en & apb_wdata_p[14] &
                                   tmc_ready & ctl_trace_capt_en &
                                   circ_buf_mode & ffcr_en_formatting_masked) |
                                  (drain_buffer & ~(unformatter_empty & trace_mem_empty) &
                                   ctl_trace_capt_en);

        always @ (posedge clk or negedge reset_n)
        begin : s_ffcr_drain_buffer
          if (!reset_n)
            drain_buffer <= 1'b0;
          else if (cg_en)
            drain_buffer <= nxt_drain_buffer;
        end

        assign ffcr_drain_buffer_en = drain_buffer;
      end
    else
      begin : dont_gen_ffcr_drain_buffer
        assign ffcr_drain_buffer_en = 1'b0;
      end
  endgenerate

  assign ffcr_embed_flush_masked      = ffcr_embed_flush & ffcr_en_formatting_masked;
  assign ffcr_stop_on_trig_evt_masked = circ_buf_mode & tmc_enabled & ffcr_stop_on_trig_evt;
  assign ffcr_flsh_on_trig_evt_masked = circ_buf_mode & tmc_enabled & ffcr_flsh_on_trig_evt;
  assign ffcr_trig_on_trig_evt_masked = circ_buf_mode & tmc_enabled & ffcr_en_trig_ins & ffcr_trig_on_trig_evt;
  assign ffcr_trig_on_trigin_masked   = ffcr_trig_on_trigin & ffcr_en_trig_ins;
  assign ffcr_trig_on_fl_masked       = ffcr_trig_on_fl & ffcr_en_trig_ins;
  assign ffcr_en_formatting_masked    = ~circ_buf_mode | ffcr_en_formatting | ffcr_en_trig_ins;

  assign ffcr_rd_en   = reg_read & ffcr_sel;
  assign ffcr_rd_data = {16'b0,
                         ffcr_embed_flush,
                         1'b0,
                         ffcr_stop_on_trig_evt,
                         ffcr_stop_on_fl,
                         1'b0,
                         ffcr_trig_on_fl,
                         ffcr_trig_on_trig_evt,
                         ffcr_trig_on_trigin,
                         1'b0,
                         ffcr_flush_man,
                         ffcr_flsh_on_trig_evt,
                         ffcr_flsh_on_flshin,
                         2'b00,
                         ffcr_en_trig_ins,
                         ffcr_en_formatting};

  assign pscr_wr_en = cg_en & reg_write_p & pscr_sel & tmc_disabled;

  assign nxt_pscr_pscount = (apb_wdata_p[4:0] == 5'h0) || ((apb_wdata_p[4:0] >= 5'h07) &&
                                                           (apb_wdata_p[4:0] <= 5'h1B)) ?
                             apb_wdata_p[4:0] : 5'h1B;

  generate
    if ((TMC_CONFIG == ETR) || (TMC_CONFIG == ETS))
      begin : gen_pscr_embed_sync
        reg pscr_embed_sync_prog;

        always @ (posedge clk or negedge reset_n)
        begin : s_pscr_embedsync
          if (!reset_n)
            pscr_embed_sync_prog <= 1'b0;
          else if (pscr_wr_en)
            pscr_embed_sync_prog <= apb_wdata_p[5];
        end

        assign pscr_embed_sync = pscr_embed_sync_prog;
      end
    else
      begin : dont_gen_pscr_embed_sync
        assign pscr_embed_sync = 1'b0;
      end
  endgenerate

  always @ (posedge clk or negedge reset_n)
  begin : s_pscr_pscount
    if (!reset_n)
      pscr_pscount <= PSCOUNT_RST_VAL;
    else if (pscr_wr_en)
      pscr_pscount <= nxt_pscr_pscount;
  end

  assign pscr_rd_en   = reg_read & pscr_sel;
  assign pscr_rd_data = {26'b0,
                         pscr_embed_sync,
                         pscr_pscount};

  generate
    if (TMC_CONFIG == ETF)
      begin : gen_it_atbm_data0
        assign it_atb_m_data_0_wr_en = cg_en & reg_write_p & it_atb_m_data_0_sel & itctrl_ime & tmc_disabled;
      end
    else
      begin : dont_gen_it_atbm_data0
        assign it_atb_m_data_0_wr_en = 1'b0;
      end
  endgenerate

  generate
    if (TMC_CONFIG == ETF)
      begin : gen_it_atbm_ctr2
        wire nxt_it_syncreqm;
        reg  syncreqm_q;
        reg  it_syncreqm;

        assign it_atb_m_ctr_2_rd_en = reg_read & it_atb_m_ctr_2_sel & itctrl_ime;
        assign it_atb_m_ctr_2_rd_data = {29'b0,
                                         it_syncreqm,
                                         afvalid_m,
                                         atready_m};

        always @ (posedge clk or negedge reset_n)
        begin : s_it_atbm_syncreq
          if (!reset_n)
            begin
              syncreqm_q <= 1'b0;
              it_syncreqm <= 1'b0;
            end
          else if (cg_en)
            begin
              syncreqm_q <= syncreq_m;
              it_syncreqm <= nxt_it_syncreqm;
            end
        end

        assign nxt_it_syncreqm =  itctrl_ime & ~it_atb_m_ctr_2_rd_en &
                                  ((syncreq_m & ~syncreqm_q) | it_syncreqm);
      end
    else
      begin : dont_gen_it_atbm_ctr2
        assign it_atb_m_ctr_2_rd_en   = 1'b0;
        assign it_atb_m_ctr_2_rd_data = 32'h0;
      end
  endgenerate

  generate
    if (TMC_CONFIG == ETF)
      begin : gen_it_atbm_ctr1
        assign it_atb_m_ctr_1_wr_en  = cg_en & reg_write_p & it_atb_m_ctr_1_sel & itctrl_ime & tmc_disabled;
      end
    else
      begin : dont_gen_it_atbm_ctr1
        assign it_atb_m_ctr_1_wr_en  = 1'b0;
      end
  endgenerate

  generate
    if (TMC_CONFIG == ETF)
      begin : gen_it_atbm_ctr0
        assign it_atb_m_ctr_0_wr_en  = cg_en & reg_write_p & it_atb_m_ctr_0_sel & itctrl_ime & tmc_disabled;
      end
    else
      begin : dont_gen_it_atbm_ctr0
        assign it_atb_m_ctr_0_wr_en = 1'b0;
      end
  endgenerate

  assign it_evt_intr_wr_en = cg_en & reg_write_p & it_evt_intr_sel & itctrl_ime & tmc_disabled;

  assign it_tr_fl_in_rd_en   = reg_read & it_tr_fl_in_sel & itctrl_ime;
  assign it_tr_fl_in_rd_data = {30'b0,
                                it_flushin,
                                it_trigin};

  assign it_atb_data_0_rd_en   = reg_read & it_atb_data_0_sel & itctrl_ime;
  assign it_atb_data_0_rd_data = {{32-ITATBDATA0_WIDTH{1'b0}},
                                  it_atb_data_0};

  assign it_atb_ctr_2_wr_en = cg_en & reg_write_p & it_atb_ctr_2_sel & itctrl_ime & tmc_disabled;

  assign it_atb_ctr_1_rd_en   = reg_read & it_atb_ctr_1_sel & itctrl_ime;
  assign it_atb_ctr_1_rd_data = {25'b0,
                                 it_atids};

  assign it_atb_ctr_0_rd_en   = reg_read & it_atb_ctr_0_sel & itctrl_ime;
  assign it_atb_ctr_0_rd_data = {{24-ATBYTES_WIDTH{1'b0}},
                                 it_atbytess,
                                 5'b0,
                                 it_atwakeups,
                                 it_afreadys,
                                 it_atvalids};

  assign it_ctrl_wr_en = reg_write & it_ctrl_sel & tmc_disabled;
  assign integ_mode_entry = it_ctrl_wr_en & pwdata_s[0];

  always @ (posedge clk or negedge reset_n)
  begin : s_it_ctrl
    if (!reset_n)
      itctrl_ime <= 1'b0;
    else if (it_ctrl_wr_en)
      itctrl_ime <= pwdata_s[0];
  end

  assign it_ctrl_rd_en   = reg_read & it_ctrl_sel;
  assign it_ctrl_rd_data = {31'h0,
                            itctrl_ime};

  assign claimset_wr_en = cg_en & reg_write_p & claimset_sel;
  assign claimclr_wr_en = cg_en & reg_write_p & claimclr_sel;
  assign claimset_rd_en = reg_read & claimset_sel;
  assign claimclr_rd_en = reg_read & claimclr_sel;

  css600_claimtags
    #(.NUM_CLAIM_TAGS(4))
    u_css600_claimtags
    (
      .clk               (clk),
      .reset_n           (reset_n),
      .claim_set_wr      (claimset_wr_en),
      .claim_set_wr_data (apb_wdata_p[3:0]),
      .claim_set_rd      (claimset_rd_en),
      .claim_set_rd_data (claimset_rd_data[3:0]),
      .claim_clr_wr      (claimclr_wr_en),
      .claim_clr_wr_data (apb_wdata_p[3:0]),
      .claim_clr_rd      (claimclr_rd_en),
      .claim_clr_rd_data (claimclr_rd_data[3:0])
    );

  assign claimset_rd_data[31:4] = 28'b0;
  assign claimclr_rd_data[31:4] = 28'b0;

  generate
    if (TMC_CONFIG == ETR)
      begin : gen_auth_status
        assign authstatus_rd_en = reg_read & authstatus_sel;

        assign authstatus_rd_data = {20'b0,
                                     2'b00,
                                     2'b00,
                                     2'b00,
                                     1'b1, (dbgen & spiden),
                                     2'b00,
                                     1'b1, dbgen};
      end
    else
      begin : dont_gen_auth_status
        assign authstatus_rd_en   = 1'b0;
        assign authstatus_rd_data = 32'h0;
      end
  endgenerate

  assign devid1_rd_en   = reg_read & devid1_sel;
  assign devid1_rd_data = {31'b0,
                          REGV_DEVID1_RMC};

  assign devid_rd_en   = reg_read & devid_sel;
  assign devid_rd_data = {2'b0,
                          REGV_DEVID_CACHETYPE,
                          REGV_DEVID_MODES,
                          REGV_DEVID_NOSCAT,
                          REGV_DEVID_AW,
                          REGV_DEVID_AW_VALID,
                          2'b00,
                          REGV_DEVID_WBUF_DEPTH,
                          REGV_DEVID_MEMWIDTH,
                          REGV_DEVID_CONFIGTYPE,
                          REGV_DEVID_CLKSCHEME,
                          REGV_DEVID_ATBPORTCOUNT};

  assign devtype_rd_en   = reg_read & devtype_sel;
  assign devtype_rd_data = {24'b0,
                            REGV_DEVTYPE_SUB,
                            REGV_DEVTYPE_MAJOR};

  assign pidr_rd_en[4:0] = {5{reg_read}} & pidr_sel[4:0];

  assign pidr0_rd_data     = {24'h0,
                              REGV_PIDR0_PART0};

  assign pidr1_rd_data     = {24'h0,
                              REGV_PIDR1_DES0,
                              REGV_PIDR1_PART1};

  assign pidr2_rd_data     = {24'h0,
                              REGV_PIDR2_REVISION,
                              REGV_PIDR2_JEDEC,
                              REGV_PIDR2_DES1};

  assign pidr3_rd_data     = {24'h0,
                              revand,
                              REGV_PIDR3_CMOD};

  assign pidr4_rd_data     = {24'h0,
                              REGV_PIDR4_SIZE,
                              REGV_PIDR4_DES2};

  assign cidr_rd_en[3:0] = {4{reg_read}} & cidr_sel[3:0];

  assign cidr0_rd_data     = {24'h0,
                              REGV_CIDR0_PRMBL0};

  assign cidr1_rd_data     = {24'h0,
                              REGV_CIDR1_CLASS,
                              REGV_CIDR1_PRMBL1};

  assign cidr2_rd_data     = {24'h0,
                              REGV_CIDR2_PRMBL2};

  assign cidr3_rd_data     = {24'h0,
                              REGV_CIDR3_PRMBL3};


  assign nxt_prdata = (({32{rsz_rd_en}}              & rsz_rd_data)
                     | ({32{sts_rd_en}}              & sts_rd_data)
                     | ({32{rrd_rdata_en}}           & rrd_rd_data)
                     | ({32{rrd_rd_deny|rrd_rd_err}} & 32'hFFFFFFFF)
                     | ({32{rrp_rd_en}}              & rrp_rd_data)
                     | ({32{rwp_rd_en}}              & rwp_rd_data)
                     | ({32{trg_rd_en}}              & trg_rd_data)
                     | ({32{ctl_rd_en}}              & ctl_rd_data)
                     | ({32{mode_rd_en}}             & mode_rd_data)
                     | ({32{l_buf_level_rd_en}}      & l_buf_level_rd_data)
                     | ({32{c_buf_level_rd_en}}      & c_buf_level_rd_data)
                     | ({32{buf_wm_rd_en}}           & buf_wm_rd_data)
                     | ({32{rrp_hi_rd_en}}           & rrp_hi_rd_data)
                     | ({32{rwp_hi_rd_en}}           & rwp_hi_rd_data)
                     | ({32{axi_ctl_rd_en}}          & axi_ctl_rd_data)
                     | ({32{dba_lo_rd_en}}           & dba_lo_rd_data)
                     | ({32{dba_hi_rd_en}}           & dba_hi_rd_data)
                     | ({32{ffsr_rd_en}}             & ffsr_rd_data)
                     | ({32{ffcr_rd_en}}             & ffcr_rd_data)
                     | ({32{pscr_rd_en}}             & pscr_rd_data)
                     | ({32{it_atb_m_ctr_2_rd_en}}   & it_atb_m_ctr_2_rd_data)
                     | ({32{it_tr_fl_in_rd_en}}      & it_tr_fl_in_rd_data)
                     | ({32{it_atb_data_0_rd_en}}    & it_atb_data_0_rd_data)
                     | ({32{it_atb_ctr_1_rd_en}}     & it_atb_ctr_1_rd_data)
                     | ({32{it_atb_ctr_0_rd_en}}     & it_atb_ctr_0_rd_data)
                     | ({32{it_ctrl_rd_en}}          & it_ctrl_rd_data)
                     | ({32{claimset_rd_en}}         & claimset_rd_data)
                     | ({32{claimclr_rd_en}}         & claimclr_rd_data)
                     | ({32{authstatus_rd_en}}       & authstatus_rd_data)
                     | ({32{devid1_rd_en}}           & devid1_rd_data)
                     | ({32{devid_rd_en}}            & devid_rd_data)
                     | ({32{devtype_rd_en}}          & devtype_rd_data)
                     | ({32{pidr_rd_en[0]}}          & pidr0_rd_data)
                     | ({32{pidr_rd_en[1]}}          & pidr1_rd_data)
                     | ({32{pidr_rd_en[2]}}          & pidr2_rd_data)
                     | ({32{pidr_rd_en[3]}}          & pidr3_rd_data)
                     | ({32{pidr_rd_en[4]}}          & pidr4_rd_data)
                     | ({32{cidr_rd_en[0]}}          & cidr0_rd_data)
                     | ({32{cidr_rd_en[1]}}          & cidr1_rd_data)
                     | ({32{cidr_rd_en[2]}}          & cidr2_rd_data)
                     | ({32{cidr_rd_en[3]}}          & cidr3_rd_data));

  assign prdata_we = cg_en & ~pwrite_s & nxt_pready;

  always @ (posedge clk or negedge reset_n)
  begin : s_prdatas
    if (!reset_n)
      prdata_s <= 32'b0;
    else if (prdata_we)
      prdata_s <= nxt_prdata;
  end

  assign nxt_pready = (nxt_state == ST_APBSLV_RDY);

  always @ (posedge clk or negedge reset_n)
  begin : s_preadys
    if (!reset_n)
      pready_s <= 1'b0;
    else if (cg_en)
      pready_s <= nxt_pready;
  end

  generate
    if (TMC_CONFIG == ETR)
      begin : gen_apb_err
        wire nxt_pslverr_etr;
        reg      pslverr_etr;

        assign nxt_pslverr_etr = (mem_err & (mem_write | mem_read)) |
                                  rrd_rd_err;

        always @ (posedge clk or negedge reset_n)
        begin : s_pslverr_etr
           if (!reset_n)
             pslverr_etr <= 1'b0;
           else if (cg_en)
             pslverr_etr <= nxt_pslverr_etr;
        end

        assign pslverr_s = pslverr_etr;

      end
    else
      begin : dont_gen_apb_err
         assign pslverr_s = 1'b0;
      end
  endgenerate


  generate
    if (TMC_CONFIG != ETS)
      begin : gen_rwd_wr_logic
        reg        rwd_wr_req_hold;
        reg [31:0] rwd_wr_data_int;

        assign rwd_wr_valid = tmc_disabled & ~mem_err;

        assign rwd_wr_en   = cg_en & mem_write & rwd_wr_valid;
        assign rwd_wr_deny = mem_write & ~rwd_wr_valid;

        assign rwd_wr_ack = (rwd_wr_req_hold & wb_ready);

        assign nxt_rwd_wr_req_hold = rwd_wr_en | (rwd_wr_req_hold & ~wb_ready);

        always @ (posedge clk or negedge reset_n)
        begin : s_rwd_wr_req_hold
          if (!reset_n)
            rwd_wr_req_hold <= 1'b0;
          else if (cg_en)
            rwd_wr_req_hold <= nxt_rwd_wr_req_hold;
        end

        always @ (posedge clk or negedge reset_n)
        begin : s_rwd_wr_data
          if (!reset_n)
            rwd_wr_data_int <= 32'b0;
          else if (rwd_wr_en)
            rwd_wr_data_int <= pwdata_s;
        end

        assign rwd_wr_data = rwd_wr_data_int;


        if (TMC_CONFIG == ETR)
          begin : rwd_wr_req_etr
            reg  rwd_wr_req_int;
            always @ (posedge clk or negedge reset_n)
            begin : s_rwd_wr_req
              if (!reset_n)
                rwd_wr_req_int <= 1'b0;
              else if (cg_en)
                rwd_wr_req_int <= rwd_wr_en;
            end

            assign rwd_wr_req = rwd_wr_req_int;
          end
        else
          begin : rwd_wr_req_etb_etf
            assign rwd_wr_req = rwd_wr_req_hold;
          end

      end
    else
      begin : dont_gen_rwd_wr_logic
        assign rwd_wr_deny = mem_write;
        assign rwd_wr_ack  = 1'b0;
        assign rwd_wr_req  = 1'b0;
        assign rwd_wr_data = 32'b0;
      end
  endgenerate


  generate
    if (TMC_CONFIG != ETS)
      begin : gen_rrd_rd_logic
        reg        rrd_rd_valid;
        reg        rrd_rd_req_int;

        always @*
        begin : c_rrd_rd_valid
          case ({mem_err,tmc_enabled})
            2'b00 :
                    rrd_rd_valid = ~trace_mem_empty | 1'b1;

            2'b01 :
                    rrd_rd_valid = circ_buf_mode ? ~trace_mem_empty & ~ffcr_drain_buffer_en & tmc_ready
                                 : sw_fifo_mode1 ? ~trace_mem_empty
                                 :                 1'b0
                                 ;
            2'b10,
            2'b11 :
                    rrd_rd_valid = 1'b0;
          endcase
        end

        assign rrd_rd_en = mem_read & rrd_rd_valid;
        assign rrd_rd_deny = mem_read & ~rrd_rd_valid;

        assign rrd_rdata_en = rrd_rd_ack & ~mem_err;

        assign rrd_rd_err = rrd_rd_ack & mem_err;

        always @ (posedge clk or negedge reset_n)
        begin : s_rrd_rd_req
          if (!reset_n)
            rrd_rd_req_int <= 1'b0;
          else if (cg_en)
            rrd_rd_req_int <= rrd_rd_en;
        end

        assign rrd_rd_req = rrd_rd_req_int;
      end
    else
      begin : dont_gen_rrd_rd_logic
        assign rrd_rd_en    = 1'b0;
        assign rrd_rd_deny  = mem_read;
        assign rrd_rdata_en = 1'b0;
        assign rrd_rd_err   = 1'b0;
        assign rrd_rd_req   = 1'b0;
      end
  endgenerate


  generate
    if (TMC_CONFIG == ETF)
      begin : gen_unf_en_stop
        reg trace_mem_empty_q;
        reg trace_mem_empty_q2;

        assign unformatter_en = (hw_fifo_mode & ctl_trace_capt_en & ~ctl_trace_capt_en_rise) |
                                 ffcr_drain_buffer_en;

        assign unformatter_stop = unformatter_en & ft_stopped &
                                  trace_mem_empty & trace_mem_empty_q & trace_mem_empty_q2;

        always @ (posedge clk or negedge reset_n)
        begin : s_trace_mem_empty_del
          if (!reset_n)
            begin
              trace_mem_empty_q <= 1'b0;
              trace_mem_empty_q2 <= 1'b0;
            end
          else if (cg_en)
            begin
              trace_mem_empty_q <= trace_mem_empty;
              trace_mem_empty_q2 <= trace_mem_empty_q;
            end
        end
      end
    else
      begin : dont_gen_unf_en_stop
        assign unformatter_en   = 1'b0;
        assign unformatter_stop = 1'b0;
      end
  endgenerate

  generate
    if (TMC_CONFIG == ETF)
      begin : gen_atbm_flush_mon
        wire nxt_atbm_flush_mon;
        reg      atbm_flush_mon_etf;

        always @ (posedge clk or negedge reset_n)
        begin : s_atbm_flush_mon
          if (!reset_n)
            atbm_flush_mon_etf <= 1'b0;
          else if (cg_en)
            atbm_flush_mon_etf <= nxt_atbm_flush_mon;
        end

        assign nxt_atbm_flush_mon = (hw_fifo_mode | ffcr_drain_buffer_en)
                                  & (  ({ctl_trace_capt_en,tmc_ready} != 2'b01)
                                    | (({ctl_trace_capt_en,tmc_ready} == 2'b01) & ~nxt_afreadym )
                                    )
                                  ;
        assign     atbm_flush_mon = atbm_flush_mon_etf;
      end
    else
      begin : dont_gen_atbm_flush_mon
        assign atbm_flush_mon = 1'b0;
      end
  endgenerate


  generate
    if (TMC_CONFIG == ETF)
      begin : gen_tmcready_etf
        assign nxt_tmc_ready = tmc_abort ?
                                   (ft_stopped & wb_empty & unformatter_empty &
                                    ~ctl_trace_capt_en_rise)
                             : ffcr_drain_buffer_en ?
                                   (trace_mem_empty & unformatter_empty)
                             : tmc_enabled && hw_fifo_mode ?
                                   (ft_stopped & trace_mem_empty & wb_empty & unformatter_empty &
                                    ~ctl_trace_capt_en_rise)
                             : tmc_enabled && (sw_fifo_mode1 || circ_buf_mode) ?
                                   (ft_stopped & wb_empty & ~ctl_trace_capt_en_rise) : 1'b1;
      end
    else if (TMC_CONFIG == ETR)
      begin : gen_tmcready_etr
        assign nxt_tmc_ready = tmc_enabled ? (ft_stopped & wb_empty & axi_intf_ready & ~ctl_trace_capt_en_rise)
                                           :  1'b1;
      end
    else if (TMC_CONFIG == ETS)
      begin : gen_tmcready_ets
        assign nxt_tmc_ready = tmc_enabled ? (ft_stopped & wb_empty & ~ctl_trace_capt_en_rise)
                                           :  1'b1;
      end
    else
      begin : gen_tmcready_etb
        assign nxt_tmc_ready = tmc_enabled ? (ft_stopped & wb_empty & ~ctl_trace_capt_en_rise)
                                           :  1'b1;
      end
  endgenerate

  always @ (posedge clk or negedge reset_n)
  begin : s_tmc_ready
    if (!reset_n)
      tmc_ready <= 1'b1;
    else if (cg_en)
      tmc_ready <= nxt_tmc_ready;
  end


  assign nxt_acqcomp = itctrl_ime ? (it_evt_intr_wr_en ? apb_wdata_p[0] : acqcomp)
                                  :  acqcomp_func;

  always @ (posedge clk or negedge reset_n)
  begin : s_acqcomp
    if (!reset_n)
      acqcomp <= 1'b0;
    else if (cg_en)
      acqcomp <= nxt_acqcomp;
  end

  generate
    if (TMC_CONFIG == ETF)
      begin : gen_acqcomp_func_etf
        wire nxt_drain_in_prog;
        reg  drain_in_prog;

        assign nxt_drain_in_prog = ffcr_drain_buffer_en | (drain_in_prog & ~tmc_ready);

        always @ (posedge clk or negedge reset_n)
        begin : s_drain_in_prog
          if (!reset_n)
            drain_in_prog <= 1'b0;
          else if (cg_en)
            drain_in_prog <= nxt_drain_in_prog;
        end

        assign acqcomp_func = tmc_enabled & ~ctl_trace_capt_en_rise & (tmc_ready | drain_in_prog);
      end
    else if (TMC_CONFIG == ETR)
      begin : gen_acqcomp_func_etr
        wire nxt_tmc_writes_done;
        reg  tmc_writes_done;

        assign nxt_tmc_writes_done = ~ctl_trace_capt_en_rise &
                                     (tmc_writes_done | nxt_tmc_ready);

        always @ (posedge clk or negedge reset_n)
        begin : s_tmc_writes_done
          if (!reset_n)
            tmc_writes_done <= 1'b1;
          else if (cg_en)
            tmc_writes_done <= nxt_tmc_writes_done;
        end

        assign acqcomp_func = tmc_enabled & ~ctl_trace_capt_en_rise & tmc_writes_done;
      end
    else
      begin : gen_acqcomp_func_etb
        assign acqcomp_func = tmc_enabled & ~ctl_trace_capt_en_rise & tmc_ready;
      end
  endgenerate


  assign tmc_enabled     =     ctl_trace_capt_en |     ~tmc_ready;
  assign nxt_tmc_enabled = nxt_ctl_trace_capt_en | ~nxt_tmc_ready;

  always @ (posedge clk or negedge reset_n)
  begin : s_tmc_enabled_r
    if (!reset_n)
      tmc_enabled_r <= 1'b0;
    else if (cg_en)
      tmc_enabled_r <= tmc_enabled;
  end

  assign ft_empty = (~tmc_enabled | acqcomp_func);


  generate
    if (TMC_CONFIG != ETS)
      begin : gen_tmc_abort
        reg tmc_abort_r;

        assign tmc_abort = (tmc_enabled & ctl_trace_capt_en_fall & (~circ_buf_mode | ffcr_drain_buffer_en)) |
                           (tmc_abort_r & ~tmc_ready);

        always @ (posedge clk or negedge reset_n)
        begin : s_tmc_abort_r
          if (!reset_n)
            tmc_abort_r <= 1'b0;
          else if (cg_en)
            tmc_abort_r <= tmc_abort;
        end
      end
    else
      begin : dont_gen_tmc_abort
        assign tmc_abort = 1'b0;
      end
  endgenerate


  generate
    if (TMC_CONFIG != ETS)
      begin : gen_apbreadfifo_clr
        assign apbreadfifo_clr = ctl_trace_capt_en_rise | rrp_wr_en | rrp_hi_wr_en |
                                (ctl_trace_capt_en_fall & ~circ_buf_mode);
      end
    else
      begin : dont_gen_apbreadfifo_clr
        assign apbreadfifo_clr = 1'b0;
      end
  endgenerate


  assign int_clk_en = itctrl_ime | psel_s | ctl_trace_capt_en | ~tmc_ready | tmc_enabled_r | flushcomp
                    | (lp_done                   & dev_run)
                    | (nxt_afreadym & ~afready_m & dev_run)
                    ;


  generate
    if (TMC_CONFIG == ETR)
      begin : gen_unprog_det_etr1
        wire unprog_rsz_clr;
        wire unprog_sts_clr;
        wire unprog_axictl_clr;
        wire unprog_dbalo_clr;

        reg  unprog_rsz_int;
        reg  unprog_sts_int;
        reg  unprog_axictl_int;
        reg  unprog_dbalo_int;

        assign unprog_rsz_clr     = cg_en & unprog_rsz    & (rsz_wr_en      | ctl_trace_capt_en_rise);
        assign unprog_rsz_init    =         unprog_rsz    & ~rsz_wr_en      & ctl_trace_capt_en_rise ;
        assign unprog_sts_clr     = cg_en & unprog_sts    & (sts_full_wr_en | ctl_trace_capt_en_rise);
        assign unprog_axictl_clr  = cg_en & unprog_axictl & (axi_ctl_wr_en  | ctl_trace_capt_en_rise);
        assign unprog_axictl_init =         unprog_axictl & ~axi_ctl_wr_en  & ctl_trace_capt_en_rise ;
        assign unprog_dbalo_clr   = cg_en & unprog_dbalo  & (dba_lo_wr_en   | ctl_trace_capt_en_rise);
        assign unprog_dbalo_init  =         unprog_dbalo  & ~dba_lo_wr_en   & ctl_trace_capt_en_rise ;

        always @ (posedge clk or negedge reset_n)
        begin : s_unprog_regs
          if (!reset_n)
            begin
              unprog_rsz_int    <= 1'b1;
              unprog_sts_int    <= 1'b1;
              unprog_axictl_int <= 1'b1;
              unprog_dbalo_int  <= 1'b1;
            end
          else
            begin
              if (unprog_rsz_clr)    unprog_rsz_int    <= 1'b0;
              if (unprog_sts_clr)    unprog_sts_int    <= 1'b0;
              if (unprog_axictl_clr) unprog_axictl_int <= 1'b0;
              if (unprog_dbalo_clr)  unprog_dbalo_int  <= 1'b0;
            end
        end

        assign unprog_rsz         = unprog_rsz_int;
        assign unprog_sts         = unprog_sts_int;
        assign unprog_axictl      = unprog_axictl_int;
        assign unprog_dbalo       = unprog_dbalo_int;

      end
    else if (TMC_CONFIG == ETS)
      begin : gen_unprog_det_ets1
        wire unprog_sts_clr;
        reg  unprog_sts_int;

        assign unprog_sts_clr = cg_en & unprog_sts & (sts_full_wr_en | ctl_trace_capt_en_rise);

        always @ (posedge clk or negedge reset_n)
        begin : s_unprog_regs
          if (!reset_n)
            unprog_sts_int <= 1'b1;
          else if (unprog_sts_clr)
            unprog_sts_int <= 1'b0;
        end

        assign unprog_sts         = unprog_sts_int;
        assign unprog_rsz         = 1'b0;
        assign unprog_axictl      = 1'b0;
        assign unprog_axictl_init = 1'b0;
        assign unprog_dbalo       = 1'b0;
        assign unprog_dbalo_init  = 1'b0;

      end
    else
      begin : gen_unprog_det_etbetf1
        assign unprog_sts         = 1'b0;
        assign unprog_rsz         = 1'b0;
        assign unprog_axictl      = 1'b0;
        assign unprog_axictl_init = 1'b0;
        assign unprog_dbalo       = 1'b0;
        assign unprog_dbalo_init  = 1'b0;
      end
  endgenerate

  generate
    if ((TMC_CONFIG == ETR) && (AXI_ADDR_WIDTH > 32))
      begin : gen_unprog_det_etr2
        wire unprog_rrphi_clr;
        wire unprog_rwphi_clr;
        wire unprog_dbahi_clr;

        reg  unprog_rrphi_int;
        reg  unprog_rwphi_int;
        reg  unprog_dbahi_int;

        assign unprog_rrphi_clr  = cg_en & unprog_rrphi & (rrp_hi_wr_en | ctl_trace_capt_en_rise);
        assign unprog_rwphi_clr  = cg_en & unprog_rwphi & (rwp_hi_wr_en | ctl_trace_capt_en_rise);
        assign unprog_dbahi_clr  = cg_en & unprog_dbahi & (dba_hi_wr_en | ctl_trace_capt_en_rise);
        assign unprog_dbahi_init =         unprog_dbahi & ~dba_hi_wr_en & ctl_trace_capt_en_rise ;

        always @ (posedge clk or negedge reset_n)
        begin : s_unprog_regs
          if (!reset_n)
            begin
              unprog_rrphi_int <= 1'b1;
              unprog_rwphi_int <= 1'b1;
              unprog_dbahi_int <= 1'b1;
            end
          else
            begin
              if (unprog_rrphi_clr) unprog_rrphi_int <= 1'b0;
              if (unprog_rwphi_clr) unprog_rwphi_int <= 1'b0;
              if (unprog_dbahi_clr) unprog_dbahi_int <= 1'b0;
            end
        end

        assign unprog_rrphi = unprog_rrphi_int;
        assign unprog_rwphi = unprog_rwphi_int;
        assign unprog_dbahi = unprog_dbahi_int;

      end
    else
      begin : dont_gen_unprog_det_etr2
        assign unprog_rrphi      = 1'b0;
        assign unprog_rwphi      = 1'b0;
        assign unprog_dbahi      = 1'b0;
        assign unprog_dbahi_init = 1'b0;
      end
  endgenerate

  generate
    if (TMC_CONFIG != ETS)
      begin : gen_unprog_det_nonets
        wire unprog_rrp_clr;
        wire unprog_rwp_clr;
        wire unprog_mode_clr;
        wire unprog_bufwm_clr;

        reg  unprog_rrp_int;
        reg  unprog_rwp_int;
        reg  unprog_mode_int;
        reg  unprog_bufwm_int;

        assign unprog_rrp_clr    = cg_en & unprog_rrp   & (rrp_wr_en    | ctl_trace_capt_en_rise);
        assign unprog_rwp_clr    = cg_en & unprog_rwp   & (rwp_wr_en    | ctl_trace_capt_en_rise);
        assign unprog_mode_clr   = cg_en & unprog_mode  & (mode_wr_en   | ctl_trace_capt_en_rise);
        assign unprog_mode_init  =         unprog_mode  & ~mode_wr_en   & ctl_trace_capt_en_rise ;
        assign unprog_bufwm_clr  = cg_en & unprog_bufwm & (buf_wm_wr_en | ctl_trace_capt_en_rise);
        assign unprog_bufwm_init =         unprog_bufwm & ~buf_wm_wr_en & ctl_trace_capt_en_rise ;

        always @ (posedge clk or negedge reset_n)
        begin : s_unprog_regs
          if (!reset_n)
            begin
              unprog_rrp_int   <= 1'b1;
              unprog_rwp_int   <= 1'b1;
              unprog_mode_int  <= 1'b1;
              unprog_bufwm_int <= 1'b1;
            end
          else
            begin
              if (unprog_rrp_clr)   unprog_rrp_int   <= 1'b0;
              if (unprog_rwp_clr)   unprog_rwp_int   <= 1'b0;
              if (unprog_mode_clr)  unprog_mode_int  <= 1'b0;
              if (unprog_bufwm_clr) unprog_bufwm_int <= 1'b0;
            end
        end

        assign unprog_rrp   = unprog_rrp_int;
        assign unprog_rwp   = unprog_rwp_int;
        assign unprog_mode  = unprog_mode_int;
        assign unprog_bufwm = unprog_bufwm_int;

        assign ptr_prog = unprog_rrp & unprog_rwp & (unprog_rrp_clr | unprog_rwp_clr);

      end
    else
      begin : dont_gen_unprog_det_nonets
        assign unprog_rrp        = 1'b0;
        assign unprog_rwp        = 1'b0;
        assign unprog_mode       = 1'b0;
        assign unprog_mode_init  = 1'b0;
        assign unprog_bufwm      = 1'b0;
        assign unprog_bufwm_init = 1'b0;

        assign ptr_prog = 1'b0;
      end
  endgenerate

  assign unprog_trg_clr = cg_en & unprog_trg & (trg_wr_en | ctl_trace_capt_en_rise);

  always @ (posedge clk or negedge reset_n)
  begin : s_unprog_regs
    if (!reset_n)
      unprog_trg <= 1'b1;
    else if (unprog_trg_clr)
      unprog_trg <= 1'b0;
  end


endmodule


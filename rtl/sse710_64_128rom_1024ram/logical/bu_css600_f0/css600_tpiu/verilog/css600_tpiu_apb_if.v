//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2018 Arm Limited or its affiliates.
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
//   Sub-module of css600_tpiu
//
//----------------------------------------------------------------------------


module css600_tpiu_apb_if
(
  input  wire        clk,
  input  wire        reset_n,


  input  wire        psel_s,
  input  wire        penable_s,
  input  wire        pwrite_s,
  input  wire [11:0] paddr_s,
  input  wire [31:0] pwdata_s,
  output  reg [31:0] prdata_s,
  output wire        pready_s,
  output wire        pslverr_s,
  output reg [1:0]   pstate,

  output wire        tp_xfer_req,
  output wire        tp_xfer_type,
  output wire  [1:0] tp_addr_enc,
  output wire [31:0] tp_wdata,
  input  wire        tp_xfer_ack_sync,
  input  wire [31:0] tp_rdata_sync,

  input  wire        dev_run,

  input  wire        ft_stopped,
  input  wire        ft_stopped_done,
  input  wire        fl_in_prog,
  input  wire        ffcr_flush_man_clr,
  output wire        trg_wr_en,
  output wire [38:0] trg_wdata,
  input  wire        trg_done,
  input  wire        sts_running,
  input  wire        sts_triggered,
  output wire        sts_triggered_clr,

  input  wire        tpctl_valid,
  input  wire  [4:0] tp_maxdatasize,

  input  wire  [7:0] extctl_in,
  output  reg  [7:0] extctl_out,

  output wire        ffcr_embed_flush_masked,
  output  reg        ffcr_stop_trig,
  output  reg        ffcr_stop_flush,
  output  reg        ffcr_trig_on_fl,
  output  reg        ffcr_trig_evt,
  output  reg        ffcr_trig_in,
  output  reg        ffcr_flush_man,
  output  reg        ffcr_fl_on_trig,
  output  reg        ffcr_flush_in,
  output  reg        ffcr_en_fcont,
  output  wire       ffcr_en_formatting_masked,

  output  reg        itctrl_ime,
  output wire        integ_mode_entry,
  output wire        ittrflin_rd_en,
  input  wire        it_trigin,
  input  wire        it_flushin,
  input  wire  [4:0] it_atdata,
  output  reg        it_syncreq,
  output wire        itatbctr2_wr_en,
  output wire        itoutctr_wr_en,
  input  wire  [6:0] it_atid,
  input  wire  [1:0] it_atbytes,
  input  wire        it_atwakeup,
  input  wire        it_afready,
  input  wire        it_atvalid,

  input  wire   [3:0] revand
);

  `include "css600_tpiu_localparams.v"
  localparam ST_APBSLV_IDLE    = 2'b00;
  localparam ST_APBSLV_RDY     = 2'b11;
  localparam ST_APBSLV_WAIT    = 2'b10;
  localparam ST_APBSLV_WAITP   = 2'b01;
  localparam ST_APBSLV_UNDEF   = 2'bxx;


  wire              supp_psize_sel;
  wire              curr_psize_sel;
  wire              supp_trig_sel;
  wire              trig_count_sel;
  wire              trig_mult_sel;
  wire              supp_tpatt_sel;
  wire              curr_tpatt_sel;
  wire              tpatt_rpt_sel;
  wire              ffsr_sel;
  wire              ffcr_sel;
  wire              fscr_sel;
  wire              extctlin_sel;
  wire              extctlout_sel;
  wire              ittrflin_sel;
  wire              itatbdata0_sel;
  wire              itatbctr2_sel;
  wire              itatbctr1_sel;
  wire              itatbctr0_sel;
  wire              itoutctr_sel;
  wire              itctrl_sel;
  wire              claimset_sel;
  wire              claimclr_sel;
  wire              devid_sel;
  wire              devtype_sel;
  wire [4:0]        pidr_sel;
  wire [3:0]        cidr_sel;

  wire              supp_psize_rd_en;
  wire              supp_trig_rd_en;
  wire              trig_count_wr_en;
  wire              trig_count_rd_en;
  wire              trig_mult_wr_en;
  wire              trig_mult_rd_en;
  wire              supp_tpatt_rd_en;
  wire              ffsr_rd_en;
  wire              ffcr_wr_en;
  wire              ffcr_fl_man_wr_en;
  wire              ffcr_wr_en_modes;
  wire              ffcr_rd_en;
  wire              extctlin_rd_en;
  wire              extctlout_wr_en;
  wire              extctlout_rd_en;
  wire              itatbdata0_rd_en;
  wire              itatbctr1_rd_en;
  wire              itatbctr0_rd_en;
  wire              itctrl_wr_en;
  wire              itctrl_rd_en;
  wire              claimset_wr_en;
  wire              claimset_rd_en;
  wire              claimclr_wr_en;
  wire              claimclr_rd_en;
  wire              devid_rd_en;
  wire              devtype_rd_en;
  wire [4:0]        pidr_rd_en;
  wire [3:0]        cidr_rd_en;

  wire [31:0]       supp_psize_rd_data;
  wire [31:0]       supp_trig_rd_data;
  wire [31:0]       trig_count_rd_data;
  wire [31:0]       trig_mult_rd_data;
  wire [31:0]       supp_tpatt_rd_data;
  wire [31:0]       ffsr_rd_data;
  wire [31:0]       ffcr_rd_data;
  wire [31:0]       extctlin_rd_data;
  wire [31:0]       extctlout_rd_data;
  wire [31:0]       ittrflin_rd_data;
  wire [31:0]       itatbdata0_rd_data;
  wire [31:0]       itatbctr1_rd_data;
  wire [31:0]       itatbctr0_rd_data;
  wire [31:0]       itctrl_rd_data;
  wire [31:0]       claimset_rd_data;
  wire [31:0]       claimclr_rd_data;
  wire [31:0]       devid_rd_data;
  wire [31:0]       devtype_rd_data;
  wire [31:0]       pidr0_rd_data;
  wire [31:0]       pidr1_rd_data;
  wire [31:0]       pidr2_rd_data;
  wire [31:0]       pidr3_rd_data;
  wire [31:0]       pidr4_rd_data;
  wire [31:0]       cidr0_rd_data;
  wire [31:0]       cidr1_rd_data;
  wire [31:0]       cidr2_rd_data;
  wire [31:0]       cidr3_rd_data;

  wire              nxt_penable_reconst;
  wire [31:0]       nxt_prdata;
  wire              rd_data_en;

  wire              apb_setup_normal;
  wire              apb_setup_wake;
  wire              apb_select;
  wire              reg_access;
  wire              tp_reg_access;
  wire              state_en;
  wire              reg_write;
  wire              reg_read;
  wire              save_tp_req;
  wire              start_tp_req;
  wire              nxt_tp_req;
  wire              tp_acc_done;
  wire              tp_reg_rd_en;

  wire [30:0]       tp_maxsize_decode;
  wire [31:0]       tp_present;
  reg               ffcr_en_ft;
  reg               ffcr_embed_flush;

  reg               sts_triggered_clr_q;

  reg               reg_write_ready;
  reg [1:0]     nxt_pstate;
  reg               state_trans;
  reg               penable_reconst;
  reg [1:0]         nxt_tp_addr_enc;
  reg               tp_xfer_req_cdc_chk;
  reg               tp_xfer_type_cdc_chk;
  reg [1:0]         tp_addr_enc_cdc_chk;
  reg [31:0]        tp_wdata_cdc_chk;
  reg [7:0]         tcvr_trigcount;
  reg               tcmr_mult64k;
  reg               tcmr_mult256;
  reg               tcmr_mult16;
  reg               tcmr_mult4;
  reg               tcmr_mult2;


  assign supp_psize_sel = ({paddr_s[11:2], 2'b00} == REGA_SSPSR);
  assign curr_psize_sel = ({paddr_s[11:2], 2'b00} == REGA_CSPSR);
  assign supp_trig_sel  = ({paddr_s[11:2], 2'b00} == REGA_STMR);
  assign trig_count_sel = ({paddr_s[11:2], 2'b00} == REGA_TCVR);
  assign trig_mult_sel  = ({paddr_s[11:2], 2'b00} == REGA_TCMR);
  assign supp_tpatt_sel = ({paddr_s[11:2], 2'b00} == REGA_STPMR);
  assign curr_tpatt_sel = ({paddr_s[11:2], 2'b00} == REGA_CTPMR);
  assign tpatt_rpt_sel  = ({paddr_s[11:2], 2'b00} == REGA_TPRCR);
  assign ffsr_sel       = ({paddr_s[11:2], 2'b00} == REGA_FFSR);
  assign ffcr_sel       = ({paddr_s[11:2], 2'b00} == REGA_FFCR);
  assign fscr_sel       = ({paddr_s[11:2], 2'b00} == REGA_FSCR);
  assign extctlin_sel   = ({paddr_s[11:2], 2'b00} == REGA_EXTCTLIN);
  assign extctlout_sel  = ({paddr_s[11:2], 2'b00} == REGA_EXTCTLOUT);
  assign ittrflin_sel   = ({paddr_s[11:2], 2'b00} == REGA_ITTRFLIN);
  assign itatbdata0_sel = ({paddr_s[11:2], 2'b00} == REGA_ITATBDATA0);
  assign itatbctr2_sel  = ({paddr_s[11:2], 2'b00} == REGA_ITATBCTR2);
  assign itatbctr1_sel  = ({paddr_s[11:2], 2'b00} == REGA_ITATBCTR1);
  assign itatbctr0_sel  = ({paddr_s[11:2], 2'b00} == REGA_ITATBCTR0);
  assign itoutctr_sel   = ({paddr_s[11:2], 2'b00} == REGA_ITOUTCTR);
  assign itctrl_sel     = ({paddr_s[11:2], 2'b00} == REGA_ITCTRL);
  assign claimset_sel   = ({paddr_s[11:2], 2'b00} == REGA_CLAIMSET);
  assign claimclr_sel   = ({paddr_s[11:2], 2'b00} == REGA_CLAIMCLR);
  assign devid_sel      = ({paddr_s[11:2], 2'b00} == REGA_DEVID);
  assign devtype_sel    = ({paddr_s[11:2], 2'b00} == REGA_DEVTYPE);
  assign pidr_sel[0]    = ({paddr_s[11:2], 2'b00} == REGA_PIDR0);
  assign pidr_sel[1]    = ({paddr_s[11:2], 2'b00} == REGA_PIDR1);
  assign pidr_sel[2]    = ({paddr_s[11:2], 2'b00} == REGA_PIDR2);
  assign pidr_sel[3]    = ({paddr_s[11:2], 2'b00} == REGA_PIDR3);
  assign pidr_sel[4]    = ({paddr_s[11:2], 2'b00} == REGA_PIDR4);
  assign cidr_sel[0]    = ({paddr_s[11:2], 2'b00} == REGA_CIDR0);
  assign cidr_sel[1]    = ({paddr_s[11:2], 2'b00} == REGA_CIDR1);
  assign cidr_sel[2]    = ({paddr_s[11:2], 2'b00} == REGA_CIDR2);
  assign cidr_sel[3]    = ({paddr_s[11:2], 2'b00} == REGA_CIDR3);


  always @ (posedge clk or negedge reset_n)
  begin : p_penable_reconst
    if (!reset_n)
      penable_reconst <= 1'b0;
    else if (dev_run)
      penable_reconst <= nxt_penable_reconst;
  end

  assign nxt_penable_reconst = psel_s & (pstate != ST_APBSLV_RDY) & (pstate != ST_APBSLV_WAITP);

  assign apb_setup_normal = (psel_s & ~penable_s) & dev_run;

  assign apb_setup_wake = (psel_s & ~penable_reconst) & dev_run;

  assign apb_select = (apb_setup_normal | apb_setup_wake) & (pstate != ST_APBSLV_WAITP);

  assign reg_access = apb_select & (supp_psize_sel | curr_psize_sel |
                       supp_trig_sel | trig_count_sel | trig_mult_sel |
                       supp_tpatt_sel | curr_tpatt_sel | tpatt_rpt_sel |
                       ffsr_sel | ffcr_sel | fscr_sel |
                       extctlin_sel | extctlout_sel |
                       ittrflin_sel | itatbdata0_sel | itatbctr2_sel |
                       itatbctr1_sel | itatbctr0_sel | itoutctr_sel |
                       itctrl_sel | claimset_sel | claimclr_sel |
                       devid_sel | devtype_sel | (|pidr_sel) | (|cidr_sel));

  assign reg_write = reg_access & pwrite_s;
  assign reg_read  = reg_access & ~pwrite_s;


  always @ *
  begin : p_apbslv_fsm_comb
    case (pstate)
      ST_APBSLV_IDLE :
        begin
          nxt_pstate  = (tp_reg_access && pwrite_s) ? ST_APBSLV_RDY
                      : (tp_reg_access            ) ? ST_APBSLV_WAIT
                      :                               ST_APBSLV_RDY
                      ;
          state_trans = apb_select;
        end
      ST_APBSLV_RDY  :
        begin
          nxt_pstate  = (tp_reg_access && pwrite_s) ? ST_APBSLV_WAITP
                      :                               ST_APBSLV_IDLE
                      ;
          state_trans = 1'b1;
        end
      ST_APBSLV_WAIT :
        begin
          nxt_pstate  = ST_APBSLV_RDY;
          state_trans = tp_acc_done;
        end
      ST_APBSLV_WAITP :
        begin
          nxt_pstate  = ST_APBSLV_IDLE;
          state_trans = tp_acc_done;
        end

      default :
        begin
          nxt_pstate  = ST_APBSLV_UNDEF;
          state_trans = 1'b1;
        end
    endcase
  end

  assign state_en = state_trans & dev_run;

  always @ (posedge clk or negedge reset_n)
  begin : p_pstate
    if (!reset_n)
      pstate <= ST_APBSLV_IDLE;
    else if (state_en)
      pstate <= nxt_pstate;
  end


  assign supp_psize_rd_en = supp_psize_sel & reg_read;

  assign supp_psize_rd_data = (tp_present & REGV_SSPSR);

  assign tp_maxsize_decode = {(tp_maxdatasize == 5'b11111),
                              (tp_maxdatasize == 5'b11110),
                              (tp_maxdatasize == 5'b11101),
                              (tp_maxdatasize == 5'b11100),
                              (tp_maxdatasize == 5'b11011),
                              (tp_maxdatasize == 5'b11010),
                              (tp_maxdatasize == 5'b11001),
                              (tp_maxdatasize == 5'b11000),
                              (tp_maxdatasize == 5'b10111),
                              (tp_maxdatasize == 5'b10110),
                              (tp_maxdatasize == 5'b10101),
                              (tp_maxdatasize == 5'b10100),
                              (tp_maxdatasize == 5'b10011),
                              (tp_maxdatasize == 5'b10010),
                              (tp_maxdatasize == 5'b10001),
                              (tp_maxdatasize == 5'b10000),
                              (tp_maxdatasize == 5'b01111),
                              (tp_maxdatasize == 5'b01110),
                              (tp_maxdatasize == 5'b01101),
                              (tp_maxdatasize == 5'b01100),
                              (tp_maxdatasize == 5'b01011),
                              (tp_maxdatasize == 5'b01010),
                              (tp_maxdatasize == 5'b01001),
                              (tp_maxdatasize == 5'b01000),
                              (tp_maxdatasize == 5'b00111),
                              (tp_maxdatasize == 5'b00110),
                              (tp_maxdatasize == 5'b00101),
                              (tp_maxdatasize == 5'b00100),
                              (tp_maxdatasize == 5'b00011),
                              (tp_maxdatasize == 5'b00010),
                              (tp_maxdatasize == 5'b00001)};

  assign tp_present = { tp_maxsize_decode[30],
                       |tp_maxsize_decode[30:29],
                       |tp_maxsize_decode[30:28],
                       |tp_maxsize_decode[30:27],
                       |tp_maxsize_decode[30:26],
                       |tp_maxsize_decode[30:25],
                       |tp_maxsize_decode[30:24],
                       |tp_maxsize_decode[30:23],
                       |tp_maxsize_decode[30:22],
                       |tp_maxsize_decode[30:21],
                       |tp_maxsize_decode[30:20],
                       |tp_maxsize_decode[30:19],
                       |tp_maxsize_decode[30:18],
                       |tp_maxsize_decode[30:17],
                       |tp_maxsize_decode[30:16],
                       |tp_maxsize_decode[30:15],
                       |tp_maxsize_decode[30:14],
                       |tp_maxsize_decode[30:13],
                       |tp_maxsize_decode[30:12],
                       |tp_maxsize_decode[30:11],
                       |tp_maxsize_decode[30:10],
                       |tp_maxsize_decode[30:9],
                       |tp_maxsize_decode[30:8],
                       |tp_maxsize_decode[30:7],
                       |tp_maxsize_decode[30:6],
                       |tp_maxsize_decode[30:5],
                       |tp_maxsize_decode[30:4],
                       |tp_maxsize_decode[30:3],
                       |tp_maxsize_decode[30:2],
                       |tp_maxsize_decode[30:1],
                       |tp_maxsize_decode[30:0],
                       1'b1 };


  assign supp_trig_rd_en = supp_trig_sel & reg_read;

  assign supp_trig_rd_data = {14'b0,
                              sts_running,
                              sts_triggered,
                              7'b0,
                              REGV_STMR_TCOUNT8,
                              3'b0,
                              REGV_STMR_MULT64K,
                              REGV_STMR_MULT256,
                              REGV_STMR_MULT16,
                              REGV_STMR_MULT4,
                              REGV_STMR_MULT2};

  assign trig_count_wr_en = trig_count_sel & reg_write;
  assign trig_count_rd_en = trig_count_sel & reg_read;


  always @ (posedge clk or negedge reset_n)
  begin : p_tcvr
    if (!reset_n)
    begin
      sts_triggered_clr_q <= 1'b0;
      tcvr_trigcount        <= 8'b0;
    end
    else
    begin
      sts_triggered_clr_q <= sts_triggered_clr;
      if (trig_count_wr_en)
        tcvr_trigcount      <= pwdata_s[7:0];
    end
  end

  wire [7           :0]  tcvr_trigcount_x1;
  wire [7+16        :0]  tcvr_trigcount_x64k;
  wire [7+16+8      :0]  tcvr_trigcount_x64k_x256;
  wire [7+16+8+4    :0]  tcvr_trigcount_x64k_x256_x16;
  wire [7+16+8+4+2  :0]  tcvr_trigcount_x64k_x256_x16_x4;
  wire [7+16+8+4+2+1:0]  tcvr_trigcount_x64k_x256_x16_x4_x2;


  assign tcvr_trigcount_x1                  = tcvr_trigcount;
  assign tcvr_trigcount_x64k                = (tcmr_mult64k) ? {tcvr_trigcount_x1,16'b0             } : {16'b0,tcvr_trigcount_x1};
  assign tcvr_trigcount_x64k_x256           = (tcmr_mult256) ? {tcvr_trigcount_x64k,8'b0            } : {8'b0,tcvr_trigcount_x64k};
  assign tcvr_trigcount_x64k_x256_x16       = (tcmr_mult16 ) ? {tcvr_trigcount_x64k_x256,4'b0       } : {4'b0,tcvr_trigcount_x64k_x256};
  assign tcvr_trigcount_x64k_x256_x16_x4    = (tcmr_mult4  ) ? {tcvr_trigcount_x64k_x256_x16,2'b0   } : {2'b0,tcvr_trigcount_x64k_x256_x16};
  assign tcvr_trigcount_x64k_x256_x16_x4_x2 = (tcmr_mult2  ) ? {tcvr_trigcount_x64k_x256_x16_x4,1'b0} : {1'b0,tcvr_trigcount_x64k_x256_x16_x4};
  assign trg_wdata = tcvr_trigcount_x64k_x256_x16_x4_x2;

  assign sts_triggered_clr          = trig_count_wr_en | trig_mult_wr_en;
  assign trg_wr_en                  = sts_triggered_clr_q
                                    | trg_done
                                    | ft_stopped_done
                                    ;

  assign trig_count_rd_data         = {24'b0,
                                       tcvr_trigcount};

  assign trig_mult_wr_en = trig_mult_sel & reg_write;
  assign trig_mult_rd_en = trig_mult_sel & reg_read;

  always @ (posedge clk or negedge reset_n) begin : p_tcmr_mult64k
    if (!reset_n)             tcmr_mult64k <= 1'b0;
    else if (trig_mult_wr_en) tcmr_mult64k <= pwdata_s[4];
  end

  always @ (posedge clk or negedge reset_n) begin : p_tcmr_mult256k
    if (!reset_n)             tcmr_mult256 <= 1'b0;
    else if (trig_mult_wr_en) tcmr_mult256 <= pwdata_s[3];
  end

  always @ (posedge clk or negedge reset_n) begin : p_tcmr_mult16k
    if (!reset_n)             tcmr_mult16  <= 1'b0;
    else if (trig_mult_wr_en) tcmr_mult16  <= pwdata_s[2];
  end

  always @ (posedge clk or negedge reset_n) begin : p_tcmr_mult4k
    if (!reset_n)             tcmr_mult4   <= 1'b0;
    else if (trig_mult_wr_en) tcmr_mult4   <= pwdata_s[1];
  end

  always @ (posedge clk or negedge reset_n) begin : p_tcmr_mult2k
    if (!reset_n)             tcmr_mult2   <= 1'b0;
    else if (trig_mult_wr_en) tcmr_mult2   <= pwdata_s[0];
  end

  assign trig_mult_rd_data = {27'b0,
                              tcmr_mult64k,
                              tcmr_mult256,
                              tcmr_mult16,
                              tcmr_mult4,
                              tcmr_mult2};

  assign supp_tpatt_rd_en = supp_tpatt_sel & reg_read;

  assign supp_tpatt_rd_data = {14'b0,
                               REGV_STPMR_PCONTEN,
                               REGV_STPMR_PTIMEEN,
                               12'b0,
                               REGV_STPMR_PATF0,
                               REGV_STPMR_PATA5,
                               REGV_STPMR_PATW0,
                               REGV_STPMR_PATW1};


  assign ffsr_rd_en = ffsr_sel & reg_read;

  assign ffsr_rd_data = {29'b0,
                         tpctl_valid,
                         ft_stopped,
                         fl_in_prog};


  assign ffcr_fl_man_wr_en = ffcr_sel & reg_write_ready;
  assign ffcr_wr_en = ffcr_sel & reg_write;
  assign ffcr_rd_en = ffcr_sel & reg_read;

  assign ffcr_wr_en_modes = ffcr_wr_en & ft_stopped;

  always @ (posedge clk or negedge reset_n)
  begin : p_reg_wr_reg
    if (!reset_n)
      begin
        reg_write_ready  <= 1'b0;
      end
    else
      begin
        reg_write_ready  <= reg_write;
      end
  end


  always @ (posedge clk or negedge reset_n)
  begin : p_ffcr
    if (!reset_n)
      begin
        ffcr_embed_flush <= 1'b0;
        ffcr_stop_trig   <= 1'b0;
        ffcr_stop_flush  <= 1'b1;
        ffcr_trig_on_fl  <= 1'b0;
        ffcr_trig_evt    <= 1'b0;
        ffcr_trig_in     <= 1'b0;
        ffcr_flush_man   <= 1'b0;
        ffcr_fl_on_trig  <= 1'b0;
        ffcr_flush_in    <= 1'b0;
        ffcr_en_fcont    <= 1'b0;
        ffcr_en_ft       <= 1'b0;
      end
    else
      begin
        if (ffcr_wr_en)         ffcr_embed_flush <=  pwdata_s[15];
        if (ffcr_wr_en)         ffcr_stop_trig   <=  pwdata_s[13];
        if (ffcr_wr_en)         ffcr_stop_flush  <=  pwdata_s[12];
        if (ffcr_wr_en)         ffcr_trig_on_fl  <=  pwdata_s[10];
        if (ffcr_wr_en)         ffcr_trig_evt    <=  pwdata_s[9];
        if (ffcr_wr_en)         ffcr_trig_in     <=  pwdata_s[8];
        if (ffcr_flush_man_clr) ffcr_flush_man   <=  1'b0                        ;
        else if (ffcr_fl_man_wr_en)    ffcr_flush_man   <=  pwdata_s[6] | ffcr_flush_man;
        if (ffcr_wr_en)         ffcr_fl_on_trig  <=  pwdata_s[5];
        if (ffcr_wr_en)         ffcr_flush_in    <=  pwdata_s[4];
        if (ffcr_wr_en_modes)   ffcr_en_fcont    <=  pwdata_s[1];
        if (ffcr_wr_en_modes)   ffcr_en_ft       <= |pwdata_s[1:0];
      end
  end
  assign ffcr_en_formatting_masked = ffcr_en_ft | ffcr_en_fcont;
  assign ffcr_embed_flush_masked = ffcr_en_ft & ffcr_embed_flush;


  assign ffcr_rd_data = {16'b0,
                         ffcr_embed_flush,
                         1'b0,
                         ffcr_stop_trig,
                         ffcr_stop_flush,
                         1'b0,
                         ffcr_trig_on_fl,
                         ffcr_trig_evt,
                         ffcr_trig_in,
                         1'b0,
                         ffcr_flush_man,
                         ffcr_fl_on_trig,
                         ffcr_flush_in,
                         2'b0,
                         ffcr_en_fcont,
                         ffcr_en_ft};


  assign extctlin_rd_en = extctlin_sel & reg_read;

  assign extctlin_rd_data = {24'b0,
                             extctl_in};

  assign extctlout_wr_en = extctlout_sel & reg_write;
  assign extctlout_rd_en = extctlout_sel & reg_read;

  always @ (posedge clk or negedge reset_n)
  begin : p_extctlout
    if (!reset_n)
      extctl_out <= 8'b0;
    else if (extctlout_wr_en)
      extctl_out <= pwdata_s[7:0];
  end

  assign extctlout_rd_data = {24'b0,
                              extctl_out};

  assign ittrflin_rd_en = ittrflin_sel & reg_read & itctrl_ime;

  assign ittrflin_rd_data = {30'b0,
                             it_flushin,
                             it_trigin};

  assign itatbdata0_rd_en = itatbdata0_sel & reg_read & itctrl_ime;

  assign itatbdata0_rd_data = {27'b0,
                               it_atdata[4],
                               it_atdata[3],
                               it_atdata[2],
                               it_atdata[1],
                               it_atdata[0]};

  assign itatbctr2_wr_en = itatbctr2_sel & reg_write & itctrl_ime;

  always @ (posedge clk or negedge reset_n)
  begin : p_it_syncreq
    if (!reset_n)
      begin
        it_syncreq <= 1'b0;
      end
    else if (itatbctr2_wr_en)
      begin
        it_syncreq <= pwdata_s[2];
      end
  end

  assign itatbctr1_rd_en = itatbctr1_sel & reg_read & itctrl_ime;

  assign itatbctr1_rd_data = {25'b0,
                              it_atid};

  assign itatbctr0_rd_en = itatbctr0_sel & reg_read & itctrl_ime;

  assign itatbctr0_rd_data = {22'b0,
                              it_atbytes,
                              5'b0,
                              it_atwakeup,
                              it_afready,
                              it_atvalid};

  assign itoutctr_wr_en = itoutctr_sel & reg_write & itctrl_ime;

  assign integ_mode_entry = itctrl_wr_en & pwdata_s[0];

  assign itctrl_wr_en = itctrl_sel & reg_write & ft_stopped;
  assign itctrl_rd_en = itctrl_sel & reg_read;

  always @ (posedge clk or negedge reset_n)
  begin : p_itctrl
    if (!reset_n)
      itctrl_ime <= 1'b0;
    else if (itctrl_wr_en)
      itctrl_ime <= pwdata_s[0];
  end

  assign itctrl_rd_data = {31'h0,
                           itctrl_ime};

  assign claimset_wr_en = claimset_sel & reg_write;
  assign claimset_rd_en = claimset_sel & reg_read;

  assign claimclr_wr_en = claimclr_sel & reg_write;
  assign claimclr_rd_en = claimclr_sel & reg_read;

  css600_claimtags
    #(.NUM_CLAIM_TAGS(4))
    u_css600_claimtags
    (
      .clk               (clk),
      .reset_n           (reset_n),
      .claim_set_wr      (claimset_wr_en),
      .claim_set_wr_data (pwdata_s[3:0]),
      .claim_set_rd      (claimset_rd_en),
      .claim_set_rd_data (claimset_rd_data[3:0]),
      .claim_clr_wr      (claimclr_wr_en),
      .claim_clr_wr_data (pwdata_s[3:0]),
      .claim_clr_rd      (claimclr_rd_en),
      .claim_clr_rd_data (claimclr_rd_data[3:0])
    );

  assign claimset_rd_data[31:4] = 28'b0;
  assign claimclr_rd_data[31:4] = 28'b0;

  assign devid_rd_en = devid_sel & reg_read;

  assign devid_rd_data = {15'b0,
                          REGV_DEVID_CTLEN,
                          REGV_DEVID_RESERVED,
                          REGV_DEVID_SWOUARTNRZ,
                          REGV_DEVID_SWOMAN,
                          REGV_DEVID_TCLKDATA,
                          REGV_DEVID_FIFOSIZE,
                          REGV_DEVID_CLKRELAT,
                          REGV_DEVID_MUXNUM};

  assign devtype_rd_en = devtype_sel & reg_read;

  assign devtype_rd_data = {24'h0,
                            REGV_DEVTYPE_SUB,
                            REGV_DEVTYPE_MAJOR};

  assign pidr_rd_en[4:0] = pidr_sel[4:0] & {5{reg_read}};

  assign pidr0_rd_data = {24'h0,
                          REGV_PIDR0_PART0};

  assign pidr1_rd_data = {24'h0,
                          REGV_PIDR1_DES0,
                          REGV_PIDR1_PART1};

  assign pidr2_rd_data = {24'h0,
                          REGV_PIDR2_REVISION,
                          REGV_PIDR2_JEDEC,
                          REGV_PIDR2_DES1};

  assign pidr3_rd_data = {24'h0,
                          revand,
                          REGV_PIDR3_CMOD};

  assign pidr4_rd_data = {24'h0,
                          REGV_PIDR4_SIZE,
                          REGV_PIDR4_DES2};

  assign cidr_rd_en[3:0] = cidr_sel[3:0] & {4{reg_read}};

  assign cidr0_rd_data = {24'h0,
                          REGV_CIDR0_PRMBL0};

  assign cidr1_rd_data = {24'h0,
                          REGV_CIDR1_CLASS,
                          REGV_CIDR1_PRMBL1};

  assign cidr2_rd_data = {24'h0,
                          REGV_CIDR2_PRMBL2};

  assign cidr3_rd_data = {24'h0,
                          REGV_CIDR3_PRMBL3};


  assign tp_reg_access = (curr_psize_sel |
                          curr_tpatt_sel |
                          tpatt_rpt_sel |
                          fscr_sel);


  assign save_tp_req = apb_select & tp_reg_access;
  assign start_tp_req = pwrite_s ? tp_reg_access & pwrite_s & (pstate == ST_APBSLV_RDY )
                      :            save_tp_req
                      ;

  assign nxt_tp_req = start_tp_req | (tp_xfer_req_cdc_chk & ~tp_xfer_ack_sync);

  always @ (posedge clk or negedge reset_n)
  begin : p_tpxferreq
    if (!reset_n)
      tp_xfer_req_cdc_chk <= 1'b0;
    else
      tp_xfer_req_cdc_chk <= nxt_tp_req;
  end

  assign tp_acc_done = ~save_tp_req & ~tp_xfer_req_cdc_chk & ~tp_xfer_ack_sync;

  always @ *
  begin : p_tp_addr_comb
    case({curr_psize_sel,curr_tpatt_sel,tpatt_rpt_sel,fscr_sel})
      4'b1000 : nxt_tp_addr_enc = 2'b00;
      4'b0100 : nxt_tp_addr_enc = 2'b01;
      4'b0010 : nxt_tp_addr_enc = 2'b10;
      4'b0001 : nxt_tp_addr_enc = 2'b11;
      default : nxt_tp_addr_enc = 2'bxx;
    endcase
  end

  always @ (posedge clk or negedge reset_n)
  begin : p_tp_ctrl
    if (!reset_n)
      begin
        tp_xfer_type_cdc_chk <= 1'b0;
        tp_addr_enc_cdc_chk  <= 2'b0;
        tp_wdata_cdc_chk     <= 32'b0;
      end
    else if (save_tp_req)
      begin
        tp_xfer_type_cdc_chk <= pwrite_s;
        tp_addr_enc_cdc_chk  <= nxt_tp_addr_enc;
        tp_wdata_cdc_chk     <= pwdata_s[31:0];
      end
  end

  assign tp_reg_rd_en = (pstate==ST_APBSLV_WAIT) & tp_acc_done;


  assign pready_s = pstate == ST_APBSLV_RDY;

  assign pslverr_s = 1'b0;

  assign nxt_prdata = (
                        ({32{tp_reg_rd_en}}     & tp_rdata_sync) |
                        ({32{supp_psize_rd_en}} & supp_psize_rd_data) |
                        ({32{supp_trig_rd_en}}  & supp_trig_rd_data) |
                        ({32{trig_count_rd_en}} & trig_count_rd_data) |
                        ({32{trig_mult_rd_en}}  & trig_mult_rd_data) |
                        ({32{supp_tpatt_rd_en}} & supp_tpatt_rd_data) |
                        ({32{ffsr_rd_en}}       & ffsr_rd_data) |
                        ({32{ffcr_rd_en}}       & ffcr_rd_data) |
                        ({32{extctlin_rd_en}}   & extctlin_rd_data) |
                        ({32{extctlout_rd_en}}  & extctlout_rd_data) |
                        ({32{ittrflin_rd_en}}   & ittrflin_rd_data) |
                        ({32{itatbdata0_rd_en}} & itatbdata0_rd_data) |
                        ({32{itatbctr1_rd_en}}  & itatbctr1_rd_data) |
                        ({32{itatbctr0_rd_en}}  & itatbctr0_rd_data) |
                        ({32{itctrl_rd_en}}   & itctrl_rd_data) |
                        ({32{claimset_rd_en}} & claimset_rd_data) |
                        ({32{claimclr_rd_en}} & claimclr_rd_data) |
                        ({32{devid_rd_en}}    & devid_rd_data) |
                        ({32{devtype_rd_en}}  & devtype_rd_data) |
                        ({32{pidr_rd_en[0]}}  & pidr0_rd_data) |
                        ({32{pidr_rd_en[1]}}  & pidr1_rd_data) |
                        ({32{pidr_rd_en[2]}}  & pidr2_rd_data) |
                        ({32{pidr_rd_en[3]}}  & pidr3_rd_data) |
                        ({32{pidr_rd_en[4]}}  & pidr4_rd_data) |
                        ({32{cidr_rd_en[0]}}  & cidr0_rd_data) |
                        ({32{cidr_rd_en[1]}}  & cidr1_rd_data) |
                        ({32{cidr_rd_en[2]}}  & cidr2_rd_data) |
                        ({32{cidr_rd_en[3]}}  & cidr3_rd_data)
                      );

  assign rd_data_en = state_en & (nxt_pstate == ST_APBSLV_RDY) & ~pwrite_s;

  always @ (posedge clk or negedge reset_n)
  begin : p_prdata
    if (!reset_n)
      prdata_s <= 32'b0;
    else if (rd_data_en)
      prdata_s <= nxt_prdata;
  end


    assign tp_xfer_req  = tp_xfer_req_cdc_chk;
    assign tp_xfer_type = tp_xfer_type_cdc_chk;
    assign tp_addr_enc  = tp_addr_enc_cdc_chk[1:0];
    assign tp_wdata     = tp_wdata_cdc_chk[31:0];


endmodule


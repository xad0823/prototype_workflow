//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017, 2019 Arm Limited or its affiliates.
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
//   Sub-module of css600_apbap
//
//----------------------------------------------------------------------------


module css600_apbap_apbslv
(
  input  wire         clk,
  input  wire         reset_n,

  input  wire         psel_s,
  input  wire         penable_s,
  input  wire         pwrite_s,
  input  wire  [12:0] paddr_s,
  input  wire  [31:0] pwdata_s,
  output  reg         pready_s,
  output  reg         pslverr_s,
  output  reg  [31:0] prdata_s,

  input  wire         ap_en,
  input  wire         ap_secure_en,

  input  wire         dp_abort,

  input  wire         dev_run,

  output  reg         itctrl_ime,

  input  wire  [31:0] baseaddr,
  input  wire         baseaddr_valid,

  output wire         mstr_tr_req,
  output wire         mstr_rd_wr,
  output  reg  [31:0] mstr_addr,
  output wire   [2:0] mstr_prot,
  input  wire         mstr_tr_in_prog,
  input  wire         mstr_tr_done,
  input  wire  [31:0] mstr_rd_data,
  input  wire         mstr_err,

  input  wire   [3:0] revand
);

`include "css600_apbap_localparams.v"

  wire [NUM_DAR-1:0] dar_sel;
  wire               csw_sel;
  wire               tar_sel;
  wire               drw_sel;
  wire [3:0]         bd_sel;
  wire               trr_sel;
  wire               cfg_sel;
  wire               base_sel;
  wire               idr_sel;
  wire               itsts_sel;
  wire               itctrl_sel;
  wire               claimset_sel;
  wire               claimclr_sel;
  wire               authsts_sel;
  wire               devarch_sel;
  wire               devtype_sel;
  wire [4:0]         pidr_sel;
  wire [3:0]         cidr_sel;

  wire               ap0_csw_wr_en;
  wire               ap0_csw_rd_en;
  wire               ap1_csw_wr_en;
  wire               ap1_csw_rd_en;

  wire               ap0_tar_sw_wr_en;
  wire               ap0_tar_wr_en;
  wire               ap0_tar_rd_en;
  wire               ap1_tar_sw_wr_en;
  wire               ap1_tar_wr_en;
  wire               ap1_tar_rd_en;

  wire               ap0_trr_sw_wr_en;
  wire               ap0_trr_wr_en;
  wire               ap0_trr_rd_en;
  wire               ap1_trr_sw_wr_en;
  wire               ap1_trr_wr_en;
  wire               ap1_trr_rd_en;

  wire               ap0_claimset_wr_en;
  wire               ap0_claimset_rd_en;
  wire               ap0_claimclr_wr_en;
  wire               ap0_claimclr_rd_en;
  wire               ap1_claimset_wr_en;
  wire               ap1_claimset_rd_en;
  wire               ap1_claimclr_wr_en;
  wire               ap1_claimclr_rd_en;

  wire               cfg_rd_en;
  wire               base_rd_en;
  wire               idr_rd_en;
  wire               itsts_rd_en;
  wire               itctrl_wr_en;
  wire               itctrl_rd_en;
  wire               authsts_rd_en;
  wire               devarch_rd_en;
  wire               devtype_rd_en;
  wire [4:0]         pidr_rd_en;
  wire [3:0]         cidr_rd_en;

  wire [31:0]        ap0_csw_rd_data;
  wire [31:0]        ap0_tar_rd_data;
  wire [31:0]        ap0_trr_rd_data;
  wire [31:0]        ap1_csw_rd_data;
  wire [31:0]        ap1_tar_rd_data;
  wire [31:0]        ap1_trr_rd_data;
  wire [31:0]        cfg_rd_data;
  wire [31:0]        base_rd_data;
  wire [31:0]        idr_rd_data;
  wire [31:0]        itsts_rd_data;
  wire [31:0]        itctrl_rd_data;
  wire [31:0]        ap0_claimset_rd_data;
  wire [31:0]        ap0_claimclr_rd_data;
  wire [31:0]        ap1_claimset_rd_data;
  wire [31:0]        ap1_claimclr_rd_data;
  wire [31:0]        authsts_rd_data;
  wire [31:0]        devarch_rd_data;
  wire [31:0]        devtype_rd_data;
  wire [31:0]        pidr0_rd_data;
  wire [31:0]        pidr1_rd_data;
  wire [31:0]        pidr2_rd_data;
  wire [31:0]        pidr3_rd_data;
  wire [31:0]        pidr4_rd_data;
  wire [31:0]        cidr0_rd_data;
  wire [31:0]        cidr1_rd_data;
  wire [31:0]        cidr2_rd_data;
  wire [31:0]        cidr3_rd_data;

  wire [19:0]        baseaddr_int;

  wire               ap0_bd_access_en;
  wire               ap0_bd_wr_en;
  wire               ap1_bd_access_en;
  wire               ap1_bd_wr_en;

  wire               ap0_dar_access_en;
  wire               ap0_dar_wr_en;
  wire               ap1_dar_access_en;
  wire               ap1_dar_wr_en;

  wire               mem_rd_en;

  wire               device_en;
  wire               sdevice_en;
  wire               apb_setup_normal;
  wire               apb_setup_wake;
  wire               ap_select;
  wire               secure_mem_req;
  wire               mstr_auth_en;
  wire               reg_access;
  wire               mem_access;
  wire               trig_fsm;
  wire               state_en;
  wire               stop_on_err;
  wire               ap0_stopped;
  wire               ap1_stopped;
  wire               ap0_auto_inc_en;
  wire               ap1_auto_inc_en;
  wire [29:0]        next_ap0_tar;
  wire [29:0]        next_ap1_tar;
  wire               ap0_log_err;
  wire               ap1_log_err;
  wire               next_ap0_trr_err;
  wire               next_ap1_trr_err;
  wire               next_itsts_dpabort;
  wire [1:0]         hnid_val;
  wire [1:0]         hid_val;
  wire [1:0]         snid_val;
  wire [1:0]         sid_val;
  wire [1:0]         nsnid_val;
  wire [1:0]         nsid_val;

  wire               next_penable_reconst;
  wire [31:0]        next_apbslv_rdata;
  wire               next_apbslv_ready;
  wire               next_apbslv_err;

  reg                boss_twin;
  reg                penable_reconst;

  reg [1:0]          curr_state;
  reg [1:0]          next_state;

  reg [2:0]          ap0_csw_prot;
  reg                ap0_csw_errstop;
  reg                ap0_csw_errnpass;
  reg                ap0_csw_addr_inc;
  reg [2:0]          ap1_csw_prot;
  reg                ap1_csw_errstop;
  reg                ap1_csw_errnpass;
  reg                ap1_csw_addr_inc;

  reg [29:0]         ap0_tar;
  reg [29:0]         ap1_tar;
  reg                ap0_trr_err;
  reg                ap1_trr_err;

  reg                itsts_dpabort;

  reg                ap0_bd_access;
  reg                ap0_dar_access;
  reg [1:0]          ap0_bd_addr;
  reg [7:0]          ap0_dar_addr;
  reg                ap1_bd_access;
  reg                ap1_dar_access;
  reg [1:0]          ap1_bd_addr;
  reg [7:0]          ap1_dar_addr;


  assign device_en  = ap_en;
  assign sdevice_en = ap_en & ap_secure_en;

  genvar i;
  generate
    for (i=0; i<NUM_DAR; i=i+1)
    begin : dar_addr_decode
      assign dar_sel[i] = ({paddr_s[11:2],2'b00} == (REGA_DAR_MIN + (i[11:0]<<2)));
    end
  endgenerate

  assign csw_sel         = ({paddr_s[11:2],2'b00} == REGA_CSW);
  assign tar_sel         = ({paddr_s[11:2],2'b00} == REGA_TAR);
  assign drw_sel         = ({paddr_s[11:2],2'b00} == REGA_DRW);
  assign bd_sel[0]       = ({paddr_s[11:2],2'b00} == REGA_BD0);
  assign bd_sel[1]       = ({paddr_s[11:2],2'b00} == REGA_BD1);
  assign bd_sel[2]       = ({paddr_s[11:2],2'b00} == REGA_BD2);
  assign bd_sel[3]       = ({paddr_s[11:2],2'b00} == REGA_BD3);
  assign trr_sel         = ({paddr_s[11:2],2'b00} == REGA_TRR);
  assign cfg_sel         = ({paddr_s[11:2],2'b00} == REGA_CFG);
  assign base_sel        = ({paddr_s[11:2],2'b00} == REGA_BASE);
  assign idr_sel         = ({paddr_s[11:2],2'b00} == REGA_IDR);
  assign itsts_sel       = ({paddr_s[11:2],2'b00} == REGA_ITSTATUS);
  assign itctrl_sel      = ({paddr_s[11:2],2'b00} == REGA_ITCTRL);
  assign claimset_sel    = ({paddr_s[11:2],2'b00} == REGA_CLAIMSET);
  assign claimclr_sel    = ({paddr_s[11:2],2'b00} == REGA_CLAIMCLR);
  assign authsts_sel     = ({paddr_s[11:2],2'b00} == REGA_AUTHSTATUS);
  assign devarch_sel     = ({paddr_s[11:2],2'b00} == REGA_DEVARCH);
  assign devtype_sel     = ({paddr_s[11:2],2'b00} == REGA_DEVTYPE);
  assign pidr_sel[0]     = ({paddr_s[11:2],2'b00} == REGA_PIDR0);
  assign pidr_sel[1]     = ({paddr_s[11:2],2'b00} == REGA_PIDR1);
  assign pidr_sel[2]     = ({paddr_s[11:2],2'b00} == REGA_PIDR2);
  assign pidr_sel[3]     = ({paddr_s[11:2],2'b00} == REGA_PIDR3);
  assign pidr_sel[4]     = ({paddr_s[11:2],2'b00} == REGA_PIDR4);
  assign cidr_sel[0]     = ({paddr_s[11:2],2'b00} == REGA_CIDR0);
  assign cidr_sel[1]     = ({paddr_s[11:2],2'b00} == REGA_CIDR1);
  assign cidr_sel[2]     = ({paddr_s[11:2],2'b00} == REGA_CIDR2);
  assign cidr_sel[3]     = ({paddr_s[11:2],2'b00} == REGA_CIDR3);


  always @(posedge clk or negedge reset_n)
  begin : p_penable_reconst
    if (!reset_n)
      penable_reconst <= 1'b0;
    else if (dev_run)
      penable_reconst <= next_penable_reconst;
  end

  assign next_penable_reconst = psel_s & (curr_state != ST_APBSLV_RDY) &
                                         (curr_state != ST_APBSLV_ERR);

  assign apb_setup_normal = (psel_s & ~penable_s) & dev_run;

  assign apb_setup_wake = (psel_s & ~penable_reconst) & dev_run;

  assign ap_select = (apb_setup_normal | apb_setup_wake);

  always @(posedge clk or negedge reset_n)
  begin : p_boss_twin
    if (!reset_n)
      boss_twin <= LOGICAL_AP0;
    else
      if (mstr_tr_req)
        boss_twin <= paddr_s[12];
  end

  assign secure_mem_req = paddr_s[12] ? ~ap1_csw_prot[1] : ~ap0_csw_prot[1];

  assign mstr_auth_en = secure_mem_req ? sdevice_en : device_en;

  assign ap0_stopped = ap0_csw_errstop & ap0_trr_err;
  assign ap1_stopped = ap1_csw_errstop & ap1_trr_err;

  assign stop_on_err = paddr_s[12] ? ap1_stopped : ap0_stopped;

  assign reg_access = ( csw_sel | tar_sel | trr_sel | cfg_sel | base_sel |
                        idr_sel | itsts_sel | itctrl_sel | claimset_sel |
                        claimclr_sel | authsts_sel | devarch_sel | devtype_sel |
                        (|pidr_sel) | (|cidr_sel)
                      );

  assign mem_access = (|dar_sel) | drw_sel | (|bd_sel);

  assign mem_rd_en = (curr_state == ST_APBSLV_MEM) &
                     (next_state == ST_APBSLV_RDY);

  assign mstr_rd_wr = mem_access & psel_s & pwrite_s;

  assign mstr_tr_req = (next_state == ST_APBSLV_MEM) &
                       (next_state != curr_state);

  assign trig_fsm = ap_select &
                ((reg_access & ((pwrite_s & ~mstr_tr_in_prog) | ~pwrite_s)) |
                 (mem_access & ~mstr_tr_in_prog & mstr_auth_en & ~stop_on_err & ~dp_abort) |
                 ~(reg_access | mem_access));


  always @*
  begin
    case(curr_state)
      ST_APBSLV_IDLE :
        begin
          case({reg_access,mem_access})
            2'b00   : next_state = trig_fsm ? ST_APBSLV_RDY : ST_APBSLV_IDLE;
            2'b01   : next_state = trig_fsm ? ST_APBSLV_MEM :
                                     ap_select ? ST_APBSLV_ERR :
                                                   ST_APBSLV_IDLE;
            2'b10   : next_state = trig_fsm ? ST_APBSLV_RDY :
                                     ap_select ? ST_APBSLV_ERR :
                                                   ST_APBSLV_IDLE;
            default : next_state = ST_APBSLV_UNDEF;
          endcase
        end
      ST_APBSLV_MEM  :
        begin
          case({mstr_tr_done,dp_abort})
            2'b00   : next_state = ST_APBSLV_MEM;
            2'b01   : next_state = ST_APBSLV_ERR;
            2'b10,
            2'b11   : next_state = mstr_err ? ST_APBSLV_ERR : ST_APBSLV_RDY;
            default : next_state = ST_APBSLV_UNDEF;
          endcase
        end
      ST_APBSLV_RDY  :
            next_state = ST_APBSLV_IDLE;
      ST_APBSLV_ERR  :
            next_state = ST_APBSLV_IDLE;
      default        :
            next_state = ST_APBSLV_UNDEF;
    endcase
  end

  always @(posedge clk or negedge reset_n)
  begin : p_curr_state
    if (!reset_n)
      curr_state <= ST_APBSLV_IDLE;
    else if (state_en)
      curr_state <= next_state;
  end

  assign state_en = dev_run;


  assign ap0_csw_wr_en = ~paddr_s[12] & csw_sel & ap_select & pwrite_s &
                         ~mstr_tr_in_prog;

  assign ap0_csw_rd_en = ~paddr_s[12] & csw_sel & ap_select & ~pwrite_s;

  always @(posedge clk or negedge reset_n)
  begin : p_ap0_csw
    if (!reset_n)
    begin
      ap0_csw_prot     <= APBM_PPROT_DEFAULT;
      ap0_csw_errstop  <= 1'b0;
      ap0_csw_errnpass <= 1'b0;
      ap0_csw_addr_inc <= 1'b0;
    end
    else
      if (ap0_csw_wr_en)
      begin
        ap0_csw_prot     <= pwdata_s[30:28];
        ap0_csw_errstop  <= pwdata_s[17];
        ap0_csw_errnpass <= pwdata_s[16];
        ap0_csw_addr_inc <= pwdata_s[4];
      end
  end

  assign ap0_csw_rd_data = {1'b0,
                            ap0_csw_prot,
                            4'h0,
                            sdevice_en,
                            5'h0,
                            ap0_csw_errstop,
                            ap0_csw_errnpass,
                            4'h0,
                            4'h0,
                            mstr_tr_in_prog,
                            device_en,
                            {1'b0,ap0_csw_addr_inc},
                            1'b0,
                            3'b010};


  assign ap1_csw_wr_en =  paddr_s[12] & csw_sel & ap_select & pwrite_s &
                         ~mstr_tr_in_prog;

  assign ap1_csw_rd_en = paddr_s[12] & csw_sel & ap_select & ~pwrite_s;

  always @(posedge clk or negedge reset_n)
  begin : p_ap1_csw
    if (!reset_n)
    begin
      ap1_csw_prot     <= APBM_PPROT_DEFAULT;
      ap1_csw_errstop  <= 1'b0;
      ap1_csw_errnpass <= 1'b0;
      ap1_csw_addr_inc <= 1'b0;
    end
    else
      if (ap1_csw_wr_en)
      begin
        ap1_csw_prot     <= pwdata_s[30:28];
        ap1_csw_errstop  <= pwdata_s[17];
        ap1_csw_errnpass <= pwdata_s[16];
        ap1_csw_addr_inc <= pwdata_s[4];
      end
  end

  assign ap1_csw_rd_data = {1'b0,
                            ap1_csw_prot,
                            4'h0,
                            sdevice_en,
                            5'h0,
                            ap1_csw_errstop,
                            ap1_csw_errnpass,
                            4'h0,
                            4'h0,
                            mstr_tr_in_prog,
                            device_en,
                            {1'b0,ap1_csw_addr_inc},
                            1'b0,
                            3'b010};


  assign ap0_tar_sw_wr_en = ~paddr_s[12] & tar_sel & ap_select & pwrite_s &
                            ~mstr_tr_in_prog;

  assign ap0_tar_rd_en = ~paddr_s[12] & tar_sel & ap_select & ~pwrite_s;

  assign next_ap0_tar[29:8] = ap0_tar_sw_wr_en ? pwdata_s[31:10] :  ap0_tar[29:8];
  assign next_ap0_tar[7:0]  = ap0_tar_sw_wr_en ? pwdata_s[9:2]   : (ap0_tar[7:0] + 8'h1);

  assign ap0_auto_inc_en =  (ap0_csw_addr_inc) &
                            (next_state == ST_APBSLV_RDY) &
                            (curr_state == ST_APBSLV_MEM) &
                            (~paddr_s[12] & drw_sel);

  assign ap0_tar_wr_en = (ap0_tar_sw_wr_en | ap0_auto_inc_en);

  always @ (posedge clk or negedge reset_n)
  begin : p_ap0_tar
    if (!reset_n)
      ap0_tar <= 30'b0;
    else if (ap0_tar_wr_en)
      ap0_tar <= next_ap0_tar;
  end

  assign ap0_tar_rd_data = {ap0_tar,2'b00};


  assign ap1_tar_sw_wr_en =  paddr_s[12] & tar_sel & ap_select & pwrite_s &
                            ~mstr_tr_in_prog;

  assign ap1_tar_rd_en = paddr_s[12] & tar_sel & ap_select & ~pwrite_s;

  assign next_ap1_tar[29:8] = ap1_tar_sw_wr_en ? pwdata_s[31:10] :  ap1_tar[29:8];
  assign next_ap1_tar[7:0]  = ap1_tar_sw_wr_en ? pwdata_s[9:2]   : (ap1_tar[7:0] + 8'h1);

  assign ap1_auto_inc_en =  (ap1_csw_addr_inc) &
                            (next_state == ST_APBSLV_RDY) &
                            (curr_state == ST_APBSLV_MEM) &
                            (paddr_s[12] & drw_sel);

  assign ap1_tar_wr_en = (ap1_tar_sw_wr_en | ap1_auto_inc_en);

  always @ (posedge clk or negedge reset_n)
  begin : p_ap1_tar
    if (!reset_n)
      ap1_tar <= 30'b0;
    else if (ap1_tar_wr_en)
      ap1_tar <= next_ap1_tar;
  end

  assign ap1_tar_rd_data = {ap1_tar,2'b00};


  assign ap0_trr_sw_wr_en = ~paddr_s[12] & trr_sel & ap_select & pwrite_s &
                            ~mstr_tr_in_prog;

  assign ap0_trr_rd_en = ~paddr_s[12] & trr_sel & ap_select & ~pwrite_s;

  assign ap0_log_err = (next_state == ST_APBSLV_ERR) &&
                         (
                          (ap_select & mem_access & ~paddr_s[12]) ||
                          ((boss_twin == LOGICAL_AP0) && (curr_state == ST_APBSLV_MEM))
                         );

  assign ap0_trr_wr_en = (ap0_trr_sw_wr_en | ap0_log_err);

  assign next_ap0_trr_err = ap0_log_err | (ap0_trr_err & ~(ap0_trr_sw_wr_en && pwdata_s[0]));

  always @(posedge clk or negedge reset_n)
  begin : p_ap0_trr
    if (!reset_n)
      ap0_trr_err <= 1'b0;
    else
      if (ap0_trr_wr_en)
        ap0_trr_err <= next_ap0_trr_err;
  end

  assign ap0_trr_rd_data = {31'b0,
                            ap0_trr_err};


  assign ap1_trr_sw_wr_en =  paddr_s[12] & trr_sel & ap_select & pwrite_s &
                            ~mstr_tr_in_prog;

  assign ap1_trr_rd_en = paddr_s[12] & trr_sel & ap_select & ~pwrite_s;

  assign ap1_log_err = (next_state == ST_APBSLV_ERR) &&
                         (
                          (ap_select & mem_access & paddr_s[12]) ||
                          ((boss_twin == LOGICAL_AP1) && (curr_state == ST_APBSLV_MEM))
                         );

  assign ap1_trr_wr_en = (ap1_trr_sw_wr_en | ap1_log_err);

  assign next_ap1_trr_err = ap1_log_err | (ap1_trr_err & ~(ap1_trr_sw_wr_en && pwdata_s[0]));

  always @(posedge clk or negedge reset_n)
  begin : p_ap1_trr
    if (!reset_n)
      ap1_trr_err <= 1'b0;
    else
      if (ap1_trr_wr_en)
        ap1_trr_err <= next_ap1_trr_err;
  end

  assign ap1_trr_rd_data = {31'b0,
                            ap1_trr_err};


  assign cfg_rd_en = cfg_sel & ap_select & ~pwrite_s;

  assign cfg_rd_data = {12'h0,
                        REGV_CFG_TARINC,
                        4'h0,
                        REGV_CFG_ERR,
                        REGV_CFG_DARSIZE,
                        4'h0};


  assign base_rd_en   = base_sel & ap_select & ~pwrite_s;

  assign baseaddr_int = baseaddr_valid ? baseaddr[31:12] : 20'h0;

  assign base_rd_data = {baseaddr_int,
                         10'h0,
                         REGV_BASE_FORMAT,
                         baseaddr_valid};


  assign idr_rd_en = idr_sel & ap_select & ~pwrite_s;

  assign idr_rd_data       = {REGV_IDR_REVISION,
                              REGV_IDR_JEDECBANK,
                              REGV_IDR_JEDECCODE,
                              REGV_IDR_CLASS,
                              5'h0,
                              REGV_IDR_VARIANT,
                              REGV_IDR_TYPE};


  assign itsts_rd_en = itsts_sel & ap_select & ~pwrite_s;

  assign next_itsts_dpabort = itctrl_ime & (dp_abort | itsts_dpabort) & ~itsts_rd_en;

  always @(posedge clk or negedge reset_n)
  begin : p_itsts
    if (!reset_n)
      itsts_dpabort <= 1'b0;
    else
      itsts_dpabort <= next_itsts_dpabort;
  end

  assign itsts_rd_data = {31'h0,
                          itsts_dpabort};


  assign itctrl_wr_en = itctrl_sel & ap_select & pwrite_s & ~mstr_tr_in_prog;
  assign itctrl_rd_en = itctrl_sel & ap_select & ~pwrite_s;

  always @(posedge clk or negedge reset_n)
  begin : p_itctrl
    if (!reset_n)
      itctrl_ime <= 1'b0;
    else
      if (itctrl_wr_en)
        itctrl_ime <= pwdata_s[0];
  end

  assign itctrl_rd_data = {31'h0,
                           itctrl_ime};


  assign ap0_claimset_wr_en  = ~paddr_s[12] &
                                claimset_sel & ap_select & pwrite_s &
                               ~mstr_tr_in_prog;

  assign ap0_claimset_rd_en  = ~paddr_s[12] &
                                claimset_sel & ap_select & ~pwrite_s;

  assign ap0_claimclr_wr_en  = ~paddr_s[12] &
                                claimclr_sel & ap_select & pwrite_s &
                               ~mstr_tr_in_prog;

  assign ap0_claimclr_rd_en  = ~paddr_s[12] &
                                claimclr_sel & ap_select & ~pwrite_s;


  css600_claimtags
    #(.NUM_CLAIM_TAGS(2))
    u_css600_claimtags_ap0
    (
      .clk               (clk),
      .reset_n           (reset_n),
      .claim_set_wr      (ap0_claimset_wr_en),
      .claim_set_wr_data (pwdata_s[1:0]),
      .claim_set_rd      (ap0_claimset_rd_en),
      .claim_set_rd_data (ap0_claimset_rd_data[1:0]),
      .claim_clr_wr      (ap0_claimclr_wr_en),
      .claim_clr_wr_data (pwdata_s[1:0]),
      .claim_clr_rd      (ap0_claimclr_rd_en),
      .claim_clr_rd_data (ap0_claimclr_rd_data[1:0])
    );

  assign ap0_claimset_rd_data[31:2] = 30'b0;
  assign ap0_claimclr_rd_data[31:2] = 30'b0;


  assign ap1_claimset_wr_en =  paddr_s[12] &
                               claimset_sel & ap_select & pwrite_s &
                              ~mstr_tr_in_prog;

  assign ap1_claimset_rd_en =  paddr_s[12] &
                               claimset_sel & ap_select & ~pwrite_s;

  assign ap1_claimclr_wr_en =  paddr_s[12] &
                               claimclr_sel & ap_select & pwrite_s &
                              ~mstr_tr_in_prog;

  assign ap1_claimclr_rd_en =  paddr_s[12] &
                               claimclr_sel & ap_select & ~pwrite_s;


  css600_claimtags
    #(.NUM_CLAIM_TAGS(2))
    u_css600_claimtags_ap1
    (
      .clk               (clk),
      .reset_n           (reset_n),
      .claim_set_wr      (ap1_claimset_wr_en),
      .claim_set_wr_data (pwdata_s[1:0]),
      .claim_set_rd      (ap1_claimset_rd_en),
      .claim_set_rd_data (ap1_claimset_rd_data[1:0]),
      .claim_clr_wr      (ap1_claimclr_wr_en),
      .claim_clr_wr_data (pwdata_s[1:0]),
      .claim_clr_rd      (ap1_claimclr_rd_en),
      .claim_clr_rd_data (ap1_claimclr_rd_data[1:0])
    );

  assign ap1_claimset_rd_data[31:2] = 30'b0;
  assign ap1_claimclr_rd_data[31:2] = 30'b0;


  assign authsts_rd_en = authsts_sel & ap_select & ~pwrite_s;

  assign hnid_val          = 2'b00;
  assign hid_val           = 2'b00;

  assign snid_val          = sdevice_en ? 2'b11 : 2'b10;
  assign sid_val           = sdevice_en ? 2'b11 : 2'b10;
  assign nsnid_val         =  device_en ? 2'b11 : 2'b10;
  assign nsid_val          =  device_en ? 2'b11 : 2'b10;

  assign authsts_rd_data   = {20'h0,
                              hnid_val,
                              hid_val,
                              snid_val,
                              sid_val,
                              nsnid_val,
                              nsid_val};


  assign devarch_rd_en = devarch_sel & ap_select & ~pwrite_s;

  assign devarch_rd_data   = {REGV_DEVARCH_ARCHITECT,
                              REGV_DEVARCH_PRESENT,
                              REGV_DEVARCH_REVISION,
                              REGV_DEVARCH_ARCHID};


  assign devtype_rd_en = devtype_sel & ap_select & ~pwrite_s;

  assign devtype_rd_data   = {24'h0,
                              REGV_DEVTYPE_SUB,
                              REGV_DEVTYPE_MAJOR};


  assign pidr_rd_en[4:0] = pidr_sel[4:0] & {5{(ap_select & ~pwrite_s)}};

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


  assign cidr_rd_en[3:0] = cidr_sel[3:0] & {4{(ap_select & ~pwrite_s)}};

  assign cidr0_rd_data     = {24'h0,
                              REGV_CIDR0_PRMBL0};

  assign cidr1_rd_data     = {24'h0,
                              REGV_CIDR1_CLASS,
                              REGV_CIDR1_PRMBL1};

  assign cidr2_rd_data     = {24'h0,
                              REGV_CIDR2_PRMBL2};

  assign cidr3_rd_data     = {24'h0,
                              REGV_CIDR3_PRMBL3};


  assign next_apbslv_rdata = (
                       ({32{mem_rd_en}} & mstr_rd_data) |
                       ({32{ap0_csw_rd_en}} & ap0_csw_rd_data) |
                       ({32{ap0_tar_rd_en}} & ap0_tar_rd_data) |
                       ({32{ap0_trr_rd_en}} & ap0_trr_rd_data) |
                       ({32{ap1_csw_rd_en}} & ap1_csw_rd_data) |
                       ({32{ap1_tar_rd_en}} & ap1_tar_rd_data) |
                       ({32{ap1_trr_rd_en}} & ap1_trr_rd_data) |
                       ({32{cfg_rd_en}} & cfg_rd_data) |
                       ({32{base_rd_en}} & base_rd_data) |
                       ({32{idr_rd_en}} & idr_rd_data) |
                       ({32{itsts_rd_en}} & itsts_rd_data) |
                       ({32{itctrl_rd_en}} & itctrl_rd_data) |
                       ({32{ap0_claimset_rd_en}} & ap0_claimset_rd_data) |
                       ({32{ap0_claimclr_rd_en}} & ap0_claimclr_rd_data) |
                       ({32{ap1_claimset_rd_en}} & ap1_claimset_rd_data) |
                       ({32{ap1_claimclr_rd_en}} & ap1_claimclr_rd_data) |
                       ({32{authsts_rd_en}} & authsts_rd_data) |
                       ({32{devarch_rd_en}} & devarch_rd_data) |
                       ({32{devtype_rd_en}} & devtype_rd_data) |
                       ({32{pidr_rd_en[0]}} & pidr0_rd_data) |
                       ({32{pidr_rd_en[1]}} & pidr1_rd_data) |
                       ({32{pidr_rd_en[2]}} & pidr2_rd_data) |
                       ({32{pidr_rd_en[3]}} & pidr3_rd_data) |
                       ({32{pidr_rd_en[4]}} & pidr4_rd_data) |
                       ({32{cidr_rd_en[0]}} & cidr0_rd_data) |
                       ({32{cidr_rd_en[1]}} & cidr1_rd_data) |
                       ({32{cidr_rd_en[2]}} & cidr2_rd_data) |
                       ({32{cidr_rd_en[3]}} & cidr3_rd_data)
                             );

  always @(posedge clk or negedge reset_n)
  begin : p_prdata_s
    if (!reset_n)
      prdata_s <= 32'b0;
    else
      prdata_s <= next_apbslv_rdata;
  end


  assign next_apbslv_ready = (next_state == ST_APBSLV_RDY) |
                             (next_state == ST_APBSLV_ERR);

  always @(posedge clk or negedge reset_n)
  begin : p_pready_s
    if (!reset_n)
      pready_s <= 1'b0;
    else
      pready_s <= next_apbslv_ready;
  end


  assign next_apbslv_err =
              (~ap0_csw_errnpass & ap0_log_err) |
              (~ap1_csw_errnpass & ap1_log_err) |
              (ap_select & ((reg_access & pwrite_s) | mem_access) & mstr_tr_in_prog) |
              (ap_select & mem_access & dp_abort & mstr_auth_en & ~stop_on_err) |
              ((curr_state == ST_APBSLV_MEM) & ~mstr_tr_done & dp_abort);

  always @(posedge clk or negedge reset_n)
  begin : p_pslverr_s
    if (!reset_n)
      pslverr_s <= 1'b0;
    else
      pslverr_s <= next_apbslv_err;
  end


  assign ap0_bd_access_en  = ((mstr_tr_req & |bd_sel & ~paddr_s[12]) | mstr_tr_done);
  assign ap1_bd_access_en  = ((mstr_tr_req & |bd_sel & paddr_s[12]) | mstr_tr_done);

  assign ap0_dar_access_en = ((mstr_tr_req & |dar_sel & ~paddr_s[12]) | mstr_tr_done);
  assign ap1_dar_access_en = ((mstr_tr_req & |dar_sel & paddr_s[12]) | mstr_tr_done);

  always @ (posedge clk or negedge reset_n)
  begin : p_bd_dar_access
    if (!reset_n)
    begin
      ap0_bd_access  <= 1'b0;
      ap1_bd_access  <= 1'b0;
      ap0_dar_access <= 1'b0;
      ap1_dar_access <= 1'b0;
    end
    else begin
      if (ap0_bd_access_en)
        ap0_bd_access  <= mstr_tr_req;

      if (ap1_bd_access_en)
        ap1_bd_access  <= mstr_tr_req;

      if (ap0_dar_access_en)
        ap0_dar_access <= mstr_tr_req;

      if (ap1_dar_access_en)
        ap1_dar_access <= mstr_tr_req;
    end
  end

  assign ap0_bd_wr_en  = ~paddr_s[12] & |bd_sel & ~mstr_tr_in_prog;
  assign ap1_bd_wr_en  =  paddr_s[12] & |bd_sel & ~mstr_tr_in_prog;

  assign ap0_dar_wr_en = ~paddr_s[12] & |dar_sel & ~mstr_tr_in_prog;
  assign ap1_dar_wr_en =  paddr_s[12] & |dar_sel & ~mstr_tr_in_prog;

  always @ (posedge clk or negedge reset_n)
  begin : p_bd_addr
    if (!reset_n)
    begin
      ap0_bd_addr <= 2'b0;
      ap1_bd_addr <= 2'b0;
    end
    else begin
      if (ap0_bd_wr_en)
        ap0_bd_addr <= paddr_s[3:2];

      if (ap1_bd_wr_en)
        ap1_bd_addr <= paddr_s[3:2];
    end
  end

  always @ (posedge clk or negedge reset_n)
  begin : p_dar_addr
    if (!reset_n)
    begin
      ap0_dar_addr <= 8'b0;
      ap1_dar_addr <= 8'b0;
    end
    else begin
      if (ap0_dar_wr_en)
        ap0_dar_addr <= paddr_s[9:2];

      if (ap1_dar_wr_en)
        ap1_dar_addr <= paddr_s[9:2];
    end
  end

  always @*
  begin
    mstr_addr[31:10] = (boss_twin == LOGICAL_AP1) ? ap1_tar[29:8] : ap0_tar[29:8];
    mstr_addr[1:0] = 2'b00;
    case({ap0_dar_access, ap1_dar_access, ap0_bd_access, ap1_bd_access})
      4'b0000  : mstr_addr[9:2] = (boss_twin == LOGICAL_AP1) ? ap1_tar[7:0] : ap0_tar[7:0];
      4'b1000  : mstr_addr[9:2] = ap0_dar_addr[7:0];
      4'b0100  : mstr_addr[9:2] = ap1_dar_addr[7:0];
      4'b0010  :
        begin
          mstr_addr[9:4] = ap0_tar[7:2];
          mstr_addr[3:2] = ap0_bd_addr[1:0];
        end
      4'b0001  :
        begin
          mstr_addr[9:4] = ap1_tar[7:2];
          mstr_addr[3:2] = ap1_bd_addr[1:0];
        end
      default  : mstr_addr[9:2] = 8'hxx;
    endcase
  end

  assign mstr_prot = (boss_twin == LOGICAL_AP1) ? ap1_csw_prot : ap0_csw_prot;


endmodule


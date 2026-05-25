//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017 Arm Limited or its affiliates.
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
//   Sub-module of css600_catu
//
//----------------------------------------------------------------------------


module css600_catu_axi_slave_if
#(
  parameter ADDR_WIDTH  = 40,
  parameter VA_WIDTH    = 40,
  parameter PS_WIDTH    = 12,
  parameter DATA_WIDTH  = 64,
  parameter LEN_WIDTH   = 8,
  parameter SIZE_WIDTH  = 3,
  parameter BURST_WIDTH = 2,
  parameter CACHE_WIDTH = 4,
  parameter PROT_WIDTH  = 3,
  parameter RESP_WIDTH  = 2,
  parameter WSTRB_WIDTH = 8
)(
  input  wire                           clk,
  input  wire                           reset_n,
  input  wire                           dev_run,
  input  wire [ADDR_WIDTH-1:0]          araddr_s,
  input  wire [LEN_WIDTH-1:0]           arlen_s,
  input  wire [SIZE_WIDTH-1:0]          arsize_s,
  input  wire [BURST_WIDTH-1:0]         arburst_s,
  input  wire                           arlock_s,
  input  wire [CACHE_WIDTH-1:0]         arcache_s,
  input  wire [PROT_WIDTH-1:0]          arprot_s,
  input  wire                           arvalid_s,
  output wire                           arready_s,
  output wire [DATA_WIDTH-1:0]          rdata_s,
  output wire [RESP_WIDTH-1:0]          rresp_s,
  output wire                           rlast_s,
  output wire                           rvalid_s,
  input  wire                           rready_s,
  input  wire [ADDR_WIDTH-1:0]          awaddr_s,
  input  wire [LEN_WIDTH-1:0]           awlen_s,
  input  wire [SIZE_WIDTH-1:0]          awsize_s,
  input  wire [BURST_WIDTH-1:0]         awburst_s,
  input  wire                           awlock_s,
  input  wire [CACHE_WIDTH-1:0]         awcache_s,
  input  wire [PROT_WIDTH-1:0]          awprot_s,
  input  wire                           awvalid_s,
  output wire                           awready_s,
  input  wire [DATA_WIDTH-1:0]          wdata_s,
  input  wire [WSTRB_WIDTH-1:0]         wstrb_s,
  input  wire                           wlast_s,
  input  wire                           wvalid_s,
  output wire                           wready_s,
  output wire [RESP_WIDTH-1:0]          bresp_s,
  output wire                           bvalid_s,
  input  wire                           bready_s,
  output wire [VA_WIDTH-1:0]            axislv_araddr,
  output wire [LEN_WIDTH-1:0]           axislv_arlen,
  output wire [SIZE_WIDTH-1:0]          axislv_arsize,
  output wire [BURST_WIDTH-1:0]         axislv_arburst,
  output wire                           axislv_arlock,
  output wire [CACHE_WIDTH-1:0]         axislv_arcache,
  output wire [PROT_WIDTH-1:0]          axislv_arprot,
  output wire                           translate_arvalid,
  input  wire                           translate_arready,
  output wire                           bypass_arvalid,
  input  wire                           bypass_arready,
  output wire                           ds_arvalid,
  input  wire                           ds_arready,
  input  wire [DATA_WIDTH-1:0]          int_rdata,
  input  wire [RESP_WIDTH-1:0]          int_rresp,
  input  wire                           int_rlast,
  input  wire                           int_rvalid,
  output wire                           int_rready,
  input  wire [RESP_WIDTH-1:0]          ds_rresp,
  input  wire                           ds_rlast,
  input  wire                           ds_rvalid,
  output wire                           ds_rready,
  output wire [VA_WIDTH-1:0]            axislv_awaddr,
  output wire [LEN_WIDTH-1:0]           axislv_awlen,
  output wire [SIZE_WIDTH-1:0]          axislv_awsize,
  output wire [BURST_WIDTH-1:0]         axislv_awburst,
  output wire                           axislv_awlock,
  output wire [CACHE_WIDTH-1:0]         axislv_awcache,
  output wire [PROT_WIDTH-1:0]          axislv_awprot,
  output wire                           translate_awvalid,
  input  wire                           translate_awready,
  output wire                           bypass_awvalid,
  input  wire                           bypass_awready,
  output wire                           ds_awvalid,
  input  wire                           ds_awready,
  output wire [DATA_WIDTH-1:0]          int_wdata,
  output wire [WSTRB_WIDTH-1:0]         int_wstrb,
  output wire                           int_wlast,
  output wire                           axislv_wvalid,
  input  wire                           axislv_wready,
  output wire                           ds_wvalid,
  input  wire                           ds_wready,
  input  wire [RESP_WIDTH-1:0]          int_bresp,
  input  wire                           int_bvalid,
  output wire                           int_bready,
  input  wire [RESP_WIDTH-1:0]          ds_bresp,
  input  wire                           ds_bvalid,
  output wire                           ds_bready,
  input  wire                           spiden,
  input  wire                           dbgen,
  input  wire                           ctrl_enable,
  input  wire                           ctrl_mode,
  input  wire                           init_tlbs,
  input  wire                           invalid_rd,
  input  wire                           invalid_wr,
  input  wire                           rd_trans_busy,
  input  wire                           wr_trans_busy,
  input  wire                           tlb_initialised,
  output wire                           init_slw,
  output wire                           rd_ds_select,
  output wire                           wr_ds_select,
  output wire                           rds_drained,
  output wire                           wrs_drained,
  output wire                           rd_auth_err,
  output wire                           wr_auth_err,
  output wire                           reg_arvalid,
  output reg                            outs_rd_cntr_noteq0,
  output wire                           reg_awvalid,
  output reg                            outs_wr_cntr_noteq0,
  output reg                            enable_busy,
  output wire                           status_busy
);


  localparam L_OUTTR_CNTR_WIDTH   = 4;
  localparam L_ARW_PAYLOAD_WIDTH  = VA_WIDTH  +
                                    LEN_WIDTH   +
                                    SIZE_WIDTH  +
                                    BURST_WIDTH +
                                    1           +
                                    CACHE_WIDTH +
                                    PROT_WIDTH;
  localparam L_W_PAYLOAD_WIDTH    = DATA_WIDTH  +
                                    WSTRB_WIDTH +
                                    1;
  localparam L_ARW_REGSTAGE_NUM   = 1;
  localparam L_W_REGSTAGE_NUM     = 1;

  localparam ST_T_IDLE       = 2'b00;
  localparam ST_T_TRANS      = 2'b01;
  localparam ST_T_BY         = 2'b10;
  localparam ST_T_DS         = 2'b11;
  localparam ST_T_UNDEF      = 2'bxx;
  localparam ST_T_BITS       = 2;

  genvar i;

  wire                           int_arvalid;
  wire                           int_arready;
  wire                           int_awvalid;
  wire                           int_awready;
  wire                           int_wvalid;
  wire                           int_wready;
  wire                           ar_accepted;
  wire                           aw_accepted;
  wire                           w_accepted;
  wire                           rresp_accepted;
  wire                           bresp_accepted;
  wire                           rd_busy;
  wire                           wr_busy;
  wire                           outs_rd_cntr_we;
  reg  [L_OUTTR_CNTR_WIDTH-1:0]  outs_rd_cntr;
  reg  [L_OUTTR_CNTR_WIDTH-1:0]  outs_rd_cntr_q;
  wire                           nxt_outs_rd_cntr_noteq0;
  wire                           outs_rd_cntr_max;
  wire                           outs_wr_cntr_we;
  reg  [L_OUTTR_CNTR_WIDTH-1:0]  outs_wr_cntr;
  reg  [L_OUTTR_CNTR_WIDTH-1:0]  outs_wr_cntr_q;
  wire                           nxt_outs_wr_cntr_noteq0;
  wire                           outs_wr_cntr_max;
  wire                           last_cntr_en;
  reg  [L_OUTTR_CNTR_WIDTH-1:0]  last_cntr;
  reg  [L_OUTTR_CNTR_WIDTH-1:0]  last_cntr_q;
  wire                           next_active_add;
  reg                            active_add;
  wire                           wr_state_en;
  reg  [ST_T_BITS-1:0]           next_wr_state;
  reg  [ST_T_BITS-1:0]           wr_state;
  wire                           rd_state_en;
  reg  [ST_T_BITS-1:0]           next_rd_state;
  reg  [ST_T_BITS-1:0]           rd_state;

  wire                           rd_auth_fail;
  wire                           wr_auth_fail;

  wire                           wr_trans_enable;
  wire                           wr_by_enable;
  wire                           wr_ds_enable;
  wire                           rd_trans_enable;
  wire                           rd_by_enable;
  wire                           rd_ds_enable;

  wire                           enable_rds_en;
  reg                            enable_rds;
  wire                           enable_wrs_en;
  reg                            enable_wrs;

  wire                           enable_busy_set;
  wire                           enable_busy_en;

  wire [L_ARW_PAYLOAD_WIDTH-1:0] ar_payload_src;
  wire [L_ARW_PAYLOAD_WIDTH-1:0] ar_payload_dst;
/* verilator lint_off UNOPTFLAT */
  wire [L_ARW_REGSTAGE_NUM:0]    ar_ready_regstages;
/* verilator lint_on UNOPTFLAT */
  wire [L_ARW_REGSTAGE_NUM:0]    ar_valid_regstages;
  wire [L_ARW_PAYLOAD_WIDTH-1:0] ar_payload_regstages [L_ARW_REGSTAGE_NUM:0];
  wire [L_ARW_PAYLOAD_WIDTH-1:0] aw_payload_src;
  wire [L_ARW_PAYLOAD_WIDTH-1:0] aw_payload_dst;
/* verilator lint_off UNOPTFLAT */
  wire [L_ARW_REGSTAGE_NUM:0]    aw_ready_regstages;
/* verilator lint_on UNOPTFLAT */
  wire [L_ARW_REGSTAGE_NUM:0]    aw_valid_regstages;
  wire [L_ARW_PAYLOAD_WIDTH-1:0] aw_payload_regstages [L_ARW_REGSTAGE_NUM:0];
  wire [L_W_PAYLOAD_WIDTH-1:0]   w_payload_src;
  wire [L_W_PAYLOAD_WIDTH-1:0]   w_payload_dst;
/* verilator lint_off UNOPTFLAT */
  wire [L_W_REGSTAGE_NUM:0]      w_ready_regstages;
/* verilator lint_on UNOPTFLAT */
  wire [L_W_REGSTAGE_NUM:0]      w_valid_regstages;
  wire [L_W_PAYLOAD_WIDTH-1:0]   w_payload_regstages [L_W_REGSTAGE_NUM:0];


  assign rd_auth_fail = (~dbgen | (~spiden & ~axislv_arprot[1])) & int_arvalid & ~rd_trans_busy;
  assign wr_auth_fail = (~dbgen | (~spiden & ~axislv_awprot[1])) & int_awvalid & ~wr_trans_busy;

  assign rd_auth_err = rd_auth_fail & enable_rds;
  assign wr_auth_err = wr_auth_fail & enable_wrs;

  assign ar_accepted    = int_arvalid & int_arready;
  assign aw_accepted    = int_awvalid & int_awready;
  assign w_accepted     = int_wvalid & int_wready & int_wlast;
  assign rresp_accepted = rvalid_s & rready_s & rlast_s;
  assign bresp_accepted = bvalid_s & bready_s;

  assign rd_busy =  arvalid_s | reg_arvalid | outs_rd_cntr_noteq0;
  assign wr_busy =  awvalid_s | reg_awvalid | outs_wr_cntr_noteq0;

  assign ar_payload_src = { araddr_s[VA_WIDTH-1:0],
                            arlen_s,
                            arsize_s,
                            arburst_s,
                            arlock_s,
                            arcache_s,
                            arprot_s  };
  assign { axislv_araddr,
           axislv_arlen,
           axislv_arsize,
           axislv_arburst,
           axislv_arlock,
           axislv_arcache,
           axislv_arprot  } = ar_payload_dst;

  assign aw_payload_src = { awaddr_s[VA_WIDTH-1:0],
                            awlen_s,
                            awsize_s,
                            awburst_s,
                            awlock_s,
                            awcache_s,
                            awprot_s  };
  assign { axislv_awaddr,
           axislv_awlen,
           axislv_awsize,
           axislv_awburst,
           axislv_awlock,
           axislv_awcache,
           axislv_awprot  } = aw_payload_dst;

  assign w_payload_src = { wdata_s,
                           wstrb_s,
                           wlast_s };
  assign { int_wdata,
           int_wstrb,
           int_wlast } = w_payload_dst;


  assign outs_rd_cntr_we = ar_accepted | rresp_accepted;

  always @*
  begin : comb_outtr_rd_cntr
    case ({ar_accepted, rresp_accepted})
      2'b10 :
        outs_rd_cntr = ( outs_rd_cntr_q + { {L_OUTTR_CNTR_WIDTH-1{1'b0}}, 1'b1 } );
      2'b01 :
        outs_rd_cntr = ( outs_rd_cntr_q - { {L_OUTTR_CNTR_WIDTH-1{1'b0}}, 1'b1 } );
      2'b11,
      2'b00 :
        outs_rd_cntr = outs_rd_cntr_q;
      default :
        outs_rd_cntr = {L_OUTTR_CNTR_WIDTH{1'bx}};
    endcase
  end

  always @(posedge clk or negedge reset_n)
  begin : reg_outtr_rd_cntr
    if (!reset_n) begin
      outs_rd_cntr_q <= {L_OUTTR_CNTR_WIDTH{1'b0}};
      outs_rd_cntr_noteq0 <= 1'b0;
    end
    else if (outs_rd_cntr_we) begin
      outs_rd_cntr_q <= outs_rd_cntr;
      outs_rd_cntr_noteq0 <= nxt_outs_rd_cntr_noteq0;
    end
  end

  assign nxt_outs_rd_cntr_noteq0 = |outs_rd_cntr;
  assign rds_drained = ~outs_rd_cntr_noteq0;
  assign outs_rd_cntr_max = &outs_rd_cntr_q;

  assign outs_wr_cntr_we = aw_accepted | bresp_accepted;

  always @*
  begin : comb_outtr_wr_cntr
    case ({aw_accepted, bresp_accepted})
      2'b10 :
        outs_wr_cntr = ( outs_wr_cntr_q + { {L_OUTTR_CNTR_WIDTH-1{1'b0}}, 1'b1 } );
      2'b01 :
        outs_wr_cntr = ( outs_wr_cntr_q - { {L_OUTTR_CNTR_WIDTH-1{1'b0}}, 1'b1 } );
      2'b11,
      2'b00 :
        outs_wr_cntr = outs_wr_cntr_q;
      default :
        outs_wr_cntr = {L_OUTTR_CNTR_WIDTH{1'bx}};
    endcase
  end

  always @(posedge clk or negedge reset_n)
  begin : reg_outtr_wr_cntr
    if (!reset_n) begin
      outs_wr_cntr_q <= {L_OUTTR_CNTR_WIDTH{1'b0}};
      outs_wr_cntr_noteq0 <= 1'b0;
    end
    else if (outs_wr_cntr_we) begin
      outs_wr_cntr_q <= outs_wr_cntr;
      outs_wr_cntr_noteq0 <= nxt_outs_wr_cntr_noteq0;
    end
  end

  assign nxt_outs_wr_cntr_noteq0 = |outs_wr_cntr;
  assign wrs_drained = ~outs_wr_cntr_noteq0;
  assign outs_wr_cntr_max = &outs_wr_cntr_q;

  assign last_cntr_en = aw_accepted | w_accepted | bresp_accepted;

  always @*
  begin : comb_last_cntr
    case ({w_accepted, bresp_accepted})
      2'b10 :
        last_cntr = ( last_cntr_q + { {L_OUTTR_CNTR_WIDTH-1{1'b0}}, 1'b1 } );
      2'b01 :
        last_cntr = ( last_cntr_q - { {L_OUTTR_CNTR_WIDTH-1{1'b0}}, 1'b1 } );
      2'b11,
      2'b00 :
        last_cntr = last_cntr_q;
      default :
        last_cntr = {L_OUTTR_CNTR_WIDTH{1'bx}};
    endcase
  end

  assign next_active_add = (last_cntr < outs_wr_cntr);

  always @(posedge clk or negedge reset_n)
  begin : reg_last_cntr
    if (!reset_n) begin
      last_cntr_q <= {L_OUTTR_CNTR_WIDTH{1'b0}};
      active_add  <= 1'b0;
    end
    else if (last_cntr_en) begin
      last_cntr_q <= last_cntr;
      active_add  <= next_active_add;
    end
  end


  always @*
  begin : p_next_wr_state
    case (wr_state)
      ST_T_IDLE  : next_wr_state = (enable_wrs && ctrl_mode && dev_run)   ? ST_T_TRANS
                                 : (enable_wrs && ~ctrl_mode && dev_run)  ? ST_T_BY
                                 : int_awvalid && dev_run ? ST_T_DS
                                 : ST_T_IDLE;
      ST_T_TRANS : next_wr_state = (wrs_drained && ~enable_wrs) ? ST_T_IDLE
                                 : (wrs_drained && wr_auth_fail) ? ST_T_DS
                                 : ST_T_TRANS;
      ST_T_BY    : next_wr_state = (wrs_drained && ~enable_wrs) ? ST_T_IDLE
                                 : (wrs_drained && wr_auth_fail) ? ST_T_DS
                                 : ST_T_BY;
      ST_T_DS    : next_wr_state = (~int_awvalid && wrs_drained && ~enable_wrs) ? ST_T_IDLE
                                 : (wrs_drained && ~wr_auth_fail && enable_wrs && ctrl_mode)   ? ST_T_TRANS
                                 : (wrs_drained && ~wr_auth_fail && enable_wrs && ~ctrl_mode)  ? ST_T_BY
                                 : ST_T_DS;
      default    : next_wr_state =  ST_T_UNDEF;
    endcase
  end

  assign wr_state_en = (wr_state != next_wr_state);

  always @(posedge clk or negedge reset_n)
  begin : p_wr_state
    if (!reset_n)
      wr_state <= ST_T_IDLE;
    else if (wr_state_en)
      wr_state <= next_wr_state;
  end

  assign wr_trans_enable = (wr_state==ST_T_TRANS) & ~wr_auth_fail & ~init_tlbs & enable_wrs;
  assign wr_by_enable = (wr_state==ST_T_BY) & ~wr_auth_fail & enable_wrs;
  assign wr_ds_enable = (wr_state==ST_T_DS) & (wr_auth_fail | ~enable_wrs);
  assign wr_ds_select = (wr_state!=ST_T_DS) & (~wr_auth_fail | ~enable_wrs) | invalid_wr;

  always @*
  begin : p_next_rd_state
    case (rd_state)
      ST_T_IDLE  : next_rd_state = (enable_rds && ctrl_mode && dev_run)   ? ST_T_TRANS
                                 : (enable_rds && ~ctrl_mode && dev_run)  ? ST_T_BY
                                 : int_arvalid && dev_run ? ST_T_DS
                                 : ST_T_IDLE;
      ST_T_TRANS : next_rd_state = (rds_drained && ~enable_rds) ? ST_T_IDLE
                                 : (rds_drained && rd_auth_fail) ? ST_T_DS
                                 : ST_T_TRANS;
      ST_T_BY    : next_rd_state = (rds_drained && ~enable_rds) ? ST_T_IDLE
                                 : (rds_drained && rd_auth_fail) ? ST_T_DS
                                 : ST_T_BY;
      ST_T_DS    : next_rd_state = (~int_arvalid && rds_drained && ~enable_rds) ? ST_T_IDLE
                                 : (rds_drained && ~rd_auth_fail && enable_rds && ctrl_mode)   ? ST_T_TRANS
                                 : (rds_drained && ~rd_auth_fail && enable_rds && ~ctrl_mode)  ? ST_T_BY
                                 : ST_T_DS;
      default    : next_rd_state =  ST_T_UNDEF;
    endcase
  end

  assign rd_state_en = (rd_state != next_rd_state);

  always @(posedge clk or negedge reset_n)
  begin : p_rd_state
    if (!reset_n)
      rd_state <= ST_T_IDLE;
    else if (rd_state_en)
      rd_state <= next_rd_state;
  end


  assign rd_trans_enable = (rd_state==ST_T_TRANS) & ~rd_auth_fail & ~init_tlbs & enable_rds;
  assign rd_by_enable = (rd_state==ST_T_BY) & ~rd_auth_fail & enable_rds;
  assign rd_ds_enable = (rd_state==ST_T_DS) & (rd_auth_fail | ~enable_rds);
  assign rd_ds_select = (rd_state!=ST_T_DS) & (~rd_auth_fail | ~enable_rds) | invalid_rd;


  assign init_slw = ((((rd_state==ST_T_IDLE) || (rd_state==ST_T_DS)) && (next_wr_state==ST_T_TRANS))
                  || (((wr_state==ST_T_IDLE) || (wr_state==ST_T_DS)) && (next_rd_state==ST_T_TRANS)))
                  && ~tlb_initialised;


  assign enable_wrs_en = ((ctrl_enable & ~enable_wrs) & (~int_awvalid | int_awready))
                       | ((~ctrl_enable & enable_wrs) & (~int_awvalid | int_awready));

  always @(posedge clk or negedge reset_n)
  begin : reg_en_wrs
    if (!reset_n) begin
      enable_wrs <= 1'b0;
    end
    else if (enable_wrs_en) begin
      enable_wrs <= ctrl_enable;
    end
  end

  assign enable_rds_en = ((ctrl_enable & ~enable_rds) & (~int_arvalid | int_arready))
                       | ((~ctrl_enable & enable_rds) & (~int_arvalid | int_arready));

  always @(posedge clk or negedge reset_n)
  begin : reg_en_rds
    if (!reset_n) begin
      enable_rds <= 1'b0;
    end
    else if (enable_rds_en) begin
      enable_rds <= ctrl_enable;
    end
  end

  assign enable_busy_set = ctrl_enable & ctrl_mode & ~enable_wrs;
  assign enable_busy_en = enable_busy_set | init_slw;
  always @(posedge clk or negedge reset_n)
  begin : reg_en_busy
    if (!reset_n) begin
      enable_busy <= 1'b0;
    end
    else if (enable_busy_en) begin
      enable_busy <= ~init_slw;
    end
  end


  assign ar_valid_regstages[0]                  = arvalid_s & dev_run;
  assign ar_payload_regstages[0]                = ar_payload_src;
  assign arready_s                              = ar_ready_regstages[0] & dev_run;
  assign reg_arvalid                            = ar_valid_regstages[L_ARW_REGSTAGE_NUM];
  assign ar_payload_dst                         = ar_payload_regstages[L_ARW_REGSTAGE_NUM];
  assign ar_ready_regstages[L_ARW_REGSTAGE_NUM] = int_arready;
  assign int_arvalid = reg_arvalid & ~outs_rd_cntr_max;

  generate
    for (i = 0; i < L_ARW_REGSTAGE_NUM; i=i+1)
    begin : gen_ar_regstages

      css600_catu_reg_stage
      #(
        .PAYLOAD_WIDTH  ( L_ARW_PAYLOAD_WIDTH )
      )
      u_css600_catu_reg_stage_ar
      (
        .clk            ( clk                       ),
        .reset_n        ( reset_n                   ),
        .valid_src      ( ar_valid_regstages[i]     ),
        .payload_src    ( ar_payload_regstages[i]   ),
        .ready_src      ( ar_ready_regstages[i]     ),
        .valid_dst      ( ar_valid_regstages[i+1]   ),
        .payload_dst    ( ar_payload_regstages[i+1] ),
        .ready_dst      ( ar_ready_regstages[i+1]   )
      );

    end
  endgenerate

  assign translate_arvalid = int_arvalid & rd_trans_enable;
  assign bypass_arvalid = int_arvalid & rd_by_enable;
  assign ds_arvalid = int_arvalid & rd_ds_enable;
  assign int_arready = ((rd_trans_enable & translate_arready)
                      | (rd_by_enable & bypass_arready)
                      | (rd_ds_enable & ds_arready))
                      & ~outs_rd_cntr_max;

  assign aw_valid_regstages[0]                  = awvalid_s & dev_run;
  assign aw_payload_regstages[0]                = aw_payload_src;
  assign awready_s                              = aw_ready_regstages[0] & dev_run;
  assign reg_awvalid                            = aw_valid_regstages[L_ARW_REGSTAGE_NUM];
  assign aw_payload_dst                         = aw_payload_regstages[L_ARW_REGSTAGE_NUM];
  assign aw_ready_regstages[L_ARW_REGSTAGE_NUM] = int_awready;
  assign int_awvalid = reg_awvalid & ~outs_wr_cntr_max;

  generate
    for (i = 0; i < L_ARW_REGSTAGE_NUM; i=i+1)
    begin : gen_aw_regstages

      css600_catu_reg_stage
      #(
        .PAYLOAD_WIDTH  ( L_ARW_PAYLOAD_WIDTH )
      )
      u_css600_catu_reg_stage_aw
      (
        .clk            ( clk                       ),
        .reset_n        ( reset_n                   ),
        .valid_src      ( aw_valid_regstages[i]     ),
        .payload_src    ( aw_payload_regstages[i]   ),
        .ready_src      ( aw_ready_regstages[i]     ),
        .valid_dst      ( aw_valid_regstages[i+1]   ),
        .payload_dst    ( aw_payload_regstages[i+1] ),
        .ready_dst      ( aw_ready_regstages[i+1]   )
      );

    end
  endgenerate

  assign translate_awvalid = int_awvalid & wr_trans_enable;
  assign bypass_awvalid = int_awvalid & wr_by_enable;
  assign ds_awvalid = int_awvalid & wr_ds_enable;
  assign int_awready = ((wr_trans_enable & translate_awready)
                      | (wr_by_enable & bypass_awready)
                      | (wr_ds_enable & ds_awready))
                      & ~outs_wr_cntr_max;

  assign w_valid_regstages[0]                = wvalid_s & dev_run;
  assign w_payload_regstages[0]              = w_payload_src;
  assign wready_s                            = w_ready_regstages[0] & dev_run;
  assign int_wvalid                          = w_valid_regstages[L_W_REGSTAGE_NUM];
  assign w_payload_dst                       = w_payload_regstages[L_W_REGSTAGE_NUM];
  assign w_ready_regstages[L_W_REGSTAGE_NUM] = int_wready;

  generate
    for (i = 0; i < L_W_REGSTAGE_NUM; i=i+1)
    begin : gen_w_regstages

      css600_catu_reg_stage
      #(
        .PAYLOAD_WIDTH  ( L_W_PAYLOAD_WIDTH )
      )
      u_css600_catu_reg_stage_w
      (
        .clk            ( clk                      ),
        .reset_n        ( reset_n                  ),
        .valid_src      ( w_valid_regstages[i]     ),
        .payload_src    ( w_payload_regstages[i]   ),
        .ready_src      ( w_ready_regstages[i]     ),
        .valid_dst      ( w_valid_regstages[i+1]   ),
        .payload_dst    ( w_payload_regstages[i+1] ),
        .ready_dst      ( w_ready_regstages[i+1]   )
      );

    end
  endgenerate

  assign axislv_wvalid = int_wvalid & active_add & (wr_state!=ST_T_DS) & ~invalid_wr;
  assign ds_wvalid     = int_wvalid & ((active_add & (wr_state==ST_T_DS)) | invalid_wr);
  assign int_wready    = (axislv_wready & (wr_state!=ST_T_DS) & ~invalid_wr & active_add)
                       | (ds_wready & (((wr_state==ST_T_DS) & active_add) | invalid_wr));


  assign rdata_s    = ((rd_state!=ST_T_DS) && ~invalid_rd) ? int_rdata : {DATA_WIDTH{1'b0}};
  assign rresp_s    = ((rd_state!=ST_T_DS) && ~invalid_rd) ? int_rresp : ds_rresp;
  assign rlast_s    = ((rd_state!=ST_T_DS) && ~invalid_rd) ? int_rlast : ds_rlast;
  assign rvalid_s   = ((rd_state!=ST_T_DS) && ~invalid_rd) ? int_rvalid : ds_rvalid;
  assign int_rready = rready_s & (rd_state!=ST_T_DS) & ~invalid_rd;
  assign ds_rready  = rready_s & ((rd_state==ST_T_DS) | invalid_rd);
  assign bresp_s    = ((wr_state!=ST_T_DS) && ~invalid_wr) ? int_bresp : ds_bresp;
  assign bvalid_s   = ((wr_state!=ST_T_DS) && ~invalid_wr) ? int_bvalid : ds_bvalid;
  assign int_bready = bready_s & (wr_state!=ST_T_DS) & ~invalid_wr;
  assign ds_bready  = bready_s & ((wr_state==ST_T_DS) | invalid_wr);


  assign status_busy = rd_busy | wr_busy;


endmodule


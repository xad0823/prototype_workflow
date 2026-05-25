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


module css600_catu_axi_master_if
#(
  parameter ADDR_WIDTH  = 40,
  parameter VA_WIDTH    = 40,
  parameter PA_WIDTH    = 40,
  parameter DATA_WIDTH  = 64,
  parameter LEN_WIDTH   = 8,
  parameter SIZE_WIDTH  = 3,
  parameter BURST_WIDTH = 2,
  parameter CACHE_WIDTH = 4,
  parameter PROT_WIDTH  = 3,
  parameter RESP_WIDTH  = 2,
  parameter WSTRB_WIDTH = 8
)(
  input  wire                      clk,
  input  wire                      reset_n,
  output reg                       awakeup_m,
  output wire [ADDR_WIDTH-1:0]     araddr_m,
  output wire [LEN_WIDTH-1:0]      arlen_m,
  output wire [SIZE_WIDTH-1:0]     arsize_m,
  output wire [BURST_WIDTH-1:0]    arburst_m,
  output wire                      arlock_m,
  output wire [CACHE_WIDTH-1:0]    arcache_m,
  output wire [PROT_WIDTH-1:0]     arprot_m,
  output wire [1:0]                arid_m,
  output wire                      arvalid_m,
  input  wire                      arready_m,
  input  wire [DATA_WIDTH-1:0]     rdata_m,
  input  wire [RESP_WIDTH-1:0]     rresp_m,
  input  wire                      rlast_m,
  input  wire [1:0]                rid_m,
  input  wire                      rvalid_m,
  output wire                      rready_m,
  output wire [ADDR_WIDTH-1:0]     awaddr_m,
  output wire [LEN_WIDTH-1:0]      awlen_m,
  output wire [SIZE_WIDTH-1:0]     awsize_m,
  output wire [BURST_WIDTH-1:0]    awburst_m,
  output wire                      awlock_m,
  output wire [CACHE_WIDTH-1:0]    awcache_m,
  output wire [PROT_WIDTH-1:0]     awprot_m,
  output wire                      awvalid_m,
  input  wire                      awready_m,
  output wire [DATA_WIDTH-1:0]     wdata_m,
  output wire [WSTRB_WIDTH-1:0]    wstrb_m,
  output wire                      wlast_m,
  output wire                      wvalid_m,
  input  wire                      wready_m,
  input  wire [RESP_WIDTH-1:0]     bresp_m,
  input  wire                      bvalid_m,
  output wire                      bready_m,
  input  wire [VA_WIDTH-1:0]       axislv_araddr,
  input  wire [LEN_WIDTH-1:0]      axislv_arlen,
  input  wire [SIZE_WIDTH-1:0]     axislv_arsize,
  input  wire [BURST_WIDTH-1:0]    axislv_arburst,
  input  wire                      axislv_arlock,
  input  wire [CACHE_WIDTH-1:0]    axislv_arcache,
  input  wire [PROT_WIDTH-1:0]     axislv_arprot,
  input  wire                      bypass_arvalid,
  output wire                      bypass_arready,
  output wire [DATA_WIDTH-1:0]     int_rdata,
  output wire [RESP_WIDTH-1:0]     int_rresp,
  output wire                      int_rlast,
  output wire                      axislv_rvalid,
  input  wire                      axislv_rready,
  input  wire [VA_WIDTH-1:0]       axislv_awaddr,
  input  wire [LEN_WIDTH-1:0]      axislv_awlen,
  input  wire [SIZE_WIDTH-1:0]     axislv_awsize,
  input  wire [BURST_WIDTH-1:0]    axislv_awburst,
  input  wire                      axislv_awlock,
  input  wire [CACHE_WIDTH-1:0]    axislv_awcache,
  input  wire [PROT_WIDTH-1:0]     axislv_awprot,
  input  wire                      bypass_awvalid,
  output wire                      bypass_awready,
  input  wire [DATA_WIDTH-1:0]     int_wdata,
  input  wire [WSTRB_WIDTH-1:0]    int_wstrb,
  input  wire                      int_wlast,
  input  wire                      int_wvalid,
  output wire                      int_wready,
  output wire [RESP_WIDTH-1:0]     int_bresp,
  output wire                      int_bvalid,
  input  wire                      int_bready,
  input  wire                      translated_arvalid,
  output wire                      translated_arready,
  input  wire [PA_WIDTH-1:0]       translated_araddr,
  input  wire                      translated_awvalid,
  output wire                      translated_awready,
  input  wire [PA_WIDTH-1:0]       translated_awaddr,
  input  wire                      slw_arvalid,
  output wire                      slw_arready,
  input  wire [1:0]                slw_aid,
  input  wire [PA_WIDTH-1:0]       slw_araddr,
  input  wire [3:0]                slw_arlen,
  input  wire [SIZE_WIDTH-1:0]     slw_arsize,
  output wire [1:0]                slw_rid,
  output wire                      slw_rvalid,
  input  wire                      slw_rready,
  output wire                      slw_rlast,
  input  wire                      ctrl_mode,
  input  wire [3:0]                axictrl_arcache,
  input  wire [1:0]                axictrl_arprot,
  output wire                      slw_err,
  output wire                      status_resp_err
);


  localparam L_AR_PAYLOAD_WIDTH  = PA_WIDTH  +
                                   LEN_WIDTH   +
                                   SIZE_WIDTH  +
                                   BURST_WIDTH +
                                   3           +
                                   CACHE_WIDTH +
                                   PROT_WIDTH;
  localparam L_AW_PAYLOAD_WIDTH  = PA_WIDTH  +
                                   LEN_WIDTH   +
                                   SIZE_WIDTH  +
                                   BURST_WIDTH +
                                   1           +
                                   CACHE_WIDTH +
                                   PROT_WIDTH;

  localparam L_W_PAYLOAD_WIDTH    = DATA_WIDTH  +
                                    WSTRB_WIDTH +
                                    1;

  localparam L_R_PAYLOAD_WIDTH    = DATA_WIDTH  +
                                    5;

  localparam L_ARW_REGSTAGE_NUM   = 1;
  localparam L_W_REGSTAGE_NUM     = 1;
  localparam L_R_REGSTAGE         = 1;

  genvar i;

  wire                           rresp_err;
  wire                           bresp_err;
  wire [L_AR_PAYLOAD_WIDTH-1:0]  ar_payload_src;
  wire [L_AR_PAYLOAD_WIDTH-1:0]  ar_payload_dst;
/* verilator lint_off UNOPTFLAT */
  wire [L_ARW_REGSTAGE_NUM:0]    ar_ready_regstages;
/* verilator lint_on UNOPTFLAT */
  wire [L_ARW_REGSTAGE_NUM:0]    ar_valid_regstages;
  wire [L_AR_PAYLOAD_WIDTH-1:0]  ar_payload_regstages [L_ARW_REGSTAGE_NUM:0];
  wire [L_AW_PAYLOAD_WIDTH-1:0]  aw_payload_src;
  wire [L_AW_PAYLOAD_WIDTH-1:0]  aw_payload_dst;
/* verilator lint_off UNOPTFLAT */
  wire [L_ARW_REGSTAGE_NUM:0]    aw_ready_regstages;
/* verilator lint_on UNOPTFLAT */
  wire [L_ARW_REGSTAGE_NUM:0]    aw_valid_regstages;
  wire [L_AW_PAYLOAD_WIDTH-1:0]  aw_payload_regstages [L_ARW_REGSTAGE_NUM:0];
  wire [L_W_PAYLOAD_WIDTH-1:0]   w_payload_src;
  wire [L_W_PAYLOAD_WIDTH-1:0]   w_payload_dst;
/* verilator lint_off UNOPTFLAT */
  wire [L_W_REGSTAGE_NUM:0]      w_ready_regstages;
/* verilator lint_on UNOPTFLAT */
  wire [L_W_REGSTAGE_NUM:0]      w_valid_regstages;
  wire [L_W_PAYLOAD_WIDTH-1:0]   w_payload_regstages [L_W_REGSTAGE_NUM:0];

  wire [1:0]                int_arid;
  wire                      int_arvalid;
  wire                      int_arready;
  wire [PA_WIDTH-1:0]       int_araddr;
  wire [LEN_WIDTH-1:0]      int_arlen;
  wire [SIZE_WIDTH-1:0]     int_arsize;
  wire [BURST_WIDTH-1:0]    int_arburst;
  wire                      int_arlock;
  wire [CACHE_WIDTH-1:0]    int_arcache;
  wire [PROT_WIDTH-1:0]     int_arprot;
  wire                      int_awvalid;
  wire                      int_awready;
  wire [PA_WIDTH-1:0]       int_awaddr;
  wire                      int_rvalid;
  wire                      int_rready;
  wire [1:0]                int_rid;
  wire                      ar_upd_en;
  wire                      next_arvalid_q;
  reg                       arvalid_q;
  reg  [2:0]                arsel;
  reg  [2:0]                arsel_q;
  wire [2:0]                rd_mux_cntl;
  wire                      awakeup_set;
  wire                      awakeup_clr;
  wire                      awakeup_en;


  assign rresp_err = int_rvalid & int_rresp[1];
  assign bresp_err = bvalid_m & bresp_m[1];

  generate
   if (DATA_WIDTH == 128)
    begin : g_128_bit
      assign slw_err = int_rvalid & int_rresp[1];
    end
   else
    begin : g_not_128_bit
      assign slw_err = int_rvalid & int_rresp[1];
    end
  endgenerate

  always @*
   begin : p_ar_sel
    case ({~ctrl_mode, translated_arvalid, slw_arvalid})
      3'b000  : arsel = 3'b000;
      3'b001  : arsel = 3'b001;
      3'b010  : arsel = 3'b010;
      3'b011  : arsel = 3'b001;
      3'b100  : arsel = 3'b100;
      3'b101  : arsel = 3'b001;
      3'b110  : arsel = 3'b100;
      3'b111  : arsel = 3'b001;
      default : arsel = 3'bxxx;
    endcase
  end

  assign int_araddr  = rd_mux_cntl[2] ? axislv_araddr :
                       rd_mux_cntl[1] ? translated_araddr :
                                        slw_araddr;
  assign int_arcache = rd_mux_cntl[0] ? axictrl_arcache : axislv_arcache;
  assign int_arprot  = rd_mux_cntl[0] ? axictrl_arprot : axislv_arprot;
  assign int_arlen   = rd_mux_cntl[0] ? {4'h0,slw_arlen} : axislv_arlen;
  assign int_arsize  = rd_mux_cntl[0] ? slw_arsize : axislv_arsize;
  assign int_arburst = rd_mux_cntl[0] ? 2'b01 : axislv_arburst;
  assign int_arlock  = rd_mux_cntl[0] ? 1'b0 : axislv_arlock;
  assign int_arid    = rd_mux_cntl[0] ? slw_aid : 2'b00;

  assign ar_upd_en = (arvalid_q & int_arready) | (~arvalid_q & int_arvalid);
  assign rd_mux_cntl = !(arvalid_q) ? arsel : arsel_q;
  assign next_arvalid_q = int_arvalid & ~int_arready;

  assign int_arvalid = slw_arvalid | translated_arvalid | bypass_arvalid;
  assign bypass_arready = rd_mux_cntl[2] & int_arready;
  assign translated_arready =  rd_mux_cntl[1] & int_arready;
  assign slw_arready    =  rd_mux_cntl[0] & int_arready;

  always @(posedge clk or negedge reset_n)
  begin : p_state
    if (!reset_n) begin
      arsel_q <= 3'b000;
      arvalid_q <= 1'b0;
    end
    else if (ar_upd_en) begin
      arsel_q <= arsel;
      arvalid_q <= next_arvalid_q;
    end
  end


  assign ar_payload_src = { int_araddr,
                            int_arlen,
                            int_arsize,
                            int_arburst,
                            int_arlock,
                            int_arcache,
                            int_arprot,
                            int_arid  };
  assign { araddr_m[PA_WIDTH-1:0],
           arlen_m,
           arsize_m,
           arburst_m,
           arlock_m,
           arcache_m,
           arprot_m,
           arid_m  } = ar_payload_dst;


  assign int_awaddr  = !ctrl_mode ? axislv_awaddr :
                       translated_awaddr;

  assign int_awvalid = translated_awvalid | bypass_awvalid;
  assign bypass_awready = ~ctrl_mode & int_awready;
  assign translated_awready = translated_awvalid & ctrl_mode & int_awready;

  assign aw_payload_src = { int_awaddr,
                            axislv_awlen,
                            axislv_awsize,
                            axislv_awburst,
                            axislv_awlock,
                            axislv_awcache,
                            axislv_awprot  };
  assign { awaddr_m[PA_WIDTH-1:0],
           awlen_m,
           awsize_m,
           awburst_m,
           awlock_m,
           awcache_m,
           awprot_m  } = aw_payload_dst;

  assign w_payload_src = { int_wdata,
                           int_wstrb,
                           int_wlast };
  assign { wdata_m,
           wstrb_m,
           wlast_m } = w_payload_dst;


  generate
    if (ADDR_WIDTH > PA_WIDTH)
    begin : gen_pad_addr
        assign awaddr_m[ADDR_WIDTH-1:PA_WIDTH] = {ADDR_WIDTH-PA_WIDTH{1'b0}};
        assign araddr_m[ADDR_WIDTH-1:PA_WIDTH] = {ADDR_WIDTH-PA_WIDTH{1'b0}};
    end
  endgenerate

  assign awakeup_set = int_awvalid | int_arvalid;
  assign awakeup_clr = ((awvalid_m & awready_m) | (arvalid_m & arready_m)) & (awvalid_m ^ arvalid_m);
  assign awakeup_en = (awakeup_set | awakeup_clr);

  always @(posedge clk or negedge reset_n)
  begin : p_wakeup
    if (!reset_n) begin
      awakeup_m <= 1'b0;
    end
    else if (awakeup_en) begin
      awakeup_m <= awakeup_set;
    end
  end


  assign ar_valid_regstages[0]                  = int_arvalid;
  assign ar_payload_regstages[0]                = ar_payload_src;
  assign int_arready                            = ar_ready_regstages[0];
  assign arvalid_m                              = ar_valid_regstages[L_ARW_REGSTAGE_NUM];
  assign ar_payload_dst                         = ar_payload_regstages[L_ARW_REGSTAGE_NUM];
  assign ar_ready_regstages[L_ARW_REGSTAGE_NUM] = arready_m;
  generate
    for (i = 0; i < L_ARW_REGSTAGE_NUM; i=i+1)
    begin : gen_ar_regstages

      css600_catu_reg_stage
      #(
        .PAYLOAD_WIDTH  ( L_AR_PAYLOAD_WIDTH )
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

  assign aw_valid_regstages[0]                  = int_awvalid;
  assign aw_payload_regstages[0]                = aw_payload_src;
  assign int_awready                            = aw_ready_regstages[0];
  assign awvalid_m                              = aw_valid_regstages[L_ARW_REGSTAGE_NUM];
  assign aw_payload_dst                         = aw_payload_regstages[L_ARW_REGSTAGE_NUM];
  assign aw_ready_regstages[L_ARW_REGSTAGE_NUM] = awready_m;
  generate
    for (i = 0; i < L_ARW_REGSTAGE_NUM; i=i+1)
    begin : gen_aw_regstages

      css600_catu_reg_stage
      #(
        .PAYLOAD_WIDTH  ( L_AW_PAYLOAD_WIDTH )
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

  assign w_valid_regstages[0]                = int_wvalid;
  assign w_payload_regstages[0]              = w_payload_src;
  assign int_wready                          = w_ready_regstages[0];
  assign wvalid_m                            = w_valid_regstages[L_W_REGSTAGE_NUM];
  assign w_payload_dst                       = w_payload_regstages[L_W_REGSTAGE_NUM];
  assign w_ready_regstages[L_W_REGSTAGE_NUM] = wready_m;
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

  generate
    if (L_R_REGSTAGE == 1)
      begin : gen_rslice
        wire [L_R_PAYLOAD_WIDTH-1:0] r_payload_src;
        wire [L_R_PAYLOAD_WIDTH-1:0] r_payload_dst;

        assign r_payload_src = { rid_m,
                                 rdata_m,
                                 rresp_m,
                                 rlast_m };
        assign { int_rid,
                 int_rdata,
                 int_rresp,
                 int_rlast } = r_payload_dst;

        assign int_rready = int_rvalid && (|int_rid) ? slw_rready : axislv_rready;

        css600_catu_reg_stage
        #(
        .PAYLOAD_WIDTH  ( L_R_PAYLOAD_WIDTH )
        )
        u_css600_catu_reg_stage_r
        (
           .clk            ( clk           ),
           .reset_n        ( reset_n       ),
           .valid_src      ( rvalid_m      ),
           .payload_src    ( r_payload_src ),
           .ready_src      ( rready_m      ),
           .valid_dst      ( int_rvalid    ),
           .payload_dst    ( r_payload_dst ),
           .ready_dst      ( int_rready    )
        );

    end
    else
      begin : gen_no_rslice

        assign int_rid       = rid_m;
        assign int_rdata     = rdata_m;
        assign int_rresp     = rresp_m;
        assign int_rlast     = rlast_m;
        assign int_rvalid    = rvalid_m;
        assign int_rready    = int_rvalid && (|int_rid) ? slw_rready : axislv_rready;
        assign rready_m      = int_rready;
    end
  endgenerate

  assign axislv_rvalid = int_rvalid & ~(|int_rid);
  assign slw_rid       = int_rid;
  assign slw_rvalid    = int_rvalid & (|int_rid);
  assign slw_rlast     = int_rlast & (|int_rid);

  assign int_bresp     = bresp_m;
  assign int_bvalid    = bvalid_m;
  assign bready_m      = int_bready;

  assign status_resp_err = rresp_err | bresp_err;


endmodule


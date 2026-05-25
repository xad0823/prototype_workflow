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
//   Sub-module of css600_dp
//
//----------------------------------------------------------------------------


module css600_dpslv_reg_block
  #(parameter JTAG_DP = 1,
    parameter SW_DP = 1,
    parameter ADDR_SIZE = 32)
   (
    input  wire        swclktck,
    input  wire        porst_n,

    input wire  [31:0] reg_wdata_i,
    input wire  [1:0]  reg_addr_i,
    input wire         reg_write_i,
    input wire         reg_orun_i,
    input wire         reg_sel_i,
    input wire         reg_wdata_err_i,
    input wire         reg_readok_i,

    input wire         stickyerr_clr_i,
    input wire         linereset_i,
    output wire  [31:0] reg_rdata_o,
    output wire         reg_stky_err_o,
    output wire   [3:0] reg_select_dpbanksel_o,
    output wire [31:28] reg_dlpidr_o,
    output wire  [27:0] reg_targetid_o,
    output wire         reg_orundetect_o,
    output wire         reg_wdataerr_o,

    input  wire        jtagactive_i,

    input wire         swactive_i,

    input wire         dp_eventstatus_i,

    output wire         cdbgpwrupreq_o,
    output wire         csyspwrupreq_o,
    output wire         cdbgrstreq_o,
    input  wire         cdbgpwrupack_i,
    input  wire         csyspwrupack_i,
    input  wire         cdbgrstack_i,

    output wire [ADDR_SIZE-1:0] reg_paddr_o,
    input  wire                 bus_err_set_i,
    input  wire          [31:0] bus_rdata_i,

    input wire [31:0]          targetid_i,
    input wire [3:0]           instanceid_i,
    input wire [ADDR_SIZE-1:0] baseaddr_i,
    input wire                 baseaddr_valid_i,

    output wire        dp_abort_o,

    output wire [1:0]  sw_trn_o
    );

  `include "css600_dpslv_reg_block_localparams.v"


  wire abort_sel;
  wire ctrlstat_sel;
  wire dlcr_sel;
  wire select_sel;

  wire addr0_sel;
  wire addr4_sel;
  wire addr8_sel;
  wire addr12_sel;

/* verilator lint_off UNOPTFLAT */
  reg [15:0] dp_reg_sel;
/* verilator lint_on UNOPTFLAT */
  reg  [3:0] dp_addr_sel;

  reg [31:0] reg_rdata;

  wire dp_abort_cond;
  reg  dp_abort_cond_q;
  wire dp_abort;

  wire [31:0] dpidr1;

  wire [31:0] baseptr0;

  wire [31:0] baseptr1;

  reg         ctrlstat_csyspwrupreq_q;
  reg         ctrlstat_cdbgpwrupreq_q;
  reg         ctrlstat_cdbgrstreq_q;
  reg         ctrlstat_errmode_q;
  reg         ctrlstat_orundetect_q;
  wire        ctrlstat_wdataerr_next;
  wire        ctrlstat_wdataerr_load;
  reg         ctrlstat_wdataerr_q;
  wire        ctrlstat_wdataerr;
  wire        ctrlstat_readok;
  wire        ctrlstat_stickyerr_set;
  wire        ctrlstat_stickyerr_clr;
  reg         ctrlstat_stickyerr_q;
  wire        ctrlstat_stickyerr;
  wire        ctrlstat_stickyorun_set;
  wire        ctrlstat_stickyorun_clr;
  reg         ctrlstat_stickyorun_q;
  wire        ctrlstat_stickyorun;
  wire        reg_stky_err;
  wire [31:0] ctrlstat;

  wire  [1:0] dlcr_turnaround_next;
  wire        dlcr_turnaround_load;
  reg   [1:0] dlcr_turnaround_q;
  wire  [1:0] dlcr_turnaround;
  wire [31:0] dlcr;

  wire [31:0] targetid;

  wire  [3:0] dlpidr_tinstance;
  wire  [3:0] dlpidr_protvsn;
  wire [31:0] dlpidr;

  wire [31:0] eventstat;

  wire        dpbanksel_en;
  wire  [3:0] next_sel_dpbanksel;
  reg  [ADDR_SIZE-1:4] select_addr_q;
  reg   [3:0] select_dpbanksel_q;

  wire [31:0] rdbuff;

  assign reg_rdata_o            = reg_rdata;
  assign reg_stky_err_o         = reg_stky_err;
  assign reg_select_dpbanksel_o = select_dpbanksel_q;
  assign reg_dlpidr_o           = dlpidr [31:28];
  assign reg_targetid_o         = targetid [27:0];
  assign csyspwrupreq_o         = ctrlstat[30];
  assign cdbgpwrupreq_o         = ctrlstat[28];
  assign cdbgrstreq_o           = ctrlstat[26];
  assign reg_paddr_o            = {select_addr_q, {4{1'b0}}};
  assign dp_abort_o             = dp_abort;
  assign reg_orundetect_o       = ctrlstat[0];
  assign sw_trn_o               = dlcr[9:8];
  assign reg_wdataerr_o         = ctrlstat[7];


  always @*
    case (reg_addr_i)
      DP_ADDR_0 : dp_addr_sel = DP_ADDR_SEL_0;
      DP_ADDR_4 : dp_addr_sel = DP_ADDR_SEL_4;
      DP_ADDR_8 : dp_addr_sel = DP_ADDR_SEL_8;
      DP_ADDR_C : dp_addr_sel = DP_ADDR_SEL_C;
      default   : dp_addr_sel = 4'bxxxx;
    endcase

  assign addr0_sel = dp_addr_sel[0];
  assign addr4_sel = dp_addr_sel[1];
  assign addr8_sel = dp_addr_sel[2];
  assign addr12_sel = dp_addr_sel[3];

  always @* begin
    if (reg_sel_i) begin
      if (addr0_sel && reg_write_i)
        dp_reg_sel = ABORT_REG_SEL;
      else if (addr0_sel && (!reg_write_i)) begin
        case (select_dpbanksel_q)
          4'b0000 : dp_reg_sel = DPIDR_REG_SEL;
          4'b0001 : dp_reg_sel = DPIDR1_REG_SEL;
          4'b0010 : dp_reg_sel = BASEPTR0_REG_SEL;
          4'b0011 : dp_reg_sel = BASEPTR1_REG_SEL;
          4'b0100,
          4'b0101,
          4'b0110,
          4'b0111,
          4'b1000,
          4'b1001,
          4'b1010,
          4'b1011,
          4'b1100,
          4'b1101,
          4'b1110,
          4'b1111 : dp_reg_sel = RESERVED_REG_SEL;
          default : dp_reg_sel = 16'bxxxxxxxxxxxxxxxx;
        endcase
      end
      else if (addr4_sel) begin
        case (select_dpbanksel_q)
          4'b0000 : dp_reg_sel = CTRLSTAT_REG_SEL;
          4'b0001 : dp_reg_sel = DLCR_REG_SEL;
          4'b0010 : dp_reg_sel = TARGETID_REG_SEL;
          4'b0011 : dp_reg_sel = DLPIDR_REG_SEL;
          4'b0100 : dp_reg_sel = EVENTSTAT_REG_SEL;
          4'b0101 : dp_reg_sel = SELECT1_REG_SEL;
          4'b0110,
          4'b0111,
          4'b1000,
          4'b1001,
          4'b1010,
          4'b1011,
          4'b1100,
          4'b1101,
          4'b1110,
          4'b1111 : dp_reg_sel = RESERVED_REG_SEL;
          default : dp_reg_sel = 16'bxxxxxxxxxxxxxxxx;
        endcase
      end
      else if (addr8_sel)
        dp_reg_sel = reg_write_i ? SELECT_REG_SEL : RESEND_REG_SEL;
      else if (addr12_sel)
        dp_reg_sel = reg_write_i ? TARGETSEL_REG_SEL : RDBUFF_REG_SEL;
      else
        dp_reg_sel = 16'bxxxxxxxxxxxxxxxx;
    end
    else
      dp_reg_sel = NO_REG_SEL;
  end

  assign abort_sel     = dp_reg_sel[0];
  assign ctrlstat_sel  = dp_reg_sel[5];
  assign dlcr_sel      = dp_reg_sel[6];
  assign select_sel    = dp_reg_sel[12];


    always @*
    case (dp_reg_sel)
      ABORT_REG_SEL     : reg_rdata = 32'h00000000;
      DPIDR_REG_SEL     : reg_rdata = DPIDR;
      DPIDR1_REG_SEL    : reg_rdata = dpidr1;
      BASEPTR0_REG_SEL  : reg_rdata = baseptr0;
      BASEPTR1_REG_SEL  : reg_rdata = baseptr1;
      CTRLSTAT_REG_SEL  : reg_rdata = ctrlstat;
      DLCR_REG_SEL      : reg_rdata = dlcr;
      TARGETID_REG_SEL  : reg_rdata = targetid;
      DLPIDR_REG_SEL    : reg_rdata = dlpidr;
      EVENTSTAT_REG_SEL : reg_rdata = eventstat;
      SELECT1_REG_SEL   : reg_rdata = 32'h00000000;
      RESEND_REG_SEL    : reg_rdata = rdbuff;
      SELECT_REG_SEL    : reg_rdata = 32'h00000000;
      RDBUFF_REG_SEL    : reg_rdata = rdbuff;
      TARGETSEL_REG_SEL : reg_rdata = 32'h00000000;
      RESERVED_REG_SEL  : reg_rdata = 32'h00000000;
      NO_REG_SEL        : reg_rdata = 32'h00000000;
      default           : reg_rdata = 32'hxxxxxxxx;
    endcase

  assign dp_abort_cond = abort_sel && reg_wdata_i[0];

  always @(posedge swclktck, negedge porst_n)
    if(!porst_n)
      dp_abort_cond_q <= 1'b0;
    else
      dp_abort_cond_q <= dp_abort_cond;

  assign dp_abort = dp_abort_cond && (!dp_abort_cond_q);

  assign dpidr1 = {{24{1'b0}}, 1'b1, ADDR_SIZE[6:0]};


generate
  if (ADDR_SIZE==32) begin : addr_size_32
     assign baseptr0 = {baseaddr_i[31:12], {11{1'b0}}, baseaddr_valid_i};
  end
  else if (ADDR_SIZE==20) begin : addr_size_20
     assign baseptr0 = {{12{1'b0}}, baseaddr_i[19:12], {11{1'b0}}, baseaddr_valid_i};
  end
  else begin : addr_size_12
     assign baseptr0 = {{31{1'b0}}, baseaddr_valid_i};
  end
endgenerate


  assign baseptr1 = {{32{1'b0}}};


  always @(posedge swclktck, negedge porst_n) begin
    if(!porst_n) begin
      ctrlstat_csyspwrupreq_q <= 1'b0;
      ctrlstat_cdbgpwrupreq_q <= 1'b0;
      ctrlstat_cdbgrstreq_q   <= 1'b0;
      ctrlstat_errmode_q      <= 1'b0;
      ctrlstat_orundetect_q   <= 1'b0;
    end
    else if (ctrlstat_sel && reg_write_i)begin
      ctrlstat_csyspwrupreq_q <= reg_wdata_i[30];
      ctrlstat_cdbgpwrupreq_q <= reg_wdata_i[28];
      ctrlstat_cdbgrstreq_q   <= reg_wdata_i[26];
      ctrlstat_errmode_q      <= reg_wdata_i[24];
      ctrlstat_orundetect_q   <= reg_wdata_i[0];
    end
  end


  assign ctrlstat_wdataerr_next = reg_wdata_err_i;

  assign ctrlstat_wdataerr_load = reg_wdata_err_i || (abort_sel && (reg_wdata_i[3]));

  always @(posedge swclktck, negedge porst_n)
    if(!porst_n)
      ctrlstat_wdataerr_q <= 1'b0;
    else if (ctrlstat_wdataerr_load)
      ctrlstat_wdataerr_q <= ctrlstat_wdataerr_next;

  assign ctrlstat_wdataerr = (swactive_i) ? ctrlstat_wdataerr_q :
                             1'b0;

  assign ctrlstat_readok   = (swactive_i) ? reg_readok_i:
                             1'b0;

  assign ctrlstat_stickyerr_set = bus_err_set_i;

  assign ctrlstat_stickyerr_clr = (jtagactive_i && ctrlstat_sel && reg_write_i && reg_wdata_i[5]) ||
                                  (abort_sel && reg_wdata_i[2]) ||

                                  (ctrlstat_errmode_q && stickyerr_clr_i);

  always @(posedge swclktck, negedge porst_n)
    if(!porst_n)
      ctrlstat_stickyerr_q <= 1'b0;
    else if (ctrlstat_stickyerr_set)
      ctrlstat_stickyerr_q <= 1'b1;
    else if (ctrlstat_stickyerr_clr)
      ctrlstat_stickyerr_q <= 1'b0;

  assign ctrlstat_stickyerr = ctrlstat_stickyerr_q;

  assign ctrlstat_stickyorun_set = ctrlstat_orundetect_q && reg_orun_i;

  assign ctrlstat_stickyorun_clr = (jtagactive_i && ctrlstat_sel && reg_write_i && reg_wdata_i[1]) ||
                                   (abort_sel && reg_wdata_i[4]);


  always @(posedge swclktck, negedge porst_n)
    if(!porst_n)
      ctrlstat_stickyorun_q <= 1'b0;
    else if (ctrlstat_stickyorun_set)
      ctrlstat_stickyorun_q <= 1'b1;
    else if (ctrlstat_stickyorun_clr)
      ctrlstat_stickyorun_q <= 1'b0;

  assign ctrlstat_stickyorun = ctrlstat_stickyorun_q;


  assign ctrlstat = {csyspwrupack_i,
                     ctrlstat_csyspwrupreq_q,
                     cdbgpwrupack_i,
                     ctrlstat_cdbgpwrupreq_q,
                     cdbgrstack_i,
                     ctrlstat_cdbgrstreq_q,
                     1'b0,
                     ctrlstat_errmode_q,
                     {16{1'b0}},
                     ctrlstat_wdataerr,
                     ctrlstat_readok,
                     ctrlstat_stickyerr,
                     {3{1'b0}},
                     ctrlstat_stickyorun,
                     ctrlstat_orundetect_q
                     };

  assign reg_stky_err = ctrlstat[1] || ctrlstat[5];


  assign dlcr_turnaround_next = linereset_i ? 2'h0 : reg_wdata_i[9:8];

  assign dlcr_turnaround_load = linereset_i | (dlcr_sel && reg_write_i);

  always @(posedge swclktck, negedge porst_n)
    if(!porst_n)
      dlcr_turnaround_q <= 2'b00;
    else if (dlcr_turnaround_load)
      dlcr_turnaround_q <= dlcr_turnaround_next;


  assign dlcr_turnaround = dlcr_turnaround_q ;


  assign dlcr = swactive_i
                ? {{22{1'b0}}, dlcr_turnaround, 1'b0, 1'b1, {6{1'b0}}}
                : {{24{1'b0}}, 1'b0, 1'b0, {6{1'b0}}};


  assign targetid = {targetid_i[31:1], 1'b1};


  assign dlpidr_tinstance = swactive_i ? instanceid_i : 4'b0000;
  assign dlpidr_protvsn   = swactive_i ? 4'h1 : 4'h1;

  assign dlpidr = {dlpidr_tinstance, {24{1'b0}}, dlpidr_protvsn};


  assign eventstat = {{31{1'b0}}, (!dp_eventstatus_i)};


  always @(posedge swclktck, negedge porst_n) begin
    if(!porst_n) begin
      select_addr_q <= {ADDR_SIZE-4{1'b0}};
    end
    else if (select_sel) begin
      select_addr_q <= reg_wdata_i[ADDR_SIZE-1:4];
    end
  end

  assign next_sel_dpbanksel = linereset_i ? 4'h0 : reg_wdata_i[3:0];
  assign dpbanksel_en = linereset_i | select_sel;

  always @(posedge swclktck, negedge porst_n) begin
    if(!porst_n) begin
      select_dpbanksel_q <= 4'h0;
    end
    else if (dpbanksel_en) begin
      select_dpbanksel_q <= next_sel_dpbanksel;
    end
  end

  assign rdbuff = swactive_i ? bus_rdata_i : 32'h00000000;


endmodule



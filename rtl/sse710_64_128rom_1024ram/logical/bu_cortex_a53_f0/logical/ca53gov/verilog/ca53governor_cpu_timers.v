//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Description: Architectural timer block
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53governor_cpu_timers (
  // Inputs
  input  wire        CLKIN,
  input  wire        DFTSE,
  input  wire        clk_cpu,
  input  wire        reset_n_gov,
  input  wire        valid_timer_en_i,
  input  wire  [8:0] cp_gov_addr_rs_i,
  input  wire [63:0] cp_gov_wdata_rs_i,
  input  wire        cp_gov_wenable_rs_i,
  input  wire [63:0] cntvalueb_rs_i,
  input  wire        dcu_cp_gov_req_i,
  input  wire        dcu_cp_gov_sel_i,
  // Outputs
  output wire [63:0] timer_cp_rdata_o,
  output wire        gov_pcnt_kernel_access_o,
  output wire        gov_pcnt_usr_access_o,
  output wire        gov_vcnt_usr_access_o,
  output wire        gov_cntp_usr_access_o,
  output wire        gov_cntv_usr_access_o,
  output wire        gov_cntp_kernel_access_o,
  output wire        ncntpsirq_o,
  output wire        ncntpnsirq_o,
  output wire        ncnthpirq_o,
  output wire        ncntvirq_o,
  output wire        timer_wfe_event_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg   [3:0] cntkctl_evnti;
  reg         cntkctl_evntdir;
  reg         cntkctl_evnten;
  reg         vcnt_usr_access;
  reg         pcnt_usr_access;
  reg  [63:0] cntvalueb_local_rs;
  reg         cntv_usr_access;
  reg         cntp_usr_access;
  reg   [3:0] cnthctl_evnti;
  reg         cnthctl_evntdir;
  reg         cnthctl_evnten;
  reg         cntp_kernel_access;
  reg         pcnt_kernel_access;
  reg         cntp_ctl_mask_intrpt;
  reg         cntp_ctl_mask_intrpt_ns;
  reg         cntp_ctl_timer_en;
  reg         cntp_ctl_timer_en_ns;
  reg         cntv_ctl_mask_intrpt;
  reg         cntv_ctl_timer_en;
  reg         cnthp_ctl_mask_intrpt;
  reg         cnthp_ctl_timer_en;
  reg  [31:0] cp_cntfrq;
  reg  [63:0] cp_cntvoff;
  reg  [63:0] cp_cntp_cval;
  reg  [63:0] cp_cntp_cval_ns;
  reg  [63:0] cp_cntv_cval;
  reg  [63:0] cp_cnthp_cval;
  reg         msk_cntpsirq_rs;
  reg         msk_cntpnsirq_rs;
  reg         msk_cnthpirq_rs;
  reg         msk_cntvirq_rs;
  reg         pcnt_sample_bit;
  reg         vcnt_sample_bit;
  reg         timer_wfe_event;
  reg         timer_clock_en;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire        clk_timer;
  wire        cntp_ctl_int_ro;
  wire        cntp_ctl_int_ro_ns;
  wire        cntv_ctl_int_ro;
  wire        cnthp_ctl_int_ro;
  wire [31:0] cp_cntfrq_rd;
  wire [31:0] cp_cnthctl_rd;
  wire        cp_cnthp_cval_en;
  wire [31:0] cp_cnthp_tval_rd;
  wire [31:0] cp_cnthp_ctl_rd;
  wire [31:0] cp_cntkctl_rd;
  wire        cp_cntp_cval_en;
  wire [31:0] cp_cntp_tval_rd;
  wire [31:0] cp_cntp_tval_ns_rd;
  wire [31:0] cp_cntp_ctl_rd;
  wire [31:0] cp_cntp_ctl_ns_rd;
  wire        cp_cntv_cval_en;
  wire        cp_cntp_cval_ns_en;
  wire [31:0] cp_cntv_tval_rd;
  wire [31:0] cp_cntv_ctl_rd;
  wire [63:0] cp_cntpct_rd;
  wire [63:0] cp_cntvct_rd;
  wire [63:0] cp_cntvoff_rd;
  wire [63:0] nxt_cp_cval;
  wire [63:0] cp_cntp_cval_rd;
  wire [63:0] cp_cntp_cval_ns_rd;
  wire [63:0] nxt_cp_cntv_cval;
  wire [63:0] cp_cntv_cval_rd;
  wire [63:0] cp_cnthp_cval_rd;
  wire [31:0] cp_cntp_tval;
  wire [31:0] cp_cntp_tval_ns;
  wire [31:0] cp_cntv_tval;
  wire [31:0] cp_cnthp_tval;
  wire [63:0] cp_cntpct;
  wire [63:0] cp_cntvct;
  wire        rd_cntfrq_el0;
  wire        rd_cntkctl_el1;
  wire        rd_cntps_tval_el1;
  wire        rd_cntp_tval_el0;
  wire        rd_cntps_ctl_el1;
  wire        rd_cntp_ctl_el0;
  wire        rd_cntv_tval_el0;
  wire        rd_cntv_ctl_el0;
  wire        rd_cnthctl_el2;
  wire        rd_cnthp_tval_el2;
  wire        rd_cnthp_ctl_el2;
  wire        rd_cntpct_el0;
  wire        rd_cntvct_el0;
  wire        rd_cntvoff_el2;
  wire        rd_cntps_cval_el1;
  wire        rd_cntp_cval_el0;
  wire        rd_cntv_cval_el0;
  wire        rd_cnthp_cval_el2;
  wire        wr_cntfrq_el0;
  wire        wr_cntkctl_el1;
  wire        wr_cntps_tval_el1;
  wire        wr_cntp_tval_el0;
  wire        wr_cntps_ctl_el1;
  wire        wr_cntp_ctl_el0;
  wire        wr_cntv_tval_el0;
  wire        wr_cntv_ctl_el0;
  wire        wr_cnthctl_el2;
  wire        wr_cnthp_tval_el2;
  wire        wr_cnthp_ctl_el2;
  wire        wr_cntvoff_el2;
  wire        wr_cntps_cval_el1;
  wire        wr_cntp_cval_el0;
  wire        wr_cntv_cval_el0;
  wire        wr_cnthp_cval_el2;
  wire        nxt_pcnt_sample_bit;
  wire        nxt_vcnt_sample_bit;
  wire        ptval_wr_en;
  wire [63:0] pcmp_value;
  wire [63:0] vcmp_value;
  wire [63:0] cmp_cntv_cval;
  wire        cntpsirq_triggered;
  wire        cntpnsirq_triggered;
  wire        cnthpirq_triggered;
  wire        cntvirq_triggered;
  wire        cntpsirq;
  wire        cntpnsirq;
  wire        cnthpirq;
  wire        cntvirq;
  wire        msk_cntpsirq;
  wire        msk_cntpnsirq;
  wire        msk_cnthpirq;
  wire        msk_cntvirq;
  wire        wfe_pevnt;
  wire        wfe_vevnt;
  wire        nxt_timer_wfe_event;
  wire        nxt_timer_clock_en;
  wire        cntvalueb_local_lo_en;
  wire        cntvalueb_local_hi_en;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Regional clock gate
  // ------------------------------------------------------

  assign nxt_timer_clock_en = dcu_cp_gov_req_i & dcu_cp_gov_sel_i;

  always @(posedge clk_cpu or negedge reset_n_gov)
    if (!reset_n_gov)
      timer_clock_en <= 1'b1;
    else
      timer_clock_en <= nxt_timer_clock_en;

  ca53_cell_inter_clkgate u_inter_clkgate_timer (.clk_i         (clk_cpu),
                                                 .clk_enable_i  (timer_clock_en),
                                                 .clk_senable_i (DFTSE),
                                                 .clk_gated_o   (clk_timer));

  // ------------------------------------------------------
  // Local CNTVALUEB
  // ------------------------------------------------------
  //
  // Locally register CNTVALUEB to ease timing paths from the central copy through
  // logic in this block.  Only enable the register when the count value changes.
  assign cntvalueb_local_lo_en = cntvalueb_rs_i[ 7:0] != cntvalueb_local_rs[ 7:0];
  assign cntvalueb_local_hi_en = cntvalueb_rs_i[63:8] != cntvalueb_local_rs[63:8];

  always @(posedge CLKIN or negedge reset_n_gov)
    if (~reset_n_gov)
      cntvalueb_local_rs[7:0] <= {8{1'b0}};
    else if (cntvalueb_local_lo_en)
      cntvalueb_local_rs[7:0] <= cntvalueb_rs_i[7:0];

  always @(posedge CLKIN or negedge reset_n_gov)
    if (~reset_n_gov)
      cntvalueb_local_rs[63:8] <= {56{1'b0}};
    else if (cntvalueb_local_hi_en)
      cntvalueb_local_rs[63:8] <= cntvalueb_rs_i[63:8];

  // ------------------------------------------------------
  // Read enable generation
  // ------------------------------------------------------

  assign rd_cntfrq_el0      = valid_timer_en_i & ~cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTFRQ_EL0);
  assign rd_cntkctl_el1     = valid_timer_en_i & ~cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTKCTL_EL1);
  assign rd_cntps_tval_el1  = valid_timer_en_i & ~cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTPS_TVAL_EL1);
  assign rd_cntp_tval_el0   = valid_timer_en_i & ~cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTP_TVAL_EL0);
  assign rd_cntps_ctl_el1   = valid_timer_en_i & ~cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTPS_CTL_EL1);
  assign rd_cntp_ctl_el0    = valid_timer_en_i & ~cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTP_CTL_EL0);
  assign rd_cntv_tval_el0   = valid_timer_en_i & ~cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTV_TVAL_EL0);
  assign rd_cntv_ctl_el0    = valid_timer_en_i & ~cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTV_CTL_EL0);
  assign rd_cnthctl_el2     = valid_timer_en_i & ~cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTHCTL_EL2);
  assign rd_cnthp_tval_el2  = valid_timer_en_i & ~cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTHP_TVAL_EL2);
  assign rd_cnthp_ctl_el2   = valid_timer_en_i & ~cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTHP_CTL_EL2);
  assign rd_cntpct_el0      = valid_timer_en_i & ~cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTPCT_EL0);
  assign rd_cntvct_el0      = valid_timer_en_i & ~cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTVCT_EL0);
  assign rd_cntvoff_el2     = valid_timer_en_i & ~cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTVOFF_EL2);
  assign rd_cntps_cval_el1  = valid_timer_en_i & ~cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTPS_CVAL_EL1);
  assign rd_cntp_cval_el0   = valid_timer_en_i & ~cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTP_CVAL_EL0);
  assign rd_cntv_cval_el0   = valid_timer_en_i & ~cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTV_CVAL_EL0);
  assign rd_cnthp_cval_el2  = valid_timer_en_i & ~cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTHP_CVAL_EL2);

  // ------------------------------------------------------
  // Write enable generation
  // ------------------------------------------------------

  assign wr_cntfrq_el0      = valid_timer_en_i &  cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTFRQ_EL0);
  assign wr_cntkctl_el1     = valid_timer_en_i &  cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTKCTL_EL1);
  assign wr_cntps_tval_el1  = valid_timer_en_i &  cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTPS_TVAL_EL1);
  assign wr_cntp_tval_el0   = valid_timer_en_i &  cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTP_TVAL_EL0);
  assign wr_cntps_ctl_el1   = valid_timer_en_i &  cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTPS_CTL_EL1);
  assign wr_cntp_ctl_el0    = valid_timer_en_i &  cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTP_CTL_EL0);
  assign wr_cntv_tval_el0   = valid_timer_en_i &  cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTV_TVAL_EL0);
  assign wr_cntv_ctl_el0    = valid_timer_en_i &  cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTV_CTL_EL0);
  assign wr_cnthp_tval_el2  = valid_timer_en_i &  cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTHP_TVAL_EL2);
  assign wr_cnthctl_el2     = valid_timer_en_i &  cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTHCTL_EL2);
  assign wr_cnthp_ctl_el2   = valid_timer_en_i &  cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTHP_CTL_EL2);
  assign wr_cntvoff_el2     = valid_timer_en_i &  cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTVOFF_EL2);
  assign wr_cntps_cval_el1  = valid_timer_en_i &  cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTPS_CVAL_EL1);
  assign wr_cntp_cval_el0   = valid_timer_en_i &  cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTP_CVAL_EL0);
  assign wr_cntv_cval_el0   = valid_timer_en_i &  cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTV_CVAL_EL0);
  assign wr_cnthp_cval_el2  = valid_timer_en_i &  cp_gov_wenable_rs_i & (cp_gov_addr_rs_i == `CA53_CPOP_CNTHP_CVAL_EL2);

  // ------------------------------------------------------
  // General Timer registers
  // ------------------------------------------------------

  // ------------------------------------------------------
  // Timer Clock Frequency Register CNTFRQ
  // ------------------------------------------------------

  always @(posedge clk_timer or negedge reset_n_gov)
    if (~reset_n_gov)
       cp_cntfrq <= {32{1'b0}};
    else if (wr_cntfrq_el0)
      cp_cntfrq <= cp_gov_wdata_rs_i[31:0];

  assign cp_cntfrq_rd = {32{rd_cntfrq_el0}} & cp_cntfrq;

  // ------------------------------------------------------
  // Timer Kernel Control Register CNTKCTL
  // ------------------------------------------------------

  always @(posedge clk_timer or negedge reset_n_gov)
    if (~reset_n_gov) begin
      cntp_usr_access <= 1'b0;
      cntv_usr_access <= 1'b0;
      cntkctl_evnti   <= {4{1'b0}};
      cntkctl_evntdir <= 1'b0;
      cntkctl_evnten  <= 1'b0;
      vcnt_usr_access <= 1'b0;
      pcnt_usr_access <= 1'b0;
    end
    else if (wr_cntkctl_el1) begin
      cntp_usr_access <= cp_gov_wdata_rs_i[9];
      cntv_usr_access <= cp_gov_wdata_rs_i[8];
      cntkctl_evnti   <= cp_gov_wdata_rs_i[7:4];
      cntkctl_evntdir <= cp_gov_wdata_rs_i[3];
      cntkctl_evnten  <= cp_gov_wdata_rs_i[2];
      vcnt_usr_access <= cp_gov_wdata_rs_i[1];
      pcnt_usr_access <= cp_gov_wdata_rs_i[0];
    end

  assign cp_cntkctl_rd = ({32{rd_cntkctl_el1}} &
                          {{22{1'b0}},        // [31:10]
                          cntp_usr_access,    // [9]
                          cntv_usr_access,    // [8]
                          cntkctl_evnti,      // [ 7: 4]
                          cntkctl_evntdir,    // [3]
                          cntkctl_evnten,     // [2]
                          vcnt_usr_access,    // [1]
                          pcnt_usr_access});  // [0]

  // ------------------------------------------------------
  // Timer Physical Timer Value Register CNTP_TVAL
  // ------------------------------------------------------

  // Secure CNTP_TVAL
  assign cp_cntp_tval    = cp_cntp_cval[31:0] - cntvalueb_local_rs[31:0];
  assign cp_cntp_tval_rd = {32{rd_cntps_tval_el1}} & cp_cntp_tval;

  // Non-secure CNTP_TVAL
  assign cp_cntp_tval_ns    = cp_cntp_cval_ns[31:0] - cntvalueb_local_rs[31:0];
  assign cp_cntp_tval_ns_rd = {32{rd_cntp_tval_el0}} & cp_cntp_tval_ns;

  // ------------------------------------------------------
  // Timer Physical Control Register CNTP_CTL
  // ------------------------------------------------------

  // Secure CNTP_CTL
  always @(posedge clk_timer or negedge reset_n_gov)
    if (~reset_n_gov)
       cntp_ctl_timer_en <= 1'b0;
    else if (wr_cntps_ctl_el1)
       cntp_ctl_timer_en <= cp_gov_wdata_rs_i[0];

  always @(posedge clk_timer)
    if (wr_cntps_ctl_el1)
       cntp_ctl_mask_intrpt <= cp_gov_wdata_rs_i[1];

  assign cntp_ctl_int_ro = cntpsirq;

  assign cp_cntp_ctl_rd = ({32{rd_cntps_ctl_el1}} &
                           {{29{1'b0}},
                            cntp_ctl_int_ro,
                            cntp_ctl_mask_intrpt,
                            cntp_ctl_timer_en});

  // Non-secure CNTP_CTL
  always @(posedge clk_timer or negedge reset_n_gov)
    if (~reset_n_gov)
      cntp_ctl_timer_en_ns <= 1'b0;
    else if (wr_cntp_ctl_el0)
      cntp_ctl_timer_en_ns <= cp_gov_wdata_rs_i[0];

  always @(posedge clk_timer)
    if (wr_cntp_ctl_el0)
       cntp_ctl_mask_intrpt_ns <= cp_gov_wdata_rs_i[1];

  assign cntp_ctl_int_ro_ns = cntpnsirq;

  assign cp_cntp_ctl_ns_rd = ({32{rd_cntp_ctl_el0}} &
                              {{29{1'b0}},
                               cntp_ctl_int_ro_ns,
                               cntp_ctl_mask_intrpt_ns,
                               cntp_ctl_timer_en_ns});

  // ------------------------------------------------------
  // Timer Virtual Timer Value Register CNTV_TVAL
  // ------------------------------------------------------

  assign cp_cntv_tval    = cp_cntv_cval[31:0] - cp_cntvct[31:0];
  assign cp_cntv_tval_rd = {32{rd_cntv_tval_el0}} & cp_cntv_tval;

  // ------------------------------------------------------
  // Timer Virtual Control Register CNTV_CTL
  // ------------------------------------------------------

  always @(posedge clk_timer or negedge reset_n_gov)
    if (~reset_n_gov)
      cntv_ctl_timer_en <= 1'b0;
    else if (wr_cntv_ctl_el0)
      cntv_ctl_timer_en <= cp_gov_wdata_rs_i[0];

  always @(posedge clk_timer)
    if (wr_cntv_ctl_el0)
       cntv_ctl_mask_intrpt <= cp_gov_wdata_rs_i[1];

  assign cntv_ctl_int_ro = cntvirq;

  assign cp_cntv_ctl_rd = ({32{rd_cntv_ctl_el0}} &
                           {{29{1'b0}},
                            cntv_ctl_int_ro,
                            cntv_ctl_mask_intrpt,
                            cntv_ctl_timer_en});

  // ------------------------------------------------------
  // Timer Hyp Control Register CNTHCTL
  // ------------------------------------------------------

  always @(posedge clk_timer or negedge reset_n_gov)
    if (~reset_n_gov) begin
      cnthctl_evnti      <= {4{1'b0}};
      cnthctl_evntdir    <= 1'b0;
      cnthctl_evnten     <= 1'b0;
      cntp_kernel_access <= 1'b1;
      pcnt_kernel_access <= 1'b1;
    end
    else if (wr_cnthctl_el2) begin
      cnthctl_evnti      <= cp_gov_wdata_rs_i[7:4];
      cnthctl_evntdir    <= cp_gov_wdata_rs_i[3];
      cnthctl_evnten     <= cp_gov_wdata_rs_i[2];
      cntp_kernel_access <= cp_gov_wdata_rs_i[1];
      pcnt_kernel_access <= cp_gov_wdata_rs_i[0];
    end

  assign cp_cnthctl_rd = ({32{rd_cnthctl_el2}} &
                          {{24{1'b0}},          // [31:8]
                          cnthctl_evnti,        // [ 7:4]
                          cnthctl_evntdir,      // [3]
                          cnthctl_evnten,       // [2]
                          cntp_kernel_access,   // [1]
                          pcnt_kernel_access}); // [0]

  // ------------------------------------------------------
  // Timer Hyp Timer Value Register CNTHP_TVAL
  // ------------------------------------------------------

  assign cp_cnthp_tval    =  cp_cnthp_cval[31:0] - cntvalueb_local_rs[31:0];
  assign cp_cnthp_tval_rd = {32{rd_cnthp_tval_el2}} & cp_cnthp_tval;

  // ------------------------------------------------------
  // Timer Hyp Control Register CNTHP_CTL
  // ------------------------------------------------------

  always @(posedge clk_timer or negedge reset_n_gov)
    if (~reset_n_gov)
       cnthp_ctl_timer_en <= 1'b0;
    else if (wr_cnthp_ctl_el2)
       cnthp_ctl_timer_en <= cp_gov_wdata_rs_i[0];

  always @(posedge clk_timer)
    if (wr_cnthp_ctl_el2)
       cnthp_ctl_mask_intrpt <= cp_gov_wdata_rs_i[1];

  assign cnthp_ctl_int_ro = cnthpirq;

  assign cp_cnthp_ctl_rd = ({32{rd_cnthp_ctl_el2}} &
                            {{29{1'b0}},
                             cnthp_ctl_int_ro,
                             cnthp_ctl_mask_intrpt,
                             cnthp_ctl_timer_en});

  // ------------------------------------------------------
  // Timer Virtual Offset Register CNTVOFF
  // ------------------------------------------------------

  always @(posedge clk_timer)
    if (wr_cntvoff_el2)
      cp_cntvoff <= cp_gov_wdata_rs_i[63:0];

  assign cp_cntvoff_rd = {64{rd_cntvoff_el2}} & cp_cntvoff;

  // ------------------------------------------------------
  // Timer Physical Count Register CNTPCT
  // ------------------------------------------------------

  assign cp_cntpct    = cntvalueb_local_rs;
  assign cp_cntpct_rd = {64{rd_cntpct_el0}} & cp_cntpct;

  // ------------------------------------------------------
  // Timer Virtual Count Register CNTVCT
  // ------------------------------------------------------

  assign cp_cntvct    = cntvalueb_local_rs - cp_cntvoff;
  assign cp_cntvct_rd = {64{rd_cntvct_el0}} & cp_cntvct;

  // ------------------------------------------------------
  // Timer Physical Compare Value Register CNTP_CVAL
  // ------------------------------------------------------

  assign ptval_wr_en   = wr_cntps_tval_el1 | wr_cntp_tval_el0 | wr_cnthp_tval_el2;
  assign pcmp_value    = cntvalueb_local_rs + {{32{cp_gov_wdata_rs_i[31]}}, cp_gov_wdata_rs_i[31:0]};

  assign nxt_cp_cval   = ptval_wr_en ? pcmp_value : cp_gov_wdata_rs_i[63:0];

  // Secure CNTP_CVAL
  assign cp_cntp_cval_en = wr_cntps_cval_el1 | wr_cntps_tval_el1;

  always @(posedge clk_timer)
    if (cp_cntp_cval_en)
       cp_cntp_cval <= nxt_cp_cval;

  assign cp_cntp_cval_rd = {64{rd_cntps_cval_el1}} & cp_cntp_cval;

  // Non-secure CNTP_CVAL
  assign cp_cntp_cval_ns_en = wr_cntp_cval_el0 | wr_cntp_tval_el0;

  always @(posedge clk_timer)
    if (cp_cntp_cval_ns_en)
       cp_cntp_cval_ns <= nxt_cp_cval;

  assign cp_cntp_cval_ns_rd = {64{rd_cntp_cval_el0}} & cp_cntp_cval_ns;

  // ------------------------------------------------------
  // Timer Virtual Compare Value Register CNTV_CVAL
  // ------------------------------------------------------

  assign vcmp_value       = cp_cntvct + {{32{cp_gov_wdata_rs_i[31]}}, cp_gov_wdata_rs_i[31:0]};
  assign nxt_cp_cntv_cval = wr_cntv_tval_el0 ? vcmp_value : cp_gov_wdata_rs_i[63:0];

  assign cp_cntv_cval_en = wr_cntv_cval_el0 | wr_cntv_tval_el0;

  always @(posedge clk_timer)
    if (cp_cntv_cval_en)
       cp_cntv_cval <= nxt_cp_cntv_cval;

  assign cp_cntv_cval_rd = {64{rd_cntv_cval_el0}} & cp_cntv_cval;

  // ------------------------------------------------------
  // Timer Hyp Compare Value Register CNTHP_CVAL
  // ------------------------------------------------------

  assign cp_cnthp_cval_en = wr_cnthp_cval_el2 | wr_cnthp_tval_el2;

  always @(posedge clk_timer)
    if (cp_cnthp_cval_en)
       cp_cnthp_cval <= nxt_cp_cval;

  assign cp_cnthp_cval_rd = {64{rd_cnthp_cval_el2}} & cp_cnthp_cval;

  // ------------------------------------------------------
  // Generic Timer Functionality
  // ------------------------------------------------------

  // Event Stream generated by the transition of any specified one
  // of the lowest 16 bits of the Physical or Virtual Count;
  assign nxt_pcnt_sample_bit = cp_cntpct[cnthctl_evnti] ^ cnthctl_evntdir;
  assign nxt_vcnt_sample_bit = cp_cntvct[cntkctl_evnti] ^ cntkctl_evntdir;

  // Timer interrupts
  assign cmp_cntv_cval = cp_cntvct - cp_cntv_cval;

  assign cntpsirq_triggered  = cp_cntpct >= cp_cntp_cval;
  assign cntpnsirq_triggered = cp_cntpct >= cp_cntp_cval_ns;
  assign cnthpirq_triggered  = cp_cntpct >= cp_cnthp_cval;
  assign cntvirq_triggered   = (~cp_cntv_cval[63] & ~cmp_cntv_cval[63]) |
                               (cp_cntvct[63]     & ~cmp_cntv_cval[63]) |
                               (cp_cntvct[63]     & ~cp_cntv_cval[63]);

  // Secure Physical Timer event
  assign cntpsirq     = cntpsirq_triggered & cntp_ctl_timer_en;
  assign msk_cntpsirq = cntpsirq & ~cntp_ctl_mask_intrpt;

  // Non-Secure Physical Timer event
  assign cntpnsirq     = cntpnsirq_triggered & cntp_ctl_timer_en_ns;
  assign msk_cntpnsirq = cntpnsirq & ~cntp_ctl_mask_intrpt_ns;

  // Hypervisor Physical Timer event
  assign cnthpirq     = cnthpirq_triggered & cnthp_ctl_timer_en;
  assign msk_cnthpirq = cnthpirq & ~cnthp_ctl_mask_intrpt;

  // Virtual Physical Timer event
  assign cntvirq     = cntvirq_triggered & cntv_ctl_timer_en;
  assign msk_cntvirq = cntvirq & ~cntv_ctl_mask_intrpt;

  // ------------------------------------------------------
  // Final read mux
  // ------------------------------------------------------
  // For synthesis timing purposes, this read mux is realised as OR gate.
  // The output from each register is sampled through an AND gate and only one
  // register is enabled at any time.  When the register is selected, the
  // outputs of the register are sent to the final OR gate.  This means that
  // the default behaviour of the logic is to drive zeros when not selected.

  assign timer_cp_rdata_o = ({{32{1'b0}},(cp_cntfrq_rd       |
                                          cp_cntkctl_rd      |
                                          cp_cntp_tval_rd    |
                                          cp_cntp_tval_ns_rd |
                                          cp_cntp_ctl_rd     |
                                          cp_cntp_ctl_ns_rd  |
                                          cp_cntv_tval_rd    |
                                          cp_cntv_ctl_rd     |
                                          cp_cnthctl_rd      |
                                          cp_cnthp_tval_rd   |
                                          cp_cnthp_ctl_rd)}) |
                                         (cp_cntpct_rd       | //64-bit registers
                                          cp_cntvct_rd       |
                                          cp_cntvoff_rd      |
                                          cp_cntp_cval_rd    |
                                          cp_cntp_cval_ns_rd |
                                          cp_cntv_cval_rd    |
                                          cp_cnthp_cval_rd);

  // ------------------------------------------------------
  // Register counter based interrupts
  // ------------------------------------------------------

  // Timer triggered interrupts
  //
  // This must use the free running clock to generate interrupts while in WFx
  always @(posedge CLKIN or negedge reset_n_gov)
    if (~reset_n_gov) begin
      msk_cntpsirq_rs  <= 1'b0;
      msk_cntpnsirq_rs <= 1'b0;
      msk_cnthpirq_rs  <= 1'b0;
      msk_cntvirq_rs   <= 1'b0;
    end
    else begin
      msk_cntpsirq_rs  <= msk_cntpsirq;
      msk_cntpnsirq_rs <= msk_cntpnsirq;
      msk_cnthpirq_rs  <= msk_cnthpirq;
      msk_cntvirq_rs   <= msk_cntvirq;
    end

  // ------------------------------------------------------
  // Timer based WFE event generation
  // ------------------------------------------------------

  // Event Stream generated by the transition of any specified one
  // of the lowest 16 bits of the Physical or Virtual Count.
  //
  // This must use the free running clock to wake the CPU from WFE
  always @(posedge CLKIN) begin
    pcnt_sample_bit <= nxt_pcnt_sample_bit;
    vcnt_sample_bit <= nxt_vcnt_sample_bit;
    timer_wfe_event <= nxt_timer_wfe_event;
  end

  assign wfe_pevnt = nxt_pcnt_sample_bit & ~pcnt_sample_bit;
  assign wfe_vevnt = nxt_vcnt_sample_bit & ~vcnt_sample_bit;

  assign nxt_timer_wfe_event = (cnthctl_evnten & wfe_pevnt) | (cntkctl_evnten & wfe_vevnt);

  //-------------------------------------------------------
  // Output assignments
  //-------------------------------------------------------

  assign gov_pcnt_kernel_access_o = pcnt_kernel_access;
  assign gov_pcnt_usr_access_o    = pcnt_usr_access;
  assign gov_vcnt_usr_access_o    = vcnt_usr_access;
  assign gov_cntp_usr_access_o    = cntp_usr_access;
  assign gov_cntv_usr_access_o    = cntv_usr_access;
  assign gov_cntp_kernel_access_o = cntp_kernel_access;
  assign ncntpsirq_o              = ~msk_cntpsirq_rs;
  assign ncntpnsirq_o             = ~msk_cntpnsirq_rs;
  assign ncnthpirq_o              = ~msk_cnthpirq_rs;
  assign ncntvirq_o               = ~msk_cntvirq_rs;
  assign timer_wfe_event_o        = timer_wfe_event;

//------------------------------------------------------------------------------
// OVL Assertions
//------------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cntvalueb_local_hi_en")
  u_ovl_x_cntvalueb_local_hi_en (.clk       (CLKIN),
                                 .reset_n   (reset_n_gov),
                                 .qualifier (1'b1),
                                 .test_expr (cntvalueb_local_hi_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cntvalueb_local_lo_en")
  u_ovl_x_cntvalueb_local_lo_en (.clk       (CLKIN),
                                 .reset_n   (reset_n_gov),
                                 .qualifier (1'b1),
                                 .test_expr (cntvalueb_local_lo_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_cnthp_cval_en")
  u_ovl_x_cp_cnthp_cval_en (.clk       (clk_timer),
                            .reset_n   (reset_n_gov),
                            .qualifier (1'b1),
                            .test_expr (cp_cnthp_cval_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_cntp_cval_en")
  u_ovl_x_cp_cntp_cval_en (.clk       (clk_timer),
                           .reset_n   (reset_n_gov),
                           .qualifier (1'b1),
                           .test_expr (cp_cntp_cval_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_cntp_cval_ns_en")
  u_ovl_x_cp_cntp_cval_ns_en (.clk       (clk_timer),
                              .reset_n   (reset_n_gov),
                              .qualifier (1'b1),
                              .test_expr (cp_cntp_cval_ns_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_cntv_cval_en")
  u_ovl_x_cp_cntv_cval_en (.clk       (clk_timer),
                           .reset_n   (reset_n_gov),
                           .qualifier (1'b1),
                           .test_expr (cp_cntv_cval_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cntfrq_el0")
  u_ovl_x_wr_cntfrq_el0 (.clk       (clk_timer),
                         .reset_n   (reset_n_gov),
                         .qualifier (1'b1),
                         .test_expr (wr_cntfrq_el0));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cnthctl_el2")
  u_ovl_x_wr_cnthctl_el2 (.clk       (clk_timer),
                          .reset_n   (reset_n_gov),
                          .qualifier (1'b1),
                          .test_expr (wr_cnthctl_el2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cnthp_ctl_el2")
  u_ovl_x_wr_cnthp_ctl_el2 (.clk       (clk_timer),
                            .reset_n   (reset_n_gov),
                            .qualifier (1'b1),
                            .test_expr (wr_cnthp_ctl_el2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cntkctl_el1")
  u_ovl_x_wr_cntkctl_el1 (.clk       (clk_timer),
                          .reset_n   (reset_n_gov),
                          .qualifier (1'b1),
                          .test_expr (wr_cntkctl_el1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cntp_ctl_el0")
  u_ovl_x_wr_cntp_ctl_el0 (.clk       (clk_timer),
                           .reset_n   (reset_n_gov),
                           .qualifier (1'b1),
                           .test_expr (wr_cntp_ctl_el0));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cntps_ctl_el1")
  u_ovl_x_wr_cntps_ctl_el1 (.clk       (clk_timer),
                            .reset_n   (reset_n_gov),
                            .qualifier (1'b1),
                            .test_expr (wr_cntps_ctl_el1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cntv_ctl_el0")
  u_ovl_x_wr_cntv_ctl_el0 (.clk       (clk_timer),
                           .reset_n   (reset_n_gov),
                           .qualifier (1'b1),
                           .test_expr (wr_cntv_ctl_el0));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cntvoff_el2")
  u_ovl_x_wr_cntvoff_el2 (.clk       (clk_timer),
                          .reset_n   (reset_n_gov),
                          .qualifier (1'b1),
                          .test_expr (wr_cntvoff_el2));

`endif

endmodule // ca53governor_cpu_timers

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/

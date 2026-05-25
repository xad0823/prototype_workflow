//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2015 ARM Limited.
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
// Description:
// SCU reset synchroniser and clock gating block
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "cortexa53params.v"

module ca53scu_clk #(`CA53_SCU_INT_PARAM_DECL) (
  // Inputs
  input  wire                     CLKIN,
  input  wire                     DFTSE,
  input  wire                     DFTRSTDISABLE,
  input  wire                     nl2reset_i,
  input  wire                     nmbistreset_i,
  input  wire [3:0]               tagctl_wfx_ready_i,
  input  wire                     cpuslv0_wfx_active_i,
  input  wire                     cpuslv1_wfx_active_i,
  input  wire                     cpuslv2_wfx_active_i,
  input  wire                     cpuslv3_wfx_active_i,
  input  wire                     cpuslv0_active_i,
  input  wire                     cpuslv1_active_i,
  input  wire                     cpuslv2_active_i,
  input  wire                     cpuslv3_active_i,
  input  wire                     acpslv_active_i,
  input  wire                     snpslv_active_i,
  input  wire                     snpslv_retention_active_i,
  input  wire                     tagctl_active_i,
  input  wire                     ramctl_active_i,
  input  wire                     master_active_i,
  input  wire                     ramctl_awake_i,
  input  wire                     master_linkactive_i,
  input  wire                     master_cpuslv0_waddrs_valid_i,
  input  wire                     master_cpuslv1_waddrs_valid_i,
  input  wire                     master_cpuslv2_waddrs_valid_i,
  input  wire                     master_cpuslv3_waddrs_valid_i,
  input  wire                     cpuslv0_l2flush_active_i,
  input  wire                     scu_ext_aclken_i,
  input  wire                     ext_acp_aclken_i,
  input  wire                     ext_sclken_i,
  input  wire                     scu_ext_ac_valid_i,
  input  wire                     scu_ext_ac_ready_i,
  input  wire                     acinactm_i,
  input  wire                     ext_sinact_i,
  input  wire                     ext_rxsactive_i,
  input  wire                     scu_acp_arready_i,
  input  wire                     scu_acp_awready_i,
  input  wire                     scu_acp_wready_i,
  input  wire                     ext_acp_ainact_i,
  input  wire                     gov_l2_in_retention_i,
  input  wire [NUM_CPUS-1:0]      gov_standbywfi_i,
  input  wire                     gov_mbistreq_i,
  input  wire                     gov_cpu0_inv_all_req_i,
  input  wire                     gov_cpu1_inv_all_req_i,
  input  wire                     gov_cpu2_inv_all_req_i,
  input  wire                     gov_cpu3_inv_all_req_i,
  input  wire                     l2flushreq_i,
  input  wire                     l2_victimram_en_i,
  input  wire                     l2_victimram_no_acc_next_cycle_i,
  input  wire                     l2_dataram_no_acc_next_cycle_i,
  input  wire                     cpuslv0_l2flushdone_i,
  // Outputs
  output wire [NUM_CPUS-1:0]      scu_wfx_ready_o,
  output wire                     standbywfil2_req_o,
  output wire                     standbywfil2_o,
  output wire                     clk,
  output wire                     clk_ext_master,
  output wire                     reset_n_o,
  output wire                     clean_aclken_o,
  output wire                     clean_aclkens_o,
  output wire                     l2flushreq_rs_o,
  output wire                     inactm_rs_o,
  output wire                     acp_ainact_rs_o,
  output wire                     ram_idle_count_max_o,
  output wire                     scu_l2_retention_ready_o,
  output wire                     l2_reached_retention_o,
  output wire                     l2flushdone_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg                 clken;
  reg                 ext_master_clken;
  reg                 standbywfil2;
  reg [NUM_CPUS-1:0]  scu_wfx_ready;
  reg                 scu_l2_retention_ready;
  reg                 l2_reaching_retention;
  reg                 l2_reached_retention;
  reg                 clean_aclken;
  reg                 clean_aclkens;
  reg                 acp_ainact_rs;
  reg                 inactm_rs;
  reg                 rxsactive_rs;
  reg [4:0]           ram_idle_count;
  reg                 scu_main_rst_ug_pipeline_stage_0;
  reg                 scu_main_rst_ug_pipeline_stage_1;
  reg                 scu_main_rst_ug_pipeline_stage_2;
  reg                 scu_main_rst_ug_pipelined;
  reg                 nmbistreset_pipeline_stage_0;
  reg                 nmbistreset_pipeline_stage_1;
  reg                 nmbistreset_pipeline_stage_2;
  reg                 nmbistreset_cmb_pipelined;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                scu_active;
  wire                next_clken;
  wire                next_ext_master_clken;
  wire                standbywfil2_req;
  wire                next_standbywfil2;
  wire [3:0]          next_scu_wfx_ready;
  wire                next_scu_l2_retention_ready;
  wire                next_l2_reaching_retention;
  wire                next_l2_reached_retention;
  wire                scu_main_rst_ug;
  wire                scu_main_rst;
  wire                nmbistreset_cmb;
  wire                next_clean_aclken;
  wire                l2flushreq_rs;
  wire                l2_ram_light_sleep_active;
  wire                next_inactm_rs;
  wire                ram_active;
  wire [4:0]          next_ram_idle_count;
  wire                ram_idle_count_en;
  wire                ram_idle_count_max;
  wire                reset_pipeline_en;

  //-----------------------------------------------------------------------------
  //  Main code
  //-----------------------------------------------------------------------------

  assign scu_active = (cpuslv0_active_i |
                       cpuslv1_active_i |
                       cpuslv2_active_i |
                       cpuslv3_active_i |
                       acpslv_active_i  |
                       snpslv_active_i  |
                       tagctl_active_i  |
                       ramctl_active_i  |
                       master_active_i  |
                       l2flushreq_rs    |
                       gov_cpu0_inv_all_req_i |
                       gov_cpu1_inv_all_req_i |
                       gov_cpu2_inv_all_req_i |
                       gov_cpu3_inv_all_req_i |
                       gov_mbistreq_i);

  // To enter L2 RAM light sleep mode the SCU needs to become active once the RAM idle count
  // has saturated.  This can not be a part of scu_active as the activity will un-necessarily
  // inhibit entry to L2 QChannel retention
  assign l2_ram_light_sleep_active = ram_idle_count_max & ~(l2_dataram_no_acc_next_cycle_i &
                                                            l2_victimram_no_acc_next_cycle_i);

  // scu_ext_ac_valid_i is a top-level input, and thus factored in as late
  // as possible
  assign next_clken = scu_active | l2_ram_light_sleep_active | snpslv_retention_active_i | ((ACE != 0) & clean_aclken & scu_ext_ac_valid_i);

  always @(posedge CLKIN or negedge scu_main_rst)
  if (~scu_main_rst) begin
    clken <= 1'b1;
  end else begin
    clken <= next_clken;
  end

  ca53_cell_clkgate u_clkgate (
    .clk_i         (CLKIN),
    .clk_enable_i  (clken),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk)
  );

  // Some registers are dealing with snoop requests or Skyros link activity
  // that is unsolicited, and so must be awake even when the rest of the SCU
  // is inactive. However they can be gated when we know there will be no
  // activity.
  generate if (ACE) begin : g_ace
    
    assign next_ext_master_clken = scu_active | ~(inactm_rs & ~scu_ext_ac_ready_i);

  end else begin : g_skyros

    always @(posedge CLKIN or negedge scu_main_rst)
    if (~scu_main_rst) begin
      rxsactive_rs <= 1'b0;
    end else if (clean_aclken) begin
      rxsactive_rs <= ext_rxsactive_i;
    end

    assign next_ext_master_clken = scu_active | rxsactive_rs | master_linkactive_i;

  end endgenerate

  always @(posedge CLKIN or negedge scu_main_rst)
  if (~scu_main_rst) begin
    ext_master_clken <= 1'b1;
  end else begin
    ext_master_clken <= next_ext_master_clken;
  end

  ca53_cell_clkgate u_ext_master_clkgate (
    .clk_i         (CLKIN),
    .clk_enable_i  (ext_master_clken),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_ext_master)
  );


  // Register the ACINACTM or SINACT input before use in STANDBYWFIL2 creation
  assign next_inactm_rs = (ACE != 0) ? acinactm_i : ext_sinact_i;

  always @(posedge CLKIN or negedge scu_main_rst)
  if (~scu_main_rst) begin
    inactm_rs <= 1'b0;
  end else if (clean_aclken) begin
    inactm_rs <= next_inactm_rs;
  end

  assign inactm_rs_o = inactm_rs;

  always @(posedge CLKIN or negedge scu_main_rst)
  if (~scu_main_rst) begin
    acp_ainact_rs <= 1'b1;
  end else if (clean_aclkens) begin
    acp_ainact_rs <= ext_acp_ainact_i;
  end

  assign next_scu_wfx_ready = (tagctl_wfx_ready_i &
                               ({4{cpuslv0_l2flush_active_i}} |
                                ~{cpuslv3_wfx_active_i | master_cpuslv3_waddrs_valid_i,
                                  cpuslv2_wfx_active_i | master_cpuslv2_waddrs_valid_i,
                                  cpuslv1_wfx_active_i | master_cpuslv1_waddrs_valid_i,
                                  cpuslv0_wfx_active_i | master_cpuslv0_waddrs_valid_i}));

  // If everything is idle, then we must deactivate the Skyros link before
  // going into WFI.
  assign standbywfil2_req = (&gov_standbywfi_i &
                             ~scu_active &
                             inactm_rs & ~scu_ext_ac_ready_i &
                             ((ACP == 0) | (acp_ainact_rs &
                                            ~scu_acp_arready_i &
                                            ~scu_acp_awready_i &
                                            ~scu_acp_wready_i)));

  assign standbywfil2_req_o = standbywfil2_req;

  assign next_standbywfil2 = (standbywfil2_req &
                              ~master_linkactive_i &
                              l2_dataram_no_acc_next_cycle_i &
                              l2_victimram_no_acc_next_cycle_i);

  assign next_scu_l2_retention_ready = ~(scu_active | ((ACE != 0) & clean_aclken & scu_ext_ac_valid_i));

  // Once we have got to a certain point in the retention entry, new requests
  // must not access the RAMs. Until that point old requests may still access
  // the RAMs and must not be prevented from doing so.
  assign next_l2_reaching_retention = scu_l2_retention_ready & gov_l2_in_retention_i & ~scu_active;

  assign next_l2_reached_retention = (((l2_reaching_retention & scu_l2_retention_ready & ~scu_active) |
                                       l2_reached_retention) & gov_l2_in_retention_i);

  // The WFI registers are reset to 1'b1 to reflect the value of the cluster
  // after it enters WFI for shut down.
  // The reached_retention register is reset to 1'b1 to support leaving reset
  // while still in retention.
  always @(posedge CLKIN or negedge scu_main_rst)
  if (~scu_main_rst) begin
    standbywfil2           <= 1'b1;
    scu_wfx_ready          <= {NUM_CPUS{1'b1}};
    scu_l2_retention_ready <= 1'b0;
    l2_reaching_retention  <= 1'b0;
    l2_reached_retention   <= 1'b1;
  end else begin
    standbywfil2           <= next_standbywfil2;
    scu_wfx_ready          <= next_scu_wfx_ready[NUM_CPUS-1:0];
    scu_l2_retention_ready <= next_scu_l2_retention_ready;
    l2_reaching_retention  <= next_l2_reaching_retention;
    l2_reached_retention   <= next_l2_reached_retention;
  end

  // Enable the reset pipeline registers on any form of reset
  assign reset_pipeline_en = ~scu_main_rst_ug_pipelined | ~nmbistreset_cmb_pipelined;

  // Main SCU reset synchroniserr, latency matched with reset pipeline in the Governor
  ca53_cell_sync u_ca53_cell_sync_scu (
    .out_o    (scu_main_rst_ug),
    .clk_i    (CLKIN),
    .inp_i    (nl2reset_i),
    .resetn_i (nl2reset_i)
  );

  always @(posedge CLKIN or negedge nl2reset_i)
  if (~nl2reset_i) begin
    scu_main_rst_ug_pipeline_stage_0 <= 1'b0;
    scu_main_rst_ug_pipeline_stage_1 <= 1'b0;
    scu_main_rst_ug_pipeline_stage_2 <= 1'b0;
    scu_main_rst_ug_pipelined        <= 1'b0;
  end else if (reset_pipeline_en) begin
    scu_main_rst_ug_pipeline_stage_0 <= scu_main_rst_ug;
    scu_main_rst_ug_pipeline_stage_1 <= scu_main_rst_ug_pipeline_stage_0;
    scu_main_rst_ug_pipeline_stage_2 <= scu_main_rst_ug_pipeline_stage_1;
    scu_main_rst_ug_pipelined        <= scu_main_rst_ug_pipeline_stage_2;
  end

  // MBIST reset synchroniser, latency matched with reset pipeline in the Governor
  ca53_cell_sync u_ca53_cell_sync_mbist_rst (
    .out_o    (nmbistreset_cmb),
    .clk_i    (CLKIN),
    .inp_i    (nmbistreset_i),
    .resetn_i (nmbistreset_i)
  );

  always @(posedge CLKIN or negedge nmbistreset_i)
  if (~nmbistreset_i) begin
    nmbistreset_pipeline_stage_0 <= 1'b0;
    nmbistreset_pipeline_stage_1 <= 1'b0;
    nmbistreset_pipeline_stage_2 <= 1'b0;
    nmbistreset_cmb_pipelined    <= 1'b0;
  end else if (reset_pipeline_en) begin
    nmbistreset_pipeline_stage_0 <= nmbistreset_cmb;
    nmbistreset_pipeline_stage_1 <= nmbistreset_pipeline_stage_0;
    nmbistreset_pipeline_stage_2 <= nmbistreset_pipeline_stage_1;
    nmbistreset_cmb_pipelined    <= nmbistreset_pipeline_stage_2;
  end

  // L2FLUSHREQ is asynchronous, mainly to assist the timing path coming in to
  // the cluster from the system.
  ca53_cell_sync u_ca53_cell_sync_l2flush (
    .out_o    (l2flushreq_rs),
    .clk_i    (CLKIN),
    .inp_i    (l2flushreq_i),
    .resetn_i (scu_main_rst)
  );

  // Gate reset terms with DFTRSTDISABLE
  assign scu_main_rst = DFTRSTDISABLE | ~(~scu_main_rst_ug_pipelined | ~nmbistreset_cmb_pipelined);

  // Register ACLKEN or SCLKEN
  assign next_clean_aclken = (ACE != 0) ? scu_ext_aclken_i : ext_sclken_i;

  always @(posedge CLKIN or negedge scu_main_rst)
  if (~scu_main_rst) begin
    clean_aclken <= 1'b0;
  end else begin
    clean_aclken <= next_clean_aclken;
  end

  always @(posedge CLKIN or negedge scu_main_rst)
  if (~scu_main_rst) begin
    clean_aclkens <= 1'b0;
  end else begin
    clean_aclkens <= ext_acp_aclken_i;
  end

  //-----------------------------------------------------------------------------
  //  RAMs light sleep counter & L2 flush pipeline
  //-----------------------------------------------------------------------------

  generate if (L2_CACHE) begin : g_l2cc

    // If the RAMs have not been accessed for a while, then indicate that they can
    // be put into a light sleep mode. This logic must be active when the rest of
    // the SCU is not, otherwise it may not trigger until the SCU becomes active
    // again.
    assign ram_active = ramctl_awake_i | l2_victimram_en_i;

    assign next_ram_idle_count = ram_active ? 5'b00000 : (ram_idle_count + 5'b00001);

    assign ram_idle_count_en = ram_active ? |ram_idle_count : ~ram_idle_count_max;

    always @(posedge CLKIN or negedge scu_main_rst)
    if (~scu_main_rst) begin
      ram_idle_count <= 5'b00000;
    end else if (ram_idle_count_en) begin
      ram_idle_count <= next_ram_idle_count;
    end

    assign ram_idle_count_max = &ram_idle_count;

    // L2 Flush Done pipeline
    reg l2flushdone;

    always @(posedge CLKIN or negedge scu_main_rst)
    if (~scu_main_rst) begin
      l2flushdone <= 1'b0;
    end else begin
      l2flushdone <= cpuslv0_l2flushdone_i;
    end

    assign l2flushdone_o = l2flushdone;

  end else begin : g_n_l2cc
    assign ram_idle_count_max = 1'b0;
    assign ram_idle_count_en = 1'b0;
    assign l2flushdone_o = 1'b0;
  end endgenerate

  //-----------------------------------------------------------------------------
  //  Assign outputs
  //-----------------------------------------------------------------------------

  assign standbywfil2_o           = standbywfil2;
  assign scu_wfx_ready_o          = scu_wfx_ready;
  assign scu_l2_retention_ready_o = scu_l2_retention_ready;
  assign l2_reached_retention_o   = l2_reached_retention;
  assign reset_n_o                = scu_main_rst;
  assign clean_aclken_o           = clean_aclken;
  assign clean_aclkens_o          = clean_aclkens;
  assign l2flushreq_rs_o          = l2flushreq_rs;
  assign acp_ainact_rs_o          = acp_ainact_rs;
  assign ram_idle_count_max_o     = ram_idle_count_max;

  //----------------------------------------------------------------------------
  // Assertions
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: clean_aclkens")
  u_ovl_x_clean_aclkens (.clk       (CLKIN),
                         .reset_n   (scu_main_rst),
                         .qualifier (1'b1),
                         .test_expr (clean_aclkens));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ram_idle_count_en")
  u_ovl_x_ram_idle_count_en (.clk       (CLKIN),
                             .reset_n   (scu_main_rst),
                             .qualifier (1'b1),
                             .test_expr (ram_idle_count_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: clean_aclken")
  u_ovl_x_clean_aclken (.clk       (CLKIN),
                        .reset_n   (scu_main_rst),
                        .qualifier (1'b1),
                        .test_expr (clean_aclken));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Clock enable unknown")
  u_ovl_clken_unknown (.clk       (CLKIN),
                       .reset_n   (scu_main_rst),
                       .qualifier (1'b1),
                       .test_expr (clken));

`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/

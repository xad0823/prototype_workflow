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



module reset_controller_f1_top #(
  parameter SOC_RST_DLY   = 3'b111,
  parameter SYNC_ENABLE   = 1,
  parameter NUM_EXT_SYS   = 2
) (

  input  wire                         s32kclk,
  input  wire                         refclk,
  input  wire                         poresetn,

  input  wire                         secenc_cae_rst_req, 
  input  wire                         soc_wdog_rst_req,
  input  wire                         secenc_wdog_rst_req,
  input  wire                         cdbgrstreq_dp,
  input  wire                         soc_rst_req,
  input  wire                         secenc_sw_rst_req,
  input  wire                         nsrst,
  input  wire                         csysrstreq_dprom,
  input  wire                         host_sys_rst_req,
  input  wire [NUM_EXT_SYS-1:0]       extsys_rst_req,

  output wire                         aontopporesetn,
  output wire                         aontopwarmresetn,
  output wire                         secporesetn,
  output wire [NUM_EXT_SYS-1:0]       extsysporesetn,

  output wire                         cdbgrstack_dp,
  output wire                         csysrstack_dprom,
  output wire [1:0]                   host_sys_rst_ack,
  output wire [(NUM_EXT_SYS*2)-1:0]   extsys_rst_ack,

  output wire                         secenccpuwait,
  output wire [NUM_EXT_SYS-1:0]       extsyscpuwait,

  output wire [4:0]                   soc_rst_syn,
  output wire [3:0]                   host_rst_syn,
  output wire [(NUM_EXT_SYS*5)-1:0]   extsys_rst_syn,
  output wire [2:0]                   se_rst_syn, 

  output wire                         aontoppo_systop_qreqn,
  input  wire                         aontoppo_systop_qacceptn,
  input  wire                         aontoppo_systop_qdeny,
  input  wire                         aontoppo_systop_qactive,

  output wire                         aontoppo_dbgtop_qreqn,
  input  wire                         aontoppo_dbgtop_qacceptn,
  input  wire                         aontoppo_dbgtop_qdeny,
  input  wire                         aontoppo_dbgtop_qactive,

  output wire                         secenc_systop_qreqn,
  input  wire                         secenc_systop_qacceptn,
  input  wire                         secenc_systop_qdeny,
  input  wire                         secenc_systop_qactive,

  output wire                         secenc_dbgtop_qreqn,
  input  wire                         secenc_dbgtop_qacceptn,
  input  wire                         secenc_dbgtop_qdeny,
  input  wire                         secenc_dbgtop_qactive,

  output wire [NUM_EXT_SYS-1:0]        extsys_systop_qreqn,
  input  wire [NUM_EXT_SYS-1:0]        extsys_systop_qacceptn,
  input  wire [NUM_EXT_SYS-1:0]        extsys_systop_qdeny,
  input  wire [NUM_EXT_SYS-1:0]        extsys_systop_qactive,

  output wire [NUM_EXT_SYS-1:0]        extsys_dbgtop_qreqn,
  input  wire [NUM_EXT_SYS-1:0]        extsys_dbgtop_qacceptn,
  input  wire [NUM_EXT_SYS-1:0]        extsys_dbgtop_qdeny,
  input  wire [NUM_EXT_SYS-1:0]        extsys_dbgtop_qactive,

  output wire [NUM_EXT_SYS-1:0]        extsys_aontop_qreqn,
  input  wire [NUM_EXT_SYS-1:0]        extsys_aontop_qacceptn,
  input  wire [NUM_EXT_SYS-1:0]        extsys_aontop_qdeny,
  input  wire [NUM_EXT_SYS-1:0]        extsys_aontop_qactive,

  output wire                          refclk_clk_qactive,

  input  wire                          dftcgen,
  input  wire [1:0]                    dftrstdisable

);


  wire                    poresetn_ss;
  wire                    secenc_cae_rst_req_ss;
  wire                    soc_wdog_rst_req_ss;
  wire                    secenc_wdog_rst_req_ss;
  wire                    cdbgrstreq_dp_ss;
  wire                    soc_rst_req_ss;
  wire                    secenc_sw_rst_req_ss;
  wire                    nsrst_ss;
  wire                    csysrstreq_dprom_ss;
  wire                    host_sys_rst_req_ss;
  wire [NUM_EXT_SYS-1:0]  extsys_rst_req_ss;


generate
if (SYNC_ENABLE == 1)
begin: request_synchronizers

  arm_element_reset_sync u_poreset_reset_sync (
    .clk           (s32kclk),
    .resetn_async  (poresetn),

    .resetn_sync   (poresetn_ss),
    .dftrstdisable (dftrstdisable[0])
  );

  arm_element_cdc_capt_sync u_cdc_capt_secenc_cae_rst_req (
    .clk (s32kclk),
    .nreset (poresetn_ss),

    .d_async (secenc_cae_rst_req),
    .q      (secenc_cae_rst_req_ss)
  );
  
  arm_element_cdc_capt_sync u_cdc_capt_soc_wdog_rst_req (
    .clk (s32kclk),
    .nreset (poresetn_ss),

    .d_async (soc_wdog_rst_req),
    .q      (soc_wdog_rst_req_ss)
  );

  arm_element_cdc_capt_sync u_cdc_capt_secenc_wdog_rst_req (
    .clk (s32kclk),
    .nreset (poresetn_ss),

    .d_async (secenc_wdog_rst_req),
    .q      (secenc_wdog_rst_req_ss)
  );

  arm_element_cdc_capt_sync u_cdc_capt_cdbgrstreq_dp (
    .clk (s32kclk),
    .nreset (poresetn_ss),

    .d_async (cdbgrstreq_dp),
    .q      (cdbgrstreq_dp_ss)
  );

  arm_element_cdc_capt_sync u_cdc_capt_soc_rst_req (
    .clk (s32kclk),
    .nreset (poresetn_ss),

    .d_async (soc_rst_req),
    .q      (soc_rst_req_ss)
  );

  arm_element_cdc_capt_sync u_cdc_capt_secenc_sw_rst_req (
    .clk (s32kclk),
    .nreset (poresetn_ss),

    .d_async (secenc_sw_rst_req),
    .q      (secenc_sw_rst_req_ss)
  );

  arm_element_cdc_capt_sync u_cdc_capt_nsrst (
    .clk (s32kclk),
    .nreset (poresetn_ss),

    .d_async (nsrst),
    .q      (nsrst_ss)
  );

  arm_element_cdc_capt_sync u_cdc_capt_csysrstreq_dprom (
    .clk (s32kclk),
    .nreset (poresetn_ss),

    .d_async (csysrstreq_dprom),
    .q      (csysrstreq_dprom_ss)
  );

  arm_element_cdc_capt_sync u_cdc_capt_host_sys_rst_req (
    .clk (s32kclk),
    .nreset (poresetn_ss),

    .d_async (host_sys_rst_req),
    .q      (host_sys_rst_req_ss)
  );

  genvar K;
  for (K=0; K<NUM_EXT_SYS; K=K+1)
  begin: GEN_EXTSYS_REQ_SYNC
  arm_element_cdc_capt_sync u_cdc_capt_extsys_rst_req (
    .clk (s32kclk),
    .nreset (poresetn_ss),

    .d_async (extsys_rst_req[K]),
    .q      (extsys_rst_req_ss[K])
  );
  end

end
endgenerate


  wire                         secenc_hostsys_qreqn;
  wire                         secenc_hostsys_qacceptn;
  wire                         secenc_hostsys_qdeny;
  wire                         secenc_hostsys_qacceptn_ss;
  wire                         secenc_hostsys_qdeny_ss;

  wire [NUM_EXT_SYS-1:0]       extsys_hostsys_qreqn;
  wire [NUM_EXT_SYS-1:0]       extsys_hostsys_qacceptn;
  wire [NUM_EXT_SYS-1:0]       extsys_hostsys_qdeny;
  wire [NUM_EXT_SYS-1:0]       extsys_hostsys_qacceptn_ss;
  wire [NUM_EXT_SYS-1:0]       extsys_hostsys_qdeny_ss;

  wire                         aontoppo_aontopwarm_qreqn;
  wire                         aontoppo_aontopwarm_qacceptn;
  wire                         aontoppo_aontopwarm_qdeny;
  wire                         aontoppo_aontopwarm_qacceptn_ss;
  wire                         aontoppo_aontopwarm_qdeny_ss;

  wire                         poresetn_int;
  wire                         secenc_cae_rst_req_int;
  wire                         soc_wdog_rst_req_int;
  wire                         secenc_wdog_rst_req_int;
  wire                         cdbgrstreq_dp_int;
  wire                         soc_rst_req_int;
  wire                         secenc_sw_rst_req_int;
  wire                         nsrst_int;
  wire                         csysrstreq_dprom_int;
  wire                         host_sys_rst_req_int;
  wire [NUM_EXT_SYS-1:0]       extsys_rst_req_int;

generate
if (SYNC_ENABLE == 1)
begin:requests_sync
assign poresetn_int            = poresetn_ss;
assign secenc_cae_rst_req_int  = secenc_cae_rst_req_ss;
assign soc_wdog_rst_req_int    = soc_wdog_rst_req_ss;
assign secenc_wdog_rst_req_int = secenc_wdog_rst_req_ss;
assign cdbgrstreq_dp_int       = cdbgrstreq_dp_ss;
assign soc_rst_req_int         = soc_rst_req_ss;
assign secenc_sw_rst_req_int   = secenc_sw_rst_req_ss;
assign nsrst_int               = nsrst_ss;
assign csysrstreq_dprom_int    = csysrstreq_dprom_ss;
assign host_sys_rst_req_int    = host_sys_rst_req_ss;
assign extsys_rst_req_int      = extsys_rst_req_ss;
end
else if (SYNC_ENABLE == 0)
begin:requests_no_sync
assign poresetn_int            = poresetn;
assign secenc_cae_rst_req_int  = secenc_cae_rst_req;
assign soc_wdog_rst_req_int    = soc_wdog_rst_req;
assign secenc_wdog_rst_req_int = secenc_wdog_rst_req;
assign cdbgrstreq_dp_int       = cdbgrstreq_dp;
assign soc_rst_req_int         = soc_rst_req;
assign secenc_sw_rst_req_int   = secenc_sw_rst_req;
assign nsrst_int               = nsrst;
assign csysrstreq_dprom_int    = csysrstreq_dprom;
assign host_sys_rst_req_int    = host_sys_rst_req;
assign extsys_rst_req_int      = extsys_rst_req;
end
endgenerate


wire                         aontopporesetn_int;
wire                         aontopwarmresetn_int;
wire                         secporesetn_int;
wire [NUM_EXT_SYS-1:0]       extsysporesetn_int;

wire                         cdbgrstack_dp_int;
wire                         csysrstack_dprom_int;
wire [1:0]                   host_sys_rst_ack_int;
wire [(NUM_EXT_SYS*2)-1:0]   extsys_rst_ack_int;

wire                         secenccpuwait_int;
wire [NUM_EXT_SYS-1:0]       extsyscpuwait_int;

wire [4:0]                   soc_rst_syn_int;
wire [3:0]                   host_rst_syn_int;
wire [(NUM_EXT_SYS*5)-1:0]   extsys_rst_syn_int;
wire [2:0]                   se_rst_syn_int;

wire                         secenc_hostsys_lpd_qactive;
wire                         aontoppo_aontopwarm_lpd_qactive;
wire [NUM_EXT_SYS-1:0]       extsys_hostsys_lpd_qactive;
wire [NUM_EXT_SYS-1:0]       extsys_aontop_lpc_qactive;

wire aontopwarmresetn_refclk;


reset_controller_f1_core #(
  .SOC_RST_DLY (SOC_RST_DLY),
  .NUM_EXT_SYS (NUM_EXT_SYS)
) u_reset_controller_core (

  .clk                                 (s32kclk),
  .resetn                              (poresetn_int),

  .secenc_cae_rst_req                  (secenc_cae_rst_req_int),
  .soc_wdog_rst_req                    (soc_wdog_rst_req_int),
  .secenc_wdog_rst_req                 (secenc_wdog_rst_req_int),
  .cdbgrstreq_dp                       (cdbgrstreq_dp_int),
  .soc_rst_req                         (soc_rst_req_int),
  .secenc_sw_rst_req                   (secenc_sw_rst_req_int),
  .nsrst                               (nsrst_int),
  .csysrstreq_dprom                    (csysrstreq_dprom_int),
  .host_sys_rst_req                    (host_sys_rst_req_int),
  .extsys_rst_req                      (extsys_rst_req_int),

  .aontopporesetn                      (aontopporesetn_int),
  .aontopwarmresetn                    (aontopwarmresetn_int),
  .secporesetn                         (secporesetn_int),
  .extsysporesetn                      (extsysporesetn_int),

  .cdbgrstack_dp                       (cdbgrstack_dp_int),
  .csysrstack_dprom                    (csysrstack_dprom_int),
  .host_sys_rst_ack                    (host_sys_rst_ack_int),
  .extsys_rst_ack                      (extsys_rst_ack_int),

  .secenccpuwait                       (secenccpuwait_int),
  .extsyscpuwait                       (extsyscpuwait_int),

  .soc_rst_syn                         (soc_rst_syn_int),
  .host_rst_syn                        (host_rst_syn_int),
  .extsys_rst_syn                      (extsys_rst_syn_int),
  .se_rst_syn                          (se_rst_syn_int),

  .aontoppo_aontopwarm_qreqn           (aontoppo_aontopwarm_qreqn),
  .aontoppo_aontopwarm_qacceptn        (aontoppo_aontopwarm_qacceptn_ss),
  .aontoppo_aontopwarm_qdeny           (aontoppo_aontopwarm_qdeny_ss),

  .secenc_hostsys_qreqn                (secenc_hostsys_qreqn),
  .secenc_hostsys_qacceptn             (secenc_hostsys_qacceptn_ss),
  .secenc_hostsys_qdeny                (secenc_hostsys_qdeny_ss),
 
  .extsys_hostsys_qreqn                (extsys_hostsys_qreqn),
  .extsys_hostsys_qacceptn             (extsys_hostsys_qacceptn_ss),
  .extsys_hostsys_qdeny                (extsys_hostsys_qdeny_ss)
);


generate
if (SYNC_ENABLE == 1)
begin: q_ch_synchronizers

  arm_element_cdc_capt_sync u_aontoppo_aontopwarm_qacceptn_sync (
    .clk (s32kclk),
    .nreset (poresetn_ss),

    .d_async (aontoppo_aontopwarm_qacceptn),
    .q       (aontoppo_aontopwarm_qacceptn_ss)
  );

  arm_element_cdc_capt_sync u_aontoppo_aontopwarm_qdeny_sync (
    .clk (s32kclk),
    .nreset (poresetn_ss),

    .d_async (aontoppo_aontopwarm_qdeny),
    .q       (aontoppo_aontopwarm_qdeny_ss)
  );

  arm_element_cdc_capt_sync u_secenc_hostsys_qacceptn_sync (
    .clk (s32kclk),
    .nreset (poresetn_ss),

    .d_async (secenc_hostsys_qacceptn),
    .q       (secenc_hostsys_qacceptn_ss)
  );

  arm_element_cdc_capt_sync u_secenc_hostsys_qdeny_sync (
    .clk (s32kclk),
    .nreset (poresetn_ss),

    .d_async (secenc_hostsys_qdeny),
    .q       (secenc_hostsys_qdeny_ss)
  );

  genvar N;
  for (N=0; N<NUM_EXT_SYS; N=N+1)
  begin: GEN_EXTSYS_QCH_SYNC
  arm_element_cdc_capt_sync u_extsys_hostsys_qacceptn_sync (
    .clk (s32kclk),
    .nreset (poresetn_ss),

    .d_async (extsys_hostsys_qacceptn[N]),
    .q       (extsys_hostsys_qacceptn_ss[N])
  );

  arm_element_cdc_capt_sync u_extsys_hostsys_qdeny_sync (
    .clk (s32kclk),
    .nreset (poresetn_ss),

    .d_async (extsys_hostsys_qdeny[N]),
    .q       (extsys_hostsys_qdeny_ss[N])
  );
  end

end
endgenerate




pck600_lpd_q #(
  .SEQUENCER      (0),
  .NUM_QCHL       (2),
  .CTRL_Q_CH_SYNC (SYNC_ENABLE),
  .DEV_Q_CH_SYNC  (SYNC_ENABLE),
  .ACTIVE_DENY    (0)
) u_secenc_hostsys_lpd_q (

  .clk (refclk),
  .reset_n (aontopwarmresetn_refclk),

  .dftcgen (dftcgen),

  .ctrl_qreqn_i (secenc_hostsys_qreqn),
  .ctrl_qacceptn_o (secenc_hostsys_qacceptn),
  .ctrl_qdeny_o (secenc_hostsys_qdeny),
  .ctrl_qactive_o ( ),

  .dev_qreqn_o ({secenc_dbgtop_qreqn, secenc_systop_qreqn}),
  .dev_qacceptn_i ({secenc_dbgtop_qacceptn, secenc_systop_qacceptn}),
  .dev_qdeny_i ({secenc_dbgtop_qdeny, secenc_systop_qdeny}),
  .dev_qactive_i ({secenc_dbgtop_qactive, secenc_systop_qactive}),

  .clk_qactive_o (secenc_hostsys_lpd_qactive)
);


wire [NUM_EXT_SYS-1:0]   aontoppo_extsys_qreqn;
wire [NUM_EXT_SYS-1:0]   aontoppo_extsys_qacceptn;
wire [NUM_EXT_SYS-1:0]   aontoppo_extsys_qdeny;
wire [NUM_EXT_SYS-1:0]   aontoppo_extsys_qactive;

pck600_lpd_q #(
  .SEQUENCER      (0),
  .NUM_QCHL       (2+NUM_EXT_SYS),
  .CTRL_Q_CH_SYNC (SYNC_ENABLE),
  .DEV_Q_CH_SYNC  (SYNC_ENABLE),
  .ACTIVE_DENY    (0)
) u_aontoppo_aontopwarm_lpd_q (

  .clk (refclk),
  .reset_n (aontopwarmresetn_refclk),

  .dftcgen (dftcgen),

  .ctrl_qreqn_i (aontoppo_aontopwarm_qreqn),
  .ctrl_qacceptn_o (aontoppo_aontopwarm_qacceptn),
  .ctrl_qdeny_o (aontoppo_aontopwarm_qdeny),
  .ctrl_qactive_o ( ),

  .dev_qreqn_o ({aontoppo_systop_qreqn, aontoppo_dbgtop_qreqn, aontoppo_extsys_qreqn}),
  .dev_qacceptn_i ({aontoppo_systop_qacceptn, aontoppo_dbgtop_qacceptn, aontoppo_extsys_qacceptn}),
  .dev_qdeny_i ({aontoppo_systop_qdeny, aontoppo_dbgtop_qdeny, aontoppo_extsys_qdeny}),
  .dev_qactive_i ({aontoppo_systop_qactive, aontoppo_dbgtop_qactive, aontoppo_extsys_qactive}),

  .clk_qactive_o (aontoppo_aontopwarm_lpd_qactive)
);



wire [NUM_EXT_SYS-1:0]   extsys_aontop_qreqn_int;
wire [NUM_EXT_SYS-1:0]   extsys_aontop_qacceptn_int;
wire [NUM_EXT_SYS-1:0]   extsys_aontop_qdeny_int;
wire [NUM_EXT_SYS-1:0]   extsys_aontop_qactive_int;


generate
  genvar I;
  for (I=0; I<NUM_EXT_SYS; I=I+1)
  begin: GEN_EXTSYS_LPD_Q
    pck600_lpd_q #(
      .SEQUENCER      (0),
      .NUM_QCHL       (3),
      .CTRL_Q_CH_SYNC (SYNC_ENABLE),
      .DEV_Q_CH_SYNC  (SYNC_ENABLE),
      .ACTIVE_DENY    (0)
    ) u_extsys_hostsys_lpd_q (
    
      .clk (refclk),
      .reset_n (aontopwarmresetn_refclk),
    
      .dftcgen (dftcgen),
    
      .ctrl_qreqn_i (extsys_hostsys_qreqn[I]),
      .ctrl_qacceptn_o (extsys_hostsys_qacceptn[I]),
      .ctrl_qdeny_o (extsys_hostsys_qdeny[I]),
      .ctrl_qactive_o ( ),
    
      .dev_qreqn_o ({extsys_aontop_qreqn_int[I], extsys_dbgtop_qreqn[I], extsys_systop_qreqn[I]}),
      .dev_qacceptn_i ({extsys_aontop_qacceptn_int[I], extsys_dbgtop_qacceptn[I], extsys_systop_qacceptn[I]}),
      .dev_qdeny_i ({extsys_aontop_qdeny_int[I], extsys_dbgtop_qdeny[I], extsys_systop_qdeny[I]}),
      .dev_qactive_i ({extsys_aontop_qactive_int[I], extsys_dbgtop_qactive[I], extsys_systop_qactive[I]}),
    
      .clk_qactive_o (extsys_hostsys_lpd_qactive[I])
    );
  end
endgenerate



generate
  genvar J;
  for (J=0; J<NUM_EXT_SYS; J=J+1)
  begin: GEN_EXTSYS_AONTOP_LPC_Q
    pck600_lpc_q #(
      .NUM_CTRL_Q_CHL (2),
      .NUM_DEV_Q_CHL  (1),
      .CTRL_Q_CH_SYNC (0),
      .DEV_Q_CH_SYNC  (SYNC_ENABLE)
    ) u_extsys_aontop_lpc_q (
      .clk (refclk),
      .reset_n (aontopwarmresetn_refclk),

      .dftcgen (dftcgen),

      .ctrl_qreqn_i ({extsys_aontop_qreqn_int[J], aontoppo_extsys_qreqn[J]}),
      .ctrl_qacceptn_o ({extsys_aontop_qacceptn_int[J], aontoppo_extsys_qacceptn[J]}),
      .ctrl_qdeny_o ({extsys_aontop_qdeny_int[J], aontoppo_extsys_qdeny[J]}),
      .ctrl_qactive_o ({extsys_aontop_qactive_int[J], aontoppo_extsys_qactive[J]}),

      .dev_qreqn_o (extsys_aontop_qreqn[J]),
      .dev_qacceptn_i (extsys_aontop_qacceptn[J]),
      .dev_qdeny_i (extsys_aontop_qdeny[J]),
      .dev_qactive_i (extsys_aontop_qactive[J]),

      .clk_qactive_o (extsys_aontop_lpc_qactive[J])
    );
  end
endgenerate


arm_element_or_tree #( .NUM_OR_TREE_INPUTS (2+2*NUM_EXT_SYS) )
u_refclkaon_clk_qactive_or_tree (
  .or_tree_i ({secenc_hostsys_lpd_qactive,
               aontoppo_aontopwarm_lpd_qactive,
               extsys_hostsys_lpd_qactive,
               extsys_aontop_lpc_qactive}
             ),

  .or_tree_o (refclk_clk_qactive)
);



arm_element_std_or2 u_aontopporesetn_dftrstdisable_or2
(
  .A (aontopporesetn_int),
  .B (dftrstdisable[1]),

  .Y (aontopporesetn)
);

arm_element_std_or2 u_aontopwarmresetn_dftrstdisable_or2
(
  .A (aontopwarmresetn_int),
  .B (dftrstdisable[1]),

  .Y (aontopwarmresetn)
);

arm_element_reset_sync u_aontopwarmreset_reset_sync (
  .clk           (refclk),
  .resetn_async  (aontopwarmresetn),

  .resetn_sync   (aontopwarmresetn_refclk),
  .dftrstdisable (dftrstdisable[0])
);

arm_element_std_or2 u_secporesetn_dftrstdisable_or2
(
  .A (secporesetn_int),
  .B (dftrstdisable[1]),

  .Y (secporesetn)
);

generate
  genvar M;
  for (M=0; M<NUM_EXT_SYS; M=M+1)
  begin: gen_extsys_dft_or_gate
    arm_element_std_or2 u_extsysporesetn_dftrstdisable_or2
    (
      .A (extsysporesetn_int[M]),
      .B (dftrstdisable[1]),
      .Y (extsysporesetn[M])
    );
  end
endgenerate

                                             
assign cdbgrstack_dp    = cdbgrstack_dp_int;   
assign csysrstack_dprom = csysrstack_dprom_int;
assign host_sys_rst_ack = host_sys_rst_ack_int;
assign extsys_rst_ack   = extsys_rst_ack_int; 
                                             
assign secenccpuwait    = secenccpuwait_int;   
assign extsyscpuwait    = extsyscpuwait_int;   
                                             
assign soc_rst_syn      = soc_rst_syn_int;     
assign host_rst_syn     = host_rst_syn_int;    
assign extsys_rst_syn   = extsys_rst_syn_int;  
assign se_rst_syn       = se_rst_syn_int;      



endmodule



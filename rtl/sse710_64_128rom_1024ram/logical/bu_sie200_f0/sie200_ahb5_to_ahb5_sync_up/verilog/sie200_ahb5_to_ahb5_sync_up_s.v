// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Wed Nov 23 16:54:21 2016 +0000
//
//      Revision            : eed409c
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//------------------------------------------------------------------------------

module sie200_ahb5_to_ahb5_sync_up_s #(

  parameter ADDR_WIDTH    = 32,
  parameter DATA_WIDTH    = 32,
  parameter MASTER_WIDTH    = 4,
  parameter USER_WIDTH    = 1,
  parameter BURST = 0,
            WRITE_BUFFER    = 0,
  parameter QS_CLOCK_EN     = 1,
  parameter QM_CLOCK_EN     = 1,
  parameter QS_POWER_EN     = 1,
  parameter QS_SYNC         = 0,
  parameter EXT_GATE_SYNC   = 0
 )
 (
  input  wire                     hclk_s,
  input  wire                     hresetn_s,

  input  wire                     hsel_s,
  input  wire                     hnonsec_s,
  input  wire [ADDR_WIDTH-1:0]    haddr_s,
  input  wire [1:0]               htrans_s,
  input  wire [2:0]               hsize_s,
  input  wire                     hwrite_s,
  input  wire [DATA_WIDTH-1:0]    hwdata_s,
  input  wire                     hready_s,
  input  wire [6:0]               hprot_s,
  input  wire [MASTER_WIDTH-1:0]  hmaster_s,
  input  wire                     hmastlock_s,
  input  wire                     hexcl_s,
  input  wire [2:0]               hburst_s,
  input  wire [USER_WIDTH-1:0]    hauser_s,
  input  wire [USER_WIDTH-1:0]    hwuser_s,

  output wire                     hreadyout_s,
  output wire                     hresp_s,
  output wire                     hexokay_s,
  output wire [DATA_WIDTH-1:0]    hrdata_s,
  output wire [USER_WIDTH-1:0]    hruser_s,

  input  wire                     ahb5_sync_up_irq_clear,
  output wire                     ahb5_sync_up_irq,

  output wire                     hnonsecs_reg,
  output wire [ADDR_WIDTH-1:0]    haddrs_reg,
  output wire [1:0]               htranss_reg,
  output wire [2:0]               hsizes_reg,
  output wire                     hwrites_reg,
  output wire [6:0]               hprots_reg,
  output wire [MASTER_WIDTH-1:0]  hmasters_reg,
  output wire                     hmastlocks_reg,
  output wire                     hexcls_reg,
  output wire [2:0]               hbursts_reg,
  output wire [USER_WIDTH-1:0]    hausers_reg,
  output wire [DATA_WIDTH-1:0]    hwdatas_reg,
  output wire [USER_WIDTH-1:0]    hwusers_reg,

  input  wire                     hrespm_reg,
  input  wire                     hexokaym_reg,
  input  wire [DATA_WIDTH-1:0]    hrdatam_reg,
  input  wire [USER_WIDTH-1:0]    hruserm_reg,

  input  wire                     transm_done,
  output wire                     transs_req,
  output wire                     unlocks_req,
  output wire                     bursts_terminate,

  output wire                     hclk_qactive_s,
  input  wire                     hclk_qreqn_s,
  output wire                     hclk_qacceptn_s,
  output wire                     hclk_qdeny_s,

  output wire                     pwr_qactive_s,
  input  wire                     pwr_qreqn_s,
  output wire                     pwr_qacceptn_s,
  output wire                     pwr_qdeny_s,

  output wire                     s_active_reg,
  output wire                     pwr_ext_wake,
  input  wire                     m_ext_wake,
  input  wire                     m_lp_req_n,
  output wire                     m_lp_done_n,
  output wire                     pwr_lp_req_n,
  input  wire                     pwr_lp_done_n,

  input  wire                     ext_gate_req,
  output wire                     ext_gate_ack,
  input  wire                     cfg_gate_resp
  );


wire                        s_hold_en;
wire                        s_pend_trans;
wire                        s_active;
wire                        wb_disable;
wire                        brg_pwr_req_s;

wire                        hnonsec_i;
wire     [2:0]              hsizes_i;
wire                        hwrites_i;
wire                        hreadys_i;
wire     [6:0]              hprots_i;
wire                        hmastlocks_i;
wire     [2:0]              hbursts_i;
wire                        hexcls_i;
wire                        hreadyouts_i;
wire                        hresps_i;
wire                        hexokays_i;
wire                        hsels_i;
wire     [1:0]              htranss_i;
wire     [MASTER_WIDTH-1:0] hmasters_i;
wire     [ADDR_WIDTH-1:0]   haddrs_i;
wire     [USER_WIDTH-1:0]   hausers_i;
wire     [DATA_WIDTH-1:0]   hwdatas_i;
wire     [USER_WIDTH-1:0]   hwusers_i;
wire     [DATA_WIDTH-1:0]   hrdatas_i;
wire     [USER_WIDTH-1:0]   hrusers_i;

wire                        hnonsecs_reg_ngo;
wire     [ADDR_WIDTH-1:0]   haddrs_reg_ngo;
wire     [1:0]              htranss_reg_ngo;
wire     [2:0]              hsizes_reg_ngo;
wire                        hwrites_reg_ngo;
wire     [6:0]              hprots_reg_ngo;
wire     [MASTER_WIDTH-1:0] hmasters_reg_ngo;
wire                        hmastlocks_reg_ngo;
wire                        hexcls_reg_ngo;
wire     [2:0]              hbursts_reg_ngo;
wire     [USER_WIDTH-1:0]   hausers_reg_ngo;
wire     [DATA_WIDTH-1:0]   hwdatas_reg_ngo;
wire     [USER_WIDTH-1:0]   hwusers_reg_ngo;
wire                        transs_req_ngo;
wire                        unlocks_req_ngo;
wire                        bursts_terminate_ngo;


sie200_ahb5_access_ctrl_core_s # (
    .QCLK_SYNC        (1'b1),
    .QS_CLOCK_EN      (QS_CLOCK_EN),
    .QM_CLOCK_EN      (QM_CLOCK_EN),
    .QS_POWER_EN      (QS_POWER_EN),
    .QS_SYNC          (QS_SYNC),
    .EXT_GATE_SYNC    (EXT_GATE_SYNC))
  u_acg_s (
    .hclk_s           (hclk_s),
    .hresetn_s        (hresetn_s),

    .hclk_qactive_s   (hclk_qactive_s),
    .hclk_qreqn_s     (hclk_qreqn_s),
    .hclk_qacceptn_s  (hclk_qacceptn_s),
    .hclk_qdeny_s     (hclk_qdeny_s),

    .pwr_qactive_s    (pwr_qactive_s),
    .pwr_qreqn_s      (pwr_qreqn_s),
    .pwr_qacceptn_s   (pwr_qacceptn_s),
    .pwr_qdeny_s      (pwr_qdeny_s),

    .ext_gate_req     (ext_gate_req),
    .ext_gate_ack     (ext_gate_ack),

    .brg_pwr_req_s    (brg_pwr_req_s),
    .brg_pwr_ack_s    (brg_pwr_req_s),

    .hold_en          (s_hold_en),
    .pend_trans       (s_pend_trans),
    .s_active         (s_active),

    .s_active_reg     (s_active_reg),
    .pwr_ext_wake     (pwr_ext_wake),
    .m_ext_wake       (m_ext_wake),
    .m_lp_req_n       (m_lp_req_n),
    .m_lp_done_n      (m_lp_done_n),
    .pwr_lp_req_n     (pwr_lp_req_n),
    .pwr_lp_done_n    (pwr_lp_done_n)
);


sie200_ahb5_to_ahb5_sync_up_core_s # (
    .AW               (ADDR_WIDTH),
    .DW               (DATA_WIDTH),
    .MW               (MASTER_WIDTH),
    .UW               (USER_WIDTH),
    .BURST            (BURST))
  u_core_s(
    .hclk_s           (hclk_s              ),
    .hresetn_s        (hresetn_s           ),
    .hsel_s           (hsels_i             ),
    .hnonsec_s        (hnonsec_i           ),
    .haddr_s          (haddrs_i            ),
    .htrans_s         (htranss_i           ),
    .hsize_s          (hsizes_i            ),
    .hwrite_s         (hwrites_i           ),
    .hready_s         (hreadys_i           ),
    .hprot_s          (hprots_i            ),
    .hmaster_s        (hmasters_i          ),
    .hmastlock_s      (hmastlocks_i        ),
    .hexcl_s          (hexcls_i            ),
    .hburst_s         (hbursts_i           ),
    .hauser_s         (hausers_i           ),
    .hwdata_s         (hwdatas_i           ),
    .hwuser_s         (hwusers_i           ),
    .hreadyout_s      (hreadyouts_i        ),
    .hresp_s          (hresps_i            ),
    .hexokay_s        (hexokays_i          ),
    .hrdata_s         (hrdatas_i           ),
    .hruser_s         (hrusers_i           ),
    .hnonsecs_reg     (hnonsecs_reg_ngo    ),
    .haddrs_reg       (haddrs_reg_ngo      ),
    .htranss_reg      (htranss_reg_ngo     ),
    .hsizes_reg       (hsizes_reg_ngo      ),
    .hwrites_reg      (hwrites_reg_ngo     ),
    .hprots_reg       (hprots_reg_ngo      ),
    .hmasters_reg     (hmasters_reg_ngo    ),
    .hmastlocks_reg   (hmastlocks_reg_ngo  ),
    .hexcls_reg       (hexcls_reg_ngo      ),
    .hbursts_reg      (hbursts_reg_ngo     ),
    .hausers_reg      (hausers_reg_ngo     ),
    .hwdatas_reg      (hwdatas_reg_ngo     ),
    .hwusers_reg      (hwusers_reg_ngo     ),
    .hrespm_reg       (hrespm_reg          ),
    .hexokaym_reg     (hexokaym_reg        ),
    .hrdatam_reg      (hrdatam_reg         ),
    .hruserm_reg      (hruserm_reg         ),
    .transm_done      (transm_done         ),
    .transs_req       (transs_req_ngo      ),
    .unlocks_req      (unlocks_req_ngo     ),
    .bursts_terminate (bursts_terminate_ngo),
    .bwerr            (ahb5_sync_up_irq    ),
    .wb_disable       (wb_disable          ),
    .cfg_gate_resp    (cfg_gate_resp       ),
    .s_hold_en        (s_hold_en           ),
    .s_pend_trans     (s_pend_trans        ),
    .s_active         (s_active            ),
    .brg_pwr_req_s    (brg_pwr_req_s       )
);


generate
  if (WRITE_BUFFER == 1) begin: gen_wb_support

    sie200_ahb5_write_buffer # (
        .AW               (ADDR_WIDTH),
        .DW               (DATA_WIDTH),
        .MW               (MASTER_WIDTH),
        .UW               (USER_WIDTH))
      u_wb(
        .hclk             (hclk_s      ),
        .hresetn          (hresetn_s   ),
        .hsel_s           (hsel_s      ),
        .hnonsec_s        (hnonsec_s   ),
        .haddr_s          (haddr_s     ),
        .htrans_s         (htrans_s    ),
        .hsize_s          (hsize_s     ),
        .hwrite_s         (hwrite_s    ),
        .hready_s         (hready_s    ),
        .hprot_s          (hprot_s     ),
        .hmaster_s        (hmaster_s   ),
        .hmastlock_s      (hmastlock_s ),
        .hwdata_s         (hwdata_s    ),
        .hburst_s         (hburst_s    ),
        .hexcl_s          (hexcl_s     ),
        .hauser_s         (hauser_s    ),
        .hwuser_s         (hwuser_s    ),
        .hreadyout_s      (hreadyout_s ),
        .hresp_s          (hresp_s     ),
        .hexokay_s        (hexokay_s   ),
        .hrdata_s         (hrdata_s    ),
        .hruser_s         (hruser_s    ),
        .hsel_m           (hsels_i     ),
        .hnonsec_m        (hnonsec_i   ),
        .haddr_m          (haddrs_i    ),
        .htrans_m         (htranss_i   ),
        .hsize_m          (hsizes_i    ),
        .hwrite_m         (hwrites_i   ),
        .hready_m         (hreadys_i   ),
        .hprot_m          (hprots_i    ),
        .hmaster_m        (hmasters_i  ),
        .hmastlock_m      (hmastlocks_i),
        .hwdata_m         (hwdatas_i   ),
        .hburst_m         (hbursts_i   ),
        .hexcl_m          (hexcls_i    ),
        .hauser_m         (hausers_i   ),
        .hwuser_m         (hwusers_i   ),
        .hreadyout_m      (hreadyouts_i),
        .hresp_m          (hresps_i    ),
        .hexokay_m        (hexokays_i  ),
        .hrdata_m         (hrdatas_i   ),
        .hruser_m         (hrusers_i   ),
        .wb_disable       (wb_disable  ),
        .bwerr_clear      (ahb5_sync_up_irq_clear),
        .bwerr            (ahb5_sync_up_irq      )
    );

  end
  else begin: gen_no_wb_support
    assign hsels_i       = hsel_s;
    assign hnonsec_i     = hnonsec_s;
    assign haddrs_i      = haddr_s;
    assign htranss_i     = htrans_s;
    assign hsizes_i      = hsize_s;
    assign hwrites_i     = hwrite_s;
    assign hreadys_i     = hready_s;
    assign hprots_i      = hprot_s;
    assign hmasters_i    = hmaster_s;
    assign hmastlocks_i  = hmastlock_s;
    assign hwdatas_i     = hwdata_s;
    assign hbursts_i     = hburst_s;
    assign hexcls_i      = hexcl_s;
    assign hausers_i     = hauser_s;
    assign hwusers_i     = hwuser_s;
    assign hreadyout_s   = hreadyouts_i;
    assign hresp_s       = hresps_i;
    assign hexokay_s     = hexokays_i;
    assign hrdata_s      = hrdatas_i;
    assign hruser_s      = hrusers_i;

    assign ahb5_sync_up_irq = 1'b0;
  end
endgenerate


generate
  if (QS_POWER_EN == 1) begin: gen_force_iso
    sie200_and #(.DATA_WIDTH(1           )) u_and_hnonsec_reg      (.in_a(~brg_pwr_req_s                ), .in_b(hnonsecs_reg_ngo    ), .out_y(hnonsecs_reg    ));
    sie200_and #(.DATA_WIDTH(ADDR_WIDTH  )) u_and_haddrs_reg       (.in_a({ADDR_WIDTH{~brg_pwr_req_s}}  ), .in_b(haddrs_reg_ngo      ), .out_y(haddrs_reg      ));
    sie200_and #(.DATA_WIDTH(1           )) u_and_htranss_reg_bit0 (.in_a(~brg_pwr_req_s                ), .in_b(htranss_reg_ngo[0]  ), .out_y(htranss_reg[0]  ));
    sie200_or  #(.DATA_WIDTH(1           )) u_or_htranss_reg_bit1  (.in_a(brg_pwr_req_s                 ), .in_b(htranss_reg_ngo[1]  ), .out_y(htranss_reg[1]  ));
    sie200_and #(.DATA_WIDTH(3           )) u_and_hsizes_reg       (.in_a({3{~brg_pwr_req_s}}           ), .in_b(hsizes_reg_ngo      ), .out_y(hsizes_reg      ));
    sie200_and #(.DATA_WIDTH(1           )) u_and_hwrites_reg      (.in_a(~brg_pwr_req_s                ), .in_b(hwrites_reg_ngo     ), .out_y(hwrites_reg     ));
    sie200_and #(.DATA_WIDTH(7           )) u_and_hprots_reg       (.in_a({7{~brg_pwr_req_s}}           ), .in_b(hprots_reg_ngo      ), .out_y(hprots_reg      ));
    sie200_and #(.DATA_WIDTH(MASTER_WIDTH)) u_and_hmasters_reg     (.in_a({MASTER_WIDTH{~brg_pwr_req_s}}), .in_b(hmasters_reg_ngo    ), .out_y(hmasters_reg    ));
    sie200_and #(.DATA_WIDTH(1           )) u_and_hmastlocks_reg   (.in_a(~brg_pwr_req_s                ), .in_b(hmastlocks_reg_ngo  ), .out_y(hmastlocks_reg  ));
    sie200_and #(.DATA_WIDTH(1           )) u_and_hexcls_reg       (.in_a(~brg_pwr_req_s                ), .in_b(hexcls_reg_ngo      ), .out_y(hexcls_reg      ));
    sie200_and #(.DATA_WIDTH(3           )) u_and_hbursts_reg      (.in_a({3{~brg_pwr_req_s}}           ), .in_b(hbursts_reg_ngo     ), .out_y(hbursts_reg     ));
    sie200_and #(.DATA_WIDTH(USER_WIDTH  )) u_and_hausers_reg      (.in_a({USER_WIDTH{~brg_pwr_req_s}}  ), .in_b(hausers_reg_ngo     ), .out_y(hausers_reg     ));
    sie200_and #(.DATA_WIDTH(DATA_WIDTH  )) u_and_hwdatas_reg      (.in_a({DATA_WIDTH{~brg_pwr_req_s}}  ), .in_b(hwdatas_reg_ngo     ), .out_y(hwdatas_reg     ));
    sie200_and #(.DATA_WIDTH(USER_WIDTH  )) u_and_hwusers_reg      (.in_a({USER_WIDTH{~brg_pwr_req_s}}  ), .in_b(hwusers_reg_ngo     ), .out_y(hwusers_reg     ));

    sie200_and #(.DATA_WIDTH(1           )) u_and_transs_req       (.in_a(~brg_pwr_req_s                ), .in_b(transs_req_ngo      ), .out_y(transs_req      ));
    sie200_or  #(.DATA_WIDTH(1           )) u_and_unlocks_req      (.in_a(brg_pwr_req_s                 ), .in_b(unlocks_req_ngo     ), .out_y(unlocks_req     ));
    sie200_or  #(.DATA_WIDTH(1           )) u_and_bursts_terminate (.in_a(brg_pwr_req_s                 ), .in_b(bursts_terminate_ngo), .out_y(bursts_terminate));
  end
  else begin: gen_no_iso
    assign hnonsecs_reg     =  hnonsecs_reg_ngo;
    assign haddrs_reg       =  haddrs_reg_ngo;
    assign htranss_reg      =  htranss_reg_ngo;
    assign hsizes_reg       =  hsizes_reg_ngo;
    assign hwrites_reg      =  hwrites_reg_ngo;
    assign hprots_reg       =  hprots_reg_ngo;
    assign hmasters_reg     =  hmasters_reg_ngo;
    assign hmastlocks_reg   =  hmastlocks_reg_ngo;
    assign hexcls_reg       =  hexcls_reg_ngo;
    assign hbursts_reg      =  hbursts_reg_ngo;
    assign hausers_reg      =  hausers_reg_ngo;
    assign hwdatas_reg      =  hwdatas_reg_ngo;
    assign hwusers_reg      =  hwusers_reg_ngo;

    assign transs_req       =  transs_req_ngo;
    assign unlocks_req      =  unlocks_req_ngo;
    assign bursts_terminate =  bursts_terminate_ngo;
  end
endgenerate





































endmodule

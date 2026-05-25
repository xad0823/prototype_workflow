//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2013, 2015-2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Thu Sep 15 11:45:39 2016 +0200
//
//      Revision            : 289e59f
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------


module sie200_ahb5_to_ahb5_sync_down #(

 parameter ADDR_WIDTH    = 32,
 parameter DATA_WIDTH    = 32,
 parameter MASTER_WIDTH  = 4,
 parameter USER_WIDTH    = 1,
 parameter BURST         = 0,
 parameter WRITE_BUFFER  = 0,
 parameter QS_POWER_EN    =  1,
 parameter QS_CLOCK_EN    =  1,
 parameter QM_CLOCK_EN    =  1,
 parameter QS_SYNC        =  0,
 parameter QM_SYNC        =  0,
 parameter EXT_GATE_SYNC  =  0
 )
(
  input  wire          hclk_s,
  input  wire          hresetn_s,
  input  wire          hclk_m,
  input  wire          hresetn_m,

  input  wire                    hsel_s,
  input  wire                    hnonsec_s,
  input  wire [ADDR_WIDTH-1:0]   haddr_s,
  input  wire    [1:0]           htrans_s,
  input  wire    [2:0]           hsize_s,
  input  wire                    hwrite_s,
  input  wire                    hready_s,
  input  wire    [6:0]           hprot_s,
  input  wire    [2:0]           hburst_s,
  input  wire                    hmastlock_s,
  input  wire                    hexcl_s,
  input  wire [DATA_WIDTH-1:0]   hwdata_s,
  input  wire [MASTER_WIDTH-1:0] hmaster_s,
  input  wire [USER_WIDTH-1:0]   hauser_s,
  input  wire [USER_WIDTH-1:0]   hwuser_s,

  output wire [DATA_WIDTH-1:0]   hrdata_s,
  output wire                    hreadyout_s,
  output wire                    hresp_s,
  output wire                    hexokay_s,
  output wire [USER_WIDTH-1:0]   hruser_s,


  output wire                    hnonsec_m,
  output wire [ADDR_WIDTH-1:0]   haddr_m,
  output wire   [1:0]            htrans_m,
  output wire   [2:0]            hsize_m,
  output wire                    hwrite_m,
  output wire   [6:0]            hprot_m,
  output wire   [2:0]            hburst_m,
  output wire                    hmastlock_m,
  output wire [DATA_WIDTH-1:0]   hwdata_m,
  output wire                    hexcl_m,
  output wire [MASTER_WIDTH-1:0] hmaster_m,
  output wire [USER_WIDTH-1:0]   hauser_m,
  output wire [USER_WIDTH-1:0]   hwuser_m,

  input  wire [DATA_WIDTH-1:0]   hrdata_m,
  input  wire                    hready_m,
  input  wire                    hresp_m,
  input  wire                    hexokay_m,
  input  wire [USER_WIDTH-1:0]   hruser_m,
  output wire                    hclk_qactive_s,
  input  wire                    hclk_qreqn_s,
  output wire                    hclk_qacceptn_s,
  output wire                    hclk_qdeny_s,

  output wire                    hclk_qactive_m,
  input  wire                    hclk_qreqn_m,
  output wire                    hclk_qacceptn_m,
  output wire                    hclk_qdeny_m,

  output wire                    pwr_qactive_s,
  input  wire                    pwr_qreqn_s,
  output wire                    pwr_qacceptn_s,
  output wire                    pwr_qdeny_s,

  input  wire                    ext_gate_req,
  output wire                    ext_gate_ack,

  input  wire                    cfg_gate_resp,

  output wire                    ahb5_sync_down_irq,
  input  wire                    ahb5_sync_down_irq_clear
  );

wire                     hnonsecs_reg;
wire    [ADDR_WIDTH-1:0] haddrs_reg;
wire               [1:0] htranss_reg;
wire               [2:0] hsizes_reg;
wire                     hwrites_reg;
wire               [6:0] hprots_reg;
wire  [MASTER_WIDTH-1:0] hmasters_reg;
wire                     hmastlocks_reg;
wire                     hexcls_reg;
wire               [2:0] hbursts_reg;
wire    [USER_WIDTH-1:0] hausers_reg;
wire                     hsels_i;
wire    [ADDR_WIDTH-1:0] haddrs_i;
wire               [1:0] htranss_i;
wire    [DATA_WIDTH-1:0] hwdatas_i;
wire    [USER_WIDTH-1:0] hwusers_i;
wire                     hrespm_reg;
wire                     hexokaym_reg;
wire   [DATA_WIDTH-1:0]  hrdatam_reg;
wire   [USER_WIDTH-1:0]  hruserm_reg;
wire                     transm_done;
wire                     transs_req;
wire                     unlocks_req;
wire                     transs_hold;
wire                     s_active_reg;
wire                     pwr_ext_wake;
wire                     m_ext_wake;
wire                     m_lp_req_n;
wire                     m_lp_done_n;
wire                     pwr_lp_req_n;
wire                     pwr_lp_done_n;



sie200_ahb5_to_ahb5_sync_down_s # (
    .ADDR_WIDTH       (ADDR_WIDTH   ),
    .DATA_WIDTH       (DATA_WIDTH   ),
    .MASTER_WIDTH     (MASTER_WIDTH ),
    .USER_WIDTH       (USER_WIDTH   ),
    .BURST            (BURST        ),
    .WRITE_BUFFER     (WRITE_BUFFER ),
    .QS_CLOCK_EN      (QS_CLOCK_EN  ),
    .QM_CLOCK_EN      (QM_CLOCK_EN  ),
    .QS_POWER_EN      (QS_POWER_EN  ),
    .QS_SYNC          (QS_SYNC      ),
    .EXT_GATE_SYNC    (EXT_GATE_SYNC))
  u_slave(
    .hclk_s           (hclk_s                  ),
    .hresetn_s        (hresetn_s               ),
    .hsel_s           (hsel_s                  ),
    .hnonsec_s        (hnonsec_s               ),
    .haddr_s          (haddr_s                 ),
    .htrans_s         (htrans_s                ),
    .hsize_s          (hsize_s                 ),
    .hwrite_s         (hwrite_s                ),
    .hwdata_s         (hwdata_s                ),
    .hready_s         (hready_s                ),
    .hprot_s          (hprot_s                 ),
    .hmaster_s        (hmaster_s               ),
    .hmastlock_s      (hmastlock_s             ),
    .hexcl_s          (hexcl_s                 ),
    .hburst_s         (hburst_s                ),
    .hauser_s         (hauser_s                ),
    .hwuser_s         (hwuser_s                ),
    .hreadyout_s      (hreadyout_s             ),
    .hresp_s          (hresp_s                 ),
    .hexokay_s        (hexokay_s               ),
    .hrdata_s         (hrdata_s                ),
    .hruser_s         (hruser_s                ),
    .ahb5_sync_down_irq       (ahb5_sync_down_irq      ),
    .ahb5_sync_down_irq_clear (ahb5_sync_down_irq_clear),
    .hnonsecs_reg     (hnonsecs_reg            ),
    .haddrs_reg       (haddrs_reg              ),
    .htranss_reg      (htranss_reg             ),
    .hsizes_reg       (hsizes_reg              ),
    .hwrites_reg      (hwrites_reg             ),
    .hprots_reg       (hprots_reg              ),
    .hmasters_reg     (hmasters_reg            ),
    .hmastlocks_reg   (hmastlocks_reg          ),
    .hexcls_reg       (hexcls_reg              ),
    .hbursts_reg      (hbursts_reg             ),
    .hausers_reg      (hausers_reg             ),
    .hsels_i          (hsels_i                 ),
    .haddrs_i         (haddrs_i                ),
    .htranss_i        (htranss_i               ),
    .hwdatas_i        (hwdatas_i               ),
    .hwusers_i        (hwusers_i               ),
    .hrespm_reg       (hrespm_reg              ),
    .hexokaym_reg     (hexokaym_reg            ),
    .hrdatam_reg      (hrdatam_reg             ),
    .hruserm_reg      (hruserm_reg             ),
    .transm_done      (transm_done             ),
    .transs_req       (transs_req              ),
    .unlocks_req      (unlocks_req             ),
    .transs_hold      (transs_hold             ),
    .hclk_qactive_s   (hclk_qactive_s          ),
    .hclk_qreqn_s     (hclk_qreqn_s            ),
    .hclk_qacceptn_s  (hclk_qacceptn_s         ),
    .hclk_qdeny_s     (hclk_qdeny_s            ),
    .pwr_qactive_s    (pwr_qactive_s           ),
    .pwr_qreqn_s      (pwr_qreqn_s             ),
    .pwr_qacceptn_s   (pwr_qacceptn_s          ),
    .pwr_qdeny_s      (pwr_qdeny_s             ),
    .s_active_reg     (s_active_reg            ),
    .pwr_ext_wake     (pwr_ext_wake            ),
    .m_ext_wake       (m_ext_wake              ),
    .m_lp_req_n       (m_lp_req_n              ),
    .m_lp_done_n      (m_lp_done_n             ),
    .pwr_lp_req_n     (pwr_lp_req_n            ),
    .pwr_lp_done_n    (pwr_lp_done_n           ),
    .ext_gate_req     (ext_gate_req            ),
    .ext_gate_ack     (ext_gate_ack            ),
    .cfg_gate_resp    (cfg_gate_resp           )
);

sie200_ahb5_to_ahb5_sync_down_m # (
    .ADDR_WIDTH       (ADDR_WIDTH   ),
    .DATA_WIDTH       (DATA_WIDTH   ),
    .MASTER_WIDTH     (MASTER_WIDTH ),
    .USER_WIDTH       (USER_WIDTH   ),
    .BURST            (BURST        ),
    .QS_POWER_EN      (QS_POWER_EN  ),
    .QM_CLOCK_EN      (QM_CLOCK_EN  ),
    .QM_SYNC          (QM_SYNC      ))
  u_master(
    .hclk_m           (hclk_m         ),
    .hresetn_m        (hresetn_m      ),
    .hnonsecs_reg     (hnonsecs_reg   ),
    .haddrs_reg       (haddrs_reg     ),
    .htranss_reg      (htranss_reg    ),
    .hsizes_reg       (hsizes_reg     ),
    .hwrites_reg      (hwrites_reg    ),
    .hprots_reg       (hprots_reg     ),
    .hmasters_reg     (hmasters_reg   ),
    .hmastlocks_reg   (hmastlocks_reg ),
    .hexcls_reg       (hexcls_reg     ),
    .hbursts_reg      (hbursts_reg    ),
    .hausers_reg      (hausers_reg    ),
    .hsels_i          (hsels_i        ),
    .haddrs_i         (haddrs_i       ),
    .htranss_i        (htranss_i      ),
    .hwdatas_i        (hwdatas_i      ),
    .hwusers_i        (hwusers_i      ),
    .hrespm_reg       (hrespm_reg     ),
    .hexokaym_reg     (hexokaym_reg   ),
    .hrdatam_reg      (hrdatam_reg    ),
    .hruserm_reg      (hruserm_reg    ),
    .transm_done      (transm_done    ),
    .transs_req       (transs_req     ),
    .unlocks_req      (unlocks_req    ),
    .transs_hold      (transs_hold    ),
    .hnonsec_m        (hnonsec_m      ),
    .haddr_m          (haddr_m        ),
    .htrans_m         (htrans_m       ),
    .hsize_m          (hsize_m        ),
    .hwrite_m         (hwrite_m       ),
    .hprot_m          (hprot_m        ),
    .hmaster_m        (hmaster_m      ),
    .hmastlock_m      (hmastlock_m    ),
    .hwdata_m         (hwdata_m       ),
    .hexcl_m          (hexcl_m        ),
    .hburst_m         (hburst_m       ),
    .hauser_m         (hauser_m       ),
    .hwuser_m         (hwuser_m       ),
    .hready_m         (hready_m       ),
    .hresp_m          (hresp_m        ),
    .hexokay_m        (hexokay_m      ),
    .hrdata_m         (hrdata_m       ),
    .hruser_m         (hruser_m       ),
    .hclk_qactive_m   (hclk_qactive_m ),
    .hclk_qreqn_m     (hclk_qreqn_m   ),
    .hclk_qacceptn_m  (hclk_qacceptn_m),
    .hclk_qdeny_m     (hclk_qdeny_m   ),
    .s_active_reg     (s_active_reg   ),
    .pwr_ext_wake     (pwr_ext_wake   ),
    .m_ext_wake       (m_ext_wake     ),
    .m_lp_req_n       (m_lp_req_n     ),
    .m_lp_done_n      (m_lp_done_n    ),
    .pwr_lp_req_n     (pwr_lp_req_n   ),
    .pwr_lp_done_n    (pwr_lp_done_n  )
);







endmodule























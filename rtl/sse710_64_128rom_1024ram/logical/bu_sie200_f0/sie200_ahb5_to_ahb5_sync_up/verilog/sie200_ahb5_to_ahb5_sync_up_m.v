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
//      Checked In          : Wed Nov 23 16:54:21 2016 +0000
//
//      Revision            : eed409c
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_to_ahb5_sync_up_m #(

  parameter ADDR_WIDTH    = 32,
  parameter DATA_WIDTH    = 32,
  parameter MASTER_WIDTH  = 4,
  parameter USER_WIDTH    = 1,
  parameter BURST = 0,
  parameter QS_POWER_EN   = 1,
  parameter QM_CLOCK_EN   = 1,
  parameter QM_SYNC       = 0
 )
 (
  input  wire                     hclk_m,
  input  wire                     hresetn_m,

  input  wire                     hnonsecs_reg,
  input  wire [ADDR_WIDTH-1:0]    haddrs_reg,
  input  wire [1:0]               htranss_reg,
  input  wire [2:0]               hsizes_reg,
  input  wire                     hwrites_reg,
  input  wire [6:0]               hprots_reg,
  input  wire [MASTER_WIDTH-1:0]  hmasters_reg,
  input  wire                     hmastlocks_reg,
  input  wire                     hexcls_reg,
  input  wire [2:0]               hbursts_reg,
  input  wire [USER_WIDTH-1:0]    hausers_reg,
  input  wire [DATA_WIDTH-1:0]    hwdatas_reg,
  input  wire [USER_WIDTH-1:0]    hwusers_reg,

  output wire                     hrespm_reg,
  output wire                     hexokaym_reg,
  output wire [DATA_WIDTH-1:0]    hrdatam_reg,
  output wire [USER_WIDTH-1:0]    hruserm_reg,

  output wire                     transm_done,
  input  wire                     transs_req,
  input  wire                     unlocks_req,
  input  wire                     bursts_terminate,

  output wire                     hnonsec_m,
  output wire [ADDR_WIDTH-1:0]    haddr_m,
  output wire [1:0]               htrans_m,
  output wire [2:0]               hsize_m,
  output wire                     hwrite_m,
  output wire [6:0]               hprot_m,
  output wire [MASTER_WIDTH-1:0]  hmaster_m,
  output wire                     hmastlock_m,
  output wire [DATA_WIDTH-1:0]    hwdata_m,
  output wire                     hexcl_m,
  output wire [2:0]               hburst_m,
  output wire [USER_WIDTH-1:0]    hauser_m,
  output wire [USER_WIDTH-1:0]    hwuser_m,

  input  wire                     hready_m,
  input  wire                     hresp_m,
  input  wire                     hexokay_m,
  input  wire [DATA_WIDTH-1:0]    hrdata_m,
  input  wire [USER_WIDTH-1:0]    hruser_m,

  output wire                     hclk_qactive_m,
  input  wire                     hclk_qreqn_m,
  output wire                     hclk_qacceptn_m,
  output wire                     hclk_qdeny_m,

  input  wire                     s_active_reg,
  input  wire                     pwr_ext_wake,
  output wire                     m_ext_wake,
  output wire                     m_lp_req_n,
  input  wire                     m_lp_done_n,
  input  wire                     pwr_lp_req_n,
  output wire                     pwr_lp_done_n
  );

wire                     brg_pwr_req_m;

wire                     hrespm_reg_ngo;
wire                     hexokaym_reg_ngo;
wire [DATA_WIDTH-1:0]    hrdatam_reg_ngo;
wire [USER_WIDTH-1:0]    hruserm_reg_ngo;
wire                     transm_done_ngo;


sie200_ahb5_access_ctrl_core_m # (
    .QCLK_SYNC          (1'b1),
    .QS_POWER_EN        (QS_POWER_EN),
    .QM_CLOCK_EN        (QM_CLOCK_EN),
    .QM_SYNC            (QM_SYNC))
  u_acg_m (
    .hclk_m             (hclk_m),
    .hresetn_m          (hresetn_m),
    .hclk_qactive_m     (hclk_qactive_m),
    .hclk_qreqn_m       (hclk_qreqn_m),
    .hclk_qacceptn_m    (hclk_qacceptn_m),
    .hclk_qdeny_m       (hclk_qdeny_m),
    .brg_pwr_req_m      (brg_pwr_req_m),
    .brg_pwr_ack_m      (brg_pwr_req_m),
    .s_active_reg       (s_active_reg),
    .pwr_ext_wake       (pwr_ext_wake),
    .m_ext_wake         (m_ext_wake),
    .m_lp_req_n         (m_lp_req_n),
    .m_lp_done_n        (m_lp_done_n),
    .pwr_lp_req_n       (pwr_lp_req_n),
    .pwr_lp_done_n      (pwr_lp_done_n)
);

sie200_ahb5_to_ahb5_sync_up_core_m # (
    .AW                 (ADDR_WIDTH   ),
    .DW                 (DATA_WIDTH   ),
    .MW                 (MASTER_WIDTH ),
    .UW                 (USER_WIDTH   ),
    .BURST              (BURST        ))
  u_core_m(
    .hclk_m             (hclk_m          ),
    .hresetn_m          (hresetn_m       ),
    .hnonsecs_reg       (hnonsecs_reg    ),
    .haddrs_reg         (haddrs_reg      ),
    .htranss_reg        (htranss_reg     ),
    .hsizes_reg         (hsizes_reg      ),
    .hwrites_reg        (hwrites_reg     ),
    .hprots_reg         (hprots_reg      ),
    .hmasters_reg       (hmasters_reg    ),
    .hmastlocks_reg     (hmastlocks_reg  ),
    .hexcls_reg         (hexcls_reg      ),
    .hbursts_reg        (hbursts_reg     ),
    .hausers_reg        (hausers_reg     ),
    .hwdatas_reg        (hwdatas_reg     ),
    .hwusers_reg        (hwusers_reg     ),
    .hrespm_reg         (hrespm_reg_ngo  ),
    .hexokaym_reg       (hexokaym_reg_ngo),
    .hrdatam_reg        (hrdatam_reg_ngo ),
    .hruserm_reg        (hruserm_reg_ngo ),
    .transm_done        (transm_done_ngo ),
    .transs_req         (transs_req      ),
    .unlocks_req        (unlocks_req     ),
    .bursts_terminate   (bursts_terminate),
    .brg_pwr_req_m      (brg_pwr_req_m   ),
    .hnonsec_m          (hnonsec_m       ),
    .haddr_m            (haddr_m         ),
    .htrans_m           (htrans_m        ),
    .hsize_m            (hsize_m         ),
    .hwrite_m           (hwrite_m        ),
    .hprot_m            (hprot_m         ),
    .hmaster_m          (hmaster_m       ),
    .hmastlock_m        (hmastlock_m     ),
    .hwdata_m           (hwdata_m        ),
    .hexcl_m            (hexcl_m         ),
    .hburst_m           (hburst_m        ),
    .hauser_m           (hauser_m        ),
    .hwuser_m           (hwuser_m        ),
    .hready_m           (hready_m        ),
    .hresp_m            (hresp_m         ),
    .hexokay_m          (hexokay_m       ),
    .hrdata_m           (hrdata_m        ),
    .hruser_m           (hruser_m        )
);


generate
  if (QS_POWER_EN == 1) begin: gen_force_iso
    sie200_and #(.DATA_WIDTH(1         )) u_and_hrespm_reg   (.in_a(~brg_pwr_req_m              ), .in_b(hrespm_reg_ngo  ), .out_y(hrespm_reg  ));
    sie200_and #(.DATA_WIDTH(1         )) u_and_hexokaym_reg (.in_a(~brg_pwr_req_m              ), .in_b(hexokaym_reg_ngo), .out_y(hexokaym_reg));
    sie200_and #(.DATA_WIDTH(DATA_WIDTH)) u_and_hrdatam_reg  (.in_a({DATA_WIDTH{~brg_pwr_req_m}}), .in_b(hrdatam_reg_ngo ), .out_y(hrdatam_reg ));
    sie200_and #(.DATA_WIDTH(USER_WIDTH)) u_and_hruserm_reg  (.in_a({USER_WIDTH{~brg_pwr_req_m}}), .in_b(hruserm_reg_ngo ), .out_y(hruserm_reg ));

    sie200_and #(.DATA_WIDTH(1         )) u_and_transm_done  (.in_a(~brg_pwr_req_m              ), .in_b(transm_done_ngo ), .out_y(transm_done ));
  end
  else begin: gen_no_iso
    assign hrespm_reg   = hrespm_reg_ngo;
    assign hexokaym_reg = hexokaym_reg_ngo;
    assign hrdatam_reg  = hrdatam_reg_ngo;
    assign hruserm_reg  = hruserm_reg_ngo;

    assign transm_done  = transm_done_ngo;
  end
endgenerate












endmodule

//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//          (C) COPYRIGHT 2015-2016 ARM Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from ARM Limited or its affiliates.
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
module sie200_ahb5_to_ahb5_apb_async_m #(
      parameter ADDR_WIDTH      = 32,
      parameter MASTER_WIDTH    = 4,
      parameter USER_WIDTH      = 1,
      parameter QS_POWER_EN     = 1,
      parameter QM_CLOCK_EN     = 1,
      parameter QM_SYNC         = 0
)
(

  input  wire                    hclk_m,
  input  wire                    hresetn_m,

  output wire                    m_semaphore,
  input  wire                    s_semaphore,

  output wire                    m_mask,
  input  wire                    s_mask,

  input  wire                    reg_hsel_apb_s,
  input  wire                    reg_hnonsec_s,
  input  wire [ADDR_WIDTH-1:0]   reg_haddr_s,
  input  wire [2:0]              reg_hsize_s,
  input  wire                    reg_hwrite_s,
  input  wire [6:0]              reg_hprot_s,
  input  wire                    reg_hmastlock_s,
  input  wire                    reg_unlock_s,
  input  wire [31:0]             reg_hwdata_s,
  input  wire                    reg_hexcl_s,
  input  wire [MASTER_WIDTH-1:0] reg_hmaster_s,
  input  wire [USER_WIDTH-1:0]   reg_hauser_s,
  input  wire [USER_WIDTH-1:0]   reg_hwuser_s,
  input  wire                    q_hmastlock_s,

  output wire                    hnonsec_m,
  output wire [ADDR_WIDTH-1:0]   haddr_m,
  output wire [1:0]              htrans_m,
  output wire [2:0]              hsize_m,
  output wire                    hwrite_m,
  input  wire                    hready_m,
  output wire [6:0]              hprot_m,
  output wire [2:0]              hburst_m,
  output wire                    hmastlock_m,
  output wire [31:0]             hwdata_m,
  output wire                    hexcl_m,
  output wire [MASTER_WIDTH-1:0] hmaster_m,
  input  wire                    hresp_m,
  input  wire [31:0]             hrdata_m,
  input  wire                    hexokay_m,
  output wire [USER_WIDTH-1:0]   hauser_m,
  output wire [USER_WIDTH-1:0]   hwuser_m,
  input  wire [USER_WIDTH-1:0]   hruser_m,

  output wire [ADDR_WIDTH-1:0]   paddr_m,
  output wire [ 2:0]             pprot_m,
  output wire                    psel_m,
  output wire                    penable_m,
  output wire                    pwrite_m,
  output wire [31:0]             pwdata_m,
  output wire [ 3:0]             pstrb_m,
  input  wire                    pready_m,
  input  wire [31:0]             prdata_m,
  input  wire                    pslverr_m,
  output wire [MASTER_WIDTH-1:0] pmaster_m,

  output wire                    hactive_m,
  output wire                    pactive_m,

  output wire                    comb_hresp_m,
  output wire [31:0]             comb_hrdata_m,
  output wire                    comb_hexokay_m,
  output wire [USER_WIDTH-1:0]   comb_hruser_m,
  output wire                    hclk_qactive_m,
  input  wire                    hclk_qreqn_m,
  output wire                    hclk_qacceptn_m,
  output wire                    hclk_qdeny_m,

  input  wire                    s_active_reg,
  input  wire                    pwr_ext_wake,
  output wire                    m_ext_wake,
  output wire                    m_lp_req_n,
  input  wire                    m_lp_done_n,
  input  wire                    pwr_lp_req_n,
  output wire                    pwr_lp_done_n

  );


  wire                           brg_pwr_req_m;
  wire                           brg_pwr_ack_m;


  sie200_ahb5_to_ahb5_apb_async_core_m # (
     .ADDR_WIDTH       (ADDR_WIDTH),
     .MASTER_WIDTH     (MASTER_WIDTH),
     .USER_WIDTH       (USER_WIDTH))
  u_master_core (
    .hclk_m            (hclk_m),
    .hresetn_m         (hresetn_m),

     .m_semaphore      (m_semaphore),
     .s_semaphore      (s_semaphore),

     .m_mask           (m_mask),
     .s_mask           (s_mask),

     .reg_hsel_apb_s   (reg_hsel_apb_s),
     .reg_hnonsec_s    (reg_hnonsec_s),
     .reg_haddr_s      (reg_haddr_s),
     .reg_hsize_s      (reg_hsize_s),
     .reg_hwrite_s     (reg_hwrite_s),
     .reg_hprot_s      (reg_hprot_s),
     .reg_hmastlock_s  (reg_hmastlock_s),
     .reg_unlock_s     (reg_unlock_s),
     .reg_hwdata_s     (reg_hwdata_s),
     .reg_hexcl_s      (reg_hexcl_s),
     .reg_hmaster_s    (reg_hmaster_s),
     .reg_hauser_s     (reg_hauser_s),
     .reg_hwuser_s     (reg_hwuser_s),
     .q_hmastlock_s    (q_hmastlock_s),

     .hnonsec_m        (hnonsec_m),
     .haddr_m          (haddr_m),
     .htrans_m         (htrans_m),
     .hsize_m          (hsize_m),
     .hwrite_m         (hwrite_m),
     .hready_m         (hready_m),
     .hprot_m          (hprot_m),
     .hburst_m         (hburst_m),
     .hmastlock_m      (hmastlock_m),
     .hwdata_m         (hwdata_m),
     .hexcl_m          (hexcl_m),
     .hmaster_m        (hmaster_m),
     .hresp_m          (hresp_m),
     .hrdata_m         (hrdata_m),
     .hexokay_m        (hexokay_m),
     .hauser_m         (hauser_m),
     .hwuser_m         (hwuser_m),
     .hruser_m         (hruser_m),

     .paddr_m          (paddr_m),
     .pprot_m          (pprot_m),
     .psel_m           (psel_m),
     .penable_m        (penable_m),
     .pwrite_m         (pwrite_m),
     .pwdata_m         (pwdata_m),
     .pstrb_m          (pstrb_m),
     .pready_m         (pready_m),
     .prdata_m         (prdata_m),
     .pslverr_m        (pslverr_m),
     .pmaster_m        (pmaster_m),

     .hactive_m        (hactive_m),
     .pactive_m        (pactive_m),

     .comb_hresp_m     (comb_hresp_m),
     .comb_hrdata_m    (comb_hrdata_m),
     .comb_hexokay_m   (comb_hexokay_m),
     .comb_hruser_m    (comb_hruser_m),

     .brg_pwr_req_m    (brg_pwr_req_m),
     .brg_pwr_ack_m    (brg_pwr_ack_m)
  );


sie200_ahb5_access_ctrl_core_m # (
    .QCLK_SYNC          (0),
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
    .brg_pwr_ack_m      (brg_pwr_ack_m),

    .s_active_reg       (s_active_reg),
    .pwr_ext_wake       (pwr_ext_wake),
    .m_ext_wake         (m_ext_wake),
    .m_lp_req_n         (m_lp_req_n),
    .m_lp_done_n        (m_lp_done_n),
    .pwr_lp_req_n       (pwr_lp_req_n),
    .pwr_lp_done_n      (pwr_lp_done_n)
);




endmodule

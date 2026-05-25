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
//      Checked In          : Thu Nov 10 15:27:46 2016 +0000
//
//      Revision            : baa1af6
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------
module sie200_ahb5_to_ahb5_apb_async #(
      parameter ADDR_WIDTH      = 32,
      parameter MASTER_WIDTH    = 4,
      parameter USER_WIDTH      = 1,
      parameter QS_CLOCK_EN     = 1,
      parameter QM_CLOCK_EN     = 1,
      parameter QS_POWER_EN     = 1,
      parameter QS_SYNC         = 0,
      parameter QM_SYNC         = 0,
      parameter EXT_GATE_SYNC   = 0
)
(

  input  wire                    hclk_s,
  input  wire                    hresetn_s,
  input  wire                    hclk_m,
  input  wire                    hresetn_m,


  input  wire                    hsel_ahb_s,
  input  wire                    hsel_apb_s,
  input  wire                    hnonsec_s,
  input  wire [ADDR_WIDTH-1:0]   haddr_s,
  input  wire [1:0]              htrans_s,
  input  wire [2:0]              hsize_s,
  input  wire                    hwrite_s,
  input  wire                    hready_s,
  input  wire [6:0]              hprot_s,
  input  wire [2:0]              hburst_s,
  input  wire                    hmastlock_s,
  input  wire [31:0]             hwdata_s,
  input  wire                    hexcl_s,
  input  wire [MASTER_WIDTH-1:0] hmaster_s,
  output wire [31:0]             hrdata_s,
  output wire                    hreadyout_s,
  output wire                    hresp_s,
  output wire                    hexokay_s,
  input  wire [USER_WIDTH-1:0]   hauser_s,
  input  wire [USER_WIDTH-1:0]   hwuser_s,
  output wire [USER_WIDTH-1:0]   hruser_s,


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

  output wire                    hclk_qactive_s,
  input  wire                    hclk_qreqn_s,
  output wire                    hclk_qacceptn_s,
  output wire                    hclk_qdeny_s,

  output wire                    hclk_qactive_m,
  input  wire                    hclk_qreqn_m,
  output wire                    hclk_qacceptn_m,
  output wire                    hclk_qdeny_m,

  output wire                    pwr_qactive_s,
  input  wire                    pwr_qreqn_s ,
  output wire                    pwr_qacceptn_s,
  output wire                    pwr_qdeny_s ,

  output wire                    hactive_m,
  output wire                    pactive_m,

  input  wire                    ext_gate_req,
  output wire                    ext_gate_ack,
  input  wire                    cfg_gate_resp
);


  wire                           m_semaphore;
  wire                           s_semaphore;

  wire                           m_mask;
  wire                           s_mask;

  wire                           reg_hsel_apb_s;
  wire                           reg_hnonsec_s;
  wire [ADDR_WIDTH-1:0]          reg_haddr_s;
  wire [2:0]                     reg_hsize_s;
  wire                           reg_hwrite_s;
  wire [6:0]                     reg_hprot_s;
  wire                           reg_hmastlock_s;
  wire                           reg_unlock_s;
  wire [31:0]                    reg_hwdata_s;
  wire                           reg_hexcl_s;
  wire [MASTER_WIDTH-1:0]        reg_hmaster_s;
  wire [USER_WIDTH-1:0]          reg_hauser_s;
  wire [USER_WIDTH-1:0]          reg_hwuser_s;

  wire                           q_hmastlock_s;

  wire                           comb_hresp_m;
  wire [31:0]                    comb_hrdata_m;
  wire                           comb_hexokay_m;
  wire  [USER_WIDTH-1:0]         comb_hruser_m;

  wire                           s_active_reg;
  wire                           pwr_ext_wake;
  wire                           m_ext_wake;
  wire                           m_lp_req_n;
  wire                           m_lp_done_n;
  wire                           pwr_lp_req_n;
  wire                           pwr_lp_done_n;


  sie200_ahb5_to_ahb5_apb_async_s # (
    .ADDR_WIDTH        (ADDR_WIDTH),
    .MASTER_WIDTH      (MASTER_WIDTH),
    .USER_WIDTH        (USER_WIDTH),
    .QS_CLOCK_EN       (QS_CLOCK_EN),
    .QM_CLOCK_EN       (QM_CLOCK_EN),
    .QS_POWER_EN       (QS_POWER_EN),
    .QS_SYNC           (QS_SYNC),
    .EXT_GATE_SYNC     (EXT_GATE_SYNC))
  u_slave (
     .hclk_s           (hclk_s),
     .hresetn_s        (hresetn_s),

     .hsel_ahb_s       (hsel_ahb_s),
     .hsel_apb_s       (hsel_apb_s),
     .hnonsec_s        (hnonsec_s),
     .haddr_s          (haddr_s),
     .htrans_s         (htrans_s),
     .hsize_s          (hsize_s),
     .hwrite_s         (hwrite_s),
     .hready_s         (hready_s),
     .hprot_s          (hprot_s),
     .hburst_s         (hburst_s),
     .hmastlock_s      (hmastlock_s),
     .hwdata_s         (hwdata_s),
     .hexcl_s          (hexcl_s),
     .hmaster_s        (hmaster_s),
     .hrdata_s         (hrdata_s),
     .hreadyout_s      (hreadyout_s),
     .hresp_s          (hresp_s),
     .hexokay_s        (hexokay_s),

     .hruser_s         (hruser_s),
     .hauser_s         (hauser_s),
     .hwuser_s         (hwuser_s),

     .s_semaphore      (s_semaphore),
     .m_semaphore      (m_semaphore),

     .s_mask           (s_mask),
     .m_mask           (m_mask),

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

     .comb_hresp_m     (comb_hresp_m),
     .comb_hrdata_m    (comb_hrdata_m),
     .comb_hexokay_m   (comb_hexokay_m),
     .comb_hruser_m    (comb_hruser_m),

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
     .cfg_gate_resp    (cfg_gate_resp),

     .s_active_reg     (s_active_reg),
     .pwr_ext_wake     (pwr_ext_wake),
     .m_ext_wake       (m_ext_wake),
     .m_lp_req_n       (m_lp_req_n),
     .m_lp_done_n      (m_lp_done_n),
     .pwr_lp_req_n     (pwr_lp_req_n),
     .pwr_lp_done_n    (pwr_lp_done_n)

  );


  sie200_ahb5_to_ahb5_apb_async_m # (
    .ADDR_WIDTH        (ADDR_WIDTH),
    .MASTER_WIDTH      (MASTER_WIDTH),
    .USER_WIDTH        (USER_WIDTH),
    .QS_POWER_EN       (QS_POWER_EN),
    .QM_CLOCK_EN       (QM_CLOCK_EN),
    .QM_SYNC           (QM_SYNC))
  u_master (
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

    .hclk_qactive_m    (hclk_qactive_m),
    .hclk_qreqn_m      (hclk_qreqn_m),
    .hclk_qacceptn_m   (hclk_qacceptn_m),
    .hclk_qdeny_m      (hclk_qdeny_m),

     .s_active_reg     (s_active_reg),
     .pwr_ext_wake     (pwr_ext_wake),
     .m_ext_wake       (m_ext_wake),
     .m_lp_req_n       (m_lp_req_n),
     .m_lp_done_n      (m_lp_done_n),
     .pwr_lp_req_n     (pwr_lp_req_n),
     .pwr_lp_done_n    (pwr_lp_done_n)

  );













`ifdef ARM_ASSERT_ON


    if ( ADDR_WIDTH > 32 )
      assert_sie200_ahb5_to_ahb5_apb_async_addr_width_check_1 : assert property ( @(posedge hclk_m) !$rose(hresetn_m)  ) else $warning("HADDR is only supported up to 32 bits!");

    if ( ADDR_WIDTH < 10 )
      assert_sie200_ahb5_to_ahb5_apb_async_addr_width_check_2 : assert property ( @(posedge hclk_m) !$rose(hresetn_m)  ) else $warning("HADDR should be at least 10 bits!");
























`endif


endmodule

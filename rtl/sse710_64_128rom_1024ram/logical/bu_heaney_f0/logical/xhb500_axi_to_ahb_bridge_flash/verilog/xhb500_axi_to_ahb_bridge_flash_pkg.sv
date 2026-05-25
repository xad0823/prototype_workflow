//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2025 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//-----------------------------------------------------------------------------
//
//      Version Information
//
//      Checked In          : Fri Mar 29 11:15:40 2019 +0000
//
//      Revision            : 08e988e
//
//      Release Information : CoreLink XHB-500 Generic Global Bundle r0p0-00rel0
//

package xhb500_axi_to_ahb_bridge_flash_pkg;

  typedef logic [2:0] xhb_size_t;

  typedef struct packed {
    logic                                     en_bridge;
    logic                                     en_core;
    logic                                     en_ar;
    logic                                     en_aw;
    logic                                     en_w;
  } ctrl_lpi_en_t;


  typedef struct packed {
    logic                                     bridge_err;
    logic                                     rvalid;
    logic                                     resp_acc;
    logic                                     ahb_last;
    logic                                     sp_empty;
  } resp_fsm_ctrl_t;

  typedef struct packed {
    logic                                     awready;
    logic                                     wready;
    logic                                     arready;
    logic                                     hold_output;
    logic                                     sparse;
    resp_fsm_ctrl_t                           resp;
  } xhb_fsm_ctrl_t;

  typedef struct packed {
    logic [11:0]                              haddr_11_0;
    xhb_size_t                                hsize;
    logic [1:0]                               htrans;
    logic                                     hmastlock;
    logic [7:0]                               rd_left;
  } xhb_fsm_out_t;


  typedef struct packed {
    logic [$clog2(16)-1:0]                    haddr_strb;
    xhb_size_t                                hsize;
    logic                                     hwrite;
    logic     [12-1:0]                        axid;
    resp_fsm_ctrl_t                           ctrl;
  } xhb_ahb_addrph_t;



  typedef struct packed {
    logic     [32-1:0]                        axaddr;
    logic     [1:0]                           axburst;
    logic     [12-1:0]                        axid;
    logic     [7:0]                           axlen;
    xhb_size_t                                axsize;
    logic                                     axlock;
    logic     [2:0]                           axprot;
    logic     [3:0]                           axcache;
    logic     [1:0]                           axdomain;
    logic     [3:0]                           axnsaid;
    logic     [3:0]                           axqos;
    logic     [3:0]                           axregion;
  } axi_axpayld_t;

  typedef struct packed {
    logic                                     awsparse;
    axi_axpayld_t                             awpayld;
  } axi_awsppayld_t;

  typedef struct packed {
    logic                                     wlast;
    logic     [16-1:0]                        wstrb;
    logic     [128-1:0]                       wdata;
  } axi_wpayld_t;

  typedef struct packed {
    logic     [12-1:0]                        rid;
    logic     [128-1:0]                       rdata;
    logic                                     rlast;
    logic     [1:0]                           rresp;
  } axi_rpayld_t;

  typedef struct packed {
    logic     [12-1:0]                        bid;
    logic     [1:0]                           bresp;
  } axi_bpayld_t;



  typedef struct packed {
    logic     [2:0]                           hburst;
    logic                                     hnonsec;
    logic     [6:0]                           hprot;
    logic     [12-1:0]                        hmaster;
    logic                                     hexcl;
    logic     [3:0]                           hqos;
    logic     [3:0]                           hregion;
    logic     [3:0]                           hnsaid;
    logic     [32-1:12]                       haddr_m_12;
  } ahb_m_trq_t;

  typedef struct packed {
    logic                                     hwrite;
    logic                                     ctrl_exclid;
    ahb_m_trq_t                               trfixq;
  } ahb_m_trfix_t;

  typedef struct packed {
    logic     [11:0]                          haddr_11_0;
    xhb_size_t                                hsize;
    logic                                     hmastlock;
    resp_fsm_ctrl_t                           resp_ctrl;
  } ahb_m_hfix_t;

  typedef struct packed {
    logic     [128-1:0]                       hwdata;
  } ahb_m_wdata_t;


  typedef struct packed {
    ahb_m_trfix_t                             trfix;
    ahb_m_hfix_t                              hfix;
    ahb_m_wdata_t                             wdata;
  } ahb_mpayld_t;


  typedef struct packed {
    logic     [128-1:0]                       hrdata;
    logic                                     hresp;
    logic                                     hexokay;
  } ahb_spayld_t;

endpackage

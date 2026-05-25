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


// This is the specification for the interface between the SCU and any external
// signals. It does not include assertions for standard interfaces such as ACE,
// as these are covered by their own protocol checkers.

// Inputs and outputs are from the point of view of the SCU.

// This file was automatically generated from the interface specification,
// do not edit it directly.
`ifdef ARM_ASSERT_ON

`include "ca53_scu_ext_defs.v"
`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53scu_defs.v"
`include "ca53_scu_dcu_defs.v"

module ca53_scu_ext #(parameter INOPTIONS = `OVL_ASSERT, parameter OUTOPTIONS = `OVL_ASSERT) (
  input         clk,
  input         reset_n,
  input         l2rstdisable_i,
  input         broadcastinner_i,
  input         broadcastouter_i,
  input         broadcastcachemaint_i,
  input         sysbardisable_i,
  input         acinactm_i,
  input         scu_ext_aclken_i,
  input         ext_sclken_i,
  input         ext_sinact_i,
  input         l2flushreq_i,
  input         scu_ext_ar_ready_i,
  input         scu_ext_dr_valid_i,
  input   [5:0] scu_ext_dr_id_i,
  input   [3:0] scu_ext_dr_resp_i,
  input [127:0] scu_ext_dr_data_i,
  input         scu_ext_dr_last_i,
  input         scu_ext_aw_ready_i,
  input         scu_ext_dw_ready_i,
  input         scu_ext_db_valid_i,
  input   [4:0] scu_ext_db_id_i,
  input   [1:0] scu_ext_db_resp_i,
  input         scu_ext_ac_valid_i,
  input   [3:0] scu_ext_ac_snoop_i,
  input  [43:0] scu_ext_ac_addr_i,
  input   [2:0] scu_ext_ac_prot_i,
  input         scu_ext_cr_ready_i,
  input         scu_ext_cd_ready_i,
  input         ext_rxsactive_i,
  input         ext_rxlinkactivereq_i,
  input         ext_txlinkactiveack_i,
  input         ext_txreqlcrdv_i,
  input         ext_txrsplcrdv_i,
  input         ext_txdatlcrdv_i,
  input         ext_rxsnpflitpend_i,
  input         ext_rxsnpflitv_i,
  input  [64:0] ext_rxsnpflit_i,
  input         ext_rxrspflitpend_i,
  input         ext_rxrspflitv_i,
  input  [44:0] ext_rxrspflit_i,
  input         ext_rxdatflitpend_i,
  input         ext_rxdatflitv_i,
  input [193:0] ext_rxdatflit_i,
  input   [1:0] ext_samaddrmap0_i,
  input   [1:0] ext_samaddrmap1_i,
  input   [1:0] ext_samaddrmap2_i,
  input   [1:0] ext_samaddrmap3_i,
  input   [1:0] ext_samaddrmap4_i,
  input   [1:0] ext_samaddrmap5_i,
  input   [1:0] ext_samaddrmap6_i,
  input   [1:0] ext_samaddrmap7_i,
  input   [1:0] ext_samaddrmap8_i,
  input   [1:0] ext_samaddrmap9_i,
  input   [1:0] ext_samaddrmap10_i,
  input   [1:0] ext_samaddrmap11_i,
  input   [1:0] ext_samaddrmap12_i,
  input   [1:0] ext_samaddrmap13_i,
  input   [1:0] ext_samaddrmap14_i,
  input   [1:0] ext_samaddrmap15_i,
  input [39:24] ext_sammnbase_i,
  input   [6:0] ext_sammnnodeid_i,
  input   [6:0] ext_samhni0nodeid_i,
  input   [6:0] ext_samhni1nodeid_i,
  input   [6:0] ext_samhnf0nodeid_i,
  input   [6:0] ext_samhnf1nodeid_i,
  input   [6:0] ext_samhnf2nodeid_i,
  input   [6:0] ext_samhnf3nodeid_i,
  input   [6:0] ext_samhnf4nodeid_i,
  input   [6:0] ext_samhnf5nodeid_i,
  input   [6:0] ext_samhnf6nodeid_i,
  input   [6:0] ext_samhnf7nodeid_i,
  input   [2:0] ext_samhnfmode_i,
  input   [6:0] ext_nodeid_i,
  input         ext_acp_aclken_i,
  input         ext_acp_ainact_i,
  input         ext_acp_awvalid_i,
  input   [4:0] ext_acp_awid_i,
  input  [39:0] ext_acp_awaddr_i,
  input   [7:0] ext_acp_awlen_i,
  input   [3:0] ext_acp_awcache_i,
  input   [1:0] ext_acp_awuser_i,
  input   [2:0] ext_acp_awprot_i,
  input         ext_acp_wvalid_i,
  input [127:0] ext_acp_wdata_i,
  input  [15:0] ext_acp_wstrb_i,
  input         ext_acp_wlast_i,
  input         ext_acp_bready_i,
  input         ext_acp_arvalid_i,
  input   [4:0] ext_acp_arid_i,
  input  [39:0] ext_acp_araddr_i,
  input   [7:0] ext_acp_arlen_i,
  input   [3:0] ext_acp_arcache_i,
  input   [1:0] ext_acp_aruser_i,
  input   [2:0] ext_acp_arprot_i,
  input         ext_acp_rready_i,
  input         nexterrirq_i,
  input         ninterrirq_i,
  input         standbywfil2_i,
  input         l2flushdone_i,
  input         scu_ext_ar_valid_i,
  input   [5:0] scu_ext_ar_id_i,
  input  [43:0] scu_ext_ar_addr_i,
  input   [7:0] scu_ext_ar_len_i,
  input   [2:0] scu_ext_ar_size_i,
  input   [1:0] scu_ext_ar_burst_i,
  input         scu_ext_ar_lock_i,
  input   [3:0] scu_ext_ar_cache_i,
  input   [2:0] scu_ext_ar_prot_i,
  input   [3:0] scu_ext_ar_snoop_i,
  input   [1:0] scu_ext_ar_domain_i,
  input   [1:0] scu_ext_ar_bar_i,
  input   [7:0] scu_ext_rdmemattr_i,
  input         scu_ext_dr_ready_i,
  input         scu_ext_aw_valid_i,
  input   [4:0] scu_ext_aw_id_i,
  input  [43:0] scu_ext_aw_addr_i,
  input   [7:0] scu_ext_aw_len_i,
  input   [2:0] scu_ext_aw_size_i,
  input   [1:0] scu_ext_aw_burst_i,
  input         scu_ext_aw_lock_i,
  input   [3:0] scu_ext_aw_cache_i,
  input   [2:0] scu_ext_aw_prot_i,
  input   [2:0] scu_ext_aw_snoop_i,
  input   [1:0] scu_ext_aw_domain_i,
  input   [1:0] scu_ext_aw_bar_i,
  input         scu_ext_aw_unique_i,
  input   [7:0] scu_ext_wrmemattr_i,
  input         scu_ext_dw_valid_i,
  input   [4:0] scu_ext_dw_id_i,
  input  [15:0] scu_ext_dw_strb_i,
  input [127:0] scu_ext_dw_data_i,
  input         scu_ext_dw_last_i,
  input         scu_ext_db_ready_i,
  input         scu_ext_ac_ready_i,
  input         scu_ext_cr_valid_i,
  input   [4:0] scu_ext_cr_resp_i,
  input         scu_ext_cd_valid_i,
  input [127:0] scu_ext_cd_data_i,
  input         scu_ext_cd_last_i,
  input         scu_ext_rack_i,
  input         scu_ext_wack_i,
  input         scu_txsactive_i,
  input         scu_rxlinkactiveack_i,
  input         scu_txlinkactivereq_i,
  input         scu_txreqflitpend_i,
  input         scu_txreqflitv_i,
  input  [99:0] scu_txreqflit_i,
  input   [7:0] scu_reqmemattr_i,
  input         scu_txrspflitpend_i,
  input         scu_txrspflitv_i,
  input  [44:0] scu_txrspflit_i,
  input         scu_txdatflitpend_i,
  input         scu_txdatflitv_i,
  input [193:0] scu_txdatflit_i,
  input         scu_rxsnplcrdv_i,
  input         scu_rxrsplcrdv_i,
  input         scu_rxdatlcrdv_i,
  input         scu_acp_awready_i,
  input         scu_acp_wready_i,
  input         scu_acp_bvalid_i,
  input   [4:0] scu_acp_bid_i,
  input   [1:0] scu_acp_bresp_i,
  input         scu_acp_arready_i,
  input         scu_acp_rvalid_i,
  input   [4:0] scu_acp_rid_i,
  input [127:0] scu_acp_rdata_i,
  input   [1:0] scu_acp_rresp_i,
  input         scu_acp_rlast_i);


  wire         l2rstdisable = l2rstdisable_i;
  wire         broadcastinner = broadcastinner_i;
  wire         broadcastouter = broadcastouter_i;
  wire         broadcastcachemaint = broadcastcachemaint_i;
  wire         sysbardisable = sysbardisable_i;
  wire         acinactm = acinactm_i;
  wire         scu_ext_aclken = scu_ext_aclken_i;
  wire         ext_sclken = ext_sclken_i;
  wire         ext_sinact = ext_sinact_i;
  wire         l2flushreq = l2flushreq_i;
  wire         scu_ext_ar_ready = scu_ext_ar_ready_i;
  wire         scu_ext_dr_valid = scu_ext_dr_valid_i;
  wire   [5:0] scu_ext_dr_id = scu_ext_dr_id_i;
  wire   [3:0] scu_ext_dr_resp = scu_ext_dr_resp_i;
  wire [127:0] scu_ext_dr_data = scu_ext_dr_data_i;
  wire         scu_ext_dr_last = scu_ext_dr_last_i;
  wire         scu_ext_aw_ready = scu_ext_aw_ready_i;
  wire         scu_ext_dw_ready = scu_ext_dw_ready_i;
  wire         scu_ext_db_valid = scu_ext_db_valid_i;
  wire   [4:0] scu_ext_db_id = scu_ext_db_id_i;
  wire   [1:0] scu_ext_db_resp = scu_ext_db_resp_i;
  wire         scu_ext_ac_valid = scu_ext_ac_valid_i;
  wire   [3:0] scu_ext_ac_snoop = scu_ext_ac_snoop_i;
  wire  [43:0] scu_ext_ac_addr = scu_ext_ac_addr_i;
  wire   [2:0] scu_ext_ac_prot = scu_ext_ac_prot_i;
  wire         scu_ext_cr_ready = scu_ext_cr_ready_i;
  wire         scu_ext_cd_ready = scu_ext_cd_ready_i;
  wire         ext_rxsactive = ext_rxsactive_i;
  wire         ext_rxlinkactivereq = ext_rxlinkactivereq_i;
  wire         ext_txlinkactiveack = ext_txlinkactiveack_i;
  wire         ext_txreqlcrdv = ext_txreqlcrdv_i;
  wire         ext_txrsplcrdv = ext_txrsplcrdv_i;
  wire         ext_txdatlcrdv = ext_txdatlcrdv_i;
  wire         ext_rxsnpflitpend = ext_rxsnpflitpend_i;
  wire         ext_rxsnpflitv = ext_rxsnpflitv_i;
  wire  [64:0] ext_rxsnpflit = ext_rxsnpflit_i;
  wire         ext_rxrspflitpend = ext_rxrspflitpend_i;
  wire         ext_rxrspflitv = ext_rxrspflitv_i;
  wire  [44:0] ext_rxrspflit = ext_rxrspflit_i;
  wire         ext_rxdatflitpend = ext_rxdatflitpend_i;
  wire         ext_rxdatflitv = ext_rxdatflitv_i;
  wire [193:0] ext_rxdatflit = ext_rxdatflit_i;
  wire   [1:0] ext_samaddrmap0 = ext_samaddrmap0_i;
  wire   [1:0] ext_samaddrmap1 = ext_samaddrmap1_i;
  wire   [1:0] ext_samaddrmap2 = ext_samaddrmap2_i;
  wire   [1:0] ext_samaddrmap3 = ext_samaddrmap3_i;
  wire   [1:0] ext_samaddrmap4 = ext_samaddrmap4_i;
  wire   [1:0] ext_samaddrmap5 = ext_samaddrmap5_i;
  wire   [1:0] ext_samaddrmap6 = ext_samaddrmap6_i;
  wire   [1:0] ext_samaddrmap7 = ext_samaddrmap7_i;
  wire   [1:0] ext_samaddrmap8 = ext_samaddrmap8_i;
  wire   [1:0] ext_samaddrmap9 = ext_samaddrmap9_i;
  wire   [1:0] ext_samaddrmap10 = ext_samaddrmap10_i;
  wire   [1:0] ext_samaddrmap11 = ext_samaddrmap11_i;
  wire   [1:0] ext_samaddrmap12 = ext_samaddrmap12_i;
  wire   [1:0] ext_samaddrmap13 = ext_samaddrmap13_i;
  wire   [1:0] ext_samaddrmap14 = ext_samaddrmap14_i;
  wire   [1:0] ext_samaddrmap15 = ext_samaddrmap15_i;
  wire [39:24] ext_sammnbase = ext_sammnbase_i;
  wire   [6:0] ext_sammnnodeid = ext_sammnnodeid_i;
  wire   [6:0] ext_samhni0nodeid = ext_samhni0nodeid_i;
  wire   [6:0] ext_samhni1nodeid = ext_samhni1nodeid_i;
  wire   [6:0] ext_samhnf0nodeid = ext_samhnf0nodeid_i;
  wire   [6:0] ext_samhnf1nodeid = ext_samhnf1nodeid_i;
  wire   [6:0] ext_samhnf2nodeid = ext_samhnf2nodeid_i;
  wire   [6:0] ext_samhnf3nodeid = ext_samhnf3nodeid_i;
  wire   [6:0] ext_samhnf4nodeid = ext_samhnf4nodeid_i;
  wire   [6:0] ext_samhnf5nodeid = ext_samhnf5nodeid_i;
  wire   [6:0] ext_samhnf6nodeid = ext_samhnf6nodeid_i;
  wire   [6:0] ext_samhnf7nodeid = ext_samhnf7nodeid_i;
  wire   [2:0] ext_samhnfmode = ext_samhnfmode_i;
  wire   [6:0] ext_nodeid = ext_nodeid_i;
  wire         ext_acp_aclken = ext_acp_aclken_i;
  wire         ext_acp_ainact = ext_acp_ainact_i;
  wire         ext_acp_awvalid = ext_acp_awvalid_i;
  wire   [4:0] ext_acp_awid = ext_acp_awid_i;
  wire  [39:0] ext_acp_awaddr = ext_acp_awaddr_i;
  wire   [7:0] ext_acp_awlen = ext_acp_awlen_i;
  wire   [3:0] ext_acp_awcache = ext_acp_awcache_i;
  wire   [1:0] ext_acp_awuser = ext_acp_awuser_i;
  wire   [2:0] ext_acp_awprot = ext_acp_awprot_i;
  wire         ext_acp_wvalid = ext_acp_wvalid_i;
  wire [127:0] ext_acp_wdata = ext_acp_wdata_i;
  wire  [15:0] ext_acp_wstrb = ext_acp_wstrb_i;
  wire         ext_acp_wlast = ext_acp_wlast_i;
  wire         ext_acp_bready = ext_acp_bready_i;
  wire         ext_acp_arvalid = ext_acp_arvalid_i;
  wire   [4:0] ext_acp_arid = ext_acp_arid_i;
  wire  [39:0] ext_acp_araddr = ext_acp_araddr_i;
  wire   [7:0] ext_acp_arlen = ext_acp_arlen_i;
  wire   [3:0] ext_acp_arcache = ext_acp_arcache_i;
  wire   [1:0] ext_acp_aruser = ext_acp_aruser_i;
  wire   [2:0] ext_acp_arprot = ext_acp_arprot_i;
  wire         ext_acp_rready = ext_acp_rready_i;
  wire         nexterrirq = nexterrirq_i;
  wire         ninterrirq = ninterrirq_i;
  wire         standbywfil2 = standbywfil2_i;
  wire         l2flushdone = l2flushdone_i;
  wire         scu_ext_ar_valid = scu_ext_ar_valid_i;
  wire   [5:0] scu_ext_ar_id = scu_ext_ar_id_i;
  wire  [43:0] scu_ext_ar_addr = scu_ext_ar_addr_i;
  wire   [7:0] scu_ext_ar_len = scu_ext_ar_len_i;
  wire   [2:0] scu_ext_ar_size = scu_ext_ar_size_i;
  wire   [1:0] scu_ext_ar_burst = scu_ext_ar_burst_i;
  wire         scu_ext_ar_lock = scu_ext_ar_lock_i;
  wire   [3:0] scu_ext_ar_cache = scu_ext_ar_cache_i;
  wire   [2:0] scu_ext_ar_prot = scu_ext_ar_prot_i;
  wire   [3:0] scu_ext_ar_snoop = scu_ext_ar_snoop_i;
  wire   [1:0] scu_ext_ar_domain = scu_ext_ar_domain_i;
  wire   [1:0] scu_ext_ar_bar = scu_ext_ar_bar_i;
  wire   [7:0] scu_ext_rdmemattr = scu_ext_rdmemattr_i;
  wire         scu_ext_dr_ready = scu_ext_dr_ready_i;
  wire         scu_ext_aw_valid = scu_ext_aw_valid_i;
  wire   [4:0] scu_ext_aw_id = scu_ext_aw_id_i;
  wire  [43:0] scu_ext_aw_addr = scu_ext_aw_addr_i;
  wire   [7:0] scu_ext_aw_len = scu_ext_aw_len_i;
  wire   [2:0] scu_ext_aw_size = scu_ext_aw_size_i;
  wire   [1:0] scu_ext_aw_burst = scu_ext_aw_burst_i;
  wire         scu_ext_aw_lock = scu_ext_aw_lock_i;
  wire   [3:0] scu_ext_aw_cache = scu_ext_aw_cache_i;
  wire   [2:0] scu_ext_aw_prot = scu_ext_aw_prot_i;
  wire   [2:0] scu_ext_aw_snoop = scu_ext_aw_snoop_i;
  wire   [1:0] scu_ext_aw_domain = scu_ext_aw_domain_i;
  wire   [1:0] scu_ext_aw_bar = scu_ext_aw_bar_i;
  wire         scu_ext_aw_unique = scu_ext_aw_unique_i;
  wire   [7:0] scu_ext_wrmemattr = scu_ext_wrmemattr_i;
  wire         scu_ext_dw_valid = scu_ext_dw_valid_i;
  wire   [4:0] scu_ext_dw_id = scu_ext_dw_id_i;
  wire  [15:0] scu_ext_dw_strb = scu_ext_dw_strb_i;
  wire [127:0] scu_ext_dw_data = scu_ext_dw_data_i;
  wire         scu_ext_dw_last = scu_ext_dw_last_i;
  wire         scu_ext_db_ready = scu_ext_db_ready_i;
  wire         scu_ext_ac_ready = scu_ext_ac_ready_i;
  wire         scu_ext_cr_valid = scu_ext_cr_valid_i;
  wire   [4:0] scu_ext_cr_resp = scu_ext_cr_resp_i;
  wire         scu_ext_cd_valid = scu_ext_cd_valid_i;
  wire [127:0] scu_ext_cd_data = scu_ext_cd_data_i;
  wire         scu_ext_cd_last = scu_ext_cd_last_i;
  wire         scu_ext_rack = scu_ext_rack_i;
  wire         scu_ext_wack = scu_ext_wack_i;
  wire         scu_txsactive = scu_txsactive_i;
  wire         scu_rxlinkactiveack = scu_rxlinkactiveack_i;
  wire         scu_txlinkactivereq = scu_txlinkactivereq_i;
  wire         scu_txreqflitpend = scu_txreqflitpend_i;
  wire         scu_txreqflitv = scu_txreqflitv_i;
  wire  [99:0] scu_txreqflit = scu_txreqflit_i;
  wire   [7:0] scu_reqmemattr = scu_reqmemattr_i;
  wire         scu_txrspflitpend = scu_txrspflitpend_i;
  wire         scu_txrspflitv = scu_txrspflitv_i;
  wire  [44:0] scu_txrspflit = scu_txrspflit_i;
  wire         scu_txdatflitpend = scu_txdatflitpend_i;
  wire         scu_txdatflitv = scu_txdatflitv_i;
  wire [193:0] scu_txdatflit = scu_txdatflit_i;
  wire         scu_rxsnplcrdv = scu_rxsnplcrdv_i;
  wire         scu_rxrsplcrdv = scu_rxrsplcrdv_i;
  wire         scu_rxdatlcrdv = scu_rxdatlcrdv_i;
  wire         scu_acp_awready = scu_acp_awready_i;
  wire         scu_acp_wready = scu_acp_wready_i;
  wire         scu_acp_bvalid = scu_acp_bvalid_i;
  wire   [4:0] scu_acp_bid = scu_acp_bid_i;
  wire   [1:0] scu_acp_bresp = scu_acp_bresp_i;
  wire         scu_acp_arready = scu_acp_arready_i;
  wire         scu_acp_rvalid = scu_acp_rvalid_i;
  wire   [4:0] scu_acp_rid = scu_acp_rid_i;
  wire [127:0] scu_acp_rdata = scu_acp_rdata_i;
  wire   [1:0] scu_acp_rresp = scu_acp_rresp_i;
  wire         scu_acp_rlast = scu_acp_rlast_i;

  wire   [4:0] bar_ar_id;
  wire [193:0] txdat_valid;
  wire [193:0] rxdat_valid;
  wire [127:0] expanded_strobes_57;

  reg         rxdatflitpend;
  reg   [3:0] rxrsp_credits;
  reg  [63:0] dvm_outstanding;
  reg   [3:0] txdat_credits;
  reg  [31:0] aw_outstanding;
  reg         txlinkactiveack_prev1;
  reg         txdatflitpend;
  reg   [3:0] txreq_credits;
  reg         rxsnpflitpend;
  reg         rxrspflitpend;
  reg         rxlinkactivereq_prev1;
  reg         rxlinkactivereq_prev2;
  reg  [63:0] ar_outstanding;
  reg         out_of_reset;
  reg   [3:0] rxsnp_credits;
  reg   [3:0] txrsp_credits;
  reg   [3:0] rxdat_credits;
  reg         txreqflitpend;
  reg         txrspflitpend;

  reg   [1:0] scu_ext_aw_bar_reg;
  reg   [1:0] scu_ext_ar_burst_reg;
  reg         scu_txrspflitpend_reg;
  reg         ext_acp_aclken_reg;
  reg         ext_acp_aclken_reg_reg;
  reg   [3:0] scu_ext_ar_snoop_reg;
  reg         scu_ext_ar_valid_reg;
  reg         scu_ext_cd_last_reg;
  reg         scu_ext_db_ready_reg;
  reg         scu_ext_wack_reg;
  reg  [99:0] scu_txreqflit_reg;
  reg   [1:0] scu_ext_ar_domain_reg;
  reg  [15:0] scu_ext_dw_strb_reg;
  reg [127:0] scu_ext_cd_data_reg;
  reg   [7:0] scu_ext_aw_len_reg;
  reg   [5:0] scu_ext_ar_id_reg;
  reg         scu_ext_aw_unique_reg;
  reg   [7:0] scu_ext_rdmemattr_reg;
  reg   [1:0] scu_ext_ar_bar_reg;
  reg   [1:0] scu_acp_rresp_reg;
  reg   [1:0] scu_acp_bresp_reg;
  reg         scu_rxdatlcrdv_reg;
  reg         scu_ext_dw_last_reg;
  reg         scu_txlinkactivereq_reg;
  reg         scu_ext_aclken_reg;
  reg         scu_ext_aclken_reg_reg;
  reg   [4:0] scu_ext_dw_id_reg;
  reg         scu_txrspflitv_reg;
  reg         scu_txreqflitpend_reg;
  reg  [43:0] scu_ext_ar_addr_reg;
  reg   [4:0] scu_ext_aw_id_reg;
  reg         scu_acp_arready_reg;
  reg         scu_acp_bvalid_reg;
  reg   [3:0] scu_ext_ar_cache_reg;
  reg   [2:0] scu_ext_aw_prot_reg;
  reg   [7:0] scu_reqmemattr_reg;
  reg         scu_txdatflitv_reg;
  reg   [4:0] scu_acp_bid_reg;
  reg         scu_acp_wready_reg;
  reg         scu_ext_aw_valid_reg;
  reg  [43:0] scu_ext_aw_addr_reg;
  reg         scu_rxlinkactiveack_reg;
  reg         scu_txsactive_reg;
  reg         scu_rxrsplcrdv_reg;
  reg   [1:0] scu_ext_aw_burst_reg;
  reg         scu_acp_awready_reg;
  reg   [2:0] scu_ext_ar_prot_reg;
  reg         scu_rxsnplcrdv_reg;
  reg   [2:0] scu_ext_aw_snoop_reg;
  reg         scu_ext_cd_valid_reg;
  reg   [7:0] scu_ext_ar_len_reg;
  reg         scu_acp_rvalid_reg;
  reg  [44:0] scu_txrspflit_reg;
  reg         out_of_reset_reg;
  reg         l2flushreq_reg;
  reg         l2flushreq_reg_reg;
  reg         l2flushreq_reg_reg_reg;
  reg         l2flushreq_reg_reg_reg_reg;
  reg   [7:0] scu_ext_wrmemattr_reg;
  reg         scu_ext_rack_reg;
  reg         scu_txreqflitv_reg;
  reg         l2flushdone_reg;
  reg         scu_ext_cr_valid_reg;
  reg [127:0] scu_ext_dw_data_reg;
  reg         scu_acp_rlast_reg;
  reg   [4:0] scu_acp_rid_reg;
  reg [127:0] scu_acp_rdata_reg;
  reg         scu_txdatflitpend_reg;
  reg         scu_ext_dw_valid_reg;
  reg         scu_ext_ac_ready_reg;
  reg         scu_ext_aw_lock_reg;
  reg   [1:0] scu_ext_aw_domain_reg;
  reg [193:0] scu_txdatflit_reg;
  reg         ext_sclken_reg;
  reg         ext_sclken_reg_reg;
  reg   [2:0] scu_ext_ar_size_reg;
  reg   [4:0] scu_ext_cr_resp_reg;
  reg         scu_ext_dr_ready_reg;
  reg   [3:0] scu_ext_aw_cache_reg;
  reg         scu_ext_ar_lock_reg;
  reg   [2:0] scu_ext_aw_size_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    scu_ext_aw_bar_reg <= 2'b00;
    scu_ext_ar_burst_reg <= 2'b00;
    scu_txrspflitpend_reg <= 1'b0;
    ext_acp_aclken_reg <= 1'b0;
    ext_acp_aclken_reg_reg <= 1'b0;
    scu_ext_ar_snoop_reg <= 4'b0000;
    scu_ext_ar_valid_reg <= 1'b0;
    scu_ext_cd_last_reg <= 1'b0;
    scu_ext_db_ready_reg <= 1'b0;
    scu_ext_wack_reg <= 1'b0;
    scu_txreqflit_reg <= {100{1'b0}};
    scu_ext_ar_domain_reg <= 2'b00;
    scu_ext_dw_strb_reg <= {16{1'b0}};
    scu_ext_cd_data_reg <= {128{1'b0}};
    scu_ext_aw_len_reg <= {8{1'b0}};
    scu_ext_ar_id_reg <= {6{1'b0}};
    scu_ext_aw_unique_reg <= 1'b0;
    scu_ext_rdmemattr_reg <= {8{1'b0}};
    scu_ext_ar_bar_reg <= 2'b00;
    scu_acp_rresp_reg <= 2'b00;
    scu_acp_bresp_reg <= 2'b00;
    scu_rxdatlcrdv_reg <= 1'b0;
    scu_ext_dw_last_reg <= 1'b0;
    scu_txlinkactivereq_reg <= 1'b0;
    scu_ext_aclken_reg <= 1'b0;
    scu_ext_aclken_reg_reg <= 1'b0;
    scu_ext_dw_id_reg <= {5{1'b0}};
    scu_txrspflitv_reg <= 1'b0;
    scu_txreqflitpend_reg <= 1'b0;
    scu_ext_ar_addr_reg <= {44{1'b0}};
    scu_ext_aw_id_reg <= {5{1'b0}};
    scu_acp_arready_reg <= 1'b0;
    scu_acp_bvalid_reg <= 1'b0;
    scu_ext_ar_cache_reg <= 4'b0000;
    scu_ext_aw_prot_reg <= 3'b000;
    scu_reqmemattr_reg <= {8{1'b0}};
    scu_txdatflitv_reg <= 1'b0;
    scu_acp_bid_reg <= {5{1'b0}};
    scu_acp_wready_reg <= 1'b0;
    scu_ext_aw_valid_reg <= 1'b0;
    scu_ext_aw_addr_reg <= {44{1'b0}};
    scu_rxlinkactiveack_reg <= 1'b0;
    scu_txsactive_reg <= 1'b0;
    scu_rxrsplcrdv_reg <= 1'b0;
    scu_ext_aw_burst_reg <= 2'b00;
    scu_acp_awready_reg <= 1'b0;
    scu_ext_ar_prot_reg <= 3'b000;
    scu_rxsnplcrdv_reg <= 1'b0;
    scu_ext_aw_snoop_reg <= 3'b000;
    scu_ext_cd_valid_reg <= 1'b0;
    scu_ext_ar_len_reg <= {8{1'b0}};
    scu_acp_rvalid_reg <= 1'b0;
    scu_txrspflit_reg <= {45{1'b0}};
    out_of_reset_reg <= 1'b0;
    l2flushreq_reg <= 1'b0;
    l2flushreq_reg_reg <= 1'b0;
    l2flushreq_reg_reg_reg <= 1'b0;
    l2flushreq_reg_reg_reg_reg <= 1'b0;
    scu_ext_wrmemattr_reg <= {8{1'b0}};
    scu_ext_rack_reg <= 1'b0;
    scu_txreqflitv_reg <= 1'b0;
    l2flushdone_reg <= 1'b0;
    scu_ext_cr_valid_reg <= 1'b0;
    scu_ext_dw_data_reg <= {128{1'b0}};
    scu_acp_rlast_reg <= 1'b0;
    scu_acp_rid_reg <= {5{1'b0}};
    scu_acp_rdata_reg <= {128{1'b0}};
    scu_txdatflitpend_reg <= 1'b0;
    scu_ext_dw_valid_reg <= 1'b0;
    scu_ext_ac_ready_reg <= 1'b0;
    scu_ext_aw_lock_reg <= 1'b0;
    scu_ext_aw_domain_reg <= 2'b00;
    scu_txdatflit_reg <= {194{1'b0}};
    ext_sclken_reg <= 1'b0;
    ext_sclken_reg_reg <= 1'b0;
    scu_ext_ar_size_reg <= 3'b000;
    scu_ext_cr_resp_reg <= {5{1'b0}};
    scu_ext_dr_ready_reg <= 1'b0;
    scu_ext_aw_cache_reg <= 4'b0000;
    scu_ext_ar_lock_reg <= 1'b0;
    scu_ext_aw_size_reg <= 3'b000;
  end
  else
  begin
    scu_ext_aclken_reg <= scu_ext_aclken;
    scu_ext_aclken_reg_reg <= scu_ext_aclken_reg;
    ext_sclken_reg <= ext_sclken;
    ext_sclken_reg_reg <= ext_sclken_reg;
    l2flushreq_reg <= l2flushreq;
    l2flushreq_reg_reg <= l2flushreq_reg;
    l2flushreq_reg_reg_reg <= l2flushreq_reg_reg;
    l2flushreq_reg_reg_reg_reg <= l2flushreq_reg_reg_reg;
    ext_acp_aclken_reg <= ext_acp_aclken;
    ext_acp_aclken_reg_reg <= ext_acp_aclken_reg;
    l2flushdone_reg <= l2flushdone;
    scu_ext_ar_valid_reg <= scu_ext_ar_valid;
    scu_ext_ar_id_reg <= scu_ext_ar_id;
    scu_ext_ar_addr_reg <= scu_ext_ar_addr;
    scu_ext_ar_len_reg <= scu_ext_ar_len;
    scu_ext_ar_size_reg <= scu_ext_ar_size;
    scu_ext_ar_burst_reg <= scu_ext_ar_burst;
    scu_ext_ar_lock_reg <= scu_ext_ar_lock;
    scu_ext_ar_cache_reg <= scu_ext_ar_cache;
    scu_ext_ar_prot_reg <= scu_ext_ar_prot;
    scu_ext_ar_snoop_reg <= scu_ext_ar_snoop;
    scu_ext_ar_domain_reg <= scu_ext_ar_domain;
    scu_ext_ar_bar_reg <= scu_ext_ar_bar;
    scu_ext_rdmemattr_reg <= scu_ext_rdmemattr;
    scu_ext_dr_ready_reg <= scu_ext_dr_ready;
    scu_ext_aw_valid_reg <= scu_ext_aw_valid;
    scu_ext_aw_id_reg <= scu_ext_aw_id;
    scu_ext_aw_addr_reg <= scu_ext_aw_addr;
    scu_ext_aw_len_reg <= scu_ext_aw_len;
    scu_ext_aw_size_reg <= scu_ext_aw_size;
    scu_ext_aw_burst_reg <= scu_ext_aw_burst;
    scu_ext_aw_lock_reg <= scu_ext_aw_lock;
    scu_ext_aw_cache_reg <= scu_ext_aw_cache;
    scu_ext_aw_prot_reg <= scu_ext_aw_prot;
    scu_ext_aw_snoop_reg <= scu_ext_aw_snoop;
    scu_ext_aw_domain_reg <= scu_ext_aw_domain;
    scu_ext_aw_bar_reg <= scu_ext_aw_bar;
    scu_ext_aw_unique_reg <= scu_ext_aw_unique;
    scu_ext_wrmemattr_reg <= scu_ext_wrmemattr;
    scu_ext_dw_valid_reg <= scu_ext_dw_valid;
    scu_ext_dw_id_reg <= scu_ext_dw_id;
    scu_ext_dw_strb_reg <= scu_ext_dw_strb;
    scu_ext_dw_data_reg <= scu_ext_dw_data;
    scu_ext_dw_last_reg <= scu_ext_dw_last;
    scu_ext_db_ready_reg <= scu_ext_db_ready;
    scu_ext_ac_ready_reg <= scu_ext_ac_ready;
    scu_ext_cr_valid_reg <= scu_ext_cr_valid;
    scu_ext_cr_resp_reg <= scu_ext_cr_resp;
    scu_ext_cd_valid_reg <= scu_ext_cd_valid;
    scu_ext_cd_data_reg <= scu_ext_cd_data;
    scu_ext_cd_last_reg <= scu_ext_cd_last;
    scu_ext_rack_reg <= scu_ext_rack;
    scu_ext_wack_reg <= scu_ext_wack;
    scu_txsactive_reg <= scu_txsactive;
    scu_rxlinkactiveack_reg <= scu_rxlinkactiveack;
    scu_txlinkactivereq_reg <= scu_txlinkactivereq;
    scu_txreqflitpend_reg <= scu_txreqflitpend;
    scu_txreqflitv_reg <= scu_txreqflitv;
    scu_txreqflit_reg <= scu_txreqflit;
    scu_reqmemattr_reg <= scu_reqmemattr;
    scu_txrspflitpend_reg <= scu_txrspflitpend;
    scu_txrspflitv_reg <= scu_txrspflitv;
    scu_txrspflit_reg <= scu_txrspflit;
    scu_txdatflitpend_reg <= scu_txdatflitpend;
    scu_txdatflitv_reg <= scu_txdatflitv;
    scu_txdatflit_reg <= scu_txdatflit;
    scu_rxsnplcrdv_reg <= scu_rxsnplcrdv;
    scu_rxrsplcrdv_reg <= scu_rxrsplcrdv;
    scu_rxdatlcrdv_reg <= scu_rxdatlcrdv;
    scu_acp_awready_reg <= scu_acp_awready;
    scu_acp_wready_reg <= scu_acp_wready;
    scu_acp_bvalid_reg <= scu_acp_bvalid;
    scu_acp_bid_reg <= scu_acp_bid;
    scu_acp_bresp_reg <= scu_acp_bresp;
    scu_acp_arready_reg <= scu_acp_arready;
    scu_acp_rvalid_reg <= scu_acp_rvalid;
    scu_acp_rid_reg <= scu_acp_rid;
    scu_acp_rdata_reg <= scu_acp_rdata;
    scu_acp_rresp_reg <= scu_acp_rresp;
    scu_acp_rlast_reg <= scu_acp_rlast;
    out_of_reset_reg <= out_of_reset;
  end



  //----------------------------------------------------------------------------
  // Configuration inputs
  //----------------------------------------------------------------------------

  //  input          l2rstdisable        valid always          timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "l2rstdisable X or Z")
  u_ovl_intf_x_l2rstdisable (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (l2rstdisable));

  //  input          broadcastinner      valid always          timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "broadcastinner X or Z")
  u_ovl_intf_x_broadcastinner (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (broadcastinner));

  //  input          broadcastouter      valid always          timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "broadcastouter X or Z")
  u_ovl_intf_x_broadcastouter (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (broadcastouter));

  //  input          broadcastcachemaint valid always          timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "broadcastcachemaint X or Z")
  u_ovl_intf_x_broadcastcachemaint (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (broadcastcachemaint));

  //  input          sysbardisable       valid always          timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "sysbardisable X or Z")
  u_ovl_intf_x_sysbardisable (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (sysbardisable));


  // broadcastinner implies broadcastouter

  assert_implication #(`OVL_FATAL, INOPTIONS, "broadcastinner  => broadcastouter")
  u_ovl_intf_assume_cc0fe04802148a2996608e6db1687099b0e72f51 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (broadcastinner ),
    .consequent_expr (broadcastouter));


  //----------------------------------------------------------------------------
  // Misc signals
  //----------------------------------------------------------------------------

  //  output         nexterrirq          valid always          timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "nexterrirq X or Z")
  u_ovl_intf_x_nexterrirq (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (nexterrirq));

  //  output         ninterrirq          valid always          timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "ninterrirq X or Z")
  u_ovl_intf_x_ninterrirq (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ninterrirq));


  //  input          acinactm            valid ext_sclken@1    timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "acinactm X or Z")
  u_ovl_intf_x_acinactm (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_sclken_reg),
    .test_expr (acinactm));


  //  input          scu_ext_aclken      valid always          timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_ext_aclken X or Z")
  u_ovl_intf_x_scu_ext_aclken (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_ext_aclken));

  //  input          ext_sclken          valid always          timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_sclken X or Z")
  u_ovl_intf_x_ext_sclken (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_sclken));

  //  input          ext_sinact          valid ext_sclken@1    timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_sinact X or Z")
  u_ovl_intf_x_ext_sinact (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_sclken_reg),
    .test_expr (ext_sinact));


  //  output         standbywfil2        valid always          timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "standbywfil2 X or Z")
  u_ovl_intf_x_standbywfil2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (standbywfil2));


  //  input          l2flushreq          valid always          timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "l2flushreq X or Z")
  u_ovl_intf_x_l2flushreq (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (l2flushreq));

  //  output         l2flushdone         valid always          timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "l2flushdone X or Z")
  u_ovl_intf_x_l2flushdone (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (l2flushdone));


  // Flush done must only be asserted in response to a request, but the
  // request takes 2 cycles to propagate through the synchroniser.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "l2flushdone  => l2flushreq@4")
  u_ovl_intf_assert_b89a196fd4092059270cac6b56fadd3786b96db6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2flushdone ),
    .consequent_expr (l2flushreq_reg_reg_reg_reg));


  // Once set, flush done must remain asserted until the request is dropped.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "l2flushdone@1 & l2flushreq@1 & l2flushreq@2 & l2flushreq@3  => l2flushdone")
  u_ovl_intf_assert_936ca7cceb0be692db123d0ccae5195eb89bc3c2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (l2flushdone_reg & l2flushreq_reg & l2flushreq_reg_reg & l2flushreq_reg_reg_reg ),
    .consequent_expr (l2flushdone));


  //----------------------------------------------------------------------------
  // ACE interface
  //----------------------------------------------------------------------------

  //  output         scu_ext_ar_valid  valid always                               timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_ext_ar_valid X or Z")
  u_ovl_intf_x_scu_ext_ar_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_ext_ar_valid));

  //  input          scu_ext_ar_ready  valid scu_ext_aclken@1                     timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_ext_ar_ready X or Z")
  u_ovl_intf_x_scu_ext_ar_ready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_aclken_reg),
    .test_expr (scu_ext_ar_ready));

  //  output [5:0]   scu_ext_ar_id     valid scu_ext_ar_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 6, OUTOPTIONS, "scu_ext_ar_id X or Z")
  u_ovl_intf_x_scu_ext_ar_id (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_ar_valid),
    .test_expr (scu_ext_ar_id));

  //  output [43:0]  scu_ext_ar_addr   valid scu_ext_ar_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 44, OUTOPTIONS, "scu_ext_ar_addr X or Z")
  u_ovl_intf_x_scu_ext_ar_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_ar_valid),
    .test_expr (scu_ext_ar_addr));

  //  output [7:0]   scu_ext_ar_len    valid scu_ext_ar_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "scu_ext_ar_len X or Z")
  u_ovl_intf_x_scu_ext_ar_len (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_ar_valid),
    .test_expr (scu_ext_ar_len));

  //  output [2:0]   scu_ext_ar_size   valid scu_ext_ar_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 3, OUTOPTIONS, "scu_ext_ar_size X or Z")
  u_ovl_intf_x_scu_ext_ar_size (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_ar_valid),
    .test_expr (scu_ext_ar_size));

  //  output [1:0]   scu_ext_ar_burst  valid scu_ext_ar_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "scu_ext_ar_burst X or Z")
  u_ovl_intf_x_scu_ext_ar_burst (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_ar_valid),
    .test_expr (scu_ext_ar_burst));

  //  output         scu_ext_ar_lock   valid scu_ext_ar_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_ext_ar_lock X or Z")
  u_ovl_intf_x_scu_ext_ar_lock (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_ar_valid),
    .test_expr (scu_ext_ar_lock));

  //  output [3:0]   scu_ext_ar_cache  valid scu_ext_ar_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "scu_ext_ar_cache X or Z")
  u_ovl_intf_x_scu_ext_ar_cache (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_ar_valid),
    .test_expr (scu_ext_ar_cache));

  //  output [2:0]   scu_ext_ar_prot   valid scu_ext_ar_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 3, OUTOPTIONS, "scu_ext_ar_prot X or Z")
  u_ovl_intf_x_scu_ext_ar_prot (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_ar_valid),
    .test_expr (scu_ext_ar_prot));

  //  output [3:0]   scu_ext_ar_snoop  valid scu_ext_ar_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "scu_ext_ar_snoop X or Z")
  u_ovl_intf_x_scu_ext_ar_snoop (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_ar_valid),
    .test_expr (scu_ext_ar_snoop));

  //  output [1:0]   scu_ext_ar_domain valid scu_ext_ar_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "scu_ext_ar_domain X or Z")
  u_ovl_intf_x_scu_ext_ar_domain (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_ar_valid),
    .test_expr (scu_ext_ar_domain));

  //  output [1:0]   scu_ext_ar_bar    valid scu_ext_ar_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "scu_ext_ar_bar X or Z")
  u_ovl_intf_x_scu_ext_ar_bar (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_ar_valid),
    .test_expr (scu_ext_ar_bar));

  //  output [7:0]   scu_ext_rdmemattr valid scu_ext_ar_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "scu_ext_rdmemattr X or Z")
  u_ovl_intf_x_scu_ext_rdmemattr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_ar_valid),
    .test_expr (scu_ext_rdmemattr));


  //  input          scu_ext_dr_valid  valid scu_ext_aclken@1                     timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_ext_dr_valid X or Z")
  u_ovl_intf_x_scu_ext_dr_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_aclken_reg),
    .test_expr (scu_ext_dr_valid));

  //  output         scu_ext_dr_ready  valid always                               timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_ext_dr_ready X or Z")
  u_ovl_intf_x_scu_ext_dr_ready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_ext_dr_ready));

  //  input  [5:0]   scu_ext_dr_id     valid scu_ext_dr_valid & scu_ext_aclken@1  timing 70%

  assert_never_unknown #(`OVL_FATAL, 6, INOPTIONS, "scu_ext_dr_id X or Z")
  u_ovl_intf_x_scu_ext_dr_id (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_dr_valid & scu_ext_aclken_reg),
    .test_expr (scu_ext_dr_id));

  //  input  [3:0]   scu_ext_dr_resp   valid scu_ext_dr_valid & scu_ext_aclken@1  timing 70%

  assert_never_unknown #(`OVL_FATAL, 4, INOPTIONS, "scu_ext_dr_resp X or Z")
  u_ovl_intf_x_scu_ext_dr_resp (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_dr_valid & scu_ext_aclken_reg),
    .test_expr (scu_ext_dr_resp));

  //  input  [127:0] scu_ext_dr_data   valid scu_ext_dr_valid & scu_ext_aclken@1  timing 70%

  assert_never_unknown #(`OVL_FATAL, 128, INOPTIONS, "scu_ext_dr_data X or Z")
  u_ovl_intf_x_scu_ext_dr_data (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_dr_valid & scu_ext_aclken_reg),
    .test_expr (scu_ext_dr_data));

  //  input          scu_ext_dr_last   valid scu_ext_dr_valid & scu_ext_aclken@1  timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_ext_dr_last X or Z")
  u_ovl_intf_x_scu_ext_dr_last (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_dr_valid & scu_ext_aclken_reg),
    .test_expr (scu_ext_dr_last));


  //  output         scu_ext_aw_valid  valid always                               timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_ext_aw_valid X or Z")
  u_ovl_intf_x_scu_ext_aw_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_ext_aw_valid));

  //  input          scu_ext_aw_ready  valid scu_ext_aclken@1                     timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_ext_aw_ready X or Z")
  u_ovl_intf_x_scu_ext_aw_ready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_aclken_reg),
    .test_expr (scu_ext_aw_ready));

  //  output [4:0]   scu_ext_aw_id     valid scu_ext_aw_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "scu_ext_aw_id X or Z")
  u_ovl_intf_x_scu_ext_aw_id (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_aw_valid),
    .test_expr (scu_ext_aw_id));

  //  output [43:0]  scu_ext_aw_addr   valid scu_ext_aw_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 44, OUTOPTIONS, "scu_ext_aw_addr X or Z")
  u_ovl_intf_x_scu_ext_aw_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_aw_valid),
    .test_expr (scu_ext_aw_addr));

  //  output [7:0]   scu_ext_aw_len    valid scu_ext_aw_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "scu_ext_aw_len X or Z")
  u_ovl_intf_x_scu_ext_aw_len (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_aw_valid),
    .test_expr (scu_ext_aw_len));

  //  output [2:0]   scu_ext_aw_size   valid scu_ext_aw_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 3, OUTOPTIONS, "scu_ext_aw_size X or Z")
  u_ovl_intf_x_scu_ext_aw_size (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_aw_valid),
    .test_expr (scu_ext_aw_size));

  //  output [1:0]   scu_ext_aw_burst  valid scu_ext_aw_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "scu_ext_aw_burst X or Z")
  u_ovl_intf_x_scu_ext_aw_burst (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_aw_valid),
    .test_expr (scu_ext_aw_burst));

  //  output         scu_ext_aw_lock   valid scu_ext_aw_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_ext_aw_lock X or Z")
  u_ovl_intf_x_scu_ext_aw_lock (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_aw_valid),
    .test_expr (scu_ext_aw_lock));

  //  output [3:0]   scu_ext_aw_cache  valid scu_ext_aw_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 4, OUTOPTIONS, "scu_ext_aw_cache X or Z")
  u_ovl_intf_x_scu_ext_aw_cache (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_aw_valid),
    .test_expr (scu_ext_aw_cache));

  //  output [2:0]   scu_ext_aw_prot   valid scu_ext_aw_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 3, OUTOPTIONS, "scu_ext_aw_prot X or Z")
  u_ovl_intf_x_scu_ext_aw_prot (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_aw_valid),
    .test_expr (scu_ext_aw_prot));

  //  output [2:0]   scu_ext_aw_snoop  valid scu_ext_aw_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 3, OUTOPTIONS, "scu_ext_aw_snoop X or Z")
  u_ovl_intf_x_scu_ext_aw_snoop (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_aw_valid),
    .test_expr (scu_ext_aw_snoop));

  //  output [1:0]   scu_ext_aw_domain valid scu_ext_aw_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "scu_ext_aw_domain X or Z")
  u_ovl_intf_x_scu_ext_aw_domain (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_aw_valid),
    .test_expr (scu_ext_aw_domain));

  //  output [1:0]   scu_ext_aw_bar    valid scu_ext_aw_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "scu_ext_aw_bar X or Z")
  u_ovl_intf_x_scu_ext_aw_bar (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_aw_valid),
    .test_expr (scu_ext_aw_bar));

  //  output         scu_ext_aw_unique valid scu_ext_aw_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_ext_aw_unique X or Z")
  u_ovl_intf_x_scu_ext_aw_unique (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_aw_valid),
    .test_expr (scu_ext_aw_unique));

  //  output [7:0]   scu_ext_wrmemattr valid scu_ext_aw_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "scu_ext_wrmemattr X or Z")
  u_ovl_intf_x_scu_ext_wrmemattr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_aw_valid),
    .test_expr (scu_ext_wrmemattr));


  //  output         scu_ext_dw_valid  valid always                               timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_ext_dw_valid X or Z")
  u_ovl_intf_x_scu_ext_dw_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_ext_dw_valid));

  //  input          scu_ext_dw_ready  valid scu_ext_aclken@1                     timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_ext_dw_ready X or Z")
  u_ovl_intf_x_scu_ext_dw_ready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_aclken_reg),
    .test_expr (scu_ext_dw_ready));

  //  output [4:0]   scu_ext_dw_id     valid scu_ext_dw_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "scu_ext_dw_id X or Z")
  u_ovl_intf_x_scu_ext_dw_id (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_dw_valid),
    .test_expr (scu_ext_dw_id));

  //  output [15:0]  scu_ext_dw_strb   valid scu_ext_dw_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 16, OUTOPTIONS, "scu_ext_dw_strb X or Z")
  u_ovl_intf_x_scu_ext_dw_strb (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_dw_valid),
    .test_expr (scu_ext_dw_strb));

  //  output [127:0] scu_ext_dw_data   valid scu_ext_dw_valid strobes 8 scu_ext_dw_strb timing 30%

  generate if (1) begin : expand_strobes_57
    genvar i;
    for (i = 0; (i * (8)) < (128); i = i + 1) begin : loop
      assign expanded_strobes_57[i*(8)+:8] = {(8){scu_ext_dw_strb[i]}};
    end
  end endgenerate

  assert_never_unknown #(`OVL_FATAL, 128, OUTOPTIONS, "scu_ext_dw_data & expanded_strobes_57 X or Z")
  u_ovl_intf_x_0b71030cd0fc9c164cb45ad48cb360b0016bf762 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_dw_valid ),
    .test_expr (scu_ext_dw_data & expanded_strobes_57));

  //  output         scu_ext_dw_last   valid scu_ext_dw_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_ext_dw_last X or Z")
  u_ovl_intf_x_scu_ext_dw_last (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_dw_valid),
    .test_expr (scu_ext_dw_last));


  //  input          scu_ext_db_valid  valid scu_ext_aclken@1                     timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_ext_db_valid X or Z")
  u_ovl_intf_x_scu_ext_db_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_aclken_reg),
    .test_expr (scu_ext_db_valid));

  //  output         scu_ext_db_ready  valid always                               timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_ext_db_ready X or Z")
  u_ovl_intf_x_scu_ext_db_ready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_ext_db_ready));

  //  input [4:0]    scu_ext_db_id     valid scu_ext_db_valid & scu_ext_aclken@1  timing 70%

  assert_never_unknown #(`OVL_FATAL, 5, INOPTIONS, "scu_ext_db_id X or Z")
  u_ovl_intf_x_scu_ext_db_id (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_db_valid & scu_ext_aclken_reg),
    .test_expr (scu_ext_db_id));

  //  input [1:0]    scu_ext_db_resp   valid scu_ext_db_valid & scu_ext_aclken@1  timing 70%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "scu_ext_db_resp X or Z")
  u_ovl_intf_x_scu_ext_db_resp (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_db_valid & scu_ext_aclken_reg),
    .test_expr (scu_ext_db_resp));


  //  input          scu_ext_ac_valid  valid scu_ext_aclken@1                     timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_ext_ac_valid X or Z")
  u_ovl_intf_x_scu_ext_ac_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_aclken_reg),
    .test_expr (scu_ext_ac_valid));

  //  output         scu_ext_ac_ready  valid always                               timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_ext_ac_ready X or Z")
  u_ovl_intf_x_scu_ext_ac_ready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_ext_ac_ready));

  //  input [3:0]    scu_ext_ac_snoop  valid scu_ext_ac_valid & scu_ext_aclken@1  timing 70%

  assert_never_unknown #(`OVL_FATAL, 4, INOPTIONS, "scu_ext_ac_snoop X or Z")
  u_ovl_intf_x_scu_ext_ac_snoop (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_ac_valid & scu_ext_aclken_reg),
    .test_expr (scu_ext_ac_snoop));

  //  input [43:0]   scu_ext_ac_addr   valid scu_ext_ac_valid & scu_ext_aclken@1  timing 70%

  assert_never_unknown #(`OVL_FATAL, 44, INOPTIONS, "scu_ext_ac_addr X or Z")
  u_ovl_intf_x_scu_ext_ac_addr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_ac_valid & scu_ext_aclken_reg),
    .test_expr (scu_ext_ac_addr));

  //  input [2:0]    scu_ext_ac_prot   valid scu_ext_ac_valid & scu_ext_aclken@1  timing 70%

  assert_never_unknown #(`OVL_FATAL, 3, INOPTIONS, "scu_ext_ac_prot X or Z")
  u_ovl_intf_x_scu_ext_ac_prot (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_ac_valid & scu_ext_aclken_reg),
    .test_expr (scu_ext_ac_prot));


  //  output         scu_ext_cr_valid  valid always                               timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_ext_cr_valid X or Z")
  u_ovl_intf_x_scu_ext_cr_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_ext_cr_valid));

  //  input          scu_ext_cr_ready  valid scu_ext_aclken@1                     timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_ext_cr_ready X or Z")
  u_ovl_intf_x_scu_ext_cr_ready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_aclken_reg),
    .test_expr (scu_ext_cr_ready));

  //  output [4:0]   scu_ext_cr_resp   valid scu_ext_cr_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "scu_ext_cr_resp X or Z")
  u_ovl_intf_x_scu_ext_cr_resp (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_cr_valid),
    .test_expr (scu_ext_cr_resp));


  //  output         scu_ext_cd_valid  valid always                               timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_ext_cd_valid X or Z")
  u_ovl_intf_x_scu_ext_cd_valid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_ext_cd_valid));

  //  input          scu_ext_cd_ready  valid scu_ext_aclken@1                     timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "scu_ext_cd_ready X or Z")
  u_ovl_intf_x_scu_ext_cd_ready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_aclken_reg),
    .test_expr (scu_ext_cd_ready));

  //  output [127:0] scu_ext_cd_data   valid scu_ext_cd_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 128, OUTOPTIONS, "scu_ext_cd_data X or Z")
  u_ovl_intf_x_scu_ext_cd_data (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_cd_valid),
    .test_expr (scu_ext_cd_data));

  //  output         scu_ext_cd_last   valid scu_ext_cd_valid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_ext_cd_last X or Z")
  u_ovl_intf_x_scu_ext_cd_last (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_ext_cd_valid),
    .test_expr (scu_ext_cd_last));


  //  output         scu_ext_rack      valid always                               timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_ext_rack X or Z")
  u_ovl_intf_x_scu_ext_rack (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_ext_rack));

  //  output         scu_ext_wack      valid always                               timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_ext_wack X or Z")
  u_ovl_intf_x_scu_ext_wack (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_ext_wack));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    out_of_reset <= 1'b0;
  else
    out_of_reset <= 1'b1;


  // Outputs must not change when aclken is low

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_ar_valid === scu_ext_ar_valid@1")
  u_ovl_intf_assert_01fba8216908ef252beef178007be51a9ebb0d7a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_ar_valid === scu_ext_ar_valid_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_ar_id === scu_ext_ar_id@1")
  u_ovl_intf_assert_72a1fc3ceb61d5e694bb3fd383eb8605d4768a19 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_ar_id === scu_ext_ar_id_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_ar_addr === scu_ext_ar_addr@1")
  u_ovl_intf_assert_903cb927bd4b11ed70e2215eb059afe1463b8244 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_ar_addr === scu_ext_ar_addr_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_ar_len === scu_ext_ar_len@1")
  u_ovl_intf_assert_320ac804ac46bfee0fe62ec73ddb5df39448f61f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_ar_len === scu_ext_ar_len_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_ar_size === scu_ext_ar_size@1")
  u_ovl_intf_assert_4ad6560687d5a7bf25b996d184678a01bf4c4f8d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_ar_size === scu_ext_ar_size_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_ar_burst === scu_ext_ar_burst@1")
  u_ovl_intf_assert_b0e1615101d8d1281f0093a0c00b042535c3aef1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_ar_burst === scu_ext_ar_burst_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_ar_lock === scu_ext_ar_lock@1")
  u_ovl_intf_assert_fdc67368dff87b593ea40c0bc72209d8c5ffbe72 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_ar_lock === scu_ext_ar_lock_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_ar_cache === scu_ext_ar_cache@1")
  u_ovl_intf_assert_57ca200cd49f4a371876f78e51d6f54450be22e4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_ar_cache === scu_ext_ar_cache_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_ar_prot === scu_ext_ar_prot@1")
  u_ovl_intf_assert_75ea2699b77f955ed33ff049d01042a9b379dae5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_ar_prot === scu_ext_ar_prot_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_ar_snoop === scu_ext_ar_snoop@1")
  u_ovl_intf_assert_0d7f33cafe3f2450c1f64ff7301ff8cf78a1f7d4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_ar_snoop === scu_ext_ar_snoop_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_ar_domain === scu_ext_ar_domain@1")
  u_ovl_intf_assert_cb6d57ae599a3d4eded594358a5023193585dc21 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_ar_domain === scu_ext_ar_domain_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_ar_bar === scu_ext_ar_bar@1")
  u_ovl_intf_assert_7a90020f38d075557d1d8daa8f33f2b351f47990 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_ar_bar === scu_ext_ar_bar_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_rdmemattr === scu_ext_rdmemattr@1")
  u_ovl_intf_assert_2e97520210960aa802b9e9569e2871e31dc116df (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_rdmemattr === scu_ext_rdmemattr_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_dr_ready === scu_ext_dr_ready@1")
  u_ovl_intf_assert_f91fc241185ca0c7bebf82b1bece2c2868ad40f3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_dr_ready === scu_ext_dr_ready_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_aw_valid === scu_ext_aw_valid@1")
  u_ovl_intf_assert_07ea1da29463559d8a76039f2f34d9ae254184b8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_aw_valid === scu_ext_aw_valid_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_aw_id === scu_ext_aw_id@1")
  u_ovl_intf_assert_c3c77e70404982b3cdb403de6762fe703ddeb792 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_aw_id === scu_ext_aw_id_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_aw_addr === scu_ext_aw_addr@1")
  u_ovl_intf_assert_71b4d97282af9c2f3f813db230550e8d03d8fd42 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_aw_addr === scu_ext_aw_addr_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_aw_len === scu_ext_aw_len@1")
  u_ovl_intf_assert_e50898e347b25620b1d2559317bf93d21e0a0478 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_aw_len === scu_ext_aw_len_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_aw_size === scu_ext_aw_size@1")
  u_ovl_intf_assert_6909cea8b137326faa4fd846dc0c6f54480835af (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_aw_size === scu_ext_aw_size_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_aw_burst === scu_ext_aw_burst@1")
  u_ovl_intf_assert_5ffc5b3f1cf67d8117a8b428fbb108259ef01fa9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_aw_burst === scu_ext_aw_burst_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_aw_lock === scu_ext_aw_lock@1")
  u_ovl_intf_assert_778bf4f52c03f3e8280219a78194189df3556904 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_aw_lock === scu_ext_aw_lock_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_aw_cache === scu_ext_aw_cache@1")
  u_ovl_intf_assert_cd3370ee177a4d4b4ac51e975402576368f08da0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_aw_cache === scu_ext_aw_cache_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_aw_prot === scu_ext_aw_prot@1")
  u_ovl_intf_assert_82c97e24e9549218b11b1633b032d6e77176bc9e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_aw_prot === scu_ext_aw_prot_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_aw_snoop === scu_ext_aw_snoop@1")
  u_ovl_intf_assert_e889b1c25badbffb9c9e4b89b8463439d68a7f41 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_aw_snoop === scu_ext_aw_snoop_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_aw_domain === scu_ext_aw_domain@1")
  u_ovl_intf_assert_0754d911e19db3d4ba2a9b40ad5a1ac3c5fb879c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_aw_domain === scu_ext_aw_domain_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_aw_bar === scu_ext_aw_bar@1")
  u_ovl_intf_assert_9f71791952c72288e92d377aaed00ae89c9d733b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_aw_bar === scu_ext_aw_bar_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_aw_unique === scu_ext_aw_unique@1")
  u_ovl_intf_assert_aa9cce57e353efb4f24226d09401a085dca688e1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_aw_unique === scu_ext_aw_unique_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_wrmemattr === scu_ext_wrmemattr@1")
  u_ovl_intf_assert_c709fd19a661f5431b120a9304b0860888a9d306 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_wrmemattr === scu_ext_wrmemattr_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_dw_valid === scu_ext_dw_valid@1")
  u_ovl_intf_assert_00d9d51388a47ecdf7eba4211b6a1f491b948726 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_dw_valid === scu_ext_dw_valid_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_dw_id === scu_ext_dw_id@1")
  u_ovl_intf_assert_3fc3268aaa96405eba01c8b82434528e4c7d0655 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_dw_id === scu_ext_dw_id_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_dw_strb === scu_ext_dw_strb@1")
  u_ovl_intf_assert_0359b620ac7f5ecdd913dd5787d0d0eac5b9f05f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_dw_strb === scu_ext_dw_strb_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_dw_data === scu_ext_dw_data@1")
  u_ovl_intf_assert_8e076874e1bc57e07bad02b079c7196d8678c7ea (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_dw_data === scu_ext_dw_data_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_dw_last === scu_ext_dw_last@1")
  u_ovl_intf_assert_ce8783f0f9246beaaba9610ff970653b41cd482a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_dw_last === scu_ext_dw_last_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_db_ready === scu_ext_db_ready@1")
  u_ovl_intf_assert_8938734a3a691db6b89bb0af02323dd5072a96ff (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_db_ready === scu_ext_db_ready_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_ac_ready === scu_ext_ac_ready@1")
  u_ovl_intf_assert_78d7be9e13e1f74cc2abecc446fd2f7e870a0db4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_ac_ready === scu_ext_ac_ready_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_cr_valid === scu_ext_cr_valid@1")
  u_ovl_intf_assert_8d339a0b0ab8cdfb8923df0021a6b31ff9c52c63 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_cr_valid === scu_ext_cr_valid_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_cr_resp === scu_ext_cr_resp@1")
  u_ovl_intf_assert_51c9daa7794a4739c20c7ee3ea3e489f5e3b4730 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_cr_resp === scu_ext_cr_resp_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_cd_valid === scu_ext_cd_valid@1")
  u_ovl_intf_assert_95073725df3b3a710791ed65b7053342c81965e9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_cd_valid === scu_ext_cd_valid_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_cd_data === scu_ext_cd_data@1")
  u_ovl_intf_assert_aab5ba0b2e1f9d98c1adaa26c067c4eb6fcba4c7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_cd_data === scu_ext_cd_data_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_cd_last === scu_ext_cd_last@1")
  u_ovl_intf_assert_8d7c4332732991c75236dc83127f6f965bd8f7cc (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_cd_last === scu_ext_cd_last_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_rack === scu_ext_rack@1")
  u_ovl_intf_assert_1e505ef2cd26e0ad055dd4e30a20f3a6c3dca6a9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_rack === scu_ext_rack_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_ext_aclken@2 & out_of_reset@1  => scu_ext_wack === scu_ext_wack@1")
  u_ovl_intf_assert_bbb041e61c2ba4c518641016b32442f7a712ebc0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_ext_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_ext_wack === scu_ext_wack_reg));


  // Barriers may only use specific IDs
  assign bar_ar_id  = {scu_ext_ar_id == 6'b001001, scu_ext_ar_id == 6'b000111, scu_ext_ar_id == 6'b000110, scu_ext_ar_id == 6'b000101, scu_ext_ar_id == 6'b000100};


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_ext_ar_valid & (scu_ext_ar_bar != 2'b00)  => |bar_ar_id")
  u_ovl_intf_assert_362a6356a9a14a85f0b2f588fa45eee721ab607c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_ext_ar_valid & (scu_ext_ar_bar != 2'b00) ),
    .consequent_expr (|bar_ar_id));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_ext_ar_valid & |bar_ar_id[3:0]  => (scu_ext_ar_bar != 2'b00)")
  u_ovl_intf_assert_1a3d8cfa1d463067d3b0c9b7474817402c579d3f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_ext_ar_valid & |bar_ar_id[3:0] ),
    .consequent_expr ((scu_ext_ar_bar != 2'b00)));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    ar_outstanding <= {64{1'b0}};
  else if (scu_ext_aclken_reg)
    ar_outstanding <= ((ar_outstanding | ({64{scu_ext_ar_valid & scu_ext_ar_ready}} & (64'h1 << scu_ext_ar_id))) & ~({64{scu_ext_dr_valid & scu_ext_dr_ready & scu_ext_dr_last}} & (64'h1 << scu_ext_dr_id)));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    dvm_outstanding <= {64{1'b0}};
  else if (scu_ext_aclken_reg)
    dvm_outstanding <= ((dvm_outstanding | ({64{scu_ext_ar_valid & scu_ext_ar_ready & (scu_ext_ar_snoop == 4'b1111)}} & (64'h1 << scu_ext_ar_id))) & ~({64{scu_ext_dr_valid & scu_ext_dr_ready & scu_ext_dr_last}} & (64'h1 << scu_ext_dr_id)));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    aw_outstanding <= {32{1'b0}};
  else if (scu_ext_aclken_reg)
    aw_outstanding <= ((aw_outstanding | ({64{scu_ext_aw_valid & scu_ext_aw_ready}} & (32'h1 << scu_ext_aw_id))) & ~({64{scu_ext_db_valid & scu_ext_db_ready}} & (32'h1 << scu_ext_db_id)));


  // Only some device accesses may have more than one outstanding transaction per ID.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_ext_ar_valid & (scu_ext_ar_id[5:2] != 4'b0000)  => (~ar_outstanding[scu_ext_ar_id] | ((scu_ext_ar_snoop == 4'b1111) & dvm_outstanding[scu_ext_ar_id]))")
  u_ovl_intf_assert_3d434f250b1c04fb39efc1644cfbd2669a9dfa4c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_ext_ar_valid & (scu_ext_ar_id[5:2] != 4'b0000) ),
    .consequent_expr ((~ar_outstanding[scu_ext_ar_id] | ((scu_ext_ar_snoop == 4'b1111) & dvm_outstanding[scu_ext_ar_id]))));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_ext_ar_valid & (scu_ext_ar_id[5:2] == 4'b0000)  => (scu_ext_ar_cache in [4'b0000, 4'b0001]) | scu_ext_ar_lock")
  u_ovl_intf_assert_7b3d3e665a014593840f4dca17c86c9e3944abd6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_ext_ar_valid & (scu_ext_ar_id[5:2] == 4'b0000) ),
    .consequent_expr ((((scu_ext_ar_cache == 4'b0000) | (scu_ext_ar_cache ==  4'b0001))) | scu_ext_ar_lock));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_ext_aw_valid & (scu_ext_aw_id[4:2] != 3'b011)  => ~aw_outstanding[scu_ext_aw_id]")
  u_ovl_intf_assert_becf0a43f872d00d4adda80d453fcec1b82970bb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_ext_aw_valid & (scu_ext_aw_id[4:2] != 3'b011) ),
    .consequent_expr (~aw_outstanding[scu_ext_aw_id]));



  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_ext_aw_valid & (scu_ext_aw_id[4:2] == 3'b011)  => scu_ext_aw_cache in [4'b0000, 4'b0001]")
  u_ovl_intf_assert_fad791c2eb1b9a1d6af4055051de98bca17ea5d4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_ext_aw_valid & (scu_ext_aw_id[4:2] == 3'b011) ),
    .consequent_expr (((scu_ext_aw_cache == 4'b0000) | (scu_ext_aw_cache ==  4'b0001))));


  //----------------------------------------------------------------------------
  // Skyros interface
  //----------------------------------------------------------------------------

  assign txdat_valid  = {194{scu_txdatflitv}} & {{8{scu_txdatflit[65]}}, {8{scu_txdatflit[64]}}, {8{scu_txdatflit[63]}}, {8{scu_txdatflit[62]}}, {8{scu_txdatflit[61]}}, {8{scu_txdatflit[60]}}, {8{scu_txdatflit[59]}}, {8{scu_txdatflit[58]}}, {8{scu_txdatflit[57]}}, {8{scu_txdatflit[56]}}, {8{scu_txdatflit[55]}}, {8{scu_txdatflit[54]}}, {8{scu_txdatflit[53]}}, {8{scu_txdatflit[52]}}, {8{scu_txdatflit[51]}}, {8{scu_txdatflit[50]}}, {66{1'b1}}};

  assign rxdat_valid  = {194{ext_rxdatflitv & ext_sclken_reg}} & {{8{ext_rxdatflit[65]}}, {8{ext_rxdatflit[64]}}, {8{ext_rxdatflit[63]}}, {8{ext_rxdatflit[62]}}, {8{ext_rxdatflit[61]}}, {8{ext_rxdatflit[60]}}, {8{ext_rxdatflit[59]}}, {8{ext_rxdatflit[58]}}, {8{ext_rxdatflit[57]}}, {8{ext_rxdatflit[56]}}, {8{ext_rxdatflit[55]}}, {8{ext_rxdatflit[54]}}, {8{ext_rxdatflit[53]}}, {8{ext_rxdatflit[52]}}, {8{ext_rxdatflit[51]}}, {8{ext_rxdatflit[50]}}, {66{1'b1}}};

  //  input          ext_rxsactive       valid ext_sclken@1                  timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_rxsactive X or Z")
  u_ovl_intf_x_ext_rxsactive (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_sclken_reg),
    .test_expr (ext_rxsactive));

  //  output         scu_txsactive       valid always                        timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_txsactive X or Z")
  u_ovl_intf_x_scu_txsactive (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_txsactive));

  //  input          ext_rxlinkactivereq valid ext_sclken@1                  timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_rxlinkactivereq X or Z")
  u_ovl_intf_x_ext_rxlinkactivereq (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_sclken_reg),
    .test_expr (ext_rxlinkactivereq));

  //  output         scu_rxlinkactiveack valid always                        timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_rxlinkactiveack X or Z")
  u_ovl_intf_x_scu_rxlinkactiveack (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_rxlinkactiveack));

  //  output         scu_txlinkactivereq valid always                        timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_txlinkactivereq X or Z")
  u_ovl_intf_x_scu_txlinkactivereq (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_txlinkactivereq));

  //  input          ext_txlinkactiveack valid ext_sclken@1                  timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_txlinkactiveack X or Z")
  u_ovl_intf_x_ext_txlinkactiveack (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_sclken_reg),
    .test_expr (ext_txlinkactiveack));

  //  output         scu_txreqflitpend   valid always                        timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_txreqflitpend X or Z")
  u_ovl_intf_x_scu_txreqflitpend (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_txreqflitpend));

  //  output         scu_txreqflitv      valid always                        timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_txreqflitv X or Z")
  u_ovl_intf_x_scu_txreqflitv (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_txreqflitv));

  //  output [99:0]  scu_txreqflit       valid scu_txreqflitv                timing 30%

  assert_never_unknown #(`OVL_FATAL, 100, OUTOPTIONS, "scu_txreqflit X or Z")
  u_ovl_intf_x_scu_txreqflit (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_txreqflitv),
    .test_expr (scu_txreqflit));

  //  output [7:0]   scu_reqmemattr      valid scu_txreqflitv                timing 30%

  assert_never_unknown #(`OVL_FATAL, 8, OUTOPTIONS, "scu_reqmemattr X or Z")
  u_ovl_intf_x_scu_reqmemattr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_txreqflitv),
    .test_expr (scu_reqmemattr));

  //  input          ext_txreqlcrdv      valid ext_sclken@1                  timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_txreqlcrdv X or Z")
  u_ovl_intf_x_ext_txreqlcrdv (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_sclken_reg),
    .test_expr (ext_txreqlcrdv));

  //  output         scu_txrspflitpend   valid always                        timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_txrspflitpend X or Z")
  u_ovl_intf_x_scu_txrspflitpend (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_txrspflitpend));

  //  output         scu_txrspflitv      valid always                        timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_txrspflitv X or Z")
  u_ovl_intf_x_scu_txrspflitv (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_txrspflitv));

  //  output [44:0]  scu_txrspflit       valid scu_txrspflitv                timing 30%

  assert_never_unknown #(`OVL_FATAL, 45, OUTOPTIONS, "scu_txrspflit X or Z")
  u_ovl_intf_x_scu_txrspflit (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_txrspflitv),
    .test_expr (scu_txrspflit));

  //  input          ext_txrsplcrdv      valid ext_sclken@1                  timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_txrsplcrdv X or Z")
  u_ovl_intf_x_ext_txrsplcrdv (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_sclken_reg),
    .test_expr (ext_txrsplcrdv));

  //  output         scu_txdatflitpend   valid always                        timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_txdatflitpend X or Z")
  u_ovl_intf_x_scu_txdatflitpend (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_txdatflitpend));

  //  output         scu_txdatflitv      valid always                        timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_txdatflitv X or Z")
  u_ovl_intf_x_scu_txdatflitv (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_txdatflitv));

  //  output [193:0] scu_txdatflit       valid mask txdat_valid              timing 30%

  assert_never_unknown #(`OVL_FATAL, 194, OUTOPTIONS, "scu_txdatflit & (txdat_valid) X or Z")
  u_ovl_intf_x_9ed869916f28b4ea0d819934b5f68269690f782d (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_txdatflit & (txdat_valid)));

  //  input          ext_txdatlcrdv      valid ext_sclken@1                  timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_txdatlcrdv X or Z")
  u_ovl_intf_x_ext_txdatlcrdv (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_sclken_reg),
    .test_expr (ext_txdatlcrdv));

  //  input          ext_rxsnpflitpend   valid ext_sclken@1                  timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_rxsnpflitpend X or Z")
  u_ovl_intf_x_ext_rxsnpflitpend (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_sclken_reg),
    .test_expr (ext_rxsnpflitpend));

  //  input          ext_rxsnpflitv      valid ext_sclken@1                  timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_rxsnpflitv X or Z")
  u_ovl_intf_x_ext_rxsnpflitv (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_sclken_reg),
    .test_expr (ext_rxsnpflitv));

  //  input [64:0]   ext_rxsnpflit       valid ext_rxsnpflitv & ext_sclken@1 timing 70%

  assert_never_unknown #(`OVL_FATAL, 65, INOPTIONS, "ext_rxsnpflit X or Z")
  u_ovl_intf_x_ext_rxsnpflit (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_rxsnpflitv & ext_sclken_reg),
    .test_expr (ext_rxsnpflit));

  //  output         scu_rxsnplcrdv      valid always                        timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_rxsnplcrdv X or Z")
  u_ovl_intf_x_scu_rxsnplcrdv (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_rxsnplcrdv));

  //  input          ext_rxrspflitpend   valid ext_sclken@1                  timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_rxrspflitpend X or Z")
  u_ovl_intf_x_ext_rxrspflitpend (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_sclken_reg),
    .test_expr (ext_rxrspflitpend));

  //  input          ext_rxrspflitv      valid ext_sclken@1                  timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_rxrspflitv X or Z")
  u_ovl_intf_x_ext_rxrspflitv (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_sclken_reg),
    .test_expr (ext_rxrspflitv));

  //  input [44:0]   ext_rxrspflit       valid ext_rxrspflitv & ext_sclken@1 timing 70%

  assert_never_unknown #(`OVL_FATAL, 45, INOPTIONS, "ext_rxrspflit X or Z")
  u_ovl_intf_x_ext_rxrspflit (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_rxrspflitv & ext_sclken_reg),
    .test_expr (ext_rxrspflit));

  //  output         scu_rxrsplcrdv      valid always                        timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_rxrsplcrdv X or Z")
  u_ovl_intf_x_scu_rxrsplcrdv (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_rxrsplcrdv));

  //  input          ext_rxdatflitpend   valid ext_sclken@1                  timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_rxdatflitpend X or Z")
  u_ovl_intf_x_ext_rxdatflitpend (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_sclken_reg),
    .test_expr (ext_rxdatflitpend));

  //  input          ext_rxdatflitv      valid ext_sclken@1                  timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_rxdatflitv X or Z")
  u_ovl_intf_x_ext_rxdatflitv (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_sclken_reg),
    .test_expr (ext_rxdatflitv));

  //  input [193:0]  ext_rxdatflit       valid mask rxdat_valid              timing 70%

  assert_never_unknown #(`OVL_FATAL, 194, INOPTIONS, "ext_rxdatflit & (rxdat_valid) X or Z")
  u_ovl_intf_x_caf20b9337b32373399338c3d7b68c58ddc0a219 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_rxdatflit & (rxdat_valid)));

  //  output         scu_rxdatlcrdv      valid always                        timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_rxdatlcrdv X or Z")
  u_ovl_intf_x_scu_rxdatlcrdv (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_rxdatlcrdv));


  // System address map configuration tie offs
  //  input [1:0]    ext_samaddrmap0     valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "ext_samaddrmap0 X or Z")
  u_ovl_intf_x_ext_samaddrmap0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samaddrmap0));

  //  input [1:0]    ext_samaddrmap1     valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "ext_samaddrmap1 X or Z")
  u_ovl_intf_x_ext_samaddrmap1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samaddrmap1));

  //  input [1:0]    ext_samaddrmap2     valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "ext_samaddrmap2 X or Z")
  u_ovl_intf_x_ext_samaddrmap2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samaddrmap2));

  //  input [1:0]    ext_samaddrmap3     valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "ext_samaddrmap3 X or Z")
  u_ovl_intf_x_ext_samaddrmap3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samaddrmap3));

  //  input [1:0]    ext_samaddrmap4     valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "ext_samaddrmap4 X or Z")
  u_ovl_intf_x_ext_samaddrmap4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samaddrmap4));

  //  input [1:0]    ext_samaddrmap5     valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "ext_samaddrmap5 X or Z")
  u_ovl_intf_x_ext_samaddrmap5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samaddrmap5));

  //  input [1:0]    ext_samaddrmap6     valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "ext_samaddrmap6 X or Z")
  u_ovl_intf_x_ext_samaddrmap6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samaddrmap6));

  //  input [1:0]    ext_samaddrmap7     valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "ext_samaddrmap7 X or Z")
  u_ovl_intf_x_ext_samaddrmap7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samaddrmap7));

  //  input [1:0]    ext_samaddrmap8     valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "ext_samaddrmap8 X or Z")
  u_ovl_intf_x_ext_samaddrmap8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samaddrmap8));

  //  input [1:0]    ext_samaddrmap9     valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "ext_samaddrmap9 X or Z")
  u_ovl_intf_x_ext_samaddrmap9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samaddrmap9));

  //  input [1:0]    ext_samaddrmap10    valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "ext_samaddrmap10 X or Z")
  u_ovl_intf_x_ext_samaddrmap10 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samaddrmap10));

  //  input [1:0]    ext_samaddrmap11    valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "ext_samaddrmap11 X or Z")
  u_ovl_intf_x_ext_samaddrmap11 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samaddrmap11));

  //  input [1:0]    ext_samaddrmap12    valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "ext_samaddrmap12 X or Z")
  u_ovl_intf_x_ext_samaddrmap12 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samaddrmap12));

  //  input [1:0]    ext_samaddrmap13    valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "ext_samaddrmap13 X or Z")
  u_ovl_intf_x_ext_samaddrmap13 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samaddrmap13));

  //  input [1:0]    ext_samaddrmap14    valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "ext_samaddrmap14 X or Z")
  u_ovl_intf_x_ext_samaddrmap14 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samaddrmap14));

  //  input [1:0]    ext_samaddrmap15    valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "ext_samaddrmap15 X or Z")
  u_ovl_intf_x_ext_samaddrmap15 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samaddrmap15));

  //  input [39:24]  ext_sammnbase       valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 16, INOPTIONS, "ext_sammnbase X or Z")
  u_ovl_intf_x_ext_sammnbase (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_sammnbase));

  //  input [6:0]    ext_sammnnodeid     valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 7, INOPTIONS, "ext_sammnnodeid X or Z")
  u_ovl_intf_x_ext_sammnnodeid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_sammnnodeid));

  //  input [6:0]    ext_samhni0nodeid   valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 7, INOPTIONS, "ext_samhni0nodeid X or Z")
  u_ovl_intf_x_ext_samhni0nodeid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samhni0nodeid));

  //  input [6:0]    ext_samhni1nodeid   valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 7, INOPTIONS, "ext_samhni1nodeid X or Z")
  u_ovl_intf_x_ext_samhni1nodeid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samhni1nodeid));

  //  input [6:0]    ext_samhnf0nodeid   valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 7, INOPTIONS, "ext_samhnf0nodeid X or Z")
  u_ovl_intf_x_ext_samhnf0nodeid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samhnf0nodeid));

  //  input [6:0]    ext_samhnf1nodeid   valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 7, INOPTIONS, "ext_samhnf1nodeid X or Z")
  u_ovl_intf_x_ext_samhnf1nodeid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samhnf1nodeid));

  //  input [6:0]    ext_samhnf2nodeid   valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 7, INOPTIONS, "ext_samhnf2nodeid X or Z")
  u_ovl_intf_x_ext_samhnf2nodeid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samhnf2nodeid));

  //  input [6:0]    ext_samhnf3nodeid   valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 7, INOPTIONS, "ext_samhnf3nodeid X or Z")
  u_ovl_intf_x_ext_samhnf3nodeid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samhnf3nodeid));

  //  input [6:0]    ext_samhnf4nodeid   valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 7, INOPTIONS, "ext_samhnf4nodeid X or Z")
  u_ovl_intf_x_ext_samhnf4nodeid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samhnf4nodeid));

  //  input [6:0]    ext_samhnf5nodeid   valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 7, INOPTIONS, "ext_samhnf5nodeid X or Z")
  u_ovl_intf_x_ext_samhnf5nodeid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samhnf5nodeid));

  //  input [6:0]    ext_samhnf6nodeid   valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 7, INOPTIONS, "ext_samhnf6nodeid X or Z")
  u_ovl_intf_x_ext_samhnf6nodeid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samhnf6nodeid));

  //  input [6:0]    ext_samhnf7nodeid   valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 7, INOPTIONS, "ext_samhnf7nodeid X or Z")
  u_ovl_intf_x_ext_samhnf7nodeid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samhnf7nodeid));

  //  input [2:0]    ext_samhnfmode      valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 3, INOPTIONS, "ext_samhnfmode X or Z")
  u_ovl_intf_x_ext_samhnfmode (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_samhnfmode));

  //  input [6:0]    ext_nodeid          valid always           timing 30%

  assert_never_unknown #(`OVL_FATAL, 7, INOPTIONS, "ext_nodeid X or Z")
  u_ovl_intf_x_ext_nodeid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_nodeid));




  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    txlinkactiveack_prev1 <= 1'b0;
  else if (ext_sclken_reg)
    txlinkactiveack_prev1 <= ext_txlinkactiveack;


  // Flits must only be sent in the run or deactivate states.
  // The link may enter the stop state in the same cycle as the last flit is being sent.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~txlinkactiveack_prev1  => ~scu_txreqflitv")
  u_ovl_intf_assert_3779fc37a1f96eb4e557fa4ba6f342ff2ed4d738 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~txlinkactiveack_prev1 ),
    .consequent_expr (~scu_txreqflitv));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~txlinkactiveack_prev1  => ~scu_txdatflitv")
  u_ovl_intf_assert_b855a64f2a5dbaec3df228df6d1ba6b553bfba40 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~txlinkactiveack_prev1 ),
    .consequent_expr (~scu_txdatflitv));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~txlinkactiveack_prev1  => ~scu_txrspflitv")
  u_ovl_intf_assert_a722780a7fcefaba42b88647cca95e2976a4792f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~txlinkactiveack_prev1 ),
    .consequent_expr (~scu_txrspflitv));


  // Flits sent in the deactivate state must only be credit returns.

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_txreqflitv & ~scu_txlinkactivereq  => (scu_txreqflit[30:26] == `CA53_SKYROS_REQ_LINKFLIT)")
  u_ovl_intf_assert_7b82d19e1174b3462c39ebb34106a6a360c1461a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_txreqflitv & ~scu_txlinkactivereq ),
    .consequent_expr ((scu_txreqflit[30:26] == `CA53_SKYROS_REQ_LINKFLIT)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_txdatflitv & ~scu_txlinkactivereq  => (scu_txdatflit[28:26] == `CA53_SKYROS_DAT_LINKFLIT)")
  u_ovl_intf_assert_3c6b9ded4ae47a4ec8e678b5908fff9cb3f4cb94 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_txdatflitv & ~scu_txlinkactivereq ),
    .consequent_expr ((scu_txdatflit[28:26] == `CA53_SKYROS_DAT_LINKFLIT)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_txrspflitv & ~scu_txlinkactivereq  => (scu_txrspflit[29:26] == `CA53_SKYROS_RSP_LINKFLIT)")
  u_ovl_intf_assert_ec3f87d34b1453cca99158e34544a6dc67783b0c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_txrspflitv & ~scu_txlinkactivereq ),
    .consequent_expr ((scu_txrspflit[29:26] == `CA53_SKYROS_RSP_LINKFLIT)));


  // Credits must not be received in the stop state

  assert_implication #(`OVL_FATAL, INOPTIONS, "~scu_txlinkactivereq & ~ext_txlinkactiveack & ext_sclken@1  => ~ext_txreqlcrdv")
  u_ovl_intf_assume_84cb96ea08311b687f131481d2e1e023a57b9657 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_txlinkactivereq & ~ext_txlinkactiveack & ext_sclken_reg ),
    .consequent_expr (~ext_txreqlcrdv));


  assert_implication #(`OVL_FATAL, INOPTIONS, "~scu_txlinkactivereq & ~ext_txlinkactiveack & ext_sclken@1  => ~ext_txdatlcrdv")
  u_ovl_intf_assume_79fe4f16e911d05ffd2046891f02ee40af5823d0 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_txlinkactivereq & ~ext_txlinkactiveack & ext_sclken_reg ),
    .consequent_expr (~ext_txdatlcrdv));


  assert_implication #(`OVL_FATAL, INOPTIONS, "~scu_txlinkactivereq & ~ext_txlinkactiveack & ext_sclken@1  => ~ext_txrsplcrdv")
  u_ovl_intf_assume_aac7c240f63e4a61d15bd39415f0674698b1800b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_txlinkactivereq & ~ext_txlinkactiveack & ext_sclken_reg ),
    .consequent_expr (~ext_txrsplcrdv));


  // Flits must only be received in the run or deactivate states

  assert_implication #(`OVL_FATAL, INOPTIONS, "~scu_rxlinkactiveack & ext_sclken@1  => ~ext_rxsnpflitv")
  u_ovl_intf_assume_3a4e9942b329941290c1333b0126ab2ac0fcbff8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_rxlinkactiveack & ext_sclken_reg ),
    .consequent_expr (~ext_rxsnpflitv));


  assert_implication #(`OVL_FATAL, INOPTIONS, "~scu_rxlinkactiveack & ext_sclken@1  => ~ext_rxdatflitv")
  u_ovl_intf_assume_12ee2b981ce54ac63e75b92171cc62f605ec9d46 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_rxlinkactiveack & ext_sclken_reg ),
    .consequent_expr (~ext_rxdatflitv));


  assert_implication #(`OVL_FATAL, INOPTIONS, "~scu_rxlinkactiveack & ext_sclken@1  => ~ext_rxrspflitv")
  u_ovl_intf_assume_775ebab2040ecb58d0503655575c9c62b58b3286 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_rxlinkactiveack & ext_sclken_reg ),
    .consequent_expr (~ext_rxrspflitv));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    rxlinkactivereq_prev1 <= 1'b0;
  else if (ext_sclken_reg)
    rxlinkactivereq_prev1 <= ext_rxlinkactivereq;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    rxlinkactivereq_prev2 <= 1'b0;
  else if (ext_sclken_reg)
    rxlinkactivereq_prev2 <= rxlinkactivereq_prev1;


  // Credits must only be sent in the run state, or the first two cycles of the deactivate state

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_rxlinkactiveack  => ~scu_rxsnplcrdv")
  u_ovl_intf_assert_f56f59aa937f9a177d642e71e372c7becc05bbfd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_rxlinkactiveack ),
    .consequent_expr (~scu_rxsnplcrdv));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_rxlinkactiveack  => ~scu_rxdatlcrdv")
  u_ovl_intf_assert_133e16c33e7a7564fccb68d570882349922d9fcd (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_rxlinkactiveack ),
    .consequent_expr (~scu_rxdatlcrdv));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~scu_rxlinkactiveack  => ~scu_rxrsplcrdv")
  u_ovl_intf_assert_78249490b286b03b48565f071c3f86fe924ec51c (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~scu_rxlinkactiveack ),
    .consequent_expr (~scu_rxrsplcrdv));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~rxlinkactivereq_prev1 & ~rxlinkactivereq_prev2  => ~scu_rxsnplcrdv")
  u_ovl_intf_assert_0dd063323bb6f7db614245aaaceac754b79d5dc6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~rxlinkactivereq_prev1 & ~rxlinkactivereq_prev2 ),
    .consequent_expr (~scu_rxsnplcrdv));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~rxlinkactivereq_prev1 & ~rxlinkactivereq_prev2  => ~scu_rxdatlcrdv")
  u_ovl_intf_assert_5fbb5e8aca339fa820e47f70d840003ba153ed0d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~rxlinkactivereq_prev1 & ~rxlinkactivereq_prev2 ),
    .consequent_expr (~scu_rxdatlcrdv));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~rxlinkactivereq_prev1 & ~rxlinkactivereq_prev2  => ~scu_rxrsplcrdv")
  u_ovl_intf_assert_14159cd9bb6df5f825baef7072b2aaa48209c67e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~rxlinkactivereq_prev1 & ~rxlinkactivereq_prev2 ),
    .consequent_expr (~scu_rxrsplcrdv));


  // The master must be active when it sends flits, except for link flits

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_txreqflitv & (scu_txreqflit[30:26] != `CA53_SKYROS_REQ_LINKFLIT)  => scu_txsactive")
  u_ovl_intf_assert_9f673540b36c13802e9be527e29b5447033000e2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_txreqflitv & (scu_txreqflit[30:26] != `CA53_SKYROS_REQ_LINKFLIT) ),
    .consequent_expr (scu_txsactive));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_txdatflitv & (scu_txdatflit[28:26] != `CA53_SKYROS_DAT_LINKFLIT)  => scu_txsactive")
  u_ovl_intf_assert_aab98ebfe6847ef2922b2d273d36ba8408642251 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_txdatflitv & (scu_txdatflit[28:26] != `CA53_SKYROS_DAT_LINKFLIT) ),
    .consequent_expr (scu_txsactive));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_txrspflitv & (scu_txrspflit[29:26] != `CA53_SKYROS_RSP_LINKFLIT)  => scu_txsactive")
  u_ovl_intf_assert_8b2d365ca32d25f305ce11463979beb4e6c1086e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_txrspflitv & (scu_txrspflit[29:26] != `CA53_SKYROS_RSP_LINKFLIT) ),
    .consequent_expr (scu_txsactive));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    txreq_credits <= 4'b0000;
  else if (ext_sclken_reg)
    txreq_credits <= txreq_credits + ext_txreqlcrdv - scu_txreqflitv;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    txrsp_credits <= 4'b0000;
  else if (ext_sclken_reg)
    txrsp_credits <= txrsp_credits + ext_txrsplcrdv - scu_txrspflitv;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    txdat_credits <= 4'b0000;
  else if (ext_sclken_reg)
    txdat_credits <= txdat_credits + ext_txdatlcrdv - scu_txdatflitv;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    rxsnp_credits <= 4'b0000;
  else if (ext_sclken_reg)
    rxsnp_credits <= rxsnp_credits + scu_rxsnplcrdv - ext_rxsnpflitv;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    rxrsp_credits <= 4'b0000;
  else if (ext_sclken_reg)
    rxrsp_credits <= rxrsp_credits + scu_rxrsplcrdv - ext_rxrspflitv;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    rxdat_credits <= 4'b0000;
  else if (ext_sclken_reg)
    rxdat_credits <= rxdat_credits + scu_rxdatlcrdv - ext_rxdatflitv;


  // Cannot send a flit without a credit

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_txreqflitv  => txreq_credits > 0")
  u_ovl_intf_assert_309a6d1786e892b843bf6f11be48efdf61a971d2 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_txreqflitv ),
    .consequent_expr (txreq_credits > 0));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_txrspflitv  => txrsp_credits > 0")
  u_ovl_intf_assert_68d1e6559cea01b2dd26ba1e709cfac8ac2f5d7b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_txrspflitv ),
    .consequent_expr (txrsp_credits > 0));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_txdatflitv  => txdat_credits > 0")
  u_ovl_intf_assert_4263559e378140370869303c978a5287fef53475 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_txdatflitv ),
    .consequent_expr (txdat_credits > 0));


  assert_implication #(`OVL_FATAL, INOPTIONS, "ext_rxsnpflitv & ext_sclken@1  => rxsnp_credits > 0")
  u_ovl_intf_assume_4806199e30035250ab4c514e2aabb5dbea52a390 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ext_rxsnpflitv & ext_sclken_reg ),
    .consequent_expr (rxsnp_credits > 0));


  assert_implication #(`OVL_FATAL, INOPTIONS, "ext_rxrspflitv & ext_sclken@1  => rxrsp_credits > 0")
  u_ovl_intf_assume_7af495327bab5c157a58a6f87c0c497f1cb07dea (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ext_rxrspflitv & ext_sclken_reg ),
    .consequent_expr (rxrsp_credits > 0));


  assert_implication #(`OVL_FATAL, INOPTIONS, "ext_rxdatflitv & ext_sclken@1  => rxdat_credits > 0")
  u_ovl_intf_assume_8d913803362cfddd7413f67ec2f3ff6fb7919bd8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ext_rxdatflitv & ext_sclken_reg ),
    .consequent_expr (rxdat_credits > 0));


  // Cannot send more than the maximum number of credits
  // On the TX channels, if a credit is received and the maximum number is already held, a flit must also be sent
  // in the same cycle.

  assert_implication #(`OVL_FATAL, INOPTIONS, "ext_txreqlcrdv & ext_sclken@1  => (txreq_credits < 4'b1111) | (txreq_credits == 4'b1111 & scu_txreqflitv)")
  u_ovl_intf_assume_a8d983e7d38dadc78e0517d25004c4c489e03f99 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ext_txreqlcrdv & ext_sclken_reg ),
    .consequent_expr ((txreq_credits < 4'b1111) | (txreq_credits == 4'b1111 & scu_txreqflitv)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "ext_txrsplcrdv & ext_sclken@1  => (txrsp_credits < 4'b1111) | (txrsp_credits == 4'b1111 & scu_txrspflitv)")
  u_ovl_intf_assume_c3b99b8d39534e59098a701d0c5a32334a60df44 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ext_txrsplcrdv & ext_sclken_reg ),
    .consequent_expr ((txrsp_credits < 4'b1111) | (txrsp_credits == 4'b1111 & scu_txrspflitv)));


  assert_implication #(`OVL_FATAL, INOPTIONS, "ext_txdatlcrdv & ext_sclken@1  => (txdat_credits < 4'b1111) | (txdat_credits == 4'b1111 & scu_txdatflitv)")
  u_ovl_intf_assume_8975c501d4777c5b15f05014252ad4901b82a65a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ext_txdatlcrdv & ext_sclken_reg ),
    .consequent_expr ((txdat_credits < 4'b1111) | (txdat_credits == 4'b1111 & scu_txdatflitv)));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_rxsnplcrdv  => rxsnp_credits < 4'b1010")
  u_ovl_intf_assert_e48cbe1863758a26fae3d867a0cfff1803574ceb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_rxsnplcrdv ),
    .consequent_expr (rxsnp_credits < 4'b1010));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_rxrsplcrdv  => rxrsp_credits < 4'b1111")
  u_ovl_intf_assert_f40f7d0025fccf3a718cf175c338dfba44ca703b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_rxrsplcrdv ),
    .consequent_expr (rxrsp_credits < 4'b1111));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "scu_rxdatlcrdv  => rxdat_credits < 4'b0110")
  u_ovl_intf_assert_bc244b6ac708b8af84f01196c65da01d12db5dfa (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_rxdatlcrdv ),
    .consequent_expr (rxdat_credits < 4'b0110));



  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    txreqflitpend <= 1'b0;
  else if (ext_sclken_reg)
    txreqflitpend <= scu_txreqflitpend;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    txrspflitpend <= 1'b0;
  else if (ext_sclken_reg)
    txrspflitpend <= scu_txrspflitpend;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    txdatflitpend <= 1'b0;
  else if (ext_sclken_reg)
    txdatflitpend <= scu_txdatflitpend;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    rxsnpflitpend <= 1'b0;
  else if (ext_sclken_reg)
    rxsnpflitpend <= ext_rxsnpflitpend;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    rxrspflitpend <= 1'b0;
  else if (ext_sclken_reg)
    rxrspflitpend <= ext_rxrspflitpend;


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    rxdatflitpend <= 1'b0;
  else if (ext_sclken_reg)
    rxdatflitpend <= ext_rxdatflitpend;



  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_txreqflitv & ext_sclken@1  => txreqflitpend")
  u_ovl_intf_assume_9ee9eda270040d3a1071e9642d63aff63c8af5ae (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_txreqflitv & ext_sclken_reg ),
    .consequent_expr (txreqflitpend));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_txrspflitv & ext_sclken@1  => txrspflitpend")
  u_ovl_intf_assume_4fe4e1c96bae0c7fdbaa3f50f800e2185bc0bb80 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_txrspflitv & ext_sclken_reg ),
    .consequent_expr (txrspflitpend));


  assert_implication #(`OVL_FATAL, INOPTIONS, "scu_txdatflitv & ext_sclken@1  => txdatflitpend")
  u_ovl_intf_assume_5e6c89be4f1aeadc9fc9e905255e572c527afae9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (scu_txdatflitv & ext_sclken_reg ),
    .consequent_expr (txdatflitpend));


  assert_implication #(`OVL_FATAL, INOPTIONS, "ext_rxsnpflitv & ext_sclken@1  => rxsnpflitpend")
  u_ovl_intf_assume_3b34f037dd862b918259572213cf66ed592cfefb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ext_rxsnpflitv & ext_sclken_reg ),
    .consequent_expr (rxsnpflitpend));


  assert_implication #(`OVL_FATAL, INOPTIONS, "ext_rxrspflitv & ext_sclken@1  => rxrspflitpend")
  u_ovl_intf_assume_542989102e9728c853f905b9e4e2d797b493f435 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ext_rxrspflitv & ext_sclken_reg ),
    .consequent_expr (rxrspflitpend));


  assert_implication #(`OVL_FATAL, INOPTIONS, "ext_rxdatflitv & ext_sclken@1  => rxdatflitpend")
  u_ovl_intf_assume_c404c2507e7e07687999234d811ce8a3a184cf2a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ext_rxdatflitv & ext_sclken_reg ),
    .consequent_expr (rxdatflitpend));


  // Outputs must not change when sclken is low

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_sclken@2 & out_of_reset@1  => scu_txsactive === scu_txsactive@1")
  u_ovl_intf_assert_581ce5316d8e5af4edfee44de883a3f518b51499 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_sclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_txsactive === scu_txsactive_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_sclken@2 & out_of_reset@1  => scu_rxlinkactiveack === scu_rxlinkactiveack@1")
  u_ovl_intf_assert_52a52c3e2f3fcc26a43db81b527416a1ed140952 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_sclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_rxlinkactiveack === scu_rxlinkactiveack_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_sclken@2 & out_of_reset@1  => scu_txlinkactivereq === scu_txlinkactivereq@1")
  u_ovl_intf_assert_35036dd998783f4dcb50f219b1247b2755612c46 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_sclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_txlinkactivereq === scu_txlinkactivereq_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_sclken@2 & out_of_reset@1  => scu_txreqflitpend === scu_txreqflitpend@1")
  u_ovl_intf_assert_8a3b94585a1f759864f853c24f8283104c299f42 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_sclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_txreqflitpend === scu_txreqflitpend_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_sclken@2 & out_of_reset@1  => scu_txreqflitv === scu_txreqflitv@1")
  u_ovl_intf_assert_d1f0602a2f437071a135ed53c61c8fb7713051c4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_sclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_txreqflitv === scu_txreqflitv_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_sclken@2 & out_of_reset@1  => scu_txreqflit === scu_txreqflit@1")
  u_ovl_intf_assert_89aff74d3dcaea90a1ef37f2a737844622f54ee5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_sclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_txreqflit === scu_txreqflit_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_sclken@2 & out_of_reset@1  => scu_reqmemattr === scu_reqmemattr@1")
  u_ovl_intf_assert_609e36ed9ee47c9bcb7981835060b73ea290746e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_sclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_reqmemattr === scu_reqmemattr_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_sclken@2 & out_of_reset@1  => scu_txrspflitpend === scu_txrspflitpend@1")
  u_ovl_intf_assert_77f142fd56497ccbe34258cf3a28cf3c593f811e (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_sclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_txrspflitpend === scu_txrspflitpend_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_sclken@2 & out_of_reset@1  => scu_txrspflitv === scu_txrspflitv@1")
  u_ovl_intf_assert_f199425eb057d5311912e2127af7d5f0b6a04914 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_sclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_txrspflitv === scu_txrspflitv_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_sclken@2 & out_of_reset@1  => scu_txrspflit === scu_txrspflit@1")
  u_ovl_intf_assert_600f7aa10424411a5da6b52aba7cdd955352b101 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_sclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_txrspflit === scu_txrspflit_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_sclken@2 & out_of_reset@1  => scu_txdatflitpend === scu_txdatflitpend@1")
  u_ovl_intf_assert_e5776f8e136a37eccebebfc86638df73acd524f4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_sclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_txdatflitpend === scu_txdatflitpend_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_sclken@2 & out_of_reset@1  => scu_txdatflitv === scu_txdatflitv@1")
  u_ovl_intf_assert_15efdc7abe27fe3c52a93199d7a04a57d1e030d1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_sclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_txdatflitv === scu_txdatflitv_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_sclken@2 & out_of_reset@1  => scu_txdatflit === scu_txdatflit@1")
  u_ovl_intf_assert_fd83f9a2ffd680d3ed9eb8356b02d55b9f0f7c89 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_sclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_txdatflit === scu_txdatflit_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_sclken@2 & out_of_reset@1  => scu_rxsnplcrdv === scu_rxsnplcrdv@1")
  u_ovl_intf_assert_406910c6219a802e387c331d0fc3dcfdad9d4803 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_sclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_rxsnplcrdv === scu_rxsnplcrdv_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_sclken@2 & out_of_reset@1  => scu_rxrsplcrdv === scu_rxrsplcrdv@1")
  u_ovl_intf_assert_ff68ce7028755c6baff34259519c0e5c2c2f562b (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_sclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_rxrsplcrdv === scu_rxrsplcrdv_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_sclken@2 & out_of_reset@1  => scu_rxdatlcrdv === scu_rxdatlcrdv@1")
  u_ovl_intf_assert_d937cca5b01ceaa19cfffdbdcf0dc5d2a4ae24d1 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_sclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_rxdatlcrdv === scu_rxdatlcrdv_reg));


  //----------------------------------------------------------------------------
  // ACP interface
  //----------------------------------------------------------------------------

  //  input          ext_acp_aclken      valid always                             timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_acp_aclken X or Z")
  u_ovl_intf_x_ext_acp_aclken (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (ext_acp_aclken));

  //  input          ext_acp_ainact      valid ext_acp_aclken@1                   timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_acp_ainact X or Z")
  u_ovl_intf_x_ext_acp_ainact (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_acp_aclken_reg),
    .test_expr (ext_acp_ainact));

  //  output         scu_acp_awready     valid always                             timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_acp_awready X or Z")
  u_ovl_intf_x_scu_acp_awready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_acp_awready));

  //  input          ext_acp_awvalid     valid ext_acp_aclken@1                   timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_acp_awvalid X or Z")
  u_ovl_intf_x_ext_acp_awvalid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_acp_aclken_reg),
    .test_expr (ext_acp_awvalid));

  //  input [4:0]    ext_acp_awid        valid ext_acp_awvalid & ext_acp_aclken@1 timing 70%

  assert_never_unknown #(`OVL_FATAL, 5, INOPTIONS, "ext_acp_awid X or Z")
  u_ovl_intf_x_ext_acp_awid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_acp_awvalid & ext_acp_aclken_reg),
    .test_expr (ext_acp_awid));

  //  input [39:0]   ext_acp_awaddr      valid ext_acp_awvalid & ext_acp_aclken@1 timing 70%

  assert_never_unknown #(`OVL_FATAL, 40, INOPTIONS, "ext_acp_awaddr X or Z")
  u_ovl_intf_x_ext_acp_awaddr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_acp_awvalid & ext_acp_aclken_reg),
    .test_expr (ext_acp_awaddr));

  //  input [7:0]    ext_acp_awlen       valid ext_acp_awvalid & ext_acp_aclken@1 timing 70%

  assert_never_unknown #(`OVL_FATAL, 8, INOPTIONS, "ext_acp_awlen X or Z")
  u_ovl_intf_x_ext_acp_awlen (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_acp_awvalid & ext_acp_aclken_reg),
    .test_expr (ext_acp_awlen));

  //  input [3:0]    ext_acp_awcache     valid ext_acp_awvalid & ext_acp_aclken@1 timing 70%

  assert_never_unknown #(`OVL_FATAL, 4, INOPTIONS, "ext_acp_awcache X or Z")
  u_ovl_intf_x_ext_acp_awcache (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_acp_awvalid & ext_acp_aclken_reg),
    .test_expr (ext_acp_awcache));

  //  input [1:0]    ext_acp_awuser      valid ext_acp_awvalid & ext_acp_aclken@1 timing 70%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "ext_acp_awuser X or Z")
  u_ovl_intf_x_ext_acp_awuser (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_acp_awvalid & ext_acp_aclken_reg),
    .test_expr (ext_acp_awuser));

  //  input [2:0]    ext_acp_awprot      valid ext_acp_awvalid & ext_acp_aclken@1 timing 70%

  assert_never_unknown #(`OVL_FATAL, 3, INOPTIONS, "ext_acp_awprot X or Z")
  u_ovl_intf_x_ext_acp_awprot (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_acp_awvalid & ext_acp_aclken_reg),
    .test_expr (ext_acp_awprot));

  //  output         scu_acp_wready      valid always                             timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_acp_wready X or Z")
  u_ovl_intf_x_scu_acp_wready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_acp_wready));

  //  input          ext_acp_wvalid      valid ext_acp_aclken@1                   timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_acp_wvalid X or Z")
  u_ovl_intf_x_ext_acp_wvalid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_acp_aclken_reg),
    .test_expr (ext_acp_wvalid));

  //  input [127:0]  ext_acp_wdata       valid ext_acp_wvalid & ext_acp_aclken@1  timing 70%

  assert_never_unknown #(`OVL_FATAL, 128, INOPTIONS, "ext_acp_wdata X or Z")
  u_ovl_intf_x_ext_acp_wdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_acp_wvalid & ext_acp_aclken_reg),
    .test_expr (ext_acp_wdata));

  //  input [15:0]   ext_acp_wstrb       valid ext_acp_wvalid & ext_acp_aclken@1  timing 70%

  assert_never_unknown #(`OVL_FATAL, 16, INOPTIONS, "ext_acp_wstrb X or Z")
  u_ovl_intf_x_ext_acp_wstrb (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_acp_wvalid & ext_acp_aclken_reg),
    .test_expr (ext_acp_wstrb));

  //  input          ext_acp_wlast       valid ext_acp_wvalid & ext_acp_aclken@1  timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_acp_wlast X or Z")
  u_ovl_intf_x_ext_acp_wlast (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_acp_wvalid & ext_acp_aclken_reg),
    .test_expr (ext_acp_wlast));

  //  input          ext_acp_bready      valid ext_acp_aclken@1                   timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_acp_bready X or Z")
  u_ovl_intf_x_ext_acp_bready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_acp_aclken_reg),
    .test_expr (ext_acp_bready));

  //  output         scu_acp_bvalid      valid always                             timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_acp_bvalid X or Z")
  u_ovl_intf_x_scu_acp_bvalid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_acp_bvalid));

  //  output [4:0]   scu_acp_bid         valid scu_acp_bvalid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "scu_acp_bid X or Z")
  u_ovl_intf_x_scu_acp_bid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_acp_bvalid),
    .test_expr (scu_acp_bid));

  //  output [1:0]   scu_acp_bresp       valid scu_acp_bvalid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "scu_acp_bresp X or Z")
  u_ovl_intf_x_scu_acp_bresp (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_acp_bvalid),
    .test_expr (scu_acp_bresp));

  //  output         scu_acp_arready     valid always                             timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_acp_arready X or Z")
  u_ovl_intf_x_scu_acp_arready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_acp_arready));

  //  input          ext_acp_arvalid     valid ext_acp_aclken@1                   timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_acp_arvalid X or Z")
  u_ovl_intf_x_ext_acp_arvalid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_acp_aclken_reg),
    .test_expr (ext_acp_arvalid));

  //  input [4:0]    ext_acp_arid        valid ext_acp_arvalid & ext_acp_aclken@1 timing 70%

  assert_never_unknown #(`OVL_FATAL, 5, INOPTIONS, "ext_acp_arid X or Z")
  u_ovl_intf_x_ext_acp_arid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_acp_arvalid & ext_acp_aclken_reg),
    .test_expr (ext_acp_arid));

  //  input [39:0]   ext_acp_araddr      valid ext_acp_arvalid & ext_acp_aclken@1 timing 70%

  assert_never_unknown #(`OVL_FATAL, 40, INOPTIONS, "ext_acp_araddr X or Z")
  u_ovl_intf_x_ext_acp_araddr (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_acp_arvalid & ext_acp_aclken_reg),
    .test_expr (ext_acp_araddr));

  //  input [7:0]    ext_acp_arlen       valid ext_acp_arvalid & ext_acp_aclken@1 timing 70%

  assert_never_unknown #(`OVL_FATAL, 8, INOPTIONS, "ext_acp_arlen X or Z")
  u_ovl_intf_x_ext_acp_arlen (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_acp_arvalid & ext_acp_aclken_reg),
    .test_expr (ext_acp_arlen));

  //  input [3:0]    ext_acp_arcache     valid ext_acp_arvalid & ext_acp_aclken@1 timing 70%

  assert_never_unknown #(`OVL_FATAL, 4, INOPTIONS, "ext_acp_arcache X or Z")
  u_ovl_intf_x_ext_acp_arcache (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_acp_arvalid & ext_acp_aclken_reg),
    .test_expr (ext_acp_arcache));

  //  input [1:0]    ext_acp_aruser      valid ext_acp_arvalid & ext_acp_aclken@1 timing 70%

  assert_never_unknown #(`OVL_FATAL, 2, INOPTIONS, "ext_acp_aruser X or Z")
  u_ovl_intf_x_ext_acp_aruser (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_acp_arvalid & ext_acp_aclken_reg),
    .test_expr (ext_acp_aruser));

  //  input [2:0]    ext_acp_arprot      valid ext_acp_arvalid & ext_acp_aclken@1 timing 70%

  assert_never_unknown #(`OVL_FATAL, 3, INOPTIONS, "ext_acp_arprot X or Z")
  u_ovl_intf_x_ext_acp_arprot (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_acp_arvalid & ext_acp_aclken_reg),
    .test_expr (ext_acp_arprot));

  //  input          ext_acp_rready      valid ext_acp_aclken@1                   timing 70%

  assert_never_unknown #(`OVL_FATAL, 1, INOPTIONS, "ext_acp_rready X or Z")
  u_ovl_intf_x_ext_acp_rready (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (ext_acp_aclken_reg),
    .test_expr (ext_acp_rready));

  //  output         scu_acp_rvalid      valid always                             timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_acp_rvalid X or Z")
  u_ovl_intf_x_scu_acp_rvalid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (scu_acp_rvalid));

  //  output [4:0]   scu_acp_rid         valid scu_acp_rvalid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 5, OUTOPTIONS, "scu_acp_rid X or Z")
  u_ovl_intf_x_scu_acp_rid (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_acp_rvalid),
    .test_expr (scu_acp_rid));

  //  output [127:0] scu_acp_rdata       valid scu_acp_rvalid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 128, OUTOPTIONS, "scu_acp_rdata X or Z")
  u_ovl_intf_x_scu_acp_rdata (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_acp_rvalid),
    .test_expr (scu_acp_rdata));

  //  output [1:0]   scu_acp_rresp       valid scu_acp_rvalid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 2, OUTOPTIONS, "scu_acp_rresp X or Z")
  u_ovl_intf_x_scu_acp_rresp (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_acp_rvalid),
    .test_expr (scu_acp_rresp));

  //  output         scu_acp_rlast       valid scu_acp_rvalid                     timing 30%

  assert_never_unknown #(`OVL_FATAL, 1, OUTOPTIONS, "scu_acp_rlast X or Z")
  u_ovl_intf_x_scu_acp_rlast (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (scu_acp_rvalid),
    .test_expr (scu_acp_rlast));


  // Outputs must not change when aclken is low

  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_acp_aclken@2 & out_of_reset@1  => scu_acp_awready === scu_acp_awready@1")
  u_ovl_intf_assert_48f577381e35395aa843df6eb52d0f405a533842 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_acp_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_acp_awready === scu_acp_awready_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_acp_aclken@2 & out_of_reset@1  => scu_acp_wready === scu_acp_wready@1")
  u_ovl_intf_assert_910e8628757baa9e8ae2ef4fd0c1a77cfb43bf8f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_acp_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_acp_wready === scu_acp_wready_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_acp_aclken@2 & out_of_reset@1  => scu_acp_bvalid === scu_acp_bvalid@1")
  u_ovl_intf_assert_68fa7429fea20afc1824f3cfa042be4804b53acf (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_acp_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_acp_bvalid === scu_acp_bvalid_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_acp_aclken@2 & out_of_reset@1  => scu_acp_bid === scu_acp_bid@1")
  u_ovl_intf_assert_19562239f5d214b86e057e55625962ff0ee6820a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_acp_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_acp_bid === scu_acp_bid_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_acp_aclken@2 & out_of_reset@1  => scu_acp_bresp === scu_acp_bresp@1")
  u_ovl_intf_assert_6784793b782c49c58f3b27fd314df340871f5483 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_acp_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_acp_bresp === scu_acp_bresp_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_acp_aclken@2 & out_of_reset@1  => scu_acp_arready === scu_acp_arready@1")
  u_ovl_intf_assert_de9f977c71f9326448b6a147f3af5350544b7943 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_acp_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_acp_arready === scu_acp_arready_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_acp_aclken@2 & out_of_reset@1  => scu_acp_rvalid === scu_acp_rvalid@1")
  u_ovl_intf_assert_84313a87da6fd83cd8b548a76fb26b634b276402 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_acp_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_acp_rvalid === scu_acp_rvalid_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_acp_aclken@2 & out_of_reset@1  => scu_acp_rid === scu_acp_rid@1")
  u_ovl_intf_assert_2adf23c83d5df1e3e7528f12ef1e0da29206db56 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_acp_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_acp_rid === scu_acp_rid_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_acp_aclken@2 & out_of_reset@1  => scu_acp_rdata === scu_acp_rdata@1")
  u_ovl_intf_assert_0829a9d21444f0ed2cf8834bd01817380360955f (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_acp_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_acp_rdata === scu_acp_rdata_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_acp_aclken@2 & out_of_reset@1  => scu_acp_rresp === scu_acp_rresp@1")
  u_ovl_intf_assert_854b0cd4c8421ff072a9afa791a39079ba5f5c5d (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_acp_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_acp_rresp === scu_acp_rresp_reg));


  assert_implication #(`OVL_FATAL, OUTOPTIONS, "~ext_acp_aclken@2 & out_of_reset@1  => scu_acp_rlast === scu_acp_rlast@1")
  u_ovl_intf_assert_ed9f9e301ecc6023272ed45e19d400ed4507f5cb (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (~ext_acp_aclken_reg_reg & out_of_reset_reg ),
    .consequent_expr (scu_acp_rlast === scu_acp_rlast_reg));



endmodule

`define CA53_UNDEFINE
`include "ca53_scu_dcu_defs.v"
`include "ca53scu_defs.v"
`include "ca53_ace_defs.v"
`include "cortexa53params.v"
`include "ca53_scu_ext_defs.v"
`undef CA53_UNDEFINE

`endif


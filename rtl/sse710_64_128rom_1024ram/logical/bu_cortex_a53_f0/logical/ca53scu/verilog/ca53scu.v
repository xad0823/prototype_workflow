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
//  Top level of the Cortex-A53 SCU
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "ca53_ace_defs.v"
`include "cortexa53params.v"

module ca53scu `CA53_SCU_PARAM_DECL
 (
  input  wire                                                   CLKIN,
  input  wire                                                   DFTSE,
  input  wire                                                   DFTRSTDISABLE,
  input  wire                                                   DFTRAMHOLD,
  input  wire                                                   DFTMCPHOLD,
  input  wire                                                   nl2reset_i,
  input  wire                                                   nmbistreset_i,
  input  wire                                                   l2rstdisable_i,
  output wire                                                   clk,
  input  wire                                                   acinactm_i,
  input  wire [NUM_CPUS-1:0]                                    gov_standbywfi_i,
  output wire                                                   standbywfil2_o,
  output wire [NUM_CPUS-1:0]                                    scu_wfx_ready_o,
  input  wire                                                   gov_enable_writeevict_i,
  input  wire                                                   gov_disable_evict_i,
  input  wire [1:0]                                             gov_l2victim_ctl_i,
  input  wire                                                   gov_l2deien_i,
  input  wire                                                   gov_l2teien_i,
  input  wire                                                   gov_l2_in_retention_i,
  output wire                                                   scu_l2_retention_ready_o,

  input  wire                                                   biu_cpu0_ar_active_i,
  output wire                                                   scu_cpu0_ar_credit_o,
  output wire                                                   scu_cpu0_ar_block_o,
  input  wire                                                   biu_cpu0_ar_valid_i,
  input  wire [4:0]                                             biu_cpu0_ar_id_i,
  input  wire [4:0]                                             biu_cpu0_ar_type_i,
  input  wire [7:0]                                             biu_cpu0_ar_attrs_i,
  input  wire [4:0]                                             biu_cpu0_ar_way_i,
  input  wire [40:0]                                            biu_cpu0_ar_addr_i,
  input  wire [1:0]                                             biu_cpu0_ar_len_i,
  input  wire [2:0]                                             biu_cpu0_ar_size_i,
  input  wire                                                   biu_cpu0_ar_lock_i,
  input  wire                                                   biu_cpu0_ar_priv_i,
  input  wire                                                   biu_cpu0_dr_credit_i,
  output wire                                                   scu_cpu0_dr_valid_o,
  output wire [4:0]                                             scu_cpu0_dr_id_o,
  output wire [5:0]                                             scu_cpu0_dr_resp_o,
  output wire [1:0]                                             scu_cpu0_dr_chunk_o,
  output wire [127:0]                                           scu_cpu0_dr_data_o,
  output wire                                                   scu_cpu0_rr_valid_o,
  output wire [4:0]                                             scu_cpu0_rr_id_o,
  output wire [1:0]                                             scu_cpu0_rr_resp_o,
  output wire [3:0]                                             scu_cpu0_rr_l2db_id_o,
  output wire [7:0]                                             scu_cpu0_ev_done_o,
  input  wire                                                   biu_cpu0_dw_valid_i,
  input  wire [3:0]                                             biu_cpu0_dw_l2db_id_i,
  input  wire [3:0]                                             biu_cpu0_dw_chunks_valid_i,
  input  wire                                                   biu_cpu0_dw_last_i,
  input  wire [31:0]                                            biu_cpu0_dw_strb_i,
  input  wire [255:0]                                           biu_cpu0_dw_data_i,
  input  wire                                                   biu_cpu0_dw_err_i,
  input  wire                                                   biu_cpu0_dw_fatal_i,
  output wire                                                   scu_cpu0_db_excl_valid_o,
  output wire [1:0]                                             scu_cpu0_db_excl_resp_o,
  output wire                                                   scu_cpu0_db_decerr_o,
  output wire                                                   scu_cpu0_db_slverr_o,
  output wire                                                   scu_cpu0_leave_ramode_o,
  output wire                                                   scu_cpu0_ac_valid_o,
  input  wire                                                   dcu_cpu0_ac_ready_i,
  output wire [2:0]                                             scu_cpu0_ac_id_o,
  output wire [3:0]                                             scu_cpu0_ac_l2db_id_o,
  output wire [3:0]                                             scu_cpu0_ac_snoop_o,
  output wire [40:0]                                            scu_cpu0_ac_addr_o,
  output wire [3:0]                                             scu_cpu0_ac_way_o,
  input  wire                                                   dcu_cpu0_cr_valid_i,
  input  wire [2:0]                                             dcu_cpu0_cr_id_i,
  input  wire                                                   dcu_cpu0_cr_dirty_i,
  input  wire                                                   dcu_cpu0_cr_age_i,
  input  wire                                                   dcu_cpu0_cr_alloc_i,
  input  wire                                                   dcu_cpu0_cr_migratory_i,
  input  wire                                                   dcu_cpu0_dvm_complete_i,
  output wire                                                   scu_cpu0_dvm_complete_o,
  output wire [7:0]                                             scu_cpu0_reqbufs_busy_o,
  output wire                                                   scu_cpu0_drain_stb_o,
  input  wire                                                   biu_cpu1_ar_active_i,
  output wire                                                   scu_cpu1_ar_credit_o,
  output wire                                                   scu_cpu1_ar_block_o,
  input  wire                                                   biu_cpu1_ar_valid_i,
  input  wire [4:0]                                             biu_cpu1_ar_id_i,
  input  wire [4:0]                                             biu_cpu1_ar_type_i,
  input  wire [7:0]                                             biu_cpu1_ar_attrs_i,
  input  wire [4:0]                                             biu_cpu1_ar_way_i,
  input  wire [40:0]                                            biu_cpu1_ar_addr_i,
  input  wire [1:0]                                             biu_cpu1_ar_len_i,
  input  wire [2:0]                                             biu_cpu1_ar_size_i,
  input  wire                                                   biu_cpu1_ar_lock_i,
  input  wire                                                   biu_cpu1_ar_priv_i,
  input  wire                                                   biu_cpu1_dr_credit_i,
  output wire                                                   scu_cpu1_dr_valid_o,
  output wire [4:0]                                             scu_cpu1_dr_id_o,
  output wire [5:0]                                             scu_cpu1_dr_resp_o,
  output wire [1:0]                                             scu_cpu1_dr_chunk_o,
  output wire [127:0]                                           scu_cpu1_dr_data_o,
  output wire                                                   scu_cpu1_rr_valid_o,
  output wire [4:0]                                             scu_cpu1_rr_id_o,
  output wire [1:0]                                             scu_cpu1_rr_resp_o,
  output wire [3:0]                                             scu_cpu1_rr_l2db_id_o,
  output wire [7:0]                                             scu_cpu1_ev_done_o,
  input  wire                                                   biu_cpu1_dw_valid_i,
  input  wire [3:0]                                             biu_cpu1_dw_l2db_id_i,
  input  wire [3:0]                                             biu_cpu1_dw_chunks_valid_i,
  input  wire                                                   biu_cpu1_dw_last_i,
  input  wire [31:0]                                            biu_cpu1_dw_strb_i,
  input  wire [255:0]                                           biu_cpu1_dw_data_i,
  input  wire                                                   biu_cpu1_dw_err_i,
  input  wire                                                   biu_cpu1_dw_fatal_i,
  output wire                                                   scu_cpu1_db_excl_valid_o,
  output wire [1:0]                                             scu_cpu1_db_excl_resp_o,
  output wire                                                   scu_cpu1_db_decerr_o,
  output wire                                                   scu_cpu1_db_slverr_o,
  output wire                                                   scu_cpu1_leave_ramode_o,
  output wire                                                   scu_cpu1_ac_valid_o,
  input  wire                                                   dcu_cpu1_ac_ready_i,
  output wire [2:0]                                             scu_cpu1_ac_id_o,
  output wire [3:0]                                             scu_cpu1_ac_l2db_id_o,
  output wire [3:0]                                             scu_cpu1_ac_snoop_o,
  output wire [40:0]                                            scu_cpu1_ac_addr_o,
  output wire [3:0]                                             scu_cpu1_ac_way_o,
  input  wire                                                   dcu_cpu1_cr_valid_i,
  input  wire [2:0]                                             dcu_cpu1_cr_id_i,
  input  wire                                                   dcu_cpu1_cr_dirty_i,
  input  wire                                                   dcu_cpu1_cr_age_i,
  input  wire                                                   dcu_cpu1_cr_alloc_i,
  input  wire                                                   dcu_cpu1_cr_migratory_i,
  input  wire                                                   dcu_cpu1_dvm_complete_i,
  output wire                                                   scu_cpu1_dvm_complete_o,
  output wire [7:0]                                             scu_cpu1_reqbufs_busy_o,
  output wire                                                   scu_cpu1_drain_stb_o,
  input  wire                                                   biu_cpu2_ar_active_i,
  output wire                                                   scu_cpu2_ar_credit_o,
  output wire                                                   scu_cpu2_ar_block_o,
  input  wire                                                   biu_cpu2_ar_valid_i,
  input  wire [4:0]                                             biu_cpu2_ar_id_i,
  input  wire [4:0]                                             biu_cpu2_ar_type_i,
  input  wire [7:0]                                             biu_cpu2_ar_attrs_i,
  input  wire [4:0]                                             biu_cpu2_ar_way_i,
  input  wire [40:0]                                            biu_cpu2_ar_addr_i,
  input  wire [1:0]                                             biu_cpu2_ar_len_i,
  input  wire [2:0]                                             biu_cpu2_ar_size_i,
  input  wire                                                   biu_cpu2_ar_lock_i,
  input  wire                                                   biu_cpu2_ar_priv_i,
  input  wire                                                   biu_cpu2_dr_credit_i,
  output wire                                                   scu_cpu2_dr_valid_o,
  output wire [4:0]                                             scu_cpu2_dr_id_o,
  output wire [5:0]                                             scu_cpu2_dr_resp_o,
  output wire [1:0]                                             scu_cpu2_dr_chunk_o,
  output wire [127:0]                                           scu_cpu2_dr_data_o,
  output wire                                                   scu_cpu2_rr_valid_o,
  output wire [4:0]                                             scu_cpu2_rr_id_o,
  output wire [1:0]                                             scu_cpu2_rr_resp_o,
  output wire [3:0]                                             scu_cpu2_rr_l2db_id_o,
  output wire [7:0]                                             scu_cpu2_ev_done_o,
  input  wire                                                   biu_cpu2_dw_valid_i,
  input  wire [3:0]                                             biu_cpu2_dw_l2db_id_i,
  input  wire [3:0]                                             biu_cpu2_dw_chunks_valid_i,
  input  wire                                                   biu_cpu2_dw_last_i,
  input  wire [31:0]                                            biu_cpu2_dw_strb_i,
  input  wire [255:0]                                           biu_cpu2_dw_data_i,
  input  wire                                                   biu_cpu2_dw_err_i,
  input  wire                                                   biu_cpu2_dw_fatal_i,
  output wire                                                   scu_cpu2_db_excl_valid_o,
  output wire [1:0]                                             scu_cpu2_db_excl_resp_o,
  output wire                                                   scu_cpu2_db_decerr_o,
  output wire                                                   scu_cpu2_db_slverr_o,
  output wire                                                   scu_cpu2_leave_ramode_o,
  output wire                                                   scu_cpu2_ac_valid_o,
  input  wire                                                   dcu_cpu2_ac_ready_i,
  output wire [2:0]                                             scu_cpu2_ac_id_o,
  output wire [3:0]                                             scu_cpu2_ac_l2db_id_o,
  output wire [3:0]                                             scu_cpu2_ac_snoop_o,
  output wire [40:0]                                            scu_cpu2_ac_addr_o,
  output wire [3:0]                                             scu_cpu2_ac_way_o,
  input  wire                                                   dcu_cpu2_cr_valid_i,
  input  wire [2:0]                                             dcu_cpu2_cr_id_i,
  input  wire                                                   dcu_cpu2_cr_dirty_i,
  input  wire                                                   dcu_cpu2_cr_age_i,
  input  wire                                                   dcu_cpu2_cr_alloc_i,
  input  wire                                                   dcu_cpu2_cr_migratory_i,
  input  wire                                                   dcu_cpu2_dvm_complete_i,
  output wire                                                   scu_cpu2_dvm_complete_o,
  output wire [7:0]                                             scu_cpu2_reqbufs_busy_o,
  output wire                                                   scu_cpu2_drain_stb_o,
  input  wire                                                   biu_cpu3_ar_active_i,
  output wire                                                   scu_cpu3_ar_credit_o,
  output wire                                                   scu_cpu3_ar_block_o,
  input  wire                                                   biu_cpu3_ar_valid_i,
  input  wire [4:0]                                             biu_cpu3_ar_id_i,
  input  wire [4:0]                                             biu_cpu3_ar_type_i,
  input  wire [7:0]                                             biu_cpu3_ar_attrs_i,
  input  wire [4:0]                                             biu_cpu3_ar_way_i,
  input  wire [40:0]                                            biu_cpu3_ar_addr_i,
  input  wire [1:0]                                             biu_cpu3_ar_len_i,
  input  wire [2:0]                                             biu_cpu3_ar_size_i,
  input  wire                                                   biu_cpu3_ar_lock_i,
  input  wire                                                   biu_cpu3_ar_priv_i,
  input  wire                                                   biu_cpu3_dr_credit_i,
  output wire                                                   scu_cpu3_dr_valid_o,
  output wire [4:0]                                             scu_cpu3_dr_id_o,
  output wire [5:0]                                             scu_cpu3_dr_resp_o,
  output wire [1:0]                                             scu_cpu3_dr_chunk_o,
  output wire [127:0]                                           scu_cpu3_dr_data_o,
  output wire                                                   scu_cpu3_rr_valid_o,
  output wire [4:0]                                             scu_cpu3_rr_id_o,
  output wire [1:0]                                             scu_cpu3_rr_resp_o,
  output wire [3:0]                                             scu_cpu3_rr_l2db_id_o,
  output wire [7:0]                                             scu_cpu3_ev_done_o,
  input  wire                                                   biu_cpu3_dw_valid_i,
  input  wire [3:0]                                             biu_cpu3_dw_l2db_id_i,
  input  wire [3:0]                                             biu_cpu3_dw_chunks_valid_i,
  input  wire                                                   biu_cpu3_dw_last_i,
  input  wire [31:0]                                            biu_cpu3_dw_strb_i,
  input  wire [255:0]                                           biu_cpu3_dw_data_i,
  input  wire                                                   biu_cpu3_dw_err_i,
  input  wire                                                   biu_cpu3_dw_fatal_i,
  output wire                                                   scu_cpu3_db_excl_valid_o,
  output wire [1:0]                                             scu_cpu3_db_excl_resp_o,
  output wire                                                   scu_cpu3_db_decerr_o,
  output wire                                                   scu_cpu3_db_slverr_o,
  output wire                                                   scu_cpu3_leave_ramode_o,
  output wire                                                   scu_cpu3_ac_valid_o,
  input  wire                                                   dcu_cpu3_ac_ready_i,
  output wire [2:0]                                             scu_cpu3_ac_id_o,
  output wire [3:0]                                             scu_cpu3_ac_l2db_id_o,
  output wire [3:0]                                             scu_cpu3_ac_snoop_o,
  output wire [40:0]                                            scu_cpu3_ac_addr_o,
  output wire [3:0]                                             scu_cpu3_ac_way_o,
  input  wire                                                   dcu_cpu3_cr_valid_i,
  input  wire [2:0]                                             dcu_cpu3_cr_id_i,
  input  wire                                                   dcu_cpu3_cr_dirty_i,
  input  wire                                                   dcu_cpu3_cr_age_i,
  input  wire                                                   dcu_cpu3_cr_alloc_i,
  input  wire                                                   dcu_cpu3_cr_migratory_i,
  input  wire                                                   dcu_cpu3_dvm_complete_i,
  output wire                                                   scu_cpu3_dvm_complete_o,
  output wire [7:0]                                             scu_cpu3_reqbufs_busy_o,
  output wire                                                   scu_cpu3_drain_stb_o,
  input  wire                                                   gov_mbistreq_i,
  output wire                                                   scu_mbistack0_o,
  output wire                                                   scu_mbistack1_o,
  input  wire [(`CA53_MBIST0_RAMARRAY_W-1):0]                   gov_mbistarray0_i,
  input  wire [(`CA53_MBIST1_RAMARRAY_W-1):0]                   gov_mbistarray1_i,
  input  wire                                                   gov_mbistwriteen0_i,
  input  wire                                                   gov_mbistwriteen1_i,
  input  wire                                                   gov_mbistreaden0_i,
  input  wire                                                   gov_mbistreaden1_i,
  input  wire [(`CA53_MBIST0_ADDR_W-1): 0]                      gov_mbistaddr0_i,
  input  wire [(`CA53_MBIST1_ADDR_W-1): 0]                      gov_mbistaddr1_i,
  input  wire [(`CA53_MBIST0_BE_W-1):0]                         gov_mbistbe0_i,
  input  wire [(`CA53_MBIST1_BE_W-1):0]                         gov_mbistbe1_i,
  input  wire                                                   gov_mbistcfg0_i,
  input  wire                                                   gov_mbistcfg1_i,
  input  wire [(`CA53_MBIST0_DATA_W-1): 0]                      gov_mbistindata0_i,
  input  wire [(`CA53_MBIST1_DATA_W-1): 0]                      gov_mbistindata1_i,
  output wire [(`CA53_MBIST0_DATA_W-1): 0]                      scu_mbistoutdata0_o,
  output wire [(`CA53_MBIST1_DATA_W-1): 0]                      scu_mbistoutdata1_o,
  output wire                                                   l1d_tagram_clken_o,
  output wire [`CA53_SCU_L1D_ASSOC-1:0]                         l1d_tagram_cpu0_en_o,
  output wire                                                   l1d_tagram_cpu0_wr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]                 l1d_tagram_cpu0_addr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]                 l1d_tagram_cpu0_wdata_o,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]                 l1d_tagram_cpu0_way0_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]                 l1d_tagram_cpu0_way1_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]                 l1d_tagram_cpu0_way2_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]                 l1d_tagram_cpu0_way3_rdata_i,
  output wire [`CA53_SCU_L1D_ASSOC-1:0]                         l1d_tagram_cpu1_en_o,
  output wire                                                   l1d_tagram_cpu1_wr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]                 l1d_tagram_cpu1_addr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]                 l1d_tagram_cpu1_wdata_o,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]                 l1d_tagram_cpu1_way0_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]                 l1d_tagram_cpu1_way1_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]                 l1d_tagram_cpu1_way2_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]                 l1d_tagram_cpu1_way3_rdata_i,
  output wire [`CA53_SCU_L1D_ASSOC-1:0]                         l1d_tagram_cpu2_en_o,
  output wire                                                   l1d_tagram_cpu2_wr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]                 l1d_tagram_cpu2_addr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]                 l1d_tagram_cpu2_wdata_o,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]                 l1d_tagram_cpu2_way0_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]                 l1d_tagram_cpu2_way1_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]                 l1d_tagram_cpu2_way2_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]                 l1d_tagram_cpu2_way3_rdata_i,
  output wire [`CA53_SCU_L1D_ASSOC-1:0]                         l1d_tagram_cpu3_en_o,
  output wire                                                   l1d_tagram_cpu3_wr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]                 l1d_tagram_cpu3_addr_o,
  output wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]                 l1d_tagram_cpu3_wdata_o,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]                 l1d_tagram_cpu3_way0_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]                 l1d_tagram_cpu3_way1_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]                 l1d_tagram_cpu3_way2_rdata_i,
  input  wire [`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]                 l1d_tagram_cpu3_way3_rdata_i,
  input  wire [`CA53_L2_SIZE_W-1:0]                             l2_size_i,
  output wire                                                   l2_tagram_clken_o,
  output wire [`CA53_SCU_L2_ASSOC-1:0]                          l2_tagram_en_o,
  output wire                                                   l2_tagram_wr_o,
  output wire [`CA53_SCU_L2_TAGRAM_ADDR_W-1:0]                  l2_tagram_addr_o,
  output wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]                  l2_tagram_wdata_o,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]                  l2_tagram_way0_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]                  l2_tagram_way1_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]                  l2_tagram_way2_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]                  l2_tagram_way3_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]                  l2_tagram_way4_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]                  l2_tagram_way5_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]                  l2_tagram_way6_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]                  l2_tagram_way7_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]                  l2_tagram_way8_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]                  l2_tagram_way9_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]                  l2_tagram_way10_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]                  l2_tagram_way11_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]                  l2_tagram_way12_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]                  l2_tagram_way13_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]                  l2_tagram_way14_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]                  l2_tagram_way15_rdata_i,
  output wire                                                   l2_victimram_no_acc_next_cycle_o,
  output wire                                                   l2_victimram_clken_o,
  output wire                                                   l2_victimram_en_o,
  output wire                                                   l2_victimram_wr_o,
  output wire [`CA53_SCU_L2_VICTIMRAM_STRB_W-1:0]               l2_victimram_strb_o,
  output wire [`CA53_SCU_L2_VICTIMRAM_ADDR_W-1:0]               l2_victimram_addr_o,
  output wire [`CA53_SCU_L2_VICTIMRAM_DATA_W-1:0]               l2_victimram_wdata_o,
  input  wire [`CA53_SCU_L2_VICTIMRAM_DATA_W-1:0]               l2_victimram_rdata_i,
  output wire                                                   l2_dataram_no_acc_next_cycle_o,
  output wire [`CA53_SCU_L2_DATARAM_EN_W-1:0]                   l2_dataram_clken_o,
  output wire [`CA53_SCU_L2_DATARAM_EN_W-1:0]                   l2_dataram_en_o,
  output wire                                                   l2_dataram_wr_o,
  output wire [`CA53_SCU_L2_DATARAM_ADDR_W-1:0]                 l2_dataram_addr_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]                 l2_dataram_wdata0_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]                 l2_dataram_wdata1_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]                 l2_dataram_wdata2_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]                 l2_dataram_wdata3_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]                 l2_dataram_wdata4_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]                 l2_dataram_wdata5_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]                 l2_dataram_wdata6_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]                 l2_dataram_wdata7_o,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]                 l2_dataram_rdata0_i,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]                 l2_dataram_rdata1_i,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]                 l2_dataram_rdata2_i,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]                 l2_dataram_rdata3_i,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]                 l2_dataram_rdata4_i,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]                 l2_dataram_rdata5_i,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]                 l2_dataram_rdata6_i,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]                 l2_dataram_rdata7_i,
  input  wire [`CA53_L1DC_SIZE_W-1:0]                           l1_dc_size_i,
  input  wire                                                   broadcastinner_i,
  input  wire                                                   broadcastouter_i,
  input  wire                                                   broadcastcachemaint_i,
  input  wire                                                   sysbardisable_i,
  output wire                                                   scu_cpu0_broadcastinner_o,
  output wire                                                   scu_cpu1_broadcastinner_o,
  output wire                                                   scu_cpu2_broadcastinner_o,
  output wire                                                   scu_cpu3_broadcastinner_o,
  output wire                                                   nexterrirq_o,
  output wire                                                   ninterrirq_o,
  output wire                                                   scu_axierr_o,
  output wire                                                   scu_eccerr_o,
  output wire                                                   scu_l2ecc_valid_o,
  output wire                                                   scu_l2ecc_fatal_o,
  output wire [  1: 0]                                          scu_l2ecc_ramid_o,
  output wire [  3: 0]                                          scu_l2ecc_cpuid_way_o,
  output wire [ 14: 0]                                          scu_l2ecc_index_o,
  input  wire                                                   gov_clear_axierr_i,
  input  wire                                                   gov_clear_eccerr_i,
  input  wire                                                   gov_cpu0_inv_all_req_i,
  input  wire                                                   gov_cpu1_inv_all_req_i,
  input  wire                                                   gov_cpu2_inv_all_req_i,
  input  wire                                                   gov_cpu3_inv_all_req_i,
  output wire                                                   scu_cpu0_inv_all_ack_o,
  output wire                                                   scu_cpu1_inv_all_ack_o,
  output wire                                                   scu_cpu2_inv_all_ack_o,
  output wire                                                   scu_cpu3_inv_all_ack_o,
  output wire                                                   scu_cpu0_evnt_l2_access_o,
  output wire                                                   scu_cpu0_evnt_l2_refill_o,
  output wire                                                   scu_cpu0_evnt_l2_wb_o,
  output wire                                                   scu_cpu0_evnt_snooped_data_o,
  output wire                                                   scu_cpu0_evnt_bus_cycle_o,
  output wire                                                   scu_cpu0_evnt_bus_acc_rd_o,
  output wire                                                   scu_cpu0_evnt_bus_acc_wr_o,
  output wire                                                   scu_cpu0_evnt_eviction_o,
  output wire                                                   scu_cpu1_evnt_l2_access_o,
  output wire                                                   scu_cpu1_evnt_l2_refill_o,
  output wire                                                   scu_cpu1_evnt_l2_wb_o,
  output wire                                                   scu_cpu1_evnt_snooped_data_o,
  output wire                                                   scu_cpu1_evnt_bus_cycle_o,
  output wire                                                   scu_cpu1_evnt_bus_acc_rd_o,
  output wire                                                   scu_cpu1_evnt_bus_acc_wr_o,
  output wire                                                   scu_cpu1_evnt_eviction_o,
  output wire                                                   scu_cpu2_evnt_l2_access_o,
  output wire                                                   scu_cpu2_evnt_l2_refill_o,
  output wire                                                   scu_cpu2_evnt_l2_wb_o,
  output wire                                                   scu_cpu2_evnt_snooped_data_o,
  output wire                                                   scu_cpu2_evnt_bus_cycle_o,
  output wire                                                   scu_cpu2_evnt_bus_acc_rd_o,
  output wire                                                   scu_cpu2_evnt_bus_acc_wr_o,
  output wire                                                   scu_cpu2_evnt_eviction_o,
  output wire                                                   scu_cpu3_evnt_l2_access_o,
  output wire                                                   scu_cpu3_evnt_l2_refill_o,
  output wire                                                   scu_cpu3_evnt_l2_wb_o,
  output wire                                                   scu_cpu3_evnt_snooped_data_o,
  output wire                                                   scu_cpu3_evnt_bus_cycle_o,
  output wire                                                   scu_cpu3_evnt_bus_acc_rd_o,
  output wire                                                   scu_cpu3_evnt_bus_acc_wr_o,
  output wire                                                   scu_cpu3_evnt_eviction_o,
  input  wire                                                   scu_ext_aclken_i,
  output wire                                                   scu_ext_ar_valid_o,
  input  wire                                                   scu_ext_ar_ready_i,
  output wire [`CA53_SCU_EXT_ADDR_W-1:0]                        scu_ext_ar_addr_o,
  output wire [`CA53_ACE_ARLEN_W-1:0]                           scu_ext_ar_len_o,
  output wire [`CA53_ACE_ARSIZE_W-1:0]                          scu_ext_ar_size_o,
  output wire [`CA53_ACE_ARBURST_W-1:0]                         scu_ext_ar_burst_o,
  output wire                                                   scu_ext_ar_lock_o,
  output wire [`CA53_ACE_ARCACHE_W-1:0]                         scu_ext_ar_cache_o,
  output wire [`CA53_ACE_ARPROT_W-1:0]                          scu_ext_ar_prot_o,
  output wire [`CA53_ACE_ARSNOOP_W-1:0]                         scu_ext_ar_snoop_o,
  output wire [`CA53_ACE_ARDOMAIN_W-1:0]                        scu_ext_ar_domain_o,
  output wire [`CA53_ACE_ARBAR_W-1:0]                           scu_ext_ar_bar_o,
  output wire [`CA53_SCU_EXT_RID_W-1:0]                         scu_ext_ar_id_o,
  output wire [7:0]                                             scu_ext_rdmemattr_o,
  input  wire [`CA53_SCU_EXT_RID_W-1:0]                         scu_ext_dr_id_i,
  output wire                                                   scu_ext_dr_ready_o,
  input  wire                                                   scu_ext_dr_valid_i,
  input  wire                                                   scu_ext_dr_last_i,
  input  wire [`CA53_SCU_EXT_DATA_W-1:0]                        scu_ext_dr_data_i,
  input  wire [`CA53_ACE_RRESP_W-1:0]                           scu_ext_dr_resp_i,
  output wire                                                   scu_ext_aw_valid_o,
  input  wire                                                   scu_ext_aw_ready_i,
  output wire [`CA53_SCU_EXT_ADDR_W-1:0]                        scu_ext_aw_addr_o,
  output wire [`CA53_ACE_AWLEN_W-1:0]                           scu_ext_aw_len_o,
  output wire [`CA53_ACE_AWSIZE_W-1:0]                          scu_ext_aw_size_o,
  output wire [`CA53_ACE_AWBURST_W-1:0]                         scu_ext_aw_burst_o,
  output wire                                                   scu_ext_aw_lock_o,
  output wire [`CA53_ACE_AWCACHE_W-1:0]                         scu_ext_aw_cache_o,
  output wire [`CA53_ACE_AWPROT_W-1:0]                          scu_ext_aw_prot_o,
  output wire [`CA53_ACE_AWSNOOP_W-1:0]                         scu_ext_aw_snoop_o,
  output wire [`CA53_ACE_AWDOMAIN_W-1:0]                        scu_ext_aw_domain_o,
  output wire [`CA53_ACE_AWBAR_W-1:0]                           scu_ext_aw_bar_o,
  output wire [`CA53_SCU_EXT_WID_W-1:0]                         scu_ext_aw_id_o,
  output wire                                                   scu_ext_aw_unique_o,
  output wire [7:0]                                             scu_ext_wrmemattr_o,
  output wire [`CA53_SCU_EXT_STRB_W-1:0]                        scu_ext_dw_strb_o,
  output wire [`CA53_SCU_EXT_DATA_W-1:0]                        scu_ext_dw_data_o,
  output wire [`CA53_SCU_EXT_WID_W-1:0]                         scu_ext_dw_id_o,
  output wire                                                   scu_ext_dw_last_o,
  input  wire                                                   scu_ext_dw_ready_i,
  output wire                                                   scu_ext_dw_valid_o,
  input  wire [`CA53_SCU_EXT_WID_W-1:0]                         scu_ext_db_id_i,
  input  wire [`CA53_ACE_BRESP_W-1:0]                           scu_ext_db_resp_i,
  input  wire                                                   scu_ext_db_valid_i,
  output wire                                                   scu_ext_db_ready_o,
  output wire                                                   scu_ext_ac_ready_o,
  input  wire                                                   scu_ext_ac_valid_i,
  input  wire [`CA53_ACE_ACSNOOP_W-1:0]                         scu_ext_ac_snoop_i,
  input  wire [`CA53_SCU_EXT_ADDR_W-1:0]                        scu_ext_ac_addr_i,
  input  wire [`CA53_ACE_ACPROT_W-1:0]                          scu_ext_ac_prot_i,
  output wire                                                   scu_ext_cr_valid_o,
  input  wire                                                   scu_ext_cr_ready_i,
  output wire [`CA53_ACE_CRRESP_W-1:0]                          scu_ext_cr_resp_o,
  output wire                                                   scu_ext_cd_valid_o,
  input  wire                                                   scu_ext_cd_ready_i,
  output wire [`CA53_SCU_EXT_DATA_W-1:0]                        scu_ext_cd_data_o,
  output wire                                                   scu_ext_cd_last_o,
  output wire                                                   scu_ext_rack_o,
  output wire                                                   scu_ext_wack_o,
  input  wire                                                   ext_sclken_i,
  input  wire                                                   ext_sinact_i,
  input  wire [6:0]                                             ext_nodeid_i,
  input  wire                                                   ext_rxsactive_i,
  output wire                                                   scu_txsactive_o,
  input  wire                                                   ext_rxlinkactivereq_i,
  output wire                                                   scu_rxlinkactiveack_o,
  output wire                                                   scu_txlinkactivereq_o,
  input  wire                                                   ext_txlinkactiveack_i,
  output wire                                                   scu_txreqflitpend_o,
  output wire                                                   scu_txreqflitv_o,
  output wire [99:0]                                            scu_txreqflit_o,
  input  wire                                                   ext_txreqlcrdv_i,
  output wire [7:0]                                             scu_reqmemattr_o,
  output wire                                                   scu_txrspflitpend_o,
  output wire                                                   scu_txrspflitv_o,
  output wire [44:0]                                            scu_txrspflit_o,
  input  wire                                                   ext_txrsplcrdv_i,
  output wire                                                   scu_txdatflitpend_o,
  output wire                                                   scu_txdatflitv_o,
  output wire [193:0]                                           scu_txdatflit_o,
  input  wire                                                   ext_txdatlcrdv_i,
  input  wire                                                   ext_rxsnpflitpend_i,
  input  wire                                                   ext_rxsnpflitv_i,
  input  wire [64:0]                                            ext_rxsnpflit_i,
  output wire                                                   scu_rxsnplcrdv_o,
  input  wire                                                   ext_rxrspflitpend_i,
  input  wire                                                   ext_rxrspflitv_i,
  input  wire [44:0]                                            ext_rxrspflit_i,
  output wire                                                   scu_rxrsplcrdv_o,
  input  wire                                                   ext_rxdatflitpend_i,
  input  wire                                                   ext_rxdatflitv_i,
  input  wire [193:0]                                           ext_rxdatflit_i,
  output wire                                                   scu_rxdatlcrdv_o,
  input  wire [1:0]                                             ext_samaddrmap0_i,
  input  wire [1:0]                                             ext_samaddrmap1_i,
  input  wire [1:0]                                             ext_samaddrmap2_i,
  input  wire [1:0]                                             ext_samaddrmap3_i,
  input  wire [1:0]                                             ext_samaddrmap4_i,
  input  wire [1:0]                                             ext_samaddrmap5_i,
  input  wire [1:0]                                             ext_samaddrmap6_i,
  input  wire [1:0]                                             ext_samaddrmap7_i,
  input  wire [1:0]                                             ext_samaddrmap8_i,
  input  wire [1:0]                                             ext_samaddrmap9_i,
  input  wire [1:0]                                             ext_samaddrmap10_i,
  input  wire [1:0]                                             ext_samaddrmap11_i,
  input  wire [1:0]                                             ext_samaddrmap12_i,
  input  wire [1:0]                                             ext_samaddrmap13_i,
  input  wire [1:0]                                             ext_samaddrmap14_i,
  input  wire [1:0]                                             ext_samaddrmap15_i,
  input  wire [39:24]                                           ext_sammnbase_i,
  input  wire [6:0]                                             ext_sammnnodeid_i,
  input  wire [6:0]                                             ext_samhni0nodeid_i,
  input  wire [6:0]                                             ext_samhni1nodeid_i,
  input  wire [6:0]                                             ext_samhnf0nodeid_i,
  input  wire [6:0]                                             ext_samhnf1nodeid_i,
  input  wire [6:0]                                             ext_samhnf2nodeid_i,
  input  wire [6:0]                                             ext_samhnf3nodeid_i,
  input  wire [6:0]                                             ext_samhnf4nodeid_i,
  input  wire [6:0]                                             ext_samhnf5nodeid_i,
  input  wire [6:0]                                             ext_samhnf6nodeid_i,
  input  wire [6:0]                                             ext_samhnf7nodeid_i,
  input  wire [2:0]                                             ext_samhnfmode_i,
  input  wire                                                   ext_acp_aclken_i,
  input  wire                                                   ext_acp_ainact_i,
  output wire                                                   scu_acp_awready_o,
  input  wire                                                   ext_acp_awvalid_i,
  input  wire  [4:0]                                            ext_acp_awid_i,
  input  wire  [39:0]                                           ext_acp_awaddr_i,
  input  wire  [7:0]                                            ext_acp_awlen_i,
  input  wire  [3:0]                                            ext_acp_awcache_i,
  input  wire  [1:0]                                            ext_acp_awuser_i,
  input  wire  [2:0]                                            ext_acp_awprot_i,
  output wire                                                   scu_acp_wready_o,
  input  wire                                                   ext_acp_wvalid_i,
  input  wire  [127:0]                                          ext_acp_wdata_i,
  input  wire  [15:0]                                           ext_acp_wstrb_i,
  input  wire                                                   ext_acp_wlast_i,
  input  wire                                                   ext_acp_bready_i,
  output wire                                                   scu_acp_bvalid_o,
  output wire  [4:0]                                            scu_acp_bid_o,
  output wire  [1:0]                                            scu_acp_bresp_o,
  output wire                                                   scu_acp_arready_o,
  input  wire                                                   ext_acp_arvalid_i,
  input  wire  [4:0]                                            ext_acp_arid_i,
  input  wire  [39:0]                                           ext_acp_araddr_i,
  input  wire  [7:0]                                            ext_acp_arlen_i,
  input  wire  [3:0]                                            ext_acp_arcache_i,
  input  wire  [1:0]                                            ext_acp_aruser_i,
  input  wire  [2:0]                                            ext_acp_arprot_i,
  input  wire                                                   ext_acp_rready_i,
  output wire                                                   scu_acp_rvalid_o,
  output wire  [4:0]                                            scu_acp_rid_o,
  output wire  [127:0]                                          scu_acp_rdata_o,
  output wire  [1:0]                                            scu_acp_rresp_o,
  output wire                                                   scu_acp_rlast_o,
  input  wire                                                   gov_cpu0_smp_en_i,
  input  wire                                                   gov_cpu1_smp_en_i,
  input  wire                                                   gov_cpu2_smp_en_i,
  input  wire                                                   gov_cpu3_smp_en_i,
  input  wire                                                   l2flushreq_i,
  output wire                                                   l2flushdone_o
);


  //-----------------------------------------------------------------------------
  //  Declarations
  //-----------------------------------------------------------------------------

  // There must be a minimum of 5 L2DBs, to ensure that when one is reserved for
  // snoops, and two are reserved for serialised accesses, there is more than one
  // left for unserialised accesses.
  localparam NUM_L2DBS = (NUM_CPUS == 1) ? (4 +
                                            (((L2_CACHE == 0) & (ACE != 0)) ? 1 : 0) +
                                            ((ACE != 0) ? 0 : 2) +
                                            ((L2_CACHE != 0) ? 2 : 0)) : 11;
  localparam MAX_L2DBS = 11;

  /*ARMAUTO*/
  // The following wires were automatically generated
  // to interconnect instantiations where appropriate.
  wire                                       acp_ainact_rs;
  wire                                       acpslv_active;
  wire                                       acpslv_compack_active;
  wire                                 [6:0] acpslv_compack_tgtid;
  wire                                 [7:0] acpslv_compack_txnid;
  wire                                       acpslv_compack_valid;
  wire                                 [3:0] acpslv_delay_allocation;
  wire                                [10:0] acpslv_early_dr_index;
  wire                                       acpslv_early_dr_l2;
  wire                                [15:0] acpslv_early_dr_ready;
  wire                                 [3:0] acpslv_early_dr_way;
  wire                                       acpslv_ext_err;
  wire                                [15:0] acpslv_force_miss_tc2;
  wire                                       acpslv_hz_tc2;
  wire                                       acpslv_hz_tc4;
  wire                                [15:0] acpslv_l2_way_used_tc2;
  wire                                [15:0] acpslv_l2_way_used_vc2;
  wire                                       acpslv_l2db0_ready;
  wire                                       acpslv_l2db0_release;
  wire                                       acpslv_l2db0_transfer;
  wire                                [25:0] acpslv_l2db0_transfer_info;
  wire                                 [2:0] acpslv_l2db0_transfer_type;
  wire                                       acpslv_l2db10_ready;
  wire                                       acpslv_l2db10_release;
  wire                                       acpslv_l2db10_transfer;
  wire                                [25:0] acpslv_l2db10_transfer_info;
  wire                                 [2:0] acpslv_l2db10_transfer_type;
  wire                                       acpslv_l2db1_ready;
  wire                                       acpslv_l2db1_release;
  wire                                       acpslv_l2db1_transfer;
  wire                                [25:0] acpslv_l2db1_transfer_info;
  wire                                 [2:0] acpslv_l2db1_transfer_type;
  wire                                       acpslv_l2db2_ready;
  wire                                       acpslv_l2db2_release;
  wire                                       acpslv_l2db2_transfer;
  wire                                [25:0] acpslv_l2db2_transfer_info;
  wire                                 [2:0] acpslv_l2db2_transfer_type;
  wire                                       acpslv_l2db3_ready;
  wire                                       acpslv_l2db3_release;
  wire                                       acpslv_l2db3_transfer;
  wire                                [25:0] acpslv_l2db3_transfer_info;
  wire                                 [2:0] acpslv_l2db3_transfer_type;
  wire                                       acpslv_l2db4_ready;
  wire                                       acpslv_l2db4_release;
  wire                                       acpslv_l2db4_transfer;
  wire                                [25:0] acpslv_l2db4_transfer_info;
  wire                                 [2:0] acpslv_l2db4_transfer_type;
  wire                                       acpslv_l2db5_ready;
  wire                                       acpslv_l2db5_release;
  wire                                       acpslv_l2db5_transfer;
  wire                                [25:0] acpslv_l2db5_transfer_info;
  wire                                 [2:0] acpslv_l2db5_transfer_type;
  wire                                       acpslv_l2db6_ready;
  wire                                       acpslv_l2db6_release;
  wire                                       acpslv_l2db6_transfer;
  wire                                [25:0] acpslv_l2db6_transfer_info;
  wire                                 [2:0] acpslv_l2db6_transfer_type;
  wire                                       acpslv_l2db7_ready;
  wire                                       acpslv_l2db7_release;
  wire                                       acpslv_l2db7_transfer;
  wire                                [25:0] acpslv_l2db7_transfer_info;
  wire                                 [2:0] acpslv_l2db7_transfer_type;
  wire                                       acpslv_l2db8_ready;
  wire                                       acpslv_l2db8_release;
  wire                                       acpslv_l2db8_transfer;
  wire                                [25:0] acpslv_l2db8_transfer_info;
  wire                                 [2:0] acpslv_l2db8_transfer_type;
  wire                                       acpslv_l2db9_ready;
  wire                                       acpslv_l2db9_release;
  wire                                       acpslv_l2db9_transfer;
  wire                                [25:0] acpslv_l2db9_transfer_info;
  wire                                 [2:0] acpslv_l2db9_transfer_type;
  wire                                       acpslv_l2dbs_active;
  wire                                 [1:0] acpslv_l2dbs_dw_chunk;
  wire                               [127:0] acpslv_l2dbs_dw_data;
  wire                                 [3:0] acpslv_l2dbs_dw_id;
  wire                                       acpslv_l2dbs_dw_last;
  wire                                [15:0] acpslv_l2dbs_dw_strb;
  wire                                       acpslv_l2dbs_dw_valid;
  wire                                       acpslv_master_dr_ready;
  wire                                       acpslv_master_sactive;
  wire                                       acpslv_ramctl_active;
  wire                                       acpslv_tagctl_active_tc0;
  wire                                [40:0] acpslv_tagctl_addr1_tc0;
  wire                                 [7:0] acpslv_tagctl_attrs_tc1;
  wire                                       acpslv_tagctl_cluster_unique_tc1;
  wire                                       acpslv_tagctl_dirty_tc1;
  wire                                       acpslv_tagctl_early_valid_tc0;
  wire                                [34:0] acpslv_tagctl_ecc_tc0;
  wire                                       acpslv_tagctl_l2db_full_tc1;
  wire                                 [3:0] acpslv_tagctl_l2db_tc1;
  wire                                 [1:0] acpslv_tagctl_len_tc1;
  wire                                 [3:0] acpslv_tagctl_pass_tc0;
  wire                                 [1:0] acpslv_tagctl_pcrdtype_tc1;
  wire                                 [1:0] acpslv_tagctl_prot_tc1;
  wire                                 [2:0] acpslv_tagctl_reqbufid_tc0;
  wire                                       acpslv_tagctl_single_tc1;
  wire                                 [2:0] acpslv_tagctl_size_tc1;
  wire                                       acpslv_tagctl_slverr_tc1;
  wire                                       acpslv_tagctl_spec_valid_tc0;
  wire                                       acpslv_tagctl_static_pcredit_tc1;
  wire                                 [4:0] acpslv_tagctl_type_tc0;
  wire                                       acpslv_tagctl_valid_tc0;
  wire                                 [3:0] acpslv_tagctl_victim_way_tc1;
  wire                                [31:0] acpslv_tagctl_ways_tc0;
  wire                                [16:0] acpslv_tagctl_wr_state_tc0;
  wire                                 [4:0] acpslv_tagctl_write_tc0;
  wire                                       acpslv_victimctl_active;
  wire                                       acpslv_victimctl_age;
  wire                                 [2:0] acpslv_victimctl_id;
  wire                                [10:0] acpslv_victimctl_index;
  wire                                       acpslv_victimctl_valid;
  wire                                 [3:0] acpslv_victimctl_way;
  wire                                       acpslv_victimctl_wr;
  wire                                       afb0_done;
  wire                                 [3:0] afb0_l2dbs_id;
  wire                                       afb0_l2dbs_transfer;
  wire                                [23:0] afb0_l2dbs_transfer_info;
  wire                                [40:0] afb0_master_addr;
  wire                                 [7:0] afb0_master_attrs;
  wire                                       afb0_master_flush;
  wire                                 [6:0] afb0_master_id;
  wire                                 [3:0] afb0_master_l2db;
  wire                                 [1:0] afb0_master_len;
  wire                                       afb0_master_lock;
  wire                                 [4:0] afb0_master_opcode;
  wire                                 [1:0] afb0_master_pcrdtype;
  wire                                 [1:0] afb0_master_prot;
  wire                                       afb0_master_req;
  wire                                 [2:0] afb0_master_size;
  wire                                       afb0_master_static_pcredit;
  wire                                 [6:0] afb0_master_tgtid;
  wire                                       afb0_snoop_resp_alloc;
  wire                                       afb0_snoop_resp_dirty;
  wire                                       afb0_snoop_resp_migratory;
  wire                                       afb0_snoop_resp_valid;
  wire                                       afb0_snoop_resp_victim_age;
  wire                                       afb0_snoop_resp_victim_alloc;
  wire                                       afb0_snoop_resp_victim_dirty;
  wire                                       afb0_snoop_resp_victim_valid;
  wire                                       afb0_write_done;
  wire                                       afb1_done;
  wire                                 [3:0] afb1_l2dbs_id;
  wire                                       afb1_l2dbs_transfer;
  wire                                [23:0] afb1_l2dbs_transfer_info;
  wire                                [40:0] afb1_master_addr;
  wire                                 [7:0] afb1_master_attrs;
  wire                                       afb1_master_flush;
  wire                                 [6:0] afb1_master_id;
  wire                                 [3:0] afb1_master_l2db;
  wire                                 [1:0] afb1_master_len;
  wire                                       afb1_master_lock;
  wire                                 [4:0] afb1_master_opcode;
  wire                                 [1:0] afb1_master_pcrdtype;
  wire                                 [1:0] afb1_master_prot;
  wire                                       afb1_master_req;
  wire                                 [2:0] afb1_master_size;
  wire                                       afb1_master_static_pcredit;
  wire                                 [6:0] afb1_master_tgtid;
  wire                                       afb1_snoop_resp_alloc;
  wire                                       afb1_snoop_resp_dirty;
  wire                                       afb1_snoop_resp_migratory;
  wire                                       afb1_snoop_resp_valid;
  wire                                       afb1_snoop_resp_victim_age;
  wire                                       afb1_snoop_resp_victim_alloc;
  wire                                       afb1_snoop_resp_victim_dirty;
  wire                                       afb1_snoop_resp_victim_valid;
  wire                                       afb1_write_done;
  wire                                       afb2_done;
  wire                                 [3:0] afb2_l2dbs_id;
  wire                                       afb2_l2dbs_transfer;
  wire                                [23:0] afb2_l2dbs_transfer_info;
  wire                                [40:0] afb2_master_addr;
  wire                                 [7:0] afb2_master_attrs;
  wire                                       afb2_master_flush;
  wire                                 [6:0] afb2_master_id;
  wire                                 [3:0] afb2_master_l2db;
  wire                                 [1:0] afb2_master_len;
  wire                                       afb2_master_lock;
  wire                                 [4:0] afb2_master_opcode;
  wire                                 [1:0] afb2_master_pcrdtype;
  wire                                 [1:0] afb2_master_prot;
  wire                                       afb2_master_req;
  wire                                 [2:0] afb2_master_size;
  wire                                       afb2_master_static_pcredit;
  wire                                 [6:0] afb2_master_tgtid;
  wire                                       afb2_snoop_resp_alloc;
  wire                                       afb2_snoop_resp_dirty;
  wire                                       afb2_snoop_resp_migratory;
  wire                                       afb2_snoop_resp_valid;
  wire                                       afb2_snoop_resp_victim_age;
  wire                                       afb2_snoop_resp_victim_alloc;
  wire                                       afb2_snoop_resp_victim_dirty;
  wire                                       afb2_snoop_resp_victim_valid;
  wire                                       afb2_write_done;
  wire                                       afb3_done;
  wire                                 [3:0] afb3_l2dbs_id;
  wire                                       afb3_l2dbs_transfer;
  wire                                [23:0] afb3_l2dbs_transfer_info;
  wire                                [40:0] afb3_master_addr;
  wire                                 [7:0] afb3_master_attrs;
  wire                                       afb3_master_flush;
  wire                                 [6:0] afb3_master_id;
  wire                                 [3:0] afb3_master_l2db;
  wire                                 [1:0] afb3_master_len;
  wire                                       afb3_master_lock;
  wire                                 [4:0] afb3_master_opcode;
  wire                                 [1:0] afb3_master_pcrdtype;
  wire                                 [1:0] afb3_master_prot;
  wire                                       afb3_master_req;
  wire                                 [2:0] afb3_master_size;
  wire                                       afb3_master_static_pcredit;
  wire                                 [6:0] afb3_master_tgtid;
  wire                                       afb3_snoop_resp_alloc;
  wire                                       afb3_snoop_resp_dirty;
  wire                                       afb3_snoop_resp_migratory;
  wire                                       afb3_snoop_resp_valid;
  wire                                       afb3_snoop_resp_victim_age;
  wire                                       afb3_snoop_resp_victim_alloc;
  wire                                       afb3_snoop_resp_victim_dirty;
  wire                                       afb3_snoop_resp_victim_valid;
  wire                                       afb3_write_done;
  wire                                       afb4_done;
  wire                                 [3:0] afb4_l2dbs_id;
  wire                                       afb4_l2dbs_transfer;
  wire                                [23:0] afb4_l2dbs_transfer_info;
  wire                                [40:0] afb4_master_addr;
  wire                                 [7:0] afb4_master_attrs;
  wire                                       afb4_master_flush;
  wire                                 [6:0] afb4_master_id;
  wire                                 [3:0] afb4_master_l2db;
  wire                                 [1:0] afb4_master_len;
  wire                                       afb4_master_lock;
  wire                                 [4:0] afb4_master_opcode;
  wire                                 [1:0] afb4_master_pcrdtype;
  wire                                 [1:0] afb4_master_prot;
  wire                                       afb4_master_req;
  wire                                 [2:0] afb4_master_size;
  wire                                       afb4_master_static_pcredit;
  wire                                 [6:0] afb4_master_tgtid;
  wire                                       afb4_snoop_resp_alloc;
  wire                                       afb4_snoop_resp_dirty;
  wire                                       afb4_snoop_resp_migratory;
  wire                                       afb4_snoop_resp_valid;
  wire                                       afb4_snoop_resp_victim_age;
  wire                                       afb4_snoop_resp_victim_alloc;
  wire                                       afb4_snoop_resp_victim_dirty;
  wire                                       afb4_snoop_resp_victim_valid;
  wire                                       afb4_write_done;
  wire                                       afb5_done;
  wire                                 [3:0] afb5_l2dbs_id;
  wire                                       afb5_l2dbs_transfer;
  wire                                [23:0] afb5_l2dbs_transfer_info;
  wire                                [40:0] afb5_master_addr;
  wire                                 [7:0] afb5_master_attrs;
  wire                                       afb5_master_flush;
  wire                                 [6:0] afb5_master_id;
  wire                                 [3:0] afb5_master_l2db;
  wire                                 [1:0] afb5_master_len;
  wire                                       afb5_master_lock;
  wire                                 [4:0] afb5_master_opcode;
  wire                                 [1:0] afb5_master_pcrdtype;
  wire                                 [1:0] afb5_master_prot;
  wire                                       afb5_master_req;
  wire                                 [2:0] afb5_master_size;
  wire                                       afb5_master_static_pcredit;
  wire                                 [6:0] afb5_master_tgtid;
  wire                                       afb5_snoop_resp_alloc;
  wire                                       afb5_snoop_resp_dirty;
  wire                                       afb5_snoop_resp_migratory;
  wire                                       afb5_snoop_resp_valid;
  wire                                       afb5_snoop_resp_victim_age;
  wire                                       afb5_snoop_resp_victim_alloc;
  wire                                       afb5_snoop_resp_victim_dirty;
  wire                                       afb5_snoop_resp_victim_valid;
  wire                                       afb5_write_done;
  wire                                       clean_aclken;
  wire                                       clean_aclkens;
  wire                                       clk_ext_master;
  wire                                       config_broadcastcachemaint;
  wire                                       config_broadcastinner;
  wire                                       config_broadcastouter;
  wire                                 [2:0] config_l1_dc_size;
  wire                                 [3:0] config_l2_size;
  wire                                       config_l2rstdisable;
  wire                                 [6:0] config_nodeid;
  wire                                       config_sysbardisable;
  wire                                       cpuslv0_ac_ready;
  wire                                       cpuslv0_active;
  wire                                       cpuslv0_compack_active;
  wire                                 [6:0] cpuslv0_compack_tgtid;
  wire                                 [7:0] cpuslv0_compack_txnid;
  wire                                       cpuslv0_compack_valid;
  wire                                       cpuslv0_cr_age;
  wire                                       cpuslv0_cr_alloc;
  wire                                       cpuslv0_cr_dirty;
  wire                                 [2:0] cpuslv0_cr_id;
  wire                                       cpuslv0_cr_migratory;
  wire                                       cpuslv0_cr_valid;
  wire                                 [7:0] cpuslv0_delay_allocation;
  wire                                       cpuslv0_dvm_sync_resp;
  wire                                [10:0] cpuslv0_early_dr_index;
  wire                                       cpuslv0_early_dr_l2;
  wire                                 [7:0] cpuslv0_early_dr_ready;
  wire                                 [3:0] cpuslv0_early_dr_way;
  wire                                       cpuslv0_ecc_hz_tc2;
  wire                                [31:0] cpuslv0_force_miss_tc2;
  wire                                       cpuslv0_hz_tc2;
  wire                                       cpuslv0_hz_tc4;
  wire                                       cpuslv0_inv_all_starting;
  wire                                [15:0] cpuslv0_l2_way_used_tc2;
  wire                                [15:0] cpuslv0_l2_way_used_vc2;
  wire                                       cpuslv0_l2db0_ready;
  wire                                       cpuslv0_l2db0_release;
  wire                                       cpuslv0_l2db0_transfer;
  wire                                [23:0] cpuslv0_l2db0_transfer_info;
  wire                                 [2:0] cpuslv0_l2db0_transfer_type;
  wire                                       cpuslv0_l2db10_ready;
  wire                                       cpuslv0_l2db10_release;
  wire                                       cpuslv0_l2db10_transfer;
  wire                                [23:0] cpuslv0_l2db10_transfer_info;
  wire                                 [2:0] cpuslv0_l2db10_transfer_type;
  wire                                       cpuslv0_l2db1_ready;
  wire                                       cpuslv0_l2db1_release;
  wire                                       cpuslv0_l2db1_transfer;
  wire                                [23:0] cpuslv0_l2db1_transfer_info;
  wire                                 [2:0] cpuslv0_l2db1_transfer_type;
  wire                                       cpuslv0_l2db2_ready;
  wire                                       cpuslv0_l2db2_release;
  wire                                       cpuslv0_l2db2_transfer;
  wire                                [23:0] cpuslv0_l2db2_transfer_info;
  wire                                 [2:0] cpuslv0_l2db2_transfer_type;
  wire                                       cpuslv0_l2db3_ready;
  wire                                       cpuslv0_l2db3_release;
  wire                                       cpuslv0_l2db3_transfer;
  wire                                [23:0] cpuslv0_l2db3_transfer_info;
  wire                                 [2:0] cpuslv0_l2db3_transfer_type;
  wire                                       cpuslv0_l2db4_ready;
  wire                                       cpuslv0_l2db4_release;
  wire                                       cpuslv0_l2db4_transfer;
  wire                                [23:0] cpuslv0_l2db4_transfer_info;
  wire                                 [2:0] cpuslv0_l2db4_transfer_type;
  wire                                       cpuslv0_l2db5_ready;
  wire                                       cpuslv0_l2db5_release;
  wire                                       cpuslv0_l2db5_transfer;
  wire                                [23:0] cpuslv0_l2db5_transfer_info;
  wire                                 [2:0] cpuslv0_l2db5_transfer_type;
  wire                                       cpuslv0_l2db6_ready;
  wire                                       cpuslv0_l2db6_release;
  wire                                       cpuslv0_l2db6_transfer;
  wire                                [23:0] cpuslv0_l2db6_transfer_info;
  wire                                 [2:0] cpuslv0_l2db6_transfer_type;
  wire                                       cpuslv0_l2db7_ready;
  wire                                       cpuslv0_l2db7_release;
  wire                                       cpuslv0_l2db7_transfer;
  wire                                [23:0] cpuslv0_l2db7_transfer_info;
  wire                                 [2:0] cpuslv0_l2db7_transfer_type;
  wire                                       cpuslv0_l2db8_ready;
  wire                                       cpuslv0_l2db8_release;
  wire                                       cpuslv0_l2db8_transfer;
  wire                                [23:0] cpuslv0_l2db8_transfer_info;
  wire                                 [2:0] cpuslv0_l2db8_transfer_type;
  wire                                       cpuslv0_l2db9_ready;
  wire                                       cpuslv0_l2db9_release;
  wire                                       cpuslv0_l2db9_transfer;
  wire                                [23:0] cpuslv0_l2db9_transfer_info;
  wire                                 [2:0] cpuslv0_l2db9_transfer_type;
  wire                                       cpuslv0_l2dbs_active;
  wire                                 [3:0] cpuslv0_l2dbs_dw_chunks_valid;
  wire                               [255:0] cpuslv0_l2dbs_dw_data;
  wire                                       cpuslv0_l2dbs_dw_err;
  wire                                       cpuslv0_l2dbs_dw_fatal;
  wire                                 [3:0] cpuslv0_l2dbs_dw_id;
  wire                                       cpuslv0_l2dbs_dw_last;
  wire                                [31:0] cpuslv0_l2dbs_dw_strb;
  wire                                       cpuslv0_l2dbs_dw_valid;
  wire                                       cpuslv0_master_dr_ready;
  wire                                       cpuslv0_master_sactive;
  wire                                       cpuslv0_noncoh_since_barrier;
  wire                                       cpuslv0_ramctl_active;
  wire                                       cpuslv0_sample_waddrs;
  wire                                       cpuslv0_sample_waddrs_dsb;
  wire                                 [2:0] cpuslv0_snp_hz_id_tc2;
  wire                                       cpuslv0_snp_hz_tc2;
  wire                                       cpuslv0_snp_l2db_dirty_tc2;
  wire                                       cpuslv0_snp_l2db_hz_tc2;
  wire                                 [3:0] cpuslv0_snp_l2db_tc2;
  wire                                [40:0] cpuslv0_tagctl_addr1_tc0;
  wire                                [40:0] cpuslv0_tagctl_addr2_tc1;
  wire                                 [7:0] cpuslv0_tagctl_attrs_tc1;
  wire                                       cpuslv0_tagctl_cluster_unique_tc1;
  wire                                       cpuslv0_tagctl_dirty_tc1;
  wire                                       cpuslv0_tagctl_dvm_sync_tc0;
  wire                                       cpuslv0_tagctl_early_valid_tc0;
  wire                                [34:0] cpuslv0_tagctl_ecc_tc0;
  wire                                       cpuslv0_tagctl_l2db_full_tc1;
  wire                                 [3:0] cpuslv0_tagctl_l2db_tc1;
  wire                                       cpuslv0_tagctl_l2flushreq_tc0;
  wire                                 [1:0] cpuslv0_tagctl_len_tc1;
  wire                                       cpuslv0_tagctl_lock_tc1;
  wire                                 [3:0] cpuslv0_tagctl_pass_tc0;
  wire                                 [1:0] cpuslv0_tagctl_pcrdtype_tc1;
  wire                                 [1:0] cpuslv0_tagctl_prot_tc1;
  wire                                       cpuslv0_tagctl_reqbuf_dcu_tc1;
  wire                                 [2:0] cpuslv0_tagctl_reqbufid_tc0;
  wire                                 [2:0] cpuslv0_tagctl_size_tc1;
  wire                                       cpuslv0_tagctl_spec_valid_tc0;
  wire                                       cpuslv0_tagctl_static_pcredit_tc1;
  wire                                 [4:0] cpuslv0_tagctl_type_tc0;
  wire                                       cpuslv0_tagctl_valid_tc0;
  wire                                 [3:0] cpuslv0_tagctl_victim_way_tc1;
  wire                                [31:0] cpuslv0_tagctl_ways_tc0;
  wire                                [16:0] cpuslv0_tagctl_wr_state_tc0;
  wire                                 [4:0] cpuslv0_tagctl_write_tc0;
  wire                                       cpuslv0_victimctl_active;
  wire                                       cpuslv0_victimctl_age;
  wire                                 [2:0] cpuslv0_victimctl_id;
  wire                                [10:0] cpuslv0_victimctl_index;
  wire                                       cpuslv0_victimctl_iside;
  wire                                       cpuslv0_victimctl_nontemp;
  wire                                       cpuslv0_victimctl_valid;
  wire                                 [3:0] cpuslv0_victimctl_way;
  wire                                       cpuslv0_victimctl_wr;
  wire                                       cpuslv0_wfx_active;
  wire                                       cpuslv1_ac_ready;
  wire                                       cpuslv1_active;
  wire                                       cpuslv1_compack_active;
  wire                                 [6:0] cpuslv1_compack_tgtid;
  wire                                 [7:0] cpuslv1_compack_txnid;
  wire                                       cpuslv1_compack_valid;
  wire                                       cpuslv1_cr_age;
  wire                                       cpuslv1_cr_alloc;
  wire                                       cpuslv1_cr_dirty;
  wire                                 [2:0] cpuslv1_cr_id;
  wire                                       cpuslv1_cr_migratory;
  wire                                       cpuslv1_cr_valid;
  wire                                 [7:0] cpuslv1_delay_allocation;
  wire                                       cpuslv1_dvm_sync_resp;
  wire                                [10:0] cpuslv1_early_dr_index;
  wire                                       cpuslv1_early_dr_l2;
  wire                                 [7:0] cpuslv1_early_dr_ready;
  wire                                 [3:0] cpuslv1_early_dr_way;
  wire                                       cpuslv1_ecc_hz_tc2;
  wire                                [31:0] cpuslv1_force_miss_tc2;
  wire                                       cpuslv1_hz_tc2;
  wire                                       cpuslv1_hz_tc4;
  wire                                       cpuslv1_inv_all_starting;
  wire                                [15:0] cpuslv1_l2_way_used_tc2;
  wire                                [15:0] cpuslv1_l2_way_used_vc2;
  wire                                       cpuslv1_l2db0_ready;
  wire                                       cpuslv1_l2db0_release;
  wire                                       cpuslv1_l2db0_transfer;
  wire                                [23:0] cpuslv1_l2db0_transfer_info;
  wire                                 [2:0] cpuslv1_l2db0_transfer_type;
  wire                                       cpuslv1_l2db10_ready;
  wire                                       cpuslv1_l2db10_release;
  wire                                       cpuslv1_l2db10_transfer;
  wire                                [23:0] cpuslv1_l2db10_transfer_info;
  wire                                 [2:0] cpuslv1_l2db10_transfer_type;
  wire                                       cpuslv1_l2db1_ready;
  wire                                       cpuslv1_l2db1_release;
  wire                                       cpuslv1_l2db1_transfer;
  wire                                [23:0] cpuslv1_l2db1_transfer_info;
  wire                                 [2:0] cpuslv1_l2db1_transfer_type;
  wire                                       cpuslv1_l2db2_ready;
  wire                                       cpuslv1_l2db2_release;
  wire                                       cpuslv1_l2db2_transfer;
  wire                                [23:0] cpuslv1_l2db2_transfer_info;
  wire                                 [2:0] cpuslv1_l2db2_transfer_type;
  wire                                       cpuslv1_l2db3_ready;
  wire                                       cpuslv1_l2db3_release;
  wire                                       cpuslv1_l2db3_transfer;
  wire                                [23:0] cpuslv1_l2db3_transfer_info;
  wire                                 [2:0] cpuslv1_l2db3_transfer_type;
  wire                                       cpuslv1_l2db4_ready;
  wire                                       cpuslv1_l2db4_release;
  wire                                       cpuslv1_l2db4_transfer;
  wire                                [23:0] cpuslv1_l2db4_transfer_info;
  wire                                 [2:0] cpuslv1_l2db4_transfer_type;
  wire                                       cpuslv1_l2db5_ready;
  wire                                       cpuslv1_l2db5_release;
  wire                                       cpuslv1_l2db5_transfer;
  wire                                [23:0] cpuslv1_l2db5_transfer_info;
  wire                                 [2:0] cpuslv1_l2db5_transfer_type;
  wire                                       cpuslv1_l2db6_ready;
  wire                                       cpuslv1_l2db6_release;
  wire                                       cpuslv1_l2db6_transfer;
  wire                                [23:0] cpuslv1_l2db6_transfer_info;
  wire                                 [2:0] cpuslv1_l2db6_transfer_type;
  wire                                       cpuslv1_l2db7_ready;
  wire                                       cpuslv1_l2db7_release;
  wire                                       cpuslv1_l2db7_transfer;
  wire                                [23:0] cpuslv1_l2db7_transfer_info;
  wire                                 [2:0] cpuslv1_l2db7_transfer_type;
  wire                                       cpuslv1_l2db8_ready;
  wire                                       cpuslv1_l2db8_release;
  wire                                       cpuslv1_l2db8_transfer;
  wire                                [23:0] cpuslv1_l2db8_transfer_info;
  wire                                 [2:0] cpuslv1_l2db8_transfer_type;
  wire                                       cpuslv1_l2db9_ready;
  wire                                       cpuslv1_l2db9_release;
  wire                                       cpuslv1_l2db9_transfer;
  wire                                [23:0] cpuslv1_l2db9_transfer_info;
  wire                                 [2:0] cpuslv1_l2db9_transfer_type;
  wire                                       cpuslv1_l2dbs_active;
  wire                                 [3:0] cpuslv1_l2dbs_dw_chunks_valid;
  wire                               [255:0] cpuslv1_l2dbs_dw_data;
  wire                                       cpuslv1_l2dbs_dw_err;
  wire                                       cpuslv1_l2dbs_dw_fatal;
  wire                                 [3:0] cpuslv1_l2dbs_dw_id;
  wire                                       cpuslv1_l2dbs_dw_last;
  wire                                [31:0] cpuslv1_l2dbs_dw_strb;
  wire                                       cpuslv1_l2dbs_dw_valid;
  wire                                       cpuslv1_master_dr_ready;
  wire                                       cpuslv1_master_sactive;
  wire                                       cpuslv1_noncoh_since_barrier;
  wire                                       cpuslv1_ramctl_active;
  wire                                       cpuslv1_sample_waddrs;
  wire                                       cpuslv1_sample_waddrs_dsb;
  wire                                 [2:0] cpuslv1_snp_hz_id_tc2;
  wire                                       cpuslv1_snp_hz_tc2;
  wire                                       cpuslv1_snp_l2db_dirty_tc2;
  wire                                       cpuslv1_snp_l2db_hz_tc2;
  wire                                 [3:0] cpuslv1_snp_l2db_tc2;
  wire                                [40:0] cpuslv1_tagctl_addr1_tc0;
  wire                                [40:0] cpuslv1_tagctl_addr2_tc1;
  wire                                 [7:0] cpuslv1_tagctl_attrs_tc1;
  wire                                       cpuslv1_tagctl_cluster_unique_tc1;
  wire                                       cpuslv1_tagctl_dirty_tc1;
  wire                                       cpuslv1_tagctl_dvm_sync_tc0;
  wire                                       cpuslv1_tagctl_early_valid_tc0;
  wire                                [34:0] cpuslv1_tagctl_ecc_tc0;
  wire                                       cpuslv1_tagctl_l2db_full_tc1;
  wire                                 [3:0] cpuslv1_tagctl_l2db_tc1;
  wire                                       cpuslv1_tagctl_l2flushreq_tc0;
  wire                                 [1:0] cpuslv1_tagctl_len_tc1;
  wire                                       cpuslv1_tagctl_lock_tc1;
  wire                                 [3:0] cpuslv1_tagctl_pass_tc0;
  wire                                 [1:0] cpuslv1_tagctl_pcrdtype_tc1;
  wire                                 [1:0] cpuslv1_tagctl_prot_tc1;
  wire                                       cpuslv1_tagctl_reqbuf_dcu_tc1;
  wire                                 [2:0] cpuslv1_tagctl_reqbufid_tc0;
  wire                                 [2:0] cpuslv1_tagctl_size_tc1;
  wire                                       cpuslv1_tagctl_spec_valid_tc0;
  wire                                       cpuslv1_tagctl_static_pcredit_tc1;
  wire                                 [4:0] cpuslv1_tagctl_type_tc0;
  wire                                       cpuslv1_tagctl_valid_tc0;
  wire                                 [3:0] cpuslv1_tagctl_victim_way_tc1;
  wire                                [31:0] cpuslv1_tagctl_ways_tc0;
  wire                                [16:0] cpuslv1_tagctl_wr_state_tc0;
  wire                                 [4:0] cpuslv1_tagctl_write_tc0;
  wire                                       cpuslv1_victimctl_active;
  wire                                       cpuslv1_victimctl_age;
  wire                                 [2:0] cpuslv1_victimctl_id;
  wire                                [10:0] cpuslv1_victimctl_index;
  wire                                       cpuslv1_victimctl_iside;
  wire                                       cpuslv1_victimctl_nontemp;
  wire                                       cpuslv1_victimctl_valid;
  wire                                 [3:0] cpuslv1_victimctl_way;
  wire                                       cpuslv1_victimctl_wr;
  wire                                       cpuslv1_wfx_active;
  wire                                       cpuslv2_ac_ready;
  wire                                       cpuslv2_active;
  wire                                       cpuslv2_compack_active;
  wire                                 [6:0] cpuslv2_compack_tgtid;
  wire                                 [7:0] cpuslv2_compack_txnid;
  wire                                       cpuslv2_compack_valid;
  wire                                       cpuslv2_cr_age;
  wire                                       cpuslv2_cr_alloc;
  wire                                       cpuslv2_cr_dirty;
  wire                                 [2:0] cpuslv2_cr_id;
  wire                                       cpuslv2_cr_migratory;
  wire                                       cpuslv2_cr_valid;
  wire                                 [7:0] cpuslv2_delay_allocation;
  wire                                       cpuslv2_dvm_sync_resp;
  wire                                [10:0] cpuslv2_early_dr_index;
  wire                                       cpuslv2_early_dr_l2;
  wire                                 [7:0] cpuslv2_early_dr_ready;
  wire                                 [3:0] cpuslv2_early_dr_way;
  wire                                       cpuslv2_ecc_hz_tc2;
  wire                                [31:0] cpuslv2_force_miss_tc2;
  wire                                       cpuslv2_hz_tc2;
  wire                                       cpuslv2_hz_tc4;
  wire                                       cpuslv2_inv_all_starting;
  wire                                [15:0] cpuslv2_l2_way_used_tc2;
  wire                                [15:0] cpuslv2_l2_way_used_vc2;
  wire                                       cpuslv2_l2db0_ready;
  wire                                       cpuslv2_l2db0_release;
  wire                                       cpuslv2_l2db0_transfer;
  wire                                [23:0] cpuslv2_l2db0_transfer_info;
  wire                                 [2:0] cpuslv2_l2db0_transfer_type;
  wire                                       cpuslv2_l2db10_ready;
  wire                                       cpuslv2_l2db10_release;
  wire                                       cpuslv2_l2db10_transfer;
  wire                                [23:0] cpuslv2_l2db10_transfer_info;
  wire                                 [2:0] cpuslv2_l2db10_transfer_type;
  wire                                       cpuslv2_l2db1_ready;
  wire                                       cpuslv2_l2db1_release;
  wire                                       cpuslv2_l2db1_transfer;
  wire                                [23:0] cpuslv2_l2db1_transfer_info;
  wire                                 [2:0] cpuslv2_l2db1_transfer_type;
  wire                                       cpuslv2_l2db2_ready;
  wire                                       cpuslv2_l2db2_release;
  wire                                       cpuslv2_l2db2_transfer;
  wire                                [23:0] cpuslv2_l2db2_transfer_info;
  wire                                 [2:0] cpuslv2_l2db2_transfer_type;
  wire                                       cpuslv2_l2db3_ready;
  wire                                       cpuslv2_l2db3_release;
  wire                                       cpuslv2_l2db3_transfer;
  wire                                [23:0] cpuslv2_l2db3_transfer_info;
  wire                                 [2:0] cpuslv2_l2db3_transfer_type;
  wire                                       cpuslv2_l2db4_ready;
  wire                                       cpuslv2_l2db4_release;
  wire                                       cpuslv2_l2db4_transfer;
  wire                                [23:0] cpuslv2_l2db4_transfer_info;
  wire                                 [2:0] cpuslv2_l2db4_transfer_type;
  wire                                       cpuslv2_l2db5_ready;
  wire                                       cpuslv2_l2db5_release;
  wire                                       cpuslv2_l2db5_transfer;
  wire                                [23:0] cpuslv2_l2db5_transfer_info;
  wire                                 [2:0] cpuslv2_l2db5_transfer_type;
  wire                                       cpuslv2_l2db6_ready;
  wire                                       cpuslv2_l2db6_release;
  wire                                       cpuslv2_l2db6_transfer;
  wire                                [23:0] cpuslv2_l2db6_transfer_info;
  wire                                 [2:0] cpuslv2_l2db6_transfer_type;
  wire                                       cpuslv2_l2db7_ready;
  wire                                       cpuslv2_l2db7_release;
  wire                                       cpuslv2_l2db7_transfer;
  wire                                [23:0] cpuslv2_l2db7_transfer_info;
  wire                                 [2:0] cpuslv2_l2db7_transfer_type;
  wire                                       cpuslv2_l2db8_ready;
  wire                                       cpuslv2_l2db8_release;
  wire                                       cpuslv2_l2db8_transfer;
  wire                                [23:0] cpuslv2_l2db8_transfer_info;
  wire                                 [2:0] cpuslv2_l2db8_transfer_type;
  wire                                       cpuslv2_l2db9_ready;
  wire                                       cpuslv2_l2db9_release;
  wire                                       cpuslv2_l2db9_transfer;
  wire                                [23:0] cpuslv2_l2db9_transfer_info;
  wire                                 [2:0] cpuslv2_l2db9_transfer_type;
  wire                                       cpuslv2_l2dbs_active;
  wire                                 [3:0] cpuslv2_l2dbs_dw_chunks_valid;
  wire                               [255:0] cpuslv2_l2dbs_dw_data;
  wire                                       cpuslv2_l2dbs_dw_err;
  wire                                       cpuslv2_l2dbs_dw_fatal;
  wire                                 [3:0] cpuslv2_l2dbs_dw_id;
  wire                                       cpuslv2_l2dbs_dw_last;
  wire                                [31:0] cpuslv2_l2dbs_dw_strb;
  wire                                       cpuslv2_l2dbs_dw_valid;
  wire                                       cpuslv2_master_dr_ready;
  wire                                       cpuslv2_master_sactive;
  wire                                       cpuslv2_noncoh_since_barrier;
  wire                                       cpuslv2_ramctl_active;
  wire                                       cpuslv2_sample_waddrs;
  wire                                       cpuslv2_sample_waddrs_dsb;
  wire                                 [2:0] cpuslv2_snp_hz_id_tc2;
  wire                                       cpuslv2_snp_hz_tc2;
  wire                                       cpuslv2_snp_l2db_dirty_tc2;
  wire                                       cpuslv2_snp_l2db_hz_tc2;
  wire                                 [3:0] cpuslv2_snp_l2db_tc2;
  wire                                [40:0] cpuslv2_tagctl_addr1_tc0;
  wire                                [40:0] cpuslv2_tagctl_addr2_tc1;
  wire                                 [7:0] cpuslv2_tagctl_attrs_tc1;
  wire                                       cpuslv2_tagctl_cluster_unique_tc1;
  wire                                       cpuslv2_tagctl_dirty_tc1;
  wire                                       cpuslv2_tagctl_dvm_sync_tc0;
  wire                                       cpuslv2_tagctl_early_valid_tc0;
  wire                                [34:0] cpuslv2_tagctl_ecc_tc0;
  wire                                       cpuslv2_tagctl_l2db_full_tc1;
  wire                                 [3:0] cpuslv2_tagctl_l2db_tc1;
  wire                                       cpuslv2_tagctl_l2flushreq_tc0;
  wire                                 [1:0] cpuslv2_tagctl_len_tc1;
  wire                                       cpuslv2_tagctl_lock_tc1;
  wire                                 [3:0] cpuslv2_tagctl_pass_tc0;
  wire                                 [1:0] cpuslv2_tagctl_pcrdtype_tc1;
  wire                                 [1:0] cpuslv2_tagctl_prot_tc1;
  wire                                       cpuslv2_tagctl_reqbuf_dcu_tc1;
  wire                                 [2:0] cpuslv2_tagctl_reqbufid_tc0;
  wire                                 [2:0] cpuslv2_tagctl_size_tc1;
  wire                                       cpuslv2_tagctl_spec_valid_tc0;
  wire                                       cpuslv2_tagctl_static_pcredit_tc1;
  wire                                 [4:0] cpuslv2_tagctl_type_tc0;
  wire                                       cpuslv2_tagctl_valid_tc0;
  wire                                 [3:0] cpuslv2_tagctl_victim_way_tc1;
  wire                                [31:0] cpuslv2_tagctl_ways_tc0;
  wire                                [16:0] cpuslv2_tagctl_wr_state_tc0;
  wire                                 [4:0] cpuslv2_tagctl_write_tc0;
  wire                                       cpuslv2_victimctl_active;
  wire                                       cpuslv2_victimctl_age;
  wire                                 [2:0] cpuslv2_victimctl_id;
  wire                                [10:0] cpuslv2_victimctl_index;
  wire                                       cpuslv2_victimctl_iside;
  wire                                       cpuslv2_victimctl_nontemp;
  wire                                       cpuslv2_victimctl_valid;
  wire                                 [3:0] cpuslv2_victimctl_way;
  wire                                       cpuslv2_victimctl_wr;
  wire                                       cpuslv2_wfx_active;
  wire                                       cpuslv3_ac_ready;
  wire                                       cpuslv3_active;
  wire                                       cpuslv3_compack_active;
  wire                                 [6:0] cpuslv3_compack_tgtid;
  wire                                 [7:0] cpuslv3_compack_txnid;
  wire                                       cpuslv3_compack_valid;
  wire                                       cpuslv3_cr_age;
  wire                                       cpuslv3_cr_alloc;
  wire                                       cpuslv3_cr_dirty;
  wire                                 [2:0] cpuslv3_cr_id;
  wire                                       cpuslv3_cr_migratory;
  wire                                       cpuslv3_cr_valid;
  wire                                 [7:0] cpuslv3_delay_allocation;
  wire                                       cpuslv3_dvm_sync_resp;
  wire                                [10:0] cpuslv3_early_dr_index;
  wire                                       cpuslv3_early_dr_l2;
  wire                                 [7:0] cpuslv3_early_dr_ready;
  wire                                 [3:0] cpuslv3_early_dr_way;
  wire                                       cpuslv3_ecc_hz_tc2;
  wire                                [31:0] cpuslv3_force_miss_tc2;
  wire                                       cpuslv3_hz_tc2;
  wire                                       cpuslv3_hz_tc4;
  wire                                       cpuslv3_inv_all_starting;
  wire                                [15:0] cpuslv3_l2_way_used_tc2;
  wire                                [15:0] cpuslv3_l2_way_used_vc2;
  wire                                       cpuslv3_l2db0_ready;
  wire                                       cpuslv3_l2db0_release;
  wire                                       cpuslv3_l2db0_transfer;
  wire                                [23:0] cpuslv3_l2db0_transfer_info;
  wire                                 [2:0] cpuslv3_l2db0_transfer_type;
  wire                                       cpuslv3_l2db10_ready;
  wire                                       cpuslv3_l2db10_release;
  wire                                       cpuslv3_l2db10_transfer;
  wire                                [23:0] cpuslv3_l2db10_transfer_info;
  wire                                 [2:0] cpuslv3_l2db10_transfer_type;
  wire                                       cpuslv3_l2db1_ready;
  wire                                       cpuslv3_l2db1_release;
  wire                                       cpuslv3_l2db1_transfer;
  wire                                [23:0] cpuslv3_l2db1_transfer_info;
  wire                                 [2:0] cpuslv3_l2db1_transfer_type;
  wire                                       cpuslv3_l2db2_ready;
  wire                                       cpuslv3_l2db2_release;
  wire                                       cpuslv3_l2db2_transfer;
  wire                                [23:0] cpuslv3_l2db2_transfer_info;
  wire                                 [2:0] cpuslv3_l2db2_transfer_type;
  wire                                       cpuslv3_l2db3_ready;
  wire                                       cpuslv3_l2db3_release;
  wire                                       cpuslv3_l2db3_transfer;
  wire                                [23:0] cpuslv3_l2db3_transfer_info;
  wire                                 [2:0] cpuslv3_l2db3_transfer_type;
  wire                                       cpuslv3_l2db4_ready;
  wire                                       cpuslv3_l2db4_release;
  wire                                       cpuslv3_l2db4_transfer;
  wire                                [23:0] cpuslv3_l2db4_transfer_info;
  wire                                 [2:0] cpuslv3_l2db4_transfer_type;
  wire                                       cpuslv3_l2db5_ready;
  wire                                       cpuslv3_l2db5_release;
  wire                                       cpuslv3_l2db5_transfer;
  wire                                [23:0] cpuslv3_l2db5_transfer_info;
  wire                                 [2:0] cpuslv3_l2db5_transfer_type;
  wire                                       cpuslv3_l2db6_ready;
  wire                                       cpuslv3_l2db6_release;
  wire                                       cpuslv3_l2db6_transfer;
  wire                                [23:0] cpuslv3_l2db6_transfer_info;
  wire                                 [2:0] cpuslv3_l2db6_transfer_type;
  wire                                       cpuslv3_l2db7_ready;
  wire                                       cpuslv3_l2db7_release;
  wire                                       cpuslv3_l2db7_transfer;
  wire                                [23:0] cpuslv3_l2db7_transfer_info;
  wire                                 [2:0] cpuslv3_l2db7_transfer_type;
  wire                                       cpuslv3_l2db8_ready;
  wire                                       cpuslv3_l2db8_release;
  wire                                       cpuslv3_l2db8_transfer;
  wire                                [23:0] cpuslv3_l2db8_transfer_info;
  wire                                 [2:0] cpuslv3_l2db8_transfer_type;
  wire                                       cpuslv3_l2db9_ready;
  wire                                       cpuslv3_l2db9_release;
  wire                                       cpuslv3_l2db9_transfer;
  wire                                [23:0] cpuslv3_l2db9_transfer_info;
  wire                                 [2:0] cpuslv3_l2db9_transfer_type;
  wire                                       cpuslv3_l2dbs_active;
  wire                                 [3:0] cpuslv3_l2dbs_dw_chunks_valid;
  wire                               [255:0] cpuslv3_l2dbs_dw_data;
  wire                                       cpuslv3_l2dbs_dw_err;
  wire                                       cpuslv3_l2dbs_dw_fatal;
  wire                                 [3:0] cpuslv3_l2dbs_dw_id;
  wire                                       cpuslv3_l2dbs_dw_last;
  wire                                [31:0] cpuslv3_l2dbs_dw_strb;
  wire                                       cpuslv3_l2dbs_dw_valid;
  wire                                       cpuslv3_master_dr_ready;
  wire                                       cpuslv3_master_sactive;
  wire                                       cpuslv3_noncoh_since_barrier;
  wire                                       cpuslv3_ramctl_active;
  wire                                       cpuslv3_sample_waddrs;
  wire                                       cpuslv3_sample_waddrs_dsb;
  wire                                 [2:0] cpuslv3_snp_hz_id_tc2;
  wire                                       cpuslv3_snp_hz_tc2;
  wire                                       cpuslv3_snp_l2db_dirty_tc2;
  wire                                       cpuslv3_snp_l2db_hz_tc2;
  wire                                 [3:0] cpuslv3_snp_l2db_tc2;
  wire                                [40:0] cpuslv3_tagctl_addr1_tc0;
  wire                                [40:0] cpuslv3_tagctl_addr2_tc1;
  wire                                 [7:0] cpuslv3_tagctl_attrs_tc1;
  wire                                       cpuslv3_tagctl_cluster_unique_tc1;
  wire                                       cpuslv3_tagctl_dirty_tc1;
  wire                                       cpuslv3_tagctl_dvm_sync_tc0;
  wire                                       cpuslv3_tagctl_early_valid_tc0;
  wire                                [34:0] cpuslv3_tagctl_ecc_tc0;
  wire                                       cpuslv3_tagctl_l2db_full_tc1;
  wire                                 [3:0] cpuslv3_tagctl_l2db_tc1;
  wire                                       cpuslv3_tagctl_l2flushreq_tc0;
  wire                                 [1:0] cpuslv3_tagctl_len_tc1;
  wire                                       cpuslv3_tagctl_lock_tc1;
  wire                                 [3:0] cpuslv3_tagctl_pass_tc0;
  wire                                 [1:0] cpuslv3_tagctl_pcrdtype_tc1;
  wire                                 [1:0] cpuslv3_tagctl_prot_tc1;
  wire                                       cpuslv3_tagctl_reqbuf_dcu_tc1;
  wire                                 [2:0] cpuslv3_tagctl_reqbufid_tc0;
  wire                                 [2:0] cpuslv3_tagctl_size_tc1;
  wire                                       cpuslv3_tagctl_spec_valid_tc0;
  wire                                       cpuslv3_tagctl_static_pcredit_tc1;
  wire                                 [4:0] cpuslv3_tagctl_type_tc0;
  wire                                       cpuslv3_tagctl_valid_tc0;
  wire                                 [3:0] cpuslv3_tagctl_victim_way_tc1;
  wire                                [31:0] cpuslv3_tagctl_ways_tc0;
  wire                                [16:0] cpuslv3_tagctl_wr_state_tc0;
  wire                                 [4:0] cpuslv3_tagctl_write_tc0;
  wire                                       cpuslv3_victimctl_active;
  wire                                       cpuslv3_victimctl_age;
  wire                                 [2:0] cpuslv3_victimctl_id;
  wire                                [10:0] cpuslv3_victimctl_index;
  wire                                       cpuslv3_victimctl_iside;
  wire                                       cpuslv3_victimctl_nontemp;
  wire                                       cpuslv3_victimctl_valid;
  wire                                 [3:0] cpuslv3_victimctl_way;
  wire                                       cpuslv3_victimctl_wr;
  wire                                       cpuslv3_wfx_active;
  wire                                       dvm_comp_sync_outstanding;
  wire                                       inactm_rs;
  wire                                       l2_reached_retention;
  wire                                       l2db0_cpuslv0_data_active;
  wire                                       l2db0_cpuslv1_data_active;
  wire                                       l2db0_cpuslv2_data_active;
  wire                                       l2db0_cpuslv3_data_active;
  wire                                       l2db0_full_line;
  wire                                 [5:0] l2db0_master_addr;
  wire                                 [7:0] l2db0_master_attrs;
  wire                                 [1:0] l2db0_master_chunk;
  wire                               [127:0] l2db0_master_data;
  wire                                 [7:0] l2db0_master_dbid;
  wire                                       l2db0_master_dirty;
  wire                                       l2db0_master_err;
  wire                                 [5:0] l2db0_master_id;
  wire                                       l2db0_master_invalidated;
  wire                                       l2db0_master_last;
  wire                                 [1:0] l2db0_master_len;
  wire                                 [2:0] l2db0_master_opcode;
  wire                                       l2db0_master_prot;
  wire                                 [3:0] l2db0_master_qos;
  wire                                 [2:0] l2db0_master_size;
  wire                                       l2db0_master_snoop;
  wire                                 [2:0] l2db0_master_snpresp;
  wire                                [15:0] l2db0_master_strb;
  wire                                       l2db0_master_strex;
  wire                                 [6:0] l2db0_master_tgtid;
  wire                                       l2db0_master_unique;
  wire                                       l2db0_master_valid;
  wire                                 [7:0] l2db0_ramctl_banks;
  wire                               [255:0] l2db0_ramctl_data;
  wire                                       l2db0_ramctl_err;
  wire                                [10:0] l2db0_ramctl_index;
  wire                                 [1:0] l2db0_ramctl_rw;
  wire                                       l2db0_ramctl_valid;
  wire                                 [3:0] l2db0_ramctl_way;
  wire                                       l2db0_rmw_line;
  wire                                 [4:0] l2db0_slv_biuid;
  wire                                       l2db0_slv_bypass;
  wire                                 [1:0] l2db0_slv_chunk;
  wire                               [127:0] l2db0_slv_data;
  wire                                       l2db0_slv_done;
  wire                                       l2db0_slv_err;
  wire                                 [5:0] l2db0_slv_id;
  wire                                       l2db0_slv_last;
  wire                                       l2db0_slv_master_arb;
  wire                                       l2db0_slv_valid;
  wire                                       l2db0_snpslv_done;
  wire                                       l2db0_tagctl_available;
  wire                                       l2db0_tagctl_for_snoop;
  wire                                       l2db0_tagctl_for_write;
  wire                                       l2db10_cpuslv0_data_active;
  wire                                       l2db10_cpuslv1_data_active;
  wire                                       l2db10_cpuslv2_data_active;
  wire                                       l2db10_cpuslv3_data_active;
  wire                                       l2db10_full_line;
  wire                                 [5:0] l2db10_master_addr;
  wire                                 [7:0] l2db10_master_attrs;
  wire                                 [1:0] l2db10_master_chunk;
  wire                               [127:0] l2db10_master_data;
  wire                                 [7:0] l2db10_master_dbid;
  wire                                       l2db10_master_dirty;
  wire                                       l2db10_master_err;
  wire                                 [5:0] l2db10_master_id;
  wire                                       l2db10_master_invalidated;
  wire                                       l2db10_master_last;
  wire                                 [1:0] l2db10_master_len;
  wire                                 [2:0] l2db10_master_opcode;
  wire                                       l2db10_master_prot;
  wire                                 [3:0] l2db10_master_qos;
  wire                                 [2:0] l2db10_master_size;
  wire                                       l2db10_master_snoop;
  wire                                 [2:0] l2db10_master_snpresp;
  wire                                [15:0] l2db10_master_strb;
  wire                                       l2db10_master_strex;
  wire                                 [6:0] l2db10_master_tgtid;
  wire                                       l2db10_master_unique;
  wire                                       l2db10_master_valid;
  wire                                 [7:0] l2db10_ramctl_banks;
  wire                               [255:0] l2db10_ramctl_data;
  wire                                       l2db10_ramctl_err;
  wire                                [10:0] l2db10_ramctl_index;
  wire                                 [1:0] l2db10_ramctl_rw;
  wire                                       l2db10_ramctl_valid;
  wire                                 [3:0] l2db10_ramctl_way;
  wire                                       l2db10_rmw_line;
  wire                                 [4:0] l2db10_slv_biuid;
  wire                                       l2db10_slv_bypass;
  wire                                 [1:0] l2db10_slv_chunk;
  wire                               [127:0] l2db10_slv_data;
  wire                                       l2db10_slv_done;
  wire                                       l2db10_slv_err;
  wire                                 [5:0] l2db10_slv_id;
  wire                                       l2db10_slv_last;
  wire                                       l2db10_slv_master_arb;
  wire                                       l2db10_slv_valid;
  wire                                       l2db10_snpslv_done;
  wire                                       l2db10_tagctl_available;
  wire                                       l2db10_tagctl_for_snoop;
  wire                                       l2db10_tagctl_for_write;
  wire                                       l2db1_cpuslv0_data_active;
  wire                                       l2db1_cpuslv1_data_active;
  wire                                       l2db1_cpuslv2_data_active;
  wire                                       l2db1_cpuslv3_data_active;
  wire                                       l2db1_full_line;
  wire                                 [5:0] l2db1_master_addr;
  wire                                 [7:0] l2db1_master_attrs;
  wire                                 [1:0] l2db1_master_chunk;
  wire                               [127:0] l2db1_master_data;
  wire                                 [7:0] l2db1_master_dbid;
  wire                                       l2db1_master_dirty;
  wire                                       l2db1_master_err;
  wire                                 [5:0] l2db1_master_id;
  wire                                       l2db1_master_invalidated;
  wire                                       l2db1_master_last;
  wire                                 [1:0] l2db1_master_len;
  wire                                 [2:0] l2db1_master_opcode;
  wire                                       l2db1_master_prot;
  wire                                 [3:0] l2db1_master_qos;
  wire                                 [2:0] l2db1_master_size;
  wire                                       l2db1_master_snoop;
  wire                                 [2:0] l2db1_master_snpresp;
  wire                                [15:0] l2db1_master_strb;
  wire                                       l2db1_master_strex;
  wire                                 [6:0] l2db1_master_tgtid;
  wire                                       l2db1_master_unique;
  wire                                       l2db1_master_valid;
  wire                                 [7:0] l2db1_ramctl_banks;
  wire                               [255:0] l2db1_ramctl_data;
  wire                                       l2db1_ramctl_err;
  wire                                [10:0] l2db1_ramctl_index;
  wire                                 [1:0] l2db1_ramctl_rw;
  wire                                       l2db1_ramctl_valid;
  wire                                 [3:0] l2db1_ramctl_way;
  wire                                       l2db1_rmw_line;
  wire                                 [4:0] l2db1_slv_biuid;
  wire                                       l2db1_slv_bypass;
  wire                                 [1:0] l2db1_slv_chunk;
  wire                               [127:0] l2db1_slv_data;
  wire                                       l2db1_slv_done;
  wire                                       l2db1_slv_err;
  wire                                 [5:0] l2db1_slv_id;
  wire                                       l2db1_slv_last;
  wire                                       l2db1_slv_master_arb;
  wire                                       l2db1_slv_valid;
  wire                                       l2db1_snpslv_done;
  wire                                       l2db1_tagctl_available;
  wire                                       l2db1_tagctl_for_snoop;
  wire                                       l2db1_tagctl_for_write;
  wire                                       l2db2_cpuslv0_data_active;
  wire                                       l2db2_cpuslv1_data_active;
  wire                                       l2db2_cpuslv2_data_active;
  wire                                       l2db2_cpuslv3_data_active;
  wire                                       l2db2_full_line;
  wire                                 [5:0] l2db2_master_addr;
  wire                                 [7:0] l2db2_master_attrs;
  wire                                 [1:0] l2db2_master_chunk;
  wire                               [127:0] l2db2_master_data;
  wire                                 [7:0] l2db2_master_dbid;
  wire                                       l2db2_master_dirty;
  wire                                       l2db2_master_err;
  wire                                 [5:0] l2db2_master_id;
  wire                                       l2db2_master_invalidated;
  wire                                       l2db2_master_last;
  wire                                 [1:0] l2db2_master_len;
  wire                                 [2:0] l2db2_master_opcode;
  wire                                       l2db2_master_prot;
  wire                                 [3:0] l2db2_master_qos;
  wire                                 [2:0] l2db2_master_size;
  wire                                       l2db2_master_snoop;
  wire                                 [2:0] l2db2_master_snpresp;
  wire                                [15:0] l2db2_master_strb;
  wire                                       l2db2_master_strex;
  wire                                 [6:0] l2db2_master_tgtid;
  wire                                       l2db2_master_unique;
  wire                                       l2db2_master_valid;
  wire                                 [7:0] l2db2_ramctl_banks;
  wire                               [255:0] l2db2_ramctl_data;
  wire                                       l2db2_ramctl_err;
  wire                                [10:0] l2db2_ramctl_index;
  wire                                 [1:0] l2db2_ramctl_rw;
  wire                                       l2db2_ramctl_valid;
  wire                                 [3:0] l2db2_ramctl_way;
  wire                                       l2db2_rmw_line;
  wire                                 [4:0] l2db2_slv_biuid;
  wire                                       l2db2_slv_bypass;
  wire                                 [1:0] l2db2_slv_chunk;
  wire                               [127:0] l2db2_slv_data;
  wire                                       l2db2_slv_done;
  wire                                       l2db2_slv_err;
  wire                                 [5:0] l2db2_slv_id;
  wire                                       l2db2_slv_last;
  wire                                       l2db2_slv_master_arb;
  wire                                       l2db2_slv_valid;
  wire                                       l2db2_snpslv_done;
  wire                                       l2db2_tagctl_available;
  wire                                       l2db2_tagctl_for_snoop;
  wire                                       l2db2_tagctl_for_write;
  wire                                       l2db3_cpuslv0_data_active;
  wire                                       l2db3_cpuslv1_data_active;
  wire                                       l2db3_cpuslv2_data_active;
  wire                                       l2db3_cpuslv3_data_active;
  wire                                       l2db3_full_line;
  wire                                 [5:0] l2db3_master_addr;
  wire                                 [7:0] l2db3_master_attrs;
  wire                                 [1:0] l2db3_master_chunk;
  wire                               [127:0] l2db3_master_data;
  wire                                 [7:0] l2db3_master_dbid;
  wire                                       l2db3_master_dirty;
  wire                                       l2db3_master_err;
  wire                                 [5:0] l2db3_master_id;
  wire                                       l2db3_master_invalidated;
  wire                                       l2db3_master_last;
  wire                                 [1:0] l2db3_master_len;
  wire                                 [2:0] l2db3_master_opcode;
  wire                                       l2db3_master_prot;
  wire                                 [3:0] l2db3_master_qos;
  wire                                 [2:0] l2db3_master_size;
  wire                                       l2db3_master_snoop;
  wire                                 [2:0] l2db3_master_snpresp;
  wire                                [15:0] l2db3_master_strb;
  wire                                       l2db3_master_strex;
  wire                                 [6:0] l2db3_master_tgtid;
  wire                                       l2db3_master_unique;
  wire                                       l2db3_master_valid;
  wire                                 [7:0] l2db3_ramctl_banks;
  wire                               [255:0] l2db3_ramctl_data;
  wire                                       l2db3_ramctl_err;
  wire                                [10:0] l2db3_ramctl_index;
  wire                                 [1:0] l2db3_ramctl_rw;
  wire                                       l2db3_ramctl_valid;
  wire                                 [3:0] l2db3_ramctl_way;
  wire                                       l2db3_rmw_line;
  wire                                 [4:0] l2db3_slv_biuid;
  wire                                       l2db3_slv_bypass;
  wire                                 [1:0] l2db3_slv_chunk;
  wire                               [127:0] l2db3_slv_data;
  wire                                       l2db3_slv_done;
  wire                                       l2db3_slv_err;
  wire                                 [5:0] l2db3_slv_id;
  wire                                       l2db3_slv_last;
  wire                                       l2db3_slv_master_arb;
  wire                                       l2db3_slv_valid;
  wire                                       l2db3_snpslv_done;
  wire                                       l2db3_tagctl_available;
  wire                                       l2db3_tagctl_for_snoop;
  wire                                       l2db3_tagctl_for_write;
  wire                                       l2db4_cpuslv0_data_active;
  wire                                       l2db4_cpuslv1_data_active;
  wire                                       l2db4_cpuslv2_data_active;
  wire                                       l2db4_cpuslv3_data_active;
  wire                                       l2db4_full_line;
  wire                                 [5:0] l2db4_master_addr;
  wire                                 [7:0] l2db4_master_attrs;
  wire                                 [1:0] l2db4_master_chunk;
  wire                               [127:0] l2db4_master_data;
  wire                                 [7:0] l2db4_master_dbid;
  wire                                       l2db4_master_dirty;
  wire                                       l2db4_master_err;
  wire                                 [5:0] l2db4_master_id;
  wire                                       l2db4_master_invalidated;
  wire                                       l2db4_master_last;
  wire                                 [1:0] l2db4_master_len;
  wire                                 [2:0] l2db4_master_opcode;
  wire                                       l2db4_master_prot;
  wire                                 [3:0] l2db4_master_qos;
  wire                                 [2:0] l2db4_master_size;
  wire                                       l2db4_master_snoop;
  wire                                 [2:0] l2db4_master_snpresp;
  wire                                [15:0] l2db4_master_strb;
  wire                                       l2db4_master_strex;
  wire                                 [6:0] l2db4_master_tgtid;
  wire                                       l2db4_master_unique;
  wire                                       l2db4_master_valid;
  wire                                 [7:0] l2db4_ramctl_banks;
  wire                               [255:0] l2db4_ramctl_data;
  wire                                       l2db4_ramctl_err;
  wire                                [10:0] l2db4_ramctl_index;
  wire                                 [1:0] l2db4_ramctl_rw;
  wire                                       l2db4_ramctl_valid;
  wire                                 [3:0] l2db4_ramctl_way;
  wire                                       l2db4_rmw_line;
  wire                                 [4:0] l2db4_slv_biuid;
  wire                                       l2db4_slv_bypass;
  wire                                 [1:0] l2db4_slv_chunk;
  wire                               [127:0] l2db4_slv_data;
  wire                                       l2db4_slv_done;
  wire                                       l2db4_slv_err;
  wire                                 [5:0] l2db4_slv_id;
  wire                                       l2db4_slv_last;
  wire                                       l2db4_slv_master_arb;
  wire                                       l2db4_slv_valid;
  wire                                       l2db4_snpslv_done;
  wire                                       l2db4_tagctl_available;
  wire                                       l2db4_tagctl_for_snoop;
  wire                                       l2db4_tagctl_for_write;
  wire                                       l2db5_cpuslv0_data_active;
  wire                                       l2db5_cpuslv1_data_active;
  wire                                       l2db5_cpuslv2_data_active;
  wire                                       l2db5_cpuslv3_data_active;
  wire                                       l2db5_full_line;
  wire                                 [5:0] l2db5_master_addr;
  wire                                 [7:0] l2db5_master_attrs;
  wire                                 [1:0] l2db5_master_chunk;
  wire                               [127:0] l2db5_master_data;
  wire                                 [7:0] l2db5_master_dbid;
  wire                                       l2db5_master_dirty;
  wire                                       l2db5_master_err;
  wire                                 [5:0] l2db5_master_id;
  wire                                       l2db5_master_invalidated;
  wire                                       l2db5_master_last;
  wire                                 [1:0] l2db5_master_len;
  wire                                 [2:0] l2db5_master_opcode;
  wire                                       l2db5_master_prot;
  wire                                 [3:0] l2db5_master_qos;
  wire                                 [2:0] l2db5_master_size;
  wire                                       l2db5_master_snoop;
  wire                                 [2:0] l2db5_master_snpresp;
  wire                                [15:0] l2db5_master_strb;
  wire                                       l2db5_master_strex;
  wire                                 [6:0] l2db5_master_tgtid;
  wire                                       l2db5_master_unique;
  wire                                       l2db5_master_valid;
  wire                                 [7:0] l2db5_ramctl_banks;
  wire                               [255:0] l2db5_ramctl_data;
  wire                                       l2db5_ramctl_err;
  wire                                [10:0] l2db5_ramctl_index;
  wire                                 [1:0] l2db5_ramctl_rw;
  wire                                       l2db5_ramctl_valid;
  wire                                 [3:0] l2db5_ramctl_way;
  wire                                       l2db5_rmw_line;
  wire                                 [4:0] l2db5_slv_biuid;
  wire                                       l2db5_slv_bypass;
  wire                                 [1:0] l2db5_slv_chunk;
  wire                               [127:0] l2db5_slv_data;
  wire                                       l2db5_slv_done;
  wire                                       l2db5_slv_err;
  wire                                 [5:0] l2db5_slv_id;
  wire                                       l2db5_slv_last;
  wire                                       l2db5_slv_master_arb;
  wire                                       l2db5_slv_valid;
  wire                                       l2db5_snpslv_done;
  wire                                       l2db5_tagctl_available;
  wire                                       l2db5_tagctl_for_snoop;
  wire                                       l2db5_tagctl_for_write;
  wire                                       l2db6_cpuslv0_data_active;
  wire                                       l2db6_cpuslv1_data_active;
  wire                                       l2db6_cpuslv2_data_active;
  wire                                       l2db6_cpuslv3_data_active;
  wire                                       l2db6_full_line;
  wire                                 [5:0] l2db6_master_addr;
  wire                                 [7:0] l2db6_master_attrs;
  wire                                 [1:0] l2db6_master_chunk;
  wire                               [127:0] l2db6_master_data;
  wire                                 [7:0] l2db6_master_dbid;
  wire                                       l2db6_master_dirty;
  wire                                       l2db6_master_err;
  wire                                 [5:0] l2db6_master_id;
  wire                                       l2db6_master_invalidated;
  wire                                       l2db6_master_last;
  wire                                 [1:0] l2db6_master_len;
  wire                                 [2:0] l2db6_master_opcode;
  wire                                       l2db6_master_prot;
  wire                                 [3:0] l2db6_master_qos;
  wire                                 [2:0] l2db6_master_size;
  wire                                       l2db6_master_snoop;
  wire                                 [2:0] l2db6_master_snpresp;
  wire                                [15:0] l2db6_master_strb;
  wire                                       l2db6_master_strex;
  wire                                 [6:0] l2db6_master_tgtid;
  wire                                       l2db6_master_unique;
  wire                                       l2db6_master_valid;
  wire                                 [7:0] l2db6_ramctl_banks;
  wire                               [255:0] l2db6_ramctl_data;
  wire                                       l2db6_ramctl_err;
  wire                                [10:0] l2db6_ramctl_index;
  wire                                 [1:0] l2db6_ramctl_rw;
  wire                                       l2db6_ramctl_valid;
  wire                                 [3:0] l2db6_ramctl_way;
  wire                                       l2db6_rmw_line;
  wire                                 [4:0] l2db6_slv_biuid;
  wire                                       l2db6_slv_bypass;
  wire                                 [1:0] l2db6_slv_chunk;
  wire                               [127:0] l2db6_slv_data;
  wire                                       l2db6_slv_done;
  wire                                       l2db6_slv_err;
  wire                                 [5:0] l2db6_slv_id;
  wire                                       l2db6_slv_last;
  wire                                       l2db6_slv_master_arb;
  wire                                       l2db6_slv_valid;
  wire                                       l2db6_snpslv_done;
  wire                                       l2db6_tagctl_available;
  wire                                       l2db6_tagctl_for_snoop;
  wire                                       l2db6_tagctl_for_write;
  wire                                       l2db7_cpuslv0_data_active;
  wire                                       l2db7_cpuslv1_data_active;
  wire                                       l2db7_cpuslv2_data_active;
  wire                                       l2db7_cpuslv3_data_active;
  wire                                       l2db7_full_line;
  wire                                 [5:0] l2db7_master_addr;
  wire                                 [7:0] l2db7_master_attrs;
  wire                                 [1:0] l2db7_master_chunk;
  wire                               [127:0] l2db7_master_data;
  wire                                 [7:0] l2db7_master_dbid;
  wire                                       l2db7_master_dirty;
  wire                                       l2db7_master_err;
  wire                                 [5:0] l2db7_master_id;
  wire                                       l2db7_master_invalidated;
  wire                                       l2db7_master_last;
  wire                                 [1:0] l2db7_master_len;
  wire                                 [2:0] l2db7_master_opcode;
  wire                                       l2db7_master_prot;
  wire                                 [3:0] l2db7_master_qos;
  wire                                 [2:0] l2db7_master_size;
  wire                                       l2db7_master_snoop;
  wire                                 [2:0] l2db7_master_snpresp;
  wire                                [15:0] l2db7_master_strb;
  wire                                       l2db7_master_strex;
  wire                                 [6:0] l2db7_master_tgtid;
  wire                                       l2db7_master_unique;
  wire                                       l2db7_master_valid;
  wire                                 [7:0] l2db7_ramctl_banks;
  wire                               [255:0] l2db7_ramctl_data;
  wire                                       l2db7_ramctl_err;
  wire                                [10:0] l2db7_ramctl_index;
  wire                                 [1:0] l2db7_ramctl_rw;
  wire                                       l2db7_ramctl_valid;
  wire                                 [3:0] l2db7_ramctl_way;
  wire                                       l2db7_rmw_line;
  wire                                 [4:0] l2db7_slv_biuid;
  wire                                       l2db7_slv_bypass;
  wire                                 [1:0] l2db7_slv_chunk;
  wire                               [127:0] l2db7_slv_data;
  wire                                       l2db7_slv_done;
  wire                                       l2db7_slv_err;
  wire                                 [5:0] l2db7_slv_id;
  wire                                       l2db7_slv_last;
  wire                                       l2db7_slv_master_arb;
  wire                                       l2db7_slv_valid;
  wire                                       l2db7_snpslv_done;
  wire                                       l2db7_tagctl_available;
  wire                                       l2db7_tagctl_for_snoop;
  wire                                       l2db7_tagctl_for_write;
  wire                                       l2db8_cpuslv0_data_active;
  wire                                       l2db8_cpuslv1_data_active;
  wire                                       l2db8_cpuslv2_data_active;
  wire                                       l2db8_cpuslv3_data_active;
  wire                                       l2db8_full_line;
  wire                                 [5:0] l2db8_master_addr;
  wire                                 [7:0] l2db8_master_attrs;
  wire                                 [1:0] l2db8_master_chunk;
  wire                               [127:0] l2db8_master_data;
  wire                                 [7:0] l2db8_master_dbid;
  wire                                       l2db8_master_dirty;
  wire                                       l2db8_master_err;
  wire                                 [5:0] l2db8_master_id;
  wire                                       l2db8_master_invalidated;
  wire                                       l2db8_master_last;
  wire                                 [1:0] l2db8_master_len;
  wire                                 [2:0] l2db8_master_opcode;
  wire                                       l2db8_master_prot;
  wire                                 [3:0] l2db8_master_qos;
  wire                                 [2:0] l2db8_master_size;
  wire                                       l2db8_master_snoop;
  wire                                 [2:0] l2db8_master_snpresp;
  wire                                [15:0] l2db8_master_strb;
  wire                                       l2db8_master_strex;
  wire                                 [6:0] l2db8_master_tgtid;
  wire                                       l2db8_master_unique;
  wire                                       l2db8_master_valid;
  wire                                 [7:0] l2db8_ramctl_banks;
  wire                               [255:0] l2db8_ramctl_data;
  wire                                       l2db8_ramctl_err;
  wire                                [10:0] l2db8_ramctl_index;
  wire                                 [1:0] l2db8_ramctl_rw;
  wire                                       l2db8_ramctl_valid;
  wire                                 [3:0] l2db8_ramctl_way;
  wire                                       l2db8_rmw_line;
  wire                                 [4:0] l2db8_slv_biuid;
  wire                                       l2db8_slv_bypass;
  wire                                 [1:0] l2db8_slv_chunk;
  wire                               [127:0] l2db8_slv_data;
  wire                                       l2db8_slv_done;
  wire                                       l2db8_slv_err;
  wire                                 [5:0] l2db8_slv_id;
  wire                                       l2db8_slv_last;
  wire                                       l2db8_slv_master_arb;
  wire                                       l2db8_slv_valid;
  wire                                       l2db8_snpslv_done;
  wire                                       l2db8_tagctl_available;
  wire                                       l2db8_tagctl_for_snoop;
  wire                                       l2db8_tagctl_for_write;
  wire                                       l2db9_cpuslv0_data_active;
  wire                                       l2db9_cpuslv1_data_active;
  wire                                       l2db9_cpuslv2_data_active;
  wire                                       l2db9_cpuslv3_data_active;
  wire                                       l2db9_full_line;
  wire                                 [5:0] l2db9_master_addr;
  wire                                 [7:0] l2db9_master_attrs;
  wire                                 [1:0] l2db9_master_chunk;
  wire                               [127:0] l2db9_master_data;
  wire                                 [7:0] l2db9_master_dbid;
  wire                                       l2db9_master_dirty;
  wire                                       l2db9_master_err;
  wire                                 [5:0] l2db9_master_id;
  wire                                       l2db9_master_invalidated;
  wire                                       l2db9_master_last;
  wire                                 [1:0] l2db9_master_len;
  wire                                 [2:0] l2db9_master_opcode;
  wire                                       l2db9_master_prot;
  wire                                 [3:0] l2db9_master_qos;
  wire                                 [2:0] l2db9_master_size;
  wire                                       l2db9_master_snoop;
  wire                                 [2:0] l2db9_master_snpresp;
  wire                                [15:0] l2db9_master_strb;
  wire                                       l2db9_master_strex;
  wire                                 [6:0] l2db9_master_tgtid;
  wire                                       l2db9_master_unique;
  wire                                       l2db9_master_valid;
  wire                                 [7:0] l2db9_ramctl_banks;
  wire                               [255:0] l2db9_ramctl_data;
  wire                                       l2db9_ramctl_err;
  wire                                [10:0] l2db9_ramctl_index;
  wire                                 [1:0] l2db9_ramctl_rw;
  wire                                       l2db9_ramctl_valid;
  wire                                 [3:0] l2db9_ramctl_way;
  wire                                       l2db9_rmw_line;
  wire                                 [4:0] l2db9_slv_biuid;
  wire                                       l2db9_slv_bypass;
  wire                                 [1:0] l2db9_slv_chunk;
  wire                               [127:0] l2db9_slv_data;
  wire                                       l2db9_slv_done;
  wire                                       l2db9_slv_err;
  wire                                 [5:0] l2db9_slv_id;
  wire                                       l2db9_slv_last;
  wire                                       l2db9_slv_master_arb;
  wire                                       l2db9_slv_valid;
  wire                                       l2db9_snpslv_done;
  wire                                       l2db9_tagctl_available;
  wire                                       l2db9_tagctl_for_snoop;
  wire                                       l2db9_tagctl_for_write;
  wire                                       l2flushreq_rs;
  wire                                       leaving_reset;
  wire                                 [5:0] master_acpslv_dr_id;
  wire                                       master_acpslv_dr_valid;
  wire                                 [3:0] master_acpslv_l2_waiting;
  wire                                 [1:0] master_acpslv_pcrdtype;
  wire                                 [3:0] master_acpslv_reqbuf_retry;
  wire                                       master_active;
  wire                                       master_afb0_ack;
  wire                                       master_afb1_ack;
  wire                                       master_afb2_ack;
  wire                                       master_afb3_ack;
  wire                                       master_afb4_ack;
  wire                                       master_afb5_ack;
  wire                                 [3:0] master_afb_waddr_id;
  wire                                       master_cpuslv0_barrier_db_valid;
  wire                                       master_cpuslv0_dev_db_valid;
  wire                                 [5:0] master_cpuslv0_dr_id;
  wire                                       master_cpuslv0_dr_valid;
  wire                                 [7:0] master_cpuslv0_l2_waiting;
  wire                                 [1:0] master_cpuslv0_pcrdtype;
  wire                                 [7:0] master_cpuslv0_reqbuf_retry;
  wire                                       master_cpuslv0_strex_db_valid;
  wire                                       master_cpuslv0_waddrs_valid;
  wire                                       master_cpuslv1_barrier_db_valid;
  wire                                       master_cpuslv1_dev_db_valid;
  wire                                 [5:0] master_cpuslv1_dr_id;
  wire                                       master_cpuslv1_dr_valid;
  wire                                 [7:0] master_cpuslv1_l2_waiting;
  wire                                 [1:0] master_cpuslv1_pcrdtype;
  wire                                 [7:0] master_cpuslv1_reqbuf_retry;
  wire                                       master_cpuslv1_strex_db_valid;
  wire                                       master_cpuslv1_waddrs_valid;
  wire                                       master_cpuslv2_barrier_db_valid;
  wire                                       master_cpuslv2_dev_db_valid;
  wire                                 [5:0] master_cpuslv2_dr_id;
  wire                                       master_cpuslv2_dr_valid;
  wire                                 [7:0] master_cpuslv2_l2_waiting;
  wire                                 [1:0] master_cpuslv2_pcrdtype;
  wire                                 [7:0] master_cpuslv2_reqbuf_retry;
  wire                                       master_cpuslv2_strex_db_valid;
  wire                                       master_cpuslv2_waddrs_valid;
  wire                                       master_cpuslv3_barrier_db_valid;
  wire                                       master_cpuslv3_dev_db_valid;
  wire                                 [5:0] master_cpuslv3_dr_id;
  wire                                       master_cpuslv3_dr_valid;
  wire                                 [7:0] master_cpuslv3_l2_waiting;
  wire                                 [1:0] master_cpuslv3_pcrdtype;
  wire                                 [7:0] master_cpuslv3_reqbuf_retry;
  wire                                       master_cpuslv3_strex_db_valid;
  wire                                       master_cpuslv3_waddrs_valid;
  wire                                 [1:0] master_db_resp;
  wire                                 [3:0] master_db_waddr;
  wire                                       master_db_waddr_valid;
  wire                                 [1:0] master_dr_chunk;
  wire                               [127:0] master_dr_data;
  wire                                 [3:0] master_dr_resp;
  wire                                       master_early_dr_barrier;
  wire                                 [1:0] master_early_dr_chunk;
  wire                               [127:0] master_early_dr_data;
  wire                                 [7:0] master_early_dr_dbid;
  wire                                 [5:0] master_early_dr_id;
  wire                                       master_early_dr_ready;
  wire                                 [3:0] master_early_dr_resp;
  wire                                       master_early_dr_same;
  wire                                 [6:0] master_early_dr_srcid;
  wire                                       master_early_dr_valid;
  wire                                       master_hz_cu_tc2;
  wire                                       master_hz_dev_tc2;
  wire                                       master_hz_dirty_tc2;
  wire                                       master_hz_l2db_tc2;
  wire                                       master_hz_tc2;
  wire                                       master_hz_tc4;
  wire                                 [3:0] master_hz_waddr_tc4;
  wire                                       master_l2db0_ready;
  wire                                       master_l2db10_ready;
  wire                                       master_l2db1_ready;
  wire                                       master_l2db2_ready;
  wire                                       master_l2db3_ready;
  wire                                       master_l2db4_ready;
  wire                                       master_l2db5_ready;
  wire                                       master_l2db6_ready;
  wire                                       master_l2db7_ready;
  wire                                       master_l2db8_ready;
  wire                                       master_l2db9_ready;
  wire                                 [3:0] master_l2db_tc2;
  wire                                       master_linkactive;
  wire                                       master_ncoh_db;
  wire                                       master_ramctl_active;
  wire                                 [3:0] master_ramctl_chunks;
  wire                               [255:0] master_ramctl_data;
  wire                                [10:0] master_ramctl_index;
  wire                                       master_ramctl_valid;
  wire                                 [3:0] master_ramctl_way;
  wire                                       master_rsp_comp_valid;
  wire                                 [7:0] master_rsp_dbid;
  wire                                       master_rsp_dbid_valid;
  wire                                       master_rsp_readreceipt_valid;
  wire                                 [3:0] master_rsp_resp;
  wire                                 [6:0] master_rsp_srcid;
  wire                                 [6:0] master_rsp_txnid;
  wire                                       master_rxla_deactivate;
  wire                                       master_rxla_run;
  wire                                       master_rxla_stop;
  wire                                       master_snpslv_db_valid;
  wire                                       master_snpslv_dr_valid;
  wire                                 [1:0] master_snpslv_pcrdtype;
  wire                                       master_snpslv_reqbuf_retry;
  wire                                       master_snpslv_waddrs_valid;
  wire                                       master_txla_deactivate;
  wire                                       master_txla_run;
  wire                                [15:0] master_waddr_valid;
  wire                                       master_writes_active;
  wire                                       ram_idle_count_max;
  wire                                       ramctl_active;
  wire                                       ramctl_awake;
  wire                               [127:0] ramctl_bypass_data;
  wire                                       ramctl_bypass_err;
  wire                                       ramctl_bypassed_err;
  wire                                       ramctl_ecc_flush_active;
  wire                                [10:0] ramctl_ecc_flush_index;
  wire                                       ramctl_ecc_flush_req;
  wire                                 [3:0] ramctl_ecc_flush_way;
  wire                                       ramctl_l2db0_ready;
  wire                                       ramctl_l2db10_ready;
  wire                                       ramctl_l2db1_ready;
  wire                                       ramctl_l2db2_ready;
  wire                                       ramctl_l2db3_ready;
  wire                                       ramctl_l2db4_ready;
  wire                                       ramctl_l2db5_ready;
  wire                                       ramctl_l2db6_ready;
  wire                                       ramctl_l2db7_ready;
  wire                                       ramctl_l2db8_ready;
  wire                                       ramctl_l2db9_ready;
  wire                                       ramctl_l2dbs_bypass;
  wire                                 [3:0] ramctl_l2dbs_bypass_id;
  wire                                 [1:0] ramctl_l2dbs_chunk;
  wire                               [255:0] ramctl_l2dbs_data;
  wire                                       ramctl_l2dbs_err;
  wire                                 [3:0] ramctl_l2dbs_id;
  wire                                       ramctl_l2dbs_last;
  wire                                       ramctl_l2dbs_valid;
  wire                                       ramctl_mask_tc2;
  wire                                       ramctl_master_accepted;
  wire                                       ramctl_master_ready;
  wire                                       ramctl_tagctl_ready;
  wire                                       reset_n;
  wire                                 [6:0] sam_tgtid_tc2;
  wire                                       snpslv_acpslv_compack_ready;
  wire                                       snpslv_active;
  wire                                       snpslv_cpuslv0_compack_ready;
  wire                                       snpslv_cpuslv1_compack_ready;
  wire                                       snpslv_cpuslv2_compack_ready;
  wire                                       snpslv_cpuslv3_compack_ready;
  wire                                       snpslv_ecc_hz_tc2;
  wire                                       snpslv_hz_tc2;
  wire                                       snpslv_hz_tc4;
  wire                                [15:0] snpslv_l2_way_used_tc2;
  wire                                [15:0] snpslv_l2_way_used_vc2;
  wire                                       snpslv_l2db0_invalidate;
  wire                                       snpslv_l2db0_makeshared;
  wire                                       snpslv_l2db0_release;
  wire                                       snpslv_l2db0_transfer;
  wire                                [28:0] snpslv_l2db0_transfer_info;
  wire                                 [2:0] snpslv_l2db0_transfer_type;
  wire                                       snpslv_l2db10_invalidate;
  wire                                       snpslv_l2db10_makeshared;
  wire                                       snpslv_l2db10_release;
  wire                                       snpslv_l2db10_transfer;
  wire                                [28:0] snpslv_l2db10_transfer_info;
  wire                                 [2:0] snpslv_l2db10_transfer_type;
  wire                                       snpslv_l2db1_invalidate;
  wire                                       snpslv_l2db1_makeshared;
  wire                                       snpslv_l2db1_release;
  wire                                       snpslv_l2db1_transfer;
  wire                                [28:0] snpslv_l2db1_transfer_info;
  wire                                 [2:0] snpslv_l2db1_transfer_type;
  wire                                       snpslv_l2db2_invalidate;
  wire                                       snpslv_l2db2_makeshared;
  wire                                       snpslv_l2db2_release;
  wire                                       snpslv_l2db2_transfer;
  wire                                [28:0] snpslv_l2db2_transfer_info;
  wire                                 [2:0] snpslv_l2db2_transfer_type;
  wire                                       snpslv_l2db3_invalidate;
  wire                                       snpslv_l2db3_makeshared;
  wire                                       snpslv_l2db3_release;
  wire                                       snpslv_l2db3_transfer;
  wire                                [28:0] snpslv_l2db3_transfer_info;
  wire                                 [2:0] snpslv_l2db3_transfer_type;
  wire                                       snpslv_l2db4_invalidate;
  wire                                       snpslv_l2db4_makeshared;
  wire                                       snpslv_l2db4_release;
  wire                                       snpslv_l2db4_transfer;
  wire                                [28:0] snpslv_l2db4_transfer_info;
  wire                                 [2:0] snpslv_l2db4_transfer_type;
  wire                                       snpslv_l2db5_invalidate;
  wire                                       snpslv_l2db5_makeshared;
  wire                                       snpslv_l2db5_release;
  wire                                       snpslv_l2db5_transfer;
  wire                                [28:0] snpslv_l2db5_transfer_info;
  wire                                 [2:0] snpslv_l2db5_transfer_type;
  wire                                       snpslv_l2db6_invalidate;
  wire                                       snpslv_l2db6_makeshared;
  wire                                       snpslv_l2db6_release;
  wire                                       snpslv_l2db6_transfer;
  wire                                [28:0] snpslv_l2db6_transfer_info;
  wire                                 [2:0] snpslv_l2db6_transfer_type;
  wire                                       snpslv_l2db7_invalidate;
  wire                                       snpslv_l2db7_makeshared;
  wire                                       snpslv_l2db7_release;
  wire                                       snpslv_l2db7_transfer;
  wire                                [28:0] snpslv_l2db7_transfer_info;
  wire                                 [2:0] snpslv_l2db7_transfer_type;
  wire                                       snpslv_l2db8_invalidate;
  wire                                       snpslv_l2db8_makeshared;
  wire                                       snpslv_l2db8_release;
  wire                                       snpslv_l2db8_transfer;
  wire                                [28:0] snpslv_l2db8_transfer_info;
  wire                                 [2:0] snpslv_l2db8_transfer_type;
  wire                                       snpslv_l2db9_invalidate;
  wire                                       snpslv_l2db9_makeshared;
  wire                                       snpslv_l2db9_release;
  wire                                       snpslv_l2db9_transfer;
  wire                                [28:0] snpslv_l2db9_transfer_info;
  wire                                 [2:0] snpslv_l2db9_transfer_type;
  wire                                       snpslv_l2dbs_active;
  wire                                       snpslv_master_active;
  wire                                       snpslv_ramctl_active;
  wire                                       snpslv_retention_active;
  wire                                       snpslv_rxsnp_active;
  wire                                       snpslv_sample_waddrs;
  wire                                       snpslv_tagctl_active_tc0;
  wire                                [41:0] snpslv_tagctl_addr1_tc0;
  wire                                [40:0] snpslv_tagctl_addr2_tc1;
  wire                                 [7:0] snpslv_tagctl_attrs_tc1;
  wire                                       snpslv_tagctl_cluster_unique_tc1;
  wire                                       snpslv_tagctl_dirty_tc1;
  wire                                       snpslv_tagctl_dvm_sync_tc0;
  wire                                       snpslv_tagctl_early_valid_tc0;
  wire                                [34:0] snpslv_tagctl_ecc_tc0;
  wire                                 [3:0] snpslv_tagctl_l2db_tc1;
  wire                                 [3:0] snpslv_tagctl_pass_tc0;
  wire                                 [1:0] snpslv_tagctl_pcrdtype_tc1;
  wire                                 [2:0] snpslv_tagctl_reqbufid_tc0;
  wire                                       snpslv_tagctl_spec_valid_tc0;
  wire                                       snpslv_tagctl_static_pcredit_tc1;
  wire                                 [4:0] snpslv_tagctl_type_tc0;
  wire                                       snpslv_tagctl_valid_tc0;
  wire                                [31:0] snpslv_tagctl_ways_tc0;
  wire                                [16:0] snpslv_tagctl_wr_state_tc0;
  wire                                 [4:0] snpslv_tagctl_write_tc0;
  wire                                       snpslv_txrsp_req;
  wire                                       standbywfil2_req;
  wire                                       tagctl_acpslv_noncoh_only;
  wire                                       tagctl_acpslv_ready_tc0;
  wire                                       tagctl_active;
  wire                                [41:6] tagctl_addr_tc1;
  wire                                [40:6] tagctl_addr_tc3;
  wire                                       tagctl_addr_valid_tc1;
  wire                                       tagctl_addr_valid_tc3;
  wire                                       tagctl_alloc_for_snoop;
  wire                                       tagctl_alloc_for_write;
  wire                                       tagctl_cluster_unique_tc3;
  wire                                 [3:0] tagctl_cpu_dvm_sync_tc4;
  wire                                       tagctl_cpu_sync_tc1;
  wire                                [40:0] tagctl_cpuslv0_ac_addr;
  wire                                 [2:0] tagctl_cpuslv0_ac_id;
  wire                                 [3:0] tagctl_cpuslv0_ac_l2db_id;
  wire                                 [3:0] tagctl_cpuslv0_ac_snoop;
  wire                                       tagctl_cpuslv0_ac_valid;
  wire                                 [3:0] tagctl_cpuslv0_ac_way;
  wire                                       tagctl_cpuslv0_noncoh_only;
  wire                                       tagctl_cpuslv0_ready_tc0;
  wire                                       tagctl_cpuslv0_snp_active;
  wire                                [40:0] tagctl_cpuslv1_ac_addr;
  wire                                 [2:0] tagctl_cpuslv1_ac_id;
  wire                                 [3:0] tagctl_cpuslv1_ac_l2db_id;
  wire                                 [3:0] tagctl_cpuslv1_ac_snoop;
  wire                                       tagctl_cpuslv1_ac_valid;
  wire                                 [3:0] tagctl_cpuslv1_ac_way;
  wire                                       tagctl_cpuslv1_noncoh_only;
  wire                                       tagctl_cpuslv1_ready_tc0;
  wire                                       tagctl_cpuslv1_snp_active;
  wire                                [40:0] tagctl_cpuslv2_ac_addr;
  wire                                 [2:0] tagctl_cpuslv2_ac_id;
  wire                                 [3:0] tagctl_cpuslv2_ac_l2db_id;
  wire                                 [3:0] tagctl_cpuslv2_ac_snoop;
  wire                                       tagctl_cpuslv2_ac_valid;
  wire                                 [3:0] tagctl_cpuslv2_ac_way;
  wire                                       tagctl_cpuslv2_noncoh_only;
  wire                                       tagctl_cpuslv2_ready_tc0;
  wire                                       tagctl_cpuslv2_snp_active;
  wire                                [40:0] tagctl_cpuslv3_ac_addr;
  wire                                 [2:0] tagctl_cpuslv3_ac_id;
  wire                                 [3:0] tagctl_cpuslv3_ac_l2db_id;
  wire                                 [3:0] tagctl_cpuslv3_ac_snoop;
  wire                                       tagctl_cpuslv3_ac_valid;
  wire                                 [3:0] tagctl_cpuslv3_ac_way;
  wire                                       tagctl_cpuslv3_noncoh_only;
  wire                                       tagctl_cpuslv3_ready_tc0;
  wire                                       tagctl_cpuslv3_snp_active;
  wire                                 [3:0] tagctl_dvm_complete;
  wire                                       tagctl_dvm_sync_tc3;
  wire                                       tagctl_ecc_err_tc3;
  wire                                [15:0] tagctl_ecc_way_tc1;
  wire                                       tagctl_ecc_wr_tc1;
  wire                                       tagctl_index_valid_tc1;
  wire                                [15:0] tagctl_l1_hit_ways_tc3;
  wire                                       tagctl_l1_lf_tc1;
  wire                                       tagctl_l1_set_way_op_tc1;
  wire                                       tagctl_l1_victim_cluster_unique_tc3;
  wire                                 [1:0] tagctl_l1_victim_shareability_tc3;
  wire                                       tagctl_l2_alloc_tc3;
  wire                                       tagctl_l2_dirty_tc3;
  wire                                [15:0] tagctl_l2_hit_ways_tc3;
  wire                                       tagctl_l2_victim_alloc_tc3;
  wire                                       tagctl_l2_victim_cu_tc3;
  wire                                       tagctl_l2_victim_dirty_tc3;
  wire                                 [1:0] tagctl_l2_victim_shareability_tc3;
  wire                                       tagctl_l2_victim_valid_tc3;
  wire                                 [3:0] tagctl_l2_victim_way_tc3;
  wire                                 [7:0] tagctl_l2dataram_banks;
  wire                                [10:0] tagctl_l2dataram_index;
  wire                                       tagctl_l2dataram_req_tc2;
  wire                                [15:0] tagctl_l2dataram_way;
  wire                                       tagctl_l2db0_alloc;
  wire                                       tagctl_l2db0_fill_strbs;
  wire                                       tagctl_l2db0_release;
  wire                                       tagctl_l2db0_snoops_done;
  wire                                       tagctl_l2db10_alloc;
  wire                                       tagctl_l2db10_fill_strbs;
  wire                                       tagctl_l2db10_release;
  wire                                       tagctl_l2db10_snoops_done;
  wire                                       tagctl_l2db1_alloc;
  wire                                       tagctl_l2db1_fill_strbs;
  wire                                       tagctl_l2db1_release;
  wire                                       tagctl_l2db1_snoops_done;
  wire                                       tagctl_l2db2_alloc;
  wire                                       tagctl_l2db2_fill_strbs;
  wire                                       tagctl_l2db2_release;
  wire                                       tagctl_l2db2_snoops_done;
  wire                                       tagctl_l2db3_alloc;
  wire                                       tagctl_l2db3_fill_strbs;
  wire                                       tagctl_l2db3_release;
  wire                                       tagctl_l2db3_snoops_done;
  wire                                       tagctl_l2db4_alloc;
  wire                                       tagctl_l2db4_fill_strbs;
  wire                                       tagctl_l2db4_release;
  wire                                       tagctl_l2db4_snoops_done;
  wire                                       tagctl_l2db5_alloc;
  wire                                       tagctl_l2db5_fill_strbs;
  wire                                       tagctl_l2db5_release;
  wire                                       tagctl_l2db5_snoops_done;
  wire                                       tagctl_l2db6_alloc;
  wire                                       tagctl_l2db6_fill_strbs;
  wire                                       tagctl_l2db6_release;
  wire                                       tagctl_l2db6_snoops_done;
  wire                                       tagctl_l2db7_alloc;
  wire                                       tagctl_l2db7_fill_strbs;
  wire                                       tagctl_l2db7_release;
  wire                                       tagctl_l2db7_snoops_done;
  wire                                       tagctl_l2db8_alloc;
  wire                                       tagctl_l2db8_fill_strbs;
  wire                                       tagctl_l2db8_release;
  wire                                       tagctl_l2db8_snoops_done;
  wire                                       tagctl_l2db9_alloc;
  wire                                       tagctl_l2db9_fill_strbs;
  wire                                       tagctl_l2db9_release;
  wire                                       tagctl_l2db9_snoops_done;
  wire                                       tagctl_master_active;
  wire                                       tagctl_mn_op_tc2;
  wire                                       tagctl_noncoh_serialised_tc3;
  wire                                       tagctl_ramctl_active;
  wire                                 [7:0] tagctl_ramctl_banks;
  wire                                       tagctl_ramctl_cancel;
  wire                                 [1:0] tagctl_ramctl_crit_chunk;
  wire                                       tagctl_ramctl_flush;
  wire                                [10:0] tagctl_ramctl_index;
  wire                                 [3:0] tagctl_ramctl_l2db;
  wire                                       tagctl_ramctl_valid;
  wire                                 [3:0] tagctl_ramctl_way;
  wire                                 [5:0] tagctl_reqbufid_tc1;
  wire                                 [5:0] tagctl_reqbufid_tc3;
  wire                                [39:6] tagctl_sam_addr_tc2;
  wire                                       tagctl_serialising_tc1;
  wire                                 [1:0] tagctl_shareability_tc3;
  wire                                 [2:0] tagctl_slv_afb_tc1;
  wire                                       tagctl_slv_early_flush_tc4;
  wire                                       tagctl_slv_flush_tc1;
  wire                                       tagctl_slv_flush_tc2;
  wire                                       tagctl_slv_flush_tc3;
  wire                                       tagctl_slv_flush_tc4;
  wire                                       tagctl_slv_l2db_cleaned_tc4;
  wire                                       tagctl_slv_l2db_cu_tc3;
  wire                                       tagctl_slv_l2db_dirty_tc3;
  wire                                       tagctl_slv_l2db_hit_tc3;
  wire                                       tagctl_slv_l2db_invalidated_tc4;
  wire                                 [3:0] tagctl_slv_l2db_tc1;
  wire                                 [3:0] tagctl_slv_l2db_tc3;
  wire                                 [3:0] tagctl_slv_l2db_tc4;
  wire                                 [4:0] tagctl_slv_snp_hz_id_tc4;
  wire                                       tagctl_slv_snp_hz_tc4;
  wire                                 [3:0] tagctl_slv_victim_l2db_tc4;
  wire                                 [1:0] tagctl_snoop_data_cpu_tc4;
  wire                                       tagctl_snp_dvm_sync_tc4;
  wire                                       tagctl_snp_sync_tc1;
  wire                                       tagctl_snpslv_ready_tc0;
  wire                                       tagctl_valid_tc1;
  wire                                 [3:0] tagctl_wfx_ready;
  wire                                       victimctl_ack;
  wire                                 [5:0] victimctl_ack_id;
  wire                                [10:0] victimctl_index_vc1;
  wire                                       victimctl_ready;
  wire                                 [5:0] victimctl_ready_id;
  wire                                 [3:0] victimctl_victim_way;
  /*END*/

  wire        tagctl_mbistreq;
  wire        tagctl_mbist_sel;
  wire [39:0] tagctl_mbistoutdata;
  wire        victimctl_mbist_sel;
  wire [31:0] victimctl_mbistoutdata;
  wire        cpuslv0_l2flushdone;
  wire        cpuslv1_l2flushdone;
  wire        cpuslv2_l2flushdone;
  wire        cpuslv3_l2flushdone;
  wire        cpuslv0_l2flush_active;
  wire        cpuslv1_l2flush_active;
  wire        cpuslv2_l2flush_active;
  wire        cpuslv3_l2flush_active;
  wire        tagctl_err_valid;
  wire        tagctl_err_fatal;
  wire [10:0] tagctl_err_index;
  wire [4:0]  tagctl_err_way;
  wire        ramctl_err_valid;
  wire        ramctl_err_fatal;
  wire [14:0] ramctl_err_index;
  wire [2:0]  ramctl_err_bank;
  wire        l2ecc_err_sel;
  wire        scu_ext_ac_ready;
  wire        scu_acp_arready;
  wire        scu_acp_awready;
  wire        scu_acp_wready;
  wire        l2_victimram_en;
  wire        l2_victimram_no_acc_next_cycle;
  wire        l2_dataram_no_acc_next_cycle;

  //-----------------------------------------------------------------------------
  //  Main code
  //-----------------------------------------------------------------------------

  ca53scu_clk #(`CA53_SCU_INT_PARAM_INST) u_clk (
    /*ARMAUTO*/
    // Inputs
    .CLKIN                            (CLKIN),
    .DFTSE                            (DFTSE),
    .DFTRSTDISABLE                    (DFTRSTDISABLE),
    .nl2reset_i                       (nl2reset_i),
    .nmbistreset_i                    (nmbistreset_i),
    .tagctl_wfx_ready_i               (tagctl_wfx_ready[3:0]),
    .cpuslv0_wfx_active_i             (cpuslv0_wfx_active),
    .cpuslv1_wfx_active_i             (cpuslv1_wfx_active),
    .cpuslv2_wfx_active_i             (cpuslv2_wfx_active),
    .cpuslv3_wfx_active_i             (cpuslv3_wfx_active),
    .cpuslv0_active_i                 (cpuslv0_active),
    .cpuslv1_active_i                 (cpuslv1_active),
    .cpuslv2_active_i                 (cpuslv2_active),
    .cpuslv3_active_i                 (cpuslv3_active),
    .acpslv_active_i                  (acpslv_active),
    .snpslv_active_i                  (snpslv_active),
    .snpslv_retention_active_i        (snpslv_retention_active),
    .tagctl_active_i                  (tagctl_active),
    .ramctl_active_i                  (ramctl_active),
    .master_active_i                  (master_active),
    .ramctl_awake_i                   (ramctl_awake),
    .master_linkactive_i              (master_linkactive),
    .master_cpuslv0_waddrs_valid_i    (master_cpuslv0_waddrs_valid),
    .master_cpuslv1_waddrs_valid_i    (master_cpuslv1_waddrs_valid),
    .master_cpuslv2_waddrs_valid_i    (master_cpuslv2_waddrs_valid),
    .master_cpuslv3_waddrs_valid_i    (master_cpuslv3_waddrs_valid),
    .cpuslv0_l2flush_active_i         (cpuslv0_l2flush_active),
    .scu_ext_aclken_i                 (scu_ext_aclken_i),
    .ext_acp_aclken_i                 (ext_acp_aclken_i),
    .ext_sclken_i                     (ext_sclken_i),
    .scu_ext_ac_valid_i               (scu_ext_ac_valid_i),
    .scu_ext_ac_ready_i               (scu_ext_ac_ready),
    .acinactm_i                       (acinactm_i),
    .ext_sinact_i                     (ext_sinact_i),
    .ext_rxsactive_i                  (ext_rxsactive_i),
    .scu_acp_arready_i                (scu_acp_arready),
    .scu_acp_awready_i                (scu_acp_awready),
    .scu_acp_wready_i                 (scu_acp_wready),
    .ext_acp_ainact_i                 (ext_acp_ainact_i),
    .gov_l2_in_retention_i            (gov_l2_in_retention_i),
    .gov_standbywfi_i                 (gov_standbywfi_i[NUM_CPUS-1:0]),
    .gov_mbistreq_i                   (gov_mbistreq_i),
    .gov_cpu0_inv_all_req_i           (gov_cpu0_inv_all_req_i),
    .gov_cpu1_inv_all_req_i           (gov_cpu1_inv_all_req_i),
    .gov_cpu2_inv_all_req_i           (gov_cpu2_inv_all_req_i),
    .gov_cpu3_inv_all_req_i           (gov_cpu3_inv_all_req_i),
    .l2flushreq_i                     (l2flushreq_i),
    .l2_victimram_en_i                (l2_victimram_en),
    .l2_victimram_no_acc_next_cycle_i (l2_victimram_no_acc_next_cycle),
    .l2_dataram_no_acc_next_cycle_i   (l2_dataram_no_acc_next_cycle),
    .cpuslv0_l2flushdone_i            (cpuslv0_l2flushdone),
    // Outputs
    .scu_wfx_ready_o                  (scu_wfx_ready_o[NUM_CPUS-1:0]),
    .standbywfil2_req_o               (standbywfil2_req),
    .standbywfil2_o                   (standbywfil2_o),
    .clk                              (clk),
    .clk_ext_master                   (clk_ext_master),
    .reset_n_o                        (reset_n),
    .clean_aclken_o                   (clean_aclken),
    .clean_aclkens_o                  (clean_aclkens),
    .l2flushreq_rs_o                  (l2flushreq_rs),
    .inactm_rs_o                      (inactm_rs),
    .acp_ainact_rs_o                  (acp_ainact_rs),
    .ram_idle_count_max_o             (ram_idle_count_max),
    .scu_l2_retention_ready_o         (scu_l2_retention_ready_o),
    .l2_reached_retention_o           (l2_reached_retention),
    .l2flushdone_o                    (l2flushdone_o)
  );  // u_clk

  ca53scu_config #(`CA53_SCU_INT_PARAM_INST) u_config (
    /*ARMAUTO*/
    // Inputs
    .clk                          (clk),
    .reset_n                      (reset_n),
    .broadcastinner_i             (broadcastinner_i),
    .broadcastouter_i             (broadcastouter_i),
    .broadcastcachemaint_i        (broadcastcachemaint_i),
    .sysbardisable_i              (sysbardisable_i),
    .l1_dc_size_i                 (l1_dc_size_i[2:0]),
    .l2_size_i                    (l2_size_i[3:0]),
    .l2rstdisable_i               (l2rstdisable_i),
    .ext_nodeid_i                 (ext_nodeid_i[6:0]),
    // Outputs
    .config_broadcastinner_o      (config_broadcastinner),
    .config_broadcastouter_o      (config_broadcastouter),
    .config_broadcastcachemaint_o (config_broadcastcachemaint),
    .config_sysbardisable_o       (config_sysbardisable),
    .config_l1_dc_size_o          (config_l1_dc_size[2:0]),
    .config_l2_size_o             (config_l2_size[3:0]),
    .config_l2rstdisable_o        (config_l2rstdisable),
    .config_nodeid_o              (config_nodeid[6:0]),
    .leaving_reset_o              (leaving_reset)
  );  // u_config

  ca53scu_cpuslv #(`CA53_SCU_INT_PARAM_INST, .CPU_NUM(0)) u_scu_cpuslv0 (
    // TEMPLATE s/cpuslv/cpuslv0/
    // TEMPLATE s/biu_/biu_cpu0_/
    // TEMPLATE s/dcu_/dcu_cpu0_/
    // TEMPLATE s/gov_/gov_cpu0_/
    // TEMPLATE s/scu_/scu_cpu0_/
    /*ARMAUTO*/
    .gov_enable_writeevict_i               (gov_enable_writeevict_i),
    .gov_l2_in_retention_i                 (gov_l2_in_retention_i),
    .gov_standbywfi_i                      (gov_standbywfi_i[NUM_CPUS-1:0]),
    .gov_mbistreq_i                        (gov_mbistreq_i),
    // Inputs
    .CLKIN                                 (CLKIN),
    .clk                                   (clk),
    .reset_n                               (reset_n),
    .DFTSE                                 (DFTSE),
    .leaving_reset_i                       (leaving_reset),
    .config_broadcastinner_i               (config_broadcastinner),
    .config_broadcastouter_i               (config_broadcastouter),
    .config_broadcastcachemaint_i          (config_broadcastcachemaint),
    .config_sysbardisable_i                (config_sysbardisable),
    .config_l1_dc_size_i                   (config_l1_dc_size[2:0]),
    .config_l2_size_i                      (config_l2_size[3:0]),
    .gov_inv_all_req_i                     (gov_cpu0_inv_all_req_i),
    .biu_ar_active_i                       (biu_cpu0_ar_active_i),
    .biu_ar_valid_i                        (biu_cpu0_ar_valid_i),
    .biu_ar_id_i                           (biu_cpu0_ar_id_i[4:0]),
    .biu_ar_type_i                         (biu_cpu0_ar_type_i[4:0]),
    .biu_ar_attrs_i                        (biu_cpu0_ar_attrs_i[7:0]),
    .biu_ar_way_i                          (biu_cpu0_ar_way_i[4:0]),
    .biu_ar_addr_i                         (biu_cpu0_ar_addr_i[40:0]),
    .biu_ar_len_i                          (biu_cpu0_ar_len_i[1:0]),
    .biu_ar_size_i                         (biu_cpu0_ar_size_i[2:0]),
    .biu_ar_lock_i                         (biu_cpu0_ar_lock_i),
    .biu_ar_priv_i                         (biu_cpu0_ar_priv_i),
    .biu_dr_credit_i                       (biu_cpu0_dr_credit_i),
    .biu_dw_valid_i                        (biu_cpu0_dw_valid_i),
    .biu_dw_l2db_id_i                      (biu_cpu0_dw_l2db_id_i[3:0]),
    .biu_dw_chunks_valid_i                 (biu_cpu0_dw_chunks_valid_i[3:0]),
    .biu_dw_last_i                         (biu_cpu0_dw_last_i),
    .biu_dw_strb_i                         (biu_cpu0_dw_strb_i[31:0]),
    .biu_dw_data_i                         (biu_cpu0_dw_data_i[255:0]),
    .biu_dw_err_i                          (biu_cpu0_dw_err_i),
    .biu_dw_fatal_i                        (biu_cpu0_dw_fatal_i),
    .l2flushreq_rs_i                       (l2flushreq_rs),
    .acp_ainact_rs_i                       (acp_ainact_rs),
    .master_writes_active_i                (master_writes_active),
    .dcu_ac_ready_i                        (dcu_cpu0_ac_ready_i),
    .dcu_cr_valid_i                        (dcu_cpu0_cr_valid_i),
    .dcu_cr_id_i                           (dcu_cpu0_cr_id_i[2:0]),
    .dcu_cr_dirty_i                        (dcu_cpu0_cr_dirty_i),
    .dcu_cr_age_i                          (dcu_cpu0_cr_age_i),
    .dcu_cr_alloc_i                        (dcu_cpu0_cr_alloc_i),
    .dcu_cr_migratory_i                    (dcu_cpu0_cr_migratory_i),
    .tagctl_cpuslv_ready_tc0_i             (tagctl_cpuslv0_ready_tc0),
    .tagctl_cpuslv_noncoh_only_i           (tagctl_cpuslv0_noncoh_only),
    .tagctl_slv_flush_tc1_i                (tagctl_slv_flush_tc1),
    .tagctl_slv_flush_tc2_i                (tagctl_slv_flush_tc2),
    .tagctl_slv_flush_tc3_i                (tagctl_slv_flush_tc3),
    .tagctl_slv_flush_tc4_i                (tagctl_slv_flush_tc4),
    .tagctl_slv_early_flush_tc4_i          (tagctl_slv_early_flush_tc4),
    .tagctl_ecc_err_tc3_i                  (tagctl_ecc_err_tc3),
    .tagctl_slv_l2db_tc1_i                 (tagctl_slv_l2db_tc1[3:0]),
    .tagctl_slv_l2db_tc4_i                 (tagctl_slv_l2db_tc4[3:0]),
    .tagctl_slv_snp_hz_tc4_i               (tagctl_slv_snp_hz_tc4),
    .tagctl_slv_snp_hz_id_tc4_i            (tagctl_slv_snp_hz_id_tc4[4:0]),
    .tagctl_slv_l2db_invalidated_tc4_i     (tagctl_slv_l2db_invalidated_tc4),
    .tagctl_slv_l2db_cleaned_tc4_i         (tagctl_slv_l2db_cleaned_tc4),
    .tagctl_slv_victim_l2db_tc4_i          (tagctl_slv_victim_l2db_tc4[3:0]),
    .afb0_done_i                           (afb0_done),
    .afb1_done_i                           (afb1_done),
    .afb2_done_i                           (afb2_done),
    .afb3_done_i                           (afb3_done),
    .afb4_done_i                           (afb4_done),
    .afb5_done_i                           (afb5_done),
    .afb0_snoop_resp_valid_i               (afb0_snoop_resp_valid),
    .afb1_snoop_resp_valid_i               (afb1_snoop_resp_valid),
    .afb2_snoop_resp_valid_i               (afb2_snoop_resp_valid),
    .afb3_snoop_resp_valid_i               (afb3_snoop_resp_valid),
    .afb4_snoop_resp_valid_i               (afb4_snoop_resp_valid),
    .afb5_snoop_resp_valid_i               (afb5_snoop_resp_valid),
    .afb0_snoop_resp_dirty_i               (afb0_snoop_resp_dirty),
    .afb1_snoop_resp_dirty_i               (afb1_snoop_resp_dirty),
    .afb2_snoop_resp_dirty_i               (afb2_snoop_resp_dirty),
    .afb3_snoop_resp_dirty_i               (afb3_snoop_resp_dirty),
    .afb4_snoop_resp_dirty_i               (afb4_snoop_resp_dirty),
    .afb5_snoop_resp_dirty_i               (afb5_snoop_resp_dirty),
    .afb0_snoop_resp_victim_valid_i        (afb0_snoop_resp_victim_valid),
    .afb1_snoop_resp_victim_valid_i        (afb1_snoop_resp_victim_valid),
    .afb2_snoop_resp_victim_valid_i        (afb2_snoop_resp_victim_valid),
    .afb3_snoop_resp_victim_valid_i        (afb3_snoop_resp_victim_valid),
    .afb4_snoop_resp_victim_valid_i        (afb4_snoop_resp_victim_valid),
    .afb5_snoop_resp_victim_valid_i        (afb5_snoop_resp_victim_valid),
    .afb0_snoop_resp_victim_dirty_i        (afb0_snoop_resp_victim_dirty),
    .afb1_snoop_resp_victim_dirty_i        (afb1_snoop_resp_victim_dirty),
    .afb2_snoop_resp_victim_dirty_i        (afb2_snoop_resp_victim_dirty),
    .afb3_snoop_resp_victim_dirty_i        (afb3_snoop_resp_victim_dirty),
    .afb4_snoop_resp_victim_dirty_i        (afb4_snoop_resp_victim_dirty),
    .afb5_snoop_resp_victim_dirty_i        (afb5_snoop_resp_victim_dirty),
    .afb0_snoop_resp_victim_age_i          (afb0_snoop_resp_victim_age),
    .afb1_snoop_resp_victim_age_i          (afb1_snoop_resp_victim_age),
    .afb2_snoop_resp_victim_age_i          (afb2_snoop_resp_victim_age),
    .afb3_snoop_resp_victim_age_i          (afb3_snoop_resp_victim_age),
    .afb4_snoop_resp_victim_age_i          (afb4_snoop_resp_victim_age),
    .afb5_snoop_resp_victim_age_i          (afb5_snoop_resp_victim_age),
    .afb0_snoop_resp_victim_alloc_i        (afb0_snoop_resp_victim_alloc),
    .afb1_snoop_resp_victim_alloc_i        (afb1_snoop_resp_victim_alloc),
    .afb2_snoop_resp_victim_alloc_i        (afb2_snoop_resp_victim_alloc),
    .afb3_snoop_resp_victim_alloc_i        (afb3_snoop_resp_victim_alloc),
    .afb4_snoop_resp_victim_alloc_i        (afb4_snoop_resp_victim_alloc),
    .afb5_snoop_resp_victim_alloc_i        (afb5_snoop_resp_victim_alloc),
    .afb0_snoop_resp_alloc_i               (afb0_snoop_resp_alloc),
    .afb1_snoop_resp_alloc_i               (afb1_snoop_resp_alloc),
    .afb2_snoop_resp_alloc_i               (afb2_snoop_resp_alloc),
    .afb3_snoop_resp_alloc_i               (afb3_snoop_resp_alloc),
    .afb4_snoop_resp_alloc_i               (afb4_snoop_resp_alloc),
    .afb5_snoop_resp_alloc_i               (afb5_snoop_resp_alloc),
    .afb0_snoop_resp_migratory_i           (afb0_snoop_resp_migratory),
    .afb1_snoop_resp_migratory_i           (afb1_snoop_resp_migratory),
    .afb2_snoop_resp_migratory_i           (afb2_snoop_resp_migratory),
    .afb3_snoop_resp_migratory_i           (afb3_snoop_resp_migratory),
    .afb4_snoop_resp_migratory_i           (afb4_snoop_resp_migratory),
    .afb5_snoop_resp_migratory_i           (afb5_snoop_resp_migratory),
    .afb0_write_done_i                     (afb0_write_done),
    .afb1_write_done_i                     (afb1_write_done),
    .afb2_write_done_i                     (afb2_write_done),
    .afb3_write_done_i                     (afb3_write_done),
    .afb4_write_done_i                     (afb4_write_done),
    .afb5_write_done_i                     (afb5_write_done),
    .tagctl_slv_afb_tc1_i                  (tagctl_slv_afb_tc1[2:0]),
    .tagctl_addr_tc1_i                     (tagctl_addr_tc1[41:6]),
    .tagctl_valid_tc1_i                    (tagctl_valid_tc1),
    .tagctl_addr_valid_tc1_i               (tagctl_addr_valid_tc1),
    .tagctl_index_valid_tc1_i              (tagctl_index_valid_tc1),
    .tagctl_l1_set_way_op_tc1_i            (tagctl_l1_set_way_op_tc1),
    .tagctl_l1_lf_tc1_i                    (tagctl_l1_lf_tc1),
    .tagctl_serialising_tc1_i              (tagctl_serialising_tc1),
    .tagctl_ecc_wr_tc1_i                   (tagctl_ecc_wr_tc1),
    .tagctl_ecc_way_tc1_i                  (tagctl_ecc_way_tc1[15:0]),
    .tagctl_reqbufid_tc1_i                 (tagctl_reqbufid_tc1[5:0]),
    .tagctl_cpu_sync_tc1_i                 (tagctl_cpu_sync_tc1),
    .tagctl_snp_sync_tc1_i                 (tagctl_snp_sync_tc1),
    .tagctl_addr_tc3_i                     (tagctl_addr_tc3[40:6]),
    .tagctl_addr_valid_tc3_i               (tagctl_addr_valid_tc3),
    .tagctl_reqbufid_tc3_i                 (tagctl_reqbufid_tc3[5:0]),
    .tagctl_noncoh_serialised_tc3_i        (tagctl_noncoh_serialised_tc3),
    .tagctl_l1_hit_ways_tc3_i              (tagctl_l1_hit_ways_tc3[15:0]),
    .tagctl_l2_hit_ways_tc3_i              (tagctl_l2_hit_ways_tc3[15:0]),
    .tagctl_l2_dirty_tc3_i                 (tagctl_l2_dirty_tc3),
    .tagctl_l2_alloc_tc3_i                 (tagctl_l2_alloc_tc3),
    .tagctl_shareability_tc3_i             (tagctl_shareability_tc3[1:0]),
    .tagctl_cluster_unique_tc3_i           (tagctl_cluster_unique_tc3),
    .tagctl_l1_victim_cluster_unique_tc3_i (tagctl_l1_victim_cluster_unique_tc3),
    .tagctl_l1_victim_shareability_tc3_i   (tagctl_l1_victim_shareability_tc3[1:0]),
    .tagctl_l2_victim_valid_tc3_i          (tagctl_l2_victim_valid_tc3),
    .tagctl_l2_victim_shareability_tc3_i   (tagctl_l2_victim_shareability_tc3[1:0]),
    .tagctl_l2_victim_alloc_tc3_i          (tagctl_l2_victim_alloc_tc3),
    .tagctl_l2_victim_cu_tc3_i             (tagctl_l2_victim_cu_tc3),
    .tagctl_l2_victim_way_tc3_i            (tagctl_l2_victim_way_tc3[3:0]),
    .tagctl_snoop_data_cpu_tc4_i           (tagctl_snoop_data_cpu_tc4[1:0]),
    .dvm_comp_sync_outstanding_i           (dvm_comp_sync_outstanding),
    .tagctl_cpuslv_ac_valid_i              (tagctl_cpuslv0_ac_valid),
    .tagctl_cpuslv_ac_snoop_i              (tagctl_cpuslv0_ac_snoop[3:0]),
    .tagctl_cpuslv_ac_id_i                 (tagctl_cpuslv0_ac_id[2:0]),
    .tagctl_cpuslv_ac_l2db_id_i            (tagctl_cpuslv0_ac_l2db_id[3:0]),
    .tagctl_cpuslv_ac_addr_i               (tagctl_cpuslv0_ac_addr[40:0]),
    .tagctl_cpuslv_ac_way_i                (tagctl_cpuslv0_ac_way[3:0]),
    .tagctl_cpuslv_snp_active_i            (tagctl_cpuslv0_snp_active),
    .snpslv_cpuslv_compack_ready_i         (snpslv_cpuslv0_compack_ready),
    .victimctl_ready_i                     (victimctl_ready),
    .victimctl_ready_id_i                  (victimctl_ready_id[5:0]),
    .victimctl_ack_i                       (victimctl_ack),
    .victimctl_ack_id_i                    (victimctl_ack_id[5:0]),
    .victimctl_victim_way_i                (victimctl_victim_way[3:0]),
    .victimctl_index_vc1_i                 (victimctl_index_vc1[10:0]),
    .l2db0_slv_done_i                      (l2db0_slv_done),
    .l2db1_slv_done_i                      (l2db1_slv_done),
    .l2db2_slv_done_i                      (l2db2_slv_done),
    .l2db3_slv_done_i                      (l2db3_slv_done),
    .l2db4_slv_done_i                      (l2db4_slv_done),
    .l2db5_slv_done_i                      (l2db5_slv_done),
    .l2db6_slv_done_i                      (l2db6_slv_done),
    .l2db7_slv_done_i                      (l2db7_slv_done),
    .l2db8_slv_done_i                      (l2db8_slv_done),
    .l2db9_slv_done_i                      (l2db9_slv_done),
    .l2db10_slv_done_i                     (l2db10_slv_done),
    .l2db0_full_line_i                     (l2db0_full_line),
    .l2db1_full_line_i                     (l2db1_full_line),
    .l2db2_full_line_i                     (l2db2_full_line),
    .l2db3_full_line_i                     (l2db3_full_line),
    .l2db4_full_line_i                     (l2db4_full_line),
    .l2db5_full_line_i                     (l2db5_full_line),
    .l2db6_full_line_i                     (l2db6_full_line),
    .l2db7_full_line_i                     (l2db7_full_line),
    .l2db8_full_line_i                     (l2db8_full_line),
    .l2db9_full_line_i                     (l2db9_full_line),
    .l2db10_full_line_i                    (l2db10_full_line),
    .l2db0_rmw_line_i                      (l2db0_rmw_line),
    .l2db1_rmw_line_i                      (l2db1_rmw_line),
    .l2db2_rmw_line_i                      (l2db2_rmw_line),
    .l2db3_rmw_line_i                      (l2db3_rmw_line),
    .l2db4_rmw_line_i                      (l2db4_rmw_line),
    .l2db5_rmw_line_i                      (l2db5_rmw_line),
    .l2db6_rmw_line_i                      (l2db6_rmw_line),
    .l2db7_rmw_line_i                      (l2db7_rmw_line),
    .l2db8_rmw_line_i                      (l2db8_rmw_line),
    .l2db9_rmw_line_i                      (l2db9_rmw_line),
    .l2db10_rmw_line_i                     (l2db10_rmw_line),
    .l2db0_cpuslv_data_active_i            (l2db0_cpuslv0_data_active),
    .l2db1_cpuslv_data_active_i            (l2db1_cpuslv0_data_active),
    .l2db2_cpuslv_data_active_i            (l2db2_cpuslv0_data_active),
    .l2db3_cpuslv_data_active_i            (l2db3_cpuslv0_data_active),
    .l2db4_cpuslv_data_active_i            (l2db4_cpuslv0_data_active),
    .l2db5_cpuslv_data_active_i            (l2db5_cpuslv0_data_active),
    .l2db6_cpuslv_data_active_i            (l2db6_cpuslv0_data_active),
    .l2db7_cpuslv_data_active_i            (l2db7_cpuslv0_data_active),
    .l2db8_cpuslv_data_active_i            (l2db8_cpuslv0_data_active),
    .l2db9_cpuslv_data_active_i            (l2db9_cpuslv0_data_active),
    .l2db10_cpuslv_data_active_i           (l2db10_cpuslv0_data_active),
    .master_early_dr_valid_i               (master_early_dr_valid),
    .master_early_dr_id_i                  (master_early_dr_id[5:0]),
    .master_early_dr_dbid_i                (master_early_dr_dbid[7:0]),
    .master_early_dr_srcid_i               (master_early_dr_srcid[6:0]),
    .master_early_dr_barrier_i             (master_early_dr_barrier),
    .master_early_dr_resp_i                (master_early_dr_resp[3:0]),
    .master_early_dr_same_i                (master_early_dr_same),
    .master_cpuslv_dr_valid_i              (master_cpuslv0_dr_valid),
    .master_cpuslv_dr_id_i                 (master_cpuslv0_dr_id[5:0]),
    .master_dr_chunk_i                     (master_dr_chunk[1:0]),
    .master_dr_data_i                      (master_dr_data[127:0]),
    .master_dr_resp_i                      (master_dr_resp[3:0]),
    .master_afb0_ack_i                     (master_afb0_ack),
    .master_afb1_ack_i                     (master_afb1_ack),
    .master_afb2_ack_i                     (master_afb2_ack),
    .master_afb3_ack_i                     (master_afb3_ack),
    .master_afb4_ack_i                     (master_afb4_ack),
    .master_afb5_ack_i                     (master_afb5_ack),
    .master_afb_waddr_id_i                 (master_afb_waddr_id[3:0]),
    .master_cpuslv_waddrs_valid_i          (master_cpuslv0_waddrs_valid),
    .master_cpuslv_barrier_db_valid_i      (master_cpuslv0_barrier_db_valid),
    .master_cpuslv_strex_db_valid_i        (master_cpuslv0_strex_db_valid),
    .master_cpuslv_dev_db_valid_i          (master_cpuslv0_dev_db_valid),
    .master_db_resp_i                      (master_db_resp[1:0]),
    .master_db_waddr_valid_i               (master_db_waddr_valid),
    .master_db_waddr_i                     (master_db_waddr[3:0]),
    .master_cpuslv_l2_waiting_i            (master_cpuslv0_l2_waiting[7:0]),
    .master_rsp_readreceipt_valid_i        (master_rsp_readreceipt_valid),
    .master_rsp_comp_valid_i               (master_rsp_comp_valid),
    .master_rsp_dbid_valid_i               (master_rsp_dbid_valid),
    .master_rsp_txnid_i                    (master_rsp_txnid[6:0]),
    .master_rsp_dbid_i                     (master_rsp_dbid[7:0]),
    .master_rsp_srcid_i                    (master_rsp_srcid[6:0]),
    .master_rsp_resp_i                     (master_rsp_resp[3:0]),
    .master_cpuslv_reqbuf_retry_i          (master_cpuslv0_reqbuf_retry[7:0]),
    .master_cpuslv_pcrdtype_i              (master_cpuslv0_pcrdtype[1:0]),
    .l2db0_slv_valid_i                     (l2db0_slv_valid),
    .l2db0_slv_id_i                        (l2db0_slv_id[5:0]),
    .l2db0_slv_biuid_i                     (l2db0_slv_biuid[4:0]),
    .l2db0_slv_data_i                      (l2db0_slv_data[127:0]),
    .l2db0_slv_chunk_i                     (l2db0_slv_chunk[1:0]),
    .l2db0_slv_bypass_i                    (l2db0_slv_bypass),
    .l2db0_slv_err_i                       (l2db0_slv_err),
    .l2db1_slv_valid_i                     (l2db1_slv_valid),
    .l2db1_slv_id_i                        (l2db1_slv_id[5:0]),
    .l2db1_slv_biuid_i                     (l2db1_slv_biuid[4:0]),
    .l2db1_slv_data_i                      (l2db1_slv_data[127:0]),
    .l2db1_slv_chunk_i                     (l2db1_slv_chunk[1:0]),
    .l2db1_slv_bypass_i                    (l2db1_slv_bypass),
    .l2db1_slv_err_i                       (l2db1_slv_err),
    .l2db2_slv_valid_i                     (l2db2_slv_valid),
    .l2db2_slv_id_i                        (l2db2_slv_id[5:0]),
    .l2db2_slv_biuid_i                     (l2db2_slv_biuid[4:0]),
    .l2db2_slv_data_i                      (l2db2_slv_data[127:0]),
    .l2db2_slv_chunk_i                     (l2db2_slv_chunk[1:0]),
    .l2db2_slv_bypass_i                    (l2db2_slv_bypass),
    .l2db2_slv_err_i                       (l2db2_slv_err),
    .l2db3_slv_valid_i                     (l2db3_slv_valid),
    .l2db3_slv_id_i                        (l2db3_slv_id[5:0]),
    .l2db3_slv_biuid_i                     (l2db3_slv_biuid[4:0]),
    .l2db3_slv_data_i                      (l2db3_slv_data[127:0]),
    .l2db3_slv_chunk_i                     (l2db3_slv_chunk[1:0]),
    .l2db3_slv_bypass_i                    (l2db3_slv_bypass),
    .l2db3_slv_err_i                       (l2db3_slv_err),
    .l2db4_slv_valid_i                     (l2db4_slv_valid),
    .l2db4_slv_id_i                        (l2db4_slv_id[5:0]),
    .l2db4_slv_biuid_i                     (l2db4_slv_biuid[4:0]),
    .l2db4_slv_data_i                      (l2db4_slv_data[127:0]),
    .l2db4_slv_chunk_i                     (l2db4_slv_chunk[1:0]),
    .l2db4_slv_bypass_i                    (l2db4_slv_bypass),
    .l2db4_slv_err_i                       (l2db4_slv_err),
    .l2db5_slv_valid_i                     (l2db5_slv_valid),
    .l2db5_slv_id_i                        (l2db5_slv_id[5:0]),
    .l2db5_slv_biuid_i                     (l2db5_slv_biuid[4:0]),
    .l2db5_slv_data_i                      (l2db5_slv_data[127:0]),
    .l2db5_slv_chunk_i                     (l2db5_slv_chunk[1:0]),
    .l2db5_slv_bypass_i                    (l2db5_slv_bypass),
    .l2db5_slv_err_i                       (l2db5_slv_err),
    .l2db6_slv_valid_i                     (l2db6_slv_valid),
    .l2db6_slv_id_i                        (l2db6_slv_id[5:0]),
    .l2db6_slv_biuid_i                     (l2db6_slv_biuid[4:0]),
    .l2db6_slv_data_i                      (l2db6_slv_data[127:0]),
    .l2db6_slv_chunk_i                     (l2db6_slv_chunk[1:0]),
    .l2db6_slv_bypass_i                    (l2db6_slv_bypass),
    .l2db6_slv_err_i                       (l2db6_slv_err),
    .l2db7_slv_valid_i                     (l2db7_slv_valid),
    .l2db7_slv_id_i                        (l2db7_slv_id[5:0]),
    .l2db7_slv_biuid_i                     (l2db7_slv_biuid[4:0]),
    .l2db7_slv_data_i                      (l2db7_slv_data[127:0]),
    .l2db7_slv_chunk_i                     (l2db7_slv_chunk[1:0]),
    .l2db7_slv_bypass_i                    (l2db7_slv_bypass),
    .l2db7_slv_err_i                       (l2db7_slv_err),
    .l2db8_slv_valid_i                     (l2db8_slv_valid),
    .l2db8_slv_id_i                        (l2db8_slv_id[5:0]),
    .l2db8_slv_biuid_i                     (l2db8_slv_biuid[4:0]),
    .l2db8_slv_data_i                      (l2db8_slv_data[127:0]),
    .l2db8_slv_chunk_i                     (l2db8_slv_chunk[1:0]),
    .l2db8_slv_bypass_i                    (l2db8_slv_bypass),
    .l2db8_slv_err_i                       (l2db8_slv_err),
    .l2db9_slv_valid_i                     (l2db9_slv_valid),
    .l2db9_slv_id_i                        (l2db9_slv_id[5:0]),
    .l2db9_slv_biuid_i                     (l2db9_slv_biuid[4:0]),
    .l2db9_slv_data_i                      (l2db9_slv_data[127:0]),
    .l2db9_slv_chunk_i                     (l2db9_slv_chunk[1:0]),
    .l2db9_slv_bypass_i                    (l2db9_slv_bypass),
    .l2db9_slv_err_i                       (l2db9_slv_err),
    .l2db10_slv_valid_i                    (l2db10_slv_valid),
    .l2db10_slv_id_i                       (l2db10_slv_id[5:0]),
    .l2db10_slv_biuid_i                    (l2db10_slv_biuid[4:0]),
    .l2db10_slv_data_i                     (l2db10_slv_data[127:0]),
    .l2db10_slv_chunk_i                    (l2db10_slv_chunk[1:0]),
    .l2db10_slv_bypass_i                   (l2db10_slv_bypass),
    .l2db10_slv_err_i                      (l2db10_slv_err),
    .ramctl_bypass_data_i                  (ramctl_bypass_data[127:0]),
    .ramctl_bypass_err_i                   (ramctl_bypass_err),
    // Outputs
    .cpuslv_active_o                       (cpuslv0_active),
    .cpuslv_wfx_active_o                   (cpuslv0_wfx_active),
    .scu_inv_all_ack_o                     (scu_cpu0_inv_all_ack_o),
    .scu_ar_credit_o                       (scu_cpu0_ar_credit_o),
    .scu_ar_block_o                        (scu_cpu0_ar_block_o),
    .scu_dr_valid_o                        (scu_cpu0_dr_valid_o),
    .scu_dr_id_o                           (scu_cpu0_dr_id_o[4:0]),
    .scu_dr_resp_o                         (scu_cpu0_dr_resp_o[5:0]),
    .scu_dr_chunk_o                        (scu_cpu0_dr_chunk_o[1:0]),
    .scu_dr_data_o                         (scu_cpu0_dr_data_o[127:0]),
    .scu_rr_valid_o                        (scu_cpu0_rr_valid_o),
    .scu_rr_id_o                           (scu_cpu0_rr_id_o[4:0]),
    .scu_rr_resp_o                         (scu_cpu0_rr_resp_o[1:0]),
    .scu_rr_l2db_id_o                      (scu_cpu0_rr_l2db_id_o[3:0]),
    .scu_ev_done_o                         (scu_cpu0_ev_done_o[7:0]),
    .scu_db_excl_valid_o                   (scu_cpu0_db_excl_valid_o),
    .scu_db_excl_resp_o                    (scu_cpu0_db_excl_resp_o[1:0]),
    .scu_db_decerr_o                       (scu_cpu0_db_decerr_o),
    .scu_db_slverr_o                       (scu_cpu0_db_slverr_o),
    .scu_leave_ramode_o                    (scu_cpu0_leave_ramode_o),
    .cpuslv_l2flushdone_o                  (cpuslv0_l2flushdone),
    .cpuslv_l2flush_active_o               (cpuslv0_l2flush_active),
    .scu_ac_valid_o                        (scu_cpu0_ac_valid_o),
    .scu_ac_snoop_o                        (scu_cpu0_ac_snoop_o[3:0]),
    .scu_ac_id_o                           (scu_cpu0_ac_id_o[2:0]),
    .scu_ac_l2db_id_o                      (scu_cpu0_ac_l2db_id_o[3:0]),
    .scu_ac_addr_o                         (scu_cpu0_ac_addr_o[40:0]),
    .scu_ac_way_o                          (scu_cpu0_ac_way_o[3:0]),
    .cpuslv_tagctl_valid_tc0_o             (cpuslv0_tagctl_valid_tc0),
    .cpuslv_tagctl_early_valid_tc0_o       (cpuslv0_tagctl_early_valid_tc0),
    .cpuslv_tagctl_spec_valid_tc0_o        (cpuslv0_tagctl_spec_valid_tc0),
    .cpuslv_tagctl_reqbufid_tc0_o          (cpuslv0_tagctl_reqbufid_tc0[2:0]),
    .cpuslv_tagctl_pass_tc0_o              (cpuslv0_tagctl_pass_tc0[3:0]),
    .cpuslv_tagctl_addr1_tc0_o             (cpuslv0_tagctl_addr1_tc0[40:0]),
    .cpuslv_tagctl_dvm_sync_tc0_o          (cpuslv0_tagctl_dvm_sync_tc0),
    .cpuslv_tagctl_wr_state_tc0_o          (cpuslv0_tagctl_wr_state_tc0[16:0]),
    .cpuslv_tagctl_ecc_tc0_o               (cpuslv0_tagctl_ecc_tc0[34:0]),
    .cpuslv_tagctl_ways_tc0_o              (cpuslv0_tagctl_ways_tc0[31:0]),
    .cpuslv_tagctl_write_tc0_o             (cpuslv0_tagctl_write_tc0[4:0]),
    .cpuslv_tagctl_type_tc0_o              (cpuslv0_tagctl_type_tc0[4:0]),
    .cpuslv_tagctl_l2flushreq_tc0_o        (cpuslv0_tagctl_l2flushreq_tc0),
    .cpuslv_tagctl_reqbuf_dcu_tc1_o        (cpuslv0_tagctl_reqbuf_dcu_tc1),
    .cpuslv_tagctl_addr2_tc1_o             (cpuslv0_tagctl_addr2_tc1[40:0]),
    .cpuslv_tagctl_len_tc1_o               (cpuslv0_tagctl_len_tc1[1:0]),
    .cpuslv_tagctl_size_tc1_o              (cpuslv0_tagctl_size_tc1[2:0]),
    .cpuslv_tagctl_lock_tc1_o              (cpuslv0_tagctl_lock_tc1),
    .cpuslv_tagctl_dirty_tc1_o             (cpuslv0_tagctl_dirty_tc1),
    .cpuslv_tagctl_cluster_unique_tc1_o    (cpuslv0_tagctl_cluster_unique_tc1),
    .cpuslv_tagctl_attrs_tc1_o             (cpuslv0_tagctl_attrs_tc1[7:0]),
    .cpuslv_tagctl_prot_tc1_o              (cpuslv0_tagctl_prot_tc1[1:0]),
    .cpuslv_tagctl_l2db_tc1_o              (cpuslv0_tagctl_l2db_tc1[3:0]),
    .cpuslv_tagctl_l2db_full_tc1_o         (cpuslv0_tagctl_l2db_full_tc1),
    .cpuslv_tagctl_static_pcredit_tc1_o    (cpuslv0_tagctl_static_pcredit_tc1),
    .cpuslv_tagctl_pcrdtype_tc1_o          (cpuslv0_tagctl_pcrdtype_tc1[1:0]),
    .cpuslv_tagctl_victim_way_tc1_o        (cpuslv0_tagctl_victim_way_tc1[3:0]),
    .cpuslv_inv_all_starting_o             (cpuslv0_inv_all_starting),
    .cpuslv_hz_tc2_o                       (cpuslv0_hz_tc2),
    .cpuslv_snp_hz_tc2_o                   (cpuslv0_snp_hz_tc2),
    .cpuslv_snp_hz_id_tc2_o                (cpuslv0_snp_hz_id_tc2[2:0]),
    .cpuslv_snp_l2db_hz_tc2_o              (cpuslv0_snp_l2db_hz_tc2),
    .cpuslv_snp_l2db_dirty_tc2_o           (cpuslv0_snp_l2db_dirty_tc2),
    .cpuslv_snp_l2db_tc2_o                 (cpuslv0_snp_l2db_tc2[3:0]),
    .cpuslv_ecc_hz_tc2_o                   (cpuslv0_ecc_hz_tc2),
    .cpuslv_force_miss_tc2_o               (cpuslv0_force_miss_tc2[31:0]),
    .cpuslv_l2_way_used_tc2_o              (cpuslv0_l2_way_used_tc2[15:0]),
    .cpuslv_hz_tc4_o                       (cpuslv0_hz_tc4),
    .scu_drain_stb_o                       (scu_cpu0_drain_stb_o),
    .cpuslv_noncoh_since_barrier_o         (cpuslv0_noncoh_since_barrier),
    .cpuslv_dvm_sync_resp_o                (cpuslv0_dvm_sync_resp),
    .cpuslv_ac_ready_o                     (cpuslv0_ac_ready),
    .cpuslv_cr_valid_o                     (cpuslv0_cr_valid),
    .cpuslv_cr_id_o                        (cpuslv0_cr_id[2:0]),
    .cpuslv_cr_dirty_o                     (cpuslv0_cr_dirty),
    .cpuslv_cr_age_o                       (cpuslv0_cr_age),
    .cpuslv_cr_alloc_o                     (cpuslv0_cr_alloc),
    .cpuslv_cr_migratory_o                 (cpuslv0_cr_migratory),
    .cpuslv_compack_active_o               (cpuslv0_compack_active),
    .cpuslv_compack_valid_o                (cpuslv0_compack_valid),
    .cpuslv_compack_tgtid_o                (cpuslv0_compack_tgtid[6:0]),
    .cpuslv_compack_txnid_o                (cpuslv0_compack_txnid[7:0]),
    .cpuslv_victimctl_active_o             (cpuslv0_victimctl_active),
    .cpuslv_victimctl_valid_o              (cpuslv0_victimctl_valid),
    .cpuslv_victimctl_index_o              (cpuslv0_victimctl_index[10:0]),
    .cpuslv_victimctl_wr_o                 (cpuslv0_victimctl_wr),
    .cpuslv_victimctl_age_o                (cpuslv0_victimctl_age),
    .cpuslv_victimctl_iside_o              (cpuslv0_victimctl_iside),
    .cpuslv_victimctl_nontemp_o            (cpuslv0_victimctl_nontemp),
    .cpuslv_victimctl_way_o                (cpuslv0_victimctl_way[3:0]),
    .cpuslv_victimctl_id_o                 (cpuslv0_victimctl_id[2:0]),
    .cpuslv_l2_way_used_vc2_o              (cpuslv0_l2_way_used_vc2[15:0]),
    .cpuslv_l2dbs_active_o                 (cpuslv0_l2dbs_active),
    .cpuslv_ramctl_active_o                (cpuslv0_ramctl_active),
    .cpuslv_l2db0_transfer_o               (cpuslv0_l2db0_transfer),
    .cpuslv_l2db0_transfer_type_o          (cpuslv0_l2db0_transfer_type[2:0]),
    .cpuslv_l2db0_transfer_info_o          (cpuslv0_l2db0_transfer_info[23:0]),
    .cpuslv_l2db0_release_o                (cpuslv0_l2db0_release),
    .cpuslv_l2db1_transfer_o               (cpuslv0_l2db1_transfer),
    .cpuslv_l2db1_transfer_type_o          (cpuslv0_l2db1_transfer_type[2:0]),
    .cpuslv_l2db1_transfer_info_o          (cpuslv0_l2db1_transfer_info[23:0]),
    .cpuslv_l2db1_release_o                (cpuslv0_l2db1_release),
    .cpuslv_l2db2_transfer_o               (cpuslv0_l2db2_transfer),
    .cpuslv_l2db2_transfer_type_o          (cpuslv0_l2db2_transfer_type[2:0]),
    .cpuslv_l2db2_transfer_info_o          (cpuslv0_l2db2_transfer_info[23:0]),
    .cpuslv_l2db2_release_o                (cpuslv0_l2db2_release),
    .cpuslv_l2db3_transfer_o               (cpuslv0_l2db3_transfer),
    .cpuslv_l2db3_transfer_type_o          (cpuslv0_l2db3_transfer_type[2:0]),
    .cpuslv_l2db3_transfer_info_o          (cpuslv0_l2db3_transfer_info[23:0]),
    .cpuslv_l2db3_release_o                (cpuslv0_l2db3_release),
    .cpuslv_l2db4_transfer_o               (cpuslv0_l2db4_transfer),
    .cpuslv_l2db4_transfer_type_o          (cpuslv0_l2db4_transfer_type[2:0]),
    .cpuslv_l2db4_transfer_info_o          (cpuslv0_l2db4_transfer_info[23:0]),
    .cpuslv_l2db4_release_o                (cpuslv0_l2db4_release),
    .cpuslv_l2db5_transfer_o               (cpuslv0_l2db5_transfer),
    .cpuslv_l2db5_transfer_type_o          (cpuslv0_l2db5_transfer_type[2:0]),
    .cpuslv_l2db5_transfer_info_o          (cpuslv0_l2db5_transfer_info[23:0]),
    .cpuslv_l2db5_release_o                (cpuslv0_l2db5_release),
    .cpuslv_l2db6_transfer_o               (cpuslv0_l2db6_transfer),
    .cpuslv_l2db6_transfer_type_o          (cpuslv0_l2db6_transfer_type[2:0]),
    .cpuslv_l2db6_transfer_info_o          (cpuslv0_l2db6_transfer_info[23:0]),
    .cpuslv_l2db6_release_o                (cpuslv0_l2db6_release),
    .cpuslv_l2db7_transfer_o               (cpuslv0_l2db7_transfer),
    .cpuslv_l2db7_transfer_type_o          (cpuslv0_l2db7_transfer_type[2:0]),
    .cpuslv_l2db7_transfer_info_o          (cpuslv0_l2db7_transfer_info[23:0]),
    .cpuslv_l2db7_release_o                (cpuslv0_l2db7_release),
    .cpuslv_l2db8_transfer_o               (cpuslv0_l2db8_transfer),
    .cpuslv_l2db8_transfer_type_o          (cpuslv0_l2db8_transfer_type[2:0]),
    .cpuslv_l2db8_transfer_info_o          (cpuslv0_l2db8_transfer_info[23:0]),
    .cpuslv_l2db8_release_o                (cpuslv0_l2db8_release),
    .cpuslv_l2db9_transfer_o               (cpuslv0_l2db9_transfer),
    .cpuslv_l2db9_transfer_type_o          (cpuslv0_l2db9_transfer_type[2:0]),
    .cpuslv_l2db9_transfer_info_o          (cpuslv0_l2db9_transfer_info[23:0]),
    .cpuslv_l2db9_release_o                (cpuslv0_l2db9_release),
    .cpuslv_l2db10_transfer_o              (cpuslv0_l2db10_transfer),
    .cpuslv_l2db10_transfer_type_o         (cpuslv0_l2db10_transfer_type[2:0]),
    .cpuslv_l2db10_transfer_info_o         (cpuslv0_l2db10_transfer_info[23:0]),
    .cpuslv_l2db10_release_o               (cpuslv0_l2db10_release),
    .cpuslv_early_dr_l2_o                  (cpuslv0_early_dr_l2),
    .cpuslv_early_dr_index_o               (cpuslv0_early_dr_index[10:0]),
    .cpuslv_early_dr_way_o                 (cpuslv0_early_dr_way[3:0]),
    .cpuslv_early_dr_ready_o               (cpuslv0_early_dr_ready[7:0]),
    .cpuslv_delay_allocation_o             (cpuslv0_delay_allocation[7:0]),
    .cpuslv_master_dr_ready_o              (cpuslv0_master_dr_ready),
    .cpuslv_master_sactive_o               (cpuslv0_master_sactive),
    .cpuslv_sample_waddrs_o                (cpuslv0_sample_waddrs),
    .cpuslv_sample_waddrs_dsb_o            (cpuslv0_sample_waddrs_dsb),
    .scu_reqbufs_busy_o                    (scu_cpu0_reqbufs_busy_o[7:0]),
    .cpuslv_l2db0_ready_o                  (cpuslv0_l2db0_ready),
    .cpuslv_l2db1_ready_o                  (cpuslv0_l2db1_ready),
    .cpuslv_l2db2_ready_o                  (cpuslv0_l2db2_ready),
    .cpuslv_l2db3_ready_o                  (cpuslv0_l2db3_ready),
    .cpuslv_l2db4_ready_o                  (cpuslv0_l2db4_ready),
    .cpuslv_l2db5_ready_o                  (cpuslv0_l2db5_ready),
    .cpuslv_l2db6_ready_o                  (cpuslv0_l2db6_ready),
    .cpuslv_l2db7_ready_o                  (cpuslv0_l2db7_ready),
    .cpuslv_l2db8_ready_o                  (cpuslv0_l2db8_ready),
    .cpuslv_l2db9_ready_o                  (cpuslv0_l2db9_ready),
    .cpuslv_l2db10_ready_o                 (cpuslv0_l2db10_ready),
    .cpuslv_l2dbs_dw_valid_o               (cpuslv0_l2dbs_dw_valid),
    .cpuslv_l2dbs_dw_id_o                  (cpuslv0_l2dbs_dw_id[3:0]),
    .cpuslv_l2dbs_dw_chunks_valid_o        (cpuslv0_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv_l2dbs_dw_last_o                (cpuslv0_l2dbs_dw_last),
    .cpuslv_l2dbs_dw_data_o                (cpuslv0_l2dbs_dw_data[255:0]),
    .cpuslv_l2dbs_dw_strb_o                (cpuslv0_l2dbs_dw_strb[31:0]),
    .cpuslv_l2dbs_dw_err_o                 (cpuslv0_l2dbs_dw_err),
    .cpuslv_l2dbs_dw_fatal_o               (cpuslv0_l2dbs_dw_fatal),
    .scu_evnt_eviction_o                   (scu_cpu0_evnt_eviction_o),
    .scu_evnt_snooped_data_o               (scu_cpu0_evnt_snooped_data_o),
    .scu_evnt_l2_access_o                  (scu_cpu0_evnt_l2_access_o)
  );  // u_scu_cpuslv0

  ca53scu_cpuslv #(`CA53_SCU_INT_PARAM_INST, .CPU_NUM(1)) u_scu_cpuslv1 (
    // TEMPLATE s/cpuslv/cpuslv1/
    // TEMPLATE s/biu_/biu_cpu1_/
    // TEMPLATE s/dcu_/dcu_cpu1_/
    // TEMPLATE s/gov_/gov_cpu1_/
    // TEMPLATE s/scu_/scu_cpu1_/
    /*ARMAUTO*/
    .gov_enable_writeevict_i               (gov_enable_writeevict_i),
    .gov_l2_in_retention_i                 (gov_l2_in_retention_i),
    .gov_standbywfi_i                      (gov_standbywfi_i[NUM_CPUS-1:0]),
    .gov_mbistreq_i                        (gov_mbistreq_i),
    // Inputs
    .CLKIN                                 (CLKIN),
    .clk                                   (clk),
    .reset_n                               (reset_n),
    .DFTSE                                 (DFTSE),
    .leaving_reset_i                       (leaving_reset),
    .config_broadcastinner_i               (config_broadcastinner),
    .config_broadcastouter_i               (config_broadcastouter),
    .config_broadcastcachemaint_i          (config_broadcastcachemaint),
    .config_sysbardisable_i                (config_sysbardisable),
    .config_l1_dc_size_i                   (config_l1_dc_size[2:0]),
    .config_l2_size_i                      (config_l2_size[3:0]),
    .gov_inv_all_req_i                     (gov_cpu1_inv_all_req_i),
    .biu_ar_active_i                       (biu_cpu1_ar_active_i),
    .biu_ar_valid_i                        (biu_cpu1_ar_valid_i),
    .biu_ar_id_i                           (biu_cpu1_ar_id_i[4:0]),
    .biu_ar_type_i                         (biu_cpu1_ar_type_i[4:0]),
    .biu_ar_attrs_i                        (biu_cpu1_ar_attrs_i[7:0]),
    .biu_ar_way_i                          (biu_cpu1_ar_way_i[4:0]),
    .biu_ar_addr_i                         (biu_cpu1_ar_addr_i[40:0]),
    .biu_ar_len_i                          (biu_cpu1_ar_len_i[1:0]),
    .biu_ar_size_i                         (biu_cpu1_ar_size_i[2:0]),
    .biu_ar_lock_i                         (biu_cpu1_ar_lock_i),
    .biu_ar_priv_i                         (biu_cpu1_ar_priv_i),
    .biu_dr_credit_i                       (biu_cpu1_dr_credit_i),
    .biu_dw_valid_i                        (biu_cpu1_dw_valid_i),
    .biu_dw_l2db_id_i                      (biu_cpu1_dw_l2db_id_i[3:0]),
    .biu_dw_chunks_valid_i                 (biu_cpu1_dw_chunks_valid_i[3:0]),
    .biu_dw_last_i                         (biu_cpu1_dw_last_i),
    .biu_dw_strb_i                         (biu_cpu1_dw_strb_i[31:0]),
    .biu_dw_data_i                         (biu_cpu1_dw_data_i[255:0]),
    .biu_dw_err_i                          (biu_cpu1_dw_err_i),
    .biu_dw_fatal_i                        (biu_cpu1_dw_fatal_i),
    .l2flushreq_rs_i                       (l2flushreq_rs),
    .acp_ainact_rs_i                       (acp_ainact_rs),
    .master_writes_active_i                (master_writes_active),
    .dcu_ac_ready_i                        (dcu_cpu1_ac_ready_i),
    .dcu_cr_valid_i                        (dcu_cpu1_cr_valid_i),
    .dcu_cr_id_i                           (dcu_cpu1_cr_id_i[2:0]),
    .dcu_cr_dirty_i                        (dcu_cpu1_cr_dirty_i),
    .dcu_cr_age_i                          (dcu_cpu1_cr_age_i),
    .dcu_cr_alloc_i                        (dcu_cpu1_cr_alloc_i),
    .dcu_cr_migratory_i                    (dcu_cpu1_cr_migratory_i),
    .tagctl_cpuslv_ready_tc0_i             (tagctl_cpuslv1_ready_tc0),
    .tagctl_cpuslv_noncoh_only_i           (tagctl_cpuslv1_noncoh_only),
    .tagctl_slv_flush_tc1_i                (tagctl_slv_flush_tc1),
    .tagctl_slv_flush_tc2_i                (tagctl_slv_flush_tc2),
    .tagctl_slv_flush_tc3_i                (tagctl_slv_flush_tc3),
    .tagctl_slv_flush_tc4_i                (tagctl_slv_flush_tc4),
    .tagctl_slv_early_flush_tc4_i          (tagctl_slv_early_flush_tc4),
    .tagctl_ecc_err_tc3_i                  (tagctl_ecc_err_tc3),
    .tagctl_slv_l2db_tc1_i                 (tagctl_slv_l2db_tc1[3:0]),
    .tagctl_slv_l2db_tc4_i                 (tagctl_slv_l2db_tc4[3:0]),
    .tagctl_slv_snp_hz_tc4_i               (tagctl_slv_snp_hz_tc4),
    .tagctl_slv_snp_hz_id_tc4_i            (tagctl_slv_snp_hz_id_tc4[4:0]),
    .tagctl_slv_l2db_invalidated_tc4_i     (tagctl_slv_l2db_invalidated_tc4),
    .tagctl_slv_l2db_cleaned_tc4_i         (tagctl_slv_l2db_cleaned_tc4),
    .tagctl_slv_victim_l2db_tc4_i          (tagctl_slv_victim_l2db_tc4[3:0]),
    .afb0_done_i                           (afb0_done),
    .afb1_done_i                           (afb1_done),
    .afb2_done_i                           (afb2_done),
    .afb3_done_i                           (afb3_done),
    .afb4_done_i                           (afb4_done),
    .afb5_done_i                           (afb5_done),
    .afb0_snoop_resp_valid_i               (afb0_snoop_resp_valid),
    .afb1_snoop_resp_valid_i               (afb1_snoop_resp_valid),
    .afb2_snoop_resp_valid_i               (afb2_snoop_resp_valid),
    .afb3_snoop_resp_valid_i               (afb3_snoop_resp_valid),
    .afb4_snoop_resp_valid_i               (afb4_snoop_resp_valid),
    .afb5_snoop_resp_valid_i               (afb5_snoop_resp_valid),
    .afb0_snoop_resp_dirty_i               (afb0_snoop_resp_dirty),
    .afb1_snoop_resp_dirty_i               (afb1_snoop_resp_dirty),
    .afb2_snoop_resp_dirty_i               (afb2_snoop_resp_dirty),
    .afb3_snoop_resp_dirty_i               (afb3_snoop_resp_dirty),
    .afb4_snoop_resp_dirty_i               (afb4_snoop_resp_dirty),
    .afb5_snoop_resp_dirty_i               (afb5_snoop_resp_dirty),
    .afb0_snoop_resp_victim_valid_i        (afb0_snoop_resp_victim_valid),
    .afb1_snoop_resp_victim_valid_i        (afb1_snoop_resp_victim_valid),
    .afb2_snoop_resp_victim_valid_i        (afb2_snoop_resp_victim_valid),
    .afb3_snoop_resp_victim_valid_i        (afb3_snoop_resp_victim_valid),
    .afb4_snoop_resp_victim_valid_i        (afb4_snoop_resp_victim_valid),
    .afb5_snoop_resp_victim_valid_i        (afb5_snoop_resp_victim_valid),
    .afb0_snoop_resp_victim_dirty_i        (afb0_snoop_resp_victim_dirty),
    .afb1_snoop_resp_victim_dirty_i        (afb1_snoop_resp_victim_dirty),
    .afb2_snoop_resp_victim_dirty_i        (afb2_snoop_resp_victim_dirty),
    .afb3_snoop_resp_victim_dirty_i        (afb3_snoop_resp_victim_dirty),
    .afb4_snoop_resp_victim_dirty_i        (afb4_snoop_resp_victim_dirty),
    .afb5_snoop_resp_victim_dirty_i        (afb5_snoop_resp_victim_dirty),
    .afb0_snoop_resp_victim_age_i          (afb0_snoop_resp_victim_age),
    .afb1_snoop_resp_victim_age_i          (afb1_snoop_resp_victim_age),
    .afb2_snoop_resp_victim_age_i          (afb2_snoop_resp_victim_age),
    .afb3_snoop_resp_victim_age_i          (afb3_snoop_resp_victim_age),
    .afb4_snoop_resp_victim_age_i          (afb4_snoop_resp_victim_age),
    .afb5_snoop_resp_victim_age_i          (afb5_snoop_resp_victim_age),
    .afb0_snoop_resp_victim_alloc_i        (afb0_snoop_resp_victim_alloc),
    .afb1_snoop_resp_victim_alloc_i        (afb1_snoop_resp_victim_alloc),
    .afb2_snoop_resp_victim_alloc_i        (afb2_snoop_resp_victim_alloc),
    .afb3_snoop_resp_victim_alloc_i        (afb3_snoop_resp_victim_alloc),
    .afb4_snoop_resp_victim_alloc_i        (afb4_snoop_resp_victim_alloc),
    .afb5_snoop_resp_victim_alloc_i        (afb5_snoop_resp_victim_alloc),
    .afb0_snoop_resp_alloc_i               (afb0_snoop_resp_alloc),
    .afb1_snoop_resp_alloc_i               (afb1_snoop_resp_alloc),
    .afb2_snoop_resp_alloc_i               (afb2_snoop_resp_alloc),
    .afb3_snoop_resp_alloc_i               (afb3_snoop_resp_alloc),
    .afb4_snoop_resp_alloc_i               (afb4_snoop_resp_alloc),
    .afb5_snoop_resp_alloc_i               (afb5_snoop_resp_alloc),
    .afb0_snoop_resp_migratory_i           (afb0_snoop_resp_migratory),
    .afb1_snoop_resp_migratory_i           (afb1_snoop_resp_migratory),
    .afb2_snoop_resp_migratory_i           (afb2_snoop_resp_migratory),
    .afb3_snoop_resp_migratory_i           (afb3_snoop_resp_migratory),
    .afb4_snoop_resp_migratory_i           (afb4_snoop_resp_migratory),
    .afb5_snoop_resp_migratory_i           (afb5_snoop_resp_migratory),
    .afb0_write_done_i                     (afb0_write_done),
    .afb1_write_done_i                     (afb1_write_done),
    .afb2_write_done_i                     (afb2_write_done),
    .afb3_write_done_i                     (afb3_write_done),
    .afb4_write_done_i                     (afb4_write_done),
    .afb5_write_done_i                     (afb5_write_done),
    .tagctl_slv_afb_tc1_i                  (tagctl_slv_afb_tc1[2:0]),
    .tagctl_addr_tc1_i                     (tagctl_addr_tc1[41:6]),
    .tagctl_valid_tc1_i                    (tagctl_valid_tc1),
    .tagctl_addr_valid_tc1_i               (tagctl_addr_valid_tc1),
    .tagctl_index_valid_tc1_i              (tagctl_index_valid_tc1),
    .tagctl_l1_set_way_op_tc1_i            (tagctl_l1_set_way_op_tc1),
    .tagctl_l1_lf_tc1_i                    (tagctl_l1_lf_tc1),
    .tagctl_serialising_tc1_i              (tagctl_serialising_tc1),
    .tagctl_ecc_wr_tc1_i                   (tagctl_ecc_wr_tc1),
    .tagctl_ecc_way_tc1_i                  (tagctl_ecc_way_tc1[15:0]),
    .tagctl_reqbufid_tc1_i                 (tagctl_reqbufid_tc1[5:0]),
    .tagctl_cpu_sync_tc1_i                 (tagctl_cpu_sync_tc1),
    .tagctl_snp_sync_tc1_i                 (tagctl_snp_sync_tc1),
    .tagctl_addr_tc3_i                     (tagctl_addr_tc3[40:6]),
    .tagctl_addr_valid_tc3_i               (tagctl_addr_valid_tc3),
    .tagctl_reqbufid_tc3_i                 (tagctl_reqbufid_tc3[5:0]),
    .tagctl_noncoh_serialised_tc3_i        (tagctl_noncoh_serialised_tc3),
    .tagctl_l1_hit_ways_tc3_i              (tagctl_l1_hit_ways_tc3[15:0]),
    .tagctl_l2_hit_ways_tc3_i              (tagctl_l2_hit_ways_tc3[15:0]),
    .tagctl_l2_dirty_tc3_i                 (tagctl_l2_dirty_tc3),
    .tagctl_l2_alloc_tc3_i                 (tagctl_l2_alloc_tc3),
    .tagctl_shareability_tc3_i             (tagctl_shareability_tc3[1:0]),
    .tagctl_cluster_unique_tc3_i           (tagctl_cluster_unique_tc3),
    .tagctl_l1_victim_cluster_unique_tc3_i (tagctl_l1_victim_cluster_unique_tc3),
    .tagctl_l1_victim_shareability_tc3_i   (tagctl_l1_victim_shareability_tc3[1:0]),
    .tagctl_l2_victim_valid_tc3_i          (tagctl_l2_victim_valid_tc3),
    .tagctl_l2_victim_shareability_tc3_i   (tagctl_l2_victim_shareability_tc3[1:0]),
    .tagctl_l2_victim_alloc_tc3_i          (tagctl_l2_victim_alloc_tc3),
    .tagctl_l2_victim_cu_tc3_i             (tagctl_l2_victim_cu_tc3),
    .tagctl_l2_victim_way_tc3_i            (tagctl_l2_victim_way_tc3[3:0]),
    .tagctl_snoop_data_cpu_tc4_i           (tagctl_snoop_data_cpu_tc4[1:0]),
    .dvm_comp_sync_outstanding_i           (dvm_comp_sync_outstanding),
    .tagctl_cpuslv_ac_valid_i              (tagctl_cpuslv1_ac_valid),
    .tagctl_cpuslv_ac_snoop_i              (tagctl_cpuslv1_ac_snoop[3:0]),
    .tagctl_cpuslv_ac_id_i                 (tagctl_cpuslv1_ac_id[2:0]),
    .tagctl_cpuslv_ac_l2db_id_i            (tagctl_cpuslv1_ac_l2db_id[3:0]),
    .tagctl_cpuslv_ac_addr_i               (tagctl_cpuslv1_ac_addr[40:0]),
    .tagctl_cpuslv_ac_way_i                (tagctl_cpuslv1_ac_way[3:0]),
    .tagctl_cpuslv_snp_active_i            (tagctl_cpuslv1_snp_active),
    .snpslv_cpuslv_compack_ready_i         (snpslv_cpuslv1_compack_ready),
    .victimctl_ready_i                     (victimctl_ready),
    .victimctl_ready_id_i                  (victimctl_ready_id[5:0]),
    .victimctl_ack_i                       (victimctl_ack),
    .victimctl_ack_id_i                    (victimctl_ack_id[5:0]),
    .victimctl_victim_way_i                (victimctl_victim_way[3:0]),
    .victimctl_index_vc1_i                 (victimctl_index_vc1[10:0]),
    .l2db0_slv_done_i                      (l2db0_slv_done),
    .l2db1_slv_done_i                      (l2db1_slv_done),
    .l2db2_slv_done_i                      (l2db2_slv_done),
    .l2db3_slv_done_i                      (l2db3_slv_done),
    .l2db4_slv_done_i                      (l2db4_slv_done),
    .l2db5_slv_done_i                      (l2db5_slv_done),
    .l2db6_slv_done_i                      (l2db6_slv_done),
    .l2db7_slv_done_i                      (l2db7_slv_done),
    .l2db8_slv_done_i                      (l2db8_slv_done),
    .l2db9_slv_done_i                      (l2db9_slv_done),
    .l2db10_slv_done_i                     (l2db10_slv_done),
    .l2db0_full_line_i                     (l2db0_full_line),
    .l2db1_full_line_i                     (l2db1_full_line),
    .l2db2_full_line_i                     (l2db2_full_line),
    .l2db3_full_line_i                     (l2db3_full_line),
    .l2db4_full_line_i                     (l2db4_full_line),
    .l2db5_full_line_i                     (l2db5_full_line),
    .l2db6_full_line_i                     (l2db6_full_line),
    .l2db7_full_line_i                     (l2db7_full_line),
    .l2db8_full_line_i                     (l2db8_full_line),
    .l2db9_full_line_i                     (l2db9_full_line),
    .l2db10_full_line_i                    (l2db10_full_line),
    .l2db0_rmw_line_i                      (l2db0_rmw_line),
    .l2db1_rmw_line_i                      (l2db1_rmw_line),
    .l2db2_rmw_line_i                      (l2db2_rmw_line),
    .l2db3_rmw_line_i                      (l2db3_rmw_line),
    .l2db4_rmw_line_i                      (l2db4_rmw_line),
    .l2db5_rmw_line_i                      (l2db5_rmw_line),
    .l2db6_rmw_line_i                      (l2db6_rmw_line),
    .l2db7_rmw_line_i                      (l2db7_rmw_line),
    .l2db8_rmw_line_i                      (l2db8_rmw_line),
    .l2db9_rmw_line_i                      (l2db9_rmw_line),
    .l2db10_rmw_line_i                     (l2db10_rmw_line),
    .l2db0_cpuslv_data_active_i            (l2db0_cpuslv1_data_active),
    .l2db1_cpuslv_data_active_i            (l2db1_cpuslv1_data_active),
    .l2db2_cpuslv_data_active_i            (l2db2_cpuslv1_data_active),
    .l2db3_cpuslv_data_active_i            (l2db3_cpuslv1_data_active),
    .l2db4_cpuslv_data_active_i            (l2db4_cpuslv1_data_active),
    .l2db5_cpuslv_data_active_i            (l2db5_cpuslv1_data_active),
    .l2db6_cpuslv_data_active_i            (l2db6_cpuslv1_data_active),
    .l2db7_cpuslv_data_active_i            (l2db7_cpuslv1_data_active),
    .l2db8_cpuslv_data_active_i            (l2db8_cpuslv1_data_active),
    .l2db9_cpuslv_data_active_i            (l2db9_cpuslv1_data_active),
    .l2db10_cpuslv_data_active_i           (l2db10_cpuslv1_data_active),
    .master_early_dr_valid_i               (master_early_dr_valid),
    .master_early_dr_id_i                  (master_early_dr_id[5:0]),
    .master_early_dr_dbid_i                (master_early_dr_dbid[7:0]),
    .master_early_dr_srcid_i               (master_early_dr_srcid[6:0]),
    .master_early_dr_barrier_i             (master_early_dr_barrier),
    .master_early_dr_resp_i                (master_early_dr_resp[3:0]),
    .master_early_dr_same_i                (master_early_dr_same),
    .master_cpuslv_dr_valid_i              (master_cpuslv1_dr_valid),
    .master_cpuslv_dr_id_i                 (master_cpuslv1_dr_id[5:0]),
    .master_dr_chunk_i                     (master_dr_chunk[1:0]),
    .master_dr_data_i                      (master_dr_data[127:0]),
    .master_dr_resp_i                      (master_dr_resp[3:0]),
    .master_afb0_ack_i                     (master_afb0_ack),
    .master_afb1_ack_i                     (master_afb1_ack),
    .master_afb2_ack_i                     (master_afb2_ack),
    .master_afb3_ack_i                     (master_afb3_ack),
    .master_afb4_ack_i                     (master_afb4_ack),
    .master_afb5_ack_i                     (master_afb5_ack),
    .master_afb_waddr_id_i                 (master_afb_waddr_id[3:0]),
    .master_cpuslv_waddrs_valid_i          (master_cpuslv1_waddrs_valid),
    .master_cpuslv_barrier_db_valid_i      (master_cpuslv1_barrier_db_valid),
    .master_cpuslv_strex_db_valid_i        (master_cpuslv1_strex_db_valid),
    .master_cpuslv_dev_db_valid_i          (master_cpuslv1_dev_db_valid),
    .master_db_resp_i                      (master_db_resp[1:0]),
    .master_db_waddr_valid_i               (master_db_waddr_valid),
    .master_db_waddr_i                     (master_db_waddr[3:0]),
    .master_cpuslv_l2_waiting_i            (master_cpuslv1_l2_waiting[7:0]),
    .master_rsp_readreceipt_valid_i        (master_rsp_readreceipt_valid),
    .master_rsp_comp_valid_i               (master_rsp_comp_valid),
    .master_rsp_dbid_valid_i               (master_rsp_dbid_valid),
    .master_rsp_txnid_i                    (master_rsp_txnid[6:0]),
    .master_rsp_dbid_i                     (master_rsp_dbid[7:0]),
    .master_rsp_srcid_i                    (master_rsp_srcid[6:0]),
    .master_rsp_resp_i                     (master_rsp_resp[3:0]),
    .master_cpuslv_reqbuf_retry_i          (master_cpuslv1_reqbuf_retry[7:0]),
    .master_cpuslv_pcrdtype_i              (master_cpuslv1_pcrdtype[1:0]),
    .l2db0_slv_valid_i                     (l2db0_slv_valid),
    .l2db0_slv_id_i                        (l2db0_slv_id[5:0]),
    .l2db0_slv_biuid_i                     (l2db0_slv_biuid[4:0]),
    .l2db0_slv_data_i                      (l2db0_slv_data[127:0]),
    .l2db0_slv_chunk_i                     (l2db0_slv_chunk[1:0]),
    .l2db0_slv_bypass_i                    (l2db0_slv_bypass),
    .l2db0_slv_err_i                       (l2db0_slv_err),
    .l2db1_slv_valid_i                     (l2db1_slv_valid),
    .l2db1_slv_id_i                        (l2db1_slv_id[5:0]),
    .l2db1_slv_biuid_i                     (l2db1_slv_biuid[4:0]),
    .l2db1_slv_data_i                      (l2db1_slv_data[127:0]),
    .l2db1_slv_chunk_i                     (l2db1_slv_chunk[1:0]),
    .l2db1_slv_bypass_i                    (l2db1_slv_bypass),
    .l2db1_slv_err_i                       (l2db1_slv_err),
    .l2db2_slv_valid_i                     (l2db2_slv_valid),
    .l2db2_slv_id_i                        (l2db2_slv_id[5:0]),
    .l2db2_slv_biuid_i                     (l2db2_slv_biuid[4:0]),
    .l2db2_slv_data_i                      (l2db2_slv_data[127:0]),
    .l2db2_slv_chunk_i                     (l2db2_slv_chunk[1:0]),
    .l2db2_slv_bypass_i                    (l2db2_slv_bypass),
    .l2db2_slv_err_i                       (l2db2_slv_err),
    .l2db3_slv_valid_i                     (l2db3_slv_valid),
    .l2db3_slv_id_i                        (l2db3_slv_id[5:0]),
    .l2db3_slv_biuid_i                     (l2db3_slv_biuid[4:0]),
    .l2db3_slv_data_i                      (l2db3_slv_data[127:0]),
    .l2db3_slv_chunk_i                     (l2db3_slv_chunk[1:0]),
    .l2db3_slv_bypass_i                    (l2db3_slv_bypass),
    .l2db3_slv_err_i                       (l2db3_slv_err),
    .l2db4_slv_valid_i                     (l2db4_slv_valid),
    .l2db4_slv_id_i                        (l2db4_slv_id[5:0]),
    .l2db4_slv_biuid_i                     (l2db4_slv_biuid[4:0]),
    .l2db4_slv_data_i                      (l2db4_slv_data[127:0]),
    .l2db4_slv_chunk_i                     (l2db4_slv_chunk[1:0]),
    .l2db4_slv_bypass_i                    (l2db4_slv_bypass),
    .l2db4_slv_err_i                       (l2db4_slv_err),
    .l2db5_slv_valid_i                     (l2db5_slv_valid),
    .l2db5_slv_id_i                        (l2db5_slv_id[5:0]),
    .l2db5_slv_biuid_i                     (l2db5_slv_biuid[4:0]),
    .l2db5_slv_data_i                      (l2db5_slv_data[127:0]),
    .l2db5_slv_chunk_i                     (l2db5_slv_chunk[1:0]),
    .l2db5_slv_bypass_i                    (l2db5_slv_bypass),
    .l2db5_slv_err_i                       (l2db5_slv_err),
    .l2db6_slv_valid_i                     (l2db6_slv_valid),
    .l2db6_slv_id_i                        (l2db6_slv_id[5:0]),
    .l2db6_slv_biuid_i                     (l2db6_slv_biuid[4:0]),
    .l2db6_slv_data_i                      (l2db6_slv_data[127:0]),
    .l2db6_slv_chunk_i                     (l2db6_slv_chunk[1:0]),
    .l2db6_slv_bypass_i                    (l2db6_slv_bypass),
    .l2db6_slv_err_i                       (l2db6_slv_err),
    .l2db7_slv_valid_i                     (l2db7_slv_valid),
    .l2db7_slv_id_i                        (l2db7_slv_id[5:0]),
    .l2db7_slv_biuid_i                     (l2db7_slv_biuid[4:0]),
    .l2db7_slv_data_i                      (l2db7_slv_data[127:0]),
    .l2db7_slv_chunk_i                     (l2db7_slv_chunk[1:0]),
    .l2db7_slv_bypass_i                    (l2db7_slv_bypass),
    .l2db7_slv_err_i                       (l2db7_slv_err),
    .l2db8_slv_valid_i                     (l2db8_slv_valid),
    .l2db8_slv_id_i                        (l2db8_slv_id[5:0]),
    .l2db8_slv_biuid_i                     (l2db8_slv_biuid[4:0]),
    .l2db8_slv_data_i                      (l2db8_slv_data[127:0]),
    .l2db8_slv_chunk_i                     (l2db8_slv_chunk[1:0]),
    .l2db8_slv_bypass_i                    (l2db8_slv_bypass),
    .l2db8_slv_err_i                       (l2db8_slv_err),
    .l2db9_slv_valid_i                     (l2db9_slv_valid),
    .l2db9_slv_id_i                        (l2db9_slv_id[5:0]),
    .l2db9_slv_biuid_i                     (l2db9_slv_biuid[4:0]),
    .l2db9_slv_data_i                      (l2db9_slv_data[127:0]),
    .l2db9_slv_chunk_i                     (l2db9_slv_chunk[1:0]),
    .l2db9_slv_bypass_i                    (l2db9_slv_bypass),
    .l2db9_slv_err_i                       (l2db9_slv_err),
    .l2db10_slv_valid_i                    (l2db10_slv_valid),
    .l2db10_slv_id_i                       (l2db10_slv_id[5:0]),
    .l2db10_slv_biuid_i                    (l2db10_slv_biuid[4:0]),
    .l2db10_slv_data_i                     (l2db10_slv_data[127:0]),
    .l2db10_slv_chunk_i                    (l2db10_slv_chunk[1:0]),
    .l2db10_slv_bypass_i                   (l2db10_slv_bypass),
    .l2db10_slv_err_i                      (l2db10_slv_err),
    .ramctl_bypass_data_i                  (ramctl_bypass_data[127:0]),
    .ramctl_bypass_err_i                   (ramctl_bypass_err),
    // Outputs
    .cpuslv_active_o                       (cpuslv1_active),
    .cpuslv_wfx_active_o                   (cpuslv1_wfx_active),
    .scu_inv_all_ack_o                     (scu_cpu1_inv_all_ack_o),
    .scu_ar_credit_o                       (scu_cpu1_ar_credit_o),
    .scu_ar_block_o                        (scu_cpu1_ar_block_o),
    .scu_dr_valid_o                        (scu_cpu1_dr_valid_o),
    .scu_dr_id_o                           (scu_cpu1_dr_id_o[4:0]),
    .scu_dr_resp_o                         (scu_cpu1_dr_resp_o[5:0]),
    .scu_dr_chunk_o                        (scu_cpu1_dr_chunk_o[1:0]),
    .scu_dr_data_o                         (scu_cpu1_dr_data_o[127:0]),
    .scu_rr_valid_o                        (scu_cpu1_rr_valid_o),
    .scu_rr_id_o                           (scu_cpu1_rr_id_o[4:0]),
    .scu_rr_resp_o                         (scu_cpu1_rr_resp_o[1:0]),
    .scu_rr_l2db_id_o                      (scu_cpu1_rr_l2db_id_o[3:0]),
    .scu_ev_done_o                         (scu_cpu1_ev_done_o[7:0]),
    .scu_db_excl_valid_o                   (scu_cpu1_db_excl_valid_o),
    .scu_db_excl_resp_o                    (scu_cpu1_db_excl_resp_o[1:0]),
    .scu_db_decerr_o                       (scu_cpu1_db_decerr_o),
    .scu_db_slverr_o                       (scu_cpu1_db_slverr_o),
    .scu_leave_ramode_o                    (scu_cpu1_leave_ramode_o),
    .cpuslv_l2flushdone_o                  (cpuslv1_l2flushdone),
    .cpuslv_l2flush_active_o               (cpuslv1_l2flush_active),
    .scu_ac_valid_o                        (scu_cpu1_ac_valid_o),
    .scu_ac_snoop_o                        (scu_cpu1_ac_snoop_o[3:0]),
    .scu_ac_id_o                           (scu_cpu1_ac_id_o[2:0]),
    .scu_ac_l2db_id_o                      (scu_cpu1_ac_l2db_id_o[3:0]),
    .scu_ac_addr_o                         (scu_cpu1_ac_addr_o[40:0]),
    .scu_ac_way_o                          (scu_cpu1_ac_way_o[3:0]),
    .cpuslv_tagctl_valid_tc0_o             (cpuslv1_tagctl_valid_tc0),
    .cpuslv_tagctl_early_valid_tc0_o       (cpuslv1_tagctl_early_valid_tc0),
    .cpuslv_tagctl_spec_valid_tc0_o        (cpuslv1_tagctl_spec_valid_tc0),
    .cpuslv_tagctl_reqbufid_tc0_o          (cpuslv1_tagctl_reqbufid_tc0[2:0]),
    .cpuslv_tagctl_pass_tc0_o              (cpuslv1_tagctl_pass_tc0[3:0]),
    .cpuslv_tagctl_addr1_tc0_o             (cpuslv1_tagctl_addr1_tc0[40:0]),
    .cpuslv_tagctl_dvm_sync_tc0_o          (cpuslv1_tagctl_dvm_sync_tc0),
    .cpuslv_tagctl_wr_state_tc0_o          (cpuslv1_tagctl_wr_state_tc0[16:0]),
    .cpuslv_tagctl_ecc_tc0_o               (cpuslv1_tagctl_ecc_tc0[34:0]),
    .cpuslv_tagctl_ways_tc0_o              (cpuslv1_tagctl_ways_tc0[31:0]),
    .cpuslv_tagctl_write_tc0_o             (cpuslv1_tagctl_write_tc0[4:0]),
    .cpuslv_tagctl_type_tc0_o              (cpuslv1_tagctl_type_tc0[4:0]),
    .cpuslv_tagctl_l2flushreq_tc0_o        (cpuslv1_tagctl_l2flushreq_tc0),
    .cpuslv_tagctl_reqbuf_dcu_tc1_o        (cpuslv1_tagctl_reqbuf_dcu_tc1),
    .cpuslv_tagctl_addr2_tc1_o             (cpuslv1_tagctl_addr2_tc1[40:0]),
    .cpuslv_tagctl_len_tc1_o               (cpuslv1_tagctl_len_tc1[1:0]),
    .cpuslv_tagctl_size_tc1_o              (cpuslv1_tagctl_size_tc1[2:0]),
    .cpuslv_tagctl_lock_tc1_o              (cpuslv1_tagctl_lock_tc1),
    .cpuslv_tagctl_dirty_tc1_o             (cpuslv1_tagctl_dirty_tc1),
    .cpuslv_tagctl_cluster_unique_tc1_o    (cpuslv1_tagctl_cluster_unique_tc1),
    .cpuslv_tagctl_attrs_tc1_o             (cpuslv1_tagctl_attrs_tc1[7:0]),
    .cpuslv_tagctl_prot_tc1_o              (cpuslv1_tagctl_prot_tc1[1:0]),
    .cpuslv_tagctl_l2db_tc1_o              (cpuslv1_tagctl_l2db_tc1[3:0]),
    .cpuslv_tagctl_l2db_full_tc1_o         (cpuslv1_tagctl_l2db_full_tc1),
    .cpuslv_tagctl_static_pcredit_tc1_o    (cpuslv1_tagctl_static_pcredit_tc1),
    .cpuslv_tagctl_pcrdtype_tc1_o          (cpuslv1_tagctl_pcrdtype_tc1[1:0]),
    .cpuslv_tagctl_victim_way_tc1_o        (cpuslv1_tagctl_victim_way_tc1[3:0]),
    .cpuslv_inv_all_starting_o             (cpuslv1_inv_all_starting),
    .cpuslv_hz_tc2_o                       (cpuslv1_hz_tc2),
    .cpuslv_snp_hz_tc2_o                   (cpuslv1_snp_hz_tc2),
    .cpuslv_snp_hz_id_tc2_o                (cpuslv1_snp_hz_id_tc2[2:0]),
    .cpuslv_snp_l2db_hz_tc2_o              (cpuslv1_snp_l2db_hz_tc2),
    .cpuslv_snp_l2db_dirty_tc2_o           (cpuslv1_snp_l2db_dirty_tc2),
    .cpuslv_snp_l2db_tc2_o                 (cpuslv1_snp_l2db_tc2[3:0]),
    .cpuslv_ecc_hz_tc2_o                   (cpuslv1_ecc_hz_tc2),
    .cpuslv_force_miss_tc2_o               (cpuslv1_force_miss_tc2[31:0]),
    .cpuslv_l2_way_used_tc2_o              (cpuslv1_l2_way_used_tc2[15:0]),
    .cpuslv_hz_tc4_o                       (cpuslv1_hz_tc4),
    .scu_drain_stb_o                       (scu_cpu1_drain_stb_o),
    .cpuslv_noncoh_since_barrier_o         (cpuslv1_noncoh_since_barrier),
    .cpuslv_dvm_sync_resp_o                (cpuslv1_dvm_sync_resp),
    .cpuslv_ac_ready_o                     (cpuslv1_ac_ready),
    .cpuslv_cr_valid_o                     (cpuslv1_cr_valid),
    .cpuslv_cr_id_o                        (cpuslv1_cr_id[2:0]),
    .cpuslv_cr_dirty_o                     (cpuslv1_cr_dirty),
    .cpuslv_cr_age_o                       (cpuslv1_cr_age),
    .cpuslv_cr_alloc_o                     (cpuslv1_cr_alloc),
    .cpuslv_cr_migratory_o                 (cpuslv1_cr_migratory),
    .cpuslv_compack_active_o               (cpuslv1_compack_active),
    .cpuslv_compack_valid_o                (cpuslv1_compack_valid),
    .cpuslv_compack_tgtid_o                (cpuslv1_compack_tgtid[6:0]),
    .cpuslv_compack_txnid_o                (cpuslv1_compack_txnid[7:0]),
    .cpuslv_victimctl_active_o             (cpuslv1_victimctl_active),
    .cpuslv_victimctl_valid_o              (cpuslv1_victimctl_valid),
    .cpuslv_victimctl_index_o              (cpuslv1_victimctl_index[10:0]),
    .cpuslv_victimctl_wr_o                 (cpuslv1_victimctl_wr),
    .cpuslv_victimctl_age_o                (cpuslv1_victimctl_age),
    .cpuslv_victimctl_iside_o              (cpuslv1_victimctl_iside),
    .cpuslv_victimctl_nontemp_o            (cpuslv1_victimctl_nontemp),
    .cpuslv_victimctl_way_o                (cpuslv1_victimctl_way[3:0]),
    .cpuslv_victimctl_id_o                 (cpuslv1_victimctl_id[2:0]),
    .cpuslv_l2_way_used_vc2_o              (cpuslv1_l2_way_used_vc2[15:0]),
    .cpuslv_l2dbs_active_o                 (cpuslv1_l2dbs_active),
    .cpuslv_ramctl_active_o                (cpuslv1_ramctl_active),
    .cpuslv_l2db0_transfer_o               (cpuslv1_l2db0_transfer),
    .cpuslv_l2db0_transfer_type_o          (cpuslv1_l2db0_transfer_type[2:0]),
    .cpuslv_l2db0_transfer_info_o          (cpuslv1_l2db0_transfer_info[23:0]),
    .cpuslv_l2db0_release_o                (cpuslv1_l2db0_release),
    .cpuslv_l2db1_transfer_o               (cpuslv1_l2db1_transfer),
    .cpuslv_l2db1_transfer_type_o          (cpuslv1_l2db1_transfer_type[2:0]),
    .cpuslv_l2db1_transfer_info_o          (cpuslv1_l2db1_transfer_info[23:0]),
    .cpuslv_l2db1_release_o                (cpuslv1_l2db1_release),
    .cpuslv_l2db2_transfer_o               (cpuslv1_l2db2_transfer),
    .cpuslv_l2db2_transfer_type_o          (cpuslv1_l2db2_transfer_type[2:0]),
    .cpuslv_l2db2_transfer_info_o          (cpuslv1_l2db2_transfer_info[23:0]),
    .cpuslv_l2db2_release_o                (cpuslv1_l2db2_release),
    .cpuslv_l2db3_transfer_o               (cpuslv1_l2db3_transfer),
    .cpuslv_l2db3_transfer_type_o          (cpuslv1_l2db3_transfer_type[2:0]),
    .cpuslv_l2db3_transfer_info_o          (cpuslv1_l2db3_transfer_info[23:0]),
    .cpuslv_l2db3_release_o                (cpuslv1_l2db3_release),
    .cpuslv_l2db4_transfer_o               (cpuslv1_l2db4_transfer),
    .cpuslv_l2db4_transfer_type_o          (cpuslv1_l2db4_transfer_type[2:0]),
    .cpuslv_l2db4_transfer_info_o          (cpuslv1_l2db4_transfer_info[23:0]),
    .cpuslv_l2db4_release_o                (cpuslv1_l2db4_release),
    .cpuslv_l2db5_transfer_o               (cpuslv1_l2db5_transfer),
    .cpuslv_l2db5_transfer_type_o          (cpuslv1_l2db5_transfer_type[2:0]),
    .cpuslv_l2db5_transfer_info_o          (cpuslv1_l2db5_transfer_info[23:0]),
    .cpuslv_l2db5_release_o                (cpuslv1_l2db5_release),
    .cpuslv_l2db6_transfer_o               (cpuslv1_l2db6_transfer),
    .cpuslv_l2db6_transfer_type_o          (cpuslv1_l2db6_transfer_type[2:0]),
    .cpuslv_l2db6_transfer_info_o          (cpuslv1_l2db6_transfer_info[23:0]),
    .cpuslv_l2db6_release_o                (cpuslv1_l2db6_release),
    .cpuslv_l2db7_transfer_o               (cpuslv1_l2db7_transfer),
    .cpuslv_l2db7_transfer_type_o          (cpuslv1_l2db7_transfer_type[2:0]),
    .cpuslv_l2db7_transfer_info_o          (cpuslv1_l2db7_transfer_info[23:0]),
    .cpuslv_l2db7_release_o                (cpuslv1_l2db7_release),
    .cpuslv_l2db8_transfer_o               (cpuslv1_l2db8_transfer),
    .cpuslv_l2db8_transfer_type_o          (cpuslv1_l2db8_transfer_type[2:0]),
    .cpuslv_l2db8_transfer_info_o          (cpuslv1_l2db8_transfer_info[23:0]),
    .cpuslv_l2db8_release_o                (cpuslv1_l2db8_release),
    .cpuslv_l2db9_transfer_o               (cpuslv1_l2db9_transfer),
    .cpuslv_l2db9_transfer_type_o          (cpuslv1_l2db9_transfer_type[2:0]),
    .cpuslv_l2db9_transfer_info_o          (cpuslv1_l2db9_transfer_info[23:0]),
    .cpuslv_l2db9_release_o                (cpuslv1_l2db9_release),
    .cpuslv_l2db10_transfer_o              (cpuslv1_l2db10_transfer),
    .cpuslv_l2db10_transfer_type_o         (cpuslv1_l2db10_transfer_type[2:0]),
    .cpuslv_l2db10_transfer_info_o         (cpuslv1_l2db10_transfer_info[23:0]),
    .cpuslv_l2db10_release_o               (cpuslv1_l2db10_release),
    .cpuslv_early_dr_l2_o                  (cpuslv1_early_dr_l2),
    .cpuslv_early_dr_index_o               (cpuslv1_early_dr_index[10:0]),
    .cpuslv_early_dr_way_o                 (cpuslv1_early_dr_way[3:0]),
    .cpuslv_early_dr_ready_o               (cpuslv1_early_dr_ready[7:0]),
    .cpuslv_delay_allocation_o             (cpuslv1_delay_allocation[7:0]),
    .cpuslv_master_dr_ready_o              (cpuslv1_master_dr_ready),
    .cpuslv_master_sactive_o               (cpuslv1_master_sactive),
    .cpuslv_sample_waddrs_o                (cpuslv1_sample_waddrs),
    .cpuslv_sample_waddrs_dsb_o            (cpuslv1_sample_waddrs_dsb),
    .scu_reqbufs_busy_o                    (scu_cpu1_reqbufs_busy_o[7:0]),
    .cpuslv_l2db0_ready_o                  (cpuslv1_l2db0_ready),
    .cpuslv_l2db1_ready_o                  (cpuslv1_l2db1_ready),
    .cpuslv_l2db2_ready_o                  (cpuslv1_l2db2_ready),
    .cpuslv_l2db3_ready_o                  (cpuslv1_l2db3_ready),
    .cpuslv_l2db4_ready_o                  (cpuslv1_l2db4_ready),
    .cpuslv_l2db5_ready_o                  (cpuslv1_l2db5_ready),
    .cpuslv_l2db6_ready_o                  (cpuslv1_l2db6_ready),
    .cpuslv_l2db7_ready_o                  (cpuslv1_l2db7_ready),
    .cpuslv_l2db8_ready_o                  (cpuslv1_l2db8_ready),
    .cpuslv_l2db9_ready_o                  (cpuslv1_l2db9_ready),
    .cpuslv_l2db10_ready_o                 (cpuslv1_l2db10_ready),
    .cpuslv_l2dbs_dw_valid_o               (cpuslv1_l2dbs_dw_valid),
    .cpuslv_l2dbs_dw_id_o                  (cpuslv1_l2dbs_dw_id[3:0]),
    .cpuslv_l2dbs_dw_chunks_valid_o        (cpuslv1_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv_l2dbs_dw_last_o                (cpuslv1_l2dbs_dw_last),
    .cpuslv_l2dbs_dw_data_o                (cpuslv1_l2dbs_dw_data[255:0]),
    .cpuslv_l2dbs_dw_strb_o                (cpuslv1_l2dbs_dw_strb[31:0]),
    .cpuslv_l2dbs_dw_err_o                 (cpuslv1_l2dbs_dw_err),
    .cpuslv_l2dbs_dw_fatal_o               (cpuslv1_l2dbs_dw_fatal),
    .scu_evnt_eviction_o                   (scu_cpu1_evnt_eviction_o),
    .scu_evnt_snooped_data_o               (scu_cpu1_evnt_snooped_data_o),
    .scu_evnt_l2_access_o                  (scu_cpu1_evnt_l2_access_o)
  );  // u_scu_cpuslv1

  ca53scu_cpuslv #(`CA53_SCU_INT_PARAM_INST, .CPU_NUM(2)) u_scu_cpuslv2 (
    // TEMPLATE s/cpuslv/cpuslv2/
    // TEMPLATE s/biu_/biu_cpu2_/
    // TEMPLATE s/dcu_/dcu_cpu2_/
    // TEMPLATE s/gov_/gov_cpu2_/
    // TEMPLATE s/scu_/scu_cpu2_/
    /*ARMAUTO*/
    .gov_enable_writeevict_i               (gov_enable_writeevict_i),
    .gov_l2_in_retention_i                 (gov_l2_in_retention_i),
    .gov_standbywfi_i                      (gov_standbywfi_i[NUM_CPUS-1:0]),
    .gov_mbistreq_i                        (gov_mbistreq_i),
    // Inputs
    .CLKIN                                 (CLKIN),
    .clk                                   (clk),
    .reset_n                               (reset_n),
    .DFTSE                                 (DFTSE),
    .leaving_reset_i                       (leaving_reset),
    .config_broadcastinner_i               (config_broadcastinner),
    .config_broadcastouter_i               (config_broadcastouter),
    .config_broadcastcachemaint_i          (config_broadcastcachemaint),
    .config_sysbardisable_i                (config_sysbardisable),
    .config_l1_dc_size_i                   (config_l1_dc_size[2:0]),
    .config_l2_size_i                      (config_l2_size[3:0]),
    .gov_inv_all_req_i                     (gov_cpu2_inv_all_req_i),
    .biu_ar_active_i                       (biu_cpu2_ar_active_i),
    .biu_ar_valid_i                        (biu_cpu2_ar_valid_i),
    .biu_ar_id_i                           (biu_cpu2_ar_id_i[4:0]),
    .biu_ar_type_i                         (biu_cpu2_ar_type_i[4:0]),
    .biu_ar_attrs_i                        (biu_cpu2_ar_attrs_i[7:0]),
    .biu_ar_way_i                          (biu_cpu2_ar_way_i[4:0]),
    .biu_ar_addr_i                         (biu_cpu2_ar_addr_i[40:0]),
    .biu_ar_len_i                          (biu_cpu2_ar_len_i[1:0]),
    .biu_ar_size_i                         (biu_cpu2_ar_size_i[2:0]),
    .biu_ar_lock_i                         (biu_cpu2_ar_lock_i),
    .biu_ar_priv_i                         (biu_cpu2_ar_priv_i),
    .biu_dr_credit_i                       (biu_cpu2_dr_credit_i),
    .biu_dw_valid_i                        (biu_cpu2_dw_valid_i),
    .biu_dw_l2db_id_i                      (biu_cpu2_dw_l2db_id_i[3:0]),
    .biu_dw_chunks_valid_i                 (biu_cpu2_dw_chunks_valid_i[3:0]),
    .biu_dw_last_i                         (biu_cpu2_dw_last_i),
    .biu_dw_strb_i                         (biu_cpu2_dw_strb_i[31:0]),
    .biu_dw_data_i                         (biu_cpu2_dw_data_i[255:0]),
    .biu_dw_err_i                          (biu_cpu2_dw_err_i),
    .biu_dw_fatal_i                        (biu_cpu2_dw_fatal_i),
    .l2flushreq_rs_i                       (l2flushreq_rs),
    .acp_ainact_rs_i                       (acp_ainact_rs),
    .master_writes_active_i                (master_writes_active),
    .dcu_ac_ready_i                        (dcu_cpu2_ac_ready_i),
    .dcu_cr_valid_i                        (dcu_cpu2_cr_valid_i),
    .dcu_cr_id_i                           (dcu_cpu2_cr_id_i[2:0]),
    .dcu_cr_dirty_i                        (dcu_cpu2_cr_dirty_i),
    .dcu_cr_age_i                          (dcu_cpu2_cr_age_i),
    .dcu_cr_alloc_i                        (dcu_cpu2_cr_alloc_i),
    .dcu_cr_migratory_i                    (dcu_cpu2_cr_migratory_i),
    .tagctl_cpuslv_ready_tc0_i             (tagctl_cpuslv2_ready_tc0),
    .tagctl_cpuslv_noncoh_only_i           (tagctl_cpuslv2_noncoh_only),
    .tagctl_slv_flush_tc1_i                (tagctl_slv_flush_tc1),
    .tagctl_slv_flush_tc2_i                (tagctl_slv_flush_tc2),
    .tagctl_slv_flush_tc3_i                (tagctl_slv_flush_tc3),
    .tagctl_slv_flush_tc4_i                (tagctl_slv_flush_tc4),
    .tagctl_slv_early_flush_tc4_i          (tagctl_slv_early_flush_tc4),
    .tagctl_ecc_err_tc3_i                  (tagctl_ecc_err_tc3),
    .tagctl_slv_l2db_tc1_i                 (tagctl_slv_l2db_tc1[3:0]),
    .tagctl_slv_l2db_tc4_i                 (tagctl_slv_l2db_tc4[3:0]),
    .tagctl_slv_snp_hz_tc4_i               (tagctl_slv_snp_hz_tc4),
    .tagctl_slv_snp_hz_id_tc4_i            (tagctl_slv_snp_hz_id_tc4[4:0]),
    .tagctl_slv_l2db_invalidated_tc4_i     (tagctl_slv_l2db_invalidated_tc4),
    .tagctl_slv_l2db_cleaned_tc4_i         (tagctl_slv_l2db_cleaned_tc4),
    .tagctl_slv_victim_l2db_tc4_i          (tagctl_slv_victim_l2db_tc4[3:0]),
    .afb0_done_i                           (afb0_done),
    .afb1_done_i                           (afb1_done),
    .afb2_done_i                           (afb2_done),
    .afb3_done_i                           (afb3_done),
    .afb4_done_i                           (afb4_done),
    .afb5_done_i                           (afb5_done),
    .afb0_snoop_resp_valid_i               (afb0_snoop_resp_valid),
    .afb1_snoop_resp_valid_i               (afb1_snoop_resp_valid),
    .afb2_snoop_resp_valid_i               (afb2_snoop_resp_valid),
    .afb3_snoop_resp_valid_i               (afb3_snoop_resp_valid),
    .afb4_snoop_resp_valid_i               (afb4_snoop_resp_valid),
    .afb5_snoop_resp_valid_i               (afb5_snoop_resp_valid),
    .afb0_snoop_resp_dirty_i               (afb0_snoop_resp_dirty),
    .afb1_snoop_resp_dirty_i               (afb1_snoop_resp_dirty),
    .afb2_snoop_resp_dirty_i               (afb2_snoop_resp_dirty),
    .afb3_snoop_resp_dirty_i               (afb3_snoop_resp_dirty),
    .afb4_snoop_resp_dirty_i               (afb4_snoop_resp_dirty),
    .afb5_snoop_resp_dirty_i               (afb5_snoop_resp_dirty),
    .afb0_snoop_resp_victim_valid_i        (afb0_snoop_resp_victim_valid),
    .afb1_snoop_resp_victim_valid_i        (afb1_snoop_resp_victim_valid),
    .afb2_snoop_resp_victim_valid_i        (afb2_snoop_resp_victim_valid),
    .afb3_snoop_resp_victim_valid_i        (afb3_snoop_resp_victim_valid),
    .afb4_snoop_resp_victim_valid_i        (afb4_snoop_resp_victim_valid),
    .afb5_snoop_resp_victim_valid_i        (afb5_snoop_resp_victim_valid),
    .afb0_snoop_resp_victim_dirty_i        (afb0_snoop_resp_victim_dirty),
    .afb1_snoop_resp_victim_dirty_i        (afb1_snoop_resp_victim_dirty),
    .afb2_snoop_resp_victim_dirty_i        (afb2_snoop_resp_victim_dirty),
    .afb3_snoop_resp_victim_dirty_i        (afb3_snoop_resp_victim_dirty),
    .afb4_snoop_resp_victim_dirty_i        (afb4_snoop_resp_victim_dirty),
    .afb5_snoop_resp_victim_dirty_i        (afb5_snoop_resp_victim_dirty),
    .afb0_snoop_resp_victim_age_i          (afb0_snoop_resp_victim_age),
    .afb1_snoop_resp_victim_age_i          (afb1_snoop_resp_victim_age),
    .afb2_snoop_resp_victim_age_i          (afb2_snoop_resp_victim_age),
    .afb3_snoop_resp_victim_age_i          (afb3_snoop_resp_victim_age),
    .afb4_snoop_resp_victim_age_i          (afb4_snoop_resp_victim_age),
    .afb5_snoop_resp_victim_age_i          (afb5_snoop_resp_victim_age),
    .afb0_snoop_resp_victim_alloc_i        (afb0_snoop_resp_victim_alloc),
    .afb1_snoop_resp_victim_alloc_i        (afb1_snoop_resp_victim_alloc),
    .afb2_snoop_resp_victim_alloc_i        (afb2_snoop_resp_victim_alloc),
    .afb3_snoop_resp_victim_alloc_i        (afb3_snoop_resp_victim_alloc),
    .afb4_snoop_resp_victim_alloc_i        (afb4_snoop_resp_victim_alloc),
    .afb5_snoop_resp_victim_alloc_i        (afb5_snoop_resp_victim_alloc),
    .afb0_snoop_resp_alloc_i               (afb0_snoop_resp_alloc),
    .afb1_snoop_resp_alloc_i               (afb1_snoop_resp_alloc),
    .afb2_snoop_resp_alloc_i               (afb2_snoop_resp_alloc),
    .afb3_snoop_resp_alloc_i               (afb3_snoop_resp_alloc),
    .afb4_snoop_resp_alloc_i               (afb4_snoop_resp_alloc),
    .afb5_snoop_resp_alloc_i               (afb5_snoop_resp_alloc),
    .afb0_snoop_resp_migratory_i           (afb0_snoop_resp_migratory),
    .afb1_snoop_resp_migratory_i           (afb1_snoop_resp_migratory),
    .afb2_snoop_resp_migratory_i           (afb2_snoop_resp_migratory),
    .afb3_snoop_resp_migratory_i           (afb3_snoop_resp_migratory),
    .afb4_snoop_resp_migratory_i           (afb4_snoop_resp_migratory),
    .afb5_snoop_resp_migratory_i           (afb5_snoop_resp_migratory),
    .afb0_write_done_i                     (afb0_write_done),
    .afb1_write_done_i                     (afb1_write_done),
    .afb2_write_done_i                     (afb2_write_done),
    .afb3_write_done_i                     (afb3_write_done),
    .afb4_write_done_i                     (afb4_write_done),
    .afb5_write_done_i                     (afb5_write_done),
    .tagctl_slv_afb_tc1_i                  (tagctl_slv_afb_tc1[2:0]),
    .tagctl_addr_tc1_i                     (tagctl_addr_tc1[41:6]),
    .tagctl_valid_tc1_i                    (tagctl_valid_tc1),
    .tagctl_addr_valid_tc1_i               (tagctl_addr_valid_tc1),
    .tagctl_index_valid_tc1_i              (tagctl_index_valid_tc1),
    .tagctl_l1_set_way_op_tc1_i            (tagctl_l1_set_way_op_tc1),
    .tagctl_l1_lf_tc1_i                    (tagctl_l1_lf_tc1),
    .tagctl_serialising_tc1_i              (tagctl_serialising_tc1),
    .tagctl_ecc_wr_tc1_i                   (tagctl_ecc_wr_tc1),
    .tagctl_ecc_way_tc1_i                  (tagctl_ecc_way_tc1[15:0]),
    .tagctl_reqbufid_tc1_i                 (tagctl_reqbufid_tc1[5:0]),
    .tagctl_cpu_sync_tc1_i                 (tagctl_cpu_sync_tc1),
    .tagctl_snp_sync_tc1_i                 (tagctl_snp_sync_tc1),
    .tagctl_addr_tc3_i                     (tagctl_addr_tc3[40:6]),
    .tagctl_addr_valid_tc3_i               (tagctl_addr_valid_tc3),
    .tagctl_reqbufid_tc3_i                 (tagctl_reqbufid_tc3[5:0]),
    .tagctl_noncoh_serialised_tc3_i        (tagctl_noncoh_serialised_tc3),
    .tagctl_l1_hit_ways_tc3_i              (tagctl_l1_hit_ways_tc3[15:0]),
    .tagctl_l2_hit_ways_tc3_i              (tagctl_l2_hit_ways_tc3[15:0]),
    .tagctl_l2_dirty_tc3_i                 (tagctl_l2_dirty_tc3),
    .tagctl_l2_alloc_tc3_i                 (tagctl_l2_alloc_tc3),
    .tagctl_shareability_tc3_i             (tagctl_shareability_tc3[1:0]),
    .tagctl_cluster_unique_tc3_i           (tagctl_cluster_unique_tc3),
    .tagctl_l1_victim_cluster_unique_tc3_i (tagctl_l1_victim_cluster_unique_tc3),
    .tagctl_l1_victim_shareability_tc3_i   (tagctl_l1_victim_shareability_tc3[1:0]),
    .tagctl_l2_victim_valid_tc3_i          (tagctl_l2_victim_valid_tc3),
    .tagctl_l2_victim_shareability_tc3_i   (tagctl_l2_victim_shareability_tc3[1:0]),
    .tagctl_l2_victim_alloc_tc3_i          (tagctl_l2_victim_alloc_tc3),
    .tagctl_l2_victim_cu_tc3_i             (tagctl_l2_victim_cu_tc3),
    .tagctl_l2_victim_way_tc3_i            (tagctl_l2_victim_way_tc3[3:0]),
    .tagctl_snoop_data_cpu_tc4_i           (tagctl_snoop_data_cpu_tc4[1:0]),
    .dvm_comp_sync_outstanding_i           (dvm_comp_sync_outstanding),
    .tagctl_cpuslv_ac_valid_i              (tagctl_cpuslv2_ac_valid),
    .tagctl_cpuslv_ac_snoop_i              (tagctl_cpuslv2_ac_snoop[3:0]),
    .tagctl_cpuslv_ac_id_i                 (tagctl_cpuslv2_ac_id[2:0]),
    .tagctl_cpuslv_ac_l2db_id_i            (tagctl_cpuslv2_ac_l2db_id[3:0]),
    .tagctl_cpuslv_ac_addr_i               (tagctl_cpuslv2_ac_addr[40:0]),
    .tagctl_cpuslv_ac_way_i                (tagctl_cpuslv2_ac_way[3:0]),
    .tagctl_cpuslv_snp_active_i            (tagctl_cpuslv2_snp_active),
    .snpslv_cpuslv_compack_ready_i         (snpslv_cpuslv2_compack_ready),
    .victimctl_ready_i                     (victimctl_ready),
    .victimctl_ready_id_i                  (victimctl_ready_id[5:0]),
    .victimctl_ack_i                       (victimctl_ack),
    .victimctl_ack_id_i                    (victimctl_ack_id[5:0]),
    .victimctl_victim_way_i                (victimctl_victim_way[3:0]),
    .victimctl_index_vc1_i                 (victimctl_index_vc1[10:0]),
    .l2db0_slv_done_i                      (l2db0_slv_done),
    .l2db1_slv_done_i                      (l2db1_slv_done),
    .l2db2_slv_done_i                      (l2db2_slv_done),
    .l2db3_slv_done_i                      (l2db3_slv_done),
    .l2db4_slv_done_i                      (l2db4_slv_done),
    .l2db5_slv_done_i                      (l2db5_slv_done),
    .l2db6_slv_done_i                      (l2db6_slv_done),
    .l2db7_slv_done_i                      (l2db7_slv_done),
    .l2db8_slv_done_i                      (l2db8_slv_done),
    .l2db9_slv_done_i                      (l2db9_slv_done),
    .l2db10_slv_done_i                     (l2db10_slv_done),
    .l2db0_full_line_i                     (l2db0_full_line),
    .l2db1_full_line_i                     (l2db1_full_line),
    .l2db2_full_line_i                     (l2db2_full_line),
    .l2db3_full_line_i                     (l2db3_full_line),
    .l2db4_full_line_i                     (l2db4_full_line),
    .l2db5_full_line_i                     (l2db5_full_line),
    .l2db6_full_line_i                     (l2db6_full_line),
    .l2db7_full_line_i                     (l2db7_full_line),
    .l2db8_full_line_i                     (l2db8_full_line),
    .l2db9_full_line_i                     (l2db9_full_line),
    .l2db10_full_line_i                    (l2db10_full_line),
    .l2db0_rmw_line_i                      (l2db0_rmw_line),
    .l2db1_rmw_line_i                      (l2db1_rmw_line),
    .l2db2_rmw_line_i                      (l2db2_rmw_line),
    .l2db3_rmw_line_i                      (l2db3_rmw_line),
    .l2db4_rmw_line_i                      (l2db4_rmw_line),
    .l2db5_rmw_line_i                      (l2db5_rmw_line),
    .l2db6_rmw_line_i                      (l2db6_rmw_line),
    .l2db7_rmw_line_i                      (l2db7_rmw_line),
    .l2db8_rmw_line_i                      (l2db8_rmw_line),
    .l2db9_rmw_line_i                      (l2db9_rmw_line),
    .l2db10_rmw_line_i                     (l2db10_rmw_line),
    .l2db0_cpuslv_data_active_i            (l2db0_cpuslv2_data_active),
    .l2db1_cpuslv_data_active_i            (l2db1_cpuslv2_data_active),
    .l2db2_cpuslv_data_active_i            (l2db2_cpuslv2_data_active),
    .l2db3_cpuslv_data_active_i            (l2db3_cpuslv2_data_active),
    .l2db4_cpuslv_data_active_i            (l2db4_cpuslv2_data_active),
    .l2db5_cpuslv_data_active_i            (l2db5_cpuslv2_data_active),
    .l2db6_cpuslv_data_active_i            (l2db6_cpuslv2_data_active),
    .l2db7_cpuslv_data_active_i            (l2db7_cpuslv2_data_active),
    .l2db8_cpuslv_data_active_i            (l2db8_cpuslv2_data_active),
    .l2db9_cpuslv_data_active_i            (l2db9_cpuslv2_data_active),
    .l2db10_cpuslv_data_active_i           (l2db10_cpuslv2_data_active),
    .master_early_dr_valid_i               (master_early_dr_valid),
    .master_early_dr_id_i                  (master_early_dr_id[5:0]),
    .master_early_dr_dbid_i                (master_early_dr_dbid[7:0]),
    .master_early_dr_srcid_i               (master_early_dr_srcid[6:0]),
    .master_early_dr_barrier_i             (master_early_dr_barrier),
    .master_early_dr_resp_i                (master_early_dr_resp[3:0]),
    .master_early_dr_same_i                (master_early_dr_same),
    .master_cpuslv_dr_valid_i              (master_cpuslv2_dr_valid),
    .master_cpuslv_dr_id_i                 (master_cpuslv2_dr_id[5:0]),
    .master_dr_chunk_i                     (master_dr_chunk[1:0]),
    .master_dr_data_i                      (master_dr_data[127:0]),
    .master_dr_resp_i                      (master_dr_resp[3:0]),
    .master_afb0_ack_i                     (master_afb0_ack),
    .master_afb1_ack_i                     (master_afb1_ack),
    .master_afb2_ack_i                     (master_afb2_ack),
    .master_afb3_ack_i                     (master_afb3_ack),
    .master_afb4_ack_i                     (master_afb4_ack),
    .master_afb5_ack_i                     (master_afb5_ack),
    .master_afb_waddr_id_i                 (master_afb_waddr_id[3:0]),
    .master_cpuslv_waddrs_valid_i          (master_cpuslv2_waddrs_valid),
    .master_cpuslv_barrier_db_valid_i      (master_cpuslv2_barrier_db_valid),
    .master_cpuslv_strex_db_valid_i        (master_cpuslv2_strex_db_valid),
    .master_cpuslv_dev_db_valid_i          (master_cpuslv2_dev_db_valid),
    .master_db_resp_i                      (master_db_resp[1:0]),
    .master_db_waddr_valid_i               (master_db_waddr_valid),
    .master_db_waddr_i                     (master_db_waddr[3:0]),
    .master_cpuslv_l2_waiting_i            (master_cpuslv2_l2_waiting[7:0]),
    .master_rsp_readreceipt_valid_i        (master_rsp_readreceipt_valid),
    .master_rsp_comp_valid_i               (master_rsp_comp_valid),
    .master_rsp_dbid_valid_i               (master_rsp_dbid_valid),
    .master_rsp_txnid_i                    (master_rsp_txnid[6:0]),
    .master_rsp_dbid_i                     (master_rsp_dbid[7:0]),
    .master_rsp_srcid_i                    (master_rsp_srcid[6:0]),
    .master_rsp_resp_i                     (master_rsp_resp[3:0]),
    .master_cpuslv_reqbuf_retry_i          (master_cpuslv2_reqbuf_retry[7:0]),
    .master_cpuslv_pcrdtype_i              (master_cpuslv2_pcrdtype[1:0]),
    .l2db0_slv_valid_i                     (l2db0_slv_valid),
    .l2db0_slv_id_i                        (l2db0_slv_id[5:0]),
    .l2db0_slv_biuid_i                     (l2db0_slv_biuid[4:0]),
    .l2db0_slv_data_i                      (l2db0_slv_data[127:0]),
    .l2db0_slv_chunk_i                     (l2db0_slv_chunk[1:0]),
    .l2db0_slv_bypass_i                    (l2db0_slv_bypass),
    .l2db0_slv_err_i                       (l2db0_slv_err),
    .l2db1_slv_valid_i                     (l2db1_slv_valid),
    .l2db1_slv_id_i                        (l2db1_slv_id[5:0]),
    .l2db1_slv_biuid_i                     (l2db1_slv_biuid[4:0]),
    .l2db1_slv_data_i                      (l2db1_slv_data[127:0]),
    .l2db1_slv_chunk_i                     (l2db1_slv_chunk[1:0]),
    .l2db1_slv_bypass_i                    (l2db1_slv_bypass),
    .l2db1_slv_err_i                       (l2db1_slv_err),
    .l2db2_slv_valid_i                     (l2db2_slv_valid),
    .l2db2_slv_id_i                        (l2db2_slv_id[5:0]),
    .l2db2_slv_biuid_i                     (l2db2_slv_biuid[4:0]),
    .l2db2_slv_data_i                      (l2db2_slv_data[127:0]),
    .l2db2_slv_chunk_i                     (l2db2_slv_chunk[1:0]),
    .l2db2_slv_bypass_i                    (l2db2_slv_bypass),
    .l2db2_slv_err_i                       (l2db2_slv_err),
    .l2db3_slv_valid_i                     (l2db3_slv_valid),
    .l2db3_slv_id_i                        (l2db3_slv_id[5:0]),
    .l2db3_slv_biuid_i                     (l2db3_slv_biuid[4:0]),
    .l2db3_slv_data_i                      (l2db3_slv_data[127:0]),
    .l2db3_slv_chunk_i                     (l2db3_slv_chunk[1:0]),
    .l2db3_slv_bypass_i                    (l2db3_slv_bypass),
    .l2db3_slv_err_i                       (l2db3_slv_err),
    .l2db4_slv_valid_i                     (l2db4_slv_valid),
    .l2db4_slv_id_i                        (l2db4_slv_id[5:0]),
    .l2db4_slv_biuid_i                     (l2db4_slv_biuid[4:0]),
    .l2db4_slv_data_i                      (l2db4_slv_data[127:0]),
    .l2db4_slv_chunk_i                     (l2db4_slv_chunk[1:0]),
    .l2db4_slv_bypass_i                    (l2db4_slv_bypass),
    .l2db4_slv_err_i                       (l2db4_slv_err),
    .l2db5_slv_valid_i                     (l2db5_slv_valid),
    .l2db5_slv_id_i                        (l2db5_slv_id[5:0]),
    .l2db5_slv_biuid_i                     (l2db5_slv_biuid[4:0]),
    .l2db5_slv_data_i                      (l2db5_slv_data[127:0]),
    .l2db5_slv_chunk_i                     (l2db5_slv_chunk[1:0]),
    .l2db5_slv_bypass_i                    (l2db5_slv_bypass),
    .l2db5_slv_err_i                       (l2db5_slv_err),
    .l2db6_slv_valid_i                     (l2db6_slv_valid),
    .l2db6_slv_id_i                        (l2db6_slv_id[5:0]),
    .l2db6_slv_biuid_i                     (l2db6_slv_biuid[4:0]),
    .l2db6_slv_data_i                      (l2db6_slv_data[127:0]),
    .l2db6_slv_chunk_i                     (l2db6_slv_chunk[1:0]),
    .l2db6_slv_bypass_i                    (l2db6_slv_bypass),
    .l2db6_slv_err_i                       (l2db6_slv_err),
    .l2db7_slv_valid_i                     (l2db7_slv_valid),
    .l2db7_slv_id_i                        (l2db7_slv_id[5:0]),
    .l2db7_slv_biuid_i                     (l2db7_slv_biuid[4:0]),
    .l2db7_slv_data_i                      (l2db7_slv_data[127:0]),
    .l2db7_slv_chunk_i                     (l2db7_slv_chunk[1:0]),
    .l2db7_slv_bypass_i                    (l2db7_slv_bypass),
    .l2db7_slv_err_i                       (l2db7_slv_err),
    .l2db8_slv_valid_i                     (l2db8_slv_valid),
    .l2db8_slv_id_i                        (l2db8_slv_id[5:0]),
    .l2db8_slv_biuid_i                     (l2db8_slv_biuid[4:0]),
    .l2db8_slv_data_i                      (l2db8_slv_data[127:0]),
    .l2db8_slv_chunk_i                     (l2db8_slv_chunk[1:0]),
    .l2db8_slv_bypass_i                    (l2db8_slv_bypass),
    .l2db8_slv_err_i                       (l2db8_slv_err),
    .l2db9_slv_valid_i                     (l2db9_slv_valid),
    .l2db9_slv_id_i                        (l2db9_slv_id[5:0]),
    .l2db9_slv_biuid_i                     (l2db9_slv_biuid[4:0]),
    .l2db9_slv_data_i                      (l2db9_slv_data[127:0]),
    .l2db9_slv_chunk_i                     (l2db9_slv_chunk[1:0]),
    .l2db9_slv_bypass_i                    (l2db9_slv_bypass),
    .l2db9_slv_err_i                       (l2db9_slv_err),
    .l2db10_slv_valid_i                    (l2db10_slv_valid),
    .l2db10_slv_id_i                       (l2db10_slv_id[5:0]),
    .l2db10_slv_biuid_i                    (l2db10_slv_biuid[4:0]),
    .l2db10_slv_data_i                     (l2db10_slv_data[127:0]),
    .l2db10_slv_chunk_i                    (l2db10_slv_chunk[1:0]),
    .l2db10_slv_bypass_i                   (l2db10_slv_bypass),
    .l2db10_slv_err_i                      (l2db10_slv_err),
    .ramctl_bypass_data_i                  (ramctl_bypass_data[127:0]),
    .ramctl_bypass_err_i                   (ramctl_bypass_err),
    // Outputs
    .cpuslv_active_o                       (cpuslv2_active),
    .cpuslv_wfx_active_o                   (cpuslv2_wfx_active),
    .scu_inv_all_ack_o                     (scu_cpu2_inv_all_ack_o),
    .scu_ar_credit_o                       (scu_cpu2_ar_credit_o),
    .scu_ar_block_o                        (scu_cpu2_ar_block_o),
    .scu_dr_valid_o                        (scu_cpu2_dr_valid_o),
    .scu_dr_id_o                           (scu_cpu2_dr_id_o[4:0]),
    .scu_dr_resp_o                         (scu_cpu2_dr_resp_o[5:0]),
    .scu_dr_chunk_o                        (scu_cpu2_dr_chunk_o[1:0]),
    .scu_dr_data_o                         (scu_cpu2_dr_data_o[127:0]),
    .scu_rr_valid_o                        (scu_cpu2_rr_valid_o),
    .scu_rr_id_o                           (scu_cpu2_rr_id_o[4:0]),
    .scu_rr_resp_o                         (scu_cpu2_rr_resp_o[1:0]),
    .scu_rr_l2db_id_o                      (scu_cpu2_rr_l2db_id_o[3:0]),
    .scu_ev_done_o                         (scu_cpu2_ev_done_o[7:0]),
    .scu_db_excl_valid_o                   (scu_cpu2_db_excl_valid_o),
    .scu_db_excl_resp_o                    (scu_cpu2_db_excl_resp_o[1:0]),
    .scu_db_decerr_o                       (scu_cpu2_db_decerr_o),
    .scu_db_slverr_o                       (scu_cpu2_db_slverr_o),
    .scu_leave_ramode_o                    (scu_cpu2_leave_ramode_o),
    .cpuslv_l2flushdone_o                  (cpuslv2_l2flushdone),
    .cpuslv_l2flush_active_o               (cpuslv2_l2flush_active),
    .scu_ac_valid_o                        (scu_cpu2_ac_valid_o),
    .scu_ac_snoop_o                        (scu_cpu2_ac_snoop_o[3:0]),
    .scu_ac_id_o                           (scu_cpu2_ac_id_o[2:0]),
    .scu_ac_l2db_id_o                      (scu_cpu2_ac_l2db_id_o[3:0]),
    .scu_ac_addr_o                         (scu_cpu2_ac_addr_o[40:0]),
    .scu_ac_way_o                          (scu_cpu2_ac_way_o[3:0]),
    .cpuslv_tagctl_valid_tc0_o             (cpuslv2_tagctl_valid_tc0),
    .cpuslv_tagctl_early_valid_tc0_o       (cpuslv2_tagctl_early_valid_tc0),
    .cpuslv_tagctl_spec_valid_tc0_o        (cpuslv2_tagctl_spec_valid_tc0),
    .cpuslv_tagctl_reqbufid_tc0_o          (cpuslv2_tagctl_reqbufid_tc0[2:0]),
    .cpuslv_tagctl_pass_tc0_o              (cpuslv2_tagctl_pass_tc0[3:0]),
    .cpuslv_tagctl_addr1_tc0_o             (cpuslv2_tagctl_addr1_tc0[40:0]),
    .cpuslv_tagctl_dvm_sync_tc0_o          (cpuslv2_tagctl_dvm_sync_tc0),
    .cpuslv_tagctl_wr_state_tc0_o          (cpuslv2_tagctl_wr_state_tc0[16:0]),
    .cpuslv_tagctl_ecc_tc0_o               (cpuslv2_tagctl_ecc_tc0[34:0]),
    .cpuslv_tagctl_ways_tc0_o              (cpuslv2_tagctl_ways_tc0[31:0]),
    .cpuslv_tagctl_write_tc0_o             (cpuslv2_tagctl_write_tc0[4:0]),
    .cpuslv_tagctl_type_tc0_o              (cpuslv2_tagctl_type_tc0[4:0]),
    .cpuslv_tagctl_l2flushreq_tc0_o        (cpuslv2_tagctl_l2flushreq_tc0),
    .cpuslv_tagctl_reqbuf_dcu_tc1_o        (cpuslv2_tagctl_reqbuf_dcu_tc1),
    .cpuslv_tagctl_addr2_tc1_o             (cpuslv2_tagctl_addr2_tc1[40:0]),
    .cpuslv_tagctl_len_tc1_o               (cpuslv2_tagctl_len_tc1[1:0]),
    .cpuslv_tagctl_size_tc1_o              (cpuslv2_tagctl_size_tc1[2:0]),
    .cpuslv_tagctl_lock_tc1_o              (cpuslv2_tagctl_lock_tc1),
    .cpuslv_tagctl_dirty_tc1_o             (cpuslv2_tagctl_dirty_tc1),
    .cpuslv_tagctl_cluster_unique_tc1_o    (cpuslv2_tagctl_cluster_unique_tc1),
    .cpuslv_tagctl_attrs_tc1_o             (cpuslv2_tagctl_attrs_tc1[7:0]),
    .cpuslv_tagctl_prot_tc1_o              (cpuslv2_tagctl_prot_tc1[1:0]),
    .cpuslv_tagctl_l2db_tc1_o              (cpuslv2_tagctl_l2db_tc1[3:0]),
    .cpuslv_tagctl_l2db_full_tc1_o         (cpuslv2_tagctl_l2db_full_tc1),
    .cpuslv_tagctl_static_pcredit_tc1_o    (cpuslv2_tagctl_static_pcredit_tc1),
    .cpuslv_tagctl_pcrdtype_tc1_o          (cpuslv2_tagctl_pcrdtype_tc1[1:0]),
    .cpuslv_tagctl_victim_way_tc1_o        (cpuslv2_tagctl_victim_way_tc1[3:0]),
    .cpuslv_inv_all_starting_o             (cpuslv2_inv_all_starting),
    .cpuslv_hz_tc2_o                       (cpuslv2_hz_tc2),
    .cpuslv_snp_hz_tc2_o                   (cpuslv2_snp_hz_tc2),
    .cpuslv_snp_hz_id_tc2_o                (cpuslv2_snp_hz_id_tc2[2:0]),
    .cpuslv_snp_l2db_hz_tc2_o              (cpuslv2_snp_l2db_hz_tc2),
    .cpuslv_snp_l2db_dirty_tc2_o           (cpuslv2_snp_l2db_dirty_tc2),
    .cpuslv_snp_l2db_tc2_o                 (cpuslv2_snp_l2db_tc2[3:0]),
    .cpuslv_ecc_hz_tc2_o                   (cpuslv2_ecc_hz_tc2),
    .cpuslv_force_miss_tc2_o               (cpuslv2_force_miss_tc2[31:0]),
    .cpuslv_l2_way_used_tc2_o              (cpuslv2_l2_way_used_tc2[15:0]),
    .cpuslv_hz_tc4_o                       (cpuslv2_hz_tc4),
    .scu_drain_stb_o                       (scu_cpu2_drain_stb_o),
    .cpuslv_noncoh_since_barrier_o         (cpuslv2_noncoh_since_barrier),
    .cpuslv_dvm_sync_resp_o                (cpuslv2_dvm_sync_resp),
    .cpuslv_ac_ready_o                     (cpuslv2_ac_ready),
    .cpuslv_cr_valid_o                     (cpuslv2_cr_valid),
    .cpuslv_cr_id_o                        (cpuslv2_cr_id[2:0]),
    .cpuslv_cr_dirty_o                     (cpuslv2_cr_dirty),
    .cpuslv_cr_age_o                       (cpuslv2_cr_age),
    .cpuslv_cr_alloc_o                     (cpuslv2_cr_alloc),
    .cpuslv_cr_migratory_o                 (cpuslv2_cr_migratory),
    .cpuslv_compack_active_o               (cpuslv2_compack_active),
    .cpuslv_compack_valid_o                (cpuslv2_compack_valid),
    .cpuslv_compack_tgtid_o                (cpuslv2_compack_tgtid[6:0]),
    .cpuslv_compack_txnid_o                (cpuslv2_compack_txnid[7:0]),
    .cpuslv_victimctl_active_o             (cpuslv2_victimctl_active),
    .cpuslv_victimctl_valid_o              (cpuslv2_victimctl_valid),
    .cpuslv_victimctl_index_o              (cpuslv2_victimctl_index[10:0]),
    .cpuslv_victimctl_wr_o                 (cpuslv2_victimctl_wr),
    .cpuslv_victimctl_age_o                (cpuslv2_victimctl_age),
    .cpuslv_victimctl_iside_o              (cpuslv2_victimctl_iside),
    .cpuslv_victimctl_nontemp_o            (cpuslv2_victimctl_nontemp),
    .cpuslv_victimctl_way_o                (cpuslv2_victimctl_way[3:0]),
    .cpuslv_victimctl_id_o                 (cpuslv2_victimctl_id[2:0]),
    .cpuslv_l2_way_used_vc2_o              (cpuslv2_l2_way_used_vc2[15:0]),
    .cpuslv_l2dbs_active_o                 (cpuslv2_l2dbs_active),
    .cpuslv_ramctl_active_o                (cpuslv2_ramctl_active),
    .cpuslv_l2db0_transfer_o               (cpuslv2_l2db0_transfer),
    .cpuslv_l2db0_transfer_type_o          (cpuslv2_l2db0_transfer_type[2:0]),
    .cpuslv_l2db0_transfer_info_o          (cpuslv2_l2db0_transfer_info[23:0]),
    .cpuslv_l2db0_release_o                (cpuslv2_l2db0_release),
    .cpuslv_l2db1_transfer_o               (cpuslv2_l2db1_transfer),
    .cpuslv_l2db1_transfer_type_o          (cpuslv2_l2db1_transfer_type[2:0]),
    .cpuslv_l2db1_transfer_info_o          (cpuslv2_l2db1_transfer_info[23:0]),
    .cpuslv_l2db1_release_o                (cpuslv2_l2db1_release),
    .cpuslv_l2db2_transfer_o               (cpuslv2_l2db2_transfer),
    .cpuslv_l2db2_transfer_type_o          (cpuslv2_l2db2_transfer_type[2:0]),
    .cpuslv_l2db2_transfer_info_o          (cpuslv2_l2db2_transfer_info[23:0]),
    .cpuslv_l2db2_release_o                (cpuslv2_l2db2_release),
    .cpuslv_l2db3_transfer_o               (cpuslv2_l2db3_transfer),
    .cpuslv_l2db3_transfer_type_o          (cpuslv2_l2db3_transfer_type[2:0]),
    .cpuslv_l2db3_transfer_info_o          (cpuslv2_l2db3_transfer_info[23:0]),
    .cpuslv_l2db3_release_o                (cpuslv2_l2db3_release),
    .cpuslv_l2db4_transfer_o               (cpuslv2_l2db4_transfer),
    .cpuslv_l2db4_transfer_type_o          (cpuslv2_l2db4_transfer_type[2:0]),
    .cpuslv_l2db4_transfer_info_o          (cpuslv2_l2db4_transfer_info[23:0]),
    .cpuslv_l2db4_release_o                (cpuslv2_l2db4_release),
    .cpuslv_l2db5_transfer_o               (cpuslv2_l2db5_transfer),
    .cpuslv_l2db5_transfer_type_o          (cpuslv2_l2db5_transfer_type[2:0]),
    .cpuslv_l2db5_transfer_info_o          (cpuslv2_l2db5_transfer_info[23:0]),
    .cpuslv_l2db5_release_o                (cpuslv2_l2db5_release),
    .cpuslv_l2db6_transfer_o               (cpuslv2_l2db6_transfer),
    .cpuslv_l2db6_transfer_type_o          (cpuslv2_l2db6_transfer_type[2:0]),
    .cpuslv_l2db6_transfer_info_o          (cpuslv2_l2db6_transfer_info[23:0]),
    .cpuslv_l2db6_release_o                (cpuslv2_l2db6_release),
    .cpuslv_l2db7_transfer_o               (cpuslv2_l2db7_transfer),
    .cpuslv_l2db7_transfer_type_o          (cpuslv2_l2db7_transfer_type[2:0]),
    .cpuslv_l2db7_transfer_info_o          (cpuslv2_l2db7_transfer_info[23:0]),
    .cpuslv_l2db7_release_o                (cpuslv2_l2db7_release),
    .cpuslv_l2db8_transfer_o               (cpuslv2_l2db8_transfer),
    .cpuslv_l2db8_transfer_type_o          (cpuslv2_l2db8_transfer_type[2:0]),
    .cpuslv_l2db8_transfer_info_o          (cpuslv2_l2db8_transfer_info[23:0]),
    .cpuslv_l2db8_release_o                (cpuslv2_l2db8_release),
    .cpuslv_l2db9_transfer_o               (cpuslv2_l2db9_transfer),
    .cpuslv_l2db9_transfer_type_o          (cpuslv2_l2db9_transfer_type[2:0]),
    .cpuslv_l2db9_transfer_info_o          (cpuslv2_l2db9_transfer_info[23:0]),
    .cpuslv_l2db9_release_o                (cpuslv2_l2db9_release),
    .cpuslv_l2db10_transfer_o              (cpuslv2_l2db10_transfer),
    .cpuslv_l2db10_transfer_type_o         (cpuslv2_l2db10_transfer_type[2:0]),
    .cpuslv_l2db10_transfer_info_o         (cpuslv2_l2db10_transfer_info[23:0]),
    .cpuslv_l2db10_release_o               (cpuslv2_l2db10_release),
    .cpuslv_early_dr_l2_o                  (cpuslv2_early_dr_l2),
    .cpuslv_early_dr_index_o               (cpuslv2_early_dr_index[10:0]),
    .cpuslv_early_dr_way_o                 (cpuslv2_early_dr_way[3:0]),
    .cpuslv_early_dr_ready_o               (cpuslv2_early_dr_ready[7:0]),
    .cpuslv_delay_allocation_o             (cpuslv2_delay_allocation[7:0]),
    .cpuslv_master_dr_ready_o              (cpuslv2_master_dr_ready),
    .cpuslv_master_sactive_o               (cpuslv2_master_sactive),
    .cpuslv_sample_waddrs_o                (cpuslv2_sample_waddrs),
    .cpuslv_sample_waddrs_dsb_o            (cpuslv2_sample_waddrs_dsb),
    .scu_reqbufs_busy_o                    (scu_cpu2_reqbufs_busy_o[7:0]),
    .cpuslv_l2db0_ready_o                  (cpuslv2_l2db0_ready),
    .cpuslv_l2db1_ready_o                  (cpuslv2_l2db1_ready),
    .cpuslv_l2db2_ready_o                  (cpuslv2_l2db2_ready),
    .cpuslv_l2db3_ready_o                  (cpuslv2_l2db3_ready),
    .cpuslv_l2db4_ready_o                  (cpuslv2_l2db4_ready),
    .cpuslv_l2db5_ready_o                  (cpuslv2_l2db5_ready),
    .cpuslv_l2db6_ready_o                  (cpuslv2_l2db6_ready),
    .cpuslv_l2db7_ready_o                  (cpuslv2_l2db7_ready),
    .cpuslv_l2db8_ready_o                  (cpuslv2_l2db8_ready),
    .cpuslv_l2db9_ready_o                  (cpuslv2_l2db9_ready),
    .cpuslv_l2db10_ready_o                 (cpuslv2_l2db10_ready),
    .cpuslv_l2dbs_dw_valid_o               (cpuslv2_l2dbs_dw_valid),
    .cpuslv_l2dbs_dw_id_o                  (cpuslv2_l2dbs_dw_id[3:0]),
    .cpuslv_l2dbs_dw_chunks_valid_o        (cpuslv2_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv_l2dbs_dw_last_o                (cpuslv2_l2dbs_dw_last),
    .cpuslv_l2dbs_dw_data_o                (cpuslv2_l2dbs_dw_data[255:0]),
    .cpuslv_l2dbs_dw_strb_o                (cpuslv2_l2dbs_dw_strb[31:0]),
    .cpuslv_l2dbs_dw_err_o                 (cpuslv2_l2dbs_dw_err),
    .cpuslv_l2dbs_dw_fatal_o               (cpuslv2_l2dbs_dw_fatal),
    .scu_evnt_eviction_o                   (scu_cpu2_evnt_eviction_o),
    .scu_evnt_snooped_data_o               (scu_cpu2_evnt_snooped_data_o),
    .scu_evnt_l2_access_o                  (scu_cpu2_evnt_l2_access_o)
  );  // u_scu_cpuslv2

  ca53scu_cpuslv #(`CA53_SCU_INT_PARAM_INST, .CPU_NUM(3)) u_scu_cpuslv3 (
    // TEMPLATE s/cpuslv/cpuslv3/
    // TEMPLATE s/biu_/biu_cpu3_/
    // TEMPLATE s/dcu_/dcu_cpu3_/
    // TEMPLATE s/gov_/gov_cpu3_/
    // TEMPLATE s/scu_/scu_cpu3_/
    /*ARMAUTO*/
    .gov_enable_writeevict_i               (gov_enable_writeevict_i),
    .gov_l2_in_retention_i                 (gov_l2_in_retention_i),
    .gov_standbywfi_i                      (gov_standbywfi_i[NUM_CPUS-1:0]),
    .gov_mbistreq_i                        (gov_mbistreq_i),
    // Inputs
    .CLKIN                                 (CLKIN),
    .clk                                   (clk),
    .reset_n                               (reset_n),
    .DFTSE                                 (DFTSE),
    .leaving_reset_i                       (leaving_reset),
    .config_broadcastinner_i               (config_broadcastinner),
    .config_broadcastouter_i               (config_broadcastouter),
    .config_broadcastcachemaint_i          (config_broadcastcachemaint),
    .config_sysbardisable_i                (config_sysbardisable),
    .config_l1_dc_size_i                   (config_l1_dc_size[2:0]),
    .config_l2_size_i                      (config_l2_size[3:0]),
    .gov_inv_all_req_i                     (gov_cpu3_inv_all_req_i),
    .biu_ar_active_i                       (biu_cpu3_ar_active_i),
    .biu_ar_valid_i                        (biu_cpu3_ar_valid_i),
    .biu_ar_id_i                           (biu_cpu3_ar_id_i[4:0]),
    .biu_ar_type_i                         (biu_cpu3_ar_type_i[4:0]),
    .biu_ar_attrs_i                        (biu_cpu3_ar_attrs_i[7:0]),
    .biu_ar_way_i                          (biu_cpu3_ar_way_i[4:0]),
    .biu_ar_addr_i                         (biu_cpu3_ar_addr_i[40:0]),
    .biu_ar_len_i                          (biu_cpu3_ar_len_i[1:0]),
    .biu_ar_size_i                         (biu_cpu3_ar_size_i[2:0]),
    .biu_ar_lock_i                         (biu_cpu3_ar_lock_i),
    .biu_ar_priv_i                         (biu_cpu3_ar_priv_i),
    .biu_dr_credit_i                       (biu_cpu3_dr_credit_i),
    .biu_dw_valid_i                        (biu_cpu3_dw_valid_i),
    .biu_dw_l2db_id_i                      (biu_cpu3_dw_l2db_id_i[3:0]),
    .biu_dw_chunks_valid_i                 (biu_cpu3_dw_chunks_valid_i[3:0]),
    .biu_dw_last_i                         (biu_cpu3_dw_last_i),
    .biu_dw_strb_i                         (biu_cpu3_dw_strb_i[31:0]),
    .biu_dw_data_i                         (biu_cpu3_dw_data_i[255:0]),
    .biu_dw_err_i                          (biu_cpu3_dw_err_i),
    .biu_dw_fatal_i                        (biu_cpu3_dw_fatal_i),
    .l2flushreq_rs_i                       (l2flushreq_rs),
    .acp_ainact_rs_i                       (acp_ainact_rs),
    .master_writes_active_i                (master_writes_active),
    .dcu_ac_ready_i                        (dcu_cpu3_ac_ready_i),
    .dcu_cr_valid_i                        (dcu_cpu3_cr_valid_i),
    .dcu_cr_id_i                           (dcu_cpu3_cr_id_i[2:0]),
    .dcu_cr_dirty_i                        (dcu_cpu3_cr_dirty_i),
    .dcu_cr_age_i                          (dcu_cpu3_cr_age_i),
    .dcu_cr_alloc_i                        (dcu_cpu3_cr_alloc_i),
    .dcu_cr_migratory_i                    (dcu_cpu3_cr_migratory_i),
    .tagctl_cpuslv_ready_tc0_i             (tagctl_cpuslv3_ready_tc0),
    .tagctl_cpuslv_noncoh_only_i           (tagctl_cpuslv3_noncoh_only),
    .tagctl_slv_flush_tc1_i                (tagctl_slv_flush_tc1),
    .tagctl_slv_flush_tc2_i                (tagctl_slv_flush_tc2),
    .tagctl_slv_flush_tc3_i                (tagctl_slv_flush_tc3),
    .tagctl_slv_flush_tc4_i                (tagctl_slv_flush_tc4),
    .tagctl_slv_early_flush_tc4_i          (tagctl_slv_early_flush_tc4),
    .tagctl_ecc_err_tc3_i                  (tagctl_ecc_err_tc3),
    .tagctl_slv_l2db_tc1_i                 (tagctl_slv_l2db_tc1[3:0]),
    .tagctl_slv_l2db_tc4_i                 (tagctl_slv_l2db_tc4[3:0]),
    .tagctl_slv_snp_hz_tc4_i               (tagctl_slv_snp_hz_tc4),
    .tagctl_slv_snp_hz_id_tc4_i            (tagctl_slv_snp_hz_id_tc4[4:0]),
    .tagctl_slv_l2db_invalidated_tc4_i     (tagctl_slv_l2db_invalidated_tc4),
    .tagctl_slv_l2db_cleaned_tc4_i         (tagctl_slv_l2db_cleaned_tc4),
    .tagctl_slv_victim_l2db_tc4_i          (tagctl_slv_victim_l2db_tc4[3:0]),
    .afb0_done_i                           (afb0_done),
    .afb1_done_i                           (afb1_done),
    .afb2_done_i                           (afb2_done),
    .afb3_done_i                           (afb3_done),
    .afb4_done_i                           (afb4_done),
    .afb5_done_i                           (afb5_done),
    .afb0_snoop_resp_valid_i               (afb0_snoop_resp_valid),
    .afb1_snoop_resp_valid_i               (afb1_snoop_resp_valid),
    .afb2_snoop_resp_valid_i               (afb2_snoop_resp_valid),
    .afb3_snoop_resp_valid_i               (afb3_snoop_resp_valid),
    .afb4_snoop_resp_valid_i               (afb4_snoop_resp_valid),
    .afb5_snoop_resp_valid_i               (afb5_snoop_resp_valid),
    .afb0_snoop_resp_dirty_i               (afb0_snoop_resp_dirty),
    .afb1_snoop_resp_dirty_i               (afb1_snoop_resp_dirty),
    .afb2_snoop_resp_dirty_i               (afb2_snoop_resp_dirty),
    .afb3_snoop_resp_dirty_i               (afb3_snoop_resp_dirty),
    .afb4_snoop_resp_dirty_i               (afb4_snoop_resp_dirty),
    .afb5_snoop_resp_dirty_i               (afb5_snoop_resp_dirty),
    .afb0_snoop_resp_victim_valid_i        (afb0_snoop_resp_victim_valid),
    .afb1_snoop_resp_victim_valid_i        (afb1_snoop_resp_victim_valid),
    .afb2_snoop_resp_victim_valid_i        (afb2_snoop_resp_victim_valid),
    .afb3_snoop_resp_victim_valid_i        (afb3_snoop_resp_victim_valid),
    .afb4_snoop_resp_victim_valid_i        (afb4_snoop_resp_victim_valid),
    .afb5_snoop_resp_victim_valid_i        (afb5_snoop_resp_victim_valid),
    .afb0_snoop_resp_victim_dirty_i        (afb0_snoop_resp_victim_dirty),
    .afb1_snoop_resp_victim_dirty_i        (afb1_snoop_resp_victim_dirty),
    .afb2_snoop_resp_victim_dirty_i        (afb2_snoop_resp_victim_dirty),
    .afb3_snoop_resp_victim_dirty_i        (afb3_snoop_resp_victim_dirty),
    .afb4_snoop_resp_victim_dirty_i        (afb4_snoop_resp_victim_dirty),
    .afb5_snoop_resp_victim_dirty_i        (afb5_snoop_resp_victim_dirty),
    .afb0_snoop_resp_victim_age_i          (afb0_snoop_resp_victim_age),
    .afb1_snoop_resp_victim_age_i          (afb1_snoop_resp_victim_age),
    .afb2_snoop_resp_victim_age_i          (afb2_snoop_resp_victim_age),
    .afb3_snoop_resp_victim_age_i          (afb3_snoop_resp_victim_age),
    .afb4_snoop_resp_victim_age_i          (afb4_snoop_resp_victim_age),
    .afb5_snoop_resp_victim_age_i          (afb5_snoop_resp_victim_age),
    .afb0_snoop_resp_victim_alloc_i        (afb0_snoop_resp_victim_alloc),
    .afb1_snoop_resp_victim_alloc_i        (afb1_snoop_resp_victim_alloc),
    .afb2_snoop_resp_victim_alloc_i        (afb2_snoop_resp_victim_alloc),
    .afb3_snoop_resp_victim_alloc_i        (afb3_snoop_resp_victim_alloc),
    .afb4_snoop_resp_victim_alloc_i        (afb4_snoop_resp_victim_alloc),
    .afb5_snoop_resp_victim_alloc_i        (afb5_snoop_resp_victim_alloc),
    .afb0_snoop_resp_alloc_i               (afb0_snoop_resp_alloc),
    .afb1_snoop_resp_alloc_i               (afb1_snoop_resp_alloc),
    .afb2_snoop_resp_alloc_i               (afb2_snoop_resp_alloc),
    .afb3_snoop_resp_alloc_i               (afb3_snoop_resp_alloc),
    .afb4_snoop_resp_alloc_i               (afb4_snoop_resp_alloc),
    .afb5_snoop_resp_alloc_i               (afb5_snoop_resp_alloc),
    .afb0_snoop_resp_migratory_i           (afb0_snoop_resp_migratory),
    .afb1_snoop_resp_migratory_i           (afb1_snoop_resp_migratory),
    .afb2_snoop_resp_migratory_i           (afb2_snoop_resp_migratory),
    .afb3_snoop_resp_migratory_i           (afb3_snoop_resp_migratory),
    .afb4_snoop_resp_migratory_i           (afb4_snoop_resp_migratory),
    .afb5_snoop_resp_migratory_i           (afb5_snoop_resp_migratory),
    .afb0_write_done_i                     (afb0_write_done),
    .afb1_write_done_i                     (afb1_write_done),
    .afb2_write_done_i                     (afb2_write_done),
    .afb3_write_done_i                     (afb3_write_done),
    .afb4_write_done_i                     (afb4_write_done),
    .afb5_write_done_i                     (afb5_write_done),
    .tagctl_slv_afb_tc1_i                  (tagctl_slv_afb_tc1[2:0]),
    .tagctl_addr_tc1_i                     (tagctl_addr_tc1[41:6]),
    .tagctl_valid_tc1_i                    (tagctl_valid_tc1),
    .tagctl_addr_valid_tc1_i               (tagctl_addr_valid_tc1),
    .tagctl_index_valid_tc1_i              (tagctl_index_valid_tc1),
    .tagctl_l1_set_way_op_tc1_i            (tagctl_l1_set_way_op_tc1),
    .tagctl_l1_lf_tc1_i                    (tagctl_l1_lf_tc1),
    .tagctl_serialising_tc1_i              (tagctl_serialising_tc1),
    .tagctl_ecc_wr_tc1_i                   (tagctl_ecc_wr_tc1),
    .tagctl_ecc_way_tc1_i                  (tagctl_ecc_way_tc1[15:0]),
    .tagctl_reqbufid_tc1_i                 (tagctl_reqbufid_tc1[5:0]),
    .tagctl_cpu_sync_tc1_i                 (tagctl_cpu_sync_tc1),
    .tagctl_snp_sync_tc1_i                 (tagctl_snp_sync_tc1),
    .tagctl_addr_tc3_i                     (tagctl_addr_tc3[40:6]),
    .tagctl_addr_valid_tc3_i               (tagctl_addr_valid_tc3),
    .tagctl_reqbufid_tc3_i                 (tagctl_reqbufid_tc3[5:0]),
    .tagctl_noncoh_serialised_tc3_i        (tagctl_noncoh_serialised_tc3),
    .tagctl_l1_hit_ways_tc3_i              (tagctl_l1_hit_ways_tc3[15:0]),
    .tagctl_l2_hit_ways_tc3_i              (tagctl_l2_hit_ways_tc3[15:0]),
    .tagctl_l2_dirty_tc3_i                 (tagctl_l2_dirty_tc3),
    .tagctl_l2_alloc_tc3_i                 (tagctl_l2_alloc_tc3),
    .tagctl_shareability_tc3_i             (tagctl_shareability_tc3[1:0]),
    .tagctl_cluster_unique_tc3_i           (tagctl_cluster_unique_tc3),
    .tagctl_l1_victim_cluster_unique_tc3_i (tagctl_l1_victim_cluster_unique_tc3),
    .tagctl_l1_victim_shareability_tc3_i   (tagctl_l1_victim_shareability_tc3[1:0]),
    .tagctl_l2_victim_valid_tc3_i          (tagctl_l2_victim_valid_tc3),
    .tagctl_l2_victim_shareability_tc3_i   (tagctl_l2_victim_shareability_tc3[1:0]),
    .tagctl_l2_victim_alloc_tc3_i          (tagctl_l2_victim_alloc_tc3),
    .tagctl_l2_victim_cu_tc3_i             (tagctl_l2_victim_cu_tc3),
    .tagctl_l2_victim_way_tc3_i            (tagctl_l2_victim_way_tc3[3:0]),
    .tagctl_snoop_data_cpu_tc4_i           (tagctl_snoop_data_cpu_tc4[1:0]),
    .dvm_comp_sync_outstanding_i           (dvm_comp_sync_outstanding),
    .tagctl_cpuslv_ac_valid_i              (tagctl_cpuslv3_ac_valid),
    .tagctl_cpuslv_ac_snoop_i              (tagctl_cpuslv3_ac_snoop[3:0]),
    .tagctl_cpuslv_ac_id_i                 (tagctl_cpuslv3_ac_id[2:0]),
    .tagctl_cpuslv_ac_l2db_id_i            (tagctl_cpuslv3_ac_l2db_id[3:0]),
    .tagctl_cpuslv_ac_addr_i               (tagctl_cpuslv3_ac_addr[40:0]),
    .tagctl_cpuslv_ac_way_i                (tagctl_cpuslv3_ac_way[3:0]),
    .tagctl_cpuslv_snp_active_i            (tagctl_cpuslv3_snp_active),
    .snpslv_cpuslv_compack_ready_i         (snpslv_cpuslv3_compack_ready),
    .victimctl_ready_i                     (victimctl_ready),
    .victimctl_ready_id_i                  (victimctl_ready_id[5:0]),
    .victimctl_ack_i                       (victimctl_ack),
    .victimctl_ack_id_i                    (victimctl_ack_id[5:0]),
    .victimctl_victim_way_i                (victimctl_victim_way[3:0]),
    .victimctl_index_vc1_i                 (victimctl_index_vc1[10:0]),
    .l2db0_slv_done_i                      (l2db0_slv_done),
    .l2db1_slv_done_i                      (l2db1_slv_done),
    .l2db2_slv_done_i                      (l2db2_slv_done),
    .l2db3_slv_done_i                      (l2db3_slv_done),
    .l2db4_slv_done_i                      (l2db4_slv_done),
    .l2db5_slv_done_i                      (l2db5_slv_done),
    .l2db6_slv_done_i                      (l2db6_slv_done),
    .l2db7_slv_done_i                      (l2db7_slv_done),
    .l2db8_slv_done_i                      (l2db8_slv_done),
    .l2db9_slv_done_i                      (l2db9_slv_done),
    .l2db10_slv_done_i                     (l2db10_slv_done),
    .l2db0_full_line_i                     (l2db0_full_line),
    .l2db1_full_line_i                     (l2db1_full_line),
    .l2db2_full_line_i                     (l2db2_full_line),
    .l2db3_full_line_i                     (l2db3_full_line),
    .l2db4_full_line_i                     (l2db4_full_line),
    .l2db5_full_line_i                     (l2db5_full_line),
    .l2db6_full_line_i                     (l2db6_full_line),
    .l2db7_full_line_i                     (l2db7_full_line),
    .l2db8_full_line_i                     (l2db8_full_line),
    .l2db9_full_line_i                     (l2db9_full_line),
    .l2db10_full_line_i                    (l2db10_full_line),
    .l2db0_rmw_line_i                      (l2db0_rmw_line),
    .l2db1_rmw_line_i                      (l2db1_rmw_line),
    .l2db2_rmw_line_i                      (l2db2_rmw_line),
    .l2db3_rmw_line_i                      (l2db3_rmw_line),
    .l2db4_rmw_line_i                      (l2db4_rmw_line),
    .l2db5_rmw_line_i                      (l2db5_rmw_line),
    .l2db6_rmw_line_i                      (l2db6_rmw_line),
    .l2db7_rmw_line_i                      (l2db7_rmw_line),
    .l2db8_rmw_line_i                      (l2db8_rmw_line),
    .l2db9_rmw_line_i                      (l2db9_rmw_line),
    .l2db10_rmw_line_i                     (l2db10_rmw_line),
    .l2db0_cpuslv_data_active_i            (l2db0_cpuslv3_data_active),
    .l2db1_cpuslv_data_active_i            (l2db1_cpuslv3_data_active),
    .l2db2_cpuslv_data_active_i            (l2db2_cpuslv3_data_active),
    .l2db3_cpuslv_data_active_i            (l2db3_cpuslv3_data_active),
    .l2db4_cpuslv_data_active_i            (l2db4_cpuslv3_data_active),
    .l2db5_cpuslv_data_active_i            (l2db5_cpuslv3_data_active),
    .l2db6_cpuslv_data_active_i            (l2db6_cpuslv3_data_active),
    .l2db7_cpuslv_data_active_i            (l2db7_cpuslv3_data_active),
    .l2db8_cpuslv_data_active_i            (l2db8_cpuslv3_data_active),
    .l2db9_cpuslv_data_active_i            (l2db9_cpuslv3_data_active),
    .l2db10_cpuslv_data_active_i           (l2db10_cpuslv3_data_active),
    .master_early_dr_valid_i               (master_early_dr_valid),
    .master_early_dr_id_i                  (master_early_dr_id[5:0]),
    .master_early_dr_dbid_i                (master_early_dr_dbid[7:0]),
    .master_early_dr_srcid_i               (master_early_dr_srcid[6:0]),
    .master_early_dr_barrier_i             (master_early_dr_barrier),
    .master_early_dr_resp_i                (master_early_dr_resp[3:0]),
    .master_early_dr_same_i                (master_early_dr_same),
    .master_cpuslv_dr_valid_i              (master_cpuslv3_dr_valid),
    .master_cpuslv_dr_id_i                 (master_cpuslv3_dr_id[5:0]),
    .master_dr_chunk_i                     (master_dr_chunk[1:0]),
    .master_dr_data_i                      (master_dr_data[127:0]),
    .master_dr_resp_i                      (master_dr_resp[3:0]),
    .master_afb0_ack_i                     (master_afb0_ack),
    .master_afb1_ack_i                     (master_afb1_ack),
    .master_afb2_ack_i                     (master_afb2_ack),
    .master_afb3_ack_i                     (master_afb3_ack),
    .master_afb4_ack_i                     (master_afb4_ack),
    .master_afb5_ack_i                     (master_afb5_ack),
    .master_afb_waddr_id_i                 (master_afb_waddr_id[3:0]),
    .master_cpuslv_waddrs_valid_i          (master_cpuslv3_waddrs_valid),
    .master_cpuslv_barrier_db_valid_i      (master_cpuslv3_barrier_db_valid),
    .master_cpuslv_strex_db_valid_i        (master_cpuslv3_strex_db_valid),
    .master_cpuslv_dev_db_valid_i          (master_cpuslv3_dev_db_valid),
    .master_db_resp_i                      (master_db_resp[1:0]),
    .master_db_waddr_valid_i               (master_db_waddr_valid),
    .master_db_waddr_i                     (master_db_waddr[3:0]),
    .master_cpuslv_l2_waiting_i            (master_cpuslv3_l2_waiting[7:0]),
    .master_rsp_readreceipt_valid_i        (master_rsp_readreceipt_valid),
    .master_rsp_comp_valid_i               (master_rsp_comp_valid),
    .master_rsp_dbid_valid_i               (master_rsp_dbid_valid),
    .master_rsp_txnid_i                    (master_rsp_txnid[6:0]),
    .master_rsp_dbid_i                     (master_rsp_dbid[7:0]),
    .master_rsp_srcid_i                    (master_rsp_srcid[6:0]),
    .master_rsp_resp_i                     (master_rsp_resp[3:0]),
    .master_cpuslv_reqbuf_retry_i          (master_cpuslv3_reqbuf_retry[7:0]),
    .master_cpuslv_pcrdtype_i              (master_cpuslv3_pcrdtype[1:0]),
    .l2db0_slv_valid_i                     (l2db0_slv_valid),
    .l2db0_slv_id_i                        (l2db0_slv_id[5:0]),
    .l2db0_slv_biuid_i                     (l2db0_slv_biuid[4:0]),
    .l2db0_slv_data_i                      (l2db0_slv_data[127:0]),
    .l2db0_slv_chunk_i                     (l2db0_slv_chunk[1:0]),
    .l2db0_slv_bypass_i                    (l2db0_slv_bypass),
    .l2db0_slv_err_i                       (l2db0_slv_err),
    .l2db1_slv_valid_i                     (l2db1_slv_valid),
    .l2db1_slv_id_i                        (l2db1_slv_id[5:0]),
    .l2db1_slv_biuid_i                     (l2db1_slv_biuid[4:0]),
    .l2db1_slv_data_i                      (l2db1_slv_data[127:0]),
    .l2db1_slv_chunk_i                     (l2db1_slv_chunk[1:0]),
    .l2db1_slv_bypass_i                    (l2db1_slv_bypass),
    .l2db1_slv_err_i                       (l2db1_slv_err),
    .l2db2_slv_valid_i                     (l2db2_slv_valid),
    .l2db2_slv_id_i                        (l2db2_slv_id[5:0]),
    .l2db2_slv_biuid_i                     (l2db2_slv_biuid[4:0]),
    .l2db2_slv_data_i                      (l2db2_slv_data[127:0]),
    .l2db2_slv_chunk_i                     (l2db2_slv_chunk[1:0]),
    .l2db2_slv_bypass_i                    (l2db2_slv_bypass),
    .l2db2_slv_err_i                       (l2db2_slv_err),
    .l2db3_slv_valid_i                     (l2db3_slv_valid),
    .l2db3_slv_id_i                        (l2db3_slv_id[5:0]),
    .l2db3_slv_biuid_i                     (l2db3_slv_biuid[4:0]),
    .l2db3_slv_data_i                      (l2db3_slv_data[127:0]),
    .l2db3_slv_chunk_i                     (l2db3_slv_chunk[1:0]),
    .l2db3_slv_bypass_i                    (l2db3_slv_bypass),
    .l2db3_slv_err_i                       (l2db3_slv_err),
    .l2db4_slv_valid_i                     (l2db4_slv_valid),
    .l2db4_slv_id_i                        (l2db4_slv_id[5:0]),
    .l2db4_slv_biuid_i                     (l2db4_slv_biuid[4:0]),
    .l2db4_slv_data_i                      (l2db4_slv_data[127:0]),
    .l2db4_slv_chunk_i                     (l2db4_slv_chunk[1:0]),
    .l2db4_slv_bypass_i                    (l2db4_slv_bypass),
    .l2db4_slv_err_i                       (l2db4_slv_err),
    .l2db5_slv_valid_i                     (l2db5_slv_valid),
    .l2db5_slv_id_i                        (l2db5_slv_id[5:0]),
    .l2db5_slv_biuid_i                     (l2db5_slv_biuid[4:0]),
    .l2db5_slv_data_i                      (l2db5_slv_data[127:0]),
    .l2db5_slv_chunk_i                     (l2db5_slv_chunk[1:0]),
    .l2db5_slv_bypass_i                    (l2db5_slv_bypass),
    .l2db5_slv_err_i                       (l2db5_slv_err),
    .l2db6_slv_valid_i                     (l2db6_slv_valid),
    .l2db6_slv_id_i                        (l2db6_slv_id[5:0]),
    .l2db6_slv_biuid_i                     (l2db6_slv_biuid[4:0]),
    .l2db6_slv_data_i                      (l2db6_slv_data[127:0]),
    .l2db6_slv_chunk_i                     (l2db6_slv_chunk[1:0]),
    .l2db6_slv_bypass_i                    (l2db6_slv_bypass),
    .l2db6_slv_err_i                       (l2db6_slv_err),
    .l2db7_slv_valid_i                     (l2db7_slv_valid),
    .l2db7_slv_id_i                        (l2db7_slv_id[5:0]),
    .l2db7_slv_biuid_i                     (l2db7_slv_biuid[4:0]),
    .l2db7_slv_data_i                      (l2db7_slv_data[127:0]),
    .l2db7_slv_chunk_i                     (l2db7_slv_chunk[1:0]),
    .l2db7_slv_bypass_i                    (l2db7_slv_bypass),
    .l2db7_slv_err_i                       (l2db7_slv_err),
    .l2db8_slv_valid_i                     (l2db8_slv_valid),
    .l2db8_slv_id_i                        (l2db8_slv_id[5:0]),
    .l2db8_slv_biuid_i                     (l2db8_slv_biuid[4:0]),
    .l2db8_slv_data_i                      (l2db8_slv_data[127:0]),
    .l2db8_slv_chunk_i                     (l2db8_slv_chunk[1:0]),
    .l2db8_slv_bypass_i                    (l2db8_slv_bypass),
    .l2db8_slv_err_i                       (l2db8_slv_err),
    .l2db9_slv_valid_i                     (l2db9_slv_valid),
    .l2db9_slv_id_i                        (l2db9_slv_id[5:0]),
    .l2db9_slv_biuid_i                     (l2db9_slv_biuid[4:0]),
    .l2db9_slv_data_i                      (l2db9_slv_data[127:0]),
    .l2db9_slv_chunk_i                     (l2db9_slv_chunk[1:0]),
    .l2db9_slv_bypass_i                    (l2db9_slv_bypass),
    .l2db9_slv_err_i                       (l2db9_slv_err),
    .l2db10_slv_valid_i                    (l2db10_slv_valid),
    .l2db10_slv_id_i                       (l2db10_slv_id[5:0]),
    .l2db10_slv_biuid_i                    (l2db10_slv_biuid[4:0]),
    .l2db10_slv_data_i                     (l2db10_slv_data[127:0]),
    .l2db10_slv_chunk_i                    (l2db10_slv_chunk[1:0]),
    .l2db10_slv_bypass_i                   (l2db10_slv_bypass),
    .l2db10_slv_err_i                      (l2db10_slv_err),
    .ramctl_bypass_data_i                  (ramctl_bypass_data[127:0]),
    .ramctl_bypass_err_i                   (ramctl_bypass_err),
    // Outputs
    .cpuslv_active_o                       (cpuslv3_active),
    .cpuslv_wfx_active_o                   (cpuslv3_wfx_active),
    .scu_inv_all_ack_o                     (scu_cpu3_inv_all_ack_o),
    .scu_ar_credit_o                       (scu_cpu3_ar_credit_o),
    .scu_ar_block_o                        (scu_cpu3_ar_block_o),
    .scu_dr_valid_o                        (scu_cpu3_dr_valid_o),
    .scu_dr_id_o                           (scu_cpu3_dr_id_o[4:0]),
    .scu_dr_resp_o                         (scu_cpu3_dr_resp_o[5:0]),
    .scu_dr_chunk_o                        (scu_cpu3_dr_chunk_o[1:0]),
    .scu_dr_data_o                         (scu_cpu3_dr_data_o[127:0]),
    .scu_rr_valid_o                        (scu_cpu3_rr_valid_o),
    .scu_rr_id_o                           (scu_cpu3_rr_id_o[4:0]),
    .scu_rr_resp_o                         (scu_cpu3_rr_resp_o[1:0]),
    .scu_rr_l2db_id_o                      (scu_cpu3_rr_l2db_id_o[3:0]),
    .scu_ev_done_o                         (scu_cpu3_ev_done_o[7:0]),
    .scu_db_excl_valid_o                   (scu_cpu3_db_excl_valid_o),
    .scu_db_excl_resp_o                    (scu_cpu3_db_excl_resp_o[1:0]),
    .scu_db_decerr_o                       (scu_cpu3_db_decerr_o),
    .scu_db_slverr_o                       (scu_cpu3_db_slverr_o),
    .scu_leave_ramode_o                    (scu_cpu3_leave_ramode_o),
    .cpuslv_l2flushdone_o                  (cpuslv3_l2flushdone),
    .cpuslv_l2flush_active_o               (cpuslv3_l2flush_active),
    .scu_ac_valid_o                        (scu_cpu3_ac_valid_o),
    .scu_ac_snoop_o                        (scu_cpu3_ac_snoop_o[3:0]),
    .scu_ac_id_o                           (scu_cpu3_ac_id_o[2:0]),
    .scu_ac_l2db_id_o                      (scu_cpu3_ac_l2db_id_o[3:0]),
    .scu_ac_addr_o                         (scu_cpu3_ac_addr_o[40:0]),
    .scu_ac_way_o                          (scu_cpu3_ac_way_o[3:0]),
    .cpuslv_tagctl_valid_tc0_o             (cpuslv3_tagctl_valid_tc0),
    .cpuslv_tagctl_early_valid_tc0_o       (cpuslv3_tagctl_early_valid_tc0),
    .cpuslv_tagctl_spec_valid_tc0_o        (cpuslv3_tagctl_spec_valid_tc0),
    .cpuslv_tagctl_reqbufid_tc0_o          (cpuslv3_tagctl_reqbufid_tc0[2:0]),
    .cpuslv_tagctl_pass_tc0_o              (cpuslv3_tagctl_pass_tc0[3:0]),
    .cpuslv_tagctl_addr1_tc0_o             (cpuslv3_tagctl_addr1_tc0[40:0]),
    .cpuslv_tagctl_dvm_sync_tc0_o          (cpuslv3_tagctl_dvm_sync_tc0),
    .cpuslv_tagctl_wr_state_tc0_o          (cpuslv3_tagctl_wr_state_tc0[16:0]),
    .cpuslv_tagctl_ecc_tc0_o               (cpuslv3_tagctl_ecc_tc0[34:0]),
    .cpuslv_tagctl_ways_tc0_o              (cpuslv3_tagctl_ways_tc0[31:0]),
    .cpuslv_tagctl_write_tc0_o             (cpuslv3_tagctl_write_tc0[4:0]),
    .cpuslv_tagctl_type_tc0_o              (cpuslv3_tagctl_type_tc0[4:0]),
    .cpuslv_tagctl_l2flushreq_tc0_o        (cpuslv3_tagctl_l2flushreq_tc0),
    .cpuslv_tagctl_reqbuf_dcu_tc1_o        (cpuslv3_tagctl_reqbuf_dcu_tc1),
    .cpuslv_tagctl_addr2_tc1_o             (cpuslv3_tagctl_addr2_tc1[40:0]),
    .cpuslv_tagctl_len_tc1_o               (cpuslv3_tagctl_len_tc1[1:0]),
    .cpuslv_tagctl_size_tc1_o              (cpuslv3_tagctl_size_tc1[2:0]),
    .cpuslv_tagctl_lock_tc1_o              (cpuslv3_tagctl_lock_tc1),
    .cpuslv_tagctl_dirty_tc1_o             (cpuslv3_tagctl_dirty_tc1),
    .cpuslv_tagctl_cluster_unique_tc1_o    (cpuslv3_tagctl_cluster_unique_tc1),
    .cpuslv_tagctl_attrs_tc1_o             (cpuslv3_tagctl_attrs_tc1[7:0]),
    .cpuslv_tagctl_prot_tc1_o              (cpuslv3_tagctl_prot_tc1[1:0]),
    .cpuslv_tagctl_l2db_tc1_o              (cpuslv3_tagctl_l2db_tc1[3:0]),
    .cpuslv_tagctl_l2db_full_tc1_o         (cpuslv3_tagctl_l2db_full_tc1),
    .cpuslv_tagctl_static_pcredit_tc1_o    (cpuslv3_tagctl_static_pcredit_tc1),
    .cpuslv_tagctl_pcrdtype_tc1_o          (cpuslv3_tagctl_pcrdtype_tc1[1:0]),
    .cpuslv_tagctl_victim_way_tc1_o        (cpuslv3_tagctl_victim_way_tc1[3:0]),
    .cpuslv_inv_all_starting_o             (cpuslv3_inv_all_starting),
    .cpuslv_hz_tc2_o                       (cpuslv3_hz_tc2),
    .cpuslv_snp_hz_tc2_o                   (cpuslv3_snp_hz_tc2),
    .cpuslv_snp_hz_id_tc2_o                (cpuslv3_snp_hz_id_tc2[2:0]),
    .cpuslv_snp_l2db_hz_tc2_o              (cpuslv3_snp_l2db_hz_tc2),
    .cpuslv_snp_l2db_dirty_tc2_o           (cpuslv3_snp_l2db_dirty_tc2),
    .cpuslv_snp_l2db_tc2_o                 (cpuslv3_snp_l2db_tc2[3:0]),
    .cpuslv_ecc_hz_tc2_o                   (cpuslv3_ecc_hz_tc2),
    .cpuslv_force_miss_tc2_o               (cpuslv3_force_miss_tc2[31:0]),
    .cpuslv_l2_way_used_tc2_o              (cpuslv3_l2_way_used_tc2[15:0]),
    .cpuslv_hz_tc4_o                       (cpuslv3_hz_tc4),
    .scu_drain_stb_o                       (scu_cpu3_drain_stb_o),
    .cpuslv_noncoh_since_barrier_o         (cpuslv3_noncoh_since_barrier),
    .cpuslv_dvm_sync_resp_o                (cpuslv3_dvm_sync_resp),
    .cpuslv_ac_ready_o                     (cpuslv3_ac_ready),
    .cpuslv_cr_valid_o                     (cpuslv3_cr_valid),
    .cpuslv_cr_id_o                        (cpuslv3_cr_id[2:0]),
    .cpuslv_cr_dirty_o                     (cpuslv3_cr_dirty),
    .cpuslv_cr_age_o                       (cpuslv3_cr_age),
    .cpuslv_cr_alloc_o                     (cpuslv3_cr_alloc),
    .cpuslv_cr_migratory_o                 (cpuslv3_cr_migratory),
    .cpuslv_compack_active_o               (cpuslv3_compack_active),
    .cpuslv_compack_valid_o                (cpuslv3_compack_valid),
    .cpuslv_compack_tgtid_o                (cpuslv3_compack_tgtid[6:0]),
    .cpuslv_compack_txnid_o                (cpuslv3_compack_txnid[7:0]),
    .cpuslv_victimctl_active_o             (cpuslv3_victimctl_active),
    .cpuslv_victimctl_valid_o              (cpuslv3_victimctl_valid),
    .cpuslv_victimctl_index_o              (cpuslv3_victimctl_index[10:0]),
    .cpuslv_victimctl_wr_o                 (cpuslv3_victimctl_wr),
    .cpuslv_victimctl_age_o                (cpuslv3_victimctl_age),
    .cpuslv_victimctl_iside_o              (cpuslv3_victimctl_iside),
    .cpuslv_victimctl_nontemp_o            (cpuslv3_victimctl_nontemp),
    .cpuslv_victimctl_way_o                (cpuslv3_victimctl_way[3:0]),
    .cpuslv_victimctl_id_o                 (cpuslv3_victimctl_id[2:0]),
    .cpuslv_l2_way_used_vc2_o              (cpuslv3_l2_way_used_vc2[15:0]),
    .cpuslv_l2dbs_active_o                 (cpuslv3_l2dbs_active),
    .cpuslv_ramctl_active_o                (cpuslv3_ramctl_active),
    .cpuslv_l2db0_transfer_o               (cpuslv3_l2db0_transfer),
    .cpuslv_l2db0_transfer_type_o          (cpuslv3_l2db0_transfer_type[2:0]),
    .cpuslv_l2db0_transfer_info_o          (cpuslv3_l2db0_transfer_info[23:0]),
    .cpuslv_l2db0_release_o                (cpuslv3_l2db0_release),
    .cpuslv_l2db1_transfer_o               (cpuslv3_l2db1_transfer),
    .cpuslv_l2db1_transfer_type_o          (cpuslv3_l2db1_transfer_type[2:0]),
    .cpuslv_l2db1_transfer_info_o          (cpuslv3_l2db1_transfer_info[23:0]),
    .cpuslv_l2db1_release_o                (cpuslv3_l2db1_release),
    .cpuslv_l2db2_transfer_o               (cpuslv3_l2db2_transfer),
    .cpuslv_l2db2_transfer_type_o          (cpuslv3_l2db2_transfer_type[2:0]),
    .cpuslv_l2db2_transfer_info_o          (cpuslv3_l2db2_transfer_info[23:0]),
    .cpuslv_l2db2_release_o                (cpuslv3_l2db2_release),
    .cpuslv_l2db3_transfer_o               (cpuslv3_l2db3_transfer),
    .cpuslv_l2db3_transfer_type_o          (cpuslv3_l2db3_transfer_type[2:0]),
    .cpuslv_l2db3_transfer_info_o          (cpuslv3_l2db3_transfer_info[23:0]),
    .cpuslv_l2db3_release_o                (cpuslv3_l2db3_release),
    .cpuslv_l2db4_transfer_o               (cpuslv3_l2db4_transfer),
    .cpuslv_l2db4_transfer_type_o          (cpuslv3_l2db4_transfer_type[2:0]),
    .cpuslv_l2db4_transfer_info_o          (cpuslv3_l2db4_transfer_info[23:0]),
    .cpuslv_l2db4_release_o                (cpuslv3_l2db4_release),
    .cpuslv_l2db5_transfer_o               (cpuslv3_l2db5_transfer),
    .cpuslv_l2db5_transfer_type_o          (cpuslv3_l2db5_transfer_type[2:0]),
    .cpuslv_l2db5_transfer_info_o          (cpuslv3_l2db5_transfer_info[23:0]),
    .cpuslv_l2db5_release_o                (cpuslv3_l2db5_release),
    .cpuslv_l2db6_transfer_o               (cpuslv3_l2db6_transfer),
    .cpuslv_l2db6_transfer_type_o          (cpuslv3_l2db6_transfer_type[2:0]),
    .cpuslv_l2db6_transfer_info_o          (cpuslv3_l2db6_transfer_info[23:0]),
    .cpuslv_l2db6_release_o                (cpuslv3_l2db6_release),
    .cpuslv_l2db7_transfer_o               (cpuslv3_l2db7_transfer),
    .cpuslv_l2db7_transfer_type_o          (cpuslv3_l2db7_transfer_type[2:0]),
    .cpuslv_l2db7_transfer_info_o          (cpuslv3_l2db7_transfer_info[23:0]),
    .cpuslv_l2db7_release_o                (cpuslv3_l2db7_release),
    .cpuslv_l2db8_transfer_o               (cpuslv3_l2db8_transfer),
    .cpuslv_l2db8_transfer_type_o          (cpuslv3_l2db8_transfer_type[2:0]),
    .cpuslv_l2db8_transfer_info_o          (cpuslv3_l2db8_transfer_info[23:0]),
    .cpuslv_l2db8_release_o                (cpuslv3_l2db8_release),
    .cpuslv_l2db9_transfer_o               (cpuslv3_l2db9_transfer),
    .cpuslv_l2db9_transfer_type_o          (cpuslv3_l2db9_transfer_type[2:0]),
    .cpuslv_l2db9_transfer_info_o          (cpuslv3_l2db9_transfer_info[23:0]),
    .cpuslv_l2db9_release_o                (cpuslv3_l2db9_release),
    .cpuslv_l2db10_transfer_o              (cpuslv3_l2db10_transfer),
    .cpuslv_l2db10_transfer_type_o         (cpuslv3_l2db10_transfer_type[2:0]),
    .cpuslv_l2db10_transfer_info_o         (cpuslv3_l2db10_transfer_info[23:0]),
    .cpuslv_l2db10_release_o               (cpuslv3_l2db10_release),
    .cpuslv_early_dr_l2_o                  (cpuslv3_early_dr_l2),
    .cpuslv_early_dr_index_o               (cpuslv3_early_dr_index[10:0]),
    .cpuslv_early_dr_way_o                 (cpuslv3_early_dr_way[3:0]),
    .cpuslv_early_dr_ready_o               (cpuslv3_early_dr_ready[7:0]),
    .cpuslv_delay_allocation_o             (cpuslv3_delay_allocation[7:0]),
    .cpuslv_master_dr_ready_o              (cpuslv3_master_dr_ready),
    .cpuslv_master_sactive_o               (cpuslv3_master_sactive),
    .cpuslv_sample_waddrs_o                (cpuslv3_sample_waddrs),
    .cpuslv_sample_waddrs_dsb_o            (cpuslv3_sample_waddrs_dsb),
    .scu_reqbufs_busy_o                    (scu_cpu3_reqbufs_busy_o[7:0]),
    .cpuslv_l2db0_ready_o                  (cpuslv3_l2db0_ready),
    .cpuslv_l2db1_ready_o                  (cpuslv3_l2db1_ready),
    .cpuslv_l2db2_ready_o                  (cpuslv3_l2db2_ready),
    .cpuslv_l2db3_ready_o                  (cpuslv3_l2db3_ready),
    .cpuslv_l2db4_ready_o                  (cpuslv3_l2db4_ready),
    .cpuslv_l2db5_ready_o                  (cpuslv3_l2db5_ready),
    .cpuslv_l2db6_ready_o                  (cpuslv3_l2db6_ready),
    .cpuslv_l2db7_ready_o                  (cpuslv3_l2db7_ready),
    .cpuslv_l2db8_ready_o                  (cpuslv3_l2db8_ready),
    .cpuslv_l2db9_ready_o                  (cpuslv3_l2db9_ready),
    .cpuslv_l2db10_ready_o                 (cpuslv3_l2db10_ready),
    .cpuslv_l2dbs_dw_valid_o               (cpuslv3_l2dbs_dw_valid),
    .cpuslv_l2dbs_dw_id_o                  (cpuslv3_l2dbs_dw_id[3:0]),
    .cpuslv_l2dbs_dw_chunks_valid_o        (cpuslv3_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv_l2dbs_dw_last_o                (cpuslv3_l2dbs_dw_last),
    .cpuslv_l2dbs_dw_data_o                (cpuslv3_l2dbs_dw_data[255:0]),
    .cpuslv_l2dbs_dw_strb_o                (cpuslv3_l2dbs_dw_strb[31:0]),
    .cpuslv_l2dbs_dw_err_o                 (cpuslv3_l2dbs_dw_err),
    .cpuslv_l2dbs_dw_fatal_o               (cpuslv3_l2dbs_dw_fatal),
    .scu_evnt_eviction_o                   (scu_cpu3_evnt_eviction_o),
    .scu_evnt_snooped_data_o               (scu_cpu3_evnt_snooped_data_o),
    .scu_evnt_l2_access_o                  (scu_cpu3_evnt_l2_access_o)
  );  // u_scu_cpuslv3

  ca53scu_acpslv #(`CA53_SCU_INT_PARAM_INST) u_scu_acpslv (
    /*ARMAUTO*/
    // Inputs
    .CLKIN                               (CLKIN),
    .clk                                 (clk),
    .reset_n                             (reset_n),
    .DFTSE                               (DFTSE),
    .leaving_reset_i                     (leaving_reset),
    .config_broadcastinner_i             (config_broadcastinner),
    .config_broadcastouter_i             (config_broadcastouter),
    .config_l1_dc_size_i                 (config_l1_dc_size[2:0]),
    .config_l2_size_i                    (config_l2_size[3:0]),
    .gov_enable_writeevict_i             (gov_enable_writeevict_i),
    .gov_l2_in_retention_i               (gov_l2_in_retention_i),
    .clean_aclkens_i                     (clean_aclkens),
    .acp_ainact_rs_i                     (acp_ainact_rs),
    .ext_acp_awvalid_i                   (ext_acp_awvalid_i),
    .ext_acp_awid_i                      (ext_acp_awid_i[4:0]),
    .ext_acp_awaddr_i                    (ext_acp_awaddr_i[39:0]),
    .ext_acp_awlen_i                     (ext_acp_awlen_i[7:0]),
    .ext_acp_awcache_i                   (ext_acp_awcache_i[3:0]),
    .ext_acp_awuser_i                    (ext_acp_awuser_i[1:0]),
    .ext_acp_awprot_i                    (ext_acp_awprot_i[2:0]),
    .ext_acp_wvalid_i                    (ext_acp_wvalid_i),
    .ext_acp_wdata_i                     (ext_acp_wdata_i[127:0]),
    .ext_acp_wstrb_i                     (ext_acp_wstrb_i[15:0]),
    .ext_acp_wlast_i                     (ext_acp_wlast_i),
    .ext_acp_bready_i                    (ext_acp_bready_i),
    .ext_acp_arvalid_i                   (ext_acp_arvalid_i),
    .ext_acp_arid_i                      (ext_acp_arid_i[4:0]),
    .ext_acp_araddr_i                    (ext_acp_araddr_i[39:0]),
    .ext_acp_arlen_i                     (ext_acp_arlen_i[7:0]),
    .ext_acp_arcache_i                   (ext_acp_arcache_i[3:0]),
    .ext_acp_aruser_i                    (ext_acp_aruser_i[1:0]),
    .ext_acp_arprot_i                    (ext_acp_arprot_i[2:0]),
    .ext_acp_rready_i                    (ext_acp_rready_i),
    .tagctl_acpslv_ready_tc0_i           (tagctl_acpslv_ready_tc0),
    .tagctl_acpslv_noncoh_only_i         (tagctl_acpslv_noncoh_only),
    .tagctl_slv_flush_tc1_i              (tagctl_slv_flush_tc1),
    .tagctl_slv_flush_tc2_i              (tagctl_slv_flush_tc2),
    .tagctl_slv_flush_tc3_i              (tagctl_slv_flush_tc3),
    .tagctl_slv_flush_tc4_i              (tagctl_slv_flush_tc4),
    .tagctl_slv_early_flush_tc4_i        (tagctl_slv_early_flush_tc4),
    .tagctl_slv_afb_tc1_i                (tagctl_slv_afb_tc1[2:0]),
    .tagctl_slv_l2db_tc1_i               (tagctl_slv_l2db_tc1[3:0]),
    .tagctl_slv_l2db_tc4_i               (tagctl_slv_l2db_tc4[3:0]),
    .tagctl_l1_hit_ways_tc3_i            (tagctl_l1_hit_ways_tc3[15:0]),
    .tagctl_l2_hit_ways_tc3_i            (tagctl_l2_hit_ways_tc3[15:0]),
    .tagctl_l2_dirty_tc3_i               (tagctl_l2_dirty_tc3),
    .tagctl_shareability_tc3_i           (tagctl_shareability_tc3[1:0]),
    .tagctl_cluster_unique_tc3_i         (tagctl_cluster_unique_tc3),
    .tagctl_l2_victim_valid_tc3_i        (tagctl_l2_victim_valid_tc3),
    .tagctl_l2_victim_shareability_tc3_i (tagctl_l2_victim_shareability_tc3[1:0]),
    .tagctl_l2_victim_alloc_tc3_i        (tagctl_l2_victim_alloc_tc3),
    .tagctl_l2_victim_cu_tc3_i           (tagctl_l2_victim_cu_tc3),
    .tagctl_l2_victim_way_tc3_i          (tagctl_l2_victim_way_tc3[3:0]),
    .tagctl_ecc_err_tc3_i                (tagctl_ecc_err_tc3),
    .tagctl_snoop_data_cpu_tc4_i         (tagctl_snoop_data_cpu_tc4[1:0]),
    .afb0_done_i                         (afb0_done),
    .afb1_done_i                         (afb1_done),
    .afb2_done_i                         (afb2_done),
    .afb3_done_i                         (afb3_done),
    .afb4_done_i                         (afb4_done),
    .afb5_done_i                         (afb5_done),
    .afb0_write_done_i                   (afb0_write_done),
    .afb1_write_done_i                   (afb1_write_done),
    .afb2_write_done_i                   (afb2_write_done),
    .afb3_write_done_i                   (afb3_write_done),
    .afb4_write_done_i                   (afb4_write_done),
    .afb5_write_done_i                   (afb5_write_done),
    .tagctl_addr_tc1_i                   (tagctl_addr_tc1[41:6]),
    .tagctl_addr_valid_tc1_i             (tagctl_addr_valid_tc1),
    .tagctl_reqbufid_tc1_i               (tagctl_reqbufid_tc1[5:0]),
    .tagctl_index_valid_tc1_i            (tagctl_index_valid_tc1),
    .tagctl_serialising_tc1_i            (tagctl_serialising_tc1),
    .tagctl_l1_lf_tc1_i                  (tagctl_l1_lf_tc1),
    .tagctl_ecc_way_tc1_i                (tagctl_ecc_way_tc1[15:0]),
    .tagctl_addr_tc3_i                   (tagctl_addr_tc3[40:6]),
    .tagctl_addr_valid_tc3_i             (tagctl_addr_valid_tc3),
    .tagctl_reqbufid_tc3_i               (tagctl_reqbufid_tc3[5:0]),
    .victimctl_ready_i                   (victimctl_ready),
    .victimctl_ready_id_i                (victimctl_ready_id[5:0]),
    .victimctl_ack_i                     (victimctl_ack),
    .victimctl_ack_id_i                  (victimctl_ack_id[5:0]),
    .victimctl_victim_way_i              (victimctl_victim_way[3:0]),
    .victimctl_index_vc1_i               (victimctl_index_vc1[10:0]),
    .l2db0_slv_done_i                    (l2db0_slv_done),
    .l2db1_slv_done_i                    (l2db1_slv_done),
    .l2db2_slv_done_i                    (l2db2_slv_done),
    .l2db3_slv_done_i                    (l2db3_slv_done),
    .l2db4_slv_done_i                    (l2db4_slv_done),
    .l2db5_slv_done_i                    (l2db5_slv_done),
    .l2db6_slv_done_i                    (l2db6_slv_done),
    .l2db7_slv_done_i                    (l2db7_slv_done),
    .l2db8_slv_done_i                    (l2db8_slv_done),
    .l2db9_slv_done_i                    (l2db9_slv_done),
    .l2db10_slv_done_i                   (l2db10_slv_done),
    .l2db0_full_line_i                   (l2db0_full_line),
    .l2db1_full_line_i                   (l2db1_full_line),
    .l2db2_full_line_i                   (l2db2_full_line),
    .l2db3_full_line_i                   (l2db3_full_line),
    .l2db4_full_line_i                   (l2db4_full_line),
    .l2db5_full_line_i                   (l2db5_full_line),
    .l2db6_full_line_i                   (l2db6_full_line),
    .l2db7_full_line_i                   (l2db7_full_line),
    .l2db8_full_line_i                   (l2db8_full_line),
    .l2db9_full_line_i                   (l2db9_full_line),
    .l2db10_full_line_i                  (l2db10_full_line),
    .l2db0_rmw_line_i                    (l2db0_rmw_line),
    .l2db1_rmw_line_i                    (l2db1_rmw_line),
    .l2db2_rmw_line_i                    (l2db2_rmw_line),
    .l2db3_rmw_line_i                    (l2db3_rmw_line),
    .l2db4_rmw_line_i                    (l2db4_rmw_line),
    .l2db5_rmw_line_i                    (l2db5_rmw_line),
    .l2db6_rmw_line_i                    (l2db6_rmw_line),
    .l2db7_rmw_line_i                    (l2db7_rmw_line),
    .l2db8_rmw_line_i                    (l2db8_rmw_line),
    .l2db9_rmw_line_i                    (l2db9_rmw_line),
    .l2db10_rmw_line_i                   (l2db10_rmw_line),
    .snpslv_acpslv_compack_ready_i       (snpslv_acpslv_compack_ready),
    .master_early_dr_valid_i             (master_early_dr_valid),
    .master_early_dr_barrier_i           (master_early_dr_barrier),
    .master_early_dr_id_i                (master_early_dr_id[5:0]),
    .master_early_dr_dbid_i              (master_early_dr_dbid[7:0]),
    .master_early_dr_srcid_i             (master_early_dr_srcid[6:0]),
    .master_early_dr_chunk_i             (master_early_dr_chunk[1:0]),
    .master_early_dr_resp_i              (master_early_dr_resp[3:0]),
    .master_early_dr_same_i              (master_early_dr_same),
    .master_early_dr_ready_i             (master_early_dr_ready),
    .master_acpslv_dr_valid_i            (master_acpslv_dr_valid),
    .master_acpslv_dr_id_i               (master_acpslv_dr_id[5:0]),
    .master_dr_chunk_i                   (master_dr_chunk[1:0]),
    .master_dr_data_i                    (master_dr_data[127:0]),
    .master_dr_resp_i                    (master_dr_resp[3:0]),
    .master_acpslv_l2_waiting_i          (master_acpslv_l2_waiting[3:0]),
    .master_rsp_comp_valid_i             (master_rsp_comp_valid),
    .master_rsp_txnid_i                  (master_rsp_txnid[6:0]),
    .master_rsp_dbid_i                   (master_rsp_dbid[7:0]),
    .master_rsp_srcid_i                  (master_rsp_srcid[6:0]),
    .master_rsp_resp_i                   (master_rsp_resp[3:0]),
    .master_acpslv_reqbuf_retry_i        (master_acpslv_reqbuf_retry[3:0]),
    .master_acpslv_pcrdtype_i            (master_acpslv_pcrdtype[1:0]),
    .l2db0_slv_valid_i                   (l2db0_slv_valid),
    .l2db0_slv_id_i                      (l2db0_slv_id[5:0]),
    .l2db0_slv_data_i                    (l2db0_slv_data[127:0]),
    .l2db0_slv_err_i                     (l2db0_slv_err),
    .l2db0_slv_last_i                    (l2db0_slv_last),
    .l2db1_slv_valid_i                   (l2db1_slv_valid),
    .l2db1_slv_id_i                      (l2db1_slv_id[5:0]),
    .l2db1_slv_data_i                    (l2db1_slv_data[127:0]),
    .l2db1_slv_err_i                     (l2db1_slv_err),
    .l2db1_slv_last_i                    (l2db1_slv_last),
    .l2db2_slv_valid_i                   (l2db2_slv_valid),
    .l2db2_slv_id_i                      (l2db2_slv_id[5:0]),
    .l2db2_slv_data_i                    (l2db2_slv_data[127:0]),
    .l2db2_slv_err_i                     (l2db2_slv_err),
    .l2db2_slv_last_i                    (l2db2_slv_last),
    .l2db3_slv_valid_i                   (l2db3_slv_valid),
    .l2db3_slv_id_i                      (l2db3_slv_id[5:0]),
    .l2db3_slv_data_i                    (l2db3_slv_data[127:0]),
    .l2db3_slv_err_i                     (l2db3_slv_err),
    .l2db3_slv_last_i                    (l2db3_slv_last),
    .l2db4_slv_valid_i                   (l2db4_slv_valid),
    .l2db4_slv_id_i                      (l2db4_slv_id[5:0]),
    .l2db4_slv_data_i                    (l2db4_slv_data[127:0]),
    .l2db4_slv_err_i                     (l2db4_slv_err),
    .l2db4_slv_last_i                    (l2db4_slv_last),
    .l2db5_slv_valid_i                   (l2db5_slv_valid),
    .l2db5_slv_id_i                      (l2db5_slv_id[5:0]),
    .l2db5_slv_data_i                    (l2db5_slv_data[127:0]),
    .l2db5_slv_err_i                     (l2db5_slv_err),
    .l2db5_slv_last_i                    (l2db5_slv_last),
    .l2db6_slv_valid_i                   (l2db6_slv_valid),
    .l2db6_slv_id_i                      (l2db6_slv_id[5:0]),
    .l2db6_slv_data_i                    (l2db6_slv_data[127:0]),
    .l2db6_slv_err_i                     (l2db6_slv_err),
    .l2db6_slv_last_i                    (l2db6_slv_last),
    .l2db7_slv_valid_i                   (l2db7_slv_valid),
    .l2db7_slv_id_i                      (l2db7_slv_id[5:0]),
    .l2db7_slv_data_i                    (l2db7_slv_data[127:0]),
    .l2db7_slv_err_i                     (l2db7_slv_err),
    .l2db7_slv_last_i                    (l2db7_slv_last),
    .l2db8_slv_valid_i                   (l2db8_slv_valid),
    .l2db8_slv_id_i                      (l2db8_slv_id[5:0]),
    .l2db8_slv_data_i                    (l2db8_slv_data[127:0]),
    .l2db8_slv_err_i                     (l2db8_slv_err),
    .l2db8_slv_last_i                    (l2db8_slv_last),
    .l2db9_slv_valid_i                   (l2db9_slv_valid),
    .l2db9_slv_id_i                      (l2db9_slv_id[5:0]),
    .l2db9_slv_data_i                    (l2db9_slv_data[127:0]),
    .l2db9_slv_err_i                     (l2db9_slv_err),
    .l2db9_slv_last_i                    (l2db9_slv_last),
    .l2db10_slv_valid_i                  (l2db10_slv_valid),
    .l2db10_slv_id_i                     (l2db10_slv_id[5:0]),
    .l2db10_slv_data_i                   (l2db10_slv_data[127:0]),
    .l2db10_slv_err_i                    (l2db10_slv_err),
    .l2db10_slv_last_i                   (l2db10_slv_last),
    // Outputs
    .acpslv_active_o                     (acpslv_active),
    .acpslv_ramctl_active_o              (acpslv_ramctl_active),
    .scu_acp_awready_o                   (scu_acp_awready),
    .scu_acp_wready_o                    (scu_acp_wready),
    .scu_acp_bvalid_o                    (scu_acp_bvalid_o),
    .scu_acp_bid_o                       (scu_acp_bid_o[4:0]),
    .scu_acp_bresp_o                     (scu_acp_bresp_o[1:0]),
    .scu_acp_arready_o                   (scu_acp_arready),
    .scu_acp_rvalid_o                    (scu_acp_rvalid_o),
    .scu_acp_rid_o                       (scu_acp_rid_o[4:0]),
    .scu_acp_rdata_o                     (scu_acp_rdata_o[127:0]),
    .scu_acp_rresp_o                     (scu_acp_rresp_o[1:0]),
    .scu_acp_rlast_o                     (scu_acp_rlast_o),
    .acpslv_tagctl_valid_tc0_o           (acpslv_tagctl_valid_tc0),
    .acpslv_tagctl_early_valid_tc0_o     (acpslv_tagctl_early_valid_tc0),
    .acpslv_tagctl_spec_valid_tc0_o      (acpslv_tagctl_spec_valid_tc0),
    .acpslv_tagctl_active_tc0_o          (acpslv_tagctl_active_tc0),
    .acpslv_tagctl_reqbufid_tc0_o        (acpslv_tagctl_reqbufid_tc0[2:0]),
    .acpslv_tagctl_pass_tc0_o            (acpslv_tagctl_pass_tc0[3:0]),
    .acpslv_tagctl_addr1_tc0_o           (acpslv_tagctl_addr1_tc0[40:0]),
    .acpslv_tagctl_wr_state_tc0_o        (acpslv_tagctl_wr_state_tc0[16:0]),
    .acpslv_tagctl_ecc_tc0_o             (acpslv_tagctl_ecc_tc0[34:0]),
    .acpslv_tagctl_ways_tc0_o            (acpslv_tagctl_ways_tc0[31:0]),
    .acpslv_tagctl_write_tc0_o           (acpslv_tagctl_write_tc0[4:0]),
    .acpslv_tagctl_type_tc0_o            (acpslv_tagctl_type_tc0[4:0]),
    .acpslv_tagctl_len_tc1_o             (acpslv_tagctl_len_tc1[1:0]),
    .acpslv_tagctl_single_tc1_o          (acpslv_tagctl_single_tc1),
    .acpslv_tagctl_size_tc1_o            (acpslv_tagctl_size_tc1[2:0]),
    .acpslv_tagctl_attrs_tc1_o           (acpslv_tagctl_attrs_tc1[7:0]),
    .acpslv_tagctl_dirty_tc1_o           (acpslv_tagctl_dirty_tc1),
    .acpslv_tagctl_cluster_unique_tc1_o  (acpslv_tagctl_cluster_unique_tc1),
    .acpslv_tagctl_prot_tc1_o            (acpslv_tagctl_prot_tc1[1:0]),
    .acpslv_tagctl_l2db_tc1_o            (acpslv_tagctl_l2db_tc1[3:0]),
    .acpslv_tagctl_l2db_full_tc1_o       (acpslv_tagctl_l2db_full_tc1),
    .acpslv_tagctl_static_pcredit_tc1_o  (acpslv_tagctl_static_pcredit_tc1),
    .acpslv_tagctl_pcrdtype_tc1_o        (acpslv_tagctl_pcrdtype_tc1[1:0]),
    .acpslv_tagctl_victim_way_tc1_o      (acpslv_tagctl_victim_way_tc1[3:0]),
    .acpslv_tagctl_slverr_tc1_o          (acpslv_tagctl_slverr_tc1),
    .acpslv_hz_tc2_o                     (acpslv_hz_tc2),
    .acpslv_force_miss_tc2_o             (acpslv_force_miss_tc2[15:0]),
    .acpslv_l2_way_used_tc2_o            (acpslv_l2_way_used_tc2[15:0]),
    .acpslv_hz_tc4_o                     (acpslv_hz_tc4),
    .acpslv_victimctl_active_o           (acpslv_victimctl_active),
    .acpslv_victimctl_valid_o            (acpslv_victimctl_valid),
    .acpslv_victimctl_index_o            (acpslv_victimctl_index[10:0]),
    .acpslv_victimctl_wr_o               (acpslv_victimctl_wr),
    .acpslv_victimctl_age_o              (acpslv_victimctl_age),
    .acpslv_victimctl_way_o              (acpslv_victimctl_way[3:0]),
    .acpslv_victimctl_id_o               (acpslv_victimctl_id[2:0]),
    .acpslv_l2_way_used_vc2_o            (acpslv_l2_way_used_vc2[15:0]),
    .acpslv_l2dbs_active_o               (acpslv_l2dbs_active),
    .acpslv_l2db0_transfer_o             (acpslv_l2db0_transfer),
    .acpslv_l2db0_transfer_type_o        (acpslv_l2db0_transfer_type[2:0]),
    .acpslv_l2db0_transfer_info_o        (acpslv_l2db0_transfer_info[25:0]),
    .acpslv_l2db0_release_o              (acpslv_l2db0_release),
    .acpslv_l2db1_transfer_o             (acpslv_l2db1_transfer),
    .acpslv_l2db1_transfer_type_o        (acpslv_l2db1_transfer_type[2:0]),
    .acpslv_l2db1_transfer_info_o        (acpslv_l2db1_transfer_info[25:0]),
    .acpslv_l2db1_release_o              (acpslv_l2db1_release),
    .acpslv_l2db2_transfer_o             (acpslv_l2db2_transfer),
    .acpslv_l2db2_transfer_type_o        (acpslv_l2db2_transfer_type[2:0]),
    .acpslv_l2db2_transfer_info_o        (acpslv_l2db2_transfer_info[25:0]),
    .acpslv_l2db2_release_o              (acpslv_l2db2_release),
    .acpslv_l2db3_transfer_o             (acpslv_l2db3_transfer),
    .acpslv_l2db3_transfer_type_o        (acpslv_l2db3_transfer_type[2:0]),
    .acpslv_l2db3_transfer_info_o        (acpslv_l2db3_transfer_info[25:0]),
    .acpslv_l2db3_release_o              (acpslv_l2db3_release),
    .acpslv_l2db4_transfer_o             (acpslv_l2db4_transfer),
    .acpslv_l2db4_transfer_type_o        (acpslv_l2db4_transfer_type[2:0]),
    .acpslv_l2db4_transfer_info_o        (acpslv_l2db4_transfer_info[25:0]),
    .acpslv_l2db4_release_o              (acpslv_l2db4_release),
    .acpslv_l2db5_transfer_o             (acpslv_l2db5_transfer),
    .acpslv_l2db5_transfer_type_o        (acpslv_l2db5_transfer_type[2:0]),
    .acpslv_l2db5_transfer_info_o        (acpslv_l2db5_transfer_info[25:0]),
    .acpslv_l2db5_release_o              (acpslv_l2db5_release),
    .acpslv_l2db6_transfer_o             (acpslv_l2db6_transfer),
    .acpslv_l2db6_transfer_type_o        (acpslv_l2db6_transfer_type[2:0]),
    .acpslv_l2db6_transfer_info_o        (acpslv_l2db6_transfer_info[25:0]),
    .acpslv_l2db6_release_o              (acpslv_l2db6_release),
    .acpslv_l2db7_transfer_o             (acpslv_l2db7_transfer),
    .acpslv_l2db7_transfer_type_o        (acpslv_l2db7_transfer_type[2:0]),
    .acpslv_l2db7_transfer_info_o        (acpslv_l2db7_transfer_info[25:0]),
    .acpslv_l2db7_release_o              (acpslv_l2db7_release),
    .acpslv_l2db8_transfer_o             (acpslv_l2db8_transfer),
    .acpslv_l2db8_transfer_type_o        (acpslv_l2db8_transfer_type[2:0]),
    .acpslv_l2db8_transfer_info_o        (acpslv_l2db8_transfer_info[25:0]),
    .acpslv_l2db8_release_o              (acpslv_l2db8_release),
    .acpslv_l2db9_transfer_o             (acpslv_l2db9_transfer),
    .acpslv_l2db9_transfer_type_o        (acpslv_l2db9_transfer_type[2:0]),
    .acpslv_l2db9_transfer_info_o        (acpslv_l2db9_transfer_info[25:0]),
    .acpslv_l2db9_release_o              (acpslv_l2db9_release),
    .acpslv_l2db10_transfer_o            (acpslv_l2db10_transfer),
    .acpslv_l2db10_transfer_type_o       (acpslv_l2db10_transfer_type[2:0]),
    .acpslv_l2db10_transfer_info_o       (acpslv_l2db10_transfer_info[25:0]),
    .acpslv_l2db10_release_o             (acpslv_l2db10_release),
    .acpslv_compack_active_o             (acpslv_compack_active),
    .acpslv_compack_valid_o              (acpslv_compack_valid),
    .acpslv_compack_tgtid_o              (acpslv_compack_tgtid[6:0]),
    .acpslv_compack_txnid_o              (acpslv_compack_txnid[7:0]),
    .acpslv_early_dr_ready_o             (acpslv_early_dr_ready[15:0]),
    .acpslv_early_dr_l2_o                (acpslv_early_dr_l2),
    .acpslv_early_dr_index_o             (acpslv_early_dr_index[10:0]),
    .acpslv_early_dr_way_o               (acpslv_early_dr_way[3:0]),
    .acpslv_delay_allocation_o           (acpslv_delay_allocation[3:0]),
    .acpslv_master_dr_ready_o            (acpslv_master_dr_ready),
    .acpslv_master_sactive_o             (acpslv_master_sactive),
    .acpslv_ext_err_o                    (acpslv_ext_err),
    .acpslv_l2db0_ready_o                (acpslv_l2db0_ready),
    .acpslv_l2db1_ready_o                (acpslv_l2db1_ready),
    .acpslv_l2db2_ready_o                (acpslv_l2db2_ready),
    .acpslv_l2db3_ready_o                (acpslv_l2db3_ready),
    .acpslv_l2db4_ready_o                (acpslv_l2db4_ready),
    .acpslv_l2db5_ready_o                (acpslv_l2db5_ready),
    .acpslv_l2db6_ready_o                (acpslv_l2db6_ready),
    .acpslv_l2db7_ready_o                (acpslv_l2db7_ready),
    .acpslv_l2db8_ready_o                (acpslv_l2db8_ready),
    .acpslv_l2db9_ready_o                (acpslv_l2db9_ready),
    .acpslv_l2db10_ready_o               (acpslv_l2db10_ready),
    .acpslv_l2dbs_dw_valid_o             (acpslv_l2dbs_dw_valid),
    .acpslv_l2dbs_dw_id_o                (acpslv_l2dbs_dw_id[3:0]),
    .acpslv_l2dbs_dw_chunk_o             (acpslv_l2dbs_dw_chunk[1:0]),
    .acpslv_l2dbs_dw_last_o              (acpslv_l2dbs_dw_last),
    .acpslv_l2dbs_dw_data_o              (acpslv_l2dbs_dw_data[127:0]),
    .acpslv_l2dbs_dw_strb_o              (acpslv_l2dbs_dw_strb[15:0])
  );  // u_scu_acpslv

  ca53scu_snpslv #(`CA53_SCU_INT_PARAM_INST) u_scu_snpslv (
    /*ARMAUTO*/
    // Inputs
    .clk                                 (clk),
    .clk_ext_master                      (clk_ext_master),
    .reset_n                             (reset_n),
    .DFTSE                               (DFTSE),
    .config_broadcastinner_i             (config_broadcastinner),
    .config_sysbardisable_i              (config_sysbardisable),
    .config_l1_dc_size_i                 (config_l1_dc_size[2:0]),
    .config_l2_size_i                    (config_l2_size[3:0]),
    .config_nodeid_i                     (config_nodeid[6:0]),
    .gov_l2_in_retention_i               (gov_l2_in_retention_i),
    .inactm_rs_i                         (inactm_rs),
    .clean_aclken_i                      (clean_aclken),
    .scu_ext_ac_valid_i                  (scu_ext_ac_valid_i),
    .scu_ext_ac_snoop_i                  (scu_ext_ac_snoop_i[`CA53_ACE_ACSNOOP_W-1:0]),
    .scu_ext_ac_addr_i                   (scu_ext_ac_addr_i[`CA53_SCU_EXT_ADDR_W-1:0]),
    .scu_ext_ac_prot_i                   (scu_ext_ac_prot_i[`CA53_ACE_ACPROT_W-1:0]),
    .scu_ext_cr_ready_i                  (scu_ext_cr_ready_i),
    .ext_rxsnpflitpend_i                 (ext_rxsnpflitpend_i),
    .ext_rxsnpflitv_i                    (ext_rxsnpflitv_i),
    .ext_rxsnpflit_i                     (ext_rxsnpflit_i[64:0]),
    .ext_txrsplcrdv_i                    (ext_txrsplcrdv_i),
    .ramctl_ecc_flush_req_i              (ramctl_ecc_flush_req),
    .ramctl_ecc_flush_active_i           (ramctl_ecc_flush_active),
    .ramctl_ecc_flush_index_i            (ramctl_ecc_flush_index[10:0]),
    .ramctl_ecc_flush_way_i              (ramctl_ecc_flush_way[3:0]),
    .tagctl_snpslv_ready_tc0_i           (tagctl_snpslv_ready_tc0),
    .tagctl_reqbufid_tc1_i               (tagctl_reqbufid_tc1[5:0]),
    .tagctl_slv_afb_tc1_i                (tagctl_slv_afb_tc1[2:0]),
    .tagctl_slv_l2db_hit_tc3_i           (tagctl_slv_l2db_hit_tc3),
    .tagctl_slv_l2db_dirty_tc3_i         (tagctl_slv_l2db_dirty_tc3),
    .tagctl_slv_l2db_cu_tc3_i            (tagctl_slv_l2db_cu_tc3),
    .tagctl_slv_l2db_tc3_i               (tagctl_slv_l2db_tc3[3:0]),
    .tagctl_l1_hit_ways_tc3_i            (tagctl_l1_hit_ways_tc3[15:0]),
    .tagctl_l2_hit_ways_tc3_i            (tagctl_l2_hit_ways_tc3[15:0]),
    .tagctl_l2_dirty_tc3_i               (tagctl_l2_dirty_tc3),
    .tagctl_l2_alloc_tc3_i               (tagctl_l2_alloc_tc3),
    .tagctl_shareability_tc3_i           (tagctl_shareability_tc3[1:0]),
    .tagctl_cluster_unique_tc3_i         (tagctl_cluster_unique_tc3),
    .tagctl_l2_victim_valid_tc3_i        (tagctl_l2_victim_valid_tc3),
    .tagctl_l2_victim_cu_tc3_i           (tagctl_l2_victim_cu_tc3),
    .tagctl_l2_victim_dirty_tc3_i        (tagctl_l2_victim_dirty_tc3),
    .tagctl_l2_victim_alloc_tc3_i        (tagctl_l2_victim_alloc_tc3),
    .tagctl_l2_victim_shareability_tc3_i (tagctl_l2_victim_shareability_tc3[1:0]),
    .tagctl_snoop_data_cpu_tc4_i         (tagctl_snoop_data_cpu_tc4[1:0]),
    .tagctl_slv_flush_tc1_i              (tagctl_slv_flush_tc1),
    .tagctl_slv_flush_tc2_i              (tagctl_slv_flush_tc2),
    .tagctl_slv_flush_tc3_i              (tagctl_slv_flush_tc3),
    .tagctl_slv_flush_tc4_i              (tagctl_slv_flush_tc4),
    .tagctl_ecc_err_tc3_i                (tagctl_ecc_err_tc3),
    .afb0_done_i                         (afb0_done),
    .afb1_done_i                         (afb1_done),
    .afb2_done_i                         (afb2_done),
    .afb3_done_i                         (afb3_done),
    .afb4_done_i                         (afb4_done),
    .afb5_done_i                         (afb5_done),
    .afb0_write_done_i                   (afb0_write_done),
    .afb1_write_done_i                   (afb1_write_done),
    .afb2_write_done_i                   (afb2_write_done),
    .afb3_write_done_i                   (afb3_write_done),
    .afb4_write_done_i                   (afb4_write_done),
    .afb5_write_done_i                   (afb5_write_done),
    .afb0_snoop_resp_dirty_i             (afb0_snoop_resp_dirty),
    .afb1_snoop_resp_dirty_i             (afb1_snoop_resp_dirty),
    .afb2_snoop_resp_dirty_i             (afb2_snoop_resp_dirty),
    .afb3_snoop_resp_dirty_i             (afb3_snoop_resp_dirty),
    .afb4_snoop_resp_dirty_i             (afb4_snoop_resp_dirty),
    .afb5_snoop_resp_dirty_i             (afb5_snoop_resp_dirty),
    .tagctl_addr_tc1_i                   (tagctl_addr_tc1[41:6]),
    .tagctl_addr_valid_tc1_i             (tagctl_addr_valid_tc1),
    .tagctl_serialising_tc1_i            (tagctl_serialising_tc1),
    .tagctl_l1_lf_tc1_i                  (tagctl_l1_lf_tc1),
    .tagctl_ecc_way_tc1_i                (tagctl_ecc_way_tc1[15:0]),
    .tagctl_cpu_sync_tc1_i               (tagctl_cpu_sync_tc1),
    .tagctl_addr_tc3_i                   (tagctl_addr_tc3[40:6]),
    .tagctl_addr_valid_tc3_i             (tagctl_addr_valid_tc3),
    .victimctl_index_vc1_i               (victimctl_index_vc1[10:0]),
    .cpuslv0_compack_active_i            (cpuslv0_compack_active),
    .cpuslv1_compack_active_i            (cpuslv1_compack_active),
    .cpuslv2_compack_active_i            (cpuslv2_compack_active),
    .cpuslv3_compack_active_i            (cpuslv3_compack_active),
    .acpslv_compack_active_i             (acpslv_compack_active),
    .cpuslv0_compack_valid_i             (cpuslv0_compack_valid),
    .cpuslv1_compack_valid_i             (cpuslv1_compack_valid),
    .cpuslv2_compack_valid_i             (cpuslv2_compack_valid),
    .cpuslv3_compack_valid_i             (cpuslv3_compack_valid),
    .acpslv_compack_valid_i              (acpslv_compack_valid),
    .cpuslv0_compack_tgtid_i             (cpuslv0_compack_tgtid[6:0]),
    .cpuslv1_compack_tgtid_i             (cpuslv1_compack_tgtid[6:0]),
    .cpuslv2_compack_tgtid_i             (cpuslv2_compack_tgtid[6:0]),
    .cpuslv3_compack_tgtid_i             (cpuslv3_compack_tgtid[6:0]),
    .acpslv_compack_tgtid_i              (acpslv_compack_tgtid[6:0]),
    .cpuslv0_compack_txnid_i             (cpuslv0_compack_txnid[7:0]),
    .cpuslv1_compack_txnid_i             (cpuslv1_compack_txnid[7:0]),
    .cpuslv2_compack_txnid_i             (cpuslv2_compack_txnid[7:0]),
    .cpuslv3_compack_txnid_i             (cpuslv3_compack_txnid[7:0]),
    .acpslv_compack_txnid_i              (acpslv_compack_txnid[7:0]),
    .master_rxla_run_i                   (master_rxla_run),
    .master_rxla_deactivate_i            (master_rxla_deactivate),
    .master_rxla_stop_i                  (master_rxla_stop),
    .master_txla_run_i                   (master_txla_run),
    .master_txla_deactivate_i            (master_txla_deactivate),
    .l2db0_slv_done_i                    (l2db0_slv_done),
    .l2db1_slv_done_i                    (l2db1_slv_done),
    .l2db2_slv_done_i                    (l2db2_slv_done),
    .l2db3_slv_done_i                    (l2db3_slv_done),
    .l2db4_slv_done_i                    (l2db4_slv_done),
    .l2db5_slv_done_i                    (l2db5_slv_done),
    .l2db6_slv_done_i                    (l2db6_slv_done),
    .l2db7_slv_done_i                    (l2db7_slv_done),
    .l2db8_slv_done_i                    (l2db8_slv_done),
    .l2db9_slv_done_i                    (l2db9_slv_done),
    .l2db10_slv_done_i                   (l2db10_slv_done),
    .l2db0_snpslv_done_i                 (l2db0_snpslv_done),
    .l2db1_snpslv_done_i                 (l2db1_snpslv_done),
    .l2db2_snpslv_done_i                 (l2db2_snpslv_done),
    .l2db3_snpslv_done_i                 (l2db3_snpslv_done),
    .l2db4_snpslv_done_i                 (l2db4_snpslv_done),
    .l2db5_snpslv_done_i                 (l2db5_snpslv_done),
    .l2db6_snpslv_done_i                 (l2db6_snpslv_done),
    .l2db7_snpslv_done_i                 (l2db7_snpslv_done),
    .l2db8_snpslv_done_i                 (l2db8_snpslv_done),
    .l2db9_snpslv_done_i                 (l2db9_snpslv_done),
    .l2db10_snpslv_done_i                (l2db10_snpslv_done),
    .l2db0_slv_err_i                     (l2db0_slv_err),
    .l2db1_slv_err_i                     (l2db1_slv_err),
    .l2db2_slv_err_i                     (l2db2_slv_err),
    .l2db3_slv_err_i                     (l2db3_slv_err),
    .l2db4_slv_err_i                     (l2db4_slv_err),
    .l2db5_slv_err_i                     (l2db5_slv_err),
    .l2db6_slv_err_i                     (l2db6_slv_err),
    .l2db7_slv_err_i                     (l2db7_slv_err),
    .l2db8_slv_err_i                     (l2db8_slv_err),
    .l2db9_slv_err_i                     (l2db9_slv_err),
    .l2db10_slv_err_i                    (l2db10_slv_err),
    .l2db0_slv_master_arb_i              (l2db0_slv_master_arb),
    .l2db1_slv_master_arb_i              (l2db1_slv_master_arb),
    .l2db2_slv_master_arb_i              (l2db2_slv_master_arb),
    .l2db3_slv_master_arb_i              (l2db3_slv_master_arb),
    .l2db4_slv_master_arb_i              (l2db4_slv_master_arb),
    .l2db5_slv_master_arb_i              (l2db5_slv_master_arb),
    .l2db6_slv_master_arb_i              (l2db6_slv_master_arb),
    .l2db7_slv_master_arb_i              (l2db7_slv_master_arb),
    .l2db8_slv_master_arb_i              (l2db8_slv_master_arb),
    .l2db9_slv_master_arb_i              (l2db9_slv_master_arb),
    .l2db10_slv_master_arb_i             (l2db10_slv_master_arb),
    .ramctl_l2dbs_valid_i                (ramctl_l2dbs_valid),
    .ramctl_l2dbs_id_i                   (ramctl_l2dbs_id[3:0]),
    .ramctl_l2dbs_last_i                 (ramctl_l2dbs_last),
    .ramctl_bypassed_err_i               (ramctl_bypassed_err),
    .tagctl_snp_sync_tc1_i               (tagctl_snp_sync_tc1),
    .tagctl_dvm_sync_tc3_i               (tagctl_dvm_sync_tc3),
    .tagctl_snp_dvm_sync_tc4_i           (tagctl_snp_dvm_sync_tc4),
    .tagctl_cpu_dvm_sync_tc4_i           (tagctl_cpu_dvm_sync_tc4[3:0]),
    .master_snpslv_waddrs_valid_i        (master_snpslv_waddrs_valid),
    .master_snpslv_db_valid_i            (master_snpslv_db_valid),
    .master_snpslv_dr_valid_i            (master_snpslv_dr_valid),
    .master_rsp_comp_valid_i             (master_rsp_comp_valid),
    .master_rsp_txnid_i                  (master_rsp_txnid[6:0]),
    .master_snpslv_reqbuf_retry_i        (master_snpslv_reqbuf_retry),
    .master_snpslv_pcrdtype_i            (master_snpslv_pcrdtype[1:0]),
    .cpuslv0_noncoh_since_barrier_i      (cpuslv0_noncoh_since_barrier),
    .cpuslv1_noncoh_since_barrier_i      (cpuslv1_noncoh_since_barrier),
    .cpuslv2_noncoh_since_barrier_i      (cpuslv2_noncoh_since_barrier),
    .cpuslv3_noncoh_since_barrier_i      (cpuslv3_noncoh_since_barrier),
    .cpuslv0_dvm_sync_resp_i             (cpuslv0_dvm_sync_resp),
    .cpuslv1_dvm_sync_resp_i             (cpuslv1_dvm_sync_resp),
    .cpuslv2_dvm_sync_resp_i             (cpuslv2_dvm_sync_resp),
    .cpuslv3_dvm_sync_resp_i             (cpuslv3_dvm_sync_resp),
    .dcu_cpu0_dvm_complete_i             (dcu_cpu0_dvm_complete_i),
    .dcu_cpu1_dvm_complete_i             (dcu_cpu1_dvm_complete_i),
    .dcu_cpu2_dvm_complete_i             (dcu_cpu2_dvm_complete_i),
    .dcu_cpu3_dvm_complete_i             (dcu_cpu3_dvm_complete_i),
    .tagctl_dvm_complete_i               (tagctl_dvm_complete[3:0]),
    // Outputs
    .snpslv_active_o                     (snpslv_active),
    .snpslv_retention_active_o           (snpslv_retention_active),
    .snpslv_ramctl_active_o              (snpslv_ramctl_active),
    .snpslv_master_active_o              (snpslv_master_active),
    .scu_ext_ac_ready_o                  (scu_ext_ac_ready),
    .scu_ext_cr_valid_o                  (scu_ext_cr_valid_o),
    .scu_ext_cr_resp_o                   (scu_ext_cr_resp_o[`CA53_ACE_CRRESP_W-1:0]),
    .scu_rxsnplcrdv_o                    (scu_rxsnplcrdv_o),
    .scu_txrspflitpend_o                 (scu_txrspflitpend_o),
    .scu_txrspflitv_o                    (scu_txrspflitv_o),
    .scu_txrspflit_o                     (scu_txrspflit_o[44:0]),
    .snpslv_tagctl_valid_tc0_o           (snpslv_tagctl_valid_tc0),
    .snpslv_tagctl_early_valid_tc0_o     (snpslv_tagctl_early_valid_tc0),
    .snpslv_tagctl_spec_valid_tc0_o      (snpslv_tagctl_spec_valid_tc0),
    .snpslv_tagctl_active_tc0_o          (snpslv_tagctl_active_tc0),
    .snpslv_tagctl_reqbufid_tc0_o        (snpslv_tagctl_reqbufid_tc0[2:0]),
    .snpslv_tagctl_pass_tc0_o            (snpslv_tagctl_pass_tc0[3:0]),
    .snpslv_tagctl_addr1_tc0_o           (snpslv_tagctl_addr1_tc0[41:0]),
    .snpslv_tagctl_dvm_sync_tc0_o        (snpslv_tagctl_dvm_sync_tc0),
    .snpslv_tagctl_wr_state_tc0_o        (snpslv_tagctl_wr_state_tc0[16:0]),
    .snpslv_tagctl_ecc_tc0_o             (snpslv_tagctl_ecc_tc0[34:0]),
    .snpslv_tagctl_ways_tc0_o            (snpslv_tagctl_ways_tc0[31:0]),
    .snpslv_tagctl_write_tc0_o           (snpslv_tagctl_write_tc0[4:0]),
    .snpslv_tagctl_type_tc0_o            (snpslv_tagctl_type_tc0[4:0]),
    .snpslv_tagctl_addr2_tc1_o           (snpslv_tagctl_addr2_tc1[40:0]),
    .snpslv_tagctl_attrs_tc1_o           (snpslv_tagctl_attrs_tc1[7:0]),
    .snpslv_tagctl_dirty_tc1_o           (snpslv_tagctl_dirty_tc1),
    .snpslv_tagctl_cluster_unique_tc1_o  (snpslv_tagctl_cluster_unique_tc1),
    .snpslv_tagctl_l2db_tc1_o            (snpslv_tagctl_l2db_tc1[3:0]),
    .snpslv_tagctl_static_pcredit_tc1_o  (snpslv_tagctl_static_pcredit_tc1),
    .snpslv_tagctl_pcrdtype_tc1_o        (snpslv_tagctl_pcrdtype_tc1[1:0]),
    .snpslv_hz_tc2_o                     (snpslv_hz_tc2),
    .snpslv_ecc_hz_tc2_o                 (snpslv_ecc_hz_tc2),
    .snpslv_l2_way_used_tc2_o            (snpslv_l2_way_used_tc2[15:0]),
    .snpslv_hz_tc4_o                     (snpslv_hz_tc4),
    .dvm_comp_sync_outstanding_o         (dvm_comp_sync_outstanding),
    .snpslv_l2_way_used_vc2_o            (snpslv_l2_way_used_vc2[15:0]),
    .snpslv_cpuslv0_compack_ready_o      (snpslv_cpuslv0_compack_ready),
    .snpslv_cpuslv1_compack_ready_o      (snpslv_cpuslv1_compack_ready),
    .snpslv_cpuslv2_compack_ready_o      (snpslv_cpuslv2_compack_ready),
    .snpslv_cpuslv3_compack_ready_o      (snpslv_cpuslv3_compack_ready),
    .snpslv_acpslv_compack_ready_o       (snpslv_acpslv_compack_ready),
    .snpslv_txrsp_req_o                  (snpslv_txrsp_req),
    .snpslv_rxsnp_active_o               (snpslv_rxsnp_active),
    .snpslv_l2dbs_active_o               (snpslv_l2dbs_active),
    .snpslv_l2db0_invalidate_o           (snpslv_l2db0_invalidate),
    .snpslv_l2db0_makeshared_o           (snpslv_l2db0_makeshared),
    .snpslv_l2db0_transfer_o             (snpslv_l2db0_transfer),
    .snpslv_l2db0_transfer_type_o        (snpslv_l2db0_transfer_type[2:0]),
    .snpslv_l2db0_transfer_info_o        (snpslv_l2db0_transfer_info[28:0]),
    .snpslv_l2db0_release_o              (snpslv_l2db0_release),
    .snpslv_l2db1_invalidate_o           (snpslv_l2db1_invalidate),
    .snpslv_l2db1_makeshared_o           (snpslv_l2db1_makeshared),
    .snpslv_l2db1_transfer_o             (snpslv_l2db1_transfer),
    .snpslv_l2db1_transfer_type_o        (snpslv_l2db1_transfer_type[2:0]),
    .snpslv_l2db1_transfer_info_o        (snpslv_l2db1_transfer_info[28:0]),
    .snpslv_l2db1_release_o              (snpslv_l2db1_release),
    .snpslv_l2db2_invalidate_o           (snpslv_l2db2_invalidate),
    .snpslv_l2db2_makeshared_o           (snpslv_l2db2_makeshared),
    .snpslv_l2db2_transfer_o             (snpslv_l2db2_transfer),
    .snpslv_l2db2_transfer_type_o        (snpslv_l2db2_transfer_type[2:0]),
    .snpslv_l2db2_transfer_info_o        (snpslv_l2db2_transfer_info[28:0]),
    .snpslv_l2db2_release_o              (snpslv_l2db2_release),
    .snpslv_l2db3_invalidate_o           (snpslv_l2db3_invalidate),
    .snpslv_l2db3_makeshared_o           (snpslv_l2db3_makeshared),
    .snpslv_l2db3_transfer_o             (snpslv_l2db3_transfer),
    .snpslv_l2db3_transfer_type_o        (snpslv_l2db3_transfer_type[2:0]),
    .snpslv_l2db3_transfer_info_o        (snpslv_l2db3_transfer_info[28:0]),
    .snpslv_l2db3_release_o              (snpslv_l2db3_release),
    .snpslv_l2db4_invalidate_o           (snpslv_l2db4_invalidate),
    .snpslv_l2db4_makeshared_o           (snpslv_l2db4_makeshared),
    .snpslv_l2db4_transfer_o             (snpslv_l2db4_transfer),
    .snpslv_l2db4_transfer_type_o        (snpslv_l2db4_transfer_type[2:0]),
    .snpslv_l2db4_transfer_info_o        (snpslv_l2db4_transfer_info[28:0]),
    .snpslv_l2db4_release_o              (snpslv_l2db4_release),
    .snpslv_l2db5_invalidate_o           (snpslv_l2db5_invalidate),
    .snpslv_l2db5_makeshared_o           (snpslv_l2db5_makeshared),
    .snpslv_l2db5_transfer_o             (snpslv_l2db5_transfer),
    .snpslv_l2db5_transfer_type_o        (snpslv_l2db5_transfer_type[2:0]),
    .snpslv_l2db5_transfer_info_o        (snpslv_l2db5_transfer_info[28:0]),
    .snpslv_l2db5_release_o              (snpslv_l2db5_release),
    .snpslv_l2db6_invalidate_o           (snpslv_l2db6_invalidate),
    .snpslv_l2db6_makeshared_o           (snpslv_l2db6_makeshared),
    .snpslv_l2db6_transfer_o             (snpslv_l2db6_transfer),
    .snpslv_l2db6_transfer_type_o        (snpslv_l2db6_transfer_type[2:0]),
    .snpslv_l2db6_transfer_info_o        (snpslv_l2db6_transfer_info[28:0]),
    .snpslv_l2db6_release_o              (snpslv_l2db6_release),
    .snpslv_l2db7_invalidate_o           (snpslv_l2db7_invalidate),
    .snpslv_l2db7_makeshared_o           (snpslv_l2db7_makeshared),
    .snpslv_l2db7_transfer_o             (snpslv_l2db7_transfer),
    .snpslv_l2db7_transfer_type_o        (snpslv_l2db7_transfer_type[2:0]),
    .snpslv_l2db7_transfer_info_o        (snpslv_l2db7_transfer_info[28:0]),
    .snpslv_l2db7_release_o              (snpslv_l2db7_release),
    .snpslv_l2db8_invalidate_o           (snpslv_l2db8_invalidate),
    .snpslv_l2db8_makeshared_o           (snpslv_l2db8_makeshared),
    .snpslv_l2db8_transfer_o             (snpslv_l2db8_transfer),
    .snpslv_l2db8_transfer_type_o        (snpslv_l2db8_transfer_type[2:0]),
    .snpslv_l2db8_transfer_info_o        (snpslv_l2db8_transfer_info[28:0]),
    .snpslv_l2db8_release_o              (snpslv_l2db8_release),
    .snpslv_l2db9_invalidate_o           (snpslv_l2db9_invalidate),
    .snpslv_l2db9_makeshared_o           (snpslv_l2db9_makeshared),
    .snpslv_l2db9_transfer_o             (snpslv_l2db9_transfer),
    .snpslv_l2db9_transfer_type_o        (snpslv_l2db9_transfer_type[2:0]),
    .snpslv_l2db9_transfer_info_o        (snpslv_l2db9_transfer_info[28:0]),
    .snpslv_l2db9_release_o              (snpslv_l2db9_release),
    .snpslv_l2db10_invalidate_o          (snpslv_l2db10_invalidate),
    .snpslv_l2db10_makeshared_o          (snpslv_l2db10_makeshared),
    .snpslv_l2db10_transfer_o            (snpslv_l2db10_transfer),
    .snpslv_l2db10_transfer_type_o       (snpslv_l2db10_transfer_type[2:0]),
    .snpslv_l2db10_transfer_info_o       (snpslv_l2db10_transfer_info[28:0]),
    .snpslv_l2db10_release_o             (snpslv_l2db10_release),
    .snpslv_sample_waddrs_o              (snpslv_sample_waddrs),
    .scu_cpu0_dvm_complete_o             (scu_cpu0_dvm_complete_o),
    .scu_cpu1_dvm_complete_o             (scu_cpu1_dvm_complete_o),
    .scu_cpu2_dvm_complete_o             (scu_cpu2_dvm_complete_o),
    .scu_cpu3_dvm_complete_o             (scu_cpu3_dvm_complete_o)
  );  // u_scu_snpslv

  ca53scu_tagctl #(`CA53_SCU_INT_PARAM_INST) u_scu_tagctl (
    /*ARMAUTO*/
    // Inputs
    .CLKIN                                 (CLKIN),
    .clk                                   (clk),
    .reset_n                               (reset_n),
    .DFTSE                                 (DFTSE),
    .DFTRAMHOLD                            (DFTRAMHOLD),
    .gov_l2teien_i                         (gov_l2teien_i),
    .config_l1_dc_size_i                   (config_l1_dc_size[`CA53_L1DC_SIZE_W-1:0]),
    .config_l2_size_i                      (config_l2_size[`CA53_L2_SIZE_W-1:0]),
    .l1d_tagram_cpu0_way0_rdata_i          (l1d_tagram_cpu0_way0_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu0_way1_rdata_i          (l1d_tagram_cpu0_way1_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu0_way2_rdata_i          (l1d_tagram_cpu0_way2_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu0_way3_rdata_i          (l1d_tagram_cpu0_way3_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu1_way0_rdata_i          (l1d_tagram_cpu1_way0_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu1_way1_rdata_i          (l1d_tagram_cpu1_way1_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu1_way2_rdata_i          (l1d_tagram_cpu1_way2_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu1_way3_rdata_i          (l1d_tagram_cpu1_way3_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu2_way0_rdata_i          (l1d_tagram_cpu2_way0_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu2_way1_rdata_i          (l1d_tagram_cpu2_way1_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu2_way2_rdata_i          (l1d_tagram_cpu2_way2_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu2_way3_rdata_i          (l1d_tagram_cpu2_way3_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu3_way0_rdata_i          (l1d_tagram_cpu3_way0_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu3_way1_rdata_i          (l1d_tagram_cpu3_way1_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu3_way2_rdata_i          (l1d_tagram_cpu3_way2_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu3_way3_rdata_i          (l1d_tagram_cpu3_way3_rdata_i[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way0_rdata_i                (l2_tagram_way0_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way1_rdata_i                (l2_tagram_way1_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way2_rdata_i                (l2_tagram_way2_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way3_rdata_i                (l2_tagram_way3_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way4_rdata_i                (l2_tagram_way4_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way5_rdata_i                (l2_tagram_way5_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way6_rdata_i                (l2_tagram_way6_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way7_rdata_i                (l2_tagram_way7_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way8_rdata_i                (l2_tagram_way8_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way9_rdata_i                (l2_tagram_way9_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way10_rdata_i               (l2_tagram_way10_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way11_rdata_i               (l2_tagram_way11_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way12_rdata_i               (l2_tagram_way12_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way13_rdata_i               (l2_tagram_way13_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way14_rdata_i               (l2_tagram_way14_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .l2_tagram_way15_rdata_i               (l2_tagram_way15_rdata_i[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .leaving_reset_i                       (leaving_reset),
    .config_l2rstdisable_i                 (config_l2rstdisable),
    .config_broadcastinner_i               (config_broadcastinner),
    .config_broadcastouter_i               (config_broadcastouter),
    .config_broadcastcachemaint_i          (config_broadcastcachemaint),
    .gov_disable_evict_i                   (gov_disable_evict_i),
    .gov_enable_writeevict_i               (gov_enable_writeevict_i),
    .gov_l2_in_retention_i                 (gov_l2_in_retention_i),
    .gov_cpu0_smp_en_i                     (gov_cpu0_smp_en_i),
    .gov_cpu1_smp_en_i                     (gov_cpu1_smp_en_i),
    .gov_cpu2_smp_en_i                     (gov_cpu2_smp_en_i),
    .gov_cpu3_smp_en_i                     (gov_cpu3_smp_en_i),
    .cpuslv0_wfx_active_i                  (cpuslv0_wfx_active),
    .cpuslv1_wfx_active_i                  (cpuslv1_wfx_active),
    .cpuslv2_wfx_active_i                  (cpuslv2_wfx_active),
    .cpuslv3_wfx_active_i                  (cpuslv3_wfx_active),
    .cpuslv0_active_i                      (cpuslv0_active),
    .cpuslv1_active_i                      (cpuslv1_active),
    .cpuslv2_active_i                      (cpuslv2_active),
    .cpuslv3_active_i                      (cpuslv3_active),
    .acpslv_active_i                       (acpslv_active),
    .snpslv_active_i                       (snpslv_active),
    .l2_reached_retention_i                (l2_reached_retention),
    .cpuslv0_tagctl_valid_tc0_i            (cpuslv0_tagctl_valid_tc0),
    .cpuslv0_tagctl_early_valid_tc0_i      (cpuslv0_tagctl_early_valid_tc0),
    .cpuslv0_tagctl_spec_valid_tc0_i       (cpuslv0_tagctl_spec_valid_tc0),
    .cpuslv0_tagctl_reqbufid_tc0_i         (cpuslv0_tagctl_reqbufid_tc0[2:0]),
    .cpuslv0_tagctl_pass_tc0_i             (cpuslv0_tagctl_pass_tc0[3:0]),
    .cpuslv0_tagctl_addr1_tc0_i            (cpuslv0_tagctl_addr1_tc0[40:0]),
    .cpuslv0_tagctl_dvm_sync_tc0_i         (cpuslv0_tagctl_dvm_sync_tc0),
    .cpuslv0_tagctl_wr_state_tc0_i         (cpuslv0_tagctl_wr_state_tc0[16:0]),
    .cpuslv0_tagctl_ecc_tc0_i              (cpuslv0_tagctl_ecc_tc0[34:0]),
    .cpuslv0_tagctl_ways_tc0_i             (cpuslv0_tagctl_ways_tc0[31:0]),
    .cpuslv0_tagctl_write_tc0_i            (cpuslv0_tagctl_write_tc0[4:0]),
    .cpuslv0_tagctl_type_tc0_i             (cpuslv0_tagctl_type_tc0[4:0]),
    .cpuslv0_tagctl_l2flushreq_tc0_i       (cpuslv0_tagctl_l2flushreq_tc0),
    .cpuslv0_tagctl_reqbuf_dcu_tc1_i       (cpuslv0_tagctl_reqbuf_dcu_tc1),
    .cpuslv0_tagctl_addr2_tc1_i            (cpuslv0_tagctl_addr2_tc1[40:0]),
    .cpuslv0_tagctl_len_tc1_i              (cpuslv0_tagctl_len_tc1[1:0]),
    .cpuslv0_tagctl_size_tc1_i             (cpuslv0_tagctl_size_tc1[2:0]),
    .cpuslv0_tagctl_lock_tc1_i             (cpuslv0_tagctl_lock_tc1),
    .cpuslv0_tagctl_dirty_tc1_i            (cpuslv0_tagctl_dirty_tc1),
    .cpuslv0_tagctl_cluster_unique_tc1_i   (cpuslv0_tagctl_cluster_unique_tc1),
    .cpuslv0_tagctl_attrs_tc1_i            (cpuslv0_tagctl_attrs_tc1[7:0]),
    .cpuslv0_tagctl_prot_tc1_i             (cpuslv0_tagctl_prot_tc1[1:0]),
    .cpuslv0_tagctl_l2db_tc1_i             (cpuslv0_tagctl_l2db_tc1[3:0]),
    .cpuslv0_tagctl_l2db_full_tc1_i        (cpuslv0_tagctl_l2db_full_tc1),
    .cpuslv0_tagctl_static_pcredit_tc1_i   (cpuslv0_tagctl_static_pcredit_tc1),
    .cpuslv0_tagctl_pcrdtype_tc1_i         (cpuslv0_tagctl_pcrdtype_tc1[1:0]),
    .cpuslv0_tagctl_victim_way_tc1_i       (cpuslv0_tagctl_victim_way_tc1[3:0]),
    .cpuslv0_inv_all_starting_i            (cpuslv0_inv_all_starting),
    .cpuslv1_tagctl_valid_tc0_i            (cpuslv1_tagctl_valid_tc0),
    .cpuslv1_tagctl_early_valid_tc0_i      (cpuslv1_tagctl_early_valid_tc0),
    .cpuslv1_tagctl_spec_valid_tc0_i       (cpuslv1_tagctl_spec_valid_tc0),
    .cpuslv1_tagctl_reqbufid_tc0_i         (cpuslv1_tagctl_reqbufid_tc0[2:0]),
    .cpuslv1_tagctl_pass_tc0_i             (cpuslv1_tagctl_pass_tc0[3:0]),
    .cpuslv1_tagctl_addr1_tc0_i            (cpuslv1_tagctl_addr1_tc0[40:0]),
    .cpuslv1_tagctl_dvm_sync_tc0_i         (cpuslv1_tagctl_dvm_sync_tc0),
    .cpuslv1_tagctl_wr_state_tc0_i         (cpuslv1_tagctl_wr_state_tc0[16:0]),
    .cpuslv1_tagctl_ecc_tc0_i              (cpuslv1_tagctl_ecc_tc0[34:0]),
    .cpuslv1_tagctl_ways_tc0_i             (cpuslv1_tagctl_ways_tc0[31:0]),
    .cpuslv1_tagctl_write_tc0_i            (cpuslv1_tagctl_write_tc0[4:0]),
    .cpuslv1_tagctl_type_tc0_i             (cpuslv1_tagctl_type_tc0[4:0]),
    .cpuslv1_tagctl_l2flushreq_tc0_i       (cpuslv1_tagctl_l2flushreq_tc0),
    .cpuslv1_tagctl_reqbuf_dcu_tc1_i       (cpuslv1_tagctl_reqbuf_dcu_tc1),
    .cpuslv1_tagctl_addr2_tc1_i            (cpuslv1_tagctl_addr2_tc1[40:0]),
    .cpuslv1_tagctl_len_tc1_i              (cpuslv1_tagctl_len_tc1[1:0]),
    .cpuslv1_tagctl_size_tc1_i             (cpuslv1_tagctl_size_tc1[2:0]),
    .cpuslv1_tagctl_lock_tc1_i             (cpuslv1_tagctl_lock_tc1),
    .cpuslv1_tagctl_dirty_tc1_i            (cpuslv1_tagctl_dirty_tc1),
    .cpuslv1_tagctl_cluster_unique_tc1_i   (cpuslv1_tagctl_cluster_unique_tc1),
    .cpuslv1_tagctl_attrs_tc1_i            (cpuslv1_tagctl_attrs_tc1[7:0]),
    .cpuslv1_tagctl_prot_tc1_i             (cpuslv1_tagctl_prot_tc1[1:0]),
    .cpuslv1_tagctl_l2db_tc1_i             (cpuslv1_tagctl_l2db_tc1[3:0]),
    .cpuslv1_tagctl_l2db_full_tc1_i        (cpuslv1_tagctl_l2db_full_tc1),
    .cpuslv1_tagctl_static_pcredit_tc1_i   (cpuslv1_tagctl_static_pcredit_tc1),
    .cpuslv1_tagctl_pcrdtype_tc1_i         (cpuslv1_tagctl_pcrdtype_tc1[1:0]),
    .cpuslv1_tagctl_victim_way_tc1_i       (cpuslv1_tagctl_victim_way_tc1[3:0]),
    .cpuslv1_inv_all_starting_i            (cpuslv1_inv_all_starting),
    .cpuslv2_tagctl_valid_tc0_i            (cpuslv2_tagctl_valid_tc0),
    .cpuslv2_tagctl_early_valid_tc0_i      (cpuslv2_tagctl_early_valid_tc0),
    .cpuslv2_tagctl_spec_valid_tc0_i       (cpuslv2_tagctl_spec_valid_tc0),
    .cpuslv2_tagctl_reqbufid_tc0_i         (cpuslv2_tagctl_reqbufid_tc0[2:0]),
    .cpuslv2_tagctl_pass_tc0_i             (cpuslv2_tagctl_pass_tc0[3:0]),
    .cpuslv2_tagctl_addr1_tc0_i            (cpuslv2_tagctl_addr1_tc0[40:0]),
    .cpuslv2_tagctl_dvm_sync_tc0_i         (cpuslv2_tagctl_dvm_sync_tc0),
    .cpuslv2_tagctl_wr_state_tc0_i         (cpuslv2_tagctl_wr_state_tc0[16:0]),
    .cpuslv2_tagctl_ecc_tc0_i              (cpuslv2_tagctl_ecc_tc0[34:0]),
    .cpuslv2_tagctl_ways_tc0_i             (cpuslv2_tagctl_ways_tc0[31:0]),
    .cpuslv2_tagctl_write_tc0_i            (cpuslv2_tagctl_write_tc0[4:0]),
    .cpuslv2_tagctl_type_tc0_i             (cpuslv2_tagctl_type_tc0[4:0]),
    .cpuslv2_tagctl_l2flushreq_tc0_i       (cpuslv2_tagctl_l2flushreq_tc0),
    .cpuslv2_tagctl_reqbuf_dcu_tc1_i       (cpuslv2_tagctl_reqbuf_dcu_tc1),
    .cpuslv2_tagctl_addr2_tc1_i            (cpuslv2_tagctl_addr2_tc1[40:0]),
    .cpuslv2_tagctl_len_tc1_i              (cpuslv2_tagctl_len_tc1[1:0]),
    .cpuslv2_tagctl_size_tc1_i             (cpuslv2_tagctl_size_tc1[2:0]),
    .cpuslv2_tagctl_lock_tc1_i             (cpuslv2_tagctl_lock_tc1),
    .cpuslv2_tagctl_dirty_tc1_i            (cpuslv2_tagctl_dirty_tc1),
    .cpuslv2_tagctl_cluster_unique_tc1_i   (cpuslv2_tagctl_cluster_unique_tc1),
    .cpuslv2_tagctl_attrs_tc1_i            (cpuslv2_tagctl_attrs_tc1[7:0]),
    .cpuslv2_tagctl_prot_tc1_i             (cpuslv2_tagctl_prot_tc1[1:0]),
    .cpuslv2_tagctl_l2db_tc1_i             (cpuslv2_tagctl_l2db_tc1[3:0]),
    .cpuslv2_tagctl_l2db_full_tc1_i        (cpuslv2_tagctl_l2db_full_tc1),
    .cpuslv2_tagctl_static_pcredit_tc1_i   (cpuslv2_tagctl_static_pcredit_tc1),
    .cpuslv2_tagctl_pcrdtype_tc1_i         (cpuslv2_tagctl_pcrdtype_tc1[1:0]),
    .cpuslv2_tagctl_victim_way_tc1_i       (cpuslv2_tagctl_victim_way_tc1[3:0]),
    .cpuslv2_inv_all_starting_i            (cpuslv2_inv_all_starting),
    .cpuslv3_tagctl_valid_tc0_i            (cpuslv3_tagctl_valid_tc0),
    .cpuslv3_tagctl_early_valid_tc0_i      (cpuslv3_tagctl_early_valid_tc0),
    .cpuslv3_tagctl_spec_valid_tc0_i       (cpuslv3_tagctl_spec_valid_tc0),
    .cpuslv3_tagctl_reqbufid_tc0_i         (cpuslv3_tagctl_reqbufid_tc0[2:0]),
    .cpuslv3_tagctl_pass_tc0_i             (cpuslv3_tagctl_pass_tc0[3:0]),
    .cpuslv3_tagctl_addr1_tc0_i            (cpuslv3_tagctl_addr1_tc0[40:0]),
    .cpuslv3_tagctl_dvm_sync_tc0_i         (cpuslv3_tagctl_dvm_sync_tc0),
    .cpuslv3_tagctl_wr_state_tc0_i         (cpuslv3_tagctl_wr_state_tc0[16:0]),
    .cpuslv3_tagctl_ecc_tc0_i              (cpuslv3_tagctl_ecc_tc0[34:0]),
    .cpuslv3_tagctl_ways_tc0_i             (cpuslv3_tagctl_ways_tc0[31:0]),
    .cpuslv3_tagctl_write_tc0_i            (cpuslv3_tagctl_write_tc0[4:0]),
    .cpuslv3_tagctl_type_tc0_i             (cpuslv3_tagctl_type_tc0[4:0]),
    .cpuslv3_tagctl_l2flushreq_tc0_i       (cpuslv3_tagctl_l2flushreq_tc0),
    .cpuslv3_tagctl_reqbuf_dcu_tc1_i       (cpuslv3_tagctl_reqbuf_dcu_tc1),
    .cpuslv3_tagctl_addr2_tc1_i            (cpuslv3_tagctl_addr2_tc1[40:0]),
    .cpuslv3_tagctl_len_tc1_i              (cpuslv3_tagctl_len_tc1[1:0]),
    .cpuslv3_tagctl_size_tc1_i             (cpuslv3_tagctl_size_tc1[2:0]),
    .cpuslv3_tagctl_lock_tc1_i             (cpuslv3_tagctl_lock_tc1),
    .cpuslv3_tagctl_dirty_tc1_i            (cpuslv3_tagctl_dirty_tc1),
    .cpuslv3_tagctl_cluster_unique_tc1_i   (cpuslv3_tagctl_cluster_unique_tc1),
    .cpuslv3_tagctl_attrs_tc1_i            (cpuslv3_tagctl_attrs_tc1[7:0]),
    .cpuslv3_tagctl_prot_tc1_i             (cpuslv3_tagctl_prot_tc1[1:0]),
    .cpuslv3_tagctl_l2db_tc1_i             (cpuslv3_tagctl_l2db_tc1[3:0]),
    .cpuslv3_tagctl_l2db_full_tc1_i        (cpuslv3_tagctl_l2db_full_tc1),
    .cpuslv3_tagctl_static_pcredit_tc1_i   (cpuslv3_tagctl_static_pcredit_tc1),
    .cpuslv3_tagctl_pcrdtype_tc1_i         (cpuslv3_tagctl_pcrdtype_tc1[1:0]),
    .cpuslv3_tagctl_victim_way_tc1_i       (cpuslv3_tagctl_victim_way_tc1[3:0]),
    .cpuslv3_inv_all_starting_i            (cpuslv3_inv_all_starting),
    .acpslv_tagctl_valid_tc0_i             (acpslv_tagctl_valid_tc0),
    .acpslv_tagctl_early_valid_tc0_i       (acpslv_tagctl_early_valid_tc0),
    .acpslv_tagctl_spec_valid_tc0_i        (acpslv_tagctl_spec_valid_tc0),
    .acpslv_tagctl_active_tc0_i            (acpslv_tagctl_active_tc0),
    .acpslv_tagctl_reqbufid_tc0_i          (acpslv_tagctl_reqbufid_tc0[2:0]),
    .acpslv_tagctl_pass_tc0_i              (acpslv_tagctl_pass_tc0[3:0]),
    .acpslv_tagctl_addr1_tc0_i             (acpslv_tagctl_addr1_tc0[40:0]),
    .acpslv_tagctl_wr_state_tc0_i          (acpslv_tagctl_wr_state_tc0[16:0]),
    .acpslv_tagctl_ecc_tc0_i               (acpslv_tagctl_ecc_tc0[34:0]),
    .acpslv_tagctl_ways_tc0_i              (acpslv_tagctl_ways_tc0[31:0]),
    .acpslv_tagctl_write_tc0_i             (acpslv_tagctl_write_tc0[4:0]),
    .acpslv_tagctl_type_tc0_i              (acpslv_tagctl_type_tc0[4:0]),
    .acpslv_tagctl_len_tc1_i               (acpslv_tagctl_len_tc1[1:0]),
    .acpslv_tagctl_single_tc1_i            (acpslv_tagctl_single_tc1),
    .acpslv_tagctl_size_tc1_i              (acpslv_tagctl_size_tc1[2:0]),
    .acpslv_tagctl_dirty_tc1_i             (acpslv_tagctl_dirty_tc1),
    .acpslv_tagctl_cluster_unique_tc1_i    (acpslv_tagctl_cluster_unique_tc1),
    .acpslv_tagctl_attrs_tc1_i             (acpslv_tagctl_attrs_tc1[7:0]),
    .acpslv_tagctl_prot_tc1_i              (acpslv_tagctl_prot_tc1[1:0]),
    .acpslv_tagctl_l2db_tc1_i              (acpslv_tagctl_l2db_tc1[3:0]),
    .acpslv_tagctl_l2db_full_tc1_i         (acpslv_tagctl_l2db_full_tc1),
    .acpslv_tagctl_static_pcredit_tc1_i    (acpslv_tagctl_static_pcredit_tc1),
    .acpslv_tagctl_pcrdtype_tc1_i          (acpslv_tagctl_pcrdtype_tc1[1:0]),
    .acpslv_tagctl_victim_way_tc1_i        (acpslv_tagctl_victim_way_tc1[3:0]),
    .acpslv_tagctl_slverr_tc1_i            (acpslv_tagctl_slverr_tc1),
    .snpslv_tagctl_valid_tc0_i             (snpslv_tagctl_valid_tc0),
    .snpslv_tagctl_early_valid_tc0_i       (snpslv_tagctl_early_valid_tc0),
    .snpslv_tagctl_spec_valid_tc0_i        (snpslv_tagctl_spec_valid_tc0),
    .snpslv_tagctl_active_tc0_i            (snpslv_tagctl_active_tc0),
    .snpslv_tagctl_reqbufid_tc0_i          (snpslv_tagctl_reqbufid_tc0[2:0]),
    .snpslv_tagctl_pass_tc0_i              (snpslv_tagctl_pass_tc0[3:0]),
    .snpslv_tagctl_addr1_tc0_i             (snpslv_tagctl_addr1_tc0[41:0]),
    .snpslv_tagctl_dvm_sync_tc0_i          (snpslv_tagctl_dvm_sync_tc0),
    .snpslv_tagctl_wr_state_tc0_i          (snpslv_tagctl_wr_state_tc0[16:0]),
    .snpslv_tagctl_ecc_tc0_i               (snpslv_tagctl_ecc_tc0[34:0]),
    .snpslv_tagctl_ways_tc0_i              (snpslv_tagctl_ways_tc0[31:0]),
    .snpslv_tagctl_write_tc0_i             (snpslv_tagctl_write_tc0[4:0]),
    .snpslv_tagctl_type_tc0_i              (snpslv_tagctl_type_tc0[4:0]),
    .snpslv_tagctl_addr2_tc1_i             (snpslv_tagctl_addr2_tc1[40:0]),
    .snpslv_tagctl_attrs_tc1_i             (snpslv_tagctl_attrs_tc1[7:0]),
    .snpslv_tagctl_dirty_tc1_i             (snpslv_tagctl_dirty_tc1),
    .snpslv_tagctl_cluster_unique_tc1_i    (snpslv_tagctl_cluster_unique_tc1),
    .snpslv_tagctl_l2db_tc1_i              (snpslv_tagctl_l2db_tc1[3:0]),
    .snpslv_tagctl_static_pcredit_tc1_i    (snpslv_tagctl_static_pcredit_tc1),
    .snpslv_tagctl_pcrdtype_tc1_i          (snpslv_tagctl_pcrdtype_tc1[1:0]),
    .cpuslv0_hz_tc2_i                      (cpuslv0_hz_tc2),
    .cpuslv1_hz_tc2_i                      (cpuslv1_hz_tc2),
    .cpuslv2_hz_tc2_i                      (cpuslv2_hz_tc2),
    .cpuslv3_hz_tc2_i                      (cpuslv3_hz_tc2),
    .acpslv_hz_tc2_i                       (acpslv_hz_tc2),
    .snpslv_hz_tc2_i                       (snpslv_hz_tc2),
    .master_hz_tc2_i                       (master_hz_tc2),
    .master_hz_dev_tc2_i                   (master_hz_dev_tc2),
    .master_hz_l2db_tc2_i                  (master_hz_l2db_tc2),
    .master_hz_dirty_tc2_i                 (master_hz_dirty_tc2),
    .master_hz_cu_tc2_i                    (master_hz_cu_tc2),
    .master_l2db_tc2_i                     (master_l2db_tc2[3:0]),
    .sam_tgtid_tc2_i                       (sam_tgtid_tc2[6:0]),
    .cpuslv0_snp_hz_tc2_i                  (cpuslv0_snp_hz_tc2),
    .cpuslv1_snp_hz_tc2_i                  (cpuslv1_snp_hz_tc2),
    .cpuslv2_snp_hz_tc2_i                  (cpuslv2_snp_hz_tc2),
    .cpuslv3_snp_hz_tc2_i                  (cpuslv3_snp_hz_tc2),
    .cpuslv0_snp_hz_id_tc2_i               (cpuslv0_snp_hz_id_tc2[2:0]),
    .cpuslv1_snp_hz_id_tc2_i               (cpuslv1_snp_hz_id_tc2[2:0]),
    .cpuslv2_snp_hz_id_tc2_i               (cpuslv2_snp_hz_id_tc2[2:0]),
    .cpuslv3_snp_hz_id_tc2_i               (cpuslv3_snp_hz_id_tc2[2:0]),
    .cpuslv0_snp_l2db_hz_tc2_i             (cpuslv0_snp_l2db_hz_tc2),
    .cpuslv1_snp_l2db_hz_tc2_i             (cpuslv1_snp_l2db_hz_tc2),
    .cpuslv2_snp_l2db_hz_tc2_i             (cpuslv2_snp_l2db_hz_tc2),
    .cpuslv3_snp_l2db_hz_tc2_i             (cpuslv3_snp_l2db_hz_tc2),
    .cpuslv0_snp_l2db_dirty_tc2_i          (cpuslv0_snp_l2db_dirty_tc2),
    .cpuslv1_snp_l2db_dirty_tc2_i          (cpuslv1_snp_l2db_dirty_tc2),
    .cpuslv2_snp_l2db_dirty_tc2_i          (cpuslv2_snp_l2db_dirty_tc2),
    .cpuslv3_snp_l2db_dirty_tc2_i          (cpuslv3_snp_l2db_dirty_tc2),
    .cpuslv0_snp_l2db_tc2_i                (cpuslv0_snp_l2db_tc2[3:0]),
    .cpuslv1_snp_l2db_tc2_i                (cpuslv1_snp_l2db_tc2[3:0]),
    .cpuslv2_snp_l2db_tc2_i                (cpuslv2_snp_l2db_tc2[3:0]),
    .cpuslv3_snp_l2db_tc2_i                (cpuslv3_snp_l2db_tc2[3:0]),
    .cpuslv0_ecc_hz_tc2_i                  (cpuslv0_ecc_hz_tc2),
    .cpuslv1_ecc_hz_tc2_i                  (cpuslv1_ecc_hz_tc2),
    .cpuslv2_ecc_hz_tc2_i                  (cpuslv2_ecc_hz_tc2),
    .cpuslv3_ecc_hz_tc2_i                  (cpuslv3_ecc_hz_tc2),
    .snpslv_ecc_hz_tc2_i                   (snpslv_ecc_hz_tc2),
    .cpuslv0_force_miss_tc2_i              (cpuslv0_force_miss_tc2[31:0]),
    .cpuslv1_force_miss_tc2_i              (cpuslv1_force_miss_tc2[31:0]),
    .cpuslv2_force_miss_tc2_i              (cpuslv2_force_miss_tc2[31:0]),
    .cpuslv3_force_miss_tc2_i              (cpuslv3_force_miss_tc2[31:0]),
    .acpslv_force_miss_tc2_i               (acpslv_force_miss_tc2[15:0]),
    .cpuslv0_l2_way_used_tc2_i             (cpuslv0_l2_way_used_tc2[15:0]),
    .cpuslv1_l2_way_used_tc2_i             (cpuslv1_l2_way_used_tc2[15:0]),
    .cpuslv2_l2_way_used_tc2_i             (cpuslv2_l2_way_used_tc2[15:0]),
    .cpuslv3_l2_way_used_tc2_i             (cpuslv3_l2_way_used_tc2[15:0]),
    .acpslv_l2_way_used_tc2_i              (acpslv_l2_way_used_tc2[15:0]),
    .snpslv_l2_way_used_tc2_i              (snpslv_l2_way_used_tc2[15:0]),
    .cpuslv0_hz_tc4_i                      (cpuslv0_hz_tc4),
    .cpuslv1_hz_tc4_i                      (cpuslv1_hz_tc4),
    .cpuslv2_hz_tc4_i                      (cpuslv2_hz_tc4),
    .cpuslv3_hz_tc4_i                      (cpuslv3_hz_tc4),
    .acpslv_hz_tc4_i                       (acpslv_hz_tc4),
    .snpslv_hz_tc4_i                       (snpslv_hz_tc4),
    .master_hz_tc4_i                       (master_hz_tc4),
    .master_ncoh_db_i                      (master_ncoh_db),
    .master_hz_waddr_tc4_i                 (master_hz_waddr_tc4[3:0]),
    .master_waddr_valid_i                  (master_waddr_valid[15:0]),
    .cpuslv0_ac_ready_i                    (cpuslv0_ac_ready),
    .cpuslv0_cr_valid_i                    (cpuslv0_cr_valid),
    .cpuslv0_cr_id_i                       (cpuslv0_cr_id[2:0]),
    .cpuslv0_cr_dirty_i                    (cpuslv0_cr_dirty),
    .cpuslv0_cr_age_i                      (cpuslv0_cr_age),
    .cpuslv0_cr_alloc_i                    (cpuslv0_cr_alloc),
    .cpuslv0_cr_migratory_i                (cpuslv0_cr_migratory),
    .cpuslv1_ac_ready_i                    (cpuslv1_ac_ready),
    .cpuslv1_cr_valid_i                    (cpuslv1_cr_valid),
    .cpuslv1_cr_id_i                       (cpuslv1_cr_id[2:0]),
    .cpuslv1_cr_dirty_i                    (cpuslv1_cr_dirty),
    .cpuslv1_cr_age_i                      (cpuslv1_cr_age),
    .cpuslv1_cr_alloc_i                    (cpuslv1_cr_alloc),
    .cpuslv1_cr_migratory_i                (cpuslv1_cr_migratory),
    .cpuslv2_ac_ready_i                    (cpuslv2_ac_ready),
    .cpuslv2_cr_valid_i                    (cpuslv2_cr_valid),
    .cpuslv2_cr_id_i                       (cpuslv2_cr_id[2:0]),
    .cpuslv2_cr_dirty_i                    (cpuslv2_cr_dirty),
    .cpuslv2_cr_age_i                      (cpuslv2_cr_age),
    .cpuslv2_cr_alloc_i                    (cpuslv2_cr_alloc),
    .cpuslv2_cr_migratory_i                (cpuslv2_cr_migratory),
    .cpuslv3_ac_ready_i                    (cpuslv3_ac_ready),
    .cpuslv3_cr_valid_i                    (cpuslv3_cr_valid),
    .cpuslv3_cr_id_i                       (cpuslv3_cr_id[2:0]),
    .cpuslv3_cr_dirty_i                    (cpuslv3_cr_dirty),
    .cpuslv3_cr_age_i                      (cpuslv3_cr_age),
    .cpuslv3_cr_alloc_i                    (cpuslv3_cr_alloc),
    .cpuslv3_cr_migratory_i                (cpuslv3_cr_migratory),
    .master_afb0_ack_i                     (master_afb0_ack),
    .master_afb1_ack_i                     (master_afb1_ack),
    .master_afb2_ack_i                     (master_afb2_ack),
    .master_afb3_ack_i                     (master_afb3_ack),
    .master_afb4_ack_i                     (master_afb4_ack),
    .master_afb5_ack_i                     (master_afb5_ack),
    .l2db0_tagctl_available_i              (l2db0_tagctl_available),
    .l2db0_tagctl_for_snoop_i              (l2db0_tagctl_for_snoop),
    .l2db0_tagctl_for_write_i              (l2db0_tagctl_for_write),
    .l2db1_tagctl_available_i              (l2db1_tagctl_available),
    .l2db1_tagctl_for_snoop_i              (l2db1_tagctl_for_snoop),
    .l2db1_tagctl_for_write_i              (l2db1_tagctl_for_write),
    .l2db2_tagctl_available_i              (l2db2_tagctl_available),
    .l2db2_tagctl_for_snoop_i              (l2db2_tagctl_for_snoop),
    .l2db2_tagctl_for_write_i              (l2db2_tagctl_for_write),
    .l2db3_tagctl_available_i              (l2db3_tagctl_available),
    .l2db3_tagctl_for_snoop_i              (l2db3_tagctl_for_snoop),
    .l2db3_tagctl_for_write_i              (l2db3_tagctl_for_write),
    .l2db4_tagctl_available_i              (l2db4_tagctl_available),
    .l2db4_tagctl_for_snoop_i              (l2db4_tagctl_for_snoop),
    .l2db4_tagctl_for_write_i              (l2db4_tagctl_for_write),
    .l2db5_tagctl_available_i              (l2db5_tagctl_available),
    .l2db5_tagctl_for_snoop_i              (l2db5_tagctl_for_snoop),
    .l2db5_tagctl_for_write_i              (l2db5_tagctl_for_write),
    .l2db6_tagctl_available_i              (l2db6_tagctl_available),
    .l2db6_tagctl_for_snoop_i              (l2db6_tagctl_for_snoop),
    .l2db6_tagctl_for_write_i              (l2db6_tagctl_for_write),
    .l2db7_tagctl_available_i              (l2db7_tagctl_available),
    .l2db7_tagctl_for_snoop_i              (l2db7_tagctl_for_snoop),
    .l2db7_tagctl_for_write_i              (l2db7_tagctl_for_write),
    .l2db8_tagctl_available_i              (l2db8_tagctl_available),
    .l2db8_tagctl_for_snoop_i              (l2db8_tagctl_for_snoop),
    .l2db8_tagctl_for_write_i              (l2db8_tagctl_for_write),
    .l2db9_tagctl_available_i              (l2db9_tagctl_available),
    .l2db9_tagctl_for_snoop_i              (l2db9_tagctl_for_snoop),
    .l2db9_tagctl_for_write_i              (l2db9_tagctl_for_write),
    .l2db10_tagctl_available_i             (l2db10_tagctl_available),
    .l2db10_tagctl_for_snoop_i             (l2db10_tagctl_for_snoop),
    .l2db10_tagctl_for_write_i             (l2db10_tagctl_for_write),
    .l2db0_slv_done_i                      (l2db0_slv_done),
    .l2db1_slv_done_i                      (l2db1_slv_done),
    .l2db2_slv_done_i                      (l2db2_slv_done),
    .l2db3_slv_done_i                      (l2db3_slv_done),
    .l2db4_slv_done_i                      (l2db4_slv_done),
    .l2db5_slv_done_i                      (l2db5_slv_done),
    .l2db6_slv_done_i                      (l2db6_slv_done),
    .l2db7_slv_done_i                      (l2db7_slv_done),
    .l2db8_slv_done_i                      (l2db8_slv_done),
    .l2db9_slv_done_i                      (l2db9_slv_done),
    .l2db10_slv_done_i                     (l2db10_slv_done),
    .l2db0_rmw_line_i                      (l2db0_rmw_line),
    .l2db1_rmw_line_i                      (l2db1_rmw_line),
    .l2db2_rmw_line_i                      (l2db2_rmw_line),
    .l2db3_rmw_line_i                      (l2db3_rmw_line),
    .l2db4_rmw_line_i                      (l2db4_rmw_line),
    .l2db5_rmw_line_i                      (l2db5_rmw_line),
    .l2db6_rmw_line_i                      (l2db6_rmw_line),
    .l2db7_rmw_line_i                      (l2db7_rmw_line),
    .l2db8_rmw_line_i                      (l2db8_rmw_line),
    .l2db9_rmw_line_i                      (l2db9_rmw_line),
    .l2db10_rmw_line_i                     (l2db10_rmw_line),
    .ramctl_tagctl_ready_i                 (ramctl_tagctl_ready),
    .ramctl_mask_tc2_i                     (ramctl_mask_tc2),
    .dcu_cpu0_dvm_complete_i               (dcu_cpu0_dvm_complete_i),
    .dcu_cpu1_dvm_complete_i               (dcu_cpu1_dvm_complete_i),
    .dcu_cpu2_dvm_complete_i               (dcu_cpu2_dvm_complete_i),
    .dcu_cpu3_dvm_complete_i               (dcu_cpu3_dvm_complete_i),
    .gov_mbistreq_i                        (gov_mbistreq_i),
    .gov_mbistarray0_i                     (gov_mbistarray0_i[`CA53_MBIST0_RAMARRAY_W-1:0]),
    .gov_mbistwriteen0_i                   (gov_mbistwriteen0_i),
    .gov_mbistreaden0_i                    (gov_mbistreaden0_i),
    .gov_mbistaddr0_i                      (gov_mbistaddr0_i[`CA53_MBIST0_ADDR_W-1:0]),
    .gov_mbistbe0_i                        (gov_mbistbe0_i[`CA53_MBIST0_BE_W-1:0]),
    .gov_mbistcfg0_i                       (gov_mbistcfg0_i),
    .gov_mbistindata0_i                    (gov_mbistindata0_i[39:0]),
    // Outputs
    .tagctl_active_o                       (tagctl_active),
    .tagctl_master_active_o                (tagctl_master_active),
    .tagctl_ramctl_active_o                (tagctl_ramctl_active),
    .l1d_tagram_clken_o                    (l1d_tagram_clken_o),
    .l1d_tagram_cpu0_en_o                  (l1d_tagram_cpu0_en_o[`CA53_SCU_L1D_ASSOC-1:0]),
    .l1d_tagram_cpu0_wr_o                  (l1d_tagram_cpu0_wr_o),
    .l1d_tagram_cpu0_addr_o                (l1d_tagram_cpu0_addr_o[`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]),
    .l1d_tagram_cpu0_wdata_o               (l1d_tagram_cpu0_wdata_o[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu1_en_o                  (l1d_tagram_cpu1_en_o[`CA53_SCU_L1D_ASSOC-1:0]),
    .l1d_tagram_cpu1_wr_o                  (l1d_tagram_cpu1_wr_o),
    .l1d_tagram_cpu1_addr_o                (l1d_tagram_cpu1_addr_o[`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]),
    .l1d_tagram_cpu1_wdata_o               (l1d_tagram_cpu1_wdata_o[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu2_en_o                  (l1d_tagram_cpu2_en_o[`CA53_SCU_L1D_ASSOC-1:0]),
    .l1d_tagram_cpu2_wr_o                  (l1d_tagram_cpu2_wr_o),
    .l1d_tagram_cpu2_addr_o                (l1d_tagram_cpu2_addr_o[`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]),
    .l1d_tagram_cpu2_wdata_o               (l1d_tagram_cpu2_wdata_o[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l1d_tagram_cpu3_en_o                  (l1d_tagram_cpu3_en_o[`CA53_SCU_L1D_ASSOC-1:0]),
    .l1d_tagram_cpu3_wr_o                  (l1d_tagram_cpu3_wr_o),
    .l1d_tagram_cpu3_addr_o                (l1d_tagram_cpu3_addr_o[`CA53_SCU_L1D_TAGRAM_ADDR_W-1:0]),
    .l1d_tagram_cpu3_wdata_o               (l1d_tagram_cpu3_wdata_o[`CA53_SCU_L1D_TAGRAM_DATA_W-1:0]),
    .l2_tagram_clken_o                     (l2_tagram_clken_o),
    .l2_tagram_en_o                        (l2_tagram_en_o[`CA53_SCU_L2_ASSOC-1:0]),
    .l2_tagram_wr_o                        (l2_tagram_wr_o),
    .l2_tagram_addr_o                      (l2_tagram_addr_o[`CA53_SCU_L2_TAGRAM_ADDR_W-1:0]),
    .l2_tagram_wdata_o                     (l2_tagram_wdata_o[`CA53_SCU_L2_TAGRAM_DATA_W-1:0]),
    .tagctl_wfx_ready_o                    (tagctl_wfx_ready[3:0]),
    .tagctl_cpuslv0_ready_tc0_o            (tagctl_cpuslv0_ready_tc0),
    .tagctl_cpuslv0_noncoh_only_o          (tagctl_cpuslv0_noncoh_only),
    .tagctl_cpuslv1_ready_tc0_o            (tagctl_cpuslv1_ready_tc0),
    .tagctl_cpuslv1_noncoh_only_o          (tagctl_cpuslv1_noncoh_only),
    .tagctl_cpuslv2_ready_tc0_o            (tagctl_cpuslv2_ready_tc0),
    .tagctl_cpuslv2_noncoh_only_o          (tagctl_cpuslv2_noncoh_only),
    .tagctl_cpuslv3_ready_tc0_o            (tagctl_cpuslv3_ready_tc0),
    .tagctl_cpuslv3_noncoh_only_o          (tagctl_cpuslv3_noncoh_only),
    .tagctl_acpslv_ready_tc0_o             (tagctl_acpslv_ready_tc0),
    .tagctl_acpslv_noncoh_only_o           (tagctl_acpslv_noncoh_only),
    .tagctl_snpslv_ready_tc0_o             (tagctl_snpslv_ready_tc0),
    .tagctl_slv_l2db_tc1_o                 (tagctl_slv_l2db_tc1[3:0]),
    .tagctl_slv_l2db_hit_tc3_o             (tagctl_slv_l2db_hit_tc3),
    .tagctl_slv_l2db_dirty_tc3_o           (tagctl_slv_l2db_dirty_tc3),
    .tagctl_slv_l2db_cu_tc3_o              (tagctl_slv_l2db_cu_tc3),
    .tagctl_slv_l2db_tc4_o                 (tagctl_slv_l2db_tc4[3:0]),
    .tagctl_slv_l2db_tc3_o                 (tagctl_slv_l2db_tc3[3:0]),
    .tagctl_slv_victim_l2db_tc4_o          (tagctl_slv_victim_l2db_tc4[3:0]),
    .tagctl_slv_snp_hz_tc4_o               (tagctl_slv_snp_hz_tc4),
    .tagctl_slv_snp_hz_id_tc4_o            (tagctl_slv_snp_hz_id_tc4[4:0]),
    .tagctl_slv_l2db_invalidated_tc4_o     (tagctl_slv_l2db_invalidated_tc4),
    .tagctl_slv_l2db_cleaned_tc4_o         (tagctl_slv_l2db_cleaned_tc4),
    .tagctl_l1_hit_ways_tc3_o              (tagctl_l1_hit_ways_tc3[15:0]),
    .tagctl_l2_hit_ways_tc3_o              (tagctl_l2_hit_ways_tc3[15:0]),
    .tagctl_l2_dirty_tc3_o                 (tagctl_l2_dirty_tc3),
    .tagctl_l2_alloc_tc3_o                 (tagctl_l2_alloc_tc3),
    .tagctl_shareability_tc3_o             (tagctl_shareability_tc3[1:0]),
    .tagctl_cluster_unique_tc3_o           (tagctl_cluster_unique_tc3),
    .tagctl_l1_victim_cluster_unique_tc3_o (tagctl_l1_victim_cluster_unique_tc3),
    .tagctl_l1_victim_shareability_tc3_o   (tagctl_l1_victim_shareability_tc3[1:0]),
    .tagctl_l2_victim_valid_tc3_o          (tagctl_l2_victim_valid_tc3),
    .tagctl_l2_victim_dirty_tc3_o          (tagctl_l2_victim_dirty_tc3),
    .tagctl_l2_victim_shareability_tc3_o   (tagctl_l2_victim_shareability_tc3[1:0]),
    .tagctl_l2_victim_alloc_tc3_o          (tagctl_l2_victim_alloc_tc3),
    .tagctl_l2_victim_cu_tc3_o             (tagctl_l2_victim_cu_tc3),
    .tagctl_l2_victim_way_tc3_o            (tagctl_l2_victim_way_tc3[3:0]),
    .tagctl_snoop_data_cpu_tc4_o           (tagctl_snoop_data_cpu_tc4[1:0]),
    .tagctl_slv_flush_tc1_o                (tagctl_slv_flush_tc1),
    .tagctl_slv_flush_tc2_o                (tagctl_slv_flush_tc2),
    .tagctl_slv_flush_tc3_o                (tagctl_slv_flush_tc3),
    .tagctl_slv_flush_tc4_o                (tagctl_slv_flush_tc4),
    .tagctl_slv_early_flush_tc4_o          (tagctl_slv_early_flush_tc4),
    .tagctl_ecc_err_tc3_o                  (tagctl_ecc_err_tc3),
    .afb0_done_o                           (afb0_done),
    .afb1_done_o                           (afb1_done),
    .afb2_done_o                           (afb2_done),
    .afb3_done_o                           (afb3_done),
    .afb4_done_o                           (afb4_done),
    .afb5_done_o                           (afb5_done),
    .afb0_snoop_resp_valid_o               (afb0_snoop_resp_valid),
    .afb1_snoop_resp_valid_o               (afb1_snoop_resp_valid),
    .afb2_snoop_resp_valid_o               (afb2_snoop_resp_valid),
    .afb3_snoop_resp_valid_o               (afb3_snoop_resp_valid),
    .afb4_snoop_resp_valid_o               (afb4_snoop_resp_valid),
    .afb5_snoop_resp_valid_o               (afb5_snoop_resp_valid),
    .afb0_snoop_resp_dirty_o               (afb0_snoop_resp_dirty),
    .afb1_snoop_resp_dirty_o               (afb1_snoop_resp_dirty),
    .afb2_snoop_resp_dirty_o               (afb2_snoop_resp_dirty),
    .afb3_snoop_resp_dirty_o               (afb3_snoop_resp_dirty),
    .afb4_snoop_resp_dirty_o               (afb4_snoop_resp_dirty),
    .afb5_snoop_resp_dirty_o               (afb5_snoop_resp_dirty),
    .afb0_snoop_resp_alloc_o               (afb0_snoop_resp_alloc),
    .afb1_snoop_resp_alloc_o               (afb1_snoop_resp_alloc),
    .afb2_snoop_resp_alloc_o               (afb2_snoop_resp_alloc),
    .afb3_snoop_resp_alloc_o               (afb3_snoop_resp_alloc),
    .afb4_snoop_resp_alloc_o               (afb4_snoop_resp_alloc),
    .afb5_snoop_resp_alloc_o               (afb5_snoop_resp_alloc),
    .afb0_snoop_resp_migratory_o           (afb0_snoop_resp_migratory),
    .afb1_snoop_resp_migratory_o           (afb1_snoop_resp_migratory),
    .afb2_snoop_resp_migratory_o           (afb2_snoop_resp_migratory),
    .afb3_snoop_resp_migratory_o           (afb3_snoop_resp_migratory),
    .afb4_snoop_resp_migratory_o           (afb4_snoop_resp_migratory),
    .afb5_snoop_resp_migratory_o           (afb5_snoop_resp_migratory),
    .afb0_snoop_resp_victim_valid_o        (afb0_snoop_resp_victim_valid),
    .afb1_snoop_resp_victim_valid_o        (afb1_snoop_resp_victim_valid),
    .afb2_snoop_resp_victim_valid_o        (afb2_snoop_resp_victim_valid),
    .afb3_snoop_resp_victim_valid_o        (afb3_snoop_resp_victim_valid),
    .afb4_snoop_resp_victim_valid_o        (afb4_snoop_resp_victim_valid),
    .afb5_snoop_resp_victim_valid_o        (afb5_snoop_resp_victim_valid),
    .afb0_snoop_resp_victim_dirty_o        (afb0_snoop_resp_victim_dirty),
    .afb1_snoop_resp_victim_dirty_o        (afb1_snoop_resp_victim_dirty),
    .afb2_snoop_resp_victim_dirty_o        (afb2_snoop_resp_victim_dirty),
    .afb3_snoop_resp_victim_dirty_o        (afb3_snoop_resp_victim_dirty),
    .afb4_snoop_resp_victim_dirty_o        (afb4_snoop_resp_victim_dirty),
    .afb5_snoop_resp_victim_dirty_o        (afb5_snoop_resp_victim_dirty),
    .afb0_snoop_resp_victim_age_o          (afb0_snoop_resp_victim_age),
    .afb1_snoop_resp_victim_age_o          (afb1_snoop_resp_victim_age),
    .afb2_snoop_resp_victim_age_o          (afb2_snoop_resp_victim_age),
    .afb3_snoop_resp_victim_age_o          (afb3_snoop_resp_victim_age),
    .afb4_snoop_resp_victim_age_o          (afb4_snoop_resp_victim_age),
    .afb5_snoop_resp_victim_age_o          (afb5_snoop_resp_victim_age),
    .afb0_snoop_resp_victim_alloc_o        (afb0_snoop_resp_victim_alloc),
    .afb1_snoop_resp_victim_alloc_o        (afb1_snoop_resp_victim_alloc),
    .afb2_snoop_resp_victim_alloc_o        (afb2_snoop_resp_victim_alloc),
    .afb3_snoop_resp_victim_alloc_o        (afb3_snoop_resp_victim_alloc),
    .afb4_snoop_resp_victim_alloc_o        (afb4_snoop_resp_victim_alloc),
    .afb5_snoop_resp_victim_alloc_o        (afb5_snoop_resp_victim_alloc),
    .afb0_write_done_o                     (afb0_write_done),
    .afb1_write_done_o                     (afb1_write_done),
    .afb2_write_done_o                     (afb2_write_done),
    .afb3_write_done_o                     (afb3_write_done),
    .afb4_write_done_o                     (afb4_write_done),
    .afb5_write_done_o                     (afb5_write_done),
    .tagctl_slv_afb_tc1_o                  (tagctl_slv_afb_tc1[2:0]),
    .tagctl_addr_tc1_o                     (tagctl_addr_tc1[41:6]),
    .tagctl_valid_tc1_o                    (tagctl_valid_tc1),
    .tagctl_addr_valid_tc1_o               (tagctl_addr_valid_tc1),
    .tagctl_index_valid_tc1_o              (tagctl_index_valid_tc1),
    .tagctl_l1_set_way_op_tc1_o            (tagctl_l1_set_way_op_tc1),
    .tagctl_l1_lf_tc1_o                    (tagctl_l1_lf_tc1),
    .tagctl_serialising_tc1_o              (tagctl_serialising_tc1),
    .tagctl_ecc_wr_tc1_o                   (tagctl_ecc_wr_tc1),
    .tagctl_ecc_way_tc1_o                  (tagctl_ecc_way_tc1[15:0]),
    .tagctl_snp_sync_tc1_o                 (tagctl_snp_sync_tc1),
    .tagctl_cpu_sync_tc1_o                 (tagctl_cpu_sync_tc1),
    .tagctl_reqbufid_tc1_o                 (tagctl_reqbufid_tc1[5:0]),
    .tagctl_mn_op_tc2_o                    (tagctl_mn_op_tc2),
    .tagctl_sam_addr_tc2_o                 (tagctl_sam_addr_tc2[39:6]),
    .tagctl_addr_tc3_o                     (tagctl_addr_tc3[40:6]),
    .tagctl_addr_valid_tc3_o               (tagctl_addr_valid_tc3),
    .tagctl_reqbufid_tc3_o                 (tagctl_reqbufid_tc3[5:0]),
    .tagctl_noncoh_serialised_tc3_o        (tagctl_noncoh_serialised_tc3),
    .tagctl_cpuslv0_ac_valid_o             (tagctl_cpuslv0_ac_valid),
    .tagctl_cpuslv0_ac_snoop_o             (tagctl_cpuslv0_ac_snoop[3:0]),
    .tagctl_cpuslv0_ac_id_o                (tagctl_cpuslv0_ac_id[2:0]),
    .tagctl_cpuslv0_ac_l2db_id_o           (tagctl_cpuslv0_ac_l2db_id[3:0]),
    .tagctl_cpuslv0_ac_addr_o              (tagctl_cpuslv0_ac_addr[40:0]),
    .tagctl_cpuslv0_ac_way_o               (tagctl_cpuslv0_ac_way[3:0]),
    .tagctl_cpuslv1_ac_valid_o             (tagctl_cpuslv1_ac_valid),
    .tagctl_cpuslv1_ac_snoop_o             (tagctl_cpuslv1_ac_snoop[3:0]),
    .tagctl_cpuslv1_ac_id_o                (tagctl_cpuslv1_ac_id[2:0]),
    .tagctl_cpuslv1_ac_l2db_id_o           (tagctl_cpuslv1_ac_l2db_id[3:0]),
    .tagctl_cpuslv1_ac_addr_o              (tagctl_cpuslv1_ac_addr[40:0]),
    .tagctl_cpuslv1_ac_way_o               (tagctl_cpuslv1_ac_way[3:0]),
    .tagctl_cpuslv2_ac_valid_o             (tagctl_cpuslv2_ac_valid),
    .tagctl_cpuslv2_ac_snoop_o             (tagctl_cpuslv2_ac_snoop[3:0]),
    .tagctl_cpuslv2_ac_id_o                (tagctl_cpuslv2_ac_id[2:0]),
    .tagctl_cpuslv2_ac_l2db_id_o           (tagctl_cpuslv2_ac_l2db_id[3:0]),
    .tagctl_cpuslv2_ac_addr_o              (tagctl_cpuslv2_ac_addr[40:0]),
    .tagctl_cpuslv2_ac_way_o               (tagctl_cpuslv2_ac_way[3:0]),
    .tagctl_cpuslv3_ac_valid_o             (tagctl_cpuslv3_ac_valid),
    .tagctl_cpuslv3_ac_snoop_o             (tagctl_cpuslv3_ac_snoop[3:0]),
    .tagctl_cpuslv3_ac_id_o                (tagctl_cpuslv3_ac_id[2:0]),
    .tagctl_cpuslv3_ac_l2db_id_o           (tagctl_cpuslv3_ac_l2db_id[3:0]),
    .tagctl_cpuslv3_ac_addr_o              (tagctl_cpuslv3_ac_addr[40:0]),
    .tagctl_cpuslv3_ac_way_o               (tagctl_cpuslv3_ac_way[3:0]),
    .tagctl_cpuslv0_snp_active_o           (tagctl_cpuslv0_snp_active),
    .tagctl_cpuslv1_snp_active_o           (tagctl_cpuslv1_snp_active),
    .tagctl_cpuslv2_snp_active_o           (tagctl_cpuslv2_snp_active),
    .tagctl_cpuslv3_snp_active_o           (tagctl_cpuslv3_snp_active),
    .afb0_master_req_o                     (afb0_master_req),
    .afb0_master_flush_o                   (afb0_master_flush),
    .afb0_master_id_o                      (afb0_master_id[6:0]),
    .afb0_master_addr_o                    (afb0_master_addr[40:0]),
    .afb0_master_opcode_o                  (afb0_master_opcode[4:0]),
    .afb0_master_len_o                     (afb0_master_len[1:0]),
    .afb0_master_size_o                    (afb0_master_size[2:0]),
    .afb0_master_lock_o                    (afb0_master_lock),
    .afb0_master_attrs_o                   (afb0_master_attrs[7:0]),
    .afb0_master_prot_o                    (afb0_master_prot[1:0]),
    .afb0_master_tgtid_o                   (afb0_master_tgtid[6:0]),
    .afb0_master_l2db_o                    (afb0_master_l2db[3:0]),
    .afb0_master_static_pcredit_o          (afb0_master_static_pcredit),
    .afb0_master_pcrdtype_o                (afb0_master_pcrdtype[1:0]),
    .afb1_master_req_o                     (afb1_master_req),
    .afb1_master_flush_o                   (afb1_master_flush),
    .afb1_master_id_o                      (afb1_master_id[6:0]),
    .afb1_master_addr_o                    (afb1_master_addr[40:0]),
    .afb1_master_opcode_o                  (afb1_master_opcode[4:0]),
    .afb1_master_len_o                     (afb1_master_len[1:0]),
    .afb1_master_size_o                    (afb1_master_size[2:0]),
    .afb1_master_lock_o                    (afb1_master_lock),
    .afb1_master_attrs_o                   (afb1_master_attrs[7:0]),
    .afb1_master_prot_o                    (afb1_master_prot[1:0]),
    .afb1_master_tgtid_o                   (afb1_master_tgtid[6:0]),
    .afb1_master_l2db_o                    (afb1_master_l2db[3:0]),
    .afb1_master_static_pcredit_o          (afb1_master_static_pcredit),
    .afb1_master_pcrdtype_o                (afb1_master_pcrdtype[1:0]),
    .afb2_master_req_o                     (afb2_master_req),
    .afb2_master_flush_o                   (afb2_master_flush),
    .afb2_master_id_o                      (afb2_master_id[6:0]),
    .afb2_master_addr_o                    (afb2_master_addr[40:0]),
    .afb2_master_opcode_o                  (afb2_master_opcode[4:0]),
    .afb2_master_len_o                     (afb2_master_len[1:0]),
    .afb2_master_size_o                    (afb2_master_size[2:0]),
    .afb2_master_lock_o                    (afb2_master_lock),
    .afb2_master_attrs_o                   (afb2_master_attrs[7:0]),
    .afb2_master_prot_o                    (afb2_master_prot[1:0]),
    .afb2_master_tgtid_o                   (afb2_master_tgtid[6:0]),
    .afb2_master_l2db_o                    (afb2_master_l2db[3:0]),
    .afb2_master_static_pcredit_o          (afb2_master_static_pcredit),
    .afb2_master_pcrdtype_o                (afb2_master_pcrdtype[1:0]),
    .afb3_master_req_o                     (afb3_master_req),
    .afb3_master_flush_o                   (afb3_master_flush),
    .afb3_master_id_o                      (afb3_master_id[6:0]),
    .afb3_master_addr_o                    (afb3_master_addr[40:0]),
    .afb3_master_opcode_o                  (afb3_master_opcode[4:0]),
    .afb3_master_len_o                     (afb3_master_len[1:0]),
    .afb3_master_size_o                    (afb3_master_size[2:0]),
    .afb3_master_lock_o                    (afb3_master_lock),
    .afb3_master_attrs_o                   (afb3_master_attrs[7:0]),
    .afb3_master_prot_o                    (afb3_master_prot[1:0]),
    .afb3_master_tgtid_o                   (afb3_master_tgtid[6:0]),
    .afb3_master_l2db_o                    (afb3_master_l2db[3:0]),
    .afb3_master_static_pcredit_o          (afb3_master_static_pcredit),
    .afb3_master_pcrdtype_o                (afb3_master_pcrdtype[1:0]),
    .afb4_master_req_o                     (afb4_master_req),
    .afb4_master_flush_o                   (afb4_master_flush),
    .afb4_master_id_o                      (afb4_master_id[6:0]),
    .afb4_master_addr_o                    (afb4_master_addr[40:0]),
    .afb4_master_opcode_o                  (afb4_master_opcode[4:0]),
    .afb4_master_len_o                     (afb4_master_len[1:0]),
    .afb4_master_size_o                    (afb4_master_size[2:0]),
    .afb4_master_lock_o                    (afb4_master_lock),
    .afb4_master_attrs_o                   (afb4_master_attrs[7:0]),
    .afb4_master_prot_o                    (afb4_master_prot[1:0]),
    .afb4_master_tgtid_o                   (afb4_master_tgtid[6:0]),
    .afb4_master_l2db_o                    (afb4_master_l2db[3:0]),
    .afb4_master_static_pcredit_o          (afb4_master_static_pcredit),
    .afb4_master_pcrdtype_o                (afb4_master_pcrdtype[1:0]),
    .afb5_master_req_o                     (afb5_master_req),
    .afb5_master_flush_o                   (afb5_master_flush),
    .afb5_master_id_o                      (afb5_master_id[6:0]),
    .afb5_master_addr_o                    (afb5_master_addr[40:0]),
    .afb5_master_opcode_o                  (afb5_master_opcode[4:0]),
    .afb5_master_len_o                     (afb5_master_len[1:0]),
    .afb5_master_size_o                    (afb5_master_size[2:0]),
    .afb5_master_lock_o                    (afb5_master_lock),
    .afb5_master_attrs_o                   (afb5_master_attrs[7:0]),
    .afb5_master_prot_o                    (afb5_master_prot[1:0]),
    .afb5_master_tgtid_o                   (afb5_master_tgtid[6:0]),
    .afb5_master_l2db_o                    (afb5_master_l2db[3:0]),
    .afb5_master_static_pcredit_o          (afb5_master_static_pcredit),
    .afb5_master_pcrdtype_o                (afb5_master_pcrdtype[1:0]),
    .tagctl_err_valid_o                    (tagctl_err_valid),
    .tagctl_err_fatal_o                    (tagctl_err_fatal),
    .tagctl_err_index_o                    (tagctl_err_index[10:0]),
    .tagctl_err_way_o                      (tagctl_err_way[4:0]),
    .tagctl_alloc_for_snoop_o              (tagctl_alloc_for_snoop),
    .tagctl_alloc_for_write_o              (tagctl_alloc_for_write),
    .tagctl_l2db0_alloc_o                  (tagctl_l2db0_alloc),
    .tagctl_l2db0_release_o                (tagctl_l2db0_release),
    .tagctl_l2db0_snoops_done_o            (tagctl_l2db0_snoops_done),
    .tagctl_l2db0_fill_strbs_o             (tagctl_l2db0_fill_strbs),
    .tagctl_l2db1_alloc_o                  (tagctl_l2db1_alloc),
    .tagctl_l2db1_release_o                (tagctl_l2db1_release),
    .tagctl_l2db1_snoops_done_o            (tagctl_l2db1_snoops_done),
    .tagctl_l2db1_fill_strbs_o             (tagctl_l2db1_fill_strbs),
    .tagctl_l2db2_alloc_o                  (tagctl_l2db2_alloc),
    .tagctl_l2db2_release_o                (tagctl_l2db2_release),
    .tagctl_l2db2_snoops_done_o            (tagctl_l2db2_snoops_done),
    .tagctl_l2db2_fill_strbs_o             (tagctl_l2db2_fill_strbs),
    .tagctl_l2db3_alloc_o                  (tagctl_l2db3_alloc),
    .tagctl_l2db3_release_o                (tagctl_l2db3_release),
    .tagctl_l2db3_snoops_done_o            (tagctl_l2db3_snoops_done),
    .tagctl_l2db3_fill_strbs_o             (tagctl_l2db3_fill_strbs),
    .tagctl_l2db4_alloc_o                  (tagctl_l2db4_alloc),
    .tagctl_l2db4_release_o                (tagctl_l2db4_release),
    .tagctl_l2db4_snoops_done_o            (tagctl_l2db4_snoops_done),
    .tagctl_l2db4_fill_strbs_o             (tagctl_l2db4_fill_strbs),
    .tagctl_l2db5_alloc_o                  (tagctl_l2db5_alloc),
    .tagctl_l2db5_release_o                (tagctl_l2db5_release),
    .tagctl_l2db5_snoops_done_o            (tagctl_l2db5_snoops_done),
    .tagctl_l2db5_fill_strbs_o             (tagctl_l2db5_fill_strbs),
    .tagctl_l2db6_alloc_o                  (tagctl_l2db6_alloc),
    .tagctl_l2db6_release_o                (tagctl_l2db6_release),
    .tagctl_l2db6_snoops_done_o            (tagctl_l2db6_snoops_done),
    .tagctl_l2db6_fill_strbs_o             (tagctl_l2db6_fill_strbs),
    .tagctl_l2db7_alloc_o                  (tagctl_l2db7_alloc),
    .tagctl_l2db7_release_o                (tagctl_l2db7_release),
    .tagctl_l2db7_snoops_done_o            (tagctl_l2db7_snoops_done),
    .tagctl_l2db7_fill_strbs_o             (tagctl_l2db7_fill_strbs),
    .tagctl_l2db8_alloc_o                  (tagctl_l2db8_alloc),
    .tagctl_l2db8_release_o                (tagctl_l2db8_release),
    .tagctl_l2db8_snoops_done_o            (tagctl_l2db8_snoops_done),
    .tagctl_l2db8_fill_strbs_o             (tagctl_l2db8_fill_strbs),
    .tagctl_l2db9_alloc_o                  (tagctl_l2db9_alloc),
    .tagctl_l2db9_release_o                (tagctl_l2db9_release),
    .tagctl_l2db9_snoops_done_o            (tagctl_l2db9_snoops_done),
    .tagctl_l2db9_fill_strbs_o             (tagctl_l2db9_fill_strbs),
    .tagctl_l2db10_alloc_o                 (tagctl_l2db10_alloc),
    .tagctl_l2db10_release_o               (tagctl_l2db10_release),
    .tagctl_l2db10_snoops_done_o           (tagctl_l2db10_snoops_done),
    .tagctl_l2db10_fill_strbs_o            (tagctl_l2db10_fill_strbs),
    .afb0_l2dbs_transfer_o                 (afb0_l2dbs_transfer),
    .afb0_l2dbs_id_o                       (afb0_l2dbs_id[3:0]),
    .afb0_l2dbs_transfer_info_o            (afb0_l2dbs_transfer_info[23:0]),
    .afb1_l2dbs_transfer_o                 (afb1_l2dbs_transfer),
    .afb1_l2dbs_id_o                       (afb1_l2dbs_id[3:0]),
    .afb1_l2dbs_transfer_info_o            (afb1_l2dbs_transfer_info[23:0]),
    .afb2_l2dbs_transfer_o                 (afb2_l2dbs_transfer),
    .afb2_l2dbs_id_o                       (afb2_l2dbs_id[3:0]),
    .afb2_l2dbs_transfer_info_o            (afb2_l2dbs_transfer_info[23:0]),
    .afb3_l2dbs_transfer_o                 (afb3_l2dbs_transfer),
    .afb3_l2dbs_id_o                       (afb3_l2dbs_id[3:0]),
    .afb3_l2dbs_transfer_info_o            (afb3_l2dbs_transfer_info[23:0]),
    .afb4_l2dbs_transfer_o                 (afb4_l2dbs_transfer),
    .afb4_l2dbs_id_o                       (afb4_l2dbs_id[3:0]),
    .afb4_l2dbs_transfer_info_o            (afb4_l2dbs_transfer_info[23:0]),
    .afb5_l2dbs_transfer_o                 (afb5_l2dbs_transfer),
    .afb5_l2dbs_id_o                       (afb5_l2dbs_id[3:0]),
    .afb5_l2dbs_transfer_info_o            (afb5_l2dbs_transfer_info[23:0]),
    .tagctl_ramctl_valid_o                 (tagctl_ramctl_valid),
    .tagctl_ramctl_cancel_o                (tagctl_ramctl_cancel),
    .tagctl_ramctl_flush_o                 (tagctl_ramctl_flush),
    .tagctl_ramctl_index_o                 (tagctl_ramctl_index[10:0]),
    .tagctl_ramctl_way_o                   (tagctl_ramctl_way[3:0]),
    .tagctl_ramctl_l2db_o                  (tagctl_ramctl_l2db[3:0]),
    .tagctl_ramctl_crit_chunk_o            (tagctl_ramctl_crit_chunk[1:0]),
    .tagctl_ramctl_banks_o                 (tagctl_ramctl_banks[7:0]),
    .tagctl_l2dataram_req_tc2_o            (tagctl_l2dataram_req_tc2),
    .tagctl_l2dataram_index_o              (tagctl_l2dataram_index[10:0]),
    .tagctl_l2dataram_way_o                (tagctl_l2dataram_way[15:0]),
    .tagctl_l2dataram_banks_o              (tagctl_l2dataram_banks[7:0]),
    .tagctl_dvm_sync_tc3_o                 (tagctl_dvm_sync_tc3),
    .tagctl_snp_dvm_sync_tc4_o             (tagctl_snp_dvm_sync_tc4),
    .tagctl_cpu_dvm_sync_tc4_o             (tagctl_cpu_dvm_sync_tc4[3:0]),
    .tagctl_dvm_complete_o                 (tagctl_dvm_complete[3:0]),
    .tagctl_mbistreq_o                     (tagctl_mbistreq),
    .tagctl_mbist_sel_o                    (tagctl_mbist_sel),
    .tagctl_mbistoutdata_o                 (tagctl_mbistoutdata[39:0])
  );  // u_scu_tagctl

  ca53scu_victimctl #(`CA53_SCU_INT_PARAM_INST) u_scu_victimctl (
    /*ARMAUTO*/
    // Inputs
    .clk                              (clk),
    .reset_n                          (reset_n),
    .DFTSE                            (DFTSE),
    .DFTRAMHOLD                       (DFTRAMHOLD),
    .leaving_reset_i                  (leaving_reset),
    .config_l2rstdisable_i            (config_l2rstdisable),
    .config_l2_size_i                 (config_l2_size[`CA53_L2_SIZE_W-1:0]),
    .gov_l2victim_ctl_i               (gov_l2victim_ctl_i[1:0]),
    .gov_l2_in_retention_i            (gov_l2_in_retention_i),
    .ram_idle_count_max_i             (ram_idle_count_max),
    .l2_victimram_rdata_i             (l2_victimram_rdata_i[`CA53_SCU_L2_VICTIMRAM_DATA_W-1:0]),
    .cpuslv0_victimctl_active_i       (cpuslv0_victimctl_active),
    .cpuslv0_victimctl_valid_i        (cpuslv0_victimctl_valid),
    .cpuslv0_victimctl_index_i        (cpuslv0_victimctl_index[10:0]),
    .cpuslv0_victimctl_wr_i           (cpuslv0_victimctl_wr),
    .cpuslv0_victimctl_age_i          (cpuslv0_victimctl_age),
    .cpuslv0_victimctl_iside_i        (cpuslv0_victimctl_iside),
    .cpuslv0_victimctl_nontemp_i      (cpuslv0_victimctl_nontemp),
    .cpuslv0_victimctl_way_i          (cpuslv0_victimctl_way[3:0]),
    .cpuslv0_victimctl_id_i           (cpuslv0_victimctl_id[2:0]),
    .cpuslv1_victimctl_active_i       (cpuslv1_victimctl_active),
    .cpuslv1_victimctl_valid_i        (cpuslv1_victimctl_valid),
    .cpuslv1_victimctl_index_i        (cpuslv1_victimctl_index[10:0]),
    .cpuslv1_victimctl_wr_i           (cpuslv1_victimctl_wr),
    .cpuslv1_victimctl_age_i          (cpuslv1_victimctl_age),
    .cpuslv1_victimctl_iside_i        (cpuslv1_victimctl_iside),
    .cpuslv1_victimctl_nontemp_i      (cpuslv1_victimctl_nontemp),
    .cpuslv1_victimctl_way_i          (cpuslv1_victimctl_way[3:0]),
    .cpuslv1_victimctl_id_i           (cpuslv1_victimctl_id[2:0]),
    .cpuslv2_victimctl_active_i       (cpuslv2_victimctl_active),
    .cpuslv2_victimctl_valid_i        (cpuslv2_victimctl_valid),
    .cpuslv2_victimctl_index_i        (cpuslv2_victimctl_index[10:0]),
    .cpuslv2_victimctl_wr_i           (cpuslv2_victimctl_wr),
    .cpuslv2_victimctl_age_i          (cpuslv2_victimctl_age),
    .cpuslv2_victimctl_iside_i        (cpuslv2_victimctl_iside),
    .cpuslv2_victimctl_nontemp_i      (cpuslv2_victimctl_nontemp),
    .cpuslv2_victimctl_way_i          (cpuslv2_victimctl_way[3:0]),
    .cpuslv2_victimctl_id_i           (cpuslv2_victimctl_id[2:0]),
    .cpuslv3_victimctl_active_i       (cpuslv3_victimctl_active),
    .cpuslv3_victimctl_valid_i        (cpuslv3_victimctl_valid),
    .cpuslv3_victimctl_index_i        (cpuslv3_victimctl_index[10:0]),
    .cpuslv3_victimctl_wr_i           (cpuslv3_victimctl_wr),
    .cpuslv3_victimctl_age_i          (cpuslv3_victimctl_age),
    .cpuslv3_victimctl_iside_i        (cpuslv3_victimctl_iside),
    .cpuslv3_victimctl_nontemp_i      (cpuslv3_victimctl_nontemp),
    .cpuslv3_victimctl_way_i          (cpuslv3_victimctl_way[3:0]),
    .cpuslv3_victimctl_id_i           (cpuslv3_victimctl_id[2:0]),
    .acpslv_victimctl_active_i        (acpslv_victimctl_active),
    .acpslv_victimctl_valid_i         (acpslv_victimctl_valid),
    .acpslv_victimctl_index_i         (acpslv_victimctl_index[10:0]),
    .acpslv_victimctl_wr_i            (acpslv_victimctl_wr),
    .acpslv_victimctl_age_i           (acpslv_victimctl_age),
    .acpslv_victimctl_way_i           (acpslv_victimctl_way[3:0]),
    .acpslv_victimctl_id_i            (acpslv_victimctl_id[2:0]),
    .cpuslv0_l2_way_used_vc2_i        (cpuslv0_l2_way_used_vc2[15:0]),
    .cpuslv1_l2_way_used_vc2_i        (cpuslv1_l2_way_used_vc2[15:0]),
    .cpuslv2_l2_way_used_vc2_i        (cpuslv2_l2_way_used_vc2[15:0]),
    .cpuslv3_l2_way_used_vc2_i        (cpuslv3_l2_way_used_vc2[15:0]),
    .acpslv_l2_way_used_vc2_i         (acpslv_l2_way_used_vc2[15:0]),
    .snpslv_l2_way_used_vc2_i         (snpslv_l2_way_used_vc2[15:0]),
    .gov_mbistreq_i                   (gov_mbistreq_i),
    .gov_mbistarray0_i                (gov_mbistarray0_i[`CA53_MBIST0_RAMARRAY_W-1:0]),
    .gov_mbistwriteen0_i              (gov_mbistwriteen0_i),
    .gov_mbistreaden0_i               (gov_mbistreaden0_i),
    .gov_mbistaddr0_i                 (gov_mbistaddr0_i[`CA53_MBIST0_ADDR_W-1:0]),
    .gov_mbistbe0_i                   (gov_mbistbe0_i[`CA53_MBIST0_BE_W-1:0]),
    .gov_mbistcfg0_i                  (gov_mbistcfg0_i),
    .gov_mbistindata0_i               (gov_mbistindata0_i[31:0]),
    // Outputs
    .l2_victimram_no_acc_next_cycle_o (l2_victimram_no_acc_next_cycle),
    .l2_victimram_clken_o             (l2_victimram_clken_o),
    .l2_victimram_en_o                (l2_victimram_en),
    .l2_victimram_wr_o                (l2_victimram_wr_o),
    .l2_victimram_strb_o              (l2_victimram_strb_o[`CA53_SCU_L2_VICTIMRAM_STRB_W-1:0]),
    .l2_victimram_addr_o              (l2_victimram_addr_o[`CA53_SCU_L2_VICTIMRAM_ADDR_W-1:0]),
    .l2_victimram_wdata_o             (l2_victimram_wdata_o[`CA53_SCU_L2_VICTIMRAM_DATA_W-1:0]),
    .victimctl_ready_o                (victimctl_ready),
    .victimctl_ready_id_o             (victimctl_ready_id[5:0]),
    .victimctl_ack_o                  (victimctl_ack),
    .victimctl_ack_id_o               (victimctl_ack_id[5:0]),
    .victimctl_victim_way_o           (victimctl_victim_way[3:0]),
    .victimctl_index_vc1_o            (victimctl_index_vc1[10:0]),
    .victimctl_mbist_sel_o            (victimctl_mbist_sel),
    .victimctl_mbistoutdata_o         (victimctl_mbistoutdata[31:0])
  );  // u_scu_victimctl

  ca53scu_l2db #(`CA53_SCU_INT_PARAM_INST, .L2DB_NUM(4'b0000)) u_scu_l2db0 (
    // TEMPLATE s/l2db_/l2db0_/
    /*ARMAUTO*/
    // Inputs
    .CLKIN                           (CLKIN),
    .clk                             (clk),
    .reset_n                         (reset_n),
    .DFTSE                           (DFTSE),
    .tagctl_l2db_alloc_i             (tagctl_l2db0_alloc),
    .tagctl_alloc_for_snoop_i        (tagctl_alloc_for_snoop),
    .tagctl_alloc_for_write_i        (tagctl_alloc_for_write),
    .tagctl_l2db_release_i           (tagctl_l2db0_release),
    .tagctl_l2db_snoops_done_i       (tagctl_l2db0_snoops_done),
    .tagctl_l2db_fill_strbs_i        (tagctl_l2db0_fill_strbs),
    .master_afb0_ack_i               (master_afb0_ack),
    .master_afb1_ack_i               (master_afb1_ack),
    .master_afb2_ack_i               (master_afb2_ack),
    .master_afb3_ack_i               (master_afb3_ack),
    .master_afb4_ack_i               (master_afb4_ack),
    .master_afb5_ack_i               (master_afb5_ack),
    .master_afb_waddr_id_i           (master_afb_waddr_id[3:0]),
    .master_rsp_dbid_valid_i         (master_rsp_dbid_valid),
    .master_rsp_comp_valid_i         (master_rsp_comp_valid),
    .master_rsp_txnid_i              (master_rsp_txnid[6:0]),
    .master_rsp_dbid_i               (master_rsp_dbid[7:0]),
    .master_rsp_srcid_i              (master_rsp_srcid[6:0]),
    .cpuslv0_l2dbs_active_i          (cpuslv0_l2dbs_active),
    .cpuslv0_l2db_transfer_i         (cpuslv0_l2db0_transfer),
    .cpuslv0_l2db_transfer_type_i    (cpuslv0_l2db0_transfer_type[2:0]),
    .cpuslv0_l2db_transfer_info_i    (cpuslv0_l2db0_transfer_info[23:0]),
    .cpuslv0_l2db_release_i          (cpuslv0_l2db0_release),
    .cpuslv1_l2dbs_active_i          (cpuslv1_l2dbs_active),
    .cpuslv1_l2db_transfer_i         (cpuslv1_l2db0_transfer),
    .cpuslv1_l2db_transfer_type_i    (cpuslv1_l2db0_transfer_type[2:0]),
    .cpuslv1_l2db_transfer_info_i    (cpuslv1_l2db0_transfer_info[23:0]),
    .cpuslv1_l2db_release_i          (cpuslv1_l2db0_release),
    .cpuslv2_l2dbs_active_i          (cpuslv2_l2dbs_active),
    .cpuslv2_l2db_transfer_i         (cpuslv2_l2db0_transfer),
    .cpuslv2_l2db_transfer_type_i    (cpuslv2_l2db0_transfer_type[2:0]),
    .cpuslv2_l2db_transfer_info_i    (cpuslv2_l2db0_transfer_info[23:0]),
    .cpuslv2_l2db_release_i          (cpuslv2_l2db0_release),
    .cpuslv3_l2dbs_active_i          (cpuslv3_l2dbs_active),
    .cpuslv3_l2db_transfer_i         (cpuslv3_l2db0_transfer),
    .cpuslv3_l2db_transfer_type_i    (cpuslv3_l2db0_transfer_type[2:0]),
    .cpuslv3_l2db_transfer_info_i    (cpuslv3_l2db0_transfer_info[23:0]),
    .cpuslv3_l2db_release_i          (cpuslv3_l2db0_release),
    .acpslv_l2dbs_active_i           (acpslv_l2dbs_active),
    .acpslv_l2db_transfer_i          (acpslv_l2db0_transfer),
    .acpslv_l2db_transfer_type_i     (acpslv_l2db0_transfer_type[2:0]),
    .acpslv_l2db_transfer_info_i     (acpslv_l2db0_transfer_info[25:0]),
    .acpslv_l2db_release_i           (acpslv_l2db0_release),
    .snpslv_l2dbs_active_i           (snpslv_l2dbs_active),
    .snpslv_l2db_transfer_i          (snpslv_l2db0_transfer),
    .snpslv_l2db_transfer_type_i     (snpslv_l2db0_transfer_type[2:0]),
    .snpslv_l2db_transfer_info_i     (snpslv_l2db0_transfer_info[28:0]),
    .snpslv_l2db_release_i           (snpslv_l2db0_release),
    .snpslv_l2db_invalidate_i        (snpslv_l2db0_invalidate),
    .snpslv_l2db_makeshared_i        (snpslv_l2db0_makeshared),
    .afb0_l2dbs_transfer_i           (afb0_l2dbs_transfer),
    .afb0_l2dbs_id_i                 (afb0_l2dbs_id[3:0]),
    .afb0_l2dbs_transfer_info_i      (afb0_l2dbs_transfer_info[23:0]),
    .afb1_l2dbs_transfer_i           (afb1_l2dbs_transfer),
    .afb1_l2dbs_id_i                 (afb1_l2dbs_id[3:0]),
    .afb1_l2dbs_transfer_info_i      (afb1_l2dbs_transfer_info[23:0]),
    .afb2_l2dbs_transfer_i           (afb2_l2dbs_transfer),
    .afb2_l2dbs_id_i                 (afb2_l2dbs_id[3:0]),
    .afb2_l2dbs_transfer_info_i      (afb2_l2dbs_transfer_info[23:0]),
    .afb3_l2dbs_transfer_i           (afb3_l2dbs_transfer),
    .afb3_l2dbs_id_i                 (afb3_l2dbs_id[3:0]),
    .afb3_l2dbs_transfer_info_i      (afb3_l2dbs_transfer_info[23:0]),
    .afb4_l2dbs_transfer_i           (afb4_l2dbs_transfer),
    .afb4_l2dbs_id_i                 (afb4_l2dbs_id[3:0]),
    .afb4_l2dbs_transfer_info_i      (afb4_l2dbs_transfer_info[23:0]),
    .afb5_l2dbs_transfer_i           (afb5_l2dbs_transfer),
    .afb5_l2dbs_id_i                 (afb5_l2dbs_id[3:0]),
    .afb5_l2dbs_transfer_info_i      (afb5_l2dbs_transfer_info[23:0]),
    .master_l2db_ready_i             (master_l2db0_ready),
    .ramctl_l2db_ready_i             (ramctl_l2db0_ready),
    .cpuslv0_l2db_ready_i            (cpuslv0_l2db0_ready),
    .cpuslv1_l2db_ready_i            (cpuslv1_l2db0_ready),
    .cpuslv2_l2db_ready_i            (cpuslv2_l2db0_ready),
    .cpuslv3_l2db_ready_i            (cpuslv3_l2db0_ready),
    .acpslv_l2db_ready_i             (acpslv_l2db0_ready),
    .master_early_dr_valid_i         (master_early_dr_valid),
    .master_early_dr_id_i            (master_early_dr_id[5:0]),
    .master_early_dr_chunk_i         (master_early_dr_chunk[1:0]),
    .master_early_dr_data_i          (master_early_dr_data[127:0]),
    .ramctl_l2dbs_valid_i            (ramctl_l2dbs_valid),
    .ramctl_l2dbs_id_i               (ramctl_l2dbs_id[3:0]),
    .ramctl_l2dbs_data_i             (ramctl_l2dbs_data[255:0]),
    .ramctl_l2dbs_chunk_i            (ramctl_l2dbs_chunk[1:0]),
    .ramctl_l2dbs_err_i              (ramctl_l2dbs_err),
    .ramctl_l2dbs_last_i             (ramctl_l2dbs_last),
    .ramctl_l2dbs_bypass_i           (ramctl_l2dbs_bypass),
    .ramctl_l2dbs_bypass_id_i        (ramctl_l2dbs_bypass_id[3:0]),
    .ramctl_bypassed_err_i           (ramctl_bypassed_err),
    .cpuslv0_l2dbs_dw_valid_i        (cpuslv0_l2dbs_dw_valid),
    .cpuslv0_l2dbs_dw_id_i           (cpuslv0_l2dbs_dw_id[3:0]),
    .cpuslv0_l2dbs_dw_chunks_valid_i (cpuslv0_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv0_l2dbs_dw_last_i         (cpuslv0_l2dbs_dw_last),
    .cpuslv0_l2dbs_dw_data_i         (cpuslv0_l2dbs_dw_data[255:0]),
    .cpuslv0_l2dbs_dw_strb_i         (cpuslv0_l2dbs_dw_strb[31:0]),
    .cpuslv0_l2dbs_dw_err_i          (cpuslv0_l2dbs_dw_err),
    .cpuslv0_l2dbs_dw_fatal_i        (cpuslv0_l2dbs_dw_fatal),
    .cpuslv1_l2dbs_dw_valid_i        (cpuslv1_l2dbs_dw_valid),
    .cpuslv1_l2dbs_dw_id_i           (cpuslv1_l2dbs_dw_id[3:0]),
    .cpuslv1_l2dbs_dw_chunks_valid_i (cpuslv1_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv1_l2dbs_dw_last_i         (cpuslv1_l2dbs_dw_last),
    .cpuslv1_l2dbs_dw_data_i         (cpuslv1_l2dbs_dw_data[255:0]),
    .cpuslv1_l2dbs_dw_strb_i         (cpuslv1_l2dbs_dw_strb[31:0]),
    .cpuslv1_l2dbs_dw_err_i          (cpuslv1_l2dbs_dw_err),
    .cpuslv1_l2dbs_dw_fatal_i        (cpuslv1_l2dbs_dw_fatal),
    .cpuslv2_l2dbs_dw_valid_i        (cpuslv2_l2dbs_dw_valid),
    .cpuslv2_l2dbs_dw_id_i           (cpuslv2_l2dbs_dw_id[3:0]),
    .cpuslv2_l2dbs_dw_chunks_valid_i (cpuslv2_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv2_l2dbs_dw_last_i         (cpuslv2_l2dbs_dw_last),
    .cpuslv2_l2dbs_dw_data_i         (cpuslv2_l2dbs_dw_data[255:0]),
    .cpuslv2_l2dbs_dw_strb_i         (cpuslv2_l2dbs_dw_strb[31:0]),
    .cpuslv2_l2dbs_dw_err_i          (cpuslv2_l2dbs_dw_err),
    .cpuslv2_l2dbs_dw_fatal_i        (cpuslv2_l2dbs_dw_fatal),
    .cpuslv3_l2dbs_dw_valid_i        (cpuslv3_l2dbs_dw_valid),
    .cpuslv3_l2dbs_dw_id_i           (cpuslv3_l2dbs_dw_id[3:0]),
    .cpuslv3_l2dbs_dw_chunks_valid_i (cpuslv3_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv3_l2dbs_dw_last_i         (cpuslv3_l2dbs_dw_last),
    .cpuslv3_l2dbs_dw_data_i         (cpuslv3_l2dbs_dw_data[255:0]),
    .cpuslv3_l2dbs_dw_strb_i         (cpuslv3_l2dbs_dw_strb[31:0]),
    .cpuslv3_l2dbs_dw_err_i          (cpuslv3_l2dbs_dw_err),
    .cpuslv3_l2dbs_dw_fatal_i        (cpuslv3_l2dbs_dw_fatal),
    .acpslv_l2dbs_dw_valid_i         (acpslv_l2dbs_dw_valid),
    .acpslv_l2dbs_dw_id_i            (acpslv_l2dbs_dw_id[3:0]),
    .acpslv_l2dbs_dw_chunk_i         (acpslv_l2dbs_dw_chunk[1:0]),
    .acpslv_l2dbs_dw_last_i          (acpslv_l2dbs_dw_last),
    .acpslv_l2dbs_dw_data_i          (acpslv_l2dbs_dw_data[127:0]),
    .acpslv_l2dbs_dw_strb_i          (acpslv_l2dbs_dw_strb[15:0]),
    .gov_mbistreq_i                  (gov_mbistreq_i),
    .gov_mbistarray0_i               (gov_mbistarray0_i[8:0]),
    // Outputs
    .l2db_tagctl_available_o         (l2db0_tagctl_available),
    .l2db_tagctl_for_snoop_o         (l2db0_tagctl_for_snoop),
    .l2db_tagctl_for_write_o         (l2db0_tagctl_for_write),
    .l2db_full_line_o                (l2db0_full_line),
    .l2db_rmw_line_o                 (l2db0_rmw_line),
    .l2db_slv_done_o                 (l2db0_slv_done),
    .l2db_snpslv_done_o              (l2db0_snpslv_done),
    .l2db_slv_master_arb_o           (l2db0_slv_master_arb),
    .l2db_master_valid_o             (l2db0_master_valid),
    .l2db_master_id_o                (l2db0_master_id[5:0]),
    .l2db_master_dbid_o              (l2db0_master_dbid[7:0]),
    .l2db_master_tgtid_o             (l2db0_master_tgtid[6:0]),
    .l2db_master_qos_o               (l2db0_master_qos[3:0]),
    .l2db_master_snoop_o             (l2db0_master_snoop),
    .l2db_master_data_o              (l2db0_master_data[127:0]),
    .l2db_master_strb_o              (l2db0_master_strb[15:0]),
    .l2db_master_chunk_o             (l2db0_master_chunk[1:0]),
    .l2db_master_last_o              (l2db0_master_last),
    .l2db_master_opcode_o            (l2db0_master_opcode[2:0]),
    .l2db_master_snpresp_o           (l2db0_master_snpresp[2:0]),
    .l2db_master_len_o               (l2db0_master_len[1:0]),
    .l2db_master_size_o              (l2db0_master_size[2:0]),
    .l2db_master_addr_o              (l2db0_master_addr[5:0]),
    .l2db_master_attrs_o             (l2db0_master_attrs[7:0]),
    .l2db_master_prot_o              (l2db0_master_prot),
    .l2db_master_strex_o             (l2db0_master_strex),
    .l2db_master_unique_o            (l2db0_master_unique),
    .l2db_master_err_o               (l2db0_master_err),
    .l2db_master_invalidated_o       (l2db0_master_invalidated),
    .l2db_master_dirty_o             (l2db0_master_dirty),
    .l2db_ramctl_valid_o             (l2db0_ramctl_valid),
    .l2db_ramctl_rw_o                (l2db0_ramctl_rw[1:0]),
    .l2db_ramctl_index_o             (l2db0_ramctl_index[10:0]),
    .l2db_ramctl_way_o               (l2db0_ramctl_way[3:0]),
    .l2db_ramctl_data_o              (l2db0_ramctl_data[255:0]),
    .l2db_ramctl_banks_o             (l2db0_ramctl_banks[7:0]),
    .l2db_ramctl_err_o               (l2db0_ramctl_err),
    .l2db_slv_valid_o                (l2db0_slv_valid),
    .l2db_slv_id_o                   (l2db0_slv_id[5:0]),
    .l2db_slv_biuid_o                (l2db0_slv_biuid[4:0]),
    .l2db_slv_data_o                 (l2db0_slv_data[127:0]),
    .l2db_slv_chunk_o                (l2db0_slv_chunk[1:0]),
    .l2db_slv_last_o                 (l2db0_slv_last),
    .l2db_slv_bypass_o               (l2db0_slv_bypass),
    .l2db_slv_err_o                  (l2db0_slv_err),
    .l2db_cpuslv0_data_active_o      (l2db0_cpuslv0_data_active),
    .l2db_cpuslv1_data_active_o      (l2db0_cpuslv1_data_active),
    .l2db_cpuslv2_data_active_o      (l2db0_cpuslv2_data_active),
    .l2db_cpuslv3_data_active_o      (l2db0_cpuslv3_data_active)
  );  // u_scu_l2db0

  ca53scu_l2db #(`CA53_SCU_INT_PARAM_INST, .L2DB_NUM(4'b0001)) u_scu_l2db1 (
    // TEMPLATE s/l2db_/l2db1_/
    /*ARMAUTO*/
    // Inputs
    .CLKIN                           (CLKIN),
    .clk                             (clk),
    .reset_n                         (reset_n),
    .DFTSE                           (DFTSE),
    .tagctl_l2db_alloc_i             (tagctl_l2db1_alloc),
    .tagctl_alloc_for_snoop_i        (tagctl_alloc_for_snoop),
    .tagctl_alloc_for_write_i        (tagctl_alloc_for_write),
    .tagctl_l2db_release_i           (tagctl_l2db1_release),
    .tagctl_l2db_snoops_done_i       (tagctl_l2db1_snoops_done),
    .tagctl_l2db_fill_strbs_i        (tagctl_l2db1_fill_strbs),
    .master_afb0_ack_i               (master_afb0_ack),
    .master_afb1_ack_i               (master_afb1_ack),
    .master_afb2_ack_i               (master_afb2_ack),
    .master_afb3_ack_i               (master_afb3_ack),
    .master_afb4_ack_i               (master_afb4_ack),
    .master_afb5_ack_i               (master_afb5_ack),
    .master_afb_waddr_id_i           (master_afb_waddr_id[3:0]),
    .master_rsp_dbid_valid_i         (master_rsp_dbid_valid),
    .master_rsp_comp_valid_i         (master_rsp_comp_valid),
    .master_rsp_txnid_i              (master_rsp_txnid[6:0]),
    .master_rsp_dbid_i               (master_rsp_dbid[7:0]),
    .master_rsp_srcid_i              (master_rsp_srcid[6:0]),
    .cpuslv0_l2dbs_active_i          (cpuslv0_l2dbs_active),
    .cpuslv0_l2db_transfer_i         (cpuslv0_l2db1_transfer),
    .cpuslv0_l2db_transfer_type_i    (cpuslv0_l2db1_transfer_type[2:0]),
    .cpuslv0_l2db_transfer_info_i    (cpuslv0_l2db1_transfer_info[23:0]),
    .cpuslv0_l2db_release_i          (cpuslv0_l2db1_release),
    .cpuslv1_l2dbs_active_i          (cpuslv1_l2dbs_active),
    .cpuslv1_l2db_transfer_i         (cpuslv1_l2db1_transfer),
    .cpuslv1_l2db_transfer_type_i    (cpuslv1_l2db1_transfer_type[2:0]),
    .cpuslv1_l2db_transfer_info_i    (cpuslv1_l2db1_transfer_info[23:0]),
    .cpuslv1_l2db_release_i          (cpuslv1_l2db1_release),
    .cpuslv2_l2dbs_active_i          (cpuslv2_l2dbs_active),
    .cpuslv2_l2db_transfer_i         (cpuslv2_l2db1_transfer),
    .cpuslv2_l2db_transfer_type_i    (cpuslv2_l2db1_transfer_type[2:0]),
    .cpuslv2_l2db_transfer_info_i    (cpuslv2_l2db1_transfer_info[23:0]),
    .cpuslv2_l2db_release_i          (cpuslv2_l2db1_release),
    .cpuslv3_l2dbs_active_i          (cpuslv3_l2dbs_active),
    .cpuslv3_l2db_transfer_i         (cpuslv3_l2db1_transfer),
    .cpuslv3_l2db_transfer_type_i    (cpuslv3_l2db1_transfer_type[2:0]),
    .cpuslv3_l2db_transfer_info_i    (cpuslv3_l2db1_transfer_info[23:0]),
    .cpuslv3_l2db_release_i          (cpuslv3_l2db1_release),
    .acpslv_l2dbs_active_i           (acpslv_l2dbs_active),
    .acpslv_l2db_transfer_i          (acpslv_l2db1_transfer),
    .acpslv_l2db_transfer_type_i     (acpslv_l2db1_transfer_type[2:0]),
    .acpslv_l2db_transfer_info_i     (acpslv_l2db1_transfer_info[25:0]),
    .acpslv_l2db_release_i           (acpslv_l2db1_release),
    .snpslv_l2dbs_active_i           (snpslv_l2dbs_active),
    .snpslv_l2db_transfer_i          (snpslv_l2db1_transfer),
    .snpslv_l2db_transfer_type_i     (snpslv_l2db1_transfer_type[2:0]),
    .snpslv_l2db_transfer_info_i     (snpslv_l2db1_transfer_info[28:0]),
    .snpslv_l2db_release_i           (snpslv_l2db1_release),
    .snpslv_l2db_invalidate_i        (snpslv_l2db1_invalidate),
    .snpslv_l2db_makeshared_i        (snpslv_l2db1_makeshared),
    .afb0_l2dbs_transfer_i           (afb0_l2dbs_transfer),
    .afb0_l2dbs_id_i                 (afb0_l2dbs_id[3:0]),
    .afb0_l2dbs_transfer_info_i      (afb0_l2dbs_transfer_info[23:0]),
    .afb1_l2dbs_transfer_i           (afb1_l2dbs_transfer),
    .afb1_l2dbs_id_i                 (afb1_l2dbs_id[3:0]),
    .afb1_l2dbs_transfer_info_i      (afb1_l2dbs_transfer_info[23:0]),
    .afb2_l2dbs_transfer_i           (afb2_l2dbs_transfer),
    .afb2_l2dbs_id_i                 (afb2_l2dbs_id[3:0]),
    .afb2_l2dbs_transfer_info_i      (afb2_l2dbs_transfer_info[23:0]),
    .afb3_l2dbs_transfer_i           (afb3_l2dbs_transfer),
    .afb3_l2dbs_id_i                 (afb3_l2dbs_id[3:0]),
    .afb3_l2dbs_transfer_info_i      (afb3_l2dbs_transfer_info[23:0]),
    .afb4_l2dbs_transfer_i           (afb4_l2dbs_transfer),
    .afb4_l2dbs_id_i                 (afb4_l2dbs_id[3:0]),
    .afb4_l2dbs_transfer_info_i      (afb4_l2dbs_transfer_info[23:0]),
    .afb5_l2dbs_transfer_i           (afb5_l2dbs_transfer),
    .afb5_l2dbs_id_i                 (afb5_l2dbs_id[3:0]),
    .afb5_l2dbs_transfer_info_i      (afb5_l2dbs_transfer_info[23:0]),
    .master_l2db_ready_i             (master_l2db1_ready),
    .ramctl_l2db_ready_i             (ramctl_l2db1_ready),
    .cpuslv0_l2db_ready_i            (cpuslv0_l2db1_ready),
    .cpuslv1_l2db_ready_i            (cpuslv1_l2db1_ready),
    .cpuslv2_l2db_ready_i            (cpuslv2_l2db1_ready),
    .cpuslv3_l2db_ready_i            (cpuslv3_l2db1_ready),
    .acpslv_l2db_ready_i             (acpslv_l2db1_ready),
    .master_early_dr_valid_i         (master_early_dr_valid),
    .master_early_dr_id_i            (master_early_dr_id[5:0]),
    .master_early_dr_chunk_i         (master_early_dr_chunk[1:0]),
    .master_early_dr_data_i          (master_early_dr_data[127:0]),
    .ramctl_l2dbs_valid_i            (ramctl_l2dbs_valid),
    .ramctl_l2dbs_id_i               (ramctl_l2dbs_id[3:0]),
    .ramctl_l2dbs_data_i             (ramctl_l2dbs_data[255:0]),
    .ramctl_l2dbs_chunk_i            (ramctl_l2dbs_chunk[1:0]),
    .ramctl_l2dbs_err_i              (ramctl_l2dbs_err),
    .ramctl_l2dbs_last_i             (ramctl_l2dbs_last),
    .ramctl_l2dbs_bypass_i           (ramctl_l2dbs_bypass),
    .ramctl_l2dbs_bypass_id_i        (ramctl_l2dbs_bypass_id[3:0]),
    .ramctl_bypassed_err_i           (ramctl_bypassed_err),
    .cpuslv0_l2dbs_dw_valid_i        (cpuslv0_l2dbs_dw_valid),
    .cpuslv0_l2dbs_dw_id_i           (cpuslv0_l2dbs_dw_id[3:0]),
    .cpuslv0_l2dbs_dw_chunks_valid_i (cpuslv0_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv0_l2dbs_dw_last_i         (cpuslv0_l2dbs_dw_last),
    .cpuslv0_l2dbs_dw_data_i         (cpuslv0_l2dbs_dw_data[255:0]),
    .cpuslv0_l2dbs_dw_strb_i         (cpuslv0_l2dbs_dw_strb[31:0]),
    .cpuslv0_l2dbs_dw_err_i          (cpuslv0_l2dbs_dw_err),
    .cpuslv0_l2dbs_dw_fatal_i        (cpuslv0_l2dbs_dw_fatal),
    .cpuslv1_l2dbs_dw_valid_i        (cpuslv1_l2dbs_dw_valid),
    .cpuslv1_l2dbs_dw_id_i           (cpuslv1_l2dbs_dw_id[3:0]),
    .cpuslv1_l2dbs_dw_chunks_valid_i (cpuslv1_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv1_l2dbs_dw_last_i         (cpuslv1_l2dbs_dw_last),
    .cpuslv1_l2dbs_dw_data_i         (cpuslv1_l2dbs_dw_data[255:0]),
    .cpuslv1_l2dbs_dw_strb_i         (cpuslv1_l2dbs_dw_strb[31:0]),
    .cpuslv1_l2dbs_dw_err_i          (cpuslv1_l2dbs_dw_err),
    .cpuslv1_l2dbs_dw_fatal_i        (cpuslv1_l2dbs_dw_fatal),
    .cpuslv2_l2dbs_dw_valid_i        (cpuslv2_l2dbs_dw_valid),
    .cpuslv2_l2dbs_dw_id_i           (cpuslv2_l2dbs_dw_id[3:0]),
    .cpuslv2_l2dbs_dw_chunks_valid_i (cpuslv2_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv2_l2dbs_dw_last_i         (cpuslv2_l2dbs_dw_last),
    .cpuslv2_l2dbs_dw_data_i         (cpuslv2_l2dbs_dw_data[255:0]),
    .cpuslv2_l2dbs_dw_strb_i         (cpuslv2_l2dbs_dw_strb[31:0]),
    .cpuslv2_l2dbs_dw_err_i          (cpuslv2_l2dbs_dw_err),
    .cpuslv2_l2dbs_dw_fatal_i        (cpuslv2_l2dbs_dw_fatal),
    .cpuslv3_l2dbs_dw_valid_i        (cpuslv3_l2dbs_dw_valid),
    .cpuslv3_l2dbs_dw_id_i           (cpuslv3_l2dbs_dw_id[3:0]),
    .cpuslv3_l2dbs_dw_chunks_valid_i (cpuslv3_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv3_l2dbs_dw_last_i         (cpuslv3_l2dbs_dw_last),
    .cpuslv3_l2dbs_dw_data_i         (cpuslv3_l2dbs_dw_data[255:0]),
    .cpuslv3_l2dbs_dw_strb_i         (cpuslv3_l2dbs_dw_strb[31:0]),
    .cpuslv3_l2dbs_dw_err_i          (cpuslv3_l2dbs_dw_err),
    .cpuslv3_l2dbs_dw_fatal_i        (cpuslv3_l2dbs_dw_fatal),
    .acpslv_l2dbs_dw_valid_i         (acpslv_l2dbs_dw_valid),
    .acpslv_l2dbs_dw_id_i            (acpslv_l2dbs_dw_id[3:0]),
    .acpslv_l2dbs_dw_chunk_i         (acpslv_l2dbs_dw_chunk[1:0]),
    .acpslv_l2dbs_dw_last_i          (acpslv_l2dbs_dw_last),
    .acpslv_l2dbs_dw_data_i          (acpslv_l2dbs_dw_data[127:0]),
    .acpslv_l2dbs_dw_strb_i          (acpslv_l2dbs_dw_strb[15:0]),
    .gov_mbistreq_i                  (gov_mbistreq_i),
    .gov_mbistarray0_i               (gov_mbistarray0_i[8:0]),
    // Outputs
    .l2db_tagctl_available_o         (l2db1_tagctl_available),
    .l2db_tagctl_for_snoop_o         (l2db1_tagctl_for_snoop),
    .l2db_tagctl_for_write_o         (l2db1_tagctl_for_write),
    .l2db_full_line_o                (l2db1_full_line),
    .l2db_rmw_line_o                 (l2db1_rmw_line),
    .l2db_slv_done_o                 (l2db1_slv_done),
    .l2db_snpslv_done_o              (l2db1_snpslv_done),
    .l2db_slv_master_arb_o           (l2db1_slv_master_arb),
    .l2db_master_valid_o             (l2db1_master_valid),
    .l2db_master_id_o                (l2db1_master_id[5:0]),
    .l2db_master_dbid_o              (l2db1_master_dbid[7:0]),
    .l2db_master_tgtid_o             (l2db1_master_tgtid[6:0]),
    .l2db_master_qos_o               (l2db1_master_qos[3:0]),
    .l2db_master_snoop_o             (l2db1_master_snoop),
    .l2db_master_data_o              (l2db1_master_data[127:0]),
    .l2db_master_strb_o              (l2db1_master_strb[15:0]),
    .l2db_master_chunk_o             (l2db1_master_chunk[1:0]),
    .l2db_master_last_o              (l2db1_master_last),
    .l2db_master_opcode_o            (l2db1_master_opcode[2:0]),
    .l2db_master_snpresp_o           (l2db1_master_snpresp[2:0]),
    .l2db_master_len_o               (l2db1_master_len[1:0]),
    .l2db_master_size_o              (l2db1_master_size[2:0]),
    .l2db_master_addr_o              (l2db1_master_addr[5:0]),
    .l2db_master_attrs_o             (l2db1_master_attrs[7:0]),
    .l2db_master_prot_o              (l2db1_master_prot),
    .l2db_master_strex_o             (l2db1_master_strex),
    .l2db_master_unique_o            (l2db1_master_unique),
    .l2db_master_err_o               (l2db1_master_err),
    .l2db_master_invalidated_o       (l2db1_master_invalidated),
    .l2db_master_dirty_o             (l2db1_master_dirty),
    .l2db_ramctl_valid_o             (l2db1_ramctl_valid),
    .l2db_ramctl_rw_o                (l2db1_ramctl_rw[1:0]),
    .l2db_ramctl_index_o             (l2db1_ramctl_index[10:0]),
    .l2db_ramctl_way_o               (l2db1_ramctl_way[3:0]),
    .l2db_ramctl_data_o              (l2db1_ramctl_data[255:0]),
    .l2db_ramctl_banks_o             (l2db1_ramctl_banks[7:0]),
    .l2db_ramctl_err_o               (l2db1_ramctl_err),
    .l2db_slv_valid_o                (l2db1_slv_valid),
    .l2db_slv_id_o                   (l2db1_slv_id[5:0]),
    .l2db_slv_biuid_o                (l2db1_slv_biuid[4:0]),
    .l2db_slv_data_o                 (l2db1_slv_data[127:0]),
    .l2db_slv_chunk_o                (l2db1_slv_chunk[1:0]),
    .l2db_slv_last_o                 (l2db1_slv_last),
    .l2db_slv_bypass_o               (l2db1_slv_bypass),
    .l2db_slv_err_o                  (l2db1_slv_err),
    .l2db_cpuslv0_data_active_o      (l2db1_cpuslv0_data_active),
    .l2db_cpuslv1_data_active_o      (l2db1_cpuslv1_data_active),
    .l2db_cpuslv2_data_active_o      (l2db1_cpuslv2_data_active),
    .l2db_cpuslv3_data_active_o      (l2db1_cpuslv3_data_active)
  );  // u_scu_l2db1

  ca53scu_l2db #(`CA53_SCU_INT_PARAM_INST, .L2DB_NUM(4'b0010)) u_scu_l2db2 (
    // TEMPLATE s/l2db_/l2db2_/
    /*ARMAUTO*/
    // Inputs
    .CLKIN                           (CLKIN),
    .clk                             (clk),
    .reset_n                         (reset_n),
    .DFTSE                           (DFTSE),
    .tagctl_l2db_alloc_i             (tagctl_l2db2_alloc),
    .tagctl_alloc_for_snoop_i        (tagctl_alloc_for_snoop),
    .tagctl_alloc_for_write_i        (tagctl_alloc_for_write),
    .tagctl_l2db_release_i           (tagctl_l2db2_release),
    .tagctl_l2db_snoops_done_i       (tagctl_l2db2_snoops_done),
    .tagctl_l2db_fill_strbs_i        (tagctl_l2db2_fill_strbs),
    .master_afb0_ack_i               (master_afb0_ack),
    .master_afb1_ack_i               (master_afb1_ack),
    .master_afb2_ack_i               (master_afb2_ack),
    .master_afb3_ack_i               (master_afb3_ack),
    .master_afb4_ack_i               (master_afb4_ack),
    .master_afb5_ack_i               (master_afb5_ack),
    .master_afb_waddr_id_i           (master_afb_waddr_id[3:0]),
    .master_rsp_dbid_valid_i         (master_rsp_dbid_valid),
    .master_rsp_comp_valid_i         (master_rsp_comp_valid),
    .master_rsp_txnid_i              (master_rsp_txnid[6:0]),
    .master_rsp_dbid_i               (master_rsp_dbid[7:0]),
    .master_rsp_srcid_i              (master_rsp_srcid[6:0]),
    .cpuslv0_l2dbs_active_i          (cpuslv0_l2dbs_active),
    .cpuslv0_l2db_transfer_i         (cpuslv0_l2db2_transfer),
    .cpuslv0_l2db_transfer_type_i    (cpuslv0_l2db2_transfer_type[2:0]),
    .cpuslv0_l2db_transfer_info_i    (cpuslv0_l2db2_transfer_info[23:0]),
    .cpuslv0_l2db_release_i          (cpuslv0_l2db2_release),
    .cpuslv1_l2dbs_active_i          (cpuslv1_l2dbs_active),
    .cpuslv1_l2db_transfer_i         (cpuslv1_l2db2_transfer),
    .cpuslv1_l2db_transfer_type_i    (cpuslv1_l2db2_transfer_type[2:0]),
    .cpuslv1_l2db_transfer_info_i    (cpuslv1_l2db2_transfer_info[23:0]),
    .cpuslv1_l2db_release_i          (cpuslv1_l2db2_release),
    .cpuslv2_l2dbs_active_i          (cpuslv2_l2dbs_active),
    .cpuslv2_l2db_transfer_i         (cpuslv2_l2db2_transfer),
    .cpuslv2_l2db_transfer_type_i    (cpuslv2_l2db2_transfer_type[2:0]),
    .cpuslv2_l2db_transfer_info_i    (cpuslv2_l2db2_transfer_info[23:0]),
    .cpuslv2_l2db_release_i          (cpuslv2_l2db2_release),
    .cpuslv3_l2dbs_active_i          (cpuslv3_l2dbs_active),
    .cpuslv3_l2db_transfer_i         (cpuslv3_l2db2_transfer),
    .cpuslv3_l2db_transfer_type_i    (cpuslv3_l2db2_transfer_type[2:0]),
    .cpuslv3_l2db_transfer_info_i    (cpuslv3_l2db2_transfer_info[23:0]),
    .cpuslv3_l2db_release_i          (cpuslv3_l2db2_release),
    .acpslv_l2dbs_active_i           (acpslv_l2dbs_active),
    .acpslv_l2db_transfer_i          (acpslv_l2db2_transfer),
    .acpslv_l2db_transfer_type_i     (acpslv_l2db2_transfer_type[2:0]),
    .acpslv_l2db_transfer_info_i     (acpslv_l2db2_transfer_info[25:0]),
    .acpslv_l2db_release_i           (acpslv_l2db2_release),
    .snpslv_l2dbs_active_i           (snpslv_l2dbs_active),
    .snpslv_l2db_transfer_i          (snpslv_l2db2_transfer),
    .snpslv_l2db_transfer_type_i     (snpslv_l2db2_transfer_type[2:0]),
    .snpslv_l2db_transfer_info_i     (snpslv_l2db2_transfer_info[28:0]),
    .snpslv_l2db_release_i           (snpslv_l2db2_release),
    .snpslv_l2db_invalidate_i        (snpslv_l2db2_invalidate),
    .snpslv_l2db_makeshared_i        (snpslv_l2db2_makeshared),
    .afb0_l2dbs_transfer_i           (afb0_l2dbs_transfer),
    .afb0_l2dbs_id_i                 (afb0_l2dbs_id[3:0]),
    .afb0_l2dbs_transfer_info_i      (afb0_l2dbs_transfer_info[23:0]),
    .afb1_l2dbs_transfer_i           (afb1_l2dbs_transfer),
    .afb1_l2dbs_id_i                 (afb1_l2dbs_id[3:0]),
    .afb1_l2dbs_transfer_info_i      (afb1_l2dbs_transfer_info[23:0]),
    .afb2_l2dbs_transfer_i           (afb2_l2dbs_transfer),
    .afb2_l2dbs_id_i                 (afb2_l2dbs_id[3:0]),
    .afb2_l2dbs_transfer_info_i      (afb2_l2dbs_transfer_info[23:0]),
    .afb3_l2dbs_transfer_i           (afb3_l2dbs_transfer),
    .afb3_l2dbs_id_i                 (afb3_l2dbs_id[3:0]),
    .afb3_l2dbs_transfer_info_i      (afb3_l2dbs_transfer_info[23:0]),
    .afb4_l2dbs_transfer_i           (afb4_l2dbs_transfer),
    .afb4_l2dbs_id_i                 (afb4_l2dbs_id[3:0]),
    .afb4_l2dbs_transfer_info_i      (afb4_l2dbs_transfer_info[23:0]),
    .afb5_l2dbs_transfer_i           (afb5_l2dbs_transfer),
    .afb5_l2dbs_id_i                 (afb5_l2dbs_id[3:0]),
    .afb5_l2dbs_transfer_info_i      (afb5_l2dbs_transfer_info[23:0]),
    .master_l2db_ready_i             (master_l2db2_ready),
    .ramctl_l2db_ready_i             (ramctl_l2db2_ready),
    .cpuslv0_l2db_ready_i            (cpuslv0_l2db2_ready),
    .cpuslv1_l2db_ready_i            (cpuslv1_l2db2_ready),
    .cpuslv2_l2db_ready_i            (cpuslv2_l2db2_ready),
    .cpuslv3_l2db_ready_i            (cpuslv3_l2db2_ready),
    .acpslv_l2db_ready_i             (acpslv_l2db2_ready),
    .master_early_dr_valid_i         (master_early_dr_valid),
    .master_early_dr_id_i            (master_early_dr_id[5:0]),
    .master_early_dr_chunk_i         (master_early_dr_chunk[1:0]),
    .master_early_dr_data_i          (master_early_dr_data[127:0]),
    .ramctl_l2dbs_valid_i            (ramctl_l2dbs_valid),
    .ramctl_l2dbs_id_i               (ramctl_l2dbs_id[3:0]),
    .ramctl_l2dbs_data_i             (ramctl_l2dbs_data[255:0]),
    .ramctl_l2dbs_chunk_i            (ramctl_l2dbs_chunk[1:0]),
    .ramctl_l2dbs_err_i              (ramctl_l2dbs_err),
    .ramctl_l2dbs_last_i             (ramctl_l2dbs_last),
    .ramctl_l2dbs_bypass_i           (ramctl_l2dbs_bypass),
    .ramctl_l2dbs_bypass_id_i        (ramctl_l2dbs_bypass_id[3:0]),
    .ramctl_bypassed_err_i           (ramctl_bypassed_err),
    .cpuslv0_l2dbs_dw_valid_i        (cpuslv0_l2dbs_dw_valid),
    .cpuslv0_l2dbs_dw_id_i           (cpuslv0_l2dbs_dw_id[3:0]),
    .cpuslv0_l2dbs_dw_chunks_valid_i (cpuslv0_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv0_l2dbs_dw_last_i         (cpuslv0_l2dbs_dw_last),
    .cpuslv0_l2dbs_dw_data_i         (cpuslv0_l2dbs_dw_data[255:0]),
    .cpuslv0_l2dbs_dw_strb_i         (cpuslv0_l2dbs_dw_strb[31:0]),
    .cpuslv0_l2dbs_dw_err_i          (cpuslv0_l2dbs_dw_err),
    .cpuslv0_l2dbs_dw_fatal_i        (cpuslv0_l2dbs_dw_fatal),
    .cpuslv1_l2dbs_dw_valid_i        (cpuslv1_l2dbs_dw_valid),
    .cpuslv1_l2dbs_dw_id_i           (cpuslv1_l2dbs_dw_id[3:0]),
    .cpuslv1_l2dbs_dw_chunks_valid_i (cpuslv1_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv1_l2dbs_dw_last_i         (cpuslv1_l2dbs_dw_last),
    .cpuslv1_l2dbs_dw_data_i         (cpuslv1_l2dbs_dw_data[255:0]),
    .cpuslv1_l2dbs_dw_strb_i         (cpuslv1_l2dbs_dw_strb[31:0]),
    .cpuslv1_l2dbs_dw_err_i          (cpuslv1_l2dbs_dw_err),
    .cpuslv1_l2dbs_dw_fatal_i        (cpuslv1_l2dbs_dw_fatal),
    .cpuslv2_l2dbs_dw_valid_i        (cpuslv2_l2dbs_dw_valid),
    .cpuslv2_l2dbs_dw_id_i           (cpuslv2_l2dbs_dw_id[3:0]),
    .cpuslv2_l2dbs_dw_chunks_valid_i (cpuslv2_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv2_l2dbs_dw_last_i         (cpuslv2_l2dbs_dw_last),
    .cpuslv2_l2dbs_dw_data_i         (cpuslv2_l2dbs_dw_data[255:0]),
    .cpuslv2_l2dbs_dw_strb_i         (cpuslv2_l2dbs_dw_strb[31:0]),
    .cpuslv2_l2dbs_dw_err_i          (cpuslv2_l2dbs_dw_err),
    .cpuslv2_l2dbs_dw_fatal_i        (cpuslv2_l2dbs_dw_fatal),
    .cpuslv3_l2dbs_dw_valid_i        (cpuslv3_l2dbs_dw_valid),
    .cpuslv3_l2dbs_dw_id_i           (cpuslv3_l2dbs_dw_id[3:0]),
    .cpuslv3_l2dbs_dw_chunks_valid_i (cpuslv3_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv3_l2dbs_dw_last_i         (cpuslv3_l2dbs_dw_last),
    .cpuslv3_l2dbs_dw_data_i         (cpuslv3_l2dbs_dw_data[255:0]),
    .cpuslv3_l2dbs_dw_strb_i         (cpuslv3_l2dbs_dw_strb[31:0]),
    .cpuslv3_l2dbs_dw_err_i          (cpuslv3_l2dbs_dw_err),
    .cpuslv3_l2dbs_dw_fatal_i        (cpuslv3_l2dbs_dw_fatal),
    .acpslv_l2dbs_dw_valid_i         (acpslv_l2dbs_dw_valid),
    .acpslv_l2dbs_dw_id_i            (acpslv_l2dbs_dw_id[3:0]),
    .acpslv_l2dbs_dw_chunk_i         (acpslv_l2dbs_dw_chunk[1:0]),
    .acpslv_l2dbs_dw_last_i          (acpslv_l2dbs_dw_last),
    .acpslv_l2dbs_dw_data_i          (acpslv_l2dbs_dw_data[127:0]),
    .acpslv_l2dbs_dw_strb_i          (acpslv_l2dbs_dw_strb[15:0]),
    .gov_mbistreq_i                  (gov_mbistreq_i),
    .gov_mbistarray0_i               (gov_mbistarray0_i[8:0]),
    // Outputs
    .l2db_tagctl_available_o         (l2db2_tagctl_available),
    .l2db_tagctl_for_snoop_o         (l2db2_tagctl_for_snoop),
    .l2db_tagctl_for_write_o         (l2db2_tagctl_for_write),
    .l2db_full_line_o                (l2db2_full_line),
    .l2db_rmw_line_o                 (l2db2_rmw_line),
    .l2db_slv_done_o                 (l2db2_slv_done),
    .l2db_snpslv_done_o              (l2db2_snpslv_done),
    .l2db_slv_master_arb_o           (l2db2_slv_master_arb),
    .l2db_master_valid_o             (l2db2_master_valid),
    .l2db_master_id_o                (l2db2_master_id[5:0]),
    .l2db_master_dbid_o              (l2db2_master_dbid[7:0]),
    .l2db_master_tgtid_o             (l2db2_master_tgtid[6:0]),
    .l2db_master_qos_o               (l2db2_master_qos[3:0]),
    .l2db_master_snoop_o             (l2db2_master_snoop),
    .l2db_master_data_o              (l2db2_master_data[127:0]),
    .l2db_master_strb_o              (l2db2_master_strb[15:0]),
    .l2db_master_chunk_o             (l2db2_master_chunk[1:0]),
    .l2db_master_last_o              (l2db2_master_last),
    .l2db_master_opcode_o            (l2db2_master_opcode[2:0]),
    .l2db_master_snpresp_o           (l2db2_master_snpresp[2:0]),
    .l2db_master_len_o               (l2db2_master_len[1:0]),
    .l2db_master_size_o              (l2db2_master_size[2:0]),
    .l2db_master_addr_o              (l2db2_master_addr[5:0]),
    .l2db_master_attrs_o             (l2db2_master_attrs[7:0]),
    .l2db_master_prot_o              (l2db2_master_prot),
    .l2db_master_strex_o             (l2db2_master_strex),
    .l2db_master_unique_o            (l2db2_master_unique),
    .l2db_master_err_o               (l2db2_master_err),
    .l2db_master_invalidated_o       (l2db2_master_invalidated),
    .l2db_master_dirty_o             (l2db2_master_dirty),
    .l2db_ramctl_valid_o             (l2db2_ramctl_valid),
    .l2db_ramctl_rw_o                (l2db2_ramctl_rw[1:0]),
    .l2db_ramctl_index_o             (l2db2_ramctl_index[10:0]),
    .l2db_ramctl_way_o               (l2db2_ramctl_way[3:0]),
    .l2db_ramctl_data_o              (l2db2_ramctl_data[255:0]),
    .l2db_ramctl_banks_o             (l2db2_ramctl_banks[7:0]),
    .l2db_ramctl_err_o               (l2db2_ramctl_err),
    .l2db_slv_valid_o                (l2db2_slv_valid),
    .l2db_slv_id_o                   (l2db2_slv_id[5:0]),
    .l2db_slv_biuid_o                (l2db2_slv_biuid[4:0]),
    .l2db_slv_data_o                 (l2db2_slv_data[127:0]),
    .l2db_slv_chunk_o                (l2db2_slv_chunk[1:0]),
    .l2db_slv_last_o                 (l2db2_slv_last),
    .l2db_slv_bypass_o               (l2db2_slv_bypass),
    .l2db_slv_err_o                  (l2db2_slv_err),
    .l2db_cpuslv0_data_active_o      (l2db2_cpuslv0_data_active),
    .l2db_cpuslv1_data_active_o      (l2db2_cpuslv1_data_active),
    .l2db_cpuslv2_data_active_o      (l2db2_cpuslv2_data_active),
    .l2db_cpuslv3_data_active_o      (l2db2_cpuslv3_data_active)
  );  // u_scu_l2db2

  ca53scu_l2db #(`CA53_SCU_INT_PARAM_INST, .L2DB_NUM(4'b0011)) u_scu_l2db3 (
    // TEMPLATE s/l2db_/l2db3_/
    /*ARMAUTO*/
    // Inputs
    .CLKIN                           (CLKIN),
    .clk                             (clk),
    .reset_n                         (reset_n),
    .DFTSE                           (DFTSE),
    .tagctl_l2db_alloc_i             (tagctl_l2db3_alloc),
    .tagctl_alloc_for_snoop_i        (tagctl_alloc_for_snoop),
    .tagctl_alloc_for_write_i        (tagctl_alloc_for_write),
    .tagctl_l2db_release_i           (tagctl_l2db3_release),
    .tagctl_l2db_snoops_done_i       (tagctl_l2db3_snoops_done),
    .tagctl_l2db_fill_strbs_i        (tagctl_l2db3_fill_strbs),
    .master_afb0_ack_i               (master_afb0_ack),
    .master_afb1_ack_i               (master_afb1_ack),
    .master_afb2_ack_i               (master_afb2_ack),
    .master_afb3_ack_i               (master_afb3_ack),
    .master_afb4_ack_i               (master_afb4_ack),
    .master_afb5_ack_i               (master_afb5_ack),
    .master_afb_waddr_id_i           (master_afb_waddr_id[3:0]),
    .master_rsp_dbid_valid_i         (master_rsp_dbid_valid),
    .master_rsp_comp_valid_i         (master_rsp_comp_valid),
    .master_rsp_txnid_i              (master_rsp_txnid[6:0]),
    .master_rsp_dbid_i               (master_rsp_dbid[7:0]),
    .master_rsp_srcid_i              (master_rsp_srcid[6:0]),
    .cpuslv0_l2dbs_active_i          (cpuslv0_l2dbs_active),
    .cpuslv0_l2db_transfer_i         (cpuslv0_l2db3_transfer),
    .cpuslv0_l2db_transfer_type_i    (cpuslv0_l2db3_transfer_type[2:0]),
    .cpuslv0_l2db_transfer_info_i    (cpuslv0_l2db3_transfer_info[23:0]),
    .cpuslv0_l2db_release_i          (cpuslv0_l2db3_release),
    .cpuslv1_l2dbs_active_i          (cpuslv1_l2dbs_active),
    .cpuslv1_l2db_transfer_i         (cpuslv1_l2db3_transfer),
    .cpuslv1_l2db_transfer_type_i    (cpuslv1_l2db3_transfer_type[2:0]),
    .cpuslv1_l2db_transfer_info_i    (cpuslv1_l2db3_transfer_info[23:0]),
    .cpuslv1_l2db_release_i          (cpuslv1_l2db3_release),
    .cpuslv2_l2dbs_active_i          (cpuslv2_l2dbs_active),
    .cpuslv2_l2db_transfer_i         (cpuslv2_l2db3_transfer),
    .cpuslv2_l2db_transfer_type_i    (cpuslv2_l2db3_transfer_type[2:0]),
    .cpuslv2_l2db_transfer_info_i    (cpuslv2_l2db3_transfer_info[23:0]),
    .cpuslv2_l2db_release_i          (cpuslv2_l2db3_release),
    .cpuslv3_l2dbs_active_i          (cpuslv3_l2dbs_active),
    .cpuslv3_l2db_transfer_i         (cpuslv3_l2db3_transfer),
    .cpuslv3_l2db_transfer_type_i    (cpuslv3_l2db3_transfer_type[2:0]),
    .cpuslv3_l2db_transfer_info_i    (cpuslv3_l2db3_transfer_info[23:0]),
    .cpuslv3_l2db_release_i          (cpuslv3_l2db3_release),
    .acpslv_l2dbs_active_i           (acpslv_l2dbs_active),
    .acpslv_l2db_transfer_i          (acpslv_l2db3_transfer),
    .acpslv_l2db_transfer_type_i     (acpslv_l2db3_transfer_type[2:0]),
    .acpslv_l2db_transfer_info_i     (acpslv_l2db3_transfer_info[25:0]),
    .acpslv_l2db_release_i           (acpslv_l2db3_release),
    .snpslv_l2dbs_active_i           (snpslv_l2dbs_active),
    .snpslv_l2db_transfer_i          (snpslv_l2db3_transfer),
    .snpslv_l2db_transfer_type_i     (snpslv_l2db3_transfer_type[2:0]),
    .snpslv_l2db_transfer_info_i     (snpslv_l2db3_transfer_info[28:0]),
    .snpslv_l2db_release_i           (snpslv_l2db3_release),
    .snpslv_l2db_invalidate_i        (snpslv_l2db3_invalidate),
    .snpslv_l2db_makeshared_i        (snpslv_l2db3_makeshared),
    .afb0_l2dbs_transfer_i           (afb0_l2dbs_transfer),
    .afb0_l2dbs_id_i                 (afb0_l2dbs_id[3:0]),
    .afb0_l2dbs_transfer_info_i      (afb0_l2dbs_transfer_info[23:0]),
    .afb1_l2dbs_transfer_i           (afb1_l2dbs_transfer),
    .afb1_l2dbs_id_i                 (afb1_l2dbs_id[3:0]),
    .afb1_l2dbs_transfer_info_i      (afb1_l2dbs_transfer_info[23:0]),
    .afb2_l2dbs_transfer_i           (afb2_l2dbs_transfer),
    .afb2_l2dbs_id_i                 (afb2_l2dbs_id[3:0]),
    .afb2_l2dbs_transfer_info_i      (afb2_l2dbs_transfer_info[23:0]),
    .afb3_l2dbs_transfer_i           (afb3_l2dbs_transfer),
    .afb3_l2dbs_id_i                 (afb3_l2dbs_id[3:0]),
    .afb3_l2dbs_transfer_info_i      (afb3_l2dbs_transfer_info[23:0]),
    .afb4_l2dbs_transfer_i           (afb4_l2dbs_transfer),
    .afb4_l2dbs_id_i                 (afb4_l2dbs_id[3:0]),
    .afb4_l2dbs_transfer_info_i      (afb4_l2dbs_transfer_info[23:0]),
    .afb5_l2dbs_transfer_i           (afb5_l2dbs_transfer),
    .afb5_l2dbs_id_i                 (afb5_l2dbs_id[3:0]),
    .afb5_l2dbs_transfer_info_i      (afb5_l2dbs_transfer_info[23:0]),
    .master_l2db_ready_i             (master_l2db3_ready),
    .ramctl_l2db_ready_i             (ramctl_l2db3_ready),
    .cpuslv0_l2db_ready_i            (cpuslv0_l2db3_ready),
    .cpuslv1_l2db_ready_i            (cpuslv1_l2db3_ready),
    .cpuslv2_l2db_ready_i            (cpuslv2_l2db3_ready),
    .cpuslv3_l2db_ready_i            (cpuslv3_l2db3_ready),
    .acpslv_l2db_ready_i             (acpslv_l2db3_ready),
    .master_early_dr_valid_i         (master_early_dr_valid),
    .master_early_dr_id_i            (master_early_dr_id[5:0]),
    .master_early_dr_chunk_i         (master_early_dr_chunk[1:0]),
    .master_early_dr_data_i          (master_early_dr_data[127:0]),
    .ramctl_l2dbs_valid_i            (ramctl_l2dbs_valid),
    .ramctl_l2dbs_id_i               (ramctl_l2dbs_id[3:0]),
    .ramctl_l2dbs_data_i             (ramctl_l2dbs_data[255:0]),
    .ramctl_l2dbs_chunk_i            (ramctl_l2dbs_chunk[1:0]),
    .ramctl_l2dbs_err_i              (ramctl_l2dbs_err),
    .ramctl_l2dbs_last_i             (ramctl_l2dbs_last),
    .ramctl_l2dbs_bypass_i           (ramctl_l2dbs_bypass),
    .ramctl_l2dbs_bypass_id_i        (ramctl_l2dbs_bypass_id[3:0]),
    .ramctl_bypassed_err_i           (ramctl_bypassed_err),
    .cpuslv0_l2dbs_dw_valid_i        (cpuslv0_l2dbs_dw_valid),
    .cpuslv0_l2dbs_dw_id_i           (cpuslv0_l2dbs_dw_id[3:0]),
    .cpuslv0_l2dbs_dw_chunks_valid_i (cpuslv0_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv0_l2dbs_dw_last_i         (cpuslv0_l2dbs_dw_last),
    .cpuslv0_l2dbs_dw_data_i         (cpuslv0_l2dbs_dw_data[255:0]),
    .cpuslv0_l2dbs_dw_strb_i         (cpuslv0_l2dbs_dw_strb[31:0]),
    .cpuslv0_l2dbs_dw_err_i          (cpuslv0_l2dbs_dw_err),
    .cpuslv0_l2dbs_dw_fatal_i        (cpuslv0_l2dbs_dw_fatal),
    .cpuslv1_l2dbs_dw_valid_i        (cpuslv1_l2dbs_dw_valid),
    .cpuslv1_l2dbs_dw_id_i           (cpuslv1_l2dbs_dw_id[3:0]),
    .cpuslv1_l2dbs_dw_chunks_valid_i (cpuslv1_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv1_l2dbs_dw_last_i         (cpuslv1_l2dbs_dw_last),
    .cpuslv1_l2dbs_dw_data_i         (cpuslv1_l2dbs_dw_data[255:0]),
    .cpuslv1_l2dbs_dw_strb_i         (cpuslv1_l2dbs_dw_strb[31:0]),
    .cpuslv1_l2dbs_dw_err_i          (cpuslv1_l2dbs_dw_err),
    .cpuslv1_l2dbs_dw_fatal_i        (cpuslv1_l2dbs_dw_fatal),
    .cpuslv2_l2dbs_dw_valid_i        (cpuslv2_l2dbs_dw_valid),
    .cpuslv2_l2dbs_dw_id_i           (cpuslv2_l2dbs_dw_id[3:0]),
    .cpuslv2_l2dbs_dw_chunks_valid_i (cpuslv2_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv2_l2dbs_dw_last_i         (cpuslv2_l2dbs_dw_last),
    .cpuslv2_l2dbs_dw_data_i         (cpuslv2_l2dbs_dw_data[255:0]),
    .cpuslv2_l2dbs_dw_strb_i         (cpuslv2_l2dbs_dw_strb[31:0]),
    .cpuslv2_l2dbs_dw_err_i          (cpuslv2_l2dbs_dw_err),
    .cpuslv2_l2dbs_dw_fatal_i        (cpuslv2_l2dbs_dw_fatal),
    .cpuslv3_l2dbs_dw_valid_i        (cpuslv3_l2dbs_dw_valid),
    .cpuslv3_l2dbs_dw_id_i           (cpuslv3_l2dbs_dw_id[3:0]),
    .cpuslv3_l2dbs_dw_chunks_valid_i (cpuslv3_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv3_l2dbs_dw_last_i         (cpuslv3_l2dbs_dw_last),
    .cpuslv3_l2dbs_dw_data_i         (cpuslv3_l2dbs_dw_data[255:0]),
    .cpuslv3_l2dbs_dw_strb_i         (cpuslv3_l2dbs_dw_strb[31:0]),
    .cpuslv3_l2dbs_dw_err_i          (cpuslv3_l2dbs_dw_err),
    .cpuslv3_l2dbs_dw_fatal_i        (cpuslv3_l2dbs_dw_fatal),
    .acpslv_l2dbs_dw_valid_i         (acpslv_l2dbs_dw_valid),
    .acpslv_l2dbs_dw_id_i            (acpslv_l2dbs_dw_id[3:0]),
    .acpslv_l2dbs_dw_chunk_i         (acpslv_l2dbs_dw_chunk[1:0]),
    .acpslv_l2dbs_dw_last_i          (acpslv_l2dbs_dw_last),
    .acpslv_l2dbs_dw_data_i          (acpslv_l2dbs_dw_data[127:0]),
    .acpslv_l2dbs_dw_strb_i          (acpslv_l2dbs_dw_strb[15:0]),
    .gov_mbistreq_i                  (gov_mbistreq_i),
    .gov_mbistarray0_i               (gov_mbistarray0_i[8:0]),
    // Outputs
    .l2db_tagctl_available_o         (l2db3_tagctl_available),
    .l2db_tagctl_for_snoop_o         (l2db3_tagctl_for_snoop),
    .l2db_tagctl_for_write_o         (l2db3_tagctl_for_write),
    .l2db_full_line_o                (l2db3_full_line),
    .l2db_rmw_line_o                 (l2db3_rmw_line),
    .l2db_slv_done_o                 (l2db3_slv_done),
    .l2db_snpslv_done_o              (l2db3_snpslv_done),
    .l2db_slv_master_arb_o           (l2db3_slv_master_arb),
    .l2db_master_valid_o             (l2db3_master_valid),
    .l2db_master_id_o                (l2db3_master_id[5:0]),
    .l2db_master_dbid_o              (l2db3_master_dbid[7:0]),
    .l2db_master_tgtid_o             (l2db3_master_tgtid[6:0]),
    .l2db_master_qos_o               (l2db3_master_qos[3:0]),
    .l2db_master_snoop_o             (l2db3_master_snoop),
    .l2db_master_data_o              (l2db3_master_data[127:0]),
    .l2db_master_strb_o              (l2db3_master_strb[15:0]),
    .l2db_master_chunk_o             (l2db3_master_chunk[1:0]),
    .l2db_master_last_o              (l2db3_master_last),
    .l2db_master_opcode_o            (l2db3_master_opcode[2:0]),
    .l2db_master_snpresp_o           (l2db3_master_snpresp[2:0]),
    .l2db_master_len_o               (l2db3_master_len[1:0]),
    .l2db_master_size_o              (l2db3_master_size[2:0]),
    .l2db_master_addr_o              (l2db3_master_addr[5:0]),
    .l2db_master_attrs_o             (l2db3_master_attrs[7:0]),
    .l2db_master_prot_o              (l2db3_master_prot),
    .l2db_master_strex_o             (l2db3_master_strex),
    .l2db_master_unique_o            (l2db3_master_unique),
    .l2db_master_err_o               (l2db3_master_err),
    .l2db_master_invalidated_o       (l2db3_master_invalidated),
    .l2db_master_dirty_o             (l2db3_master_dirty),
    .l2db_ramctl_valid_o             (l2db3_ramctl_valid),
    .l2db_ramctl_rw_o                (l2db3_ramctl_rw[1:0]),
    .l2db_ramctl_index_o             (l2db3_ramctl_index[10:0]),
    .l2db_ramctl_way_o               (l2db3_ramctl_way[3:0]),
    .l2db_ramctl_data_o              (l2db3_ramctl_data[255:0]),
    .l2db_ramctl_banks_o             (l2db3_ramctl_banks[7:0]),
    .l2db_ramctl_err_o               (l2db3_ramctl_err),
    .l2db_slv_valid_o                (l2db3_slv_valid),
    .l2db_slv_id_o                   (l2db3_slv_id[5:0]),
    .l2db_slv_biuid_o                (l2db3_slv_biuid[4:0]),
    .l2db_slv_data_o                 (l2db3_slv_data[127:0]),
    .l2db_slv_chunk_o                (l2db3_slv_chunk[1:0]),
    .l2db_slv_last_o                 (l2db3_slv_last),
    .l2db_slv_bypass_o               (l2db3_slv_bypass),
    .l2db_slv_err_o                  (l2db3_slv_err),
    .l2db_cpuslv0_data_active_o      (l2db3_cpuslv0_data_active),
    .l2db_cpuslv1_data_active_o      (l2db3_cpuslv1_data_active),
    .l2db_cpuslv2_data_active_o      (l2db3_cpuslv2_data_active),
    .l2db_cpuslv3_data_active_o      (l2db3_cpuslv3_data_active)
  );  // u_scu_l2db3

  ca53scu_l2db #(`CA53_SCU_INT_PARAM_INST, .L2DB_NUM(4'b0100)) u_scu_l2db4 (
    // TEMPLATE s/l2db_/l2db4_/
    /*ARMAUTO*/
    // Inputs
    .CLKIN                           (CLKIN),
    .clk                             (clk),
    .reset_n                         (reset_n),
    .DFTSE                           (DFTSE),
    .tagctl_l2db_alloc_i             (tagctl_l2db4_alloc),
    .tagctl_alloc_for_snoop_i        (tagctl_alloc_for_snoop),
    .tagctl_alloc_for_write_i        (tagctl_alloc_for_write),
    .tagctl_l2db_release_i           (tagctl_l2db4_release),
    .tagctl_l2db_snoops_done_i       (tagctl_l2db4_snoops_done),
    .tagctl_l2db_fill_strbs_i        (tagctl_l2db4_fill_strbs),
    .master_afb0_ack_i               (master_afb0_ack),
    .master_afb1_ack_i               (master_afb1_ack),
    .master_afb2_ack_i               (master_afb2_ack),
    .master_afb3_ack_i               (master_afb3_ack),
    .master_afb4_ack_i               (master_afb4_ack),
    .master_afb5_ack_i               (master_afb5_ack),
    .master_afb_waddr_id_i           (master_afb_waddr_id[3:0]),
    .master_rsp_dbid_valid_i         (master_rsp_dbid_valid),
    .master_rsp_comp_valid_i         (master_rsp_comp_valid),
    .master_rsp_txnid_i              (master_rsp_txnid[6:0]),
    .master_rsp_dbid_i               (master_rsp_dbid[7:0]),
    .master_rsp_srcid_i              (master_rsp_srcid[6:0]),
    .cpuslv0_l2dbs_active_i          (cpuslv0_l2dbs_active),
    .cpuslv0_l2db_transfer_i         (cpuslv0_l2db4_transfer),
    .cpuslv0_l2db_transfer_type_i    (cpuslv0_l2db4_transfer_type[2:0]),
    .cpuslv0_l2db_transfer_info_i    (cpuslv0_l2db4_transfer_info[23:0]),
    .cpuslv0_l2db_release_i          (cpuslv0_l2db4_release),
    .cpuslv1_l2dbs_active_i          (cpuslv1_l2dbs_active),
    .cpuslv1_l2db_transfer_i         (cpuslv1_l2db4_transfer),
    .cpuslv1_l2db_transfer_type_i    (cpuslv1_l2db4_transfer_type[2:0]),
    .cpuslv1_l2db_transfer_info_i    (cpuslv1_l2db4_transfer_info[23:0]),
    .cpuslv1_l2db_release_i          (cpuslv1_l2db4_release),
    .cpuslv2_l2dbs_active_i          (cpuslv2_l2dbs_active),
    .cpuslv2_l2db_transfer_i         (cpuslv2_l2db4_transfer),
    .cpuslv2_l2db_transfer_type_i    (cpuslv2_l2db4_transfer_type[2:0]),
    .cpuslv2_l2db_transfer_info_i    (cpuslv2_l2db4_transfer_info[23:0]),
    .cpuslv2_l2db_release_i          (cpuslv2_l2db4_release),
    .cpuslv3_l2dbs_active_i          (cpuslv3_l2dbs_active),
    .cpuslv3_l2db_transfer_i         (cpuslv3_l2db4_transfer),
    .cpuslv3_l2db_transfer_type_i    (cpuslv3_l2db4_transfer_type[2:0]),
    .cpuslv3_l2db_transfer_info_i    (cpuslv3_l2db4_transfer_info[23:0]),
    .cpuslv3_l2db_release_i          (cpuslv3_l2db4_release),
    .acpslv_l2dbs_active_i           (acpslv_l2dbs_active),
    .acpslv_l2db_transfer_i          (acpslv_l2db4_transfer),
    .acpslv_l2db_transfer_type_i     (acpslv_l2db4_transfer_type[2:0]),
    .acpslv_l2db_transfer_info_i     (acpslv_l2db4_transfer_info[25:0]),
    .acpslv_l2db_release_i           (acpslv_l2db4_release),
    .snpslv_l2dbs_active_i           (snpslv_l2dbs_active),
    .snpslv_l2db_transfer_i          (snpslv_l2db4_transfer),
    .snpslv_l2db_transfer_type_i     (snpslv_l2db4_transfer_type[2:0]),
    .snpslv_l2db_transfer_info_i     (snpslv_l2db4_transfer_info[28:0]),
    .snpslv_l2db_release_i           (snpslv_l2db4_release),
    .snpslv_l2db_invalidate_i        (snpslv_l2db4_invalidate),
    .snpslv_l2db_makeshared_i        (snpslv_l2db4_makeshared),
    .afb0_l2dbs_transfer_i           (afb0_l2dbs_transfer),
    .afb0_l2dbs_id_i                 (afb0_l2dbs_id[3:0]),
    .afb0_l2dbs_transfer_info_i      (afb0_l2dbs_transfer_info[23:0]),
    .afb1_l2dbs_transfer_i           (afb1_l2dbs_transfer),
    .afb1_l2dbs_id_i                 (afb1_l2dbs_id[3:0]),
    .afb1_l2dbs_transfer_info_i      (afb1_l2dbs_transfer_info[23:0]),
    .afb2_l2dbs_transfer_i           (afb2_l2dbs_transfer),
    .afb2_l2dbs_id_i                 (afb2_l2dbs_id[3:0]),
    .afb2_l2dbs_transfer_info_i      (afb2_l2dbs_transfer_info[23:0]),
    .afb3_l2dbs_transfer_i           (afb3_l2dbs_transfer),
    .afb3_l2dbs_id_i                 (afb3_l2dbs_id[3:0]),
    .afb3_l2dbs_transfer_info_i      (afb3_l2dbs_transfer_info[23:0]),
    .afb4_l2dbs_transfer_i           (afb4_l2dbs_transfer),
    .afb4_l2dbs_id_i                 (afb4_l2dbs_id[3:0]),
    .afb4_l2dbs_transfer_info_i      (afb4_l2dbs_transfer_info[23:0]),
    .afb5_l2dbs_transfer_i           (afb5_l2dbs_transfer),
    .afb5_l2dbs_id_i                 (afb5_l2dbs_id[3:0]),
    .afb5_l2dbs_transfer_info_i      (afb5_l2dbs_transfer_info[23:0]),
    .master_l2db_ready_i             (master_l2db4_ready),
    .ramctl_l2db_ready_i             (ramctl_l2db4_ready),
    .cpuslv0_l2db_ready_i            (cpuslv0_l2db4_ready),
    .cpuslv1_l2db_ready_i            (cpuslv1_l2db4_ready),
    .cpuslv2_l2db_ready_i            (cpuslv2_l2db4_ready),
    .cpuslv3_l2db_ready_i            (cpuslv3_l2db4_ready),
    .acpslv_l2db_ready_i             (acpslv_l2db4_ready),
    .master_early_dr_valid_i         (master_early_dr_valid),
    .master_early_dr_id_i            (master_early_dr_id[5:0]),
    .master_early_dr_chunk_i         (master_early_dr_chunk[1:0]),
    .master_early_dr_data_i          (master_early_dr_data[127:0]),
    .ramctl_l2dbs_valid_i            (ramctl_l2dbs_valid),
    .ramctl_l2dbs_id_i               (ramctl_l2dbs_id[3:0]),
    .ramctl_l2dbs_data_i             (ramctl_l2dbs_data[255:0]),
    .ramctl_l2dbs_chunk_i            (ramctl_l2dbs_chunk[1:0]),
    .ramctl_l2dbs_err_i              (ramctl_l2dbs_err),
    .ramctl_l2dbs_last_i             (ramctl_l2dbs_last),
    .ramctl_l2dbs_bypass_i           (ramctl_l2dbs_bypass),
    .ramctl_l2dbs_bypass_id_i        (ramctl_l2dbs_bypass_id[3:0]),
    .ramctl_bypassed_err_i           (ramctl_bypassed_err),
    .cpuslv0_l2dbs_dw_valid_i        (cpuslv0_l2dbs_dw_valid),
    .cpuslv0_l2dbs_dw_id_i           (cpuslv0_l2dbs_dw_id[3:0]),
    .cpuslv0_l2dbs_dw_chunks_valid_i (cpuslv0_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv0_l2dbs_dw_last_i         (cpuslv0_l2dbs_dw_last),
    .cpuslv0_l2dbs_dw_data_i         (cpuslv0_l2dbs_dw_data[255:0]),
    .cpuslv0_l2dbs_dw_strb_i         (cpuslv0_l2dbs_dw_strb[31:0]),
    .cpuslv0_l2dbs_dw_err_i          (cpuslv0_l2dbs_dw_err),
    .cpuslv0_l2dbs_dw_fatal_i        (cpuslv0_l2dbs_dw_fatal),
    .cpuslv1_l2dbs_dw_valid_i        (cpuslv1_l2dbs_dw_valid),
    .cpuslv1_l2dbs_dw_id_i           (cpuslv1_l2dbs_dw_id[3:0]),
    .cpuslv1_l2dbs_dw_chunks_valid_i (cpuslv1_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv1_l2dbs_dw_last_i         (cpuslv1_l2dbs_dw_last),
    .cpuslv1_l2dbs_dw_data_i         (cpuslv1_l2dbs_dw_data[255:0]),
    .cpuslv1_l2dbs_dw_strb_i         (cpuslv1_l2dbs_dw_strb[31:0]),
    .cpuslv1_l2dbs_dw_err_i          (cpuslv1_l2dbs_dw_err),
    .cpuslv1_l2dbs_dw_fatal_i        (cpuslv1_l2dbs_dw_fatal),
    .cpuslv2_l2dbs_dw_valid_i        (cpuslv2_l2dbs_dw_valid),
    .cpuslv2_l2dbs_dw_id_i           (cpuslv2_l2dbs_dw_id[3:0]),
    .cpuslv2_l2dbs_dw_chunks_valid_i (cpuslv2_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv2_l2dbs_dw_last_i         (cpuslv2_l2dbs_dw_last),
    .cpuslv2_l2dbs_dw_data_i         (cpuslv2_l2dbs_dw_data[255:0]),
    .cpuslv2_l2dbs_dw_strb_i         (cpuslv2_l2dbs_dw_strb[31:0]),
    .cpuslv2_l2dbs_dw_err_i          (cpuslv2_l2dbs_dw_err),
    .cpuslv2_l2dbs_dw_fatal_i        (cpuslv2_l2dbs_dw_fatal),
    .cpuslv3_l2dbs_dw_valid_i        (cpuslv3_l2dbs_dw_valid),
    .cpuslv3_l2dbs_dw_id_i           (cpuslv3_l2dbs_dw_id[3:0]),
    .cpuslv3_l2dbs_dw_chunks_valid_i (cpuslv3_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv3_l2dbs_dw_last_i         (cpuslv3_l2dbs_dw_last),
    .cpuslv3_l2dbs_dw_data_i         (cpuslv3_l2dbs_dw_data[255:0]),
    .cpuslv3_l2dbs_dw_strb_i         (cpuslv3_l2dbs_dw_strb[31:0]),
    .cpuslv3_l2dbs_dw_err_i          (cpuslv3_l2dbs_dw_err),
    .cpuslv3_l2dbs_dw_fatal_i        (cpuslv3_l2dbs_dw_fatal),
    .acpslv_l2dbs_dw_valid_i         (acpslv_l2dbs_dw_valid),
    .acpslv_l2dbs_dw_id_i            (acpslv_l2dbs_dw_id[3:0]),
    .acpslv_l2dbs_dw_chunk_i         (acpslv_l2dbs_dw_chunk[1:0]),
    .acpslv_l2dbs_dw_last_i          (acpslv_l2dbs_dw_last),
    .acpslv_l2dbs_dw_data_i          (acpslv_l2dbs_dw_data[127:0]),
    .acpslv_l2dbs_dw_strb_i          (acpslv_l2dbs_dw_strb[15:0]),
    .gov_mbistreq_i                  (gov_mbistreq_i),
    .gov_mbistarray0_i               (gov_mbistarray0_i[8:0]),
    // Outputs
    .l2db_tagctl_available_o         (l2db4_tagctl_available),
    .l2db_tagctl_for_snoop_o         (l2db4_tagctl_for_snoop),
    .l2db_tagctl_for_write_o         (l2db4_tagctl_for_write),
    .l2db_full_line_o                (l2db4_full_line),
    .l2db_rmw_line_o                 (l2db4_rmw_line),
    .l2db_slv_done_o                 (l2db4_slv_done),
    .l2db_snpslv_done_o              (l2db4_snpslv_done),
    .l2db_slv_master_arb_o           (l2db4_slv_master_arb),
    .l2db_master_valid_o             (l2db4_master_valid),
    .l2db_master_id_o                (l2db4_master_id[5:0]),
    .l2db_master_dbid_o              (l2db4_master_dbid[7:0]),
    .l2db_master_tgtid_o             (l2db4_master_tgtid[6:0]),
    .l2db_master_qos_o               (l2db4_master_qos[3:0]),
    .l2db_master_snoop_o             (l2db4_master_snoop),
    .l2db_master_data_o              (l2db4_master_data[127:0]),
    .l2db_master_strb_o              (l2db4_master_strb[15:0]),
    .l2db_master_chunk_o             (l2db4_master_chunk[1:0]),
    .l2db_master_last_o              (l2db4_master_last),
    .l2db_master_opcode_o            (l2db4_master_opcode[2:0]),
    .l2db_master_snpresp_o           (l2db4_master_snpresp[2:0]),
    .l2db_master_len_o               (l2db4_master_len[1:0]),
    .l2db_master_size_o              (l2db4_master_size[2:0]),
    .l2db_master_addr_o              (l2db4_master_addr[5:0]),
    .l2db_master_attrs_o             (l2db4_master_attrs[7:0]),
    .l2db_master_prot_o              (l2db4_master_prot),
    .l2db_master_strex_o             (l2db4_master_strex),
    .l2db_master_unique_o            (l2db4_master_unique),
    .l2db_master_err_o               (l2db4_master_err),
    .l2db_master_invalidated_o       (l2db4_master_invalidated),
    .l2db_master_dirty_o             (l2db4_master_dirty),
    .l2db_ramctl_valid_o             (l2db4_ramctl_valid),
    .l2db_ramctl_rw_o                (l2db4_ramctl_rw[1:0]),
    .l2db_ramctl_index_o             (l2db4_ramctl_index[10:0]),
    .l2db_ramctl_way_o               (l2db4_ramctl_way[3:0]),
    .l2db_ramctl_data_o              (l2db4_ramctl_data[255:0]),
    .l2db_ramctl_banks_o             (l2db4_ramctl_banks[7:0]),
    .l2db_ramctl_err_o               (l2db4_ramctl_err),
    .l2db_slv_valid_o                (l2db4_slv_valid),
    .l2db_slv_id_o                   (l2db4_slv_id[5:0]),
    .l2db_slv_biuid_o                (l2db4_slv_biuid[4:0]),
    .l2db_slv_data_o                 (l2db4_slv_data[127:0]),
    .l2db_slv_chunk_o                (l2db4_slv_chunk[1:0]),
    .l2db_slv_last_o                 (l2db4_slv_last),
    .l2db_slv_bypass_o               (l2db4_slv_bypass),
    .l2db_slv_err_o                  (l2db4_slv_err),
    .l2db_cpuslv0_data_active_o      (l2db4_cpuslv0_data_active),
    .l2db_cpuslv1_data_active_o      (l2db4_cpuslv1_data_active),
    .l2db_cpuslv2_data_active_o      (l2db4_cpuslv2_data_active),
    .l2db_cpuslv3_data_active_o      (l2db4_cpuslv3_data_active)
  );  // u_scu_l2db4

  ca53scu_l2db #(`CA53_SCU_INT_PARAM_INST, .L2DB_NUM(4'b0101)) u_scu_l2db5 (
    // TEMPLATE s/l2db_/l2db5_/
    /*ARMAUTO*/
    // Inputs
    .CLKIN                           (CLKIN),
    .clk                             (clk),
    .reset_n                         (reset_n),
    .DFTSE                           (DFTSE),
    .tagctl_l2db_alloc_i             (tagctl_l2db5_alloc),
    .tagctl_alloc_for_snoop_i        (tagctl_alloc_for_snoop),
    .tagctl_alloc_for_write_i        (tagctl_alloc_for_write),
    .tagctl_l2db_release_i           (tagctl_l2db5_release),
    .tagctl_l2db_snoops_done_i       (tagctl_l2db5_snoops_done),
    .tagctl_l2db_fill_strbs_i        (tagctl_l2db5_fill_strbs),
    .master_afb0_ack_i               (master_afb0_ack),
    .master_afb1_ack_i               (master_afb1_ack),
    .master_afb2_ack_i               (master_afb2_ack),
    .master_afb3_ack_i               (master_afb3_ack),
    .master_afb4_ack_i               (master_afb4_ack),
    .master_afb5_ack_i               (master_afb5_ack),
    .master_afb_waddr_id_i           (master_afb_waddr_id[3:0]),
    .master_rsp_dbid_valid_i         (master_rsp_dbid_valid),
    .master_rsp_comp_valid_i         (master_rsp_comp_valid),
    .master_rsp_txnid_i              (master_rsp_txnid[6:0]),
    .master_rsp_dbid_i               (master_rsp_dbid[7:0]),
    .master_rsp_srcid_i              (master_rsp_srcid[6:0]),
    .cpuslv0_l2dbs_active_i          (cpuslv0_l2dbs_active),
    .cpuslv0_l2db_transfer_i         (cpuslv0_l2db5_transfer),
    .cpuslv0_l2db_transfer_type_i    (cpuslv0_l2db5_transfer_type[2:0]),
    .cpuslv0_l2db_transfer_info_i    (cpuslv0_l2db5_transfer_info[23:0]),
    .cpuslv0_l2db_release_i          (cpuslv0_l2db5_release),
    .cpuslv1_l2dbs_active_i          (cpuslv1_l2dbs_active),
    .cpuslv1_l2db_transfer_i         (cpuslv1_l2db5_transfer),
    .cpuslv1_l2db_transfer_type_i    (cpuslv1_l2db5_transfer_type[2:0]),
    .cpuslv1_l2db_transfer_info_i    (cpuslv1_l2db5_transfer_info[23:0]),
    .cpuslv1_l2db_release_i          (cpuslv1_l2db5_release),
    .cpuslv2_l2dbs_active_i          (cpuslv2_l2dbs_active),
    .cpuslv2_l2db_transfer_i         (cpuslv2_l2db5_transfer),
    .cpuslv2_l2db_transfer_type_i    (cpuslv2_l2db5_transfer_type[2:0]),
    .cpuslv2_l2db_transfer_info_i    (cpuslv2_l2db5_transfer_info[23:0]),
    .cpuslv2_l2db_release_i          (cpuslv2_l2db5_release),
    .cpuslv3_l2dbs_active_i          (cpuslv3_l2dbs_active),
    .cpuslv3_l2db_transfer_i         (cpuslv3_l2db5_transfer),
    .cpuslv3_l2db_transfer_type_i    (cpuslv3_l2db5_transfer_type[2:0]),
    .cpuslv3_l2db_transfer_info_i    (cpuslv3_l2db5_transfer_info[23:0]),
    .cpuslv3_l2db_release_i          (cpuslv3_l2db5_release),
    .acpslv_l2dbs_active_i           (acpslv_l2dbs_active),
    .acpslv_l2db_transfer_i          (acpslv_l2db5_transfer),
    .acpslv_l2db_transfer_type_i     (acpslv_l2db5_transfer_type[2:0]),
    .acpslv_l2db_transfer_info_i     (acpslv_l2db5_transfer_info[25:0]),
    .acpslv_l2db_release_i           (acpslv_l2db5_release),
    .snpslv_l2dbs_active_i           (snpslv_l2dbs_active),
    .snpslv_l2db_transfer_i          (snpslv_l2db5_transfer),
    .snpslv_l2db_transfer_type_i     (snpslv_l2db5_transfer_type[2:0]),
    .snpslv_l2db_transfer_info_i     (snpslv_l2db5_transfer_info[28:0]),
    .snpslv_l2db_release_i           (snpslv_l2db5_release),
    .snpslv_l2db_invalidate_i        (snpslv_l2db5_invalidate),
    .snpslv_l2db_makeshared_i        (snpslv_l2db5_makeshared),
    .afb0_l2dbs_transfer_i           (afb0_l2dbs_transfer),
    .afb0_l2dbs_id_i                 (afb0_l2dbs_id[3:0]),
    .afb0_l2dbs_transfer_info_i      (afb0_l2dbs_transfer_info[23:0]),
    .afb1_l2dbs_transfer_i           (afb1_l2dbs_transfer),
    .afb1_l2dbs_id_i                 (afb1_l2dbs_id[3:0]),
    .afb1_l2dbs_transfer_info_i      (afb1_l2dbs_transfer_info[23:0]),
    .afb2_l2dbs_transfer_i           (afb2_l2dbs_transfer),
    .afb2_l2dbs_id_i                 (afb2_l2dbs_id[3:0]),
    .afb2_l2dbs_transfer_info_i      (afb2_l2dbs_transfer_info[23:0]),
    .afb3_l2dbs_transfer_i           (afb3_l2dbs_transfer),
    .afb3_l2dbs_id_i                 (afb3_l2dbs_id[3:0]),
    .afb3_l2dbs_transfer_info_i      (afb3_l2dbs_transfer_info[23:0]),
    .afb4_l2dbs_transfer_i           (afb4_l2dbs_transfer),
    .afb4_l2dbs_id_i                 (afb4_l2dbs_id[3:0]),
    .afb4_l2dbs_transfer_info_i      (afb4_l2dbs_transfer_info[23:0]),
    .afb5_l2dbs_transfer_i           (afb5_l2dbs_transfer),
    .afb5_l2dbs_id_i                 (afb5_l2dbs_id[3:0]),
    .afb5_l2dbs_transfer_info_i      (afb5_l2dbs_transfer_info[23:0]),
    .master_l2db_ready_i             (master_l2db5_ready),
    .ramctl_l2db_ready_i             (ramctl_l2db5_ready),
    .cpuslv0_l2db_ready_i            (cpuslv0_l2db5_ready),
    .cpuslv1_l2db_ready_i            (cpuslv1_l2db5_ready),
    .cpuslv2_l2db_ready_i            (cpuslv2_l2db5_ready),
    .cpuslv3_l2db_ready_i            (cpuslv3_l2db5_ready),
    .acpslv_l2db_ready_i             (acpslv_l2db5_ready),
    .master_early_dr_valid_i         (master_early_dr_valid),
    .master_early_dr_id_i            (master_early_dr_id[5:0]),
    .master_early_dr_chunk_i         (master_early_dr_chunk[1:0]),
    .master_early_dr_data_i          (master_early_dr_data[127:0]),
    .ramctl_l2dbs_valid_i            (ramctl_l2dbs_valid),
    .ramctl_l2dbs_id_i               (ramctl_l2dbs_id[3:0]),
    .ramctl_l2dbs_data_i             (ramctl_l2dbs_data[255:0]),
    .ramctl_l2dbs_chunk_i            (ramctl_l2dbs_chunk[1:0]),
    .ramctl_l2dbs_err_i              (ramctl_l2dbs_err),
    .ramctl_l2dbs_last_i             (ramctl_l2dbs_last),
    .ramctl_l2dbs_bypass_i           (ramctl_l2dbs_bypass),
    .ramctl_l2dbs_bypass_id_i        (ramctl_l2dbs_bypass_id[3:0]),
    .ramctl_bypassed_err_i           (ramctl_bypassed_err),
    .cpuslv0_l2dbs_dw_valid_i        (cpuslv0_l2dbs_dw_valid),
    .cpuslv0_l2dbs_dw_id_i           (cpuslv0_l2dbs_dw_id[3:0]),
    .cpuslv0_l2dbs_dw_chunks_valid_i (cpuslv0_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv0_l2dbs_dw_last_i         (cpuslv0_l2dbs_dw_last),
    .cpuslv0_l2dbs_dw_data_i         (cpuslv0_l2dbs_dw_data[255:0]),
    .cpuslv0_l2dbs_dw_strb_i         (cpuslv0_l2dbs_dw_strb[31:0]),
    .cpuslv0_l2dbs_dw_err_i          (cpuslv0_l2dbs_dw_err),
    .cpuslv0_l2dbs_dw_fatal_i        (cpuslv0_l2dbs_dw_fatal),
    .cpuslv1_l2dbs_dw_valid_i        (cpuslv1_l2dbs_dw_valid),
    .cpuslv1_l2dbs_dw_id_i           (cpuslv1_l2dbs_dw_id[3:0]),
    .cpuslv1_l2dbs_dw_chunks_valid_i (cpuslv1_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv1_l2dbs_dw_last_i         (cpuslv1_l2dbs_dw_last),
    .cpuslv1_l2dbs_dw_data_i         (cpuslv1_l2dbs_dw_data[255:0]),
    .cpuslv1_l2dbs_dw_strb_i         (cpuslv1_l2dbs_dw_strb[31:0]),
    .cpuslv1_l2dbs_dw_err_i          (cpuslv1_l2dbs_dw_err),
    .cpuslv1_l2dbs_dw_fatal_i        (cpuslv1_l2dbs_dw_fatal),
    .cpuslv2_l2dbs_dw_valid_i        (cpuslv2_l2dbs_dw_valid),
    .cpuslv2_l2dbs_dw_id_i           (cpuslv2_l2dbs_dw_id[3:0]),
    .cpuslv2_l2dbs_dw_chunks_valid_i (cpuslv2_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv2_l2dbs_dw_last_i         (cpuslv2_l2dbs_dw_last),
    .cpuslv2_l2dbs_dw_data_i         (cpuslv2_l2dbs_dw_data[255:0]),
    .cpuslv2_l2dbs_dw_strb_i         (cpuslv2_l2dbs_dw_strb[31:0]),
    .cpuslv2_l2dbs_dw_err_i          (cpuslv2_l2dbs_dw_err),
    .cpuslv2_l2dbs_dw_fatal_i        (cpuslv2_l2dbs_dw_fatal),
    .cpuslv3_l2dbs_dw_valid_i        (cpuslv3_l2dbs_dw_valid),
    .cpuslv3_l2dbs_dw_id_i           (cpuslv3_l2dbs_dw_id[3:0]),
    .cpuslv3_l2dbs_dw_chunks_valid_i (cpuslv3_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv3_l2dbs_dw_last_i         (cpuslv3_l2dbs_dw_last),
    .cpuslv3_l2dbs_dw_data_i         (cpuslv3_l2dbs_dw_data[255:0]),
    .cpuslv3_l2dbs_dw_strb_i         (cpuslv3_l2dbs_dw_strb[31:0]),
    .cpuslv3_l2dbs_dw_err_i          (cpuslv3_l2dbs_dw_err),
    .cpuslv3_l2dbs_dw_fatal_i        (cpuslv3_l2dbs_dw_fatal),
    .acpslv_l2dbs_dw_valid_i         (acpslv_l2dbs_dw_valid),
    .acpslv_l2dbs_dw_id_i            (acpslv_l2dbs_dw_id[3:0]),
    .acpslv_l2dbs_dw_chunk_i         (acpslv_l2dbs_dw_chunk[1:0]),
    .acpslv_l2dbs_dw_last_i          (acpslv_l2dbs_dw_last),
    .acpslv_l2dbs_dw_data_i          (acpslv_l2dbs_dw_data[127:0]),
    .acpslv_l2dbs_dw_strb_i          (acpslv_l2dbs_dw_strb[15:0]),
    .gov_mbistreq_i                  (gov_mbistreq_i),
    .gov_mbistarray0_i               (gov_mbistarray0_i[8:0]),
    // Outputs
    .l2db_tagctl_available_o         (l2db5_tagctl_available),
    .l2db_tagctl_for_snoop_o         (l2db5_tagctl_for_snoop),
    .l2db_tagctl_for_write_o         (l2db5_tagctl_for_write),
    .l2db_full_line_o                (l2db5_full_line),
    .l2db_rmw_line_o                 (l2db5_rmw_line),
    .l2db_slv_done_o                 (l2db5_slv_done),
    .l2db_snpslv_done_o              (l2db5_snpslv_done),
    .l2db_slv_master_arb_o           (l2db5_slv_master_arb),
    .l2db_master_valid_o             (l2db5_master_valid),
    .l2db_master_id_o                (l2db5_master_id[5:0]),
    .l2db_master_dbid_o              (l2db5_master_dbid[7:0]),
    .l2db_master_tgtid_o             (l2db5_master_tgtid[6:0]),
    .l2db_master_qos_o               (l2db5_master_qos[3:0]),
    .l2db_master_snoop_o             (l2db5_master_snoop),
    .l2db_master_data_o              (l2db5_master_data[127:0]),
    .l2db_master_strb_o              (l2db5_master_strb[15:0]),
    .l2db_master_chunk_o             (l2db5_master_chunk[1:0]),
    .l2db_master_last_o              (l2db5_master_last),
    .l2db_master_opcode_o            (l2db5_master_opcode[2:0]),
    .l2db_master_snpresp_o           (l2db5_master_snpresp[2:0]),
    .l2db_master_len_o               (l2db5_master_len[1:0]),
    .l2db_master_size_o              (l2db5_master_size[2:0]),
    .l2db_master_addr_o              (l2db5_master_addr[5:0]),
    .l2db_master_attrs_o             (l2db5_master_attrs[7:0]),
    .l2db_master_prot_o              (l2db5_master_prot),
    .l2db_master_strex_o             (l2db5_master_strex),
    .l2db_master_unique_o            (l2db5_master_unique),
    .l2db_master_err_o               (l2db5_master_err),
    .l2db_master_invalidated_o       (l2db5_master_invalidated),
    .l2db_master_dirty_o             (l2db5_master_dirty),
    .l2db_ramctl_valid_o             (l2db5_ramctl_valid),
    .l2db_ramctl_rw_o                (l2db5_ramctl_rw[1:0]),
    .l2db_ramctl_index_o             (l2db5_ramctl_index[10:0]),
    .l2db_ramctl_way_o               (l2db5_ramctl_way[3:0]),
    .l2db_ramctl_data_o              (l2db5_ramctl_data[255:0]),
    .l2db_ramctl_banks_o             (l2db5_ramctl_banks[7:0]),
    .l2db_ramctl_err_o               (l2db5_ramctl_err),
    .l2db_slv_valid_o                (l2db5_slv_valid),
    .l2db_slv_id_o                   (l2db5_slv_id[5:0]),
    .l2db_slv_biuid_o                (l2db5_slv_biuid[4:0]),
    .l2db_slv_data_o                 (l2db5_slv_data[127:0]),
    .l2db_slv_chunk_o                (l2db5_slv_chunk[1:0]),
    .l2db_slv_last_o                 (l2db5_slv_last),
    .l2db_slv_bypass_o               (l2db5_slv_bypass),
    .l2db_slv_err_o                  (l2db5_slv_err),
    .l2db_cpuslv0_data_active_o      (l2db5_cpuslv0_data_active),
    .l2db_cpuslv1_data_active_o      (l2db5_cpuslv1_data_active),
    .l2db_cpuslv2_data_active_o      (l2db5_cpuslv2_data_active),
    .l2db_cpuslv3_data_active_o      (l2db5_cpuslv3_data_active)
  );  // u_scu_l2db5

  ca53scu_l2db #(`CA53_SCU_INT_PARAM_INST, .L2DB_NUM(4'b0110)) u_scu_l2db6 (
    // TEMPLATE s/l2db_/l2db6_/
    /*ARMAUTO*/
    // Inputs
    .CLKIN                           (CLKIN),
    .clk                             (clk),
    .reset_n                         (reset_n),
    .DFTSE                           (DFTSE),
    .tagctl_l2db_alloc_i             (tagctl_l2db6_alloc),
    .tagctl_alloc_for_snoop_i        (tagctl_alloc_for_snoop),
    .tagctl_alloc_for_write_i        (tagctl_alloc_for_write),
    .tagctl_l2db_release_i           (tagctl_l2db6_release),
    .tagctl_l2db_snoops_done_i       (tagctl_l2db6_snoops_done),
    .tagctl_l2db_fill_strbs_i        (tagctl_l2db6_fill_strbs),
    .master_afb0_ack_i               (master_afb0_ack),
    .master_afb1_ack_i               (master_afb1_ack),
    .master_afb2_ack_i               (master_afb2_ack),
    .master_afb3_ack_i               (master_afb3_ack),
    .master_afb4_ack_i               (master_afb4_ack),
    .master_afb5_ack_i               (master_afb5_ack),
    .master_afb_waddr_id_i           (master_afb_waddr_id[3:0]),
    .master_rsp_dbid_valid_i         (master_rsp_dbid_valid),
    .master_rsp_comp_valid_i         (master_rsp_comp_valid),
    .master_rsp_txnid_i              (master_rsp_txnid[6:0]),
    .master_rsp_dbid_i               (master_rsp_dbid[7:0]),
    .master_rsp_srcid_i              (master_rsp_srcid[6:0]),
    .cpuslv0_l2dbs_active_i          (cpuslv0_l2dbs_active),
    .cpuslv0_l2db_transfer_i         (cpuslv0_l2db6_transfer),
    .cpuslv0_l2db_transfer_type_i    (cpuslv0_l2db6_transfer_type[2:0]),
    .cpuslv0_l2db_transfer_info_i    (cpuslv0_l2db6_transfer_info[23:0]),
    .cpuslv0_l2db_release_i          (cpuslv0_l2db6_release),
    .cpuslv1_l2dbs_active_i          (cpuslv1_l2dbs_active),
    .cpuslv1_l2db_transfer_i         (cpuslv1_l2db6_transfer),
    .cpuslv1_l2db_transfer_type_i    (cpuslv1_l2db6_transfer_type[2:0]),
    .cpuslv1_l2db_transfer_info_i    (cpuslv1_l2db6_transfer_info[23:0]),
    .cpuslv1_l2db_release_i          (cpuslv1_l2db6_release),
    .cpuslv2_l2dbs_active_i          (cpuslv2_l2dbs_active),
    .cpuslv2_l2db_transfer_i         (cpuslv2_l2db6_transfer),
    .cpuslv2_l2db_transfer_type_i    (cpuslv2_l2db6_transfer_type[2:0]),
    .cpuslv2_l2db_transfer_info_i    (cpuslv2_l2db6_transfer_info[23:0]),
    .cpuslv2_l2db_release_i          (cpuslv2_l2db6_release),
    .cpuslv3_l2dbs_active_i          (cpuslv3_l2dbs_active),
    .cpuslv3_l2db_transfer_i         (cpuslv3_l2db6_transfer),
    .cpuslv3_l2db_transfer_type_i    (cpuslv3_l2db6_transfer_type[2:0]),
    .cpuslv3_l2db_transfer_info_i    (cpuslv3_l2db6_transfer_info[23:0]),
    .cpuslv3_l2db_release_i          (cpuslv3_l2db6_release),
    .acpslv_l2dbs_active_i           (acpslv_l2dbs_active),
    .acpslv_l2db_transfer_i          (acpslv_l2db6_transfer),
    .acpslv_l2db_transfer_type_i     (acpslv_l2db6_transfer_type[2:0]),
    .acpslv_l2db_transfer_info_i     (acpslv_l2db6_transfer_info[25:0]),
    .acpslv_l2db_release_i           (acpslv_l2db6_release),
    .snpslv_l2dbs_active_i           (snpslv_l2dbs_active),
    .snpslv_l2db_transfer_i          (snpslv_l2db6_transfer),
    .snpslv_l2db_transfer_type_i     (snpslv_l2db6_transfer_type[2:0]),
    .snpslv_l2db_transfer_info_i     (snpslv_l2db6_transfer_info[28:0]),
    .snpslv_l2db_release_i           (snpslv_l2db6_release),
    .snpslv_l2db_invalidate_i        (snpslv_l2db6_invalidate),
    .snpslv_l2db_makeshared_i        (snpslv_l2db6_makeshared),
    .afb0_l2dbs_transfer_i           (afb0_l2dbs_transfer),
    .afb0_l2dbs_id_i                 (afb0_l2dbs_id[3:0]),
    .afb0_l2dbs_transfer_info_i      (afb0_l2dbs_transfer_info[23:0]),
    .afb1_l2dbs_transfer_i           (afb1_l2dbs_transfer),
    .afb1_l2dbs_id_i                 (afb1_l2dbs_id[3:0]),
    .afb1_l2dbs_transfer_info_i      (afb1_l2dbs_transfer_info[23:0]),
    .afb2_l2dbs_transfer_i           (afb2_l2dbs_transfer),
    .afb2_l2dbs_id_i                 (afb2_l2dbs_id[3:0]),
    .afb2_l2dbs_transfer_info_i      (afb2_l2dbs_transfer_info[23:0]),
    .afb3_l2dbs_transfer_i           (afb3_l2dbs_transfer),
    .afb3_l2dbs_id_i                 (afb3_l2dbs_id[3:0]),
    .afb3_l2dbs_transfer_info_i      (afb3_l2dbs_transfer_info[23:0]),
    .afb4_l2dbs_transfer_i           (afb4_l2dbs_transfer),
    .afb4_l2dbs_id_i                 (afb4_l2dbs_id[3:0]),
    .afb4_l2dbs_transfer_info_i      (afb4_l2dbs_transfer_info[23:0]),
    .afb5_l2dbs_transfer_i           (afb5_l2dbs_transfer),
    .afb5_l2dbs_id_i                 (afb5_l2dbs_id[3:0]),
    .afb5_l2dbs_transfer_info_i      (afb5_l2dbs_transfer_info[23:0]),
    .master_l2db_ready_i             (master_l2db6_ready),
    .ramctl_l2db_ready_i             (ramctl_l2db6_ready),
    .cpuslv0_l2db_ready_i            (cpuslv0_l2db6_ready),
    .cpuslv1_l2db_ready_i            (cpuslv1_l2db6_ready),
    .cpuslv2_l2db_ready_i            (cpuslv2_l2db6_ready),
    .cpuslv3_l2db_ready_i            (cpuslv3_l2db6_ready),
    .acpslv_l2db_ready_i             (acpslv_l2db6_ready),
    .master_early_dr_valid_i         (master_early_dr_valid),
    .master_early_dr_id_i            (master_early_dr_id[5:0]),
    .master_early_dr_chunk_i         (master_early_dr_chunk[1:0]),
    .master_early_dr_data_i          (master_early_dr_data[127:0]),
    .ramctl_l2dbs_valid_i            (ramctl_l2dbs_valid),
    .ramctl_l2dbs_id_i               (ramctl_l2dbs_id[3:0]),
    .ramctl_l2dbs_data_i             (ramctl_l2dbs_data[255:0]),
    .ramctl_l2dbs_chunk_i            (ramctl_l2dbs_chunk[1:0]),
    .ramctl_l2dbs_err_i              (ramctl_l2dbs_err),
    .ramctl_l2dbs_last_i             (ramctl_l2dbs_last),
    .ramctl_l2dbs_bypass_i           (ramctl_l2dbs_bypass),
    .ramctl_l2dbs_bypass_id_i        (ramctl_l2dbs_bypass_id[3:0]),
    .ramctl_bypassed_err_i           (ramctl_bypassed_err),
    .cpuslv0_l2dbs_dw_valid_i        (cpuslv0_l2dbs_dw_valid),
    .cpuslv0_l2dbs_dw_id_i           (cpuslv0_l2dbs_dw_id[3:0]),
    .cpuslv0_l2dbs_dw_chunks_valid_i (cpuslv0_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv0_l2dbs_dw_last_i         (cpuslv0_l2dbs_dw_last),
    .cpuslv0_l2dbs_dw_data_i         (cpuslv0_l2dbs_dw_data[255:0]),
    .cpuslv0_l2dbs_dw_strb_i         (cpuslv0_l2dbs_dw_strb[31:0]),
    .cpuslv0_l2dbs_dw_err_i          (cpuslv0_l2dbs_dw_err),
    .cpuslv0_l2dbs_dw_fatal_i        (cpuslv0_l2dbs_dw_fatal),
    .cpuslv1_l2dbs_dw_valid_i        (cpuslv1_l2dbs_dw_valid),
    .cpuslv1_l2dbs_dw_id_i           (cpuslv1_l2dbs_dw_id[3:0]),
    .cpuslv1_l2dbs_dw_chunks_valid_i (cpuslv1_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv1_l2dbs_dw_last_i         (cpuslv1_l2dbs_dw_last),
    .cpuslv1_l2dbs_dw_data_i         (cpuslv1_l2dbs_dw_data[255:0]),
    .cpuslv1_l2dbs_dw_strb_i         (cpuslv1_l2dbs_dw_strb[31:0]),
    .cpuslv1_l2dbs_dw_err_i          (cpuslv1_l2dbs_dw_err),
    .cpuslv1_l2dbs_dw_fatal_i        (cpuslv1_l2dbs_dw_fatal),
    .cpuslv2_l2dbs_dw_valid_i        (cpuslv2_l2dbs_dw_valid),
    .cpuslv2_l2dbs_dw_id_i           (cpuslv2_l2dbs_dw_id[3:0]),
    .cpuslv2_l2dbs_dw_chunks_valid_i (cpuslv2_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv2_l2dbs_dw_last_i         (cpuslv2_l2dbs_dw_last),
    .cpuslv2_l2dbs_dw_data_i         (cpuslv2_l2dbs_dw_data[255:0]),
    .cpuslv2_l2dbs_dw_strb_i         (cpuslv2_l2dbs_dw_strb[31:0]),
    .cpuslv2_l2dbs_dw_err_i          (cpuslv2_l2dbs_dw_err),
    .cpuslv2_l2dbs_dw_fatal_i        (cpuslv2_l2dbs_dw_fatal),
    .cpuslv3_l2dbs_dw_valid_i        (cpuslv3_l2dbs_dw_valid),
    .cpuslv3_l2dbs_dw_id_i           (cpuslv3_l2dbs_dw_id[3:0]),
    .cpuslv3_l2dbs_dw_chunks_valid_i (cpuslv3_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv3_l2dbs_dw_last_i         (cpuslv3_l2dbs_dw_last),
    .cpuslv3_l2dbs_dw_data_i         (cpuslv3_l2dbs_dw_data[255:0]),
    .cpuslv3_l2dbs_dw_strb_i         (cpuslv3_l2dbs_dw_strb[31:0]),
    .cpuslv3_l2dbs_dw_err_i          (cpuslv3_l2dbs_dw_err),
    .cpuslv3_l2dbs_dw_fatal_i        (cpuslv3_l2dbs_dw_fatal),
    .acpslv_l2dbs_dw_valid_i         (acpslv_l2dbs_dw_valid),
    .acpslv_l2dbs_dw_id_i            (acpslv_l2dbs_dw_id[3:0]),
    .acpslv_l2dbs_dw_chunk_i         (acpslv_l2dbs_dw_chunk[1:0]),
    .acpslv_l2dbs_dw_last_i          (acpslv_l2dbs_dw_last),
    .acpslv_l2dbs_dw_data_i          (acpslv_l2dbs_dw_data[127:0]),
    .acpslv_l2dbs_dw_strb_i          (acpslv_l2dbs_dw_strb[15:0]),
    .gov_mbistreq_i                  (gov_mbistreq_i),
    .gov_mbistarray0_i               (gov_mbistarray0_i[8:0]),
    // Outputs
    .l2db_tagctl_available_o         (l2db6_tagctl_available),
    .l2db_tagctl_for_snoop_o         (l2db6_tagctl_for_snoop),
    .l2db_tagctl_for_write_o         (l2db6_tagctl_for_write),
    .l2db_full_line_o                (l2db6_full_line),
    .l2db_rmw_line_o                 (l2db6_rmw_line),
    .l2db_slv_done_o                 (l2db6_slv_done),
    .l2db_snpslv_done_o              (l2db6_snpslv_done),
    .l2db_slv_master_arb_o           (l2db6_slv_master_arb),
    .l2db_master_valid_o             (l2db6_master_valid),
    .l2db_master_id_o                (l2db6_master_id[5:0]),
    .l2db_master_dbid_o              (l2db6_master_dbid[7:0]),
    .l2db_master_tgtid_o             (l2db6_master_tgtid[6:0]),
    .l2db_master_qos_o               (l2db6_master_qos[3:0]),
    .l2db_master_snoop_o             (l2db6_master_snoop),
    .l2db_master_data_o              (l2db6_master_data[127:0]),
    .l2db_master_strb_o              (l2db6_master_strb[15:0]),
    .l2db_master_chunk_o             (l2db6_master_chunk[1:0]),
    .l2db_master_last_o              (l2db6_master_last),
    .l2db_master_opcode_o            (l2db6_master_opcode[2:0]),
    .l2db_master_snpresp_o           (l2db6_master_snpresp[2:0]),
    .l2db_master_len_o               (l2db6_master_len[1:0]),
    .l2db_master_size_o              (l2db6_master_size[2:0]),
    .l2db_master_addr_o              (l2db6_master_addr[5:0]),
    .l2db_master_attrs_o             (l2db6_master_attrs[7:0]),
    .l2db_master_prot_o              (l2db6_master_prot),
    .l2db_master_strex_o             (l2db6_master_strex),
    .l2db_master_unique_o            (l2db6_master_unique),
    .l2db_master_err_o               (l2db6_master_err),
    .l2db_master_invalidated_o       (l2db6_master_invalidated),
    .l2db_master_dirty_o             (l2db6_master_dirty),
    .l2db_ramctl_valid_o             (l2db6_ramctl_valid),
    .l2db_ramctl_rw_o                (l2db6_ramctl_rw[1:0]),
    .l2db_ramctl_index_o             (l2db6_ramctl_index[10:0]),
    .l2db_ramctl_way_o               (l2db6_ramctl_way[3:0]),
    .l2db_ramctl_data_o              (l2db6_ramctl_data[255:0]),
    .l2db_ramctl_banks_o             (l2db6_ramctl_banks[7:0]),
    .l2db_ramctl_err_o               (l2db6_ramctl_err),
    .l2db_slv_valid_o                (l2db6_slv_valid),
    .l2db_slv_id_o                   (l2db6_slv_id[5:0]),
    .l2db_slv_biuid_o                (l2db6_slv_biuid[4:0]),
    .l2db_slv_data_o                 (l2db6_slv_data[127:0]),
    .l2db_slv_chunk_o                (l2db6_slv_chunk[1:0]),
    .l2db_slv_last_o                 (l2db6_slv_last),
    .l2db_slv_bypass_o               (l2db6_slv_bypass),
    .l2db_slv_err_o                  (l2db6_slv_err),
    .l2db_cpuslv0_data_active_o      (l2db6_cpuslv0_data_active),
    .l2db_cpuslv1_data_active_o      (l2db6_cpuslv1_data_active),
    .l2db_cpuslv2_data_active_o      (l2db6_cpuslv2_data_active),
    .l2db_cpuslv3_data_active_o      (l2db6_cpuslv3_data_active)
  );  // u_scu_l2db6

  ca53scu_l2db #(`CA53_SCU_INT_PARAM_INST, .L2DB_NUM(4'b0111)) u_scu_l2db7 (
    // TEMPLATE s/l2db_/l2db7_/
    /*ARMAUTO*/
    // Inputs
    .CLKIN                           (CLKIN),
    .clk                             (clk),
    .reset_n                         (reset_n),
    .DFTSE                           (DFTSE),
    .tagctl_l2db_alloc_i             (tagctl_l2db7_alloc),
    .tagctl_alloc_for_snoop_i        (tagctl_alloc_for_snoop),
    .tagctl_alloc_for_write_i        (tagctl_alloc_for_write),
    .tagctl_l2db_release_i           (tagctl_l2db7_release),
    .tagctl_l2db_snoops_done_i       (tagctl_l2db7_snoops_done),
    .tagctl_l2db_fill_strbs_i        (tagctl_l2db7_fill_strbs),
    .master_afb0_ack_i               (master_afb0_ack),
    .master_afb1_ack_i               (master_afb1_ack),
    .master_afb2_ack_i               (master_afb2_ack),
    .master_afb3_ack_i               (master_afb3_ack),
    .master_afb4_ack_i               (master_afb4_ack),
    .master_afb5_ack_i               (master_afb5_ack),
    .master_afb_waddr_id_i           (master_afb_waddr_id[3:0]),
    .master_rsp_dbid_valid_i         (master_rsp_dbid_valid),
    .master_rsp_comp_valid_i         (master_rsp_comp_valid),
    .master_rsp_txnid_i              (master_rsp_txnid[6:0]),
    .master_rsp_dbid_i               (master_rsp_dbid[7:0]),
    .master_rsp_srcid_i              (master_rsp_srcid[6:0]),
    .cpuslv0_l2dbs_active_i          (cpuslv0_l2dbs_active),
    .cpuslv0_l2db_transfer_i         (cpuslv0_l2db7_transfer),
    .cpuslv0_l2db_transfer_type_i    (cpuslv0_l2db7_transfer_type[2:0]),
    .cpuslv0_l2db_transfer_info_i    (cpuslv0_l2db7_transfer_info[23:0]),
    .cpuslv0_l2db_release_i          (cpuslv0_l2db7_release),
    .cpuslv1_l2dbs_active_i          (cpuslv1_l2dbs_active),
    .cpuslv1_l2db_transfer_i         (cpuslv1_l2db7_transfer),
    .cpuslv1_l2db_transfer_type_i    (cpuslv1_l2db7_transfer_type[2:0]),
    .cpuslv1_l2db_transfer_info_i    (cpuslv1_l2db7_transfer_info[23:0]),
    .cpuslv1_l2db_release_i          (cpuslv1_l2db7_release),
    .cpuslv2_l2dbs_active_i          (cpuslv2_l2dbs_active),
    .cpuslv2_l2db_transfer_i         (cpuslv2_l2db7_transfer),
    .cpuslv2_l2db_transfer_type_i    (cpuslv2_l2db7_transfer_type[2:0]),
    .cpuslv2_l2db_transfer_info_i    (cpuslv2_l2db7_transfer_info[23:0]),
    .cpuslv2_l2db_release_i          (cpuslv2_l2db7_release),
    .cpuslv3_l2dbs_active_i          (cpuslv3_l2dbs_active),
    .cpuslv3_l2db_transfer_i         (cpuslv3_l2db7_transfer),
    .cpuslv3_l2db_transfer_type_i    (cpuslv3_l2db7_transfer_type[2:0]),
    .cpuslv3_l2db_transfer_info_i    (cpuslv3_l2db7_transfer_info[23:0]),
    .cpuslv3_l2db_release_i          (cpuslv3_l2db7_release),
    .acpslv_l2dbs_active_i           (acpslv_l2dbs_active),
    .acpslv_l2db_transfer_i          (acpslv_l2db7_transfer),
    .acpslv_l2db_transfer_type_i     (acpslv_l2db7_transfer_type[2:0]),
    .acpslv_l2db_transfer_info_i     (acpslv_l2db7_transfer_info[25:0]),
    .acpslv_l2db_release_i           (acpslv_l2db7_release),
    .snpslv_l2dbs_active_i           (snpslv_l2dbs_active),
    .snpslv_l2db_transfer_i          (snpslv_l2db7_transfer),
    .snpslv_l2db_transfer_type_i     (snpslv_l2db7_transfer_type[2:0]),
    .snpslv_l2db_transfer_info_i     (snpslv_l2db7_transfer_info[28:0]),
    .snpslv_l2db_release_i           (snpslv_l2db7_release),
    .snpslv_l2db_invalidate_i        (snpslv_l2db7_invalidate),
    .snpslv_l2db_makeshared_i        (snpslv_l2db7_makeshared),
    .afb0_l2dbs_transfer_i           (afb0_l2dbs_transfer),
    .afb0_l2dbs_id_i                 (afb0_l2dbs_id[3:0]),
    .afb0_l2dbs_transfer_info_i      (afb0_l2dbs_transfer_info[23:0]),
    .afb1_l2dbs_transfer_i           (afb1_l2dbs_transfer),
    .afb1_l2dbs_id_i                 (afb1_l2dbs_id[3:0]),
    .afb1_l2dbs_transfer_info_i      (afb1_l2dbs_transfer_info[23:0]),
    .afb2_l2dbs_transfer_i           (afb2_l2dbs_transfer),
    .afb2_l2dbs_id_i                 (afb2_l2dbs_id[3:0]),
    .afb2_l2dbs_transfer_info_i      (afb2_l2dbs_transfer_info[23:0]),
    .afb3_l2dbs_transfer_i           (afb3_l2dbs_transfer),
    .afb3_l2dbs_id_i                 (afb3_l2dbs_id[3:0]),
    .afb3_l2dbs_transfer_info_i      (afb3_l2dbs_transfer_info[23:0]),
    .afb4_l2dbs_transfer_i           (afb4_l2dbs_transfer),
    .afb4_l2dbs_id_i                 (afb4_l2dbs_id[3:0]),
    .afb4_l2dbs_transfer_info_i      (afb4_l2dbs_transfer_info[23:0]),
    .afb5_l2dbs_transfer_i           (afb5_l2dbs_transfer),
    .afb5_l2dbs_id_i                 (afb5_l2dbs_id[3:0]),
    .afb5_l2dbs_transfer_info_i      (afb5_l2dbs_transfer_info[23:0]),
    .master_l2db_ready_i             (master_l2db7_ready),
    .ramctl_l2db_ready_i             (ramctl_l2db7_ready),
    .cpuslv0_l2db_ready_i            (cpuslv0_l2db7_ready),
    .cpuslv1_l2db_ready_i            (cpuslv1_l2db7_ready),
    .cpuslv2_l2db_ready_i            (cpuslv2_l2db7_ready),
    .cpuslv3_l2db_ready_i            (cpuslv3_l2db7_ready),
    .acpslv_l2db_ready_i             (acpslv_l2db7_ready),
    .master_early_dr_valid_i         (master_early_dr_valid),
    .master_early_dr_id_i            (master_early_dr_id[5:0]),
    .master_early_dr_chunk_i         (master_early_dr_chunk[1:0]),
    .master_early_dr_data_i          (master_early_dr_data[127:0]),
    .ramctl_l2dbs_valid_i            (ramctl_l2dbs_valid),
    .ramctl_l2dbs_id_i               (ramctl_l2dbs_id[3:0]),
    .ramctl_l2dbs_data_i             (ramctl_l2dbs_data[255:0]),
    .ramctl_l2dbs_chunk_i            (ramctl_l2dbs_chunk[1:0]),
    .ramctl_l2dbs_err_i              (ramctl_l2dbs_err),
    .ramctl_l2dbs_last_i             (ramctl_l2dbs_last),
    .ramctl_l2dbs_bypass_i           (ramctl_l2dbs_bypass),
    .ramctl_l2dbs_bypass_id_i        (ramctl_l2dbs_bypass_id[3:0]),
    .ramctl_bypassed_err_i           (ramctl_bypassed_err),
    .cpuslv0_l2dbs_dw_valid_i        (cpuslv0_l2dbs_dw_valid),
    .cpuslv0_l2dbs_dw_id_i           (cpuslv0_l2dbs_dw_id[3:0]),
    .cpuslv0_l2dbs_dw_chunks_valid_i (cpuslv0_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv0_l2dbs_dw_last_i         (cpuslv0_l2dbs_dw_last),
    .cpuslv0_l2dbs_dw_data_i         (cpuslv0_l2dbs_dw_data[255:0]),
    .cpuslv0_l2dbs_dw_strb_i         (cpuslv0_l2dbs_dw_strb[31:0]),
    .cpuslv0_l2dbs_dw_err_i          (cpuslv0_l2dbs_dw_err),
    .cpuslv0_l2dbs_dw_fatal_i        (cpuslv0_l2dbs_dw_fatal),
    .cpuslv1_l2dbs_dw_valid_i        (cpuslv1_l2dbs_dw_valid),
    .cpuslv1_l2dbs_dw_id_i           (cpuslv1_l2dbs_dw_id[3:0]),
    .cpuslv1_l2dbs_dw_chunks_valid_i (cpuslv1_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv1_l2dbs_dw_last_i         (cpuslv1_l2dbs_dw_last),
    .cpuslv1_l2dbs_dw_data_i         (cpuslv1_l2dbs_dw_data[255:0]),
    .cpuslv1_l2dbs_dw_strb_i         (cpuslv1_l2dbs_dw_strb[31:0]),
    .cpuslv1_l2dbs_dw_err_i          (cpuslv1_l2dbs_dw_err),
    .cpuslv1_l2dbs_dw_fatal_i        (cpuslv1_l2dbs_dw_fatal),
    .cpuslv2_l2dbs_dw_valid_i        (cpuslv2_l2dbs_dw_valid),
    .cpuslv2_l2dbs_dw_id_i           (cpuslv2_l2dbs_dw_id[3:0]),
    .cpuslv2_l2dbs_dw_chunks_valid_i (cpuslv2_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv2_l2dbs_dw_last_i         (cpuslv2_l2dbs_dw_last),
    .cpuslv2_l2dbs_dw_data_i         (cpuslv2_l2dbs_dw_data[255:0]),
    .cpuslv2_l2dbs_dw_strb_i         (cpuslv2_l2dbs_dw_strb[31:0]),
    .cpuslv2_l2dbs_dw_err_i          (cpuslv2_l2dbs_dw_err),
    .cpuslv2_l2dbs_dw_fatal_i        (cpuslv2_l2dbs_dw_fatal),
    .cpuslv3_l2dbs_dw_valid_i        (cpuslv3_l2dbs_dw_valid),
    .cpuslv3_l2dbs_dw_id_i           (cpuslv3_l2dbs_dw_id[3:0]),
    .cpuslv3_l2dbs_dw_chunks_valid_i (cpuslv3_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv3_l2dbs_dw_last_i         (cpuslv3_l2dbs_dw_last),
    .cpuslv3_l2dbs_dw_data_i         (cpuslv3_l2dbs_dw_data[255:0]),
    .cpuslv3_l2dbs_dw_strb_i         (cpuslv3_l2dbs_dw_strb[31:0]),
    .cpuslv3_l2dbs_dw_err_i          (cpuslv3_l2dbs_dw_err),
    .cpuslv3_l2dbs_dw_fatal_i        (cpuslv3_l2dbs_dw_fatal),
    .acpslv_l2dbs_dw_valid_i         (acpslv_l2dbs_dw_valid),
    .acpslv_l2dbs_dw_id_i            (acpslv_l2dbs_dw_id[3:0]),
    .acpslv_l2dbs_dw_chunk_i         (acpslv_l2dbs_dw_chunk[1:0]),
    .acpslv_l2dbs_dw_last_i          (acpslv_l2dbs_dw_last),
    .acpslv_l2dbs_dw_data_i          (acpslv_l2dbs_dw_data[127:0]),
    .acpslv_l2dbs_dw_strb_i          (acpslv_l2dbs_dw_strb[15:0]),
    .gov_mbistreq_i                  (gov_mbistreq_i),
    .gov_mbistarray0_i               (gov_mbistarray0_i[8:0]),
    // Outputs
    .l2db_tagctl_available_o         (l2db7_tagctl_available),
    .l2db_tagctl_for_snoop_o         (l2db7_tagctl_for_snoop),
    .l2db_tagctl_for_write_o         (l2db7_tagctl_for_write),
    .l2db_full_line_o                (l2db7_full_line),
    .l2db_rmw_line_o                 (l2db7_rmw_line),
    .l2db_slv_done_o                 (l2db7_slv_done),
    .l2db_snpslv_done_o              (l2db7_snpslv_done),
    .l2db_slv_master_arb_o           (l2db7_slv_master_arb),
    .l2db_master_valid_o             (l2db7_master_valid),
    .l2db_master_id_o                (l2db7_master_id[5:0]),
    .l2db_master_dbid_o              (l2db7_master_dbid[7:0]),
    .l2db_master_tgtid_o             (l2db7_master_tgtid[6:0]),
    .l2db_master_qos_o               (l2db7_master_qos[3:0]),
    .l2db_master_snoop_o             (l2db7_master_snoop),
    .l2db_master_data_o              (l2db7_master_data[127:0]),
    .l2db_master_strb_o              (l2db7_master_strb[15:0]),
    .l2db_master_chunk_o             (l2db7_master_chunk[1:0]),
    .l2db_master_last_o              (l2db7_master_last),
    .l2db_master_opcode_o            (l2db7_master_opcode[2:0]),
    .l2db_master_snpresp_o           (l2db7_master_snpresp[2:0]),
    .l2db_master_len_o               (l2db7_master_len[1:0]),
    .l2db_master_size_o              (l2db7_master_size[2:0]),
    .l2db_master_addr_o              (l2db7_master_addr[5:0]),
    .l2db_master_attrs_o             (l2db7_master_attrs[7:0]),
    .l2db_master_prot_o              (l2db7_master_prot),
    .l2db_master_strex_o             (l2db7_master_strex),
    .l2db_master_unique_o            (l2db7_master_unique),
    .l2db_master_err_o               (l2db7_master_err),
    .l2db_master_invalidated_o       (l2db7_master_invalidated),
    .l2db_master_dirty_o             (l2db7_master_dirty),
    .l2db_ramctl_valid_o             (l2db7_ramctl_valid),
    .l2db_ramctl_rw_o                (l2db7_ramctl_rw[1:0]),
    .l2db_ramctl_index_o             (l2db7_ramctl_index[10:0]),
    .l2db_ramctl_way_o               (l2db7_ramctl_way[3:0]),
    .l2db_ramctl_data_o              (l2db7_ramctl_data[255:0]),
    .l2db_ramctl_banks_o             (l2db7_ramctl_banks[7:0]),
    .l2db_ramctl_err_o               (l2db7_ramctl_err),
    .l2db_slv_valid_o                (l2db7_slv_valid),
    .l2db_slv_id_o                   (l2db7_slv_id[5:0]),
    .l2db_slv_biuid_o                (l2db7_slv_biuid[4:0]),
    .l2db_slv_data_o                 (l2db7_slv_data[127:0]),
    .l2db_slv_chunk_o                (l2db7_slv_chunk[1:0]),
    .l2db_slv_last_o                 (l2db7_slv_last),
    .l2db_slv_bypass_o               (l2db7_slv_bypass),
    .l2db_slv_err_o                  (l2db7_slv_err),
    .l2db_cpuslv0_data_active_o      (l2db7_cpuslv0_data_active),
    .l2db_cpuslv1_data_active_o      (l2db7_cpuslv1_data_active),
    .l2db_cpuslv2_data_active_o      (l2db7_cpuslv2_data_active),
    .l2db_cpuslv3_data_active_o      (l2db7_cpuslv3_data_active)
  );  // u_scu_l2db7

  ca53scu_l2db #(`CA53_SCU_INT_PARAM_INST, .L2DB_NUM(4'b1000)) u_scu_l2db8 (
    // TEMPLATE s/l2db_/l2db8_/
    /*ARMAUTO*/
    // Inputs
    .CLKIN                           (CLKIN),
    .clk                             (clk),
    .reset_n                         (reset_n),
    .DFTSE                           (DFTSE),
    .tagctl_l2db_alloc_i             (tagctl_l2db8_alloc),
    .tagctl_alloc_for_snoop_i        (tagctl_alloc_for_snoop),
    .tagctl_alloc_for_write_i        (tagctl_alloc_for_write),
    .tagctl_l2db_release_i           (tagctl_l2db8_release),
    .tagctl_l2db_snoops_done_i       (tagctl_l2db8_snoops_done),
    .tagctl_l2db_fill_strbs_i        (tagctl_l2db8_fill_strbs),
    .master_afb0_ack_i               (master_afb0_ack),
    .master_afb1_ack_i               (master_afb1_ack),
    .master_afb2_ack_i               (master_afb2_ack),
    .master_afb3_ack_i               (master_afb3_ack),
    .master_afb4_ack_i               (master_afb4_ack),
    .master_afb5_ack_i               (master_afb5_ack),
    .master_afb_waddr_id_i           (master_afb_waddr_id[3:0]),
    .master_rsp_dbid_valid_i         (master_rsp_dbid_valid),
    .master_rsp_comp_valid_i         (master_rsp_comp_valid),
    .master_rsp_txnid_i              (master_rsp_txnid[6:0]),
    .master_rsp_dbid_i               (master_rsp_dbid[7:0]),
    .master_rsp_srcid_i              (master_rsp_srcid[6:0]),
    .cpuslv0_l2dbs_active_i          (cpuslv0_l2dbs_active),
    .cpuslv0_l2db_transfer_i         (cpuslv0_l2db8_transfer),
    .cpuslv0_l2db_transfer_type_i    (cpuslv0_l2db8_transfer_type[2:0]),
    .cpuslv0_l2db_transfer_info_i    (cpuslv0_l2db8_transfer_info[23:0]),
    .cpuslv0_l2db_release_i          (cpuslv0_l2db8_release),
    .cpuslv1_l2dbs_active_i          (cpuslv1_l2dbs_active),
    .cpuslv1_l2db_transfer_i         (cpuslv1_l2db8_transfer),
    .cpuslv1_l2db_transfer_type_i    (cpuslv1_l2db8_transfer_type[2:0]),
    .cpuslv1_l2db_transfer_info_i    (cpuslv1_l2db8_transfer_info[23:0]),
    .cpuslv1_l2db_release_i          (cpuslv1_l2db8_release),
    .cpuslv2_l2dbs_active_i          (cpuslv2_l2dbs_active),
    .cpuslv2_l2db_transfer_i         (cpuslv2_l2db8_transfer),
    .cpuslv2_l2db_transfer_type_i    (cpuslv2_l2db8_transfer_type[2:0]),
    .cpuslv2_l2db_transfer_info_i    (cpuslv2_l2db8_transfer_info[23:0]),
    .cpuslv2_l2db_release_i          (cpuslv2_l2db8_release),
    .cpuslv3_l2dbs_active_i          (cpuslv3_l2dbs_active),
    .cpuslv3_l2db_transfer_i         (cpuslv3_l2db8_transfer),
    .cpuslv3_l2db_transfer_type_i    (cpuslv3_l2db8_transfer_type[2:0]),
    .cpuslv3_l2db_transfer_info_i    (cpuslv3_l2db8_transfer_info[23:0]),
    .cpuslv3_l2db_release_i          (cpuslv3_l2db8_release),
    .acpslv_l2dbs_active_i           (acpslv_l2dbs_active),
    .acpslv_l2db_transfer_i          (acpslv_l2db8_transfer),
    .acpslv_l2db_transfer_type_i     (acpslv_l2db8_transfer_type[2:0]),
    .acpslv_l2db_transfer_info_i     (acpslv_l2db8_transfer_info[25:0]),
    .acpslv_l2db_release_i           (acpslv_l2db8_release),
    .snpslv_l2dbs_active_i           (snpslv_l2dbs_active),
    .snpslv_l2db_transfer_i          (snpslv_l2db8_transfer),
    .snpslv_l2db_transfer_type_i     (snpslv_l2db8_transfer_type[2:0]),
    .snpslv_l2db_transfer_info_i     (snpslv_l2db8_transfer_info[28:0]),
    .snpslv_l2db_release_i           (snpslv_l2db8_release),
    .snpslv_l2db_invalidate_i        (snpslv_l2db8_invalidate),
    .snpslv_l2db_makeshared_i        (snpslv_l2db8_makeshared),
    .afb0_l2dbs_transfer_i           (afb0_l2dbs_transfer),
    .afb0_l2dbs_id_i                 (afb0_l2dbs_id[3:0]),
    .afb0_l2dbs_transfer_info_i      (afb0_l2dbs_transfer_info[23:0]),
    .afb1_l2dbs_transfer_i           (afb1_l2dbs_transfer),
    .afb1_l2dbs_id_i                 (afb1_l2dbs_id[3:0]),
    .afb1_l2dbs_transfer_info_i      (afb1_l2dbs_transfer_info[23:0]),
    .afb2_l2dbs_transfer_i           (afb2_l2dbs_transfer),
    .afb2_l2dbs_id_i                 (afb2_l2dbs_id[3:0]),
    .afb2_l2dbs_transfer_info_i      (afb2_l2dbs_transfer_info[23:0]),
    .afb3_l2dbs_transfer_i           (afb3_l2dbs_transfer),
    .afb3_l2dbs_id_i                 (afb3_l2dbs_id[3:0]),
    .afb3_l2dbs_transfer_info_i      (afb3_l2dbs_transfer_info[23:0]),
    .afb4_l2dbs_transfer_i           (afb4_l2dbs_transfer),
    .afb4_l2dbs_id_i                 (afb4_l2dbs_id[3:0]),
    .afb4_l2dbs_transfer_info_i      (afb4_l2dbs_transfer_info[23:0]),
    .afb5_l2dbs_transfer_i           (afb5_l2dbs_transfer),
    .afb5_l2dbs_id_i                 (afb5_l2dbs_id[3:0]),
    .afb5_l2dbs_transfer_info_i      (afb5_l2dbs_transfer_info[23:0]),
    .master_l2db_ready_i             (master_l2db8_ready),
    .ramctl_l2db_ready_i             (ramctl_l2db8_ready),
    .cpuslv0_l2db_ready_i            (cpuslv0_l2db8_ready),
    .cpuslv1_l2db_ready_i            (cpuslv1_l2db8_ready),
    .cpuslv2_l2db_ready_i            (cpuslv2_l2db8_ready),
    .cpuslv3_l2db_ready_i            (cpuslv3_l2db8_ready),
    .acpslv_l2db_ready_i             (acpslv_l2db8_ready),
    .master_early_dr_valid_i         (master_early_dr_valid),
    .master_early_dr_id_i            (master_early_dr_id[5:0]),
    .master_early_dr_chunk_i         (master_early_dr_chunk[1:0]),
    .master_early_dr_data_i          (master_early_dr_data[127:0]),
    .ramctl_l2dbs_valid_i            (ramctl_l2dbs_valid),
    .ramctl_l2dbs_id_i               (ramctl_l2dbs_id[3:0]),
    .ramctl_l2dbs_data_i             (ramctl_l2dbs_data[255:0]),
    .ramctl_l2dbs_chunk_i            (ramctl_l2dbs_chunk[1:0]),
    .ramctl_l2dbs_err_i              (ramctl_l2dbs_err),
    .ramctl_l2dbs_last_i             (ramctl_l2dbs_last),
    .ramctl_l2dbs_bypass_i           (ramctl_l2dbs_bypass),
    .ramctl_l2dbs_bypass_id_i        (ramctl_l2dbs_bypass_id[3:0]),
    .ramctl_bypassed_err_i           (ramctl_bypassed_err),
    .cpuslv0_l2dbs_dw_valid_i        (cpuslv0_l2dbs_dw_valid),
    .cpuslv0_l2dbs_dw_id_i           (cpuslv0_l2dbs_dw_id[3:0]),
    .cpuslv0_l2dbs_dw_chunks_valid_i (cpuslv0_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv0_l2dbs_dw_last_i         (cpuslv0_l2dbs_dw_last),
    .cpuslv0_l2dbs_dw_data_i         (cpuslv0_l2dbs_dw_data[255:0]),
    .cpuslv0_l2dbs_dw_strb_i         (cpuslv0_l2dbs_dw_strb[31:0]),
    .cpuslv0_l2dbs_dw_err_i          (cpuslv0_l2dbs_dw_err),
    .cpuslv0_l2dbs_dw_fatal_i        (cpuslv0_l2dbs_dw_fatal),
    .cpuslv1_l2dbs_dw_valid_i        (cpuslv1_l2dbs_dw_valid),
    .cpuslv1_l2dbs_dw_id_i           (cpuslv1_l2dbs_dw_id[3:0]),
    .cpuslv1_l2dbs_dw_chunks_valid_i (cpuslv1_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv1_l2dbs_dw_last_i         (cpuslv1_l2dbs_dw_last),
    .cpuslv1_l2dbs_dw_data_i         (cpuslv1_l2dbs_dw_data[255:0]),
    .cpuslv1_l2dbs_dw_strb_i         (cpuslv1_l2dbs_dw_strb[31:0]),
    .cpuslv1_l2dbs_dw_err_i          (cpuslv1_l2dbs_dw_err),
    .cpuslv1_l2dbs_dw_fatal_i        (cpuslv1_l2dbs_dw_fatal),
    .cpuslv2_l2dbs_dw_valid_i        (cpuslv2_l2dbs_dw_valid),
    .cpuslv2_l2dbs_dw_id_i           (cpuslv2_l2dbs_dw_id[3:0]),
    .cpuslv2_l2dbs_dw_chunks_valid_i (cpuslv2_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv2_l2dbs_dw_last_i         (cpuslv2_l2dbs_dw_last),
    .cpuslv2_l2dbs_dw_data_i         (cpuslv2_l2dbs_dw_data[255:0]),
    .cpuslv2_l2dbs_dw_strb_i         (cpuslv2_l2dbs_dw_strb[31:0]),
    .cpuslv2_l2dbs_dw_err_i          (cpuslv2_l2dbs_dw_err),
    .cpuslv2_l2dbs_dw_fatal_i        (cpuslv2_l2dbs_dw_fatal),
    .cpuslv3_l2dbs_dw_valid_i        (cpuslv3_l2dbs_dw_valid),
    .cpuslv3_l2dbs_dw_id_i           (cpuslv3_l2dbs_dw_id[3:0]),
    .cpuslv3_l2dbs_dw_chunks_valid_i (cpuslv3_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv3_l2dbs_dw_last_i         (cpuslv3_l2dbs_dw_last),
    .cpuslv3_l2dbs_dw_data_i         (cpuslv3_l2dbs_dw_data[255:0]),
    .cpuslv3_l2dbs_dw_strb_i         (cpuslv3_l2dbs_dw_strb[31:0]),
    .cpuslv3_l2dbs_dw_err_i          (cpuslv3_l2dbs_dw_err),
    .cpuslv3_l2dbs_dw_fatal_i        (cpuslv3_l2dbs_dw_fatal),
    .acpslv_l2dbs_dw_valid_i         (acpslv_l2dbs_dw_valid),
    .acpslv_l2dbs_dw_id_i            (acpslv_l2dbs_dw_id[3:0]),
    .acpslv_l2dbs_dw_chunk_i         (acpslv_l2dbs_dw_chunk[1:0]),
    .acpslv_l2dbs_dw_last_i          (acpslv_l2dbs_dw_last),
    .acpslv_l2dbs_dw_data_i          (acpslv_l2dbs_dw_data[127:0]),
    .acpslv_l2dbs_dw_strb_i          (acpslv_l2dbs_dw_strb[15:0]),
    .gov_mbistreq_i                  (gov_mbistreq_i),
    .gov_mbistarray0_i               (gov_mbistarray0_i[8:0]),
    // Outputs
    .l2db_tagctl_available_o         (l2db8_tagctl_available),
    .l2db_tagctl_for_snoop_o         (l2db8_tagctl_for_snoop),
    .l2db_tagctl_for_write_o         (l2db8_tagctl_for_write),
    .l2db_full_line_o                (l2db8_full_line),
    .l2db_rmw_line_o                 (l2db8_rmw_line),
    .l2db_slv_done_o                 (l2db8_slv_done),
    .l2db_snpslv_done_o              (l2db8_snpslv_done),
    .l2db_slv_master_arb_o           (l2db8_slv_master_arb),
    .l2db_master_valid_o             (l2db8_master_valid),
    .l2db_master_id_o                (l2db8_master_id[5:0]),
    .l2db_master_dbid_o              (l2db8_master_dbid[7:0]),
    .l2db_master_tgtid_o             (l2db8_master_tgtid[6:0]),
    .l2db_master_qos_o               (l2db8_master_qos[3:0]),
    .l2db_master_snoop_o             (l2db8_master_snoop),
    .l2db_master_data_o              (l2db8_master_data[127:0]),
    .l2db_master_strb_o              (l2db8_master_strb[15:0]),
    .l2db_master_chunk_o             (l2db8_master_chunk[1:0]),
    .l2db_master_last_o              (l2db8_master_last),
    .l2db_master_opcode_o            (l2db8_master_opcode[2:0]),
    .l2db_master_snpresp_o           (l2db8_master_snpresp[2:0]),
    .l2db_master_len_o               (l2db8_master_len[1:0]),
    .l2db_master_size_o              (l2db8_master_size[2:0]),
    .l2db_master_addr_o              (l2db8_master_addr[5:0]),
    .l2db_master_attrs_o             (l2db8_master_attrs[7:0]),
    .l2db_master_prot_o              (l2db8_master_prot),
    .l2db_master_strex_o             (l2db8_master_strex),
    .l2db_master_unique_o            (l2db8_master_unique),
    .l2db_master_err_o               (l2db8_master_err),
    .l2db_master_invalidated_o       (l2db8_master_invalidated),
    .l2db_master_dirty_o             (l2db8_master_dirty),
    .l2db_ramctl_valid_o             (l2db8_ramctl_valid),
    .l2db_ramctl_rw_o                (l2db8_ramctl_rw[1:0]),
    .l2db_ramctl_index_o             (l2db8_ramctl_index[10:0]),
    .l2db_ramctl_way_o               (l2db8_ramctl_way[3:0]),
    .l2db_ramctl_data_o              (l2db8_ramctl_data[255:0]),
    .l2db_ramctl_banks_o             (l2db8_ramctl_banks[7:0]),
    .l2db_ramctl_err_o               (l2db8_ramctl_err),
    .l2db_slv_valid_o                (l2db8_slv_valid),
    .l2db_slv_id_o                   (l2db8_slv_id[5:0]),
    .l2db_slv_biuid_o                (l2db8_slv_biuid[4:0]),
    .l2db_slv_data_o                 (l2db8_slv_data[127:0]),
    .l2db_slv_chunk_o                (l2db8_slv_chunk[1:0]),
    .l2db_slv_last_o                 (l2db8_slv_last),
    .l2db_slv_bypass_o               (l2db8_slv_bypass),
    .l2db_slv_err_o                  (l2db8_slv_err),
    .l2db_cpuslv0_data_active_o      (l2db8_cpuslv0_data_active),
    .l2db_cpuslv1_data_active_o      (l2db8_cpuslv1_data_active),
    .l2db_cpuslv2_data_active_o      (l2db8_cpuslv2_data_active),
    .l2db_cpuslv3_data_active_o      (l2db8_cpuslv3_data_active)
  );  // u_scu_l2db8

  ca53scu_l2db #(`CA53_SCU_INT_PARAM_INST, .L2DB_NUM(4'b1001)) u_scu_l2db9 (
    // TEMPLATE s/l2db_/l2db9_/
    /*ARMAUTO*/
    // Inputs
    .CLKIN                           (CLKIN),
    .clk                             (clk),
    .reset_n                         (reset_n),
    .DFTSE                           (DFTSE),
    .tagctl_l2db_alloc_i             (tagctl_l2db9_alloc),
    .tagctl_alloc_for_snoop_i        (tagctl_alloc_for_snoop),
    .tagctl_alloc_for_write_i        (tagctl_alloc_for_write),
    .tagctl_l2db_release_i           (tagctl_l2db9_release),
    .tagctl_l2db_snoops_done_i       (tagctl_l2db9_snoops_done),
    .tagctl_l2db_fill_strbs_i        (tagctl_l2db9_fill_strbs),
    .master_afb0_ack_i               (master_afb0_ack),
    .master_afb1_ack_i               (master_afb1_ack),
    .master_afb2_ack_i               (master_afb2_ack),
    .master_afb3_ack_i               (master_afb3_ack),
    .master_afb4_ack_i               (master_afb4_ack),
    .master_afb5_ack_i               (master_afb5_ack),
    .master_afb_waddr_id_i           (master_afb_waddr_id[3:0]),
    .master_rsp_dbid_valid_i         (master_rsp_dbid_valid),
    .master_rsp_comp_valid_i         (master_rsp_comp_valid),
    .master_rsp_txnid_i              (master_rsp_txnid[6:0]),
    .master_rsp_dbid_i               (master_rsp_dbid[7:0]),
    .master_rsp_srcid_i              (master_rsp_srcid[6:0]),
    .cpuslv0_l2dbs_active_i          (cpuslv0_l2dbs_active),
    .cpuslv0_l2db_transfer_i         (cpuslv0_l2db9_transfer),
    .cpuslv0_l2db_transfer_type_i    (cpuslv0_l2db9_transfer_type[2:0]),
    .cpuslv0_l2db_transfer_info_i    (cpuslv0_l2db9_transfer_info[23:0]),
    .cpuslv0_l2db_release_i          (cpuslv0_l2db9_release),
    .cpuslv1_l2dbs_active_i          (cpuslv1_l2dbs_active),
    .cpuslv1_l2db_transfer_i         (cpuslv1_l2db9_transfer),
    .cpuslv1_l2db_transfer_type_i    (cpuslv1_l2db9_transfer_type[2:0]),
    .cpuslv1_l2db_transfer_info_i    (cpuslv1_l2db9_transfer_info[23:0]),
    .cpuslv1_l2db_release_i          (cpuslv1_l2db9_release),
    .cpuslv2_l2dbs_active_i          (cpuslv2_l2dbs_active),
    .cpuslv2_l2db_transfer_i         (cpuslv2_l2db9_transfer),
    .cpuslv2_l2db_transfer_type_i    (cpuslv2_l2db9_transfer_type[2:0]),
    .cpuslv2_l2db_transfer_info_i    (cpuslv2_l2db9_transfer_info[23:0]),
    .cpuslv2_l2db_release_i          (cpuslv2_l2db9_release),
    .cpuslv3_l2dbs_active_i          (cpuslv3_l2dbs_active),
    .cpuslv3_l2db_transfer_i         (cpuslv3_l2db9_transfer),
    .cpuslv3_l2db_transfer_type_i    (cpuslv3_l2db9_transfer_type[2:0]),
    .cpuslv3_l2db_transfer_info_i    (cpuslv3_l2db9_transfer_info[23:0]),
    .cpuslv3_l2db_release_i          (cpuslv3_l2db9_release),
    .acpslv_l2dbs_active_i           (acpslv_l2dbs_active),
    .acpslv_l2db_transfer_i          (acpslv_l2db9_transfer),
    .acpslv_l2db_transfer_type_i     (acpslv_l2db9_transfer_type[2:0]),
    .acpslv_l2db_transfer_info_i     (acpslv_l2db9_transfer_info[25:0]),
    .acpslv_l2db_release_i           (acpslv_l2db9_release),
    .snpslv_l2dbs_active_i           (snpslv_l2dbs_active),
    .snpslv_l2db_transfer_i          (snpslv_l2db9_transfer),
    .snpslv_l2db_transfer_type_i     (snpslv_l2db9_transfer_type[2:0]),
    .snpslv_l2db_transfer_info_i     (snpslv_l2db9_transfer_info[28:0]),
    .snpslv_l2db_release_i           (snpslv_l2db9_release),
    .snpslv_l2db_invalidate_i        (snpslv_l2db9_invalidate),
    .snpslv_l2db_makeshared_i        (snpslv_l2db9_makeshared),
    .afb0_l2dbs_transfer_i           (afb0_l2dbs_transfer),
    .afb0_l2dbs_id_i                 (afb0_l2dbs_id[3:0]),
    .afb0_l2dbs_transfer_info_i      (afb0_l2dbs_transfer_info[23:0]),
    .afb1_l2dbs_transfer_i           (afb1_l2dbs_transfer),
    .afb1_l2dbs_id_i                 (afb1_l2dbs_id[3:0]),
    .afb1_l2dbs_transfer_info_i      (afb1_l2dbs_transfer_info[23:0]),
    .afb2_l2dbs_transfer_i           (afb2_l2dbs_transfer),
    .afb2_l2dbs_id_i                 (afb2_l2dbs_id[3:0]),
    .afb2_l2dbs_transfer_info_i      (afb2_l2dbs_transfer_info[23:0]),
    .afb3_l2dbs_transfer_i           (afb3_l2dbs_transfer),
    .afb3_l2dbs_id_i                 (afb3_l2dbs_id[3:0]),
    .afb3_l2dbs_transfer_info_i      (afb3_l2dbs_transfer_info[23:0]),
    .afb4_l2dbs_transfer_i           (afb4_l2dbs_transfer),
    .afb4_l2dbs_id_i                 (afb4_l2dbs_id[3:0]),
    .afb4_l2dbs_transfer_info_i      (afb4_l2dbs_transfer_info[23:0]),
    .afb5_l2dbs_transfer_i           (afb5_l2dbs_transfer),
    .afb5_l2dbs_id_i                 (afb5_l2dbs_id[3:0]),
    .afb5_l2dbs_transfer_info_i      (afb5_l2dbs_transfer_info[23:0]),
    .master_l2db_ready_i             (master_l2db9_ready),
    .ramctl_l2db_ready_i             (ramctl_l2db9_ready),
    .cpuslv0_l2db_ready_i            (cpuslv0_l2db9_ready),
    .cpuslv1_l2db_ready_i            (cpuslv1_l2db9_ready),
    .cpuslv2_l2db_ready_i            (cpuslv2_l2db9_ready),
    .cpuslv3_l2db_ready_i            (cpuslv3_l2db9_ready),
    .acpslv_l2db_ready_i             (acpslv_l2db9_ready),
    .master_early_dr_valid_i         (master_early_dr_valid),
    .master_early_dr_id_i            (master_early_dr_id[5:0]),
    .master_early_dr_chunk_i         (master_early_dr_chunk[1:0]),
    .master_early_dr_data_i          (master_early_dr_data[127:0]),
    .ramctl_l2dbs_valid_i            (ramctl_l2dbs_valid),
    .ramctl_l2dbs_id_i               (ramctl_l2dbs_id[3:0]),
    .ramctl_l2dbs_data_i             (ramctl_l2dbs_data[255:0]),
    .ramctl_l2dbs_chunk_i            (ramctl_l2dbs_chunk[1:0]),
    .ramctl_l2dbs_err_i              (ramctl_l2dbs_err),
    .ramctl_l2dbs_last_i             (ramctl_l2dbs_last),
    .ramctl_l2dbs_bypass_i           (ramctl_l2dbs_bypass),
    .ramctl_l2dbs_bypass_id_i        (ramctl_l2dbs_bypass_id[3:0]),
    .ramctl_bypassed_err_i           (ramctl_bypassed_err),
    .cpuslv0_l2dbs_dw_valid_i        (cpuslv0_l2dbs_dw_valid),
    .cpuslv0_l2dbs_dw_id_i           (cpuslv0_l2dbs_dw_id[3:0]),
    .cpuslv0_l2dbs_dw_chunks_valid_i (cpuslv0_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv0_l2dbs_dw_last_i         (cpuslv0_l2dbs_dw_last),
    .cpuslv0_l2dbs_dw_data_i         (cpuslv0_l2dbs_dw_data[255:0]),
    .cpuslv0_l2dbs_dw_strb_i         (cpuslv0_l2dbs_dw_strb[31:0]),
    .cpuslv0_l2dbs_dw_err_i          (cpuslv0_l2dbs_dw_err),
    .cpuslv0_l2dbs_dw_fatal_i        (cpuslv0_l2dbs_dw_fatal),
    .cpuslv1_l2dbs_dw_valid_i        (cpuslv1_l2dbs_dw_valid),
    .cpuslv1_l2dbs_dw_id_i           (cpuslv1_l2dbs_dw_id[3:0]),
    .cpuslv1_l2dbs_dw_chunks_valid_i (cpuslv1_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv1_l2dbs_dw_last_i         (cpuslv1_l2dbs_dw_last),
    .cpuslv1_l2dbs_dw_data_i         (cpuslv1_l2dbs_dw_data[255:0]),
    .cpuslv1_l2dbs_dw_strb_i         (cpuslv1_l2dbs_dw_strb[31:0]),
    .cpuslv1_l2dbs_dw_err_i          (cpuslv1_l2dbs_dw_err),
    .cpuslv1_l2dbs_dw_fatal_i        (cpuslv1_l2dbs_dw_fatal),
    .cpuslv2_l2dbs_dw_valid_i        (cpuslv2_l2dbs_dw_valid),
    .cpuslv2_l2dbs_dw_id_i           (cpuslv2_l2dbs_dw_id[3:0]),
    .cpuslv2_l2dbs_dw_chunks_valid_i (cpuslv2_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv2_l2dbs_dw_last_i         (cpuslv2_l2dbs_dw_last),
    .cpuslv2_l2dbs_dw_data_i         (cpuslv2_l2dbs_dw_data[255:0]),
    .cpuslv2_l2dbs_dw_strb_i         (cpuslv2_l2dbs_dw_strb[31:0]),
    .cpuslv2_l2dbs_dw_err_i          (cpuslv2_l2dbs_dw_err),
    .cpuslv2_l2dbs_dw_fatal_i        (cpuslv2_l2dbs_dw_fatal),
    .cpuslv3_l2dbs_dw_valid_i        (cpuslv3_l2dbs_dw_valid),
    .cpuslv3_l2dbs_dw_id_i           (cpuslv3_l2dbs_dw_id[3:0]),
    .cpuslv3_l2dbs_dw_chunks_valid_i (cpuslv3_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv3_l2dbs_dw_last_i         (cpuslv3_l2dbs_dw_last),
    .cpuslv3_l2dbs_dw_data_i         (cpuslv3_l2dbs_dw_data[255:0]),
    .cpuslv3_l2dbs_dw_strb_i         (cpuslv3_l2dbs_dw_strb[31:0]),
    .cpuslv3_l2dbs_dw_err_i          (cpuslv3_l2dbs_dw_err),
    .cpuslv3_l2dbs_dw_fatal_i        (cpuslv3_l2dbs_dw_fatal),
    .acpslv_l2dbs_dw_valid_i         (acpslv_l2dbs_dw_valid),
    .acpslv_l2dbs_dw_id_i            (acpslv_l2dbs_dw_id[3:0]),
    .acpslv_l2dbs_dw_chunk_i         (acpslv_l2dbs_dw_chunk[1:0]),
    .acpslv_l2dbs_dw_last_i          (acpslv_l2dbs_dw_last),
    .acpslv_l2dbs_dw_data_i          (acpslv_l2dbs_dw_data[127:0]),
    .acpslv_l2dbs_dw_strb_i          (acpslv_l2dbs_dw_strb[15:0]),
    .gov_mbistreq_i                  (gov_mbistreq_i),
    .gov_mbistarray0_i               (gov_mbistarray0_i[8:0]),
    // Outputs
    .l2db_tagctl_available_o         (l2db9_tagctl_available),
    .l2db_tagctl_for_snoop_o         (l2db9_tagctl_for_snoop),
    .l2db_tagctl_for_write_o         (l2db9_tagctl_for_write),
    .l2db_full_line_o                (l2db9_full_line),
    .l2db_rmw_line_o                 (l2db9_rmw_line),
    .l2db_slv_done_o                 (l2db9_slv_done),
    .l2db_snpslv_done_o              (l2db9_snpslv_done),
    .l2db_slv_master_arb_o           (l2db9_slv_master_arb),
    .l2db_master_valid_o             (l2db9_master_valid),
    .l2db_master_id_o                (l2db9_master_id[5:0]),
    .l2db_master_dbid_o              (l2db9_master_dbid[7:0]),
    .l2db_master_tgtid_o             (l2db9_master_tgtid[6:0]),
    .l2db_master_qos_o               (l2db9_master_qos[3:0]),
    .l2db_master_snoop_o             (l2db9_master_snoop),
    .l2db_master_data_o              (l2db9_master_data[127:0]),
    .l2db_master_strb_o              (l2db9_master_strb[15:0]),
    .l2db_master_chunk_o             (l2db9_master_chunk[1:0]),
    .l2db_master_last_o              (l2db9_master_last),
    .l2db_master_opcode_o            (l2db9_master_opcode[2:0]),
    .l2db_master_snpresp_o           (l2db9_master_snpresp[2:0]),
    .l2db_master_len_o               (l2db9_master_len[1:0]),
    .l2db_master_size_o              (l2db9_master_size[2:0]),
    .l2db_master_addr_o              (l2db9_master_addr[5:0]),
    .l2db_master_attrs_o             (l2db9_master_attrs[7:0]),
    .l2db_master_prot_o              (l2db9_master_prot),
    .l2db_master_strex_o             (l2db9_master_strex),
    .l2db_master_unique_o            (l2db9_master_unique),
    .l2db_master_err_o               (l2db9_master_err),
    .l2db_master_invalidated_o       (l2db9_master_invalidated),
    .l2db_master_dirty_o             (l2db9_master_dirty),
    .l2db_ramctl_valid_o             (l2db9_ramctl_valid),
    .l2db_ramctl_rw_o                (l2db9_ramctl_rw[1:0]),
    .l2db_ramctl_index_o             (l2db9_ramctl_index[10:0]),
    .l2db_ramctl_way_o               (l2db9_ramctl_way[3:0]),
    .l2db_ramctl_data_o              (l2db9_ramctl_data[255:0]),
    .l2db_ramctl_banks_o             (l2db9_ramctl_banks[7:0]),
    .l2db_ramctl_err_o               (l2db9_ramctl_err),
    .l2db_slv_valid_o                (l2db9_slv_valid),
    .l2db_slv_id_o                   (l2db9_slv_id[5:0]),
    .l2db_slv_biuid_o                (l2db9_slv_biuid[4:0]),
    .l2db_slv_data_o                 (l2db9_slv_data[127:0]),
    .l2db_slv_chunk_o                (l2db9_slv_chunk[1:0]),
    .l2db_slv_last_o                 (l2db9_slv_last),
    .l2db_slv_bypass_o               (l2db9_slv_bypass),
    .l2db_slv_err_o                  (l2db9_slv_err),
    .l2db_cpuslv0_data_active_o      (l2db9_cpuslv0_data_active),
    .l2db_cpuslv1_data_active_o      (l2db9_cpuslv1_data_active),
    .l2db_cpuslv2_data_active_o      (l2db9_cpuslv2_data_active),
    .l2db_cpuslv3_data_active_o      (l2db9_cpuslv3_data_active)
  );  // u_scu_l2db9

  ca53scu_l2db #(`CA53_SCU_INT_PARAM_INST, .L2DB_NUM(4'b1010)) u_scu_l2db10 (
    // TEMPLATE s/l2db_/l2db10_/
    /*ARMAUTO*/
    // Inputs
    .CLKIN                           (CLKIN),
    .clk                             (clk),
    .reset_n                         (reset_n),
    .DFTSE                           (DFTSE),
    .tagctl_l2db_alloc_i             (tagctl_l2db10_alloc),
    .tagctl_alloc_for_snoop_i        (tagctl_alloc_for_snoop),
    .tagctl_alloc_for_write_i        (tagctl_alloc_for_write),
    .tagctl_l2db_release_i           (tagctl_l2db10_release),
    .tagctl_l2db_snoops_done_i       (tagctl_l2db10_snoops_done),
    .tagctl_l2db_fill_strbs_i        (tagctl_l2db10_fill_strbs),
    .master_afb0_ack_i               (master_afb0_ack),
    .master_afb1_ack_i               (master_afb1_ack),
    .master_afb2_ack_i               (master_afb2_ack),
    .master_afb3_ack_i               (master_afb3_ack),
    .master_afb4_ack_i               (master_afb4_ack),
    .master_afb5_ack_i               (master_afb5_ack),
    .master_afb_waddr_id_i           (master_afb_waddr_id[3:0]),
    .master_rsp_dbid_valid_i         (master_rsp_dbid_valid),
    .master_rsp_comp_valid_i         (master_rsp_comp_valid),
    .master_rsp_txnid_i              (master_rsp_txnid[6:0]),
    .master_rsp_dbid_i               (master_rsp_dbid[7:0]),
    .master_rsp_srcid_i              (master_rsp_srcid[6:0]),
    .cpuslv0_l2dbs_active_i          (cpuslv0_l2dbs_active),
    .cpuslv0_l2db_transfer_i         (cpuslv0_l2db10_transfer),
    .cpuslv0_l2db_transfer_type_i    (cpuslv0_l2db10_transfer_type[2:0]),
    .cpuslv0_l2db_transfer_info_i    (cpuslv0_l2db10_transfer_info[23:0]),
    .cpuslv0_l2db_release_i          (cpuslv0_l2db10_release),
    .cpuslv1_l2dbs_active_i          (cpuslv1_l2dbs_active),
    .cpuslv1_l2db_transfer_i         (cpuslv1_l2db10_transfer),
    .cpuslv1_l2db_transfer_type_i    (cpuslv1_l2db10_transfer_type[2:0]),
    .cpuslv1_l2db_transfer_info_i    (cpuslv1_l2db10_transfer_info[23:0]),
    .cpuslv1_l2db_release_i          (cpuslv1_l2db10_release),
    .cpuslv2_l2dbs_active_i          (cpuslv2_l2dbs_active),
    .cpuslv2_l2db_transfer_i         (cpuslv2_l2db10_transfer),
    .cpuslv2_l2db_transfer_type_i    (cpuslv2_l2db10_transfer_type[2:0]),
    .cpuslv2_l2db_transfer_info_i    (cpuslv2_l2db10_transfer_info[23:0]),
    .cpuslv2_l2db_release_i          (cpuslv2_l2db10_release),
    .cpuslv3_l2dbs_active_i          (cpuslv3_l2dbs_active),
    .cpuslv3_l2db_transfer_i         (cpuslv3_l2db10_transfer),
    .cpuslv3_l2db_transfer_type_i    (cpuslv3_l2db10_transfer_type[2:0]),
    .cpuslv3_l2db_transfer_info_i    (cpuslv3_l2db10_transfer_info[23:0]),
    .cpuslv3_l2db_release_i          (cpuslv3_l2db10_release),
    .acpslv_l2dbs_active_i           (acpslv_l2dbs_active),
    .acpslv_l2db_transfer_i          (acpslv_l2db10_transfer),
    .acpslv_l2db_transfer_type_i     (acpslv_l2db10_transfer_type[2:0]),
    .acpslv_l2db_transfer_info_i     (acpslv_l2db10_transfer_info[25:0]),
    .acpslv_l2db_release_i           (acpslv_l2db10_release),
    .snpslv_l2dbs_active_i           (snpslv_l2dbs_active),
    .snpslv_l2db_transfer_i          (snpslv_l2db10_transfer),
    .snpslv_l2db_transfer_type_i     (snpslv_l2db10_transfer_type[2:0]),
    .snpslv_l2db_transfer_info_i     (snpslv_l2db10_transfer_info[28:0]),
    .snpslv_l2db_release_i           (snpslv_l2db10_release),
    .snpslv_l2db_invalidate_i        (snpslv_l2db10_invalidate),
    .snpslv_l2db_makeshared_i        (snpslv_l2db10_makeshared),
    .afb0_l2dbs_transfer_i           (afb0_l2dbs_transfer),
    .afb0_l2dbs_id_i                 (afb0_l2dbs_id[3:0]),
    .afb0_l2dbs_transfer_info_i      (afb0_l2dbs_transfer_info[23:0]),
    .afb1_l2dbs_transfer_i           (afb1_l2dbs_transfer),
    .afb1_l2dbs_id_i                 (afb1_l2dbs_id[3:0]),
    .afb1_l2dbs_transfer_info_i      (afb1_l2dbs_transfer_info[23:0]),
    .afb2_l2dbs_transfer_i           (afb2_l2dbs_transfer),
    .afb2_l2dbs_id_i                 (afb2_l2dbs_id[3:0]),
    .afb2_l2dbs_transfer_info_i      (afb2_l2dbs_transfer_info[23:0]),
    .afb3_l2dbs_transfer_i           (afb3_l2dbs_transfer),
    .afb3_l2dbs_id_i                 (afb3_l2dbs_id[3:0]),
    .afb3_l2dbs_transfer_info_i      (afb3_l2dbs_transfer_info[23:0]),
    .afb4_l2dbs_transfer_i           (afb4_l2dbs_transfer),
    .afb4_l2dbs_id_i                 (afb4_l2dbs_id[3:0]),
    .afb4_l2dbs_transfer_info_i      (afb4_l2dbs_transfer_info[23:0]),
    .afb5_l2dbs_transfer_i           (afb5_l2dbs_transfer),
    .afb5_l2dbs_id_i                 (afb5_l2dbs_id[3:0]),
    .afb5_l2dbs_transfer_info_i      (afb5_l2dbs_transfer_info[23:0]),
    .master_l2db_ready_i             (master_l2db10_ready),
    .ramctl_l2db_ready_i             (ramctl_l2db10_ready),
    .cpuslv0_l2db_ready_i            (cpuslv0_l2db10_ready),
    .cpuslv1_l2db_ready_i            (cpuslv1_l2db10_ready),
    .cpuslv2_l2db_ready_i            (cpuslv2_l2db10_ready),
    .cpuslv3_l2db_ready_i            (cpuslv3_l2db10_ready),
    .acpslv_l2db_ready_i             (acpslv_l2db10_ready),
    .master_early_dr_valid_i         (master_early_dr_valid),
    .master_early_dr_id_i            (master_early_dr_id[5:0]),
    .master_early_dr_chunk_i         (master_early_dr_chunk[1:0]),
    .master_early_dr_data_i          (master_early_dr_data[127:0]),
    .ramctl_l2dbs_valid_i            (ramctl_l2dbs_valid),
    .ramctl_l2dbs_id_i               (ramctl_l2dbs_id[3:0]),
    .ramctl_l2dbs_data_i             (ramctl_l2dbs_data[255:0]),
    .ramctl_l2dbs_chunk_i            (ramctl_l2dbs_chunk[1:0]),
    .ramctl_l2dbs_err_i              (ramctl_l2dbs_err),
    .ramctl_l2dbs_last_i             (ramctl_l2dbs_last),
    .ramctl_l2dbs_bypass_i           (ramctl_l2dbs_bypass),
    .ramctl_l2dbs_bypass_id_i        (ramctl_l2dbs_bypass_id[3:0]),
    .ramctl_bypassed_err_i           (ramctl_bypassed_err),
    .cpuslv0_l2dbs_dw_valid_i        (cpuslv0_l2dbs_dw_valid),
    .cpuslv0_l2dbs_dw_id_i           (cpuslv0_l2dbs_dw_id[3:0]),
    .cpuslv0_l2dbs_dw_chunks_valid_i (cpuslv0_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv0_l2dbs_dw_last_i         (cpuslv0_l2dbs_dw_last),
    .cpuslv0_l2dbs_dw_data_i         (cpuslv0_l2dbs_dw_data[255:0]),
    .cpuslv0_l2dbs_dw_strb_i         (cpuslv0_l2dbs_dw_strb[31:0]),
    .cpuslv0_l2dbs_dw_err_i          (cpuslv0_l2dbs_dw_err),
    .cpuslv0_l2dbs_dw_fatal_i        (cpuslv0_l2dbs_dw_fatal),
    .cpuslv1_l2dbs_dw_valid_i        (cpuslv1_l2dbs_dw_valid),
    .cpuslv1_l2dbs_dw_id_i           (cpuslv1_l2dbs_dw_id[3:0]),
    .cpuslv1_l2dbs_dw_chunks_valid_i (cpuslv1_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv1_l2dbs_dw_last_i         (cpuslv1_l2dbs_dw_last),
    .cpuslv1_l2dbs_dw_data_i         (cpuslv1_l2dbs_dw_data[255:0]),
    .cpuslv1_l2dbs_dw_strb_i         (cpuslv1_l2dbs_dw_strb[31:0]),
    .cpuslv1_l2dbs_dw_err_i          (cpuslv1_l2dbs_dw_err),
    .cpuslv1_l2dbs_dw_fatal_i        (cpuslv1_l2dbs_dw_fatal),
    .cpuslv2_l2dbs_dw_valid_i        (cpuslv2_l2dbs_dw_valid),
    .cpuslv2_l2dbs_dw_id_i           (cpuslv2_l2dbs_dw_id[3:0]),
    .cpuslv2_l2dbs_dw_chunks_valid_i (cpuslv2_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv2_l2dbs_dw_last_i         (cpuslv2_l2dbs_dw_last),
    .cpuslv2_l2dbs_dw_data_i         (cpuslv2_l2dbs_dw_data[255:0]),
    .cpuslv2_l2dbs_dw_strb_i         (cpuslv2_l2dbs_dw_strb[31:0]),
    .cpuslv2_l2dbs_dw_err_i          (cpuslv2_l2dbs_dw_err),
    .cpuslv2_l2dbs_dw_fatal_i        (cpuslv2_l2dbs_dw_fatal),
    .cpuslv3_l2dbs_dw_valid_i        (cpuslv3_l2dbs_dw_valid),
    .cpuslv3_l2dbs_dw_id_i           (cpuslv3_l2dbs_dw_id[3:0]),
    .cpuslv3_l2dbs_dw_chunks_valid_i (cpuslv3_l2dbs_dw_chunks_valid[3:0]),
    .cpuslv3_l2dbs_dw_last_i         (cpuslv3_l2dbs_dw_last),
    .cpuslv3_l2dbs_dw_data_i         (cpuslv3_l2dbs_dw_data[255:0]),
    .cpuslv3_l2dbs_dw_strb_i         (cpuslv3_l2dbs_dw_strb[31:0]),
    .cpuslv3_l2dbs_dw_err_i          (cpuslv3_l2dbs_dw_err),
    .cpuslv3_l2dbs_dw_fatal_i        (cpuslv3_l2dbs_dw_fatal),
    .acpslv_l2dbs_dw_valid_i         (acpslv_l2dbs_dw_valid),
    .acpslv_l2dbs_dw_id_i            (acpslv_l2dbs_dw_id[3:0]),
    .acpslv_l2dbs_dw_chunk_i         (acpslv_l2dbs_dw_chunk[1:0]),
    .acpslv_l2dbs_dw_last_i          (acpslv_l2dbs_dw_last),
    .acpslv_l2dbs_dw_data_i          (acpslv_l2dbs_dw_data[127:0]),
    .acpslv_l2dbs_dw_strb_i          (acpslv_l2dbs_dw_strb[15:0]),
    .gov_mbistreq_i                  (gov_mbistreq_i),
    .gov_mbistarray0_i               (gov_mbistarray0_i[8:0]),
    // Outputs
    .l2db_tagctl_available_o         (l2db10_tagctl_available),
    .l2db_tagctl_for_snoop_o         (l2db10_tagctl_for_snoop),
    .l2db_tagctl_for_write_o         (l2db10_tagctl_for_write),
    .l2db_full_line_o                (l2db10_full_line),
    .l2db_rmw_line_o                 (l2db10_rmw_line),
    .l2db_slv_done_o                 (l2db10_slv_done),
    .l2db_snpslv_done_o              (l2db10_snpslv_done),
    .l2db_slv_master_arb_o           (l2db10_slv_master_arb),
    .l2db_master_valid_o             (l2db10_master_valid),
    .l2db_master_id_o                (l2db10_master_id[5:0]),
    .l2db_master_dbid_o              (l2db10_master_dbid[7:0]),
    .l2db_master_tgtid_o             (l2db10_master_tgtid[6:0]),
    .l2db_master_qos_o               (l2db10_master_qos[3:0]),
    .l2db_master_snoop_o             (l2db10_master_snoop),
    .l2db_master_data_o              (l2db10_master_data[127:0]),
    .l2db_master_strb_o              (l2db10_master_strb[15:0]),
    .l2db_master_chunk_o             (l2db10_master_chunk[1:0]),
    .l2db_master_last_o              (l2db10_master_last),
    .l2db_master_opcode_o            (l2db10_master_opcode[2:0]),
    .l2db_master_snpresp_o           (l2db10_master_snpresp[2:0]),
    .l2db_master_len_o               (l2db10_master_len[1:0]),
    .l2db_master_size_o              (l2db10_master_size[2:0]),
    .l2db_master_addr_o              (l2db10_master_addr[5:0]),
    .l2db_master_attrs_o             (l2db10_master_attrs[7:0]),
    .l2db_master_prot_o              (l2db10_master_prot),
    .l2db_master_strex_o             (l2db10_master_strex),
    .l2db_master_unique_o            (l2db10_master_unique),
    .l2db_master_err_o               (l2db10_master_err),
    .l2db_master_invalidated_o       (l2db10_master_invalidated),
    .l2db_master_dirty_o             (l2db10_master_dirty),
    .l2db_ramctl_valid_o             (l2db10_ramctl_valid),
    .l2db_ramctl_rw_o                (l2db10_ramctl_rw[1:0]),
    .l2db_ramctl_index_o             (l2db10_ramctl_index[10:0]),
    .l2db_ramctl_way_o               (l2db10_ramctl_way[3:0]),
    .l2db_ramctl_data_o              (l2db10_ramctl_data[255:0]),
    .l2db_ramctl_banks_o             (l2db10_ramctl_banks[7:0]),
    .l2db_ramctl_err_o               (l2db10_ramctl_err),
    .l2db_slv_valid_o                (l2db10_slv_valid),
    .l2db_slv_id_o                   (l2db10_slv_id[5:0]),
    .l2db_slv_biuid_o                (l2db10_slv_biuid[4:0]),
    .l2db_slv_data_o                 (l2db10_slv_data[127:0]),
    .l2db_slv_chunk_o                (l2db10_slv_chunk[1:0]),
    .l2db_slv_last_o                 (l2db10_slv_last),
    .l2db_slv_bypass_o               (l2db10_slv_bypass),
    .l2db_slv_err_o                  (l2db10_slv_err),
    .l2db_cpuslv0_data_active_o      (l2db10_cpuslv0_data_active),
    .l2db_cpuslv1_data_active_o      (l2db10_cpuslv1_data_active),
    .l2db_cpuslv2_data_active_o      (l2db10_cpuslv2_data_active),
    .l2db_cpuslv3_data_active_o      (l2db10_cpuslv3_data_active)
  );  // u_scu_l2db10

  ca53scu_ramctl #(`CA53_SCU_INT_PARAM_INST) u_scu_ramctl (
    /*ARMAUTO*/
    // Inputs
    .clk                            (clk),
    .reset_n                        (reset_n),
    .DFTSE                          (DFTSE),
    .DFTRAMHOLD                     (DFTRAMHOLD),
    .DFTMCPHOLD                     (DFTMCPHOLD),
    .gov_l2deien_i                  (gov_l2deien_i),
    .ram_idle_count_max_i           (ram_idle_count_max),
    .l2_dataram_rdata0_i            (l2_dataram_rdata0_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_rdata1_i            (l2_dataram_rdata1_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_rdata2_i            (l2_dataram_rdata2_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_rdata3_i            (l2_dataram_rdata3_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_rdata4_i            (l2_dataram_rdata4_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_rdata5_i            (l2_dataram_rdata5_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_rdata6_i            (l2_dataram_rdata6_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_rdata7_i            (l2_dataram_rdata7_i[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .config_l2_size_i               (config_l2_size[`CA53_L2_SIZE_W-1:0]),
    .l2db0_ramctl_valid_i           (l2db0_ramctl_valid),
    .l2db0_ramctl_rw_i              (l2db0_ramctl_rw[1:0]),
    .l2db0_ramctl_banks_i           (l2db0_ramctl_banks[7:0]),
    .l2db0_ramctl_data_i            (l2db0_ramctl_data[255:0]),
    .l2db0_ramctl_way_i             (l2db0_ramctl_way[3:0]),
    .l2db0_ramctl_index_i           (l2db0_ramctl_index[10:0]),
    .l2db0_ramctl_err_i             (l2db0_ramctl_err),
    .l2db1_ramctl_valid_i           (l2db1_ramctl_valid),
    .l2db1_ramctl_rw_i              (l2db1_ramctl_rw[1:0]),
    .l2db1_ramctl_banks_i           (l2db1_ramctl_banks[7:0]),
    .l2db1_ramctl_data_i            (l2db1_ramctl_data[255:0]),
    .l2db1_ramctl_way_i             (l2db1_ramctl_way[3:0]),
    .l2db1_ramctl_index_i           (l2db1_ramctl_index[10:0]),
    .l2db1_ramctl_err_i             (l2db1_ramctl_err),
    .l2db2_ramctl_valid_i           (l2db2_ramctl_valid),
    .l2db2_ramctl_rw_i              (l2db2_ramctl_rw[1:0]),
    .l2db2_ramctl_banks_i           (l2db2_ramctl_banks[7:0]),
    .l2db2_ramctl_data_i            (l2db2_ramctl_data[255:0]),
    .l2db2_ramctl_way_i             (l2db2_ramctl_way[3:0]),
    .l2db2_ramctl_index_i           (l2db2_ramctl_index[10:0]),
    .l2db2_ramctl_err_i             (l2db2_ramctl_err),
    .l2db3_ramctl_valid_i           (l2db3_ramctl_valid),
    .l2db3_ramctl_rw_i              (l2db3_ramctl_rw[1:0]),
    .l2db3_ramctl_banks_i           (l2db3_ramctl_banks[7:0]),
    .l2db3_ramctl_data_i            (l2db3_ramctl_data[255:0]),
    .l2db3_ramctl_way_i             (l2db3_ramctl_way[3:0]),
    .l2db3_ramctl_index_i           (l2db3_ramctl_index[10:0]),
    .l2db3_ramctl_err_i             (l2db3_ramctl_err),
    .l2db4_ramctl_valid_i           (l2db4_ramctl_valid),
    .l2db4_ramctl_rw_i              (l2db4_ramctl_rw[1:0]),
    .l2db4_ramctl_banks_i           (l2db4_ramctl_banks[7:0]),
    .l2db4_ramctl_data_i            (l2db4_ramctl_data[255:0]),
    .l2db4_ramctl_way_i             (l2db4_ramctl_way[3:0]),
    .l2db4_ramctl_index_i           (l2db4_ramctl_index[10:0]),
    .l2db4_ramctl_err_i             (l2db4_ramctl_err),
    .l2db5_ramctl_valid_i           (l2db5_ramctl_valid),
    .l2db5_ramctl_rw_i              (l2db5_ramctl_rw[1:0]),
    .l2db5_ramctl_banks_i           (l2db5_ramctl_banks[7:0]),
    .l2db5_ramctl_data_i            (l2db5_ramctl_data[255:0]),
    .l2db5_ramctl_way_i             (l2db5_ramctl_way[3:0]),
    .l2db5_ramctl_index_i           (l2db5_ramctl_index[10:0]),
    .l2db5_ramctl_err_i             (l2db5_ramctl_err),
    .l2db6_ramctl_valid_i           (l2db6_ramctl_valid),
    .l2db6_ramctl_rw_i              (l2db6_ramctl_rw[1:0]),
    .l2db6_ramctl_banks_i           (l2db6_ramctl_banks[7:0]),
    .l2db6_ramctl_data_i            (l2db6_ramctl_data[255:0]),
    .l2db6_ramctl_way_i             (l2db6_ramctl_way[3:0]),
    .l2db6_ramctl_index_i           (l2db6_ramctl_index[10:0]),
    .l2db6_ramctl_err_i             (l2db6_ramctl_err),
    .l2db7_ramctl_valid_i           (l2db7_ramctl_valid),
    .l2db7_ramctl_rw_i              (l2db7_ramctl_rw[1:0]),
    .l2db7_ramctl_banks_i           (l2db7_ramctl_banks[7:0]),
    .l2db7_ramctl_data_i            (l2db7_ramctl_data[255:0]),
    .l2db7_ramctl_way_i             (l2db7_ramctl_way[3:0]),
    .l2db7_ramctl_index_i           (l2db7_ramctl_index[10:0]),
    .l2db7_ramctl_err_i             (l2db7_ramctl_err),
    .l2db8_ramctl_valid_i           (l2db8_ramctl_valid),
    .l2db8_ramctl_rw_i              (l2db8_ramctl_rw[1:0]),
    .l2db8_ramctl_banks_i           (l2db8_ramctl_banks[7:0]),
    .l2db8_ramctl_data_i            (l2db8_ramctl_data[255:0]),
    .l2db8_ramctl_way_i             (l2db8_ramctl_way[3:0]),
    .l2db8_ramctl_index_i           (l2db8_ramctl_index[10:0]),
    .l2db8_ramctl_err_i             (l2db8_ramctl_err),
    .l2db9_ramctl_valid_i           (l2db9_ramctl_valid),
    .l2db9_ramctl_rw_i              (l2db9_ramctl_rw[1:0]),
    .l2db9_ramctl_banks_i           (l2db9_ramctl_banks[7:0]),
    .l2db9_ramctl_data_i            (l2db9_ramctl_data[255:0]),
    .l2db9_ramctl_way_i             (l2db9_ramctl_way[3:0]),
    .l2db9_ramctl_index_i           (l2db9_ramctl_index[10:0]),
    .l2db9_ramctl_err_i             (l2db9_ramctl_err),
    .l2db10_ramctl_valid_i          (l2db10_ramctl_valid),
    .l2db10_ramctl_rw_i             (l2db10_ramctl_rw[1:0]),
    .l2db10_ramctl_banks_i          (l2db10_ramctl_banks[7:0]),
    .l2db10_ramctl_data_i           (l2db10_ramctl_data[255:0]),
    .l2db10_ramctl_way_i            (l2db10_ramctl_way[3:0]),
    .l2db10_ramctl_index_i          (l2db10_ramctl_index[10:0]),
    .l2db10_ramctl_err_i            (l2db10_ramctl_err),
    .master_ramctl_valid_i          (master_ramctl_valid),
    .master_ramctl_chunks_i         (master_ramctl_chunks[3:0]),
    .master_ramctl_data_i           (master_ramctl_data[255:0]),
    .master_ramctl_way_i            (master_ramctl_way[3:0]),
    .master_ramctl_index_i          (master_ramctl_index[10:0]),
    .tagctl_ramctl_valid_i          (tagctl_ramctl_valid),
    .tagctl_ramctl_cancel_i         (tagctl_ramctl_cancel),
    .tagctl_ramctl_index_i          (tagctl_ramctl_index[10:0]),
    .tagctl_ramctl_way_i            (tagctl_ramctl_way[3:0]),
    .tagctl_ramctl_l2db_i           (tagctl_ramctl_l2db[3:0]),
    .tagctl_ramctl_crit_chunk_i     (tagctl_ramctl_crit_chunk[1:0]),
    .tagctl_ramctl_banks_i          (tagctl_ramctl_banks[7:0]),
    .tagctl_ramctl_flush_i          (tagctl_ramctl_flush),
    .tagctl_l2dataram_req_tc2_i     (tagctl_l2dataram_req_tc2),
    .tagctl_l2dataram_index_i       (tagctl_l2dataram_index[10:0]),
    .tagctl_l2dataram_way_i         (tagctl_l2dataram_way[15:0]),
    .tagctl_l2dataram_banks_i       (tagctl_l2dataram_banks[7:0]),
    .master_ramctl_active_i         (master_ramctl_active),
    .tagctl_ramctl_active_i         (tagctl_ramctl_active),
    .cpuslv0_ramctl_active_i        (cpuslv0_ramctl_active),
    .cpuslv1_ramctl_active_i        (cpuslv1_ramctl_active),
    .cpuslv2_ramctl_active_i        (cpuslv2_ramctl_active),
    .cpuslv3_ramctl_active_i        (cpuslv3_ramctl_active),
    .acpslv_ramctl_active_i         (acpslv_ramctl_active),
    .snpslv_ramctl_active_i         (snpslv_ramctl_active),
    .gov_mbistreq_i                 (gov_mbistreq_i),
    .gov_mbistarray1_i              (gov_mbistarray1_i[`CA53_MBIST1_RAMARRAY_W-1:0]),
    .gov_mbistwriteen1_i            (gov_mbistwriteen1_i),
    .gov_mbistreaden1_i             (gov_mbistreaden1_i),
    .gov_mbistaddr1_i               (gov_mbistaddr1_i[`CA53_MBIST1_ADDR_W-1:0]),
    .gov_mbistbe1_i                 (gov_mbistbe1_i[`CA53_MBIST1_BE_W-1:0]),
    .gov_mbistcfg1_i                (gov_mbistcfg1_i),
    .gov_mbistindata1_i             (gov_mbistindata1_i[`CA53_MBIST1_DATA_W-1:0]),
    // Outputs
    .ramctl_active_o                (ramctl_active),
    .ramctl_awake_o                 (ramctl_awake),
    .l2_dataram_no_acc_next_cycle_o (l2_dataram_no_acc_next_cycle),
    .l2_dataram_clken_o             (l2_dataram_clken_o[`CA53_SCU_L2_DATARAM_EN_W-1:0]),
    .l2_dataram_en_o                (l2_dataram_en_o[`CA53_SCU_L2_DATARAM_EN_W-1:0]),
    .l2_dataram_wr_o                (l2_dataram_wr_o),
    .l2_dataram_addr_o              (l2_dataram_addr_o[`CA53_SCU_L2_DATARAM_ADDR_W-1:0]),
    .l2_dataram_wdata0_o            (l2_dataram_wdata0_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_wdata1_o            (l2_dataram_wdata1_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_wdata2_o            (l2_dataram_wdata2_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_wdata3_o            (l2_dataram_wdata3_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_wdata4_o            (l2_dataram_wdata4_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_wdata5_o            (l2_dataram_wdata5_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_wdata6_o            (l2_dataram_wdata6_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .l2_dataram_wdata7_o            (l2_dataram_wdata7_o[`CA53_SCU_L2_DATARAM_DATA_W-1:0]),
    .ramctl_l2dbs_valid_o           (ramctl_l2dbs_valid),
    .ramctl_l2dbs_id_o              (ramctl_l2dbs_id[3:0]),
    .ramctl_l2dbs_data_o            (ramctl_l2dbs_data[255:0]),
    .ramctl_l2dbs_chunk_o           (ramctl_l2dbs_chunk[1:0]),
    .ramctl_l2dbs_err_o             (ramctl_l2dbs_err),
    .ramctl_l2dbs_last_o            (ramctl_l2dbs_last),
    .ramctl_l2dbs_bypass_o          (ramctl_l2dbs_bypass),
    .ramctl_l2dbs_bypass_id_o       (ramctl_l2dbs_bypass_id[3:0]),
    .ramctl_bypass_data_o           (ramctl_bypass_data[127:0]),
    .ramctl_bypass_err_o            (ramctl_bypass_err),
    .ramctl_bypassed_err_o          (ramctl_bypassed_err),
    .ramctl_l2db0_ready_o           (ramctl_l2db0_ready),
    .ramctl_l2db1_ready_o           (ramctl_l2db1_ready),
    .ramctl_l2db2_ready_o           (ramctl_l2db2_ready),
    .ramctl_l2db3_ready_o           (ramctl_l2db3_ready),
    .ramctl_l2db4_ready_o           (ramctl_l2db4_ready),
    .ramctl_l2db5_ready_o           (ramctl_l2db5_ready),
    .ramctl_l2db6_ready_o           (ramctl_l2db6_ready),
    .ramctl_l2db7_ready_o           (ramctl_l2db7_ready),
    .ramctl_l2db8_ready_o           (ramctl_l2db8_ready),
    .ramctl_l2db9_ready_o           (ramctl_l2db9_ready),
    .ramctl_l2db10_ready_o          (ramctl_l2db10_ready),
    .ramctl_master_ready_o          (ramctl_master_ready),
    .ramctl_master_accepted_o       (ramctl_master_accepted),
    .ramctl_tagctl_ready_o          (ramctl_tagctl_ready),
    .ramctl_mask_tc2_o              (ramctl_mask_tc2),
    .ramctl_ecc_flush_req_o         (ramctl_ecc_flush_req),
    .ramctl_ecc_flush_active_o      (ramctl_ecc_flush_active),
    .ramctl_ecc_flush_index_o       (ramctl_ecc_flush_index[10:0]),
    .ramctl_ecc_flush_way_o         (ramctl_ecc_flush_way[3:0]),
    .ramctl_err_valid_o             (ramctl_err_valid),
    .ramctl_err_fatal_o             (ramctl_err_fatal),
    .ramctl_err_index_o             (ramctl_err_index[14:0]),
    .ramctl_err_bank_o              (ramctl_err_bank[2:0]),
    .scu_mbistack1_o                (scu_mbistack1_o),
    .scu_mbistoutdata1_o            (scu_mbistoutdata1_o[`CA53_MBIST1_DATA_W-1:0])
  );  // u_scu_ramctl

  ca53scu_master #(`CA53_SCU_INT_PARAM_INST) u_scu_master (
    /*ARMAUTO*/
    // Inputs
    .CLKIN                             (CLKIN),
    .clk                               (clk),
    .clk_ext_master                    (clk_ext_master),
    .reset_n                           (reset_n),
    .DFTSE                             (DFTSE),
    .tagctl_master_active_i            (tagctl_master_active),
    .snpslv_master_active_i            (snpslv_master_active),
    .standbywfil2_req_i                (standbywfil2_req),
    .config_broadcastinner_i           (config_broadcastinner),
    .config_broadcastouter_i           (config_broadcastouter),
    .gov_clear_axierr_i                (gov_clear_axierr_i),
    .gov_clear_eccerr_i                (gov_clear_eccerr_i),
    .clean_aclken_i                    (clean_aclken),
    .scu_ext_ar_ready_i                (scu_ext_ar_ready_i),
    .scu_ext_dr_valid_i                (scu_ext_dr_valid_i),
    .scu_ext_dr_id_i                   (scu_ext_dr_id_i[5:0]),
    .scu_ext_dr_last_i                 (scu_ext_dr_last_i),
    .scu_ext_dr_data_i                 (scu_ext_dr_data_i[127:0]),
    .scu_ext_dr_resp_i                 (scu_ext_dr_resp_i[3:0]),
    .scu_ext_aw_ready_i                (scu_ext_aw_ready_i),
    .scu_ext_dw_ready_i                (scu_ext_dw_ready_i),
    .scu_ext_db_valid_i                (scu_ext_db_valid_i),
    .scu_ext_db_id_i                   (scu_ext_db_id_i[4:0]),
    .scu_ext_db_resp_i                 (scu_ext_db_resp_i[1:0]),
    .scu_ext_cd_ready_i                (scu_ext_cd_ready_i),
    .config_nodeid_i                   (config_nodeid[6:0]),
    .ext_rxlinkactivereq_i             (ext_rxlinkactivereq_i),
    .ext_txlinkactiveack_i             (ext_txlinkactiveack_i),
    .ext_txreqlcrdv_i                  (ext_txreqlcrdv_i),
    .ext_txdatlcrdv_i                  (ext_txdatlcrdv_i),
    .ext_rxrspflitpend_i               (ext_rxrspflitpend_i),
    .ext_rxrspflitv_i                  (ext_rxrspflitv_i),
    .ext_rxrspflit_i                   (ext_rxrspflit_i[44:0]),
    .ext_rxdatflitpend_i               (ext_rxdatflitpend_i),
    .ext_rxdatflitv_i                  (ext_rxdatflitv_i),
    .ext_rxdatflit_i                   (ext_rxdatflit_i[193:0]),
    .afb0_master_req_i                 (afb0_master_req),
    .afb0_master_flush_i               (afb0_master_flush),
    .afb0_master_id_i                  (afb0_master_id[6:0]),
    .afb0_master_addr_i                (afb0_master_addr[40:0]),
    .afb0_master_opcode_i              (afb0_master_opcode[4:0]),
    .afb0_master_len_i                 (afb0_master_len[1:0]),
    .afb0_master_size_i                (afb0_master_size[2:0]),
    .afb0_master_lock_i                (afb0_master_lock),
    .afb0_master_attrs_i               (afb0_master_attrs[7:0]),
    .afb0_master_prot_i                (afb0_master_prot[1:0]),
    .afb0_master_tgtid_i               (afb0_master_tgtid[6:0]),
    .afb0_master_l2db_i                (afb0_master_l2db[3:0]),
    .afb0_master_static_pcredit_i      (afb0_master_static_pcredit),
    .afb0_master_pcrdtype_i            (afb0_master_pcrdtype[1:0]),
    .afb1_master_req_i                 (afb1_master_req),
    .afb1_master_flush_i               (afb1_master_flush),
    .afb1_master_id_i                  (afb1_master_id[6:0]),
    .afb1_master_addr_i                (afb1_master_addr[40:0]),
    .afb1_master_opcode_i              (afb1_master_opcode[4:0]),
    .afb1_master_len_i                 (afb1_master_len[1:0]),
    .afb1_master_size_i                (afb1_master_size[2:0]),
    .afb1_master_lock_i                (afb1_master_lock),
    .afb1_master_attrs_i               (afb1_master_attrs[7:0]),
    .afb1_master_prot_i                (afb1_master_prot[1:0]),
    .afb1_master_tgtid_i               (afb1_master_tgtid[6:0]),
    .afb1_master_l2db_i                (afb1_master_l2db[3:0]),
    .afb1_master_static_pcredit_i      (afb1_master_static_pcredit),
    .afb1_master_pcrdtype_i            (afb1_master_pcrdtype[1:0]),
    .afb2_master_req_i                 (afb2_master_req),
    .afb2_master_flush_i               (afb2_master_flush),
    .afb2_master_id_i                  (afb2_master_id[6:0]),
    .afb2_master_addr_i                (afb2_master_addr[40:0]),
    .afb2_master_opcode_i              (afb2_master_opcode[4:0]),
    .afb2_master_len_i                 (afb2_master_len[1:0]),
    .afb2_master_size_i                (afb2_master_size[2:0]),
    .afb2_master_lock_i                (afb2_master_lock),
    .afb2_master_attrs_i               (afb2_master_attrs[7:0]),
    .afb2_master_prot_i                (afb2_master_prot[1:0]),
    .afb2_master_tgtid_i               (afb2_master_tgtid[6:0]),
    .afb2_master_l2db_i                (afb2_master_l2db[3:0]),
    .afb2_master_static_pcredit_i      (afb2_master_static_pcredit),
    .afb2_master_pcrdtype_i            (afb2_master_pcrdtype[1:0]),
    .afb3_master_req_i                 (afb3_master_req),
    .afb3_master_flush_i               (afb3_master_flush),
    .afb3_master_id_i                  (afb3_master_id[6:0]),
    .afb3_master_addr_i                (afb3_master_addr[40:0]),
    .afb3_master_opcode_i              (afb3_master_opcode[4:0]),
    .afb3_master_len_i                 (afb3_master_len[1:0]),
    .afb3_master_size_i                (afb3_master_size[2:0]),
    .afb3_master_lock_i                (afb3_master_lock),
    .afb3_master_attrs_i               (afb3_master_attrs[7:0]),
    .afb3_master_prot_i                (afb3_master_prot[1:0]),
    .afb3_master_tgtid_i               (afb3_master_tgtid[6:0]),
    .afb3_master_l2db_i                (afb3_master_l2db[3:0]),
    .afb3_master_static_pcredit_i      (afb3_master_static_pcredit),
    .afb3_master_pcrdtype_i            (afb3_master_pcrdtype[1:0]),
    .afb4_master_req_i                 (afb4_master_req),
    .afb4_master_flush_i               (afb4_master_flush),
    .afb4_master_id_i                  (afb4_master_id[6:0]),
    .afb4_master_addr_i                (afb4_master_addr[40:0]),
    .afb4_master_opcode_i              (afb4_master_opcode[4:0]),
    .afb4_master_len_i                 (afb4_master_len[1:0]),
    .afb4_master_size_i                (afb4_master_size[2:0]),
    .afb4_master_lock_i                (afb4_master_lock),
    .afb4_master_attrs_i               (afb4_master_attrs[7:0]),
    .afb4_master_prot_i                (afb4_master_prot[1:0]),
    .afb4_master_tgtid_i               (afb4_master_tgtid[6:0]),
    .afb4_master_l2db_i                (afb4_master_l2db[3:0]),
    .afb4_master_static_pcredit_i      (afb4_master_static_pcredit),
    .afb4_master_pcrdtype_i            (afb4_master_pcrdtype[1:0]),
    .afb5_master_req_i                 (afb5_master_req),
    .afb5_master_flush_i               (afb5_master_flush),
    .afb5_master_id_i                  (afb5_master_id[6:0]),
    .afb5_master_addr_i                (afb5_master_addr[40:0]),
    .afb5_master_opcode_i              (afb5_master_opcode[4:0]),
    .afb5_master_len_i                 (afb5_master_len[1:0]),
    .afb5_master_size_i                (afb5_master_size[2:0]),
    .afb5_master_lock_i                (afb5_master_lock),
    .afb5_master_attrs_i               (afb5_master_attrs[7:0]),
    .afb5_master_prot_i                (afb5_master_prot[1:0]),
    .afb5_master_tgtid_i               (afb5_master_tgtid[6:0]),
    .afb5_master_l2db_i                (afb5_master_l2db[3:0]),
    .afb5_master_static_pcredit_i      (afb5_master_static_pcredit),
    .afb5_master_pcrdtype_i            (afb5_master_pcrdtype[1:0]),
    .tagctl_err_fatal_i                (tagctl_err_fatal),
    .l2db0_master_valid_i              (l2db0_master_valid),
    .l2db0_master_snoop_i              (l2db0_master_snoop),
    .l2db0_master_id_i                 (l2db0_master_id[5:0]),
    .l2db0_master_dbid_i               (l2db0_master_dbid[7:0]),
    .l2db0_master_tgtid_i              (l2db0_master_tgtid[6:0]),
    .l2db0_master_qos_i                (l2db0_master_qos[3:0]),
    .l2db0_master_data_i               (l2db0_master_data[127:0]),
    .l2db0_master_strb_i               (l2db0_master_strb[15:0]),
    .l2db0_master_chunk_i              (l2db0_master_chunk[1:0]),
    .l2db0_master_last_i               (l2db0_master_last),
    .l2db0_master_opcode_i             (l2db0_master_opcode[2:0]),
    .l2db0_master_snpresp_i            (l2db0_master_snpresp[2:0]),
    .l2db0_master_len_i                (l2db0_master_len[1:0]),
    .l2db0_master_size_i               (l2db0_master_size[2:0]),
    .l2db0_master_addr_i               (l2db0_master_addr[5:0]),
    .l2db0_master_attrs_i              (l2db0_master_attrs[7:0]),
    .l2db0_master_prot_i               (l2db0_master_prot),
    .l2db0_master_strex_i              (l2db0_master_strex),
    .l2db0_master_unique_i             (l2db0_master_unique),
    .l2db0_master_err_i                (l2db0_master_err),
    .l2db1_master_valid_i              (l2db1_master_valid),
    .l2db1_master_snoop_i              (l2db1_master_snoop),
    .l2db1_master_id_i                 (l2db1_master_id[5:0]),
    .l2db1_master_dbid_i               (l2db1_master_dbid[7:0]),
    .l2db1_master_tgtid_i              (l2db1_master_tgtid[6:0]),
    .l2db1_master_qos_i                (l2db1_master_qos[3:0]),
    .l2db1_master_data_i               (l2db1_master_data[127:0]),
    .l2db1_master_strb_i               (l2db1_master_strb[15:0]),
    .l2db1_master_chunk_i              (l2db1_master_chunk[1:0]),
    .l2db1_master_last_i               (l2db1_master_last),
    .l2db1_master_opcode_i             (l2db1_master_opcode[2:0]),
    .l2db1_master_snpresp_i            (l2db1_master_snpresp[2:0]),
    .l2db1_master_len_i                (l2db1_master_len[1:0]),
    .l2db1_master_size_i               (l2db1_master_size[2:0]),
    .l2db1_master_addr_i               (l2db1_master_addr[5:0]),
    .l2db1_master_attrs_i              (l2db1_master_attrs[7:0]),
    .l2db1_master_prot_i               (l2db1_master_prot),
    .l2db1_master_strex_i              (l2db1_master_strex),
    .l2db1_master_unique_i             (l2db1_master_unique),
    .l2db1_master_err_i                (l2db1_master_err),
    .l2db2_master_valid_i              (l2db2_master_valid),
    .l2db2_master_snoop_i              (l2db2_master_snoop),
    .l2db2_master_id_i                 (l2db2_master_id[5:0]),
    .l2db2_master_dbid_i               (l2db2_master_dbid[7:0]),
    .l2db2_master_tgtid_i              (l2db2_master_tgtid[6:0]),
    .l2db2_master_qos_i                (l2db2_master_qos[3:0]),
    .l2db2_master_data_i               (l2db2_master_data[127:0]),
    .l2db2_master_strb_i               (l2db2_master_strb[15:0]),
    .l2db2_master_chunk_i              (l2db2_master_chunk[1:0]),
    .l2db2_master_last_i               (l2db2_master_last),
    .l2db2_master_opcode_i             (l2db2_master_opcode[2:0]),
    .l2db2_master_snpresp_i            (l2db2_master_snpresp[2:0]),
    .l2db2_master_len_i                (l2db2_master_len[1:0]),
    .l2db2_master_size_i               (l2db2_master_size[2:0]),
    .l2db2_master_addr_i               (l2db2_master_addr[5:0]),
    .l2db2_master_attrs_i              (l2db2_master_attrs[7:0]),
    .l2db2_master_prot_i               (l2db2_master_prot),
    .l2db2_master_strex_i              (l2db2_master_strex),
    .l2db2_master_unique_i             (l2db2_master_unique),
    .l2db2_master_err_i                (l2db2_master_err),
    .l2db3_master_valid_i              (l2db3_master_valid),
    .l2db3_master_snoop_i              (l2db3_master_snoop),
    .l2db3_master_id_i                 (l2db3_master_id[5:0]),
    .l2db3_master_dbid_i               (l2db3_master_dbid[7:0]),
    .l2db3_master_tgtid_i              (l2db3_master_tgtid[6:0]),
    .l2db3_master_qos_i                (l2db3_master_qos[3:0]),
    .l2db3_master_data_i               (l2db3_master_data[127:0]),
    .l2db3_master_strb_i               (l2db3_master_strb[15:0]),
    .l2db3_master_chunk_i              (l2db3_master_chunk[1:0]),
    .l2db3_master_last_i               (l2db3_master_last),
    .l2db3_master_opcode_i             (l2db3_master_opcode[2:0]),
    .l2db3_master_snpresp_i            (l2db3_master_snpresp[2:0]),
    .l2db3_master_len_i                (l2db3_master_len[1:0]),
    .l2db3_master_size_i               (l2db3_master_size[2:0]),
    .l2db3_master_addr_i               (l2db3_master_addr[5:0]),
    .l2db3_master_attrs_i              (l2db3_master_attrs[7:0]),
    .l2db3_master_prot_i               (l2db3_master_prot),
    .l2db3_master_strex_i              (l2db3_master_strex),
    .l2db3_master_unique_i             (l2db3_master_unique),
    .l2db3_master_err_i                (l2db3_master_err),
    .l2db4_master_valid_i              (l2db4_master_valid),
    .l2db4_master_snoop_i              (l2db4_master_snoop),
    .l2db4_master_id_i                 (l2db4_master_id[5:0]),
    .l2db4_master_dbid_i               (l2db4_master_dbid[7:0]),
    .l2db4_master_tgtid_i              (l2db4_master_tgtid[6:0]),
    .l2db4_master_qos_i                (l2db4_master_qos[3:0]),
    .l2db4_master_data_i               (l2db4_master_data[127:0]),
    .l2db4_master_strb_i               (l2db4_master_strb[15:0]),
    .l2db4_master_chunk_i              (l2db4_master_chunk[1:0]),
    .l2db4_master_last_i               (l2db4_master_last),
    .l2db4_master_opcode_i             (l2db4_master_opcode[2:0]),
    .l2db4_master_snpresp_i            (l2db4_master_snpresp[2:0]),
    .l2db4_master_len_i                (l2db4_master_len[1:0]),
    .l2db4_master_size_i               (l2db4_master_size[2:0]),
    .l2db4_master_addr_i               (l2db4_master_addr[5:0]),
    .l2db4_master_attrs_i              (l2db4_master_attrs[7:0]),
    .l2db4_master_prot_i               (l2db4_master_prot),
    .l2db4_master_strex_i              (l2db4_master_strex),
    .l2db4_master_unique_i             (l2db4_master_unique),
    .l2db4_master_err_i                (l2db4_master_err),
    .l2db5_master_valid_i              (l2db5_master_valid),
    .l2db5_master_snoop_i              (l2db5_master_snoop),
    .l2db5_master_id_i                 (l2db5_master_id[5:0]),
    .l2db5_master_dbid_i               (l2db5_master_dbid[7:0]),
    .l2db5_master_tgtid_i              (l2db5_master_tgtid[6:0]),
    .l2db5_master_qos_i                (l2db5_master_qos[3:0]),
    .l2db5_master_data_i               (l2db5_master_data[127:0]),
    .l2db5_master_strb_i               (l2db5_master_strb[15:0]),
    .l2db5_master_chunk_i              (l2db5_master_chunk[1:0]),
    .l2db5_master_last_i               (l2db5_master_last),
    .l2db5_master_opcode_i             (l2db5_master_opcode[2:0]),
    .l2db5_master_snpresp_i            (l2db5_master_snpresp[2:0]),
    .l2db5_master_len_i                (l2db5_master_len[1:0]),
    .l2db5_master_size_i               (l2db5_master_size[2:0]),
    .l2db5_master_addr_i               (l2db5_master_addr[5:0]),
    .l2db5_master_attrs_i              (l2db5_master_attrs[7:0]),
    .l2db5_master_prot_i               (l2db5_master_prot),
    .l2db5_master_strex_i              (l2db5_master_strex),
    .l2db5_master_unique_i             (l2db5_master_unique),
    .l2db5_master_err_i                (l2db5_master_err),
    .l2db6_master_valid_i              (l2db6_master_valid),
    .l2db6_master_snoop_i              (l2db6_master_snoop),
    .l2db6_master_id_i                 (l2db6_master_id[5:0]),
    .l2db6_master_dbid_i               (l2db6_master_dbid[7:0]),
    .l2db6_master_tgtid_i              (l2db6_master_tgtid[6:0]),
    .l2db6_master_qos_i                (l2db6_master_qos[3:0]),
    .l2db6_master_data_i               (l2db6_master_data[127:0]),
    .l2db6_master_strb_i               (l2db6_master_strb[15:0]),
    .l2db6_master_chunk_i              (l2db6_master_chunk[1:0]),
    .l2db6_master_last_i               (l2db6_master_last),
    .l2db6_master_opcode_i             (l2db6_master_opcode[2:0]),
    .l2db6_master_snpresp_i            (l2db6_master_snpresp[2:0]),
    .l2db6_master_len_i                (l2db6_master_len[1:0]),
    .l2db6_master_size_i               (l2db6_master_size[2:0]),
    .l2db6_master_addr_i               (l2db6_master_addr[5:0]),
    .l2db6_master_attrs_i              (l2db6_master_attrs[7:0]),
    .l2db6_master_prot_i               (l2db6_master_prot),
    .l2db6_master_strex_i              (l2db6_master_strex),
    .l2db6_master_unique_i             (l2db6_master_unique),
    .l2db6_master_err_i                (l2db6_master_err),
    .l2db7_master_valid_i              (l2db7_master_valid),
    .l2db7_master_snoop_i              (l2db7_master_snoop),
    .l2db7_master_id_i                 (l2db7_master_id[5:0]),
    .l2db7_master_dbid_i               (l2db7_master_dbid[7:0]),
    .l2db7_master_tgtid_i              (l2db7_master_tgtid[6:0]),
    .l2db7_master_qos_i                (l2db7_master_qos[3:0]),
    .l2db7_master_data_i               (l2db7_master_data[127:0]),
    .l2db7_master_strb_i               (l2db7_master_strb[15:0]),
    .l2db7_master_chunk_i              (l2db7_master_chunk[1:0]),
    .l2db7_master_last_i               (l2db7_master_last),
    .l2db7_master_opcode_i             (l2db7_master_opcode[2:0]),
    .l2db7_master_snpresp_i            (l2db7_master_snpresp[2:0]),
    .l2db7_master_len_i                (l2db7_master_len[1:0]),
    .l2db7_master_size_i               (l2db7_master_size[2:0]),
    .l2db7_master_addr_i               (l2db7_master_addr[5:0]),
    .l2db7_master_attrs_i              (l2db7_master_attrs[7:0]),
    .l2db7_master_prot_i               (l2db7_master_prot),
    .l2db7_master_strex_i              (l2db7_master_strex),
    .l2db7_master_unique_i             (l2db7_master_unique),
    .l2db7_master_err_i                (l2db7_master_err),
    .l2db8_master_valid_i              (l2db8_master_valid),
    .l2db8_master_snoop_i              (l2db8_master_snoop),
    .l2db8_master_id_i                 (l2db8_master_id[5:0]),
    .l2db8_master_dbid_i               (l2db8_master_dbid[7:0]),
    .l2db8_master_tgtid_i              (l2db8_master_tgtid[6:0]),
    .l2db8_master_qos_i                (l2db8_master_qos[3:0]),
    .l2db8_master_data_i               (l2db8_master_data[127:0]),
    .l2db8_master_strb_i               (l2db8_master_strb[15:0]),
    .l2db8_master_chunk_i              (l2db8_master_chunk[1:0]),
    .l2db8_master_last_i               (l2db8_master_last),
    .l2db8_master_opcode_i             (l2db8_master_opcode[2:0]),
    .l2db8_master_snpresp_i            (l2db8_master_snpresp[2:0]),
    .l2db8_master_len_i                (l2db8_master_len[1:0]),
    .l2db8_master_size_i               (l2db8_master_size[2:0]),
    .l2db8_master_addr_i               (l2db8_master_addr[5:0]),
    .l2db8_master_attrs_i              (l2db8_master_attrs[7:0]),
    .l2db8_master_prot_i               (l2db8_master_prot),
    .l2db8_master_strex_i              (l2db8_master_strex),
    .l2db8_master_unique_i             (l2db8_master_unique),
    .l2db8_master_err_i                (l2db8_master_err),
    .l2db9_master_valid_i              (l2db9_master_valid),
    .l2db9_master_snoop_i              (l2db9_master_snoop),
    .l2db9_master_id_i                 (l2db9_master_id[5:0]),
    .l2db9_master_dbid_i               (l2db9_master_dbid[7:0]),
    .l2db9_master_tgtid_i              (l2db9_master_tgtid[6:0]),
    .l2db9_master_qos_i                (l2db9_master_qos[3:0]),
    .l2db9_master_data_i               (l2db9_master_data[127:0]),
    .l2db9_master_strb_i               (l2db9_master_strb[15:0]),
    .l2db9_master_chunk_i              (l2db9_master_chunk[1:0]),
    .l2db9_master_last_i               (l2db9_master_last),
    .l2db9_master_opcode_i             (l2db9_master_opcode[2:0]),
    .l2db9_master_snpresp_i            (l2db9_master_snpresp[2:0]),
    .l2db9_master_len_i                (l2db9_master_len[1:0]),
    .l2db9_master_size_i               (l2db9_master_size[2:0]),
    .l2db9_master_addr_i               (l2db9_master_addr[5:0]),
    .l2db9_master_attrs_i              (l2db9_master_attrs[7:0]),
    .l2db9_master_prot_i               (l2db9_master_prot),
    .l2db9_master_strex_i              (l2db9_master_strex),
    .l2db9_master_unique_i             (l2db9_master_unique),
    .l2db9_master_err_i                (l2db9_master_err),
    .l2db10_master_valid_i             (l2db10_master_valid),
    .l2db10_master_snoop_i             (l2db10_master_snoop),
    .l2db10_master_id_i                (l2db10_master_id[5:0]),
    .l2db10_master_dbid_i              (l2db10_master_dbid[7:0]),
    .l2db10_master_tgtid_i             (l2db10_master_tgtid[6:0]),
    .l2db10_master_qos_i               (l2db10_master_qos[3:0]),
    .l2db10_master_data_i              (l2db10_master_data[127:0]),
    .l2db10_master_strb_i              (l2db10_master_strb[15:0]),
    .l2db10_master_chunk_i             (l2db10_master_chunk[1:0]),
    .l2db10_master_last_i              (l2db10_master_last),
    .l2db10_master_opcode_i            (l2db10_master_opcode[2:0]),
    .l2db10_master_snpresp_i           (l2db10_master_snpresp[2:0]),
    .l2db10_master_len_i               (l2db10_master_len[1:0]),
    .l2db10_master_size_i              (l2db10_master_size[2:0]),
    .l2db10_master_addr_i              (l2db10_master_addr[5:0]),
    .l2db10_master_attrs_i             (l2db10_master_attrs[7:0]),
    .l2db10_master_prot_i              (l2db10_master_prot),
    .l2db10_master_strex_i             (l2db10_master_strex),
    .l2db10_master_unique_i            (l2db10_master_unique),
    .l2db10_master_err_i               (l2db10_master_err),
    .l2db10_master_invalidated_i       (l2db10_master_invalidated),
    .l2db9_master_invalidated_i        (l2db9_master_invalidated),
    .l2db8_master_invalidated_i        (l2db8_master_invalidated),
    .l2db7_master_invalidated_i        (l2db7_master_invalidated),
    .l2db6_master_invalidated_i        (l2db6_master_invalidated),
    .l2db5_master_invalidated_i        (l2db5_master_invalidated),
    .l2db4_master_invalidated_i        (l2db4_master_invalidated),
    .l2db3_master_invalidated_i        (l2db3_master_invalidated),
    .l2db2_master_invalidated_i        (l2db2_master_invalidated),
    .l2db1_master_invalidated_i        (l2db1_master_invalidated),
    .l2db0_master_invalidated_i        (l2db0_master_invalidated),
    .l2db10_master_dirty_i             (l2db10_master_dirty),
    .l2db9_master_dirty_i              (l2db9_master_dirty),
    .l2db8_master_dirty_i              (l2db8_master_dirty),
    .l2db7_master_dirty_i              (l2db7_master_dirty),
    .l2db6_master_dirty_i              (l2db6_master_dirty),
    .l2db5_master_dirty_i              (l2db5_master_dirty),
    .l2db4_master_dirty_i              (l2db4_master_dirty),
    .l2db3_master_dirty_i              (l2db3_master_dirty),
    .l2db2_master_dirty_i              (l2db2_master_dirty),
    .l2db1_master_dirty_i              (l2db1_master_dirty),
    .l2db0_master_dirty_i              (l2db0_master_dirty),
    .cpuslv0_master_dr_ready_i         (cpuslv0_master_dr_ready),
    .cpuslv1_master_dr_ready_i         (cpuslv1_master_dr_ready),
    .cpuslv2_master_dr_ready_i         (cpuslv2_master_dr_ready),
    .cpuslv3_master_dr_ready_i         (cpuslv3_master_dr_ready),
    .acpslv_master_dr_ready_i          (acpslv_master_dr_ready),
    .cpuslv0_early_dr_ready_i          (cpuslv0_early_dr_ready[7:0]),
    .cpuslv0_early_dr_l2_i             (cpuslv0_early_dr_l2),
    .cpuslv0_early_dr_index_i          (cpuslv0_early_dr_index[10:0]),
    .cpuslv0_early_dr_way_i            (cpuslv0_early_dr_way[3:0]),
    .cpuslv1_early_dr_ready_i          (cpuslv1_early_dr_ready[7:0]),
    .cpuslv1_early_dr_l2_i             (cpuslv1_early_dr_l2),
    .cpuslv1_early_dr_index_i          (cpuslv1_early_dr_index[10:0]),
    .cpuslv1_early_dr_way_i            (cpuslv1_early_dr_way[3:0]),
    .cpuslv2_early_dr_ready_i          (cpuslv2_early_dr_ready[7:0]),
    .cpuslv2_early_dr_l2_i             (cpuslv2_early_dr_l2),
    .cpuslv2_early_dr_index_i          (cpuslv2_early_dr_index[10:0]),
    .cpuslv2_early_dr_way_i            (cpuslv2_early_dr_way[3:0]),
    .cpuslv3_early_dr_ready_i          (cpuslv3_early_dr_ready[7:0]),
    .cpuslv3_early_dr_l2_i             (cpuslv3_early_dr_l2),
    .cpuslv3_early_dr_index_i          (cpuslv3_early_dr_index[10:0]),
    .cpuslv3_early_dr_way_i            (cpuslv3_early_dr_way[3:0]),
    .acpslv_early_dr_l2_i              (acpslv_early_dr_l2),
    .acpslv_early_dr_index_i           (acpslv_early_dr_index[10:0]),
    .acpslv_early_dr_way_i             (acpslv_early_dr_way[3:0]),
    .acpslv_early_dr_ready_i           (acpslv_early_dr_ready[15:0]),
    .cpuslv0_sample_waddrs_i           (cpuslv0_sample_waddrs),
    .cpuslv1_sample_waddrs_i           (cpuslv1_sample_waddrs),
    .cpuslv2_sample_waddrs_i           (cpuslv2_sample_waddrs),
    .cpuslv3_sample_waddrs_i           (cpuslv3_sample_waddrs),
    .cpuslv0_sample_waddrs_dsb_i       (cpuslv0_sample_waddrs_dsb),
    .cpuslv1_sample_waddrs_dsb_i       (cpuslv1_sample_waddrs_dsb),
    .cpuslv2_sample_waddrs_dsb_i       (cpuslv2_sample_waddrs_dsb),
    .cpuslv3_sample_waddrs_dsb_i       (cpuslv3_sample_waddrs_dsb),
    .snpslv_sample_waddrs_i            (snpslv_sample_waddrs),
    .ramctl_master_ready_i             (ramctl_master_ready),
    .ramctl_master_accepted_i          (ramctl_master_accepted),
    .cpuslv0_delay_allocation_i        (cpuslv0_delay_allocation[7:0]),
    .cpuslv1_delay_allocation_i        (cpuslv1_delay_allocation[7:0]),
    .cpuslv2_delay_allocation_i        (cpuslv2_delay_allocation[7:0]),
    .cpuslv3_delay_allocation_i        (cpuslv3_delay_allocation[7:0]),
    .acpslv_delay_allocation_i         (acpslv_delay_allocation[3:0]),
    .victimctl_ack_i                   (victimctl_ack),
    .victimctl_ack_id_i                (victimctl_ack_id[5:0]),
    .victimctl_victim_way_i            (victimctl_victim_way[3:0]),
    .snpslv_txrsp_req_i                (snpslv_txrsp_req),
    .snpslv_rxsnp_active_i             (snpslv_rxsnp_active),
    .snpslv_active_i                   (snpslv_active),
    .cpuslv0_compack_valid_i           (cpuslv0_compack_valid),
    .cpuslv1_compack_valid_i           (cpuslv1_compack_valid),
    .cpuslv2_compack_valid_i           (cpuslv2_compack_valid),
    .cpuslv3_compack_valid_i           (cpuslv3_compack_valid),
    .acpslv_compack_valid_i            (acpslv_compack_valid),
    .cpuslv0_master_sactive_i          (cpuslv0_master_sactive),
    .cpuslv1_master_sactive_i          (cpuslv1_master_sactive),
    .cpuslv2_master_sactive_i          (cpuslv2_master_sactive),
    .cpuslv3_master_sactive_i          (cpuslv3_master_sactive),
    .acpslv_master_sactive_i           (acpslv_master_sactive),
    .tagctl_addr_tc1_i                 (tagctl_addr_tc1[41:6]),
    .tagctl_addr_valid_tc1_i           (tagctl_addr_valid_tc1),
    .tagctl_addr_tc3_i                 (tagctl_addr_tc3[40:6]),
    .tagctl_addr_valid_tc3_i           (tagctl_addr_valid_tc3),
    .tagctl_reqbufid_tc1_i             (tagctl_reqbufid_tc1[5:0]),
    .acpslv_ext_err_i                  (acpslv_ext_err),
    .gov_mbistreq_i                    (gov_mbistreq_i),
    .gov_mbistindata0_i                (gov_mbistindata0_i[`CA53_MBIST0_DATA_W-1:0]),
    // Outputs
    .master_active_o                   (master_active),
    .master_linkactive_o               (master_linkactive),
    .master_writes_active_o            (master_writes_active),
    .scu_axierr_o                      (scu_axierr_o),
    .scu_eccerr_o                      (scu_eccerr_o),
    .nexterrirq_o                      (nexterrirq_o),
    .ninterrirq_o                      (ninterrirq_o),
    .scu_cpu0_evnt_bus_cycle_o         (scu_cpu0_evnt_bus_cycle_o),
    .scu_cpu1_evnt_bus_cycle_o         (scu_cpu1_evnt_bus_cycle_o),
    .scu_cpu2_evnt_bus_cycle_o         (scu_cpu2_evnt_bus_cycle_o),
    .scu_cpu3_evnt_bus_cycle_o         (scu_cpu3_evnt_bus_cycle_o),
    .scu_cpu0_evnt_bus_acc_rd_o        (scu_cpu0_evnt_bus_acc_rd_o),
    .scu_cpu1_evnt_bus_acc_rd_o        (scu_cpu1_evnt_bus_acc_rd_o),
    .scu_cpu2_evnt_bus_acc_rd_o        (scu_cpu2_evnt_bus_acc_rd_o),
    .scu_cpu3_evnt_bus_acc_rd_o        (scu_cpu3_evnt_bus_acc_rd_o),
    .scu_cpu0_evnt_bus_acc_wr_o        (scu_cpu0_evnt_bus_acc_wr_o),
    .scu_cpu1_evnt_bus_acc_wr_o        (scu_cpu1_evnt_bus_acc_wr_o),
    .scu_cpu2_evnt_bus_acc_wr_o        (scu_cpu2_evnt_bus_acc_wr_o),
    .scu_cpu3_evnt_bus_acc_wr_o        (scu_cpu3_evnt_bus_acc_wr_o),
    .scu_cpu0_evnt_l2_refill_o         (scu_cpu0_evnt_l2_refill_o),
    .scu_cpu1_evnt_l2_refill_o         (scu_cpu1_evnt_l2_refill_o),
    .scu_cpu2_evnt_l2_refill_o         (scu_cpu2_evnt_l2_refill_o),
    .scu_cpu3_evnt_l2_refill_o         (scu_cpu3_evnt_l2_refill_o),
    .scu_cpu0_evnt_l2_wb_o             (scu_cpu0_evnt_l2_wb_o),
    .scu_cpu1_evnt_l2_wb_o             (scu_cpu1_evnt_l2_wb_o),
    .scu_cpu2_evnt_l2_wb_o             (scu_cpu2_evnt_l2_wb_o),
    .scu_cpu3_evnt_l2_wb_o             (scu_cpu3_evnt_l2_wb_o),
    .scu_ext_ar_valid_o                (scu_ext_ar_valid_o),
    .scu_ext_ar_addr_o                 (scu_ext_ar_addr_o[43:0]),
    .scu_ext_ar_len_o                  (scu_ext_ar_len_o[7:0]),
    .scu_ext_ar_size_o                 (scu_ext_ar_size_o[2:0]),
    .scu_ext_ar_burst_o                (scu_ext_ar_burst_o[1:0]),
    .scu_ext_ar_lock_o                 (scu_ext_ar_lock_o),
    .scu_ext_ar_cache_o                (scu_ext_ar_cache_o[3:0]),
    .scu_ext_ar_prot_o                 (scu_ext_ar_prot_o[2:0]),
    .scu_ext_ar_domain_o               (scu_ext_ar_domain_o[1:0]),
    .scu_ext_ar_snoop_o                (scu_ext_ar_snoop_o[3:0]),
    .scu_ext_ar_id_o                   (scu_ext_ar_id_o[5:0]),
    .scu_ext_ar_bar_o                  (scu_ext_ar_bar_o[1:0]),
    .scu_ext_rdmemattr_o               (scu_ext_rdmemattr_o[7:0]),
    .scu_ext_dr_ready_o                (scu_ext_dr_ready_o),
    .scu_ext_aw_valid_o                (scu_ext_aw_valid_o),
    .scu_ext_aw_addr_o                 (scu_ext_aw_addr_o[43:0]),
    .scu_ext_aw_len_o                  (scu_ext_aw_len_o[7:0]),
    .scu_ext_aw_size_o                 (scu_ext_aw_size_o[2:0]),
    .scu_ext_aw_burst_o                (scu_ext_aw_burst_o[1:0]),
    .scu_ext_aw_lock_o                 (scu_ext_aw_lock_o),
    .scu_ext_aw_cache_o                (scu_ext_aw_cache_o[3:0]),
    .scu_ext_aw_prot_o                 (scu_ext_aw_prot_o[2:0]),
    .scu_ext_aw_id_o                   (scu_ext_aw_id_o[4:0]),
    .scu_ext_aw_snoop_o                (scu_ext_aw_snoop_o[2:0]),
    .scu_ext_aw_domain_o               (scu_ext_aw_domain_o[1:0]),
    .scu_ext_aw_bar_o                  (scu_ext_aw_bar_o[1:0]),
    .scu_ext_aw_unique_o               (scu_ext_aw_unique_o),
    .scu_ext_wrmemattr_o               (scu_ext_wrmemattr_o[7:0]),
    .scu_ext_dw_valid_o                (scu_ext_dw_valid_o),
    .scu_ext_dw_data_o                 (scu_ext_dw_data_o[127:0]),
    .scu_ext_dw_strb_o                 (scu_ext_dw_strb_o[15:0]),
    .scu_ext_dw_id_o                   (scu_ext_dw_id_o[4:0]),
    .scu_ext_dw_last_o                 (scu_ext_dw_last_o),
    .scu_ext_db_ready_o                (scu_ext_db_ready_o),
    .scu_ext_rack_o                    (scu_ext_rack_o),
    .scu_ext_wack_o                    (scu_ext_wack_o),
    .scu_ext_cd_valid_o                (scu_ext_cd_valid_o),
    .scu_ext_cd_data_o                 (scu_ext_cd_data_o[127:0]),
    .scu_ext_cd_last_o                 (scu_ext_cd_last_o),
    .scu_txsactive_o                   (scu_txsactive_o),
    .scu_rxlinkactiveack_o             (scu_rxlinkactiveack_o),
    .scu_txlinkactivereq_o             (scu_txlinkactivereq_o),
    .scu_txreqflitpend_o               (scu_txreqflitpend_o),
    .scu_txreqflitv_o                  (scu_txreqflitv_o),
    .scu_txreqflit_o                   (scu_txreqflit_o[99:0]),
    .scu_txdatflitpend_o               (scu_txdatflitpend_o),
    .scu_txdatflitv_o                  (scu_txdatflitv_o),
    .scu_txdatflit_o                   (scu_txdatflit_o[193:0]),
    .scu_rxrsplcrdv_o                  (scu_rxrsplcrdv_o),
    .scu_rxdatlcrdv_o                  (scu_rxdatlcrdv_o),
    .scu_reqmemattr_o                  (scu_reqmemattr_o[7:0]),
    .master_afb0_ack_o                 (master_afb0_ack),
    .master_afb1_ack_o                 (master_afb1_ack),
    .master_afb2_ack_o                 (master_afb2_ack),
    .master_afb3_ack_o                 (master_afb3_ack),
    .master_afb4_ack_o                 (master_afb4_ack),
    .master_afb5_ack_o                 (master_afb5_ack),
    .master_afb_waddr_id_o             (master_afb_waddr_id[3:0]),
    .master_l2db0_ready_o              (master_l2db0_ready),
    .master_l2db1_ready_o              (master_l2db1_ready),
    .master_l2db2_ready_o              (master_l2db2_ready),
    .master_l2db3_ready_o              (master_l2db3_ready),
    .master_l2db4_ready_o              (master_l2db4_ready),
    .master_l2db5_ready_o              (master_l2db5_ready),
    .master_l2db6_ready_o              (master_l2db6_ready),
    .master_l2db7_ready_o              (master_l2db7_ready),
    .master_l2db8_ready_o              (master_l2db8_ready),
    .master_l2db9_ready_o              (master_l2db9_ready),
    .master_l2db10_ready_o             (master_l2db10_ready),
    .master_rsp_dbid_valid_o           (master_rsp_dbid_valid),
    .master_rsp_comp_valid_o           (master_rsp_comp_valid),
    .master_rsp_readreceipt_valid_o    (master_rsp_readreceipt_valid),
    .master_rsp_txnid_o                (master_rsp_txnid[6:0]),
    .master_rsp_dbid_o                 (master_rsp_dbid[7:0]),
    .master_rsp_srcid_o                (master_rsp_srcid[6:0]),
    .master_rsp_resp_o                 (master_rsp_resp[3:0]),
    .master_cpuslv0_dr_valid_o         (master_cpuslv0_dr_valid),
    .master_cpuslv1_dr_valid_o         (master_cpuslv1_dr_valid),
    .master_cpuslv2_dr_valid_o         (master_cpuslv2_dr_valid),
    .master_cpuslv3_dr_valid_o         (master_cpuslv3_dr_valid),
    .master_acpslv_dr_valid_o          (master_acpslv_dr_valid),
    .master_snpslv_dr_valid_o          (master_snpslv_dr_valid),
    .master_cpuslv0_dr_id_o            (master_cpuslv0_dr_id[5:0]),
    .master_cpuslv1_dr_id_o            (master_cpuslv1_dr_id[5:0]),
    .master_cpuslv2_dr_id_o            (master_cpuslv2_dr_id[5:0]),
    .master_cpuslv3_dr_id_o            (master_cpuslv3_dr_id[5:0]),
    .master_acpslv_dr_id_o             (master_acpslv_dr_id[5:0]),
    .master_dr_chunk_o                 (master_dr_chunk[1:0]),
    .master_dr_data_o                  (master_dr_data[127:0]),
    .master_dr_resp_o                  (master_dr_resp[3:0]),
    .master_early_dr_valid_o           (master_early_dr_valid),
    .master_early_dr_id_o              (master_early_dr_id[5:0]),
    .master_early_dr_dbid_o            (master_early_dr_dbid[7:0]),
    .master_early_dr_srcid_o           (master_early_dr_srcid[6:0]),
    .master_early_dr_resp_o            (master_early_dr_resp[3:0]),
    .master_early_dr_data_o            (master_early_dr_data[127:0]),
    .master_early_dr_barrier_o         (master_early_dr_barrier),
    .master_early_dr_same_o            (master_early_dr_same),
    .master_early_dr_chunk_o           (master_early_dr_chunk[1:0]),
    .master_early_dr_ready_o           (master_early_dr_ready),
    .master_cpuslv0_reqbuf_retry_o     (master_cpuslv0_reqbuf_retry[7:0]),
    .master_cpuslv1_reqbuf_retry_o     (master_cpuslv1_reqbuf_retry[7:0]),
    .master_cpuslv2_reqbuf_retry_o     (master_cpuslv2_reqbuf_retry[7:0]),
    .master_cpuslv3_reqbuf_retry_o     (master_cpuslv3_reqbuf_retry[7:0]),
    .master_acpslv_reqbuf_retry_o      (master_acpslv_reqbuf_retry[3:0]),
    .master_snpslv_reqbuf_retry_o      (master_snpslv_reqbuf_retry),
    .master_cpuslv0_pcrdtype_o         (master_cpuslv0_pcrdtype[1:0]),
    .master_cpuslv1_pcrdtype_o         (master_cpuslv1_pcrdtype[1:0]),
    .master_cpuslv2_pcrdtype_o         (master_cpuslv2_pcrdtype[1:0]),
    .master_cpuslv3_pcrdtype_o         (master_cpuslv3_pcrdtype[1:0]),
    .master_acpslv_pcrdtype_o          (master_acpslv_pcrdtype[1:0]),
    .master_snpslv_pcrdtype_o          (master_snpslv_pcrdtype[1:0]),
    .master_cpuslv0_strex_db_valid_o   (master_cpuslv0_strex_db_valid),
    .master_cpuslv1_strex_db_valid_o   (master_cpuslv1_strex_db_valid),
    .master_cpuslv2_strex_db_valid_o   (master_cpuslv2_strex_db_valid),
    .master_cpuslv3_strex_db_valid_o   (master_cpuslv3_strex_db_valid),
    .master_cpuslv0_barrier_db_valid_o (master_cpuslv0_barrier_db_valid),
    .master_cpuslv1_barrier_db_valid_o (master_cpuslv1_barrier_db_valid),
    .master_cpuslv2_barrier_db_valid_o (master_cpuslv2_barrier_db_valid),
    .master_cpuslv3_barrier_db_valid_o (master_cpuslv3_barrier_db_valid),
    .master_cpuslv0_dev_db_valid_o     (master_cpuslv0_dev_db_valid),
    .master_cpuslv1_dev_db_valid_o     (master_cpuslv1_dev_db_valid),
    .master_cpuslv2_dev_db_valid_o     (master_cpuslv2_dev_db_valid),
    .master_cpuslv3_dev_db_valid_o     (master_cpuslv3_dev_db_valid),
    .master_db_resp_o                  (master_db_resp[1:0]),
    .master_db_waddr_valid_o           (master_db_waddr_valid),
    .master_db_waddr_o                 (master_db_waddr[3:0]),
    .master_cpuslv0_waddrs_valid_o     (master_cpuslv0_waddrs_valid),
    .master_cpuslv1_waddrs_valid_o     (master_cpuslv1_waddrs_valid),
    .master_cpuslv2_waddrs_valid_o     (master_cpuslv2_waddrs_valid),
    .master_cpuslv3_waddrs_valid_o     (master_cpuslv3_waddrs_valid),
    .master_snpslv_waddrs_valid_o      (master_snpslv_waddrs_valid),
    .master_snpslv_db_valid_o          (master_snpslv_db_valid),
    .master_ramctl_active_o            (master_ramctl_active),
    .master_ramctl_valid_o             (master_ramctl_valid),
    .master_ramctl_chunks_o            (master_ramctl_chunks[3:0]),
    .master_ramctl_data_o              (master_ramctl_data[255:0]),
    .master_ramctl_way_o               (master_ramctl_way[3:0]),
    .master_ramctl_index_o             (master_ramctl_index[10:0]),
    .master_cpuslv0_l2_waiting_o       (master_cpuslv0_l2_waiting[7:0]),
    .master_cpuslv1_l2_waiting_o       (master_cpuslv1_l2_waiting[7:0]),
    .master_cpuslv2_l2_waiting_o       (master_cpuslv2_l2_waiting[7:0]),
    .master_cpuslv3_l2_waiting_o       (master_cpuslv3_l2_waiting[7:0]),
    .master_acpslv_l2_waiting_o        (master_acpslv_l2_waiting[3:0]),
    .master_rxla_run_o                 (master_rxla_run),
    .master_rxla_deactivate_o          (master_rxla_deactivate),
    .master_rxla_stop_o                (master_rxla_stop),
    .master_txla_run_o                 (master_txla_run),
    .master_txla_deactivate_o          (master_txla_deactivate),
    .master_hz_tc2_o                   (master_hz_tc2),
    .master_hz_tc4_o                   (master_hz_tc4),
    .master_hz_waddr_tc4_o             (master_hz_waddr_tc4[3:0]),
    .master_hz_dev_tc2_o               (master_hz_dev_tc2),
    .master_hz_l2db_tc2_o              (master_hz_l2db_tc2),
    .master_hz_dirty_tc2_o             (master_hz_dirty_tc2),
    .master_hz_cu_tc2_o                (master_hz_cu_tc2),
    .master_l2db_tc2_o                 (master_l2db_tc2[3:0]),
    .master_ncoh_db_o                  (master_ncoh_db),
    .master_waddr_valid_o              (master_waddr_valid[15:0])
  );  // u_scu_master

  ca53scu_sam #(`CA53_SCU_INT_PARAM_INST) u_scu_sam (
    /*ARMAUTO*/
    // Inputs
    .tagctl_sam_addr_tc2_i (tagctl_sam_addr_tc2[39:6]),
    .tagctl_mn_op_tc2_i    (tagctl_mn_op_tc2),
    .ext_sammnbase_i       (ext_sammnbase_i[39:24]),
    .ext_samaddrmap0_i     (ext_samaddrmap0_i[1:0]),
    .ext_samaddrmap1_i     (ext_samaddrmap1_i[1:0]),
    .ext_samaddrmap2_i     (ext_samaddrmap2_i[1:0]),
    .ext_samaddrmap3_i     (ext_samaddrmap3_i[1:0]),
    .ext_samaddrmap4_i     (ext_samaddrmap4_i[1:0]),
    .ext_samaddrmap5_i     (ext_samaddrmap5_i[1:0]),
    .ext_samaddrmap6_i     (ext_samaddrmap6_i[1:0]),
    .ext_samaddrmap7_i     (ext_samaddrmap7_i[1:0]),
    .ext_samaddrmap8_i     (ext_samaddrmap8_i[1:0]),
    .ext_samaddrmap9_i     (ext_samaddrmap9_i[1:0]),
    .ext_samaddrmap10_i    (ext_samaddrmap10_i[1:0]),
    .ext_samaddrmap11_i    (ext_samaddrmap11_i[1:0]),
    .ext_samaddrmap12_i    (ext_samaddrmap12_i[1:0]),
    .ext_samaddrmap13_i    (ext_samaddrmap13_i[1:0]),
    .ext_samaddrmap14_i    (ext_samaddrmap14_i[1:0]),
    .ext_samaddrmap15_i    (ext_samaddrmap15_i[1:0]),
    .ext_sammnnodeid_i     (ext_sammnnodeid_i[6:0]),
    .ext_samhni0nodeid_i   (ext_samhni0nodeid_i[6:0]),
    .ext_samhni1nodeid_i   (ext_samhni1nodeid_i[6:0]),
    .ext_samhnf0nodeid_i   (ext_samhnf0nodeid_i[6:0]),
    .ext_samhnf1nodeid_i   (ext_samhnf1nodeid_i[6:0]),
    .ext_samhnf2nodeid_i   (ext_samhnf2nodeid_i[6:0]),
    .ext_samhnf3nodeid_i   (ext_samhnf3nodeid_i[6:0]),
    .ext_samhnf4nodeid_i   (ext_samhnf4nodeid_i[6:0]),
    .ext_samhnf5nodeid_i   (ext_samhnf5nodeid_i[6:0]),
    .ext_samhnf6nodeid_i   (ext_samhnf6nodeid_i[6:0]),
    .ext_samhnf7nodeid_i   (ext_samhnf7nodeid_i[6:0]),
    .ext_samhnfmode_i      (ext_samhnfmode_i[2:0]),
    // Output
    .sam_tgtid_tc2_o       (sam_tgtid_tc2[6:0])
  );  // u_scu_sam


  //-----------------------------------------------------------------------------
  // Output assignments
  //-----------------------------------------------------------------------------

  assign scu_cpu0_broadcastinner_o = config_broadcastinner;
  assign scu_cpu1_broadcastinner_o = config_broadcastinner;
  assign scu_cpu2_broadcastinner_o = config_broadcastinner;
  assign scu_cpu3_broadcastinner_o = config_broadcastinner;

  assign scu_mbistack0_o = tagctl_mbistreq;

  // Select MBIST data from either the tag RAMs or the CPUs.
  assign scu_mbistoutdata0_o = {l2db0_master_data[`CA53_MBIST0_DATA_W-1:40],
                                tagctl_mbist_sel ? tagctl_mbistoutdata[39:32] : l2db0_master_data[39:32],
                                victimctl_mbist_sel ? victimctl_mbistoutdata :
                                tagctl_mbist_sel    ? tagctl_mbistoutdata[31:0] :
                                                      l2db0_master_data[31:0]};

  generate if (SCU_CACHE_PROTECTION[0] || CPU_CACHE_PROTECTION[0]) begin : g_ecc
    // Output information about any errors to the governor, for it to record
    // in the L2MERRSR. If multiple errors occur on the same cycle, then they
    // are prioritised as follows:
    // 1 Fatal tag error
    // 2 Fatal data error
    // 3 Correctable data error
    // 4 Correctable tag error
    //
    // L2 tag errors have priority over L1 tag errors (this is done in tagctl).
    assign l2ecc_err_sel = ramctl_err_valid & ~tagctl_err_fatal;

    assign scu_l2ecc_valid_o     = l2ecc_err_sel | tagctl_err_valid;
    assign scu_l2ecc_fatal_o     = l2ecc_err_sel ? ramctl_err_fatal : tagctl_err_fatal;
    assign scu_l2ecc_ramid_o     = l2ecc_err_sel ? 2'b01 : {~tagctl_err_way[4], 1'b0};
    assign scu_l2ecc_cpuid_way_o = l2ecc_err_sel ? {1'b0, ramctl_err_bank} : tagctl_err_way[3:0];
    assign scu_l2ecc_index_o     = l2ecc_err_sel ? ramctl_err_index : {4'b0000, tagctl_err_index};

  end else begin : g_n_ecc

    assign scu_l2ecc_valid_o     = 1'b0;
    assign scu_l2ecc_fatal_o     = 1'b0;
    assign scu_l2ecc_ramid_o     = 2'b00;
    assign scu_l2ecc_cpuid_way_o = 4'b0000;
    assign scu_l2ecc_index_o     = {15{1'b0}};

  end endgenerate

  assign scu_ext_ac_ready_o = scu_ext_ac_ready;
  assign scu_acp_arready_o = scu_acp_arready;
  assign scu_acp_awready_o = scu_acp_awready;
  assign scu_acp_wready_o = scu_acp_wready;
  assign l2_victimram_en_o = l2_victimram_en;
  assign l2_victimram_no_acc_next_cycle_o = l2_victimram_no_acc_next_cycle;
  assign l2_dataram_no_acc_next_cycle_o = l2_dataram_no_acc_next_cycle;

  //-----------------------------------------------------------------------------
  //  Assertions
  //-----------------------------------------------------------------------------


`ifdef ARM_ASSERT_ON

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Clock gated while AR transfer being sent")
  u_ovl_clock_gated_on_ar (
    .clk             (CLKIN),
    .reset_n         (reset_n),
    .antecedent_expr (scu_ext_ar_valid_o),
    .consequent_expr (u_clk.clken)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Clock gated when R transfer received")
  u_ovl_clock_gated_on_r (
    .clk             (CLKIN),
    .reset_n         (reset_n),
    .antecedent_expr (clean_aclken & scu_ext_dr_valid_i),
    .consequent_expr (u_clk.clken)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Clock gated while AW transfer being sent")
  u_ovl_clock_gated_on_aw (
    .clk             (CLKIN),
    .reset_n         (reset_n),
    .antecedent_expr (scu_ext_aw_valid_o),
    .consequent_expr (u_clk.clken)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Clock gated while W transfer being sent")
  u_ovl_clock_gated_on_w (
    .clk             (CLKIN),
    .reset_n         (reset_n),
    .antecedent_expr (scu_ext_dw_valid_o),
    .consequent_expr (u_clk.clken)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Clock gated when B transfer received")
  u_ovl_clock_gated_on_b (
    .clk             (CLKIN),
    .reset_n         (reset_n),
    .antecedent_expr (clean_aclken & scu_ext_db_valid_i),
    .consequent_expr (u_clk.clken)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Clock gated while CR transfer being sent")
  u_ovl_clock_gated_on_cr (
    .clk             (CLKIN),
    .reset_n         (reset_n),
    .antecedent_expr (scu_ext_cr_valid_o),
    .consequent_expr (u_clk.clken)
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Clock gated while CD transfer being sent")
  u_ovl_clock_gated_on_cd (
    .clk             (CLKIN),
    .reset_n         (reset_n),
    .antecedent_expr (scu_ext_cd_valid_o),
    .consequent_expr (u_clk.clken)
  );

  reg [3:0] ovl_smp_en;
  always @(posedge CLKIN or negedge reset_n)
  if (~reset_n) begin
    ovl_smp_en <= 4'b0000;
  end else begin
    ovl_smp_en <= {gov_cpu3_smp_en_i,
                   gov_cpu2_smp_en_i,
                   gov_cpu1_smp_en_i,
                   gov_cpu0_smp_en_i};
  end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "New snoop should not be issued to CPU while SMP enable is low")
  u_ovl_snoop_during_smp_low0 (
    .clk             (CLKIN),
    .reset_n         (reset_n),
    .antecedent_expr (scu_wfx_ready_o[0] & ~ovl_smp_en[0]),
    .consequent_expr (~scu_cpu0_ac_valid_o)
  );

  wire [5:0]           ovl_slvs_busy;
  wire [MAX_L2DBS-1:0] ovl_l2dbs_busy;

  assign ovl_slvs_busy[0] = |u_scu_cpuslv0.g_cpuslv.reqbuf_busy;

  generate
    if (NUM_CPUS > 1) begin : g_ovl_1
      assert_implication #(`OVL_FATAL, `OVL_ASSERT, "New snoop should not be issued to CPU while SMP enable is low")
      u_ovl_snoop_during_smp_low1 (
        .clk             (CLKIN),
        .reset_n         (reset_n),
        .antecedent_expr (scu_wfx_ready_o[1] & ~ovl_smp_en[1]),
        .consequent_expr (~scu_cpu1_ac_valid_o)
      );

      assign ovl_slvs_busy[1] = |u_scu_cpuslv1.g_cpuslv.reqbuf_busy;
    end else begin : g_n_ovl_1
      assign ovl_slvs_busy[1] = 1'b0;
    end
    if (NUM_CPUS > 2) begin : g_ovl_2
      assert_implication #(`OVL_FATAL, `OVL_ASSERT, "New snoop should not be issued to CPU while SMP enable is low")
      u_ovl_snoop_during_smp_low2 (
        .clk             (CLKIN),
        .reset_n         (reset_n),
        .antecedent_expr (scu_wfx_ready_o[2] & ~ovl_smp_en[2]),
        .consequent_expr (~scu_cpu2_ac_valid_o)
      );

      assign ovl_slvs_busy[2] = |u_scu_cpuslv2.g_cpuslv.reqbuf_busy;
    end else begin : g_n_ovl_2
      assign ovl_slvs_busy[2] = 1'b0;
    end
    if (NUM_CPUS > 3) begin : g_ovl_3
      assert_implication #(`OVL_FATAL, `OVL_ASSERT, "New snoop should not be issued to CPU while SMP enable is low")
      u_ovl_snoop_during_smp_low3 (
        .clk             (CLKIN),
        .reset_n         (reset_n),
        .antecedent_expr (scu_wfx_ready_o[3] & ~ovl_smp_en[3]),
        .consequent_expr (~scu_cpu3_ac_valid_o)
      );

      assign ovl_slvs_busy[3] = |u_scu_cpuslv3.g_cpuslv.reqbuf_busy;
    end else begin : g_n_ovl_3
      assign ovl_slvs_busy[3] = 1'b0;
    end
    if (ACP) begin : g_ovl_4
      assign ovl_slvs_busy[4] = |u_scu_acpslv.g_acpslv.reqbuf_busy;
    end else begin : g_n_ovl_4
      assign ovl_slvs_busy[4] = 1'b0;
    end

    assign ovl_slvs_busy[5] = |u_scu_snpslv.reqbuf_busy;

    assign ovl_l2dbs_busy[0] = |u_scu_l2db0.g_l2db.l2db_state & ~u_scu_l2db0.g_l2db.l2db_release;
    assign ovl_l2dbs_busy[1] = |u_scu_l2db1.g_l2db.l2db_state & ~u_scu_l2db1.g_l2db.l2db_release;
    assign ovl_l2dbs_busy[2] = |u_scu_l2db2.g_l2db.l2db_state & ~u_scu_l2db2.g_l2db.l2db_release;
    assign ovl_l2dbs_busy[3] = |u_scu_l2db3.g_l2db.l2db_state & ~u_scu_l2db3.g_l2db.l2db_release;
    if (NUM_L2DBS > 4) begin : g_ovl_l2db4
      assign ovl_l2dbs_busy[4] = |u_scu_l2db4.g_l2db.l2db_state & ~u_scu_l2db4.g_l2db.l2db_release;
    end
    if (NUM_L2DBS > 5) begin : g_ovl_l2db5
      assign ovl_l2dbs_busy[5] = |u_scu_l2db5.g_l2db.l2db_state & ~u_scu_l2db5.g_l2db.l2db_release;
    end
    if (NUM_L2DBS > 6) begin : g_ovl_l2db6
      assign ovl_l2dbs_busy[6] = |u_scu_l2db6.g_l2db.l2db_state & ~u_scu_l2db6.g_l2db.l2db_release;
    end
    if (NUM_L2DBS > 7) begin : g_ovl_l2db7
      assign ovl_l2dbs_busy[7] = |u_scu_l2db7.g_l2db.l2db_state & ~u_scu_l2db7.g_l2db.l2db_release;
    end
    if (NUM_L2DBS > 8) begin : g_ovl_l2db8
      assign ovl_l2dbs_busy[8] = |u_scu_l2db8.g_l2db.l2db_state & ~u_scu_l2db8.g_l2db.l2db_release;
    end
    if (NUM_L2DBS > 9) begin : g_ovl_l2db9
      assign ovl_l2dbs_busy[9] = |u_scu_l2db9.g_l2db.l2db_state & ~u_scu_l2db9.g_l2db.l2db_release;
    end
    if (NUM_L2DBS > 10) begin : g_ovl_l2db10
      assign ovl_l2dbs_busy[10] = |u_scu_l2db10.g_l2db.l2db_state & ~u_scu_l2db10.g_l2db.l2db_release;
    end

    genvar i;

    for (i = NUM_L2DBS; i < MAX_L2DBS; i = i + 1) begin : g_ovl_l2db_unused
      assign ovl_l2dbs_busy[i] = 1'b0;
    end
  endgenerate

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "All L2DBs must be idle when all reqbufs are idle")
  u_ovl_l2dbs_idle (
    .clk             (CLKIN),
    .reset_n         (reset_n),
    .antecedent_expr (~|ovl_slvs_busy),
    .consequent_expr (~|ovl_l2dbs_busy)
  );

`endif


endmodule // ca53scu

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/


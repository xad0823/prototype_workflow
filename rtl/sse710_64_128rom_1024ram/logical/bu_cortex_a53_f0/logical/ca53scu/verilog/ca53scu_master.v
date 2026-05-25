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

//-----------------------------------------------------------------------------
// Description:
//  The master block implements the ACE or Skyros master interface. For ACE it
//  includes the AR, R, AW, W, B and CD channels, but not AC or CR.
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "cortexa53params.v"


module ca53scu_master #(`CA53_SCU_INT_PARAM_DECL)
 (
  input  wire                           CLKIN,
  input  wire                           clk,
  input  wire                           clk_ext_master,
  input  wire                           reset_n,
  input  wire                           DFTSE,

  input  wire                           tagctl_master_active_i,
  input  wire                           snpslv_master_active_i,
  input  wire                           standbywfil2_req_i,
  output wire                           master_active_o,
  output wire                           master_linkactive_o,
  output wire                           master_writes_active_o,
  output wire                           scu_axierr_o,
  output wire                           scu_eccerr_o,
  input  wire                           config_broadcastinner_i,
  input  wire                           config_broadcastouter_i,
  input  wire                           gov_clear_axierr_i,
  input  wire                           gov_clear_eccerr_i,
  output wire                           nexterrirq_o,
  output wire                           ninterrirq_o,
  output wire                           scu_cpu0_evnt_bus_cycle_o,
  output wire                           scu_cpu1_evnt_bus_cycle_o,
  output wire                           scu_cpu2_evnt_bus_cycle_o,
  output wire                           scu_cpu3_evnt_bus_cycle_o,
  output wire                           scu_cpu0_evnt_bus_acc_rd_o,
  output wire                           scu_cpu1_evnt_bus_acc_rd_o,
  output wire                           scu_cpu2_evnt_bus_acc_rd_o,
  output wire                           scu_cpu3_evnt_bus_acc_rd_o,
  output wire                           scu_cpu0_evnt_bus_acc_wr_o,
  output wire                           scu_cpu1_evnt_bus_acc_wr_o,
  output wire                           scu_cpu2_evnt_bus_acc_wr_o,
  output wire                           scu_cpu3_evnt_bus_acc_wr_o,
  output wire                           scu_cpu0_evnt_l2_refill_o,
  output wire                           scu_cpu1_evnt_l2_refill_o,
  output wire                           scu_cpu2_evnt_l2_refill_o,
  output wire                           scu_cpu3_evnt_l2_refill_o,
  output wire                           scu_cpu0_evnt_l2_wb_o,
  output wire                           scu_cpu1_evnt_l2_wb_o,
  output wire                           scu_cpu2_evnt_l2_wb_o,
  output wire                           scu_cpu3_evnt_l2_wb_o,

  // External ACE channels
  input  wire                           clean_aclken_i,

  output wire                           scu_ext_ar_valid_o,
  input  wire                           scu_ext_ar_ready_i,
  output wire [43:0]                    scu_ext_ar_addr_o,
  output wire [7:0]                     scu_ext_ar_len_o,
  output wire [2:0]                     scu_ext_ar_size_o,
  output wire [1:0]                     scu_ext_ar_burst_o,
  output wire                           scu_ext_ar_lock_o,
  output wire [3:0]                     scu_ext_ar_cache_o,
  output wire [2:0]                     scu_ext_ar_prot_o,
  output wire [1:0]                     scu_ext_ar_domain_o,
  output wire [3:0]                     scu_ext_ar_snoop_o,
  output wire [5:0]                     scu_ext_ar_id_o,
  output wire [1:0]                     scu_ext_ar_bar_o,
  output wire [7:0]                     scu_ext_rdmemattr_o,

  input  wire                           scu_ext_dr_valid_i,
  output wire                           scu_ext_dr_ready_o,
  input  wire [5:0]                     scu_ext_dr_id_i,
  input  wire                           scu_ext_dr_last_i,
  input  wire [127:0]                   scu_ext_dr_data_i,
  input  wire [3:0]                     scu_ext_dr_resp_i,

  output wire                           scu_ext_aw_valid_o,
  input  wire                           scu_ext_aw_ready_i,
  output wire [43:0]                    scu_ext_aw_addr_o,
  output wire [7:0]                     scu_ext_aw_len_o,
  output wire [2:0]                     scu_ext_aw_size_o,
  output wire [1:0]                     scu_ext_aw_burst_o,
  output wire                           scu_ext_aw_lock_o,
  output wire [3:0]                     scu_ext_aw_cache_o,
  output wire [2:0]                     scu_ext_aw_prot_o,
  output wire [4:0]                     scu_ext_aw_id_o,
  output wire [2:0]                     scu_ext_aw_snoop_o,
  output wire [1:0]                     scu_ext_aw_domain_o,
  output wire [1:0]                     scu_ext_aw_bar_o,
  output wire                           scu_ext_aw_unique_o,
  output wire [7:0]                     scu_ext_wrmemattr_o,

  output wire                           scu_ext_dw_valid_o,
  input  wire                           scu_ext_dw_ready_i,
  output wire [127:0]                   scu_ext_dw_data_o,
  output wire [15:0]                    scu_ext_dw_strb_o,
  output wire [4:0]                     scu_ext_dw_id_o,
  output wire                           scu_ext_dw_last_o,

  input  wire                           scu_ext_db_valid_i,
  output wire                           scu_ext_db_ready_o,
  input  wire [4:0]                     scu_ext_db_id_i,
  input  wire [1:0]                     scu_ext_db_resp_i,

  output wire                           scu_ext_rack_o,
  output wire                           scu_ext_wack_o,

  output wire                           scu_ext_cd_valid_o,
  input  wire                           scu_ext_cd_ready_i,
  output wire [127:0]                   scu_ext_cd_data_o,
  output wire                           scu_ext_cd_last_o,

  // External Skyros channels
  input  wire [6:0]                     config_nodeid_i,
  output wire                           scu_txsactive_o,
  input  wire                           ext_rxlinkactivereq_i,
  output wire                           scu_rxlinkactiveack_o,
  output wire                           scu_txlinkactivereq_o,
  input  wire                           ext_txlinkactiveack_i,
  output wire                           scu_txreqflitpend_o,
  output wire                           scu_txreqflitv_o,
  output wire [99:0]                    scu_txreqflit_o,
  input  wire                           ext_txreqlcrdv_i,
  output wire                           scu_txdatflitpend_o,
  output wire                           scu_txdatflitv_o,
  output wire [193:0]                   scu_txdatflit_o,
  input  wire                           ext_txdatlcrdv_i,
  input  wire                           ext_rxrspflitpend_i,
  input  wire                           ext_rxrspflitv_i,
  input  wire [44:0]                    ext_rxrspflit_i,
  output wire                           scu_rxrsplcrdv_o,
  input  wire                           ext_rxdatflitpend_i,
  input  wire                           ext_rxdatflitv_i,
  input  wire [193:0]                   ext_rxdatflit_i,
  output wire                           scu_rxdatlcrdv_o,
  output wire [7:0]                     scu_reqmemattr_o,

  // AFB address requests
  input  wire                           afb0_master_req_i,
  input  wire                           afb0_master_flush_i,
  input  wire [6:0]                     afb0_master_id_i,
  input  wire [40:0]                    afb0_master_addr_i,
  input  wire [4:0]                     afb0_master_opcode_i,
  input  wire [1:0]                     afb0_master_len_i,
  input  wire [2:0]                     afb0_master_size_i,
  input  wire                           afb0_master_lock_i,
  input  wire [7:0]                     afb0_master_attrs_i,
  input  wire [1:0]                     afb0_master_prot_i,
  input  wire [6:0]                     afb0_master_tgtid_i,
  input  wire [3:0]                     afb0_master_l2db_i,
  input  wire                           afb0_master_static_pcredit_i,
  input  wire [1:0]                     afb0_master_pcrdtype_i,
  output wire                           master_afb0_ack_o,

  input  wire                           afb1_master_req_i,
  input  wire                           afb1_master_flush_i,
  input  wire [6:0]                     afb1_master_id_i,
  input  wire [40:0]                    afb1_master_addr_i,
  input  wire [4:0]                     afb1_master_opcode_i,
  input  wire [1:0]                     afb1_master_len_i,
  input  wire [2:0]                     afb1_master_size_i,
  input  wire                           afb1_master_lock_i,
  input  wire [7:0]                     afb1_master_attrs_i,
  input  wire [1:0]                     afb1_master_prot_i,
  input  wire [6:0]                     afb1_master_tgtid_i,
  input  wire [3:0]                     afb1_master_l2db_i,
  input  wire                           afb1_master_static_pcredit_i,
  input  wire [1:0]                     afb1_master_pcrdtype_i,
  output wire                           master_afb1_ack_o,

  input  wire                           afb2_master_req_i,
  input  wire                           afb2_master_flush_i,
  input  wire [6:0]                     afb2_master_id_i,
  input  wire [40:0]                    afb2_master_addr_i,
  input  wire [4:0]                     afb2_master_opcode_i,
  input  wire [1:0]                     afb2_master_len_i,
  input  wire [2:0]                     afb2_master_size_i,
  input  wire                           afb2_master_lock_i,
  input  wire [7:0]                     afb2_master_attrs_i,
  input  wire [1:0]                     afb2_master_prot_i,
  input  wire [6:0]                     afb2_master_tgtid_i,
  input  wire [3:0]                     afb2_master_l2db_i,
  input  wire                           afb2_master_static_pcredit_i,
  input  wire [1:0]                     afb2_master_pcrdtype_i,
  output wire                           master_afb2_ack_o,

  input  wire                           afb3_master_req_i,
  input  wire                           afb3_master_flush_i,
  input  wire [6:0]                     afb3_master_id_i,
  input  wire [40:0]                    afb3_master_addr_i,
  input  wire [4:0]                     afb3_master_opcode_i,
  input  wire [1:0]                     afb3_master_len_i,
  input  wire [2:0]                     afb3_master_size_i,
  input  wire                           afb3_master_lock_i,
  input  wire [7:0]                     afb3_master_attrs_i,
  input  wire [1:0]                     afb3_master_prot_i,
  input  wire [6:0]                     afb3_master_tgtid_i,
  input  wire [3:0]                     afb3_master_l2db_i,
  input  wire                           afb3_master_static_pcredit_i,
  input  wire [1:0]                     afb3_master_pcrdtype_i,
  output wire                           master_afb3_ack_o,

  input  wire                           afb4_master_req_i,
  input  wire                           afb4_master_flush_i,
  input  wire [6:0]                     afb4_master_id_i,
  input  wire [40:0]                    afb4_master_addr_i,
  input  wire [4:0]                     afb4_master_opcode_i,
  input  wire [1:0]                     afb4_master_len_i,
  input  wire [2:0]                     afb4_master_size_i,
  input  wire                           afb4_master_lock_i,
  input  wire [7:0]                     afb4_master_attrs_i,
  input  wire [1:0]                     afb4_master_prot_i,
  input  wire [6:0]                     afb4_master_tgtid_i,
  input  wire [3:0]                     afb4_master_l2db_i,
  input  wire                           afb4_master_static_pcredit_i,
  input  wire [1:0]                     afb4_master_pcrdtype_i,
  output wire                           master_afb4_ack_o,

  input  wire                           afb5_master_req_i,
  input  wire                           afb5_master_flush_i,
  input  wire [6:0]                     afb5_master_id_i,
  input  wire [40:0]                    afb5_master_addr_i,
  input  wire [4:0]                     afb5_master_opcode_i,
  input  wire [1:0]                     afb5_master_len_i,
  input  wire [2:0]                     afb5_master_size_i,
  input  wire                           afb5_master_lock_i,
  input  wire [7:0]                     afb5_master_attrs_i,
  input  wire [1:0]                     afb5_master_prot_i,
  input  wire [6:0]                     afb5_master_tgtid_i,
  input  wire [3:0]                     afb5_master_l2db_i,
  input  wire                           afb5_master_static_pcredit_i,
  input  wire [1:0]                     afb5_master_pcrdtype_i,
  output wire                           master_afb5_ack_o,

  output wire [3:0]                     master_afb_waddr_id_o,
  input  wire                           tagctl_err_fatal_i,

  // L2DB data requests
  input  wire                           l2db0_master_valid_i,
  input  wire                           l2db0_master_snoop_i,
  input  wire [5:0]                     l2db0_master_id_i,
  input  wire [7:0]                     l2db0_master_dbid_i,
  input  wire [6:0]                     l2db0_master_tgtid_i,
  input  wire [3:0]                     l2db0_master_qos_i,
  input  wire [127:0]                   l2db0_master_data_i,
  input  wire [15:0]                    l2db0_master_strb_i,
  input  wire [1:0]                     l2db0_master_chunk_i,
  input  wire                           l2db0_master_last_i,
  input  wire [2:0]                     l2db0_master_opcode_i,
  input  wire [2:0]                     l2db0_master_snpresp_i,
  input  wire [1:0]                     l2db0_master_len_i,
  input  wire [2:0]                     l2db0_master_size_i,
  input  wire [5:0]                     l2db0_master_addr_i,
  input  wire [7:0]                     l2db0_master_attrs_i,
  input  wire                           l2db0_master_prot_i,
  input  wire                           l2db0_master_strex_i,
  input  wire                           l2db0_master_unique_i,
  input  wire                           l2db0_master_err_i,
  output wire                           master_l2db0_ready_o,

  input  wire                           l2db1_master_valid_i,
  input  wire                           l2db1_master_snoop_i,
  input  wire [5:0]                     l2db1_master_id_i,
  input  wire [7:0]                     l2db1_master_dbid_i,
  input  wire [6:0]                     l2db1_master_tgtid_i,
  input  wire [3:0]                     l2db1_master_qos_i,
  input  wire [127:0]                   l2db1_master_data_i,
  input  wire [15:0]                    l2db1_master_strb_i,
  input  wire [1:0]                     l2db1_master_chunk_i,
  input  wire                           l2db1_master_last_i,
  input  wire [2:0]                     l2db1_master_opcode_i,
  input  wire [2:0]                     l2db1_master_snpresp_i,
  input  wire [1:0]                     l2db1_master_len_i,
  input  wire [2:0]                     l2db1_master_size_i,
  input  wire [5:0]                     l2db1_master_addr_i,
  input  wire [7:0]                     l2db1_master_attrs_i,
  input  wire                           l2db1_master_prot_i,
  input  wire                           l2db1_master_strex_i,
  input  wire                           l2db1_master_unique_i,
  input  wire                           l2db1_master_err_i,
  output wire                           master_l2db1_ready_o,

  input  wire                           l2db2_master_valid_i,
  input  wire                           l2db2_master_snoop_i,
  input  wire [5:0]                     l2db2_master_id_i,
  input  wire [7:0]                     l2db2_master_dbid_i,
  input  wire [6:0]                     l2db2_master_tgtid_i,
  input  wire [3:0]                     l2db2_master_qos_i,
  input  wire [127:0]                   l2db2_master_data_i,
  input  wire [15:0]                    l2db2_master_strb_i,
  input  wire [1:0]                     l2db2_master_chunk_i,
  input  wire                           l2db2_master_last_i,
  input  wire [2:0]                     l2db2_master_opcode_i,
  input  wire [2:0]                     l2db2_master_snpresp_i,
  input  wire [1:0]                     l2db2_master_len_i,
  input  wire [2:0]                     l2db2_master_size_i,
  input  wire [5:0]                     l2db2_master_addr_i,
  input  wire [7:0]                     l2db2_master_attrs_i,
  input  wire                           l2db2_master_prot_i,
  input  wire                           l2db2_master_strex_i,
  input  wire                           l2db2_master_unique_i,
  input  wire                           l2db2_master_err_i,
  output wire                           master_l2db2_ready_o,

  input  wire                           l2db3_master_valid_i,
  input  wire                           l2db3_master_snoop_i,
  input  wire [5:0]                     l2db3_master_id_i,
  input  wire [7:0]                     l2db3_master_dbid_i,
  input  wire [6:0]                     l2db3_master_tgtid_i,
  input  wire [3:0]                     l2db3_master_qos_i,
  input  wire [127:0]                   l2db3_master_data_i,
  input  wire [15:0]                    l2db3_master_strb_i,
  input  wire [1:0]                     l2db3_master_chunk_i,
  input  wire                           l2db3_master_last_i,
  input  wire [2:0]                     l2db3_master_opcode_i,
  input  wire [2:0]                     l2db3_master_snpresp_i,
  input  wire [1:0]                     l2db3_master_len_i,
  input  wire [2:0]                     l2db3_master_size_i,
  input  wire [5:0]                     l2db3_master_addr_i,
  input  wire [7:0]                     l2db3_master_attrs_i,
  input  wire                           l2db3_master_prot_i,
  input  wire                           l2db3_master_strex_i,
  input  wire                           l2db3_master_unique_i,
  input  wire                           l2db3_master_err_i,
  output wire                           master_l2db3_ready_o,

  input  wire                           l2db4_master_valid_i,
  input  wire                           l2db4_master_snoop_i,
  input  wire [5:0]                     l2db4_master_id_i,
  input  wire [7:0]                     l2db4_master_dbid_i,
  input  wire [6:0]                     l2db4_master_tgtid_i,
  input  wire [3:0]                     l2db4_master_qos_i,
  input  wire [127:0]                   l2db4_master_data_i,
  input  wire [15:0]                    l2db4_master_strb_i,
  input  wire [1:0]                     l2db4_master_chunk_i,
  input  wire                           l2db4_master_last_i,
  input  wire [2:0]                     l2db4_master_opcode_i,
  input  wire [2:0]                     l2db4_master_snpresp_i,
  input  wire [1:0]                     l2db4_master_len_i,
  input  wire [2:0]                     l2db4_master_size_i,
  input  wire [5:0]                     l2db4_master_addr_i,
  input  wire [7:0]                     l2db4_master_attrs_i,
  input  wire                           l2db4_master_prot_i,
  input  wire                           l2db4_master_strex_i,
  input  wire                           l2db4_master_unique_i,
  input  wire                           l2db4_master_err_i,
  output wire                           master_l2db4_ready_o,

  input  wire                           l2db5_master_valid_i,
  input  wire                           l2db5_master_snoop_i,
  input  wire [5:0]                     l2db5_master_id_i,
  input  wire [7:0]                     l2db5_master_dbid_i,
  input  wire [6:0]                     l2db5_master_tgtid_i,
  input  wire [3:0]                     l2db5_master_qos_i,
  input  wire [127:0]                   l2db5_master_data_i,
  input  wire [15:0]                    l2db5_master_strb_i,
  input  wire [1:0]                     l2db5_master_chunk_i,
  input  wire                           l2db5_master_last_i,
  input  wire [2:0]                     l2db5_master_opcode_i,
  input  wire [2:0]                     l2db5_master_snpresp_i,
  input  wire [1:0]                     l2db5_master_len_i,
  input  wire [2:0]                     l2db5_master_size_i,
  input  wire [5:0]                     l2db5_master_addr_i,
  input  wire [7:0]                     l2db5_master_attrs_i,
  input  wire                           l2db5_master_prot_i,
  input  wire                           l2db5_master_strex_i,
  input  wire                           l2db5_master_unique_i,
  input  wire                           l2db5_master_err_i,
  output wire                           master_l2db5_ready_o,

  input  wire                           l2db6_master_valid_i,
  input  wire                           l2db6_master_snoop_i,
  input  wire [5:0]                     l2db6_master_id_i,
  input  wire [7:0]                     l2db6_master_dbid_i,
  input  wire [6:0]                     l2db6_master_tgtid_i,
  input  wire [3:0]                     l2db6_master_qos_i,
  input  wire [127:0]                   l2db6_master_data_i,
  input  wire [15:0]                    l2db6_master_strb_i,
  input  wire [1:0]                     l2db6_master_chunk_i,
  input  wire                           l2db6_master_last_i,
  input  wire [2:0]                     l2db6_master_opcode_i,
  input  wire [2:0]                     l2db6_master_snpresp_i,
  input  wire [1:0]                     l2db6_master_len_i,
  input  wire [2:0]                     l2db6_master_size_i,
  input  wire [5:0]                     l2db6_master_addr_i,
  input  wire [7:0]                     l2db6_master_attrs_i,
  input  wire                           l2db6_master_prot_i,
  input  wire                           l2db6_master_strex_i,
  input  wire                           l2db6_master_unique_i,
  input  wire                           l2db6_master_err_i,
  output wire                           master_l2db6_ready_o,

  input  wire                           l2db7_master_valid_i,
  input  wire                           l2db7_master_snoop_i,
  input  wire [5:0]                     l2db7_master_id_i,
  input  wire [7:0]                     l2db7_master_dbid_i,
  input  wire [6:0]                     l2db7_master_tgtid_i,
  input  wire [3:0]                     l2db7_master_qos_i,
  input  wire [127:0]                   l2db7_master_data_i,
  input  wire [15:0]                    l2db7_master_strb_i,
  input  wire [1:0]                     l2db7_master_chunk_i,
  input  wire                           l2db7_master_last_i,
  input  wire [2:0]                     l2db7_master_opcode_i,
  input  wire [2:0]                     l2db7_master_snpresp_i,
  input  wire [1:0]                     l2db7_master_len_i,
  input  wire [2:0]                     l2db7_master_size_i,
  input  wire [5:0]                     l2db7_master_addr_i,
  input  wire [7:0]                     l2db7_master_attrs_i,
  input  wire                           l2db7_master_prot_i,
  input  wire                           l2db7_master_strex_i,
  input  wire                           l2db7_master_unique_i,
  input  wire                           l2db7_master_err_i,
  output wire                           master_l2db7_ready_o,

  input  wire                           l2db8_master_valid_i,
  input  wire                           l2db8_master_snoop_i,
  input  wire [5:0]                     l2db8_master_id_i,
  input  wire [7:0]                     l2db8_master_dbid_i,
  input  wire [6:0]                     l2db8_master_tgtid_i,
  input  wire [3:0]                     l2db8_master_qos_i,
  input  wire [127:0]                   l2db8_master_data_i,
  input  wire [15:0]                    l2db8_master_strb_i,
  input  wire [1:0]                     l2db8_master_chunk_i,
  input  wire                           l2db8_master_last_i,
  input  wire [2:0]                     l2db8_master_opcode_i,
  input  wire [2:0]                     l2db8_master_snpresp_i,
  input  wire [1:0]                     l2db8_master_len_i,
  input  wire [2:0]                     l2db8_master_size_i,
  input  wire [5:0]                     l2db8_master_addr_i,
  input  wire [7:0]                     l2db8_master_attrs_i,
  input  wire                           l2db8_master_prot_i,
  input  wire                           l2db8_master_strex_i,
  input  wire                           l2db8_master_unique_i,
  input  wire                           l2db8_master_err_i,
  output wire                           master_l2db8_ready_o,

  input  wire                           l2db9_master_valid_i,
  input  wire                           l2db9_master_snoop_i,
  input  wire [5:0]                     l2db9_master_id_i,
  input  wire [7:0]                     l2db9_master_dbid_i,
  input  wire [6:0]                     l2db9_master_tgtid_i,
  input  wire [3:0]                     l2db9_master_qos_i,
  input  wire [127:0]                   l2db9_master_data_i,
  input  wire [15:0]                    l2db9_master_strb_i,
  input  wire [1:0]                     l2db9_master_chunk_i,
  input  wire                           l2db9_master_last_i,
  input  wire [2:0]                     l2db9_master_opcode_i,
  input  wire [2:0]                     l2db9_master_snpresp_i,
  input  wire [1:0]                     l2db9_master_len_i,
  input  wire [2:0]                     l2db9_master_size_i,
  input  wire [5:0]                     l2db9_master_addr_i,
  input  wire [7:0]                     l2db9_master_attrs_i,
  input  wire                           l2db9_master_prot_i,
  input  wire                           l2db9_master_strex_i,
  input  wire                           l2db9_master_unique_i,
  input  wire                           l2db9_master_err_i,
  output wire                           master_l2db9_ready_o,

  input  wire                           l2db10_master_valid_i,
  input  wire                           l2db10_master_snoop_i,
  input  wire [5:0]                     l2db10_master_id_i,
  input  wire [7:0]                     l2db10_master_dbid_i,
  input  wire [6:0]                     l2db10_master_tgtid_i,
  input  wire [3:0]                     l2db10_master_qos_i,
  input  wire [127:0]                   l2db10_master_data_i,
  input  wire [15:0]                    l2db10_master_strb_i,
  input  wire [1:0]                     l2db10_master_chunk_i,
  input  wire                           l2db10_master_last_i,
  input  wire [2:0]                     l2db10_master_opcode_i,
  input  wire [2:0]                     l2db10_master_snpresp_i,
  input  wire [1:0]                     l2db10_master_len_i,
  input  wire [2:0]                     l2db10_master_size_i,
  input  wire [5:0]                     l2db10_master_addr_i,
  input  wire [7:0]                     l2db10_master_attrs_i,
  input  wire                           l2db10_master_prot_i,
  input  wire                           l2db10_master_strex_i,
  input  wire                           l2db10_master_unique_i,
  input  wire                           l2db10_master_err_i,
  output wire                           master_l2db10_ready_o,

  output wire                           master_rsp_dbid_valid_o,
  output wire                           master_rsp_comp_valid_o,
  output wire                           master_rsp_readreceipt_valid_o,
  output wire [6:0]                     master_rsp_txnid_o,
  output wire [7:0]                     master_rsp_dbid_o,
  output wire [6:0]                     master_rsp_srcid_o,
  output wire [3:0]                     master_rsp_resp_o,

  // L2DB status
  input  wire                           l2db10_master_invalidated_i,
  input  wire                           l2db9_master_invalidated_i,
  input  wire                           l2db8_master_invalidated_i,
  input  wire                           l2db7_master_invalidated_i,
  input  wire                           l2db6_master_invalidated_i,
  input  wire                           l2db5_master_invalidated_i,
  input  wire                           l2db4_master_invalidated_i,
  input  wire                           l2db3_master_invalidated_i,
  input  wire                           l2db2_master_invalidated_i,
  input  wire                           l2db1_master_invalidated_i,
  input  wire                           l2db0_master_invalidated_i,

  input  wire                           l2db10_master_dirty_i,
  input  wire                           l2db9_master_dirty_i,
  input  wire                           l2db8_master_dirty_i,
  input  wire                           l2db7_master_dirty_i,
  input  wire                           l2db6_master_dirty_i,
  input  wire                           l2db5_master_dirty_i,
  input  wire                           l2db4_master_dirty_i,
  input  wire                           l2db3_master_dirty_i,
  input  wire                           l2db2_master_dirty_i,
  input  wire                           l2db1_master_dirty_i,
  input  wire                           l2db0_master_dirty_i,

  // Read data responses
  output wire                           master_cpuslv0_dr_valid_o,
  output wire                           master_cpuslv1_dr_valid_o,
  output wire                           master_cpuslv2_dr_valid_o,
  output wire                           master_cpuslv3_dr_valid_o,
  output wire                           master_acpslv_dr_valid_o,
  output wire                           master_snpslv_dr_valid_o,
  input  wire                           cpuslv0_master_dr_ready_i,
  input  wire                           cpuslv1_master_dr_ready_i,
  input  wire                           cpuslv2_master_dr_ready_i,
  input  wire                           cpuslv3_master_dr_ready_i,
  input  wire                           acpslv_master_dr_ready_i,
  output wire [5:0]                     master_cpuslv0_dr_id_o,
  output wire [5:0]                     master_cpuslv1_dr_id_o,
  output wire [5:0]                     master_cpuslv2_dr_id_o,
  output wire [5:0]                     master_cpuslv3_dr_id_o,
  output wire [5:0]                     master_acpslv_dr_id_o,
  output wire [1:0]                     master_dr_chunk_o,
  output wire [127:0]                   master_dr_data_o,
  output wire [3:0]                     master_dr_resp_o,

  output wire                           master_early_dr_valid_o,
  output wire [5:0]                     master_early_dr_id_o,
  output wire [7:0]                     master_early_dr_dbid_o,
  output wire [6:0]                     master_early_dr_srcid_o,
  output wire [3:0]                     master_early_dr_resp_o,
  output wire [127:0]                   master_early_dr_data_o,
  output wire                           master_early_dr_barrier_o,
  output wire                           master_early_dr_same_o,
  output wire [1:0]                     master_early_dr_chunk_o,
  output wire                           master_early_dr_ready_o,
  input  wire [7:0]                     cpuslv0_early_dr_ready_i,
  input  wire                           cpuslv0_early_dr_l2_i,
  input  wire [10:0]                    cpuslv0_early_dr_index_i,
  input  wire [3:0]                     cpuslv0_early_dr_way_i,
  input  wire [7:0]                     cpuslv1_early_dr_ready_i,
  input  wire                           cpuslv1_early_dr_l2_i,
  input  wire [10:0]                    cpuslv1_early_dr_index_i,
  input  wire [3:0]                     cpuslv1_early_dr_way_i,
  input  wire [7:0]                     cpuslv2_early_dr_ready_i,
  input  wire                           cpuslv2_early_dr_l2_i,
  input  wire [10:0]                    cpuslv2_early_dr_index_i,
  input  wire [3:0]                     cpuslv2_early_dr_way_i,
  input  wire [7:0]                     cpuslv3_early_dr_ready_i,
  input  wire                           cpuslv3_early_dr_l2_i,
  input  wire [10:0]                    cpuslv3_early_dr_index_i,
  input  wire [3:0]                     cpuslv3_early_dr_way_i,
  input  wire                           acpslv_early_dr_l2_i,
  input  wire [10:0]                    acpslv_early_dr_index_i,
  input  wire [3:0]                     acpslv_early_dr_way_i,
  input  wire [15:0]                    acpslv_early_dr_ready_i,

  output wire [7:0]                     master_cpuslv0_reqbuf_retry_o,
  output wire [7:0]                     master_cpuslv1_reqbuf_retry_o,
  output wire [7:0]                     master_cpuslv2_reqbuf_retry_o,
  output wire [7:0]                     master_cpuslv3_reqbuf_retry_o,
  output wire [3:0]                     master_acpslv_reqbuf_retry_o,
  output wire                           master_snpslv_reqbuf_retry_o,

  output wire [1:0]                     master_cpuslv0_pcrdtype_o,
  output wire [1:0]                     master_cpuslv1_pcrdtype_o,
  output wire [1:0]                     master_cpuslv2_pcrdtype_o,
  output wire [1:0]                     master_cpuslv3_pcrdtype_o,
  output wire [1:0]                     master_acpslv_pcrdtype_o,
  output wire [1:0]                     master_snpslv_pcrdtype_o,

  // Write responses
  output wire                           master_cpuslv0_strex_db_valid_o,
  output wire                           master_cpuslv1_strex_db_valid_o,
  output wire                           master_cpuslv2_strex_db_valid_o,
  output wire                           master_cpuslv3_strex_db_valid_o,
  output wire                           master_cpuslv0_barrier_db_valid_o,
  output wire                           master_cpuslv1_barrier_db_valid_o,
  output wire                           master_cpuslv2_barrier_db_valid_o,
  output wire                           master_cpuslv3_barrier_db_valid_o,
  output wire                           master_cpuslv0_dev_db_valid_o,
  output wire                           master_cpuslv1_dev_db_valid_o,
  output wire                           master_cpuslv2_dev_db_valid_o,
  output wire                           master_cpuslv3_dev_db_valid_o,
  output wire [1:0]                     master_db_resp_o,
  output wire                           master_db_waddr_valid_o,
  output wire [3:0]                     master_db_waddr_o,

  // Waddr status for barriers
  output wire                           master_cpuslv0_waddrs_valid_o,
  output wire                           master_cpuslv1_waddrs_valid_o,
  output wire                           master_cpuslv2_waddrs_valid_o,
  output wire                           master_cpuslv3_waddrs_valid_o,

  input  wire                           cpuslv0_sample_waddrs_i,
  input  wire                           cpuslv1_sample_waddrs_i,
  input  wire                           cpuslv2_sample_waddrs_i,
  input  wire                           cpuslv3_sample_waddrs_i,
  input  wire                           cpuslv0_sample_waddrs_dsb_i,
  input  wire                           cpuslv1_sample_waddrs_dsb_i,
  input  wire                           cpuslv2_sample_waddrs_dsb_i,
  input  wire                           cpuslv3_sample_waddrs_dsb_i,
  input  wire                           snpslv_sample_waddrs_i,
  output wire                           master_snpslv_waddrs_valid_o,
  output wire                           master_snpslv_db_valid_o,

  // L2 RAM allocation
  output wire                           master_ramctl_active_o,
  output wire                           master_ramctl_valid_o,
  output wire [3:0]                     master_ramctl_chunks_o,
  output wire [255:0]                   master_ramctl_data_o,
  output wire [3:0]                     master_ramctl_way_o,
  output wire [10:0]                    master_ramctl_index_o,
  input  wire                           ramctl_master_ready_i,
  input  wire                           ramctl_master_accepted_i,

  output wire [7:0]                     master_cpuslv0_l2_waiting_o,
  output wire [7:0]                     master_cpuslv1_l2_waiting_o,
  output wire [7:0]                     master_cpuslv2_l2_waiting_o,
  output wire [7:0]                     master_cpuslv3_l2_waiting_o,
  output wire [3:0]                     master_acpslv_l2_waiting_o,

  input  wire [7:0]                     cpuslv0_delay_allocation_i,
  input  wire [7:0]                     cpuslv1_delay_allocation_i,
  input  wire [7:0]                     cpuslv2_delay_allocation_i,
  input  wire [7:0]                     cpuslv3_delay_allocation_i,
  input  wire [3:0]                     acpslv_delay_allocation_i,

  input  wire                           victimctl_ack_i,
  input  wire [5:0]                     victimctl_ack_id_i,
  input  wire [3:0]                     victimctl_victim_way_i,

  // Snpslv interaction
  input  wire                           snpslv_txrsp_req_i,
  input  wire                           snpslv_rxsnp_active_i,
  input  wire                           snpslv_active_i,
  input  wire                           cpuslv0_compack_valid_i,
  input  wire                           cpuslv1_compack_valid_i,
  input  wire                           cpuslv2_compack_valid_i,
  input  wire                           cpuslv3_compack_valid_i,
  input  wire                           acpslv_compack_valid_i,
  output wire                           master_rxla_run_o,
  output wire                           master_rxla_deactivate_o,
  output wire                           master_rxla_stop_o,
  output wire                           master_txla_run_o,
  output wire                           master_txla_deactivate_o,
  input  wire                           cpuslv0_master_sactive_i,
  input  wire                           cpuslv1_master_sactive_i,
  input  wire                           cpuslv2_master_sactive_i,
  input  wire                           cpuslv3_master_sactive_i,
  input  wire                           acpslv_master_sactive_i,

  // Hazarding
  input  wire [41:6]                    tagctl_addr_tc1_i,
  input  wire                           tagctl_addr_valid_tc1_i,
  input  wire [40:6]                    tagctl_addr_tc3_i,
  input  wire                           tagctl_addr_valid_tc3_i,
  input  wire [5:0]                     tagctl_reqbufid_tc1_i,
  output wire                           master_hz_tc2_o,
  output wire                           master_hz_tc4_o,
  output wire [3:0]                     master_hz_waddr_tc4_o,
  output wire                           master_hz_dev_tc2_o,
  output wire                           master_hz_l2db_tc2_o,
  output wire                           master_hz_dirty_tc2_o,
  output wire                           master_hz_cu_tc2_o,
  output wire [3:0]                     master_l2db_tc2_o,
  output wire                           master_ncoh_db_o,
  output wire [15:0]                    master_waddr_valid_o,

  input  wire                           acpslv_ext_err_i,

  // MBIST
  input  wire                           gov_mbistreq_i,
  input  wire [`CA53_MBIST0_DATA_W-1:0] gov_mbistindata0_i
);


  //-----------------------------------------------------------------------------
  //  Declarations
  //-----------------------------------------------------------------------------

  localparam NUM_RBUFS = 5;
  localparam DATA_ARB_MAX = NUM_L2DBS - 1;

  // Address channel
  reg [2:0]                        addr_arb_rr;
  reg [2:0]                        addr_arb_old_rr;
  reg [2:0]                        addr_arb_write_rr;
  reg                              addr_arb_dvm1;
  reg                              addr_arb_dvm2;
  reg [5:0]                        addr_arbitrated;
  reg [5:0]                        addr_read_arbitrated;
  reg [5:0]                        addr_write;
  reg                              addr_write_force;
  reg                              addr_write_forced;

  wire                             addr_arb_req;
  wire                             addr_arb_early_req;
  wire                             addr_arb_ack;
  wire                             next_addr_arb_ack;
  wire [5:0]                       addr_arb_flush;
  wire [3:0]                       addr_arb_waddr_id;
  wire [5:0]                       master_afb_ack;
  wire [5:0]                       request_mask;
  wire [2:0]                       next_addr_arb_rr;
  wire [2:0]                       addr_arb_rr_updated;
  wire                             addr_arb_rr_en;
  wire [5:0]                       next_addr_arbitrated;
  wire [5:0]                       next_addr_read_arbitrated;
  wire                             addr_read_arbitrated_en;
  wire [5:0]                       next_addr_write;
  wire                             addr_arbitrated_en;
  wire                             addr_read_arb_ack;
  wire                             next_addr_arb_dvm1;
  wire                             addr_arb_dvm_part_two;
  wire                             addr_arb_write_rr_en;
  wire [2:0]                       next_addr_arb_write_rr;
  wire                             next_addr_write_force;
  wire [5:0]                       addr_req;
  wire [5:0]                       addr_req_updated;
  wire [5:0]                       addr_arb;
  wire [6:0]                       addr_arb_id;
  wire [5:0]                       addr_arb_write_addr;
  wire [40:0]                      addr_arb_read_addr;
  wire [40:0]                      addr_arb_addr;
  wire [4:0]                       addr_arb_opcode;
  wire [3:0]                       addr_arb_l2db;
  wire                             addr_arb_static_pcredit;
  wire [1:0]                       addr_arb_pcrdtype;
  wire [1:0]                       addr_arb_read_len;
  wire [1:0]                       addr_arb_write_len;
  wire [1:0]                       addr_arb_len;
  wire [2:0]                       addr_arb_read_size;
  wire [2:0]                       addr_arb_write_size;
  wire [2:0]                       addr_arb_size;
  wire                             addr_arb_lock;
  wire [7:0]                       addr_arb_attrs;
  wire [1:0]                       addr_arb_prot;
  wire [6:0]                       addr_arb_tgtid;
  wire [MAX_L2DBS-1:0]             afb_master_l2db [5:0];
  wire [1:0]                       afb_write_len   [5:0];
  wire [5:0]                       afb_write_addr  [5:0];
  wire [2:0]                       afb_write_size  [5:0];


  // Read data channel
  reg [NUM_RBUFS-1:0]              rbuf_dr_valid;
  reg [NUM_RBUFS-1:0]              rbuf_l2_valid;
  reg [127:0]                      rbuf_data     [NUM_RBUFS-1:0];
  reg [5:0]                        rbuf_id       [NUM_RBUFS-1:0];
  reg [1:0]                        rbuf_chunk    [NUM_RBUFS-1:0];
  reg [3:0]                        rbuf_resp     [NUM_RBUFS-1:0];
  reg [10:0]                       rbuf_l2_index [NUM_RBUFS-1:0];
  reg [3:0]                        rbuf_l2_way   [NUM_RBUFS-1:0];
  reg                              read_resp_dr_sent;
  reg [NUM_RBUFS-1:0]              rbuf_l2_arb;
  reg [NUM_RBUFS-1:0]              rbuf_halfline_match;
  reg [5:0]                        rbuf_oldest_id;
  reg                              rbuf_ramctl_data_accepted;

  wire [NUM_RBUFS-1:0]             rbuf_valid;
  wire [NUM_RBUFS*NUM_RBUFS-1:0]   rbuf_older_pkd;
  wire [NUM_RBUFS-1:0]             oldest_dr_rbuf;
  wire [NUM_RBUFS-1:0]             next_oldest_dr_rbuf;
  wire [NUM_RBUFS-1:0]             next_oldest_l2_rbuf;
  wire [NUM_RBUFS-1:0]             first_empty_rbuf;
  wire [NUM_RBUFS-1:0]             rbuf_en;
  wire [NUM_RBUFS-1:0]             rbuf_way_en;
  wire [3:0]                       next_rbuf_l2_way [NUM_RBUFS-1:0];
  wire                             set_rbuf_dr_valid;
  wire                             set_rbuf_l2_valid;
  wire [NUM_RBUFS-1:0]             clear_rbuf_dr_valid;
  wire [NUM_RBUFS-1:0]             clear_rbuf_l2_valid;
  wire [NUM_RBUFS-1:0]             next_rbuf_dr_valid;
  wire [NUM_RBUFS-1:0]             next_rbuf_l2_valid;
  wire                             rbuf_valid_en;
  wire [NUM_RBUFS-1:0]             rbuf_lower_empty;
  wire                             rbuf_dr_any_valid;
  wire                             rbuf_oldest_id_en;
  wire [5:0]                       next_rbuf_oldest_id;
  wire [5:0]                       master_dr_slvs_valid;
  wire [5:0]                       master_dr_slvs_ready;
  wire                             master_early_dr_slv_ready;
  wire                             acp_early_dr_ready;
  wire [3:0]                       acpslv_early_dr_chunk;
  wire                             slv_accepting_dr;
  wire                             read_resp_valid;
  wire [3:0]                       read_resp;
  wire [127:0]                     read_resp_data;
  wire [5:0]                       read_resp_id;
  wire [5:0]                       read_resp_cpuslv0_id;
  wire [5:0]                       read_resp_cpuslv1_id;
  wire [5:0]                       read_resp_cpuslv2_id;
  wire [5:0]                       read_resp_cpuslv3_id;
  wire [5:0]                       read_resp_acpslv_id;
  wire [7:0]                       read_resp_dbid;
  wire [6:0]                       read_resp_srcid;
  wire [1:0]                       read_resp_chunk;
  wire                             read_resp_l2_alloc;
  wire [10:0]                      read_resp_l2_index;
  wire [3:0]                       read_resp_l2_way;
  wire                             read_resp_ready;
  wire                             read_resp_next_ready;
  wire [127:0]                     next_rbuf_data;
  wire                             read_early_resp_valid;
  wire [5:0]                       read_early_resp_id;
  wire                             read_early_resp_barrier;
  wire                             next_read_resp_dr_sent;
  wire [5:0]                       l2_delay_id [NUM_RBUFS-1:0];
  wire [NUM_RBUFS-1:0]             rbuf_l2_delay;
  wire [NUM_RBUFS-1:0]             next_rbuf_l2_arb;
  wire [NUM_RBUFS-1:0]             next_rbuf_halfline_match;
  wire                             rbuf_l2_arb_en;
  wire                             master_ramctl_valid;
  wire                             next_rbuf_ramctl_data_accepted;
  wire [3:0]                       credit_return;
  wire [127:0]                     rbuf_dr_data;
  wire [1:0]                       rbuf_dr_chunk;
  wire [3:0]                       rbuf_dr_resp;
  wire [5:0]                       rbuf_next_id;
  wire [127:0]                     rbuf_ramctl_data_lo;
  wire [127:0]                     rbuf_ramctl_data_hi;
  wire [3:0]                       rbuf_ramctl_way;
  wire [10:0]                      rbuf_ramctl_index;
  wire [1:0]                       rbuf_ramctl_chunk;
  wire [1:0]                       rbuf_next_ramctl_chunk;
  wire [5:0]                       rbuf_next_ramctl_id;
  wire [7:0]                       rbuf_slv_reqbuf_id [NUM_RBUFS-1:0];
  wire [3:0]                       rbuf_acpslv_reqbuf_id [NUM_RBUFS-1:0];
  wire [NUM_RBUFS-1:0]             rbuf_slv_l2_valid [4:0];
  wire [5:0]                       rbuf_ramctl_id;
  wire [NUM_RBUFS-1:0]             rbuf_ramctl_same_halfline;
  wire [NUM_RBUFS-1:0]             rbuf_l2_data_arb_lo;
  wire [NUM_RBUFS-1:0]             rbuf_l2_data_arb_hi;
  wire [7:0]                       rbuf_cpuslv0_l2_waiting;
  wire [7:0]                       rbuf_cpuslv1_l2_waiting;
  wire [7:0]                       rbuf_cpuslv2_l2_waiting;
  wire [7:0]                       rbuf_cpuslv3_l2_waiting;
  wire [3:0]                       rbuf_acpslv_l2_waiting;


  // Write data channel
  reg [`CA53_LOG2(NUM_L2DBS)-1:0]  data_arb_rr;
  reg [NUM_L2DBS-1:0]              data_arbitrated;
  reg                              data_arb_first;
  reg [NUM_L2DBS-1:0]              data_write_arb;
  reg [NUM_L2DBS-1:0]              data_snoop_arb;
  reg                              data_arb_snoop_rr;

  wire [NUM_L2DBS-1:0]             data_req;
  wire                             data_arb_req;
  wire                             data_arb_snoop;
  wire [5:0]                       data_arb_id;
  wire [7:0]                       data_arb_dbid;
  wire [6:0]                       data_arb_tgtid;
  wire [3:0]                       data_arb_qos;
  wire [127:0]                     data_arb_raw_data;
  wire [127:0]                     data_arb_data;
  wire [15:0]                      data_arb_strb;
  wire [1:0]                       data_arb_chunk;
  wire                             data_arb_last;
  wire                             data_arb_err;
  wire                             data_arb_dw_ready;
  wire                             data_arb_cd_ready;
  wire [2:0]                       data_arb_opcode;
  wire [2:0]                       data_arb_snpresp;
  wire [1:0]                       data_arb_len;
  wire [2:0]                       data_arb_size;
  wire [5:0]                       data_arb_addr;
  wire [7:0]                       data_arb_attrs;
  wire                             data_arb_prot;
  wire                             data_arb_strex;
  wire                             data_arb_unique;
  wire [`CA53_LOG2(NUM_L2DBS)-1:0] next_data_arb_rr;
  wire [NUM_L2DBS-1:0]             next_data_arbitrated;
  wire [MAX_L2DBS-1:0]             l2db_master_valid;
  wire [MAX_L2DBS-1:0]             l2db_master_snoop;
  wire [MAX_L2DBS-1:0]             l2db_master_last;
  wire [MAX_L2DBS-1:0]             master_l2db_ready;
  wire [MAX_L2DBS-1:0]             data_arb;
  wire [MAX_L2DBS-1:0]             data_id_arb;
  wire                             data_arb_sel_snoop;
  wire                             data_arb_sel_write;
  wire                             data_arb_sel_write_first;
  wire [NUM_L2DBS-1:0]             data_write_req;
  wire [NUM_L2DBS-1:0]             data_snoop_req;
  wire [NUM_L2DBS-1:0]             next_data_write_arb;
  wire [NUM_L2DBS-1:0]             next_data_snoop_arb;
  wire                             data_write_arb_en;
  wire                             data_snoop_arb_en;
  wire                             data_sel_write;
  wire                             data_allow_write;
  wire                             data_allow_snoop;
  wire                             data_arb_rr_en;
  wire                             data_arbitrated_en;
  wire                             next_data_arb_snoop_rr;
  wire                             next_data_arb_first;


  // Misc
  reg                              clk_enable_int;
  reg                              master_mbistreq;
  reg                              nexterrirq;
  reg                              addr_arb_evnt_refill;
  reg                              addr_arb_evnt_wb;
  reg [2:0]                        addr_arb_evnt_cpu;
  reg [NUM_CPUS-1:0]               evnt_bus_acc_rd;
  reg [NUM_CPUS-1:0]               evnt_bus_acc_wr;
  reg [NUM_CPUS-1:0]               evnt_l2_refill;
  reg [NUM_CPUS-1:0]               evnt_l2_wb;

  wire                             clk_master;
  wire                             clk_enable;
  wire                             clk_enable_ext;
  wire                             next_clk_enable_int;
  wire                             master_active;
  wire                             err_response;
  wire                             interface_active;
  wire                             next_nexterrirq;
  wire                             zero;
  wire                             next_addr_arb_evnt_refill;
  wire                             next_addr_arb_evnt_wb;
  wire [NUM_CPUS-1:0]              next_evnt_bus_acc_rd;
  wire [NUM_CPUS-1:0]              next_evnt_bus_acc_wr;
  wire [NUM_CPUS-1:0]              next_evnt_l2_refill;
  wire [NUM_CPUS-1:0]              next_evnt_l2_wb;
  wire [3:0]                       scu_evnt_bus_acc_rd;
  wire [3:0]                       scu_evnt_bus_acc_wr;
  wire [3:0]                       scu_evnt_l2_refill;
  wire [3:0]                       scu_evnt_l2_wb;

  genvar i;
  genvar j;

  // Tie-off for configurable logic.
  assign zero = 1'b0;

  //----------------------------------------------------------------------------
  // Regional clock gate
  //----------------------------------------------------------------------------

  assign master_active = |rbuf_valid | interface_active;

  assign master_active_o = master_active;

  // CPUslvs do not need to tell us when an L2DB may send data, because that can
  // only happen after the address is placed in the waddr which will keep the
  // master active.
  assign next_clk_enable_int = (|l2db_master_valid | master_active |
                                tagctl_master_active_i | snpslv_master_active_i |
                                gov_mbistreq_i);

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    clk_enable_int <= 1'b1;
  end else begin
    clk_enable_int <= next_clk_enable_int;
  end

  // Because the external signals may be running off a slower synchronous clock,
  // we must register them separately from the internal signals that need to be
  // registered every cycle.
  assign clk_enable = clk_enable_int | clk_enable_ext;

  ca53_cell_inter_clkgate u_inter_clkgate (
    .clk_i         (clk),
    .clk_enable_i  (clk_enable),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_master));

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    master_mbistreq <= 1'b0;
  end else begin
    master_mbistreq <= gov_mbistreq_i;
  end

  //-----------------------------------------------------------------------------
  //  Address channel arbitration
  //-----------------------------------------------------------------------------


  // A new AFB request can be arbitrated every cycle, however each AFB can only
  // make a request every other cycle. This only limits throughput on 2 part DVM
  // messages, as for every other type of request the AFB will not be ready to
  // send anything new for several cycles.
  assign addr_req = {afb5_master_req_i,
                     afb4_master_req_i,
                     afb3_master_req_i,
                     afb2_master_req_i,
                     afb1_master_req_i,
                     afb0_master_req_i} & ~request_mask;


  generate if (ACE) begin : g_ace_rr

    // Select between AFB requests on a round robin basis.
    assign addr_arb_rr_en = addr_arb_ack & ~addr_arb_dvm1 & ~addr_write_forced;

    assign next_addr_arb_rr = (addr_arb_rr == 3'b101) ? 3'b000 : (addr_arb_rr + 3'b001);

    always @(posedge clk_master or negedge reset_n)
    if (~reset_n) begin
      addr_arb_rr <= 3'b000;
    end else if (addr_arb_rr_en) begin
      addr_arb_rr <= next_addr_arb_rr;
    end

    always @(posedge clk_master or negedge reset_n)
    if (~reset_n) begin
      addr_arb_old_rr <= 3'b000;
    end else if (addr_arb_rr_en) begin
      addr_arb_old_rr <= addr_arb_rr;
    end

    // Because we must allow writes to progress when a read is blocked, detect
    // when a read is arbitrated but not accepted, and there is a write waiting
    // behind it. In the following bus cycle, force the arbitration to only
    // select writes if the read was also not accepted on this cycle.
    assign next_addr_write_force = |(addr_arbitrated & addr_read_arbitrated) & ~addr_arb_ack & |addr_write;

    always @(posedge clk_master or negedge reset_n)
    if (~reset_n) begin
      addr_write_force <= 1'b0;
    end else if (clean_aclken_i) begin
      addr_write_force <= next_addr_write_force;
    end

    always @(posedge clk_master or negedge reset_n)
    if (~reset_n) begin
      addr_write_forced <= 1'b0;
    end else if (addr_arbitrated_en) begin
      addr_write_forced <= addr_write_force;
    end

    // Use a separate round robin counter when forcing a write to be arbitrated,
    // to ensure that forced writes do not unfairly affect other reads.
    assign next_addr_arb_write_rr = (addr_arb_rr == 3'b101) ? 3'b000 : (addr_arb_rr + 3'b001);

    assign addr_arb_write_rr_en = addr_arb_ack & addr_write_forced;

    always @(posedge clk_master or negedge reset_n)
    if (~reset_n) begin
      addr_arb_write_rr <= 3'b000;
    end else if (addr_arb_write_rr_en) begin
      addr_arb_write_rr <= next_addr_arb_write_rr;
    end

    // Because the round robin counter is not incremented until the ack, it is a
    // cycle behind if there is an ack and so we must compensate.
    assign addr_arb_rr_updated = addr_arb_ack ? addr_arb_rr : (addr_write_force ? addr_arb_write_rr : addr_arb_old_rr);


    assign addr_req_updated = (addr_write_force & ~addr_arb_ack) ? addr_write : addr_req;

    ca53_rr_arb #(.WIDTH(6)) u_addr_arb (
      .clk          (clk_master),
      .reset_n      (reset_n),
      .rr_counter_i (addr_arb_rr_updated),
      .requests_i   (addr_req_updated),
      .arb_o        (addr_arb)
    );

  end else begin : g_skyros_rr

    assign addr_arb_rr_en = next_addr_arb_ack;

    // Select between AFB requests on a round robin basis.
    ca53_rr_reg_arb #(.WIDTH(6)) u_addr_arb (
      .clk          (clk_master),
      .reset_n      (reset_n),
      .enable_i     (addr_arb_rr_en),
      .requests_i   (addr_req),
      .arb_o        (addr_arb)
    );

    assign next_addr_arb_rr = 3'b000;
    assign addr_arb_rr_updated = 3'b000;
    assign addr_arb_write_rr_en = 1'b0;

    always @*
    begin
      addr_arb_old_rr = {3{zero}};
      addr_arb_rr = {3{zero}};
    end

  end endgenerate

  assign addr_arb_flush = {afb5_master_flush_i,
                           afb4_master_flush_i,
                           afb3_master_flush_i,
                           afb2_master_flush_i,
                           afb1_master_flush_i,
                           afb0_master_flush_i};

  assign addr_arb_req = |(addr_arb & ~addr_arb_flush);

  assign addr_arb_early_req = |addr_req;

  assign addr_arb_id = (({7{addr_arb[5]}} & afb5_master_id_i) |
                        ({7{addr_arb[4]}} & afb4_master_id_i) |
                        ({7{addr_arb[3]}} & afb3_master_id_i) |
                        ({7{addr_arb[2]}} & afb2_master_id_i) |
                        ({7{addr_arb[1]}} & afb1_master_id_i) |
                        ({7{addr_arb[0]}} & afb0_master_id_i));

  assign addr_arb_read_addr = (({41{addr_arb[5]}} & afb5_master_addr_i) |
                               ({41{addr_arb[4]}} & afb4_master_addr_i) |
                               ({41{addr_arb[3]}} & afb3_master_addr_i) |
                               ({41{addr_arb[2]}} & afb2_master_addr_i) |
                               ({41{addr_arb[1]}} & afb1_master_addr_i) |
                               ({41{addr_arb[0]}} & afb0_master_addr_i));

  assign afb_master_l2db[0] = 11'h001 << afb0_master_l2db_i;
  assign afb_master_l2db[1] = 11'h001 << afb1_master_l2db_i;
  assign afb_master_l2db[2] = 11'h001 << afb2_master_l2db_i;
  assign afb_master_l2db[3] = 11'h001 << afb3_master_l2db_i;
  assign afb_master_l2db[4] = 11'h001 << afb4_master_l2db_i;
  assign afb_master_l2db[5] = 11'h001 << afb5_master_l2db_i;

  // Writes must calculate the lower address bits based in the actual bytes being sent.
  generate for (i = 0; i < 6; i = i + 1) begin : g_afb_write_addr
    assign afb_write_addr[i] = (({6{afb_master_l2db[i][10]}} & l2db10_master_addr_i) |
                                ({6{afb_master_l2db[i][9]}}  & l2db9_master_addr_i) |
                                ({6{afb_master_l2db[i][8]}}  & l2db8_master_addr_i) |
                                ({6{afb_master_l2db[i][7]}}  & l2db7_master_addr_i) |
                                ({6{afb_master_l2db[i][6]}}  & l2db6_master_addr_i) |
                                ({6{afb_master_l2db[i][5]}}  & l2db5_master_addr_i) |
                                ({6{afb_master_l2db[i][4]}}  & l2db4_master_addr_i) |
                                ({6{afb_master_l2db[i][3]}}  & l2db3_master_addr_i) |
                                ({6{afb_master_l2db[i][2]}}  & l2db2_master_addr_i) |
                                ({6{afb_master_l2db[i][1]}}  & l2db1_master_addr_i) |
                                ({6{afb_master_l2db[i][0]}}  & l2db0_master_addr_i));
  end endgenerate

  assign addr_arb_write_addr = (({6{addr_arb[5]}} & afb_write_addr[5]) |
                                ({6{addr_arb[4]}} & afb_write_addr[4]) |
                                ({6{addr_arb[3]}} & afb_write_addr[3]) |
                                ({6{addr_arb[2]}} & afb_write_addr[2]) |
                                ({6{addr_arb[1]}} & afb_write_addr[1]) |
                                ({6{addr_arb[0]}} & afb_write_addr[0]));

  assign addr_arb_addr = {addr_arb_read_addr[40:6],
                          ((ACE != 0) | `CA53_REQ_OPCODE_IS_READ(addr_arb_opcode)) ? addr_arb_read_addr[5:0] :
                                                                                     addr_arb_write_addr};

  assign addr_arb_opcode = (({5{addr_arb[5]}} & afb5_master_opcode_i) |
                            ({5{addr_arb[4]}} & afb4_master_opcode_i) |
                            ({5{addr_arb[3]}} & afb3_master_opcode_i) |
                            ({5{addr_arb[2]}} & afb2_master_opcode_i) |
                            ({5{addr_arb[1]}} & afb1_master_opcode_i) |
                            ({5{addr_arb[0]}} & afb0_master_opcode_i));

  assign addr_arb_l2db = (({4{addr_arb[5]}} & afb5_master_l2db_i) |
                          ({4{addr_arb[4]}} & afb4_master_l2db_i) |
                          ({4{addr_arb[3]}} & afb3_master_l2db_i) |
                          ({4{addr_arb[2]}} & afb2_master_l2db_i) |
                          ({4{addr_arb[1]}} & afb1_master_l2db_i) |
                          ({4{addr_arb[0]}} & afb0_master_l2db_i));

  assign addr_arb_static_pcredit = ((addr_arb[5] & afb5_master_static_pcredit_i) |
                                    (addr_arb[4] & afb4_master_static_pcredit_i) |
                                    (addr_arb[3] & afb3_master_static_pcredit_i) |
                                    (addr_arb[2] & afb2_master_static_pcredit_i) |
                                    (addr_arb[1] & afb1_master_static_pcredit_i) |
                                    (addr_arb[0] & afb0_master_static_pcredit_i));

  assign addr_arb_pcrdtype = (({2{addr_arb[5]}} & afb5_master_pcrdtype_i) |
                              ({2{addr_arb[4]}} & afb4_master_pcrdtype_i) |
                              ({2{addr_arb[3]}} & afb3_master_pcrdtype_i) |
                              ({2{addr_arb[2]}} & afb2_master_pcrdtype_i) |
                              ({2{addr_arb[1]}} & afb1_master_pcrdtype_i) |
                              ({2{addr_arb[0]}} & afb0_master_pcrdtype_i));

  assign addr_arb_read_len = (({2{addr_arb[5]}} & afb5_master_len_i) |
                              ({2{addr_arb[4]}} & afb4_master_len_i) |
                              ({2{addr_arb[3]}} & afb3_master_len_i) |
                              ({2{addr_arb[2]}} & afb2_master_len_i) |
                              ({2{addr_arb[1]}} & afb1_master_len_i) |
                              ({2{addr_arb[0]}} & afb0_master_len_i));

  generate for (i = 0; i < 6; i = i + 1) begin : g_afb_write_len
    assign afb_write_len[i] = (({2{afb_master_l2db[i][10]}} & l2db10_master_len_i) |
                               ({2{afb_master_l2db[i][9]}}  & l2db9_master_len_i) |
                               ({2{afb_master_l2db[i][8]}}  & l2db8_master_len_i) |
                               ({2{afb_master_l2db[i][7]}}  & l2db7_master_len_i) |
                               ({2{afb_master_l2db[i][6]}}  & l2db6_master_len_i) |
                               ({2{afb_master_l2db[i][5]}}  & l2db5_master_len_i) |
                               ({2{afb_master_l2db[i][4]}}  & l2db4_master_len_i) |
                               ({2{afb_master_l2db[i][3]}}  & l2db3_master_len_i) |
                               ({2{afb_master_l2db[i][2]}}  & l2db2_master_len_i) |
                               ({2{afb_master_l2db[i][1]}}  & l2db1_master_len_i) |
                               ({2{afb_master_l2db[i][0]}}  & l2db0_master_len_i));
  end endgenerate

  assign addr_arb_write_len = (({2{addr_arb[5]}} & afb_write_len[5]) |
                               ({2{addr_arb[4]}} & afb_write_len[4]) |
                               ({2{addr_arb[3]}} & afb_write_len[3]) |
                               ({2{addr_arb[2]}} & afb_write_len[2]) |
                               ({2{addr_arb[1]}} & afb_write_len[1]) |
                               ({2{addr_arb[0]}} & afb_write_len[0]));

  assign addr_arb_len = ((ACE != 0) | `CA53_REQ_OPCODE_IS_READ(addr_arb_opcode)) ? addr_arb_read_len : addr_arb_write_len;

  assign addr_arb_read_size = (({3{addr_arb[5]}} & afb5_master_size_i) |
                               ({3{addr_arb[4]}} & afb4_master_size_i) |
                               ({3{addr_arb[3]}} & afb3_master_size_i) |
                               ({3{addr_arb[2]}} & afb2_master_size_i) |
                               ({3{addr_arb[1]}} & afb1_master_size_i) |
                               ({3{addr_arb[0]}} & afb0_master_size_i));

  generate for (i = 0; i < 6; i = i + 1) begin : g_afb_write_size
    assign afb_write_size[i] = (({3{afb_master_l2db[i][10]}} & l2db10_master_size_i) |
                                ({3{afb_master_l2db[i][9]}}  & l2db9_master_size_i) |
                                ({3{afb_master_l2db[i][8]}}  & l2db8_master_size_i) |
                                ({3{afb_master_l2db[i][7]}}  & l2db7_master_size_i) |
                                ({3{afb_master_l2db[i][6]}}  & l2db6_master_size_i) |
                                ({3{afb_master_l2db[i][5]}}  & l2db5_master_size_i) |
                                ({3{afb_master_l2db[i][4]}}  & l2db4_master_size_i) |
                                ({3{afb_master_l2db[i][3]}}  & l2db3_master_size_i) |
                                ({3{afb_master_l2db[i][2]}}  & l2db2_master_size_i) |
                                ({3{afb_master_l2db[i][1]}}  & l2db1_master_size_i) |
                                ({3{afb_master_l2db[i][0]}}  & l2db0_master_size_i));
  end endgenerate

  assign addr_arb_write_size = (({3{addr_arb[5]}} & afb_write_size[5]) |
                                ({3{addr_arb[4]}} & afb_write_size[4]) |
                                ({3{addr_arb[3]}} & afb_write_size[3]) |
                                ({3{addr_arb[2]}} & afb_write_size[2]) |
                                ({3{addr_arb[1]}} & afb_write_size[1]) |
                                ({3{addr_arb[0]}} & afb_write_size[0]));

  assign addr_arb_size = ((ACE != 0) | `CA53_REQ_OPCODE_IS_READ(addr_arb_opcode)) ? addr_arb_read_size : addr_arb_write_size;

  assign addr_arb_lock = ((addr_arb[5] & afb5_master_lock_i) |
                          (addr_arb[4] & afb4_master_lock_i) |
                          (addr_arb[3] & afb3_master_lock_i) |
                          (addr_arb[2] & afb2_master_lock_i) |
                          (addr_arb[1] & afb1_master_lock_i) |
                          (addr_arb[0] & afb0_master_lock_i));

  assign addr_arb_attrs = (({8{addr_arb[5]}} & afb5_master_attrs_i) |
                           ({8{addr_arb[4]}} & afb4_master_attrs_i) |
                           ({8{addr_arb[3]}} & afb3_master_attrs_i) |
                           ({8{addr_arb[2]}} & afb2_master_attrs_i) |
                           ({8{addr_arb[1]}} & afb1_master_attrs_i) |
                           ({8{addr_arb[0]}} & afb0_master_attrs_i));

  assign addr_arb_prot = (({2{addr_arb[5]}} & afb5_master_prot_i) |
                          ({2{addr_arb[4]}} & afb4_master_prot_i) |
                          ({2{addr_arb[3]}} & afb3_master_prot_i) |
                          ({2{addr_arb[2]}} & afb2_master_prot_i) |
                          ({2{addr_arb[1]}} & afb1_master_prot_i) |
                          ({2{addr_arb[0]}} & afb0_master_prot_i));

  assign addr_arb_tgtid = (({7{addr_arb[5]}} & afb5_master_tgtid_i) |
                           ({7{addr_arb[4]}} & afb4_master_tgtid_i) |
                           ({7{addr_arb[3]}} & afb3_master_tgtid_i) |
                           ({7{addr_arb[2]}} & afb2_master_tgtid_i) |
                           ({7{addr_arb[1]}} & afb1_master_tgtid_i) |
                           ({7{addr_arb[0]}} & afb0_master_tgtid_i));

  // Store the AFB that was arbitrated, so that we know which one the ack
  // relates to in the following cycle.
  assign next_addr_arbitrated = addr_arb & ~addr_arb_flush;

  assign addr_arbitrated_en = addr_arb_req | addr_arb_ack;

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    addr_arbitrated <= 6'b000000;
  end else if (addr_arbitrated_en) begin
    addr_arbitrated <= next_addr_arbitrated;
  end

  // Return an ack to the AFB after the request has been accepted into the
  // interface registers.
  assign master_afb_ack = {6{addr_arb_ack}} & addr_arbitrated;

  assign master_afb5_ack_o = master_afb_ack[5];
  assign master_afb4_ack_o = master_afb_ack[4];
  assign master_afb3_ack_o = master_afb_ack[3];
  assign master_afb2_ack_o = master_afb_ack[2];
  assign master_afb1_ack_o = master_afb_ack[1];
  assign master_afb0_ack_o = master_afb_ack[0];

  generate if (ACE) begin : g_ace_mask

    // Once a read has been arbitrated, we must not arbitrate any other reads
    // until it is acked, but we can arbitrate writes. A read is anything that
    // needs to use the read channel, and thus includes barriers.
    // If the first half of a 2 part DVM message has been arbitrated, then no
    // other reads must be aribtrated until after the second part.
    assign addr_read_arbitrated_en = ((addr_arb_req & `CA53_REQ_OPCODE_IS_READ(addr_arb_opcode)) |
                                      (addr_arb_ack & |(addr_arbitrated & addr_read_arbitrated) & ~addr_arb_dvm1));

    assign next_addr_read_arbitrated = addr_arb & ~addr_arb_flush & {6{`CA53_REQ_OPCODE_IS_READ(addr_arb_opcode)}};

    always @(posedge clk_master or negedge reset_n)
    if (~reset_n) begin
      addr_read_arbitrated <= 6'b000000;
    end else if (addr_read_arbitrated_en) begin
      addr_read_arbitrated <= next_addr_read_arbitrated;
    end

    assign next_addr_write = ({afb5_master_req_i & `CA53_REQ_OPCODE_IS_WRITE(afb5_master_opcode_i),
                               afb4_master_req_i & `CA53_REQ_OPCODE_IS_WRITE(afb4_master_opcode_i),
                               afb3_master_req_i & `CA53_REQ_OPCODE_IS_WRITE(afb3_master_opcode_i),
                               afb2_master_req_i & `CA53_REQ_OPCODE_IS_WRITE(afb2_master_opcode_i),
                               afb1_master_req_i & `CA53_REQ_OPCODE_IS_WRITE(afb1_master_opcode_i),
                               afb0_master_req_i & `CA53_REQ_OPCODE_IS_WRITE(afb0_master_opcode_i)} &
                              ~addr_arb_flush &
                              ~({6{addr_arb_ack}} & addr_arbitrated));

    always @(posedge clk_master or negedge reset_n)
    if (~reset_n) begin
      addr_write <= 6'b000000;
    end else if (addr_arbitrated_en) begin
      addr_write <= next_addr_write;
    end

    assign addr_read_arb_ack = addr_arb_ack & |(addr_arbitrated & addr_read_arbitrated);

    assign request_mask = (({6{addr_arb_ack}} & (addr_arbitrated | {6{addr_arb_dvm1}})) |
                           ({6{|addr_read_arbitrated & ~(addr_read_arb_ack & ~addr_arb_dvm1)}} &
                            ~(addr_read_arbitrated | addr_write)));

    // Detect the first half of a 2 part DVM message.
    assign next_addr_arb_dvm1 = ((addr_arb_opcode == `CA53_REQ_OPCODE_DVM) & addr_arb_addr[0] &
                                 ~addr_arb_dvm_part_two);

    always @(posedge clk_master or negedge reset_n)
    if (~reset_n) begin
      addr_arb_dvm1 <= 1'b0;
    end else if (addr_arb_req) begin
      addr_arb_dvm1 <= next_addr_arb_dvm1;
    end

    always @(posedge clk_master or negedge reset_n)
    if (~reset_n) begin
      addr_arb_dvm2 <= 1'b0;
    end else if (addr_read_arb_ack) begin
      addr_arb_dvm2 <= addr_arb_dvm1;
    end

    assign addr_arb_dvm_part_two = addr_read_arb_ack ? addr_arb_dvm1 : addr_arb_dvm2;

  end else begin : g_skyros_mask
    reg  [5:0] req_mask;
    wire [5:0] next_req_mask;

    // Skyros does not require writes to be able to overtakes reads and so the
    // arbitration is always sticky in this case.
    assign next_req_mask = next_addr_arb_ack ? next_addr_arbitrated : ({6{|next_addr_arbitrated}} & ~next_addr_arbitrated);

    always @(posedge clk_master or negedge reset_n)
    if (~reset_n) begin
      req_mask <= {6{1'b0}};
    end else if (addr_arbitrated_en) begin
      req_mask <= next_req_mask;
    end

    assign request_mask = req_mask;

    always @*
      addr_arb_dvm1 = zero;

    assign addr_read_arb_ack = 1'b0;
    assign addr_read_arbitrated_en = 1'b0;

  end endgenerate

  // For writes, we also need to tell the AFB which waddr got allocated, so
  // that it can supply that ID with the write data.
  assign master_afb_waddr_id_o = addr_arb_waddr_id;


  //-----------------------------------------------------------------------------
  //  Write and snoop data channel arbitration
  //-----------------------------------------------------------------------------

  assign l2db_master_valid = {l2db10_master_valid_i,
                              l2db9_master_valid_i,
                              l2db8_master_valid_i,
                              l2db7_master_valid_i,
                              l2db6_master_valid_i,
                              l2db5_master_valid_i,
                              l2db4_master_valid_i,
                              l2db3_master_valid_i,
                              l2db2_master_valid_i,
                              l2db1_master_valid_i,
                              l2db0_master_valid_i};

  assign l2db_master_snoop = {l2db10_master_snoop_i,
                              l2db9_master_snoop_i,
                              l2db8_master_snoop_i,
                              l2db7_master_snoop_i,
                              l2db6_master_snoop_i,
                              l2db5_master_snoop_i,
                              l2db4_master_snoop_i,
                              l2db3_master_snoop_i,
                              l2db2_master_snoop_i,
                              l2db1_master_snoop_i,
                              l2db0_master_snoop_i};

  assign l2db_master_last = {l2db10_master_last_i,
                             l2db9_master_last_i,
                             l2db8_master_last_i,
                             l2db7_master_last_i,
                             l2db6_master_last_i,
                             l2db5_master_last_i,
                             l2db4_master_last_i,
                             l2db3_master_last_i,
                             l2db2_master_last_i,
                             l2db1_master_last_i,
                             l2db0_master_last_i};

  generate if (ACE) begin : g_ace_arb

    // Select the next request of each type, exclusing the one that is
    // currently arbitrated.
    assign data_write_req = l2db_master_valid[NUM_L2DBS-1:0] & ~l2db_master_snoop[NUM_L2DBS-1:0] & ~data_write_arb;
    assign data_snoop_req = l2db_master_valid[NUM_L2DBS-1:0] &  l2db_master_snoop[NUM_L2DBS-1:0] & ~data_snoop_arb;

    ca53_rr_arb #(.WIDTH(NUM_L2DBS)) u_data_write_arb (
      .clk          (clk_master),
      .reset_n      (reset_n),
      .rr_counter_i (data_arb_rr),
      .requests_i   (data_write_req),
      .arb_o        (next_data_write_arb)
    );

    ca53_rr_arb #(.WIDTH(NUM_L2DBS)) u_data_snoop_arb (
      .clk          (clk_master),
      .reset_n      (reset_n),
      .rr_counter_i (data_arb_rr),
      .requests_i   (data_snoop_req),
      .arb_o        (next_data_snoop_arb)
    );

    // Select the next L2DB when either the current one has reached its last
    // beat or there is no currently arbitrated one.
    assign data_write_arb_en = |data_write_arb ? ( data_sel_write & data_arb_dw_ready & data_arb_last) : |data_write_req;
    assign data_snoop_arb_en = |data_snoop_arb ? (~data_sel_write & data_arb_cd_ready & data_arb_last) : |data_snoop_req;

    // Increment the round robin counter whenever a new L2DB is arbitrated.
    assign data_arb_rr_en = ((data_write_arb_en & |data_write_req) |
                             (data_snoop_arb_en & |data_snoop_req));

    always @(posedge clk_master or negedge reset_n)
    if (~reset_n) begin
      data_write_arb <= {NUM_L2DBS{1'b0}};
    end else if (data_write_arb_en) begin
      data_write_arb <= next_data_write_arb;
    end

    always @(posedge clk_master or negedge reset_n)
    if (~reset_n) begin
      data_snoop_arb <= {NUM_L2DBS{1'b0}};
    end else if (data_snoop_arb_en) begin
      data_snoop_arb <= next_data_snoop_arb;
    end

    // Track the first beat of write data.
    assign next_data_arb_first = (data_write_arb_en |
                                  (data_arb_first & ~(data_sel_write & data_arb_dw_ready)));

    always @(posedge clk_master)
    begin
      data_arb_first <= next_data_arb_first;
    end

    // Data beats are only allowed if the data skid buffer is available.
    // Additionally, the first beat of a write is only allowed if the address
    // skid buffer is also available.
    assign data_allow_write = (|data_write_arb & data_arb_sel_write &
                               ~(data_arb_first & ~data_arb_sel_write_first));

    // Snoops are always allowed if the data skid buffer is available.
    assign data_allow_snoop = |data_snoop_arb & data_arb_sel_snoop;

    // Signal that there is a request ready to be sent.
    assign data_arb_req = data_allow_write | data_allow_snoop;

    // If both write and snoop data is allowed then select between them on a
    // round robin basis.
    assign data_sel_write = data_allow_write & ~(data_allow_snoop & data_arb_snoop_rr);

    assign next_data_arb_snoop_rr = (data_allow_write & data_allow_snoop) ^ data_arb_snoop_rr;

    always @(posedge clk_master or negedge reset_n)
    if (~reset_n) begin
      data_arb_snoop_rr <= 1'b0;
    end else begin
      data_arb_snoop_rr <= next_data_arb_snoop_rr;
    end

    assign data_arb[NUM_L2DBS-1:0] = data_sel_write ? data_write_arb : data_snoop_arb;

    // For ACE, only writes have an ID, so use an earlier arbitration result.
    assign data_id_arb[NUM_L2DBS-1:0] = data_write_arb;

    assign data_arbitrated_en = 1'b0;

  end else begin : g_n_ace_arb

    // Once we have arbitrated an L2DB, keep arbitrating the same one until
    // all of its data is sent.
    assign data_req = l2db_master_valid[NUM_L2DBS-1:0] & data_arbitrated;

    // Signal that there is a request ready to be sent.
    assign data_arb_req = |l2db_master_valid;

    // Select between requests on a round robin basis.
    ca53_rr_arb #(.WIDTH(NUM_L2DBS)) u_data_arb (
      .clk          (clk_master),
      .reset_n      (reset_n),
      .rr_counter_i (data_arb_rr),
      .requests_i   (data_req),
      .arb_o        (data_arb[NUM_L2DBS-1:0])
    );

    assign data_id_arb[NUM_L2DBS-1:0] = data_arb[NUM_L2DBS-1:0];

    assign data_arbitrated_en = data_arb_req & (data_arb_cd_ready & data_arb_dw_ready);

    assign data_arb_rr_en = data_arbitrated_en & data_arb_last;

    // Store the L2DB that has been arbitrated, to ensure we then arbitrate the
    // rest of the burst, or all bits set if not in the middle of a burst.
    assign next_data_arbitrated = data_arb_last ? {NUM_L2DBS{1'b1}} : data_arb[NUM_L2DBS-1:0];

    always @(posedge clk_master or negedge reset_n)
    if (~reset_n) begin
      data_arbitrated <= {NUM_L2DBS{1'b1}};
    end else if (data_arbitrated_en) begin
      data_arbitrated <= next_data_arbitrated;
    end

    assign data_write_arb_en = 1'b0;
    assign data_snoop_arb_en = 1'b0;

  end endgenerate

  generate for (i = NUM_L2DBS; i < MAX_L2DBS; i = i + 1) begin : g_data_arb
    // Tie-offs for unused L2DBs
    assign data_arb[i] = 1'b0;
    assign data_id_arb[i] = 1'b0;
  end endgenerate

  // Round robin counter for selecting between L2DBs.
  assign next_data_arb_rr = (data_arb_rr >= DATA_ARB_MAX[`CA53_LOG2(NUM_L2DBS)-1:0]) ? {`CA53_LOG2(NUM_L2DBS){1'b0}} :
                                                                                       (data_arb_rr +
                                                                                        {{(`CA53_LOG2(NUM_L2DBS)-1){1'b0}}, 1'b1});

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    data_arb_rr <= {`CA53_LOG2(NUM_L2DBS){1'b0}};
  end else if (data_arb_rr_en) begin
    data_arb_rr <= next_data_arb_rr;
  end

  // Mux the arbitrated L2DB information.
  assign data_arb_snoop = |(data_arb & l2db_master_snoop);

  assign data_arb_id = (({6{data_id_arb[10]}} & l2db10_master_id_i) |
                        ({6{data_id_arb[9]}}  & l2db9_master_id_i) |
                        ({6{data_id_arb[8]}}  & l2db8_master_id_i) |
                        ({6{data_id_arb[7]}}  & l2db7_master_id_i) |
                        ({6{data_id_arb[6]}}  & l2db6_master_id_i) |
                        ({6{data_id_arb[5]}}  & l2db5_master_id_i) |
                        ({6{data_id_arb[4]}}  & l2db4_master_id_i) |
                        ({6{data_id_arb[3]}}  & l2db3_master_id_i) |
                        ({6{data_id_arb[2]}}  & l2db2_master_id_i) |
                        ({6{data_id_arb[1]}}  & l2db1_master_id_i) |
                        ({6{data_id_arb[0]}}  & l2db0_master_id_i));

  assign data_arb_dbid = (({8{data_id_arb[10]}} & l2db10_master_dbid_i) |
                          ({8{data_id_arb[9]}}  & l2db9_master_dbid_i) |
                          ({8{data_id_arb[8]}}  & l2db8_master_dbid_i) |
                          ({8{data_id_arb[7]}}  & l2db7_master_dbid_i) |
                          ({8{data_id_arb[6]}}  & l2db6_master_dbid_i) |
                          ({8{data_id_arb[5]}}  & l2db5_master_dbid_i) |
                          ({8{data_id_arb[4]}}  & l2db4_master_dbid_i) |
                          ({8{data_id_arb[3]}}  & l2db3_master_dbid_i) |
                          ({8{data_id_arb[2]}}  & l2db2_master_dbid_i) |
                          ({8{data_id_arb[1]}}  & l2db1_master_dbid_i) |
                          ({8{data_id_arb[0]}}  & l2db0_master_dbid_i));

  assign data_arb_tgtid = (({7{data_arb[10]}} & l2db10_master_tgtid_i) |
                           ({7{data_arb[9]}}  & l2db9_master_tgtid_i) |
                           ({7{data_arb[8]}}  & l2db8_master_tgtid_i) |
                           ({7{data_arb[7]}}  & l2db7_master_tgtid_i) |
                           ({7{data_arb[6]}}  & l2db6_master_tgtid_i) |
                           ({7{data_arb[5]}}  & l2db5_master_tgtid_i) |
                           ({7{data_arb[4]}}  & l2db4_master_tgtid_i) |
                           ({7{data_arb[3]}}  & l2db3_master_tgtid_i) |
                           ({7{data_arb[2]}}  & l2db2_master_tgtid_i) |
                           ({7{data_arb[1]}}  & l2db1_master_tgtid_i) |
                           ({7{data_arb[0]}}  & l2db0_master_tgtid_i));

  assign data_arb_qos = (({4{data_arb[10]}} & l2db10_master_qos_i) |
                         ({4{data_arb[9]}}  & l2db9_master_qos_i) |
                         ({4{data_arb[8]}}  & l2db8_master_qos_i) |
                         ({4{data_arb[7]}}  & l2db7_master_qos_i) |
                         ({4{data_arb[6]}}  & l2db6_master_qos_i) |
                         ({4{data_arb[5]}}  & l2db5_master_qos_i) |
                         ({4{data_arb[4]}}  & l2db4_master_qos_i) |
                         ({4{data_arb[3]}}  & l2db3_master_qos_i) |
                         ({4{data_arb[2]}}  & l2db2_master_qos_i) |
                         ({4{data_arb[1]}}  & l2db1_master_qos_i) |
                         ({4{data_arb[0]}}  & l2db0_master_qos_i));

  assign data_arb_strb = (({16{data_arb[10]}} & l2db10_master_strb_i) |
                          ({16{data_arb[9]}}  & l2db9_master_strb_i) |
                          ({16{data_arb[8]}}  & l2db8_master_strb_i) |
                          ({16{data_arb[7]}}  & l2db7_master_strb_i) |
                          ({16{data_arb[6]}}  & l2db6_master_strb_i) |
                          ({16{data_arb[5]}}  & l2db5_master_strb_i) |
                          ({16{data_arb[4]}}  & l2db4_master_strb_i) |
                          ({16{data_arb[3]}}  & l2db3_master_strb_i) |
                          ({16{data_arb[2]}}  & l2db2_master_strb_i) |
                          ({16{data_arb[1]}}  & l2db1_master_strb_i) |
                          ({16{data_arb[0]}}  & l2db0_master_strb_i));

  assign data_arb_raw_data = (({128{data_arb[10]}} & l2db10_master_data_i) |
                              ({128{data_arb[9]}}  & l2db9_master_data_i) |
                              ({128{data_arb[8]}}  & l2db8_master_data_i) |
                              ({128{data_arb[7]}}  & l2db7_master_data_i) |
                              ({128{data_arb[6]}}  & l2db6_master_data_i) |
                              ({128{data_arb[5]}}  & l2db5_master_data_i) |
                              ({128{data_arb[4]}}  & l2db4_master_data_i) |
                              ({128{data_arb[3]}}  & l2db3_master_data_i) |
                              ({128{data_arb[2]}}  & l2db2_master_data_i) |
                              ({128{data_arb[1]}}  & l2db1_master_data_i) |
                              ({128{data_arb[0]}}  & l2db0_master_data_i));

  assign data_arb_data = data_arb_raw_data & {{8{data_arb_strb[15]}},
                                              {8{data_arb_strb[14]}},
                                              {8{data_arb_strb[13]}},
                                              {8{data_arb_strb[12]}},
                                              {8{data_arb_strb[11]}},
                                              {8{data_arb_strb[10]}},
                                              {8{data_arb_strb[9]}},
                                              {8{data_arb_strb[8]}},
                                              {8{data_arb_strb[7]}},
                                              {8{data_arb_strb[6]}},
                                              {8{data_arb_strb[5]}},
                                              {8{data_arb_strb[4]}},
                                              {8{data_arb_strb[3]}},
                                              {8{data_arb_strb[2]}},
                                              {8{data_arb_strb[1]}},
                                              {8{data_arb_strb[0]}}};

  assign data_arb_chunk = (({2{data_arb[10]}} & l2db10_master_chunk_i) |
                           ({2{data_arb[9]}}  & l2db9_master_chunk_i) |
                           ({2{data_arb[8]}}  & l2db8_master_chunk_i) |
                           ({2{data_arb[7]}}  & l2db7_master_chunk_i) |
                           ({2{data_arb[6]}}  & l2db6_master_chunk_i) |
                           ({2{data_arb[5]}}  & l2db5_master_chunk_i) |
                           ({2{data_arb[4]}}  & l2db4_master_chunk_i) |
                           ({2{data_arb[3]}}  & l2db3_master_chunk_i) |
                           ({2{data_arb[2]}}  & l2db2_master_chunk_i) |
                           ({2{data_arb[1]}}  & l2db1_master_chunk_i) |
                           ({2{data_arb[0]}}  & l2db0_master_chunk_i));

  assign data_arb_last = |(data_arb & l2db_master_last);

  assign data_arb_err = ((data_arb[10] & l2db10_master_err_i) |
                         (data_arb[9]  & l2db9_master_err_i) |
                         (data_arb[8]  & l2db8_master_err_i) |
                         (data_arb[7]  & l2db7_master_err_i) |
                         (data_arb[6]  & l2db6_master_err_i) |
                         (data_arb[5]  & l2db5_master_err_i) |
                         (data_arb[4]  & l2db4_master_err_i) |
                         (data_arb[3]  & l2db3_master_err_i) |
                         (data_arb[2]  & l2db2_master_err_i) |
                         (data_arb[1]  & l2db1_master_err_i) |
                         (data_arb[0]  & l2db0_master_err_i));

  assign data_arb_opcode = (({3{data_arb[10]}} & l2db10_master_opcode_i) |
                            ({3{data_arb[9]}}  & l2db9_master_opcode_i) |
                            ({3{data_arb[8]}}  & l2db8_master_opcode_i) |
                            ({3{data_arb[7]}}  & l2db7_master_opcode_i) |
                            ({3{data_arb[6]}}  & l2db6_master_opcode_i) |
                            ({3{data_arb[5]}}  & l2db5_master_opcode_i) |
                            ({3{data_arb[4]}}  & l2db4_master_opcode_i) |
                            ({3{data_arb[3]}}  & l2db3_master_opcode_i) |
                            ({3{data_arb[2]}}  & l2db2_master_opcode_i) |
                            ({3{data_arb[1]}}  & l2db1_master_opcode_i) |
                            ({3{data_arb[0]}}  & l2db0_master_opcode_i));

  assign data_arb_snpresp = (({3{data_arb[10]}} & l2db10_master_snpresp_i) |
                             ({3{data_arb[9]}}  & l2db9_master_snpresp_i) |
                             ({3{data_arb[8]}}  & l2db8_master_snpresp_i) |
                             ({3{data_arb[7]}}  & l2db7_master_snpresp_i) |
                             ({3{data_arb[6]}}  & l2db6_master_snpresp_i) |
                             ({3{data_arb[5]}}  & l2db5_master_snpresp_i) |
                             ({3{data_arb[4]}}  & l2db4_master_snpresp_i) |
                             ({3{data_arb[3]}}  & l2db3_master_snpresp_i) |
                             ({3{data_arb[2]}}  & l2db2_master_snpresp_i) |
                             ({3{data_arb[1]}}  & l2db1_master_snpresp_i) |
                             ({3{data_arb[0]}}  & l2db0_master_snpresp_i));

  assign data_arb_len = (({2{data_arb[10]}} & l2db10_master_len_i) |
                         ({2{data_arb[9]}}  & l2db9_master_len_i) |
                         ({2{data_arb[8]}}  & l2db8_master_len_i) |
                         ({2{data_arb[7]}}  & l2db7_master_len_i) |
                         ({2{data_arb[6]}}  & l2db6_master_len_i) |
                         ({2{data_arb[5]}}  & l2db5_master_len_i) |
                         ({2{data_arb[4]}}  & l2db4_master_len_i) |
                         ({2{data_arb[3]}}  & l2db3_master_len_i) |
                         ({2{data_arb[2]}}  & l2db2_master_len_i) |
                         ({2{data_arb[1]}}  & l2db1_master_len_i) |
                         ({2{data_arb[0]}}  & l2db0_master_len_i));

  assign data_arb_size = (({3{data_arb[10]}} & l2db10_master_size_i) |
                          ({3{data_arb[9]}}  & l2db9_master_size_i) |
                          ({3{data_arb[8]}}  & l2db8_master_size_i) |
                          ({3{data_arb[7]}}  & l2db7_master_size_i) |
                          ({3{data_arb[6]}}  & l2db6_master_size_i) |
                          ({3{data_arb[5]}}  & l2db5_master_size_i) |
                          ({3{data_arb[4]}}  & l2db4_master_size_i) |
                          ({3{data_arb[3]}}  & l2db3_master_size_i) |
                          ({3{data_arb[2]}}  & l2db2_master_size_i) |
                          ({3{data_arb[1]}}  & l2db1_master_size_i) |
                          ({3{data_arb[0]}}  & l2db0_master_size_i));

  assign data_arb_addr = (({6{data_arb[10]}} & l2db10_master_addr_i) |
                          ({6{data_arb[9]}}  & l2db9_master_addr_i) |
                          ({6{data_arb[8]}}  & l2db8_master_addr_i) |
                          ({6{data_arb[7]}}  & l2db7_master_addr_i) |
                          ({6{data_arb[6]}}  & l2db6_master_addr_i) |
                          ({6{data_arb[5]}}  & l2db5_master_addr_i) |
                          ({6{data_arb[4]}}  & l2db4_master_addr_i) |
                          ({6{data_arb[3]}}  & l2db3_master_addr_i) |
                          ({6{data_arb[2]}}  & l2db2_master_addr_i) |
                          ({6{data_arb[1]}}  & l2db1_master_addr_i) |
                          ({6{data_arb[0]}}  & l2db0_master_addr_i));

  assign data_arb_attrs = (({8{data_arb[10]}} & l2db10_master_attrs_i) |
                           ({8{data_arb[9]}}  & l2db9_master_attrs_i) |
                           ({8{data_arb[8]}}  & l2db8_master_attrs_i) |
                           ({8{data_arb[7]}}  & l2db7_master_attrs_i) |
                           ({8{data_arb[6]}}  & l2db6_master_attrs_i) |
                           ({8{data_arb[5]}}  & l2db5_master_attrs_i) |
                           ({8{data_arb[4]}}  & l2db4_master_attrs_i) |
                           ({8{data_arb[3]}}  & l2db3_master_attrs_i) |
                           ({8{data_arb[2]}}  & l2db2_master_attrs_i) |
                           ({8{data_arb[1]}}  & l2db1_master_attrs_i) |
                           ({8{data_arb[0]}}  & l2db0_master_attrs_i));

  assign data_arb_prot = ((data_arb[10] & l2db10_master_prot_i) |
                          (data_arb[9]  & l2db9_master_prot_i) |
                          (data_arb[8]  & l2db8_master_prot_i) |
                          (data_arb[7]  & l2db7_master_prot_i) |
                          (data_arb[6]  & l2db6_master_prot_i) |
                          (data_arb[5]  & l2db5_master_prot_i) |
                          (data_arb[4]  & l2db4_master_prot_i) |
                          (data_arb[3]  & l2db3_master_prot_i) |
                          (data_arb[2]  & l2db2_master_prot_i) |
                          (data_arb[1]  & l2db1_master_prot_i) |
                          (data_arb[0]  & l2db0_master_prot_i));

  assign data_arb_strex = ((data_arb[10] & l2db10_master_strex_i) |
                           (data_arb[9]  & l2db9_master_strex_i) |
                           (data_arb[8]  & l2db8_master_strex_i) |
                           (data_arb[7]  & l2db7_master_strex_i) |
                           (data_arb[6]  & l2db6_master_strex_i) |
                           (data_arb[5]  & l2db5_master_strex_i) |
                           (data_arb[4]  & l2db4_master_strex_i) |
                           (data_arb[3]  & l2db3_master_strex_i) |
                           (data_arb[2]  & l2db2_master_strex_i) |
                           (data_arb[1]  & l2db1_master_strex_i) |
                           (data_arb[0]  & l2db0_master_strex_i));

  assign data_arb_unique = ((data_arb[10] & l2db10_master_unique_i) |
                            (data_arb[9]  & l2db9_master_unique_i) |
                            (data_arb[8]  & l2db8_master_unique_i) |
                            (data_arb[7]  & l2db7_master_unique_i) |
                            (data_arb[6]  & l2db6_master_unique_i) |
                            (data_arb[5]  & l2db5_master_unique_i) |
                            (data_arb[4]  & l2db4_master_unique_i) |
                            (data_arb[3]  & l2db3_master_unique_i) |
                            (data_arb[2]  & l2db2_master_unique_i) |
                            (data_arb[1]  & l2db1_master_unique_i) |
                            (data_arb[0]  & l2db0_master_unique_i));

  generate for (i = 0; i < MAX_L2DBS; i = i + 1) begin : g_data_ready
    assign master_l2db_ready[i] = data_arb[i] & (l2db_master_snoop[i] ? data_arb_cd_ready : data_arb_dw_ready);
  end endgenerate

  assign master_l2db10_ready_o = master_l2db_ready[10];
  assign master_l2db9_ready_o  = master_l2db_ready[9];
  assign master_l2db8_ready_o  = master_l2db_ready[8];
  assign master_l2db7_ready_o  = master_l2db_ready[7];
  assign master_l2db6_ready_o  = master_l2db_ready[6];
  assign master_l2db5_ready_o  = master_l2db_ready[5];
  assign master_l2db4_ready_o  = master_l2db_ready[4];
  assign master_l2db3_ready_o  = master_l2db_ready[3];
  assign master_l2db2_ready_o  = master_l2db_ready[2];
  assign master_l2db1_ready_o  = master_l2db_ready[1];
  assign master_l2db0_ready_o  = master_l2db_ready[0];


  //-----------------------------------------------------------------------------
  //  Read data channel
  //-----------------------------------------------------------------------------

  // Send information about newly arrived data to the slvs. They must use this to
  // start hazarding again, as for ACE, the RACK may get sent before the data
  // leaves the read buffers and reaches the slv. They should also return L2
  // allocation information back to the master.
  // Additionally, the response may be suppressed by the reqbuf based on this
  // early information, even if a different response is being returned from the
  // rbufs.
  assign master_early_dr_valid_o = read_early_resp_valid & ~read_resp_dr_sent;
  assign master_early_dr_id_o    = read_early_resp_id;
  assign master_early_dr_dbid_o  = read_resp_dbid;
  assign master_early_dr_srcid_o = read_resp_srcid;
  assign master_early_dr_resp_o  = read_resp;
  assign master_early_dr_chunk_o = read_resp_chunk;
  assign master_early_dr_data_o  = read_resp_data;

  // If the early response is the same as the later response then tell the slv
  // so that it can ignore one of them.
  assign master_early_dr_same_o = ~rbuf_dr_any_valid;

  assign master_early_dr_barrier_o = read_early_resp_barrier;

  // Select the oldest rbuf entry to forward on, or the next beat from the
  // interface registers if that is the only valid beat.
  `CA53_ONEHOT_MUX(rbuf_dr_data, 128, oldest_dr_rbuf, rbuf_data,  NUM_RBUFS, g_mux_dr_data)
  `CA53_ONEHOT_MUX(rbuf_dr_chunk,  2, oldest_dr_rbuf, rbuf_chunk, NUM_RBUFS, g_mux_dr_chunk)
  `CA53_ONEHOT_MUX(rbuf_dr_resp,   4, oldest_dr_rbuf, rbuf_resp,  NUM_RBUFS, g_mux_dr_resp)

  assign master_dr_data_o = rbuf_dr_data | ({128{~rbuf_dr_any_valid}} & read_resp_data);

  assign master_dr_chunk_o = rbuf_dr_chunk | ({2{~rbuf_dr_any_valid}} & read_resp_chunk);

  assign master_dr_resp_o = rbuf_dr_resp | ({4{~rbuf_dr_any_valid}} & read_resp);

  // The ID is more timing critical, as it is used to decide where to send the
  // data, and then also in the slvs for arbitration, so calculate it the cycle
  // before and register it.
  assign rbuf_oldest_id_en = (slv_accepting_dr |
                              (read_resp_valid & ~read_resp_dr_sent & ~rbuf_dr_any_valid));

  `CA53_ONEHOT_MUX(rbuf_next_id, 6, next_oldest_dr_rbuf, rbuf_id, NUM_RBUFS, g_mux_rbuf_id)

  assign next_rbuf_oldest_id = rbuf_next_id | ({6{~|next_oldest_dr_rbuf}}  & read_resp_id);

  always @(posedge clk_master)
  if (rbuf_oldest_id_en) begin
    rbuf_oldest_id <= next_rbuf_oldest_id;
  end

  assign rbuf_dr_any_valid = |rbuf_dr_valid;

  assign master_cpuslv0_dr_id_o = rbuf_dr_any_valid ? rbuf_oldest_id : read_resp_cpuslv0_id;
  assign master_cpuslv1_dr_id_o = rbuf_dr_any_valid ? rbuf_oldest_id : read_resp_cpuslv1_id;
  assign master_cpuslv2_dr_id_o = rbuf_dr_any_valid ? rbuf_oldest_id : read_resp_cpuslv2_id;
  assign master_cpuslv3_dr_id_o = rbuf_dr_any_valid ? rbuf_oldest_id : read_resp_cpuslv3_id;
  assign master_acpslv_dr_id_o  = rbuf_dr_any_valid ? rbuf_oldest_id : read_resp_acpslv_id;

  // Expand ID to indicate which slv that data is destined for.
  generate for (i = 0; i < 6; i = i + 1) begin : g_slv_valid
    assign master_dr_slvs_valid[i] = rbuf_dr_any_valid ? (rbuf_oldest_id[5:3] == i[2:0]) :
                                                         ((read_resp_valid & ~read_resp_dr_sent) &
                                                          (read_early_resp_id[4:3] == i[1:0]) &
                                                          ((i < 4) ? ((read_early_resp_id[5] == i[2]) | ~|read_early_resp_id[2:1]) :
                                                                     ((read_early_resp_id[5] == i[2]) &  |read_early_resp_id[2:1])));
  end endgenerate

  assign master_snpslv_dr_valid_o  = master_dr_slvs_valid[5];
  assign master_acpslv_dr_valid_o  = master_dr_slvs_valid[4];
  assign master_cpuslv3_dr_valid_o = master_dr_slvs_valid[3];
  assign master_cpuslv2_dr_valid_o = master_dr_slvs_valid[2];
  assign master_cpuslv1_dr_valid_o = master_dr_slvs_valid[1];
  assign master_cpuslv0_dr_valid_o = master_dr_slvs_valid[0];

  // Combine which slvs are ready to accept the data. The snoop slv can always
  // accept a response.
  assign master_dr_slvs_ready = {1'b1,
                                 acpslv_master_dr_ready_i,
                                 cpuslv3_master_dr_ready_i,
                                 cpuslv2_master_dr_ready_i,
                                 cpuslv1_master_dr_ready_i,
                                 cpuslv0_master_dr_ready_i};

  assign acpslv_early_dr_chunk = (({4{read_early_resp_id[1:0] == 2'b00}} & acpslv_early_dr_ready_i[3:0]) |
                                  ({4{read_early_resp_id[1:0] == 2'b01}} & acpslv_early_dr_ready_i[7:4]) |
                                  ({4{read_early_resp_id[1:0] == 2'b10}} & acpslv_early_dr_ready_i[11:8]) |
                                  ({4{read_early_resp_id[1:0] == 2'b11}} & acpslv_early_dr_ready_i[15:12]));

  assign acp_early_dr_ready = (ACE != 0) ? |acpslv_early_dr_chunk :
                                           |(acpslv_early_dr_chunk & (4'b0001 << read_resp_chunk));

  assign master_early_dr_slv_ready = (read_early_resp_barrier |
                                      (read_early_resp_valid & ~read_resp_dr_sent &
                                       (((read_early_resp_id[5:3] == 3'b100) &
                                         acp_early_dr_ready) |
                                        ((read_early_resp_id[5:3] == 3'b011) &
                                         cpuslv3_early_dr_ready_i[read_early_resp_id[2:0]]) |
                                        ((read_early_resp_id[5:3] == 3'b010) &
                                         cpuslv2_early_dr_ready_i[read_early_resp_id[2:0]]) |
                                        ((read_early_resp_id[5:3] == 3'b001) &
                                         cpuslv1_early_dr_ready_i[read_early_resp_id[2:0]]) |
                                        ((read_early_resp_id[5:3] == 3'b000) &
                                         cpuslv0_early_dr_ready_i[read_early_resp_id[2:0]]))));

  // If the relevant slv can accept the data then it will leave the read buffers.
  assign slv_accepting_dr = |(master_dr_slvs_valid & master_dr_slvs_ready);

  // Move the new data into an rbuf if one is free and the slv cannot accept
  // the new data yet.
  assign set_rbuf_dr_valid = ((read_resp_valid & ~read_resp_dr_sent) & read_resp_ready &
                              (rbuf_dr_any_valid | ~slv_accepting_dr) &
                              ~master_early_dr_slv_ready);

  // Release buffers when the beat is forwarded on to the destination.
  assign clear_rbuf_dr_valid = {NUM_RBUFS{slv_accepting_dr}} & oldest_dr_rbuf;

  assign next_rbuf_dr_valid = master_mbistreq ? {{(NUM_RBUFS-1){1'b0}}, 1'b1} :
                                                ((rbuf_dr_valid & ~clear_rbuf_dr_valid) |
                                                 ({NUM_RBUFS{set_rbuf_dr_valid}} & first_empty_rbuf));

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    rbuf_dr_valid <= {NUM_RBUFS{1'b0}};
  end else if (rbuf_valid_en) begin
    rbuf_dr_valid <= next_rbuf_dr_valid;
  end

  //-----------------------------------------------------------------------------
  //  L2 allocation
  //-----------------------------------------------------------------------------

  // Collect the responses about this beat from the reqbufs. A reqbuf will only
  // response if the ID matches, and so there can be at most one response.
  assign read_resp_l2_alloc = (cpuslv0_early_dr_l2_i |
                               cpuslv1_early_dr_l2_i |
                               cpuslv2_early_dr_l2_i |
                               cpuslv3_early_dr_l2_i |
                               acpslv_early_dr_l2_i);

  assign read_resp_l2_index = (cpuslv0_early_dr_index_i |
                               cpuslv1_early_dr_index_i |
                               cpuslv2_early_dr_index_i |
                               cpuslv3_early_dr_index_i |
                               acpslv_early_dr_index_i);

  assign read_resp_l2_way = (cpuslv0_early_dr_way_i |
                             cpuslv1_early_dr_way_i |
                             cpuslv2_early_dr_way_i |
                             cpuslv3_early_dr_way_i |
                             acpslv_early_dr_way_i);


  assign set_rbuf_l2_valid = read_resp_l2_alloc & read_early_resp_valid & read_resp_ready;

  assign clear_rbuf_l2_valid = (rbuf_l2_arb | rbuf_ramctl_same_halfline) & {NUM_RBUFS{ramctl_master_ready_i}};

  assign next_rbuf_l2_valid = master_mbistreq ? {NUM_RBUFS{1'b0}} :
                                                ((rbuf_l2_valid & ~clear_rbuf_l2_valid) |
                                                 ({NUM_RBUFS{set_rbuf_l2_valid}} & first_empty_rbuf));

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    rbuf_l2_valid <= {NUM_RBUFS{1'b0}};
  end else if (rbuf_valid_en) begin
    rbuf_l2_valid <= next_rbuf_l2_valid;
  end

  assign master_ramctl_active_o = |rbuf_l2_valid | set_rbuf_l2_valid;

  // If the slv tells us to delay the allocation because it has not read the
  // victim out of the data RAMs yet then we must register this an prevent a
  // request to the data RAMs in the following cycle.
  generate for (i = 0; i < NUM_RBUFS; i = i + 1) begin : g_l2_delay

    assign l2_delay_id[i] = rbuf_l2_valid[i] ? rbuf_id[i] : read_early_resp_id;

    assign rbuf_l2_delay[i] = (((l2_delay_id[i][5:3] == 3'b000) & cpuslv0_delay_allocation_i[l2_delay_id[i][2:0]]) |
                               ((l2_delay_id[i][5:3] == 3'b001) & cpuslv1_delay_allocation_i[l2_delay_id[i][2:0]]) |
                               ((l2_delay_id[i][5:3] == 3'b010) & cpuslv2_delay_allocation_i[l2_delay_id[i][2:0]]) |
                               ((l2_delay_id[i][5:3] == 3'b011) & cpuslv3_delay_allocation_i[l2_delay_id[i][2:0]]) |
                               ((l2_delay_id[i][5:3] == 3'b100) &  acpslv_delay_allocation_i[l2_delay_id[i][1:0]]));
  end endgenerate

  assign next_rbuf_l2_arb = next_oldest_l2_rbuf & ~rbuf_l2_delay;

  assign rbuf_l2_arb_en = rbuf_valid_en & (ramctl_master_ready_i | ~master_ramctl_valid);

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    rbuf_l2_arb <= {NUM_RBUFS{1'b0}};
  end else if (rbuf_l2_arb_en) begin
    rbuf_l2_arb <= next_rbuf_l2_arb;
  end

  // If ramctl has started accepting the data, but has not finished the access
  // then we must not change the data being sent after this point.
  assign next_rbuf_ramctl_data_accepted = ((rbuf_ramctl_data_accepted |
                                            (ramctl_master_accepted_i & ~|rbuf_ramctl_same_halfline)) &
                                           ~ramctl_master_ready_i);

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    rbuf_ramctl_data_accepted <= 1'b0;
  end else begin
    rbuf_ramctl_data_accepted <= next_rbuf_ramctl_data_accepted;
  end

  assign master_ramctl_valid = |(rbuf_l2_valid & rbuf_l2_arb);
  assign master_ramctl_valid_o = master_ramctl_valid;

  `CA53_ONEHOT_MUX(rbuf_ramctl_way,    4, rbuf_l2_arb, rbuf_l2_way,   NUM_RBUFS, g_mux_ramctl_way)
  `CA53_ONEHOT_MUX(rbuf_ramctl_index, 11, rbuf_l2_arb, rbuf_l2_index, NUM_RBUFS, g_mux_ramctl_index)
  `CA53_ONEHOT_MUX(rbuf_ramctl_chunk,  2, rbuf_l2_arb, rbuf_chunk,    NUM_RBUFS, g_mux_ramctl_chunk)
  `CA53_ONEHOT_MUX(rbuf_ramctl_id,     6, rbuf_l2_arb, rbuf_id,       NUM_RBUFS, g_mux_ramctl_id)

  // If there is a second chunk available from the same halfline as the oldest,
  // then send both together.
  `CA53_ONEHOT_MUX(rbuf_next_ramctl_chunk,  2, next_oldest_l2_rbuf, rbuf_chunk,    NUM_RBUFS, g_mux_ramctl_next_chunk)
  `CA53_ONEHOT_MUX(rbuf_next_ramctl_id,     6, next_oldest_l2_rbuf, rbuf_id,       NUM_RBUFS, g_mux_ramctl_next_id)

  generate for (i = 0; i < NUM_RBUFS; i = i + 1) begin : g_l2_same_line
    assign next_rbuf_halfline_match[i] = (rbuf_l2_arb_en ? (rbuf_l2_valid[i] ? ((rbuf_id[i] == rbuf_next_ramctl_id) &
                                                                                (rbuf_chunk[i][1] == rbuf_next_ramctl_chunk[1])) :
                                                                               ((read_early_resp_id == rbuf_next_ramctl_id) &
                                                                                (read_resp_chunk[1] == rbuf_next_ramctl_chunk[1]))) :
                                                           (rbuf_l2_valid[i] ? ((rbuf_id[i] == rbuf_ramctl_id) &
                                                                                (rbuf_chunk[i][1] == rbuf_ramctl_chunk[1])) :
                                                                               ((read_early_resp_id == rbuf_ramctl_id) &
                                                                                (read_resp_chunk[1] == rbuf_ramctl_chunk[1]))));

    assign rbuf_ramctl_same_halfline[i] = (rbuf_l2_valid[i] & ~rbuf_l2_arb[i] &
                                           ~rbuf_ramctl_data_accepted &
                                           rbuf_halfline_match[i]);

    assign rbuf_l2_data_arb_lo[i] = ~rbuf_chunk[i][0] & (rbuf_l2_arb[i] | rbuf_ramctl_same_halfline[i]);
    assign rbuf_l2_data_arb_hi[i] =  rbuf_chunk[i][0] & (rbuf_l2_arb[i] | rbuf_ramctl_same_halfline[i]);
  end endgenerate

  always @(posedge clk_master)
  begin
    rbuf_halfline_match <= next_rbuf_halfline_match;
  end

  `CA53_ONEHOT_MUX(rbuf_ramctl_data_lo, 128, rbuf_l2_data_arb_lo, rbuf_data, NUM_RBUFS, g_mux_ramctl_data_lo)
  `CA53_ONEHOT_MUX(rbuf_ramctl_data_hi, 128, rbuf_l2_data_arb_hi, rbuf_data, NUM_RBUFS, g_mux_ramctl_data_hi)

  assign master_ramctl_data_o   = {rbuf_ramctl_data_hi, rbuf_ramctl_data_lo};
  assign master_ramctl_way_o    = rbuf_ramctl_way;
  assign master_ramctl_index_o  = rbuf_ramctl_index;
  assign master_ramctl_chunks_o = ((4'b0001 << rbuf_ramctl_chunk) |
                                   ({4{|rbuf_ramctl_same_halfline}} &
                                    (4'b0001 << (rbuf_ramctl_chunk ^ 2'b01))));


  // Tell the slv when we have data for a particular reqbuf that has not been allocated yet.

  generate for (j = 0; j < NUM_RBUFS; j = j + 1) begin : g_l2_id
    assign rbuf_slv_reqbuf_id[j] = (8'h01 << rbuf_id[j][2:0]);
    assign rbuf_acpslv_reqbuf_id[j] = rbuf_slv_reqbuf_id[j][7:4];
  end endgenerate

  generate for (i = 0; i < 5; i = i + 1) begin : g_waiting
    for (j = 0; j < NUM_RBUFS; j = j + 1) begin : g_l2_valid
      assign rbuf_slv_l2_valid[i][j] = rbuf_l2_valid[j] & (rbuf_id[j][5:3] == i[2:0]);
    end
  end endgenerate

  `CA53_ONEHOT_MUX(rbuf_cpuslv0_l2_waiting, 8, rbuf_slv_l2_valid[0], rbuf_slv_reqbuf_id,    NUM_RBUFS, g_mux_cpuslv0_waiting)
  `CA53_ONEHOT_MUX(rbuf_cpuslv1_l2_waiting, 8, rbuf_slv_l2_valid[1], rbuf_slv_reqbuf_id,    NUM_RBUFS, g_mux_cpuslv1_waiting)
  `CA53_ONEHOT_MUX(rbuf_cpuslv2_l2_waiting, 8, rbuf_slv_l2_valid[2], rbuf_slv_reqbuf_id,    NUM_RBUFS, g_mux_cpuslv2_waiting)
  `CA53_ONEHOT_MUX(rbuf_cpuslv3_l2_waiting, 8, rbuf_slv_l2_valid[3], rbuf_slv_reqbuf_id,    NUM_RBUFS, g_mux_cpuslv3_waiting)
  `CA53_ONEHOT_MUX(rbuf_acpslv_l2_waiting,  4, rbuf_slv_l2_valid[4], rbuf_acpslv_reqbuf_id, NUM_RBUFS, g_mux_acpslv_waiting)

  assign master_cpuslv0_l2_waiting_o = (rbuf_cpuslv0_l2_waiting |
                                        ({8{read_resp_valid & read_resp_dr_sent &
                                            (read_early_resp_id[5:3] == 3'b000)}} & (8'h01 << read_early_resp_id[2:0])));

  assign master_cpuslv1_l2_waiting_o = (rbuf_cpuslv1_l2_waiting |
                                        ({8{read_resp_valid & read_resp_dr_sent &
                                            (read_early_resp_id[5:3] == 3'b001)}} & (8'h01 << read_early_resp_id[2:0])));

  assign master_cpuslv2_l2_waiting_o = (rbuf_cpuslv2_l2_waiting |
                                        ({8{read_resp_valid & read_resp_dr_sent &
                                            (read_early_resp_id[5:3] == 3'b010)}} & (8'h01 << read_early_resp_id[2:0])));

  assign master_cpuslv3_l2_waiting_o = (rbuf_cpuslv3_l2_waiting |
                                        ({8{read_resp_valid & read_resp_dr_sent &
                                            (read_early_resp_id[5:3] == 3'b011)}} & (8'h01 << read_early_resp_id[2:0])));

  assign master_acpslv_l2_waiting_o = (rbuf_acpslv_l2_waiting |
                                        ({4{read_resp_valid & read_resp_dr_sent &
                                            (read_early_resp_id[5:3] == 3'b100)}} & (4'h1 << read_early_resp_id[1:0])));

  //-----------------------------------------------------------------------------
  //  rbuf control and storage
  //-----------------------------------------------------------------------------

  // Each buffer can hold data for the dr channel, L2, or both.
  assign rbuf_valid = rbuf_dr_valid | rbuf_l2_valid;

  // Enable all valid bits whenever any of them might change, so they can share
  // a clock gate.
  assign rbuf_valid_en = |rbuf_valid | read_resp_valid | master_mbistreq;

  // Enable a specific read buffer if it is the first empty buffer. We do not
  // factor in if it is being accepted this cycle to help timing.
  assign rbuf_en = master_mbistreq ? {{(NUM_RBUFS-1){1'b0}}, 1'b1} : ({NUM_RBUFS{read_resp_valid}} & first_empty_rbuf);

  assign next_rbuf_data = {read_resp_data[127:`CA53_MBIST0_DATA_W],
                           master_mbistreq ? gov_mbistindata0_i[`CA53_MBIST0_DATA_W-1:0] :
                                             read_resp_data[`CA53_MBIST0_DATA_W-1:0]};

  generate for (i = 0; i < NUM_RBUFS; i = i + 1) begin : g_rbufs

    // Store the beat in the buffer.
    always @(posedge clk_master)
    if (rbuf_en[i]) begin
      rbuf_data[i]     <= next_rbuf_data;
      rbuf_id[i]       <= read_resp_id;
      rbuf_chunk[i]    <= read_resp_chunk;
      rbuf_resp[i]     <= read_resp;
      rbuf_l2_index[i] <= read_resp_l2_index;
    end

    // The way is provided by the request buffer, however if the data arrives
    // before the request buffer has picked the vitim way then it must be
    // updated when the victim RAM provides an answer.
    assign rbuf_way_en[i] = rbuf_en[i] | (rbuf_valid[i] &
                                          victimctl_ack_i &
                                          (victimctl_ack_id_i == rbuf_id[i]));

    assign next_rbuf_l2_way[i] = (victimctl_ack_i &
                                  (rbuf_valid[i] ? (victimctl_ack_id_i == rbuf_id[i]) :
                                                   (victimctl_ack_id_i == read_early_resp_id))) ? victimctl_victim_way_i :
                                                                                                  read_resp_l2_way;

    always @(posedge clk_master)
    if (rbuf_way_en[i]) begin
      rbuf_l2_way[i] <= next_rbuf_l2_way[i];
    end

    // Calculate if this buffer has any lower buffers that are empty (and hence
    // this one is not the lowest empty buffer).
    if (i == 0) begin : g_buf0
      assign rbuf_lower_empty[i] = 1'b0;
    end else begin : g_others
      assign rbuf_lower_empty[i] = ~rbuf_valid[i-1] | rbuf_lower_empty[i-1];
    end

    // Work out the oldest buffer for each type of response.
    assign oldest_dr_rbuf[i] = rbuf_dr_valid[i] & ~|(rbuf_dr_valid & rbuf_older_pkd[NUM_RBUFS*i +: NUM_RBUFS]);

    assign next_oldest_l2_rbuf[i] = ((rbuf_l2_valid[i] & ~rbuf_l2_arb[i] &
                                      ~|(rbuf_l2_valid & ~rbuf_l2_arb &
                                         rbuf_older_pkd[NUM_RBUFS*i +: NUM_RBUFS])) |
                                     (~|rbuf_l2_valid & first_empty_rbuf[i]));

    assign next_oldest_dr_rbuf[i] = (rbuf_dr_valid[i] & ~oldest_dr_rbuf[i] &
                                     ~|(rbuf_dr_valid & ~oldest_dr_rbuf & rbuf_older_pkd[NUM_RBUFS*i +: NUM_RBUFS]));

  end endgenerate

  // Keep track of the order in which rbufs were allocated.
  ca53scu_buf_age #(.NUM_BUFS(NUM_RBUFS)) u_rbuf_age (
    .clk         (clk_master),
    .reset_n     (reset_n),
    .buf_alloc_i (rbuf_en),
    .buf_older_o (rbuf_older_pkd)
  );

  // Identify the first read buffer that is empty, so that this one can be
  // filled with the next beat available.
  assign first_empty_rbuf = ~rbuf_valid & ~rbuf_lower_empty;

  // Indicate when there is at least one buffer empty, or the beat does not
  // require a buffer.
  assign read_resp_ready = (rbuf_lower_empty[NUM_RBUFS-1] | ~rbuf_valid[NUM_RBUFS-1] |
                            ((read_resp_dr_sent | master_early_dr_slv_ready) & ~read_resp_l2_alloc));

  // The ACP slv needs to know if read data is going to move out of the early
  // buffer or not, so that it knows when to start suppressing unneeded beats.
  assign master_early_dr_ready_o = rbuf_lower_empty[NUM_RBUFS-1] | ~rbuf_valid[NUM_RBUFS-1];

  // Indicate when there will be at least one buffer empty next cycle. This
  // must be true if there are at least two buffers empty, at least one buffer
  // empty that is not being filled this cycle, or one becoming empty this cycle.
  assign read_resp_next_ready = (|(rbuf_lower_empty & ~rbuf_valid) |
                                 ((rbuf_lower_empty[NUM_RBUFS-1] | ~rbuf_valid[NUM_RBUFS-1]) &
                                  ~(read_resp_valid & ~(master_early_dr_slv_ready & ~read_resp_l2_alloc))) |
                                  (|(~(next_rbuf_dr_valid | next_rbuf_l2_valid))));

  // If the response has been sent to the slv, but also needs to write into L2
  // and cannot move into an rbuf then record the fact that it has been sent so
  // that we do not try and send it again in the following cycles.
  assign next_read_resp_dr_sent = ((read_resp_dr_sent |
                                    (read_early_resp_valid & master_early_dr_slv_ready) |
                                    (~rbuf_dr_any_valid & slv_accepting_dr)) &
                                   ~read_resp_ready);

  always @(posedge clk_master or negedge reset_n)
  if (~reset_n) begin
    read_resp_dr_sent <= 1'b0;
  end else begin
    read_resp_dr_sent <= next_read_resp_dr_sent;
  end

  // For Skyros, we must return a credit when the buffer has been released.
  // There can be at most four data beats being released in a cycle.
  assign credit_return = {|(clear_rbuf_dr_valid & (~rbuf_l2_valid | clear_rbuf_l2_valid)),
                          |(clear_rbuf_l2_valid & ~rbuf_l2_arb & ~rbuf_dr_valid),
                          |(clear_rbuf_l2_valid &  rbuf_l2_arb & ~rbuf_dr_valid),
                          ((read_early_resp_valid & master_early_dr_slv_ready) |
                           (~rbuf_dr_any_valid & slv_accepting_dr)) & ~read_resp_l2_alloc};

  //-----------------------------------------------------------------------------
  //  Error IRQ generation
  //-----------------------------------------------------------------------------

  // Generate nEXTERRIRQ output for error responses on
  // transactions where the response won't propagate to a CPU
  assign next_nexterrirq = ~(err_response | acpslv_ext_err_i | (~nexterrirq & ~gov_clear_axierr_i));

  // This needs to be clocked from the ungated clock to ensure it can be
  // cleared when there is no other SCU activity.
  always @(posedge CLKIN or negedge reset_n)
  if (~reset_n) begin
    nexterrirq <= 1'b1;
  end else begin
    nexterrirq <= next_nexterrirq;
  end

  assign nexterrirq_o = nexterrirq;
  assign scu_axierr_o = ~nexterrirq;

  generate if (CPU_CACHE_PROTECTION[0] || SCU_CACHE_PROTECTION[0]) begin : g_ecc

    reg  ninterrirq;
    wire next_ninterrirq;
    wire fatal_err;

    // Generate nINTERRIRQ output when we would be sending dirty data externally
    // that contains a fatal error. Because of the error, the byte strobes will
    // not be set and hence the dirty data is lost.
    assign fatal_err = ((data_arb_req &
                         (data_arb_snoop ? data_arb_cd_ready : data_arb_dw_ready) &
                         data_arb_err & data_arb_last &
                         ~((data_arb_opcode == `CA53_DATA_OPCODE_INVALID) |
                           (data_arb_opcode == `CA53_DATA_OPCODE_EVICT) |
                           (data_arb_opcode == `CA53_DATA_OPCODE_EVICTDATA))) |
                        tagctl_err_fatal_i);

    assign next_ninterrirq = ~(fatal_err | (~ninterrirq & ~gov_clear_eccerr_i));

    // This needs to be clocked from the ungated clock to ensure it can be
    // cleared when there is no other SCU activity.
    always @(posedge CLKIN or negedge reset_n)
    if (~reset_n) begin
      ninterrirq <= 1'b1;
    end else begin
      ninterrirq <= next_ninterrirq;
    end

    assign ninterrirq_o = ninterrirq;
    assign scu_eccerr_o = ~ninterrirq;

  end else begin : g_n_ecc

    assign ninterrirq_o = 1'b0;
    assign scu_eccerr_o = 1'b0;

  end endgenerate

  //----------------------------------------------------------------------------
  //  Performance counter events
  //----------------------------------------------------------------------------

  // Pass the registered ACLKEN input to the CPU performance monitors
  // for tracking bus cycles
  assign scu_cpu0_evnt_bus_cycle_o = clean_aclken_i;
  assign scu_cpu1_evnt_bus_cycle_o = clean_aclken_i;
  assign scu_cpu2_evnt_bus_cycle_o = clean_aclken_i;
  assign scu_cpu3_evnt_bus_cycle_o = clean_aclken_i;

  assign next_addr_arb_evnt_wb = ((addr_arb_opcode == `CA53_REQ_OPCODE_WRITEBACK) |
                                  (addr_arb_opcode == `CA53_REQ_OPCODE_WRITECLEAN) |
                                  (addr_arb_opcode == `CA53_REQ_OPCODE_WRITEUNIQUE) |
                                  (addr_arb_opcode == `CA53_REQ_OPCODE_EVICTDATA));

  assign next_addr_arb_evnt_refill = ((addr_arb_opcode == `CA53_REQ_OPCODE_READSHARED) |
                                      (addr_arb_opcode == `CA53_REQ_OPCODE_READUNIQUE) |
                                      (addr_arb_opcode == `CA53_REQ_OPCODE_READONCE));

  generate if (L2_CACHE) begin : g_l2cc

    always @(posedge clk_master)
    if (addr_arbitrated_en) begin
      addr_arb_evnt_cpu    <= addr_arb_id[5:3];
      addr_arb_evnt_refill <= next_addr_arb_evnt_refill;
      addr_arb_evnt_wb     <= next_addr_arb_evnt_wb;
    end

  end else begin : g_n_l2cc

    always @*
    begin
      addr_arb_evnt_cpu    = {3{zero}};
      addr_arb_evnt_refill = zero;
      addr_arb_evnt_wb     = zero;
    end

  end endgenerate

  generate for (i = 0; i < 4; i = i + 1) begin : g_evnt_cpu
    if (i < NUM_CPUS) begin : g_cpu

      assign next_evnt_bus_acc_rd[i] = ((read_resp_valid | read_early_resp_valid) &
                                        ~read_resp_dr_sent &
                                        (read_resp_id[5:3] == {1'b0, i[1:0]}));

      assign next_evnt_bus_acc_wr[i] = ((|(data_arb & ~l2db_master_snoop) & data_arb_dw_ready) &
                                        (data_arb_id[5:3] == {1'b0, i[1:0]}));

      always @(posedge clk_master or negedge reset_n)
      if (~reset_n) begin
        evnt_bus_acc_rd[i] <= 1'b0;
        evnt_bus_acc_wr[i] <= 1'b0;
      end else begin
        evnt_bus_acc_rd[i] <= next_evnt_bus_acc_rd[i];
        evnt_bus_acc_wr[i] <= next_evnt_bus_acc_wr[i];
      end

      assign scu_evnt_bus_acc_rd[i] = evnt_bus_acc_rd[i];
      assign scu_evnt_bus_acc_wr[i] = evnt_bus_acc_wr[i];

      assign next_evnt_l2_refill[i]  = addr_arb_ack & (addr_arb_evnt_cpu == {1'b0, i[1:0]}) & addr_arb_evnt_refill;
      assign next_evnt_l2_wb[i]      = addr_arb_ack & (addr_arb_evnt_cpu == {1'b0, i[1:0]}) & addr_arb_evnt_wb;

      if (L2_CACHE) begin : g_l2cc

        always @(posedge clk_master or negedge reset_n)
        if (~reset_n) begin
          evnt_l2_refill[i] <= 1'b0;
          evnt_l2_wb[i]     <= 1'b0;
        end else begin
          evnt_l2_refill[i] <= next_evnt_l2_refill[i];
          evnt_l2_wb[i]     <= next_evnt_l2_wb[i];
        end

        assign scu_evnt_l2_refill[i] = evnt_l2_refill[i];
        assign scu_evnt_l2_wb[i] = evnt_l2_wb[i];

      end else begin : g_n_l2cc

        assign scu_evnt_l2_refill[i] = 1'b0;
        assign scu_evnt_l2_wb[i] = 1'b0;

      end
    end else begin : g_n_cpu

      assign scu_evnt_bus_acc_rd[i] = 1'b0;
      assign scu_evnt_bus_acc_wr[i] = 1'b0;
      assign scu_evnt_l2_refill[i] = 1'b0;
      assign scu_evnt_l2_wb[i] = 1'b0;

    end

  end endgenerate

  assign scu_cpu0_evnt_bus_acc_rd_o = scu_evnt_bus_acc_rd[0];
  assign scu_cpu1_evnt_bus_acc_rd_o = scu_evnt_bus_acc_rd[1];
  assign scu_cpu2_evnt_bus_acc_rd_o = scu_evnt_bus_acc_rd[2];
  assign scu_cpu3_evnt_bus_acc_rd_o = scu_evnt_bus_acc_rd[3];
  assign scu_cpu0_evnt_bus_acc_wr_o = scu_evnt_bus_acc_wr[0];
  assign scu_cpu1_evnt_bus_acc_wr_o = scu_evnt_bus_acc_wr[1];
  assign scu_cpu2_evnt_bus_acc_wr_o = scu_evnt_bus_acc_wr[2];
  assign scu_cpu3_evnt_bus_acc_wr_o = scu_evnt_bus_acc_wr[3];
  assign scu_cpu0_evnt_l2_refill_o = scu_evnt_l2_refill[0];
  assign scu_cpu1_evnt_l2_refill_o = scu_evnt_l2_refill[1];
  assign scu_cpu2_evnt_l2_refill_o = scu_evnt_l2_refill[2];
  assign scu_cpu3_evnt_l2_refill_o = scu_evnt_l2_refill[3];
  assign scu_cpu0_evnt_l2_wb_o = scu_evnt_l2_wb[0];
  assign scu_cpu1_evnt_l2_wb_o = scu_evnt_l2_wb[1];
  assign scu_cpu2_evnt_l2_wb_o = scu_evnt_l2_wb[2];
  assign scu_cpu3_evnt_l2_wb_o = scu_evnt_l2_wb[3];

  //----------------------------------------------------------------------------
  //  ACE or Skyros specific parts
  //----------------------------------------------------------------------------

  generate if (ACE) begin : g_ace

    ca53scu_master_ace #(`CA53_SCU_INT_PARAM_INST) u_master_ace (
      /*ARMAUTO*/
      // Inputs
      .clk                               (clk),
      .clk_master                        (clk_master),
      .reset_n                           (reset_n),
      .clean_aclken_i                    (clean_aclken_i),
      .config_broadcastinner_i           (config_broadcastinner_i),
      .config_broadcastouter_i           (config_broadcastouter_i),
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
      .addr_arb_req_i                    (addr_arb_req),
      .addr_arb_id_i                     (addr_arb_id[6:0]),
      .addr_arb_addr_i                   (addr_arb_addr[40:0]),
      .addr_arb_opcode_i                 (addr_arb_opcode[4:0]),
      .addr_arb_len_i                    (addr_arb_len[1:0]),
      .addr_arb_size_i                   (addr_arb_size[2:0]),
      .addr_arb_lock_i                   (addr_arb_lock),
      .addr_arb_attrs_i                  (addr_arb_attrs[7:0]),
      .addr_arb_prot_i                   (addr_arb_prot[1:0]),
      .addr_arb_dvm_part_two_i           (addr_arb_dvm_part_two),
      .data_arb_req_i                    (data_arb_req),
      .data_arb_snoop_i                  (data_arb_snoop),
      .data_arb_first_i                  (data_arb_first),
      .data_arb_id_i                     (data_arb_id[5:0]),
      .data_arb_data_i                   (data_arb_data[127:0]),
      .data_arb_strb_i                   (data_arb_strb[15:0]),
      .data_arb_last_i                   (data_arb_last),
      .data_arb_opcode_i                 (data_arb_opcode[2:0]),
      .data_arb_len_i                    (data_arb_len[1:0]),
      .data_arb_size_i                   (data_arb_size[2:0]),
      .data_arb_addr_i                   (data_arb_addr[5:0]),
      .data_arb_attrs_i                  (data_arb_attrs[7:0]),
      .data_arb_prot_i                   (data_arb_prot),
      .data_arb_strex_i                  (data_arb_strex),
      .data_arb_unique_i                 (data_arb_unique),
      .read_resp_ready_i                 (read_resp_ready),
      .read_resp_next_ready_i            (read_resp_next_ready),
      .cpuslv0_sample_waddrs_i           (cpuslv0_sample_waddrs_i),
      .cpuslv1_sample_waddrs_i           (cpuslv1_sample_waddrs_i),
      .cpuslv2_sample_waddrs_i           (cpuslv2_sample_waddrs_i),
      .cpuslv3_sample_waddrs_i           (cpuslv3_sample_waddrs_i),
      .cpuslv0_sample_waddrs_dsb_i       (cpuslv0_sample_waddrs_dsb_i),
      .cpuslv1_sample_waddrs_dsb_i       (cpuslv1_sample_waddrs_dsb_i),
      .cpuslv2_sample_waddrs_dsb_i       (cpuslv2_sample_waddrs_dsb_i),
      .cpuslv3_sample_waddrs_dsb_i       (cpuslv3_sample_waddrs_dsb_i),
      .snpslv_sample_waddrs_i            (snpslv_sample_waddrs_i),
      .tagctl_addr_tc1_i                 (tagctl_addr_tc1_i[40:6]),
      .tagctl_addr_valid_tc1_i           (tagctl_addr_valid_tc1_i),
      .tagctl_addr_tc3_i                 (tagctl_addr_tc3_i[40:6]),
      .tagctl_addr_valid_tc3_i           (tagctl_addr_valid_tc3_i),
      .tagctl_reqbufid_tc1_i             (tagctl_reqbufid_tc1_i[5:0]),
      // Outputs
      .clk_enable_ext_o                  (clk_enable_ext),
      .interface_active_o                (interface_active),
      .master_writes_active_o            (master_writes_active_o),
      .err_response_o                    (err_response),
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
      .addr_arb_ack_o                    (addr_arb_ack),
      .addr_arb_waddr_id_o               (addr_arb_waddr_id[3:0]),
      .data_arb_sel_snoop_o              (data_arb_sel_snoop),
      .data_arb_sel_write_o              (data_arb_sel_write),
      .data_arb_sel_write_first_o        (data_arb_sel_write_first),
      .data_arb_dw_ready_o               (data_arb_dw_ready),
      .data_arb_cd_ready_o               (data_arb_cd_ready),
      .read_resp_valid_o                 (read_resp_valid),
      .read_resp_o                       (read_resp[3:0]),
      .read_resp_data_o                  (read_resp_data[127:0]),
      .read_resp_id_o                    (read_resp_id[5:0]),
      .read_resp_cpuslv0_id_o            (read_resp_cpuslv0_id[5:0]),
      .read_resp_cpuslv1_id_o            (read_resp_cpuslv1_id[5:0]),
      .read_resp_cpuslv2_id_o            (read_resp_cpuslv2_id[5:0]),
      .read_resp_cpuslv3_id_o            (read_resp_cpuslv3_id[5:0]),
      .read_resp_acpslv_id_o             (read_resp_acpslv_id[5:0]),
      .read_resp_chunk_o                 (read_resp_chunk[1:0]),
      .read_early_resp_valid_o           (read_early_resp_valid),
      .read_early_resp_id_o              (read_early_resp_id[5:0]),
      .read_early_resp_barrier_o         (read_early_resp_barrier),
      .master_cpuslv0_strex_db_valid_o   (master_cpuslv0_strex_db_valid_o),
      .master_cpuslv1_strex_db_valid_o   (master_cpuslv1_strex_db_valid_o),
      .master_cpuslv2_strex_db_valid_o   (master_cpuslv2_strex_db_valid_o),
      .master_cpuslv3_strex_db_valid_o   (master_cpuslv3_strex_db_valid_o),
      .master_cpuslv0_barrier_db_valid_o (master_cpuslv0_barrier_db_valid_o),
      .master_cpuslv1_barrier_db_valid_o (master_cpuslv1_barrier_db_valid_o),
      .master_cpuslv2_barrier_db_valid_o (master_cpuslv2_barrier_db_valid_o),
      .master_cpuslv3_barrier_db_valid_o (master_cpuslv3_barrier_db_valid_o),
      .master_cpuslv0_dev_db_valid_o     (master_cpuslv0_dev_db_valid_o),
      .master_cpuslv1_dev_db_valid_o     (master_cpuslv1_dev_db_valid_o),
      .master_cpuslv2_dev_db_valid_o     (master_cpuslv2_dev_db_valid_o),
      .master_cpuslv3_dev_db_valid_o     (master_cpuslv3_dev_db_valid_o),
      .master_db_resp_o                  (master_db_resp_o[1:0]),
      .master_db_waddr_valid_o           (master_db_waddr_valid_o),
      .master_db_waddr_o                 (master_db_waddr_o[3:0]),
      .master_cpuslv0_waddrs_valid_o     (master_cpuslv0_waddrs_valid_o),
      .master_cpuslv1_waddrs_valid_o     (master_cpuslv1_waddrs_valid_o),
      .master_cpuslv2_waddrs_valid_o     (master_cpuslv2_waddrs_valid_o),
      .master_cpuslv3_waddrs_valid_o     (master_cpuslv3_waddrs_valid_o),
      .master_snpslv_waddrs_valid_o      (master_snpslv_waddrs_valid_o),
      .master_snpslv_db_valid_o          (master_snpslv_db_valid_o),
      .master_hz_tc2_o                   (master_hz_tc2_o),
      .master_hz_tc4_o                   (master_hz_tc4_o),
      .master_hz_waddr_tc4_o             (master_hz_waddr_tc4_o[3:0]),
      .master_hz_dev_tc2_o               (master_hz_dev_tc2_o),
      .master_ncoh_db_o                  (master_ncoh_db_o),
      .master_waddr_valid_o              (master_waddr_valid_o[15:0])
    );  // u_master_ace

    assign scu_txsactive_o = 1'b0;
    assign scu_rxlinkactiveack_o = 1'b0;
    assign scu_txlinkactivereq_o = 1'b0;
    assign scu_txreqflitpend_o = 1'b0;
    assign scu_txreqflitv_o = 1'b0;
    assign scu_txreqflit_o = {100{1'b0}};
    assign scu_txdatflitpend_o = 1'b0;
    assign scu_txdatflitv_o = 1'b0;
    assign scu_txdatflit_o = {194{1'b0}};
    assign scu_rxrsplcrdv_o = 1'b0;
    assign scu_rxdatlcrdv_o = 1'b0;
    assign scu_reqmemattr_o = {8{1'b0}};
    assign read_resp_dbid = {8{1'b0}};
    assign read_resp_srcid = {7{1'b0}};
    assign master_rsp_dbid_valid_o = 1'b0;
    assign master_rsp_comp_valid_o = 1'b0;
    assign master_rsp_readreceipt_valid_o = 1'b0;
    assign master_rsp_txnid_o = {7{1'b0}};
    assign master_rsp_dbid_o = {8{1'b0}};
    assign master_rsp_srcid_o = {7{1'b0}};
    assign master_rsp_resp_o = {4{1'b0}};
    assign master_cpuslv0_reqbuf_retry_o = {8{1'b0}};
    assign master_cpuslv1_reqbuf_retry_o = {8{1'b0}};
    assign master_cpuslv2_reqbuf_retry_o = {8{1'b0}};
    assign master_cpuslv3_reqbuf_retry_o = {8{1'b0}};
    assign master_acpslv_reqbuf_retry_o = {4{1'b0}};
    assign master_snpslv_reqbuf_retry_o = 1'b0;
    assign master_cpuslv0_pcrdtype_o = {2{1'b0}};
    assign master_cpuslv1_pcrdtype_o = {2{1'b0}};
    assign master_cpuslv2_pcrdtype_o = {2{1'b0}};
    assign master_cpuslv3_pcrdtype_o = {2{1'b0}};
    assign master_acpslv_pcrdtype_o  = {2{1'b0}};
    assign master_snpslv_pcrdtype_o  = {2{1'b0}};
    assign master_rxla_run_o = 1'b0;
    assign master_rxla_deactivate_o = 1'b0;
    assign master_rxla_stop_o = 1'b0;
    assign master_txla_run_o = 1'b0;
    assign master_txla_deactivate_o = 1'b0;
    assign master_linkactive_o = 1'b0;
    assign master_hz_l2db_tc2_o = 1'b0;
    assign master_hz_dirty_tc2_o = 1'b0;
    assign master_hz_cu_tc2_o = 1'b0;
    assign master_l2db_tc2_o = {4{1'b0}};

  end else begin : g_skyros

    ca53scu_master_skyros #(`CA53_SCU_INT_PARAM_INST, .NUM_RBUFS(NUM_RBUFS)) u_master_skyros (
      /*ARMAUTO*/
      // Inputs
      .clk                            (clk),
      .clk_master                     (clk_master),
      .clk_ext_master                 (clk_ext_master),
      .reset_n                        (reset_n),
      .clean_aclken_i                 (clean_aclken_i),
      .config_broadcastinner_i        (config_broadcastinner_i),
      .config_broadcastouter_i        (config_broadcastouter_i),
      .tagctl_master_active_i         (tagctl_master_active_i),
      .snpslv_master_active_i         (snpslv_master_active_i),
      .standbywfil2_req_i             (standbywfil2_req_i),
      .config_nodeid_i                (config_nodeid_i[6:0]),
      .ext_rxlinkactivereq_i          (ext_rxlinkactivereq_i),
      .ext_txlinkactiveack_i          (ext_txlinkactiveack_i),
      .ext_txreqlcrdv_i               (ext_txreqlcrdv_i),
      .ext_txdatlcrdv_i               (ext_txdatlcrdv_i),
      .ext_rxrspflitpend_i            (ext_rxrspflitpend_i),
      .ext_rxrspflitv_i               (ext_rxrspflitv_i),
      .ext_rxrspflit_i                (ext_rxrspflit_i[44:0]),
      .ext_rxdatflitpend_i            (ext_rxdatflitpend_i),
      .ext_rxdatflitv_i               (ext_rxdatflitv_i),
      .ext_rxdatflit_i                (ext_rxdatflit_i[193:0]),
      .addr_arb_req_i                 (addr_arb_req),
      .addr_arb_early_req_i           (addr_arb_early_req),
      .addr_arb_id_i                  (addr_arb_id[6:0]),
      .addr_arb_addr_i                (addr_arb_addr[40:0]),
      .addr_arb_opcode_i              (addr_arb_opcode[4:0]),
      .addr_arb_len_i                 (addr_arb_len[1:0]),
      .addr_arb_size_i                (addr_arb_size[2:0]),
      .addr_arb_lock_i                (addr_arb_lock),
      .addr_arb_attrs_i               (addr_arb_attrs[7:0]),
      .addr_arb_prot_i                (addr_arb_prot[1:0]),
      .addr_arb_l2db_i                (addr_arb_l2db[3:0]),
      .addr_arb_tgtid_i               (addr_arb_tgtid[6:0]),
      .addr_arb_static_pcredit_i      (addr_arb_static_pcredit),
      .addr_arb_pcrdtype_i            (addr_arb_pcrdtype[1:0]),
      .data_arb_req_i                 (data_arb_req),
      .data_arb_snoop_i               (data_arb_snoop),
      .data_arb_i                     (data_arb[NUM_L2DBS-1:0]),
      .data_arb_dbid_i                (data_arb_dbid[7:0]),
      .data_arb_tgtid_i               (data_arb_tgtid[6:0]),
      .data_arb_qos_i                 (data_arb_qos[3:0]),
      .data_arb_data_i                (data_arb_data[127:0]),
      .data_arb_strb_i                (data_arb_strb[15:0]),
      .data_arb_chunk_i               (data_arb_chunk[1:0]),
      .data_arb_err_i                 (data_arb_err),
      .data_arb_opcode_i              (data_arb_opcode[2:0]),
      .data_arb_snpresp_i             (data_arb_snpresp[2:0]),
      .data_arb_addr_i                (data_arb_addr[5:4]),
      .data_arb_unique_i              (data_arb_unique),
      .l2db10_master_invalidated_i    (l2db10_master_invalidated_i),
      .l2db9_master_invalidated_i     (l2db9_master_invalidated_i),
      .l2db8_master_invalidated_i     (l2db8_master_invalidated_i),
      .l2db7_master_invalidated_i     (l2db7_master_invalidated_i),
      .l2db6_master_invalidated_i     (l2db6_master_invalidated_i),
      .l2db5_master_invalidated_i     (l2db5_master_invalidated_i),
      .l2db4_master_invalidated_i     (l2db4_master_invalidated_i),
      .l2db3_master_invalidated_i     (l2db3_master_invalidated_i),
      .l2db2_master_invalidated_i     (l2db2_master_invalidated_i),
      .l2db1_master_invalidated_i     (l2db1_master_invalidated_i),
      .l2db0_master_invalidated_i     (l2db0_master_invalidated_i),
      .l2db10_master_dirty_i          (l2db10_master_dirty_i),
      .l2db9_master_dirty_i           (l2db9_master_dirty_i),
      .l2db8_master_dirty_i           (l2db8_master_dirty_i),
      .l2db7_master_dirty_i           (l2db7_master_dirty_i),
      .l2db6_master_dirty_i           (l2db6_master_dirty_i),
      .l2db5_master_dirty_i           (l2db5_master_dirty_i),
      .l2db4_master_dirty_i           (l2db4_master_dirty_i),
      .l2db3_master_dirty_i           (l2db3_master_dirty_i),
      .l2db2_master_dirty_i           (l2db2_master_dirty_i),
      .l2db1_master_dirty_i           (l2db1_master_dirty_i),
      .l2db0_master_dirty_i           (l2db0_master_dirty_i),
      .l2db10_master_unique_i         (l2db10_master_unique_i),
      .l2db9_master_unique_i          (l2db9_master_unique_i),
      .l2db8_master_unique_i          (l2db8_master_unique_i),
      .l2db7_master_unique_i          (l2db7_master_unique_i),
      .l2db6_master_unique_i          (l2db6_master_unique_i),
      .l2db5_master_unique_i          (l2db5_master_unique_i),
      .l2db4_master_unique_i          (l2db4_master_unique_i),
      .l2db3_master_unique_i          (l2db3_master_unique_i),
      .l2db2_master_unique_i          (l2db2_master_unique_i),
      .l2db1_master_unique_i          (l2db1_master_unique_i),
      .l2db0_master_unique_i          (l2db0_master_unique_i),
      .read_resp_ready_i              (read_resp_ready),
      .rbuf_valid_i                   (rbuf_valid[4:0]),
      .credit_return_i                (credit_return[3:0]),
      .snpslv_txrsp_req_i             (snpslv_txrsp_req_i),
      .snpslv_rxsnp_active_i          (snpslv_rxsnp_active_i),
      .snpslv_active_i                (snpslv_active_i),
      .cpuslv0_compack_valid_i        (cpuslv0_compack_valid_i),
      .cpuslv1_compack_valid_i        (cpuslv1_compack_valid_i),
      .cpuslv2_compack_valid_i        (cpuslv2_compack_valid_i),
      .cpuslv3_compack_valid_i        (cpuslv3_compack_valid_i),
      .acpslv_compack_valid_i         (acpslv_compack_valid_i),
      .cpuslv0_master_sactive_i       (cpuslv0_master_sactive_i),
      .cpuslv1_master_sactive_i       (cpuslv1_master_sactive_i),
      .cpuslv2_master_sactive_i       (cpuslv2_master_sactive_i),
      .cpuslv3_master_sactive_i       (cpuslv3_master_sactive_i),
      .acpslv_master_sactive_i        (acpslv_master_sactive_i),
      .tagctl_addr_tc1_i              (tagctl_addr_tc1_i[41:6]),
      .tagctl_addr_valid_tc1_i        (tagctl_addr_valid_tc1_i),
      .tagctl_addr_tc3_i              (tagctl_addr_tc3_i[40:6]),
      .tagctl_addr_valid_tc3_i        (tagctl_addr_valid_tc3_i),
      .tagctl_reqbufid_tc1_i          (tagctl_reqbufid_tc1_i[5:0]),
      // Outputs
      .clk_enable_ext_o               (clk_enable_ext),
      .master_linkactive_o            (master_linkactive_o),
      .interface_active_o             (interface_active),
      .err_response_o                 (err_response),
      .scu_txsactive_o                (scu_txsactive_o),
      .scu_rxlinkactiveack_o          (scu_rxlinkactiveack_o),
      .scu_txlinkactivereq_o          (scu_txlinkactivereq_o),
      .scu_txreqflitpend_o            (scu_txreqflitpend_o),
      .scu_txreqflitv_o               (scu_txreqflitv_o),
      .scu_txreqflit_o                (scu_txreqflit_o[99:0]),
      .scu_reqmemattr_o               (scu_reqmemattr_o[7:0]),
      .scu_txdatflitpend_o            (scu_txdatflitpend_o),
      .scu_txdatflitv_o               (scu_txdatflitv_o),
      .scu_txdatflit_o                (scu_txdatflit_o[193:0]),
      .scu_rxrsplcrdv_o               (scu_rxrsplcrdv_o),
      .scu_rxdatlcrdv_o               (scu_rxdatlcrdv_o),
      .addr_arb_ack_o                 (addr_arb_ack),
      .next_addr_arb_ack_o            (next_addr_arb_ack),
      .data_arb_sel_snoop_o           (data_arb_sel_snoop),
      .data_arb_sel_write_o           (data_arb_sel_write),
      .data_arb_sel_write_first_o     (data_arb_sel_write_first),
      .data_arb_dw_ready_o            (data_arb_dw_ready),
      .data_arb_cd_ready_o            (data_arb_cd_ready),
      .read_resp_valid_o              (read_resp_valid),
      .read_resp_o                    (read_resp[3:0]),
      .read_resp_data_o               (read_resp_data[127:0]),
      .read_resp_id_o                 (read_resp_id[5:0]),
      .read_resp_cpuslv0_id_o         (read_resp_cpuslv0_id[5:0]),
      .read_resp_cpuslv1_id_o         (read_resp_cpuslv1_id[5:0]),
      .read_resp_cpuslv2_id_o         (read_resp_cpuslv2_id[5:0]),
      .read_resp_cpuslv3_id_o         (read_resp_cpuslv3_id[5:0]),
      .read_resp_acpslv_id_o          (read_resp_acpslv_id[5:0]),
      .read_resp_dbid_o               (read_resp_dbid[7:0]),
      .read_resp_srcid_o              (read_resp_srcid[6:0]),
      .read_resp_chunk_o              (read_resp_chunk[1:0]),
      .master_cpuslv0_reqbuf_retry_o  (master_cpuslv0_reqbuf_retry_o[7:0]),
      .master_cpuslv1_reqbuf_retry_o  (master_cpuslv1_reqbuf_retry_o[7:0]),
      .master_cpuslv2_reqbuf_retry_o  (master_cpuslv2_reqbuf_retry_o[7:0]),
      .master_cpuslv3_reqbuf_retry_o  (master_cpuslv3_reqbuf_retry_o[7:0]),
      .master_acpslv_reqbuf_retry_o   (master_acpslv_reqbuf_retry_o[3:0]),
      .master_snpslv_reqbuf_retry_o   (master_snpslv_reqbuf_retry_o),
      .master_cpuslv0_pcrdtype_o      (master_cpuslv0_pcrdtype_o[1:0]),
      .master_cpuslv1_pcrdtype_o      (master_cpuslv1_pcrdtype_o[1:0]),
      .master_cpuslv2_pcrdtype_o      (master_cpuslv2_pcrdtype_o[1:0]),
      .master_cpuslv3_pcrdtype_o      (master_cpuslv3_pcrdtype_o[1:0]),
      .master_acpslv_pcrdtype_o       (master_acpslv_pcrdtype_o[1:0]),
      .master_snpslv_pcrdtype_o       (master_snpslv_pcrdtype_o[1:0]),
      .master_rsp_dbid_valid_o        (master_rsp_dbid_valid_o),
      .master_rsp_comp_valid_o        (master_rsp_comp_valid_o),
      .master_rsp_readreceipt_valid_o (master_rsp_readreceipt_valid_o),
      .master_rsp_txnid_o             (master_rsp_txnid_o[6:0]),
      .master_rsp_dbid_o              (master_rsp_dbid_o[7:0]),
      .master_rsp_srcid_o             (master_rsp_srcid_o[6:0]),
      .master_rsp_resp_o              (master_rsp_resp_o[3:0]),
      .master_rxla_run_o              (master_rxla_run_o),
      .master_rxla_deactivate_o       (master_rxla_deactivate_o),
      .master_rxla_stop_o             (master_rxla_stop_o),
      .master_txla_run_o              (master_txla_run_o),
      .master_txla_deactivate_o       (master_txla_deactivate_o),
      .master_hz_tc2_o                (master_hz_tc2_o),
      .master_hz_tc4_o                (master_hz_tc4_o),
      .master_hz_l2db_tc2_o           (master_hz_l2db_tc2_o),
      .master_hz_dirty_tc2_o          (master_hz_dirty_tc2_o),
      .master_hz_cu_tc2_o             (master_hz_cu_tc2_o),
      .master_l2db_tc2_o              (master_l2db_tc2_o[3:0])
    );  // u_master_skyros

    assign scu_ext_ar_valid_o = 1'b0;
    assign scu_ext_ar_addr_o = {44{1'b0}};
    assign scu_ext_ar_len_o = {8{1'b0}};
    assign scu_ext_ar_size_o = {3{1'b0}};
    assign scu_ext_ar_burst_o = {2{1'b0}};
    assign scu_ext_ar_lock_o = 1'b0;
    assign scu_ext_ar_cache_o = {4{1'b0}};
    assign scu_ext_ar_prot_o = {3{1'b0}};
    assign scu_ext_ar_domain_o = {2{1'b0}};
    assign scu_ext_ar_snoop_o = {4{1'b0}};
    assign scu_ext_ar_id_o = {6{1'b0}};
    assign scu_ext_ar_bar_o = {2{1'b0}};
    assign scu_ext_rdmemattr_o = {8{1'b0}};
    assign scu_ext_dr_ready_o = 1'b0;
    assign scu_ext_aw_valid_o = 1'b0;
    assign scu_ext_aw_addr_o = {44{1'b0}};
    assign scu_ext_aw_len_o = {8{1'b0}};
    assign scu_ext_aw_size_o = {3{1'b0}};
    assign scu_ext_aw_burst_o = {2{1'b0}};
    assign scu_ext_aw_lock_o = 1'b0;
    assign scu_ext_aw_cache_o = {4{1'b0}};
    assign scu_ext_aw_prot_o = {3{1'b0}};
    assign scu_ext_aw_id_o = {5{1'b0}};
    assign scu_ext_aw_snoop_o = {3{1'b0}};
    assign scu_ext_aw_domain_o = {2{1'b0}};
    assign scu_ext_aw_bar_o = {2{1'b0}};
    assign scu_ext_aw_unique_o = 1'b0;
    assign scu_ext_wrmemattr_o = {8{1'b0}};
    assign scu_ext_dw_valid_o = 1'b0;
    assign scu_ext_dw_data_o = {128{1'b0}};
    assign scu_ext_dw_strb_o = {16{1'b0}};
    assign scu_ext_dw_id_o = {5{1'b0}};
    assign scu_ext_dw_last_o = 1'b0;
    assign scu_ext_db_ready_o = 1'b0;
    assign scu_ext_rack_o = 1'b0;
    assign scu_ext_wack_o = 1'b0;
    assign scu_ext_cd_valid_o = 1'b0;
    assign scu_ext_cd_data_o = {128{1'b0}};
    assign scu_ext_cd_last_o = 1'b0;
    assign master_writes_active_o = 1'b0;
    assign master_hz_dev_tc2_o = 1'b0;
    assign master_hz_waddr_tc4_o = {4{1'b0}};
    assign master_ncoh_db_o = 1'b0;
    assign addr_arb_waddr_id = 4'b0000;
    assign master_waddr_valid_o = {16{1'b0}};
    assign master_cpuslv0_waddrs_valid_o = 1'b0;
    assign master_cpuslv1_waddrs_valid_o = 1'b0;
    assign master_cpuslv2_waddrs_valid_o = 1'b0;
    assign master_cpuslv3_waddrs_valid_o = 1'b0;
    assign master_cpuslv3_barrier_db_valid_o = 1'b0;
    assign master_cpuslv2_barrier_db_valid_o = 1'b0;
    assign master_cpuslv1_barrier_db_valid_o = 1'b0;
    assign master_cpuslv0_barrier_db_valid_o = 1'b0;
    assign master_cpuslv3_strex_db_valid_o = 1'b0;
    assign master_cpuslv2_strex_db_valid_o = 1'b0;
    assign master_cpuslv1_strex_db_valid_o = 1'b0;
    assign master_cpuslv0_strex_db_valid_o = 1'b0;
    assign master_cpuslv3_dev_db_valid_o = 1'b0;
    assign master_cpuslv2_dev_db_valid_o = 1'b0;
    assign master_cpuslv1_dev_db_valid_o = 1'b0;
    assign master_cpuslv0_dev_db_valid_o = 1'b0;
    assign master_db_resp_o = 2'b00;
    assign master_db_waddr_valid_o = 1'b0;
    assign master_db_waddr_o = 4'b0000;
    assign master_snpslv_db_valid_o = 1'b0;
    assign read_early_resp_valid = read_resp_valid;
    assign read_early_resp_id = read_resp_id;
    assign read_early_resp_barrier = 1'b0;
    assign master_snpslv_waddrs_valid_o = 1'b0;

  end endgenerate

  //----------------------------------------------------------------------------
  //  OVLs
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Master clock must be enabled when a request arrives")
  u_ovl_clk_en (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (|addr_req | data_arb_req),
    .consequent_expr (clk_enable));

  wire ovl_master_dr_valid = |rbuf_dr_valid | (read_resp_valid & ~read_resp_dr_sent);

  wire [5:0] ovl_rbuf_dr_id;

  `CA53_ONEHOT_MUX(ovl_rbuf_dr_id, 6, oldest_dr_rbuf, rbuf_id, NUM_RBUFS, ovl_g_mux_rbuf_id)

  wire [5:0] ovl_master_dr_id = ovl_rbuf_dr_id | ({6{~|rbuf_dr_valid}} & read_resp_id);

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Master dr ID calculation correct")
  u_ovl_master_cpuslv0_dr_id (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (ovl_master_dr_valid & (ovl_master_dr_id[5:3] == 3'b000)),
    .consequent_expr (master_cpuslv0_dr_id_o == ovl_master_dr_id));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Master dr ID calculation correct")
  u_ovl_master_cpuslv1_dr_id (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (ovl_master_dr_valid & (ovl_master_dr_id[5:3] == 3'b001)),
    .consequent_expr (master_cpuslv1_dr_id_o == ovl_master_dr_id));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Master dr ID calculation correct")
  u_ovl_master_cpuslv2_dr_id (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (ovl_master_dr_valid & (ovl_master_dr_id[5:3] == 3'b010)),
    .consequent_expr (master_cpuslv2_dr_id_o == ovl_master_dr_id));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Master dr ID calculation correct")
  u_ovl_master_cpuslv3_dr_id (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (ovl_master_dr_valid & (ovl_master_dr_id[5:3] == 3'b011)),
    .consequent_expr (master_cpuslv3_dr_id_o == ovl_master_dr_id));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Master dr ID calculation correct")
  u_ovl_master_acpslv_dr_id (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (ovl_master_dr_valid & (ovl_master_dr_id[5:3] == 3'b100)),
    .consequent_expr (master_acpslv_dr_id_o == ovl_master_dr_id));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "AFB master reqbuf must remain asserted until arbitrated")
  u_ovl_afb0_master_req (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (addr_arbitrated[0]),
    .consequent_expr (afb0_master_req_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "AFB master reqbuf must remain asserted until arbitrated")
  u_ovl_afb1_master_req (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (addr_arbitrated[1]),
    .consequent_expr (afb1_master_req_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "AFB master reqbuf must remain asserted until arbitrated")
  u_ovl_afb2_master_req (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (addr_arbitrated[2]),
    .consequent_expr (afb2_master_req_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "AFB master reqbuf must remain asserted until arbitrated")
  u_ovl_afb3_master_req (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (addr_arbitrated[3]),
    .consequent_expr (afb3_master_req_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "AFB master reqbuf must remain asserted until arbitrated")
  u_ovl_afb4_master_req (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (addr_arbitrated[4]),
    .consequent_expr (afb4_master_req_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "AFB master reqbuf must remain asserted until arbitrated")
  u_ovl_afb5_master_req (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (addr_arbitrated[5]),
    .consequent_expr (afb5_master_req_i));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "The second half of a 2 part DVM must immediately follow the first")
  u_ovl_afb0_dvm_twopart (.clk         (clk),
                          .reset_n     (reset_n),
                          .start_event (addr_read_arb_ack & master_afb_ack[0] & addr_arb_dvm1),
                          .test_expr   (afb0_master_req_i & (afb0_master_opcode_i == `CA53_REQ_OPCODE_DVM)));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "The second half of a 2 part DVM must immediately follow the first")
  u_ovl_afb1_dvm_twopart (.clk         (clk),
                          .reset_n     (reset_n),
                          .start_event (addr_read_arb_ack & master_afb_ack[1] & addr_arb_dvm1),
                          .test_expr   (afb1_master_req_i & (afb1_master_opcode_i == `CA53_REQ_OPCODE_DVM)));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "The second half of a 2 part DVM must immediately follow the first")
  u_ovl_afb2_dvm_twopart (.clk         (clk),
                          .reset_n     (reset_n),
                          .start_event (addr_read_arb_ack & master_afb_ack[2] & addr_arb_dvm1),
                          .test_expr   (afb2_master_req_i & (afb2_master_opcode_i == `CA53_REQ_OPCODE_DVM)));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "The second half of a 2 part DVM must immediately follow the first")
  u_ovl_afb3_dvm_twopart (.clk         (clk),
                          .reset_n     (reset_n),
                          .start_event (addr_read_arb_ack & master_afb_ack[3] & addr_arb_dvm1),
                          .test_expr   (afb3_master_req_i & (afb3_master_opcode_i == `CA53_REQ_OPCODE_DVM)));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "The second half of a 2 part DVM must immediately follow the first")
  u_ovl_afb4_dvm_twopart (.clk         (clk),
                          .reset_n     (reset_n),
                          .start_event (addr_read_arb_ack & master_afb_ack[4] & addr_arb_dvm1),
                          .test_expr   (afb4_master_req_i & (afb4_master_opcode_i == `CA53_REQ_OPCODE_DVM)));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "The second half of a 2 part DVM must immediately follow the first")
  u_ovl_afb5_dvm_twopart (.clk         (clk),
                          .reset_n     (reset_n),
                          .start_event (addr_read_arb_ack & master_afb_ack[5] & addr_arb_dvm1),
                          .test_expr   (afb5_master_req_i & (afb5_master_opcode_i == `CA53_REQ_OPCODE_DVM)));

  generate for (i = 0; i < NUM_L2DBS; i = i + 1) begin : g_ovl_l2db

    assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "An L2DB must hold its request until accepted")
    u_ovl_l2db_req (.clk         (clk),
                    .reset_n     (reset_n),
                    .start_event (l2db_master_valid[i] & ~master_l2db_ready[i]),
                    .test_expr   (l2db_master_valid[i]));

    assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "An L2DB must send all beats")
    u_ovl_l2db_last (.clk         (clk),
                     .reset_n     (reset_n),
                     .start_event (l2db_master_valid[i] & master_l2db_ready[i] & ~l2db_master_last[i]),
                     .test_expr   (l2db_master_valid[i]));

  end endgenerate

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: rbuf_l2_arb_en")
  u_ovl_x_rbuf_l2_arb_en (.clk       (clk_master),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (rbuf_l2_arb_en));

  assert_never_unknown #(`OVL_FATAL, NUM_RBUFS, `OVL_ASSERT, "Register enable x-check: rbuf_way_en")
  u_ovl_x_rbuf_way_en (.clk       (clk_master),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (rbuf_way_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: addr_arbitrated_en")
  u_ovl_x_addr_arbitrated_en (.clk       (clk_master),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (addr_arbitrated_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: addr_read_arb_ack")
  u_ovl_x_addr_read_arb_ack (.clk       (clk_master),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (addr_read_arb_ack));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: addr_read_arbitrated_en")
  u_ovl_x_addr_read_arbitrated_en (.clk       (clk_master),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (addr_read_arbitrated_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: data_arb_rr_en")
  u_ovl_x_data_arb_rr_en (.clk       (clk_master),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (data_arb_rr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: data_arbitrated_en")
  u_ovl_x_data_arbitrated_en (.clk       (clk_master),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (data_arbitrated_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: data_snoop_arb_en")
  u_ovl_x_data_snoop_arb_en (.clk       (clk_master),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (data_snoop_arb_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: data_write_arb_en")
  u_ovl_x_data_write_arb_en (.clk       (clk_master),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (data_write_arb_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: clean_aclken_i")
  u_ovl_x_clean_aclken_i (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (clean_aclken_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: rbuf_oldest_id_en")
  u_ovl_x_rbuf_oldest_id_en (.clk       (clk_master),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (rbuf_oldest_id_en));


  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "The read buffers must be ready if in the previous cycle they said they would be.")
  u_ovl_next_ready (.clk         (clk),
                      .reset_n     (reset_n),
                      .start_event (read_resp_next_ready),
                      .test_expr   (read_resp_ready));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: addr_arb_ack")
  u_ovl_x_addr_arb_ack (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (addr_arb_ack));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: addr_arb_req")
  u_ovl_x_addr_arb_req (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (addr_arb_req));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: addr_arb_rr_en")
  u_ovl_x_addr_arb_rr_en (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (addr_arb_rr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: addr_arb_write_rr_en")
  u_ovl_x_addr_arb_write_rr_en (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (addr_arb_write_rr_en));

  assert_never_unknown #(`OVL_FATAL, NUM_RBUFS, `OVL_ASSERT, "Register enable x-check: rbuf_en")
  u_ovl_x_rbuf_en (.clk       (clk),
                   .reset_n   (reset_n),
                   .qualifier (1'b1),
                   .test_expr (rbuf_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: rbuf_valid_en")
  u_ovl_x_rbuf_valid_en (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (rbuf_valid_en));


`endif

endmodule // ca53scu_master

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/

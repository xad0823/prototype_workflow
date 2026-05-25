# ----------------------------------------------------------------------------
#    The confidential and proprietary information contained in this file may
#    only be used by a person authorised under and to the extent permitted
#    by a subsisting licensing agreement from Arm Limited or its affiliates.
#
#           (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
#               ALL RIGHTS RESERVED
#
#    This entire notice must be reproduced on all copies of this file
#    and copies of this file may only be made by a person if such person is
#    permitted to do so under the terms of a subsisting license agreement
#    from Arm Limited or its affiliates.
#
#
#
#
#       Release Information : SSE710-r0p0-00eac0
#
# -----------------------------------------------------------------------------
# Purpose : CDC constraints as compat_set_max_delay -ignore_clock_latency for SSE-710
# -----------------------------------------------------------------------------
#
# Max delay constraints are defined for
# different-clock paths to minimize CDC latency.
#
# NOTE: these constraints are intended for implementation/OOB purposes they are
#       currently NOT sign off quality


##############################################
# Determine CPU name based on config variable
##############################################

# HOST_CPU_TYPE : 3
# CPU type : a53
# CPU name : ca53
###############################################


##############################
# Constrain ADB-400 Crossings
##############################

# Constrain the ADB-400 CDCs in the design using the constrain_adb400_axi4_mst_slv
# procedure defined in procs.sdc. Further signoff checks required, but these
# can't be represented in SDC.

constrain_adb400_axi4_mst_slv \
  -master {u_pd_systop/u_pc_eh0_f0_systop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst} \
  -slave {u_pd_extsys0top/u_pc_eh_f0_extsysmem/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv} \
  -shortest_period [expr {min($PERIODS(SYSPLL_ACLK_2), $PERIODS(EXTSYS0ACLK))}]

constrain_adb400_axi4_mst_slv \
  -master {u_pd_systop/u_pc_eh1_f0_systop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst} \
  -slave {u_pd_extsys1top/u_pc_eh_f0_extsysmem/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv} \
  -shortest_period [expr {min($PERIODS(SYSPLL_ACLK_2), $PERIODS(EXTSYS1ACLK))}]

constrain_adb400_axi4_mst_slv \
  -master {u_pd_systop/u_pc_cpu_systop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst} \
  -slave {u_pd_systop/u_pd_clustop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv} \
  -shortest_period [expr {min($PERIODS(SYSPLL_ACLK_2), $PERIODS(CPUPLL_HOSTCPUCLK_1))}]

constrain_adb400_axi4_mst_slv \
  -master {u_pd_dbgtop_f0/u_systop_f0_dbgtop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst} \
  -slave {u_pd_systop/u_pc_debug_f0_systop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv} \
  -shortest_period [expr {min($PERIODS(SYSPLL_DBGCLK_4), $PERIODS(SYSPLL_ACLK_2))}]

constrain_adb400_axi4_mst_slv \
  -master {u_pd_systop/u_pc_secenc_f0_systop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst} \
  -slave {u_pd_secenc_f1_top/u_secenc_f1_sepd/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv} \
  -shortest_period [expr {min($PERIODS(SYSPLL_ACLK_2), $PERIODS(SECENCCLK_SECENCDIVCLK_2))}]

constrain_adb400_axi4_mst_slv \
  -master {u_pd_systop/u_pd_clustop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst} \
  -slave {u_pd_systop/u_pc_cpu_systop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv} \
  -shortest_period [expr {min($PERIODS(SYSPLL_GICCLK_2), $PERIODS(SYSPLL_ACLK_2))}]

constrain_adb400_axi4_mst_slv \
  -master {u_system_control_f0_aontop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst} \
  -slave {u_pd_systop/u_pc_sysctrl_f0_systop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv} \
  -shortest_period [expr {min($PERIODS(REFCLK), $PERIODS(SYSPLL_ACLK_2))}]

constrain_adb400_axi4_mst_slv \
  -master {u_pd_systop/u_pc_debug_f0_systop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst} \
  -slave {u_pd_dbgtop_f0/u_systop_f0_dbgtop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv} \
  -shortest_period [expr {min($PERIODS(SYSPLL_ACLK_2), $PERIODS(SYSPLL_DBGCLK_4))}]

constrain_adb400_axi4s_mst_slv \
  -master {u_pd_dbgtop_f0/u_pc_aontop_f0_dbgtop/u_sse710_adb400_r3_axi4_stream_mst_wrapper/u_adb400_r3_axi4_stream_mst} \
  -slave {u_system_control_f0_aontop/u_a4s_dbgtop_slv} \
  -shortest_period [expr {min($PERIODS(SYSPLL_DBGCLK_4), $PERIODS(REFCLK))}]

constrain_adb400_axi4s_mst_slv \
  -master {u_system_control_f0_aontop/u_sse710_adb400_r3_axi4_stream_mst_wrapper_dbgtop/u_adb400_r3_axi4_stream_mst} \
  -slave {u_pd_dbgtop_f0/u_pc_aontop_f0_dbgtop/u_slv} \
  -shortest_period [expr {min($PERIODS(SYSPLL_DBGCLK_4), $PERIODS(REFCLK))}]

constrain_adb400_axi4s_mst_slv \
  -master {u_pd_systop/u_pc_sysctrl_f0_systop/u_sse710_adb400_r3_axi4_stream_mst_wrapper/u_adb400_r3_axi4_stream_mst} \
  -slave {u_system_control_f0_aontop/u_a4s_systop_slv} \
  -shortest_period [expr {min($PERIODS(SYSPLL_ACLK_2), $PERIODS(REFCLK))}]

constrain_adb400_axi4s_mst_slv \
  -master {u_system_control_f0_aontop/u_sse710_adb400_r3_axi4_stream_mst_wrapper_systop/u_adb400_r3_axi4_stream_mst} \
  -slave {u_pd_systop/u_pc_sysctrl_f0_systop/u_a4s_slv} \
  -shortest_period [expr {min($PERIODS(SYSPLL_ACLK_2), $PERIODS(REFCLK))}]


##############################
# Constrain SDC-600 Crossings
##############################

# Constrain the SDC-600 CDCs in the design using the
# constrain_sdc600_comasyncbridge_indirect_cdc procedure defined in procs.sdc.
# Further signoff checks required, but these can't be represented in SDC.

constrain_sdc600_comasyncbridge_indirect_cdc \
  -half_ext {u_debug_f0_aontop/u_sdc600_comasyncbridge_indirect_half_ext} \
  -half_int {u_pd_systop/u_pc_debug_aon_f0_systop/u_sdc600_comasyncbridge_indirect_half_int} \
  -shortest_period [expr {min($PERIODS(SYSPLL_ACLK_2), $PERIODS(REFCLK))}]


##############################
# Constrain CSS-600 Crossings
##############################

# Constrain the CSS-600 CDCs in the design using the following procedures,
# defined in procs.sdc:
#
#   constrain_css600_apbasyncbridge_cdc
#   constrain_css600_atbasyncbridge_cdc
#   constrain_css600_tpiu_cdc
#   constrain_css600_pulseasyncbridge_cdc
#   constrain_css600_dp_cdc
#
# Further signoff checks required, but these can't be represented in SDC.

constrain_css600_apbasyncbridge_cdc \
  -master {u_pd_dbgtop_f0/u_pc_aontop_f0_dbgtop/u_mst_apb} \
  -slave {u_debug_f0_aontop/u_apb_slv} \
  -shortest_period [expr {min($PERIODS(SYSPLL_DBGCLK_4), $PERIODS(REFCLK))}]

constrain_css600_apbasyncbridge_cdc \
  -master {u_pd_systop/u_pd_clustop/u_host_cpu_debug_mstr} \
  -slave {u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_apbasyncbridgeslv} \
  -shortest_period [expr {min($PERIODS(SYSPLL_DBGCLK_4), $PERIODS(CPUPLL_HOSTCPUCLK_1))}]

constrain_css600_apbasyncbridge_cdc \
  -master {u_debug_f0_aontop/u_apbhostext_mst} \
  -slave {u_pd_systop/u_pc_debug_aon_f0_systop/u_adb_apb4_slv} \
  -shortest_period [expr {min($PERIODS(REFCLK), $PERIODS(SYSPLL_ACLK_2))}]

constrain_css600_apbasyncbridge_cdc \
  -master {u_system_control_f0_aontop/u_bootreg/u_css600_apbasyncbridgemstr} \
  -slave {u_pd_systop/u_pc_sysctrl_f0_systop/u_bootreg_systop/u_css600_apbasyncbridgeslv} \
  -shortest_period [expr {min($PERIODS(REFCLK), $PERIODS(SYSPLL_ACLK_2))}]

constrain_css600_apbasyncbridge_cdc \
  -master {u_secenc_f1_aontop/u_secenc_f1_aon/u_css600_apbasyncbridgemstr_1} \
  -slave {u_pd_secenc_f1_top/u_secenc_f1_sepd/u_css600_apbasyncbridgeslv_1} \
  -shortest_period [expr {min($PERIODS(SECENCCLK_SECENCDIVCLK_2), $PERIODS(S32KCLK))}]

constrain_css600_apbasyncbridge_cdc \
  -master {u_system_control_f0_aontop/u_aonperip_mux/u_adb_apb4_mst} \
  -slave {u_pd_systop/u_pc_sysctrl_f0_systop/u_adb_apb4_slv} \
  -shortest_period [expr {min($PERIODS(REFCLK), $PERIODS(SYSPLL_ACLK_2))}]

constrain_css600_apbasyncbridge_cdc \
  -master {u_pd_dbgtop_f0/u_systop_f0_dbgtop/u_apbhostext_mst} \
  -slave {u_pd_systop/u_pc_debug_f0_systop/u_adb_hostsysdbg_slv} \
  -shortest_period [expr {min($PERIODS(SYSPLL_DBGCLK_4), $PERIODS(SYSPLL_ACLK_2))}]

constrain_css600_apbasyncbridge_cdc \
  -master {u_system_control_f0_aontop/u_uart_subsys/u_mst_apb} \
  -slave {u_pd_systop/u_pc_sysctrl_f0_systop/u_adb_uart_apb4_slv} \
  -shortest_period [expr {min($PERIODS(UARTCLK_HOSTUARTCLK_1), $PERIODS(SYSPLL_ACLK_2))}]

constrain_css600_atbasyncbridge_cdc \
  -master {u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_atbasyncbridgemstr} \
  -slave {u_pd_systop/u_pd_clustop/u_clustop_atb_slv} \
  -shortest_period [expr {min($PERIODS(CPUPLL_HOSTCPUCLK_1), $PERIODS(SYSPLL_DBGCLK_4))}]

constrain_css600_apbasyncbridge_cdc \
  -master {u_eh0_f0_aontop/u_css600_apbasyncbridgemstr} \
  -slave {u_pd_extsys0top/u_pc_eh_f0_extsysextdbg/u_css600_apbasyncbridgeslv} \
  -shortest_period [expr {min($PERIODS(REFCLK), $PERIODS(EXTSYS0DBGCLKS))}]

constrain_css600_apbasyncbridge_cdc \
  -master {u_pd_extsys0top/u_pc_eh_f0_extsysdbg/u_css600_apbasyncbridgemstr} \
  -slave {u_pd_dbgtop_f0/u_pc_eh0_f0_dbgtop/u_css600_apbasyncbridgeslv} \
  -shortest_period [expr {min($PERIODS(SYSPLL_DBGCLK_4), $PERIODS(EXTSYS0DBGCLKM))}]

constrain_css600_atbasyncbridge_cdc \
  -master {u_pd_dbgtop_f0/u_pc_eh0_f0_dbgtop/u_css600_atbasyncbridgemstr} \
  -slave {u_pd_extsys0top/u_pc_eh_f0_extsystrace/u_css600_atbasyncbridgeslv} \
  -shortest_period [expr {min($PERIODS(EXTSYS0ATCLK), $PERIODS(SYSPLL_DBGCLK_4))}]

constrain_css600_apbasyncbridge_cdc \
  -master {u_eh1_f0_aontop/u_css600_apbasyncbridgemstr} \
  -slave {u_pd_extsys1top/u_pc_eh_f0_extsysextdbg/u_css600_apbasyncbridgeslv} \
  -shortest_period [expr {min($PERIODS(REFCLK), $PERIODS(EXTSYS1DBGCLKS))}]

constrain_css600_apbasyncbridge_cdc \
  -master {u_pd_extsys1top/u_pc_eh_f0_extsysdbg/u_css600_apbasyncbridgemstr} \
  -slave {u_pd_dbgtop_f0/u_pc_eh1_f0_dbgtop/u_css600_apbasyncbridgeslv} \
  -shortest_period [expr {min($PERIODS(SYSPLL_DBGCLK_4), $PERIODS(EXTSYS1DBGCLKM))}]

constrain_css600_atbasyncbridge_cdc \
  -master {u_pd_dbgtop_f0/u_pc_eh1_f0_dbgtop/u_css600_atbasyncbridgemstr} \
  -slave {u_pd_extsys1top/u_pc_eh_f0_extsystrace/u_css600_atbasyncbridgeslv} \
  -shortest_period [expr {min($PERIODS(EXTSYS1ATCLK), $PERIODS(SYSPLL_DBGCLK_4))}]


constrain_css600_tpiu_cdc \
  -path {u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_soc_tpiu} \
  -shortest_period [expr {min($PERIODS(SYSPLL_DBGCLK_4), $PERIODS(TRACECLKIN))}]


constrain_css600_pulseasyncbridge_cdc \
  -master {u_pd_secenc_f1_top/u_secenc_f1_sepd/u_css600_pulseasyncbridgemstr_0} \
  -slave {u_pd_dbgtop_f0/u_pc_secenc_f0_dbgtop/u_css600_pulseasyncbridgeslv_0} \
  -shortest_period [expr {min($PERIODS(SYSPLL_DBGCLK_4), $PERIODS(SECENCCLK_SECENCDIVCLK_2))}]

constrain_css600_pulseasyncbridge_cdc \
  -master {u_pd_secenc_f1_top/u_secenc_f1_sepd/u_css600_pulseasyncbridgemstr_1} \
  -slave {u_pd_dbgtop_f0/u_pc_secenc_f0_dbgtop/u_css600_pulseasyncbridgeslv_1} \
  -shortest_period [expr {min($PERIODS(SYSPLL_DBGCLK_4), $PERIODS(SECENCCLK_SECENCDIVCLK_2))}]

constrain_css600_pulseasyncbridge_cdc \
  -master {u_pd_dbgtop_f0/u_pc_secenc_f0_dbgtop/u_css600_pulseasyncbridgemstr} \
  -slave {u_pd_secenc_f1_top/u_secenc_f1_sepd/u_css600_pulseasyncbridgeslv} \
  -shortest_period [expr {min($PERIODS(SYSPLL_DBGCLK_4), $PERIODS(SECENCCLK_SECENCDIVCLK_2))}]

constrain_css600_pulseasyncbridge_cdc \
  -master {u_pd_secenc_f1_top/u_secenc_f1_sepd/u_css600_apbasyncbridgemstr} \
  -slave {u_pd_dbgtop_f0/u_pc_secenc_f0_dbgtop/u_css600_apbasyncbridgeslv} \
  -shortest_period [expr {min($PERIODS(SYSPLL_DBGCLK_4), $PERIODS(SECENCCLK_SECENCDIVCLK_2))}]

constrain_css600_pulseasyncbridge_cdc \
  -master {u_pd_systop/u_pd_clustop/u_shared_interrupts_pulse_mstr} \
  -slave {u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_irq_pulseasyncbridgeslv} \
  -shortest_period [expr {min($PERIODS(SYSPLL_GICCLK_2), $PERIODS(SYSPLL_DBGCLK_4))}]

constrain_css600_pulseasyncbridge_cdc \
  -master {u_system_control_f0_aontop/u_css600_pulseasyncbridgeslv_s32kcounter} \
  -slave {u_pd_dbgtop_f0/u_pc_aontop_f0_dbgtop/u_css600_pulseasyncbridgeslv_counter} \
  -shortest_period [expr {min($PERIODS(S32KCLK), $PERIODS(SYSPLL_DBGCLK_4))}]

constrain_css600_pulseasyncbridge_cdc \
  -master {u_system_control_f0_aontop/u_css600_pulseasyncbridgeslv_counter} \
  -slave {u_pd_dbgtop_f0/u_pc_aontop_f0_dbgtop/u_css600_pulseasyncbridgeslv_counter} \
  -shortest_period [expr {min($PERIODS(REFCLK), $PERIODS(SYSPLL_DBGCLK_4))}]

constrain_css600_pulseasyncbridge_cdc \
  -master {u_debug_f0_aontop/u_dpmstr/u_css600_pulseasyncbridgemstr} \
  -slave {u_debug_f0_aontop/u_dpslv/u_css600_pulseasyncbridgeslv_qactive_only} \
  -shortest_period [expr {min($PERIODS(REFCLK), $PERIODS(SWCLKTCK))}]

constrain_css600_pulseasyncbridge_cdc \
  -master {u_pd_systop/u_pd_clustop/u_clustop_atb_slv/u_css600_pulseasyncbridgemstr} \
  -slave {u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_atbasyncbridgemstr/u_css600_pulseasyncbridgeslv} \
  -shortest_period [expr {min($PERIODS(CPUPLL_HOSTCPUCLK_1), $PERIODS(SYSPLL_DBGCLK_4))}]

constrain_css600_pulseasyncbridge_cdc \
  -master {u_pd_extsys0top/u_pc_eh_f0_extsyscti/u_css600_pulseasyncbridgemstr} \
  -slave {u_pd_dbgtop_f0/u_pc_eh0_f0_dbgtop/u_css600_pulseasyncbridgeslv_cti} \
  -shortest_period [expr {min($PERIODS(EXTSYS0CTICLK), $PERIODS(SYSPLL_DBGCLK_4))}]

constrain_css600_pulseasyncbridge_cdc \
  -master {u_pd_dbgtop_f0/u_pc_eh0_f0_dbgtop/u_css600_pulseasyncbridgemstr} \
  -slave {u_pd_extsys0top/u_pc_eh_f0_extsyscti/u_css600_pulseasyncbridgeslv} \
  -shortest_period [expr {min($PERIODS(EXTSYS0CTICLK), $PERIODS(SYSPLL_DBGCLK_4))}]

constrain_css600_pulseasyncbridge_cdc \
  -master {u_pd_extsys0top/u_pc_eh_f0_extsysdbg/u_css600_pulseasyncbridgemstr} \
  -slave {u_pd_dbgtop_f0/u_pc_eh0_f0_dbgtop/u_css600_pulseasyncbridgeslv_dpabort} \
  -shortest_period [expr {min($PERIODS(EXTSYS0DBGCLKM), $PERIODS(SYSPLL_DBGCLK_4))}]

constrain_css600_pulseasyncbridge_cdc \
  -master {u_pd_extsys0top/u_pc_eh_f0_extsystrace/u_css600_atbasyncbridgeslv/u_css600_pulseasyncbridgemstr} \
  -slave {u_pd_dbgtop_f0/u_pc_eh0_f0_dbgtop/u_css600_atbasyncbridgemstr/u_css600_pulseasyncbridgeslv} \
  -shortest_period [expr {min($PERIODS(EXTSYS0ATCLK), $PERIODS(SYSPLL_DBGCLK_4))}]

constrain_css600_pulseasyncbridge_cdc \
  -master {u_pd_extsys1top/u_pc_eh_f0_extsyscti/u_css600_pulseasyncbridgemstr} \
  -slave {u_pd_dbgtop_f0/u_pc_eh1_f0_dbgtop/u_css600_pulseasyncbridgeslv_cti} \
  -shortest_period [expr {min($PERIODS(EXTSYS1CTICLK), $PERIODS(SYSPLL_DBGCLK_4))}]

constrain_css600_pulseasyncbridge_cdc \
  -master {u_pd_dbgtop_f0/u_pc_eh1_f0_dbgtop/u_css600_pulseasyncbridgemstr} \
  -slave {u_pd_extsys1top/u_pc_eh_f0_extsyscti/u_css600_pulseasyncbridgeslv} \
  -shortest_period [expr {min($PERIODS(EXTSYS1CTICLK), $PERIODS(SYSPLL_DBGCLK_4))}]

constrain_css600_pulseasyncbridge_cdc \
  -master {u_pd_extsys1top/u_pc_eh_f0_extsysdbg/u_css600_pulseasyncbridgemstr} \
  -slave {u_pd_dbgtop_f0/u_pc_eh1_f0_dbgtop/u_css600_pulseasyncbridgeslv_dpabort} \
  -shortest_period [expr {min($PERIODS(EXTSYS1DBGCLKM), $PERIODS(SYSPLL_DBGCLK_4))}]

constrain_css600_pulseasyncbridge_cdc \
  -master {u_pd_extsys1top/u_pc_eh_f0_extsystrace/u_css600_atbasyncbridgeslv/u_css600_pulseasyncbridgemstr} \
  -slave {u_pd_dbgtop_f0/u_pc_eh1_f0_dbgtop/u_css600_atbasyncbridgemstr/u_css600_pulseasyncbridgeslv} \
  -shortest_period [expr {min($PERIODS(EXTSYS1ATCLK), $PERIODS(SYSPLL_DBGCLK_4))}]


constrain_css600_pulseasyncbridge_wakeonpulse_cdc \
  -master {u_pd_dbgtop_f0/u_pc_aontop_f0_dbgtop/u_dpabort_slv_dbgtopap} \
  -slave {u_debug_f0_aontop/u_dp_abort} \
  -shortest_period [expr {min($PERIODS(SYSPLL_DBGCLK_4), $PERIODS(REFCLK))}]


constrain_css600_dp_cdc \
  -master {u_debug_f0_aontop/u_dpmstr} \
  -slave {u_debug_f0_aontop/u_dpslv} \
  -shortest_period [expr {min($PERIODS(REFCLK), $PERIODS(SWCLKTCK))}]


#############################
# Constrain MHUv2 Crossings
#############################

# Constrain the MHUv2 CDCs in the design using the constrain_mhuv2_cdc
# procedure defined in procs.sdc.
# Further signoff checks required, but these can't be represented in SDC.

# ES <-> SE
constrain_mhuv2_cdc \
  -receiver {u_pd_extsys0top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_receiver_seesx_0} \
  -sender {u_pd_secenc_f1_top/u_secenc_f1_sepd/u_secenc_f1_core/u_sec_periph_integration/u_mhuv2_f1_sender_sees00} \
  -shortest_period [expr {min($PERIODS(EXTSYS0MHUCLK), $PERIODS(SECENCCLK_SECENCDIVCLK_2))}]

constrain_mhuv2_cdc \
  -receiver {u_pd_extsys0top/u_pc_eh_f0_extsysmhu/gen_mhu_seesx_1_u_mhuv2_f1_receiver_seesx_1} \
  -sender {u_pd_secenc_f1_top/u_secenc_f1_sepd/u_secenc_f1_core/u_sec_periph_integration/u_mhuv2_f1_sender_sees01} \
  -shortest_period [expr {min($PERIODS(EXTSYS0MHUCLK), $PERIODS(SECENCCLK_SECENCDIVCLK_2))}]

constrain_mhuv2_cdc \
  -receiver {u_pd_secenc_f1_top/u_secenc_f1_sepd/u_secenc_f1_core/u_sec_periph_integration/u_mhuv2_f1_receiver_es0se0} \
  -sender {u_pd_extsys0top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_sender_esxse_0} \
  -shortest_period [expr {min($PERIODS(EXTSYS0MHUCLK), $PERIODS(SECENCCLK_SECENCDIVCLK_2))}]

constrain_mhuv2_cdc \
  -receiver {u_pd_secenc_f1_top/u_secenc_f1_sepd/u_secenc_f1_core/u_sec_periph_integration/u_mhuv2_f1_receiver_es0se1} \
  -sender {u_pd_extsys0top/u_pc_eh_f0_extsysmhu/gen_mhu_esxse_1_u_mhuv2_f1_sender_esxse_1} \
  -shortest_period [expr {min($PERIODS(EXTSYS0MHUCLK), $PERIODS(SECENCCLK_SECENCDIVCLK_2))}]

# ES <-> SE
constrain_mhuv2_cdc \
  -receiver {u_pd_extsys1top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_receiver_seesx_0} \
  -sender {u_pd_secenc_f1_top/u_secenc_f1_sepd/u_secenc_f1_core/u_sec_periph_integration/u_mhuv2_f1_sender_sees10} \
  -shortest_period [expr {min($PERIODS(EXTSYS1MHUCLK), $PERIODS(SECENCCLK_SECENCDIVCLK_2))}]

constrain_mhuv2_cdc \
  -receiver {u_pd_extsys1top/u_pc_eh_f0_extsysmhu/gen_mhu_seesx_1_u_mhuv2_f1_receiver_seesx_1} \
  -sender {u_pd_secenc_f1_top/u_secenc_f1_sepd/u_secenc_f1_core/u_sec_periph_integration/u_mhuv2_f1_sender_sees11} \
  -shortest_period [expr {min($PERIODS(EXTSYS1MHUCLK), $PERIODS(SECENCCLK_SECENCDIVCLK_2))}]

constrain_mhuv2_cdc \
  -receiver {u_pd_secenc_f1_top/u_secenc_f1_sepd/u_secenc_f1_core/u_sec_periph_integration/u_mhuv2_f1_receiver_es1se0} \
  -sender {u_pd_extsys1top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_sender_esxse_0} \
  -shortest_period [expr {min($PERIODS(EXTSYS1MHUCLK), $PERIODS(SECENCCLK_SECENCDIVCLK_2))}]

constrain_mhuv2_cdc \
  -receiver {u_pd_secenc_f1_top/u_secenc_f1_sepd/u_secenc_f1_core/u_sec_periph_integration/u_mhuv2_f1_receiver_es1se1} \
  -sender {u_pd_extsys1top/u_pc_eh_f0_extsysmhu/gen_mhu_esxse_1_u_mhuv2_f1_sender_esxse_1} \
  -shortest_period [expr {min($PERIODS(EXTSYS1MHUCLK), $PERIODS(SECENCCLK_SECENCDIVCLK_2))}]


# SYSTOP <-> SE
constrain_mhuv2_cdc \
  -receiver {u_pd_secenc_f1_top/u_secenc_f1_sepd/u_secenc_f1_core/u_sec_periph_integration/u_mhuv2_f1_receiver_hse0} \
  -sender {u_pd_systop/u_pc_secenc_f0_systop/u_mhuv2_f1_sender_hse_0} \
  -shortest_period [expr {min($PERIODS(SECENCCLK_SECENCDIVCLK_2), $PERIODS(SYSPLL_ACLK_2))}]

constrain_mhuv2_cdc \
  -receiver {u_pd_secenc_f1_top/u_secenc_f1_sepd/u_secenc_f1_core/u_sec_periph_integration/u_mhuv2_f1_receiver_hse1} \
  -sender {u_pd_systop/u_pc_secenc_f0_systop/u_mhuv2_f1_sender_hse_1} \
  -shortest_period [expr {min($PERIODS(SECENCCLK_SECENCDIVCLK_2), $PERIODS(SYSPLL_ACLK_2))}]

constrain_mhuv2_cdc \
  -receiver {u_pd_systop/u_pc_secenc_f0_systop/u_mhuv2_f1_receiver_seh_0} \
  -sender {u_pd_secenc_f1_top/u_secenc_f1_sepd/u_secenc_f1_core/u_sec_periph_integration/u_mhuv2_f1_sender_seh0} \
  -shortest_period [expr {min($PERIODS(SECENCCLK_SECENCDIVCLK_2), $PERIODS(SYSPLL_ACLK_2))}]

constrain_mhuv2_cdc \
  -receiver {u_pd_systop/u_pc_secenc_f0_systop/u_mhuv2_f1_receiver_seh_1} \
  -sender {u_pd_secenc_f1_top/u_secenc_f1_sepd/u_secenc_f1_core/u_sec_periph_integration/u_mhuv2_f1_sender_seh1} \
  -shortest_period [expr {min($PERIODS(SECENCCLK_SECENCDIVCLK_2), $PERIODS(SYSPLL_ACLK_2))}]

# SYSTOP <-> ES0
constrain_mhuv2_cdc \
  -receiver {u_pd_systop/u_pc_eh0_f0_systop/u_mhuv2_f1_receiver_esxh_0} \
  -sender {u_pd_extsys0top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_sender_esxh_0} \
  -shortest_period [expr {min($PERIODS(EXTSYS0MHUCLK), $PERIODS(SYSPLL_ACLK_2))}]

constrain_mhuv2_cdc \
  -receiver {u_pd_systop/u_pc_eh0_f0_systop/gen_mhu_esxh_1_u_mhuv2_f1_receiver_esxh_1} \
  -sender {u_pd_extsys0top/u_pc_eh_f0_extsysmhu/gen_mhu_esxh_1_u_mhuv2_f1_sender_esxh_1} \
  -shortest_period [expr {min($PERIODS(EXTSYS0MHUCLK), $PERIODS(SYSPLL_ACLK_2))}]

constrain_mhuv2_cdc \
  -receiver {u_pd_extsys0top/u_pc_eh_f0_extsysmhu/gen_mhu_hesx_1_u_mhuv2_f1_receiver_hesx_1} \
  -sender {u_pd_systop/u_pc_eh0_f0_systop/gen_mhu_hesx_1_u_mhuv2_f1_sender_hesx_1} \
  -shortest_period [expr {min($PERIODS(EXTSYS0MHUCLK), $PERIODS(SYSPLL_ACLK_2))}]

constrain_mhuv2_cdc \
  -receiver {u_pd_extsys0top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_receiver_hesx_0} \
  -sender {u_pd_systop/u_pc_eh0_f0_systop/u_mhuv2_f1_sender_hesx_0} \
  -shortest_period [expr {min($PERIODS(EXTSYS0MHUCLK), $PERIODS(SYSPLL_ACLK_2))}]

# SYSTOP <-> ES0
constrain_mhuv2_cdc \
  -receiver {u_pd_systop/u_pc_eh1_f0_systop/u_mhuv2_f1_receiver_esxh_0} \
  -sender {u_pd_extsys1top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_sender_esxh_0} \
  -shortest_period [expr {min($PERIODS(EXTSYS1MHUCLK), $PERIODS(SYSPLL_ACLK_2))}]

constrain_mhuv2_cdc \
  -receiver {u_pd_systop/u_pc_eh1_f0_systop/gen_mhu_esxh_1_u_mhuv2_f1_receiver_esxh_1} \
  -sender {u_pd_extsys1top/u_pc_eh_f0_extsysmhu/gen_mhu_esxh_1_u_mhuv2_f1_sender_esxh_1} \
  -shortest_period [expr {min($PERIODS(EXTSYS1MHUCLK), $PERIODS(SYSPLL_ACLK_2))}]

constrain_mhuv2_cdc \
  -receiver {u_pd_extsys1top/u_pc_eh_f0_extsysmhu/gen_mhu_hesx_1_u_mhuv2_f1_receiver_hesx_1} \
  -sender {u_pd_systop/u_pc_eh1_f0_systop/gen_mhu_hesx_1_u_mhuv2_f1_sender_hesx_1} \
  -shortest_period [expr {min($PERIODS(EXTSYS1MHUCLK), $PERIODS(SYSPLL_ACLK_2))}]

constrain_mhuv2_cdc \
  -receiver {u_pd_extsys1top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_receiver_hesx_0} \
  -sender {u_pd_systop/u_pc_eh1_f0_systop/u_mhuv2_f1_sender_hesx_0} \
  -shortest_period [expr {min($PERIODS(EXTSYS1MHUCLK), $PERIODS(SYSPLL_ACLK_2))}]


##############################
# Constrain CPU CTI Interface
##############################

# The CPU CTI interface is connected to a CSS-600 pulse asynchronous bridge slave,
# amd therefore the pulse_req* and pulse_ack* pins on either side of the crossing
# should have max_delay relationships.
# Further signoff checks required, but these can't be represented in SDC.

compat_set_max_delay -ignore_clock_latency $CPU_CTI_MAX_DELAY -from [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/u_governor_ctm/ctm_ctichinack_reg_*/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_pulseasyncbridgeslv_hostcpuctichin/gen_ack_sync_no_cdc_*_u_css600_cdc_capt_sync_ack/sync_depth_2_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $CPU_CTI_MAX_DELAY -from [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/u_governor_ctm/ctm_ctichout_reg_*/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_pulseasyncbridgeslv_hostcpuctichout/gen_req_sync_no_cdc_*_u_css600_cdc_capt_sync_req/sync_depth_2_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $CPU_CTI_MAX_DELAY -from [get_pins {
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_pulseasyncbridgeslv_hostcpuctichout/pulse_ack_q_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/u_governor_ctm/u_ctm_ch_out_*/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $CPU_CTI_MAX_DELAY -from [get_pins {
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_pulseasyncbridgeslv_hostcpuctichout/pulse_ack_q_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_ctichout_pulseasyncbridge_slv/gen_ack_sync_no_cdc_*_u_css600_cdc_capt_sync_ack/sync_depth_2_u_cdc_capt_sync/D
}]

##############################################
# Low Power P-Channel and Q-Channel Max Delays
##############################################

# For these low power Q-channel CDCs, the crossing latency is not critical, and
# crossing path delays do not need to be balanced. It is enough to just
# constrain the paths with a loose maximum delay constraint.

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_clocks {
  CPUPLL_HOSTCPUCLK_1
  REFCLK
  S32KCLK
  SECENCCLK_SECENCDIVCLK_2
  SWCLKTCK
  SYSPLL_ACLK_2
  SYSPLL_CTRLCLK_2
  SYSPLL_DBGCLK_4
  SYSPLL_GICCLK_2
  SYSPLL_SECENCCLK_4
  TRACECLKIN
}] -through [get_pins {
  u_pd_dbgtop_f0/u_clk_ctrl_dbgclk/clk_qactive_i*
  u_pd_systop/u_aclk_ctrl/clk_qactive_i*
  u_pd_systop/u_ctrlclk_ctrl/clk_qactive_i*
  u_reset_controller_f1_top/u_secenc_hostsys_lpd_q/dev_qactive_i*
  u_system_control_f0_aontop/u_clk_ctrl_refclk_free/clk_qactive_i*
  u_system_control_f0_aontop/u_clk_ctrl_refclk_int/clk_qactive_i*
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_ingress_expander/dev_qactive_i*
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_q_sequencer/dev_qactive_i*
}] -to [get_clocks {
  REFCLK
  SYSPLL_ACLK_2
  SYSPLL_CTRLCLK_2
  SYSPLL_DBGCLK_4
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_fc/u_lpi/u_comp_pwrctrl/qacceptn_o_reg/CK
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_fc/u_lpi/u_comp_pwrctrl/qdeny_o_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_internal_expander/dev_sync_inc_dev_sync_loop_0_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_internal_expander/dev_sync_inc_dev_sync_loop_0_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_base_systop/u_fc_*/u_lpi/u_comp_pwrctrl/qacceptn_o_reg/CK
  u_pd_systop/u_base_systop/u_fc_*/u_lpi/u_comp_pwrctrl/qdeny_o_reg/CK
}] -to [get_pins {
  u_pd_systop/u_systop_internal_lpdq/dev_sync_inc_dev_sync_loop_*_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_pd_systop/u_systop_internal_lpdq/dev_sync_inc_dev_sync_loop_*_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_l2_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_1/CK
  u_pd_systop/u_pc_cpu_systop/u_clustop_ppu/u_pck600_ppu_diu/dev_pstate_r_reg_*/CK
  u_pd_systop/u_pc_cpu_systop/u_clustop_l2_qch_handshake/l2_qreqn_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/u_cdc_capt_sync_l2qreqn/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_systop_internal_lpdq/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_base_systop/u_fc_*/u_pwrqreqn_cdc_capt_sync/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/pwrqacceptn_q_reg/CK
  u_pd_systop/u_pc_cpu_systop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/pwrqdeny_q_reg/CK
  u_pd_systop/u_pd_clustop/u_clustop_atb_slv/u_css600_atbasyncbridge_pwr_lpi_slv/u_css600_lpislave_fsm/state_reg_2/CK
  u_pd_systop/u_pd_clustop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/pwrqacceptn_q_reg/CK
  u_pd_systop/u_pd_clustop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/pwrqdeny_q_reg/CK
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_internal_expander/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_0/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_fc/u_pwrqreqn_cdc_capt_sync/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/GEN_EXTSYS_LPD_Q_0_u_extsys_hostsys_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_*/CK
}] -to [get_pins {
  extsys_dbgtopq_comb_*_u_extsys_dbgtopq_comb/ctrl_sync_inc_ctrl_sync_loop_0_u_pck600_sync_qreqn/u_cdc_capt_sync/D
  extsys_systopq_comb_*_u_extsys_systopq_comb/ctrl_sync_inc_ctrl_sync_loop_0_u_pck600_sync_qreqn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/GEN_EXTSYS_LPD_Q_1_u_extsys_hostsys_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_*/CK
}] -to [get_pins {
  extsys_dbgtopq_comb_*_u_extsys_dbgtopq_comb/ctrl_sync_inc_ctrl_sync_loop_0_u_pck600_sync_qreqn/u_cdc_capt_sync/D
  extsys_systopq_comb_*_u_extsys_systopq_comb/ctrl_sync_inc_ctrl_sync_loop_0_u_pck600_sync_qreqn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_systop_egress_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pc_sysctrl_f0_systop/u_adb_apb4_slv/u_pwr_qreq_sync/sync_depth_2_u_cdc_capt_sync/D
  u_pd_systop/u_pc_sysctrl_f0_systop/u_bootreg_systop/u_css600_apbasyncbridgeslv/u_pwr_qreq_sync/sync_depth_2_u_cdc_capt_sync/D
  u_pd_systop/u_pc_sysctrl_f0_systop/u_a4s_slv/u_slv/u_si_ctrl/u_syncn_pwrqreqn/g_levels_2_u_sync/D
  u_pd_systop/u_pc_sysctrl_f0_systop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/u_syncn_pwrqreqn/g_levels_2_u_sync/D
  u_pd_systop/u_pc_sysctrl_f0_systop/u_adb_uart_apb4_slv/u_pwr_qreq_sync/sync_depth_2_u_cdc_capt_sync/D
  u_pd_systop/u_pc_debug_aon_f0_systop/u_sdc600_apbcom_int/u_apbcom/GENTOP_SYNC_INT_u_pwr_qreq_sync/sync_depth_2_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  extsys_systopq_comb_*_u_extsys_systopq_comb/u_lpc_core/ctrl_qacceptn_r_reg_0/CK
  extsys_systopq_comb_*_u_extsys_systopq_comb/u_lpc_core/ctrl_qdeny_r_reg_0/CK
  extsys_dbgtopq_comb_*_u_extsys_dbgtopq_comb/u_lpc_core/ctrl_qacceptn_r_reg_0/CK
  extsys_dbgtopq_comb_*_u_extsys_dbgtopq_comb/u_lpc_core/ctrl_qdeny_r_reg_0/CK
}] -to [get_pins {
  u_reset_controller_f1_top/GEN_EXTSYS_LPD_Q_0_u_extsys_hostsys_lpd_q/dev_sync_inc_dev_sync_loop_*_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_reset_controller_f1_top/GEN_EXTSYS_LPD_Q_0_u_extsys_hostsys_lpd_q/dev_sync_inc_dev_sync_loop_*_u_pck600_sync_qdeny/u_cdc_capt_sync/D
  u_reset_controller_f1_top/GEN_EXTSYS_LPD_Q_1_u_extsys_hostsys_lpd_q/dev_sync_inc_dev_sync_loop_*_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_reset_controller_f1_top/GEN_EXTSYS_LPD_Q_1_u_extsys_hostsys_lpd_q/dev_sync_inc_dev_sync_loop_*_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_egress_dbgtop_comb/u_lpc_core/dev_qreqn_r_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pc_debug_f0_systop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/u_syncn_pwrqreqn/g_levels_2_u_sync/D
  u_pd_systop/u_pc_debug_f0_systop/u_adb_hostsysdbg_slv/u_pwr_qreq_sync/sync_depth_2_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ingress_dbgtop_comb/u_lpc_core/dev_qreqn_r_reg_*/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_apbasyncbridgeslv/u_pwr_qreq_sync/sync_depth_2_u_cdc_capt_sync/D
  u_pd_dbgtop_f0/u_systop_f0_dbgtop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/u_syncn_pwrqreqn/g_levels_2_u_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_pwr_ctrl/u_pck600_lpc_q_*/u_lpc_core/ctrl_qacceptn_r_reg_1/CK
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_pwr_ctrl/u_pck600_lpc_q_*/u_lpc_core/ctrl_qdeny_r_reg_1/CK
}] -to [get_pins {
  u_secenc_systopq_comb/dev_sync_inc_dev_sync_loop_0_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_secenc_systopq_comb/dev_sync_inc_dev_sync_loop_0_u_pck600_sync_qdeny/u_cdc_capt_sync/D
  u_secenc_dbgtopq_comb/dev_sync_inc_dev_sync_loop_0_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_secenc_dbgtopq_comb/dev_sync_inc_dev_sync_loop_0_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_egress_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_*/CK
  u_pd_systop/u_pc_cpu_systop/u_clustop_ingress_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_clustop_atb_slv/u_css600_atbasyncbridge_slv_sync/u_pwr_qreq_sync/sync_depth_2_u_cdc_capt_sync/D
  u_pd_systop/u_pd_clustop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/u_syncn_pwrqreqn/g_levels_2_u_sync/D
  u_pd_systop/u_pc_cpu_systop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/u_syncn_pwrqreqn/g_levels_2_u_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_secenc_hostsys_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_*/CK
}] -to [get_pins {
  u_secenc_systopq_comb/ctrl_sync_inc_ctrl_sync_loop_0_u_pck600_sync_qreqn/u_cdc_capt_sync/D
  u_secenc_dbgtopq_comb/ctrl_sync_inc_ctrl_sync_loop_0_u_pck600_sync_qreqn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pc_eh0_f0_systop/gen_mhu_esxh_1_u_mhuv2_f1_receiver_esxh_*/u_mhuv2_f1_adb_sync_pwrqreqn/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_systop/u_pc_eh0_f0_systop/u_mhuv2_f1_receiver_esxh_*/u_mhuv2_f1_adb_sync_pwrqreqn/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_systop/u_pc_eh1_f0_systop/gen_mhu_esxh_1_u_mhuv2_f1_receiver_esxh_*/u_mhuv2_f1_adb_sync_pwrqreqn/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_systop/u_pc_eh1_f0_systop/u_mhuv2_f1_receiver_esxh_*/u_mhuv2_f1_adb_sync_pwrqreqn/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_systop/u_pc_secenc_f0_systop/u_mhuv2_f1_receiver_seh_*/u_mhuv2_f1_adb_sync_pwrqreqn/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_sysctrl_f0_systop/u_a4s_slv/u_slv/u_si_ctrl/pwrqacceptn_q_reg/CK
  u_pd_systop/u_pc_sysctrl_f0_systop/u_a4s_slv/u_slv/u_si_ctrl/pwrqdeny_q_reg/CK
  u_pd_systop/u_pc_sysctrl_f0_systop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/pwrqacceptn_q_reg/CK
  u_pd_systop/u_pc_sysctrl_f0_systop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/pwrqdeny_q_reg/CK
  u_pd_systop/u_pc_debug_aon_f0_systop/u_sdc600_apbcom_int/u_apbcom/u_lpi/GEN_PWR_LPI_u_pwr_lpislave/lpi_state_reg_2/CK
  u_pd_systop/u_pc_debug_aon_f0_systop/u_sdc600_apbcom_int/u_apbcom/u_lpi/GEN_PWR_LPI_u_pwr_lpislave/lpi_state_reg_1/CK
}] -to [get_pins {
  u_pd_systop/u_systop_egress_lpd_q/dev_sync_inc_dev_sync_loop_*_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_pd_systop/u_systop_egress_lpd_q/dev_sync_inc_dev_sync_loop_*_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_dp2hostdbg_aontopq_comb/u_lpc_core/ctrl_qacceptn_r_reg_1/CK
  u_dp2hostdbg_aontopq_comb/u_lpc_core/ctrl_qdeny_r_reg_1/CK
  u_dp2systop_aontopq_comb/u_lpc_core/ctrl_qacceptn_r_reg_1/CK
  u_dp2systop_aontopq_comb/u_lpc_core/ctrl_qdeny_r_reg_1/CK
}] -to [get_pins {
  u_reset_controller_f1_top/u_aontoppo_aontopwarm_lpd_q/dev_sync_inc_dev_sync_loop_*_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_reset_controller_f1_top/u_aontoppo_aontopwarm_lpd_q/dev_sync_inc_dev_sync_loop_*_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_secenc_systopq_comb/u_lpc_core/ctrl_qacceptn_r_reg_0/CK
  u_secenc_systopq_comb/u_lpc_core/ctrl_qdeny_r_reg_0/CK
  u_secenc_dbgtopq_comb/u_lpc_core/ctrl_qacceptn_r_reg_0/CK
  u_secenc_dbgtopq_comb/u_lpc_core/ctrl_qdeny_r_reg_0/CK
}] -to [get_pins {
  u_reset_controller_f1_top/u_secenc_hostsys_lpd_q/dev_sync_inc_dev_sync_loop_*_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_reset_controller_f1_top/u_secenc_hostsys_lpd_q/dev_sync_inc_dev_sync_loop_*_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_eh0_f0_systop/u_mhuv2_f1_receiver_esxh_0/u_mhuv2_f1_rec_qch_pwr/qacceptn_r_reg/CK
  u_pd_systop/u_pc_eh0_f0_systop/u_mhuv2_f1_receiver_esxh_0/u_mhuv2_f1_rec_qch_pwr/qdeny_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_0_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_0_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_eh0_f0_systop/gen_mhu_esxh_1_u_mhuv2_f1_receiver_esxh_1/u_mhuv2_f1_rec_qch_pwr/qacceptn_r_reg/CK
  u_pd_systop/u_pc_eh0_f0_systop/gen_mhu_esxh_1_u_mhuv2_f1_receiver_esxh_1/u_mhuv2_f1_rec_qch_pwr/qdeny_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_1_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_1_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_eh1_f0_systop/u_mhuv2_f1_receiver_esxh_0/u_mhuv2_f1_rec_qch_pwr/qacceptn_r_reg/CK
  u_pd_systop/u_pc_eh1_f0_systop/u_mhuv2_f1_receiver_esxh_0/u_mhuv2_f1_rec_qch_pwr/qdeny_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_2_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_2_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_eh1_f0_systop/gen_mhu_esxh_1_u_mhuv2_f1_receiver_esxh_1/u_mhuv2_f1_rec_qch_pwr/qacceptn_r_reg/CK
  u_pd_systop/u_pc_eh1_f0_systop/gen_mhu_esxh_1_u_mhuv2_f1_receiver_esxh_1/u_mhuv2_f1_rec_qch_pwr/qdeny_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_3_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_3_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_secenc_f0_systop/u_mhuv2_f1_receiver_seh_0/u_mhuv2_f1_rec_qch_pwr/qacceptn_r_reg/CK
  u_pd_systop/u_pc_secenc_f0_systop/u_mhuv2_f1_receiver_seh_0/u_mhuv2_f1_rec_qch_pwr/qdeny_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_4_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_4_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_secenc_f0_systop/u_mhuv2_f1_receiver_seh_1/u_mhuv2_f1_rec_qch_pwr/qacceptn_r_reg/CK
  u_pd_systop/u_pc_secenc_f0_systop/u_mhuv2_f1_receiver_seh_1/u_mhuv2_f1_rec_qch_pwr/qdeny_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_5_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_5_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_pc_aontop_f0_dbgtop/u_slv/u_slv/u_si_ctrl/pwrqacceptn_q_reg/CK
  u_pd_dbgtop_f0/u_pc_aontop_f0_dbgtop/u_slv/u_slv/u_si_ctrl/pwrqdeny_q_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_internal_expander/dev_sync_inc_dev_sync_loop_2_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_internal_expander/dev_sync_inc_dev_sync_loop_2_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_dp2systop_aontopq_comb/u_lpc_core/dev_qreqn_r_reg_0/CK
  u_dp2systop_aontopq_comb/u_lpc_core/dev_qreqn_r_reg_1/CK
}] -to [get_pins {
  u_pd_systop/u_pc_debug_aon_f0_systop/u_adb_apb4_slv/u_pwr_qreq_sync/sync_depth_2_u_cdc_capt_sync/D
  u_pd_systop/u_pc_debug_aon_f0_systop/u_sdc600_comasyncbridge_indirect_half_int/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_pwr_lpislave/u_sync_pwr_qreq_n/sync_depth_2_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_irq_pulseasyncbridgeslv/pwr_qaccept_n_reg/CK
}] -to [get_pins {
  u_clustop_dbgtop_ingress_comb/dev_sync_inc_dev_sync_loop_2_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_pc_aontop_f0_dbgtop/u_css600_pulseasyncbridgeslv_counter/pwr_qaccept_n_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_internal_expander/dev_sync_inc_dev_sync_loop_1_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_pulseasyncbridgeslv_hostcpuctichin/pwr_qaccept_n_reg/CK
}] -to [get_pins {
  u_clustop_dbgtop_ingress_comb/dev_sync_inc_dev_sync_loop_1_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_systop_f0_dbgtop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/pwrqacceptn_q_reg/CK
  u_pd_dbgtop_f0/u_systop_f0_dbgtop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/pwrqdeny_q_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ingress_dbgtop_comb/dev_sync_inc_dev_sync_loop_0_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ingress_dbgtop_comb/dev_sync_inc_dev_sync_loop_0_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_debug_f0_systop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/pwrqacceptn_q_reg/CK
  u_pd_systop/u_pc_debug_f0_systop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/pwrqdeny_q_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_egress_dbgtop_comb/dev_sync_inc_dev_sync_loop_0_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_system_control_f0_aontop/u_ppu_aon/u_systop_egress_dbgtop_comb/dev_sync_inc_dev_sync_loop_0_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_systop_internal_lpdq/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_5/CK
}] -to [get_pins {
  u_pd_systop/u_base_systop/u_base_aclk_lpdq/active_deny_support_active_deny_sync_inc_u_pck600_dev_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_secenc_systopq_comb/u_lpc_core/dev_qreqn_r_reg_0/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_pwr_ctrl/u_pck600_lpc_q_0/ctrl_sync_inc_ctrl_sync_loop_1_u_pck600_sync_qreqn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_internal_expander/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_*/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_pc_aontop_f0_dbgtop/u_css600_pulseasyncbridgeslv_counter/u_css600_cdc_capt_sync_pwr_qreq_n/sync_depth_2_u_cdc_capt_sync/D
  u_pd_dbgtop_f0/u_pc_aontop_f0_dbgtop/u_slv/u_slv/u_si_ctrl/u_syncn_pwrqreqn/g_levels_2_u_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_clustop_dbgtop_ingress_comb/u_lpc_core/dev_qreqn_r_reg_*/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_pulseasyncbridgeslv_hostcpuctichin/u_css600_cdc_capt_sync_pwr_qreq_n/sync_depth_2_u_cdc_capt_sync/D
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_irq_pulseasyncbridgeslv/u_css600_cdc_capt_sync_pwr_qreq_n/sync_depth_2_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_debug_aon_f0_systop/u_sdc600_comasyncbridge_indirect_half_int/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_pwr_lpislave/u_pwr_lpislave/lpi_state_reg_1/CK
  u_pd_systop/u_pc_debug_aon_f0_systop/u_sdc600_comasyncbridge_indirect_half_int/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_pwr_lpislave/u_pwr_lpislave/lpi_state_reg_2/CK
}] -to [get_pins {
  u_dp2systop_aontopq_comb/dev_sync_inc_dev_sync_loop_1_u_pck600_sync_qdeny/u_cdc_capt_sync/D
  u_dp2systop_aontopq_comb/dev_sync_inc_dev_sync_loop_1_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_acg_axi_cvm/u_acg_axi_core/pwr_qacceptn_r_reg/CK
  u_pd_systop/u_acg_axi_cvm/u_acg_axi_core/pwr_qdeny_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_internal_acg_p2q/dev_sync_inc_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_system_control_f0_aontop/u_ppu_aon/u_systop_internal_acg_p2q/dev_sync_inc_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_clustop_dbgtop_ingress_comb/u_lpc_core/ctrl_qacceptn_r_reg_*/CK
  u_clustop_dbgtop_ingress_comb/u_lpc_core/ctrl_qdeny_r_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_2_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_pd_systop/u_pc_cpu_systop/u_clustop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_2_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/u_governor_power/l2qacceptn_o_reg/CK
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/u_governor_power/l2qactive_o_reg/CK
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/u_governor_power/l2qdeny_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_l2_lpd_q/dev_sync_inc_dev_sync_loop_1_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_pd_systop/u_pc_cpu_systop/u_clustop_l2_lpd_q/dev_sync_inc_dev_sync_loop_1_u_pck600_sync_qdeny/u_cdc_capt_sync/D
  u_pd_systop/u_pc_cpu_systop/u_l2_qacceptn_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_systop/u_pc_cpu_systop/u_l2_qdeny_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_internal_acg_p2q/u_p2q_core/dev_qreqn_reg/CK
}] -to [get_pins {
  u_pd_systop/u_acg_axi_cvm/u_acg_axi_core/u_acg_sync_pwr_qreqn/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_extdbg_rom/u_css600_apbrom_gpr_gpr/cdbgpwrupreq_reg_0/CK
  u_pd_dbgtop_f0/u_pc_secenc_f0_dbgtop/u_css600_apbasyncbridgeslv/u_slv_core/pwrqactive_r_reg/CK
  u_pd_dbgtop_f0/u_pc_secenc_f0_dbgtop/u_css600_pulseasyncbridgeslv_*/gen_ack_sync_no_cdc_*_u_css600_cdc_capt_sync_ack/sync_depth_2_u_cdc_capt_sync/CK
  u_pd_dbgtop_f0/u_pc_secenc_f0_dbgtop/u_css600_pulseasyncbridgeslv_*/pulse_req_q_reg_*/CK
  u_pd_systop/u_pc_secenc_f0_systop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst/u_mst/u_protocol_quiescent/read_write_quiescent_q_reg/CK
  u_pd_systop/u_pc_debug_f0_systop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst/u_mst/u_protocol_quiescent/read_write_quiescent_q_reg/CK  
  u_pd_systop/u_pc_secenc_f0_systop/u_mhuv2_f1_sender_hse_0/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
  u_pd_systop/u_pc_secenc_f0_systop/u_mhuv2_f1_sender_hse_1/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_pwr_ctrl/u_pck600_ppu_sse710_secenc/pactive_input_block_loop_8_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/pactive_input_block_loop_7_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/gen_mhu_esxse_1_u_mhuv2_f1_sender_esxse_1/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_sender_esxse_0/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/gen_mhu_esxse_1_u_mhuv2_f1_sender_esxse_1/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_sender_esxse_0/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_pwr_ctrl/u_pck600_ppu_sse710_secenc/pactive_input_block_loop_8_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/pactive_input_block_loop_7_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_chac_reg/data_chs_pwr_req_reg_5/CK
  u_pd_systop/u_acg_axi_cvm/u_acg_axi_core/aw_ot_cntr_non_zero_reg/CK
  u_pd_systop/u_acg_axi_cvm/u_acg_axi_core/rd_ot_cntr_non_zero_reg/CK
  u_pd_systop/u_acg_axi_cvm/u_acg_axi_core/w_ot_cntr_non_zero_reg/CK
  u_pd_systop/u_base_systop/u_fc_4/u_regslice_m/awakeup_o_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/pactive_input_block_loop_8_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_debug_f0_aontop/u_dpslv/u_css600_dpslv_reg_block/ctrlstat_cdbgpwrupreq_q_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_repack_dp_cdbgpwrupreq/u_p_reqack_to_qchan_f0_cdc_capt_sync_pwrupreq/u_arm_element_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pck600_ppu_pcsm_sse710_clus/pcsm_paccept_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_ppu/u_pck600_ppu_input_block_pcsmpaccept/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_ppu/u_pck600_ppu_piu/pcsm_preq_r_reg/CK
}] -to [get_pins {
  u_pck600_ppu_pcsm_sse710_clus/pchannel_async_u_pck600_cdc_capt_sync_pcsm_preq/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_systop_internal_lpdq/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_base_systop/u_base_aclk_lpdq/active_deny_support_active_deny_sync_inc_u_pck600_dev_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_egress_expander/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_1/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_pc_aontop_f0_dbgtop/u_slv/u_slv/u_si_ctrl/u_syncn_pwrqreqn/g_levels_2_u_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_pc_aontop_f0_dbgtop/u_slv/u_slv/u_si_ctrl/pwrqacceptn_q_reg/CK
  u_pd_dbgtop_f0/u_pc_aontop_f0_dbgtop/u_slv/u_slv/u_si_ctrl/pwrqdeny_q_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_egress_expander/dev_sync_inc_dev_sync_loop_1_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_egress_expander/dev_sync_inc_dev_sync_loop_1_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_aontoppo_aontopwarm_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_*/CK
}] -to [get_pins {
  u_dp2hostdbg_aontopq_comb/ctrl_sync_inc_ctrl_sync_loop_1_u_pck600_sync_qreqn/u_cdc_capt_sync/D
  u_dp2systop_aontopq_comb/ctrl_sync_inc_ctrl_sync_loop_1_u_pck600_sync_qreqn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_clustop_dbgtop_egress_comb/u_lpc_core/ctrl_qacceptn_r_reg_*/CK
  u_clustop_dbgtop_egress_comb/u_lpc_core/ctrl_qdeny_r_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_egress_lpd_q/dev_sync_inc_dev_sync_loop_1_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_pd_systop/u_pc_cpu_systop/u_clustop_egress_lpd_q/dev_sync_inc_dev_sync_loop_1_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_clustop_dbgtop_egress_comb/u_lpc_core/dev_qreqn_r_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_clustop_atb_slv/u_css600_atbasyncbridge_slv_sync/u_pwr_qreq_sync/sync_depth_2_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_clustop_dbgtop_ingress_comb/u_lpc_core/dev_qreqn_r_reg_*/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_apbasyncbridgeslv/u_pwr_qreq_sync/sync_depth_2_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_pc_aontop_f0_dbgtop/u_slv/u_slv/u_si_ctrl/pwrqacceptn_q_reg/CK
  u_pd_dbgtop_f0/u_pc_aontop_f0_dbgtop/u_slv/u_slv/u_si_ctrl/pwrqdeny_q_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_egress_expander/dev_sync_inc_dev_sync_loop_2_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_egress_expander/dev_sync_inc_dev_sync_loop_2_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_ingress_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_*/CK
  u_pd_systop/u_pc_cpu_systop/u_clustop_egress_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_*/CK
}] -to [get_pins {
  u_clustop_dbgtop_ingress_comb/ctrl_sync_inc_ctrl_sync_loop_0_u_pck600_sync_qreqn/u_cdc_capt_sync/D
  u_clustop_dbgtop_egress_comb/ctrl_sync_inc_ctrl_sync_loop_0_u_pck600_sync_qreqn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_systop_clustop_dependency_q_chan/pwr_qacceptn_reg/CK
  u_pd_systop/u_pc_cpu_systop/u_systop_clustop_dependency_q_chan/pwr_qdeny_reg/CK
}] -to [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_0_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_0_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_eh0_f0_systop/gen_mhu_esxh_1_u_mhuv2_f1_receiver_esxh_1/u_mhuv2_f1_rec_qch_pwr/qacceptn_r_reg/CK
  u_pd_systop/u_pc_eh0_f0_systop/gen_mhu_esxh_1_u_mhuv2_f1_receiver_esxh_1/u_mhuv2_f1_rec_qch_pwr/qdeny_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_2_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_2_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_eh0_f0_systop/u_mhuv2_f1_receiver_esxh_0/u_mhuv2_f1_rec_qch_pwr/qacceptn_r_reg/CK
  u_pd_systop/u_pc_eh0_f0_systop/u_mhuv2_f1_receiver_esxh_0/u_mhuv2_f1_rec_qch_pwr/qdeny_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_1_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_1_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_eh1_f0_systop/gen_mhu_esxh_1_u_mhuv2_f1_receiver_esxh_1/u_mhuv2_f1_rec_qch_pwr/qacceptn_r_reg/CK
  u_pd_systop/u_pc_eh1_f0_systop/gen_mhu_esxh_1_u_mhuv2_f1_receiver_esxh_1/u_mhuv2_f1_rec_qch_pwr/qdeny_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_4_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_4_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_eh1_f0_systop/u_mhuv2_f1_receiver_esxh_0/u_mhuv2_f1_rec_qch_pwr/qacceptn_r_reg/CK
  u_pd_systop/u_pc_eh1_f0_systop/u_mhuv2_f1_receiver_esxh_0/u_mhuv2_f1_rec_qch_pwr/qdeny_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_3_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_3_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_secenc_f0_systop/u_mhuv2_f1_receiver_seh_0/u_mhuv2_f1_rec_qch_pwr/qacceptn_r_reg/CK
  u_pd_systop/u_pc_secenc_f0_systop/u_mhuv2_f1_receiver_seh_0/u_mhuv2_f1_rec_qch_pwr/qdeny_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_5_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_5_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_*/CK
  u_pd_systop/u_systop_ingress_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_systop_clustop_dependency_q_chan/pactive_en_reg_*/D
  u_pd_systop/u_pc_cpu_systop/u_systop_clustop_dependency_q_chan/pwr_qacceptn_reg/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_*/CK
  u_pd_systop/u_systop_ingress_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_systop_clustop_dependency_q_chan/pwr_qdeny_reg/D
  u_pd_systop/u_pc_cpu_systop/u_systop_clustop_dependency_q_chan/state_r_reg_*/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_egress_expander/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_*/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_pc_aontop_f0_dbgtop/u_slv/u_slv/u_si_ctrl/u_syncn_pwrqreqn/g_levels_2_u_sync/D
}]


#################
# Interrupt CDCs
#################

# For these interrupt CDCs, the crossing latency is not critical, and
# crossing path delays do not need to be balanced. It is enough to just
# constrain the paths with a loose maximum delay constraint.

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_refclk_cntbase0/u_gtimer_syncapb_core_physical/interrupt_out_reg/CK
  u_system_control_f0_aontop/u_refclk_cntbase1/u_gtimer_syncapb_core_physical/interrupt_out_reg/CK
  u_system_control_f0_aontop/u_refclk_cntbase2/u_gtimer_syncapb_core_physical/interrupt_out_reg/CK
  u_system_control_f0_aontop/u_refclk_cntbase3/u_gtimer_syncapb_core_physical/interrupt_out_reg/CK
}] -to [get_clocks {
  SYSPLL_CTRLCLK_2
  SYSPLL_GICCLK_2
  SECENCCLK_SECENCDIVCLK_2
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/u_gic400/u_gic_interfaces/g_gic_cpu_interfaces_*_u_gic_cpu_interface/nfiq_cpu_q_reg/CK
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/u_gic400/u_gic_interfaces/g_gic_cpu_interfaces_*_u_gic_cpu_interface/nirq_cpu_q_reg/CK
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/u_gic400/u_gic_interfaces/g_gic_vcpu_interfaces_*_u_gic_vcpu_interface/nvirq_q_reg/CK
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/u_gic400/u_gic_interfaces/g_gic_vcpu_interfaces_*_u_gic_vcpu_interface/nvfiq_q_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/GEN_INTR_SYNC_*_u_cdc_capt_sync_intr*/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_ppu/u_pck600_ppu_reg/irq_r_reg/CK
  u_system_control_f0_aontop/u_ppu_aon/u_fwram_ppu/u_pck600_ppu_reg/irq_r_reg/CK
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/u_pck600_ppu_reg/irq_r_reg/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_int_col/sync_loop_2_gen_sync_u_sec_cdc_capt_sync/u_arm_element_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_ppu/u_pck600_ppu_reg/irq_r_reg/CK
  u_pd_systop/u_pc_cpu_systop/u_core*_ppu/u_pck600_ppu_reg/irq_r_reg/CK
  u_pd_systop/u_pc_debug_aon_f0_systop/u_sdc600_apbcom_int/u_apbcom/u_apbcom_reg/irq_reg_reg/CK
  u_system_control_f0_aontop/u_firewall_f0_ctlr/u_firewall_f0_ctlr_fctlr_regbank/fc_int_st_r_reg_*/CK
  u_system_control_f0_aontop/u_interrupt_router/u_interrupt_router_reg_bank/shd_int_cfg_ici_en_rw_r_reg_*_*/CK
  u_system_control_f0_aontop/u_s32k_cntbase*/u_gtimer_asyncapb_core_physical/interrupt_out_reg/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_int_col/sync_loop_*_gen_sync_u_sec_cdc_capt_sync/u_arm_element_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_s32k_cntbase*/u_gtimer_asyncapb_core_physical/interrupt_out_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_pactive_on_glitch/has_sync_sync_7_u_pactive_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_ppu/u_pck600_ppu_reg/irq_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_host_control/u_host_ppu_int_st_clustop_int_st_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core*_ppu/u_pck600_ppu_reg/irq_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_host_control/u_host_ppu_int_st_core*_int_st_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_clustop_atb_slv/u_css600_atbasyncbridge_slv_fifo/fifo_data_word_reg_*_*/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_atbasyncbridgemstr/u_css600_atbasyncbridge_mst_fifo/u_cdc_capt_nosync_atid/gen_cdc_capt_nosync_*_u_flop/D
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_atbasyncbridgemstr/u_css600_atbasyncbridge_mst_fifo/u_cdc_capt_nosync_atdata/gen_cdc_capt_nosync_*_u_flop/D
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_atbasyncbridgemstr/u_css600_atbasyncbridge_mst_sync/u_cdc_sync_clear/sync_depth_*_u_cdc_capt_sync_high/D
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_atbasyncbridgemstr/u_css600_atbasyncbridge_mst_fifo/u_cdc_capt_nosync_atbytes/gen_cdc_capt_nosync_*_u_flop/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_atbasyncbridgemstr/u_css600_atbasyncbridge_mst_fifo/rd_ptr_gray_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_clustop_atb_slv/u_css600_atbasyncbridge_slv_sync/u_cdc_rd_ptr_sync_*/sync_depth_*_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
 u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_atbasyncbridgemstr/u_css600_pulseasyncbridgeslv/pulse_req_q_reg_*/CK
}] -to [get_pins {
 u_pd_systop/u_pd_clustop/u_clustop_atb_slv/u_css600_pulseasyncbridgemstr/gen_req_sync_no_cdc_*_u_css600_cdc_capt_sync_req/sync_depth_*_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_crypto_accelerator_aon/u_crypto_accelerator_aon_model/CRYPTOAONCLKOUT
}] -to [get_pins {
  u_clk_ctrl_aondbgctrl/clkqactive_sync_inc_clkqactive_sync_loop_*_u_pck600_sync_qactive/u_cdc_capt_sync/D
  u_system_control_f0_aontop/u_ppu_dbgen_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_system_control_f0_aontop/u_firewall_f0_ctlr/u_bypass_cdc_capt_sync/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_host_cpu_debug_mstr/u_mstr_core/apb_async_resp_payload_r_reg_*/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_apbasyncbridgeslv/u_slv_core/u_cdc_capt_nosync_resp_payload/gen_cdc_capt_nosync_*_u_flop/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_clustop_atb_slv/u_css600_atbasyncbridge_slv_fifo/wrptr_gray_reg_*/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_atbasyncbridgemstr/u_css600_atbasyncbridge_mst_sync/u_cdc_wr_ptr_sync*/sync_depth_*_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_host_cpu_debug_mstr/u_mstr_core/apb_async_ack_r_reg/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_apbasyncbridgeslv/u_ack_sync/sync_depth_2_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_clustop_atb_slv/u_css600_atbasyncbridge_slv_fifo/flush_done_reg/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_atbasyncbridgemstr/u_css600_atbasyncbridge_mst_sync/u_cdc_flush_done_sync/sync_depth_2_u_cdc_capt_sync_high/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_clustop_warmresetn_sync/iresetn_syncdelay_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/u_tsvalue_refclk_resetn_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/IRQS_SS_GEN_*_GEN_IRQS_SYNC_u_cdc_capt_sync_intr0/u_sdff2yrpq/u_arm_sdff2yrpq/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/g_governor_cpu_*_u_governor_cpu/u_governor_cpu_slice/u_ca53_cell_sync12/u_cdc_capt_sync/D
}]


#########
# Resets
#########

# For these reset CDCs, the crossing latency is not critical. However, some
# reset signals do need to be balanced across their sinks, to ensure correct
# operation of the design. Further information about this will be provided in
# the CIM in a future release.

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core*_ppu/u_pck600_ppu_psm/devporesetn_r_reg/CK
  u_pd_systop/u_pc_cpu_systop/u_core*_ppu/u_pck600_ppu_psm/devretresetn_r_reg/CK
  u_pd_systop/u_pc_cpu_systop/u_clustop_ppu/u_pck600_ppu_psm/devporesetn_r_reg/CK
  u_pd_systop/u_pc_cpu_systop/u_clustop_ppu/u_pck600_ppu_psm/devwarmresetn_r_reg/CK
  u_pd_systop/u_pd_clustop/u_clustop_poresetn_refclk_sync/u_sdff2yrpq/u_arm_sdff2yrpq/CK
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_pwr_ctrl/u_pck600_ppu_sse710_secenc/u_pck600_ppu_psm/devwarmresetn_r_reg/CK
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_ppu/u_pck600_ppu_psm/devwarmresetn_r_reg/CK
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/u_pck600_ppu_psm/devwarmresetn_r_reg/CK
}] -to [get_clocks {
  CPUPLL
  CPUPLL_HOSTCPUCLK_1
  REFCLK
  S32KCLK
  SYSPLL
  SYSPLL_ACLK_2
  SYSPLL_CTRLCLK_2
  SYSPLL_DBGCLK_4
  SYSPLL_GICCLK_2
  SYSPLL_HOSTCPUCLK_1
  SYSPLL_SECENCCLK_4
  TRACECLKIN
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/secporesetn_r_reg/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_secencclk_aon_secenc_clk/u_clkrst_f1_clkdiv_modulate_top_syspll/u_clkrst_f1_rstsync_clkin_buf/u_arm_element_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_secencclk_aon_secenc_clk/u_clkrst_f1_clkdiv_modulate_top_syspll/u_clkrst_f1_rstsync_clkin_buf_n/u_arm_element_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_secencclk_aon_secenc_clk/u_clkselnway_f0_2/u_clkselNway_f0_rstsync_clk0/u_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_secencclk_aon_secenc_clk/u_clkselnway_f0_2/u_clkselNway_f0_rstsync_clk1/u_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_secencclk_secenc_clk/u_e_clk_f1_reset_sync_dct_cg/u_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_secencdivclk_i_secenc_clk/u_clkrst_f1_clkdiv_modulate_top_secencdivclk_i/u_clkrst_f1_rstsync_clkin_buf/u_arm_element_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_secencdivclk_i_secenc_clk/u_clkrst_f1_clkdiv_modulate_top_secencdivclk_i/u_clkrst_f1_rstsync_clkin_buf_n/u_arm_element_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_secencdivclk_secenc_clk/u_e_clk_f1_reset_sync_dct_cg/u_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_reset_sync_0/u_arm_element_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_reset_refclk_sync/u_sdff2yrpq/u_arm_sdff2yrpq/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_clk_f1_top_uartclk/u_e_clk_f1_unit_hostuartclk_uartclk/u_clkrst_f1_clkdiv_modulate_top_uartclk/u_clkrst_f1_rstsync_clkin_buf/u_arm_element_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
  u_system_control_f0_aontop/u_clk_f1_top_uartclk/u_e_clk_f1_unit_hostuartclk_uartclk/u_clkrst_f1_clkdiv_modulate_top_uartclk/u_clkrst_f1_rstsync_clkin_buf_n/u_arm_element_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
  u_system_control_f0_aontop/u_clk_f1_top_uartclk/u_e_clk_f1_unit_hostuartclk_uartclk/u_clkselnway_f0_3/u_clkselNway_f0_rstsync_clk1/u_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
  u_system_control_f0_aontop/u_clk_f1_top_uartclk/u_e_clk_f1_unit_hostuartclk_uartclk/u_clkselnway_f0_3/u_clkselNway_f0_rstsync_clk2/u_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/aontopwarmresetn_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_reset_refclk_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
  u_system_control_f0_aontop/u_reset_uart_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
  u_system_control_f0_aontop/u_pcgs/sync_loop_0_u_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
  u_system_control_f0_aontop/u_pcgs/sync_loop_1_u_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
}]

####################
# Clock Module CDCs
####################

# For these clock module CDCs, the crossing latency is not critical, and
# crossing path delays do not need to be balanced. It is enough to just
# constrain the paths with a loose maximum delay constraint.

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_clk_gen_dbgclk/u_e_clk_f1_unit_dbgclk_dbgtop/u_clkselnway_f0_2/iclk*off_delay_reg/CK
  u_pd_systop/u_clk_gen_systop/u_e_clk_f1_unit_aclk_systop/u_clkselnway_f0_2/iclk*off_delay_reg/CK
  u_pd_systop/u_clk_gen_systop/u_e_clk_f1_unit_ctrlclk_systop/u_clkselnway_f0_2/iclk*off_delay_reg/CK
  u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_gicclk_clustop/u_clkselnway_f0_2/iclk*off_delay_reg/CK
  u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_hostcpuclk_clustop/u_clkselnway_f0_3/iclk*off_delay_reg/CK
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_secencclk_aon_secenc_clk/u_clkselnway_f0_2/iclk*off_delay_reg/CK
  u_system_control_f0_aontop/u_clk_f1_top_uartclk/u_e_clk_f1_unit_hostuartclk_uartclk/u_clkselnway_f0_3/iclk*off_delay_reg/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_clk_gen_dbgclk/u_e_clk_f1_unit_dbgclk_dbgtop/u_clkselnway_f0_2/u_clkselNway_f0_cdc_capt_sync_clk*Offclk*/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_systop/u_clk_gen_systop/u_e_clk_f1_unit_aclk_systop/u_clkselnway_f0_2/u_clkselNway_f0_cdc_capt_sync_clk*Offclk*/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_systop/u_clk_gen_systop/u_e_clk_f1_unit_ctrlclk_systop/u_clkselnway_f0_2/u_clkselNway_f0_cdc_capt_sync_clk*Offclk*/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_gicclk_clustop/u_clkselnway_f0_2/u_clkselNway_f0_cdc_capt_sync_clk*Offclk*/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_hostcpuclk_clustop/u_clkselnway_f0_3/u_clkselNway_f0_cdc_capt_sync_clk*Offclk*/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_secencclk_aon_secenc_clk/u_clkselnway_f0_2/u_clkselNway_f0_cdc_capt_sync_clk*Offclk*/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_system_control_f0_aontop/u_clk_f1_top_uartclk/u_e_clk_f1_unit_hostuartclk_uartclk/u_clkselnway_f0_3/u_clkselNway_f0_cdc_capt_sync_clk*Offclk*/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/aclk_ctrl_clkselect_reg_*/CK
  u_system_control_f0_aontop/u_host_control/ctrlclk_ctrl_clkselect_reg_*/CK
  u_system_control_f0_aontop/u_host_control/dbgclk_ctrl_clkselect_reg_*/CK
  u_system_control_f0_aontop/u_host_control/gicclk_ctrl_clkselect_reg_*/CK
  u_system_control_f0_aontop/u_host_control/hostcpuclk_ctrl_clkselect_reg_*/CK
  u_system_control_f0_aontop/u_host_control/hostuartclk_ctrl_clkselect_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_clk_gen_systop/u_e_clk_f1_unit_aclk_systop/u_clkselnway_f0_2/u_clkselNway_f0_cdc_capt_sync_select*clk*/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_systop/u_clk_gen_systop/u_e_clk_f1_unit_ctrlclk_systop/u_clkselnway_f0_2/u_clkselNway_f0_cdc_capt_sync_select*clk*/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_dbgtop_f0/u_clk_gen_dbgclk/u_e_clk_f1_unit_dbgclk_dbgtop/u_clkselnway_f0_2/u_clkselNway_f0_cdc_capt_sync_select*clk*/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_gicclk_clustop/u_clkselnway_f0_2/u_clkselNway_f0_cdc_capt_sync_select*clk*/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_hostcpuclk_clustop/u_clkselnway_f0_3/u_clkselNway_f0_cdc_capt_sync_select*clk*/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_system_control_f0_aontop/u_clk_f1_top_uartclk/u_e_clk_f1_unit_hostuartclk_uartclk/u_clkselnway_f0_3/u_clkselNway_f0_cdc_capt_sync_select*clk*/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_hostcpuclk_clustop/u_clkrst_f1_clkdiv_modulate_top_cpupll/u_clkrst_f1_clkdiv_modulate/idivratio_cur_delay_reg_*/CK
  u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_gicclk_clustop/u_clkrst_f1_clkdiv_modulate_top_syspll/u_clkrst_f1_clkdiv_modulate/idivratio_cur_delay_reg_*/CK
  u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_hostcpuclk_clustop/u_clkrst_f1_clkdiv_modulate_top_syspll/u_clkrst_f1_clkdiv_modulate/idivratio_cur_delay_reg_*/CK
  u_pd_systop/u_clk_gen_systop/u_e_clk_f1_unit_ctrlclk_systop/u_clkrst_f1_clkdiv_modulate_top_syspll/u_clkrst_f1_clkdiv_modulate/idivratio_cur_delay_reg_*/CK
  u_pd_systop/u_clk_gen_systop/u_e_clk_f1_unit_aclk_systop/u_clkrst_f1_clkdiv_modulate_top_syspll/u_clkrst_f1_clkdiv_modulate/idivratio_cur_delay_reg_*/CK
  u_pd_dbgtop_f0/u_clk_gen_dbgclk/u_e_clk_f1_unit_dbgclk_dbgtop/u_clkrst_f1_clkdiv_modulate_top_syspll/u_clkrst_f1_clkdiv_modulate/idivratio_cur_delay_reg_*/CK
  u_system_control_f0_aontop/u_clk_f1_top_uartclk/u_e_clk_f1_unit_hostuartclk_uartclk/u_clkrst_f1_clkdiv_modulate_top_uartclk/u_clkrst_f1_clkdiv_modulate/idivratio_cur_delay_reg_*/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_host_control/u_hostcpuclk_div*_clkdiv_cur_*_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_system_control_f0_aontop/u_host_control/u_gicclk_div*_clkdiv_cur_*_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_system_control_f0_aontop/u_host_control/u_ctrlclk_div*_clkdiv_cur_*_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_system_control_f0_aontop/u_host_control/u_aclk_div*_clkdiv_cur_*_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_system_control_f0_aontop/u_host_control/u_dbgclk_div*_clkdiv_cur_*_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_system_control_f0_aontop/u_host_control/u_hostuartclk_div*_clkdiv_cur_*_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_clk_gen_dbgclk/u_e_clk_f1_unit_dbgclk_dbgtop/u_clkselnway_f0_2/iclk1off_delay_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_host_control/u_dbgclk_ctrl_clkselect_cur_1_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_clk_gen_systop/u_e_clk_f1_unit_aclk_systop/u_clkselnway_f0_2/iclk1off_delay_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_host_control/u_aclk_ctrl_clkselect_cur_1_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_clk_gen_systop/u_e_clk_f1_unit_ctrlclk_systop/u_clkselnway_f0_2/iclk1off_delay_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_host_control/u_ctrlclk_ctrl_clkselect_cur_1_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_gicclk_clustop/u_clkselnway_f0_2/iclk1off_delay_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_host_control/u_gicclk_ctrl_clkselect_cur_1_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# The following clock module CDCs still have no latency requirement, but the
# buses do need to be balanced to within one receiving clock cycle, as the
# signals should be captured no more than one rising clock edge apart.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_hostcpuclk_clustop/u_clkselnway_f0_3/iclk*off_delay_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_host_control/u_hostcpuclk_ctrl_clkselect_cur_*_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_clk_f1_top_uartclk/u_e_clk_f1_unit_hostuartclk_uartclk/u_clkselnway_f0_3/iclk*off_delay_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_host_control/u_hostuartclk_ctrl_clkselect_cur_*_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/aclk_div0_clkdiv_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_clk_gen_systop/u_e_clk_f1_unit_aclk_systop/u_clkrst_f1_clkdiv_modulate_top_syspll/enable_cdc_logic_u_clkrst_f1_clkdiv_cdc_divratio/async_synchronisers_set1_async_sync_flops_*_u_clkrst_f1_cdc_capt_sync_set/u_arm_element_cdc_capt_sync_set/u_arm_sdff2ysq/u_arm_sdff2ysq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/ctrlclk_div0_clkdiv_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_clk_gen_systop/u_e_clk_f1_unit_ctrlclk_systop/u_clkrst_f1_clkdiv_modulate_top_syspll/enable_cdc_logic_u_clkrst_f1_clkdiv_cdc_divratio/async_synchronisers_set1_async_sync_flops_*_u_clkrst_f1_cdc_capt_sync_set/u_arm_element_cdc_capt_sync_set/u_arm_sdff2ysq/u_arm_sdff2ysq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/dbgclk_div0_clkdiv_reg_*/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_clk_gen_dbgclk/u_e_clk_f1_unit_dbgclk_dbgtop/u_clkrst_f1_clkdiv_modulate_top_syspll/enable_cdc_logic_u_clkrst_f1_clkdiv_cdc_divratio/async_synchronisers_set1_async_sync_flops_*_u_clkrst_f1_cdc_capt_sync_set/u_arm_element_cdc_capt_sync_set/u_arm_sdff2ysq/u_arm_sdff2ysq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/gicclk_div0_clkdiv_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_gicclk_clustop/u_clkrst_f1_clkdiv_modulate_top_syspll/enable_cdc_logic_u_clkrst_f1_clkdiv_cdc_divratio/async_synchronisers_set1_async_sync_flops_*_u_clkrst_f1_cdc_capt_sync_set/u_arm_element_cdc_capt_sync_set/u_arm_sdff2ysq/u_arm_sdff2ysq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/hostcpuclk_div*_clkdiv_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_hostcpuclk_clustop/u_clkrst_f1_clkdiv_modulate_top_syspll/enable_cdc_logic_u_clkrst_f1_clkdiv_cdc_divratio/async_synchronisers_set1_async_sync_flops_*_u_clkrst_f1_cdc_capt_sync_set/u_arm_element_cdc_capt_sync_set/u_arm_sdff2ysq/u_arm_sdff2ysq/D
  u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_hostcpuclk_clustop/u_clkrst_f1_clkdiv_modulate_top_cpupll/enable_cdc_logic_u_clkrst_f1_clkdiv_cdc_divratio/async_synchronisers_set1_async_sync_flops_*_u_clkrst_f1_cdc_capt_sync_set/u_arm_element_cdc_capt_sync_set/u_arm_sdff2ysq/u_arm_sdff2ysq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/hostuartclk_div0_clkdiv_reg_*/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_clk_f1_top_uartclk/u_e_clk_f1_unit_hostuartclk_uartclk/u_clkrst_f1_clkdiv_modulate_top_uartclk/enable_cdc_logic_u_clkrst_f1_clkdiv_cdc_divratio/async_synchronisers_set1_async_sync_flops_*_u_clkrst_f1_cdc_capt_sync_set/u_arm_element_cdc_capt_sync_set/u_arm_sdff2ysq/u_arm_sdff2ysq/D
}]


#######################
# Other CDC Max Delays
#######################

# The latencies across these "gray_count" buses must be balanced.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_gray_encode/gray_count_reg_*/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_gray_decode/u_gray_sync/COUNTER_SYNC_*_u_gtimer_countter_cdc_capt_sync_gray_count/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/u_gray_encode_hostcpu/gray_count_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/u_gray_decode_hostcpu/u_gray_sync/COUNTER_SYNC_*_u_gtimer_countter_cdc_capt_sync_gray_count/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_apbasyncbridgeslv/u_slv_core/u_lpislave_pwr/u_css600_lpislave_fsm/state_reg_*/CK
  u_pd_systop/u_pc_debug_aon_f0_systop/u_adb_apb4_slv/u_slv_core/u_lpislave_pwr/u_css600_lpislave_fsm/state_reg_*/CK
  u_pd_systop/u_pc_debug_f0_systop/u_adb_hostsysdbg_slv/u_slv_core/u_lpislave_pwr/u_css600_lpislave_fsm/state_reg_*/CK
  u_pd_systop/u_pc_sysctrl_f0_systop/u_adb_apb4_slv/u_slv_core/u_lpislave_pwr/u_css600_lpislave_fsm/state_reg_*/CK
  u_pd_systop/u_pc_sysctrl_f0_systop/u_adb_uart_apb4_slv/u_slv_core/u_lpislave_pwr/u_css600_lpislave_fsm/state_reg_*/CK
  u_pd_systop/u_pc_sysctrl_f0_systop/u_bootreg_systop/u_css600_apbasyncbridgeslv/u_slv_core/u_lpislave_pwr/u_css600_lpislave_fsm/state_reg_*/CK
}]

# Below are example max delay constraints for CDC path latency between clocks constrained by logically exclusive group SYSPLL_DBGCLK_logically_exclusive. 
# These may not be seen while reporting by the tools if the logically_exclusive clock groups are set in the func.sdc
# Can be adjusted according to performance requirements
# Can be enabled if required and desired by removing clock groups (SYSPLL_DBGCLK_logically_exclusive), but this may degrade tool performance and require additional exceptions
# Alternatively path delay can be reported using the -unconstrained switch or by setting the timing_report_unconstrained_paths variable
# (or in any other way which enables the specific tool to report unconstrained paths) to check the path delay.

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $PERIODS(SYSPLL_SECENCCLK_4) -through [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_crypto_accelerator_aon/u_crypto_accelerator_aon_model/SCB[*]
}] -to [get_clocks {
  REFCLK SECENCCLK_SECENCDIVCLK_2 CPUPLL_HOSTCPUCLK_1 SYSPLL_CTRLCLK_2
  SYSPLL_ACLK_2 SYSPLL_DBGCLK_4
}]

compat_set_max_delay -ignore_clock_latency $PERIODS(SYSPLL_SECENCCLK_4) -through [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_crypto_accelerator_aon/u_crypto_accelerator_aon_model/SCB[*]
}] -to [get_pins {
  u_pd_systop/u_aclk_ctrl/clkqactive_sync_inc_clkqactive_sync_loop_*_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

# Each of the three buses must have balanced delays
# (within 1 destination clock period) - an additional signoff check is needed.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/ctrlclk_ctrl_entrydelay_reg_*/CK
  u_system_control_f0_aontop/u_host_control/aclk_ctrl_entrydelay_reg_*/CK
  u_system_control_f0_aontop/u_host_control/dbgclk_ctrl_entrydelay_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_ctrlclk_ctrl/gen_entrydelay_*_u_pck600_sync_entrydelay/u_cdc_capt_sync/D
  u_pd_systop/u_aclk_ctrl/gen_entrydelay_*_u_pck600_sync_entrydelay/u_cdc_capt_sync/D
  u_pd_dbgtop_f0/u_clk_ctrl_dbgclk/gen_entrydelay_*_u_pck600_sync_entrydelay/u_cdc_capt_sync/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_ppu/u_pck600_ppu_piu/pcsm_pstate_r_reg_*/CK
}] -to [get_pins {
  u_pck600_ppu_pcsm_sse710_clus/pchannel_async_u_pck600_cdc_capt_nosync_pcsm_pstate/BK_CDC_CAPT_NOSYNC_*_u_cdc_capt_nosync_nosync/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/wdogint_s_reg/CK
  u_pd_secenc_f1_top/u_secenc_f1_sepd/u_secenc_f1_core/m0_halted_s_reg/CK
  u_system_control_f0_aontop/u_interrupt_router/u_interrupt_router_reg_bank/int_rtr_tmp_st_ovrflw_rw_r_reg/CK
  u_system_control_f0_aontop/u_interrupt_router/u_interrupt_router_reg_bank/int_rtr_tmp_st_vld_rw_r_reg/CK
  u_system_control_f0_aontop/u_firewall_f0_ctlr/u_firewall_f0_ctlr_fctlr_regbank/FW_TMP_CTRL_LDE_fw_tmp_ctrl_tr_vld_r_reg/CK
  u_system_control_f0_aontop/u_secure_wdog/intr_reg_1/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_cdc_capt_sync_*/u_arm_element_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/reset_syndrome_secenc_sw_rst_req_r_reg/CK
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/reset_syndrome_secenc_wdog_rst_req_r_reg/CK
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/reset_syndrome_poresetn_r_reg/CK
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/reset_syndrome_cdbgrstreq_dp_r_reg/CK
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/reset_syndrome_soc_rst_req_r_reg/CK
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/reset_syndrome_soc_wdog_rst_req_r_reg/CK
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/reset_syndrome_nsrst_r_reg/CK
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/reset_syndrome_csysrstreq_dprom_r_reg/CK
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/reset_syndrome_host_sys_rst_req_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_host_control/u_host_rst_syn_syn_*_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_ctrl_reg/u_sec_cdc_capt_sync_*/u_arm_element_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/host_sys_rst_ack_r_reg_*/CK
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/reset_syndrome_cdbgrstreq_dp_r_reg/CK
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/reset_syndrome_csysrstreq_dprom_r_reg/CK
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/reset_syndrome_host_sys_rst_req_r_reg/CK
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/reset_syndrome_nsrst_r_reg/CK
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/reset_syndrome_poresetn_r_reg/CK
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/reset_syndrome_secenc_sw_rst_req_r_reg/CK
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/reset_syndrome_secenc_wdog_rst_req_r_reg/CK
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/reset_syndrome_soc_rst_req_r_reg/CK
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/reset_syndrome_soc_wdog_rst_req_r_reg/CK
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/soc_rst_syn_r_reg_*/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_chac_reg/u_sec_cdc_capt_sync_*/u_arm_element_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/reset_syndrome_secenc_sw_rst_req_r_reg/CK
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/reset_syndrome_secenc_wdog_rst_req_r_reg/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_ctrl_reg/u_sec_cdc_capt_sync_*/u_arm_element_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/secenccpuwait_r_reg/CK
}] -to [get_pins {
  u_pd_secenc_f1_top/u_secenc_f1_sepd/u_sec_cdc_capt_sync_set/u_arm_element_cdc_capt_sync_set/u_arm_sdff2ysq/u_arm_sdff2ysq/D
}]

# No latency requirements, but the bus should be balanced.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_chac_reg/data_secencclk_ctrl_reg_*/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_secencclk_aon_secenc_clk/u_clkselnway_f0_2/u_clkselNway_f0_cdc_capt_sync_select*clk0/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No latency requirements, but the bus should be balanced.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_chac_reg/data_secencclk_div_reg_*/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_secencclk_aon_secenc_clk/u_clkrst_f1_clkdiv_modulate_top_syspll/enable_cdc_logic_u_clkrst_f1_clkdiv_cdc_divratio/async_synchronisers_set1_async_sync_flops_*_u_clkrst_f1_cdc_capt_sync_set/u_arm_element_cdc_capt_sync_set/u_arm_sdff2ysq/u_arm_sdff2ysq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_chac_reg/data_soc_rst_ctrl_reg/CK
}] -to [get_pins {
  u_reset_controller_f1_top/request_synchronizers_u_cdc_capt_soc_rst_req/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_chac_reg/data_host_sys_rst_ctrl_reg_*/CK
}] -to [get_pins {
  u_reset_controller_f1_top/request_synchronizers_u_cdc_capt_host_sys_rst_req/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_ppu/u_pck600_ppu_psm/ppuhwstat_pwr_mode_r_reg_*/CK
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/u_pck600_ppu_psm/ppuhwstat_pwr_mode_r_reg_*/CK
  u_pd_systop/u_pc_cpu_systop/u_core*_ppu/u_pck600_ppu_psm/ppuhwstat_pwr_mode_r_reg_0/CK
  u_pd_systop/u_pc_cpu_systop/u_clustop_ppu/u_pck600_ppu_psm/ppuhwstat_pwr_mode_r_reg_*/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_chac_reg/u_sec_cdc_capt_sync_*/u_arm_element_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_host_axiap_rom/csyspwrupack_synchroniser_1_u_csyspwrupack_sync/sync_depth_2_u_cdc_capt_sync/D
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_host_rom/cdbgpwrupack_synchroniser_0_u_cdbgpwrupack_sync/sync_depth_2_u_cdc_capt_sync/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_extdbg_rom/u_css600_apbrom_gpr_gpr/cdbgpwrupreq_reg_0/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_pwr_ctrl/u_p_reqack_to_qchan_f0_top/u_p_reqack_to_qchan_f0_cdc_capt_sync_pwrupreq/u_arm_element_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_pwr_ctrl/u_p_reqack_to_qchan_f0_top/state_reg_0/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_extdbg_rom/cdbgpwrupack_synchroniser_0_u_cdbgpwrupack_sync/sync_depth_2_u_cdc_capt_sync/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_repack_axiap_csyspwrupreq0/state_reg_0/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_host_axiap_rom/csyspwrupack_synchroniser_0_u_csyspwrupack_sync/sync_depth_2_u_cdc_capt_sync/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_ports {
  ARVALIDEXPSLV*
  AWAKEUPEXTSYS*MEM
  AWVALIDEXPSLV*
  WVALIDEXPSLV*
}] -to [get_pins {
  u_pd_systop/u_aclk_ctrl/clkqactive_sync_inc_clkqactive_sync_loop_*_u_pck600_sync_qactive/u_cdc_capt_sync/D
  u_pd_systop/u_systop_internal_lpdq/dev_sync_inc_dev_sync_loop_*_u_pck600_sync_qdeny/u_cdc_capt_sync/D
  u_system_control_f0_aontop/u_clk_ctrl_refclk_free/clkqactive_sync_inc_clkqactive_sync_loop_2_u_pck600_sync_qactive/u_cdc_capt_sync/D
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/pactive_input_block_loop_7_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/boot_msk_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_boot_mask_sync*/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# One-hot signals - delay no more than 2 CTRLCLK cycles, no balancing.
compat_set_max_delay -ignore_clock_latency [expr {2.0 * $PERIODS(SYSPLL_CTRLCLK_2)}] -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_ppu/u_pck600_ppu_psm/devclken_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_clustop_pcgs/sync_loop_*_u_enable_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# Delay no more than 1 REFCLK cycle, no balancing.
compat_set_max_delay -ignore_clock_latency $PERIODS(REFCLK) -from [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/u_pck600_ppu_psm/devclken_r_reg/CK
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_ppu/u_pck600_ppu_psm/devclken_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_pcgs/sync_loop_*_u_enable_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# Delay no more than 1 SECENCCLK_SECENCDIVCLK_2 cycle, no balancing.
compat_set_max_delay -ignore_clock_latency $PERIODS(SECENCCLK_SECENCDIVCLK_2) -from [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_pwr_ctrl/u_pck600_ppu_sse710_secenc/u_pck600_ppu_psm/devclken_r_reg/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_32k/u_e_clk_f1_unit_s32kclk_secenc_secenc_32k/u_e_clk_f1_cdc_capt_sync_dct_cg/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_secenc_f1_top/u_secenc_f1_sepd/u_secenc_f1_core/u_CORTEXM0PLUSINTEGRATIONCS/u_imp/u_cortexm0plus/u_top/u_sys/u_nvic/sys_reset_req_q_reg/CK
}] -to [get_pins {
  u_reset_controller_f1_top/request_synchronizers_u_cdc_capt_secenc_sw_rst_req/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_secenc_f1_top/u_secenc_f1_sepd/u_secenc_f1_core/wdog_rst_req_int_s_reg/CK
}] -to [get_pins {
  u_reset_controller_f1_top/request_synchronizers_u_cdc_capt_secenc_wdog_rst_req/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_secencclk_aon_secenc_clk/u_clkselnway_f0_2/iclk0off_delay_reg/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_chac_reg/u_sec_cdc_capt_sync_6/u_arm_element_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No latency requirement, but balance bus.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_secencclk_aon_secenc_clk/u_clkrst_f1_clkdiv_modulate_top_syspll/u_clkrst_f1_clkdiv_modulate/idivratio_cur_delay_reg_*/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_chac_reg/sync_loop_*_u_sec_cdc_capt_sync/u_arm_element_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/g_governor_cpu_*_u_governor_cpu/u_cti/u_cti_ti/ctitrigout_r_reg_2/CK
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/g_governor_cpu_*_u_governor_cpu/u_governor_cpu_slice/npmuirq_rs_o_reg/CK
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/g_governor_cpu_*_u_governor_cpu/u_governor_cpu_slice/ncommirq_rs_o_reg/CK
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53scu/u_scu_master/g_ecc_ninterrirq_reg/CK
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53scu/u_scu_master/nexterrirq_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/IRQS_SS_GEN_*_GEN_IRQS_SYNC_u_cdc_capt_sync_intr0/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/clkforce_reg_*/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_clk_ctrl_dbgclk/u_pck600_sync_clkforce/u_cdc_capt_sync/D
  u_pd_systop/u_aclk_ctrl/u_pck600_sync_clkforce/u_cdc_capt_sync/D
  u_pd_systop/u_ctrlclk_ctrl/u_pck600_sync_clkforce/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/host_lock_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/GEN_INTR_SYNC_*_u_cdc_capt_sync_cp15sdisable/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/u_cdc_capt_sync_cfgsdisable/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/pe*_config_cfgend_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/GEN_INTR_SYNC_*_u_cdc_capt_sync_cfgend/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/pe*_config_cfgte_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/GEN_INTR_SYNC_*_u_cdc_capt_sync_cfgte/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/pe*_config_vinithi_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/GEN_INTR_SYNC_*_u_cdc_capt_sync_vinithi/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_pc_aontop_f0_dbgtop/u_css600_pulseasyncbridgeslv_counter/pulse_req_q_reg_*/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_s32k_gcounter/u_gcounter_asyncapb_counter/u_gct_synchronizer_restartreq/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_s32k_gcounter/u_gcounter_asyncapb_counter/u_gct_synchronizer_restartreq/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/CK
  u_pd_systop/u_pd_clustop/u_clustop_atb_slv/u_css600_pulseasyncbridgemstr/pulse_ack_q_reg_0/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_pc_aontop_f0_dbgtop/u_css600_pulseasyncbridgeslv_counter/gen_ack_sync_no_cdc_*_u_css600_cdc_capt_sync_ack/sync_depth_*_u_cdc_capt_sync/D
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_atbasyncbridgemstr/u_css600_pulseasyncbridgeslv/gen_ack_sync_no_cdc_*_u_css600_cdc_capt_sync_ack/sync_depth_*_u_cdc_capt_sync/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53scu/u_clk/g_l2cc_l2flushdone_reg/CK
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53scu/u_clk/standbywfil2_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_hostcpu_l2flushdone_dd_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_systop/u_pc_cpu_systop/u_hostcpu_standbywfil2_dd_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_debug_f0_aontop/u_dpslv/u_css600_dpslv_reg_block/ctrlstat_cdbgrstreq_q_reg/CK
}] -to [get_pins {
  u_reset_controller_f1_top/request_synchronizers_u_cdc_capt_cdbgrstreq_dp/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_soc_cti/u_css600_cti_ti/trigout_int_q_reg_2/CK
}] -to [get_pins {
  u_debug_f0_aontop/u_dpslv/u_css600_dpslv_sync/u_css600_cdc_capt_sync_eventstatus/sync_depth_2_u_cdc_capt_sync/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/cdbgrstack_dp_r_reg/CK
}] -to [get_pins {
  u_debug_f0_aontop/u_dpslv/u_css600_dpslv_sync/u_css600_cdc_capt_sync_cdbgrstack/sync_depth_2_u_cdc_capt_sync/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_repack_dp_cdbgpwrupreq/state_reg_0/CK
}] -to [get_pins {
  u_debug_f0_aontop/u_dpslv/u_css600_dpslv_sync/u_css600_cdc_capt_sync_cdbgpwrupack/sync_depth_2_u_cdc_capt_sync/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pck600_ppu_pcsm_sse710_clus/pcsm_mode_stat_r_reg_1/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_ppu/u_pck600_cdc_capt_nosync_pcsm_mode_stat/BK_CDC_CAPT_NOSYNC_0_u_cdc_capt_nosync_nosync/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_host_axiap_rom/u_css600_apbrom_gpr_gpr/csyspwrupreq_reg_0/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_repack_axiap_csyspwrupreq0/u_p_reqack_to_qchan_f0_cdc_capt_sync_pwrupreq/u_arm_element_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_l2flush_handshake/l2flushreq_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53scu/u_clk/u_ca53_cell_sync_l2flush/u_cdc_capt_sync/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_debug_f0_aontop/u_dprom/u_css600_apbrom_gpr_gpr/csysrstreq_reg/CK
}] -to [get_pins {
  u_reset_controller_f1_top/request_synchronizers_u_cdc_capt_csysrstreq_dprom/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_pc_aontop_f0_dbgtop/u_css600_pulseasyncbridgeslv_counter/pulse_req_q_reg_*/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_refclk_gcounter/u_gcounter_syncapb_counter/u_restartreq_sync/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_secenc_f1_top/u_secenc_f1_sepd/u_secenc_f1_core/u_sec_systick/toggle_reg/CK
}] -to [get_pins {
  u_pd_secenc_f1_top/u_secenc_f1_sepd/u_secenc_f1_core/u_sec_systick/u_sec_cdc_capt_sync/u_arm_element_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No latency requirement, but balance bus.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_chac_reg/chs_pwr_req_systop_r_reg_*/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_secenc_bsys_pwr_req_systop_pwr_sync*/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_firewall_f0_ctlr/u_firewall_f0_ctlr_fctlr_regbank/fw_global_int_st_reg/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_int_col/sync_loop_0_gen_sync_u_sec_cdc_capt_sync/u_arm_element_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/ext_sys0_rst_ctrl_rst_req_reg/CK
}] -to [get_pins {
  u_reset_controller_f1_top/request_synchronizers_GEN_EXTSYS_REQ_SYNC_0_u_cdc_capt_extsys_rst_req/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/ext_sys1_rst_ctrl_rst_req_reg/CK
}] -to [get_pins {
  u_reset_controller_f1_top/request_synchronizers_GEN_EXTSYS_REQ_SYNC_1_u_cdc_capt_extsys_rst_req/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_refclk_gcounter/u_gcounter_syncapb_counter/u_restartreq_sync/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_pc_aontop_f0_dbgtop/u_css600_pulseasyncbridgeslv_counter/gen_ack_sync_no_cdc_0_u_css600_cdc_capt_sync_ack/sync_depth_2_u_cdc_capt_sync/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_host_axiap_rom/u_css600_apbrom_gpr_gpr/csyspwrupreq_reg_1/CK
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_host_rom/u_css600_apbrom_gpr_gpr/cdbgpwrupreq_reg_0/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_axiap_csyspwrup_reqack/u_p_reqack_to_qchan_f0_cdc_capt_sync_pwrupreq/u_arm_element_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_systop/u_pc_cpu_systop/u_hostrom_cdbgpwrup_reqack/u_p_reqack_to_qchan_f0_cdc_capt_sync_pwrupreq/u_arm_element_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_axiap_csyspwrup_reqack/state_reg_0/CK
  u_pd_systop/u_pc_cpu_systop/u_hostrom_cdbgpwrup_reqack/state_reg_0/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_host_axiap_rom/csyspwrupack_synchroniser_1_u_csyspwrupack_sync/sync_depth_2_u_cdc_capt_sync/D
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_host_rom/cdbgpwrupack_synchroniser_0_u_cdbgpwrupack_sync/sync_depth_2_u_cdc_capt_sync/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/l2rstdisable_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53scu/u_config/g_l2rstdisable_config_l2rstdisable_reg/D
}]

# No balancing requirements, but ensure latency less than 1 SYSPLL_CTRLCLK_2 cycle.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/g_governor_cpu_*_u_governor_cpu/u_governor_cpu_slice/dbgnopwrdwn_o_reg/CK
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/g_governor_cpu_*_u_governor_cpu/u_governor_cpu_slice/dbgrstreq_o_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core*_pactive_offemu_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_systop/u_pc_cpu_systop/u_core*_pactive_warmrst_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# Below sets of paths have to be captured in the same order as they are launched
#
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_clocks {
  CPUPLL_HOSTCPUCLK_1
}] -to [get_clocks {
  SYSPLL_ACLK_2 SYSPLL_CTRLCLK_2
}] -through [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/g_governor_cpu_*_u_governor_cpu/u_governor_cpu_slice/warmrstreq_o_reg/Q
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/g_governor_cpu_*_u_governor_cpu/u_governor_cpu_slice/gov_smpen_o_reg/Q
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/g_governor_cpu_*_u_governor_cpu/u_governor_cpu_power/cpuqactive_o_reg/Q
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/u_governor_slice/standbywfi_o_reg*/Q
}]

# These data-data checks have been added to make sure that the data arrives at the destination flops in the correct order.
# The implementation has to make sure that they are also captured in the same order.
# That is, the clock skew between these pairs of destination flops MUST be less than (CPU_CLOCK_PERIOD - FLOP_SETUP_TIME - FLOP_HOLD_TIME)

set DATA_CHK_VAL 0

set_data_check -clock CPUPLL_HOSTCPUCLK_1 -setup $DATA_CHK_VAL -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core0_standbywfi_sync/u_arm_sdff2ysq/u_arm_sdff2ysq/D
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core0_warmrstreq_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

set_data_check -clock CPUPLL_HOSTCPUCLK_1 -setup $DATA_CHK_VAL -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core0_cpuqactive_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core0_smpen_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

set_data_check -clock CPUPLL_HOSTCPUCLK_1 -setup $DATA_CHK_VAL -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core0_standbywfi_sync/u_arm_sdff2ysq/u_arm_sdff2ysq/D
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core0_smpen_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

set_data_check -clock CPUPLL_HOSTCPUCLK_1 -setup $DATA_CHK_VAL -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core1_standbywfi_sync/u_arm_sdff2ysq/u_arm_sdff2ysq/D
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core1_warmrstreq_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

set_data_check -clock CPUPLL_HOSTCPUCLK_1 -setup $DATA_CHK_VAL -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core1_cpuqactive_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core1_smpen_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

set_data_check -clock CPUPLL_HOSTCPUCLK_1 -setup $DATA_CHK_VAL -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core1_standbywfi_sync/u_arm_sdff2ysq/u_arm_sdff2ysq/D
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core1_smpen_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

set_data_check -clock CPUPLL_HOSTCPUCLK_1 -setup $DATA_CHK_VAL -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core2_standbywfi_sync/u_arm_sdff2ysq/u_arm_sdff2ysq/D
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core2_warmrstreq_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

set_data_check -clock CPUPLL_HOSTCPUCLK_1 -setup $DATA_CHK_VAL -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core2_cpuqactive_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core2_smpen_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

set_data_check -clock CPUPLL_HOSTCPUCLK_1 -setup $DATA_CHK_VAL -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core2_standbywfi_sync/u_arm_sdff2ysq/u_arm_sdff2ysq/D
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core2_smpen_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

set_data_check -clock CPUPLL_HOSTCPUCLK_1 -setup $DATA_CHK_VAL -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core3_standbywfi_sync/u_arm_sdff2ysq/u_arm_sdff2ysq/D
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core3_warmrstreq_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

set_data_check -clock CPUPLL_HOSTCPUCLK_1 -setup $DATA_CHK_VAL -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core3_cpuqactive_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core3_smpen_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

set_data_check -clock CPUPLL_HOSTCPUCLK_1 -setup $DATA_CHK_VAL -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core3_standbywfi_sync/u_arm_sdff2ysq/u_arm_sdff2ysq/D
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core3_smpen_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/g_governor_cpu_*_u_governor_cpu/u_governor_cpu_slice/warmrstreq_o_reg/CK
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/u_governor_slice/standbywfi_o_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core*_pactive_warmrst_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_hostcpu_corewakeup_pulse/pulse_ack_q_reg_*/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_host_control/u_modify_lock_ack_ss_*/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/modify_lock_req_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_hostcpu_corewakeup_pulse/gen_req_sync_no_cdc_*_u_css600_cdc_capt_sync_req/sync_depth_2_u_cdc_capt_sync/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/host_lock_reg_*/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_host_control/u_host_lock*_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_clustop_atb_slv/u_css600_atbasyncbridge_slv_fifo/sync_clear_reg/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_atbasyncbridgemstr/u_css600_pulseasyncbridgeslv/u_css600_cdc_capt_sync_pwr_qreq_n/sync_depth_2_u_cdc_capt_sync/D
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_atbasyncbridgemstr/u_css600_atbasyncbridge_mst_sync/u_cdc_sync_clear/sync_depth_2_u_cdc_capt_sync_high/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys0top/u_pc_eh_f0_extsystrace/u_css600_atbasyncbridgeslv/u_css600_atbasyncbridge_slv_fifo/sync_clear_reg/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_pc_eh0_f0_dbgtop/u_css600_atbasyncbridgemstr/u_css600_pulseasyncbridgeslv/u_css600_cdc_capt_sync_pwr_qreq_n/sync_depth_2_u_cdc_capt_sync/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys1top/u_pc_eh_f0_extsystrace/u_css600_atbasyncbridgeslv/u_css600_atbasyncbridge_slv_fifo/sync_clear_reg/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_pc_eh1_f0_dbgtop/u_css600_atbasyncbridgemstr/u_css600_pulseasyncbridgeslv/u_css600_cdc_capt_sync_pwr_qreq_n/sync_depth_2_u_cdc_capt_sync/D
}]

# No balancing or latency requirements.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_chac_reg/data_chs_pwr_req_reg_2/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_ppu/pactive_input_block_loop_8_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

# No balancing or latency requirements
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_s32k_cntbase0/u_gtimer_asyncapb_core_physical/interrupt_out_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/pactive_input_block_loop_7_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_protocol_quiescent/read_write_quiescent_q_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_pactive_on_glitch/has_sync_sync_7_u_pactive_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/fsm_en_r_reg_*/CK
}] -to [get_pins {
  u_reset_controller_f1_top/GEN_EXTSYS_LPD_Q_0_u_extsys_hostsys_lpd_q/ctrl_sync_inc_u_pck600_sync_qreqn/u_cdc_capt_sync/D
  u_system_control_f0_aontop/u_host_control/u_set_extsys0_cpuwait_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_system_control_f0_aontop/u_host_control/u_ext_sys0_rst_st_rst_ack_*_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D  
  u_reset_controller_f1_top/GEN_EXTSYS_LPD_Q_1_u_extsys_hostsys_lpd_q/ctrl_sync_inc_u_pck600_sync_qreqn/u_cdc_capt_sync/D
  u_system_control_f0_aontop/u_host_control/u_set_extsys1_cpuwait_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_system_control_f0_aontop/u_host_control/u_ext_sys1_rst_st_rst_ack_*_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D  
}]

# No balancing or latency requirements
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/aontoppo_aontopwarm_qreqn_r_reg/CK
}] -to [get_pins {
  u_reset_controller_f1_top/u_aontoppo_aontopwarm_lpd_q/ctrl_sync_inc_u_pck600_sync_qreqn/u_cdc_capt_sync/D
}]

# No balancing or latency requirements
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/secenc_hostsys_qreqn_r_reg/CK
}] -to [get_pins {
  u_reset_controller_f1_top/u_secenc_hostsys_lpd_q/ctrl_sync_inc_u_pck600_sync_qreqn/u_cdc_capt_sync/D
}]

# No balancing or latency requirements
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_aontoppo_aontopwarm_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/ctrl_qacceptn_r_reg/CK
}] -to [get_pins {
  u_reset_controller_f1_top/q_ch_synchronizers_u_aontoppo_aontopwarm_qacceptn_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/GEN_EXTSYS_LPD_Q_0_u_extsys_hostsys_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/ctrl_qacceptn_r_reg/CK
}] -to [get_pins {
  u_reset_controller_f1_top/q_ch_synchronizers_GEN_EXTSYS_QCH_SYNC_0_u_extsys_hostsys_qacceptn_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/GEN_EXTSYS_LPD_Q_1_u_extsys_hostsys_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/ctrl_qacceptn_r_reg/CK
}] -to [get_pins {
  u_reset_controller_f1_top/q_ch_synchronizers_GEN_EXTSYS_QCH_SYNC_1_u_extsys_hostsys_qacceptn_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_secenc_hostsys_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/ctrl_qdeny_r_reg/CK
}] -to [get_pins {
  u_reset_controller_f1_top/q_ch_synchronizers_u_secenc_hostsys_qdeny_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_aontoppo_aontopwarm_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/ctrl_qdeny_r_reg/CK
}] -to [get_pins {
  u_reset_controller_f1_top/q_ch_synchronizers_u_aontoppo_aontopwarm_qdeny_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/GEN_EXTSYS_LPD_Q_0_u_extsys_hostsys_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/ctrl_qdeny_r_reg/CK
}] -to [get_pins {
  u_reset_controller_f1_top/q_ch_synchronizers_GEN_EXTSYS_QCH_SYNC_0_u_extsys_hostsys_qdeny_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/GEN_EXTSYS_LPD_Q_1_u_extsys_hostsys_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/ctrl_qdeny_r_reg/CK
}] -to [get_pins {
  u_reset_controller_f1_top/q_ch_synchronizers_GEN_EXTSYS_QCH_SYNC_1_u_extsys_hostsys_qdeny_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# No balancing or latency requirements
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_secenc_hostsys_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/ctrl_qacceptn_r_reg/CK
}] -to [get_pins {
  u_reset_controller_f1_top/q_ch_synchronizers_u_secenc_hostsys_qacceptn_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_s32k_cntbase1/u_gtimer_asyncapb_core_physical/interrupt_out_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/pactive_input_block_loop_7_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_base_systop/u_fc_*/u_bas_reg_regslice/u_dti_reg_slice/reg_busy_dn_i_reg_*/CK
  u_pd_systop/u_base_systop/u_fc_ic/u_sse710_bas_switch_16x1/u_bas_switch_core/twakeup_dti_dn_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/pactive_input_block_loop_*_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/hostcpu_axi_slv_wakeups_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_pactive_on_glitch/has_sync_sync_7_u_pactive_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/extsys_fsm_0_u_extsysrst_fsm/qreqn_r_reg/CK
}] -to [get_pins {
  u_reset_controller_f1_top/GEN_EXTSYS_LPD_Q_0_u_extsys_hostsys_lpd_q/ctrl_sync_inc_u_pck600_sync_qreqn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/extsys_fsm_1_u_extsysrst_fsm/qreqn_r_reg/CK
}] -to [get_pins {
  u_reset_controller_f1_top/GEN_EXTSYS_LPD_Q_1_u_extsys_hostsys_lpd_q/ctrl_sync_inc_u_pck600_sync_qreqn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/u_governor_ctm/ctm_ctichout_reg_3/CK
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/u_governor_ctm/ctm_ctichout_reg_2/CK
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/u_governor_ctm/ctm_ctichout_reg_1/CK
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/u_governor_ctm/ctm_ctichout_reg_0/CK
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53scu/u_clk/standbywfil2_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_pactive_on_glitch/has_sync_sync_7_u_pactive_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_pulseasyncbridgeslv_hostcpuctichout/gen_req_sync_no_cdc_*_u_css600_cdc_capt_sync_req/sync_depth_*_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/extsys_hostsys_qreqn_r_reg_0/CK
}] -to [get_pins {
  u_reset_controller_f1_top/GEN_EXTSYS_LPD_Q_0_u_extsys_hostsys_lpd_q/ctrl_sync_inc_u_pck600_sync_qreqn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/extsys_hostsys_qreqn_r_reg_1/CK
}] -to [get_pins {
  u_reset_controller_f1_top/GEN_EXTSYS_LPD_Q_1_u_extsys_hostsys_lpd_q/ctrl_sync_inc_u_pck600_sync_qreqn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/gen_mhu_esxh_1_u_mhuv2_f1_sender_esxh_1/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
}] -to [get_pins {
  u_pd_systop/u_aclk_ctrl/clkqactive_sync_inc_clkqactive_sync_loop_27_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_debug_f0_aontop/u_gpio_apb/gpio_out_reg_reg_0/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_crypto_accelerator_aon/u_crypto_accelerator_aon_model/CALC
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys1top/u_pc_eh_f0_extsyscti/u_css600_pulseasyncbridgeslv/pulse_req_q_reg_2/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_clk_ctrl_dbgclk/clkqactive_sync_inc_clkqactive_sync_loop_9_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys0top/u_pc_eh_f0_extsysmem/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/slvmustacceptreqn_q_reg/CK
}] -to [get_pins {
  u_pd_systop/u_aclk_ctrl/clkqactive_sync_inc_clkqactive_sync_loop_26_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_base_systop/u_fc_5/u_regslice_m/awakeup_o_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/pactive_input_block_loop_8_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/gen_mhu_esxh_1_u_mhuv2_f1_sender_esxh_1/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_clk_ctrl_refclk_free/clkqactive_sync_inc_clkqactive_sync_loop_4_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_0/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_systop_ingress_qreqn_pactive_on_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys1top/u_pc_eh_f0_extsysextdbg/u_css600_apbasyncbridgeslv/u_slv_core/apb_async_req_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_clk_ctrl_refclk_free/clkqactive_sync_inc_clkqactive_sync_loop_2_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/gen_mhu_esxh_1_u_mhuv2_f1_sender_esxh_1/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_clk_ctrl_refclk_int/clkqactive_sync_inc_clkqactive_sync_loop_17_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys0top/u_pc_eh_f0_extsysextdbg/u_css600_apbasyncbridgeslv/u_slv_core/apb_async_req_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_clk_ctrl_refclk_free/clkqactive_sync_inc_clkqactive_sync_loop_1_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_pulseasyncbridgeslv_hostcpuctichin/pulse_req_q_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_ctichin_pulseasyncbridge_mstr/gen_req_sync_no_cdc_*_u_css600_cdc_capt_sync_req/sync_depth_2_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_ingress_lpd_q/gen_expander_u_pck600_lpd_q_expander_core/dev_qreqn_r_reg_0/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_ingress_cti_qreqn_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/core_power_handshake_logic_*_u_core_power_handshake/u_core_p2q/u_p2q_core/ctrl_paccept_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_pck600_lpd_p_core*_power_handshake/dev0_sync_inc_u_pck600_sync_dev0_paccept/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/core_power_handshake_logic_*_u_core_power_handshake/u_core_p2q/u_p2q_core/ctrl_pdeny_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_pck600_lpd_p_core*_power_handshake/dev0_sync_inc_u_pck600_sync_dev0_pdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core*_dbgpwrdup_gen/u_p2q_core/dev_qreqn_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/GEN_INTR_SYNC_*_u_cdc_capt_sync_dbgpwrdup/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/g_governor_cpu_*_u_governor_cpu/u_governor_cpu_timers/msk_cnthpirq_rs_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/GEN_INTR_SYNC_*_u_cdc_capt_sync_intr7/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/g_governor_cpu_*_u_governor_cpu/u_governor_cpu_timers/msk_cntpnsirq_rs_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/GEN_INTR_SYNC_*_u_cdc_capt_sync_intr5/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/g_governor_cpu_*_u_governor_cpu/u_governor_cpu_timers/msk_cntpsirq_rs_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/GEN_INTR_SYNC_*_u_cdc_capt_sync_intr4/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/g_governor_cpu_*_u_governor_cpu/u_governor_cpu_timers/msk_cntvirq_rs_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/GEN_INTR_SYNC_*_u_cdc_capt_sync_intr6/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_ctichin_pulseasyncbridge_mstr/pulse_ack_q_reg_*/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_pulseasyncbridgeslv_hostcpuctichin/gen_ack_sync_no_cdc_*_u_css600_cdc_capt_sync_ack/sync_depth_2_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_ctichin_pulseasyncbridge_slv/pwr_qaccept_n_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_0_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -through [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_crypto_accelerator_aon/u_crypto_accelerator_aon_model/SCB[*]
}] -to [get_pins {
  u_debug_f0_aontop/u_arm_element_cdc_capt_sync_*/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_dbgtop_f0/u_arm_element_cdc_capt_sync_*/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_systop/u_pc_cpu_systop/u_dbgen_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_systop/u_base_systop/u_fc_*/u_bypass_cdc_capt_sync/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_systop/u_base_systop/u_base_aclk_lpdq/active_deny_support_active_deny_sync_inc_u_pck600_dev_qactive/u_cdc_capt_sync/D
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/g_governor_cpu_*_u_governor_cpu/u_governor_cpu_slice/u_ca53_cell_sync*/u_cdc_capt_sync/D
}]

# Must be hand balanced to within a single cycle.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/g_governor_cpu_*_u_governor_cpu/u_governor_cpu_power/cpuqactive_o_reg/CK
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/g_governor_cpu_*_u_governor_cpu/u_governor_cpu_debug/dbgpwrupreq_reg/CK
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/u_governor_slice/standbywfi_o_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core*_pactive_offemu_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_systop/u_pc_cpu_systop/u_core*_pactive_on_glitch/has_sync_sync_*_u_pactive_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_pd_systop/u_pc_cpu_systop/u_core*_dbgpwrupreq_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/g_governor_cpu_*_u_governor_cpu/u_governor_cpu_power/cpuqactive_o_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core*_pactive_on_glitch/has_sync_sync_*_u_pactive_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

# Must be balanced to within a single cycle.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core*_lpd_p/u_lpd_p_diu/gen_sequencer_g_seq_sm_0_u_seq_sm/dev_pstate_r_reg_*/CK
  u_pd_systop/u_pc_cpu_systop/u_core*_lpd_p/u_lpd_p_diu/gen_sequencer_g_seq_sm_0_u_seq_sm/dev_preq_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/core_power_handshake_logic_*_u_core_power_handshake/u_core_p2q/dev_sync_inc_u_pck600_sync_qdeny/u_cdc_capt_sync/D
  u_pd_systop/u_pd_clustop/core_power_handshake_logic_*_u_core_power_handshake/u_core_p2q/dev_sync_inc_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
  u_pd_systop/u_pd_clustop/core_power_handshake_logic_*_u_core_power_handshake/u_core_p2q/u_p2q_tinit_sync/u_pck600_nosync_ctrl_pstate/BK_CDC_CAPT_NOSYNC_*_u_cdc_capt_nosync_nosync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_ctichin_pulseasyncbridge_slv/gen_ack_sync_no_cdc_*_u_css600_cdc_capt_sync_ack/sync_depth_2_u_cdc_capt_sync/CK
  u_pd_systop/u_pd_clustop/u_ctichin_pulseasyncbridge_slv/pulse_req_q_reg_*/CK
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_irq_pulseasyncbridgeslv/pulse_req_q_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_pactive_on_glitch/has_sync_sync_7_u_pactive_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/g_governor_cpu_*_u_governor_cpu/u_governor_cpu_slice/gov_smpen_o_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core*_pactive_on_glitch/has_sync_sync_8_u_pactive_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/core_power_handshake_logic_*_u_core_power_handshake/u_sse710_warmrst_check/pdeny_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_pck600_lpd_p_core*_power_handshake/dev1_sync_inc_u_pck600_sync_dev1_pdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/core_power_handshake_logic_*_u_core_power_handshake/u_sse710_warmrst_check/paccept_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_pck600_lpd_p_core*_power_handshake/dev1_sync_inc_u_pck600_sync_dev1_paccept/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_pck600_lpd_p_core*_power_handshake/u_lpd_p_diu/gen_expander_g_exp_sm_inst_*_u_exp_sm/dev_pstate_r_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/core_power_handshake_logic_*_u_core_power_handshake/u_nosync_pstate_warmrst_check/BK_CDC_CAPT_NOSYNC_*_u_sdffrpq/u_arm_sdffrpq/D
  u_pd_systop/u_pd_clustop/core_power_handshake_logic_*_u_core_power_handshake/u_nosync_pstate_power_handshake/BK_CDC_CAPT_NOSYNC_*_u_sdffrpq/u_arm_sdffrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_pck600_lpd_p_core*_power_handshake/u_lpd_p_diu/gen_expander_g_exp_sm_inst_*_u_exp_sm/dev_preq_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/core_power_handshake_logic_*_u_core_power_handshake/u_sync_preq_power_handshake/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_pck600_lpd_p_core*_power_handshake/u_lpd_p_diu/gen_expander_g_exp_sm_inst_*_u_exp_sm/dev_preq_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/core_power_handshake_logic_*_u_core_power_handshake/u_sync_preq_warmrst_check/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/clustop_ingress_cti_double_bridge_qacceptn_ddd_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_0_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/extsys_fsm_*_u_extsysrst_fsm/cpuwait_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_host_control/u_set_extsys*_cpuwait_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/extsys_fsm_*_u_extsysrst_fsm/rst_ack_r_reg_*/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_host_control/u_ext_sys*_rst_st_rst_ack_*_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/se_rst_syn_r_reg_*/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_ctrl_reg/u_sec_cdc_capt_sync_*/u_arm_element_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/csysrstack_dprom_r_reg/CK
}] -to [get_pins {
  u_debug_f0_aontop/u_dprom/u_csysrstack_sync/sync_depth_2_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/aontopwarmresetn_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_pcgs/sync_loop_2_u_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
  u_reset_controller_f1_top/u_aontopwarmreset_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
  u_system_control_f0_aontop/u_reset_refclk_sync_top/u_sdff2yrpq/u_arm_sdff2yrpq/R
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/secporesetn_r_reg/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_reset_sync_2/u_arm_element_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/aontopporesetn_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_reset_refclk_sync_top/u_sdff2yrpq/u_arm_sdff2yrpq/R
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_debug_aon_f0_systop/u_adb_apb4_slv/u_slv_core/apb_async_req_r_reg/CK
}] -to [get_pins {
  u_clk_ctrl_aondbgctrl/clkqactive_sync_inc_clkqactive_sync_loop_*_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_debug_aon_f0_systop/u_sdc600_comasyncbridge_indirect_half_int/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_async2com/u_reg_async_rx_linkup/q_gen_*_u_flop/CK
}] -to [get_pins {
  u_clk_ctrl_aondbgctrl/clkqactive_sync_inc_clkqactive_sync_loop_*_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_base_systop/u_fc_*/u_lpi/u_comp_pwrctrl/qactive_o_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/pactive_input_block_loop_7_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_debug_aon_f0_systop/u_sdc600_comasyncbridge_indirect_half_int/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_com2async/u_reg_async_tx_linkest/q_gen_0_u_flop/CK
  u_pd_systop/u_pc_debug_aon_f0_systop/u_sdc600_comasyncbridge_indirect_half_int/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_com2async/u_reg_async_tx_req/q_gen_0_u_flop/CK
}] -to [get_pins {
  u_clk_ctrl_aondbgctrl/clkqactive_sync_inc_clkqactive_sync_loop_4_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_base_systop/u_fc_*/u_bas_reg_regslice/twakeup_dti_dn_reg/CK
  u_pd_systop/u_pc_debug_aon_f0_systop/u_sdc600_comasyncbridge_indirect_half_int/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_com2async/u_reg_async_tx_req/q_gen_0_u_flop/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/pactive_input_block_loop_*_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_secenc_f1_top/u_secenc_f1_sepd/u_secenc_f1_core/u_sec_periph_integration/u_mhuv2_f1_sender_seh*/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/gen_mhu_esxh_1_u_mhuv2_f1_sender_esxh_1/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_sender_esxh_0/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/gen_mhu_esxh_1_u_mhuv2_f1_sender_esxh_1/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_sender_esxh_0/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
  u_pd_secenc_f1_top/u_secenc_f1_sepd/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_protocol_quiescent/read_write_quiescent_q_reg/CK
  u_pd_secenc_f1_top/u_secenc_f1_sepd/u_secenc_f1_core/u_secenc_f1_fw/u_fw_comp_secenc/u_regslice_s/awakeup_o_reg/CK
  u_pd_dbgtop_f0/u_systop_f0_dbgtop/slv_wakeup_reg/CK
  u_pd_dbgtop_f0/u_systop_f0_dbgtop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst/u_mst/u_protocol_quiescent/read_write_quiescent_q_reg/CK
  u_pd_dbgtop_f0/u_systop_f0_dbgtop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_protocol_quiescent/read_write_quiescent_q_reg/CK
  u_pd_systop/u_pc_debug_aon_f0_systop/u_sdc600_apbcom_int/u_apbcom/u_lpi/GEN_PWR_LPI_pwr_active_internal_reg_reg/CK
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_host_axiap_rom/u_css600_apbrom_gpr_gpr/csyspwrupreq_reg_0/CK
  u_pd_systop/u_pc_debug_aon_f0_systop/u_sdc600_comasyncbridge_indirect_half_int/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_async2com/u_sync_async_rx_linkest/sync_depth_2_u_cdc_capt_sync/CK
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_soc_catu/u_css600_catu_reg_block/it_addrerr_reg/CK
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_soc_catu/u_css600_catu_reg_block/irq_q_reg/CK
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_soc_catu/u_css600_catu_reg_block/itctrl_q_reg/CK
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_soc_etr/u_css600_tmc_core/u_css600_tmc_axi_if_block_u_css600_tmc_axi_if/bufintr_reg/CK
  u_pd_systop/u_pc_sysctrl_f0_systop/u_sse710_adb400_r3_axi4_stream_mst_wrapper/u_adb400_r3_axi4_stream_mst/u_mst/responder_quiescentn_q_reg/CK
  u_pd_systop/u_pc_debug_f0_systop/u_adb_hostsysdbg_slv/u_slv_core/pwrqactive_r_reg/CK
  u_pd_systop/u_pc_cpu_systop/u_clustop_ppu/u_pck600_ppu_psm/ppuhwstat_pwr_mode_r_reg_*/CK
  u_pd_systop/u_pc_sysctrl_f0_systop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_protocol_quiescent/read_write_quiescent_q_reg/CK
  u_pd_systop/u_pc_cpu_systop/u_systop_clustop_dependency_q_chan/pactive_en_reg_*/CK
  u_pd_systop/u_pc_sysctrl_f0_systop/u_adb_uart_apb4_slv/u_slv_core/pwrqactive_r_reg/CK
  u_pd_systop/u_pc_cpu_systop/u_core*_ppu/u_pck600_ppu_reg/irq_r_reg/CK
  u_pd_systop/u_pc_debug_aon_f0_systop/u_adb_apb4_slv/u_slv_core/pwrqactive_r_reg/CK
  u_pd_systop/u_pc_sysctrl_f0_systop/u_adb_apb4_slv/u_slv_core/pwrqactive_r_reg/CK
  u_pd_systop/u_pc_debug_aon_f0_systop/u_sdc600_comasyncbridge_indirect_half_int/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_pwr_lpislave/dev_active_reg_reg/CK
  u_pd_systop/u_pc_sysctrl_f0_systop/u_a4s_slv/u_slv/initiator_quiescentn_q_reg/CK
  u_pd_systop/u_pc_debug_f0_systop/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_protocol_quiescent/read_write_quiescent_q_reg/CK
  u_pd_systop/u_pc_sysctrl_f0_systop/u_bootreg_systop/u_css600_apbasyncbridgeslv/u_slv_core/pwrqactive_r_reg/CK
  u_pd_systop/u_pc_cpu_systop/u_clustop_pactive_on_glitch/pactive_reg_reg_*/CK
  u_pd_systop/u_pc_debug_aon_f0_systop/u_sdc600_apbcom_int/u_apbcom/u_apbcom_reg/irq_reg_reg/CK
  u_pd_systop/u_pc_cpu_systop/u_clustop_ppu/u_pck600_ppu_reg/irq_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/pactive_input_block_loop_*_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_chac_reg/data_host_sys_rst_ctrl_reg_0/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/core_power_handshake_logic_*_u_core_power_handshake/u_sync_cpuwait/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

#Paths from EXTSYS0ACLK <-> SYSPLL_ACLK_2
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys0top/u_pc_eh_f0_extsysmem/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/slvcandenyreqn_q_reg/CK
}] -to [get_pins {
  u_pd_systop/u_aclk_ctrl/clkqactive_sync_inc_clkqactive_sync_loop_26_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

#Paths from EXTSYS0ATCLK <-> SYSPLL_DBGCLK_4
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys0top/u_pc_eh_f0_extsystrace/u_css600_atbasyncbridgeslv/u_css600_atbasyncbridge_slv_fifo/wrptr_gray_reg_3/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_clk_ctrl_dbgclk/clkqactive_sync_inc_clkqactive_sync_loop_9_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

#Paths from EXTSYS0CTICLK <-> SYSPLL_DBGCLK_4
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys0top/u_pc_eh_f0_extsyscti/u_css600_pulseasyncbridgeslv/pulse_req_q_reg_3/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_clk_ctrl_dbgclk/clkqactive_sync_inc_clkqactive_sync_loop_8_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

#Paths from EXTSYS0DBGCLKS <-> REFCLK
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys0top/u_pc_eh_f0_extsysextdbg/u_css600_apbasyncbridgeslv/u_slv_core/apb_async_req_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_clk_ctrl_refclk_free/clkqactive_sync_inc_clkqactive_sync_loop_2_u_pck600_sync_qactive/u_cdc_capt_sync/D
  u_clk_ctrl_aondbgctrl/clkqactive_sync_inc_clkqactive_sync_loop_0_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

#Paths from EXTSYS0MHUCLK <-> SYSPLL_ACLK_2
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/gen_mhu_esxh_1_u_mhuv2_f1_sender_esxh_1/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
}] -to [get_pins {
  u_pd_systop/u_aclk_ctrl/clkqactive_sync_inc_clkqactive_sync_loop_26_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

#Paths from EXTSYS1ACLK <-> SYSPLL_ACLK_2
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys1top/u_pc_eh_f0_extsysmem/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/slvmustacceptreqn_q_reg/CK
}] -to [get_pins {
  u_pd_systop/u_aclk_ctrl/clkqactive_sync_inc_clkqactive_sync_loop_27_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

#Paths from EXTSYS1ATCLK <-> SYSPLL_DBGCLK_4
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys1top/u_pc_eh_f0_extsystrace/u_css600_atbasyncbridgeslv/u_css600_atbasyncbridge_slv_fifo/wrptr_gray_reg_1/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_clk_ctrl_dbgclk/clkqactive_sync_inc_clkqactive_sync_loop_12_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

#Paths from EXTSYS1CTICLK <-> SYSPLL_DBGCLK_4
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys1top/u_pc_eh_f0_extsyscti/u_css600_pulseasyncbridgeslv/pulse_req_q_reg_2/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_clk_ctrl_dbgclk/clkqactive_sync_inc_clkqactive_sync_loop_11_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

#Paths from EXTSYS1DBGCLKS <-> REFCLK
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys1top/u_pc_eh_f0_extsysextdbg/u_css600_apbasyncbridgeslv/u_slv_core/apb_async_req_r_reg/CK
}] -to [get_pins {
  u_clk_ctrl_aondbgctrl/clkqactive_sync_inc_clkqactive_sync_loop_1_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

#Paths from EXTSYS1MHUCLK <-> REFCLK
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/gen_mhu_esxh_1_u_mhuv2_f1_sender_esxh_1/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_clk_ctrl_refclk_free/clkqactive_sync_inc_clkqactive_sync_loop_0_u_pck600_sync_qactive/u_cdc_capt_sync/D
  u_system_control_f0_aontop/u_clk_ctrl_refclk_int/clkqactive_sync_inc_clkqactive_sync_loop_2_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

#Paths from EXTSYS1MHUCLK <-> SYSPLL_ACLK_2
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_receiver_hesx_0/u_mhuv2_f1_adb_posedge_slave/edgereqasync_state_reg_1/CK
}] -to [get_pins {
  u_pd_systop/u_aclk_ctrl/clkqactive_sync_inc_clkqactive_sync_loop_27_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

#Paths from REFCLK <-> CPUPLL_HOSTCPUCLK_1
# Latencies across the "gray_count" signals must be balanced.
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_refclk_gray_encode/gray_count_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/u_gray_decode/u_gray_sync/COUNTER_SYNC_*_u_gtimer_countter_cdc_capt_sync_gray_count/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

#Paths from REFCLK <-> SYSPLL_CTRLCLK_2
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_ns_wdog/intr_reg_0/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_pactive_on_glitch/has_sync_sync_7_u_pactive_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_clustop_dbgtop_ingress_comb/u_lpc_core/ctrl_qacceptn_r_reg_0/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_3_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_clustop_dbgtop_ingress_comb/u_lpc_core/ctrl_qdeny_r_reg_0/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_3_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/host_cpu_wake_up_core*_wakeup_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core*_pactive_on_glitch/has_sync_sync_8_u_pactive_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

#Paths from REFCLK <-> SYSPLL_GICCLK_2
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_fwram_ppu/u_pck600_ppu_reg/irq_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/IRQS_SS_GEN_5_GEN_IRQS_SYNC_u_cdc_capt_sync_intr0/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_firewall_f0_ctlr/u_firewall_f0_ctlr_fctlr_regbank/fw_global_int_st_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/IRQS_SS_GEN_4_GEN_IRQS_SYNC_u_cdc_capt_sync_intr0/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_secure_wdog/intr_reg_0/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/IRQS_SS_GEN_0_GEN_IRQS_SYNC_u_cdc_capt_sync_intr0/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_ns_wdog/intr_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/IRQS_SS_GEN_*_GEN_IRQS_SYNC_u_cdc_capt_sync_intr0/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_interrupt_router/u_interrupt_router_reg_bank/shd_int_cfg_ici_en_rw_r_reg_*_1/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/IRQS_SS_GEN_*_GEN_IRQS_SYNC_u_cdc_capt_sync_intr0/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

#Paths from S32KCLK <-> SYSPLL_GICCLK_2
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_s32k_cntbase*/u_gtimer_asyncapb_core_physical/interrupt_out_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/IRQS_SS_GEN_*_GEN_IRQS_SYNC_u_cdc_capt_sync_intr0/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

#Paths from SWCLKTCK <-> REFCLK
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_debug_f0_aontop/u_dpslv/u_css600_pulseasyncbridgeslv_qactive_only/pulse_req_q_reg_0/CK
}] -to [get_pins {
  u_clk_ctrl_aondbgctrl/clkqactive_sync_inc_clkqactive_sync_loop_2_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

#Paths from UARTCLK_HOSTUARTCLK_1 <-> SYSPLL_CTRLCLK_2
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_uart_subsys/uart0_intr_reg/CK
}] -to [get_pins {
  u_pd_systop/u_ctrlclk_ctrl/clkqactive_sync_inc_clkqactive_sync_loop_0_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_uart_subsys/uart0_intr_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_pactive_on_glitch/has_sync_sync_7_u_pactive_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

#Paths from UARTCLK_HOSTUARTCLK_1 <-> SYSPLL_GICCLK_2
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_uart_subsys/uart*_intr_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/IRQS_SS_GEN_*_GEN_IRQS_SYNC_u_cdc_capt_sync_intr0/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_ctichout_pulseasyncbridge_slv/pulse_req_q_reg_*/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_pc_cpu_f0_dbgtop/u_css600_pulseasyncbridgeslv_hostcpuctichout/gen_req_sync_no_cdc_*_u_css600_cdc_capt_sync_req/sync_depth_2_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_ctichout_pulseasyncbridge_slv/gen_ack_sync_no_cdc_*_u_css600_cdc_capt_sync_ack/sync_depth_2_u_cdc_capt_sync/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_pactive_on_glitch/has_sync_sync_7_u_pactive_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/u_governor_power/l2qactive_o_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_l2_qactive_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/aontopwarmresetn_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_pcgs/sync_loop_0_u_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
  u_system_control_f0_aontop/u_pcgs/sync_loop_1_u_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
  u_system_control_f0_aontop/u_pcg_syspll_systop/sync_loop_0_u_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
  u_system_control_f0_aontop/u_pcg_refclk_systop/sync_loop_0_u_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
  u_system_control_f0_aontop/u_pcg_cpupll/sync_loop_0_u_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/secporesetn_r_reg/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_hintclken_clk_secenc_clk/u_e_clk_f1_reset_sync_dct_cg/u_reset_sync/u_sdff2yrpq/u_arm_sdff2yrpq/R
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_ctichout_pulseasyncbridge_slv/pulse_req_q_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_pactive_on_glitch/has_sync_sync_7_u_pactive_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pd_clustop/u_ctichout_pulseasyncbridge_slv/pwr_qaccept_n_reg/CK
}] -to [get_pins {
  u_clustop_dbgtop_egress_comb/dev_sync_inc_dev_sync_loop_0_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_clustop_dbgtop_egress_comb/u_lpc_core/dev_qreqn_r_reg_0/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_ctichout_pulseasyncbridge_slv/u_css600_cdc_capt_sync_pwr_qreq_n/sync_depth_2_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_eh0_f0_systop/esh_1_ehx_mhuint_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/pactive_input_block_loop_7_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_eh1_f0_systop/esh_1_ehx_mhuint_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/pactive_input_block_loop_7_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_secenc_f0_systop/hse1_mhuint_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/pactive_input_block_loop_7_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/gen_mhu_esxh_1_u_mhuv2_f1_sender_esxh_1/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_eh1_f0_systop/gen_mhu_esxh_1_u_mhuv2_f1_receiver_esxh_1/u_mhuv2_f1_adb_apb3_mst/u_mhuv2_f1_adb_sync_recwakeup_async/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/u_pck600_ppu_psm/devclken_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_pcg_cpupll/sync_loop_0_u_enable_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_egress_dbgtop_comb/u_lpc_core/dev_qreqn_r_reg_0/CK
}] -to [get_pins {
  u_pd_systop/u_pc_debug_f0_systop/u_acg_stm_sequencer/ctrl_sync_inc_u_pck600_sync_qreqn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_interrupt_router/u_interrupt_router_reg_bank/shd_int_cfg_ici_en_rw_r_reg_8_1/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_pactive_on_glitch/has_sync_sync_7_u_pactive_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/host_cpu_clus_pwr_req_mem_ret_req_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_pactive_mem_ret_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_egress_expander/gen_sequencer_u_pck600_lpd_q_sequencer_core/dev_qreqn_r_reg_0/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_systop_ingress_qreqn_pactive_on_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_ppu/u_pck600_ppu_reg/irq_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/IRQS_SS_GEN_5_GEN_IRQS_SYNC_u_cdc_capt_sync_intr0/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys0top/u_pc_eh_f0_extsysmem/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_protocol_quiescent/read_write_quiescent_q_reg/CK
}] -to [get_pins {
  u_pd_systop/u_aclk_ctrl/clkqactive_sync_inc_clkqactive_sync_loop_26_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys0top/u_pc_eh_f0_extsystrace/u_css600_atbasyncbridgeslv/u_css600_atbasyncbridge_slv_fifo/wrptr_gray_reg_0/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_clk_ctrl_dbgclk/clkqactive_sync_inc_clkqactive_sync_loop_9_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys0top/u_pc_eh_f0_extsyscti/u_css600_pulseasyncbridgeslv/pulse_req_q_reg_2/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_clk_ctrl_dbgclk/clkqactive_sync_inc_clkqactive_sync_loop_8_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_sender_esxh_0/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_clk_ctrl_refclk_free/clkqactive_sync_inc_clkqactive_sync_loop_0_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_sender_esxh_0/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_clk_ctrl_refclk_int/clkqactive_sync_inc_clkqactive_sync_loop_2_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/gen_mhu_esxh_1_u_mhuv2_f1_sender_esxh_1/u_mhuv2_f1_adb_apb3_slv/u_mhuv2_f1_adb_apb3_slv_core/apb_async_req_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_aclk_ctrl/clkqactive_sync_inc_clkqactive_sync_loop_26_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys1top/u_pc_eh_f0_extsysmem/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/slvcandenyreqn_q_reg/CK
}] -to [get_pins {
  u_pd_systop/u_aclk_ctrl/clkqactive_sync_inc_clkqactive_sync_loop_27_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys1top/u_pc_eh_f0_extsystrace/u_css600_atbasyncbridgeslv/u_css600_atbasyncbridge_slv_fifo/wrptr_gray_reg_2/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_clk_ctrl_dbgclk/clkqactive_sync_inc_clkqactive_sync_loop_12_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys1top/u_pc_eh_f0_extsyscti/u_css600_pulseasyncbridgeslv/pulse_req_q_reg_0/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_clk_ctrl_dbgclk/clkqactive_sync_inc_clkqactive_sync_loop_11_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/gen_mhu_hesx_1_u_mhuv2_f1_receiver_hesx_1/u_mhuv2_f1_adb_apb3_mst/recawake_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_aclk_ctrl/clkqactive_sync_inc_clkqactive_sync_loop_27_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]
compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_debug_f0_aontop/u_dpslv/u_css600_dpslv_cdc/bus_req_q_reg/CK
}] -to [get_pins {
  u_clk_ctrl_aondbgctrl/clkqactive_sync_inc_clkqactive_sync_loop_2_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_eh0_f0_systop/hes_1_ehx_mhuint_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/pactive_input_block_loop_7_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_eh1_f0_systop/hes_1_ehx_mhuint_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/pactive_input_block_loop_7_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_debug_f0_systop/u_acg_stm_sequencer/gen_sequencer_u_pck600_lpd_q_sequencer_core/ctrl_qacceptn_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_egress_dbgtop_comb/dev_sync_inc_dev_sync_loop_0_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_debug_f0_systop/u_acg_stm_sequencer/gen_sequencer_u_pck600_lpd_q_sequencer_core/ctrl_qdeny_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_egress_dbgtop_comb/dev_sync_inc_dev_sync_loop_0_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_systop_clustop_dependency_q_chan/pwr_qacceptn_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_egress_expander/dev_sync_inc_dev_sync_loop_0_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_systop_clustop_dependency_q_chan/pwr_qdeny_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_egress_expander/dev_sync_inc_dev_sync_loop_0_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_host_axiap_rom/u_css600_apbrom_gpr_gpr/csyspwrupreq_reg_1/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/pactive_input_block_loop_7_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_uart_subsys/uart0_intr_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_clk_ctrl_refclk_free/clkqactive_sync_inc_clkqactive_sync_loop_0_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_uart_subsys/uart0_intr_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_clk_ctrl_refclk_int/clkqactive_sync_inc_clkqactive_sync_loop_2_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_uart_subsys/uart0_intr_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/pactive_input_block_loop_7_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_uart_subsys/uart1_intr_reg/CK
}] -to [get_pins {
  u_pd_systop/u_ctrlclk_ctrl/clkqactive_sync_inc_clkqactive_sync_loop_0_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_debug_f0_aontop/u_dpmstr/u_css600_dpmstr_apb_if/ack_state_reg/CK
}] -to [get_pins {
  u_debug_f0_aontop/u_dpslv/u_css600_dpslv_cdc/u_css600_cdc_capt_bus_ack_sync/sync_depth_2_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_debug_f0_aontop/u_dpslv/u_css600_dpslv_cdc/bus_req_q_reg/CK
}] -to [get_pins {
  u_debug_f0_aontop/u_dpmstr/u_css600_dpmstr_apb_if/u_css600_cdc_capt_sync_req/sync_depth_2_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_uart_subsys/uart1_intr_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_pactive_on_glitch/has_sync_sync_7_u_pactive_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_debug_f0_aontop/u_dpmstr/u_css600_dpmstr_apb_if/pslverr_q_reg/CK
}] -to [get_pins {
  u_debug_f0_aontop/u_dpslv/u_css600_dpslv_cdc/u_css600_cdc_capt_nosync_bus_err_sync/gen_cdc_capt_nosync_0_u_flop/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_secenc_f0_systop/seh1_mhuint_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/pactive_input_block_loop_7_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

## Max delay constraints for new CDC paths added in 710  ###

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/ca_scb_masked_reg_*/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53/u_ca53_l2/u_ca53_l2noram/u_ca53governor/g_governor_cpu_*_u_governor_cpu/u_governor_cpu_slice/u_ca53_cell_sync*/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_host_rom/u_css600_apbrom_gpr_gpr/cdbgpwrupreq_reg_0/CK
  u_pd_systop/fw_axi_wakeup_reg/CK
  u_pd_systop/u_pc_eh0_f0_systop/esh_0_ehx_mhuint_r_reg/CK
  u_pd_systop/u_pc_eh0_f0_systop/hes_0_ehx_mhuint_r_reg/CK
  u_pd_systop/u_pc_eh1_f0_systop/esh_0_ehx_mhuint_r_reg/CK
  u_pd_systop/u_pc_eh1_f0_systop/hes_0_ehx_mhuint_r_reg/CK
  u_pd_systop/u_pc_secenc_f0_systop/hse0_mhuint_r_reg/CK
  u_pd_systop/u_pc_secenc_f0_systop/seh0_mhuint_r_reg/CK
  u_system_control_f0_aontop/u_uart_subsys/uart1_intr_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/pactive_input_block_loop_7_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys0top/u_pc_eh_f0_extsyscti/u_css600_pulseasyncbridgeslv/pulse_req_q_reg_0/CK
  u_pd_extsys0top/u_pc_eh_f0_extsyscti/u_css600_pulseasyncbridgeslv/pulse_req_q_reg_1/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_clk_ctrl_dbgclk/clkqactive_sync_inc_clkqactive_sync_loop_8_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/gen_mhu_esxh_1_u_mhuv2_f1_sender_esxh_1/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_sender_esxh_0/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
  u_system_control_f0_aontop/u_uart_subsys/uart1_intr_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_clk_ctrl_refclk_free/clkqactive_sync_inc_clkqactive_sync_loop_0_u_pck600_sync_qactive/u_cdc_capt_sync/D
  u_system_control_f0_aontop/u_clk_ctrl_refclk_int/clkqactive_sync_inc_clkqactive_sync_loop_2_u_pck600_sync_qactive/u_cdc_capt_sync/D 
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/gen_mhu_hesx_1_u_mhuv2_f1_receiver_hesx_1/u_mhuv2_f1_adb_apb3_mst/recawake_r_reg/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/gen_mhu_hesx_1_u_mhuv2_f1_receiver_hesx_1/u_mhuv2_f1_adb_posedge_slave/edgereqasync_state_reg_0/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/gen_mhu_hesx_1_u_mhuv2_f1_receiver_hesx_1/u_mhuv2_f1_adb_posedge_slave/edgereqasync_state_reg_1/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_receiver_hesx_0/u_mhuv2_f1_adb_apb3_mst/recawake_r_reg/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_receiver_hesx_0/u_mhuv2_f1_adb_posedge_slave/edgereqasync_state_reg_0/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_receiver_hesx_0/u_mhuv2_f1_adb_posedge_slave/edgereqasync_state_reg_1/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_sender_esxh_0/u_mhuv2_f1_adb_apb3_slv/u_mhuv2_f1_adb_apb3_slv_core/apb_async_req_r_reg/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_sender_esxh_0/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
}] -to [get_pins {
  u_pd_systop/u_aclk_ctrl/clkqactive_sync_inc_clkqactive_sync_loop_26_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys0top/u_pc_eh_f0_extsystrace/u_css600_atbasyncbridgeslv/u_css600_atbasyncbridge_slv_fifo/sync_clear_reg/CK
  u_pd_extsys0top/u_pc_eh_f0_extsystrace/u_css600_atbasyncbridgeslv/u_css600_atbasyncbridge_slv_fifo/wrptr_gray_reg_1/CK
  u_pd_extsys0top/u_pc_eh_f0_extsystrace/u_css600_atbasyncbridgeslv/u_css600_atbasyncbridge_slv_fifo/wrptr_gray_reg_2/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_clk_ctrl_dbgclk/clkqactive_sync_inc_clkqactive_sync_loop_9_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys1top/u_pc_eh_f0_extsyscti/u_css600_pulseasyncbridgeslv/pulse_req_q_reg_1/CK
  u_pd_extsys1top/u_pc_eh_f0_extsyscti/u_css600_pulseasyncbridgeslv/pulse_req_q_reg_3/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_clk_ctrl_dbgclk/clkqactive_sync_inc_clkqactive_sync_loop_11_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys1top/u_pc_eh_f0_extsysmem/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_protocol_quiescent/read_write_quiescent_q_reg/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/gen_mhu_esxh_1_u_mhuv2_f1_sender_esxh_1/u_mhuv2_f1_adb_apb3_slv/u_mhuv2_f1_adb_apb3_slv_core/apb_async_req_r_reg/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/gen_mhu_hesx_1_u_mhuv2_f1_receiver_hesx_1/u_mhuv2_f1_adb_posedge_slave/edgereqasync_state_reg_0/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/gen_mhu_hesx_1_u_mhuv2_f1_receiver_hesx_1/u_mhuv2_f1_adb_posedge_slave/edgereqasync_state_reg_1/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_receiver_hesx_0/u_mhuv2_f1_adb_apb3_mst/recawake_r_reg/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_receiver_hesx_0/u_mhuv2_f1_adb_posedge_slave/edgereqasync_state_reg_0/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_sender_esxh_0/u_mhuv2_f1_adb_apb3_slv/u_mhuv2_f1_adb_apb3_slv_core/apb_async_req_r_reg/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_sender_esxh_0/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
}] -to [get_pins {
  u_pd_systop/u_aclk_ctrl/clkqactive_sync_inc_clkqactive_sync_loop_27_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys1top/u_pc_eh_f0_extsystrace/u_css600_atbasyncbridgeslv/u_css600_atbasyncbridge_slv_fifo/sync_clear_reg/CK
  u_pd_extsys1top/u_pc_eh_f0_extsystrace/u_css600_atbasyncbridgeslv/u_css600_atbasyncbridge_slv_fifo/wrptr_gray_reg_0/CK
  u_pd_extsys1top/u_pc_eh_f0_extsystrace/u_css600_atbasyncbridgeslv/u_css600_atbasyncbridge_slv_fifo/wrptr_gray_reg_3/CK
}] -to [get_pins {
  u_pd_dbgtop_f0/u_clk_ctrl_dbgclk/clkqactive_sync_inc_clkqactive_sync_loop_12_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_reset_controller_f1_top/u_reset_controller_core/u_rst_ctlr_fsm/reset_syndrome_secenc_cae_rst_req_r_reg/CK
}] -to [get_pins {
  u_system_control_f0_aontop/u_host_control/u_host_rst_syn_syn_0_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_chac_reg/u_sec_cdc_capt_sync_14/u_arm_element_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_ctrl_reg/u_sec_cdc_capt_sync_2/u_arm_element_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_secenc_dbgtopq_comb/u_lpc_core/dev_qreqn_r_reg_0/CK
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_pwr_ctrl/u_pck600_lpc_q_2/ctrl_sync_inc_ctrl_sync_loop_1_u_pck600_sync_qreqn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/ca_scb_masked_reg_*/CK
}] -to [get_pins {
  u_clk_ctrl_aondbgctrl/clkqactive_sync_inc_clkqactive_sync_loop_*_u_pck600_sync_qactive/u_cdc_capt_sync/D
  u_debug_f0_aontop/u_arm_element_cdc_capt_sync_*/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_system_control_f0_aontop/u_ppu_dbgen_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_system_control_f0_aontop/u_firewall_f0_ctlr/u_bypass_cdc_capt_sync/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_system_control_f0_aontop/u_host_control/u_extsys0_cpuwait_wen_dd/u_sdff2yrpq/u_arm_sdff2yrpq/D
  u_system_control_f0_aontop/u_host_control/u_extsys1_cpuwait_wen_dd/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_firewall_f0_ctlr/u_firewall_f0_ctlr_fctlr_regbank/fw_global_int_st_reg/CK
  u_system_control_f0_aontop/u_host_control/bsys_pwr_req_wakeup_en_reg/CK
  u_system_control_f0_aontop/u_host_control/host_cpu_clus_pwr_req_pwr_req_reg/CK
  u_system_control_f0_aontop/u_interrupt_router/u_interrupt_router_reg_bank/shd_int_cfg_ici_en_rw_r_reg_*_1/CK
  u_system_control_f0_aontop/u_ns_wdog/intr_reg_1/CK
  u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_ppu/u_pck600_ppu_reg/irq_r_reg/CK
  u_system_control_f0_aontop/u_ppu_aon/u_fwram_ppu/u_pck600_ppu_reg/irq_r_reg/CK
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/u_pck600_ppu_reg/irq_r_reg/CK
  u_system_control_f0_aontop/u_secure_wdog/intr_reg_0/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_clustop_pactive_on_glitch/has_sync_sync_7_u_pactive_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/host_cpu_wake_up_core0_wakeup_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core0_wakeup_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/host_cpu_wake_up_core1_wakeup_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core1_wakeup_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/host_cpu_wake_up_core2_wakeup_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core2_wakeup_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/host_cpu_wake_up_core3_wakeup_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pc_cpu_systop/u_core3_wakeup_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/u_pck600_ppu_reg/irq_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/IRQS_SS_GEN_5_GEN_IRQS_SYNC_u_cdc_capt_sync_intr0/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys0top/u_pc_eh_f0_extsysmem/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_protocol_quiescent/read_write_quiescent_q_reg/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmem/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/slvcandenyreqn_q_reg/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmem/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/slvmustacceptreqn_q_reg/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/gen_mhu_esxh_1_u_mhuv2_f1_sender_esxh_1/u_mhuv2_f1_adb_apb3_slv/u_mhuv2_f1_adb_apb3_slv_core/apb_async_req_r_reg/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/gen_mhu_esxh_1_u_mhuv2_f1_sender_esxh_1/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/gen_mhu_hesx_1_u_mhuv2_f1_receiver_hesx_1/u_mhuv2_f1_adb_apb3_mst/recawake_r_reg/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/gen_mhu_hesx_1_u_mhuv2_f1_receiver_hesx_1/u_mhuv2_f1_adb_posedge_slave/edgereqasync_state_reg_0/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/gen_mhu_hesx_1_u_mhuv2_f1_receiver_hesx_1/u_mhuv2_f1_adb_posedge_slave/edgereqasync_state_reg_1/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_receiver_hesx_0/u_mhuv2_f1_adb_apb3_mst/recawake_r_reg/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_receiver_hesx_0/u_mhuv2_f1_adb_posedge_slave/edgereqasync_state_reg_0/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_receiver_hesx_0/u_mhuv2_f1_adb_posedge_slave/edgereqasync_state_reg_1/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_sender_esxh_0/u_mhuv2_f1_adb_apb3_slv/u_mhuv2_f1_adb_apb3_slv_core/apb_async_req_r_reg/CK
  u_pd_extsys0top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_sender_esxh_0/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
}] -to [get_pins {
  u_pd_systop/u_aclk_ctrl/clkqactive_sync_inc_clkqactive_sync_loop_25_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_extsys1top/u_pc_eh_f0_extsysmem/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_protocol_quiescent/read_write_quiescent_q_reg/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmem/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/slvcandenyreqn_q_reg/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmem/u_sse710_adb400_r3_axi4_slv_wrapper/u_adb400_r3_axi4_slv/u_slv/u_si_ctrl/slvmustacceptreqn_q_reg/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/gen_mhu_esxh_1_u_mhuv2_f1_sender_esxh_1/u_mhuv2_f1_adb_apb3_slv/u_mhuv2_f1_adb_apb3_slv_core/apb_async_req_r_reg/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/gen_mhu_esxh_1_u_mhuv2_f1_sender_esxh_1/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/gen_mhu_hesx_1_u_mhuv2_f1_receiver_hesx_1/u_mhuv2_f1_adb_apb3_mst/recawake_r_reg/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/gen_mhu_hesx_1_u_mhuv2_f1_receiver_hesx_1/u_mhuv2_f1_adb_posedge_slave/edgereqasync_state_reg_0/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/gen_mhu_hesx_1_u_mhuv2_f1_receiver_hesx_1/u_mhuv2_f1_adb_posedge_slave/edgereqasync_state_reg_1/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_receiver_hesx_0/u_mhuv2_f1_adb_apb3_mst/recawake_r_reg/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_receiver_hesx_0/u_mhuv2_f1_adb_posedge_slave/edgereqasync_state_reg_0/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_receiver_hesx_0/u_mhuv2_f1_adb_posedge_slave/edgereqasync_state_reg_1/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_sender_esxh_0/u_mhuv2_f1_adb_apb3_slv/u_mhuv2_f1_adb_apb3_slv_core/apb_async_req_r_reg/CK
  u_pd_extsys1top/u_pc_eh_f0_extsysmhu/u_mhuv2_f1_sender_esxh_0/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK
}] -to [get_pins {
  u_pd_systop/u_aclk_ctrl/clkqactive_sync_inc_clkqactive_sync_loop_26_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_system_control_f0_aontop/u_host_control/pe*_rvbaraddr_lw_rvbar31_2_int*/CK
}] -to [get_pins {
  u_pd_systop/u_pd_clustop/u_cpu_gic_socket/u_cdc_capt_sync_rvbaraddr*_*/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/cae_rst_req_r_reg/CK
}] -to [get_pins {
  u_reset_controller_f1_top/request_synchronizers_u_cdc_capt_secenc_cae_rst_req/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_eh1_f0_systop/u_mhuv2_f1_receiver_esxh_0/u_mhuv2_f1_rec_qch_pwr/qacceptn_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_1_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_eh1_f0_systop/u_mhuv2_f1_receiver_esxh_0/u_mhuv2_f1_rec_qch_pwr/qdeny_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_1_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_secenc_f0_systop/u_mhuv2_f1_receiver_seh_0/u_mhuv2_f1_rec_qch_pwr/qacceptn_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_2_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_secenc_f0_systop/u_mhuv2_f1_receiver_seh_0/u_mhuv2_f1_rec_qch_pwr/qdeny_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_2_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_secenc_f0_systop/u_mhuv2_f1_receiver_seh_1/u_mhuv2_f1_rec_qch_pwr/qacceptn_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_3_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
  u_pd_systop/u_pc_secenc_f0_systop/u_mhuv2_f1_receiver_seh_1/u_mhuv2_f1_rec_qch_pwr/qdeny_r_reg/CK
}] -to [get_pins {
  u_pd_systop/u_systop_ingress_lpd_q/dev_sync_inc_dev_sync_loop_3_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]


compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
    u_system_control_f0_aontop/u_host_control/pe*_config_vinithi_int_reg/CK
}] -to [get_pins {
    u_pd_systop/u_pd_clustop/u_cpu_gic_socket/GEN_INTR_SYNC_*_u_cdc_capt_sync_vinithi/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
    u_system_control_f0_aontop/u_host_control/pe*_config_cfgte_int_reg/CK
}] -to [get_pins {
    u_pd_systop/u_pd_clustop/u_cpu_gic_socket/GEN_INTR_SYNC_*_u_cdc_capt_sync_cfgte/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
     u_system_control_f0_aontop/u_host_control/pe*_config_cfgend_int_reg/CK
}] -to [get_pins {
     u_pd_systop/u_pd_clustop/u_cpu_gic_socket/GEN_INTR_SYNC_*_u_cdc_capt_sync_cfgend/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]


compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
     u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_host_catu/u_css600_catu_reg_block/itctrl_q_reg/CK
     u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_host_etr/u_css600_tmc_core/u_css600_tmc_axi_if_block_u_css600_tmc_axi_if/bufintr_reg/CK
     u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_soc_catu/u_css600_catu_reg_block/itctrl_q_reg/CK
     u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_soc_etr/u_css600_tmc_core/u_css600_tmc_axi_if_block_u_css600_tmc_axi_if/bufintr_reg/CK
     u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_host_catu/u_css600_catu_reg_block/it_addrerr_reg/CK
     u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_soc_catu/u_css600_catu_reg_block/irq_q_reg/CK 
}] -to [get_pins {
     u_pd_systop/u_pd_clustop/u_cpu_gic_socket/IRQS_SS_GEN_*_GEN_IRQS_SYNC_u_cdc_capt_sync_intr0/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
     u_pd_systop/u_pc_debug_aon_f0_systop/u_sdc600_apbcom_int/u_apbcom/u_apbcom_reg/irq_reg_reg/CK
}] -to [get_pins {
     u_pd_systop/u_pd_clustop/u_cpu_gic_socket/IRQS_SS_GEN_*_GEN_IRQS_SYNC_u_cdc_capt_sync_intr0/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
     u_pd_systop/u_pc_eh*_f0_systop/esh_*_ehx_mhuint_r_reg/CK
     u_pd_systop/u_pc_eh*_f0_systop/hes_*_ehx_mhuint_r_reg/CK
     u_pd_systop/u_pc_secenc_f0_systop/hse*_mhuint_r_reg/CK
     u_pd_systop/u_pc_secenc_f0_systop/seh*_mhuint_r_reg/CK
}] -to [get_pins {
     u_pd_systop/u_pd_clustop/u_cpu_gic_socket/IRQS_SS_GEN_*_GEN_IRQS_SYNC_u_cdc_capt_sync_intr0/u_sdff2yrpq/u_arm_sdff2yrpq/D
     u_pd_systop/u_pd_clustop/u_cpu_gic_socket/IRQS_SS_GEN_10_GEN_IRQS_SYNC_u_cdc_capt_sync_intr0/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins {
     u_secenc_f1_aontop/u_secenc_f1_aon/ca_scb_masked_reg_*/CK
}] -to [get_pins {
    u_pd_systop/u_base_systop/u_base_aclk_lpdq/active_deny_support_active_deny_sync_inc_u_pck600_dev_qactive/u_cdc_capt_sync/D
    u_pd_systop/u_base_systop/u_fc_*/u_bypass_cdc_capt_sync/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
    u_pd_systop/u_pc_cpu_systop/u_dbgen_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]


compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_pd_secenc_f1_top/u_secenc_f1_sepd/u_css600_apbasyncbridgemstr/u_mstr_core/apb_async_ack_r_reg/CK
}] -to [get_pins {
   u_pd_dbgtop_f0/u_pc_secenc_f0_dbgtop/u_css600_apbasyncbridgeslv/u_ack_sync/sync_depth_2_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_pd_systop/u_pc_eh0_f0_systop/hes_0_ehx_mhuint_r_reg/CK
}] -to [get_pins {
   u_pd_systop/u_pc_cpu_systop/u_clustop_pactive_on_glitch/has_sync_sync_7_u_pactive_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_pd_systop/u_base_systop/u_nic400_sys_apb/u_cd_a/u_ib_slave_9_ib_s/u_a_fifo_wr/u_cdc_launch_wr_ptr_gry/gen_cdc_launch_gry_*_u_flop/CK
}] -to [get_pins {
   u_pd_systop/u_base_systop/u_nic400_sys_apb/u_cd_ctrl/u_ib_slave_9_ib_m/u_a_fifo_rd/u_sync_wr_ptr_gry/u_cdc_capt_sync_ptr_1/gen_cdc_capt_sync_*_u_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_pd_systop/u_base_systop/u_nic400_sys_apb/u_cd_ctrl/u_ib_slave_9_ib_m/u_w_fifo_rd/u_cdc_launch_rd_ptr_gry/gen_cdc_launch_gry_*_u_flop/CK
}] -to [get_pins {
   u_pd_systop/u_base_systop/u_nic400_sys_apb/u_cd_a/u_ib_slave_9_ib_s/u_w_fifo_wr/u_sync_rd_ptr_gry/u_cdc_capt_sync_ptr_*/gen_cdc_capt_sync_0_u_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_pd_systop/u_pc_cpu_systop/u_core1_ppu/u_pck600_ppu_reg/irq_r_reg/CK
}] -to [get_pins {
   u_pd_systop/u_pd_clustop/u_cpu_gic_socket/IRQS_SS_GEN_5_GEN_IRQS_SYNC_u_cdc_capt_sync_intr0/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_pd_dbgtop_f0/u_pc_secenc_f0_dbgtop/u_pck600_lpd_q_pwr/gen_expander_u_pck600_lpd_q_expander_core/ctrl_qdeny_r_reg/CK
}] -to [get_pins {
   u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_pwr_ctrl/u_pck600_lpc_q_2/dev_sync_inc_dev_sync_loop_1_u_pck600_sync_qdeny/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_pd_dbgtop_f0/u_pc_secenc_f0_dbgtop/u_css600_pulseasyncbridgeslv_1/pulse_req_q_reg_2/CK
}] -to [get_pins {
   u_pd_secenc_f1_top/u_secenc_f1_sepd/u_pck600_clk_ctrl_0/clkqactive_sync_inc_clkqactive_sync_loop_3_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_pd_dbgtop_f0/u_pc_secenc_f0_dbgtop/u_css600_apbasyncbridgeslv/u_slv_core/apb_async_req_r_reg/CK
}] -to [get_pins {
   u_pd_secenc_f1_top/u_secenc_f1_sepd/u_pck600_clk_ctrl_0/clkqactive_sync_inc_clkqactive_sync_loop_0_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_pd_dbgtop_f0/u_pc_secenc_f0_dbgtop/u_pck600_lpd_q_pwr/gen_expander_u_pck600_lpd_q_expander_core/ctrl_qacceptn_r_reg/CK
}] -to [get_pins {
   u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_pwr_ctrl/u_pck600_lpc_q_2/dev_sync_inc_dev_sync_loop_1_u_pck600_sync_qacceptn/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_pd_dbgtop_f0/u_pc_secenc_f0_dbgtop/u_css600_apbasyncbridgeslv/u_slv_core/apb_async_req_r_reg/CK
}] -to [get_pins {
   u_pd_secenc_f1_top/u_secenc_f1_sepd/u_css600_apbasyncbridgemstr/u_req_sync/sync_depth_2_u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_pd_dbgtop_f0/u_pc_secenc_f0_dbgtop/u_css600_pulseasyncbridgeslv_0/pulse_req_q_reg_0/CK
}] -to [get_pins {
   u_pd_secenc_f1_top/u_secenc_f1_sepd/u_pck600_clk_ctrl_0/clkqactive_sync_inc_clkqactive_sync_loop_2_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_extdbg_rom/u_css600_apbrom_gpr_gpr/cdbgpwrupreq_reg_0/CK
}] -to [get_pins {
   u_pd_secenc_f1_top/u_secenc_f1_sepd/u_pck600_clk_ctrl_0/clkqactive_sync_inc_clkqactive_sync_loop_5_u_pck600_sync_qactive/u_cdc_capt_sync/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_host_rom/u_css600_apbrom_gpr_gpr/cdbgpwrupreq_reg_0/CK
}] -to [get_pins {
   u_pd_systop/u_pc_cpu_systop/u_clustop_pactive_on_glitch/has_sync_sync_7_u_pactive_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_soc_catu/u_css600_catu_reg_block/it_addrerr_reg/CK
}] -to [get_pins {
   u_pd_systop/u_pd_clustop/u_cpu_gic_socket/IRQS_SS_GEN_43_GEN_IRQS_SYNC_u_cdc_capt_sync_intr0/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_host_catu/u_css600_catu_reg_block/irq_q_reg/CK
}] -to [get_pins {
   u_pd_systop/u_pd_clustop/u_cpu_gic_socket/IRQS_SS_GEN_39_GEN_IRQS_SYNC_u_cdc_capt_sync_intr0/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_pd_systop/u_pd_clustop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst/u_mst/u_protocol_quiescent/read_write_quiescent_q_reg/CK
}] -to [get_pins {
   u_pd_systop/u_pc_cpu_systop/u_clustop_pactive_on_glitch/has_sync_sync_7_u_pactive_ss/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_pd_systop/u_pd_clustop/u_cpu_gic_socket/GEN_WAKEUPREQ_INV_*_u_cdc_capt_sync_wakeupreq/u_sdff2yrpq/u_arm_sdff2yrpq/CK
}] -to [get_pins {
   u_pd_systop/u_pc_cpu_systop/u_core*_wakeupreq_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_secenc_f1_aontop/u_secenc_f1_aon/ca_scb_masked_reg_*/CK
}] -to [get_pins {
   u_pd_dbgtop_f0/u_arm_element_cdc_capt_sync_*/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_secenc_f1_aontop/u_secenc_f1_aon/ca_scb_masked_reg_37/CK
}] -to [get_pins {
   u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_fc/u_bypass_cdc_capt_sync/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]


compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/u_pck600_ppu_psm/devclken_r_reg/CK
}] -to [get_pins {
   u_system_control_f0_aontop/u_pcg_syspll_systop/sync_loop_0_u_enable_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_pwr_ctrl/u_p_reqack_to_qchan_f0_top/state_reg_0/CK
}] -to [get_pins {
   u_pd_dbgtop_f0/u_arm_element_cdc_capt_extdbg_cdbgpwrupack/u_sdff2yrpq/u_arm_sdff2yrpq/D
}]

compat_set_max_delay -ignore_clock_latency $NON_CRITICAL_CROSSING_LATENCY_TARGET -from [get_pins { 
   u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_pwr_ctrl/u_pck600_lpc_q_2/u_lpc_core/dev_qreqn_r_reg_1/CK
}] -to [get_pins {
   u_pd_dbgtop_f0/u_pc_secenc_f0_dbgtop/u_pck600_lpd_q_pwr/ctrl_sync_inc_u_pck600_sync_qreqn/u_cdc_capt_sync/D
}]


######################
# GCounter and GTimer
######################

constrain_gcounter -path {u_system_control_f0_aontop/u_s32k_gcounter} \
  -shortest_period [expr {min($PERIODS(REFCLK), $PERIODS(S32KCLK))}]
constrain_gtimer -path {u_system_control_f0_aontop/u_s32k_cntbase0} \
  -shortest_period [expr {min($PERIODS(REFCLK), $PERIODS(S32KCLK))}]
constrain_gtimer -path {u_system_control_f0_aontop/u_s32k_cntbase1} \
  -shortest_period [expr {min($PERIODS(REFCLK), $PERIODS(S32KCLK))}]


#######################################################################
# Max Delay Constraints for paths involving asynchronous virtual clock
#######################################################################

set DEFAULT_ASYNC_MAX_DELAY 25.0
set NON_ASYNC_CLOCKS [remove_from_collection [all_clocks] [get_clocks V_ASYNC]]

foreach_in_collection clock $NON_ASYNC_CLOCKS {
  compat_set_max_delay -ignore_clock_latency $DEFAULT_ASYNC_MAX_DELAY -from [get_clocks {V_ASYNC}] \
    -to $clock
}

foreach_in_collection clock $NON_ASYNC_CLOCKS {
  compat_set_max_delay -ignore_clock_latency $DEFAULT_ASYNC_MAX_DELAY -from $clock \
    -to [get_clocks {V_ASYNC}]
}


#######################################################################
# Clock gating disable
#######################################################################

set_disable_clock_gating_check [get_cells {
  u_pd_dbgtop_f0/u_clk_gen_dbgclk/u_e_clk_f1_unit_dbgclk_dbgtop/u_clkrst_f1_clkdiv_modulate_top_syspll/u_clkrst_f1_clkdiv_modulate/clockpath_logic_u_clkrst_f1_clkor2/u_arm_element_clock_or2/u_*or2
  u_pd_systop/u_clk_gen_systop/u_e_clk_f1_unit_aclk_systop/u_clkrst_f1_clkdiv_modulate_top_syspll/u_clkrst_f1_clkdiv_modulate/clockpath_logic_u_clkrst_f1_clkor2/u_arm_element_clock_or2/u_*or2
  u_pd_systop/u_clk_gen_systop/u_e_clk_f1_unit_ctrlclk_systop/u_clkrst_f1_clkdiv_modulate_top_syspll/u_clkrst_f1_clkdiv_modulate/clockpath_logic_u_clkrst_f1_clkor2/u_arm_element_clock_or2/u_*or2
  u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_gicclk_clustop/u_clkrst_f1_clkdiv_modulate_top_syspll/u_clkrst_f1_clkdiv_modulate/clockpath_logic_u_clkrst_f1_clkor2/u_arm_element_clock_or2/u_*or2
  u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_hostcpuclk_clustop/u_clkrst_f1_clkdiv_modulate_top_cpupll/u_clkrst_f1_clkdiv_modulate/clockpath_logic_u_clkrst_f1_clkor2/u_arm_element_clock_or2/u_*or2
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_secencclk_aon_secenc_clk/u_clkrst_f1_clkdiv_modulate_top_syspll/u_clkrst_f1_clkdiv_modulate/clockpath_logic_u_clkrst_f1_clkor2/u_arm_element_clock_or2/u_*or2
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_secencdivclk_i_secenc_clk/u_clkrst_f1_clkdiv_modulate_top_secencdivclk_i/u_clkrst_f1_clkdiv_modulate/clockpath_logic_u_clkrst_f1_clkor2/u_arm_element_clock_or2/u_*or2
  u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_hostcpuclk_clustop/u_clkselnway_f0_3/u_clkoutor_1/u_clock_or2/u_*or2
  u_pd_systop/u_clk_gen_systop/u_e_clk_f1_unit_ctrlclk_systop/u_clkselnway_f0_2/u_clkoutor2/u_clock_or2/u_*or2
}]
# End of CDC Mode SDC for SSE-710

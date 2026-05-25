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
# Purpose : IO Port SDC for SSE-710
# -----------------------------------------------------------------------------
#
# This file contains delay constraints for all of the top level ports for the
# SSE-710 design. It is sourced in all of the constraint modes, following clock
# definition.
#
# NOTE: these constraints are intended for implementation/OOB purposes they are
#       currently NOT sign off quality

set_units -time ns

#######################
# Constant Definitions
#######################

array unset DEFAULT_DELAYS

dict for {clk period} [array get PERIODS] {
  set DEFAULT_DELAYS($clk) [expr {0.6 * $period}]
  set DEFAULT_DELAYS_30($clk) [expr {0.3 * $period}]
}

set SWCLKTCK_NEG_EDGE_OUTPUT_DELAY [expr {0.475 * $PERIODS(SWCLKTCK)}]
set SWCLKTCK_NEG_EDGE_INPUT_DELAY  [expr {0.475 * $PERIODS(SWCLKTCK)}]


#################
# Chassis Clocks
#################

set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SYSPLLLOCK}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {CPUPLLLOCK}]


#################
# Chassis Resets
#################

set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {PORESETn}]
set_input_delay  -add -clock V_SWCLKTCK $SWCLKTCK_NEG_EDGE_INPUT_DELAY [get_ports {PORESETn}]

set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {nSRST}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {AONTOPPORESETn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {AONTOPWARMRESETn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SYSTOPWARMRESETn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DBGTOPWARMRESETn}]


#######################
# SOCID: SOC Interface
#######################

set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SOCPRTID[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SOCVAR[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SOCREV[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SOCIMPLID[*]}]

set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DPROMPRTID[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DPROMVAR[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DPROMREV[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DPROMIMPLID[*]}]

set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTDBGROMPRTID[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTDBGROMVAR[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTDBGROMREV[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTDBGROMIMPLID[*]}]

set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTROMPRTID[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTROMVAR[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTROMREV[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTROMIMPLID[*]}]

set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTAXIAPROMPRTID[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTAXIAPROMVAR[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTAXIAPROMREV[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTAXIAPROMIMPLID[*]}]

set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {OCVMSIZE[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {XNVMSIZE[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {CVMSIZE[*]}]

set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXPSHDINT[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {GICWAKEUP}]


############################################################
# DFT / JTAG / Serial Wire Debug Interface / Debug expansion
############################################################

set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {nTRST}]

# HOSTDBGPWRREQ
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTDBGPWRREQ[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTDBGPWRACK[*]}]

# SWJ
set_input_delay  -clock V_SWCLKTCK $DEFAULT_DELAYS(SWCLKTCK) [get_ports {SWDITMS}]
set_output_delay -clock V_SWCLKTCK $DEFAULT_DELAYS(SWCLKTCK) [get_ports {SWDO}]
set_output_delay -clock V_SWCLKTCK $DEFAULT_DELAYS(SWCLKTCK) [get_ports {SWDOEN}]
set_input_delay  -clock V_SWCLKTCK $DEFAULT_DELAYS(SWCLKTCK) [get_ports {TDI}]
set_output_delay -clock V_SWCLKTCK $DEFAULT_DELAYS(SWCLKTCK) [get_ports {SWACTIVE}]
set_output_delay -clock V_SWCLKTCK $DEFAULT_DELAYS(SWCLKTCK) [get_ports {JTAGACTIVE}]
set_output_delay -clock V_SWCLKTCK $DEFAULT_DELAYS(SWCLKTCK) [get_ports {JTAGIR[*]}]
set_output_delay -clock V_SWCLKTCK $DEFAULT_DELAYS(SWCLKTCK) [get_ports {JTAGSTATE[*]}]
set_output_delay -clock V_SWCLKTCK $DEFAULT_DELAYS(SWCLKTCK) [get_ports {DORMANTSTATE}]
# 45% external delay for these ports, since the launching flop is negative-edge triggered
set_output_delay -clock V_SWCLKTCK $SWCLKTCK_NEG_EDGE_OUTPUT_DELAY [get_ports {TDO}]
set_output_delay -clock V_SWCLKTCK $SWCLKTCK_NEG_EDGE_OUTPUT_DELAY [get_ports {TDOENn}]

# DFT
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DFTDIVSEL}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DFTRAMHOLD}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DFTMCPHOLD}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DFTCGEN}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DFTRSTDISABLE[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DFTPWRUP}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DFTRETDISABLE}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DFTISODISABLE}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DFTENABLE[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DFTHOSTUARTCLKSEL[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DFTCTRLCLKSEL[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DFTGICCLKSEL[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DFTACLKSEL[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DFTDBGCLKSEL[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DFTSECCLKSEL[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DFTCLKSELEN}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DFTHOSTCPUCLKSEL[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DFTDIVBYPASS}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DFTSE}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DFTTESTMODE}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {nMBISTRESET}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {MBISTREQ}]
set_max_delay    -from  [get_ports {MBISTREQ}]           25.0

# HOSTDBGTRACEEXP
set_input_delay  -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {ATWAKEUPHOSTDBGTRACEEXP}]
set_input_delay  -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {ATIDHOSTDBGTRACEEXP[*]}]
set_input_delay  -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {ATBYTESHOSTDBGTRACEEXP[*]}]
set_input_delay  -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {ATDATAHOSTDBGTRACEEXP[*]}]
set_input_delay  -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {ATVALIDHOSTDBGTRACEEXP}]
set_output_delay -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {ATREADYHOSTDBGTRACEEXP}]
set_output_delay -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {AFVALIDHOSTDBGTRACEEXP}]
set_input_delay  -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {AFREADYHOSTDBGTRACEEXP}]
set_output_delay -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {SYNCREQHOSTDBGTRACEEXP}]

# HOSTCTICHINEXP
set_input_delay  -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {HOSTCTICHINEXP[*]}]
set_output_delay -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {HOSTCTICHOUTEXP[*]}]

# HOSTDBGEXP
set_output_delay -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {PWAKEUPHOSTDBGEXP}]
set_output_delay -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {PSELHOSTDBGEXP}]
set_output_delay -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {PENABLEHOSTDBGEXP}]
set_output_delay -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {PWRITEHOSTDBGEXP}]
set_output_delay -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {PPROTHOSTDBGEXP[*]}]
set_output_delay -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {PSTRBHOSTDBGEXP[*]}]
set_output_delay -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {PADDRHOSTDBGEXP[*]}]
set_output_delay -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {PWDATAHOSTDBGEXP[*]}]
set_input_delay  -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {PREADYHOSTDBGEXP}]
set_input_delay  -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {PSLVERRHOSTDBGEXP}]
set_input_delay  -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {PRDATAHOSTDBGEXP[*]}]

# HOSTSTMDPRD
set_input_delay  -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {HOSTSTMDPRDRREADY}]
set_input_delay  -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {HOSTSTMDPRDAVALID}]
set_input_delay  -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {HOSTSTMDPRDATYPE[*]}]
set_output_delay -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {HOSTSTMDPRDRVALID}]
set_output_delay -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {HOSTSTMDPRDRTYPE[*]}]
set_output_delay -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {HOSTSTMDPRDRLAST}]
set_output_delay -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {HOSTSTMDPRDAREADY}]

# SOCSC
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SCBEXP[*]}]

# SOCLCC
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SOCLCC}]

# TPIU
set_output_delay -clock V_TRACECLKIN  $DEFAULT_DELAYS(TRACECLKIN) [get_ports {TPIUTRACEDATA[*]}]
set_output_delay -clock V_TRACECLKIN  $DEFAULT_DELAYS(TRACECLKIN) [get_ports {TPIUTRACECTL}]
set_input_delay  -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {TPIUTRACEMAXDATASIZE[*]}]
set_input_delay  -clock V_DBGCLK $DEFAULT_DELAYS(V_DBGCLK) [get_ports {TPIUTPCTLVALID}]

######################
# Low Power Interface
######################

# REFCLKQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {REFCLKQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {REFCLKQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {REFCLKQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {REFCLKQACTIVE}]

# ACLKQ
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {ACLKQREQn[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {ACLKQACCEPTn[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {ACLKQDENY[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {ACLKQACTIVE[*]}]

# DBGCLKQ
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DBGCLKQREQn[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DBGCLKQACCEPTn[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DBGCLKQDENY[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DBGCLKQACTIVE[*]}]

# SYSTOPQ
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SYSTOPQREQn[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SYSTOPQACCEPTn[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SYSTOPQDENY[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SYSTOPQACTIVE[*]}]

# DBGTOPQ
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DBGTOPQREQn[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DBGTOPQACCEPTn[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DBGTOPQDENY[*]}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {DBGTOPQACTIVE[*]}]


#########################
# SSE-710 AXI Interfaces
#########################

# CVM
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWIDCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWADDRCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWLENCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWSIZECVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWBURSTCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWLOCKCVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWCACHECVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWPROTCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWVALIDCVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWAKEUPCVM}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWREADYCVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WDATACVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WSTRBCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WLASTCVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WVALIDCVM}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WREADYCVM}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BIDCVM[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BRESPCVM[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BVALIDCVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BREADYCVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARIDCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARADDRCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARLENCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARSIZECVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARBURSTCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARLOCKCVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARCACHECVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARPROTCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARVALIDCVM}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARREADYCVM}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RIDCVM[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RDATACVM[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RRESPCVM[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RLASTCVM}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RVALIDCVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RREADYCVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWMMUSIDCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWUSERCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARMMUSIDCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARUSERCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWQOSCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARQOSCVM[*]}]


# XNVM
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWIDXNVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWADDRXNVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWLENXNVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWSIZEXNVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWBURSTXNVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWLOCKXNVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWCACHEXNVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWPROTXNVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWVALIDXNVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWAKEUPXNVM}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWREADYXNVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WDATAXNVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WSTRBXNVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WLASTXNVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WVALIDXNVM}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WREADYXNVM}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BIDXNVM[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BRESPXNVM[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BVALIDXNVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BREADYXNVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARIDXNVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARADDRXNVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARLENXNVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARSIZEXNVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARBURSTXNVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARLOCKXNVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARCACHEXNVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARPROTXNVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARVALIDXNVM}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARREADYXNVM}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RIDXNVM[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RDATAXNVM[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RRESPXNVM[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RLASTXNVM}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RVALIDXNVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RREADYXNVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWMMUSIDXNVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWUSERXNVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARMMUSIDXNVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARUSERXNVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWQOSXNVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARQOSXNVM[*]}]

# OCVM
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWIDOCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWADDROCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWLENOCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWSIZEOCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWBURSTOCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWLOCKOCVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWCACHEOCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWPROTOCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWVALIDOCVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWAKEUPOCVM}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWREADYOCVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WDATAOCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WSTRBOCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WLASTOCVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WVALIDOCVM}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WREADYOCVM}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BIDOCVM[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BRESPOCVM[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BVALIDOCVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BREADYOCVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARIDOCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARADDROCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARLENOCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARSIZEOCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARBURSTOCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARLOCKOCVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARCACHEOCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARPROTOCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARVALIDOCVM}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARREADYOCVM}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RIDOCVM[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RDATAOCVM[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RRESPOCVM[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RLASTOCVM}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RVALIDOCVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RREADYOCVM}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWMMUSIDOCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWUSEROCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARMMUSIDOCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARUSEROCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWQOSOCVM[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARQOSOCVM[*]}]


# EXPSLV0 
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWIDEXPSLV0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWADDREXPSLV0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWLENEXPSLV0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWSIZEEXPSLV0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWBURSTEXPSLV0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWLOCKEXPSLV0}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWCACHEEXPSLV0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWPROTEXPSLV0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWVALIDEXPSLV0}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWAKEUPEXPSLV0}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWREADYEXPSLV0}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WDATAEXPSLV0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WSTRBEXPSLV0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WLASTEXPSLV0}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WVALIDEXPSLV0}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WREADYEXPSLV0}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BIDEXPSLV0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BRESPEXPSLV0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BVALIDEXPSLV0}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BREADYEXPSLV0}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARIDEXPSLV0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARADDREXPSLV0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARLENEXPSLV0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARSIZEEXPSLV0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARBURSTEXPSLV0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARLOCKEXPSLV0}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARCACHEEXPSLV0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARPROTEXPSLV0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARVALIDEXPSLV0}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARREADYEXPSLV0}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RIDEXPSLV0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RDATAEXPSLV0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RRESPEXPSLV0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RLASTEXPSLV0}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RVALIDEXPSLV0}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RREADYEXPSLV0}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWMMUSIDEXPSLV0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWUSEREXPSLV0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARMMUSIDEXPSLV0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARUSEREXPSLV0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWQOSEXPSLV0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARQOSEXPSLV0[*]}]

# EXPSLV1 
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWIDEXPSLV1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWADDREXPSLV1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWLENEXPSLV1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWSIZEEXPSLV1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWBURSTEXPSLV1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWLOCKEXPSLV1}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWCACHEEXPSLV1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWPROTEXPSLV1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWVALIDEXPSLV1}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWAKEUPEXPSLV1}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWREADYEXPSLV1}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WDATAEXPSLV1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WSTRBEXPSLV1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WLASTEXPSLV1}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WVALIDEXPSLV1}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WREADYEXPSLV1}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BIDEXPSLV1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BRESPEXPSLV1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BVALIDEXPSLV1}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BREADYEXPSLV1}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARIDEXPSLV1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARADDREXPSLV1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARLENEXPSLV1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARSIZEEXPSLV1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARBURSTEXPSLV1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARLOCKEXPSLV1}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARCACHEEXPSLV1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARPROTEXPSLV1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARVALIDEXPSLV1}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARREADYEXPSLV1}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RIDEXPSLV1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RDATAEXPSLV1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RRESPEXPSLV1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RLASTEXPSLV1}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RVALIDEXPSLV1}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RREADYEXPSLV1}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWMMUSIDEXPSLV1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWUSEREXPSLV1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARMMUSIDEXPSLV1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARUSEREXPSLV1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWQOSEXPSLV1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARQOSEXPSLV1[*]}]


# EXPMST0 
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWIDEXPMST0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWADDREXPMST0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWLENEXPMST0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWSIZEEXPMST0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWBURSTEXPMST0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWLOCKEXPMST0}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWCACHEEXPMST0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWPROTEXPMST0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWVALIDEXPMST0}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWAKEUPEXPMST0}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWREADYEXPMST0}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WDATAEXPMST0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WSTRBEXPMST0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WLASTEXPMST0}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WVALIDEXPMST0}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WREADYEXPMST0}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BIDEXPMST0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BRESPEXPMST0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BVALIDEXPMST0}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BREADYEXPMST0}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARIDEXPMST0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARADDREXPMST0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARLENEXPMST0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARSIZEEXPMST0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARBURSTEXPMST0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARLOCKEXPMST0}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARCACHEEXPMST0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARPROTEXPMST0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARVALIDEXPMST0}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARREADYEXPMST0}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RIDEXPMST0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RDATAEXPMST0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RRESPEXPMST0[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RLASTEXPMST0}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RVALIDEXPMST0}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RREADYEXPMST0}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWMMUSIDEXPMST0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWUSEREXPMST0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARMMUSIDEXPMST0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARUSEREXPMST0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWQOSEXPMST0[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARQOSEXPMST0[*]}]

# EXPMST1 
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWIDEXPMST1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWADDREXPMST1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWLENEXPMST1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWSIZEEXPMST1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWBURSTEXPMST1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWLOCKEXPMST1}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWCACHEEXPMST1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWPROTEXPMST1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWVALIDEXPMST1}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWAKEUPEXPMST1}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWREADYEXPMST1}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WDATAEXPMST1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WSTRBEXPMST1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WLASTEXPMST1}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WVALIDEXPMST1}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {WREADYEXPMST1}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BIDEXPMST1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BRESPEXPMST1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BVALIDEXPMST1}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {BREADYEXPMST1}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARIDEXPMST1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARADDREXPMST1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARLENEXPMST1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARSIZEEXPMST1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARBURSTEXPMST1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARLOCKEXPMST1}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARCACHEEXPMST1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARPROTEXPMST1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARVALIDEXPMST1}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARREADYEXPMST1}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RIDEXPMST1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RDATAEXPMST1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RRESPEXPMST1[*]}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RLASTEXPMST1}]
set_input_delay  -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RVALIDEXPMST1}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {RREADYEXPMST1}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWMMUSIDEXPMST1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWUSEREXPMST1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARMMUSIDEXPMST1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARUSEREXPMST1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {AWQOSEXPMST1[*]}]
set_output_delay -clock V_ACLK $DEFAULT_DELAYS(V_ACLK) [get_ports {ARQOSEXPMST1[*]}]


#######################################################
# Debug, Trace, Cross Trigger and Debug Authentication
#######################################################

set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTDBGAUTHDBGEN}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTDBGAUTHNIDEN}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTDBGAUTHSPIDEN}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTDBGAUTHSPNIDEN}]


############################
# Timestamp Synchronization
############################

set_input_delay  -clock V_REFCLK  $DEFAULT_DELAYS_30(REFCLK)  [get_ports {HOSTTSVALUEB[*]}]

set_output_delay -clock V_ASYNC   $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTCNTVALUEG[*]}]
set_input_delay  -clock V_REFCLK  $DEFAULT_DELAYS(REFCLK)  [get_ports {HOSTCNTVALUEB[*]}]

set_output_delay -clock V_ASYNC   $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTS32KCNTVALUEG[*]}]
set_input_delay  -clock V_S32KCLK $DEFAULT_DELAYS(S32KCLK) [get_ports {HOSTS32KCNTVALUEB[*]}]


##################################
# Host System UART 0/1 Interfaces
##################################

# HOSTUART
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTUART0OUT2n}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTUART0OUT1n}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTUART0RTSn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTUART0DTRn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTUART0TX}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTUART0CTSn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTUART0DCDn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTUART0DSRn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTUART0RIn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTUART0RX}]

set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTUART1OUT2n}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTUART1OUT1n}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTUART1RTSn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTUART1DTRn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTUART1TX}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTUART1CTSn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTUART1DCDn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTUART1DSRn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTUART1RIn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {HOSTUART1RX}]

#################
# Host AON
#################

# HOSTAONEXPMST
set_output_delay -clock V_REFCLK $DEFAULT_DELAYS(REFCLK) [get_ports {PSELHOSTAONEXPMST}]
set_output_delay -clock V_REFCLK $DEFAULT_DELAYS(REFCLK) [get_ports {PENABLEHOSTAONEXPMST}]
set_output_delay -clock V_REFCLK $DEFAULT_DELAYS(REFCLK) [get_ports {PADDRHOSTAONEXPMST[*]}]
set_output_delay -clock V_REFCLK $DEFAULT_DELAYS(REFCLK) [get_ports {PWRITEHOSTAONEXPMST}]
set_output_delay -clock V_REFCLK $DEFAULT_DELAYS(REFCLK) [get_ports {PWDATAHOSTAONEXPMST[*]}]
set_output_delay -clock V_REFCLK $DEFAULT_DELAYS(REFCLK) [get_ports {PSTRBHOSTAONEXPMST[*]}]
set_output_delay -clock V_REFCLK $DEFAULT_DELAYS(REFCLK) [get_ports {PPROTHOSTAONEXPMST[*]}]
set_output_delay -clock V_REFCLK $DEFAULT_DELAYS(REFCLK) [get_ports {PWAKEUPHOSTAONEXPMST}]
set_input_delay  -clock V_REFCLK $DEFAULT_DELAYS(REFCLK) [get_ports {PREADYHOSTAONEXPMST}]
set_input_delay  -clock V_REFCLK $DEFAULT_DELAYS(REFCLK) [get_ports {PRDATAHOSTAONEXPMST[*]}]
set_input_delay  -clock V_REFCLK $DEFAULT_DELAYS(REFCLK) [get_ports {PSLVERRHOSTAONEXPMST}]


#################
# Secure Enclave 
#################


# SECENCUART UART
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SECENCUARTTX}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SECENCUARTRX}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SECENCUARTRTSn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SECENCUARTCTSn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SECENCUARTRIn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SECENCUARTDCDn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SECENCUARTDSRn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SECENCUARTDTRn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SECENCUARTOUT1n}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {SECENCUARTOUT2n}]


#######################################
# External System Harness 0 Interfaces
#######################################

# Resets
set_input_delay  -clock V_EXTSYS0DBGCLKS $DEFAULT_DELAYS(EXTSYS0DBGCLKS) [get_ports {EXTSYS0DBGPRESETSn}]
set_input_delay  -clock V_EXTSYS0DBGCLKM $DEFAULT_DELAYS(EXTSYS0DBGCLKM) [get_ports {EXTSYS0DBGPRESETMn}]
set_input_delay  -clock V_EXTSYS0MHUCLK  $DEFAULT_DELAYS(EXTSYS0MHUCLK)  [get_ports {EXTSYS0MHURESETn}]
set_input_delay  -clock V_EXTSYS0ATCLK   $DEFAULT_DELAYS(EXTSYS0ATCLK)   [get_ports {EXTSYS0ATRESETn}]
set_input_delay  -clock V_EXTSYS0CTICLK  $DEFAULT_DELAYS(EXTSYS0CTICLK)  [get_ports {EXTSYS0CTIRESETn}]
set_input_delay  -clock V_EXTSYS0ACLK    $DEFAULT_DELAYS(EXTSYS0ACLK)    [get_ports {EXTSYS0ARESETn}]
set_output_delay -clock V_ASYNC          $DEFAULT_DELAYS(V_ASYNC)        [get_ports {EXTSYS0PORESETn}]

set_output_delay -clock V_ASYNC          $DEFAULT_DELAYS(V_ASYNC)        [get_ports {EXTSYS0CPUWAIT}]

# EXTSYS0MEM
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {AWAKEUPEXTSYS0MEM}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {AWIDEXTSYS0MEM[*]}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {AWADDREXTSYS0MEM[*]}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {AWLENEXTSYS0MEM[*]}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {AWSIZEEXTSYS0MEM[*]}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {AWBURSTEXTSYS0MEM[*]}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {AWLOCKEXTSYS0MEM}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {AWCACHEEXTSYS0MEM[*]}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {AWPROTEXTSYS0MEM[*]}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {AWREGIONEXTSYS0MEM[*]}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {AWVALIDEXTSYS0MEM}]
set_output_delay -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {AWREADYEXTSYS0MEM}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {WSTRBEXTSYS0MEM[*]}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {WLASTEXTSYS0MEM}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {WVALIDEXTSYS0MEM}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {WDATAEXTSYS0MEM[*]}]
set_output_delay -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {WREADYEXTSYS0MEM}]
set_output_delay -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {BIDEXTSYS0MEM[*]}]
set_output_delay -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {BRESPEXTSYS0MEM[*]}]
set_output_delay -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {BVALIDEXTSYS0MEM}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {BREADYEXTSYS0MEM}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {ARIDEXTSYS0MEM[*]}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {ARADDREXTSYS0MEM[*]}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {ARLENEXTSYS0MEM[*]}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {ARSIZEEXTSYS0MEM[*]}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {ARBURSTEXTSYS0MEM[*]}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {ARLOCKEXTSYS0MEM}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {ARCACHEEXTSYS0MEM[*]}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {ARPROTEXTSYS0MEM[*]}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {ARREGIONEXTSYS0MEM[*]}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {ARVALIDEXTSYS0MEM}]
set_output_delay -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {ARREADYEXTSYS0MEM}]
set_output_delay -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {RIDEXTSYS0MEM[*]}]
set_output_delay -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {RRESPEXTSYS0MEM[*]}]
set_output_delay -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {RLASTEXTSYS0MEM}]
set_output_delay -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {RVALIDEXTSYS0MEM}]
set_output_delay -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {RDATAEXTSYS0MEM[*]}]
set_input_delay  -clock V_EXTSYS0ACLK $DEFAULT_DELAYS(EXTSYS0ACLK) [get_ports {RREADYEXTSYS0MEM}]

# EXTSYS0MHU
set_input_delay  -clock V_EXTSYS0MHUCLK $DEFAULT_DELAYS(EXTSYS0MHUCLK) [get_ports {PSELEXTSYS0MHU}]
set_input_delay  -clock V_EXTSYS0MHUCLK $DEFAULT_DELAYS(EXTSYS0MHUCLK) [get_ports {PWAKEUPEXTSYS0MHU}]
set_input_delay  -clock V_EXTSYS0MHUCLK $DEFAULT_DELAYS(EXTSYS0MHUCLK) [get_ports {PENABLEEXTSYS0MHU}]
set_input_delay  -clock V_EXTSYS0MHUCLK $DEFAULT_DELAYS(EXTSYS0MHUCLK) [get_ports {PADDREXTSYS0MHU[*]}]
set_input_delay  -clock V_EXTSYS0MHUCLK $DEFAULT_DELAYS(EXTSYS0MHUCLK) [get_ports {PWRITEEXTSYS0MHU}]
set_input_delay  -clock V_EXTSYS0MHUCLK $DEFAULT_DELAYS(EXTSYS0MHUCLK) [get_ports {PWDATAEXTSYS0MHU[*]}]
set_input_delay  -clock V_EXTSYS0MHUCLK $DEFAULT_DELAYS(EXTSYS0MHUCLK) [get_ports {PSTRBEXTSYS0MHU[*]}]
set_input_delay  -clock V_EXTSYS0MHUCLK $DEFAULT_DELAYS(EXTSYS0MHUCLK) [get_ports {PPROTEXTSYS0MHU[*]}]
set_output_delay -clock V_EXTSYS0MHUCLK $DEFAULT_DELAYS(EXTSYS0MHUCLK) [get_ports {PRDATAEXTSYS0MHU[*]}]
set_output_delay -clock V_EXTSYS0MHUCLK $DEFAULT_DELAYS(EXTSYS0MHUCLK) [get_ports {PREADYEXTSYS0MHU}]
set_output_delay -clock V_EXTSYS0MHUCLK $DEFAULT_DELAYS(EXTSYS0MHUCLK) [get_ports {PSLVERREXTSYS0MHU}]

# EXTSYS0MHUINT
set_output_delay -clock V_EXTSYS0MHUCLK $DEFAULT_DELAYS(EXTSYS0MHUCLK) [get_ports {ESH0EXTSYS0MHUINT}]
set_output_delay -clock V_EXTSYS0MHUCLK $DEFAULT_DELAYS(EXTSYS0MHUCLK) [get_ports {HES0EXTSYS0MHUINT}]
set_output_delay -clock V_EXTSYS0MHUCLK $DEFAULT_DELAYS(EXTSYS0MHUCLK) [get_ports {ESH1EXTSYS0MHUINT}]
set_output_delay -clock V_EXTSYS0MHUCLK $DEFAULT_DELAYS(EXTSYS0MHUCLK) [get_ports {HES1EXTSYS0MHUINT}]
set_output_delay -clock V_EXTSYS0MHUCLK $DEFAULT_DELAYS(EXTSYS0MHUCLK) [get_ports {ESSE0EXTSYS0MHUINT}]
set_output_delay -clock V_EXTSYS0MHUCLK $DEFAULT_DELAYS(EXTSYS0MHUCLK) [get_ports {SEES0EXTSYS0MHUINT}]
set_output_delay -clock V_EXTSYS0MHUCLK $DEFAULT_DELAYS(EXTSYS0MHUCLK) [get_ports {ESSE1EXTSYS0MHUINT}]
set_output_delay -clock V_EXTSYS0MHUCLK $DEFAULT_DELAYS(EXTSYS0MHUCLK) [get_ports {SEES1EXTSYS0MHUINT}]

# EXTSYS0TRACEEXP
set_output_delay -clock V_EXTSYS0ATCLK $DEFAULT_DELAYS(EXTSYS0ATCLK) [get_ports {ATREADYEXTSYS0TRACEEXP}]
set_output_delay -clock V_EXTSYS0ATCLK $DEFAULT_DELAYS(EXTSYS0ATCLK) [get_ports {AFVALIDEXTSYS0TRACEEXP}]
set_output_delay -clock V_EXTSYS0ATCLK $DEFAULT_DELAYS(EXTSYS0ATCLK) [get_ports {SYNCREQEXTSYS0TRACEEXP}]
set_input_delay  -clock V_EXTSYS0ATCLK $DEFAULT_DELAYS(EXTSYS0ATCLK) [get_ports {ATIDEXTSYS0TRACEEXP[*]}]
set_input_delay  -clock V_EXTSYS0ATCLK $DEFAULT_DELAYS(EXTSYS0ATCLK) [get_ports {ATVALIDEXTSYS0TRACEEXP}]
set_input_delay  -clock V_EXTSYS0ATCLK $DEFAULT_DELAYS(EXTSYS0ATCLK) [get_ports {ATDATAEXTSYS0TRACEEXP[*]}]
set_input_delay  -clock V_EXTSYS0ATCLK $DEFAULT_DELAYS(EXTSYS0ATCLK) [get_ports {ATBYTESEXTSYS0TRACEEXP[*]}]
set_input_delay  -clock V_EXTSYS0ATCLK $DEFAULT_DELAYS(EXTSYS0ATCLK) [get_ports {AFREADYEXTSYS0TRACEEXP}]
set_input_delay  -clock V_EXTSYS0ATCLK $DEFAULT_DELAYS(EXTSYS0ATCLK) [get_ports {ATWAKEUPEXTSYS0TRACEEXP}]

# EXTSYS0DBG APB4
set_output_delay -clock V_EXTSYS0DBGCLKM $DEFAULT_DELAYS(EXTSYS0DBGCLKM) [get_ports {PSELEXTSYS0DBG}]
set_output_delay -clock V_EXTSYS0DBGCLKM $DEFAULT_DELAYS(EXTSYS0DBGCLKM) [get_ports {PWAKEUPEXTSYS0DBG}]
set_output_delay -clock V_EXTSYS0DBGCLKM $DEFAULT_DELAYS(EXTSYS0DBGCLKM) [get_ports {PENABLEEXTSYS0DBG}]
set_output_delay -clock V_EXTSYS0DBGCLKM $DEFAULT_DELAYS(EXTSYS0DBGCLKM) [get_ports {PADDREXTSYS0DBG[*]}]
set_output_delay -clock V_EXTSYS0DBGCLKM $DEFAULT_DELAYS(EXTSYS0DBGCLKM) [get_ports {PWRITEEXTSYS0DBG}]
set_output_delay -clock V_EXTSYS0DBGCLKM $DEFAULT_DELAYS(EXTSYS0DBGCLKM) [get_ports {PWDATAEXTSYS0DBG[*]}]
set_output_delay -clock V_EXTSYS0DBGCLKM $DEFAULT_DELAYS(EXTSYS0DBGCLKM) [get_ports {PSTRBEXTSYS0DBG[*]}]
set_output_delay -clock V_EXTSYS0DBGCLKM $DEFAULT_DELAYS(EXTSYS0DBGCLKM) [get_ports {PPROTEXTSYS0DBG[*]}]
set_input_delay  -clock V_EXTSYS0DBGCLKM $DEFAULT_DELAYS(EXTSYS0DBGCLKM) [get_ports {PRDATAEXTSYS0DBG[*]}]
set_input_delay  -clock V_EXTSYS0DBGCLKM $DEFAULT_DELAYS(EXTSYS0DBGCLKM) [get_ports {PREADYEXTSYS0DBG}]
set_input_delay  -clock V_EXTSYS0DBGCLKM $DEFAULT_DELAYS(EXTSYS0DBGCLKM) [get_ports {PSLVERREXTSYS0DBG}]

# EXTSYS0DBG DPAbort
set_output_delay -clock V_EXTSYS0DBGCLKM $DEFAULT_DELAYS(EXTSYS0DBGCLKM) [get_ports {DPABORTEXTSYS0DBG}]

# EXTSYS0EXTDBG
set_input_delay  -clock V_EXTSYS0DBGCLKS $DEFAULT_DELAYS(EXTSYS0DBGCLKS) [get_ports {PSELEXTSYS0EXTDBG}]
set_input_delay  -clock V_EXTSYS0DBGCLKS $DEFAULT_DELAYS(EXTSYS0DBGCLKS) [get_ports {PWAKEUPEXTSYS0EXTDBG}]
set_input_delay  -clock V_EXTSYS0DBGCLKS $DEFAULT_DELAYS(EXTSYS0DBGCLKS) [get_ports {PENABLEEXTSYS0EXTDBG}]
set_input_delay  -clock V_EXTSYS0DBGCLKS $DEFAULT_DELAYS(EXTSYS0DBGCLKS) [get_ports {PADDREXTSYS0EXTDBG[*]}]
set_input_delay  -clock V_EXTSYS0DBGCLKS $DEFAULT_DELAYS(EXTSYS0DBGCLKS) [get_ports {PWRITEEXTSYS0EXTDBG}]
set_input_delay  -clock V_EXTSYS0DBGCLKS $DEFAULT_DELAYS(EXTSYS0DBGCLKS) [get_ports {PWDATAEXTSYS0EXTDBG[*]}]
set_input_delay  -clock V_EXTSYS0DBGCLKS $DEFAULT_DELAYS(EXTSYS0DBGCLKS) [get_ports {PSTRBEXTSYS0EXTDBG[*]}]
set_input_delay  -clock V_EXTSYS0DBGCLKS $DEFAULT_DELAYS(EXTSYS0DBGCLKS) [get_ports {PPROTEXTSYS0EXTDBG[*]}]
set_output_delay -clock V_EXTSYS0DBGCLKS $DEFAULT_DELAYS(EXTSYS0DBGCLKS) [get_ports {PRDATAEXTSYS0EXTDBG[*]}]
set_output_delay -clock V_EXTSYS0DBGCLKS $DEFAULT_DELAYS(EXTSYS0DBGCLKS) [get_ports {PREADYEXTSYS0EXTDBG}]
set_output_delay -clock V_EXTSYS0DBGCLKS $DEFAULT_DELAYS(EXTSYS0DBGCLKS) [get_ports {PSLVERREXTSYS0EXTDBG}]

# EXTSYS0CTICHIN
set_input_delay  -clock V_EXTSYS0CTICLK $DEFAULT_DELAYS(EXTSYS0CTICLK) [get_ports {EXTSYS0CTICHIN[*]}]

# EXTSYS0CTICHOUT
set_output_delay -clock V_EXTSYS0CTICLK $DEFAULT_DELAYS(EXTSYS0CTICLK) [get_ports {EXTSYS0CTICHOUT[*]}]

# EXTSYS0SHDINT
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0SHDINT[*]}]

# EXTSYS0ACLKQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0ACLKQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0ACLKQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0ACLKQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0ACLKQACTIVE}]

# EXTSYS0MHUQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0MHUCLKQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0MHUCLKQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0MHUCLKQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0MHUCLKQACTIVE}]

# EXTSYS0ATCLKQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0ATCLKQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0ATCLKQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0ATCLKQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0ATCLKQACTIVE}]

# EXTSYS0DBGCLKMQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0DBGCLKMQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0DBGCLKMQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0DBGCLKMQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0DBGCLKMQACTIVE}]

# EXTSYS0DBGCLKSQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0DBGCLKSQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0DBGCLKSQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0DBGCLKSQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0DBGCLKSQACTIVE}]

# EXTSYS0CTICLKQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0CTICLKQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0CTICLKQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0CTICLKQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0CTICLKQACTIVE}]

# EXTSYS0MEMPWRQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0MEMPWRQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0MEMPWRQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0MEMPWRQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0MEMPWRQACTIVE}]

# EXTSYS0MHUPWRQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0MHUPWRQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0MHUPWRQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0MHUPWRQDENY}]

# EXTSYS0MHUPWRREQ
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0MHUPWRREQACTIVE}]

# EXTSYS0TRACEEXPPRQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0TRACEEXPPWRQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0TRACEEXPPWRQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0TRACEEXPPWRQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0TRACEEXPPWRQACTIVE}]

# EXTSYS0DBGPWRQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0DBGPWRQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0DBGPWRQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0DBGPWRQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0DBGPWRQACTIVE}]

# EXTSYS0EXTDBGPWR
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0EXTDBGPWRQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0EXTDBGPWRQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0EXTDBGPWRQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0EXTDBGPWRQACTIVE}]

# EXTSYS0CTIINPWRQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0CTIINPWRQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0CTIINPWRQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0CTIINPWRQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0CTIINPWRQACTIVE}]

# EXTSYS0CTIOUTPWR
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0CTIOUTPWRQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0CTIOUTPWRQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0CTIOUTPWRQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0CTIOUTPWRQACTIVE}]

# EXTSYS0DBGTOPQ
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0DBGTOPQREQn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0DBGTOPQACCEPTn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0DBGTOPQDENY}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0DBGTOPQACTIVE}]

# EXTSYS0SYSTOPQ
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0SYSTOPQREQn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0SYSTOPQACCEPTn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0SYSTOPQDENY}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0SYSTOPQACTIVE}]

# EXTSYS0AONTOPQ
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0AONTOPQREQn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0AONTOPQACCEPTn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0AONTOPQDENY}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0AONTOPQACTIVE}]

# EXTSYS0PWRREQ
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0EXTDBGROMCDBGPWRUPREQ}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0EXTDBGROMCDBGPWRUPACK}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0AXIAPROMCSYSPWRUPREQ}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0AXIAPROMCSYSPWRUPACK}]

# EXTSYS0RSTSYN
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS0RSTSYN[*]}]

#######################################
# External System Harness 1 Interfaces
#######################################

# Resets
set_input_delay  -clock V_EXTSYS1DBGCLKS $DEFAULT_DELAYS(EXTSYS1DBGCLKS) [get_ports {EXTSYS1DBGPRESETSn}]
set_input_delay  -clock V_EXTSYS1DBGCLKM $DEFAULT_DELAYS(EXTSYS1DBGCLKM) [get_ports {EXTSYS1DBGPRESETMn}]
set_input_delay  -clock V_EXTSYS1MHUCLK  $DEFAULT_DELAYS(EXTSYS1MHUCLK)  [get_ports {EXTSYS1MHURESETn}]
set_input_delay  -clock V_EXTSYS1ATCLK   $DEFAULT_DELAYS(EXTSYS1ATCLK)   [get_ports {EXTSYS1ATRESETn}]
set_input_delay  -clock V_EXTSYS1CTICLK  $DEFAULT_DELAYS(EXTSYS1CTICLK)  [get_ports {EXTSYS1CTIRESETn}]
set_input_delay  -clock V_EXTSYS1ACLK    $DEFAULT_DELAYS(EXTSYS1ACLK)    [get_ports {EXTSYS1ARESETn}]
set_output_delay -clock V_ASYNC          $DEFAULT_DELAYS(V_ASYNC)        [get_ports {EXTSYS1PORESETn}]

set_output_delay -clock V_ASYNC          $DEFAULT_DELAYS(V_ASYNC)        [get_ports {EXTSYS1CPUWAIT}]

# EXTSYS1MEM
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {AWAKEUPEXTSYS1MEM}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {AWIDEXTSYS1MEM[*]}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {AWADDREXTSYS1MEM[*]}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {AWLENEXTSYS1MEM[*]}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {AWSIZEEXTSYS1MEM[*]}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {AWBURSTEXTSYS1MEM[*]}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {AWLOCKEXTSYS1MEM}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {AWCACHEEXTSYS1MEM[*]}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {AWPROTEXTSYS1MEM[*]}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {AWREGIONEXTSYS1MEM[*]}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {AWVALIDEXTSYS1MEM}]
set_output_delay -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {AWREADYEXTSYS1MEM}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {WSTRBEXTSYS1MEM[*]}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {WLASTEXTSYS1MEM}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {WVALIDEXTSYS1MEM}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {WDATAEXTSYS1MEM[*]}]
set_output_delay -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {WREADYEXTSYS1MEM}]
set_output_delay -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {BIDEXTSYS1MEM[*]}]
set_output_delay -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {BRESPEXTSYS1MEM[*]}]
set_output_delay -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {BVALIDEXTSYS1MEM}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {BREADYEXTSYS1MEM}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {ARIDEXTSYS1MEM[*]}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {ARADDREXTSYS1MEM[*]}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {ARLENEXTSYS1MEM[*]}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {ARSIZEEXTSYS1MEM[*]}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {ARBURSTEXTSYS1MEM[*]}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {ARLOCKEXTSYS1MEM}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {ARCACHEEXTSYS1MEM[*]}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {ARPROTEXTSYS1MEM[*]}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {ARREGIONEXTSYS1MEM[*]}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {ARVALIDEXTSYS1MEM}]
set_output_delay -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {ARREADYEXTSYS1MEM}]
set_output_delay -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {RIDEXTSYS1MEM[*]}]
set_output_delay -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {RRESPEXTSYS1MEM[*]}]
set_output_delay -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {RLASTEXTSYS1MEM}]
set_output_delay -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {RVALIDEXTSYS1MEM}]
set_output_delay -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {RDATAEXTSYS1MEM[*]}]
set_input_delay  -clock V_EXTSYS1ACLK $DEFAULT_DELAYS(EXTSYS1ACLK) [get_ports {RREADYEXTSYS1MEM}]

# EXTSYS1MHU
set_input_delay  -clock V_EXTSYS1MHUCLK $DEFAULT_DELAYS(EXTSYS1MHUCLK) [get_ports {PSELEXTSYS1MHU}]
set_input_delay  -clock V_EXTSYS1MHUCLK $DEFAULT_DELAYS(EXTSYS1MHUCLK) [get_ports {PWAKEUPEXTSYS1MHU}]
set_input_delay  -clock V_EXTSYS1MHUCLK $DEFAULT_DELAYS(EXTSYS1MHUCLK) [get_ports {PENABLEEXTSYS1MHU}]
set_input_delay  -clock V_EXTSYS1MHUCLK $DEFAULT_DELAYS(EXTSYS1MHUCLK) [get_ports {PADDREXTSYS1MHU[*]}]
set_input_delay  -clock V_EXTSYS1MHUCLK $DEFAULT_DELAYS(EXTSYS1MHUCLK) [get_ports {PWRITEEXTSYS1MHU}]
set_input_delay  -clock V_EXTSYS1MHUCLK $DEFAULT_DELAYS(EXTSYS1MHUCLK) [get_ports {PWDATAEXTSYS1MHU[*]}]
set_input_delay  -clock V_EXTSYS1MHUCLK $DEFAULT_DELAYS(EXTSYS1MHUCLK) [get_ports {PSTRBEXTSYS1MHU[*]}]
set_input_delay  -clock V_EXTSYS1MHUCLK $DEFAULT_DELAYS(EXTSYS1MHUCLK) [get_ports {PPROTEXTSYS1MHU[*]}]
set_output_delay -clock V_EXTSYS1MHUCLK $DEFAULT_DELAYS(EXTSYS1MHUCLK) [get_ports {PRDATAEXTSYS1MHU[*]}]
set_output_delay -clock V_EXTSYS1MHUCLK $DEFAULT_DELAYS(EXTSYS1MHUCLK) [get_ports {PREADYEXTSYS1MHU}]
set_output_delay -clock V_EXTSYS1MHUCLK $DEFAULT_DELAYS(EXTSYS1MHUCLK) [get_ports {PSLVERREXTSYS1MHU}]

# EXTSYS1MHUINT
set_output_delay -clock V_EXTSYS1MHUCLK $DEFAULT_DELAYS(EXTSYS1MHUCLK) [get_ports {ESH0EXTSYS1MHUINT}]
set_output_delay -clock V_EXTSYS1MHUCLK $DEFAULT_DELAYS(EXTSYS1MHUCLK) [get_ports {HES0EXTSYS1MHUINT}]
set_output_delay -clock V_EXTSYS1MHUCLK $DEFAULT_DELAYS(EXTSYS1MHUCLK) [get_ports {ESH1EXTSYS1MHUINT}]
set_output_delay -clock V_EXTSYS1MHUCLK $DEFAULT_DELAYS(EXTSYS1MHUCLK) [get_ports {HES1EXTSYS1MHUINT}]
set_output_delay -clock V_EXTSYS1MHUCLK $DEFAULT_DELAYS(EXTSYS1MHUCLK) [get_ports {ESSE0EXTSYS1MHUINT}]
set_output_delay -clock V_EXTSYS1MHUCLK $DEFAULT_DELAYS(EXTSYS1MHUCLK) [get_ports {SEES0EXTSYS1MHUINT}]
set_output_delay -clock V_EXTSYS1MHUCLK $DEFAULT_DELAYS(EXTSYS1MHUCLK) [get_ports {ESSE1EXTSYS1MHUINT}]
set_output_delay -clock V_EXTSYS1MHUCLK $DEFAULT_DELAYS(EXTSYS1MHUCLK) [get_ports {SEES1EXTSYS1MHUINT}]

# EXTSYS1TRACEEXP
set_output_delay -clock V_EXTSYS1ATCLK $DEFAULT_DELAYS(EXTSYS1ATCLK) [get_ports {ATREADYEXTSYS1TRACEEXP}]
set_output_delay -clock V_EXTSYS1ATCLK $DEFAULT_DELAYS(EXTSYS1ATCLK) [get_ports {AFVALIDEXTSYS1TRACEEXP}]
set_output_delay -clock V_EXTSYS1ATCLK $DEFAULT_DELAYS(EXTSYS1ATCLK) [get_ports {SYNCREQEXTSYS1TRACEEXP}]
set_input_delay  -clock V_EXTSYS1ATCLK $DEFAULT_DELAYS(EXTSYS1ATCLK) [get_ports {ATIDEXTSYS1TRACEEXP[*]}]
set_input_delay  -clock V_EXTSYS1ATCLK $DEFAULT_DELAYS(EXTSYS1ATCLK) [get_ports {ATVALIDEXTSYS1TRACEEXP}]
set_input_delay  -clock V_EXTSYS1ATCLK $DEFAULT_DELAYS(EXTSYS1ATCLK) [get_ports {ATDATAEXTSYS1TRACEEXP[*]}]
set_input_delay  -clock V_EXTSYS1ATCLK $DEFAULT_DELAYS(EXTSYS1ATCLK) [get_ports {ATBYTESEXTSYS1TRACEEXP[*]}]
set_input_delay  -clock V_EXTSYS1ATCLK $DEFAULT_DELAYS(EXTSYS1ATCLK) [get_ports {AFREADYEXTSYS1TRACEEXP}]
set_input_delay  -clock V_EXTSYS1ATCLK $DEFAULT_DELAYS(EXTSYS1ATCLK) [get_ports {ATWAKEUPEXTSYS1TRACEEXP}]

# EXTSYS1DBG APB4
set_output_delay -clock V_EXTSYS1DBGCLKM $DEFAULT_DELAYS(EXTSYS1DBGCLKM) [get_ports {PSELEXTSYS1DBG}]
set_output_delay -clock V_EXTSYS1DBGCLKM $DEFAULT_DELAYS(EXTSYS1DBGCLKM) [get_ports {PWAKEUPEXTSYS1DBG}]
set_output_delay -clock V_EXTSYS1DBGCLKM $DEFAULT_DELAYS(EXTSYS1DBGCLKM) [get_ports {PENABLEEXTSYS1DBG}]
set_output_delay -clock V_EXTSYS1DBGCLKM $DEFAULT_DELAYS(EXTSYS1DBGCLKM) [get_ports {PADDREXTSYS1DBG[*]}]
set_output_delay -clock V_EXTSYS1DBGCLKM $DEFAULT_DELAYS(EXTSYS1DBGCLKM) [get_ports {PWRITEEXTSYS1DBG}]
set_output_delay -clock V_EXTSYS1DBGCLKM $DEFAULT_DELAYS(EXTSYS1DBGCLKM) [get_ports {PWDATAEXTSYS1DBG[*]}]
set_output_delay -clock V_EXTSYS1DBGCLKM $DEFAULT_DELAYS(EXTSYS1DBGCLKM) [get_ports {PSTRBEXTSYS1DBG[*]}]
set_output_delay -clock V_EXTSYS1DBGCLKM $DEFAULT_DELAYS(EXTSYS1DBGCLKM) [get_ports {PPROTEXTSYS1DBG[*]}]
set_input_delay  -clock V_EXTSYS1DBGCLKM $DEFAULT_DELAYS(EXTSYS1DBGCLKM) [get_ports {PRDATAEXTSYS1DBG[*]}]
set_input_delay  -clock V_EXTSYS1DBGCLKM $DEFAULT_DELAYS(EXTSYS1DBGCLKM) [get_ports {PREADYEXTSYS1DBG}]
set_input_delay  -clock V_EXTSYS1DBGCLKM $DEFAULT_DELAYS(EXTSYS1DBGCLKM) [get_ports {PSLVERREXTSYS1DBG}]

# EXTSYS1DBG DPAbort
set_output_delay -clock V_EXTSYS1DBGCLKM $DEFAULT_DELAYS(EXTSYS1DBGCLKM) [get_ports {DPABORTEXTSYS1DBG}]

# EXTSYS1EXTDBG
set_input_delay  -clock V_EXTSYS1DBGCLKS $DEFAULT_DELAYS(EXTSYS1DBGCLKS) [get_ports {PSELEXTSYS1EXTDBG}]
set_input_delay  -clock V_EXTSYS1DBGCLKS $DEFAULT_DELAYS(EXTSYS1DBGCLKS) [get_ports {PWAKEUPEXTSYS1EXTDBG}]
set_input_delay  -clock V_EXTSYS1DBGCLKS $DEFAULT_DELAYS(EXTSYS1DBGCLKS) [get_ports {PENABLEEXTSYS1EXTDBG}]
set_input_delay  -clock V_EXTSYS1DBGCLKS $DEFAULT_DELAYS(EXTSYS1DBGCLKS) [get_ports {PADDREXTSYS1EXTDBG[*]}]
set_input_delay  -clock V_EXTSYS1DBGCLKS $DEFAULT_DELAYS(EXTSYS1DBGCLKS) [get_ports {PWRITEEXTSYS1EXTDBG}]
set_input_delay  -clock V_EXTSYS1DBGCLKS $DEFAULT_DELAYS(EXTSYS1DBGCLKS) [get_ports {PWDATAEXTSYS1EXTDBG[*]}]
set_input_delay  -clock V_EXTSYS1DBGCLKS $DEFAULT_DELAYS(EXTSYS1DBGCLKS) [get_ports {PSTRBEXTSYS1EXTDBG[*]}]
set_input_delay  -clock V_EXTSYS1DBGCLKS $DEFAULT_DELAYS(EXTSYS1DBGCLKS) [get_ports {PPROTEXTSYS1EXTDBG[*]}]
set_output_delay -clock V_EXTSYS1DBGCLKS $DEFAULT_DELAYS(EXTSYS1DBGCLKS) [get_ports {PRDATAEXTSYS1EXTDBG[*]}]
set_output_delay -clock V_EXTSYS1DBGCLKS $DEFAULT_DELAYS(EXTSYS1DBGCLKS) [get_ports {PREADYEXTSYS1EXTDBG}]
set_output_delay -clock V_EXTSYS1DBGCLKS $DEFAULT_DELAYS(EXTSYS1DBGCLKS) [get_ports {PSLVERREXTSYS1EXTDBG}]

# EXTSYS1CTICHIN
set_input_delay  -clock V_EXTSYS1CTICLK $DEFAULT_DELAYS(EXTSYS1CTICLK) [get_ports {EXTSYS1CTICHIN[*]}]

# EXTSYS1CTICHOUT
set_output_delay -clock V_EXTSYS1CTICLK $DEFAULT_DELAYS(EXTSYS1CTICLK) [get_ports {EXTSYS1CTICHOUT[*]}]

# EXTSYS1SHDINT
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1SHDINT[*]}]

# EXTSYS1ACLKQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1ACLKQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1ACLKQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1ACLKQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1ACLKQACTIVE}]

# EXTSYS1MHUQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1MHUCLKQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1MHUCLKQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1MHUCLKQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1MHUCLKQACTIVE}]

# EXTSYS1ATCLKQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1ATCLKQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1ATCLKQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1ATCLKQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1ATCLKQACTIVE}]

# EXTSYS1DBGCLKMQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1DBGCLKMQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1DBGCLKMQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1DBGCLKMQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1DBGCLKMQACTIVE}]

# EXTSYS1DBGCLKSQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1DBGCLKSQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1DBGCLKSQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1DBGCLKSQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1DBGCLKSQACTIVE}]

# EXTSYS1CTICLKQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1CTICLKQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1CTICLKQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1CTICLKQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1CTICLKQACTIVE}]

# EXTSYS1MEMPWRQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1MEMPWRQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1MEMPWRQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1MEMPWRQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1MEMPWRQACTIVE}]

# EXTSYS1MHUPWRQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1MHUPWRQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1MHUPWRQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1MHUPWRQDENY}]

# EXTSYS1MHUPWRREQ
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1MHUPWRREQACTIVE}]

# EXTSYS1TRACEEXPPRQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1TRACEEXPPWRQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1TRACEEXPPWRQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1TRACEEXPPWRQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1TRACEEXPPWRQACTIVE}]

# EXTSYS1DBGPWRQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1DBGPWRQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1DBGPWRQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1DBGPWRQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1DBGPWRQACTIVE}]

# EXTSYS1EXTDBGPWR
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1EXTDBGPWRQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1EXTDBGPWRQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1EXTDBGPWRQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1EXTDBGPWRQACTIVE}]

# EXTSYS1CTIINPWRQ
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1CTIINPWRQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1CTIINPWRQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1CTIINPWRQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1CTIINPWRQACTIVE}]

# EXTSYS1CTIOUTPWR
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1CTIOUTPWRQREQn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1CTIOUTPWRQACCEPTn}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1CTIOUTPWRQDENY}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1CTIOUTPWRQACTIVE}]

# EXTSYS1DBGTOPQ
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1DBGTOPQREQn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1DBGTOPQACCEPTn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1DBGTOPQDENY}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1DBGTOPQACTIVE}]

# EXTSYS1SYSTOPQ
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1SYSTOPQREQn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1SYSTOPQACCEPTn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1SYSTOPQDENY}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1SYSTOPQACTIVE}]

# EXTSYS1AONTOPQ
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1AONTOPQREQn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1AONTOPQACCEPTn}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1AONTOPQDENY}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1AONTOPQACTIVE}]

# EXTSYS1PWRREQ
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1EXTDBGROMCDBGPWRUPREQ}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1EXTDBGROMCDBGPWRUPACK}]
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1AXIAPROMCSYSPWRUPREQ}]
set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1AXIAPROMCSYSPWRUPACK}]

# EXTSYS1RSTSYN
set_output_delay -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {EXTSYS1RSTSYN[*]}]


###############################################
# Ports defined during physical implementation
###############################################

if {[sizeof_collection [get_ports -quiet {LP_ISOLATENEXTSYS0TOP}]] > 0} {
  set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {LP_ISOLATENEXTSYS0TOP}]
}

if {[sizeof_collection [get_ports -quiet {LP_ISOLATENEXTSYS1TOP}]] > 0} {
  set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {LP_ISOLATENEXTSYS1TOP}]
}

if {[sizeof_collection [get_ports -quiet {LP_LPWRNEXTSYS0TOP}]] > 0} {
  set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {LP_LPWRNEXTSYS0TOP}]
}

if {[sizeof_collection [get_ports -quiet {LP_LPWRNEXTSYS1TOP}]] > 0} {
  set_input_delay  -clock V_ASYNC $DEFAULT_DELAYS(V_ASYNC) [get_ports {LP_LPWRNEXTSYS1TOP}]
}



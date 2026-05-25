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
# Purpose : Functional Mode SDC for SSE-710
# -----------------------------------------------------------------------------
#
# This file contains all of the technology-independent timing constraints
# required for implementation of the SSE-710 top level design, in primary functional
# mode.
#
# NOTE: these constraints are intended for implementation/OOB purposes they are
#       currently NOT sign off quality

##############################################
# Determine CPU name based on config variable
##############################################

# HOST_CPU_TYPE : 3
# CPU type : a53
# CPU name : ca53#################################################

set sdc_version 2.0

set_units -time ns

if {![info exists ::env(LOGICAL_PATH)]} {
  set ::env(LOGICAL_PATH) ../../logical
}
set CONSTRAINT_DIR $::env(LOGICAL_PATH)/top_sse710_r0_3/top_sse710_r0_aontop_3/constraints

source ${CONSTRAINT_DIR}/procs.sdc

# Forcing the below variable to always be 1

set ::env(ALLOW_CDC_PATHS) 1

#######################
# Constant Definitions
#######################

array unset FREQUENCIES
array unset PERIODS
array unset DFT_CONSTRAINTS

set ACLK_FREQUENCY "400 MHz"
set DBGCLK_FREQUENCY "200 MHz"
set SECENCCLK_FREQUENCY "200 MHz"

# S32KCLK clock period and CPUCLK clock period adjusted 
# to pass unexpandable clocks check in PrimeTime and Design Compiler.

set CPUCLK_FREQUENCY "694.444444 MHz"
set S32KCLK_FREQUENCY "1.111111 MHz"
set CPUCLK_PERIOD 1.44
set S32KCLK_PERIOD 900

# The frequencies of key clocks in the design - all external clocks and any
# internal clocks involved in other constraint definitions
array set FREQUENCIES [list \
  REFCLK                          "100 MHz" \
  S32KCLK                $S32KCLK_FREQUENCY \
  SYSPLL                          "800 MHz" \
  CPUPLL                  $CPUCLK_FREQUENCY \
  EXTSYS0ACLK                     "200 MHz" \
  EXTSYS0ATCLK                    "200 MHz" \
  EXTSYS0CTICLK                   "200 MHz" \
  EXTSYS0DBGCLKM                  "200 MHz" \
  EXTSYS0DBGCLKS                  "200 MHz" \
  EXTSYS0MHUCLK                   "200 MHz" \
  EXTSYS1ACLK                     "200 MHz" \
  EXTSYS1ATCLK                    "200 MHz" \
  EXTSYS1CTICLK                   "200 MHz" \
  EXTSYS1DBGCLKM                  "200 MHz" \
  EXTSYS1DBGCLKS                  "200 MHz" \
  EXTSYS1MHUCLK                   "200 MHz" \
  SWCLKTCK                         "50 MHz" \
  SECENCREFCLK                    "100 MHz" \
  TRACECLKIN                      "100 MHz" \
  UARTCLK                         "100 MHz" \
  SYSPLL_ACLK_2             $ACLK_FREQUENCY \
  SYSPLL_DBGCLK_4         $DBGCLK_FREQUENCY \
  SYSPLL_SECENCCLK_4   $SECENCCLK_FREQUENCY \
  SECENCCLK_SECENCDIVCLK_2        "100 MHz" \
  CPUPLL_HOSTCPUCLK_1     $CPUCLK_FREQUENCY \
  SYSPLL_GICCLK_2                 "400 MHz" \
  V_ACLK                    $ACLK_FREQUENCY \
  V_DBGCLK                $DBGCLK_FREQUENCY \
  V_SYSPLL_SECENCCLK_4 $SECENCCLK_FREQUENCY \
  SYSPLL_CTRLCLK_2                "400 MHz" \
  UARTCLK_HOSTUARTCLK_1           "100 MHz" \
  SYSPLL_HOSTCPUCLK_1             "800 MHz" \
  V_ASYNC                          "40 MHz" \
]

# Use the calculate_period procedure defined in procs.sdc to calculate the clock
# period in nanoseconds
dict for {clk frequency} [array get FREQUENCIES] {
  set PERIODS($clk) [calculate_period $frequency]
}

# Explicitly setting the period for S32KCLK and CPUCLK
# since frequency is not an integer and conversion from FREQUENCY may not yield the most accurate period
set PERIODS(S32KCLK) $S32KCLK_PERIOD
set PERIODS(CPUPLL) $CPUCLK_PERIOD
set PERIODS(CPUPLL_HOSTCPUCLK_1) $CPUCLK_PERIOD


set ACLK_CLOCK_UNIT_PATH          {u_pd_systop/u_clk_gen_systop/u_e_clk_f1_unit_aclk_systop}
set CTRLCLK_CLOCK_UNIT_PATH       {u_pd_systop/u_clk_gen_systop/u_e_clk_f1_unit_ctrlclk_systop}
set GICCLK_CLOCK_UNIT_PATH        {u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_gicclk_clustop}
set HOSTCPUCLK_CLOCK_UNIT_PATH    {u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_hostcpuclk_clustop}
set SECENCCLK_CLOCK_UNIT_PATH     {u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_secencclk_aon_secenc_clk}
set SECENCDIVCLK_CLOCK_UNIT_PATH  {u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_secencdivclk_i_secenc_clk}
set DBGCLK_CLOCK_UNIT_PATH        {u_pd_dbgtop_f0/u_clk_gen_dbgclk/u_e_clk_f1_unit_dbgclk_dbgtop}
set UARTCLK_CLOCK_UNIT_PATH       {u_system_control_f0_aontop/u_clk_f1_top_uartclk/u_e_clk_f1_unit_hostuartclk_uartclk}
set TRACECLK_REG_PATH             {u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_soc_tpiu/u_css600_tpiu_trace_clk/traceclk_reg}
set CPU_CLUSTER_PATH              {u_pd_systop/u_pd_clustop/u_cpu_gic_socket/cortexa53_inst_u_cortex_a53}
set L2_RAM_PATH                   "${CPU_CLUSTER_PATH}/u_ca53_l2/g_l2_rams_u_ca53_l2_datarams"

# Define all the clocks which are synchronous to SYSPLL, to avoid a long list
# definition later on in the constraint file
set SYSPLL_DOMAIN_CLOCKS {
  SYSPLL
  SYSPLL_ACLK_2 SYSPLL_ACLK_1
  SYSPLL_CTRLCLK_2 SYSPLL_CTRLCLK_1
  SYSPLL_GICCLK_2 SYSPLL_GICCLK_1
  SYSPLL_HOSTCPUCLK_2 SYSPLL_HOSTCPUCLK_1
  SYSPLL_SECENCCLK_4 SYSPLL_SECENCCLK_1
  SYSPLL_DBGCLK_4 SYSPLL_DBGCLK_1
  SECENCCLK_SECENCDIVCLK_1 SECENCCLK_SECENCDIVCLK_2
  V_ACLK
  V_DBGCLK
  V_SYSPLL_SECENCCLK_4
}

# Define the DFT port constraints for functional mode
# DFTSI[*] and DFTRAMBYP are added during implementation, and
# are not present in the RTL
array set DFT_CONSTRAINTS {
  {DFTSE}                 0
}

set ASYNCHRONOUS_PORT_MAX_DELAY 15.0

set NON_CRITICAL_CROSSING_LATENCY_TARGET 10.0

set CPU_CTI_MAX_DELAY [expr {
  min($PERIODS(CPUPLL_HOSTCPUCLK_1), $PERIODS(SYSPLL_DBGCLK_4))
}]


#########################
# Create External Clocks
#########################

# Use the standard SDC 'create_clock' procedure to define clocks on all input
# clock ports

create_clock -name REFCLK          -period $PERIODS(REFCLK)          [get_ports REFCLK]
create_clock -name S32KCLK         -period $PERIODS(S32KCLK)         [get_ports S32KCLK]
create_clock -name SYSPLL          -period $PERIODS(SYSPLL)          [get_ports SYSPLL]
create_clock -name CPUPLL          -period $PERIODS(CPUPLL)          [get_ports CPUPLL]
create_clock -name EXTSYS0ACLK     -period $PERIODS(EXTSYS0ACLK)     [get_ports EXTSYS0ACLK]
create_clock -name EXTSYS0ATCLK    -period $PERIODS(EXTSYS0ATCLK)    [get_ports EXTSYS0ATCLK]
create_clock -name EXTSYS0CTICLK   -period $PERIODS(EXTSYS0CTICLK)   [get_ports EXTSYS0CTICLK]
create_clock -name EXTSYS0DBGCLKM  -period $PERIODS(EXTSYS0DBGCLKM)  [get_ports EXTSYS0DBGCLKM]
create_clock -name EXTSYS0DBGCLKS  -period $PERIODS(EXTSYS0DBGCLKS)  [get_ports EXTSYS0DBGCLKS]
create_clock -name EXTSYS0MHUCLK   -period $PERIODS(EXTSYS0MHUCLK)   [get_ports EXTSYS0MHUCLK]
create_clock -name EXTSYS1ACLK     -period $PERIODS(EXTSYS1ACLK)     [get_ports EXTSYS1ACLK]
create_clock -name EXTSYS1ATCLK    -period $PERIODS(EXTSYS1ATCLK)    [get_ports EXTSYS1ATCLK]
create_clock -name EXTSYS1CTICLK   -period $PERIODS(EXTSYS1CTICLK)   [get_ports EXTSYS1CTICLK]
create_clock -name EXTSYS1DBGCLKM  -period $PERIODS(EXTSYS1DBGCLKM)  [get_ports EXTSYS1DBGCLKM]
create_clock -name EXTSYS1DBGCLKS  -period $PERIODS(EXTSYS1DBGCLKS)  [get_ports EXTSYS1DBGCLKS]
create_clock -name EXTSYS1MHUCLK   -period $PERIODS(EXTSYS1MHUCLK)   [get_ports EXTSYS1MHUCLK]
create_clock -name SWCLKTCK        -period $PERIODS(SWCLKTCK)        [get_ports SWCLKTCK]
create_clock -name SECENCREFCLK    -period $PERIODS(SECENCREFCLK)    [get_ports SECENCREFCLK]
create_clock -name TRACECLKIN      -period $PERIODS(TRACECLKIN)      [get_ports TRACECLKIN]
create_clock -name UARTCLK         -period $PERIODS(UARTCLK)         [get_ports UARTCLK]


########################
# Define Clock Division
########################

# Use the 'constrain_divider' and 'constrain_selector' procedures defined in procs.sdc
# to create generated clocks and control propagation. See the procedure
# definitions for further information.

# SYSPLL_ACLK_2 is generated from SYSPLL, through a divide-by-2 clock division.
# The SYSPLL_ACLK_1 clock is also generated on the clock gate within the
# divider, but propagation out of the divider is blocked for this clock.
# SYSPLL_ACLK_2 is selected as the output of the subsequent clock selector,
# rather than REFCLK, since SYSPLL_ACLK_2 is the faster clock. REFCLK selection
# would need to be propagated in an alternative functional mode

constrain_divider \
  -path "${ACLK_CLOCK_UNIT_PATH}/u_clkrst_f1_clkdiv_modulate_top_syspll" \
  -source_clock SYSPLL \
  -divided_clock SYSPLL_ACLK_2 -edges {1 3 5} \
  -bypass_clock SYSPLL_ACLK_1 -bypass 0
constrain_selector -path $ACLK_CLOCK_UNIT_PATH \
  -clocks {REFCLK SYSPLL_ACLK_2} \
  -selected SYSPLL_ACLK_2

# See comment for ACLK - clock generation is exactly the same for the CTRLCLK
# clocks.
constrain_divider \
  -path "${CTRLCLK_CLOCK_UNIT_PATH}/u_clkrst_f1_clkdiv_modulate_top_syspll" \
  -source_clock SYSPLL \
  -divided_clock SYSPLL_CTRLCLK_2 -edges {1 3 5} \
  -bypass_clock SYSPLL_CTRLCLK_1 -bypass 0
constrain_selector -path $CTRLCLK_CLOCK_UNIT_PATH \
  -clocks {REFCLK SYSPLL_CTRLCLK_2} \
  -selected SYSPLL_CTRLCLK_2

# See comment for ACLK - clock generation is exactly the same for the GICCLK
# clocks.
constrain_divider \
  -path "${GICCLK_CLOCK_UNIT_PATH}/u_clkrst_f1_clkdiv_modulate_top_syspll" \
  -source_clock SYSPLL \
  -divided_clock SYSPLL_GICCLK_2 -edges {1 3 5} \
  -bypass_clock SYSPLL_GICCLK_1 -bypass 0
constrain_selector -path $GICCLK_CLOCK_UNIT_PATH \
  -clocks {REFCLK SYSPLL_GICCLK_2} \
  -selected SYSPLL_GICCLK_2

# HOSTCPUCLK clock generation is slightly different, in that two divided clocks
# are generated rather than one. CPUPLL_HOSTCPUCLK_2 is generated by divide-by-2
# division, but the divided clock does not leave the divider - instead,
# CPUPLL_HOSTCPUCLK_1 from the internal clock gate leaves the divider and passes
# to the clock selection block. The same happens for the SYSPLL_HOSTCPUCLK_2 and
# SYSPLL_HOSTCPUCLK_1 clocks. Finally, the divider selects the
# CPUPLL_HOSTCPUCLK_1 - although the SYSPLL_HOSTCPUCLK_1 clock is faster, the
# CPU target frequency was 750 MHz for Arm trial implementation.
constrain_divider \
  -path "${HOSTCPUCLK_CLOCK_UNIT_PATH}/u_clkrst_f1_clkdiv_modulate_top_cpupll" \
  -source_clock CPUPLL \
  -divided_clock CPUPLL_HOSTCPUCLK_2 -edges {1 3 5} \
  -bypass_clock CPUPLL_HOSTCPUCLK_1 -bypass 1
constrain_divider \
  -path "${HOSTCPUCLK_CLOCK_UNIT_PATH}/u_clkrst_f1_clkdiv_modulate_top_syspll" \
  -source_clock SYSPLL \
  -divided_clock SYSPLL_HOSTCPUCLK_2 -edges {1 3 5} \
  -bypass_clock SYSPLL_HOSTCPUCLK_1 -bypass 1
constrain_selector -path $HOSTCPUCLK_CLOCK_UNIT_PATH \
  -clocks {REFCLK SYSPLL_HOSTCPUCLK_1 CPUPLL_HOSTCPUCLK_1} \
  -selected CPUPLL_HOSTCPUCLK_1

# See comment for ACLK - clock generation is exactly the same for the SECENCCLK
# clocks.
constrain_divider \
  -path "${SECENCCLK_CLOCK_UNIT_PATH}/u_clkrst_f1_clkdiv_modulate_top_syspll" \
  -source_clock SYSPLL \
  -divided_clock SYSPLL_SECENCCLK_4 -edges {1 5 9} \
  -bypass_clock SYSPLL_SECENCCLK_1 -bypass 0
constrain_selector -path $SECENCCLK_CLOCK_UNIT_PATH \
  -clocks {SECENCREFCLK SYSPLL_SECENCCLK_4} \
  -selected SYSPLL_SECENCCLK_4

# See comment for ACLK - apart from using SYSPLL_SECENCCLK_4 as the master clock
# rather than SYSPLL, clock generation is exactly the same for the SECENCDIVCLK
# clocks.
###################
# Note that there is a bypass clock (SECENCCLK_SECENCDIVCLK_1) and a divide-by-2 clock
# (SECENCCLK_SECENCDIVCLK_2) being generated from the clock divider module. 
# But here only the divide-by-2 clock is being propagated forward and the bypass clock
# is blocked. However based on the software configuration either of the two clocks can be 
# chosen to propagate forward in the real system. If the partners intend to use this
# configurability then they should make sure that the timing analysis is carried out with
# the bypass clock propagated.
###################
constrain_divider \
  -path "${SECENCDIVCLK_CLOCK_UNIT_PATH}/u_clkrst_f1_clkdiv_modulate_top_secencdivclk_i" \
  -source_clock SYSPLL_SECENCCLK_4 \
  -divided_clock SECENCCLK_SECENCDIVCLK_2 -edges {1 3 5} \
  -bypass_clock SECENCCLK_SECENCDIVCLK_1 -bypass 0

# See comment for ACLK - clock generation is exactly the same for the DBGCLK
# clocks.
constrain_divider \
  -path "${DBGCLK_CLOCK_UNIT_PATH}/u_clkrst_f1_clkdiv_modulate_top_syspll" \
  -source_clock SYSPLL \
  -divided_clock SYSPLL_DBGCLK_4 -edges {1 5 9} \
  -bypass_clock SYSPLL_DBGCLK_1 -bypass 0
constrain_selector -path $DBGCLK_CLOCK_UNIT_PATH \
  -clocks {REFCLK SYSPLL_DBGCLK_4} \
  -selected SYSPLL_DBGCLK_4

# See comment for ACLK - apart from using UARTCLK as the master clock rather
# than SYSPLL, clock generation is exactly the same for the HOSTUARTCLK clocks.
constrain_divider \
  -path "${UARTCLK_CLOCK_UNIT_PATH}/u_clkrst_f1_clkdiv_modulate_top_uartclk" \
  -source_clock UARTCLK \
  -divided_clock UARTCLK_HOSTUARTCLK_2 -edges {1 3 5} \
  -bypass_clock UARTCLK_HOSTUARTCLK_1 -bypass 1
constrain_selector -path $UARTCLK_CLOCK_UNIT_PATH \
  -clocks {REFCLK UARTCLK_HOSTUARTCLK_1 S32KCLK} \
  -selected UARTCLK_HOSTUARTCLK_1


#####################
# Define TRACECLKOUT
#####################

# This clock is defined within the CSS-600 TPIU, and has half the frequency of
# the input TRACECLK
# See section 4.9.3 of the CSS-600 Technical Reference Manual
create_generated_clock \
  -source [get_pins ${TRACECLK_REG_PATH}/CK] \
  -add \
  -master_clock [get_clocks TRACECLKIN] \
  -name TRACECLKOUT \
  -edges {1 3 5} \
  [get_pins ${TRACECLK_REG_PATH}/Q]


################################
# Create Virtual Clocks for IOs
################################

# Define virtual clocks using 'create_clock' SDC command. These virtual clocks
# are used to constrain top level inputs and outputs, so that clock latency for
# virtual flops can be adjusted indepdent of the internal clock latencies.

# Virtual clocks corresponding to external clocks
create_clock -name V_EXTSYS0ACLK        -period $PERIODS(EXTSYS0ACLK)
create_clock -name V_EXTSYS0ATCLK       -period $PERIODS(EXTSYS0ATCLK)
create_clock -name V_EXTSYS0CTICLK      -period $PERIODS(EXTSYS0CTICLK)
create_clock -name V_EXTSYS0DBGCLKM     -period $PERIODS(EXTSYS0DBGCLKM)
create_clock -name V_EXTSYS0DBGCLKS     -period $PERIODS(EXTSYS0DBGCLKS)
create_clock -name V_EXTSYS0MHUCLK      -period $PERIODS(EXTSYS0MHUCLK)
create_clock -name V_EXTSYS1ACLK        -period $PERIODS(EXTSYS1ACLK)
create_clock -name V_EXTSYS1ATCLK       -period $PERIODS(EXTSYS1ATCLK)
create_clock -name V_EXTSYS1CTICLK      -period $PERIODS(EXTSYS1CTICLK)
create_clock -name V_EXTSYS1DBGCLKM     -period $PERIODS(EXTSYS1DBGCLKM)
create_clock -name V_EXTSYS1DBGCLKS     -period $PERIODS(EXTSYS1DBGCLKS)
create_clock -name V_EXTSYS1MHUCLK      -period $PERIODS(EXTSYS1MHUCLK)
create_clock -name V_REFCLK             -period $PERIODS(REFCLK)
create_clock -name V_S32KCLK            -period $PERIODS(S32KCLK)
create_clock -name V_SWCLKTCK           -period $PERIODS(SWCLKTCK)
create_clock -name V_TRACECLKIN         -period $PERIODS(TRACECLKIN)

# Virtual clocks corresponding to internally generated clocks
create_clock -name V_ACLK               -period $PERIODS(V_ACLK)
create_clock -name V_DBGCLK             -period $PERIODS(V_DBGCLK)
create_clock -name V_SYSPLL_SECENCCLK_4 -period $PERIODS(V_SYSPLL_SECENCCLK_4)

# Virtual clock to constrain asynchronous IOs
create_clock -name V_ASYNC              -period $PERIODS(V_ASYNC)

######################
# Define Clock Groups
######################

# Define the relationships between clocks - all external clocks are assumed to
# be asynchronous. Logically exclusive clock groups are used for all
# synchronous clocks with paths between them - these are CDC paths, timed in
# CDC mode.
# Note: ALLOW_CDC_PATHS is always set to 1

if {$::env(ALLOW_CDC_PATHS)} {
set_clock_groups -asynchronous -allow_paths -name external_asynchronous_clocks \
  -group [get_clocks {REFCLK V_REFCLK}] \
  -group [get_clocks {S32KCLK V_S32KCLK}] \
  -group [get_clocks $SYSPLL_DOMAIN_CLOCKS] \
  -group [get_clocks {CPUPLL CPUPLL_HOSTCPUCLK_1 CPUPLL_HOSTCPUCLK_2}] \
  -group [get_clocks {EXTSYS0ACLK V_EXTSYS0ACLK}] \
  -group [get_clocks {EXTSYS0ATCLK V_EXTSYS0ATCLK}] \
  -group [get_clocks {EXTSYS0CTICLK V_EXTSYS0CTICLK}] \
  -group [get_clocks {EXTSYS0DBGCLKM V_EXTSYS0DBGCLKM}] \
  -group [get_clocks {EXTSYS0DBGCLKS V_EXTSYS0DBGCLKS}] \
  -group [get_clocks {EXTSYS0MHUCLK V_EXTSYS0MHUCLK}] \
  -group [get_clocks {EXTSYS1ACLK V_EXTSYS1ACLK}] \
  -group [get_clocks {EXTSYS1ATCLK V_EXTSYS1ATCLK}] \
  -group [get_clocks {EXTSYS1CTICLK V_EXTSYS1CTICLK}] \
  -group [get_clocks {EXTSYS1DBGCLKM V_EXTSYS1DBGCLKM}] \
  -group [get_clocks {EXTSYS1DBGCLKS V_EXTSYS1DBGCLKS}] \
  -group [get_clocks {EXTSYS1MHUCLK V_EXTSYS1MHUCLK}] \
  -group [get_clocks {SWCLKTCK V_SWCLKTCK}] \
  -group [get_clocks {SECENCREFCLK}] \
  -group [get_clocks {TRACECLKIN TRACECLKOUT V_TRACECLKIN}] \
  -group [get_clocks {UARTCLK UARTCLK_HOSTUARTCLK_1 UARTCLK_HOSTUARTCLK_2}] \
  -group [get_clocks {V_ASYNC}]
  
  #Define groups of synchronous clocks
  set clock_groups [ list \
    {REFCLK V_REFCLK} \
    {S32KCLK V_S32KCLK} \
    $SYSPLL_DOMAIN_CLOCKS \
    {CPUPLL CPUPLL_HOSTCPUCLK_1 CPUPLL_HOSTCPUCLK_2} \
    {EXTSYS0ACLK V_EXTSYS0ACLK} \
    {EXTSYS0ATCLK V_EXTSYS0ATCLK} \
    {EXTSYS0CTICLK V_EXTSYS0CTICLK} \
    {EXTSYS0DBGCLKM V_EXTSYS0DBGCLKM} \
    {EXTSYS0DBGCLKS V_EXTSYS0DBGCLKS} \
    {EXTSYS0MHUCLK V_EXTSYS0MHUCLK} \
    {EXTSYS1ACLK V_EXTSYS1ACLK} \
    {EXTSYS1ATCLK V_EXTSYS1ATCLK} \
    {EXTSYS1CTICLK V_EXTSYS1CTICLK} \
    {EXTSYS1DBGCLKM V_EXTSYS1DBGCLKM} \
    {EXTSYS1DBGCLKS V_EXTSYS1DBGCLKS} \
    {EXTSYS1MHUCLK V_EXTSYS1MHUCLK} \
    {SWCLKTCK V_SWCLKTCK} \
    {SECENCREFCLK} \
    {TRACECLKIN TRACECLKOUT V_TRACECLKIN} \
    {UARTCLK UARTCLK_HOSTUARTCLK_1 UARTCLK_HOSTUARTCLK_2} \
    {V_ASYNC} \
  ]
  
  # False paths for hold checks, which are not applicable for cross-clock paths
  foreach from_group $clock_groups {
    foreach to_group $clock_groups {
      if {$from_group ne $to_group} {
        set_false_path -hold -from [get_clocks $from_group] -to [get_clocks $to_group]
      }
   }
 }  
} else {
set_clock_groups -asynchronous -name external_asynchronous_clocks \
  -group [get_clocks {REFCLK V_REFCLK}] \
  -group [get_clocks {S32KCLK V_S32KCLK}] \
  -group [get_clocks $SYSPLL_DOMAIN_CLOCKS] \
  -group [get_clocks {CPUPLL CPUPLL_HOSTCPUCLK_1 CPUPLL_HOSTCPUCLK_2}] \
  -group [get_clocks {EXTSYS0ACLK V_EXTSYS0ACLK}] \
  -group [get_clocks {EXTSYS0ATCLK V_EXTSYS0ATCLK}] \
  -group [get_clocks {EXTSYS0CTICLK V_EXTSYS0CTICLK}] \
  -group [get_clocks {EXTSYS0DBGCLKM V_EXTSYS0DBGCLKM}] \
  -group [get_clocks {EXTSYS0DBGCLKS V_EXTSYS0DBGCLKS}] \
  -group [get_clocks {EXTSYS0MHUCLK V_EXTSYS0MHUCLK}] \
  -group [get_clocks {EXTSYS1ACLK V_EXTSYS1ACLK}] \
  -group [get_clocks {EXTSYS1ATCLK V_EXTSYS1ATCLK}] \
  -group [get_clocks {EXTSYS1CTICLK V_EXTSYS1CTICLK}] \
  -group [get_clocks {EXTSYS1DBGCLKM V_EXTSYS1DBGCLKM}] \
  -group [get_clocks {EXTSYS1DBGCLKS V_EXTSYS1DBGCLKS}] \
  -group [get_clocks {EXTSYS1MHUCLK V_EXTSYS1MHUCLK}] \
  -group [get_clocks {SWCLKTCK V_SWCLKTCK}] \
  -group [get_clocks {SECENCREFCLK}] \
  -group [get_clocks {TRACECLKIN TRACECLKOUT V_TRACECLKIN}] \
  -group [get_clocks {UARTCLK UARTCLK_HOSTUARTCLK_1 UARTCLK_HOSTUARTCLK_2}] \
  -group [get_clocks {V_ASYNC}]
}



###########################
# Set DFT Port Constraints
###########################

# Use the DFT constraints defined at the top of the constraints file to set
# case analysis on the DFT ports in functional mode.
dict for {signal value} [array get DFT_CONSTRAINTS] {
  if {[sizeof_collection [get_ports -quiet $signal]] > 0} {
    puts "top_sse710_r0_aontop.func.sdc: Setting DFT case analysis on port $signal ($value)"
    set_case_analysis $value [get_ports $signal]
  } else {
    puts "top_sse710_r0_aontop.func.sdc: Couldn't set case analysis - missing port \"$signal\""
  }
}


#################
# IO Constraints
#################

source ${CONSTRAINT_DIR}/top_sse710_r0_aontop.io.sdc

# Additional placeholder constraints for ports added during implementation:
# A maximum delay is used to constrain the paths related to DFTSI/DFTSO/DFTRAMBYP.
# An input or output delay of zero avoids overconstraint above the max_delay requirement
# and is used to clean up spurious reports from check_timing.

if {[sizeof_collection [get_ports -quiet {DFTRAMBYP}]] > 0} {
  set_max_delay -from [get_ports {DFTRAMBYP}] $ASYNCHRONOUS_PORT_MAX_DELAY
  set_input_delay -clock V_ASYNC 0 [get_ports {DFTRAMBYP}]
}

if {[sizeof_collection [get_ports -quiet {DFTSI[*]}]] > 0} {
  set_max_delay -from [get_ports {DFTSI[*]}] $ASYNCHRONOUS_PORT_MAX_DELAY
  set_input_delay -clock V_ASYNC 0 [get_ports {DFTSI[*]}]
}

if {[sizeof_collection [get_ports -quiet {DFTSO[*]}]] > 0} {
  set_max_delay -to [get_ports {DFTSO[*]}] $ASYNCHRONOUS_PORT_MAX_DELAY
  set_output_delay -clock V_ASYNC 0 [get_ports {DFTSO[*]}]
}

##################
# Path Exceptions
##################

# Time falling-edge JTAG register async reset pins using V_SWCLKTCK only
set_false_path -from [get_clocks V_ASYNC] \
  -through {u_debug_f0_aontop/u_dpslv/JTAG_PROTOCOL_ENGINE_u_css600_dpslv_jtag_protocol/tdo_reg/R \
            u_debug_f0_aontop/u_dpslv/JTAG_PROTOCOL_ENGINE_u_css600_dpslv_jtag_protocol/tdo_en_reg/R}

# These registers control the status of isolation cells throughout the design,
# and these signals are pseudo-static. They have a high fanout and endpoints
# span multiple clock domains, so constrain with a maximum delay equal to an
# arbitrary multiple (in this case, 4x) of the launching clock period.

set_max_delay 15.0 -from u_pd_systop/u_pc_cpu_systop/u_core0_ppu/u_pck600_ppu_psm/devemuisolaten_r_reg/CK
set_max_delay 15.0 -from u_pd_systop/u_pc_cpu_systop/u_core1_ppu/u_pck600_ppu_psm/devemuisolaten_r_reg/CK
set_max_delay 15.0 -from u_pd_systop/u_pc_cpu_systop/u_core2_ppu/u_pck600_ppu_psm/devemuisolaten_r_reg/CK
set_max_delay 15.0 -from u_pd_systop/u_pc_cpu_systop/u_core3_ppu/u_pck600_ppu_psm/devemuisolaten_r_reg/CK

set_max_delay 25.0 -from u_pd_systop/u_pc_cpu_systop/u_clustop_ppu/u_pck600_ppu_psm/devisolaten_r_reg/CK

set_max_delay 40.0 -from u_system_control_f0_aontop/u_ppu_aon/u_dbgtop_ppu/u_pck600_ppu_psm/devisolaten_r_reg/CK
set_max_delay 40.0 -from u_system_control_f0_aontop/u_ppu_aon/u_systop_ppu/u_pck600_ppu_psm/devisolaten_r_reg/CK

set_max_delay 40.0 -from u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_pwr_ctrl/u_pck600_ppu_sse710_secenc/u_pck600_ppu_psm/devisolaten_r_reg/CK

# These multicycle paths for L2 RAM Q outputs are specified in 
# the Configuration and Sign-off Guide of the A-class processor being used
# For example section 2.23 of the Cortex-A32 Configuration and Sign-off Guide
for {set ram_index 0} {$ram_index < 8} {incr ram_index} {
  set_multicycle_path 2 -setup \
    -from [get_pins ${L2_RAM_PATH}/u_l2_dataram_${ram_index}/u_arm_element_sp_ram_pa_0/CLK] \
    -through [get_pins ${L2_RAM_PATH}/u_l2_dataram_${ram_index}/u_arm_element_sp_ram_pa_0/Q\[*\]]
  set_multicycle_path 1 -hold \
    -from [get_pins ${L2_RAM_PATH}/u_l2_dataram_${ram_index}/u_arm_element_sp_ram_pa_0/CLK] \
    -through [get_pins ${L2_RAM_PATH}/u_l2_dataram_${ram_index}/u_arm_element_sp_ram_pa_0/Q\[*\]]

  set_multicycle_path 2 -setup \
    -from [get_pins ${L2_RAM_PATH}/u_l2_dataram_${ram_index}/u_arm_element_sp_ram_pa_1/CLK] \
    -through [get_pins ${L2_RAM_PATH}/u_l2_dataram_${ram_index}/u_arm_element_sp_ram_pa_1/Q\[*\]]
  set_multicycle_path 1 -hold \
    -from [get_pins ${L2_RAM_PATH}/u_l2_dataram_${ram_index}/u_arm_element_sp_ram_pa_1/CLK] \
    -through [get_pins ${L2_RAM_PATH}/u_l2_dataram_${ram_index}/u_arm_element_sp_ram_pa_1/Q\[*\]]
}

#
# Exceptions when Crypto Accelerator contents are not visible
#

set_max_delay $NON_CRITICAL_CROSSING_LATENCY_TARGET -through [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_crypto_accelerator_aon/u_crypto_accelerator_aon_model/SCB[*] \
}] -to [get_pins {
 u_pd_secenc_f1_top/u_secenc_f1_sepd/u_sec_cdc_capt_sync_*/u_arm_element_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
 u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_cdc_capt_sync_*/u_arm_element_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D  \
}]

set_max_delay $NON_CRITICAL_CROSSING_LATENCY_TARGET -through [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_crypto_accelerator_aon/u_crypto_accelerator_aon_model/CAPWRPACCEPT
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_pwr_ctrl/u_pck600_lpd_p_sse710_secenc/dev1_sync_inc_u_pck600_sync_dev1_paccept/u_cdc_capt_sync/D
}]

set_max_delay $NON_CRITICAL_CROSSING_LATENCY_TARGET -through [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_crypto_accelerator_aon/u_crypto_accelerator_aon_model/CAPWRPACTIVE[*]
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_pwr_ctrl/u_pck600_ppu_sse710_secenc/pactive_input_block_loop_2_u_pck600_ppu_input_block_active/input_sync_u_pck600_sync/u_cdc_capt_sync/D
}]

set_max_delay $NON_CRITICAL_CROSSING_LATENCY_TARGET -through [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_crypto_accelerator_aon/u_crypto_accelerator_aon_model/CAPWRPDENY
}] -to [get_pins {
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_pwr_ctrl/u_pck600_lpd_p_sse710_secenc/dev1_sync_inc_u_pck600_sync_dev1_pdeny/u_cdc_capt_sync/D
}]

#######################################################################
# Max Delay Constraints for paths involving asynchronous virtual clock
#######################################################################
set FEEDTHROUGH_ASYNC_MAX_DELAY 40.0
set_max_delay $FEEDTHROUGH_ASYNC_MAX_DELAY -from [get_clocks {V_ASYNC}] \
  -to [get_clocks {V_ASYNC}]

#Specific max_delay constraints for paths from DFTISODISABLE to DFTSO ports.

set_max_delay $FEEDTHROUGH_ASYNC_MAX_DELAY -from [get_ports {DFTISODISABLE}] \
  -to [get_ports {DFTSO[*]}]

#######################################################################
# qactive constraints
#######################################################################

set_max_delay 3 -from [get_pins {
 u_pd_systop/u_base_systop/u_fc_*/u_lpi/u_comp_clkctrl/current_state_r_reg_*/CK
 u_pd_systop/u_base_systop/u_fc_*/u_regslice_s/u_aw_regslice/FULL_u_reg_slc_full/sel_b_reg_*/CK
 u_pd_systop/u_base_systop/u_fc_*/u_fc_regbank/RGN_SIZE_PE_LVL_NOT_ZERO_RGN_SIZE_MULNPO2_PE_LVL_NOT_ZERO_RSE_LVL_NOT_ZERO_RGN_SIZE_MULNPO2_PE_LVL_TWO_RSE_LVL_NOT_ZERO_RGN_SIZE_MULNPO2_FC_NUM_RGN_NOT_1_rgn_size_mulnpo2_non_def_r_reg_*/CK
 u_pd_systop/u_pc_eh1_f0_systop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst/u_mst/u_protocol_quiescent/stall_aw_n_q_reg/CK
 u_pd_systop/u_pc_eh1_f0_systop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst/u_mst/g_ar_opreg_no_tkn_u_ar_opreg/rd_sel_reg/CK
 u_pd_systop/u_pc_eh0_f0_systop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst/u_mst/g_aw_opreg_no_tkn_u_aw_opreg/rd_sel_reg/CK
 u_pd_systop/u_pc_eh1_f0_systop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst/u_mst/g_aw_opreg_no_tkn_u_aw_opreg/rd_sel_reg/CK
 u_pd_systop/u_base_systop/u_nic400_main/u_cd_a/u_amib_sysctrl_axim/u_aw_master_port_chan_slice/u_ful_regd_slice/sel_b_reg_*/CK
 u_pd_systop/u_base_systop/u_fc_*/u_regslice_s/u_aw_regslice/FULL_u_reg_slc_full/payload_reg_a_reg_*/CK
 u_pd_systop/u_pc_eh0_f0_systop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst/u_mst/g_aw_opreg_no_tkn_u_aw_opreg/rd_valid_reg_*/CK
 u_pd_systop/u_base_systop/u_fc_*/u_regslice_s/u_aw_regslice/FULL_u_reg_slc_full/payload_reg_b_reg_*/CK
 u_pd_systop/u_pc_eh1_f0_systop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst/u_mst/g_aw_opreg_no_tkn_u_aw_opreg/rd_valid_reg_*/CK
 u_pd_systop/u_base_systop/u_fc_*/u_regslice_s/u_ar_regslice/FULL_u_reg_slc_full/sel_b_reg_*/CK
 u_pd_systop/u_base_systop/u_fc_*/u_lpi/u_comp_clkctrl/cg_curr_state_r_reg_*/CK
 u_pd_systop/u_pc_eh0_f0_systop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst/u_mst/u_protocol_quiescent/stall_aw_n_q_reg/CK
 u_pd_systop/u_base_systop/u_fc_*/u_regslice_s/u_ar_regslice/FULL_u_reg_slc_full/payload_reg_b_reg_*/CK
 u_pd_systop/u_pc_eh*_f0_systop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst/u_mst/u_mi_ctrl/outer_fencen_q_reg/CK
 u_pd_systop/u_pc_eh*_f0_systop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst/u_mst/g_aw_opreg_no_tkn_u_aw_opreg/payld0_reg_*/CK
 u_pd_systop/u_base_systop/u_fc_*/u_regslice_s/u_ar_regslice/FULL_u_reg_slc_full/payload_reg_a_reg_*/CK
 u_pd_systop/u_base_systop/u_fc_*/u_comp_gate/u_ax_tracker_aw/MULT_OUTST_outst_counter_reg_*/CK
 u_pd_systop/u_pc_eh*_f0_systop/u_sse710_adb400_r3_axi4_mst_wrapper/u_adb400_r3_axi4_mst/u_mst/g_aw_opreg_no_tkn_u_aw_opreg/payld1_reg_*/CK
 u_pd_systop/u_base_systop/u_nic400_main/u_cd_a/u_amib_sysctrl_axim/u_ar_master_port_chan_slice/u_ful_regd_slice/sel_b_reg_*/CK
}] -to [get_pins {
 u_pd_systop/u_base_systop/u_base_aclk_lpdq/active_deny_support_active_deny_sync_inc_u_pck600_dev_qactive/u_cdc_capt_sync/D
}]


# End of Functional Mode SDC for SSE-710


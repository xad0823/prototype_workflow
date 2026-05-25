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
# Purpose : Shift Mode SDC for SSE-710
# -----------------------------------------------------------------------------
#
# This file contains all of the technology-independent timing constraints
# required for implementation of the SSE-710 top level design, in scan shift
# mode.
#
# NOTE: these constraints are intended for implementation/OOB purposes they are
#       currently NOT sign off quality


set sdc_version 2.0

set_units -time ns

if {![info exists ::env(LOGICAL_PATH)]} {
  set ::env(LOGICAL_PATH) ../../logical
}
set CONSTRAINT_DIR $::env(LOGICAL_PATH)/top_sse710_r0_3/top_sse710_r0_aontop_3/constraints

source ${CONSTRAINT_DIR}/procs.sdc

#######################
# Constant Definitions
#######################

array unset FREQUENCIES
array unset PERIODS
array unset DFT_CONSTRAINTS

set SHIFT_FREQUENCY "50 MHz"

# The frequencies of key clocks in the design - all external clocks and any
# internal clocks involved in other constraint definitions
array set FREQUENCIES [list \
  REFCLK                    $SHIFT_FREQUENCY \
  S32KCLK                   $SHIFT_FREQUENCY \
  SYSPLL                    $SHIFT_FREQUENCY \
  CPUPLL                    $SHIFT_FREQUENCY \
  EXTSYS0ACLK               $SHIFT_FREQUENCY \
  EXTSYS0ATCLK              $SHIFT_FREQUENCY \
  EXTSYS0CTICLK             $SHIFT_FREQUENCY \
  EXTSYS0DBGCLKM            $SHIFT_FREQUENCY \
  EXTSYS0DBGCLKS            $SHIFT_FREQUENCY \
  EXTSYS0MHUCLK             $SHIFT_FREQUENCY \
  EXTSYS1ACLK               $SHIFT_FREQUENCY \
  EXTSYS1ATCLK              $SHIFT_FREQUENCY \
  EXTSYS1CTICLK             $SHIFT_FREQUENCY \
  EXTSYS1DBGCLKM            $SHIFT_FREQUENCY \
  EXTSYS1DBGCLKS            $SHIFT_FREQUENCY \
  EXTSYS1MHUCLK             $SHIFT_FREQUENCY \
  SWCLKTCK                  $SHIFT_FREQUENCY \
  SECENCREFCLK              $SHIFT_FREQUENCY \
  TRACECLKIN                $SHIFT_FREQUENCY \
  UARTCLK                   $SHIFT_FREQUENCY \
  SYSPLL_ACLK_1             $SHIFT_FREQUENCY \
  SYSPLL_DBGCLK_1           $SHIFT_FREQUENCY \
  SECENCCLK_SECENCDIVCLK_1  $SHIFT_FREQUENCY \
  CPUPLL_HOSTCPUCLK_1       $SHIFT_FREQUENCY \
  SYSPLL_SECENCCLK_4        $SHIFT_FREQUENCY \
  SYSPLL_GICCLK_1           $SHIFT_FREQUENCY \
  V_ACLK                    $SHIFT_FREQUENCY \
  V_DBGCLK                  $SHIFT_FREQUENCY \
  V_SYSPLL_SECENCCLK_4      $SHIFT_FREQUENCY \
  SYSPLL_CTRLCLK_1          $SHIFT_FREQUENCY \
  UARTCLK_HOSTUARTCLK_1     $SHIFT_FREQUENCY \
  SYSPLL_HOSTCPUCLK_1       $SHIFT_FREQUENCY \
  V_ASYNC                   $SHIFT_FREQUENCY \
]

# Use the calculate_period procedure defined in procs.sdc to calculate the clock
# period in nanoseconds
dict for {clk frequency} [array get FREQUENCIES] {
  set PERIODS($clk) [calculate_period $frequency]
}

set ACLK_CLOCK_UNIT_PATH          {u_pd_systop/u_clk_gen_systop/u_e_clk_f1_unit_aclk_systop}
set CTRLCLK_CLOCK_UNIT_PATH       {u_pd_systop/u_clk_gen_systop/u_e_clk_f1_unit_ctrlclk_systop}
set GICCLK_CLOCK_UNIT_PATH        {u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_gicclk_clustop}
set HOSTCPUCLK_CLOCK_UNIT_PATH    {u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_hostcpuclk_clustop}
set SECENCCLK_CLOCK_UNIT_PATH     {u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_secencclk_aon_secenc_clk}
set SECENCDIVCLK_CLOCK_UNIT_PATH  {u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_secencdivclk_i_secenc_clk}
set DBGCLK_CLOCK_UNIT_PATH        {u_pd_dbgtop_f0/u_clk_gen_dbgclk/u_e_clk_f1_unit_dbgclk_dbgtop}
set UARTCLK_CLOCK_UNIT_PATH       {u_system_control_f0_aontop/u_clk_f1_top_uartclk/u_e_clk_f1_unit_hostuartclk_uartclk}
set TRACECLK_REG_PATH             {u_pd_dbgtop_f0/u_debug_f0_dbgtop/u_soc_tpiu/u_css600_tpiu_trace_clk/traceclk_reg}

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

# Define the DFT port constraints for shift mode
# DFTSI[*] and DFTRAMBYP are added during implementation, and
# are not present in the RTL
array set DFT_CONSTRAINTS {
  {DFTSE}             1
  {DFTTESTMODE}       1
}

set ASYNCHRONOUS_PORT_MAX_DELAY 15.0

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

# In shift mode, all dividers are bypassed, and operate in divide-by-1 mode.
# Although divide-by-2 clocks are generated, these do not propagate out of the
# dividers. The clock output from the clock selector can be selected during
# testing, but in these constraints, each selector in configured to use the same
# clock source as in functional mode. For example, the ACLK selector will use
# the output from the SYSPLL ACLK divider in both modes.

constrain_divider \
  -path "${ACLK_CLOCK_UNIT_PATH}/u_clkrst_f1_clkdiv_modulate_top_syspll" \
  -source_clock SYSPLL \
  -divided_clock SYSPLL_ACLK_2 -edges {1 3 5} \
  -bypass_clock SYSPLL_ACLK_1 -bypass 1
constrain_selector -path $ACLK_CLOCK_UNIT_PATH \
  -clocks {REFCLK SYSPLL_ACLK_1} \
  -selected SYSPLL_ACLK_1

constrain_divider \
  -path "${CTRLCLK_CLOCK_UNIT_PATH}/u_clkrst_f1_clkdiv_modulate_top_syspll" \
  -source_clock SYSPLL \
  -divided_clock SYSPLL_CTRLCLK_2 -edges {1 3 5} \
  -bypass_clock SYSPLL_CTRLCLK_1 -bypass 1
constrain_selector -path $CTRLCLK_CLOCK_UNIT_PATH \
  -clocks {REFCLK SYSPLL_CTRLCLK_1} \
  -selected SYSPLL_CTRLCLK_1

constrain_divider \
  -path "${GICCLK_CLOCK_UNIT_PATH}/u_clkrst_f1_clkdiv_modulate_top_syspll" \
  -source_clock SYSPLL \
  -divided_clock SYSPLL_GICCLK_2 -edges {1 3 5} \
  -bypass_clock SYSPLL_GICCLK_1 -bypass 1
constrain_selector -path $GICCLK_CLOCK_UNIT_PATH \
  -clocks {REFCLK SYSPLL_GICCLK_1} \
  -selected SYSPLL_GICCLK_1

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

constrain_divider \
  -path "${SECENCCLK_CLOCK_UNIT_PATH}/u_clkrst_f1_clkdiv_modulate_top_syspll" \
  -source_clock SYSPLL \
  -divided_clock SYSPLL_SECENCCLK_4 -edges {1 5 9} \
  -bypass_clock SYSPLL_SECENCCLK_1 -bypass 1
constrain_selector -path $SECENCCLK_CLOCK_UNIT_PATH \
  -clocks {SECENCREFCLK SYSPLL_SECENCCLK_1} \
  -selected SECENCREFCLK

constrain_divider \
  -path "${SECENCDIVCLK_CLOCK_UNIT_PATH}/u_clkrst_f1_clkdiv_modulate_top_secencdivclk_i" \
  -source_clock SECENCREFCLK \
  -divided_clock SECENCCLK_SECENCDIVCLK_2 -edges {1 3 5} \
  -bypass_clock SECENCCLK_SECENCDIVCLK_1 -bypass 1

constrain_divider \
  -path "${DBGCLK_CLOCK_UNIT_PATH}/u_clkrst_f1_clkdiv_modulate_top_syspll" \
  -source_clock SYSPLL \
  -divided_clock SYSPLL_DBGCLK_4 -edges {1 5 9} \
  -bypass_clock SYSPLL_DBGCLK_1 -bypass 1
constrain_selector -path $DBGCLK_CLOCK_UNIT_PATH \
  -clocks {REFCLK SYSPLL_DBGCLK_1} \
  -selected SYSPLL_DBGCLK_1

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
create_clock -name V_ASYNC             -period $PERIODS(V_ASYNC)

###########################
# Set DFT Port Constraints
###########################

# Use the DFT constraints defined at the top of the constraints file to set
# case analysis on the DFT ports in shift mode.
dict for {signal value} [array get DFT_CONSTRAINTS] {
  if {[sizeof_collection [get_ports -quiet $signal]] > 0} {
    puts "top_sse710_r0_aontop.shift.sdc: Setting DFT case analysis on port $signal ($value)"
    set_case_analysis $value [get_ports $signal]
  } else {
    puts "top_sse710_r0_aontop.shift.sdc: Couldn't set case analysis - missing port \"$signal\""
  }
}

###############################
# Hold False path for ASYNC IO
###############################
set_false_path -hold -from [get_clocks V_ASYNC] -to [remove_from_collection [get_clocks *] "V_ASYNC"]


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

#########################################################################
# Time falling-edge JTAG register async reset pins using V_SWCLKTCK only
#########################################################################
set_false_path -from [get_clocks V_ASYNC] \
  -through {u_debug_f0_aontop/u_dpslv/JTAG_PROTOCOL_ENGINE_u_css600_dpslv_jtag_protocol/tdo_reg/R \
            u_debug_f0_aontop/u_dpslv/JTAG_PROTOCOL_ENGINE_u_css600_dpslv_jtag_protocol/tdo_en_reg/R}

#######################################################################
# Max Delay Constraints for paths involving asynchronous virtual clock
#######################################################################
set FEEDTHROUGH_ASYNC_MAX_DELAY 40.0
set_max_delay $FEEDTHROUGH_ASYNC_MAX_DELAY -from [get_clocks {V_ASYNC}] \
  -to [get_clocks {V_ASYNC}]

###########################################################
# Max Delay Constraints for Q Channel related feedthroughs
###########################################################

set_max_delay $FEEDTHROUGH_ASYNC_MAX_DELAY -from [get_ports PWAKEUPEXTSYS0EXTDBG] -to [get_ports EXTSYS0DBGCLKSQACTIVE]
set_max_delay $FEEDTHROUGH_ASYNC_MAX_DELAY -from [get_ports ATWAKEUPEXTSYS0TRACEEXP] -to [get_ports EXTSYS0ATCLKQACTIVE]
set_max_delay $FEEDTHROUGH_ASYNC_MAX_DELAY -from [get_ports PWAKEUPEXTSYS0MHU] -to [get_ports EXTSYS0MHUCLKQACTIVE]
set_max_delay $FEEDTHROUGH_ASYNC_MAX_DELAY -from [get_ports AWAKEUPEXTSYS0MEM] -to [get_ports EXTSYS0ACLKQACTIVE]
set_max_delay $FEEDTHROUGH_ASYNC_MAX_DELAY -from [get_ports AWAKEUPEXTSYS0MEM] -to [get_ports EXTSYS0MEMPWRQACTIVE]
set_max_delay $FEEDTHROUGH_ASYNC_MAX_DELAY -from [get_ports PWAKEUPEXTSYS1EXTDBG] -to [get_ports EXTSYS1DBGCLKSQACTIVE]
set_max_delay $FEEDTHROUGH_ASYNC_MAX_DELAY -from [get_ports ATWAKEUPEXTSYS1TRACEEXP] -to [get_ports EXTSYS1ATCLKQACTIVE]
set_max_delay $FEEDTHROUGH_ASYNC_MAX_DELAY -from [get_ports PWAKEUPEXTSYS1MHU] -to [get_ports EXTSYS1MHUCLKQACTIVE]
set_max_delay $FEEDTHROUGH_ASYNC_MAX_DELAY -from [get_ports AWAKEUPEXTSYS1MEM] -to [get_ports EXTSYS1ACLKQACTIVE]
set_max_delay $FEEDTHROUGH_ASYNC_MAX_DELAY -from [get_ports AWAKEUPEXTSYS1MEM] -to [get_ports EXTSYS1MEMPWRQACTIVE]

#####################################################
# Max Delay Constraints related to isolation control
#####################################################

set FEEDTHROUGH_ISO_MAX_DELAY 40.0
if {[sizeof_collection [get_ports -quiet LP_ISOLATENEXTSYS0TOP]] > 0} {
  set_max_delay $FEEDTHROUGH_ISO_MAX_DELAY \
    -from [get_ports LP_ISOLATENEXTSYS0TOP] \
    -to [get_clocks {V_EXTSYS0ACLK V_EXTSYS0ATCLK V_EXTSYS0CTICLK \
                     V_EXTSYS0DBGCLKM V_EXTSYS0DBGCLKS V_EXTSYS0MHUCLK}]
}
if {[sizeof_collection [get_ports -quiet LP_ISOLATENEXTSYS1TOP]] > 0} {
  set_max_delay $FEEDTHROUGH_ISO_MAX_DELAY \
    -from [get_ports LP_ISOLATENEXTSYS1TOP] \
    -to [get_clocks {V_EXTSYS1ACLK V_EXTSYS1ATCLK V_EXTSYS1CTICLK \
                     V_EXTSYS1DBGCLKM V_EXTSYS1DBGCLKS V_EXTSYS1MHUCLK}]
}

##############################
# Disable clock gating checks
##############################
set_disable_clock_gating_check [get_cells [list \
  u_pd_dbgtop_f0/u_clk_gen_dbgclk/u_e_clk_f1_unit_dbgclk_dbgtop/u_clkselnway_f0_2/u_clkoutor2/u_clock_or2/u_clock_or2 \
  u_pd_systop/u_clk_gen_systop/u_e_clk_f1_unit_aclk_systop/u_clkselnway_f0_2/u_clkoutor2/u_clock_or2/u_clock_or2 \
  u_pd_systop/u_clk_gen_systop/u_e_clk_f1_unit_ctrlclk_systop/u_clkselnway_f0_2/u_clkoutor2/u_clock_or2/u_clock_or2 \
  u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_gicclk_clustop/u_clkselnway_f0_2/u_clkoutor2/u_clock_or2/u_clock_or2 \
  u_pd_systop/u_pd_clustop/u_clk_gen_clustop/u_e_clk_f1_unit_hostcpuclk_clustop/u_clkselnway_f0_3/u_clkoutor_1/u_clock_or2/u_clock_or2 \
  u_secenc_f1_aontop/u_secenc_f1_aon/u_sec_clk_ctrl/u_e_clk_f1_top_secenc_clk/u_e_clk_f1_unit_secencclk_aon_secenc_clk/u_clkselnway_f0_2/u_clkoutor2/u_clock_or2/u_clock_or2 \
  u_system_control_f0_aontop/u_clk_f1_top_uartclk/u_e_clk_f1_unit_hostuartclk_uartclk/u_clkselnway_f0_3/u_clkoutor_1/u_clock_or2/u_clock_or2 \
  u_system_control_f0_aontop/u_clk_f1_top_uartclk/u_e_clk_f1_unit_hostuartclk_uartclk/u_clkselnway_f0_3/u_clkoutor_3/u_clock_or2/u_clock_or2 \
]]
 

# End of Shift Mode SDC for SSE-710

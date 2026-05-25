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
# Purpose : Supporting Timing Constraint Procedures for SSE-710
# -----------------------------------------------------------------------------
#
# This file contains all of the procedures used in the main modal SDC files
# required for implementation of the SSE-710 top level design. It includes
# procedures for defining the generated clocks within dividers, and for defining
# maximum delays for clock domain crossings for various IP components.
#
# NOTE: these constraints are intended for implementation/OOB purposes they are
#       currently NOT sign off quality


proc debug_out {str} {
  # This procedure prints out debug information from within the other constraint
  # procedures. The following line can be commented out to disable debug
  # printing.
  puts "$str"
}

proc _args_to_dict {calling_proc args} {
  # Converts a series of labelled arguments (in the format "-label value"),
  # and stores them in a dictionary for easy querying. It returns the resulting
  # dictionary.

  set current_param_name ""
  set param_dict [dict create]
  foreach arg $args {
    if {[string first "-" $arg] == 0} {
      set current_param_name [string range $arg 1 end]
    } elseif {$current_param_name ne ""} {
      dict set param_dict $current_param_name $arg
      set current_param_name ""
    } else {
      puts "ERROR: Incorrect parameter syntax for proc: $calling_proc - this command will be skipped"
      break
    }
  }
  return $param_dict
}

proc constrain_divider {args} {
  # Constrains a clock divider module, creating two generated clocks - the
  # first is created on the output of the "bypass" clock gate in the divider,
  # while the other is created on the OR gate combining the clock signal from
  # the even and odd registers.

  # The value of the bypass parameter controls which of the two clocks
  # propagates out of the divider - if it is set to 0, the divided clock reaches
  # the divclk output, and the bypass clock is blocked. Otherwise, the
  # bypass clock is propagated out of the divider and the divided clock is
  # blocked.

  set param_dict [_args_to_dict "constrain_divider" {*}$args]
  set required_params_found [expr {
    [dict exists $param_dict path] &&
    [dict exists $param_dict source_clock] &&
    [dict exists $param_dict divided_clock] &&
    [dict exists $param_dict bypass_clock] &&
    [dict exists $param_dict edges] &&
    [dict exists $param_dict bypass]
  }]

  if {!$required_params_found} {
    puts "ERROR: Required parameters not provided to constrain_divider - skipping"
    puts $param_dict
    return
  }
  set path [dict get $param_dict path]
  set source_clock [dict get $param_dict source_clock]
  set divided_clock [dict get $param_dict divided_clock]
  set bypass_clock [dict get $param_dict bypass_clock]
  set edges [dict get $param_dict edges]
  set bypass [dict get $param_dict bypass]

  set divided_clock_source ${path}/u_clkrst_f1_clkdiv_modulate/clockpath_logic_u_clkrst_f1_clkor2_clockdiv_even/u_arm_element_clock_or2/u_clock_or2/Y
  set bypass_clock_source ${path}/u_clkrst_f1_clkdiv_modulate/enable_combo_clkgate_u_div_clkgate/u_arm_element_clock_gate/u_clock_gate/ECK
  set origin ${path}/u_clkrst_f1_clkbuf_top/u_arm_element_clock_buffer/u_clock_buffer/Y
  set divided_clock_stop ${path}/u_clkrst_f1_clkdiv_modulate/clockpath_logic_u_clkrst_f1_clkor2/u_arm_element_clock_or2/u_clock_or2/B
  set bypass_clock_stop ${path}/u_clkrst_f1_clkdiv_modulate/clockpath_logic_u_clkrst_f1_clkor2/u_arm_element_clock_or2/u_clock_or2/A

  create_generated_clock \
    -source [get_pins $origin] \
    -add \
    -master_clock [get_clocks $source_clock] \
    -name $divided_clock \
    -edges $edges \
    [get_pins $divided_clock_source]

  create_generated_clock \
    -source [get_pins $origin] \
    -add \
    -master_clock [get_clocks $source_clock] \
    -name $bypass_clock \
    -edges {1 2 3} \
    [get_pins $bypass_clock_source]

  if {$bypass} {
    # Stop propagation of the divided clock
    set_clock_sense [get_pins $divided_clock_stop] \
      -clocks [get_clocks $divided_clock] \
      -stop_propagation
  } else {
    # Stop propagation of the undivided clock
    set_clock_sense [get_pins $bypass_clock_stop] \
      -clocks [get_clocks $bypass_clock] \
      -stop_propagation
  }
}

proc constrain_selector {args} {
  # This procedure constraints a clock selection module, where several clock
  # gates connecting to an OR gate allow switching between different clocks to
  # clock downstream logic. The 'selected' parameter determines which of the
  # clocks is allowed to pass through the set of clock gates - all other clocks
  # are blocked.

  # The order of clocks passed in the 'clocks' parameter must match the logical
  # connections in the design, otherwise incorrect constraints will be applied.

  set param_dict [_args_to_dict "constrain_selector" {*}$args]
  set required_params_found [expr {
    [dict exists $param_dict path] &&
    [dict exists $param_dict clocks] &&
    [dict exists $param_dict selected]
  }]
  if {!$required_params_found} {
    puts "ERROR: Required parameters not provided to constrain_selector - skipping"
    puts $param_dict
    return
  }
  set path [dict get $param_dict path]
  set clock_selection [dict get $param_dict clocks]
  set selected_clock [dict get $param_dict selected]

  set i 0
  if {[lsearch $clock_selection $selected_clock] == -1} {
    puts "ERROR: constrain_selector with $clock_selection and $selected_clock"
    return
  }

  set ways [llength $clock_selection]
  foreach clock $clock_selection {
    if {$clock ne $selected_clock} {
      set_clock_sense [get_pins ${path}/u_clkselnway_f0_${ways}/u_clkselNway_f0_clkgate_clk_$i/u_clock_gate/u_clock_gate/ECK] \
        -clocks [get_clocks $clock] \
        -stop_propagation
    }
    incr i
  }
}

proc calculate_period {frequency {base_units 1e-9}} {
  # This procedure converts a frequency string into a numerical period. The
  # frequency string is composed of a real number and a unit - for example,
  # an input "400 MHz" would result in an output of "2.5", which is the period
  # of a 400 MHz clock in nanoseconds. The base units for the result can be
  # changed, if, for example it is preferred to use picoseconds in the
  # constraints and implementation tools - the default is 1e-9 seconds, or 1
  # nanosecond.

  if {![regexp {(\d+\.?\d*) ?([kMG]Hz)} $frequency -> freq_val freq_unit]} {
    puts "ERROR: Cannot calculate period in calculate_period from $frequency"
    return
  }

  set period_s [expr {1.0 / $freq_val}]
  if {$freq_unit eq "kHz"} {
    set period_s [expr {$period_s / 1000.0}]
  } elseif {$freq_unit eq "MHz"} {
    set period_s [expr {$period_s / 1000000.0}]
  } elseif {$freq_unit eq "GHz"} {
    set period_s [expr {$period_s / 1000000000.0}]
  }

  return [expr {$period_s / $base_units}]
}

proc compat_set_max_delay {args} {
  # Allow the use of the standard "-ignore_clock_latency" options for the
  # set_max_delay SDC command across a wide variety of tools, by removing or
  # converting this argument for tools which do not fully support the SDC 2.1
  # standard.

  set is_cadence_cui [expr {
    [llength [info commands get_db]] > 0 &&
    [llength [info commands is_attribute]] > 0 &&
    [is_attribute program_short_name -obj_type root]
  }]
  set is_cadence_legacy [expr {
    [llength [info commands is_attribute]] > 0 &&
    [is_attribute program_short_name -obj_type root]
  }]
  set is_timevision [expr {[namespace exists ::tvGlobal] == 1}]

  if {$is_cadence_cui && [get_db program_short_name] eq "genus"} {
    # If using Cadence Genus, swap standard "-ignore_clock_latency" for
    # "-combinational_from_to", since they do not support SDC 2.1 yet.
    set args [regsub {\-ignore_clock_latency} $args {-combinational_from_to}]
  } elseif {$is_cadence_legacy && [get_attribute program_short_name] eq "genus"} {
    # If using Cadence Genus, swap standard "-ignore_clock_latency" for
    # "-combinational_from_to", since they do not support SDC 2.1 yet.
    set args [regsub {\-ignore_clock_latency} $args {-combinational_from_to}]
  } elseif {$is_timevision} {
    # If this is TimeVision, remove "-ignore_clock_latency" completely
    set args [regsub {\-ignore_clock_latency} $args {}]
  }

  set_max_delay {*}$args
}


proc _constrain_max_delay_if_exists {latency startpoint_names endpoint_names} {
  # Checks for the presence of the given startpoints and endpoints in the
  # design, and if they exist, creates a max delay from the startpoints to the
  # endpoints. This proc is intended to be used to constrain CDCs in
  # configurable IP. The total number of startpoints and endpoints is returned.

  set startpoints [get_pins -quiet $startpoint_names]
  set endpoints [get_pins -quiet $endpoint_names]
  if {[sizeof_collection $startpoints] > 0 && [sizeof_collection $endpoints] > 0} {
    compat_set_max_delay -ignore_clock_latency $latency -from $startpoints -to $endpoints
    return [expr {[sizeof_collection $startpoints] + [sizeof_collection $endpoints]}]
  }

  return 0
}

proc constrain_adb400_axi4_mst_slv {args} {
  # As specified in the ADB-400 User Guide, Section 3.4, a maximum delay
  # constraint is used here to minimize the round-trip latency for each channel
  # in the ADB. To ensure that the internal FIFO is not filled up, which would
  # degrade performance, the maximum round-trip latency must be less than the
  # number of FIFO slots multiplied by the slave clock period.

  # As a simplification of this, this procedure assumes that there is a single
  # FIFO slot, and the clock with the shortest period is the slave clock. This
  # results in an over-conservative constraint on the CDC during synthesis and
  # place and route, which can be refined during signoff.

  set param_dict [_args_to_dict "constrain_adb400_axi4_mst_slv" {*}$args]
  set required_params_found [expr {
    [dict exists $param_dict master] &&
    [dict exists $param_dict slave] &&
    [dict exists $param_dict shortest_period]
  }]

  if {!$required_params_found} {
    puts "ERROR: Required parameters not provided to constrain_adb400_axi4_mst_slv - skipping"
    puts $param_dict
    return
  }
  set master [dict get $param_dict master]
  set slave [dict get $param_dict slave]
  set shortest_period [dict get $param_dict shortest_period]

  debug_out "Constraining channels for $master <-> $slave ADB-400 CDC"

  set channels {p t aw w b ar r ac cr cd}
  set constrained_points 0
  foreach channel $channels {
    set channel_points 0
    # Master to slave - write REQ, write data and read REQ
    incr channel_points [_constrain_max_delay_if_exists $shortest_period \
      ${master}/u_mst/u_dnstrm_${channel}/rd_ptr_async_reg_*/CK \
      ${slave}/u_slv/u_upstrm_${channel}/g_j_*_u_syncn_rd_ptr_async/g_levels_2_u_sync/D \
    ]
    incr channel_points [_constrain_max_delay_if_exists $shortest_period \
      ${master}/u_mst/u_upstrm_${channel}/g_WIDTH_nz_data_reg_*/CK \
      ${slave}/u_slv/g_${channel}_opreg_u_${channel}_opreg/payld*_reg_*/D \
    ]
    incr channel_points [_constrain_max_delay_if_exists $shortest_period \
      ${master}/u_mst/u_upstrm_${channel}/wr_ptr_async_reg_*/CK \
      ${slave}/u_slv/u_dnstrm_${channel}/g_j_*_u_syncn_wr_ptr_async/g_levels_2_u_sync/D \
    ]

    # Slave to master - read ACK, read data and write ACK
    incr channel_points [_constrain_max_delay_if_exists $shortest_period \
      ${slave}/u_slv/u_dnstrm_${channel}/rd_ptr_async_reg_*/CK \
      ${master}/u_mst/u_upstrm_${channel}/g_j_*_u_syncn_rd_ptr_async/g_levels_2_u_sync/D \
    ]
    incr channel_points [_constrain_max_delay_if_exists $shortest_period \
      ${slave}/u_slv/u_upstrm_${channel}/g_WIDTH_nz_data_reg_*/CK \
      ${master}/u_mst/g_${channel}_opreg_no_tkn_u_${channel}_opreg/payld*_reg_*/D \
    ]
    incr channel_points [_constrain_max_delay_if_exists $shortest_period \
      ${slave}/u_slv/u_upstrm_${channel}/wr_ptr_async_reg_*/CK \
      ${master}/u_mst/u_dnstrm_${channel}/g_j_*_u_syncn_wr_ptr_async/g_levels_2_u_sync/D \
    ]
    incr constrained_points $channel_points

    debug_out "    Constrained ${channel_points} for channel ${channel} of $master <-> $slave ADB-400 CDC"
  }

  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/u_slv/u_si_ctrl/slvcandenyreqn_q_reg/CK \
    ${master}/u_mst/u_mi_ctrl/u_syncn_slvcandenyreqn/g_levels_2_u_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/u_slv/u_si_ctrl/slvmustacceptreqn_q_reg/CK \
    ${master}/u_mst/u_mi_ctrl/u_syncn_slvmustacceptreqn/g_levels_2_u_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${master}/u_mst/u_mi_ctrl/slvacceptn_q_reg/CK \
    ${slave}/u_slv/u_si_ctrl/u_syncn_slvacceptn/g_levels_2_u_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${master}/u_mst/u_mi_ctrl/slvdeny_q_reg/CK \
    ${slave}/u_slv/u_si_ctrl/u_syncn_slvdeny/g_levels_2_u_sync/D \
  ]

  debug_out "Constrained ${constrained_points} for $master <-> $slave ADB-400 CDC"
}


proc constrain_adb400_axi4s_mst_slv {args} {
  # As specified in the ADB-400 User Guide, Section 3.4, a maximum delay
  # constraint is used here to minimize the round-trip latency for each channel
  # in the ADB. To ensure that the internal FIFO is not filled up, which would
  # degrade performance, the maximum round-trip latency must be less than the
  # number of FIFO slots multiplied by the slave clock period.

  # As a simplification of this, this procedure assumes that there is a single
  # FIFO slot, and the clock with the shortest period is the slave clock. This
  # results in an over-conservative constraint on the CDC during synthesis and
  # place and route, which can be refined during signoff.

  # This procedure is specific to the AXI 4 Stream variant of the ADB-400
  # crossing, which has a single, unnamed channel.

  set param_dict [_args_to_dict "constrain_adb400_axi4s_mst_slv" {*}$args]
  set required_params_found [expr {
    [dict exists $param_dict master] &&
    [dict exists $param_dict slave] &&
    [dict exists $param_dict shortest_period]
  }]

  if {!$required_params_found} {
    puts "ERROR: Required parameters not provided to constrain_adb400_axi4s_mst_slv - skipping"
    puts $param_dict
    return
  }
  set master [dict get $param_dict master]
  set slave [dict get $param_dict slave]
  set shortest_period [dict get $param_dict shortest_period]

  debug_out "Constraining channels for $master <-> $slave ADB-400 A4S CDC"

  set constrained_points 0

  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${master}/u_mst/u_dnstrm/rd_ptr_async_reg_*/CK \
    ${slave}/u_slv/u_upstrm/g_j_*_u_syncn_rd_ptr_async/g_levels_2_u_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/u_slv/u_upstrm/wr_ptr_async_reg_*/CK \
    ${master}/u_mst/u_dnstrm/g_j_*_u_syncn_wr_ptr_async/g_levels_2_u_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/u_slv/u_upstrm/g_WIDTH_nz_data_reg_*/CK \
    ${master}/u_mst/g_opreg_u_opreg/payld*_reg_*/D \
  ]

  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/u_slv/u_si_ctrl/slvcandenyreqn_q_reg/CK \
    ${master}/u_mst/u_mi_ctrl/u_syncn_slvcandenyreqn/g_levels_2_u_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/u_slv/u_si_ctrl/slvmustacceptreqn_q_reg/CK \
    ${master}/u_mst/u_mi_ctrl/u_syncn_slvmustacceptreqn/g_levels_2_u_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${master}/u_mst/u_mi_ctrl/slvacceptn_q_reg/CK \
    ${slave}/u_slv/u_si_ctrl/u_syncn_slvacceptn/g_levels_2_u_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${master}/u_mst/u_mi_ctrl/slvdeny_q_reg/CK \
    ${slave}/u_slv/u_si_ctrl/u_syncn_slvdeny/g_levels_2_u_sync/D \
  ]

  debug_out "Constrained ${constrained_points} for $master <-> $slave ADB-400 A4S CDC"
}

proc constrain_sdc600_comasyncbridge_indirect_cdc {args} {
  # As specified in the SDC-600 Configuration and Integration Manual,
  # Section 7.10, a maximum delay constraint is used here to minimize the
  # latency for each crossing between the asynchronous bridge halves. The
  # shortest clock period involved in the CDC is used as the maximum delay -
  # this is passed into the procedure as an argument.

  set param_dict [_args_to_dict "constrain_sdc600_comasyncbridge_indirect_cdc" {*}$args]
  set required_params_found [expr {
    [dict exists $param_dict half_ext] &&
    [dict exists $param_dict half_int] &&
    [dict exists $param_dict shortest_period]
  }]

  if {!$required_params_found} {
    puts "ERROR: Required parameters not provided to constrain_sdc600_comasyncbridge_indirect_cdc - skipping"
    puts $param_dict
    return
  }
  set half_ext_inst [dict get $param_dict half_ext]
  set half_int_inst [dict get $param_dict half_int]
  set shortest_period [dict get $param_dict shortest_period]

  debug_out "Constraining $half_ext_inst <-> $half_int_inst SDC-600 CDC"

  set constrained_points 0

  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${half_ext_inst}/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_com2async/u_reg_async_tx_req/q_gen_0_u_flop/CK \
    ${half_int_inst}/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_async2com/u_sync_async_rx_req/sync_depth_2_u_cdc_capt_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${half_int_inst}/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_async2com/u_reg_async_rx_ack/q_gen_0_u_flop/CK \
    ${half_ext_inst}/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_com2async/u_sync_async_tx_ack/sync_depth_2_u_cdc_capt_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${half_ext_inst}/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_com2async/u_reg_async_tx_data/q_gen_*_u_flop/CK \
    ${half_int_inst}/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_async2com/u_reg_tx_data/q_gen_*_u_flop/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${half_int_inst}/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_async2com/u_reg_async_rx_linkup/q_gen_0_u_flop/CK \
    ${half_ext_inst}/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_com2async/u_sync_async_tx_linkup/sync_depth_2_u_cdc_capt_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${half_ext_inst}/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_com2async/u_reg_async_tx_linkest/q_gen_0_u_flop/CK \
    ${half_int_inst}/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_async2com/u_sync_async_rx_linkest/sync_depth_2_u_cdc_capt_sync/D \
  ]

  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${half_int_inst}/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_com2async/u_reg_async_tx_req/q_gen_0_u_flop/CK \
    ${half_ext_inst}/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_async2com/u_sync_async_rx_req/sync_depth_2_u_cdc_capt_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${half_ext_inst}/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_async2com/u_reg_async_rx_ack/q_gen_0_u_flop/CK \
    ${half_int_inst}/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_com2async/u_sync_async_tx_ack/sync_depth_2_u_cdc_capt_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${half_int_inst}/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_com2async/u_reg_async_tx_data/q_gen_*_u_flop/CK \
    ${half_ext_inst}/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_async2com/u_reg_tx_data/q_gen_*_u_flop/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${half_ext_inst}/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_async2com/u_reg_async_rx_linkup/q_gen_0_u_flop/CK \
    ${half_int_inst}/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_com2async/u_sync_async_tx_linkup/sync_depth_2_u_cdc_capt_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${half_int_inst}/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_com2async/u_reg_async_tx_linkest/q_gen_0_u_flop/CK \
    ${half_ext_inst}/u_sdc600_comasyncbridge_indirect_half/u_sdc600_comasyncbridge_indirect_async2com/u_sync_async_rx_linkest/sync_depth_2_u_cdc_capt_sync/D \
  ]

  debug_out "Constrained ${constrained_points} for $half_ext_inst <-> $half_int_inst SDC-600 CDC"
}

proc constrain_css600_pulseasyncbridge_cdc {args} {
  # As specified in the SOC-600 Configuration and Integration Manual,
  # Section B4.13, a maximum delay constraint is used here to minimize the
  # latency for each crossing between the asynchronous bridge master and slave.
  # The shortest clock period involved in the CDC is used as the maximum delay -
  # this is passed into the procedure as an argument.

  set param_dict [_args_to_dict "constrain_css600_pulseasyncbridge_cdc" {*}$args]
  set required_params_found [expr {
    [dict exists $param_dict master] &&
    [dict exists $param_dict slave] &&
    [dict exists $param_dict shortest_period]
  }]

  if {!$required_params_found} {
    puts "ERROR: Required parameters not provided to constrain_css600_pulseasyncbridge_cdc - skipping"
    puts $param_dict
    return
  }
  set master [dict get $param_dict master]
  set slave [dict get $param_dict slave]
  set shortest_period [dict get $param_dict shortest_period]

  debug_out "Constraining $master <-> $slave CSS-600 PULSEASYNCBRIDGE CDC"

  set constrained_points 0

  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/pulse_req_q_reg_*/CK \
    ${master}/gen_req_sync_no_cdc_*_u_css600_cdc_capt_sync_req/sync_depth_2_u_cdc_capt_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${master}/pulse_ack_q_reg_*/CK \
    ${slave}/gen_ack_sync_no_cdc_*_u_css600_cdc_capt_sync_ack/sync_depth_2_u_cdc_capt_sync/D \
  ]

  debug_out "Constrained ${constrained_points} for $master <-> $slave CSS-600 PULSEASYNCBRIDGE CDC"
}

proc constrain_css600_pulseasyncbridge_wakeonpulse_cdc {args} {
  # As specified in the SOC-600 Configuration and Integration Manual,
  # Section B4.13, a maximum delay constraint is used here to minimize the
  # latency for each crossing between the asynchronous bridge master and slave.
  # The shortest clock period involved in the CDC is used as the maximum delay -
  # this is passed into the procedure as an argument.

  set param_dict [_args_to_dict "constrain_css600_pulseasyncbridge_wakeonpulse_cdc" {*}$args]
  set required_params_found [expr {
    [dict exists $param_dict master] &&
    [dict exists $param_dict slave] &&
    [dict exists $param_dict shortest_period]
  }]

  if {!$required_params_found} {
    puts "ERROR: Required parameters not provided to constrain_css600_pulseasyncbridge_wakeonpulse_cdc - skipping"
    puts $param_dict
    return
  }
  set master [dict get $param_dict master]
  set slave [dict get $param_dict slave]
  set shortest_period [dict get $param_dict shortest_period]

  debug_out "Constraining $master <-> $slave CSS-600 PULSEASYNCBRIDGE (WAKE_ON_PULSE) CDC"

  set constrained_points 0

  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/gen_wake_on_pulse_pulse_req_qq_reg_*/CK \
    ${master}/gen_req_sync_no_cdc_*_u_css600_cdc_capt_sync_req/sync_depth_2_u_cdc_capt_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${master}/pulse_ack_q_reg_*/CK \
    ${slave}/gen_ack_sync_no_cdc_*_u_css600_cdc_capt_sync_ack/sync_depth_2_u_cdc_capt_sync/D \
  ]

  debug_out "Constrained ${constrained_points} for $master <-> $slave CSS-600 PULSEASYNCBRIDGE (WAKE_ON_PULSE) CDC"
}

proc constrain_css600_apbasyncbridge_cdc {args} {
  # As specified in the SOC-600 Configuration and Integration Manual,
  # Section B4.13, a maximum delay constraint is used here to minimize the
  # latency for each crossing between the asynchronous bridge master and slave.
  # The shortest clock period involved in the CDC is used as the maximum delay -
  # this is passed into the procedure as an argument.

  set param_dict [_args_to_dict "constrain_css600_apbasyncbridge_cdc" {*}$args]
  set required_params_found [expr {
    [dict exists $param_dict master] &&
    [dict exists $param_dict slave] &&
    [dict exists $param_dict shortest_period]
  }]

  if {!$required_params_found} {
    puts "ERROR: Required parameters not provided to constrain_css600_apbasyncbridge_cdc - skipping"
    puts $param_dict
    return
  }
  set master [dict get $param_dict master]
  set slave [dict get $param_dict slave]
  set shortest_period [dict get $param_dict shortest_period]

  debug_out "Constraining $master <-> $slave CSS-600 APBASYNCBRIDGE CDC"

  set constrained_points 0

  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/u_slv_core/apb_async_req_r_reg/CK \
    ${master}/u_req_sync/sync_depth_2_u_cdc_capt_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/u_slv_core/apb_async_req_payload_r_reg_*/CK \
    ${master}/u_mstr_core/u_cdc_capt_nosync_req_payload/gen_cdc_capt_nosync_*_u_flop/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${master}/u_mstr_core/apb_async_ack_r_reg/CK \
    ${slave}/u_ack_sync/sync_depth_2_u_cdc_capt_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${master}/u_mstr_core/apb_async_resp_payload_r_reg_*/CK \
    ${slave}/u_slv_core/u_cdc_capt_nosync_resp_payload/gen_cdc_capt_nosync_*_u_flop/D \
  ]

  debug_out "Constrained ${constrained_points} for $master <-> $slave CSS-600 APBASYNCBRIDGE CDC"

}

proc constrain_css600_tpiu_cdc {args} {
  # As specified in the SOC-600 Configuration and Integration Manual,
  # Section B4.13, a maximum delay constraint is used here to minimize the
  # latency for each crossing between the asynchronous bridge master and slave.
  # The shortest clock period involved in the CDC is used as the maximum delay -
  # this is passed into the procedure as an argument.

  set param_dict [_args_to_dict "constrain_css600_tpiu_cdc" {*}$args]
  set required_params_found [expr {
    [dict exists $param_dict path] &&
    [dict exists $param_dict shortest_period]
  }]

  if {!$required_params_found} {
    puts "ERROR: Required parameters not provided to constrain_css600_tpiu_cdc - skipping"
    puts $param_dict
    return
  }
  set tpiu [dict get $param_dict path]
  set shortest_period [dict get $param_dict shortest_period]

  debug_out "Constraining $tpiu CSS-600 TPIU CDC"

  set constrained_points 0

  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${tpiu}/u_css600_tpiu_trace_bridge/trig_port_done_reg/CK \
    ${tpiu}/u_css600_tpiu_core_sync/u_css600_cdc_capt_sync_trigportdone/sync_depth_2_u_cdc_capt_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${tpiu}/u_css600_trace_formatter/gen_trig_port_trig_port_int_reg/CK \
    ${tpiu}/u_css600_tpiu_trace_sync/u_css600_cdc_capt_sync_trigport/sync_depth_2_u_cdc_capt_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${tpiu}/u_css600_tpiu_atb_fifo/fifodata_cdc_chk_reg_*/CK \
    ${tpiu}/u_css600_tpiu_trace_fifo/fifo_r_data_reg_*/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${tpiu}/u_css600_tpiu_atb_fifo/wr_ptr_gray_cdc_chk_reg_*/CK \
    ${tpiu}/u_css600_tpiu_trace_sync/u_css600_cdc_capt_sync_wrptrgray*/sync_depth_2_u_cdc_capt_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${tpiu}/u_css600_tpiu_trace_fifo/rd_ptr_gray_cdc_chk_reg_*/CK \
    ${tpiu}/u_css600_tpiu_core_sync/u_css600_cdc_capt_sync_rdptrgray*/sync_depth_2_u_cdc_capt_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${tpiu}/u_css600_tpiu_apb_if/tp_addr_enc_cdc_chk_reg_*/CK \
    ${tpiu}/u_css600_tpiu_trace_sync/u_css600_cdc_capt_nosync_tpreqbus/gen_cdc_capt_nosync_*_u_flop/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${tpiu}/u_css600_tpiu_apb_if/tp_wdata_cdc_chk_reg_*/CK \
    ${tpiu}/u_css600_tpiu_trace_sync/u_css600_cdc_capt_nosync_tpreqbus/gen_cdc_capt_nosync_*_u_flop/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${tpiu}/u_css600_tpiu_apb_if/tp_xfer_req_cdc_chk_reg/CK \
    ${tpiu}/u_css600_tpiu_trace_sync/u_css600_cdc_capt_sync_tpxferreq/sync_depth_2_u_cdc_capt_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${tpiu}/u_css600_tpiu_apb_if/tp_xfer_type_cdc_chk_reg/CK \
    ${tpiu}/u_css600_tpiu_trace_sync/u_css600_cdc_capt_nosync_tpreqbus/gen_cdc_capt_nosync_34_u_flop/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${tpiu}/u_css600_tpiu_reg_t/tp_rdata_cdc_chk_reg_*/CK \
    ${tpiu}/u_css600_tpiu_core_sync/u_css600_cdc_capt_nosync_tprdata/gen_cdc_capt_nosync_*_u_flop/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${tpiu}/u_css600_tpiu_reg_t/tp_xfer_req_q2_reg/CK \
    ${tpiu}/u_css600_tpiu_core_sync/u_css600_cdc_capt_sync_tpxferack/sync_depth_2_u_cdc_capt_sync/D \
  ]

  debug_out "Constrained ${constrained_points} for ${tpiu} CSS-600 TPIU CDC"

  # The TPIU contains an internal pulseasyncbridge component - constrain this
  # using the previously defined procedure
  constrain_css600_pulseasyncbridge_cdc \
    -master ${tpiu}/u_css600_pulseasyncbridgemstr_syncreq \
    -slave ${tpiu}/u_css600_pulseasyncbridgeslv_sycnreq \
    -shortest_period $shortest_period
}

proc constrain_css600_atbasyncbridge_cdc {args} {
  # As specified in the SOC-600 Configuration and Integration Manual,
  # Section B4.13, a maximum delay constraint is used here to minimize the
  # latency for each crossing between the asynchronous bridge master and slave.
  # The shortest clock period involved in the CDC is used as the maximum delay -
  # this is passed into the procedure as an argument.

  set param_dict [_args_to_dict "constrain_css600_atbasyncbridge_cdc" {*}$args]
  set required_params_found [expr {
    [dict exists $param_dict master] &&
    [dict exists $param_dict slave] &&
    [dict exists $param_dict shortest_period]
  }]

  if {!$required_params_found} {
    puts "ERROR: Required parameters not provided to constrain_css600_atbasyncbridge_cdc - skipping"
    puts $param_dict
    return
  }
  set master [dict get $param_dict master]
  set slave [dict get $param_dict slave]
  set shortest_period [dict get $param_dict shortest_period]

  debug_out "Constraining $master <-> $slave CSS-600 ATBASYNCBRIDGE CDC"

  set constrained_points 0

  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${master}/u_css600_atbasyncbridge_mst_fifo/flush_req_reg/CK \
    ${slave}/u_css600_atbasyncbridge_slv_sync/u_cdc_flush_req/sync_depth_2_u_cdc_capt_sync/D \
  ]

  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${master}/u_css600_atbasyncbridge_mst_fifo/rd_ptr_gray_reg_*/CK \
    ${slave}/u_css600_atbasyncbridge_slv_sync/u_cdc_rd_ptr_sync_*/sync_depth_2_u_cdc_capt_sync/D \
  ]

  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/u_css600_atbasyncbridge_slv_fifo/fifo_data_word_reg_*_*/CK \
    ${master}/u_css600_atbasyncbridge_mst_fifo/u_cdc_capt_nosync_atbytes/gen_cdc_capt_nosync_*_u_flop/D \
  ]

  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/u_css600_atbasyncbridge_slv_fifo/fifo_data_word_reg_*_*/CK \
    ${master}/u_css600_atbasyncbridge_mst_fifo/u_cdc_capt_nosync_atdata/gen_cdc_capt_nosync_*_u_flop/D \
  ]

  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/u_css600_atbasyncbridge_slv_fifo/fifo_data_word_reg_*_*/CK \
    ${master}/u_css600_atbasyncbridge_mst_fifo/u_cdc_capt_nosync_atid/gen_cdc_capt_nosync_*_u_flop/D \
  ]

  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/u_css600_atbasyncbridge_slv_fifo/flush_done_reg/CK \
    ${master}/u_css600_atbasyncbridge_mst_sync/u_cdc_flush_done_sync/sync_depth_2_u_cdc_capt_sync_high/D \
  ]

  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/u_css600_atbasyncbridge_slv_fifo/wrptr_gray_reg_*/CK \
    ${master}/u_css600_atbasyncbridge_mst_sync/u_cdc_wr_ptr_sync*/sync_depth_2_u_cdc_capt_sync/D \
  ]

  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${master}/u_css600_atbasyncbridge_mst_fifo/sync_done_reg/CK \
    ${slave}/u_css600_atbasyncbridge_slv_sync/u_sync_done/sync_depth_2_u_cdc_capt_sync_high/D \
  ]

  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/u_css600_atbasyncbridge_slv_fifo/sync_clear_reg/CK \
    ${master}/u_css600_atbasyncbridge_mst_sync/u_cdc_sync_clear/sync_depth_2_u_cdc_capt_sync_high/D \
  ]

  debug_out "Constrained ${constrained_points} for $master <-> $slave CSS-600 ATBASYNCBRIDGE CDC"
}

proc constrain_mhuv2_cdc {args} {
  # The MHUv2 module within the design has a crossing that is quite similar to
  # the SOC-600 apbasyncbridge CDC, except that extra signals are defined. As
  # such, the constrain_css600_apbasyncbridge_cdc procedure was used as a
  # starting point for these constraints.

  set param_dict [_args_to_dict "constrain_mhuv2_cdc" {*}$args]
  set required_params_found [expr {
    [dict exists $param_dict receiver] &&
    [dict exists $param_dict sender] &&
    [dict exists $param_dict shortest_period]
  }]

  if {!$required_params_found} {
    puts "ERROR: Required parameters not provided to constrain_mhuv2_cdc - skipping"
    puts $param_dict
    return
  }
  set receiver [dict get $param_dict receiver]
  set sender [dict get $param_dict sender]
  set shortest_period [dict get $param_dict shortest_period]

  debug_out "Constraining $sender <-> $receiver MHUv2 CDC"

  set constrained_points 0

  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${sender}/u_mhuv2_f1_adb_apb3_slv/u_mhuv2_f1_adb_apb3_slv_core/apb_async_req_r_reg/CK \
    ${receiver}/u_mhuv2_f1_adb_apb3_mst/u_mhuv2_f1_adb_sync_apb_async_req/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${sender}/u_mhuv2_f1_adb_apb3_slv/u_mhuv2_f1_adb_apb3_slv_core/apb_async_req_payload_r_reg_*/CK \
    ${receiver}/u_mhuv2_f1_adb_apb3_mst/u_mhuv2_f1_adb_apb3_mst_core/u_mhuv2_f1_adb_cdc_capt_nosync/u_arm_element_cdc_capt_nosync/BK_CDC_CAPT_NOSYNC_*_u_sdffrpq/u_arm_sdffrpq/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${receiver}/u_mhuv2_f1_adb_apb3_mst/u_mhuv2_f1_adb_apb3_mst_core/apb_async_ack_r_reg/CK \
    ${sender}/u_mhuv2_f1_adb_apb3_slv/u_mhuv2_f1_adb_sync_apb_async_ack/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${receiver}/u_mhuv2_f1_adb_apb3_mst/u_mhuv2_f1_adb_apb3_mst_core/apb_async_resp_payload_r_reg_*/CK \
    ${sender}/u_mhuv2_f1_adb_apb3_slv/u_mhuv2_f1_adb_apb3_slv_core/u_mhuv2_f1_adb_cdc_capt_nosync/u_arm_element_cdc_capt_nosync/BK_CDC_CAPT_NOSYNC_*_u_sdffrpq/u_arm_sdffrpq/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${sender}/u_mhuv2_f1_snd_mhu_reg/access_req_reg/CK \
    ${receiver}/u_mhuv2_f1_adb_apb3_mst/u_mhuv2_f1_adb_sync_recwakeup_async/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${receiver}/u_mhuv2_f1_adb_apb3_mst/recawake_r_reg/CK \
    ${sender}/u_mhuv2_f1_adb_apb3_slv/u_mhuv2_f1_adb_sync_recawake_async/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${receiver}/u_mhuv2_f1_adb_posedge_slave/edgereqasync_state_reg_*/CK \
    ${sender}/u_mhuv2_f1_adb_posedge_master/SYNC_*_u_adb_sync_edgereqasync/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${sender}/u_mhuv2_f1_adb_posedge_master/edge_detect_flop_reg_*/CK \
    ${receiver}/u_mhuv2_f1_adb_posedge_slave/SYNC_*_u_adb_sync_edgeack/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]

  debug_out "Constrained ${constrained_points} for $sender <-> $receiver MHUv2 CDC"
}

proc constrain_css600_dp_cdc {args} {
  # As specified in the SOC-600 Configuration and Integration Manual,
  # Section B4.13, a maximum delay constraint is used here to minimize the
  # latency for each crossing between the asynchronous bridge master and slave.
  # The shortest clock period involved in the CDC is used as the maximum delay -
  # this is passed into the procedure as an argument.

  set param_dict [_args_to_dict "constrain_css600_dp_cdc" {*}$args]
  set required_params_found [expr {
    [dict exists $param_dict master] &&
    [dict exists $param_dict slave] &&
    [dict exists $param_dict shortest_period]
  }]

  if {!$required_params_found} {
    puts "ERROR: Required parameters not provided to constrain_css600_dp_cdc - skipping"
    puts $param_dict
    return
  }
  set master [dict get $param_dict master]
  set slave [dict get $param_dict slave]
  set shortest_period [dict get $param_dict shortest_period]

  debug_out "Constraining $master <-> $slave CSS-600 DP CDC"

  set constrained_points 0

  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/u_css600_dpslv_cdc/bus_req_dp_mstr_q_reg/CK \
    ${master}/u_css600_dpmstr_apb_if/u_css600_cdc_capt_sync_req/sync_depth_2_u_cdc_capt_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/u_css600_dpslv_cdc/bus_write_q_reg/CK \
    ${master}/u_css600_dpmstr_apb_if/u_css600_cdc_capt_nosync_bus_write/gen_cdc_capt_nosync_0_u_flop/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/u_css600_dpslv_cdc/bus_wdata_q_reg_*/CK \
    ${master}/u_css600_dpmstr_apb_if/u_css600_cdc_capt_nosync_bus_wdata/gen_cdc_capt_nosync_*_u_flop/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/u_css600_dpslv_cdc/bus_addr_q_reg_*/CK \
    ${master}/u_css600_dpmstr_apb_if/u_css600_cdc_capt_nosync_bus_addr/gen_cdc_capt_nosync_*_u_flop/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/u_css600_dpslv_reg_block/select_addr_q_reg_*/CK \
    ${master}/u_css600_dpmstr_apb_if/u_css600_cdc_capt_nosync_bus_addr/gen_cdc_capt_nosync_*_u_flop/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${master}/u_css600_dpmstr_apb_if/ack_state_reg/CK \
    ${slave}/u_css600_dpslv_cdc/u_css600_cdc_capt_sync_ack/sync_depth_2_u_cdc_capt_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${master}/u_css600_dpmstr_apb_if/prdata_q_reg_*/CK \
    ${slave}/u_css600_dpslv_cdc/u_css600_cdc_capt_nosync_bus_rdata/gen_cdc_capt_nosync_*_u_flop/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${master}/u_css600_dpmstr_apb_if/pslverr_q_reg/CK \
    ${slave}/u_css600_dpslv_cdc/u_css600_cdc_capt_nosync_bus_err/gen_cdc_capt_nosync_0_u_flop/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${slave}/u_css600_pulseasyncbridgeslv_qactive_only/pulse_req_q_reg_0/CK \
    ${master}/u_css600_pulseasyncbridgemstr/gen_req_sync_no_cdc_0_u_css600_cdc_capt_sync_req/sync_depth_2_u_cdc_capt_sync/D \
  ]
  incr constrained_points [_constrain_max_delay_if_exists $shortest_period \
    ${master}/u_css600_pulseasyncbridgemstr/pulse_ack_q_reg_0/CK \
    ${slave}/u_css600_pulseasyncbridgeslv_qactive_only/gen_ack_sync_no_cdc_0_u_css600_cdc_capt_sync_ack/sync_depth_2_u_cdc_capt_sync/D \
  ]

  debug_out "Constrained ${constrained_points} for $master <-> $slave CSS-600 DP CDC"
}


proc constrain_gcounter {args} {
  # The gcounter module is part of the SSE-710 IP, and involves a number of
  # crossings which need to be balanced. This procedure sets a max delay
  # constraint equal to the shortest clock period involved in the CDC, and also
  # indicates which signals must be balanced using comments. Further signoff
  # checks are required to ensure valid operation of the crossings.

  set param_dict [_args_to_dict "constrain_gcounter" {*}$args]
  set required_params_found [expr {
    [dict exists $param_dict path] &&
    [dict exists $param_dict shortest_period]
  }]

  if {!$required_params_found} {
    puts "ERROR: Required parameters not provided to constrain_gcounter - skipping"
    puts $param_dict
    return
  }
  set hierarchy [dict get $param_dict path]
  set pclk_period [dict get $param_dict shortest_period]

  # Signals when the enable_cnt and hdbg signals are ready to be captured by the
  # CCLK domain
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_apbif/cntcr_write_in_progress_reg/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_counter/u_gct_synchronizer_cntcr_write_complete/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]

  # Signals to the PCLK domain when the above signals have been captured by the
  # CCLK domain
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_counter/cntcr_write_complete_reg/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_apbif/u_gct_syncpulse_cntcr_sync/u_gct_synchronizer/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]

  # The CNTCR data - these signals must be balanced against the associated
  # "write_in_progress" signal
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_apbif/enable_cnt_reg/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_counter/u_gct_synchronizer_enable_cnt/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_apbif/hdbg_reg/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_counter/u_gct_synchronizer_hdbg/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]

  # These two signals indicate when the preload values are ready for capturing
  # by the CCLK domain
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_apbif/cntcvl_write_in_progress_reg/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_counter/u_gct_syncpulse_preload_cntcvl/u_gct_synchronizer/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_apbif/cntcvu_write_in_progress_reg/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_counter/u_gct_syncpulse_preload_cntcvu/u_gct_synchronizer/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]

  # These two signals acknowledge the capture of the preload values
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_counter/u_gct_syncpulse_preload_cntcvl/sync_flop3_reg/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_apbif/u_gct_syncpulse_cntcvl_sync/u_gct_synchronizer/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]

  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_counter/u_gct_syncpulse_preload_cntcvu/sync_flop3_reg/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_apbif/u_gct_syncpulse_cntcvu_sync/u_gct_synchronizer/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]

  # Both high and low counter preload signals must be balanced against the
  # associated "write_in_progress" signals
  # The low counter preload value is used in the main counter and the
  # pre-counter, and also eventually used (indirectly) to determine when the
  # pre-counter had rolled over, which is captured by a register
  # (enincr_maincount_reg)
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_apbif/preload_cntcvl_data_reg_*/CK \
  ] -to [get_pins [list \
    ${hierarchy}/u_gcounter_asyncapb_counter/u_gcounter_asyncapb_counter_core/enincr_maincount_reg/D \
    ${hierarchy}/u_gcounter_asyncapb_counter/u_gcounter_asyncapb_counter_core/maincount_reg_*/D \
    ${hierarchy}/u_gcounter_asyncapb_counter/u_gcounter_asyncapb_counter_core/precount_reg_*/D \
  ]]

  # The high counter perload value is just used to load the main counter
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_apbif/preload_cntcvu_data_reg_*/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_counter/u_gcounter_asyncapb_counter_core/maincount_reg_*/D \
  ]

  # cclktoggle_reg indicates when the counter has just been updated (inverts on
  # every rising edge of the clock) - this signals to the PCLK domain when it
  # should read the register values
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_counter/cclktoggle_reg/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_apbif/u_gct_syncpulse_cclktoggle_sync/u_gct_synchronizer/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]

  # The current counter value - this is sent to the PCLK domain to be read over
  # the APB interface - must be balanced to the cclktoggle_reg signal
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_counter/u_gcounter_asyncapb_counter_core/maincount_reg_*/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_apbif/tsvalueb_rd_data_val_reg_*/D \
  ]
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_counter/u_gcounter_asyncapb_counter_core/precount_reg_*/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_apbif/tsvalueb_rd_data_val_reg_*/D \
  ]

  # This is a flag to indicate whether a halt request caused the counter to
  # halt - independent of other signals.
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_counter/dbgh_reg/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gcounter_asyncapb_apbif/u_dbgh_ss/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]
}

proc constrain_gtimer {args} {
  # The gtimer module is part of the SSE-710 IP, and involves a number of
  # crossings which need to be balanced. This procedure sets a max delay
  # constraint equal to the shortest clock period involved in the CDC, and also
  # indicates which signals must be balanced using comments. Further signoff
  # checks are required to ensure valid operation of the crossings.

  set param_dict [_args_to_dict "constrain_gtimer" {*}$args]
  set required_params_found [expr {
    [dict exists $param_dict path] &&
    [dict exists $param_dict shortest_period]
  }]

  if {!$required_params_found} {
    puts "ERROR: Required parameters not provided to constrain_gtimer - skipping"
    puts $param_dict
    return
  }
  set hierarchy [dict get $param_dict path]
  set pclk_period [dict get $param_dict shortest_period]

  # CCLK -> PCLK

  # update_timer_regs_reg indicates when the timer registers have just been
  # updated (inverts on every rising edge of the clock) - this signals to the
  # PCLK domain when it should read the register values - these signals should
  # be balanced
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/update_timer_regs_reg/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_apbif/u_gct_syncpulse_cntp_update_timer/u_gct_synchronizer/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]

  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/timer_control_reg_*/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_apbif/cntpctl_rd_data_1_0_reg_*/D \
  ]

  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/compare_value_reg_*/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_apbif/cntpcval_rd_data_reg_*/D \
  ]

  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/timer_count_reg_*/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_apbif/cntpct_rd_val_reg_*/D \
  ]

  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/timer_value_reg_*/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_apbif/cntptval_rd_val_reg_*/D \
  ]

  # This status flag is independent of the logic above, but should probably have
  # a similar crossing latency.
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/timer_control_reg_*/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_apbif/u_cntpctl_rd_data_2/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]

  # PCLK -> CCLK

  # Pointer and payload for writing the timer control register - these signals
  # should be balanced
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_apbif/u_gtimer_asyncapb_regwrite_logic_physical/u_gtimer_asyncapb_asyncreg_wr_logic_cnt_ctl/write_in_progress_toggle_reg/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/u_gct_syncpulse_ctl/u_gct_synchronizer/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/u_gct_syncpulse_ctl/sync_flop3_reg/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_apbif/u_gct_syncpulse_cntp_ctl_write_complete/u_gct_synchronizer/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_apbif/u_gtimer_asyncapb_regwrite_logic_physical/cnt_ctl_write_val_reg_*/CK
  ] -to [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/timer_control_reg_*/D
  ]

  # Pointer and payload for timer value to the CCLK domain - this value sets the
  # timer value and the lower 32 bits of the compare value - these signals
  # should be balanced
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_apbif/u_gtimer_asyncapb_regwrite_logic_physical/u_gtimer_asyncapb_asyncreg_wr_logic_cnt_tval/write_in_progress_toggle_reg/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/u_gct_syncpulse_tval/u_gct_synchronizer/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/u_gct_syncpulse_tval/sync_flop3_reg/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_apbif/u_gct_syncpulse_cntp_tval_write_complete/u_gct_synchronizer/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_apbif/u_gtimer_asyncapb_regwrite_logic_physical/cnt_tval_write_val_reg_*/CK \
  ] -to [get_pins [list \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/compare_value_reg_*/D \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/timer_value_reg_*/D \
  ]]

  # Pointer and payload for writing the lower compare value to the CCLK
  # domain - sets the lower 32 bits of the compare value and sets the timer
  # value. Can also trigger the timer event and generate an interrupt - these
  # signals should be balanced
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_apbif/u_gtimer_asyncapb_regwrite_logic_physical/u_gtimer_asyncapb_asyncreg_wr_logic_cntl_cval/write_in_progress_toggle_reg/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/u_gct_syncpulse_lcval/u_gct_synchronizer/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/u_gct_syncpulse_lcval/sync_flop3_reg/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_apbif/u_gct_syncpulse_cntpl_cval_write_complete/u_gct_synchronizer/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_apbif/u_gtimer_asyncapb_regwrite_logic_physical/cntl_cval_write_val_reg_*/CK \
  ] -to [get_pins [list \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/interrupt_out_reg/D \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/timer_control_reg_*/D \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/compare_value_reg_*/D \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/timer_value_reg_*/D \
  ]]

  # Pointer and payload for writing the upper compare value to the CCLK
  # domain - sets the lower 32 bits of the compare value and sets the timer
  # value. Can also trigger the timer event and generate an interrupt - these
  # signals should be balanced
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_apbif/u_gtimer_asyncapb_regwrite_logic_physical/u_gtimer_asyncapb_asyncreg_wr_logic_cntu_cval/write_in_progress_toggle_reg/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/u_gct_syncpulse_ucval/u_gct_synchronizer/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/u_gct_syncpulse_ucval/sync_flop3_reg/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_apbif/u_gct_syncpulse_cntpu_cval_write_complete/u_gct_synchronizer/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_apbif/u_gtimer_asyncapb_regwrite_logic_physical/cntu_cval_write_val_reg_*/CK \
  ] -to [get_pins [list \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/interrupt_out_reg/D \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/timer_control_reg_*/D \
    ${hierarchy}/u_gtimer_asyncapb_core_physical/compare_value_reg_*/D \
  ]]

  ## SSE710 gtimer configuration may not need this crossing or it may be optimised-out
  # Independent flag signal, no balancing or latency requirement.
  if {[sizeof_collection [get_pins -quiet ${hierarchy}/u_gtimer_asyncapb_core_virtual/cntvoff_sync_reg/CK]] > 0} {
    compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
      ${hierarchy}/u_gtimer_asyncapb_core_virtual/cntvoff_sync_reg/CK \
    ] -to [get_pins \
      ${hierarchy}/u_gtimer_asyncapb_apbif/u_gct_syncpulse_cntvoff_sync/u_gct_synchronizer/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
    ]
  }

  # update_timer_regs_reg indicates when the timer registers have just been
  # updated (inverts on every rising edge of the clock) - this signals to the
  # PCLK domain when it should read the register values - these signals should
  # be balanced
  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_core_virtual/update_timer_regs_reg/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_apbif/u_gct_syncpulse_cntv_update_timer/u_gct_synchronizer/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  ]

  compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_core_virtual/timer_count_reg_*/CK \
  ] -to [get_pins \
    ${hierarchy}/u_gtimer_asyncapb_apbif/cntvct_rd_val_reg_*/D \
  ]

  #updated 28/11/2019
  # This should have a similar latency to the update_timer_regs group
  #compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
  #  ${hierarchy}/u_gtimer_asyncapb_core_virtual/timer_control_reg_*/CK \
  #] -to [get_pins \
  #  ${hierarchy}/u_gtimer_asyncapb_apbif/u_cntvctl_rd_data_2/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
  #]

  # SSE710 gtimer configuration may not need this crossing (or it may be optimised-out)
  # The following four signals are all independent pointers - no balancing
  # required.
  if {[sizeof_collection [get_pins -quiet ${hierarchy}/u_gtimer_asyncapb_core_virtual/u_gct_syncpulse_ctl/sync_flop3_reg/CK]] > 0} {
    compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
      ${hierarchy}/u_gtimer_asyncapb_core_virtual/u_gct_syncpulse_ctl/sync_flop3_reg/CK \
    ] -to [get_pins \
      ${hierarchy}/u_gtimer_asyncapb_apbif/u_gct_syncpulse_cntv_ctl_write_complete/u_gct_synchronizer/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
    ]
    compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
      ${hierarchy}/u_gtimer_asyncapb_core_virtual/u_gct_syncpulse_lcval/sync_flop3_reg/CK \
    ] -to [get_pins \
      ${hierarchy}/u_gtimer_asyncapb_apbif/u_gct_syncpulse_cntvl_cval_write_complete/u_gct_synchronizer/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D \
    ]
    compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
      ${hierarchy}/u_gtimer_asyncapb_core_virtual/u_gct_syncpulse_tval/sync_flop3_reg/CK \
    ] -to [get_pins \
      ${hierarchy}/u_gtimer_asyncapb_apbif/u_gct_syncpulse_cntv_tval_write_complete/u_gct_synchronizer/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
    ]
    compat_set_max_delay -ignore_clock_latency $pclk_period -from [get_pins \
      ${hierarchy}/u_gtimer_asyncapb_core_virtual/u_gct_syncpulse_ucval/sync_flop3_reg/CK \
    ] -to [get_pins \
      ${hierarchy}/u_gtimer_asyncapb_apbif/u_gct_syncpulse_cntvu_cval_write_complete/u_gct_synchronizer/u_cdc_capt_sync/u_sdff2yrpq/u_arm_sdff2yrpq/D
    ]
  }
}

proc constrain_nic400_sys_apb_aclk_ctrlclk_cdc {shortest_period} {
  # The NIC-400 IP is released separately to the SSE-710 IP, but the CDCs are
  # only minimally documented in the associated Configuration and Signoff
  # Guide. This procedure sets a max delay constraint equal to the shortest
  # clock period involved in each CDC, and also indicates which signals must be
  # balanced using comments. Further signoff checks are required to ensure
  # valid operation of the crossings. Please see the SSE-710 Configuration and
  # Integration Manual for futher information.

  set nic400_path      u_pd_systop/u_base_systop/u_nic400_sys_apb
  set aclk_s_path      ${nic400_path}/u_cd_a/u_ib_slave_9_ib_s
  set ctrlclk_dmu_path ${nic400_path}/u_cd_ctrl/u_dmu_ctrl_sse710_sys_apb
  set ctrlclk_m_path   ${nic400_path}/u_cd_ctrl/u_ib_slave_9_ib_m

  # This is a flag signal, used to indicate to the receiving domain when it
  # should be active (i.e. when data is available in the FIFO). Indepdent, but
  # delay should be minimised.
  compat_set_max_delay -ignore_clock_latency $shortest_period -from [get_pins \
    ${aclk_s_path}/u_cdc_launch_empty_ptr_gry/gen_cdc_launch_gry_*_u_flop/CK \
  ] -to [get_pins \
    ${ctrlclk_dmu_path}/u_cactive_wakeup_sync/gen_cdc_capt_sync_*_u_sync/D \
  ]

  # The pointers and payload corresponding to the A channel FIFOs - these must
  # be balanced.
  compat_set_max_delay -ignore_clock_latency $shortest_period -from [get_pins \
    ${ctrlclk_m_path}/u_a_fifo_rd/u_cdc_launch_rd_ptr_gry/gen_cdc_launch_gry_*_u_flop/CK \
  ] -to [get_pins \
    ${aclk_s_path}/u_a_fifo_wr/u_sync_rd_ptr_gry/u_cdc_capt_sync_ptr_*/gen_cdc_capt_sync_*_u_sync/D \
  ]
  compat_set_max_delay -ignore_clock_latency $shortest_period -from [get_pins \
    ${aclk_s_path}/u_a_fifo_wr/u_cdc_launch_wr_ptr_gry/gen_cdc_launch_gry_*_u_flop/CK \
  ] -to [get_pins \
    ${ctrlclk_m_path}/u_a_fifo_rd/u_sync_wr_ptr_gry/u_cdc_capt_sync_ptr_*/gen_cdc_capt_sync_*_u_sync/D \
  ]
  compat_set_max_delay -ignore_clock_latency $shortest_period -through [get_pins \
    ${aclk_s_path}/u_a_fifo_wr/dst_data[*] \
  ] -to [get_pins \
    ${ctrlclk_m_path}/u_a_fifo_rd/src_data[*] \
  ]

  # The pointers and payload corresponding to the W channel FIFOs - these must
  # be balanced.
  compat_set_max_delay -ignore_clock_latency $shortest_period -from [get_pins \
    ${ctrlclk_m_path}/u_w_fifo_rd/u_cdc_launch_rd_ptr_gry/gen_cdc_launch_gry_*_u_flop/CK \
  ] -to [get_pins \
    ${aclk_s_path}/u_w_fifo_wr/u_sync_rd_ptr_gry/u_cdc_capt_sync_ptr_*/gen_cdc_capt_sync_*_u_sync/D \
  ]
  compat_set_max_delay -ignore_clock_latency $shortest_period -from [get_pins \
    ${aclk_s_path}/u_w_fifo_wr/u_cdc_launch_wr_ptr_gry/gen_cdc_launch_gry_*_u_flop/CK \
  ] -to [get_pins \
    ${ctrlclk_m_path}/u_w_fifo_rd/u_sync_wr_ptr_gry/u_cdc_capt_sync_ptr_*/gen_cdc_capt_sync_*_u_sync/D \
  ]
  compat_set_max_delay -ignore_clock_latency $shortest_period -through [get_pins \
    ${aclk_s_path}/u_w_fifo_wr/dst_data[*] \
  ] -through [get_pins \
    ${ctrlclk_m_path}/u_w_fifo_rd/src_data[*] \
  ]

  # The pointers and payload corresponding to the D channel FIFOs - these must
  # be balanced.
  compat_set_max_delay -ignore_clock_latency $shortest_period -from [get_pins \
    ${aclk_s_path}/u_d_fifo_rd/u_cdc_launch_rd_ptr_gry/gen_cdc_launch_gry_*_u_flop/CK \
  ] -to [get_pins \
    ${ctrlclk_m_path}/u_d_fifo_wr/u_sync_rd_ptr_gry/u_cdc_capt_sync_ptr_*/gen_cdc_capt_sync_*_u_sync/D \
  ]
  compat_set_max_delay -ignore_clock_latency $shortest_period -from [get_pins \
    ${ctrlclk_m_path}/u_d_fifo_wr/u_cdc_launch_wr_ptr_gry/gen_cdc_launch_gry_*_u_flop/CK \
  ] -to [get_pins \
    ${aclk_s_path}/u_d_fifo_rd/u_sync_wr_ptr_gry/u_cdc_capt_sync_ptr_*/gen_cdc_capt_sync_*_u_sync/D \
  ]
  compat_set_max_delay -ignore_clock_latency $shortest_period -through [get_pins \
    ${ctrlclk_m_path}/u_d_fifo_wr/dst_data[*] \
  ] -through [get_pins \
    ${aclk_s_path}/u_d_fifo_rd/src_data[*] \
  ]
}


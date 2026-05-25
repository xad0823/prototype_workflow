// *********************************************************************
//  The confidential and proprietary information contained in this file may
//  only be used by a person authorised under and to the extent permitted
//  by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//             (C) COPYRIGHT 2012-2016 ARM Limited or its affiliates.
//                 ALL RIGHTS RESERVED
//
//  This entire notice must be reproduced on all copies of this file
//  and copies of this file may only be made by a person if such person is
//  permitted to do so under the terms of a subsisting license agreement
//  from ARM Limited or its affiliates.
//
//   File Revision       :$Revision: $
//   File Date           :$Date: $
//
//   Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
// *********************************************************************

`ifndef VIP_AHB5_COVERAGE_MACROS_SVH
`define VIP_AHB5_COVERAGE_MACROS_SVH


    `ifndef VIP_AHB5_COVERGROUP_MERGE_INSTANCES
    `define VIP_AHB5_COVERGROUP_MERGE_INSTANCES 0
    `endif

    `ifndef VIP_AHB5_COVERGROUP_GET_INST_COVERAGE
    `define VIP_AHB5_COVERGROUP_GET_INST_COVERAGE 1
    `endif

    `define VIP_AHB5_COV_COVERGROUP_OPTIONS(coverage_group) \
        option.goal = 100; \
        option.weight = cov_config_.get_covergroup_enabled(coverage_group); \
        option.per_instance = 1; \


    `define VIP_AHB5_COV_COVERPOINT_OPTIONS(coverage_point) \
        option.weight = cov_config_.get_coverpoint_weighting(coverage_point); \
        option.goal = ((cov_config_.get_coverpoint_weighting(coverage_point) == 0)) ? 0 : \
                cov_config_.get_coverpoint_goal(coverage_point); \
        option.at_least = ((cov_config_.get_coverpoint_weighting(coverage_point) == 0)) ? 1 : \
                (cov_config_.get_coverpoint_at_least(coverage_point) > 0 ? \
                    cov_config_.get_coverpoint_at_least(coverage_point) : 1);

    `define VIP_AHB5_COV_WAIT_STATES_COUNTING_BINS_HELPER(bin_name, parameter, min_range, max_range) \
        bins bin_name``_``min_range``_``max_range = { \
            [(cov_config_.get_limit_parameter(parameter) > min_range) ? \
                min_range : vip_ahb5_types::INFINITE \
            :   ((cov_config_.get_limit_parameter(parameter) <= min_range) ? vip_ahb5_types::INFINITE : \
                ((cov_config_.get_limit_parameter(parameter) > max_range) ? max_range : \
                cov_config_.get_limit_parameter(parameter) - 1)) \
            ]};



    `define VIP_AHB5_COV_WAIT_STATES_COUNTING_BINS(bin_name, parameter) \
        bins bin_name``_0 = { \
            cov_config_.get_limit_parameter(parameter) > 0 ? 0 : vip_ahb5_types::INFINITE \
                }; \
        bins bin_name``_1 = { \
            cov_config_.get_limit_parameter(parameter) > 1 ? 1 : vip_ahb5_types::INFINITE \
                }; \
        `VIP_AHB5_COV_WAIT_STATES_COUNTING_BINS_HELPER(bin_name, parameter, 2, 3) \
        `VIP_AHB5_COV_WAIT_STATES_COUNTING_BINS_HELPER(bin_name, parameter, 4, 7) \
        `VIP_AHB5_COV_WAIT_STATES_COUNTING_BINS_HELPER(bin_name, parameter, 8, 15) \
         bins bin_name``_MAX [] = { \
            cov_config_.get_limit_parameter(parameter) \
                }; \
        illegal_bins illegal_``bin_name``_OVER = { \
            [cov_config_.get_limit_parameter(parameter) + 1: $] \
                };

`endif

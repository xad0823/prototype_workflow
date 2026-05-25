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

`ifndef VIP_AHB5_COVERAGE_CONFIGURATION_SVH
`define VIP_AHB5_COVERAGE_CONFIGURATION_SVH




class vip_ahb5_coverage_configuration extends uvm_object;

    `uvm_object_utils(vip_ahb5_coverage_configuration)

    protected shortint unsigned default_weighting_;

    protected shortint unsigned default_goal_;

    protected bit disabled_coverpoints_pool[vip_ahb5_types::coverpoints_t];

    protected bit disabled_covergroups_pool[vip_ahb5_types::covergroups_t];

    bit enable_user_define_weightings;

    protected shortint unsigned user_defined_coverpoint_weighting[vip_ahb5_types::coverpoints_t];

    protected shortint unsigned limit_parameter[vip_ahb5_types::cov_parameters_t];

    function new(string name = "vip_ahb5_coverage_configuration");
        super.new(name);

        set_limit_parameter(vip_ahb5_types::PARAM_SLAVE_WAIT_STATES_MIN,0);
        set_limit_parameter(vip_ahb5_types::PARAM_MASTER_BUSY_CYCLES_MIN,0);
        set_limit_parameter(vip_ahb5_types::PARAM_SLAVE_WAIT_STATES_MAX,16);
        set_limit_parameter(vip_ahb5_types::PARAM_MASTER_BUSY_CYCLES_MAX,16);

        disabled_covergroups_pool.delete();
        disabled_coverpoints_pool.delete();
        user_defined_coverpoint_weighting.delete();

        enable_user_define_weightings = 'b0;
    endfunction: new


    virtual function
    void set_disable_covergroup(vip_ahb5_types::covergroups_t covergroup_);
        if(!disabled_covergroups_pool.exists(covergroup_))
        begin
            disabled_covergroups_pool[covergroup_] = 1'b1;
        end
    endfunction : set_disable_covergroup

    virtual function
    void set_enable_covergroup(vip_ahb5_types::covergroups_t covergroup_);
        if(!disabled_covergroups_pool.exists(covergroup_))
        begin
            disabled_covergroups_pool.delete(covergroup_);
        end
    endfunction : set_enable_covergroup

    virtual function
    void set_disable_coverpoint(vip_ahb5_types::coverpoints_t coverpoint_);
        if(!disabled_coverpoints_pool.exists(coverpoint_))
        begin
            disabled_coverpoints_pool[coverpoint_] = 1'b1;
        end
    endfunction: set_disable_coverpoint

    virtual function
    int get_covergroup_enabled(vip_ahb5_types::covergroups_t covergroup_);
        if(disabled_covergroups_pool.exists(covergroup_))
        begin
            return 0;
        end
        else
        begin
            return 1;
        end
    endfunction:get_covergroup_enabled


    virtual function
    void set_enable_coverpoint(vip_ahb5_types::coverpoints_t coverpoint_);
        if(disabled_coverpoints_pool.exists(coverpoint_))
        begin
            disabled_coverpoints_pool.delete(coverpoint_);
        end
    endfunction: set_enable_coverpoint

    virtual function
    shortint unsigned get_coverpoint_weighting(vip_ahb5_types::coverpoints_t coverpoint_);
        if(disabled_coverpoints_pool.exists(coverpoint_))
        begin
            return 0;
        end else if((enable_user_define_weightings) &&(user_defined_coverpoint_weighting.exists(coverpoint_)))
        begin
            return user_defined_coverpoint_weighting[coverpoint_];
        end else begin
            return get_default_coverpoint_weighting();
        end
    endfunction : get_coverpoint_weighting

    virtual function
    shortint unsigned get_default_coverpoint_weighting();
        return 1;
    endfunction : get_default_coverpoint_weighting

    virtual function
    shortint unsigned get_coverpoint_goal(vip_ahb5_types::coverpoints_t coverpoint_);
        if(disabled_coverpoints_pool.exists(coverpoint_)
            ||(get_coverpoint_weighting(coverpoint_) == 0))
        begin
            return 0;
        end
        else
        begin
            return get_default_coverpoint_goal();
        end
    endfunction : get_coverpoint_goal

    virtual function
    shortint unsigned get_default_coverpoint_goal();
        return 100;
    endfunction : get_default_coverpoint_goal

    virtual function
    shortint unsigned get_coverpoint_at_least(vip_ahb5_types::coverpoints_t coverpoint_);
        if(disabled_coverpoints_pool.exists(coverpoint_)
            ||(get_coverpoint_weighting(coverpoint_) == 0))
        begin
            return 0;
        end
        else
        begin
            return get_default_coverpoint_at_least();
        end

    endfunction : get_coverpoint_at_least

    virtual function
    shortint unsigned get_default_coverpoint_at_least();
        return 1;
    endfunction : get_default_coverpoint_at_least

    virtual function
    shortint unsigned get_limit_parameter(vip_ahb5_types::cov_parameters_t param_);
        return limit_parameter[param_];
    endfunction : get_limit_parameter

    virtual function
    void set_limit_parameter(vip_ahb5_types::cov_parameters_t param_,int unsigned value);
        limit_parameter[param_] = value;
    endfunction :set_limit_parameter



endclass : vip_ahb5_coverage_configuration

`endif



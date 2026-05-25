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

`ifndef VIP_AHB5_TRANSACTION_COVERAGE_SVH
`define VIP_AHB5_TRANSACTION_COVERAGE_SVH



class vip_ahb5_transaction_coverage extends vip_ahb5_transaction_coverage_base;

    covergroup transaction_cov(string name_);

       `VIP_AHB5_COV_COVERGROUP_OPTIONS(vip_ahb5_types::CG_TRANSACTION_COV)
        option.comment = "Covers payload for an ahb_lite transaction";
        option.name = name_;

        burst_type : coverpoint transaction.burst_type
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANSACTION_COV_BURST)

            option.comment = "Covers HBURST field of transaction";

            bins SINGLE  = {vip_ahb5_types::BURST_SINGLE};
            bins INCR    = {vip_ahb5_types::BURST_INCR};
            bins WRAP4   = {vip_ahb5_types::BURST_WRAP4};
            bins INCR4   = {vip_ahb5_types::BURST_INCR4};
            bins WRAP8   = {vip_ahb5_types::BURST_WRAP8};
            bins INCR8   = {vip_ahb5_types::BURST_INCR8};
            bins WRAP16  = {vip_ahb5_types::BURST_WRAP16};
            bins INCR16  = {vip_ahb5_types::BURST_INCR16};
        }

        request_type : coverpoint transaction.request_type
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANSACTION_COV_REQUEST)

            option.comment = "Covers HWRITE field of transaction for read/write transfers";

            bins READ  = {vip_ahb5_types::REQUEST_READ};
            bins WRITE = {vip_ahb5_types::REQUEST_WRITE};
        }

        transfer_size : coverpoint transaction.transfer_size
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANSACTION_COV_TRANSFER_SIZE)

            option.comment = "Covers HSIZE field of transaction";

            bins HSIZE[] = {[0:vip_ahb5_types::size_t'(cov_config_.get_limit_parameter(vip_ahb5_types::PARAM_HSIZE_MAX))]};
        }

        access_type : coverpoint transaction.locked_access
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANSACTION_COV_ACCESS)

            option.comment = "Covers HMASLOCK field of transaction";
            bins NORMAL = {vip_ahb5_types::ACCESS_NORMAL};
            bins LOCKED = {vip_ahb5_types::ACCESS_LOCKED};
        }

        protection_control : coverpoint transaction.protection
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANSACTION_COV_PROTECTION_CONTROL)

            option.comment = "Covers HPROT field of transaction";

            wildcard bins OPCODE_FETCH   = {7'b???0};
            wildcard bins DATA_ACCESS    = {7'b???1};
            wildcard bins USER_ACCESS    = {7'b??0?};
            wildcard bins PRIV_ACCESS    = {7'b??1?};
            bins MEMORY_TYPE[] = { [vip_ahb5_types::MEMORY_V8_DEVICE_nE : vip_ahb5_types::MEMORY_V8_WB_A_S] };
        }

        secure_transfer : coverpoint transaction.secure_transfer
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANSACTION_COV_SECURE_TRANSFER)

            option.comment = "Covers HNONSEC field of transaction";

            bins SECURE    = {vip_ahb5_types::ACCESS_ATTR_SECURE};
            bins NONSECURE = {vip_ahb5_types::ACCESS_ATTR_NONSECURE};
        }

        exclusive_transfer : coverpoint transaction.exclusive_transfer
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANSACTION_COV_EXCLUSIVE_TRANSFER)

            option.comment = "Covers EXOKAY field of transaction";

            bins EXCLUSIVE_TRANSFER     = {vip_ahb5_types::TRANS_ATTR_EXCL};
            bins NON_EXCLUSIVE_TRANSFER = {vip_ahb5_types::TRANS_ATTR_NONEXCL};
        }

        exclusive_response : coverpoint transaction.exclusive_response
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANSACTION_COV_EXCLUSIVE_RESPONSE)

            option.comment = "Covers EXOKAY field of transaction";

            bins EXCL_OKAY = {vip_ahb5_types::EXCL_OKAY};
            bins EXCL_FAIL = {vip_ahb5_types::EXCL_FAIL};
        }

        transaction_response :  coverpoint transaction.transaction_response
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANSACTION_COV_TRANS_RESPONSE)

            option.comment = "Covers HRESP field of transaction computed over complete burst";
            bins OKAY  = {vip_ahb5_types::RESP_OKAY};
            bins ERROR = {vip_ahb5_types::RESP_ERROR};
        }

        early_burst_termination : coverpoint transaction.transaction_terminated
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANSACTION_COV_EARLY_BURST_TERMINATION)

            option.comment = "Covers early burst termination by master in case of error response";
            bins BURST_TERMINATED  = {1'b1};
        }

        hnonsec_x_burst_x_request : cross secure_transfer,burst_type, request_type
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANSACTION_COV_HNONSEC_X_BURST_X_REQUEST)

            option.comment = "Covers various Secure and Non-Secure burst types with read/write requests";
        }

        excl_transfer_x_request_x_excl_resp : cross exclusive_transfer,request_type,exclusive_response
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANSACTION_COV_EXCL_TRANS_X_REQUEST_X_EXCL_RESP)

            option.comment = "Covers various Exclsuive read/write with EXCL_OKAY/EXCL_FAIL response";
        }

        burst_x_protection : cross burst_type, protection_control
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANSACTION_COV_BURST_X_HPROT)

            option.comment = "Covers various burst types with all protection encodings";
        }

        burst_x_request : cross burst_type,request_type
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANSACTION_COV_BURST_X_REQUEST)

            option.comment = "Covers various burst types with request";
        }

        burst_x_size : cross burst_type, transfer_size
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANSACTION_COV_BURST_X_TRANSFER_SIZE)

            option.comment = "Covers various bursts with all permissible sizes";
        }

        burst_x_response : cross burst_type, transaction_response
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANSACTION_COV_BURST_X_TRANS_RESPONSE)

            option.comment = "Covers various bursts with okay/error response";
        }

        burst_x_access : cross burst_type, access_type
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANSACTION_COV_BURST_X_ACCESS)

            option.comment = "Covers various bursts with locked/normal access";
        }

        request_x_size : cross request_type, transfer_size
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANSACTION_COV_REQUEST_X_TRANSFER_SIZE)

            option.comment = "Covers read/write requests with all permissible transfer sizes";
        }

        request_x_response : cross request_type, transaction_response
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANSACTION_COV_REQUEST_X_TRANS_RESPONSE)

            option.comment = "Covers read/write requests with okay/error responses";
        }

        request_x_access : cross request_type, access_type
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANSACTION_COV_REQUEST_X_ACCESS)

            option.comment = "Covers read/write requests with normal/locked accesses";
        }

        hnonsec_x_request_x_protection :  cross secure_transfer,request_type, protection_control
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANSACTION_COV_HNONSEC_X_REQUEST_X_PROTECTION_CONTROL)

            option.comment = "Covers Secure/Non-secure read/write requests with all protection encodings";
        }

    endgroup

    covergroup trans_delay_cov(string name_) with function sample(bit[4:0] mstr_delay,bit[4:0] slv_delay);
        option.comment = "Covers busy cycles inserted by the master and slave wait states";
        option.name = name_;
       `VIP_AHB5_COV_COVERGROUP_OPTIONS(vip_ahb5_types::CG_TRANS_DELAY_COV)

        busy_cycles : coverpoint mstr_delay
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANS_DELAY_COV_BUSY_CYCLES)
             option.comment = "Counts number of busy cycles inserted by master";
            `VIP_AHB5_COV_WAIT_STATES_COUNTING_BINS(NUM_BUSY_CYCLES, vip_ahb5_types::PARAM_MASTER_BUSY_CYCLES_MAX)
        }

        wait_states : coverpoint slv_delay
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANS_DELAY_COV_BUSY_CYCLES)
             option.comment = "Counts number of wait states inserted by slave";
            `VIP_AHB5_COV_WAIT_STATES_COUNTING_BINS(NUM_WAIT_STATES,vip_ahb5_types::PARAM_SLAVE_WAIT_STATES_MAX)
        }
    endgroup

    function new(string name_ = "vip_ahb5_transaction_coverage",vip_ahb5_coverage_configuration cov_config);
        super.new(name_);

        this.cov_config_ = cov_config;

        if(cov_config_.get_covergroup_enabled(vip_ahb5_types::CG_TRANSACTION_COV) != 0)
        begin
            transaction_cov = new({name_,"[transaction]"});
        end

        if(cov_config_.get_covergroup_enabled(vip_ahb5_types::CG_TRANS_DELAY_COV) != 0)
        begin
            trans_delay_cov = new({name_,"[delay_cycles]"});
        end
    endfunction : new


    virtual function void update(vip_ahb5_transaction trans_);
        super.update(trans_);
        if(transaction_cov != null)
        begin
            transaction_cov.sample();
        end

        if(trans_delay_cov != null)
        begin
            foreach(transaction.master_wait_states[i])
            begin
                trans_delay_cov.sample(transaction.master_wait_states[i],transaction.slave_wait_states[i]);
            end
        end

    endfunction : update

endclass: vip_ahb5_transaction_coverage

`endif


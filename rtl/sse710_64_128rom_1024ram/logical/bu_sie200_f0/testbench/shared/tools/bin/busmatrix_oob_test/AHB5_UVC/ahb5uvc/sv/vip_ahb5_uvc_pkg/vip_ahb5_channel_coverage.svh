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

`ifndef VIP_AHB5_CHANNEL_COVERAGE_SVH
`define VIP_AHB5_CHANNEL_COVERAGE_SVH



class vip_ahb5_channel_coverage extends vip_ahb5_channel_coverage_base;

    covergroup trans_sequence_cov(string name_);

        option.comment = "Covers individual beats of an AHB transfer";
        option.name = name_;
       `VIP_AHB5_COV_COVERGROUP_OPTIONS(vip_ahb5_types::CG_TRANS_SEQ_COV)

        transfer : coverpoint transfer.req_beat.Transfer
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANS_SEQ_TRANSFER)

            option.comment = "Covers HTRANS field of transaction";

            bins IDLE    = {vip_ahb5_types::TRANSFER_IDLE};
            bins BUSY    = {vip_ahb5_types::TRANSFER_BUSY};
            bins NON_SEQ = {vip_ahb5_types::TRANSFER_NONSEQ};
            bins SEQ     = {vip_ahb5_types::TRANSFER_SEQ};
        }

        response : coverpoint transfer.resp_beat.Response
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANS_SEQ_RESPONSE)

            option.comment = "Covers HRESP field of transaction";
            bins OKAY  = {vip_ahb5_types::RESP_OKAY};
            bins ERROR = {vip_ahb5_types::RESP_ERROR};
        }

        response_state : coverpoint transfer.resp_beat.State
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANS_SEQ_RESPONSE_STATE)

            option.comment = "Covers all transitions in HREADYOUT-HRESP field of transaction";

            bins SUCCESS  = {vip_ahb5_types::TRANS_PENDING};
            bins PENDING  = {vip_ahb5_types::TRANS_SUCCESS};
            bins ERROR_I  = {vip_ahb5_types::ERROR_RESP_1ST_CYCLE};
            bins ERROR_II = {vip_ahb5_types::ERROR_RESP_2ND_CYCLE};
        }


        transfer_transition : coverpoint transfer.req_beat.Transfer
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANS_SEQ_TRANSFER_TRANSITION)

            option.comment = "Covers transition of HTRANS field of transaction";

            bins NONSEQ_NONSEQ = (vip_ahb5_types::TRANSFER_NONSEQ => vip_ahb5_types::TRANSFER_NONSEQ);
            bins NONSEQ_SEQ    = (vip_ahb5_types::TRANSFER_NONSEQ => vip_ahb5_types::TRANSFER_SEQ);
            bins NONSEQ_BUSY   = (vip_ahb5_types::TRANSFER_NONSEQ => vip_ahb5_types::TRANSFER_BUSY);
            bins NONSEQ_IDLE   = (vip_ahb5_types::TRANSFER_NONSEQ => vip_ahb5_types::TRANSFER_IDLE);
            bins SEQ_SEQ       = (vip_ahb5_types::TRANSFER_SEQ => vip_ahb5_types::TRANSFER_SEQ);
            bins SEQ_BUSY      = (vip_ahb5_types::TRANSFER_SEQ => vip_ahb5_types::TRANSFER_BUSY);
            bins SEQ_IDLE      = (vip_ahb5_types::TRANSFER_SEQ => vip_ahb5_types::TRANSFER_IDLE);
            bins BUSY_NONSEQ   = (vip_ahb5_types::TRANSFER_BUSY => vip_ahb5_types::TRANSFER_NONSEQ);
            bins BUSY_SEQ      = (vip_ahb5_types::TRANSFER_BUSY => vip_ahb5_types::TRANSFER_SEQ);
            bins BUSY_BUSY     = (vip_ahb5_types::TRANSFER_BUSY => vip_ahb5_types::TRANSFER_BUSY);
            bins BUSY_IDLE     = (vip_ahb5_types::TRANSFER_BUSY => vip_ahb5_types::TRANSFER_IDLE);
            bins IDLE_NONSEQ   = (vip_ahb5_types::TRANSFER_IDLE => vip_ahb5_types::TRANSFER_NONSEQ);
            bins IDLE_IDLE     = (vip_ahb5_types::TRANSFER_IDLE => vip_ahb5_types::TRANSFER_IDLE);
        }

        response_transition : coverpoint transfer.resp_beat.State
        {
            `VIP_AHB5_COV_COVERPOINT_OPTIONS(vip_ahb5_types::CP_TRANS_SEQ_RESPONSE_TRANSITION)

            option.comment = "Covers all state transition of response";

            bins OKAY_OKAY   = (vip_ahb5_types::TRANS_SUCCESS => vip_ahb5_types::TRANS_SUCCESS);
            bins OKAY_WAIT   = (vip_ahb5_types::TRANS_SUCCESS => vip_ahb5_types::TRANS_PENDING);
            bins OKAY_ERROR  = (vip_ahb5_types::TRANS_SUCCESS => vip_ahb5_types::ERROR_RESP_1ST_CYCLE);
            bins WAIT_OKAY   = (vip_ahb5_types::TRANS_PENDING => vip_ahb5_types::TRANS_SUCCESS);
            bins WAIT_WAIT   = (vip_ahb5_types::TRANS_PENDING => vip_ahb5_types::TRANS_PENDING);
            bins WAIT_ERROR  = (vip_ahb5_types::TRANS_PENDING => vip_ahb5_types::ERROR_RESP_1ST_CYCLE);
            bins ERROR_OKAY  = (vip_ahb5_types::ERROR_RESP_2ND_CYCLE => vip_ahb5_types::TRANS_SUCCESS);
            bins ERROR_WAIT  = (vip_ahb5_types::ERROR_RESP_2ND_CYCLE => vip_ahb5_types::TRANS_PENDING);
            bins ERROR_ERROR = (vip_ahb5_types::ERROR_RESP_2ND_CYCLE => vip_ahb5_types::ERROR_RESP_1ST_CYCLE);

        }

    endgroup :trans_sequence_cov


    function new(string name_ = "vip_ahb5_channel_coverage",vip_ahb5_coverage_configuration cov_config);
        super.new(name_);

        this.cov_config_ = cov_config;
        if(cov_config_.get_covergroup_enabled(vip_ahb5_types::CG_TRANS_SEQ_COV) != 0)
        begin
            trans_sequence_cov = new({name_,"[transfer_sequence]"});
        end
    endfunction : new


    virtual function void update(vip_ahb5_channel_cov_item trans_);
        super.update(trans_);
        if(trans_sequence_cov != null)
        begin
            trans_sequence_cov.sample();
        end
    endfunction : update

endclass: vip_ahb5_channel_coverage

`endif


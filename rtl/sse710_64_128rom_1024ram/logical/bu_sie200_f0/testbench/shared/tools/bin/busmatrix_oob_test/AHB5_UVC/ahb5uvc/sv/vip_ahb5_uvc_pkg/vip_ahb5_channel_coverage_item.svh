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

`ifndef VIP_AHB5_CHANNEL_COVERAGE_ITEM_SVH
`define VIP_AHB5_CHANNEL_COVERAGE_ITEM_SVH


class vip_ahb5_channel_cov_item extends uvm_sequence_item;
    `uvm_object_utils(vip_ahb5_channel_cov_item)

    vip_ahb5_types::request_beat_struct_t req_beat;

    vip_ahb5_types::response_beat_struct_t resp_beat;

    bit[7:0] rd_data[];

    bit[7:0] wr_data[];

    vip_ahb5_types::hdatauser_t data_user;

    bit reset;

    function new(string name_ = "vip_ahb5_channel_cov_item");
        super.new(name_);
    endfunction: new

    function void do_copy(uvm_object rhs);
        vip_ahb5_channel_cov_item source;
        if(!$cast(source,rhs)) begin
            `vip_ahb5_fatal(("Type mismatch in do_copy"))
        end

        super.do_copy(rhs);

        req_beat  = source.req_beat;
        resp_beat = source.resp_beat;
        rd_data   = source.rd_data;
        wr_data   = source.wr_data;
    endfunction: do_copy


    function string get_data_string(bit[7:0] data_[]);
        string data_str_;
        foreach(data_[i]) begin
            data_str_ = {$sformatf("%2h",data_[i]),data_str_};
        end
        data_str_ = {"0x",data_str_};
        return data_str_;
    endfunction : get_data_string

    virtual function void do_print(uvm_printer printer);
        printer.knobs.type_name = 0;
        printer.knobs.size = 0;

        printer.print_string("Request",$sformatf("%s",vip_ahb5_types::request_t'(req_beat.Direction)));
        printer.print_string("Burst",$sformatf("%s",vip_ahb5_types::burst_t'(req_beat.Burst)));
        printer.print_string("Size",$sformatf("%s",vip_ahb5_types::size_t'(req_beat.Size)));
        printer.print_string("Transfer",$sformatf("%s",vip_ahb5_types::transfer_t'(req_beat.Transfer)));
        printer.print_string("Address",$sformatf("0x%h",vip_ahb5_types::address_t'(req_beat.Address)));
        printer.print_string("Read data", get_data_string(rd_data));
        printer.print_string("Write data", get_data_string(wr_data));
        printer.print_string("Response",$sformatf("%s",vip_ahb5_types::response_t'(resp_beat.Response)));
        printer.print_string("Exclusive",$sformatf("%s",vip_ahb5_types::trans_attr_t'(req_beat.Exclusive)));
        printer.print_string("ExclResponse",$sformatf("%s",vip_ahb5_types::excl_response_t'(resp_beat.ExclResponse)));

    endfunction: do_print


endclass: vip_ahb5_channel_cov_item


`endif

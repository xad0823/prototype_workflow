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

`ifndef VIP_AHB5_SLAVE_BASE_RESPONSE_SEQUENCE_SVH
`define VIP_AHB5_SLAVE_BASE_RESPONSE_SEQUENCE_SVH


class vip_ahb5_slave_base_response_sequence extends uvm_sequence#(vip_ahb5_transaction);

    `uvm_object_utils(vip_ahb5_slave_base_response_sequence)

    vip_ahb5_transaction transaction_;

    vip_ahb5_memory_model memory_model;

    vip_ahb5_types::address_t addr_q[$];

    bit[63:0] address;

    function new(string name = "vip_ahb5_slave_base_response_sequence");
        super.new(name);
    endfunction : new

    function void initialize(vip_ahb5_transaction tr,
                        vip_ahb5_memory_model mem_model,
                        vip_ahb5_types::address_t addr[$],
                        uvm_phase starting_phase);
        this.transaction_ = tr;
        this.memory_model = mem_model;
        this.addr_q       = addr;
        this.starting_phase = starting_phase;
        if(transaction_ == null || memory_model == null || addr_q.size() == 0) begin
            `uvm_fatal(get_name(),$sformatf("either one of transaction_|memory_model|addr_q is null"))
        end
    endfunction : initialize

    virtual function void read_from_memory(vip_ahb5_transaction transaction_);
        int unsigned index_;
        bit[7:0] rd_data[];
        bit [7:0]mem_data[];
        bit error_;

        for(int i =0; i< transaction_.burst_length; ++i) begin
            address = addr_q.pop_front();
            mem_data = new[(1<<transaction_.transfer_size)];
            rd_data = new[transaction_.data_byte_width];
            index_ = 0;
            memory_model.read_data(address, transaction_.secure_transfer, mem_data, error_);
            transaction_.data.data.push_back(mem_data);
            transaction_.resp[i] = vip_ahb5_types::response_t'(error_);
        end

    endfunction : read_from_memory

    virtual function
    void generate_user_data(vip_ahb5_transaction transaction_);
        vip_ahb5_types::user_mode_t user_gen_mode;
        vip_ahb5_types::hdatauser_t data_user;
        vip_ahb5_control_knobs control_knobs;

        control_knobs = transaction_.get_control_knobs();
        if (control_knobs == null)
        begin
            user_gen_mode = vip_ahb5_types::USER_ZERO;
        end
        else
        begin
            user_gen_mode = control_knobs.get_user_generation_mode();
        end
        transaction_.data.user.delete();
        for (int i = 0; i < transaction_.burst_length; i++)
        begin
            case(user_gen_mode)
                vip_ahb5_types::USER_ZERO :
                begin
                    data_user = 0;
                end
                vip_ahb5_types::USER_RANDOM:
                begin
                    bit result = std::randomize(data_user);
                    if (!result)
                    begin
                        `vip_ahb5_error(("Failed to randomize user data in response sequence"))
                    end
                end
            endcase

            transaction_.data.user.push_back(data_user);
        end
    endfunction : generate_user_data


    virtual function void write_into_memory(vip_ahb5_transaction transaction_);

        foreach(transaction_.data.data[i]) begin
            transaction_.get_valid_byte_lanes(transaction_.request_beats[i].Address);
            memory_model.write_data(transaction_.request_beats[i].Address,
                                    transaction_.secure_transfer,
                                    transaction_.valid_byte_strobes,
                                    transaction_.data.data[i],
                                    transaction_.response_beats[i].Response);
        end
        transaction_.data.data.delete();
    endfunction : write_into_memory

    task put_item();
        starting_phase.raise_objection(this, "UVC Responder Incoming Transaction");
        start_item(transaction_);
        finish_item(transaction_);
        starting_phase.drop_objection(this, "UVC Responder Idle");
    endtask :put_item


    virtual task body();
        vip_ahb5_transaction resp;

        if(memory_model != null) begin
            if(transaction_ != null && addr_q.size() != 0) begin
                memory_model.set_byte_length((1<<transaction_.transfer_size));
                transaction_.data.data.delete();
                if(transaction_.request_type == vip_ahb5_types::REQUEST_READ) begin
                    read_from_memory(transaction_);
                    generate_user_data(transaction_);
                end
                put_item();
                get_response(resp);
                if(transaction_.request_type == vip_ahb5_types::REQUEST_WRITE) begin
                    write_into_memory(resp);
                end
            end
            else begin
                `uvm_fatal(get_name(),$sformatf("Transaction in vip_ahb5_slave_base_response_sequence is null"))
            end
        end
    endtask : body

endclass : vip_ahb5_slave_base_response_sequence

`endif

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

`ifndef VIP_AHB5_TRANSACTION_LAYER_SVH
`define VIP_AHB5_TRANSACTION_LAYER_SVH



class vip_ahb5_transaction_layer extends uvm_component;

    `uvm_component_utils(vip_ahb5_transaction_layer)

    local vip_ahb5_exclusive_monitor exclusive_monitor;

    vip_ahb5_configuration configuration;


    local vip_ahb5_types::transfer_t transfer[$];

    local vip_ahb5_types::address_t address_q[$];

    local vip_ahb5_types::response_t resp[$];

    local vip_ahb5_types::data_queue_t data;

    local vip_ahb5_types::request_beat_struct_t transfer_beat;


    const bit[10:0] boundary_1k = 11'h400;

    local int unsigned transaction_size;

    local bit wrapping_burst;

    local int unsigned data_byte_width;

    protected vip_ahb5_types::excl_response_t exclusive_response;

    function new(string name = "vip_ahb5_transaction_layer", uvm_component parent);
        super.new(name,parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(vip_ahb5_configuration)::get(this,"","configuration",configuration))
        begin
            `vip_ahb5_fatal(("Configuration object not set."))
        end

        if((configuration.get_support_exclusives())&&
           (configuration.get_node_type() == vip_ahb5_types::SLAVE_NODE))
        begin
            exclusive_monitor = vip_ahb5_exclusive_monitor::type_id::create("ahb5_exclusive_monitor");
        end
    endfunction: build_phase

    function void check_address_alignment(vip_ahb5_transaction transaction_);
        bit[63:0] address_mask;
        address_mask = 64'hFFFFFFFFFFFFFFFF;
        address_mask <<= (transaction_.transfer_size);
        if(transaction_.address !== (transaction_.address& address_mask))
        begin
            `vip_ahb5_warning(("Unaligned start address, regenerating aligned address"))
            transaction_.address &= address_mask;
        end
        else
        begin
            `vip_ahb5_info(("Start address = %h",transaction_.address),UVM_FULL)
        end
    endfunction: check_address_alignment

    function void check_boundary_crossing(vip_ahb5_transaction transaction_);
        bit burst_length_changed = 0;
        if(!wrapping_burst)
        begin
            if(get_transaction_size(transaction_) > boundary_1k)
            begin
               `vip_ahb5_warning(("Burst crossing 1K boundary, reducing the transaction size"))
                do
                begin
                    case(transaction_.burst_type)
                        vip_ahb5_types::BURST_INCR:
                        begin
                            transaction_.burst_length = transaction_.burst_length/2;
                            burst_length_changed = 1;
                        end
                        vip_ahb5_types::BURST_INCR4:
                        begin
                            transaction_.burst_length = transaction_.burst_length/2;
                            transaction_.burst_type = vip_ahb5_types::BURST_INCR;
                            burst_length_changed = 1;
                        end
                        vip_ahb5_types::BURST_INCR8:
                        begin
                            transaction_.burst_length = transaction_.burst_length/2;
                            transaction_.burst_type = vip_ahb5_types::BURST_INCR4;
                            burst_length_changed = 1;
                        end
                        vip_ahb5_types::BURST_INCR16:
                        begin
                            transaction_.burst_length = transaction_.burst_length/2;
                            transaction_.burst_type = vip_ahb5_types::BURST_INCR8;
                            burst_length_changed = 1;
                        end
                    endcase
                end
                while(get_transaction_size(transaction_) > boundary_1k);
            end
        end
        if (burst_length_changed)
        begin
            transaction_.data.data = transaction_.data.data[0:transaction_.burst_length-1];
            transaction_.data.user = transaction_.data.user[0:transaction_.burst_length-1];
        end

        if((!wrapping_burst)&&((boundary_1k-transaction_size)<transaction_.address[9:0]))
        begin
            `vip_ahb5_warning(("Burst crossing 1K boundary, regenerating start address"))
            transaction_.address[9:0] = boundary_1k-transaction_size;
            check_address_alignment(transaction_);
        end
    endfunction: check_boundary_crossing


    function vip_ahb5_types::address_t get_next_address(vip_ahb5_types::address_t current_address_,vip_ahb5_transaction transaction_);
         vip_ahb5_types::address_t wrap_boundary_;
         vip_ahb5_types::address_t next_address_;
         wrap_boundary_    = (transaction_.address / transaction_size)*transaction_size ;

         next_address_ = current_address_ + data_byte_width;
         if(wrapping_burst)
         begin
             if(next_address_  >= (wrap_boundary_ + transaction_size))
             begin
                 next_address_ = next_address_ - transaction_size ;
             end
         end

         return next_address_ ;
    endfunction: get_next_address

    function void create_address_queue(vip_ahb5_transaction transaction_);
        vip_ahb5_types::address_t current_address;
        vip_ahb5_types::address_t next_address;
        vip_ahb5_types::transfer_t current_transfer;
        vip_ahb5_types::transfer_t previous_transfer;
        vip_ahb5_types::address_range_struct_t addr_range;

        if(configuration.sam != null) begin
            if(transaction_.calc_address_on_slave_id) begin
                `vip_ahb5_info(("calc_address_on_slave_id is set. Updating Address based on Slave_id('d%0d)",transaction_.slave_select),UVM_LOW)
                addr_range = configuration.sam.get_address_range(transaction_.slave_select);
                transaction_.set_address(addr_range.start_address);
            end
        end
        if(!transaction_.is_bypass_address_alignment())
        begin
            check_address_alignment(transaction_);
        end
        check_boundary_crossing(transaction_);

        foreach(transfer[i])
        begin
            current_transfer = transfer[i];
            case(transfer[i])

                vip_ahb5_types::TRANSFER_NONSEQ:
                begin
                    if(i !== 0)
                    begin
                        `vip_ahb5_fatal(("NONSEQ should be first transfer,Transfer queue generation failed."))
                    end
                    else
                    begin
                        current_address = transaction_.address;
                        address_q.push_back(current_address);
                    end
                end

                vip_ahb5_types::TRANSFER_SEQ:
                begin
                    if(previous_transfer !== vip_ahb5_types::TRANSFER_BUSY)
                    begin
                        next_address = get_next_address(current_address,transaction_);
                        address_q.push_back(next_address);
                        current_address = next_address;
                    end
                    else
                    begin
                        address_q.push_back(current_address);
                    end
                end

                vip_ahb5_types::TRANSFER_BUSY:
                begin
                    if(previous_transfer !== vip_ahb5_types::TRANSFER_BUSY)
                    begin
                        next_address = get_next_address(current_address,transaction_);
                        address_q.push_back(next_address);
                        current_address = next_address;
                    end
                    else
                    begin
                        address_q.push_back(current_address);
                    end
                end
                default:
                begin
                    address_q.push_back(current_address);
                end

            endcase
            previous_transfer = current_transfer;
        end
    endfunction: create_address_queue



    function void create_transfer_queue(vip_ahb5_transaction transaction_);
        int unsigned pos;
        transfer.push_back(vip_ahb5_types::TRANSFER_NONSEQ);
        for(int i=1;i < transaction_.get_burst_length();++i)
        begin
            repeat(transaction_.master_wait_states[i-1])
            begin
                transfer.push_back(vip_ahb5_types::TRANSFER_BUSY);
            end
            transfer.push_back(vip_ahb5_types::TRANSFER_SEQ);
        end

        if((transaction_.get_terminate_incr_with_busy())
            &&(transaction_.burst_type == vip_ahb5_types::BURST_INCR))
            begin
                pos = 0;
                for(int i =0;i< transfer.size();++i)
                begin
                    if(transfer[i] != vip_ahb5_types::TRANSFER_BUSY)
                    begin
                        ++pos;
                    end
                    else
                    begin
                        break;
                    end
                end
                transfer = transfer[0:pos];
        end
        if((transaction_.locked_access == vip_ahb5_types::ACCESS_LOCKED))
        begin
            transfer.push_back(vip_ahb5_types::TRANSFER_IDLE);
        end
        if(transaction_.get_insert_idle_at_end() != 0)
        begin
            for(int i = 0; i< transaction_.get_insert_idle_at_end();++i)
            begin
                transfer.push_back(vip_ahb5_types::TRANSFER_IDLE);
            end
        end

    endfunction: create_transfer_queue

    protected function void create_request_queue(vip_ahb5_transaction transaction_);
        transfer_beat.Address   = address_q.pop_front();
        transfer_beat.Burst     = transaction_.burst_type;
        transfer_beat.Transfer  = transfer.pop_front();
        transfer_beat.Size      = transaction_.transfer_size;
        transfer_beat.Select    = transaction_.slave_select;
        transfer_beat.Lock      = transaction_.locked_access;
        transfer_beat.Direction = transaction_.request_type;
        transfer_beat.AUser     = transaction_.a_user.pop_front();
        if(configuration.sam != null) begin
            if(transaction_.calc_slave_id_on_address == 1) begin
                if(configuration.sam.get_slave_id(transaction_.address, transaction_.secure_transfer) != -1) begin
                    transfer_beat.Select = configuration.sam.get_slave_id(transaction_.address, transaction_.secure_transfer);
                    transaction_.protection[6:2] = configuration.sam.get_memory_type(transaction_.address, transaction_.secure_transfer);
                    `uvm_info(get_name(),$sformatf("cal_slave_id_on_address is set. Slave Select : %0d based on address('h%0h)",transfer_beat.Select,transaction_.address),UVM_LOW)
                end
            end
        end
        transaction_.protection[1:0] = transaction_.access_attribute;
        transfer_beat.Prot      = transaction_.protection;
        transfer_beat.Secure    = transaction_.secure_transfer;
        if(configuration.support_exclusives)
            transfer_beat.Exclusive = transaction_.exclusive_transfer;
        else
            transfer_beat.Exclusive = vip_ahb5_types::TRANS_ATTR_NONEXCL;
        transfer_beat.MasterId  = transaction_.exclusive_master_id;

        transaction_.request_beats.push_back(transfer_beat);

        foreach(address_q[i])
        begin
            transfer_beat.Address = address_q[i];
            transfer_beat.Transfer = transfer[i];
            if(transfer[i] == vip_ahb5_types::TRANSFER_IDLE)
            begin
                transfer_beat.Lock = vip_ahb5_types::ACCESS_NORMAL;
                transfer_beat.Exclusive = vip_ahb5_types::TRANS_ATTR_NONEXCL;
                transfer_beat.Secure = vip_ahb5_types::ACCESS_ATTR_SECURE;
            end
            transaction_.request_beats.push_back(transfer_beat);
        end
    endfunction: create_request_queue

    protected function void update_outgoing_data(vip_ahb5_transaction transaction_,
                                              vip_ahb5_types::address_t addr_q_[$]);
        vip_ahb5_types::address_t new_address;
        vip_ahb5_types::address_t prev_address;
        int unsigned len_;
        bit[7:0] data_[];
        bit[7:0] sorted_data_[];

        if(transaction_.data.data.size() != transaction_.get_burst_length())
        begin
            `vip_ahb5_fatal(("Received data queue size 'd%0d exceeding burst length 'd%0d",transaction_.data.data.size(),transaction_.get_burst_length()))
        end


        len_ = 0;
        new_address = addr_q_.pop_front();
        prev_address = ~new_address;

        while(len_ != transaction_.get_burst_length())
        begin
            if(new_address != prev_address)
            begin
                transaction_.get_endianed_data_lanes(new_address);
                data_ = transaction_.data.data.pop_front();
                sorted_data_ = new[data_.size()];
                foreach(transaction_.valid_byte_strobes[i])
                begin
                    if(transaction_.valid_byte_strobes[i] == 1'b1)
                    begin
                        sorted_data_[i] = data_[transaction_.valid_data_index[i]];
                    end
                    else begin
                        sorted_data_[i] = 8'h00;
                    end
                end
                transaction_.data.data.push_back(sorted_data_);
                data_.delete();
                ++len_;
            end
            prev_address = new_address;
            new_address = addr_q_.pop_front();
        end

    endfunction: update_outgoing_data

    function void update_incoming_data(vip_ahb5_transaction transaction_);
        vip_ahb5_types::address_t new_address;
        int unsigned len_;
        bit[7:0] data_[];
        bit[7:0] sorted_data_[];

        len_ = 0;

        while(len_ != transaction_.get_burst_length())
        begin
            new_address = transaction_.request_beats[len_].Address;
            transaction_.get_endianed_data_lanes(new_address);
            data_ = transaction_.data.data.pop_front();

            if(configuration.get_endianness() == vip_ahb5_types::ENDIAN_BE8)
            begin
                transaction_.convert_be8_to_little_endian(new_address,data_,sorted_data_);
            end
            else if(configuration.get_endianness() == vip_ahb5_types::ENDIAN_BE32) begin
                transaction_.convert_be32_to_little_endian(new_address,data_,sorted_data_);
            end else begin
                transaction_.convert_to_little_endian(new_address,data_,sorted_data_);
            end
            transaction_.data.data.push_back(sorted_data_);
            data_.delete();
            ++len_;
        end
    endfunction: update_incoming_data

    task create_request(vip_ahb5_transaction transaction);

        transaction.request_beats.delete();
        transaction.response_beats.delete();

        set_transaction_item(transaction);
        create_transfer_queue(transaction);
        create_address_queue(transaction);
        if(transaction.request_type == vip_ahb5_types::REQUEST_WRITE)
        begin
            if(address_q.size() == 0)
            begin
                `vip_ahb5_fatal(("Zero length address queue for the write data"))
            end
            update_outgoing_data(transaction,address_q);
        end
        else begin
            transaction.data.data.delete();
        end
        create_request_queue(transaction);

    endtask: create_request



    task create_responses(vip_ahb5_transaction transaction);
        vip_ahb5_types::response_beat_struct_t resp_beat;
        vip_ahb5_types::address_t addr_q[$];
        transaction.response_beats.delete();

        set_transaction_item(transaction);

        if(transaction.request_type == vip_ahb5_types::REQUEST_READ)
        begin
            addr_q = transaction.address_beats;
            if(addr_q.size() == 0)
            begin
                `vip_ahb5_fatal(("Zero length address queue for the read data"))
            end
            update_outgoing_data(transaction,addr_q);
        end

        if(exclusive_monitor != null)
        begin
            if(is_exclusive_transaction(transaction))
            begin
                if(is_write_transaction(transaction))
                begin
                    set_exclusive_response(exclusive_monitor.get_response_for_exclusive_write(transaction));
                end
                else
                begin
                    exclusive_monitor.add_exclusive_read(transaction);
                    set_exclusive_response(vip_ahb5_types::EXCL_OKAY);
                end
            end
            else
            begin
                if(is_write_transaction(transaction))
                begin
                    exclusive_monitor.update_monitor_on_write(transaction);
                end
                set_exclusive_response(vip_ahb5_types::EXCL_FAIL);
            end
        end

        foreach(transaction.resp[i])
        begin
            if(transaction.slave_wait_states[i] === 0)
            begin
                generate_response(i,transaction);
            end
            else
            begin
                repeat(transaction.slave_wait_states[i])
                begin
                    resp_beat.ReadyOut = vip_ahb5_types::SLAVE_WAIT;
                    resp_beat.Response = vip_ahb5_types::RESP_OKAY;
                    resp_beat.ExclResponse = vip_ahb5_types::EXCL_FAIL;
                    resp_beat.State = vip_ahb5_types::TRANS_PENDING;
                    transaction.response_beats.push_back(resp_beat);
                end
                generate_response(i,transaction);
            end
        end
    endtask: create_responses


    protected function void generate_response(int unsigned pos,vip_ahb5_transaction transaction_);
        vip_ahb5_types::response_beat_struct_t resp_beat;

        if(transaction_.resp[pos] == vip_ahb5_types::RESP_OKAY)
        begin
            resp_beat.ReadyOut = vip_ahb5_types::SLAVE_READY;
            resp_beat.Response = vip_ahb5_types::RESP_OKAY;

            resp_beat.ExclResponse = configuration.is_bypass_exclusive_monitor()?
                                     transaction_.exclusive_response:get_exclusive_response();
            resp_beat.State = vip_ahb5_types::TRANS_SUCCESS;
            transaction_.response_beats.push_back(resp_beat);
        end
        else
        begin
            resp_beat.ReadyOut = vip_ahb5_types::SLAVE_WAIT;
            resp_beat.Response = vip_ahb5_types::RESP_ERROR;
            resp_beat.State = vip_ahb5_types::ERROR_RESP_1ST_CYCLE;
            resp_beat.ExclResponse = vip_ahb5_types::EXCL_FAIL;
            transaction_.response_beats.push_back(resp_beat);

            resp_beat.ReadyOut = vip_ahb5_types::SLAVE_READY;
            resp_beat.State = vip_ahb5_types::ERROR_RESP_2ND_CYCLE;
            transaction_.response_beats.push_back(resp_beat);
        end
    endfunction:generate_response



    virtual function
    bit is_exclusive_transaction(vip_ahb5_transaction transaction);
        return(transaction.exclusive_transfer == vip_ahb5_types::TRANS_ATTR_EXCL);
    endfunction:is_exclusive_transaction

    virtual function
    bit is_write_transaction(vip_ahb5_transaction transaction);
        return (transaction.request_type == vip_ahb5_types::REQUEST_WRITE);
    endfunction:is_write_transaction

    virtual function
    void handle_exclusives(vip_ahb5_transaction transaction);
    endfunction: handle_exclusives

    protected function void set_transaction_item(vip_ahb5_transaction transaction_);
        clear_trans_layer_containers();

        transaction_.set_burst_length(transaction_.calculate_burst_length());


        data_byte_width = vip_ahb5_types::get_data_width_from_hsize(transaction_.transfer_size);
        if(data_byte_width > transaction_.data_byte_width)
        begin
            `vip_ahb5_fatal(("Transfer with HSIZE greater then data bus width attempted."))
        end
        transaction_size = get_transaction_size(transaction_);
        wrapping_burst   = ((transaction_.burst_type == vip_ahb5_types::BURST_WRAP4)
                            ||(transaction_.burst_type == vip_ahb5_types::BURST_WRAP8)
                            ||(transaction_.burst_type == vip_ahb5_types::BURST_WRAP16));
        transaction_.set_endianness(configuration.get_endianness());

    endfunction: set_transaction_item


    protected function int unsigned get_transaction_size(vip_ahb5_transaction transaction_);
        int unsigned trans_size_;
        trans_size_ =  (data_byte_width)*(transaction_.burst_length);
        return trans_size_;
    endfunction: get_transaction_size

    protected function void clear_trans_layer_containers();
        transfer.delete();
        address_q.delete();
        resp.delete();
        data.delete();
    endfunction: clear_trans_layer_containers

    protected function
    void reset_transaction_layer();
        clear_trans_layer_containers();
        if(exclusive_monitor != null)
        begin
            exclusive_monitor.clear_active_addresses();
        end
    endfunction: reset_transaction_layer

    `VIP_AHB5_ACCESSOR(vip_ahb5_types::excl_response_t,exclusive_response)

endclass: vip_ahb5_transaction_layer


`endif

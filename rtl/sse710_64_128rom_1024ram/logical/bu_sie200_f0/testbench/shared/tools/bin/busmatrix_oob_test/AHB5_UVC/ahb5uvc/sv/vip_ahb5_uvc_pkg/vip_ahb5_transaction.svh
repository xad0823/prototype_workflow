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

`ifndef VIP_AHB5_TRANSACTION_SVH
`define VIP_AHB5_TRANSACTION_SVH


class vip_ahb5_transaction extends uvm_sequence_item;
    `uvm_object_utils(vip_ahb5_transaction)

    localparam int unsigned HSEL_WIDTH_MAX = 4;


    bit transaction_complete;

    bit transaction_terminated;

    bit reset_detected;

    bit valid_byte_strobes[];

    int unsigned valid_data_index[];


    protected vip_ahb5_types::node_t node_type;

    protected vip_ahb5_types::endianness_t  endianness;

    int unsigned data_byte_width;

    protected int unsigned hselx_width;

    int unsigned burst_length;

    bit terminate_burst_on_error;

    bit terminate_incr_with_busy;

    int unsigned insert_idle_at_end;

    bit bypass_address_alignment;


    rand vip_ahb5_types::request_t request_type;

    rand vip_ahb5_types::address_t address;

    rand vip_ahb5_types::size_t transfer_size;

    rand vip_ahb5_types::burst_t burst_type;

    rand vip_ahb5_types::lock_t locked_access;

    vip_ahb5_types::ahb5_prot_t protection;

    rand vip_ahb5_types::prot_t ahb3_protection;

    rand vip_ahb5_types::memory_v8_t memory_type;

    rand vip_ahb5_types::memory_access_t access_attribute;

    rand int unsigned incr_transfer_burst_length;

    rand bit[HSEL_WIDTH_MAX-1:0] slave_select;

    rand vip_ahb5_types::access_attr_t secure_transfer;

    rand vip_ahb5_types::trans_attr_t exclusive_transfer;

    rand vip_ahb5_types::master_id_t exclusive_master_id;

    vip_ahb5_types::hauser_t a_user[$];

    vip_ahb5_types::excl_response_t exclusive_response;

    rand vip_ahb5_types::response_t resp[];
    local bit resp_rand;

    time start_time;

    time finish_time;


    vip_ahb5_types::transfer_t transfer_beats[];

    vip_ahb5_types::address_t address_beats[];

    vip_ahb5_types::vip_ahb5_data_struct_t data;

    vip_ahb5_types::request_beat_struct_t request_beats[$];

    vip_ahb5_types::response_beat_struct_t response_beats[$];

    vip_ahb5_types::response_t transaction_response;


    protected vip_ahb5_control_knobs control_knobs;

    static protected vip_ahb5_control_knobs default_control_knobs;


    int unsigned busy_transfer_position;

    rand bit[4:0] num_busy_cycles;

    bit[4:0] master_wait_states[$];

    bit[4:0] slave_wait_states[$];

    bit calc_address_on_slave_id;

    bit calc_slave_id_on_address=1;


    constraint burst_type_for_exclusive_constraint{
        solve exclusive_transfer before burst_type;

        if(exclusive_transfer == vip_ahb5_types::TRANS_ATTR_EXCL)
            burst_type inside{vip_ahb5_types::BURST_SINGLE, vip_ahb5_types::BURST_INCR};
    }

    constraint incr_transfer_burst_length_constraint{
        solve exclusive_transfer before incr_transfer_burst_length;
        if (exclusive_transfer == vip_ahb5_types::TRANS_ATTR_EXCL)
            incr_transfer_burst_length == 1;
        else
            incr_transfer_burst_length inside{[1:control_knobs.get_max_burst_length()]};
    }

    constraint transfer_size_constraint {
        transfer_size inside{[0:vip_ahb5_types::get_hsize_from_data_width(data_byte_width)]};
    }

    constraint slave_select_constraint{
        slave_select inside{[0:hselx_width]};
    }

    constraint response_constraint {

        resp.size() == burst_length;

        if (control_knobs.response_mode == vip_ahb5_types::RESP_MODE_OKAY)
             foreach (resp[i]) resp[i] == vip_ahb5_types::RESP_OKAY;
        else if (control_knobs.response_mode == vip_ahb5_types::RESP_MODE_ERROR)
             foreach (resp[i]) resp[i] == vip_ahb5_types::RESP_ERROR;
    }


    constraint num_busy_cycles_constraint{
        if(control_knobs.timing_mode == vip_ahb5_types::TIMING_ASAP)
            num_busy_cycles == 5'h00;
        else if (control_knobs.timing_mode == vip_ahb5_types::TIMING_RANDOM)
            num_busy_cycles inside {[control_knobs.get_wait_state_delay_cycle_min():
                                    control_knobs.get_wait_state_delay_cycle_max()]};
    }


    function new(string name_ = "vip_ahb5_transaction");
        super.new(name_);
        default_control_knobs = vip_ahb5_control_knobs::type_id::create("Default control knobs");
        set_request_type_rand(1);
        set_address_rand(1);
        set_transfer_size_rand(1);
        set_burst_type_rand(1);
        set_locked_access_rand(1);
        set_memory_type_rand(1);
        set_access_attribute_rand(1);
        set_slave_select_rand(1);
        set_resp_rand(1);
        set_bypass_address_alignment(0);
        set_insert_idle_at_end(0);
    endfunction: new

    function void pre_randomize();
        super.pre_randomize();

        if (control_knobs == null)
        begin
            control_knobs = default_control_knobs;
        end

        case(get_node_type())
            vip_ahb5_types::MASTER_NODE:
                begin
                    set_resp_rand(0);

                    if(!control_knobs.support_secure_transfer) begin
                        set_secure_transfer_rand(0);
                    end
                    else begin
                        set_secure_transfer_rand(1);
                    end
                end
            vip_ahb5_types::SLAVE_NODE:
                begin
                    set_request_type_rand(0);
                    set_address_rand(0);
                    set_transfer_size_rand(0);
                    set_burst_type_rand(0);
                    set_locked_access_rand(0);
                    set_memory_type_rand(0);
                    set_access_attribute_rand(0);
                    set_slave_select_rand(0);
                    set_burst_type_for_exclusive_constraint_cmode(0);
                    set_incr_transfer_burst_length_constraint_cmode(0);
                    set_incr_transfer_burst_length(control_knobs.get_max_burst_length());
                    set_burst_length(calculate_burst_length());
                end
        endcase

    endfunction: pre_randomize

    function void post_randomize();
        bit[4:0] num_wait_cycles;
        super.post_randomize();

        case(get_node_type())
            vip_ahb5_types::MASTER_NODE:
            begin
               set_burst_length(calculate_burst_length());

               `VIP_AHB5_RANDOMIZE_RANGE(busy_transfer_position,0,(calculate_burst_length()-2))
                if(burst_type != vip_ahb5_types::BURST_SINGLE) begin
                    for(int i =0;i<get_burst_length();++i) begin
                        if(i == busy_transfer_position) begin
                            master_wait_states.push_back(num_busy_cycles);
                        end else begin
                            master_wait_states.push_back(5'h00);
                        end
                    end
                end else begin
                    master_wait_states.push_back(5'h00);
                end

                if((request_type == vip_ahb5_types::REQUEST_WRITE)&&
                   (control_knobs.get_generate_random_data()))
                begin
                    data.data.delete();
                    generate_data();
                    data.user.delete();
                    generate_data_user();
                end
                a_user.delete();
                generate_address_user();

                if(control_knobs != null && control_knobs.support_v8_memory) begin
                    set_protection({memory_type,access_attribute});
                end
                else begin
                    set_protection(ahb3_protection);
                end
            end

            vip_ahb5_types::SLAVE_NODE:
            begin
                for(int i =0;i<get_burst_length();++i) begin
                    if(control_knobs.timing_mode == vip_ahb5_types::TIMING_ASAP) begin
                        slave_wait_states.push_back(5'h00);
                    end else begin
                       `VIP_AHB5_RANDOMIZE_RANGE(num_wait_cycles,control_knobs.get_wait_state_delay_cycle_min(),
                                                              control_knobs.get_wait_state_delay_cycle_max())
                        slave_wait_states.push_back(num_wait_cycles);
                    end
                end
            end
        endcase
        this.constraint_mode(1);
        this.rand_mode(1);

    endfunction: post_randomize

    protected function void generate_data();
        bit [7:0] data_byte[];
        for(int i=0;i < burst_length;++i) begin
            data_byte = new[this.data_byte_width];
            if(!(std::randomize(data_byte))) begin
                `vip_ahb5_fatal(("Failed to randomize data"))
            end
            data.data.push_back(data_byte);
            data_byte.delete();
        end
    endfunction : generate_data

    protected function
    void generate_data_user();
        vip_ahb5_types::hdatauser_t data_user_tmp;
        vip_ahb5_types::user_mode_t user_gen_mode;

        user_gen_mode = control_knobs.get_user_generation_mode();

        for (int i= 0; i< burst_length; i++)
        begin
           case (user_gen_mode)
               vip_ahb5_types::USER_RANDOM :
               begin
                   bit result = std::randomize(data_user_tmp);
                   if (!result)
                   begin
                       `vip_ahb5_error(("Failed to randomize user data"))
                   end
               end
               vip_ahb5_types::USER_ZERO :
               begin
                   data_user_tmp = 0;
               end
           endcase
           data.user.push_back(data_user_tmp);
        end
    endfunction : generate_data_user

    virtual function
    void generate_address_user();
        vip_ahb5_types::hdatauser_t addr_user_tmp;
        vip_ahb5_types::user_mode_t user_gen_mode;

        user_gen_mode = control_knobs.get_user_generation_mode();

        case (user_gen_mode)
            vip_ahb5_types::USER_ZERO :
            begin
                addr_user_tmp = 0;
            end
            vip_ahb5_types::USER_RANDOM :
            begin
                bit result = std::randomize(addr_user_tmp);
                if(!result)
                begin
                    `vip_ahb5_error(("Failed to randomize AUser field"))
                end
            end
        endcase
        a_user.push_back(addr_user_tmp);
    endfunction : generate_address_user

    virtual function void populate_transaction();
        if (control_knobs == null)
        begin
            control_knobs = default_control_knobs;
        end
        populate_request();
        populate_response();
    endfunction: populate_transaction

    virtual function void populate_request();
        vip_ahb5_types::request_beat_struct_t request_q[$];
        bit[4:0]delay;
        int idx;

        if (request_beats.size() == 0)
        begin
            return;
        end

        set_address(vip_ahb5_types::address_t'(request_beats[0].Address));
        set_request_type(vip_ahb5_types::request_t'(request_beats[0].Direction));
        set_burst_type(vip_ahb5_types::burst_t'(request_beats[0].Burst));
        set_transfer_size(vip_ahb5_types::size_t'(request_beats[0].Size));
        set_locked_access(vip_ahb5_types::lock_t'(request_beats[0].Lock));
        set_protection(vip_ahb5_types::ahb5_prot_t'(request_beats[0].Prot));
        set_memory_type(vip_ahb5_types::memory_v8_t'(request_beats[0].Prot[6:2]));
        set_access_attribute(vip_ahb5_types::memory_access_t'(request_beats[0].Prot[1:0]));
        set_slave_select(request_beats[0].Select);
        set_burst_length(calculate_burst_length());
        set_exclusive_transfer(vip_ahb5_types::trans_attr_t'(request_beats[0].Exclusive));
        set_secure_transfer(vip_ahb5_types::access_attr_t'(request_beats[0].Secure));
        set_exclusive_master_id(request_beats[0].MasterId);


        transfer_beats = new[request_beats.size()];
        address_beats  = new[request_beats.size()];
        idx=0;
        for(int i =0;i< request_beats.size();++i)begin
            if(request_beats[i].Transfer != vip_ahb5_types::TRANSFER_BUSY) begin
                request_q.push_back(request_beats[i]);
                transfer_beats[idx] = vip_ahb5_types::transfer_t'(request_beats[i].Transfer);
                address_beats[idx++]  = vip_ahb5_types::address_t'(request_beats[i].Address);
                master_wait_states.push_back(delay);
                delay = 0;
            end  else begin
                ++delay;
            end
        end
        transfer_beats = new[idx](transfer_beats);
        address_beats  = new[idx](address_beats);

        if(burst_type != vip_ahb5_types::BURST_INCR)
        begin
            set_transaction_terminated(transfer_beats.size() < burst_length);
        end

        a_user.delete();
        a_user.push_back(request_beats[0].AUser);
    endfunction: populate_request

    virtual function void populate_response();
        vip_ahb5_types::response_t response_q[$];
        bit temp_response;
        bit[4:0]delay;

        if(response_beats.size() == 0)
        begin
            return;
        end

        for(int i =0;i< response_beats.size();++i)begin
            if(response_beats[i].ReadyOut) begin
                response_q.push_back( vip_ahb5_types::response_t'(response_beats[i].Response));
                slave_wait_states.push_back(delay);
                delay = 0;
            end else if(!response_beats[i].Response) begin
                ++delay;
            end
            temp_response |=  response_beats[i].Response;
        end
        resp = response_q;

        set_exclusive_response(vip_ahb5_types::excl_response_t'(response_beats[response_beats.size()-1].ExclResponse));

        transaction_response = vip_ahb5_types::response_t'(temp_response);

    endfunction: populate_response


    virtual function void set_physical_properties(vip_ahb5_types::vip_ahb5_physical_properties_t physical_properties);
        this.data_byte_width = physical_properties.data_byte_width;
        this.hselx_width     = physical_properties.hselx_width;
    endfunction: set_physical_properties

    function int unsigned calculate_burst_length();
        int unsigned length;

        if ((incr_transfer_burst_length == 0) && (is_node_type(vip_ahb5_types::SLAVE_NODE)))
        begin
            set_incr_transfer_burst_length(control_knobs.get_max_burst_length());
        end

        case(burst_type)
        vip_ahb5_types::BURST_SINGLE:
            begin
                length = 1;
            end
        vip_ahb5_types::BURST_INCR:
            begin
                length = get_incr_transfer_burst_length();
            end
        vip_ahb5_types::BURST_WRAP4,
        vip_ahb5_types::BURST_INCR4:
            begin
               length = 4;
            end
        vip_ahb5_types::BURST_WRAP8,
        vip_ahb5_types::BURST_INCR8:
            begin
               length = 8;
            end
        vip_ahb5_types::BURST_WRAP16,
        vip_ahb5_types::BURST_INCR16:
            begin
               length = 16;
            end
        endcase
        return length;
    endfunction: calculate_burst_length


    protected function string pad_string(string s, int desired_length);
        static string pad="          ";
        while (desired_length - s.len() >= pad.len())
            s = { s , pad };
        if ( desired_length > s.len())
        begin
            s = {s, pad.substr(0,desired_length - s.len() -1)};
        end
        return s;
    endfunction : pad_string

    protected function string get_string_array(int unsigned index_);
        string list[3];
        foreach(transfer_beats[i])
        begin
            int max_len;
            if( i != 0)
            begin
                list[0] = {list[0]," "};
                list[1] = {list[1]," "};
                list[2] = {list[2]," "};
            end
            list[1] = {list[1],"0x"};
            list[0] = {list[0],$sformatf("0x%h",address_beats[i])};

            if(data.data.size() > 0) begin
                for(int j= data.data[i].size()-1;j>=0 ;--j)
                begin
                    list[1] = {list[1],$sformatf("%h",data.data[i][j])};
                end
            end
            list[2] = {list[2],resp[i].name()};
            max_len = list[0].len();
            if (max_len < list[1].len())
            begin
                max_len = list[1].len();
            end
            if (max_len < list[2].len())
            begin
                max_len = list[2].len();
            end
            list[0] = pad_string(list[0],max_len);
            list[1] = pad_string(list[1],max_len);
            list[2] = pad_string(list[2],max_len);
        end
        return list[index_];
    endfunction:get_string_array

    virtual function void do_print(uvm_printer printer);

        printer.knobs.type_name = 0;
        printer.knobs.size = 0;

        printer.print_string("Transaction",request_type.name());
        printer.print_string("Burst",burst_type.name());
        printer.print_string("Size",transfer_size.name());
        printer.print_string("Access",locked_access.name());
        printer.print_string("Memory Type",memory_type.name());
        printer.print_string("Access Attributes",access_attribute.name());
        printer.print_string("Endianness",endianness.name());
        printer.print_string("Address",get_string_array(0));
        printer.print_string("Data",get_string_array(1));
        printer.print_string("Response",get_string_array(2));
        printer.print_string("Secure",secure_transfer.name());
        printer.print_string("Exclusive",exclusive_transfer.name());
        if(exclusive_transfer == vip_ahb5_types::TRANS_ATTR_EXCL)
            printer.print_string("ExclusiveResp",exclusive_response.name());
        printer.print_string("MasterId",$sformatf("%02x",exclusive_master_id));
        printer.print_time("Start time",start_time);
        printer.print_time("End time",finish_time);
    endfunction: do_print

    virtual function string convert2string();

        return {"\n================================================================",
            "\nTransaction     : ",request_type.name(),
            "\nBurst           : ",burst_type.name(),
            "\nSize            : ",transfer_size.name(),
            "\nAccess          : ",locked_access.name(),
            "\nProtection      : ",$sformatf("'h%0h",protection),
            "\nMemory Type     : ",memory_type.name(),
            "\nAccess Attrs    : ",access_attribute.name(),
            "\nEndianness      : ",endianness.name(),
            "\nAddress         : ",get_string_array(0),
            "\nData            : ",get_string_array(1),
            "\nResponse        : ",get_string_array(2),
            "\nSlave Select    : ",$sformatf("%0h",slave_select),

            "\nSecure          : ",secure_transfer.name(),
            "\nExclusive       : ",exclusive_transfer.name(),
            "\nMasterId        : ",$sformatf("%02x",exclusive_master_id),
            (exclusive_transfer == vip_ahb5_types::TRANS_ATTR_EXCL) ? { "\nExclusiveResp   : ",exclusive_response.name() } : "",
            "\nStart time      : ",$sformatf("%t",start_time),
            "\nEnd time        : ",$sformatf("%t",finish_time),
            "\n----------------------------------------------------------------"
            };
    endfunction: convert2string

    function void do_copy(uvm_object rhs);
        vip_ahb5_transaction source;
        if(!$cast(source,rhs)) begin
            `vip_ahb5_fatal(("Type mismatch in do_copy"))
        end

        super.do_copy(rhs);

        data_byte_width          = source.data_byte_width;
        hselx_width              = source.hselx_width;

        node_type                = source.node_type;
        control_knobs            = source.control_knobs;
        terminate_burst_on_error = source.terminate_burst_on_error;
        terminate_incr_with_busy = source.terminate_incr_with_busy;
        insert_idle_at_end       = source.insert_idle_at_end;
        bypass_address_alignment = source.bypass_address_alignment;
        endianness               = source.endianness;

        request_type               = source.request_type;
        address                    = source.address;
        a_user                     = source.a_user;
        transfer_size              = source.transfer_size;
        burst_type                 = source.burst_type;
        locked_access              = source.locked_access;
        protection                 = source.protection;
        memory_type                = source.memory_type;
        access_attribute           = source.access_attribute;
        resp                       = source.resp;
        valid_byte_strobes         = source.valid_byte_strobes;
        data                       = source.data;
        master_wait_states         = source.master_wait_states;
        burst_length               = source.burst_length;
        slave_select               = source.slave_select;
        slave_wait_states          = source.slave_wait_states;
        request_beats              = source.request_beats;
        response_beats             = source.response_beats;
        address_beats              = source.address_beats;
        secure_transfer            = source.secure_transfer;
        exclusive_transfer         = source.exclusive_transfer;
        exclusive_master_id        = source.exclusive_master_id;
        exclusive_response         = source.exclusive_response;
        incr_transfer_burst_length = source.incr_transfer_burst_length;

        transaction_complete     = source.transaction_complete;
        transaction_terminated   = source.transaction_terminated;
        reset_detected           = source.reset_detected;
    endfunction: do_copy

    function void set_start_time(time t);
        this.start_time = t;
        void'(begin_tr(this.start_time));
    endfunction: set_start_time

    function void set_finish_time(time t);
        this.finish_time = t;
        end_tr(finish_time);
    endfunction: set_finish_time


    virtual function void get_endianed_data_lanes(vip_ahb5_types::address_t addr_);
        int unsigned address_offset;
        int unsigned data_bus_size;
        int unsigned lane_offset;

        valid_data_index = new[this.data_byte_width];
        valid_byte_strobes = new[this.data_byte_width];

        address_offset = (addr_ - (addr_/data_byte_width)*data_byte_width);
        data_bus_size = data_byte_width -1;

        for(int i = 0; i< data_byte_width; ++i)
        begin
            valid_byte_strobes[i] = 1'b0;
            valid_data_index[i] = i;
        end
        case(transfer_size)
            vip_ahb5_types::SIZE_0:
            begin
                sort_byte_transfer_endianness(address_offset, data_bus_size);
            end
            vip_ahb5_types::SIZE_1:
            begin
                sort_halfword_transfer_endianness(address_offset, data_bus_size);
            end
            default:
            begin
                sort_larger_transfer_endianness(data_bus_size);
            end
        endcase

    endfunction:get_endianed_data_lanes

    function void sort_byte_transfer_endianness(int unsigned addr_offset_, int unsigned bus_size_);
        if((endianness == vip_ahb5_types::ENDIAN_LITTLE) ||(endianness == vip_ahb5_types::ENDIAN_BE8))
        begin
            foreach(valid_byte_strobes[i]) begin
                if(i == addr_offset_) begin
                    valid_byte_strobes[i] = 1'b1;
                end
            end
        end
        else if(endianness == vip_ahb5_types::ENDIAN_BE32)
        begin
            foreach(valid_byte_strobes[i]) begin
                if(i == (bus_size_ - addr_offset_)) begin
                    valid_byte_strobes[i] = 1'b1;
                end
                valid_data_index[i] = bus_size_- i;
            end
        end
    endfunction: sort_byte_transfer_endianness

    function void sort_halfword_transfer_endianness(int unsigned addr_offset_, int unsigned bus_size_);

        if(endianness == vip_ahb5_types::ENDIAN_LITTLE)
        begin
            foreach(valid_byte_strobes[i]) begin
                if(i == addr_offset_) begin
                    valid_byte_strobes[i] = 1'b1;
                    valid_byte_strobes[i+1] = 1'b1;
                end
            end
        end
        else if(endianness == vip_ahb5_types::ENDIAN_BE8)
        begin
            foreach(valid_byte_strobes[i]) begin
                if(i == addr_offset_) begin
                    valid_byte_strobes[i]   = 1'b1;
                    valid_byte_strobes[i+1] = 1'b1;
                    valid_data_index[i]     = i+1;
                    valid_data_index[i+1]   = i;
                end
            end
        end
        else if(endianness == vip_ahb5_types::ENDIAN_BE32)
        begin
            foreach(valid_byte_strobes[i]) begin
                if(i == (bus_size_ - addr_offset_)) begin
                    valid_byte_strobes[i] = 1'b1;
                    valid_byte_strobes[i-1] = 1'b1;
                    valid_data_index[i] = addr_offset_ + 1;
                    valid_data_index[i-1] = addr_offset_;
                end
            end
        end

    endfunction: sort_halfword_transfer_endianness

    function void sort_larger_transfer_endianness(int unsigned bus_size_);
        if((endianness == vip_ahb5_types::ENDIAN_LITTLE) ||(endianness == vip_ahb5_types::ENDIAN_BE32))
        begin
            foreach(valid_byte_strobes[i]) begin
                valid_byte_strobes[i] = 1'b1;
            end
        end
        else if(endianness == vip_ahb5_types::ENDIAN_BE8)
        begin
            foreach(valid_byte_strobes[i]) begin
                valid_data_index[i] = (bus_size_ - i);
                valid_byte_strobes[i] = 1'b1;
            end
        end
    endfunction: sort_larger_transfer_endianness

    function void convert_be8_to_little_endian(input vip_ahb5_types::address_t addr_,input bit[7:0] in_data_[], output bit[7:0] out_data_[]);
        int unsigned address_offset;
        int unsigned data_bus_size;
        int unsigned lane_offset;
        bit modified_byte_strobes[];


        address_offset = (addr_ - (addr_/data_byte_width)*data_byte_width);
        modified_byte_strobes = new[data_byte_width];
        data_bus_size = data_byte_width -1;

        out_data_ = new[in_data_.size()];

        foreach(valid_byte_strobes[i]) begin
            modified_byte_strobes[i] = 1'b0;
            out_data_[i] = 8'h00;
        end

        case(transfer_size)
            vip_ahb5_types::SIZE_0:
            begin
                foreach(valid_byte_strobes[i]) begin
                    if(i == address_offset) begin
                        modified_byte_strobes[address_offset] = 1'b1;
                        out_data_[address_offset] = in_data_[i];
                    end
                end
            end
            vip_ahb5_types::SIZE_1:
            begin
                foreach(valid_byte_strobes[i]) begin
                    if(i == address_offset) begin
                        modified_byte_strobes[i] = 1'b1;
                        modified_byte_strobes[i+1] = 1'b1;
                        out_data_[i] = in_data_[i+1];
                        out_data_[i+1] = in_data_[i];
                    end
                end
            end
            default:
            begin
                foreach(valid_byte_strobes[i]) begin
                    out_data_[i] = in_data_[(data_bus_size -i)];
                    modified_byte_strobes[i] = 1'b1;
                end
            end
        endcase
        valid_byte_strobes = modified_byte_strobes;
    endfunction: convert_be8_to_little_endian

    function void convert_be32_to_little_endian(input vip_ahb5_types::address_t addr_,input bit[7:0] in_data_[], output bit[7:0] out_data_[]);
        int unsigned address_offset;
        int unsigned data_bus_size;
        int unsigned lane_offset;
        bit modified_byte_strobes[];

        address_offset = (addr_ - (addr_/data_byte_width)*data_byte_width);
        modified_byte_strobes = new[data_byte_width];
        data_bus_size = data_byte_width -1;

        out_data_ = new[in_data_.size()];

        foreach(valid_byte_strobes[i]) begin
            modified_byte_strobes[i] = 1'b0;
            out_data_[i] = 8'h00;
        end

        case(transfer_size)
            vip_ahb5_types::SIZE_0:
            begin
                foreach(valid_byte_strobes[i]) begin
                    if(i == address_offset) begin
                        modified_byte_strobes[address_offset] = 1'b1;
                        out_data_[address_offset] = in_data_[(data_bus_size -address_offset)];
                    end
                end
            end
            vip_ahb5_types::SIZE_1:
            begin
                foreach(valid_byte_strobes[i]) begin
                    if(i == (data_bus_size - address_offset)) begin
                        modified_byte_strobes[address_offset] = 1'b1;
                        modified_byte_strobes[address_offset+1] = 1'b1;
                        out_data_[address_offset] = in_data_[data_bus_size - (address_offset+1)];
                        out_data_[address_offset+1] = in_data_[(data_bus_size - address_offset)];
                    end
                end
            end
            default:
            begin
                out_data_ = in_data_;
                foreach(valid_byte_strobes[i])
                begin
                    modified_byte_strobes[i] = 1'b1;
                end
            end
        endcase
        valid_byte_strobes = modified_byte_strobes;
    endfunction: convert_be32_to_little_endian

    function void convert_to_little_endian(input vip_ahb5_types::address_t addr_,input bit[7:0] in_data_[], output bit[7:0] out_data_[]);
        int unsigned address_offset;
        int unsigned data_bus_size;
        int unsigned lane_offset;
        bit modified_byte_strobes[];

        address_offset = (addr_ - (addr_/data_byte_width)*data_byte_width);
        modified_byte_strobes = new[data_byte_width];
        data_bus_size = data_byte_width -1;

        out_data_ = new[in_data_.size()];

        foreach(valid_byte_strobes[i]) begin
            modified_byte_strobes[i] = 1'b0;
            out_data_[i] = 8'h00;
        end

        case(transfer_size)
            vip_ahb5_types::SIZE_0:
            begin
                foreach(valid_byte_strobes[i]) begin
                    if(i == address_offset) begin
                        modified_byte_strobes[address_offset] = 1'b1;
                        out_data_[address_offset] = in_data_[i];
                    end
                end
            end
            vip_ahb5_types::SIZE_1:
            begin
                foreach(valid_byte_strobes[i]) begin
                    if(i == (data_bus_size - address_offset)) begin
                        modified_byte_strobes[address_offset] = 1'b1;
                        modified_byte_strobes[address_offset+1] = 1'b1;
                        out_data_[address_offset] = in_data_[address_offset];
                        out_data_[address_offset+1] = in_data_[address_offset+1];
                    end
                end
            end
            default:
            begin
                out_data_ = in_data_;
                foreach(valid_byte_strobes[i]) begin
                    modified_byte_strobes[i] = 1'b1;
                end
            end
        endcase
        valid_byte_strobes = modified_byte_strobes;
    endfunction: convert_to_little_endian

    virtual function void get_valid_byte_lanes(vip_ahb5_types::address_t addr);
        int unsigned data_size;
        int unsigned num;
        int unsigned start_offset;
        bit[7:0] modified_address_offset = 8'h00;
        begin
            data_size = 1<<transfer_size;
            num = $clog2(this.data_byte_width);
            for(int i = 0; i<num; ++i)
            begin
                modified_address_offset[i] = addr[i];
            end

            foreach (valid_byte_strobes[i])
            begin
                valid_byte_strobes[i] = 1'b0;
            end
            if(data_size < this.data_byte_width)
            begin
                if((modified_address_offset%data_size) == 0)
                begin
                    start_offset = modified_address_offset;
                    for(int j = 0;j<data_size;++j)
                    begin
                        valid_byte_strobes[start_offset+j] = 1'b1;
                    end
                end
            end
            else
            begin
                foreach (valid_byte_strobes[i])
                begin
                    valid_byte_strobes[i] = 1'b1;
                end
            end
        end
    endfunction : get_valid_byte_lanes


   `VIP_AHB5_FLAG_ACCESSOR(transaction_complete)
   `VIP_AHB5_FLAG_ACCESSOR(transaction_terminated)
   `VIP_AHB5_FLAG_ACCESSOR(reset_detected)
   `VIP_AHB5_FLAG_ACCESSOR(terminate_burst_on_error)
   `VIP_AHB5_FLAG_ACCESSOR(terminate_incr_with_busy)
   `VIP_AHB5_ACCESSOR(int unsigned,insert_idle_at_end)
   `VIP_AHB5_FLAG_ACCESSOR(bypass_address_alignment)
   `VIP_AHB5_ACCESSOR(vip_ahb5_types::node_t,node_type)
   `VIP_AHB5_ACCESSOR(vip_ahb5_types::endianness_t,endianness)
   `VIP_AHB5_ACCESSOR(vip_ahb5_control_knobs, control_knobs)
   `VIP_AHB5_ACCESSOR(int unsigned, burst_length)
   `VIP_AHB5_ACCESSOR(int unsigned,data_byte_width)
   `VIP_AHB5_ACCESSOR(int unsigned,busy_transfer_position)


   `VIP_AHB5_RAND_ACCESSOR(vip_ahb5_types::request_t,request_type)
   `VIP_AHB5_RAND_ACCESSOR(vip_ahb5_types::address_t,address)
   `VIP_AHB5_RAND_ACCESSOR(vip_ahb5_types::size_t,transfer_size)
   `VIP_AHB5_RAND_ACCESSOR(vip_ahb5_types::burst_t,burst_type)
   `VIP_AHB5_RAND_ACCESSOR(vip_ahb5_types::lock_t,locked_access)
   `VIP_AHB5_RAND_ACCESSOR(int unsigned,incr_transfer_burst_length)
   `VIP_AHB5_RAND_MODE_ARRAY_OPTIMISED(resp)
   `VIP_AHB5_STATIC_ARRAY_RAND_ACCESSOR(vip_ahb5_types::response_t,resp)
   `VIP_AHB5_CONSTRAINT_MODE(response_constraint)
   `VIP_AHB5_RAND_ACCESSOR(bit[HSEL_WIDTH_MAX-1:0], slave_select)
   `VIP_AHB5_RAND_ACCESSOR(vip_ahb5_types::access_attr_t,secure_transfer)
   `VIP_AHB5_RAND_ACCESSOR(vip_ahb5_types::trans_attr_t,exclusive_transfer)
   `VIP_AHB5_ACCESSOR(vip_ahb5_types::excl_response_t,exclusive_response)
   `VIP_AHB5_RAND_ACCESSOR(vip_ahb5_types::master_id_t,exclusive_master_id)
   `VIP_AHB5_RAND_ACCESSOR(vip_ahb5_types::memory_v8_t,memory_type)
   `VIP_AHB5_RAND_ACCESSOR(vip_ahb5_types::memory_access_t,access_attribute)
   `VIP_AHB5_ACCESSOR(vip_ahb5_types::ahb5_prot_t,protection)
   `VIP_AHB5_CONSTRAINT_MODE(burst_type_for_exclusive_constraint)
   `VIP_AHB5_CONSTRAINT_MODE(incr_transfer_burst_length_constraint)
endclass: vip_ahb5_transaction


`endif

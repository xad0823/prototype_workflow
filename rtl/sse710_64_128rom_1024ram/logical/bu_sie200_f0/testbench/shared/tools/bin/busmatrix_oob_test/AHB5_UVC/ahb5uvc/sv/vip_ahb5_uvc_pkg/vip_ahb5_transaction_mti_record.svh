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

`ifndef VIP_AHB5_TRANSACTION_MTI_RECORD_SVH
`define VIP_AHB5_TRANSACTION_MTI_RECORD_SVH



`ifdef MODEL_TECH
    `define VIP_AHB5_RECORD_CREATE_STREAM(a,b) b = $create_transaction_stream(a);
    `define VIP_AHB5_RECORD_BEGIN_TRANSACTION(a,b,c) $begin_transaction(a,b,c);
    `define VIP_AHB5_RECORD_BEGIN_CHILD_TRANSACTION(a,b,c,d) $begin_transaction(a,b,c,d);
    `define VIP_AHB5_RECORD_ADD_ATTRIBUTE(a,b,c) $add_attribute(a,b,c);
    `define VIP_AHB5_RECORD_SET_COLOR(a,b) $add_color(a,b);
    `define VIP_AHB5_RECORD_END_TRANSACTION(a) $end_transaction(a); $free_transaction(a);
    `define VIP_AHB5_RECORD_END_TRANSACTION_AT(a,b) $end_transaction(a,b); $free_transaction(a);
`endif

class vip_ahb5_transaction_mti_record extends vip_ahb5_transaction_record_base;
    `uvm_component_utils(vip_ahb5_transaction_mti_record)

    typedef struct {
        string memory_type;
        string secure_access;
        string access_attributes;
    } memory_payload_t;

    typedef struct {
        string size;
        string locked_access;
        string endianness;
        string exclusive;
        string exclusive_response;
        vip_ahb5_types::hauser_t user;
    } other_req_attr_t;

    typedef enum bit {
        COLOUR_READ,
        COLOUR_WRITE
    } visualization_colours_t;

    protected string visualization_colours[];

    function
    new(string name, uvm_component parent);
        super.new(name, parent);

        visualization_colours = '{
            "#00BFFF",
            "#FF8C00"
        };
    endfunction : new

    virtual function
    void open_recording_stream();
`ifdef MODEL_TECH
        string name;
        uvm_component parent_;

        parent_ = get_parent();
        name = {"..", parent_.get_full_name(), ".req_stream"};

        `VIP_AHB5_RECORD_CREATE_STREAM(name, stream)

        if (stream == 0)
        begin
            `vip_ahb5_error(("Unable to create visualization stream on %s location", name))
        end
`endif
    endfunction : open_recording_stream



    virtual function
    void do_new_transaction(vip_ahb5_transaction_record_item viz_event_);
`ifdef MODEL_TECH
        if (new_trans_handle != 0)
        begin
            `vip_ahb5_error(("New visualization transaction handle is already in use!"))
        end
        else
        begin
            new_trans_handle = create_transaction_handle(viz_event_);
            if (new_trans_handle == 0)
            begin
                `vip_ahb5_error(("Unable to add new transaction to the stream"))
            end
            else
            begin
                trans_handle = new_trans_handle;
                new_trans_handle = 0;

                add_transaction_attributes(viz_event_, trans_handle);

            end
        end
`endif
    endfunction : do_new_transaction


    virtual function
    integer create_transaction_handle(vip_ahb5_transaction_record_item viz_event_);
`ifdef MODEL_TECH
        integer handle_;
        string name = viz_event_.transaction.request_type.name();
        if (viz_event_.start_time > $realtime)
        begin
            viz_event_.start_time = $realtime;
            `vip_ahb5_warning(("Attempt to start a transaction in the future"))
        end
        handle_ = `VIP_AHB5_RECORD_BEGIN_TRANSACTION(stream, name, viz_event_.start_time)
        return handle_;
`else
        return 0;
`endif
    endfunction : create_transaction_handle

    virtual function
    void free_transaction_handle(vip_ahb5_transaction_record_item viz_event_,
                                 integer handle_);
`ifdef MODEL_TECH
        if (!(viz_event_.transaction.is_transaction_complete() ||
              viz_event_.transaction.is_reset_detected()))
        begin
            `vip_ahb5_warning(("Trying to free handle for uncomplete transaction!"))
        end
        else
        begin
            if (handle_ == 0)
            begin
                `vip_ahb5_warning(("Trying to de-alocate a zero value handle!"))
            end
            else
            begin
                `VIP_AHB5_RECORD_END_TRANSACTION(handle_)
            end
        end
`endif
    endfunction : free_transaction_handle

    virtual function
    void do_completed_transaction(vip_ahb5_transaction_record_item viz_event_);
`ifdef MODEL_TECH
        do_update_transaction(viz_event_);
        free_transaction_handle(temp_viz_event, trans_handle);
`endif
    endfunction : do_completed_transaction


    virtual function
    void add_transaction_attributes(vip_ahb5_transaction_record_item viz_event_,
                                    integer handle_);
`ifdef MODEL_TECH
        string name;
        memory_payload_t mem_payload;
        other_req_attr_t other_req_attr;
        string colour;

        name = viz_event_.transaction.burst_type.name();
        `VIP_AHB5_RECORD_ADD_ATTRIBUTE(handle_, name, "Burst")
        name = $sformatf("0x%h", viz_event_.transaction.get_address());
        `VIP_AHB5_RECORD_ADD_ATTRIBUTE(handle_, name, "Address")
        mem_payload = populate_mem_attr(viz_event_.transaction);
        `VIP_AHB5_RECORD_ADD_ATTRIBUTE(handle_, mem_payload, "Memory_Payload")
        other_req_attr = populate_other_req_attr(viz_event_.transaction);
        `VIP_AHB5_RECORD_ADD_ATTRIBUTE(handle_, other_req_attr, "Other_Attributes")

        case (viz_event_.transaction.request_type)
            vip_ahb5_types::REQUEST_READ  :
            begin
                colour = get_visualization_colour(COLOUR_READ);
            end
            vip_ahb5_types::REQUEST_WRITE :
            begin
                colour = get_visualization_colour(COLOUR_WRITE);
            end
            default       : `vip_ahb5_warning(("Attempt to set colour for an unknown transaction type!"))
        endcase
        `VIP_AHB5_RECORD_SET_COLOR(handle_,colour)

`endif
    endfunction : add_transaction_attributes

    virtual function
    void add_data_attributes(vip_ahb5_transaction_record_item viz_event_,
                                    integer handle_);
`ifdef MODEL_TECH
        string data;
        integer position;
        vip_ahb5_types::hdatauser_t user;
        vip_ahb5_types::response_beat_struct_t success_resp[$];

        success_resp = viz_event_.transaction.response_beats.find with
                        (!(item.State inside {vip_ahb5_types::TRANS_PENDING,
                                              vip_ahb5_types::ERROR_RESP_1ST_CYCLE}));

        if (viz_event_.transaction.data.data.size() == 0)
        begin
            `vip_ahb5_error(("Attempt to display data when no data is available!"))
        end
        else
        begin
            position = viz_event_.transaction.data.data.size() - 1;
            data     = get_data_string(viz_event_.transaction.data.data[position]);
            user     = viz_event_.transaction.data.user[position];

            `VIP_AHB5_RECORD_ADD_ATTRIBUTE(handle_, viz_event_.transaction.address_beats[position], "Address")
            `VIP_AHB5_RECORD_ADD_ATTRIBUTE(handle_, data, "Data")
            `VIP_AHB5_RECORD_ADD_ATTRIBUTE(handle_, success_resp[position], "Resp")
            `VIP_AHB5_RECORD_ADD_ATTRIBUTE(handle_, user, "User")

            `VIP_AHB5_RECORD_END_TRANSACTION(handle_)
        end
`endif
    endfunction : add_data_attributes

    virtual function
    void do_update_transaction(vip_ahb5_transaction_record_item viz_event_);
`ifdef MODEL_TECH
        if (viz_event_.transaction.is_reset_detected())
        begin
            return;
        end
        data_handle = `VIP_AHB5_RECORD_BEGIN_CHILD_TRANSACTION(stream, "DATA", prev_cycle_time, trans_handle)
        if (data_handle == 0)
        begin
            `vip_ahb5_error(("Unable to add new data to ongoing transaction"))
        end
        else
        begin
            add_data_attributes(viz_event_, data_handle);
        end
`endif
    endfunction : do_update_transaction

    virtual function
    memory_payload_t populate_mem_attr(vip_ahb5_transaction trans);
        memory_payload_t mem_attr;

        mem_attr.memory_type = trans.memory_type.name();
        mem_attr.secure_access = trans.secure_transfer.name();
        mem_attr.access_attributes = trans.access_attribute.name();

        return mem_attr;

    endfunction : populate_mem_attr

    virtual function
    other_req_attr_t populate_other_req_attr(vip_ahb5_transaction trans);
        other_req_attr_t other_req_attr;
        vip_ahb5_types::endianness_t endianness;

        other_req_attr.size = trans.transfer_size.name();
        other_req_attr.locked_access = trans.locked_access.name();
        other_req_attr.exclusive = trans.exclusive_transfer.name();
        other_req_attr.exclusive_response = trans.exclusive_response.name();

        endianness = trans.get_endianness();
        other_req_attr.endianness = endianness.name();
        if (trans.a_user.size() > 0)
        begin
            other_req_attr.user = trans.a_user.pop_front();
        end

        return other_req_attr;
    endfunction : populate_other_req_attr

    virtual function
    string get_visualization_colour(visualization_colours_t colour_);
        return visualization_colours[colour_];
    endfunction : get_visualization_colour

    virtual function
    string get_data_string(vip_ahb5_types::dynamic_byte_array_t data_);
        string data_string;

        if (data_.size() > 0)
        begin
            for(int i = data_.size()-1; i>=0; i--)
            begin
                data_string = {data_string, $sformatf("%h",data_[i])};
            end
        end
        else
        begin
            data_string = "";
        end
        return data_string;
    endfunction : get_data_string

endclass : vip_ahb5_transaction_mti_record

`endif


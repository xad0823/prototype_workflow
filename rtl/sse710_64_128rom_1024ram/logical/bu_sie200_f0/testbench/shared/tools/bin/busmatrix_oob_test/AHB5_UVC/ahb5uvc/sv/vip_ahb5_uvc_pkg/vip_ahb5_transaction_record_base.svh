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

`ifndef VIP_AHB5_TRANSACTION_RECORD_BASE_SVH
`define VIP_AHB5_TRANSACTION_RECORD_BASE_SVH


`define CHECK_ENABLED if (!is_enabled()) return;


class vip_ahb5_transaction_record_item extends uvm_object;
    `uvm_object_utils(vip_ahb5_transaction_record_item)

    typedef enum {
        STARTED_TRANSACTION,
        ADD_DATA,
        COMPLETED_TRANSACTION,
        CANCEL_TRANSACTION,
        EMPTY_EVENT
    } event_t;

    event_t                     viz_event;

    realtime                    start_time;
    realtime                    end_time;
    realtime                    data_start_time;
    vip_ahb5_transaction        transaction;

    function
    new(event_t viz_event_ = EMPTY_EVENT);
        viz_event = viz_event_;
    endfunction : new

    virtual function
    void reset(event_t viz_event_ = EMPTY_EVENT);
        viz_event = viz_event_;
        start_time = 0;
        data_start_time = 0;
        end_time = 0;
    endfunction : reset

    function void do_copy(uvm_object rhs);
        vip_ahb5_transaction_record_item source;

        if (!$cast(source, rhs))
        begin
            `vip_ahb5_fatal(("Type mismatch in do_copy for vip_ahb5_transaction_record_item"))
        end

        super.do_copy(rhs);

        viz_event       = source.viz_event;
        start_time      = source.start_time;
        end_time        = source.end_time;
        data_start_time = source.data_start_time;
        transaction.do_copy(source.transaction);
    endfunction : do_copy

endclass : vip_ahb5_transaction_record_item

class vip_ahb5_transaction_record_base extends uvm_component;
    `uvm_component_utils(vip_ahb5_transaction_record_base)

    protected integer stream;

    protected integer new_trans_handle;

    protected integer trans_handle;

    protected integer data_handle;

    protected bit enabled;

    protected event new_event;

    protected realtime current_time;

    protected realtime prev_cycle_time;

    protected vip_ahb5_transaction_record_item temp_viz_event;

    protected vip_ahb5_transaction_record_item new_temp_viz_event;


    function
    new(string name, uvm_component parent);
        super.new(name, parent);
        stream          = 0;
        current_time    = 0;
        prev_cycle_time = 0;
    endfunction : new

    virtual function
    void build_phase(uvm_phase phase);
        super.build_phase(phase);

    endfunction : build_phase

    virtual task
    run_phase(uvm_phase phase);

        if (enabled && (stream == 0))
        begin

           `VIP_AHB5_NEW(temp_viz_event, ())
           `VIP_AHB5_NEW(temp_viz_event.transaction, ())
           `VIP_AHB5_NEW(new_temp_viz_event, ())
           `VIP_AHB5_NEW(new_temp_viz_event.transaction, ())

            open_recording_stream();
        end

        wait (stream !== 0);
        run_recording();
    endtask : run_phase

    static function
    vip_ahb5_transaction_record_base create_default(string subcomponent,
                                                    uvm_component parent);
        string path;
        uvm_object_wrapper proxy;

        path = {parent.get_full_name(), ".", subcomponent};
        proxy = factory.find_override_by_name("vip_ahb5_transaction_record_base", path);

        if ((proxy == null) ||
            (proxy.get_type_name() == "vip_ahb5_transaction_record_base"))
        begin
            string default_transaction_if_;
            vip_ahb5_transaction_record_base intf;
            uvm_component component;
`ifdef MODEL_TECH
            default_transaction_if_ = "vip_ahb5_transaction_mti_record";
`else
            default_transaction_if_ = "vip_ahb5_transaction_record_base";
`endif
            component = factory.create_component_by_name(default_transaction_if_,
                                                         "",
                                                         subcomponent,
                                                         parent);
            if ((component != null) && ($cast(intf, component) != 0))
            begin
                parent.uvm_report_info("vip_ahb5_transaction_record_base",
                    {"Using default transaction interface of ", default_transaction_if_, " for ",  path},
                    UVM_HIGH);
                return intf;
            end
            else
            begin
                factory.set_inst_override_by_name("vip_ahb5_transaction_record_base",
                                                  default_transaction_if_,
                                                  path);
            end
        end

        return vip_ahb5_transaction_record_base::type_id::create(subcomponent, parent);
    endfunction : create_default



    virtual function
    void record_new_request(vip_ahb5_types::request_beat_struct_t new_req_);
    begin
        `CHECK_ENABLED

        new_temp_viz_event.transaction.request_beats.delete();
        new_temp_viz_event.transaction.request_beats.push_back(new_req_);
        new_temp_viz_event.transaction.populate_request();
        new_temp_viz_event.start_time = $realtime;
        new_temp_viz_event.viz_event = vip_ahb5_transaction_record_item::STARTED_TRANSACTION;

        -> new_event;

    end
    endfunction : record_new_request

    virtual function
    void record_data(vip_ahb5_types::vip_ahb5_data_struct_t data_,
                     vip_ahb5_types::response_beat_struct_t resp_[$]);

        `CHECK_ENABLED

        temp_viz_event.transaction.data = data_;
        temp_viz_event.transaction.response_beats = resp_;
        temp_viz_event.transaction.populate_response();
        temp_viz_event.viz_event = vip_ahb5_transaction_record_item::ADD_DATA;

        -> new_event;
    endfunction : record_data

    virtual function
    void record_complete_transaction(vip_ahb5_transaction trans_);
        `CHECK_ENABLED

        temp_viz_event.transaction.do_copy(trans_);
        temp_viz_event.end_time = $realtime;
        temp_viz_event.viz_event = vip_ahb5_transaction_record_item::COMPLETED_TRANSACTION;

        -> new_event;
    endfunction : record_complete_transaction

    virtual function
    void clear_visualization_item(vip_ahb5_transaction_record_item viz_event_);
        `CHECK_ENABLED

        viz_event_.viz_event = vip_ahb5_transaction_record_item::EMPTY_EVENT;
        viz_event_.start_time = 0;
        viz_event_.end_time = 0;
        viz_event_.transaction.address_beats.delete();
        viz_event_.transaction.response_beats.delete();
        viz_event_.transaction.data.data.delete();
    endfunction : clear_visualization_item

    virtual function
    void open_recording_stream();
    endfunction : open_recording_stream

    virtual function
    void close_recording_stream();
    endfunction : close_recording_stream

    virtual function
    void do_new_transaction(vip_ahb5_transaction_record_item viz_event_);
        `vip_ahb5_error(("Transaction visualisation has not been defined"))
    endfunction : do_new_transaction

    virtual function
    void do_completed_transaction(vip_ahb5_transaction_record_item viz_event_);
        `vip_ahb5_error(("Transaction visualisation has not been defined"))
    endfunction : do_completed_transaction

    virtual function
    void do_cancel_transaction(vip_ahb5_transaction_record_item viz_event_);
        `vip_ahb5_error(("Transaction visualisation has not been defined"))
    endfunction : do_cancel_transaction

    virtual function
    void do_update_transaction(vip_ahb5_transaction_record_item viz_event_);
        `vip_ahb5_error(("Transaction visualisation has not been defined"))
    endfunction : do_update_transaction


    virtual function
    integer create_transaction_handle(vip_ahb5_transaction_record_item viz_event_);
        return 0;
    endfunction : create_transaction_handle

    virtual function
    void free_transaction_handle(vip_ahb5_transaction_record_item viz_event_,
                                 integer handle_);
    endfunction : free_transaction_handle

    virtual function
    void process_events();
        `vip_ahb5_error(("Transaction visualisation has not been defined"))
    endfunction : process_events

    virtual task
    run_recording();
        forever
        begin
            @new_event;
            if (new_temp_viz_event.viz_event != vip_ahb5_transaction_record_item::EMPTY_EVENT)
            begin
                temp_viz_event.do_copy(new_temp_viz_event);
                do_new_transaction(temp_viz_event);
                temp_viz_event.viz_event = vip_ahb5_transaction_record_item::EMPTY_EVENT;
                clear_visualization_item(new_temp_viz_event);
            end
            if (temp_viz_event.viz_event != vip_ahb5_transaction_record_item::EMPTY_EVENT)
            begin
                case (temp_viz_event.viz_event)
                    vip_ahb5_transaction_record_item::ADD_DATA :
                    begin
                        do_update_transaction(temp_viz_event);
                    end
                    vip_ahb5_transaction_record_item::COMPLETED_TRANSACTION :
                    begin
                        do_completed_transaction(temp_viz_event);
                    end
                    vip_ahb5_transaction_record_item::CANCEL_TRANSACTION :
                    begin
                        do_cancel_transaction(temp_viz_event);
                    end
                    default :
                    begin
                        `vip_ahb5_error(("STARTED_TRANSACTION state detected on ongoing transaction!"))
                    end
                endcase
                temp_viz_event.viz_event = vip_ahb5_transaction_record_item::EMPTY_EVENT;
            end
        end
    endtask: run_recording

    virtual function
    void get_time_on_clk_edge();
        prev_cycle_time = current_time;
        current_time    = $realtime;
    endfunction : get_time_on_clk_edge

`VIP_AHB5_FLAG_ACCESSOR(enabled)

endclass : vip_ahb5_transaction_record_base

`endif


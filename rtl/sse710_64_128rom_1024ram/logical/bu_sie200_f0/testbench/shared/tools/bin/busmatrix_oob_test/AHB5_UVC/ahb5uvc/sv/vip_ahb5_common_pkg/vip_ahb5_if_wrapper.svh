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

`ifndef VIP_AHB5_IF_WRAPPER_SVH
`define VIP_AHB5_IF_WRAPPER_SVH


virtual class vip_ahb5_if_wrapper extends uvm_object;

    int unsigned default_slave;

    vip_ahb5_types::idle_mode_t idle_mode;

    pure virtual task drive_request_beat(vip_ahb5_types::request_beat_struct_t tx_request);

    pure virtual task start_transfer(vip_ahb5_types::request_beat_struct_t tx_request);

    pure virtual task sample_start_of_transfer(output vip_ahb5_types::request_beat_struct_t rx_req);

    pure virtual task sample_transfer(output vip_ahb5_types::request_beat_struct_t rx_req);

    pure virtual task drive_data_beat(bit[7:0]data[],
                                      vip_ahb5_types::hdatauser_t data_user);

    pure virtual task drive_response_beat(vip_ahb5_types::response_beat_struct_t tx_response);

    pure virtual task sample_read_data(output bit[7:0]data[],
                                       output vip_ahb5_types::hdatauser_t user);

    pure virtual task sample_write_data(output bit[7:0]data[],
                                        output vip_ahb5_types::hdatauser_t user);

    pure virtual function int unsigned get_data_byte_width();

    pure virtual function int unsigned get_number_of_slaves();

    pure virtual task drive_bus_idle(vip_ahb5_types::idle_mode_t mode);

    pure virtual task drive_request_idle(vip_ahb5_types::idle_mode_t mode);

    pure virtual task drive_data_idle(vip_ahb5_types::idle_mode_t mode);

    pure virtual task wait_for_ready();

    pure virtual task sample_response(output vip_ahb5_types::response_beat_struct_t rx_resp);

    pure virtual task clk_sync(int unsigned num_clocks);

    pure virtual task wait_for_reset(output bit reset);

    pure virtual task wait_for_reset_exit();

    pure virtual function void set_default_slave(int unsigned id_);

    pure virtual function int unsigned get_default_slave();

    pure virtual function void set_idle_mode(vip_ahb5_types::idle_mode_t idle_mode_);

    pure virtual function vip_ahb5_types::idle_mode_t get_idle_mode();


endclass : vip_ahb5_if_wrapper


`endif

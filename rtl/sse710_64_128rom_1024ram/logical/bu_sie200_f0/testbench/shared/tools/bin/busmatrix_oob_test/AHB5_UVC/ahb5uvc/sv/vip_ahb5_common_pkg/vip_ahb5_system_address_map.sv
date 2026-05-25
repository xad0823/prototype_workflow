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

`ifndef VIP_AHB5_SYSTEM_ADDRESS_MAP
`define VIP_AHB5_SYSTEM_ADDRESS_MAP

class vip_ahb5_system_address_map extends uvm_component;
    `uvm_component_utils(vip_ahb5_system_address_map)

    vip_ahb5_types::address_range_struct_t address_map[int unsigned][$];

    function new(string name = "vip_ahb5_system_address_map",uvm_component parent=null);
        super.new(name,parent);
    endfunction : new

    function void register_address_range(vip_ahb5_types::address_range_struct_t address_range,int unsigned slave_id);

        address_map[slave_id].push_back(address_range);
        `vip_ahb5_info(("Range Defined :\nSlave ID : %0d \nStart address : %0h\nEnd Address : %0h\nMem Type : %s",slave_id,
                                                                                                                  address_range.start_address,
                                                                                                                  address_range.end_address,
                                                                                                                  address_range.memory_type.name()),UVM_DEBUG)
    endfunction : register_address_range

    function int get_slave_id(vip_ahb5_types::address_t address, vip_ahb5_types::access_attr_t access_attr);
        int unsigned q_[$];
        int unsigned slave_id;
        if(address_map.first(slave_id)) begin
            do begin
                if(query_address_range_queue(address_map[slave_id],address, access_attr) == 1) begin
                    q_.push_back(slave_id);
                end
            end
            while(address_map.next(slave_id));
        end

        if(q_.size()== 0) begin
            `vip_ahb5_warning(("address('h%0h) is not in any range provided in System address map",address))
            return -1;
        end
        else begin
            `vip_ahb5_info(("Slave ID('d%0d) is selected as per Address('h%0h)",q_[0],address),UVM_DEBUG)
            return q_[0];
        end
    endfunction : get_slave_id

    function bit query_address_range_queue(vip_ahb5_types::address_range_struct_t q_[$],
                                           vip_ahb5_types::address_t address,
                                           vip_ahb5_types::access_attr_t access_attr,
                                           bit return_idx=0);
        bit signed[31:0] return_q_[$];
        return_q_ = q_.find_first_index with ((item.start_address <= address) &&
                                              (item.end_address >= address)   &&
                                              (item.access_type == access_attr) );
        if(return_q_.size()== 0) begin
            return 0;
        end
        else begin
            if(return_idx)
                return return_q_[0];
            else
                return 1;
        end
    endfunction : query_address_range_queue

    function vip_ahb5_types::memory_v8_t get_memory_type(vip_ahb5_types::address_t address,
                                                         vip_ahb5_types::access_attr_t access_attr);
        int slave_id;
        int queue_id;
        slave_id = this.get_slave_id(address, access_attr);
        queue_id = this.query_address_range_queue(address_map[slave_id], address, access_attr, 1);
        `vip_ahb5_info(("queue ID('d%0d) is selected as per Address('h%0h)",queue_id,address),UVM_DEBUG)
        return address_map[slave_id][queue_id].memory_type;
    endfunction : get_memory_type

    function vip_ahb5_types::address_range_struct_t get_address_range(int unsigned slave_id);
        if(address_map.exists(slave_id)) begin
            return address_map[slave_id][0];
        end
        else begin
            `vip_ahb5_error(("Address Map(SAM) doesn't have entry for Slave ID 'd%0d",slave_id))
        end
    endfunction : get_address_range

endclass : vip_ahb5_system_address_map

`endif

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

`ifndef VIP_AHB5_EXCLUSIVE_MONITOR_SVH
`define VIP_AHB5_EXCLUSIVE_MONITOR_SVH


class vip_ahb5_exclusive_address;

    vip_ahb5_types::address_t address;

    vip_ahb5_types::size_t transfer_size;

    int unsigned master_id;

    vip_ahb5_types::burst_t burst_type;

    vip_ahb5_types::ahb5_prot_t prot;

    vip_ahb5_types::access_attr_t secure_trans;

    vip_ahb5_types::address_t start_address;

    vip_ahb5_types::address_t end_address;

    function new(vip_ahb5_transaction transaction_);
        address       = transaction_.get_address();
        transfer_size = transaction_.get_transfer_size();
        prot          = transaction_.get_protection();
        secure_trans  = transaction_.get_secure_transfer();
        burst_type    = transaction_.get_burst_type();
        master_id     = transaction_.get_exclusive_master_id();

        start_address = address;
        end_address   = (start_address + vip_ahb5_types::address_t'((1<<transfer_size)-1));
    endfunction: new

endclass : vip_ahb5_exclusive_address

class vip_ahb5_exclusive_monitor extends uvm_object;

    `uvm_object_utils(vip_ahb5_exclusive_monitor)

    protected vip_ahb5_exclusive_address active_addresses[$];

    function new(string name = "vip_ahb5_exclusive_monitor");
        super.new(name);
    endfunction: new


    virtual function
    void add_exclusive_read(vip_ahb5_transaction transaction);

        if(master_id_exists(transaction.get_exclusive_master_id()))
        begin
            remove_exclusive_by_id(transaction.get_exclusive_master_id());
        end
        add_exclusive(transaction);
    endfunction: add_exclusive_read

    virtual function
    void update_monitor_on_write(vip_ahb5_transaction transaction);
        if(overlapping_address_exists(transaction.get_address(),
                                      transaction.get_transfer_size())
           )
        begin
            remove_exclusive_by_address(transaction.get_address(),
                                        transaction.get_transfer_size()
                                        );
        end
    endfunction: update_monitor_on_write

    virtual function
    vip_ahb5_types::excl_response_t get_response_for_exclusive_write(vip_ahb5_transaction transaction);
        vip_ahb5_types::excl_response_t excl_resp;

        if(exact_exclusive_exists(transaction)
           )
        begin
            remove_exclusive_by_address(transaction.get_address(),
                                        transaction.get_transfer_size());
            excl_resp = vip_ahb5_types::EXCL_OKAY;
            return excl_resp;
        end

        excl_resp = vip_ahb5_types::EXCL_FAIL;
        return excl_resp;
    endfunction: get_response_for_exclusive_write


    virtual function
    void add_exclusive(vip_ahb5_transaction transaction_);
        vip_ahb5_exclusive_address excl_addr_;

        excl_addr_ = new(transaction_);

        active_addresses.push_back(excl_addr_);

    endfunction: add_exclusive

    virtual function
    void remove_exclusive_by_address(vip_ahb5_types::address_t address_,
                                     vip_ahb5_types::size_t transfer_size_
                                    );
        vip_ahb5_types::address_t start_address;
        vip_ahb5_types::address_t end_address;
        int indices[$];

        start_address = address_;
        end_address   = (start_address + vip_ahb5_types::address_t'((1<<transfer_size_)-1));

        indices = active_addresses.find_index with((address_      == item.address)||
                                                   (start_address >= item.start_address)||
                                                   (end_address   <= item.end_address)
                                                   );
        if(indices.size() >0)
        begin
            for(int i =(indices.size()-1);i>=0;--i)
            begin
                int unsigned index;
                index = indices[i];
                active_addresses.delete(index);
            end
        end
    endfunction: remove_exclusive_by_address

    virtual function
    void remove_exclusive_by_id(int unsigned master_id_);
        int indices[$];

        indices = active_addresses.find_index with(master_id_ == item.master_id);
        if(indices.size() >0)
        begin
            for(int i =(indices.size()-1);i>=0;--i)
            begin
                int unsigned index;
                index = indices[i];
                active_addresses.delete(index);
            end
        end
    endfunction: remove_exclusive_by_id

    virtual function
    bit exact_exclusive_exists(vip_ahb5_transaction transaction_);
        int indices[$];

        indices = active_addresses.find_index with((transaction_.get_address()             == item.address      )&&
                                                   (transaction_.get_transfer_size()       == item.transfer_size)&&
                                                   (transaction_.get_protection()          == item.prot         )&&
                                                   (transaction_.get_secure_transfer()     == item.secure_trans )&&
                                                   (transaction_.get_burst_type()          == item.burst_type   )&&
                                                   (transaction_.get_exclusive_master_id() == item.master_id)
                                                   );
        return (indices.size() >0);
    endfunction: exact_exclusive_exists

    virtual function
    bit overlapping_address_exists(vip_ahb5_types::address_t address_,
                                   vip_ahb5_types::size_t transfer_size_);
        vip_ahb5_types::address_t start_address;
        vip_ahb5_types::address_t end_address;
        int indices[$];

        start_address = address_;
        end_address   = (start_address + vip_ahb5_types::address_t'((1<<transfer_size_)-1));

        indices = active_addresses.find_index with((address_      == item.address)||
                                                   (start_address >= item.start_address)||
                                                   (end_address   <= item.end_address)
                                                   );
        return (indices.size() >0);
    endfunction: overlapping_address_exists

    virtual function
    bit master_id_exists(int unsigned master_id_);
        int indices[$];

        indices = active_addresses.find_index with (master_id_ == item.master_id);

        return (indices.size() >0);
    endfunction: master_id_exists

    virtual function
    void clear_active_addresses();
        active_addresses = '{};
    endfunction: clear_active_addresses


endclass :vip_ahb5_exclusive_monitor

`endif

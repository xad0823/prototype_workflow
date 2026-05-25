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

`ifndef VIP_AHB5_MEMORY_MODEL_SVH
`define VIP_AHB5_MEMORY_MODEL_SVH


class vip_ahb5_memory_model extends uvm_component;

    `uvm_component_utils(vip_ahb5_memory_model)

    uvm_pool #(vip_ahb5_types::secure_address_t,vip_ahb5_memory_element) memory;

    int unsigned data_byte_width;

    vip_ahb5_types:: memory_mode_t default_mode;

    vip_ahb5_types:: error_mode_t default_error_mode;

    bit corrupt_data_on_error;

    bit corrupt_read_data;

    bit create_mem_on_read;

    bit[7:0] default_data;

    local int unsigned byte_length;

    function new(string name = "vip_ahb5_memory_model",uvm_component parent = null);
        super.new(name,parent);
        memory = new("memory");
        default_mode = vip_ahb5_types::MEMORY_MODE_RANDOM;
        default_error_mode = vip_ahb5_types::ERROR_MODE_OKAY;
        set_default_data(8'hAA);
        set_create_mem_on_read(1'b1);
    endfunction : new


    function vip_ahb5_memory_element create_memory_element();
        vip_ahb5_memory_element mem_element_ ;
        mem_element_ = new("");
        return mem_element_ ;
    endfunction : create_memory_element

    function bit get_data_error();
        bit error;
        case(default_error_mode)
            vip_ahb5_types::ERROR_MODE_RANDOM:
                begin
                    if (!std::randomize(error))
                    begin
                          `vip_ahb5_fatal(("Randomization failed for error generation"))
                    end
                end
            vip_ahb5_types::ERROR_MODE_OKAY:
                begin
                    error = 1'b0;
                end
            vip_ahb5_types::ERROR_MODE_ERROR:
                begin
                    error = 1'b1;
                end
        endcase

        return error;
    endfunction:get_data_error

    function void initialize_mem(vip_ahb5_memory_element mem);
        bit [7:0] rand_data;
        vip_ahb5_types::mem_unit_struct_t data_struct;

        case(default_mode)
            vip_ahb5_types::MEMORY_MODE_RANDOM:
                begin
                    foreach(data_struct.data[i])
                    begin
                        if (!std::randomize(rand_data))
                        begin
                          `vip_ahb5_fatal(("Randomization failed for data"))
                        end
                        else
                        begin
                            data_struct.data[i] = rand_data;
                        end
                    end
                end
            vip_ahb5_types::MEMORY_MODE_DEFAULT:
                begin
                    foreach(data_struct.data[i]) begin
                        data_struct.data[i] = default_data;
                    end
                end
        endcase
        data_struct.error = get_data_error();
        mem.write_data(data_struct,1'b0);
    endfunction : initialize_mem


    virtual function void write_data(vip_ahb5_types::address_t address,
                                  vip_ahb5_types::access_attr_t secure,
                                  bit byte_enable[],
                                  bit[7:0] wdata[],
                                  bit error_);
        vip_ahb5_memory_element mem_element_;
        vip_ahb5_types::mem_unit_struct_t mem_struct;
        vip_ahb5_types::secure_address_t mem_address;
        bit store_prev_data;
        bit skip_write_data;

        if(error_) begin
            if(corrupt_data_on_error)begin
                foreach(wdata[i]) begin
                    wdata[i] = ~wdata[i];
                end
            end
            else begin
                skip_write_data = 1;
            end
        end

        if(skip_write_data != 1) begin
            mem_address = vip_ahb5_types::get_secure_address(secure,address);
            for(int i =0; i< wdata.size();i++) begin
                if(byte_enable[i]) begin
                    if(!memory.exists(mem_address)) begin
                        mem_element_ = create_memory_element();
                    end else begin
                        mem_element_ = memory.get(mem_address);
                        store_prev_data = 1'b1;
                    end
                    mem_struct.data = wdata[i];
                    mem_struct.error = error_;
                    mem_element_.write_data(mem_struct,store_prev_data);
                    memory.add((mem_address),mem_element_);
                    `vip_ahb5_info(( "Memory write at address %0h, data %0h, error = %0h", mem_address,wdata[i],error_),UVM_HIGH)
                    mem_address++;
                 end
            end
        end
    endfunction :write_data


    virtual function void read_data(vip_ahb5_types::address_t address,
                                    vip_ahb5_types::access_attr_t secure,
                                    output bit[7:0] rdata[],
                                    output bit error_);
       vip_ahb5_memory_element mem_element_;
       vip_ahb5_types::mem_unit_struct_t mem_struct;
       vip_ahb5_types::secure_address_t mem_addr;

       mem_addr = vip_ahb5_types::get_secure_address(secure, address);

        rdata = new[get_byte_length()];

        for(int i =0;i<get_byte_length();++i) begin
            if(!memory.exists(mem_addr+i)) begin
                if(get_create_mem_on_read()) begin
                    mem_element_ = create_memory_element();
                    initialize_mem(mem_element_);
                    memory.add(mem_addr+i,mem_element_);
                end
            end else begin
                mem_element_ = memory.get(mem_addr+i);
            end

            if(mem_element_ != null)
            begin
                mem_struct =  mem_element_.read_data();
                if(get_corrupt_read_data()) begin
                    rdata[i] = ~mem_struct.data;
                    error_ = 1;
                end
                else begin
                    rdata[i] = mem_struct.data;
                    error_ |= mem_struct.error;
                end
            end
            else
            begin
                rdata[i] = 8'h00;
            end
            `vip_ahb5_info(( "Memory read from address %0h, data %0h, error = %0h", address+i,rdata[i],error_),UVM_HIGH)
        end
    endfunction : read_data

    `VIP_AHB5_ACCESSOR(vip_ahb5_types::memory_mode_t,default_mode)
    `VIP_AHB5_ACCESSOR(int unsigned, byte_length)
    `VIP_AHB5_FLAG_ACCESSOR(create_mem_on_read)
    `VIP_AHB5_FLAG_ACCESSOR(corrupt_data_on_error)
    `VIP_AHB5_ACCESSOR(bit[7:0],default_data)
    `VIP_AHB5_FLAG_ACCESSOR(corrupt_read_data)

endclass : vip_ahb5_memory_model


`endif

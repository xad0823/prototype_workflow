// *********************************************************************
//  The confidential and proprietary information contained in this file may
//  only be used by a person authorised under and to the extent permitted
//  by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//             (C) COPYRIGHT 2015-2016 ARM Limited or its affiliates.
//                 ALL RIGHTS RESERVED
//
//  This entire notice must be reproduced on all copies of this file
//  and copies of this file may only be made by a person if such person is
//  permitted to do so under the terms of a subsisting license agreement
//  from ARM Limited or its affiliates.
//
//   Revision            : 3ed9556
//   Checked In          : Mon Sep 12 15:21:46 2016 +0100
//
//   Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
// *********************************************************************

`ifndef VIP_AHB5_MASTER_SEQUENCE_SVH
`define VIP_AHB5_MASTER_SEQUENCE_SVH

class gbusm_vip_ahb5_master_range_seq extends vip_ahb5_issuer_sequence;
    `uvm_object_utils(gbusm_vip_ahb5_master_range_seq)



    vip_ahb5_types::address_t start_addr,  end_addr;


        function new(string name = "gbusm_vip_ahb5_master_range_seq");
            super.new(name);
        endfunction : new


    function void set_adress_range( addr_range addr);
      start_addr=addr.start_addr;
      end_addr= addr.end_addr;
    endfunction : set_adress_range


    function vip_ahb5_types::size_t get_seq_transfer_size();
      vip_ahb5_types::size_t retvar;
      unique case(DATA_WIDTH)
        8:      retvar = vip_ahb5_types::SIZE_0;
        16:     retvar = vip_ahb5_types::SIZE_1;
        32:     retvar = vip_ahb5_types::SIZE_2;
        64:     retvar = vip_ahb5_types::SIZE_3;
        128:    retvar = vip_ahb5_types::SIZE_4;
        256:    retvar = vip_ahb5_types::SIZE_5;
        512:    retvar = vip_ahb5_types::SIZE_6;
        1024:   retvar = vip_ahb5_types::SIZE_7;
        default:  retvar = vip_ahb5_types::SIZE_0;
      endcase

      return retvar;

    endfunction : get_seq_transfer_size

        virtual task body();
            super.body();



            start_item(request);
            request.set_terminate_burst_on_error(1);
            `uvm_info(get_name(),"[PT]Transaction started",UVM_LOW)
        void'(request.randomize() with {
                      request_type        == vip_ahb5_types::REQUEST_WRITE;
                      exclusive_transfer  == vip_ahb5_types::TRANS_ATTR_NONEXCL;
                      address       == start_addr;
                      transfer_size     == get_seq_transfer_size();
                      secure_transfer   ==  vip_ahb5_types::ACCESS_ATTR_NONSECURE;
                      burst_type          == vip_ahb5_types::BURST_SINGLE;

                    });
            finish_item(request);
            get_response(response);
            `uvm_info(get_name(),"[PT]Transaction finished",UVM_LOW)


            start_item(request);
            request.set_terminate_burst_on_error(1);
            `uvm_info(get_name(),"[PT]Transaction started",UVM_LOW)
        void'(request.randomize() with {
                      request_type        == vip_ahb5_types::REQUEST_READ;
                      exclusive_transfer  == vip_ahb5_types::TRANS_ATTR_NONEXCL;
                      address       == start_addr;
                      transfer_size     == get_seq_transfer_size();
                      secure_transfer   ==  vip_ahb5_types::ACCESS_ATTR_NONSECURE;
                      burst_type          == vip_ahb5_types::BURST_SINGLE;

                    });
            finish_item(request);
            get_response(response);
            `uvm_info(get_name(),"[PT]Transaction finished",UVM_LOW)




            start_item(request);
            request.set_terminate_burst_on_error(1);
            `uvm_info(get_name(),"[PT]Transaction started",UVM_LOW)
        void'(request.randomize() with {
                      request_type        == vip_ahb5_types::REQUEST_WRITE;
                      exclusive_transfer  == vip_ahb5_types::TRANS_ATTR_NONEXCL;
                      address       == end_addr;
                      transfer_size     == get_seq_transfer_size();
                      secure_transfer   ==  vip_ahb5_types::ACCESS_ATTR_NONSECURE;
                      burst_type          == vip_ahb5_types::BURST_SINGLE;

                    });
            finish_item(request);
            get_response(response);
            `uvm_info(get_name(),"[PT]Transaction finished",UVM_LOW)



            start_item(request);
            request.set_terminate_burst_on_error(1);
            `uvm_info(get_name(),"[PT]Transaction started",UVM_LOW)
        void'(request.randomize() with {
                      request_type        == vip_ahb5_types::REQUEST_READ;
                      exclusive_transfer  == vip_ahb5_types::TRANS_ATTR_NONEXCL;
                      address       == end_addr;
                      transfer_size     == get_seq_transfer_size();
                      secure_transfer   ==  vip_ahb5_types::ACCESS_ATTR_NONSECURE;
                      burst_type          == vip_ahb5_types::BURST_SINGLE;

                    });
            finish_item(request);
            get_response(response);
            `uvm_info(get_name(),"[PT]Transaction finished",UVM_LOW)




      for (int i=0; i<5 ; i++) begin


              start_item(request);
              request.set_terminate_burst_on_error(1);
                `uvm_info(get_name(),"[PT]Transaction started",UVM_LOW)
          void'(request.randomize() with {
                        request_type        == vip_ahb5_types::REQUEST_READ;
                        exclusive_transfer  == vip_ahb5_types::TRANS_ATTR_NONEXCL;
                        address           >= start_addr;
                        address       <= end_addr;
                        transfer_size     == get_seq_transfer_size();
                        secure_transfer   ==  vip_ahb5_types::ACCESS_ATTR_NONSECURE;
                        burst_type          == vip_ahb5_types::BURST_SINGLE;

                      });
              finish_item(request);
              get_response(response);
                `uvm_info(get_name(),"[PT]Transaction finished",UVM_LOW)


      end


        endtask : body

endclass : gbusm_vip_ahb5_master_range_seq


class gbusm_vip_ahb5_master_sequence extends vip_ahb5_issuer_sequence;
    `uvm_object_utils(gbusm_vip_ahb5_master_sequence)

  int master_num=0;
  string scope_name = "";
  busmtrx_addr_map addr_map;
  addr_range_array master_addresses;
    gbusm_vip_ahb5_master_range_seq range_test_seq [];

    function new(string name="gbusm_vip_ahb5_master_sequence");
        super.new(name);
    endfunction

  function void set_master_num(int master_number);
    this.master_num = master_number;
  endfunction


  function void fill_sequence_array();

    if( scope_name == "" ) begin
        scope_name = get_full_name();
      end

    if(!uvm_config_db#(busmtrx_addr_map)::get(null,"","addr_map",addr_map))
    begin
            `uvm_fatal("ADDR_MAP", "Address map not set.")
        end

    master_addresses = addr_map.get_master_ranges(master_num);
    range_test_seq=new[master_addresses.size];

    foreach (master_addresses[i])begin
      range_test_seq[i]=gbusm_vip_ahb5_master_range_seq::type_id::create($sformatf("gbusm_vip_ahb5_master_range_seq%0d",i));
      range_test_seq[i].set_adress_range(master_addresses[i]);
    end


  endfunction : fill_sequence_array

    virtual task body();
    fill_sequence_array();

    foreach (this.range_test_seq[i])begin
      automatic int idx = i;
      fork
        this.range_test_seq[idx].start(m_sequencer,this);
      join_none
    end
    wait fork;
    #50ns;



    endtask

endclass

`endif

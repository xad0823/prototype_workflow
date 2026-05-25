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
`ifndef VIP_GGVE_ENV_SVH
`define VIP_GGVE_ENV_SVH


class gbusm_env extends uvm_env;
    `ifdef NUM_AHB5_MASTERS
       vip_ahb5_agent ahb5_master_agent [0:`NUM_AHB5_MASTERS-1];
    `endif
    `ifdef NUM_AHB5_SLAVES
       vip_ahb5_agent ahb5_slave_agent [0:`NUM_AHB5_SLAVES-1];
    `endif
    `ifdef NUM_AHB5_MASTERS
       vip_ahb5_configuration ahb5_master_cfg [0:`NUM_AHB5_MASTERS-1];
    `endif
    `ifdef NUM_AHB5_SLAVES
    vip_ahb5_configuration ahb5_slave_cfg [0:`NUM_AHB5_SLAVES-1];
    `endif
    `ifdef NUM_AHB5_MASTERS
    `endif


    vip_ahb5_control_knobs ahb5_slave_knobs;
    busmtrx_ref_model ref_model;

    busmtrx_addr_map addr_map;

    uvm_table_printer printer;


    `uvm_component_utils(gbusm_env)

    function new(string name = "", uvm_component parent = null);
        super.new(name,parent);
        `ifdef NUM_AHB5_MASTERS
           for(int i=0; i < `NUM_AHB5_MASTERS; i++) begin
              ahb5_master_cfg[i] = new({"ahb5_master_cfg",$sformatf("%0d",i)});
              ahb5_master_cfg[i].set_enable_coverage(0);
           end
        `endif
        `ifdef NUM_AHB5_SLAVES
           for(int i=0; i < `NUM_AHB5_SLAVES; i++) begin
              ahb5_slave_cfg[i] = new({"ahb5_slave_cfg",$sformatf("%0d",i)});
              ahb5_slave_cfg[i].set_enable_coverage(0);
           end
        `endif


        printer = new();
        printer.knobs.depth = 4;
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);



        `ifdef NUM_AHB5_MASTERS
           for(int i=0; i < `NUM_AHB5_MASTERS; i++) begin
           end
        `endif

        ahb5_slave_knobs = vip_ahb5_control_knobs::type_id::create("vip_ahb5_control_knobs");
        ahb5_slave_knobs.set_max_slave_number(32);

        uvm_config_db#(vip_ahb5_control_knobs)::set(null,"m_sequencer","responder_control_knobs",ahb5_slave_knobs);

        ref_model = busmtrx_ref_model::type_id::create( "ref_model", this);



        `ifdef NUM_AHB5_MASTERS
           for(int i=0; i < `NUM_AHB5_MASTERS; i++) begin
              uvm_config_db#(vip_ahb5_configuration)::set(this,{"ahb5_master",$sformatf("%0d",i)},"configuration",ahb5_master_cfg[i]);
              ahb5_master_agent[i] = vip_ahb5_agent::type_id::create({"ahb5_master",$sformatf("%0d",i)},this);
           end
        `endif
        `ifdef NUM_AHB5_SLAVES
           for(int i=0; i < `NUM_AHB5_SLAVES; i++) begin
              uvm_config_db#(vip_ahb5_configuration)::set(this,{"ahb5_slave",$sformatf("%0d",i)},"configuration",ahb5_slave_cfg[i]);
              ahb5_slave_agent[i] = vip_ahb5_agent::type_id::create({"ahb5_slave",$sformatf("%0d",i)},this);
           end
        `endif

   endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        `uvm_info(get_type_name(),
        $sformatf("Printing the test topology :\n%s", this.sprint(printer)), UVM_LOW)
    endfunction


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);


    if(!uvm_config_db#(busmtrx_addr_map)::get(null,"","addr_map",addr_map))
    begin
            `uvm_fatal("ADDR_MAP", "Address map not set.")
        end

        do_master_configuration();
        do_slave_configuration();

        <Ref model connections>

    endfunction


    virtual function void do_master_configuration();
    addr_range_array master_range;
    vip_ahb5_types::address_range_struct_t address_range;
    address_range.memory_type = vip_ahb5_types::MEMORY_V8_NORMAL_NC_nS;
    address_range.access_type = vip_ahb5_types::ACCESS_ATTR_NONSECURE;

       `ifdef NUM_AHB5_MASTERS
          for(int i=0; i < `NUM_AHB5_MASTERS; i++) begin
        master_range =  addr_map.get_master_ranges(i);

      foreach (master_range[j])begin
        address_range.start_address = master_range[j].start_addr;
        address_range.end_address = master_range[j].end_addr;
      end
          end
       `endif
       `ifdef NUM_AHB5_MASTERS
          for(int i=0; i < `NUM_AHB5_MASTERS; i++) begin
             ahb5_master_cfg[i].node_type = vip_ahb5_types::MASTER_NODE;
             ahb5_master_cfg[i].idle_mode = vip_ahb5_types::DRIVE_ZERO;
             ahb5_master_cfg[i].set_support_exclusives(0);
          end
       `endif
    endfunction

    virtual function void do_slave_configuration();
        `ifdef NUM_AHB5_SLAVES
           for(int i=0; i < `NUM_AHB5_SLAVES; i++) begin
              ahb5_slave_cfg[i].node_type = vip_ahb5_types::SLAVE_NODE;
              ahb5_slave_cfg[i].idle_mode = vip_ahb5_types::DRIVE_ZERO;
              ahb5_slave_cfg[i].set_support_exclusives(0);
           end
        `endif
    endfunction

endclass

`endif

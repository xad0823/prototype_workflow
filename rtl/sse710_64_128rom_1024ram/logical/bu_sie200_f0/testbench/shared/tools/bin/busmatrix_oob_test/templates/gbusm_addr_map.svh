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

class busmtrx_addr_map extends uvm_component;
`uvm_component_utils(busmtrx_addr_map)


    addr_range fix_addr_ranges [0:`NUM_AHB5_MASTERS-1][0:`NUM_AHB5_SLAVES-1][];
    addr_range temp_addr_ranges [0:`NUM_AHB5_MASTERS-1][0:`NUM_AHB5_SLAVES-1][];
    addr_range rmp_addr_ranges [0:REMAP_WIDTH-1][0:`NUM_AHB5_MASTERS-1][0:`NUM_AHB5_SLAVES-1][];
    addr_range del_addr_ranges [0:`NUM_AHB5_MASTERS-1][0:`NUM_AHB5_SLAVES-1][];
    int remap_inf [0:`NUM_AHB5_MASTERS-1][0:`NUM_AHB5_SLAVES-1][];
    int del_bits [0:`NUM_AHB5_MASTERS-1][0:`NUM_AHB5_SLAVES-1][][];

    virtual busmtrx_remap_if #(.REMAP_WIDTH(REMAP_WIDTH)) remap_vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);

        <Fill addr range arrays>
    endfunction: new



    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual busmtrx_remap_if#(.REMAP_WIDTH(REMAP_WIDTH)))::get(this,"","remap_vif",remap_vif))
        begin
            `uvm_fatal("REMAP", "Remap interface not set.")
        end
    endfunction


  function int rmp_is_active(int rmp_bit);
        return (remap_vif.REMAP[rmp_bit] == 1'b1) ;
    endfunction

  function int is_influenced(int master_number, int slave_number);
    foreach (remap_inf[master_num, slave_num, a]) begin
            if (master_num == master_number && slave_num == slave_number) begin
                if (rmp_is_active(remap_inf[master_num][slave_num][a])) begin
          return 1;
        end
      end
    end
    return 0;
  endfunction

  function int is_deleted(int master_number, int slave_number, int addr_index);
    foreach (del_bits[m, s, a, d]) begin
      if (m==master_number && s==slave_number && a==addr_index) begin
        if( rmp_is_active(del_bits[m][s][a][d]) ) begin
          return 1;
        end
      end
    end

    return 0;

  endfunction


  function addr_range_array get_master_ranges(int master_number);
    foreach (fix_addr_ranges[m, s, a]) begin
            if (m == master_number) begin
        get_master_ranges = new[get_master_ranges.size()+1](get_master_ranges);
        get_master_ranges[get_master_ranges.size()-1].start_addr = fix_addr_ranges[m][s][a].start_addr;
        get_master_ranges[get_master_ranges.size()-1].end_addr = fix_addr_ranges[m][s][a].end_addr;
        get_master_ranges[get_master_ranges.size()-1].slave_id = s;
            end
        end
    foreach (del_addr_ranges[m, s, a]) begin
            if (m == master_number && !is_deleted(m,s,a)) begin
        get_master_ranges = new[get_master_ranges.size()+1](get_master_ranges);
        get_master_ranges[get_master_ranges.size()-1].start_addr = del_addr_ranges[m][s][a].start_addr;
        get_master_ranges[get_master_ranges.size()-1].end_addr = del_addr_ranges[m][s][a].end_addr;
        get_master_ranges[get_master_ranges.size()-1].slave_id = s;
            end
        end
        for (int slave_number = 0 ; slave_number < `NUM_AHB5_SLAVES ; slave_number++) begin
      if (is_influenced(master_number,slave_number)) begin
        foreach (rmp_addr_ranges[r, m, s, a]) begin
                if (m == master_number && s == slave_number && rmp_is_active(r) ) begin
            get_master_ranges = new[get_master_ranges.size()+1](get_master_ranges);
            get_master_ranges[get_master_ranges.size()-1].start_addr = rmp_addr_ranges[r][m][s][a].start_addr;
            get_master_ranges[get_master_ranges.size()-1].end_addr = rmp_addr_ranges[r][m][s][a].end_addr;
            get_master_ranges[get_master_ranges.size()-1].slave_id = s;
                end
            end
      end
      else begin
        foreach (temp_addr_ranges[m, s, a]) begin
                if (m == master_number && s == slave_number) begin
            get_master_ranges = new[get_master_ranges.size()+1](get_master_ranges);
            get_master_ranges[get_master_ranges.size()-1].start_addr = temp_addr_ranges[m][s][a].start_addr;
            get_master_ranges[get_master_ranges.size()-1].end_addr = temp_addr_ranges[m][s][a].end_addr;
            get_master_ranges[get_master_ranges.size()-1].slave_id = s;
                end
            end
      end
    end
  endfunction : get_master_ranges


    function bit addr_in_range(vip_ahb5_types::address_t address, addr_range range);
        if (address <= range.end_addr && address >= range.start_addr) begin
            return 1;
        end
        else begin
            return 0;
        end
    endfunction


    function int mst_decode_addr(vip_ahb5_types::address_t address, int master_number);
        int fail = -1;
        foreach (fix_addr_ranges[m, s, a]) begin
            if (m == master_number) begin
                if (addr_in_range(address, fix_addr_ranges[m][s][a])) begin
                    return s;
                end
            end
        end
    foreach (del_addr_ranges[m, s, a]) begin
            if (m == master_number && !is_deleted(m,s,a)) begin
                if (addr_in_range(address, del_addr_ranges[m][s][a])) begin
                    return s;
                end
            end
        end

        for (int slave_number = 0 ; slave_number < `NUM_AHB5_SLAVES ; slave_number++) begin
      if (is_influenced(master_number,slave_number)) begin
          for (int rmp_bit = 0; rmp_bit < REMAP_WIDTH ; rmp_bit++) begin
          if (rmp_is_active(rmp_bit)) begin
                  foreach (rmp_addr_ranges[r, m, s, a]) begin
                    if (r == rmp_bit && s == slave_number && m == master_number) begin
                        if (addr_in_range(address, rmp_addr_ranges[r][m][s][a])) begin
                            return s;
                          end
                      end
                  end
              end
          end
      end
      else begin
          foreach (temp_addr_ranges[master_num, slave_num, addr]) begin
                if (master_num == master_number && slave_num == slave_number) begin
                    if (addr_in_range(address, temp_addr_ranges[master_num][slave_num][addr])) begin
                        return slave_num;
                    end
                end
            end
      end
    end


        `uvm_info("WRONG_ADDRESS", $sformatf("Transaction address is not mapped to any slaves on MASTER %d with address %h", master_number, address), UVM_MEDIUM)
        return fail;
    endfunction
endclass

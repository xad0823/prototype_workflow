// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//               (C) COPYRIGHT 2016 ARM Limited or its affiliates.
//                   ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
// Checked In : Mon Sep 12 15:21:46 2016 +0100
// Revision : 3ed9556
//
// Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
// -----------------------------------------------------------------------------

`ifndef UVM_DATA
`define UVM_DATA

`include "ggve_defines.sv"

class uvm_data extends uvm_object;
`uvm_object_utils(uvm_data)

   typedef bit[7:0] byte_t;

   bit hnonsec_dis;

   bit pstrb_dis;

   bit [31:0] ByteAddress;

   bit [7:0] ByteData;

   bit ByteDirection;

   bit [MASTER_WIDTH-1:0] master_id;

   bit [7:0] ByteSecure;
   bit hnonsec;

   bit [2:0] size;

   bit resp;

   uvm_sequence_item TransactionPnt;

   time AbsolutTime;






   function bit compare(uvm_data obj_);

      bit data_cmp;
      bit hprot_cmp;
      bit hnonsec_cmp;
      bit size_cmp;
      bit resp_cmp;
      bit m_id_cmp;

      if (((this.ByteAddress == obj_.ByteAddress) &&
           (this.ByteData == obj_.ByteData) &&
           (this.ByteDirection == obj_.ByteDirection)) == 1) begin

         data_cmp = 1'b1;

         if (!this.hnonsec_dis) begin
            hnonsec_cmp = (this.hnonsec == obj_.hnonsec);
         end else begin
            hnonsec_cmp = 1'b1;
            `uvm_info(get_type_name(), $sformatf("HNONSEC CMP DISABLED!"), UVM_LOW)
         end

         if (this.ByteSecure[7] == obj_.ByteSecure[7]) begin
            hprot_cmp = (this.ByteSecure[6:0] == obj_.ByteSecure[6:0]);
         end else begin
            hprot_cmp = ( (this.ByteSecure[1] == obj_.ByteSecure[1]) && (!this.ByteSecure[0] == obj_.ByteSecure[0]) );
         end

         if (!obj_.pstrb_dis) begin
            size_cmp = (this.size == obj_.size);
         end else begin
            size_cmp = 1'b1;
         end

         resp_cmp = (this.resp == obj_.resp);

         if (obj_.master_id >= 0) begin
            m_id_cmp = (this.master_id == obj_.master_id);
         end else begin
            m_id_cmp = 1'b1;
         end

      end

      return (data_cmp && hnonsec_cmp && hprot_cmp && size_cmp && resp_cmp);


    endfunction

   function void copy(uvm_object obj_);
      begin
         obj_ = new this;
      end
   endfunction

endclass

`endif

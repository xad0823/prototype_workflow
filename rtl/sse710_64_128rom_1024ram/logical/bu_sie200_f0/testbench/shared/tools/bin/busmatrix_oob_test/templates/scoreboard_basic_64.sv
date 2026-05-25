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

`ifndef SCOREBOARD_BASIC
`define SCOREBOARD_BASIC

`uvm_analysis_imp_decl(_master_ahb5)
`uvm_analysis_imp_decl(_slave_ahb5)



class scoreboard_basic extends uvm_scoreboard;

`uvm_component_utils(scoreboard_basic)

   `ifdef NUM_AHB5_MASTERS
      uvm_analysis_imp_master_ahb5 #(vip_ahb5_transaction, scoreboard_basic) aport_master_ahb5[0:`NUM_AHB5_MASTERS];
   `endif
   `ifdef NUM_AHB5_SLAVES
      uvm_analysis_imp_slave_ahb5 #(vip_ahb5_transaction, scoreboard_basic) aport_slave_ahb5[0:`NUM_AHB5_SLAVES];
   `endif

   uvm_tlm_analysis_fifo #(vip_ahb5_transaction) master_ahb5_fifo;
   uvm_tlm_analysis_fifo #(vip_ahb5_transaction) slave_ahb5_fifo;


   localparam VIP_AHB5_HBURST_WIDTH   =  3;
   localparam VIP_AHB5_HSIZE_WIDTH    =  3;

   protected process master_ahb5_proc = null;
   protected process slave_ahb5_proc  = null;

   uvm_data transaction_ahb5;

   uvm_data master_q[$];
   uvm_data slave_q[$];

   int unsigned burst_length;

   protected bit scbd_enabled;
   protected bit hnonsec_cmp;

   bit [DATA_BYTES-1:0] pstrb;

   bit predict_write = 1'b1;

   protected bit [MASTER_WIDTH-1:0] master_id;

   bit v_addr;


   semaphore extract_ahb5_lock = new(1);

   typedef bit[7:0] d_byte_array_t[];

   typedef d_byte_array_t data_byte_queue_t[$];

   data_byte_queue_t data;

   int idx_q[$];


   vip_ahb5_types::request_t request_type;

   typedef enum bit [VIP_AHB5_HBURST_WIDTH-1:0]
   {
      BURST_SINGLE = 0,
      BURST_INCR   = 1,
      BURST_WRAP4  = 2,
      BURST_INCR4  = 3,
      BURST_WRAP8  = 4,
      BURST_INCR8  = 5,
      BURST_WRAP16 = 6,
      BURST_INCR16 = 7
   } burst_t;

   burst_t burst_type;

   typedef enum bit [VIP_AHB5_HSIZE_WIDTH-1:0]
   {
      SIZE_0 = 0,
      SIZE_1 = 1,
      SIZE_2 = 2,
      SIZE_3 = 3,
      SIZE_4 = 4,
      SIZE_5 = 5,
      SIZE_6 = 6,
      SIZE_7 = 7
   } size_t;

   size_t transfer_size;

   function new (string name, uvm_component parent);
      super.new(name, parent);
      scbd_enabled = 1;
      hnonsec_cmp  = 1;
      master_id    = -1;
   endfunction

   virtual function void write_master_ahb5(vip_ahb5_transaction trans);
      if (scbd_enabled == 1 && !trans.reset_detected) begin
         `uvm_info(get_type_name(),"Analysis Import from AHB5 MASTER Write invoked",UVM_MEDIUM)
         `uvm_info(get_type_name(),$psprintf("Collected transaction is %s",trans.convert2string()),UVM_MEDIUM)
         if (predict_write) begin
           void'(master_ahb5_fifo.try_put(trans));
         end
      end
   endfunction

   virtual function void write_slave_ahb5(vip_ahb5_transaction trans);
      if (scbd_enabled == 1 && !trans.reset_detected) begin
         `uvm_info(get_type_name(),"Analysis Import from AHB5 SLAVE Write invoked",UVM_MEDIUM)
         `uvm_info(get_type_name(),$psprintf("Collected transaction is %s",trans.convert2string()),UVM_MEDIUM)
         void'(slave_ahb5_fifo.try_put(trans));
      end
   endfunction


   virtual function void build_phase (uvm_phase phase);
      super.build_phase(phase);
      `ifdef NUM_AHB5_MASTERS
         for(int i=0; i < `NUM_AHB5_MASTERS; i++) begin
            aport_master_ahb5[i] = new({"aport_master_ahb5",$sformatf("%0d",i)}, this);
         end
         master_ahb5_fifo = new("master_ahb5_fifo", this);
      `endif
      `ifdef NUM_AHB5_SLAVES
         for(int i=0; i < `NUM_AHB5_SLAVES; i++) begin
            aport_slave_ahb5[i] = new({"aport_slave_ahb5",$sformatf("%0d",i)}, this);
         end
         slave_ahb5_fifo  = new("slave_ahb5_fifo", this);
      `endif
   endfunction

  virtual task run_phase (uvm_phase phase);
      enable_stop_interrupt = '1;

      fork
         `ifdef NUM_AHB5_MASTERS
            extract_data_ahb5(master_ahb5_fifo, master_ahb5_proc);
         `endif
         `ifdef NUM_AHB5_SLAVES
            extract_data_ahb5(slave_ahb5_fifo, slave_ahb5_proc);
         `endif
      join_none

   endtask

   task stop (string ph_name);

      if (scbd_enabled == 1'b1) begin
         `uvm_info("SCOREBOARD", "stop task running ...", UVM_LOW);
         kill();
         `uvm_info("SCOREBOARD", "stop task done", UVM_LOW);
      end
   endtask


   virtual function void kill();
      `ifdef NUM_AHB5_MASTERS
         master_ahb5_proc.kill();
      `endif
      `ifdef NUM_AHB5_SLAVES
         slave_ahb5_proc.kill();
      `endif
   endfunction


   protected task extract_data_ahb5(ref uvm_tlm_analysis_fifo#(vip_ahb5_transaction) transaction_fifo, ref process proc);
      vip_ahb5_transaction ahb5_txn;
      forever begin
         proc = process::self();

         if (proc == master_ahb5_proc) begin
            transaction_fifo.get(ahb5_txn);
            extract_ahb5_fields(ahb5_txn, 1);
         end else begin
            transaction_fifo.get(ahb5_txn);
            extract_ahb5_fields(ahb5_txn, 0);
         end
         if ( (master_q.size() != 0) && (slave_q.size() != 0) ) begin
            compare_transactions();
         end
      end
   endtask


   function void compare_transactions();
      uvm_data txn;
      int unsigned k;
      int m_size, s_size;
      bit match;
         k = 0;
         `uvm_info(get_type_name(),$psprintf("COMPARING TRANSACTIONS!"),UVM_DEBUG)

         m_size = master_q.size();
         s_size = slave_q.size();
         for(int i=0; i<m_size; i++) begin
            match = 0;
            txn = master_q.pop_front();
            for(int j=0; j<s_size-k; j++) begin
               if (txn.compare(slave_q[j])) begin
                  k++;
                  slave_q.delete(j);
                  match = 1;
                  break;
               end
            end
            if (match !=1 ) begin
               master_q.push_back(txn);
            end
         end
   endfunction


   protected task extract_ahb5_fields(vip_ahb5_transaction trans, bit is_master);
      int unsigned idx, no_of_transactions;
      int unsigned addr_idx;
      bit [63:0] address, wrap_boundry, addr_msk;
      bit [29:0] tmp_addr;
      bit [7:0] data [];
      bit [7:0] data_byte;
      vip_ahb5_types::response_t resp[];
      bit early_burst_termination;

      bit broken_burst = 1'b0;
      bit empty_q = 1'b0;

      burst_type = burst_t'(trans.burst_type);

      transfer_size = size_t'(trans.transfer_size);

      burst_length = calculate_burst_length(trans);

      extract_ahb5_lock.get();
uvm_report_info("SCOREBOARD", $sformatf("Master Queue Size: %0d", master_q.size()));
uvm_report_info("SCOREBOARD", $sformatf("Slave Queue Size:  %0d", slave_q.size()));
      if (bit'(trans.request_type) != 'b0) begin

         resp = trans.resp;
         for(int i=0; i<burst_length; i++) begin
            data = trans.data.data.pop_front;

            `uvm_info(get_type_name(),$psprintf("DATA SIZE IS %d",data.size()),UVM_DEBUG)
            if (data.size() == 0) begin
               if (is_master) begin
                  uvm_report_info("SCOREBOARD", $sformatf("EARLY BURST TERMINATION!"), UVM_LOW);
                  `uvm_info(get_type_name(),$psprintf("ADDR from early burst termination is %h",address),UVM_DEBUG)
               end
               break;
            end

            for (int j=0; j<(2**(int'(transfer_size))); j++) begin
               transaction_ahb5 = new();

               if ((burst_type == BURST_WRAP4) || (burst_type == BURST_WRAP8) || (burst_type == BURST_WRAP16)) begin
                  wrap_boundry = (trans.address / ((2**transfer_size)*burst_length))*((2**transfer_size)*burst_length) ;

                  address = (trans.address+(2**transfer_size)*i+j);
                  if (address > (wrap_boundry + (2**transfer_size)*burst_length-1)) begin
                     address = address - (2**transfer_size)*burst_length;
                  end
               end else begin
                  address = trans.address+(2**transfer_size)*i+j;
               end
               idx = (i*(2**transfer_size) + int'(trans.address[1:0]) + j) % DATA_BYTES;

               data_byte = data[idx];
               transaction_ahb5.ByteAddress    = address;
               transaction_ahb5.ByteData       = data_byte;
               transaction_ahb5.ByteDirection  = bit'(trans.request_type);
               transaction_ahb5.TransactionPnt = trans;
               transaction_ahb5.AbsolutTime    = trans.finish_time;
               if (!hnonsec_cmp) begin
                  transaction_ahb5.hnonsec_dis = 1'b1;
               end
               transaction_ahb5.ByteSecure     = {1'b1, trans.memory_type, trans.access_attribute};
              `uvm_info(get_type_name(),$psprintf("HPROT[6:0] is %7b",transaction_ahb5.ByteSecure),UVM_DEBUG)
               transaction_ahb5.hnonsec        = trans.secure_transfer;
              `uvm_info(get_type_name(),$psprintf("hnonsec is %2b",transaction_ahb5.hnonsec),UVM_DEBUG)
               transaction_ahb5.size           = trans.transfer_size;
               transaction_ahb5.resp           = resp[i];
              `uvm_info(get_type_name(),$psprintf("RESPONSE IS %2b",resp[i]),UVM_DEBUG)
               transaction_ahb5.master_id      = trans.exclusive_master_id;
              `uvm_info(get_type_name(),$psprintf("MASTER ID IS %4b",trans.exclusive_master_id),UVM_DEBUG)

               if ((is_master == 1) && (i+j == (burst_length-1 + (2**(int'(transfer_size)))-1))) begin
                  empty_q = 1'b1;
               end else begin
                  empty_q = 1'b0;
               end

               if ((v_addr == 1'b1) && (is_master == 1)) begin
                  broken_burst = 1'b1;
               end


               if (!broken_burst) begin
                  if (is_master == 1) begin
                        master_q.push_back(transaction_ahb5);
                  end else begin
                     slave_q.push_back(transaction_ahb5);
                  end
               end else begin
                  uvm_report_info("SCOREBOARD", $sformatf("THE BURST IS INVALID - DROPPING TRANSACTIONS FROM MASTER UNTIL THE END OF BURST!"), UVM_DEBUG);
               end
            end
         end
      end else begin
         addr_msk = {64{1'b1}};
         addr_msk = addr_msk << transfer_size;
         resp = trans.resp;
         for(int i=0; i<burst_length; i++) begin
            data = trans.data.data.pop_front;

            if (data.size() == 0) begin
               if (is_master) begin
                  uvm_report_info("SCOREBOARD", $sformatf("EARLY BURST TERMINATION!"), UVM_LOW);
               end
               break;
            end

            for (int k=0; k<DATA_BYTES; k++) begin
               transaction_ahb5 = new();

               address = trans.address + (2**transfer_size)*i;
               if (transfer_size < 3) begin
                  address = {address[63:2],2'b00} + k%4;
               end else begin
                  address = (address & addr_msk) + k;
               end

               if ((burst_type == BURST_WRAP4) || (burst_type == BURST_WRAP8) || (burst_type == BURST_WRAP16)) begin

                  wrap_boundry = (trans.address / ((2**transfer_size)*burst_length))*((2**transfer_size)*burst_length) ;

                  if (address > (wrap_boundry + (2**transfer_size)*burst_length-1)) begin
                     address = address - (2**transfer_size)*burst_length;
                  end

               end

               idx = k;
               data_byte = data[idx];
               transaction_ahb5.ByteAddress    = address;
               transaction_ahb5.ByteData       = data_byte;
               transaction_ahb5.ByteDirection  = bit'(trans.request_type);
               transaction_ahb5.TransactionPnt = trans;
               transaction_ahb5.AbsolutTime    = trans.finish_time;
               if (!hnonsec_cmp) begin
                  transaction_ahb5.hnonsec_dis = 1'b1;
               end
               transaction_ahb5.ByteSecure     = {1'b1, trans.memory_type, trans.access_attribute};
              `uvm_info(get_type_name(),$psprintf("HPROT[6:0] is %7b",transaction_ahb5.ByteSecure),UVM_DEBUG)
               transaction_ahb5.hnonsec        = trans.secure_transfer;
              `uvm_info(get_type_name(),$psprintf("hnonsec is %2b",transaction_ahb5.hnonsec),UVM_DEBUG)
               transaction_ahb5.size           = trans.transfer_size;
               transaction_ahb5.resp           = resp[i];
              `uvm_info(get_type_name(),$psprintf("RESPONSE IS %2b",resp[i]),UVM_DEBUG)
               transaction_ahb5.master_id      = trans.exclusive_master_id;
              `uvm_info(get_type_name(),$psprintf("MASTER ID IS %4b",trans.exclusive_master_id),UVM_DEBUG)

               if ((is_master == 1) && (i+k == (burst_length-1 + DATA_BYTES-1))) begin
                  empty_q = 1'b1;
               end else begin
                  empty_q = 1'b0;
               end


               if ((v_addr == 1'b1) && (is_master == 1)) begin
                  broken_burst = 1'b1;
               end


               if (!broken_burst) begin
                  if (is_master == 1) begin
                        master_q.push_back(transaction_ahb5);
                  end else begin
                     slave_q.push_back(transaction_ahb5);
                  end
               end else begin
                  uvm_report_info("SCOREBOARD", $sformatf("THE BURST IS INVALID - DROPPING TRANSACTIONS FROM MASTER UNTIL THE END OF BURST!"), UVM_DEBUG);
               end
            end
         end
      end
      extract_ahb5_lock.put();
   endtask



   function int unsigned calculate_burst_length(vip_ahb5_transaction trans);
      int unsigned length;

      case(burst_type)
         vip_ahb5_types::BURST_SINGLE:
            begin
               length = 1;
            end
         vip_ahb5_types::BURST_INCR:
            begin
               length = trans.data.data.size;
            end
         vip_ahb5_types::BURST_WRAP4,
         vip_ahb5_types::BURST_INCR4:
            begin
               length = 4;
            end
         vip_ahb5_types::BURST_WRAP8,
         vip_ahb5_types::BURST_INCR8:
            begin
               length = 8;
            end
         vip_ahb5_types::BURST_WRAP16,
         vip_ahb5_types::BURST_INCR16:
            begin
               length = 16;
            end
      endcase
      return length;
   endfunction: calculate_burst_length


   virtual function void report_phase (uvm_phase phase);
      if (scbd_enabled == 1'b1) begin
         uvm_report_info("SCOREBOARD", $sformatf("Master Queue Size: %0d", master_q.size()));
         uvm_report_info("SCOREBOARD", $sformatf("Slave Queue Size:  %0d", slave_q.size()));
         if ((master_q.size() != 0) || (slave_q.size() != 0)) begin
            `uvm_error(get_type_name(), "QUEUES ARE NOT EMPTY - UNMATCHED TRANSACTIONS DETECTED");
         end
         else begin
            uvm_report_info("SCOREBOARD", $sformatf("DATA BYTE CHECK PASSED!"));
         end
      end else begin
         uvm_report_info("SCOREBOARD", $sformatf("BASIC SCOREBOARD WAS DISABLED - NO TRANSACTIONS WERE COMPARED!"));
      end
   endfunction

   function void enable_scbd();
      scbd_enabled = 1'b1;
   endfunction

   function void disable_scbd();
      scbd_enabled = 1'b0;
   endfunction;

   function void hnonsec_cmp_en();
      hnonsec_cmp = 1'b1;
   endfunction

   function void hnonsec_cmp_dis();
      hnonsec_cmp = 1'b0;
   endfunction

endclass : scoreboard_basic

`endif

//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------


module nic400_bm0_rd_wr_arb_0_sse710_integration_example_f0_host_exp
  (
    wr_override,
    rd_override,
    last_slot,
    wr_reqd_qv,
    rd_reqd_qv,
    awvalid,
    awvalid_m,
    awready_m,
    arvalid,
    arvalid_m,
    arready_m,
    aclk,
    aresetn
  );



  output            wr_override;
  output            rd_override;
  input             last_slot;
  input  [3:0]      wr_reqd_qv;
  input  [3:0]      rd_reqd_qv;
  input             awvalid;
  input             awvalid_m;
  input             awready_m;
  input             arvalid;
  input             arvalid_m;
  input             arready_m;
  input             aclk;
  input             aresetn;


  
  reg           priority_upd;
  wire          rd_priority;
  wire          wr_priority;
  reg           wr_override;
  reg           rd_override;
  wire          next_stall_rd;
  wire          next_stall_wr;
  wire          last_slot_en;


  reg           rw_priority;
  reg           stall_rd;
  reg           stall_wr;


  assign next_stall_rd = (arvalid_m & ~arready_m);
  assign next_stall_wr = (awvalid_m & ~awready_m);

   always @(posedge aclk or negedge aresetn)
   begin : p_stall_seq
        if (!aresetn) begin
             stall_rd <= 1'b0;
             stall_wr <= 1'b0;
        end else begin
             stall_rd <= next_stall_rd;
             stall_wr <= next_stall_wr;
        end 
   end 

  assign rd_priority = ((rd_reqd_qv > wr_reqd_qv) && !stall_wr) || stall_rd;
  assign wr_priority = ((wr_reqd_qv > rd_reqd_qv) && !stall_rd) || stall_wr;
  assign last_slot_en = (awvalid | stall_wr) & (arvalid | stall_rd) & last_slot;

  always @(rd_priority or wr_priority or last_slot_en or
           awready_m or arready_m or rw_priority)
   begin : p_override
        rd_override = 1'b0;
        wr_override = 1'b0;
        priority_upd = 1'b0;
        if (last_slot_en) begin
            priority_upd = awready_m | arready_m;
            if (wr_priority)
                rd_override = 1'b1;
            else if (rd_priority)
                wr_override = 1'b1;
            else
            begin
                wr_override = rw_priority;
                rd_override = ~rw_priority;
            end
        end
   end 


   always @(posedge aclk or negedge aresetn)
   begin : p_priority_seq
        if (!aresetn) begin
             rw_priority <= 1'b0;
        end else if (priority_upd) begin
             rw_priority <= ~rw_priority;
        end 
   end 


`ifdef ARM_ASSERT_ON

   assert_never #(2,0,"last_slot and read and writes stall")
     ovl_wr_post_del_wtr
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr ( last_slot & stall_rd & stall_wr)
       );


`endif

  endmodule


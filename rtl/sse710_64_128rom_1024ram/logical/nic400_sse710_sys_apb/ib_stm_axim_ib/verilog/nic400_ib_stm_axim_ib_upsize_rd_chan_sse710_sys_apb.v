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


module nic400_ib_stm_axim_ib_upsize_rd_chan_sse710_sys_apb
  (
  rvalid_s,
  rdata_s,
  rlast_s,
  rid_s,
  rresp_s,

  rready_s,

  rvalid_m,
  rdata_m,
  rlast_m,
  rid_m,
  rresp_m,

  rready_m,

  archannel_data,
  archannel_valid,
  archannel_ready,

  aclk,
  aresetn
  );

`include "nic400_ib_stm_axim_ib_defs_sse710_sys_apb.v"

  input                     aclk;
  input                     aresetn;

  input                     archannel_valid;
  output                    archannel_ready;
  input [26:0]              archannel_data;

  input                     rvalid_m;
  output                    rready_m;

  input [63:0]              rdata_m;
  input [11:0]              rid_m;
  input [1:0]               rresp_m;
  input                     rlast_m;

  input                     rready_s;

  output                    rvalid_s;
  output [31:0]             rdata_s;
  output [11:0]             rid_s;
  output [1:0]              rresp_s;
  output                    rlast_s;


   wire                                                archannel_ready_i;
   wire                     match_bus;
   wire                     hazard_bus;
   wire                     valid_bus;
   wire                     last_addr_match_bus;
   wire                     beat_complete_slice_bus;

   wire                     hazard;           
   wire                     last_addr_match;  
   wire                     beat_complete_slice;

   wire                     archannel_hndshk;
   wire                     rchannel_hndshk;

   wire                     push_slice;
   wire                     pop_slice;          
   wire                     update;

   wire                     beat_complete;

   wire                     data_select;

   wire                     addr;
   
   wire [11:0]              rid_m;

   wire [63:0]              rdata;
   wire                     rlast_in;
   wire                     rlast_s_i;
   wire [1:0]               rresp_s;
   wire                     addr_out0;

   wire [3:0]               rdata_byte_mask0;
   wire [3:0]               rdata_byte_mask;

   wire [31:0]              rdata_beat_mask;

   wire [31:0]              rdata_s;


   reg [31:0]               rdata_s_demux;
   reg                      hazard_pointer;
   reg                      match_pointer;

   reg                      store;


   assign rid_s = rid_m;
   assign rlast_in = rlast_m;
   assign rresp_s = rresp_m;
   assign rdata = rdata_m;



   assign hazard = hazard_bus;

   assign last_addr_match = (last_addr_match_bus & match_bus);

   assign beat_complete_slice = (beat_complete_slice_bus & match_bus);

   assign addr = addr_out0;

   assign rdata_byte_mask = rdata_byte_mask0;

   assign rdata_beat_mask = {{8{rdata_byte_mask[3]}},
                             {8{rdata_byte_mask[2]}},
                             {8{rdata_byte_mask[1]}},
                             {8{rdata_byte_mask[0]}}};
  

   assign data_select = addr;


   always @(data_select or rdata)
     begin : rdata_demux
     case (data_select)
         1'd0 : rdata_s_demux = rdata[31:0];
         1'd1 : rdata_s_demux = rdata[63:32];
         default : rdata_s_demux = 32'bx;
        endcase
     end 

   assign rdata_s = rdata_s_demux & rdata_beat_mask;


   
   assign rlast_s_i = last_addr_match  && rlast_in;
   assign rlast_s   = rlast_s_i;

   assign archannel_ready_i = ~&valid_bus;
   assign archannel_ready   = archannel_ready_i;
   assign archannel_hndshk = archannel_ready_i && archannel_valid;

   assign push_slice = archannel_hndshk;

   always @(valid_bus or match_bus)
     begin : store_decode
        if (!valid_bus)
           store = 1'b1;
        else
           store = match_bus;
      end 

   always @(hazard_bus)
     begin : hazard_num_distibution
       case (hazard_bus)
          1'b0 : hazard_pointer = 1'b0;
           1'd1 : hazard_pointer = 1'd0;
         default : hazard_pointer = 1'bx;
       endcase
     end

   always @(match_bus)
     begin : match_num_distibution
       case (match_bus)
          1'b0 : match_pointer = 1'b0;
           1'd1 : match_pointer = 1'd0;
         default : match_pointer = 1'bx;
       endcase
     end

   assign beat_complete = (rlast_s_i | beat_complete_slice) && update;


   assign rready_m = beat_complete && rvalid_m;


   assign rvalid_s = rvalid_m;


   assign rchannel_hndshk = rvalid_m && rready_s;

   assign update = rchannel_hndshk;

   assign pop_slice = update && rlast_s_i;


    
     nic400_ib_stm_axim_ib_upsize_rd_cam_slice_sse710_sys_apb u_upsize_rd_cam_slice_0
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),

        .store                (store),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .archannel_data       (archannel_data),
        .rlast_in             (rlast_in),
        
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .hazard               (hazard_bus),
        .match                (match_bus),
        .valid                (valid_bus),
        .addr_out             (addr_out0),
        .last_addr_match      (last_addr_match_bus),
        .beat_complete        (beat_complete_slice_bus),
        .rdata_byte_mask      (rdata_byte_mask0)
     );
     


`ifdef ARM_ASSERT_ON
`include "std_ovl_defines.h"


  assert_never_unknown #(`OVL_FATAL,1,`OVL_ASSERT,"Rd Channel Slice match has gone wrong")  
  ovl_single_ID_match
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .qualifier        (match_bus),
     .test_expr        (rchannel_hndshk)
     );


  assert_never_unknown #(`OVL_FATAL,1,`OVL_ASSERT,"Rd Channel Slice hazard has gone wrong")
  ovl_single_hazard
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .qualifier        (hazard_bus),
     .test_expr        (archannel_hndshk)
     );



`endif

endmodule

`include "nic400_ib_stm_axim_ib_undefs_sse710_sys_apb.v"


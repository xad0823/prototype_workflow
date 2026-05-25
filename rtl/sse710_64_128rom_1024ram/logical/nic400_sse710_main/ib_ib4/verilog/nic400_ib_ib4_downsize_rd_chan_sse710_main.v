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


module nic400_ib_ib4_downsize_rd_chan_sse710_main
  (
  rvalid_m,
  rdata_m,
  rlast_m,
  ruser_m,
  rid_m,
  rresp_m,
  
  rready_s,
 
  rready_m,
  
  rvalid_s,
  rdata_s,
  rlast_s,
  ruser_s,
  rid_s,
  rresp_s,
  
  rbeats_s,
  

  arvalid_m,
  arready_m,

  archannel_data,
  archannel_valid,
  archannel_ready,
  
  arsize,
  araddr,
  arid,
  
  aclk, 
  aresetn
  );

`include "nic400_ib_ib4_defs_sse710_main.v"
`include "Axi.v"

  input                   aclk;
  input                   aresetn;

  input                   archannel_valid;
  output                  archannel_ready;
  input [11:0]            archannel_data;

    
  output                  arvalid_m;
  input                   arready_m;
  
  input [2:0]             arsize;
  input [2:0]             araddr;
  input [11:0]            arid;

  
  input                   rready_s;               

  output                  rvalid_s;
  output [63:0]           rdata_s;
  output [11:0]           rid_s;
  output [1:0]            rresp_s;
  output                  ruser_s;
  output                  rlast_s;
  
  output [1:0]            rbeats_s;

  output                  rready_m;               

  input                   rvalid_m;
  input [31:0]            rdata_m;
  input [11:0]            rid_m;
  input [1:0]             rresp_m;
  input                   ruser_m;
  input                   rlast_m;

 
   wire [17:0]            match_bus; 
   wire [17:0]            hazard_bus;
   wire [17:0]            valid_bus;
   wire [17:0]            last_addr_match_bus;
   wire [17:0]            beat_complete_slice_bus;

   reg  [4:0]             hazard_pointer;
   reg  [4:0]             match_pointer;

   wire                   hazard;           
   wire                   last_addr_match;  
   wire                   beat_complete_slice;           

   reg [17:0]             store;

   wire                   archannel_hndshk;
   wire                   rchannel_hndshk;

   wire                   push_slice;
   wire                   pop_slice;          
   wire                   update;
   wire [17:0]            clear_slice;

   wire                   beat_complete;

   
   wire                   bypass;

   wire [1:0]             rbeats;
   
   
   
 
   wire                   rlast_m;
   wire [11:0]            rid_m;
   wire [1:0]             rresp_m;
   wire                    ruser_m;
   
   wire                   rlast_out;
   wire                   rlast_out_masked;
   
   wire [18:0]            ar_cam_data;
   
   wire [11:0]            ar_channel_data;

   wire                   cam_update;




    
  
   wire [1:0]             beat_number0;
  
   wire [1:0]             beat_number1;
  
   wire [1:0]             beat_number2;
  
   wire [1:0]             beat_number3;
  
   wire [1:0]             beat_number4;
  
   wire [1:0]             beat_number5;
  
   wire [1:0]             beat_number6;
  
   wire [1:0]             beat_number7;
  
   wire [1:0]             beat_number8;
  
   wire [1:0]             beat_number9;
  
   wire [1:0]             beat_number10;
  
   wire [1:0]             beat_number11;
  
   wire [1:0]             beat_number12;
  
   wire [1:0]             beat_number13;
  
   wire [1:0]             beat_number14;
  
   wire [1:0]             beat_number15;
  
   wire [1:0]             beat_number16;
  
   wire [1:0]             beat_number17;
       
   wire [1:0]             rresp_cam;
   wire                   mask_last;
   wire [31:0]            rdata_cam;
  
   wire [31:0]            rdata_cam0;
  
   wire [31:0]            rdata_cam1;
  
   wire [31:0]            rdata_cam2;
  
   wire [31:0]            rdata_cam3;
  
   wire [31:0]            rdata_cam4;
  
   wire [31:0]            rdata_cam5;
  
   wire [31:0]            rdata_cam6;
  
   wire [31:0]            rdata_cam7;
  
   wire [31:0]            rdata_cam8;
  
   wire [31:0]            rdata_cam9;
  
   wire [31:0]            rdata_cam10;
  
   wire [31:0]            rdata_cam11;
  
   wire [31:0]            rdata_cam12;
  
   wire [31:0]            rdata_cam13;
  
   wire [31:0]            rdata_cam14;
  
   wire [31:0]            rdata_cam15;
  
   wire [31:0]            rdata_cam16;
  
   wire [31:0]            rdata_cam17;
  
   wire [1:0]             rresp_cam0;
  
   wire [1:0]             rresp_cam1;
  
   wire [1:0]             rresp_cam2;
  
   wire [1:0]             rresp_cam3;
  
   wire [1:0]             rresp_cam4;
  
   wire [1:0]             rresp_cam5;
  
   wire [1:0]             rresp_cam6;
  
   wire [1:0]             rresp_cam7;
  
   wire [1:0]             rresp_cam8;
  
   wire [1:0]             rresp_cam9;
  
   wire [1:0]             rresp_cam10;
  
   wire [1:0]             rresp_cam11;
  
   wire [1:0]             rresp_cam12;
  
   wire [1:0]             rresp_cam13;
  
   wire [1:0]             rresp_cam14;
  
   wire [1:0]             rresp_cam15;
  
   wire [1:0]             rresp_cam16;
  
   wire [1:0]             rresp_cam17;
  
   wire                   mask_last0;
  
   wire                   mask_last1;
  
   wire                   mask_last2;
  
   wire                   mask_last3;
  
   wire                   mask_last4;
  
   wire                   mask_last5;
  
   wire                   mask_last6;
  
   wire                   mask_last7;
  
   wire                   mask_last8;
  
   wire                   mask_last9;
  
   wire                   mask_last10;
  
   wire                   mask_last11;
  
   wire                   mask_last12;
  
   wire                   mask_last13;
  
   wire                   mask_last14;
  
   wire                   mask_last15;
  
   wire                   mask_last16;
  
   wire                   mask_last17;
   
   wire [63:0]            rdata_out;
   wire [1:0]             rresp_out;
   
   
   wire                   fixed_dwnsize;   
   
   wire [3:0]                n_response;
   
   wire [2:0]             addr_mask;
   
   wire [3:0]                next_n_response_reg;
   wire                   n_response_reg_wr_en;
   wire                   slice_required;
    
    
    


   reg [2:0]              downsize;

   reg [3:0]                 n_response_reg;


   assign rid_s   = rid_m;
   assign rdata_s = rdata_out;
   assign rresp_s = rresp_out;
   assign ruser_s = ruser_m;
   assign rlast_s = rlast_out_masked;
   
   assign rbeats_s = rbeats;
     



   assign hazard = |hazard_bus;

   assign last_addr_match = |(last_addr_match_bus & match_bus);

   assign beat_complete_slice = |(beat_complete_slice_bus & match_bus);

   assign rbeats = beat_number0
              |  beat_number1
              |  beat_number2
              |  beat_number3
              |  beat_number4
              |  beat_number5
              |  beat_number6
              |  beat_number7
              |  beat_number8
              |  beat_number9
              |  beat_number10
              |  beat_number11
              |  beat_number12
              |  beat_number13
              |  beat_number14
              |  beat_number15
              |  beat_number16
              |  beat_number17;
   
   assign rdata_cam = rdata_cam0
              |  rdata_cam1
              |  rdata_cam2
              |  rdata_cam3
              |  rdata_cam4
              |  rdata_cam5
              |  rdata_cam6
              |  rdata_cam7
              |  rdata_cam8
              |  rdata_cam9
              |  rdata_cam10
              |  rdata_cam11
              |  rdata_cam12
              |  rdata_cam13
              |  rdata_cam14
              |  rdata_cam15
              |  rdata_cam16
              |  rdata_cam17;
   

   
   assign rresp_cam = rresp_cam0
              |  rresp_cam1
              |  rresp_cam2
              |  rresp_cam3
              |  rresp_cam4
              |  rresp_cam5
              |  rresp_cam6
              |  rresp_cam7
              |  rresp_cam8
              |  rresp_cam9
              |  rresp_cam10
              |  rresp_cam11
              |  rresp_cam12
              |  rresp_cam13
              |  rresp_cam14
              |  rresp_cam15
              |  rresp_cam16
              |  rresp_cam17;
   
   assign mask_last = mask_last0
              |  mask_last1
              |  mask_last2
              |  mask_last3
              |  mask_last4
              |  mask_last5
              |  mask_last6
              |  mask_last7
              |  mask_last8
              |  mask_last9
              |  mask_last10
              |  mask_last11
              |  mask_last12
              |  mask_last13
              |  mask_last14
              |  mask_last15
              |  mask_last16
              |  mask_last17;

   


   assign rdata_out[63:32] = rdata_m;
  
    
   assign rdata_out[31:0] = rdata_cam[31:0];
  

   assign rlast_out = last_addr_match  && rlast_m;
   
   assign rlast_out_masked = rlast_out & ~mask_last;
   
   assign rresp_out = rresp_cam;
   

  always @(archannel_data)
    begin : downsize_mask_p
      case (archannel_data[2:0])
         `AXI_ASIZE_8    : downsize = {3{1'b0}};
         `AXI_ASIZE_16   : downsize = {{2{1'b0}},{1'b1}};
         `AXI_ASIZE_32   : downsize = {{1{1'b0}},{2'b11}};
         `AXI_ASIZE_64   : downsize = {{3'b111}};
         `AXI_ASIZE_128,
       `AXI_ASIZE_256,
       `AXI_ASIZE_512,
       `AXI_ASIZE_1024 : downsize = {3{1'b0}};    
        default : downsize = 3'bx;
      endcase
    end
    
    
    assign ar_cam_data = {arid,araddr,arsize[1:0],fixed_dwnsize,bypass};
    
    assign ar_channel_data = {downsize,archannel_data[11:3]};
    

   
   assign n_response = archannel_data[11:8];
   
   
   assign addr_mask = archannel_data[5:3];
   
   
   
    assign bypass = (archannel_data[2:0] == arsize[2:0]) & (~|n_response);

   
   assign fixed_dwnsize = (|n_response) & (downsize[2]) & (~|addr_mask);
      
   
   assign next_n_response_reg = n_response; 

   assign n_response_reg_wr_en =  (archannel_hndshk);


   always @(posedge aclk or negedge aresetn)
     begin : next_resp_seq
       if (!aresetn) 
          n_response_reg <= 4'b0;
      else if (n_response_reg_wr_en)
           n_response_reg <= next_n_response_reg;
   end 

   assign arvalid_m = archannel_valid & ((~&valid_bus) | ~slice_required);
   assign archannel_ready = arready_m & ((~&valid_bus) | ~slice_required); 

   assign archannel_hndshk = archannel_ready && archannel_valid;

   assign slice_required = (~|n_response_reg) | ((downsize[2]) & (~|addr_mask));
   assign push_slice = archannel_hndshk & slice_required;
   
   always @(valid_bus or match_bus)
     begin : store_decode
        if (!valid_bus[0])
           store = 18'b000000000000000001;
         else if (!valid_bus[1])
            store = 18'b000000000000000010;
         else if (!valid_bus[2])
            store = 18'b000000000000000100;
         else if (!valid_bus[3])
            store = 18'b000000000000001000;
         else if (!valid_bus[4])
            store = 18'b000000000000010000;
         else if (!valid_bus[5])
            store = 18'b000000000000100000;
         else if (!valid_bus[6])
            store = 18'b000000000001000000;
         else if (!valid_bus[7])
            store = 18'b000000000010000000;
         else if (!valid_bus[8])
            store = 18'b000000000100000000;
         else if (!valid_bus[9])
            store = 18'b000000001000000000;
         else if (!valid_bus[10])
            store = 18'b000000010000000000;
         else if (!valid_bus[11])
            store = 18'b000000100000000000;
         else if (!valid_bus[12])
            store = 18'b000001000000000000;
         else if (!valid_bus[13])
            store = 18'b000010000000000000;
         else if (!valid_bus[14])
            store = 18'b000100000000000000;
         else if (!valid_bus[15])
            store = 18'b001000000000000000;
         else if (!valid_bus[16])
            store = 18'b010000000000000000;
         else if (!valid_bus[17])
            store = 18'b100000000000000000;
        else
           store = match_bus;
      end 
      
   always @(hazard_bus)
     begin : hazard_num_distibution
       case (hazard_bus)
          18'b0 : hazard_pointer = 5'b0;
           18'd1 : hazard_pointer = 5'd0;
          18'd2 : hazard_pointer = 5'd1;
          18'd4 : hazard_pointer = 5'd2;
          18'd8 : hazard_pointer = 5'd3;
          18'd16 : hazard_pointer = 5'd4;
          18'd32 : hazard_pointer = 5'd5;
          18'd64 : hazard_pointer = 5'd6;
          18'd128 : hazard_pointer = 5'd7;
          18'd256 : hazard_pointer = 5'd8;
          18'd512 : hazard_pointer = 5'd9;
          18'd1024 : hazard_pointer = 5'd10;
          18'd2048 : hazard_pointer = 5'd11;
          18'd4096 : hazard_pointer = 5'd12;
          18'd8192 : hazard_pointer = 5'd13;
          18'd16384 : hazard_pointer = 5'd14;
          18'd32768 : hazard_pointer = 5'd15;
          18'd65536 : hazard_pointer = 5'd16;
          18'd131072 : hazard_pointer = 5'd17;
         default : hazard_pointer = 5'bx;
       endcase
     end
     
   always @(match_bus)
     begin : match_num_distibution
       case (match_bus)
          18'b0 : match_pointer = 5'b0;
           18'd1 : match_pointer = 5'd0;
          18'd2 : match_pointer = 5'd1;
          18'd4 : match_pointer = 5'd2;
          18'd8 : match_pointer = 5'd3;
          18'd16 : match_pointer = 5'd4;
          18'd32 : match_pointer = 5'd5;
          18'd64 : match_pointer = 5'd6;
          18'd128 : match_pointer = 5'd7;
          18'd256 : match_pointer = 5'd8;
          18'd512 : match_pointer = 5'd9;
          18'd1024 : match_pointer = 5'd10;
          18'd2048 : match_pointer = 5'd11;
          18'd4096 : match_pointer = 5'd12;
          18'd8192 : match_pointer = 5'd13;
          18'd16384 : match_pointer = 5'd14;
          18'd32768 : match_pointer = 5'd15;
          18'd65536 : match_pointer = 5'd16;
          18'd131072 : match_pointer = 5'd17;
         default : match_pointer = 5'bx;
       endcase
     end

   assign beat_complete = (rlast_out | beat_complete_slice) && update;

   
   assign rready_m = (beat_complete | (~beat_complete_slice)) && rvalid_m;

   assign rvalid_s = beat_complete_slice && rvalid_m;
   

   assign rchannel_hndshk = rvalid_s && rready_s;
      
   assign update = rchannel_hndshk;

   assign clear_slice = {18{update}} & match_bus;

   assign cam_update = rvalid_m & rready_m;

   assign pop_slice = update && rlast_out;


    
     nic400_ib_ib4_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_0
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[0]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[0]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[0]),
        .match                (match_bus[0]),
        .valid                (valid_bus[0]),
        .last_addr_match      (last_addr_match_bus[0]),
        .beat_complete        (beat_complete_slice_bus[0]),
        .beat_number          (beat_number0),
        
        .rdata_cam            (rdata_cam0),
        
        .rresp_cam            (rresp_cam0),
        
        .mask_last            (mask_last0)
     );
     
     nic400_ib_ib4_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_1
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[1]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[1]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[1]),
        .match                (match_bus[1]),
        .valid                (valid_bus[1]),
        .last_addr_match      (last_addr_match_bus[1]),
        .beat_complete        (beat_complete_slice_bus[1]),
        .beat_number          (beat_number1),
        
        .rdata_cam            (rdata_cam1),
        
        .rresp_cam            (rresp_cam1),
        
        .mask_last            (mask_last1)
     );
     
     nic400_ib_ib4_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_2
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[2]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[2]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[2]),
        .match                (match_bus[2]),
        .valid                (valid_bus[2]),
        .last_addr_match      (last_addr_match_bus[2]),
        .beat_complete        (beat_complete_slice_bus[2]),
        .beat_number          (beat_number2),
        
        .rdata_cam            (rdata_cam2),
        
        .rresp_cam            (rresp_cam2),
        
        .mask_last            (mask_last2)
     );
     
     nic400_ib_ib4_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_3
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[3]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[3]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[3]),
        .match                (match_bus[3]),
        .valid                (valid_bus[3]),
        .last_addr_match      (last_addr_match_bus[3]),
        .beat_complete        (beat_complete_slice_bus[3]),
        .beat_number          (beat_number3),
        
        .rdata_cam            (rdata_cam3),
        
        .rresp_cam            (rresp_cam3),
        
        .mask_last            (mask_last3)
     );
     
     nic400_ib_ib4_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_4
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[4]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[4]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[4]),
        .match                (match_bus[4]),
        .valid                (valid_bus[4]),
        .last_addr_match      (last_addr_match_bus[4]),
        .beat_complete        (beat_complete_slice_bus[4]),
        .beat_number          (beat_number4),
        
        .rdata_cam            (rdata_cam4),
        
        .rresp_cam            (rresp_cam4),
        
        .mask_last            (mask_last4)
     );
     
     nic400_ib_ib4_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_5
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[5]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[5]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[5]),
        .match                (match_bus[5]),
        .valid                (valid_bus[5]),
        .last_addr_match      (last_addr_match_bus[5]),
        .beat_complete        (beat_complete_slice_bus[5]),
        .beat_number          (beat_number5),
        
        .rdata_cam            (rdata_cam5),
        
        .rresp_cam            (rresp_cam5),
        
        .mask_last            (mask_last5)
     );
     
     nic400_ib_ib4_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_6
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[6]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[6]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[6]),
        .match                (match_bus[6]),
        .valid                (valid_bus[6]),
        .last_addr_match      (last_addr_match_bus[6]),
        .beat_complete        (beat_complete_slice_bus[6]),
        .beat_number          (beat_number6),
        
        .rdata_cam            (rdata_cam6),
        
        .rresp_cam            (rresp_cam6),
        
        .mask_last            (mask_last6)
     );
     
     nic400_ib_ib4_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_7
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[7]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[7]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[7]),
        .match                (match_bus[7]),
        .valid                (valid_bus[7]),
        .last_addr_match      (last_addr_match_bus[7]),
        .beat_complete        (beat_complete_slice_bus[7]),
        .beat_number          (beat_number7),
        
        .rdata_cam            (rdata_cam7),
        
        .rresp_cam            (rresp_cam7),
        
        .mask_last            (mask_last7)
     );
     
     nic400_ib_ib4_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_8
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[8]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[8]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[8]),
        .match                (match_bus[8]),
        .valid                (valid_bus[8]),
        .last_addr_match      (last_addr_match_bus[8]),
        .beat_complete        (beat_complete_slice_bus[8]),
        .beat_number          (beat_number8),
        
        .rdata_cam            (rdata_cam8),
        
        .rresp_cam            (rresp_cam8),
        
        .mask_last            (mask_last8)
     );
     
     nic400_ib_ib4_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_9
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[9]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[9]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[9]),
        .match                (match_bus[9]),
        .valid                (valid_bus[9]),
        .last_addr_match      (last_addr_match_bus[9]),
        .beat_complete        (beat_complete_slice_bus[9]),
        .beat_number          (beat_number9),
        
        .rdata_cam            (rdata_cam9),
        
        .rresp_cam            (rresp_cam9),
        
        .mask_last            (mask_last9)
     );
     
     nic400_ib_ib4_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_10
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[10]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[10]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[10]),
        .match                (match_bus[10]),
        .valid                (valid_bus[10]),
        .last_addr_match      (last_addr_match_bus[10]),
        .beat_complete        (beat_complete_slice_bus[10]),
        .beat_number          (beat_number10),
        
        .rdata_cam            (rdata_cam10),
        
        .rresp_cam            (rresp_cam10),
        
        .mask_last            (mask_last10)
     );
     
     nic400_ib_ib4_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_11
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[11]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[11]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[11]),
        .match                (match_bus[11]),
        .valid                (valid_bus[11]),
        .last_addr_match      (last_addr_match_bus[11]),
        .beat_complete        (beat_complete_slice_bus[11]),
        .beat_number          (beat_number11),
        
        .rdata_cam            (rdata_cam11),
        
        .rresp_cam            (rresp_cam11),
        
        .mask_last            (mask_last11)
     );
     
     nic400_ib_ib4_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_12
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[12]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[12]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[12]),
        .match                (match_bus[12]),
        .valid                (valid_bus[12]),
        .last_addr_match      (last_addr_match_bus[12]),
        .beat_complete        (beat_complete_slice_bus[12]),
        .beat_number          (beat_number12),
        
        .rdata_cam            (rdata_cam12),
        
        .rresp_cam            (rresp_cam12),
        
        .mask_last            (mask_last12)
     );
     
     nic400_ib_ib4_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_13
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[13]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[13]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[13]),
        .match                (match_bus[13]),
        .valid                (valid_bus[13]),
        .last_addr_match      (last_addr_match_bus[13]),
        .beat_complete        (beat_complete_slice_bus[13]),
        .beat_number          (beat_number13),
        
        .rdata_cam            (rdata_cam13),
        
        .rresp_cam            (rresp_cam13),
        
        .mask_last            (mask_last13)
     );
     
     nic400_ib_ib4_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_14
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[14]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[14]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[14]),
        .match                (match_bus[14]),
        .valid                (valid_bus[14]),
        .last_addr_match      (last_addr_match_bus[14]),
        .beat_complete        (beat_complete_slice_bus[14]),
        .beat_number          (beat_number14),
        
        .rdata_cam            (rdata_cam14),
        
        .rresp_cam            (rresp_cam14),
        
        .mask_last            (mask_last14)
     );
     
     nic400_ib_ib4_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_15
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[15]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[15]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[15]),
        .match                (match_bus[15]),
        .valid                (valid_bus[15]),
        .last_addr_match      (last_addr_match_bus[15]),
        .beat_complete        (beat_complete_slice_bus[15]),
        .beat_number          (beat_number15),
        
        .rdata_cam            (rdata_cam15),
        
        .rresp_cam            (rresp_cam15),
        
        .mask_last            (mask_last15)
     );
     
     nic400_ib_ib4_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_16
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[16]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[16]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[16]),
        .match                (match_bus[16]),
        .valid                (valid_bus[16]),
        .last_addr_match      (last_addr_match_bus[16]),
        .beat_complete        (beat_complete_slice_bus[16]),
        .beat_number          (beat_number16),
        
        .rdata_cam            (rdata_cam16),
        
        .rresp_cam            (rresp_cam16),
        
        .mask_last            (mask_last16)
     );
     
     nic400_ib_ib4_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_17
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[17]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[17]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[17]),
        .match                (match_bus[17]),
        .valid                (valid_bus[17]),
        .last_addr_match      (last_addr_match_bus[17]),
        .beat_complete        (beat_complete_slice_bus[17]),
        .beat_number          (beat_number17),
        
        .rdata_cam            (rdata_cam17),
        
        .rresp_cam            (rresp_cam17),
        
        .mask_last            (mask_last17)
     );
     


`ifdef ARM_ASSERT_ON
`include "std_ovl_defines.h"


  assert_zero_one_hot #(0,18,0,"More than one Rd Channel Slice matched")
  ovl_single_ID_match
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .test_expr        ({18{rchannel_hndshk}} & match_bus)
     );


  assert_zero_one_hot #(0,18,0,"More than one R Channel Slice hazard")
  ovl_single_hazard
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .test_expr        ({18{archannel_hndshk}} & hazard_bus)
     );


  wire [11:0]   cam_id_reg [0:17];

  assign cam_id_reg[0] = u_downsize_rd_cam_slice_0.id_reg;


  assert_implication #(0,0,"CAM 0 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_0_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_0.pointer_reg] && (cam_id_reg[0] == cam_id_reg[u_downsize_rd_cam_slice_0.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 0 is last but is pointed to by another valid CAM")
  ovl_cam_0_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[0] && u_downsize_rd_cam_slice_0.last_reg),
     .consequent_expr  (!(
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 0) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 0) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 0) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 0) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 0) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 0) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 0) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 0) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 0) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 0) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 0) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 0) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 0) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 0) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 0) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 0) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 0)))
     );
  
  assign cam_id_reg[1] = u_downsize_rd_cam_slice_1.id_reg;


  assert_implication #(0,0,"CAM 1 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_1_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_1.pointer_reg] && (cam_id_reg[1] == cam_id_reg[u_downsize_rd_cam_slice_1.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 1 is last but is pointed to by another valid CAM")
  ovl_cam_1_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[1] && u_downsize_rd_cam_slice_1.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 1) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 1) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 1) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 1) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 1) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 1) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 1) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 1) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 1) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 1) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 1) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 1) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 1) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 1) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 1) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 1) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 1)))
     );
  
  assign cam_id_reg[2] = u_downsize_rd_cam_slice_2.id_reg;


  assert_implication #(0,0,"CAM 2 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_2_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_2.pointer_reg] && (cam_id_reg[2] == cam_id_reg[u_downsize_rd_cam_slice_2.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 2 is last but is pointed to by another valid CAM")
  ovl_cam_2_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[2] && u_downsize_rd_cam_slice_2.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 2) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 2) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 2) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 2) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 2) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 2) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 2) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 2) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 2) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 2) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 2) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 2) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 2) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 2) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 2) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 2) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 2)))
     );
  
  assign cam_id_reg[3] = u_downsize_rd_cam_slice_3.id_reg;


  assert_implication #(0,0,"CAM 3 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_3_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_3.pointer_reg] && (cam_id_reg[3] == cam_id_reg[u_downsize_rd_cam_slice_3.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 3 is last but is pointed to by another valid CAM")
  ovl_cam_3_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[3] && u_downsize_rd_cam_slice_3.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 3) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 3) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 3) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 3) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 3) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 3) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 3) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 3) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 3) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 3) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 3) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 3) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 3) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 3) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 3) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 3) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 3)))
     );
  
  assign cam_id_reg[4] = u_downsize_rd_cam_slice_4.id_reg;


  assert_implication #(0,0,"CAM 4 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_4_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_4.pointer_reg] && (cam_id_reg[4] == cam_id_reg[u_downsize_rd_cam_slice_4.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 4 is last but is pointed to by another valid CAM")
  ovl_cam_4_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[4] && u_downsize_rd_cam_slice_4.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 4) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 4) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 4) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 4) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 4) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 4) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 4) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 4) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 4) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 4) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 4) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 4) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 4) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 4) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 4) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 4) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 4)))
     );
  
  assign cam_id_reg[5] = u_downsize_rd_cam_slice_5.id_reg;


  assert_implication #(0,0,"CAM 5 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_5_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_5.pointer_reg] && (cam_id_reg[5] == cam_id_reg[u_downsize_rd_cam_slice_5.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 5 is last but is pointed to by another valid CAM")
  ovl_cam_5_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[5] && u_downsize_rd_cam_slice_5.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 5) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 5) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 5) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 5) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 5) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 5) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 5) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 5) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 5) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 5) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 5) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 5) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 5) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 5) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 5) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 5) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 5)))
     );
  
  assign cam_id_reg[6] = u_downsize_rd_cam_slice_6.id_reg;


  assert_implication #(0,0,"CAM 6 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_6_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_6.pointer_reg] && (cam_id_reg[6] == cam_id_reg[u_downsize_rd_cam_slice_6.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 6 is last but is pointed to by another valid CAM")
  ovl_cam_6_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[6] && u_downsize_rd_cam_slice_6.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 6) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 6) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 6) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 6) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 6) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 6) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 6) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 6) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 6) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 6) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 6) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 6) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 6) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 6) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 6) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 6) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 6)))
     );
  
  assign cam_id_reg[7] = u_downsize_rd_cam_slice_7.id_reg;


  assert_implication #(0,0,"CAM 7 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_7_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_7.pointer_reg] && (cam_id_reg[7] == cam_id_reg[u_downsize_rd_cam_slice_7.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 7 is last but is pointed to by another valid CAM")
  ovl_cam_7_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[7] && u_downsize_rd_cam_slice_7.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 7) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 7) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 7) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 7) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 7) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 7) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 7) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 7) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 7) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 7) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 7) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 7) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 7) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 7) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 7) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 7) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 7)))
     );
  
  assign cam_id_reg[8] = u_downsize_rd_cam_slice_8.id_reg;


  assert_implication #(0,0,"CAM 8 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_8_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_8.pointer_reg] && (cam_id_reg[8] == cam_id_reg[u_downsize_rd_cam_slice_8.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 8 is last but is pointed to by another valid CAM")
  ovl_cam_8_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[8] && u_downsize_rd_cam_slice_8.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 8) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 8) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 8) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 8) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 8) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 8) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 8) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 8) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 8) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 8) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 8) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 8) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 8) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 8) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 8) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 8) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 8)))
     );
  
  assign cam_id_reg[9] = u_downsize_rd_cam_slice_9.id_reg;


  assert_implication #(0,0,"CAM 9 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_9_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_9.pointer_reg] && (cam_id_reg[9] == cam_id_reg[u_downsize_rd_cam_slice_9.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 9 is last but is pointed to by another valid CAM")
  ovl_cam_9_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[9] && u_downsize_rd_cam_slice_9.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 9) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 9) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 9) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 9) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 9) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 9) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 9) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 9) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 9) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 9) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 9) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 9) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 9) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 9) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 9) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 9) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 9)))
     );
  
  assign cam_id_reg[10] = u_downsize_rd_cam_slice_10.id_reg;


  assert_implication #(0,0,"CAM 10 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_10_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_10.pointer_reg] && (cam_id_reg[10] == cam_id_reg[u_downsize_rd_cam_slice_10.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 10 is last but is pointed to by another valid CAM")
  ovl_cam_10_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[10] && u_downsize_rd_cam_slice_10.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 10) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 10) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 10) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 10) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 10) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 10) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 10) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 10) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 10) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 10) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 10) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 10) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 10) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 10) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 10) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 10) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 10)))
     );
  
  assign cam_id_reg[11] = u_downsize_rd_cam_slice_11.id_reg;


  assert_implication #(0,0,"CAM 11 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_11_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_11.pointer_reg] && (cam_id_reg[11] == cam_id_reg[u_downsize_rd_cam_slice_11.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 11 is last but is pointed to by another valid CAM")
  ovl_cam_11_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[11] && u_downsize_rd_cam_slice_11.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 11) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 11) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 11) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 11) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 11) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 11) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 11) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 11) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 11) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 11) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 11) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 11) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 11) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 11) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 11) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 11) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 11)))
     );
  
  assign cam_id_reg[12] = u_downsize_rd_cam_slice_12.id_reg;


  assert_implication #(0,0,"CAM 12 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_12_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_12.pointer_reg] && (cam_id_reg[12] == cam_id_reg[u_downsize_rd_cam_slice_12.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 12 is last but is pointed to by another valid CAM")
  ovl_cam_12_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[12] && u_downsize_rd_cam_slice_12.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 12) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 12) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 12) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 12) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 12) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 12) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 12) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 12) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 12) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 12) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 12) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 12) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 12) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 12) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 12) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 12) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 12)))
     );
  
  assign cam_id_reg[13] = u_downsize_rd_cam_slice_13.id_reg;


  assert_implication #(0,0,"CAM 13 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_13_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_13.pointer_reg] && (cam_id_reg[13] == cam_id_reg[u_downsize_rd_cam_slice_13.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 13 is last but is pointed to by another valid CAM")
  ovl_cam_13_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[13] && u_downsize_rd_cam_slice_13.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 13) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 13) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 13) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 13) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 13) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 13) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 13) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 13) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 13) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 13) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 13) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 13) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 13) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 13) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 13) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 13) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 13)))
     );
  
  assign cam_id_reg[14] = u_downsize_rd_cam_slice_14.id_reg;


  assert_implication #(0,0,"CAM 14 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_14_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_14.pointer_reg] && (cam_id_reg[14] == cam_id_reg[u_downsize_rd_cam_slice_14.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 14 is last but is pointed to by another valid CAM")
  ovl_cam_14_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[14] && u_downsize_rd_cam_slice_14.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 14) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 14) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 14) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 14) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 14) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 14) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 14) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 14) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 14) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 14) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 14) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 14) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 14) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 14) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 14) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 14) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 14)))
     );
  
  assign cam_id_reg[15] = u_downsize_rd_cam_slice_15.id_reg;


  assert_implication #(0,0,"CAM 15 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_15_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_15.pointer_reg] && (cam_id_reg[15] == cam_id_reg[u_downsize_rd_cam_slice_15.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 15 is last but is pointed to by another valid CAM")
  ovl_cam_15_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[15] && u_downsize_rd_cam_slice_15.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 15) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 15) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 15) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 15) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 15) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 15) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 15) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 15) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 15) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 15) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 15) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 15) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 15) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 15) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 15) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 15) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 15)))
     );
  
  assign cam_id_reg[16] = u_downsize_rd_cam_slice_16.id_reg;


  assert_implication #(0,0,"CAM 16 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_16_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_16.pointer_reg] && (cam_id_reg[16] == cam_id_reg[u_downsize_rd_cam_slice_16.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 16 is last but is pointed to by another valid CAM")
  ovl_cam_16_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[16] && u_downsize_rd_cam_slice_16.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 16) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 16) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 16) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 16) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 16) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 16) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 16) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 16) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 16) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 16) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 16) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 16) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 16) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 16) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 16) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 16) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 16)))
     );
  
  assign cam_id_reg[17] = u_downsize_rd_cam_slice_17.id_reg;


  assert_implication #(0,0,"CAM 17 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_17_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_17.pointer_reg] && (cam_id_reg[17] == cam_id_reg[u_downsize_rd_cam_slice_17.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 17 is last but is pointed to by another valid CAM")
  ovl_cam_17_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[17] && u_downsize_rd_cam_slice_17.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 17) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 17) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 17) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 17) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 17) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 17) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 17) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 17) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 17) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 17) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 17) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 17) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 17) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 17) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 17) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 17) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 17)))
     );
  
     
     wire        arsize_out_range;
 
     assign      arsize_out_range = archannel_valid && (archannel_data[2:0] > `AXI_ASIZE_64);
                                                                                             
     wire        illegal_downsize;        

     assign illegal_downsize =  (downsize == {3{1'b0}}) & arsize_out_range;

     assert_never #(`OVL_FATAL,
                    `OVL_ASSERT,
                    "Input archannel_data[2:0] to downsize calculation has gone out of legal range")
     ovl_downsize_illegal_asize
     (
       .clk        (aclk),
       .reset_n    (aresetn),
       .test_expr  (illegal_downsize)
     );


`endif

endmodule

`include "nic400_ib_ib4_undefs_sse710_main.v"
`include "Axi_undefs.v"


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


module nic400_ib_hostcpu_axis_ib_downsize_rd_chan_sse710_main
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

`include "nic400_ib_hostcpu_axis_ib_defs_sse710_main.v"
`include "Axi.v"

  input                   aclk;
  input                   aresetn;

  input                   archannel_valid;
  output                  archannel_ready;
  input [13:0]            archannel_data;

    
  output                  arvalid_m;
  input                   arready_m;
  
  input [2:0]             arsize;
  input [3:0]             araddr;
  input [7:0]             arid;

  
  input                   rready_s;               

  output                  rvalid_s;
  output [127:0]          rdata_s;
  output [7:0]            rid_s;
  output [1:0]            rresp_s;
  output                  ruser_s;
  output                  rlast_s;
  
  output [2:0]            rbeats_s;

  output                  rready_m;               

  input                   rvalid_m;
  input [63:0]            rdata_m;
  input [7:0]             rid_m;
  input [1:0]             rresp_m;
  input                   ruser_m;
  input                   rlast_m;

 
   wire [31:0]            match_bus; 
   wire [31:0]            hazard_bus;
   wire [31:0]            valid_bus;
   wire [31:0]            last_addr_match_bus;
   wire [31:0]            beat_complete_slice_bus;

   reg  [4:0]             hazard_pointer;
   reg  [4:0]             match_pointer;

   wire                   hazard;           
   wire                   last_addr_match;  
   wire                   beat_complete_slice;           

   reg [31:0]             store;

   wire                   archannel_hndshk;
   wire                   rchannel_hndshk;

   wire                   push_slice;
   wire                   pop_slice;          
   wire                   update;
   wire [31:0]            clear_slice;

   wire                   beat_complete;

   
   wire                   bypass;

   wire [2:0]             rbeats;
   
   
   
 
   wire                   rlast_m;
   wire [7:0]             rid_m;
   wire [1:0]             rresp_m;
   wire                    ruser_m;
   
   wire                   rlast_out;
   wire                   rlast_out_masked;
   
   wire [16:0]            ar_cam_data;
   
   wire [14:0]            ar_channel_data;

   wire                   cam_update;




    
  
   wire [2:0]             beat_number0;
  
   wire [2:0]             beat_number1;
  
   wire [2:0]             beat_number2;
  
   wire [2:0]             beat_number3;
  
   wire [2:0]             beat_number4;
  
   wire [2:0]             beat_number5;
  
   wire [2:0]             beat_number6;
  
   wire [2:0]             beat_number7;
  
   wire [2:0]             beat_number8;
  
   wire [2:0]             beat_number9;
  
   wire [2:0]             beat_number10;
  
   wire [2:0]             beat_number11;
  
   wire [2:0]             beat_number12;
  
   wire [2:0]             beat_number13;
  
   wire [2:0]             beat_number14;
  
   wire [2:0]             beat_number15;
  
   wire [2:0]             beat_number16;
  
   wire [2:0]             beat_number17;
  
   wire [2:0]             beat_number18;
  
   wire [2:0]             beat_number19;
  
   wire [2:0]             beat_number20;
  
   wire [2:0]             beat_number21;
  
   wire [2:0]             beat_number22;
  
   wire [2:0]             beat_number23;
  
   wire [2:0]             beat_number24;
  
   wire [2:0]             beat_number25;
  
   wire [2:0]             beat_number26;
  
   wire [2:0]             beat_number27;
  
   wire [2:0]             beat_number28;
  
   wire [2:0]             beat_number29;
  
   wire [2:0]             beat_number30;
  
   wire [2:0]             beat_number31;
       
   wire [1:0]             rresp_cam;
   wire                   mask_last;
   wire [63:0]            rdata_cam;
  
   wire [63:0]            rdata_cam0;
  
   wire [63:0]            rdata_cam1;
  
   wire [63:0]            rdata_cam2;
  
   wire [63:0]            rdata_cam3;
  
   wire [63:0]            rdata_cam4;
  
   wire [63:0]            rdata_cam5;
  
   wire [63:0]            rdata_cam6;
  
   wire [63:0]            rdata_cam7;
  
   wire [63:0]            rdata_cam8;
  
   wire [63:0]            rdata_cam9;
  
   wire [63:0]            rdata_cam10;
  
   wire [63:0]            rdata_cam11;
  
   wire [63:0]            rdata_cam12;
  
   wire [63:0]            rdata_cam13;
  
   wire [63:0]            rdata_cam14;
  
   wire [63:0]            rdata_cam15;
  
   wire [63:0]            rdata_cam16;
  
   wire [63:0]            rdata_cam17;
  
   wire [63:0]            rdata_cam18;
  
   wire [63:0]            rdata_cam19;
  
   wire [63:0]            rdata_cam20;
  
   wire [63:0]            rdata_cam21;
  
   wire [63:0]            rdata_cam22;
  
   wire [63:0]            rdata_cam23;
  
   wire [63:0]            rdata_cam24;
  
   wire [63:0]            rdata_cam25;
  
   wire [63:0]            rdata_cam26;
  
   wire [63:0]            rdata_cam27;
  
   wire [63:0]            rdata_cam28;
  
   wire [63:0]            rdata_cam29;
  
   wire [63:0]            rdata_cam30;
  
   wire [63:0]            rdata_cam31;
  
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
  
   wire [1:0]             rresp_cam18;
  
   wire [1:0]             rresp_cam19;
  
   wire [1:0]             rresp_cam20;
  
   wire [1:0]             rresp_cam21;
  
   wire [1:0]             rresp_cam22;
  
   wire [1:0]             rresp_cam23;
  
   wire [1:0]             rresp_cam24;
  
   wire [1:0]             rresp_cam25;
  
   wire [1:0]             rresp_cam26;
  
   wire [1:0]             rresp_cam27;
  
   wire [1:0]             rresp_cam28;
  
   wire [1:0]             rresp_cam29;
  
   wire [1:0]             rresp_cam30;
  
   wire [1:0]             rresp_cam31;
  
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
  
   wire                   mask_last18;
  
   wire                   mask_last19;
  
   wire                   mask_last20;
  
   wire                   mask_last21;
  
   wire                   mask_last22;
  
   wire                   mask_last23;
  
   wire                   mask_last24;
  
   wire                   mask_last25;
  
   wire                   mask_last26;
  
   wire                   mask_last27;
  
   wire                   mask_last28;
  
   wire                   mask_last29;
  
   wire                   mask_last30;
  
   wire                   mask_last31;
   
   wire [127:0]           rdata_out;
   wire [1:0]             rresp_out;
   
   
   wire                   fixed_dwnsize;   
   
   wire [3:0]                n_response;
   
   wire [3:0]             addr_mask;
   
   wire [3:0]                next_n_response_reg;
   wire                   n_response_reg_wr_en;
   wire                   slice_required;
    
    
    


   reg [3:0]              downsize;

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
              |  beat_number17
              |  beat_number18
              |  beat_number19
              |  beat_number20
              |  beat_number21
              |  beat_number22
              |  beat_number23
              |  beat_number24
              |  beat_number25
              |  beat_number26
              |  beat_number27
              |  beat_number28
              |  beat_number29
              |  beat_number30
              |  beat_number31;
   
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
              |  rdata_cam17
              |  rdata_cam18
              |  rdata_cam19
              |  rdata_cam20
              |  rdata_cam21
              |  rdata_cam22
              |  rdata_cam23
              |  rdata_cam24
              |  rdata_cam25
              |  rdata_cam26
              |  rdata_cam27
              |  rdata_cam28
              |  rdata_cam29
              |  rdata_cam30
              |  rdata_cam31;
   

   
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
              |  rresp_cam17
              |  rresp_cam18
              |  rresp_cam19
              |  rresp_cam20
              |  rresp_cam21
              |  rresp_cam22
              |  rresp_cam23
              |  rresp_cam24
              |  rresp_cam25
              |  rresp_cam26
              |  rresp_cam27
              |  rresp_cam28
              |  rresp_cam29
              |  rresp_cam30
              |  rresp_cam31;
   
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
              |  mask_last17
              |  mask_last18
              |  mask_last19
              |  mask_last20
              |  mask_last21
              |  mask_last22
              |  mask_last23
              |  mask_last24
              |  mask_last25
              |  mask_last26
              |  mask_last27
              |  mask_last28
              |  mask_last29
              |  mask_last30
              |  mask_last31;

   


   assign rdata_out[127:64] = rdata_m;
  
    
   assign rdata_out[63:0] = rdata_cam[63:0];
  

   assign rlast_out = last_addr_match  && rlast_m;
   
   assign rlast_out_masked = rlast_out & ~mask_last;
   
   assign rresp_out = rresp_cam;
   

  always @(archannel_data)
    begin : downsize_mask_p
      case (archannel_data[2:0])
         `AXI_ASIZE_8    : downsize = {4{1'b0}};
         `AXI_ASIZE_16   : downsize = {{3{1'b0}},{1'b1}};
         `AXI_ASIZE_32   : downsize = {{2{1'b0}},{2'b11}};
         `AXI_ASIZE_64   : downsize = {{1{1'b0}},{3'b111}};
         `AXI_ASIZE_128  : downsize = {{4'b1111}};
         `AXI_ASIZE_256,
       `AXI_ASIZE_512,
       `AXI_ASIZE_1024 : downsize = {4{1'b0}};    
        default : downsize = 4'bx;
      endcase
    end
    
    
    assign ar_cam_data = {arid,araddr,arsize[2:0],fixed_dwnsize,bypass};
    
    assign ar_channel_data = {downsize,archannel_data[13:3]};
    

   
   assign n_response = archannel_data[13:10];
   
   
   assign addr_mask = archannel_data[6:3];
   
   
   
    assign bypass = (archannel_data[2:0] == arsize[2:0]) & (~|n_response);

   
   assign fixed_dwnsize = (|n_response) & (downsize[3]) & (~|addr_mask);
      
   
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

   assign slice_required = (~|n_response_reg) | ((downsize[3]) & (~|addr_mask));
   assign push_slice = archannel_hndshk & slice_required;
   
   always @(valid_bus or match_bus)
     begin : store_decode
        if (!valid_bus[0])
           store = 32'b00000000000000000000000000000001;
         else if (!valid_bus[1])
            store = 32'b00000000000000000000000000000010;
         else if (!valid_bus[2])
            store = 32'b00000000000000000000000000000100;
         else if (!valid_bus[3])
            store = 32'b00000000000000000000000000001000;
         else if (!valid_bus[4])
            store = 32'b00000000000000000000000000010000;
         else if (!valid_bus[5])
            store = 32'b00000000000000000000000000100000;
         else if (!valid_bus[6])
            store = 32'b00000000000000000000000001000000;
         else if (!valid_bus[7])
            store = 32'b00000000000000000000000010000000;
         else if (!valid_bus[8])
            store = 32'b00000000000000000000000100000000;
         else if (!valid_bus[9])
            store = 32'b00000000000000000000001000000000;
         else if (!valid_bus[10])
            store = 32'b00000000000000000000010000000000;
         else if (!valid_bus[11])
            store = 32'b00000000000000000000100000000000;
         else if (!valid_bus[12])
            store = 32'b00000000000000000001000000000000;
         else if (!valid_bus[13])
            store = 32'b00000000000000000010000000000000;
         else if (!valid_bus[14])
            store = 32'b00000000000000000100000000000000;
         else if (!valid_bus[15])
            store = 32'b00000000000000001000000000000000;
         else if (!valid_bus[16])
            store = 32'b00000000000000010000000000000000;
         else if (!valid_bus[17])
            store = 32'b00000000000000100000000000000000;
         else if (!valid_bus[18])
            store = 32'b00000000000001000000000000000000;
         else if (!valid_bus[19])
            store = 32'b00000000000010000000000000000000;
         else if (!valid_bus[20])
            store = 32'b00000000000100000000000000000000;
         else if (!valid_bus[21])
            store = 32'b00000000001000000000000000000000;
         else if (!valid_bus[22])
            store = 32'b00000000010000000000000000000000;
         else if (!valid_bus[23])
            store = 32'b00000000100000000000000000000000;
         else if (!valid_bus[24])
            store = 32'b00000001000000000000000000000000;
         else if (!valid_bus[25])
            store = 32'b00000010000000000000000000000000;
         else if (!valid_bus[26])
            store = 32'b00000100000000000000000000000000;
         else if (!valid_bus[27])
            store = 32'b00001000000000000000000000000000;
         else if (!valid_bus[28])
            store = 32'b00010000000000000000000000000000;
         else if (!valid_bus[29])
            store = 32'b00100000000000000000000000000000;
         else if (!valid_bus[30])
            store = 32'b01000000000000000000000000000000;
         else if (!valid_bus[31])
            store = 32'b10000000000000000000000000000000;
        else
           store = match_bus;
      end 
      
   always @(hazard_bus)
     begin : hazard_num_distibution
       case (hazard_bus)
          32'b0 : hazard_pointer = 5'b0;
           32'd1 : hazard_pointer = 5'd0;
          32'd2 : hazard_pointer = 5'd1;
          32'd4 : hazard_pointer = 5'd2;
          32'd8 : hazard_pointer = 5'd3;
          32'd16 : hazard_pointer = 5'd4;
          32'd32 : hazard_pointer = 5'd5;
          32'd64 : hazard_pointer = 5'd6;
          32'd128 : hazard_pointer = 5'd7;
          32'd256 : hazard_pointer = 5'd8;
          32'd512 : hazard_pointer = 5'd9;
          32'd1024 : hazard_pointer = 5'd10;
          32'd2048 : hazard_pointer = 5'd11;
          32'd4096 : hazard_pointer = 5'd12;
          32'd8192 : hazard_pointer = 5'd13;
          32'd16384 : hazard_pointer = 5'd14;
          32'd32768 : hazard_pointer = 5'd15;
          32'd65536 : hazard_pointer = 5'd16;
          32'd131072 : hazard_pointer = 5'd17;
          32'd262144 : hazard_pointer = 5'd18;
          32'd524288 : hazard_pointer = 5'd19;
          32'd1048576 : hazard_pointer = 5'd20;
          32'd2097152 : hazard_pointer = 5'd21;
          32'd4194304 : hazard_pointer = 5'd22;
          32'd8388608 : hazard_pointer = 5'd23;
          32'd16777216 : hazard_pointer = 5'd24;
          32'd33554432 : hazard_pointer = 5'd25;
          32'd67108864 : hazard_pointer = 5'd26;
          32'd134217728 : hazard_pointer = 5'd27;
          32'd268435456 : hazard_pointer = 5'd28;
          32'd536870912 : hazard_pointer = 5'd29;
          32'd1073741824 : hazard_pointer = 5'd30;
          32'd2147483648 : hazard_pointer = 5'd31;
         default : hazard_pointer = 5'bx;
       endcase
     end
     
   always @(match_bus)
     begin : match_num_distibution
       case (match_bus)
          32'b0 : match_pointer = 5'b0;
           32'd1 : match_pointer = 5'd0;
          32'd2 : match_pointer = 5'd1;
          32'd4 : match_pointer = 5'd2;
          32'd8 : match_pointer = 5'd3;
          32'd16 : match_pointer = 5'd4;
          32'd32 : match_pointer = 5'd5;
          32'd64 : match_pointer = 5'd6;
          32'd128 : match_pointer = 5'd7;
          32'd256 : match_pointer = 5'd8;
          32'd512 : match_pointer = 5'd9;
          32'd1024 : match_pointer = 5'd10;
          32'd2048 : match_pointer = 5'd11;
          32'd4096 : match_pointer = 5'd12;
          32'd8192 : match_pointer = 5'd13;
          32'd16384 : match_pointer = 5'd14;
          32'd32768 : match_pointer = 5'd15;
          32'd65536 : match_pointer = 5'd16;
          32'd131072 : match_pointer = 5'd17;
          32'd262144 : match_pointer = 5'd18;
          32'd524288 : match_pointer = 5'd19;
          32'd1048576 : match_pointer = 5'd20;
          32'd2097152 : match_pointer = 5'd21;
          32'd4194304 : match_pointer = 5'd22;
          32'd8388608 : match_pointer = 5'd23;
          32'd16777216 : match_pointer = 5'd24;
          32'd33554432 : match_pointer = 5'd25;
          32'd67108864 : match_pointer = 5'd26;
          32'd134217728 : match_pointer = 5'd27;
          32'd268435456 : match_pointer = 5'd28;
          32'd536870912 : match_pointer = 5'd29;
          32'd1073741824 : match_pointer = 5'd30;
          32'd2147483648 : match_pointer = 5'd31;
         default : match_pointer = 5'bx;
       endcase
     end

   assign beat_complete = (rlast_out | beat_complete_slice) && update;

   
   assign rready_m = (beat_complete | (~beat_complete_slice)) && rvalid_m;

   assign rvalid_s = beat_complete_slice && rvalid_m;
   

   assign rchannel_hndshk = rvalid_s && rready_s;
      
   assign update = rchannel_hndshk;

   assign clear_slice = {32{update}} & match_bus;

   assign cam_update = rvalid_m & rready_m;

   assign pop_slice = update && rlast_out;


    
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_0
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
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_1
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
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_2
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
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_3
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
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_4
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
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_5
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
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_6
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
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_7
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
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_8
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
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_9
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
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_10
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
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_11
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
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_12
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
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_13
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
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_14
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
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_15
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
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_16
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
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_17
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
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_18
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[18]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[18]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[18]),
        .match                (match_bus[18]),
        .valid                (valid_bus[18]),
        .last_addr_match      (last_addr_match_bus[18]),
        .beat_complete        (beat_complete_slice_bus[18]),
        .beat_number          (beat_number18),
        
        .rdata_cam            (rdata_cam18),
        
        .rresp_cam            (rresp_cam18),
        
        .mask_last            (mask_last18)
     );
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_19
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[19]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[19]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[19]),
        .match                (match_bus[19]),
        .valid                (valid_bus[19]),
        .last_addr_match      (last_addr_match_bus[19]),
        .beat_complete        (beat_complete_slice_bus[19]),
        .beat_number          (beat_number19),
        
        .rdata_cam            (rdata_cam19),
        
        .rresp_cam            (rresp_cam19),
        
        .mask_last            (mask_last19)
     );
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_20
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[20]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[20]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[20]),
        .match                (match_bus[20]),
        .valid                (valid_bus[20]),
        .last_addr_match      (last_addr_match_bus[20]),
        .beat_complete        (beat_complete_slice_bus[20]),
        .beat_number          (beat_number20),
        
        .rdata_cam            (rdata_cam20),
        
        .rresp_cam            (rresp_cam20),
        
        .mask_last            (mask_last20)
     );
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_21
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[21]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[21]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[21]),
        .match                (match_bus[21]),
        .valid                (valid_bus[21]),
        .last_addr_match      (last_addr_match_bus[21]),
        .beat_complete        (beat_complete_slice_bus[21]),
        .beat_number          (beat_number21),
        
        .rdata_cam            (rdata_cam21),
        
        .rresp_cam            (rresp_cam21),
        
        .mask_last            (mask_last21)
     );
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_22
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[22]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[22]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[22]),
        .match                (match_bus[22]),
        .valid                (valid_bus[22]),
        .last_addr_match      (last_addr_match_bus[22]),
        .beat_complete        (beat_complete_slice_bus[22]),
        .beat_number          (beat_number22),
        
        .rdata_cam            (rdata_cam22),
        
        .rresp_cam            (rresp_cam22),
        
        .mask_last            (mask_last22)
     );
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_23
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[23]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[23]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[23]),
        .match                (match_bus[23]),
        .valid                (valid_bus[23]),
        .last_addr_match      (last_addr_match_bus[23]),
        .beat_complete        (beat_complete_slice_bus[23]),
        .beat_number          (beat_number23),
        
        .rdata_cam            (rdata_cam23),
        
        .rresp_cam            (rresp_cam23),
        
        .mask_last            (mask_last23)
     );
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_24
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[24]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[24]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[24]),
        .match                (match_bus[24]),
        .valid                (valid_bus[24]),
        .last_addr_match      (last_addr_match_bus[24]),
        .beat_complete        (beat_complete_slice_bus[24]),
        .beat_number          (beat_number24),
        
        .rdata_cam            (rdata_cam24),
        
        .rresp_cam            (rresp_cam24),
        
        .mask_last            (mask_last24)
     );
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_25
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[25]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[25]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[25]),
        .match                (match_bus[25]),
        .valid                (valid_bus[25]),
        .last_addr_match      (last_addr_match_bus[25]),
        .beat_complete        (beat_complete_slice_bus[25]),
        .beat_number          (beat_number25),
        
        .rdata_cam            (rdata_cam25),
        
        .rresp_cam            (rresp_cam25),
        
        .mask_last            (mask_last25)
     );
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_26
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[26]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[26]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[26]),
        .match                (match_bus[26]),
        .valid                (valid_bus[26]),
        .last_addr_match      (last_addr_match_bus[26]),
        .beat_complete        (beat_complete_slice_bus[26]),
        .beat_number          (beat_number26),
        
        .rdata_cam            (rdata_cam26),
        
        .rresp_cam            (rresp_cam26),
        
        .mask_last            (mask_last26)
     );
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_27
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[27]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[27]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[27]),
        .match                (match_bus[27]),
        .valid                (valid_bus[27]),
        .last_addr_match      (last_addr_match_bus[27]),
        .beat_complete        (beat_complete_slice_bus[27]),
        .beat_number          (beat_number27),
        
        .rdata_cam            (rdata_cam27),
        
        .rresp_cam            (rresp_cam27),
        
        .mask_last            (mask_last27)
     );
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_28
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[28]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[28]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[28]),
        .match                (match_bus[28]),
        .valid                (valid_bus[28]),
        .last_addr_match      (last_addr_match_bus[28]),
        .beat_complete        (beat_complete_slice_bus[28]),
        .beat_number          (beat_number28),
        
        .rdata_cam            (rdata_cam28),
        
        .rresp_cam            (rresp_cam28),
        
        .mask_last            (mask_last28)
     );
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_29
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[29]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[29]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[29]),
        .match                (match_bus[29]),
        .valid                (valid_bus[29]),
        .last_addr_match      (last_addr_match_bus[29]),
        .beat_complete        (beat_complete_slice_bus[29]),
        .beat_number          (beat_number29),
        
        .rdata_cam            (rdata_cam29),
        
        .rresp_cam            (rresp_cam29),
        
        .mask_last            (mask_last29)
     );
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_30
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[30]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[30]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[30]),
        .match                (match_bus[30]),
        .valid                (valid_bus[30]),
        .last_addr_match      (last_addr_match_bus[30]),
        .beat_complete        (beat_complete_slice_bus[30]),
        .beat_number          (beat_number30),
        
        .rdata_cam            (rdata_cam30),
        
        .rresp_cam            (rresp_cam30),
        
        .mask_last            (mask_last30)
     );
     
     nic400_ib_hostcpu_axis_ib_downsize_rd_cam_slice_sse710_main u_downsize_rd_cam_slice_31
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .match_id              (rid_m),      

        .store                (store[31]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (cam_update),
        .clear_slice          (clear_slice[31]),
        .match_pointer        (match_pointer),

        .archannel_data       (ar_channel_data),
        
        .ar_cam_data          (ar_cam_data),
        
        .rdata_m              (rdata_m),
        .rresp_m              (rresp_m),
        .rlast_m              (rlast_m),
         
        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),
   
        .hazard               (hazard_bus[31]),
        .match                (match_bus[31]),
        .valid                (valid_bus[31]),
        .last_addr_match      (last_addr_match_bus[31]),
        .beat_complete        (beat_complete_slice_bus[31]),
        .beat_number          (beat_number31),
        
        .rdata_cam            (rdata_cam31),
        
        .rresp_cam            (rresp_cam31),
        
        .mask_last            (mask_last31)
     );
     


`ifdef ARM_ASSERT_ON
`include "std_ovl_defines.h"


  assert_zero_one_hot #(0,32,0,"More than one Rd Channel Slice matched")
  ovl_single_ID_match
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .test_expr        ({32{rchannel_hndshk}} & match_bus)
     );


  assert_zero_one_hot #(0,32,0,"More than one R Channel Slice hazard")
  ovl_single_hazard
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .test_expr        ({32{archannel_hndshk}} & hazard_bus)
     );


  wire [7:0]    cam_id_reg [0:31];

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
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 0) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 0) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 0) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 0) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 0) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 0) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 0) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 0) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 0) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 0) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 0) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 0) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 0) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 0) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 0)))
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
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 1) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 1) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 1) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 1) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 1) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 1) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 1) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 1) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 1) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 1) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 1) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 1) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 1) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 1) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 1)))
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
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 2) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 2) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 2) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 2) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 2) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 2) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 2) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 2) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 2) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 2) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 2) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 2) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 2) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 2) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 2)))
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
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 3) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 3) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 3) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 3) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 3) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 3) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 3) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 3) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 3) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 3) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 3) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 3) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 3) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 3) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 3)))
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
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 4) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 4) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 4) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 4) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 4) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 4) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 4) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 4) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 4) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 4) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 4) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 4) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 4) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 4) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 4)))
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
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 5) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 5) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 5) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 5) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 5) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 5) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 5) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 5) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 5) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 5) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 5) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 5) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 5) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 5) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 5)))
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
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 6) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 6) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 6) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 6) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 6) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 6) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 6) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 6) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 6) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 6) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 6) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 6) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 6) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 6) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 6)))
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
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 7) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 7) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 7) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 7) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 7) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 7) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 7) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 7) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 7) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 7) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 7) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 7) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 7) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 7) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 7)))
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
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 8) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 8) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 8) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 8) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 8) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 8) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 8) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 8) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 8) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 8) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 8) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 8) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 8) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 8) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 8)))
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
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 9) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 9) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 9) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 9) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 9) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 9) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 9) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 9) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 9) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 9) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 9) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 9) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 9) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 9) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 9)))
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
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 10) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 10) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 10) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 10) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 10) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 10) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 10) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 10) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 10) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 10) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 10) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 10) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 10) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 10) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 10)))
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
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 11) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 11) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 11) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 11) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 11) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 11) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 11) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 11) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 11) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 11) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 11) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 11) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 11) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 11) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 11)))
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
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 12) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 12) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 12) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 12) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 12) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 12) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 12) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 12) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 12) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 12) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 12) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 12) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 12) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 12) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 12)))
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
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 13) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 13) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 13) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 13) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 13) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 13) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 13) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 13) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 13) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 13) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 13) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 13) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 13) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 13) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 13)))
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
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 14) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 14) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 14) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 14) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 14) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 14) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 14) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 14) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 14) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 14) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 14) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 14) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 14) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 14) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 14)))
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
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 15) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 15) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 15) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 15) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 15) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 15) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 15) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 15) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 15) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 15) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 15) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 15) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 15) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 15) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 15)))
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
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 16) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 16) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 16) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 16) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 16) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 16) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 16) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 16) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 16) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 16) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 16) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 16) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 16) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 16) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 16)))
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
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 17) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 17) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 17) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 17) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 17) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 17) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 17) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 17) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 17) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 17) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 17) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 17) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 17) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 17) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 17)))
     );
  
  assign cam_id_reg[18] = u_downsize_rd_cam_slice_18.id_reg;


  assert_implication #(0,0,"CAM 18 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_18_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_18.pointer_reg] && (cam_id_reg[18] == cam_id_reg[u_downsize_rd_cam_slice_18.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 18 is last but is pointed to by another valid CAM")
  ovl_cam_18_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[18] && u_downsize_rd_cam_slice_18.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 18) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 18) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 18) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 18) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 18) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 18) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 18) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 18) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 18) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 18) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 18) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 18) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 18) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 18) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 18) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 18) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 18) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 18) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 18) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 18) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 18) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 18) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 18) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 18) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 18) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 18) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 18) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 18) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 18) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 18) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 18)))
     );
  
  assign cam_id_reg[19] = u_downsize_rd_cam_slice_19.id_reg;


  assert_implication #(0,0,"CAM 19 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_19_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_19.pointer_reg] && (cam_id_reg[19] == cam_id_reg[u_downsize_rd_cam_slice_19.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 19 is last but is pointed to by another valid CAM")
  ovl_cam_19_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[19] && u_downsize_rd_cam_slice_19.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 19) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 19) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 19) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 19) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 19) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 19) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 19) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 19) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 19) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 19) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 19) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 19) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 19) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 19) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 19) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 19) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 19) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 19) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 19) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 19) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 19) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 19) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 19) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 19) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 19) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 19) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 19) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 19) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 19) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 19) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 19)))
     );
  
  assign cam_id_reg[20] = u_downsize_rd_cam_slice_20.id_reg;


  assert_implication #(0,0,"CAM 20 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_20_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_20.pointer_reg] && (cam_id_reg[20] == cam_id_reg[u_downsize_rd_cam_slice_20.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 20 is last but is pointed to by another valid CAM")
  ovl_cam_20_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[20] && u_downsize_rd_cam_slice_20.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 20) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 20) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 20) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 20) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 20) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 20) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 20) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 20) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 20) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 20) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 20) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 20) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 20) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 20) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 20) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 20) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 20) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 20) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 20) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 20) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 20) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 20) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 20) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 20) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 20) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 20) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 20) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 20) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 20) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 20) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 20)))
     );
  
  assign cam_id_reg[21] = u_downsize_rd_cam_slice_21.id_reg;


  assert_implication #(0,0,"CAM 21 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_21_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_21.pointer_reg] && (cam_id_reg[21] == cam_id_reg[u_downsize_rd_cam_slice_21.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 21 is last but is pointed to by another valid CAM")
  ovl_cam_21_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[21] && u_downsize_rd_cam_slice_21.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 21) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 21) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 21) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 21) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 21) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 21) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 21) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 21) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 21) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 21) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 21) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 21) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 21) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 21) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 21) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 21) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 21) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 21) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 21) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 21) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 21) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 21) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 21) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 21) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 21) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 21) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 21) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 21) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 21) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 21) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 21)))
     );
  
  assign cam_id_reg[22] = u_downsize_rd_cam_slice_22.id_reg;


  assert_implication #(0,0,"CAM 22 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_22_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_22.pointer_reg] && (cam_id_reg[22] == cam_id_reg[u_downsize_rd_cam_slice_22.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 22 is last but is pointed to by another valid CAM")
  ovl_cam_22_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[22] && u_downsize_rd_cam_slice_22.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 22) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 22) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 22) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 22) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 22) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 22) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 22) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 22) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 22) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 22) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 22) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 22) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 22) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 22) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 22) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 22) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 22) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 22) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 22) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 22) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 22) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 22) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 22) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 22) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 22) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 22) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 22) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 22) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 22) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 22) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 22)))
     );
  
  assign cam_id_reg[23] = u_downsize_rd_cam_slice_23.id_reg;


  assert_implication #(0,0,"CAM 23 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_23_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_23.pointer_reg] && (cam_id_reg[23] == cam_id_reg[u_downsize_rd_cam_slice_23.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 23 is last but is pointed to by another valid CAM")
  ovl_cam_23_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[23] && u_downsize_rd_cam_slice_23.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 23) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 23) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 23) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 23) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 23) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 23) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 23) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 23) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 23) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 23) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 23) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 23) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 23) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 23) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 23) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 23) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 23) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 23) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 23) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 23) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 23) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 23) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 23) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 23) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 23) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 23) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 23) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 23) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 23) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 23) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 23)))
     );
  
  assign cam_id_reg[24] = u_downsize_rd_cam_slice_24.id_reg;


  assert_implication #(0,0,"CAM 24 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_24_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_24.pointer_reg] && (cam_id_reg[24] == cam_id_reg[u_downsize_rd_cam_slice_24.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 24 is last but is pointed to by another valid CAM")
  ovl_cam_24_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[24] && u_downsize_rd_cam_slice_24.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 24) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 24) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 24) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 24) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 24) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 24) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 24) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 24) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 24) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 24) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 24) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 24) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 24) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 24) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 24) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 24) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 24) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 24) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 24) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 24) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 24) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 24) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 24) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 24) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 24) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 24) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 24) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 24) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 24) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 24) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 24)))
     );
  
  assign cam_id_reg[25] = u_downsize_rd_cam_slice_25.id_reg;


  assert_implication #(0,0,"CAM 25 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_25_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_25.pointer_reg] && (cam_id_reg[25] == cam_id_reg[u_downsize_rd_cam_slice_25.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 25 is last but is pointed to by another valid CAM")
  ovl_cam_25_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[25] && u_downsize_rd_cam_slice_25.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 25) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 25) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 25) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 25) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 25) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 25) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 25) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 25) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 25) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 25) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 25) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 25) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 25) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 25) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 25) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 25) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 25) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 25) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 25) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 25) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 25) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 25) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 25) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 25) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 25) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 25) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 25) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 25) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 25) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 25) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 25)))
     );
  
  assign cam_id_reg[26] = u_downsize_rd_cam_slice_26.id_reg;


  assert_implication #(0,0,"CAM 26 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_26_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_26.pointer_reg] && (cam_id_reg[26] == cam_id_reg[u_downsize_rd_cam_slice_26.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 26 is last but is pointed to by another valid CAM")
  ovl_cam_26_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[26] && u_downsize_rd_cam_slice_26.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 26) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 26) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 26) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 26) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 26) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 26) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 26) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 26) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 26) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 26) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 26) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 26) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 26) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 26) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 26) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 26) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 26) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 26) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 26) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 26) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 26) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 26) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 26) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 26) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 26) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 26) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 26) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 26) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 26) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 26) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 26)))
     );
  
  assign cam_id_reg[27] = u_downsize_rd_cam_slice_27.id_reg;


  assert_implication #(0,0,"CAM 27 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_27_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_27.pointer_reg] && (cam_id_reg[27] == cam_id_reg[u_downsize_rd_cam_slice_27.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 27 is last but is pointed to by another valid CAM")
  ovl_cam_27_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[27] && u_downsize_rd_cam_slice_27.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 27) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 27) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 27) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 27) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 27) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 27) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 27) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 27) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 27) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 27) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 27) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 27) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 27) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 27) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 27) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 27) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 27) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 27) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 27) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 27) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 27) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 27) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 27) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 27) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 27) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 27) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 27) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 27) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 27) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 27) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 27)))
     );
  
  assign cam_id_reg[28] = u_downsize_rd_cam_slice_28.id_reg;


  assert_implication #(0,0,"CAM 28 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_28_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_28.pointer_reg] && (cam_id_reg[28] == cam_id_reg[u_downsize_rd_cam_slice_28.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 28 is last but is pointed to by another valid CAM")
  ovl_cam_28_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[28] && u_downsize_rd_cam_slice_28.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 28) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 28) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 28) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 28) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 28) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 28) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 28) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 28) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 28) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 28) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 28) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 28) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 28) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 28) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 28) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 28) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 28) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 28) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 28) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 28) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 28) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 28) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 28) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 28) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 28) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 28) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 28) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 28) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 28) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 28) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 28)))
     );
  
  assign cam_id_reg[29] = u_downsize_rd_cam_slice_29.id_reg;


  assert_implication #(0,0,"CAM 29 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_29_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_29.pointer_reg] && (cam_id_reg[29] == cam_id_reg[u_downsize_rd_cam_slice_29.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 29 is last but is pointed to by another valid CAM")
  ovl_cam_29_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[29] && u_downsize_rd_cam_slice_29.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 29) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 29) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 29) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 29) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 29) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 29) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 29) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 29) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 29) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 29) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 29) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 29) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 29) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 29) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 29) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 29) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 29) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 29) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 29) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 29) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 29) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 29) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 29) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 29) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 29) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 29) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 29) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 29) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 29) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 29) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 29)))
     );
  
  assign cam_id_reg[30] = u_downsize_rd_cam_slice_30.id_reg;


  assert_implication #(0,0,"CAM 30 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_30_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_30.pointer_reg] && (cam_id_reg[30] == cam_id_reg[u_downsize_rd_cam_slice_30.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 30 is last but is pointed to by another valid CAM")
  ovl_cam_30_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[30] && u_downsize_rd_cam_slice_30.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 30) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 30) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 30) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 30) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 30) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 30) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 30) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 30) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 30) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 30) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 30) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 30) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 30) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 30) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 30) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 30) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 30) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 30) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 30) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 30) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 30) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 30) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 30) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 30) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 30) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 30) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 30) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 30) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 30) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 30) ||
                          (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg && u_downsize_rd_cam_slice_31.pointer_reg == 30)))
     );
  
  assign cam_id_reg[31] = u_downsize_rd_cam_slice_31.id_reg;


  assert_implication #(0,0,"CAM 31 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_31_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[31] && u_downsize_rd_cam_slice_31.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_rd_cam_slice_31.pointer_reg] && (cam_id_reg[31] == cam_id_reg[u_downsize_rd_cam_slice_31.pointer_reg]))
     );


  assert_implication #(0,0,"CAM 31 is last but is pointed to by another valid CAM")
  ovl_cam_31_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[31] && u_downsize_rd_cam_slice_31.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_rd_cam_slice_0.hazard_reg && u_downsize_rd_cam_slice_0.pointer_reg == 31) ||
                          (valid_bus[1] && u_downsize_rd_cam_slice_1.hazard_reg && u_downsize_rd_cam_slice_1.pointer_reg == 31) ||
                          (valid_bus[2] && u_downsize_rd_cam_slice_2.hazard_reg && u_downsize_rd_cam_slice_2.pointer_reg == 31) ||
                          (valid_bus[3] && u_downsize_rd_cam_slice_3.hazard_reg && u_downsize_rd_cam_slice_3.pointer_reg == 31) ||
                          (valid_bus[4] && u_downsize_rd_cam_slice_4.hazard_reg && u_downsize_rd_cam_slice_4.pointer_reg == 31) ||
                          (valid_bus[5] && u_downsize_rd_cam_slice_5.hazard_reg && u_downsize_rd_cam_slice_5.pointer_reg == 31) ||
                          (valid_bus[6] && u_downsize_rd_cam_slice_6.hazard_reg && u_downsize_rd_cam_slice_6.pointer_reg == 31) ||
                          (valid_bus[7] && u_downsize_rd_cam_slice_7.hazard_reg && u_downsize_rd_cam_slice_7.pointer_reg == 31) ||
                          (valid_bus[8] && u_downsize_rd_cam_slice_8.hazard_reg && u_downsize_rd_cam_slice_8.pointer_reg == 31) ||
                          (valid_bus[9] && u_downsize_rd_cam_slice_9.hazard_reg && u_downsize_rd_cam_slice_9.pointer_reg == 31) ||
                          (valid_bus[10] && u_downsize_rd_cam_slice_10.hazard_reg && u_downsize_rd_cam_slice_10.pointer_reg == 31) ||
                          (valid_bus[11] && u_downsize_rd_cam_slice_11.hazard_reg && u_downsize_rd_cam_slice_11.pointer_reg == 31) ||
                          (valid_bus[12] && u_downsize_rd_cam_slice_12.hazard_reg && u_downsize_rd_cam_slice_12.pointer_reg == 31) ||
                          (valid_bus[13] && u_downsize_rd_cam_slice_13.hazard_reg && u_downsize_rd_cam_slice_13.pointer_reg == 31) ||
                          (valid_bus[14] && u_downsize_rd_cam_slice_14.hazard_reg && u_downsize_rd_cam_slice_14.pointer_reg == 31) ||
                          (valid_bus[15] && u_downsize_rd_cam_slice_15.hazard_reg && u_downsize_rd_cam_slice_15.pointer_reg == 31) ||
                          (valid_bus[16] && u_downsize_rd_cam_slice_16.hazard_reg && u_downsize_rd_cam_slice_16.pointer_reg == 31) ||
                          (valid_bus[17] && u_downsize_rd_cam_slice_17.hazard_reg && u_downsize_rd_cam_slice_17.pointer_reg == 31) ||
                          (valid_bus[18] && u_downsize_rd_cam_slice_18.hazard_reg && u_downsize_rd_cam_slice_18.pointer_reg == 31) ||
                          (valid_bus[19] && u_downsize_rd_cam_slice_19.hazard_reg && u_downsize_rd_cam_slice_19.pointer_reg == 31) ||
                          (valid_bus[20] && u_downsize_rd_cam_slice_20.hazard_reg && u_downsize_rd_cam_slice_20.pointer_reg == 31) ||
                          (valid_bus[21] && u_downsize_rd_cam_slice_21.hazard_reg && u_downsize_rd_cam_slice_21.pointer_reg == 31) ||
                          (valid_bus[22] && u_downsize_rd_cam_slice_22.hazard_reg && u_downsize_rd_cam_slice_22.pointer_reg == 31) ||
                          (valid_bus[23] && u_downsize_rd_cam_slice_23.hazard_reg && u_downsize_rd_cam_slice_23.pointer_reg == 31) ||
                          (valid_bus[24] && u_downsize_rd_cam_slice_24.hazard_reg && u_downsize_rd_cam_slice_24.pointer_reg == 31) ||
                          (valid_bus[25] && u_downsize_rd_cam_slice_25.hazard_reg && u_downsize_rd_cam_slice_25.pointer_reg == 31) ||
                          (valid_bus[26] && u_downsize_rd_cam_slice_26.hazard_reg && u_downsize_rd_cam_slice_26.pointer_reg == 31) ||
                          (valid_bus[27] && u_downsize_rd_cam_slice_27.hazard_reg && u_downsize_rd_cam_slice_27.pointer_reg == 31) ||
                          (valid_bus[28] && u_downsize_rd_cam_slice_28.hazard_reg && u_downsize_rd_cam_slice_28.pointer_reg == 31) ||
                          (valid_bus[29] && u_downsize_rd_cam_slice_29.hazard_reg && u_downsize_rd_cam_slice_29.pointer_reg == 31) ||
                          (valid_bus[30] && u_downsize_rd_cam_slice_30.hazard_reg && u_downsize_rd_cam_slice_30.pointer_reg == 31)))
     );
  
     
     wire        arsize_out_range;
 
     assign      arsize_out_range = archannel_valid && (archannel_data[2:0] > `AXI_ASIZE_128);
                                                                                             
     wire        illegal_downsize;        

     assign illegal_downsize =  (downsize == {4{1'b0}}) & arsize_out_range;

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

`include "nic400_ib_hostcpu_axis_ib_undefs_sse710_main.v"
`include "Axi_undefs.v"


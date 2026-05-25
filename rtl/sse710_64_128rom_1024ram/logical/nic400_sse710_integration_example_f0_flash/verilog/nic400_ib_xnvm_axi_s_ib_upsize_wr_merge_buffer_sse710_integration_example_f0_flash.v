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


module nic400_ib_xnvm_axi_s_ib_upsize_wr_merge_buffer_sse710_integration_example_f0_flash
  (
  wdata_out, 
  wstrb_out,
  merge_skid_valid,
  
  wdata_in, 
  wstrb_in,
  data_select, 
  merge, 
  merge_clear,
   
  aclk, 
  aresetn
  );

  input                                 aclk;
  input                                 aresetn;

  output [127:0]                        wdata_out;
  output [15:0]                         wstrb_out;
  output                                merge_skid_valid;

  input  [63:0]                         wdata_in;
  input  [7:0]                          wstrb_in;

  input  [1:0]                          data_select;       
  input                                 merge;
  input                                 merge_clear;
  
 
   wire  [127:0]                        wide_wdata_in; 
   wire  [15:0]                         wide_wstrb_in;
   wire  [15:0]                         wide_wstrb_masked;
   wire  [15:0]                         wstrb_out_i;

   wire                                 update_strb;           
   wire                                 strb_skid_valid_wr;    
   wire                                 strb_skid_valid_nxt;   
   wire                                 all_bytes;             

   
   wire                                 merge_byte_15;
   wire                                 merge_strb_15;
   wire                                 next_strb_15;

   wire                                 merge_byte_14;
   wire                                 merge_strb_14;
   wire                                 next_strb_14;

   wire                                 merge_byte_13;
   wire                                 merge_strb_13;
   wire                                 next_strb_13;

   wire                                 merge_byte_12;
   wire                                 merge_strb_12;
   wire                                 next_strb_12;

   wire                                 merge_byte_11;
   wire                                 merge_strb_11;
   wire                                 next_strb_11;

   wire                                 merge_byte_10;
   wire                                 merge_strb_10;
   wire                                 next_strb_10;

   wire                                 merge_byte_9;
   wire                                 merge_strb_9;
   wire                                 next_strb_9;

   wire                                 merge_byte_8;
   wire                                 merge_strb_8;
   wire                                 next_strb_8;

   wire                                 merge_byte_7;
   wire                                 merge_strb_7;
   wire                                 next_strb_7;

   wire                                 merge_byte_6;
   wire                                 merge_strb_6;
   wire                                 next_strb_6;

   wire                                 merge_byte_5;
   wire                                 merge_strb_5;
   wire                                 next_strb_5;

   wire                                 merge_byte_4;
   wire                                 merge_strb_4;
   wire                                 next_strb_4;

   wire                                 merge_byte_3;
   wire                                 merge_strb_3;
   wire                                 next_strb_3;

   wire                                 merge_byte_2;
   wire                                 merge_strb_2;
   wire                                 next_strb_2;

   wire                                 merge_byte_1;
   wire                                 merge_strb_1;
   wire                                 next_strb_1;

   wire                                 merge_byte_0;
   wire                                 merge_strb_0;
   wire                                 next_strb_0;



   reg                                  strb_skid_valid;

   
   reg [7:0]                            merged_byte_15;
   reg                                  merged_strb_15;

   reg [7:0]                            merged_byte_14;
   reg                                  merged_strb_14;

   reg [7:0]                            merged_byte_13;
   reg                                  merged_strb_13;

   reg [7:0]                            merged_byte_12;
   reg                                  merged_strb_12;

   reg [7:0]                            merged_byte_11;
   reg                                  merged_strb_11;

   reg [7:0]                            merged_byte_10;
   reg                                  merged_strb_10;

   reg [7:0]                            merged_byte_9;
   reg                                  merged_strb_9;

   reg [7:0]                            merged_byte_8;
   reg                                  merged_strb_8;

   reg [7:0]                            merged_byte_7;
   reg                                  merged_strb_7;

   reg [7:0]                            merged_byte_6;
   reg                                  merged_strb_6;

   reg [7:0]                            merged_byte_5;
   reg                                  merged_strb_5;

   reg [7:0]                            merged_byte_4;
   reg                                  merged_strb_4;

   reg [7:0]                            merged_byte_3;
   reg                                  merged_strb_3;

   reg [7:0]                            merged_byte_2;
   reg                                  merged_strb_2;

   reg [7:0]                            merged_byte_1;
   reg                                  merged_strb_1;

   reg [7:0]                            merged_byte_0;
   reg                                  merged_strb_0;



   assign wide_wdata_in     = {2{wdata_in}}; 
   assign wide_wstrb_masked = {2{wstrb_in}} | {16{all_bytes}}; 
   assign wide_wstrb_in     = {2{wstrb_in}};

   assign all_bytes = data_select == {2{1'b1}};

   assign update_strb = merge_clear || (merge && all_bytes) 
                        || (~all_bytes && strb_skid_valid); 

   assign strb_skid_valid_wr = (merge && all_bytes) || update_strb;

   assign strb_skid_valid_nxt = merge && all_bytes;

   always @(posedge aclk or negedge aresetn) 
     begin : strb_skid_valid_p
        if (!aresetn)  
           strb_skid_valid <= 1'b0;
        else if (strb_skid_valid_wr)
           strb_skid_valid <= strb_skid_valid_nxt;
     end

   assign merge_skid_valid = strb_skid_valid;
   


   

   assign merge_byte_15 = merge && data_select[1] && wide_wstrb_masked[15];
   assign wdata_out[127:120] = merge_byte_15 ? wide_wdata_in[127:120] : merged_byte_15;

   always @(posedge aclk)
     begin : byte_15_seq
       if (merge_byte_15)
          merged_byte_15 <= wide_wdata_in[127:120];
     end 

   assign merge_strb_15 = merge_byte_15 || update_strb;
   
   assign wstrb_out_i[15] = merge_byte_15 ? wide_wstrb_in[15] :
                           (((strb_skid_valid && data_select[1]) || (~strb_skid_valid && ~update_strb)) ? merged_strb_15 : 1'b0);
   assign wstrb_out[15] = wstrb_out_i[15];
   assign next_strb_15 = wstrb_out_i[15];

   always @(posedge aclk or negedge aresetn)
     begin : byte_15_strb_seq
       if (!aresetn)
          merged_strb_15 <= 1'b0;      
       else if (merge_strb_15)
          merged_strb_15 <= next_strb_15;
     end 

     

   assign merge_byte_14 = merge && data_select[1] && wide_wstrb_masked[14];
   assign wdata_out[119:112] = merge_byte_14 ? wide_wdata_in[119:112] : merged_byte_14;

   always @(posedge aclk)
     begin : byte_14_seq
       if (merge_byte_14)
          merged_byte_14 <= wide_wdata_in[119:112];
     end 

   assign merge_strb_14 = merge_byte_14 || update_strb;
   
   assign wstrb_out_i[14] = merge_byte_14 ? wide_wstrb_in[14] :
                           (((strb_skid_valid && data_select[1]) || (~strb_skid_valid && ~update_strb)) ? merged_strb_14 : 1'b0);
   assign wstrb_out[14] = wstrb_out_i[14];
   assign next_strb_14 = wstrb_out_i[14];

   always @(posedge aclk or negedge aresetn)
     begin : byte_14_strb_seq
       if (!aresetn)
          merged_strb_14 <= 1'b0;      
       else if (merge_strb_14)
          merged_strb_14 <= next_strb_14;
     end 

     

   assign merge_byte_13 = merge && data_select[1] && wide_wstrb_masked[13];
   assign wdata_out[111:104] = merge_byte_13 ? wide_wdata_in[111:104] : merged_byte_13;

   always @(posedge aclk)
     begin : byte_13_seq
       if (merge_byte_13)
          merged_byte_13 <= wide_wdata_in[111:104];
     end 

   assign merge_strb_13 = merge_byte_13 || update_strb;
   
   assign wstrb_out_i[13] = merge_byte_13 ? wide_wstrb_in[13] :
                           (((strb_skid_valid && data_select[1]) || (~strb_skid_valid && ~update_strb)) ? merged_strb_13 : 1'b0);
   assign wstrb_out[13] = wstrb_out_i[13];
   assign next_strb_13 = wstrb_out_i[13];

   always @(posedge aclk or negedge aresetn)
     begin : byte_13_strb_seq
       if (!aresetn)
          merged_strb_13 <= 1'b0;      
       else if (merge_strb_13)
          merged_strb_13 <= next_strb_13;
     end 

     

   assign merge_byte_12 = merge && data_select[1] && wide_wstrb_masked[12];
   assign wdata_out[103:96] = merge_byte_12 ? wide_wdata_in[103:96] : merged_byte_12;

   always @(posedge aclk)
     begin : byte_12_seq
       if (merge_byte_12)
          merged_byte_12 <= wide_wdata_in[103:96];
     end 

   assign merge_strb_12 = merge_byte_12 || update_strb;
   
   assign wstrb_out_i[12] = merge_byte_12 ? wide_wstrb_in[12] :
                           (((strb_skid_valid && data_select[1]) || (~strb_skid_valid && ~update_strb)) ? merged_strb_12 : 1'b0);
   assign wstrb_out[12] = wstrb_out_i[12];
   assign next_strb_12 = wstrb_out_i[12];

   always @(posedge aclk or negedge aresetn)
     begin : byte_12_strb_seq
       if (!aresetn)
          merged_strb_12 <= 1'b0;      
       else if (merge_strb_12)
          merged_strb_12 <= next_strb_12;
     end 

     

   assign merge_byte_11 = merge && data_select[1] && wide_wstrb_masked[11];
   assign wdata_out[95:88] = merge_byte_11 ? wide_wdata_in[95:88] : merged_byte_11;

   always @(posedge aclk)
     begin : byte_11_seq
       if (merge_byte_11)
          merged_byte_11 <= wide_wdata_in[95:88];
     end 

   assign merge_strb_11 = merge_byte_11 || update_strb;
   
   assign wstrb_out_i[11] = merge_byte_11 ? wide_wstrb_in[11] :
                           (((strb_skid_valid && data_select[1]) || (~strb_skid_valid && ~update_strb)) ? merged_strb_11 : 1'b0);
   assign wstrb_out[11] = wstrb_out_i[11];
   assign next_strb_11 = wstrb_out_i[11];

   always @(posedge aclk or negedge aresetn)
     begin : byte_11_strb_seq
       if (!aresetn)
          merged_strb_11 <= 1'b0;      
       else if (merge_strb_11)
          merged_strb_11 <= next_strb_11;
     end 

     

   assign merge_byte_10 = merge && data_select[1] && wide_wstrb_masked[10];
   assign wdata_out[87:80] = merge_byte_10 ? wide_wdata_in[87:80] : merged_byte_10;

   always @(posedge aclk)
     begin : byte_10_seq
       if (merge_byte_10)
          merged_byte_10 <= wide_wdata_in[87:80];
     end 

   assign merge_strb_10 = merge_byte_10 || update_strb;
   
   assign wstrb_out_i[10] = merge_byte_10 ? wide_wstrb_in[10] :
                           (((strb_skid_valid && data_select[1]) || (~strb_skid_valid && ~update_strb)) ? merged_strb_10 : 1'b0);
   assign wstrb_out[10] = wstrb_out_i[10];
   assign next_strb_10 = wstrb_out_i[10];

   always @(posedge aclk or negedge aresetn)
     begin : byte_10_strb_seq
       if (!aresetn)
          merged_strb_10 <= 1'b0;      
       else if (merge_strb_10)
          merged_strb_10 <= next_strb_10;
     end 

     

   assign merge_byte_9 = merge && data_select[1] && wide_wstrb_masked[9];
   assign wdata_out[79:72] = merge_byte_9 ? wide_wdata_in[79:72] : merged_byte_9;

   always @(posedge aclk)
     begin : byte_9_seq
       if (merge_byte_9)
          merged_byte_9 <= wide_wdata_in[79:72];
     end 

   assign merge_strb_9 = merge_byte_9 || update_strb;
   
   assign wstrb_out_i[9] = merge_byte_9 ? wide_wstrb_in[9] :
                           (((strb_skid_valid && data_select[1]) || (~strb_skid_valid && ~update_strb)) ? merged_strb_9 : 1'b0);
   assign wstrb_out[9] = wstrb_out_i[9];
   assign next_strb_9 = wstrb_out_i[9];

   always @(posedge aclk or negedge aresetn)
     begin : byte_9_strb_seq
       if (!aresetn)
          merged_strb_9 <= 1'b0;      
       else if (merge_strb_9)
          merged_strb_9 <= next_strb_9;
     end 

     

   assign merge_byte_8 = merge && data_select[1] && wide_wstrb_masked[8];
   assign wdata_out[71:64] = merge_byte_8 ? wide_wdata_in[71:64] : merged_byte_8;

   always @(posedge aclk)
     begin : byte_8_seq
       if (merge_byte_8)
          merged_byte_8 <= wide_wdata_in[71:64];
     end 

   assign merge_strb_8 = merge_byte_8 || update_strb;
   
   assign wstrb_out_i[8] = merge_byte_8 ? wide_wstrb_in[8] :
                           (((strb_skid_valid && data_select[1]) || (~strb_skid_valid && ~update_strb)) ? merged_strb_8 : 1'b0);
   assign wstrb_out[8] = wstrb_out_i[8];
   assign next_strb_8 = wstrb_out_i[8];

   always @(posedge aclk or negedge aresetn)
     begin : byte_8_strb_seq
       if (!aresetn)
          merged_strb_8 <= 1'b0;      
       else if (merge_strb_8)
          merged_strb_8 <= next_strb_8;
     end 

     

   assign merge_byte_7 = merge && data_select[0] && wide_wstrb_masked[7];
   assign wdata_out[63:56] = merge_byte_7 ? wide_wdata_in[63:56] : merged_byte_7;

   always @(posedge aclk)
     begin : byte_7_seq
       if (merge_byte_7)
          merged_byte_7 <= wide_wdata_in[63:56];
     end 

   assign merge_strb_7 = merge_byte_7 || update_strb;
   
   assign wstrb_out_i[7] = merge_byte_7 ? wide_wstrb_in[7] :
                           (((strb_skid_valid && data_select[0]) || (~strb_skid_valid && ~update_strb)) ? merged_strb_7 : 1'b0);
   assign wstrb_out[7] = wstrb_out_i[7];
   assign next_strb_7 = wstrb_out_i[7];

   always @(posedge aclk or negedge aresetn)
     begin : byte_7_strb_seq
       if (!aresetn)
          merged_strb_7 <= 1'b0;      
       else if (merge_strb_7)
          merged_strb_7 <= next_strb_7;
     end 

     

   assign merge_byte_6 = merge && data_select[0] && wide_wstrb_masked[6];
   assign wdata_out[55:48] = merge_byte_6 ? wide_wdata_in[55:48] : merged_byte_6;

   always @(posedge aclk)
     begin : byte_6_seq
       if (merge_byte_6)
          merged_byte_6 <= wide_wdata_in[55:48];
     end 

   assign merge_strb_6 = merge_byte_6 || update_strb;
   
   assign wstrb_out_i[6] = merge_byte_6 ? wide_wstrb_in[6] :
                           (((strb_skid_valid && data_select[0]) || (~strb_skid_valid && ~update_strb)) ? merged_strb_6 : 1'b0);
   assign wstrb_out[6] = wstrb_out_i[6];
   assign next_strb_6 = wstrb_out_i[6];

   always @(posedge aclk or negedge aresetn)
     begin : byte_6_strb_seq
       if (!aresetn)
          merged_strb_6 <= 1'b0;      
       else if (merge_strb_6)
          merged_strb_6 <= next_strb_6;
     end 

     

   assign merge_byte_5 = merge && data_select[0] && wide_wstrb_masked[5];
   assign wdata_out[47:40] = merge_byte_5 ? wide_wdata_in[47:40] : merged_byte_5;

   always @(posedge aclk)
     begin : byte_5_seq
       if (merge_byte_5)
          merged_byte_5 <= wide_wdata_in[47:40];
     end 

   assign merge_strb_5 = merge_byte_5 || update_strb;
   
   assign wstrb_out_i[5] = merge_byte_5 ? wide_wstrb_in[5] :
                           (((strb_skid_valid && data_select[0]) || (~strb_skid_valid && ~update_strb)) ? merged_strb_5 : 1'b0);
   assign wstrb_out[5] = wstrb_out_i[5];
   assign next_strb_5 = wstrb_out_i[5];

   always @(posedge aclk or negedge aresetn)
     begin : byte_5_strb_seq
       if (!aresetn)
          merged_strb_5 <= 1'b0;      
       else if (merge_strb_5)
          merged_strb_5 <= next_strb_5;
     end 

     

   assign merge_byte_4 = merge && data_select[0] && wide_wstrb_masked[4];
   assign wdata_out[39:32] = merge_byte_4 ? wide_wdata_in[39:32] : merged_byte_4;

   always @(posedge aclk)
     begin : byte_4_seq
       if (merge_byte_4)
          merged_byte_4 <= wide_wdata_in[39:32];
     end 

   assign merge_strb_4 = merge_byte_4 || update_strb;
   
   assign wstrb_out_i[4] = merge_byte_4 ? wide_wstrb_in[4] :
                           (((strb_skid_valid && data_select[0]) || (~strb_skid_valid && ~update_strb)) ? merged_strb_4 : 1'b0);
   assign wstrb_out[4] = wstrb_out_i[4];
   assign next_strb_4 = wstrb_out_i[4];

   always @(posedge aclk or negedge aresetn)
     begin : byte_4_strb_seq
       if (!aresetn)
          merged_strb_4 <= 1'b0;      
       else if (merge_strb_4)
          merged_strb_4 <= next_strb_4;
     end 

     

   assign merge_byte_3 = merge && data_select[0] && wide_wstrb_masked[3];
   assign wdata_out[31:24] = merge_byte_3 ? wide_wdata_in[31:24] : merged_byte_3;

   always @(posedge aclk)
     begin : byte_3_seq
       if (merge_byte_3)
          merged_byte_3 <= wide_wdata_in[31:24];
     end 

   assign merge_strb_3 = merge_byte_3 || update_strb;
   
   assign wstrb_out_i[3] = merge_byte_3 ? wide_wstrb_in[3] :
                           (((strb_skid_valid && data_select[0]) || (~strb_skid_valid && ~update_strb)) ? merged_strb_3 : 1'b0);
   assign wstrb_out[3] = wstrb_out_i[3];
   assign next_strb_3 = wstrb_out_i[3];

   always @(posedge aclk or negedge aresetn)
     begin : byte_3_strb_seq
       if (!aresetn)
          merged_strb_3 <= 1'b0;      
       else if (merge_strb_3)
          merged_strb_3 <= next_strb_3;
     end 

     

   assign merge_byte_2 = merge && data_select[0] && wide_wstrb_masked[2];
   assign wdata_out[23:16] = merge_byte_2 ? wide_wdata_in[23:16] : merged_byte_2;

   always @(posedge aclk)
     begin : byte_2_seq
       if (merge_byte_2)
          merged_byte_2 <= wide_wdata_in[23:16];
     end 

   assign merge_strb_2 = merge_byte_2 || update_strb;
   
   assign wstrb_out_i[2] = merge_byte_2 ? wide_wstrb_in[2] :
                           (((strb_skid_valid && data_select[0]) || (~strb_skid_valid && ~update_strb)) ? merged_strb_2 : 1'b0);
   assign wstrb_out[2] = wstrb_out_i[2];
   assign next_strb_2 = wstrb_out_i[2];

   always @(posedge aclk or negedge aresetn)
     begin : byte_2_strb_seq
       if (!aresetn)
          merged_strb_2 <= 1'b0;      
       else if (merge_strb_2)
          merged_strb_2 <= next_strb_2;
     end 

     

   assign merge_byte_1 = merge && data_select[0] && wide_wstrb_masked[1];
   assign wdata_out[15:8] = merge_byte_1 ? wide_wdata_in[15:8] : merged_byte_1;

   always @(posedge aclk)
     begin : byte_1_seq
       if (merge_byte_1)
          merged_byte_1 <= wide_wdata_in[15:8];
     end 

   assign merge_strb_1 = merge_byte_1 || update_strb;
   
   assign wstrb_out_i[1] = merge_byte_1 ? wide_wstrb_in[1] :
                           (((strb_skid_valid && data_select[0]) || (~strb_skid_valid && ~update_strb)) ? merged_strb_1 : 1'b0);
   assign wstrb_out[1] = wstrb_out_i[1];
   assign next_strb_1 = wstrb_out_i[1];

   always @(posedge aclk or negedge aresetn)
     begin : byte_1_strb_seq
       if (!aresetn)
          merged_strb_1 <= 1'b0;      
       else if (merge_strb_1)
          merged_strb_1 <= next_strb_1;
     end 

     

   assign merge_byte_0 = merge && data_select[0] && wide_wstrb_masked[0];
   assign wdata_out[7:0] = merge_byte_0 ? wide_wdata_in[7:0] : merged_byte_0;

   always @(posedge aclk)
     begin : byte_0_seq
       if (merge_byte_0)
          merged_byte_0 <= wide_wdata_in[7:0];
     end 

   assign merge_strb_0 = merge_byte_0 || update_strb;
   
   assign wstrb_out_i[0] = merge_byte_0 ? wide_wstrb_in[0] :
                           (((strb_skid_valid && data_select[0]) || (~strb_skid_valid && ~update_strb)) ? merged_strb_0 : 1'b0);
   assign wstrb_out[0] = wstrb_out_i[0];
   assign next_strb_0 = wstrb_out_i[0];

   always @(posedge aclk or negedge aresetn)
     begin : byte_0_strb_seq
       if (!aresetn)
          merged_strb_0 <= 1'b0;      
       else if (merge_strb_0)
          merged_strb_0 <= next_strb_0;
     end 

     

endmodule


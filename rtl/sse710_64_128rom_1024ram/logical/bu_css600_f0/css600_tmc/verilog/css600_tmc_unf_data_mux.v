//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2009-2010, 2016-2017 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Sub-module of css600_tmc
//
//----------------------------------------------------------------------------


module css600_tmc_unf_data_mux
#(
  parameter FRAME_BUFFER_WIDTH = 120,
  parameter ATB_DATA_WIDTH = 128,
  parameter SEL_WIDTH  = 4
)
(
  input  wire [FRAME_BUFFER_WIDTH-1:0] frame_buffer,
  input  wire          [SEL_WIDTH-1:0] sel,
  output wire                    [6:0] unformatted_id,
  output wire     [ATB_DATA_WIDTH-1:0] unformatted_data
);


  function automatic [38:0] data_mux_fn_32;
    input   [3:0] sel;
    input [119:0] frame_buffer;

    reg     [7:0] muxed_data_l0_0;
    reg     [7:0] muxed_data_l0_1;
    reg     [7:0] muxed_data_l0_2;
    reg     [7:0] muxed_data_l0_3;
    reg     [7:0] muxed_data_l0_4;
    reg     [6:0] muxed_data_l0_8;
    reg     [7:0] muxed_data_l0_9;
    reg     [7:0] muxed_data_l0_10;
    reg     [7:0] muxed_data_l0_11;
    reg     [7:0] muxed_data_l0_12;
    reg     [7:0] muxed_data_l0_13;
    reg     [7:0] muxed_data_l0_14;
    reg     [7:0] muxed_data_l1_0;
    reg     [7:0] muxed_data_l1_1;
    reg     [7:0] muxed_data_l1_2;
    reg     [7:0] muxed_data_l1_3;
    reg     [7:0] muxed_data_l1_4;
    reg     [6:0] muxed_data_l1_12;
    reg     [7:0] muxed_data_l1_13;
    reg     [7:0] muxed_data_l1_14;
    reg     [7:0] muxed_data_l2_0;
    reg     [7:0] muxed_data_l2_1;
    reg     [7:0] muxed_data_l2_2;
    reg     [7:0] muxed_data_l2_3;
    reg     [7:0] muxed_data_l2_4;
    reg     [6:0] muxed_data_l2_14;
    reg     [6:0] muxed_data_l3_0;
    reg     [7:0] muxed_data_l3_1;
    reg     [7:0] muxed_data_l3_2;
    reg     [7:0] muxed_data_l3_3;
    reg     [7:0] muxed_data_l3_4;
  begin

     muxed_data_l0_0  = sel[3] ? frame_buffer[63:56] : frame_buffer[7:0];
     muxed_data_l0_1  = sel[3] ? frame_buffer[71:64] : frame_buffer[15:8];
     muxed_data_l0_2  = sel[3] ? frame_buffer[79:72] : frame_buffer[23:16];
     muxed_data_l0_3  = sel[3] ? frame_buffer[87:80] : frame_buffer[31:24];
     muxed_data_l0_4  = sel[3] ? frame_buffer[95:88] : frame_buffer[39:32];
     muxed_data_l0_8  = sel[3] ? frame_buffer[7:1]   : frame_buffer[71:65];
     muxed_data_l0_9  = sel[3] ? frame_buffer[15:8]  : frame_buffer[79:72];
     muxed_data_l0_10 = sel[3] ? frame_buffer[23:16] : frame_buffer[87:80];
     muxed_data_l0_11 = sel[3] ? frame_buffer[31:24] : frame_buffer[95:88];
     muxed_data_l0_12 = sel[3] ? frame_buffer[39:32] : frame_buffer[103:96];
     muxed_data_l0_13 = sel[3] ? frame_buffer[47:40] : frame_buffer[111:104];
     muxed_data_l0_14 = sel[3] ? frame_buffer[55:48] : frame_buffer[119:112];

     muxed_data_l1_0  = sel[2] ? muxed_data_l0_11 : muxed_data_l0_0;
     muxed_data_l1_1  = sel[2] ? muxed_data_l0_12 : muxed_data_l0_1;
     muxed_data_l1_2  = sel[2] ? muxed_data_l0_13 : muxed_data_l0_2;
     muxed_data_l1_3  = sel[2] ? muxed_data_l0_14 : muxed_data_l0_3;
     muxed_data_l1_4  = sel[2] ? muxed_data_l0_0  : muxed_data_l0_4;
     muxed_data_l1_12 = sel[2] ? muxed_data_l0_8  : muxed_data_l0_12[7:1];
     muxed_data_l1_13 = sel[2] ? muxed_data_l0_9  : muxed_data_l0_13;
     muxed_data_l1_14 = sel[2] ? muxed_data_l0_10 : muxed_data_l0_14;

     muxed_data_l2_0  = sel[1] ? muxed_data_l1_13 : muxed_data_l1_0;
     muxed_data_l2_1  = sel[1] ? muxed_data_l1_14 : muxed_data_l1_1;
     muxed_data_l2_2  = sel[1] ? muxed_data_l1_0  : muxed_data_l1_2;
     muxed_data_l2_3  = sel[1] ? muxed_data_l1_1  : muxed_data_l1_3;
     muxed_data_l2_4  = sel[1] ? muxed_data_l1_2  : muxed_data_l1_4;
     muxed_data_l2_14 = sel[1] ? muxed_data_l1_12 : muxed_data_l1_14[7:1];

     muxed_data_l3_0  = sel[0] ? muxed_data_l2_14 : muxed_data_l2_0[7:1];
     muxed_data_l3_1  = sel[0] ? muxed_data_l2_0  : muxed_data_l2_1;
     muxed_data_l3_2  = sel[0] ? muxed_data_l2_1  : muxed_data_l2_2;
     muxed_data_l3_3  = sel[0] ? muxed_data_l2_2  : muxed_data_l2_3;
     muxed_data_l3_4  = sel[0] ? muxed_data_l2_3  : muxed_data_l2_4;

     data_mux_fn_32 = {muxed_data_l3_4,muxed_data_l3_3,
                       muxed_data_l3_2,muxed_data_l3_1,muxed_data_l3_0};
  end
  endfunction


  function automatic [70:0] data_mux_fn_64;
    input [4:0] sel;
    input [239:0] frame_buffer;

    reg [7:0] muxed_data_l0_0;
    reg [7:0] muxed_data_l0_1;
    reg [7:0] muxed_data_l0_2;
    reg [7:0] muxed_data_l0_3;
    reg [7:0] muxed_data_l0_4;
    reg [7:0] muxed_data_l0_5;
    reg [7:0] muxed_data_l0_6;
    reg [7:0] muxed_data_l0_7;
    reg [7:0] muxed_data_l0_8;
    reg [6:0] muxed_data_l0_15;
    reg [7:0] muxed_data_l0_16;
    reg [7:0] muxed_data_l0_17;
    reg [7:0] muxed_data_l0_18;
    reg [7:0] muxed_data_l0_19;
    reg [7:0] muxed_data_l0_20;
    reg [7:0] muxed_data_l0_21;
    reg [7:0] muxed_data_l0_22;
    reg [7:0] muxed_data_l0_23;
    reg [7:0] muxed_data_l0_24;
    reg [7:0] muxed_data_l0_25;
    reg [7:0] muxed_data_l0_26;
    reg [7:0] muxed_data_l0_27;
    reg [7:0] muxed_data_l0_28;
    reg [7:0] muxed_data_l0_29;

    reg [7:0] muxed_data_l1_0;
    reg [7:0] muxed_data_l1_1;
    reg [7:0] muxed_data_l1_2;
    reg [7:0] muxed_data_l1_3;
    reg [7:0] muxed_data_l1_4;
    reg [7:0] muxed_data_l1_5;
    reg [7:0] muxed_data_l1_6;
    reg [7:0] muxed_data_l1_7;
    reg [7:0] muxed_data_l1_8;
    reg [6:0] muxed_data_l1_23;
    reg [7:0] muxed_data_l1_24;
    reg [7:0] muxed_data_l1_25;
    reg [7:0] muxed_data_l1_26;
    reg [7:0] muxed_data_l1_27;
    reg [7:0] muxed_data_l1_28;
    reg [7:0] muxed_data_l1_29;

    reg [7:0] muxed_data_l2_0;
    reg [7:0] muxed_data_l2_1;
    reg [7:0] muxed_data_l2_2;
    reg [7:0] muxed_data_l2_3;
    reg [7:0] muxed_data_l2_4;
    reg [7:0] muxed_data_l2_5;
    reg [7:0] muxed_data_l2_6;
    reg [7:0] muxed_data_l2_7;
    reg [7:0] muxed_data_l2_8;
    reg [6:0] muxed_data_l2_27;
    reg [7:0] muxed_data_l2_28;
    reg [7:0] muxed_data_l2_29;

    reg [7:0] muxed_data_l3_0;
    reg [7:0] muxed_data_l3_1;
    reg [7:0] muxed_data_l3_2;
    reg [7:0] muxed_data_l3_3;
    reg [7:0] muxed_data_l3_4;
    reg [7:0] muxed_data_l3_5;
    reg [7:0] muxed_data_l3_6;
    reg [7:0] muxed_data_l3_7;
    reg [7:0] muxed_data_l3_8;
    reg [6:0] muxed_data_l3_29;

    reg [6:0] muxed_data_l4_0;
    reg [7:0] muxed_data_l4_1;
    reg [7:0] muxed_data_l4_2;
    reg [7:0] muxed_data_l4_3;
    reg [7:0] muxed_data_l4_4;
    reg [7:0] muxed_data_l4_5;
    reg [7:0] muxed_data_l4_6;
    reg [7:0] muxed_data_l4_7;
    reg [7:0] muxed_data_l4_8;
  begin

     muxed_data_l0_0   =  sel[4]  ?  frame_buffer[119:112] :  frame_buffer[7:0];
     muxed_data_l0_1   =  sel[4]  ?  frame_buffer[127:120] :  frame_buffer[15:8];
     muxed_data_l0_2   =  sel[4]  ?  frame_buffer[135:128] :  frame_buffer[23:16];
     muxed_data_l0_3   =  sel[4]  ?  frame_buffer[143:136] :  frame_buffer[31:24];
     muxed_data_l0_4   =  sel[4]  ?  frame_buffer[151:144] :  frame_buffer[39:32];
     muxed_data_l0_5   =  sel[4]  ?  frame_buffer[159:152] :  frame_buffer[47:40];
     muxed_data_l0_6   =  sel[4]  ?  frame_buffer[167:160] :  frame_buffer[55:48];
     muxed_data_l0_7   =  sel[4]  ?  frame_buffer[175:168] :  frame_buffer[63:56];
     muxed_data_l0_8   =  sel[4]  ?  frame_buffer[183:176] :  frame_buffer[71:64];
     muxed_data_l0_15  =  sel[4]  ?  frame_buffer[239:233] :  frame_buffer[127:121];
     muxed_data_l0_16  =  sel[4]  ?  frame_buffer[7:0]     :  frame_buffer[135:128];
     muxed_data_l0_17  =  sel[4]  ?  frame_buffer[15:8]    :  frame_buffer[143:136];
     muxed_data_l0_18  =  sel[4]  ?  frame_buffer[23:16]   :  frame_buffer[151:144];
     muxed_data_l0_19  =  sel[4]  ?  frame_buffer[31:24]   :  frame_buffer[159:152];
     muxed_data_l0_20  =  sel[4]  ?  frame_buffer[39:32]   :  frame_buffer[167:160];
     muxed_data_l0_21  =  sel[4]  ?  frame_buffer[47:40]   :  frame_buffer[175:168];
     muxed_data_l0_22  =  sel[4]  ?  frame_buffer[55:48]   :  frame_buffer[183:176];
     muxed_data_l0_23  =  sel[4]  ?  frame_buffer[63:56]   :  frame_buffer[191:184];
     muxed_data_l0_24  =  sel[4]  ?  frame_buffer[71:64]   :  frame_buffer[199:192];
     muxed_data_l0_25  =  sel[4]  ?  frame_buffer[79:72]   :  frame_buffer[207:200];
     muxed_data_l0_26  =  sel[4]  ?  frame_buffer[87:80]   :  frame_buffer[215:208];
     muxed_data_l0_27  =  sel[4]  ?  frame_buffer[95:88]   :  frame_buffer[223:216];
     muxed_data_l0_28  =  sel[4]  ?  frame_buffer[103:96]  :  frame_buffer[231:224];
     muxed_data_l0_29  =  sel[4]  ?  frame_buffer[111:104] :  frame_buffer[239:232];

     muxed_data_l1_0  = sel[3] ? muxed_data_l0_22 : muxed_data_l0_0;
     muxed_data_l1_1  = sel[3] ? muxed_data_l0_23 : muxed_data_l0_1;
     muxed_data_l1_2  = sel[3] ? muxed_data_l0_24 : muxed_data_l0_2;
     muxed_data_l1_3  = sel[3] ? muxed_data_l0_25 : muxed_data_l0_3;
     muxed_data_l1_4  = sel[3] ? muxed_data_l0_26 : muxed_data_l0_4;
     muxed_data_l1_5  = sel[3] ? muxed_data_l0_27 : muxed_data_l0_5;
     muxed_data_l1_6  = sel[3] ? muxed_data_l0_28 : muxed_data_l0_6;
     muxed_data_l1_7  = sel[3] ? muxed_data_l0_29 : muxed_data_l0_7;
     muxed_data_l1_8  = sel[3] ? muxed_data_l0_0  : muxed_data_l0_8;
     muxed_data_l1_23 = sel[3] ? muxed_data_l0_15 : muxed_data_l0_23[7:1];
     muxed_data_l1_24 = sel[3] ? muxed_data_l0_16 : muxed_data_l0_24;
     muxed_data_l1_25 = sel[3] ? muxed_data_l0_17 : muxed_data_l0_25;
     muxed_data_l1_26 = sel[3] ? muxed_data_l0_18 : muxed_data_l0_26;
     muxed_data_l1_27 = sel[3] ? muxed_data_l0_19 : muxed_data_l0_27;
     muxed_data_l1_28 = sel[3] ? muxed_data_l0_20 : muxed_data_l0_28;
     muxed_data_l1_29 = sel[3] ? muxed_data_l0_21 : muxed_data_l0_29;

     muxed_data_l2_0  = sel[2] ? muxed_data_l1_26 : muxed_data_l1_0;
     muxed_data_l2_1  = sel[2] ? muxed_data_l1_27 : muxed_data_l1_1;
     muxed_data_l2_2  = sel[2] ? muxed_data_l1_28 : muxed_data_l1_2;
     muxed_data_l2_3  = sel[2] ? muxed_data_l1_29 : muxed_data_l1_3;
     muxed_data_l2_4  = sel[2] ? muxed_data_l1_0  : muxed_data_l1_4;
     muxed_data_l2_5  = sel[2] ? muxed_data_l1_1  : muxed_data_l1_5;
     muxed_data_l2_6  = sel[2] ? muxed_data_l1_2  : muxed_data_l1_6;
     muxed_data_l2_7  = sel[2] ? muxed_data_l1_3  : muxed_data_l1_7;
     muxed_data_l2_8  = sel[2] ? muxed_data_l1_4  : muxed_data_l1_8;
     muxed_data_l2_27 = sel[2] ? muxed_data_l1_23 : muxed_data_l1_27[7:1];
     muxed_data_l2_28 = sel[2] ? muxed_data_l1_24 : muxed_data_l1_28;
     muxed_data_l2_29 = sel[2] ? muxed_data_l1_25 : muxed_data_l1_29;

     muxed_data_l3_0  = sel[1] ? muxed_data_l2_28 : muxed_data_l2_0;
     muxed_data_l3_1  = sel[1] ? muxed_data_l2_29 : muxed_data_l2_1;
     muxed_data_l3_2  = sel[1] ? muxed_data_l2_0  : muxed_data_l2_2;
     muxed_data_l3_3  = sel[1] ? muxed_data_l2_1  : muxed_data_l2_3;
     muxed_data_l3_4  = sel[1] ? muxed_data_l2_2  : muxed_data_l2_4;
     muxed_data_l3_5  = sel[1] ? muxed_data_l2_3  : muxed_data_l2_5;
     muxed_data_l3_6  = sel[1] ? muxed_data_l2_4  : muxed_data_l2_6;
     muxed_data_l3_7  = sel[1] ? muxed_data_l2_5  : muxed_data_l2_7;
     muxed_data_l3_8  = sel[1] ? muxed_data_l2_6  : muxed_data_l2_8;
     muxed_data_l3_29 = sel[1] ? muxed_data_l2_27 : muxed_data_l2_29[7:1];

     muxed_data_l4_0  = sel[0] ? muxed_data_l3_29 : muxed_data_l3_0[7:1];
     muxed_data_l4_1  = sel[0] ? muxed_data_l3_0  : muxed_data_l3_1;
     muxed_data_l4_2  = sel[0] ? muxed_data_l3_1  : muxed_data_l3_2;
     muxed_data_l4_3  = sel[0] ? muxed_data_l3_2  : muxed_data_l3_3;
     muxed_data_l4_4  = sel[0] ? muxed_data_l3_3  : muxed_data_l3_4;
     muxed_data_l4_5  = sel[0] ? muxed_data_l3_4  : muxed_data_l3_5;
     muxed_data_l4_6  = sel[0] ? muxed_data_l3_5  : muxed_data_l3_6;
     muxed_data_l4_7  = sel[0] ? muxed_data_l3_6  : muxed_data_l3_7;
     muxed_data_l4_8  = sel[0] ? muxed_data_l3_7  : muxed_data_l3_8;

     data_mux_fn_64 = {muxed_data_l4_8,muxed_data_l4_7,muxed_data_l4_6,
                       muxed_data_l4_5,muxed_data_l4_4,muxed_data_l4_3,
                       muxed_data_l4_2,muxed_data_l4_1,muxed_data_l4_0};
  end
  endfunction


  function automatic [134:0] data_mux_fn_128;
    input [5:0] sel;
    input [479:0] frame_buffer;

    reg [7:0] muxed_data_l0_0;
    reg [7:0] muxed_data_l0_1;
    reg [7:0] muxed_data_l0_2;
    reg [7:0] muxed_data_l0_3;
    reg [7:0] muxed_data_l0_4;
    reg [7:0] muxed_data_l0_5;
    reg [7:0] muxed_data_l0_6;
    reg [7:0] muxed_data_l0_7;
    reg [7:0] muxed_data_l0_8;
    reg [7:0] muxed_data_l0_9;
    reg [7:0] muxed_data_l0_10;
    reg [7:0] muxed_data_l0_11;
    reg [7:0] muxed_data_l0_12;
    reg [7:0] muxed_data_l0_13;
    reg [7:0] muxed_data_l0_14;
    reg [7:0] muxed_data_l0_15;
    reg [7:0] muxed_data_l0_16;
    reg [7:0] muxed_data_l0_29;
    reg [7:0] muxed_data_l0_30;
    reg [7:0] muxed_data_l0_31;
    reg [7:0] muxed_data_l0_32;
    reg [7:0] muxed_data_l0_33;
    reg [7:0] muxed_data_l0_34;
    reg [7:0] muxed_data_l0_35;
    reg [7:0] muxed_data_l0_36;
    reg [7:0] muxed_data_l0_37;
    reg [7:0] muxed_data_l0_38;
    reg [7:0] muxed_data_l0_39;
    reg [7:0] muxed_data_l0_40;
    reg [7:0] muxed_data_l0_41;
    reg [7:0] muxed_data_l0_42;
    reg [7:0] muxed_data_l0_43;
    reg [7:0] muxed_data_l0_44;
    reg [7:0] muxed_data_l0_45;
    reg [7:0] muxed_data_l0_46;
    reg [7:0] muxed_data_l0_47;
    reg [7:0] muxed_data_l0_48;
    reg [7:0] muxed_data_l0_49;
    reg [7:0] muxed_data_l0_50;
    reg [7:0] muxed_data_l0_51;
    reg [7:0] muxed_data_l0_52;
    reg [7:0] muxed_data_l0_53;
    reg [7:0] muxed_data_l0_54;
    reg [7:0] muxed_data_l0_55;
    reg [7:0] muxed_data_l0_56;
    reg [7:0] muxed_data_l0_57;
    reg [7:0] muxed_data_l0_58;
    reg [7:0] muxed_data_l0_59;

    reg [7:0] muxed_data_l1_0;
    reg [7:0] muxed_data_l1_1;
    reg [7:0] muxed_data_l1_2;
    reg [7:0] muxed_data_l1_3;
    reg [7:0] muxed_data_l1_4;
    reg [7:0] muxed_data_l1_5;
    reg [7:0] muxed_data_l1_6;
    reg [7:0] muxed_data_l1_7;
    reg [7:0] muxed_data_l1_8;
    reg [7:0] muxed_data_l1_9;
    reg [7:0] muxed_data_l1_10;
    reg [7:0] muxed_data_l1_11;
    reg [7:0] muxed_data_l1_12;
    reg [7:0] muxed_data_l1_13;
    reg [7:0] muxed_data_l1_14;
    reg [7:0] muxed_data_l1_15;
    reg [7:0] muxed_data_l1_16;
    reg [6:0] muxed_data_l1_45;
    reg [7:0] muxed_data_l1_46;
    reg [7:0] muxed_data_l1_47;
    reg [7:0] muxed_data_l1_48;
    reg [7:0] muxed_data_l1_49;
    reg [7:0] muxed_data_l1_50;
    reg [7:0] muxed_data_l1_51;
    reg [7:0] muxed_data_l1_52;
    reg [7:0] muxed_data_l1_53;
    reg [7:0] muxed_data_l1_54;
    reg [7:0] muxed_data_l1_55;
    reg [7:0] muxed_data_l1_56;
    reg [7:0] muxed_data_l1_57;
    reg [7:0] muxed_data_l1_58;
    reg [7:0] muxed_data_l1_59;

    reg [7:0] muxed_data_l2_0;
    reg [7:0] muxed_data_l2_1;
    reg [7:0] muxed_data_l2_2;
    reg [7:0] muxed_data_l2_3;
    reg [7:0] muxed_data_l2_4;
    reg [7:0] muxed_data_l2_5;
    reg [7:0] muxed_data_l2_6;
    reg [7:0] muxed_data_l2_7;
    reg [7:0] muxed_data_l2_8;
    reg [7:0] muxed_data_l2_9;
    reg [7:0] muxed_data_l2_10;
    reg [7:0] muxed_data_l2_11;
    reg [7:0] muxed_data_l2_12;
    reg [7:0] muxed_data_l2_13;
    reg [7:0] muxed_data_l2_14;
    reg [7:0] muxed_data_l2_15;
    reg [7:0] muxed_data_l2_16;
    reg [6:0] muxed_data_l2_53;
    reg [7:0] muxed_data_l2_54;
    reg [7:0] muxed_data_l2_55;
    reg [7:0] muxed_data_l2_56;
    reg [7:0] muxed_data_l2_57;
    reg [7:0] muxed_data_l2_58;
    reg [7:0] muxed_data_l2_59;

    reg [7:0] muxed_data_l3_0;
    reg [7:0] muxed_data_l3_1;
    reg [7:0] muxed_data_l3_2;
    reg [7:0] muxed_data_l3_3;
    reg [7:0] muxed_data_l3_4;
    reg [7:0] muxed_data_l3_5;
    reg [7:0] muxed_data_l3_6;
    reg [7:0] muxed_data_l3_7;
    reg [7:0] muxed_data_l3_8;
    reg [7:0] muxed_data_l3_9;
    reg [7:0] muxed_data_l3_10;
    reg [7:0] muxed_data_l3_11;
    reg [7:0] muxed_data_l3_12;
    reg [7:0] muxed_data_l3_13;
    reg [7:0] muxed_data_l3_14;
    reg [7:0] muxed_data_l3_15;
    reg [7:0] muxed_data_l3_16;
    reg [6:0] muxed_data_l3_57;
    reg [7:0] muxed_data_l3_58;
    reg [7:0] muxed_data_l3_59;

    reg [7:0] muxed_data_l4_0;
    reg [7:0] muxed_data_l4_1;
    reg [7:0] muxed_data_l4_2;
    reg [7:0] muxed_data_l4_3;
    reg [7:0] muxed_data_l4_4;
    reg [7:0] muxed_data_l4_5;
    reg [7:0] muxed_data_l4_6;
    reg [7:0] muxed_data_l4_7;
    reg [7:0] muxed_data_l4_8;
    reg [7:0] muxed_data_l4_9;
    reg [7:0] muxed_data_l4_10;
    reg [7:0] muxed_data_l4_11;
    reg [7:0] muxed_data_l4_12;
    reg [7:0] muxed_data_l4_13;
    reg [7:0] muxed_data_l4_14;
    reg [7:0] muxed_data_l4_15;
    reg [7:0] muxed_data_l4_16;
    reg [6:0] muxed_data_l4_59;

    reg [6:0] muxed_data_l5_0;
    reg [7:0] muxed_data_l5_1;
    reg [7:0] muxed_data_l5_2;
    reg [7:0] muxed_data_l5_3;
    reg [7:0] muxed_data_l5_4;
    reg [7:0] muxed_data_l5_5;
    reg [7:0] muxed_data_l5_6;
    reg [7:0] muxed_data_l5_7;
    reg [7:0] muxed_data_l5_8;
    reg [7:0] muxed_data_l5_9;
    reg [7:0] muxed_data_l5_10;
    reg [7:0] muxed_data_l5_11;
    reg [7:0] muxed_data_l5_12;
    reg [7:0] muxed_data_l5_13;
    reg [7:0] muxed_data_l5_14;
    reg [7:0] muxed_data_l5_15;
    reg [7:0] muxed_data_l5_16;
  begin

     muxed_data_l0_0  = sel[5] ? frame_buffer[231:224] : frame_buffer[7:0];
     muxed_data_l0_1  = sel[5] ? frame_buffer[239:232] : frame_buffer[15:8];
     muxed_data_l0_2  = sel[5] ? frame_buffer[247:240] : frame_buffer[23:16];
     muxed_data_l0_3  = sel[5] ? frame_buffer[255:248] : frame_buffer[31:24];
     muxed_data_l0_4  = sel[5] ? frame_buffer[263:256] : frame_buffer[39:32];
     muxed_data_l0_5  = sel[5] ? frame_buffer[271:264] : frame_buffer[47:40];
     muxed_data_l0_6  = sel[5] ? frame_buffer[279:272] : frame_buffer[55:48];
     muxed_data_l0_7  = sel[5] ? frame_buffer[287:280] : frame_buffer[63:56];
     muxed_data_l0_8  = sel[5] ? frame_buffer[295:288] : frame_buffer[71:64];
     muxed_data_l0_9  = sel[5] ? frame_buffer[303:296] : frame_buffer[79:72];
     muxed_data_l0_10 = sel[5] ? frame_buffer[311:304] : frame_buffer[87:80];
     muxed_data_l0_11 = sel[5] ? frame_buffer[319:312] : frame_buffer[95:88];
     muxed_data_l0_12 = sel[5] ? frame_buffer[327:320] : frame_buffer[103:96];
     muxed_data_l0_13 = sel[5] ? frame_buffer[335:328] : frame_buffer[111:104];
     muxed_data_l0_14 = sel[5] ? frame_buffer[343:336] : frame_buffer[119:112];
     muxed_data_l0_15 = sel[5] ? frame_buffer[351:344] : frame_buffer[127:120];
     muxed_data_l0_16 = sel[5] ? frame_buffer[359:352] : frame_buffer[135:128];
     muxed_data_l0_29 = sel[5] ? frame_buffer[463:456] : frame_buffer[239:232];
     muxed_data_l0_30 = sel[5] ? frame_buffer[471:464] : frame_buffer[247:240];
     muxed_data_l0_31 = sel[5] ? frame_buffer[479:472] : frame_buffer[255:248];
     muxed_data_l0_32 = sel[5] ? frame_buffer[7:0]     : frame_buffer[263:256];
     muxed_data_l0_33 = sel[5] ? frame_buffer[15:8]    : frame_buffer[271:264];
     muxed_data_l0_34 = sel[5] ? frame_buffer[23:16]   : frame_buffer[279:272];
     muxed_data_l0_35 = sel[5] ? frame_buffer[31:24]   : frame_buffer[287:280];
     muxed_data_l0_36 = sel[5] ? frame_buffer[39:32]   : frame_buffer[295:288];
     muxed_data_l0_37 = sel[5] ? frame_buffer[47:40]   : frame_buffer[303:296];
     muxed_data_l0_38 = sel[5] ? frame_buffer[55:48]   : frame_buffer[311:304];
     muxed_data_l0_39 = sel[5] ? frame_buffer[63:56]   : frame_buffer[319:312];
     muxed_data_l0_40 = sel[5] ? frame_buffer[71:64]   : frame_buffer[327:320];
     muxed_data_l0_41 = sel[5] ? frame_buffer[79:72]   : frame_buffer[335:328];
     muxed_data_l0_42 = sel[5] ? frame_buffer[87:80]   : frame_buffer[343:336];
     muxed_data_l0_43 = sel[5] ? frame_buffer[95:88]   : frame_buffer[351:344];
     muxed_data_l0_44 = sel[5] ? frame_buffer[103:96]  : frame_buffer[359:352];
     muxed_data_l0_45 = sel[5] ? frame_buffer[111:104] : frame_buffer[367:360];
     muxed_data_l0_46 = sel[5] ? frame_buffer[119:112] : frame_buffer[375:368];
     muxed_data_l0_47 = sel[5] ? frame_buffer[127:120] : frame_buffer[383:376];
     muxed_data_l0_48 = sel[5] ? frame_buffer[135:128] : frame_buffer[391:384];
     muxed_data_l0_49 = sel[5] ? frame_buffer[143:136] : frame_buffer[399:392];
     muxed_data_l0_50 = sel[5] ? frame_buffer[151:144] : frame_buffer[407:400];
     muxed_data_l0_51 = sel[5] ? frame_buffer[159:152] : frame_buffer[415:408];
     muxed_data_l0_52 = sel[5] ? frame_buffer[167:160] : frame_buffer[423:416];
     muxed_data_l0_53 = sel[5] ? frame_buffer[175:168] : frame_buffer[431:424];
     muxed_data_l0_54 = sel[5] ? frame_buffer[183:176] : frame_buffer[439:432];
     muxed_data_l0_55 = sel[5] ? frame_buffer[191:184] : frame_buffer[447:440];
     muxed_data_l0_56 = sel[5] ? frame_buffer[199:192] : frame_buffer[455:448];
     muxed_data_l0_57 = sel[5] ? frame_buffer[207:200] : frame_buffer[463:456];
     muxed_data_l0_58 = sel[5] ? frame_buffer[215:208] : frame_buffer[471:464];
     muxed_data_l0_59 = sel[5] ? frame_buffer[223:216] : frame_buffer[479:472];

     muxed_data_l1_0  = sel[4] ? muxed_data_l0_44 : muxed_data_l0_0;
     muxed_data_l1_1  = sel[4] ? muxed_data_l0_45 : muxed_data_l0_1;
     muxed_data_l1_2  = sel[4] ? muxed_data_l0_46 : muxed_data_l0_2;
     muxed_data_l1_3  = sel[4] ? muxed_data_l0_47 : muxed_data_l0_3;
     muxed_data_l1_4  = sel[4] ? muxed_data_l0_48 : muxed_data_l0_4;
     muxed_data_l1_5  = sel[4] ? muxed_data_l0_49 : muxed_data_l0_5;
     muxed_data_l1_6  = sel[4] ? muxed_data_l0_50 : muxed_data_l0_6;
     muxed_data_l1_7  = sel[4] ? muxed_data_l0_51 : muxed_data_l0_7;
     muxed_data_l1_8  = sel[4] ? muxed_data_l0_52 : muxed_data_l0_8;
     muxed_data_l1_9  = sel[4] ? muxed_data_l0_53 : muxed_data_l0_9;
     muxed_data_l1_10 = sel[4] ? muxed_data_l0_54 : muxed_data_l0_10;
     muxed_data_l1_11 = sel[4] ? muxed_data_l0_55 : muxed_data_l0_11;
     muxed_data_l1_12 = sel[4] ? muxed_data_l0_56 : muxed_data_l0_12;
     muxed_data_l1_13 = sel[4] ? muxed_data_l0_57 : muxed_data_l0_13;
     muxed_data_l1_14 = sel[4] ? muxed_data_l0_58 : muxed_data_l0_14;
     muxed_data_l1_15 = sel[4] ? muxed_data_l0_59 : muxed_data_l0_15;
     muxed_data_l1_16 = sel[4] ? muxed_data_l0_0  : muxed_data_l0_16;
     muxed_data_l1_45 = sel[4] ? muxed_data_l0_29[7:1] : muxed_data_l0_45[7:1];
     muxed_data_l1_46 = sel[4] ? muxed_data_l0_30 : muxed_data_l0_46;
     muxed_data_l1_47 = sel[4] ? muxed_data_l0_31 : muxed_data_l0_47;
     muxed_data_l1_48 = sel[4] ? muxed_data_l0_32 : muxed_data_l0_48;
     muxed_data_l1_49 = sel[4] ? muxed_data_l0_33 : muxed_data_l0_49;
     muxed_data_l1_50 = sel[4] ? muxed_data_l0_34 : muxed_data_l0_50;
     muxed_data_l1_51 = sel[4] ? muxed_data_l0_35 : muxed_data_l0_51;
     muxed_data_l1_52 = sel[4] ? muxed_data_l0_36 : muxed_data_l0_52;
     muxed_data_l1_53 = sel[4] ? muxed_data_l0_37 : muxed_data_l0_53;
     muxed_data_l1_54 = sel[4] ? muxed_data_l0_38 : muxed_data_l0_54;
     muxed_data_l1_55 = sel[4] ? muxed_data_l0_39 : muxed_data_l0_55;
     muxed_data_l1_56 = sel[4] ? muxed_data_l0_40 : muxed_data_l0_56;
     muxed_data_l1_57 = sel[4] ? muxed_data_l0_41 : muxed_data_l0_57;
     muxed_data_l1_58 = sel[4] ? muxed_data_l0_42 : muxed_data_l0_58;
     muxed_data_l1_59 = sel[4] ? muxed_data_l0_43 : muxed_data_l0_59;

     muxed_data_l2_0  = sel[3] ? muxed_data_l1_52  :  muxed_data_l1_0;
     muxed_data_l2_1  = sel[3] ? muxed_data_l1_53  :  muxed_data_l1_1;
     muxed_data_l2_2  = sel[3] ? muxed_data_l1_54  :  muxed_data_l1_2;
     muxed_data_l2_3  = sel[3] ? muxed_data_l1_55  :  muxed_data_l1_3;
     muxed_data_l2_4  = sel[3] ? muxed_data_l1_56  :  muxed_data_l1_4;
     muxed_data_l2_5  = sel[3] ? muxed_data_l1_57  :  muxed_data_l1_5;
     muxed_data_l2_6  = sel[3] ? muxed_data_l1_58  :  muxed_data_l1_6;
     muxed_data_l2_7  = sel[3] ? muxed_data_l1_59  :  muxed_data_l1_7;
     muxed_data_l2_8  = sel[3] ? muxed_data_l1_0  :  muxed_data_l1_8;
     muxed_data_l2_9  = sel[3] ? muxed_data_l1_1  :  muxed_data_l1_9;
     muxed_data_l2_10 = sel[3] ? muxed_data_l1_2  :  muxed_data_l1_10;
     muxed_data_l2_11 = sel[3] ? muxed_data_l1_3  :  muxed_data_l1_11;
     muxed_data_l2_12 = sel[3] ? muxed_data_l1_4  :  muxed_data_l1_12;
     muxed_data_l2_13 = sel[3] ? muxed_data_l1_5  :  muxed_data_l1_13;
     muxed_data_l2_14 = sel[3] ? muxed_data_l1_6  :  muxed_data_l1_14;
     muxed_data_l2_15 = sel[3] ? muxed_data_l1_7  :  muxed_data_l1_15;
     muxed_data_l2_16 = sel[3] ? muxed_data_l1_8  :  muxed_data_l1_16;
     muxed_data_l2_53 = sel[3] ? muxed_data_l1_45  :  muxed_data_l1_53[7:1];
     muxed_data_l2_54 = sel[3] ? muxed_data_l1_46  :  muxed_data_l1_54;
     muxed_data_l2_55 = sel[3] ? muxed_data_l1_47  :  muxed_data_l1_55;
     muxed_data_l2_56 = sel[3] ? muxed_data_l1_48  :  muxed_data_l1_56;
     muxed_data_l2_57 = sel[3] ? muxed_data_l1_49  :  muxed_data_l1_57;
     muxed_data_l2_58 = sel[3] ? muxed_data_l1_50  :  muxed_data_l1_58;
     muxed_data_l2_59 = sel[3] ? muxed_data_l1_51  :  muxed_data_l1_59;

     muxed_data_l3_0  = sel[2] ? muxed_data_l2_56  :  muxed_data_l2_0;
     muxed_data_l3_1  = sel[2] ? muxed_data_l2_57  :  muxed_data_l2_1;
     muxed_data_l3_2  = sel[2] ? muxed_data_l2_58  :  muxed_data_l2_2;
     muxed_data_l3_3  = sel[2] ? muxed_data_l2_59  :  muxed_data_l2_3;
     muxed_data_l3_4  = sel[2] ? muxed_data_l2_0  :  muxed_data_l2_4;
     muxed_data_l3_5  = sel[2] ? muxed_data_l2_1  :  muxed_data_l2_5;
     muxed_data_l3_6  = sel[2] ? muxed_data_l2_2  :  muxed_data_l2_6;
     muxed_data_l3_7  = sel[2] ? muxed_data_l2_3  :  muxed_data_l2_7;
     muxed_data_l3_8  = sel[2] ? muxed_data_l2_4  :  muxed_data_l2_8;
     muxed_data_l3_9  = sel[2] ? muxed_data_l2_5  :  muxed_data_l2_9;
     muxed_data_l3_10 = sel[2] ? muxed_data_l2_6  :  muxed_data_l2_10;
     muxed_data_l3_11 = sel[2] ? muxed_data_l2_7  :  muxed_data_l2_11;
     muxed_data_l3_12 = sel[2] ? muxed_data_l2_8  :  muxed_data_l2_12;
     muxed_data_l3_13 = sel[2] ? muxed_data_l2_9  :  muxed_data_l2_13;
     muxed_data_l3_14 = sel[2] ? muxed_data_l2_10  :  muxed_data_l2_14;
     muxed_data_l3_15 = sel[2] ? muxed_data_l2_11  :  muxed_data_l2_15;
     muxed_data_l3_16 = sel[2] ? muxed_data_l2_12  :  muxed_data_l2_16;
     muxed_data_l3_57 = sel[2] ? muxed_data_l2_53  :  muxed_data_l2_57[7:1];
     muxed_data_l3_58 = sel[2] ? muxed_data_l2_54  :  muxed_data_l2_58;
     muxed_data_l3_59 = sel[2] ? muxed_data_l2_55  :  muxed_data_l2_59;

     muxed_data_l4_0  = sel[1] ? muxed_data_l3_58  :  muxed_data_l3_0;
     muxed_data_l4_1  = sel[1] ? muxed_data_l3_59  :  muxed_data_l3_1;
     muxed_data_l4_2  = sel[1] ? muxed_data_l3_0  :  muxed_data_l3_2;
     muxed_data_l4_3  = sel[1] ? muxed_data_l3_1  :  muxed_data_l3_3;
     muxed_data_l4_4  = sel[1] ? muxed_data_l3_2  :  muxed_data_l3_4;
     muxed_data_l4_5  = sel[1] ? muxed_data_l3_3  :  muxed_data_l3_5;
     muxed_data_l4_6  = sel[1] ? muxed_data_l3_4  :  muxed_data_l3_6;
     muxed_data_l4_7  = sel[1] ? muxed_data_l3_5  :  muxed_data_l3_7;
     muxed_data_l4_8  = sel[1] ? muxed_data_l3_6  :  muxed_data_l3_8;
     muxed_data_l4_9  = sel[1] ? muxed_data_l3_7  :  muxed_data_l3_9;
     muxed_data_l4_10 = sel[1] ? muxed_data_l3_8  :  muxed_data_l3_10;
     muxed_data_l4_11 = sel[1] ? muxed_data_l3_9  :  muxed_data_l3_11;
     muxed_data_l4_12 = sel[1] ? muxed_data_l3_10  :  muxed_data_l3_12;
     muxed_data_l4_13 = sel[1] ? muxed_data_l3_11  :  muxed_data_l3_13;
     muxed_data_l4_14 = sel[1] ? muxed_data_l3_12  :  muxed_data_l3_14;
     muxed_data_l4_15 = sel[1] ? muxed_data_l3_13  :  muxed_data_l3_15;
     muxed_data_l4_16 = sel[1] ? muxed_data_l3_14  :  muxed_data_l3_16;
     muxed_data_l4_59 = sel[1] ? muxed_data_l3_57  :  muxed_data_l3_59[7:1];

     muxed_data_l5_0  = sel[0] ? muxed_data_l4_59 : muxed_data_l4_0[7:1];
     muxed_data_l5_1  = sel[0] ? muxed_data_l4_0 : muxed_data_l4_1;
     muxed_data_l5_2  = sel[0] ? muxed_data_l4_1 : muxed_data_l4_2;
     muxed_data_l5_3  = sel[0] ? muxed_data_l4_2 : muxed_data_l4_3;
     muxed_data_l5_4  = sel[0] ? muxed_data_l4_3 : muxed_data_l4_4;
     muxed_data_l5_5  = sel[0] ? muxed_data_l4_4 : muxed_data_l4_5;
     muxed_data_l5_6  = sel[0] ? muxed_data_l4_5 : muxed_data_l4_6;
     muxed_data_l5_7  = sel[0] ? muxed_data_l4_6 : muxed_data_l4_7;
     muxed_data_l5_8  = sel[0] ? muxed_data_l4_7 : muxed_data_l4_8;
     muxed_data_l5_9  = sel[0] ? muxed_data_l4_8 : muxed_data_l4_9;
     muxed_data_l5_10 = sel[0] ? muxed_data_l4_9 : muxed_data_l4_10;
     muxed_data_l5_11 = sel[0] ? muxed_data_l4_10 : muxed_data_l4_11;
     muxed_data_l5_12 = sel[0] ? muxed_data_l4_11 : muxed_data_l4_12;
     muxed_data_l5_13 = sel[0] ? muxed_data_l4_12 : muxed_data_l4_13;
     muxed_data_l5_14 = sel[0] ? muxed_data_l4_13 : muxed_data_l4_14;
     muxed_data_l5_15 = sel[0] ? muxed_data_l4_14 : muxed_data_l4_15;
     muxed_data_l5_16 = sel[0] ? muxed_data_l4_15 : muxed_data_l4_16;

     data_mux_fn_128 = {muxed_data_l5_16, muxed_data_l5_15,
                        muxed_data_l5_14,muxed_data_l5_13,muxed_data_l5_12,
                        muxed_data_l5_11,muxed_data_l5_10,muxed_data_l5_9,
                        muxed_data_l5_8,muxed_data_l5_7, muxed_data_l5_6,
                        muxed_data_l5_5,muxed_data_l5_4,muxed_data_l5_3,
                        muxed_data_l5_2,muxed_data_l5_1,muxed_data_l5_0};
  end
  endfunction


  generate
    if (ATB_DATA_WIDTH == 32)
    begin : gen_unf_mux_atb32
      assign  {unformatted_data,unformatted_id} = data_mux_fn_32(sel,frame_buffer);
    end

    else if (ATB_DATA_WIDTH == 64)
    begin : gen_unf_mux_atb64
      assign  {unformatted_data,unformatted_id} = data_mux_fn_64(sel,frame_buffer);
    end

    else
    begin : gen_unf_mux_atb128
      assign  {unformatted_data,unformatted_id} = data_mux_fn_128(sel,frame_buffer);
    end
  endgenerate

endmodule


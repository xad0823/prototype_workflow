//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2009, 2016-2017 Arm Limited or its affiliates.
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
//   Top level of css600_one_hot_mux
//
//----------------------------------------------------------------------------


module css600_one_hot_mux
  (
   inp_sel,
   inp_data,
   out_data
   );


  parameter SEL_WIDTH  = 2;
  parameter DATA_WIDTH = 2;


  input [SEL_WIDTH-1:0]               inp_sel;
  input [(SEL_WIDTH*DATA_WIDTH)-1:0]  inp_data;
  output [DATA_WIDTH-1:0]             out_data;


  genvar                              g_data;
  genvar                              g_sel;

  generate
    for (g_data=0;g_data<DATA_WIDTH;g_data=g_data+1)
    begin : g_data_width
      wire [SEL_WIDTH-1:0] column;

      for (g_sel=0;g_sel<SEL_WIDTH;g_sel=g_sel+1)
      begin : g_sel_width
        assign column[g_sel] = inp_data[(g_sel*DATA_WIDTH) + g_data];
      end

      assign out_data[g_data] = |(column & inp_sel);
    end
  endgenerate


endmodule


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

module sse710_integration_example_f0_blockram_128
  #(parameter ADDRESSWIDTH = 18)   

  (input  wire                      HCLK,      
   input  wire                      HRESETn,   
   input  wire                      HSELBRAM,  
   input  wire                      HREADY,    
   input  wire  [1:0]               HTRANS,    
   input  wire  [2:0]               HSIZE,     
   input  wire                      HWRITE,    
   input  wire  [ADDRESSWIDTH-1:0]  HADDR,     
   input  wire  [127:0]             HWDATA,    

   output wire                      HREADYOUT, 
   output wire                      HRESP,     
   output wire [127:0]              HRDATA);   

   localparam AW            = (ADDRESSWIDTH-1);
   localparam AWT           = ((1<<(AW-1))-1);
   
   localparam RSP_OKAY      = 1'b0;

  reg     [7:0] bram0  [0:AWT];
  reg     [7:0] bram1  [0:AWT];
  reg     [7:0] bram2  [0:AWT];
  reg     [7:0] bram3  [0:AWT];
  reg     [7:0] bram4  [0:AWT];
  reg     [7:0] bram5  [0:AWT];
  reg     [7:0] bram6  [0:AWT];
  reg     [7:0] bram7  [0:AWT];
  reg     [7:0] bram8  [0:AWT];
  reg     [7:0] bram9  [0:AWT];
  reg     [7:0] bram10 [0:AWT];
  reg     [7:0] bram11 [0:AWT];
  reg     [7:0] bram12 [0:AWT];
  reg     [7:0] bram13 [0:AWT];
  reg     [7:0] bram14 [0:AWT];
  reg     [7:0] bram15 [0:AWT];

  reg  [AW-4:0] reg_haddr;  
  wire          trn_valid;  
  wire   [15:0] nxt_wr_en;  
  reg    [15:0] reg_wr_en;  
  wire          wr_en_actv; 
  wire          size___8bit;
  wire          size__16bit;
  wire          size__32bit;
  wire          size__64bit;
  wire          size_128bit;
  wire          unused;


  assign trn_valid = HSELBRAM & HREADY & HTRANS[1];

  assign wr_en_actv   = (trn_valid & HWRITE) | (|reg_wr_en);

  assign size___8bit = (HSIZE[2:0]==3'b000);
  assign size__16bit = (HSIZE[2:0]==3'b001);
  assign size__32bit = (HSIZE[2:0]==3'b010);
  assign size__64bit = (HSIZE[2:0]==3'b011);
  assign size_128bit = (HSIZE[2:0]==3'b100);

  assign nxt_wr_en[0]  = (((HADDR[3:0]==4'b0000) && size___8bit) ||
                          ((HADDR[3:1]==3'b000)  && size__16bit) ||
                          ((HADDR[3:2]==2'b00)   && size__32bit) ||
                          ((HADDR[3]  ==1'b0)    && size__64bit) ||
                                                    size_128bit )? trn_valid & HWRITE : 1'b0;

  assign nxt_wr_en[1]  = (((HADDR[3:0]==4'b0001) && size___8bit) ||
                          ((HADDR[3:1]==3'b000)  && size__16bit) ||
                          ((HADDR[3:2]==2'b00)   && size__32bit) ||
                          ((HADDR[3]  ==1'b0)    && size__64bit) ||
                                                    size_128bit )? trn_valid & HWRITE : 1'b0;
  assign nxt_wr_en[2]  = (((HADDR[3:0]==4'b0010) && size___8bit) ||
                          ((HADDR[3:1]==3'b001)  && size__16bit) ||
                          ((HADDR[3:2]==2'b00)   && size__32bit) ||
                          ((HADDR[3]  ==1'b0)    && size__64bit) ||
                                                    size_128bit )? trn_valid & HWRITE : 1'b0;
  assign nxt_wr_en[3]  = (((HADDR[3:0]==4'b0011) && size___8bit) ||
                          ((HADDR[3:1]==3'b001)  && size__16bit) ||
                          ((HADDR[3:2]==2'b00)   && size__32bit) ||
                          ((HADDR[3]  ==1'b0)    && size__64bit) ||
                                                    size_128bit )? trn_valid & HWRITE : 1'b0;
  assign nxt_wr_en[4]  = (((HADDR[3:0]==4'b0100) && size___8bit) ||
                          ((HADDR[3:1]==3'b010)  && size__16bit) ||
                          ((HADDR[3:2]==2'b01)   && size__32bit) ||
                          ((HADDR[3]  ==1'b0)    && size__64bit) ||
                                                    size_128bit )? trn_valid & HWRITE : 1'b0;
  assign nxt_wr_en[5]  = (((HADDR[3:0]==4'b0101) && size___8bit) ||
                          ((HADDR[3:1]==3'b010)  && size__16bit) ||
                          ((HADDR[3:2]==2'b01)   && size__32bit) ||
                          ((HADDR[3]  ==1'b0)    && size__64bit) ||
                                                    size_128bit )? trn_valid & HWRITE : 1'b0;
  assign nxt_wr_en[6]  = (((HADDR[3:0]==4'b0110) && size___8bit) ||
                          ((HADDR[3:1]==3'b011)  && size__16bit) ||
                          ((HADDR[3:2]==2'b01)   && size__32bit) ||
                          ((HADDR[3]  ==1'b0)    && size__64bit) ||
                                                    size_128bit )? trn_valid & HWRITE : 1'b0;
  assign nxt_wr_en[7]  = (((HADDR[3:0]==4'b0111) && size___8bit) ||
                          ((HADDR[3:1]==3'b011)  && size__16bit) ||
                          ((HADDR[3:2]==2'b01)   && size__32bit) ||
                          ((HADDR[3]  ==1'b0)    && size__64bit) ||
                                                    size_128bit )? trn_valid & HWRITE : 1'b0;
  assign nxt_wr_en[8]  = (((HADDR[3:0]==4'b1000) && size___8bit) ||
                          ((HADDR[3:1]==3'b100)  && size__16bit) ||
                          ((HADDR[3:2]==2'b10)   && size__32bit) ||
                          ((HADDR[3]  ==1'b1)    && size__64bit) ||
                                                    size_128bit )? trn_valid & HWRITE : 1'b0;
  assign nxt_wr_en[9]  = (((HADDR[3:0]==4'b1001) && size___8bit) ||
                          ((HADDR[3:1]==3'b100)  && size__16bit) ||
                          ((HADDR[3:2]==2'b10)   && size__32bit) ||
                          ((HADDR[3]  ==1'b1)    && size__64bit) ||
                                                    size_128bit )? trn_valid & HWRITE : 1'b0;
  assign nxt_wr_en[10] = (((HADDR[3:0]==4'b1010) && size___8bit) ||
                          ((HADDR[3:1]==3'b101)  && size__16bit) ||
                          ((HADDR[3:2]==2'b10)   && size__32bit) ||
                          ((HADDR[3]  ==1'b1)    && size__64bit) ||
                                                    size_128bit )? trn_valid & HWRITE : 1'b0;
  assign nxt_wr_en[11] = (((HADDR[3:0]==4'b1011) && size___8bit) ||
                          ((HADDR[3:1]==3'b101)  && size__16bit) ||
                          ((HADDR[3:2]==2'b10)   && size__32bit) ||
                          ((HADDR[3]  ==1'b1)    && size__64bit) ||
                                                    size_128bit )? trn_valid & HWRITE : 1'b0;
  assign nxt_wr_en[12] = (((HADDR[3:0]==4'b1100) && size___8bit) ||
                          ((HADDR[3:1]==3'b110)  && size__16bit) ||
                          ((HADDR[3:2]==2'b11)   && size__32bit) ||
                          ((HADDR[3]  ==1'b1)    && size__64bit) ||
                                                    size_128bit )? trn_valid & HWRITE : 1'b0;
  assign nxt_wr_en[13] = (((HADDR[3:0]==4'b1101) && size___8bit) ||
                          ((HADDR[3:1]==3'b110)  && size__16bit) ||
                          ((HADDR[3:2]==2'b11)   && size__32bit) ||
                          ((HADDR[3]  ==1'b1)    && size__64bit) ||
                                                    size_128bit )? trn_valid & HWRITE : 1'b0;
  assign nxt_wr_en[14] = (((HADDR[3:0]==4'b1110) && size___8bit) ||
                          ((HADDR[3:1]==3'b111)  && size__16bit) ||
                          ((HADDR[3:2]==2'b11)   && size__32bit) ||
                          ((HADDR[3]  ==1'b1)    && size__64bit) ||
                                                    size_128bit )? trn_valid & HWRITE : 1'b0;
  assign nxt_wr_en[15] = (((HADDR[3:0]==4'b1111) && size___8bit) ||
                          ((HADDR[3:1]==3'b111)  && size__16bit) ||
                          ((HADDR[3:2]==2'b11)   && size__32bit) ||
                          ((HADDR[3]  ==1'b1)    && size__64bit) ||
                                                    size_128bit )? trn_valid & HWRITE : 1'b0;

  always @ (negedge HRESETn or posedge HCLK)
  begin
    if (~HRESETn)
      reg_wr_en <= 16'h0000;
    else if (wr_en_actv)
      reg_wr_en <= nxt_wr_en;
  end

  always @ (posedge HCLK)
    begin
      if (reg_wr_en[0])
        bram0[reg_haddr] <= HWDATA[7:0];
      if (reg_wr_en[1])
        bram1[reg_haddr] <= HWDATA[15:8];
      if (reg_wr_en[2])
        bram2[reg_haddr] <= HWDATA[23:16];
      if (reg_wr_en[3])
        bram3[reg_haddr] <= HWDATA[31:24];
      if (reg_wr_en[4])
        bram4[reg_haddr] <= HWDATA[39:32];
      if (reg_wr_en[5])
        bram5[reg_haddr] <= HWDATA[47:40];
      if (reg_wr_en[6])
        bram6[reg_haddr] <= HWDATA[55:48];
      if (reg_wr_en[7])
        bram7[reg_haddr] <= HWDATA[63:56];
      if (reg_wr_en[8])
        bram8[reg_haddr] <= HWDATA[71:64];
      if (reg_wr_en[9])
        bram9[reg_haddr] <= HWDATA[79:72];
      if (reg_wr_en[10])
        bram10[reg_haddr] <= HWDATA[87:80];
      if (reg_wr_en[11])
        bram11[reg_haddr] <= HWDATA[95:88];
      if (reg_wr_en[12])
        bram12[reg_haddr] <= HWDATA[103:96];
      if (reg_wr_en[13])
        bram13[reg_haddr] <= HWDATA[111:104];
      if (reg_wr_en[14])
        bram14[reg_haddr] <= HWDATA[119:112];
      if (reg_wr_en[15])
        bram15[reg_haddr] <= HWDATA[127:120];

      reg_haddr <= HADDR[AW:4];
    end

  assign HRESP     = RSP_OKAY;
  assign HREADYOUT = 1'b1;
  assign HRDATA    = {bram15[reg_haddr],bram14[reg_haddr],
                      bram13[reg_haddr],bram12[reg_haddr],
                      bram11[reg_haddr],bram10[reg_haddr],
                      bram9[reg_haddr],bram8[reg_haddr],
                      bram7[reg_haddr],bram6[reg_haddr],
                      bram5[reg_haddr],bram4[reg_haddr],
                      bram3[reg_haddr],bram2[reg_haddr],
                      bram1[reg_haddr],bram0[reg_haddr]};
    
    
  assign unused = HTRANS[0];

endmodule

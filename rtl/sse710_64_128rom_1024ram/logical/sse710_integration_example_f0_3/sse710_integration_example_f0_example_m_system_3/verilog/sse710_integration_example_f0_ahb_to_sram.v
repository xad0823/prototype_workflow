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

module sse710_integration_example_f0_ahb_to_sram #(
  parameter AW       = 16) 
 (
  input  wire          HCLK,      
  input  wire          HRESETn,   
  input  wire          HSEL,      
  input  wire          HREADY,    
  input  wire    [1:0] HTRANS,    
  input  wire    [2:0] HSIZE,     
  input  wire          HWRITE,    
  input  wire [AW-1:0] HADDR,     
  input  wire   [31:0] HWDATA,    
  output wire          HREADYOUT, 
  output wire          HRESP,     
  output wire   [31:0] HRDATA,    

  input  wire   [31:0] SRAMRDATA, 
  output wire [AW-3:0] SRAMADDR,  
  output wire    [3:0] SRAMWEN,   
  output wire   [31:0] SRAMWDATA, 
  output wire          SRAMCS);   

   reg  [(AW-3):0]           buf_addr;        
   reg  [ 3:0]               buf_we;          
   reg                       buf_hit;         
   reg  [31:0]               buf_data;        
   reg                       buf_pend;        
   reg                       buf_data_en;     


   wire        ahb_access   = HTRANS[1] & HSEL & HREADY;
   wire        ahb_write    = ahb_access &  HWRITE;
   wire        ahb_read     = ahb_access & (~HWRITE);

   wire        buf_pend_nxt = (buf_pend | buf_data_en) & ahb_read;

   wire        ram_write    = (buf_pend | buf_data_en)  & (~ahb_read); 

   assign      SRAMWEN  = {4{ram_write}} & buf_we[3:0];

   assign      SRAMADDR = ahb_read ? HADDR[AW-1:2] : buf_addr;

   assign      SRAMCS   = ahb_read | ram_write;


   wire       tx_byte    = (~HSIZE[1]) & (~HSIZE[0]);
   wire       tx_half    = (~HSIZE[1]) &  HSIZE[0];
   wire       tx_word    =   HSIZE[1];

   wire       byte_at_00 = tx_byte & (~HADDR[1]) & (~HADDR[0]);
   wire       byte_at_01 = tx_byte & (~HADDR[1]) &   HADDR[0];
   wire       byte_at_10 = tx_byte &   HADDR[1]  & (~HADDR[0]);
   wire       byte_at_11 = tx_byte &   HADDR[1]  &   HADDR[0];

   wire       half_at_00 = tx_half & (~HADDR[1]);
   wire       half_at_10 = tx_half &   HADDR[1];

   wire       word_at_00 = tx_word;

   wire       byte_sel_0 = word_at_00 | half_at_00 | byte_at_00;
   wire       byte_sel_1 = word_at_00 | half_at_00 | byte_at_01;
   wire       byte_sel_2 = word_at_00 | half_at_10 | byte_at_10;
   wire       byte_sel_3 = word_at_00 | half_at_10 | byte_at_11;

   wire [3:0] buf_we_nxt = { byte_sel_3 & ahb_write,
                             byte_sel_2 & ahb_write,
                             byte_sel_1 & ahb_write,
                             byte_sel_0 & ahb_write };


   always @(posedge HCLK or negedge HRESETn)
     if (~HRESETn)
       buf_data_en <= 1'b0;
     else
       buf_data_en <= ahb_write;

   always @(posedge HCLK)
     if(buf_we[3] & buf_data_en)
       buf_data[31:24] <= HWDATA[31:24];

   always @(posedge HCLK)
     if(buf_we[2] & buf_data_en)
       buf_data[23:16] <= HWDATA[23:16];

   always @(posedge HCLK)
     if(buf_we[1] & buf_data_en)
       buf_data[15: 8] <= HWDATA[15: 8];

   always @(posedge HCLK)
     if(buf_we[0] & buf_data_en)
       buf_data[ 7: 0] <= HWDATA[ 7: 0];

   always @(posedge HCLK or negedge HRESETn)
     if (~HRESETn)
       buf_we <= 4'b0000;
     else if(ahb_write)
       buf_we <= buf_we_nxt;

   always @(posedge HCLK or negedge HRESETn)
     begin
     if (~HRESETn)
       buf_addr <= {(AW-2){1'b0}};
     else if (ahb_write)
         buf_addr <= HADDR[(AW-1):2];
     end

   wire  buf_hit_nxt = (HADDR[AW-1:2] == buf_addr[AW-3:0]);


   wire [ 3:0] merge1  = {4{buf_hit}} & buf_we; 

   assign HRDATA =
              { merge1[3] ? buf_data[31:24] : SRAMRDATA[31:24],
                merge1[2] ? buf_data[23:16] : SRAMRDATA[23:16],
                merge1[1] ? buf_data[15: 8] : SRAMRDATA[15: 8],
                merge1[0] ? buf_data[ 7: 0] : SRAMRDATA[ 7: 0] };


   always @(posedge HCLK or negedge HRESETn)
     if (~HRESETn)
       buf_hit <= 1'b0;
     else if(ahb_read)
       buf_hit <= buf_hit_nxt;

   always @(posedge HCLK or negedge HRESETn)
     if (~HRESETn)
       buf_pend <= 1'b0;
     else
       buf_pend <= buf_pend_nxt;

   assign SRAMWDATA = (buf_pend) ? buf_data : HWDATA[31:0];

   assign HREADYOUT = 1'b1;
   assign HRESP     = 1'b0;

`ifdef ARM_AHB_ASSERT_ON

`include "std_ovl_defines.h"

   reg ovl_ahb_read_reg;  
   reg ovl_ahb_write_reg; 
   reg ovl_buf_pend_reg;  

   always @(posedge HCLK or negedge HRESETn)
   begin
   if (~HRESETn)
     begin
     ovl_ahb_read_reg  <= 1'b0;
     ovl_ahb_write_reg <= 1'b0;
     ovl_buf_pend_reg  <= 1'b0;
     end
   else
     begin
     ovl_ahb_read_reg  <= ahb_read;
     ovl_ahb_write_reg <= ahb_write;
     ovl_buf_pend_reg  <= buf_pend;
     end
   end



   assert_never
     #(`OVL_ERROR,`OVL_ASSERT,
       "SRAMADDR read incorrect")
   u_ovl_sramaddr_read_transfer_error
     (.clk(HCLK), .reset_n(HRESETn),
      .test_expr(HTRANS[1] & HSEL & HREADY & (~HWRITE) & (SRAMADDR != HADDR[(AW-1):2]))
      );

   assert_never
     #(`OVL_ERROR,`OVL_ASSERT,
       "SRAMWEN read incorrect")
   u_ovl_sramwen_read_transfer_error
     (.clk(HCLK), .reset_n(HRESETn),
      .test_expr(HTRANS[1] & HSEL & HREADY & (~HWRITE) & (SRAMWEN!=4'b0000))
      );

   assert_never
     #(`OVL_ERROR,`OVL_ASSERT,
       "SRAMCS read incorrect")
   u_ovl_sramcs_read_transfer_error
     (.clk(HCLK), .reset_n(HRESETn),
      .test_expr(HTRANS[1] & HSEL & HREADY & (~HWRITE) & (SRAMCS!=1'b1))
      );


   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "SRAMADDR write incorrect")
   u_ovl_sramaddr_wr_transfer_error
     (.clk(HCLK), .reset_n(HRESETn),
      .antecedent_expr(ovl_ahb_write_reg & 
        (ahb_read==1'b0)), 
      .consequent_expr(SRAMADDR==buf_addr)
      );

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "SRAMCS write incorrect")
   u_ovl_sramcs_wr_transfer_error
     (.clk(HCLK), .reset_n(HRESETn),
      .antecedent_expr(ovl_ahb_write_reg & 
        (ahb_read==1'b0)), 
      .consequent_expr(SRAMCS)
      );

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "SRAMWEN write incorrect")
   u_ovl_sramwen_wr_transfer_error
     (.clk(HCLK), .reset_n(HRESETn),
      .antecedent_expr(ovl_ahb_write_reg & 
        (ahb_read==1'b0)), 
      .consequent_expr(SRAMWEN==buf_we)
      );

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "SRAMWDATA write incorrect")
   u_ovl_sramwdata_wr_transfer_error
     (.clk(HCLK), .reset_n(HRESETn),
      .antecedent_expr(ovl_ahb_write_reg & 
        (ahb_read==1'b0)),  
      .consequent_expr(buf_pend == 1'b0) 
      ); 


   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "SRAMADDR buffer write incorrect")
   u_ovl_sramaddr_bufwr_transfer_error
     (.clk(HCLK), .reset_n(HRESETn),
      .antecedent_expr(((~(HTRANS[1] & HSEL & HREADY))|(HWRITE)) & 
        (buf_pend==1'b1)), 
      .consequent_expr(SRAMADDR==buf_addr)
      );

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "SRAMWDATA buffer write incorrect")
   u_ovl_sramwdata_bufwr_transfer_error
     (.clk(HCLK), .reset_n(HRESETn),
      .antecedent_expr(((~(HTRANS[1] & HSEL & HREADY))|(HWRITE)) & 
        (buf_pend==1'b1)),  
      .consequent_expr(SRAMWDATA==buf_data)
      );

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "SRAMWDATA buffer write incorrect")
   u_ovl_sramcs_bufwr_transfer_error
     (.clk(HCLK), .reset_n(HRESETn),
      .antecedent_expr(((~(HTRANS[1] & HSEL & HREADY))|(HWRITE)) & 
        (buf_pend==1'b1)),  
      .consequent_expr(SRAMCS)
      );

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "SRAMWEN buffer write incorrect")
   u_ovl_sramwen_bufwr_transfer_error
     (.clk(HCLK), .reset_n(HRESETn),
      .antecedent_expr(((~(HTRANS[1] & HSEL & HREADY))|(HWRITE)) & 
        (buf_pend==1'b1)), 
      .consequent_expr(SRAMWEN==buf_we)
      );


   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "buf_pend not staying high at read")
   u_ovl_buf_pend_nxt_set_error
     (.clk(HCLK), .reset_n(HRESETn),
      .antecedent_expr(ovl_ahb_write_reg & ahb_read),
      .consequent_expr(buf_pend_nxt)
      );

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "buf_pend not staying high at read")
   u_ovl_buf_pend_stay_error
     (.clk(HCLK), .reset_n(HRESETn),
      .antecedent_expr(ovl_ahb_read_reg & ovl_buf_pend_reg),
      .consequent_expr(buf_pend)
      );

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "buf_pend not clear")
   u_ovl_buf_pend_clear_error
     (.clk(HCLK), .reset_n(HRESETn),
      .antecedent_expr(ovl_ahb_write_reg | (~ovl_ahb_read_reg)),
      .consequent_expr(~buf_pend)
      );

`endif

endmodule

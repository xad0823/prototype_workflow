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
 


module system_id
#(
    parameter IIDR_PRODUCT_ID          = 12'd762,
    parameter IIDR_VARIANT_ID          = 4'd0,
    parameter IIDR_REVISION            = 4'd0,
    parameter IIDR_IMPLEMENTER         = 12'h43b
 )
(
    
    input wire                 penable,
    input wire [11:0]          paddr,
    
    input wire                 psel,
    output wire                pready,
    output wire [31:0]         prdata,
    output wire                pslverr,
    

    input wire [3:0] bsys_cfg0_num_host_cpu,
    input wire [3:0] bsys_cfg1_ext_sys3,
    input wire [3:0] bsys_cfg1_ext_sys2,
    input wire [3:0] bsys_cfg1_ext_sys1,
    input wire [3:0] bsys_cfg1_ext_sys0,
    input wire  bsys_cfg2_ocvm_en,
    input wire [3:0] bsys_cfg2_num_exp_mst,
    input wire [3:0] bsys_cfg2_num_exp_slv,
    input wire [11:0] soc_id_product_id,
    input wire [3:0] soc_id_variant_id,
    input wire [3:0] soc_id_revision,
    input wire [11:0] soc_id_implementer,
    input wire                 clk,
    input wire                 resetn

);
   reg [11:0] paddr_reg;
    
    always @(posedge clk or negedge resetn)
    begin
      if (!resetn)
      begin
       paddr_reg<=12'd0;      
      end
      else
      begin       
        
        if(psel && !penable)
        begin
            paddr_reg<=paddr[11:0];                
        end
      end        
    end        
  
  wire [31:0] bsys_cfg0_val;                
  wire [31:0] bsys_cfg1_val;                
  wire [31:0] bsys_cfg2_val;                
  wire [31:0] bsys_cfg3_val;                
  wire [31:0] soc_id_val;  
  
  wire [31:0] cid0_val;                
  wire [31:0] cid1_val;                
  wire [31:0] cid2_val;                
  wire [31:0] cid3_val;

  wire [31:0] pid6_val;                
  wire [31:0] pid5_val;                
  wire [31:0] pid7_val;                
  wire [31:0] pid0_val;                
  wire [31:0] pid1_val;                
  wire [31:0] pid2_val;                
  wire [31:0] pid3_val;                

  wire [31:0] iidr_val;  
  wire [31:0] pid4_val;  
  
  assign bsys_cfg0_val[31:4] = 28'h0000000;  
  assign bsys_cfg0_val[3:0] = bsys_cfg0_num_host_cpu;

  assign bsys_cfg1_val[31:16] = 16'h0000;  
  assign bsys_cfg1_val[15:12] = bsys_cfg1_ext_sys3;  
  assign bsys_cfg1_val[11:8] = bsys_cfg1_ext_sys2;  
  assign bsys_cfg1_val[7:4] = bsys_cfg1_ext_sys1;  
  assign bsys_cfg1_val[3:0] = bsys_cfg1_ext_sys0;

  
  assign bsys_cfg2_val[31:25] = 7'h00;
  assign bsys_cfg2_val[24:24] = bsys_cfg2_ocvm_en;  
  assign bsys_cfg2_val[23:20] = bsys_cfg2_num_exp_mst;  
  assign bsys_cfg2_val[19:16] = bsys_cfg2_num_exp_slv;                
  assign bsys_cfg2_val[15:0] = 16'b0;
  
  assign bsys_cfg3_val[31:0] = 32'h00000000;

  assign soc_id_val[31:20] = soc_id_product_id;  
  assign soc_id_val[19:16] = soc_id_variant_id;  
  assign soc_id_val[15:12] = soc_id_revision;  
  assign soc_id_val[11:0] = soc_id_implementer;

  assign iidr_val[31:20] = IIDR_PRODUCT_ID; 
  assign iidr_val[19:16] = pid2_val[7:4];   
  assign iidr_val[15:12] = pid3_val[7:4];   
  assign iidr_val[11:0] = IIDR_IMPLEMENTER;

  
  assign pid4_val[31:8] = 24'h000000;  
  assign pid4_val[7:4] = 4'h0;  
  assign pid4_val[3:0] = IIDR_IMPLEMENTER[11:8]; 
  
  assign pid5_val[31:0] = 32'h00000000;
  
  assign pid6_val[31:0] = 32'h00000000;
  
  assign pid7_val[31:0] = 32'h00000000;
  
  assign pid0_val[31:8] = 24'h000000;  
  assign pid0_val[7:0] = IIDR_PRODUCT_ID[7:0]; 

  assign pid1_val[31:8] = 24'h000000;               
  assign pid1_val[7:4] = IIDR_IMPLEMENTER[3:0]; 
  assign pid1_val[3:0] = IIDR_PRODUCT_ID[11:8]; 

  assign pid2_val[31:8] = 24'h000000;  
  arm_element_ecorevnum #( .WIDTH (4), .ECOREVVAL(IIDR_VARIANT_ID) ) u_pid2_0 ( .ecorevnum( pid2_val[7:4]) );            
  assign pid2_val[3:3] = 1'b1;
  assign pid2_val[2:0] = IIDR_IMPLEMENTER[6:4]; 

  
  assign pid3_val[31:8] = 24'h000000; 
  arm_element_ecorevnum #( .WIDTH (4), .ECOREVVAL(IIDR_REVISION) ) u_pid3_0 ( .ecorevnum( pid3_val[7:4]) );               
  assign pid3_val[3:0] = 4'h0;
  
  assign cid0_val[31:8] = 24'h000000;
  assign cid0_val[7:0] = 8'h0D;
  
  assign cid1_val[31:8] = 24'h000000;               
  assign cid1_val[7:4] = 4'hF;                
  assign cid1_val[3:0] = 4'h0;

  assign cid2_val[31:8] = 24'h000000;                
  assign cid2_val[7:0] = 8'h05;

  assign cid3_val[31:8] = 24'h000000;
  assign cid3_val[7:0] = 8'hB1;
  
  assign prdata = 
         paddr_reg ==  12'h000 ? bsys_cfg0_val: 
         paddr_reg ==  12'h004 ? bsys_cfg1_val: 
         paddr_reg ==  12'h008 ? bsys_cfg2_val: 
         paddr_reg ==  12'h00c ? bsys_cfg3_val: 
         paddr_reg ==  12'h040 ? soc_id_val: 
         paddr_reg ==  12'hFC8 ? iidr_val: 
         paddr_reg ==  12'hFD0 ? pid4_val: 
         paddr_reg ==  12'hFD4 ? pid5_val: 
         paddr_reg ==  12'hFD8 ? pid6_val: 
         paddr_reg ==  12'hFDC ? pid7_val: 
         paddr_reg ==  12'hFE0 ? pid0_val: 
         paddr_reg ==  12'hFE4 ? pid1_val: 
         paddr_reg ==  12'hFE8 ? pid2_val: 
         paddr_reg ==  12'hFEC ? pid3_val: 
         paddr_reg ==  12'hFF0 ? cid0_val: 
         paddr_reg ==  12'hFF4 ? cid1_val: 
         paddr_reg ==  12'hFF8 ? cid2_val: 
         paddr_reg ==  12'hFFC ? cid3_val: 
                        32'd0;
  assign pslverr = 
         paddr_reg ==  12'h000 ? 1'b0 : 
         paddr_reg ==  12'h004 ? 1'b0 : 
         paddr_reg ==  12'h008 ? 1'b0 : 
         paddr_reg ==  12'h00c ? 1'b0 : 
         paddr_reg ==  12'h040 ? 1'b0 : 
         paddr_reg ==  12'hFC8 ? 1'b0 : 
         paddr_reg ==  12'hFD0 ? 1'b0 : 
         paddr_reg ==  12'hFD4 ? 1'b0 : 
         paddr_reg ==  12'hFD8 ? 1'b0 : 
         paddr_reg ==  12'hFDC ? 1'b0 : 
         paddr_reg ==  12'hFE0 ? 1'b0 : 
         paddr_reg ==  12'hFE4 ? 1'b0 : 
         paddr_reg ==  12'hFE8 ? 1'b0 : 
         paddr_reg ==  12'hFEC ? 1'b0 : 
         paddr_reg ==  12'hFF0 ? 1'b0 : 
         paddr_reg ==  12'hFF4 ? 1'b0 : 
         paddr_reg ==  12'hFF8 ? 1'b0 : 
         paddr_reg ==  12'hFFC ? 1'b0 : 
         1'b0;

  assign pready = 1'b1;
  
endmodule

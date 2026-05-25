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

module sse710_boot_reg_f0_aontop
 #(
   parameter [7:0] WREN_ID = 8'h00  
 )(
    
    input  wire           refclk,
    
    input  wire           aontop_warmresetn,
        
    input wire            qreqn_bootreg_refclk,
    output wire           qacceptn_bootreg_refclk,
    output wire           qdeny_bootreg_refclk,
    output wire           qactive_bootreg_refclk,     
    
    input  wire           apb_async_req_bootreg,
    input  wire [61:0]    apb_async_req_payload_bootreg,
    output wire [32:0]    apb_async_resp_payload_bootreg,
    output wire           apb_async_ack_bootreg,
    
    input  wire           dftcgen   
  );

  
  wire [25:0]    paddr;
  wire [31:0]    pwdata;
  wire           pwrite;
  wire           psel;
  wire           penable;
  wire [2:0]     pprot;
  wire [3:0]     pstrb;
  reg  [31:0]    prdata;
  wire           pready;    
  wire           pslverr; 
  reg  [9:0]     paddr_r;
  wire [9:0]     nxt_paddr;
  
  reg  [31:0]    bir0;
  reg  [31:0]    bir1;
  reg  [31:0]    bir2;
  reg  [31:0]    bir3;
  
  wire           bir0_en;
  wire           bir1_en;
  wire           bir2_en;
  wire           bir3_en;
  
  wire  [31:0]   nxt_bir0;
  wire  [31:0]   nxt_bir1;
  wire  [31:0]   nxt_bir2;
  wire  [31:0]   nxt_bir3;
  
  wire           wr_en_mst_id;
  
  wire           full_word_write;
  
  wire [1:0]     read_size;
  reg            unaligned_rd;
 
  reg  [3:0]     bir_done_r;
  wire           bir_done_en;
  wire [3:0]     nxt_bir_done;
  
  reg            pslverr_r;
  wire           nxt_pslverr;
  reg            nxt_pslverr_func;
  wire           nxt_pslverr_unaligned_rd;
  wire           pslverr_en;
  
  wire           apb_wr_en;
  wire           apb_rd_en;
  
  wire [31:0]    rdata_pid0;
  wire [31:0]    rdata_pid1;
  wire [31:0]    rdata_pid2;
  wire [31:0]    rdata_pid3;
  wire [31:0]    rdata_pid4;
  wire [31:0]    rdata_pid5;
  wire [31:0]    rdata_pid6;
  wire [31:0]    rdata_pid7;
  wire [31:0]    rdata_cid0;
  wire [31:0]    rdata_cid1;
  wire [31:0]    rdata_cid2;
  wire [31:0]    rdata_cid3;
  
  wire [3:0]     rdata_pid2_eco;
  wire [3:0]     rdata_pid3_eco;
  
  wire           unused;
  


  css600_apbasyncbridgemstr #(
    .APB_ADDR_WIDTH(26),
    .FF_SYNC_DEPTH(2)
  ) u_css600_apbasyncbridgemstr (
    .clk_m                      (refclk),
    .reset_m_n                  (aontop_warmresetn),
    .dftcgen                    (dftcgen),
    .psel_m                     (psel),
    .penable_m                  (penable),
    .paddr_m                    (paddr),
    .pwrite_m                   (pwrite),
    .pwdata_m                   (pwdata),
    .pprot_m                    (pprot),
    .prdata_m                   (prdata),
    .pready_m                   (pready),
    .pslverr_m                  (pslverr),
    .pwakeup_m                  (),
    .clk_m_qreq_n               (qreqn_bootreg_refclk),
    .clk_m_qaccept_n            (qacceptn_bootreg_refclk),
    .clk_m_qdeny                (qdeny_bootreg_refclk),
    .clk_m_qactive              (qactive_bootreg_refclk),
    .apb_async_req              (apb_async_req_bootreg),         
    .apb_async_req_payload      (apb_async_req_payload_bootreg), 
    .apb_async_resp_payload     (apb_async_resp_payload_bootreg),
    .apb_async_ack              (apb_async_ack_bootreg)          
  );  
  

  assign apb_rd_en = psel & ~pwrite & ~penable;
  
  assign wr_en_mst_id = (paddr[19:12] == WREN_ID) ? 1'b1 : 1'b0;
  
  assign read_size = paddr[21:20];
  
  assign pstrb = paddr[25:22];
  
  assign full_word_write = &pstrb;
  
  assign apb_wr_en = psel & pwrite & ~penable & wr_en_mst_id & full_word_write;

  
  always @(*)
  begin
    case({paddr[1:0], read_size})
      4'b0000,                           
      4'b0001,                           
      4'b0010,                           
      4'b0100,                           
      4'b1000,                           
      4'b1001,                           
      4'b1100: unaligned_rd = 1'b0;      
      4'b0011,                           
      4'b0101,                           
      4'b0110,                           
      4'b0111,                           
      4'b1010,                           
      4'b1011,                           
      4'b1101,                           
      4'b1110,                           
      4'b1111: unaligned_rd = apb_rd_en; 
      default: unaligned_rd = 1'bx;      
    endcase
  end 
  
  
  always @(*)
  begin
    nxt_pslverr_func = (&(paddr[11:2] ^ (~paddr[11:2]))) ? ~penable : 1'b0;  
    case(paddr[11:2])
      10'h000: nxt_pslverr_func = (~apb_wr_en | bir_done_r[0]) & pwrite & ~penable;
      10'h001: nxt_pslverr_func = (~apb_wr_en | bir_done_r[1]) & pwrite & ~penable;
      10'h002: nxt_pslverr_func = (~apb_wr_en | bir_done_r[2]) & pwrite & ~penable;
      10'h003: nxt_pslverr_func = (~apb_wr_en | bir_done_r[3]) & pwrite & ~penable;
      10'h004,
      10'h005,
      10'h006,
      10'h007,
      10'h008,
      10'h009,
      10'h00A,
      10'h00B,
      10'h00C,
      10'h00D,
      10'h00E,
      10'h00F,
      10'h3F4,
      10'h3F5,
      10'h3F6,
      10'h3F7,
      10'h3F8,
      10'h3F9,
      10'h3FA,
      10'h3FB,
      10'h3FC,
      10'h3FD,
      10'h3FE,
      10'h3FF: nxt_pslverr_func = pwrite & ~penable;
    endcase
  end
  
  assign nxt_pslverr_unaligned_rd = unaligned_rd;
  
  assign nxt_pslverr = nxt_pslverr_func | nxt_pslverr_unaligned_rd;
  
  always@(posedge refclk or negedge aontop_warmresetn)
  begin
    if(!aontop_warmresetn)
    begin
      pslverr_r <= 1'b0;  
    end
    else if (pslverr_en)
    begin
      pslverr_r <= nxt_pslverr;
    end
  end  
  
  assign pslverr    = pslverr_r;
  
  assign pslverr_en = psel;
  

  assign nxt_bir0 = {32{bir0_en}} & pwdata;
  
  assign bir0_en  = apb_wr_en & (paddr[11:2] == 10'h000) & ~bir_done_r[0];

  always@(posedge refclk or negedge aontop_warmresetn)
  begin
    if(!aontop_warmresetn)
    begin
      bir0 <= 32'h0000_0000;  
    end
    else if (bir0_en)
    begin
      bir0 <= nxt_bir0;
    end
  end
  
  assign nxt_bir1 = {32{bir1_en}} & pwdata;

  assign bir1_en  = apb_wr_en & (paddr[11:2] == 10'h001) & ~bir_done_r[1];

  always@(posedge refclk or negedge aontop_warmresetn)
  begin
    if(!aontop_warmresetn)
    begin
      bir1 <= 32'h0000_0000;  
    end
    else if (bir1_en)
    begin
      bir1 <= nxt_bir1;
    end
  end  
  
  assign nxt_bir2 = {32{bir2_en}} & pwdata;

  assign bir2_en  = apb_wr_en & (paddr[11:2] == 10'h002) & ~bir_done_r[2];

  always@(posedge refclk or negedge aontop_warmresetn)
  begin
    if(!aontop_warmresetn)
    begin
      bir2 <= 32'h0000_0000;  
    end
    else if (bir2_en)
    begin
      bir2 <= nxt_bir2;
    end
  end
  
  assign nxt_bir3 = {32{bir3_en}} & pwdata;

  assign bir3_en  = apb_wr_en & (paddr[11:2] == 10'h003) & ~bir_done_r[3];

  always@(posedge refclk or negedge aontop_warmresetn)
  begin
    if(!aontop_warmresetn)
    begin
      bir3 <= 32'h0000_0000;  
    end
    else if (bir3_en)
    begin
      bir3 <= nxt_bir3;
    end
  end  


  always@(posedge refclk or negedge aontop_warmresetn)
  begin
    if(!aontop_warmresetn)
    begin
      bir_done_r <= 4'b0000;  
    end
    else if (bir_done_en)
    begin
      bir_done_r <= nxt_bir_done;
    end
  end
  
  assign nxt_bir_done = {bir3_en, bir2_en, bir1_en, bir0_en} | bir_done_r;
  assign bir_done_en  = bir0_en | bir1_en | bir2_en | bir3_en;
  
  
  always @(*)
  begin
    prdata =  (&(paddr_r ^ (~paddr_r))) ? 32'h0000_0000 : 32'hFFFF_FFFF;  
    case(paddr_r)
      10'h000: prdata = bir0;
      10'h001: prdata = bir1;
      10'h002: prdata = bir2;
      10'h003: prdata = bir3;
      10'h004: prdata = bir0;
      10'h005: prdata = bir1;
      10'h006: prdata = bir2;
      10'h007: prdata = bir3;
      10'h008: prdata = bir0;
      10'h009: prdata = bir1;
      10'h00A: prdata = bir2;
      10'h00B: prdata = bir3;
      10'h00C: prdata = bir0;
      10'h00D: prdata = bir1;
      10'h00E: prdata = bir2;
      10'h00F: prdata = bir3;
      10'h3F4: prdata = rdata_pid4;
      10'h3F5: prdata = rdata_pid5;
      10'h3F6: prdata = rdata_pid6;
      10'h3F7: prdata = rdata_pid7;
      10'h3F8: prdata = rdata_pid0;
      10'h3F9: prdata = rdata_pid1;
      10'h3FA: prdata = rdata_pid2;
      10'h3FB: prdata = rdata_pid3;
      10'h3FC: prdata = rdata_cid0;
      10'h3FD: prdata = rdata_cid1;
      10'h3FE: prdata = rdata_cid2;
      10'h3FF: prdata = rdata_cid3;
    endcase
  end
  
  arm_element_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'h0)
  ) u_arm_element_ecorevnum_0 (
    .ecorevnum (rdata_pid2_eco)
    );
  
  arm_element_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'h0)
  ) u_arm_element_ecorevnum_1 (
    .ecorevnum (rdata_pid3_eco)
  );  
  
  assign rdata_pid0 = 32'h0000_0072;
  assign rdata_pid1 = 32'h0000_00B0;
  assign rdata_pid2 = {24'h00_0000,rdata_pid2_eco,4'hB};
  assign rdata_pid3 = {24'h00_0000,rdata_pid3_eco,4'h0};
  assign rdata_pid4 = 32'h0000_0004;
  assign rdata_pid5 = 32'h0000_0000;
  assign rdata_pid6 = 32'h0000_0000;
  assign rdata_pid7 = 32'h0000_0000;
  assign rdata_cid0 = 32'h0000_000D;
  assign rdata_cid1 = 32'h0000_00F0;
  assign rdata_cid2 = 32'h0000_0005;
  assign rdata_cid3 = 32'h0000_00B1; 
  
  always @(posedge refclk or negedge aontop_warmresetn)
  begin
    if (~aontop_warmresetn)
      begin
        paddr_r <= {10{1'b0}};
      end
    else if (apb_rd_en)
      begin
        paddr_r <= nxt_paddr;
      end
  end 
  
  assign nxt_paddr = unaligned_rd ? 10'h300 : paddr[11:2];
  
  assign pready = 1'b1;
  

  assign unused = (|pprot);
  
endmodule
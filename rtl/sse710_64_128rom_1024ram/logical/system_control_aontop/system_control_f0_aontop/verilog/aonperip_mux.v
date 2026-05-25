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


module aonperip_mux 
(
  input wire                  refclk_int_gated,
  input wire                  resetn,

  input   wire              ppu_dbgen      ,
      
  input wire                  apb_async_req,
  input wire [67:0]           apb_async_req_payload,
  output wire [32:0]          apb_async_resp_payload,
  output wire                 apb_async_ack,

  input wire                 qreqn,
  output wire                qacceptn,
  output wire                qdeny,
  output wire                qactive,
  output wire                qactive_only,
  
  output wire                 penable,
  output wire [31:0]          paddr,
  output wire                 pwrite,
  output wire [31:0]          pwdata,
  output wire [3:0]           pstrb,
  output wire [2:0]           pprot,
  output wire                 pwakeup,
    

  
  output wire                   psel_system_id,   
  input wire                    pready_system_id, 
  input wire [31:0]             prdata_system_id, 
  input wire                    pslverr_system_id,
    
  output wire                   psel_host_chassis_control,   
  input wire                    pready_host_chassis_control, 
  input wire [31:0]             prdata_host_chassis_control, 
  input wire                    pslverr_host_chassis_control,
    
  output wire                   psel_firewall_ppu,   
  input wire                    pready_firewall_ppu, 
  input wire [31:0]             prdata_firewall_ppu, 
  input wire                    pslverr_firewall_ppu,
    
  output wire                   psel_systop_ppu,   
  input wire                    pready_systop_ppu, 
  input wire [31:0]             prdata_systop_ppu, 
  input wire                    pslverr_systop_ppu,
    
  output wire                   psel_dbgtop_ppu,   
  input wire                    pready_dbgtop_ppu, 
  input wire [31:0]             prdata_dbgtop_ppu, 
  input wire                    pslverr_dbgtop_ppu,
    
  output wire                   psel_refclk_cntcontrol,   
  input wire                    pready_refclk_cntcontrol, 
  input wire [31:0]             prdata_refclk_cntcontrol, 
  input wire                    pslverr_refclk_cntcontrol,
    
  output wire                   psel_refclk_cntread,   
  input wire                    pready_refclk_cntread, 
  input wire [31:0]             prdata_refclk_cntread, 
  input wire                    pslverr_refclk_cntread,
    
  output wire                   psel_refclk_cntctl,   
  input wire                    pready_refclk_cntctl, 
  input wire [31:0]             prdata_refclk_cntctl, 
  input wire                    pslverr_refclk_cntctl,
    
  output wire                   psel_refclk_cntbase0,   
  input wire                    pready_refclk_cntbase0, 
  input wire [31:0]             prdata_refclk_cntbase0, 
  input wire                    pslverr_refclk_cntbase0,
    
  output wire                   psel_refclk_cntbase1,   
  input wire                    pready_refclk_cntbase1, 
  input wire [31:0]             prdata_refclk_cntbase1, 
  input wire                    pslverr_refclk_cntbase1,
    
  output wire                   psel_refclk_cntbase2,   
  input wire                    pready_refclk_cntbase2, 
  input wire [31:0]             prdata_refclk_cntbase2, 
  input wire                    pslverr_refclk_cntbase2,
    
  output wire                   psel_refclk_cntbase3,   
  input wire                    pready_refclk_cntbase3, 
  input wire [31:0]             prdata_refclk_cntbase3, 
  input wire                    pslverr_refclk_cntbase3,
    
  output wire                   psel_ns_wdog,   
  input wire                    pready_ns_wdog, 
  input wire [31:0]             prdata_ns_wdog, 
  input wire                    pslverr_ns_wdog,
    
  output wire                   psel_secure_wdog,   
  input wire                    pready_secure_wdog, 
  input wire [31:0]             prdata_secure_wdog, 
  input wire                    pslverr_secure_wdog,
    
  output wire                   psel_s32k_cntcontrol,   
  input wire                    pready_s32k_cntcontrol, 
  input wire [31:0]             prdata_s32k_cntcontrol, 
  input wire                    pslverr_s32k_cntcontrol,
    
  output wire                   psel_s32k_cntread,   
  input wire                    pready_s32k_cntread, 
  input wire [31:0]             prdata_s32k_cntread, 
  input wire                    pslverr_s32k_cntread,
    
  output wire                   psel_s32k_cntctl,   
  input wire                    pready_s32k_cntctl, 
  input wire [31:0]             prdata_s32k_cntctl, 
  input wire                    pslverr_s32k_cntctl,
    
  output wire                   psel_s32k_cntbase0,   
  input wire                    pready_s32k_cntbase0, 
  input wire [31:0]             prdata_s32k_cntbase0, 
  input wire                    pslverr_s32k_cntbase0,
    
  output wire                   psel_s32k_cntbase1,   
  input wire                    pready_s32k_cntbase1, 
  input wire [31:0]             prdata_s32k_cntbase1, 
  input wire                    pslverr_s32k_cntbase1,
    
  output wire                   psel_interrupt_router,   
  input wire                    pready_interrupt_router, 
  input wire [31:0]             prdata_interrupt_router, 
  input wire                    pslverr_interrupt_router,
    
  output wire                   psel_aon_expansion_intf,   
  input wire                    pready_aon_expansion_intf, 
  input wire [31:0]             prdata_aon_expansion_intf, 
  input wire                    pslverr_aon_expansion_intf,
    
   
  input wire                  dftcgen
    
);
  
  localparam REFCLK_ARB_SLAVE_CNT = 21;
     
  wire [REFCLK_ARB_SLAVE_CNT-1:0]   sel_arb;  

  wire [REFCLK_ARB_SLAVE_CNT-1:0]   slv_sec;
  wire [31:0]            addr_arb;
  wire                  is_ppu_dbg_reg;   
  wire                  access_aligned;
  wire                 psel_adb;
  wire                 pready_adb;
  wire [31:0]          prdata_adb;
  wire                 pslverr_adb;
  wire                 penable_adb;
  wire [31:0]          paddr_adb;
  wire [31:0]          paddr_adb_t;
  wire                 pwrite_adb;
  wire [31:0]          pwdata_adb;
  wire [3:0]           pstrb_adb;
  wire [2:0]           pprot_adb;
 
  wire [REFCLK_ARB_SLAVE_CNT-1:0]    psel_arb;
  wire [REFCLK_ARB_SLAVE_CNT-1:0]    pready_arb;
  wire [32*REFCLK_ARB_SLAVE_CNT-1:0] prdata_arb;
  wire [REFCLK_ARB_SLAVE_CNT-1:0]    pslverr_arb;

  css600_apbasyncbridgemstr #(
    .APB_ADDR_WIDTH(32)
  ) u_adb_apb4_mst 
  (    
    .clk_m      (refclk_int_gated),
    .reset_m_n   (resetn),
    .dftcgen   (dftcgen),
    
    
    .psel_m     (psel_adb),
    .penable_m  (penable_adb),
    .paddr_m    (paddr_adb_t),
    .pwrite_m   (pwrite_adb),
    .pwdata_m   (pwdata_adb),
    .pprot_m    (pprot_adb),
    .prdata_m   (prdata_adb),
    .pready_m   (pready_adb),
    .pslverr_m  (pslverr_adb),
    
    .pwakeup_m  (pwakeup),
    
    .clk_m_qreq_n     (qreqn),
    .clk_m_qaccept_n  (qacceptn),
    .clk_m_qdeny    (qdeny),
    .clk_m_qactive   (qactive),
    
    .apb_async_req           (apb_async_req),
    .apb_async_req_payload   (apb_async_req_payload),
    .apb_async_resp_payload  (apb_async_resp_payload),
    .apb_async_ack           (apb_async_ack)
  );
  assign pstrb_adb = paddr_adb_t[31:28];
  assign paddr_adb = {4'b0001,paddr_adb_t[27:0]};
  
  apb4_arbiter 
  #(
    .SLAVE_CNT(REFCLK_ARB_SLAVE_CNT)
  )
  u_apb4_refclk_arbiter
  (
    .clk       (refclk_int_gated),
    .resetn    (resetn),
    
    .paddr_s   (paddr_adb),
    .psel_s    (psel_adb),
    .pprot_s   (pprot_adb),
    .penable_s (penable_adb),
    .pready_s  (pready_adb),
    .prdata_s  (prdata_adb),
    .pslverr_s (pslverr_adb),
    
    .psel_m     (psel_arb),
    .pready_m   (pready_arb),
    .prdata_m   (prdata_arb),
    .pslverr_m  (pslverr_arb),
    
    .addr_arb (addr_arb),
    .sel_arb  (sel_arb),
    
    .slv_sec (slv_sec),
    
    .qactive( qactive_only )
   );
 
 wire ppu_dbg_reg_violation;
 assign ppu_dbg_reg_violation = ppu_dbgen ? 1'b0 : pwrite && ( (addr_arb[11:0] == 12'h020) || (addr_arb[11:0] == 12'h024) ); 
 
  
 assign slv_sec[0] = 1'b0;  
 assign slv_sec[1] = 1'b0;  
 assign slv_sec[2] = 1'b1;  
 assign slv_sec[3] = 1'b1;  
 assign slv_sec[4] = 1'b1;  
 assign slv_sec[5] = 1'b1;  
 assign slv_sec[6] = 1'b0;  
 assign slv_sec[7] = 1'b0;  
 assign slv_sec[8] = 1'b0;  
 assign slv_sec[9] = 1'b0;  
 assign slv_sec[10] = 1'b0;  
 assign slv_sec[11] = 1'b0;  
 assign slv_sec[12] = 1'b0;  
 assign slv_sec[13] = 1'b1;  
 assign slv_sec[14] = 1'b1;  
 assign slv_sec[15] = 1'b0;  
 assign slv_sec[16] = 1'b0;  
 assign slv_sec[17] = 1'b0;  
 assign slv_sec[18] = 1'b0;  
 assign slv_sec[19] = 1'b0;  
 assign slv_sec[20] = 1'b0;  
 assign access_aligned = addr_arb[1:0] == 32'd0 && ( pwrite==1'b0 | (pstrb==4'b1111)); 
 
  assign sel_arb[0] = (access_aligned | 1'b0) && ( ((addr_arb >= 32'h1a000000) && (addr_arb < 32'h1a001000)) );
  assign sel_arb[1] = (access_aligned | 1'b0) && ( ((addr_arb >= 32'h1a010000) && (addr_arb < 32'h1a011000)) );
  assign sel_arb[2] = (access_aligned | 1'b1) && ( ((addr_arb >= 32'h1a020000) && (addr_arb < 32'h1a021000))  && (~ppu_dbg_reg_violation));
  assign sel_arb[3] = (access_aligned | 1'b1) && ( ((addr_arb >= 32'h1a030000) && (addr_arb < 32'h1a031000))  && (~ppu_dbg_reg_violation));
  assign sel_arb[4] = (access_aligned | 1'b1) && ( ((addr_arb >= 32'h1a040000) && (addr_arb < 32'h1a041000))  && (~ppu_dbg_reg_violation));
  assign sel_arb[5] = (access_aligned | 1'b1) && ( ((addr_arb >= 32'h1a200000) && (addr_arb < 32'h1a201000)) );
  assign sel_arb[6] = (access_aligned | 1'b1) && ( ((addr_arb >= 32'h1a210000) && (addr_arb < 32'h1a211000)) );
  assign sel_arb[7] = (access_aligned | 1'b1) && ( ((addr_arb >= 32'h1a220000) && (addr_arb < 32'h1a221000)) );
  assign sel_arb[8] = (access_aligned | 1'b1) && ( ((addr_arb >= 32'h1a230000) && (addr_arb < 32'h1a231000)) );
  assign sel_arb[9] = (access_aligned | 1'b1) && ( ((addr_arb >= 32'h1a240000) && (addr_arb < 32'h1a241000)) );
  assign sel_arb[10] = (access_aligned | 1'b1) && ( ((addr_arb >= 32'h1a250000) && (addr_arb < 32'h1a251000)) );
  assign sel_arb[11] = (access_aligned | 1'b1) && ( ((addr_arb >= 32'h1a260000) && (addr_arb < 32'h1a261000)) );
  assign sel_arb[12] = (access_aligned | 1'b1) && ( ((addr_arb >= 32'h1a300000) && (addr_arb < 32'h1a320000)) );
  assign sel_arb[13] = (access_aligned | 1'b1) && ( ((addr_arb >= 32'h1a320000) && (addr_arb < 32'h1a340000)) );
  assign sel_arb[14] = (access_aligned | 1'b1) && ( ((addr_arb >= 32'h1a400000) && (addr_arb < 32'h1a401000)) );
  assign sel_arb[15] = (access_aligned | 1'b1) && ( ((addr_arb >= 32'h1a410000) && (addr_arb < 32'h1a411000)) );
  assign sel_arb[16] = (access_aligned | 1'b1) && ( ((addr_arb >= 32'h1a420000) && (addr_arb < 32'h1a421000)) );
  assign sel_arb[17] = (access_aligned | 1'b1) && ( ((addr_arb >= 32'h1a430000) && (addr_arb < 32'h1a431000)) );
  assign sel_arb[18] = (access_aligned | 1'b1) && ( ((addr_arb >= 32'h1a440000) && (addr_arb < 32'h1a441000)) );
  assign sel_arb[19] = (access_aligned | 1'b0) && ( ((addr_arb >= 32'h1a500000) && (addr_arb < 32'h1a501000)) );
  assign sel_arb[20] = (access_aligned | 1'b1) && ( ((addr_arb >= 32'h1a600000) && (addr_arb < 32'h1a700000)) );
  
 
  assign psel_system_id = psel_arb[0];
  assign pready_arb[0]          = pready_system_id;
  assign prdata_arb[0*32 +: 32] = prdata_system_id;
  assign pslverr_arb[0]         = pslverr_system_id;      

  assign psel_host_chassis_control = psel_arb[1];
  assign pready_arb[1]          = pready_host_chassis_control;
  assign prdata_arb[1*32 +: 32] = prdata_host_chassis_control;
  assign pslverr_arb[1]         = pslverr_host_chassis_control;      

  assign psel_firewall_ppu = psel_arb[2];
  assign pready_arb[2]          = pready_firewall_ppu;
  assign prdata_arb[2*32 +: 32] = prdata_firewall_ppu;
  assign pslverr_arb[2]         = pslverr_firewall_ppu;      

  assign psel_systop_ppu = psel_arb[3];
  assign pready_arb[3]          = pready_systop_ppu;
  assign prdata_arb[3*32 +: 32] = prdata_systop_ppu;
  assign pslverr_arb[3]         = pslverr_systop_ppu;      

  assign psel_dbgtop_ppu = psel_arb[4];
  assign pready_arb[4]          = pready_dbgtop_ppu;
  assign prdata_arb[4*32 +: 32] = prdata_dbgtop_ppu;
  assign pslverr_arb[4]         = pslverr_dbgtop_ppu;      

  assign psel_refclk_cntcontrol = psel_arb[5];
  assign pready_arb[5]          = pready_refclk_cntcontrol;
  assign prdata_arb[5*32 +: 32] = prdata_refclk_cntcontrol;
  assign pslverr_arb[5]         = pslverr_refclk_cntcontrol;      

  assign psel_refclk_cntread = psel_arb[6];
  assign pready_arb[6]          = pready_refclk_cntread;
  assign prdata_arb[6*32 +: 32] = prdata_refclk_cntread;
  assign pslverr_arb[6]         = pslverr_refclk_cntread;      

  assign psel_refclk_cntctl = psel_arb[7];
  assign pready_arb[7]          = pready_refclk_cntctl;
  assign prdata_arb[7*32 +: 32] = prdata_refclk_cntctl;
  assign pslverr_arb[7]         = pslverr_refclk_cntctl;      

  assign psel_refclk_cntbase0 = psel_arb[8];
  assign pready_arb[8]          = pready_refclk_cntbase0;
  assign prdata_arb[8*32 +: 32] = prdata_refclk_cntbase0;
  assign pslverr_arb[8]         = pslverr_refclk_cntbase0;      

  assign psel_refclk_cntbase1 = psel_arb[9];
  assign pready_arb[9]          = pready_refclk_cntbase1;
  assign prdata_arb[9*32 +: 32] = prdata_refclk_cntbase1;
  assign pslverr_arb[9]         = pslverr_refclk_cntbase1;      

  assign psel_refclk_cntbase2 = psel_arb[10];
  assign pready_arb[10]          = pready_refclk_cntbase2;
  assign prdata_arb[10*32 +: 32] = prdata_refclk_cntbase2;
  assign pslverr_arb[10]         = pslverr_refclk_cntbase2;      

  assign psel_refclk_cntbase3 = psel_arb[11];
  assign pready_arb[11]          = pready_refclk_cntbase3;
  assign prdata_arb[11*32 +: 32] = prdata_refclk_cntbase3;
  assign pslverr_arb[11]         = pslverr_refclk_cntbase3;      

  assign psel_ns_wdog = psel_arb[12];
  assign pready_arb[12]          = pready_ns_wdog;
  assign prdata_arb[12*32 +: 32] = prdata_ns_wdog;
  assign pslverr_arb[12]         = pslverr_ns_wdog;      

  assign psel_secure_wdog = psel_arb[13];
  assign pready_arb[13]          = pready_secure_wdog;
  assign prdata_arb[13*32 +: 32] = prdata_secure_wdog;
  assign pslverr_arb[13]         = pslverr_secure_wdog;      

  assign psel_s32k_cntcontrol = psel_arb[14];
  assign pready_arb[14]          = pready_s32k_cntcontrol;
  assign prdata_arb[14*32 +: 32] = prdata_s32k_cntcontrol;
  assign pslverr_arb[14]         = pslverr_s32k_cntcontrol;      

  assign psel_s32k_cntread = psel_arb[15];
  assign pready_arb[15]          = pready_s32k_cntread;
  assign prdata_arb[15*32 +: 32] = prdata_s32k_cntread;
  assign pslverr_arb[15]         = pslverr_s32k_cntread;      

  assign psel_s32k_cntctl = psel_arb[16];
  assign pready_arb[16]          = pready_s32k_cntctl;
  assign prdata_arb[16*32 +: 32] = prdata_s32k_cntctl;
  assign pslverr_arb[16]         = pslverr_s32k_cntctl;      

  assign psel_s32k_cntbase0 = psel_arb[17];
  assign pready_arb[17]          = pready_s32k_cntbase0;
  assign prdata_arb[17*32 +: 32] = prdata_s32k_cntbase0;
  assign pslverr_arb[17]         = pslverr_s32k_cntbase0;      

  assign psel_s32k_cntbase1 = psel_arb[18];
  assign pready_arb[18]          = pready_s32k_cntbase1;
  assign prdata_arb[18*32 +: 32] = prdata_s32k_cntbase1;
  assign pslverr_arb[18]         = pslverr_s32k_cntbase1;      

  assign psel_interrupt_router = psel_arb[19];
  assign pready_arb[19]          = pready_interrupt_router;
  assign prdata_arb[19*32 +: 32] = prdata_interrupt_router;
  assign pslverr_arb[19]         = pslverr_interrupt_router;      

  assign psel_aon_expansion_intf = psel_arb[20];
  assign pready_arb[20]          = pready_aon_expansion_intf;
  assign prdata_arb[20*32 +: 32] = prdata_aon_expansion_intf;
  assign pslverr_arb[20]         = pslverr_aon_expansion_intf;      
  assign pwrite = pwrite_adb;
  assign penable = penable_adb;
  assign pwdata = pwdata_adb;
  assign pstrb = pstrb_adb;
  assign pprot = pprot_adb;
  assign paddr = paddr_adb;
   
endmodule


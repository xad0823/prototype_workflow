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
 

`ifndef INT_RTR_PARAMS
`include "interrupt_router_f0_params.v"
`endif

module system_control_f0_aontop
#(
    
    parameter DEV_PREQ_DLY_DBG         = 0,
    parameter PCSM_PREQ_DLY_DBG        = 0,
    parameter ISO_CLKEN_DLY_CFG_DBG    = 0,
    parameter CLKEN_RST_DLY_CFG_DBG    = 0,
    parameter RST_HWSTAT_DLY_CFG_DBG   = 0,
    parameter CLKEN_ISO_DLY_CFG_DBG    = 0,
    parameter ISO_RST_DLY_CFG_DBG      = 0,
    
    parameter DEV_PREQ_DLY_SYS         = 0,
    parameter PCSM_PREQ_DLY_SYS        = 0,
    parameter ISO_CLKEN_DLY_CFG_SYS    = 0,
    parameter CLKEN_RST_DLY_CFG_SYS    = 0,
    parameter RST_HWSTAT_DLY_CFG_SYS   = 0,
    parameter CLKEN_ISO_DLY_CFG_SYS    = 0,
    parameter ISO_RST_DLY_CFG_SYS      = 0,
    
    parameter DEV_PREQ_DLY_FWRAM       = 0,
    parameter PCSM_PREQ_DLY_FWRAM      = 0,
    parameter ISO_CLKEN_DLY_CFG_FWRAM  = 0,
    parameter CLKEN_RST_DLY_CFG_FWRAM  = 0,
    parameter RST_HWSTAT_DLY_CFG_FWRAM = 0,
    parameter CLKEN_ISO_DLY_CFG_FWRAM  = 0,
    parameter ISO_RST_DLY_CFG_FWRAM    = 0,

    parameter ES_CNT                   = 2,
    parameter SYS_EGRESS_2_DBG         = 2,
    parameter SYS_INGRESS_2_DBG        = 2,
    parameter IIDR_PRODUCT_ID          = 12'd762,
    parameter IIDR_VARIANT_ID          = 4'd0,
    parameter IIDR_REVISION            = 4'd0,
    parameter IIDR_IMPLEMENTER         = 12'h43b,
    
    parameter FCTRLPROG_AW_FIFO_DEPTH  =  2,
    parameter FCTRLPROG_AR_FIFO_DEPTH  =  2,
    parameter FCTRLPROG_W_FIFO_DEPTH   =  2,
    parameter FCTRLPROG_B_FIFO_DEPTH   =  2,
    parameter FCTRLPROG_R_FIFO_DEPTH   =  2,
    parameter FCTRLPROG_AWUSER_WIDTH   = 10,
    parameter FCTRLPROG_ARUSER_WIDTH   = 10,
    parameter FCTRLPROG_WUSER_WIDTH    =  0,
    parameter FCTRLPROG_BUSER_WIDTH    =  0,
    parameter FCTRLPROG_RUSER_WIDTH    =  0,
    parameter FCTRLPROG_AWID_WIDTH     =  8,
    parameter FCTRLPROG_ARID_WIDTH     =  8,
    parameter FCTRLPROG_ADDR_WIDTH     = 32,
    parameter FCTRLPROG_DATA_WIDTH     = 32,

    parameter FCTRL_NUM_FC_CLOG2       = 4,
    parameter FCTRLCFG_UP_LAST_WIDTH   = 1,
    parameter FCTRLCFG_UP_DATA_WIDTH   = 32,
    parameter FCTRLCFG_UP_STRB_WIDTH   = 0,
    parameter FCTRLCFG_UP_KEEP_WIDTH   = FCTRLCFG_UP_DATA_WIDTH / 8,
    parameter FCTRLCFG_UP_ID_WIDTH     = FCTRL_NUM_FC_CLOG2,
    parameter FCTRLCFG_UP_DEST_WIDTH   = FCTRL_NUM_FC_CLOG2,
    parameter FCTRLCFG_UP_USER_WIDTH   = 0,
    parameter FCTRLCFG_UP_FIFO_DEPTH_SYSTOP = 2,
    parameter FCTRLCFG_UP_FIFO_DEPTH_DBGTOP = 2,

    parameter FCTRLCFG_DN_LAST_WIDTH   = 1,
    parameter FCTRLCFG_DN_DATA_WIDTH   = 32,
    parameter FCTRLCFG_DN_STRB_WIDTH   = 0,
    parameter FCTRLCFG_DN_KEEP_WIDTH   = FCTRLCFG_DN_DATA_WIDTH / 8,
    parameter FCTRLCFG_DN_ID_WIDTH     = FCTRL_NUM_FC_CLOG2,
    parameter FCTRLCFG_DN_DEST_WIDTH   = FCTRL_NUM_FC_CLOG2,
    parameter FCTRLCFG_DN_USER_WIDTH   = 0,
    parameter FCTRLCFG_DN_FIFO_DEPTH_SYSTOP = 2,
    parameter FCTRLCFG_DN_FIFO_DEPTH_DBGTOP = 2,
    

    parameter FCTRLPROG_AWPAYLD_LEN = (FCTRLPROG_AWUSER_WIDTH +
                                       FCTRLPROG_AWID_WIDTH   +
                                       FCTRLPROG_ADDR_WIDTH + 29)*
                                       FCTRLPROG_AW_FIFO_DEPTH,

    parameter FCTRLPROG_ARPAYLD_LEN = (FCTRLPROG_ARUSER_WIDTH +
                                       FCTRLPROG_ARID_WIDTH   +
                                       FCTRLPROG_ADDR_WIDTH + 29)*
                                       FCTRLPROG_AR_FIFO_DEPTH,

    parameter FCTRLPROG_WPAYLD_LEN  = (FCTRLPROG_WUSER_WIDTH +
                                       FCTRLPROG_DATA_WIDTH  +
                                       FCTRLPROG_DATA_WIDTH/8+1)*
                                       FCTRLPROG_W_FIFO_DEPTH,

    parameter FCTRLPROG_BPAYLD_LEN  = (FCTRLPROG_BUSER_WIDTH +
                                       FCTRLPROG_AWID_WIDTH  +2) *
                                       FCTRLPROG_B_FIFO_DEPTH,


    parameter FCTRLPROG_RPAYLD_LEN  = (FCTRLPROG_RUSER_WIDTH +
                                       FCTRLPROG_ARID_WIDTH +
                                       FCTRLPROG_DATA_WIDTH +
                                       3) * FCTRLPROG_R_FIFO_DEPTH,

    parameter FCTRLCFG_DN_PAYLD_LEN_SYSTOP = (FCTRLCFG_DN_LAST_WIDTH +
                                       FCTRLCFG_DN_DATA_WIDTH +
                                       FCTRLCFG_DN_STRB_WIDTH +
                                       FCTRLCFG_DN_KEEP_WIDTH +
                                       FCTRLCFG_DN_ID_WIDTH   +
                                       FCTRLCFG_DN_DEST_WIDTH +
                                       FCTRLCFG_DN_USER_WIDTH) *
                                       FCTRLCFG_DN_FIFO_DEPTH_SYSTOP,

    parameter FCTRLCFG_DN_PAYLD_LEN_DBGTOP = (FCTRLCFG_DN_LAST_WIDTH +
                                       FCTRLCFG_DN_DATA_WIDTH +
                                       FCTRLCFG_DN_STRB_WIDTH +
                                       FCTRLCFG_DN_KEEP_WIDTH +
                                       FCTRLCFG_DN_ID_WIDTH   +
                                       FCTRLCFG_DN_DEST_WIDTH +
                                       FCTRLCFG_DN_USER_WIDTH) *
                                       FCTRLCFG_DN_FIFO_DEPTH_DBGTOP,

    parameter FCTRLCFG_UP_PAYLD_LEN_SYSTOP = (FCTRLCFG_UP_LAST_WIDTH +
                                       FCTRLCFG_UP_DATA_WIDTH +
                                       FCTRLCFG_UP_STRB_WIDTH +
                                       FCTRLCFG_UP_KEEP_WIDTH +
                                       FCTRLCFG_UP_ID_WIDTH   +
                                       FCTRLCFG_UP_DEST_WIDTH +
                                       FCTRLCFG_UP_USER_WIDTH) *
                                       FCTRLCFG_UP_FIFO_DEPTH_SYSTOP,

   parameter FCTRLCFG_UP_PAYLD_LEN_DBGTOP = (FCTRLCFG_UP_LAST_WIDTH +
                                       FCTRLCFG_UP_DATA_WIDTH +
                                       FCTRLCFG_UP_STRB_WIDTH +
                                       FCTRLCFG_UP_KEEP_WIDTH +
                                       FCTRLCFG_UP_ID_WIDTH   +
                                       FCTRLCFG_UP_DEST_WIDTH +
                                       FCTRLCFG_UP_USER_WIDTH) *
                                       FCTRLCFG_UP_FIFO_DEPTH_DBGTOP,
                                       
    `SI_DEF_ICI_DST_FROM_32
    `SI_DEF_ICI_EN_FROM_32
    parameter NUM_SHD_INT            = 96,
    parameter NUM_ICI                = 2+2,
    parameter HOST_CPU_NUM_CORES     = 4,
    parameter DBG_INTERNAL_CNT       = 3,
    parameter DBG_EGRESS_CNT         = 1,
    parameter QACTIVE_REFCLK_TOP_CNT = 2*2+7    

)
 (    
    input  wire                                poresetn,
    input  wire                                aontop_warmresetn,                           
    input  wire                                aontop_poresetn,                                                                        
    input  wire                                uartclk,                                     
    input  wire                                refclk_free,                                 
    input  wire                                s32kclk,                                     
    input  wire                                syspll,                                      
    input  wire                                cpupll,                                      
    input  wire                                traceclk_in,                                 
                                                                   
                                                                                            
    output wire                                refclk_int_gated_out,
    output wire                                refclk_sleep_gated_out,    
    
    output wire                                refclk_systop,                               
    output wire                                refclk_dbgtop,                               
    output wire                                syspll_systop,                               
    output wire                                syspll_dbgtop,                               
    output wire                                cpupll_systop,                               
    output wire                                traceclk_in_dbgtop,

    output wire                                refclk_warmresetn,
    output wire                                refclk_aontopporesetn,
    
                                                         
    output wire                                hostcntclkout,                               
    output wire                                hostcntclkout_systop,                        
    input  wire [QACTIVE_REFCLK_TOP_CNT-1:0]   qactive_refclk_int_gated_top,                          
    input  wire                                qactive_refclk_systop,                       
    output wire                                systop_warmresetn,                           
    output wire                                dbgtop_warmresetn,                           
                                                                                            
     
    input wire                                 ppu_dbgen,
    
    input  wire                                refclk_poresetn_qreqn,                           
    output wire                                refclk_poresetn_qacceptn,                        
    output wire                                refclk_poresetn_qdeny,                           
    output wire                                refclk_poresetn_qactive,                         
                                                                                            
                                                                                            
    input wire [7:0]                           ocvmsize,                                    
    input wire [7:0]                           cnvmsize,                                    
    input wire [7:0]                           cvmsize ,                                    
    input wire [11:0]                          soc_id_product_id,                           
    input wire [3:0]                           soc_id_variant_id,                           
    input wire [3:0]                           soc_id_revision,                             
    input wire [10:0]                          soc_id_implementer,                          
                                                                                            
                                                                                            
    output wire                                psel_aon_expansion,                          
    output wire  [31:0]                        paddr_aon_expansion,                         
    input wire                                 pready_aon_expansion,                        
    input wire [31:0]                          prdata_aon_expansion,                        
    input wire                                 pslverr_aon_expansion,                       
    output wire                                pwrite_aon_expansion,                        
    output wire                                penable_aon_expansion,                       
    output wire [31:0]                         pwdata_aon_expansion,                        
    output wire [3:0]                          pstrb_aon_expansion,                         
    output wire [2:0]                          pprot_aon_expansion,                         
    output wire                                pwakeup_aon_expansion,                       
    output wire                                pclk_aon_expansion,                          
    
    input  wire                                periph_async_req,                            
    input  wire [67:0]                         periph_async_req_payload,                    
    output wire [32:0]                         periph_async_resp_payload,                   
    output wire                                periph_async_ack,                            
                                                                                            
    input  wire                                bootreg_async_req,                           
    input  wire [61:0]                         bootreg_async_req_payload,                   
    output wire [32:0]                         bootreg_async_resp_payload,                  
    output wire                                bootreg_async_ack,                           
        
    input  wire                                uart_async_req,
    input  wire [52:0]                         uart_async_req_payload,
    output wire [32:0]                         uart_async_resp_payload,
    output wire                                uart_async_ack,
            
                                                                                            
    input  wire                                fctrlprog_slvmustacceptreqn_async,           
    input  wire                                fctrlprog_slvcandenyreqn_async,              
    output wire                                fctrlprog_slvacceptn_async,                  
    output wire                                fctrlprog_slvdeny_async,                     
    input  wire                                fctrlprog_si_to_mi_wakeup_async,             
    output wire                                fctrlprog_mi_to_si_wakeup_async,             
    input  wire [FCTRLPROG_AW_FIFO_DEPTH-1:0]  fctrlprog_aw_wr_ptr_async,                   
    output wire [FCTRLPROG_AW_FIFO_DEPTH-1:0]  fctrlprog_aw_rd_ptr_async,                   
    input  wire [FCTRLPROG_AWPAYLD_LEN-1:0]    fctrlprog_aw_payld_async,                    
    input  wire [FCTRLPROG_W_FIFO_DEPTH-1:0]   fctrlprog_w_wr_ptr_async,                    
    output wire [FCTRLPROG_W_FIFO_DEPTH-1:0]   fctrlprog_w_rd_ptr_async,                    
    input  wire [FCTRLPROG_WPAYLD_LEN-1:0]     fctrlprog_w_payld_async,                     
    output wire [FCTRLPROG_B_FIFO_DEPTH-1:0]   fctrlprog_b_wr_ptr_async,                    
    input  wire [FCTRLPROG_B_FIFO_DEPTH-1:0]   fctrlprog_b_rd_ptr_async,                    
    output wire [FCTRLPROG_BPAYLD_LEN-1:0]     fctrlprog_b_payld_async,                     
    input  wire [FCTRLPROG_AR_FIFO_DEPTH-1:0]  fctrlprog_ar_wr_ptr_async,                   
    output wire [FCTRLPROG_AR_FIFO_DEPTH-1:0]  fctrlprog_ar_rd_ptr_async,                   
    input  wire [FCTRLPROG_ARPAYLD_LEN-1:0]    fctrlprog_ar_payld_async,                    
    output wire [FCTRLPROG_R_FIFO_DEPTH-1:0]   fctrlprog_r_wr_ptr_async,                    
    input  wire [FCTRLPROG_R_FIFO_DEPTH-1:0]   fctrlprog_r_rd_ptr_async,                    
    output wire [FCTRLPROG_RPAYLD_LEN-1:0]     fctrlprog_r_payld_async,                     

    
    input  wire                                fctrlcfg_systop_dn_slvmustacceptreqn_async,  
    input  wire                                fctrlcfg_systop_dn_slvcandenyreqn_async,     
    output  wire                               fctrlcfg_systop_dn_slvacceptn_async,         
    output  wire                               fctrlcfg_systop_dn_slvdeny_async,            

    input wire                                 fctrlcfg_systop_dn_si_to_mi_wakeup_async,
    output  wire                               fctrlcfg_systop_dn_mi_to_si_wakeup_async,

    input wire [FCTRLCFG_DN_FIFO_DEPTH_SYSTOP-1:0]    fctrlcfg_systop_dn_wr_ptr_async,             
    output  wire [FCTRLCFG_DN_FIFO_DEPTH_SYSTOP-1:0]  fctrlcfg_systop_dn_rd_ptr_async,             
    input wire [FCTRLCFG_DN_PAYLD_LEN_SYSTOP-1:0]     fctrlcfg_systop_dn_payld_async,              
    
    output  wire                               fctrlcfg_systop_up_slvmustacceptreqn_async,  
    output  wire                               fctrlcfg_systop_up_slvcandenyreqn_async,     
    input wire                                 fctrlcfg_systop_up_slvacceptn_async,         
    input wire                                 fctrlcfg_systop_up_slvdeny_async,            

    output  wire                               fctrlcfg_systop_up_si_to_mi_wakeup_async,    
    input wire                                 fctrlcfg_systop_up_mi_to_si_wakeup_async,    

    output  wire [FCTRLCFG_UP_FIFO_DEPTH_SYSTOP-1:0]  fctrlcfg_systop_up_wr_ptr_async,             
    input   wire [FCTRLCFG_UP_FIFO_DEPTH_SYSTOP-1:0]  fctrlcfg_systop_up_rd_ptr_async,             
    output  wire [FCTRLCFG_UP_PAYLD_LEN_SYSTOP-1:0]   fctrlcfg_systop_up_payld_async,              
   
    
    input  wire                                fctrlcfg_dbgtop_dn_slvmustacceptreqn_async,  
    input  wire                                fctrlcfg_dbgtop_dn_slvcandenyreqn_async,     
    output wire                                fctrlcfg_dbgtop_dn_slvacceptn_async,         
    output wire                                fctrlcfg_dbgtop_dn_slvdeny_async,            
                                              
    input  wire                                fctrlcfg_dbgtop_dn_si_to_mi_wakeup_async,    
    output wire                                fctrlcfg_dbgtop_dn_mi_to_si_wakeup_async,    

    input  wire [FCTRLCFG_DN_FIFO_DEPTH_DBGTOP-1:0]   fctrlcfg_dbgtop_dn_wr_ptr_async,              
    output wire [FCTRLCFG_DN_FIFO_DEPTH_DBGTOP-1:0]   fctrlcfg_dbgtop_dn_rd_ptr_async,              
    input  wire [FCTRLCFG_DN_PAYLD_LEN_DBGTOP-1:0]    fctrlcfg_dbgtop_dn_payld_async,               
                                               
    output  wire                               fctrlcfg_dbgtop_up_slvmustacceptreqn_async,   
    output  wire                               fctrlcfg_dbgtop_up_slvcandenyreqn_async,      
    input wire                                 fctrlcfg_dbgtop_up_slvacceptn_async,          
    input wire                                 fctrlcfg_dbgtop_up_slvdeny_async,             
                                               
    output  wire                               fctrlcfg_dbgtop_up_si_to_mi_wakeup_async,     
    input wire                                 fctrlcfg_dbgtop_up_mi_to_si_wakeup_async,     
                                               
    output  wire [FCTRLCFG_UP_FIFO_DEPTH_DBGTOP-1:0]  fctrlcfg_dbgtop_up_wr_ptr_async,              
    input wire [FCTRLCFG_UP_FIFO_DEPTH_DBGTOP-1:0]    fctrlcfg_dbgtop_up_rd_ptr_async,              
    output  wire [FCTRLCFG_UP_PAYLD_LEN_DBGTOP-1:0]   fctrlcfg_dbgtop_up_payld_async,               
                                               
                                               
                                               
    output wire                                uart0_out2n,                                  
    output wire                                uart0_out1n,                                  
    output wire                                uart0_rtsn,                                   
    output wire                                uart0_dtrn,                                   
    output wire                                uart0_txd,                                    
    input  wire                                uart0_ctsn,                                   
    input  wire                                uart0_dcdn,                                   
    input  wire                                uart0_dsrn,                                   
    input  wire                                uart0_ri,                                     
    input  wire                                uart0_rxd,                                    
                                               
    output wire                                uart1_out2n,                                  
    output wire                                uart1_out1n,                                  
    output wire                                uart1_rtsn,                                   
    output wire                                uart1_dtrn,                                   
    output wire                                uart1_txd,                                    
    input  wire                                uart1_ctsn,                                   
    input  wire                                uart1_dcdn,                                   
    input  wire                                uart1_dsrn,                                   
    input  wire                                uart1_ri,                                     
    input  wire                                uart1_rxd,                                    
                                                                                                                                           
    output wire                                qreqn_secenc_systopq,                         
    input  wire                                qacceptn_secenc_systopq,                      
    input  wire                                qdeny_secenc_systopq,                         
    input  wire                                qactive_secenc_systopq,                       
                                                                                              
    output wire                                qreqn_secenc_dbgtopq,                         
    input  wire                                qacceptn_secenc_dbgtopq,                      
    input  wire                                qdeny_secenc_dbgtopq,                         
    input  wire                                qactive_secenc_dbgtopq,                       
                                               
    output wire [ES_CNT-1:0]                   qreqn_extsys_systopq,                         
    input  wire [ES_CNT-1:0]                   qacceptn_extsys_systopq,                      
    input  wire [ES_CNT-1:0]                   qdeny_extsys_systopq,                         
    input  wire [ES_CNT-1:0]                   qactive_extsys_systopq,                       
                                               
    output wire [ES_CNT-1:0]                   qreqn_extsys_dbgtopq,                         
    input  wire [ES_CNT-1:0]                   qacceptn_extsys_dbgtopq,                      
    input  wire [ES_CNT-1:0]                   qdeny_extsys_dbgtopq,                         
    input  wire [ES_CNT-1:0]                   qactive_extsys_dbgtopq,                       
                                               
    output wire                                qreqn_dbgtop_ingress_aon,                     
    input  wire                                qacceptn_dbgtop_ingress_aon,                  
    input  wire                                qdeny_dbgtop_ingress_aon,                     
    input  wire                                qactive_dbgtop_ingress_aon,                   
                                                                                                                                              
    output wire [SYS_EGRESS_2_DBG-1:0]         qreqn_systop_egress_dbgtop,                   
    input  wire [SYS_EGRESS_2_DBG-1:0]         qacceptn_systop_egress_dbgtop,                
    input  wire [SYS_EGRESS_2_DBG-1:0]         qdeny_systop_egress_dbgtop,                   
    input  wire [SYS_EGRESS_2_DBG-1:0]         qactive_systop_egress_dbgtop,                 
                                               
    output wire [SYS_INGRESS_2_DBG-1:0]        qreqn_systop_ingress_dbgtop,                  
    input  wire [SYS_INGRESS_2_DBG-1:0]        qacceptn_systop_ingress_dbgtop,               
    input  wire [SYS_INGRESS_2_DBG-1:0]        qdeny_systop_ingress_dbgtop,                  
    input  wire [SYS_INGRESS_2_DBG-1:0]        qactive_systop_ingress_dbgtop,                
                                               
                                               
    output wire [2:0]                          qreqn_systop,                                 
    input  wire [2:0]                          qacceptn_systop,                              
    input  wire [2:0]                          qdeny_systop,                                 
    input  wire [2:0]                          qactive_systop,                               
                                             
  
    output wire [2:0]                          qreqn_systop_exp,                                 
    input  wire [2:0]                          qacceptn_systop_exp,                              
    input  wire [2:0]                          qdeny_systop_exp,                                 
    input  wire [2:0]                          qactive_systop_exp,                               
                                                                                          
    output wire                                qreqn_systop_acg,                             
    input  wire                                qacceptn_systop_acg,                          
    input  wire                                qdeny_systop_acg,                             
    input  wire                                qactive_systop_acg,                           
                                               
    output wire [2:0]                          qreqn_dbgtop_exp,                             
    input  wire [2:0]                          qacceptn_dbgtop_exp,                          
    input  wire [2:0]                          qdeny_dbgtop_exp,                             
    input  wire [2:0]                          qactive_dbgtop_exp,                           

    output wire                                qreqn_clustop_egress_dbgtop,
    input  wire                                qacceptn_clustop_egress_dbgtop,
    input  wire                                qdeny_clustop_egress_dbgtop,  
    input  wire                                qactive_clustop_egress_dbgtop,
    
    output wire                                qreqn_clustop_ingress_dbgtop,
    input  wire                                qacceptn_clustop_ingress_dbgtop,
    input  wire                                qdeny_clustop_ingress_dbgtop,  
    input  wire                                qactive_clustop_ingress_dbgtop,
    
    output wire                                clustop_dependency_qreqn,
    input  wire                                clustop_dependency_qacceptn,
    input  wire                                clustop_dependency_qdeny,     
    input  wire                                clustop_dependency_qactive,     
  
    output wire [DBG_INTERNAL_CNT-1:0]         qreqn_dbgtop_internal,                        
    input  wire [DBG_INTERNAL_CNT-1:0]         qacceptn_dbgtop_internal,                     
    input  wire [DBG_INTERNAL_CNT-1:0]         qdeny_dbgtop_internal,                        
    input  wire [DBG_INTERNAL_CNT-1:0]         qactive_dbgtop_internal,                      
    
    output wire [DBG_EGRESS_CNT-1:0]           qreqn_dbgtop_egress,                        
    input  wire [DBG_EGRESS_CNT-1:0]           qacceptn_dbgtop_egress,                     
    input  wire [DBG_EGRESS_CNT-1:0]           qdeny_dbgtop_egress,                        
    input  wire [DBG_EGRESS_CNT-1:0]           qactive_dbgtop_egress,                      
    
    output wire                                qreqn_aondbg_sleep_gated,                             
    input  wire                                qacceptn_aondbg_sleep_gated,                          
    input  wire                                qdeny_aondbg_sleep_gated,                             
    input  wire                                qactive_aondbg_sleep_gated,                           
    
    
    input  wire [NUM_SHD_INT-32-1:0]           exp_shd_int,                                  
    output wire [4:0]                          hostcpu_gicintdbgtop,                         
    output wire [1:0]                          hostcpu_gicintuart,                           
    output wire [NUM_SHD_INT-1:0]              hostcpu_gicshdint,                            
    output wire [1:0]                          hostcpu_gicintwdogs,                          
    output wire                                hostcpu_gicintwdogns,                         
    output wire                                interrupt_router_tamper_interrupt,            

                                               
    output wire [NUM_SHD_INT-1:0]              extsys0_shared_interrupts,                    
                                               
    output wire [NUM_SHD_INT-1:0]              extsys1_shared_interrupts,                    
    output wire [63:0]                         secenc_shared_interrupts,                     
                                               
    output wire [63:0]                         tsvalueg_out,                                 
    input  wire [63:0]                         tsvalueb_in,                                  
                                               
    output wire [63:0]                         tsvalueg_s32k_out,                            
    input wire [63:0]                          tsvalueb_s32k_in,                             
                                               
    input wire                                 refclk_counter_haltreqreq,                       
    output wire                                refclk_counter_haltreqack,                       
    input wire                                 refclk_counter_restartreq,                    
    output wire                                refclk_counter_restartack,                   
                                                                                             
    input wire                                 s32k_counter_haltreqreq,                         
    output wire                                s32k_counter_haltreqack,                         
    input wire                                 s32k_counter_restartreq,                      
    output wire                                s32k_counter_restartack,                     
                                                                                               
    output wire                                cluster_config_cryptodisable,                 
    output wire                                pe0_config_vinithi,                           
    output wire                                pe0_config_cfgte,                             
    output wire                                pe0_config_cfgend,                            
    output wire                                pe1_config_vinithi,                           
    output wire                                pe1_config_cfgte,                             
    output wire                                pe1_config_cfgend,                            
    output wire                                pe2_config_vinithi,                           
    output wire                                pe2_config_cfgte,                             
    output wire                                pe2_config_cfgend,                            
    output wire                                pe3_config_vinithi,                           
    output wire                                pe3_config_cfgte,                             
    output wire                                pe3_config_cfgend,                            

    output wire                                pe0_config_aa64naa32,
    output wire [29:0]                         pe0_rvbaraddr_lw_rvbar31_2,
    output wire [11:0]                         pe0_rvbaraddr_up_rvbar43_32,
  
    output wire                                pe1_config_aa64naa32,
    output wire [29:0]                         pe1_rvbaraddr_lw_rvbar31_2,
    output wire [11:0]                         pe1_rvbaraddr_up_rvbar43_32,
  
    output wire                                pe2_config_aa64naa32,
    output wire [29:0]                         pe2_rvbaraddr_lw_rvbar31_2,
    output wire [11:0]                         pe2_rvbaraddr_up_rvbar43_32,
  
    output wire                                pe3_config_aa64naa32,
    output wire [29:0]                         pe3_rvbaraddr_lw_rvbar31_2,
    output wire [11:0]                         pe3_rvbaraddr_up_rvbar43_32,

    output wire [3:0]                          host_cpu_boot_msk_boot_msk,                   
    output wire                                host_cpu_clus_pwr_req_pwr_req,                
    output wire                                bsys_pwr_req_wakeup_en_o,                     
  
    output wire                                clkforce_st_refclk_force_st,
    output wire [7:0]                          refclk_ctrl_entrydelay,
      
    output wire [7:0]                          gicclk_ctrl_entrydelay,                       
    output wire [7:0]                          aclk_ctrl_entrydelay,                         
    output wire [7:0]                          ctrlclk_ctrl_entrydelay,                      
    output wire [7:0]                          dbgclk_ctrl_entrydelay,                       
              
    input wire [7:0]                           hostcpuclk_ctrl_clkselect_cur,               
    output wire [7:0]                          hostcpuclk_ctrl_clkselect,                   
    input wire [4:0]                           hostcpuclk_div0_clkdiv_cur,                  
                                  
    output wire [4:0]                          hostcpuclk_div0_clkdiv,                      
    input wire [4:0]                           hostcpuclk_div1_clkdiv_cur,                  
                                  
    output wire [4:0]                          hostcpuclk_div1_clkdiv,                      
    input wire [7:0]                           gicclk_ctrl_clkselect_cur,                   
    output wire [7:0]                          gicclk_ctrl_clkselect,                       
    input wire [4:0]                           gicclk_div0_clkdiv_cur,                      
    output wire [4:0]                          gicclk_div0_clkdiv,                          
    input wire [7:0]                           aclk_ctrl_clkselect_cur,                     
    output wire [7:0]                          aclk_ctrl_clkselect,                         
    input wire [4:0]                           aclk_div0_clkdiv_cur,                        
                                  
    output wire [4:0]                          aclk_div0_clkdiv,                            
    input wire [7:0]                           ctrlclk_ctrl_clkselect_cur,                  
    output wire [7:0]                          ctrlclk_ctrl_clkselect,                      
    input wire [4:0]                           ctrlclk_div0_clkdiv_cur,                     
    output wire [4:0]                          ctrlclk_div0_clkdiv,                         
    input wire [7:0]                           dbgclk_ctrl_clkselect_cur,                   
    output wire [7:0]                          dbgclk_ctrl_clkselect,                       
    input wire [4:0]                           dbgclk_div0_clkdiv_cur,                      
    output wire [4:0]                          dbgclk_div0_clkdiv,                          
    output wire                                clkforce_st_dbgclk_force_st,                 
    output wire                                clkforce_st_ctrlclk_force_st,                
    output wire                                clkforce_st_aclk_force_st,                   
    output wire                                clkforce_st_gicclk_force_st,                 
    input wire                                 pll_st_cpuplllock_st,                        
    input wire                                 pll_st_sysplllock_st,                        
    input wire                                 host_ppu_int_st_core3_int_st,                
    input wire                                 host_ppu_int_st_core2_int_st,                
    input wire                                 host_ppu_int_st_core1_int_st,                
    input wire                                 host_ppu_int_st_core0_int_st,                
    input wire                                 host_ppu_int_st_clustop_int_st,              
    output wire                                host_cpu_clus_pwr_req_mem_ret_r,             

                                               
    input wire [1:0]                           ext_sys0_rst_st_rst_ack,                     
    output wire                                ext_sys0_rst_ctrl_rst_req,                   
    output wire                                ext_sys0_rst_ctrl_cpuwait,                   
    input  wire                                set_extsys0_cpuwait,                         
    input  wire                                extsys0_cpuwait_wen,

                                               
    input wire [1:0]                           ext_sys1_rst_st_rst_ack,                     
    output wire                                ext_sys1_rst_ctrl_rst_req,                   
    output wire                                ext_sys1_rst_ctrl_cpuwait,                   
    input  wire                                set_extsys1_cpuwait,                         
    input  wire                                extsys1_cpuwait_wen,

    input wire  [3:0]                          secenc_bsys_pwr_req_systop_pwr_req,          
    output wire [4:0]                          secenc_bsys_pwr_st_systop_pwr_st,            
    input wire                                 secenc_bsys_pwr_req_dbgtop_pwr_req,          
    output wire                                secenc_bsys_pwr_st_dbgtop_pwr_st,            
    input  wire                                secenc_bsys_pwr_req_refclk_req,              
                  
    output wire                                secure_wdog_intr_second,                     
    output wire                                fwtamp_intr,                                 
    input  wire                                fctrl_bypass,                                
                  
    input  wire                                dp_cdbgpwrupreq,                             
    output wire                                dp_cdbgpwrupack,                             
    input wire                                 dprom_cdbgrstreq0,                           
    output wire                                dprom_cdbgrstack0,                           
    input wire                                 dprom_cdbgpwrupreq0,                         
    output wire                                dprom_cdbgpwrupack0,                         
    input  wire                                axiap_csyspwrupreq0,                         
    input  wire                                axiap_csyspwrupreq1,                         
    output wire                                axiap_csyspwrupack0,                         
    input wire                                 host_cdbgpwrupreq,
    input  wire                                sdc600_rempur,                               
    output wire                                sdc600_rempua,                               
  
    input  wire                                irq_sdc600,                                  
    input  wire                                irq_soc_etr,                                 
    input  wire                                irq_soc_catu,                                
    input  wire                                irq_host_stm,                                
    input  wire                                irq_host_etr,                                
    input  wire                                irq_host_catu,                               
    input  wire                                host_cti_trig_out_4,                         
    input  wire                                host_cti_trig_out_5,                         
      
    input  wire                                secenc_mhu1_sender_cirq,                     
    input  wire                                secenc_mhu1_receiver_cirq,                   
    input  wire                                secenc_mhu0_sender_cirq,                     
    input  wire                                secenc_mhu0_receiver_cirq,                   
    input  wire                                extsys0_mhu0_sender_cirq,                    
    input  wire                                extsys0_mhu0_receiver_cirq,                  
      input  wire                                extsys0_mhu1_sender_cirq,                    
    input  wire                                extsys0_mhu1_receiver_cirq,                  
      input  wire                                extsys1_mhu0_sender_cirq,                    
    input  wire                                extsys1_mhu0_receiver_cirq,                  
      input  wire                                extsys1_mhu1_sender_cirq,                    
    input  wire                                extsys1_mhu1_receiver_cirq,                  
    
    input  wire                                gic_wakeup,                                  
    input  wire                                recwakeup_async_eh0_mhu_esh_0,               
      input  wire                                recwakeup_async_eh0_mhu_esh_1,               
      input  wire                                recwakeup_async_eh1_mhu_esh_0,               
      input  wire                                recwakeup_async_eh1_mhu_esh_1,               
      input  wire                                recwakeup_async_seh0_mhu,                    
    input  wire                                recwakeup_async_seh1_mhu,                    
                  
    input wire [3:0]                           host_rst_syn,                                
  
    input wire [15:0]                          clustop_ppuhwstat,
  
    output wire [3:0]                          host_cpu_wake_up,
    input wire [4:0]                           host_lock, 
  
    output  wire  [9:0]                        modify_lock_req,
    input   wire  [9:0]                        modify_lock_ack,

  
    input wire                                 mbistreq,                                    
    input wire                                 nmbistreset,                                 
    input wire                                 dftdivsel,                                   
    input wire                                 dftramhold,                                  
    input wire [1:0]                           dftrstdisable,                               
    input wire                                 dftcgen,                                     
    input wire                                 dftisodisable,                               
    input wire                                 dftpwrup,                                    
    input wire                                 dftretdisable,                               

    input wire [2:0]                           dfthostuartclksel,                
    input wire                                 dfthostuartclkselen,                 
    input wire                                 dfthostuartclkdivbypass  
);

  localparam DD_SYNC_COUNT = 8;
    
  wire  host_sys_lctrl_host_fw_lock;

  wire [FCTRLPROG_AWID_WIDTH-1:0]   fwctrl_awid;
  wire [31:0]  fwctrl_awaddr;
  wire [7:0]   fwctrl_awlen;
  wire [2:0]   fwctrl_awsize;
  wire [1:0]   fwctrl_awburst;
  wire         fwctrl_awlock;
  wire [3:0]   fwctrl_awcache;
  wire [2:0]   fwctrl_awprot;
  wire         fwctrl_awvalid;
  wire         fwctrl_awready;
  wire [FCTRLPROG_AWUSER_WIDTH-1:0]   fwctrl_awuser;
  
  wire [31:0]  fwctrl_wdata;
  wire [3:0]   fwctrl_wstrb;
  wire         fwctrl_wlast;
  wire         fwctrl_wvalid;
  wire         fwctrl_wready;
  
  wire [FCTRLPROG_AWID_WIDTH-1:0]   fwctrl_bid;
  wire [1:0]   fwctrl_bresp;
  wire         fwctrl_bvalid;
  wire         fwctrl_bready;
  wire         fwctrl_buser;
  
  wire [FCTRLPROG_ARID_WIDTH-1:0]   fwctrl_arid;
  wire [31:0]  fwctrl_araddr;
  wire [7:0]   fwctrl_arlen;
  wire [2:0]   fwctrl_arsize;
  wire [1:0]   fwctrl_arburst;
  wire         fwctrl_arlock;
  wire [3:0]   fwctrl_arcache;
  wire [2:0]   fwctrl_arprot;
  wire         fwctrl_arvalid;
  wire         fwctrl_arready;
  wire [FCTRLPROG_AWUSER_WIDTH-1:0]   fwctrl_aruser;
  
  wire [FCTRLPROG_ARID_WIDTH-1:0]   fwctrl_rid;
  wire [31:0]  fwctrl_rdata;
  wire [1:0]   fwctrl_rresp;
  wire         fwctrl_rlast;
  wire         fwctrl_rvalid;
  wire         fwctrl_rready;
    
  wire                 penable;
  wire [31:0]          paddr;
  wire                 pwrite;
  wire [31:0]          pwdata;
  wire [3:0]           pstrb;
  wire [2:0]           pprot;
  wire                 pwakeup; 
  
   
  wire [2:0] hostuartclk_ctrl_clkselect_cur;
  wire [2:0] hostuartclk_ctrl_clkselect;
  wire [4:0] hostuartclk_div0_clkdiv_cur;
  wire [4:0] hostuartclk_div0_clkdiv;
  
  wire hostuartclk;
  wire hostuartclk_resetn;
  
  wire  refclk_qreqn;
  wire  refclk_qacceptn;
  wire  refclk_qdeny;
  wire  refclk_qactive;
  
  assign refclk_poresetn_qactive = refclk_qactive;
  
    wire        psel_system_id; 
  wire        pready_system_id;
  wire [31:0] prdata_system_id; 
  wire        pslverr_system_id;
    
  wire        psel_host_chassis_control; 
  wire        pready_host_chassis_control;
  wire [31:0] prdata_host_chassis_control; 
  wire        pslverr_host_chassis_control;
    
  wire        psel_firewall_ppu; 
  wire        pready_firewall_ppu;
  wire [31:0] prdata_firewall_ppu; 
  wire        pslverr_firewall_ppu;
    
  wire        psel_systop_ppu; 
  wire        pready_systop_ppu;
  wire [31:0] prdata_systop_ppu; 
  wire        pslverr_systop_ppu;
    
  wire        psel_dbgtop_ppu; 
  wire        pready_dbgtop_ppu;
  wire [31:0] prdata_dbgtop_ppu; 
  wire        pslverr_dbgtop_ppu;
    
  wire        psel_refclk_cntcontrol; 
  wire        pready_refclk_cntcontrol;
  wire [31:0] prdata_refclk_cntcontrol; 
  wire        pslverr_refclk_cntcontrol;
    
  wire        psel_refclk_cntread; 
  wire        pready_refclk_cntread;
  wire [31:0] prdata_refclk_cntread; 
  wire        pslverr_refclk_cntread;
    
  wire        psel_refclk_cntctl; 
  wire        pready_refclk_cntctl;
  wire [31:0] prdata_refclk_cntctl; 
  wire        pslverr_refclk_cntctl;
    
  wire        psel_refclk_cntbase0; 
  wire        pready_refclk_cntbase0;
  wire [31:0] prdata_refclk_cntbase0; 
  wire        pslverr_refclk_cntbase0;
    
  wire        psel_refclk_cntbase1; 
  wire        pready_refclk_cntbase1;
  wire [31:0] prdata_refclk_cntbase1; 
  wire        pslverr_refclk_cntbase1;
    
  wire        psel_refclk_cntbase2; 
  wire        pready_refclk_cntbase2;
  wire [31:0] prdata_refclk_cntbase2; 
  wire        pslverr_refclk_cntbase2;
    
  wire        psel_refclk_cntbase3; 
  wire        pready_refclk_cntbase3;
  wire [31:0] prdata_refclk_cntbase3; 
  wire        pslverr_refclk_cntbase3;
    
  wire        psel_ns_wdog; 
  wire        pready_ns_wdog;
  wire [31:0] prdata_ns_wdog; 
  wire        pslverr_ns_wdog;
    
  wire        psel_secure_wdog; 
  wire        pready_secure_wdog;
  wire [31:0] prdata_secure_wdog; 
  wire        pslverr_secure_wdog;
    
  wire        psel_s32k_cntcontrol; 
  wire        pready_s32k_cntcontrol;
  wire [31:0] prdata_s32k_cntcontrol; 
  wire        pslverr_s32k_cntcontrol;
    
  wire        psel_s32k_cntread; 
  wire        pready_s32k_cntread;
  wire [31:0] prdata_s32k_cntread; 
  wire        pslverr_s32k_cntread;
    
  wire        psel_s32k_cntctl; 
  wire        pready_s32k_cntctl;
  wire [31:0] prdata_s32k_cntctl; 
  wire        pslverr_s32k_cntctl;
    
  wire        psel_s32k_cntbase0; 
  wire        pready_s32k_cntbase0;
  wire [31:0] prdata_s32k_cntbase0; 
  wire        pslverr_s32k_cntbase0;
    
  wire        psel_s32k_cntbase1; 
  wire        pready_s32k_cntbase1;
  wire [31:0] prdata_s32k_cntbase1; 
  wire        pslverr_s32k_cntbase1;
    
  wire        psel_interrupt_router; 
  wire        pready_interrupt_router;
  wire [31:0] prdata_interrupt_router; 
  wire        pslverr_interrupt_router;
    
  wire        psel_aon_expansion_intf; 
  wire        pready_aon_expansion_intf;
  wire [31:0] prdata_aon_expansion_intf; 
  wire        pslverr_aon_expansion_intf;
    
   

  wire [DD_SYNC_COUNT-1:0]  refclk_sleep_gated_sync_qactive;
  wire [10:0]   pactive_fwctrl;
  wire [10:0]   pactive_fwctrl_lac;
  wire [3:0]    pstate_fwctrl;
  wire          preq_fwctrl;
  wire          paccept_fwctrl;
  wire          pdeny_fwctrl;

  
  wire          fwctrl_ctrl_wakeup;
  
  wire          fwctrl_qreqn;
  wire          fwctrl_qacceptn;
  wire          fwctrl_qdeny;
  wire          fwctrl_qactive;
  
  wire          fwctrladb_qreqn;
  wire          fwctrladb_qacceptn;
  wire          fwctrladb_qdeny;
  wire          fwctrladb_qactive;
       
  wire [15:0]   systop_ppuhwstat;
  wire [15:0]   dbgtop_ppuhwstat;
  
  wire          dbgtop_devclken;
  wire          systop_devclken;

  
  wire          bootreg_qreqn;
  wire          bootreg_qacceptn;
  wire          bootreg_qdeny;
  wire          bootreg_qactive;
               
  wire          refclk_sleep_gated_clken;
  wire          refclk_int_gated_clken;
  
  wire   [5:0] cntacr0_refclk;
  wire  [63:0] cntvoff0_refclk;
  
  wire   [5:0] cntacr1_refclk;
  wire  [63:0] cntvoff1_refclk;
  
  wire   [5:0] cntacr2_refclk;
  wire  [63:0] cntvoff2_refclk;
  
  wire   [5:0] cntacr3_refclk;
  wire  [63:0] cntvoff3_refclk;
  
  wire         timer0fvireg_refclk;
  wire         timer0fpl0reg_refclk;
                           
  wire         timer1fvireg_refclk;
  wire         timer1fpl0reg_refclk;
                           
  wire         timer2fvireg_refclk;
  wire         timer2fpl0reg_refclk;
                           
  wire         timer3fvireg_refclk;
  wire         timer3fpl0reg_refclk;

  wire   [5:0] cntacr0_s32k;
  wire  [63:0] cntvoff0_s32k;
  
  wire   [5:0] cntacr1_s32k;
  wire  [63:0] cntvoff1_s32k;
      
  wire          refclk_cntbase0_intr;   
  wire          refclk_cntbase1_intr;
  wire          refclk_cntbase2_intr;
  wire          refclk_cntbase3_intr;
  wire          s32k_cntbase0_intr;  
  wire          s32k_cntbase1_intr;  
  wire          fwintr;
    
  wire         ppu_comb_intr;
  wire [7:0]   ppu_comb_intr_merged;
  wire         ns_wdog_intr_first;
  wire         ns_wdog_intr_second;
  wire         secure_wdog_intr_first;

  wire   uart0_intr;
  wire   uart1_intr;
  wire        dftcgen_or_mbistreq;
  wire        refclk_int_gated;
  wire        refclk_sleep_gated;
  
  wire [NUM_SHD_INT-1:0]  shared_interrupt_input;
  wire  host_sys_lctrl_int_rtr_lock;
  

  wire [63:0]  tsvalueb;
  wire [63:0]  tsvalueb_s32k;
 
  wire s32kresetn;
  

  wire [NUM_SHD_INT-1:0]  ici1_out;
  wire [NUM_SHD_INT-1:0]  ici0_out;
 
  wire systop_devclken_refclk_sleep_gated;
  wire systop_devclken_syspll;
  wire dbgtop_devclken_refclk_sleep_gated;
  wire dbgtop_devclken_syspll;
  
  wire        wake_systop_for_clustop_gated;
  wire        wake_systop_for_clustop_nongated;
  wire [10:0] pactive_systop_force;
  wire [10:0] pactive_dbgtop_force;
  
  reg  [2:0] bsys_pwr_req_systop_pwr_req;
  wire       bsys_pwr_req_dbgtop_pwr_req;
  
  wire [2:0] host_bsys_pwr_req_systop_pwr_req;
  wire       host_bsys_pwr_req_dbgtop_pwr_req;
  
  wire       bsys_pwr_req_refclk_req;
  wire       bsys_pwr_req_wakeup_en;
  wire [2:0] bsys_pwr_st_systop_pwr_st;
  wire       bsys_pwr_st_dbgtop_pwr_st;
  wire       host_ppu_int_st_systop_int_st;
  wire       host_ppu_int_st_dbgtop_int_st;
  wire       host_ppu_int_st_fw_int_st;

  wire              fctrlcfg_dbgtop_up_tvalid;
  wire              fctrlcfg_dbgtop_up_tready;
  wire [31:0]       fctrlcfg_dbgtop_up_tdata;
  wire [3:0]        fctrlcfg_dbgtop_up_tkeep;
  wire              fctrlcfg_dbgtop_up_tlast;
  wire [3:0]        fctrlcfg_dbgtop_up_tdest;
  wire              fctrlcfg_dbgtop_up_wakeup;

  wire              fctrlcfg_dbgtop_dn_tvalid;
  wire              fctrlcfg_dbgtop_dn_tready;
  wire [31:0]       fctrlcfg_dbgtop_dn_tdata;
  wire [3:0]        fctrlcfg_dbgtop_dn_tkeep;
  wire              fctrlcfg_dbgtop_dn_tlast;
  wire [3:0]        fctrlcfg_dbgtop_dn_tid;
  wire              fctrlcfg_dbgtop_dn_wakeup;
  
  wire              fctrlcfg_systop_up_tvalid;
  wire              fctrlcfg_systop_up_tready;
  wire [31:0]       fctrlcfg_systop_up_tdata;
  wire [3:0]        fctrlcfg_systop_up_tkeep;
  wire              fctrlcfg_systop_up_tlast;
  wire [3:0]        fctrlcfg_systop_up_tdest;
  wire              fctrlcfg_systop_up_wakeup;

  wire              fctrlcfg_systop_dn_tvalid;
  wire              fctrlcfg_systop_dn_tready;
  wire [31:0]       fctrlcfg_systop_dn_tdata;
  wire [3:0]        fctrlcfg_systop_dn_tkeep;
  wire              fctrlcfg_systop_dn_tlast;
  wire [3:0]        fctrlcfg_systop_dn_tid;
  wire              fctrlcfg_systop_dn_wakeup;

  wire              fctrlcfg_dn_tvalid;
  wire              fctrlcfg_dn_tready;
  wire [31:0]       fctrlcfg_dn_tdata;
  wire [3:0]        fctrlcfg_dn_tkeep;
  wire              fctrlcfg_dn_tlast;
  wire [3:0]        fctrlcfg_dn_tid;
  wire              fctrlcfg_dn_twakeup;
  
  wire              fctrlcfg_up_tvalid;
  wire              fctrlcfg_up_tready;
  wire [31:0]       fctrlcfg_up_tdata;
  wire [3:0]        fctrlcfg_up_tkeep;
  wire              fctrlcfg_up_tlast;
  wire [3:0]        fctrlcfg_up_tdest;
  wire              fctrlcfg_up_twakeup;

 
  wire              refclk_dbgpwrup_qreqn;   
  wire              refclk_dbgpwrup_qacceptn;
  wire              refclk_dbgpwrup_qdeny;   
  wire              refclk_dbgpwrup_qactive;  
 
  wire  [2:0]       ppu_qreqn_refclk;
  wire [2:0]        ppu_qacceptn_refclk;
  wire [2:0]        ppu_qdeny_refclk;
  wire [2:0]        ppu_qactive_refclk;
  wire [16:0]       ppu_qactive_only_refclk;
  
  
  wire [1:0]        systop_wakeup_qreqn;
  wire [1:0]        systop_wakeup_qacceptn;
  wire [1:0]        systop_wakeup_qdeny;
  wire [1:0]        systop_wakeup_qactive;
  
  
  wire               qreqn_dbgtop_dpromreqack;
  wire               qacceptn_dbgtop_dpromreqack;
  wire               qdeny_dbgtop_dpromreqack;
  wire               qactive_dbgtop_dpromreqack;
  
  
 wire                aonperip_mux_qreqn;
 wire                aonperip_mux_qacceptn;
 wire                aonperip_mux_qdeny;
 wire                aonperip_mux_qactive;
 wire                aonperip_mux_qactive_only;
  
  
  wire fctrlcfg_dbgtop_dn_clkqreqn;
  wire fctrlcfg_dbgtop_dn_clkqacceptn;
  wire fctrlcfg_dbgtop_dn_clkqdeny;
  wire fctrlcfg_dbgtop_dn_clkqactive;

  wire fctrlcfg_dbgtop_up_clkqreqn;
  wire fctrlcfg_dbgtop_up_clkqacceptn;
  wire fctrlcfg_dbgtop_up_clkqdeny;
  wire fctrlcfg_dbgtop_up_clkqactive;

  wire fctrlcfg_systop_dn_clkqreqn;
  wire fctrlcfg_systop_dn_clkqacceptn;
  wire fctrlcfg_systop_dn_clkqdeny;
  wire fctrlcfg_systop_dn_clkqactive;

  wire fctrlcfg_systop_up_clkqreqn;
  wire fctrlcfg_systop_up_clkqacceptn;
  wire fctrlcfg_systop_up_clkqdeny;
  wire fctrlcfg_systop_up_clkqactive;
  
       
  wire fctrlcfg_dbgtop_up_pwrqreqn;
  wire fctrlcfg_dbgtop_up_pwrqacceptn;
  wire fctrlcfg_dbgtop_up_pwrqdeny;
  wire fctrlcfg_dbgtop_up_pwrqactive;
  
  wire fctrlcfg_systop_up_pwrqreqn;
  wire fctrlcfg_systop_up_pwrqacceptn;
  wire fctrlcfg_systop_up_pwrqdeny;
  wire fctrlcfg_systop_up_pwrqactive;
 
  wire secenc_bsys_pwr_req_systop_pwr_req_glitch;
  wire [3:0] secenc_bsys_pwr_req_systop_pwr_req_dd_dirty;
  reg  [2:0] secenc_bsys_pwr_req_systop_pwr_req_dd;   
   
 
  wire clkforce_st_dbgclk_force_st_int;
  wire clkforce_st_ctrlclk_force_st_int;
  wire clkforce_st_aclk_force_st_int;
  wire clkforce_st_gicclk_force_st_int;
  wire clkforce_st_refclk_force_st_int;

  wire resetn_clk_gen;

  wire [2:0] wake_systop_for_clustop;
    
  
  assign bsys_pwr_req_wakeup_en_o = bsys_pwr_req_wakeup_en;
  
  
     
  
 wire [10:0] refclk_int_qreqn;
 wire [10:0] refclk_int_qacceptn;
 wire [10:0] refclk_int_qdeny;
 wire [QACTIVE_REFCLK_TOP_CNT+25:0] refclk_int_qactive;
 
 wire  refclk_int_hc_qreqn;
 wire  refclk_int_hc_qacceptn;
 wire  refclk_int_hc_qdeny;
 wire  refclk_int_hc_qactive;
 
 wire  refclk_int_hc_toprst_qreqn;
 wire  refclk_int_hc_toprst_qacceptn;
 wire  refclk_int_hc_toprst_qdeny;
 wire  refclk_int_hc_toprst_qactive;
        
  
  wire systop_needs_refclk = !(systop_ppuhwstat[0] | systop_ppuhwstat[2]);
  wire dbgtop_needs_refclk = !dbgtop_ppuhwstat[0];
  
  wire qactive_refclk_int,qactive_refclk_int_2;
  
  assign dftcgen_or_mbistreq = dftcgen | mbistreq;
  
  
  wire refclk_poresetn;
  
  arm_element_reset_sync u_reset_sync (
  .clk             (refclk_free),         
  .resetn_async    (poresetn),
  .resetn_sync     (refclk_poresetn),   
  .dftrstdisable   (dftrstdisable[0]) 
  );
  
  refclkq_bridge u_refclk_bridge_poresetn (

    .clk            (refclk_free ),
    .ctrl_resetn_sync    (refclk_poresetn),
    .dev_resetn_sync     (refclk_aontopporesetn),
        
    .ctrl_qreqn_i   (refclk_poresetn_qreqn   ),
    .ctrl_qacceptn_o(refclk_poresetn_qacceptn),
    .ctrl_qdeny_o   (refclk_poresetn_qdeny   ),
                      
    
    .dev_qreqn_o   (refclk_qreqn   ),
    .dev_qacceptn_i(refclk_qacceptn),
    .dev_qdeny_i   (refclk_qdeny   )                   
  );


  pck600_clk_ctrl
 #(
  .NUM_Q_CHL        (3),
  .NUM_QACTIVE_ONLY (5+DD_SYNC_COUNT),
  .HC_Q_CH_SYNC     (1),
  .PWR_Q_CH_SYNC    (1),
  .CLK_Q_CH_SYNC    (1),
  .ACTIVE_DENY_EN   (1)
 )
 u_clk_ctrl_refclk_free
(
  .clk          (refclk_free),
  .reset_n      (refclk_aontopporesetn),
                
  .dftcgen      (dftcgen),

  .hc_qreqn_i       (refclk_qreqn   ),
  .hc_qacceptn_o    (refclk_qacceptn),
  .hc_qdeny_o       (refclk_qdeny   ),
  .hc_qactive_o     (refclk_qactive ),

  .pwr_qreqn_i      (1'b1),
  .pwr_qacceptn_o   (),
  .pwr_qdeny_o      (),
  .pwr_qactive_o    (),

  .clk_qreqn_o      ( {qreqn_aondbg_sleep_gated    ,refclk_dbgpwrup_qreqn   , refclk_int_hc_toprst_qreqn} ),
  .clk_qacceptn_i   ( {qacceptn_aondbg_sleep_gated ,refclk_dbgpwrup_qacceptn, refclk_int_hc_toprst_qacceptn} ),
  .clk_qactive_i    ( {qactive_refclk_systop,secenc_bsys_pwr_req_refclk_req, bsys_pwr_req_refclk_req, dbgtop_needs_refclk,systop_needs_refclk, refclk_sleep_gated_sync_qactive, qactive_aondbg_sleep_gated,refclk_dbgpwrup_qactive , refclk_int_hc_toprst_qactive}),
  .clk_qdeny_i      ( {qdeny_aondbg_sleep_gated,    refclk_dbgpwrup_qdeny, refclk_int_hc_toprst_qdeny } ),
                       
  .clk_force_i      (clkforce_st_refclk_force_st),

  .entry_delay_i    (refclk_ctrl_entrydelay),

  .clken_o          (refclk_sleep_gated_clken)

);
  
 assign refclk_int_hc_toprst_qactive = refclk_int_hc_qactive;

  refclkq_bridge u_refclk_bridge_aontopporesetn (

    .clk            (refclk_sleep_gated ),
    .ctrl_resetn_sync    (refclk_aontopporesetn),
    .dev_resetn_sync     (refclk_warmresetn),
        
    .ctrl_qreqn_i   (refclk_int_hc_toprst_qreqn   ),
    .ctrl_qacceptn_o(refclk_int_hc_toprst_qacceptn),
    .ctrl_qdeny_o   (refclk_int_hc_toprst_qdeny   ),
                      
    
    .dev_qreqn_o   (refclk_int_hc_qreqn   ),
    .dev_qacceptn_i(refclk_int_hc_qacceptn),
    .dev_qdeny_i   (refclk_int_hc_qdeny   )                 
  ); 

    
  pck600_clk_ctrl
 #(
  .NUM_Q_CHL        (11),
  .NUM_QACTIVE_ONLY (18+QACTIVE_REFCLK_TOP_CNT),
  .HC_Q_CH_SYNC     (1),
  .PWR_Q_CH_SYNC    (1),
  .CLK_Q_CH_SYNC    (1),
  .ACTIVE_DENY_EN   (1)
 )
 u_clk_ctrl_refclk_int
(
  .clk          (refclk_sleep_gated),
  .reset_n      (refclk_warmresetn),
                
  .dftcgen      (dftcgen),
  
   
  .hc_qreqn_i       (refclk_int_hc_qreqn   ),
  .hc_qacceptn_o    (refclk_int_hc_qacceptn),
  .hc_qdeny_o       (refclk_int_hc_qdeny   ),
  .hc_qactive_o     (refclk_int_hc_qactive),

  .pwr_qreqn_i      (1'b1),
  .pwr_qacceptn_o   (),
  .pwr_qdeny_o      (),
  .pwr_qactive_o    (),

  .clk_qreqn_o      ( {fwctrl_qreqn,fctrlcfg_dbgtop_dn_clkqreqn,   fctrlcfg_dbgtop_up_clkqreqn,   fctrlcfg_systop_dn_clkqreqn,   fctrlcfg_systop_up_clkqreqn,    fwctrladb_qreqn      ,bootreg_qreqn    ,aonperip_mux_qreqn   , ppu_qreqn_refclk   }   ),
  .clk_qacceptn_i   ( {fwctrl_qacceptn,fctrlcfg_dbgtop_dn_clkqacceptn,fctrlcfg_dbgtop_up_clkqacceptn,fctrlcfg_systop_dn_clkqacceptn,fctrlcfg_systop_up_clkqacceptn, fwctrladb_qacceptn,bootreg_qacceptn ,aonperip_mux_qacceptn, ppu_qacceptn_refclk}   ),
  .clk_qdeny_i      ( {fwctrl_qdeny,fctrlcfg_dbgtop_dn_clkqdeny,   fctrlcfg_dbgtop_up_clkqdeny,   fctrlcfg_systop_dn_clkqdeny,   fctrlcfg_systop_up_clkqdeny,    fwctrladb_qdeny      ,bootreg_qdeny    ,aonperip_mux_qdeny   , ppu_qdeny_refclk   }   ),
  .clk_qactive_i    ( {ppu_qactive_only_refclk,aonperip_mux_qactive_only,qactive_refclk_int_gated_top,fwctrl_qactive, fctrlcfg_dbgtop_dn_clkqactive, fctrlcfg_dbgtop_up_clkqactive, fctrlcfg_systop_dn_clkqactive, fctrlcfg_systop_up_clkqactive,  fwctrladb_qactive ,bootreg_qactive  ,aonperip_mux_qactive , ppu_qactive_refclk } ),

  .clk_force_i      (clkforce_st_refclk_force_st),

  .entry_delay_i    (refclk_ctrl_entrydelay),

  .clken_o          (refclk_int_gated_clken)
);


 arm_element_clock_gate u_refclk_int_gated (
  .clk_in  (refclk_sleep_gated),
  .enable  (refclk_int_gated_clken),
  .clk_out (refclk_int_gated),
  .dftcgen (dftcgen_or_mbistreq)
 );

  arm_element_clock_gate u_refclk_sleep_gated (
  .clk_in  (refclk_free),
  .enable  (refclk_sleep_gated_clken),
  .clk_out (refclk_sleep_gated),
  .dftcgen (dftcgen_or_mbistreq)
 );

 assign refclk_int_gated_out    = refclk_int_gated;
 assign refclk_sleep_gated_out    = refclk_sleep_gated;
 assign hostcntclkout = refclk_sleep_gated;
 

  arm_element_reset_sync u_reset_refclk_sync (
  .clk             (refclk_free),         
  .resetn_async    (aontop_warmresetn),
  .resetn_sync     (refclk_warmresetn),   
  .dftrstdisable   (dftrstdisable[0]) 
  );
  arm_element_reset_sync u_reset_refclk_sync_top (
  .clk             (refclk_free),         
  .resetn_async    (aontop_poresetn),
  .resetn_sync     (refclk_aontopporesetn),   
  .dftrstdisable   (dftrstdisable[0]) 
  );
  
 arm_element_reset_sync u_reset_s32kclk_sync (
  .clk             (s32kclk),         
  .resetn_async    (aontop_warmresetn),
  .resetn_sync     (s32kresetn),   
  .dftrstdisable   (dftrstdisable[0]) 
  );
 
 arm_element_reset_sync u_reset_uart_sync (
  .clk             (hostuartclk),         
  .resetn_async    (aontop_warmresetn),
  .resetn_sync     (hostuartclk_resetn),   
  .dftrstdisable   (dftrstdisable[0]) 
  );
  

 sse710_boot_reg_f0_aontop u_bootreg (
    
    
    .refclk               (refclk_int_gated),
    
    
    .aontop_warmresetn    (refclk_warmresetn),
        

    .qreqn_bootreg_refclk       (bootreg_qreqn),
    .qacceptn_bootreg_refclk    (bootreg_qacceptn),
    .qdeny_bootreg_refclk       (bootreg_qdeny),
    .qactive_bootreg_refclk     (bootreg_qactive),     
        
    .apb_async_req_bootreg           (bootreg_async_req),
    .apb_async_req_payload_bootreg   (bootreg_async_req_payload),
    .apb_async_resp_payload_bootreg  (bootreg_async_resp_payload),
    .apb_async_ack_bootreg           (bootreg_async_ack),
    
    .dftcgen                 (dftcgen)
  );
  
  arm_element_cdc_comb_mux2 u_clkgen_reset_nmbistreset_mux (
   .din1_async(refclk_warmresetn),
   .din2_async(nmbistreset),
   .sel       (dftdivsel),
   .dout_async(resetn_clk_gen)
  );
  
e_clk_f1_top_uartclk u_clk_f1_top_uartclk (
    .RESETN(resetn_clk_gen),    
    
    .REFCLK      (refclk_sleep_gated),
    .UARTCLK     (uartclk),
    .S32KCLK     (s32kclk),
    
    .HOSTUARTCLK (hostuartclk),
    
    .HOSTUARTCLK_ON_UARTCLK_DIVRATIO      (hostuartclk_div0_clkdiv       ),
    .HOSTUARTCLK_ON_UARTCLK_DIVRATIO_CUR  (hostuartclk_div0_clkdiv_cur   ),       
    .HOSTUARTCLK_CLKSEL                   (hostuartclk_ctrl_clkselect),    
    .HOSTUARTCLK_CLKSEL_CUR               (hostuartclk_ctrl_clkselect_cur),             
    
    .DFTHOSTUARTCLKSEL                  (dfthostuartclksel                 ),                      
    .DFTHOSTUARTCLKSELEN                (dfthostuartclkselen               ),
    .DFTHOSTUARTCLKDIVBYPASS_ON_UARTCLK (dfthostuartclkdivbypass),
    
    .DFTCGEN           (dftcgen),
    .DFTRSTDISABLE     (dftrstdisable[1])

);


  
    
   wire ppu_unused;
   
   assign ppu_unused = (|systop_ppuhwstat[15:10]) | 
                       (|systop_ppuhwstat[6:3])   | 
                       (|systop_ppuhwstat[1])     | 
                       (|dbgtop_ppuhwstat[15:10]) | 
                       (|dbgtop_ppuhwstat[7:1])   | 
                       (|clustop_ppuhwstat[15:10]) | 
                       (|clustop_ppuhwstat[6:0])   | 
                       (|ppu_qacceptn_refclk)     |
                       (|ppu_qdeny_refclk);
                        
   assign secenc_bsys_pwr_st_systop_pwr_st = {systop_ppuhwstat[8], 
                                              systop_ppuhwstat[7], 
                                              systop_ppuhwstat[2], 
                                              systop_ppuhwstat[9], 
                                              systop_ppuhwstat[0]  
                                              }; 
   assign secenc_bsys_pwr_st_dbgtop_pwr_st = bsys_pwr_st_dbgtop_pwr_st; 
   
   assign secenc_bsys_pwr_req_systop_pwr_req_glitch = (secenc_bsys_pwr_req_systop_pwr_req_dd_dirty[2:0] == 3'd0) && secenc_bsys_pwr_req_systop_pwr_req_dd_dirty[3] == 1'b0;
   
   always @(posedge refclk_sleep_gated or negedge refclk_warmresetn)
   begin
    if(!refclk_warmresetn)
    begin
        secenc_bsys_pwr_req_systop_pwr_req_dd<=3'd0;
        bsys_pwr_req_systop_pwr_req<=3'd0;
    end
    else
    begin
        if(!secenc_bsys_pwr_req_systop_pwr_req_glitch) 
            secenc_bsys_pwr_req_systop_pwr_req_dd<=secenc_bsys_pwr_req_systop_pwr_req_dd_dirty[2:0];       
        
        bsys_pwr_req_systop_pwr_req[2]<=secenc_bsys_pwr_req_systop_pwr_req_dd[2] | host_bsys_pwr_req_systop_pwr_req[2];               
        
        bsys_pwr_req_systop_pwr_req[1]<=(|secenc_bsys_pwr_req_systop_pwr_req_dd[2:1]) | (|host_bsys_pwr_req_systop_pwr_req[2:1]);
        
        bsys_pwr_req_systop_pwr_req[0]<=(secenc_bsys_pwr_req_systop_pwr_req_dd[2:0]==3'b001) | 
                                        (host_bsys_pwr_req_systop_pwr_req[2:0] == 3'b001);
    end
   end
       
   arm_element_or_tree #(
     .NUM_OR_TREE_INPUTS (2)
   ) u_arm_element_or_tree_pwr_req_dbgtop (
     .or_tree_i ({host_bsys_pwr_req_dbgtop_pwr_req, secenc_bsys_pwr_req_dbgtop_pwr_req}),
     .or_tree_o (bsys_pwr_req_dbgtop_pwr_req)
   );   
                                        
   assign bsys_pwr_st_systop_pwr_st = {systop_ppuhwstat[8], 
                                       systop_ppuhwstat[7], 
                                       systop_ppuhwstat[2]  
                                       }; 
   
   assign bsys_pwr_st_dbgtop_pwr_st = dbgtop_ppuhwstat[8]; 
   
   
  
  
  assign clkforce_st_dbgclk_force_st  = clkforce_st_dbgclk_force_st_int;
  assign clkforce_st_ctrlclk_force_st = clkforce_st_ctrlclk_force_st_int;
  assign clkforce_st_aclk_force_st    = clkforce_st_aclk_force_st_int;
  assign clkforce_st_gicclk_force_st  = clkforce_st_gicclk_force_st_int;
  assign clkforce_st_refclk_force_st  = clkforce_st_refclk_force_st_int;
   
  
   
   
    arm_element_or_tree #(
    .NUM_OR_TREE_INPUTS (19+4*2)
    ) u_systop_wakeup (
    .or_tree_i  ({
                 gic_wakeup,
                 ns_wdog_intr_second,
                 ns_wdog_intr_first,
                 secure_wdog_intr_first,
                 secenc_mhu0_receiver_cirq,
                 secenc_mhu0_sender_cirq,
                 secenc_mhu1_receiver_cirq,
                 secenc_mhu1_sender_cirq,
                 extsys0_mhu0_receiver_cirq,
                 extsys0_mhu0_sender_cirq,
                   extsys0_mhu1_receiver_cirq,
                 extsys0_mhu1_sender_cirq,
                   extsys1_mhu0_receiver_cirq,
                 extsys1_mhu0_sender_cirq,
                   extsys1_mhu1_receiver_cirq,
                 extsys1_mhu1_sender_cirq,
                   uart0_intr,
                 uart1_intr,
                 fwintr,
                 irq_sdc600,
                 ppu_comb_intr,
                 refclk_cntbase0_intr,
                 refclk_cntbase1_intr,
                 refclk_cntbase2_intr,
                 refclk_cntbase3_intr,
                 s32k_cntbase0_intr,
                 s32k_cntbase1_intr
                 }),
    .or_tree_o  (wake_systop_for_clustop_nongated)
    );
   
   arm_element_cdc_comb_and2  u_systop_wakeup_gate (
         .din1_async( wake_systop_for_clustop_nongated), 
         .din2_async( bsys_pwr_req_wakeup_en), 
         .dout_async( wake_systop_for_clustop_gated         )  
         );


   assign wake_systop_for_clustop = { wake_systop_for_clustop_gated, 
                                      host_cdbgpwrupreq,
                                      axiap_csyspwrupreq1 
                                    };
  
   arm_element_or_tree #(
    .NUM_OR_TREE_INPUTS (11+2*2)
    ) u_pactive_systop_force7 (
    .or_tree_i  ({  
                    clustop_ppuhwstat[7],
                    clustop_ppuhwstat[8],
                    clustop_ppuhwstat[9],                                        
                    bsys_pwr_req_systop_pwr_req[1],
                    recwakeup_async_eh0_mhu_esh_0,
                      recwakeup_async_eh0_mhu_esh_1,
                      recwakeup_async_eh1_mhu_esh_0,
                      recwakeup_async_eh1_mhu_esh_1,
                      recwakeup_async_seh0_mhu,
                    recwakeup_async_seh1_mhu,                    
                    axiap_csyspwrupreq0,
                    sdc600_rempur,                                                        
                    wake_systop_for_clustop
                    }),
    .or_tree_o  (pactive_systop_force[7])
    );
    
                                    
   
   assign pactive_systop_force[10:9] = 2'd0;   
   assign pactive_systop_force[8]    = bsys_pwr_req_systop_pwr_req[2];                                                      
   assign pactive_systop_force[6:3]  = 4'd0;                   
   assign pactive_systop_force[2]    = bsys_pwr_req_systop_pwr_req[0];
   assign pactive_systop_force[1:0]  = 2'b01;

   
   assign pactive_dbgtop_force[10] = 1'b0;
   assign pactive_dbgtop_force[9] =  dprom_cdbgrstreq0;   
   assign pactive_dbgtop_force[8]   = bsys_pwr_req_dbgtop_pwr_req;
   assign pactive_dbgtop_force[7:0] = 8'd1;
   
   
        
   wire dprom_cdbgrstreq0_ss;   
      
  
   assign dprom_cdbgrstack0  =  dbgtop_ppuhwstat[9];
   
   
   p_reqack_to_qchan_f0_top u_repack_dp_cdbgpwrupreq (
            .CLK(refclk_sleep_gated),
            .RESETn(refclk_aontopporesetn),
            .PWRUPREQ(dp_cdbgpwrupreq),
            .PWRUPACK(dp_cdbgpwrupack),
            
            .PWRQREQn     (refclk_dbgpwrup_qreqn   ),
            .PWRQACCEPTn  (refclk_dbgpwrup_qacceptn),
            .PWRQDENY     (refclk_dbgpwrup_qdeny   ),
            .PWRQACTIVE   (refclk_dbgpwrup_qactive ), 
            .CLKQACTIVE   ()
    );
    
   p_reqack_to_qchan_f0_top u_repack_sdc600_rempua (
            .CLK(refclk_sleep_gated),
            .RESETn(refclk_warmresetn),
            .PWRUPREQ(sdc600_rempur),
            .PWRUPACK(sdc600_rempua),
            
            .PWRQREQn     (systop_wakeup_qreqn   [0]),
            .PWRQACCEPTn  (systop_wakeup_qacceptn[0]),
            .PWRQDENY     (systop_wakeup_qdeny   [0]),
            .PWRQACTIVE   (systop_wakeup_qactive [0]), 
            .CLKQACTIVE   ()
    );
    
   p_reqack_to_qchan_f0_top u_repack_axiap_csyspwrupreq0 (
            .CLK(refclk_sleep_gated),
            .RESETn(refclk_warmresetn),
            .PWRUPREQ(axiap_csyspwrupreq0),
            .PWRUPACK(axiap_csyspwrupack0),
            
            .PWRQREQn     (systop_wakeup_qreqn   [1]),
            .PWRQACCEPTn  (systop_wakeup_qacceptn[1]),
            .PWRQDENY     (systop_wakeup_qdeny   [1]),
            .PWRQACTIVE   (systop_wakeup_qactive [1]), 
            .CLKQACTIVE   ()
    );
            
    
   
   
   p_reqack_to_qchan_f0_top u_repack_dprom_cdbgpwrupreq0 (
            .CLK(refclk_sleep_gated),
            .RESETn(refclk_warmresetn),
            .PWRUPREQ(dprom_cdbgpwrupreq0),
            .PWRUPACK(dprom_cdbgpwrupack0),
            
            .PWRQREQn     (qreqn_dbgtop_dpromreqack),  
            .PWRQACCEPTn  (qacceptn_dbgtop_dpromreqack),
            .PWRQDENY     (qdeny_dbgtop_dpromreqack),
            .PWRQACTIVE   (qactive_dbgtop_dpromreqack),
            .CLKQACTIVE   ()
    );
    
   ppu_aon #(
    .DEV_PREQ_DLY_DBG         (DEV_PREQ_DLY_DBG        ),
    .PCSM_PREQ_DLY_DBG        (PCSM_PREQ_DLY_DBG       ),
    .ISO_CLKEN_DLY_CFG_DBG    (ISO_CLKEN_DLY_CFG_DBG   ),
    .CLKEN_RST_DLY_CFG_DBG    (CLKEN_RST_DLY_CFG_DBG   ),
    .RST_HWSTAT_DLY_CFG_DBG   (RST_HWSTAT_DLY_CFG_DBG  ),
    .CLKEN_ISO_DLY_CFG_DBG    (CLKEN_ISO_DLY_CFG_DBG   ),
    .ISO_RST_DLY_CFG_DBG      (ISO_RST_DLY_CFG_DBG     ),
    .DEV_PREQ_DLY_SYS         (DEV_PREQ_DLY_SYS        ),
    .PCSM_PREQ_DLY_SYS        (PCSM_PREQ_DLY_SYS       ),
    .ISO_CLKEN_DLY_CFG_SYS    (ISO_CLKEN_DLY_CFG_SYS   ),
    .CLKEN_RST_DLY_CFG_SYS    (CLKEN_RST_DLY_CFG_SYS   ),
    .RST_HWSTAT_DLY_CFG_SYS   (RST_HWSTAT_DLY_CFG_SYS  ),
    .CLKEN_ISO_DLY_CFG_SYS    (CLKEN_ISO_DLY_CFG_SYS   ),
    .ISO_RST_DLY_CFG_SYS      (ISO_RST_DLY_CFG_SYS     ),
    .DEV_PREQ_DLY_FWRAM       (DEV_PREQ_DLY_FWRAM      ),
    .PCSM_PREQ_DLY_FWRAM      (PCSM_PREQ_DLY_FWRAM     ),
    .ISO_CLKEN_DLY_CFG_FWRAM  (ISO_CLKEN_DLY_CFG_FWRAM ),
    .CLKEN_RST_DLY_CFG_FWRAM  (CLKEN_RST_DLY_CFG_FWRAM ),
    .RST_HWSTAT_DLY_CFG_FWRAM (RST_HWSTAT_DLY_CFG_FWRAM),
    .CLKEN_ISO_DLY_CFG_FWRAM  (CLKEN_ISO_DLY_CFG_FWRAM ),
    .ISO_RST_DLY_CFG_FWRAM    (ISO_RST_DLY_CFG_FWRAM   ),
    .ES_CNT                   (ES_CNT),
    .SYS_EGRESS_2_DBG         (SYS_EGRESS_2_DBG),
    .SYS_INGRESS_2_DBG        (SYS_INGRESS_2_DBG),
    .DBG_INTERNAL_CNT         (DBG_INTERNAL_CNT),
    .DBG_EGRESS_CNT           (DBG_EGRESS_CNT)
   ) u_ppu_aon (
   
    .refclk_gated   (refclk_int_gated),
    .refclk_resetn  (refclk_warmresetn),

    
    .qreqn_refclk         (ppu_qreqn_refclk       ),
    .qacceptn_refclk      (ppu_qacceptn_refclk    ),
    .qdeny_refclk         (ppu_qdeny_refclk       ),
    .qactive_refclk       (ppu_qactive_refclk     ),
    .qactive_only_refclk  (ppu_qactive_only_refclk),
  
    .penable_systop_ppu   (penable),
    .paddr_systop_ppu     (paddr  ),
    .pwrite_systop_ppu    (pwrite ),
    .pwdata_systop_ppu    (pwdata ),
    .psel_systop_ppu      (psel_systop_ppu    ),
    .pready_systop_ppu    (pready_systop_ppu  ),
    .prdata_systop_ppu    (prdata_systop_ppu  ),
    .pslverr_systop_ppu   (pslverr_systop_ppu ),
    .pwakeup              (pwakeup),
  
    .penable_fwram_ppu   (penable),
    .paddr_fwram_ppu     (paddr  ),
    .pwrite_fwram_ppu    (pwrite ),
    .pwdata_fwram_ppu    (pwdata ),
    .psel_fwram_ppu      (psel_firewall_ppu    ),
    .pready_fwram_ppu    (pready_firewall_ppu  ),
    .prdata_fwram_ppu    (prdata_firewall_ppu  ),
    .pslverr_fwram_ppu   (pslverr_firewall_ppu ),
  
    .penable_dbgtop_ppu   (penable),
    .paddr_dbgtop_ppu     (paddr),
    .pwrite_dbgtop_ppu    (pwrite),
    .pwdata_dbgtop_ppu    (pwdata),
    .psel_dbgtop_ppu      (psel_dbgtop_ppu  ),
    .pready_dbgtop_ppu    (pready_dbgtop_ppu),
    .prdata_dbgtop_ppu    (prdata_dbgtop_ppu),
    .pslverr_dbgtop_ppu   (pslverr_dbgtop_ppu),

    
    .systop_wakeup_qreqn      (systop_wakeup_qreqn   ),
    .systop_wakeup_qacceptn   (systop_wakeup_qacceptn),
    .systop_wakeup_qdeny      (systop_wakeup_qdeny   ),
    .systop_wakeup_qactive    (systop_wakeup_qactive ),
    
    
    .qreqn_dbgtop_dpromreqack    (qreqn_dbgtop_dpromreqack   ),
    .qacceptn_dbgtop_dpromreqack (qacceptn_dbgtop_dpromreqack), 
    .qdeny_dbgtop_dpromreqack    (qdeny_dbgtop_dpromreqack   ),
    .qactive_dbgtop_dpromreqack  (qactive_dbgtop_dpromreqack ),
    
    .qreqn_secenc_systopq        (qreqn_secenc_systopq    ), 
    .qacceptn_secenc_systopq     (qacceptn_secenc_systopq ), 
    .qdeny_secenc_systopq        (qdeny_secenc_systopq    ), 
    .qactive_secenc_systopq      (qactive_secenc_systopq  ), 
                                
                                
    .qreqn_secenc_dbgtopq        (qreqn_secenc_dbgtopq   ),  
    .qacceptn_secenc_dbgtopq     (qacceptn_secenc_dbgtopq),  
    .qdeny_secenc_dbgtopq        (qdeny_secenc_dbgtopq   ),  
    .qactive_secenc_dbgtopq      (qactive_secenc_dbgtopq ),  
                                
                                
                                
    .qreqn_extsys_systopq        (qreqn_extsys_systopq   ),  
    .qacceptn_extsys_systopq     (qacceptn_extsys_systopq),  
    .qdeny_extsys_systopq        (qdeny_extsys_systopq   ),  
    .qactive_extsys_systopq      (qactive_extsys_systopq ),  
                                
                                
                                
    .qreqn_extsys_dbgtopq        (qreqn_extsys_dbgtopq   ),  
    .qacceptn_extsys_dbgtopq     (qacceptn_extsys_dbgtopq),  
    .qdeny_extsys_dbgtopq        (qdeny_extsys_dbgtopq   ),  
    .qactive_extsys_dbgtopq      (qactive_extsys_dbgtopq ),  
    
    .clustop_dependency_qreqn    (clustop_dependency_qreqn),
    .clustop_dependency_qacceptn (clustop_dependency_qacceptn),
    .clustop_dependency_qdeny    (clustop_dependency_qdeny),   
    .clustop_dependency_qactive  (clustop_dependency_qactive), 
    
    
    .qreqn_dbgtop_ingress_aon               (qreqn_dbgtop_ingress_aon     ),         
    .qacceptn_dbgtop_ingress_aon            (qacceptn_dbgtop_ingress_aon  ),         
    .qdeny_dbgtop_ingress_aon               (qdeny_dbgtop_ingress_aon     ),         
    .qactive_dbgtop_ingress_aon             (qactive_dbgtop_ingress_aon   ),         
                                            
                                            
    .qreqn_systop_egress_dbgtop             (qreqn_systop_egress_dbgtop    ),        
    .qacceptn_systop_egress_dbgtop          (qacceptn_systop_egress_dbgtop ),        
    .qdeny_systop_egress_dbgtop             (qdeny_systop_egress_dbgtop    ),        
    .qactive_systop_egress_dbgtop           (qactive_systop_egress_dbgtop  ),        
                                            
    .qreqn_systop_ingress_dbgtop            (qreqn_systop_ingress_dbgtop    ),      
    .qacceptn_systop_ingress_dbgtop         (qacceptn_systop_ingress_dbgtop ),      
    .qdeny_systop_ingress_dbgtop            (qdeny_systop_ingress_dbgtop    ),      
    .qactive_systop_ingress_dbgtop          (qactive_systop_ingress_dbgtop  ),
                                            
    .qreqn_systop                           (qreqn_systop     ),                     
    .qacceptn_systop                        (qacceptn_systop  ),                     
    .qdeny_systop                           (qdeny_systop     ),                     
    .qactive_systop                         (qactive_systop   ),                     

                                            
    .qreqn_systop_exp                       (qreqn_systop_exp   ),                     
    .qacceptn_systop_exp                    (qacceptn_systop_exp),                     
    .qdeny_systop_exp                       (qdeny_systop_exp   ),                     
    .qactive_systop_exp                     (qactive_systop_exp),                     
    
    .qreqn_systop_acg                       (qreqn_systop_acg    ),                  
    .qacceptn_systop_acg                    (qacceptn_systop_acg ),                  
    .qdeny_systop_acg                       (qdeny_systop_acg    ),                  
    .qactive_systop_acg                     (qactive_systop_acg  ),                    
    
    .qreqn_dbgtop_egress                    (qreqn_dbgtop_egress    ),
   .qacceptn_dbgtop_egress                  (qacceptn_dbgtop_egress ),
   .qdeny_dbgtop_egress                     (qdeny_dbgtop_egress    ),
   .qactive_dbgtop_egress                   (qactive_dbgtop_egress  ),
   
   
    .qreqn_dbgtop_internal                  (qreqn_dbgtop_internal    ),                    
    .qacceptn_dbgtop_internal               (qacceptn_dbgtop_internal ),        
    .qdeny_dbgtop_internal                  (qdeny_dbgtop_internal    ),        
    .qactive_dbgtop_internal                (qactive_dbgtop_internal  ),        
    
    .qreqn_dbgtop_exp                       (qreqn_dbgtop_exp    ),                    
    .qacceptn_dbgtop_exp                    (qacceptn_dbgtop_exp ),        
    .qdeny_dbgtop_exp                       (qdeny_dbgtop_exp    ),        
    .qactive_dbgtop_exp                     (qactive_dbgtop_exp  ),        
        
    .qreqn_clustop_egress_dbgtop            (qreqn_clustop_egress_dbgtop   ),
    .qacceptn_clustop_egress_dbgtop         (qacceptn_clustop_egress_dbgtop),
    .qdeny_clustop_egress_dbgtop            (qdeny_clustop_egress_dbgtop   ),
    .qactive_clustop_egress_dbgtop          (qactive_clustop_egress_dbgtop ),
    
    .qreqn_clustop_ingress_dbgtop           (qreqn_clustop_ingress_dbgtop   ),
    .qacceptn_clustop_ingress_dbgtop        (qacceptn_clustop_ingress_dbgtop),
    .qdeny_clustop_ingress_dbgtop           (qdeny_clustop_ingress_dbgtop   ),
    .qactive_clustop_ingress_dbgtop         (qactive_clustop_ingress_dbgtop ),
        
    .fctrlcfg_dbgtop_pwrqreqn               (fctrlcfg_dbgtop_up_pwrqreqn   ),
    .fctrlcfg_dbgtop_pwrqacceptn            (fctrlcfg_dbgtop_up_pwrqacceptn),
    .fctrlcfg_dbgtop_pwrqdeny               (fctrlcfg_dbgtop_up_pwrqdeny   ),
    .fctrlcfg_dbgtop_pwrqactive             (fctrlcfg_dbgtop_up_pwrqactive   ),
    
    .fctrlcfg_systop_pwrqreqn               (fctrlcfg_systop_up_pwrqreqn   ),
    .fctrlcfg_systop_pwrqacceptn            (fctrlcfg_systop_up_pwrqacceptn),
    .fctrlcfg_systop_pwrqdeny               (fctrlcfg_systop_up_pwrqdeny   ),
    .fctrlcfg_systop_pwrqactive             (fctrlcfg_systop_up_pwrqactive   ),
                                           
    .pactive_fwctrl                         (pactive_fwctrl),
    .pstate_fwctrl                          (pstate_fwctrl),
    .preq_fwctrl                            (preq_fwctrl),
    .paccept_fwctrl                         (paccept_fwctrl),
    .pdeny_fwctrl                           (pdeny_fwctrl),
   
    .pactive_systop_force                   (pactive_systop_force),
    
    .systop_devclken                        (systop_devclken),
    .systop_devwarmresetn                   (systop_warmresetn),
    .systop_ppuhwstat                       (systop_ppuhwstat),
    
    .systop_int                             (host_ppu_int_st_systop_int_st),     
    .dbgtop_int                             (host_ppu_int_st_dbgtop_int_st),
    .fw_int                                 (host_ppu_int_st_fw_int_st    ),

    .pactive_dbgtop_force                   (pactive_dbgtop_force),
    
    
    .dbgtop_devclken                        (dbgtop_devclken),    
    .dbgtop_devwarmresetn                   (dbgtop_warmresetn),
    .dbgtop_ppuhwstat                       (dbgtop_ppuhwstat),
    
    .fwram_ppuhwstat                        (),
    .fwram_devwarmresetn                    (),
    .fwram_devclken                         (),

    
    .dftcgen                                (dftcgen),
    .dftisodisable                          (dftisodisable),    
    .dftrstdisable                          (dftrstdisable[1]),
    .dftpwrup                               (dftpwrup),
    .dftretdisable                          (dftretdisable)
    
 );
    
   
    pcg  #(
        .WIDTH(3)
    )
    u_pcgs
    (
       .clk_in  ({refclk_sleep_gated,
                  syspll,
                  traceclk_in}),
       .enable  ({dbgtop_devclken,
                  dbgtop_devclken,
                  dbgtop_devclken}),                  
       .clk_out ({refclk_dbgtop,
                  syspll_dbgtop,
                  traceclk_in_dbgtop}),
       .resetn  ({3{aontop_warmresetn}}),
       .dftcgen (dftcgen),
       .dftrstdisable(dftrstdisable[0])
    );
    
    pcg  #(
        .WIDTH(1)
    )
    u_pcg_cpupll
    (
       .clk_in  ({cpupll}),
       .enable  ({systop_devclken}),                  
       .clk_out ({cpupll_systop}),
       .resetn  ({aontop_warmresetn}),
       .dftcgen (dftcgen_or_mbistreq),
       .dftrstdisable(dftrstdisable[0])
    );
    
    pcg  #(
        .WIDTH(1)
    )
    u_pcg_refclk_systop
    (
       .clk_in  (refclk_sleep_gated),
       .enable  (systop_devclken),                  
       .clk_out (refclk_systop),
       .resetn  (aontop_warmresetn),
       .dftcgen (dftcgen_or_mbistreq),
       .dftrstdisable(dftrstdisable[0])
    );
    
    pcg  #(
        .WIDTH(1)
    )
    u_pcg_syspll_systop
    (
       .clk_in  (syspll),
       .enable  (systop_devclken),                  
       .clk_out (syspll_systop),
       .resetn  (aontop_warmresetn),
       .dftcgen (dftcgen_or_mbistreq),
       .dftrstdisable(dftrstdisable[0])
    );
    
    assign hostcntclkout_systop = refclk_systop;
    
              
    wire ppu_dbgen_ss;
             

     
    aonperip_mux u_aonperip_mux (
        .refclk_int_gated (refclk_int_gated),
        .resetn           (refclk_warmresetn),        

        
        .apb_async_req            (periph_async_req           ),
        .apb_async_req_payload    (periph_async_req_payload   ),
        .apb_async_resp_payload   (periph_async_resp_payload  ),
        .apb_async_ack            (periph_async_ack           ),

        
        .qreqn          (aonperip_mux_qreqn),
        .qacceptn       (aonperip_mux_qacceptn    ),
        .qdeny          (aonperip_mux_qdeny       ),
        .qactive        (aonperip_mux_qactive     ),
        .qactive_only   (aonperip_mux_qactive_only),

        .penable    (penable),
        .paddr      (paddr),
        .pwrite     (pwrite),
        .pwdata     (pwdata),
        .pstrb      (pstrb),
        .pprot      (pprot),
        .pwakeup    (pwakeup),
        
       
        .ppu_dbgen      (ppu_dbgen_ss),
    
                 
        .psel_system_id   (psel_system_id),
        .pready_system_id (pready_system_id),
        .prdata_system_id (prdata_system_id),
        .pslverr_system_id(pslverr_system_id),            
                 
        .psel_host_chassis_control   (psel_host_chassis_control),
        .pready_host_chassis_control (pready_host_chassis_control),
        .prdata_host_chassis_control (prdata_host_chassis_control),
        .pslverr_host_chassis_control(pslverr_host_chassis_control),            
                 
        .psel_firewall_ppu   (psel_firewall_ppu),
        .pready_firewall_ppu (pready_firewall_ppu),
        .prdata_firewall_ppu (prdata_firewall_ppu),
        .pslverr_firewall_ppu(pslverr_firewall_ppu),            
                 
        .psel_systop_ppu   (psel_systop_ppu),
        .pready_systop_ppu (pready_systop_ppu),
        .prdata_systop_ppu (prdata_systop_ppu),
        .pslverr_systop_ppu(pslverr_systop_ppu),            
                 
        .psel_dbgtop_ppu   (psel_dbgtop_ppu),
        .pready_dbgtop_ppu (pready_dbgtop_ppu),
        .prdata_dbgtop_ppu (prdata_dbgtop_ppu),
        .pslverr_dbgtop_ppu(pslverr_dbgtop_ppu),            
                 
        .psel_refclk_cntcontrol   (psel_refclk_cntcontrol),
        .pready_refclk_cntcontrol (pready_refclk_cntcontrol),
        .prdata_refclk_cntcontrol (prdata_refclk_cntcontrol),
        .pslverr_refclk_cntcontrol(pslverr_refclk_cntcontrol),            
                 
        .psel_refclk_cntread   (psel_refclk_cntread),
        .pready_refclk_cntread (pready_refclk_cntread),
        .prdata_refclk_cntread (prdata_refclk_cntread),
        .pslverr_refclk_cntread(pslverr_refclk_cntread),            
                 
        .psel_refclk_cntctl   (psel_refclk_cntctl),
        .pready_refclk_cntctl (pready_refclk_cntctl),
        .prdata_refclk_cntctl (prdata_refclk_cntctl),
        .pslverr_refclk_cntctl(pslverr_refclk_cntctl),            
                 
        .psel_refclk_cntbase0   (psel_refclk_cntbase0),
        .pready_refclk_cntbase0 (pready_refclk_cntbase0),
        .prdata_refclk_cntbase0 (prdata_refclk_cntbase0),
        .pslverr_refclk_cntbase0(pslverr_refclk_cntbase0),            
                 
        .psel_refclk_cntbase1   (psel_refclk_cntbase1),
        .pready_refclk_cntbase1 (pready_refclk_cntbase1),
        .prdata_refclk_cntbase1 (prdata_refclk_cntbase1),
        .pslverr_refclk_cntbase1(pslverr_refclk_cntbase1),            
                 
        .psel_refclk_cntbase2   (psel_refclk_cntbase2),
        .pready_refclk_cntbase2 (pready_refclk_cntbase2),
        .prdata_refclk_cntbase2 (prdata_refclk_cntbase2),
        .pslverr_refclk_cntbase2(pslverr_refclk_cntbase2),            
                 
        .psel_refclk_cntbase3   (psel_refclk_cntbase3),
        .pready_refclk_cntbase3 (pready_refclk_cntbase3),
        .prdata_refclk_cntbase3 (prdata_refclk_cntbase3),
        .pslverr_refclk_cntbase3(pslverr_refclk_cntbase3),            
                 
        .psel_ns_wdog   (psel_ns_wdog),
        .pready_ns_wdog (pready_ns_wdog),
        .prdata_ns_wdog (prdata_ns_wdog),
        .pslverr_ns_wdog(pslverr_ns_wdog),            
                 
        .psel_secure_wdog   (psel_secure_wdog),
        .pready_secure_wdog (pready_secure_wdog),
        .prdata_secure_wdog (prdata_secure_wdog),
        .pslverr_secure_wdog(pslverr_secure_wdog),            
                 
        .psel_s32k_cntcontrol   (psel_s32k_cntcontrol),
        .pready_s32k_cntcontrol (pready_s32k_cntcontrol),
        .prdata_s32k_cntcontrol (prdata_s32k_cntcontrol),
        .pslverr_s32k_cntcontrol(pslverr_s32k_cntcontrol),            
                 
        .psel_s32k_cntread   (psel_s32k_cntread),
        .pready_s32k_cntread (pready_s32k_cntread),
        .prdata_s32k_cntread (prdata_s32k_cntread),
        .pslverr_s32k_cntread(pslverr_s32k_cntread),            
                 
        .psel_s32k_cntctl   (psel_s32k_cntctl),
        .pready_s32k_cntctl (pready_s32k_cntctl),
        .prdata_s32k_cntctl (prdata_s32k_cntctl),
        .pslverr_s32k_cntctl(pslverr_s32k_cntctl),            
                 
        .psel_s32k_cntbase0   (psel_s32k_cntbase0),
        .pready_s32k_cntbase0 (pready_s32k_cntbase0),
        .prdata_s32k_cntbase0 (prdata_s32k_cntbase0),
        .pslverr_s32k_cntbase0(pslverr_s32k_cntbase0),            
                 
        .psel_s32k_cntbase1   (psel_s32k_cntbase1),
        .pready_s32k_cntbase1 (pready_s32k_cntbase1),
        .prdata_s32k_cntbase1 (prdata_s32k_cntbase1),
        .pslverr_s32k_cntbase1(pslverr_s32k_cntbase1),            
                 
        .psel_interrupt_router   (psel_interrupt_router),
        .pready_interrupt_router (pready_interrupt_router),
        .prdata_interrupt_router (prdata_interrupt_router),
        .pslverr_interrupt_router(pslverr_interrupt_router),            
                 
        .psel_aon_expansion_intf   (psel_aon_expansion_intf),
        .pready_aon_expansion_intf (pready_aon_expansion_intf),
        .prdata_aon_expansion_intf (prdata_aon_expansion_intf),
        .pslverr_aon_expansion_intf(pslverr_aon_expansion_intf),            
           
        .dftcgen    (dftcgen)
    );
   
 uart_subsys  u_uart_subsys
(
  .uartclk      (hostuartclk),
  .uartresetn   (hostuartclk_resetn),
  
  .apb_async_req           (uart_async_req          ),
  .apb_async_req_payload   (uart_async_req_payload  ),
  .apb_async_resp_payload  (uart_async_resp_payload ),
  .apb_async_ack           (uart_async_ack          ),
   
  .uart0_intr  (uart0_intr),
  .uart1_intr  (uart1_intr),
  
  .uart0_out2n (uart0_out2n),
  .uart0_out1n (uart0_out1n),
  .uart0_rtsn  (uart0_rtsn),
  .uart0_dtrn  (uart0_dtrn),
  .uart0_txd   (uart0_txd),
  .uart0_ctsn  (uart0_ctsn),
  .uart0_dcdn  (uart0_dcdn),
  .uart0_dsrn  (uart0_dsrn),
  .uart0_ri    (uart0_ri),
  .uart0_rxd   (uart0_rxd),
  
  .uart1_out2n (uart1_out2n),
  .uart1_out1n  (uart1_out1n ),
  .uart1_rtsn   (uart1_rtsn ),
  .uart1_dtrn   (uart1_dtrn ),
  .uart1_txd    (uart1_txd  ),
  .uart1_ctsn   (uart1_ctsn ),
  .uart1_dcdn   (uart1_dcdn ),
  .uart1_dsrn   (uart1_dsrn ),
  .uart1_ri     (uart1_ri   ),
  .uart1_rxd    (uart1_rxd  ),
  
  .dftcgen     (dftcgen)
  );

 
  
 
 gray_encode u_refclk_gray_encode(
    .nreset        ( refclk_warmresetn ),
    .clk           ( refclk_sleep_gated ),
    .binary_count  ( tsvalueb ),
    .gray_count    ( tsvalueg_out)
 );
 
 gray_encode u_s32k_gray_encode(
    .nreset        ( s32kresetn ),
    .clk           ( s32kclk ),
    .binary_count  ( tsvalueb_s32k ),
    .gray_count    ( tsvalueg_s32k_out)
 );
  wire refclk_counter_haltreq;
  css600_pulseasyncbridgemstr #(
            .WIDTH(1)            
  )
  u_css600_pulseasyncbridgeslv_counter
  (
      .clk_m          (refclk_sleep_gated),                     
      .reset_m_n      (refclk_warmresetn),
      .pulse_out      (refclk_counter_haltreq  ),
      .pulse_req      (refclk_counter_haltreqreq),
      .pulse_ack      (refclk_counter_haltreqack),
      .clk_m_qreq_n    (1'b1),
      .clk_m_qaccept_n  ()  ,
      .clk_m_qactive    ()  
  );
 gcounter_syncapb u_refclk_gcounter(
    .SCLK        (refclk_sleep_gated),
    .SRESETn     (refclk_warmresetn),
    .PCLK        (refclk_sleep_gated),
    .PRESETn     (refclk_warmresetn),
    
    .PSELCNTCONTROL    (psel_refclk_cntcontrol),
    .PADDRCNTCONTROL   (paddr[11:2]),
    .PENABLECNTCONTROL (penable),
    .PWRITECNTCONTROL  (pwrite),
    .PWDATACNTCONTROL  (pwdata),
    .PREADYCNTCONTROL  (pready_refclk_cntcontrol),
    .PRDATACNTCONTROL  (prdata_refclk_cntcontrol),
    .PSLVERRCNTCONTROL (pslverr_refclk_cntcontrol),
    
    .PSELCNTREAD       (psel_refclk_cntread),
    .PADDRCNTREAD      (paddr[11:2]),
    .PENABLECNTREAD    (penable),
    .PWRITECNTREAD     (pwrite),
    .PWDATACNTREAD     (pwdata),
    .PREADYCNTREAD     (pready_refclk_cntread),
    .PRDATACNTREAD     (prdata_refclk_cntread),
    .PSLVERRCNTREAD    (pslverr_refclk_cntread),
    
    .HALTREQ           (refclk_counter_haltreq),
    .RESTARTREQ        (refclk_counter_restartreq),
    .RESTARTACK        (refclk_counter_restartack),
    
    .TSVALUEB           (tsvalueb),
    .TSFORCESYNC        ()
  );

  gtimer_control #(
    .TIMER0_FI (1'b1),          
    .TIMER1_FI (1'b1),          
    .TIMER2_FI (1'b1),          
    .TIMER3_FI (1'b1),          
    .TIMER4_FI (1'b0),          
    .TIMER5_FI (1'b0),          
    .TIMER6_FI (1'b0),          
    .TIMER7_FI (1'b0),          
    .TIMER0_FVI (1'b0),         
    .TIMER0_FPL0(1'b0),         
    .TIMER0_CFGBL_ACC(1'b0),    
    .TIMER0_NONSECURE(1'b1),    
    .TIMER1_FVI (1'b0),         
    .TIMER1_FPL0(1'b0),         
    .TIMER1_CFGBL_ACC(1'b0),    
    .TIMER1_NONSECURE(1'b1),    
    .TIMER2_FVI (1'b0),         
    .TIMER2_FPL0(1'b0),         
    .TIMER2_CFGBL_ACC(1'b0),    
    .TIMER2_NONSECURE(1'b1),    
    .TIMER3_FVI (1'b0),         
    .TIMER3_FPL0(1'b0),         
    .TIMER3_CFGBL_ACC(1'b0),    
    .TIMER3_NONSECURE(1'b1)     
 )
 u_refclk_cntctl (
    .PCLK          (refclk_sleep_gated),
    .PRESETn       (refclk_warmresetn),        
    
    .PSEL          (psel_refclk_cntctl),  
    .PADDR         (paddr[11:2]),
    .PENABLE       (penable),
    .PWRITE        (pwrite),
    .PPROT         (pprot),
    .PSTRB         (pstrb),
    .PWDATA        (pwdata),
    .PREADY        (pready_refclk_cntctl),
    .PRDATA        (prdata_refclk_cntctl),
    .PSLVERR       (pslverr_refclk_cntctl),
    
    .CNTACR0       (cntacr0_refclk),
    .CNTVOFF0      (cntvoff0_refclk),              
    .CNTACR1       (cntacr1_refclk),
    .CNTVOFF1      (cntvoff1_refclk),            
    .CNTACR2       (cntacr2_refclk),
    .CNTVOFF2      (cntvoff2_refclk),              
    .CNTACR3       (cntacr3_refclk),
    .CNTVOFF3      (cntvoff3_refclk),
    
    .CNTACR4       (),
    .CNTVOFF4      (),              
    .CNTACR5       (),
    .CNTVOFF5      (),            
    .CNTACR6       (),
    .CNTVOFF6      (),              
    .CNTACR7       (),
    .CNTVOFF7      (),
    
    
    .TIMER4FVIREG   (),
    .TIMER4FPL0REG  (),           
                     
    .TIMER5FVIREG   (),          
    .TIMER5FPL0REG  (),      
                     
    .TIMER6FVIREG   (),          
    .TIMER6FPL0REG  (),      
                     
    .TIMER7FVIREG   (),           
    .TIMER7FPL0REG  (),
    
    
    .TIMER0FVIREG   (timer0fvireg_refclk),
    .TIMER0FPL0REG  (timer0fpl0reg_refclk),           
                    
    .TIMER1FVIREG   (timer1fvireg_refclk),           
    .TIMER1FPL0REG  (timer1fpl0reg_refclk),      
                    
    .TIMER2FVIREG   (timer2fvireg_refclk),           
    .TIMER2FPL0REG  (timer2fpl0reg_refclk),      
                    
    .TIMER3FVIREG   (timer3fvireg_refclk),            
    .TIMER3FPL0REG  (timer3fpl0reg_refclk)

  );
  
  gtimer_syncapb u_refclk_cntbase0(
    .PCLK            (refclk_sleep_gated),
    .PRESETn         (refclk_warmresetn),       
    
    .TSVALUEB        (tsvalueb_in),
    
    .CNTACR          (cntacr0_refclk),
    .CNTVOFF         (cntvoff0_refclk),
    
    .GTIMERINTRPHYS  (refclk_cntbase0_intr),      
    .GTIMERINTRVIRT  (),      
    
    .PSELCNTBASEN    (psel_refclk_cntbase0),
    .PADDRCNTBASEN   (paddr[11:2]),
    .PENABLECNTBASEN (penable),
    .PWRITECNTBASEN  (pwrite),
    .PWDATACNTBASEN  (pwdata),
    .PREADYCNTBASEN  (pready_refclk_cntbase0),
    .PRDATACNTBASEN  (prdata_refclk_cntbase0),    
    .PSLVERRCNTBASEN (pslverr_refclk_cntbase0),    
    
    .PSELCNTPL0BASEN    (1'b0),  
    .PADDRCNTPL0BASEN   (10'd0),   
    .PENABLECNTPL0BASEN (1'b0),   
    .PWRITECNTPL0BASEN  (1'b0),   
    .PWDATACNTPL0BASEN  (32'd0),   
    .PREADYCNTPL0BASEN  (),   
    .PRDATACNTPL0BASEN  (),   
    .PSLVERRCNTPL0BASEN (),   
    
    .TIMERFVIREG        (timer0fvireg_refclk),
    .TIMERFPL0REG       (timer0fpl0reg_refclk)
  );
  
  gtimer_syncapb u_refclk_cntbase1(
    .PCLK            (refclk_sleep_gated),
    .PRESETn         (refclk_warmresetn),       
    
    .TSVALUEB        (tsvalueb_in),
    
    .CNTACR          (cntacr1_refclk),
    .CNTVOFF         (cntvoff1_refclk),
    
    .GTIMERINTRPHYS  (refclk_cntbase1_intr),      
    .GTIMERINTRVIRT  (),      
    
    .PSELCNTBASEN    (psel_refclk_cntbase1),
    .PADDRCNTBASEN   (paddr[11:2]),
    .PENABLECNTBASEN (penable),
    .PWRITECNTBASEN  (pwrite),
    .PWDATACNTBASEN  (pwdata),
    .PREADYCNTBASEN  (pready_refclk_cntbase1),
    .PRDATACNTBASEN  (prdata_refclk_cntbase1),    
    .PSLVERRCNTBASEN (pslverr_refclk_cntbase1),    
    
    .PSELCNTPL0BASEN    (1'b0),  
    .PADDRCNTPL0BASEN   (10'd0),   
    .PENABLECNTPL0BASEN (1'b0),   
    .PWRITECNTPL0BASEN  (1'b0),   
    .PWDATACNTPL0BASEN  (32'd0),   
    .PREADYCNTPL0BASEN  (),   
    .PRDATACNTPL0BASEN  (),   
    .PSLVERRCNTPL0BASEN (),   
    
    .TIMERFVIREG        (timer1fvireg_refclk),
    .TIMERFPL0REG       (timer1fpl0reg_refclk)
  );
  
  gtimer_syncapb u_refclk_cntbase2(
    .PCLK            (refclk_sleep_gated),
    .PRESETn         (refclk_warmresetn),       
    
    .TSVALUEB        (tsvalueb_in),
    
    .CNTACR          (cntacr2_refclk),
    .CNTVOFF         (cntvoff2_refclk),
    
    .GTIMERINTRPHYS  (refclk_cntbase2_intr),      
    .GTIMERINTRVIRT  (),      
    
    .PSELCNTBASEN    (psel_refclk_cntbase2),
    .PADDRCNTBASEN   (paddr[11:2]),
    .PENABLECNTBASEN (penable),
    .PWRITECNTBASEN  (pwrite),
    .PWDATACNTBASEN  (pwdata),
    .PREADYCNTBASEN  (pready_refclk_cntbase2),
    .PRDATACNTBASEN  (prdata_refclk_cntbase2),    
    .PSLVERRCNTBASEN (pslverr_refclk_cntbase2),    
    
    .PSELCNTPL0BASEN    (1'b0),  
    .PADDRCNTPL0BASEN   (10'd0),   
    .PENABLECNTPL0BASEN (1'b0),   
    .PWRITECNTPL0BASEN  (1'b0),   
    .PWDATACNTPL0BASEN  (32'd0),   
    .PREADYCNTPL0BASEN  (),   
    .PRDATACNTPL0BASEN  (),   
    .PSLVERRCNTPL0BASEN (),   
    
    .TIMERFVIREG        (timer2fvireg_refclk),
    .TIMERFPL0REG       (timer2fpl0reg_refclk)
  );
  
  gtimer_syncapb u_refclk_cntbase3(
    .PCLK            (refclk_sleep_gated),
    .PRESETn         (refclk_warmresetn),       
    
    .TSVALUEB        (tsvalueb_in),
    
    .CNTACR          (cntacr3_refclk),
    .CNTVOFF         (cntvoff3_refclk),
    
    .GTIMERINTRPHYS  (refclk_cntbase3_intr),      
    .GTIMERINTRVIRT  (),      
    
    .PSELCNTBASEN    (psel_refclk_cntbase3),
    .PADDRCNTBASEN   (paddr[11:2]),
    .PENABLECNTBASEN (penable),
    .PWRITECNTBASEN  (pwrite),
    .PWDATACNTBASEN  (pwdata),
    .PREADYCNTBASEN  (pready_refclk_cntbase3),
    .PRDATACNTBASEN  (prdata_refclk_cntbase3),    
    .PSLVERRCNTBASEN (pslverr_refclk_cntbase3),    
    
    .PSELCNTPL0BASEN    (1'b0),  
    .PADDRCNTPL0BASEN   (10'd0),   
    .PENABLECNTPL0BASEN (1'b0),   
    .PWRITECNTPL0BASEN  (1'b0),   
    .PWDATACNTPL0BASEN  (32'd0),   
    .PREADYCNTPL0BASEN  (),   
    .PRDATACNTPL0BASEN  (),   
    .PSLVERRCNTPL0BASEN (),   
    
    .TIMERFVIREG        (timer3fvireg_refclk),
    .TIMERFPL0REG       (timer3fpl0reg_refclk)
  );
 
  
  assign pslverr_ns_wdog = 1'b0;
  
  generic_wdog 
  #(
    .NONSECURE (1'b1)
  )
  u_ns_wdog
  (
    .clk            (refclk_sleep_gated),
    .reset_n        (refclk_warmresetn),         
    .tsvalueb       (tsvalueb_in), 
    
    .intr({ns_wdog_intr_second,ns_wdog_intr_first}),
    
    .prdata         (prdata_ns_wdog),
    .pready         (pready_ns_wdog),  
                            
    .penable        (penable),
    .psel           (psel_ns_wdog),
    .paddr          (paddr[16:0]),
    .pwrite         (pwrite), 
    .pwdata         (pwdata),
    .pstrb          (pstrb),
    .pprot          (pprot)
  );

  assign pslverr_secure_wdog = 1'b0;
  
  generic_wdog 
  #(
    .NONSECURE (1'b0)
  )
  u_secure_wdog
  (
    .clk            (refclk_sleep_gated),
    .reset_n        (refclk_warmresetn),         
    .tsvalueb       (tsvalueb_in), 
    
    .intr({secure_wdog_intr_second,secure_wdog_intr_first}),
    
    .prdata         (prdata_secure_wdog),
    .pready         (pready_secure_wdog),  
                            
    .penable        (penable),
    .psel           (psel_secure_wdog),
    .paddr          (paddr[16:0]),
    .pwrite         (pwrite), 
    .pwdata         (pwdata),
    .pstrb          (pstrb),
    .pprot          (pprot)
  );

                                                   
  
  wire s32k_counter_haltreq;
  css600_pulseasyncbridgemstr #(
            .WIDTH(1)           
  )
  u_css600_pulseasyncbridgeslv_s32kcounter
  (
      .clk_m          (s32kclk),                     
      .reset_m_n      (s32kresetn),
      .pulse_out      (s32k_counter_haltreq  ),
      .pulse_req      (s32k_counter_haltreqreq),
      .pulse_ack      (s32k_counter_haltreqack),
      .clk_m_qreq_n    (1'b1),
      .clk_m_qaccept_n  ()  ,
      .clk_m_qactive    ()  
      
   );
  
  gcounter_asyncapb u_s32k_gcounter(
    .CCLK        (s32kclk),
    .CRESETn     (s32kresetn),
    .PCLK        (refclk_sleep_gated),
    .PRESETn     (refclk_warmresetn),
    
    .PSELCNTCONTROL    (psel_s32k_cntcontrol),
    .PADDRCNTCONTROL   (paddr[11:2]),
    .PENABLECNTCONTROL (penable),
    .PWRITECNTCONTROL  (pwrite),
    .PWDATACNTCONTROL  (pwdata),
    .PREADYCNTCONTROL  (pready_s32k_cntcontrol),
    .PRDATACNTCONTROL  (prdata_s32k_cntcontrol),
    .PSLVERRCNTCONTROL (pslverr_s32k_cntcontrol),
    
    .PSELCNTREAD       (psel_s32k_cntread),
    .PADDRCNTREAD      (paddr[11:2]),
    .PENABLECNTREAD    (penable),
    .PWRITECNTREAD     (pwrite),
    .PWDATACNTREAD     (pwdata),
    .PREADYCNTREAD     (pready_s32k_cntread),
    .PRDATACNTREAD     (prdata_s32k_cntread),
    .PSLVERRCNTREAD    (pslverr_s32k_cntread),
    
    .HALTREQ           (s32k_counter_haltreq),
    .RESTARTREQ        (s32k_counter_restartreq),
    .RESTARTACK        (s32k_counter_restartack),
    
    .TSVALUEB           (tsvalueb_s32k),
    .TSFORCESYNC        ()
  );

  gtimer_control #(
    .TIMER0_FI (1'b1),
    .TIMER1_FI (1'b1),
    .TIMER2_FI (1'b0),
    .TIMER3_FI (1'b0),
    .TIMER4_FI (1'b0),
    .TIMER5_FI (1'b0),     
    .TIMER6_FI (1'b0),
    .TIMER7_FI (1'b0),
    .TIMER0_FVI (1'b0),         
    .TIMER0_FPL0(1'b0),         
    .TIMER0_CFGBL_ACC(1'b0),    
    .TIMER0_NONSECURE(1'b1),    
    .TIMER1_FVI (1'b0),         
    .TIMER1_FPL0(1'b0),         
    .TIMER1_CFGBL_ACC(1'b0),    
    .TIMER1_NONSECURE(1'b1)     
  
 )
 u_s32k_cntctl (
    .PCLK          (refclk_sleep_gated),
    .PRESETn       (refclk_warmresetn),      
    
    .PSEL          (psel_s32k_cntctl),  
    .PADDR         (paddr[11:2]),
    .PENABLE       (penable),
    .PWRITE        (pwrite),
    .PPROT         (pprot),
    .PSTRB         (pstrb),
    .PWDATA        (pwdata),
    .PREADY        (pready_s32k_cntctl),
    .PRDATA        (prdata_s32k_cntctl),
    .PSLVERR       (pslverr_s32k_cntctl),
    
    .CNTACR0       (cntacr0_s32k),
    .CNTVOFF0      (cntvoff0_s32k),              
    .CNTACR1       (cntacr1_s32k),
    .CNTVOFF1      (cntvoff1_s32k),            
    
    .TIMER0FVIREG   (),
    .TIMER0FPL0REG  (),           
                    
    .TIMER1FVIREG   (),           
    .TIMER1FPL0REG  (),
    
    .CNTACR2       (),
    .CNTVOFF2      (),              
    .CNTACR3       (),
    .CNTVOFF3      (),              
    
    .CNTACR4       (),
    .CNTVOFF4      (),              
    .CNTACR5       (),
    .CNTVOFF5      (),            
    .CNTACR6       (),
    .CNTVOFF6      (),              
    .CNTACR7       (),
    .CNTVOFF7      (),
    
    
    .TIMER2FVIREG   (),
    .TIMER2FPL0REG  (),           
            
    .TIMER3FVIREG   (),
    .TIMER3FPL0REG  (),           
            
    .TIMER4FVIREG   (),
    .TIMER4FPL0REG  (),           
                     
    .TIMER5FVIREG   (),          
    .TIMER5FPL0REG  (),      
                     
    .TIMER6FVIREG   (),          
    .TIMER6FPL0REG  (),      
                     
    .TIMER7FVIREG   (),           
    .TIMER7FPL0REG  ()
    

  );
  
  gtimer_asyncapb u_s32k_cntbase0(
    .CCLK        (s32kclk),
    .CRESETn     (s32kresetn),
    .PCLK        (refclk_sleep_gated),
    .PRESETn     (refclk_warmresetn),
     
    .TSVALUEB        (tsvalueb_s32k_in),
    
    .CNTACR          (cntacr0_s32k),
    .CNTVOFF         (cntvoff0_s32k),
    
    .GTIMERINTRPHYS  (s32k_cntbase0_intr),      
    .GTIMERINTRVIRT  (),      
    
    .PSELCNTBASEN    (psel_s32k_cntbase0),
    .PADDRCNTBASEN   (paddr[11:2]),
    .PENABLECNTBASEN (penable),
    .PWRITECNTBASEN  (pwrite),
    .PWDATACNTBASEN  (pwdata),
    .PREADYCNTBASEN  (pready_s32k_cntbase0),
    .PRDATACNTBASEN  (prdata_s32k_cntbase0),    
    .PSLVERRCNTBASEN (pslverr_s32k_cntbase0),    
    
    .PSELCNTPL0BASEN    (1'b0),  
    .PADDRCNTPL0BASEN   (10'd0),   
    .PENABLECNTPL0BASEN (1'b0),   
    .PWRITECNTPL0BASEN  (1'b0),   
    .PWDATACNTPL0BASEN  (32'd0),   
    .PREADYCNTPL0BASEN  (),   
    .PRDATACNTPL0BASEN  (),   
    .PSLVERRCNTPL0BASEN (),   
    
    .TIMERFVIREG        (1'b0),
    .TIMERFPL0REG       (1'b0)
  );
  
  gtimer_asyncapb u_s32k_cntbase1(
    .PCLK        (refclk_sleep_gated),
    .PRESETn     (refclk_warmresetn),
    .CCLK        (s32kclk),
    .CRESETn     (s32kresetn),
    
    .TSVALUEB        (tsvalueb_s32k_in),
    
    .CNTACR          (cntacr1_s32k),
    .CNTVOFF         (cntvoff1_s32k),
    
    .GTIMERINTRPHYS  (s32k_cntbase1_intr),      
    .GTIMERINTRVIRT  (),      
    
    .PSELCNTBASEN    (psel_s32k_cntbase1),
    .PADDRCNTBASEN   (paddr[11:2]),
    .PENABLECNTBASEN (penable),
    .PWRITECNTBASEN  (pwrite),
    .PWDATACNTBASEN  (pwdata),
    .PREADYCNTBASEN  (pready_s32k_cntbase1),
    .PRDATACNTBASEN  (prdata_s32k_cntbase1),    
    .PSLVERRCNTBASEN (pslverr_s32k_cntbase1),    
    
    .PSELCNTPL0BASEN    (1'b0),  
    .PADDRCNTPL0BASEN   (10'd0),   
    .PENABLECNTPL0BASEN (1'b0),   
    .PWRITECNTPL0BASEN  (1'b0),   
    .PWDATACNTPL0BASEN  (32'd0),   
    .PREADYCNTPL0BASEN  (),   
    .PRDATACNTPL0BASEN  (),   
    .PSLVERRCNTPL0BASEN (),   
    
    .TIMERFVIREG        (1'b0),
    .TIMERFPL0REG       (1'b0)
  );
  
  system_id #(
     .IIDR_PRODUCT_ID           (IIDR_PRODUCT_ID    ),
     .IIDR_VARIANT_ID           (IIDR_VARIANT_ID    ),
     .IIDR_REVISION             (IIDR_REVISION      ),
     .IIDR_IMPLEMENTER          (IIDR_IMPLEMENTER   )    
  )
     u_system_id 
  (    
    .clk(refclk_int_gated),
    .resetn(refclk_warmresetn),
    
    .penable  (penable),   
    .paddr    (paddr[11:0]),
    .psel     (psel_system_id),
    .pready   (pready_system_id),
    .prdata   (prdata_system_id),
    .pslverr  (pslverr_system_id),
    
  
     .bsys_cfg0_num_host_cpu    (4'd4),
     .bsys_cfg1_ext_sys3        (4'd0),
     .bsys_cfg1_ext_sys2        (4'd0),
     .bsys_cfg1_ext_sys1        (4'd3),
     .bsys_cfg1_ext_sys0        (4'd3),
     .bsys_cfg2_num_exp_mst     (4'd2),
     .bsys_cfg2_num_exp_slv     (4'd2),   
     .bsys_cfg2_ocvm_en         (1'd1), 
     .soc_id_product_id         (soc_id_product_id  ),
     .soc_id_variant_id         (soc_id_variant_id  ),
     .soc_id_revision           (soc_id_revision    ),
     .soc_id_implementer        ({soc_id_implementer[10:7],1'b0,soc_id_implementer[6:0]} )
     
  
  );
  wire pll_st_sysplllock_st_ss;
  wire pll_st_cpuplllock_st_ss;
  
  
  
  
  
  
    
  
  
  
  assign pe3_rvbaraddr_up_rvbar43_32 = 12'd0;
  assign pe2_rvbaraddr_up_rvbar43_32 = 12'd0;
  assign pe1_rvbaraddr_up_rvbar43_32 = 12'd0;
  assign pe0_rvbaraddr_up_rvbar43_32 = 12'd0;
  
  host_control #(
    .HOST_CPU_NUM_CORES(HOST_CPU_NUM_CORES)
  )
  u_host_control 
  (
    .clk(refclk_sleep_gated),
    .resetn(refclk_warmresetn),    
    .extsys0_cpuwait_wen (extsys0_cpuwait_wen),
    .extsys1_cpuwait_wen (extsys1_cpuwait_wen),
        
    .host_cpu_wake_up_core3_wakeup(host_cpu_wake_up[3]),
    .host_cpu_wake_up_core2_wakeup(host_cpu_wake_up[2]),
    .host_cpu_wake_up_core1_wakeup(host_cpu_wake_up[1]),
    .host_cpu_wake_up_core0_wakeup(host_cpu_wake_up[0]),
    .penable  (penable),   
    .paddr    (paddr[11:0]),
    .pwrite   (pwrite),
    .pwdata   (pwdata),    
    .psel     (psel_host_chassis_control),
    .pready   (pready_host_chassis_control),
    .prdata   (prdata_host_chassis_control),
    .pslverr  (pslverr_host_chassis_control),
    
    .cluster_config_cryptodisable       (cluster_config_cryptodisable),
    .pe0_config_aa64naa32               (pe0_config_aa64naa32        ),
    .pe0_config_vinithi                 (pe0_config_vinithi          ),
    .pe0_config_cfgte                   (pe0_config_cfgte            ),
    .pe0_config_cfgend                  (pe0_config_cfgend           ),
    .pe0_rvbaraddr_lw_rvbar31_2         (pe0_rvbaraddr_lw_rvbar31_2  ),
    .pe0_rvbaraddr_up_rvbar43_32        (pe0_rvbaraddr_up_rvbar43_32 ),
    .pe1_config_aa64naa32               (pe1_config_aa64naa32        ),
    .pe1_config_vinithi                 (pe1_config_vinithi          ),
    .pe1_config_cfgte                   (pe1_config_cfgte            ),
    .pe1_config_cfgend                  (pe1_config_cfgend           ),
    .pe1_rvbaraddr_lw_rvbar31_2         (pe1_rvbaraddr_lw_rvbar31_2  ),
    .pe1_rvbaraddr_up_rvbar43_32        (pe1_rvbaraddr_up_rvbar43_32 ),
    .pe2_config_aa64naa32               (pe2_config_aa64naa32        ),
    .pe2_config_vinithi                 (pe2_config_vinithi          ),
    .pe2_config_cfgte                   (pe2_config_cfgte            ),
    .pe2_config_cfgend                  (pe2_config_cfgend           ),
    .pe2_rvbaraddr_lw_rvbar31_2         (pe2_rvbaraddr_lw_rvbar31_2  ),
    .pe2_rvbaraddr_up_rvbar43_32        (pe2_rvbaraddr_up_rvbar43_32 ),
    .pe3_config_aa64naa32               (pe3_config_aa64naa32        ),
    .pe3_config_vinithi                 (pe3_config_vinithi          ),
    .pe3_config_cfgte                   (pe3_config_cfgte            ),
    .pe3_config_cfgend                  (pe3_config_cfgend           ),
    .pe3_rvbaraddr_lw_rvbar31_2         (pe3_rvbaraddr_lw_rvbar31_2  ),
    .pe3_rvbaraddr_up_rvbar43_32        (pe3_rvbaraddr_up_rvbar43_32 ),
    
    .host_rst_syn_syn                   (host_rst_syn              ),
    .host_cpu_boot_msk_boot_msk         (host_cpu_boot_msk_boot_msk     ),
    .host_cpu_clus_pwr_req_mem_ret_req  (host_cpu_clus_pwr_req_mem_ret_r),
    .host_cpu_clus_pwr_req_pwr_req      (host_cpu_clus_pwr_req_pwr_req  ),
    .ext_sys0_rst_st_rst_ack            (ext_sys0_rst_st_rst_ack),
    .ext_sys0_rst_ctrl_rst_req          (ext_sys0_rst_ctrl_rst_req),
    .ext_sys0_rst_ctrl_cpuwait          (ext_sys0_rst_ctrl_cpuwait),
    .set_extsys0_cpuwait                (set_extsys0_cpuwait      ),

    .ext_sys1_rst_st_rst_ack            (ext_sys1_rst_st_rst_ack),
    .ext_sys1_rst_ctrl_rst_req          (ext_sys1_rst_ctrl_rst_req),
    .ext_sys1_rst_ctrl_cpuwait          (ext_sys1_rst_ctrl_cpuwait),
    .set_extsys1_cpuwait                (set_extsys1_cpuwait      ),

    .bsys_pwr_req_systop_pwr_req        (host_bsys_pwr_req_systop_pwr_req),
    .bsys_pwr_req_dbgtop_pwr_req        (host_bsys_pwr_req_dbgtop_pwr_req),
    .bsys_pwr_req_refclk_req            (bsys_pwr_req_refclk_req        ),
    .bsys_pwr_req_wakeup_en             (bsys_pwr_req_wakeup_en         ),
    .bsys_pwr_st_systop_pwr_st          (bsys_pwr_st_systop_pwr_st      ),
    .bsys_pwr_st_dbgtop_pwr_st          (bsys_pwr_st_dbgtop_pwr_st      ),
    .hostcpuclk_ctrl_clkselect_cur      (hostcpuclk_ctrl_clkselect_cur  ),
    .hostcpuclk_ctrl_clkselect          (hostcpuclk_ctrl_clkselect      ),
    .hostcpuclk_div0_clkdiv_cur         (hostcpuclk_div0_clkdiv_cur     ),
    
    .hostcpuclk_div0_clkdiv             (hostcpuclk_div0_clkdiv         ),
    .hostcpuclk_div1_clkdiv_cur         (hostcpuclk_div1_clkdiv_cur     ),
    
    .hostcpuclk_div1_clkdiv             (hostcpuclk_div1_clkdiv         ),
    .gicclk_ctrl_clkselect_cur          (gicclk_ctrl_clkselect_cur      ),
    .gicclk_ctrl_clkselect              (gicclk_ctrl_clkselect          ),
    .gicclk_div0_clkdiv_cur             (gicclk_div0_clkdiv_cur         ),
    .gicclk_div0_clkdiv                 (gicclk_div0_clkdiv             ),
    .aclk_ctrl_clkselect_cur            (aclk_ctrl_clkselect_cur        ),
    .aclk_ctrl_clkselect                (aclk_ctrl_clkselect            ),
    .aclk_div0_clkdiv_cur               (aclk_div0_clkdiv_cur           ),
    
    .aclk_div0_clkdiv                   (aclk_div0_clkdiv               ),
    .ctrlclk_ctrl_clkselect_cur         (ctrlclk_ctrl_clkselect_cur     ),
    .ctrlclk_ctrl_clkselect             (ctrlclk_ctrl_clkselect         ),
    .ctrlclk_div0_clkdiv_cur            (ctrlclk_div0_clkdiv_cur        ),
    .ctrlclk_div0_clkdiv                (ctrlclk_div0_clkdiv            ),
    .dbgclk_ctrl_clkselect_cur          (dbgclk_ctrl_clkselect_cur      ),
    .dbgclk_ctrl_clkselect              (dbgclk_ctrl_clkselect          ),
    .dbgclk_div0_clkdiv_cur             (dbgclk_div0_clkdiv_cur         ),
    .dbgclk_div0_clkdiv                 (dbgclk_div0_clkdiv             ),
    .hostuartclk_ctrl_clkselect_cur      (hostuartclk_ctrl_clkselect_cur      ),
    .hostuartclk_ctrl_clkselect          (hostuartclk_ctrl_clkselect          ),
    .hostuartclk_div0_clkdiv_cur         (hostuartclk_div0_clkdiv_cur         ),
    .hostuartclk_div0_clkdiv             (hostuartclk_div0_clkdiv             ),
    
    .clkforce_st_dbgclk_force_st        (clkforce_st_dbgclk_force_st_int    ),
    .clkforce_st_ctrlclk_force_st       (clkforce_st_ctrlclk_force_st_int   ),
    .clkforce_st_aclk_force_st          (clkforce_st_aclk_force_st_int      ),
    .clkforce_st_gicclk_force_st        (clkforce_st_gicclk_force_st_int    ),
    .clkforce_st_refclk_force_st        (clkforce_st_refclk_force_st_int    ),
    .pll_st_cpuplllock_st               (pll_st_cpuplllock_st_ss        ),
    .pll_st_sysplllock_st               (pll_st_sysplllock_st_ss        ),
    .host_ppu_int_st_core3_int_st       (host_ppu_int_st_core3_int_st   ),
    .host_ppu_int_st_core2_int_st       (host_ppu_int_st_core2_int_st   ),
    .host_ppu_int_st_core1_int_st       (host_ppu_int_st_core1_int_st   ),
    .host_ppu_int_st_core0_int_st       (host_ppu_int_st_core0_int_st   ),
    .host_ppu_int_st_clustop_int_st     (host_ppu_int_st_clustop_int_st ),
    .host_ppu_int_st_systop_int_st      (host_ppu_int_st_systop_int_st  ),
    .host_ppu_int_st_dbgtop_int_st      (host_ppu_int_st_dbgtop_int_st  ),
    .host_ppu_int_st_fw_int_st          (host_ppu_int_st_fw_int_st      ),    
    .host_sys_lctrl_st_int_rtr_lock     (host_sys_lctrl_int_rtr_lock    ),
    .host_sys_lctrl_st_host_fw_lock     (host_sys_lctrl_host_fw_lock    ),
    .gicclk_ctrl_entrydelay             (gicclk_ctrl_entrydelay    ),
    .aclk_ctrl_entrydelay               (aclk_ctrl_entrydelay      ),
    .ctrlclk_ctrl_entrydelay            (ctrlclk_ctrl_entrydelay   ),
    .refclk_ctrl_entrydelay             (refclk_ctrl_entrydelay   ),
    .dbgclk_ctrl_entrydelay             (dbgclk_ctrl_entrydelay    ),        
        
    .modify_lock_req                    (modify_lock_req),
    .modify_lock_ack                    (modify_lock_ack),
    .host_lock_cpu                      (host_lock)
  
  );
  
  
  assign  pready_aon_expansion_intf  = pready_aon_expansion;
  assign  prdata_aon_expansion_intf  = prdata_aon_expansion;
  assign  pslverr_aon_expansion_intf = pslverr_aon_expansion;  
  assign psel_aon_expansion    = psel_aon_expansion_intf;
  assign penable_aon_expansion = penable;
  assign paddr_aon_expansion   = paddr;
  assign pwrite_aon_expansion  = pwrite;
  assign pwdata_aon_expansion  = pwdata;
  assign pstrb_aon_expansion   = pstrb;
  assign pprot_aon_expansion   = pprot;
  assign pwakeup_aon_expansion = pwakeup;
  assign pclk_aon_expansion    = refclk_sleep_gated;

  
  wire fw_unused;
  assign fw_unused = (|fwctrl_awaddr[31:21]) | 
                     (|fwctrl_araddr[31:21]) |
                     (|fwctrl_aruser[1:0])   |
                     (|fwctrl_awuser[1:0]);
    
    adb400_r3_axi4_stream_slv
    #(
      .DATA_WIDTH       (32),
      .STRB_WIDTH       (0),
      .KEEP_WIDTH       (4),
      .LAST_WIDTH       (4),
      .ID_WIDTH         (4),
      .DEST_WIDTH       (4),
      .USER_WIDTH       (0),
      .FIFO_DEPTH       (FCTRLCFG_DN_FIFO_DEPTH_DBGTOP),
      .SI_SYNC_LEVELS   (2)
    )
  u_a4s_dbgtop_slv
    (
      .pwrq_permit_deny_sar_i  (1'b1),

      .pwrqreqns_i             (fctrlcfg_dbgtop_up_pwrqreqn),
      .pwrqacceptns_o          (fctrlcfg_dbgtop_up_pwrqacceptn),
      .pwrqdenys_o             (fctrlcfg_dbgtop_up_pwrqdeny),

      .aclks                   (refclk_int_gated),
      .aresetns                (refclk_warmresetn),

      .dftrstdisables          (dftrstdisable[1]),

      .clkqreqns_i             (fctrlcfg_dbgtop_up_clkqreqn),
      .clkqacceptns_o          (fctrlcfg_dbgtop_up_clkqacceptn),
      .clkqdenys_o             (fctrlcfg_dbgtop_up_clkqdeny),
      .clkqactives_o           (fctrlcfg_dbgtop_up_clkqactive),
      .pwrqactives_o           (fctrlcfg_dbgtop_up_pwrqactive),
      .wakeups_i               (fctrlcfg_dbgtop_up_wakeup),

      .tvalids                 (fctrlcfg_dbgtop_up_tvalid),
      .treadys                 (fctrlcfg_dbgtop_up_tready),
      .tdatas                  (fctrlcfg_dbgtop_up_tdata),
      .tstrbs                  (1'b1), 
      .tkeeps                  (fctrlcfg_dbgtop_up_tkeep),
      .tlasts                  (fctrlcfg_dbgtop_up_tlast),
      .tids                    (4'd0), 
      .tdests                  (fctrlcfg_dbgtop_up_tdest),
      .tusers                  (1'b0),

      .slvmustacceptreqn_async (fctrlcfg_dbgtop_up_slvmustacceptreqn_async),
      .slvcandenyreqn_async    (fctrlcfg_dbgtop_up_slvcandenyreqn_async),
      .slvacceptn_async        (fctrlcfg_dbgtop_up_slvacceptn_async),
      .slvdeny_async           (fctrlcfg_dbgtop_up_slvdeny_async),

      .si_to_mi_wakeup_async   (fctrlcfg_dbgtop_up_si_to_mi_wakeup_async),
      .mi_to_si_wakeup_async   (fctrlcfg_dbgtop_up_mi_to_si_wakeup_async),
                                
      .wr_ptr_async            (fctrlcfg_dbgtop_up_wr_ptr_async),
      .rd_ptr_async            (fctrlcfg_dbgtop_up_rd_ptr_async),
      .payld_async             (fctrlcfg_dbgtop_up_payld_async)
    );

    
    
    sse710_adb400_r3_axi4_stream_mst_wrapper
    #(
      .DATA_WIDTH       (32),
      .STRB_WIDTH       (0),
      .KEEP_WIDTH       (4),
      .LAST_WIDTH       (4),
      .ID_WIDTH         (4),
      .DEST_WIDTH       (4),
      .USER_WIDTH       (0),
      .FIFO_DEPTH       (FCTRLCFG_UP_FIFO_DEPTH_DBGTOP),
      .OPREG            (1),
      .MI_SYNC_LEVELS   (2),
      .PAYLOAD_WIDTH    (FCTRLCFG_DN_PAYLD_LEN_DBGTOP)
    )
  u_sse710_adb400_r3_axi4_stream_mst_wrapper_dbgtop
    (
      .aclkm                   (refclk_int_gated),
      .aresetnm                (refclk_warmresetn),

      .dftrstdisablem          (dftrstdisable[1]),

      .clkqreqnm_i             (fctrlcfg_dbgtop_dn_clkqreqn),
      .clkqacceptnm_o          (fctrlcfg_dbgtop_dn_clkqacceptn),
      .clkqdenym_o             (fctrlcfg_dbgtop_dn_clkqdeny),
      .clkqactivem_o           (fctrlcfg_dbgtop_dn_clkqactive),
      .wakeupm_o               (fctrlcfg_dbgtop_dn_wakeup),

      .tvalidm                 (fctrlcfg_dbgtop_dn_tvalid),
      .treadym                 (fctrlcfg_dbgtop_dn_tready),
      .tdatam                  (fctrlcfg_dbgtop_dn_tdata),
      .tstrbm                  (), 
      .tkeepm                  (fctrlcfg_dbgtop_dn_tkeep),
      .tlastm                  (fctrlcfg_dbgtop_dn_tlast),
      .tidm                    (fctrlcfg_dbgtop_dn_tid),
      .tdestm                  (),
      .tuserm                  (),

      .slvmustacceptreqn_async (fctrlcfg_dbgtop_dn_slvmustacceptreqn_async),
      .slvcandenyreqn_async    (fctrlcfg_dbgtop_dn_slvcandenyreqn_async),
      .slvacceptn_async        (fctrlcfg_dbgtop_dn_slvacceptn_async),
      .slvdeny_async           (fctrlcfg_dbgtop_dn_slvdeny_async),

      .si_to_mi_wakeup_async   (fctrlcfg_dbgtop_dn_si_to_mi_wakeup_async),
      .mi_to_si_wakeup_async   (fctrlcfg_dbgtop_dn_mi_to_si_wakeup_async),

      .wr_ptr_async            (fctrlcfg_dbgtop_dn_wr_ptr_async),
      .rd_ptr_async            (fctrlcfg_dbgtop_dn_rd_ptr_async),
      .payld_async             (fctrlcfg_dbgtop_dn_payld_async)
    );

  adb400_r3_axi4_stream_slv
    #(
      .DATA_WIDTH       (32),                       
      .STRB_WIDTH       (0),
      .KEEP_WIDTH       (4),
      .LAST_WIDTH       (4),
      .ID_WIDTH         (4),
      .DEST_WIDTH       (4),
      .USER_WIDTH       (0),
      .FIFO_DEPTH       (FCTRLCFG_DN_FIFO_DEPTH_SYSTOP),
      .SI_SYNC_LEVELS   (2)
    )
  u_a4s_systop_slv
    (
      .pwrq_permit_deny_sar_i  (1'b1),

      .pwrqreqns_i             (fctrlcfg_systop_up_pwrqreqn),
      .pwrqacceptns_o          (fctrlcfg_systop_up_pwrqacceptn),
      .pwrqdenys_o             (fctrlcfg_systop_up_pwrqdeny),

      .aclks                   (refclk_int_gated),
      .aresetns                (refclk_warmresetn),

      .dftrstdisables          (dftrstdisable[1]),

      .clkqreqns_i             (fctrlcfg_systop_up_clkqreqn),
      .clkqacceptns_o          (fctrlcfg_systop_up_clkqacceptn),
      .clkqdenys_o             (fctrlcfg_systop_up_clkqdeny),
      .clkqactives_o           (fctrlcfg_systop_up_clkqactive),
      .pwrqactives_o           (fctrlcfg_systop_up_pwrqactive),
      .wakeups_i               (fctrlcfg_systop_up_wakeup),

      .tvalids                 (fctrlcfg_systop_up_tvalid),
      .treadys                 (fctrlcfg_systop_up_tready),
      .tdatas                  (fctrlcfg_systop_up_tdata),
      .tstrbs                  (1'b1), 
      .tkeeps                  (fctrlcfg_systop_up_tkeep),
      .tlasts                  (fctrlcfg_systop_up_tlast),
      .tids                    (4'd0), 
      .tdests                  (fctrlcfg_systop_up_tdest),
      .tusers                  (1'b0),

      .slvmustacceptreqn_async (fctrlcfg_systop_up_slvmustacceptreqn_async),
      .slvcandenyreqn_async    (fctrlcfg_systop_up_slvcandenyreqn_async),
      .slvacceptn_async        (fctrlcfg_systop_up_slvacceptn_async),
      .slvdeny_async           (fctrlcfg_systop_up_slvdeny_async),

      .si_to_mi_wakeup_async   (fctrlcfg_systop_up_si_to_mi_wakeup_async),
      .mi_to_si_wakeup_async   (fctrlcfg_systop_up_mi_to_si_wakeup_async),
                                
      .wr_ptr_async            (fctrlcfg_systop_up_wr_ptr_async),
      .rd_ptr_async            (fctrlcfg_systop_up_rd_ptr_async),
      .payld_async             (fctrlcfg_systop_up_payld_async)
    );

    sse710_adb400_r3_axi4_stream_mst_wrapper
    #(
      .DATA_WIDTH       (32),
      .STRB_WIDTH       (0),
      .KEEP_WIDTH       (4),
      .LAST_WIDTH       (4),
      .ID_WIDTH         (4),
      .DEST_WIDTH       (4),
      .USER_WIDTH       (0),
      .FIFO_DEPTH       (FCTRLCFG_UP_FIFO_DEPTH_SYSTOP),
      .OPREG            (1),
      .MI_SYNC_LEVELS   (2),
      .PAYLOAD_WIDTH    (FCTRLCFG_DN_PAYLD_LEN_SYSTOP)
    )
  u_sse710_adb400_r3_axi4_stream_mst_wrapper_systop
    (
      .aclkm                   (refclk_int_gated),
      .aresetnm                (refclk_warmresetn),

      .dftrstdisablem          (dftrstdisable[1]),

      .clkqreqnm_i             (fctrlcfg_systop_dn_clkqreqn),
      .clkqacceptnm_o          (fctrlcfg_systop_dn_clkqacceptn),
      .clkqdenym_o             (fctrlcfg_systop_dn_clkqdeny),
      .clkqactivem_o           (fctrlcfg_systop_dn_clkqactive),
      .wakeupm_o               (fctrlcfg_systop_dn_wakeup),

      .tvalidm                 (fctrlcfg_systop_dn_tvalid),
      .treadym                 (fctrlcfg_systop_dn_tready),
      .tdatam                  (fctrlcfg_systop_dn_tdata),
      .tstrbm                  (), 
      .tkeepm                  (fctrlcfg_systop_dn_tkeep),
      .tlastm                  (fctrlcfg_systop_dn_tlast),
      .tidm                    (fctrlcfg_systop_dn_tid),
      .tdestm                  (),
      .tuserm                  (),

      .slvmustacceptreqn_async (fctrlcfg_systop_dn_slvmustacceptreqn_async),
      .slvcandenyreqn_async    (fctrlcfg_systop_dn_slvcandenyreqn_async),
      .slvacceptn_async        (fctrlcfg_systop_dn_slvacceptn_async),
      .slvdeny_async           (fctrlcfg_systop_dn_slvdeny_async),

      .si_to_mi_wakeup_async   (fctrlcfg_systop_dn_si_to_mi_wakeup_async),
      .mi_to_si_wakeup_async   (fctrlcfg_systop_dn_mi_to_si_wakeup_async),

      .wr_ptr_async            (fctrlcfg_systop_dn_wr_ptr_async),
      .rd_ptr_async            (fctrlcfg_systop_dn_rd_ptr_async),
      .payld_async             (fctrlcfg_systop_dn_payld_async)
        );
        

  
  sse710_adb400_r3_axi4_mst_wrapper
    #(    
      .ADDR_WIDTH       (FCTRLPROG_ADDR_WIDTH),   
      .DATA_WIDTH       (FCTRLPROG_DATA_WIDTH),   
      .AWID_WIDTH       (FCTRLPROG_AWID_WIDTH),   
      .ARID_WIDTH       (FCTRLPROG_ARID_WIDTH),   
      .AWUSER_WIDTH     (FCTRLPROG_AWUSER_WIDTH),
      .ARUSER_WIDTH     (FCTRLPROG_ARUSER_WIDTH), 
      .WUSER_WIDTH      (0),
      .BUSER_WIDTH      (FCTRLPROG_BUSER_WIDTH),   
      .RUSER_WIDTH      (FCTRLPROG_RUSER_WIDTH),  
      .AW_FIFO_DEPTH    (FCTRLPROG_AW_FIFO_DEPTH),
      .W_FIFO_DEPTH     (FCTRLPROG_W_FIFO_DEPTH), 
      .B_FIFO_DEPTH     (FCTRLPROG_B_FIFO_DEPTH), 
      .AR_FIFO_DEPTH    (FCTRLPROG_AR_FIFO_DEPTH),
      .R_FIFO_DEPTH     (FCTRLPROG_R_FIFO_DEPTH),   
      .AW_PAYLOAD_WIDTH (FCTRLPROG_AWPAYLD_LEN),
      .W_PAYLOAD_WIDTH  (FCTRLPROG_WPAYLD_LEN),
      .B_PAYLOAD_WIDTH  (FCTRLPROG_BPAYLD_LEN),
      .AR_PAYLOAD_WIDTH (FCTRLPROG_ARPAYLD_LEN),
      .R_PAYLOAD_WIDTH  (FCTRLPROG_RPAYLD_LEN)
    )
    u_sse710_adb400_r3_axi4_mst_wrapper (
            
        
        .aclkm          (refclk_int_gated),
        .aresetnm       (refclk_warmresetn),

        .clkqreqnm_i   (fwctrladb_qreqn   ),
        .clkqacceptnm_o(fwctrladb_qacceptn),
        .clkqdenym_o   (fwctrladb_qdeny   ),  
        .clkqactivem_o (fwctrladb_qactive ),

        .awvalidm     (fwctrl_awvalid  ),      
        .awreadym     (fwctrl_awready  ),      
        .awidm        (fwctrl_awid     ),   
        .awaddrm      (fwctrl_awaddr   ),     
        .awregionm    (                ),       
        .awlenm       (fwctrl_awlen    ),    
        .awsizem      (fwctrl_awsize   ),     
        .awburstm     (fwctrl_awburst  ),      
        .awlockm      (fwctrl_awlock   ),     
        .awcachem     (fwctrl_awcache  ),      
        .awprotm      (fwctrl_awprot   ),     
        .awqosm       (                ),    
        .awuserm      (fwctrl_awuser   ),
        
        .wvalidm      (fwctrl_wvalid  ),     
        .wreadym      (fwctrl_wready  ),     
        .wdatam       (fwctrl_wdata   ),    
        .wstrbm       (fwctrl_wstrb   ),    
        .wlastm       (fwctrl_wlast   ),    
        .wuserm       (           ),    
                      
        .bvalidm      (fwctrl_bvalid  ),     
        .breadym      (fwctrl_bready  ),     
        .bidm         (fwctrl_bid     ),  
        .brespm       (fwctrl_bresp   ),    
        .buserm       (fwctrl_buser   ),    
                      
        .arvalidm     (fwctrl_arvalid ),      
        .arreadym     (fwctrl_arready ),      
        .aridm        (fwctrl_arid    ),   
        .araddrm      (fwctrl_araddr  ),     
        .arregionm    (           ),       
        .arlenm       (fwctrl_arlen   ),    
        .arsizem      (fwctrl_arsize  ),     
        .arburstm     (fwctrl_arburst ),      
        .arlockm      (fwctrl_arlock  ),     
        .arcachem     (fwctrl_arcache ),      
        .arprotm      (fwctrl_arprot  ),     
        .arqosm       (          ),    
        .aruserm      (fwctrl_aruser  ),     
                      
        .rvalidm      (fwctrl_rvalid  ),     
        .rreadym      (fwctrl_rready  ),     
        .ridm         (fwctrl_rid     ),  
        .rdatam       (fwctrl_rdata   ),    
        .rrespm       (fwctrl_rresp   ),    
        .rlastm       (fwctrl_rlast   ),    
        .ruserm       (1'b0           ),    
    
        .slvmustacceptreqn_async (fctrlprog_slvmustacceptreqn_async),
        .slvcandenyreqn_async    (fctrlprog_slvcandenyreqn_async),
        .slvacceptn_async        (fctrlprog_slvacceptn_async),
        .slvdeny_async           (fctrlprog_slvdeny_async),
        .si_to_mi_wakeup_async   (fctrlprog_si_to_mi_wakeup_async),
        .mi_to_si_wakeup_async   (fctrlprog_mi_to_si_wakeup_async),
        .aw_wr_ptr_async         (fctrlprog_aw_wr_ptr_async),
        .aw_rd_ptr_async         (fctrlprog_aw_rd_ptr_async),
        .aw_payld_async          (fctrlprog_aw_payld_async),
        .w_wr_ptr_async          (fctrlprog_w_wr_ptr_async),
        .w_rd_ptr_async          (fctrlprog_w_rd_ptr_async),
        .w_payld_async           (fctrlprog_w_payld_async),
        .b_wr_ptr_async          (fctrlprog_b_wr_ptr_async),
        .b_rd_ptr_async          (fctrlprog_b_rd_ptr_async),
        .b_payld_async           (fctrlprog_b_payld_async),
        .ar_wr_ptr_async         (fctrlprog_ar_wr_ptr_async),
        .ar_rd_ptr_async         (fctrlprog_ar_rd_ptr_async),
        .ar_payld_async          (fctrlprog_ar_payld_async),
        .r_wr_ptr_async          (fctrlprog_r_wr_ptr_async),
        .r_rd_ptr_async          (fctrlprog_r_rd_ptr_async),
        .r_payld_async           (fctrlprog_r_payld_async),
    
        .wakeupm_o               (fwctrl_ctrl_wakeup),
        .dftrstdisablem          (dftrstdisable[1])
    );
    
    
   
    sse710_bas_switch_2x1 #(
        .DATA_WIDTH (32),
        .ID_WIDTH   (4),
        .DECMIN_SI0 (0),
        .DECMAX_SI0 (12),
        .DECMIN_SI1 (13),
        .DECMAX_SI1 (13)   
    ) u_fc_ic (
        .aclk               (refclk_int_gated),
        .aresetn            (refclk_warmresetn),
        
      
        .tvalid_dti_dn_s0           (fctrlcfg_systop_dn_tvalid),
        .tready_dti_dn_s0           (fctrlcfg_systop_dn_tready),
        .tdata_dti_dn_s0            (fctrlcfg_systop_dn_tdata ),
        .tkeep_dti_dn_s0            (fctrlcfg_systop_dn_tkeep ),
        .tid_dti_dn_s0              (fctrlcfg_systop_dn_tid   ),
        .tlast_dti_dn_s0            (fctrlcfg_systop_dn_tlast ),
       
        .tvalid_dti_up_s0           (fctrlcfg_systop_up_tvalid),
        .tready_dti_up_s0           (fctrlcfg_systop_up_tready),
        .tdata_dti_up_s0            (fctrlcfg_systop_up_tdata ),
        .tkeep_dti_up_s0            (fctrlcfg_systop_up_tkeep ),
        .tdest_dti_up_s0            (fctrlcfg_systop_up_tdest   ),
        .tlast_dti_up_s0            (fctrlcfg_systop_up_tlast ),

        .twakeup_dti_dn_s0          (fctrlcfg_systop_dn_wakeup),
        .twakeup_dti_up_s0          (fctrlcfg_systop_up_wakeup),
        
        .tvalid_dti_dn_s1           (fctrlcfg_dbgtop_dn_tvalid),
        .tready_dti_dn_s1           (fctrlcfg_dbgtop_dn_tready),
        .tdata_dti_dn_s1            (fctrlcfg_dbgtop_dn_tdata ),
        .tkeep_dti_dn_s1            (fctrlcfg_dbgtop_dn_tkeep ),
        .tid_dti_dn_s1              (fctrlcfg_dbgtop_dn_tid   ),
        .tlast_dti_dn_s1            (fctrlcfg_dbgtop_dn_tlast ),

        .tvalid_dti_up_s1           (fctrlcfg_dbgtop_up_tvalid),
        .tready_dti_up_s1           (fctrlcfg_dbgtop_up_tready),
        .tdata_dti_up_s1            (fctrlcfg_dbgtop_up_tdata ),
        .tkeep_dti_up_s1            (fctrlcfg_dbgtop_up_tkeep ),
        .tdest_dti_up_s1            (fctrlcfg_dbgtop_up_tdest ),
        .tlast_dti_up_s1            (fctrlcfg_dbgtop_up_tlast ),
     
        .twakeup_dti_dn_s1          (fctrlcfg_dbgtop_dn_wakeup),
        .twakeup_dti_up_s1          (fctrlcfg_dbgtop_up_wakeup),
          
        .tvalid_dti_dn_m            (fctrlcfg_dn_tvalid),
        .tready_dti_dn_m            (fctrlcfg_dn_tready),
        .tdata_dti_dn_m             (fctrlcfg_dn_tdata ),
        .tkeep_dti_dn_m             (fctrlcfg_dn_tkeep ),
        .tid_dti_dn_m               (fctrlcfg_dn_tid ),
        .tlast_dti_dn_m             (fctrlcfg_dn_tlast ),
        
        .tvalid_dti_up_m            (fctrlcfg_up_tvalid),
        .tready_dti_up_m            (fctrlcfg_up_tready),
        .tdata_dti_up_m             (fctrlcfg_up_tdata ),
        .tkeep_dti_up_m             (fctrlcfg_up_tkeep ),
        .tdest_dti_up_m             (fctrlcfg_up_tdest ),
        .tlast_dti_up_m             (fctrlcfg_up_tlast ),
                      
        .twakeup_dti_dn_m           (fctrlcfg_dn_twakeup),   
        .twakeup_dti_up_m           (fctrlcfg_up_twakeup)       
    );
    
    
`include "firewall_f0_global_masterid_cfg_sse710.vh"    
`include "firewall_f0_ctlr_global_cfg_sse710.vh" 
    
    firewall_f0_ctlr 
    #(
 `include "firewall_f0_ctlr_cfg_sse710.vh"
    ) u_firewall_f0_ctlr  (
    .clk             (refclk_int_gated),
    .reset_n         (refclk_warmresetn),

    .dftcgen         (dftcgen_or_mbistreq),
    .dftrambyp       (1'b0), 
    .dftramhold      (dftramhold), 
    
    .arid_s_i        (fwctrl_arid    ),     
    .araddr_s_i      (fwctrl_araddr[20:0]),    
    .arlen_s_i       (fwctrl_arlen   ),    
    .arsize_s_i      (fwctrl_arsize  ),    
    .arburst_s_i     (fwctrl_arburst ),    
    .arlock_s_i      (fwctrl_arlock  ),    
    .arcache_s_i     (fwctrl_arcache ),    
    .arprot_s_i      (fwctrl_arprot  ),    
    .arvalid_s_i     (fwctrl_arvalid ),    
    .arready_s_o     (fwctrl_arready ),    
    .armmusid_s_i    (fwctrl_aruser[9:2]),    
                                     
    .awid_s_i        (fwctrl_awid    ),    
    .awaddr_s_i      (fwctrl_awaddr[20:0]),    
    .awlen_s_i       (fwctrl_awlen   ),    
    .awsize_s_i      (fwctrl_awsize  ),    
    .awburst_s_i     (fwctrl_awburst ),    
    .awlock_s_i      (fwctrl_awlock  ),    
    .awcache_s_i     (fwctrl_awcache ),    
    .awprot_s_i      (fwctrl_awprot  ),    
    .awvalid_s_i     (fwctrl_awvalid ),    
    .awready_s_o     (fwctrl_awready ),    
    .awmmusid_s_i    (fwctrl_awuser[9:2]),    
                                     
    .wdata_s_i       (fwctrl_wdata   ),    
    .wstrb_s_i       (fwctrl_wstrb   ),    
    .wlast_s_i       (fwctrl_wlast   ),    
    .wvalid_s_i      (fwctrl_wvalid  ),    
    .wready_s_o      (fwctrl_wready  ),    
                     
    .bid_s_o         (fwctrl_bid     ),    
    .bresp_s_o       (fwctrl_bresp   ),    
    .buser_s_o       (fwctrl_buser   ),    
    .bvalid_s_o      (fwctrl_bvalid  ),    
    .bready_s_i      (fwctrl_bready  ),    
                                     
    .rid_s_o         (fwctrl_rid     ),    
    .rdata_s_o       (fwctrl_rdata   ),    
    .rresp_s_o       (fwctrl_rresp   ),    
    .rlast_s_o       (fwctrl_rlast   ),    
    .ruser_s_o       (   ),    
    .rvalid_s_o      (fwctrl_rvalid  ),    
    .rready_s_i      (fwctrl_rready  ),    
    
    
    .awakeup_s_i     (fwctrl_ctrl_wakeup),
                               
    .tvalid_ds_i     (fctrlcfg_dn_tvalid ),
    .tready_ds_o     (fctrlcfg_dn_tready ),
    .tdata_ds_i      (fctrlcfg_dn_tdata  ),
    .tkeep_ds_i      (fctrlcfg_dn_tkeep  ),
    .tlast_ds_i      (fctrlcfg_dn_tlast  ),
    .tid_ds_i        (fctrlcfg_dn_tid  ),
    .twakeup_ds_i    (fctrlcfg_dn_twakeup),
                             
    .tvalid_us_o     (fctrlcfg_up_tvalid ),
    .tready_us_i     (fctrlcfg_up_tready ),
    .tdata_us_o      (fctrlcfg_up_tdata  ),
    .tkeep_us_o      (fctrlcfg_up_tkeep  ),
    .tlast_us_o      (fctrlcfg_up_tlast  ),
    .tdest_us_o      (fctrlcfg_up_tdest  ),
    .twakeup_us_o    (fctrlcfg_up_twakeup),
        
    .clk_qreqn_i     (fwctrl_qreqn),
    .clk_qacceptn_o  (fwctrl_qacceptn),
    .clk_qdeny_o     (fwctrl_qdeny),
    .clk_qactive_o   (fwctrl_qactive), 
    
    .pwr_preq_i      (preq_fwctrl),
    .pwr_paccept_o   (paccept_fwctrl),
    .pwr_pdeny_o     (pdeny_fwctrl),  
    .pwr_pactive_o   (pactive_fwctrl),
    .pwr_pstate_i    (pstate_fwctrl),  
                      
    .lockdown_i         (host_sys_lctrl_host_fw_lock),
    .interrupt_o        (fwintr),
    .tamper_interrupt_o (fwtamp_intr), 
    .protsize_i         ({
    8'hff,   
    ocvmsize,  
    8'd29, 
    8'd29, 
    8'd32,                         
    8'd32,                         
    8'd32,                         
    8'd32,                         
    8'd255,                        
    cvmsize,                       
    cnvmsize,                      
    8'd23,                         
    8'd25,                         
    8'd29                          
    }),
    
    .bypass_i           (fctrl_bypass) 
);
 
 assign ppu_comb_intr_merged = {host_ppu_int_st_systop_int_st , 
                                host_ppu_int_st_dbgtop_int_st , 
                                host_ppu_int_st_fw_int_st     , 
                                host_ppu_int_st_core0_int_st  ,
                                host_ppu_int_st_core1_int_st  ,
                                host_ppu_int_st_core2_int_st  ,
                                host_ppu_int_st_clustop_int_st,
                                host_ppu_int_st_core3_int_st  }; 
 
  arm_element_or_tree #(
    .NUM_OR_TREE_INPUTS (8)
  ) u_arm_element_or_tree_ppu_comb_intr (
    .or_tree_i  (ppu_comb_intr_merged),                    
    .or_tree_o  (ppu_comb_intr)
  ); 
 
 
 
  assign shared_interrupt_input[NUM_SHD_INT-1:32] = exp_shd_int;
  assign shared_interrupt_input[31:13]            = 19'h00000; 
  assign shared_interrupt_input[0]                = fwintr;
  assign shared_interrupt_input[1]                = irq_sdc600;
  assign shared_interrupt_input[2]                = ppu_comb_intr;
  assign shared_interrupt_input[3]                = refclk_cntbase0_intr;
  assign shared_interrupt_input[4]                = refclk_cntbase1_intr;
  assign shared_interrupt_input[5]                = refclk_cntbase2_intr;
  assign shared_interrupt_input[6]                = refclk_cntbase3_intr;
  assign shared_interrupt_input[7]                = s32k_cntbase0_intr;
  assign shared_interrupt_input[8]                = s32k_cntbase1_intr;
  assign shared_interrupt_input[9]                = irq_soc_etr; 
  assign shared_interrupt_input[10]               = irq_soc_catu; 
  assign shared_interrupt_input[11]               = 1'b0;
  assign shared_interrupt_input[12]               = 1'b0;

interrupt_router_f0_top #(
  .SI0_ICI_DST   (4'h3),
  .SI0_DEF_ICI   (4'h3),
  .SI1_ICI_DST   (4'h3),
  .SI1_DEF_ICI   (4'h3),
  .SI2_ICI_DST   (4'h3),
  .SI2_DEF_ICI   (4'h3),
  .SI3_ICI_DST   (4'hf),
  .SI3_DEF_ICI   (4'hf),
  .SI4_ICI_DST   (4'hf),
  .SI4_DEF_ICI   (4'hf),
  .SI5_ICI_DST   (4'hf),
  .SI5_DEF_ICI   (4'hf),
  .SI6_ICI_DST   (4'hf),
  .SI6_DEF_ICI   (4'hf),
  .SI7_ICI_DST   (4'hf),
  .SI7_DEF_ICI   (4'hf),
  .SI8_ICI_DST   (4'hf),
  .SI8_DEF_ICI   (4'hf),
  .SI9_ICI_DST   (4'he),
  .SI9_DEF_ICI   (4'he),
  .SI10_ICI_DST   (4'he),
  .SI10_DEF_ICI   (4'he),
  .SI11_ICI_DST   (4'h0),
  .SI11_DEF_ICI   (4'h0),
  .SI12_ICI_DST   (4'h0),
  .SI12_DEF_ICI   (4'h0),
  .SI13_ICI_DST   (4'h0),
  .SI13_DEF_ICI   (4'h0),
  .SI14_ICI_DST   (4'h0),
  .SI14_DEF_ICI   (4'h0),
  .SI15_ICI_DST   (4'h0),
  .SI15_DEF_ICI   (4'h0),
  .SI16_ICI_DST   (4'h0),
  .SI16_DEF_ICI   (4'h0),
  .SI17_ICI_DST   (4'h0),
  .SI17_DEF_ICI   (4'h0),
  .SI18_ICI_DST   (4'h0),
  .SI18_DEF_ICI   (4'h0),
  .SI19_ICI_DST   (4'h0),
  .SI19_DEF_ICI   (4'h0),
  .SI20_ICI_DST   (4'h0),
  .SI20_DEF_ICI   (4'h0),
  .SI21_ICI_DST   (4'h0),
  .SI21_DEF_ICI   (4'h0),
  .SI22_ICI_DST   (4'h0),
  .SI22_DEF_ICI   (4'h0),
  .SI23_ICI_DST   (4'h0),
  .SI23_DEF_ICI   (4'h0),
  .SI24_ICI_DST   (4'h0),
  .SI24_DEF_ICI   (4'h0),
  .SI25_ICI_DST   (4'h0),
  .SI25_DEF_ICI   (4'h0),
  .SI26_ICI_DST   (4'h0),
  .SI26_DEF_ICI   (4'h0),
  .SI27_ICI_DST   (4'h0),
  .SI27_DEF_ICI   (4'h0),
  .SI28_ICI_DST   (4'h0),
  .SI28_DEF_ICI   (4'h0),
  .SI29_ICI_DST   (4'h0),
  .SI29_DEF_ICI   (4'h0),
  .SI30_ICI_DST   (4'h0),
  .SI30_DEF_ICI   (4'h0),
  .SI31_ICI_DST   (4'h0),
  .SI31_DEF_ICI   (4'h0),
  `ICI_DST_OVERRIDE_FROM_32
  `DEF_ICI_OVERRIDE_FROM_32
  .LDE_LVL     (2),
  .NUM_ICI     (NUM_ICI),
  .NUM_SHD_INT (NUM_SHD_INT)
) u_interrupt_router (
  .SII                  (shared_interrupt_input),

  .ICI0                 (ici0_out),
  .ICI1                 (ici1_out),
  .ICI2                 (extsys0_shared_interrupts),
  .ICI3                 (extsys1_shared_interrupts),
  
  .LOCK_I               (host_sys_lctrl_int_rtr_lock),
  .TAMPER_INTERRUPT_O   (interrupt_router_tamper_interrupt),

  .MASTER_ID_I          (pprot[2]), 
  .PCLK                 (refclk_sleep_gated),
  .PRESETn              (refclk_warmresetn),  
  .PSEL_I               (psel_interrupt_router),
  .PPROT_I              (pprot),
  .PSTRB_I              (pstrb),
  .PENABLE_I            (penable),
  .PADDR_I              (paddr[11:0]),
  .PWRITE_I             (pwrite),
  .PWDATA_I             (pwdata),
  .PRDATA_O             (prdata_interrupt_router),
  .PREADY_O             (pready_interrupt_router),
  .PSLVERR_O            (pslverr_interrupt_router)

);



generate 
if( NUM_SHD_INT >= 64 ) 
    begin : more_than_64_shd
    assign secenc_shared_interrupts[63:0] = ici0_out[63:0];
    end
endgenerate

generate 
if( NUM_SHD_INT < 64 ) 
    begin : lesseq_than_64_shd
    assign secenc_shared_interrupts[NUM_SHD_INT-1:0] = ici0_out[NUM_SHD_INT-1:0];
    assign secenc_shared_interrupts[63:NUM_SHD_INT] = {64-NUM_SHD_INT{1'b0}};
    end
endgenerate

assign hostcpu_gicshdint      = ici1_out;
assign hostcpu_gicintwdogs    = {ns_wdog_intr_second, secure_wdog_intr_first}; 

assign hostcpu_gicintuart     = {uart1_intr, uart0_intr}; 
assign hostcpu_gicintwdogns   = ns_wdog_intr_first; 
assign hostcpu_gicintdbgtop   = {host_cti_trig_out_5, host_cti_trig_out_4, irq_host_catu, irq_host_etr, irq_host_stm}; 



arm_element_cdc_capt_sync u_secenc_bsys_pwr_req_systop_pwr_sync0   ( .clk(refclk_sleep_gated), .nreset(refclk_warmresetn),   .d_async(secenc_bsys_pwr_req_systop_pwr_req[0]), .q(secenc_bsys_pwr_req_systop_pwr_req_dd_dirty[0]) );
arm_element_cdc_capt_sync u_secenc_bsys_pwr_req_systop_pwr_sync1   ( .clk(refclk_sleep_gated), .nreset(refclk_warmresetn),   .d_async(secenc_bsys_pwr_req_systop_pwr_req[1]), .q(secenc_bsys_pwr_req_systop_pwr_req_dd_dirty[1]) );   
arm_element_cdc_capt_sync u_secenc_bsys_pwr_req_systop_pwr_sync2   ( .clk(refclk_sleep_gated), .nreset(refclk_warmresetn),   .d_async(secenc_bsys_pwr_req_systop_pwr_req[2]), .q(secenc_bsys_pwr_req_systop_pwr_req_dd_dirty[2]) );
arm_element_cdc_capt_sync u_secenc_bsys_pwr_req_systop_pwr_sync3   ( .clk(refclk_sleep_gated), .nreset(refclk_warmresetn),   .d_async(secenc_bsys_pwr_req_systop_pwr_req[3]), .q(secenc_bsys_pwr_req_systop_pwr_req_dd_dirty[3]) );   
arm_element_cdc_capt_sync u_dprom_cdbgrstreq0_ss                   ( .clk(refclk_sleep_gated), .nreset(refclk_warmresetn),       .d_async(dprom_cdbgrstreq0                    ), .q(dprom_cdbgrstreq0_ss                          ) );   
arm_element_cdc_capt_sync u_ppu_dbgen_ss                           ( .clk(refclk_sleep_gated), .nreset(refclk_warmresetn),       .d_async(ppu_dbgen                            ), .q(ppu_dbgen_ss                                  ) );  
arm_element_cdc_capt_sync u_pll_st_sysplllock_st_ss                ( .clk(refclk_sleep_gated), .nreset(refclk_warmresetn),       .d_async(pll_st_sysplllock_st                 ), .q(pll_st_sysplllock_st_ss                       ) );
arm_element_cdc_capt_sync u_pll_st_cpuplllock_st_ss                ( .clk(refclk_sleep_gated), .nreset(refclk_warmresetn),       .d_async(pll_st_cpuplllock_st                 ), .q(pll_st_cpuplllock_st_ss                       ) );





wire [DD_SYNC_COUNT-1:0] qactive_gen_async;
wire [DD_SYNC_COUNT-1:0] qactive_gen_q;
wire [DD_SYNC_COUNT-1:0] qactive_gen_or;

assign qactive_gen_async = {secenc_bsys_pwr_req_systop_pwr_req[0],
                            secenc_bsys_pwr_req_systop_pwr_req[1],
                            secenc_bsys_pwr_req_systop_pwr_req[2],
                            secenc_bsys_pwr_req_systop_pwr_req[3],
                            dprom_cdbgrstreq0                    ,
                            ppu_dbgen                            ,
                            pll_st_sysplllock_st                 ,
                            pll_st_cpuplllock_st};
                  
assign qactive_gen_q = {secenc_bsys_pwr_req_systop_pwr_req_dd_dirty[0],                            
                        secenc_bsys_pwr_req_systop_pwr_req_dd_dirty[1],                            
                        secenc_bsys_pwr_req_systop_pwr_req_dd_dirty[2],                            
                        secenc_bsys_pwr_req_systop_pwr_req_dd_dirty[3],                            
                        dprom_cdbgrstreq0_ss                          ,                            
                        ppu_dbgen_ss                                  ,                            
                        pll_st_sysplllock_st_ss                       ,    
                        pll_st_cpuplllock_st_ss};

genvar i;
                      
generate 
for(i=0;i<DD_SYNC_COUNT;i=i+1) 
begin : qactive_gen_loop   
    arm_element_std_xor2 u_qactive_gen (
    .A (qactive_gen_async[i]),
    .B (qactive_gen_q[i]),
    .Y (refclk_sleep_gated_sync_qactive[i])
    );
end
endgenerate

wire unused;
assign unused= (HOST_CPU_NUM_CORES==0) |
                ppu_unused    |
                fw_unused;


endmodule

`ifdef INT_RTR_PARAMS
`include "interrupt_router_f0_undefs.v"
`endif




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

module sse710_integration_example_f0_external_system_dbg (
    
    input  wire           extsys_dclk,
    
    input  wire           extsys_dbg_resetn,
    
    input  wire           dbg_psel,    
    input  wire           dbg_penable, 
    input  wire           dbg_pwrite,  
    input  wire [31:0]    dbg_paddr,   
    input  wire [31:0]    dbg_pwdata,  
    output wire           dbg_pready,  
    output wire           dbg_pslverr, 
    output wire  [31:0]   dbg_prdata,     
    
    output wire           cpu_dbg_psel,    
    input  wire           cpu_dbg_pready,  
    input  wire           cpu_dbg_pslverr, 
    input  wire [31:0]    cpu_dbg_prdata,        
    
    input  wire           traceexp_atready,    
    input  wire           traceexp_afvalid,
    input  wire           traceexp_syncreq,
    output wire [6:0]     traceexp_atid,            
    output wire           traceexp_atvalid,        
    output wire [31:0]    traceexp_atdata,         
    output wire [1:0]     traceexp_atbytes,         
    output wire           traceexp_afready, 
    output wire           traceexp_atwakeup, 
    
    output wire           etm_atready,      
    input  wire [6:0]     etm_atid,            
    input  wire           etm_atvalid,        
    input  wire [7:0]     etm_atdata,         
    input  wire           etm_atbytes,         
    input  wire           etm_afready,     
    
    output wire           itm_atready,      
    input  wire [6:0]     itm_atid,            
    input  wire           itm_atvalid,        
    input  wire [7:0]     itm_atdata,         
    input  wire           itm_atbytes,         
    input  wire           itm_afready,     
    
    output wire [47:0]    tsvalueb,    
    
    input  wire [3:0]     nts_wr_ptr_encd_gry,
    output wire [3:0]     nts_rd_ptr_encd_gry,
    input  wire [3:0]     nts_wr_ptr_sync_gry,
    output wire [3:0]     nts_rd_ptr_sync_gry,
    input  wire [53:0]    nts_fw_data,
    input  wire           nts_s_lp,
    output wire           nts_s_lp_return,
    output wire           nts_m_lp
    
  );


  wire [6:0]  tsbit;
  wire [1:0]  tssync;
  wire        tssyncready;

  wire        upsizer_etm_atwakeup;
  wire        upsizer_etm_atvalid;
  wire        upsizer_etm_afready;
  wire [6:0]  upsizer_etm_atid;
  wire [31:0] upsizer_etm_atdata;
  wire [1:0]  upsizer_etm_atbytes;
 
  wire        upsizer_etm_atready;
  wire        upsizer_etm_afvalid;
  wire        upsizer_etm_syncreq;  
  
  wire        upsizer_itm_atwakeup;
  wire        upsizer_itm_atvalid;
  wire        upsizer_itm_afready;
  wire [6:0]  upsizer_itm_atid;
  wire [31:0] upsizer_itm_atdata;
  wire [1:0]  upsizer_itm_atbytes;
 
  wire        upsizer_itm_atready;
  wire        upsizer_itm_afvalid;
  wire        upsizer_itm_syncreq;
  
  wire        syncbridge_etm_atwakeup;
  wire        syncbridge_etm_atvalid;
  wire        syncbridge_etm_afready;
  wire [6:0]  syncbridge_etm_atid;
  wire [31:0] syncbridge_etm_atdata;
  wire [1:0]  syncbridge_etm_atbytes;
 
  wire        syncbridge_etm_atready;
  wire        syncbridge_etm_afvalid;
  wire        syncbridge_etm_syncreq;  
  
  wire        syncbridge_etm_syncreq_req;
  wire        syncbridge_etm_syncreq_ack;

  wire [83:0] syncbridge_etm_atb_fwd_data;
  wire        syncbridge_etm_flush_req;
  wire        syncbridge_etm_flush_done;
  wire [1:0]  syncbridge_etm_wr_pointer;
  wire [1:0]  syncbridge_etm_rd_pointer;
  wire        syncbridge_etm_sync_clear;
  wire        syncbridge_etm_sync_done; 
  
  wire        syncbridge_itm_atwakeup;    
  wire        syncbridge_itm_atvalid;     
  wire        syncbridge_itm_afready;     
  wire [6:0]  syncbridge_itm_atid;        
  wire [31:0] syncbridge_itm_atdata;      
  wire [1:0]  syncbridge_itm_atbytes;     
                                           
  wire        syncbridge_itm_atready;     
  wire        syncbridge_itm_afvalid;     
  wire        syncbridge_itm_syncreq;     
  
  wire        syncbridge_itm_syncreq_req;
  wire        syncbridge_itm_syncreq_ack;

  wire [83:0] syncbridge_itm_atb_fwd_data;
  wire        syncbridge_itm_flush_req;
  wire        syncbridge_itm_flush_done;
  wire [1:0]  syncbridge_itm_wr_pointer;
  wire [1:0]  syncbridge_itm_rd_pointer;
  wire        syncbridge_itm_sync_clear;
  wire        syncbridge_itm_sync_done;   
  
  wire [1:0]  funnel_atwakeup_s;
  wire [1:0]  funnel_atvalid_s;
  wire [1:0]  funnel_afready_s;
  wire [13:0] funnel_atid_s;
  wire [63:0] funnel_atdata_s;
  wire [3:0]  funnel_atbytes_s;
 
  wire [1:0]  funnel_atready_s;
  wire [1:0]  funnel_afvalid_s;
  wire [1:0]  funnel_syncreq_s;  
  
  wire [3:0] dbg_decode4bit;

  wire [15:0] unused_ts;
  wire        unused;


  
  assign dbg_decode4bit = (|dbg_paddr[19:12]) ? 4'b0001 : 4'b0000; 

  cmsdk_apb_slave_mux #(
    .PORT0_ENABLE  (1),
    .PORT1_ENABLE  (1),
    .PORT2_ENABLE  (0),
    .PORT3_ENABLE  (0),
    .PORT4_ENABLE  (0),
    .PORT5_ENABLE  (0),
    .PORT6_ENABLE  (0),
    .PORT7_ENABLE  (0),
    .PORT8_ENABLE  (0),
    .PORT9_ENABLE  (0),
    .PORT10_ENABLE (0),
    .PORT11_ENABLE (0),
    .PORT12_ENABLE (0),
    .PORT13_ENABLE (0),
    .PORT14_ENABLE (0),
    .PORT15_ENABLE (0)
  ) u_cmsdk_apb_slave_mux (
    .DECODE4BIT      (dbg_decode4bit),
    .PSEL            (dbg_psel),

    .PSEL0           (cpu_dbg_psel),
    .PREADY0         (cpu_dbg_pready),
    .PRDATA0         (cpu_dbg_prdata),
    .PSLVERR0        (cpu_dbg_pslverr),

    .PSEL1           (),
    .PREADY1         (1'b1),
    .PRDATA1         (32'h0000_0000),
    .PSLVERR1        (1'b1),

    .PSEL2           (),
    .PREADY2         (1'b0),
    .PRDATA2         (32'h0000_0000),
    .PSLVERR2        (1'b0),

    .PSEL3           (),             
    .PREADY3         (1'b0),         
    .PRDATA3         (32'h0000_0000),
    .PSLVERR3        (1'b0),         

    .PSEL4           (),             
    .PREADY4         (1'b0),         
    .PRDATA4         (32'h0000_0000),
    .PSLVERR4        (1'b0),         

    .PSEL5           (),             
    .PREADY5         (1'b0),         
    .PRDATA5         (32'h0000_0000),
    .PSLVERR5        (1'b0),         

    .PSEL6           (),             
    .PREADY6         (1'b0),         
    .PRDATA6         (32'h0000_0000),
    .PSLVERR6        (1'b0),         

    .PSEL7           (),             
    .PREADY7         (1'b0),         
    .PRDATA7         (32'h0000_0000),
    .PSLVERR7        (1'b0),         

    .PSEL8           (),             
    .PREADY8         (1'b0),         
    .PRDATA8         (32'h0000_0000),
    .PSLVERR8        (1'b0),         

    .PSEL9           (),             
    .PREADY9         (1'b0),         
    .PRDATA9         (32'h0000_0000),
    .PSLVERR9        (1'b0),         

    .PSEL10          (),             
    .PREADY10        (1'b0),         
    .PRDATA10        (32'h0000_0000),
    .PSLVERR10       (1'b0),         

    .PSEL11          (),             
    .PREADY11        (1'b0),         
    .PRDATA11        (32'h0000_0000),
    .PSLVERR11       (1'b0),         

    .PSEL12          (),             
    .PREADY12        (1'b0),         
    .PRDATA12        (32'h0000_0000),
    .PSLVERR12       (1'b0),         

    .PSEL13          (),             
    .PREADY13        (1'b0),         
    .PRDATA13        (32'h0000_0000),
    .PSLVERR13       (1'b0),         

    .PSEL14          (),             
    .PREADY14        (1'b0),         
    .PRDATA14        (32'h0000_0000),
    .PSLVERR14       (1'b0),         

    .PSEL15          (),             
    .PREADY15        (1'b0),         
    .PRDATA15        (32'h0000_0000),
    .PSLVERR15       (1'b0),         

    .PREADY          (dbg_pready),
    .PRDATA          (dbg_prdata),
    .PSLVERR         (dbg_pslverr)
  );
  

  css600_atbupsizer #(
    .ATB_SLAVE_DATA_WIDTH  (8),
    .ATB_MASTER_DATA_WIDTH (32)
  ) u_css600_atbupsizer_itm (
    .clk          (extsys_dclk),
    .reset_n      (extsys_dbg_resetn),
    .atwakeup_m   (upsizer_itm_atwakeup),
    .atvalid_m    (upsizer_itm_atvalid),
    .atready_m    (upsizer_itm_atready),
    .afvalid_m    (upsizer_itm_afvalid),
    .afready_m    (upsizer_itm_afready),
    .syncreq_m    (upsizer_itm_syncreq),
    .atid_m       (upsizer_itm_atid),
    .atdata_m     (upsizer_itm_atdata),
    .atbytes_m    (upsizer_itm_atbytes),
    .atwakeup_s   (itm_atvalid),
    .atvalid_s    (itm_atvalid),
    .atready_s    (itm_atready),
    .afvalid_s    (),             
    .afready_s    (itm_afready),
    .syncreq_s    (),             
    .atid_s       (itm_atid),
    .atdata_s     (itm_atdata),
    .atbytes_s    (itm_atbytes),
    .clk_qactive  ()
  );
  
  css600_atbupsizer #(
    .ATB_SLAVE_DATA_WIDTH  (8),
    .ATB_MASTER_DATA_WIDTH (32)
  ) u_css600_atbupsizer_etm (
    .clk          (extsys_dclk),
    .reset_n      (extsys_dbg_resetn),
    .atwakeup_m   (upsizer_etm_atwakeup),
    .atvalid_m    (upsizer_etm_atvalid),
    .atready_m    (upsizer_etm_atready),
    .afvalid_m    (upsizer_etm_afvalid),
    .afready_m    (upsizer_etm_afready),
    .syncreq_m    (upsizer_etm_syncreq),
    .atid_m       (upsizer_etm_atid),
    .atdata_m     (upsizer_etm_atdata),
    .atbytes_m    (upsizer_etm_atbytes),
    .atwakeup_s   (etm_atvalid),
    .atvalid_s    (etm_atvalid),
    .atready_s    (etm_atready),
    .afvalid_s    (),                 
    .afready_s    (etm_afready),
    .syncreq_s    (),                 
    .atid_s       (etm_atid),
    .atdata_s     (etm_atdata),
    .atbytes_s    (etm_atbytes),
    .clk_qactive  ()
  );


  css600_atbsyncbridgeslv #(
    .ATB_DATA_WIDTH     (32),
    .FF_SYNC_DEPTH      (2)
  ) u_css600_atbsyncbridgeslv_itm (
    .clk_s                (extsys_dclk),
    .reset_s_n            (extsys_dbg_resetn),
  
    .atwakeup_s           (upsizer_itm_atwakeup),
    .atvalid_s            (upsizer_itm_atvalid),
    .atid_s               (upsizer_itm_atid),
    .atbytes_s            (upsizer_itm_atbytes),
    .atdata_s             (upsizer_itm_atdata),
    .afready_s            (upsizer_itm_afready),
  
    .atready_s            (upsizer_itm_atready),
    .afvalid_s            (upsizer_itm_afvalid),
  
    .syncreq_s            (upsizer_itm_syncreq),
    .syncreq_req          (syncbridge_itm_syncreq_req),
    .syncreq_ack          (syncbridge_itm_syncreq_ack),
  
    .atb_fwd_data         (syncbridge_itm_atb_fwd_data),
    .flush_req            (syncbridge_itm_flush_req),
    .flush_done           (syncbridge_itm_flush_done),
    .wr_pointer           (syncbridge_itm_wr_pointer),
    .rd_pointer           (syncbridge_itm_rd_pointer),
    .sync_clear           (syncbridge_itm_sync_clear),
    .sync_done            (syncbridge_itm_sync_done),
  
    .clk_s_qreq_n         (1'b1),
    .clk_s_qaccept_n      (),
    .clk_s_qdeny          (),
    .clk_s_qactive        (),
  
    .pwr_qreq_n           (1'b1),
    .pwr_qaccept_n        (),
    .pwr_qdeny            (),
    .pwr_qactive          ()
  );  

  css600_atbsyncbridgemstr #(
    .ATB_DATA_WIDTH  (32)
  ) u_css600_atbsyncbridgemstr_itm (
    .clk_m           (extsys_dclk),
    .reset_m_n       (extsys_dbg_resetn),

    .afready_m       (syncbridge_itm_afready),
    .afvalid_m       (syncbridge_itm_afvalid),

    .atwakeup_m      (syncbridge_itm_atwakeup),
    .atvalid_m       (syncbridge_itm_atvalid),
    .atready_m       (syncbridge_itm_atready),
    .atid_m          (syncbridge_itm_atid),
    .atbytes_m       (syncbridge_itm_atbytes),
    .atdata_m        (syncbridge_itm_atdata),

    .syncreq_m       (syncbridge_itm_syncreq),
    .syncreq_req     (syncbridge_itm_syncreq_req),
    .syncreq_ack     (syncbridge_itm_syncreq_ack),

    .atb_fwd_data    (syncbridge_itm_atb_fwd_data),
    .flush_req       (syncbridge_itm_flush_req),
    .flush_done      (syncbridge_itm_flush_done),
    .wr_pointer      (syncbridge_itm_wr_pointer),
    .rd_pointer      (syncbridge_itm_rd_pointer),
    .sync_clear      (syncbridge_itm_sync_clear),
    .sync_done       (syncbridge_itm_sync_done)
  );
  
  css600_atbsyncbridgeslv #(
    .ATB_DATA_WIDTH     (32),
    .FF_SYNC_DEPTH      (2)
  ) u_css600_atbsyncbridgeslv_etm (
    .clk_s                (extsys_dclk),
    .reset_s_n            (extsys_dbg_resetn),
  
    .atwakeup_s           (upsizer_etm_atwakeup),
    .atvalid_s            (upsizer_etm_atvalid),
    .atid_s               (upsizer_etm_atid),
    .atbytes_s            (upsizer_etm_atbytes),
    .atdata_s             (upsizer_etm_atdata),
    .afready_s            (upsizer_etm_afready),
  
    .atready_s            (upsizer_etm_atready),
    .afvalid_s            (upsizer_etm_afvalid),
  
    .syncreq_s            (upsizer_etm_syncreq),
    .syncreq_req          (syncbridge_etm_syncreq_req),
    .syncreq_ack          (syncbridge_etm_syncreq_ack),
  
    .atb_fwd_data         (syncbridge_etm_atb_fwd_data),
    .flush_req            (syncbridge_etm_flush_req),
    .flush_done           (syncbridge_etm_flush_done),
    .wr_pointer           (syncbridge_etm_wr_pointer),
    .rd_pointer           (syncbridge_etm_rd_pointer),
    .sync_clear           (syncbridge_etm_sync_clear),
    .sync_done            (syncbridge_etm_sync_done),
  
    .clk_s_qreq_n         (1'b1),
    .clk_s_qaccept_n      (),
    .clk_s_qdeny          (),
    .clk_s_qactive        (),
  
    .pwr_qreq_n           (1'b1),
    .pwr_qaccept_n        (),
    .pwr_qdeny            (),
    .pwr_qactive          ()
  );  

  css600_atbsyncbridgemstr #(
    .ATB_DATA_WIDTH  (32)
  ) u_css600_atbsyncbridgemstr_etm (
    .clk_m           (extsys_dclk),
    .reset_m_n       (extsys_dbg_resetn),

    .afready_m       (syncbridge_etm_afready),
    .afvalid_m       (syncbridge_etm_afvalid),

    .atwakeup_m      (syncbridge_etm_atwakeup),
    .atvalid_m       (syncbridge_etm_atvalid),
    .atready_m       (syncbridge_etm_atready),
    .atid_m          (syncbridge_etm_atid),
    .atbytes_m       (syncbridge_etm_atbytes),
    .atdata_m        (syncbridge_etm_atdata),

    .syncreq_m       (syncbridge_etm_syncreq),
    .syncreq_req     (syncbridge_etm_syncreq_req),
    .syncreq_ack     (syncbridge_etm_syncreq_ack),

    .atb_fwd_data    (syncbridge_etm_atb_fwd_data),
    .flush_req       (syncbridge_etm_flush_req),
    .flush_done      (syncbridge_etm_flush_done),
    .wr_pointer      (syncbridge_etm_wr_pointer),
    .rd_pointer      (syncbridge_etm_rd_pointer),
    .sync_clear      (syncbridge_etm_sync_clear),
    .sync_done       (syncbridge_etm_sync_done)
  );
  
  css600_atbfunnel #(
    .ATB_DATA_WIDTH  (32),
    .NUM_ATB_SLAVES  (2)
  ) u_css600_atbfunnel (
    .clk          (extsys_dclk),
    .reset_n      (extsys_dbg_resetn),

    .atwakeup_s   (funnel_atwakeup_s),
    .atvalid_s    (funnel_atvalid_s),
    .afready_s    (funnel_afready_s),
    .atid_s       (funnel_atid_s),
    .atdata_s     (funnel_atdata_s),
    .atbytes_s    (funnel_atbytes_s),

    .atready_m    (traceexp_atready),
    .afvalid_m    (traceexp_afvalid),
    .syncreq_m    (traceexp_syncreq),

    .atwakeup_m   (traceexp_atwakeup),
    .atvalid_m    (traceexp_atvalid),
    .afready_m    (traceexp_afready),
    .atid_m       (traceexp_atid),
    .atdata_m     (traceexp_atdata),
    .atbytes_m    (traceexp_atbytes),

    .atready_s    (funnel_atready_s),
    .afvalid_s    (funnel_afvalid_s),
    .syncreq_s    (funnel_syncreq_s), 

    .clk_qactive  ()
  );
 
  assign funnel_atwakeup_s = {syncbridge_etm_atwakeup, syncbridge_itm_atwakeup};
  assign funnel_atvalid_s  = {syncbridge_etm_atvalid , syncbridge_itm_atvalid};
  assign funnel_afready_s  = {syncbridge_etm_afready , syncbridge_itm_afready};
  assign funnel_atid_s     = {syncbridge_etm_atid    , syncbridge_itm_atid};
  assign funnel_atdata_s   = {syncbridge_etm_atdata  , syncbridge_itm_atdata};
  assign funnel_atbytes_s  = {syncbridge_etm_atbytes , syncbridge_itm_atbytes};
  
  assign {syncbridge_etm_atready, syncbridge_itm_atready} = funnel_atready_s;
  assign {syncbridge_etm_afvalid, syncbridge_itm_afvalid} = funnel_afvalid_s;
  assign {syncbridge_etm_syncreq, syncbridge_itm_syncreq} = funnel_syncreq_s;
 
  css600_ntsasyncbridgemstr #(
    .FF_SYNC_DEPTH (2),
    .THRESHOLD     (8)
  ) u_css600_ntsasyncbridgemstr (
    .clk_m             (extsys_dclk),
    .reset_m_n         (extsys_dbg_resetn),
    .tsbit_m           (tsbit),
    .tssync_m          (tssync),
    .tssyncready_m     (tssyncready),
    .clk_m_qreq_n      (1'b1),
    .clk_m_qaccept_n   (),
    .clk_m_qactive     (),
    .wr_ptr_encd_gry   (nts_wr_ptr_encd_gry),
    .rd_ptr_encd_gry   (nts_rd_ptr_encd_gry),
    .wr_ptr_sync_gry   (nts_wr_ptr_sync_gry),
    .rd_ptr_sync_gry   (nts_rd_ptr_sync_gry),
    .nts_fw_data       (nts_fw_data),
    .s_lp              (nts_s_lp),
    .s_lp_return       (nts_s_lp_return),
    .m_lp              (nts_m_lp)
  );
  
  css600_ntsdecoder #(
    .FF_SYNC_DEPTH (2)
  ) u_css600_ntsdecoder (
    .clk            (extsys_dclk),
    .reset_n        (extsys_dbg_resetn),
    .tsbit_s        (tsbit),
    .tssync_s       (tssync),
    .tssyncready_s  (tssyncready),
    .tsvalue_b_m    ({unused_ts, tsvalueb}),
    .clk_qreq_n     (1'b1),
    .clk_qaccept_n  ()
    );
  

  assign unused = |{dbg_penable, 
                    dbg_pwdata,
                    dbg_pwrite,
                    dbg_paddr[11:0],
                    dbg_paddr[31:20]};

  
endmodule

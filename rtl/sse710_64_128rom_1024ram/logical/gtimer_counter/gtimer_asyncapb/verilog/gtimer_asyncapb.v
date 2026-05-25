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


module gtimer_asyncapb (
  input  wire         PCLK,                  
  input  wire         PRESETn,               
  input  wire         CCLK,                  
  input  wire         CRESETn,               
  
  input  wire  [63:0] TSVALUEB,              
  
  input  wire   [5:0] CNTACR,                
  input  wire  [63:0] CNTVOFF,               
  
  output wire         GTIMERINTRPHYS,        
  output wire         GTIMERINTRVIRT,        
  
  input  wire         PSELCNTBASEN,          
  input  wire  [11:2] PADDRCNTBASEN,         
  input  wire         PENABLECNTBASEN,       
  input  wire         PWRITECNTBASEN,        
  input  wire  [31:0] PWDATACNTBASEN,        
  output wire         PREADYCNTBASEN,        
  output wire  [31:0] PRDATACNTBASEN,        
  output wire         PSLVERRCNTBASEN,       
  
  input  wire         PSELCNTPL0BASEN,       
  input  wire  [11:2] PADDRCNTPL0BASEN,      
  input  wire         PENABLECNTPL0BASEN,    
  input  wire         PWRITECNTPL0BASEN,     
  input  wire  [31:0] PWDATACNTPL0BASEN,     
  output wire         PREADYCNTPL0BASEN,     
  output wire  [31:0] PRDATACNTPL0BASEN,     
  output wire         PSLVERRCNTPL0BASEN,    

  input  wire         TIMERFVIREG,           
  input  wire         TIMERFPL0REG           
);


wire  [3:0]  tieoff1;                        
wire  [3:0]  tieoff2;                        
wire  [3:0]  revision;                       

wire         cntvoff_sync;                   
wire [63:0]  int_cntvoff;                    

wire         cntpl_cval_write_in_progress_toggle;
wire         cntpl_cval_write_complete;
wire [31:0]  cntpl_cval_write_val;
wire         cntpu_cval_write_in_progress_toggle;
wire         cntpu_cval_write_complete;
wire [31:0]  cntpu_cval_write_val;
wire         cntp_tval_write_in_progress_toggle;
wire         cntp_tval_write_complete;
wire [31:0]  cntp_tval_write_val;
wire         cntp_ctl_write_in_progress_toggle;
wire         cntp_ctl_write_complete;
wire [1:0]   cntp_ctl_write_val;

wire         cntvl_cval_write_in_progress_toggle;
wire         cntvl_cval_write_complete;
wire [31:0]  cntvl_cval_write_val;
wire         cntvu_cval_write_in_progress_toggle;
wire         cntvu_cval_write_complete;
wire [31:0]  cntvu_cval_write_val;
wire         cntv_tval_write_in_progress_toggle;
wire         cntv_tval_write_complete;
wire [31:0]  cntv_tval_write_val;
wire         cntv_ctl_write_in_progress_toggle;
wire         cntv_ctl_write_complete;
wire [1:0]   cntv_ctl_write_val;

wire [63:0]  cntpct_rd_data;
wire [31:0]  cntptval_rd;
wire [63:0]  cntpcval_rd;
wire  [2:0]  cntpctl_rd;
wire         cntp_update_timer_regs;

wire [63:0]  cntvct_rd_data;
wire [31:0]  cntvtval_rd;
wire [63:0]  cntvcval_rd;
wire  [2:0]  cntvctl_rd;
wire         cntv_update_timer_regs;



reg  [3:0]       tieoff1_static_r;
wire [3:0]       tieoff1_static_o;
reg              tieoff1_static_up;
wire             tieoff1_static_en;

always@(posedge PCLK)
begin
  if(tieoff1_static_en)
  begin
    tieoff1_static_r <= 4'b0000;
  end
end

always@(posedge PCLK or negedge PRESETn)
begin
  if(!PRESETn)
  begin
    tieoff1_static_up <= 1'b1;
  end
  else if(tieoff1_static_en)
  begin
    tieoff1_static_up <= 1'b0;
  end
end

assign tieoff1_static_en = tieoff1_static_up;

assign tieoff1_static_o = tieoff1_static_r;


reg  [3:0]       tieoff2_static_r;
wire [3:0]       tieoff2_static_o;
reg              tieoff2_static_up;
wire             tieoff2_static_en;

always@(posedge PCLK)
begin
  if(tieoff2_static_en)
  begin
    tieoff2_static_r <= 4'b0000;
  end
end

always@(posedge PCLK or negedge PRESETn)
begin
  if(!PRESETn)
  begin
    tieoff2_static_up <= 1'b1;
  end
  else if(tieoff2_static_en)
  begin
    tieoff2_static_up <= 1'b0;
  end
end

assign tieoff2_static_en = tieoff2_static_up;

assign tieoff2_static_o = tieoff2_static_r;


assign tieoff1          = tieoff1_static_o;
assign tieoff2          = tieoff2_static_o;


gtimer_asyncapb_revision  u_gtimer_asyncapb_revision_0 (
                    .tieoff1           ( tieoff1[0]        ),  
                    .tieoff2           ( tieoff2[0]        ),  
                    .revision          ( revision[0]       )   
                     );

gtimer_asyncapb_revision  u_gtimer_asyncapb_revision_1 (
                    .tieoff1           ( tieoff1[1]        ),  
                    .tieoff2           ( tieoff2[1]        ),  
                    .revision          ( revision[1]       )   
                     );

gtimer_asyncapb_revision  u_gtimer_asyncapb_revision_2 (
                    .tieoff1           ( tieoff1[2]        ),  
                    .tieoff2           ( tieoff2[2]        ),  
                    .revision          ( revision[2]       )   
                     );

gtimer_asyncapb_revision  u_gtimer_asyncapb_revision_3 (
                    .tieoff1           ( tieoff1[3]        ),  
                    .tieoff2           ( tieoff2[3]        ),  
                    .revision          ( revision[3]       )   
                     );


gtimer_asyncapb_apbif u_gtimer_asyncapb_apbif (
                    .PCLK                                ( PCLK                                ),  
                    .PRESETn                             ( PRESETn                             ),  

                    .PADDRCNTBASEN                       ( PADDRCNTBASEN                       ),  
                    .PSELCNTBASEN                        ( PSELCNTBASEN                        ),  
                    .PENABLECNTBASEN                     ( PENABLECNTBASEN                     ),  
                    .PWRITECNTBASEN                      ( PWRITECNTBASEN                      ),  
                    .PWDATACNTBASEN                      ( PWDATACNTBASEN                      ),  

                    .PREADYCNTBASEN                      ( PREADYCNTBASEN                      ),  
                    .PRDATACNTBASEN                      ( PRDATACNTBASEN                      ),  
                    .PSLVERRCNTBASEN                     ( PSLVERRCNTBASEN                     ),  
                                       
                    .PADDRCNTPL0BASEN                    ( PADDRCNTPL0BASEN                    ),  
                    .PSELCNTPL0BASEN                     ( PSELCNTPL0BASEN                     ),  
                    .PENABLECNTPL0BASEN                  ( PENABLECNTPL0BASEN                  ),  
                    .PWRITECNTPL0BASEN                   ( PWRITECNTPL0BASEN                   ),  
                    .PWDATACNTPL0BASEN                   ( PWDATACNTPL0BASEN                   ),  

                    .PREADYCNTPL0BASEN                   ( PREADYCNTPL0BASEN                   ),  
                    .PRDATACNTPL0BASEN                   ( PRDATACNTPL0BASEN                   ),  
                    .PSLVERRCNTPL0BASEN                  ( PSLVERRCNTPL0BASEN                  ),  

                    .revision                            ( revision                            ),  

                    .TIMERFVIREG                         ( TIMERFVIREG                         ),  
                    .TIMERFPL0REG                        ( TIMERFPL0REG                        ),  
                    .CNTACR                              ( CNTACR                              ),  
                    .CNTVOFF                             ( CNTVOFF                             ),  
                    .cntvoff_sync                        ( cntvoff_sync                        ),  
                    .int_cntvoff                         ( int_cntvoff                         ),  

                    .cntpl_cval_write_in_progress_toggle ( cntpl_cval_write_in_progress_toggle ),  
                    .cntpl_cval_write_complete           ( cntpl_cval_write_complete           ),  
                    .cntpl_cval_write_val                ( cntpl_cval_write_val                ),  
                    .cntpu_cval_write_in_progress_toggle ( cntpu_cval_write_in_progress_toggle ),  
                    .cntpu_cval_write_complete           ( cntpu_cval_write_complete           ),  
                    .cntpu_cval_write_val                ( cntpu_cval_write_val                ),  
                    .cntp_tval_write_in_progress_toggle  ( cntp_tval_write_in_progress_toggle  ),  
                    .cntp_tval_write_complete            ( cntp_tval_write_complete            ),  
                    .cntp_tval_write_val                 ( cntp_tval_write_val                 ),  
                    .cntp_ctl_write_in_progress_toggle   ( cntp_ctl_write_in_progress_toggle   ),  
                    .cntp_ctl_write_complete             ( cntp_ctl_write_complete             ),  
                    .cntp_ctl_write_val                  ( cntp_ctl_write_val                  ),  
                    
                    .cntvl_cval_write_in_progress_toggle ( cntvl_cval_write_in_progress_toggle ),  
                    .cntvl_cval_write_complete           ( cntvl_cval_write_complete           ),  
                    .cntvl_cval_write_val                ( cntvl_cval_write_val                ),  
                    .cntvu_cval_write_in_progress_toggle ( cntvu_cval_write_in_progress_toggle ),  
                    .cntvu_cval_write_complete           ( cntvu_cval_write_complete           ),  
                    .cntvu_cval_write_val                ( cntvu_cval_write_val                ),  
                    .cntv_tval_write_in_progress_toggle  ( cntv_tval_write_in_progress_toggle  ),  
                    .cntv_tval_write_complete            ( cntv_tval_write_complete            ),  
                    .cntv_tval_write_val                 ( cntv_tval_write_val                 ),  
                    .cntv_ctl_write_in_progress_toggle   ( cntv_ctl_write_in_progress_toggle   ),  
                    .cntv_ctl_write_complete             ( cntv_ctl_write_complete             ),  
                    .cntv_ctl_write_val                  ( cntv_ctl_write_val                  ),  

                    .cntpct_rd_data                      ( cntpct_rd_data                      ),  
                    .cntptval_rd                         ( cntptval_rd                         ),  
                    .cntpcval_rd                         ( cntpcval_rd                         ),  
                    .cntpctl_rd                          ( cntpctl_rd                          ),  
                    .cntp_update_timer_regs              ( cntp_update_timer_regs              ),  

                    .cntvct_rd_data                      ( cntvct_rd_data                      ),  
                    .cntvtval_rd                         ( cntvtval_rd                         ),  
                    .cntvcval_rd                         ( cntvcval_rd                         ),  
                    .cntvctl_rd                          ( cntvctl_rd                          ),  
                    .cntv_update_timer_regs              ( cntv_update_timer_regs              )  
                    );


gtimer_asyncapb_core u_gtimer_asyncapb_core_physical (
                    .clk                            ( CCLK                                ),  
                    .resetn                         ( CRESETn                             ),  

                    .tsvalueb                       ( TSVALUEB                            ),  

                    .cntvoff_sync                   (                             ),  
                    .int_cntvoff                    ( 64'h0000_0000_0000_0000             ),  

                    .lcval_write_in_progress_toggle ( cntpl_cval_write_in_progress_toggle ),  
                    .lcval_write_complete           ( cntpl_cval_write_complete           ),  
                    .lcval_write_val                ( cntpl_cval_write_val                ),  
                    .ucval_write_in_progress_toggle ( cntpu_cval_write_in_progress_toggle ),  
                    .ucval_write_complete           ( cntpu_cval_write_complete           ),  
                    .ucval_write_val                ( cntpu_cval_write_val                ),  
                    .tval_write_in_progress_toggle  ( cntp_tval_write_in_progress_toggle  ),  
                    .tval_write_complete            ( cntp_tval_write_complete            ),  
                    .tval_write_val                 ( cntp_tval_write_val                 ),  
                    .ctl_write_in_progress_toggle   ( cntp_ctl_write_in_progress_toggle   ),  
                    .ctl_write_complete             ( cntp_ctl_write_complete             ),  
                    .ctl_write_val                  ( cntp_ctl_write_val                  ),  

                    .timer_count                    ( cntpct_rd_data                      ),  
                    .timer_value                    ( cntptval_rd                         ),  
                    .compare_value                  ( cntpcval_rd                         ),  
                    .timer_control                  ( cntpctl_rd                          ),  
                    .update_timer_regs              ( cntp_update_timer_regs              ),  

                    .interrupt_out                  ( GTIMERINTRPHYS                      )   
                    );
                     
                     
gtimer_asyncapb_core u_gtimer_asyncapb_core_virtual (
                    .clk                            ( CCLK                                ),  
                    .resetn                         ( CRESETn                             ),  

                    .tsvalueb                       ( TSVALUEB                            ),  

                    .cntvoff_sync                   ( cntvoff_sync                        ),  
                    .int_cntvoff                    ( int_cntvoff                         ),  

                    .lcval_write_in_progress_toggle ( cntvl_cval_write_in_progress_toggle ),  
                    .lcval_write_complete           ( cntvl_cval_write_complete           ),  
                    .lcval_write_val                ( cntvl_cval_write_val                ),  
                    .ucval_write_in_progress_toggle ( cntvu_cval_write_in_progress_toggle ),  
                    .ucval_write_complete           ( cntvu_cval_write_complete           ),  
                    .ucval_write_val                ( cntvu_cval_write_val                ),  
                    .tval_write_in_progress_toggle  ( cntv_tval_write_in_progress_toggle  ),  
                    .tval_write_complete            ( cntv_tval_write_complete            ),  
                    .tval_write_val                 ( cntv_tval_write_val                 ),  
                    .ctl_write_in_progress_toggle   ( cntv_ctl_write_in_progress_toggle   ),  
                    .ctl_write_complete             ( cntv_ctl_write_complete             ),  
                    .ctl_write_val                  ( cntv_ctl_write_val                  ),  

                    .timer_count                    ( cntvct_rd_data                      ),  
                    .timer_value                    ( cntvtval_rd                         ),  
                    .compare_value                  ( cntvcval_rd                         ),  
                    .timer_control                  ( cntvctl_rd                          ),  
                    .update_timer_regs              ( cntv_update_timer_regs              ),  

                    .interrupt_out                  ( GTIMERINTRVIRT                      )   
                     );


endmodule


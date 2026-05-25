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


module gtimer_syncapb (
  input  wire         PCLK,                  
  input  wire         PRESETn,               
  
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

reg  [63:0]  int_cntvoff;                    
reg   [5:0]  int_cntacr;                     

reg  [63:0]  int_tsvalueb;                   

wire         cntpu_cval_write_cntbasen;
wire         cntpl_cval_write_cntbasen;
wire         cntp_tval_write_cntbasen;
wire         cntp_ctl_write_cntbasen;
wire         cntvl_cval_write_cntbasen;
wire         cntvu_cval_write_cntbasen;
wire         cntv_tval_write_cntbasen;
wire         cntv_ctl_write_cntbasen;
wire [31:0]  pwdata_enabled_cntbasen;
wire         cntpl_cval_write_cntpl0basen;
wire         cntpu_cval_write_cntpl0basen;
wire         cntp_tval_write_cntpl0basen;
wire         cntp_ctl_write_cntpl0basen;
wire         cntvl_cval_write_cntpl0basen;
wire         cntvu_cval_write_cntpl0basen;
wire         cntv_tval_write_cntpl0basen;
wire         cntv_ctl_write_cntpl0basen;
wire [31:0]  pwdata_enabled_cntpl0basen;

wire [63:0]  cntpct_rd;
wire [63:0]  cntpcval_rd;
wire [31:0]  cntptval_rd;
wire  [2:0]  cntpctl_rd;
wire [63:0]  cntvct_rd;
wire [63:0]  cntvcval_rd;
wire [31:0]  cntvtval_rd;
wire  [2:0]  cntvctl_rd;



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

gtimer_syncapb_revision  u_gtimer_syncapb_revision_0 (
                    .tieoff1           ( tieoff1[0]        ),  
                    .tieoff2           ( tieoff2[0]        ),  
                    .revision          ( revision[0]       )   
                     );

gtimer_syncapb_revision  u_gtimer_syncapb_revision_1 (
                    .tieoff1           ( tieoff1[1]        ),  
                    .tieoff2           ( tieoff2[1]        ),  
                    .revision          ( revision[1]       )   
                     );

gtimer_syncapb_revision  u_gtimer_syncapb_revision_2 (
                    .tieoff1           ( tieoff1[2]        ),  
                    .tieoff2           ( tieoff2[2]        ),  
                    .revision          ( revision[2]       )   
                     );

gtimer_syncapb_revision  u_gtimer_syncapb_revision_3 (
                    .tieoff1           ( tieoff1[3]        ),  
                    .tieoff2           ( tieoff2[3]        ),  
                    .revision          ( revision[3]       )   
                     );


always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    begin
      int_cntvoff <= 64'h0000_0000_0000_0000;
      int_cntacr  <= 6'h00;
    end
  else
    begin
      int_cntvoff <= CNTVOFF;
      int_cntacr  <= CNTACR;
    end
      

gtimer_syncapb_apbif u_gtimer_syncapb_apbif (
                    .PCLK                           ( PCLK                         ),  
                    .PRESETn                        ( PRESETn                      ),  

                    .PADDRCNTBASEN                  ( PADDRCNTBASEN                ),  
                    .PSELCNTBASEN                   ( PSELCNTBASEN                 ),  
                    .PENABLECNTBASEN                ( PENABLECNTBASEN              ),  
                    .PWRITECNTBASEN                 ( PWRITECNTBASEN               ),  
                    .PWDATACNTBASEN                 ( PWDATACNTBASEN               ),  

                    .PREADYCNTBASEN                 ( PREADYCNTBASEN               ),  
                    .PRDATACNTBASEN                 ( PRDATACNTBASEN               ),  
                    .PSLVERRCNTBASEN                ( PSLVERRCNTBASEN              ),  
                                       
                    .PADDRCNTPL0BASEN               ( PADDRCNTPL0BASEN             ),  
                    .PSELCNTPL0BASEN                ( PSELCNTPL0BASEN              ),  
                    .PENABLECNTPL0BASEN             ( PENABLECNTPL0BASEN           ),  
                    .PWRITECNTPL0BASEN              ( PWRITECNTPL0BASEN            ),  
                    .PWDATACNTPL0BASEN              ( PWDATACNTPL0BASEN            ),  

                    .PREADYCNTPL0BASEN              ( PREADYCNTPL0BASEN            ),  
                    .PRDATACNTPL0BASEN              ( PRDATACNTPL0BASEN            ),  
                    .PSLVERRCNTPL0BASEN             ( PSLVERRCNTPL0BASEN           ),  

                    .revision                       ( revision                     ),  

                    .TIMERFVIREG                    ( TIMERFVIREG                  ),  
                    .TIMERFPL0REG                   ( TIMERFPL0REG                 ),  
                    .access_control                 ( int_cntacr                   ),  

                    .cntpu_cval_write_cntbasen      ( cntpu_cval_write_cntbasen    ),  
                    .cntpl_cval_write_cntbasen      ( cntpl_cval_write_cntbasen    ),  
                    .cntp_tval_write_cntbasen       ( cntp_tval_write_cntbasen     ),  
                    .cntp_ctl_write_cntbasen        ( cntp_ctl_write_cntbasen      ),  
                    .cntvu_cval_write_cntbasen      ( cntvu_cval_write_cntbasen    ),  
                    .cntvl_cval_write_cntbasen      ( cntvl_cval_write_cntbasen    ),  
                    .cntv_tval_write_cntbasen       ( cntv_tval_write_cntbasen     ),  
                    .cntv_ctl_write_cntbasen        ( cntv_ctl_write_cntbasen      ),  
                    .pwdata_enabled_cntbasen        ( pwdata_enabled_cntbasen      ),  
                    
                    .cntpu_cval_write_cntpl0basen   ( cntpu_cval_write_cntpl0basen ),  
                    .cntpl_cval_write_cntpl0basen   ( cntpl_cval_write_cntpl0basen ),  
                    .cntp_tval_write_cntpl0basen    ( cntp_tval_write_cntpl0basen  ),  
                    .cntp_ctl_write_cntpl0basen     ( cntp_ctl_write_cntpl0basen   ),  
                    .cntvu_cval_write_cntpl0basen   ( cntvu_cval_write_cntpl0basen ),  
                    .cntvl_cval_write_cntpl0basen   ( cntvl_cval_write_cntpl0basen ),  
                    .cntv_tval_write_cntpl0basen    ( cntv_tval_write_cntpl0basen  ),  
                    .cntv_ctl_write_cntpl0basen     ( cntv_ctl_write_cntpl0basen   ),  
                    .pwdata_enabled_cntpl0basen     ( pwdata_enabled_cntpl0basen   ),  

                    .virtual_offset                 ( int_cntvoff                  ),  
                    .timer_count_phys_in            ( cntpct_rd                    ),  
                    .compare_value_phys_in          ( cntpcval_rd                  ),  
                    .timer_value_phys_in            ( cntptval_rd                  ),  
                    .timer_control_phys_in          ( cntpctl_rd                   ),  
                    .timer_count_virt_in            ( cntvct_rd                    ),  
                    .compare_value_virt_in          ( cntvcval_rd                  ),  
                    .timer_value_virt_in            ( cntvtval_rd                  ),  
                    .timer_control_virt_in          ( cntvctl_rd                   )   
                     );


always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    int_tsvalueb <= 64'h0000_0000_0000_0000;
  else
    int_tsvalueb <= TSVALUEB;


gtimer_syncapb_core u_gtimer_syncapb_core_physical (
                    .clk                            ( PCLK                         ),  
                    .resetn                         ( PRESETn                      ),  

                    .tsvalueb                       ( int_tsvalueb                 ),  

                    .virtual_offset                 ( 64'h0000_0000_0000_0000      ),  

                    .compare_value_u_we_cntbasen    ( cntpu_cval_write_cntbasen    ),  
                    .compare_value_l_we_cntbasen    ( cntpl_cval_write_cntbasen    ),  
                    .timer_value_we_cntbasen        ( cntp_tval_write_cntbasen     ),  
                    .timer_control_we_cntbasen      ( cntp_ctl_write_cntbasen      ),  
                    .pwdata_enabled_cntbasen        ( pwdata_enabled_cntbasen      ),  

                    .compare_value_u_we_cntpl0basen ( cntpu_cval_write_cntpl0basen ),  
                    .compare_value_l_we_cntpl0basen ( cntpl_cval_write_cntpl0basen ),  
                    .timer_value_we_cntpl0basen     ( cntp_tval_write_cntpl0basen  ),  
                    .timer_control_we_cntpl0basen   ( cntp_ctl_write_cntpl0basen   ),  
                    .pwdata_enabled_cntpl0basen     ( pwdata_enabled_cntpl0basen   ),  

                    .timer_count                    ( cntpct_rd                    ),  
                    .compare_value                  ( cntpcval_rd                  ),  
                    .timer_value                    ( cntptval_rd                  ),  
                    .timer_control                  ( cntpctl_rd                   ),  

                    .interrupt_out                  ( GTIMERINTRPHYS               )   
                    );
                     
                     
gtimer_syncapb_core u_gtimer_syncapb_core_virtual (
                    .clk                            ( PCLK                         ),  
                    .resetn                         ( PRESETn                      ),  

                    .tsvalueb                       ( int_tsvalueb                 ),  

                    .virtual_offset                 ( int_cntvoff                  ),  

                    .compare_value_u_we_cntbasen    ( cntvu_cval_write_cntbasen    ),  
                    .compare_value_l_we_cntbasen    ( cntvl_cval_write_cntbasen    ),  
                    .timer_value_we_cntbasen        ( cntv_tval_write_cntbasen     ),  
                    .timer_control_we_cntbasen      ( cntv_ctl_write_cntbasen      ),  
                    .pwdata_enabled_cntbasen        ( pwdata_enabled_cntbasen      ),  

                    .compare_value_u_we_cntpl0basen ( cntvu_cval_write_cntpl0basen ),  
                    .compare_value_l_we_cntpl0basen ( cntvl_cval_write_cntpl0basen ),  
                    .timer_value_we_cntpl0basen     ( cntv_tval_write_cntpl0basen  ),  
                    .timer_control_we_cntpl0basen   ( cntv_ctl_write_cntpl0basen   ),  
                    .pwdata_enabled_cntpl0basen     ( pwdata_enabled_cntpl0basen   ),  

                    .timer_count                    ( cntvct_rd                    ),  
                    .compare_value                  ( cntvcval_rd                  ),  
                    .timer_value                    ( cntvtval_rd                  ),  
                    .timer_control                  ( cntvctl_rd                   ),  

                    .interrupt_out                  ( GTIMERINTRVIRT               )   
                     );


endmodule


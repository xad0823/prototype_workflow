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


module gcounter_syncapb_ts (
  input  wire         SCLK,                
  input  wire         SRESETn,             
  input  wire         PCLK,                
  input  wire         PRESETn,             

  input  wire         PSELCNTCONTROL,      
  input  wire  [11:2] PADDRCNTCONTROL,     
  input  wire         PENABLECNTCONTROL,   
  input  wire         PWRITECNTCONTROL,    
  input  wire  [31:0] PWDATACNTCONTROL,    
  output wire         PREADYCNTCONTROL,    
  output wire  [31:0] PRDATACNTCONTROL,    
  output wire         PSLVERRCNTCONTROL,   

  input  wire         PSELCNTREAD,         
  input  wire  [11:2] PADDRCNTREAD,        
  input  wire         PENABLECNTREAD,      
  input  wire         PWRITECNTREAD,       
  input  wire  [31:0] PWDATACNTREAD,       
  output wire         PREADYCNTREAD,       
  output wire  [31:0] PRDATACNTREAD,       
  output wire         PSLVERRCNTREAD,      
  
  input  wire         HALTREQ,             
  input  wire         RESTARTREQ,          
  output wire         RESTARTACK,          
 
  input  wire         PRELOAD_SYNC_EN,     
  input  wire         SYNC_STOP_CTR,       
  input  wire  [63:0] PRELOAD_SYNC_DATA,   
  
  output wire  [63:0] TSVALUEB,            
  output wire         TSFORCESYNC          
);


wire [3:0]   tieoff1;                  
wire [3:0]   tieoff2;                  
wire [3:0]   revision;                 

wire         sclktoggle;               

wire [63:0]  tsvalueb_sync;            

wire         dbgh;                     
wire         hdbg;                     

wire         enable_cnt;               
wire         ensync;                   

wire         preload_cnt_l;            
wire         preload_cnt_u;            
wire [31:0]  preload_cnt_data;         




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

gcounter_syncapb_revision  u_gcounter_syncapb_revision_0 (
                    .tieoff1           ( tieoff1[0]        ),  
                    .tieoff2           ( tieoff2[0]        ),  
                    .revision          ( revision[0]       )   
                     );

gcounter_syncapb_revision  u_gcounter_syncapb_revision_1 (
                    .tieoff1           ( tieoff1[1]        ),  
                    .tieoff2           ( tieoff2[1]        ),  
                    .revision          ( revision[1]       )   
                     );

gcounter_syncapb_revision  u_gcounter_syncapb_revision_2 (
                    .tieoff1           ( tieoff1[2]        ),  
                    .tieoff2           ( tieoff2[2]        ),  
                    .revision          ( revision[2]       )   
                     );

gcounter_syncapb_revision  u_gcounter_syncapb_revision_3 (
                    .tieoff1           ( tieoff1[3]        ),  
                    .tieoff2           ( tieoff2[3]        ),  
                    .revision          ( revision[3]       )   
                     );

gcounter_syncapb_apbif u_gcounter_syncapb_apbif (
                    .PCLK              ( PCLK              ),  
                    .PRESETn           ( PRESETn           ),  

                    .PADDRCNTCONTROL   ( PADDRCNTCONTROL   ),  
                    .PSELCNTCONTROL    ( PSELCNTCONTROL    ),  
                    .PENABLECNTCONTROL ( PENABLECNTCONTROL ),  
                    .PWRITECNTCONTROL  ( PWRITECNTCONTROL  ),  
                    .PWDATACNTCONTROL  ( PWDATACNTCONTROL  ),  

                    .PREADYCNTCONTROL  ( PREADYCNTCONTROL  ),  
                    .PRDATACNTCONTROL  ( PRDATACNTCONTROL  ),  
                    .PSLVERRCNTCONTROL ( PSLVERRCNTCONTROL ),  

                    .PADDRCNTREAD      ( PADDRCNTREAD      ),  
                    .PSELCNTREAD       ( PSELCNTREAD       ),  
                    .PENABLECNTREAD    ( PENABLECNTREAD    ),  
                    .PWRITECNTREAD     ( PWRITECNTREAD     ),  
                    .PWDATACNTREAD     ( PWDATACNTREAD     ),  

                    .PREADYCNTREAD     ( PREADYCNTREAD     ),  
                    .PRDATACNTREAD     ( PRDATACNTREAD     ),  
                    .PSLVERRCNTREAD    ( PSLVERRCNTREAD    ),  

                    .revision          ( revision          ),  
                    .tsvalueb          ( TSVALUEB          ),  
                    .dbgh              ( dbgh              ),  
                    .cntsv             ( tsvalueb_sync     ),  

                    .hdbg              ( hdbg              ),  
                    .enable_cnt        ( enable_cnt        ),  
                    .ensync            ( ensync            ),  
                    .preload_cnt_l     ( preload_cnt_l     ),  
                    .preload_cnt_u     ( preload_cnt_u     ),  
                    .preload_cnt_data  ( preload_cnt_data  )   
                     );



gcounter_syncapb_sclktoggle u_gcounter_syncapb_sclktoggle (
                    .clk               ( SCLK              ),  
                    .resetn            ( SRESETn           ),  
                    .sclktoggle        ( sclktoggle        )   
                    );
                    

gcounter_syncapb_counter_ts u_gcounter_syncapb_counter (
                    .PCLK              ( PCLK              ),  
                    .PRESETn           ( PRESETn           ),  
                    
                    .sclktoggle        ( sclktoggle        ),  
                    .tsvalueb_sync     ( tsvalueb_sync     ),  
                                        
                    .HALTREQ           ( HALTREQ           ),  
                    .RESTARTREQ        ( RESTARTREQ        ),  
                    .RESTARTACK        ( RESTARTACK        ),  
                    
                    .hdbg              ( hdbg              ),  
                    .dbgh              ( dbgh              ),  
                    
                    .enable_cnt        ( enable_cnt        ),  
                    .ensync            ( ensync            ),  
                    
                    .preload_cnt_l     ( preload_cnt_l     ),  
                    .preload_cnt_u     ( preload_cnt_u     ),  
                    .preload_cnt_data  ( preload_cnt_data  ),  

                    .preload_sync_en        ( PRELOAD_SYNC_EN   ),  
                    .synchronizer_stop_ctr  ( SYNC_STOP_CTR     ),  
                    .preload_sync_data      ( PRELOAD_SYNC_DATA ),  
                    
                    .TSVALUEB          ( TSVALUEB          ),  
                    .TSFORCESYNC       ( TSFORCESYNC       )   
                    );


endmodule


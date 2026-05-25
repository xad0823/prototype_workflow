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


module gcounter_asyncapb (
  input  wire         CCLK,                
  input  wire         CRESETn,             
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
  
  output wire  [63:0] TSVALUEB,            
  output wire         TSFORCESYNC          
);


wire [3:0]   tieoff1;                    
wire [3:0]   tieoff2;                    
wire [3:0]   revision;                   

wire         dbgh;                       
wire         hdbg;                       

wire         enable_cnt;                 

wire         cntcr_write_in_progress;    
wire         cntcr_write_complete;

wire         cntcvl_write_in_progress;   
wire         cntcvl_write_complete;
wire         cntcvu_write_in_progress;   
wire         cntcvu_write_complete;

wire [31:0]  preload_cntcvl_data;        
wire [31:0]  preload_cntcvu_data;        

wire         cclktoggle;                 


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

gcounter_asyncapb_revision  u_gcounter_asyncapb_revision_0 (
                    .tieoff1           ( tieoff1[0]        ),  
                    .tieoff2           ( tieoff2[0]        ),  
                    .revision          ( revision[0]       )   
                     );

gcounter_asyncapb_revision  u_gcounter_asyncapb_revision_1 (
                    .tieoff1           ( tieoff1[1]        ),  
                    .tieoff2           ( tieoff2[1]        ),  
                    .revision          ( revision[1]       )   
                     );

gcounter_asyncapb_revision  u_gcounter_asyncapb_revision_2 (
                    .tieoff1           ( tieoff1[2]        ),  
                    .tieoff2           ( tieoff2[2]        ),  
                    .revision          ( revision[2]       )   
                     );

gcounter_asyncapb_revision  u_gcounter_asyncapb_revision_3 (
                    .tieoff1           ( tieoff1[3]        ),  
                    .tieoff2           ( tieoff2[3]        ),  
                    .revision          ( revision[3]       )   
                     );

gcounter_asyncapb_apbif u_gcounter_asyncapb_apbif (
                    .PCLK                        ( PCLK                        ),  
                    .PRESETn                     ( PRESETn                     ),  

                    .PADDRCNTCONTROL             ( PADDRCNTCONTROL             ),  
                    .PSELCNTCONTROL              ( PSELCNTCONTROL              ),  
                    .PENABLECNTCONTROL           ( PENABLECNTCONTROL           ),  
                    .PWRITECNTCONTROL            ( PWRITECNTCONTROL            ),  
                    .PWDATACNTCONTROL            ( PWDATACNTCONTROL            ),  

                    .PREADYCNTCONTROL            ( PREADYCNTCONTROL            ),  
                    .PRDATACNTCONTROL            ( PRDATACNTCONTROL            ),  
                    .PSLVERRCNTCONTROL           ( PSLVERRCNTCONTROL           ),  

                    .PADDRCNTREAD                ( PADDRCNTREAD                ),  
                    .PSELCNTREAD                 ( PSELCNTREAD                 ),  
                    .PENABLECNTREAD              ( PENABLECNTREAD              ),  
                    .PWRITECNTREAD               ( PWRITECNTREAD               ),  
                    .PWDATACNTREAD               ( PWDATACNTREAD               ),  

                    .PREADYCNTREAD               ( PREADYCNTREAD               ),  
                    .PRDATACNTREAD               ( PRDATACNTREAD               ),  
                    .PSLVERRCNTREAD              ( PSLVERRCNTREAD              ),  

                    .revision                    ( revision                    ),  
                    .dbgh                        ( dbgh                        ),  

                    .cntcr_write_in_progress     ( cntcr_write_in_progress     ),  
                    .cntcr_write_complete        ( cntcr_write_complete        ),  
                    .hdbg                        ( hdbg                        ),  
                    .enable_cnt                  ( enable_cnt                  ),  
                    
                    .cntcvl_write_in_progress    ( cntcvl_write_in_progress    ),  
                    .cntcvl_write_complete       ( cntcvl_write_complete       ),  
                    .cntcvu_write_in_progress    ( cntcvu_write_in_progress    ),  
                    .cntcvu_write_complete       ( cntcvu_write_complete       ),  
                    .preload_cntcvl_data         ( preload_cntcvl_data         ),  
                    .preload_cntcvu_data         ( preload_cntcvu_data         ),  
                    
                    .TSVALUEB                    ( TSVALUEB                    ),  
                    .cclktoggle                  ( cclktoggle                  )   
                     );



gcounter_asyncapb_counter u_gcounter_asyncapb_counter (
                    .CCLK                        ( CCLK                        ),  
                    .CRESETn                     ( CRESETn                     ),  
                    
                    .HALTREQ                     ( HALTREQ                     ),  
                    .RESTARTREQ                  ( RESTARTREQ                  ),  
                    .RESTARTACK                  ( RESTARTACK                  ),  
                    
                    .cntcr_write_in_progress     ( cntcr_write_in_progress     ),  
                    .cntcr_write_complete        ( cntcr_write_complete        ),  
                    .hdbg                        ( hdbg                        ),  
                    .enable_cnt                  ( enable_cnt                  ),  
                    
                    .cntcvl_write_in_progress    ( cntcvl_write_in_progress    ),  
                    .cntcvl_write_complete       ( cntcvl_write_complete       ),  
                    .cntcvu_write_in_progress    ( cntcvu_write_in_progress    ),  
                    .cntcvu_write_complete       ( cntcvu_write_complete       ),  
                    .preload_cntcvl_data         ( preload_cntcvl_data         ),  
                    .preload_cntcvu_data         ( preload_cntcvu_data         ),  

                    .dbgh                        ( dbgh                        ),  
                    
                    .TSVALUEB                    ( TSVALUEB                    ),  
                    .TSFORCESYNC                 ( TSFORCESYNC                 ),  
                    
                    .cclktoggle                  ( cclktoggle                  )   
                    );



endmodule


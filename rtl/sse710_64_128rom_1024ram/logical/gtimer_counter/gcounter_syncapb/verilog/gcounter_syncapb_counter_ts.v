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


module gcounter_syncapb_counter_ts (
  input  wire         PCLK,              
  input  wire         PRESETn,           
  
  input  wire         sclktoggle,        
  output reg  [63:0]  tsvalueb_sync,     
    
  input  wire         HALTREQ,           
  input  wire         RESTARTREQ,        
  output wire         RESTARTACK,        
  
  input  wire         hdbg,              
  output reg          dbgh,              
  
  input  wire         enable_cnt,        
  input  wire         ensync,            
                                         
  input  wire         preload_cnt_l,     
  input  wire         preload_cnt_u,     
  input  wire [31:0]  preload_cnt_data,  

  input  wire [63:0]  preload_sync_data,     
  input  wire         preload_sync_en,       
  input  wire         synchronizer_stop_ctr, 

  output wire [63:0]  TSVALUEB,          
  output wire         TSFORCESYNC        
);


wire         sclksync;                 
wire          sclktoggle_sync;          
reg          sclktoggle_sync3;         

wire [63:0]  next_tsvalueb_sync;       

wire          haltreq_sync;             

wire          restartreq_sync;          

wire         next_dbgh;

reg          last_enable_cnt;
reg   [1:0]  counter_start_state;
reg   [1:0]  next_counter_start_state;

wire         counter_start_stopn;
wire         counter_preload_enable;
wire         counter_start_forcesync;

wire         preload_mux_u;
wire         preload_mux_l;
wire         counter_preload_mux_en;
wire  [31:0] preload_mux_cnt_data;

  always @(posedge PCLK or negedge PRESETn)
    if (~PRESETn)
      begin
       sclktoggle_sync3 <= 1'b0;
      end
    else
      begin
       sclktoggle_sync3 <= sclktoggle_sync;
      end
  
  gct_synchronizer u_sclktoggle_sync ( .clk( PCLK), .reset_n(PRESETn), .data_i(sclktoggle), .data_o(sclktoggle_sync) );
  
  assign sclksync = sclktoggle_sync3 ^ sclktoggle_sync;


  assign next_tsvalueb_sync = sclksync ? TSVALUEB : tsvalueb_sync;
  
  always @(posedge PCLK or negedge PRESETn)
    if (~PRESETn)
      tsvalueb_sync <= 64'h0000_0000_0000_0000;
    else
      tsvalueb_sync <= next_tsvalueb_sync;



  assign RESTARTACK = restartreq_sync;


  gct_synchronizer u_haltreq_sync ( .clk( PCLK), .reset_n(PRESETn), .data_i(HALTREQ),    .data_o(haltreq_sync) );
  gct_synchronizer u_restartreq_sync ( .clk( PCLK), .reset_n(PRESETn), .data_i(RESTARTREQ), .data_o(restartreq_sync) );
  
   
  assign next_dbgh = (hdbg & (haltreq_sync | dbgh) & (~restartreq_sync));

  always @(posedge PCLK or negedge PRESETn)
    if (~PRESETn)
      dbgh <= 1'b0;
    else
      dbgh <= next_dbgh;



  always @(posedge PCLK or negedge PRESETn)
    if (~PRESETn)
      last_enable_cnt <= 1'b0;
    else
      last_enable_cnt <= enable_cnt;


  always @*
   begin
    next_counter_start_state = counter_start_state;
    
    case (counter_start_state)
      2'b00 : if (~ensync & enable_cnt) 
                next_counter_start_state = 2'b11;
              else if (ensync & ~last_enable_cnt & enable_cnt)
                next_counter_start_state = 2'b10;
      2'b10 : if (~enable_cnt)
                next_counter_start_state = 2'b00;
              else if (sclksync & ~next_dbgh)
                next_counter_start_state = 2'b11;
      2'b11 : if (~enable_cnt)
                next_counter_start_state = 2'b00;
      default : next_counter_start_state = counter_start_state;
    endcase
   end
   
  always @(posedge PCLK or negedge PRESETn)
    if (~PRESETn)
      counter_start_state <= 2'b00;
    else
      counter_start_state <= next_counter_start_state;

  assign counter_start_forcesync        =  next_counter_start_state[0];
  assign counter_start_stopn            =  counter_start_state[0] & ~dbgh & ~preload_sync_en & ~synchronizer_stop_ctr;
  assign counter_preload_enable         = ~counter_start_state[1];         

  assign preload_mux_u =  preload_sync_en ? 1'b1 : preload_cnt_u;
  assign preload_mux_l =  preload_sync_en ? 1'b1 : preload_cnt_l;
  assign counter_preload_mux_en =  preload_sync_en ? 1'b1 : counter_preload_enable;
  assign preload_mux_cnt_data[31:0] =  preload_sync_en ? preload_sync_data[31:0] : preload_cnt_data[31:0];

gcounter_syncapb_counter_core_ts #(
                                .P    (5)
                               ) u_gcounter_syncapb_counter_core (
                    .clk                     ( PCLK                    ),  
                    .resetn                  ( PRESETn                 ),  

                    .counter_start_stopn     ( counter_start_stopn     ),  
                    .counter_preload_enable  ( counter_preload_mux_en  ),  
                    .preload_cnt_l           ( preload_mux_l           ),  
                    .preload_cnt_u           ( preload_mux_u           ),  
                    .preload_cnt_data        ( preload_mux_cnt_data    ),  
                    .preload_sync_data       ( preload_sync_data       ),  
                    .counter_start_forcesync ( counter_start_forcesync ),  

                    .tsvalueb                ( TSVALUEB                ),  
                    .tsforcesync             ( TSFORCESYNC             )   
                     );


endmodule

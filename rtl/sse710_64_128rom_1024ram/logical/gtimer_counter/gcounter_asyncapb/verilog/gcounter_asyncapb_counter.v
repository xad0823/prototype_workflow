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


module gcounter_asyncapb_counter (
  input  wire         CCLK,                        
  input  wire         CRESETn,                     
  
  input  wire         HALTREQ,                     
  input  wire         RESTARTREQ,                  
  output wire         RESTARTACK,                  
  
  input  wire         cntcr_write_in_progress,     
  output reg          cntcr_write_complete,
  input  wire         hdbg,                        
  
  input  wire         enable_cnt,                  
  
  input  wire         cntcvl_write_in_progress,    
  output wire         cntcvl_write_complete,
  input  wire         cntcvu_write_in_progress,    
  output wire         cntcvu_write_complete,
                                         
  input  wire [31:0]  preload_cntcvl_data,         
  input  wire [31:0]  preload_cntcvu_data,         

  output reg          dbgh,                        
  
  output wire [63:0]  TSVALUEB,                    
  output wire         TSFORCESYNC,                 
  
  output reg          cclktoggle                   
);


wire         enable_cnt_sync;                      

wire         hdbg_sync;                            

wire         haltreq_sync;                         

wire         restartreq_sync;                      

wire         next_dbgh;

wire         enable_counter;           

wire         preload_cntcvl;

wire         preload_cntcvu;
wire         cntcr_write_complete_t;

wire        enable_cnt_d;


assign   enable_cnt_d =  enable_cnt;
  gct_synchronizer  u_gct_synchronizer_enable_cnt
  (
    .clk     (CCLK                      ),
    .reset_n (CRESETn                   ),
    .data_i  (enable_cnt_d                ),
    .data_o  (enable_cnt_sync           )
  );
  
  gct_synchronizer  u_gct_synchronizer_hdbg
  (
    .clk     (CCLK                      ),
    .reset_n (CRESETn                   ),
    .data_i  (hdbg                      ),
    .data_o  (hdbg_sync                 )
  );

  gct_synchronizer  u_gct_synchronizer_cntcr_write_complete
  (
    .clk     (CCLK                      ),
    .reset_n (CRESETn                   ),
    .data_i  (cntcr_write_in_progress   ),
    .data_o  (cntcr_write_complete_t      )
  );
                    
  gct_synchronizer  u_gct_synchronizer_haltreq
  (
    .clk     (CCLK                      ),
    .reset_n (CRESETn                   ),
    .data_i  (HALTREQ                   ),
    .data_o  (haltreq_sync              )
  );
                    
  gct_synchronizer  u_gct_synchronizer_restartreq
  (
    .clk     (CCLK                      ),
    .reset_n (CRESETn                   ),
    .data_i  (RESTARTREQ                ),
    .data_o  (restartreq_sync           )
  );
  

  assign RESTARTACK = restartreq_sync;


  assign next_dbgh  = (hdbg_sync & (haltreq_sync | dbgh) & (~restartreq_sync));

  always @(posedge CCLK or negedge CRESETn)
    if (~CRESETn)
      dbgh <= 1'b0;
    else
      dbgh <= next_dbgh;

      
  assign enable_counter = enable_cnt_sync & (~dbgh);
  
  always @(posedge CCLK or negedge CRESETn)
    if (~CRESETn)
      cntcr_write_complete <= 1'b0;
    else
      cntcr_write_complete <= cntcr_write_complete_t;
gct_syncpulse u_gct_syncpulse_preload_cntcvl (
                    .clk     ( CCLK                         ),
                    .reset_n ( CRESETn                      ),
                    .data_i  ( cntcvl_write_in_progress     ),
                    .pulse_o ( preload_cntcvl               ),
                    .ack_o   ( cntcvl_write_complete        )
                    );

gct_syncpulse u_gct_syncpulse_preload_cntcvu (
                    .clk     ( CCLK                         ),
                    .reset_n ( CRESETn                      ),
                    .data_i  ( cntcvu_write_in_progress     ),
                    .pulse_o ( preload_cntcvu               ),
                    .ack_o   ( cntcvu_write_complete        )
                    );


gcounter_asyncapb_counter_core #(
                                .P    (5)
                                ) u_gcounter_asyncapb_counter_core (
                    .clk                     ( CCLK                    ),  
                    .resetn                  ( CRESETn                 ),  

                    .enable_counter          ( enable_counter          ),  
                    .preload_cntcvl          ( preload_cntcvl          ),  
                    .preload_cntcvu          ( preload_cntcvu          ),  
                    .preload_cntcvl_data     ( preload_cntcvl_data     ),  
                    .preload_cntcvu_data     ( preload_cntcvu_data     ),  

                    .tsvalueb                ( TSVALUEB                ),  
                    .tsforcesync             ( TSFORCESYNC             )   
                     );

  always @(posedge CCLK or negedge CRESETn)
    if (~CRESETn)
      cclktoggle <= 1'b0;
    else
      cclktoggle <= ~cclktoggle;





endmodule

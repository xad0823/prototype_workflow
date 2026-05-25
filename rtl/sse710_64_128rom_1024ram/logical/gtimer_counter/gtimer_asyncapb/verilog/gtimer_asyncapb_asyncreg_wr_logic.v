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


module gtimer_asyncapb_asyncreg_wr_logic (
  input  wire         PCLK,
  input  wire         PRESETn,

  input  wire         write_setup_cntbasen,       
  input  wire         write_setup_cntpl0basen,    
  input  wire         write_complete_pulse,       

  output wire         latch_wdata,                
  output reg          latch_cntbasen_wdata,       
  output reg          latch_cntpl0basen_wdata,    
  output wire         write_in_progress,          
  output reg          write_in_progress_toggle,   
  
  output reg          next_preadycntbasen,        
  output reg          next_preadycntpl0basen      
);


parameter GTA_WRSM_IDLE      = 4'b0000;

parameter GTA_WRSM_WRA       = 4'b0001;
parameter GTA_WRSM_WIPA      = 4'b0011;
parameter GTA_WRSM_WIPA_WRB  = 4'b0111;
parameter GTA_WRSM_ACMP_WIPB = 4'b0101;
parameter GTA_WRSM_WRAB_A    = 4'b0110;

parameter GTA_WRSM_WRB       = 4'b1000;
parameter GTA_WRSM_WIPB      = 4'b1001;
parameter GTA_WRSM_WIPB_WRA  = 4'b1011;
parameter GTA_WRSM_BCMP_WIPA = 4'b1111;
parameter GTA_WRSM_WRAB_B    = 4'b1010;


wire       next_pl0wins;
reg        pl0wins;

reg        write_in_progress_cntbasen;
reg        write_in_progress_cntpl0basen;

reg  [3:0] next_gta_wrsm_state;
reg  [3:0] gta_wrsm_state;

wire       next_write_in_progress_toggle;


assign  next_pl0wins = write_complete_pulse ? write_in_progress_cntbasen : pl0wins;
  
always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    pl0wins <= 1'b0;
  else
    pl0wins <= next_pl0wins;



always @*
  begin
    latch_cntbasen_wdata = 1'b0;
    latch_cntpl0basen_wdata = 1'b0;
    
    case (gta_wrsm_state)
      GTA_WRSM_IDLE      : begin
                              next_preadycntbasen = 1'b1;
                              next_preadycntpl0basen = 1'b1;
                              write_in_progress_cntbasen = 1'b0;
                              write_in_progress_cntpl0basen = 1'b0;
                              
                              if (write_setup_cntbasen & ~write_setup_cntpl0basen)
                                begin
                                  next_preadycntbasen = 1'b0;
                                  next_gta_wrsm_state = GTA_WRSM_WRA;
                                end
                              else if (~write_setup_cntbasen & write_setup_cntpl0basen)
                                     begin
                                       next_preadycntpl0basen = 1'b0;
                                       next_gta_wrsm_state = GTA_WRSM_WRB;
                                     end
                              else if (write_setup_cntbasen & write_setup_cntpl0basen)
                                     if (pl0wins)
                                       begin
                                         next_preadycntbasen = 1'b0;
                                         next_preadycntpl0basen = 1'b0;
                                         next_gta_wrsm_state = GTA_WRSM_WRAB_B;
                                       end
                                     else
                                       begin
                                         next_preadycntbasen = 1'b0;
                                         next_preadycntpl0basen = 1'b0;
                                         next_gta_wrsm_state = GTA_WRSM_WRAB_A;
                                       end
                              else
                                next_gta_wrsm_state = GTA_WRSM_IDLE;
                           end
  
  
      GTA_WRSM_WRA       : begin
                              next_preadycntbasen = 1'b0;
                              next_preadycntpl0basen = 1'b1;
                              write_in_progress_cntbasen = 1'b0;
                              write_in_progress_cntpl0basen = 1'b0;
                              
                              if (write_setup_cntpl0basen)
                                begin
                                  latch_cntbasen_wdata = 1'b1;
                                  next_preadycntpl0basen = 1'b0;
                                  next_gta_wrsm_state = GTA_WRSM_WIPA_WRB;
                                end
                              else
                                begin
                                  latch_cntbasen_wdata = 1'b1;
                                  next_gta_wrsm_state = GTA_WRSM_WIPA;
                                end
                           end
  
      GTA_WRSM_WIPA      : begin
                              next_preadycntbasen = 1'b0;
                              next_preadycntpl0basen = 1'b1;
                              write_in_progress_cntbasen = 1'b1;
                              write_in_progress_cntpl0basen = 1'b0;
                              
                              if (write_complete_pulse & ~write_setup_cntpl0basen)
                                begin
                                  next_preadycntbasen = 1'b1;
                                  next_gta_wrsm_state = GTA_WRSM_IDLE;
                                end
                              else if (write_complete_pulse & write_setup_cntpl0basen)
                                     begin
                                       next_preadycntbasen = 1'b1;
                                       next_preadycntpl0basen = 1'b0;
                                       next_gta_wrsm_state = GTA_WRSM_WRB;
                                     end
                              else if (write_setup_cntpl0basen & ~write_complete_pulse)
                                     begin
                                       next_preadycntpl0basen = 1'b0;
                                       next_gta_wrsm_state = GTA_WRSM_WIPA_WRB;
                                     end
                              else
                                next_gta_wrsm_state = GTA_WRSM_WIPA;
                           end
  
      GTA_WRSM_WIPA_WRB  : begin
                              next_preadycntbasen = 1'b0;
                              next_preadycntpl0basen = 1'b0;
                              write_in_progress_cntbasen = 1'b1;
                              write_in_progress_cntpl0basen = 1'b0;
                              
                              if (write_complete_pulse)
                                begin
                                  latch_cntpl0basen_wdata = 1'b1;
                                  next_preadycntbasen = 1'b1;
                                  next_gta_wrsm_state = GTA_WRSM_ACMP_WIPB;
                                end
                              else
                                next_gta_wrsm_state = GTA_WRSM_WIPA_WRB;
                           end
  
      GTA_WRSM_ACMP_WIPB : begin
                              next_preadycntbasen = 1'b1;
                              next_preadycntpl0basen = 1'b0;
                              write_in_progress_cntbasen = 1'b0;
                              write_in_progress_cntpl0basen = 1'b1;
                              
                              if (write_complete_pulse & ~write_setup_cntbasen)
                                begin
                                  next_preadycntpl0basen = 1'b1;
                                  next_gta_wrsm_state = GTA_WRSM_IDLE;
                                end
                              else if (write_complete_pulse & write_setup_cntbasen)
                                     begin
                                       next_preadycntbasen = 1'b0;
                                       next_preadycntpl0basen = 1'b1;
                                       next_gta_wrsm_state = GTA_WRSM_WRA;
                                     end
                              else if (write_setup_cntbasen & ~write_complete_pulse)
                                     begin
                                       next_preadycntbasen = 1'b0;
                                       next_gta_wrsm_state = GTA_WRSM_WIPB_WRA;
                                     end
                              else
                                next_gta_wrsm_state = GTA_WRSM_ACMP_WIPB;
                           end
  
      GTA_WRSM_WRAB_A    : begin
                              next_preadycntbasen = 1'b0;
                              next_preadycntpl0basen = 1'b0;
                              write_in_progress_cntbasen = 1'b0;
                              write_in_progress_cntpl0basen = 1'b0;
  
                              latch_cntbasen_wdata = 1'b1;
                              next_gta_wrsm_state = GTA_WRSM_WIPA_WRB;
                           end
  
  
      GTA_WRSM_WRB       : begin
                              next_preadycntbasen = 1'b1;
                              next_preadycntpl0basen = 1'b0;
                              write_in_progress_cntbasen = 1'b0;
                              write_in_progress_cntpl0basen = 1'b0;
                              
                              if (write_setup_cntbasen)
                                begin
                                  latch_cntpl0basen_wdata = 1'b1;
                                  next_preadycntbasen = 1'b0;
                                  next_gta_wrsm_state = GTA_WRSM_WIPB_WRA;
                                end
                              else
                                begin
                                  latch_cntpl0basen_wdata = 1'b1;
                                  next_gta_wrsm_state = GTA_WRSM_WIPB;
                                end
                           end
  
      GTA_WRSM_WIPB      : begin
                              next_preadycntbasen = 1'b1;
                              next_preadycntpl0basen = 1'b0;
                              write_in_progress_cntbasen = 1'b0;
                              write_in_progress_cntpl0basen = 1'b1;
                              
                              if (write_complete_pulse & ~write_setup_cntbasen)
                                begin
                                  next_preadycntpl0basen = 1'b1;
                                  next_gta_wrsm_state = GTA_WRSM_IDLE;
                                end
                              else if (write_complete_pulse & write_setup_cntbasen)
                                     begin
                                       next_preadycntbasen = 1'b0;
                                       next_preadycntpl0basen = 1'b1;
                                       next_gta_wrsm_state = GTA_WRSM_WRA;
                                     end
                              else if (write_setup_cntbasen & ~write_complete_pulse)
                                     begin
                                       next_preadycntbasen = 1'b0;
                                       next_gta_wrsm_state = GTA_WRSM_WIPB_WRA;
                                     end
                              else
                                next_gta_wrsm_state = GTA_WRSM_WIPB;
                           end
  
      GTA_WRSM_WIPB_WRA  : begin
                              next_preadycntbasen = 1'b0;
                              next_preadycntpl0basen = 1'b0;
                              write_in_progress_cntbasen = 1'b0;
                              write_in_progress_cntpl0basen = 1'b1;
                              
                              if (write_complete_pulse)
                                begin
                                  latch_cntbasen_wdata = 1'b1;
                                  next_preadycntpl0basen = 1'b1;
                                  next_gta_wrsm_state = GTA_WRSM_BCMP_WIPA;
                                end
                              else
                                next_gta_wrsm_state = GTA_WRSM_WIPB_WRA;
                           end
  
      GTA_WRSM_BCMP_WIPA : begin
                              next_preadycntbasen = 1'b0;
                              next_preadycntpl0basen = 1'b1;
                              write_in_progress_cntbasen = 1'b1;
                              write_in_progress_cntpl0basen = 1'b0;
                              
                              if (write_complete_pulse & ~write_setup_cntpl0basen)
                                begin
                                  next_preadycntbasen = 1'b1;
                                  next_gta_wrsm_state = GTA_WRSM_IDLE;
                                end
                              else if (write_complete_pulse & write_setup_cntpl0basen)
                                     begin
                                       next_preadycntbasen = 1'b1;
                                       next_preadycntpl0basen = 1'b0;
                                       next_gta_wrsm_state = GTA_WRSM_WRB;
                                     end
                              else if (write_setup_cntpl0basen & ~write_complete_pulse)
                                     begin
                                       next_preadycntpl0basen = 1'b0;
                                       next_gta_wrsm_state = GTA_WRSM_WIPA_WRB;
                                     end
                              else
                                next_gta_wrsm_state = GTA_WRSM_BCMP_WIPA;
                           end
  
      GTA_WRSM_WRAB_B    : begin
                              next_preadycntbasen = 1'b0;
                              next_preadycntpl0basen = 1'b0;
                              write_in_progress_cntbasen = 1'b0;
                              write_in_progress_cntpl0basen = 1'b0;
  
                              latch_cntpl0basen_wdata = 1'b1;
                              next_gta_wrsm_state = GTA_WRSM_WIPB_WRA;
                           end
  
                 default : begin
                             next_preadycntbasen = 1'b1;
                             next_preadycntpl0basen = 1'b1;
                             write_in_progress_cntbasen = 1'b0;
                             write_in_progress_cntpl0basen = 1'b0;
                              
                             next_gta_wrsm_state = GTA_WRSM_IDLE;
                           end
    endcase
  end

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    gta_wrsm_state <= GTA_WRSM_IDLE;
  else
    gta_wrsm_state <= next_gta_wrsm_state;


assign latch_wdata = latch_cntbasen_wdata | latch_cntpl0basen_wdata;


assign write_in_progress = write_in_progress_cntbasen | write_in_progress_cntpl0basen;


assign next_write_in_progress_toggle = latch_wdata ? ~write_in_progress_toggle : write_in_progress_toggle;

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    write_in_progress_toggle <= 1'b0;
  else
    write_in_progress_toggle <= next_write_in_progress_toggle;


endmodule

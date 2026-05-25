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


module gtimer_asyncapb_regwrite_logic (
  input  wire         PCLK,
  input  wire         PRESETn,
  input  wire [31:0]  pwdata_enabled_cntbasen,
  input  wire [31:0]  pwdata_enabled_cntpl0basen,

  input  wire         cntl_cval_wsetup_cntbasen,
  input  wire         cntl_cval_wsetup_cntpl0basen,
  input  wire         cntl_cval_write_complete_pulse,
  output wire         cntl_cval_latch_wdata,
  output wire         cntl_cval_write_in_progress,
  output wire         cntl_cval_write_in_progress_toggle,
  output reg  [31:0]  cntl_cval_write_val,

  input  wire         cntu_cval_wsetup_cntbasen,
  input  wire         cntu_cval_wsetup_cntpl0basen,
  input  wire         cntu_cval_write_complete_pulse,
  output wire         cntu_cval_latch_wdata,
  output wire         cntu_cval_write_in_progress,
  output wire         cntu_cval_write_in_progress_toggle,
  output reg  [31:0]  cntu_cval_write_val,

  input  wire         cnt_tval_wsetup_cntbasen,
  input  wire         cnt_tval_wsetup_cntpl0basen,
  input  wire         cnt_tval_write_complete_pulse,
  output wire         cnt_tval_latch_wdata,
  output wire         cnt_tval_write_in_progress,
  output wire         cnt_tval_write_in_progress_toggle,
  output reg  [31:0]  cnt_tval_write_val,

  input  wire         cnt_ctl_wsetup_cntbasen,
  input  wire         cnt_ctl_wsetup_cntpl0basen,
  input  wire         cnt_ctl_write_complete_pulse,
  output wire         cnt_ctl_latch_wdata,
  output wire         cnt_ctl_write_in_progress,
  output wire         cnt_ctl_write_in_progress_toggle,
  output reg  [1:0]   cnt_ctl_write_val,

  output wire         next_preadycntbasen,
  output wire         next_preadycntpl0basen
  );

reg  [31:0]  cntl_cval_next_write_val;
reg  [31:0]  cntu_cval_next_write_val;
reg  [31:0]  cnt_tval_next_write_val;
reg  [1:0]   cnt_ctl_next_write_val;


wire         cntl_cval_latch_cntbasen_wdata;
wire         cntl_cval_latch_cntpl0basen_wdata;
wire         cntl_cval_next_preadycntbasen;
wire         cntu_cval_next_preadycntbasen;
wire         cnt_tval_next_preadycntbasen;
wire         cnt_ctl_next_preadycntbasen;

wire         cntl_cval_next_preadycntpl0basen;
wire         cntu_cval_next_preadycntpl0basen;
wire         cnt_tval_next_preadycntpl0basen;
wire         cnt_ctl_next_preadycntpl0basen;
wire         cntu_cval_latch_cntbasen_wdata;
wire         cntu_cval_latch_cntpl0basen_wdata;
wire         cnt_tval_latch_cntbasen_wdata;
wire         cnt_tval_latch_cntpl0basen_wdata;
wire         cnt_ctl_latch_cntbasen_wdata;
wire         cnt_ctl_latch_cntpl0basen_wdata;

gtimer_asyncapb_asyncreg_wr_logic u_gtimer_asyncapb_asyncreg_wr_logic_cntl_cval (
                    .PCLK                           ( PCLK                               ),  
                    .PRESETn                        ( PRESETn                            ),  
                    .write_setup_cntbasen           ( cntl_cval_wsetup_cntbasen          ),  
                    .write_setup_cntpl0basen        ( cntl_cval_wsetup_cntpl0basen       ),  
                    .write_complete_pulse           ( cntl_cval_write_complete_pulse     ),  
                    .latch_wdata                    ( cntl_cval_latch_wdata              ),  
                    .latch_cntbasen_wdata           ( cntl_cval_latch_cntbasen_wdata     ),  
                    .latch_cntpl0basen_wdata        ( cntl_cval_latch_cntpl0basen_wdata  ),  
                    .write_in_progress              ( cntl_cval_write_in_progress        ),  
                    .write_in_progress_toggle       ( cntl_cval_write_in_progress_toggle ),  
                    .next_preadycntbasen            ( cntl_cval_next_preadycntbasen      ),  
                    .next_preadycntpl0basen         ( cntl_cval_next_preadycntpl0basen   )   
                    );

always @*
  case ({cntl_cval_latch_cntpl0basen_wdata, cntl_cval_latch_cntbasen_wdata})
    2'b00 : cntl_cval_next_write_val  = cntl_cval_write_val;
    2'b01 : cntl_cval_next_write_val = pwdata_enabled_cntbasen;
    2'b10 : cntl_cval_next_write_val = pwdata_enabled_cntpl0basen;
    default : cntl_cval_next_write_val  = cntl_cval_write_val; 
  endcase
    
always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
     cntl_cval_write_val <= 32'h0000_0000;
  else
     cntl_cval_write_val <= cntl_cval_next_write_val;
     

gtimer_asyncapb_asyncreg_wr_logic u_gtimer_asyncapb_asyncreg_wr_logic_cntu_cval (
                    .PCLK                           ( PCLK                               ),  
                    .PRESETn                        ( PRESETn                            ),  
                    .write_setup_cntbasen           ( cntu_cval_wsetup_cntbasen          ),  
                    .write_setup_cntpl0basen        ( cntu_cval_wsetup_cntpl0basen       ),  
                    .write_complete_pulse           ( cntu_cval_write_complete_pulse     ),  
                    .latch_wdata                    ( cntu_cval_latch_wdata              ),  
                    .latch_cntbasen_wdata           ( cntu_cval_latch_cntbasen_wdata     ),  
                    .latch_cntpl0basen_wdata        ( cntu_cval_latch_cntpl0basen_wdata  ),  
                    .write_in_progress              ( cntu_cval_write_in_progress        ),  
                    .write_in_progress_toggle       ( cntu_cval_write_in_progress_toggle ),  
                    .next_preadycntbasen            ( cntu_cval_next_preadycntbasen      ),  
                    .next_preadycntpl0basen         ( cntu_cval_next_preadycntpl0basen   )   
                    );

always @*
  case ({cntu_cval_latch_cntpl0basen_wdata, cntu_cval_latch_cntbasen_wdata})
    2'b00 : cntu_cval_next_write_val  = cntu_cval_write_val;
    2'b01 : cntu_cval_next_write_val = pwdata_enabled_cntbasen;
    2'b10 : cntu_cval_next_write_val = pwdata_enabled_cntpl0basen;
    default : cntu_cval_next_write_val  = cntu_cval_write_val; 
  endcase
    
always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
     cntu_cval_write_val <= 32'h0000_0000;
  else
     cntu_cval_write_val <= cntu_cval_next_write_val;
     

gtimer_asyncapb_asyncreg_wr_logic u_gtimer_asyncapb_asyncreg_wr_logic_cnt_tval (
                    .PCLK                           ( PCLK                              ),  
                    .PRESETn                        ( PRESETn                           ),  
                    .write_setup_cntbasen           ( cnt_tval_wsetup_cntbasen          ),  
                    .write_setup_cntpl0basen        ( cnt_tval_wsetup_cntpl0basen       ),  
                    .write_complete_pulse           ( cnt_tval_write_complete_pulse     ),  
                    .latch_wdata                    ( cnt_tval_latch_wdata              ),  
                    .latch_cntbasen_wdata           ( cnt_tval_latch_cntbasen_wdata     ),  
                    .latch_cntpl0basen_wdata        ( cnt_tval_latch_cntpl0basen_wdata  ),  
                    .write_in_progress              ( cnt_tval_write_in_progress        ),  
                    .write_in_progress_toggle       ( cnt_tval_write_in_progress_toggle ),  
                    .next_preadycntbasen            ( cnt_tval_next_preadycntbasen      ),  
                    .next_preadycntpl0basen         ( cnt_tval_next_preadycntpl0basen   )   
                    );

always @*
  case ({cnt_tval_latch_cntpl0basen_wdata, cnt_tval_latch_cntbasen_wdata})
    2'b00 : cnt_tval_next_write_val  = cnt_tval_write_val;
    2'b01 : cnt_tval_next_write_val = pwdata_enabled_cntbasen;
    2'b10 : cnt_tval_next_write_val = pwdata_enabled_cntpl0basen;
    default : cnt_tval_next_write_val  = cnt_tval_write_val; 
  endcase
    
always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
     cnt_tval_write_val <= 32'h0000_0000;
  else
     cnt_tval_write_val <= cnt_tval_next_write_val;
     

gtimer_asyncapb_asyncreg_wr_logic u_gtimer_asyncapb_asyncreg_wr_logic_cnt_ctl (
                    .PCLK                           ( PCLK                              ),  
                    .PRESETn                        ( PRESETn                           ),  
                    .write_setup_cntbasen           ( cnt_ctl_wsetup_cntbasen           ),  
                    .write_setup_cntpl0basen        ( cnt_ctl_wsetup_cntpl0basen        ),  
                    .write_complete_pulse           ( cnt_ctl_write_complete_pulse      ),  
                    .latch_wdata                    ( cnt_ctl_latch_wdata               ),  
                    .latch_cntbasen_wdata           ( cnt_ctl_latch_cntbasen_wdata      ),  
                    .latch_cntpl0basen_wdata        ( cnt_ctl_latch_cntpl0basen_wdata   ),  
                    .write_in_progress              ( cnt_ctl_write_in_progress         ),  
                    .write_in_progress_toggle       ( cnt_ctl_write_in_progress_toggle  ),  
                    .next_preadycntbasen            ( cnt_ctl_next_preadycntbasen       ),  
                    .next_preadycntpl0basen         ( cnt_ctl_next_preadycntpl0basen    )   
                    );

always @*
  case ({cnt_ctl_latch_cntpl0basen_wdata, cnt_ctl_latch_cntbasen_wdata})
    2'b00 : cnt_ctl_next_write_val = cnt_ctl_write_val;
    2'b01 : cnt_ctl_next_write_val = pwdata_enabled_cntbasen[1:0];
    2'b10 : cnt_ctl_next_write_val = pwdata_enabled_cntpl0basen[1:0];
    default : cnt_ctl_next_write_val  = cnt_ctl_write_val; 
  endcase
    
always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
     cnt_ctl_write_val <= 2'b00;
  else
     cnt_ctl_write_val <= cnt_ctl_next_write_val;
     

assign next_preadycntbasen    = cntl_cval_next_preadycntbasen &
                                cntu_cval_next_preadycntbasen &
                                cnt_tval_next_preadycntbasen  &
                                cnt_ctl_next_preadycntbasen;

assign next_preadycntpl0basen = cntl_cval_next_preadycntpl0basen &
                                cntu_cval_next_preadycntpl0basen &
                                cnt_tval_next_preadycntpl0basen  &
                                cnt_ctl_next_preadycntpl0basen;
                             
endmodule

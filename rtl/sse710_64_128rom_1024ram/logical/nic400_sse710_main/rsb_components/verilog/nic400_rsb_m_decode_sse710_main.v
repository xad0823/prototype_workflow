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


module nic400_rsb_m_decode_sse710_main
  (
   rclk,
   rresetn,

   rsb_data_s,
   rsb_valid_s,
   rsb_ready_s,

   rsb_data_pass,
   rsb_valid_pass,
   rsb_ready_pass,

   wlast_strbless,

   tx_done,

   tx_last,

   dbnr,
   ddata,
   dresp,
   dlast,
   dvalid,
   dready

   );

`include "nic400_rsb_defs_sse710_main.v"

  parameter MID_VALUE = 0;
  parameter ADR_LENGTH = 2;
  parameter DAT_LENGTH = 4;

  parameter FIFO_DEPTH = 3 + ADR_LENGTH + DAT_LENGTH;
  parameter FIFO_MAX = FIFO_DEPTH - 1;
  
  input                   rclk;         
  input                   rresetn;      

  input             [7:0] rsb_data_s;
  input                   rsb_valid_s;
  output                  rsb_ready_s;
  
  output            [7:0] rsb_data_pass;
  output                  rsb_valid_pass;
  input                   rsb_ready_pass;

  input                   wlast_strbless;

  output                  tx_done;

  output                  tx_last;
  
  output                  dbnr;         
  output           [31:0] ddata;        
  output            [1:0] dresp;        
  output                  dlast;        
  output                  dvalid;       
  input                   dready;       



  reg [7:0]               rsb_fifo [FIFO_MAX:0];
  reg [FIFO_MAX:0]        rsb_fifo_en;
  reg [4:0]               rsb_fifo_w_ptr;
  wire                    rsb_fifo_w_ptr_en;
  wire [4:0]              rsb_fifo_w_ptr_nxt;
  reg [4:0]               rsb_fifo_r_ptr;
  wire                    rsb_fifo_r_ptr_en;
  wire [4:0]              rsb_fifo_r_ptr_nxt;
  wire                    rsb_fifo_push;
  wire                    rsb_fifo_pop;
  wire                    rsb_fifo_clear;
  wire                    rsb_fifo_full;
  wire                    rsb_fifo_empty;
  wire                    pass_enable;
  reg                     pass_enable_reg;
  wire                    pass_enable_reg_en;
  wire                    axi_valid;
  wire                    tx_last_nxt;
  reg                     tx_last;
  reg                     tx_done;
  wire [7:0]              ctl_reg;
  wire                    err_reg_nxt;
  wire                    err_reg_en;
  reg                     err_reg;
  wire                    i_rsb_valid_pass;
  wire                    i_rsb_ready_s;
  wire                    wlast_strbless_h;
  reg                     wlast_strbless_reg;
  

  assign rsb_fifo_w_ptr_nxt = ((rsb_fifo_w_ptr[3:0] == FIFO_MAX)
                               ? {~rsb_fifo_w_ptr[4],4'b0000}
                               : {rsb_fifo_w_ptr[4],
                                  (rsb_fifo_w_ptr[3:0] + 4'b0001)}
                               );

  assign rsb_fifo_w_ptr_en = rsb_fifo_push;

  always @(posedge rclk or negedge rresetn)
  begin : p_rsb_fifo_w_ptr
    if (~rresetn)
      rsb_fifo_w_ptr <= {5{1'b0}};
    else if (rsb_fifo_w_ptr_en)
      rsb_fifo_w_ptr <= rsb_fifo_w_ptr_nxt;
  end

  assign rsb_fifo_r_ptr_nxt = (((rsb_fifo_r_ptr[3:0] == FIFO_MAX) |
                                rsb_fifo_clear) ? {~rsb_fifo_r_ptr[4],4'b0000}
                               : {rsb_fifo_r_ptr[4],
                                  (rsb_fifo_r_ptr[3:0] + 4'b0001)}
                               );

  assign rsb_fifo_r_ptr_en = rsb_fifo_pop | rsb_fifo_clear;

  always @(posedge rclk or negedge rresetn)
  begin : p_rsb_fifo_r_ptr
    if (~rresetn)
      rsb_fifo_r_ptr <= {5{1'b0}};
    else if (rsb_fifo_r_ptr_en)
      rsb_fifo_r_ptr <= rsb_fifo_r_ptr_nxt;
  end

  assign rsb_fifo_full = ((rsb_fifo_r_ptr[4] != rsb_fifo_w_ptr[4]) &
                          (rsb_fifo_r_ptr[3:0] == rsb_fifo_w_ptr[3:0]));

  assign rsb_fifo_empty = (rsb_fifo_r_ptr == rsb_fifo_w_ptr);

  always @(rsb_fifo_w_ptr or rsb_fifo_push)
  begin : p_rsb_fifo_enables
    integer i;
    for (i=0; i<FIFO_DEPTH; i=i+1) begin
      rsb_fifo_en[i] = ({{28{1'b0}},rsb_fifo_w_ptr[3:0]} == i) & rsb_fifo_push;
    end
  end

  always @(posedge rclk)
  begin : p_rsb_fifo
    integer i;
    for (i=0; i<FIFO_DEPTH; i=i+1)
      if (rsb_fifo_en[i])
        rsb_fifo[i] <= rsb_data_s;
  end

  assign i_rsb_ready_s = ~rsb_fifo_full;
  assign rsb_ready_s = i_rsb_ready_s;

  assign i_rsb_valid_pass = pass_enable & ~rsb_fifo_empty;
  assign rsb_valid_pass = i_rsb_valid_pass;
  assign rsb_data_pass = rsb_fifo[rsb_fifo_r_ptr[3:0]];

  assign rsb_fifo_push = rsb_valid_s & i_rsb_ready_s;
  assign rsb_fifo_pop = i_rsb_valid_pass & rsb_ready_pass;

  assign pass_enable = ((rsb_fifo_r_ptr[3:0] != `STATE_ADN) ? pass_enable_reg
                        : (((rsb_fifo_w_ptr[3:0] > `STATE_MID) | rsb_fifo_full)
                           & (rsb_fifo[`STATE_MID] != MID_VALUE)));

  assign pass_enable_reg_en = (rsb_fifo_r_ptr[3:0] == `STATE_ADN);
 
  always @(posedge rclk or negedge rresetn)
  begin : p_pass_enable
    if (~rresetn)
      pass_enable_reg <= 1'b0;
    else if (pass_enable_reg_en)
      pass_enable_reg <= pass_enable;
  end

  assign axi_valid = rsb_fifo_full & ~pass_enable;

  assign rsb_fifo_clear = axi_valid & (dready | (~ctl_reg[0] & ~ctl_reg[6]));
  

  assign err_reg_nxt = tx_last_nxt ? 1'b0
                         : (((ctl_reg[7] | ctl_reg[5]) &
                             (rsb_fifo[`STATE_MID] == MID_VALUE)) |
                            err_reg);

  assign err_reg_en = tx_last_nxt | rsb_fifo_en[`STATE_ADR1];
  
  always @(posedge rclk or negedge rresetn)
  begin : p_err_reg
    if (~rresetn)
      err_reg <= 1'b0;
    else if (err_reg_en)
      err_reg <= err_reg_nxt;
  end



  assign wlast_strbless_h = wlast_strbless ? 1'b1 :
                                   (dready ? 1'b0 : wlast_strbless_reg);

  always @(posedge rclk or negedge rresetn)
  begin : p_wlast_strbless_reg
    if (~rresetn)
      wlast_strbless_reg <= 1'b0;
    else
      wlast_strbless_reg <= wlast_strbless_h;
  end

  assign ctl_reg = rsb_fifo[`STATE_CTL];

  assign dbnr = ~ctl_reg[0] | wlast_strbless_reg;
  assign ddata  = {rsb_fifo[`STATE_DAT3],
                   rsb_fifo[`STATE_DAT2],
                   rsb_fifo[`STATE_DAT1],
                   rsb_fifo[`STATE_DAT0]};
  assign dresp  = 2'b00; 
  assign dlast  = ctl_reg[6] | wlast_strbless_reg;
  assign dvalid = (axi_valid & (ctl_reg[0] | ctl_reg[6])) | wlast_strbless_reg;

  assign tx_last_nxt = (rsb_fifo_clear & ctl_reg[6]) |
                       (wlast_strbless_reg & dready);

  always @(posedge rclk or negedge rresetn)
  begin : p_tx_last
    if (~rresetn)
    begin
      tx_done <= 1'b0;
      tx_last <= 1'b0;
    end
    else
    begin
      tx_done <= rsb_fifo_clear;
      tx_last <= tx_last_nxt;
    end
  end

`include "nic400_rsb_undefs_sse710_main.v"

endmodule 



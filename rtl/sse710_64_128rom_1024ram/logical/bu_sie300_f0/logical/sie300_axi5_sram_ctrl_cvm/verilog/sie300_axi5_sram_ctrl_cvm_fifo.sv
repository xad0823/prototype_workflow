//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2019 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//
//      Version Information
//
//      Checked In          : Fri Jul 19 10:20:22 2019 +0100
//
//      Revision            : 0a78fca3
//
//      Release Information : CoreLink SIE-300 Generic Global Bundle r1p2-00rel0
//
//----------------------------------------------------------------------------

module sie300_axi5_sram_ctrl_cvm_fifo #(
  parameter
      WIDTH         = 64,
      DEPTH         = 8,
      CNT_WIDTH     = 8,
      RDY_AT_DEPTH_1= 0,
      FT_AT_DEPTH_1 = 0,
      PEEK_LOGIC    = 0
)
(
  input  wire logic                         clk,
  input  wire logic                         resetn,
  input  wire logic [WIDTH-1:0]             ingress_data,
  input  wire logic                         ingress_vld,
  output      logic                         ingress_rdy,
  output      logic [WIDTH-1:0]             egress_data,
  output      logic                         egress_vld,
  input  wire logic                         egress_rdy,
  output      logic [CNT_WIDTH-1:0]         level,
  output      logic                         empty,
  output      logic                         full,
  input       logic                         fall_thru_en,
  output      logic [DEPTH-1:0]             peek_data_vld,
  output      logic [(WIDTH*DEPTH)-1:0]     peek_data
  );

  typedef logic [CNT_WIDTH-1:0] cnt_t;

  logic                     pop;
  logic                     push;
  logic [WIDTH-1:0]         fifo_data;

  generate
    if (DEPTH == 1 && RDY_AT_DEPTH_1 != 0)
    begin : g_ingress_rdy_ft
      assign ingress_rdy = ~full | pop;
    end
    else
    begin : g_ingress_rdy
      assign ingress_rdy = ~full;
    end
  endgenerate

  generate
    if (DEPTH == 1 && FT_AT_DEPTH_1 == 0)
    begin : g_egress_vld
      assign egress_vld = ~empty;
    end
    else
    begin : g_egress_vld_ft
      assign egress_vld = ~empty | (ingress_vld & fall_thru_en);
    end
  endgenerate

  generate
    if (DEPTH != 1 || FT_AT_DEPTH_1 != 0)
    begin : g_egress_data_ft
      assign egress_data = (fall_thru_en & empty) ? ingress_data : fifo_data;
    end
    else
    begin : g_egress_data
      assign egress_data = fifo_data;
    end
  endgenerate

  assign push = ingress_vld & ingress_rdy;
  assign pop  = egress_vld & egress_rdy;

  sie300_axi5_sram_ctrl_cvm_fifo_core
  #(
    .FIFO_WIDTH         ( WIDTH           ),
    .FIFO_DEPTH         ( DEPTH           ),
    .PEEK_LOGIC         ( PEEK_LOGIC      )
  )
  u_fifo_core
  (
    .clk                ( clk             ),
    .resetn             ( resetn          ),
    .push_i             ( push            ),
    .push_data_i        ( ingress_data    ),
    .pop_i              ( pop             ),
    .pop_data_o         ( fifo_data       ),
    .empty_o            ( empty           ),
    .full_o             ( full            ),
    .peek_data_valid_o  ( peek_data_vld   ),
    .peek_data_o        ( peek_data       )
  );

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn) begin
      level <= '0;
    end
    else begin
      if(push & pop) begin
        level <= level;
      end
      else if(push) begin
        level <= cnt_t'(level + cnt_t'(1));
      end
      else if (pop) begin
        level <= cnt_t'(level - cnt_t'(1));
      end
    end
  end

endmodule

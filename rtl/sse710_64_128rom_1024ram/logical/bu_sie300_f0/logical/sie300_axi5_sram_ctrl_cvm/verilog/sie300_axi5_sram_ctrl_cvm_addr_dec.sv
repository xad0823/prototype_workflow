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
//      Checked In          : Mon Jun 17 13:33:11 2019 +0100
//
//      Revision            : f90fe38b
//
//      Release Information : CoreLink SIE-300 Generic Global Bundle r1p2-00rel0
//
//----------------------------------------------------------------------------

module sie300_axi5_sram_ctrl_cvm_addr_dec
(
  input  wire logic                                           clk,
  input  wire logic                                           resetn,

  input  wire logic [22-1     :0]                             addr,
  input  wire logic [7                        :0]             len,
  input  wire logic [2                        :0]             size,
  input  wire logic [1                        :0]             burst,
  input  wire logic                                           first_cycle,
  input  wire logic                                           en_cnt,
  output      logic [22-1     :0]                             addr_calc
);
  localparam FIXED    = 2'b00;
  localparam WRAP     = 2'b10;

  logic [22-1:0]                  incr_val;
  logic [22-1:0]                  addr_incr;
  logic [22-1:0]                  addr_masked;
  logic [22-1:0]                  addr_mux;
  logic [22-1:0]                  wrap_mask;
  logic [2:0]                     wrap_len_log2;

  assign incr_val = (burst == FIXED)  ? 22'b0
                                      : 22'b1 << size;

  assign addr_incr = (en_cnt) ? (addr_mux + incr_val)
                              :  addr_mux;

  always_comb begin
    case (len)
      8'd1 :    wrap_len_log2 = 3'd1;
      8'd3 :    wrap_len_log2 = 3'd2;
      8'd7 :    wrap_len_log2 = 3'd3;
      8'd15:    wrap_len_log2 = 3'd4;
      default:  wrap_len_log2 = 'x;
    endcase
  end

  assign wrap_mask     = ( {22{1'b1}}  << size ) << wrap_len_log2;


  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn ) begin
      addr_masked <= 'b0;
    end
    else if (en_cnt | first_cycle) begin
      if (burst == WRAP) begin
        addr_masked <=  ( addr_incr & ~wrap_mask )
                      | ( addr      &  wrap_mask );
      end
      else begin
        addr_masked <= addr_incr;
      end
    end
  end

  assign addr_mux = (first_cycle) ? addr : addr_masked;

  localparam UNUSED_LOWER_BITS = $clog2(64/8);
  assign addr_calc = {  addr_mux[22-1:UNUSED_LOWER_BITS],
                        {UNUSED_LOWER_BITS{1'b0}} };




endmodule


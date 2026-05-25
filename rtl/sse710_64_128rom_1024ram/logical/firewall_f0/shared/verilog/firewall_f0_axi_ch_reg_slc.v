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

module firewall_f0_axi_ch_reg_slc #(
    parameter PAYLD_WIDTH = 2, 
    parameter REG_DIR     = 3  
) (
    input  wire                   clk      ,
    input  wire                   reset_n  ,

    input  wire                   valid_i  ,
    input  wire                   ready_i  ,
    input  wire [PAYLD_WIDTH-1:0] payload_i,

    output wire                   valid_o  ,
    output wire                   ready_o  ,
    output wire [PAYLD_WIDTH-1:0] payload_o
);

generate
  case (REG_DIR)
    0: begin: FULL
      firewall_f0_ful_regd_slice #(
        .PAYLD_WIDTH(PAYLD_WIDTH)
      ) u_reg_slc_full (
        .aresetn    (reset_n  ),
        .aclk       (clk  ),

        .valid_src  (valid_i  ),
        .ready_dst  (ready_i  ),
        .payload_src(payload_i),

        .valid_dst  (valid_o  ),
        .ready_src  (ready_o  ),
        .payload_dst(payload_o)
      );
    end

    1: begin: FORWARD
      firewall_f0_fwd_regd_slice #(
        .PAYLD_WIDTH(PAYLD_WIDTH)
      ) u_reg_slc_fwd (
        .aresetn    (reset_n  ),
        .aclk       (clk  ),

        .valid_src  (valid_i  ),
        .ready_dst  (ready_i  ),
        .payload_src(payload_i),

        .valid_dst  (valid_o  ),
        .ready_src  (ready_o  ),
        .payload_dst(payload_o)
      );
    end

    2: begin: REVERSE
      firewall_f0_rev_regd_slice #(
        .PAYLD_WIDTH(PAYLD_WIDTH)
      ) u_reg_slc_rev (
        .aresetn    (reset_n   ),
        .aclk       (clk  ),

        .valid_src  (valid_i  ),
        .ready_dst  (ready_i  ),
        .payload_src(payload_i),

        .valid_dst  (valid_o  ),
        .ready_src  (ready_o  ),
        .payload_dst(payload_o)
      );
    end

    3: begin: BYPASS
      assign valid_o   = valid_i  ;
      assign ready_o   = ready_i  ;
      assign payload_o = payload_i;
    end

    default: begin: BYPASS
      assign valid_o   = 1'bx               ;
      assign ready_o   = 1'bx               ;
      assign payload_o = {PAYLD_WIDTH{1'bx}};
    end
  endcase
endgenerate

endmodule

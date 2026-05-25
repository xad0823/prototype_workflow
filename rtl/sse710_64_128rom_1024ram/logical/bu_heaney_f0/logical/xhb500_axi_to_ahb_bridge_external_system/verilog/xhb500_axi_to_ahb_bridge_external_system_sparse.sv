//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2025 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//-----------------------------------------------------------------------------
//
//      Version Information
//
//      Checked In          : Fri Mar 29 11:15:40 2019 +0000
//
//      Revision            : 08e988e
//
//      Release Information : CoreLink XHB-500 Generic Global Bundle r0p0-00rel0
//

module xhb500_axi_to_ahb_bridge_external_system_sparse
(
  input wire logic [6:0]                        addr_6_0_in,
  input wire xhb500_axi_to_ahb_bridge_external_system_pkg::xhb_size_t axsize_in,

  input wire logic [4-1:0]                      sp_strb_in,

  output     logic [6:0]                        sp_addr_6_0_out,
  output     xhb500_axi_to_ahb_bridge_external_system_pkg::xhb_size_t sp_size_out,

  output     logic [4-1:0]                      sp_strb_left,
  output     logic                              sp_beat_finished,

  output     logic                              new_beat_sparse,
  output     logic                              new_beat_empty,
  output     logic                              new_beat_full
);

  localparam W_ADDR_SPBITS    = $clog2(4);

  typedef enum logic [1:0] {SIZE000= 2'b00, SIZE001= 2'b01, SIZE010= 2'b10, SIZE011= 2'b11} e_xhb_size_t;

  localparam W_STRB_M2  = 4/2;


  wire logic [W_STRB_M2 -1:0]             strb_p2;
  wire logic [4-1:0]                      strb_m2;

  always_comb begin
    sp_addr_6_0_out             = addr_6_0_in;
    sp_strb_left                = sp_strb_in;
    sp_size_out                 = axsize_in;

    if((axsize_in == SIZE010) & (&sp_strb_in)) begin
      sp_size_out               = SIZE010;
      sp_strb_left              = '0;
      sp_addr_6_0_out[1:0]      = '0;
    end
    else begin
      for (int i = 0; i < 4; i=i+1) begin : g_strb_addr

        if(sp_strb_in[i]) begin

          sp_addr_6_0_out[W_ADDR_SPBITS-1:0] = W_ADDR_SPBITS'(i);

          sp_size_out           = SIZE000;
          sp_strb_left[i]       = 1'b0;

          if((axsize_in > SIZE000) & (i%2 == 0) & (strb_m2[i])) begin
            sp_size_out         = SIZE001;
            for (int j = i+1; j < i+2; j=j+1) begin : g_strb_left2
              sp_strb_left[j]   = 1'b0;
            end
          end

          break;

        end
      end
    end
  end

  assign sp_beat_finished  = ~(|sp_strb_left);
  assign new_beat_sparse   = (axsize_in != sp_size_out);
  assign new_beat_empty    = ~(|sp_strb_in);
  assign new_beat_full     = (|sp_strb_in) & (axsize_in == sp_size_out);



  genvar i2;
  for (i2 = 0; i2 < W_STRB_M2; i2=i2+1) begin: g_strb_s2
    assign strb_p2[i2] = &sp_strb_in[(2*i2+1):(2*i2)];
    assign strb_m2[(2*i2+1):(2*i2)] = {2{strb_p2[i2]}};
    end


endmodule

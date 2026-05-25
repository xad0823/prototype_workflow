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

module xhb500_axi_to_ahb_bridge_flash_strbgen
(
  input wire logic    [$clog2(16)-1:0]                      addr_in,
  input wire xhb500_axi_to_ahb_bridge_flash_pkg::xhb_size_t             size_in,

  output     logic    [16-1:0]                              strb
);

  typedef enum logic [2:0] {SIZE000=3'b000, SIZE001=3'b001, SIZE010=3'b010, SIZE011=3'b011, SIZE100=3'b100, SIZE101=3'b101, SIZE110=3'b110, SIZE111=3'b111} e_xhb_size_t;

  wire logic [$clog2(16)-1:0]                      addr_aligned = addr_in & ({$clog2(16){1'b1}} << size_in);

  logic [16-1:0] strb_mask;

  always_comb
    case (size_in)
      SIZE000  : strb_mask = {{(16- 1){1'b0}}, { 1{1'b1}}};
      SIZE001  : strb_mask = {{(16- 2){1'b0}}, { 2{1'b1}}};
      SIZE010  : strb_mask = {{(16- 4){1'b0}}, { 4{1'b1}}};
      SIZE011  : strb_mask = {{(16- 8){1'b0}}, { 8{1'b1}}};
      SIZE100,
      SIZE101,
      SIZE110,
      SIZE111  : strb_mask = '1;
      default  : strb_mask = 'x;
    endcase

  assign strb = strb_mask << addr_aligned;

endmodule

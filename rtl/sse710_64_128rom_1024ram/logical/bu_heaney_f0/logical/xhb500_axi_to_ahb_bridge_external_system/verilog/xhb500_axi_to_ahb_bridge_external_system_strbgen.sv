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

module xhb500_axi_to_ahb_bridge_external_system_strbgen
(
  input wire logic    [$clog2(4)-1:0]                       addr_in,
  input wire xhb500_axi_to_ahb_bridge_external_system_pkg::xhb_size_t             size_in,

  output     logic    [4-1:0]                               strb
);

  typedef enum logic [1:0] {SIZE000= 2'b00, SIZE001= 2'b01, SIZE010= 2'b10, SIZE011= 2'b11} e_xhb_size_t;

  wire logic [$clog2(4)-1:0]                       addr_aligned = addr_in & ({$clog2(4){1'b1}} << size_in);

  logic [4-1:0] strb_mask;

  always_comb
    case (size_in)
      SIZE000  : strb_mask = {{(4- 1){1'b0}}, { 1{1'b1}}};
      SIZE001  : strb_mask = {{(4- 2){1'b0}}, { 2{1'b1}}};
      SIZE010,
      SIZE011  : strb_mask = '1;
      default  : strb_mask = 'x;
    endcase

  assign strb = strb_mask << addr_aligned;

endmodule

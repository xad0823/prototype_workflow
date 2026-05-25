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

module xhb500_ahb_to_axi_bridge_external_system_strb (

  input  wire logic [32-1:0]                     haddr,
  input  wire logic [1:0]                        hsize,

  output      logic [4-1:0]                      wstrb

  );

  localparam OFFSET = $clog2(4);


  wire logic [32-OFFSET-1:0] unused = haddr[32-1:OFFSET];


  logic [4-1:0] wmask;

  always_comb
  begin : p_write_strb_decode_comb

    case (hsize)
      2'd0 : wmask = 4'h1;
      2'd1 : wmask = 4'h3;
      2'd2 : wmask = 4'hf;
      2'd3 : wmask = 4'hff;
      default :
          wmask = {4{1'bx}};
    endcase
  end

  assign wstrb = wmask << haddr[OFFSET-1:0];

endmodule

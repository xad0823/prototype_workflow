//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2013-2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------
// Description:
//
//   Decodes writes on the validation interface, setting the write enable on the
//   appropriate validation component.
//------------------------------------------------------------------------------

module execution_tb_val_decoder
(// Address inputs
 input  wire [43:0] val_wr_addr_i,
 input  wire        val_write_i,
 input  wire [15:0] val_wr_strb_i,

 // Output enables
 output wire        val_write_mem_o,
 output wire        val_write_tube_o,
 output wire        val_write_tbox_fcnt_o,
 output wire        val_write_tbox_fclr_o
);

  //----------------------------------------------------------------------------
  // Decode
  //
  //   0x000_1300_0000 : Tube
  //   0x000_1300_0008 : Trickbox FIQ count  (word write)
  //   0x000_1300_0010 : Trickbox FIQ clear
  //----------------------------------------------------------------------------

  assign val_write_mem_o       = val_write_i & (val_wr_addr_i[43:16] != 28'h000_1300    );
  assign val_write_tube_o      = val_write_i & (val_wr_addr_i[43:4]  == 44'h000_1300_000) &   val_wr_strb_i[0];
  assign val_write_tbox_fcnt_o = val_write_i & (val_wr_addr_i[43:4]  == 44'h000_1300_000) & (&val_wr_strb_i[11:8]);
  assign val_write_tbox_fclr_o = val_write_i & (val_wr_addr_i[43:4]  == 44'h000_1300_001) &   val_wr_strb_i[0];

endmodule


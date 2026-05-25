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
//      Checked In          : $Date: 2014-07-25 09:52:11 +0100 (Fri, 25 Jul 2014) $
//
//      Revision            : $Revision: 285788 $
//
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------
// Description:
//
//   Validation trickbox component, containing:
//
//     1. FIQ counter:
//
//         - Write a counter value to register at offset 0x08 to start the FIQ
//           counter.  The counter starts to decrement immediately after the
//           write and a FIQ will be asserted to every CPU when the counter
//           reaches zero.
//
//         - De-assert every CPU's FIQ by writing any value to the register at
//           offset 0x10.
//
//     2. A free-running counter that counts simulation cycles.  This is
//        initialized to 0 at simulation time 0 and does not have a logical
//        reset.
//
//   The trickbox is a write-only device; none of the registers can be read.
//------------------------------------------------------------------------------

module execution_tb_val_tbox #(parameter integer NUM_CPUS = 1)
(
  // Clocks and resets
  input  wire                   clk,
  input  wire                   reset_n,

  // Write interface
  input  wire                   val_write_tbox_fcnt_i,
  input  wire                   val_write_tbox_fclr_i,
  input  wire [43:0]            val_wr_addr_i,
  input  wire [127:0]           val_wr_data_i,

  // Trickbox outputs
  output wire [(NUM_CPUS-1):0]  tbox_nfiq_o,
  output wire [63:0]            tbox_cntvalueb_o
);

  //----------------------------------------------------------------------------
  // Signal declarations
  //----------------------------------------------------------------------------

  // FIQ counter
  reg  [12:0]           fiq_counter;
  wire [12:0]           nxt_fiq_counter;
  wire                  fiq_counter_we;
  reg  [(NUM_CPUS-1):0] nfiq;
  wire [(NUM_CPUS-1):0] nxt_nfiq;
  wire                  nfiq_we;

  // Cycle count
  reg  [63:0]           cntvalueb;


  //----------------------------------------------------------------------------
  // FIQ counter
  //----------------------------------------------------------------------------

  // Counter
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      fiq_counter <= {13{1'b0}};
    else if (fiq_counter_we)
      fiq_counter <= nxt_fiq_counter;

  assign nxt_fiq_counter = val_write_tbox_fcnt_i ? val_wr_data_i[76:64] : (fiq_counter - 1'b1);
  assign fiq_counter_we  = (fiq_counter != {13{1'b0}}) | val_write_tbox_fcnt_i;


  // nFIQ registers
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      nfiq <= {NUM_CPUS{1'b1}};
    else if (nfiq_we)
      nfiq <= nxt_nfiq;

  assign nxt_nfiq = {NUM_CPUS{(fiq_counter != {{12{1'b0}}, 1'b1})}}; // Active-low
  assign nfiq_we  = (fiq_counter == {{12{1'b0}}, 1'b1}) | val_write_tbox_fclr_i;


  //----------------------------------------------------------------------------
  // Cycle counter
  //----------------------------------------------------------------------------

  initial cntvalueb = {64{1'b0}};

  always @ (posedge clk)
    cntvalueb <= (cntvalueb + 1'b1);


  //----------------------------------------------------------------------------
  // Output assignments
  //----------------------------------------------------------------------------

  assign tbox_nfiq_o      = nfiq;
  assign tbox_cntvalueb_o = cntvalueb;

endmodule


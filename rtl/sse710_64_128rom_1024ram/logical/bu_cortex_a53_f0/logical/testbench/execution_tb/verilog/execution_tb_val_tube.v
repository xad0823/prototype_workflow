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
//   Validation tube.  This is a simple character-printing device that writes
//   characters to the simulation console.
//
//   Characters must be written one byte at a time in the lowest byte lane of
//   the write data.  Every other byte lane is ignored.
//
//   Written characters are added to the buffer and will be printed either when
//   the buffer is full, or a newline character is written, whichever comes
//   first.
//
//   Writing the ASCII 'End of Transmission' (EOT) character, 0x04, will end the
//   simulation.
//------------------------------------------------------------------------------

module execution_tb_val_tube #(parameter integer NUM_CPUS = 1)
(
  // Clocks and resets
  input  wire         clk,
  input  wire         reset_n,

  // Validation interface (write-only)
  input  wire         val_write_tube_i,
  input  wire [1:0]   val_wr_cpu_i,
  input  wire [127:0] val_wr_data_i,

  // Cycle counter
  input  wire [63:0]  tbox_cntvalueb_i
);

  //----------------------------------------------------------------------------
  // Local constants
  //----------------------------------------------------------------------------

  localparam [7:0] CHAR_LF  = 8'h0A;  // Linefeed character
  localparam [7:0] CHAR_CR  = 8'h0D;  // Carriage return character
  localparam [7:0] CHAR_EOT = 8'h04;  // 'EOT' character (ends the test)
  localparam [7:0] CHAR_NUL = 8'h00;  // NULL character

  localparam integer          BUF_SIZE = 1024;       // Size of the tube buffer
  localparam integer          PTR_SIZE = 10;         // Pointer size for BUF_SIZE characters
  localparam [(PTR_SIZE-1):0] PTR_MAX  = {PTR_SIZE{1'b1}};


  //----------------------------------------------------------------------------
  // Signal declarations
  //----------------------------------------------------------------------------

  wire write; // Valid write operation

  reg [((BUF_SIZE*8)-1):0] tube [0:(NUM_CPUS-1)];  // The tube character buffer
  reg [(PTR_SIZE-1):0]     ptr  [0:(NUM_CPUS-1)];  // Pointer to the current char

  integer i;

  //----------------------------------------------------------------------------
  // Functions
  //----------------------------------------------------------------------------

  // Count trailing null characters function.
  //
  //   This function counts the number of trailing NULL characters in a given
  //   tube buffer.  This is then used to shift the string right by that number
  //   of characters prior to printing.
  //
  //   The reason for doing this is that a strict interpretation of the Verilog
  //   standard states that NULL characters at the START of a reg variable will
  //   not be printed but NULL characters at the END of a reg WILL be printed.
  //   Although many simulators suppress trailing NULLs when the '%0s' print
  //   format is used, other simulators do not use this convention and trailing
  //   NULLs result in padding at the end of the printed output.
  //
  //   To avoid excessive padding in the printed string, the tube therefore
  //   shifts out the terminating NULLs prior to output, effectively moving them
  //   to the start of the string where they will not be printed.
  function integer trailing_nulls;
    input   [((BUF_SIZE*8)-1):0] str;
    integer                      n;

    begin
      trailing_nulls = 0;

      // Begin at the start of the string (top of the reg) and work down to the
      // bottom.  Keep a running NULL count, but reset it when a non-NULL is
      // encountered.  At the end of the string the result will be the number of
      // trailing NULLs.
      for (n=(BUF_SIZE*8)-1; n>0; n=n-8) begin
        if (str[n-:8] == CHAR_NUL)
          trailing_nulls = trailing_nulls+1;
        else
          trailing_nulls = 0;
      end
    end
  endfunction

  //----------------------------------------------------------------------------
  // Main code
  //----------------------------------------------------------------------------

  // Detect writes.  Only use the lowest byte lane.  For safety, ensure that
  // the CPU number that is requesting the write is valid given the number of
  // implemented CPUs.
  assign write = val_write_tube_i & (val_wr_cpu_i < NUM_CPUS);

  // Character pointer process.  At reset this points to the top of the buffer
  // (which in Verilog is the start of the string).  It is decremented every
  // time a character is written, except for CR or LF which resets it.  These
  // two characters cause the buffer to be printed so we start again from the
  // top of the buffer.
  always @ (posedge clk or negedge reset_n)
    for (i=0; i<NUM_CPUS; i=i+1)
      if (!reset_n)
        ptr[i] <= PTR_MAX;
      else if (write && (val_wr_cpu_i == i[1:0])) begin
        if (val_wr_data_i[7:0] == CHAR_LF || val_wr_data_i[7:0] == CHAR_CR)
          ptr[i] <= PTR_MAX;
        else
          ptr[i] <= ptr[i] - 1;
      end else
        ptr[i] <= ptr[i];

  // Printing process.  Append characters to the buffer.  Print the buffer when
  // the character is a newline or the test ends.
  always @ (posedge clk)
    if (write) begin
      if (val_wr_data_i[7:0] == CHAR_EOT) begin
        // An EOT character from any CPU terminates the simulation
        tube[val_wr_cpu_i][(ptr[val_wr_cpu_i]*8)+:8] = CHAR_NUL;
        $display("CPU%d terminated the test at %0t (%0d cycles)", val_wr_cpu_i, $time, tbox_cntvalueb_i);
        $finish;
      end else if (val_wr_data_i[7:0] == CHAR_LF || val_wr_data_i[7:0] == CHAR_CR) begin
        // A CR or LF character prints the buffer for that CPU.  The buffer is
        // then filled with NULL characters ready to accept the next line.
        $display("( %t ) CPU%d: %0s", $time, val_wr_cpu_i, (tube[val_wr_cpu_i] >> (8 * trailing_nulls(tube[val_wr_cpu_i]))));
        tube[val_wr_cpu_i] = {(BUF_SIZE*8){1'b0}};
      end else begin
        // Any other character gets added to the buffer
        tube[val_wr_cpu_i][(ptr[val_wr_cpu_i]*8)+:8] = val_wr_data_i[7:0];
      end
    end

  // At the start of simulation the tube buffer is filled with NULL characters
  initial begin
    for (i=0; i<NUM_CPUS; i=i+1)
      tube[i] = {(BUF_SIZE*8){1'b0}};
  end

endmodule


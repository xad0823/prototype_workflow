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
//   Execution testbench dual-port memory model (one read port and one write
//   port.)
//
//   Note: this model is not intended to be synthesizable.
//
//   The memory has a 128-bit (16 byte)  data width and the input address
//   width is configurable using the ADDR_RANGE parameter.  The memory array is
//   indexed using bits[(ADDR_RANGE-1):4] of the input address, so as always to
//   read or write a 16-byte-aligned value.
//
//   Therefore:
//     Memory depth        =       2 ** (ADDR_RANGE - 4)
//     Memory size (bytes) = 16 * (2 ** (ADDR_RANGE - 4))
//
//----------------------------------------------------------------------------

module execution_tb_val_mem #(parameter ADDR_RANGE = 24)
(// Clocks
 input  wire          clk,

 // Read port
 input  wire          val_read_i,
 input  wire [43:0]   val_rd_addr_i,
 output wire [127:0]  val_rd_data_o,

 // Write port
 input  wire          val_write_i,
 input  wire [43:0]   val_wr_addr_i,
 input  wire [15:0]   val_wr_strb_i,
 input  wire [127:0]  val_wr_data_i
);

  //----------------------------------------------------------------------------
  // Local constants
  //----------------------------------------------------------------------------

  localparam integer DATA_WIDTH = 128;
  localparam integer BYTE_LANES = DATA_WIDTH / 8;
  localparam integer MEM_DEPTH  = 1 << (ADDR_RANGE - 4);


  //----------------------------------------------------------------------------
  // Signal declarations
  //----------------------------------------------------------------------------

  // Memory
  reg  [(DATA_WIDTH-1):0] mem [0:(MEM_DEPTH-1)];   // Memory array
  wire [(BYTE_LANES-1):0] wr_en;                   // Write enable for each lane
  wire [(DATA_WIDTH-1):0] rd_data;                 // Memory read data
  integer                 i;                       // Loop counter


  //----------------------------------------------------------------------------
  // Reads
  //----------------------------------------------------------------------------

  assign rd_data = val_read_i ? mem[val_rd_addr_i[(ADDR_RANGE-1):4]] : {127{1'b0}};


  //----------------------------------------------------------------------------
  // Writes
  //----------------------------------------------------------------------------

  // Write enable for each byte lane
  assign wr_en = {BYTE_LANES{val_write_i}} & val_wr_strb_i;

  // Loop across each byte lane
  always @ (posedge clk)
    for (i=0; i<BYTE_LANES; i=i+1)
      if (wr_en[i])
        mem[val_wr_addr_i[(ADDR_RANGE-1):4]][(8*i)+:8] <= val_wr_data_i[(8*i)+:8];


  //----------------------------------------------------------------------------
  // Initialisation code
  //----------------------------------------------------------------------------

  initial begin : initial_mem_init
    reg [(8*128):1] mem_init_file;  // Mem init filename

    for (i=0; i<MEM_DEPTH; i=i+1) begin
      mem[i] = {DATA_WIDTH{1'b0}};
    end

    if (!$test$plusargs("no_init")) begin
      if ($value$plusargs("mem_init=%s", mem_init_file))
        $readmemh(mem_init_file, mem);
      else
        $readmemh("image.vhx", mem);  // Default image filename
    end else
      $display("*** WARNING: Memory model not initialized.");
  end


  //----------------------------------------------------------------------------
  // Output assignments
  //----------------------------------------------------------------------------

  assign val_rd_data_o = rd_data;

endmodule


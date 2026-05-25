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
//   Converts a Skyros request into a series of individual requests with an
//   incrementing address.
//------------------------------------------------------------------------------

module execution_tb_sky_intf_addr_unpack #(parameter integer ADDR_WIDTH = 44)
(
  // Clocks and resets
  input  wire                    clk,
  input  wire                    reset_n,

  // Request interface
  input  wire                    req_valid_i,
  input  wire [(ADDR_WIDTH-1):0] req_addr_i,
  input  wire [1:0]              req_beats_i,

  // Unpacked address interface
  output wire                    unpk_valid_o,
  output wire [(ADDR_WIDTH-1):0] unpk_addr_o,
  output wire [1:0]              unpk_chunk_o,
  output wire                    unpk_last_o,
  input  wire                    unpk_ready_i
);

  //----------------------------------------------------------------------------
  // Signal declarations
  //----------------------------------------------------------------------------

  // Unpacked interface signals
  reg                     unpk_valid;
  reg  [11:0]             unpk_addr;  // Incrementing address (lower 12 bits)
  reg                     unpk_last;
  reg  [1:0]              unpk_chunk;
  wire                    nxt_unpk_valid;
  wire [11:0]             nxt_unpk_addr;
  wire                    nxt_unpk_last;
  wire [1:0]              nxt_unpk_chunk;
  wire                    unpk_addr_we;
  wire [7:0]              burst_len;

  // Incrementer
  wire [11:0]             unpk_addr_incr;
  reg  [1:0]              addr_count;
  wire [1:0]              nxt_addr_count;
  wire                    addr_count_we;


  //----------------------------------------------------------------------------
  // Address incrementer
  //----------------------------------------------------------------------------

  execution_tb_ace_sky_addr_inc
    u_execution_tb_ace_sky_addr_inc
      (.unpk_addr_i       (unpk_addr),
       .unpk_addr_incr_o  (unpk_addr_incr),
       .burst_len_i       (burst_len),
       .burst_size_i      (3'b100),  // Beats are always 16-byte (128-bit) chunks
       .burst_type_i      (2'b10)    // Wrapping burst type
      );

  assign burst_len = {6'b000000, req_beats_i[1:0]};


  //----------------------------------------------------------------------------
  // Incremented address
  //----------------------------------------------------------------------------

  // Next address is either from the originating request (for the first
  // transfer) or the next address from the incrementer for subsequent beats.
  assign nxt_unpk_addr = req_valid_i ? req_addr_i[11:0] : unpk_addr_incr;
  assign unpk_addr_we  = req_valid_i | unpk_ready_i;

  // Address register
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      unpk_addr <= 12'h000;
    else if (unpk_addr_we)
      unpk_addr <= nxt_unpk_addr;


  //----------------------------------------------------------------------------
  // Address counter
  //
  //   Determines how many addresses there are in the burst, and indicates when
  //   the final address of the burst is issued.
  //----------------------------------------------------------------------------

  assign nxt_addr_count = req_valid_i ? req_beats_i[1:0] : (addr_count - 2'b01);
  assign nxt_unpk_last  = (nxt_addr_count == 2'b00);
  assign nxt_unpk_chunk = req_valid_i ? req_addr_i[5:4] : (unpk_chunk + 2'b01);
  assign addr_count_we  = req_valid_i | (unpk_valid & unpk_ready_i);

  always @ (posedge clk or negedge reset_n)
    if (!reset_n) begin
      addr_count <= 2'b00;
      unpk_last  <= 1'b0;
      unpk_chunk <= 2'b00;
    end else if (addr_count_we) begin
      addr_count <= nxt_addr_count;
      unpk_last  <= nxt_unpk_last;
      unpk_chunk <= nxt_unpk_chunk;
    end


  //----------------------------------------------------------------------------
  // Address valid indicator
  //----------------------------------------------------------------------------

  // unpk_valid is high when an address is accepted and goes low when the last
  // address is accepted, unless another burst is started.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      unpk_valid <= 1'b0;
    else
      unpk_valid <= nxt_unpk_valid;

  assign nxt_unpk_valid = req_valid_i | (unpk_valid & ~(unpk_last & unpk_ready_i));


  //----------------------------------------------------------------------------
  // Output assignments
  //----------------------------------------------------------------------------

  assign unpk_valid_o = unpk_valid;
  assign unpk_addr_o  = {req_addr_i[(ADDR_WIDTH-1):12], unpk_addr};
  assign unpk_chunk_o = unpk_chunk;
  assign unpk_last_o  = unpk_last;

endmodule


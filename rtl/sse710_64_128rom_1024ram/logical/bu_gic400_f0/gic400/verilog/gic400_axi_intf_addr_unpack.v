//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2012  ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2011-08-03 15:09:44 +0100 (Wed, 03 Aug 2011) $
//
//      Revision            : $Revision: 180427 $
//
//      Release Information : GIC-400-r0p1-00rel0
//
//-----------------------------------------------------------------------------
// Purpose: Registers an AXI AR/AW address and spins out the correct number
//          of P0 transactions for the burst.
//------------------------------------------------------------------------------

module gic400_axi_intf_addr_unpack #(parameter NUM_ID_BITS = 4)
(
  // Clocks and resets
  input  wire                   clk,
  input  wire                   reset_n,

  // AXI interface
  input  wire            [14:0] axi_addr_i,
  input  wire             [1:0] axi_size_i,
  input  wire             [1:0] axi_burst_i,
  input  wire             [7:0] axi_len_i,
  input  wire             [2:0] axi_prot_i,
  input  wire             [2:0] axi_cpu_i,
  input  wire [NUM_ID_BITS-1:0] axi_id_i,
  input  wire                   axi_valid_i,
  output wire                   axi_ready_o,
  input  wire                   defer_axi_ready_i,

  // Unpacked address interface
  output wire            [14:2] p0_addr_o,    // Incrementing address
  output wire                   p0_nsecure_o, // Secure/non-secure access
  output wire [NUM_ID_BITS-1:0] p0_id_o,      // ID
  output wire             [2:0] p0_cpu_o,     // CPU ID number
  output wire             [1:0] p0_size_o,    // Size of access
  output wire                   p0_last_o,    // Last address of burst
  output wire                   p0_valid_o,   // Address valid
  input  wire                   p0_ready_i    // Address accepted
);


  //----------------------------------------------------------------------------
  // Local constants
  //----------------------------------------------------------------------------

  `include "gic400_defs.v"


  //----------------------------------------------------------------------------
  // Signal/wire declarations
  //----------------------------------------------------------------------------

  // Unpacked interface signals
  reg            [14:0] p0_byte_addr_q;
  reg                   p0_last_q;
  reg                   p0_valid_q;
  wire           [14:0] nxt_p0_byte_addr;
  wire                  p0_en;
  wire                  nxt_p0_last;
  wire                  nxt_p0_valid;

  // AXI signals
  wire                  nxt_axi_ready;
  reg                   axi_ready_q;
  wire                  new_axi_addr;       // New AXI address on AXI i/f
  reg             [1:0] axi_size_q;         // Registered input AXI size
  reg             [1:0] axi_burst_q;        // Registered input AXI burst type
  reg             [7:0] axi_len_q;          // Registered input AXI burst length
  reg                   axi_nsecure_q;      // Registered axi_prot[1] security bit
  reg             [2:0] axi_cpu_q;          // Registered CPU ID
  reg [NUM_ID_BITS-1:0] axi_id_q;           // Registered AXI ID

  // Incrementer
  wire           [11:0] p0_byte_addr_incr;  // Incremented address
  reg             [7:0] p0_addr_count_q;    // Burst counter
  wire            [7:0] nxt_p0_addr_count;
  reg            [11:0] offset_addr;
  wire           [11:0] incr_addr;
  wire           [11:0] wrap_addr;
  wire           [11:0] mux_addr;
  reg            [11:0] calc_addr;


  //----------------------------------------------------------------------------
  // Control signal registers
  //----------------------------------------------------------------------------

  // Enable for address registers. This signal indicates that there is a new
  // address on the AXI input interface.
  assign new_axi_addr = axi_valid_i & axi_ready_q;

  // Address control registers
  always @(posedge clk)
    if (new_axi_addr) begin
      axi_size_q    <= axi_size_i;
      axi_burst_q   <= axi_burst_i;
      axi_len_q     <= axi_len_i;
      axi_nsecure_q <= axi_prot_i[1];
      axi_cpu_q     <= axi_cpu_i;
      axi_id_q      <= axi_id_i;
    end


  //----------------------------------------------------------------------------
  // Incremented address
  //----------------------------------------------------------------------------

  // As bursts cannot cross 4KB boundary, only least significant 12 bits need to
  // increment.

  // Combinational address shift right
  // - Extract the significant bits of interest, depending on the AXI transaction
  //   size.

  always @ (*)
    case (axi_size_q)
      AXI_SIZE_8:    offset_addr = p0_byte_addr_q[11:0];
      AXI_SIZE_16:   offset_addr = {1'b0,  p0_byte_addr_q[11:1]};
      AXI_SIZE_32:   offset_addr = {2'b00, p0_byte_addr_q[11:2]};
      AXI_SIZE_64:   offset_addr = p0_byte_addr_q[11:0];          // Unsupported size
      default:       offset_addr = {12{1'bX}};
    endcase

  // Increment the address
  assign incr_addr = offset_addr + 12'h001;

  // Address wrapping
  // - The address of the next transfer should wrap on the next transfer if the
  //   boundary is reached. axi_len_q is in [1,3,7,15...] for wrapping bursts

  // Upper bits of wrapped address remain static
  assign wrap_addr[11:8] = offset_addr[11:8];

  // Wrap lower bits according to length of burst
  assign wrap_addr[7:0]  = ( axi_len_q & incr_addr[7:0]) |
                           (~axi_len_q & offset_addr[7:0]);

  // Combinational address multiplexer
  // - Choose the final offset address depending on burst type
  assign mux_addr = (axi_burst_q == AXI_BURST_WRAP) ? wrap_addr : incr_addr;

  // Combinational address shift left
  // - Shift the bits of interest to the correct bits of the resultant address

  always @ (*)
    case (axi_size_q)
      AXI_SIZE_8:    calc_addr = mux_addr;
      AXI_SIZE_16:   calc_addr = {mux_addr[10:0], 1'b0};
      AXI_SIZE_32:   calc_addr = {mux_addr[9:0], 2'b00};
      AXI_SIZE_64:   calc_addr = mux_addr;                // Unsupported size
      default:       calc_addr = {12{1'bX}};
    endcase

  assign p0_byte_addr_incr = (axi_burst_q == AXI_BURST_FIXED) ? p0_byte_addr_q[11:0] : calc_addr;

  // Next address is either from the AXI interface on the first transfer or
  // the address from the incrementer on subsequent transfers.
  assign nxt_p0_byte_addr = axi_ready_q ? axi_addr_i : {p0_byte_addr_q[14:12],p0_byte_addr_incr[11:0]};

  assign p0_en = new_axi_addr | p0_ready_i;

  // Address register
  always @(posedge clk)
    if (p0_en)
      p0_byte_addr_q <= nxt_p0_byte_addr;


  //----------------------------------------------------------------------------
  // Address counter
  //
  //   Determines how many addresses there are in the burst, and indicates when
  //   the final address of the burst is issued.
  //----------------------------------------------------------------------------

  // The count increments when a new burst is started, or when an incrementing
  // address is accepted
  assign nxt_p0_addr_count = axi_ready_q ? axi_len_i : (p0_addr_count_q - 8'h01);
  assign nxt_p0_last       = (nxt_p0_addr_count == 8'h00);

  always @(posedge clk)
    if (p0_en) begin
      p0_addr_count_q <= nxt_p0_addr_count;
      p0_last_q       <= nxt_p0_last;
    end


  //----------------------------------------------------------------------------
  // Address valid indicator
  //----------------------------------------------------------------------------

  // p0_valid_q is high when an address is accepted and goes low when the last
  // address is accepted, unless another burst is started.
  assign nxt_p0_valid = new_axi_addr |
                        (p0_valid_q & ~(p0_ready_i & p0_last_q));

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      p0_valid_q <= 1'b0;
    else
      p0_valid_q <= nxt_p0_valid;


  //----------------------------------------------------------------------------
  // READY logic
  //----------------------------------------------------------------------------

  // A new AXI address can be accepted after the current address has been
  // accepted by the programming interface. This means there will always be
  // one cycle after an address is accepted before a new address can be
  // accepted.
  //
  // The AW channel is blocked from accepting new transactions when a read is
  // valid in P0. This is required to ensure that a stream of writes does not
  // block a read indefinitely, as reads are not issued from P0 when there is
  // a write in P0.

  assign nxt_axi_ready = ~defer_axi_ready_i & ~new_axi_addr &
                         (~p0_valid_q | (p0_ready_i & p0_last_q));

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      axi_ready_q <= 1'b0;
    else
      axi_ready_q <= nxt_axi_ready;


  //----------------------------------------------------------------------------
  // Output assignments
  //----------------------------------------------------------------------------

  assign p0_addr_o    = p0_byte_addr_q[14:2];
  assign p0_last_o    = p0_last_q;
  assign p0_nsecure_o = axi_nsecure_q;
  assign p0_id_o      = axi_id_q[NUM_ID_BITS-1:0];
  assign p0_cpu_o     = axi_cpu_q[2:0];
  assign p0_size_o    = axi_size_q[1:0];
  assign p0_valid_o   = p0_valid_q;
  assign axi_ready_o  = axi_ready_q;

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON
  `include "std_ovl_defines.h"

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: new_axi_addr")
  u_ovl_x_new_axi_addr (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (new_axi_addr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: p0_en")
  u_ovl_x_p0_en (.clk       (clk),
                 .reset_n   (reset_n),
                 .qualifier (1'b1),
                 .test_expr (p0_en));


`endif

endmodule


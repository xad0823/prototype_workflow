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
//   ACE interface for the execution testbench, unpacking transactions into an
//   SRAM-style interface for connecting to the validation memories and
//   components.
//
//   The validation memory model has a dual-port interface and all control
//   registers are write-only.  Therefore the ACE read and write channels can be
//   treated independently.
//
//   The execution testbench validation environment is implicitly coherent
//   because it only contains one master (the processor.)  Also the validation
//   memory and components process one transaction at a time, in order.
//   Therefore the coherency channel signals are tied off.
//----------------------------------------------------------------------------

module execution_tb_ace_intf #(parameter integer ADDR_WIDTH = 32)
(
  // Clocks and resets
  input  wire                    clk,
  input  wire                    reset_n,

  // ACE slave interface
  output wire                    ace_awready_o,
  input  wire                    ace_awvalid_i,
  input  wire [4:0]              ace_awid_i,
  input  wire [43:0]             ace_awaddr_i,
  input  wire [7:0]              ace_awlen_i,
  input  wire [2:0]              ace_awsize_i,
  input  wire [1:0]              ace_awburst_i,
  input  wire [1:0]              ace_awbar_i,
  input  wire [1:0]              ace_awdomain_i,
  input  wire                    ace_awlock_i,
  input  wire [3:0]              ace_awcache_i,
  input  wire [2:0]              ace_awprot_i,
  input  wire [2:0]              ace_awsnoop_i,
  input  wire                    ace_awunique_i,
  output wire                    ace_wready_o,
  input  wire                    ace_wvalid_i,
  input  wire [4:0]              ace_wid_i,
  input  wire [127:0]            ace_wdata_i,
  input  wire [15:0]             ace_wstrb_i,
  input  wire                    ace_wlast_i,
  input  wire                    ace_bready_i,
  output wire                    ace_bvalid_o,
  output wire [4:0]              ace_bid_o,
  output wire [1:0]              ace_bresp_o,
  output wire                    ace_arready_o,
  input  wire                    ace_arvalid_i,
  input  wire [5:0]              ace_arid_i,
  input  wire [43:0]             ace_araddr_i,
  input  wire [7:0]              ace_arlen_i,
  input  wire [2:0]              ace_arsize_i,
  input  wire [1:0]              ace_arburst_i,
  input  wire [1:0]              ace_arbar_i,
  input  wire [1:0]              ace_ardomain_i,
  input  wire                    ace_arlock_i,
  input  wire [3:0]              ace_arcache_i,
  input  wire [2:0]              ace_arprot_i,
  input  wire [3:0]              ace_arsnoop_i,
  input  wire                    ace_rready_i,
  output wire                    ace_rvalid_o,
  output wire [5:0]              ace_rid_o,
  output wire [127:0]            ace_rdata_o,
  output wire [3:0]              ace_rresp_o,
  output wire                    ace_rlast_o,
  input  wire                    ace_acready_i,
  output wire                    ace_acvalid_o,
  output wire [43:0]             ace_acaddr_o,
  output wire [2:0]              ace_acprot_o,
  output wire [3:0]              ace_acsnoop_o,
  output wire                    ace_crready_o,
  input  wire                    ace_crvalid_i,
  input  wire [4:0]              ace_crresp_i,
  output wire                    ace_cdready_o,
  input  wire                    ace_cdvalid_i,
  input  wire [127:0]            ace_cddata_i,
  input  wire                    ace_cdlast_i,

  // Internal interface
  output wire                    val_read_o,    // Read valid
  output wire [(ADDR_WIDTH-1):0] val_rd_addr_o, // Read address
  input  wire [127:0]            val_rd_data_i, // Read data
  output wire                    val_write_o,   // Write valid
  output wire [(ADDR_WIDTH-1):0] val_wr_addr_o, // Write address
  output wire [15:0]             val_wr_strb_o, // Write strobes
  output wire [1:0]              val_wr_cpu_o,  // Write CPU
  output wire [127:0]            val_wr_data_o  // Write data
);

  //----------------------------------------------------------------------------
  // Signal declarations
  //----------------------------------------------------------------------------

  // Read/write arbitration
  reg                     write_sel;
  wire                    nxt_write_sel;
  wire                    write_sel_we;

  // Unpacked address/control
  wire [(ADDR_WIDTH-1):0] unpk_wr_addr;
  wire                    unpk_wr_last;
  wire                    unpk_wr_valid;
  wire                    unpk_wr_ready;
  wire [(ADDR_WIDTH-1):0] unpk_rd_addr;
  wire                    unpk_rd_last;
  wire                    unpk_rd_valid;
  wire                    unpk_rd_ready;

  // ACE signals
  wire                    ace_awready;
  wire                    ace_arready;
  reg  [5:0]              ace_arid_reg;
  wire                    ace_arid_reg_we;
  reg  [5:0]              ace_rid;
  wire                    ace_rid_we;
  reg  [4:0]              ace_bid;
  wire                    ace_bid_we;
  reg                     ace_wready;
  wire                    nxt_ace_wready;
  reg                     ace_bvalid;
  wire                    nxt_ace_bvalid;
  wire [1:0]              ace_bresp;
  reg  [127:0]            ace_rdata;
  reg                     ace_rvalid;
  wire                    nxt_ace_rvalid;
  reg                     ace_rlast;
  wire [1:0]              ace_rresp;

  // Validation read/write
  wire                    val_read;
  wire                    val_write;
  wire                    val_rd_ongoing;
  reg                     val_rd_ongoing_reg;


  //----------------------------------------------------------------------------
  // ACE address unpacking
  //
  //   An ACE read/write request can specify a burst while only providing the
  //   address for the first transfer in the burst.  To access the validation
  //   memory resources these 'packed' addresses are unpacked into a series of
  //   requests, each providing the full address.
  //
  //   The valid signal goes high on the unpacked interface at the start of the
  //   burst and remains high for the series of unpacked addresses until the
  //   last address has been signalled ready.
  //----------------------------------------------------------------------------

  // Write channel
  execution_tb_ace_intf_addr_unpack #(.ADDR_WIDTH(ADDR_WIDTH))
    u_execution_tb_ace_intf_addr_unpack_wr
      (// Clocks and resets
       .clk             (clk),
       .reset_n         (reset_n),

       // ACE write address channel
       .ace_axaddr_i    (ace_awaddr_i),
       .ace_axburst_i   (ace_awburst_i),
       .ace_axsize_i    (ace_awsize_i),
       .ace_axlen_i     (ace_awlen_i),
       .ace_axprot_i    (ace_awprot_i),
       .ace_axvalid_i   (ace_awvalid_i),
       .ace_axready_o   (ace_awready),

       // Unpacked write address/control
       .unpk_addr_o     (unpk_wr_addr),
       .unpk_last_o     (unpk_wr_last),
       .unpk_valid_o    (unpk_wr_valid),
       .unpk_ready_i    (unpk_wr_ready)
      );

  // Read channel
  execution_tb_ace_intf_addr_unpack
    u_execution_tb_ace_intf_addr_unpack_rd
      (// Clocks and resets
       .clk             (clk),
       .reset_n         (reset_n),

       // ACE read address channel
       .ace_axaddr_i    (ace_araddr_i),
       .ace_axburst_i   (ace_arburst_i),
       .ace_axsize_i    (ace_arsize_i),
       .ace_axlen_i     (ace_arlen_i),
       .ace_axprot_i    (ace_arprot_i),
       .ace_axvalid_i   (ace_arvalid_i),
       .ace_axready_o   (ace_arready),

       // Unpacked write address channel
       .unpk_addr_o     (unpk_rd_addr),
       .unpk_last_o     (unpk_rd_last),
       .unpk_valid_o    (unpk_rd_valid),
       .unpk_ready_i    (unpk_rd_ready)
      );

  // The ACE write address channel is stalled until the ACE write channel
  // provides data on a completed W channel handshake.
  //
  // However, for the last beat of the burst the stall is extended until the end
  // of the ACE write response channel handshake.  This is required so that no
  // other requests on the AW channel are started until the current request has
  // completely cleared; the address unpacker can only handle a single
  // outstanding write.
  assign unpk_wr_ready = (ace_wvalid_i & ace_wready & ~unpk_wr_last) |
                         (ace_bvalid & ace_bready_i);

  // The ACE read address channel stalls until the read is issued to the
  // validation subsystem.
  assign unpk_rd_ready = val_read;


  //----------------------------------------------------------------------------
  // ACE transaction IDs
  //----------------------------------------------------------------------------

  // ARID register:
  //   Capture ARID on a completed ACE AR handskake to form the correct ID for
  //   the read response
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      ace_arid_reg <= {6{1'b0}};
    else if (ace_arid_reg_we)
      ace_arid_reg <= ace_arid_i;

  assign ace_arid_reg_we = ace_arready & ace_arvalid_i;

  // RID:
  //   RID will normally be from ace_arid_reg, but because we can accept the
  //   next AR request while waiting for the previous request's RREADY we have
  //   to cover this extra window.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      ace_rid <= {6{1'b0}};
    else if (ace_rid_we)
      ace_rid <= ace_arid_reg;

  assign ace_rid_we = unpk_rd_valid & ~(ace_rlast & ace_rvalid & ~ace_rready_i);


  // BID:
  //   Takes a copy of AWID when the write address handshake is complete.
  //   Bits[1:0] of the ID contains the CPU number of the CPU that made the
  //   request.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      ace_bid <= {5{1'b0}};
    else if (ace_bid_we)
      ace_bid <= ace_awid_i;

  assign ace_bid_we = ace_awready & ace_awvalid_i;


  //----------------------------------------------------------------------------
  // Write channel handshake
  //
  //   Once a write address handshake has completed, writes for that transaction
  //   do not incur any stalls.  Therefore WREADY is brought high after a write
  //   address handshake and stays high until the handshake for the last data
  //   beat completes and the write response has handshaked.
  //
  //   We must wait for the write response handshake to complete so as not to
  //   handshake any new write transactions that the processor may have
  //   presented.
  //----------------------------------------------------------------------------

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      ace_wready <= 1'b0;
    else
      ace_wready <= nxt_ace_wready;

  assign nxt_ace_wready = unpk_wr_valid &                               // Ongoing write
                          ~(ace_wvalid_i & ace_wready & ace_wlast_i) &  // Not last beat
                          ~ace_bvalid;                                  // Not waiting for BREADY


  //----------------------------------------------------------------------------
  // Write response channel handshake
  //
  //   The write response is driven after the final beat of write data has been
  //   written (i.e. its write handshake has completed.)  BVALID stays high
  //   until the processor completes the handshake.
  //----------------------------------------------------------------------------

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      ace_bvalid <= 1'b0;
    else
      ace_bvalid <= nxt_ace_bvalid;

  assign nxt_ace_bvalid = ((ace_wvalid_i & ace_wready & unpk_wr_last) | ace_bvalid) &
                          ~(ace_bvalid & ace_bready_i);

  assign ace_bresp = 2'b00; // OKAY response


  //----------------------------------------------------------------------------
  // Read channel data register and handshake
  //
  //   Read data from the validation memory model is registered before being
  //   sent to the processor.
  //
  //   RVALID is set high at the same time and stays high until the processor
  //   completes the handshake.
  //----------------------------------------------------------------------------

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      ace_rdata <= {127{1'b0}};
    else if (val_read)
      ace_rdata <= val_rd_data_i;

  // RVALID
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      ace_rvalid <= 1'b0;
    else
      ace_rvalid <= nxt_ace_rvalid;

  assign nxt_ace_rvalid = val_rd_ongoing | (ace_rvalid & ~ace_rready_i);

  // Drive RLAST from the unpacked interface when the read is ongoing
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      ace_rlast <= 1'b0;
    else if (val_read)
      ace_rlast <= unpk_rd_last;

  // The validation memories never give an error response
  assign ace_rresp = 2'b00;  // OKAY response


  //----------------------------------------------------------------------------
  // Validation read/write valid
  //
  //   A read to the validation memory interface is valid when the address
  //   unpacker signals a valid read and we are not waiting on RREADY (which
  //   stalls the next read.)
  //
  //   Since write data is accepted as soon as it is provided by the processor,
  //   a write to the validation memory interface is valid when there's
  //   a completed ACE write channel handshake.
  //----------------------------------------------------------------------------

  assign val_read  = unpk_rd_valid & ~(ace_rvalid & ~ace_rready_i);
  assign val_write = ace_wvalid_i & ace_wready;

  // Set a flag when a read is sent to the validation components and stays high
  // until the read data is presented to the ACE interface, accounting for any
  // stalls from the RVALID/RREADY handshake
  assign val_rd_ongoing = val_read | (val_rd_ongoing_reg & ~(ace_rvalid & ace_rready_i));

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      val_rd_ongoing_reg <= 1'b0;
    else
      val_rd_ongoing_reg <= val_rd_ongoing;


  //----------------------------------------------------------------------------
  // Output assignments
  //----------------------------------------------------------------------------

  // Validation memory interface
  assign val_read_o    = val_read;
  assign val_rd_addr_o = unpk_rd_addr;
  assign val_write_o   = val_write;
  assign val_wr_addr_o = unpk_wr_addr;
  assign val_wr_data_o = ace_wdata_i;
  assign val_wr_strb_o = ace_wstrb_i;
  assign val_wr_cpu_o  = ace_bid[1:0];

  // ACE outputs
  assign ace_awready_o = ace_awready;
  assign ace_wready_o  = ace_wready;
  assign ace_bvalid_o  = ace_bvalid;
  assign ace_bid_o     = ace_bid;
  assign ace_bresp_o   = ace_bresp;
  assign ace_arready_o = ace_arready;
  assign ace_rvalid_o  = ace_rvalid;
  assign ace_rid_o     = ace_rid;
  assign ace_rdata_o   = ace_rdata;
  assign ace_rresp_o   = ace_rresp;
  assign ace_rlast_o   = ace_rlast;

  // Coherency channel tie-offs
  assign ace_acvalid_o = 1'b0;
  assign ace_acaddr_o  = {44{1'b0}};
  assign ace_acprot_o  = {3{1'b0}};
  assign ace_acsnoop_o = {4{1'b0}};
  assign ace_crready_o = 1'b1;
  assign ace_cdready_o = 1'b1;

endmodule


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
//   Execution testbence ACE subsystem.  This is used when the processor is
//   configured with an ACE interface.
//
//   Note that since the execution testbench is a single-master, single-slave
//   system there is no need for a coherent interconnect.  The testbench drives
//   the processor's SYSBARDISABLE pin high and BROADCASTINNER, BROADCASTOUTER
//   and BROADCASTCACHEMAINT inputs low.  This disables the broadcast of
//   barriers and cache maintenance operations.
//
//   The following ACE channels are therefore safely tied off:
//     - Coherency address channel
//     - Coherency data channel
//     - Coherency response channel
//----------------------------------------------------------------------------

module execution_tb_val_sys_ace #(parameter integer NUM_CPUS = 1)
(
  // Clocks and resets
  input  wire                   clk,
  input  wire                   reset_n,

  // ACE interface
  //   NB. this interface is to be connected directly to the processor, not via
  //   an interconnect
  output wire                   ace_awready_o,
  input  wire                   ace_awvalid_i,
  input  wire [4:0]             ace_awid_i,
  input  wire [43:0]            ace_awaddr_i,
  input  wire [7:0]             ace_awlen_i,
  input  wire [2:0]             ace_awsize_i,
  input  wire [1:0]             ace_awburst_i,
  input  wire [1:0]             ace_awbar_i,
  input  wire [1:0]             ace_awdomain_i,
  input  wire                   ace_awlock_i,
  input  wire [3:0]             ace_awcache_i,
  input  wire [2:0]             ace_awprot_i,
  input  wire [2:0]             ace_awsnoop_i,
  input  wire                   ace_awunique_i,
  output wire                   ace_wready_o,
  input  wire                   ace_wvalid_i,
  input  wire [4:0]             ace_wid_i,
  input  wire [127:0]           ace_wdata_i,
  input  wire [15:0]            ace_wstrb_i,
  input  wire                   ace_wlast_i,
  input  wire                   ace_bready_i,
  output wire                   ace_bvalid_o,
  output wire [4:0]             ace_bid_o,
  output wire [1:0]             ace_bresp_o,
  output wire                   ace_arready_o,
  input  wire                   ace_arvalid_i,
  input  wire [5:0]             ace_arid_i,
  input  wire [43:0]            ace_araddr_i,
  input  wire [7:0]             ace_arlen_i,
  input  wire [2:0]             ace_arsize_i,
  input  wire [1:0]             ace_arburst_i,
  input  wire [1:0]             ace_arbar_i,
  input  wire [1:0]             ace_ardomain_i,
  input  wire                   ace_arlock_i,
  input  wire [3:0]             ace_arcache_i,
  input  wire [2:0]             ace_arprot_i,
  input  wire [3:0]             ace_arsnoop_i,
  input  wire                   ace_rready_i,
  output wire                   ace_rvalid_o,
  output wire [5:0]             ace_rid_o,
  output wire [127:0]           ace_rdata_o,
  output wire [3:0]             ace_rresp_o,
  output wire                   ace_rlast_o,
  input  wire                   ace_acready_i,
  output wire                   ace_acvalid_o,
  output wire [43:0]            ace_acaddr_o,
  output wire [2:0]             ace_acprot_o,
  output wire [3:0]             ace_acsnoop_o,
  output wire                   ace_crready_o,
  input  wire                   ace_crvalid_i,
  input  wire [4:0]             ace_crresp_i,
  output wire                   ace_cdready_o,
  input  wire                   ace_cdvalid_i,
  input  wire [127:0]           ace_cddata_i,
  input  wire                   ace_cdlast_i,
  input  wire                   ace_rack_i,
  input  wire                   ace_wack_i,

  // Trickbox signals
  output wire [(NUM_CPUS-1):0]  tbox_nfiq_o,
  output wire [63:0]            tbox_cntvalueb_o
);


  //----------------------------------------------------------------------------
  // Local constants
  //----------------------------------------------------------------------------

  localparam integer ADDR_WIDTH = 44;  // Address width on the validation subsystem


  //----------------------------------------------------------------------------
  // Signal declarations
  //----------------------------------------------------------------------------

  // Internal validation memory interface
  wire                    val_read;
  wire [(ADDR_WIDTH-1):0] val_rd_addr;
  wire [127:0]            val_rd_data;
  wire                    val_write;
  wire                    val_write_mem;
  wire                    val_write_tube;
  wire                    val_write_tbox_fcnt;
  wire                    val_write_tbox_fclr;
  wire [(ADDR_WIDTH-1):0] val_wr_addr;
  wire [15:0]             val_wr_strb;
  wire [1:0]              val_wr_cpu;
  wire [127:0]            val_wr_data;

  // Trickbox
  wire [63:0]             tbox_cntvalueb;


  //----------------------------------------------------------------------------
  // ACE interface
  //
  //   Handles the ACE transactions and creates the internal validation memory
  //   bus, which is a simpler interface with all bursts unpacked into
  //   individual transactions.
  //----------------------------------------------------------------------------

  execution_tb_ace_intf #(.ADDR_WIDTH(44))
    u_execution_tb_ace_intf
      (// Clocks and resets
       .clk             (clk),
       .reset_n         (reset_n),

       // ACE slave interface
       .ace_awready_o   (ace_awready_o),
       .ace_awvalid_i   (ace_awvalid_i),
       .ace_awid_i      (ace_awid_i),
       .ace_awaddr_i    (ace_awaddr_i),
       .ace_awlen_i     (ace_awlen_i),
       .ace_awsize_i    (ace_awsize_i),
       .ace_awburst_i   (ace_awburst_i),
       .ace_awbar_i     (ace_awbar_i),
       .ace_awdomain_i  (ace_awdomain_i),
       .ace_awlock_i    (ace_awlock_i),
       .ace_awcache_i   (ace_awcache_i),
       .ace_awprot_i    (ace_awprot_i),
       .ace_awsnoop_i   (ace_awsnoop_i),
       .ace_awunique_i  (ace_awunique_i),
       .ace_wready_o    (ace_wready_o),
       .ace_wvalid_i    (ace_wvalid_i),
       .ace_wid_i       (ace_wid_i),
       .ace_wdata_i     (ace_wdata_i),
       .ace_wstrb_i     (ace_wstrb_i),
       .ace_wlast_i     (ace_wlast_i),
       .ace_bready_i    (ace_bready_i),
       .ace_bvalid_o    (ace_bvalid_o),
       .ace_bid_o       (ace_bid_o),
       .ace_bresp_o     (ace_bresp_o),
       .ace_arready_o   (ace_arready_o),
       .ace_arvalid_i   (ace_arvalid_i),
       .ace_arid_i      (ace_arid_i),
       .ace_araddr_i    (ace_araddr_i),
       .ace_arlen_i     (ace_arlen_i),
       .ace_arsize_i    (ace_arsize_i),
       .ace_arburst_i   (ace_arburst_i),
       .ace_arbar_i     (ace_arbar_i),
       .ace_ardomain_i  (ace_ardomain_i),
       .ace_arlock_i    (ace_arlock_i),
       .ace_arcache_i   (ace_arcache_i),
       .ace_arprot_i    (ace_arprot_i),
       .ace_arsnoop_i   (ace_arsnoop_i),
       .ace_rready_i    (ace_rready_i),
       .ace_rvalid_o    (ace_rvalid_o),
       .ace_rid_o       (ace_rid_o),
       .ace_rdata_o     (ace_rdata_o),
       .ace_rresp_o     (ace_rresp_o),
       .ace_rlast_o     (ace_rlast_o),
       .ace_acready_i   (ace_acready_i),
       .ace_acvalid_o   (ace_acvalid_o),
       .ace_acaddr_o    (ace_acaddr_o),
       .ace_acprot_o    (ace_acprot_o),
       .ace_acsnoop_o   (ace_acsnoop_o),
       .ace_crready_o   (ace_crready_o),
       .ace_crvalid_i   (ace_crvalid_i),
       .ace_crresp_i    (ace_crresp_i),
       .ace_cdready_o   (ace_cdready_o),
       .ace_cdvalid_i   (ace_cdvalid_i),
       .ace_cddata_i    (ace_cddata_i),
       .ace_cdlast_i    (ace_cdlast_i),

       // Internal interface
       .val_read_o      (val_read),
       .val_rd_addr_o   (val_rd_addr),
       .val_rd_data_i   (val_rd_data),
       .val_write_o     (val_write),
       .val_wr_addr_o   (val_wr_addr),
       .val_wr_strb_o   (val_wr_strb),
       .val_wr_cpu_o    (val_wr_cpu),
       .val_wr_data_o   (val_wr_data)
      );


  //----------------------------------------------------------------------------
  // System address decoder
  //
  //   The validation memory starts at address 0x000_0000_0000 and aliases
  //   through the whole memory map, except for the region 0x000_1300_0000 to
  //   0x000_13FF_FFFF which is reserved for the tube and trickbox registers.
  //
  //   This region contains:
  //
  //     0x000_1300_0000 : Tube
  //     0x000_1300_0008 : Trickbox - FIQ counter load
  //     0x000_1300_000C : Trickbox - FIQ clear
  //
  //   Other locations in the trickbox region are reserved.
  //----------------------------------------------------------------------------

  execution_tb_val_decoder
    u_execution_tb_val_decoder
      (// Master write interface
       .val_write_i           (val_write),
       .val_wr_addr_i         (val_wr_addr),
       .val_wr_strb_i         (val_wr_strb),

       // Individual write enables
       .val_write_mem_o       (val_write_mem),
       .val_write_tube_o      (val_write_tube),
       .val_write_tbox_fcnt_o (val_write_tbox_fcnt),
       .val_write_tbox_fclr_o (val_write_tbox_fclr)
      );


  //----------------------------------------------------------------------------
  // Memory model
  //----------------------------------------------------------------------------

  execution_tb_val_mem #(.ADDR_RANGE(24))
    u_execution_tb_val_mem
    (// Clocks
     .clk                 (clk),

     // Read port
     .val_read_i          (val_read),
     .val_rd_addr_i       (val_rd_addr),
     .val_rd_data_o       (val_rd_data),

     // Write port
     .val_write_i         (val_write_mem),
     .val_wr_addr_i       (val_wr_addr),
     .val_wr_strb_i       (val_wr_strb),
     .val_wr_data_i       (val_wr_data)
    );


  //----------------------------------------------------------------------------
  // Tube
  //----------------------------------------------------------------------------

  execution_tb_val_tube #(.NUM_CPUS(NUM_CPUS))
    u_execution_tb_val_tube
      (// Clocks and resets
       .clk               (clk),
       .reset_n           (reset_n),

       // Write port
       .val_write_tube_i  (val_write_tube),
       .val_wr_cpu_i      (val_wr_cpu),
       .val_wr_data_i     (val_wr_data),

       // Cycle counter
       .tbox_cntvalueb_i  (tbox_cntvalueb)
      );


  //----------------------------------------------------------------------------
  // Trickbox
  //----------------------------------------------------------------------------

  execution_tb_val_tbox #(.NUM_CPUS(NUM_CPUS))
    u_execution_tb_val_tbox
      (// Clocks and resets
       .clk                   (clk),
       .reset_n               (reset_n),

       // Write port
       .val_write_tbox_fcnt_i (val_write_tbox_fcnt),
       .val_write_tbox_fclr_i (val_write_tbox_fclr),
       .val_wr_addr_i         (val_wr_addr),
       .val_wr_data_i         (val_wr_data),

       // Trickbox outputs
       .tbox_nfiq_o           (tbox_nfiq_o),
       .tbox_cntvalueb_o      (tbox_cntvalueb)
      );


  //----------------------------------------------------------------------------
  // Output assignments
  //----------------------------------------------------------------------------

  assign tbox_cntvalueb_o = tbox_cntvalueb;

endmodule


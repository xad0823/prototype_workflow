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
//   Execution testbench validation subsystem with a Skyros-based bus model.
//   This is used when the processor is configured with the Skyros interface.
//
//   NOTE:
//     The execution testbench is a single-master, single-slave system with
//     a simple validation memory.  This Skyros functional model implements only
//     the subset of functionality required for the execution testbench
//     environment and is not a general-purpose Skyros interconnect.
//
//     In particular, this logic assumes that all BROADCAST* inputs to the
//     processor are tied LOW.  As such, only ReadNoSnoop, WriteNoSnoop,
//     barriers and some miscellaneous transaction types are supported.  The
//     barrier transactions are only trivially implemented because there is only
//     one master in the system.
//
//     Logically, this subsystem implements a Miscellaneous Node (MN) for
//     handling the barriers and a HN-I for the read and write transactions.
//     Physically, these transactions are handled in the same logic.
//------------------------------------------------------------------------------

module execution_tb_val_sys_sky #(parameter integer NUM_CPUS  = 1,
                                  parameter [6:0]   HNINODEID = 7'b0000001,
                                  parameter [6:0]   MNNODEID  = 7'b0001111)
(
  // Clocks and resets
  input  wire                   clk,
  input  wire                   reset_n,

  // Skyros interface
  //   NB. this interface is to be connected directly to the processor, not via
  //   an interconnect
  input  wire                   rxlinkactivereq_i,
  output wire                   rxlinkactiveack_o,
  output wire                   txlinkactivereq_o,
  input  wire                   txlinkactiveack_i,
  output wire                   txsactive_o,
  input  wire                   rxreqflitpend_i,
  input  wire                   rxreqflitv_i,
  input  wire [99:0]            rxreqflit_i,
  output wire                   rxreqlcrdv_o,
  input  wire                   rxrspflitpend_i,
  input  wire                   rxrspflitv_i,
  input  wire [44:0]            rxrspflit_i,
  output wire                   rxrsplcrdv_o,
  input  wire                   rxdatflitpend_i,
  input  wire                   rxdatflitv_i,
  input  wire [193:0]           rxdatflit_i,
  output wire                   rxdatlcrdv_o,
  output wire                   txrspflitpend_o,
  output wire                   txrspflitv_o,
  output wire [44:0]            txrspflit_o,
  input  wire                   txrsplcrdv_i,
  output wire                   txdatflitpend_o,
  output wire                   txdatflitv_o,
  output wire [193:0]           txdatflit_o,
  input  wire                   txdatlcrdv_i,
  output wire                   txsnpflitpend_o,
  output wire                   txsnpflitv_o,
  output wire [64:0]            txsnpflit_o,
  input  wire                   txsnplcrdv_i,

  // Trickbox signals
  output wire [(NUM_CPUS-1):0]  tbox_nfiq_o,
  output wire [63:0]            tbox_cntvalueb_o
);


  //----------------------------------------------------------------------------
  // Local constants
  //----------------------------------------------------------------------------

  localparam integer ADDR_WIDTH = 44;  // Address width on the validation subsystem

  // Common Skyros constants
  `include "execution_tb_sky_defs.v"


  //----------------------------------------------------------------------------
  // Signal declarations
  //----------------------------------------------------------------------------

  // Link active states
  reg  [1:0]      txlinkactive_st;
  reg  [1:0]      rxlinkactive_st;
  reg  [1:0]      nxt_txlinkactive_st;
  reg  [1:0]      nxt_rxlinkactive_st;
  wire            txlinkactivereq;
  wire            rxlinkactiveack;
  wire            tx_activate;
  wire            tx_deactivate;
  wire            rx_stop;
  wire            rx_nocredit;

  // RXREQ channel
  wire            rxreq_ch_active;
  wire            rxreq_ch_flitv;
  wire [99:0]     rxreq_ch_flit;
  wire            rxreq_ch_pop;
  wire            rxreq_ch_crd_rtn;

  // RXDAT channel
  wire            rxdat_ch_active;
  wire            rxdat_ch_flitv;
  wire [193:0]    rxdat_ch_flit;
  wire            rxdat_ch_pop;
  wire            rxdat_ch_crd_rtn;

  // RXRSP channel
  wire            rxrsp_ch_active;
  wire            rxrsp_ch_flitv;
  wire [44:0]     rxrsp_ch_flit;
  wire            rxrsp_ch_pop;
  wire            rxrsp_ch_crd_rtn;

  // TXRSP channel
  wire            txrsp_ch_full;
  wire            txrsp_ch_empty;
  wire            txrsp_ch_push;
  wire [44:0]     txrsp_ch_flit;

  // TXDAT channel
  wire            txdat_ch_full;
  wire            txdat_ch_empty;
  wire            txdat_ch_push;
  wire [193:0]    txdat_ch_flit;

  // TXSACTIVE signalling
  wire            pcomplete;
  reg             txsactive;
  wire            nxt_txsactive;

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
  // Link activation and de-activation
  //----------------------------------------------------------------------------

  // All links are de-activated state out of reset
  always @ (posedge clk or negedge reset_n)
    if (!reset_n) begin
      txlinkactive_st <= SKY_LINK_STOP;
      rxlinkactive_st <= SKY_LINK_STOP;
    end else begin
      txlinkactive_st <= nxt_txlinkactive_st;
      rxlinkactive_st <= nxt_rxlinkactive_st;
    end

  // Next RX state
  always @ (*)
    case (rxlinkactive_st)
      SKY_LINK_STOP:       nxt_rxlinkactive_st = rxlinkactivereq_i ? SKY_LINK_ACTIVATE : SKY_LINK_STOP;
      SKY_LINK_ACTIVATE:   nxt_rxlinkactive_st = SKY_LINK_RUN;
      SKY_LINK_RUN:        nxt_rxlinkactive_st = rxlinkactivereq_i ? SKY_LINK_RUN      : SKY_LINK_DEACTIVATE;
      SKY_LINK_DEACTIVATE: nxt_rxlinkactive_st = rx_stop           ? SKY_LINK_STOP     : SKY_LINK_DEACTIVATE;
      default:             nxt_rxlinkactive_st = 2'bXX;
    endcase

  // Next TX state
  always @ (*)
    case (txlinkactive_st)
      SKY_LINK_STOP:       nxt_txlinkactive_st = tx_activate       ? SKY_LINK_ACTIVATE   : SKY_LINK_STOP;
      SKY_LINK_ACTIVATE:   nxt_txlinkactive_st = txlinkactiveack_i ? SKY_LINK_RUN        : SKY_LINK_ACTIVATE;
      SKY_LINK_RUN:        nxt_txlinkactive_st = tx_deactivate     ? SKY_LINK_DEACTIVATE : SKY_LINK_RUN;
      SKY_LINK_DEACTIVATE: nxt_txlinkactive_st = txlinkactiveack_i ? SKY_LINK_DEACTIVATE : SKY_LINK_STOP;
    endcase

  // RXLINKACTIVEACK / TXLINKACTIVEREQ
  assign txlinkactivereq = txlinkactive_st[1];
  assign rxlinkactiveack = rxlinkactive_st[0];

  // TX link activation and de-activation
  //   - Acitvation from TXLA_STOP occurs when:
  //      - There are flits to send and the receiver is in RXLA_STOP; or
  //      - The receiver interface is in RXLA_ACTIVATE.
  //   - De-activation from TXLA_RUN occurs when:
  //      - The receiver is in the RXLA_DEACTIVATE state.
  //
  // Note that this component does not deactivate its TX links when there is
  // nothing to transmit; they are only de-activated in response to the receiver
  // de-activating as required by the protocol.
  assign tx_activate   = (~rxlinkactivereq_i & ~rxlinkactiveack & ~txdat_ch_empty) |
                         ( rxlinkactivereq_i & ~rxlinkactiveack                  );
  assign tx_deactivate =  ~rxlinkactivereq_i &  rxlinkactiveack;

  // RX link DEACTIVATE -> STOP (i.e. de-assert RXLINKACTIVEACK) when all
  // oustanding credits have been returned.
  assign rx_stop = rx_nocredit & ~txlinkactivereq;

  // TXSACTIVE is set whenever there are RX requests in the FIFO.  It is cleared
  // when the protocol layer is complete, and there are no further requests to
  // process.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      txsactive <= 1'b0;
    else
      txsactive <= nxt_txsactive;

  assign nxt_txsactive = ((rxreq_ch_flitv & (rxlinkactive_st == SKY_LINK_RUN)) | txsactive) &
                         ~(pcomplete & ~rxreq_ch_flitv);


  //----------------------------------------------------------------------------
  // RX channels
  //----------------------------------------------------------------------------

  // RXREQ
  execution_tb_sky_rx_chan #(.FLIT_WIDTH(100),
                             .FIFO_DEPTH(4))
    u_execution_tb_rxreq_chan
      (.clk               (clk),
       .reset_n           (reset_n),
       .rxflitv_i         (rxreqflitv_i),
       .rxflit_i          (rxreqflit_i),
       .rxlcrdv_o         (rxreqlcrdv_o),
       .rxlinkactive_st_i (rxlinkactive_st),
       .ch_active_o       (rxreq_ch_active),
       .ch_flitv_o        (rxreq_ch_flitv),
       .ch_flit_o         (rxreq_ch_flit),
       .ch_pop_i          (rxreq_ch_pop),
       .ch_crd_rtn_i      (rxreq_ch_crd_rtn)
      );

  // RXRSP
  execution_tb_sky_rx_chan #(.FLIT_WIDTH(45),
                             .FIFO_DEPTH(4))
    u_execution_tb_rxrsp_chan
      (.clk               (clk),
       .reset_n           (reset_n),
       .rxflitv_i         (rxrspflitv_i),
       .rxflit_i          (rxrspflit_i),
       .rxlcrdv_o         (rxrsplcrdv_o),
       .rxlinkactive_st_i (rxlinkactive_st),
       .ch_active_o       (rxrsp_ch_active),
       .ch_flitv_o        (rxrsp_ch_flitv),
       .ch_flit_o         (rxrsp_ch_flit),
       .ch_pop_i          (rxrsp_ch_pop),
       .ch_crd_rtn_i      (rxrsp_ch_crd_rtn)
      );

  // RXDAT
  execution_tb_sky_rx_chan #(.FLIT_WIDTH(194),
                             .FIFO_DEPTH(4))
    u_execution_tb_rxdat_chan
      (.clk               (clk),
       .reset_n           (reset_n),
       .rxflitv_i         (rxdatflitv_i),
       .rxflit_i          (rxdatflit_i),
       .rxlcrdv_o         (rxdatlcrdv_o),
       .rxlinkactive_st_i (rxlinkactive_st),
       .ch_active_o       (rxdat_ch_active),
       .ch_flitv_o        (rxdat_ch_flitv),
       .ch_flit_o         (rxdat_ch_flit),
       .ch_pop_i          (rxdat_ch_pop),
       .ch_crd_rtn_i      (rxdat_ch_crd_rtn)
      );

  // Indicate when no credits are in issue on any RX channels
  assign rx_nocredit = ~rxreq_ch_active & ~rxrsp_ch_active & ~rxdat_ch_active;


  //----------------------------------------------------------------------------
  // TX channels
  //----------------------------------------------------------------------------

  // TXRSP
  execution_tb_sky_tx_chan #(.FLIT_WIDTH(45),
                             .FIFO_DEPTH(4))
    u_execution_tb_txrsp_chan
      (.clk               (clk),
       .reset_n           (reset_n),
       .txflitpend_o      (txrspflitpend_o),
       .txflitv_o         (txrspflitv_o),
       .txflit_o          (txrspflit_o),
       .txlcrdv_i         (txrsplcrdv_i),
       .txlinkactive_st_i (txlinkactive_st),
       .ch_full_o         (txrsp_ch_full),
       .ch_empty_o        (txrsp_ch_empty),
       .ch_push_i         (txrsp_ch_push),
       .ch_flit_i         (txrsp_ch_flit)
      );

  // TXDAT
  execution_tb_sky_tx_chan #(.FLIT_WIDTH(194),
                             .FIFO_DEPTH(4))
    u_execution_tb_txdat_chan
      (.clk               (clk),
       .reset_n           (reset_n),
       .txflitpend_o      (txdatflitpend_o),
       .txflitv_o         (txdatflitv_o),
       .txflit_o          (txdatflit_o),
       .txlcrdv_i         (txdatlcrdv_i),
       .txlinkactive_st_i (txlinkactive_st),
       .ch_full_o         (txdat_ch_full),
       .ch_empty_o        (txdat_ch_empty),
       .ch_push_i         (txdat_ch_push),
       .ch_flit_i         (txdat_ch_flit)
      );

  // TXSNP
  //   Note: this slave does not generate snoops, but we instantiate a
  //         TX channel to honour the link-layer credit exchange.
  execution_tb_sky_tx_chan #(.FLIT_WIDTH(65),
                             .FIFO_DEPTH(4))
    u_execution_tb_txsnp_chan
      (.clk               (clk),
       .reset_n           (reset_n),
       .txflitpend_o      (txsnpflitpend_o),
       .txflitv_o         (txsnpflitv_o),
       .txflit_o          (txsnpflit_o),
       .txlcrdv_i         (txsnplcrdv_i),
       .txlinkactive_st_i (txlinkactive_st),
       .ch_full_o         (),           // Not used - never full
       .ch_empty_o        (),           // Not used - always empty
       .ch_push_i         (1'b0),       // No snoop flits generated
       .ch_flit_i         ({65{1'b0}})
      );


  //----------------------------------------------------------------------------
  // Skyros to validation interface
  //----------------------------------------------------------------------------

  execution_tb_sky_intf #(.ADDR_WIDTH(ADDR_WIDTH),
                          .HNINODEID (HNINODEID),
                          .MNNODEID  (MNNODEID))
    u_execution_tb_sky_intf
      (// Clocks and resets
       .clk                (clk),
       .reset_n            (reset_n),

       // RXREQ
       .rxreq_ch_active_i  (rxreq_ch_active),
       .rxreq_ch_flitv_i   (rxreq_ch_flitv),
       .rxreq_ch_flit_i    (rxreq_ch_flit),
       .rxreq_ch_pop_o     (rxreq_ch_pop),
       .rxreq_ch_crd_rtn_o (rxreq_ch_crd_rtn),

       // RXDAT
       .rxdat_ch_active_i  (rxdat_ch_active),
       .rxdat_ch_flitv_i   (rxdat_ch_flitv),
       .rxdat_ch_flit_i    (rxdat_ch_flit),
       .rxdat_ch_pop_o     (rxdat_ch_pop),
       .rxdat_ch_crd_rtn_o (rxdat_ch_crd_rtn),

       // RXRSP
       .rxrsp_ch_active_i  (rxrsp_ch_active),
       .rxrsp_ch_flitv_i   (rxrsp_ch_flitv),
       .rxrsp_ch_flit_i    (rxrsp_ch_flit),
       .rxrsp_ch_pop_o     (rxrsp_ch_pop),
       .rxrsp_ch_crd_rtn_o (rxrsp_ch_crd_rtn),

       // TXRSP
       .txrsp_ch_full_i    (txrsp_ch_full),
       .txrsp_ch_push_o    (txrsp_ch_push),
       .txrsp_ch_flit_o    (txrsp_ch_flit),

       // TXDAT
       .txdat_ch_full_i    (txdat_ch_full),
       .txdat_ch_push_o    (txdat_ch_push),
       .txdat_ch_flit_o    (txdat_ch_flit),

       // Protocol layer complete
       .pcomplete_o        (pcomplete),

       // Validation subsystem
       .val_read_o         (val_read),
       .val_rd_addr_o      (val_rd_addr),
       .val_rd_data_i      (val_rd_data),
       .val_write_o        (val_write),
       .val_wr_addr_o      (val_wr_addr),
       .val_wr_strb_o      (val_wr_strb),
       .val_wr_cpu_o       (val_wr_cpu),
       .val_wr_data_o      (val_wr_data)
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

  // Link active states
  assign rxlinkactiveack_o = rxlinkactiveack;
  assign txlinkactivereq_o = txlinkactivereq;
  assign txsactive_o       = txsactive;

  // Trickbox counter
  assign tbox_cntvalueb_o = tbox_cntvalueb;

endmodule


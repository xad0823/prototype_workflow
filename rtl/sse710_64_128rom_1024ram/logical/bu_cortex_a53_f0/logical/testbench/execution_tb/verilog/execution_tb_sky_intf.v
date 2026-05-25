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
//   Takes a set of Skyros channels and decodes them into transactions on the
//   validation interface.  Sends responses from the validation interface
//   back through the Skyros TX channels.
//
//   This module is responsible for decoding the flits and popping entries from
//   each channel's FIFO as required.
//
//   The validation subsystem can handle a single read or write on each cycle.
//   Reads and writes are performed in the order they are popped from the
//   Skyros request channel FIFO.
//------------------------------------------------------------------------------

module execution_tb_sky_intf #(parameter integer ADDR_WIDTH = 44,
                               parameter [6:0]   HNINODEID  = 7'b0000001,
                               parameter [6:0]   MNNODEID   = 7'b0001111)
(
  // Clocks and resets
  input  wire                    clk,
  input  wire                    reset_n,

  // RXREQ
  input  wire                    rxreq_ch_active_i,
  input  wire                    rxreq_ch_flitv_i,
  input  wire [99:0]             rxreq_ch_flit_i,
  output wire                    rxreq_ch_pop_o,
  output wire                    rxreq_ch_crd_rtn_o,

  // RXDAT
  input  wire                    rxdat_ch_active_i,
  input  wire                    rxdat_ch_flitv_i,
  input  wire [193:0]            rxdat_ch_flit_i,
  output wire                    rxdat_ch_pop_o,
  output wire                    rxdat_ch_crd_rtn_o,

  // RXRSP
  input  wire                    rxrsp_ch_active_i,
  input  wire                    rxrsp_ch_flitv_i,
  input  wire [44:0]             rxrsp_ch_flit_i,
  output wire                    rxrsp_ch_pop_o,
  output wire                    rxrsp_ch_crd_rtn_o,

  // TXRSP
  input  wire                    txrsp_ch_full_i,
  output wire                    txrsp_ch_push_o,
  output wire [44:0]             txrsp_ch_flit_o,

  // TXDAT
  input  wire                    txdat_ch_full_i,
  output wire                    txdat_ch_push_o,
  output wire [193:0]            txdat_ch_flit_o,

  // Protocol layer complete
  output wire                    pcomplete_o,

  // Validation subsystem
  output wire                    val_read_o,
  output wire [(ADDR_WIDTH-1):0] val_rd_addr_o,
  input  wire [127:0]            val_rd_data_i,
  output wire                    val_write_o,
  output wire [(ADDR_WIDTH-1):0] val_wr_addr_o,
  output wire [15:0]             val_wr_strb_o,
  output wire [1:0]              val_wr_cpu_o,
  output wire [127:0]            val_wr_data_o
);

  //----------------------------------------------------------------------------
  // Local constants
  //----------------------------------------------------------------------------

  // Supported request opcodes
  localparam [4:0] SKY_REQ_LINKFLIT         = 5'h00;
  localparam [4:0] SKY_REQ_READNOSNOOP      = 5'h04;
  localparam [4:0] SKY_REQ_EOBARRIER        = 5'h0E;
  localparam [4:0] SKY_REQ_ECBARRIER        = 5'h0F;
  localparam [4:0] SKY_REQ_WRITENOSNOOPPTL  = 5'h1C;
  localparam [4:0] SKY_REQ_WRITENOSNOOPFULL = 5'h1D;

  // Unsupported request opcodes that must nevertheless be decoded for the
  // purpose of error reporting.  Note this isn't the complete list of
  // unsupported request opcodes but only those that require a specific type of
  // response.
  localparam [4:0] SKY_REQ_WRITEEVICTFULL   = 5'h15;
  localparam [4:0] SKY_REQ_WRITECLEANPTL    = 5'h16;
  localparam [4:0] SKY_REQ_WRITECLEANFULL   = 5'h17;
  localparam [4:0] SKY_REQ_WRITEUNIQUEPTL   = 5'h18;
  localparam [4:0] SKY_REQ_WRITEUNIQUEFULL  = 5'h19;
  localparam [4:0] SKY_REQ_WRITEBACKPTL     = 5'h1A;
  localparam [4:0] SKY_REQ_WRITEBACKFULL    = 5'h1B;

  // Supported response opcodes
  localparam [3:0] SKY_RSP_LINKFLIT         = 4'h0;
  localparam [3:0] SKY_RSP_COMPACK          = 4'h2;
  localparam [3:0] SKY_RSP_COMP             = 4'h4;
  localparam [3:0] SKY_RSP_COMPDBIDRESP     = 4'h5;
  localparam [3:0] SKY_RSP_READRECEIPT      = 4'h8;

  // Supported response data opcodes
  localparam [2:0] SKY_DAT_LINKFLIT         = 3'h0;
  localparam [2:0] SKY_DAT_NONCOPYBACKWRDATA= 3'h3;
  localparam [2:0] SKY_DAT_COMPDATA         = 3'h4;

  // Supported RespErr encodings
  localparam [1:0] SKY_RESPERR_OKAY         = 2'b00;
  localparam [1:0] SKY_RESPERR_NONDATA_ERR  = 2'b11;


  //------------------------------------------------------------------------------
  // Signal declarations
  //------------------------------------------------------------------------------

  wire                    rxreq_pop;
  reg  [6:0]              rxreq_tgtid;
  reg  [6:0]              rxreq_srcid;
  reg  [7:0]              rxreq_txnid;
  reg  [5:0]              rxreq_opcode;
  reg  [2:0]              rxreq_size;
  reg  [43:0]             rxreq_addr;
  reg  [1:0]              rxreq_order;
  reg  [2:0]              rxreq_lpid;
  reg                     rxreq_expcompack;
  reg  [3:0]              rxreq_rsvd;
  reg                     rxreq_valid;

  wire                    rxdat_pop;
  reg  [6:0]              rxdat_tgtid;
  reg  [6:0]              rxdat_srcid;
  reg  [7:0]              rxdat_txnid;
  reg  [2:0]              rxdat_opcode;
  reg  [1:0]              rxdat_resperr;
  reg  [2:0]              rxdat_resp;
  reg  [7:0]              rxdat_dbid;
  reg  [1:0]              rxdat_ccid;
  reg  [1:0]              rxdat_dataid;
  reg  [15:0]             rxdat_be;
  reg  [127:0]            rxdat_data;
  reg                     rxdat_valid;

  wire                    read_valid;
  wire                    writeany_valid;
  wire                    writenosnp_valid;
  wire                    unsupported_req;
  reg  [1:0]              rxreq_beats;

  wire                    unpk_valid;
  wire [(ADDR_WIDTH-1):0] unpk_addr;
  wire [1:0]              unpk_chunk;
  wire                    unpk_last;
  wire                    unpk_ready;
  reg                     read_ongoing;
  wire                    nxt_read_ongoing;

  reg  [1:0]              write_cnt;
  wire [1:0]              nxt_write_cnt;
  wire                    write_cnt_we;
  reg                     write_ongoing;
  wire                    nxt_write_ongoing;

  wire                    rxrsp_pop;
  reg  [6:0]              rxrsp_tgtid;
  reg  [6:0]              rxrsp_srcid;
  reg  [7:0]              rxrsp_txnid;
  reg  [3:0]              rxrsp_opcode;
  reg  [1:0]              rxrsp_resperr;
  reg  [2:0]              rxrsp_resp;
  reg  [7:0]              rxrsp_dbid;
  reg                     rxrsp_valid;
  reg                     wait_compack;
  wire                    nxt_wait_compack;
  wire                    use_exp_compack;

  wire                    txrsp_push;
  wire [3:0]              txrsp_opcode;
  wire [1:0]              txrsp_resperr;
  wire [6:0]              txrsp_srcid;
  wire [44:0]             txrsp_flit;
  wire                    txdat_push;
  wire [15:0]             txdat_be;
  wire [193:0]            txdat_flit;

  wire                    barrier;
  wire                    complete;
  wire                    rxreq_crd_rtn;
  wire                    rxdat_crd_rtn;
  wire                    rxrsp_crd_rtn;

  wire                    val_read;
  wire [(ADDR_WIDTH-1):0] val_rd_addr;
  wire                    val_write;
  wire [(ADDR_WIDTH-1):0] val_wr_addr;
  wire [15:0]             val_wr_strb;
  wire [1:0]              val_wr_cpu;
  wire [127:0]            val_wr_data;


  //------------------------------------------------------------------------------
  // Read and write requests
  //------------------------------------------------------------------------------

  // We pop a request from the request FIFO and buffer it for sending through
  // the address unpacker.  A request is popped provided there is not already an
  // ongoing unpack operation.  This ensures that all requests are completed in
  // order.
  assign rxreq_pop = rxreq_ch_active_i & rxreq_ch_flitv_i & ~read_ongoing & ~wait_compack & ~write_ongoing;

  always @ (posedge clk)
    if (rxreq_pop) begin
      rxreq_tgtid      <= rxreq_ch_flit_i[10: 4];
      rxreq_srcid      <= rxreq_ch_flit_i[17:11];
      rxreq_txnid      <= rxreq_ch_flit_i[25:18];
      rxreq_opcode     <= rxreq_ch_flit_i[30:26];
      rxreq_size       <= rxreq_ch_flit_i[33:31];
      rxreq_addr       <= rxreq_ch_flit_i[77:34];
      rxreq_order      <= rxreq_ch_flit_i[82:81];
      rxreq_lpid       <= rxreq_ch_flit_i[93:91];
      rxreq_expcompack <= rxreq_ch_flit_i[95];
      rxreq_rsvd       <= rxreq_ch_flit_i[99:96];
    end

  // Registered pop signal tells us that the request will be processed on this
  // cycle.  For reads this means that the address will be unpacked into several
  // individual validation interface transfers.  For writes it means that we
  // prepare to take write data.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      rxreq_valid <= 1'b0;
    else
      rxreq_valid <= rxreq_pop;


  // Read and write qualification.  For writes we decode all types of writes and
  // separately deocde only the supported write types.  This is so that the
  // correct type of response can be sent.
  assign read_valid       = rxreq_valid &  (rxreq_opcode == SKY_REQ_READNOSNOOP);
  assign writeany_valid   = rxreq_valid & ((rxreq_opcode == SKY_REQ_WRITENOSNOOPPTL)  |
                                           (rxreq_opcode == SKY_REQ_WRITENOSNOOPFULL) |
                                           (rxreq_opcode == SKY_REQ_WRITEEVICTFULL)   |
                                           (rxreq_opcode == SKY_REQ_WRITECLEANPTL)    |
                                           (rxreq_opcode == SKY_REQ_WRITECLEANFULL)   |
                                           (rxreq_opcode == SKY_REQ_WRITEUNIQUEPTL)   |
                                           (rxreq_opcode == SKY_REQ_WRITEUNIQUEFULL)  |
                                           (rxreq_opcode == SKY_REQ_WRITEBACKPTL)     |
                                           (rxreq_opcode == SKY_REQ_WRITEBACKFULL));
  assign writenosnp_valid = rxreq_valid & ((rxreq_opcode == SKY_REQ_WRITENOSNOOPPTL) |
                                           (rxreq_opcode == SKY_REQ_WRITENOSNOOPFULL));
  assign unsupported_req  = rxreq_valid & ((rxreq_opcode != SKY_REQ_WRITENOSNOOPPTL)  &
                                           (rxreq_opcode != SKY_REQ_WRITENOSNOOPFULL) &
                                           (rxreq_opcode != SKY_REQ_READNOSNOOP)      &
                                           (rxreq_opcode != SKY_REQ_EOBARRIER)        &
                                           (rxreq_opcode != SKY_REQ_ECBARRIER)        &
                                           (rxreq_opcode != SKY_REQ_LINKFLIT));

  // Determine the number of beats required based on the fact that we have
  // a 16-byte response field:
  //   1 beat  : rxreq_beats = 0
  //   2 beats : rxreq_beats = 1
  //   4 beats : rxreq_beats = 3
  always @ (*)
    case (rxreq_size)
      3'b000:  rxreq_beats = 2'b00;  // 1 beat
      3'b001:  rxreq_beats = 2'b00;
      3'b010:  rxreq_beats = 2'b00;
      3'b011:  rxreq_beats = 2'b00;
      3'b100:  rxreq_beats = 2'b00;
      3'b101:  rxreq_beats = 2'b01;  // 2 beats
      3'b110:  rxreq_beats = 2'b11;  // 4 beats
      3'b111:  rxreq_beats = 2'b00;  // Illegal
      default: rxreq_beats = 2'bXX;
    endcase


  //----------------------------------------------------------------------------
  // Read address unpacking
  //
  //   A request will require up to four transfers, depending on the size of the
  //   request.  The requested address is unpacked into the required number of
  //   individual transfers, each address being incremented based on the
  //   transfer size.
  //----------------------------------------------------------------------------

  execution_tb_sky_intf_addr_unpack #(.ADDR_WIDTH(ADDR_WIDTH))
    u_execution_tb_sky_intf_addr_unpack
      (// Clocks and resets
       .clk             (clk),
       .reset_n         (reset_n),

       // Request properties
       .req_valid_i     (read_valid),  // Valid ReadNoSnoop transaction
       .req_addr_i      (rxreq_addr),
       .req_beats_i     (rxreq_beats),

       // Unpacked address interface
       .unpk_valid_o    (unpk_valid),
       .unpk_addr_o     (unpk_addr),
       .unpk_chunk_o    (unpk_chunk),
       .unpk_last_o     (unpk_last),
       .unpk_ready_i    (unpk_ready)
      );

  // Stall unpacker if transmit channels are too busy
  assign unpk_ready = ~txrsp_ch_full_i & ~txdat_ch_full_i;

  // Status flag to indicate when a read operation is ongoing.  This starts when
  // a read request has been popped from the request channel and continues until
  // the burst has been fully unpacked and the last operation has completed.
  //
  // This flag is different from unpk_valid which indicates an individual
  // unpacked operation.  There are multiple unpack operations per request and
  // these are not necessarily back-to-back, for example if there is no space in
  // the TXRSP FIFOs.  To maintain transaction ordering we do not start any
  // further unpack operations until the previous one has completely finished.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      read_ongoing <= 1'b0;
    else
      read_ongoing <= nxt_read_ongoing;

  assign nxt_read_ongoing = (rxreq_pop & (rxreq_ch_flit_i[30:26] == SKY_REQ_READNOSNOOP)) |
                            (read_ongoing & ~(unpk_valid & unpk_last));


  //----------------------------------------------------------------------------
  // Write control
  //----------------------------------------------------------------------------

  // Write control: a write operation starts when we see a write request and
  // completes once the final write data chunk has been received and converted
  // to a transaction on the validation subsystem.

  // Keep track of how many beats are yet to be written.  Note that write_cnt
  // will be zero when one beat is outstanding.  The write_ongoing flag is
  // de-asserted once the write happens.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      write_cnt <= 2'b00;
    else if (write_cnt_we)
      write_cnt <= nxt_write_cnt;

  assign nxt_write_cnt = writenosnp_valid ? rxreq_beats : (write_cnt - 2'b01);
  assign write_cnt_we  = writenosnp_valid | (val_write & (write_cnt != 2'b00));

  // Ongoing write flag.  This is set when the write request is first popped and
  // is de-asserted when the final beat is written.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      write_ongoing <= 1'b0;
    else
      write_ongoing <= nxt_write_ongoing;

  assign nxt_write_ongoing = (rxreq_pop & ((rxreq_ch_flit_i[30:26] == SKY_REQ_WRITENOSNOOPPTL) |
                                           (rxreq_ch_flit_i[30:26] == SKY_REQ_WRITENOSNOOPFULL))) |
                             // Clear when final beat is written
                             (write_ongoing & ~(val_write & (write_cnt == 2'b00)));

  // Write buffer
  //   Note: as we only handle one transaction at a time, completing each
  //   transaction before starting the next, we only have one write buffer.
  //   Therefore the DBID for write responses is always 0.
  // val_write if it's not a credit return
  assign rxdat_pop = rxdat_ch_active_i & rxdat_ch_flitv_i;

  always @ (posedge clk)
    if (rxdat_pop) begin
      rxdat_tgtid    <= rxdat_ch_flit_i[10:4];
      rxdat_srcid    <= rxdat_ch_flit_i[17:11];
      rxdat_txnid    <= rxdat_ch_flit_i[25:18];
      rxdat_opcode   <= rxdat_ch_flit_i[28:26];
      rxdat_resperr  <= rxdat_ch_flit_i[30:29];
      rxdat_resp     <= rxdat_ch_flit_i[33:31];
      rxdat_dbid     <= rxdat_ch_flit_i[41:34];
      rxdat_ccid     <= rxdat_ch_flit_i[43:42];
      rxdat_dataid   <= rxdat_ch_flit_i[45:44];
      rxdat_be       <= rxdat_ch_flit_i[65:50];
      rxdat_data     <= rxdat_ch_flit_i[193:66];
    end

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      rxdat_valid <= 1'b0;
    else
      rxdat_valid <= rxdat_pop;

  //----------------------------------------------------------------------------
  // RX responses
  //----------------------------------------------------------------------------

  assign rxrsp_pop = rxrsp_ch_active_i & rxrsp_ch_flitv_i;

  always @ (posedge clk)
    if (rxrsp_pop) begin
      rxrsp_tgtid     <= rxrsp_ch_flit_i[10:4];
      rxrsp_srcid     <= rxrsp_ch_flit_i[17:11];
      rxrsp_txnid     <= rxrsp_ch_flit_i[25:18];
      rxrsp_opcode    <= rxrsp_ch_flit_i[29:26];
      rxrsp_resperr   <= rxrsp_ch_flit_i[31:30];
      rxrsp_resp      <= rxrsp_ch_flit_i[34:32];
      rxrsp_dbid      <= rxrsp_ch_flit_i[42:35];
    end

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      rxrsp_valid <= 1'b0;
    else
      rxrsp_valid <= rxrsp_pop;

  // If a request has ExpCompAck set then we have to wait until a CompAck is
  // received before popping a new request.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      wait_compack <= 1'b0;
    else
      wait_compack <= nxt_wait_compack;

  // A link flit can have the ExpCompAck field set to any value, but should
  // be ignored, so be sure not to wait for CompAck if it's set in this case
  assign use_exp_compack  = (rxreq_opcode != SKY_REQ_LINKFLIT);
  assign nxt_wait_compack = ((rxreq_valid & use_exp_compack & rxreq_expcompack) | wait_compack) & // Set
                            ~(rxrsp_valid & (rxrsp_opcode == SKY_RSP_COMPACK));                   // Clear


  //----------------------------------------------------------------------------
  // Construct responses
  //----------------------------------------------------------------------------

  // ReadNoSnp:   Send a read receipt for ordered requests.  The execution_tb
  //              subsystem always deals with requests in order so this is
  //              straightforward.
  //
  // WriteNoSnp:  Send a response containing the data buffer ID.  Since we only
  //              handle one transaction at a time, this is always zero.  We
  //              send the completion togerther with the data buffer ID in
  //              a single CompDBIDResp packet.
  //
  // Barriers:    Send completion response
  //
  // Unsupported: Unsupported request types are provided with a non-data error
  //              response.

  // Note stall logic for the TX FIFO full case was already included in the
  // unpack stage
  assign txrsp_push = (val_read & unpk_last & (rxreq_order != 2'b00)) | writeany_valid | barrier;

  assign txrsp_opcode  = barrier         ? SKY_RSP_COMP         :
                         writeany_valid  ? SKY_RSP_COMPDBIDRESP :
                                           SKY_RSP_READRECEIPT;
  assign txrsp_resperr = unsupported_req ? SKY_RESPERR_NONDATA_ERR : SKY_RESPERR_OKAY;
  assign txrsp_srcid   = barrier         ? MNNODEID : HNINODEID;

  // TX response flit
  assign txrsp_flit[44:43] = 2'b00;         // PCrdType
  assign txrsp_flit[42:35] = 8'h00;         // DBID
  assign txrsp_flit[34:32] = 3'b000;        // Resp
  assign txrsp_flit[31:30] = txrsp_resperr; // RespErr
  assign txrsp_flit[29:26] = txrsp_opcode;  // Opcode
  assign txrsp_flit[25:18] = rxreq_txnid;   // TxnID
  assign txrsp_flit[17:11] = txrsp_srcid;   // SrcID
  assign txrsp_flit[10: 4] = rxreq_srcid;   // TgtID
  assign txrsp_flit[ 3: 0] = 4'h0;          // QoS


  // Push read data immediately. Stalls were already factored in at the unpack
  // stage.
  assign txdat_push = val_read;
  assign txdat_be   = {{4{unpk_chunk==2'b11}},  // Chunk 3 -> 0xF000
                       {4{unpk_chunk==2'b10}},  // Chunk 2 -> 0x0F00
                       {4{unpk_chunk==2'b01}},  // Chunk 1 -> 0x00F0
                       {4{unpk_chunk==2'b00}}}; // Chunk 0 -> 0x000F

  // TX read data flit
  assign txdat_flit[193:66] = val_rd_data_i;    // Data
  assign txdat_flit[65:50]  = txdat_be;         // BE
  assign txdat_flit[49:46]  = 4'h0;             // RSVD
  assign txdat_flit[45:44]  = unpk_chunk;       // DataID
  assign txdat_flit[43:42]  = rxreq_addr[5:4];  // CCID
  assign txdat_flit[41:34]  = 8'h00;            // DBID
  assign txdat_flit[33:31]  = 3'b000;           // Resp
  assign txdat_flit[30:29]  = 2'b00;            // RespErr
  assign txdat_flit[28:26]  = SKY_DAT_COMPDATA; // Opcode
  assign txdat_flit[25:18]  = rxreq_txnid;      // TxnID
  assign txdat_flit[17:11]  = HNINODEID;        // SrcID
  assign txdat_flit[10:4]   = rxreq_srcid;      // TgtID
  assign txdat_flit[3:0]    = 4'h0;             // QoS


  //----------------------------------------------------------------------------
  // Validation interface signals
  //----------------------------------------------------------------------------

  // Contruct read transactions.  These happen immediately when a a read request
  // address has been unpacked.
  assign val_read    = unpk_valid & (rxreq_opcode == SKY_REQ_READNOSNOOP);
  assign val_rd_addr = {ADDR_WIDTH{unpk_valid}} & unpk_addr[(ADDR_WIDTH-1):0];

  // Construct write transactions.  These happen when a write address has
  // previously been accepted, indicated by write_ongoing, and the data is
  // subsequently presented.
  //
  // Note:
  //   The single logical slave layout of the validation subsystem means that
  //   the write address generation is simplified slightly.  The address of each
  //   beat is:
  //     bits[43:6] - cache line address from original request
  //     bits[5 :4] - address of chunk within line, from DataID
  //
  //   The slave uses the data strobes to determine which bytes of the line to
  //   write.
  assign val_write   = rxdat_valid & write_ongoing & (rxdat_opcode == SKY_DAT_NONCOPYBACKWRDATA);
  assign val_wr_addr = {ADDR_WIDTH{rxdat_valid}} & {rxreq_addr[(ADDR_WIDTH-1):6], rxdat_dataid[1:0], 4'h0};
  assign val_wr_strb = {        16{rxdat_valid}} & rxdat_be;
  assign val_wr_cpu  = {         2{rxdat_valid}} & rxreq_lpid[1:0];
  assign val_wr_data = {       128{rxdat_valid}} & rxdat_data;


  //----------------------------------------------------------------------------
  // Barriers
  //
  //   The execution testbench supports a trivial implementation of barriers.
  //   As there is only one master and one slave, and transactions are processed
  //   in order, we must only provide the appropriste responses to barriers.
  //----------------------------------------------------------------------------

  assign barrier = rxreq_valid & ((rxreq_opcode == SKY_REQ_EOBARRIER) |
                                  (rxreq_opcode == SKY_REQ_ECBARRIER));


  //----------------------------------------------------------------------------
  // Completion
  //
  //   Indicate when protocol-layer activity has completed.  This means that
  //   a completion packet has been sent or received:
  //
  //     - a CompAck flit is received on RXRSP when waiting for CompAck; or
  //     - a NonCopyBackWrData flit is received on RXDAT; or
  //     - a ReadReceipt flit is sent on TXRSP; or
  //     - a Comp flit is sent on TXRSP (completing a barrier)
  //
  //   This signal is used together with the receiving FIFO status to form the
  //   TXSACTIVE signal.
  //----------------------------------------------------------------------------

  assign complete = (rxrsp_valid & (rxrsp_opcode == SKY_RSP_COMPACK) & wait_compack) |
                    (rxdat_valid & (rxdat_opcode == SKY_DAT_NONCOPYBACKWRDATA))      |
                    (txrsp_push  & (txrsp_opcode == SKY_RSP_READRECEIPT))            |
                    (txrsp_push  & (txrsp_opcode == SKY_RSP_COMP));


  //----------------------------------------------------------------------------
  // Credit return
  //
  //   Decode returned L-credits on the RX channels when the link is being
  //   de-activated.
  //----------------------------------------------------------------------------

  assign rxreq_crd_rtn = rxreq_valid & (rxreq_opcode == SKY_REQ_LINKFLIT) & (rxreq_txnid == 8'h00);
  assign rxdat_crd_rtn = rxdat_valid & (rxdat_opcode == SKY_DAT_LINKFLIT) & (rxdat_txnid == 8'h00);
  assign rxrsp_crd_rtn = rxrsp_valid & (rxrsp_opcode == SKY_RSP_LINKFLIT) & (rxrsp_txnid == 8'h00);


  //----------------------------------------------------------------------------
  // Output assignments
  //----------------------------------------------------------------------------

  assign rxreq_ch_pop_o     = rxreq_pop;
  assign rxreq_ch_crd_rtn_o = rxreq_crd_rtn;
  assign rxdat_ch_pop_o     = rxdat_pop;
  assign rxdat_ch_crd_rtn_o = rxdat_crd_rtn;
  assign rxrsp_ch_pop_o     = rxrsp_pop;
  assign rxrsp_ch_crd_rtn_o = rxrsp_crd_rtn;

  assign txrsp_ch_push_o    = txrsp_push;
  assign txrsp_ch_flit_o    = txrsp_flit;
  assign txdat_ch_push_o    = txdat_push;
  assign txdat_ch_flit_o    = txdat_flit;

  assign pcomplete_o        = complete;

  assign val_read_o         = val_read;
  assign val_rd_addr_o      = val_rd_addr;
  assign val_write_o        = val_write;
  assign val_wr_addr_o      = val_wr_addr;
  assign val_wr_strb_o      = val_wr_strb;
  assign val_wr_cpu_o       = val_wr_cpu;
  assign val_wr_data_o      = val_wr_data;

endmodule


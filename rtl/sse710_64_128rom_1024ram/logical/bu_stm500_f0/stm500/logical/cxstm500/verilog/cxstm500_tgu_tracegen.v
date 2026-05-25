//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2009-2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Revision            : $Revision: 38583 $
//
//      Release Information : CoreSight STM-500 Global Bundle-r0p1-00rel0
//-----------------------------------------------------------------------------
//      Purpose:
//      RTL design for STM TGU Trace Generation Block (interface to STM front
//      end blocks)
//-----------------------------------------------------------------------------

module cxstm500_tgu_tracegen #(
  parameter                          STM_DATA_WIDTH = 64   // STM data path width
  )
  (
  // Clock and Reset
  input wire                         clk_gated,            // gated clock
  input wire                         STMRESETn,            // asynchronous reset

  // TGU data interface
  input wire                         tgu_valid_i,          // TGU data transaction valid
  input wire [7:0]                   tgu_master_i,         // TGU data transaction master number
  input wire [15:0]                  tgu_channel_i,        // TGU data transaction channel number
  input wire [2:0]                   tgu_packet_type_i,    // TGU data transaction type
  input wire [(STM_DATA_WIDTH/32):0] tgu_size_i,           // TGU data transaction size
  input wire [STM_DATA_WIDTH-1:0]    tgu_payload_i,        // TGU data transaction payload
  input wire [1:0]                   tgu_ts_req_i,         // TGU data transaction timestamp request
  input wire                         tgu_fready_i,         // TGU data flush completed

  output wire                        tgu_ready_o,          // TGU data transaction ready
  output wire                        tgu_timestamped_o,    // TGU data transaction has been timestamped
  output wire                        tgu_fvalid_o,         // TGU data flush request

  // Timestamp
  input wire [63:0]                  tsvalue_i,            // Timestamp value (registered in regfile for timing)

  // Synchronization request and output
  input wire                         syncreq_i,            // sync request
  input wire                         stm_enable_syncreq_i, // sync request due to STM enable pulse
  input wire                         asyncout_i,           // sync sequence has been output

  // FIFO interface
  input wire                                              ctrl_in_ready_i,      // control fifo ready
  output wire                                             ctrl_in_valid_o,      // control fifo data ready
  output wire [3:0]                                       ctrl_in_data_o,       // control fifo data
  input wire                                              data_in_ready_i,      // data fifo ready
  output wire                                             data_in_valid_o,      // data fifo data ready
  output wire [(STM_DATA_WIDTH+(STM_DATA_WIDTH/32)+27):0] data_in_data_o,       // data fifo data, comprising:
                                                                                //     Data [32 or 64 bits],
                                                                                //     Data Size [4 or 5 bits],
                                                                                //     TS/Opcode Data [25 bits]
  input wire                                              ch_in_ready_i,        // channel fifo ready
  output wire                                             ch_in_valid_o,        // channel fifo data ready
  output wire [26:0]                                      ch_in_data_o,         // channel fifo data
  input wire                                              extts_in_ready_i,     // MSB timestamp fifo ready
  output wire                                             extts_in_valid_o,     // MSB timestamp fifo data ready
  output wire [49:0]                                      extts_in_data_o,      // MSB timestamp fifo data

  // TGU configuration and status interface
  input wire                         tgu_cfg_enable_i,     // TGU enable
  input wire                         tgu_cfg_tsen_i,       // timestamp enable
  input wire                         tgu_cfg_spcompen_i,   // compresion enable for AXI stimulus
  input wire                         tgu_cfg_hwcompen_i,   // compresion enable for HW stimulus
  input wire                         tgu_cfg_asyncpe_i,    // priority escalation for sync request
  output wire                        tracegen_clk_req_o,   // Tracegen requires clock
  output wire                        tracegen_busy_o,      // Tracegen is busy

  // Flush
  input wire                         AFVALIDM,             // ATB flush valid
  input wire                         afreadym_i,           // ATB flush ready

  // Q-Channel
  input wire                         q_stop_i,             // Q-Channel in STOPPING or STOPPED state
  input wire                         q_stopped_i           // Q-Channel in STOPPED state
  );

  //---------------------------------------------------------------------------
  // Constant definitions
  //---------------------------------------------------------------------------
  localparam CTRL_FIFO_ONLY  = 1'b0;
  localparam CTRL_USE_FIFOS  = 1'b1;

  localparam CTRL_ASYNC      = 2'b01;
  localparam CTRL_ASYNC_FREQ = 2'b11;
  localparam CTRL_NONE       = 2'b00;

  localparam STPV2_NULL      = 4'h0;
  localparam STPV2_MERR      = 4'h2;
  localparam STPV2_FLAG      = 4'hE;
  localparam STPV2_DM4       = 4'hD;
  localparam STPV2_DM8       = 4'h8;
  localparam STPV2_DM16      = 4'h9;
  localparam STPV2_DM32      = 4'hA;
  localparam STPV2_D4        = 4'hC;
  localparam STPV2_D8        = 4'h4;
  localparam STPV2_D16       = 4'h5;
  localparam STPV2_D32       = 4'h6;

  //---------------------------------------------------------------------------
  // Wires
  //---------------------------------------------------------------------------
  wire                             sync_masked;
  wire                             sync_pending_we;
  wire                             nxt_sync_pending;
  wire                             sync_ongoing_we;
  wire                             nxt_sync_ongoing;
  wire [3:0]                       sync_ctrl_data;
  wire                             sync_tgu;
  wire                             sync_inserted;
  wire                             hp_sync_request;
  wire                             hp_sync_tgu;
  wire                             hp_sync_pending_we;
  wire                             nxt_hp_sync_pending;
  wire                             tgu_ready;
  wire                             ch_needed;
  wire                             mc_needed;
  wire [2:0]                       mc_type;
  wire                             ch_diff_msb;
  wire                             ch_nonzero_lsb;
  wire                             ch_prev_we;
  wire                             ch_reset;
  wire [15:0]                      nxt_ch_prev;
  wire                             payload_nonzero_64;
  wire                             payload_nonzero_32;
  wire                             payload_nonzero_16;
  wire                             payload_nonzero_8;
  wire                             data_comp_enabled;
  wire [(STM_DATA_WIDTH/32):0]     payload_size;
  wire [STM_DATA_WIDTH-1:0]        tgu_payload;
  wire                             timestamped;
  wire [3:0]                       stpv2_opcode;
  wire                             extended_opcode;
  wire [3:0]                       packet_ctrl_data;
  wire                             mast_changed;
  wire                             mast_reset;
  wire [7:0]                       nxt_mast_prev;
  wire                             mast_prev_we;
  wire                             packet_inserted;
  wire                             extts_needed;
  wire [1:0]                       tgu_ts_req;
  wire [6:0]                       ts_size_ctrl;
  wire [3:0]                       ts_size;
  wire [3:2]                       exttsp_size;
  wire                             nxt_ts_full;
  wire                             ts_prev_we;
  wire [6:1]                       ts_diff;
  wire [47:0]                      extts_value;
  wire [((STM_DATA_WIDTH/32)+2):0] dp_size;
  wire                             no_payload;
  wire                             atb_fvalid;
  wire                             flush_from_atb;
  wire                             nxt_tgu_fvalid;
  wire                             tgu_fvalid_we;
  wire                             flush_tgu;
  wire                             flush_inserted;
  wire                             flush_marker;
  wire                             flush_pending_we;
  wire                             nxt_flush_pending;
  wire [3:0]                       flush_ctrl_data;

  //Packet data comprises Data [32 or 64 bits] plus 20 bits of TS/TS Size
  wire [(STM_DATA_WIDTH+20)-1:0]   packet_data_mux1;
  wire [(STM_DATA_WIDTH+20)-1:0]   packet_data_mux2;
  wire [(STM_DATA_WIDTH+20)-1:0]   packet_data_mux3;
  wire [(STM_DATA_WIDTH+20)-1:0]   packet_data_mux4;
  wire [(STM_DATA_WIDTH+20)-1:0]   packet_data;

  //---------------------------------------------------------------------------
  // Registers
  //---------------------------------------------------------------------------
  reg         sync_pending_reg;
  reg         sync_ongoing_reg;
  reg         hp_sync_pending_reg;
  reg [15:0]  ch_prev_reg;
  reg [7:0]   mast_prev_reg;
  reg [63:4]  ts_prev_reg;
  reg         ts_full_reg;
  reg         flush_pending_reg;
  reg         tgu_fvalid_reg;
  reg         atb_fvalid_reg;
  reg [63:0]  timestamp;

  reg  [(STM_DATA_WIDTH/32):0] comp_data_size;


  //---------------------------------------------------------------------------
  //
  // Main body of code
  // =================
  //
  //---------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  // Synchronization request handling
  //---------------------------------------------------------------------------
  // New sync from TGU input (either external or internal) is masked if
  // there is another sync in the FIFO already. This is to prevent excessive ATB
  // bandwidth due to back to back syncs

  assign sync_masked = syncreq_i & ~sync_ongoing_reg;

  // Sync request is kept pending until it is accepted by control FIFO
  //   - set when sync request is active but not sync is not inserted
  //     into FIFO as priority is given to TGU data interface or FIFO
  //     is full
  //   - cleared when sync is inserted in FIFO

  assign sync_pending_we  = sync_masked |  sync_inserted;
  assign nxt_sync_pending = sync_masked & ~sync_inserted;

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      sync_pending_reg <= 1'b0;
    else if(sync_pending_we)
      sync_pending_reg <= nxt_sync_pending;
  end

  // High priority sync request
  // A high priority sync request is generated if
  // - Priority Escalation is enabled
  // - There is a sync request while an existing request is pending
  // OR
  // - The sync request is due to STM enable

  assign hp_sync_request = (sync_masked & sync_pending_reg & tgu_cfg_asyncpe_i) | (stm_enable_syncreq_i & ~sync_ongoing_reg);

  // High priority sync request is kept pending until it is
  // accepted by the control FIFO. High priority requests take
  // priority over the TGU data interface.
  //   - set when high priority sync request is active but control fifo is not ready
  //   - cleared when sync is inserted in FIFO

  assign hp_sync_pending_we  = (hp_sync_request & ~ctrl_in_ready_i) | sync_inserted;
  assign nxt_hp_sync_pending = (hp_sync_request & ~ctrl_in_ready_i);

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      hp_sync_pending_reg <= 1'b0;
    else if(hp_sync_pending_we)
      hp_sync_pending_reg <= nxt_hp_sync_pending;
  end

  // Sync request in TGU has 2 sources:
  //   - sync from combined internal and external request (sync_masked)
  //   - pending sync (sync_pending_reg)
  assign sync_tgu = sync_masked | sync_pending_reg;

  // High priority sync request has 2 sources:
  //   - hp sync request
  //   - pending hp sync request
  assign hp_sync_tgu = hp_sync_request | hp_sync_pending_reg;

  // Sync is inserted in FIFO when:
  // - sync request is active
  // - fifo is ready
  // - tgu data i/f is not busy
  // or
  // - high priority sync is pending
  // - fifo is ready
  // and
  // - the TGU is enabled
  // - non invasive debug is enabled
  assign sync_inserted = ((sync_tgu & ~tgu_valid_i & ctrl_in_ready_i) |
                          (hp_sync_tgu & ctrl_in_ready_i));

  // Sync request is marked as ongoing until sync sequence is output
  assign sync_ongoing_we  = sync_inserted |  asyncout_i;
  assign nxt_sync_ongoing = sync_inserted;

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      sync_ongoing_reg <= 1'b0;
    else if(sync_ongoing_we)
      sync_ongoing_reg <= nxt_sync_ongoing;
  end

  // Word written to ctrl fifo on sync insertion
  // ASYNC sequence includes FREQ packet if timestamps are enabled
  assign sync_ctrl_data[3:0] = {flush_marker,                                  // 3   - flush marker
                                tgu_cfg_tsen_i ? CTRL_ASYNC_FREQ : CTRL_ASYNC, // 2:1 - ASYNC sequence
                                CTRL_FIFO_ONLY                                 // 0   - information is in CTRL FIFO only
                               };

  //---------------------------------------------------------------------------
  // Flush handling
  //---------------------------------------------------------------------------

  // Flush from ATB interface
  assign atb_fvalid = AFVALIDM & ~afreadym_i & tgu_cfg_enable_i & ~q_stopped_i;
  // Delayed version for AFVALID edge detection
  // Gated with tgu_cfg_enable_i to allow AFVALID detection if it was
  // asserted before TGU was enabled
  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      atb_fvalid_reg <= 1'b0;
    else
      atb_fvalid_reg <= atb_fvalid;
  end

  assign flush_from_atb = atb_fvalid & ~atb_fvalid_reg;

  // Flush is propagated to TGU data i/f
  assign nxt_tgu_fvalid = flush_from_atb;
  assign tgu_fvalid_we  = flush_from_atb |  tgu_fready_i;
  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      tgu_fvalid_reg <= 1'b0;
    else if (tgu_fvalid_we)
      tgu_fvalid_reg <= nxt_tgu_fvalid;
  end

  // TGU is flushed after flush of TGU data interface is completed
  assign flush_tgu = tgu_fready_i & tgu_fvalid_reg;

  // Flush will pend if marker cannot be inserted into FIFO due to FIFO full
  //   - set when flush is active but not taken
  //   - cleared when flush is inserted in FIFO
  assign flush_pending_we  = flush_tgu  |   sync_inserted | packet_inserted | flush_inserted;
  assign nxt_flush_pending = flush_tgu  & ~(sync_inserted | packet_inserted | flush_inserted);

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      flush_pending_reg <= 1'b0;
    else if(flush_pending_we)
      flush_pending_reg <= nxt_flush_pending;
  end

  assign flush_marker = flush_tgu | flush_pending_reg;
  // Flush control word is inserted in FIFO when:
  // - flush is requested
  // - there is nothing else to write into control fifo
  assign flush_inserted = flush_marker & ~tgu_valid_i & ~sync_inserted & ctrl_in_ready_i;

  // Word written to ctrl fifo on single flush insertion
  assign flush_ctrl_data[3:0] = {flush_marker,      // 3   - flush marker
                                 CTRL_NONE,         // 2:1
                                 CTRL_FIFO_ONLY     // 0   - information is in CTRL FIFO only
                                };

  //---------------------------------------------------------------------------
  // TGU interface handshake
  //---------------------------------------------------------------------------
  // TGU ready is only generated in response to valid_i as transaction has to be decoded before ready is generated.
  // TGU data interface can be stalled in case of:
  //   - control fifo not ready
  //   - other fifo's needed but not ready
  //   - sync priority escalation and tgu is enabled
  //   - STM is in Q_STOPPED
  //   - STM is disabled
  assign tgu_ready =  tgu_valid_i &
                      ctrl_in_ready_i &
                      (~mc_needed | mc_needed & ch_in_ready_i) &
                      ((tgu_ts_req[1:0]!=2'b11) | ((tgu_ts_req[1:0]==2'b11) & (~extts_needed | extts_needed & extts_in_ready_i))) &
                      ~(hp_sync_tgu) &
                      ~(q_stop_i);

  // -----------------------------------------------------------------------------
  // Master change detection
  // -----------------------------------------------------------------------------

  // Diff previous and current master numbers on an incoming transfer
  assign mast_changed = (tgu_master_i[7:0] != mast_prev_reg[7:0]);

  // Master is reset after synchronization and error packet (GERR)
  assign mast_reset = sync_inserted | (tgu_packet_type_i[2:0] == 3'b111);

  // Reset the master number or capture the current value
  assign nxt_mast_prev[7:0] = mast_reset ? {8{1'b0}} : tgu_master_i[7:0];

  // Enable the register when the master number changes or on master reset condition (sync or GERR)
  // TRIG is global, don't update on TRIG packet
  assign mast_prev_we = (tgu_ready &
                         ((mast_changed & (tgu_packet_type_i[2:0] != 3'b101)) |
                          (tgu_packet_type_i[2:0] == 3'b111)))
                        | sync_inserted;

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      mast_prev_reg[7:0] <= {8{1'b0}};
    else if (mast_prev_we)
      mast_prev_reg[7:0] <= nxt_mast_prev[7:0];
  end

  // -----------------------------------------------------------------------------
  // Channel change detection
  // -----------------------------------------------------------------------------

  // Diff previous and current channel numbers on an incoming transfer
  // If master number is changed do a diff with 0
  assign ch_needed = (~mast_changed & (tgu_channel_i[15:0] != ch_prev_reg[15:0])) | (mast_changed & (tgu_channel_i[15:0] != {16{1'b0}}));

  // Channel is reset after synchronization and error packets (both MERR and GERR)
  assign ch_reset = sync_inserted | (tgu_packet_type_i[2:0] == 3'b110) | (tgu_packet_type_i[2:0] == 3'b111);

  // Reset the channel number or capture the current value
  assign nxt_ch_prev[15:0] = ch_reset ? {16{1'b0}} : tgu_channel_i[15:0];

  // Enable the register when the channel number changes
  // - channel or master is changed for packets other then TRIG
  // - MERR
  // - GERR
  // or after synchronisation
  // TRIG is global, don't update on TRIG packet
  assign ch_prev_we = (tgu_ready &
                       (((ch_needed | mast_changed) & (tgu_packet_type_i[2:0] != 3'b101)) |
                        (tgu_packet_type_i[2:0] == 3'b110)                                |
                        (tgu_packet_type_i[2:0] == 3'b111)))
                      | sync_inserted;

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      ch_prev_reg[15:0] <= {16{1'b0}};
    else if (ch_prev_we)
      ch_prev_reg[15:0] <= nxt_ch_prev[15:0];
  end

  // Master or Channel packet is needed if
  // - master has changed
  // - channel has changed
  // and packet type is not TRIG ie TRIG is global it doesn't reference master/channel
  assign mc_needed  = (mast_changed | ch_needed) & (tgu_packet_type_i[2:0] != 3'b101);

  // Top 8 bits of channel are output only if they differ from previous channel
  // In case when M8 packet is output, M8 packet resets current channel to 0, so channel is compared to 8'h00 in that case
  assign ch_diff_msb   = mast_changed ? (tgu_channel_i[15:8] != 8'h00) : (tgu_channel_i[15:8] != ch_prev_reg[15:8]);

  // Bottom 8 bits of channel are compared to 0 to check if C8 should be output after M8
  assign ch_nonzero_lsb = (tgu_channel_i[7:0] != 8'h00);

  // MC type encoding
  // 010 - C8
  // 100 - C16
  // 001 - M8
  // 011 - M8 C8
  // 101 - M8 C16
  assign mc_type[2] = ch_diff_msb;
  assign mc_type[1] = mast_changed ? ch_nonzero_lsb & ~ch_diff_msb : ~ch_diff_msb;
  assign mc_type[0] = mast_changed;

  // -----------------------------------------------------------------------------
  // Timestamp value generation
  // -----------------------------------------------------------------------------

  // Ignore optional timestamp request for MERR/GERR
  // MERR/GERR may have optional timestamp request attached due to
  // "force timestamp" feature that will keep optional timestamp request for
  // all AXI TGU transations until transaction is timestamped
  assign tgu_ts_req[1:0] = {                                                 tgu_ts_req_i[1],
                            ~(tgu_packet_type_i[2] & tgu_packet_type_i[1]) & tgu_ts_req_i[0]};

  // Cause a full timestamp packet to be sent after synchronisation
  // Cleared on a write to the timestamp FIFO
  assign nxt_ts_full =  sync_inserted |
                      (~sync_inserted & ~(tgu_ready & timestamped) & ts_full_reg);

  // Reset value is 1 - first timestamp is always full timestamp.
  // Reset value of 1 keeps extts_needed and thus tgu_ready at defined value after STMRESETn
  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      ts_full_reg <= 1'b1;
    else
      ts_full_reg <= nxt_ts_full;
  end

  // Capture the current timestamp value when a new packet is written to the FIFOs
  // and will have an associated timestamp
  assign ts_prev_we = timestamped & tgu_ready;
  always @(posedge clk_gated)
  begin
    if (ts_prev_we)
      ts_prev_reg[63:4] <= tsvalue_i[63:4];
  end

  // Mark the range of nibbles that have changed, nibble 0 will always change
  assign ts_diff[6] =  ((tsvalue_i[63:48] != ts_prev_reg[63:48]) | ts_full_reg);
  assign ts_diff[5] =    tsvalue_i[47:32] != ts_prev_reg[47:32]  | ts_full_reg;
  assign ts_diff[4] =    tsvalue_i[31:16] != ts_prev_reg[31:16];
  assign ts_diff[3] =    tsvalue_i[15:12] != ts_prev_reg[15:12];
  assign ts_diff[2] =    tsvalue_i[11:8]  != ts_prev_reg[11:8];
  assign ts_diff[1] =    tsvalue_i[7:4]   != ts_prev_reg[7:4];

  // Calculate the number of nibbles to be sent, set to all nibbles after a
  // synchronisation packet
  assign ts_size_ctrl[6:0] = {timestamped &  ts_diff[6],
                              timestamped & ~ts_diff[6] &  ts_diff[5],
                              timestamped & ~ts_diff[6] & ~ts_diff[5] &  ts_diff[4],
                              timestamped & ~ts_diff[6] & ~ts_diff[5] & ~ts_diff[4] &  ts_diff[3],
                              timestamped & ~ts_diff[6] & ~ts_diff[5] & ~ts_diff[4] & ~ts_diff[3] &  ts_diff[2],
                              timestamped & ~ts_diff[6] & ~ts_diff[5] & ~ts_diff[4] & ~ts_diff[3] & ~ts_diff[2] &  ts_diff[1],
                              timestamped & ~ts_diff[6] & ~ts_diff[5] & ~ts_diff[4] & ~ts_diff[3] & ~ts_diff[2] & ~ts_diff[1]};

  // When not timestamped, ts_size[3:0] is 4'h0
  assign ts_size[3:0] = {4{ts_size_ctrl[6]}} & 4'hE |
                        {4{ts_size_ctrl[5]}} & 4'hC |
                        {4{ts_size_ctrl[4]}} & 4'h8 |
                        {4{ts_size_ctrl[3]}} & 4'h4 |
                        {4{ts_size_ctrl[2]}} & 4'h3 |
                        {4{ts_size_ctrl[1]}} & 4'h2 |
                        {4{ts_size_ctrl[0]}} & 4'h1;

  // Shift and align timestamp value for storing into FIFO
  always @*
  begin
    case (ts_size[3:0])
      4'h1 : // 4-bit
        timestamp[63:0] = {{60{1'b0}},
                           tsvalue_i[3:0]
                          };
      4'h2 : // 8-bit
        timestamp[63:0] = {{56{1'b0}},
                           tsvalue_i[3:0],
                           tsvalue_i[7:4]
                          };
      4'h3 : // 12-bit
        timestamp[63:0] = {{52{1'b0}},
                           tsvalue_i[3:0],
                           tsvalue_i[7:4],
                           tsvalue_i[11:8]
                          };
      4'h4 : // 16-bit
        timestamp[63:0] = {{48{1'b0}},
                           tsvalue_i[3:0],
                           tsvalue_i[7:4],
                           tsvalue_i[11:8],
                           tsvalue_i[15:12]
                          };
      4'h8 : // 32-bit
        timestamp[63:0] = {{32{1'b0}},
                           tsvalue_i[3:0],
                           tsvalue_i[7:4],
                           tsvalue_i[11:8],
                           tsvalue_i[15:12],
                           tsvalue_i[19:16],
                           tsvalue_i[23:20],
                           tsvalue_i[27:24],
                           tsvalue_i[31:28]
                          };
      4'hC : // 48-bit
        timestamp[63:0] = {{16{1'b0}},
                           tsvalue_i[3:0],
                           tsvalue_i[7:4],
                           tsvalue_i[11:8],
                           tsvalue_i[15:12],
                           tsvalue_i[19:16],
                           tsvalue_i[23:20],
                           tsvalue_i[27:24],
                           tsvalue_i[31:28],
                           tsvalue_i[35:32],
                           tsvalue_i[39:36],
                           tsvalue_i[43:40],
                           tsvalue_i[47:44]
                          };
      4'hE : // 64-bit
        timestamp[63:0] = {tsvalue_i[3:0],
                           tsvalue_i[7:4],
                           tsvalue_i[11:8],
                           tsvalue_i[15:12],
                           tsvalue_i[19:16],
                           tsvalue_i[23:20],
                           tsvalue_i[27:24],
                           tsvalue_i[31:28],
                           tsvalue_i[35:32],
                           tsvalue_i[39:36],
                           tsvalue_i[43:40],
                           tsvalue_i[47:44],
                           tsvalue_i[51:48],
                           tsvalue_i[55:52],
                           tsvalue_i[59:56],
                           tsvalue_i[63:60]
                          };
      4'h0,
      4'h5,
      4'h6,
      4'h7,
      4'h9,
      4'hA,
      4'hB,
      4'hD,
      4'hF :
        timestamp[63:0] = {64{1'b0}};
      // unreachable, X propagation only
      // VCS coverage off
      default: timestamp[63:0] = {64{1'bX}};
      // VCS coverage on
    endcase
  end

  generate
    if (STM_DATA_WIDTH == 64)
      // Extended timestamp FIFO is needed in case of:
      // - 64-bit data and timestamp larger than 16 bits
      // - 4, 8, 16, 32-bit data and timestamp larger than 32 bits
      assign extts_needed = ((payload_size[2:0] == 3'b100) ? (|ts_diff[6:4]) : (|ts_diff[6:5]) | ts_full_reg);
  endgenerate

  assign timestamped = |tgu_ts_req[1:0] & (extts_in_ready_i | ~extts_needed);

  // -----------------------------------------------------------------------------
  // Data compression
  // -----------------------------------------------------------------------------
  // When compression is enabled, remove leading zeros from the data value if it
  // allows the packet size to be reduced
  // The original size must be checked, as <32-bit data values may have non-zero
  // bits in sections that aren't used

  // Indicate which parts of the payload contain non-zero data
  generate
    if (STM_DATA_WIDTH == 64)
      assign payload_nonzero_64 = |tgu_payload_i[63:32];
  endgenerate

  assign payload_nonzero_32 = |tgu_payload_i[31:16];
  assign payload_nonzero_16 = |tgu_payload_i[15:8];
  assign payload_nonzero_8  = |tgu_payload_i[7:4];

  // Compression enable is per master
  assign data_comp_enabled = tgu_master_i[7] ? tgu_cfg_hwcompen_i : tgu_cfg_spcompen_i;

  // When compression is enabled, reduce the size of 8/16/32/64-bit data packets.
  // 4-bit data packets cannot be made any smaller, so are unmodified.
  generate
    //64 Bit Datapath
    if (STM_DATA_WIDTH == 64) begin : gen_comp_size_64
      always @*
      begin
        case (tgu_size_i[(STM_DATA_WIDTH/32):0])
          3'b000 : // 4-bit
            comp_data_size[2:0] = tgu_size_i[2:0];
          3'b001 : // 8-bit
            comp_data_size[2:0] = {2'b00, payload_nonzero_8};
          3'b010 : // 16-bit
            begin
              comp_data_size[2] = 1'b0;
              comp_data_size[1] =  payload_nonzero_16;
              comp_data_size[0] = ~payload_nonzero_16 & payload_nonzero_8;
            end
          3'b011 : // 32-bit
            begin
              comp_data_size[2] = 1'b0;
              comp_data_size[1] = payload_nonzero_32 |   payload_nonzero_16;
              comp_data_size[0] = payload_nonzero_32 | (~payload_nonzero_16 & payload_nonzero_8);
            end
          3'b100 : // 64-bit
            begin
              comp_data_size[2] =  payload_nonzero_64;
              comp_data_size[1] = ~payload_nonzero_64 & (payload_nonzero_32 |   payload_nonzero_16);
              comp_data_size[0] = ~payload_nonzero_64 & (payload_nonzero_32 | (~payload_nonzero_16 & payload_nonzero_8));
            end
          // unreachable, X propagation only
          // VCS coverage off
          default: comp_data_size[2:0] = 3'bxxx;
          // VCS coverage on
        endcase
      end
    end
  endgenerate

  // Payload size decode
  // - MERR and GERR payload is 0x00
  // - TRIG - 2nd and 3rd nibble of TRIG STPv2 opcode are treated as payload, so TRIG payload is 8+8=16 bits
  // - for data packets payload is
  //    - taken from TGU i/f or
  //    - from compression logic
  generate
    if (STM_DATA_WIDTH == 64)
      assign payload_size[2:0]  = ({3{ tgu_packet_type_i[2] &  tgu_packet_type_i[1]}} & 3'b001)               | // MERR/GERR
                                  ({3{ tgu_packet_type_i[2] & ~tgu_packet_type_i[1]}} & 3'b010)               | // TRIG
                                  ({3{~tgu_packet_type_i[2] &  data_comp_enabled}}    & comp_data_size[2:0]) | // DATA with compression
                                  ({3{~tgu_packet_type_i[2] & ~data_comp_enabled}}    & tgu_size_i[2:0]);      // DATA without compression


  endgenerate

  // No payload for FLAG
  assign no_payload = tgu_packet_type_i[2:0]==3'b100;

  // Mux for packet data (goes into data FIFO)
  // Packet payload is shifted and aligned according to data_size
  // If packet is timestamped, timestamp size and lower bits of timestamp are added
  // - up to 16 bits in case of D(M)32TS
  // - up to 32 bits in all other cases

  generate
    if (STM_DATA_WIDTH == 64)
      assign tgu_payload[63:32] = tgu_payload_i[63:32];
  endgenerate

  assign tgu_payload[31:16] = tgu_payload_i[31:16];

  assign tgu_payload[15:0]  = ({16{ tgu_packet_type_i[2] &  tgu_packet_type_i[1]}} & {16{1'b0}})                                | // MERR/GERR
                              ({16{ tgu_packet_type_i[2] & ~tgu_packet_type_i[1]}} & {4'b0000, 3'b011, timestamped, {8{1'b0}}}) | // TRIG
                              ({16{~tgu_packet_type_i[2]}}                         & tgu_payload_i[15:0]);                        // DATA

  //Select 4 or 8 bit packet based on payload_size[0]
  assign packet_data_mux1[83:0] = payload_size[0]
                                ? {{40{1'b0}},
                                   timestamp[31:0],
                                   ts_size[3:0],
                                   tgu_payload[3:0],
                                   tgu_payload[7:4]
                                  }
                                : {{44{1'b0}},
                                   timestamp[31:0],
                                   ts_size[3:0],
                                   tgu_payload[3:0]
                                  };

  //Select 16 or 32 bit packet based on payload_size[0]
  assign packet_data_mux2[83:0] = payload_size[0]
                                ? {{16{1'b0}},
                                   timestamp[31:0],
                                   ts_size[3:0],
                                   tgu_payload[3:0],
                                   tgu_payload[7:4],
                                   tgu_payload[11:8],
                                   tgu_payload[15:12],
                                   tgu_payload[19:16],
                                   tgu_payload[23:20],
                                   tgu_payload[27:24],
                                   tgu_payload[31:28]
                                  }
                                : {{32{1'b0}},
                                   timestamp[31:0],
                                   ts_size[3:0],
                                   tgu_payload[3:0],
                                   tgu_payload[7:4],
                                   tgu_payload[11:8],
                                   tgu_payload[15:12]
                                  };

  //Select 4, 8, 16 or 32 bit packet based on payload_size[1]
  assign packet_data_mux3[83:0] = payload_size[1]
                                ? packet_data_mux2[83:0]
                                : packet_data_mux1[83:0];

  //Select 64 bit or (4/8/16/32) bit packet based on payload_size[2]
  assign packet_data_mux4[83:0] = payload_size[2]
                                ? {timestamp[15:0],
                                   ts_size[3:0],
                                   tgu_payload[3:0],
                                   tgu_payload[7:4],
                                   tgu_payload[11:8],
                                   tgu_payload[15:12],
                                   tgu_payload[19:16],
                                   tgu_payload[23:20],
                                   tgu_payload[27:24],
                                   tgu_payload[31:28],
                                   tgu_payload[35:32],
                                   tgu_payload[39:36],
                                   tgu_payload[43:40],
                                   tgu_payload[47:44],
                                   tgu_payload[51:48],
                                   tgu_payload[55:52],
                                   tgu_payload[59:56],
                                   tgu_payload[63:60]
                                  }
                                : packet_data_mux3[83:0];

  assign packet_data[83:0]      = no_payload
                                ? {{48{1'b0}},
                                   timestamp[31:0],
                                   ts_size[3:0]
                                  }
                                : packet_data_mux4[83:0];

  // Extended timestamp FIFO takes upper bits of timestamp:
  // - 48 bits in case of D(M)32TS (32-bit Data Path) or D(M)64TS (64-bit Data Path)
  // - 32 bits in all other cases
  // Lower timestamp bits are stored into data FIFO:
  // - up to 16 bits in case of D(M)32TS (32-bit Data Path) or D(M)64TS (64-bit Data Path)
  // - up to 32 bits in all other cases
  generate
    if (STM_DATA_WIDTH == 64)
      assign extts_value[47:0] = (payload_size[2:0] == 3'b100) ? timestamp[63:16] : {{16{1'b0}}, timestamp[63:32]};

  endgenerate

  generate
    if (STM_DATA_WIDTH == 64) begin : gen_dp_size_64

  // -----------------------------------------------------------------------------
  // Packet opcode decode
  // -----------------------------------------------------------------------------
  // PLA table sent to espresso
  // .i 13
  // .o 12
  // .ilb tgu_packet_type_i[2] tgu_packet_type_i[1] tgu_packet_type_i[0] payload_size[2] payload_size[1] payload_size[0] timestamped ts_diff[6] ts_diff[5] ts_diff[4] ts_diff[3] ts_diff[2] ts_diff[1]
  // .ob extended_opcode stpv2_opcode[3] stpv2_opcode[2] stpv2_opcode[1] stpv2_opcode[0] dp_size[4] dp_size[3] dp_size[2] dp_size[1] dp_size[0] exttsp_size[3] exttsp_size[2]
  // #
  // #Inputs:
  // # tgu_packet_type[2:0]
  // # |   payload_size[1:0]
  // # |   |   timestamped
  // # |   |   | ts_diff[6:1]
  // # |   |   | |
  // # |   |   | |          Outputs:
  // # |   |   | |           extended_opcode
  // # |   |   | |           | stpv2_opcode[3:0]
  // # |   |   | |           | |    dp_size[4:0] - data packet size in nibbles in data fifo:
  // # |   |   | |           | |    |  - STPv2 opcode 1 or 2 nibbles
  // # |   |   | |           | |    |  - packet payload 0, 1, 2, 4, 8 or 16 nibbles
  // # |   |   | |           | |    |  - timestamp size (if present) 1 nibble
  // # |   |   | |           | |    |  - lower timestamp bits (if present) 1, 2, 3, 4 (D32 and other) or 8 (no D64)
  // # |   |   | |           | |    |     exttsp_size[3:2] - size of timestamp data in extended timestamp fifo
  // # |   |   | |           | |    |     |  - bits[1:0] are always 00
  // # DM4                   | |    |     |
  //   000 000 0 ------      1 1101 00011 --
  // # DM8
  //   000 001 0 ------      1 1000 00100 --
  // # DM16
  //   000 010 0 ------      1 1001 00110 --
  // # DM32
  //   000 011 0 ------      1 1010 01010 --
  // # DM64
  //   000 100 0 ------      1 1011 10010 --
  // # USER(_TS) - invalid case, assertion present
  //   001 --- - ------      - ---- ----- --
  // # D4
  //   010 000 0 ------      0 1100 00010 --
  // # D8
  //   010 001 0 ------      0 0100 00011 --
  // # D16
  //   010 010 0 ------      0 0101 00101 --
  // # D32
  //   010 011 0 ------      0 0110 01001 --
  // # D64
  //   010 100 0 ------      0 0111 10001 --
  // # TIME(_TS) - invalid case, assertion present
  //   011 --- - ------      - ---- ----- --
  // # FLAG
  //   100 00- 0 ------      - ---- ----- --
  //   100 010 0 ------      1 1110 00010 --
  //   100 011 0 ------      - ---- ----- --
  // # TRIG
  //   101 00- 0 ------      - ---- ----- --
  //   101 010 0 ------      0 1111 00101 --
  //   101 011 0 ------      - ---- ----- --
  // # MERR
  //   110 000 0 ------      - ---- ----- --
  //   110 001 0 ------      0 0010 00011 --
  //   110 01- 0 ------      - ---- ----- --
  // # GERR
  //   111 000 0 ------      - ---- ----- --
  //   111 001 0 ------      1 0010 00100 --
  //   111 01- 0 ------      - ---- ----- --
  // # DM4TS
  //   000 000 1 1-----      0 1101 01011 10
  //   000 000 1 01----      0 1101 01011 01
  //   000 000 1 001---      0 1101 01011 --
  //   000 000 1 0001--      0 1101 00111 --
  //   000 000 1 00001-      0 1101 00110 --
  //   000 000 1 000001      0 1101 00101 --
  //   000 000 1 000000      0 1101 00100 --
  // # DM8TS
  //   000 001 1 1-----      0 1000 01100 10
  //   000 001 1 01----      0 1000 01100 01
  //   000 001 1 001---      0 1000 01100 --
  //   000 001 1 0001--      0 1000 01000 --
  //   000 001 1 00001-      0 1000 00111 --
  //   000 001 1 000001      0 1000 00110 --
  //   000 001 1 000000      0 1000 00101 --
  // # DM16TS
  //   000 010 1 1-----      0 1001 01110 10
  //   000 010 1 01----      0 1001 01110 01
  //   000 010 1 001---      0 1001 01110 --
  //   000 010 1 0001--      0 1001 01010 --
  //   000 010 1 00001-      0 1001 01001 --
  //   000 010 1 000001      0 1001 01000 --
  //   000 010 1 000000      0 1001 00111 --
  // # DM32TS
  //   000 011 1 1-----      0 1010 10010 10
  //   000 011 1 01----      0 1010 10010 01
  //   000 011 1 001---      0 1010 10010 --
  //   000 011 1 0001--      0 1010 01110 --
  //   000 011 1 00001-      0 1010 01101 --
  //   000 011 1 000001      0 1010 01100 --
  //   000 011 1 000000      0 1010 01011 --
  // # DM64TS
  //   000 100 1 1-----      0 1011 10110 11
  //   000 100 1 01----      0 1011 10110 10
  //   000 100 1 001---      0 1011 10110 01
  //   000 100 1 0001--      0 1011 10110 --
  //   000 100 1 00001-      0 1011 10101 --
  //   000 100 1 000001      0 1011 10100 --
  //   000 100 1 000000      0 1011 10011 --
  // # D4TS
  //   010 000 1 1-----      1 1100 01100 10
  //   010 000 1 01----      1 1100 01100 01
  //   010 000 1 001---      1 1100 01100 --
  //   010 000 1 0001--      1 1100 01000 --
  //   010 000 1 00001-      1 1100 00111 --
  //   010 000 1 000001      1 1100 00110 --
  //   010 000 1 000000      1 1100 00101 --
  // # D8TS
  //   010 001 1 1-----      1 0100 01101 10
  //   010 001 1 01----      1 0100 01101 01
  //   010 001 1 001---      1 0100 01101 --
  //   010 001 1 0001--      1 0100 01001 --
  //   010 001 1 00001-      1 0100 01000 --
  //   010 001 1 000001      1 0100 00111 --
  //   010 001 1 000000      1 0100 00110 --
  // # D16TS
  //   010 010 1 1-----      1 0101 01111 10
  //   010 010 1 01----      1 0101 01111 01
  //   010 010 1 001---      1 0101 01111 --
  //   010 010 1 0001--      1 0101 01011 --
  //   010 010 1 00001-      1 0101 01010 --
  //   010 010 1 000001      1 0101 01001 --
  //   010 010 1 000000      1 0101 01000 --
  // # D32TS
  //   010 011 1 1-----      1 0110 10011 10
  //   010 011 1 01----      1 0110 10011 01
  //   010 011 1 001---      1 0110 10011 --
  //   010 011 1 0001--      1 0110 01111 --
  //   010 011 1 00001-      1 0110 01110 --
  //   010 011 1 000001      1 0110 01101 --
  //   010 011 1 000000      1 0110 01100 --
  // # D64TS
  //   010 100 1 1-----      1 0111 10111 11
  //   010 100 1 01----      1 0111 10111 10
  //   010 100 1 001---      1 0111 10111 01
  //   010 100 1 0001--      1 0111 10111 --
  //   010 100 1 00001-      1 0111 10110 --
  //   010 100 1 000001      1 0111 10101 --
  //   010 100 1 000000      1 0111 10100 --
  // # FLAG_TS
  //   100 00- 1 ------      - ---- ----- --
  //   100 010 1 1-----      0 1110 01010 10
  //   100 010 1 01----      0 1110 01010 01
  //   100 010 1 001---      0 1110 01010 --
  //   100 010 1 0001--      0 1110 00110 --
  //   100 010 1 00001-      0 1110 00101 --
  //   100 010 1 000001      0 1110 00100 --
  //   100 010 1 000000      0 1110 00011 --
  //   100 011 1 ------      - ---- ----- --
  // # TRIG_TS
  //   101 00- 1 ------      - ---- ----- --
  //   101 010 1 1-----      0 1111 01110 10
  //   101 010 1 01----      0 1111 01110 01
  //   101 010 1 001---      0 1111 01110 --
  //   101 010 1 0001--      0 1111 01010 --
  //   101 010 1 00001-      0 1111 01001 --
  //   101 010 1 000001      0 1111 01000 --
  //   101 010 1 000000      0 1111 00111 --
  //   101 011 1 ------      - ---- ----- --
  // # MERR - invalid case, assertion present
  //   110 --- 1 ------      - ---- ----- --
  // # GERR - invalid case, assertion present
  //   111 --- 1 ------      - ---- ----- --
  // # Illegal payload size, assertion present
  //   --- 101 - ------      - ---- ----- --
  //   --- 110 - ------      - ---- ----- --
  //   --- 111 - ------      - ---- ----- --
  // .e
  // espresso output
  // DO NOT MODIFY BY HAND
  assign extended_opcode = (!tgu_packet_type_i[1]&!tgu_packet_type_i[0]
    &payload_size[1]&!timestamped) | (tgu_packet_type_i[0]
    &payload_size[0]) | (tgu_packet_type_i[1]&timestamped) | (
    !tgu_packet_type_i[2]&!tgu_packet_type_i[1]&!timestamped);

  assign stpv2_opcode[3] = (!tgu_packet_type_i[1]&payload_size[1]) | (
    !payload_size[2]&!payload_size[1]&!payload_size[0]) | (
    !tgu_packet_type_i[2]&!tgu_packet_type_i[1]);

  assign stpv2_opcode[2] = (tgu_packet_type_i[2]&payload_size[1]) | (
    !tgu_packet_type_i[2]&tgu_packet_type_i[1]) | (!payload_size[2]
    &!payload_size[1]&!payload_size[0]);

  assign stpv2_opcode[1] = (tgu_packet_type_i[2]&!payload_size[2]) | (
    !tgu_packet_type_i[2]&payload_size[2]) | (payload_size[1]
    &payload_size[0]);

  assign stpv2_opcode[0] = (tgu_packet_type_i[0]&payload_size[1]) | (
    !tgu_packet_type_i[2]&!tgu_packet_type_i[1]&!payload_size[0]) | (
    !tgu_packet_type_i[2]&payload_size[1]&!payload_size[0]) | (
    !tgu_packet_type_i[2]&payload_size[2]);

  assign dp_size[4] = (!tgu_packet_type_i[2]&payload_size[2]) | (payload_size[1]
    &payload_size[0]&timestamped&ts_diff[4]) | (payload_size[1]
    &payload_size[0]&timestamped&ts_diff[5]) | (payload_size[1]
    &payload_size[0]&timestamped&ts_diff[6]);

  assign dp_size[3] = (tgu_packet_type_i[0]&payload_size[1]&timestamped&ts_diff[3]) | (
    tgu_packet_type_i[0]&payload_size[1]&timestamped&ts_diff[2]) | (
    tgu_packet_type_i[1]&payload_size[1]&!payload_size[0]&timestamped) | (
    tgu_packet_type_i[1]&!payload_size[1]&payload_size[0]&timestamped
    &ts_diff[2]) | (tgu_packet_type_i[0]&payload_size[1]&timestamped
    &ts_diff[1]) | (!tgu_packet_type_i[2]&payload_size[1]&!payload_size[0]
    &timestamped&ts_diff[3]) | (tgu_packet_type_i[1]&!payload_size[2]
    &!payload_size[0]&timestamped&ts_diff[3]) | (!payload_size[1]
    &payload_size[0]&timestamped&ts_diff[6]) | (!tgu_packet_type_i[2]
    &payload_size[1]&!payload_size[0]&timestamped&ts_diff[2]) | (
    !payload_size[1]&payload_size[0]&timestamped&ts_diff[5]) | (
    !payload_size[1]&payload_size[0]&timestamped&ts_diff[4]) | (
    !tgu_packet_type_i[2]&payload_size[1]&!payload_size[0]&timestamped
    &ts_diff[1]) | (!payload_size[1]&payload_size[0]&timestamped
    &ts_diff[3]) | (!payload_size[2]&!payload_size[0]&timestamped
    &ts_diff[6]) | (!payload_size[2]&!payload_size[0]&timestamped
    &ts_diff[5]) | (!payload_size[2]&!payload_size[0]&timestamped
    &ts_diff[4]) | (payload_size[1]&payload_size[0]&!ts_diff[6]
    &!ts_diff[5]&!ts_diff[4]) | (payload_size[1]&payload_size[0]
    &!timestamped);

  assign dp_size[2] = (tgu_packet_type_i[0]&payload_size[1]&!ts_diff[3]&!ts_diff[2]
    &!ts_diff[1]) | (tgu_packet_type_i[2]&!tgu_packet_type_i[0]
    &payload_size[1]&timestamped&!ts_diff[6]&!ts_diff[5]&!ts_diff[4]
    &ts_diff[2]) | (!tgu_packet_type_i[2]&!tgu_packet_type_i[1]
    &payload_size[1]&!payload_size[0]&!ts_diff[3]&!ts_diff[2]&!ts_diff[1]) | (
    tgu_packet_type_i[1]&payload_size[0]&timestamped&!ts_diff[6]
    &!ts_diff[5]&!ts_diff[4]&!ts_diff[3]&!ts_diff[2]) | (payload_size[1]
    &payload_size[0]&timestamped&!ts_diff[6]&!ts_diff[5]&!ts_diff[4]
    &ts_diff[2]) | (tgu_packet_type_i[2]&!tgu_packet_type_i[0]
    &payload_size[1]&timestamped&!ts_diff[6]&!ts_diff[5]&!ts_diff[4]
    &ts_diff[1]) | (tgu_packet_type_i[1]&payload_size[2]&timestamped) | (
    tgu_packet_type_i[0]&payload_size[1]&ts_diff[6]) | (payload_size[1]
    &payload_size[0]&timestamped&!ts_diff[6]&!ts_diff[5]&!ts_diff[4]
    &ts_diff[1]) | (tgu_packet_type_i[2]&!tgu_packet_type_i[0]
    &payload_size[1]&timestamped&!ts_diff[6]&!ts_diff[5]&!ts_diff[4]
    &ts_diff[3]) | (tgu_packet_type_i[0]&payload_size[1]&ts_diff[5]) | (
    !tgu_packet_type_i[2]&!payload_size[1]&timestamped&!ts_diff[6]
    &!ts_diff[5]&!ts_diff[4]&!ts_diff[3]&!ts_diff[2]&ts_diff[1]) | (
    !tgu_packet_type_i[2]&payload_size[2]&timestamped&ts_diff[2]) | (
    tgu_packet_type_i[0]&payload_size[1]&ts_diff[4]) | (
    tgu_packet_type_i[1]&!payload_size[1]&!payload_size[0]&timestamped
    &!ts_diff[3]) | (!tgu_packet_type_i[2]&!tgu_packet_type_i[1]
    &!payload_size[1]&!payload_size[0]&timestamped&!ts_diff[6]&!ts_diff[5]
    &!ts_diff[4]&ts_diff[3]) | (tgu_packet_type_i[1]&!payload_size[0]
    &timestamped&ts_diff[6]) | (tgu_packet_type_i[1]&!payload_size[0]
    &timestamped&ts_diff[5]) | (!payload_size[1]&payload_size[0]
    &timestamped&ts_diff[6]) | (!tgu_packet_type_i[1]&!payload_size[2]
    &!payload_size[1]&timestamped&!ts_diff[6]&!ts_diff[5]&!ts_diff[4]
    &!ts_diff[3]) | (tgu_packet_type_i[1]&!payload_size[0]&timestamped
    &ts_diff[4]) | (!payload_size[1]&payload_size[0]&timestamped
    &ts_diff[5]) | (!payload_size[1]&payload_size[0]&timestamped
    &ts_diff[4]) | (tgu_packet_type_i[0]&!payload_size[2]&!timestamped) | (
    payload_size[1]&payload_size[0]&timestamped&!ts_diff[6]&!ts_diff[5]
    &!ts_diff[4]&ts_diff[3]) | (!tgu_packet_type_i[2]&payload_size[2]
    &timestamped&ts_diff[4]) | (!tgu_packet_type_i[2]&payload_size[1]
    &!payload_size[0]&ts_diff[4]) | (!tgu_packet_type_i[2]
    &payload_size[2]&timestamped&ts_diff[5]) | (!tgu_packet_type_i[2]
    &payload_size[2]&timestamped&ts_diff[6]) | (!tgu_packet_type_i[2]
    &payload_size[1]&!payload_size[0]&ts_diff[5]) | (
    !tgu_packet_type_i[2]&payload_size[1]&!payload_size[0]&ts_diff[6]) | (
    !tgu_packet_type_i[1]&!payload_size[1]&payload_size[0]&!timestamped) | (
    !tgu_packet_type_i[2]&payload_size[1]&!payload_size[0]&!timestamped);

  assign dp_size[1] = (tgu_packet_type_i[1]&!payload_size[1]&payload_size[0]
    &timestamped&!ts_diff[6]&!ts_diff[5]&!ts_diff[4]&!ts_diff[3]
    &!ts_diff[2]) | (tgu_packet_type_i[1]&!payload_size[2]
    &!payload_size[1]&!payload_size[0]&!ts_diff[6]&!ts_diff[5]&!ts_diff[4]
    &!ts_diff[3]&ts_diff[1]) | (!tgu_packet_type_i[1]&payload_size[1]
    &timestamped&!ts_diff[2]&!ts_diff[1]) | (!payload_size[1]
    &payload_size[0]&timestamped&!ts_diff[6]&!ts_diff[5]&!ts_diff[4]
    &!ts_diff[3]&!ts_diff[2]&ts_diff[1]) | (tgu_packet_type_i[1]
    &!payload_size[0]&timestamped&!ts_diff[6]&!ts_diff[5]&!ts_diff[4]
    &!ts_diff[3]&ts_diff[2]) | (!tgu_packet_type_i[1]&!payload_size[2]
    &!payload_size[1]&timestamped&!ts_diff[6]&!ts_diff[5]&!ts_diff[4]
    &!ts_diff[3]&ts_diff[2]) | (!tgu_packet_type_i[2]
    &!tgu_packet_type_i[1]&!payload_size[0]&ts_diff[6]) | (
    !tgu_packet_type_i[2]&payload_size[2]&timestamped&ts_diff[6]) | (
    !tgu_packet_type_i[2]&!tgu_packet_type_i[1]&!payload_size[0]
    &ts_diff[5]) | (!tgu_packet_type_i[2]&payload_size[2]&timestamped
    &ts_diff[5]) | (!tgu_packet_type_i[2]&!tgu_packet_type_i[1]
    &!payload_size[0]&ts_diff[4]) | (!tgu_packet_type_i[2]
    &payload_size[2]&timestamped&ts_diff[4]) | (!tgu_packet_type_i[2]
    &!tgu_packet_type_i[1]&!payload_size[0]&ts_diff[3]) | (
    !tgu_packet_type_i[1]&!tgu_packet_type_i[0]&payload_size[1]
    &!timestamped) | (!tgu_packet_type_i[2]&payload_size[2]&timestamped
    &ts_diff[3]) | (tgu_packet_type_i[1]&!tgu_packet_type_i[0]
    &!payload_size[2]&!payload_size[1]&!timestamped) | (
    !tgu_packet_type_i[2]&!tgu_packet_type_i[1]&!payload_size[0]
    &!timestamped) | (!tgu_packet_type_i[2]&!tgu_packet_type_i[1]
    &payload_size[2]&!ts_diff[2]&!ts_diff[1]) | (tgu_packet_type_i[1]
    &payload_size[1]&timestamped&ts_diff[2]) | (payload_size[1]
    &timestamped&ts_diff[3]) | (payload_size[1]&timestamped&ts_diff[4]) | (
    payload_size[1]&timestamped&ts_diff[5]) | (payload_size[1]
    &timestamped&ts_diff[6]);

  assign dp_size[0] = (tgu_packet_type_i[1]&payload_size[2]&timestamped&!ts_diff[2]
    &ts_diff[1]) | (tgu_packet_type_i[1]&payload_size[0]&timestamped
    &!ts_diff[2]&ts_diff[1]) | (tgu_packet_type_i[0]&payload_size[1]
    &!timestamped) | (tgu_packet_type_i[1]&payload_size[2]&timestamped
    &ts_diff[6]) | (tgu_packet_type_i[1]&payload_size[0]&timestamped
    &ts_diff[6]) | (tgu_packet_type_i[1]&payload_size[2]&timestamped
    &ts_diff[5]) | (tgu_packet_type_i[1]&payload_size[0]&timestamped
    &ts_diff[5]) | (tgu_packet_type_i[1]&payload_size[2]&timestamped
    &ts_diff[4]) | (tgu_packet_type_i[1]&payload_size[0]&timestamped
    &ts_diff[4]) | (tgu_packet_type_i[1]&payload_size[2]&timestamped
    &ts_diff[3]) | (tgu_packet_type_i[1]&payload_size[0]&timestamped
    &ts_diff[3]) | (tgu_packet_type_i[1]&!tgu_packet_type_i[0]
    &payload_size[0]&!timestamped) | (!tgu_packet_type_i[1]
    &payload_size[1]&timestamped&!ts_diff[6]&!ts_diff[5]&!ts_diff[4]
    &!ts_diff[3]&!ts_diff[1]) | (!tgu_packet_type_i[1]&payload_size[1]
    &timestamped&!ts_diff[6]&!ts_diff[5]&!ts_diff[4]&!ts_diff[3]
    &ts_diff[2]) | (!tgu_packet_type_i[2]&!tgu_packet_type_i[1]
    &payload_size[2]&timestamped&!ts_diff[6]&!ts_diff[5]&!ts_diff[4]
    &!ts_diff[3]&!ts_diff[1]) | (!tgu_packet_type_i[1]&payload_size[0]
    &timestamped&!ts_diff[6]&!ts_diff[5]&!ts_diff[4]&!ts_diff[3]
    &!ts_diff[1]) | (!tgu_packet_type_i[1]&!payload_size[2]
    &!payload_size[1]&!payload_size[0]&!ts_diff[2]&ts_diff[1]) | (
    tgu_packet_type_i[1]&payload_size[1]&!ts_diff[2]&ts_diff[1]) | (
    !tgu_packet_type_i[2]&!tgu_packet_type_i[1]&payload_size[2]
    &timestamped&!ts_diff[6]&!ts_diff[5]&!ts_diff[4]&!ts_diff[3]
    &ts_diff[2]) | (tgu_packet_type_i[1]&!payload_size[2]&!payload_size[1]
    &!payload_size[0]&timestamped&!ts_diff[6]&!ts_diff[5]&!ts_diff[4]
    &!ts_diff[3]&!ts_diff[1]) | (!tgu_packet_type_i[1]&payload_size[0]
    &timestamped&!ts_diff[6]&!ts_diff[5]&!ts_diff[4]&!ts_diff[3]
    &ts_diff[2]) | (tgu_packet_type_i[1]&!payload_size[2]&!payload_size[1]
    &!payload_size[0]&timestamped&!ts_diff[6]&!ts_diff[5]&!ts_diff[4]
    &!ts_diff[3]&ts_diff[2]) | (!tgu_packet_type_i[1]&!payload_size[2]
    &!payload_size[1]&!payload_size[0]&ts_diff[3]) | (
    tgu_packet_type_i[1]&payload_size[1]&ts_diff[3]) | (
    !tgu_packet_type_i[1]&!payload_size[2]&!payload_size[1]
    &!payload_size[0]&ts_diff[4]) | (tgu_packet_type_i[1]&payload_size[1]
    &ts_diff[4]) | (!tgu_packet_type_i[2]&tgu_packet_type_i[1]
    &payload_size[2]&!timestamped) | (!tgu_packet_type_i[1]
    &!payload_size[2]&!payload_size[1]&!payload_size[0]&ts_diff[5]) | (
    tgu_packet_type_i[1]&payload_size[1]&ts_diff[5]) | (
    !tgu_packet_type_i[1]&!payload_size[2]&!payload_size[1]
    &!payload_size[0]&ts_diff[6]) | (tgu_packet_type_i[1]&payload_size[1]
    &ts_diff[6]) | (!tgu_packet_type_i[1]&!payload_size[2]
    &!payload_size[1]&!payload_size[0]&!timestamped) | (
    tgu_packet_type_i[1]&payload_size[1]&!timestamped);

  assign exttsp_size[3] = (payload_size[1]&ts_diff[6]) | (!tgu_packet_type_i[2]
    &payload_size[2]&ts_diff[5]) | (!tgu_packet_type_i[2]&ts_diff[6]);

  assign exttsp_size[2] = (!tgu_packet_type_i[2]&!ts_diff[6]&!ts_diff[5]) | (
    !payload_size[2]&!ts_diff[6]) | (!tgu_packet_type_i[2]
    &payload_size[2]&ts_diff[6]);

  // end of espresso output

  end













  endgenerate

  // Word written to ctrl fifo on packet insertion
  assign packet_ctrl_data[3:0] = {flush_marker,                 // 3
                                  (extts_needed & timestamped), // 2
                                  mc_needed,                    // 1
                                  CTRL_USE_FIFOS                // 0
                                 };

  // Packet information is inserted into FIFO when:
  // - data request is active
  // - tgu is not stalled
  assign packet_inserted = tgu_ready;

  //----------------------------------------------------------------------------
  // Output assignment
  //----------------------------------------------------------------------------
  // TGU i/f
  assign tgu_ready_o       = tgu_ready;
  assign tgu_timestamped_o = timestamped;
  assign tgu_fvalid_o      = tgu_fvalid_reg;

  // Control FIFO
  assign ctrl_in_valid_o     = sync_inserted | packet_inserted | flush_inserted;
  assign ctrl_in_data_o[3:0] = {4{sync_inserted}}   & sync_ctrl_data[3:0]  |
                               {4{flush_inserted}}  & flush_ctrl_data[3:0] |
                               {4{packet_inserted}} & packet_ctrl_data[3:0];

  // Channel FIFO
  assign ch_in_valid_o      = tgu_ready & mc_needed;
  assign ch_in_data_o[26:0] = {mc_type[2:0],         // 26:24 - master/channel encoding
                               tgu_channel_i[15:0],  // 23:8  - channel number
                               tgu_master_i[7:0]     // 7:0   - master number
                              };

  // Data FIFO
  generate
    if (STM_DATA_WIDTH == 64) begin : gen_data_out_64
      assign data_in_valid_o      = tgu_ready;
      assign data_in_data_o[93:0] = {dp_size[4:0],        // 93:89
                                     extended_opcode,     // 88
                                     stpv2_opcode[3:0],   // 87:84
                                     packet_data[83:0]    // 83:0
                                    };
    end
  endgenerate

  // Extended timestamp FIFO
  assign extts_in_valid_o      = tgu_ready & (|tgu_ts_req[1:0]) & extts_needed & extts_in_ready_i;
  assign extts_in_data_o[49:0] = {exttsp_size[3:2],   // 49:48
                                  extts_value[47:0]   // 47:0
                                 };

  // TGU busy is held high if there is a pending or new sync
  assign tracegen_busy_o = sync_pending_reg | syncreq_i;

  // TGU requires clock if there is data on the input, or sync/flush are to be inserted
  assign tracegen_clk_req_o = tgu_valid_i | sync_tgu | hp_sync_tgu | flush_marker;

  wire unused_ok;
  assign unused_ok = &{1'b0,
                       data_in_ready_i,
                       1'b0};

`ifdef ARM_ASSERT_ON
  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------

  assert_zero_one_hot #(`OVL_FATAL,3,`OVL_ASSERT,"sync_inserted, flush_inserted, packet_inserted should be exclusive")
    ovl_zero_one_hot_tracegen_exclusive_packet_insertion (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr ({sync_inserted, flush_inserted, packet_inserted})
    );

  // Ensure no packets are inserted during Q_STOPPED
  // Hierarchical references used to prevent having to run additional q_stopped signal into tracegen
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"No packets must be inserted during Q_STOPPED state")
    ovl_never_tracegen_no_packets_inserted (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (q_stopped_i & (packet_inserted | sync_inserted | flush_inserted))
    );

  // TGU i/f assertions
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"tgu_ready_o should not be asserted without tgu_valid_i")
    ovl_never_tracegen_tgu_ready_without_tgu_valid (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (~tgu_valid_i & tgu_ready)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"MERR should not be timestamped")
    ovl_never_tracegen_merr_with_timestamp (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (tgu_valid_i & (tgu_packet_type_i[2:0] == 3'b110) & timestamped)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"GERR should not be timestamped")
    ovl_never_tracegen_gerr_with_timestamp (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (tgu_valid_i & (tgu_packet_type_i[2:0] == 3'b111) & timestamped)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"TIME and USER requests are not supported")
    ovl_never_tracegen_illegal_time_or_user_packet (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (tgu_valid_i & ((tgu_packet_type_i[2:0] == 3'b001) | (tgu_packet_type_i[2:0] == 3'b011)))
    );

  // FIFO write assertions
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Write to data, channel or timestamp fifo must be accompanied with write to control fifo")
    ovl_never_tracegen_write_without_control_data (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (~ctrl_in_valid_o & (ch_in_valid_o | data_in_valid_o | extts_in_valid_o))
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Write to channel fifo must be accompanied with write to data fifo")
    ovl_never_tracegen_channel_write_without_data (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (~data_in_valid_o & ch_in_valid_o)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Write to timestamp fifo must be accompanied with write to data fifo")
    ovl_never_tracegen_timestamp_write_without_data (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (~data_in_valid_o & extts_in_valid_o)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Illegal ts_size")
    ovl_never_tracegen_illegal_ts_size (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (tgu_valid_i & timestamped & ((ts_size[3:0]==4'b0000) | (ts_size[3:0]==4'b0101) | (ts_size[3:0]==4'b0110) |
                                               (ts_size[3:0]==4'b0111) | (ts_size[3:0]==4'b1001) | (ts_size[3:0]==4'b1010) |
                                               (ts_size[3:0]==4'b1011) | (ts_size[3:0]==4'b1101) | (ts_size[3:0]==4'b1111)))
    );

  assert_zero_one_hot #(`OVL_FATAL,7,`OVL_ASSERT,"ts_size_ctrl must be zero or one-hots")
    ovl_zero_one_hot_tracegen_ts_size_ctrl (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr ({7{tgu_valid_i}} & ts_size_ctrl[6:0])
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Sync must be pending for high priority sync to be pending")
    ovl_never_tracegen_hp_sync_pending (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (~sync_pending_reg & hp_sync_pending_reg)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Data FIFO must be ready when ctrl FIFO is ready")
    ovl_never_tracegen_data_fifo_ready_when_ctrl_fifo_ready (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (ctrl_in_ready_i & ~data_in_ready_i)
    );

  generate
    if(STM_DATA_WIDTH == 64) begin : gen_ovl_64
      assert_never #(`OVL_FATAL,`OVL_ASSERT,"Illegal payload size (3'b101)")
        ovl_never_illegal_payload_size_101 (
          .clk       (clk_gated),
          .reset_n   (STMRESETn),
          .test_expr (tgu_valid_i & (tgu_size_i == 3'b101))
        );

      assert_never #(`OVL_FATAL,`OVL_ASSERT,"Illegal payload size (3'b110)")
        ovl_never_illegal_payload_size_110 (
          .clk       (clk_gated),
          .reset_n   (STMRESETn),
          .test_expr (tgu_valid_i & (tgu_size_i == 3'b110))
        );

      assert_never #(`OVL_FATAL,`OVL_ASSERT,"Illegal payload size (3'b111)")
        ovl_never_illegal_payload_size_111 (
          .clk       (clk_gated),
          .reset_n   (STMRESETn),
          .test_expr (tgu_valid_i & (tgu_size_i == 3'b111))
        );
    end
  endgenerate


  // X propagation
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "tgu_fvalid_we is X")
    ovl_never_unknown_tracegen_tgu_fvalid_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (tgu_fvalid_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "mast_prev_we is X")
    ovl_never_unknown_tracegen_mast_prev_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (mast_prev_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "ch_prev_we is X")
    ovl_never_unknown_tracegen_ch_prev_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (ch_prev_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "ts_prev_we is X")
    ovl_never_unknown_tracegen_ts_prev_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (ts_prev_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "sync_pending_we is X")
    ovl_never_unknown_tracegen_sync_pending_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (sync_pending_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "hp_sync_pending_we is X")
    ovl_never_unknown_tracegen_hp_sync_pending_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (hp_sync_pending_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "sync_ongoing_we is X")
    ovl_never_unknown_tracegen_sync_ongoing_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (sync_ongoing_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "flush_pending_we is X")
    ovl_never_unknown_tracegen_flush_pending_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (flush_pending_we)
    );

  assert_never_unknown #(`OVL_FATAL, 64, `OVL_ASSERT, "timestamp is X")
    ovl_never_unknown_tracegen_timestamp (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (timestamped),
      .test_expr (timestamp)
    );

  assert_never_unknown #(`OVL_FATAL, ((STM_DATA_WIDTH/32)+1), `OVL_ASSERT, "comp_data_size is X")
    ovl_never_unknown_tracegen_comp_data_size (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (tgu_valid_i),
      .test_expr (comp_data_size)
    );

`endif

endmodule // cxstm500_tgu_tracegen

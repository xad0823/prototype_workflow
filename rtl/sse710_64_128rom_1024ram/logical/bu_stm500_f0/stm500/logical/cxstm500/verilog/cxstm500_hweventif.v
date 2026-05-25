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
//      Revision            : $Revision: 38886 $
//
//      Release Information : CoreSight STM-500 Global Bundle-r0p1-00rel0
//-----------------------------------------------------------------------------
//      Purpose:
//      Hardware Event Observation interface
//-----------------------------------------------------------------------------

module cxstm500_hweventif #(
  parameter [31:0] HWEVOBIF_CONFIG_63_32 = 32'h0000_0000, // Edge/Level based HW Event detection (0 = Edge based, 1 = Level for interfaces HW63:HW32
  parameter [31:0] HWEVOBIF_CONFIG_31_0  = 32'h0000_0000, // Edge/Level based HW Event detection (0 = Edge based, 1 = Level for interfaces HW32:HW0
  parameter        STM_DATA_WIDTH    = 64
  )
  (
  // Clock and Reset
  input wire                          clk_gated,            // gated clock
  input wire                          STMRESETn,            // asynchronous reset

  // Harware Event Interface
  input wire   [STM_DATA_WIDTH-1:0]   HWEVENTS,             // Hardware Events

  // TGU data interface
  input wire                          tgu_ready_i,          // TGU Transfer Ready
  input wire                          tgu_fvalid_i,         // Data flush request
  output wire                         tgu_valid_o,          // TGU Transfer Valid
  output wire [7:0]                   tgu_master_o,         // Master Number
  output wire [15:0]                  tgu_channel_o,        // STPv2 Channel Number
  output wire [2:0]                   tgu_packet_type_o,    // STPv2 Packet Type
  output wire [(STM_DATA_WIDTH/32):0] tgu_size_o,           // Payload Size
  output wire [STM_DATA_WIDTH-1:0]    tgu_payload_o,        // Payload
  output wire [1:0]                   tgu_ts_req_o,         // Timestamp Qualifier
  output wire                         tgu_fready_o,         // Data flush completed

  // Configuration Interface
  input wire                          hw_enable_i,          // HW Front End Enable
  input wire                          hw_tsen_i,            // Timestamping Enable
  input wire  [STM_DATA_WIDTH-1:0]    hw_heer_i,            // HEER value
  input wire  [STM_DATA_WIDTH-1:0]    hw_heter_i,           // HETER value
  input wire                          hw_singleshot_i,      // HETE singleshot mode
  input wire                          hw_trigstatushete_i,  // HETE trigger status in singleshot mode
  input wire                          hw_errdetect_i,       // hw error detection enable
  output wire                         hw_busy_o,            // Busy Status

  // Trigger Interface
  output wire                         triggerhete_o,        // Trigger, matches using STMSPTER
  output wire                         TRIGOUTHETE,          // Trigger output event, matches using STMSPTER, registered output

  // CoreSight Authentication Interface
  input wire                          dbgen_r_i,            // Debug Enable
  input wire                          niden_r_i,            // Non-invasive Debug Enable

  // Integartion testing interface
  input wire                          itctl_i,              // integration mode
  input wire                          ittrigger_we_i,       // write to ITTRIGGER register
  input wire                          pwdatadbg2_r_i        // APB data bit 2
  );


  //---------------------------------------------------------------------------
  // Constant definitions
  //---------------------------------------------------------------------------
  localparam  HW_IDLE       = 3'b001;   // TGU HW FSM idle
  localparam  HW_D          = 3'b000;   // TGU HW FSM requesting data packet without timestamp
  localparam  HW_DF         = 3'b010;   // TGU HW FSM requesting data packet to be followed by FLAGTS
  localparam  HW_FLAGTS     = 3'b101;   // TGU HW FSM requesting FLAGTS packet
  localparam  HW_FLAGTSH    = 3'b011;   // TGU HW FSM requesting FLAGTS packet, with historical data present
  localparam  HW_FLAGTSM    = 3'b100;   // TGU HW FSM requesting FLAGTS packet to be followed by MERR
  localparam  HW_MERR       = 3'b110;   // TGU HW FSM requesting MERR packet

  localparam  TGU_DATAM     = 3'b000;   // TGU DxM packet type
  localparam  TGU_DATA      = 3'b010;   // TGU Dx packet type
  localparam  TGU_FLAG      = 3'b100;   // TGU FLAG packet type
  localparam  TGU_MERR      = 3'b110;   // TGU MERR packet type

  localparam  TGU_DEFAULT_SIZE      = (STM_DATA_WIDTH/32) + 2; //TGU Size - 64 bits = 3'b100, 32 bits = 3'b011

  //---------------------------------------------------------------------------
  // Wires
  //---------------------------------------------------------------------------
  wire [STM_DATA_WIDTH-1:0]     events;
  wire                          new_event;
  wire [(STM_DATA_WIDTH/8)-1:0] nxt_new_event;
  wire                          events_buf_empty;
  wire [STM_DATA_WIDTH-1:0]     events_in;
  wire [STM_DATA_WIDTH-1:0]     no_events;
  wire                          single_event;
  wire [7:0]                    m_payload;
  wire [(STM_DATA_WIDTH/8)-1:0] nxt_merr;
  wire                          merr_we;
  wire                          merr_clear;
  wire                          merr;
  wire [(STM_DATA_WIDTH/8)-1:0] nxt_ts_flag;
  wire                          ts_flag_we;
  wire                          ts_flag_clear;
  wire                          ts_flag;
  wire                          state_we;
  wire [STM_DATA_WIDTH-1:0]     tgu_payload;
  wire                          nxt_fsm_busy;
  wire                          tgu_valid;
  wire                          hw_triggerhete_en;
  wire                          triggerhete;
  wire                          trigouthete_we;
  wire                          nxt_trigouthete;
  wire                          hw_flush;
  wire                          nxt_hw_flush_done;
  wire                          hw_flush_done_we;
  wire                          nxt_tgu_toflush;
  wire                          tgu_toflush_we;
  wire                          tgu_to_flush;
  wire                          data_nxt_state;
  wire                          flush_ongoing;
  wire                          tgu_fready;
  wire [STM_DATA_WIDTH-1:0]     events_mask;
  wire                          hw_busy;
  wire                          nsec_noninvasive;
  wire                          hw_enable_we;
  wire                          new_event_reg_we;
  wire                          events_buf_reg_we;

  //---------------------------------------------------------------------------
  // Registers
  //---------------------------------------------------------------------------
  reg [STM_DATA_WIDTH-1:0]     hwevents_reg;
  reg [(STM_DATA_WIDTH/8)-1:0] new_event_reg;
  reg [STM_DATA_WIDTH-1:0]     events_buf_reg;
  reg                          fsm_busy_reg;
  reg [(STM_DATA_WIDTH/8)-1:0] merr_reg;
  reg [(STM_DATA_WIDTH/8)-1:0] ts_flag_reg;
  reg [2:0]                    state_reg;
  reg                          trigouthete_reg;
  reg                          hw_enable_reg;
  reg                          tgu_fvalid_reg;
  reg                          tgu_toflush_reg;
  reg                          hw_flush_done_reg;

  reg [(STM_DATA_WIDTH/32):0] tgu_size;
  reg [1:0]                   tgu_ts_req;
  reg [2:0]                   tgu_packet_type;
  reg [2:0]                   nxt_state;

  //---------------------------------------------------------------------------
  //
  // Main body of code
  // =================
  //
  //---------------------------------------------------------------------------
  // Authentication signals decode
  // Table 9-2 and Table 3-7 CoreSight Architecture
  // HW i/f is not invasive and there is no security
  assign nsec_noninvasive = niden_r_i | dbgen_r_i;

  // Event Detection Logic
  //----------------------

  // The event detection logic may be configured for level-based or
  // edge-based detection. The build-time parameter HWEVOBIF_CONFIG
  // defeines the detection behaviour for each HW event. E.g. HW0 is
  // defined by HWEVOBIF_CONFIG[0], where a value of 0 indicates edge
  // detection and 1 indicates level detection

  // Detection is gated with one cycle delayed enable
  // This is to allow edge detectors to work off gated clock
  // but not report false edges on hw_enable_i rising edge
  // Event is detected on rising edge and when enabled in STMHEER

  // Level-based dection is detected when enabled in STMHEER

  //Register hw_enable for use in event detection
  assign hw_enable_we = hw_enable_reg ^ hw_enable_i;

  always @(posedge clk_gated or negedge STMRESETn)
    begin
      if (!STMRESETn)
        hw_enable_reg <= 1'b0;
      else if (hw_enable_we)
        hw_enable_reg <= hw_enable_i;
    end

  //Generate level-based or edge-based detection (Events 31:0)
  genvar i;
  generate
    for(i = 0; i < 32; i=i+1 ) begin : gen_hw_31_0

      //Edge based detection
      if (HWEVOBIF_CONFIG_31_0[i] == 1'b0) begin : gen_hw_31_0_edge

        always @(posedge clk_gated)
          begin
            if (hw_enable_i)
              hwevents_reg[i] <= HWEVENTS[i];
          end

        assign events_mask[i] = ~hwevents_reg[i] & hw_heer_i[i] & hw_enable_reg & hw_enable_i & nsec_noninvasive;
        assign events[i]      = HWEVENTS[i] & events_mask[i];


      //Level based detection
      end else begin : gen_hw_31_0_level

        assign events_mask[i] = hw_heer_i[i] & hw_enable_reg & hw_enable_i & nsec_noninvasive;
        assign events[i]      = HWEVENTS[i] & events_mask[i];

      end
    end

    //Generate level-based or edge-based detection (Events 63:32)
    if (STM_DATA_WIDTH == 64) begin : gen_hw_64
      for(i = 0; i < 32; i=i+1) begin : gen_hw_63_32

        //Edge based detection
        if (HWEVOBIF_CONFIG_63_32[i] == 1'b0) begin : gen_hw_63_32_edge

          always @(posedge clk_gated)
            begin
              if (hw_enable_i)
                hwevents_reg[i+32] <= HWEVENTS[i+32];
            end

          assign events_mask[i+32] = ~hwevents_reg[i+32] & hw_heer_i[i+32] & hw_enable_reg & hw_enable_i & nsec_noninvasive;
          assign events[i+32]      = HWEVENTS[i+32] & events_mask[i+32];


        //Level based detection
        end else begin : gen_hw_63_32_level

          assign events_mask[i+32] = hw_heer_i[i+32] & hw_enable_reg & hw_enable_i & nsec_noninvasive;
          assign events[i+32]      = HWEVENTS[i+32] & events_mask[i+32];

        end
      end
    end
  endgenerate

  // Timing optimization
  // Timing from inputs is critical, 64 events are split in 8 groups of 8 events,
  // while 32 events are split into 4 groups of 8 events such that
  // only 8-bit reduction is done on input side
  generate
    if(STM_DATA_WIDTH == 64)
      assign nxt_new_event[(STM_DATA_WIDTH/8)-1:0] = {|events[63:56],
                                                      |events[55:48],
                                                      |events[47:40],
                                                      |events[39:32],
                                                      |events[31:24],
                                                      |events[23:16],
                                                      |events[15:8],
                                                      |events[7:0]};
  endgenerate

  assign new_event_reg_we = hw_enable_reg | hw_enable_i | new_event;

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      new_event_reg[(STM_DATA_WIDTH/8)-1:0] <= {(STM_DATA_WIDTH/8){1'b0}};
    else if (new_event_reg_we)
      new_event_reg[(STM_DATA_WIDTH/8)-1:0] <= nxt_new_event[(STM_DATA_WIDTH/8)-1:0];
  end

  assign new_event = |new_event_reg[(STM_DATA_WIDTH/8)-1:0];

  // Events are added to buffer register until tgu_ready is seen
  // On tgu_ready buffer is cleared or loaded with new events
  assign events_in[STM_DATA_WIDTH-1:0] = ({STM_DATA_WIDTH{ tgu_ready_i & tgu_valid & ~tgu_packet_type[2]}} &  events[STM_DATA_WIDTH-1:0]                        ) |
                                         ({STM_DATA_WIDTH{ tgu_ready_i & tgu_valid &  tgu_packet_type[2]}} & (events[STM_DATA_WIDTH-1:0] | events_buf_reg[STM_DATA_WIDTH-1:0])) |
                                         ({STM_DATA_WIDTH{~tgu_ready_i}}                                   & (events[STM_DATA_WIDTH-1:0] | events_buf_reg[STM_DATA_WIDTH-1:0]));

  assign events_buf_reg_we = hw_enable_reg | hw_enable_i | (|events_buf_reg[STM_DATA_WIDTH-1:0]);

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      events_buf_reg[STM_DATA_WIDTH-1:0] <= {STM_DATA_WIDTH{1'b0}};
    else if (events_buf_reg_we)
      events_buf_reg[STM_DATA_WIDTH-1:0] <= events_in[STM_DATA_WIDTH-1:0];
  end

  assign events_buf_empty = ~(|events_buf_reg[STM_DATA_WIDTH-1:0]);

  // Detect single event
  // To detect if single bit set within the array
  // a mask is generated with each mask bit
  // telling that there are no bits set in the rest of array
  // For example bit 0, mask is set high if all bits [STM_DATA_WIDTH-1:1] are zero
  generate
    if (STM_DATA_WIDTH == 64)
      assign no_events[STM_DATA_WIDTH-1:0] = {~(|events_buf_reg[62:0]),
                                              ~(|{events_buf_reg[63],   events_buf_reg[61:0]}),
                                              ~(|{events_buf_reg[63:62], events_buf_reg[60:0]}),
                                              ~(|{events_buf_reg[63:61], events_buf_reg[59:0]}),
                                              ~(|{events_buf_reg[63:60], events_buf_reg[58:0]}),
                                              ~(|{events_buf_reg[63:59], events_buf_reg[57:0]}),
                                              ~(|{events_buf_reg[63:58], events_buf_reg[56:0]}),
                                              ~(|{events_buf_reg[63:57], events_buf_reg[55:0]}),
                                              ~(|{events_buf_reg[63:56], events_buf_reg[54:0]}),
                                              ~(|{events_buf_reg[63:55], events_buf_reg[53:0]}),
                                              ~(|{events_buf_reg[63:54], events_buf_reg[52:0]}),
                                              ~(|{events_buf_reg[63:53], events_buf_reg[51:0]}),
                                              ~(|{events_buf_reg[63:52], events_buf_reg[50:0]}),
                                              ~(|{events_buf_reg[63:51], events_buf_reg[49:0]}),
                                              ~(|{events_buf_reg[63:50], events_buf_reg[48:0]}),
                                              ~(|{events_buf_reg[63:49], events_buf_reg[47:0]}),
                                              ~(|{events_buf_reg[63:48], events_buf_reg[46:0]}),
                                              ~(|{events_buf_reg[63:47], events_buf_reg[45:0]}),
                                              ~(|{events_buf_reg[63:46], events_buf_reg[44:0]}),
                                              ~(|{events_buf_reg[63:45], events_buf_reg[43:0]}),
                                              ~(|{events_buf_reg[63:44], events_buf_reg[42:0]}),
                                              ~(|{events_buf_reg[63:43], events_buf_reg[41:0]}),
                                              ~(|{events_buf_reg[63:42], events_buf_reg[40:0]}),
                                              ~(|{events_buf_reg[63:41], events_buf_reg[39:0]}),
                                              ~(|{events_buf_reg[63:40], events_buf_reg[38:0]}),
                                              ~(|{events_buf_reg[63:39], events_buf_reg[37:0]}),
                                              ~(|{events_buf_reg[63:38], events_buf_reg[36:0]}),
                                              ~(|{events_buf_reg[63:37], events_buf_reg[35:0]}),
                                              ~(|{events_buf_reg[63:36], events_buf_reg[34:0]}),
                                              ~(|{events_buf_reg[63:35], events_buf_reg[33:0]}),
                                              ~(|{events_buf_reg[63:34], events_buf_reg[32:0]}),
                                              ~(|{events_buf_reg[63:33], events_buf_reg[31:0]}),
                                              ~(|{events_buf_reg[63:32], events_buf_reg[30:0]}),
                                              ~(|{events_buf_reg[63:31], events_buf_reg[29:0]}),
                                              ~(|{events_buf_reg[63:30], events_buf_reg[28:0]}),
                                              ~(|{events_buf_reg[63:29], events_buf_reg[27:0]}),
                                              ~(|{events_buf_reg[63:28], events_buf_reg[26:0]}),
                                              ~(|{events_buf_reg[63:27], events_buf_reg[25:0]}),
                                              ~(|{events_buf_reg[63:26], events_buf_reg[24:0]}),
                                              ~(|{events_buf_reg[63:25], events_buf_reg[23:0]}),
                                              ~(|{events_buf_reg[63:24], events_buf_reg[22:0]}),
                                              ~(|{events_buf_reg[63:23], events_buf_reg[21:0]}),
                                              ~(|{events_buf_reg[63:22], events_buf_reg[20:0]}),
                                              ~(|{events_buf_reg[63:21], events_buf_reg[19:0]}),
                                              ~(|{events_buf_reg[63:20], events_buf_reg[18:0]}),
                                              ~(|{events_buf_reg[63:19], events_buf_reg[17:0]}),
                                              ~(|{events_buf_reg[63:18], events_buf_reg[16:0]}),
                                              ~(|{events_buf_reg[63:17], events_buf_reg[15:0]}),
                                              ~(|{events_buf_reg[63:16], events_buf_reg[14:0]}),
                                              ~(|{events_buf_reg[63:15], events_buf_reg[13:0]}),
                                              ~(|{events_buf_reg[63:14], events_buf_reg[12:0]}),
                                              ~(|{events_buf_reg[63:13], events_buf_reg[11:0]}),
                                              ~(|{events_buf_reg[63:12], events_buf_reg[10:0]}),
                                              ~(|{events_buf_reg[63:11], events_buf_reg[9:0]}),
                                              ~(|{events_buf_reg[63:10], events_buf_reg[8:0]}),
                                              ~(|{events_buf_reg[63:9], events_buf_reg[7:0]}),
                                              ~(|{events_buf_reg[63:8], events_buf_reg[6:0]}),
                                              ~(|{events_buf_reg[63:7], events_buf_reg[5:0]}),
                                              ~(|{events_buf_reg[63:6], events_buf_reg[4:0]}),
                                              ~(|{events_buf_reg[63:5], events_buf_reg[3:0]}),
                                              ~(|{events_buf_reg[63:4], events_buf_reg[2:0]}),
                                              ~(|{events_buf_reg[63:3], events_buf_reg[1:0]}),
                                              ~(|{events_buf_reg[63:2], events_buf_reg[0:0]}),
                                              ~(|events_buf_reg[63:1])};

  endgenerate

  assign single_event = |(events_buf_reg[STM_DATA_WIDTH-1:0] & no_events[STM_DATA_WIDTH-1:0]);

  generate
    if(STM_DATA_WIDTH == 64)
      assign m_payload[7:0] = ({8{events_buf_reg[0] }} & 8'h00) |
                              ({8{events_buf_reg[1] }} & 8'h01) |
                              ({8{events_buf_reg[2] }} & 8'h02) |
                              ({8{events_buf_reg[3] }} & 8'h03) |
                              ({8{events_buf_reg[4] }} & 8'h04) |
                              ({8{events_buf_reg[5] }} & 8'h05) |
                              ({8{events_buf_reg[6] }} & 8'h06) |
                              ({8{events_buf_reg[7] }} & 8'h07) |
                              ({8{events_buf_reg[8] }} & 8'h08) |
                              ({8{events_buf_reg[9] }} & 8'h09) |
                              ({8{events_buf_reg[10]}} & 8'h0A) |
                              ({8{events_buf_reg[11]}} & 8'h0B) |
                              ({8{events_buf_reg[12]}} & 8'h0C) |
                              ({8{events_buf_reg[13]}} & 8'h0D) |
                              ({8{events_buf_reg[14]}} & 8'h0E) |
                              ({8{events_buf_reg[15]}} & 8'h0F) |
                              ({8{events_buf_reg[16]}} & 8'h10) |
                              ({8{events_buf_reg[17]}} & 8'h11) |
                              ({8{events_buf_reg[18]}} & 8'h12) |
                              ({8{events_buf_reg[19]}} & 8'h13) |
                              ({8{events_buf_reg[20]}} & 8'h14) |
                              ({8{events_buf_reg[21]}} & 8'h15) |
                              ({8{events_buf_reg[22]}} & 8'h16) |
                              ({8{events_buf_reg[23]}} & 8'h17) |
                              ({8{events_buf_reg[24]}} & 8'h18) |
                              ({8{events_buf_reg[25]}} & 8'h19) |
                              ({8{events_buf_reg[26]}} & 8'h1A) |
                              ({8{events_buf_reg[27]}} & 8'h1B) |
                              ({8{events_buf_reg[28]}} & 8'h1C) |
                              ({8{events_buf_reg[29]}} & 8'h1D) |
                              ({8{events_buf_reg[30]}} & 8'h1E) |
                              ({8{events_buf_reg[31]}} & 8'h1F) |
                              ({8{events_buf_reg[32]}} & 8'h20) |
                              ({8{events_buf_reg[33]}} & 8'h21) |
                              ({8{events_buf_reg[34]}} & 8'h22) |
                              ({8{events_buf_reg[35]}} & 8'h23) |
                              ({8{events_buf_reg[36]}} & 8'h24) |
                              ({8{events_buf_reg[37]}} & 8'h25) |
                              ({8{events_buf_reg[38]}} & 8'h26) |
                              ({8{events_buf_reg[39]}} & 8'h27) |
                              ({8{events_buf_reg[40]}} & 8'h28) |
                              ({8{events_buf_reg[41]}} & 8'h29) |
                              ({8{events_buf_reg[42]}} & 8'h2A) |
                              ({8{events_buf_reg[43]}} & 8'h2B) |
                              ({8{events_buf_reg[44]}} & 8'h2C) |
                              ({8{events_buf_reg[45]}} & 8'h2D) |
                              ({8{events_buf_reg[46]}} & 8'h2E) |
                              ({8{events_buf_reg[47]}} & 8'h2F) |
                              ({8{events_buf_reg[48]}} & 8'h30) |
                              ({8{events_buf_reg[49]}} & 8'h31) |
                              ({8{events_buf_reg[50]}} & 8'h32) |
                              ({8{events_buf_reg[51]}} & 8'h33) |
                              ({8{events_buf_reg[52]}} & 8'h34) |
                              ({8{events_buf_reg[53]}} & 8'h35) |
                              ({8{events_buf_reg[54]}} & 8'h36) |
                              ({8{events_buf_reg[55]}} & 8'h37) |
                              ({8{events_buf_reg[56]}} & 8'h38) |
                              ({8{events_buf_reg[57]}} & 8'h39) |
                              ({8{events_buf_reg[58]}} & 8'h3A) |
                              ({8{events_buf_reg[59]}} & 8'h3B) |
                              ({8{events_buf_reg[60]}} & 8'h3C) |
                              ({8{events_buf_reg[61]}} & 8'h3D) |
                              ({8{events_buf_reg[62]}} & 8'h3E) |
                              ({8{events_buf_reg[63]}} & 8'h3F);

  endgenerate

  // Error detection
  // Timing optimization
  // Timing from inputs is critical, events are split in groups of 8 events,
  // so only 8-bit reduction is done on input side
  assign merr_clear  = tgu_ready_i & tgu_valid & ~tgu_packet_type[2];

  generate
    if(STM_DATA_WIDTH == 64)
      assign nxt_merr[(STM_DATA_WIDTH/8)-1:0] = {|(HWEVENTS[63:56] & events_mask[63:56] & events_buf_reg[63:56] & {8{hw_errdetect_i & (~tgu_ready_i | tgu_packet_type[2])}}),
                                                 |(HWEVENTS[55:48] & events_mask[55:48] & events_buf_reg[55:48] & {8{hw_errdetect_i & (~tgu_ready_i | tgu_packet_type[2])}}),
                                                 |(HWEVENTS[47:40] & events_mask[47:40] & events_buf_reg[47:40] & {8{hw_errdetect_i & (~tgu_ready_i | tgu_packet_type[2])}}),
                                                 |(HWEVENTS[39:32] & events_mask[39:32] & events_buf_reg[39:32] & {8{hw_errdetect_i & (~tgu_ready_i | tgu_packet_type[2])}}),
                                                 |(HWEVENTS[31:24] & events_mask[31:24] & events_buf_reg[31:24] & {8{hw_errdetect_i & (~tgu_ready_i | tgu_packet_type[2])}}),
                                                 |(HWEVENTS[23:16] & events_mask[23:16] & events_buf_reg[23:16] & {8{hw_errdetect_i & (~tgu_ready_i | tgu_packet_type[2])}}),
                                                 |(HWEVENTS[15:8]  & events_mask[15:8]  & events_buf_reg[15:8]  & {8{hw_errdetect_i & (~tgu_ready_i | tgu_packet_type[2])}}),
                                                 |(HWEVENTS[7:0]   & events_mask[7:0]   & events_buf_reg[7:0]   & {8{hw_errdetect_i & (~tgu_ready_i | tgu_packet_type[2])}})};

  endgenerate

  assign merr_we       = ~merr | merr_clear;

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      merr_reg[(STM_DATA_WIDTH/8)-1:0] <= {(STM_DATA_WIDTH/8){1'b0}};
    else if (merr_we)
      merr_reg[(STM_DATA_WIDTH/8)-1:0] <= nxt_merr[(STM_DATA_WIDTH/8)-1:0];
  end

  assign merr = |merr_reg[(STM_DATA_WIDTH/8)-1:0];

  // TS request detection
  // Timing optimization
  // Timing from inputs is critical, events are split in groups of 8 events,
  // so only 8-bit reduction is done on input side
  assign ts_flag_clear  = tgu_ready_i & tgu_valid & ~tgu_packet_type[2];

  generate
    if(STM_DATA_WIDTH == 64)
      assign nxt_ts_flag[(STM_DATA_WIDTH/8)-1:0] = {|(HWEVENTS[63:56] & events_mask[63:56] & {8{hw_tsen_i}}),
                                                    |(HWEVENTS[55:48] & events_mask[55:48] & {8{hw_tsen_i}}),
                                                    |(HWEVENTS[47:40] & events_mask[47:40] & {8{hw_tsen_i}}),
                                                    |(HWEVENTS[39:32] & events_mask[39:32] & {8{hw_tsen_i}}),
                                                    |(HWEVENTS[31:24] & events_mask[31:24] & {8{hw_tsen_i}}),
                                                    |(HWEVENTS[23:16] & events_mask[23:16] & {8{hw_tsen_i}}),
                                                    |(HWEVENTS[15:8]  & events_mask[15:8]  & {8{hw_tsen_i}}),
                                                    |(HWEVENTS[7:0]   & events_mask[7:0]   & {8{hw_tsen_i}})};

  endgenerate

  assign ts_flag_we  = ~ts_flag | ts_flag_clear;

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      ts_flag_reg[(STM_DATA_WIDTH/8)-1:0] <= {(STM_DATA_WIDTH/8){1'b0}};
    else if (ts_flag_we)
      ts_flag_reg[(STM_DATA_WIDTH/8)-1:0] <= nxt_ts_flag[(STM_DATA_WIDTH/8)-1:0];
  end

  assign ts_flag = |ts_flag_reg[(STM_DATA_WIDTH/8)-1:0];

  // FSM that controls TGU interface request generation
  // FSM is Meeley type for timing reasons
  // Timing from top level inputs is critical
  assign state_we = ~events_buf_empty | (tgu_ready_i & tgu_valid);

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      state_reg <= HW_IDLE;
    else if (state_we)
      state_reg <= nxt_state;
  end

  // This FSM implemnts HW Event tracing scheme as specified in
  // Table 45, STM Programmer's Model Architecture
  always @*
  begin
    case (state_reg)
      HW_IDLE: begin
        // assertion present for new_event being X
        if (~new_event)
          nxt_state = HW_IDLE;
        else
          // FSM moves into D or DF (D followed by FLAGTS)
          // if TGU i/f is stalled
          case ({tgu_ready_i, ts_flag})
            2'b10:   nxt_state = HW_IDLE;
            2'b11:   nxt_state = HW_IDLE;
            2'b00:   nxt_state = HW_D;
            2'b01:   nxt_state = HW_DF;
            // unreachable, X propagation only
            // VCS coverage off
            default: nxt_state = 3'bxxx;
            // VCS coverage on
          endcase
      end
      HW_D: begin
        // assertion present for tgu_ready_i being X
        if (~tgu_ready_i)
          // If TGU i/f is stalled stay in D state unless there is new event with timestamp
          case ({new_event, ts_flag})
            2'b00:   nxt_state = HW_D;
            2'b10:   nxt_state = HW_D;
            2'b11:   nxt_state = HW_DF;
            // illegal case - assertion present, ts_flag without new_event cannot happen in D state
            // 2'b01
            // VCS coverage off
            default: nxt_state = 3'bxxx;
            // VCS coverage on
          endcase
        else
          // When transaction is taken on TGU i/f
          // - move to MERR state if error is pending
          // - move to FLAGTS state if new event had timestamp
          // - move to FLAGTSM i.e FLAG followed by MERR if new event had timestamp and there was error pending
          case ({new_event, merr})
            2'b00:   nxt_state = HW_IDLE;
            2'b01:   nxt_state = HW_MERR;
            2'b10:   nxt_state = ts_flag ? HW_FLAGTS : HW_IDLE;
            2'b11:   nxt_state = ts_flag ? HW_FLAGTSM : HW_MERR;
            // unreachable, X propagation only
            // VCS coverage off
            default: nxt_state = 3'bxxx;
            // VCS coverage on
          endcase
      end
      HW_DF: begin
        // assertion present for tgu_ready_i being X
        if (~tgu_ready_i)
          // If TGU i/f is stalled stay in DF state
          nxt_state = HW_DF;
        else
          // When transaction is taken on TGU i/f
          // - move to FLAGTSM i.e FLAG followed by MERR if there was error pending
          // - otherwise move to FLAGTS state
          case ({new_event, merr})
            2'b00:   nxt_state = HW_FLAGTS;
            2'b01:   nxt_state = HW_FLAGTSM;
            2'b10:   nxt_state = HW_FLAGTS;
            2'b11:   nxt_state = HW_FLAGTSM;
            // unreachable, X propagation only
            // VCS coverage off
            default: nxt_state = 3'bxxx;
            // VCS coverage on
          endcase
      end
      HW_FLAGTS: begin
        // assertion present for tgu_ready_i being X
        if (~tgu_ready_i)
          // If TGU i/f is stalled wait until FLAGTS is accepted
          // Move to FLAGTSH to indicate there is some historical data
          // without timestamp request to output after FLAGTS
          // FLAGTS can be replaced with DTS unless flush is ongoing
          case ({new_event, ts_flag})
            2'b00:  nxt_state = HW_FLAGTS;
            2'b01:  nxt_state = HW_FLAGTS;
            2'b10:  nxt_state = HW_FLAGTSH;
            2'b11:  nxt_state = flush_ongoing ? HW_FLAGTS : HW_DF;
            // VCS coverage off
            default:  nxt_state = 3'bxxx;
            // VCS coverage on
          endcase
        else
          // When FLAGTS is taken on TGU i/f
          // - move to D if there are events without timestamp to output
          // - move to DF if there are events with timestamp to output
          // - move to IDLE if there is nothing to output
          case ({new_event, events_buf_empty, ts_flag})
            3'b001:  nxt_state = HW_DF;
            3'b010:  nxt_state = HW_IDLE;
            3'b100:  nxt_state = HW_D;
            3'b101:  nxt_state = flush_ongoing ? HW_DF : HW_IDLE;
            // illegal cases
            // 3'b000                 - assertion present, no historical data without timestamp here
            // 3'b011, 3'b011, 3'b111 - assertion present, ts_flag cannot be set when event buffer is empty
            // 3'b110                 - assertion present, buffer cannot be empty when there is a new event
            // VCS coverage off
            default:  nxt_state = 3'bxxx;
            // VCS coverage on
          endcase
      end
      HW_FLAGTSH: begin
        // assertion present for tgu_ready_i being X
        if (~tgu_ready_i)
          // If TGU i/f is stalled wait until FLAGTS is accepted
          nxt_state = HW_FLAGTSH;
        else
          // then
          // - move to D if there are events without timestamp to output
          // - move to DF if there are events with timestamp to output
          nxt_state = ts_flag ? HW_DF : HW_D;
      end
      HW_FLAGTSM: begin
        // When FLAGTS is taken on TGU i/f, move on to output MERR
        nxt_state = tgu_ready_i ? HW_MERR : HW_FLAGTSM;
      end
      HW_MERR: begin
        // assertion present for tgu_ready_i being X
        if (~tgu_ready_i)
          // If TGU i/f is stalled wait until MERR is accepted
          nxt_state = HW_MERR;
        else
          // When MERR is taken on TGU i/f
          // - move to D if there are events without timestamp to output
          // - move to DF if there are events with timestamp to output
          // - move to IDLE if there is nothing to output
          case ({events_buf_empty, ts_flag})
            2'b10:   nxt_state = HW_IDLE;
            2'b00:   nxt_state = HW_D;
            2'b01:   nxt_state = HW_DF;
            // 2'b11 is illegal - assertion present, ts_flag cannot be set when event buffer is empty
            // VCS coverage off
            default: nxt_state = 3'bxxx;
            // VCS coverage on
          endcase
      end
      // all other cases are illegal cases, assertion present
      // VCS coverage off
      default: nxt_state = 3'bxxx;
      // VCS coverage on
    endcase
  end

  always @*
  begin
    case (state_reg[2:0])

      HW_IDLE[2:0]: begin
        tgu_packet_type[2:0]            = single_event ? TGU_DATAM[2:0] : TGU_DATA[2:0];
        tgu_size[(STM_DATA_WIDTH/32):0] = single_event ? {{(STM_DATA_WIDTH/32){1'b0}},1'b1} : TGU_DEFAULT_SIZE[(STM_DATA_WIDTH/32):0];
        tgu_ts_req[1:0]                 = {2{ts_flag}};
        end

      HW_D[2:0]: begin
        tgu_packet_type[2:0]            = {1'b0, ~single_event, 1'b0};
        tgu_size[(STM_DATA_WIDTH/32):0] = single_event ? {{(STM_DATA_WIDTH/32){1'b0}},1'b1} : TGU_DEFAULT_SIZE[(STM_DATA_WIDTH/32):0];
        tgu_ts_req[1:0]                 = 2'b00;
        end

      HW_DF[2:0]: begin
        tgu_packet_type[2:0]            = {1'b0, ~single_event, 1'b0};
        tgu_size[(STM_DATA_WIDTH/32):0] = single_event ? {{(STM_DATA_WIDTH/32){1'b0}},1'b1} : TGU_DEFAULT_SIZE[(STM_DATA_WIDTH/32):0];
        tgu_ts_req[1:0]                 = 2'b00;
        end

      HW_FLAGTS[2:0]: begin
        // assertion present for new_event being X
        if (~new_event)
          tgu_packet_type[2:0] = TGU_FLAG[2:0];
        else
          // assertion present for flush_ongoing being X
          if (flush_ongoing)
            tgu_packet_type[2:0] = TGU_FLAG[2:0];
          else
            case ({single_event, ts_flag})
              2'b00:   tgu_packet_type[2:0] = TGU_FLAG[2:0];
              2'b10:   tgu_packet_type[2:0] = TGU_FLAG[2:0];
              2'b11:   tgu_packet_type[2:0] = TGU_DATAM[2:0];
              2'b01:   tgu_packet_type[2:0] = TGU_DATA[2:0];
              // unreachable, X propagation only
              // VCS coverage off
              default: tgu_packet_type[2:0] = 3'bxxx;
              // VCS coverage on
            endcase

        // assertion present for new_event being X
        if (~new_event)
          tgu_size[(STM_DATA_WIDTH/32):0] = {((STM_DATA_WIDTH/32)+1){1'b0}};
        else
          // assertion present for flush_ongoing being X
          if (flush_ongoing)
            tgu_size[(STM_DATA_WIDTH/32):0] = {((STM_DATA_WIDTH/32)+1){1'b0}};
          else
            case ({single_event, ts_flag})
              2'b00:   tgu_size[(STM_DATA_WIDTH/32):0] = {{(STM_DATA_WIDTH/32){1'b0}}, 1'b0};
              2'b10:   tgu_size[(STM_DATA_WIDTH/32):0] = {{(STM_DATA_WIDTH/32){1'b0}}, 1'b0};
              2'b11:   tgu_size[(STM_DATA_WIDTH/32):0] = {{(STM_DATA_WIDTH/32){1'b0}}, 1'b1};
              2'b01:   tgu_size[(STM_DATA_WIDTH/32):0] = TGU_DEFAULT_SIZE[(STM_DATA_WIDTH/32):0];
              // unreachable, X propagation only
              // VCS coverage off
              default: tgu_size[(STM_DATA_WIDTH/32):0] = {((STM_DATA_WIDTH/32)+1){1'bx}};
              // VCS coverage on
            endcase
        tgu_ts_req[1:0] = 2'b11;
      end

      HW_FLAGTSH[2:0]: begin
        tgu_packet_type[2:0]            = 3'b100;
        tgu_size[(STM_DATA_WIDTH/32):0] = {((STM_DATA_WIDTH/32)+1){1'b0}};
        tgu_ts_req[1:0]                 = 2'b11;
      end

      HW_FLAGTSM[2:0]: begin
        tgu_packet_type[2:0]            = 3'b100;
        tgu_size[(STM_DATA_WIDTH/32):0] = {((STM_DATA_WIDTH/32)+1){1'b0}};
        tgu_ts_req[1:0]                 = 2'b11;
      end

      HW_MERR[2:0]: begin
        tgu_packet_type[2:0]            = 3'b110;
        tgu_size[(STM_DATA_WIDTH/32):0] = {((STM_DATA_WIDTH/32)+1){1'b0}};
        tgu_ts_req[1:0]                 = 2'b00;
      end

      // all other cases are illegal cases, assertion present
      // VCS coverage off
      default: begin
        tgu_packet_type[2:0]            = 3'bxxx;
        tgu_size[(STM_DATA_WIDTH/32):0] = {((STM_DATA_WIDTH/32)+1){1'bx}};
        tgu_ts_req[1:0]                 = 2'bxx;
      end
      // VCS coverage on
    endcase
  end

  assign tgu_payload[STM_DATA_WIDTH-1:0] = single_event ? {{(STM_DATA_WIDTH-8){1'b0}}, m_payload[7:0]} : events_buf_reg[STM_DATA_WIDTH-1:0];

  // TGU i/f has valid transaction unless FSM is in idle state
  assign nxt_fsm_busy = (nxt_state[2:0] != HW_IDLE[2:0]);

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      fsm_busy_reg <= 1'b0;
    else if (state_we)
      fsm_busy_reg <= nxt_fsm_busy;
  end

  assign tgu_valid = fsm_busy_reg | ~events_buf_empty;

  // Flush handling
  assign flush_ongoing = tgu_fvalid_i & tgu_fvalid_reg & ~tgu_fready;

  // Detect new flush request as:
  // - rising edge of tgu_fvalid_i
  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      tgu_fvalid_reg <= 1'b0;
    else
      tgu_fvalid_reg <= tgu_fvalid_i;
  end

  assign hw_flush = tgu_fvalid_i & ~tgu_fvalid_reg;

  // Toflush flag is set on rising edge of flush request if there are events in the buffer
  // It is cleared when data is outputted (data accpeted on TGU i/f)
  assign nxt_tgu_toflush = hw_flush & ~events_buf_empty & ~(tgu_ready_i & tgu_valid & ~tgu_packet_type[2]);
  assign tgu_toflush_we  = hw_flush |  (tgu_valid & tgu_ready_i & ~tgu_packet_type[2]);
  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      tgu_toflush_reg <= 1'b0;
    else if (tgu_toflush_we)
      tgu_toflush_reg <= nxt_tgu_toflush;
  end
  assign tgu_to_flush = tgu_toflush_reg | nxt_tgu_toflush;

  // Historical data means all events captured before flush (tgu_fvalid_i) was asserted plus all non-data packets
  // that are associated with the last data packet (FLAGTS, MERR)
  // 1) transaction on TGU if is accepted and FSM moves to new data state from current data state and flush is ongoing - meaning all historic data is accepted
  // 2) transaction on TGU if is accepted and FSM moves to new data state from non-data state and there is no historical data to be flushed
  assign data_nxt_state = ((nxt_state[2:0] == HW_IDLE[2:0]) | (nxt_state[2:0] == HW_D[2:0]) | (nxt_state[2:0] == HW_DF[2:0]));

  assign nxt_hw_flush_done = (tgu_valid & tgu_ready_i & data_nxt_state & ~tgu_packet_type[2] & tgu_fvalid_i & ~hw_flush_done_reg) |
                             (tgu_valid & tgu_ready_i & data_nxt_state &  tgu_packet_type[2] & ~tgu_to_flush & tgu_fvalid_i);
  assign hw_flush_done_we  = state_we | hw_flush_done_reg;

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      hw_flush_done_reg <= 1'b0;
    else if (hw_flush_done_we)
      hw_flush_done_reg <= nxt_hw_flush_done;
  end

  // Flush ready is set high when there is no historical data to output.
  // or TGU i/f is idle
  assign tgu_fready = ~tgu_valid | hw_flush_done_reg;

  // Triggers
  // Tirgger on "match using STMHETER"

  // The HETE trigger is output if:
  // 1. Triggers are enabled
  // 2. Trigger for event is enabled

  assign hw_triggerhete_en = ~hw_singleshot_i | (hw_singleshot_i & ~(trigouthete_reg | hw_trigstatushete_i));

  assign triggerhete       = |({STM_DATA_WIDTH{hw_triggerhete_en}} & HWEVENTS[STM_DATA_WIDTH-1:0] & events_mask[STM_DATA_WIDTH-1:0] & hw_heter_i[STM_DATA_WIDTH-1:0]);

  assign trigouthete_we    =  ~itctl_i | ittrigger_we_i;
  assign nxt_trigouthete   =  itctl_i ? pwdatadbg2_r_i :
                                        triggerhete;
  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      trigouthete_reg <= 1'b0;
    else if (trigouthete_we)
      trigouthete_reg <= nxt_trigouthete;
  end

  // Hardware frontend is busy when:
  // - FSM is busy
  // - there are captured events to be output
  // - in the cycle after hw_enable is removed because edge detection is done with deleyed hw_enable to allow clock gating
  assign hw_busy = (state_reg[2:0]!=HW_IDLE[2:0]) |
                   ~events_buf_empty              |
                   (~hw_enable_i & hw_enable_reg);

  //----------------------------------------------------------------------------
  // Output assignment
  //----------------------------------------------------------------------------
  // Trigger i/f
  assign triggerhete_o         = trigouthete_reg;
  assign TRIGOUTHETE           = trigouthete_reg;

  // TGU i/f
  assign tgu_valid_o                         = tgu_valid;
  assign tgu_master_o[7:0]                   = 8'h80;
  assign tgu_channel_o[15:0]                 = {16{1'b0}};
  assign tgu_payload_o[STM_DATA_WIDTH-1:0]   = tgu_payload[STM_DATA_WIDTH-1:0];
  assign tgu_size_o[(STM_DATA_WIDTH/32):0]   = tgu_size[(STM_DATA_WIDTH/32):0];
  assign tgu_packet_type_o[2:0]              = tgu_packet_type[2:0];
  assign tgu_ts_req_o[1:0]                   = tgu_ts_req[1:0];
  assign tgu_fready_o                        = tgu_fready;

  // Status interface
  assign hw_busy_o             = hw_busy;

`ifdef ARM_ASSERT_ON
  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"ts_flag should not be set when event buffer is empty")
    ovl_never_hwif_ts_flag_when_buffer_empty (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (events_buf_empty & ts_flag)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"event buffer should not be empty when new event is present")
    ovl_never_hwif_event_buf_empty_when_new_event (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (events_buf_empty & new_event)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"when transaction is accepted in FLAGTS state it cannot be historical data without timestamp")
    ovl_never_hwif_historical_data_without_timestamp (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr ((state_reg[2:0]==HW_FLAGTS[2:0]) & tgu_ready_i & ~new_event & ~events_buf_empty & ~ts_flag)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"when HW i/f is idle fready should be asserted")
    ovl_never_hwif_fready_when_idle (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (~tgu_valid & ~tgu_fready_o)
    );

  assert_next #(`OVL_FATAL,1,1,0,`OVL_ASSERT,"New events must not be accepted when authentication is removed")
    ovl_never_hwif_no_events_when_auth_removed (
      .clk         (clk_gated),
      .reset_n     (STMRESETn),
      .start_event (~dbgen_r_i & ~niden_r_i),
      .test_expr   (~new_event)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"when in D state ts_flag cannot be asserted without new_event")
    ovl_never_hwif_ts_flag_without_new_event (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr ((state_reg[2:0]==HW_D[2:0]) & ~new_event & ts_flag)
    );

  assert_next #(`OVL_FATAL,1,1,0,`OVL_ASSERT,"hw_flush_done_reg should be 1 clock cycle pulse")
    ovl_next_hwif_hw_flush_done_reg_1_cycle_pulse (
      .clk         (clk_gated),
      .reset_n     (STMRESETn),
      .start_event (hw_flush_done_reg),
      .test_expr   (~hw_flush_done_reg)
    );

  assert_next #(`OVL_FATAL,1,1,0,`OVL_ASSERT,"hw_busy should not be re-asserted after hw_enable goes low")
    ovl_next_hwif_hw_busy_when_enable_low (
      .clk         (clk_gated),
      .reset_n     (STMRESETn),
      .start_event (~hw_enable_i & ~hw_busy),
      .test_expr   (~hw_busy)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"TGU i/f tgu_ready should only be generated in response to tgu_valid")
    ovl_never_hwif_tgu_ready_in_response_to_valid (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (~tgu_valid & tgu_ready_i)
    );

  // X propagation
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "new_event is X")
    ovl_never_unknown_hwif_new_event (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (new_event)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "tgu_ready_i is X")
    ovl_never_unknown_hwif_tgu_ready_i (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (new_event)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "flush_ongoing is X")
    ovl_never_unknown_hwif_flush_ongoing (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (flush_ongoing)
    );

  assert_never_unknown #(`OVL_FATAL, 3, `OVL_ASSERT, "illegal nxt_state")
    ovl_never_unknown_hwif_nxt_state (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (nxt_state[2:0])
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "hw_enable_i is X")
    ovl_never_unknown_hwif_hw_enable_i (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (hw_enable_i)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "merr_we is X")
    ovl_never_unknown_hwif_merr_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (merr_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "ts_flag_we is X")
    ovl_never_unknown_hwif_ (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (ts_flag_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "state_we is X")
    ovl_never_unknown_hwif_state_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (state_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "tgu_toflush_we is X")
    ovl_never_unknown_hwif_tgu_toflush_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (tgu_toflush_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "hw_flush_done_we is X")
    ovl_never_unknown_hwif_hw_flush_done_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (hw_flush_done_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "trigouthete_we is X")
    ovl_never_unknown_hwif_trigouthete_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (trigouthete_we)
    );

  assert_never_unknown #(`OVL_FATAL, 3, `OVL_ASSERT, "state_reg is X")
    ovl_never_unknown_hwif_state_reg (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (state_reg)
    );

  assert_never_unknown #(`OVL_FATAL, 3, `OVL_ASSERT, "tgu_packet_type is X")
    ovl_never_unknown_hwif_tgu_packet_type (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (tgu_packet_type)
    );

  assert_never_unknown #(`OVL_FATAL, ((STM_DATA_WIDTH/32)+1), `OVL_ASSERT, "tgu_size is X")
    ovl_never_unknown_hwif_tgu_size (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (tgu_size)
    );

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "tgu_ts_req is X")
    ovl_never_unknown_hwif_tgu_ts_req (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (tgu_ts_req)
    );

`endif

endmodule // cxstm500_hweventif

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
//      RTL design for STM AXI Slave Interface for write transactions
//-----------------------------------------------------------------------------

module cxstm500_axislvif_write
#(
  parameter AXI_ID_WIDTH = 2,
  parameter STM_DATA_WIDTH = 64
  )
  (
  // Clock and Reset
  input wire                          CLK,                  // AXI Clock
  input wire                          ARESETn,              // AXI Reset
  // AMBA3 AXI Interface
  // AW channel
  input wire  [AXI_ID_WIDTH-1:0]      AWIDS,                // Write Address ID
  input wire                          AWVALIDS,             // Write Address Valid
  input wire  [31:0]                  AWADDRS,              // Write Address
  input wire  [2:0]                   AWSIZES,              // Write Size
  input wire  [7:0]                   AWLENS,               // Burst Length
  input wire  [1:0]                   AWBURSTS,             // Write Burst Type
  input wire  [2:0]                   AWPROTS,              // Write Authentication
  output wire                         AWREADYS,             // Write Address Ready
  // W channel
  input wire                          WVALIDS,              // Write Data Valid
  input wire [STM_DATA_WIDTH-1:0]     WDATAS,               // Write Data
  input wire [(STM_DATA_WIDTH/8)-1:0] WSTRBS,               // Write Strobes
  input wire                          WLASTS,               // Write Data Last
  output wire                         WREADYS,              // Write Data Ready
  // B channel
  input wire                          BREADYS,              // Write Response Ready
  output wire                         BVALIDS,              // Write Response Valid
  output wire [AXI_ID_WIDTH-1:0]      BIDS,                 // Write Response ID
  output wire [1:0]                   BRESPS,               // Write Response

  // TGU data interface
  input wire                          tgu_ready_i,          // TGU Transfer Ready
  input wire                          tgu_timestamped_i,    // Timestamp Indicator
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
  input wire                          axi_enable_i,         // STM Enable
  input wire  [31:0]                  axi_sper_i,           // SPER value
  input wire  [31:0]                  axi_spter_i,          // SPTER value
  input wire                          axi_singleshot_i,     // SPTE singleshot mode
  input wire                          axi_trigstatusspte_i, // SPTE trigger status in singleshot mode
  input wire  [11:0]                  axi_banksel_i,        // STMSPSCR.PORTSEL
  input wire  [1:0]                   axi_portctl_i,        // STMSPSCR.PORTCTL
  input wire  [7:0]                   axi_mastsel_i,        // STMSPMSCR.MASTSEL
  input wire                          axi_mastctl_i,        // STMSPMSCR.MASTCTL
  input wire  [16:0]                  axi_overportsel_i,    // STMSPOVERRIDER.PORTSEL
  input wire                          axi_overts_i,         // Timestamp Override
  input wire  [1:0]                   axi_overportctl_i,    // STMSPOVERRIDER.OVERCTL
  input wire  [7:0]                   axi_overmastsel_i,    // STMSPMOVERRIDER.MASTSEL
  input wire                          axi_overmastctl_i,    // STMSPMOVERRIDER.MASTCTL
  input wire                          axi_tsen_i,           // Timestamping Enable
  input wire                          axi_buf_clr_i,        // AXI Buffer Clear
  output wire                         axi_busy_q_channel_o, // Busy Status for Q Channel
  output wire                         axi_busy_stm_o,       // Busy Status for STM

  // Trigger Interface
  output wire                         triggerspte_o,        // Trigger, matches using STMSPTER
  output wire                         TRIGOUTSPTE,          // Trigger output event, matches using STMSPTER
  output wire                         triggersw_o,          // Trigger, writes to TRIG location
  output wire                         TRIGOUTSW,            // Trigger output event, writes to TRIG location

  // CoreSight Authentication Interface
  input wire                          dbgen_r_i,            // Debug Enable
  input wire                          niden_r_i,            // Non-invasive Debug Enable
  input wire                          spiden_r_i,           // Secure Debug Enable
  input wire                          spniden_r_i,          // Secure Non-invasive Debug Enable
  input wire                          nsguaren_r_i,         // Enable non-secure guaranteed stimulus port accesses

  // Integartion testing interface
  input wire                          itctl_i,              // integration mode
  input wire                          ittrigger_we_i,       // write to ITTRIGGER register
  input wire [1:0]                    pwdatadbg1_0_r_i,     // APB data 1:0

  input wire                          q_stop_i              // Q-Channel stopping
  );

  //---------------------------------------------------------------------------
  // Constant definitions
  //---------------------------------------------------------------------------
  localparam  AXI_RESP_OKAY    = 2'b00;           // AXI OKAY response
  localparam  AXI_ASIZE_8      = 2'b00;           // AXI 8-bit transfer
  localparam  AXI_ASIZE_16     = 2'b01;           // AXI 16-bit transfer
  localparam  AXI_ASIZE_32     = 2'b10;           // AXI 32-bit transfer
  localparam  AXI_ASIZE_64     = 2'b11;           // AXI 64-bit transfer
  localparam  AXI_ABURST_FIXED = 2'b00;           // AXI FIXED burst
  localparam  AXI_ABURST_WRAP  = 2'b10;           // AXI WRAP burst

  localparam  TGU_DATAM        = 3'b000;             // TGU DxM packet type
  localparam  TGU_DATA         = 3'b010;             // TGU Dx packet type
  localparam  TGU_FLAG         = 3'b100;             // TGU FLAG packet type
  localparam  TGU_TRIG         = 3'b101;             // TGU TRIG packet type
  localparam  TGU_MERR         = 3'b110;             // TGU MERR packet type
  localparam  TGU_GERR         = 3'b111;             // TGU GERR packet type

  localparam  TGU_SIZE_BYTE    = 3'b001;             // TGU size is 8 bits
  localparam  TGU_SIZE_HWORD   = 3'b010;             // TGU size is 16 bits
  localparam  TGU_SIZE_WORD    = 3'b011;             // TGU size is 32 bits
  localparam  TGU_SIZE_DWORD   = 3'b100;             // TGU size is 64 bits

  localparam  ERR_NONE         = 2'b00;              // No error pending
  localparam  ERR_MERR         = 2'b01;              // MERR pending
  localparam  ERR_GERR         = 2'b10;              // GERR pending

  //---------------------------------------------------------------------------
  // Wires
  //---------------------------------------------------------------------------
  wire                    address_load;
  wire [2:0]              addr_buf_mux_ctrl;
  wire [2:0]              addr_skid_mux_ctrl;
  wire [11:0]             nxt_burst_addr;
  wire [11:0]             offset_addr;
  wire [11:0]             incr_addr;
  wire [11:0]             wrap_addr;
  wire [11:0]             mux_addr;
  wire [11:0]             calc_addr;
  wire [29:0]             nxt_awaddr_buf;
  wire [1:0]              nxt_awburst_buf;
  wire                    nxt_awprot_buf;
  wire [1:0]              nxt_awsize_buf;
  wire [3:0]              nxt_awlen_buf;
  wire [29:3]             nxt_awaddr_skid;
  wire [1:0]              nxt_awburst_skid;
  wire                    nxt_awprot_skid;
  wire [1:0]              nxt_awsize_skid;
  wire [3:0]              nxt_awlen_skid;
  wire                    addr_buf_we;
  wire                    addr_skid_we;
  wire                    addr_second_skid_we;
  wire                    nxt_addr_buf_valid;
  wire                    nxt_addr_skid_valid;
  wire                    nxt_addr_second_skid_valid;
  wire                    addr_valid;
  wire                    nxt_awready;
  wire                    nxt_wready;
  wire                    wready;

  wire                    tgu_buf_rdy;

  wire                    data_valid;
  wire                    data_beat;
  wire                    last_data_beat;
  wire                    valid_wstrbs;

  wire [AXI_ID_WIDTH-1:0] nxt_bid;
  wire [AXI_ID_WIDTH-1:0] nxt_bid_buf;
  wire                    bid_we;
  wire                    bid_buf_we;
  wire                    bid_skid_we;
  wire                    nxt_bid_valid;
  wire                    nxt_bid_buf_valid;
  wire                    nxt_bid_skid_valid;
  wire                    nxt_wdata_valid;
  wire                    nxt_wdata_buf_valid;
  wire                    nxt_wdata_skid_valid;
  wire                    nxt_bvalid;
  wire                    bid_ready;

  wire [31:0]             sp_onehot_if;
  wire [31:0]             sp_onehot_buf;
  wire [31:0]             sp_onehot_agu;
  wire [31:0]             sp_onehot_skid;
  wire [6:0]              master_id_if;
  wire [6:0]              master_id_buf;
  wire [6:0]              master_id_skid;
  wire [6:0]              master_id_enabled;
  wire [6:0]              mastsel_mask;
  wire [10:0]             banksel_mask;
  wire [10:0]             bank_enabled;
  wire                    sp_selected_if;
  wire                    sp_selected_buf;
  wire                    sp_selected_agu;
  wire                    sp_selected_skid;
  wire                    sp_selected_int;
  wire                    sp_selected;
  wire                    mast_selected_if;
  wire                    mast_selected_buf;
  wire                    mast_selected_skid;
  wire                    bank_selected_if;
  wire                    bank_selected_buf;
  wire                    bank_selected_skid;
  wire [6:0]              mast_overridesel_mask;
  wire [6:0]              mast_override_enabled;
  wire [15:0]             bank_overridesel_mask;
  wire [15:0]             bank_override_enabled;
  wire                    mast_override_sel_if;
  wire                    mast_override_sel_buf;
  wire                    mast_override_sel_skid;
  wire                    bank_override_sel_if;
  wire                    bank_override_sel_buf;
  wire                    bank_override_sel_agu;
  wire                    bank_override_sel_skid;
  wire                    sp_override_sel_if;
  wire                    sp_override_sel_buf;
  wire                    sp_override_sel_agu;
  wire                    sp_override_sel_skid;
  wire                    sp_en_mask_if;
  wire                    sp_en_mask_buf;
  wire                    sp_en_mask_agu;
  wire                    sp_en_mask_skid;
  wire                    sp_en_mask_int;
  wire                    sp_en_mask;
  wire                    sp_enabled;
  wire                    guaranteed_if;
  wire                    guaranteed_buf;
  wire                    guaranteed_agu;
  wire                    guaranteed_skid;
  wire                    guaranteed_int;
  wire                    guaranteed;
  wire                    trig_enabled_if;
  wire                    trig_enabled_buf;
  wire                    trig_enabled_agu;
  wire                    trig_enabled_skid;
  wire                    trig_selected_if;
  wire                    trig_selected_buf;
  wire                    trig_selected_agu;
  wire                    trig_selected_skid;
  wire                    trig_enabled_int;
  wire                    trig_enabled;

  wire [6:0]                                       axi_tgu_master;
  wire [15:0]                                      axi_tgu_channel;
  wire [STM_DATA_WIDTH-1:0]                        axi_tgu_payload;
  wire [2:0]                                       axi_tgu_packet_type;
  wire [1:0]                                       axi_tgu_ts_req;
  wire [(STM_DATA_WIDTH/32):0]                     axi_tgu_size;
  wire [(STM_DATA_WIDTH+(STM_DATA_WIDTH/32)+28):0] axi_tgu_transfer;
  wire [(STM_DATA_WIDTH+(STM_DATA_WIDTH/32)+28):0] nxt_tgu_transfer;

  wire                    skid_load;
  wire                    skid_valid_clear;
  wire                    tgu_data_source;
  wire                    tgu_load;
  wire                    tgu_valid_clear;
  wire                    nxt_tgu_valid;
  wire                    tgu_valid_we;
  wire                    nxt_tgu_skid_valid;
  wire                    tgu_skid_we;

  wire                    data_dropped;
  wire                    tgu_load_err;
  wire [1:0]              nxt_err_pending;
  wire                    err_pending_we;
  wire [1:0]              nxt_tgu_err;
  wire                    tgu_err_we;

  wire                    axi_triggerspte_en;
  wire                    triggerspte;
  wire                    trigoutspte_we;
  wire                    nxt_trigoutspte;
  wire                    triggersw;
  wire                    trigoutsw_we;
  wire                    nxt_trigoutsw;

  wire                    axi_busy_q_channel;
  wire                    axi_busy_stm;
  wire                    q_stopped_int;

  wire                    axi_flush;
  wire                    nxt_tgu_toflush;
  wire                    tgu_toflush_we;
  wire                    nxt_tgu_skid_toflush;
  wire                    tgu_skid_toflush_we;
  wire                    nxt_tgu_fready;
  wire                    tgu_fready_we;

  wire [2:0]              decode_mux_ctrl;
  wire                    decode_if_sel;

  wire                    sec_invasive;
  wire                    nsec_invasive;
  wire                    sec_noninvasive;
  wire                    nsec_noninvasive;

  //---------------------------------------------------------------------------
  // Registers
  //---------------------------------------------------------------------------
  reg [29:0]              awaddr_buf_reg;
  reg [1:0]               awburst_buf_reg;
  reg                     awprot_buf_reg;
  reg [1:0]               awsize_buf_reg;
  reg [3:0]               awlen_buf_reg;
  reg [29:3]              awaddr_skid_reg;
  reg [1:0]               awburst_skid_reg;
  reg                     awprot_skid_reg;
  reg [1:0]               awsize_skid_reg;
  reg [3:0]               awlen_skid_reg;
  reg [29:3]              awaddr_second_skid_reg;
  reg [1:0]               awburst_second_skid_reg;
  reg                     awprot_second_skid_reg;
  reg [1:0]               awsize_second_skid_reg;
  reg [3:0]               awlen_second_skid_reg;
  reg                     awready_reg;
  reg                         wready_reg;
  reg                         bvalid_reg;
  reg [AXI_ID_WIDTH-1:0]      bid_reg;
  reg                         bid_valid_reg;
  reg                         bid_buf_valid_reg;
  reg                         bid_skid_valid_reg;
  reg                         wdata_valid_reg;
  reg                         wdata_buf_valid_reg;
  reg                         wdata_skid_valid_reg;
  reg [AXI_ID_WIDTH-1:0]      bid_buf_reg;
  reg [AXI_ID_WIDTH-1:0]      bid_skid_reg;
  reg                         addr_buf_valid_reg;
  reg                         addr_skid_valid_reg;
  reg                         addr_second_skid_valid_reg;
  reg                         sp_en_mask_reg;
  reg                         sp_selected_reg;
  reg                         guaranteed_reg;
  reg                         trig_enabled_reg;
  reg                         tgu_valid_reg;
  reg                         tgu_skid_valid_reg;

  reg [(STM_DATA_WIDTH+(STM_DATA_WIDTH/32)+28):0] tgu_transfer_reg;
  reg [(STM_DATA_WIDTH+(STM_DATA_WIDTH/32)+28):0] tgu_transfer_skid_reg;

  reg [1:0]                   err_pending_reg;
  reg [1:0]                   tgu_err_reg;
  reg [6:0]                   merr_master_pend_reg;
  reg [6:0]                   merr_master_reg;
  reg                         trigoutspte_reg;
  reg                         trigoutsw_reg;
  reg                         tgu_toflush_reg;
  reg                         tgu_skid_toflush_reg;
  reg                         tgu_fvalid_reg;
  reg                         tgu_fready_reg;

  //---------------------------------------------------------------------------
  //
  // Main body of code
  // =================
  //
  //---------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  // Q-Channel behaviour
  //---------------------------------------------------------------------------

  // AXI busy is reported to Q-Channel controller when:
  // 1. There is TGU transfer ongoing
  // 2. There is a pending Write Response on the B Channel
  // 3. There is an ongoing AW transaction

  assign axi_busy_q_channel =  tgu_valid_reg | bid_valid_reg | (AWVALIDS & awready_reg);

  //When q_channel wants to accept a response it asserts q_channel_i
  //This signal must be masked if the AXI is active to prevent protocol
  //violations on the interface when a new transactions arrives at the same
  //time as the q-channel request
  assign q_stopped_int = q_stop_i & ~axi_busy_q_channel;

  //---------------------------------------------------------------------------
  // Address Calculation
  //---------------------------------------------------------------------------

  // Authentication signals decode
  // Table 9-2 and Table 3-7 CoreSight Architecture
  assign sec_invasive     = spiden_r_i & dbgen_r_i;
  assign nsec_invasive    = dbgen_r_i;
  assign sec_noninvasive  = (spniden_r_i | spiden_r_i) & (niden_r_i | dbgen_r_i);
  assign nsec_noninvasive = niden_r_i | dbgen_r_i;

  // Address Channel
  assign address_load = AWVALIDS & awready_reg;

  //-----------------------------------------------------------------------------------------------------
  //  Address Buffer
  //-----------------------------------------------------------------------------------------------------

  // Address and burst buffer mux
  // [2] : address taken from skid buffer
  // [1] : address taken from addr buffer
  // [0] : address taken from AW interface
  // In case of incrementing burst the incremented address is written back to addr buffer
  assign addr_buf_mux_ctrl[2:0] = {( last_data_beat & addr_skid_valid_reg),
                                   (~last_data_beat & data_beat),
                                   ((last_data_beat | ~addr_buf_valid_reg) & ~addr_skid_valid_reg)};

  // In case of INCR burst address is incremented by 1, 2, 4 or 8 depending on transfer size
  // offset_addr indicates the address bits of interest, depending on AWSIZE
  assign offset_addr[11:0] = ({12{(awsize_buf_reg[1:0] == AXI_ASIZE_8)}}  & awaddr_buf_reg[11:0])          |
                             ({12{(awsize_buf_reg[1:0] == AXI_ASIZE_16)}} & {1'b0, awaddr_buf_reg[11:1]})  |
                             ({12{(awsize_buf_reg[1:0] == AXI_ASIZE_32)}} & {2'b00, awaddr_buf_reg[11:2]}) |
                             ({12{(awsize_buf_reg[1:0] == AXI_ASIZE_64)}} & {3'b000, awaddr_buf_reg[11:3]});

  // INCR burst crossing 4Kb pages are not allowed by AXI, so only 12 bits are used
  // in address increment, carry (bit 12) is ignored.
  assign incr_addr[11:0] = offset_addr[11:0] + {{11{1'b0}}, 1'b1};

  //  Address wrapping
  //  The address of the next transfer should wrap on the next transfer if the
  //  boundary is reached.
  //  Upper bits of wrapped address remain static
  assign wrap_addr[11:4] = offset_addr[11:4];

  // Wrap lower bits according to length of burst
  assign wrap_addr[3:0]  = (awlen_buf_reg[3:0] & incr_addr[3:0]) | (~awlen_buf_reg[3:0] & offset_addr[3:0]);

  assign mux_addr[11:0]  = (awburst_buf_reg[1:0] == AXI_ABURST_WRAP) ? wrap_addr[11:0] : incr_addr[11:0];

  assign calc_addr[11:0] = ({12{(awsize_buf_reg[1:0] == AXI_ASIZE_8)}}  & mux_addr[11:0])         |
                           ({12{(awsize_buf_reg[1:0] == AXI_ASIZE_16)}} & {mux_addr[10:0], 1'b0}) |
                           ({12{(awsize_buf_reg[1:0] == AXI_ASIZE_32)}} & {mux_addr[9:0], 2'b00}) |
                           ({12{(awsize_buf_reg[1:0] == AXI_ASIZE_64)}} & {mux_addr[8:0], 3'b000});

  // Address is not incremented for FIXED burst
  assign nxt_burst_addr[11:0]  = (awburst_buf_reg[1:0] == AXI_ABURST_FIXED) ? awaddr_buf_reg[11:0] : calc_addr[11:0];

  // Address buffer muxing
  // Address alignment is forced to 64-bit, 3 LSB are zeroed
  assign nxt_awaddr_buf[29:0] = ({30{addr_buf_mux_ctrl[2]}} & {awaddr_skid_reg[29:3], 3'b000})               |
                                ({30{addr_buf_mux_ctrl[1]}} & {awaddr_buf_reg[29:12], nxt_burst_addr[11:0]}) |
                                ({30{addr_buf_mux_ctrl[0]}} & {AWADDRS[29:3], 3'b000});

  assign nxt_awburst_buf[1:0] = ({2{addr_buf_mux_ctrl[2]}} & awburst_skid_reg[1:0]) |
                                ({2{addr_buf_mux_ctrl[1]}} & awburst_buf_reg[1:0])  |
                                ({2{addr_buf_mux_ctrl[0]}} & AWBURSTS[1:0]);

  assign nxt_awprot_buf       = (addr_buf_mux_ctrl[2] & awprot_skid_reg) |
                                (addr_buf_mux_ctrl[1] & awprot_buf_reg)  |
                                (addr_buf_mux_ctrl[0] & AWPROTS[1]);

  assign nxt_awsize_buf[1:0]  = ({2{addr_buf_mux_ctrl[2]}} & awsize_skid_reg[1:0]) |
                                ({2{addr_buf_mux_ctrl[1]}} & awsize_buf_reg[1:0])  |
                                ({2{addr_buf_mux_ctrl[0]}} & AWSIZES[1:0]);

  //AWLEN is registered for calculating wrapping bursts - only bits [3:0] are required
  //since AWLEN is <16 for wrapping bursts
  assign nxt_awlen_buf[3:0]  = ({4{addr_buf_mux_ctrl[2]}} & awlen_skid_reg[3:0]) |
                               ({4{addr_buf_mux_ctrl[1]}} & awlen_buf_reg[3:0])  |
                               ({4{addr_buf_mux_ctrl[0]}} & AWLENS[3:0]);

  // Address buffer is loaded if:
  // - buffer is empty and AXI address is present
  // - on each data beat
  // - on last data beat if addr skid buf is full
  // - on last data beat if there is a new AW transaction and skid buffer is empty
  assign addr_buf_we = (~addr_buf_valid_reg & AWVALIDS) |
                       (data_beat & ~WLASTS) |
                       (last_data_beat & addr_skid_valid_reg) |
                       (last_data_beat & ~addr_skid_valid_reg & AWVALIDS);

  // Registered address buffer
  always @(posedge CLK)
  begin
    if (addr_buf_we)
    begin
      awaddr_buf_reg[29:0]     <= nxt_awaddr_buf[29:0];
      awburst_buf_reg[1:0]     <= nxt_awburst_buf[1:0];
      awprot_buf_reg           <= nxt_awprot_buf;
      awsize_buf_reg[1:0]      <= nxt_awsize_buf[1:0];
      awlen_buf_reg[3:0]       <= nxt_awlen_buf[3:0];
    end
  end

  // Address buffer valid is set:
  // - when new address is loaded either from AXI interface or from skid buffer
  // Address buffer valid is cleared:
  // - on last data beat if there is no new address from AXI interface or skid buffer
  assign nxt_addr_buf_valid = address_load        |
                              addr_skid_valid_reg |
                              (~last_data_beat & addr_buf_valid_reg);

  // Registered address valid
  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      addr_buf_valid_reg <= 1'b0;
    else
      addr_buf_valid_reg <= nxt_addr_buf_valid;
  end

  //-----------------------------------------------------------------------------------------------------
  //  Address Skid Buffer
  //-----------------------------------------------------------------------------------------------------

  // Address and burst buffer mux
  // [2] : address taken from second skid buffer
  // [1] : address taken from skid buffer
  // [0] : address taken from AW interface
  // In case of incrementing burst the incremented address is written back to addr buffer
  assign addr_skid_mux_ctrl[2:0] = {(last_data_beat & addr_second_skid_valid_reg),
                                   (~last_data_beat & data_beat & addr_skid_valid_reg),
                                   ((last_data_beat | ~addr_skid_valid_reg) & ~addr_second_skid_valid_reg)};

  // Address skid buffer muxing
  // Address alignment is forced to 64-bit, 3 LSB are zeroed
  assign nxt_awaddr_skid[29:3] = ({27{addr_skid_mux_ctrl[2]}} & awaddr_second_skid_reg[29:3]) |
                                 ({27{addr_skid_mux_ctrl[1]}} & awaddr_skid_reg[29:3]) |
                                 ({27{addr_skid_mux_ctrl[0]}} & AWADDRS[29:3]);

  assign nxt_awburst_skid[1:0] = ({2{addr_skid_mux_ctrl[2]}} & awburst_second_skid_reg[1:0]) |
                                 ({2{addr_skid_mux_ctrl[1]}} & awburst_skid_reg[1:0])  |
                                 ({2{addr_skid_mux_ctrl[0]}} & AWBURSTS[1:0]);

  assign nxt_awprot_skid       = (addr_skid_mux_ctrl[2] & awprot_second_skid_reg) |
                                 (addr_skid_mux_ctrl[1] & awprot_skid_reg)  |
                                 (addr_skid_mux_ctrl[0] & AWPROTS[1]);

  assign nxt_awsize_skid[1:0]  = ({2{addr_skid_mux_ctrl[2]}} & awsize_second_skid_reg[1:0]) |
                                 ({2{addr_skid_mux_ctrl[1]}} & awsize_skid_reg[1:0])  |
                                 ({2{addr_skid_mux_ctrl[0]}} & AWSIZES[1:0]);

  //AWLEN is registered for calculating wrapping bursts - only bits [3:0] are required
  //since AWLEN is <16 for wrapping bursts
  assign nxt_awlen_skid[3:0]  = ({4{addr_skid_mux_ctrl[2]}} & awlen_second_skid_reg[3:0]) |
                                ({4{addr_skid_mux_ctrl[1]}} & awlen_skid_reg[3:0])  |
                                ({4{addr_skid_mux_ctrl[0]}} & AWLENS[3:0]);


  // Address skid buffer is loaded if:
  // - skid buffer is empty and AXI address is present, when main buffer is full and not last data beat
  // - on last data beat if second skid buffer is full
  // - on last data beat if there is a new AW transaction and second skid buffer is empty
  assign addr_skid_we = (address_load & ~last_data_beat &  addr_buf_valid_reg         & ~addr_skid_valid_reg) |
                        (                last_data_beat &  addr_second_skid_valid_reg                       ) |
                        (address_load &  last_data_beat & ~addr_second_skid_valid_reg                       );

  always @(posedge CLK)
  begin
    if (addr_skid_we)
    begin
      awaddr_skid_reg[29:3]     <= nxt_awaddr_skid[29:3];
      awburst_skid_reg[1:0]     <= nxt_awburst_skid[1:0];
      awprot_skid_reg           <= nxt_awprot_skid;
      awsize_skid_reg[1:0]      <= nxt_awsize_skid[1:0];
      awlen_skid_reg[3:0]       <= nxt_awlen_skid[3:0];
    end
  end

  // Address skid buffer valid is set:
  // - when new address cannot be loaded to address buffer
  // - when second skid buffer is valid
  // - when skid buffer is already valid and not seen last_data_beat
  // Address skid buffer valid is cleared:
  // - on last data beat if there is no new address from AXI interface or second skid buffer
  assign nxt_addr_skid_valid = ( address_load & ~last_data_beat & addr_buf_valid_reg) |
                               ( address_load &  last_data_beat & addr_skid_valid_reg) |
                               ( addr_second_skid_valid_reg) |
                               (~last_data_beat & addr_skid_valid_reg);


  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      addr_skid_valid_reg <= 1'b0;
    else
      addr_skid_valid_reg <= nxt_addr_skid_valid;
  end

  //-----------------------------------------------------------------------------------------------------
  //  Address Second Skid Buffer
  //-----------------------------------------------------------------------------------------------------

  // Address second skid buffer
  // Second skid buffer is loaded with address from AXI interface in case address buffer and
  // skid buffer cannot take the address
  assign addr_second_skid_we = address_load & ~last_data_beat & addr_skid_valid_reg;
  always @(posedge CLK)
  begin
    if (addr_second_skid_we)
    begin
      awaddr_second_skid_reg[29:3]     <= AWADDRS[29:3];
      awburst_second_skid_reg[1:0]     <= AWBURSTS[1:0];
      awprot_second_skid_reg           <= AWPROTS[1];
      awsize_second_skid_reg[1:0]      <= AWSIZES[1:0];
      awlen_second_skid_reg[3:0]       <= AWLENS[3:0];
    end
  end

  // Address second skid buffer valid is set:
  // - when new address cannot be loaded to address buffer or skid buffer
  // - when second skid buffer is already valid and not seen last_data_beat
  // Address second skid buffer valid is cleared:
  // - on last data beat if there is no new address from AXI interface
  assign nxt_addr_second_skid_valid = ( address_load & ~last_data_beat & addr_skid_valid_reg) |
                                      (~last_data_beat & addr_second_skid_valid_reg);

  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      addr_second_skid_valid_reg <= 1'b0;
    else
      addr_second_skid_valid_reg <= nxt_addr_second_skid_valid;
  end

  //-----------------------------------------------------------------------------------------------------
  //  Address Acceptance
  //-----------------------------------------------------------------------------------------------------

  // AXI slave is ready to accept new address when:
  // - there's at least one space in the BID buffers,
  //   or the BID buffer is full with BVALID and BREADY set
  // - Q-channel is not in q_stopped state

  // PLA table sent to espresso
  //  .i 7
  //  .o 1
  //  .ilb bid_valid_reg bid_buf_valid_reg bid_skid_valid_reg address_load BREADYS bvalid_reg q_stopped_int
  //  .ob nxt_awready
  //# bid_valid_reg
  //# | bid_buf_valid_reg
  //# | | bid_skid_valid_reg
  //# | | | address_load
  //# | | | | BREADYS
  //# | | | | | bvalid_reg
  //# | | | | | | q_stopped_int
  //# | | | | | | |
  //# | | | | | | |   nxt_awready
  //# | | | | | | |   |
  //  0 - - - - - 0   1
  //  1 0 - - - - 0   1
  //  1 1 0 0 - - 0   1
  //  1 1 0 1 0 0 -   0
  //  1 1 0 1 0 1 -   0
  //  1 1 0 1 1 0 -   0
  //  1 1 0 1 1 1 0   1
  //  1 1 1 0 0 0 -   0
  //  1 1 1 0 0 1 -   0
  //  1 1 1 0 1 0 -   0
  //  1 1 1 0 1 1 0   1
  //  - - - - - - 1   0
  //# Illegal Cases
  //  1 1 1 1 - - -   -
  //  .e
  // espresso output
  // DO NOT MODIFY BY HAND
  assign nxt_awready = (BREADYS&bvalid_reg&!q_stopped_int) | (!bid_skid_valid_reg
    &!address_load&!q_stopped_int) | (!bid_buf_valid_reg&!q_stopped_int) | (
    !bid_valid_reg&!q_stopped_int);

  // end of espresso output

  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      awready_reg <= 1'b0;
    else
      awready_reg <= nxt_awready;
  end

  // Address valid for puprose of WREADY generation.
  // Address is valid if:
  // - valid on AXI i/f
  // - there's an address in address buffer and it's not the last accepted data beat or there's a new address in skid buffer
  assign addr_valid = (address_load | (addr_buf_valid_reg & (~last_data_beat | addr_skid_valid_reg)));

  assign decode_mux_ctrl[2:0] = {~last_data_beat & ~data_beat,
                                 ~last_data_beat &  data_beat,
                                  last_data_beat};

  assign decode_if_sel = ~addr_buf_valid_reg | (last_data_beat & ~addr_skid_valid_reg);

  // Address decode
  // Address Upper Bits Mask Generation
  // Master
  assign mastsel_mask[6:0]  =  {|axi_mastsel_i[6:0],  // bit 6
                                |axi_mastsel_i[5:0],  // bit 5
                                |axi_mastsel_i[4:0],  // bit 4
                                |axi_mastsel_i[3:0],  // bit 3
                                |axi_mastsel_i[2:0],  // bit 2
                                |axi_mastsel_i[1:0],  // bit 1
                                 axi_mastsel_i[0]};   // bit 0
  // Stimulus port bank
  assign banksel_mask[10:0] =  {|axi_banksel_i[10:0], // bit 10
                                |axi_banksel_i[ 9:0], // bit 9
                                |axi_banksel_i[ 8:0], // bit 8
                                |axi_banksel_i[ 7:0], // bit 7
                                |axi_banksel_i[ 6:0], // bit 6
                                |axi_banksel_i[ 5:0], // bit 5
                                |axi_banksel_i[ 4:0], // bit 4
                                |axi_banksel_i[ 3:0], // bit 3
                                |axi_banksel_i[ 2:0], // bit 2
                                |axi_banksel_i[ 1:0], // bit 1
                                 axi_banksel_i[0]};   // bit 0

  // One-hot encoding of Stimulus Port (within group of 32 sp)
  // Address from AXI interface
  assign sp_onehot_if[31:0] = {(AWADDRS[12:8] == 5'b11111),  // bit 31
                               (AWADDRS[12:8] == 5'b11110),  // bit 30
                               (AWADDRS[12:8] == 5'b11101),  // bit 29
                               (AWADDRS[12:8] == 5'b11100),  // bit 28
                               (AWADDRS[12:8] == 5'b11011),  // bit 27
                               (AWADDRS[12:8] == 5'b11010),  // bit 26
                               (AWADDRS[12:8] == 5'b11001),  // bit 25
                               (AWADDRS[12:8] == 5'b11000),  // bit 24
                               (AWADDRS[12:8] == 5'b10111),  // bit 23
                               (AWADDRS[12:8] == 5'b10110),  // bit 22
                               (AWADDRS[12:8] == 5'b10101),  // bit 21
                               (AWADDRS[12:8] == 5'b10100),  // bit 20
                               (AWADDRS[12:8] == 5'b10011),  // bit 19
                               (AWADDRS[12:8] == 5'b10010),  // bit 18
                               (AWADDRS[12:8] == 5'b10001),  // bit 17
                               (AWADDRS[12:8] == 5'b10000),  // bit 16
                               (AWADDRS[12:8] == 5'b01111),  // bit 15
                               (AWADDRS[12:8] == 5'b01110),  // bit 14
                               (AWADDRS[12:8] == 5'b01101),  // bit 13
                               (AWADDRS[12:8] == 5'b01100),  // bit 12
                               (AWADDRS[12:8] == 5'b01011),  // bit 11
                               (AWADDRS[12:8] == 5'b01010),  // bit 10
                               (AWADDRS[12:8] == 5'b01001),  // bit 9
                               (AWADDRS[12:8] == 5'b01000),  // bit 8
                               (AWADDRS[12:8] == 5'b00111),  // bit 7
                               (AWADDRS[12:8] == 5'b00110),  // bit 6
                               (AWADDRS[12:8] == 5'b00101),  // bit 5
                               (AWADDRS[12:8] == 5'b00100),  // bit 4
                               (AWADDRS[12:8] == 5'b00011),  // bit 3
                               (AWADDRS[12:8] == 5'b00010),  // bit 2
                               (AWADDRS[12:8] == 5'b00001),  // bit 1
                               (AWADDRS[12:8] == 5'b00000)}; // bit 0

  assign sp_selected_if = |(axi_sper_i[31:0] & sp_onehot_if[31:0]);

  // Address from address buffer
  assign sp_onehot_buf[31:0] = {(awaddr_buf_reg[12:8] == 5'b11111),  // bit 31
                                (awaddr_buf_reg[12:8] == 5'b11110),  // bit 30
                                (awaddr_buf_reg[12:8] == 5'b11101),  // bit 29
                                (awaddr_buf_reg[12:8] == 5'b11100),  // bit 28
                                (awaddr_buf_reg[12:8] == 5'b11011),  // bit 27
                                (awaddr_buf_reg[12:8] == 5'b11010),  // bit 26
                                (awaddr_buf_reg[12:8] == 5'b11001),  // bit 25
                                (awaddr_buf_reg[12:8] == 5'b11000),  // bit 24
                                (awaddr_buf_reg[12:8] == 5'b10111),  // bit 23
                                (awaddr_buf_reg[12:8] == 5'b10110),  // bit 22
                                (awaddr_buf_reg[12:8] == 5'b10101),  // bit 21
                                (awaddr_buf_reg[12:8] == 5'b10100),  // bit 20
                                (awaddr_buf_reg[12:8] == 5'b10011),  // bit 19
                                (awaddr_buf_reg[12:8] == 5'b10010),  // bit 18
                                (awaddr_buf_reg[12:8] == 5'b10001),  // bit 17
                                (awaddr_buf_reg[12:8] == 5'b10000),  // bit 16
                                (awaddr_buf_reg[12:8] == 5'b01111),  // bit 15
                                (awaddr_buf_reg[12:8] == 5'b01110),  // bit 14
                                (awaddr_buf_reg[12:8] == 5'b01101),  // bit 13
                                (awaddr_buf_reg[12:8] == 5'b01100),  // bit 12
                                (awaddr_buf_reg[12:8] == 5'b01011),  // bit 11
                                (awaddr_buf_reg[12:8] == 5'b01010),  // bit 10
                                (awaddr_buf_reg[12:8] == 5'b01001),  // bit 9
                                (awaddr_buf_reg[12:8] == 5'b01000),  // bit 8
                                (awaddr_buf_reg[12:8] == 5'b00111),  // bit 7
                                (awaddr_buf_reg[12:8] == 5'b00110),  // bit 6
                                (awaddr_buf_reg[12:8] == 5'b00101),  // bit 5
                                (awaddr_buf_reg[12:8] == 5'b00100),  // bit 4
                                (awaddr_buf_reg[12:8] == 5'b00011),  // bit 3
                                (awaddr_buf_reg[12:8] == 5'b00010),  // bit 2
                                (awaddr_buf_reg[12:8] == 5'b00001),  // bit 1
                                (awaddr_buf_reg[12:8] == 5'b00000)}; // bit 0

  assign sp_selected_buf = |(axi_sper_i[31:0] & sp_onehot_buf[31:0]);

  // Address from address generation
  assign sp_onehot_agu[31:0] = {({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b11111),  // bit 31
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b11110),  // bit 30
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b11101),  // bit 29
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b11100),  // bit 28
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b11011),  // bit 27
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b11010),  // bit 26
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b11001),  // bit 25
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b11000),  // bit 24
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b10111),  // bit 23
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b10110),  // bit 22
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b10101),  // bit 21
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b10100),  // bit 20
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b10011),  // bit 19
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b10010),  // bit 18
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b10001),  // bit 17
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b10000),  // bit 16
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b01111),  // bit 15
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b01110),  // bit 14
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b01101),  // bit 13
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b01100),  // bit 12
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b01011),  // bit 11
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b01010),  // bit 10
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b01001),  // bit 9
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b01000),  // bit 8
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b00111),  // bit 7
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b00110),  // bit 6
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b00101),  // bit 5
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b00100),  // bit 4
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b00011),  // bit 3
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b00010),  // bit 2
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b00001),  // bit 1
                                ({awaddr_buf_reg[12], nxt_burst_addr[11:8]} == 5'b00000)}; // bit 0

  assign sp_selected_agu = |(axi_sper_i[31:0] & sp_onehot_agu[31:0]);

  // Address from skid buffer
  assign sp_onehot_skid[31:0] = {(awaddr_skid_reg[12:8] == 5'b11111),  // bit 31
                                 (awaddr_skid_reg[12:8] == 5'b11110),  // bit 30
                                 (awaddr_skid_reg[12:8] == 5'b11101),  // bit 29
                                 (awaddr_skid_reg[12:8] == 5'b11100),  // bit 28
                                 (awaddr_skid_reg[12:8] == 5'b11011),  // bit 27
                                 (awaddr_skid_reg[12:8] == 5'b11010),  // bit 26
                                 (awaddr_skid_reg[12:8] == 5'b11001),  // bit 25
                                 (awaddr_skid_reg[12:8] == 5'b11000),  // bit 24
                                 (awaddr_skid_reg[12:8] == 5'b10111),  // bit 23
                                 (awaddr_skid_reg[12:8] == 5'b10110),  // bit 22
                                 (awaddr_skid_reg[12:8] == 5'b10101),  // bit 21
                                 (awaddr_skid_reg[12:8] == 5'b10100),  // bit 20
                                 (awaddr_skid_reg[12:8] == 5'b10011),  // bit 19
                                 (awaddr_skid_reg[12:8] == 5'b10010),  // bit 18
                                 (awaddr_skid_reg[12:8] == 5'b10001),  // bit 17
                                 (awaddr_skid_reg[12:8] == 5'b10000),  // bit 16
                                 (awaddr_skid_reg[12:8] == 5'b01111),  // bit 15
                                 (awaddr_skid_reg[12:8] == 5'b01110),  // bit 14
                                 (awaddr_skid_reg[12:8] == 5'b01101),  // bit 13
                                 (awaddr_skid_reg[12:8] == 5'b01100),  // bit 12
                                 (awaddr_skid_reg[12:8] == 5'b01011),  // bit 11
                                 (awaddr_skid_reg[12:8] == 5'b01010),  // bit 10
                                 (awaddr_skid_reg[12:8] == 5'b01001),  // bit 9
                                 (awaddr_skid_reg[12:8] == 5'b01000),  // bit 8
                                 (awaddr_skid_reg[12:8] == 5'b00111),  // bit 7
                                 (awaddr_skid_reg[12:8] == 5'b00110),  // bit 6
                                 (awaddr_skid_reg[12:8] == 5'b00101),  // bit 5
                                 (awaddr_skid_reg[12:8] == 5'b00100),  // bit 4
                                 (awaddr_skid_reg[12:8] == 5'b00011),  // bit 3
                                 (awaddr_skid_reg[12:8] == 5'b00010),  // bit 2
                                 (awaddr_skid_reg[12:8] == 5'b00001),  // bit 1
                                 (awaddr_skid_reg[12:8] == 5'b00000)}; // bit 0

  assign sp_selected_skid = |(axi_sper_i[31:0] & sp_onehot_skid[31:0]);

   // Master is selected when upper address bits match axi_mastsel_i (mask applied to both)
  assign master_id_enabled[6:0] = axi_mastsel_i[7:1] & mastsel_mask[6:0];

  assign master_id_if[6:0]   = {AWPROTS[1],      AWADDRS[29:24]};
  assign mast_selected_if    = ((master_id_if[6:0] & mastsel_mask[6:0]) == master_id_enabled[6:0]);

  assign master_id_buf[6:0]  = {awprot_buf_reg,  awaddr_buf_reg[29:24]};
  assign mast_selected_buf   = ((master_id_buf[6:0] & mastsel_mask[6:0]) == master_id_enabled[6:0]);

  assign master_id_skid[6:0] = {awprot_skid_reg, awaddr_skid_reg[29:24]};
  assign mast_selected_skid  = ((master_id_skid[6:0] & mastsel_mask[6:0]) == master_id_enabled[6:0]);

   // Bank is selected when upper address bits match axi_banksel_i (mask applied to both)
  assign bank_enabled[10:0] = axi_banksel_i[11:1] & banksel_mask[10:0];

  assign bank_selected_if     = ((AWADDRS[23:13]         & banksel_mask[10:0]) == bank_enabled[10:0]);
  assign bank_selected_buf    = ((awaddr_buf_reg[23:13]  & banksel_mask[10:0]) == bank_enabled[10:0]);
  assign bank_selected_skid   = ((awaddr_skid_reg[23:13] & banksel_mask[10:0]) == bank_enabled[10:0]);

  // There are 4 sources for address decode:
  // - address for i/f
  // - address buffer
  // - address generation (used in burst)
  // - address skid buffer

  // The Stimulus Port is enable mask is generated based on:
  // 1. STM is enabled
  // 2. addressed bank is enabled
  // 3. addressed master is enabled
  // 4. Access is non-secure and non-secure non-invasive debug is enabled or access is secure and secure non-invasive debug is enabled

  assign sp_en_mask_if = axi_enable_i &
                         (((axi_portctl_i[1:0]==2'b11) & bank_selected_if) | (axi_portctl_i[1:0]!=2'b11)) &
                         ((axi_mastctl_i & mast_selected_if) | ~axi_mastctl_i) &
                         ((AWPROTS[1] & nsec_noninvasive) | (~AWPROTS[1] & sec_noninvasive));

  assign sp_en_mask_buf = axi_enable_i &
                          (((axi_portctl_i[1:0]==2'b11) & bank_selected_buf) | (axi_portctl_i[1:0]!=2'b11)) &
                          ((axi_mastctl_i & mast_selected_buf) | ~axi_mastctl_i) &
                          ((awprot_buf_reg & nsec_noninvasive) | (~awprot_buf_reg & sec_noninvasive));

  assign sp_en_mask_agu = axi_enable_i &
                          (((axi_portctl_i[1:0]==2'b11) & bank_selected_buf) | (axi_portctl_i[1:0]!=2'b11)) &
                          ((axi_mastctl_i & mast_selected_buf) | ~axi_mastctl_i) &
                          ((awprot_buf_reg & nsec_noninvasive) | (~awprot_buf_reg & sec_noninvasive));

  assign sp_en_mask_skid = axi_enable_i &
                           (((axi_portctl_i[1:0]==2'b11) & bank_selected_skid) | (axi_portctl_i[1:0]!=2'b11)) &
                           ((axi_mastctl_i & mast_selected_skid) | ~axi_mastctl_i) &
                           ((awprot_skid_reg & nsec_noninvasive) | (~awprot_skid_reg & sec_noninvasive));

  // Mux for selecting decoder output from local address sources:
  // - address buffer
  // - address generation (used in burst)
  // - address skid buffer
  assign sp_selected_int  = (decode_mux_ctrl[2] & sp_selected_buf) |
                            (decode_mux_ctrl[1] & sp_selected_agu) |
                            (decode_mux_ctrl[0] & sp_selected_skid);

  // Mux for selecting decoder output:
  // - i/f
  // - local address source
  assign sp_selected  = decode_if_sel ? sp_selected_if : sp_selected_int;

  // Mux for selecting decoder output from local address sources:
  // - address buffer
  // - address generation (used in burst)
  // - address skid buffer
  assign sp_en_mask_int  = (decode_mux_ctrl[2] & sp_en_mask_buf) |
                           (decode_mux_ctrl[1] & sp_en_mask_agu) |
                           (decode_mux_ctrl[0] & sp_en_mask_skid);


  // Mux for selecting decoder output:
  // - i/f
  // - local address source
  assign sp_en_mask  = decode_if_sel ? sp_en_mask_if : sp_en_mask_int;

  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      sp_selected_reg <= 1'b0;
    else
      sp_selected_reg <= sp_selected;
  end

  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      sp_en_mask_reg <= 1'b0;
    else
      sp_en_mask_reg <= sp_en_mask;
  end

  // Stimulus port is enabled if:
  // - port within the bank is enabled
  // - enable mask for selected port is set
  assign sp_enabled = sp_selected_reg & sp_en_mask_reg;

  // Master Override Mask Generation
  assign mast_overridesel_mask[0]  =  axi_overmastsel_i[0];
  assign mast_overridesel_mask[1]  = |axi_overmastsel_i[1:0];
  assign mast_overridesel_mask[2]  = |axi_overmastsel_i[2:0];
  assign mast_overridesel_mask[3]  = |axi_overmastsel_i[3:0];
  assign mast_overridesel_mask[4]  = |axi_overmastsel_i[4:0];
  assign mast_overridesel_mask[5]  = |axi_overmastsel_i[5:0];
  assign mast_overridesel_mask[6]  = |axi_overmastsel_i[6:0];

  // Stimulus Port Override Mask Generation
  assign bank_overridesel_mask[0]  =  axi_overportsel_i[0];
  assign bank_overridesel_mask[1]  = |axi_overportsel_i[1:0];
  assign bank_overridesel_mask[2]  = |axi_overportsel_i[2:0];
  assign bank_overridesel_mask[3]  = |axi_overportsel_i[3:0];
  assign bank_overridesel_mask[4]  = |axi_overportsel_i[4:0];
  assign bank_overridesel_mask[5]  = |axi_overportsel_i[5:0];
  assign bank_overridesel_mask[6]  = |axi_overportsel_i[6:0];
  assign bank_overridesel_mask[7]  = |axi_overportsel_i[7:0];
  assign bank_overridesel_mask[8]  = |axi_overportsel_i[8:0];
  assign bank_overridesel_mask[9]  = |axi_overportsel_i[9:0];
  assign bank_overridesel_mask[10] = |axi_overportsel_i[10:0];
  assign bank_overridesel_mask[11] = |axi_overportsel_i[11:0];
  assign bank_overridesel_mask[12] = |axi_overportsel_i[12:0];
  assign bank_overridesel_mask[13] = |axi_overportsel_i[13:0];
  assign bank_overridesel_mask[14] = |axi_overportsel_i[14:0];
  assign bank_overridesel_mask[15] = |axi_overportsel_i[15:0];

  // Master override is selected when upper address match cfg_banksel_i (mask applied to both)
  assign mast_override_enabled[6:0] = axi_overmastsel_i[7:1] & mast_overridesel_mask[6:0];

  assign mast_override_sel_if   = ((master_id_if[6:0]   & mast_overridesel_mask[6:0]) == mast_override_enabled[6:0]);
  assign mast_override_sel_buf  = ((master_id_buf[6:0]  & mast_overridesel_mask[6:0]) == mast_override_enabled[6:0]);
  assign mast_override_sel_skid = ((master_id_skid[6:0] & mast_overridesel_mask[6:0]) == mast_override_enabled[6:0]);

  // Bank override is selected when upper address match cfg_banksel_i (mask applied to both)
  assign bank_override_enabled[15:0] = axi_overportsel_i[16:1] & bank_overridesel_mask[15:0];

  assign bank_override_sel_if   = ((AWADDRS[23:8]                                  & bank_overridesel_mask[15:0]) == bank_override_enabled[15:0]);
  assign bank_override_sel_buf  = ((awaddr_buf_reg[23:8]                           & bank_overridesel_mask[15:0]) == bank_override_enabled[15:0]);
  assign bank_override_sel_agu  = (({awaddr_buf_reg[23:12], nxt_burst_addr[11:8]}  & bank_overridesel_mask[15:0]) == bank_override_enabled[15:0]);
  assign bank_override_sel_skid = ((awaddr_skid_reg[23:8]                          & bank_overridesel_mask[15:0]) == bank_override_enabled[15:0]);

  // Stimulus port override
  assign sp_override_sel_if   = (~axi_overmastctl_i & bank_override_sel_if)   | (axi_overmastctl_i & mast_override_sel_if   & bank_override_sel_if);
  assign sp_override_sel_buf  = (~axi_overmastctl_i & bank_override_sel_buf)  | (axi_overmastctl_i & mast_override_sel_buf  & bank_override_sel_buf);
  assign sp_override_sel_agu  = (~axi_overmastctl_i & bank_override_sel_agu)  | (axi_overmastctl_i & mast_override_sel_buf  & bank_override_sel_agu);
  assign sp_override_sel_skid = (~axi_overmastctl_i & bank_override_sel_skid) | (axi_overmastctl_i & mast_override_sel_skid & bank_override_sel_skid);

  // Transaction is guaranteed if:
  // 1.- request is to guaranteed address with no override applied, or
  //   - guaranteed override is applied and invasive debug is enabled (non-secure access with non-secure invasive debug or secure access with secure invasive debug), or
  //   - invariant-timing override is selected but not applied to this stimulus port and access is guaranteed
  // and
  // 2. transaction is secure or transaction is non-secure with guaranteed for non-secure (NSGUAREN) enabled
  assign guaranteed_if  = (((axi_overportctl_i[1:0]==2'b00) &  ~AWADDRS[7])                                                                                         |
                           ((axi_overportctl_i[1:0]==2'b01) & (~AWADDRS[7] | (sp_override_sel_if & ((AWPROTS[1] & nsec_invasive) | (~AWPROTS[1] & sec_invasive))))) |
                           ((axi_overportctl_i[1:0]==2'b10) &  ~AWADDRS[7] & ~sp_override_sel_if))
                          & (~AWPROTS[1] | nsguaren_r_i);

  assign guaranteed_buf  = (((axi_overportctl_i[1:0]==2'b00) &  ~awaddr_buf_reg[7])                                                                                                  |
                            ((axi_overportctl_i[1:0]==2'b01) & (~awaddr_buf_reg[7] | (sp_override_sel_buf & ((awprot_buf_reg & nsec_invasive) | (~awprot_buf_reg & sec_invasive))))) |
                            ((axi_overportctl_i[1:0]==2'b10) &  ~awaddr_buf_reg[7] & ~sp_override_sel_buf))
                           & (~awprot_buf_reg | nsguaren_r_i);

  assign guaranteed_agu  = (((axi_overportctl_i[1:0]==2'b00) &  ~nxt_burst_addr[7])                                                                                                  |
                            ((axi_overportctl_i[1:0]==2'b01) & (~nxt_burst_addr[7] | (sp_override_sel_agu & ((awprot_buf_reg & nsec_invasive) | (~awprot_buf_reg & sec_invasive))))) |
                            ((axi_overportctl_i[1:0]==2'b10) &  ~nxt_burst_addr[7] & ~sp_override_sel_agu))
                           & (~awprot_buf_reg | nsguaren_r_i);

  assign guaranteed_skid  = (((axi_overportctl_i[1:0]==2'b00) &  ~awaddr_skid_reg[7])                                                                                                     |
                             ((axi_overportctl_i[1:0]==2'b01) & (~awaddr_skid_reg[7] | (sp_override_sel_skid & ((awprot_skid_reg & nsec_invasive) | (~awprot_skid_reg & sec_invasive))))) |
                             ((axi_overportctl_i[1:0]==2'b10) &  ~awaddr_skid_reg[7] & ~sp_override_sel_skid))
                            & (~awprot_skid_reg | nsguaren_r_i);

  // Mux for selecting decoder output from local address sources:
  // - address buffer
  // - address generation (used in burst)
  // - address skid buffer
  assign guaranteed_int  =  (decode_mux_ctrl[2] & guaranteed_buf) |
                            (decode_mux_ctrl[1] & guaranteed_agu) |
                            (decode_mux_ctrl[0] & guaranteed_skid);


  // Mux for selecting decoder output:
  // - i/f
  // - local address source
  assign guaranteed  = decode_if_sel ? guaranteed_if : guaranteed_int;

  // Registering guaranteed for use in timesatmp request calculation
  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      guaranteed_reg <= 1'b0;
    else
      guaranteed_reg <= guaranteed;
  end

  //-----------------------------------------------------------------------------------------------------
  //
  //  B Channel
  //
  //  The STM is able to accept 3 address transactions (write acceptance capability of 3)
  //  As such the STM must be able to buffer up to 3 outstanding AWIDs
  //  BVALID is then set when the corresponding W-Channel transactions is completed. As such:
  //  - 3 Buffers are present for the AWID values
  //  - 3 Buffers are present to indicate the completion of the corresponding W-Channel transaction
  //  These buffers are cleared as BVALID and BREADY are seen
  //
  //-----------------------------------------------------------------------------------------------------

  //-----------------------------------------------------------------------------------------------------
  //  BID
  //-----------------------------------------------------------------------------------------------------

  // BID is taken from:
  // - AWID on completion of AW transaction (if no BID response is currently pending)
  // - BID Buffers (if BID response is in progress)
  assign nxt_bid_valid = (address_load & ~bid_valid_reg) |
                         (address_load &  bid_valid_reg & bvalid_reg & BREADYS) |
                         (BREADYS & bvalid_reg & bid_buf_valid_reg) |
                         (~(BREADYS & bvalid_reg) & bid_valid_reg);

  always @(posedge CLK or negedge ARESETn) begin
    if(!ARESETn)
      bid_valid_reg <= 1'b0;
    else
      bid_valid_reg <= nxt_bid_valid;
  end

  assign nxt_bid[AXI_ID_WIDTH-1:0] = bid_buf_valid_reg ? bid_buf_reg[AXI_ID_WIDTH-1:0] : AWIDS[AXI_ID_WIDTH-1:0];
  assign bid_we                    = (address_load & ~bid_valid_reg)  |
                                     (address_load &  bid_valid_reg & bvalid_reg & BREADYS) |
                                     (BREADYS & bvalid_reg & bid_buf_valid_reg);


  always @(posedge CLK) begin
    if (bid_we)
      bid_reg[AXI_ID_WIDTH-1:0] <= nxt_bid[AXI_ID_WIDTH-1:0];
  end

  //-----------------------------------------------------------------------------------------------------
  //  BID Buffer
  //-----------------------------------------------------------------------------------------------------

  // BID is buffered if there is an existing BID response pending
  // BID buffer is taken from:
  // - AWID on completion of AW transaction (if bid valid is set)
  // - BID SKID buffer if skid valid is set on completion of B transaction
  assign nxt_bid_buf_valid = (address_load & bid_valid_reg & ~bid_buf_valid_reg & ~(bvalid_reg & BREADYS)) |
                             (address_load & bid_buf_valid_reg & bvalid_reg & BREADYS) |
                             (bvalid_reg & BREADYS & bid_skid_valid_reg) |
                             (~(BREADYS & bvalid_reg) & bid_buf_valid_reg);

  always @(posedge CLK or negedge ARESETn) begin
    if (!ARESETn)
      bid_buf_valid_reg <= 1'b0;
    else
      bid_buf_valid_reg <= nxt_bid_buf_valid;
  end

  assign nxt_bid_buf[AXI_ID_WIDTH-1:0] = bid_skid_valid_reg ? bid_skid_reg[AXI_ID_WIDTH-1:0] : AWIDS[AXI_ID_WIDTH-1:0];
  assign bid_buf_we = (address_load & bid_valid_reg & ~bid_buf_valid_reg & ~(bvalid_reg & BREADYS)) |
                      (address_load & bid_buf_valid_reg & bvalid_reg & BREADYS) |
                      (bid_skid_valid_reg & bvalid_reg & BREADYS);

  always @(posedge CLK) begin
    if (bid_buf_we)
      bid_buf_reg[AXI_ID_WIDTH-1:0] <= nxt_bid_buf[AXI_ID_WIDTH-1:0];
  end

  //-----------------------------------------------------------------------------------------------------
  //  BID SKID Buffer
  //-----------------------------------------------------------------------------------------------------

  // 3rd BID is buffered if there is are 2 existing BID responses pending
  // BID buffer is taken from:
  // - AWID on completion of AW transaction (if there are 2 BID responses pending)
  assign nxt_bid_skid_valid = (address_load & bid_buf_valid_reg & ~(bvalid_reg & BREADYS)) |
                              (~(BREADYS & bvalid_reg) & bid_skid_valid_reg );

  always @(posedge CLK or negedge ARESETn) begin
    if (!ARESETn)
      bid_skid_valid_reg <= 1'b0;
    else
      bid_skid_valid_reg <= nxt_bid_skid_valid;
  end

  assign bid_skid_we = (address_load & bid_buf_valid_reg & ~(bvalid_reg & BREADYS));

  always @(posedge CLK) begin
    if (bid_skid_we)
      bid_skid_reg[AXI_ID_WIDTH-1:0] <= AWIDS[AXI_ID_WIDTH-1:0];
  end

  //-----------------------------------------------------------------------------------------------------
  //  BID W Channel Dependencies
  //-----------------------------------------------------------------------------------------------------

  // BID response is dependant on completion of W Channel transaction
  // Completion of W channel transaction is registered to calculate nxt_bvalid

  // WDATA VALID (corresponding to AWID stored in bid_valid_reg)
  assign nxt_wdata_valid = (last_data_beat & ~wdata_valid_reg) |
                           (last_data_beat & wdata_valid_reg & bvalid_reg & BREADYS) |
                           (BREADYS & bvalid_reg & wdata_buf_valid_reg) |
                           (~(BREADYS & bvalid_reg) & wdata_valid_reg);

  always @(posedge CLK or negedge ARESETn) begin
    if(!ARESETn)
      wdata_valid_reg <= 1'b0;
    else
      wdata_valid_reg <= nxt_wdata_valid;
  end

  // WDATA BUF VALID (corresponding to AWID stored in bid_buf_valid_reg)
  assign nxt_wdata_buf_valid = (last_data_beat & wdata_valid_reg & ~(bvalid_reg & BREADYS)) |
                               (last_data_beat & wdata_buf_valid_reg & bvalid_reg & BREADYS) |
                               (wdata_skid_valid_reg & bvalid_reg & BREADYS) |
                               (~(BREADYS & bvalid_reg) & wdata_buf_valid_reg);

  always @(posedge CLK or negedge ARESETn) begin
    if(!ARESETn)
      wdata_buf_valid_reg <= 1'b0;
    else
      wdata_buf_valid_reg <= nxt_wdata_buf_valid;
  end

  // WDATA SKID VALID (corresponding to AWID stored in bid_skid_valid_reg)
  assign nxt_wdata_skid_valid = (last_data_beat & wdata_buf_valid_reg & ~(bvalid_reg & BREADYS)) |
                                (~(BREADYS & bvalid_reg) & wdata_skid_valid_reg);

  always @(posedge CLK or negedge ARESETn) begin
    if(!ARESETn)
      wdata_skid_valid_reg <= 1'b0;
    else
      wdata_skid_valid_reg <= nxt_wdata_skid_valid;
  end


  //-----------------------------------------------------------------------------------------------------
  //  BID Response
  //-----------------------------------------------------------------------------------------------------

  // BVALID is set if:
  // - There is a complete AW transaction and W transaction is about to complete
  // - There is a B response about to be completed and a pending AW transaction and W transaction about to complete
  // - There is an existing B response in progress
  assign nxt_bvalid = (~(BREADYS & bvalid_reg) & bid_valid_reg & nxt_wdata_valid) |
                      (BREADYS & bvalid_reg & bid_buf_valid_reg & nxt_wdata_valid) |
                      //(~(BREADYS & bvalid_reg) & nxt_bid_valid & wdata_valid_reg) |
                      (~BREADYS & bvalid_reg);

  always @(posedge CLK or negedge ARESETn) begin
    if (!ARESETn)
      bvalid_reg <= 1'b0;
    else
      bvalid_reg <= nxt_bvalid;
  end

  // State of B channel is taken into account for W channel stall
  // W channel is stalled if new ID cannot be accepted due to interconnect stall
  // on B channel
  assign bid_ready = ~(wdata_skid_valid_reg & ~(BREADYS & bvalid_reg));

  // W channel handshake
  // accepted data beat
  assign data_beat = WVALIDS & wready;
  // last accepted data beat
  assign last_data_beat = WLASTS & WVALIDS & wready;

  // Data is accepted on AXI i/f:
  // - one cycle after AWADDR is accepted in case of disabled stimulus port
  // - one cycle after AWADDR is accepted in case of invariant timing access
  // - when TGU i/f is ready in case of guaranteed access
  //
  assign nxt_wready = (~(sp_selected & sp_en_mask) | ~guaranteed | tgu_buf_rdy) & addr_valid & bid_ready & ~q_stopped_int;
  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      wready_reg <= 1'b0;
    else
      wready_reg <= nxt_wready;
  end

  assign wready = wready_reg;

  // TGU interface
  // TGU i/f is ready to take new data when:
  // - empty
  // - tgu_ready_i is high i.e. current TGU tarnsfer is accepted with no error pending
  // - STM is not in STMRESETn (axi_buf_clr_i high)
  assign tgu_buf_rdy = (~tgu_valid_reg |
                       ~(data_valid & data_beat) & (tgu_ready_i & ~tgu_err_reg[0] & ~tgu_err_reg[1]) |
                       ~tgu_skid_valid_reg & (tgu_ready_i & ~tgu_err_reg[0] & ~tgu_err_reg[1])       |
                       ~(data_valid & data_beat) & ~tgu_skid_valid_reg) &
                       ~axi_buf_clr_i;

  // TGU i/f channel is based on AXI AW address
  assign axi_tgu_master[6:0]    = {awprot_buf_reg, awaddr_buf_reg[29:24]};

  // TGU i/f channel is based on AXI AW address
  assign axi_tgu_channel[15:0]  = awaddr_buf_reg[23:8];

  generate
    if (STM_DATA_WIDTH == 64) begin : gen_wstrb_64

      // TGU i/f payload takes data from AXI W channel
      assign axi_tgu_payload[7:0]   = ({8{(WSTRBS==8'b00000001) | (WSTRBS==8'b00000011) |
                                          (WSTRBS==8'b00001111) | (WSTRBS==8'b11111111)}} & WDATAS[7:0])   |
                                      ({8{(WSTRBS==8'b00000010)}}                         & WDATAS[15:8])  |
                                      ({8{(WSTRBS==8'b00000100) | (WSTRBS==8'b00001100) |
                                          (WSTRBS==8'b00111100)}}                         & WDATAS[23:16]) |
                                      ({8{(WSTRBS==8'b00001000)}}                         & WDATAS[31:24]) |
                                      ({8{(WSTRBS==8'b00010000) | (WSTRBS==8'b00110000) |
                                          (WSTRBS==8'b11110000)}}                         & WDATAS[39:32]) |
                                      ({8{(WSTRBS==8'b00100000)}}                         & WDATAS[47:40]) |
                                      ({8{(WSTRBS==8'b01000000) | (WSTRBS==8'b11000000)}} & WDATAS[55:48]) |
                                      ({8{(WSTRBS==8'b10000000)}}                         & WDATAS[63:56]);


      assign axi_tgu_payload[15:8]  = ({8{(WSTRBS==8'b00000011) | (WSTRBS==8'b00001111) |
                                          (WSTRBS==8'b11111111)}}                         & WDATAS[15:8])  |
                                      ({8{(WSTRBS==8'b00001100)}}                         & WDATAS[31:24]) |
                                      ({8{(WSTRBS==8'b00110000) | (WSTRBS==8'b11110000)}} & WDATAS[47:40]) |
                                      ({8{(WSTRBS==8'b11000000)}}                         & WDATAS[63:56]);

      assign axi_tgu_payload[31:16] = ({16{(WSTRBS==8'b00001111) | (WSTRBS==8'b11111111)}} & WDATAS[31:16]) |
                                      ({16{(WSTRBS==8'b11110000)}}                         & WDATAS[63:48]);


      assign axi_tgu_payload[63:32] = ({32{(WSTRBS==8'b11111111)}}                         & WDATAS[63:32]);

      // AXI WSTRB to TGU size valid encodings

      // 00000001   WDATAS[7:0]     byte
      // 00000010   WDATAS[15:8]    byte
      // 00000100   WDATAS[23:16]   byte
      // 00001000   WDATAS[31:24]   byte
      // 00010000   WDATAS[39:32]   byte
      // 00100000   WDATAS[47:40]   byte
      // 01000000   WDATAS[55:48]   byte
      // 10000000   WDATAS[63:56]   byte
      // 00000011   WDATAS[15:0]    half-word
      // 00001100   WDATAS[31:16]   half-word
      // 00110000   WDATAS[47:32]   half-word
      // 11000000   WDATAS[63:48]   half-word
      // 00001111   WDATAS[31:0]    word
      // 11110000   WDATAS[63:32]   word
      // 11111111   WDATAS[63:0]    doubleword
      // ALL OTHER ENCODINGS WILL OUTPUT NO DATA

      // PLA table sent to espresso
      // .i 8
      // .o 4
      // .ilb WSTRBS[7] WSTRBS[6] WSTRBS[5] WSTRBS[4] WSTRBS[3] WSTRBS[2] WSTRBS[1] WSTRBS[0]
      // .ob axi_tgu_size[2] axi_tgu_size[1] axi_tgu_size[0] valid_wstrbs
      // #
      // #Inputs:
      // # WSTRBS[7:0]
      // # |            Outputs:
      // # |            axi_tgu_size[2:0]
      // # |            |   valid_wstrbs
      // # |            |   |
      // # Valid WSTRBS |   |
      //   00000001     001 1
      //   00000010     001 1
      //   00000100     001 1
      //   00001000     001 1
      //   00010000     001 1
      //   00100000     001 1
      //   01000000     001 1
      //   10000000     001 1
      //   00000011     010 1
      //   00001100     010 1
      //   00110000     010 1
      //   11000000     010 1
      //   00001111     011 1
      //   11110000     011 1
      //   11111111     100 1
      //   --------     000 0
      // .e
  // espresso output
  // DO NOT MODIFY BY HAND
  assign axi_tgu_size[2] = (WSTRBS[7]&WSTRBS[6]&WSTRBS[5]&WSTRBS[4]&WSTRBS[3]
    &WSTRBS[2]&WSTRBS[1]&WSTRBS[0]);

  assign axi_tgu_size[1] = (WSTRBS[7]&WSTRBS[6]&WSTRBS[5]&WSTRBS[4]&!WSTRBS[3]
    &!WSTRBS[2]&!WSTRBS[1]&!WSTRBS[0]) | (!WSTRBS[7]&!WSTRBS[6]&!WSTRBS[5]
    &!WSTRBS[4]&WSTRBS[3]&WSTRBS[2]&WSTRBS[1]&WSTRBS[0]) | (WSTRBS[7]
    &WSTRBS[6]&!WSTRBS[5]&!WSTRBS[4]&!WSTRBS[3]&!WSTRBS[2]&!WSTRBS[1]
    &!WSTRBS[0]) | (!WSTRBS[7]&!WSTRBS[6]&WSTRBS[5]&WSTRBS[4]&!WSTRBS[3]
    &!WSTRBS[2]&!WSTRBS[1]&!WSTRBS[0]) | (!WSTRBS[7]&!WSTRBS[6]&!WSTRBS[5]
    &!WSTRBS[4]&WSTRBS[3]&WSTRBS[2]&!WSTRBS[1]&!WSTRBS[0]) | (!WSTRBS[7]
    &!WSTRBS[6]&!WSTRBS[5]&!WSTRBS[4]&!WSTRBS[3]&!WSTRBS[2]&WSTRBS[1]
    &WSTRBS[0]);

  assign axi_tgu_size[0] = (WSTRBS[7]&WSTRBS[6]&WSTRBS[5]&WSTRBS[4]&!WSTRBS[3]
    &!WSTRBS[2]&!WSTRBS[1]&!WSTRBS[0]) | (!WSTRBS[7]&!WSTRBS[6]&!WSTRBS[5]
    &!WSTRBS[4]&WSTRBS[3]&WSTRBS[2]&WSTRBS[1]&WSTRBS[0]) | (WSTRBS[7]
    &!WSTRBS[6]&!WSTRBS[5]&!WSTRBS[4]&!WSTRBS[3]&!WSTRBS[2]&!WSTRBS[1]
    &!WSTRBS[0]) | (!WSTRBS[7]&WSTRBS[6]&!WSTRBS[5]&!WSTRBS[4]&!WSTRBS[3]
    &!WSTRBS[2]&!WSTRBS[1]&!WSTRBS[0]) | (!WSTRBS[7]&!WSTRBS[6]&WSTRBS[5]
    &!WSTRBS[4]&!WSTRBS[3]&!WSTRBS[2]&!WSTRBS[1]&!WSTRBS[0]) | (
    !WSTRBS[7]&!WSTRBS[6]&!WSTRBS[5]&WSTRBS[4]&!WSTRBS[3]&!WSTRBS[2]
    &!WSTRBS[1]&!WSTRBS[0]) | (!WSTRBS[7]&!WSTRBS[6]&!WSTRBS[5]&!WSTRBS[4]
    &WSTRBS[3]&!WSTRBS[2]&!WSTRBS[1]&!WSTRBS[0]) | (!WSTRBS[7]&!WSTRBS[6]
    &!WSTRBS[5]&!WSTRBS[4]&!WSTRBS[3]&WSTRBS[2]&!WSTRBS[1]&!WSTRBS[0]) | (
    !WSTRBS[7]&!WSTRBS[6]&!WSTRBS[5]&!WSTRBS[4]&!WSTRBS[3]&!WSTRBS[2]
    &WSTRBS[1]&!WSTRBS[0]) | (!WSTRBS[7]&!WSTRBS[6]&!WSTRBS[5]&!WSTRBS[4]
    &!WSTRBS[3]&!WSTRBS[2]&!WSTRBS[1]&WSTRBS[0]);

  assign valid_wstrbs = (WSTRBS[7]&WSTRBS[6]&WSTRBS[5]&WSTRBS[4]&WSTRBS[3]
    &WSTRBS[2]&WSTRBS[1]&WSTRBS[0]) | (WSTRBS[7]&WSTRBS[6]&WSTRBS[5]
    &WSTRBS[4]&!WSTRBS[3]&!WSTRBS[2]&!WSTRBS[1]&!WSTRBS[0]) | (!WSTRBS[7]
    &!WSTRBS[6]&!WSTRBS[5]&!WSTRBS[4]&WSTRBS[3]&WSTRBS[2]&WSTRBS[1]
    &WSTRBS[0]) | (WSTRBS[7]&!WSTRBS[5]&!WSTRBS[4]&!WSTRBS[3]&!WSTRBS[2]
    &!WSTRBS[1]&!WSTRBS[0]) | (!WSTRBS[7]&!WSTRBS[6]&WSTRBS[5]&!WSTRBS[3]
    &!WSTRBS[2]&!WSTRBS[1]&!WSTRBS[0]) | (!WSTRBS[7]&!WSTRBS[6]&!WSTRBS[5]
    &!WSTRBS[4]&WSTRBS[3]&!WSTRBS[1]&!WSTRBS[0]) | (!WSTRBS[7]&!WSTRBS[6]
    &!WSTRBS[5]&!WSTRBS[4]&!WSTRBS[3]&!WSTRBS[2]&WSTRBS[1]) | (WSTRBS[6]
    &!WSTRBS[5]&!WSTRBS[4]&!WSTRBS[3]&!WSTRBS[2]&!WSTRBS[1]&!WSTRBS[0]) | (
    !WSTRBS[7]&!WSTRBS[6]&WSTRBS[4]&!WSTRBS[3]&!WSTRBS[2]&!WSTRBS[1]
    &!WSTRBS[0]) | (!WSTRBS[7]&!WSTRBS[6]&!WSTRBS[5]&!WSTRBS[4]&WSTRBS[2]
    &!WSTRBS[1]&!WSTRBS[0]) | (!WSTRBS[7]&!WSTRBS[6]&!WSTRBS[5]&!WSTRBS[4]
    &!WSTRBS[3]&!WSTRBS[2]&WSTRBS[0]);

  // end of espresso output

    end








  endgenerate

  // TGU packet type decode
  // Packet type other than MERR/GERR depends on AXI address
  assign axi_tgu_packet_type[2:0] = ({3{(~awaddr_buf_reg[6] & ~awaddr_buf_reg[4])}}                      & TGU_DATAM[2:0]) |
                                    ({3{(~awaddr_buf_reg[6] &  awaddr_buf_reg[4])}}                      & TGU_DATA [2:0]) |
                                    ({3{( awaddr_buf_reg[6] &  awaddr_buf_reg[5] & ~awaddr_buf_reg[4])}} & TGU_FLAG [2:0]) |
                                    ({3{( awaddr_buf_reg[6] &  awaddr_buf_reg[5] &  awaddr_buf_reg[4])}} & TGU_TRIG [2:0]);

  // Timestamp request
  // - guaranteed transactions have guaranteed timestamp
  // - invariant transaction have sticky timestamp
  //  Sticky timestamp means that a optional timestamp request is generated for TGU until one transaction is timestamped
  // - forced timestamp generates a sticky timestamp request
  // When timestamp override is set non-timestamp accesses are marked with optional timestamp
  assign axi_tgu_ts_req[1] =  (guaranteed_reg & ~awaddr_buf_reg[3]) & axi_tsen_i;
  assign axi_tgu_ts_req[0] =  (~awaddr_buf_reg[3] | axi_overts_i)   & axi_tsen_i;

  generate
    if (STM_DATA_WIDTH == 64) begin : gen_tgu_transfer_64

      assign axi_tgu_transfer[94:0] = {axi_tgu_master[6:0],        // 94:88
                                       axi_tgu_channel[15:0],      // 87:72
                                       axi_tgu_payload[63:0],      // 71:8
                                       axi_tgu_size[2:0],          // 7:5
                                       axi_tgu_packet_type[2:0],   // 4:2
                                       axi_tgu_ts_req[1:0]         // 1:0
                                      };

      assign nxt_tgu_transfer[94:88] = ({7{(  tgu_load_err                   )}} & merr_master_reg[6:0])         |
                                       ({7{( ~tgu_load_err &  tgu_data_source)}} & tgu_transfer_skid_reg[94:88]) |
                                       ({7{( ~tgu_load_err & ~tgu_data_source)}} & axi_tgu_transfer[94:88]);

      assign nxt_tgu_transfer[87:5]  = tgu_data_source ? tgu_transfer_skid_reg[87:5] : axi_tgu_transfer[87:5];

    end




  endgenerate

  // Error insertion
  assign nxt_tgu_transfer[4:2] = ({3{(  tgu_load_err & ~tgu_err_reg[1] &  tgu_err_reg[0])}} & TGU_MERR [2:0])             |
                                 ({3{(  tgu_load_err &  tgu_err_reg[1] & ~tgu_err_reg[0])}} & TGU_GERR [2:0])             |
                                 ({3{( ~tgu_load_err &  tgu_data_source)}}                  & tgu_transfer_skid_reg[4:2]) |
                                 ({3{( ~tgu_load_err & ~tgu_data_source)}}                  & axi_tgu_packet_type[2:0]);

  // Sticky timestamp
  // TGU ignores ts_req for MERR/GERR so sticky is kept through MERR/GERR
  assign nxt_tgu_transfer[1] =  (tgu_data_source ? tgu_transfer_skid_reg[1] : axi_tgu_transfer[1]) & ~tgu_load_err;
  assign nxt_tgu_transfer[0] = ((tgu_data_source ? tgu_transfer_skid_reg[0] : axi_tgu_transfer[0]) & ~tgu_load_err) |
                               (tgu_valid_reg & ~tgu_transfer_reg[1] & tgu_transfer_reg[0] & ~tgu_timestamped_i);

  // TGU i/f is registered
  always @(posedge CLK)
  begin
    if (tgu_valid_we)
    begin
      tgu_transfer_reg[(STM_DATA_WIDTH+(STM_DATA_WIDTH/32)+28):0] <= nxt_tgu_transfer[(STM_DATA_WIDTH+(STM_DATA_WIDTH/32)+28):0];
    end
  end

  // TGU skid buffer
  always @(posedge CLK)
  begin
    if (tgu_skid_we)
    begin
      tgu_transfer_skid_reg[(STM_DATA_WIDTH+(STM_DATA_WIDTH/32)+28):0] <= axi_tgu_transfer[(STM_DATA_WIDTH+(STM_DATA_WIDTH/32)+28):0];
    end
  end

  // Data is valid for load into tgu buffer/skid buffer if
  // 1. There is an ongoing access (addr_buf_valid_reg)
  // 2. It's to enabled stimulus port (sp_enabled)
  // 3. The WSTRBS are valid (valid_wstrbs)
  // 4. The STM is not in STMRESETn and therefore not flushing the AXI TGU buffers (axi_buf_clr_i)
  //
  assign data_valid = sp_enabled & addr_buf_valid_reg & valid_wstrbs;

  // PLA table sent to espresso
  // .i 8
  // .o 7
  // .ilb data_beat data_valid tgu_skid_valid_reg tgu_valid_reg tgu_ready_i tgu_err_reg[1] tgu_err_reg[0] axi_buf_clr_i
  // .ob data_dropped tgu_load_err skid_load skid_valid_clear tgu_data_source tgu_load tgu_valid_clear
  // #
  // #Inputs:
  // # data_beat
  // # | data_valid
  // # | | tgu_skid_valid_reg
  // # | | | tgu_valid_reg
  // # | | | | tgu_ready_i
  // # | | | | | tgu_err_reg
  // # | | | | | |  axi_buf_clr_i
  // # | | | | | |  |
  // # | | | | | |  |
  // # | | | | | |  |   Outputs:
  // # | | | | | |  |      data_dropped
  // # | | | | | |  |      | tgu_load_err
  // # | | | | | |  |      | | skid_load
  // # | | | | | |  |      | | | skid_valid_clear
  // # | | | | | |  |      | | | | tgu_data_source 1=skid buffer 0=AXI
  // # | | | | | |  |      | | | | | tgu_load
  // # | | | | | |  |      | | | | | | tgu_valid_clear
  // # no data from AXI    | | | | | | |
  //   0 - - - 0 -- 0      0 0 0 0 - 0 0
  //   0 - 0 1 1 00 0      0 0 0 0 - 0 1
  //   0 - 0 1 1 1- 0      0 1 0 0 - 0 0
  //   0 - 0 1 1 -1 0      0 1 0 0 - 0 0
  //   0 - 1 1 1 00 0      0 0 0 1 1 1 0
  //   0 - 1 1 1 1- 0      0 1 0 0 - 0 0
  //   0 - 1 1 1 -1 0      0 1 0 0 - 0 0
  // # disabled access
  //   1 0 0 0 - -- 0      0 0 0 0 - 0 0
  //   1 0 0 1 0 -- 0      0 0 0 0 - 0 0
  //   1 0 0 1 1 00 0      0 0 0 0 - 0 1
  //   1 0 0 1 1 1- 0      0 1 0 0 - 0 0
  //   1 0 0 1 1 -1 0      0 1 0 0 - 0 0
  //   1 0 1 1 0 -- 0      0 0 0 0 - 0 0
  //   1 0 1 1 1 00 0      0 0 0 1 1 1 0
  //   1 0 1 1 1 1- 0      0 1 0 0 - 0 0
  //   1 0 1 1 1 -1 0      0 1 0 0 - 0 0
  // # valid data
  //   1 1 0 0 - -- 0      0 0 0 0 0 1 0
  //   1 1 0 1 0 -- 0      0 0 1 0 - 0 0
  //   1 1 0 1 1 00 0      0 0 0 0 0 1 0
  //   1 1 0 1 1 1- 0      0 1 1 0 - 0 0
  //   1 1 0 1 1 -1 0      0 1 1 0 - 0 0
  //   1 1 1 1 0 -- 0      1 0 0 0 - 0 0
  //   1 1 1 1 1 00 0      0 0 1 0 1 1 0
  //   1 1 1 1 1 1- 0      1 1 0 0 - 0 0
  //   1 1 1 1 1 -1 0      1 1 0 0 - 0 0
  // # stm in reset
  //   0 - - 0 - 00 1      0 0 0 0 - 0 0
  //   1 - - - - -- 1      0 0 0 1 - 0 1
  //   - - - 1 - -- 1      0 0 0 1 - 0 1
  //   - - - - - 1- 1      0 0 0 1 - 0 1
  //   - - - - - -1 1      0 0 0 1 - 0 1
  // # invalid cases - assertion present
  //   - - 1 0 - -- -      - - - - - - -
  //   - - 0 0 - 1- -      - - - - - - -
  //   - - 0 0 - -1 -      - - - - - - -
  // .e
  // espresso output
  // DO NOT MODIFY BY HAND
  assign data_dropped = (data_beat&data_valid&tgu_skid_valid_reg&tgu_err_reg[0]
    &!axi_buf_clr_i) | (data_beat&data_valid&tgu_skid_valid_reg
    &tgu_err_reg[1]&!axi_buf_clr_i) | (data_beat&data_valid
    &tgu_skid_valid_reg&!tgu_ready_i&!axi_buf_clr_i);

  assign tgu_load_err = (tgu_ready_i&tgu_err_reg[0]&!axi_buf_clr_i) | (
    tgu_ready_i&tgu_err_reg[1]&!axi_buf_clr_i);

  assign skid_load = (data_beat&data_valid&tgu_skid_valid_reg&tgu_ready_i
    &!tgu_err_reg[1]&!tgu_err_reg[0]&!axi_buf_clr_i) | (data_beat
    &data_valid&!tgu_skid_valid_reg&tgu_err_reg[0]&!axi_buf_clr_i) | (
    data_beat&data_valid&!tgu_skid_valid_reg&tgu_err_reg[1]&!axi_buf_clr_i) | (
    data_beat&data_valid&!tgu_skid_valid_reg&tgu_valid_reg&!tgu_ready_i
    &!axi_buf_clr_i);

  assign skid_valid_clear = (!data_valid&tgu_skid_valid_reg&tgu_ready_i
    &!tgu_err_reg[1]&!tgu_err_reg[0]) | (!data_beat&tgu_skid_valid_reg
    &tgu_ready_i&!tgu_err_reg[1]&!tgu_err_reg[0]) | (data_beat
    &axi_buf_clr_i) | (tgu_valid_reg&axi_buf_clr_i);

  assign tgu_data_source = (tgu_skid_valid_reg);

  assign tgu_load = (tgu_skid_valid_reg&tgu_ready_i&!tgu_err_reg[1]&!tgu_err_reg[0]
    &!axi_buf_clr_i) | (data_beat&data_valid&tgu_ready_i&!tgu_err_reg[1]
    &!tgu_err_reg[0]&!axi_buf_clr_i) | (data_beat&data_valid
    &!tgu_valid_reg&!axi_buf_clr_i);

  assign tgu_valid_clear = (!data_valid&!tgu_skid_valid_reg&tgu_valid_reg
    &tgu_ready_i&!tgu_err_reg[1]&!tgu_err_reg[0]) | (!data_beat
    &!tgu_skid_valid_reg&tgu_valid_reg&tgu_ready_i&!tgu_err_reg[1]
    &!tgu_err_reg[0]) | (data_beat&axi_buf_clr_i) | (tgu_valid_reg
    &axi_buf_clr_i);

  // end of espresso output

  // TGU valid (Invalid WSTRBS will prevent tgu_valid for being asserted and therefore produce no data)
  assign nxt_tgu_valid = tgu_load | tgu_load_err;
  assign tgu_valid_we  = tgu_valid_clear | tgu_load | tgu_load_err;
  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      tgu_valid_reg <= 1'b0;
    else if (tgu_valid_we)
      tgu_valid_reg <= nxt_tgu_valid;
  end

  assign nxt_tgu_skid_valid = skid_load;
  assign tgu_skid_we        = skid_valid_clear | skid_load;
  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      tgu_skid_valid_reg <= 1'b0;
    else if (tgu_skid_we)
      tgu_skid_valid_reg <= nxt_tgu_skid_valid;
  end

  // Error generation
  // Pending error is set when data is dropped due to skid buffer being full
  // First dropped data causes MERR, subsequent drops will cause GERR only if master ID changes
  // Pending error is cleared when skid data is moved to tgu buffer
  assign nxt_err_pending[1:0] = ({2{tgu_load}} & ERR_NONE[1:0])                                                                                           |
                                ({2{data_dropped & (err_pending_reg[1:0]==2'b00)}} & ERR_MERR[1:0])                                                       |
                                ({2{data_dropped & (err_pending_reg[1:0]==2'b01 & (axi_tgu_master[6:0]==merr_master_pend_reg[6:0]))}} & ERR_MERR[1:0]) |
                                ({2{data_dropped & (err_pending_reg[1:0]==2'b01 & (axi_tgu_master[6:0]!=merr_master_pend_reg[6:0]))}} & ERR_GERR[1:0]) |
                                ({2{data_dropped & (err_pending_reg[1:0]==2'b10)}} & ERR_GERR[1:0]);
  assign err_pending_we       = data_dropped | tgu_load | tgu_valid_clear;
  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      err_pending_reg[1:0] <= ERR_NONE;
    else if (err_pending_we)
      err_pending_reg[1:0] <= nxt_err_pending[1:0];
  end

  always @(posedge CLK)
  begin
    if (err_pending_we)
      merr_master_pend_reg[6:0] <= axi_tgu_master[6:0];
  end

  // Error qualifier attached to current tgu transaction.
  // Error means that MERR or GERR should follow.
  // It's cleared when MERR/GERR is presented on TGU interface
  assign nxt_tgu_err[1:0] = ({2{tgu_load_err}} & ERR_NONE)        |
                            ({2{tgu_load}} & err_pending_reg[1:0]);
  assign tgu_err_we       = tgu_load | tgu_load_err | tgu_valid_clear;
  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      tgu_err_reg[1:0] <= ERR_NONE;
    else if (tgu_err_we)
      tgu_err_reg[1:0] <= nxt_tgu_err[1:0];
  end

  always @(posedge CLK)
  begin
    if (tgu_err_we)
      merr_master_reg[6:0] <= merr_master_pend_reg[6:0];
  end

  // Flush handling
  // Detect new flush request as:
  // - rising edge of tgu_fvalid_i
  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      tgu_fvalid_reg <= 1'b0;
    else
      tgu_fvalid_reg <= tgu_fvalid_i;
  end

  assign axi_flush = tgu_fvalid_i & ~tgu_fvalid_reg;

  // Toflush flages are set for each buffer entry on rising edge of flush request
  // and cleared on data write from AXI interface
  assign nxt_tgu_toflush = (axi_flush | (tgu_load & tgu_data_source & tgu_skid_toflush_reg)) & ~(tgu_load & ~tgu_data_source);
  assign tgu_toflush_we  = axi_flush | tgu_load;
  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      tgu_toflush_reg <= 1'b0;
    else if (tgu_toflush_we)
      tgu_toflush_reg <= nxt_tgu_toflush;
  end

  assign nxt_tgu_skid_toflush = axi_flush & ~skid_load;
  assign tgu_skid_toflush_we  = axi_flush | skid_load;
  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      tgu_skid_toflush_reg <= 1'b0;
    else if (tgu_skid_toflush_we)
      tgu_skid_toflush_reg <= nxt_tgu_skid_toflush;
  end

  // Flush ready is asserted after last historical data is output i.e.
  // - data is taken with flush ongoing and
  // -- it is data marked with "to flush flag" and there is no error attached to it and no "to flush" skid data
  // -- it is data from first cycle of flush request and there is no error attached to it and nothing in the skid
  // - there is nothing more to output
  assign nxt_tgu_fready = (tgu_valid_reg & tgu_ready_i &
                           ((tgu_toflush_reg & ~(tgu_skid_toflush_reg & tgu_skid_valid_reg) & ~tgu_load_err) |
                           (axi_flush & ~tgu_skid_valid_reg & ~tgu_load_err))) |
                          (~nxt_tgu_valid & tgu_valid_we);
  assign tgu_fready_we = tgu_valid_we | (tgu_valid_reg & tgu_fvalid_i);
  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      tgu_fready_reg <= 1'b1;
    else if (tgu_fready_we)
      tgu_fready_reg <= nxt_tgu_fready;
  end

  // Triggers
  // Trigger on "match using STMSPTER"

  // SPTE trigger selection within group of 32 stimulus ports
  assign trig_selected_if   = |(axi_spter_i[31:0] & sp_onehot_if[31:0]);
  assign trig_selected_buf  = |(axi_spter_i[31:0] & sp_onehot_buf[31:0]);
  assign trig_selected_agu  = |(axi_spter_i[31:0] & sp_onehot_agu[31:0]);
  assign trig_selected_skid = |(axi_spter_i[31:0] & sp_onehot_skid[31:0]);

  // The SPTE trigger is enabled if:
  // 1. STM is enabled
  // 2. bank is enabled
  // 3. Master is enabled
  // 4. Access is non-secure and non-invasive debug is enabled or access is secure and secure non-invasive debug is enabled

  assign trig_enabled_if  = axi_enable_i     &
                            (((axi_portctl_i[0]==1'b1) & bank_selected_if) | (axi_portctl_i[0]==1'b0)) &
                            ((axi_mastctl_i & mast_selected_if) | ~axi_mastctl_i) &
                            ((AWPROTS[1] & nsec_noninvasive) | (~AWPROTS[1] & sec_noninvasive));

  assign trig_enabled_buf = axi_enable_i     &
                            (((axi_portctl_i[0]==1'b1) & bank_selected_buf) | (axi_portctl_i[0]==1'b0)) &
                            ((axi_mastctl_i & mast_selected_buf) | ~axi_mastctl_i) &
                            ((awprot_buf_reg & nsec_noninvasive) | (~awprot_buf_reg & sec_noninvasive));

  assign trig_enabled_agu = axi_enable_i     &
                            (((axi_portctl_i[0]==1'b1) & bank_selected_buf) | (axi_portctl_i[0]==1'b0)) &
                            ((axi_mastctl_i & mast_selected_buf) | ~axi_mastctl_i) &
                            ((awprot_buf_reg & nsec_noninvasive) | (~awprot_buf_reg & sec_noninvasive));

  assign trig_enabled_skid = axi_enable_i     &
                             (((axi_portctl_i[0]==1'b1) & bank_selected_skid) | (axi_portctl_i[0]==1'b0)) &
                             ((axi_mastctl_i & mast_selected_skid) | ~axi_mastctl_i) &
                             ((awprot_skid_reg & nsec_noninvasive) | (~awprot_skid_reg & sec_noninvasive));


  // Trigger on Stimulus Port is enabled
  // - port is selected for trigger generation - trig_selected_*
  // - port is enabled for trigger generation - trig_enabled_*

  // Mux for selecting decoder output from local address sources:
  // - address buffer
  // - address generation (used in burst)
  // - address skid buffer
  assign trig_enabled_int  = (decode_mux_ctrl[2] & (trig_enabled_buf   & trig_selected_buf)) |
                             (decode_mux_ctrl[1] & (trig_enabled_agu   & trig_selected_agu)) |
                             (decode_mux_ctrl[0] & (trig_enabled_skid  & trig_selected_skid));

  // Mux for selecting decoder output:
  // - i/f
  // - local address source
  assign trig_enabled  = decode_if_sel ? (trig_enabled_if & trig_selected_if) : (trig_enabled_int);

  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      trig_enabled_reg <= 1'b0;
    else
      trig_enabled_reg <= trig_enabled;
  end

  // The SPTE trigger is output on data beat of valid access (addr_buf_valid_reg) to trigger enabled location
  // The trigger is output on
  // 1. Data Beat
  // 2. Triggers are enabled
  // 3. STM is not triggering a flush of AXI TGU buffers (i.e. not in STMRESETn)
  assign axi_triggerspte_en = ~axi_singleshot_i | (axi_singleshot_i & ~(trigoutspte_reg | axi_trigstatusspte_i));

  assign triggerspte        = (sp_selected_reg & trig_enabled_reg) & data_beat & valid_wstrbs & axi_triggerspte_en & ~axi_buf_clr_i;

  assign trigoutspte_we  = ittrigger_we_i | ~itctl_i;
  assign nxt_trigoutspte = itctl_i ? pwdatadbg1_0_r_i[0] : triggerspte;
  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      trigoutspte_reg <= 1'b0;
    else if (trigoutspte_we)
      trigoutspte_reg <= nxt_trigoutspte;
  end

  // Trigger on "write to TRIG location"
  // The SW trigger is output on:
  // 1. Valid Data Beat
  // 2. to TRIG location
  // 3. STM is not triggering a flush of AXI TGU buffers (i.e. not in STMRESETn)
  assign triggersw     = data_valid & data_beat & ~axi_buf_clr_i &
                         (awaddr_buf_reg[6] & awaddr_buf_reg[5] & awaddr_buf_reg[4]);

  assign trigoutsw_we  = ittrigger_we_i | ~itctl_i;
  assign nxt_trigoutsw = itctl_i ? pwdatadbg1_0_r_i[1] : triggersw;
  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      trigoutsw_reg <= 1'b0;
    else if (trigoutsw_we)
      trigoutsw_reg <= nxt_trigoutsw;
  end

  // AXI is busy is reported to STMTCSR register when
  // 1. There is TGU transfer ongoing
  // 2. AXI address for enabled stimulus port is accepted and present in address buffer

  assign axi_busy_stm =  tgu_valid_reg |
                        (sp_enabled & addr_buf_valid_reg);

  // Unused inputs
  wire unused_ok;
  assign unused_ok = &{1'b0,
                       AWADDRS[2:0],
                       AWADDRS[31:30],
                       AWSIZES[2],
                       AWPROTS[2],
                       AWPROTS[0],
                       AWLENS[7:4],
                       1'b0};

  //----------------------------------------------------------------------------
  // Output assignment
  //----------------------------------------------------------------------------

  // AXI i/f
  assign AWREADYS               = awready_reg;
  assign WREADYS                = wready;
  assign BRESPS[1:0]            = AXI_RESP_OKAY[1:0];
  assign BIDS[AXI_ID_WIDTH-1:0] = bid_reg[AXI_ID_WIDTH-1:0];
  assign BVALIDS                = bvalid_reg;

  generate
    if (STM_DATA_WIDTH == 64) begin : gen_output_64

      // TGU i/f
      assign tgu_valid_o                         = tgu_valid_reg;
      assign tgu_master_o[7:0]                   = {1'b0, tgu_transfer_reg[94:88]};
      assign tgu_channel_o[15:0]                 = tgu_transfer_reg[87:72];
      assign tgu_payload_o[STM_DATA_WIDTH-1:0]   = tgu_transfer_reg[71:8];
      assign tgu_size_o[(STM_DATA_WIDTH/32):0]   = tgu_transfer_reg[7:5];
      assign tgu_packet_type_o[2:0]              = tgu_transfer_reg[4:2];
      assign tgu_ts_req_o[1:0]                   = tgu_transfer_reg[1:0];
      assign tgu_fready_o                        = tgu_fready_reg;

    end


  endgenerate

  // Status interface
  assign axi_busy_q_channel_o  = axi_busy_q_channel;
  assign axi_busy_stm_o        = axi_busy_stm;

  // Trigger i/f
  assign triggerspte_o         = trigoutspte_reg;
  assign TRIGOUTSPTE           = trigoutspte_reg;
  assign triggersw_o           = trigoutsw_reg;
  assign TRIGOUTSW             = trigoutsw_reg;

`ifdef ARM_ASSERT_ON
  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------

  assert_zero_one_hot #(`OVL_FATAL,3,`OVL_ASSERT,"AWADDR buffer control must be one hot")
    ovl_zero_one_hot_axislvif_write_addr_buf_mux_ctrl (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (addr_buf_mux_ctrl[2:0])
    );

  assert_zero_one_hot #(`OVL_FATAL,3,`OVL_ASSERT,"AWADDR skid control must be one hot")
    ovl_zero_one_hot_axislvif_write_addr_skid_mux_ctrl (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (addr_skid_mux_ctrl[2:0])
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"tgu_err_reg should never be 2'b11 (MERR and GERR)")
    ovl_never_axislvif_write_tgu_err_never_merr_gerr (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (tgu_err_reg[1:0] == 2'b11)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"address buffer should not be empty if address skid buffer is full")
    ovl_never_axislvif_write_addr_skid_full_when_addr_buf_empty (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (~addr_buf_valid_reg & addr_skid_valid_reg)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"address skid buffer should not be empty if address second skid buffer is full")
    ovl_never_axislvif_write_addr_second_skid_full_when_addr_skid_empty (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (~addr_skid_valid_reg & addr_second_skid_valid_reg)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"address buffer cannot be empty when data is accepted ")
    ovl_never_axislvif_write_addr_buffer_empty_on_data_beat (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (~addr_buf_valid_reg & data_beat)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"BID valid should not be empty if BID valid buffer is full")
    ovl_never_axislvif_write_bid_valid_empty_when_bid_valid_buf_full (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (~bid_valid_reg & bid_buf_valid_reg)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"BID valid buf should not be empty if BID valid skid buffer is full")
    ovl_never_axislvif_write_bid_buf_empty_when_bid_valid_skid_full (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (~bid_buf_valid_reg & bid_skid_valid_reg)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"wdata valid should not be empty if wdata valid buffer is full")
    ovl_never_axislvif_write_wdata_valid_empty_when_wdata_valid_buf_full (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (~wdata_valid_reg & wdata_buf_valid_reg)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"wdata buffer should not be empty if wdata valid skid buffer is full")
    ovl_never_axislvif_write_wdata_valid_empty_when_wdata_valid_skid_full (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (~wdata_buf_valid_reg & wdata_skid_valid_reg)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"TGU i/f should not be idle if TGU skid buffer is full")
    ovl_never_axislvif_write_tgu_idle_when_tgu_skid_full (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (~tgu_valid_reg & tgu_skid_valid_reg)
    );

  assert_zero_one_hot #(`OVL_FATAL,3,`OVL_ASSERT,"tgu_load_err, tgu_load and tgu_valid_clear must be one hot")
    ovl_zero_axislvif_write_one_hot_tgu_load (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr ({tgu_load_err, tgu_load, tgu_valid_clear})
    );

  assert_zero_one_hot #(`OVL_FATAL,3,`OVL_ASSERT,"data_dropped, skid_load and skid_valid_clear must be one hot")
    ovl_zero_axislvif_write_one_hot_skid_data (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr ({data_dropped, skid_load, skid_valid_clear})
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"data_dropped can only be set when tgu_skid_valid_reg is set")
    ovl_never_axislvif_write_data_dropped_when_skid_valid (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (data_dropped & ~tgu_skid_valid_reg)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"data_dropped cannot be set when tgu buffer is loaded")
    ovl_never_axislvif_write_data_dropped_when_tgu_load (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (data_dropped & tgu_load)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"if skid buffer is full data must be loaded from it and not from interface")
    ovl_never_axislvif_write_tgu_load_from_intf_when_skid_full (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (tgu_skid_valid_reg & tgu_load & ~tgu_data_source)
    );

  reg guaranteed_dly;
  reg bid_ready_dly;
  always @(posedge CLK)
  begin
      guaranteed_dly <= guaranteed;
      bid_ready_dly  <= bid_ready;
  end

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"guaranteed must never be dropped")
    ovl_never_axislvif_write_drop_guaranteed_transaction (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (data_dropped & guaranteed_dly)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"invariant transactions must never stall")
    ovl_never_axislvif_write_stall_invariant_transaction (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (~guaranteed_dly & addr_buf_valid_reg & bid_ready_dly & ~WREADYS)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"there must not be 4 BID in flight")
    ovl_never_axislvif_write_3_bid_in_flight (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (awready_reg & AWVALIDS & bid_skid_valid_reg)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"data beat should not happen without valid address")
    ovl_never_axislvif_write_data_without_valid_addr (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (~addr_buf_valid_reg & data_beat)
    );

  assert_zero_one_hot #(`OVL_FATAL,3,`OVL_ASSERT,"decode mux control must be one hot")
    ovl_zero_one_hot_axislvif_write_decode_mux (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (decode_mux_ctrl[2:0])
    );

  assert_next #(`OVL_FATAL,1,1,0,`OVL_ASSERT,"New transaction must not be accepted into skid buffer when authentication is removed")
    ovl_next_axislvif_write_new_transaction_into_skid_auth (
      .clk         (CLK),
      .reset_n     (ARESETn),
      .start_event (~dbgen_r_i & ~niden_r_i),
      .test_expr   (~skid_load)
    );

  assert_next #(`OVL_FATAL,1,1,0,`OVL_ASSERT,"New transaction form AXI must not be accepted into buffer when authentication is removed")
    ovl_next_axislvif_write_new_transaction_into_buffer_auth (
      .clk         (CLK),
      .reset_n     (ARESETn),
      .start_event (~dbgen_r_i & ~niden_r_i),
      .test_expr   (~(tgu_load & ~tgu_data_source))
    );

  assert_next #(`OVL_FATAL,1,1,0,`OVL_ASSERT,"New secure transaction must not be accepted into skid buffer when secure authentication is removed")
    ovl_next_axislvif_write_new_transaction_into_skid_secure_auth (
      .clk         (CLK),
      .reset_n     (ARESETn),
      .start_event (~sec_invasive & ~sec_noninvasive),
      .test_expr   ((skid_load & awprot_buf_reg) | ~skid_load)
    );

  assert_next #(`OVL_FATAL,1,1,0,`OVL_ASSERT,"New secure transaction form AXI must not be accepted into buffer when secure authentication is removed")
    ovl_next_axislvif_write_new_transaction_into_buffer_secure_auth (
      .clk         (CLK),
      .reset_n     (ARESETn),
      .start_event (~sec_invasive & ~sec_noninvasive),
      .test_expr   ((tgu_load & ~tgu_data_source & awprot_buf_reg) | ~(tgu_load & ~tgu_data_source))
    );

  assert_next #(`OVL_FATAL,1,1,0,`OVL_ASSERT,"axi should not go busy after axi_enable goes low")
    ovl_next_axislvif_write_axi_busy_after_axi_enable_low (
      .clk         (CLK),
      .reset_n     (ARESETn),
      .start_event (~axi_enable_i & ~(tgu_valid_reg | (sp_enabled & addr_buf_valid_reg))),
      .test_expr   (~(tgu_valid_reg | (sp_enabled & addr_buf_valid_reg)))
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"TGU i/f tgu_ready should only be generated in response to tgu_valid")
    ovl_never_axislvif_write_tgu_ready_in_response_to_tgu_valid (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (~tgu_valid_reg & tgu_ready_i)
    );

  // X propagation
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "addr_buf_we is X")
    ovl_never_unknown_axislvif_write_addr_buf_we (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (addr_buf_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "addr_skid_we is X")
    ovl_never_unknown_axislvif_write_addr_skid_we (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (addr_skid_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "bid_we is X")
    ovl_never_unknown_axislvif_write_bid_we (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (bid_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "bid_buf_we is X")
    ovl_never_unknown_axislvif_write_bid_buf_we (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (bid_buf_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "tgu_valid_we is X")
    ovl_never_unknown_axislvif_write_tgu_valid_we (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (tgu_valid_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "tgu_skid_we is X")
    ovl_never_unknown_axislvif_write_tgu_skid_we (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (tgu_skid_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "err_pending_we is X")
    ovl_never_unknown_axislvif_write_err_pending_we (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (err_pending_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "tgu_err_we is X")
    ovl_never_unknown_axislvif_write_tgu_err_we (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (tgu_err_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "tgu_toflush_we is X")
    ovl_never_unknown_axislvif_write_tgu_toflush_we (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (tgu_toflush_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "tgu_skid_toflush_we is X")
    ovl_never_unknown_axislvif_write_tgu_skid_toflush_we (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (tgu_skid_toflush_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "tgu_fready_we is X")
    ovl_never_unknown_axislvif_write_tgu_fready_we (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (tgu_fready_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "trigoutspte_we is X")
    ovl_never_unknown_axislvif_write_trigoutspte_we (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (trigoutspte_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "trigoutsw_we is X")
    ovl_never_unknown_axislvif_write_trigoutsw_we (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (trigoutsw_we)
    );

`endif

endmodule // cxstm500_axislvif_write


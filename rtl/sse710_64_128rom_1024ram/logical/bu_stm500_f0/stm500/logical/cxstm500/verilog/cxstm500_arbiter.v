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
//      RTL design for STM Front End Arbiter
//-----------------------------------------------------------------------------

module cxstm500_arbiter #(
  parameter HWEVOBIF_PRESENT = 1,
  parameter STM_DATA_WIDTH = 64
  )
  (
  // Clock and Reset
  input wire                          clk_gated,             // Gated Clock
  input wire                          STMRESETn,             // Asynchronous Reset
  // AXI front end
  input  wire                         axi_tgu_valid_i,       // TGU Transfer Valid
  input  wire [7:0]                   axi_tgu_master_i,      // Master Number
  input  wire [15:0]                  axi_tgu_channel_i,     // STPv2 Channel Number
  input  wire [2:0]                   axi_tgu_packet_type_i, // STPv2 Packet Type
  input  wire [(STM_DATA_WIDTH/32):0] axi_tgu_size_i,        // Payload Size
  input  wire [STM_DATA_WIDTH-1:0]    axi_tgu_payload_i,     // Payload
  input  wire [1:0]                   axi_tgu_ts_req_i,      // Timestamp Qualifier
  input  wire                         axi_tgu_fready_i,      // Data flush completed
  output wire                         axi_tgu_ready_o,       // TGU Transfer Ready
  output wire                         axi_tgu_timestamped_o, // Timestamp Indicator
  output wire                         axi_tgu_fvalid_o,      // Data flush request
  // AXI
  input  wire                         axi_force_ts_req_i,    // Force timestamp request
  output wire                         axi_force_ts_ack_o,    // Force timestamp acknowledge
  // Hardware Event front end
  input  wire                         hw_tgu_valid_i,        // TGU Transfer Valid
  input  wire [7:0]                   hw_tgu_master_i,       // Master Number
  input  wire [15:0]                  hw_tgu_channel_i,      // STPv2 Channel Number
  input  wire [2:0]                   hw_tgu_packet_type_i,  // STPv2 Packet Type
  input  wire [(STM_DATA_WIDTH/32):0] hw_tgu_size_i,         // Payload Size
  input  wire [STM_DATA_WIDTH-1:0]    hw_tgu_payload_i,      // Payload
  input  wire [1:0]                   hw_tgu_ts_req_i,       // Timestamp Qualifier
  input  wire                         hw_tgu_fready_i,       // Data flush completed
  output wire                         hw_tgu_ready_o,        // TGU Transfer Ready
  output wire                         hw_tgu_fvalid_o,       // Data flush request
  // TGU Interface
  output wire                         tgu_valid_o,           // TGU Transfer Valid
  output wire [7:0]                   tgu_master_o,          // Master Number
  output wire [15:0]                  tgu_channel_o,         // STPv2 Channel Number
  output wire [2:0]                   tgu_packet_type_o,     // STPv2 Packet Type
  output wire [(STM_DATA_WIDTH/32):0] tgu_size_o,            // Payload Size
  output wire [STM_DATA_WIDTH-1:0]    tgu_payload_o,         // Payload
  output wire [1:0]                   tgu_ts_req_o,          // Timestamp Qualifier
  output wire                         tgu_fready_o,          // Data flush completed
  input  wire                         tgu_timestamped_i,     // TGU Transfer Ready
  input  wire                         tgu_ready_i,           // Timestamp Indicator
  input  wire                         tgu_fvalid_i,          // Data flush request
  // Triggers
  input  wire                         triggerspte_i,         // Trigger, matches using STMSPTER
  input  wire                         triggersw_i,           // Trigger, writes to TRIG location
  input  wire                         triggerhete_i,         // Trigger, matches using STMSPTER
  input  wire                         arb_atbtrigenspte_i,   // Enable ATB tigger generation from SPTE(ATID=0x7D)
  input  wire                         arb_atbtrigensw_i,     // Enable ATB tigger generation from SW(ATID=0x7D)
  input  wire                         arb_atbtrigenhete_i,   // Enable ATB tigger generation from HETE(ATID=0x7D)
  input  wire                         arb_flushprinvdis_i,   // Disable priority inversion between AXI/HW after AXI is flushed
  output wire                         tgu_trace_trigger_o    // TGU trigger input
  );

  //---------------------------------------------------------------------------
  // Constant definitions
  //---------------------------------------------------------------------------
  localparam  FL_IDLE       = 2'b00;    // Front ends are flushed - free from historical data
  localparam  FL_W_AXI      = 2'b01;    // Wait for AXI to be flushed
  localparam  FL_W_HW       = 2'b10;    // Wait for HW to be flushed
  localparam  FL_W_BOTH     = 2'b11;    // Wait for both AXU and HW to be flushed

  //---------------------------------------------------------------------------
  // Wires
  //---------------------------------------------------------------------------
  wire [1:0]   axi_tgu_ts_req;
  wire         axi_force_ts_ack;

  //If STM_DATA_WIDTH == 64 then tgu_if is 96 bits
  //TGU_IF is made up of:
  //  payload of width STM_DATA_WIDTH (64 or 32 bits)
  //  payload size of width STM_DATA_WIDTH/32 + 1 (3 or 2 bits)
  //  and 29 additional bits, hence:
  wire [(STM_DATA_WIDTH+(STM_DATA_WIDTH/32)+30):0]  axi_tgu_if;
  wire [(STM_DATA_WIDTH+(STM_DATA_WIDTH/32)+30):0]  hw_tgu_if;
  wire [(STM_DATA_WIDTH+(STM_DATA_WIDTH/32)+30):0]  tgu_if;

  wire         frontend_sel;
  wire         axi_flushed;
  wire         hw_flushed;
  wire         axi_tgu_fvalid;
  wire         hw_tgu_fvalid;
  wire         tgu_fready;

  //---------------------------------------------------------------------------
  // Registers
  //---------------------------------------------------------------------------
  reg [1:0]    fl_state_reg;
  reg [1:0]    nxt_fl_state;

  generate
  if (HWEVOBIF_PRESENT == 1)
  begin : gen_hw_intf
  //---------------------------------------------------------------------------
  //
  // Main body of code
  // =================
  //
  //---------------------------------------------------------------------------

  // Front end arbitration
  // 1 - AXI selected
  // 0 - HW selected
  // If there is ongoing flush
  //  a) AXI has priority over HW, until AXI is flushed
  //  b) - when AXI is flushed AXI will get priority if priority inversion is disabled
  //     - when AXI is flushed HW will get priority if priority inversion is not disabled
  // If there is no ongoing flush AXI has priority over HW

  assign frontend_sel =  tgu_fvalid_i ? (~axi_flushed)                                         |
                                        ( axi_flushed & arb_flushprinvdis_i & axi_tgu_valid_i) |
                                        ( axi_flushed & hw_flushed          & axi_tgu_valid_i)
                                       : axi_tgu_valid_i;

  assign axi_tgu_ts_req[1:0] = axi_tgu_ts_req_i[1:0] | {1'b0, axi_force_ts_req_i};
  assign axi_force_ts_ack    = frontend_sel & tgu_ready_i & tgu_timestamped_i;

                                                               // STM500
  assign axi_tgu_if = {axi_tgu_valid_i,                        // 96
                       axi_tgu_master_i[7:0],                  // 95:88
                       axi_tgu_channel_i[15:0],                // 87:72
                       axi_tgu_packet_type_i[2:0],             // 71:69
                       axi_tgu_size_i[(STM_DATA_WIDTH/32):0],  // 68:66
                       axi_tgu_payload_i[STM_DATA_WIDTH-1:0],  // 65:2
                       axi_tgu_ts_req[1:0]                     // 1:0
                       };
                                                               // STM500
  assign hw_tgu_if =  {hw_tgu_valid_i,                         // 96
                       hw_tgu_master_i[7:0],                   // 95:88
                       hw_tgu_channel_i[15:0],                 // 87:72
                       hw_tgu_packet_type_i[2:0],              // 71:69
                       hw_tgu_size_i[(STM_DATA_WIDTH/32):0],   // 68:66
                       hw_tgu_payload_i[STM_DATA_WIDTH-1:0],   // 65:2
                       hw_tgu_ts_req_i[1:0]                    // 1:0
                       };

  assign tgu_if = frontend_sel ? axi_tgu_if : hw_tgu_if;

  //---------------------------------------------------------------------------
  // Flush handling
  //---------------------------------------------------------------------------
  // FSM for handling flush of front ends
  // When flush is assereted from TGU, FSM waits until both front ends (AXI and HW)
  // are flushed before asserting tgu_fready for TGU
  // Depending on the state of fready from front ends FSM will move to
  // - W_BOTH, wait for both AXI and HW to flush
  // - W_HW, wait fro HW to flush
  // - W_AXI, wait for AXI to flush

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      fl_state_reg <= FL_IDLE;
    else
      fl_state_reg <= nxt_fl_state;
  end

  always @*
  begin
    case (fl_state_reg)
      FL_IDLE: begin
        // assertion present for tgu_fvalid_i being X
        if (~tgu_fvalid_i)
          nxt_fl_state = FL_IDLE;
        else
          case ({axi_tgu_fready_i, hw_tgu_fready_i})
            2'b11:   nxt_fl_state = FL_IDLE;
            2'b01:   nxt_fl_state = FL_W_AXI;
            2'b10:   nxt_fl_state = FL_W_HW;
            2'b00:   nxt_fl_state = FL_W_BOTH;
            // unreachable, X propagation only
            // VCS coverage off
            default: nxt_fl_state = 2'bxx;
            // VCS coverage on
          endcase
      end
      FL_W_AXI: begin
        nxt_fl_state = axi_tgu_fready_i ? FL_IDLE : FL_W_AXI;
      end
      FL_W_HW: begin
        nxt_fl_state = hw_tgu_fready_i ? FL_IDLE : FL_W_HW;
      end
      FL_W_BOTH: begin
        nxt_fl_state = axi_tgu_fready_i ? FL_W_HW : FL_W_BOTH;
      end
      // unreachable, X propagation only
      // VCS coverage off
      default: nxt_fl_state = 2'bxx;
      // VCS coverage on
    endcase
  end

  assign axi_flushed    = ((fl_state_reg[1:0] != FL_W_HW[1:0])  & axi_tgu_fready_i) | (fl_state_reg[1:0] == FL_W_HW[1:0]);
  assign hw_flushed     = ((fl_state_reg[1:0] != FL_W_AXI[1:0]) & hw_tgu_fready_i) | (fl_state_reg[1:0] == FL_W_AXI[1:0]);

  assign axi_tgu_fvalid = ((fl_state_reg[1:0] != FL_W_HW[1:0])  & tgu_fvalid_i);
  assign hw_tgu_fvalid  = ((fl_state_reg[1:0] != FL_W_AXI[1:0]) & tgu_fvalid_i);

  assign tgu_fready     = ((fl_state_reg[1:0] == FL_IDLE[1:0])  & axi_tgu_fready_i & hw_tgu_fready_i) |
                          ((fl_state_reg[1:0] == FL_W_AXI[1:0]) & axi_tgu_fready_i)                   |
                          ((fl_state_reg[1:0] == FL_W_HW[1:0])                     & hw_tgu_fready_i);

  //----------------------------------------------------------------------------
  // Output assignment
  //----------------------------------------------------------------------------

  // TGU i/f
  if (STM_DATA_WIDTH == 64) begin
    assign tgu_valid_o           = tgu_if[96];
    assign tgu_master_o          = tgu_if[95:88];
    assign tgu_channel_o         = tgu_if[87:72];
    assign tgu_packet_type_o     = tgu_if[71:69];
    assign tgu_size_o            = tgu_if[68:66];
    assign tgu_payload_o         = tgu_if[65:2];
    assign tgu_ts_req_o          = tgu_if[1:0];

  end

  assign tgu_fready_o          = tgu_fready;

  // TGU status i/f
  assign axi_force_ts_ack_o    = axi_force_ts_ack;

  // TGU i/f for AXI front end
  assign axi_tgu_ready_o       = frontend_sel & tgu_ready_i;
  assign axi_tgu_timestamped_o = frontend_sel & tgu_timestamped_i;
  assign axi_tgu_fvalid_o      = axi_tgu_fvalid;

  // TGU i/f for HW front end
  assign hw_tgu_ready_o        = ~frontend_sel & tgu_ready_i;
  assign hw_tgu_fvalid_o       = hw_tgu_fvalid;

  // TGU trigger i/f
  assign tgu_trace_trigger_o   = (arb_atbtrigenspte_i & triggerspte_i) |
                                 (arb_atbtrigensw_i   & triggersw_i)   |
                                 (arb_atbtrigenhete_i & triggerhete_i);

  end
  else  // else generate
  begin : gen_no_hw_intf
  // No HW

  assign axi_tgu_ts_req[1:0] = axi_tgu_ts_req_i[1:0] | {1'b0, axi_force_ts_req_i};
  assign axi_force_ts_ack    = tgu_ready_i & tgu_timestamped_i;

  //----------------------------------------------------------------------------
  // Output assignment
  //----------------------------------------------------------------------------

  // TGU i/f
  assign tgu_valid_o                       = axi_tgu_valid_i;
  assign tgu_master_o[7:0]                 = axi_tgu_master_i[7:0];
  assign tgu_channel_o[15:0]               = axi_tgu_channel_i[15:0];
  assign tgu_packet_type_o[2:0]            = axi_tgu_packet_type_i[2:0];
  assign tgu_size_o[(STM_DATA_WIDTH/32):0] = axi_tgu_size_i[(STM_DATA_WIDTH/32):0];
  assign tgu_payload_o[STM_DATA_WIDTH-1:0] = axi_tgu_payload_i[STM_DATA_WIDTH-1:0];
  assign tgu_ts_req_o[1:0]                 = axi_tgu_ts_req[1:0];
  assign tgu_fready_o                      = axi_tgu_fready_i;

  // TGU status i/f
  assign axi_force_ts_ack_o     = axi_force_ts_ack;

  // TGU i/f for AXI front end
  assign axi_tgu_ready_o        = tgu_ready_i;
  assign axi_tgu_timestamped_o  = tgu_timestamped_i;
  assign axi_tgu_fvalid_o       = tgu_fvalid_i;

  // TGU i/f for HW front end
  assign hw_tgu_ready_o         = 1'b0;
  assign hw_tgu_fvalid_o        = 1'b0;

  // TGU trigger i/f
  assign tgu_trace_trigger_o    = (arb_atbtrigenspte_i & triggerspte_i) |
                                  (arb_atbtrigensw_i   & triggersw_i);

  wire unused_ok;
  assign unused_ok = &{1'b0,
                       clk_gated,
                       STMRESETn,
                       hw_tgu_valid_i,
                       hw_tgu_master_i[7:0],
                       hw_tgu_channel_i[15:0],
                       hw_tgu_packet_type_i[2:0],
                       hw_tgu_size_i[(STM_DATA_WIDTH/32):0],
                       hw_tgu_payload_i[STM_DATA_WIDTH-1:0],
                       hw_tgu_ts_req_i[1:0],
                       hw_tgu_fready_i,
                       triggerhete_i,
                       arb_atbtrigenhete_i,
                       arb_flushprinvdis_i,
                       1'b0};

  end
  endgenerate

`ifdef ARM_ASSERT_ON
  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------

  generate
  if (HWEVOBIF_PRESENT == 1)
  begin : gen_ovl_hw_intf
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"If arbiter waits for AXI front end, AXI must have transaction pending ")
    ovl_never_arbiter_axi_no_transaction_pending (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr ((fl_state_reg[1:0]==FL_W_AXI[1:0]) & ~axi_tgu_valid_i & ~axi_tgu_fready_i)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"If arbiter waits for HW front end, HW must have transaction pending ")
    ovl_never_arbiter_hw_no_transaction_pending (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr ((fl_state_reg[1:0]==FL_W_HW[1:0]) & ~hw_tgu_valid_i & ~hw_tgu_fready_i)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"If arbiter waits for both front ends, HW cannot acknowledge first ")
    ovl_never_arbiter_hw_ack_before_axi_ack (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr ((fl_state_reg[1:0]==FL_W_BOTH[1:0]) & ~axi_tgu_fready_i & hw_tgu_fready_i)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"If arbiter waits for both front ends, both cannot acknowledge at the same time ")
    ovl_never_arbiter_hw_axi_simultaneous_ack (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr ((fl_state_reg[1:0]==FL_W_BOTH[1:0]) & axi_tgu_fready_i & hw_tgu_fready_i)
    );

  // X propagation

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "nxt_fl_state is X")
    ovl_never_unknown_arbiter_nxt_fl_state (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (nxt_fl_state)
    );

  end

  // X propagation
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "tgu_fvalid_i is X")
    ovl_never_unknown_arbiter_tgu_fvalid_i (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (tgu_fvalid_i)
    );



  endgenerate
`endif
endmodule  // cxstm500_tgu_atbmast

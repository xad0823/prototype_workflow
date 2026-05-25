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
//      RTL design for STM TGU Packer and ATB Master Interface
//-----------------------------------------------------------------------------

module cxstm500_tgu_packetgen #(
  parameter                               STM_DATA_WIDTH = 64   // STM Datapath width
  )
  (
  // Clock and Reset
  input wire                              clk_gated,            // gated clock
  input wire                              STMRESETn,            // asynchronous reset

  // Configuration interface
  input wire [31:0]                       tgu_cfg_tsfreqr_i,    // timestamp frequency

  // FIFO interface
  input wire                              ctrl_out_valid_i,     // control fifo ready
  input wire [3:0]                        ctrl_out_data_i,      // control fifo data
  output wire                             ctrl_out_ready_o,     // control fifo data ready

  input wire [(STM_DATA_WIDTH+(STM_DATA_WIDTH/32)+27):0] data_out_data_i,       // data fifo data

  output wire                             data_out_ready_o,     // data fifo data ready
  input wire [26:0]                       ch_out_data_i,        // channel fifo data
  output wire                             ch_out_ready_o,       // channel fifo data ready
  input wire [49:0]                       extts_out_data_i,     // MSB timestamp fifo data
  output wire                             extts_out_ready_o,    // MSB timestamp fifo data ready

  // Packer interface
  input wire                              packer_done_i,        // end of pack sequence
  output wire                             packets_valid_o,      // packets valid
  output wire [1:0]                       pack_sequence_o,      // type of packing sequence
  output wire [2:0]                       packer_request_o,     // packing request
  output wire [59:0]                      async1_packet_o,      // 1st part of async sequence
  output wire [3:0]                       async1_packet_size_o, // size of 1st part of async sequence
  output wire [35:0]                      async2_packet_o,      // 2nd part of async sequence
  output wire [3:0]                       async2_packet_size_o, // size of 2nd part of async sequence
  output wire [59:0]                      async3_packet_o,      // 3rd part of async sequence
  output wire [3:0]                       async3_packet_size_o, // size of 3rd part of async sequence
  output wire [35:0]                      mc_packet_o,          // master and channel packet
  output wire [3:0]                       mc_packet_size_o,     // size of mc packet
  output wire [(STM_DATA_WIDTH+27):0]     data_packet_o,        // data packet with lower bit of timestamp
  output wire [((STM_DATA_WIDTH/32)+2):0] data_packet_size_o,   // size of data packet
  output wire [47:0]                      extts_packet_o,       // upper bits of timestamp
  output wire [3:0]                       extts_packet_size_o,  // size of extended timestamp packet
  output wire                             flush_req_o,          // flush request

  // Cross-trigger
  output wire                             asyncout_o,           // async sequence has been output

  // Integration testing
  input wire                              itctl_i,              // integration mode
  input wire                              ittrigger_we_i,       // write to ITTRIGGER register
  input wire                              pwdatadbg3_r_i        // APB write data, bit 1

  );

  //---------------------------------------------------------------------------
  // Constant definitions
  //---------------------------------------------------------------------------

  localparam CTRL_TYPE_NOT_USED  = 2'b00;
  localparam CTRL_TYPE_OPCODE    = 2'b01;
  localparam CTRL_TYPE_ASYNC     = 2'b10;
  localparam CTRL_TYPE_TSONLY    = 2'b11;

  localparam STPV2NAT            = 4'h3;

  localparam STPV2_C8            = 4'h3;
  localparam STPV2_M8            = 4'h1;

  //---------------------------------------------------------------------------
  // Wires
  //---------------------------------------------------------------------------
  wire        mc_needed;
  reg  [35:0] mc_packet;
  reg  [3:0]  mc_packet_size;
  wire        data_needed;
  wire [(STM_DATA_WIDTH+27):0] data_packet;
  wire [3:0]  stpv2_opcode;
  wire        stpv2_opcode_ext;
  wire        extts_needed;
  wire [59:0] async1_packet;
  wire [3:0]  async1_packet_size;
  wire [35:0] async2_packet;
  wire [3:0]  async2_packet_size;
  wire [59:0] async3_packet;
  wire [3:0]  async3_packet_size;
  wire [3:0]  version;
  wire [43:0] freq_packet;
  wire        nxt_asyncout;
  wire        asyncout_we;
  wire [2:0]  packer_request;

  //---------------------------------------------------------------------------
  // Registers
  //---------------------------------------------------------------------------
  reg         asyncout_reg;

  //---------------------------------------------------------------------------
  //
  // Main body of code
  // =================
  //
  //---------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  // Packet building
  //---------------------------------------------------------------------------

  // SYNC sequence packets
  // STM sync sequence is:
  //   ASYNC
  //   VERSION
  //   FREQ (only if timestamping is enabled
  // sync sequence is broken down in 3 packets for packing purpose
  // 1st packet is 15 nibbles long and contains first part of ASYNC
  assign async1_packet[59:0] = {60{1'b1}};
  assign async1_packet_size[3:0] = 4'd15;

  // 2nd packet is 9 nibbles long and contains remaining part of ASYNC and first 2 opcode nibbles of VERSION
  assign async2_packet[35:0] = {4'h0,           // VERSION opcode
                                4'hF,           // VERSION opcode
                                4'h0,           // ending of ASYNC
                                4'hF,           // ASYNC
                                4'hF,           // ASYNC
                                4'hF,           // ASYNC
                                4'hF,           // ASYNC
                                4'hF,           // ASYNC
                                4'hF            // ASYNC
                               };
  assign async2_packet_size[3:0] = 4'd9;
  // 3rd packet is either 2 or 13 nibbles long
  // - the first 2 nibbles are - 3rd VERSION opcode and VERSION payload
  // - if timestamping was enabled when ASYNC request was put into FIFO
  //   additional 11 nible long FREQ packet is added
  assign version[3:0] = STPV2NAT;
  assign freq_packet[43:0] = ctrl_out_data_i[2] ? {tgu_cfg_tsfreqr_i[3:0],   // FREQ payload;
                                                   tgu_cfg_tsfreqr_i[7:4],   // FREQ payload
                                                   tgu_cfg_tsfreqr_i[11:8],  // FREQ payload
                                                   tgu_cfg_tsfreqr_i[15:12], // FREQ payload
                                                   tgu_cfg_tsfreqr_i[19:16], // FREQ payload
                                                   tgu_cfg_tsfreqr_i[23:20], // FREQ payload
                                                   tgu_cfg_tsfreqr_i[27:24], // FREQ payload
                                                   tgu_cfg_tsfreqr_i[31:28], // FREQ payload
                                                   4'h8,                     // FREQ opcode
                                                   4'h0,                     // FREQ opcode
                                                   4'hF                      // FREQ opcode
                                                  }:
                                                  {44{1'b0}};

  assign async3_packet[59:0] = {4'h0,                     // not used
                                4'h0,                     // not used
                                freq_packet[43:40],       // FREQ packet
                                freq_packet[39:36],       // FREQ packet
                                freq_packet[35:32],       // FREQ packet
                                freq_packet[31:28],       // FREQ packet
                                freq_packet[27:24],       // FREQ packet
                                freq_packet[23:20],       // FREQ packet
                                freq_packet[19:16],       // FREQ packet
                                freq_packet[15:12],       // FREQ packet
                                freq_packet[11:8],        // FREQ packet
                                freq_packet[7:4],         // FREQ packet
                                freq_packet[3:0],         // FREQ packet
                                version[3:0],             // VERSION
                                4'h0                      // VERSION opcode
                               };

  assign async3_packet_size[3:0] = ctrl_out_data_i[2] ? 4'd13 : 4'd2;

  // MASTER & CHANNEL packet
  assign mc_needed = ctrl_out_data_i[1] & ctrl_out_data_i[0];
  always @*
  begin
    case (ch_out_data_i[26:24])
      3'b001 : mc_packet[35:0] = {{24{1'b0}}, ch_out_data_i[3:0], ch_out_data_i[7:4], STPV2_M8[3:0]};
      3'b010 : mc_packet[35:0] = {{24{1'b0}}, ch_out_data_i[11:8], ch_out_data_i[15:12], STPV2_C8[3:0]};
      3'b100 : mc_packet[35:0] = {{12{1'b0}}, ch_out_data_i[11:8], ch_out_data_i[15:12], ch_out_data_i[19:16], ch_out_data_i[23:20], STPV2_C8[3:0], 4'hF};
      3'b011 : mc_packet[35:0] = {{12{1'b0}}, ch_out_data_i[11:8], ch_out_data_i[15:12], STPV2_C8[3:0], ch_out_data_i[3:0], ch_out_data_i[7:4], STPV2_M8[3:0]};
      3'b101 : mc_packet[35:0] = {ch_out_data_i[11:8], ch_out_data_i[15:12], ch_out_data_i[19:16], ch_out_data_i[23:20], STPV2_C8[3:0], 4'hF, ch_out_data_i[3:0], ch_out_data_i[7:4], STPV2_M8[3:0]};
      // assertion present for illegal states - uzovl_4
      // VCS coverage off
      default: mc_packet[35:0] = {36{1'bx}};
      // VCS coverage on
    endcase
  end

  always @*
  begin
    case (ch_out_data_i[26:24])
      3'b001 : mc_packet_size[3:0] = 4'd3;      // M8
      3'b010 : mc_packet_size[3:0] = 4'd3;      // C8
      3'b100 : mc_packet_size[3:0] = 4'd6;      // C16
      3'b011 : mc_packet_size[3:0] = 4'd6;      // M8C8
      3'b101 : mc_packet_size[3:0] = 4'd9;      // M8C16
      // assertion present for illegal states - uzovl_4
      // VCS coverage off
      default: mc_packet_size[3:0] = {4{1'bx}};
      // VCS coverage on
    endcase
  end

  // DATA packet
  // data packet is needed when control word indicates that data fifo is used
  assign data_needed       = ctrl_out_data_i[0];

  generate
    if (STM_DATA_WIDTH == 64) begin : gen_data_packet_64
      assign stpv2_opcode_ext  = data_out_data_i[88];
      assign stpv2_opcode      = data_out_data_i[87:84];

      assign data_packet[91:0]   = stpv2_opcode_ext ? {data_out_data_i[83:0], stpv2_opcode[3:0], {4{stpv2_opcode_ext}}} :
                                                      {4'h0, data_out_data_i[83:0], stpv2_opcode[3:0]};

    end


  endgenerate

  // Extended TIMESTAMP packet
  assign extts_needed        = ctrl_out_data_i[2] & ctrl_out_data_i[0];

  // Packer request
  assign packer_request[2:0] = ctrl_out_data_i[0] ? {extts_needed, data_needed, mc_needed} :
                                                    {1'b1, 1'b1, 1'b1};
  //---------------------------------------------------------------------------
  // Cross-trigger
  //---------------------------------------------------------------------------
  assign nxt_asyncout =  itctl_i ? pwdatadbg3_r_i :
                                   ctrl_out_valid_i & packer_done_i & (ctrl_out_data_i[1:0]==2'b10);

  assign asyncout_we  = ~itctl_i | ittrigger_we_i;

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      asyncout_reg <= 1'b0;
    else if (asyncout_we)
      asyncout_reg <= nxt_asyncout;
  end

  //----------------------------------------------------------------------------
  // Output assignment
  //----------------------------------------------------------------------------
  // Packets
  assign packets_valid_o            = ctrl_out_valid_i;
  assign pack_sequence_o[1:0]       = ctrl_out_data_i[1:0];
  assign packer_request_o[2:0]      = packer_request[2:0];

  assign async1_packet_o[59:0]      = async1_packet[59:0];
  assign async1_packet_size_o[3:0]  = async1_packet_size[3:0];
  assign async2_packet_o[35:0]      = async2_packet[35:0];
  assign async2_packet_size_o[3:0]  = async2_packet_size[3:0];
  assign async3_packet_o[59:0]      = async3_packet[59:0];
  assign async3_packet_size_o[3:0]  = async3_packet_size[3:0];

  // MC packet
  assign mc_packet_o[35:0]          = mc_packet[35:0];
  assign mc_packet_size_o[3:0]      = mc_packet_size[3:0];

  // Data packet
  generate
    if (STM_DATA_WIDTH == 64) begin : gen_data_out_64
      assign data_packet_o[91:0]        = data_packet[91:0];
      assign data_packet_size_o[4:0]    = data_out_data_i[93:89];

    end

  endgenerate

  assign extts_packet_o[47:0]       = extts_out_data_i[47:0];
  assign extts_packet_size_o[3:0]   = {extts_out_data_i[49:48], 2'b00};

  // Flush request
  assign flush_req_o = ctrl_out_data_i[3];

  // FIFO controls
  assign ctrl_out_ready_o  = packer_done_i;
  assign ch_out_ready_o    = ctrl_out_valid_i & packer_done_i & (ctrl_out_data_i[0]==1'b1) & packer_request[0];
  assign data_out_ready_o  = ctrl_out_valid_i & packer_done_i & (ctrl_out_data_i[0]==1'b1);
  assign extts_out_ready_o = ctrl_out_valid_i & packer_done_i & (ctrl_out_data_i[0]==1'b1) & packer_request[2];

  // Cross-triggering
  assign asyncout_o = asyncout_reg;

`ifdef ARM_ASSERT_ON
  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------

  // X propagation
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "asyncout_we is X")
    ovl_never_unknown_packetgen_asyncout_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (asyncout_we)
    );

  assert_never_unknown #(`OVL_FATAL, 36, `OVL_ASSERT, "mc_packet is X")
    ovl_never_unknown_packetgen_mc_packet (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (mc_needed),
      .test_expr (mc_packet)
    );

  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "mc_packet_size is X")
    ovl_never_unknown_packetgen_mc_packet_size (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (mc_needed),
      .test_expr (mc_packet_size)
    );

`endif

endmodule  // cxstm500_tgu_packetgen

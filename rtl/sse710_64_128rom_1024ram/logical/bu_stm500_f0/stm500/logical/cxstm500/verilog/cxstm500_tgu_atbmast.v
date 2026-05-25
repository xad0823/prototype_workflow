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

module cxstm500_tgu_atbmast #(
  parameter                              STM_DATA_WIDTH = 64    // STM Data Path Width
  )
  (
  // Clock and Reset
  input wire                             clk_gated,             // gated clock
  input wire                             STMRESETn,             // asynchronous reset

  // Configuration interface
  input wire                             tgu_cfg_enable_i,      // TGU enable
  input wire [6:0]                       tgu_cfg_traceid_i,     // ID for ATB
  input wire                             tgu_cfg_fifoaf_i,      // enable fifo auto-fulsh
  input wire                             tgu_cfg_freadyhigh_i,  // control for driving AFREADY high
  input wire                             tgu_fifo_empty_i,      // fifo empty
  input wire                             tgu_flush_i,           // Flush from TGU input
  input wire                             tgu_busy_i,            // TGU busy
  output wire                            atb_busy_o,            // ATB or Packer busy

  // Packet interface
  input wire                             packets_valid_i,       // packets valid
  input wire [1:0]                       pack_sequence_i,       // type of packing sequence
  input wire [2:0]                       packer_request_i,      // packing request
  input wire [59:0]                      async1_packet_i,       // 1st part of async sequence
  input wire [3:0]                       async1_packet_size_i,  // size of 1st part of async sequence
  input wire [35:0]                      async2_packet_i,       // 2nd part of async sequence
  input wire [3:0]                       async2_packet_size_i,  // size of 2nd part of async sequence
  input wire [59:0]                      async3_packet_i,       // 3rd part of async sequence
  input wire [3:0]                       async3_packet_size_i,  // size of 3rd part of async sequence
  input wire [35:0]                      mc_packet_i,           // master and channel packet
  input wire [3:0]                       mc_packet_size_i,      // size of mc packet
  input wire [(STM_DATA_WIDTH+27):0]     data_packet_i,         // data packet with lower bit of timestamp
  input wire [((STM_DATA_WIDTH/32)+2):0] data_packet_size_i,    // size of data packet
  input wire [47:0]                      extts_packet_i,        // upper bits of timestamp
  input wire [3:0]                       extts_packet_size_i,   // size of extended timestamp packet
  input wire                             flush_req_i,           // flush request

  output wire                            packer_done_o,         // end of pack sequence

  // Trace trigger interface
  input wire                             tgu_trace_trigger_i,   // Trace trigger input

  // ATB interface
  input  wire                            ATREADYM,              // ATB ready
  input  wire                            AFVALIDM,              // ATB flush valid

  output wire                            atvalid_o,             // ATB valid
  output wire [(STM_DATA_WIDTH/32):0]    ATBYTESM,              // ATB bytes
  output wire [STM_DATA_WIDTH-1:0]       ATDATAM,               // ATB data
  output wire [6:0]                      ATIDM,                 // ATB ID
  output wire                            afreadym_o,            // ATB flush ready

  // Integration testing
  input wire                             itctl_i,               // integration mode
  input wire                             itatbdata0_we_i,       // write to ITATBDATA0 register
  input wire                             itatbid_we_i,          // write to ITATBID register
  input wire                             itatbctr0_we_i,        // write to ITATBCTR0 register
  input wire [10:0]                      pwdatadbg10_0_r_i,     // APB data 10:0

  // Q-Channel
  input wire                             q_stopped_i,           // Q_Channel STOPPED
  input wire                             q_flush_i              // Q-Channel initiated autoflush
  );

  //---------------------------------------------------------------------------
  // Constant definitions
  //---------------------------------------------------------------------------
  localparam ATB_TRACE_TRIGGER_ID = 7'h7D;

  localparam FLUSH_IDLE    = 2'b00;
  localparam FLUSH_ONGOING = 2'b11;
  localparam FLUSH_ONE     = 2'b10;

  //---------------------------------------------------------------------------
  // Wires
  //---------------------------------------------------------------------------
  wire [(2*STM_DATA_WIDTH)+23:0] packed_data;
  wire [(STM_DATA_WIDTH-5):0]    nxt_residual_data;
  wire [(STM_DATA_WIDTH/32)+1:0] nxt_residual_data_size;
  wire                           residual_data_we;
  wire                           residual_data_size_we;
  wire [STM_DATA_WIDTH-1:0]      nxt_aux_data;

  wire                           mux1_enable;
  wire [1:0]                     mux1_ctrl;
  wire [3:0]                     mux1_size;
  wire [35:0]                    mux1_1;
  wire [35:0]                    mux1_2;
  wire [35:0]                    mux1_out;
  wire                           shift1_enable;
  wire [35:0]                    shift1_in;
  wire [(STM_DATA_WIDTH/32)+2:0] shift1_ctrl;
  wire [(2*STM_DATA_WIDTH)-1:0]  shift1_out;
  wire [(2*STM_DATA_WIDTH)-1:0]  shift1_1;
  wire [(2*STM_DATA_WIDTH)-1:0]  shift1_2;
  wire [(2*STM_DATA_WIDTH)-1:0]  shift1_4;
  wire [(2*STM_DATA_WIDTH)-1:0]  shift1_8;
  wire [(2*STM_DATA_WIDTH)-1:0]  shift1_16;

  wire                           mux2_enable;
  wire [1:0]                     mux2_ctrl;
  wire [(STM_DATA_WIDTH/32)+2:0] mux2_size;
  wire [(STM_DATA_WIDTH+27):0]   mux2_1;
  wire [(STM_DATA_WIDTH+27):0]   mux2_2;
  wire [(STM_DATA_WIDTH+27):0]   mux2_out;
  wire                           shift2_enable;
  wire [(STM_DATA_WIDTH+27):0]   shift2_in;
  wire [(STM_DATA_WIDTH/32)+2:0] shift2_ctrl;
  wire [(2*STM_DATA_WIDTH)+23:0] shift2_out;
  wire [(2*STM_DATA_WIDTH)+23:0] shift2_1;
  wire [(2*STM_DATA_WIDTH)+23:0] shift2_2;
  wire [(2*STM_DATA_WIDTH)+23:0] shift2_4;
  wire [(2*STM_DATA_WIDTH)+23:0] shift2_8;
  wire [(2*STM_DATA_WIDTH)+23:0] shift2_16;

  wire                           use_one_mux;
  wire                           m12_sel;
  wire [(STM_DATA_WIDTH/32)+3:0] pack1_size;
  wire [(STM_DATA_WIDTH/32)+3:0] pack2_size;
  wire [(STM_DATA_WIDTH/32)+3:0] pack_size;

  wire                           packets_valid;
  wire [2:0]                     pack_request_masked;
  wire [2:0]                     pack_done_mask_r1;
  wire [2:0]                     pack_done_mask_r2;
  wire [2:0]                     pack_done_mask_m;
  wire [2:0]                     next_mask;
  wire [1:0]                     nxt_pack_done_mask;
  wire                           pack_done_mask_we;

  wire                           aux_data_we;
  wire                           aux_valid_set;
  wire                           aux_valid_clear;
  wire                           aux_valid_we;
  wire                           aux_data_source;
  wire                           nxt_aux_valid;
  wire                           atb_data_load;
  wire                           atb_valid_clear;
  wire                           atb_data_source;
  wire                           uop_done;
  wire                           last_uop;
  wire                           packer_done;
  wire                           dword_taken;
  wire                           dword_taken_we;

  wire                           flush_done;
  reg  [(STM_DATA_WIDTH/32):0]   flush_atbytes;
  wire                           flush_uop;
  reg                            atb_flushed;
  reg  [1:0]                     nxt_fl_state;
  wire                           local_flush;
  wire                           nxt_flushed;
  wire                           flushed_we;

  wire                           nxt_trace_trigger;
  wire                           trace_trigger_we;

  wire                           packer_busy;
  wire                           trigger_busy;
  wire                           atb_busy;

  // atb interface
  wire [STM_DATA_WIDTH-1:0]     int_data;
  wire [STM_DATA_WIDTH-1:0]     nxt_atdata_int;
  wire [STM_DATA_WIDTH-1:0]     nxt_atdata_f;
  wire [STM_DATA_WIDTH-1:0]     nxt_atdata_tt;
  wire [STM_DATA_WIDTH-1:0]     nxt_atdata;
  wire [(STM_DATA_WIDTH/32):0]  nxt_atbytes_int;
  wire [(STM_DATA_WIDTH/32):0]  nxt_atbytes_f;
  wire [(STM_DATA_WIDTH/32):0]  nxt_atbytes_tt;
  wire [(STM_DATA_WIDTH/32):0]  nxt_atbytes;
  wire [6:0]                    nxt_atid_int;
  wire [6:0]                    nxt_atid_tt;
  wire [6:0]                    nxt_atid;
  wire                          nxt_atvalid;
  wire                          nxt_afready;
  wire        atvalid_we;
  wire        atb_we;
  wire        afready_we;

  //---------------------------------------------------------------------------
  // Registers
  //---------------------------------------------------------------------------
  reg [STM_DATA_WIDTH-1:0]    atdata_reg;
  reg [(STM_DATA_WIDTH/32):0] atbytes_reg;
  reg [6:0]                   atid_reg;
  reg                         atvalid_reg;
  reg                         afready_reg;
  reg [STM_DATA_WIDTH-1:0]      aux_data_reg;
  reg                           aux_valid_reg;
  reg [STM_DATA_WIDTH-5:0]      residual_data_reg;
  reg [(STM_DATA_WIDTH/32)+1:0] residual_data_size_reg;
  reg [1:0]                     pack_done_mask_reg;
  reg                           dword_taken_reg;
  reg                           trace_trigger_reg;
  reg [1:0]                     fl_state_reg;
  reg                           flushed_reg;

  //---------------------------------------------------------------------------
  //
  // Main body of code
  // =================
  //
  //---------------------------------------------------------------------------

  //---------------------------------------------------------------------------
  // Packer datapath (Configurable for 32 or 64-bit datapath)
  //---------------------------------------------------------------------------
  // Packer datapath consists of:
  // - 2 left shifters which can shift their input by up to 15 (32-bit datapath)
  //   or 31 (64-bit datapath) nibbles
  // - muxes in front of each shifter
  //
  // Mux - shift 1
  // Mux1 muxes following inputs from packetgen sub-block
  //                                  32-bit | 64-bit
  // 0. master/channel packet       | [35:0] | [35:0]
  // 1. unused                      |  N/A   |  N/A
  // 2. extended timestamp packet   | [31:0] | [31:0]
  // 3. 2nd part of async sequence  | [35:0] | [35:0]
  //
  assign mux1_1[35:0]   = mc_packet_i[35:0];

  assign mux1_2[35:0]   = mux1_ctrl[0]
                        ? async2_packet_i[35:0]
                        : extts_packet_i[35:0];

  assign mux1_out[35:0] = mux1_ctrl[1]
                        ? mux1_2[35:0]
                        : mux1_1[35:0];

  assign shift1_in[35:0] = {36{shift1_enable}} & mux1_out[35:0];

  // Shift left one nibble
  assign shift1_1[(2*STM_DATA_WIDTH)-1:0] = shift1_ctrl[0]
                                          ? {{((2*STM_DATA_WIDTH)-40){1'b0}}, shift1_in[35:0], {4{1'b0}}}
                                          : {{((2*STM_DATA_WIDTH)-36){1'b0}}, shift1_in[35:0]};

  // Shift left two nibbles
  assign shift1_2[(2*STM_DATA_WIDTH)-1:0] = (shift1_ctrl[1]
                                          ? {shift1_1[(2*STM_DATA_WIDTH)-9:0], {8{1'b0}}}
                                          :  shift1_1[(2*STM_DATA_WIDTH)-1:0]);

  // Shift left four nibbles
  assign shift1_4[(2*STM_DATA_WIDTH)-1:0] = (shift1_ctrl[2]
                                          ? {shift1_2[(2*STM_DATA_WIDTH)-17:0], {16{1'b0}}}
                                          :  shift1_2[(2*STM_DATA_WIDTH)-1:0]);

  // Shift left eight nibbles
  assign shift1_8[(2*STM_DATA_WIDTH)-1:0] = (shift1_ctrl[3]
                                          ? {shift1_4[(2*STM_DATA_WIDTH)-33:0], {32{1'b0}}}
                                          :  shift1_4[(2*STM_DATA_WIDTH)-1:0]);

  generate
    if (STM_DATA_WIDTH == 64) begin : gen_shift1_64

      // Shift left sixteen nibbles
      assign shift1_16[(2*STM_DATA_WIDTH)-1:0] = (shift1_ctrl[4]
                                                ? {shift1_8[(2*STM_DATA_WIDTH)-65:0], {64{1'b0}}}
                                                :  shift1_8[(2*STM_DATA_WIDTH)-1:0]);

      assign shift1_out[(2*STM_DATA_WIDTH)-1:0] = shift1_16[(2*STM_DATA_WIDTH)-1:0];

    end


  endgenerate

  // Mux - shift 2
  // Mux1 muxes following inputs from packetgen sub-block
  //                                  32-bit | 64-bit
  // 0. data packet                 | [59:0] | [91:0]
  // 1. 1st part of async sequence  | [59:0] | [59:0]
  // 2. extended timestamp packet   | [47:0] | [47:0]
  // 3. 3rd part of async sequence  | [59:0] | [59:0]
  //
  assign mux2_1[(STM_DATA_WIDTH+27):0]   = mux2_ctrl[0]
                                         ? {{STM_DATA_WIDTH-32{1'b0}}, async1_packet_i[59:0]}
                                         : data_packet_i[STM_DATA_WIDTH+27:0];

  assign mux2_2[(STM_DATA_WIDTH+27):0]   = mux2_ctrl[0]
                                         ? {{STM_DATA_WIDTH-32{1'b0}}, async3_packet_i[59:0]}
                                         : {{STM_DATA_WIDTH-20{1'b0}}, extts_packet_i[47:0]};

  assign mux2_out[(STM_DATA_WIDTH+27):0] = mux2_ctrl[1]
                                         ? mux2_2[(STM_DATA_WIDTH+27):0]
                                         : mux2_1[(STM_DATA_WIDTH+27):0];

  assign shift2_in[(STM_DATA_WIDTH+27):0] = {(STM_DATA_WIDTH+28){shift2_enable}} & mux2_out[(STM_DATA_WIDTH+27):0];

  // Shift left one nibble
  assign shift2_1[(2*STM_DATA_WIDTH)+23:0] = shift2_ctrl[0]
                                           ? {{(STM_DATA_WIDTH-8){1'b0}}, shift2_in[(STM_DATA_WIDTH+27):0], {4{1'b0}}}
                                           : {{(STM_DATA_WIDTH-4){1'b0}}, shift2_in[(STM_DATA_WIDTH+27):0]};

  // Shift left two nibbles
  assign shift2_2[(2*STM_DATA_WIDTH)+23:0] = (shift2_ctrl[1]
                                           ? {shift2_1[(2*STM_DATA_WIDTH)+15:0], {8{1'b0}}}
                                           :  shift2_1[(2*STM_DATA_WIDTH)+23:0]);

  // Shift left four nibbles
  assign shift2_4[(2*STM_DATA_WIDTH)+23:0] = (shift2_ctrl[2]
                                           ? {shift2_2[(2*STM_DATA_WIDTH)+7:0], {16{1'b0}}}
                                           :  shift2_2[(2*STM_DATA_WIDTH)+23:0]);

  // Shift left eight nibbles
  assign shift2_8[(2*STM_DATA_WIDTH)+23:0] = (shift2_ctrl[3]
                                           ? {shift2_4[(2*STM_DATA_WIDTH)-9:0], {32{1'b0}}}
                                           :  shift2_4[(2*STM_DATA_WIDTH)+23:0]);

  generate
    if (STM_DATA_WIDTH == 64) begin : gen_shift2_64

      // Shift left sixteen nibbles
      assign shift2_16[(2*STM_DATA_WIDTH)+23:0] = (shift2_ctrl[4]
                                                ? {shift2_8[(2*STM_DATA_WIDTH)-41:0], {64{1'b0}}}
                                                :  shift2_8[(2*STM_DATA_WIDTH)+23:0]);

      assign shift2_out[(2*STM_DATA_WIDTH)+23:0] = shift2_16[(2*STM_DATA_WIDTH)+23:0];

    end


  endgenerate

  assign packed_data[(2*STM_DATA_WIDTH)+23:0] = {{(STM_DATA_WIDTH+28){1'b0}}, residual_data_reg[(STM_DATA_WIDTH-5):0]} |
                                                                 {{24{1'b0}}, shift1_out[(2*STM_DATA_WIDTH)-1:0]}      |
                                                                              shift2_out[(2*STM_DATA_WIDTH)+23:0];

  // Auxiliary registers take excess data from packing operation
  // residual_data_reg takes leftover data from packing into 32-bit/64-bit words depending on configuration
  //
  // 32-bit: size of data in residual data register can be up to 28 bits i.e. 7 nibbles
  // In terms of 32-bit words packer output can be:
  // - 0 ATB words - residual_data_reg takes packed_data[27:0]
  // - 1 ATB word  - residual_data_reg takes packed_data[59:32]
  // - 2 ATB words - residual_data_reg takes packed_data[87:64]
  //
  // 64-bit: size of data in residual data register can be up to 60 bits i.e. 15 nibbles
  // In terms of 64-bit words packer output can be:
  // - 0 ATB words - residual_data_reg takes packed_data[59:0]
  // - 1 ATB word  - residual_data_reg takes packed_data[123:64]
  // - 2 ATB words - residual_data_reg takes packed_data[151:128]
  //
  generate
    if (STM_DATA_WIDTH == 64)
      assign nxt_residual_data[59:0] = ({60{(pack_size[5:4]==2'b00)}} & packed_data[59:0])  |
                                       ({60{(pack_size[5:4]==2'b01)}} & packed_data[123:64]) |
                                       ({60{(pack_size[5:4]==2'b10)}} & {36'h0, packed_data[151:128]});
  endgenerate

  // Data is written into residual_data_reg when:
  // - packing mico-operation is done without idle cycle for doubleword, or
  // - double word double word data is taken into atdata_reg and aux_data_reg and a idle cycle is introduced
  // This is to ensure that in case of stall whole of packed_data is taken into registers in single cycle
  assign residual_data_we = ((uop_done & ~dword_taken_reg) | dword_taken) & (packets_valid_i | atvalid_reg | atb_data_load);
  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      residual_data_reg[STM_DATA_WIDTH-5:0] <= {(STM_DATA_WIDTH-4){1'b0}};
    else if (residual_data_we)
      residual_data_reg[STM_DATA_WIDTH-5:0] <= nxt_residual_data[STM_DATA_WIDTH-5:0];
  end

  // Size of residual data is bottom bits of resulting size of packing operation
  // New size is captured when packing micro-operation is done
  assign nxt_residual_data_size[(STM_DATA_WIDTH/32)+1:0] = pack_size[(STM_DATA_WIDTH/32)+1:0];
  assign residual_data_size_we       = uop_done & (packets_valid_i | atvalid_reg | atb_data_load);
  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      residual_data_size_reg[(STM_DATA_WIDTH/32)+1:0] <= {((STM_DATA_WIDTH/32)+2){1'b0}};
    else if (residual_data_size_we)
      residual_data_size_reg[(STM_DATA_WIDTH/32)+1:0] <= nxt_residual_data_size[(STM_DATA_WIDTH/32)+1:0];
  end

  // Auxiliary data register is used to store data from packer in case:
  // - one 32-bit word is ready and ATB data register is full - packed_data[31:0] is stored
  // - two 32-bit words are ready - packed_data[63:32] is stored
  assign nxt_aux_data[STM_DATA_WIDTH-1:0] = aux_data_source ? packed_data[((2*STM_DATA_WIDTH)-1):STM_DATA_WIDTH] : packed_data[STM_DATA_WIDTH-1:0];
  always @(posedge clk_gated)
  begin
    if (aux_data_we)
      aux_data_reg[STM_DATA_WIDTH-1:0] <= nxt_aux_data[STM_DATA_WIDTH-1:0];
  end

  // Valid for auxiliary data register
  assign nxt_aux_valid = aux_valid_set;
  assign aux_valid_we  = aux_valid_set | aux_valid_clear;
  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      aux_valid_reg <= 1'b0;
    else if (aux_valid_we)
      aux_valid_reg <= nxt_aux_valid;
  end

  //---------------------------------------------------------------------------
  // Data packer control
  //---------------------------------------------------------------------------
  // Packer has valid data to pack when packets are valid from packet builder
  // and flush uop is not ongoing
  assign packets_valid = packets_valid_i & ~flush_uop;

  // Packer request from packet builder is encoded as 3-bit value,
  // each bit representing a packet to be processed
  // As packet are processed lower bits are masked
  // Single uop can process 1 or 2 packets depending on packet size and size of residual data
  // Add bit to mask to remove 1st non-zero bit from request
  // req  mask_r1
  // 000  ---
  // 001  ---
  // 010  010
  // 011  001
  // 100  100
  // 101  ---
  // 110  010
  // 111  001
  assign pack_done_mask_r1[2:0] = {~pack_request_masked[1],
                                   ~pack_request_masked[0] &  pack_request_masked[1],
                                    pack_request_masked[0]};
  // Add 2 bits to mask to remove 1st and 2nd non-zero bits from request
  // req  mask_r2
  // 000  ---
  // 001  ---
  // 010  ---
  // 011  011
  // 100  ---
  // 101  ---
  // 110  110
  // 111  011
  assign pack_done_mask_r2[2:0] = {~pack_request_masked[0] & pack_request_masked[2],
                                    pack_request_masked[1],
                                    pack_request_masked[0]};

  assign pack_done_mask_m[2:0]   = use_one_mux ? pack_done_mask_r1[2:0]: pack_done_mask_r2[2:0];
  assign next_mask[2:0]          = {1'b0, pack_done_mask_reg[1:0]} | pack_done_mask_m[2:0];
  // Mask is reset when packing is done
  assign nxt_pack_done_mask[1:0] = packer_done ? 2'b00 : next_mask[1:0];
  assign pack_done_mask_we       = packets_valid & uop_done;
  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      pack_done_mask_reg[1:0] <= 2'b00;
    else if (pack_done_mask_we)
      pack_done_mask_reg[1:0] <= nxt_pack_done_mask[1:0];
  end

  // Masked request is used to control packer uops
  assign pack_request_masked[2:0] = {packer_request_i[2], packer_request_i[1:0] ^ pack_done_mask_reg[1:0]};

  // Based on type of packing operation (pack_sequence_i) and data available for packing (masked requect)
  // mux controls are generated
  // to select correct packets
  // Mux1 control - mux1_ctrl[1:0]:
  //  00 - master/channel packet
  //  01 - unused
  //  10 - extended timestamp
  //  11 - 2nd async
  // Mux2 control - mux2_ctrl[1:0]:
  //  00 - data packet
  //  01 - 1st async
  //  10 - extended timestamp
  //  11 - 3rd async
  // Order of muxes - m12_sel
  //  1 - use mux1 as first mux
  //  0 - use mux2 as first mux

  // PLA table sent to espresso
  //  .i 6
  //  .o 7
  //  .ilb packets_valid pack_sequence_i[1] pack_sequence_i[0] pack_request_masked[2] pack_request_masked[1] pack_request_masked[0]
  //  .ob mux1_enable mux1_ctrl[1] mux1_ctrl[0] mux2_enable mux2_ctrl[1] mux2_ctrl[0] m12_sel
  //  #        mux1_enable_pack
  //  #        | mux1_ctrl
  //  #        | |  mux2_enable_pack
  //  #        | |  | mux2_ctrl
  //  #        | |  | |  m12_sel 1= use mux1 first
  //  #        | |  | |  |
  //  0 -- --- 0 -- 0 -- -
  //  #data fifo not used - Flush only
  //  1 00 --- 0 -- 0 -- -
  //  #packet processing
  //  1 -1 010 0 -- 1 00 0
  //  1 -1 011 1 00 1 00 1
  //  1 -1 111 1 00 1 00 1
  //  1 -1 110 1 10 1 00 0
  //  1 -1 100 0 -- 1 10 0
  //  # invalid cases - assertions present, uzovl_11
  //  1 -1 000 - -- - -- -
  //  1 -1 001 - -- - -- -
  //  1 -1 101 - -- - -- -
  //  #sync sequence
  //  1 10 111 1 11 1 01 0
  //  1 10 110 1 11 1 11 1
  //  1 10 100 0 -- 1 11 0
  //  # invalid case - assertion present, uzovl_12
  //  1 10 101 - -- - -- -
  //  1 10 0-- - -- - -- -
  //  .e
  // espresso output
  // DO NOT MODIFY BY HAND
  assign mux1_enable = (packets_valid&pack_sequence_i[1]&pack_request_masked[2]
    &pack_request_masked[1]) | (packets_valid&pack_sequence_i[0]
    &pack_request_masked[0]) | (packets_valid&pack_sequence_i[0]
    &pack_request_masked[2]&pack_request_masked[1]);

  assign mux1_ctrl[1] = (!pack_sequence_i[0]) | (!pack_request_masked[0]);

  assign mux1_ctrl[0] = (!pack_sequence_i[0]);

  assign mux2_enable = (packets_valid&pack_sequence_i[1]) | (packets_valid
    &pack_sequence_i[0]);

  assign mux2_ctrl[1] = (!pack_sequence_i[0]&!pack_request_masked[0]) | (
    !pack_request_masked[1]);

  assign mux2_ctrl[0] = (!pack_sequence_i[0]);

  assign m12_sel = (!pack_sequence_i[0]&pack_request_masked[1]
    &!pack_request_masked[0]) | (pack_sequence_i[0]
    &pack_request_masked[0]);

  // end of espresso output

  // Last uop is the uop in which all request bits are masked
  assign last_uop = (next_mask[2:0] == packer_request_i[2:0]) & packets_valid_i;

  // Size of a packet from 1st mux
  // - master/channel packet
  // - unused
  // - extended timestamp packet[35:0]
  // - 2nd part of async sequence
  assign mux1_size[3:0] = (({4{(mux1_ctrl[1:0] == 2'b00)}} & mc_packet_size_i[3:0])      |
                           ({4{(mux1_ctrl[1:0] == 2'b10)}} & extts_packet_size_i[3:0])   |
                           ({4{(mux1_ctrl[1:0] == 2'b11)}} & async2_packet_size_i[3:0]))
                           & {4{mux1_enable}};

  // Size of a packet from 2nd mux
  // - data packet
  // - 1st part of async sequence
  // - extended timestamp packet[47:0]
  // - 3rd part of async sequence
  generate
    if (STM_DATA_WIDTH == 64) begin : gen_pack_size_64
      assign mux2_size[4:0] = (({5{(mux2_ctrl[1:0] == 2'b00)}} & data_packet_size_i[4:0])    |
                               ({5{(mux2_ctrl[1:0] == 2'b01)}} & {1'b0, async1_packet_size_i[3:0]})  |
                               ({5{(mux2_ctrl[1:0] == 2'b10)}} & {1'b0, extts_packet_size_i[3:0]})   |
                               ({5{(mux2_ctrl[1:0] == 2'b11)}} & {1'b0, async3_packet_size_i[3:0]}))
                               & {5{mux2_enable}};

      // Size of packed data after 1st shifter
      // - residual size plus
      // - size from mux1 or from mux2
      // depending on which mux is used as the 1st
      assign pack1_size[5:0] = {1'b0, residual_data_size_reg[3:0]} + (m12_sel ? {1'b0, mux1_size[3:0]} : mux2_size[4:0]);

      // Size of packed data after 2nd shifter is:
      // - residual size plus
      // - size from mux1 plus
      // - size from mux2
      assign pack2_size[5:0] = {1'b0, residual_data_size_reg[3:0]} + {1'b0, mux1_size[3:0]} + mux2_size[4:0];

      // Based on size of packed data determine whether to use one or both muxes
      // Use one mux if:
      // - only one mux2 is enabled from control logic
      // - 1st shifter produces 2 64-bit words
      // - both muxes produce more than 128 bits
      assign use_one_mux = (~mux1_enable & mux2_enable) | pack1_size[5] | (pack2_size[5:0] > 6'b100000);

      // Size of packed data is:
      // - 64 bit in case of flush - which means data of up to 64 bits is ready
      // - size after 1st or second shifter
      assign pack_size[(STM_DATA_WIDTH/32)+3:0] = flush_uop ? 6'b010000 :
                                                  use_one_mux ? pack1_size[(STM_DATA_WIDTH/32)+3:0] : pack2_size[(STM_DATA_WIDTH/32)+3:0];

      // Shifter controls
      // Amount of shifting is equal to
      // - residual size in case of 1st shifter
      // - size of packed data after 1st shifter
      assign shift1_ctrl[4:0] = m12_sel ? {1'b0, residual_data_size_reg[3:0]} : pack1_size[4:0];
      assign shift2_ctrl[4:0] = m12_sel ? pack1_size[4:0] : {1'b0, residual_data_size_reg[3:0]};

    end






  endgenerate

  // Mask shifter output if not used
  assign shift1_enable = mux1_enable & ~(use_one_mux & ~m12_sel);
  assign shift2_enable = mux2_enable & ~(use_one_mux &  m12_sel);

  // Controls for ATB output register and skid buffer
  //  - uop_done - packing micro-operation is completed when data from packer is taken into registers
  // Auxiliary register data source:
  // - 0 - when one data word is ready and ATB data register is full, packed_data[STM_DATA_WIDTH-1:0] is stored
  // - 1 - when two data words are ready, packed_data[2*STM_DATA_WIDTH-1:STM_DATA_WIDTH] is stored
  // Auxiliary register data source:
  // - 0 - packed_data[STM_DATA_WIDTH-1:0]
  // - 1 - auxiliary register

  generate
    if (STM_DATA_WIDTH == 64) begin : gen_output_control_64

  // PLA table sent to espresso
  //  .i 10
  //  .o 9
  //  .ilb pack_size[5] pack_size[4] flush_uop packer_busy dword_taken_reg aux_valid_reg atvalid_reg ATREADYM trace_trigger_reg q_stopped_i
  //  .ob uop_done aux_data_we aux_valid_set aux_valid_clear aux_data_source atb_data_load atb_valid_clear atb_data_source dword_taken
  //# pack_size[5:4]
  //# |  flush_uop
  //# |  | packer_busy
  //# |  | | dword_taken_reg
  //# |  | | | aux_valid_reg
  //# |  | | | | atvalid_reg
  //# |  | | | | | ATREADYM
  //# |  | | | | | | trace_trigger_reg
  //# |  | | | | | | | q_stopped_i
  //# |  | | | | | | | |
  //# |  | | | | | | | |   uop_done
  //# |  | | | | | | | |   | aux_data_we
  //# |  | | | | | | | |   | | aux_valid_set
  //# |  | | | | | | | |   | | | aux_valid_clear
  //# |  | | | | | | | |   | | | | aux_data_source 1=packer[127:64] 0=packer[63:0]
  //# |  | | | | | | | |   | | | | | atb_data_load
  //# |  | | | | | | | |   | | | | | | atb_valid_clear
  //# |  | | | | | | | |   | | | | | | | atb_data_source 1=aux 0=packer[63:0]
  //# |  | | | | | | | |   | | | | | | | | dword_taken
  //# |  | | | | | | | |   | | | | | | | | |
  //# |  | | | | | | | |   | | | | | | | | |
  //  # ATB in Q_STOPPED
  //  -- - - - - - - - 1   - 0 0 1 - 0 1 - -
  //  # trace trigger                          # ATREADYM
  //  -- - - - - 0 - 1 0   0 0 0 0 - 1 0 - 0   # -
  //  -- - - - - 1 0 1 0   0 0 0 0 - 0 0 - 0   # 0
  //  -- - - - - 1 1 1 0   0 0 0 0 - 1 0 - 0   # 1
  //  # no words                               #
  //  00 - - - 0 0 0 0 0   1 0 0 0 - 0 0 - 0   # 0
  //  00 - - - 0 0 1 0 0   1 0 0 0 - 0 0 - 0   # 1
  //  00 - - - 0 1 0 0 0   1 0 0 0 - 0 0 - 0   # 0
  //  00 - - - 0 1 1 0 0   1 0 0 0 - 0 1 - 0   # 1
  //  00 - - - 1 1 0 0 0   1 0 0 0 - 0 0 - 0   # 0
  //  00 - - - 1 1 1 0 0   1 0 0 1 - 1 0 1 0   # 1
  //  # one word from packer                   #
  //  01 0 - - 0 0 0 0 0   1 0 0 0 - 1 0 0 0   # 0
  //  01 1 0 - 0 0 0 0 0   1 0 0 0 - 0 0 0 0   # 0
  //  01 1 1 - 0 0 0 0 0   1 0 0 0 - 1 0 0 0   # 0
  //  01 0 - - 0 0 1 0 0   1 0 0 0 - 1 0 0 0   # 1
  //  01 1 0 - 0 0 1 0 0   1 0 0 0 - 0 0 0 0   # 1
  //  01 1 1 - 0 0 1 0 0   1 0 0 0 - 1 0 0 0   # 1
  //  01 0 - - 0 1 0 0 0   1 1 1 0 0 0 0 - 0   # 0
  //  01 1 - - 0 1 0 0 0   0 0 0 0 - 0 0 - 0   # 0
  //  01 0 - - 0 1 1 0 0   1 1 0 0 - 1 0 0 0   # 1
  //  01 1 - - 0 1 1 0 0   0 0 0 0 - 0 1 - 0   # 1
  //  01 - - - 1 1 0 0 0   0 0 0 0 - 0 0 - 0   # 0
  //  01 - - - 1 1 1 0 0   0 0 0 1 - 1 0 1 0   # 1
  //  # two words from packer                  #
  //  #  two buffer spaces available, doubleword taken without stall
  //  10 - - 0 0 0 0 0 0   1 1 1 0 1 1 0 0 0   # 0
  //  10 - - 0 0 0 1 0 0   1 1 1 0 1 1 0 0 0   # 1
  //  #  one buffer space available            #
  //  10 - - 0 0 1 0 0 0   0 1 0 0 - 0 0 - 0   # 0
  //  #  one buffer space available, stall inserted after ATREADY
  //  10 - - 0 0 1 1 0 0   0 1 1 0 1 1 0 0 1   # 1
  //  #  no buffer space available             #
  //  10 - - 0 1 1 0 0 0   0 0 0 0 - 0 0 - 0   # 0
  //  10 - - 0 1 1 1 0 0   0 0 0 1 - 1 0 1 0   # 1
  //  #  doubleword taken                      #
  //  10 - - 1 1 1 0 0 0   1 0 0 0 - 0 0 - 0   # 0
  //  10 - - 1 1 1 1 0 0   1 0 0 1 - 1 0 1 0   # 1
  //  # invalid cases - assertions present     #
  //  # less than two words from packer and dword_taken_reg asserted - uzovl_10
  //  00 - - 1 - - - - 0   - - - - - - - - -   # -
  //  01 - - 1 - - - - 0   - - - - - - - - -   # -
  //  # doubleword taken and both buffers are not full - uzovl_3
  //  10 - - 1 0 1 0 0 0   - - - - - - - - -   # 0
  //  10 - - 1 0 1 1 0 0   - - - - - - - - -   # 1
  //  10 - - 1 0 0 0 0 0   - - - - - - - - -   # 0
  //  10 - - 1 0 0 1 0 0   - - - - - - - - -   # 1
  //  # (3 words) - uzovl_0
  //  11 - - - - - - 0 0   - - - - - - - - -   # -
  //  # aux buffer full, main buffer empty - uzovl_2
  //  -- - - - 1 0 - 0 0   - - - - - - - - -   # -
  //  .e
  // espresso output
  // DO NOT MODIFY BY HAND
  assign uop_done = (pack_size[4]&!flush_uop&!aux_valid_reg&!trace_trigger_reg) | (
    dword_taken_reg&!trace_trigger_reg) | (!atvalid_reg&!trace_trigger_reg) | (
    !pack_size[5]&!pack_size[4]&!trace_trigger_reg);

  assign aux_data_we = (pack_size[4]&!flush_uop&!aux_valid_reg&atvalid_reg
    &!trace_trigger_reg&!q_stopped_i) | (pack_size[5]&!aux_valid_reg
    &!trace_trigger_reg&!q_stopped_i);

  assign aux_valid_set = (pack_size[4]&!flush_uop&!aux_valid_reg&atvalid_reg
    &!ATREADYM&!trace_trigger_reg&!q_stopped_i) | (pack_size[5]
    &!atvalid_reg&!trace_trigger_reg&!q_stopped_i) | (pack_size[5]
    &!aux_valid_reg&ATREADYM&!trace_trigger_reg&!q_stopped_i);

  assign aux_valid_clear = (aux_valid_reg&ATREADYM&!trace_trigger_reg) | (
    q_stopped_i);

  assign aux_data_source = (!pack_size[4]);

  assign atb_data_load = (pack_size[4]&packer_busy&!atvalid_reg&!q_stopped_i) | (
    pack_size[5]&!atvalid_reg&!q_stopped_i) | (aux_valid_reg&ATREADYM
    &!q_stopped_i) | (pack_size[4]&!flush_uop&!atvalid_reg&!q_stopped_i) | (
    pack_size[5]&ATREADYM&!q_stopped_i) | (pack_size[4]&!flush_uop
    &ATREADYM&!q_stopped_i) | (ATREADYM&trace_trigger_reg&!q_stopped_i) | (
    !atvalid_reg&trace_trigger_reg&!q_stopped_i);

  assign atb_valid_clear = (pack_size[4]&flush_uop&!aux_valid_reg&atvalid_reg
    &ATREADYM&!trace_trigger_reg) | (!pack_size[5]&!pack_size[4]
    &!aux_valid_reg&atvalid_reg&ATREADYM&!trace_trigger_reg) | (
    q_stopped_i);

  assign atb_data_source = (aux_valid_reg);

  assign dword_taken = (pack_size[5]&!aux_valid_reg&atvalid_reg&ATREADYM
    &!trace_trigger_reg);

  // end of espresso output

    end











  endgenerate

  // In case 2 data words are ready from packer, insert one wait state
  // if not both buffers empty
  // This is to remove ATREADY dependency from uop_done
  assign dword_taken_we  = uop_done | dword_taken;
  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      dword_taken_reg <= 1'b0;
    else if (dword_taken_we)
      dword_taken_reg <= dword_taken;
  end

  // Packer is finished when last uop is stored into buffers
  // or when flush is done for "flush only" control word
  assign packer_done = (last_uop & uop_done & ~flush_uop) | (flush_done & (pack_sequence_i[1:0] == 2'b00));

  //---------------------------------------------------------------------------
  // Trace trigger insertion
  //---------------------------------------------------------------------------
  // Trace trigger event from TGU interface is registered
  // and trace trigger with ATID 0x7D is inserted at next opportunity,
  // i.e. when current ATB transaction is accepted or immediately if ATB i/f is idle and not in q_stopped
  assign nxt_trace_trigger = tgu_trace_trigger_i;
  assign trace_trigger_we  = tgu_trace_trigger_i | (trace_trigger_reg & (ATREADYM | ~atvalid_reg) & ~q_stopped_i);
  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      trace_trigger_reg <= 1'b0;
    else if (trace_trigger_we)
      trace_trigger_reg <= nxt_trace_trigger;
  end

  //---------------------------------------------------------------------------
  // Flush control
  //---------------------------------------------------------------------------
  // A flush uop flushes packer registers. flush_uop is performed in two cases:
  //  1) when there is a flush request from control fifo and there is some residual data in packer
  //  2) locally generated flush
  // During flush uop no data is taken from tgu packet builder and
  // data from residual data register is output

  assign flush_uop  = (packets_valid_i & flush_req_i & ~flushed_reg) |
                      local_flush;

  // Local flush - auto flush mode
  // When fifo is empty and auto-flush is enabled and there is residual data in packer
  // flush is initiated
  assign local_flush = packer_busy & tgu_fifo_empty_i &
                        (tgu_cfg_fifoaf_i | tgu_flush_i | ~tgu_cfg_enable_i | q_flush_i);

  // This register is used to mask further flush requests after flush is done in case flush request is present alongside new data
  // Flush is done first and packing shall resume with new data
  // So, set with flush_done, cleared with packer done
  assign nxt_flushed = (flush_done & (pack_sequence_i[1:0] != 2'b00) & ~local_flush);
  assign flushed_we  = (flush_done & (pack_sequence_i[1:0] != 2'b00) & ~local_flush) |  (uop_done & ~flush_uop & last_uop);
  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      flushed_reg <= 1'b0;
    else if (flushed_we)
      flushed_reg <= nxt_flushed;
  end

  generate
    if (STM_DATA_WIDTH == 64) begin : gen_flush_bytes_64
      // Convert size of residual data to ATB ATBYTES encoding
      // Used on flush uop, when less then 64-bits can be output
      always @(residual_data_size_reg)
      begin
        case(residual_data_size_reg[3:0])
          4'b0000 : flush_atbytes[2:0] = 3'b000;
          4'b0001 : flush_atbytes[2:0] = 3'b000;
          4'b0010 : flush_atbytes[2:0] = 3'b000;
          4'b0011 : flush_atbytes[2:0] = 3'b001;
          4'b0100 : flush_atbytes[2:0] = 3'b001;
          4'b0101 : flush_atbytes[2:0] = 3'b010;
          4'b0110 : flush_atbytes[2:0] = 3'b010;
          4'b0111 : flush_atbytes[2:0] = 3'b011;
          4'b1000 : flush_atbytes[2:0] = 3'b011;
          4'b1001 : flush_atbytes[2:0] = 3'b100;
          4'b1010 : flush_atbytes[2:0] = 3'b100;
          4'b1011 : flush_atbytes[2:0] = 3'b101;
          4'b1100 : flush_atbytes[2:0] = 3'b101;
          4'b1101 : flush_atbytes[2:0] = 3'b110;
          4'b1110 : flush_atbytes[2:0] = 3'b110;
          4'b1111 : flush_atbytes[2:0] = 3'b111;
          // unreachable, X propagation only
          // VCS coverage off
          default: flush_atbytes[2:0] = {3{1'bx}};
          // VCS coverage on
        endcase
      end
    end
  endgenerate

  // Flush is completed in packer when flush uop is done
  assign flush_done = flush_uop & uop_done;

  // FSM for ATB i/f flush handshake
  // FSM tracks progress of ATB flush
  // Once flush is done, there can be 2, 1 or 0 words still to output
  // before AFREADY is asserted

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      fl_state_reg <= FLUSH_IDLE;
    else if (AFVALIDM)
      fl_state_reg <= nxt_fl_state;
  end

  always @*
  begin
    case (fl_state_reg)
      FLUSH_IDLE: begin
        // assertion present for tgu_cfg_enable_i being X
        if (~tgu_cfg_enable_i | q_stopped_i)
          nxt_fl_state = FLUSH_IDLE;
        else
          case ({AFVALIDM, afready_reg})
            2'b00:   nxt_fl_state = FLUSH_IDLE;
            2'b01:   nxt_fl_state = FLUSH_IDLE;
            2'b10:   nxt_fl_state = FLUSH_ONGOING[1:0];
            2'b11:   nxt_fl_state = FLUSH_IDLE[1:0];
            // unreachable, X propagation only
            // VCS coverage off
            default: nxt_fl_state = 2'bxx;
            // VCS coverage on
          endcase
      end
      FLUSH_ONGOING: begin
        // assertion present for flush_done being X - uzovl_7
        // assertion present for local_flush being X - uzovl_9
        if (~flush_done | local_flush)
          nxt_fl_state = FLUSH_ONGOING;
        else
          nxt_fl_state = packer_busy ? FLUSH_ONE : FLUSH_IDLE;
      end
      FLUSH_ONE: begin
        nxt_fl_state = ATREADYM ? FLUSH_IDLE : FLUSH_ONE;
      end
      // state 2'b01 is illegal, assertion present - uzovl_8
      // VCS coverage off
      default: nxt_fl_state = 2'bxx;
      // VCS coverage on
    endcase
  end

  always @*
  begin
    case (fl_state_reg[1:0])
      FLUSH_IDLE[1:0]:    atb_flushed = 1'b0;
      FLUSH_ONGOING[1:0]: atb_flushed = (flush_done & ~local_flush & ~packer_busy);
      FLUSH_ONE[1:0]:     atb_flushed = ATREADYM;
      // state 2'b01 is illegal, assertion present - uzovl_8
      // VCS coverage off
      default:            atb_flushed = 1'bx;
      // VCS coverage on
    endcase
  end

  //---------------------------------------------------------------------------
  // ATB interface
  //---------------------------------------------------------------------------
  // ATVALID
  assign nxt_atvalid =  itctl_i ? pwdatadbg10_0_r_i[0] : atb_data_load;
  assign atvalid_we  =  itctl_i ? itatbctr0_we_i :
                                  (atb_data_load | atb_valid_clear);

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      atvalid_reg <= 1'b0;
    else if (atvalid_we)
      atvalid_reg <= nxt_atvalid;
  end

  // ATB registers are enabled when new atb data is loaded or in integration mode
  assign atb_we = itctl_i | atb_data_load;

  // ATID
  // in integration mode atid is loaded from APB
  assign nxt_atid_int[6:0] = itatbid_we_i      ? pwdatadbg10_0_r_i[6:0]     : atid_reg[6:0];
  // trace trigger insertion
  assign nxt_atid_tt [6:0] = trace_trigger_reg ? ATB_TRACE_TRIGGER_ID[6:0] : tgu_cfg_traceid_i[6:0];
  // select next atid in integration or functional mode
  assign nxt_atid    [6:0] = itctl_i           ? nxt_atid_int[6:0]         : nxt_atid_tt[6:0];

  always @(posedge clk_gated)
  begin
    if (atb_we)
      atid_reg[6:0] <= nxt_atid[6:0];
  end

  // ATDATA
  // in integration mode atdata is loaded from APB
  assign int_data[31:0]       =  {pwdatadbg10_0_r_i[4],    // 31
                                  {7{1'b0}},
                                  pwdatadbg10_0_r_i[3],    // 23
                                  {7{1'b0}},
                                  pwdatadbg10_0_r_i[2],    // 15
                                  {7{1'b0}},
                                  pwdatadbg10_0_r_i[1],    // 7
                                  {6{1'b0}},
                                  pwdatadbg10_0_r_i[0]};   // 0

  generate
    if (STM_DATA_WIDTH == 64)
      assign int_data[63:32]   = {pwdatadbg10_0_r_i[8],    // 63
                                  {7{1'b0}},
                                  pwdatadbg10_0_r_i[7],    // 55
                                  {7{1'b0}},
                                  pwdatadbg10_0_r_i[6],    // 47
                                  {7{1'b0}},
                                  pwdatadbg10_0_r_i[5],    // 39
                                  {7{1'b0}}};
  endgenerate


  assign nxt_atdata_int[STM_DATA_WIDTH-1:0] = itatbdata0_we_i   ? int_data[STM_DATA_WIDTH-1:0]                         : atdata_reg[STM_DATA_WIDTH-1:0];
  // new data is taken either from auxiliary register or from packer
  assign nxt_atdata_f  [STM_DATA_WIDTH-1:0] = atb_data_source   ? aux_data_reg[STM_DATA_WIDTH-1:0]                     : packed_data[STM_DATA_WIDTH-1:0];
  // trace trigger insertion
  assign nxt_atdata_tt [STM_DATA_WIDTH-1:0] = trace_trigger_reg ? {{(STM_DATA_WIDTH-7){1'b0}}, tgu_cfg_traceid_i[6:0]} : nxt_atdata_f[STM_DATA_WIDTH-1:0];
  // select next atdata in integration or functional mode
  assign nxt_atdata    [STM_DATA_WIDTH-1:0] = itctl_i           ? nxt_atdata_int[STM_DATA_WIDTH-1:0]                   : nxt_atdata_tt[STM_DATA_WIDTH-1:0];

  always @(posedge clk_gated)
  begin
    if (atb_we)
      atdata_reg[STM_DATA_WIDTH-1:0] <= nxt_atdata[STM_DATA_WIDTH-1:0];
  end

  // ATBYTES
  // in integration mode atbytes is loaded from APB
  assign nxt_atbytes_int[(STM_DATA_WIDTH/32):0] = itatbctr0_we_i                 ? pwdatadbg10_0_r_i[(STM_DATA_WIDTH/32)+8:8] : atbytes_reg[(STM_DATA_WIDTH/32):0];
  // for flush operation atbytes is calculated based on size of residual data, otherwise
  // full word is always output
  assign nxt_atbytes_f  [(STM_DATA_WIDTH/32):0] = (flush_uop & ~atb_data_source) ? flush_atbytes[(STM_DATA_WIDTH/32):0]       : {((STM_DATA_WIDTH/32)+1){1'b1}};
  // trace trigger insertion
  assign nxt_atbytes_tt [(STM_DATA_WIDTH/32):0] = trace_trigger_reg              ? {((STM_DATA_WIDTH/32)+1){1'b0}}            : nxt_atbytes_f[(STM_DATA_WIDTH/32):0];
  // select next atbytes in integration or functional mode
  assign nxt_atbytes    [(STM_DATA_WIDTH/32):0] = itctl_i                        ? nxt_atbytes_int[(STM_DATA_WIDTH/32):0]     : nxt_atbytes_tt[(STM_DATA_WIDTH/32):0];

  always @(posedge clk_gated)
  begin
    if (atb_we)
      atbytes_reg[(STM_DATA_WIDTH/32):0] <= nxt_atbytes[(STM_DATA_WIDTH/32):0];
  end

  // AFREADY
  // AFREADY is high if:
  // 1. tgu_cfg_freadyhigh is set
  // 2. STM is disabled and idle
  // 3. ATB is flushed
  // 4. Q-Channel is STOPPING/STOPPED and STM is idle
  assign nxt_afready =  itctl_i ? pwdatadbg10_0_r_i[1]
                                :(tgu_cfg_freadyhigh_i | (~tgu_cfg_enable_i & ~tgu_busy_i) | atb_flushed | q_stopped_i);

  assign afready_we  =  ~itctl_i | itatbctr0_we_i;
  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      afready_reg <= 1'b1;
    else if (afready_we)
      afready_reg <= nxt_afready;
  end

  // ATB is busy when there is:
  // - valid data still in buffers, or
  // - residual data
  // - flush request ongoing
  // - trigger received but not yet output
  assign packer_busy  = |(residual_data_size_reg[(STM_DATA_WIDTH/32)+1:0]);
  assign trigger_busy = tgu_trace_trigger_i | trace_trigger_reg;
  assign atb_busy     = atvalid_reg | packer_busy | (fl_state_reg[1:0] != FLUSH_IDLE[1:0]) | trigger_busy;

  //----------------------------------------------------------------------------
  // Output assignment
  //----------------------------------------------------------------------------
  // ATB i/f
  assign atvalid_o                       = atvalid_reg;
  assign ATDATAM[STM_DATA_WIDTH-1:0]     = atdata_reg[STM_DATA_WIDTH-1:0];
  assign ATBYTESM[(STM_DATA_WIDTH/32):0] = atbytes_reg[(STM_DATA_WIDTH/32):0];
  assign ATIDM[6:0]                      = atid_reg[6:0];
  assign afreadym_o                      = afready_reg;

  // Status interface
  assign atb_busy_o  = atb_busy;

  // Packet generation interface
  assign packer_done_o = packer_done;


`ifdef ARM_ASSERT_ON
  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------

  generate
    if (STM_DATA_WIDTH == 64) begin : gen_ovl_64_packer

    assert_never #(`OVL_FATAL,`OVL_ASSERT,"packer output cannot be 3x64-bit")
    ovl_never_atbmast_invalid_packer_output_64 (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (pack_size[5:4]==2'b11)
    );


    end


  endgenerate

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Mux1 ctrl value 2'b01 is illegal")
    ovl_never_atbmast_illegal_mux1_value (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr ((mux1_ctrl[1:0]==2'b01) & mux1_enable)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"ATVALID should not be low with auxiliary buffer full")
    ovl_never_atbmast_atvalid_low_when_aux_full (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (aux_valid_reg & ~atvalid_reg)
    );

  generate
    if(STM_DATA_WIDTH == 64) begin : gen_ovl_64_buffer

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"When doubleword is taken from packer both buffers must be full")
    ovl_never_atbmast_buffers_full_on_doubleword_64 (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr ((pack_size[5:4]==2'b10) & dword_taken_reg & ~(aux_valid_reg & atvalid_reg))
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"doubleword is taken only when 2 words are ready from packer")
    ovl_never_atbmast_doubleword_taken_only_when_available_64 (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (~(pack_size[5:4]==2'b10) & dword_taken)
    );

    end



  endgenerate

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Flush uop cannot be done if ATB i/f is stalled with 2 words pending")
    ovl_never_atbmast_flushuop_while_atb_stalled (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (flush_done & (pack_sequence_i[1:0] == 2'b00) & packer_busy & aux_valid_reg & atvalid_reg & ~ATREADYM)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Flush cannot be done if ATB i/f is stalled with 2 words pending")
    ovl_never_atbmast_flush_while_atb_stalled (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (flush_done & ~flush_uop &  aux_valid_reg &  atvalid_reg & ~ATREADYM & packer_busy)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Illegal FL FSM state")
    ovl_never_atbmast_illegal_fsm_state (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (fl_state_reg[1:0] == 2'b01)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"illegal packing request for packets other then sync")
    ovl_never_atbmast_illegal_packing_request (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (packets_valid_i & ((pack_request_masked[2:0]==3'b000) | (pack_request_masked[2:0]==3'b001) | (pack_request_masked[2:0]==3'b101)) & pack_sequence_i[0])
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"illegal packing request for sync sequence")
    ovl_never_atbmast_illegal_packing_request_sync (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (packets_valid_i & ((pack_request_masked[2]==1'b0) | (pack_request_masked[2:0]==3'b101)) & (pack_sequence_i[1:0]==2'b10))
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Packing request received during q_stopped")
    ovl_never_atbmast_packing_during_q_stopped (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (q_stopped_i & packets_valid_i)
    );

  // X propagation
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "tgu_cfg_enable_i is X")
    ovl_never_unknown_atbmast_tgu_cfg_enable_i (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (tgu_cfg_enable_i)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "flush_done is X")
    ovl_never_unknown_atbmast_flush_done (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (flush_done)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "local_flush is X")
    ovl_never_unknown_atbmast_local_flush (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (local_flush)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "residual_data_we is X")
    ovl_never_unknown_atbmast_residual_data_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (residual_data_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "residual_data_size_we is X")
    ovl_never_unknown_atbmast_residual_data_size_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (residual_data_size_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "aux_data_we is X")
    ovl_never_unknown_atbmast_aux_data_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (aux_data_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "aux_valid_we is X")
    ovl_never_unknown_atbmast_aux_valid_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (aux_valid_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pack_done_mask_we is X")
    ovl_never_unknown_atbmast_pack_done_mask_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (pack_done_mask_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "dword_taken_we is X")
    ovl_never_unknown_atbmast_dword_taken_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (dword_taken_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "trace_trigger_we is X")
    ovl_never_unknown_atbmast_trace_trigger_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (trace_trigger_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "flushed_we is X")
    ovl_never_unknown_atbmast_flushed_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (flushed_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "AFVALIDM is X")
    ovl_never_unknown_atbmast_afvalidm (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (AFVALIDM)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "atvalid_we is X")
    ovl_never_unknown_atbmast_atvalid_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (atvalid_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "atb_we is X")
    ovl_never_unknown_atbmast_atb_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (atb_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "afready_we is X")
    ovl_never_unknown_atbmast_afready_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (afready_we)
    );

  assert_never_unknown #(`OVL_FATAL, ((STM_DATA_WIDTH/32)+1), `OVL_ASSERT, "flush_atbytes is X")
    ovl_never_unknown_atbmast_flush_atbytes (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (flush_atbytes)
    );

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "fl_state_reg is X")
    ovl_never_unknown_atbmast_fl_state_reg (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (fl_state_reg)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "atb_flushed is X")
    ovl_never_unknown_atbmast_atb_flushed (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (atb_flushed)
    );

`endif
endmodule  // cxstm500_tgu_atbmast

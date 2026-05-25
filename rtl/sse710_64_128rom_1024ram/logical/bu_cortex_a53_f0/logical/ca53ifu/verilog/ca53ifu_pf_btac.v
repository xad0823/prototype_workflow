//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2012-06-13 14:45:48 +0100 (Wed, 13 Jun 2012) $
//
//      Revision            : $Revision: 211777 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Two-stage Cascaded Branch Target Address Cache
//-----------------------------------------------------------------------------

module ca53ifu_pf_btac (
  // Inputs
  input wire         clk,
  input wire         reset_n,
  input wire         btac_disable_i,
  input wire         DFTSE,
  input wire         DFTRAMHOLD,
  input wire [ 1:0]  instr_valid_if3_i,
  input wire         early_instr1_possible_i,
  input wire [79:0]  abuf_if3_i,
  input wire [ 1:0]  spec_btac_if3_i,
  input wire [ 1:0]  brn_btac_if3_i,
  input wire         dpu_btac_ret_i,
  input wire [ 1:0]  pfb_push_i,
  input wire         dpu_pf_force_i,
  input wire         dpu_fe_valid_ret_i,
  input wire         dpu_fe_valid_wr_i,
  input wire         dpu_iq_full_i,
  input wire [48:1]  va_if1_i,
  input wire [17:3]  abuf_va_if3_i,
  input wire [17:3]  bbuf_va_if3_i,
  input wire         instr_is_thumb_if3_i,
  input wire [ 2:1]  ip_if3_i,
  input wire         cpsr_state_i,
  input wire [49:0]  btac_stg0_ram_rdata_i,
  input wire [58:0]  btac_stg1_ram_rdata_i,
  input wire         ctl_mbist_req_i,
  input wire [ 1:0]  ctl_mbist_btac_en_mb4_i,
  input wire [ 6:0]  ctl_mbist_btac_addr_mb4_i,
  input wire         ctl_mbist_btac_wr_mb4_i,
  input wire [58:0]  ctl_mbist_btac_wdata_mb4_i,
  // Outputs
  output wire        btac_stg0_ram_en_o,
  output wire        btac_stg0_ram_wr_o,
  output wire [49:0] btac_stg0_ram_wdata_o,
  output wire [ 6:0] btac_stg0_ram_addr_o,
  output wire        btac_stg1_ram_en_o,
  output wire        btac_stg1_ram_wr_o,
  output wire [58:0] btac_stg1_ram_wdata_o,
  output wire [ 6:0] btac_stg1_ram_addr_o,
  output wire        brn_btac_pushed_if3_o,
  output wire        btac_invalidate_o,
  output wire        btac_lookup_stall_if4_o,
  output wire        btac_skew_loopkup_if4_o,
  output wire        btac_hit_if4_o,
  output wire [48:0] btac_hit_addr_if4_o);

  // -----------------------------
  // Variables
  // -----------------------------

  genvar i;

  // -----------------------------
  // Parameters
  // -----------------------------

  localparam integer BTAC_STG0_HIST_W = 7;
  localparam integer BTAC_STG1_HIST_W = 12;

  localparam integer BTAC_QUEUE_WIDTH      = 73;
  localparam integer BTAC_Q_HU_WAY_BIT     = 53;
  localparam integer BTAC_Q_HU_STAGE_BIT   = 58;
  localparam integer BTAC_Q_CONFIDENCE_BIT = 49;

  localparam integer BTAC_WRITE_STATE_W       = 2;
  localparam         BTAC_WRITE_STATE_IDLE    = 2'b00;
  localparam         BTAC_WRITE_STATE_WRITE   = 2'b01;
  localparam         BTAC_WRITE_STATE_INVRAM  = 2'b10;
  localparam         BTAC_WRITE_STATE_UNREACH = 2'b11;

  localparam [5:0]   SB_LDR_BTAC    = 6'b010101;
  localparam [5:0]   SB_LDR_PC_BTAC = 6'b011000;
  localparam [5:0]   SB_BLX_BTAC    = 6'b100101;
  localparam [5:0]   SB_TB_BTAC     = 6'b101101;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg [6:0]                          btac_address;
  reg                                btac_coarse_clock_en;
  reg                                btac_fine_clock_en;
  reg                                btac_initialise;
  reg                                btac_lookup_if4;
  reg                                btac_lookup_stall_if4;
  reg [(BTAC_QUEUE_WIDTH-1):0]       btac_queue_entry [2:0];
  reg                                btac_skew_loopkup_if4;
  reg [(BTAC_STG0_HIST_W-1):0]       cm_stg0_gh;
  reg [(BTAC_STG1_HIST_W-1):0]       cm_stg1_gh;
  reg                                last_cycle_force_ret;
  reg                                last_cycle_force_wr;
  reg                                nxt_read_ptr;
  reg [2:0]                          nxt_valid;
  reg                                nxt_write_ptr;
  reg [(BTAC_WRITE_STATE_W-1):0]     nxt_write_state;
  reg                                read_ptr;
  reg [(BTAC_STG0_HIST_W-1):0]       sp_stg0_gh;
  reg [(BTAC_STG1_HIST_W-1):0]       sp_stg1_gh;
  reg                                stg0_ram_wdata_force;
  reg                                stg0_ram_wr;
  reg                                stg1_ram_wdata_force;
  reg                                stg1_ram_wr;
  reg [17:3]                         va_if4;
  reg [2:0]                          valid;
  reg                                write_ptr;
  reg [(BTAC_WRITE_STATE_W-1):0]     write_state;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                               brn_btac_pushed_if3;
  wire                               btac_address_en;
  wire                               btac_confidence_if4;
  wire [48:0]                        btac_data_if4;
  wire                               btac_pos_in_abuf_if3;
  wire                               btac_instr_in_if3;
  wire                               btac_invalidate;
  wire                               btac_main_queue_push;
  wire [2:0]                         btac_queue_entry_en;
  wire                               btac_queue_push;
  wire [6:0]                         btac_stg0_addr_if4;
  wire                               btac_stg0_confid;
  wire [48:0]                        btac_stg0_data;
  wire [6:0]                         btac_stg1_addr_if4;
  wire                               btac_stg1_confid;
  wire [48:0]                        btac_stg1_data;
  wire                               btac_stg1_tag_hit;
  wire                               btac_write;
  wire                               clk_btac_coarse;
  wire                               clk_btac_fine;
  wire                               en_cm_gh;
  wire                               en_sp_gh;
  wire                               en_update;
  wire                               en_va_if4;
  wire [6:0]                         stg0_ram_raddr;
  wire [6:0]                         stg1_ram_raddr;
  wire [(BTAC_QUEUE_WIDTH-1):0]      new_btac_queue_entry;
  wire [6:0]                         nxt_btac_address;
  wire                               nxt_btac_coarse_clock_en;
  wire                               nxt_btac_fine_clock_en;
  wire                               nxt_btac_lookup_stall_if4;
  wire [(BTAC_QUEUE_WIDTH-1):0]      nxt_btac_queue_head_entry;
  wire                               nxt_btac_skew_loopkup_if4;
  wire [(BTAC_STG0_HIST_W-1):0]      nxt_cm_stg0_gh;
  wire [(BTAC_STG1_HIST_W-1):0]      nxt_cm_stg1_gh;
  wire                               nxt_btac_lookup_if4;
  wire [(BTAC_STG0_HIST_W-1):0]      nxt_sp_stg0_gh;
  wire [(BTAC_STG1_HIST_W-1):0]      nxt_sp_stg1_gh;
  wire [17:3]                        nxt_va_if4;
  wire                               prediction_confid;
  wire                               prediction_stage;
  wire [6:0]                         prediction_stg0_addr;
  wire [6:0]                         prediction_stg1_addr;
  wire [7:0]                         prediction_tag;
  wire [48:0]                        prediction_data;
  wire [6:0]                         sp_stg0_history;
  wire [6:0]                         sp_stg1_history;
  wire                               basic_btac_clock_en;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //
  // The Cortex-A53 BTAC is implemented as a 2-Stage cascaded structure using 2bc (confidence) for
  // each table within the structure.  Stage-0 is a tagless 128-Entry table which uses
  // a hash of path-length 1 to index in to the table.  Stage-1 is also a 128-Entry table
  // which uses a path-length of 3 to index in to the table.
  //
  // RAMs are read at the end of IF3, providing data in IF4.  This requires the IFU to stall for
  // 1-cycle after a BTAC-lookup.  RAMs are written at the end of IF1 along with committed history.
  //
  // If the BTAC is disabled the history registers and queue pointers are forced to zero and a
  // lookup will not occur.  The IFU will not stall since the conditions for a disabled BTAC also
  // mean that all branches are marked not-taken.

  // ------------------------------------------------------
  // Regional clock gate
  // ------------------------------------------------------

  // Create two regional clock enables.
  // - The coarse enable is used for all registers that may need to be updated at any time when there are outstanding indirect
  // instructions in flight.  For example, a force may occur at any point and this will need to effect registers such as
  // speculative history.
  // - The fine enable is used for all registers that only need to be clocked on the cycle of a read or the cycles around
  // writes.
  assign basic_btac_clock_en      = btac_disable_i | btac_initialise | (write_state != BTAC_WRITE_STATE_IDLE) | nxt_btac_lookup_if4 | dpu_btac_ret_i;
  assign nxt_btac_coarse_clock_en = basic_btac_clock_en | btac_lookup_if4 | valid[0];
  assign nxt_btac_fine_clock_en   = basic_btac_clock_en;

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      btac_coarse_clock_en <= 1'b1;
      btac_fine_clock_en   <= 1'b1;
    end
    else begin
      btac_coarse_clock_en <= nxt_btac_coarse_clock_en;
      btac_fine_clock_en   <= nxt_btac_fine_clock_en;
    end

  ca53_cell_inter_clkgate u_inter_clkgate_coarse_btac (.clk_i         (clk),
                                                       .clk_enable_i  (btac_coarse_clock_en),
                                                       .clk_senable_i (DFTSE),
                                                       .clk_gated_o   (clk_btac_coarse));

  ca53_cell_inter_clkgate u_inter_clkgate_fine_btac (.clk_i         (clk),
                                                     .clk_enable_i  (btac_fine_clock_en),
                                                     .clk_senable_i (DFTSE),
                                                     .clk_gated_o   (clk_btac_fine));

  // ------------------------------------------------------
  // IF3 Read path
  // ------------------------------------------------------
  //
  // Like the main branch prediction, address prediction for the BTAC is undertaken
  // on a 64-bit or per-buffer basis.

  // To choose between the A-Buffer and B-Buffer address we only need to know if the BTAC-able
  // instruction can only be in the A-Buffer.  This is the case if the instruction pointer is in
  // the lower part of the FQ or if it is in the upper part and there is a BTAC'able instruction
  // in instr-0.
  //
  // We don't need to be precise, just make sure we aren't missing a BTAC in the A-Buffer.
  //
  // This aproach allows us to index off the 'abuf' FQ entry directly rather than wait for the
  // instruction to be picked out and traverse through the decoders.
  assign btac_pos_in_abuf_if3 = (// Instruction pointer is in the lower part of the buffer
                                 ~ip_if3_i[2] |
                                 // Instruction pointer is in the middle of the A-Buffer and T16
                                 (ip_if3_i[2:1] == 2'b10 & instr_is_thumb_if3_i & ~abuf_if3_i[59]) |
                                 // Instruction pointer is in the middle of the A-Buffer and is instr-0 is BTAC-able
                                 (ip_if3_i[2:1] == 2'b10 & ~(instr_is_thumb_if3_i & ~abuf_if3_i[59]) & ((abuf_if3_i[58:53] == SB_LDR_BTAC)    |
                                                                                                        (abuf_if3_i[58:53] == SB_LDR_PC_BTAC) |
                                                                                                        (abuf_if3_i[58:53] == SB_BLX_BTAC)    |
                                                                                                        (abuf_if3_i[58:53] == SB_TB_BTAC))) |
                                 // Instruction pointer is at the top of the A-Buffer and instr-0 is T16 BTAC-able
                                 (ip_if3_i[2:1] == 2'b11 & instr_is_thumb_if3_i & ~abuf_if3_i[79] & abuf_if3_i[78:76] == 3'b011) |
                                 // Instruction pointer is at the top of the A-Buffer and instr-0 is Non-T16 BTAC-able
                                 (ip_if3_i[2:1] == 2'b11 & ~(instr_is_thumb_if3_i & ~abuf_if3_i[79]) & ((abuf_if3_i[78:73] == SB_LDR_BTAC)    |
                                                                                                        (abuf_if3_i[78:73] == SB_LDR_PC_BTAC) |
                                                                                                        (abuf_if3_i[78:73] == SB_BLX_BTAC)    |
                                                                                                        (abuf_if3_i[78:73] == SB_TB_BTAC))));

  // Address generation.  If the read has been held off due a write then use the address that's
  // been registered in to IF4.
  assign stg0_ram_raddr = (btac_skew_loopkup_if4 ? (       va_if4[9:3] ^ sp_stg0_history[6:0]) :
                           btac_pos_in_abuf_if3  ? (abuf_va_if3_i[9:3] ^ sp_stg0_history[6:0]) : (bbuf_va_if3_i[9:3] ^ sp_stg0_history[6:0]));

  assign stg1_ram_raddr = (btac_skew_loopkup_if4 ? (       va_if4[9:3] ^ sp_stg1_history[6:0]) :
                           btac_pos_in_abuf_if3  ? (abuf_va_if3_i[9:3] ^ sp_stg1_history[6:0]) : (bbuf_va_if3_i[9:3] ^ sp_stg1_history[6:0]));

  // Identify that there is a BTAC'able instruction in IF3
  assign btac_instr_in_if3 = ((spec_btac_if3_i[1] & instr_valid_if3_i[1] & ~btac_write & ~dpu_iq_full_i & early_instr1_possible_i) |
                              (spec_btac_if3_i[0] & instr_valid_if3_i[0] & ~btac_write & ~dpu_iq_full_i));

  // Identify that a a BTAC'able instruction has been taken and pushed to the DPU
  assign brn_btac_pushed_if3 = (~btac_disable_i &
                                ~btac_invalidate &
                                ~ctl_mbist_req_i &  // the fetch buffers are still going for few cycles after mbist is set, but we do not want to interfere with the RAM
                                ((brn_btac_if3_i[0] & pfb_push_i[0]) |  // Indirect branch in instr-0 pushed to DPU
                                 (brn_btac_if3_i[1] & pfb_push_i[1]))); // Indirect branch in instr-1 pushed to DPU

  // ------------------------------------------------------
  // IF4 Control
  // ------------------------------------------------------

  // Pipeline the address to IF4 for the tag compare and for tracking the target address to update
  // at the end of the pipeline
  assign nxt_va_if4 = btac_pos_in_abuf_if3 ? abuf_va_if3_i[17:3] : bbuf_va_if3_i[17:3];

  assign en_va_if4 = (brn_btac_if3_i[1] & early_instr1_possible_i) | brn_btac_if3_i[0];

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      va_if4 <= {15{1'b0}};
    else if (en_va_if4)
      va_if4 <= nxt_va_if4;

  // Create a one shot indicator that a lookup is required and possible
  assign nxt_btac_lookup_if4 = (~dpu_pf_force_i &
                                (write_state == BTAC_WRITE_STATE_IDLE) &        // Writes & invalidates have priority over reads
                                (brn_btac_pushed_if3 | btac_skew_loopkup_if4)); // Reads take place after a taken branch has been pushed or after skewed by a write

  // Create an indicator that the read had been skewed out due to a write
  assign nxt_btac_skew_loopkup_if4 = (~dpu_pf_force_i &
                                      btac_write &
                                      (brn_btac_pushed_if3 | btac_skew_loopkup_if4));

  // Create a lookup suppression signal for IF1 while a read is in-flight or stalled due to a write
  assign nxt_btac_lookup_stall_if4 = (~dpu_pf_force_i &
                                      (brn_btac_pushed_if3 | btac_skew_loopkup_if4));

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      btac_lookup_if4       <= 1'b0;
      btac_skew_loopkup_if4 <= 1'b0;
      btac_lookup_stall_if4 <= 1'b0;
    end
    else begin
      btac_lookup_if4       <= nxt_btac_lookup_if4;
      btac_skew_loopkup_if4 <= nxt_btac_skew_loopkup_if4;
      btac_lookup_stall_if4 <= nxt_btac_lookup_stall_if4;
    end

  // ------------------------------------------------------
  // IF4 Hit path
  // ------------------------------------------------------

  // Stage-0 of the BTAC is a 128-Entry tagless table with the following format
  //
  // Confidence         [49  ]
  // Address Sign       [48  ]
  // Address Offset     [47:1]
  // Target ISA         [ 0  ]
  assign btac_stg0_data   = btac_stg0_ram_rdata_i[48:0];
  assign btac_stg0_confid = btac_stg0_ram_rdata_i[49];

  // Stage-1 of the BTAC is 128-Entry table with the following format
  //
  // Valid              [58   ]
  // Tag                [57:50]
  // Confidence         [49   ]
  // Address Sign       [48   ]
  // Address Offset     [47: 1]
  // Target ISA         [ 0   ]
  assign btac_stg1_tag_hit = btac_lookup_if4 & btac_stg1_ram_rdata_i[58] & (btac_stg1_ram_rdata_i[57:50] == va_if4[17:10]);
  assign btac_stg1_data    = btac_stg1_ram_rdata_i[48:0];
  assign btac_stg1_confid  = btac_stg1_ram_rdata_i[49];

  // Resolve values for queue
  assign btac_stg1_addr_if4  = va_if4[9:3] ^ sp_stg1_history[6:0];
  assign btac_stg0_addr_if4  = va_if4[9:3] ^ sp_stg0_history[6:0];
  assign btac_confidence_if4 = btac_stg1_tag_hit ? btac_stg1_confid     : btac_stg0_confid;
  assign btac_data_if4       = btac_stg1_tag_hit ? btac_stg1_data[48:0] : btac_stg0_data[48:0];

  // ------------------------------------------------------
  // History
  // ------------------------------------------------------

  // Enables for both Stage-0 and Stage-1
  assign en_cm_gh = btac_disable_i | btac_write;
  assign en_sp_gh = btac_disable_i | btac_queue_push | last_cycle_force_wr | last_cycle_force_ret;

  // Stage-0 (path length of 1)
  assign nxt_cm_stg0_gh = ((btac_disable_i | btac_invalidate ) ? {BTAC_STG0_HIST_W{1'b0}} :
                           (btac_write & last_cycle_force_ret) ? va_if1_i[7:1]            :
                           (btac_write                       ) ? prediction_data[7:1]     : cm_stg0_gh);

  assign nxt_sp_stg0_gh = ((btac_disable_i | btac_invalidate) ? {BTAC_STG0_HIST_W{1'b0}} :
                           btac_queue_push                    ? btac_data_if4[7:1]       : nxt_cm_stg0_gh[6:0]);

  // Stage-1 (path length of 3 using an enter-left, shift-right register resulting in older paths on the right)
  assign nxt_cm_stg1_gh = ((btac_disable_i | btac_invalidate ) ? {BTAC_STG1_HIST_W{1'b0}}                 :
                           (btac_write & last_cycle_force_ret) ? {va_if1_i[7:4], cm_stg1_gh[11:4]}        :
                           (btac_write                       ) ? {prediction_data[7:4], cm_stg1_gh[11:4]} : cm_stg1_gh);

  assign nxt_sp_stg1_gh = ((btac_disable_i | btac_invalidate) ? {BTAC_STG1_HIST_W{1'b0}}               :
                           btac_queue_push                    ? {btac_data_if4[7:4], sp_stg1_gh[11:4]} : nxt_cm_stg1_gh[11:0]);

  always @(posedge clk_btac_fine or negedge reset_n)
    if (!reset_n) begin
      cm_stg0_gh <= {BTAC_STG0_HIST_W{1'b0}};
      cm_stg1_gh <= {BTAC_STG1_HIST_W{1'b0}};
    end
    else if (en_cm_gh) begin
      cm_stg0_gh <= nxt_cm_stg0_gh;
      cm_stg1_gh <= nxt_cm_stg1_gh;
    end

  always @(posedge clk_btac_coarse or negedge reset_n)
    if (!reset_n) begin
      sp_stg0_gh <= {BTAC_STG0_HIST_W{1'b0}};
      sp_stg1_gh <= {BTAC_STG1_HIST_W{1'b0}};
    end
    else if (en_sp_gh) begin
      sp_stg0_gh <= nxt_sp_stg0_gh;
      sp_stg1_gh <= nxt_sp_stg1_gh;
    end

  // Speculative history for hashing
  //
  // Stage-0 uses the history as stored in the history registers as only a path of 1 is used
  //
  // Stage-1 uses reverse interleaving with target bits from the older path bits used more often
  // to prevent aliasing.  This is shown below where 'P' is the Path and a higher number denotes
  // an older path and the number is brackets it the target offset address bit for that path. To
  // further avoid collisions, the youngest history (P0) and next youngest history (P1) is hashed.
  //     Speculative Stage-1 History :  P2[7], (P1[7] ^ P0[6]), P2[6], (P1[6] ^ P0[7]), P2[5], (P1[4] ^ P0[8]), P2[4]
  assign sp_stg0_history =  sp_stg0_gh;
  assign sp_stg1_history = {sp_stg1_gh[3], (sp_stg1_gh[6] ^ sp_stg1_gh[9]), sp_stg1_gh[2], (sp_stg1_gh[5] ^ sp_stg1_gh[10]), sp_stg1_gh[1], (sp_stg1_gh[4] ^ sp_stg1_gh[11]), sp_stg1_gh[0]};

  // ------------------------------------------------------
  // Hit-Update & Miss-Allocate Queue
  // ------------------------------------------------------
  //
  // This logic is concerned with allocating a new entry in the BTAC on a miss as well as updating
  // on a hit.  The hit-update path can either change the confidence bit or, if there is a target
  // address mispredict and the confidence bit is currently weak, update the target address.
  //
  // The RAMs are more area efficient if a single word-wide enable is used rather than multiple enables
  // to cover the confidence or target data portions.  Therefore the entire entry is stored in a queue, but
  // since this requires so much logic we only allow three in-flight predictions (research suggests that
  // three indirect in-flight branches will be rare, but possible).  If more than three predictions are
  // made before the first is resolved a further prediction can still be made, but it will not be queued.

  // Queue Format is essentially the BTAC RAM format with an extra bits for tracking whether a new allocation
  // is required or, if it is a hit-update, which Way/Stage
  assign new_btac_queue_entry = {btac_stg1_addr_if4,    // [72:66] - Stage-1 RAM source/target address
                                 btac_stg0_addr_if4,    // [65:59] - Stage-0 RAM source/target address
                                 btac_stg1_tag_hit,     // [58   ] - Hit-Update from Stage-0 (1'b0) or Stage-1 (1'b1)
                                 va_if4[17:10],         // [57:50] - Tag
                                 btac_confidence_if4,   // [49   ] - Confidence
                                 btac_data_if4[48],     // [48   ] - Sign
                                 btac_data_if4[47:1],   // [47: 1] - Data
                                 btac_data_if4[ 0  ]};  // [ 0   ] - ISA

  // Push control
  assign btac_queue_push = ~dpu_pf_force_i & btac_lookup_if4 & ~valid[2];

  // Pointer-Queue head entry
  assign nxt_btac_queue_head_entry = (({BTAC_QUEUE_WIDTH{~valid[1]            }} & new_btac_queue_entry) |
                                      ({BTAC_QUEUE_WIDTH{ valid[1] & ~read_ptr}} & btac_queue_entry[1]) |
                                      ({BTAC_QUEUE_WIDTH{ valid[1] &  read_ptr}} & btac_queue_entry[2]));

  assign btac_queue_entry_en[0] = ((~valid[0] & btac_queue_push             ) |
                                   ( valid[0] & btac_queue_push & btac_write) |
                                   ( valid[1]                   & btac_write));

  always @(posedge clk_btac_fine or negedge reset_n)
    if (!reset_n)
      btac_queue_entry[0] <= {BTAC_QUEUE_WIDTH{1'b0}};
    else if (btac_queue_entry_en[0])
      btac_queue_entry[0] <= nxt_btac_queue_head_entry;

  // Pointer-Queue main entries
  assign btac_main_queue_push   = (valid[0] & btac_queue_push & ~btac_write) | (valid[1] & btac_queue_push);
  assign btac_queue_entry_en[1] = ~write_ptr & btac_main_queue_push;
  assign btac_queue_entry_en[2] =  write_ptr & btac_main_queue_push;

  always @(posedge clk_btac_fine)
    if (btac_queue_entry_en[1])
      btac_queue_entry[1] <= new_btac_queue_entry;

  always @(posedge clk_btac_fine)
    if (btac_queue_entry_en[2])
      btac_queue_entry[2] <= new_btac_queue_entry;

  // Valid generation
  always @*
    case ({(btac_disable_i | dpu_pf_force_i), btac_queue_push, btac_write})
      3'b100, 3'b101, 3'b110, 3'b111 : nxt_valid = {3{1'b0}};
      3'b000, 3'b011                 : nxt_valid = valid[2:0];
      3'b001                         : nxt_valid = {1'b0, valid[2:1]};
      3'b010                         : nxt_valid = {valid[1:0], 1'b1};
      default                        : nxt_valid = {3{1'bx}};
    endcase

  // Read pointer generation
  always @*
    if (btac_disable_i | dpu_pf_force_i)
      nxt_read_ptr = 1'b0;
    else if (btac_write & valid[1])
      nxt_read_ptr = ~read_ptr;
    else
      nxt_read_ptr = read_ptr;

  // Write pointer generation
  always @*
    if (btac_disable_i | dpu_pf_force_i)
      nxt_write_ptr = 1'b0;
    else if (btac_main_queue_push)
      nxt_write_ptr = ~write_ptr;
    else
      nxt_write_ptr = write_ptr;

  assign en_update = btac_disable_i | dpu_pf_force_i | btac_write | btac_queue_push;

  always @(posedge clk_btac_coarse or negedge reset_n)
    if (!reset_n) begin
      read_ptr  <= 1'b0;
      write_ptr <= 1'b0;
      valid     <= {3{1'b0}};
    end
    else if (en_update) begin
      read_ptr  <= nxt_read_ptr;
      write_ptr <= nxt_write_ptr;
      valid     <= nxt_valid;
    end

  // Assign queue outputs
  assign prediction_stg1_addr = btac_queue_entry[0][72:66];
  assign prediction_stg0_addr = btac_queue_entry[0][65:59];
  assign prediction_stage     = btac_queue_entry[0][BTAC_Q_HU_STAGE_BIT];
  assign prediction_tag       = btac_queue_entry[0][57:50];
  assign prediction_confid    = btac_queue_entry[0][BTAC_Q_CONFIDENCE_BIT];
  assign prediction_data      = btac_queue_entry[0][48:0];

  // ------------------------------------------------------
  // Write path
  // ------------------------------------------------------

  always @*
    begin
      // Defaults
      stg0_ram_wr          = 1'b0;
      stg0_ram_wdata_force = 1'b0;
      stg1_ram_wr          = 1'b0;
      stg1_ram_wdata_force = 1'b0;

      case (write_state)
        BTAC_WRITE_STATE_IDLE : begin
          nxt_write_state = (btac_initialise                              ? BTAC_WRITE_STATE_INVRAM :
                             (dpu_btac_ret_i & ~btac_disable_i & valid[0]) ? BTAC_WRITE_STATE_WRITE  : BTAC_WRITE_STATE_IDLE);
        end
        BTAC_WRITE_STATE_WRITE : begin
          // On a Miss-Allocate the IFU pipeline will be empty so we'll always be able
          // to access the RAMs.
          //
          // Hit-Updates may be back-to-back so we must be able to stay in this state.
          //
          // Also, the IFU pipeline may not be empty if we are just incrementing the
          // confidence bit.  Writes take priority over reads, which is counter-intuitive
          // for performance, but eases timing paths and read/write conflicts are
          // anticipated to be rare.
          nxt_write_state = (dpu_btac_ret_i & valid[1]) ? BTAC_WRITE_STATE_WRITE : BTAC_WRITE_STATE_IDLE;

          // Determining what to update is quite complicated:
          //
          // Force  | Prediction | Prediction |+|  Stage-0 Operation  |  Stage-1 Operation  | Commited History
          //        |    Stage   | Confidence |+|                     |                     |     Source
          //   0    |      0     |      0     |+| Increase Confidence |      No Change      |   Queue Data
          //   0    |      0     |      1     |+|      No Change      |      No Change      |   Queue Data
          //   0    |      1     |      0     |+|      No Change      | Increase Confidence |   Queue Data
          //   0    |      1     |      1     |+|      No Change      |      No Change      |   Queue Data
          //   1    |      0     |      0     |+|  Allocate New Entry |  Allocate New Entry |    IF1 AGU
          //   1    |      0     |      1     |+| Decrease Confidence |  Allocate New Entry |    IF1 AGU
          //   1    |      1     |      0     |+|      No Change      |     Update Entry    |    IF1 AGU
          //   1    |      1     |      1     |+|      No Change      | Decrease Confidence |    IF1 AGU
          //
          // To ease timing paths, the enables are calculated precisely from the truth table, but
          // the data defaults to common values - even if not written.
          //
          // New allocations or updated entries have a confidence of 1.

          // Stage-0
          stg0_ram_wr          = ((~last_cycle_force_ret & ~prediction_stage & ~prediction_confid) |
                                  ( last_cycle_force_ret & ~prediction_stage                     ));
          stg0_ram_wdata_force = last_cycle_force_ret & ~prediction_stage & ~prediction_confid;

          // Stage-1
          stg1_ram_wr          = ((~last_cycle_force_ret &  prediction_stage & ~prediction_confid) |
                                  ( last_cycle_force_ret &  prediction_stage                     ) |
                                  ( last_cycle_force_ret & ~prediction_stage                     ));
          stg1_ram_wdata_force = last_cycle_force_ret & ~(prediction_stage & prediction_confid);
        end
        BTAC_WRITE_STATE_INVRAM : begin
          // Control RAM invalidation
          nxt_write_state = ctl_mbist_req_i ? BTAC_WRITE_STATE_IDLE :
                            btac_address_en ? BTAC_WRITE_STATE_INVRAM : BTAC_WRITE_STATE_IDLE;
        end
        BTAC_WRITE_STATE_UNREACH : begin
          // Use defaults
          nxt_write_state = BTAC_WRITE_STATE_IDLE;
        end
        default : begin
          nxt_write_state      = {BTAC_WRITE_STATE_W{1'bx}};
          stg0_ram_wr          = 1'bx;
          stg0_ram_wdata_force = 1'bx;
          stg1_ram_wr          = 1'bx;
          stg1_ram_wdata_force = 1'bx;
        end
      endcase
    end

  always @(posedge clk_btac_coarse)
    begin
      last_cycle_force_wr  <= dpu_fe_valid_wr_i;
      last_cycle_force_ret <= dpu_fe_valid_ret_i;
    end

  always @(posedge clk_btac_coarse or negedge reset_n)
    if (!reset_n)
      write_state <= {BTAC_WRITE_STATE_W{1'b0}};
    else
      write_state <= nxt_write_state;

  always @(posedge clk_btac_fine or negedge reset_n)
    if (!reset_n)
      btac_initialise <= 1'b1;
    else if (btac_initialise)
      btac_initialise <= 1'b0;

  // ------------------------------------------------------
  // RAM Initialisation
  // ------------------------------------------------------

  assign nxt_btac_address = {7{write_state == BTAC_WRITE_STATE_INVRAM}} & (btac_address[6:0] + 7'h01);

  assign btac_address_en = (write_state == BTAC_WRITE_STATE_INVRAM) & btac_address != 7'h7F;

  always @(posedge clk_btac_fine or negedge reset_n)
    if (!reset_n)
      btac_address <= {7{1'b0}};
    else if (btac_address_en)
      btac_address <= nxt_btac_address;

  // ------------------------------------------------------
  // Arbitration
  // ------------------------------------------------------
  //
  // Writes take priority over reads

  // Identify specific BTAC states
  assign btac_invalidate = write_state == BTAC_WRITE_STATE_INVRAM;
  assign btac_write      = write_state == BTAC_WRITE_STATE_WRITE;

  // Stage-0 RAM interface
  assign btac_stg0_ram_en_o    = (ctl_mbist_btac_en_mb4_i[0] | btac_invalidate | stg0_ram_wr | btac_instr_in_if3 | (btac_skew_loopkup_if4 & ~btac_write)) & ~DFTRAMHOLD;
  assign btac_stg0_ram_wr_o    = ctl_mbist_btac_wr_mb4_i     | btac_invalidate | stg0_ram_wr;
  assign btac_stg0_ram_wdata_o = (ctl_mbist_btac_en_mb4_i[0] ? ctl_mbist_btac_wdata_mb4_i[49:0]     :
                                  stg0_ram_wdata_force       ? {1'b1, va_if1_i[48:1], cpsr_state_i} :
                                                               {~prediction_confid, prediction_data[48:0]});
  assign btac_stg0_ram_addr_o  = (ctl_mbist_btac_en_mb4_i[0] ? ctl_mbist_btac_addr_mb4_i :
                                  btac_invalidate            ? btac_address              :
                                  btac_write                 ? prediction_stg0_addr      : stg0_ram_raddr);

  // Stage-1 RAM interface
  assign btac_stg1_ram_en_o    = (ctl_mbist_btac_en_mb4_i[1] | btac_invalidate | stg1_ram_wr | btac_instr_in_if3 | (btac_skew_loopkup_if4 & ~btac_write)) & ~DFTRAMHOLD;
  assign btac_stg1_ram_wr_o    = ctl_mbist_btac_wr_mb4_i     | btac_invalidate | stg1_ram_wr;
  assign btac_stg1_ram_wdata_o = (ctl_mbist_btac_en_mb4_i[1] ? ctl_mbist_btac_wdata_mb4_i[58:0] :
                                  stg1_ram_wdata_force       ? {1'b1,       prediction_tag[7:0], 1'b1, va_if1_i[48:1], cpsr_state_i} :
                                                               {btac_write, prediction_tag[7:0], ~prediction_confid, prediction_data[48:0]});
  assign btac_stg1_ram_addr_o  = (ctl_mbist_btac_en_mb4_i[1] ? ctl_mbist_btac_addr_mb4_i :
                                  btac_invalidate            ? btac_address              :
                                  btac_write                 ? prediction_stg1_addr      : stg1_ram_raddr);

  // ------------------------------------------------------
  // Output assignments
  // ------------------------------------------------------

  assign brn_btac_pushed_if3_o   = brn_btac_pushed_if3;
  assign btac_invalidate_o       = btac_invalidate;
  assign btac_lookup_stall_if4_o = btac_lookup_stall_if4;
  assign btac_skew_loopkup_if4_o = btac_skew_loopkup_if4;
  assign btac_hit_addr_if4_o     = btac_data_if4[48:0];
  assign btac_hit_if4_o          = btac_lookup_if4;

  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: btac_queue_entry_en[0]")
  u_ovl_x_btac_queue_entry_en0 (.clk       (clk_btac_fine),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (btac_queue_entry_en[0]));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: btac_queue_entry_en[1]")
  u_ovl_x_btac_queue_entry_en1 (.clk       (clk_btac_fine),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (btac_queue_entry_en[1]));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: btac_queue_entry_en[2]")
  u_ovl_x_btac_queue_entry_en2 (.clk       (clk_btac_fine),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (btac_queue_entry_en[2]));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: btac_address_en")
  u_ovl_x_btac_address_en (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (btac_address_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: btac_initialise")
  u_ovl_x_btac_initialise (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (btac_initialise));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_cm_gh")
  u_ovl_x_en_cm_gh (.clk       (clk),
                    .reset_n   (reset_n),
                    .qualifier (1'b1),
                    .test_expr (en_cm_gh));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_sp_gh")
  u_ovl_x_en_sp_gh (.clk       (clk),
                    .reset_n   (reset_n),
                    .qualifier (1'b1),
                    .test_expr (en_sp_gh));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_update")
  u_ovl_x_en_update (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (en_update));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_va_if4")
  u_ovl_x_en_va_if4 (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (en_va_if4));

  // ----------------------------------------------------------------------------
  // State machine checks
  // ----------------------------------------------------------------------------

  assert_never #(`OVL_FATAL,`OVL_ASSERT, "State Machine has reached an illegal state")
    ovl_state_machine_ill (.clk       (clk),
                           .reset_n   (reset_n),
                           .test_expr (write_state == BTAC_WRITE_STATE_UNREACH));

  assert_never_unknown #(`OVL_FATAL, 2,`OVL_ASSERT, "State Machine is unknown")
    ovl_state_machine_x (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (write_state[1:0]));

  // ----------------------------------------------------------------------------
  // Queue checks
  // ----------------------------------------------------------------------------

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"BTAC Queue read-ptr should equal write-ptr if queue is not being used")
    ovl_queue_rd_wr_ptr_incorrect (.clk             (clk),
                                   .reset_n         (reset_n),
                                   .antecedent_expr (~valid[1] & ~valid[2]),
                                   .consequent_expr (read_ptr == write_ptr));

  assert_never #(`OVL_FATAL,`OVL_ASSERT, "Valid indicator jumping to full")
    ovl_valid_jumps (.clk       (clk),
                     .reset_n   (reset_n),
                     .test_expr (valid[2] & ~valid[1]));

  assert_never_unknown #(`OVL_FATAL, BTAC_QUEUE_WIDTH,`OVL_ASSERT, "Writing X into BTAC queue head entry")
    ovl_queue_head_entry_x (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (btac_queue_entry_en[0]),
                            .test_expr (nxt_btac_queue_head_entry));

  assert_never_unknown #(`OVL_FATAL, BTAC_QUEUE_WIDTH,`OVL_ASSERT, "Writing X into BTAC queue pointer entries")
    ovl_queue_ptr_entry_x (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (btac_queue_entry_en[1] | btac_queue_entry_en[2]),
                           .test_expr (new_btac_queue_entry));

  // ----------------------------------------------------------------------------
  // Regional clock gate checks
  // ----------------------------------------------------------------------------

  assert_never_unknown #(`OVL_FATAL, 1,`OVL_ASSERT, "Regional enable (fine grained) is x")
    ovl_regional_en_fine_x (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (btac_fine_clock_en));

  assert_never_unknown #(`OVL_FATAL, 1,`OVL_ASSERT, "Regional enable (coarse grained) is x")
    ovl_regional_en_coarse_x (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (btac_coarse_clock_en));

  // ----------------------------------------------------------------------------
  // Branch history
  // ----------------------------------------------------------------------------

  // Check that the branch history is stable after a force once all updates are complete
  // and the first instruction after a force has made it to IF3.
  reg    ovl_force_plus1;
  reg    ovl_force_plus2;
  reg    ovl_force_plus3;

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      ovl_force_plus1      <= 1'b0;
      ovl_force_plus2      <= 1'b0;
      ovl_force_plus3      <= 1'b0;
    end
    else begin
      ovl_force_plus1      <= dpu_pf_force_i; // IF1<=IF0
      ovl_force_plus2      <= ovl_force_plus1; // IF2<=IF1
      ovl_force_plus3      <= ovl_force_plus2; // IF3<=IF2
    end

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Stage-0 speculative & committed histories don't match after a force")
    ovl_stg0_history_match (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (ovl_force_plus3),
                            .consequent_expr (cm_stg0_gh == sp_stg0_gh));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Stage-1 speculative & committed histories don't match after a force")
    ovl_stg1_history_match (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr (ovl_force_plus3),
                            .consequent_expr (cm_stg1_gh == sp_stg1_gh));

  // ----------------------------------------------------------------------------
  // RAM lookup address
  // ----------------------------------------------------------------------------

  // Check that the RAM lookup addresses remain stable when a write is skewing a read
  reg [6:0]   ovl_stg0_ram_raddr;
  reg [6:0]   ovl_stg1_ram_raddr;

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      ovl_stg0_ram_raddr <= {7{1'b0}};
      ovl_stg1_ram_raddr <= {7{1'b0}};
    end
    else begin
      ovl_stg0_ram_raddr <= stg0_ram_raddr;
      ovl_stg1_ram_raddr <= stg1_ram_raddr;
    end

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Stage-0 RAM lookup address is not stable on a skewed read")
    ovl_stg0_look_addr_stable (.clk             (clk),
                               .reset_n         (reset_n),
                               .antecedent_expr (btac_skew_loopkup_if4),
                               .consequent_expr (ovl_stg0_ram_raddr == stg0_ram_raddr));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Stage-1 RAM lookup address is not stable on a skewed read")
    ovl_stg1_look_addr_stable (.clk             (clk),
                               .reset_n         (reset_n),
                               .antecedent_expr (btac_skew_loopkup_if4),
                               .consequent_expr (ovl_stg1_ram_raddr == stg1_ram_raddr));
`endif

endmodule

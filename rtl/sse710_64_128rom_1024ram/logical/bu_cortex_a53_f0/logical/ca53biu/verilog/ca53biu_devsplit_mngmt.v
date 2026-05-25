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
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : BIU device split management
//-----------------------------------------------------------------------------
//
// Overview
// -------
// DC3 device split logic
// Other features:
//  o AR throttle support following the DPU setting

`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53_dcu_biu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53biu_defs.v"

module ca53biu_devsplit_mngmt
  (
   //----------------------------------------------------------------------------
   // Clock and Reset
   //----------------------------------------------------------------------------

   input  wire                                    clk,
   input  wire                                    reset_n,

   //------------------------------------------------------------------------------
   // DPU Interface
   //------------------------------------------------------------------------------

   input  wire                                    dpu_disable_device_split_throttle_i,

   //-----------------------------------------------------------------------------
   // DC3 Flush/CC fail and the outstanding load address [5:0]
   //-----------------------------------------------------------------------------

   input  wire                                    biu_cc_fail_or_flush_dc3_i,
   input  wire                                    biu_leaving_dc3_i,
   input  wire                                    biu_load_dc3_i,
   input  wire [5:0]                              biu_load_pa_dc3_i,

   //-----------------------------------------------------------------------------
   // DC3 Address Request Channel
   //-----------------------------------------------------------------------------

   input  wire                                    dcu_neon_access_dc3_i,
   input  wire                                    dcu_biu_req_dc3_i,
   input  wire [7:0]                              dcu_attrs_dc3_i,
   input  wire [1:0]                              dcu_size_dc3_i,
   input  wire [3:0]                              dcu_length_dc3_i,

   //-----------------------------------------------------------------------------
   // DC3 AR Arbiter (ca53biu_addr_req_arbiter)
   //-----------------------------------------------------------------------------

   input  wire [1:0]                              dc3_trans_cross128_i,
   input  wire                                    dc3_trans_last_beat_i,
   input  wire                                    biu_ar_ready_dev_i,
   input  wire [2:0]                              biu_ar_id_dev_i,

   //-----------------------------------------------------------------------------
   // DC3 DR Buffers (ca53biu_data_read_buffers)
   //-----------------------------------------------------------------------------

   input  wire                                    data_fwd_dc3_i,

   //------------------------------------------------------------------------------
   // Loads Device Management
   //------------------------------------------------------------------------------

   output wire                                    dev_active_o,
   output wire                                    dev_req_o,
   output wire [5:0]                              dev_addr_o,
   output wire [2:0]                              dev_size_o,
   output wire [1:0]                              dev_length_o,
   output wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]      dev_id_outstanding_o,
   output wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]      dev_id_pending_o,

   //-----------------------------------------------------------------------------
   // Gov Management
   //-----------------------------------------------------------------------------

   output wire                                    dev_idle_o
  );

  //-----------------------------------------------------------------------------
  // Local parameters
  //-----------------------------------------------------------------------------

  localparam STATE_W                             = 2;
  localparam [STATE_W-1:0] STATE_IDLE            = 2'b00;
  localparam [STATE_W-1:0] STATE_AR_REQ_PENDING  = 2'b01;
  localparam [STATE_W-1:0] STATE_AR_REQ_THROTTLE = 2'b10;
  localparam [STATE_W-1:0] STATE_DR_WAIT_LAST    = 2'b11;

  //-----------------------------------------------------------------------------
  // Registers
  //-----------------------------------------------------------------------------

  reg  [STATE_W-1:0]                             dev_mngmt_state;
  reg  [STATE_W-1:0]                             next_dev_mngmt_state;
  reg  [`CA53_BIU_DCU_NC_ID_NUM-1:0]             dev_id_order_bits_valid;
  reg  [2:0]                                     ar_curr_len_dev [`CA53_BIU_DCU_NC_ID_NUM-1:0];
  reg  [5:3]                                     ar_last_addr_dev [`CA53_BIU_DCU_NC_ID_NUM-1:0];
  reg  [5:3]                                     ar_last_addr_dev_outstanding;
  reg  [3:0]                                     ar_total_words_pend_dev;
  reg  [5:3]                                     ar_addr_pend_dev;
  reg  [`CA53_BIU_RBUFS_NUM_W:0]                 rd_buff_dev_available;

  //-----------------------------------------------------------------------------
  // Wires
  //-----------------------------------------------------------------------------

  wire                                           biu_load_leaving_dc3;
  wire                                           biu_last_load_leaving_dc3;
  wire                                           biu_last_load_leaving_or_drop_dc3;
  wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]             dev_id_order_bits [`CA53_BIU_DCU_NC_ID_NUM-1:0];
  wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]             dev_id_outstanding;
  wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]             dev_id_alloc_req;
  wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]             dev_id_rel_req;
  wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]             next_dev_id_order_bits_valid;
  wire [2:0]                                     dev_len_outstanding;
  wire [6:2]                                     ar_last_addr_dev_sum;
  wire [2:0]                                     ar_curr_len_dev_dec [`CA53_BIU_DCU_NC_ID_NUM-1:0];
  wire [`CA53_BIU_DCU_NC_ID_NUM-1:0]             ar_curr_len_dev_en;
  wire [2:0]                                     next_ar_curr_len_dev [`CA53_BIU_DCU_NC_ID_NUM-1:0];
  wire [1:0]                                     ar_beat_words_dev;
  wire [3:0]                                     ar_total_words_dev;
  wire                                           dr_last_beat_dev;
  wire                                           dr_last_qword_dev;
  wire                                           ar_last_dev;
  wire [1:0]                                     ar_len_dev;
  wire [2:0]                                     ar_len_dev_inc;
  wire [2:0]                                     ar_size_dev;
  wire                                           ar_done_dev_valid;
  wire [2:0]                                     rd_buff_dev_rel;
  wire [1:0]                                     rd_buff_dev_issue;
  wire [4:0]                                     ar_total_words_pend_dev_sum;
  wire [6:2]                                     ar_addr_pend_dev_sum;
  wire [3:0]                                     ar_total_words_init_dev;
  wire [3:0]                                     ar_total_words_init_dev_neon;
  wire [3:0]                                     current_ar_total_words_pend_dev;
  wire [5:2]                                     current_ar_addr_pend_dev;
  wire [`CA53_BIU_RBUFS_NUM_W_INC:0]             rd_buff_dev_available_sum;
  wire                                           rd_buff_dev_available_en;
  wire [`CA53_BIU_RBUFS_NUM_W:0]                 next_rd_buff_dev_available;
  wire                                           dev_mngmt_state_idle;
  wire                                           dev_mngmt_state_ar_req_pending;

  //-----------------------------------------------------------------------------
  // Generate variables
  //-----------------------------------------------------------------------------

  genvar                                         index_i;
  genvar                                         index_j;

  //-----------------------------------------------------------------------------
  // Devices load transactions management:
  // - Initiates the BIU-SCU read transactions for the device load instructions,
  //   fulfilling the below requirements:
  //   o fetch power of two bytes per each BIU-SCU transaction
  //   o fetch the exact number of bytes accessed by the instruction for non-NEON device loads
  //   o device NEON are permitted to access bytes that are not explicitly accessed by the instruction,
  //   provided the bytes accessed are in a 16-byte window, aligned to 16-bytes, that contains at least
  //   one byte that is explicitly accessed by the instruction.
  //   o guarantee forward progress and thus not fetch more chunks than the read buffers available
  //   (in order to allow data reordering for device non-NEON accesses received out of order from the SCU)
  //   o issue more than one outstanding BIU-SCU load transactions in order to fetch data
  //   in advance for the entire instruction based on the read buffers availability
  //   (controlled through the dpu_disable_device_split_throttle_i)
  //   o factorize the potential beats forwarded from the STB for the device GRE load transactions
  // - Maintains the order of IDs of the multiple outstanding BIU-SCU transactions issued to the same
  //   device load instruction
  // - Maintains the status of outstanding device transactions to the current device load instruction
  //   (last address and chunks used per each BIU-SCU transaction ID)
  // - Tracks the number of read buffers used by the outstanding device transactions to the current
  //   device load instruction
  //-----------------------------------------------------------------------------

  // Check if the load is leaving DC3

  assign biu_load_leaving_dc3              = biu_load_dc3_i & biu_leaving_dc3_i;
  assign biu_last_load_leaving_dc3         = biu_load_leaving_dc3 & dc3_trans_last_beat_i;
  assign biu_last_load_leaving_or_drop_dc3 = biu_last_load_leaving_dc3 | biu_cc_fail_or_flush_dc3_i;

  // Check if the outstanding DC3 load address is within the range of the device split transaction

  assign ar_done_dev_valid = biu_ar_ready_dev_i                                           &
                             ((ar_last_addr_dev_sum[5:3] > biu_load_pa_dc3_i[5:3])     |
                               ((ar_last_addr_dev_sum[5:3] == biu_load_pa_dc3_i[5:3]) &
                                (biu_load_dc3_i & ~biu_leaving_dc3_i                  ))) &
                             ~biu_last_load_leaving_dc3;

  // The current address of the device load

  assign current_ar_addr_pend_dev = ~dev_mngmt_state_idle ? {ar_addr_pend_dev, 1'b0}        :
                                    dcu_neon_access_dc3_i ? {biu_load_pa_dc3_i[5:4], 2'b00} :
                                                            biu_load_pa_dc3_i[5:2];

  // The DC3 dev trans total words:
  // o device non-NEON fetches the exact number of words accessed by the instruction
  // o device NEON are permitted to access bytes that are not explicitly accessed by the instruction,
  //   provided the bytes accessed are in a 16-byte window, aligned to 16-bytes, that contains at least
  //   one byte that is explicitly accessed by the instruction.

  assign ar_total_words_init_dev[3:0]      = dcu_length_dc3_i[3:0];

  assign ar_total_words_init_dev_neon[3:0] = {dc3_trans_cross128_i, 2'b11};

  // The current length of the device load

  assign current_ar_total_words_pend_dev = ~dev_mngmt_state_idle ? ar_total_words_pend_dev      :
                                           dcu_neon_access_dc3_i ? ar_total_words_init_dev_neon :
                                                                   ar_total_words_init_dev;

  // The device length from the current transaction issued to the SCU

  assign ar_len_dev = // o Four qwords fetched from SCU
                      //   (the start addr must be 64 bytes aligned for dev load and the number of
                      //    read buffers available for device has to be higher or equal to four)
                      ((&current_ar_total_words_pend_dev[3:0]) & rd_buff_dev_available[2])               ? `CA53_REQ_LEN3 :
                      // o Two qwords fetched from SCU
                      //   (the start addr must be in qword0 or qword2 and
                      //    the start addr must be qword aligned and
                      //    the number of words higher or equal to eight and
                      //    the number of read buffers available for device has to be higher or equal to two)
                      (~current_ar_addr_pend_dev[4]                                                   &
                       (current_ar_addr_pend_dev[3:2] == 2'b00)                                       &
                       (current_ar_total_words_pend_dev[3] | (&current_ar_total_words_pend_dev[2:0])) &
                       (rd_buff_dev_available[2] | rd_buff_dev_available[1]                           )) ? `CA53_REQ_LEN1 :
                      // o One word, dword or qword fetched from SCU
                      //   (the start addr must be word/dword/qword aligned and the number of
                      //    read buffers available for device has to be higher or equal to one)
                                                                                                           `CA53_REQ_LEN0;

  // The device size from the current transaction issued to the SCU

  assign ar_size_dev = // o The byte and hword load are always single accesses not crossing the dword aligned window
                       //   and thus they preserve the size attributes received from the DCU for non-NEON accesses
                       (~dcu_neon_access_dc3_i & ~dcu_size_dc3_i[1])                                 ? {1'b0, dcu_size_dc3_i} :
                       // o The start load address is the second or the most significant
                       //   word from the qword OR
                       // o The number of words required by DCU is one
                       (current_ar_addr_pend_dev[2]       |
                        (~|current_ar_total_words_pend_dev))                                         ? `CA53_ACE_SIZE_32BIT    :
                       // o The start load address is on the third significant word from the qword
                       //   (and the number of words is higher than one) OR
                       // o The number of words required by DCU less than four
                       //   (and the transaction does not cross the qword aligned window)
                       ((current_ar_addr_pend_dev[3:2] == 2'b10)                                  |
                        ((~|current_ar_total_words_pend_dev[3:2])                                &
                         (current_ar_total_words_pend_dev[1] ^ current_ar_total_words_pend_dev[0]))) ? `CA53_ACE_SIZE_64BIT    :
                       // o Full qword(s) are fetched from SCU
                                                                                                       `CA53_ACE_SIZE_128BIT;

  // Dev trans words per beat minus one

  assign ar_beat_words_dev = (ar_size_dev == `CA53_ACE_SIZE_128BIT) ? 2'b11 :
                             (ar_size_dev == `CA53_ACE_SIZE_64BIT)  ? 2'b01 :
                                                                      2'b00;

  // Dev trans total words minus one

  assign ar_total_words_dev = (ar_len_dev[1:0] == `CA53_REQ_LEN0) ? {2'b00, ar_beat_words_dev}       :
                              (ar_len_dev[1:0] == `CA53_REQ_LEN1) ? {1'b0,  ar_beat_words_dev, 1'b1} :
                                                                    {ar_beat_words_dev, 2'b11};

  // The remaining words minus one required to be requested from the SCU

  assign ar_total_words_pend_dev_sum = current_ar_total_words_pend_dev - ar_total_words_dev - 1'b1;

  // The last AR device transaction required to be issued to the SCU

  assign ar_last_dev = (current_ar_total_words_pend_dev == ar_total_words_dev);

  // The next addr to be requested from the SCU

  assign ar_addr_pend_dev_sum  = current_ar_addr_pend_dev + ar_total_words_dev + 1'b1;

  // Register the next addr & total number of words left to be requested

  always @(posedge clk)
    if (biu_ar_ready_dev_i) begin
      ar_addr_pend_dev        <= ar_addr_pend_dev_sum[5:3];
      ar_total_words_pend_dev <= ar_total_words_pend_dev_sum[3:0];
    end

  // Get the last addr for the outstanding dev trans

  always @* begin : ar_last_addr_mux
    integer   index_k;
    reg [5:3] tmp_ar_last_addr_dev_outstanding;

    tmp_ar_last_addr_dev_outstanding = {3{1'b0}};

    for (index_k = 0; index_k < `CA53_BIU_DCU_NC_ID_NUM; index_k = index_k + 1) begin
      tmp_ar_last_addr_dev_outstanding = tmp_ar_last_addr_dev_outstanding                                  |
                                         (ar_last_addr_dev[index_k][5:3] & {3{dev_id_outstanding[index_k]}});
    end

    ar_last_addr_dev_outstanding = tmp_ar_last_addr_dev_outstanding;
  end

  //-----------------------------------------------------------------------------
  // Compute the next read buffers available for device loads
  // o the BIU cannot issue a device load transaction with the length higher
  //   than the rd_buff_dev_available (in order to guarantee re-ordering of read data)
  //-----------------------------------------------------------------------------

  assign dr_last_beat_dev           = dc3_trans_last_beat_i                                  |
                                      (ar_last_addr_dev_outstanding == biu_load_pa_dc3_i[5:3]);

  assign dr_last_qword_dev          = biu_load_pa_dc3_i[3];

  assign rd_buff_dev_rel            = {3{// DC3 device pend
                                         ~dev_mngmt_state_idle                 &
                                         // Dev split trans outstanding
                                         (|dev_id_order_bits_valid)            &
                                         // Dev split load fwd-ed/leaving DC3
                                         (data_fwd_dc3_i | biu_load_leaving_dc3)}}    &
                                      (// Last address from the current device transaction
                                       ({3{dr_last_beat_dev}} & dev_len_outstanding) |
                                       // Last data transfer from the current qword
                                       {2'b00, ~dr_last_beat_dev & dr_last_qword_dev });

  assign rd_buff_dev_issue          = {2{ar_done_dev_valid}} & ar_len_dev[1:0];

  assign rd_buff_dev_available_sum  = rd_buff_dev_available     +
                                      rd_buff_dev_rel           -
                                      {1'b0, rd_buff_dev_issue} -
                                      {2'b00, ar_done_dev_valid };

  assign next_rd_buff_dev_available = biu_cc_fail_or_flush_dc3_i ? `CA53_BIU_RBUFS_NUM_W_INC'h`CA53_BIU_RBUFS_NUM         :
                                                                   rd_buff_dev_available_sum[`CA53_BIU_RBUFS_NUM_W_INC-1:0];

  assign rd_buff_dev_available_en   = biu_cc_fail_or_flush_dc3_i |
                                      data_fwd_dc3_i             |
                                      biu_load_leaving_dc3       |
                                      ar_done_dev_valid;

  // Register the read buffers available info

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      rd_buff_dev_available <= `CA53_BIU_RBUFS_NUM_W_INC'h`CA53_BIU_RBUFS_NUM;
    end else if (rd_buff_dev_available_en) begin
      rd_buff_dev_available <= next_rd_buff_dev_available;
    end

  //-------------------------------------------------------------------------------------------------------
  // Device split transactions read IDs ordering bits
  //-------------------------------------------------------------------------------------------------------

  assign dev_id_alloc_req = {`CA53_BIU_DCU_NC_ID_NUM{ar_done_dev_valid & ~biu_cc_fail_or_flush_dc3_i}} &
                            { biu_ar_id_dev_i[1] &  biu_ar_id_dev_i[0],
                              biu_ar_id_dev_i[1] & ~biu_ar_id_dev_i[0],
                             ~biu_ar_id_dev_i[1] &  biu_ar_id_dev_i[0],
                             ~biu_ar_id_dev_i[1] & ~biu_ar_id_dev_i[0]                                 };

  generate
    for (index_i = 0; index_i < `CA53_BIU_DCU_NC_ID_NUM; index_i = index_i + 1) begin : g_dev_id_rel_req_01
      assign dev_id_rel_req[index_i] = (dc3_trans_last_beat_i                                    |
                                        (ar_last_addr_dev[index_i][5:3] == biu_load_pa_dc3_i[5:3])) &
                                       (data_fwd_dc3_i | biu_load_leaving_dc3                       );
    end
  endgenerate

  assign next_dev_id_order_bits_valid = ~{`CA53_BIU_DCU_NC_ID_NUM{biu_cc_fail_or_flush_dc3_i}}         &
                                        ((dev_id_order_bits_valid & ~dev_id_rel_req) | dev_id_alloc_req);

  // Register dev_id_order_bits_valid

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      dev_id_order_bits_valid <= {`CA53_BIU_DCU_NC_ID_NUM{1'b0}};
    end else begin
      dev_id_order_bits_valid <= next_dev_id_order_bits_valid;
    end

  // Number of data beats issued to the AR channel by the current device split transaction

  assign ar_len_dev_inc = ar_len_dev[1:0] + 1'b1;

  // Update the last addr per each ID of the outstanding device transactions

  assign ar_last_addr_dev_sum = current_ar_addr_pend_dev[5:2] + ar_total_words_dev;

  generate
    for (index_i = 0; index_i < `CA53_BIU_DCU_NC_ID_NUM; index_i = index_i + 1) begin : g_ar_last_addr_dev_01

      assign ar_curr_len_dev_dec[index_i]  = ar_curr_len_dev[index_i] - 1'b1;

      assign next_ar_curr_len_dev[index_i] = dev_id_alloc_req[index_i] ? ar_len_dev_inc             :
                                                                         ar_curr_len_dev_dec[index_i];
      assign ar_curr_len_dev_en[index_i]   = dev_id_alloc_req[index_i]               |
                                             (dev_id_outstanding[index_i]           &
                                              dr_last_qword_dev                     &
                                              (data_fwd_dc3_i | biu_load_leaving_dc3));

      always @(posedge clk)
        if (ar_curr_len_dev_en[index_i]) begin
          ar_curr_len_dev[index_i] <= next_ar_curr_len_dev[index_i];
        end

      always @(posedge clk)
        if (dev_id_alloc_req[index_i]) begin
          ar_last_addr_dev[index_i] <= ar_last_addr_dev_sum[5:3];
        end
    end
  endgenerate

  // In order to maintain ordering between ID requests, the IDs ordering bits are maintained.
  // These form a matrix. The ordering bit in the i-th row and j-th column indicates that
  // the i-th request ID is ordered after the j-th if it is set, or the reverse otherwise.
  // For example, if there were five request IDs:
  //
  //      A  B  C  D  E
  //   A  0  0  1  0  0
  //   B  1  0  1  1  1
  //   C  0  0  0  0  0
  //   D  1  0  1  0  0
  //   E  1  0  1  1  0
  //
  // This set of bits indicates that the ID requests are ordered C (oldest), A, D, E, B (youngest).
  // It can be observed that the bits on the diagonal (where i == j) are always zero, and that
  // the bits in the lower-left triangle are a complement of those in the upper-right triangle.
  // As such, it is only necessary to actually register the upper-right triangle of bits.
  //
  // When a request ID is allocated, it becomes the youngest ID, and so all bits in
  // the row corresponding to that ID are set, and all bits in the corresponding column
  // are cleared.

  generate
    for (index_i = 0; index_i < `CA53_BIU_DCU_NC_ID_NUM; index_i = index_i + 1) begin : g_dev_id_ordering_outer
      for (index_j = 0; index_j < `CA53_BIU_DCU_NC_ID_NUM; index_j = index_j + 1) begin : g_dev_id_ordering_inner
        if (index_i < index_j) begin : g_dev_id_ordering_nested_0
          reg   dev_id_ordering_bit;
          wire  next_dev_id_ordering_bit;

          assign next_dev_id_ordering_bit = dev_id_alloc_req[index_i]                        |
                                            (dev_id_ordering_bit & ~dev_id_alloc_req[index_j]);

          always @(posedge clk)
            if (biu_ar_ready_dev_i) begin
              dev_id_ordering_bit <= next_dev_id_ordering_bit;
            end

          assign dev_id_order_bits[index_i][index_j] = dev_id_ordering_bit;

        end else if (index_i == index_j) begin : g_dev_id_ordering_nested_0_else_0

          assign dev_id_order_bits[index_i][index_j] = 1'b0;

        end else begin : g_dev_id_ordering_nested_0_else_1

          assign dev_id_order_bits[index_i][index_j] = ~dev_id_order_bits[index_j][index_i];

        end
      end
    end
  endgenerate

  generate
    for (index_i = 0; index_i < `CA53_BIU_DCU_NC_ID_NUM; index_i = index_i + 1) begin : g_dev_id_outstanding
      assign dev_id_outstanding[index_i] = ~|(dev_id_order_bits[index_i][`CA53_BIU_DCU_NC_ID_NUM-1:0] &
                                              dev_id_order_bits_valid[`CA53_BIU_DCU_NC_ID_NUM-1:0]     ) &
                                           dev_id_order_bits_valid[index_i];
    end
  endgenerate

  assign dev_len_outstanding = (ar_curr_len_dev[0] & {3{dev_id_outstanding[0]}}) |
                               (ar_curr_len_dev[1] & {3{dev_id_outstanding[1]}}) |
                               (ar_curr_len_dev[2] & {3{dev_id_outstanding[2]}}) |
                               (ar_curr_len_dev[3] & {3{dev_id_outstanding[3]}}  );

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign dev_id_outstanding_o = dev_id_outstanding;
  assign dev_id_pending_o     = dev_id_order_bits_valid;

  //-----------------------------------------------------------------------------
  // Load devices management FSM
  //-----------------------------------------------------------------------------

  always @* begin
    case (dev_mngmt_state)
      STATE_IDLE:
        if (biu_ar_ready_dev_i && !biu_cc_fail_or_flush_dc3_i) begin
          if (ar_last_dev) begin
            next_dev_mngmt_state = STATE_DR_WAIT_LAST;
          end else if (!dpu_disable_device_split_throttle_i) begin
            next_dev_mngmt_state = STATE_AR_REQ_THROTTLE;
          end else begin
            next_dev_mngmt_state = STATE_AR_REQ_PENDING;
          end
        end else begin
          next_dev_mngmt_state = STATE_IDLE;
        end

      STATE_AR_REQ_PENDING:
        if (biu_last_load_leaving_or_drop_dc3) begin
          next_dev_mngmt_state = STATE_IDLE;
        end else if (ar_done_dev_valid) begin
          if (ar_last_dev) begin
            next_dev_mngmt_state = STATE_DR_WAIT_LAST;
          end else if (!dpu_disable_device_split_throttle_i) begin
            next_dev_mngmt_state = STATE_AR_REQ_THROTTLE;
          end else begin
            next_dev_mngmt_state = STATE_AR_REQ_PENDING;
          end
        end else begin
          next_dev_mngmt_state = STATE_AR_REQ_PENDING;
        end

      STATE_AR_REQ_THROTTLE:
        if (biu_last_load_leaving_or_drop_dc3) begin
          next_dev_mngmt_state = STATE_IDLE;
        end else if ((data_fwd_dc3_i || biu_load_leaving_dc3) && dr_last_beat_dev) begin
          next_dev_mngmt_state = STATE_AR_REQ_PENDING;
        end else begin
          next_dev_mngmt_state = STATE_AR_REQ_THROTTLE;
        end

      STATE_DR_WAIT_LAST:
        if (biu_cc_fail_or_flush_dc3_i ||
            ((data_fwd_dc3_i || biu_load_leaving_dc3) && dc3_trans_last_beat_i)) begin
          next_dev_mngmt_state = STATE_IDLE;
        end else begin
          next_dev_mngmt_state = STATE_DR_WAIT_LAST;
        end

      default: begin
        next_dev_mngmt_state = {STATE_W{1'bx}};
      end
    endcase
  end

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      dev_mngmt_state <= STATE_IDLE;
    end else begin
      dev_mngmt_state <= next_dev_mngmt_state;
    end

  //-----------------------------------------------------------------------------
  // Decode states
  //-----------------------------------------------------------------------------

  assign dev_mngmt_state_idle            = (dev_mngmt_state == STATE_IDLE);
  assign dev_mngmt_state_ar_req_pending  = (dev_mngmt_state == STATE_AR_REQ_PENDING);

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign dev_idle_o   = dev_mngmt_state_idle;
  assign dev_active_o = dev_mngmt_state_ar_req_pending;
  assign dev_req_o    = ((dev_mngmt_state_idle            &
                          dcu_biu_req_dc3_i               &
                          `CA53_MEM_DEVICE(dcu_attrs_dc3_i)) |
                         dev_mngmt_state_ar_req_pending       ) &
                        (|rd_buff_dev_available                 );
  assign dev_addr_o   = ~dev_mngmt_state_idle ? {ar_addr_pend_dev[5:3], 3'b000} :
                        // Align the device NEON accesses to qword size
                        dcu_neon_access_dc3_i ? {biu_load_pa_dc3_i[5:4], 4'h0}  :
                        // Keep the alignment for the non-NEON device accesses
                                                biu_load_pa_dc3_i[5:0];
  assign dev_size_o   = ar_size_dev;
  assign dev_length_o = ar_len_dev;

`ifdef ARM_ASSERT_ON
  // ----------------------------------------------------------------------------
  // ARMAUTO assertions
  // ----------------------------------------------------------------------------

  /* ARMAUTO_X */
  assert_never_unknown            #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: rd_buff_dev_available_en")
  u_ovl_x_rd_buff_dev_available_en (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (rd_buff_dev_available_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: biu_ar_ready_dev_i")
  u_ovl_x_ar_done_dev   (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (biu_ar_ready_dev_i));

  assert_never_unknown      #(`OVL_FATAL, `CA53_BIU_DCU_NC_ID_NUM, `OVL_ASSERT, "Register enable x-check: ar_curr_len_dev_en")
  u_ovl_x_ar_curr_len_dev_en (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (ar_curr_len_dev_en));

  assert_never_unknown    #(`OVL_FATAL, `CA53_BIU_DCU_NC_ID_NUM, `OVL_ASSERT, "Register enable x-check: dev_id_alloc_req")
  u_ovl_x_dev_id_alloc_req (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (dev_id_alloc_req));

  //-----------------------------------------------------------------------------
  // Other assertions
  //-----------------------------------------------------------------------------

  assert_never_unknown   #(`OVL_FATAL, 1, `OVL_ASSERT, "dev_req_o must never be unknown")
  u_ovl_devsplit_mngmt_1  (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (dev_req_o));

  assert_always          #(`OVL_FATAL, `OVL_ASSERT, "rd_buff_dev_available must not be higher than max number of the read buffers")
  u_ovl_devsplit_mngmt_2  (.clk       (clk),
                           .reset_n   (reset_n),
                           .test_expr ((rd_buff_dev_available <= `CA53_BIU_RBUFS_NUM_W_INC'h`CA53_BIU_RBUFS_NUM)));

  assert_never_unknown   #(`OVL_FATAL, `CA53_BIU_RBUFS_NUM_W+1, `OVL_ASSERT, "next_rd_buff_dev_available must never be unknown")
  u_ovl_devsplit_mngmt_3  (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (next_rd_buff_dev_available));

  assert_never_unknown   #(`OVL_FATAL, 1, `OVL_ASSERT, "dev_mngmt_state_idle must never be unknown")
  u_ovl_devsplit_mngmt_4  (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (dev_mngmt_state_idle));

  assert_never_unknown   #(`OVL_FATAL, 1, `OVL_ASSERT, "dev_mngmt_state_ar_req_pending must never be unknown")
  u_ovl_devsplit_mngmt_5  (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (dev_mngmt_state_ar_req_pending));

  assert_never_unknown   #(`OVL_FATAL, 1, `OVL_ASSERT, "ar_last_dev must not be unknown when biu_ar_ready_dev_i is asserted")
  u_ovl_devsplit_mngmt_6  (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (biu_ar_ready_dev_i),
                           .test_expr (ar_last_dev));

  assert_always          #(`OVL_FATAL, `OVL_ASSERT, "Only some dev_mngmt_state states are valid")
  u_ovl_devsplit_mngmt_7  (.clk       (clk),
                           .reset_n   (reset_n),
                           .test_expr ((dev_mngmt_state == STATE_IDLE)            ||
                                       (dev_mngmt_state == STATE_AR_REQ_PENDING)  ||
                                       (dev_mngmt_state == STATE_AR_REQ_THROTTLE) ||
                                       (dev_mngmt_state == STATE_DR_WAIT_LAST)      ));

  assert_implication     #(`OVL_FATAL, `OVL_ASSERT, "rd_buff_dev_available must be equal to the max number of the read buffers when there is no outstanding device split transaction")
  u_ovl_devsplit_mngmt_8  (.clk             (clk),
                           .reset_n         (reset_n),
                           .antecedent_expr (~|dev_id_order_bits_valid),
                           .consequent_expr ((rd_buff_dev_available == `CA53_BIU_RBUFS_NUM_W_INC'h`CA53_BIU_RBUFS_NUM)));

  assert_implication     #(`OVL_FATAL, `OVL_ASSERT, "rd_buff_dev_available must be equal to the max number of the read buffers when there is no outstanding device split transaction")
  u_ovl_devsplit_mngmt_9  (.clk             (clk),
                           .reset_n         (reset_n),
                           .antecedent_expr ((rd_buff_dev_available == `CA53_BIU_RBUFS_NUM_W_INC'h`CA53_BIU_RBUFS_NUM)),
                           .consequent_expr (~|dev_id_order_bits_valid));

`endif

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53_dcu_biu_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53biu_defs.v"
`undef CA53_UNDEFINE

endmodule // ca53biu_devsplit_mngmt

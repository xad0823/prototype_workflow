//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
// (C) COPYRIGHT 2011-2016 ARM Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
// Checked In :  2016-02-09 14:22:09 +0000 (Tue, 09 Feb 2016)
// Revision : 206584
//
// Release Information : PL405-r3p0-01rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// File: adb400_r3_vn_fifo.v
//-----------------------------------------------------------------------------
// Purpose : A FIFO for a VN - deals with token procurement and use, and
//           indicates the highest QoS value in the FIFO as well as the highest
//           QoS value of an un-tokened entry in the FIFO. Output is a register
//           but if the FIFO is completely empty and a token is available
//           having been prefetched it can act in passthrough mode, storing
//           the transfer if it doesn't get handshaked.
//-----------------------------------------------------------------------------

module adb400_r3_vn_fifo
  #(parameter
    FIFO_WIDTH = 40,
    FIFO_DEPTH = 4,
    QOS_WIDTH  = 4,
    QOS_PRESENT = 0 // set to < 0 to remove QOS handling
  )
  (
    input  wire                  aclk,
    input  wire                  aresetn,

    input  wire                  valid_src,
    input  wire [FIFO_WIDTH-1:0] payld_src,
    input  wire [((QOS_PRESENT>0)?3:0):0] qv_src, 
    input  wire                  promotion_qv_update,
    input  wire [((QOS_PRESENT>0)?3:0):0] promotion_qv,

    output wire                  valid_dst,
    input  wire                  ready_dst,
    output wire [FIFO_WIDTH-1:0] payld_dst,
    output wire [((QOS_PRESENT>0)?3:0):0] max_qv,

    output wire                  tkn_req,
    input  wire                  tkn_gnt,
    output wire [((QOS_PRESENT>0)?3:0):0]  tkn_qv,
    input  wire                  tkn_prealloc,

    output wire                  emptyn
  );

  //---------------------------------------------------------------------------
  // The VN FIFO works by putting all transfers into a FIFO, unless the FIFO is
  // already empty, there is a token available, and it can handshake downstream
  // immediately. At the same time, the QoS value from the transfer is put into
  // the token QoS FIFO. All entries already in the token QoS FIFO have their
  // QoS value updated with the new value if the new value is higher, and it
  // gets an entry in the token QoS FIFO.
  //
  // A count is kept of the number of tokens received and not yet used. This
  // counter has an offset of 1 so that if a prealloc token is used the
  // decrement cannot cause it to go below 0. A transfer is allowed when the 
  // counter value is >1 or ==1, when there is a prealloc token, or when the
  // transfer needs no token.
  // - when preallocate is used the range of values is [DEPTH+1:0]
  // - when preallocate is not used the range of values id [DEPTH+1:1]
  //
  // A separate count is kept of the number of transfers that need a token that
  // have been received and not yet sent downstream. This also has an offset of
  // 1 so that it can be directly compared to the unused token counter.Whenever
  // the two counters are not equal a token must be fetched.
  //---------------------------------------------------------------------------

`include "adb400_r3_functions.v"
 
  localparam FIFO_DEPTH_INT       = FIFO_DEPTH - 1;

  // The offset of 1 of the unused token counter requires the +1 here
  localparam UNUSED_TKN_CNT_WIDTH = clogb2(FIFO_DEPTH+1);
  localparam UNUSED_TKN_CNT_WIDTH_EQ_0 = {UNUSED_TKN_CNT_WIDTH{1'b0}};
  localparam UNUSED_TKN_CNT_WIDTH_EQ_1 = {{(UNUSED_TKN_CNT_WIDTH-1){1'b0}},1'b1};
  localparam UNUSED_TKN_CNT_WIDTH_EQ_2 = ((UNUSED_TKN_CNT_WIDTH==2) ? 2'b10 : {{(UNUSED_TKN_CNT_WIDTH-2){1'b0}},2'b10});


  // Track the occupancy of the payload FIFO
  wire payld_fifo_empty;

  // Is there a token available for use, allocated or not.
//  reg  unused_tkn_avail_q;
  wire  unused_tkn_avail;

  // If a feedthrough is possible
//  wire feedthrough_possible = (payld_fifo_empty & unused_tkn_avail_q);
  wire feedthrough_possible = (payld_fifo_empty & unused_tkn_avail);

  // Can send when what is on the output is when there is a token.
  assign valid_dst = (
                      (valid_src & feedthrough_possible) |
//                      (~payld_fifo_empty & (unused_tkn_avail_q))
                      (~payld_fifo_empty & unused_tkn_avail)
                     );

   // Only feed through when we could use that feedthrough
  wire [FIFO_WIDTH-1:0] payld_fifo_pop_data;

  assign payld_dst = payld_fifo_empty ? payld_src : payld_fifo_pop_data;

  //-----------------------------------------------------------------------------
  // The core, payload FIFO
  //-----------------------------------------------------------------------------

  // When things enter and leave the FIFO
  wire payld_fifo_push = // Something needs sending somewhere
                         valid_src &
                         // It doesn't go straight out
                         ~(feedthrough_possible & ready_dst);

  wire payld_fifo_pop = // There is something to pop
                        ~payld_fifo_empty &
                        // Something gets sent
                         (valid_dst & ready_dst);


  adb400_r3_fifo_opreg
    #(
      .FIFO_WIDTH (FIFO_WIDTH),
      .FIFO_DEPTH (FIFO_DEPTH)
    )
  u_payld_fifo
    (
      .aclk        (aclk),
      .aresetn     (aresetn),
      
      .push_i      (payld_fifo_push),
      .pop_i       (payld_fifo_pop),
      
      .push_data_i (payld_src),
      .pop_data_o  (payld_fifo_pop_data),
      
      .empty_o     (payld_fifo_empty)
    );


  //-----------------------------------------------------------------------------
  // Token accounting
  //-----------------------------------------------------------------------------

  // Count unused tokens (including a prealloc)
  reg  [UNUSED_TKN_CNT_WIDTH-1:0] unused_tkn_count_q;
  // If a token is received, increment the unused_token_count
  wire                            unused_tkn_count_inc = (tkn_req & tkn_gnt);
  // If it was a token-needing transfer, decrement the token counter
  wire                            unused_tkn_count_dec = (valid_dst & ready_dst);
  wire                            unused_tkn_count_ovrflw;
  wire [UNUSED_TKN_CNT_WIDTH-1:0] unused_tkn_count_p1;
// ACS_off UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING constant is written as 1'b1 to guide synthesis to an incrementer/decrementer
  assign {unused_tkn_count_ovrflw,unused_tkn_count_p1} = (unused_tkn_count_q + 1'b1);
// ACS_off UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING constant is written as 1'b1 to guide synthesis to an incrementer/decrementer
  wire [UNUSED_TKN_CNT_WIDTH-1:0] unused_tkn_count_m1  = (unused_tkn_count_q - 1'b1);

  reg                             unused_tkn_count_ez_q;
  reg                             unused_tkn_count_ez_nxt;
  reg                             unused_tkn_count_eo_q;
  reg                             unused_tkn_count_eo_nxt;

  reg  [UNUSED_TKN_CNT_WIDTH-1:0] unused_tkn_count_nxt;
  wire                            unused_tkn_count_upd_en = (
                                                             unused_tkn_count_inc ^
                                                             unused_tkn_count_dec
                                                            );

  always @*
    begin : p_unused_tkn_count_nxt
      case ({unused_tkn_count_inc,unused_tkn_count_dec})
        2'b00,
        2'b11:
          begin
            unused_tkn_count_nxt    = unused_tkn_count_q;
            unused_tkn_count_ez_nxt = unused_tkn_count_ez_q;
            unused_tkn_count_eo_nxt = unused_tkn_count_eo_q;
          end
        2'b01:
          begin
            unused_tkn_count_nxt    = unused_tkn_count_m1;
            unused_tkn_count_ez_nxt = unused_tkn_count_eo_q;
            unused_tkn_count_eo_nxt = (unused_tkn_count_q == UNUSED_TKN_CNT_WIDTH_EQ_2);
          end
        2'b10:
          begin
            unused_tkn_count_nxt    = unused_tkn_count_p1;
            unused_tkn_count_ez_nxt = 1'b0;
            unused_tkn_count_eo_nxt = unused_tkn_count_ez_q;
          end
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
        default:
          begin
// ACS_off start UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
            unused_tkn_count_nxt    = {UNUSED_TKN_CNT_WIDTH{1'bx}};
            unused_tkn_count_ez_nxt = 1'bx;
            unused_tkn_count_eo_nxt = 1'bx;
// ACS_off end UNREACHABLE_DEFAULT_STATEMENT
          end
      endcase
    end

  always @(posedge aclk or negedge aresetn)
    begin : p_unused_tkn_count_q
      if (! aresetn)
        begin
          unused_tkn_count_q    <= {{(UNUSED_TKN_CNT_WIDTH-1){1'b0}},1'b1};
          unused_tkn_count_ez_q <= 1'b0;
          unused_tkn_count_eo_q <= 1'b1;
        end
      else if (unused_tkn_count_upd_en)
        begin
          unused_tkn_count_q    <= unused_tkn_count_nxt;
          unused_tkn_count_ez_q <= unused_tkn_count_ez_nxt;
          unused_tkn_count_eo_q <= unused_tkn_count_eo_nxt;
        end
    end

  // Is there a token available for use, allocated or not.
  assign unused_tkn_avail = ~(unused_tkn_count_ez_q | (unused_tkn_count_eo_q & ~tkn_prealloc));


  // Count deficient tokens (including a prealloc)
  reg  [UNUSED_TKN_CNT_WIDTH-1:0] deficient_tkn_count_q;
  // If a token is received, increment the deficient_token_count
  wire                            deficient_tkn_count_inc = (valid_src);
  // If it was a token-needing transfer, decrement the token counter
  wire                            deficient_tkn_count_dec = (tkn_req & tkn_gnt);
  wire                            deficient_tkn_count_ovrflw;
  wire [UNUSED_TKN_CNT_WIDTH-1:0] deficient_tkn_count_p1;
// ACS_off UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING constant is written as 1'b1 to guide synthesis to an incrementer/decrementer
  assign {deficient_tkn_count_ovrflw,deficient_tkn_count_p1} = (deficient_tkn_count_q + 1'b1);
// ACS_off UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING constant is written as 1'b1 to guide synthesis to an incrementer/decrementer
  wire [UNUSED_TKN_CNT_WIDTH-1:0] deficient_tkn_count_m1  = (deficient_tkn_count_q - 1'b1);

  reg  [UNUSED_TKN_CNT_WIDTH-1:0] deficient_tkn_count_nxt;
  wire                            deficient_tkn_count_upd_en = (
                                                             deficient_tkn_count_inc ^
                                                             deficient_tkn_count_dec
                                                            );
  reg                             deficient_tkn_count_eq_0_q;
  wire                            deficient_tkn_count_eq_0_nxt = ({UNUSED_TKN_CNT_WIDTH{1'b0}} == deficient_tkn_count_nxt);

  always @*
    begin : p_deficient_tkn_count_nxt
      case ({deficient_tkn_count_inc,deficient_tkn_count_dec})
        2'b00,
        2'b11:
          deficient_tkn_count_nxt = deficient_tkn_count_q;
        2'b01:
          deficient_tkn_count_nxt = deficient_tkn_count_m1;
        2'b10:
          deficient_tkn_count_nxt = deficient_tkn_count_p1;
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
        default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
          deficient_tkn_count_nxt = {UNUSED_TKN_CNT_WIDTH{1'bx}};
      endcase
    end

  always @(posedge aclk or negedge aresetn)
    begin : p_deficient_tkn_count_q
      if (! aresetn)
        begin
          deficient_tkn_count_q      <= {UNUSED_TKN_CNT_WIDTH{1'b0}};
          deficient_tkn_count_eq_0_q <= 1'b1;
        end
      else if (deficient_tkn_count_upd_en)
        begin
          deficient_tkn_count_q      <= deficient_tkn_count_nxt;
          deficient_tkn_count_eq_0_q <= deficient_tkn_count_eq_0_nxt;
        end
    end

  // A token is needed if there is something in the FIFO needing one or one is arriving from upstream
  assign tkn_req = (~deficient_tkn_count_eq_0_q | valid_src);

  //-----------------------------------------------------------------------------
  // Track the QVs required for arbitration and token requests
  //-----------------------------------------------------------------------------

  generate

// ACS_off UNEQUAL_WIDTH_REL_ARGS Inequality is only in parameter and constant
    if (QOS_PRESENT<=0)
      begin : g_no_axqos

        assign max_qv = 1'b0;
        assign tkn_qv = 1'b0;

      end
    else
      begin : g_has_axqos

        //-----------------------------------------------------------------------------
        // Track the promotion_qv
        //-----------------------------------------------------------------------------
  
        // Update any time the source updates
        reg  [3:0] promotion_qv_q;
        always @(posedge aclk or negedge aresetn)
          begin : p_promotion_qv_q
            if (! aresetn)
              promotion_qv_q <= {4{1'b0}};
            else if (promotion_qv_update)
              promotion_qv_q <= promotion_qv;
          end

        //-----------------------------------------------------------------------------
        // The arbitration QV
        //-----------------------------------------------------------------------------

        // The arbitration QV is the highest of all QVs of all transactions
        // that are still in the FIFO.
        //
        // - Push on arrival of any transaction
        // - Pop on departure of any transaction
        // - Update all entries on promotion

        wire [3:0] arbqv_fifo_pop_data;
        wire arbqv_fifo_empty;

        // Updated for every transfer received when there is something in the FIFO
        wire arbqv_fifo_update = valid_src & ~arbqv_fifo_empty;

        adb400_r3_qv_update_fifo
          #(
            .FIFO_DEPTH (FIFO_DEPTH),
            .FIFO_WIDTH (4)
          )
        u_arbqv_fifo
          (
            .aclk        (aclk),
            .aresetn     (aresetn),
            
            .push_i      (payld_fifo_push),
            .pop_i       (payld_fifo_pop),
            .update_i    (arbqv_fifo_update),
            
            .push_data_i (qv_src),
            .pop_data_o  (arbqv_fifo_pop_data),
            
            .empty_o     (arbqv_fifo_empty)
          );

        assign max_qv = (((promotion_qv_q > arbqv_fifo_pop_data) || arbqv_fifo_empty) ?
                         promotion_qv_q :
                         arbqv_fifo_pop_data);

        //-----------------------------------------------------------------------------
        // The token QV
        //-----------------------------------------------------------------------------

        // The token QV is the highest of all QVs of transactions that
        // need, but do not have, a token.
        //
        // - Push on arrival of transaction
        // - Pop on grant of a token
        // - Update all entries on promotion

        // The qv_update_fifo copes with simultaneous push and pop when empty.
        // while empty it puts the last value *really* written on the pop_data
        // output.
        //
        // Care must be taken to use a simultaneous pop for the cases where a
        // real push is not desired.
        //
        // The case of a transfer that requests and is granted its token on its
        // ingress cycle is deliberately not avoided as that would make the 
        // token handshake signals a part of the push expression, which the 
        // simultaneous push and pop when empty handling was added to avoid.
        wire tknqv_fifo_push = // A transfer is received and ...
                               valid_src &
                               // ... there is not a preallocated one available
                               ~(tkn_prealloc & deficient_tkn_count_eq_0_q);

        // The FIFO is popped when a token is received.
        wire tknqv_fifo_pop = (tkn_req & tkn_gnt);

        wire tknqv_fifo_empty;
        wire [3:0] tknqv_fifo_pop_data;

        wire tknqv_fifo_update = valid_src & ~tknqv_fifo_empty;

        adb400_r3_qv_update_fifo
          #(
            .FIFO_DEPTH (FIFO_DEPTH),
            .FIFO_WIDTH (4)
          )
        u_tknqv_fifo
          (
            .aclk        (aclk),
            .aresetn     (aresetn),
            
            .push_i      (tknqv_fifo_push),
            .pop_i       (tknqv_fifo_pop),
            .update_i    (tknqv_fifo_update),
            
            .push_data_i (qv_src),
            .pop_data_o  (tknqv_fifo_pop_data),
            
            .empty_o     (tknqv_fifo_empty)
          );

        //-----------------------------------------------------------------------------
        // Find the highest QV of all non-FIFO sources and update the registered value
        // it either it has increased or the token request is non-sticky.
        //
        // When replenishing a preallocated token (i.e. nothing in the FIFO) the QV
        // of the last transfer should be used instead of the FIFO value as that is,
        // nominally, the transaction that the token is being fetched for. If there is
        // something in the FIFO, the value in the last_qv register will also be in the
        // FIFO so its inclusion will not affect the output value. Thus it can always
        // be included if prealloc is in use, regardless of what is being fetched.
        //
        // All components must be monotonic while the token request is sticky.
        // tknqv_fifo_pop_data is inherently monotonic so to minimise delay, all the 
        // other components are combined into a monotonicised register.
        //-----------------------------------------------------------------------------

        //-----------------------------------------------------------------------------
        // Track the last_qv
        //-----------------------------------------------------------------------------

        // Update any time the source updates
        reg  [3:0] last_qv_q;
        wire last_qv_upd_en = valid_src & tkn_prealloc;
        always @(posedge aclk or negedge aresetn)
          begin : p_last_qv_q
            if (! aresetn)
              last_qv_q <= {4{1'b0}};
            else if (last_qv_upd_en)
              last_qv_q <= qv_src;
          end

        //-----------------------------------------------------------------------------
        // Calculate the highest non-FIFO part of the QV
        //-----------------------------------------------------------------------------

        // Track stickiness of the token request to ensure the QV is monotonically increasing
        wire tkn_sticky_nxt = tkn_req & ~tkn_gnt;

        wire [3:0] promotion_qv_mux = (promotion_qv_update ?
                                       promotion_qv :
                                       promotion_qv_q);
        wire [3:0] last_qv_mux      = (valid_src ?
                                       qv_src :
                                       last_qv_q);

        reg  [3:0] tknqv_non_fifo_q;
        wire [3:0] tknqv_non_fifo_nxt = (((promotion_qv_mux > last_qv_mux) || ~tkn_prealloc) ?
                                         promotion_qv_mux :
                                         last_qv_mux);
        wire       tknqv_non_fifo_increased = (tknqv_non_fifo_nxt > tknqv_non_fifo_q);
        wire       tknqv_non_fifo_upd_en = (~tkn_sticky_nxt | tknqv_non_fifo_increased);

        always @(posedge aclk or negedge aresetn)
          begin : p_tknqv_non_fifo_q
            if (! aresetn)
              tknqv_non_fifo_q <= {4{1'b0}};
            else if (tknqv_non_fifo_upd_en)
// ACS_off CDC_END Where this register exists, it is an expected CDC endpoint.
              tknqv_non_fifo_q <= tknqv_non_fifo_nxt;
          end

        //-----------------------------------------------------------------------------
        // Find the highest QV of the tknqv_fifo head and the tknqv_non_fifo_q
        //-----------------------------------------------------------------------------
       assign tkn_qv = (((tknqv_non_fifo_q > tknqv_fifo_pop_data) || tknqv_fifo_empty) ?
                         tknqv_non_fifo_q :
                         tknqv_fifo_pop_data);


      end // g_qv
  endgenerate

  assign emptyn = ~payld_fifo_empty;

endmodule

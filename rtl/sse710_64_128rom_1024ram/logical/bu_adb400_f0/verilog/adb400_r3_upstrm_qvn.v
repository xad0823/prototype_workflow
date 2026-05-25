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
// File: adb400_r3_upstrm_qvn.v
//-----------------------------------------------------------------------------
// Purpose : The upstream half of QVN handling
//-----------------------------------------------------------------------------

module adb400_r3_upstrm_qvn
  #(parameter
      DEPTH            = 8,
      VN               = 2,
      QOS_PRESENT      = 0
  )
  (
    // Sampled-at-reset config signals (already staticised above here)
    input  wire [VN-1:0]          vx_prealloc_i,
    input  wire [(4*VN)-1:0]      vx_id_i,

    // Global signals
    input  wire                   aclk,
    input  wire                   aresetn,

    // The channel handshake and barrier indication
    input  wire                   valid_i,
    input  wire                   ready_i,
    input  wire                   bar_i,
    input  wire [3:0]             vnet_i, 
    output wire [VN-1:0]          vnpid_1h_o,

    // QVN specific signalling

    // Token request
    input  wire [VN-1:0]          vxvalid,
    output wire [VN-1:0]          vxready,
    input  wire [((QOS_PRESENT>0)?((4*VN)-1):0):0] vxqos,

    // Token return
    input  wire tkn_return,
    input  wire [(VN*clogb2(DEPTH))-1:0] tkn_return_count,

    // Promotion QV
    output wire [((QOS_PRESENT>0)?((4*VN)-1):0):0] promotion_qv,
    output wire                   promote,
    input  wire                   promote_ack
  );

  // This module manages tokens and controls ingress into the async crossing
  // FIFO upstream half.
  //
  // Token grant can occur when (avail_tokens>1) or when 
  // (avail_tokens==1) and no prealloc was used. 

`include "adb400_r3_functions.v"

  // Must be sized to DEPTH+1 as in the prealloc case, it is possible for
  // the prealloc token to be used and returned by downstream before any
  // tokens have been requested.
  localparam DEPTH_P1            = DEPTH + 1;
  localparam TKN_COUNT_WIDTH     = clogb2(DEPTH);
  localparam TKN_COUNT_P1_WIDTH  = clogb2(DEPTH_P1);
  localparam [TKN_COUNT_P1_WIDTH-1:0] TOKENS_AVAIL_INIT_VAL  = DEPTH[TKN_COUNT_P1_WIDTH-1:0];


  genvar i,j;

  //---------------------------------------------------------------------------
  // Track when SAR signals can be used
  //---------------------------------------------------------------------------
  
  reg  [1:0] sar_done_q;
  wire [1:0] sar_done_nxt = {1'b0,sar_done_q[1]};
  wire       sar_done_upd_en = (|(sar_done_q));

  always @(posedge aclk or negedge aresetn)
    begin : p_sar_done_vec
      if (! aresetn)
        sar_done_q <= 2'b10;
      else if (sar_done_upd_en)
        sar_done_q <= sar_done_nxt;
    end 
  wire sar_not_done  = sar_done_q[1];
  wire sar_just_done = sar_done_q[0];

  // Track tokens that have been granted, and those that have been used
  // NOTE:
  //       tokens_avail is initialised to DEPTH and there are no tokens
  //       available to grant when it is <= vx_prealloc_i.
  //       - If prealloc is not used then DEPTH tokens can be granted
  //         and the range of values for the counter is [DEPTH:0].
  //       - If prealloc is used then DEPTH-1 tokens can be granted,
  //         but the prealloc'ed one could be used and returned before
  //         any is requested, so the range of values for the counter
  //         is [DEPTH+1:1].
  //       - Thus the counter must be able to handle a range of [DEPTH+1:0].


  reg  [TKN_COUNT_P1_WIDTH-1:0] tokens_avail_q    [VN-1:0];
  wire [TKN_COUNT_P1_WIDTH-1:0] tokens_avail_m1   [VN-1:0];
  wire [TKN_COUNT_P1_WIDTH-1:0] tokens_avail_pret [VN-1:0];
  wire [TKN_COUNT_P1_WIDTH-1:0] tokens_avail_pret_m1 [VN-1:0];
  reg  [VN-1:0]                 tokens_avail_now_q;
  wire [VN-1:0]                 tokens_avail_now_nxt;
  wire [TKN_COUNT_WIDTH-1:0]    tokens_return_count_vn [VN-1:0];
  wire [VN-1:0]                 tokens_avail_dec;
  reg  [TKN_COUNT_P1_WIDTH-1:0] tokens_avail_nxt      [VN-1:0];
  wire [VN-1:0]                 tokens_avail_upd_en;
  wire [VN-1:0]                 tokens_avail_eq_0_nxt;
  wire [VN-1:0]                 tokens_avail_eq_1_nxt;

  // When a token is given upstream
  wire [VN-1:0] vx_hndshk = vxvalid & vxready;

  // When to update the counters - ensure it is sampled just after SAR is done
  assign tokens_avail_upd_en = (tokens_avail_dec | {VN{tkn_return}} | {VN{sar_just_done}});

  generate
    for (i=0; i<VN ; i=i+1)
      begin : g_i_per_vn
        assign vnpid_1h_o[i] = (vnet_i == vx_id_i[(4*i)+:4]);

        //
        // Track tokens available for issue upstream
        //
        wire tokens_avail_pret_ovrflw;
// ACS_off UNEQUAL_WIDTH_OP_ARGS lhs of addition uses a false-0 of 1 to so the width to represent it can end up being larger than the rhs argument
        assign {tokens_avail_pret_ovrflw,tokens_avail_pret[i]} = (tokens_avail_q[i] + tokens_return_count_vn[i]);
// ACS_off UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING constant is written as 1'b1 to guide synthesis to an incrementer/decrementer
        assign tokens_avail_m1[i] = (tokens_avail_q[i] - 1'b1);
        wire tokens_avail_pret_m1_ovrflw;
// ACS_off UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING constant is written as 1'b1 to guide synthesis to an incrementer/decrementer
        assign {tokens_avail_pret_m1_ovrflw,tokens_avail_pret_m1[i]} = (tokens_avail_q[i] + tokens_return_count_vn[i] - 1'b1);

        always @*
          begin : p_tokens_avail_nxt
            case ({tkn_return,tokens_avail_dec[i]})
              2'b00:
                tokens_avail_nxt[i] = tokens_avail_q[i];
              2'b01:
                tokens_avail_nxt[i] = tokens_avail_m1[i];
              2'b10:
                tokens_avail_nxt[i] = tokens_avail_pret[i];
              2'b11:
                tokens_avail_nxt[i] = tokens_avail_pret_m1[i];

// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
              default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
                tokens_avail_nxt[i]  = {TKN_COUNT_P1_WIDTH{1'bx}};
            endcase
          end

        // How many tokens are being returned from downstream
        assign tokens_return_count_vn[i] = tkn_return ?
                                     tkn_return_count[(i*TKN_COUNT_WIDTH)+:TKN_COUNT_WIDTH] :
                                     {TKN_COUNT_WIDTH{1'b0}};

        assign tokens_avail_dec[i] = vx_hndshk[i];

        assign tokens_avail_eq_0_nxt[i]   = ({TKN_COUNT_P1_WIDTH{1'b0}}             == tokens_avail_nxt[i]);
        assign tokens_avail_eq_1_nxt[i]   = ({{(TKN_COUNT_P1_WIDTH-1){1'b0}},1'b1}  == tokens_avail_nxt[i]);
        // Prevent tokens being available withe reset-sampling
        assign tokens_avail_now_nxt[i]    = ~(sar_not_done |
                                              tokens_avail_eq_0_nxt[i] |
                                              (tokens_avail_eq_1_nxt[i] & vx_prealloc_i[i])
                                              );

        // Update the counters
        always @(posedge aclk or negedge aresetn)
          begin : p_tokens_avail
            if (! aresetn)
              begin
                tokens_avail_q[i]        <= TOKENS_AVAIL_INIT_VAL;
                tokens_avail_now_q[i]    <= 1'b0;
              end
            else if (tokens_avail_upd_en[i])
              begin
                tokens_avail_q[i]        <= tokens_avail_nxt[i];
                tokens_avail_now_q[i]    <= tokens_avail_now_nxt[i];
              end
          end

        // Always give a token if there is one available
        assign vxready[i] = tokens_avail_now_q[i];

      end
  endgenerate

  generate
// ACS_off UNEQUAL_WIDTH_REL_ARGS Inequality is only in parameter and constant
    if (QOS_PRESENT>0)
      begin : g_has_promo_qv

        reg  promote_nonzero_lst_q;
        wire promote_nonzero_lst_nxt = (|(promotion_qv));
        wire promote_nonzero_lst_upd_en = (promote & promote_ack);
        always @(posedge aclk or negedge aresetn)
          begin : p_promote_nonzero_lst_q
            if (! aresetn)
              promote_nonzero_lst_q <= 1'b0;
            else if (promote_nonzero_lst_upd_en)
              promote_nonzero_lst_q <= promote_nonzero_lst_nxt;
          end

        assign promote = ((|(vxvalid & ~vxready)) | promote_nonzero_lst_q);

        for (j=0; j<VN ; j=j+1)
          begin : g_j_promo_qv

            // Indicate a the promotion QV for a stalled token
            assign promotion_qv[(4*j)+:4] = (vxvalid[j] && !vxready[j]) ?
                                            vxqos[(4*j)+:4] :
                                            {4{1'b0}};
          end

      end
    else
      begin : g_no_promo_qv

        assign promotion_qv = 1'b0;
        assign promote = 1'b0;

      end

  endgenerate

endmodule

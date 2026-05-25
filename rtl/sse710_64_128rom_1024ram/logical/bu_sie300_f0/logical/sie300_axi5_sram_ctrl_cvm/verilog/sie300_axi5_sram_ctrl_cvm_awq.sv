//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2019 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//
//      Version Information
//
//      Checked In          : Tue Jul 16 16:12:54 2019 +0100
//
//      Revision            : 3fd92913
//
//      Release Information : CoreLink SIE-300 Generic Global Bundle r1p2-00rel0
//
//----------------------------------------------------------------------------

module sie300_axi5_sram_ctrl_cvm_awq
(
  input  wire logic                                           clk,
  input  wire logic                                           resetn,

  input  wire logic                                           awvalid,
  output      logic                                           awready,
  input  wire logic [12-1       :0]                           awid,
  input  wire logic [22-1     :0]                             awaddr,
  input  wire logic [7                        :0]             awlen,
  input  wire logic [2                        :0]             awsize,
  input  wire logic [1                        :0]             awburst,
  input  wire logic [3                        :0]             awqos,
  input  wire logic                                           awprot,
  input  wire logic                                           awlock,

  input  wire logic [22-1     :0]                             araddr,
  input  wire logic                                           arvalid,
  input  wire logic                                           arready,
  input  wire logic                                           bvalid,
  input  wire logic                                           bready,
  input  wire logic                                           wbeat_rdy,
  output      logic                                           raw_match_arb,
  output      logic                                           raw_match_stall,

  output      logic                                           awq_vld,
  input  wire logic                                           awq_rdy,
  output      logic [12-1       :0]                           awq_id,
  output      logic [22-1     :0]                             awq_addr,
  output      logic [7                        :0]             awq_len,
  output      logic [2                        :0]             awq_size,
  output      logic [1                        :0]             awq_burst,
  output      logic [3                        :0]             awq_qos,
  output      logic                                           awq_prot,
  output      logic                                           awq_lock,
  output      logic                                           awq_full,
  output      logic                                           awq_empty,

  input  wire logic                                           awready_bq,

  input  wire logic                                           bq_exfail,

  output      logic [2-1  :0]                                 awq_cnt,
  input  wire logic [2-1  :0]                                 wlast_cnt,
  input  wire logic                                           wq_empty,
  input  wire logic                                           ext_stall

);


  typedef struct packed {
    logic [12-1:0]                    id;
    logic [22-1:0]                    addr;
    logic [7                   :0]    len;
    logic [2                   :0]    size;
    logic [1                   :0]    burst;
    logic [3                   :0]    qos;
    logic                             prot;
    logic                             lock;
  } ax_fields_t;

  localparam AX_Q_WIDTH = $bits(ax_fields_t);

  typedef logic [2-1:0]                   aw_buf_t;

  ax_fields_t                                   awpayload_in, awq_payload_out;
  logic                                         awready_fifo;
  logic                                         awvalid_fifo;
  logic                                         raw_match_set;
  logic                                         raw_match_arb_clr;
  logic                                         raw_match_arb_reg;
  logic                                         raw_match_arb_next;
  logic                                         raw_match_stall_clr;
  logic                                         raw_match_stall_reg;
  logic                                         raw_match_stall_next;
  logic [2*AX_Q_WIDTH-1:0]                      peek_data;
  ax_fields_t [2-1:0]                           peek_data_struct;
  aw_buf_t                                      peek_data_vld;
  aw_buf_t                                      raw_match_unfold_set;
  aw_buf_t                                      raw_match_unfold_clr;
  aw_buf_t                                      early_bresp;
  aw_buf_t                                      early_bresp_snap;

  logic [22-1     :0]                           araddr_chk;
  logic                                         wr_exec_granted;
  logic                                         wr_exec_granted_r;
  logic                                         wr_exec_finished;
  logic                                         wr_exec_finished_r;
  logic                                         b_hs_done;
  logic                                         w_ahead;

  assign awpayload_in = {awid, awaddr, awlen, awsize, awburst, awqos, awprot, awlock};

  sie300_axi5_sram_ctrl_cvm_fifo  #(
    .WIDTH          ( AX_Q_WIDTH            ),
    .DEPTH          ( 2   ),
    .RDY_AT_DEPTH_1 ( 1                     ),
    .CNT_WIDTH      ( 2 ),
    .PEEK_LOGIC     ( 1                     )
  ) u_fifo (
    .clk            ( clk                   ),
    .resetn         ( resetn                ),
    .ingress_data   ( awpayload_in          ),
    .ingress_vld    ( awvalid_fifo          ),
    .ingress_rdy    ( awready_fifo          ),
    .egress_data    ( awq_payload_out       ),
    .egress_vld     ( awq_vld               ),
    .egress_rdy     ( awq_rdy               ),
    .level          ( awq_cnt               ),
    .empty          ( awq_empty             ),
    .full           ( awq_full              ),
    .fall_thru_en   ( 1'b0                  ),
    .peek_data_vld  ( peek_data_vld         ),
    .peek_data      ( peek_data             )
  );

  assign {awq_id, awq_addr, awq_len, awq_size, awq_burst, awq_qos, awq_prot, awq_lock} = awq_payload_out;


  assign awready        = ext_stall
                        ? awready_fifo & awready_bq & ~raw_match_stall & w_ahead
                        : awready_fifo & awready_bq & ~raw_match_stall;

  assign awvalid_fifo   = ext_stall
                        ? awvalid & awready_bq & ~raw_match_stall & w_ahead
                        : awvalid & awready_bq & ~raw_match_stall;

  assign w_ahead  = (awq_cnt <  wlast_cnt)
                  | (awq_empty & ~wq_empty);

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn) begin
      araddr_chk <= '0;
    end
    else if(arvalid & arready) begin
      araddr_chk <= araddr;
    end
  end

  assign peek_data_struct = peek_data;

  assign wr_exec_finished = awq_vld & awq_rdy;
  assign wr_exec_granted  = awq_vld & wbeat_rdy;
  assign b_hs_done        = bvalid  & bready;

  typedef logic [ $clog2(2)-1:0 ] ptr_t;

  ptr_t aw_ptr;
  ptr_t b_ptr;
  logic aw_gt_b;
  logic aw_lt_b;
  logic wrap_aw;
  logic wrap_b;

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn) begin
      aw_ptr  <= ptr_t'(1);
      b_ptr   <= ptr_t'(1);
    end
    else begin
      if (wr_exec_finished) begin
        if ((aw_ptr  == ptr_t'(2-1)) )begin
          aw_ptr  <= ptr_t'(0);
        end
        else begin
          aw_ptr  <= ptr_t'(aw_ptr + ptr_t'(1));
        end
      end
      if (b_hs_done) begin
        if ((b_ptr  == ptr_t'(2-1)) )begin
          b_ptr  <= ptr_t'(0);
        end
        else begin
          b_ptr   <= ptr_t'(b_ptr  + ptr_t'(1));
        end
      end
    end
  end

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn) begin
      wrap_aw <= 1'b0;
      wrap_b  <= 1'b0;
    end
    else begin
      case ( {  (b_hs_done        & (b_ptr  == ptr_t'(2-1)) ),
                (wr_exec_finished & (aw_ptr == ptr_t'(2-1)) )  } )
        2'b10:begin
                if (wrap_aw) begin
                  wrap_aw <= 1'b0;
                  wrap_b  <= 1'b0;
                end
                else begin
                  wrap_aw <= 1'b0;
                  wrap_b  <= 1'b1;
                end
              end
        2'b01:begin
                if (wrap_b) begin
                  wrap_aw <= 1'b0;
                  wrap_b  <= 1'b0;
                end
                else begin
                  wrap_aw <= 1'b1;
                  wrap_b  <= 1'b0;
                end
              end
        2'b00,
        2'b11:begin
                wrap_aw <= wrap_aw;
                wrap_b  <= wrap_b;
              end
        default: {wrap_aw, wrap_b} <= 'x;
      endcase
    end
  end

  assign aw_gt_b = ( (aw_ptr > b_ptr) & ~wrap_b ) | wrap_aw;
  assign aw_lt_b = ( (aw_ptr < b_ptr) & ~wrap_aw) | wrap_b;

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn) begin
      early_bresp <= '0;
    end
    else begin
      if (aw_lt_b) begin
        if (b_hs_done & ~bq_exfail & ~wr_exec_granted) begin
          early_bresp[b_ptr] <= 1'b1;
        end
        else if (b_hs_done & ~bq_exfail & wr_exec_granted) begin
            early_bresp[b_ptr]  <= 1'b1;
            early_bresp[aw_ptr] <= 1'b0;
        end
        else if (~(b_hs_done & ~bq_exfail) & wr_exec_granted) begin
          early_bresp[aw_ptr] <= 1'b0;
        end
      end
      else if (aw_gt_b) begin
        if (wr_exec_granted) begin
          early_bresp[aw_ptr] <= 1'b0;
        end
      end
      else begin
        if (wr_exec_granted) begin
          early_bresp[aw_ptr] <= 1'b0;
        end
        else if (b_hs_done & ~bq_exfail) begin
          early_bresp[b_ptr] <= 1'b1;
        end
      end
    end
  end

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn) begin
      early_bresp_snap <= '0;
    end
    else begin
      if (raw_match_set & ~wr_exec_granted) begin
        early_bresp_snap <= early_bresp;
      end
      else if (raw_match_set & wr_exec_granted) begin
        early_bresp_snap <= early_bresp;
        early_bresp_snap[aw_ptr] <= 1'b0;
      end
      else if (~raw_match_set & wr_exec_granted) begin
        early_bresp_snap[aw_ptr] <= 1'b0;
      end
    end
  end


  localparam IGNORE_LSB = 12;
  genvar j;
  generate
    for (j=0;j< 2;j=j+1) begin : g_raw
      assign raw_match_unfold_set[j]  = peek_data_vld[j]
                                      & early_bresp[j]
                                      & (   peek_data_struct[j].addr[22-1:IGNORE_LSB]
                                          ==                  araddr[22-1:IGNORE_LSB]);
      assign raw_match_unfold_clr[j]  = peek_data_vld[j]
                                      & early_bresp_snap[j]
                                      & (   peek_data_struct[j].addr[22-1:IGNORE_LSB]
                                          ==              araddr_chk[22-1:IGNORE_LSB]);

    end : g_raw
  endgenerate



  aw_buf_t aw_ptr_onehot;
  assign aw_ptr_onehot = aw_buf_t'(1 << aw_ptr);

  assign raw_match_set        = ~raw_match_stall_reg
                              & arvalid
                              & arready
                              & ( raw_match_unfold_set != aw_buf_t'(0) )
                              & ~(  (awq_len == 8'd0)
                                  & wr_exec_finished
                                  & wr_exec_granted
                                  & ( (raw_match_unfold_set & ~aw_ptr_onehot) == aw_buf_t'(0) ) );

  assign raw_match_arb_clr    = raw_match_arb_reg
                              & wr_exec_granted_r
                              & ( raw_match_unfold_clr == aw_buf_t'(0) );

  assign raw_match_stall_clr  = raw_match_stall_reg
                              & wr_exec_finished_r
                              & ( raw_match_unfold_clr == aw_buf_t'(0) );

  always_comb begin
    if (raw_match_set) begin
      raw_match_arb_next    = 1'b1;
    end
    else if (raw_match_arb_clr) begin
      raw_match_arb_next    = 1'b0;
    end
    else begin
      raw_match_arb_next    = raw_match_arb_reg;
    end
  end

  always_comb begin
    if (raw_match_set) begin
      raw_match_stall_next  = 1'b1;
    end
    else if (raw_match_stall_clr) begin
      raw_match_stall_next  = 1'b0;
    end
    else begin
      raw_match_stall_next  = raw_match_stall_reg;
    end
  end

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn) begin
      raw_match_arb_reg   <= 1'b0;
      raw_match_stall_reg <= 1'b0;
    end
    else begin
      raw_match_arb_reg   <= raw_match_arb_next;
      raw_match_stall_reg <= raw_match_stall_next;
    end
  end

  assign raw_match_stall  = raw_match_stall_reg;
  assign raw_match_arb    = raw_match_arb_reg;

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn) begin
      wr_exec_finished_r  <= 'b0;
      wr_exec_granted_r   <= 'b0;
    end
    else begin
      wr_exec_finished_r  <= wr_exec_finished;
      wr_exec_granted_r   <= wr_exec_granted;
    end
  end

endmodule



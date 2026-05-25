//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2017 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Sub-module of css600_catu
//
//----------------------------------------------------------------------------


module css600_catu_ds
#(
  parameter LEN_WIDTH   = 8,
  parameter RESP_WIDTH  = 2
)(
  input  wire                   clk,
  input  wire                   reset_n,
  input  wire                   rd_ds_select,
  input  wire                   wr_ds_select,
  input  wire [LEN_WIDTH-1:0]   arlen_s,
  input  wire                   arvalid_s,
  output wire                   arready_s,
  output wire [RESP_WIDTH-1:0]  rresp_s,
  output wire                   rlast_s,
  output wire                   rvalid_s,
  input  wire                   rready_s,
  input  wire                   awvalid_s,
  output wire                   awready_s,
  input  wire                   wlast_s,
  input  wire                   wvalid_s,
  output wire                   wready_s,
  output wire [RESP_WIDTH-1:0]  bresp_s,
  output wire                   bvalid_s,
  input  wire                   bready_s,
  input  wire                   arvalid_t,
  output wire                   arready_t,
  input  wire                   awvalid_t,
  output wire                   awready_t
);


localparam AXIBM_AW_READY_HIGH         = 1'b0;
localparam AXIBM_AW_READY_LOW          = 1'b1;

localparam AXIBM_W_READY_LOW           = 1'b0;
localparam AXIBM_W_READY_HIGH          = 1'b1;

localparam AXIBM_B_VALID_LOW           = 1'b0;
localparam AXIBM_B_VALID_HIGH          = 1'b1;

localparam AXIBM_AR_READY_HIGH         = 1'b0;
localparam AXIBM_AR_READY_LOW          = 1'b1;

localparam AXIBM_R_VALID_LOW           = 1'b0;
localparam AXIBM_R_VALID_HIGH          = 1'b1;

localparam AXIBM_RLAST_LOW             = 2'b00;
localparam AXIBM_RLAST_HIGH_HANDSHAKE  = 2'b01;
localparam AXIBM_RLAST_HIGH_NOT_READY  = 2'b10;


  wire [LEN_WIDTH-1:0]   arlen;
  wire                   arvalid;
  wire                   arready;
  wire                   rvalid;
  wire                   rready;
  wire                   awvalid;
  wire                   awready;
  wire                   wlast;
  wire                   wvalid;
  wire                   wready;
  wire                   bvalid;
  wire                   bready;

  reg                    aw_state;
  reg                    aw_state_nxt;
/* verilator lint_off UNOPTFLAT */
  reg                    i_awready;
/* verilator lint_on UNOPTFLAT */

  reg                    w_state;
  reg                    w_state_nxt;
/* verilator lint_off UNOPTFLAT */
  reg                    i_wready;
/* verilator lint_on UNOPTFLAT */

  reg                    b_state;
  reg                    b_state_nxt;
/* verilator lint_off UNOPTFLAT */
  reg                    i_bvalid;
/* verilator lint_on UNOPTFLAT */

  reg                    ar_state;
  reg                    ar_state_nxt;
  reg                    i_arready;
  wire                   artrans;
  reg                    r_state;
  reg                    r_state_nxt;
  reg                    i_rvalid;
  reg  [LEN_WIDTH-1:0]   reads_left;
  reg  [LEN_WIDTH-1:0]   reads_left_nxt;
  wire                   i_rlast;


  assign arlen     = arlen_s;
  assign arvalid   = rd_ds_select ? arvalid_t : arvalid_s;
  assign arready_s = rd_ds_select ? 1'b0 : arready;
  assign arready_t = rd_ds_select ? arready : 1'b0;

  assign rlast_s   = i_rlast;
  assign rresp_s   = 2'b11;
  assign rvalid_s  = rvalid;
  assign rready    = rready_s;

  assign awvalid   = wr_ds_select ? awvalid_t : awvalid_s;
  assign awready_s = wr_ds_select ? 1'b0 : awready;
  assign awready_t = wr_ds_select ? awready : 1'b0;

  assign wlast     = wlast_s;
  assign wvalid    = wvalid_s;
  assign wready_s  = wready;

  assign bresp_s   = 2'b11;
  assign bvalid_s  = bvalid;
  assign bready    = bready_s;


  assign awready   = i_awready;
  assign wready    = i_wready;
  assign bvalid    = i_bvalid;

  assign arready   = i_arready;
  assign artrans   = arvalid & i_arready;
  assign rvalid    = i_rvalid;

  assign i_rlast   = (reads_left == {LEN_WIDTH{1'b0}}) ? 1'b1 : 1'b0;


always @(awvalid or i_bvalid or bready or aw_state)
  begin : p_aw_state_comb
    case (aw_state)

       AXIBM_AW_READY_HIGH :
         begin
           i_awready = 1'b1;
           aw_state_nxt = awvalid ? AXIBM_AW_READY_LOW :
           AXIBM_AW_READY_HIGH;
         end

       AXIBM_AW_READY_LOW :
         begin
           i_awready = 1'b0;
           aw_state_nxt = (i_bvalid && bready) ? AXIBM_AW_READY_HIGH :
           AXIBM_AW_READY_LOW;
         end

      default : aw_state_nxt = AXIBM_AW_READY_HIGH;

    endcase
  end


always @(negedge reset_n or posedge clk)
  begin : p_aw_stateSeq
    if (!reset_n)
      aw_state <= AXIBM_AW_READY_HIGH;
    else
      aw_state <= aw_state_nxt;
  end


always @(i_awready or wvalid or wlast or i_bvalid or w_state)
  begin : p_w_state_comb
    case (w_state)

       AXIBM_W_READY_LOW :
         begin
           i_wready = 1'b0;
           w_state_nxt = (i_awready || i_bvalid) ? AXIBM_W_READY_LOW :
           AXIBM_W_READY_HIGH;
         end

       AXIBM_W_READY_HIGH :
         begin
           i_wready = 1'b1;
           w_state_nxt = (wlast && wvalid) ?  AXIBM_W_READY_LOW :
           AXIBM_W_READY_HIGH;
         end

      default : w_state_nxt = AXIBM_W_READY_LOW;

    endcase
  end


always @(negedge reset_n or posedge clk)
  begin : p_w_state_seq
    if (!reset_n)
      w_state  <= AXIBM_W_READY_LOW;
    else
      w_state  <= w_state_nxt;
  end


always @(wlast or i_wready or wvalid or bready or b_state)
  begin : p_b_state_comb
    case (b_state)

       AXIBM_B_VALID_LOW :
         begin
            i_bvalid = 1'b0;
            b_state_nxt = (wlast && i_wready && wvalid) ? AXIBM_B_VALID_HIGH :
            AXIBM_B_VALID_LOW;
         end

       AXIBM_B_VALID_HIGH :
         begin
           i_bvalid = 1'b1;
           b_state_nxt = (bready) ? AXIBM_B_VALID_LOW :
           AXIBM_B_VALID_HIGH;
         end

      default : b_state_nxt = AXIBM_B_VALID_LOW;

    endcase
  end


  always @(negedge reset_n or posedge clk)
    begin : p_b_stateSeq
      if (!reset_n)
        b_state  <= AXIBM_B_VALID_LOW;
      else
       b_state  <= b_state_nxt;
    end


always @(arvalid or rready or i_rlast or ar_state)
  begin : p_ar_stateComb
    case (ar_state)

       AXIBM_AR_READY_HIGH :
         begin
           i_arready = 1'b1;
           ar_state_nxt = arvalid ? AXIBM_AR_READY_LOW :
           AXIBM_AR_READY_HIGH;
         end

       AXIBM_AR_READY_LOW :
         begin
           i_arready = 1'b0;
           ar_state_nxt = (rready && i_rlast) ? AXIBM_AR_READY_HIGH :
           AXIBM_AR_READY_LOW;
         end

      default : ar_state_nxt = AXIBM_AR_READY_HIGH;

    endcase
  end


always @(negedge reset_n or posedge clk)
  begin : p_ar_state_seq
    if (!reset_n)
      ar_state <= AXIBM_AR_READY_HIGH;
    else
      ar_state <= ar_state_nxt;
  end


always @(artrans or i_rlast or rready or r_state)
  begin : p_r_state_comb
    case (r_state)

       AXIBM_R_VALID_LOW :
         begin
           i_rvalid = 1'b0;
           r_state_nxt =  (artrans) ? AXIBM_R_VALID_HIGH :
           AXIBM_R_VALID_LOW;
         end

       AXIBM_R_VALID_HIGH :
         begin
           i_rvalid = 1'b1;
           r_state_nxt = (i_rlast && rready) ? AXIBM_R_VALID_LOW :
           AXIBM_R_VALID_HIGH;
         end

      default : r_state_nxt = AXIBM_R_VALID_LOW;

    endcase
  end


always @(negedge reset_n or posedge clk)
  begin : p_r_stateSeq
    if (!reset_n)
      r_state  <= AXIBM_R_VALID_LOW;
    else
      r_state  <= r_state_nxt;
  end


always @( artrans or arlen or rready or i_rvalid or reads_left)
  begin : p_r_counter_dec_comb
    if (artrans)
       reads_left_nxt = arlen;
    else if((reads_left != {LEN_WIDTH{1'b0}}) && rready && i_rvalid)
       reads_left_nxt = reads_left - {{LEN_WIDTH-1{1'b0}},1'b1};
    else
       reads_left_nxt = reads_left;
  end


always @(negedge reset_n or posedge clk)
  begin : p_r_counter_dec_seq
    if (!reset_n)
      reads_left  <= {LEN_WIDTH{1'b0}};
    else
      reads_left  <= reads_left_nxt;
  end


endmodule


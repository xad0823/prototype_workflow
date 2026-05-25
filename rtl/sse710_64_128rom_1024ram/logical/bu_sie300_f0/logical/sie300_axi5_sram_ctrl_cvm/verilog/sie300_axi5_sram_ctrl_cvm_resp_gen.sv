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
//      Checked In          : Fri Jul 5 10:48:27 2019 +0100
//
//      Revision            : fc5e647c
//
//      Release Information : CoreLink SIE-300 Generic Global Bundle r1p2-00rel0
//
//----------------------------------------------------------------------------

module sie300_axi5_sram_ctrl_cvm_resp_gen
(
  input  wire logic                                           clk,
  input  wire logic                                           resetn,

  input  wire logic                                           arvalid,
  input  wire logic [12-1       :0]                           arid,
  input  wire logic [7                        :0]             arlen,
  input  wire logic                                           rready,
  input  wire logic                                           awvalid,
  input  wire logic [12-1       :0]                           awid,
  input  wire logic                                           wvalid,
  input  wire logic                                           wlast,
  input  wire logic                                           bready,
  input  wire logic                                           arready,
  input  wire logic                                           awready,

  output      logic                                           arready_r,
  output      logic                                           rvalid_r,
  output      logic [1                        :0]             rresp_r,
  output      logic                                           rlast_r,
  output      logic [12-1       :0]                           rid_r,
  output      logic                                           awready_r,
  output      logic                                           wready_r,
  output      logic                                           bvalid_r,
  output      logic [1                        :0]             bresp_r,
  output      logic [12-1       :0]                           bid_r,

  input  wire logic                                           cfg_gate_resp,
  input  wire logic                                           ext_gt_qacceptn,
  input  wire logic                                           resp_fsm_en,
  output      logic                                           resp_fsm_act
);

  typedef enum logic [1:0] {
    ST_IDLE = 2'b00,
    ST_ADDR,
    ST_DATA,
    ST_WR_RESP,
    ST_DEFAULT_X_RESP = 'x
  } resp_state_t;

  resp_state_t                                    rd_resp_state_nxt;
  resp_state_t                                    rd_resp_state;
  resp_state_t                                    wr_resp_state_nxt;
  resp_state_t                                    wr_resp_state;

  logic                                           gate_resp;
  logic                                           gate_resp_reg;
  logic                                           ext_gt_qacceptn_reg;

  always_ff @ (posedge clk or negedge resetn) begin
    if (~resetn) begin
      gate_resp_reg       <= 1'b0;
      ext_gt_qacceptn_reg <= 1'b0;
    end
    else begin
      if (ext_gt_qacceptn_reg & ~ext_gt_qacceptn) begin
        gate_resp_reg <= cfg_gate_resp;
      end
      ext_gt_qacceptn_reg <= ext_gt_qacceptn;
    end
  end

  assign gate_resp = (ext_gt_qacceptn_reg & ~ext_gt_qacceptn) ? cfg_gate_resp : gate_resp_reg;

  always_comb begin : comb_wr_resp_state_nxt
    wr_resp_state_nxt = wr_resp_state;
    case (wr_resp_state)
      ST_IDLE:        if (resp_fsm_en & gate_resp & awvalid) begin
                        wr_resp_state_nxt = ST_ADDR;
                      end

      ST_ADDR:        if (awready_r) begin
                        wr_resp_state_nxt = ST_DATA;
                      end

      ST_DATA:        if (wvalid & wready_r & wlast) begin
                        wr_resp_state_nxt = ST_WR_RESP;
                      end

      ST_WR_RESP:     if (bvalid_r & bready) begin
                        wr_resp_state_nxt = ST_IDLE;
                      end

      default:        wr_resp_state_nxt = ST_DEFAULT_X_RESP;
    endcase
  end

  always_ff @ (posedge clk or negedge resetn) begin : reg_wr_resp_state
    if (~resetn) begin
      wr_resp_state <= ST_IDLE;
    end
    else if (wr_resp_state != wr_resp_state_nxt) begin
      wr_resp_state <= wr_resp_state_nxt;
    end
  end

  always_ff @(posedge clk or negedge resetn) begin
    if(~resetn) begin
      bid_r <= 'b0;
    end
    else if(awvalid & awready_r) begin
      bid_r <= awid;
    end
  end

  assign awready_r  = (wr_resp_state == ST_ADDR);
  assign wready_r   = (wr_resp_state == ST_DATA);
  assign bvalid_r   = (wr_resp_state == ST_WR_RESP);
  assign bresp_r    = 2'b10;

  always_comb begin : comb_rd_resp_state_nxt
    rd_resp_state_nxt = rd_resp_state;
    case (rd_resp_state)
      ST_IDLE:        if (resp_fsm_en & gate_resp & arvalid) begin
                        rd_resp_state_nxt = ST_ADDR;
                      end

      ST_ADDR:        if (arready_r) begin
                        rd_resp_state_nxt = ST_DATA;
                      end

      ST_DATA:        if (rvalid_r & rready & rlast_r) begin
                        rd_resp_state_nxt = ST_IDLE;
                      end

      default:        rd_resp_state_nxt = ST_DEFAULT_X_RESP;
    endcase
  end

  always_ff @ (posedge clk or negedge resetn) begin : reg_rd_resp_state
    if (~resetn) begin
      rd_resp_state <= ST_IDLE;
    end else if (rd_resp_state != rd_resp_state_nxt) begin
      rd_resp_state <= rd_resp_state_nxt;
    end
  end

  always_ff @(posedge clk or negedge resetn) begin
    if(~resetn) begin
      rid_r <= 'b0;
    end
    else if(arvalid & arready_r) begin
      rid_r <= arid;
    end
  end

  logic [7:0]   rd_burst_cnt;

  always_ff @(posedge clk or negedge resetn) begin
    if(~resetn) begin
      rd_burst_cnt <= '0;
    end
    else if(arvalid & arready_r) begin
      rd_burst_cnt <= arlen;
    end
    else if(rready & rvalid_r) begin
      if (rd_burst_cnt != 8'b0)
      rd_burst_cnt <= rd_burst_cnt - 8'b1;
    end
  end

  assign arready_r  = (rd_resp_state == ST_ADDR);
  assign rvalid_r   = (rd_resp_state == ST_DATA);
  assign rresp_r    = 2'b10;
  assign rlast_r    = (rd_resp_state == ST_DATA)
                    ? (rd_burst_cnt == 8'b0)
                    : 1'b0;

  sie300_or_tree  #(
    .NUM_OR_INPUTS ( 4 )
  ) u_or_tree_resp_fsm_act (
    .or_inputs  ( { wr_resp_state,
                    rd_resp_state } ),
    .or_output  ( resp_fsm_act           )
  );
endmodule

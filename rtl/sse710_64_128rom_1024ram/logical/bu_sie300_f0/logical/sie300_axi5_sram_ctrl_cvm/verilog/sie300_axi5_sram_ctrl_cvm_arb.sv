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
//      Checked In          : Mon Jul 29 14:50:07 2019 +0100
//
//      Revision            : aec093fa
//
//      Release Information : CoreLink SIE-300 Generic Global Bundle r1p2-00rel0
//
//----------------------------------------------------------------------------

module sie300_axi5_sram_ctrl_cvm_arb
(
  input  wire logic                                           clk,
  input  wire logic                                           resetn,

  input  wire logic                                           wbeat_vld,
  output      logic                                           wbeat_rdy,
  input  wire logic [22-1     :0]                             wbeat_addr,
  input  wire logic [8-1     :0]                              wbeat_strb,

  input  wire logic                                           rbeat_vld,
  output      logic                                           rbeat_rdy,
  input  wire logic [22-1     :0]                             rbeat_addr,

  input  wire logic                                           wbeat_chk_exok,
  input  wire logic                                           eam_exok,

  input  wire logic                                           awq_rdy,
  input  wire logic                                           raw_match,
  input  wire logic                                           arq_last,

  input  wire logic                                           awq_full,
  input  wire logic                                           wq_full,
  input  wire logic                                           bq_full,

  input  wire logic                                           bq_lock,
  input  wire logic                                           bvalid,

  input  wire logic                                           arq_rdy,

  input  wire logic [3                        :0]             arq_qos,
  input  wire logic [3                        :0]             awq_qos,

  output      logic [22-1     :0]                             memaddr_arb,
  output      logic                                           memcen_arb,
  output      logic [8-1     :0]                              memwen_arb,
  output      logic                                           memrd_arb
);


  localparam NOP  = 2'b00;
  localparam RD   = 2'b01;
  localparam WR   = 2'b10;
  localparam BAL_CNT_LIMIT = 3'd7;

  typedef logic[2:0] cnt_t;

  logic up_arb;
  logic last_beat;
  logic [1:0] curr_acc;
  logic [1:0] next_acc;
  cnt_t wr_bal_cnt;
  cnt_t rd_bal_cnt;

  logic wr_bal_incr;
  logic wr_bal_clr;
  logic rd_bal_incr;
  logic rd_bal_clr;

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn ) begin
      last_beat        <= '0;
    end
    else begin
      last_beat        <= (rbeat_rdy & arq_rdy) | (wbeat_rdy & awq_rdy) | (wbeat_rdy & wbeat_chk_exok & ~eam_exok) ;
    end
  end

  assign up_arb = last_beat | curr_acc==NOP;

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn ) begin
      curr_acc        <= '0;
    end
    else begin
      curr_acc        <= next_acc;
    end
  end


  always_comb begin
    if (up_arb) begin
        if (raw_match)
          if (wbeat_vld)
            next_acc = WR;
          else
            if (rbeat_vld & ~arq_last)
              next_acc = RD;

            else
              next_acc = NOP;
        else
          case ({rbeat_vld, wbeat_vld})
            2'b00 : next_acc = NOP;
            2'b10 : next_acc = RD;
            2'b01 : next_acc = WR;
            2'b11 : if ( ~(awq_full | wq_full | bq_full | (bq_lock & ~bvalid) ) )
                      next_acc = RD;
                    else
                      if (wr_bal_cnt >= BAL_CNT_LIMIT)
                        next_acc = WR;
                      else
                        if (rd_bal_cnt >= BAL_CNT_LIMIT)
                          next_acc = RD;
                        else
                          if (arq_qos > awq_qos)
                            next_acc = RD;
                          else
                            next_acc = WR;
        default: next_acc = 'x;
      endcase
    end
    else begin
      next_acc = curr_acc;
    end
  end

  assign wbeat_rdy    = (next_acc==WR);
  assign rbeat_rdy    = (next_acc==RD);


  assign memaddr_arb  = rbeat_rdy
                      ? rbeat_addr
                      : wbeat_addr;

  assign memcen_arb = ~((rbeat_vld & rbeat_rdy) | (wbeat_vld & wbeat_rdy & ~wbeat_chk_exok) );

  assign memrd_arb = rbeat_vld & rbeat_rdy;

  assign memwen_arb[8-1:0]
                      = rbeat_rdy
                      ? {8{1'b1}}
                      : ~wbeat_strb;


  assign wr_bal_clr  = up_arb & (next_acc == WR);
  assign wr_bal_incr = up_arb & rbeat_vld & wbeat_vld & (next_acc == RD);

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn) begin
      wr_bal_cnt   <= '0;
    end
    else if (wr_bal_clr) begin
      wr_bal_cnt   <= '0;
    end
    else if (wr_bal_incr & wr_bal_cnt < BAL_CNT_LIMIT) begin
      wr_bal_cnt     <= wr_bal_cnt + cnt_t'(1);
    end
  end

  assign rd_bal_clr  = up_arb & (next_acc == RD);
  assign rd_bal_incr = up_arb & rbeat_vld & wbeat_vld & (next_acc == WR);

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn) begin
      rd_bal_cnt   <= '0;
    end
    else if (rd_bal_clr) begin
      rd_bal_cnt   <= '0;
    end
    else if (rd_bal_incr & rd_bal_cnt < BAL_CNT_LIMIT) begin
      rd_bal_cnt     <= rd_bal_cnt + cnt_t'(1);
    end
  end

endmodule

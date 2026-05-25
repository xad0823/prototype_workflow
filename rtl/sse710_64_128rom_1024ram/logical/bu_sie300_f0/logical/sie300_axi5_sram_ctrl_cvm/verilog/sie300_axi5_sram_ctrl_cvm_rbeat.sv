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
//      Checked In          : Tue Apr 30 16:42:21 2019 +0100
//
//      Revision            : 59885c20
//
//      Release Information : CoreLink SIE-300 Generic Global Bundle r1p2-00rel0
//
//----------------------------------------------------------------------------

module sie300_axi5_sram_ctrl_cvm_rbeat
(
  input  wire logic                                           clk,
  input  wire logic                                           resetn,

  input  wire logic                                           arq_vld,
  output      logic                                           arq_rdy,
  input  wire logic [12-1       :0]                           arq_id,
  input  wire logic [22-1     :0]                             arq_addr,
  input  wire logic [7                        :0]             arq_len,
  input  wire logic [2                        :0]             arq_size,
  input  wire logic [1                        :0]             arq_burst,
  input  wire logic                                           arq_lock,

  output      logic                                           rq_vld,
  output      logic [64-1     :0]                             rq_data,
  output      logic [12-1       :0]                           rq_id,
  output      logic [1                        :0]             rq_resp,
  output      logic                                           rq_last,

  input  wire logic                                           rvalid,
  input  wire logic                                           rready,

  output      logic                                           rbeat_vld,
  input  wire logic                                           rbeat_rdy,
  output      logic [22-1     :0]                             rbeat_addr,

  input  wire logic [64-1     :0]                             memq_clamp
);

  typedef enum logic [1:0] {
    EXOK = 2'b01,
    OKAY = 2'b00
  } axi_resp_t;

  typedef logic[7:0] cnt_t;

  axi_resp_t rq_resp_int;
  cnt_t rbeat_cnt;
  logic rbeat_last;
  logic load_cnt;
  logic incr_cnt;
  logic first_cycle;
  logic arq_vld_r;
  logic arq_rdy_r;
  logic [1:0] cap;

  logic rq_lock;

  localparam MAX_CAP = 2'd1;

  sie300_axi5_sram_ctrl_cvm_addr_dec
    u_addr_dec (
    .clk                ( clk             ),
    .resetn             ( resetn          ),
    .addr               ( arq_addr        ),
    .len                ( arq_len         ),
    .size               ( arq_size        ),
    .burst              ( arq_burst       ),
    .first_cycle        ( first_cycle     ),
    .en_cnt             ( incr_cnt        ),
    .addr_calc          ( rbeat_addr      )
  );

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn ) begin
      rbeat_cnt <= '0;
    end
    else begin
      if (load_cnt) begin
        rbeat_cnt <= '0;
      end
      else if (incr_cnt ) begin
        rbeat_cnt <= cnt_t'(rbeat_cnt + cnt_t'(1));
      end
    end
  end

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn ) begin
      arq_vld_r     <= 'b0;
      arq_rdy_r     <= 'b0;
    end
    else begin
      arq_vld_r     <= arq_vld;
      arq_rdy_r     <= arq_rdy;
    end
  end

  assign load_cnt   = (~arq_vld)
                    | ( arq_vld &  arq_rdy);

  assign first_cycle= (arq_vld & ~arq_vld_r)
                    | (arq_vld &  arq_vld_r & arq_rdy_r);
  assign incr_cnt   = rbeat_vld & rbeat_rdy & ~rbeat_last;

  assign rbeat_last = (rbeat_cnt==arq_len) & rbeat_vld;

  assign rbeat_vld  = arq_vld & (rready | cap < MAX_CAP );

  assign arq_rdy    = rbeat_vld & rbeat_rdy & rbeat_last;


  assign rq_data                  = memq_clamp;


  assign rq_resp_int  = rq_lock ? EXOK : OKAY;

  assign rq_resp = rq_resp_int;

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn ) begin
      rq_vld  <= 'b0;
      rq_id   <= 'b0;
      rq_last <= 'b0;
      rq_lock <= 'b0;
    end
    else if (rbeat_vld & rbeat_rdy) begin
      rq_vld  <= 'b1;
      rq_id   <= arq_id;
      rq_last <= rbeat_last;
      rq_lock <= arq_lock;
    end
    else begin
      rq_vld  <= 'b0;
    end
  end

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn ) begin
      cap <= '0;
    end
    else begin
      case ( { rbeat_vld & rbeat_rdy, rvalid & rready } )
        2'b00,
        2'b11: cap <= cap;
        2'b10: cap <= 2'(cap + 2'b1);
        2'b01: cap <= 2'(cap - 2'b1);
        default: cap <= 'x;
      endcase
    end
  end


endmodule

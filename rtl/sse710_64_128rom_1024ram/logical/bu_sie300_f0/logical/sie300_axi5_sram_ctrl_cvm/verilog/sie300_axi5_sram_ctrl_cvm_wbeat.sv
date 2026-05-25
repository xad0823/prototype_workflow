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
//      Checked In          : Tue Apr 30 09:07:02 2019 +0100
//
//      Revision            : 1dc2da2f
//
//      Release Information : CoreLink SIE-300 Generic Global Bundle r1p2-00rel0
//
//----------------------------------------------------------------------------

module sie300_axi5_sram_ctrl_cvm_wbeat
(
  input  wire logic                                           clk,
  input  wire logic                                           resetn,

  input  wire logic                                           awq_vld,
  output      logic                                           awq_rdy,
  input  wire logic [22-1     :0]                             awq_addr,
  input  wire logic [7                        :0]             awq_len,
  input  wire logic [2                        :0]             awq_size,
  input  wire logic [1                        :0]             awq_burst,
  input  wire logic                                           awq_lock,

  input  wire logic                                           wq_vld,
  output      logic                                           wq_rdy,
  input  wire logic [64-1     :0]                             wq_data,
  input  wire logic [8-1     :0]                              wq_strb,

  output      logic                                           wbeat_vld,
  input  wire logic                                           wbeat_rdy,
  output      logic [22-1     :0]                             wbeat_addr,
  output      logic [8-1     :0]                              wbeat_strb,

  input  wire logic                                           eam_exok,
  input  wire logic                                           bq_exok_saved,
  output      logic                                           wbeat_chk_exok,

  output      logic [64-1     :0]                             memd_wbeat
);

  typedef logic[7:0] cnt_t;

  cnt_t wbeat_cnt;
  logic wbeat_last;
  logic load_cnt;
  logic incr_cnt;
  logic first_cycle;
  logic awq_vld_r;
  logic awq_rdy_r;
  logic wbeat_vld_i;
  logic wbeat_rdy_i;
  logic exfail;
  logic exfail_saved;

  sie300_axi5_sram_ctrl_cvm_addr_dec
    u_addr_dec (
    .clk                ( clk             ),
    .resetn             ( resetn          ),
    .addr               ( awq_addr        ),
    .len                ( awq_len         ),
    .size               ( awq_size        ),
    .burst              ( awq_burst       ),
    .first_cycle        ( first_cycle     ),
    .en_cnt             ( incr_cnt        ),
    .addr_calc          ( wbeat_addr      )
  );

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn ) begin
      wbeat_cnt <= '0;
    end
    else begin
      if (load_cnt) begin
        wbeat_cnt <= '0;
      end
      else if (incr_cnt ) begin
        wbeat_cnt <= cnt_t'(wbeat_cnt + cnt_t'(1));
      end
    end
  end

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn ) begin
      awq_vld_r <= 1'b0;
      awq_rdy_r <= 1'b0;
    end
    else begin
      awq_vld_r <= awq_vld;
      awq_rdy_r <= awq_rdy;
    end
  end

  assign load_cnt     = (~awq_vld)
                      | ( awq_vld &  awq_rdy);

  assign first_cycle  = (awq_vld & ~awq_vld_r)
                      | (awq_vld &  awq_vld_r & awq_rdy_r);

  assign incr_cnt     = wbeat_vld_i & wbeat_rdy_i & ~wbeat_last;

  assign wbeat_last   = (wbeat_cnt==awq_len) & wbeat_vld_i;

  assign wbeat_vld_i  = awq_vld & wq_vld;

  assign wbeat_strb   = wq_strb;

  assign awq_rdy      = (awq_len != 8'h0 )
                      ? (wbeat_vld_i & wbeat_rdy_i & wbeat_last & awq_vld_r & ~awq_rdy_r)
                      : (wbeat_vld_i & wbeat_rdy_i);

  assign wq_rdy       = wbeat_vld_i & wbeat_rdy_i;

  assign wbeat_vld    = wbeat_vld_i & ( (awq_lock & ~exfail_saved & ~bq_exok_saved)
                                      | (awq_lock &  exfail_saved & ~exfail )
                                      | ~awq_lock ) ;
  assign wbeat_rdy_i  = (wbeat_rdy & ~wbeat_chk_exok)  | ( exfail & exfail_saved ) ;

  always_ff @ (posedge clk or negedge resetn) begin
    if(~resetn ) begin
      exfail        <= '0;
      exfail_saved  <= '0;
    end
    else begin
      if (wbeat_chk_exok) begin
        exfail_saved  <= 1'b1;
        exfail        <= ~eam_exok;
      end
      else if (awq_rdy) begin
        exfail_saved  <= 1'b0;
      end
    end
  end

  assign wbeat_chk_exok = wbeat_vld & wbeat_rdy & awq_lock & ~bq_exok_saved & ~exfail_saved;


  assign memd_wbeat = {wq_data};

endmodule


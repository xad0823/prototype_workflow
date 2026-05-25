//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------

module firewall_f0_dti_reg_slice
  (
   aresetn,
   aclk,

  tvalid_dn_s,
  tready_dn_s,
  tpayld_dn_s,
  tvalid_up_s,
  tready_up_s,
  tpayld_up_s,

  tvalid_dn_m,
  tready_dn_m,
  tpayld_dn_m,
  tvalid_up_m,
  tready_up_m,
  tpayld_up_m,

  reg_busy_dn,
  reg_busy_up

  );

`include "firewall_f0_reg_slice_localparams.v"

  parameter PAYLD_WIDTH    = 160;
  parameter DN_PAYLD_WIDTH = PAYLD_WIDTH;
  parameter UP_PAYLD_WIDTH = PAYLD_WIDTH;
  parameter MODE           = RS_REGD;           

  localparam DN_PAYLD_MSB   = (DN_PAYLD_WIDTH - 1);
  localparam UP_PAYLD_MSB   = (UP_PAYLD_WIDTH - 1);
  localparam INT_HNDSHK_MODE = MODE; 


  input   wire                  aresetn;
  input   wire                  aclk;

  input   wire                  tvalid_dn_s;
  output  wire                  tready_dn_s;
  input   wire [DN_PAYLD_MSB:0] tpayld_dn_s;
  output  wire                  tvalid_up_s;
  input   wire                  tready_up_s;
  output  wire [UP_PAYLD_MSB:0] tpayld_up_s;

  output  wire                  tvalid_dn_m;
  input   wire                  tready_dn_m;
  output  wire [DN_PAYLD_MSB:0] tpayld_dn_m;
  input   wire                  tvalid_up_m;
  output  wire                  tready_up_m;
  input   wire [UP_PAYLD_MSB:0] tpayld_up_m;

  output  wire                  reg_busy_dn;
  output  wire                  reg_busy_up;

  generate
    if (INT_HNDSHK_MODE == RS_REGD)
    begin : g_full_reg_slice
      firewall_f0_ful_regd_slice #(.PAYLD_WIDTH (DN_PAYLD_WIDTH)) u_dn_ful_regd_slice
        (
        .aresetn          (aresetn),
        .aclk             (aclk),
        .valid_src        (tvalid_dn_s),
        .ready_dst        (tready_dn_m),
        .payload_src      (tpayld_dn_s),
        .valid_dst        (tvalid_dn_m),
        .ready_src        (tready_dn_s),
        .payload_dst      (tpayld_dn_m)
        );

      firewall_f0_ful_regd_slice #(.PAYLD_WIDTH (UP_PAYLD_WIDTH)) u_up_ful_regd_slice
        (
        .aresetn          (aresetn),
        .aclk             (aclk),
        .valid_src        (tvalid_up_m),
        .ready_dst        (tready_up_s),
        .payload_src      (tpayld_up_m),
        .valid_dst        (tvalid_up_s),
        .ready_src        (tready_up_m),
        .payload_dst      (tpayld_up_s)
        );

    end
    else
    if (INT_HNDSHK_MODE == RS_FWD_REG)
    begin : g_fwd_reg_slice
      firewall_f0_fwd_regd_slice #(.PAYLD_WIDTH (DN_PAYLD_WIDTH)) u_dn_fwd_regd_slice
        (
        .aresetn          (aresetn),
        .aclk             (aclk),
        .valid_src        (tvalid_dn_s),
        .ready_dst        (tready_dn_m),
        .payload_src      (tpayld_dn_s),
        .valid_dst        (tvalid_dn_m),
        .ready_src        (tready_dn_s),
        .payload_dst      (tpayld_dn_m)
        );

      firewall_f0_fwd_regd_slice #(.PAYLD_WIDTH (UP_PAYLD_WIDTH)) u_up_fwd_regd_slice
        (
        .aresetn          (aresetn),
        .aclk             (aclk),
        .valid_src        (tvalid_up_m),
        .ready_dst        (tready_up_s),
        .payload_src      (tpayld_up_m),
        .valid_dst        (tvalid_up_s),
        .ready_src        (tready_up_m),
        .payload_dst      (tpayld_up_s)
        );

    end
    else
    if (INT_HNDSHK_MODE == RS_REV_REG)
    begin : g_rev_reg_slice
      firewall_f0_rev_regd_slice #(.PAYLD_WIDTH (DN_PAYLD_WIDTH)) u_dn_rev_regd_slice
        (
        .aresetn          (aresetn),
        .aclk             (aclk),
        .valid_src        (tvalid_dn_s),
        .ready_dst        (tready_dn_m),
        .payload_src      (tpayld_dn_s),
        .valid_dst        (tvalid_dn_m),
        .ready_src        (tready_dn_s),
        .payload_dst      (tpayld_dn_m)
        );

      firewall_f0_rev_regd_slice #(.PAYLD_WIDTH (UP_PAYLD_WIDTH)) u_up_rev_regd_slice
        (
        .aresetn          (aresetn),
        .aclk             (aclk),
        .valid_src        (tvalid_up_m),
        .ready_dst        (tready_up_s),
        .payload_src      (tpayld_up_m),
        .valid_dst        (tvalid_up_s),
        .ready_src        (tready_up_m),
        .payload_dst      (tpayld_up_s)
        );

    end
    else
    begin : g_bypass

      assign  tvalid_dn_m = tvalid_dn_s;
      assign  tready_dn_s = tready_dn_m;
      assign  tpayld_dn_m = tpayld_dn_s;
      assign  tvalid_up_s = tvalid_up_m;
      assign  tready_up_m = tready_up_s;
      assign  tpayld_up_s = tpayld_up_m;

    end
  endgenerate

  reg   [1:0] reg_busy_dn_i;
  wire  [1:0] reg_busy_dn_nxt;
  wire        reg_busy_dn_en;
  wire        reg_busy_dn_hs_out;

  generate
    if (INT_HNDSHK_MODE == RS_STATIC_BYPASS)
      begin : g_reg_busy_dn_bypass_mode
        assign reg_busy_dn_nxt = reg_busy_dn_i;
      end
    else
      begin : g_reg_busy_dn_not_bypass_mode

        reg  [1:0] reg_busy_dn_comb;
        wire       reg_busy_dn_hs_in;

        assign reg_busy_dn_hs_in  = tvalid_dn_s & tready_dn_s;

        always @*
          case ({reg_busy_dn_hs_in, reg_busy_dn_hs_out})
            2'b00,
            2'b11 : reg_busy_dn_comb = reg_busy_dn_i;
            2'b01 : reg_busy_dn_comb = reg_busy_dn_i - 2'b01;
            2'b10 : reg_busy_dn_comb = reg_busy_dn_i + 2'b01;
            default : reg_busy_dn_comb = 2'bxx;
          endcase

          assign reg_busy_dn_nxt = reg_busy_dn_comb;
      end
  endgenerate

  always @(posedge aclk or negedge aresetn)
  begin : q_reg_busy_dn
    if(!aresetn) begin
      reg_busy_dn_i <=  2'b00;
    end else if(reg_busy_dn_en) begin
      reg_busy_dn_i <= reg_busy_dn_nxt;
    end
  end

  assign reg_busy_dn_hs_out = tvalid_dn_m & tready_dn_m;
  assign reg_busy_dn_en     = tvalid_dn_s | reg_busy_dn_hs_out;

  firewall_f0_or_tree #(
    .ACTIVE_WIDTH (2)
  ) u_firewall_f0_dti_reg_slice_reg_busy_dn_or2tree (
    .actives_i (reg_busy_dn_i),
    .active_o  (reg_busy_dn)
  );

  reg   [1:0] reg_busy_up_i;
  wire  [1:0] reg_busy_up_nxt;
  wire        reg_busy_up_en;
  wire        reg_busy_up_hs_out;

  generate
    if (INT_HNDSHK_MODE == RS_STATIC_BYPASS)
      begin : g_reg_busy_up_bypass_mode
        assign reg_busy_up_nxt = reg_busy_up_i;
      end
    else
      begin : g_reg_busy_up_not_bypass_mode

        reg  [1:0] reg_busy_up_comb;
        wire       reg_busy_up_hs_in;
        assign reg_busy_up_hs_in  = tvalid_up_m & tready_up_m;

        always @*
          case ({reg_busy_up_hs_in, reg_busy_up_hs_out})
            2'b00,
            2'b11 : reg_busy_up_comb = reg_busy_up_i;
            2'b01 : reg_busy_up_comb = reg_busy_up_i - 2'b01;
            2'b10 : reg_busy_up_comb = reg_busy_up_i + 2'b01;
            default : reg_busy_up_comb = 2'bxx;
          endcase

        assign reg_busy_up_nxt = reg_busy_up_comb;
      end
  endgenerate

  always @(posedge aclk or negedge aresetn)
  begin : q_reg_busy_up
    if(!aresetn) begin
      reg_busy_up_i <=  2'b00;
    end else if(reg_busy_up_en) begin
      reg_busy_up_i <= reg_busy_up_nxt;
    end
  end

  assign reg_busy_up_hs_out = tvalid_up_s & tready_up_s;
  assign reg_busy_up_en     = tvalid_up_m | reg_busy_up_hs_out;

  firewall_f0_or_tree #(
    .ACTIVE_WIDTH (2)
  ) u_firewall_f0_dti_reg_slice_reg_busy_up_or2tree (
    .actives_i (reg_busy_up_i),
    .active_o  (reg_busy_up)
  );

endmodule 

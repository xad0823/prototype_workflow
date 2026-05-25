//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Mon Sep 12 08:10:15 2016 +0100
//
//      Revision            : a5f598d
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//------------------------------------------------------------------------------

module sie200_ahb5_to_ahb5_sync_down_core_s #(

  parameter       AW    = 32,
  parameter       DW    = 32,
  parameter       MW    = 4,
  parameter       UW    = 1,
  parameter       BURST = 0)
 (
  input  wire          hclk_s,
  input  wire          hresetn_s,

  input  wire          hsel_s,
  input  wire          hnonsec_s,
  input  wire [AW-1:0] haddr_s,
  input  wire    [1:0] htrans_s,
  input  wire    [2:0] hsize_s,
  input  wire          hwrite_s,
  input  wire          hready_s,
  input  wire    [6:0] hprot_s,
  input  wire [MW-1:0] hmaster_s,
  input  wire          hmastlock_s,
  input  wire          hexcl_s,
  input  wire    [2:0] hburst_s,
  input  wire [UW-1:0] hauser_s,

  output wire          hreadyout_s,
  output wire          hresp_s,
  output wire          hexokay_s,
  output wire [DW-1:0] hrdata_s,
  output wire [UW-1:0] hruser_s,

  output reg           hnonsecs_reg,
  output reg  [AW-1:0] haddrs_reg,
  output reg     [1:0] htranss_reg,
  output reg     [2:0] hsizes_reg,
  output reg           hwrites_reg,
  output reg     [6:0] hprots_reg,
  output reg  [MW-1:0] hmasters_reg,
  output reg           hmastlocks_reg,
  output reg           hexcls_reg,
  output reg     [2:0] hbursts_reg,
  output reg  [UW-1:0] hausers_reg,

  input  wire          hrespm_reg,
  input  wire          hexokaym_reg,
  input  wire [DW-1:0] hrdatam_reg,
  input  wire [UW-1:0] hruserm_reg,

  input  wire          transm_done,
  output reg           transs_req,
  output reg           unlocks_req,
  output wire          transs_hold,

  input  wire          bwerr,
  output wire          wb_disable,

  input  wire          cfg_gate_resp,
  input  wire          s_hold_en,
  output wire          s_pend_trans,
  output wire          s_active
  );


localparam TRN_IDLE   = 2'b00;
localparam TRN_BUSY   = 2'b01;
localparam TRN_NONSEQ = 2'b10;
localparam TRN_SEQ    = 2'b11;

localparam RESP_OKAY  = 1'b0;
localparam RESP_ERR   = 1'b1;

localparam FSM_IDLE  = 3'b000;
localparam FSM_HOLD  = 3'b001;
localparam FSM_REJECT = 3'b010;
localparam FSM_ERR   = 3'b011;
localparam FSM_WAIT  = 3'b100;

wire       sample_addr_phase;

reg        last_transm_done;
wire       transs_done;

reg        locked_trans_reg;
wire       unlocks_valid;

wire       s_idle;

reg  [2:0] slave_state, slave_state_nxt;
reg        hreadyouts_nxt, hreadyouts_reg;
reg        hresps_nxt, hresps_reg;
reg        hexokays_nxt, hexokays_reg;
reg        transs_req_nxt;



assign  sample_addr_phase = hsel_s & htrans_s[1] & hready_s;

always @(posedge hclk_s or negedge hresetn_s)
begin
  if (!hresetn_s) begin
    hnonsecs_reg    <= 1'b0;
    haddrs_reg      <= {AW{1'b0}};
    htranss_reg     <= TRN_NONSEQ;
    hsizes_reg      <= 3'h0;
    hwrites_reg     <= 1'b0;
    hprots_reg      <= 7'h0;
    hmasters_reg    <= {MW{1'b0}};
    hmastlocks_reg  <= 1'b0;
    hexcls_reg      <= 1'b0;
    hbursts_reg     <= 3'h0;
    hausers_reg     <= {UW{1'b0}};
  end
  else if (sample_addr_phase) begin
    hnonsecs_reg    <= hnonsec_s;
    haddrs_reg      <= haddr_s;
    htranss_reg     <= htrans_s;
    hsizes_reg      <= hsize_s;
    hwrites_reg     <= hwrite_s;
    hprots_reg      <= hprot_s;
    hmasters_reg    <= hmaster_s;
    hmastlocks_reg  <= hmastlock_s;
    hexcls_reg      <= hexcl_s;
    hbursts_reg     <= hburst_s;
    hausers_reg     <= hauser_s;
  end
end


always @(posedge hclk_s or negedge hresetn_s)
begin
  if (!hresetn_s) begin
    last_transm_done <= 1'b0;
  end
  else begin
    last_transm_done <= transm_done;
  end
end

assign transs_done = transm_done & ~last_transm_done;



always @(posedge hclk_s or negedge hresetn_s)
begin
  if (!hresetn_s) begin
    locked_trans_reg <= 1'b0;
  end
  else if (sample_addr_phase & hmastlock_s) begin
    locked_trans_reg <= 1'b1;
  end
  else if (hready_s &((hsel_s & (~hmastlock_s)) | (~hsel_s))) begin
    locked_trans_reg <= 1'b0;
  end
end


assign unlocks_valid = hready_s & locked_trans_reg & (((~hmastlock_s) & hsel_s)
                       | (~hsel_s));


always @(posedge hclk_s or negedge hresetn_s)
begin
  if (!hresetn_s) begin
    unlocks_req <= 1'b0;
  end
  else if (transs_done) begin
    unlocks_req <= 1'b0;
  end
  else if (unlocks_valid) begin
    unlocks_req <= 1'b1;
  end
end


assign s_idle = ((~htrans_s[0] | ~hsel_s) & ~locked_trans_reg & ~bwerr & (slave_state == FSM_IDLE)) | (slave_state == FSM_REJECT);

assign s_pend_trans = ~s_idle;

assign s_active = ((slave_state_nxt != FSM_IDLE) & (slave_state_nxt != FSM_REJECT)) | s_pend_trans;

assign transs_hold = (slave_state == FSM_HOLD) | (slave_state == FSM_REJECT);

assign wb_disable = s_hold_en | (slave_state_nxt == FSM_HOLD) | (slave_state_nxt == FSM_REJECT);

always @ *
begin
  slave_state_nxt = slave_state;
  hreadyouts_nxt = hreadyouts_reg;
  hresps_nxt = RESP_OKAY;
  hexokays_nxt = 1'b0;
  transs_req_nxt = transs_req;
  case (slave_state)
    FSM_IDLE:
      begin
        if (sample_addr_phase) begin
          if (s_hold_en) begin
            slave_state_nxt = cfg_gate_resp ? FSM_REJECT : FSM_HOLD;
            hreadyouts_nxt = 1'b0;
            hresps_nxt = cfg_gate_resp ? RESP_ERR : RESP_OKAY;
            hexokays_nxt = 1'b0;
            transs_req_nxt = 1'b0;
          end
          else begin
            slave_state_nxt = FSM_WAIT;
            hreadyouts_nxt = 1'b0;
            hresps_nxt = RESP_OKAY;
            hexokays_nxt = 1'b0;
            transs_req_nxt = 1'b1;
          end
        end
      end

    FSM_HOLD:
      begin
        if (s_hold_en) begin
          slave_state_nxt = FSM_HOLD;
          hreadyouts_nxt = 1'b0;
          hresps_nxt = RESP_OKAY;
          hexokays_nxt = 1'b0;
          transs_req_nxt = 1'b0;
        end
        else begin
          slave_state_nxt = FSM_WAIT;
          hreadyouts_nxt = 1'b0;
          hresps_nxt = RESP_OKAY;
          hexokays_nxt = 1'b0;
          transs_req_nxt = 1'b1;
        end
      end

    FSM_REJECT:
      begin
        if (!hreadyouts_reg) begin
          slave_state_nxt = FSM_REJECT;
          hreadyouts_nxt = 1'b1;
          hresps_nxt = RESP_ERR;
          hexokays_nxt = 1'b0;
          transs_req_nxt = 1'b0;
        end
        else if (sample_addr_phase) begin
          if (!htrans_s[0] && ({locked_trans_reg, hmastlock_s} != 2'b11)) begin
            if (!s_hold_en || !cfg_gate_resp) begin
              slave_state_nxt = s_hold_en ? FSM_HOLD : FSM_WAIT;
              hreadyouts_nxt = 1'b0;
              hresps_nxt = RESP_OKAY;
              hexokays_nxt = 1'b0;
              transs_req_nxt = ~s_hold_en;
            end
            else begin
              slave_state_nxt = FSM_REJECT;
              hreadyouts_nxt = 1'b0;
              hresps_nxt = RESP_ERR;
              hexokays_nxt = 1'b0;
              transs_req_nxt = 1'b0;
            end
          end
          else begin
            slave_state_nxt = FSM_REJECT;
            hreadyouts_nxt = 1'b0;
            hresps_nxt = RESP_ERR;
            hexokays_nxt = 1'b0;
            transs_req_nxt = 1'b0;
          end
        end
      end

    FSM_ERR:
      begin
        slave_state_nxt = FSM_IDLE;
        hreadyouts_nxt = 1'b1;
        hresps_nxt = RESP_ERR;
        hexokays_nxt = 1'b0;
        transs_req_nxt = 1'b0;
      end

    FSM_WAIT:
      begin
        if (transs_done) begin
          if (hrespm_reg == RESP_OKAY) begin
            slave_state_nxt = FSM_IDLE;
            hreadyouts_nxt = 1'b1;
            hresps_nxt = RESP_OKAY;
            hexokays_nxt = hexokaym_reg;
            transs_req_nxt = 1'b0;
          end
          else begin
            slave_state_nxt = FSM_ERR;
            hreadyouts_nxt = 1'b0;
            hresps_nxt = RESP_ERR;
            hexokays_nxt = 1'b0;
            transs_req_nxt = 1'b0;
          end
        end
      end

    default:
      begin
        slave_state_nxt = 3'bxxx;
        hreadyouts_nxt = 1'bx;
        hresps_nxt = 1'bx;
        hexokays_nxt = 1'bx;
        transs_req_nxt = 1'bx;
      end
  endcase
end


always @(posedge hclk_s or negedge hresetn_s)
begin
  if (!hresetn_s) begin
    slave_state <= FSM_IDLE;
    hreadyouts_reg <= 1'b1;
    hresps_reg <= RESP_OKAY;
    hexokays_reg <= 1'b0;
    transs_req <= 1'b0;
  end
  else begin
    slave_state <= slave_state_nxt;
    hreadyouts_reg <= hreadyouts_nxt;
    hresps_reg <= hresps_nxt;
    hexokays_reg <= hexokays_nxt;
    transs_req <= transs_req_nxt;
  end
end

assign hreadyout_s = hreadyouts_reg;
assign hresp_s = hresps_reg;
assign hexokay_s = hexokays_reg;

assign hrdata_s = hrdatam_reg;
assign hruser_s = hruserm_reg;

endmodule

// -----------------------------------------------------------------------------
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
//      Checked In          : Fri Sep 2 11:03:19 2016 +0200
//
//      Revision            : da73871
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_to_ahb5_sync_down_core_m #(

  parameter       AW    = 32,
  parameter       DW    = 32,
  parameter       MW    = 4,
  parameter       UW    = 1,
  parameter       BURST = 0)
 (
  input  wire          hclk_m,
  input  wire          hresetn_m,

  input  wire          hnonsecs_reg,
  input  wire [AW-1:0] haddrs_reg,
  input  wire    [1:0] htranss_reg,
  input  wire    [2:0] hsizes_reg,
  input  wire          hwrites_reg,
  input  wire    [6:0] hprots_reg,
  input  wire [MW-1:0] hmasters_reg,
  input  wire          hmastlocks_reg,
  input  wire          hexcls_reg,
  input  wire    [2:0] hbursts_reg,
  input  wire [UW-1:0] hausers_reg,

  input  wire          hsel_s,
  input  wire [AW-1:0] haddr_s,
  input  wire    [1:0] htrans_s,
  input  wire [DW-1:0] hwdata_s,
  input  wire [UW-1:0] hwuser_s,

  output reg           hrespm_reg,
  output reg           hexokaym_reg,
  output reg  [DW-1:0] hrdatam_reg,
  output reg  [UW-1:0] hruserm_reg,

  output reg           transm_done,
  input  wire          transs_req,
  input  wire          unlocks_req,
  input  wire          transs_hold,

  input  wire          brg_pwr_req_m,

  output wire          hnonsec_m,
  output wire [AW-1:0] haddr_m,
  output wire    [1:0] htrans_m,
  output wire    [2:0] hsize_m,
  output wire          hwrite_m,
  output wire    [6:0] hprot_m,
  output wire [MW-1:0] hmaster_m,
  output wire          hmastlock_m,
  output wire [DW-1:0] hwdata_m,
  output wire          hexcl_m,
  output wire    [2:0] hburst_m,
  output wire [UW-1:0] hauser_m,
  output wire [UW-1:0] hwuser_m,

  input  wire          hready_m,
  input  wire          hresp_m,
  input  wire          hexokay_m,
  input  wire [DW-1:0] hrdata_m,
  input  wire [UW-1:0] hruser_m
  );

localparam TRN_IDLE   = 2'b00;
localparam TRN_BUSY   = 2'b01;
localparam TRN_NONSEQ = 2'b10;
localparam TRN_SEQ    = 2'b11;

localparam RESP_OKAY  = 1'b0;
localparam RESP_ERR   = 1'b1;

localparam FSM_IDLE   = 3'b000;
localparam FSM_UNLOCK = 3'b001;
localparam FSM_ADDR   = 3'b010;
localparam FSM_WAIT   = 3'b011;
localparam FSM_ERR    = 3'b100;
localparam FSM_DONE   = 3'b101;

wire          addr_m_changeable;

reg  [DW-1:0] hwdatam_reg;
reg  [UW-1:0] hwuserm_reg;
reg  [1:0]    htransm_reg;
wire [1:0]    htransm_nxt;
reg  [AW-1:0] haddrm_reg;
wire [AW-1:0] haddrm_nxt;
reg           hmastlockm_reg;
wire          hmastlockm_nxt;
reg           hnonsecm_reg;
wire          hnonsecm_nxt;
reg  [2:0]    hsizem_reg;
wire [2:0]    hsizem_nxt;
reg           hwritem_reg;
wire          hwritem_nxt;
reg  [6:0]    hprotm_reg;
wire [6:0]    hprotm_nxt;
reg  [MW-1:0] hmasterm_reg;
wire [MW-1:0] hmasterm_nxt;
reg           hexclm_reg;
wire          hexclm_nxt;
reg  [UW-1:0] hauserm_reg;
wire [UW-1:0] hauserm_nxt;

wire          hreadyoutm_canc;
wire          hrespm_canc;

reg  [2:0]    master_state, master_state_nxt;
reg           transm_valid;
reg           unlockm_idle_valid;
reg           hwdatam_valid;
reg           hrdatam_valid;


assign  addr_m_changeable = (htransm_reg == TRN_IDLE) | hreadyoutm_canc;


always @(posedge hclk_m or negedge hresetn_m)
begin
  if (!hresetn_m) begin
    hwdatam_reg <= {DW{1'b0}};
    hwuserm_reg <= {UW{1'b0}};
  end
  else if (hwdatam_valid) begin
    hwdatam_reg <= hwdata_s;
    hwuserm_reg <= hwuser_s;
  end
end

assign hwdata_m = hwdatam_reg;
assign hwuser_m = hwuserm_reg;


generate
  if (BURST == 1) begin:gen_burst_support

    wire          busy_override;
    wire   [2:0]  hburstm_nxt;
    reg    [2:0]  hburstm_reg;

    assign busy_override = (~transs_hold & hsel_s & ((htrans_s == TRN_BUSY) | (htrans_s == TRN_SEQ)));

    assign htransm_nxt = unlockm_idle_valid ? TRN_IDLE :
                         transm_valid       ? htranss_reg :
                         transm_done        ? htransm_reg :
                         busy_override      ? TRN_BUSY :
                                              TRN_IDLE;


    assign haddrm_nxt = unlockm_idle_valid ? haddrm_reg :
                        transm_valid       ? haddrs_reg :
                        transm_done        ? haddrm_reg :
                        busy_override      ? haddr_s :
                                             haddrm_reg;

    assign hburstm_nxt = transm_valid ? hbursts_reg :
                                        hburstm_reg;



    always @(posedge hclk_m or negedge hresetn_m)
    begin
      if (!hresetn_m)  begin
        hburstm_reg <= 3'h0;
      end
      else if (addr_m_changeable) begin
        hburstm_reg <= hburstm_nxt;
      end
    end

    assign hburst_m = hburstm_reg;

  end

  else begin: gen_burst_not_support

    assign htransm_nxt = unlockm_idle_valid ? TRN_IDLE :
                         transm_valid       ? {htranss_reg[1], 1'b0} :
                                              TRN_IDLE;

    assign haddrm_nxt = transm_valid  ? haddrs_reg :
                                        haddrm_reg;

    assign hburst_m = 3'b000;

  end

endgenerate


assign hmastlockm_nxt = unlockm_idle_valid ? 1'b0 :
                        transm_valid       ? hmastlocks_reg :
                                             hmastlockm_reg;

assign hnonsecm_nxt = transm_valid ? hnonsecs_reg :
                                     hnonsecm_reg;

assign hsizem_nxt = transm_valid ? hsizes_reg :
                                   hsizem_reg;

assign hwritem_nxt = transm_valid ? hwrites_reg :
                                    hwritem_reg;

assign hprotm_nxt = transm_valid ? hprots_reg :
                                   hprotm_reg;

assign hmasterm_nxt = transm_valid ? hmasters_reg :
                                     hmasterm_reg;

assign hexclm_nxt = transm_valid ? hexcls_reg :
                                   1'b0;

assign hauserm_nxt = transm_valid ? hausers_reg :
                                    hauserm_reg;


always @(posedge hclk_m or negedge hresetn_m)
begin
  if (!hresetn_m)  begin
    hnonsecm_reg    <= 1'b0;
    haddrm_reg      <= {AW{1'b0}};
    htransm_reg     <= 2'h0;
    hsizem_reg      <= 3'h0;
    hwritem_reg     <= 1'b0;
    hprotm_reg      <= 7'h0;
    hmasterm_reg    <= {MW{1'b0}};
    hmastlockm_reg  <= 1'b0;
    hexclm_reg      <= 1'b0;
    hauserm_reg     <= {UW{1'b0}};
  end
  else if (addr_m_changeable) begin
    hnonsecm_reg    <= hnonsecm_nxt;
    haddrm_reg      <= haddrm_nxt;
    htransm_reg     <= htransm_nxt;
    hsizem_reg      <= hsizem_nxt;
    hwritem_reg     <= hwritem_nxt;
    hprotm_reg      <= hprotm_nxt;
    hmasterm_reg    <= hmasterm_nxt;
    hmastlockm_reg  <= hmastlockm_nxt;
    hexclm_reg      <= hexclm_nxt;
    hauserm_reg     <= hauserm_nxt;
  end
end


assign hnonsec_m    = hnonsecm_reg;
assign haddr_m      = haddrm_reg;
assign hsize_m      = hsizem_reg;
assign hwrite_m     = hwritem_reg;
assign hprot_m      = hprotm_reg;
assign hmaster_m    = hmasterm_reg;
assign hmastlock_m  = hmastlockm_reg;
assign hexcl_m      = hexclm_reg;
assign hauser_m     = hauserm_reg;



generate
  if (BURST == 1)  begin: gen_with_err_canc

    sie200_ahb5_error_canc
      u_ahb5_to_ahb5_sync_down_err_canc
      (
       .hclk       (hclk_m),
       .hresetn    (hresetn_m),
       .htrans_s   (htransm_reg),
       .hready_m   (hready_m),
       .hresp_m    (hresp_m),
       .hreadyout_s(hreadyoutm_canc),
       .hresp_s    (hrespm_canc),
       .htrans_m   (htrans_m)
      );
  end
   else begin: gen_no_err_canc
     assign  hrespm_canc     = hresp_m;
     assign  hreadyoutm_canc = hready_m;
     assign  htrans_m        = htransm_reg;
   end
endgenerate


always @ *
begin
  master_state_nxt = master_state;
  transm_valid = 1'b0;
  transm_done = 1'b0;
  unlockm_idle_valid = 1'b0;
  hwdatam_valid = 1'b0;
  hrdatam_valid = 1'b0;
  case (master_state)
    FSM_IDLE:
      begin
        unlockm_idle_valid = unlocks_req;
        if (transs_req) begin
          master_state_nxt = unlocks_req ? FSM_UNLOCK : FSM_ADDR;
          transm_valid = ~unlocks_req;
        end
      end

    FSM_UNLOCK:
      begin
        master_state_nxt = FSM_ADDR;
        transm_valid = 1'b1;
      end

    FSM_ADDR:
      begin
        if (hreadyoutm_canc) begin
          master_state_nxt = FSM_WAIT;
          hwdatam_valid = 1'b1;
        end
      end

    FSM_WAIT:
      begin
        if (hrespm_canc) begin
          master_state_nxt = FSM_ERR;
        end
        else if (hreadyoutm_canc) begin
          master_state_nxt = FSM_DONE;
          hrdatam_valid = 1'b1;
        end
      end

    FSM_ERR:
      begin
        if (hreadyoutm_canc) begin
          master_state_nxt = FSM_DONE;
          hrdatam_valid = 1'b1;
        end
      end

    FSM_DONE:
      begin
        master_state_nxt = FSM_IDLE;
        transm_done = 1'b1;
      end

    default:
      begin
        master_state_nxt = 3'bxxx;
        transm_valid = 1'bx;
        transm_done = 1'bx;
        unlockm_idle_valid = 1'bx;
        hwdatam_valid = 1'bx;
        hrdatam_valid = 1'bx;
      end
  endcase
end

always @(posedge hclk_m or negedge hresetn_m)
begin
  if (!hresetn_m) begin
    master_state <= FSM_IDLE;
  end
  else begin
    master_state <= master_state_nxt;
  end
end

always @(posedge hclk_m or negedge hresetn_m)
begin
  if (!hresetn_m) begin
    hrespm_reg <= RESP_OKAY;
    hexokaym_reg <= 1'b0;
    hrdatam_reg <= {DW{1'b0}};
    hruserm_reg <= {UW{1'b0}};
  end
  else if (brg_pwr_req_m) begin
    hrespm_reg <= RESP_OKAY;
    hexokaym_reg <= 1'b0;
    hrdatam_reg <= {DW{1'b0}};
    hruserm_reg <= {UW{1'b0}};
  end
  else if (hrdatam_valid) begin
    hrespm_reg <= hrespm_canc;
    hexokaym_reg <= hexokay_m;
    hrdatam_reg <= hrdata_m;
    hruserm_reg <= hruser_m;
  end
end



endmodule






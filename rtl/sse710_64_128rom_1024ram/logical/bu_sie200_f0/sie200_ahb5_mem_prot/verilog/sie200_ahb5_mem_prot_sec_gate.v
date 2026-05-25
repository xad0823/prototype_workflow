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
//      Checked In          : Fri Jan 27 12:44:51 2017 +0000
//
//      Revision            : 5cdcd55
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_mem_prot_sec_gate #(
  parameter DATA_WIDTH      = 32,
  parameter ADDR_WIDTH      = 18,
  parameter MASTER_WIDTH    = 4,
  parameter USER_WIDTH      = 1,
  parameter BLK_SIZE        = 3,
  parameter GATE_RESP       = 0,
  parameter LUT_ADDR_WIDTH  = 5,
  parameter LUT_DATA_WIDTH  = 32,
  parameter GATE_PRESENT    = 1
)
(
  input  wire                       hclk,
  input  wire                       hresetn,

  input  wire                       hsel_s,
  input  wire                       hnonsec_s,
  input  wire [ADDR_WIDTH-1:0]      haddr_s,
  input  wire [1:0]                 htrans_s,
  input  wire [2:0]                 hsize_s,
  input  wire                       hwrite_s,
  input  wire                       hready_s,
  input  wire [6:0]                 hprot_s,
  input  wire [2:0]                 hburst_s,
  input  wire                       hmastlock_s,
  input  wire [DATA_WIDTH-1:0]      hwdata_s,
  input  wire                       hexcl_s,
  input  wire [MASTER_WIDTH-1:0]    hmaster_s,
  output wire [DATA_WIDTH-1:0]      hrdata_s,
  output wire                       hreadyout_s,
  output wire                       hresp_s,
  output wire                       hexokay_s,
  output wire [USER_WIDTH-1:0]      hruser_s,
  input  wire [USER_WIDTH-1:0]      hauser_s,
  input  wire [USER_WIDTH-1:0]      hwuser_s,

  output wire                       hsel_m,
  output wire [ADDR_WIDTH-1:0]      haddr_m,
  output wire [1:0]                 htrans_m,
  output wire [2:0]                 hsize_m,
  output wire                       hwrite_m,
  output wire                       hready_m,
  output wire [6:0]                 hprot_m,
  output wire [2:0]                 hburst_m,
  output wire                       hmastlock_m,
  output wire [DATA_WIDTH-1:0]      hwdata_m,
  output wire                       hnonsec_m,
  output wire                       hexcl_m,
  output wire [MASTER_WIDTH-1:0]    hmaster_m,
  input  wire                       hreadyout_m,
  input  wire                       hresp_m,
  input  wire [DATA_WIDTH-1:0]      hrdata_m,
  input  wire                       hexokay_m,
  output wire [USER_WIDTH-1:0]      hauser_m,
  output wire [USER_WIDTH-1:0]      hwuser_m,
  input  wire [USER_WIDTH-1:0]      hruser_m,

  output wire [11:0]                lut_addr,
  input  wire [31:0]                lut_data_in,
  input  wire                       lut_valid,
  input  wire                       lut_init_done,
  output wire                       lut_wr_disable,

  input  wire                       cfg_sec_resp,
  input  wire                       gate_req,
  output reg                        gate_ack_reg,
  output reg  [ADDR_WIDTH-1:0]      sec_info_haddr,
  output reg  [MASTER_WIDTH-1:0]    sec_info_hmaster,
  output reg                        sec_info_hnonsec,
  output reg                        sec_info_cfg_ns,
  input  wire                       mpc_irq_clear,
  input  wire                       mpc_irq_set,
  input  wire                       mpc_irq_mask,
  input  wire                       mpc_irq_enable,
  output wire                       mpc_irq_trigd,
  output wire                       mpc_irq

);





localparam  IDLE    = 2'b01,
            HOLD    = 2'b00,
            ERR_1   = 2'b10,
            ERR_2   = 2'b11;


localparam UNUSED_WIDTH            =    1;
wire [UNUSED_WIDTH-1:0]     unused = lut_valid;


wire                        latch_en;
reg                         show_latched;

reg  [ADDR_WIDTH-1:0]       latched_haddr;
reg  [1:0]                  latched_htrans;
reg  [2:0]                  latched_hsize;
reg                         latched_hwrite;
reg  [6:0]                  latched_hprot;
reg  [2:0]                  latched_hburst;
reg                         latched_hmastlock;
reg                         latched_hnonsec;
reg                         latched_hexcl;
reg  [MASTER_WIDTH-1:0]     latched_hmaster;
reg  [USER_WIDTH-1:0]       latched_hauser;

wire [ADDR_WIDTH-1:0]       chk_haddr;
wire                        chk_hnonsec;
wire [MASTER_WIDTH-1:0]     chk_hmaster;

wire                        sec_err;
reg                         latched_sec_err;
wire                        trans_sec_err;

wire                        trans_req;
wire                        burst_blocked;
wire                        burst_blocked_set;
wire                        burst_blocked_clr;
reg                         burst_blocked_reg;

reg  [1:0]                  resp_state;
reg  [1:0]                  next_state;

wire                        gate_ack_set;
wire                        gate_ack;
reg                         gate_ack_block_reg;
wire                        gate_ack_block;
wire                        gate_ack_block_set;

wire                        gate_ctrl;
wire                        gate_hmastlock;
reg                         gate_data;

reg                         lock_ongoing;
wire                        lock_ongoing_set;
wire                        lock_ongoing_clr;

wire [4:0]                  cfg_ns_addr;
wire                        cfg_ns;

wire                        err_hresp;
wire                        err_hreadyout;

reg                         hready_s_d;
wire [1:0]                  htrans_s_masked;
reg                         hreadyout_m_loop;

reg                         mpc_irq_trigd_reg;


function [2:0] lut_dw_log2(input [31:0] dw);
  case (dw)
    32: lut_dw_log2 = 3'h5;
    16: lut_dw_log2 = 3'h4;
    8:  lut_dw_log2 = 3'h3;
    4:  lut_dw_log2 = 3'h2;
    2:  lut_dw_log2 = 3'h1;
    default: lut_dw_log2 = 3'h0;
  endcase
endfunction

generate
if(GATE_PRESENT) begin: GEN_GATING_LOGIC



assign gate_ack_set       = gate_req & hready_s & ~htrans_s[0] & (~lock_ongoing | lock_ongoing_clr | gate_ack_block_reg);
assign gate_ack           = (gate_ack_reg | gate_ack_set) & gate_req;
assign gate_ack_block_set = (gate_ack & trans_req);
assign gate_ack_block     = (gate_ack_block_set | gate_ack_block_reg) & ~(((trans_req & htrans_s == 2'b10) & ~gate_req) | show_latched);


assign chk_haddr    = (resp_state == HOLD) ? latched_haddr    : haddr_s;
assign chk_hnonsec  = (resp_state == HOLD) ? latched_hnonsec  : hnonsec_s;
assign chk_hmaster  = (resp_state == HOLD) ? latched_hmaster  : hmaster_s;

assign trans_sec_err = (trans_req & sec_err) | (show_latched & latched_sec_err);

end
else begin: GEN_NO_GATING_LOGIC

assign gate_ack         = 1'b0;
assign gate_ack_block   = 1'b0;

assign chk_haddr        = haddr_s;
assign chk_hnonsec      = hnonsec_s;
assign chk_hmaster      = hmaster_s;

assign trans_sec_err    = (trans_req & sec_err);

wire   unused_2         = gate_req;

end
endgenerate

always @(posedge hclk or negedge hresetn) begin
  if (~hresetn) begin
    gate_ack_reg        <= 1'b0;
    gate_ack_block_reg  <= 1'b0;
  end
  else begin
    gate_ack_reg        <= gate_ack;
    gate_ack_block_reg  <= gate_ack_block;
  end
end


generate
  if (LUT_ADDR_WIDTH > 0) begin: LUT_ADDR_WIDTH_NOT_0
    assign lut_addr[LUT_ADDR_WIDTH-1:0] = chk_haddr[ADDR_WIDTH-1:BLK_SIZE+10];
    assign cfg_ns_addr  = chk_haddr[BLK_SIZE+9:BLK_SIZE+5];
    assign cfg_ns       = lut_data_in[cfg_ns_addr];

    if(LUT_ADDR_WIDTH < 12) begin: UNUSED_LUT_ADDR
      assign lut_addr[11:LUT_ADDR_WIDTH] = {(12-LUT_ADDR_WIDTH){1'b0}};
    end

  end
  else begin: LUT_ADDR_WIDTH_IS_0
    localparam [2:0] LUT_DATA_WIDTH_L2 = lut_dw_log2(LUT_DATA_WIDTH);
    assign lut_addr                           = 12'h000;
    assign cfg_ns_addr[LUT_DATA_WIDTH_L2-1:0] = chk_haddr[BLK_SIZE + LUT_DATA_WIDTH_L2 + 4:BLK_SIZE+5];
    assign cfg_ns                             = lut_data_in[cfg_ns_addr];

    if(LUT_DATA_WIDTH < 32) begin: UNUSED_LUT_DATA
      assign cfg_ns_addr[4:LUT_DATA_WIDTH_L2] = {(5-LUT_DATA_WIDTH_L2){1'b0}};

      localparam UNUSED_3_WIDTH = 32-LUT_DATA_WIDTH;
      wire [UNUSED_3_WIDTH-1:0] unused_3 = lut_data_in[31:LUT_DATA_WIDTH];
    end
  end

endgenerate




always @(posedge hclk or negedge hresetn) begin
  if (~hresetn) begin
    hready_s_d <= 1'b1;
  end
  else begin
    hready_s_d <= hready_s;
  end
end


assign lut_wr_disable = ((hsel_s & htrans_s[0]) | ~hready_s | (~hready_s_d & (hsel_s & htrans_s[1]))) & ~gate_ack & lut_init_done;


assign sec_err      = (chk_hnonsec ^ cfg_ns) & ~gate_ack & lut_init_done;

assign trans_req    = (hsel_s & htrans_s[1] & hready_s);


always @(posedge hclk or negedge hresetn) begin
  if (~hresetn) begin
    burst_blocked_reg <= 1'b0;
  end
  else begin
    burst_blocked_reg <= (burst_blocked_reg & ~burst_blocked_clr) | burst_blocked_set;
  end
end


assign burst_blocked_set = sec_err & hsel_s & (htrans_s[0] | (htrans_s[1] & hready_s & |hburst_s));
assign burst_blocked_clr = (hsel_s & ~htrans_s[0] & hready_s) | ~hsel_s;
assign burst_blocked     = (burst_blocked_reg & ~burst_blocked_clr);

always @(posedge hclk or negedge hresetn) begin
  if (~hresetn) begin
    lock_ongoing <= 1'b0;
  end
  else begin
    lock_ongoing <= (lock_ongoing_set | lock_ongoing) & ~lock_ongoing_clr;
  end
end

assign lock_ongoing_set = ~lock_ongoing & hmastlock_s & trans_req;
assign lock_ongoing_clr = (hready_s | htrans_s[1]) & (~hsel_s | ~hmastlock_s);



always @(posedge hclk or negedge hresetn) begin
  if (~hresetn) begin
    mpc_irq_trigd_reg  <= 1'b0;
  end
  else begin
    if((trans_sec_err & mpc_irq_enable) | mpc_irq_set) begin
      mpc_irq_trigd_reg <= 1'b1;
    end
    else if(mpc_irq_clear) begin
      mpc_irq_trigd_reg <= 1'b0;
    end
  end
end


always @(posedge hclk or negedge hresetn) begin
  if (~hresetn) begin
    sec_info_haddr        <= {ADDR_WIDTH{1'b0}};
    sec_info_hmaster      <= {MASTER_WIDTH{1'b0}};
    sec_info_cfg_ns       <= 1'b0;
    sec_info_hnonsec      <= 1'b0;
  end
  else begin
    if(((trans_sec_err & mpc_irq_enable) | mpc_irq_set) & (~mpc_irq_trigd_reg | mpc_irq_clear)) begin
      sec_info_haddr      <= chk_haddr;
      sec_info_hmaster    <= chk_hmaster;
      sec_info_cfg_ns     <= cfg_ns;
      sec_info_hnonsec    <= chk_hnonsec;
    end
  end
end

assign mpc_irq_trigd  = mpc_irq_trigd_reg;
assign mpc_irq        = mpc_irq_trigd & ~mpc_irq_mask;


generate

if(GATE_PRESENT) begin: GEN_FSM_WITH_GATING_LOGIC

always @(*) begin
  next_state = resp_state;
  case ( resp_state )
    IDLE,
    ERR_2:  begin
              if (gate_ack_block | ~lut_init_done) begin
                case({GATE_RESP,trans_req})
                  2'b00:    next_state = IDLE;
                  2'b01:    next_state = HOLD;
                  2'b10:    next_state = IDLE;
                  2'b11:    next_state = ERR_1;
                  default:  next_state = 2'bxx;
                endcase
              end
              else if(trans_req & (sec_err | burst_blocked) & cfg_sec_resp) begin
                next_state = ERR_1;
              end
              else begin
                next_state = IDLE;
              end
            end

    HOLD:   begin
              if(~gate_ack_reg & lut_init_done & hready_m) begin
                if (latched_sec_err & cfg_sec_resp) begin
                  next_state = ERR_1;
                end
                else begin
                  next_state = IDLE;
                end
              end
            end

    ERR_1:  begin
              next_state = ERR_2;
            end

    default:begin
              next_state = 2'bxx;
            end
  endcase
end

end
else begin: GEN_FSM_WITHOUT_GATING_LOGIC

always @(*) begin
  next_state = resp_state;
  case ( resp_state )
    IDLE,
    ERR_2:  begin
              if(trans_req & (((sec_err | burst_blocked) & cfg_sec_resp) | ~lut_init_done) ) begin
                next_state = ERR_1;
              end
              else begin
                next_state = IDLE;
              end
            end

    ERR_1:  begin
              next_state = ERR_2;
            end

    default:begin
              next_state = 2'bxx;
            end
  endcase
end

end
endgenerate
always @(posedge hclk or negedge hresetn) begin
  if (~hresetn) begin
    resp_state <= IDLE;
  end
  else begin
    resp_state <= next_state;
  end
end


assign err_hreadyout  = resp_state[0];
assign err_hresp      = resp_state[1];


generate
if (GATE_PRESENT) begin: GEN_HOLD_STAGE
assign latch_en       = ((resp_state == IDLE) || (resp_state == ERR_2)) && (next_state == HOLD);

always @(posedge hclk or negedge hresetn) begin
  if (~hresetn) begin
    latched_haddr         <= {ADDR_WIDTH{1'b0}};
    latched_htrans        <= 2'b10;
    latched_hsize         <= 3'b000;
    latched_hwrite        <= 1'b0;
    latched_hprot         <= 7'h00;
    latched_hburst        <= 3'b000;
    latched_hmastlock     <= 1'b0;
    latched_hnonsec       <= 1'b0;
    latched_hexcl         <= 1'b0;
    latched_hmaster       <= {MASTER_WIDTH{1'b0}};
    latched_hauser        <= {USER_WIDTH{1'b0}};
  end
  else begin
    if(latch_en) begin
      latched_haddr       <= haddr_s;
      latched_htrans      <= htrans_s;
      latched_hsize       <= hsize_s;
      latched_hwrite      <= hwrite_s;
      latched_hprot       <= hprot_s;
      latched_hburst      <= hburst_s;
      latched_hmastlock   <= hmastlock_s;
      latched_hnonsec     <= hnonsec_s;
      latched_hexcl       <= hexcl_s;
      latched_hmaster     <= hmaster_s;
      latched_hauser      <= hauser_s;
    end
  end
end

always @(posedge hclk or negedge hresetn) begin
  if (~hresetn) begin
    show_latched      <= 1'b0;
    latched_sec_err   <= 1'b0;
  end
  else begin
    if ((resp_state == HOLD) & (gate_ack_reg & ~gate_ack & lut_init_done) & hready_m) begin
      show_latched    <= 1'b1;
      latched_sec_err <= sec_err;
    end
    else begin
      show_latched    <= 1'b0;
    end
  end
end



assign gate_ctrl  =((((resp_state == IDLE)  || (resp_state == ERR_2)) && (gate_ack_block || (hsel_s && (htrans_s != 2'b00) && sec_err) || burst_blocked )) ||
                      (resp_state == HOLD)  ||
                      (resp_state == ERR_1));


assign gate_hmastlock = (htrans_s == 2'b10) && hsel_s && ~hready_s && (~lock_ongoing | lock_ongoing_clr) && ~gate_ctrl ;


always @(posedge hclk or negedge hresetn) begin
  if (~hresetn) begin
    gate_data <= 1'b0;
  end
  else begin
    if((resp_state == IDLE) || (resp_state == ERR_2)) begin
      gate_data <= (gate_ack_block || (hsel_s && htrans_s[1] && hready_s && sec_err) || (burst_blocked && hready_s) || (gate_data & ~trans_req));
    end
    else if((resp_state == HOLD) && (next_state == IDLE)) begin
      gate_data <= sec_err;
    end
  end
end

always @(posedge hclk or negedge hresetn) begin
  if (~hresetn) begin
    hreadyout_m_loop <= 1'b0;
  end
  else begin
    if(hready_m) begin
      hreadyout_m_loop <= hsel_m;
    end
  end
end


assign htrans_s_masked = ((htrans_s == 2'b10) && hsel_s && ~hready_s && (~lock_ongoing | lock_ongoing_clr)) ? 2'b00 : htrans_s;

end
else begin: GEN_NO_HOLD_STAGE
assign gate_ctrl  =((((resp_state == IDLE)  || (resp_state == ERR_2)) && ((hsel_s && (htrans_s != 2'b00) && sec_err) || burst_blocked )) ||
                      (resp_state == ERR_1));

always @(posedge hclk or negedge hresetn) begin
  if (~hresetn) begin
    gate_data <= 1'b0;
  end
  else begin
    if((resp_state == IDLE) || (resp_state == ERR_2)) begin
      gate_data <= ((hsel_s && htrans_s[1] && hready_s && sec_err) || (burst_blocked && hready_s) || (gate_data & ~trans_req));
    end
  end
end

always @(posedge hclk or negedge hresetn) begin
  if (~hresetn) begin
    hreadyout_m_loop <= 1'b0;
  end
  else begin
    if(hready_m) begin
      hreadyout_m_loop <= hsel_m;
    end
  end
end

end


if(GATE_PRESENT) begin: GEN_PORT_MUX_WITH_GATING

assign hsel_m       = gate_ack_block ? 1'b1 : show_latched | hsel_s;

assign hready_m     = hreadyout_m_loop ? hreadyout_m : hready_s;

assign haddr_m      = (resp_state == HOLD) ? latched_haddr : haddr_s;
assign hmastlock_m  = gate_hmastlock  ? 1'b0 : (show_latched ? latched_hmastlock  : hmastlock_s);

assign htrans_m     = gate_ctrl ? ( (show_latched & ~latched_sec_err) ? latched_htrans     : 2'b00                 ) : htrans_s_masked;
assign hsize_m      = gate_ctrl ? ( (show_latched & ~latched_sec_err) ? latched_hsize      : 3'b000                ) : hsize_s;
assign hwrite_m     = gate_ctrl ? ( (show_latched & ~latched_sec_err) ? latched_hwrite     : 1'b0                  ) : hwrite_s;
assign hprot_m      = gate_ctrl ? ( (show_latched & ~latched_sec_err) ? latched_hprot      : 7'h00                 ) : hprot_s;
assign hburst_m     = gate_ctrl ? ( (show_latched & ~latched_sec_err) ? latched_hburst     : 3'b000                ) : hburst_s;
assign hnonsec_m    = gate_ctrl ? ( (show_latched & ~latched_sec_err) ? latched_hnonsec    : 1'b0                  ) : hnonsec_s;
assign hexcl_m      = gate_ctrl ? ( (show_latched & ~latched_sec_err) ? latched_hexcl      : 1'b0                  ) : hexcl_s;
assign hmaster_m    = gate_ctrl ? ( (show_latched & ~latched_sec_err) ? latched_hmaster    : {MASTER_WIDTH{1'b0}}  ) : hmaster_s;
assign hauser_m     = gate_ctrl ? ( (show_latched & ~latched_sec_err) ? latched_hauser     : {USER_WIDTH{1'b0}}    ) : hauser_s;


end
else begin: GEN_PORT_MUX_WITHOUT_GATING

assign hsel_m       = hsel_s;

assign hready_m     = hreadyout_m_loop ? hreadyout_m : hready_s;

assign haddr_m      = haddr_s;
assign hmastlock_m  = hmastlock_s;

assign htrans_m     = gate_ctrl ? 2'b00                 : htrans_s;
assign hsize_m      = gate_ctrl ? 3'b000                : hsize_s;
assign hwrite_m     = gate_ctrl ? 1'b0                  : hwrite_s;
assign hprot_m      = gate_ctrl ? 7'h00                 : hprot_s;
assign hburst_m     = gate_ctrl ? 3'b000                : hburst_s;
assign hnonsec_m    = gate_ctrl ? 1'b0                  : hnonsec_s;
assign hexcl_m      = gate_ctrl ? 1'b0                  : hexcl_s;
assign hmaster_m    = gate_ctrl ? {MASTER_WIDTH{1'b0}}  : hmaster_s;
assign hauser_m     = gate_ctrl ? {USER_WIDTH{1'b0}}    : hauser_s;

end

endgenerate

assign hwdata_m     = gate_data ? {DATA_WIDTH{1'b0}}  : hwdata_s;
assign hwuser_m     = gate_data ? {USER_WIDTH{1'b0}}  : hwuser_s;


assign hexokay_s    = gate_data ? 1'b0                : hexokay_m;
assign hreadyout_s  = gate_data ? err_hreadyout       : hreadyout_m;
assign hresp_s      = gate_data ? err_hresp           : hresp_m;
assign hrdata_s     = gate_data ? {DATA_WIDTH{1'b0}}  : hrdata_m;
assign hruser_s     = gate_data ? {USER_WIDTH{1'b0}}  : hruser_m;









endmodule

//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//          (C) COPYRIGHT 2016 ARM Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Thu Dec 1 11:53:45 2016 +0000
//
//      Revision            : 43833a0
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//----------------------------------------------------------------------------

module sie200_ahb5_access_ctrl_hold #(

  parameter                       ADDR_WIDTH    = 32,
  parameter                       DATA_WIDTH    = 32,
  parameter                       MASTER_WIDTH  =  4,
  parameter                       USER_WIDTH    =  1
)
(
  input  wire                     hclk_s,
  input  wire                     hresetn_s,
  input  wire                     hsel_s,
  input  wire                     hnonsec_s,
  input  wire [ADDR_WIDTH-1:0]    haddr_s,
  input  wire [1:0]               htrans_s,
  input  wire [2:0]               hsize_s,
  input  wire                     hwrite_s,
  input  wire                     hready_s,
  input  wire [6:0]               hprot_s,
  input  wire [2:0]               hburst_s,
  input  wire                     hmastlock_s,
  input  wire [DATA_WIDTH-1:0]    hwdata_s,
  input  wire                     hexcl_s,
  input  wire [MASTER_WIDTH-1:0]  hmaster_s,
  output wire                     hreadyout_s,
  output wire                     hresp_s,
  output wire [DATA_WIDTH-1:0]    hrdata_s,
  output wire                     hexokay_s,
  input  wire [USER_WIDTH-1:0]    hauser_s,
  input  wire [USER_WIDTH-1:0]    hwuser_s,
  output wire [USER_WIDTH-1:0]    hruser_s,

  output wire                     hsel_m,
  output wire                     hnonsec_m,
  output wire [ADDR_WIDTH-1:0]    haddr_m,
  output wire [1:0]               htrans_m,
  output wire [2:0]               hsize_m,
  output wire                     hwrite_m,
  output wire                     hready_m,
  output wire [6:0]               hprot_m,
  output wire [2:0]               hburst_m,
  output wire                     hmastlock_m,
  output wire [DATA_WIDTH-1:0]    hwdata_m,
  output wire                     hexcl_m,
  output wire [MASTER_WIDTH-1:0]  hmaster_m,
  input  wire                     hreadyout_m,
  input  wire                     hresp_m,
  input  wire [DATA_WIDTH-1:0]    hrdata_m,
  input  wire                     hexokay_m,
  output wire [USER_WIDTH-1:0]    hauser_m,
  output wire [USER_WIDTH-1:0]    hwuser_m,
  input  wire [USER_WIDTH-1:0]    hruser_m,


  input  wire                     hold_en,
  input  wire                     cfg_gate_resp,
  input  wire                     brg_pwr_req_s,
  output wire                     brg_pwr_ack_s,
  output wire                     pend_trans,
  output wire                     s_active

);


localparam  IDLE = 2'b01,
            HOLD = 2'b00,
            ERR1 = 2'b10,
            ERR2 = 2'b11;



localparam  TRANS_IDLE = 2'b00,
            TRANS_BUSY = 2'b01,
            TRANS_NSEQ = 2'b10,
            TRANS_SEQ  = 2'b11;

wire [1:0]                htrans_s_masked;

reg                       hnonsec_hold;
reg  [ADDR_WIDTH-1:0]     haddr_hold;
reg  [2:0]                hsize_hold;
reg                       hwrite_hold;
reg  [6:0]                hprot_hold;
reg  [2:0]                hburst_hold;
reg                       hmastlock_hold;

reg                       hexcl_hold;
reg  [MASTER_WIDTH-1:0]   hmaster_hold;
reg  [USER_WIDTH-1:0]     hauser_hold;

wire                      hreadyout_int;
wire                      hresp_int;

wire                      trans_req;
reg                       gate_open_addr;
reg                       gate_open_data;
wire                      show_hold;
wire                      hold_new_data;

reg   [1:0]               acg_state;
reg   [1:0]               acg_state_nxt;
reg                       burst_blocked;
wire                      hmastlock_blocked;
reg                       hmastlock_blocked_reg;
reg                       hmastlock_s_d;
reg                       trans_ongoing;


wire                      hsel_iso;
wire                      hnonsec_iso;
wire  [ADDR_WIDTH-1:0]    haddr_iso;
wire  [1:0]               htrans_iso;
wire  [2:0]               hsize_iso;
wire                      hwrite_iso;
wire                      hready_iso;
wire  [6:0]               hprot_iso;
wire  [2:0]               hburst_iso;
wire                      hmastlock_iso;
wire                      hexcl_iso;
wire  [MASTER_WIDTH-1:0]  hmaster_iso;
wire  [USER_WIDTH-1:0]    hauser_iso;



always @ (posedge hclk_s or negedge hresetn_s) begin
  if(~hresetn_s) begin
    hnonsec_hold      <= 1'b0;
    haddr_hold        <= {ADDR_WIDTH{1'b0}};
    hsize_hold        <= 3'b000;
    hwrite_hold       <= 1'b0;
    hprot_hold        <= 7'h00;
    hburst_hold       <= 3'b000;
    hmastlock_hold    <= 1'b0;
    hexcl_hold        <= 1'b0;
    hmaster_hold      <= {MASTER_WIDTH{1'b0}};
    hauser_hold       <= {USER_WIDTH{1'b0}};
  end
  else begin
    if(hold_new_data) begin
      hnonsec_hold    <= hnonsec_s;
      haddr_hold      <= haddr_s;
      hsize_hold      <= hsize_s;
      hwrite_hold     <= hwrite_s;
      hprot_hold      <= hprot_s;
      hburst_hold     <= hburst_s;
      hmastlock_hold  <= hmastlock_s;
      hexcl_hold      <= hexcl_s;
      hmaster_hold    <= hmaster_s;
      hauser_hold     <= hauser_s;
    end
  end
end



always @ (*) begin
  acg_state_nxt = acg_state;

  case(acg_state)
    IDLE: begin
            if(trans_req) begin
              if(hold_en & (htrans_s == TRANS_NSEQ)) begin
                acg_state_nxt = cfg_gate_resp | hmastlock_blocked ? ERR1 : HOLD;
              end
              else if(hmastlock_blocked) begin
                acg_state_nxt = ERR1;
              end
              else if(burst_blocked & (htrans_s == TRANS_SEQ)) begin
                acg_state_nxt = ERR1;
              end
            end
          end
    HOLD: begin
            if(~hold_en) begin
              acg_state_nxt = IDLE;
            end
          end
    ERR1: begin
            acg_state_nxt = ERR2;
          end

    ERR2: begin
            if(trans_req) begin
              if (htrans_s == TRANS_NSEQ) begin
                if(hold_en) begin
                  acg_state_nxt = cfg_gate_resp | hmastlock_blocked ? ERR1 : HOLD;
                end
                else if (hmastlock_blocked) begin
                  acg_state_nxt = ERR1;
                end
                else begin
                  acg_state_nxt = IDLE;
                end
              end
              else begin
                acg_state_nxt = ERR1;
              end
            end
            else begin
              acg_state_nxt = IDLE;
            end
          end

    default : begin
                acg_state_nxt = 2'bxx;
              end
  endcase
end


always @ (posedge hclk_s or negedge hresetn_s) begin
  if(~hresetn_s) begin
    acg_state <= IDLE;
  end
  else begin
    acg_state <= acg_state_nxt;
  end
end


assign hreadyout_int  = acg_state[0],
       hresp_int      = acg_state[1];


always @ (*) begin
  case(acg_state)
    IDLE: begin
            if (hmastlock_blocked) begin
              gate_open_addr  = trans_req & (htrans_s == TRANS_NSEQ) & ~hold_en & ~hmastlock_s;
            end
            else if (burst_blocked) begin
              gate_open_addr  = trans_req & (htrans_s == TRANS_NSEQ) & ~hold_en;
            end
            else if(trans_req) begin
              if(hold_en) begin
                gate_open_addr  = 1'b0;
              end
              else begin
                gate_open_addr  = 1'b1;
              end
            end
            else begin
              gate_open_addr  = 1'b1;
            end
          end
    HOLD: begin
            gate_open_addr    = 1'b0;
          end
    ERR1: begin
            gate_open_addr    = 1'b0;
          end
    ERR2: begin
            if(hsel_s & hready_s & (hold_en | htrans_s[0])) begin
              gate_open_addr  = 1'b0;
            end
            else if (hmastlock_blocked) begin
              gate_open_addr  = trans_req & (htrans_s == TRANS_NSEQ) & ~hold_en & ~hmastlock_s;
            end
            else begin
              gate_open_addr  = 1'b1;
            end
          end
    default : begin
                gate_open_addr  = 1'bx;
              end
  endcase
end

always @ (posedge hclk_s or negedge hresetn_s) begin
  if(~hresetn_s) begin
    burst_blocked <= 1'b0;
  end
  else begin
    if((acg_state_nxt == ERR1) & |hburst_s) begin
      burst_blocked <= 1'b1;
    end
    else if(hsel_s & hready_s & ~htrans_s[0]) begin
      burst_blocked <= 1'b0;
    end
  end
end

always @ (posedge hclk_s or negedge hresetn_s) begin
  if(~hresetn_s) begin
    hmastlock_blocked_reg <= 1'b0;
  end
  else begin
    if((acg_state_nxt == ERR1) & hmastlock_s) begin
      hmastlock_blocked_reg <= 1'b1;
    end
    else if((~hsel_s | ~hmastlock_s) & hready_s) begin
      hmastlock_blocked_reg <= 1'b0;
    end
  end
end

assign hmastlock_blocked = hmastlock_blocked_reg & ~((~hsel_s | ~hmastlock_s) & hready_s);



always @ (posedge hclk_s or negedge hresetn_s) begin
  if(~hresetn_s) begin
    gate_open_data <= 1'b0;
  end
  else begin
    if(acg_state_nxt == IDLE) begin
      if(show_hold) begin
        gate_open_data <= 1'b1;
      end
      else begin
        gate_open_data <= (gate_open_addr & trans_req) | (gate_open_data & ~(~hsel_s & hready_s) & ~brg_pwr_req_s);
      end
    end
    else begin
      gate_open_data <= 1'b0;
    end
  end
end



always @(posedge hclk_s or negedge hresetn_s) begin
  if (~hresetn_s) begin
    hmastlock_s_d  <= 1'b0;
  end
  else begin
    if((trans_req & (htrans_s == TRANS_NSEQ) & hmastlock_s & gate_open_addr) | (show_hold & hmastlock_hold)) begin
      hmastlock_s_d  <= 1'b1;
    end
    else if ((~hsel_s | ~hmastlock_s) & hready_s) begin
      hmastlock_s_d  <= 1'b0;
    end
  end
end

always @(posedge hclk_s or negedge hresetn_s) begin
  if (~hresetn_s) begin
    trans_ongoing  <= 1'b0;
  end
  else begin
    if(trans_req & (htrans_s == TRANS_NSEQ) & ~(hold_en & cfg_gate_resp) & ~hmastlock_blocked) begin
      trans_ongoing  <= 1'b1;
    end
    else if (hready_s & (~hsel_s |
                        (hsel_s & (htrans_s == TRANS_IDLE) & (~hmastlock_s | ~hmastlock_s_d)) |
                        (hsel_s & (htrans_s == TRANS_NSEQ) & hold_en & cfg_gate_resp)
                        )) begin
      trans_ongoing  <= 1'b0;
    end
  end
end

reg hreadyout_m_loop;

always @(posedge hclk_s or negedge hresetn_s) begin
  if (~hresetn_s) begin
    hreadyout_m_loop  <= 1'b0;
  end
  else begin
    if(hready_m) begin
      hreadyout_m_loop  <= hsel_m | ~gate_open_addr;
    end
  end
end

reg brg_pwr_req_block_reg;
wire brg_pwr_req_block;
wire brg_pwr_req_block_clr;
reg brg_pwr_ack_reg;

always @(posedge hclk_s or negedge hresetn_s) begin
  if (~hresetn_s) begin
    brg_pwr_req_block_reg   <= 1'b1;
    brg_pwr_ack_reg         <= 1'b1;
  end
  else begin
    brg_pwr_req_block_reg   <= brg_pwr_req_block;
    brg_pwr_ack_reg         <= brg_pwr_req_s;
  end
end

assign brg_pwr_req_block_clr = (((htrans_s == TRANS_NSEQ) & hsel_s) | show_hold) & ~brg_pwr_req_s;
assign brg_pwr_req_block = (brg_pwr_req_s | brg_pwr_req_block_reg) & ~brg_pwr_req_block_clr;

assign trans_req      = htrans_s[1] & hsel_s & hready_s;

assign hold_new_data  = (acg_state != HOLD) & (acg_state_nxt == HOLD);
assign show_hold      = (acg_state == HOLD) & ~hold_en;



assign htrans_s_masked = (((htrans_s == TRANS_NSEQ) & hsel_s & ~hready_s ) | brg_pwr_req_block) ? TRANS_IDLE : htrans_s;


assign  hsel_iso        = (gate_open_addr ? hsel_s           : 1'b1),
        htrans_iso      = (gate_open_addr ? htrans_s_masked  : show_hold ? TRANS_NSEQ : TRANS_IDLE),
        hready_iso      = (hreadyout_m_loop ? hreadyout_m    : hready_s),
        hnonsec_iso     = (gate_open_addr ? hnonsec_s        : hnonsec_hold),
        haddr_iso       = (gate_open_addr ? haddr_s          : haddr_hold),
        hsize_iso       = (gate_open_addr ? hsize_s          : hsize_hold),
        hwrite_iso      = (gate_open_addr ? hwrite_s         : hwrite_hold),
        hprot_iso       = (gate_open_addr ? hprot_s          : hprot_hold),
        hburst_iso      = (gate_open_addr ? hburst_s         : hburst_hold),
        hmastlock_iso   = (gate_open_addr ? hmastlock_s      : show_hold ? hmastlock_hold : 1'b0),
        hexcl_iso       = (gate_open_addr ? hexcl_s          : hexcl_hold),
        hmaster_iso     = (gate_open_addr ? hmaster_s        : hmaster_hold),
        hauser_iso      = (gate_open_addr ? hauser_s         : hauser_hold);


sie200_or   u_mux_iso_hready      (.in_a( brg_pwr_req_s), .in_b(hready_iso    ),   .out_y(hready_m      ));
sie200_and  u_mux_iso_hsel        (.in_a(~brg_pwr_req_s), .in_b(hsel_iso      ),   .out_y(hsel_m        ));
sie200_and  u_mux_iso_hnonsec     (.in_a(~brg_pwr_req_s), .in_b(hnonsec_iso   ),   .out_y(hnonsec_m     ));
sie200_and  u_mux_iso_hwrite      (.in_a(~brg_pwr_req_s), .in_b(hwrite_iso    ),   .out_y(hwrite_m      ));
sie200_and  u_mux_iso_hmastlock   (.in_a(~brg_pwr_req_s), .in_b(hmastlock_iso ),   .out_y(hmastlock_m   ));
sie200_and  u_mux_iso_hexcl       (.in_a(~brg_pwr_req_s), .in_b(hexcl_iso ),       .out_y(hexcl_m       ));

sie200_and #(.DATA_WIDTH(2))            u_mux_iso_htrans  ( .in_a(~{2{brg_pwr_req_s}}),           .in_b(htrans_iso  ), .out_y(htrans_m  ));
sie200_and #(.DATA_WIDTH(ADDR_WIDTH))   u_mux_iso_haddr   ( .in_a(~{ADDR_WIDTH{brg_pwr_req_s}}),  .in_b(haddr_iso   ), .out_y(haddr_m   ));
sie200_and #(.DATA_WIDTH(3))            u_mux_iso_hsize   ( .in_a(~{3{brg_pwr_req_s}}),           .in_b(hsize_iso   ), .out_y(hsize_m   ));
sie200_and #(.DATA_WIDTH(7))            u_mux_iso_hprot   ( .in_a(~{7{brg_pwr_req_s}}),           .in_b(hprot_iso   ), .out_y(hprot_m   ));
sie200_and #(.DATA_WIDTH(3))            u_mux_iso_hburst  ( .in_a(~{3{brg_pwr_req_s}}),           .in_b(hburst_iso  ), .out_y(hburst_m  ));
sie200_and #(.DATA_WIDTH(MASTER_WIDTH)) u_mux_iso_hmaster ( .in_a(~{MASTER_WIDTH{brg_pwr_req_s}}),.in_b(hmaster_iso ), .out_y(hmaster_m ));
sie200_and #(.DATA_WIDTH(USER_WIDTH))   u_mux_iso_hauser  ( .in_a(~{USER_WIDTH{brg_pwr_req_s}}),  .in_b(hauser_iso  ), .out_y(hauser_m  ));



assign  hwdata_m      = gate_open_data ? hwdata_s         : {DATA_WIDTH{1'b0}},
        hwuser_m      = gate_open_data ? hwuser_s         : {USER_WIDTH{1'b0}};

assign  hreadyout_s   = gate_open_data ? hreadyout_m      : hreadyout_int,
        hresp_s       = gate_open_data ? ~brg_pwr_req_s & hresp_m : hresp_int,
        hexokay_s     = gate_open_data ? hexokay_m        : 1'b0,
        hrdata_s      = gate_open_data ? hrdata_m         : {DATA_WIDTH{1'b0}},
        hruser_s      = gate_open_data ? hruser_m         : {USER_WIDTH{1'b0}};



assign  pend_trans    = trans_ongoing & ~(hready_s & (~hsel_s | (~htrans_s[0] & (~hmastlock_s | ~hmastlock_s_d))));


assign  s_active      = (trans_req & (htrans_s == TRANS_NSEQ) & ~(hold_en & cfg_gate_resp) & ~hmastlock_blocked) | pend_trans;

assign  brg_pwr_ack_s = brg_pwr_req_s & brg_pwr_ack_reg;








endmodule

// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2015-2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Fri Sep 16 18:23:36 2016 +0200
//
//      Revision            : c4b897b
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------
module sie200_ahb5_to_apb_async_core_s #(
  parameter     ADDR_WIDTH   = 32,
  parameter     MASTER_WIDTH = 4)
 (
  input  wire                    hclk,
  input  wire                    hresetn,

  input  wire                    hsel,
  input  wire [ADDR_WIDTH-1:0]   haddr,
  input  wire            [1:0]   htrans,
  input  wire                    hwrite,
  input  wire            [2:0]   hsize,
  input  wire            [6:0]   hprot,
  input  wire                    hready,
  input  wire          [31:0]    hwdata,

  input  wire [MASTER_WIDTH-1:0] hmaster,
  input  wire                    hnonsec,

  output wire                    hreadyout,
  output wire          [31:0]    hrdata,
  output wire                    hresp,

  output wire [ADDR_WIDTH-3:0]   s_addr,
  output wire                    s_trans_valid,
  output wire                    s_write,
  output wire            [2:0]   s_prot,
  output wire            [3:0]   s_strb,
  output wire [MASTER_WIDTH-1:0] s_master,

  output wire           [31:0]   s_wdata,

  input  wire           [31:0]   s_rdata,
  input  wire                    s_resp,

  output wire                    s_req_h,
  input  wire                    s_ack_h,

  input  wire                    cfg_gate_resp,
  input  wire                    s_hold_en,
  output wire                    s_pend_trans,
  output wire                    s_active,
  input  wire                    brg_pwr_req_s,
  output wire                    brg_pwr_ack_s
  );


  wire [3:0]   pstrb_nxt;
  wire [2:0]   pprot_nxt;
  wire [MASTER_WIDTH-1:0] hmaster_nxt;

  wire       s_idle;
  wire       sample_addr_phase;
  wire       sample_wdata_phase;
  wire       nxt_trans_valid;

  wire [6:0] unused = {hprot[6:2],hsize[2],htrans[0]};

  reg  [2:0] curr_state;
  reg  [2:0] next_state;
  localparam FSM_IDLE    = 3'h0;
  localparam FSM_DONE    = 3'h1;
  localparam FSM_HOLD    = 3'h2;
  localparam FSM_REJECT0 = 3'h3;
  localparam FSM_REJECT1 = 3'h4;
  localparam FSM_WR      = 3'h5;
  localparam FSM_WAIT    = 3'h6;

  wire reg_s_req_h;
  wire reg_s_req_h_en;
  wire reg_s_req_h_nxt;
  reg  s_resp_reg;

  reg  toggle_req;
  wire trans_done;

  reg  reg_hresp;
  wire err_detect;

  wire s_write_i;


  assign  sample_addr_phase = hsel & htrans[1] & hready;

  sie200_launch_en #( .DATA_WIDTH(ADDR_WIDTH-2) ) u_addr_s (     .clk(hclk), .reset_n(hresetn), .en(sample_addr_phase), .d(haddr[ADDR_WIDTH-1:2]), .q(s_addr   ) );

  sie200_flop_en   #( .DATA_WIDTH(           1) ) u_write_s (    .clk(hclk), .reset_n(hresetn), .en(sample_addr_phase), .d(hwrite),                .q(s_write_i  )  );
  assign s_write = s_write_i;

  assign pprot_nxt[0] =  hprot[1];
  assign pprot_nxt[1] =  hnonsec;
  assign pprot_nxt[2] = ~hprot[0];

  assign pstrb_nxt[0] = hwrite & (hsize[1]|((hsize[0])&(~haddr[1]))|(haddr[1:0]==2'b00));
  assign pstrb_nxt[1] = hwrite & (hsize[1]|((hsize[0])&(~haddr[1]))|(haddr[1:0]==2'b01));
  assign pstrb_nxt[2] = hwrite & (hsize[1]|((hsize[0])&( haddr[1]))|(haddr[1:0]==2'b10));
  assign pstrb_nxt[3] = hwrite & (hsize[1]|((hsize[0])&( haddr[1]))|(haddr[1:0]==2'b11));

  assign hmaster_nxt = hmaster;

  sie200_launch_en #( .DATA_WIDTH(           3) ) u_pprot_s (    .clk(hclk), .reset_n(hresetn), .en(sample_addr_phase), .d(pprot_nxt),     .q(s_prot  )  );
  sie200_launch_en #( .DATA_WIDTH(           4) ) u_pstrb_s (    .clk(hclk), .reset_n(hresetn), .en(sample_addr_phase), .d(pstrb_nxt),     .q(s_strb  )  );
  sie200_launch_en #( .DATA_WIDTH(MASTER_WIDTH) ) u_hmaster_s (  .clk(hclk), .reset_n(hresetn), .en(sample_addr_phase), .d(hmaster_nxt),   .q(s_master)  );

  assign nxt_trans_valid = (next_state == FSM_WAIT);

  sie200_launch #( .DATA_WIDTH(           1) ) u_trans_valid_s (     .clk(hclk), .reset_n(hresetn), .d(nxt_trans_valid),       .q(s_trans_valid  )  );

  assign  sample_wdata_phase = (curr_state == FSM_WR);

  sie200_launch_en #( .DATA_WIDTH(          32) ) u_wdata_s (   .clk(hclk), .reset_n(hresetn), .en(sample_wdata_phase), .d(hwdata),        .q(s_wdata  ) );


  assign s_idle = ((~htrans[0] | ~hsel) & ((curr_state == FSM_IDLE) | ((curr_state == FSM_DONE) & ~s_resp_reg))) |
                  (curr_state == FSM_REJECT0) | (curr_state == FSM_REJECT1);

  assign s_pend_trans = ~s_idle;

  assign s_active = ((next_state != FSM_IDLE) & (next_state != FSM_REJECT0) & (next_state != FSM_REJECT1)) | s_pend_trans;

  assign brg_pwr_ack_s = ~s_ack_h & brg_pwr_req_s;

  always @*
  begin
    next_state = curr_state;
    toggle_req = 1'b0;
    case (curr_state)
      FSM_IDLE, FSM_DONE:
        begin
          if (sample_addr_phase) begin
            if (s_hold_en) begin
              next_state = cfg_gate_resp ? FSM_REJECT0 : FSM_HOLD;
            end
            else if (hwrite) begin
              next_state = FSM_WR;
            end
            else begin
              next_state = FSM_WAIT;
              toggle_req = 1'b1;
            end
          end
          else begin
            next_state = FSM_IDLE;
          end
        end

      FSM_HOLD:
        begin
          next_state =   s_hold_en ? FSM_HOLD :
                         s_write_i ? FSM_WR :
                                     FSM_WAIT;
          toggle_req = ~s_hold_en & ~s_write_i;
        end

      FSM_REJECT0:
        begin
          next_state = FSM_REJECT1;
        end

      FSM_REJECT1:
        begin
          if (sample_addr_phase) begin
            if (!htrans[0]) begin
              if (!s_hold_en || !cfg_gate_resp) begin
                next_state = FSM_HOLD;
              end
              else begin
                next_state = FSM_REJECT0;
              end
            end
            else begin
              next_state = FSM_REJECT0;
            end
          end
        end

      FSM_WR:
        begin
          next_state = FSM_WAIT;
          toggle_req = 1'b1;
        end

      FSM_WAIT:
        begin
          next_state = (trans_done) ? FSM_DONE : FSM_WAIT;
        end

      default:
        begin
          next_state = 3'bxxx;
          toggle_req = 1'bx;
        end
    endcase
  end


  always @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn) begin
      curr_state <= FSM_IDLE;
    end
    else begin
      curr_state <= next_state;
    end
  end

  always @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn) begin
      s_resp_reg <= 1'b0;
    end
    else if (trans_done) begin
      s_resp_reg <= s_resp;
    end
  end

  assign reg_s_req_h_en  = brg_pwr_req_s || toggle_req;
  assign reg_s_req_h_nxt = ~reg_s_req_h && ~brg_pwr_req_s;

  sie200_flop_en #( .DATA_WIDTH(   1) ) u_s_req_h_s (     .clk(hclk), .reset_n(hresetn), .en(reg_s_req_h_en), .d(reg_s_req_h_nxt), .q(reg_s_req_h)  );

  assign s_req_h = reg_s_req_h;

  assign trans_done = (reg_s_req_h == s_ack_h);

  assign hrdata = s_rdata;

  assign hreadyout = ((curr_state == FSM_IDLE) | ((curr_state == FSM_DONE) & ~s_resp_reg) |
                      (curr_state == FSM_REJECT1));

  assign err_detect = ((curr_state == FSM_DONE) & s_resp_reg) | (curr_state == FSM_REJECT0);

  always @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn) begin
      reg_hresp <= 1'b0;
    end
    else if ((curr_state == FSM_IDLE) | (curr_state == FSM_REJECT1) | err_detect) begin
      reg_hresp <= err_detect;
    end
  end
  assign hresp = reg_hresp | err_detect ;























endmodule



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
//      Checked In          : Wed Nov 2 18:02:43 2016 +0100
//
//      Revision            : 4774679
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------
module sie200_ahb5_to_apb_async_core_m #(
  parameter     ADDR_WIDTH   = 32,
  parameter     MASTER_WIDTH =  4
  )
 (

  input  wire                  pclk,
  input  wire                  presetn,

  input  wire                  s_req_p,
  output wire                  s_ack_p,

  input  wire [ADDR_WIDTH-3:0] s_addr,
  input  wire                  s_trans_valid,
  input  wire            [2:0] s_prot,
  input  wire            [3:0] s_strb,
  input  wire                  s_write,
  input  wire           [31:0] s_wdata,
  input  wire [MASTER_WIDTH-1:0] s_master,

  output wire           [31:0] s_rdata,
  output wire                  s_resp,

  output wire [ADDR_WIDTH-1:0] paddr,
  output wire                  penable,
  output wire                  pwrite,
  output wire           [3:0]  pstrb,
  output wire           [2:0]  pprot,
  output wire          [31:0]  pwdata,
  output wire                  psel,
  output wire [MASTER_WIDTH-1:0] pmaster,

  input  wire          [31:0]  prdata,
  input  wire                  pready,
  input  wire                  pslverr,

  input  wire                  brg_pwr_req_m,
  output wire                  brg_pwr_ack_m,

  output wire                  apb_active);

  reg                    last_s_req_p;
  wire                   reg_s_ack_p;
  reg                    nxt_s_ack_p;

  localparam FSM_APB_IDLE = 2'b00;
  localparam FSM_APB_CYC1 = 2'b01;
  localparam FSM_APB_WAIT = 2'b11;

  localparam ARW = ADDR_WIDTH-2;

  reg              [1:0] curr_state;
  reg              [1:0] next_state;

  wire                   req_detect;
  wire                   trans_done;

  reg                    s_write_reg;
  reg                    s_trans_valid_reg;

  wire         [ARW-1:0] s_addr_gated;

  wire                   reg_rdata_en;
  wire            [31:0] reg_rdata_nxt;

  wire                   reg_resp_nxt;


  always @(posedge pclk or negedge presetn)
  begin
  if (~presetn)
    last_s_req_p <= 1'b0;
  else
    last_s_req_p <= s_req_p;
  end

  always @(posedge pclk or negedge presetn)
  begin
  if (~presetn)
    s_trans_valid_reg <= 1'b0;
  else if (req_detect)
    s_trans_valid_reg <= s_trans_valid;
  end

  assign req_detect = (s_req_p != last_s_req_p);
  assign trans_done = (curr_state==FSM_APB_WAIT) & pready;

  always @(curr_state or req_detect or pready or s_trans_valid_reg)
  begin
    case (curr_state)
      FSM_APB_IDLE :
        begin
        if  (req_detect)
          next_state = FSM_APB_CYC1;
        else
          next_state = FSM_APB_IDLE;
        end
      FSM_APB_CYC1 :
        next_state = (s_trans_valid_reg) ? FSM_APB_WAIT : FSM_APB_IDLE;
      FSM_APB_WAIT :
        begin
        if (pready)
          next_state = FSM_APB_IDLE;
        else
          next_state = FSM_APB_WAIT;
        end
      default:
        next_state = 2'bxx;
    endcase
  end

  always @(posedge pclk or negedge presetn)
  begin
  if (~presetn)
    curr_state <= FSM_APB_IDLE;
  else
    curr_state <= next_state;
  end


  assign reg_rdata_en  = brg_pwr_req_m || trans_done;
  assign reg_rdata_nxt = prdata & {32{~brg_pwr_req_m}};

  assign reg_resp_nxt  = pslverr & ~brg_pwr_req_m;

  sie200_launch_en #( .DATA_WIDTH(          32) ) u_wdata_s (   .clk(pclk), .reset_n(presetn), .en(reg_rdata_en), .d(reg_rdata_nxt),        .q(s_rdata  ) );

  sie200_launch_en #( .DATA_WIDTH(           1) ) u_resp_s  (   .clk(pclk), .reset_n(presetn), .en(reg_rdata_en), .d(reg_resp_nxt),        .q(s_resp  ) );


  always @(curr_state or pready or s_req_p or reg_s_ack_p or brg_pwr_req_m)
  begin
    if (brg_pwr_req_m) begin
      nxt_s_ack_p = 1'b0;
    end
    else if ((curr_state==FSM_APB_WAIT) & pready) begin
      nxt_s_ack_p = s_req_p;
    end
    else begin
      nxt_s_ack_p = reg_s_ack_p;
    end
  end

  sie200_flop #( .DATA_WIDTH(   1) ) u_s_ack_p_s (     .clk(pclk), .reset_n(presetn), .d(nxt_s_ack_p), .q(reg_s_ack_p)  );

  assign s_ack_p    = reg_s_ack_p;

  assign brg_pwr_ack_m = ~s_req_p & brg_pwr_req_m;

  always @(posedge pclk or negedge presetn)
  begin
  if (~presetn)
    s_write_reg <= 1'b0;
  else if (req_detect)
    s_write_reg <= s_write;
  end

  assign apb_active = req_detect | curr_state[0];




   assign penable = curr_state[1] ;

   sie200_and #(.DATA_WIDTH (1))   u_and_psel   (.in_a (curr_state[0]),        .in_b (s_trans_valid_reg), .out_y(psel));
   sie200_and #(.DATA_WIDTH (1))   u_and_pwrite (.in_a (curr_state[0]),        .in_b (s_write_reg),       .out_y(pwrite));
   sie200_and #(.DATA_WIDTH (3))   u_and_pprot  (.in_a ({3{curr_state[0]}}),   .in_b (s_prot),            .out_y(pprot));
   sie200_and #(.DATA_WIDTH (4))   u_and_pstrb  (.in_a ({4{curr_state[0]}}),   .in_b (s_strb),            .out_y(pstrb));
   sie200_and #(.DATA_WIDTH (32))  u_and_pwdata (.in_a ({32{curr_state[0]}}),  .in_b (s_wdata),           .out_y(pwdata));

   sie200_and #(.DATA_WIDTH (ARW)) u_and_paddr  (.in_a ({ARW{curr_state[0]}}), .in_b (s_addr),            .out_y(s_addr_gated));
   assign paddr = {s_addr_gated, 2'b00};

   sie200_and #(.DATA_WIDTH (MASTER_WIDTH)) u_and_pmaster (.in_a ({MASTER_WIDTH{curr_state[0]}}), .in_b (s_master),  .out_y(pmaster));






















endmodule



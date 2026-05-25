//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2010-2014, 2016-2017 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Top level of css600_atbreplicator
//
//----------------------------------------------------------------------------


module css600_atbreplicator #(parameter
  ATB_DATA_WIDTH = 32
)
(
  clk,
  reset_n,


  atwakeup_s,
  atvalid_s,
  atid_s,

  atbytes_s,
  atdata_s,
  afready_s,
  atready_m,
  afvalid_m,
  syncreq_m,

  atready_s,
  afvalid_s,
  atwakeup_m,
  atvalid_m,
  atid_m,

  atbytes_m,
  atdata_m,

  afready_m,
  syncreq_s,
  clk_qactive
);

function integer atb_clog2 (input integer num);
  integer i;
  begin
    atb_clog2 = 0;
    for(i=num; i>1; i=i>>1)
      atb_clog2 = atb_clog2 + 1;
  end
endfunction

  localparam ATB_DATA_WIDTH_LOC =  (
                                      (ATB_DATA_WIDTH ==  8)  ||
                                      (ATB_DATA_WIDTH == 16)  ||
                                      (ATB_DATA_WIDTH == 32)  ||
                                      (ATB_DATA_WIDTH == 64)  ||
                                      (ATB_DATA_WIDTH == 128)
                                    ) ? ATB_DATA_WIDTH : 32;

  localparam ATBYTES_WIDTH = (ATB_DATA_WIDTH_LOC > 8) ? (atb_clog2(ATB_DATA_WIDTH_LOC)-4) : 0;

  localparam CSR_F_IDLE       = 3'b000;
  localparam CSR_F_REQ_0      = 3'b001;
  localparam CSR_F_REQ_1      = 3'b010;
  localparam CSR_F_REQ_01     = 3'b011;
  localparam CSR_F_REQ_10     = 3'b100;
  localparam CSR_F_REQ_A      = 3'b101;
  localparam CSR_F_REQ_U0     = 3'b110;
  localparam CSR_F_REQ_U1     = 3'b111;
  localparam CSR_F_UNDEF      = 3'bXXX;

  localparam CSR_T_UNDEF      = 2'bXX;
  localparam CSR_T_IDLE       = 2'b00;
  localparam CSR_T_PEND_A     = 2'b01;
  localparam CSR_T_PEND_0     = 2'b10;
  localparam CSR_T_PEND_1     = 2'b11;

  input wire         clk;
  input wire         reset_n;

  input wire         atwakeup_s;
  input wire         atvalid_s;
  input wire   [6:0] atid_s;

  input wire  [ATBYTES_WIDTH:0]         atbytes_s;
  input wire  [ATB_DATA_WIDTH_LOC-1:0]  atdata_s;
  input wire         afready_s;
  input wire  [1:0]  atready_m;
  input wire  [1:0]  afvalid_m;
  input wire  [1:0]  syncreq_m;
  output wire        atready_s;
  output wire        afvalid_s;
  output reg  [1:0]  atwakeup_m;
  output wire [1:0]  atvalid_m;
  output wire [13:0] atid_m;

  output wire [2*ATBYTES_WIDTH+1:0] atbytes_m;
  output wire [2*ATB_DATA_WIDTH_LOC-1:0] atdata_m;

  output wire [1:0]  afready_m;
  output reg         syncreq_s;
  output wire        clk_qactive;


  wire atreadym0_mod;
  wire atreadym1_mod;

  reg [2:0] flush_state;
  reg [2:0] nxt_flush_state;
  reg [1:0] transfer_state;
  reg [1:0] nxt_transfer_state;
  wire      nxt_syncreqs;
  wire      sync_flag_m0_we;
  wire      sync_flag_m1_we;
  reg       sync_req_m0_reg;
  reg       sync_req_m1_reg;
  reg       sync_flag_m0;
  reg       sync_flag_m1;
  reg       rst_state;


  assign atid_m[6:0]                                          = atid_s;
  assign atid_m[13:7]                                         = atid_s;
  assign atbytes_m[ATBYTES_WIDTH:0]                           = atbytes_s;
  assign atbytes_m[2*ATBYTES_WIDTH+1:ATBYTES_WIDTH+1]         = atbytes_s;
  assign atdata_m[ATB_DATA_WIDTH_LOC-1:0]                     = atdata_s;
  assign atdata_m[2*ATB_DATA_WIDTH_LOC-1:ATB_DATA_WIDTH_LOC]  = atdata_s;


  assign atreadym0_mod = atready_m[0];
  assign atreadym1_mod = atready_m[1];


  always @(posedge clk or negedge reset_n)
  begin : atwakeup_flop
    if (!reset_n)
      atwakeup_m <= 2'b0;
    else
      atwakeup_m <= {atwakeup_s, atwakeup_s};
  end

  always @ *
  begin : p_transfer_fsm_comb
    case (transfer_state)
      CSR_T_IDLE :
        if (atvalid_s)
          begin
            case ({atreadym0_mod,atreadym1_mod})
              2'b00 : nxt_transfer_state = CSR_T_PEND_A;
              2'b01 : nxt_transfer_state = CSR_T_PEND_0;
              2'b10 : nxt_transfer_state = CSR_T_PEND_1;
              2'b11 : nxt_transfer_state = CSR_T_IDLE;
              default : nxt_transfer_state = CSR_T_UNDEF;
            endcase
          end
        else nxt_transfer_state = CSR_T_IDLE;
      CSR_T_PEND_0 :
        nxt_transfer_state = atready_m[0] ? CSR_T_IDLE : CSR_T_PEND_0;
      CSR_T_PEND_1 :
        nxt_transfer_state = atready_m[1] ? CSR_T_IDLE : CSR_T_PEND_1;
      CSR_T_PEND_A :
        case ({atready_m[0],atready_m[1]})
          2'b00 : nxt_transfer_state = CSR_T_PEND_A;
          2'b01 : nxt_transfer_state = CSR_T_PEND_0;
          2'b10 : nxt_transfer_state = CSR_T_PEND_1;
          2'b11 : nxt_transfer_state = CSR_T_IDLE;
          default : nxt_transfer_state = CSR_T_UNDEF;
        endcase
      default : nxt_transfer_state = CSR_T_UNDEF;
    endcase
  end

  always @(posedge clk or negedge reset_n)
  begin : p_transfer_fsm_seq
    if (!reset_n)
      transfer_state <= CSR_T_IDLE;
    else
      transfer_state <= nxt_transfer_state;
  end


  assign atready_s = (nxt_transfer_state == CSR_T_IDLE) & ~rst_state;


  assign atvalid_m[0] = atvalid_s &
                       ((transfer_state == CSR_T_PEND_0) |
                        (transfer_state == CSR_T_PEND_A) |
                        (transfer_state == CSR_T_IDLE));


  assign atvalid_m[1] = atvalid_s &
                       ((transfer_state == CSR_T_PEND_1) |
                        (transfer_state == CSR_T_PEND_A) |
                        (transfer_state == CSR_T_IDLE));


  always @ *
  begin : p_flush_fsm_comb
    case (flush_state)
      CSR_F_IDLE :
        case ({afvalid_m[0],afvalid_m[1]})
          2'b00 : nxt_flush_state = CSR_F_IDLE;
          2'b01 : nxt_flush_state = CSR_F_REQ_1;
          2'b10 : nxt_flush_state = CSR_F_REQ_0;
          2'b11 : nxt_flush_state = CSR_F_REQ_A;
          default : nxt_flush_state = CSR_F_UNDEF;
        endcase
      CSR_F_REQ_0 :
        case ({afready_s,afvalid_m[1]})
          2'b00 : nxt_flush_state = CSR_F_REQ_0;
          2'b01 : nxt_flush_state = CSR_F_REQ_01;
          2'b10 : nxt_flush_state = CSR_F_IDLE;
          2'b11 : nxt_flush_state = CSR_F_REQ_1;
          default : nxt_flush_state = CSR_F_UNDEF;
        endcase
      CSR_F_REQ_1 :
        case ({afready_s,afvalid_m[0]})
          2'b00 : nxt_flush_state = CSR_F_REQ_1;
          2'b01 : nxt_flush_state = CSR_F_REQ_10;
          2'b10 : nxt_flush_state = CSR_F_IDLE;
          2'b11 : nxt_flush_state = CSR_F_REQ_0;
          default : nxt_flush_state = CSR_F_UNDEF;
        endcase
      CSR_F_REQ_01 : nxt_flush_state = afready_s ? CSR_F_REQ_1 : CSR_F_REQ_01;
      CSR_F_REQ_10 : nxt_flush_state = afready_s ? CSR_F_REQ_0 : CSR_F_REQ_10;
      CSR_F_REQ_A : nxt_flush_state = afready_s ? CSR_F_IDLE : CSR_F_REQ_A;
      default : nxt_flush_state = CSR_F_UNDEF;
    endcase
  end


  always @(posedge clk or negedge reset_n)
  begin : p_flush_fsm_seq
    if (!reset_n)
      flush_state <= CSR_F_IDLE;
    else
      flush_state <= nxt_flush_state;
  end

  assign afvalid_s = (flush_state != CSR_F_IDLE);


  always @(posedge clk or negedge reset_n)
  begin : p_rst_state
    if (!reset_n)
      rst_state <= 1'b1;
    else
      rst_state <= 1'b0;
  end

  assign afready_m[0] = rst_state |
                     (
                      (flush_state == CSR_F_REQ_0)  |
                      (flush_state == CSR_F_REQ_01) |
                      (flush_state == CSR_F_REQ_A)
                     ) & afready_s;

  assign afready_m[1] = rst_state |
                     (
                      (flush_state == CSR_F_REQ_1)  |
                      (flush_state == CSR_F_REQ_10) |
                      (flush_state == CSR_F_REQ_A)
                     ) & afready_s;


  always @(posedge clk or negedge reset_n)
  begin : p_sync_req_seq
    if (!reset_n)
      begin
        sync_req_m0_reg <= 1'b0;
        sync_req_m1_reg <= 1'b0;
      end
    else
      begin
        sync_req_m0_reg <= syncreq_m[0];
        sync_req_m1_reg <= syncreq_m[1];
      end
  end

  assign sync_flag_m0_we  = sync_req_m0_reg |
                            (sync_req_m1_reg & sync_flag_m1);


  assign sync_flag_m1_we  = sync_req_m1_reg |
                            (sync_req_m0_reg & sync_flag_m0);

  always @(posedge clk or negedge reset_n)
  begin : p_sync_flag_m0_seq
    if (!reset_n)
      begin
        sync_flag_m0 <= 1'b1;
      end
    else if (sync_flag_m0_we)
      begin
        sync_flag_m0 <= sync_req_m0_reg;
      end
  end

  always @(posedge clk or negedge reset_n)
  begin : p_sync_flag_m1_seq
    if (!reset_n)
      begin
        sync_flag_m1 <= 1'b1;
      end
    else if (sync_flag_m1_we)
      begin
        sync_flag_m1 <= sync_req_m1_reg;
      end
  end

  assign nxt_syncreqs = ((sync_req_m0_reg & sync_flag_m0) |
                         (sync_req_m1_reg & sync_flag_m1));


  always @(posedge clk or negedge reset_n)
  begin : p_syncreqs
    if (!reset_n)
      syncreq_s <= 1'b0;
    else
      syncreq_s <= nxt_syncreqs;
  end

  css600_or_tree
  #(
    .NUM_OR_INPUTS (3)
  ) u_qactive_async
  (
    .or_inputs({afvalid_m, atwakeup_s}),
    .or_output(clk_qactive)
  );


endmodule

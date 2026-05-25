//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017, 2019 Arm Limited or its affiliates.
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
//   Sub-module of css600_catu
//
//----------------------------------------------------------------------------


module css600_catu_scatter_list_walker
#(
  parameter ADDR_WIDTH  = 40,
  parameter DATA_WIDTH  = 64,
  parameter VA_WIDTH  = 40,
  parameter PA_WIDTH  = 40,
  parameter DSIZE       = 2,
  parameter PS_WIDTH    = 12,
  parameter SIZE_WIDTH  = 3,
  parameter TLB_RD_DEPTH = 1,
  parameter TLB_WR_DEPTH = 2,
  parameter TLB_DEPTH  = 1,
  parameter INIT_BITS  = 1
)(
  input  wire                   clk,
  input  wire                   reset_n,
  input  wire                   init_slw,
  input  wire                   clr_tlbs,
  input  wire                   ctrl_mode,
  input  wire [ADDR_WIDTH-1:0]  ctrl_sladdr,
  input  wire [ADDR_WIDTH-1:0]  ctrl_inaddr,
  output wire                   init_tlbs,
  output wire                   tlb_initialised,
  output wire                   slw_arvalid,
  input  wire                   slw_arready,
  output wire [1:0]             slw_aid,
  output wire [PA_WIDTH-1:0]    slw_araddr,
  output wire [3:0]             slw_arlen,
  output wire [SIZE_WIDTH-1:0]  slw_arsize,
  input  wire [1:0]             slw_rid,
  input  wire                   slw_rvalid,
  output wire                   slw_rready,
  input  wire                   slw_rlast,
  input  wire [DATA_WIDTH-1:0]  int_rdata,
  input  wire                   slw_err,
  output wire                   slw_rd_tlb_valid,
  output wire                   slw_wr_tlb_valid,
  output wire                   slw_wr_tlb_upd,
  output wire                   slw_wr_tlb_inv,
  output wire [PA_WIDTH-PS_WIDTH+INIT_BITS-1:0] slw_tlb_data,
  input  wire                   trans_slw_arvalid,
  output wire                   trans_slw_arready,
  input  wire [VA_WIDTH-1:0]    axislv_araddr,
  input  wire                   trans_slw_awvalid,
  output wire                   trans_slw_awready,
  input  wire                   wr_prefetch,
  input  wire                   wr_pre_addr_inc_ndec,
  input  wire [VA_WIDTH-PS_WIDTH-1:0] wr_pre_addr,
  input  wire [VA_WIDTH-1:0]    axislv_awaddr,
  output reg                    fetch_busy,
  output reg                    w_prefetch,
  output wire                   slw_busy,
  output wire                   slw_invalid_tlb_pftch
);

`include "css600_catu_localparams.v"

 localparam INIT_LEN = TLB_DEPTH == 2 && DATA_WIDTH == 32 ? 4'b0011
                     : TLB_DEPTH == 1 && DATA_WIDTH ==32 ||
                       TLB_DEPTH == 2 && DATA_WIDTH ==64 ? 4'b0001
                     : 4'b0000;

 localparam AR_SEQ_LEN = TLB_RD_DEPTH == 2 && DATA_WIDTH == 32 ? 4'b0011
                       : TLB_RD_DEPTH == 1 && DATA_WIDTH ==32 ||
                         TLB_RD_DEPTH == 2 && DATA_WIDTH ==64 ? 4'b0001
                       : 4'b0000;
 localparam AR_SINGLE_LEN = DATA_WIDTH == 32 ? 4'b0001
                          : 4'b0000;

 localparam AW_SEQ_LEN = TLB_WR_DEPTH == 2 && DATA_WIDTH == 32 ? 4'b0011
                       : TLB_WR_DEPTH == 1 && DATA_WIDTH ==32 ||
                         TLB_WR_DEPTH == 2 && DATA_WIDTH ==64 ? 4'b0001
                       : 4'b0000;
 localparam AW_SINGLE_LEN = DATA_WIDTH == 32 ? 4'b0001
                          : 4'b0000;


  genvar i;
  wire [PA_WIDTH-PS_WIDTH-1:0] next_curr_r_sg_pa;
  wire [VA_WIDTH-SP_SIZE-1:0]  next_curr_r_sg_va;
  reg  [PA_WIDTH-PS_WIDTH-1:0] curr_r_sg_pa;
  reg  [VA_WIDTH-SP_SIZE-1:0]  curr_r_sg_va;
  wire [PA_WIDTH-1:0]          next_r_page_locn;
  wire [PA_WIDTH-1:0]          prev_r_page_locn;
  wire                         r_inc_ndec;
  wire [PA_WIDTH-1:0]          r_page_locn_sel;
  wire [PA_WIDTH-1:0]          next_rd_addr;
  wire                         fetch_state_en;
  wire                         next_fetch_busy;
  reg  [ST_FETCH_BITS-1:0]     next_fetch_state;
  reg  [ST_FETCH_BITS-1:0]     fetch_state;
  wire                         r_slw_state_en;
  reg  [ST_SLW_BITS-1:0]       next_r_slw_state;
  reg  [ST_SLW_BITS-1:0]       r_slw_state;
  wire [3:0]                   next_rd_len;
  wire                         r_correct_page;
  wire                         r_inaddr_page;
  wire                         r_slw_update;
  wire [PA_WIDTH-PS_WIDTH-1:0] next_curr_w_sg_pa;
  wire [VA_WIDTH-SP_SIZE-1:0]  next_curr_w_sg_va;
  reg  [PA_WIDTH-PS_WIDTH-1:0] curr_w_sg_pa;
  reg  [VA_WIDTH-SP_SIZE-1:0]  curr_w_sg_va;
  wire [PA_WIDTH-1:0]          next_w_page_locn;
  wire [PA_WIDTH-1:0]          prev_w_page_locn;
  wire                         w_inc_ndec;
  wire [PA_WIDTH-1:0]          w_page_locn_sel;
  wire [PA_WIDTH-1:0]          p_page_locn_sel;
  wire [PA_WIDTH-1:0]          next_wr_addr;
  wire                         w_correct_page;
  wire                         w_inaddr_page;
  wire                         w_slw_update;
  wire                         w_slw_state_en;
  reg  [ST_SLW_BITS-1:0]       next_w_slw_state;
  wire                         next_w_prefetch;
  reg  [ST_SLW_BITS-1:0]       w_slw_state;
  wire [3:0]                   next_wr_len;
  wire [3:0]                   fetch_wr_len;
  wire [PA_WIDTH-1:0]          next_wr_pre_addr;
  wire [PA_WIDTH-1:0]          prefetch_addr;
  wire                         p_correct_page;
  wire                         slw_tlb;
  wire                         slw_tlb_beat;
  wire                         slw_valid_tlb;
  wire                         tlb_upd_complete;
  wire [63:0]                  slw_rdata;
  wire                         upd_r_curr_pa;
  wire                         upd_r_curr_va;
  wire                         upd_w_curr_pa;
  wire                         upd_w_curr_va;
  wire [VA_WIDTH-1-SP_SIZE:0]  inc_dec_digit;
  wire                         beat_cnt_en;
  wire                         slw_err_resp;
  wire                         slw_invalid_tlb;
  wire                         w_prefetch_nosearch;

  assign inc_dec_digit = {{VA_WIDTH-SP_SIZE-1{1'b0}}, 1'b1};

  assign slw_busy = fetch_busy | w_prefetch;


  always @*
  begin : p_next_fetch_state
    case (fetch_state)
      ST_FETCH_IDLE     : next_fetch_state = init_slw ? ST_FETCH_INIT :
                                                        ST_FETCH_IDLE;
      ST_FETCH_INIT     : next_fetch_state = (slw_arvalid && slw_arready) ? ST_FETCH_INIT_CMP
                                                                         : ST_FETCH_INIT;
      ST_FETCH_INIT_CMP : next_fetch_state =
                         (slw_rvalid && slw_rready && tlb_upd_complete && slw_rlast) ? ST_FETCH_COMPLETE
                                                               : ST_FETCH_INIT_CMP;
      ST_FETCH_COMPLETE : next_fetch_state = clr_tlbs ? ST_FETCH_IDLE :
                                                        ST_FETCH_COMPLETE;
      default           : next_fetch_state = ST_FETCH_UNDEF;
    endcase
  end

  assign fetch_state_en = (fetch_state != next_fetch_state);
  assign next_fetch_busy = (next_fetch_state == ST_FETCH_INIT) || (next_fetch_state == ST_FETCH_INIT_CMP);

  always @(posedge clk or negedge reset_n)
  begin : p_fetch_state
    if (!reset_n) begin
      fetch_state <= ST_FETCH_IDLE;
      fetch_busy <= 1'b0;
    end
    else if (fetch_state_en) begin
      fetch_state <= next_fetch_state;
      fetch_busy <= next_fetch_busy;
    end
  end

  assign tlb_initialised = (fetch_state != ST_FETCH_IDLE);

  assign init_tlbs = ((fetch_state == ST_FETCH_INIT) || (fetch_state == ST_FETCH_INIT_CMP))
                    && ctrl_mode == 1'b1;


  assign next_r_page_locn = {curr_r_sg_pa, SCATTER_NEXT_PAGE};
  assign prev_r_page_locn = {curr_r_sg_pa, SCATTER_PREV_PAGE};
  assign r_inc_ndec = curr_r_sg_va < axislv_araddr[VA_WIDTH-1:SP_SIZE] ? 1'b1 : 1'b0;

  assign r_page_locn_sel = r_inc_ndec
                         ? next_r_page_locn : prev_r_page_locn;

  assign next_rd_addr = (r_slw_state == ST_SLW_ACT) && r_correct_page
                      ? {curr_r_sg_pa, 1'b0, axislv_araddr[SP_SIZE-1:PS_WIDTH],3'b0}
                      : (r_slw_state == ST_SLW_ACT) && r_inaddr_page
                      ? {ctrl_sladdr[PA_WIDTH-1:PS_WIDTH], 1'b0, axislv_araddr[SP_SIZE-1:PS_WIDTH],3'b0}
                      : r_page_locn_sel;

  assign next_rd_len = (r_slw_state==ST_SLW_ACT && r_correct_page) ? AR_SEQ_LEN
                       : AR_SINGLE_LEN;

  assign next_curr_r_sg_pa = (init_slw || (r_slw_update && r_inaddr_page)) ? ctrl_sladdr[PA_WIDTH-1:PS_WIDTH]
                           : r_slw_update ? slw_rdata[PA_WIDTH-1:PS_WIDTH]
                           : curr_r_sg_pa;
  assign next_curr_r_sg_va = (init_slw || (r_slw_update && r_inaddr_page)) ? ctrl_inaddr[VA_WIDTH-1:SP_SIZE]
                           : (r_slw_update && r_inc_ndec) ? curr_r_sg_va + inc_dec_digit
                           : (r_slw_update && ~r_inc_ndec) ? curr_r_sg_va - inc_dec_digit
                           : curr_r_sg_va;
  assign upd_r_curr_pa = init_slw | r_slw_update;
  assign upd_r_curr_va = init_slw | r_slw_update;

  always @(posedge clk or negedge reset_n)
  begin : p_curr_pa
    if (!reset_n)
     curr_r_sg_pa <= {PA_WIDTH-PS_WIDTH{1'b0}};
    else if (upd_r_curr_pa)
     curr_r_sg_pa <= next_curr_r_sg_pa;
  end

  always @(posedge clk or negedge reset_n)
  begin : p_curr_va
    if (!reset_n)
     curr_r_sg_va <= {VA_WIDTH-SP_SIZE{1'b0}};
    else if (upd_r_curr_va)
     curr_r_sg_va <= next_curr_r_sg_va;
  end

  assign r_correct_page = axislv_araddr[VA_WIDTH-1:SP_SIZE] == curr_r_sg_va;
  assign r_inaddr_page = axislv_araddr[VA_WIDTH-1:SP_SIZE] == ctrl_inaddr[VA_WIDTH-1:SP_SIZE];

  always @*
  begin : p_next_r_slw_state
    case (r_slw_state)
      ST_SLW_IDLE  : next_r_slw_state = trans_slw_arvalid ? ST_SLW_ACT
                                      : ST_SLW_IDLE;
      ST_SLW_ACT   : next_r_slw_state = (slw_arvalid && slw_arready && slw_aid == 2'b11
                                            && (r_correct_page || r_inaddr_page)) ? ST_SLW_FETCH
                                      : (slw_arvalid && slw_arready && slw_aid == 2'b11) ? ST_SLW_SRCH
                                      :  ST_SLW_ACT;
      ST_SLW_SRCH  : next_r_slw_state = (slw_rvalid && slw_rlast && slw_rid==2'b11 && slw_err_resp) ? ST_SLW_IDLE
                                      : (slw_rvalid && slw_rlast && slw_rid==2'b11 && slw_rdata[0]) ? ST_SLW_UPD
                                      : (slw_rvalid && slw_rlast && slw_rid==2'b11) ? ST_SLW_IDLE
                                      : ST_SLW_SRCH;
      ST_SLW_UPD   : next_r_slw_state = ST_SLW_ACT;
      ST_SLW_FETCH : next_r_slw_state = (slw_rvalid && slw_rlast && tlb_upd_complete && slw_rid==2'b11) ? ST_SLW_IDLE
                                      : ST_SLW_FETCH;
      default      : next_r_slw_state = ST_SLW_UNDEF;
    endcase
  end

  assign r_slw_state_en = (r_slw_state != next_r_slw_state);

  always @(posedge clk or negedge reset_n)
  begin : p_r_slw_state
    if (!reset_n)
      r_slw_state <= ST_SLW_IDLE;
    else if (r_slw_state_en)
      r_slw_state <= next_r_slw_state;
  end

  assign r_slw_update = ((r_slw_state==ST_SLW_SRCH)
                      || (r_slw_state==ST_SLW_FETCH && slw_rid==2'b11 && r_inaddr_page))
                      && (slw_rvalid && slw_rlast && slw_rid==2'b11 && slw_rdata[0] && ~slw_err_resp);
  assign trans_slw_arready = (next_r_slw_state == ST_SLW_IDLE) && (r_slw_state != ST_SLW_IDLE);


  assign next_w_page_locn = {curr_w_sg_pa, SCATTER_NEXT_PAGE};
  assign prev_w_page_locn = {curr_w_sg_pa, SCATTER_PREV_PAGE};
  assign w_inc_ndec = (curr_w_sg_va < axislv_awaddr[VA_WIDTH-1:SP_SIZE]) && !w_prefetch ? 1'b1
                    : wr_pre_addr_inc_ndec && w_prefetch ? 1'b1 : 1'b0;

  assign w_page_locn_sel = w_inc_ndec
                         ? next_w_page_locn : prev_w_page_locn;

  assign next_wr_addr = (w_slw_state == ST_SLW_ACT) && w_correct_page
                      ? {curr_w_sg_pa, 1'b0, axislv_awaddr[SP_SIZE-1:PS_WIDTH],{DSIZE{1'b0}}}
                      : (w_slw_state == ST_SLW_ACT) && w_inaddr_page
                      ? {ctrl_sladdr[PA_WIDTH-1:PS_WIDTH], 1'b0, axislv_awaddr[SP_SIZE-1:PS_WIDTH],3'b0}
                      : w_page_locn_sel;

  generate
   if (DATA_WIDTH == 128)
    begin : g_128_addr
      assign fetch_wr_len = axislv_awaddr[PS_WIDTH] ? AW_SEQ_LEN + 4'b0001 : AW_SEQ_LEN;
    end
   else
    begin : g_not_128_addr
      assign fetch_wr_len = AW_SEQ_LEN;
    end

  endgenerate

  assign next_wr_len = (w_slw_state==ST_SLW_ACT && !w_prefetch && (w_correct_page || w_inaddr_page)) ? fetch_wr_len
                       : AW_SINGLE_LEN;

  assign next_curr_w_sg_pa = (init_slw || (w_slw_update && w_prefetch_nosearch) || (w_slw_update && w_inaddr_page && ~w_prefetch)) ? ctrl_sladdr[PA_WIDTH-1:PS_WIDTH]
                         : w_slw_update ? slw_rdata[PA_WIDTH-1:PS_WIDTH]
                         : curr_w_sg_pa;
  assign next_curr_w_sg_va = (init_slw || (w_slw_update && w_prefetch_nosearch) || (w_slw_update && w_inaddr_page && ~w_prefetch)) ? ctrl_inaddr[VA_WIDTH-1:SP_SIZE]
                         : (w_slw_update && w_inc_ndec) ? curr_w_sg_va + inc_dec_digit
                         : (w_slw_update && ~w_inc_ndec) ? curr_w_sg_va - inc_dec_digit
                         : curr_w_sg_va;
  assign upd_w_curr_pa = init_slw | w_slw_update;
  assign upd_w_curr_va = init_slw | w_slw_update;

  always @(posedge clk or negedge reset_n)
  begin : p_w_curr_pa
    if (!reset_n)
     curr_w_sg_pa <= {PA_WIDTH-PS_WIDTH{1'b0}};
    else if (upd_w_curr_pa)
     curr_w_sg_pa <= next_curr_w_sg_pa;
  end

  always @(posedge clk or negedge reset_n)
  begin : p_w_curr_va
    if (!reset_n)
     curr_w_sg_va <= {VA_WIDTH-SP_SIZE{1'b0}};
    else if (upd_w_curr_va)
     curr_w_sg_va <= next_curr_w_sg_va;
  end

  assign w_correct_page = axislv_awaddr[VA_WIDTH-1:SP_SIZE] == curr_w_sg_va;
  assign w_inaddr_page = axislv_awaddr[VA_WIDTH-1:SP_SIZE] == ctrl_inaddr[VA_WIDTH-1:SP_SIZE];

  always @*
  begin : p_next_w_slw_state
    case (w_slw_state)
      ST_SLW_IDLE  : next_w_slw_state = (trans_slw_awvalid || wr_prefetch) ? ST_SLW_ACT
                                      : ST_SLW_IDLE;
      ST_SLW_ACT   : next_w_slw_state = (slw_arvalid && slw_arready) &&
                                        ((slw_aid == 2'b01 && (w_correct_page || w_inaddr_page))
                                      || (slw_aid == 2'b10 && (p_correct_page || w_prefetch_nosearch)))
                                       ? ST_SLW_FETCH
                                      : (slw_arvalid && slw_arready && (slw_aid == 2'b01 || slw_aid == 2'b10))
                                       ? ST_SLW_SRCH
                                      :  ST_SLW_ACT;
      ST_SLW_SRCH  : next_w_slw_state = (slw_rvalid && slw_rlast && (slw_rid==2'b01 || slw_rid==2'b10) && slw_err_resp) ? ST_SLW_IDLE
                                      : (slw_rvalid && slw_rlast && (slw_rid==2'b01 || slw_rid==2'b10) && slw_rdata[0]) ? ST_SLW_UPD
                                      : (slw_rvalid && slw_rlast && (slw_rid==2'b01 || slw_rid==2'b10)) ? ST_SLW_IDLE
                                      : ST_SLW_SRCH;
      ST_SLW_UPD   : next_w_slw_state = ST_SLW_ACT;
      ST_SLW_FETCH : next_w_slw_state = (slw_rvalid && slw_rlast && tlb_upd_complete && slw_rid==2'b01) ? ST_SLW_IDLE
                                      : (slw_rvalid && slw_rlast && tlb_upd_complete && slw_rid==2'b10) ? ST_SLW_WAIT
                                      : ST_SLW_FETCH;
      ST_SLW_WAIT  : next_w_slw_state = ST_SLW_IDLE;
      default      : next_w_slw_state = ST_SLW_UNDEF;
    endcase
  end

  assign w_slw_state_en = (w_slw_state != next_w_slw_state);
  assign next_w_prefetch =  wr_prefetch & (next_w_slw_state != ST_SLW_IDLE);

  always @(posedge clk or negedge reset_n)
  begin : p_w_slw_state
    if (!reset_n) begin
      w_slw_state <= ST_SLW_IDLE;
      w_prefetch  <= 1'b0;
    end
    else if (w_slw_state_en) begin
      w_slw_state <= next_w_slw_state;
      w_prefetch  <= next_w_prefetch;
    end
  end

  assign w_slw_update = ((w_slw_state==ST_SLW_SRCH && slw_rid==2'b01)
                      || (w_slw_state==ST_SLW_SRCH && slw_rid==2'b10)
                      || (w_slw_state==ST_SLW_FETCH && slw_rid==2'b10 && w_prefetch_nosearch)
                      || (w_slw_state==ST_SLW_FETCH && slw_rid==2'b01 && w_inaddr_page))
                      && (slw_tlb_beat && slw_rdata[0] & ~slw_err_resp);
  assign trans_slw_awready = (next_w_slw_state == ST_SLW_IDLE) && (w_slw_state != ST_SLW_IDLE) &&
                            ((!w_prefetch) || (next_wr_addr == prefetch_addr && trans_slw_awvalid));


  assign p_correct_page = (wr_pre_addr[VA_WIDTH-PS_WIDTH-1:SP_SIZE-PS_WIDTH]) == curr_w_sg_va;
  assign p_page_locn_sel = wr_pre_addr_inc_ndec ? next_w_page_locn : prev_w_page_locn;

  assign next_wr_pre_addr = w_prefetch && p_correct_page
                          ? {curr_w_sg_pa, 1'b0, wr_pre_addr[SP_SIZE-PS_WIDTH-1:0], {DSIZE{1'b0}}}
                          : w_prefetch_nosearch
                          ? {ctrl_sladdr[PA_WIDTH-1:PS_WIDTH], {PS_WIDTH{1'b0}} }
                          : p_page_locn_sel;
  assign w_prefetch_nosearch = w_prefetch && !p_correct_page && (wr_pre_addr == ctrl_inaddr[VA_WIDTH-1:PS_WIDTH]);
  assign prefetch_addr = next_wr_pre_addr;


  assign slw_invalid_tlb_pftch = slw_tlb & (~slw_rdata[0]) & (slw_rid==2'b10) & ~slw_err_resp
                               | slw_wr_tlb_inv & ~slw_err_resp
                               ;

  generate
   if (DATA_WIDTH == 32)
    begin : g_32_bit

      wire [1:0]  next_r_beat_cnt;
      reg  [1:0]  r_beat_cnt;
      wire [1:0]  next_w_beat_cnt;
      reg  [1:0]  w_beat_cnt;
      reg  [31:0] r_rdata_lsw;
      reg  [31:0] w_rdata_lsw;
      wire [31:0] rdata_lsw;
      wire        r_rdata_en;
      wire        w_rdata_en;
      wire        beat_cnt;
      reg         w_resp_err;
      reg         r_resp_err;

      assign next_w_beat_cnt = (slw_rvalid && slw_rready && slw_rlast && (slw_rid[0] ^ slw_rid[1]))
                                  ? 2'b00 :
                               (slw_rvalid && slw_rready && (slw_rid[0] ^ slw_rid[1]))
                                  ? w_beat_cnt + 2'b1
                                  : w_beat_cnt;
      assign next_r_beat_cnt = (slw_rvalid && slw_rready && slw_rlast && (&slw_rid))
                                  ? 2'b00 :
                               (slw_rvalid && slw_rready && (&slw_rid)) ? r_beat_cnt + 2'b1
                                  : r_beat_cnt;
      assign beat_cnt_en = slw_rvalid;

      always @(posedge clk or negedge reset_n)
       begin : p_beat_cnt
        if (!reset_n) begin
         r_beat_cnt <= 2'b00;
         w_beat_cnt <= 2'b00;
        end
        else if (beat_cnt_en) begin
         r_beat_cnt <= next_r_beat_cnt;
         w_beat_cnt <= next_w_beat_cnt;
        end
       end

      assign beat_cnt = (&slw_rid) ? 1'b0 : w_beat_cnt[1];

      assign slw_tlb_beat = slw_rvalid
                     & ((w_beat_cnt[0] & (slw_rid[0] ^ slw_rid[1])) | (r_beat_cnt[0] & (&slw_rid)));
      assign slw_tlb = slw_tlb_beat
                     & (fetch_state == ST_FETCH_INIT_CMP
                       | r_slw_state == ST_SLW_FETCH
                       | w_slw_state == ST_SLW_FETCH);
      assign slw_valid_tlb = slw_tlb & slw_rdata[0] & ~slw_err_resp;

      assign slw_rd_tlb_valid = slw_valid_tlb & ((fetch_state == ST_FETCH_INIT_CMP)
                                               | (slw_rid==2'b11 && r_slw_state == ST_SLW_FETCH));
      assign slw_wr_tlb_valid = slw_valid_tlb & ((fetch_state == ST_FETCH_INIT_CMP)
                                               | (slw_rid==2'b01 && w_slw_state == ST_SLW_FETCH));
      assign slw_tlb_data = {slw_rdata[PA_WIDTH-1:PS_WIDTH], beat_cnt};

      assign r_rdata_en = slw_rvalid & slw_rready & ~r_beat_cnt[0] & (&slw_rid);
      assign w_rdata_en = slw_rvalid & slw_rready & ~w_beat_cnt[0] & ~(&slw_rid);

      always @(posedge clk)
       begin : p_w_rdata_lsw
       if (w_rdata_en) begin
         w_rdata_lsw <= int_rdata;
         w_resp_err  <= slw_err;
       end
      end

      always @(posedge clk)
       begin : p_r_rdata_lsw
       if (r_rdata_en) begin
         r_rdata_lsw <= int_rdata;
         r_resp_err  <= slw_err;
       end
      end

      assign slw_err_resp = (((w_resp_err | slw_err) & (slw_rid[0] ^ slw_rid[1]))
                        | ((r_resp_err | slw_err) & (&slw_rid)));

      assign rdata_lsw = (&slw_rid) ? r_rdata_lsw : w_rdata_lsw;
      assign tlb_upd_complete = 1'b1;
      assign slw_rdata = {int_rdata, rdata_lsw};

    end
   else if (DATA_WIDTH == 64)
    begin : g_64_bit

      wire       next_wr_beat_cnt;
      reg        wr_beat_cnt;
      wire       next_pr_beat_cnt;
      reg        pr_beat_cnt;
      wire       beat;

      assign next_wr_beat_cnt = (slw_rvalid && slw_rready && slw_rlast && slw_rid==2'b01) ? 1'b0 :
                                (slw_rvalid && slw_rready && slw_rid==2'b01) ? ~wr_beat_cnt :
                                 wr_beat_cnt;

      assign next_pr_beat_cnt = (slw_rvalid && slw_rready && slw_rlast && slw_rid==2'b10) ? 1'b0 :
                                (slw_rvalid && slw_rready && slw_rid==2'b10) ? ~pr_beat_cnt :
                                 pr_beat_cnt;
      assign beat_cnt_en = slw_rvalid & (slw_rid[0] ^ slw_rid[1]);

      always @(posedge clk or negedge reset_n)
       begin : p_beat_cnt
       if (!reset_n) begin
          wr_beat_cnt <= 1'b0;
          pr_beat_cnt <= 1'b0;
        end
       else if (beat_cnt_en) begin
          wr_beat_cnt <= next_wr_beat_cnt;
          pr_beat_cnt <= next_pr_beat_cnt;
        end
       end

      assign slw_err_resp = slw_err;

      assign beat = slw_rid==2'b11 ? 1'b0
                  : slw_rid==2'b01 ? wr_beat_cnt
                  : pr_beat_cnt;

      assign slw_tlb_beat = slw_rvalid;
      assign slw_tlb = slw_tlb_beat
                     & (fetch_state == ST_FETCH_INIT_CMP
                      | r_slw_state == ST_SLW_FETCH
                      | w_slw_state == ST_SLW_FETCH);
      assign slw_valid_tlb = slw_tlb & slw_rdata[0] & ~slw_err_resp;

      assign slw_rd_tlb_valid = slw_valid_tlb & ((fetch_state == ST_FETCH_INIT_CMP)
                                               | (slw_rid==2'b11 && r_slw_state == ST_SLW_FETCH));
      assign slw_wr_tlb_valid = slw_valid_tlb & ((fetch_state == ST_FETCH_INIT_CMP)
                                               | (slw_rid==2'b01 && w_slw_state == ST_SLW_FETCH));
      assign slw_tlb_data = {slw_rdata[PA_WIDTH-1:PS_WIDTH], beat};
      assign tlb_upd_complete = 1'b1;
      assign slw_rdata = int_rdata;

    end
   else if (DATA_WIDTH == 128)
    begin : g_128_bit

      wire       next_beat_cnt;
      wire       dword_sel;
      reg        beat_cnt_q;
      wire       beat_cnt;
      wire       beat_sel;
      wire       unal_en;
      wire       nxt_unaligned_fetch;
      reg        unaligned_fetch_q;
      wire       unaligned_fetch;

      assign nxt_unaligned_fetch = (axislv_awaddr[PS_WIDTH] & (!w_prefetch && (w_correct_page || w_inaddr_page)) & ~init_tlbs);
      assign unal_en = (w_slw_state==ST_SLW_ACT) || (fetch_state==ST_FETCH_INIT);

      always @(posedge clk or negedge reset_n)
       begin : p_unal
       if (!reset_n)
         unaligned_fetch_q <= 1'b0;
       else if (unal_en)
         unaligned_fetch_q <= nxt_unaligned_fetch;
       end

      assign unaligned_fetch = unaligned_fetch_q;

      assign slw_err_resp = slw_err;

      assign next_beat_cnt = (!slw_rvalid) ? 1'b0 :
                             (slw_wr_tlb_valid || (slw_err & slw_tlb & ~wr_prefetch & ~(&slw_rid))) ? ~beat_cnt :
                              beat_cnt;
      assign dword_sel = (~slw_rid[0] & slw_rid[1] & ~init_tlbs & p_correct_page & wr_pre_addr[0])
                       | (~slw_rid[0] & slw_rid[1] & ~init_tlbs & ~p_correct_page & p_page_locn_sel[DSIZE])
                       | (slw_rid[0] & slw_rid[1] & ~init_tlbs & (r_correct_page | r_inaddr_page) & axislv_araddr[PS_WIDTH])
                       | (slw_rid[0] & slw_rid[1] & (r_slw_state == ST_SLW_SRCH) & r_page_locn_sel[DSIZE])
                       | (slw_rid[0] & ~slw_rid[1] & (w_slw_state == ST_SLW_SRCH) & w_page_locn_sel[DSIZE])
                       | (beat_cnt & ~(&slw_rid));
      assign slw_rdata = dword_sel ? int_rdata[127:64]
                                   : int_rdata[63:0];

      assign beat_cnt_en = beat_cnt_q != next_beat_cnt;

      always @(posedge clk or negedge reset_n)
       begin : p_beat_cnt
       if (!reset_n)
         beat_cnt_q <= 1'b0;
       else if (beat_cnt_en)
         beat_cnt_q <= next_beat_cnt;
       end

      assign beat_cnt = (!slw_rlast && unaligned_fetch) ? ~beat_cnt_q : beat_cnt_q;

      assign slw_tlb_beat = slw_rvalid;
      assign slw_tlb = slw_tlb_beat
                     & (fetch_state == ST_FETCH_INIT_CMP
                      | r_slw_state == ST_SLW_FETCH
                      | w_slw_state == ST_SLW_FETCH);
      assign slw_valid_tlb = slw_tlb & slw_rdata[0] & ~slw_err_resp;
      assign slw_invalid_tlb = slw_tlb & (~slw_rdata[0] | slw_err_resp);
      assign slw_rd_tlb_valid = slw_valid_tlb & ((fetch_state == ST_FETCH_INIT_CMP)
                                               | (slw_rid==2'b11 && r_slw_state == ST_SLW_FETCH));
      assign slw_wr_tlb_valid = slw_valid_tlb & ((fetch_state == ST_FETCH_INIT_CMP)
                                               | (slw_rid==2'b01 && w_slw_state == ST_SLW_FETCH));
      assign beat_sel = unaligned_fetch ? ~beat_cnt : beat_cnt;

      assign slw_tlb_data = beat_sel && !(&slw_rid) ? {slw_rdata[ADDR_WIDTH-1:PS_WIDTH], 1'b1}
                                     : {slw_rdata[ADDR_WIDTH-1:PS_WIDTH], 1'b0};
      assign tlb_upd_complete = beat_cnt || slw_invalid_tlb
                            || (slw_rlast & unaligned_fetch)
                            || (w_slw_state == ST_SLW_FETCH && w_prefetch)
                            || (w_slw_state == ST_SLW_SRCH)
                            || (r_slw_state == ST_SLW_FETCH && (&slw_rid))
                            || (r_slw_state == ST_SLW_SRCH && (&slw_rid));

    end
  endgenerate

  generate
   if (TLB_WR_DEPTH > 1)
    begin : g_wr_upd
      assign slw_wr_tlb_upd = slw_valid_tlb & (slw_rid==2'b10) & (w_slw_state == ST_SLW_FETCH);
      assign slw_wr_tlb_inv = (slw_tlb_beat & (w_slw_state == ST_SLW_FETCH | w_slw_state == ST_SLW_SRCH))
                            & (~slw_rdata[0] | slw_err_resp) & (slw_rid == 2'b10);
    end
   else
    begin : g_no_wr_upd
      assign slw_wr_tlb_upd = 1'b0;
      assign slw_wr_tlb_inv = 1'b0;
    end
  endgenerate


  generate
   if (TLB_DEPTH > 1)
    begin : g_prefetch
      assign slw_arvalid = (fetch_state == ST_FETCH_INIT) ||
                           (r_slw_state == ST_SLW_ACT) ||
                           (w_slw_state == ST_SLW_ACT);
      assign slw_aid = (w_slw_state == ST_SLW_ACT && !w_prefetch) ? 2'b01 :
                       (r_slw_state == ST_SLW_ACT) ? 2'b11 :
                        2'b10;
      assign slw_araddr = (init_tlbs) ? {curr_r_sg_pa, {PS_WIDTH{1'b0}}} :
                          (w_slw_state == ST_SLW_ACT && !w_prefetch) ? next_wr_addr :
                          (r_slw_state == ST_SLW_ACT) ? next_rd_addr :
                           prefetch_addr;

      assign slw_arlen = (init_tlbs) ? INIT_LEN
                        : (w_slw_state != ST_SLW_IDLE && !w_prefetch) ? next_wr_len : next_rd_len;
      assign slw_arsize = DATA_WIDTH == 32 ? 3'b010
                        : DATA_WIDTH == 64 ||
                          (w_slw_state==ST_SLW_ACT && (w_prefetch || (!w_correct_page && !w_inaddr_page))) ||
                          (r_slw_state==ST_SLW_ACT && w_slw_state!=ST_SLW_ACT) ? 3'b011
                        : 3'b100;

      assign slw_rready = ((fetch_state == ST_FETCH_INIT_CMP) ||
                           (w_slw_state == ST_SLW_SRCH) ||
                           (w_slw_state == ST_SLW_FETCH) ||
                           (r_slw_state == ST_SLW_SRCH) ||
                           (r_slw_state == ST_SLW_FETCH))
                         && tlb_upd_complete;
    end
  endgenerate


endmodule



//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017 Arm Limited or its affiliates.
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


module css600_catu_translation_ctrl
#(
  parameter VA_WIDTH  = 40,
  parameter PA_WIDTH  = 40,
  parameter PS_WIDTH  = 12,
  parameter ADDR_WIDTH  = 40,
  parameter DATA_WIDTH  = 64,
  parameter LEN_WIDTH   = 8,
  parameter SIZE_WIDTH  = 3,
  parameter BURST_WIDTH = 2,
  parameter CACHE_WIDTH = 4,
  parameter PROT_WIDTH  = 3,
  parameter RESP_WIDTH  = 2,
  parameter WSTRB_WIDTH = 8,
  parameter TLB_RES_WIDTH = PA_WIDTH - PS_WIDTH + 1
)(
  input  wire                        clk,
  input  wire                        reset_n,
  input  wire [ADDR_WIDTH-1:0]       ctrl_inaddr,
  input  wire                        translate_avalid,
  input  wire [TLB_RES_WIDTH-1:0]    tlb_result,
  input  wire [VA_WIDTH-1:0]         axislv_addr,
  input  wire                        prefetch,

  output reg                         translated_avalid,
  input  wire                        translated_aready,
  output reg  [PA_WIDTH-1:0]         translated_addr,
  output reg                         avalid_t,
  input  wire                        aready_t,
  input  wire                        resp_valid_t,
  input  wire                        resp_ready_t,
  input  wire                        trans_drained,
  input  wire                        trans_resperr,
  output wire                        invalid_trans,
  output wire                        upd_addr_en,
  output reg                         trans_slw_avalid,
  input  wire                        trans_slw_aready,
  output wire                        trans_busy,
  output wire                        oor_va

);

`include "css600_catu_localparams.v"

  reg   [2:0]   next_trans_state;
  reg   [2:0]   trans_state;
  wire          trans_fail;
  reg           trans_slw_complete;
  wire          trans_slw_en;
  wire          trans_state_en;
  wire          trans_slw_avalid_en;
  wire          set_trans_slw_avalid;
  wire          clr_trans_slw_avalid;


  assign oor_va = translate_avalid &&
                 (((axislv_addr < ctrl_inaddr[VA_WIDTH-1:0]) && (trans_state == ST_TRANSLATE_IDLE))
               || ((trans_slw_complete && !tlb_result[0]) && (trans_state == ST_TRANSLATE_MISS)));
  assign trans_fail = oor_va;

  assign trans_slw_en = (trans_slw_complete ^ trans_slw_aready);

  always @(posedge clk or negedge reset_n)
  begin : p_trans_slw
    if (!reset_n)
      trans_slw_complete <= 1'b0;
    else if (trans_slw_en)
      trans_slw_complete <= trans_slw_aready;
  end

  assign trans_busy = (trans_state!=ST_TRANSLATE_IDLE);

  assign invalid_trans = trans_state==ST_INVALID_RESP;

  always @*
  begin : p_next_state
    case (trans_state)
      ST_TRANSLATE_IDLE : next_trans_state = (translate_avalid && trans_fail) ? ST_INVALID_ADD :
                                             (translate_avalid && tlb_result[0]) ? ST_TRANSLATE_HIT :
                                             (translate_avalid && ~prefetch) ? ST_TRANSLATE_MISS :
                                              ST_TRANSLATE_IDLE;
      ST_TRANSLATE_HIT  : next_trans_state = (translated_avalid && translated_aready) ? ST_TRANSLATE_IDLE :
                                              ST_TRANSLATE_HIT;
      ST_TRANSLATE_MISS : next_trans_state = (translate_avalid && tlb_result[0]) ? ST_TRANSLATED :
                                             (trans_slw_complete || trans_resperr) ? ST_INVALID_ADD :
                                              ST_TRANSLATE_MISS;
      ST_TRANSLATED     : next_trans_state = (translated_avalid && translated_aready && trans_slw_avalid) ? ST_TRANS_CMP :
                                             (translated_avalid && translated_aready) ? ST_TRANSLATE_IDLE :
                                              ST_TRANSLATED;
      ST_TRANS_CMP      : next_trans_state = (trans_slw_avalid) ? ST_TRANS_CMP : ST_TRANSLATE_IDLE;
      ST_INVALID_ADD    : next_trans_state = (avalid_t && aready_t) ? ST_INVALID_RESP :
                                              ST_INVALID_ADD;
      ST_INVALID_RESP   : next_trans_state = (resp_valid_t && resp_ready_t && trans_slw_avalid) ? ST_TRANS_CMP :
                                             (resp_valid_t && resp_ready_t) ? ST_TRANSLATE_IDLE :
                                              ST_INVALID_RESP;
      default           : next_trans_state =  ST_TRANSLATE_UNDEF;
    endcase
  end

  assign trans_state_en = (trans_state != next_trans_state);

  always @(posedge clk or negedge reset_n)
  begin : p_state
    if (!reset_n)
      trans_state <= ST_TRANSLATE_IDLE;
    else if (trans_state_en)
      trans_state <= next_trans_state;
  end

  assign set_trans_slw_avalid = (next_trans_state == ST_TRANSLATE_MISS) && (trans_state == ST_TRANSLATE_IDLE);
  assign upd_addr_en = set_trans_slw_avalid;
  assign clr_trans_slw_avalid = trans_slw_aready;
  assign trans_slw_avalid_en = clr_trans_slw_avalid | set_trans_slw_avalid;

  always @(posedge clk or negedge reset_n)
  begin : p_trans_slw_valid
    if (!reset_n)
      trans_slw_avalid <= 1'b0;
    else if (trans_slw_avalid_en)
      trans_slw_avalid <= ~clr_trans_slw_avalid;
  end


  always @*
  begin : p_routing
    translated_avalid = 1'b0;
    avalid_t = 1'b0;
    translated_addr = {PA_WIDTH{1'b0}};
    if (trans_state == ST_TRANSLATE_HIT)
     begin
       translated_avalid = 1'b1;
       translated_addr = {tlb_result[PA_WIDTH-PS_WIDTH:1], axislv_addr[PS_WIDTH-1:0]};
     end
    else if (trans_state == ST_INVALID_ADD)
     begin
       avalid_t = trans_drained;
     end
    else if (trans_state == ST_TRANSLATED)
     begin
       translated_avalid = 1'b1;
       translated_addr = {tlb_result[PA_WIDTH-PS_WIDTH:1], axislv_addr[PS_WIDTH-1:0]};
     end
  end


endmodule



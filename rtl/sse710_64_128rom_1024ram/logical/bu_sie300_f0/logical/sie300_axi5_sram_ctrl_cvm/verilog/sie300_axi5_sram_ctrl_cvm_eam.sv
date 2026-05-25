//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2019 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//
//      Version Information
//
//      Checked In          : Tue Apr 30 16:42:21 2019 +0100
//
//      Revision            : 59885c20
//
//      Release Information : CoreLink SIE-300 Generic Global Bundle r1p2-00rel0
//
//----------------------------------------------------------------------------

module sie300_axi5_sram_ctrl_cvm_eam
#(
  parameter IGNORE_LSB_EXCL = 7
)
(
  input  wire logic                                           clk,
  input  wire logic                                           resetn,

  input  wire logic [12-1   :0]                               arq_id,
  input  wire logic [22-1 :0]                                 arq_addr,
  input  wire logic                                           arq_prot,
  input  wire logic                                           arq_lock,
  input  wire logic                                           arq_vld,
  input  wire logic                                           arq_rdy,
  input  wire logic [12-1   :0]                               awq_id,
  input  wire logic [22-1 :0]                                 awq_addr,
  input  wire logic                                           awq_prot,
  input  wire logic [22-1 :IGNORE_LSB_EXCL]                   wbeat_addr,
  input  wire logic                                           wbeat_vld,
  input  wire logic                                           wbeat_rdy,
  input  wire logic                                           wbeat_chk_exok,
  output      logic                                           eam_exok
);
  genvar g;

  logic [2-1:0]                           excl_mon_in_use;
  logic [2-1:0]                           excl_mon_sel;
  logic [2-1:0]                           exokay_vector;
  logic [2-1:0]                           excl_mon_first_free;
  logic [2-1:0]                           excl_mon_and;
  logic                                   excl_mon_full;
  logic [2-1:0]                           excl_mon_alloc;
  logic [2-1:0]                           id_match_ar;
  logic                                   process_ar;
  logic                                   process_wbeat;

  assign process_ar           = arq_vld & arq_rdy & arq_lock;
  assign process_wbeat        = wbeat_vld & wbeat_rdy & ~wbeat_chk_exok;

  assign excl_mon_and[0]        =  excl_mon_in_use[0];
  assign excl_mon_first_free[0] = ~excl_mon_in_use[0];

  generate
    for (g=1; g < 2; g=g+1) begin : g_and_ripple
      assign excl_mon_and[g]        = excl_mon_and[g-1] &  excl_mon_in_use[g];
      assign excl_mon_first_free[g] = excl_mon_and[g-1] & ~excl_mon_in_use[g];
    end
  endgenerate

  assign excl_mon_full = excl_mon_and[2-1];

  always_ff @(posedge clk or negedge resetn) begin : p_excl_mon_allocator
    if (~resetn) begin
      excl_mon_alloc <= 2'd1;
    end
    else if (~|id_match_ar & excl_mon_full & process_ar) begin
      excl_mon_alloc <= { excl_mon_alloc[2-2 : 0], excl_mon_alloc[2-1]};
    end
  end

  assign excl_mon_sel         = |id_match_ar
                              ? id_match_ar
                              : (excl_mon_full ? excl_mon_alloc : excl_mon_first_free);

  generate
    for (g=0;g < 2; g=g+1)
    begin : g_excl_monitor

      logic [22-1   :0]                     mon_addr;
      logic [12-1     :0]                   mon_id;
      logic                                 mon_prot;
      logic                                 clr_mon;
      logic                                 ld_mon;
      logic                                 addr_match_awq;
      logic                                 addr_match_wbeat;
      logic                                 id_match_awq;
      logic                                 prot_match_awq;

      assign id_match_ar[g]     = excl_mon_in_use[g]
                                & (arq_id == mon_id);

      assign id_match_awq       = excl_mon_in_use[g]
                                & (awq_id == mon_id);

      assign prot_match_awq     = excl_mon_in_use[g]
                                & (awq_prot == mon_prot);

      assign addr_match_awq     = excl_mon_in_use[g]
                                & (    mon_addr[22-1 : 0]
                                    == awq_addr[22-1 : 0] );

      assign addr_match_wbeat   = excl_mon_in_use[g]
                                & (      mon_addr[22-1 : IGNORE_LSB_EXCL]
                                    == wbeat_addr[22-1 : IGNORE_LSB_EXCL] );

      assign clr_mon            = excl_mon_in_use[g]
                                & process_wbeat
                                & addr_match_wbeat;

      assign ld_mon             = excl_mon_sel[g]
                                & process_ar;

      always_ff @(posedge clk or negedge resetn) begin : p_monitor_seq
        if (~resetn) begin
          mon_addr    <= 22'b0;
          mon_id      <= 12'b0;
          mon_prot    <= 1'b0;
        end
        else if (ld_mon) begin
          mon_addr    <= arq_addr;
          mon_id      <= arq_id;
          mon_prot    <= arq_prot;
        end
      end

      always_ff @(posedge clk or negedge resetn) begin : p_excl_mon_in_use_seq
        if (~resetn) begin
          excl_mon_in_use[g] <= 1'b0;
        end
        else if (ld_mon) begin
          excl_mon_in_use[g] <= 1'b1;
        end
        else if (excl_mon_in_use[g] & clr_mon) begin
          excl_mon_in_use[g] <= 1'b0;
        end

      end

      assign exokay_vector[g]   = wbeat_chk_exok
                                & addr_match_awq
                                & id_match_awq
                                & prot_match_awq;
    end
  endgenerate

  assign eam_exok = |exokay_vector;

endmodule


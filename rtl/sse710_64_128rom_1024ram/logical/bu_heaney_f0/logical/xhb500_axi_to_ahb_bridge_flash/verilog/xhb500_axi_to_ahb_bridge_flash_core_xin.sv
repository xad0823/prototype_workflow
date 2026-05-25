//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2025 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//-----------------------------------------------------------------------------
//
//      Version Information
//
//      Checked In          : Fri Mar 29 11:15:40 2019 +0000
//
//      Revision            : 08e988e
//
//      Release Information : CoreLink XHB-500 Generic Global Bundle r0p0-00rel0
//

module xhb500_axi_to_ahb_bridge_flash_core_xin
(



  input  wire logic                                                   clk,
  input  wire logic                                                   resetn,

  input  wire logic                                                   ctrl_core_en,
  output      logic                                                   ctrl_xin_active,


  input  wire logic                                                   awsparse,

  input  wire logic                                                   awvalid,
  output      logic                                                   awready,
  input  wire xhb500_axi_to_ahb_bridge_flash_pkg::axi_axpayld_t                   awpayld,

  input  wire logic                                                   arvalid,
  output      logic                                                   arready,
  input  wire xhb500_axi_to_ahb_bridge_flash_pkg::axi_axpayld_t                   arpayld,

  input  wire logic                                                   wvalid,
  output      logic                                                   wready,
  input  wire xhb500_axi_to_ahb_bridge_flash_pkg::axi_wpayld_t                    wpayld,



  output      logic                                                   tr_en,
  output      logic                                                   h_en,
  output      logic                                                   w_en,

  output      logic                                            [1:0]  htrans_out,
  output      xhb500_axi_to_ahb_bridge_flash_pkg::ahb_mpayld_t                    ahb_out,

  input wire logic                                                    hready_in,
  input wire  xhb500_axi_to_ahb_bridge_flash_pkg::ahb_m_trq_t                     ahb_tr_q_in
);

  wire xhb500_axi_to_ahb_bridge_flash_pkg::axi_axpayld_t                          aw = awpayld;
  wire xhb500_axi_to_ahb_bridge_flash_pkg::axi_axpayld_t                          ar = arpayld;
  wire xhb500_axi_to_ahb_bridge_flash_pkg::axi_wpayld_t                           w  = wpayld;

  typedef enum logic [1:0] {AHB_TRANS_IDLE=2'b00, AHB_TRANS_BUSY=2'b01, AHB_TRANS_NONSEQ=2'b10, AHB_TRANS_SEQ=2'b11} ahb_trans_t;
  typedef enum logic [2:0] {
      AHB_BURST_SINGLE = 3'b000, AHB_BURST_INCR  = 3'b001, AHB_BURST_WRAP4  = 3'b010, AHB_BURST_INCR4  = 3'b011,
      AHB_BURST_WRAP8  = 3'b100, AHB_BURST_INCR8 = 3'b101, AHB_BURST_WRAP16 = 3'b110, AHB_BURST_INCR16 = 3'b111} ahb_burst_t;

  typedef enum logic [1:0] {AXI_BURST_FIXED = 2'b00, AXI_BURST_INCR  = 2'b01, AXI_BURST_WRAP  = 2'b10} axi_burst_t;

  typedef enum logic [2:0] {FIRST=3'b000, READ=3'b001, WRITE=3'b010, UNM_READ=3'b011, SP_WRITE=3'b100} estate_t;

  localparam MAXSIZE = $clog2(16);
  typedef enum logic [2:0] {SIZE000=3'b000, SIZE001=3'b001, SIZE010=3'b010, SIZE011=3'b011, SIZE100=3'b100, SIZE101=3'b101, SIZE110=3'b110, SIZE111=3'b111} e_xhb_size_t;
  typedef xhb500_axi_to_ahb_bridge_flash_pkg::xhb_size_t xhb_size_t;

  xhb500_axi_to_ahb_bridge_flash_pkg::xhb_fsm_ctrl_t    fsm_ctrl;
  xhb500_axi_to_ahb_bridge_flash_pkg::xhb_fsm_out_t     fsm_out;

  xhb500_axi_to_ahb_bridge_flash_pkg::ahb_m_trfix_t     ahb_tr;
  xhb500_axi_to_ahb_bridge_flash_pkg::ahb_m_hfix_t      ahb_h;
  xhb500_axi_to_ahb_bridge_flash_pkg::ahb_m_wdata_t     ahb_w;

  logic                                     hmastlock_q;
  logic                                     hmastlock_err_q;
  logic [7:0]                               rd_left_q;
  xhb500_axi_to_ahb_bridge_flash_pkg::xhb_size_t        tr_axsize_q;
  logic [3:0]                               tr_wraplen_q;
  logic                                     tr_fixed_q;
  logic [MAXSIZE-1:0]                       tr_unmr_addr_ms_q;

  logic [11:0]                              nxt_addr_11_0_q;
  logic                                     nxt_tr_break_q;
  logic [11:0]                              unmr_addr_11_0_q;
  logic                                     unmr_tr_break_q;

  logic                                     sp_ctrl_is_sparse_q;
  logic                                     sp_beat_finished_q;
  logic                                     sp_beat_is_full_q;
  logic                                     sp_wlast_q;

  xhb500_axi_to_ahb_bridge_flash_pkg::ahb_m_trq_t       sp_trq_q;
  logic                                     sp_tr_is_fixed_q;

  xhb500_axi_to_ahb_bridge_flash_pkg::xhb_size_t        sp_axsize_tr_q;
  logic     [3:0]                           sp_wraplen_tr_q;
  logic     [11:0]                          sp_addr_11_0_q;
  logic                                     sp_tr_break_q;
  logic     [16-1:0]                        sp_strb_left_q;

  wire logic        awsparse_cfg_in         = awsparse;


  wire logic        ar_wrap_2               = (ar.axburst == AXI_BURST_WRAP) & (ar.axlen[3:0]==4'b0001);
  wire logic        aw_wrap_2               = (aw.axburst == AXI_BURST_WRAP) & (aw.axlen[3:0]==4'b0001);

  wire logic        ar_nonmodif             = ~ar.axcache[1];
  wire logic        aw_nonmodif             = ~aw.axcache[1];

  wire logic [11:0] araddr_11_0_aligned     = {ar.axaddr[11:MAXSIZE], ar.axaddr[MAXSIZE-1:0] & ({MAXSIZE{1'b1}} << ar.axsize)};
  wire logic [11:0] awaddr_11_0_aligned     = {aw.axaddr[11:MAXSIZE], aw.axaddr[MAXSIZE-1:0] & ({MAXSIZE{1'b1}} << aw.axsize)};

  wire logic        ar_unaligned            = |(ar.axaddr[MAXSIZE-1:0] & (~({MAXSIZE{1'b1}} << ar.axsize)));

  logic [7:0]       ar_tr_cross_crp;
  always_comb
    case(ar.axsize)
      SIZE000:      ar_tr_cross_crp         = (&ar.axaddr[9:8]) ? ~ar.axaddr[7:0] : '1;
      SIZE001:      ar_tr_cross_crp         = ( ar.axaddr[9]  ) ? ~ar.axaddr[8:1] : '1;
      SIZE010:      ar_tr_cross_crp         =                     ~ar.axaddr[9:2] ;
      SIZE011:      ar_tr_cross_crp         =              {1'b0, ~ar.axaddr[9:3]};
      SIZE100:      ar_tr_cross_crp         =              {2'b0, ~ar.axaddr[9:4]};
      SIZE101:      ar_tr_cross_crp         =                                   '1;
      SIZE110:      ar_tr_cross_crp         =                                   '1;
      SIZE111:      ar_tr_cross_crp         =                                   '1;
      default:      ar_tr_cross_crp         =                                   'x;
  endcase
  wire logic        ar_tr_incr_cross        = (ar_tr_cross_crp < ar.axlen) & (ar.axburst == AXI_BURST_INCR);

  logic [7:0]       aw_tr_cross_crp;
  always_comb
    case(aw.axsize)
      SIZE000:      aw_tr_cross_crp         = (&aw.axaddr[9:8]) ? ~aw.axaddr[7:0] : '1;
      SIZE001:      aw_tr_cross_crp         = ( aw.axaddr[9]  ) ? ~aw.axaddr[8:1] : '1;
      SIZE010:      aw_tr_cross_crp         =                     ~aw.axaddr[9:2] ;
      SIZE011:      aw_tr_cross_crp         =              {1'b0, ~aw.axaddr[9:3]};
      SIZE100:      aw_tr_cross_crp         =              {2'b0, ~aw.axaddr[9:4]};
      SIZE101:      aw_tr_cross_crp         =                                   '1;
      SIZE110:      aw_tr_cross_crp         =                                   '1;
      SIZE111:      aw_tr_cross_crp         =                                   '1;
      default:      aw_tr_cross_crp         =                                   'x;
  endcase
  wire logic        aw_tr_incr_cross        = (aw_tr_cross_crp < aw.axlen) & (aw.axburst == AXI_BURST_INCR);

  wire logic [11:0] ar_addr_11_0_sh         = (ar.axaddr[11:0] >> ar.axsize);
  wire logic [11:0] ar_incraddr_11_0_sh     =  ar_addr_11_0_sh + 1'b1;
  wire logic [11:0] ar_wrapaddr_11_0_sh     = {ar_addr_11_0_sh[11:4],(ar_addr_11_0_sh[3:0] & ~ar.axlen[3:0])};
  wire logic        ar_wrap_beat            = (ar.axburst == AXI_BURST_WRAP) & (&(ar_addr_11_0_sh[3:0] | ~ar.axlen[3:0]));
  wire logic [11:0] ar_iwaddr_11_0          = (ar_wrap_beat ? ar_wrapaddr_11_0_sh : ar_incraddr_11_0_sh) << ar.axsize;
  wire logic        ar_cross_beat           =  ar.axaddr[10] ^ ar_iwaddr_11_0[10];
  wire logic [11:0] nxt_ar_fiwaddr_11_0     = (ar.axburst == AXI_BURST_FIXED) ? araddr_11_0_aligned : ar_iwaddr_11_0;
  wire logic        nxt_ar_tr_break         = (ar.axburst == AXI_BURST_FIXED) ? 1'b1 : (ar_cross_beat | (ar_wrap_beat & ar_wrap_2));

  wire logic [11:0] aw_addr_11_0_sh         = (aw.axaddr[11:0] >> aw.axsize);
  wire logic [11:0] aw_incraddr_11_0_sh     =  aw_addr_11_0_sh + 1'b1;
  wire logic [11:0] aw_wrapaddr_11_0_sh     = {aw_addr_11_0_sh[11:4],(aw_addr_11_0_sh[3:0] & ~aw.axlen[3:0])};
  wire logic        aw_wrap_beat            = (aw.axburst == AXI_BURST_WRAP) & (&(aw_addr_11_0_sh[3:0] | ~aw.axlen[3:0]));
  wire logic [11:0] aw_iwaddr_11_0          = (aw_wrap_beat ? aw_wrapaddr_11_0_sh : aw_incraddr_11_0_sh) << aw.axsize;
  wire logic        aw_cross_beat           =  aw.axaddr[10] ^ aw_iwaddr_11_0[10];
  wire logic [11:0] nxt_aw_fiwaddr_11_0     = (aw.axburst == AXI_BURST_FIXED) ? awaddr_11_0_aligned : aw_iwaddr_11_0;
  wire logic        nxt_aw_tr_break         = (aw.axburst == AXI_BURST_FIXED) ? 1'b1 : (aw_cross_beat | (aw_wrap_beat & (awsparse_cfg_in | aw_wrap_2)));

  wire logic        ar_trans_cross          =  ar_tr_incr_cross;
  wire logic        aw_trans_cross          =  aw_tr_incr_cross;

  wire logic [16-1:0] aw_strb_mask;
  xhb500_axi_to_ahb_bridge_flash_strbgen u_aw_strb_chk
  (
      .addr_in            (aw.axaddr[$clog2(16)-1:0]),
      .size_in            (aw.axsize),

      .strb               (aw_strb_mask)
  );

  wire logic        aw_sparse               = |(aw_strb_mask & ~w.wstrb);

  wire logic [11:0] nxt_addr_11_0_sh        = (nxt_addr_11_0_q >> tr_axsize_q);
  wire logic [11:0] nxt_incraddr_11_0_sh    =  nxt_addr_11_0_sh + 1'b1;
  wire logic [11:0] nxt_wrapaddr_11_0_sh    = {nxt_addr_11_0_sh[11:4],(nxt_addr_11_0_sh[3:0] & ~tr_wraplen_q[3:0])};
  wire logic        nxt_wrap_beat           =  tr_wraplen_q[0] & (&(nxt_addr_11_0_sh[3:0] | ~tr_wraplen_q[3:0]));
  wire logic [11:0] nxt_iwaddr_11_0         = (nxt_wrap_beat ? nxt_wrapaddr_11_0_sh : nxt_incraddr_11_0_sh) << tr_axsize_q;
  wire logic        nxt_cross_beat          =  nxt_addr_11_0_q[10] ^ nxt_iwaddr_11_0[10];
  wire logic        nxt_tr_break            =  nxt_cross_beat | (nxt_wrap_beat & (ahb_tr_q_in.hburst == AHB_BURST_INCR)) | tr_fixed_q;

  xhb500_axi_to_ahb_bridge_flash_pkg::xhb_size_t        ar_bgst_size;
  xhb500_axi_to_ahb_bridge_flash_pkg::xhb_size_t        nxt_unmr_bgst_size;

  always_comb begin
    ar_bgst_size          = ar.axsize;
    nxt_unmr_bgst_size    = tr_axsize_q;

    for (int i = MAXSIZE-1; i >=0; i=i-1) begin : g_bgst_size
      if((xhb_size_t'(i)  <= ar.axsize)     &&        ar.axaddr[i])        ar_bgst_size = xhb_size_t'(i);
      if((xhb_size_t'(i)  <= tr_axsize_q)   && unmr_addr_11_0_q[i])  nxt_unmr_bgst_size = xhb_size_t'(i);
    end
  end

  wire logic        ar_nxt_aligned          = ~|(       ~ar.axaddr[MAXSIZE-1:0] & {       ar.axaddr[MAXSIZE-2:0],1'b0} & ~({MAXSIZE{1'b1}} <<   ar.axsize));
  wire logic        nxt_unmr_aligned        = ~|(~unmr_addr_11_0_q[MAXSIZE-1:0] & {unmr_addr_11_0_q[MAXSIZE-2:0],1'b0} & ~({MAXSIZE{1'b1}} << tr_axsize_q));

  wire logic [11:0] ar_unmr_iaddr_11_0      =  ar.axaddr[11:0] + (MAXSIZE'(1'b1) << ar_bgst_size);
  wire logic [11:0] nxt_ar_unmr_fiaddr_11_0 = ((ar.axburst == AXI_BURST_FIXED) & ar_nxt_aligned) ? ar.axaddr[11:0] : ar_unmr_iaddr_11_0;
  wire logic        nxt_ar_unmr_tr_break    =  ar_nxt_aligned;
  wire logic [11:0] nxt_unmr_iaddr_11_0     =  unmr_addr_11_0_q + (MAXSIZE'(1'b1) << nxt_unmr_bgst_size);
  wire logic        nxt_unmr_cross_beat     =  unmr_addr_11_0_q[10] ^ nxt_unmr_iaddr_11_0[10];
  wire logic [11:0] nxt_unmr_fiaddr_11_0    = (tr_fixed_q & nxt_unmr_aligned) ? {unmr_addr_11_0_q[11:MAXSIZE], tr_unmr_addr_ms_q} : nxt_unmr_iaddr_11_0;
  wire logic        nxt_unmr_tr_break       = ((nxt_unmr_bgst_size != tr_axsize_q) & nxt_unmr_aligned) | nxt_unmr_cross_beat | (tr_fixed_q & nxt_unmr_aligned);

  wire logic [6:0]                          sp_aw_addr_6_0_out;
  wire xhb500_axi_to_ahb_bridge_flash_pkg::xhb_size_t   sp_aw_size_out;
  wire logic [16-1:0]                       sp_aw_strb_left;
  wire logic                                sp_aw_beat_finished;
  wire logic                                sp_aw_beat_sparse;
  wire logic                                sp_aw_beat_empty;
  wire logic                                sp_aw_beat_is_full;

  xhb500_axi_to_ahb_bridge_flash_sparse u_aw_sparse
  (
      .addr_6_0_in        (aw.axaddr[6:0]),
      .axsize_in          (aw.axsize),

      .sp_strb_in         (w.wstrb),

      .sp_addr_6_0_out    (sp_aw_addr_6_0_out),
      .sp_size_out        (sp_aw_size_out),

      .sp_strb_left       (sp_aw_strb_left),
      .sp_beat_finished   (sp_aw_beat_finished),

      .new_beat_sparse    (sp_aw_beat_sparse),
      .new_beat_empty     (sp_aw_beat_empty),
      .new_beat_full      (sp_aw_beat_is_full)
  );

  wire logic [11:0] nxt_aw_sp_fiwaddr_11_0  = (aw.axburst == AXI_BURST_FIXED | ~sp_aw_beat_finished) ? awaddr_11_0_aligned : aw_iwaddr_11_0;
  wire logic        nxt_aw_sp_tr_break      = (aw.axburst == AXI_BURST_FIXED) ? 1'b1 : (aw_cross_beat | aw_wrap_beat);

  wire logic [6:0]                          sp_w_addr_6_0_out;
  wire xhb500_axi_to_ahb_bridge_flash_pkg::xhb_size_t   sp_w_size_out;
  wire logic [16-1:0]                       sp_w_strb_left;
  wire logic                                sp_w_beat_finished;
  wire logic                                sp_w_beat_sparse;
  wire logic                                sp_w_beat_empty;
  wire logic                                sp_w_beat_is_full;

  xhb500_axi_to_ahb_bridge_flash_sparse u_w_sparse
  (
      .addr_6_0_in        (sp_addr_11_0_q[6:0]),
      .axsize_in          (sp_axsize_tr_q),

      .sp_strb_in         (w.wstrb),

      .sp_addr_6_0_out    (sp_w_addr_6_0_out),
      .sp_size_out        (sp_w_size_out),

      .sp_strb_left       (sp_w_strb_left),
      .sp_beat_finished   (sp_w_beat_finished),

      .new_beat_sparse    (sp_w_beat_sparse),
      .new_beat_empty     (sp_w_beat_empty),
      .new_beat_full      (sp_w_beat_is_full)
  );

  wire logic [6:0]                          sp_q_addr_6_0_out;
  wire xhb500_axi_to_ahb_bridge_flash_pkg::xhb_size_t   sp_q_size_out;
  wire logic [16-1:0]                       sp_q_strb_left;
  wire logic                                sp_q_beat_finished;
  wire logic                                sp_q_beat_sparse;
  wire logic                                sp_q_beat_empty;
  wire logic                                sp_q_beat_is_full;

  xhb500_axi_to_ahb_bridge_flash_sparse u_q_sparse
  (
      .addr_6_0_in        (sp_addr_11_0_q[6:0]),
      .axsize_in          (sp_axsize_tr_q),

      .sp_strb_in         (sp_strb_left_q),

      .sp_addr_6_0_out    (sp_q_addr_6_0_out),
      .sp_size_out        (sp_q_size_out),

      .sp_strb_left       (sp_q_strb_left),
      .sp_beat_finished   (sp_q_beat_finished),

      .new_beat_sparse    (sp_q_beat_sparse),
      .new_beat_empty     (sp_q_beat_empty),
      .new_beat_full      (sp_q_beat_is_full)
  );

  wire logic [6:0]                          sp_addr_6_0_out   = (sp_beat_finished_q & wvalid) ? sp_w_addr_6_0_out  : sp_q_addr_6_0_out;
  wire xhb500_axi_to_ahb_bridge_flash_pkg::xhb_size_t   sp_size_out       = (sp_beat_finished_q & wvalid) ? sp_w_size_out      : sp_q_size_out;
  wire logic [16-1:0]                       sp_strb_left      = (sp_beat_finished_q & wvalid) ? sp_w_strb_left     : sp_q_strb_left;
  wire logic                                sp_beat_finished  = (sp_beat_finished_q & wvalid) ? sp_w_beat_finished : sp_q_beat_finished;
  wire logic                                sp_beat_sparse    = (sp_beat_finished_q & wvalid) ? sp_w_beat_sparse   : sp_q_beat_sparse;
  wire logic                                sp_beat_empty     = (sp_beat_finished_q & wvalid) ? sp_w_beat_empty    : sp_q_beat_empty;
  wire logic                                sp_beat_is_full   = (sp_beat_finished_q & wvalid) ? sp_w_beat_is_full  : sp_q_beat_is_full;

  wire logic [11:0] sp_addr_11_0_sh         = (sp_addr_11_0_q >> sp_axsize_tr_q);
  wire logic        sp_wrap_beat            =  sp_wraplen_tr_q[0] &  (&(sp_addr_11_0_sh[3:0] | ~sp_wraplen_tr_q[3:0]));
  wire logic [11:0] sp_incraddr_11_0_sh     =  sp_addr_11_0_sh + 1'b1;
  wire logic [11:0] sp_wrapaddr_11_0_sh     = {sp_addr_11_0_sh[11:4], (sp_addr_11_0_sh[3:0] & ~sp_wraplen_tr_q[3:0])};
  wire logic [11:0] sp_iwaddr_11_0          = (sp_wrap_beat ? sp_wrapaddr_11_0_sh : sp_incraddr_11_0_sh) << sp_axsize_tr_q;
  wire logic        sp_cross_beat           = sp_addr_11_0_q[10] ^ sp_iwaddr_11_0[10];
  wire logic        nxt_sp_tr_break         = sp_cross_beat | sp_wrap_beat | sp_tr_is_fixed_q;

  wire logic [16-1:0] wr_strb_mask;
  xhb500_axi_to_ahb_bridge_flash_strbgen u_wr_strb_chk
  (
      .addr_in            (nxt_addr_11_0_q[MAXSIZE-1:0]),
      .size_in            (tr_axsize_q),

      .strb               (wr_strb_mask)
  );

  wire logic        wr_sparse               = |(wr_strb_mask & ~w.wstrb);


  wire logic        ar_hnonsec              =   ar.axprot[1];
  wire logic        aw_hnonsec              =   aw.axprot[1];
  wire logic [6:0]  ar_hprot                = {^ar.axdomain[1:0], ar.axcache[2], |ar.axcache[3:2], ar.axcache[1], (ar.axcache[3:0] == 4'b0011) ? 1'b0 : ar.axcache[0], ar.axprot[0], ~ar.axprot[2]};
  wire logic [6:0]  aw_hprot                = {^aw.axdomain[1:0], aw.axcache[3], |aw.axcache[3:2], aw.axcache[1], (aw.axcache[3:0] == 4'b0011) ? 1'b0 : aw.axcache[0], aw.axprot[0], ~aw.axprot[2]};
  wire logic        ar_hexcl                =   ar.axlock & (ar.axlen == 8'h00);
  wire logic        aw_hexcl                =   aw.axlock & (aw.axlen == 8'h00) & ~aw_sparse;
  wire logic        ar_ctrl_exclid          =   ar_hexcl & ahb_tr_q_in.hexcl & (ar.axid == ahb_tr_q_in.hmaster);
  wire logic        aw_ctrl_exclid          =   aw_hexcl & ahb_tr_q_in.hexcl & (aw.axid == ahb_tr_q_in.hmaster);

  ahb_burst_t       ar_hburst;

  always_comb begin
    ar_hburst       = AHB_BURST_INCR;

    if( (ar.axburst == AXI_BURST_FIXED) | ((ar.axburst == AXI_BURST_INCR) & (ar.axlen == 8'h00)))
      ar_hburst     = AHB_BURST_SINGLE;
    else if(ar.axburst == AXI_BURST_WRAP) begin
      if(ar.axlen[1])         ar_hburst = AHB_BURST_WRAP4;
      if(ar.axlen[2])         ar_hburst = AHB_BURST_WRAP8;
      if(ar.axlen[3])         ar_hburst = AHB_BURST_WRAP16;
    end
    else if((ar.axburst == AXI_BURST_INCR) & ~(ar_unaligned & ar_nonmodif) & ~ar_tr_incr_cross) begin
      if(ar.axlen == 8'h03)   ar_hburst = AHB_BURST_INCR4;
      if(ar.axlen == 8'h07)   ar_hburst = AHB_BURST_INCR8;
      if(ar.axlen == 8'h0f)   ar_hburst = AHB_BURST_INCR16;
    end
  end

  ahb_burst_t       aw_hburst;

  always_comb begin
    aw_hburst       = AHB_BURST_INCR;

    if( (aw.axburst == AXI_BURST_FIXED) | ((aw.axburst == AXI_BURST_INCR) & (aw.axlen == 8'h00)))
      aw_hburst     = AHB_BURST_SINGLE;
    else if(~awsparse_cfg_in) begin
      if(aw.axburst == AXI_BURST_WRAP) begin
        if(aw.axlen[1])       aw_hburst = AHB_BURST_WRAP4;
        if(aw.axlen[2])       aw_hburst = AHB_BURST_WRAP8;
        if(aw.axlen[3])       aw_hburst = AHB_BURST_WRAP16;
      end
      else if((aw.axburst == AXI_BURST_INCR) & ~aw_tr_incr_cross) begin
        if(aw.axlen == 8'h03) aw_hburst = AHB_BURST_INCR4;
        if(aw.axlen == 8'h07) aw_hburst = AHB_BURST_INCR8;
        if(aw.axlen == 8'h0f) aw_hburst = AHB_BURST_INCR16;
      end
    end
  end



  estate_t fsm_state;
  estate_t fsm_nxt_state;
  wire logic        fsm_out_en              = ctrl_core_en & hready_in;
  wire logic        fsm_state_en            = ctrl_core_en & hready_in & ~fsm_ctrl.hold_output;

  logic      [2:0]  sch_wr_wait_count_q;
  wire logic        ctrl_sch_write_boost    = (sch_wr_wait_count_q == 3'b111);

  wire logic [2:0]  sch_wr_wait_count_nxt   = sch_wr_wait_count_q + (awvalid | sp_ctrl_is_sparse_q);
  wire logic        sch_wr_wait_clear_en    = fsm_out_en & (fsm_state == FIRST) & ~(arvalid & ~ctrl_sch_write_boost) & ~hmastlock_q;
  wire logic        sch_wr_wait_count_en    = fsm_out_en & (fsm_state == FIRST) &  (arvalid & ~ctrl_sch_write_boost) & ~hmastlock_q & wvalid;

  always_ff @ (posedge clk, negedge resetn)
    if (~resetn)
      sch_wr_wait_count_q   <= '0;
    else if(sch_wr_wait_clear_en)
      sch_wr_wait_count_q   <= '0;
    else if(sch_wr_wait_count_en)
      sch_wr_wait_count_q   <= sch_wr_wait_count_nxt;


  always_ff @(posedge clk, negedge resetn)
    if (~resetn)
      fsm_state <= FIRST;
    else if(fsm_state_en)
      fsm_state <= fsm_nxt_state;

  always_comb
  begin

    fsm_nxt_state           = fsm_state;
    fsm_ctrl                = '0;
    fsm_out                 = '0;

    case (fsm_state)

      FIRST : begin

        if (hmastlock_q) begin
          fsm_nxt_state                 = FIRST;
        end
        else if (arvalid & ~ctrl_sch_write_boost) begin
          fsm_nxt_state                 = READ;

          fsm_ctrl.arready              = 1'b1;
          fsm_ctrl.resp.rvalid          = 1'b1;
          fsm_ctrl.resp.bridge_err      = ar_nonmodif & ar_trans_cross;

          fsm_out.haddr_11_0            = araddr_11_0_aligned;
          fsm_out.hsize                 = ar.axsize;
          fsm_out.htrans                = fsm_out_en ? AHB_TRANS_NONSEQ : AHB_TRANS_IDLE;
          fsm_out.hmastlock             = fsm_out_en ? (ar_nonmodif & ~ar_trans_cross) : 1'b0;

          fsm_out.rd_left               = ar.axlen;

          if (|ar.axlen) begin
            fsm_ctrl.resp.ahb_last      = 1'b0;
            fsm_out.rd_left             = ar.axlen - 1'b1;
          end
          else begin
            fsm_ctrl.resp.ahb_last      = 1'b1;
            fsm_nxt_state               = FIRST;
          end

          if(ar_unaligned & ar_nonmodif) begin
            fsm_nxt_state               = UNM_READ;
            fsm_ctrl.resp.ahb_last      = 1'b0;
            fsm_ctrl.resp.rvalid        = ar_nxt_aligned;

            fsm_out.haddr_11_0          = ar.axaddr[11:0];
            fsm_out.hsize               = ar_bgst_size;

            if(~ar_nxt_aligned)
              fsm_out.rd_left           = ar.axlen;

            if(ar_nxt_aligned & ~|ar.axlen) begin
              fsm_nxt_state             = FIRST;
              fsm_ctrl.resp.ahb_last    = 1'b1;
            end
          end
        end

        else if (wvalid & sp_ctrl_is_sparse_q) begin
          fsm_nxt_state                 = SP_WRITE;
          fsm_ctrl.sparse               = 1'b1;
          fsm_ctrl.wready               = 1'b1;
          fsm_ctrl.resp.resp_acc        = 1'b1;
          fsm_ctrl.resp.ahb_last        = w.wlast & sp_w_beat_finished;
          fsm_ctrl.resp.sp_empty        = fsm_out_en & sp_w_beat_empty;

          if((w.wlast | sp_w_beat_sparse) & sp_w_beat_finished) begin
            fsm_nxt_state               = FIRST;
          end

          fsm_out.haddr_11_0            = {sp_addr_11_0_q[11:7], sp_w_addr_6_0_out};
          fsm_out.hsize                 = sp_w_size_out;
          fsm_out.htrans                = (fsm_out_en & ~sp_w_beat_empty) ? AHB_TRANS_NONSEQ : AHB_TRANS_IDLE;
        end

        else if (awvalid & wvalid) begin
          fsm_nxt_state                 = WRITE;

          fsm_ctrl.awready              = 1'b1;
          fsm_ctrl.wready               = 1'b1;
          fsm_ctrl.resp.ahb_last        = w.wlast;

          fsm_out.haddr_11_0            = awaddr_11_0_aligned;
          fsm_out.hsize                 = aw.axsize;
          fsm_out.htrans                = fsm_out_en ? AHB_TRANS_NONSEQ : AHB_TRANS_IDLE;
          fsm_out.hmastlock             = fsm_out_en ? (aw_nonmodif & ~aw_trans_cross) : 1'b0;

          if (w.wlast) begin
            fsm_nxt_state               = FIRST;
          end

          fsm_ctrl.resp.bridge_err      = (((aw.axlock & (aw.axlen == 8'h00)) |~awsparse_cfg_in) & aw_sparse) | (aw_nonmodif & aw_trans_cross);

          if (awsparse_cfg_in) begin
            fsm_nxt_state               = SP_WRITE;

            fsm_ctrl.sparse             = 1'b1;
            fsm_ctrl.resp.ahb_last      = w.wlast & sp_aw_beat_finished;
            fsm_ctrl.resp.sp_empty      = fsm_out_en & sp_aw_beat_empty;

            if(~sp_aw_beat_empty) begin
              fsm_out.haddr_11_0        = {aw.axaddr[11:7], sp_aw_addr_6_0_out};
            end
            fsm_out.hsize               = sp_aw_size_out;
            fsm_out.htrans              = (fsm_out_en & ~sp_aw_beat_empty) ? AHB_TRANS_NONSEQ : AHB_TRANS_IDLE;

            if((w.wlast | (sp_aw_beat_sparse & ~fsm_out.hmastlock)) & sp_aw_beat_finished) begin
              fsm_nxt_state             = FIRST;
            end
          end
        end
      end

      READ: begin
        fsm_nxt_state                   = READ;

        fsm_ctrl.resp.rvalid            = 1'b1;
        fsm_ctrl.resp.bridge_err        = hmastlock_err_q;

        fsm_out.hsize                   = tr_axsize_q;
        fsm_out.haddr_11_0              = nxt_addr_11_0_q;
        fsm_out.htrans                  = nxt_tr_break_q ? AHB_TRANS_NONSEQ : AHB_TRANS_SEQ;
        fsm_out.hmastlock               = hmastlock_q;

        if (|rd_left_q) begin
          fsm_ctrl.resp.ahb_last        = 1'b0;
          fsm_out.rd_left               = rd_left_q - 1'b1;
        end
        else begin
          fsm_nxt_state                 = FIRST;
          fsm_ctrl.resp.ahb_last        = 1'b1;
        end
      end

      WRITE: begin
        fsm_nxt_state                   = WRITE;

        fsm_ctrl.wready                 = wvalid;
        fsm_ctrl.hold_output            = ~wvalid;
        fsm_ctrl.resp.resp_acc          = 1'b1;
        fsm_ctrl.resp.ahb_last          = wvalid & w.wlast;

        fsm_ctrl.resp.bridge_err        = wvalid & wr_sparse;

        fsm_out.haddr_11_0              = nxt_addr_11_0_q;
        fsm_out.hsize                   = tr_axsize_q;
        fsm_out.hmastlock               = hmastlock_q;

        if(nxt_tr_break_q)
          fsm_out.htrans                = wvalid ? AHB_TRANS_NONSEQ : AHB_TRANS_IDLE;
        else
          fsm_out.htrans                = wvalid ? AHB_TRANS_SEQ    : AHB_TRANS_BUSY;

        if (wvalid & w.wlast)
          fsm_nxt_state                 = FIRST;
      end

      UNM_READ: begin
        fsm_nxt_state                   = UNM_READ;
        fsm_ctrl.resp.rvalid            = nxt_unmr_aligned;
        fsm_ctrl.resp.resp_acc          = ~unmr_tr_break_q & ~(nxt_unmr_bgst_size == tr_axsize_q);
        fsm_ctrl.resp.bridge_err        = hmastlock_err_q;

        fsm_out.htrans                  = (~unmr_tr_break_q & (nxt_unmr_bgst_size == tr_axsize_q)) ? AHB_TRANS_SEQ : AHB_TRANS_NONSEQ;
        fsm_out.haddr_11_0              = unmr_addr_11_0_q;
        fsm_out.hsize                   = nxt_unmr_bgst_size;
        fsm_out.hmastlock               = hmastlock_q;

        fsm_out.rd_left                 = rd_left_q;
        if (nxt_unmr_aligned) begin
          if(|rd_left_q) begin
            fsm_out.rd_left             = rd_left_q - 1'b1;
          end
          else begin
            fsm_nxt_state               = FIRST;
            fsm_ctrl.resp.ahb_last      = 1'b1;
          end
        end
      end

      SP_WRITE: begin
        fsm_nxt_state                   = SP_WRITE;

        fsm_ctrl.sparse                 = 1'b1;
        fsm_ctrl.wready                 = sp_beat_finished_q & wvalid;
        fsm_ctrl.resp.resp_acc          = 1'b1;

        fsm_ctrl.resp.ahb_last          = (sp_wlast_q | (sp_beat_finished_q & wvalid & w.wlast)) & sp_beat_finished;
        fsm_ctrl.hold_output            = sp_beat_finished_q & ~wvalid;

        fsm_ctrl.resp.sp_empty          = fsm_state_en & wvalid & sp_beat_empty;
        fsm_out.haddr_11_0              = {sp_addr_11_0_q[11:7], sp_addr_6_0_out};
        fsm_out.hsize                   = sp_size_out;
        fsm_out.hmastlock               = hmastlock_q;

        if ((sp_beat_finished & sp_beat_sparse & ~hmastlock_q) | fsm_ctrl.resp.ahb_last)
          fsm_nxt_state                 = FIRST;

        if(wvalid & sp_beat_empty)
          fsm_out.htrans                = AHB_TRANS_IDLE;
        else if(sp_tr_break_q | ~sp_beat_is_full_q | (sp_beat_finished_q & wvalid & ~sp_beat_is_full))
          fsm_out.htrans                = fsm_ctrl.hold_output ? AHB_TRANS_IDLE : AHB_TRANS_NONSEQ;
        else
          fsm_out.htrans                = fsm_ctrl.hold_output ? AHB_TRANS_BUSY : AHB_TRANS_SEQ;

      end

      default: begin
        fsm_nxt_state       =  estate_t'('x);

        fsm_ctrl            = ('x);
        fsm_out             = ('x);
      end

    endcase
  end




  xhb500_axi_to_ahb_bridge_flash_pkg::ahb_m_trq_t   ar_trq;
  assign ar_trq.hburst      = ar_hburst;
  assign ar_trq.hprot       = ar_hprot;
  assign ar_trq.hnonsec     = ar_hnonsec;
  assign ar_trq.hexcl       = ar_hexcl;
  assign ar_trq.haddr_m_12  = ar.axaddr[32-1:12];
  assign ar_trq.hmaster     = ar.axid;
  assign ar_trq.hqos        = ar.axqos;
  assign ar_trq.hregion     = ar.axregion;
  assign ar_trq.hnsaid      = ar.axnsaid;

  xhb500_axi_to_ahb_bridge_flash_pkg::ahb_m_trq_t   aw_trq;
  assign aw_trq.hburst      = aw_hburst;
  assign aw_trq.hprot       = aw_hprot;
  assign aw_trq.hnonsec     = aw_hnonsec;
  assign aw_trq.hexcl       = aw_hexcl;
  assign aw_trq.haddr_m_12  = aw.axaddr[32-1:12];
  assign aw_trq.hmaster     = aw.axid;
  assign aw_trq.hqos        = aw.axqos;
  assign aw_trq.hregion     = aw.axregion;
  assign aw_trq.hnsaid      = aw.axnsaid;

  always_comb begin
    ahb_tr  = '0;

    if ((fsm_state == FIRST) & ~hmastlock_q & arvalid & ~ctrl_sch_write_boost) begin
      ahb_tr.hwrite         = '0;
      ahb_tr.ctrl_exclid    = ar_ctrl_exclid;
      ahb_tr.trfixq         = ar_trq;
    end
    else if ((fsm_state == FIRST) & ~hmastlock_q & wvalid & sp_ctrl_is_sparse_q) begin
      ahb_tr.hwrite         = '1;
      ahb_tr.ctrl_exclid    = '0;
      ahb_tr.trfixq         = sp_trq_q;
    end
    else if ((fsm_state == FIRST) & ~hmastlock_q & awvalid & wvalid) begin
      ahb_tr.hwrite         = '1;
      ahb_tr.ctrl_exclid    = aw_ctrl_exclid;
      ahb_tr.trfixq         = aw_trq;
    end
    else if(ctrl_core_en) begin
      ahb_tr.hwrite         = (fsm_state != FIRST) & (fsm_state != READ) & (fsm_state != UNM_READ);
      ahb_tr.ctrl_exclid    = '0;
      ahb_tr.trfixq         = ahb_tr_q_in;
    end
  end

  assign ahb_h.haddr_11_0   = fsm_out.haddr_11_0;
  assign ahb_h.hsize        = fsm_out.hsize;
  assign ahb_h.hmastlock    = fsm_out.hmastlock;
  assign ahb_h.resp_ctrl    = fsm_ctrl.resp;

  assign ahb_w.hwdata       = w.wdata;



  wire logic tr_ar_first_en = fsm_out_en & ~fsm_ctrl.resp.ahb_last & (fsm_state == FIRST) & ~hmastlock_q & arvalid & ~ctrl_sch_write_boost;
  wire logic tr_sp_cont_en  = fsm_out_en & ~fsm_ctrl.resp.ahb_last & (fsm_state == FIRST) & ~hmastlock_q &  wvalid & sp_ctrl_is_sparse_q;
  wire logic tr_aw_first_en = fsm_out_en & ~fsm_ctrl.resp.ahb_last & (fsm_state == FIRST) & ~hmastlock_q & awvalid & wvalid;

  always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
      tr_axsize_q           <= '0;
      tr_wraplen_q          <= '0;
      tr_fixed_q            <= '0;
    end
    else if(tr_ar_first_en) begin
      tr_axsize_q           <=  ar.axsize;
      tr_wraplen_q          <= (ar.axburst == AXI_BURST_WRAP) ? ar.axlen[3:0] : '0;
      tr_fixed_q            <= (ar.axburst == AXI_BURST_FIXED);
    end
    else if(tr_sp_cont_en) begin
      tr_axsize_q           <= sp_axsize_tr_q;
      tr_wraplen_q          <= sp_wraplen_tr_q;
      tr_fixed_q            <= sp_tr_is_fixed_q;
    end
    else if(tr_aw_first_en) begin
      tr_axsize_q           <=  aw.axsize;
      tr_wraplen_q          <= (aw.axburst == AXI_BURST_WRAP) ? aw.axlen[3:0] : '0;
      tr_fixed_q            <= (aw.axburst == AXI_BURST_FIXED);
    end
  end

  wire logic rd_left_en     = fsm_out_en & (((fsm_state==FIRST) & arvalid) | (fsm_state==UNM_READ) | (fsm_state==READ));
  always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn)
      rd_left_q             <= '0;
    else if(rd_left_en)
      rd_left_q             <= fsm_out.rd_left;
  end

  always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
      hmastlock_q           <= '0;
      hmastlock_err_q       <= '0;
    end
    else if(fsm_out_en & (fsm_state==FIRST) & (hmastlock_q | arvalid | (awvalid & wvalid))) begin
      hmastlock_q           <= fsm_out.hmastlock;
      hmastlock_err_q       <= fsm_ctrl.resp.bridge_err;
    end
  end


  wire logic tr_rd_first_en = fsm_out_en & |ar.axlen & (fsm_state == FIRST) & ~hmastlock_q & arvalid & ~ctrl_sch_write_boost;
  wire logic tr_wr_first_en = fsm_out_en & |aw.axlen & (fsm_state == FIRST) & ~hmastlock_q & awvalid & wvalid;
  wire logic tr_rd_wr_en    = fsm_out_en & ~fsm_ctrl.resp.ahb_last & ~tr_fixed_q & ((fsm_state==READ) | (wvalid & (fsm_state==WRITE)));
  always_ff @(posedge clk, negedge resetn)
    if (~resetn) begin
      nxt_addr_11_0_q       <= '0;
      nxt_tr_break_q        <= '0;
    end
    else if(tr_rd_first_en) begin
      nxt_addr_11_0_q       <= nxt_ar_fiwaddr_11_0;
      nxt_tr_break_q        <= nxt_ar_tr_break;
    end
    else if(tr_wr_first_en) begin
      nxt_addr_11_0_q       <= nxt_aw_fiwaddr_11_0;
      nxt_tr_break_q        <= nxt_aw_tr_break;
    end
    else if(tr_rd_wr_en) begin
      nxt_addr_11_0_q       <= nxt_iwaddr_11_0;
      nxt_tr_break_q        <= nxt_tr_break;
    end

  wire logic tr_unmr_first_en = fsm_out_en & ~fsm_ctrl.resp.ahb_last & (fsm_state == FIRST) & ~hmastlock_q & arvalid & ar_nonmodif & ar_unaligned & ~ctrl_sch_write_boost;
  wire logic tr_unmr_en       = fsm_out_en & ~fsm_ctrl.resp.ahb_last & (fsm_state == UNM_READ);
  always_ff @(posedge clk, negedge resetn)
    if (~resetn) begin
      tr_unmr_addr_ms_q     <= '0;
      unmr_addr_11_0_q      <= '0;
      unmr_tr_break_q       <= '0;
    end
    else if(tr_unmr_en) begin
      unmr_addr_11_0_q      <= nxt_unmr_fiaddr_11_0;
      unmr_tr_break_q       <= nxt_unmr_tr_break;
    end
    else if(tr_unmr_first_en) begin
      tr_unmr_addr_ms_q     <= ar.axaddr[MAXSIZE-1:0];
      unmr_addr_11_0_q      <= nxt_ar_unmr_fiaddr_11_0;
      unmr_tr_break_q       <= nxt_ar_unmr_tr_break;
    end

  always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
      sp_strb_left_q        <= '0;
      sp_beat_finished_q    <= '0;
      sp_ctrl_is_sparse_q   <= '0;
      sp_wlast_q            <= '0;
    end
    else if (fsm_state_en & fsm_ctrl.sparse) begin
      sp_strb_left_q        <= ((fsm_state == FIRST) & ~sp_ctrl_is_sparse_q) ? sp_aw_strb_left     : sp_strb_left;
      sp_beat_finished_q    <= ((fsm_state == FIRST) & ~sp_ctrl_is_sparse_q) ? sp_aw_beat_finished : sp_beat_finished;
      sp_ctrl_is_sparse_q   <= ~fsm_ctrl.resp.ahb_last;
      sp_wlast_q            <= (w.wlast & fsm_ctrl.wready) | (sp_wlast_q & ~fsm_ctrl.wready);
    end
  end

  always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn)
      sp_beat_is_full_q     <= '0;
    else if (fsm_state_en & fsm_ctrl.sparse & wvalid)
      sp_beat_is_full_q     <= ((fsm_state == FIRST) & ~sp_ctrl_is_sparse_q) ? sp_aw_beat_is_full  : sp_beat_is_full;
  end

  wire logic tr_aw_sp_first_en = fsm_out_en & ~fsm_ctrl.resp.ahb_last & (fsm_state == FIRST) & ~sp_ctrl_is_sparse_q & fsm_ctrl.sparse;
  always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
      sp_trq_q              <= '0;
      sp_axsize_tr_q        <= '0;
      sp_wraplen_tr_q       <= '0;
      sp_tr_is_fixed_q      <= '0;
    end
    else if(tr_aw_sp_first_en) begin
      sp_trq_q              <= aw_trq;
      sp_axsize_tr_q        <= aw.axsize;
      sp_wraplen_tr_q       <= (aw.axburst == AXI_BURST_WRAP) ? aw.axlen[3:0] : '0;
      sp_tr_is_fixed_q      <= (aw.axburst == AXI_BURST_FIXED);
    end
  end

  wire logic tr_sp_en = fsm_state_en & ~fsm_ctrl.resp.ahb_last & sp_ctrl_is_sparse_q & fsm_ctrl.sparse & ~sp_tr_is_fixed_q & sp_beat_finished;
  always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
      sp_addr_11_0_q        <= '0;
      sp_tr_break_q         <= '0;
    end
    else if (tr_aw_sp_first_en) begin
      sp_addr_11_0_q        <= nxt_aw_sp_fiwaddr_11_0;
      sp_tr_break_q         <= nxt_aw_sp_tr_break;
    end
    else if (tr_sp_en) begin
      sp_addr_11_0_q        <= sp_iwaddr_11_0;
      sp_tr_break_q         <= nxt_sp_tr_break;
    end
  end


  assign ctrl_xin_active    = (fsm_state != FIRST) | sp_ctrl_is_sparse_q;

  assign awready            = fsm_out_en & fsm_ctrl.awready;
  assign arready            = fsm_out_en & fsm_ctrl.arready;
  assign wready             = fsm_out_en & fsm_ctrl.wready;

  assign tr_en              = fsm_out_en & (fsm_state == FIRST) &  (arvalid | ((sp_ctrl_is_sparse_q | awvalid) & wvalid));
  assign h_en               = fsm_out_en;
  assign w_en               = wready;

  assign htrans_out         = fsm_out.htrans;
  assign ahb_out.trfix      = ahb_tr;
  assign ahb_out.hfix       = ahb_h;
  assign ahb_out.wdata      = ahb_w;





















endmodule


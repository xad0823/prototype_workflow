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

module xhb500_ahb_to_axi_bridge_external_system_core_addr (

  input  wire logic                                         clk,
  input  wire logic                                         resetn,

  input  wire logic                                         hsel,
  input  wire logic                                         hnonsec,
  input  wire logic [32-1:0]                                haddr,
  input  wire logic [1:0]                                   htrans,
  input  wire logic [1:0]                                   hsize,
  input  wire logic                                         hwrite,
  input  wire logic                                         hready,
  input  wire logic [6:0]                                   hprot,
  input  wire logic [2:0]                                   hburst,
  input  wire logic                                         hmastlock,
  input  wire logic                                         hexcl,
  input  wire logic [1-1:0]                                 hmaster,
  input  wire logic [3:0]                                   hqos,
  input  wire logic [3:0]                                   hregion,
  input  wire logic [3:0]                                   hnsaid,

  output      logic                                         awvalid,
  output      logic [32-1:0]                                awaddr,
  output      logic [1:0]                                   awdomain,
  output      logic [1:0]                                   awburst,
  output      logic [1-1:0]                                 awid,
  output      logic [7:0]                                   awlen,
  output      logic [1:0]                                   awsize,
  output      logic                                         awlock,
  output      logic [2:0]                                   awprot,
  input  wire logic                                         awready,
  output      logic [3:0]                                   awcache,
  output      logic [3:0]                                   awregion,
  output      logic [3:0]                                   awnsaid,
  output      logic [3:0]                                   awqos,

  output      logic                                         arvalid,
  output      logic [32-1:0]                                araddr,
  output      logic [1:0]                                   ardomain,
  output      logic [1:0]                                   arburst,
  output      logic [1-1:0]                                 arid,
  output      logic [7:0]                                   arlen,
  output      logic [1:0]                                   arsize,
  output      logic                                         arlock,
  output      logic [2:0]                                   arprot,
  input  wire logic                                         arready,
  output      logic [3:0]                                   arcache,
  output      logic [3:0]                                   arregion,
  output      logic [3:0]                                   arnsaid,
  output      logic [3:0]                                   arqos,

  output      logic [32-1:0]                                chk_addr,
  input  wire logic                                         hazard,
  input  wire logic                                         hazard_full,
  output      logic                                         hazard_add,
  output      logic [1-1:0]                                 hazard_id,
  output      logic [32-1:0]                                hazard_addr,

  input  wire logic                                         ready_for_read,
  output      logic                                         pause_addr_submit,

  input  wire logic                                         pending_broken_b_resp,
  input  wire logic                                         pending_broken_b_resp_next,
  input  wire logic [1-1:0]                                 pending_broken_b_resp_id,
  input  wire logic [1-1:0]                                 pending_broken_b_resp_id_next,
  input  wire logic                                         ignore_broken_b_resp,
  output      logic                                         address_readyout,

  output      logic                                         addr_idle,
  input  wire logic                                         clk_qacceptn,
  input  wire logic                                         pwr_qacceptn
);

  import xhb500_ahb_to_axi_bridge_external_system_pkg::*;

  typedef struct packed {
    logic                                                  hnonsec;
    logic [32-1:0]                                         haddr;
    logic [1:0]                                            hsize;
    logic                                                  hwrite;
    logic [6:0]                                            hprot;
    ahb_burst_type                                         hburst;
    logic                                                  hexcl;
    logic [1-1:0]                                          hmaster;
    logic [3:0]                                            hqos;
    logic [3:0]                                            hregion;
    logic [3:0]                                            hnsaid;
  } aphase_signals;


  logic                                                    hazard_read;

  logic                                                    cntrl_1_empty;
  logic                                                    cntrl_1_in_valid;
  aphase_signals                                           cntrl_1_in;
  logic                                                    cntrl_1_in_ready;
  logic                                                    cntrl_1_out_valid;
  aphase_signals                                           cntrl_1_out;
  logic                                                    cntrl_1_out_ready;

  logic                                                    cntrl_2_empty;
  logic                                                    cntrl_2_in_valid;
  aphase_signals                                           cntrl_2_in;
  logic                                                    cntrl_2_in_ready;
  logic                                                    cntrl_2_out_valid;
  aphase_signals                                           cntrl_2_out;
  logic                                                    cntrl_2_out_ready;

  axburst_type                                             burst_int;
  logic [3:0]                                              len_int;

  logic                                                    singles_burst;



  assign hazard_read = hazard & ~cntrl_1_out.hwrite;

  always_ff @ (posedge clk or negedge resetn)
  begin : reg_singles_burst
    if (~resetn)
      singles_burst <= 1'b0;
    else
      if (hsel && hready && htrans == TR_NONSEQ)
        singles_burst <= ~hprot[3] || hexcl || hburst == BUR_INCR;
  end


  assign pause_addr_submit = ~clk_qacceptn | ~pwr_qacceptn  |
             (~cntrl_1_out.hwrite &
                  (~ready_for_read ||
                  hazard_read)) |
             (cntrl_1_out.hwrite & cntrl_1_out.hprot[2] & ~cntrl_1_out.hprot[6] &
                  (hazard_full |
                  (((pending_broken_b_resp && pending_broken_b_resp_id == cntrl_1_out.hmaster) ||
                    (pending_broken_b_resp_next && pending_broken_b_resp_id_next == cntrl_1_out.hmaster))
                  & !ignore_broken_b_resp )));


  assign cntrl_1_in_valid = hsel &
                            hready &
                            ~hmastlock &
                            (htrans == TR_NONSEQ ||
                            (htrans == TR_SEQ && (singles_burst) ) );
  assign cntrl_1_in = { hnonsec, haddr, hsize, hwrite, hprot, hburst, hexcl, hmaster, hqos, hregion, hnsaid };

  xhb500_reverse_regd_slice_rst_empty
  #(
    .PAYLD_WIDTH($bits(aphase_signals))
  )
  u_ctrl_st1_regslice_rst
  (
    .clk                (clk),
    .resetn             (resetn),
    .empty              (cntrl_1_empty),
    .valid_src          (cntrl_1_in_valid),
    .payload_src        (cntrl_1_in),
    .ready_src          (cntrl_1_in_ready),
    .valid_dst          (cntrl_1_out_valid),
    .payload_dst        (cntrl_1_out),
    .ready_dst          (cntrl_1_out_ready)
  );

  assign cntrl_1_out_ready = cntrl_2_in_ready && ~pause_addr_submit;
  assign cntrl_2_in_valid = cntrl_1_out_valid && ~pause_addr_submit;
  assign cntrl_2_in = cntrl_1_out;

  xhb500_bypass_regd_slice
  #(
    .PAYLD_WIDTH($bits(aphase_signals))
  )
  u_ctrl_st2_regslice
  (
    .valid_src          (cntrl_2_in_valid),
    .payload_src        (cntrl_2_in),
    .ready_src          (cntrl_2_in_ready),
    .valid_dst          (cntrl_2_out_valid),
    .payload_dst        (cntrl_2_out),
    .ready_dst          (cntrl_2_out_ready)
  );

  assign cntrl_2_empty = 1'b1;

  assign cntrl_2_out_ready = cntrl_2_out.hwrite ? awready : arready;

  always_comb
  begin
    if (cntrl_2_out.hprot[3] & !cntrl_2_out.hexcl)
      case (cntrl_2_out.hburst)
        BUR_SINGLE , BUR_INCR                : burst_int = XBUR_INCR;
        BUR_INCR4  , BUR_INCR8  , BUR_INCR16 : burst_int = XBUR_INCR;
        BUR_WRAP4  , BUR_WRAP8  , BUR_WRAP16 : burst_int = XBUR_WRAP;
        default : burst_int = XBUR_undef;
      endcase
    else
      burst_int = XBUR_INCR;
  end

  assign len_int = calculate_burst_length(
                     cntrl_2_out.hprot[3],
                     cntrl_2_out.hexcl,
                     cntrl_2_out.hburst,
                     cntrl_2_out.hsize,
                     cntrl_2_out.haddr);


  assign address_readyout = cntrl_1_in_ready;

  assign chk_addr  = cntrl_1_out.haddr;

  assign hazard_add  = clk_qacceptn & pwr_qacceptn &
                       cntrl_1_out_valid & cntrl_2_in_ready & cntrl_1_out.hwrite &
                       cntrl_1_out.hprot[2] & ~cntrl_1_out.hprot[6] &
                       ~hazard_full &
                       ~(((pending_broken_b_resp && pending_broken_b_resp_id == cntrl_1_out.hmaster) ||
                          (pending_broken_b_resp_next && pending_broken_b_resp_id_next == cntrl_1_out.hmaster))
                         & !ignore_broken_b_resp );


  assign hazard_id   = cntrl_1_out.hmaster;
  assign hazard_addr = cntrl_1_out.haddr;

  assign addr_idle = cntrl_1_empty & cntrl_2_empty & ~cntrl_1_in_valid;

  assign awaddr        = cntrl_2_out.haddr;
  assign awdomain      = { !cntrl_2_out.hprot[6], 1'b1};
  assign awburst       = burst_int;
  assign awid          = cntrl_2_out.hmaster;
  assign awlen         = {4'd0,len_int};
  assign awsize        = cntrl_2_out.hsize;
  assign awlock        = cntrl_2_out.hexcl;
  assign awprot        = {!cntrl_2_out.hprot[0], cntrl_2_out.hnonsec, cntrl_2_out.hprot[1]};
  assign awcache[3:2]  = cntrl_2_out.hexcl ? 2'b00 :
                                             {cntrl_2_out.hprot[5], cntrl_2_out.hprot[4]};
  assign awcache[1:0]  = {cntrl_2_out.hprot[3], cntrl_2_out.hprot[2] };
  assign awregion      = cntrl_2_out.hregion;
  assign awnsaid       = cntrl_2_out.hnsaid;
  assign awqos         = cntrl_2_out.hqos;

  assign araddr        = awaddr;
  assign ardomain      = awdomain;
  assign arburst       = awburst;
  assign arid          = awid;
  assign arlen         = awlen;
  assign arsize        = awsize;
  assign arlock        = awlock;
  assign arprot        = awprot;
  assign arcache[3:2]  = cntrl_2_out.hexcl ? 2'b00 :
                                             {cntrl_2_out.hprot[4], cntrl_2_out.hprot[5]};
  assign arcache[1:0]  = {cntrl_2_out.hprot[3], cntrl_2_out.hprot[2]};
  assign arregion      = awregion;
  assign arnsaid       = awnsaid;
  assign arqos         = awqos;

  assign arvalid       = cntrl_2_out_valid & ~cntrl_2_out.hwrite;
  assign awvalid       = cntrl_2_out_valid &  cntrl_2_out.hwrite;







endmodule

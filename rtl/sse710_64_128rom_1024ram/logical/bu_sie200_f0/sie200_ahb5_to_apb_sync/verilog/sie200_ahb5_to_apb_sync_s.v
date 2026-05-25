//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2012, 2015-2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Fri Dec 9 09:57:44 2016 +0000
//
//      Revision            : b783292
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------
module sie200_ahb5_to_apb_sync_s #(
    parameter ADDR_WIDTH     = 32,
    parameter MASTER_WIDTH   =  4,
    parameter REGISTER_WDATA =  0,
    parameter QS_POWER_EN    =  1,
    parameter QS_CLOCK_EN    =  1,
    parameter QM_CLOCK_EN    =  1,
    parameter QS_SYNC        =  0,
    parameter EXT_GATE_SYNC  =  0

  )
 (
  input  wire                             hclk,
  input  wire                             hresetn,

  input  wire                             hsel,
  input  wire            [ADDR_WIDTH-1:0] haddr,
  input  wire                       [1:0] htrans,
  input  wire                       [2:0] hsize,
  input  wire                       [6:0] hprot,
  input  wire                             hwrite,
  input  wire                             hready,
  input  wire                      [31:0] hwdata,
  input  wire                             hnonsec,
  input  wire          [MASTER_WIDTH-1:0] hmaster,

  output wire                             hreadyout,
  output wire                      [31:0] hrdata,
  output wire                             hresp,

  output wire                             apb_trnf_req,
  input  wire                             apb_trnf_ack,

  input  wire                             pslverr_i,
  input  wire                      [31:0] prdata_r,
  output wire          [MASTER_WIDTH-1:0] pmaster_i,
  output wire            [ADDR_WIDTH-1:0] paddr_i,
  output wire                             pwrite_i,
  output wire                       [3:0] pstrb_i,
  output wire                       [2:0] pprot_i,
  output wire                      [31:0] pwdata_i,

  output wire                             hclk_qactive_s,
  input  wire                             hclk_qreqn_s,
  output wire                             hclk_qacceptn_s,
  output wire                             hclk_qdeny_s,

  output wire                             pwr_qactive_s,
  input  wire                             pwr_qreqn_s,
  output wire                             pwr_qacceptn_s,
  output wire                             pwr_qdeny_s,

  input  wire                             ext_gate_req,
  output wire                             ext_gate_ack,
  input  wire                             cfg_gate_resp,

  output wire                             s_active_reg,
  output wire                             pwr_ext_wake,
  input  wire                             m_ext_wake,
  input  wire                             m_lp_req_n,
  output wire                             m_lp_done_n,

  output wire                             pwr_lp_req_n,
  input  wire                             pwr_lp_done_n

  );

  wire        hold_en;
  wire        pend_trans;
  wire        s_active;
  wire        brg_pwr_req_s;

  wire [MASTER_WIDTH-1:0]  pmaster_g;
  wire   [ADDR_WIDTH-1:0]  paddr_g  ;
  wire                     pwrite_g ;
  wire              [3:0]  pstrb_g  ;
  wire              [2:0]  pprot_g  ;
  wire             [31:0]  pwdata_g ;
  wire                     pslverr_g;
  wire             [31:0]  prdata_g ;

  wire [2:0]  unused;


  assign unused = {hprot[6:4]};

     sie200_ahb5_to_apb_sync_core_s #(
      .ADDR_WIDTH (ADDR_WIDTH),
      .MASTER_WIDTH (MASTER_WIDTH),
      .REGISTER_WDATA (REGISTER_WDATA)
      )
     u_ahb5_to_apb_sync_ahbs (
      .hclk            (hclk),
      .hresetn         (hresetn),
      .hsel            (hsel),
      .haddr           (haddr),
      .htrans          (htrans),
      .hsize           (hsize),
      .hprot           (hprot[3:0]),
      .hwrite          (hwrite),
      .hready          (hready),
      .hwdata          (hwdata),
      .hnonsec         (hnonsec),
      .hmaster         (hmaster),
      .hreadyout       (hreadyout),
      .hrdata          (hrdata),
      .hresp           (hresp),
      .apb_trnf_req    (apb_trnf_req),
      .apb_trnf_ack    (apb_trnf_ack),
      .cfg_gate_resp   (cfg_gate_resp),
      .pslverr         (pslverr_g),
      .prdata_r        (prdata_g),
      .hold_en         (hold_en),
      .pend_trans      (pend_trans),
      .s_active        (s_active),
      .pmaster         (pmaster_g),
      .paddr           (paddr_g),
      .pwrite          (pwrite_g),
      .pstrb           (pstrb_g),
      .pprot           (pprot_g),
      .pwdata          (pwdata_g)
     );

    sie200_ahb5_access_ctrl_core_s # (
    .QCLK_SYNC          (1'b1),
    .QS_CLOCK_EN        (QS_CLOCK_EN),
    .QM_CLOCK_EN        (QM_CLOCK_EN),
    .QS_POWER_EN        (QS_POWER_EN),
    .QS_SYNC            (QS_SYNC),
    .EXT_GATE_SYNC      (EXT_GATE_SYNC))
    u_acg_s (
    .hclk_s             (hclk),
    .hresetn_s          (hresetn),

    .hclk_qactive_s     (hclk_qactive_s),
    .hclk_qreqn_s       (hclk_qreqn_s),
    .hclk_qacceptn_s    (hclk_qacceptn_s),
    .hclk_qdeny_s       (hclk_qdeny_s),

    .pwr_qactive_s      (pwr_qactive_s),
    .pwr_qreqn_s        (pwr_qreqn_s),
    .pwr_qacceptn_s     (pwr_qacceptn_s),
    .pwr_qdeny_s        (pwr_qdeny_s),

    .brg_pwr_req_s      (brg_pwr_req_s),
    .brg_pwr_ack_s      (brg_pwr_req_s),

    .ext_gate_req       (ext_gate_req),
    .ext_gate_ack       (ext_gate_ack),

    .hold_en            (hold_en),
    .pend_trans         (pend_trans),
    .s_active           (s_active),

    .s_active_reg       (s_active_reg),
    .pwr_ext_wake       (pwr_ext_wake),
    .m_ext_wake         (m_ext_wake),
    .m_lp_req_n         (m_lp_req_n),
    .m_lp_done_n        (m_lp_done_n),
    .pwr_lp_req_n       (pwr_lp_req_n),
    .pwr_lp_done_n      (pwr_lp_done_n)
    );


    generate
      if (QS_POWER_EN)
        begin : power_down_s
          localparam ISO_WIDTH = MASTER_WIDTH + ADDR_WIDTH + 73;
          sie200_and #(.DATA_WIDTH(ISO_WIDTH)) u_sie200_and (
          .in_a  ({pmaster_g,paddr_g,pwrite_g,pstrb_g,pprot_g,pwdata_g,pslverr_i,prdata_r}),
          .in_b  ({(ISO_WIDTH){~brg_pwr_req_s}}),
          .out_y ({pmaster_i,paddr_i,pwrite_i,pstrb_i,pprot_i,pwdata_i,pslverr_g,prdata_g})
          );
        end
      else
        begin : functional_s
          assign {pmaster_i,paddr_i,pwrite_i,pstrb_i,pprot_i,pwdata_i,pslverr_g,prdata_g} =
                 {pmaster_g,paddr_g,pwrite_g,pstrb_g,pprot_g,pwdata_g,pslverr_i,prdata_r};
        end
    endgenerate




endmodule


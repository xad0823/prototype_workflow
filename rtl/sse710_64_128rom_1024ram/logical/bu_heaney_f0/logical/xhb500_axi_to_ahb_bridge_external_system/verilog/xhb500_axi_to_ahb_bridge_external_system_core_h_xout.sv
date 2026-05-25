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

module xhb500_axi_to_ahb_bridge_external_system_core_h_xout
(


  input  wire logic                                                   clk,
  input  wire logic                                                   resetn,

  output      logic                                                   ctrl_h_xout_active,

  input  wire logic                                            [1:0]  htrans_in,
  input  wire xhb500_axi_to_ahb_bridge_external_system_pkg::ahb_mpayld_t                    ahb_in,

  output wire logic                                                   hready_out,

  output      logic                                            [1:0]  htrans,
  output      xhb500_axi_to_ahb_bridge_external_system_pkg::ahb_mpayld_t                    hmpayld,

  input  wire logic                                                   hready,
  input  wire xhb500_axi_to_ahb_bridge_external_system_pkg::ahb_spayld_t                    hspayld,


  output      logic                                                   rvalid,
  input  wire logic                                                   rready,
  output      xhb500_axi_to_ahb_bridge_external_system_pkg::axi_rpayld_t                    rpayld,

  output      logic                                                   bvalid,
  input  wire logic                                                   bready,
  output      xhb500_axi_to_ahb_bridge_external_system_pkg::axi_bpayld_t                    bpayld
);

  wire xhb500_axi_to_ahb_bridge_external_system_pkg::ahb_spayld_t                           hs = hspayld;

  typedef enum logic [1:0] {AHB_TRANS_IDLE  = 2'b00, AHB_TRANS_BUSY  = 2'b01, AHB_TRANS_NONSEQ = 2'b10, AHB_TRANS_SEQ=2'b11} ahb_trans_t;
  typedef enum logic [1:0] {AXI_RESP_OKAY   = 2'b00, AXI_RESP_EXOKAY = 2'b01, AXI_RESP_SLVERR  = 2'b10}                      axi_resp_t;



  logic                                       resp_trans_valid_q;
  xhb500_axi_to_ahb_bridge_external_system_pkg::xhb_ahb_addrph_t    ahb_addrph_q;

  wire logic                                  resp_ctrl_accept_rd;
  wire logic                                  resp_ctrl_accept_wr;

  wire logic resp_ctrl_hold_excl  = resp_trans_valid_q & ahb_in.trfix.ctrl_exclid;

  wire logic resp_ctrl_hold_trans = resp_ctrl_hold_excl | (~resp_ctrl_accept_rd & ~ahb_in.trfix.hwrite) | (~resp_ctrl_accept_wr & ahb_in.trfix.hwrite);

  logic [1:0] hold_htrans;

  always_comb begin
    if (resp_ctrl_hold_trans) begin
      case(htrans_in)
        AHB_TRANS_NONSEQ    : hold_htrans = AHB_TRANS_IDLE;
        AHB_TRANS_SEQ       : hold_htrans = AHB_TRANS_BUSY;
        AHB_TRANS_IDLE      : hold_htrans = AHB_TRANS_IDLE;
        AHB_TRANS_BUSY      : hold_htrans = AHB_TRANS_BUSY;
        default             : hold_htrans =      {2{1'bx}};
      endcase
    end
    else
      hold_htrans           = htrans_in;

  end

  assign hready_out         = hready & ~resp_ctrl_hold_trans;


  assign htrans             = hold_htrans;
  assign hmpayld            = ahb_in;




  wire logic sp_empty_valid       = hready_out & ahb_in.hfix.resp_ctrl.sp_empty;
  wire logic resp_trans_valid     = hready & ((htrans == AHB_TRANS_NONSEQ) |  (htrans == AHB_TRANS_SEQ) |  sp_empty_valid);
  wire logic resp_trans_invalid   = hready & ~(htrans == AHB_TRANS_NONSEQ) & ~(htrans == AHB_TRANS_SEQ) & ~sp_empty_valid;


  xhb500_axi_to_ahb_bridge_external_system_pkg::xhb_ahb_addrph_t    ahb_addrph;

  assign ahb_addrph.haddr_strb    = ahb_in.hfix.haddr_11_0[$clog2(4)-1:0];
  assign ahb_addrph.hsize         = ahb_in.hfix.hsize;
  assign ahb_addrph.hwrite        = ahb_in.trfix.hwrite;
  assign ahb_addrph.axid          = ahb_in.trfix.trfixq.hmaster;
  assign ahb_addrph.ctrl          = ahb_in.hfix.resp_ctrl;

  always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
      ahb_addrph_q          <= '0;
    end
    else if(resp_trans_valid) begin
      ahb_addrph_q          <= ahb_addrph;
    end
  end

  always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
      resp_trans_valid_q    <= '0;
    end
    else if((resp_trans_valid & ~resp_trans_valid_q) | (resp_trans_invalid & resp_trans_valid_q)) begin
      resp_trans_valid_q    <= ~resp_trans_valid_q;
    end
  end

  wire logic acc_trans_valid      = resp_trans_valid_q & hready;
  wire logic acc_valid_nohready   = resp_trans_valid_q;

  wire logic acc_rvalid_nohready  = resp_trans_valid_q & ahb_addrph_q.ctrl.rvalid;
  wire logic acc_rvalid           =  acc_trans_valid   & ahb_addrph_q.ctrl.rvalid;
  wire logic acc_rlast            =  acc_trans_valid   & ahb_addrph_q.ctrl.ahb_last & ~ahb_addrph_q.hwrite;
  wire logic acc_bvalid_nohready  = resp_trans_valid_q & ahb_addrph_q.ctrl.ahb_last &  ahb_addrph_q.hwrite;
  wire logic acc_bvalid           =  acc_trans_valid   & ahb_addrph_q.ctrl.ahb_last &  ahb_addrph_q.hwrite;


  logic      [32-1:0]                     acc_hrdata_q;
  logic                                   acc_hresp_q;
  logic                                   acc_hresp_wr_q;


  wire logic [4-1:0] acc_wstrb_mask;
  xhb500_axi_to_ahb_bridge_external_system_strbgen u_strb_mask
  (
    .addr_in  (ahb_addrph_q.haddr_strb),
    .size_in  (ahb_addrph_q.hsize),

    .strb     (acc_wstrb_mask)
  );

  wire logic [32-1:0] acc_mask;
  genvar i;
  for (i = 0; i < 4; i=i+1) begin: g_mask
    assign acc_mask[8*i+7:8*i]    = {8{acc_wstrb_mask[i]}};
    end

  wire logic acc_hrdata_clr  = acc_trans_valid & ~ahb_addrph_q.hwrite & ahb_addrph_q.ctrl.resp_acc & ahb_addrph_q.ctrl.rvalid;
  wire logic [32-1:0] acc_hrdata_en = {32{acc_trans_valid & ~ahb_addrph_q.hwrite & ~ahb_addrph_q.ctrl.rvalid}} & acc_mask;

  genvar i_out;
  for (i_out = 0; i_out < 32; i_out=i_out+1) begin: g_hrdata
    if(~|((4-(i_out/8)) & ((4-1)-(i_out/8)))) begin: g_hrdata_unused
      always_comb begin
        acc_hrdata_q[i_out]      = '0;
      end
    end
    else begin: g_hrdata_used
      always_ff @ (posedge clk, negedge resetn) begin
        if(~resetn)
          acc_hrdata_q[i_out]   <= '0;
        else if(acc_hrdata_clr)
          acc_hrdata_q[i_out]   <= '0;
        else if(acc_hrdata_en[i_out])
          acc_hrdata_q[i_out]   <= hs.hrdata[i_out];
      end
    end
  end

  wire logic [32-1:0] acc_hrdata = (acc_hrdata_q & {32{ahb_addrph_q.ctrl.resp_acc}}) | (hs.hrdata & acc_mask);
  wire logic [1:0] acc_hresp      = (ahb_addrph_q.ctrl.bridge_err | (acc_hresp_q & ahb_addrph_q.ctrl.resp_acc) | hs.hresp) ?  AXI_RESP_SLVERR :
                                                          (hs.hexokay ?  AXI_RESP_EXOKAY : AXI_RESP_OKAY);
  wire logic [1:0] acc_hresp_wr   = (ahb_addrph_q.hwrite & (ahb_addrph_q.ctrl.bridge_err | (acc_hresp_wr_q & ahb_addrph_q.ctrl.resp_acc) | (~ahb_addrph_q.ctrl.sp_empty & hs.hresp))) ?  AXI_RESP_SLVERR :
                                                          (hs.hexokay ?  AXI_RESP_EXOKAY : AXI_RESP_OKAY);

  always_ff @ (posedge clk, negedge resetn) begin
    if(~resetn) begin
      acc_hresp_q           <= '0;
      acc_hresp_wr_q        <= '0;
    end
    else if(acc_trans_valid) begin
      if(~ahb_addrph_q.ctrl.rvalid & ~ahb_addrph_q.hwrite) begin
        acc_hresp_q         <= (acc_hresp == AXI_RESP_SLVERR);
      end
      if(ahb_addrph_q.hwrite) begin
        acc_hresp_wr_q      <= (acc_hresp_wr == AXI_RESP_SLVERR);
      end
    end
  end


  wire logic rreg_rempty;
  wire xhb500_axi_to_ahb_bridge_external_system_pkg::axi_rpayld_t  rreg_rpayld_in;

  assign rreg_rpayld_in.rid   = ahb_addrph_q.axid;
  assign rreg_rpayld_in.rdata = acc_hrdata;
  assign rreg_rpayld_in.rlast = acc_rlast;
  assign rreg_rpayld_in.rresp = acc_hresp;

  xhb500_axi_to_ahb_bridge_external_system_respreg_r
  #(
  .PAYLD_WIDTH          ($bits(xhb500_axi_to_ahb_bridge_external_system_pkg::axi_rpayld_t))
  ) u_respreg_r
  (
    .clk                (clk),
    .resetn             (resetn),

    .valid_in           (acc_rvalid),
    .valid_in_nohready  (acc_rvalid_nohready),

    .payld_in           (rreg_rpayld_in),
    .ready_dst          (rready),

    .valid_out          (rvalid),
    .payld_out          (rpayld),

    .empty              (rreg_rempty),
    .accept_ctrl_out    (resp_ctrl_accept_rd)
  );

  wire logic rreg_bempty;
  wire xhb500_axi_to_ahb_bridge_external_system_pkg::axi_bpayld_t    rreg_bpayld_in;

  assign rreg_bpayld_in.bid   = ahb_addrph_q.axid;
  assign rreg_bpayld_in.bresp = acc_hresp_wr;

  xhb500_axi_to_ahb_bridge_external_system_respreg_b
  #(
  .PAYLD_WIDTH          ($bits(xhb500_axi_to_ahb_bridge_external_system_pkg::axi_bpayld_t))
  ) u_respreg_b
  (
    .clk                (clk),
    .resetn             (resetn),

    .valid_in           (acc_bvalid),
    .valid_in_nohready  (acc_bvalid_nohready),

    .payld_in           (rreg_bpayld_in),
    .ready_dst          (bready),

    .valid_out          (bvalid),
    .payld_out          (bpayld),

    .empty              (rreg_bempty),
    .accept_ctrl_out    (resp_ctrl_accept_wr)
  );

  assign ctrl_h_xout_active = acc_valid_nohready | ~rreg_rempty | ~rreg_bempty;














endmodule


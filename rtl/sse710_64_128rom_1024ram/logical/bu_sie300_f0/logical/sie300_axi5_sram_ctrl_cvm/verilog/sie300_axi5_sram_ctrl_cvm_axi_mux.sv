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
//      Checked In          : Tue Apr 30 09:07:02 2019 +0100
//
//      Revision            : 1dc2da2f
//
//      Release Information : CoreLink SIE-300 Generic Global Bundle r1p2-00rel0
//
//----------------------------------------------------------------------------

module sie300_axi5_sram_ctrl_cvm_axi_mux
(
  output      logic                                           arready,
  output      logic                                           rvalid,
  output      logic [1                        :0]             rresp,
  output      logic                                           rlast,
  output      logic [12-1       :0]                           rid,
  output      logic [64-1     :0]                             rdata,
  output      logic [1-1     :0]                              rpoison,
  output      logic                                           awready,
  output      logic                                           wready,
  output      logic                                           bvalid,
  output      logic [1                        :0]             bresp,
  output      logic [12-1       :0]                           bid,

  input  wire logic                                           arready_q,
  input  wire logic                                           rvalid_q,
  input  wire logic [1                        :0]             rresp_q,
  input  wire logic                                           rlast_q,
  input  wire logic [12-1       :0]                           rid_q,
  input  wire logic [64-1     :0]                             rdata_q,
  input  wire logic [1-1     :0]                              rpoison_q,
  input  wire logic                                           awready_q,
  input  wire logic                                           wready_q,
  input  wire logic                                           bvalid_q,
  input  wire logic [1                        :0]             bresp_q,
  input  wire logic [12-1       :0]                           bid_q,

  input  wire logic                                           arready_r,
  input  wire logic                                           rvalid_r,
  input  wire logic [1                        :0]             rresp_r,
  input  wire logic                                           rlast_r,
  input  wire logic [12-1       :0]                           rid_r,
  input  wire logic                                           awready_r,
  input  wire logic                                           wready_r,
  input  wire logic                                           bvalid_r,
  input  wire logic [1                        :0]             bresp_r,
  input  wire logic [12-1       :0]                           bid_r,

  input  wire logic                                           sel_resp_path
);


  always_comb begin : mux_resp
    if (sel_resp_path) begin
      arready     = arready_r;
      rvalid      = rvalid_r;
      rresp       = rresp_r;
      rlast       = rlast_r;
      rid         = rid_r;
      rdata       = '0;
      rpoison     = '0;
      awready     = awready_r;
      wready      = wready_r;
      bvalid      = bvalid_r;
      bresp       = bresp_r;
      bid         = bid_r;
    end
    else begin
      arready     = arready_q;
      rvalid      = rvalid_q;
      rresp       = rresp_q;
      rlast       = rlast_q;
      rid         = rid_q;
      rdata       = rdata_q;
      rpoison     = rpoison_q;
      awready     = awready_q;
      wready      = wready_q;
      bvalid      = bvalid_q;
      bresp       = bresp_q;
      bid         = bid_q;
    end
  end

endmodule

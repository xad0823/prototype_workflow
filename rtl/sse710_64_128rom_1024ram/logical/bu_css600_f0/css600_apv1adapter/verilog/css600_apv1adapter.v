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
//   Top level of css600_apv1adapter
//
//----------------------------------------------------------------------------


module css600_apv1adapter #(parameter
  REVAND = 4'h0)
(
  clk,
  reset_n,
  dp_abort,
  psel_s,
  penable_s,
  pwrite_s,
  paddr_s,
  pwdata_s,
  pready_s,
  pslverr_s,
  prdata_s,
  dapsel_m,
  dapenable_m,
  dapwrite_m,
  dapcaddr_m,
  dapwdata_m,
  dapready_m,
  dapslverr_m,
  daprdata_m,
  dapabort_m
  );

  input  wire        clk;
  input  wire        reset_n;

  input  wire        dp_abort;

  input  wire        psel_s;
  input  wire        penable_s;
  input  wire        pwrite_s;
  input  wire [11:0] paddr_s;
  input  wire [31:0] pwdata_s;
  output wire        pready_s;
  output wire        pslverr_s;
  output wire [31:0] prdata_s;

  output wire        dapsel_m;
  output wire        dapenable_m;
  output wire        dapwrite_m;
  output wire [7:0]  dapcaddr_m;
  output wire [31:0] dapwdata_m;
  input  wire        dapready_m;
  input  wire        dapslverr_m;
  input  wire [31:0] daprdata_m;
  output wire        dapabort_m;


  wire        psel_mgmt;
  wire        psel_res;
  wire        ime;
  wire        itdapabort_rd;
  wire        itdapabort_rd_data;
  wire        claim_set_wr;
  wire        claim_set_rd;
  wire [1:0]  claim_set_wr_data;
  wire [1:0]  claim_set_rd_data;
  wire        claim_clr_wr;
  wire        claim_clr_rd;
  wire [1:0]  claim_clr_wr_data;
  wire [1:0]  claim_clr_rd_data;
  wire        pready_mgmt;
  wire [31:0] prdata_mgmt;
  wire [11:0] paddr_int = {paddr_s[11:2], 2'b00};
  wire [3:0]  w_revand;
  wire [31:0] prdata_mstr;

  css600_apv1adapter_decoder u_decoder(
    .paddr_s               (paddr_s),
    .psel_s                (psel_s),
    .penable_s             (penable_s),
    .pwrite_s              (pwrite_s),
    .pwdata_s              (pwdata_s),
    .psel_mgmt             (psel_mgmt),
    .psel_res              (psel_res),
    .dapcaddr_m            (dapcaddr_m),
    .dapsel_m              (dapsel_m),
    .dapenable_m           (dapenable_m),
    .dapwrite_m            (dapwrite_m),
    .dapwdata_m            (dapwdata_m)
  );

  css600_apv1adapter_reg_block
  #(.APB_ADDR_WIDTH (12)) u_reg_block
  (
    .pclk                  (clk),
    .preset_n              (reset_n),
    .ime                   (ime),
    .itdpabort_rd          (itdapabort_rd),
    .itdpabort_rd_data     (itdapabort_rd_data),
    .claim_set_wr          (claim_set_wr),
    .claim_set_wr_data     (claim_set_wr_data),
    .claim_set_rd          (claim_set_rd),
    .claim_set_rd_data     (claim_set_rd_data),
    .claim_clr_wr          (claim_clr_wr),
    .claim_clr_wr_data     (claim_clr_wr_data),
    .claim_clr_rd          (claim_clr_rd),
    .claim_clr_rd_data     (claim_clr_rd_data),
    .psel                  (psel_mgmt),
    .penable               (penable_s),
    .paddr                 (paddr_int),
    .pwrite                (pwrite_s),
    .pwdata                (pwdata_s),
    .prdata                (prdata_mgmt),
    .pready                (pready_mgmt),
    .revand                (w_revand)
  );

  css600_claimtags u_claimtags (
    .clk                   (clk),
    .reset_n               (reset_n),
    .claim_set_wr          (claim_set_wr),
    .claim_set_wr_data     (claim_set_wr_data),
    .claim_set_rd          (claim_set_rd),
    .claim_set_rd_data     (claim_set_rd_data),
    .claim_clr_wr          (claim_clr_wr),
    .claim_clr_wr_data     (claim_clr_wr_data),
    .claim_clr_rd          (claim_clr_rd),
    .claim_clr_rd_data     (claim_clr_rd_data)
  );

  css600_apv1adapter_itregs u_itregs(
    .clk                   (clk),
    .reset_n               (reset_n),
    .ime                   (ime),
    .itdapabort_rd         (itdapabort_rd),
    .itdapabort_rd_data    (itdapabort_rd_data),
    .dp_abort              (dp_abort),
    .dapabort              (dapabort_m)
  );


  assign prdata_mstr = dapslverr_m ? 32'h00000000 : daprdata_m;

  css600_one_hot_mux
  #(
    .SEL_WIDTH (3),
    .DATA_WIDTH (34)
  )
  u_apd_rdata_mux
  (
    .inp_sel               ({dapsel_m, psel_mgmt, psel_res}),
    .inp_data              ({dapready_m, dapslverr_m, prdata_mstr,
                             pready_mgmt, 1'b0, prdata_mgmt,
                             1'b1, 1'b0, 32'h00000000}),
    .out_data              ({pready_s, pslverr_s, prdata_s})
  );

  css600_ecorevnum #(.WIDTH(4), .ECOREVVAL(REVAND))
    u_css600_ecorevnum (.ecorevnum(w_revand));

endmodule

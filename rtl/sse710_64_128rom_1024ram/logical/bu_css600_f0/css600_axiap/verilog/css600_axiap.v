//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017, 2019-2020 Arm Limited or its affiliates.
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
//   Top level of css600_axiap
//
//----------------------------------------------------------------------------


module css600_axiap #(parameter
  AXI_ADDR_WIDTH        = 32,
  AXI_DATA_WIDTH        = 32,
  FF_SYNC_DEPTH         = 2,
  REVAND                = 4'h0
)
(
  clk,
  reset_n,
  dftcgen,
  pwakeup_s,
  psel_s,
  penable_s,
  pwrite_s,
  paddr_s,
  pwdata_s,
  pready_s,
  pslverr_s,
  prdata_s,
  clk_qreq_n,
  clk_qaccept_n,
  clk_qactive,
  clk_qdeny,
  ap_en,
  ap_secure_en,
  baseaddr_valid,
  baseaddr,
  dp_abort,
  arlock_m,
  arvalid_m,
  arready_m,
  rlast_m,
  rvalid_m,
  rready_m,
  awlock_m,
  awvalid_m,
  awready_m,
  wlast_m,
  wvalid_m,
  wready_m,
  bvalid_m,
  bready_m,
  arlen_m,
  arburst_m,
  arcache_m,
  arprot_m,
  rresp_m,
  awlen_m,
  awburst_m,
  awcache_m,
  awprot_m,
  bresp_m,
  awdomain_m,
  awsnoop_m,
  ardomain_m,
  arsnoop_m,
  araddr_m,
  arsize_m,
  rdata_m,
  awaddr_m,
  awsize_m,
  wdata_m,
  wstrb_m,
  awakeup_m
);

  localparam L_MTE_PRESENT     =                                  0
                               ;
  localparam L_MTE_TAG_WIDTH   =                                  4
                               ;
  localparam L_MTE_TAG_GRANULE =                                  4
                               ;
  localparam L_AXI_ADDR_WIDTH  = (L_MTE_PRESENT               ) ? 64
                               : (AXI_ADDR_WIDTH == 64        ) ? 64
                               :                                  32
                               ;
  localparam L_AXI_DATA_WIDTH  = (L_MTE_PRESENT               ) ? 128
                               : (AXI_DATA_WIDTH == 64        ) ? 64
                               :                                  32
                               ;
  localparam L_AXI_WSTRB_WIDTH = (L_AXI_DATA_WIDTH      == 128) ? 16
                               : (L_AXI_DATA_WIDTH      == 64 ) ? 8
                               :                                  4
                               ;
  localparam L_FF_SYNC_DEPTH   = (FF_SYNC_DEPTH         == 3  ) ? 3
                               :                                  2
                               ;


  input  wire                          clk;
  input  wire                          reset_n;
  input  wire                          dftcgen;
  input  wire                          psel_s;
  input  wire                          penable_s;
  input  wire                          pwrite_s;
  output wire                          pready_s;
  output wire                          pslverr_s;
  input  wire [12:0]                   paddr_s;
  input  wire [31:0]                   pwdata_s;
  output wire [31:0]                   prdata_s;
  input  wire                          pwakeup_s;
  input  wire                          clk_qreq_n;
  output wire                          clk_qaccept_n;
  output wire                          clk_qactive;
  output wire                          clk_qdeny;
  input  wire                          ap_en;
  input  wire                          ap_secure_en;
  input  wire                          baseaddr_valid;
  input  wire [L_AXI_ADDR_WIDTH-1:0]   baseaddr;
  input  wire                          dp_abort;
  output wire                          arlock_m;
  output wire                          arvalid_m;
  input  wire                          arready_m;
  input  wire                          rlast_m;
  input  wire                          rvalid_m;
  output wire                          rready_m;
  output wire                          awlock_m;
  output wire                          awvalid_m;
  input  wire                          awready_m;
  output wire                          wlast_m;
  output wire                          wvalid_m;
  input  wire                          wready_m;
  input  wire                          bvalid_m;
  output wire                          bready_m;
  output wire [7:0]                    arlen_m;
  output wire [1:0]                    arburst_m;
  output wire [3:0]                    arcache_m;
  output wire [2:0]                    arprot_m;
  input  wire [1:0]                    rresp_m;
  output wire [7:0]                    awlen_m;
  output wire [1:0]                    awburst_m;
  output wire [3:0]                    awcache_m;
  output wire [2:0]                    awprot_m;
  input  wire [1:0]                    bresp_m;
  output wire [1:0]                    awdomain_m;
  output wire [2:0]                    awsnoop_m;
  output wire [1:0]                    ardomain_m;
  output wire [3:0]                    arsnoop_m;
  output wire [L_AXI_ADDR_WIDTH - 1:0] araddr_m;
  output wire [2:0]                    arsize_m;
  input  wire [L_AXI_DATA_WIDTH - 1:0] rdata_m;
  output wire [L_AXI_ADDR_WIDTH - 1:0] awaddr_m;
  output wire [2:0]                    awsize_m;
  output wire [L_AXI_DATA_WIDTH - 1:0] wdata_m;
  output wire [L_AXI_WSTRB_WIDTH-1:0]  wstrb_m;
  output wire                          awakeup_m;


  wire [3:0] w_revand;

  css600_axiap_core
  #(
    .AXI_ADDR_WIDTH        (L_AXI_ADDR_WIDTH),
    .AXI_DATA_WIDTH        (L_AXI_DATA_WIDTH),
    .AXI_WSTRB_WIDTH       (L_AXI_WSTRB_WIDTH),
    .MTE_PRESENT           (L_MTE_PRESENT),
    .MTE_TAG_WIDTH         (L_MTE_TAG_WIDTH),
    .MTE_TAG_GRANULE       (L_MTE_TAG_GRANULE),
    .FF_SYNC_DEPTH         (L_FF_SYNC_DEPTH)
  )
  u_css600_axiap_core
  (
    .clk            (clk           ),
    .reset_n        (reset_n       ),
    .pwakeup_s      (pwakeup_s     ),
    .psel_s         (psel_s        ),
    .penable_s      (penable_s     ),
    .pwrite_s       (pwrite_s      ),
    .paddr_s        (paddr_s       ),
    .pwdata_s       (pwdata_s      ),
    .pready_s       (pready_s      ),
    .pslverr_s      (pslverr_s     ),
    .prdata_s       (prdata_s      ),
    .clk_qreq_n     (clk_qreq_n    ),
    .clk_qaccept_n  (clk_qaccept_n ),
    .clk_qactive    (clk_qactive   ),
    .clk_qdeny      (clk_qdeny     ),
    .ap_en          (ap_en         ),
    .ap_secure_en   (ap_secure_en  ),
    .baseaddr_valid (baseaddr_valid),
    .baseaddr       (baseaddr      ),
    .dp_abort       (dp_abort      ),
    .arlock_m       (arlock_m      ),
    .arvalid_m      (arvalid_m     ),
    .arready_m      (arready_m     ),
    .rlast_m        (rlast_m       ),
    .rvalid_m       (rvalid_m      ),
    .rready_m       (rready_m      ),
    .awlock_m       (awlock_m      ),
    .awvalid_m      (awvalid_m     ),
    .awready_m      (awready_m     ),
    .wlast_m        (wlast_m       ),
    .wvalid_m       (wvalid_m      ),
    .wready_m       (wready_m      ),
    .bvalid_m       (bvalid_m      ),
    .bready_m       (bready_m      ),
    .arlen_m        (arlen_m       ),
    .arburst_m      (arburst_m     ),
    .arcache_m      (arcache_m     ),
    .arprot_m       (arprot_m      ),
    .rresp_m        (rresp_m       ),
    .awlen_m        (awlen_m       ),
    .awburst_m      (awburst_m     ),
    .awcache_m      (awcache_m     ),
    .awprot_m       (awprot_m      ),
    .bresp_m        (bresp_m       ),
    .awdomain_m     (awdomain_m    ),
    .awsnoop_m      (awsnoop_m     ),
    .ardomain_m     (ardomain_m    ),
    .arsnoop_m      (arsnoop_m     ),
    .araddr_m       (araddr_m      ),
    .arsize_m       (arsize_m      ),
    .rdata_m        (rdata_m       ),
    .awaddr_m       (awaddr_m      ),
    .awsize_m       (awsize_m      ),
    .wdata_m        (wdata_m       ),
    .wstrb_m        (wstrb_m       ),
    .awakeup_m      (awakeup_m     ),
    .awtagop_m      (              ),
    .wtagupdate_m   (              ),
    .wtag_m         (              ),
    .artagop_m      (              ),
    .rtag_m         ({L_MTE_TAG_WIDTH{1'b0}}),

    .dftcgen        (dftcgen       ),

    .revand         (w_revand      )
  );

  css600_ecorevnum #(.WIDTH(4), .ECOREVVAL(REVAND))
    u_css600_ecorevnum (.ecorevnum(w_revand));

endmodule

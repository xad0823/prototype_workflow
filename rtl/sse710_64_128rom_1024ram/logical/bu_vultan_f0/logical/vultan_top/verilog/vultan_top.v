// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2017 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Thu Oct 26 20:14:53 2017 +0100
//
//      Revision            : 599abeb
//
//      Release Information : Vultan Generic Flash Controller - Global Bundle r0p0-00rel0
//
//-----------------------------------------------------------------------------

module vultan_top (
   input  wire             clk,
   input  wire             resetn,

   input  wire             hsel,
   input  wire [21:0]      haddr,
   input  wire [1:0]       htrans,
   input  wire             hwrite,
   input  wire [2:0]       hsize,
   input  wire [2:0]       hburst,
   input  wire             hmastlock,
   input  wire             hready,
   output wire             hreadyout,
   output wire             hresp,
   output wire [127:0]     hrdata,

   input  wire             psel_s,
   input  wire             penable_s,
   input  wire [12:0]      paddr_s,
   input  wire             pwrite_s,
   input  wire [3:0]       pstrb_s,
   input  wire [31:0]      pwdata_s,
   output wire [31:0]      prdata_s,
   output wire             pready_s,
   output wire             pslverr_s,

   output wire             psel_m,
   output wire             penable_m,
   output wire [11:0]      paddr_m,
   output wire             pwrite_m,
   output wire [3:0]       pstrb_m,
   output wire [31:0]      pwdata_m,
   input  wire [31:0]      prdata_m,
   input  wire             pready_m,
   input  wire             pslverr_m,

   output wire [21:0]      faddr,
   output wire [2:0]       fcmd,
   output wire             fabort,
   output wire [31:0]      fwdata,
   input  wire [127:0]     frdata,
   input  wire             fready,
   input  wire             fresp,

   input  wire             qreqn_clk,
   output wire             qacceptn_clk,
   output wire             qdeny_clk,
   output wire             qactive_clk,

   input  wire             qreqn_pwr ,
   output wire             qacceptn_pwr,
   output wire             qdeny_pwr,
   output wire             qactive_pwr,

   output wire             preq,
   output wire             pstate,
   input  wire             paccept,
   input  wire             pdeny,
   input  wire             pactive,

   output wire             irq,
   output wire             flash_pwr_rdy

);

wire         psel_rb;
wire         penable_rb;
wire  [11:0] paddr_rb;
wire         pwrite_rb;
wire  [31:0] pwdata_rb;
wire   [3:0] pstrb_rb;
wire  [31:0] prdata_rb;
wire         pready_rb;
wire         pslverr_rb;

wire         qreqn_apb;
wire         qacceptn_apb;
wire         qdeny_apb;
wire         qactive_apb;
wire         qreqn_flash;
wire         qacceptn_flash;
wire         qdeny_flash;
wire         qactive_flash;
wire         qreqn_gfb;
wire         qacceptn_gfb;
wire         qdeny_gfb;
wire         qactive_gfb;

wire   [2:0] fcmd_apb;
wire         fabort_apb;
wire  [21:0] faddr_apb;
wire  [31:0] fwdata_apb;
wire         freq_apb;
wire         fgnt_apb;
wire         arbitration_locked;

wire  [21:0] faddr_ahb;
wire         freq_locked_ahb;
wire         freq_ahb;
wire         fgnt_ahb;

wire [127:0] frdata_int;
wire         fresp_int;
wire         fready_int;

wire         irq_raw;

vultan_ahb_if u_vultan_ahb_if (
   .clk            (clk),
   .resetn         (resetn),

   .hsel           (hsel),
   .haddr          (haddr),
   .htrans         (htrans),
   .hsize          (hsize),
   .hwrite         (hwrite),
   .hburst         (hburst),
   .hmastlock      (hmastlock),
   .hready         (hready),
   .hreadyout      (hreadyout),
   .hresp          (hresp),
   .hrdata         (hrdata),

   .faddr_ahb      (faddr_ahb),
   .freq_locked_ahb(freq_locked_ahb),
   .freq_ahb       (freq_ahb),
   .fgnt_ahb       (fgnt_ahb),
   .frdata_ahb     (frdata_int),
   .fresp_ahb      (fresp_int),
   .fready_ahb     (fready_int)
);

vultan_apb_mux u_vultan_apb_mux (
   .clk         (clk),
   .resetn      (resetn),

   .psel_s      (psel_s),
   .penable_s   (penable_s),
   .paddr_s     (paddr_s),
   .pwrite_s    (pwrite_s),
   .pstrb_s     (pstrb_s),
   .pwdata_s    (pwdata_s),
   .prdata_s    (prdata_s),
   .pready_s    (pready_s),
   .pslverr_s   (pslverr_s),

   .psel_m      (psel_m),
   .penable_m   (penable_m),
   .paddr_m     (paddr_m),
   .pwrite_m    (pwrite_m),
   .pstrb_m     (pstrb_m),
   .pwdata_m    (pwdata_m),
   .prdata_m    (prdata_m),
   .pready_m    (pready_m),
   .pslverr_m   (pslverr_m),

   .psel_rb     (psel_rb),
   .penable_rb  (penable_rb),
   .paddr_rb    (paddr_rb),
   .pwrite_rb   (pwrite_rb),
   .pstrb_rb    (pstrb_rb),
   .pwdata_rb   (pwdata_rb),
   .prdata_rb   (prdata_rb),
   .pready_rb   (pready_rb),
   .pslverr_rb  (pslverr_rb),

   .irq_raw     (irq_raw),
   .irq         (irq),
   .qreqn_apb   (qreqn_apb),
   .qacceptn_apb(qacceptn_apb),
   .qdeny_apb   (qdeny_apb),
   .qactive_apb (qactive_apb)
);

vultan_apb_reg_bank u_vultan_apb_reg_bank (
   .clk               (clk),
   .resetn            (resetn),

   .fabort_apb        (fabort_apb),
   .faddr_apb         (faddr_apb),
   .fcmd_apb          (fcmd_apb),
   .fwdata_apb        (fwdata_apb),

   .frdata_apb        (frdata_int),
   .fready_apb        (fready_int),
   .fresp_apb         (fresp_int),

   .freq_apb          (freq_apb),
   .fgnt_apb          (fgnt_apb),

   .psel              (psel_rb),
   .penable           (penable_rb),
   .paddr             (paddr_rb),
   .pwrite            (pwrite_rb),
   .pstrb             (pstrb_rb),
   .pwdata            (pwdata_rb),
   .prdata            (prdata_rb),
   .pready            (pready_rb),
   .pslverr           (pslverr_rb),

   .irq               (irq_raw),
   .arbitration_locked(arbitration_locked)
   );



vultan_pchan_mstr u_vultan_pchan_mstr (
   .clk           (clk),
   .resetn        (resetn),

   .qreqn_flash   (qreqn_flash),
   .qacceptn_flash(qacceptn_flash),
   .qdeny_flash   (qdeny_flash),
   .qactive_flash (qactive_flash),

   .preq          (preq),
   .pstate        (pstate),
   .paccept       (paccept),
   .pdeny         (pdeny),
   .pactive       (pactive)
);


vultan_qchan_ctrl u_vultan_qchan_ctrl (
   .clk           (clk),
   .resetn        (resetn),

   .qreqn_clk     (qreqn_clk),
   .qacceptn_clk  (qacceptn_clk),
   .qdeny_clk     (qdeny_clk),
   .qactive_clk   (qactive_clk),

   .qreqn_pwr     (qreqn_pwr),
   .qacceptn_pwr  (qacceptn_pwr),
   .qdeny_pwr     (qdeny_pwr),
   .qactive_pwr   (qactive_pwr),

   .qreqn_apb     (qreqn_apb),
   .qacceptn_apb  (qacceptn_apb),
   .qdeny_apb     (qdeny_apb),
   .qactive_apb   (qactive_apb),

   .qreqn_gfb     (qreqn_gfb),
   .qacceptn_gfb  (qacceptn_gfb),
   .qdeny_gfb     (qdeny_gfb),
   .qactive_gfb   (qactive_gfb),

   .qreqn_flash   (qreqn_flash),
   .qacceptn_flash(qacceptn_flash),
   .qdeny_flash   (qdeny_flash),
   .qactive_flash (qactive_flash),

   .flash_pwr_rdy (flash_pwr_rdy)

);

vultan_gfb_arbiter u_vultan_gfb_arbiter (
   .clk               (clk),
   .resetn            (resetn),

   .faddr_ahb         (faddr_ahb),
   .freq_ahb          (freq_ahb),
   .freq_locked_ahb   (freq_locked_ahb),
   .fgnt_ahb          (fgnt_ahb),

   .faddr_apb         (faddr_apb),
   .fcmd_apb          (fcmd_apb),
   .fabort_apb        (fabort_apb),
   .fwdata_apb        (fwdata_apb),
   .freq_apb          (freq_apb),
   .fgnt_apb          (fgnt_apb),
   .arbitration_locked(arbitration_locked),

   .frdata_int        (frdata_int),
   .fready_int        (fready_int),
   .fresp_int         (fresp_int),

   .faddr             (faddr),
   .fcmd              (fcmd),
   .fabort            (fabort),
   .fwdata            (fwdata),
   .frdata            (frdata),
   .fready            (fready),
   .fresp             (fresp),

   .qreqn_gfb         (qreqn_gfb),
   .qacceptn_gfb      (qacceptn_gfb),
   .qdeny_gfb         (qdeny_gfb),
   .qactive_gfb       (qactive_gfb)

   );

endmodule

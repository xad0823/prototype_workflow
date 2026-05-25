//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Mon Dec 19 16:07:57 2016 +0000
//
//      Revision            : fcb8222
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_mem_prot #(
  parameter DATA_WIDTH      = 32,
  parameter ADDR_WIDTH      = 18,
  parameter MASTER_WIDTH    = 4,
  parameter USER_WIDTH      = 1,
  parameter BLK_SIZE        = 3,
  parameter GATE_RESP       = 0,
  parameter GATE_PRESENT    = 1
)
(
  input  wire                       hclk,
  input  wire                       hresetn,

  output wire                       mpc_irq,
  input  wire                       mpc_irq_enable,
  input  wire                       cfg_init_value,

  input  wire                       hsel_s,
  input  wire                       hnonsec_s,
  input  wire [ADDR_WIDTH-1:0]      haddr_s,
  input  wire [1:0]                 htrans_s,
  input  wire [2:0]                 hsize_s,
  input  wire                       hwrite_s,
  input  wire                       hready_s,
  input  wire [6:0]                 hprot_s,
  input  wire [2:0]                 hburst_s,
  input  wire                       hmastlock_s,
  input  wire [DATA_WIDTH-1:0]      hwdata_s,
  input  wire                       hexcl_s,
  input  wire [MASTER_WIDTH-1:0]    hmaster_s,
  output wire [DATA_WIDTH-1:0]      hrdata_s,
  output wire                       hreadyout_s,
  output wire                       hresp_s,
  output wire                       hexokay_s,
  output wire [USER_WIDTH-1:0]      hruser_s,
  input  wire [USER_WIDTH-1:0]      hauser_s,
  input  wire [USER_WIDTH-1:0]      hwuser_s,

  output wire                       hsel_m,
  output wire [ADDR_WIDTH-1:0]      haddr_m,
  output wire [1:0]                 htrans_m,
  output wire [2:0]                 hsize_m,
  output wire                       hwrite_m,
  output wire                       hready_m,
  output wire [6:0]                 hprot_m,
  output wire [2:0]                 hburst_m,
  output wire                       hmastlock_m,
  output wire [DATA_WIDTH-1:0]      hwdata_m,
  output wire                       hnonsec_m,
  output wire                       hexcl_m,
  output wire [MASTER_WIDTH-1:0]    hmaster_m,
  input  wire                       hreadyout_m,
  input  wire                       hresp_m,
  input  wire [DATA_WIDTH-1:0]      hrdata_m,
  input  wire                       hexokay_m,
  output wire [USER_WIDTH-1:0]      hauser_m,
  output wire [USER_WIDTH-1:0]      hwuser_m,
  input  wire [USER_WIDTH-1:0]      hruser_m,

  input  wire                       psel,
  input  wire [11:0]                paddr,
  input  wire [3:0]                 pstrb,
  input  wire                       pwrite,
  input  wire                       penable,
  input  wire [2:0]                 pprot,
  input  wire [31:0]                pwdata,

  output wire [31:0]                prdata,
  output wire                       pready,
  output wire                       pslverr
);



localparam LUT_ADDR_WIDTH = (ADDR_WIDTH - BLK_SIZE - 10) > 0 ? (ADDR_WIDTH - BLK_SIZE - 10) : 0;
localparam LUT_DATA_WIDTH = LUT_ADDR_WIDTH > 0 ? 32 : 1 << (ADDR_WIDTH - BLK_SIZE - 5);



wire                        lut_init_done;
wire [11:0]                 lut_addr_a;
wire [31:0]                 lut_data_in_a;
wire [31:0]                 lut_data_out_a;
wire                        lut_valid_a;
wire                        lut_write_a;
wire                        lut_wr_disable;

wire [11:0]                 lut_addr_b;
wire [31:0]                 lut_data_out_b;
wire                        lut_valid_b;


wire                        cfg_sec_resp;

wire [ADDR_WIDTH-1:0]       sec_info_haddr;
wire [MASTER_WIDTH-1:0]     sec_info_hmaster;
wire                        sec_info_hnonsec;
wire                        sec_info_cfg_ns;

wire                        gate_req;
wire                        gate_ack;
wire                        mpc_irq_clear;
wire                        mpc_irq_mask;
wire                        mpc_irq_trigd;
wire                        mpc_irq_set;




sie200_ahb5_mem_prot_lut #(
  .ADDR_WIDTH               (LUT_ADDR_WIDTH),
  .DATA_WIDTH               (LUT_DATA_WIDTH))
  u_lut (
    .clk                    (hclk),
    .resetn                 (hresetn),

    .init_value             (cfg_init_value),
    .init_done              (lut_init_done),

    .addr_a                 (lut_addr_a),
    .data_in_a              (lut_data_in_a),
    .write_a                (lut_write_a),
    .data_out_a             (lut_data_out_a),
    .valid_a                (lut_valid_a),

    .addr_b                 (lut_addr_b),
    .data_out_b             (lut_data_out_b),
    .valid_b                (lut_valid_b)
);

sie200_ahb5_mem_prot_reg_bank #(
  .ADDR_WIDTH               (ADDR_WIDTH),
  .MASTER_WIDTH             (MASTER_WIDTH),
  .BLK_SIZE                 (BLK_SIZE),
  .LUT_ADDR_WIDTH           (LUT_ADDR_WIDTH),
  .LUT_DATA_WIDTH           (LUT_DATA_WIDTH),
  .GATE_PRESENT             (GATE_PRESENT)
  )
  u_reg_bank(
    .pclk                   (hclk),
    .presetn                (hresetn),

    .psel                   (psel),
    .paddr                  (paddr),
    .pstrb                  (pstrb),
    .pwrite                 (pwrite),
    .penable                (penable),
    .pprot                  (pprot),
    .pwdata                 (pwdata),
    .prdata                 (prdata),
    .pready                 (pready),
    .pslverr                (pslverr),

    .lut_init_done          (lut_init_done),
    .blk_idx                (lut_addr_a),
    .blk_lut_out            (lut_data_in_a),
    .blk_lut_write          (lut_write_a),
    .blk_lut_in             (lut_data_out_a),
    .blk_lut_valid          (lut_valid_a),
    .lut_wr_disable         (lut_wr_disable),

    .cfg_sec_resp           (cfg_sec_resp),
    .gate_req               (gate_req),
    .gate_ack               (gate_ack),
    .sec_info_haddr         (sec_info_haddr),
    .sec_info_hmaster       (sec_info_hmaster),
    .sec_info_hnonsec       (sec_info_hnonsec),
    .sec_info_cfg_ns        (sec_info_cfg_ns),
    .mpc_irq_trigd          (mpc_irq_trigd),
    .mpc_irq_clear          (mpc_irq_clear),
    .mpc_irq_set            (mpc_irq_set),
    .mpc_irq_mask           (mpc_irq_mask)

);

sie200_ahb5_mem_prot_sec_gate #(
  .DATA_WIDTH               (DATA_WIDTH),
  .ADDR_WIDTH               (ADDR_WIDTH),
  .MASTER_WIDTH             (MASTER_WIDTH),
  .USER_WIDTH               (USER_WIDTH),
  .BLK_SIZE                 (BLK_SIZE),
  .GATE_RESP                (GATE_RESP),
  .LUT_ADDR_WIDTH           (LUT_ADDR_WIDTH),
  .LUT_DATA_WIDTH           (LUT_DATA_WIDTH),
  .GATE_PRESENT             (GATE_PRESENT)
  )
  u_sec_gate (
    .hclk                   (hclk),
    .hresetn                (hresetn),

    .hsel_s                 (hsel_s),
    .hnonsec_s              (hnonsec_s),
    .haddr_s                (haddr_s),
    .htrans_s               (htrans_s),
    .hsize_s                (hsize_s),
    .hwrite_s               (hwrite_s),
    .hready_s               (hready_s),
    .hprot_s                (hprot_s),
    .hburst_s               (hburst_s),
    .hmastlock_s            (hmastlock_s),
    .hwdata_s               (hwdata_s),
    .hexcl_s                (hexcl_s),
    .hmaster_s              (hmaster_s),

    .hrdata_s               (hrdata_s),
    .hreadyout_s            (hreadyout_s),
    .hresp_s                (hresp_s),
    .hexokay_s              (hexokay_s),
    .hruser_s               (hruser_s),

    .hauser_s               (hauser_s),
    .hwuser_s               (hwuser_s),

    .hsel_m                 (hsel_m),
    .haddr_m                (haddr_m),
    .htrans_m               (htrans_m),
    .hsize_m                (hsize_m),
    .hwrite_m               (hwrite_m),
    .hready_m               (hready_m),
    .hprot_m                (hprot_m),
    .hburst_m               (hburst_m),
    .hmastlock_m            (hmastlock_m),
    .hwdata_m               (hwdata_m),
    .hnonsec_m              (hnonsec_m),
    .hexcl_m                (hexcl_m),
    .hmaster_m              (hmaster_m),

    .hreadyout_m            (hreadyout_m),
    .hresp_m                (hresp_m),
    .hrdata_m               (hrdata_m),
    .hexokay_m              (hexokay_m),
    .hruser_m               (hruser_m),

    .hauser_m               (hauser_m),
    .hwuser_m               (hwuser_m),


    .lut_addr               (lut_addr_b),
    .lut_data_in            (lut_data_out_b),
    .lut_valid              (lut_valid_b),
    .lut_init_done          (lut_init_done),
    .lut_wr_disable         (lut_wr_disable),

    .cfg_sec_resp           (cfg_sec_resp),
    .gate_req               (gate_req),
    .gate_ack_reg           (gate_ack),
    .sec_info_haddr         (sec_info_haddr),
    .sec_info_hmaster       (sec_info_hmaster),
    .sec_info_hnonsec       (sec_info_hnonsec),
    .sec_info_cfg_ns        (sec_info_cfg_ns),
    .mpc_irq                (mpc_irq),
    .mpc_irq_trigd          (mpc_irq_trigd),
    .mpc_irq_mask           (mpc_irq_mask),
    .mpc_irq_enable         (mpc_irq_enable),
    .mpc_irq_clear          (mpc_irq_clear),
    .mpc_irq_set            (mpc_irq_set)

);



endmodule

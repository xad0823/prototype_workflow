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
//   Top level of css600_atbfunnel
//
//----------------------------------------------------------------------------


module css600_atbfunnel_prog #(parameter
  ATB_DATA_WIDTH = 32,
  NUM_ATB_SLAVES = 8,
  REVAND         = 4'h0
)
(
  clk,
  reset_n,

  psel_s,
  penable_s,
  pwrite_s,
  paddr_s,
  pwdata_s,

  pready_s,
  pslverr_s,
  prdata_s,
  pwakeup_s,

  atwakeup_s,
  atvalid_s,
  atready_s,
  atid_s,
  atdata_s,
  atbytes_s,

  atready_m,
  atwakeup_m,
  atvalid_m,
  syncreq_m,

  afvalid_m,
  afready_m,
  atid_m,
  atdata_m,
  atbytes_m,

  afready_s,
  afvalid_s,
  syncreq_s,

  clk_qactive
);

function integer atb_clog2 (input integer num);
  integer i;
  begin
    atb_clog2 = 0;
    for(i=num; i>1; i=i>>1)
      atb_clog2 = atb_clog2 + 1;
  end
endfunction


  localparam ATB_DATA_WIDTH_LOC =  (
                                          (ATB_DATA_WIDTH ==  8)  ||
                                          (ATB_DATA_WIDTH == 16)  ||
                                          (ATB_DATA_WIDTH == 32)  ||
                                          (ATB_DATA_WIDTH == 64)  ||
                                          (ATB_DATA_WIDTH == 128)
                                         ) ? ATB_DATA_WIDTH : 32;

  localparam NUM_ATB_SLAVES_LOC =  (
                                          (NUM_ATB_SLAVES == 2)  ||
                                          (NUM_ATB_SLAVES == 3)  ||
                                          (NUM_ATB_SLAVES == 4)  ||
                                          (NUM_ATB_SLAVES == 5)  ||
                                          (NUM_ATB_SLAVES == 6)  ||
                                          (NUM_ATB_SLAVES == 7)  ||
                                          (NUM_ATB_SLAVES == 8)
                                         ) ? NUM_ATB_SLAVES : 8;


  localparam ATBYTES_WIDTH = (ATB_DATA_WIDTH_LOC > 8) ? (atb_clog2(ATB_DATA_WIDTH_LOC)-3) : 1;


  localparam CSS600_FUNNEL_FIXED_CONFIG_HOLD_TIME = 4'b0011;

  localparam PORT_REG_WIDTH = NUM_ATB_SLAVES_LOC*3-1;
  localparam DATA_REG_WIDTH = (ATB_DATA_WIDTH_LOC == 128) ? 16 : 8;
  localparam PORT_DATA_WIDTH = (PORT_REG_WIDTH > DATA_REG_WIDTH) ? PORT_REG_WIDTH : DATA_REG_WIDTH;
  localparam WRITE_REG_WIDTH = (PORT_DATA_WIDTH > 12) ? PORT_DATA_WIDTH : 12;

  localparam NUM_OR_IN_QACTIVE = NUM_ATB_SLAVES_LOC + 2;


  input wire         clk;
  input wire         reset_n;

  input wire         psel_s;
  input wire         penable_s;
  input wire         pwrite_s;
  input wire [11:0]  paddr_s;
  input wire [31:0]  pwdata_s;
  input wire         pwakeup_s;

  input wire [NUM_ATB_SLAVES_LOC-1:0]                     atwakeup_s;
  input wire [NUM_ATB_SLAVES_LOC-1:0]                     atvalid_s;
  input wire [NUM_ATB_SLAVES_LOC-1:0]                     afready_s;
  input wire [7*NUM_ATB_SLAVES_LOC-1:0]                     atid_s;
  input wire [NUM_ATB_SLAVES_LOC*ATB_DATA_WIDTH_LOC-1:0]  atdata_s;
  input wire [NUM_ATB_SLAVES_LOC*ATBYTES_WIDTH-1:0]       atbytes_s;

  input wire                            atready_m;
  input wire                            afvalid_m;
  input wire                            syncreq_m;


  output wire                           pready_s;
  output wire                           pslverr_s;
  output wire [31:0]                    prdata_s;

  output wire                           atwakeup_m;
  output wire                           atvalid_m;
  output wire                           afready_m;
  output wire [6:0]                     atid_m;
  output wire [ATB_DATA_WIDTH_LOC-1:0]  atdata_m;
  output wire  [ATBYTES_WIDTH-1:0]      atbytes_m;

  output wire [NUM_ATB_SLAVES_LOC-1:0]  atready_s;
  output wire [NUM_ATB_SLAVES_LOC-1:0]  afvalid_s;
  output wire [NUM_ATB_SLAVES_LOC-1:0]  syncreq_s;

  output wire                           clk_qactive;


  wire [NUM_ATB_SLAVES_LOC-1:0]   en_port;
  wire [3*NUM_ATB_SLAVES_LOC-1:0] pri_port;

  wire [3:0]            min_hold_time;
  wire                  fl_normal;

  wire                  itc_reg;
  wire [31:0]           read_data;
  wire [9:0]            reg_addr;
  wire                  reg_read;
  wire                  reg_write;
  wire [WRITE_REG_WIDTH:0]      write_data;

  wire [ATB_DATA_WIDTH_LOC/8:0]      it_atb_data_0_wr_reg;

  wire [1:0]      it_atb_ctr_2_wr_reg;
  wire [6:0]      it_atb_ctr_1_wr_reg;
  wire [3:0]      it_atb_ctr_0_wr_reg;

  wire [ATB_DATA_WIDTH_LOC/8:0]      it_atb_data_0_rd_reg;

  wire [1:0]      it_atb_ctr_2_rd_reg;
  wire [6:0]      it_atb_ctr_1_rd_reg;
  wire [3:0]      it_atb_ctr_0_rd_reg;

  wire syncreq_apb_w;
  wire syncreq_reg_w;


  wire [3:0] w_revand;


      css600_atbfunnel_apb_if
        #(.WRITE_REG_WIDTH          (WRITE_REG_WIDTH),
          .ATB_DATA_WIDTH           (ATB_DATA_WIDTH_LOC),
          .NUM_ATB_SLAVES           (NUM_ATB_SLAVES_LOC))
        u_css600_atbfunnel_apb_if
        (
        .clk                               (clk),
        .reset_n                           (reset_n),
        .pseldbg                           (psel_s),
        .penabledbg                        (penable_s),
        .pwritedbg                         (pwrite_s),
        .paddrdbg                          (paddr_s[11:2]),
        .pwdatadbg                         (pwdata_s[WRITE_REG_WIDTH:0]),
        .read_data                         (read_data),

        .preadydbg                         (pready_s),
        .pslverrdbg                        (pslverr_s),
        .prdatadbg                         (prdata_s),
        .reg_write                         (reg_write),
        .reg_read                          (reg_read),
        .reg_addr                          (reg_addr),
        .write_data                        (write_data));

      css600_atbfunnel_reg_blk
        #(.CSS600_FIXED_CONFIG_HOLD_TIME   (CSS600_FUNNEL_FIXED_CONFIG_HOLD_TIME),
          .WRITE_REG_WIDTH          (WRITE_REG_WIDTH),
          .ATB_DATA_WIDTH           (ATB_DATA_WIDTH_LOC),
          .NUM_ATB_SLAVES           (NUM_ATB_SLAVES_LOC),
          .ATBYTES_WIDTH            (ATBYTES_WIDTH))
      u_css600atbfunnel_reg_blk
        (
        .clk                                (clk),
        .reset_n                            (reset_n),
        .reg_write                          (reg_write),
        .reg_read                           (reg_read),
        .reg_addr                           (reg_addr),
        .it_atb_data_0_wr_reg               (it_atb_data_0_wr_reg),
        .it_atb_ctr_2_wr_reg                (it_atb_ctr_2_wr_reg),
        .it_atb_ctr_1_wr_reg                (it_atb_ctr_1_wr_reg),
        .it_atb_ctr_0_wr_reg                (it_atb_ctr_0_wr_reg),
        .write_data                         (write_data),
        .atvalid_s                          (atvalid_s),
        .atready_s                          (atready_s),
        .afvalid_s                          (afvalid_s),
        .syncreq_reg                        (syncreq_reg_w),
        .revand                             (w_revand),

        .it_atb_data_0_rd_reg               (it_atb_data_0_rd_reg),
        .it_atb_ctr_2_rd_reg                (it_atb_ctr_2_rd_reg),
        .it_atb_ctr_1_rd_reg                (it_atb_ctr_1_rd_reg),
        .it_atb_ctr_0_rd_reg                (it_atb_ctr_0_rd_reg),
        .syncreq_apb                        (syncreq_apb_w),
        .read_data                          (read_data),
        .en_port                            (en_port),
        .pri_port                           (pri_port),
        .itc_reg                            (itc_reg),
        .min_hold_time                      (min_hold_time),
        .fl_normal                          (fl_normal));

  css600_atbfunnel_arbiter_prog
    #(
     .ATB_DATA_WIDTH           (ATB_DATA_WIDTH_LOC),
     .ATBYTES_WIDTH            (ATBYTES_WIDTH),
     .NUM_ATB_SLAVES           (NUM_ATB_SLAVES_LOC))
    u_css600_atbfunnel_arbiter_prog
     (
     .clk                               (clk),
     .reset_n                           (reset_n),
     .atready_m                         (atready_m),
     .syncreq_m                         (syncreq_m),
     .atvalid_s                         (atvalid_s),
     .atdata_s                          (atdata_s),
     .atbytes_s                         (atbytes_s),
     .afready_s                         (afready_s),
     .afvalid_m                         (afvalid_m),
     .atid_s                            (atid_s),

     .min_hold_time                     (min_hold_time),
     .fl_normal                         (fl_normal),
     .en_port                           (en_port),
     .pri_port                          (pri_port),

     .itc_reg                           (itc_reg),
     .it_atb_data_0_wr_reg              (it_atb_data_0_wr_reg),
     .it_atb_ctr_2_wr_reg               (it_atb_ctr_2_wr_reg),
     .it_atb_ctr_1_wr_reg               (it_atb_ctr_1_wr_reg),
     .it_atb_ctr_0_wr_reg               (it_atb_ctr_0_wr_reg),
     .syncreq_apb                       (syncreq_apb_w),


     .it_atb_data_0_rd_reg              (it_atb_data_0_rd_reg),
     .it_atb_ctr_2_rd_reg               (it_atb_ctr_2_rd_reg),
     .it_atb_ctr_1_rd_reg               (it_atb_ctr_1_rd_reg),
     .it_atb_ctr_0_rd_reg               (it_atb_ctr_0_rd_reg),

     .afready_m                         (afready_m),
     .atvalid_m                         (atvalid_m),
     .atbytes_m                         (atbytes_m),
     .atid_m                            (atid_m),
     .atdata_m                          (atdata_m),

     .atready_s                         (atready_s),
     .afvalid_s                         (afvalid_s),
     .syncreq_s                         (syncreq_s),
     .syncreq_reg                       (syncreq_reg_w),

     .atwakeup_s                      (atwakeup_s),
     .atwakeup_m                      (atwakeup_m)
);

  css600_or_tree
  #(
    .NUM_OR_INPUTS (NUM_OR_IN_QACTIVE)
  ) u_qactive_async
  (
    .or_inputs({atwakeup_s, afvalid_m, pwakeup_s}),
    .or_output(clk_qactive)
  );

  css600_ecorevnum #(.WIDTH(4), .ECOREVVAL(REVAND))
    u_css600_ecorevnum (.ecorevnum(w_revand));


endmodule

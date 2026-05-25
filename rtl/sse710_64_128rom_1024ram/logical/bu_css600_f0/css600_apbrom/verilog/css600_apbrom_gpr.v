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
//   Top level of css600_apbrom
//
//----------------------------------------------------------------------------


module css600_apbrom_gpr # (parameter
  `include "css600_apbrom_params.v"
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
  cdbgpwrupreq,
  cdbgpwrupack,
  csyspwrupreq,
  csyspwrupack,
  cdbgrstreq,
  cdbgrstack,
  csysrstreq,
  csysrstack,
  dbgen,
  niden,
  spiden,
  spniden,
  revision,
  part_number,
  jep106_id,
  eco_rev_and,
  entry_present
);

  `include "css600_apbrom_localparams.v"

  input  wire                              clk;
  input  wire                              reset_n;
  input  wire                              psel_s;
  input  wire                              penable_s;
  input  wire                              pwrite_s;
  input  wire [11:0]                       paddr_s;
  input  wire [31:0]                       pwdata_s;
  output reg                               pready_s;
  output wire                              pslverr_s;
  output reg  [31:0]                       prdata_s;
  output wire [L_NUM_DBGPWRUP_MASTERS-1:0] cdbgpwrupreq;
  input  wire [L_NUM_DBGPWRUP_MASTERS-1:0] cdbgpwrupack;
  output wire [L_NUM_SYSPWRUP_MASTERS-1:0] csyspwrupreq;
  input  wire [L_NUM_SYSPWRUP_MASTERS-1:0] csyspwrupack;
  output wire                              cdbgrstreq;
  input  wire                              cdbgrstack;
  output wire                              csysrstreq;
  input  wire                              csysrstack;
  input  wire                              dbgen;
  input  wire                              niden;
  input  wire                              spiden;
  input  wire                              spniden;
  input  wire [3:0]                        revision;
  input  wire [11:0]                       part_number;
  input  wire [10:0]                       jep106_id;
  input  wire [3:0]                        eco_rev_and;
  input  wire [NUM_ENTRIES-1:0]            entry_present;

  wire                                     cdbgrstack_sync;
  wire                                     csysrstack_sync;
  wire [L_NUM_DBGPWRUP_MASTERS-1:0]        cdbgpwrupack_sync;
  wire [L_NUM_SYSPWRUP_MASTERS-1:0]        csyspwrupack_sync;
/* verilator lint_off UNOPTFLAT */
  wire [1:0]                               prdata_gpr;
/* verilator lint_on UNOPTFLAT */
  wire [31:0]                              prdata_rom;
  reg                                      psel_rom;
  reg                                      psel_pwr;
  reg                                      psel_rst;

  wire [11:0] int_addr   = {paddr_s[11:2], 2'b00};
  wire [7:0]  authstatus = {1'b1, ((spiden | spniden) & (dbgen | niden)),
                            1'b1, ( spiden & dbgen),
                            1'b1, ( niden | dbgen),
                            1'b1,   dbgen};
  wire [511:0] entry_present_int = {{512-NUM_ENTRIES{1'b0}}, entry_present};

  genvar master;

  generate

    for (master=0; master <L_NUM_DBGPWRUP_MASTERS; master=master+1)
    begin: cdbgpwrupack_synchroniser
      css600_cdc_capt_sync #(
        .FF_SYNC_DEPTH (L_FF_SYNC_DEPTH)
      ) u_cdbgpwrupack_sync (
        .clk       (clk),
        .reset_n   (reset_n),
        .d_async_i (cdbgpwrupack[master]),
        .q_sync_o  (cdbgpwrupack_sync[master])
      );
    end

    for (master=0; master <L_NUM_SYSPWRUP_MASTERS; master=master+1)
    begin: csyspwrupack_synchroniser
      css600_cdc_capt_sync #(
        .FF_SYNC_DEPTH (L_FF_SYNC_DEPTH)
      ) u_csyspwrupack_sync (
        .clk       (clk),
        .reset_n   (reset_n),
        .d_async_i (csyspwrupack[master]),
        .q_sync_o  (csyspwrupack_sync[master])
      );
    end

  endgenerate

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH (L_FF_SYNC_DEPTH)
  ) u_cdbgrstack_sync (
    .clk       (clk),
    .reset_n   (reset_n),
    .d_async_i (cdbgrstack),
    .q_sync_o  (cdbgrstack_sync)
  );

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH (L_FF_SYNC_DEPTH)
  ) u_csysrstack_sync (
    .clk       (clk),
    .reset_n   (reset_n),
    .d_async_i (csysrstack),
    .q_sync_o  (csysrstack_sync)
  );

  always @(int_addr or psel_s or penable_s or prdata_rom or prdata_gpr
           or jep106_id or part_number or revision
           or eco_rev_and or authstatus) begin
    psel_rom = 1'b0;
    psel_pwr = 1'b0;
    psel_rst = 1'b0;
    prdata_s   = 32'h00000000;
    pready_s   = 1'b0;
    if (psel_s && penable_s && !int_addr[11]) begin
      psel_rom = 1'b1;
      prdata_s   = prdata_rom;
      pready_s   = penable_s;
    end
    else if (psel_s && penable_s) begin
      if (int_addr[11:9] == 3'b101) begin
         prdata_s = {30'h00000000, prdata_gpr};
         psel_pwr = 1'b1;
      end
      else
        case (int_addr)
          12'hC00: prdata_s = PRIDR0_GPR;
          12'hC10, 12'hC14, 12'hC18, 12'hC1C:
            begin
                   prdata_s = {30'h00000000, prdata_gpr};
                   psel_rst = 1'b1;
            end
          12'hFB8: prdata_s = {24'h000000, authstatus};
          12'hFBC: prdata_s = DEVARCH;
          12'hFC8: prdata_s = DEVID_GPR;
          12'hFD0: prdata_s = {24'h000000, SIZE, jep106_id[10:7]};
          12'hFD4: prdata_s = {24'h000000, PERIPHID5};
          12'hFD8: prdata_s = {24'h000000, PERIPHID6};
          12'hFDC: prdata_s = {24'h000000, PERIPHID7};
          12'hFE0: prdata_s = {24'h000000, part_number[7:0]};
          12'hFE4: prdata_s = {24'h000000, jep106_id[3:0], part_number[11:8]};
          12'hFE8: prdata_s = {24'h000000, revision, 1'b1, jep106_id[6:4]};
          12'hFEC: prdata_s = {24'h000000, eco_rev_and, CMOD};
          12'hFF0: prdata_s = {24'h000000, PRMBL_0};
          12'hFF4: prdata_s = {24'h000000, CMP_CLASS, PRMBL_1};
          12'hFF8: prdata_s = {24'h000000, PRMBL_2};
          12'hFFC: prdata_s = {24'h000000, PRMBL_3};
          default: prdata_s = 32'h00000000;
        endcase
      pready_s   = penable_s;
    end
  end

  css600_apbrom_rom #(
  `include "css600_apbrom_param_map.v"
  ) u_css600_apbrom_rom (
    .entry_present (entry_present_int),
    .psel          (psel_rom),
    .penable       (penable_s),
    .paddr         (int_addr[10:0]),
    .prdata        (prdata_rom)
  );

  css600_apbrom_gpr_gpr #(
    .NUM_DBGPWRUP_MASTERS (L_NUM_DBGPWRUP_MASTERS),
    .NUM_SYSPWRUP_MASTERS (L_NUM_SYSPWRUP_MASTERS)
  ) u_css600_apbrom_gpr_gpr (
    .clk               (clk),
    .reset_n           (reset_n),
    .psel_pwr          (psel_pwr),
    .psel_rst          (psel_rst),
    .penable           (penable_s),
    .pwrite            (pwrite_s),
    .paddr             (int_addr[8:0]),
    .pwdata            (pwdata_s[1:0]),
    .prdata            (prdata_gpr),
    .cdbgpwrupreq      (cdbgpwrupreq),
    .csyspwrupreq      (csyspwrupreq),
    .cdbgpwrupack_sync (cdbgpwrupack_sync),
    .csyspwrupack_sync (csyspwrupack_sync),
    .cdbgrstreq        (cdbgrstreq),
    .csysrstreq        (csysrstreq),
    .cdbgrstack_sync   (cdbgrstack_sync),
    .csysrstack_sync   (csysrstack_sync),
    .dbgen             (dbgen),
    .niden             (niden),
    .spiden            (spiden)
  );

  assign pslverr_s = 1'b0;

endmodule

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


module css600_apbrom # (parameter
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
  revision,
  part_number,
  jep106_id,
  eco_rev_and,
  entry_present
);

  `include "css600_apbrom_localparams.v"

  input  wire                   clk;
  input  wire                   reset_n;
  input  wire                   psel_s;
  input  wire                   penable_s;
  input  wire                   pwrite_s;
  input  wire [11:0]            paddr_s;
  input  wire [31:0]            pwdata_s;
  output reg                    pready_s;
  output wire                   pslverr_s;
  output reg  [31:0]            prdata_s;
  input  wire [3:0]             revision;
  input  wire [11:0]            part_number;
  input  wire [10:0]            jep106_id;
  input  wire [3:0]             eco_rev_and;
  input  wire [NUM_ENTRIES-1:0] entry_present;

  reg          psel_rom;
  wire [31:0]  prdata_rom;
  wire [11:0]  int_addr          = {paddr_s[11:2], 2'b00};
  wire [511:0] entry_present_int = {{512-NUM_ENTRIES{1'b0}}, entry_present};

  always @(int_addr or psel_s or penable_s or prdata_rom or part_number
           or jep106_id or revision or eco_rev_and) begin
    psel_rom = 1'b0;
    prdata_s   = 32'h00000000;
    pready_s   = 1'b0;
    if (psel_s && penable_s && !int_addr[11]) begin
      psel_rom = 1'b1;
      prdata_s   = prdata_rom;
      pready_s   = penable_s;
    end
    else if (psel_s && penable_s) begin
      if (int_addr[11:9] == 3'b101)
        prdata_s = PWR_NO_GPR;
      else
        case (int_addr)
          12'hC00: prdata_s = PRIDR0_NO_GPR;
          12'hC10, 12'hC14, 12'hC18, 12'hC1C:
                   prdata_s = RST_NO_GPR;
          12'hFBC: prdata_s = DEVARCH;
          12'hFC8: prdata_s = DEVID_NO_GPR;
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
      pready_s  = penable_s;
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

  assign pslverr_s = 1'b0;

endmodule

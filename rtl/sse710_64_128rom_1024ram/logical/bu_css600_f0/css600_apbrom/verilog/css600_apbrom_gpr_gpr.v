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


module css600_apbrom_gpr_gpr # (parameter
    NUM_DBGPWRUP_MASTERS = 1,
    NUM_SYSPWRUP_MASTERS = 1)
  (
    input  wire                            clk,
    input  wire                            reset_n,
    input  wire                            psel_pwr,
    input  wire                            psel_rst,
    input  wire                            penable,
    input  wire                            pwrite,
    input  wire [8:0]                      paddr,
    input  wire [1:0]                      pwdata,
    output wire [1:0]                      prdata,
    output reg  [NUM_DBGPWRUP_MASTERS-1:0] cdbgpwrupreq,
    output reg  [NUM_SYSPWRUP_MASTERS-1:0] csyspwrupreq,
    input  wire [NUM_DBGPWRUP_MASTERS-1:0] cdbgpwrupack_sync,
    input  wire [NUM_SYSPWRUP_MASTERS-1:0] csyspwrupack_sync,
    output reg                             cdbgrstreq,
    output reg                             csysrstreq,
    input  wire                            cdbgrstack_sync,
    input  wire                            csysrstack_sync,
    input  wire                            dbgen,
    input  wire                            niden,
    input  wire                            spiden
  );

  wire [NUM_DBGPWRUP_MASTERS-1:0] cdbgpwrupreq_wr;
  wire [NUM_DBGPWRUP_MASTERS-1:0] cdbgpwrupreq_rd;
  wire [NUM_DBGPWRUP_MASTERS-1:0] cdbgpwrupack_rd;
  wire [NUM_SYSPWRUP_MASTERS-1:0] csyspwrupreq_wr;
  wire [NUM_SYSPWRUP_MASTERS-1:0] csyspwrupreq_rd;
  wire [NUM_SYSPWRUP_MASTERS-1:0] csyspwrupack_rd;
  wire                            cdbgrstreq_wr;
  wire                            cdbgrstreq_rd;
  wire                            cdbgrstack_rd;
  wire                            csysrstreq_wr;
  wire                            csysrstreq_rd;
  wire                            csysrstack_rd;

  wire non_invasive_debug = niden  | dbgen;
  wire sec_invasive_debug = spiden & dbgen;

  genvar master;

  generate

    for (master=0; master < NUM_DBGPWRUP_MASTERS; master=master+1)
    begin: cbgpwrupreq_registers
      assign cdbgpwrupreq_wr[master] = psel_pwr &  pwrite & penable & ~paddr[8] & ~paddr[7] & (paddr[6:2] == master[4:0]);
      assign cdbgpwrupreq_rd[master] = psel_pwr & ~pwrite & penable & ~paddr[8] & ~paddr[7] & (paddr[6:2] == master[4:0]);
      assign cdbgpwrupack_rd[master] = psel_pwr & ~pwrite & penable & ~paddr[8] &  paddr[7] & (paddr[6:2] == master[4:0]);

      always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
          cdbgpwrupreq[master] <= 1'b0;
        else if (cdbgpwrupreq_wr[master])
          cdbgpwrupreq[master] <= pwdata[1] & non_invasive_debug;
      end
    end

    for (master=0; master < NUM_SYSPWRUP_MASTERS; master=master+1)
    begin: csyswrupreq_registers
      assign csyspwrupreq_wr[master] = psel_pwr &  pwrite & penable &  paddr[8] & ~paddr[7] & (paddr[6:2] == master[4:0]);
      assign csyspwrupreq_rd[master] = psel_pwr & ~pwrite & penable &  paddr[8] & ~paddr[7] & (paddr[6:2] == master[4:0]);
      assign csyspwrupack_rd[master] = psel_pwr & ~pwrite & penable &  paddr[8] &  paddr[7] & (paddr[6:2] == master[4:0]);

      always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
          csyspwrupreq[master] <= 1'b0;
        else if (csyspwrupreq_wr[master])
          csyspwrupreq[master] <= pwdata[1] & non_invasive_debug;
      end
    end

  endgenerate

  assign  cdbgrstreq_wr = psel_rst &  pwrite & penable &  (paddr[8:2] == 7'h04);
  assign  cdbgrstreq_rd = psel_rst & ~pwrite & penable &  (paddr[8:2] == 7'h04);
  assign  cdbgrstack_rd = psel_rst & ~pwrite & penable &  (paddr[8:2] == 7'h05);
  assign  csysrstreq_wr = psel_rst &  pwrite & penable &  (paddr[8:2] == 7'h06);
  assign  csysrstreq_rd = psel_rst & ~pwrite & penable &  (paddr[8:2] == 7'h06);
  assign  csysrstack_rd = psel_rst & ~pwrite & penable &  (paddr[8:2] == 7'h07);

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
      cdbgrstreq <= 1'b0;
    else if (cdbgrstreq_wr)
      cdbgrstreq <= pwdata[0] & sec_invasive_debug;
  end

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
      csysrstreq <= 1'b0;
    else if (csysrstreq_wr)
      csysrstreq <= pwdata[0] & sec_invasive_debug;
  end


  assign prdata[0] = (|(cdbgpwrupreq_rd))
                   | (|(cdbgpwrupack_rd & cdbgpwrupack_sync))
                   | (|(csyspwrupreq_rd))
                   | (|(csyspwrupack_rd & csyspwrupack_sync))
                   | cdbgrstreq_rd   & cdbgrstreq
                   | cdbgrstack_rd   & cdbgrstack_sync
                   | csysrstreq_rd   & csysrstreq
                   | csysrstack_rd   & csysrstack_sync;

  assign prdata[1] = (|(cdbgpwrupreq_rd & cdbgpwrupreq))
                   | (|(cdbgpwrupack_rd & cdbgpwrupack_sync))
                   | (|(csyspwrupreq_rd & csyspwrupreq))
                   | (|(csyspwrupack_rd & csyspwrupack_sync));

  endmodule

//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2017-2018 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Tue May 8 15:44:55 2018 +0200
//
//      Revision            : e27ce4b
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//----------------------------------------------------------------------------

module sdc600_apbcom_apbif # (
  parameter           APBCOM_VAR  = 0
)(

input   wire          pclk,
input   wire          presetn,

input   wire  [11:0]  paddr,
input   wire          pwrite,
input   wire          psel,
input   wire          penable,
output  wire          pready,
output  wire          pslverr,

input   wire          sr_trinprog,
input   wire          dbr_addr_str,
input   wire          dr_addr_str,
input   wire          txle,
input   wire          txoe,
output  wire          wen,
output  wire          ren,
output  wire  [11:0]  paddr_r,

input   wire          delay_pready,
input   wire          dev_run

);

`include "sdc600_apbcom_variants.v"

localparam   INIT = 2'b00;
localparam  READY = 2'b01;
localparam UNUSED = 2'b10;
localparam  ABORT = 2'b11;

wire  [1:0] unused_lsbs;
wire  [1:0] apboutfsm;
wire        gated_psel;
wire        wr_data_transfer;
wire        txe;
reg         gated_psel_reg;
reg         psel_r;
reg         penable_r;
reg         pwrite_r;
reg  [11:2] paddr_reg;


assign wr_data_transfer         = pwrite_r & (dbr_addr_str | dr_addr_str);
assign txe                      = txoe | txle;

assign     wen  =  pwrite_r & psel_r & dev_run & penable_r & ~apboutfsm[1];

assign     ren  = ~pwrite_r & gated_psel & (~gated_psel_reg | ~penable_r) & dev_run;

assign pslverr  =   apboutfsm[1] & dev_run;
assign  pready  =   apboutfsm[0] & dev_run;

assign gated_psel = psel_r & dev_run;
always @(posedge pclk or negedge presetn) begin
  if (!presetn) begin
   gated_psel_reg <= 1'b0;
  end
  else begin
   gated_psel_reg <= gated_psel;
  end
end

always @(posedge pclk or negedge presetn) begin
  if (!presetn) begin
    psel_r    <= 1'b0;
    penable_r <= 1'b0;
    pwrite_r  <= 1'b0;
  end
  else if (pready) begin
    psel_r    <= 1'b0;
    penable_r <= 1'b0;
    pwrite_r  <= 1'b0;
  end
  else begin
    psel_r    <= psel;
    penable_r <= penable & dev_run;
    if (psel) begin
      pwrite_r  <= pwrite;
    end
    else begin
      pwrite_r  <= 1'b0;
    end
  end
end

always @(posedge pclk or negedge presetn) begin
  if (!presetn) begin
    paddr_reg <= 10'h0;
  end
  else if (psel) begin
    paddr_reg <= paddr[11:2];
  end
end

assign unused_lsbs[1:0] = paddr[1:0];
assign paddr_r = {paddr_reg, 2'b00};

generate
if ((APBCOM_VAR == APBCOM_INT) || (APBCOM_VAR == APBCOM_EXT_ROM)) begin : GEN_NO_PSLVERR
  reg apboutfsm_reg;
  reg apboutfsm_next_reg;
  assign apboutfsm[0] = apboutfsm_reg;
  assign apboutfsm[1] = 1'b0;
  always @* begin
    case (apboutfsm_reg)

      INIT[0]:
      begin
        if (psel_r && dev_run) begin
          if (!wr_data_transfer) begin
            apboutfsm_next_reg = READY[0];
          end
          else begin
            if (~delay_pready || dr_addr_str || txe) begin
              apboutfsm_next_reg = READY[0];
            end
            else begin
              apboutfsm_next_reg = INIT[0];
            end
          end
        end
        else begin
          apboutfsm_next_reg = INIT[0];
        end
      end

      READY[0]:
      begin
        apboutfsm_next_reg = INIT[0];
      end

      default:
      begin
        apboutfsm_next_reg = 1'bx;
      end
    endcase
  end

  always @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
      apboutfsm_reg    <= INIT[0];
    end
    else begin
      apboutfsm_reg    <= apboutfsm_next_reg;
    end
  end

end
else begin : GEN_PSLVERR
  reg [1:0] apboutfsm_reg;
  reg [1:0] apboutfsm_next_reg;
  assign apboutfsm = apboutfsm_reg;

  always @* begin
    case (apboutfsm_reg)

      INIT:
      begin
        if (psel_r && dev_run) begin
          if (!wr_data_transfer) begin
            apboutfsm_next_reg = READY;
          end
          else begin
            if (sr_trinprog) begin
              apboutfsm_next_reg = ABORT;
            end
            else begin
              if (~delay_pready || dr_addr_str || txe) begin
                apboutfsm_next_reg = READY;
              end
              else begin
                apboutfsm_next_reg = INIT;
              end
            end
          end
        end
        else begin
          apboutfsm_next_reg = INIT;
        end
      end

      READY:
      begin
        apboutfsm_next_reg = INIT;
      end

      ABORT:
      begin
        apboutfsm_next_reg = INIT;
      end

      UNUSED:
      begin
        apboutfsm_next_reg = INIT;
      end

      default:
      begin
        apboutfsm_next_reg = 2'bxx;
      end
    endcase
  end

  always @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
      apboutfsm_reg    <= INIT;
    end
    else begin
      apboutfsm_reg    <= apboutfsm_next_reg;
    end
  end
end
endgenerate

endmodule

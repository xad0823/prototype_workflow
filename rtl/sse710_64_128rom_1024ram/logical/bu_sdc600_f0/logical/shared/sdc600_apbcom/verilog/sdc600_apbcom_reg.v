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
//      Checked In          : Fri Jun 1 19:22:58 2018 +0200
//
//      Revision            : d586398
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//----------------------------------------------------------------------------

module  sdc600_apbcom_reg  # (
  parameter         FF_SYNC_DEPTH   = 2,
  parameter         APBCOM_VAR      = 0,
  parameter [ 3:0]  REVISION        = 4'h0,
  parameter [11:0]  PART_NUMBER     = 12'h0,
  parameter [10:0]  JEP106_ID       = 11'h0,
  parameter [ 3:0]  ECO_REV_AND     = 4'h0,
  parameter [31:0]  ROM_ENTRY0      = 32'hE00F_F000
)(

input   wire         clk,
input   wire         resetn,
input   wire         rrdis,
input   wire         pen,
output  wire         irq,
input   wire         tx_ready,

input   wire         spniden,
input   wire         spiden,
input   wire         niden,
input   wire         dbgen,

input   wire  [11:0] addr,
input   wire  [31:0] wdata,
input   wire         wen,
input   wire         ren,
input   wire         dp_abort,
output   reg  [31:0] rdata,
output  wire         sr_trinprog,
output  wire         dbr_addr_str,
output  wire         dr_addr_str,
output   reg         txle,
output   reg         txoe,

input   wire         rxfifo_full,
input   wire  [ 7:0] rdata_dr,

input   wire         txfifo_empty,
input   wire         set_txoe,
input   wire         set_txlerr,
input   wire         delay_pready,
input   wire         tx_linkup,
output  wire         wr_str_dr,
output  wire         wr_str_dbr,

input   wire         pwr_dev_run

);

`include "sdc600_apbcom_localparams.v"

wire        rxfis;
wire [ 3:0] rxfil;
wire        txfis;
wire [ 3:0] txfil;
wire [31:0] icsr  = {rxfis,11'h000,rxfil,txfis,11'h000,txfil};

wire    trinprog;
assign  sr_trinprog       = trinprog;

wire  [31:0]  sr          =   {pen,1'b0,6'h00,7'h00,rxfifo_full,trinprog,txle,txoe,rrdis,4'h0,7'h00,txfifo_empty};

wire          itstatus0;
wire  [31:0]  itstatus    = {{31{1'b0}},itstatus0};

wire          itctrl0;
wire  [31:0]  itctrl      = {{31{1'b0}},itctrl0};

wire  [31:0]  claimsetclr;
wire  [ 1:0]  claimimp;

wire  [31:0]  authstatus;

wire  [31:0]  romentry;

reg irq_reg;

always @(posedge clk or negedge resetn)
begin
  if (!resetn) begin
    irq_reg <= 1'b0;
  end
  else if (!pwr_dev_run || !pen) begin
    irq_reg <= 1'b0;
  end
  else begin
    irq_reg <= (rxfis || txfis);
  end
end

assign irq = irq_reg;


wire    dbr_addr_str_fb    = ({addr[11:2],2'b00} == ADDR_DBR) ? 1'b1 : 1'b0;
wire    dr_addr_str_fb     = ({addr[11:2],2'b00} == ADDR_DR) ? 1'b1 : 1'b0;
assign  dbr_addr_str       = dbr_addr_str_fb;
assign  dr_addr_str        = dr_addr_str_fb;

assign  wr_str_dr          = wen & ~txle & ~txoe & ~sr_trinprog &  dr_addr_str_fb & pen;
wire    wr_str_dbr_fb      = wen & ~txle & ~txoe & ~sr_trinprog & dbr_addr_str_fb & pen;
assign  wr_str_dbr         = wr_str_dbr_fb;


wire [ECODATA_WIDTH-1:0] ecodata_out;

genvar i;
generate
for (i=0; i<ECODATA_WIDTH; i=i+1) begin  : GENREG_ECOREVNUM
  sdc600_ecobit #(.ECOBITVAL(ECODATA[i])) u_sdc600_ecobit(.ecobit(ecodata_out[i]));
end
endgenerate

wire [ 1:0] unused_signals0;
wire [19:0] unused_signals1;
assign unused_signals0 = addr[1:0];
assign unused_signals1 = {wdata[30], wdata[29:20], wdata[12:4]};
generate
if ((APBCOM_VAR != APBCOM_EXT) && (APBCOM_VAR != APBCOM_INT)) begin : GEN_UNUSED_SIGNALS2
  wire [1:0] unused_signals2;
  assign unused_signals2 = wdata[1:0];
end
if (APBCOM_VAR != APBCOM_INT) begin : GEN_UNUSED_SIGNALS3
  wire [7:0] unused_signals3;
  assign unused_signals3 = {wdata[31], wdata[19:15], wdata[3:2]};
end
if ((APBCOM_VAR != APBCOM_EXT_ROM)) begin : GEN_UNUSED_SIGNALS4
  wire [3:0] unused_signals4;
  assign unused_signals4 = {dbgen, niden, spiden, spniden};
end
endgenerate


generate
if (APBCOM_VAR != APBCOM_EXT)  begin  : GEN_NO_ITSTATUS_ITCTRL
  assign itstatus0  = 1'b0;
  assign itctrl0    = 1'b0;
end
else begin : GEN_ITSTATUS_ITCTRL
  reg dp_abort_d;
  reg itstatus_reg;
  assign itstatus0   = itstatus_reg;
  wire wr_str_itctrl = (({addr[11:2],2'b00} == ADDR_ITCTRL) && wen) ? 1'b1 : 1'b0;

  always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      dp_abort_d <= 1'b0;
    end
    else begin
      dp_abort_d <= dp_abort;
    end
  end

  always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      itstatus_reg  <= 1'b0;
    end
    else begin
      if (~itctrl0 || (wr_str_itctrl && ~wdata[0])) begin
        itstatus_reg  <= 1'b0;
      end
      else begin
        if(ren && ({addr[11:2],2'b00} == ADDR_ITSTATUS)) begin
          itstatus_reg  <= 1'b0;
        end
        else begin
          if (!dp_abort_d && dp_abort) begin
            itstatus_reg  <= 1'b1;
          end
        end
      end
    end
  end

  reg     itctrl_reg;
  assign  itctrl0 = itctrl_reg;
  always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      itctrl_reg  <= 1'b0;
    end
    else begin
      if (wr_str_itctrl) begin
        itctrl_reg  <= wdata[0];
      end
    end
  end
end
endgenerate

generate
if ((APBCOM_VAR == APBCOM_EXT_ROM) || (APBCOM_VAR == COMAP)) begin  : GEN_NO_CLAIMTAG

assign claimsetclr = {32{1'b0}};
assign claimimp = 2'b00;

end
else begin  : GEN_CLAIMTAG

  reg [ 1:0]  claimsetclr_reg;
  assign  claimsetclr = {{30{1'b0}},claimsetclr_reg};
  assign  claimimp = 2'b11;

  always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      claimsetclr_reg  <= 2'b00;
    end
    else begin
      if (wen) begin
        case ({addr[11:2],2'b00})
          ADDR_CLAIMSET:  claimsetclr_reg <=  wdata[1:0] | claimsetclr_reg;
          ADDR_CLAIMCLR:  claimsetclr_reg <= ~wdata[1:0] & claimsetclr_reg;
          default:        claimsetclr_reg <=  claimsetclr_reg;
        endcase
      end
    end
  end

end
endgenerate

generate
if (APBCOM_VAR == APBCOM_EXT_ROM) begin  : GEN_AUTH_ROMENTRY

reg [ 3:0]  authstatus_reg;
assign authstatus   = {{24{1'b0}},1'b1,authstatus_reg[3],1'b1,authstatus_reg[2],1'b1,authstatus_reg[1],1'b1,authstatus_reg[0]};

reg    present0;
assign romentry[31:0] = {C_ROM_ENTRY0,11'h001,present0};

  always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      authstatus_reg <= 4'h0;
      present0       <= 1'b0;
    end
    else begin
      if ((spiden || spniden) && (dbgen || niden)) begin
        authstatus_reg[3] <=  1'b1;
      end
      else begin
        authstatus_reg[3] <=  1'b0;
      end
      if (spiden && dbgen) begin
        authstatus_reg[2] <=  1'b1;
      end
      else begin
        authstatus_reg[2] <=  1'b0;
      end
      if (niden || dbgen) begin
        authstatus_reg[1] <=  1'b1;
      end
      else begin
        authstatus_reg[1] <=  1'b0;
      end
      if (dbgen) begin
        authstatus_reg[0] <=  1'b1;
      end
      else begin
        authstatus_reg[0] <=  1'b0;
      end
      present0              <= spniden | spiden | niden | dbgen;
    end
  end
end
else begin  : GEN_NO_AUTH_ROMENTRY
  assign  authstatus  = {32{1'b0}};
  assign  romentry    = {32{1'b0}};
end
endgenerate


generate
if (APBCOM_VAR == APBCOM_INT) begin  : GENIRQ_INT

  reg         rxfis_reg;
  reg  [ 3:0] rxfil_reg;
  reg         txfis_reg;
  reg  [ 3:0] txfil_reg;

  assign rxfis = rxfis_reg;
  assign txfis = txfis_reg;
  assign rxfil = rxfil_reg;
  assign txfil = txfil_reg;

  wire rx_irq_cond = rxfifo_full;
  wire tx_irq_cond = txfifo_empty | (txfil_reg[3:1] != 3'h0);
  wire rx_irq_en   = (rxfil_reg != 4'h0);
  wire tx_irq_en   = (txfil_reg != 4'h0);


  always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      rxfis_reg <=  1'b0;
      rxfil_reg <=  4'h1;
      txfis_reg <=  1'b0;
      txfil_reg <=  4'h0;
    end
    else begin

      if (wen && ({addr[11:2],2'b00} == ADDR_ICSR)) begin
        rxfil_reg  <=  wdata[19:16];
        txfil_reg  <=  wdata[ 3: 0];
      end
      if (APBCOM_VAR == APBCOM_INT) begin
        if (wen && ({addr[11:2],2'b00} == ADDR_ICSR)) begin
          rxfis_reg <= (~wdata[31] & rxfis_reg) | (rx_irq_cond & rx_irq_en);
        end
        else begin
          rxfis_reg <=  rxfis_reg | (rx_irq_cond & rx_irq_en);
        end
      end
      else begin
        rxfis_reg <= 1'b0;
      end

      if (APBCOM_VAR == APBCOM_INT) begin
        if (wen && ({addr[11:2],2'b00} == ADDR_ICSR)) begin
          txfis_reg <= (~wdata[15] & txfis_reg) | (tx_irq_cond & tx_irq_en);
        end
        else begin
          txfis_reg <=  txfis_reg | (tx_irq_cond & tx_irq_en);
        end
      end
      else begin
        txfis_reg <= 1'b0;
      end

    end
  end

end
else begin : GENIRQ_NON_INT
  assign txfil = 4'h0;
  assign rxfil = 4'h0;
  assign txfis = 1'b0;
  assign rxfis = 1'b0;
end
endgenerate

generate
if ((APBCOM_VAR == APBCOM_INT) || (APBCOM_VAR == APBCOM_EXT_ROM)) begin : GEN_NO_TRINPROG
  assign trinprog = 1'b0;
end
else begin                      : GEN_TRINPROG
  reg trinprog_reg;
  assign trinprog = trinprog_reg;
  always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      trinprog_reg  <=  1'b0;
    end
    else begin
      if (tx_ready || ~tx_linkup) begin
        trinprog_reg  <= 1'b0;
      end
      else begin
        if (dp_abort && delay_pready && wr_str_dbr_fb) begin
          trinprog_reg  <= 1'b1;
        end
      end
    end
  end
end
endgenerate

always @(posedge clk or negedge resetn) begin
  if (!resetn) begin
    txle      <=  1'b0;
    txoe      <=  1'b0;
  end
  else begin

    if (set_txlerr) begin
      txle  <= 1'b1;
    end
    else begin
      if (wen && (({addr[11:2],2'b00} == ADDR0_SR) || ({addr[11:2],2'b00} == ADDR1_SR))) begin
        txle  <= ~wdata[14] & txle;
      end
    end

    if (set_txoe) begin
      txoe  <= 1'b1;
    end
    else begin
      if (wen && (({addr[11:2],2'b00} == ADDR0_SR) || ({addr[11:2],2'b00} == ADDR1_SR))) begin
        txoe  <= ~wdata[13] & txoe;
      end
    end

  end
end

always @(posedge clk or negedge resetn) begin
  if (!resetn) begin
    rdata  <=  {32{1'b0}};
  end
  else begin
    if (ren) begin
      case ({addr[11:2],2'b00})
        ADDR_ITSTATUS     : rdata  <=  itstatus;
        ADDR_ITCTRL       : rdata  <=  itctrl;
        ADDR_CLAIMSET     : rdata  <=  {{30{1'b0}},claimimp};
        ADDR_CLAIMCLR     : rdata  <=  claimsetclr;
        ADDR_AUTHSTATUS   : rdata  <=  authstatus;
        ADDR_DEVARCH      : rdata  <=  C_DEVARCH;
        ADDR_DEVID        : rdata  <=  C_DEVID;
        ADDR_PIDR0        : rdata  <=  C_PIDR0;
        ADDR_PIDR1        : rdata  <=  C_PIDR1;
        ADDR_PIDR2        : rdata  <=  {C_PIDR2[31:8],ecodata_out[11: 8],C_PIDR2[3:0]};
        ADDR_PIDR3        : rdata  <=  {C_PIDR3[31:8],ecodata_out[ 7: 0]};
        ADDR_PIDR4        : rdata  <=  C_PIDR4;
        ADDR_CIDR0        : rdata  <=  C_CIDR0;
        ADDR_CIDR1        : rdata  <=  C_CIDR1;
        ADDR_CIDR2        : rdata  <=  C_CIDR2;
        ADDR_CIDR3        : rdata  <=  C_CIDR3;
        ADDR_IDR          : rdata  <=  C_IDR;
        ADDR_ROMENTRY     : rdata  <=  romentry;
        ADDR_VIDR         : rdata  <=  C_VIDR;
        ADDR_FIDTXR       : rdata  <=  C_FIDTXR;
        ADDR_FIDRXR       : rdata  <=  C_FIDRXR;
        ADDR_ICSR         : rdata  <=  icsr;
        ADDR0_SR,ADDR1_SR : rdata  <=  sr;
        ADDR_DR,ADDR_DBR  : rdata  <=  pen ? {{3{FLAG_NULL}},rdata_dr} : {4{FLAG_NULL}};
        default           : rdata  <=  {32{1'b0}};
      endcase
    end
    else begin
      rdata  <=  rdata & {32{pwr_dev_run}};
    end
  end
end

endmodule


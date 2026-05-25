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
//      Checked In          : Thu Sep 7 10:31:46 2017 +0100
//
//      Revision            : 7406604
//
//      Release Information : Vultan Generic Flash Controller - Global Bundle r0p0-00rel0
//
//-----------------------------------------------------------------------------


module vultan_apb_reg_bank(
   input  wire           resetn,
   input  wire           clk,
   input  wire           psel,
   input  wire           penable,
   input  wire  [11:0]   paddr,
   input  wire           pwrite,
   input  wire  [31:0]   pwdata,
   input  wire   [3:0]   pstrb,
   output wire  [31:0]   prdata,
   output wire           pready,
   output wire           pslverr,
   output wire   [2:0]   fcmd_apb,
   output wire           fabort_apb,
   output wire  [21:0]   faddr_apb,
   output wire  [31:0]   fwdata_apb,
   input  wire [127:0]   frdata_apb,
   input  wire           fresp_apb,
   input  wire           fready_apb,
   output wire           freq_apb,
   input  wire           fgnt_apb,
   input  wire           arbitration_locked,
   output wire           irq
);


`include "vultan_gen_const_pkg.vh"

localparam GFB_IDLE       = 3'b000;
localparam GFB_READ       = 3'b001;
localparam GFB_WRITE      = 3'b010;
localparam GFB_ROW_WRITE  = 3'b011;
localparam GFB_RESERVED0  = 3'b101;
localparam GFB_RESERVED1  = 3'b110;

localparam FSM_IDLE     = 1'b0;
localparam FSM_ACCEPT   = 1'b1;

wire         wr_en;
wire         rd_en;
wire         sel_irq_enable_set;
wire         sel_irq_enable_clr;
wire         sel_irq_status_set;
wire         sel_irq_status_clr;
wire         sel_irq_masked_status;
wire         sel_ctrl;
wire         sel_status;
wire         sel_addr;
wire         sel_data0;
wire         sel_data1;
wire         sel_data2;
wire         sel_data3;
wire         sel_pidr0;
wire         sel_pidr1;
wire         sel_pidr2;
wire         sel_pidr3;
wire         sel_pidr4;
wire         sel_cidr0;
wire         sel_cidr1;
wire         sel_cidr2;
wire         sel_cidr3;
reg   [4:0]  irq_enable_reg;
wire         irq_enable_set_wr_en;
wire         irq_enable_clr_wr_en;
wire  [4:0]  irq_enable_set_nxt, irq_enable_clr_nxt;
wire  [4:0]  irq_enable_nxt;
wire         cmd_reject;
wire  [4:0]  irq_event;
wire  [4:0]  saved_irq_event;
wire         irq_status_set_wr_en;
wire         irq_status_clr_wr_en;
wire  [4:0]  irq_status_set_nxt, irq_status_clr_nxt;
wire  [4:0]  irq_status_nxt;
reg   [4:0]  irq_status_reg;
wire  [4:0]  irq_masked_status;
wire         irq_nxt;
reg          irq_reg;
wire  [2:0]  ctrl_cmd_nxt;
reg   [2:0]  ctrl_cmd_reg;
wire         ctrl_abort_nxt;
reg          ctrl_abort_reg;
wire         ctrl_unlocked;
wire         ctrl_wr_en;
wire  [2:0]  saved_result_nxt;
reg   [2:0]  saved_result_reg;
wire         status_cmd_pending;
wire         status_cmd_accept;
wire         status_cmd_finish;
wire [21:0]  addr_nxt;
reg  [21:0]  addr_reg;
wire         addr_wr_en;
wire [31:0]  data0_apb_nxt;
wire [31:0]  data0_gfb_nxt;
reg  [31:0]  data0_reg;
wire         data0_wr_en;
reg  [31:0]  data1_reg;
wire [31:0]  data1_gfb_nxt;
reg  [31:0]  data2_reg;
wire [31:0]  data2_gfb_nxt;
reg  [31:0]  data3_reg;
wire [31:0]  data3_gfb_nxt;
reg          gfb_state, gfb_state_nxt;
reg          ctrl_clr;
reg          frdata_valid;
reg          cmd_accept;
reg          cmd_success;
reg          cmd_fail;
reg          result_overflow;
reg  [31:0]  fwdata_apb_reg, fwdata_apb_nxt;
reg          read_accepted_reg, read_accepted_nxt;
wire [31:0]  rdata_irq_enable;
wire [31:0]  rdata_irq_status;
wire [31:0]  rdata_irq_masked_status;
wire [31:0]  rdata_ctrl;
wire [31:0]  rdata_status;
wire [31:0]  rdata_addr;
wire [31:0]  rdata_data0;
wire [31:0]  rdata_data1;
wire [31:0]  rdata_data2;
wire [31:0]  rdata_data3;
wire [31:0]  rdata_pidr0;
wire [31:0]  rdata_pidr1;
wire [31:0]  rdata_pidr2;
wire [31:0]  rdata_pidr3;
wire [31:0]  rdata_pidr4;
wire [31:0]  rdata_cidr0;
wire [31:0]  rdata_cidr1;
wire [31:0]  rdata_cidr2;
wire [31:0]  rdata_cidr3;
wire  [3:0]  pidr2_revision;
wire  [3:0]  pidr3_revand;

wire [1:0] unused = paddr[1:0];

assign pready  = 1'b1;
assign pslverr = 1'b0;

assign wr_en = psel & ~penable & pwrite & (pstrb == 4'b1111);
assign rd_en = psel & penable & ~pwrite;

assign sel_irq_enable_set    = (paddr[11:2] == IRQ_ENABLE_SET_REG_OFFSET_PARAM[11:2]   );
assign sel_irq_enable_clr    = (paddr[11:2] == IRQ_ENABLE_CLR_REG_OFFSET_PARAM[11:2]   );
assign sel_irq_status_set    = (paddr[11:2] == IRQ_STATUS_SET_REG_OFFSET_PARAM[11:2]   );
assign sel_irq_status_clr    = (paddr[11:2] == IRQ_STATUS_CLR_REG_OFFSET_PARAM[11:2]   );
assign sel_irq_masked_status = (paddr[11:2] == IRQ_MASKED_STATUS_REG_OFFSET_PARAM[11:2]);
assign sel_ctrl              = (paddr[11:2] == CTRL_REG_OFFSET_PARAM[11:2]             );
assign sel_status            = (paddr[11:2] == STATUS_REG_OFFSET_PARAM[11:2]           );
assign sel_addr              = (paddr[11:2] == ADDR_REG_OFFSET_PARAM[11:2]             );
assign sel_data0             = (paddr[11:2] == DATA0_REG_OFFSET_PARAM[11:2]            );
assign sel_data1             = (paddr[11:2] == DATA1_REG_OFFSET_PARAM[11:2]            );
assign sel_data2             = (paddr[11:2] == DATA2_REG_OFFSET_PARAM[11:2]            );
assign sel_data3             = (paddr[11:2] == DATA3_REG_OFFSET_PARAM[11:2]            );
assign sel_pidr0             = (paddr[11:2] == PIDR0_REG_OFFSET_PARAM[11:2]            );
assign sel_pidr1             = (paddr[11:2] == PIDR1_REG_OFFSET_PARAM[11:2]            );
assign sel_pidr2             = (paddr[11:2] == PIDR2_REG_OFFSET_PARAM[11:2]            );
assign sel_pidr3             = (paddr[11:2] == PIDR3_REG_OFFSET_PARAM[11:2]            );
assign sel_pidr4             = (paddr[11:2] == PIDR4_REG_OFFSET_PARAM[11:2]            );
assign sel_cidr0             = (paddr[11:2] == CIDR0_REG_OFFSET_PARAM[11:2]            );
assign sel_cidr1             = (paddr[11:2] == CIDR1_REG_OFFSET_PARAM[11:2]            );
assign sel_cidr2             = (paddr[11:2] == CIDR2_REG_OFFSET_PARAM[11:2]            );
assign sel_cidr3             = (paddr[11:2] == CIDR3_REG_OFFSET_PARAM[11:2]            );



assign irq_enable_set_wr_en = sel_irq_enable_set & wr_en;
assign irq_enable_clr_wr_en = sel_irq_enable_clr & wr_en;

assign irq_enable_set_nxt = irq_enable_reg | pwdata[4:0];
assign irq_enable_clr_nxt = irq_enable_reg & ~pwdata[4:0];

assign irq_enable_nxt = irq_enable_set_wr_en ? irq_enable_set_nxt :
                        irq_enable_clr_wr_en ? irq_enable_clr_nxt :
                                               irq_enable_reg;

always @ (posedge clk or negedge resetn)
begin
  if (!resetn) begin
    irq_enable_reg <= 5'h0;
  end
  else begin
    irq_enable_reg <= irq_enable_nxt;
  end
end


assign irq_event = {1'b0, cmd_reject, cmd_fail, cmd_success, cmd_accept};

assign saved_irq_event = result_overflow ? {saved_result_nxt[2], 1'b0, saved_result_nxt[1:0], 1'b0} :
                                           {saved_result_reg[2], 1'b0, saved_result_reg[1:0], 1'b0};

assign irq_status_set_wr_en = sel_irq_status_set & wr_en;
assign irq_status_clr_wr_en = sel_irq_status_clr & wr_en;

assign irq_status_set_nxt = irq_event | irq_status_reg | pwdata[4:0];
assign irq_status_clr_nxt = irq_event | saved_irq_event | (irq_status_reg & ~pwdata[4:0]);

assign irq_status_nxt = irq_status_set_wr_en ? irq_status_set_nxt :
                        irq_status_clr_wr_en ? irq_status_clr_nxt :
                                               irq_event | irq_status_reg;


always @(posedge clk or negedge resetn)
begin
  if (!resetn) begin
    irq_status_reg <= 5'h0;
  end
  else begin
    irq_status_reg <= irq_status_nxt;
  end
end


assign irq_masked_status = irq_status_reg & irq_enable_reg;

assign irq_nxt = |(irq_status_nxt & irq_enable_nxt);

always @(posedge clk or negedge resetn)
begin
  if (!resetn) begin
    irq_reg <= 1'b0;
  end
  else begin
    irq_reg <= irq_nxt;
  end
end

assign irq = irq_reg;


assign saved_result_nxt = {read_accepted_reg, fresp_apb, ~fresp_apb};

always @ (posedge clk or negedge resetn)
begin
  if (!resetn) begin
    saved_result_reg <= 3'h0;
  end
  else if (irq_status_clr_wr_en) begin
    saved_result_reg <= 3'h0;
  end
  else if (result_overflow) begin
    saved_result_reg <= saved_result_nxt;
  end
end

assign ctrl_cmd_nxt = (pwdata[4] || pwdata[2:0] == GFB_RESERVED0 || pwdata[2:0] == GFB_RESERVED1) ? 3'h0 : pwdata[2:0];
assign ctrl_abort_nxt = pwdata[4] & (gfb_state == FSM_ACCEPT) & ~fready_apb;
assign ctrl_unlocked = (irq_status_reg[4:0] == 5'h0) & (ctrl_cmd_reg == GFB_IDLE) & (ctrl_abort_reg == 1'b0);
assign ctrl_wr_en = sel_ctrl & wr_en & ctrl_unlocked;
assign cmd_reject = (sel_ctrl | sel_addr | sel_data0) & wr_en & ~ctrl_unlocked;
always @(posedge clk or negedge resetn)
begin
  if (!resetn) begin
    ctrl_cmd_reg <= 3'h0;
    ctrl_abort_reg <= 1'b0;
  end
  else if (ctrl_wr_en) begin
    ctrl_cmd_reg <= ctrl_cmd_nxt;
    ctrl_abort_reg <= ctrl_abort_nxt;
  end
  else if (ctrl_clr) begin
    ctrl_cmd_reg <= 3'h0;
    ctrl_abort_reg <= 1'b0;
  end
end

assign status_cmd_pending = (ctrl_cmd_reg != 3'h0) | ctrl_abort_reg;
assign status_cmd_accept = (gfb_state == FSM_ACCEPT);
assign status_cmd_finish = (saved_result_reg != 3'h0);

assign addr_nxt = pwdata[21:0];
assign addr_wr_en = sel_addr & wr_en & ctrl_unlocked;

always @ (posedge clk or negedge resetn)
begin
  if (!resetn) begin
    addr_reg <= 22'h0;
  end
  else if (addr_wr_en) begin
    addr_reg <= addr_nxt;
  end
end


assign data0_apb_nxt = pwdata;
assign data0_gfb_nxt = frdata_apb[31:0];
assign data0_wr_en = sel_data0 & wr_en & ctrl_unlocked;

always @(posedge clk or negedge resetn)
begin
  if (!resetn) begin
    data0_reg <= 32'h0;
  end
  else if (data0_wr_en) begin
    data0_reg <= data0_apb_nxt;
  end
  else if (frdata_valid) begin
    data0_reg <= data0_gfb_nxt;
  end
end


assign data1_gfb_nxt = frdata_apb[63:32];

always @(posedge clk or negedge resetn)
begin
  if (!resetn) begin
    data1_reg <= 32'h0;
  end
  else if (frdata_valid) begin
    data1_reg <= data1_gfb_nxt;
  end
end


assign data2_gfb_nxt = frdata_apb[95:64];

always @(posedge clk or negedge resetn)
begin
  if (!resetn) begin
    data2_reg <= 32'h0;
  end
  else if (frdata_valid) begin
    data2_reg <= data2_gfb_nxt;
  end
end


assign data3_gfb_nxt = frdata_apb[127:96];

always @(posedge clk or negedge resetn)
begin
  if (!resetn) begin
    data3_reg <= 32'h0;
  end
  else if (frdata_valid) begin
    data3_reg <= data3_gfb_nxt;
  end
end

vultan_ecorevnum #(
  .WIDTH(4),
  .ECOREVVAL(PIDR2_REVISION_BIT_RESET_PARAM))
u_vultan_ecorevnum_pidr2(
  .ecorevnum(pidr2_revision)
);

vultan_ecorevnum #(
  .WIDTH(4),
  .ECOREVVAL(PIDR3_REVAND_BIT_RESET_PARAM))
u_vultan_ecorevnum_pidr3(
  .ecorevnum(pidr3_revand)
);

assign rdata_irq_enable        = {27'h0, irq_enable_reg};
assign rdata_irq_status        = {27'h0, irq_status_reg};
assign rdata_irq_masked_status = {27'h0, irq_masked_status};
assign rdata_ctrl              = {27'h0, ctrl_abort_reg, 1'b0, ctrl_cmd_reg[2:0]};
assign rdata_status            = {26'h0, arbitration_locked, status_cmd_finish, irq_status_reg[2:1], status_cmd_accept, status_cmd_pending};
assign rdata_addr              = {10'h0, addr_reg};
assign rdata_data0             = data0_reg;
assign rdata_data1             = data1_reg;
assign rdata_data2             = data2_reg;
assign rdata_data3             = data3_reg;
assign rdata_pidr0             = {24'h0, PIDR0_PART_0_BIT_RESET_PARAM};
assign rdata_pidr1             = {24'h0, PIDR1_DES_0_BIT_RESET_PARAM, PIDR1_PART_1_BIT_RESET_PARAM};
assign rdata_pidr2             = {24'h0, pidr2_revision, PIDR2_JEDEC_BIT_RESET_PARAM, PIDR2_DES_1_BIT_RESET_PARAM};
assign rdata_pidr3             = {24'h0, pidr3_revand, PIDR3_CMOD_BIT_RESET_PARAM};
assign rdata_pidr4             = {24'h0, PIDR4_SIZE_BIT_RESET_PARAM, PIDR4_DES_2_BIT_RESET_PARAM};
assign rdata_cidr0             = {24'h0, CIDR0_PRMBL_0_BIT_RESET_PARAM};
assign rdata_cidr1             = {24'h0, CIDR1_CLASS_BIT_RESET_PARAM, CIDR1_PRMBL_1_BIT_RESET_PARAM};
assign rdata_cidr2             = {24'h0, CIDR2_PRMBL_2_BIT_RESET_PARAM};
assign rdata_cidr3             = {24'h0, CIDR3_PRMBL_3_BIT_RESET_PARAM};



assign prdata = {32{rd_en}} & (
                ( {32{sel_irq_enable_set   }} & rdata_irq_enable        ) |
                ( {32{sel_irq_enable_clr   }} & rdata_irq_enable        ) |
                ( {32{sel_irq_status_set   }} & rdata_irq_status        ) |
                ( {32{sel_irq_status_clr   }} & rdata_irq_status        ) |
                ( {32{sel_irq_masked_status}} & rdata_irq_masked_status ) |
                ( {32{sel_ctrl             }} & rdata_ctrl              ) |
                ( {32{sel_status           }} & rdata_status            ) |
                ( {32{sel_addr             }} & rdata_addr              ) |
                ( {32{sel_data0            }} & rdata_data0             ) |
                ( {32{sel_data1            }} & rdata_data1             ) |
                ( {32{sel_data2            }} & rdata_data2             ) |
                ( {32{sel_data3            }} & rdata_data3             ) |
                ( {32{sel_pidr0            }} & rdata_pidr0             ) |
                ( {32{sel_pidr1            }} & rdata_pidr1             ) |
                ( {32{sel_pidr2            }} & rdata_pidr2             ) |
                ( {32{sel_pidr3            }} & rdata_pidr3             ) |
                ( {32{sel_pidr4            }} & rdata_pidr4             ) |
                ( {32{sel_cidr0            }} & rdata_cidr0             ) |
                ( {32{sel_cidr1            }} & rdata_cidr1             ) |
                ( {32{sel_cidr2            }} & rdata_cidr2             ) |
                ( {32{sel_cidr3            }} & rdata_cidr3             ));




assign fcmd_apb = ctrl_cmd_reg;
assign fabort_apb = ctrl_abort_reg;
assign faddr_apb = addr_reg;
assign fwdata_apb = fwdata_apb_reg;
assign freq_apb = (fcmd_apb != GFB_IDLE);
always @*
begin
  gfb_state_nxt = gfb_state;
  ctrl_clr = 1'b0;
  frdata_valid = 1'b0;
  cmd_accept = 1'b0;
  cmd_success = 1'b0;
  cmd_fail = 1'b0;
  result_overflow = 1'b0;
  fwdata_apb_nxt = fwdata_apb_reg;
  read_accepted_nxt = read_accepted_reg;
  case (gfb_state)
    FSM_IDLE:
      begin
        if (ctrl_cmd_reg != GFB_IDLE) begin
          if (fgnt_apb && fready_apb) begin
            gfb_state_nxt = FSM_ACCEPT;
            read_accepted_nxt = (ctrl_cmd_reg == GFB_READ);
            ctrl_clr = 1'b1;
            cmd_accept = 1'b1;
            fwdata_apb_nxt = (ctrl_cmd_reg == GFB_WRITE || ctrl_cmd_reg == GFB_ROW_WRITE) ? data0_reg : 32'h0;
          end
        end
      end

    FSM_ACCEPT:
      begin
        if (fready_apb && !fgnt_apb) begin
          if (irq_status_reg[2:1] != 2'h0) begin
            gfb_state_nxt = FSM_IDLE;
            result_overflow = 1'b1;
          end
          else begin
            gfb_state_nxt = FSM_IDLE;
            {cmd_fail, cmd_success} = {fresp_apb, ~fresp_apb};
            frdata_valid = read_accepted_reg & ~fresp_apb;
          end
          if (ctrl_abort_reg) begin
            ctrl_clr = 1'b1;
          end
        end
        else if (fready_apb && fgnt_apb) begin
          gfb_state_nxt = FSM_ACCEPT;
          read_accepted_nxt = (ctrl_cmd_reg == GFB_READ);
          ctrl_clr = 1'b1;
          cmd_accept = 1'b1;
          fwdata_apb_nxt = (ctrl_cmd_reg == GFB_WRITE || ctrl_cmd_reg == GFB_ROW_WRITE) ? data0_reg : 32'h0;
          {cmd_fail, cmd_success} = {fresp_apb, ~fresp_apb};
          frdata_valid = read_accepted_reg & ~fresp_apb;
        end
      end

    default:
      begin
        gfb_state_nxt = 1'bx;
      end
  endcase
end

always @ (negedge resetn or posedge clk)
begin
  if (!resetn) begin
    gfb_state <= FSM_IDLE;
    fwdata_apb_reg <= 32'h0;
    read_accepted_reg <= 1'b0;
  end
  else begin
    gfb_state <= gfb_state_nxt;
    fwdata_apb_reg <= fwdata_apb_nxt;
    read_accepted_reg <= read_accepted_nxt;
  end
end


endmodule





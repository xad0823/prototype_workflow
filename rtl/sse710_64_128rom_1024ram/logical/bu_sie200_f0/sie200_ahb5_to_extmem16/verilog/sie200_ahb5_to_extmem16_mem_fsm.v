//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2013 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      SVN Information
//
//      Checked In          : Thu Nov 24 18:07:53 2016 +0100
//
//      Revision            : 71f5000
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_to_extmem16_mem_fsm(
  input  wire        hclk,
  input  wire        hresetn,

  input  wire        rdreq,
  input  wire        wrreq,
  input  wire  [1:0] nxtbytemask,
  output wire        done,

  input  wire  [2:0] cfg_read_cycle,
  input  wire  [2:0] cfg_write_cycle,
  input  wire  [2:0] cfg_turnaround_cycle,

  output wire        dataout_en,
  output wire        we_n,
  output wire        oe_n,
  output wire        ce_n,
  output wire        lb_n,
  output wire        ub_n,

  output wire  [2:0] memfsmstate);

  reg  [2:0]    reg_mstate;
  reg  [2:0]    nxt_mstate;

  localparam EXTMEM_FSM_IDLE   = 3'b000;
  localparam EXTMEM_FSM_WRITE1 = 3'b001;
  localparam EXTMEM_FSM_WRITE2 = 3'b011;
  localparam EXTMEM_FSM_WRITE3 = 3'b010;
  localparam EXTMEM_FSM_READ1  = 3'b100;

  reg           reg_dataoe_n;
  reg           nxt_dataoe_n;
  reg           reg_we_n;
  reg           nxt_we_n;
  reg           reg_oe_n;
  reg           nxt_oe_n;
  reg           reg_ce_n;
  reg           nxt_ce_n;
  reg  [1:0]    reg_bs_n;
  reg  [1:0]    nxt_bs_n;

  reg  [2:0]    reg_mcount;
  reg  [2:0]    nxt_mcount;
  reg           last_operation;
  wire          nxt_last_operation;
  wire [2:0]    dec_mcount;

  assign        dec_mcount = reg_mcount - 1'b1;

always @(reg_mstate or rdreq or wrreq or reg_mcount or cfg_read_cycle or
   cfg_write_cycle or cfg_turnaround_cycle or last_operation or dec_mcount)
begin
  case (reg_mstate)
    EXTMEM_FSM_IDLE :
      begin
      if (rdreq)
        begin
        if ((reg_mcount!= {3{1'b0}}) & (last_operation))
          begin
          nxt_mstate   = EXTMEM_FSM_IDLE;
          nxt_mcount   = dec_mcount;
          end
        else
          begin
          nxt_mstate   = EXTMEM_FSM_READ1;
          nxt_mcount   = cfg_read_cycle;
          end
        end
      else if (wrreq)
        begin
        if ((reg_mcount!= {3{1'b0}}) & (~last_operation))
          begin
          nxt_mstate   = EXTMEM_FSM_IDLE;
          nxt_mcount   = dec_mcount;
          end
        else
          begin
          nxt_mstate   = EXTMEM_FSM_WRITE1;
          nxt_mcount   = cfg_write_cycle;
          end
        end
      else if ((reg_mcount!= {3{1'b0}}))
        begin
        nxt_mstate   = EXTMEM_FSM_IDLE;
        nxt_mcount   = dec_mcount;
        end
      else
        begin
        nxt_mstate   = EXTMEM_FSM_IDLE;
        nxt_mcount   = {3{1'b0}};
        end
      end
    EXTMEM_FSM_READ1:
      begin
      if (reg_mcount!= {3{1'b0}})
        begin
        nxt_mstate   = EXTMEM_FSM_READ1;
        nxt_mcount   = dec_mcount;
        end
      else if (rdreq)
        begin
        nxt_mstate   = EXTMEM_FSM_READ1;
        nxt_mcount   = cfg_read_cycle;
        end
      else
        begin
        nxt_mstate   = EXTMEM_FSM_IDLE;
        nxt_mcount   = cfg_turnaround_cycle;
        end
      end
    EXTMEM_FSM_WRITE1:
      begin
      nxt_mstate   = EXTMEM_FSM_WRITE2;
      nxt_mcount   = cfg_write_cycle;
      end
    EXTMEM_FSM_WRITE2:
      if (reg_mcount!= {3{1'b0}})
        begin
        nxt_mstate   = EXTMEM_FSM_WRITE2;
        nxt_mcount   = dec_mcount;
        end
      else
        begin
        nxt_mstate   = EXTMEM_FSM_WRITE3;
        nxt_mcount   = {3{1'b0}};
        end
    EXTMEM_FSM_WRITE3: begin
      if (wrreq)
        begin
        nxt_mstate   = EXTMEM_FSM_WRITE1;
        nxt_mcount   = cfg_write_cycle;
        end
      else
        begin
        nxt_mstate   = EXTMEM_FSM_IDLE;
        nxt_mcount   = cfg_turnaround_cycle;
        end
      end
    default:
      begin
      nxt_mstate   = 3'bxxx;
      nxt_mcount   = 3'bxxx;
      end
  endcase
end

assign done = ((reg_mstate==EXTMEM_FSM_READ1) & (reg_mcount==3'b000)) |
              (reg_mstate==EXTMEM_FSM_WRITE3);

assign nxt_last_operation = (reg_mstate == EXTMEM_FSM_WRITE3);

always @(posedge hclk or negedge hresetn)
  begin
  if (~hresetn)
    last_operation <= 1'b0;
  else if (done)
    last_operation <= nxt_last_operation;
  end

always @(nxt_mstate or nxtbytemask)
begin
  case (nxt_mstate)
    EXTMEM_FSM_IDLE :
        begin
        nxt_dataoe_n = 1'b1;
        nxt_ce_n     = 1'b1;
        nxt_oe_n     = 1'b1;
        nxt_we_n     = 1'b1;
        nxt_bs_n     = 2'b11;
        end
    EXTMEM_FSM_READ1 :
        begin
        nxt_dataoe_n = 1'b1;
        nxt_ce_n     = 1'b0;
        nxt_oe_n     = 1'b0;
        nxt_we_n     = 1'b1;
        nxt_bs_n     = ~nxtbytemask;
        end
    EXTMEM_FSM_WRITE1, EXTMEM_FSM_WRITE3 :
        begin
        nxt_dataoe_n = 1'b0;
        nxt_ce_n     = 1'b0;
        nxt_oe_n     = 1'b1;
        nxt_we_n     = 1'b1;
        nxt_bs_n     = ~nxtbytemask;
        end
    EXTMEM_FSM_WRITE2 :
        begin
        nxt_dataoe_n = 1'b0;
        nxt_ce_n     = 1'b0;
        nxt_oe_n     = 1'b1;
        nxt_we_n     = 1'b0;
        nxt_bs_n     = ~nxtbytemask;
        end
    default:
        begin
        nxt_dataoe_n = 1'bx;
        nxt_ce_n     = 1'bx;
        nxt_oe_n     = 1'bx;
        nxt_we_n     = 1'bx;
        nxt_bs_n     = 2'bxx;
        end
  endcase
end

always @(posedge hclk or negedge hresetn)
begin
  if (~hresetn)
    begin
    reg_mstate    <= EXTMEM_FSM_IDLE;
    reg_mcount    <= 3'b000;
    reg_dataoe_n  <= 1'b1;
    reg_ce_n      <= 1'b1;
    reg_oe_n      <= 1'b1;
    reg_we_n      <= 1'b1;
    reg_bs_n      <= 2'b11;
    end
  else
    begin
    reg_mstate    <= nxt_mstate;
    reg_mcount    <= nxt_mcount;
    reg_dataoe_n  <= nxt_dataoe_n;
    reg_ce_n      <= nxt_ce_n;
    reg_oe_n      <= nxt_oe_n;
    reg_we_n      <= nxt_we_n;
    reg_bs_n      <= nxt_bs_n;
    end
end

assign dataout_en  = reg_dataoe_n;
assign ce_n      = reg_ce_n;
assign we_n      = reg_we_n;
assign oe_n      = reg_oe_n;
assign lb_n      = reg_bs_n[0];
assign ub_n      = reg_bs_n[1];


assign memfsmstate = reg_mstate;



























endmodule


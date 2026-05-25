//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2010-2012, 2016-2017, 2019-2020 Arm Limited or its affiliates.
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
//   Sub-module of css600_atbfunnel
//
//----------------------------------------------------------------------------


module css600_atbfunnel_apb_if# (
  parameter WRITE_REG_WIDTH = 12,
  parameter ATB_DATA_WIDTH = 32,
  parameter NUM_ATB_SLAVES = 8
)
(
  input wire         clk,
  input wire         reset_n,
  input wire         pseldbg,
  input wire         penabledbg,
  input wire         pwritedbg,
  input wire  [9:0]  paddrdbg,
  input wire  [WRITE_REG_WIDTH:0] pwdatadbg,
  input wire  [31:0] read_data,

  output wire        preadydbg,
  output wire        pslverrdbg,
  output wire [31:0] prdatadbg,
  output wire        reg_write,
  output wire        reg_read,
  output reg  [9:0]  reg_addr,
  output reg [WRITE_REG_WIDTH:0] write_data
);

  wire          apb_setup;
  wire      nxt_apb_valid;
  reg           apb_valid;
  wire      nxt_apb_valid_q;
  reg           apb_valid_q;
  reg [2:0]     prdatadbg_23_21;
  reg [2:0]     prdatadbg_20_18;
  reg           prdatadbg_17;
  reg [1:0]     prdatadbg_16_15;
  reg [2:0]     prdatadbg_14_12;
  reg [3:0]     prdatadbg_11_8;
  reg           prdatadbg_7;
  reg [6:0]     prdatadbg_6_0;

  always @(posedge clk or negedge reset_n)
    begin : p_apb_if
      if (!reset_n)
        begin
          reg_addr   <= {10{1'b0}};
          write_data <= {(WRITE_REG_WIDTH+1){1'b0}};
        end
      else
        if(apb_setup)
          begin
            reg_addr        <= paddrdbg;
            write_data      <= pwdatadbg;
          end
    end

  always @(posedge clk or negedge reset_n)
    begin : p_reg_prdata
      if (!reset_n)
        begin
          prdatadbg_6_0 <= {7{1'b0}};
          prdatadbg_11_8 <= {4{1'b0}};
        end
      else if (reg_read)
          begin
            prdatadbg_6_0  <= read_data[6:0];
            prdatadbg_11_8 <= read_data[11:8];
          end
    end

  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
        begin
          prdatadbg_7 <= 1'b0;
        end
      else if (reg_read)
          begin
            prdatadbg_7  <= read_data[7];
          end
    end

  generate
  if ((ATB_DATA_WIDTH > 64) || (NUM_ATB_SLAVES > 4)) begin: prdatadbg_14_12_cond

    always @(posedge clk or negedge reset_n)
      begin
        if (!reset_n)
          begin
            prdatadbg_14_12 <= {3{1'b0}};
          end
        else if (reg_read)
            begin
              prdatadbg_14_12  <= read_data[14:12];
            end
      end
  end
  else begin : prdatadbg_14_12_comb
    always @*
      prdatadbg_14_12  = read_data[14:12];
  end

  endgenerate

  generate
  if ((ATB_DATA_WIDTH > 64) || (NUM_ATB_SLAVES > 5)) begin: prdatadbg_16_15_cond

    always @(posedge clk or negedge reset_n)
      begin
        if (!reset_n)
          begin
            prdatadbg_16_15 <= {2{1'b0}};
          end
        else if (reg_read)
            begin
              prdatadbg_16_15  <= read_data[16:15];
            end
      end
  end
  else begin : prdatadbg_16_15_comb
    always @*
      prdatadbg_16_15  = read_data[16:15];
  end

  endgenerate
  generate
  if (NUM_ATB_SLAVES > 5) begin: prdatadbg_17_cond
    always @(posedge clk or negedge reset_n)
      begin
        if (!reset_n)
          begin
            prdatadbg_17 <= 1'b0;
          end
        else if (reg_read)
            begin
              prdatadbg_17  <= read_data[17];
            end
      end
  end
  else begin : prdatadbg_17_comb
    always @*
      prdatadbg_17  = read_data[17];
  end

  endgenerate

  generate
  if (NUM_ATB_SLAVES > 6) begin: prdatadbg_20_18_cond
    always @(posedge clk or negedge reset_n)
      begin
        if (!reset_n)
          begin
            prdatadbg_20_18 <= 3'b0;
          end
        else if (reg_read)
            begin
              prdatadbg_20_18  <= read_data[20:18];
            end
      end
  end
  else begin : prdatadbg_20_18_comb
  always @*
    prdatadbg_20_18  = read_data[20:18];
  end
  endgenerate

  generate
  if (NUM_ATB_SLAVES > 7) begin: prdatadbg_23_21_cond
    always @(posedge clk or negedge reset_n)
      begin
        if (!reset_n)
          begin
            prdatadbg_23_21 <= 3'b0;
          end
        else if (reg_read)
            begin
              prdatadbg_23_21  <= read_data[23:21];
            end
      end
  end
  else begin : prdatadbg_23_21_comb
    always @*
      prdatadbg_23_21  = read_data[23:21];
  end
  endgenerate


  assign prdatadbg = {read_data[31:24],
                      prdatadbg_23_21,
                      prdatadbg_20_18,
                      prdatadbg_17,
                      prdatadbg_16_15,
                      prdatadbg_14_12,
                      prdatadbg_11_8,
                      prdatadbg_7,
                      prdatadbg_6_0};


  assign reg_write = apb_valid & pwritedbg;

  assign reg_read = apb_valid & ~pwritedbg;

  assign apb_setup = (pseldbg & ~penabledbg)
                   | (pseldbg &  penabledbg & ~apb_valid)
                   ;


  assign nxt_apb_valid   = apb_setup | apb_valid & ~preadydbg;
  assign nxt_apb_valid_q =             apb_valid & ~preadydbg;

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n) begin
      apb_valid   <= 1'b0;
      apb_valid_q <= 1'b0;
    end
    else begin
      apb_valid   <= nxt_apb_valid;
      apb_valid_q <= nxt_apb_valid_q;
    end
  end

  assign preadydbg = pwritedbg ? apb_valid
                   :             apb_valid_q
                   ;
  assign pslverrdbg = 1'b0;

endmodule

//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------

module sse710_integration_example_f0_otp (
  input  wire              pclk,
  input  wire              presetn,

  input  wire              psel,
  input  wire [12:0]       paddr,
  input  wire              penable,
  input  wire              pwrite,
  input  wire [31:0]       pwdata,
  input  wire [3:0]        pstrb,
  output wire [31:0]       prdata,
  output wire              pready,
  output wire              pslverr,
  output wire              prog_completed
  );

  wire [9:0]     apb_wait_cycles  = 10'h0;   
  wire           apb_response     = 1'h0;    
  wire [9:0]     prog_wait_cycles = 10'd200; 


  wire           read_en;
  wire           write_en;

  reg  [31:0]    mem[8191:0];
  wire [31:0]    mem_nxt;

  reg [9:0]      pready_cnt;
  reg [9:0]      prog_cnt;
  reg            prog_comp_r;


  assign  read_en     = psel & (~pwrite);           
  assign  write_en    = psel & (~penable) & pwrite; 

  always @(posedge pclk or negedge presetn)
  begin
    if(~presetn)
    begin
      pready_cnt <= 10'h0;
    end
    else if(psel & ~pready) 
    begin
      pready_cnt <= pready_cnt + 10'h1;
    end
    else if(psel & pready)  
    begin
      pready_cnt <= 10'h0;
    end
  end

  assign pready = (pready_cnt == (apb_wait_cycles+10'h1)) ? 1'b1 : 1'b0;

  assign pslverr = apb_response ? 1'b1 : 1'b0;

  always @(posedge pclk or negedge presetn)
  begin
    if(~presetn)
    begin
      prog_cnt <= 10'h0;
    end
    else if(write_en & prog_comp_r) 
    begin
      prog_cnt <= 10'h0;
    end
    else if(~prog_comp_r)           
    begin
      prog_cnt <= prog_cnt + 10'h1;
    end
  end

  always @(posedge pclk or negedge presetn)
  begin
    if(~presetn)
    begin
      prog_comp_r <= 1'h1;
    end
    else if(write_en)                     
    begin
      prog_comp_r <= 1'h0;
    end
    else if(prog_cnt == prog_wait_cycles) 
    begin
      prog_comp_r <= 1'h1;
    end
  end

  assign prog_completed = prog_comp_r;   


  integer i;
  initial begin
    for(i = 0; i < 8192; i = i + 1)
    begin
      mem[i] = 32'b0;
    end
  end

  always @(posedge pclk)
  begin
    if(pstrb & write_en)
    begin
      mem[paddr] <= mem_nxt;
    end
  end

  assign mem_nxt = ((pwdata & { {8{pstrb[3]}},{8{pstrb[2]}}, {8{pstrb[1]}}, {8{pstrb[0]}}}) | mem[paddr]);

  assign prdata = read_en ? mem[paddr] : 32'hxxxx_xxxx;

endmodule



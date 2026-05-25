//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Thu Dec 1 16:03:15 2016 +0000
//
//      Revision            : 6ca04ec
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------
module sie200_ahb5_to_rom #(
 parameter ADDR_WIDTH  = 16,
 parameter WAIT_STATES = 1,
 parameter DATA_WIDTH  = 16
 )
  (
  input  wire                  hclk,
  input  wire                  hresetn,

  input  wire [ADDR_WIDTH-1:0] haddr,
  input  wire    [2:0]         hsize,
  input  wire    [1:0]         htrans,
  input  wire [DATA_WIDTH-1:0] hwdata,
  input  wire                  hwrite,
  output wire [DATA_WIDTH-1:0] hrdata,
  output wire                  hreadyout,
  output wire                  hresp,
  input  wire                  hsel,
  input  wire                  hready,

  output wire [ADDR_WIDTH-DATA_WIDTH/16-1:0] rom_addr,
  input  wire [DATA_WIDTH-1:0]               rom_rdata
  );

wire  [(1+(DATA_WIDTH/16)+3+DATA_WIDTH-1):0] unused = {htrans[0], haddr[DATA_WIDTH/16-1:0], hsize, hwdata};

wire          read_valid;
reg           read_valid_dp;
reg  [ADDR_WIDTH-DATA_WIDTH/16-1:0] reg_addr;

wire          rom_read_done;
reg    [1:0]  rom_wait_counter;
wire   [1:0]  nxt_rom_wait_counter;

wire   [1:0]  wait_states_cfg;

assign wait_states_cfg = (WAIT_STATES == 0) ? 2'b00 :
                         (WAIT_STATES == 1) ? 2'b01 :
                         (WAIT_STATES == 2) ? 2'b10 :
                                              2'b11 ;

assign read_valid  = hsel & htrans[1] & (~hwrite) & hready;

always @(posedge hclk or negedge hresetn)
begin
  if (~hresetn)
    begin
    read_valid_dp  <= 1'b0;
    reg_addr       <= {(ADDR_WIDTH-DATA_WIDTH/16){1'b0}};
    end
  else if (hready)
    begin
    read_valid_dp  <= read_valid;
    reg_addr       <= haddr[ADDR_WIDTH-1:DATA_WIDTH/16];
    end
end

assign rom_addr = reg_addr;

assign nxt_rom_wait_counter = (read_valid) ? wait_states_cfg :
  ((rom_wait_counter != {2{1'b0}}) ? (rom_wait_counter - 2'b01) : rom_wait_counter);

always @(posedge hclk or negedge hresetn)
begin
  if (~hresetn) begin
    rom_wait_counter    <= {2{1'b0}};
  end
  else if (read_valid | (rom_wait_counter != {2{1'b0}})) begin
    rom_wait_counter    <= nxt_rom_wait_counter;
  end
end

assign rom_read_done = (rom_wait_counter == 0);
assign hreadyout = (~read_valid_dp) | rom_read_done;
assign hresp     = 1'b0;
assign hrdata    = (read_valid_dp) ? rom_rdata : {DATA_WIDTH{1'b0}};
















endmodule



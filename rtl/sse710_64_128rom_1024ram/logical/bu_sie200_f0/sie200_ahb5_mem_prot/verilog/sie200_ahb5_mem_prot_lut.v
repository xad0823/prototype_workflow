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
//      Checked In          : Thu Jan 26 15:28:36 2017 +0000
//
//      Revision            : ff674d4
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_mem_prot_lut #(
  parameter ADDR_WIDTH      = 5,
  parameter DATA_WIDTH      = 32
)
(
  input  wire                       clk,
  input  wire                       resetn,

  input  wire                       init_value,
  output reg                        init_done,

  input  wire [11:0]                addr_a,
  input  wire [31:0]                data_in_a,
  input  wire                       write_a,
  output wire [31:0]                data_out_a,
  output wire                       valid_a,

  input  wire [11:0]                addr_b,
  output wire [31:0]                data_out_b,
  output wire                       valid_b
);



localparam ARRAY_DEPTH = 1 << ADDR_WIDTH;
localparam ARRAY_WIDTH = ADDR_WIDTH > 0 ? 32 : DATA_WIDTH;

reg  [ARRAY_WIDTH-1:0]  reg_array [0:ARRAY_DEPTH-1];

genvar i;
generate
  if (ADDR_WIDTH > 0) begin: LUT_ADDR_WIDTH_IS_NOT_0
    for(i=0; i<ARRAY_DEPTH; i=i+1) begin: GEN_REG_ARRAY_BITS
      always @ (posedge clk or negedge resetn) begin
        if(~resetn) begin
          reg_array[i] <= 32'h0;
        end
        else if (~init_done) begin
          reg_array[i] <= {32{init_value}};
        end
        else if (write_a && (i == addr_a[ADDR_WIDTH-1:0])) begin
          reg_array[i] <= data_in_a;
        end
      end
    end

    assign data_out_a = reg_array[addr_a[ADDR_WIDTH-1:0]];
    assign data_out_b = reg_array[addr_b[ADDR_WIDTH-1:0]];

    if (ADDR_WIDTH < 12) begin: UNUSED_ADDR
      localparam UNUSED_WIDTH = (2*(12-ADDR_WIDTH));
      wire [UNUSED_WIDTH-1:0] unused = {addr_a[11:ADDR_WIDTH],addr_b[11:ADDR_WIDTH]};
    end

  end
  else begin: LUT_ADDR_WIDTH_IS_0
    always @ (posedge clk or negedge resetn) begin
      if(~resetn) begin
        reg_array[0] <= {DATA_WIDTH{1'b0}};
      end
      else if (~init_done) begin
        reg_array[0] <= {DATA_WIDTH{init_value}};
      end
      else if (write_a) begin
        reg_array[0] <= data_in_a[DATA_WIDTH-1:0];
      end
    end

    assign data_out_a[DATA_WIDTH-1:0] = reg_array[0][DATA_WIDTH-1:0];
    assign data_out_b[DATA_WIDTH-1:0] = reg_array[0][DATA_WIDTH-1:0];

    localparam UNUSED_WIDTH = 24 + (32-DATA_WIDTH);
    wire [UNUSED_WIDTH-1:0] unused;
    assign unused[23:0] = {addr_a,addr_b};

    if (DATA_WIDTH != 32) begin: UNUSED_ADDR_DATA
      assign unused[UNUSED_WIDTH-1:24] = data_in_a[31:DATA_WIDTH];
      assign data_out_a[31:DATA_WIDTH] = {(32-DATA_WIDTH){1'b0}};
      assign data_out_b[31:DATA_WIDTH] = {(32-DATA_WIDTH){1'b0}};
    end
  end

endgenerate


always @ (posedge clk or negedge resetn) begin
  if(~resetn) begin
    init_done <= 1'b0;
  end
  else begin
    init_done <= 1'b1;
  end
end

assign valid_a    = 1'b1;
assign valid_b    = 1'b1;




endmodule

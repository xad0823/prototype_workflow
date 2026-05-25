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

module firewall_f0_comp_message_creator #(
    parameter MSG_NOFRMT_SIZE     = 32,
    parameter READ_DATA_SIZE      = 7,
    parameter MSG_SIZE            = 35,
    parameter MSG_TYPE_WIDTH      = 3,
    parameter MSG_TYPE_READ       = 3'b000,
    parameter MSG_TYPE_WRITE      = 3'b001,
    parameter MSG_TYPE_CONNECT    = 3'b010,
    parameter MSG_TYPE_DISCONNECT = 3'b011,
    parameter MSG_TYPE_IRQ        = 3'b100,
    parameter FC_CFG_DATA_W       = 32,
    parameter READ_MSG_HDR_SIZE   = 3,
    parameter CFG_READ_RSP_T      = 1'b1,
    parameter CFG_WRITE_RSP_T     = 1'b0,
    parameter CFG_RSP_T           = 2'b10,
    parameter HNDSHK_REQ_T        = 2'b00,
    parameter IRQ_REQ_T           = 2'b01,
    parameter MAX_NUM_OF_PKTS     = 2,
    parameter MSG_SIZE_WIDTH      = 1
) (
    input  wire [MSG_TYPE_WIDTH-1:0]  msg_crtr_msg_type_i,
    input  wire [MSG_NOFRMT_SIZE-1:0] msg_crtr_msg_data_i,
    input  wire [READ_DATA_SIZE-1:0]  msg_crtr_msg_rd_size_i,
    input  wire                       msg_crtr_msg_valid_i,

    output wire [MSG_SIZE-1:0]        msg_crtr_msg_data_o,
    output wire [MSG_SIZE_WIDTH-1:0]  msg_crtr_msg_size_o,
    output wire                       msg_crtr_msg_valid_o,

    output wire                       msg_crtr_lpi_busy_o
);


localparam ONE_BYTE = 0;

reg [MSG_SIZE-1:0]       msg_crtr_msg_data_o_int;
reg [MSG_SIZE_WIDTH-1:0] msg_crtr_msg_size_o_int;

wire [MSG_SIZE_WIDTH-1:0] rd_data_beats;

reg bit4;


generate
  if (MAX_NUM_OF_PKTS < 3) begin : MAX_2_BEATS
    assign rd_data_beats = (msg_crtr_msg_rd_size_i > (FC_CFG_DATA_W-3)) ? 1'b1 : 1'b0;
  end
  else begin: OVER_2_BEATS

    integer i;
    reg [MSG_SIZE_WIDTH-1:0] rd_data_beats_int;

    always @* begin
      for (i=0; i<MAX_NUM_OF_PKTS; i=i+1) begin
        if ((msg_crtr_msg_rd_size_i > ((FC_CFG_DATA_W*i)-3)) &&
            (msg_crtr_msg_rd_size_i <= ((FC_CFG_DATA_W*(i+1))-3))) begin
          rd_data_beats_int = i[MSG_SIZE_WIDTH-1:0];
        end
      end
    end

    assign rd_data_beats = rd_data_beats_int;

  end
endgenerate


always @(*)
begin
  case (msg_crtr_msg_type_i)
    MSG_TYPE_READ: begin 
      msg_crtr_msg_data_o_int  = {msg_crtr_msg_data_i,
                                  CFG_READ_RSP_T, CFG_RSP_T};
      msg_crtr_msg_size_o_int  = rd_data_beats;
      bit4                     = 1'b0;
    end

    MSG_TYPE_WRITE: begin 
      bit4 = msg_crtr_msg_data_i[0] ? msg_crtr_msg_data_i[1] : 1'b0;

      msg_crtr_msg_data_o_int  = {{(MSG_SIZE-8){1'b0}},{3{1'b0}},
                                 bit4,msg_crtr_msg_data_i[0],
                                 CFG_WRITE_RSP_T, CFG_RSP_T};
      msg_crtr_msg_size_o_int  = ONE_BYTE[MSG_SIZE_WIDTH-1:0];
    end

    MSG_TYPE_CONNECT: begin 
      msg_crtr_msg_data_o_int  = {{(MSG_SIZE-8){1'b0}},{4{1'b0}},
                                 msg_crtr_msg_data_i[0],1'b0, HNDSHK_REQ_T};
      msg_crtr_msg_size_o_int  = ONE_BYTE[MSG_SIZE_WIDTH-1:0];
      bit4                     = 1'b0;
    end

    MSG_TYPE_DISCONNECT: begin 
      msg_crtr_msg_data_o_int  = {{(MSG_SIZE-8){1'b0}},{5{1'b0}},
                                 1'b1, HNDSHK_REQ_T};
      msg_crtr_msg_size_o_int  = ONE_BYTE[MSG_SIZE_WIDTH-1:0];
      bit4                     = 1'b0;
    end

    MSG_TYPE_IRQ: begin 
      msg_crtr_msg_data_o_int  = {{(MSG_SIZE-8){1'b0}}, 1'b0,
                                 msg_crtr_msg_data_i[4:0], IRQ_REQ_T};
      msg_crtr_msg_size_o_int  = ONE_BYTE[MSG_SIZE_WIDTH-1:0];
      bit4                     = 1'b0;
    end

    default: begin 
      msg_crtr_msg_data_o_int  = {MSG_SIZE{1'bx}};
      msg_crtr_msg_size_o_int  = {MSG_SIZE_WIDTH{1'bx}};
      bit4                     = 1'bx;
    end
  endcase
end


assign msg_crtr_msg_data_o  = msg_crtr_msg_data_o_int;
assign msg_crtr_msg_size_o  = msg_crtr_msg_size_o_int;
assign msg_crtr_msg_valid_o = msg_crtr_msg_valid_i;
assign msg_crtr_lpi_busy_o  = msg_crtr_msg_valid_i;

endmodule

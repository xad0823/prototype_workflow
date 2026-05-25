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

module firewall_f0_ctlr_message_creator #(
    parameter LOG2_FW_NUM_FC   = 5,
    parameter FC_CFG_DATA_W    = 32,
    parameter REG_ADDR_WIDTH   = 10,
    parameter MSG_SIZE         = 45,
    parameter FW_SRE_LVL       = 1,
    parameter CFG_REQ_T        = 2'b10,
    parameter CFG_READ_REQ_T   = 1'b1,
    parameter CFG_WRITE_REQ_T  = 1'b0,
    parameter HNDSHK_RSP_T     = 2'b00,
    parameter HNDSHK_CNCT_T    = 1'b0,
    parameter HNDSHK_DISCNCT_T = 1'b1,
    parameter REG_DATA_WIDTH   = 32,
    parameter LOG2_MSG_SIZE    = 6,
    parameter READ_DATA_SIZE   = 7,
    parameter FW_NUM_FC        = 7,
    parameter MAX_NUM_OF_PKTS  = 2,
    parameter MSG_SIZE_WIDTH   = 1

) (
    input  wire                      clk,
    input  wire                      reset_n,

    input  wire [LOG2_FW_NUM_FC-1:0] msg_crtr_pwr_fw_id_i,
    input  wire                      msg_crtr_con_valid_i,
    input  wire                      msg_crtr_discon_valid_i,

    input  wire [REG_ADDR_WIDTH-1:0] msg_crtr_reg_addr_i,
    input  wire                      msg_crtr_rw_i,
    input  wire [LOG2_FW_NUM_FC-1:0] msg_crtr_fw_id_i,
    input  wire [FC_CFG_DATA_W-1:0]  msg_crtr_wr_data_i,
    input  wire [READ_DATA_SIZE-1:0] msg_crtr_reg_size_i,
    input  wire                      msg_crtr_acc_valid_i,

    input  wire [LOG2_FW_NUM_FC-1:0] msg_crtr_restore_fw_id_i,
    input  wire                      msg_crtr_restore_valid_i,
    input  wire [FC_CFG_DATA_W-1:0]  msg_crtr_restore_data_i,
    input  wire                      msg_crtr_cfg_valid_i,

    output wire [MSG_SIZE-1:0]       msg_crtr_msg_data_o,
    output wire [MSG_SIZE_WIDTH-1:0] msg_crtr_msg_size_o,
    output wire                      msg_crtr_msg_valid_o,
    output wire [LOG2_FW_NUM_FC-1:0] msg_crtr_id_o,

    input  wire [8*FW_NUM_FC-1:0]    msg_crtr_prot_size_i
);


`include "firewall_f0_ceil_divide.vh"
`include "firewall_f0_log2.vh"


localparam READ    = 3'b001; 
localparam WRITE   = 3'b010; 
localparam CNCT    = 3'b011; 
localparam DISCNCT = 3'b100; 
localparam RESTORE = 3'b101; 

localparam READ_MSG_SIZE    = 16; 
localparam DISCNCT_MSG_SIZE = 8;  
localparam CNCT_MSG_SIZE    = 16; 

localparam MAX_NO_PKTS = firewall_f0_ceil_divide(MSG_SIZE, FC_CFG_DATA_W);

localparam ONE_BYTE = 0;
localparam TWO_BYTE = 1;


reg  [2:0] msg_type;
reg  [2:0] reg_msg_type;
reg  [2:0] comb_msg_type;
wire [4:0] aux_comb_msg_type;

wire [MSG_SIZE_WIDTH-1:0] no_of_pkts;


reg [MSG_SIZE-1:0]       msg_crtr_msg_data_o_int;
reg [MSG_SIZE_WIDTH-1:0] msg_crtr_msg_size_o_int;
reg [LOG2_FW_NUM_FC-1:0] msg_crtr_id_o_int;
reg [7:0]                fw_prot_size_int;

integer fw_id;


assign aux_comb_msg_type[0] = (msg_crtr_acc_valid_i || msg_crtr_cfg_valid_i) &&
  !msg_crtr_rw_i;
assign aux_comb_msg_type[1] = (msg_crtr_acc_valid_i || msg_crtr_cfg_valid_i) &&
  msg_crtr_rw_i;
assign aux_comb_msg_type[2] = msg_crtr_con_valid_i;
assign aux_comb_msg_type[3] = msg_crtr_discon_valid_i;
assign aux_comb_msg_type[4] = msg_crtr_restore_valid_i;

always @* begin
  fw_prot_size_int = 8'b0;
  for (fw_id=0; fw_id<FW_NUM_FC; fw_id=fw_id+1) begin
    if (fw_id == msg_crtr_pwr_fw_id_i) begin
      fw_prot_size_int = msg_crtr_prot_size_i[fw_id*8 +: 8];
    end
  end
end

always @(*)
begin
  case (aux_comb_msg_type)
    5'b00001: comb_msg_type = 3'b001;
    5'b00010: comb_msg_type = 3'b010;
    5'b00100: comb_msg_type = 3'b011;
    5'b01000: comb_msg_type = 3'b100;
    5'b10000: comb_msg_type = 3'b101;
    default : comb_msg_type = 3'bxxx;
  endcase
end

always @(posedge clk or negedge reset_n)
begin: REGISTER_MSG_TYPE
  if (!reset_n) begin
    reg_msg_type <= 3'b000;
  end
  else begin
    if (msg_crtr_msg_valid_o) begin
      reg_msg_type <= comb_msg_type;
    end
  end
end

always @(*)
begin
  if (msg_crtr_msg_valid_o) begin
    msg_type = comb_msg_type;
  end
  else begin
    msg_type = reg_msg_type;
  end
end

generate
  if (MAX_NUM_OF_PKTS < 3) begin : MAX_2_BEATS
    assign no_of_pkts = (msg_crtr_reg_size_i > (FC_CFG_DATA_W-REG_ADDR_WIDTH-3)) ? 1'b1 : 1'b0;
  end
  else begin: OVER_2_BEATS

    integer i;
    reg [MSG_SIZE_WIDTH-1:0] no_of_pkts_int;

    always @* begin
      for (i=0; i<MAX_NUM_OF_PKTS; i=i+1) begin
        if ((msg_crtr_reg_size_i > ((FC_CFG_DATA_W*i)-REG_ADDR_WIDTH-3)) &&
            (msg_crtr_reg_size_i <= ((FC_CFG_DATA_W*(i+1))-REG_ADDR_WIDTH-3))) begin
          no_of_pkts_int = i[MSG_SIZE_WIDTH-1:0];
        end
      end
    end

    assign no_of_pkts = no_of_pkts_int;

  end
endgenerate

always @(*)
begin:FORMAT_MESSAGE
  case (msg_type)
    READ: begin
      msg_crtr_msg_data_o_int = {{(MSG_SIZE-READ_MSG_SIZE){1'b0}},{3{1'b0}},
                                 msg_crtr_reg_addr_i,CFG_READ_REQ_T,
                                 CFG_REQ_T};

      msg_crtr_msg_size_o_int = (FC_CFG_DATA_W < READ_MSG_SIZE) ?
                                TWO_BYTE[MSG_SIZE_WIDTH-1:0]:
                                ONE_BYTE[MSG_SIZE_WIDTH-1:0];

      msg_crtr_id_o_int = msg_crtr_fw_id_i;
    end
    WRITE: begin
      if (MSG_SIZE>(REG_DATA_WIDTH+REG_ADDR_WIDTH+3)) begin
        msg_crtr_msg_data_o_int =
          {{(MSG_SIZE-REG_DATA_WIDTH-REG_ADDR_WIDTH-3){1'b0}},
           msg_crtr_wr_data_i,msg_crtr_reg_addr_i,CFG_WRITE_REQ_T,CFG_REQ_T};
      end
      else begin
        msg_crtr_msg_data_o_int =
         {msg_crtr_wr_data_i,msg_crtr_reg_addr_i,CFG_WRITE_REQ_T,CFG_REQ_T};
      end

      msg_crtr_msg_size_o_int = no_of_pkts;

      msg_crtr_id_o_int = msg_crtr_fw_id_i;
    end
    CNCT: begin
      msg_crtr_msg_data_o_int = {{(MSG_SIZE-CNCT_MSG_SIZE){1'b0}},
                                 {4{1'b0}}, fw_prot_size_int,
                                 1'b0, HNDSHK_CNCT_T,
                                 HNDSHK_RSP_T};

      msg_crtr_msg_size_o_int = (FC_CFG_DATA_W < CNCT_MSG_SIZE) ?
                                 TWO_BYTE[MSG_SIZE_WIDTH-1:0]:
                                 ONE_BYTE[MSG_SIZE_WIDTH-1:0];

      msg_crtr_id_o_int = msg_crtr_pwr_fw_id_i;
    end
    DISCNCT: begin
      msg_crtr_msg_data_o_int = {{(MSG_SIZE-DISCNCT_MSG_SIZE){1'b0}},
                                 {5{1'b0}}, HNDSHK_DISCNCT_T, HNDSHK_RSP_T};

      msg_crtr_msg_size_o_int = {(MSG_SIZE_WIDTH){1'b0}};

      msg_crtr_id_o_int = msg_crtr_pwr_fw_id_i;
    end
    RESTORE: begin
      msg_crtr_msg_data_o_int  = {{(MSG_SIZE-FC_CFG_DATA_W){1'b0}},
                                  msg_crtr_restore_data_i};

      msg_crtr_msg_size_o_int = (FC_CFG_DATA_W < 16) ?
                                 TWO_BYTE[MSG_SIZE_WIDTH-1:0]:
                                 ONE_BYTE[MSG_SIZE_WIDTH-1:0];

      msg_crtr_id_o_int = msg_crtr_restore_fw_id_i;
    end
    default: begin
      msg_crtr_msg_data_o_int  = {MSG_SIZE{1'bx}};
      msg_crtr_msg_size_o_int  = {MSG_SIZE_WIDTH{1'bx}};
      msg_crtr_id_o_int        = {LOG2_FW_NUM_FC{1'bx}};
    end
  endcase
end


assign msg_crtr_msg_valid_o = msg_crtr_acc_valid_i ||
                              msg_crtr_con_valid_i ||
                              msg_crtr_discon_valid_i ||
                              msg_crtr_restore_valid_i ||
                              msg_crtr_cfg_valid_i;
assign msg_crtr_msg_data_o  = msg_crtr_msg_data_o_int;
assign msg_crtr_msg_size_o  = msg_crtr_msg_size_o_int;
assign msg_crtr_id_o        = msg_crtr_id_o_int;

endmodule

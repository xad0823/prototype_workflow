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

module sie200_ahb5_to_extmem16_ahb_fsm #(
  parameter ADDR_WIDTH  = 16,
  parameter ENDIANNESS  = 0
)
(
  input  wire          hclk,
  input  wire          hresetn,

  input  wire          hsel,
  input  wire [ADDR_WIDTH-1:0] haddr,
  input  wire    [1:0] htrans,
  input  wire    [2:0] hsize,
  input  wire          hwrite,
  input  wire   [31:0] hwdata,
  input  wire          hready,
  output wire          hreadyout,
  output wire   [31:0] hrdata,
  output wire          hresp,

  input  wire          cfg_size,

  output wire [ADDR_WIDTH-1:0] addr,
  output reg    [15:0] dataout,
  input  wire   [15:0] datain,

  output reg           rdreq,
  output reg           wrreq,
  output reg     [1:0] nxtbytemask,
  input  wire          done,

  output wire    [2:0] busfsmstate);

  reg       [2:0] reg_bstate;
  reg       [2:0] nxt_bstate;

  localparam BUSCNV_FSM_DEF      = 3'b000;
  localparam BUSCNV_FSM_32BIT_8A = 3'b001;
  localparam BUSCNV_FSM_32BIT_8B = 3'b011;
  localparam BUSCNV_FSM_32BIT_8C = 3'b010;
  localparam BUSCNV_FSM_32BIT_16 = 3'b100;
  localparam BUSCNV_FSM_16BIT_8  = 3'b101;


  wire            trans_valid;
  reg             reg_write;
  reg             reg_active;
  reg       [1:0] reg_size;

  reg       [1:0] reg_addr_low;
  reg       [1:0] nxt_addr_low;
  reg    [ADDR_WIDTH-3:0] reg_addr_high;
  reg    [ADDR_WIDTH-3:0] nxt_addr_high;
  reg       [1:0] reg_lb_mux;
  reg       [1:0] nxt_lb_mux;
  reg       [1:0] reg_ub_mux;
  reg       [1:0] nxt_ub_mux;
  reg       [1:0] reg_byte_mask;
  reg             reg_rd_req;
  reg             reg_wr_req;
  wire      [2:0] merged_cfgsize_hsize;
  wire      [2:0] merged_cfgsize_reg_size;
  wire     [15:0] i_dataout;
  reg       [7:0] read_buffer_0;
  reg       [7:0] read_buffer_1;
  reg       [7:0] read_buffer_2;

  reg      [31:0] i_hrdata;

  assign trans_valid = hsel & hready & htrans[1];

  always @(posedge hclk or negedge hresetn)
  begin
  if (~hresetn)
    begin
    reg_write <= 1'b0;
    reg_active<= 1'b0;
    reg_size  <= 2'b00;
    end
  else if (hready)
    begin
    reg_write <= hwrite;
    reg_active<= trans_valid;
    reg_size  <= hsize[1:0];
    end
  end

  assign merged_cfgsize_hsize = {cfg_size, hsize[1:0]};

  always @(reg_bstate or  trans_valid or reg_write or
    hwrite or haddr or reg_addr_low or reg_addr_high or
    reg_lb_mux or reg_ub_mux or reg_byte_mask or done or
    reg_rd_req or reg_wr_req or merged_cfgsize_hsize)
  begin
  case (reg_bstate)
    BUSCNV_FSM_DEF :
    begin
    if (trans_valid)
      begin
      case (merged_cfgsize_hsize)
        3'b0_00 : begin
          nxt_bstate   = BUSCNV_FSM_DEF;
          nxt_addr_low = haddr[1:0];
          nxt_addr_high= haddr[ADDR_WIDTH-1:2];
          rdreq        = ~hwrite;
          wrreq        =  hwrite;
          nxt_lb_mux   = haddr[1:0];
          nxt_ub_mux   = 2'b01;
          nxtbytemask  = 2'b01;
          end
        3'b0_01 : begin
          nxt_bstate   = BUSCNV_FSM_16BIT_8;
          nxt_addr_low = haddr[1:0];
          nxt_addr_high= haddr[ADDR_WIDTH-1:2];
          rdreq        = ~hwrite;
          wrreq        =  hwrite;
          nxt_lb_mux   = haddr[1:0];
          nxt_ub_mux   = 2'b01;
          nxtbytemask  = 2'b01;
          end
        3'b0_10, 3'b0_11 : begin
          nxt_bstate   = BUSCNV_FSM_32BIT_8A;
          nxt_addr_low = haddr[1:0];
          nxt_addr_high= haddr[ADDR_WIDTH-1:2];
          rdreq        = ~hwrite;
          wrreq        =  hwrite;
          nxt_lb_mux   = haddr[1:0];
          nxt_ub_mux   = 2'b01;
          nxtbytemask  = 2'b01;
          end
    3'b1_00 : begin
          nxt_bstate   = BUSCNV_FSM_DEF;
          nxt_addr_low = haddr[1:0];
          nxt_addr_high= haddr[ADDR_WIDTH-1:2];
          rdreq        = ~hwrite;
          wrreq        =  hwrite;
          nxt_lb_mux   = {haddr[1], 1'b0};
          nxt_ub_mux   = {haddr[1], 1'b1};
          nxtbytemask  = {haddr[0], ~haddr[0]};
          end
        3'b1_01 : begin
          nxt_bstate   = BUSCNV_FSM_DEF;
          nxt_addr_low = haddr[1:0];
          nxt_addr_high= haddr[ADDR_WIDTH-1:2];
          rdreq        = ~hwrite;
          wrreq        =  hwrite;
          nxt_lb_mux   = {haddr[1], 1'b0};
          nxt_ub_mux   = {haddr[1], 1'b1};
          nxtbytemask  = 2'b11;
          end
        3'b1_10, 3'b1_11 : begin
          nxt_bstate   = BUSCNV_FSM_32BIT_16;
          nxt_addr_low = haddr[1:0];
          nxt_addr_high= haddr[ADDR_WIDTH-1:2];
          rdreq        = ~hwrite;
          wrreq        =  hwrite;
          nxt_lb_mux   = {haddr[1], 1'b0};
          nxt_ub_mux   = {haddr[1], 1'b1};
          nxtbytemask  = 2'b11;
          end
        default : begin
          nxt_bstate   = 3'bxxx;
          nxt_addr_low = 2'bxx;
          nxt_addr_high= {(ADDR_WIDTH-2){1'bx}};
          rdreq        = 1'bx;
          wrreq        = 1'bx;
          nxt_lb_mux   = 2'bxx;
          nxt_ub_mux   = 2'bxx;
          nxtbytemask  = 2'bxx;
          end
      endcase
      end
    else
      begin
      nxt_bstate   = BUSCNV_FSM_DEF;
      nxt_addr_low = reg_addr_low;
      nxt_addr_high= reg_addr_high;
      rdreq        = reg_rd_req & (~done);
      wrreq        = reg_wr_req & (~done);
      nxt_lb_mux   = reg_lb_mux;
      nxt_ub_mux   = reg_ub_mux;
      nxtbytemask  = reg_byte_mask;
      end
    end
    BUSCNV_FSM_32BIT_16 :
    begin
    if (~done)
      begin
      nxt_bstate   = reg_bstate;
      nxt_addr_low = reg_addr_low;
      nxt_addr_high= reg_addr_high;
      rdreq        = ~reg_write;
      wrreq        =  reg_write;
      nxt_lb_mux   = reg_lb_mux;
      nxt_ub_mux   = {reg_ub_mux[1], 1'b1};
      nxtbytemask  = reg_byte_mask;
      end
    else
      begin
      nxt_bstate   = BUSCNV_FSM_DEF;
      nxt_addr_low = 2'b10;
      nxt_addr_high= reg_addr_high;
      rdreq        = ~reg_write;
      wrreq        =  reg_write;
      nxt_lb_mux   = 2'b10;
      nxt_ub_mux   = 2'b11;
      nxtbytemask  = reg_byte_mask;
      end
    end
    BUSCNV_FSM_32BIT_8A :
    begin
    if (~done)
      begin
      nxt_bstate   = reg_bstate;
      nxt_addr_low = reg_addr_low;
      nxt_addr_high= reg_addr_high;
      rdreq        = ~reg_write;
      wrreq        =  reg_write;
      nxt_lb_mux   = reg_lb_mux;
      nxt_ub_mux   = {reg_ub_mux[1], 1'b1};
      nxtbytemask  = reg_byte_mask;
      end
    else
      begin
      nxt_bstate   = BUSCNV_FSM_32BIT_8B;
      nxt_addr_low = 2'b01;
      nxt_addr_high= reg_addr_high;
      rdreq        = ~reg_write;
      wrreq        =  reg_write;
      nxt_lb_mux   = 2'b01;
      nxt_ub_mux   = {reg_ub_mux[1], 1'b1};
      nxtbytemask  = reg_byte_mask;
      end
    end
    BUSCNV_FSM_32BIT_8B :
    begin
    if (~done)
      begin
      nxt_bstate   = reg_bstate;
      nxt_addr_low = reg_addr_low;
      nxt_addr_high= reg_addr_high;
      rdreq        = ~reg_write;
      wrreq        =  reg_write;
      nxt_lb_mux   = reg_lb_mux;
      nxt_ub_mux   = {reg_ub_mux[1], 1'b1};
      nxtbytemask  = reg_byte_mask;
      end
    else
      begin
      nxt_bstate   = BUSCNV_FSM_32BIT_8C;
      nxt_addr_low = 2'b10;
      nxt_addr_high= reg_addr_high;
      rdreq        = ~reg_write;
      wrreq        =  reg_write;
      nxt_lb_mux   = 2'b10;
      nxt_ub_mux   = {reg_ub_mux[1], 1'b1};
      nxtbytemask  = reg_byte_mask;
      end
    end
    BUSCNV_FSM_32BIT_8C :
    begin
    if (~done)
      begin
      nxt_bstate   = reg_bstate;
      nxt_addr_low = reg_addr_low;
      nxt_addr_high= reg_addr_high;
      rdreq        = ~reg_write;
      wrreq        =  reg_write;
      nxt_lb_mux   = reg_lb_mux;
      nxt_ub_mux   = {reg_ub_mux[1], 1'b1};
      nxtbytemask  = reg_byte_mask;
      end
    else
      begin
      nxt_bstate   = BUSCNV_FSM_DEF;
      nxt_addr_low = 2'b11;
      nxt_addr_high= reg_addr_high;
      rdreq        = ~reg_write;
      wrreq        =  reg_write;
      nxt_lb_mux   = 2'b11;
      nxt_ub_mux   = {reg_ub_mux[1], 1'b1};
      nxtbytemask  = reg_byte_mask;
      end
    end
    BUSCNV_FSM_16BIT_8 :
    begin
    if (~done)
      begin
      nxt_bstate   = reg_bstate;
      nxt_addr_low = reg_addr_low;
      nxt_addr_high= reg_addr_high;
      rdreq        = ~reg_write;
      wrreq        =  reg_write;
      nxt_lb_mux   = reg_lb_mux;
      nxt_ub_mux   = {reg_ub_mux[1], 1'b1};
      nxtbytemask  = reg_byte_mask;
      end
    else
      begin
      nxt_bstate   = BUSCNV_FSM_DEF;
      nxt_addr_low = {reg_addr_low[1], 1'b1};
      nxt_addr_high= reg_addr_high;
      rdreq        = ~reg_write;
      wrreq        =  reg_write;
      nxt_lb_mux   = {reg_addr_low[1], 1'b1};
      nxt_ub_mux   = {reg_ub_mux[1], 1'b1};
      nxtbytemask  = reg_byte_mask;
      end
    end
    default :
      begin
      nxt_bstate   = 3'bxxx;
      nxt_addr_low = 2'bxx;
      nxt_addr_high= {(ADDR_WIDTH-2){1'bx}};
      rdreq        = 1'bx;
      wrreq        = 1'bx;
      nxt_lb_mux   = 2'bxx;
      nxt_ub_mux   = 2'bxx;
      nxtbytemask  = 2'bxx;
      end
  endcase
  end

  always @(posedge hclk or negedge hresetn)
  begin
  if (~hresetn)
    begin
    reg_bstate    <= BUSCNV_FSM_DEF;
    reg_addr_low  <= 2'b00;
    reg_addr_high <= {(ADDR_WIDTH-2){1'b0}};
    reg_rd_req    <= 1'b0;
    reg_wr_req    <= 1'b0;
    reg_lb_mux    <= 2'b00;
    reg_ub_mux    <= 2'b01;
    reg_byte_mask <= 2'b00;
    end
  else
    begin
    reg_bstate    <= nxt_bstate;
    reg_addr_low  <= nxt_addr_low;
    reg_addr_high <= nxt_addr_high;
    reg_rd_req    <= rdreq;
    reg_wr_req    <= wrreq;
    reg_lb_mux    <= nxt_lb_mux;
    reg_ub_mux    <= nxt_ub_mux;
    reg_byte_mask <= nxtbytemask;
    end
  end

  assign addr = {reg_addr_high, reg_addr_low};

  generate
    if(ENDIANNESS == 2) begin: WRITE_WORD_BIG_ENDIAN
      assign i_dataout[ 7:0] = (reg_lb_mux[1]) ? ((reg_lb_mux[0]) ? hwdata[7:0]   : hwdata[15:8]) :
                                                 ((reg_lb_mux[0]) ? hwdata[23:16] : hwdata[31:24]);
      assign i_dataout[15:8] = (reg_ub_mux[1]) ? hwdata[7:0] : hwdata[23:16];
    end
    else begin : WRITE_LITTLE_OR_BYTE_BIG_ENDIAN
      assign i_dataout[ 7:0] = (reg_lb_mux[1]) ? ((reg_lb_mux[0]) ? hwdata[31:24] : hwdata[23:16]) :
                                                 ((reg_lb_mux[0]) ? hwdata[15:8]  : hwdata[7:0]) ;
      assign i_dataout[15:8] = (reg_ub_mux[1]) ? hwdata[31:24] : hwdata[15:8];
    end
  endgenerate


  always @(posedge hclk or negedge hresetn)
  begin
  if (~hresetn)
    begin
    dataout <= {16{1'b0}};
    end
  else if (reg_active & reg_write)
    begin
    dataout <= i_dataout;
    end
  end

  always @(posedge hclk or negedge hresetn)
  begin
  if (~hresetn)
    read_buffer_0 <= {8{1'b0}};
  else if (reg_active & (~reg_write))
    begin
    if (done & (reg_lb_mux[1:0] == 2'b00))
        read_buffer_0 <= datain[7:0];
    end
  end

  always @(posedge hclk or negedge hresetn)
  begin
  if (~hresetn)
    read_buffer_1 <= {8{1'b0}};
  else if (reg_active & (~reg_write))
    begin
    if (done & (reg_bstate == BUSCNV_FSM_32BIT_16))
        read_buffer_1 <= datain[15:8];
    else if (done & (reg_bstate == BUSCNV_FSM_32BIT_8B))
        read_buffer_1 <= datain[ 7:0];
    end
  end

  always @(posedge hclk or negedge hresetn)
  begin
  if (~hresetn)
    read_buffer_2 <= {8{1'b0}};
  else if (reg_active & (~reg_write))
    begin
    if (done & (reg_bstate == BUSCNV_FSM_16BIT_8))
        read_buffer_2 <= datain[7:0];
    else if (done & (reg_bstate == BUSCNV_FSM_32BIT_8C))
        read_buffer_2 <= datain[ 7:0];
    end
  end


  assign merged_cfgsize_reg_size = {cfg_size , reg_size[1:0]};


  generate
    if(ENDIANNESS == 2) begin: READ_WORD_BIG_ENDIAN
      always @(merged_cfgsize_reg_size or datain or read_buffer_0 or read_buffer_1 or read_buffer_2)
      begin
        case (merged_cfgsize_reg_size)
          3'b0_00 : i_hrdata = {datain[ 7:0],  datain[7:0],   datain[7:0],   datain[7:0]};
          3'b0_01 : i_hrdata = {read_buffer_0, datain[7:0],   read_buffer_2, datain[7:0]};
          3'b0_10 : i_hrdata = {read_buffer_0, read_buffer_1, read_buffer_2, datain[7:0]};
          3'b0_11 : i_hrdata = {read_buffer_0, read_buffer_1, read_buffer_2, datain[7:0]};
          3'b1_00 : i_hrdata = {datain[7:0],   datain[15:8],  datain[7:0],   datain[15:8]};
          3'b1_01 : i_hrdata = {datain[7:0],   datain[15:8],  datain[7:0],   datain[15:8]};
          3'b1_10 : i_hrdata = {read_buffer_0, read_buffer_1, datain[7:0],   datain[15:8]};
          3'b1_11 : i_hrdata = {read_buffer_0, read_buffer_1, datain[7:0],   datain[15:8]};
          default : i_hrdata = {32{1'bx}};
        endcase
      end
    end
    else begin : READ_LITTLE_OR_BYTE_BIG_ENDIAN
      always @(merged_cfgsize_reg_size or datain or read_buffer_0 or read_buffer_1 or read_buffer_2)
      begin
        case (merged_cfgsize_reg_size)
          3'b0_00 : i_hrdata = {datain[7:0],  datain[7:0],   datain[7:0],   datain[7:0]};
          3'b0_01 : i_hrdata = {datain[7:0],  read_buffer_2, datain[7:0],   read_buffer_0};
          3'b0_10 : i_hrdata = {datain[7:0],  read_buffer_2, read_buffer_1, read_buffer_0};
          3'b0_11 : i_hrdata = {datain[7:0],  read_buffer_2, read_buffer_1, read_buffer_0};
          3'b1_00 : i_hrdata = {datain[15:8], datain[7:0],   datain[15:8],  datain[7:0]};
          3'b1_01 : i_hrdata = {datain[15:8], datain[7:0],   datain[15:8],  datain[7:0]};
          3'b1_10 : i_hrdata = {datain[15:8], datain[7:0],   read_buffer_1, read_buffer_0};
          3'b1_11 : i_hrdata = {datain[15:8], datain[7:0],   read_buffer_1, read_buffer_0};
          default : i_hrdata = {32{1'bx}};
        endcase
      end
    end
  endgenerate


  assign hreadyout   = (~reg_active) | ((reg_bstate==BUSCNV_FSM_DEF) & done);

  assign hresp       = 1'b0;

  assign hrdata      = i_hrdata;

  assign busfsmstate = reg_bstate;














endmodule


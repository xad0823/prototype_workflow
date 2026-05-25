//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2004,2008, 2012, 2016-2019 Arm Limited or its affiliates.
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
//   Sub-module of css600_tpiu
//
//----------------------------------------------------------------------------


module css600_tpiu_trace_fifo
#(
  parameter ATB_DATA_WIDTH = 32,
  parameter FF_SYNC_DEPTH = 2
)
(
  traceclk_in,
  treset_n,
  rd_ptr_gray,
  wr_ptr_gray_sync,
  fifo_data,
  fifo_r_data,
  pop_fifo,
  fifo_empty
);

  localparam BUFFER_DEPTH    = (FF_SYNC_DEPTH == 3) ?  8 : 6;
  localparam FIFO_DATA_WIDTH = ATB_DATA_WIDTH + 2;

  input  wire                                    traceclk_in;
  input  wire                                    treset_n;
  output wire                              [3:0] rd_ptr_gray;
  input  wire                              [3:0] wr_ptr_gray_sync;
  input  wire [BUFFER_DEPTH*FIFO_DATA_WIDTH-1:0] fifo_data;

  output reg               [FIFO_DATA_WIDTH-1:0] fifo_r_data;
  input  wire                                    pop_fifo;
  output  reg                                    fifo_empty;


  wire [FIFO_DATA_WIDTH-1:0]             nxt_fifo_r_data;

  wire                                       fifo_en;

  wire                                       rd_ptr_en;
  reg  [3:0]                             nxt_rd_ptr_gray;
  reg  [3:0]                                 rd_ptr_gray_cdc_chk;

  wire                                   nxt_fifo_empty;
  wire                                       fifo_empty_en;


  genvar a;
  generate
  for (a=0; a< FIFO_DATA_WIDTH; a=a+1) begin: fifo_data_mux

    if (BUFFER_DEPTH == 8) begin : fifo_data_mux_1_depth_8
      wire  [FIFO_DATA_WIDTH-1:0] fifo_data_1_0 ;
      wire  [FIFO_DATA_WIDTH-1:0] fifo_data_3_2 ;
      wire  [FIFO_DATA_WIDTH-1:0] fifo_data_5_4 ;
      wire  [FIFO_DATA_WIDTH-1:0] fifo_data_7_6 ;
      wire  [FIFO_DATA_WIDTH-1:0] fifo_data_3_2_1_0 ;
      wire  [FIFO_DATA_WIDTH-1:0] fifo_data_7_6_5_4 ;

      css600_mux2 u_css600_mux2_01       ( .din1_async (fifo_data[0*FIFO_DATA_WIDTH+a]), .din2_async (fifo_data[1*FIFO_DATA_WIDTH+a]), .sel(rd_ptr_gray_cdc_chk[0]), .dout_async (fifo_data_1_0[a]    ) );
      css600_mux2 u_css600_mux2_23       ( .din1_async (fifo_data[3*FIFO_DATA_WIDTH+a]), .din2_async (fifo_data[2*FIFO_DATA_WIDTH+a]), .sel(rd_ptr_gray_cdc_chk[0]), .dout_async (fifo_data_3_2[a]    ) );
      css600_mux2 u_css600_mux2_45       ( .din1_async (fifo_data[4*FIFO_DATA_WIDTH+a]), .din2_async (fifo_data[5*FIFO_DATA_WIDTH+a]), .sel(rd_ptr_gray_cdc_chk[0]), .dout_async (fifo_data_5_4[a]    ) );
      css600_mux2 u_css600_mux2_67       ( .din1_async (fifo_data[7*FIFO_DATA_WIDTH+a]), .din2_async (fifo_data[6*FIFO_DATA_WIDTH+a]), .sel(rd_ptr_gray_cdc_chk[0]), .dout_async (fifo_data_7_6[a]    ) );

      css600_mux2 u_css600_mux2_0123     ( .din1_async (fifo_data_1_0[a]              ), .din2_async (fifo_data_3_2[a]              ), .sel(rd_ptr_gray_cdc_chk[1]), .dout_async (fifo_data_3_2_1_0[a]) );

      css600_mux2 u_css600_mux2_4567     ( .din1_async (fifo_data_7_6[a]              ), .din2_async (fifo_data_5_4[a]              ), .sel(rd_ptr_gray_cdc_chk[1]), .dout_async (fifo_data_7_6_5_4[a]) );

      css600_mux2 u_css600_mux2_01234567 ( .din1_async (fifo_data_7_6_5_4[a]          ), .din2_async (fifo_data_3_2_1_0[a]          ), .sel(rd_ptr_gray_cdc_chk[3]
                                                                                                                                        == rd_ptr_gray_cdc_chk[2]), .dout_async (nxt_fifo_r_data[a]  ) );

    end

    if (BUFFER_DEPTH == 6) begin: fifo_data_mux_1_depth_6

      reg [2:0] rd_ptr_corrected;
      wire  [FIFO_DATA_WIDTH-1:0] fifo_data_1_0 ;
      wire  [FIFO_DATA_WIDTH-1:0] fifo_data_3_2 ;
      wire  [FIFO_DATA_WIDTH-1:0] fifo_data_5_4 ;
      wire  [FIFO_DATA_WIDTH-1:0] fifo_data_3_2_1_0 ;
      wire  [FIFO_DATA_WIDTH-1:0] fifo_data_7_6_5_4 ;

      always @ *
      begin : c_wrptr_encode
        case (rd_ptr_gray_cdc_chk)
          4'b0000 : rd_ptr_corrected = 3'b000;
          4'b0001 : rd_ptr_corrected = 3'b001;
          4'b0011 : rd_ptr_corrected = 3'b011;
          4'b0010 : rd_ptr_corrected = 3'b010;
          4'b0110 : rd_ptr_corrected = 3'b110;
          4'b0111 : rd_ptr_corrected = 3'b111;

          4'b1111 : rd_ptr_corrected = 3'b000;
          4'b1110 : rd_ptr_corrected = 3'b001;
          4'b1010 : rd_ptr_corrected = 3'b011;
          4'b1011 : rd_ptr_corrected = 3'b010;
          4'b1001 : rd_ptr_corrected = 3'b110;
          4'b1000 : rd_ptr_corrected = 3'b111;
          4'b0100 : rd_ptr_corrected = 3'b100;
          4'b0101 : rd_ptr_corrected = 3'b101;
          4'b1100 : rd_ptr_corrected = 3'b101;
          4'b1101 : rd_ptr_corrected = 3'b100;
          default : rd_ptr_corrected = 3'bxxx;
        endcase
      end

      css600_mux2 u_css600_mux2_01       ( .din1_async (fifo_data[0*FIFO_DATA_WIDTH+a]), .din2_async (fifo_data[1*FIFO_DATA_WIDTH+a]), .sel(rd_ptr_corrected[0]), .dout_async (fifo_data_1_0[a]    ) );
      css600_mux2 u_css600_mux2_23       ( .din1_async (fifo_data[3*FIFO_DATA_WIDTH+a]), .din2_async (fifo_data[2*FIFO_DATA_WIDTH+a]), .sel(rd_ptr_corrected[0]), .dout_async (fifo_data_3_2[a]    ) );
      css600_mux2 u_css600_mux2_45       ( .din1_async (fifo_data[4*FIFO_DATA_WIDTH+a]), .din2_async (fifo_data[5*FIFO_DATA_WIDTH+a]), .sel(rd_ptr_corrected[0]), .dout_async (fifo_data_5_4[a]    ) );
      css600_mux2 u_css600_mux2_0123     ( .din1_async (fifo_data_1_0[a]              ), .din2_async (fifo_data_3_2[a]              ), .sel(rd_ptr_corrected[1]), .dout_async (fifo_data_3_2_1_0[a]) );

      css600_mux2 u_css600_mux2_4567     ( .din1_async (1'b0                          ), .din2_async (fifo_data_5_4[a]              ), .sel(rd_ptr_corrected[1]), .dout_async (fifo_data_7_6_5_4[a]) );

      css600_mux2 u_css600_mux2_01234567 ( .din1_async (fifo_data_3_2_1_0[a]          ), .din2_async (fifo_data_7_6_5_4[a]          ), .sel(rd_ptr_corrected[2]), .dout_async (nxt_fifo_r_data[a]  ) );


    end
  end
  endgenerate


  generate if (FF_SYNC_DEPTH == 3) begin : c_wrptr_encode_sync_depth3
    always @ *
    begin : c_rdptr_decode
      case (rd_ptr_gray_cdc_chk)
        4'b0000 : nxt_rd_ptr_gray = 4'b0001;
        4'b0001 : nxt_rd_ptr_gray = 4'b0011;
        4'b0011 : nxt_rd_ptr_gray = 4'b0010;
        4'b0010 : nxt_rd_ptr_gray = 4'b0110;
        4'b0110 : nxt_rd_ptr_gray = 4'b0111;
        4'b0111 : nxt_rd_ptr_gray = 4'b0101;
        4'b0101 : nxt_rd_ptr_gray = 4'b0100;
        4'b0100 : nxt_rd_ptr_gray = 4'b1100;

        4'b1100 : nxt_rd_ptr_gray = 4'b1101;
        4'b1101 : nxt_rd_ptr_gray = 4'b1111;
        4'b1111 : nxt_rd_ptr_gray = 4'b1110;
        4'b1110 : nxt_rd_ptr_gray = 4'b1010;
        4'b1010 : nxt_rd_ptr_gray = 4'b1011;
        4'b1011 : nxt_rd_ptr_gray = 4'b1001;
        4'b1001 : nxt_rd_ptr_gray = 4'b1000;
        4'b1000 : nxt_rd_ptr_gray = 4'b0000;

        default : nxt_rd_ptr_gray = 4'bxxxx;
      endcase
    end
  end
  endgenerate

  generate if (FF_SYNC_DEPTH == 2) begin : c_wrptr_encode_sync_depth2

    always @ *
    begin : c_rdptr_decode
      case (rd_ptr_gray_cdc_chk)
        4'b0000 : nxt_rd_ptr_gray = 4'b0001;
        4'b0001 : nxt_rd_ptr_gray = 4'b0011;
        4'b0011 : nxt_rd_ptr_gray = 4'b0010;
        4'b0010 : nxt_rd_ptr_gray = 4'b0110;
        4'b0110 : nxt_rd_ptr_gray = 4'b0111;
        4'b0111 : nxt_rd_ptr_gray = 4'b1111;

        4'b1111 : nxt_rd_ptr_gray = 4'b1110;
        4'b1110 : nxt_rd_ptr_gray = 4'b1010;
        4'b1010 : nxt_rd_ptr_gray = 4'b1011;
        4'b1011 : nxt_rd_ptr_gray = 4'b1001;
        4'b1001 : nxt_rd_ptr_gray = 4'b1000;
        4'b1000 : nxt_rd_ptr_gray = 4'b0000;
        4'b0100,
        4'b0101,
        4'b1100,
        4'b1101 : nxt_rd_ptr_gray = 4'bxxxx;
        default : nxt_rd_ptr_gray = 4'bxxxx;
      endcase
    end
  end
  endgenerate

  assign rd_ptr_en = (pop_fifo | fifo_empty) & ~nxt_fifo_empty;

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_rdptrgray
    if (!treset_n)
      rd_ptr_gray_cdc_chk <= 4'b0;
    else if (rd_ptr_en)
      rd_ptr_gray_cdc_chk <= nxt_rd_ptr_gray;
  end


  assign fifo_en = (pop_fifo | fifo_empty) & ~nxt_fifo_empty;

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_fifordata
    if (!treset_n)
      fifo_r_data <= {4'b1101
                     ,{30{1'b0}}
                     };
    else if (fifo_en)
      fifo_r_data <= nxt_fifo_r_data;
  end

  assign fifo_empty_en = pop_fifo | fifo_empty;

  assign nxt_fifo_empty = (wr_ptr_gray_sync == rd_ptr_gray_cdc_chk);

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_fifoempty
    if (!treset_n)
      fifo_empty <= 1'b1;
    else if (fifo_empty_en)
      fifo_empty <= nxt_fifo_empty;
  end


    assign rd_ptr_gray = rd_ptr_gray_cdc_chk;

endmodule


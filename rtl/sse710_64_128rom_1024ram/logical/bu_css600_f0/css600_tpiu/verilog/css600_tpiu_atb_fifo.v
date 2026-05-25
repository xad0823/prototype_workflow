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


module css600_tpiu_atb_fifo
#(
  parameter ATB_DATA_WIDTH = 32,
  parameter FF_SYNC_DEPTH = 2
)
(
      clk,
      reset_n,
      dev_run,
      ffcr_en_formatting_masked,
      ffcr_en_fcont,
      ft_stopped,
      ft_starting,
      ft_data,
      ft_data_beacon,
      ft_data_padded,
      ft_data_valid,
      wb_ready,
      nxt_wb_ready,
      stop_state,
      st_on_trig_active,
      st_on_fl_active,
      st_trig_pend,
      ft_trig_pend,
      st_fl_pend,
      nxt_wb_flush_req,
      wb_flush_ack,
      rd_ptr_gray_sync,
      wr_ptr_gray,
      fifo_data
);

  localparam ST_STOPPED       = 2'b00;
  localparam ST_START_MSG     = 2'b01;
  localparam ST_RUNNING       = 2'b10;
  localparam ST_UNUSED        = 2'b11;


  input  wire                          clk;
  input  wire                          reset_n;
  input  wire                          dev_run;

  input  wire                          ffcr_en_formatting_masked;
  input  wire                          ffcr_en_fcont;
  input  wire                          ft_stopped;
  input  wire                          ft_starting;
  input  wire [ATB_DATA_WIDTH-1:0]     ft_data;
  input  wire                          ft_data_beacon;
  input  wire                          ft_data_padded;
  input  wire                          ft_data_valid;
  output wire                          wb_ready;
  output wire                      nxt_wb_ready;
  output reg  [1:0]                    stop_state;

  input  wire                          st_on_trig_active;
  input  wire                          st_on_fl_active;
  input  wire                          st_trig_pend;
  input  wire                          ft_trig_pend;
  input  wire                          st_fl_pend;
  input  wire                      nxt_wb_flush_req;
  input  wire                          wb_flush_ack;

  input  wire [3:0]                    rd_ptr_gray_sync;
  output wire [3:0]                    wr_ptr_gray;
  output wire [2*(FF_SYNC_DEPTH+1)
              *(ATB_DATA_WIDTH+2)-1:0] fifo_data;


  reg  [3:0]                       nxt_wr_ptr_gray;
  reg  [3:0]                           wr_ptr_gray_cdc_chk;

  wire                                 data_buf_full;
  wire                                 data_buf_nearfull;

  wire                                 st_on_fl_req;
  wire                                 st_on_trig_req;
  wire                                 ft_data_flush_req;

  wire                             nxt_wb_flush_requested;
  reg                                  wb_flush_requested;
  wire                                 wb_flush_req_missing;

  wire                                 fifo_data_wr;
  wire [2*(FF_SYNC_DEPTH+1)-1:0]       fifo_data_en;

  wire [(ATB_DATA_WIDTH+2)-1:0]        fifodata;
  reg  [(ATB_DATA_WIDTH+2)-1:0]        fifodata_cdc_chk [2*(FF_SYNC_DEPTH+1)-1:0];

  wire                                 start_msg_wr;
  wire                                 stop_msg_sent;

  reg [1:0]                            nxt_stop_state;

  wire                                 stop_fl_marker;
  wire                                 stop_trig_marker;


  always @ *
  begin : c_stop_state
    case (stop_state)
      ST_RUNNING:
        if (stop_msg_sent)
          nxt_stop_state   = ST_STOPPED;
        else
          nxt_stop_state   = ST_RUNNING;

      ST_STOPPED:
        if (ft_starting)
          if (data_buf_full)
            nxt_stop_state = ST_START_MSG;
          else
            nxt_stop_state = ST_RUNNING;
        else
          nxt_stop_state   = ST_STOPPED;

      ST_START_MSG:
        if (data_buf_full)
          nxt_stop_state   = ST_START_MSG;
        else
          nxt_stop_state   = ST_RUNNING;

      ST_UNUSED:
        nxt_stop_state     = ST_RUNNING;

      default:
          nxt_stop_state   = 2'bxx;

    endcase
  end

  assign start_msg_wr = (stop_state==ST_STOPPED  ) ? ~data_buf_full & ft_starting
                      : (stop_state==ST_START_MSG) ? ~data_buf_full
                      :                              1'b0
                      ;

  always @ (posedge clk or negedge reset_n)
  begin : s_patt_state
    if (!reset_n)
      stop_state <= ST_STOPPED;
    else
      stop_state <= nxt_stop_state;
  end


  assign st_on_trig_req    = ft_data_padded &  st_on_trig_active;
  assign st_on_fl_req      = (ft_data_padded & st_fl_pend & ~st_trig_pend                )
                           | (ft_data_padded & st_fl_pend &  st_trig_pend & ~ft_trig_pend)
                           | (ft_data_padded & st_on_fl_active                           )
                           ;
  assign stop_msg_sent     = fifo_data_wr & (stop_fl_marker | stop_trig_marker | ft_stopped);
  assign stop_trig_marker  = fifodata[33:32] == 2'b10;
  assign stop_fl_marker    = fifodata[33:31] == 3'b011 & st_on_fl_req;
  assign ft_data_flush_req = ft_data_padded & ~st_on_trig_active;
  assign nxt_wb_flush_requested = (wb_flush_requested) ? ~wb_flush_ack
                                :                        ft_data_flush_req
                                                       | wb_flush_req_missing
                                ;
  assign wb_flush_req_missing   = ~wb_flush_requested & nxt_wb_flush_req & ~data_buf_full;

  always @ (posedge clk or negedge reset_n)
  begin : s_wb_flush_requested
    if (!reset_n)
      wb_flush_requested <= 1'b0;
    else
      wb_flush_requested <= nxt_wb_flush_requested;
  end


  assign fifo_data_wr = ft_data_valid & wb_ready
                      | wb_flush_req_missing & (stop_state == ST_RUNNING)
                      | start_msg_wr
                      ;
  assign fifodata     = (start_msg_wr        ) ? {2'b11,ffcr_en_formatting_masked
                                                            ,
                                                        ffcr_en_fcont,{30{1'bx}}}
                      : (wb_flush_req_missing) ? {2'b11,1'b0,    1'b1,{30{1'bx}}}
                      : (st_on_trig_req      ) ? {2'b10,           ft_data[31:0]}
                      : (ft_data_beacon      ) ? {2'b01,           ft_data[31:0]}
                      : (!ft_data_flush_req  ) ? {2'b00,           ft_data[31:0]}
                      : (st_on_fl_req        ) ? {2'b01,1'b1,      ft_data[30:0]}
                      :                          {2'b01,1'b0,      ft_data[30:0]}
                      ;


  generate if (FF_SYNC_DEPTH == 3) begin : c_wrptr_encode_sync_depth3

    assign fifo_data_en[0] = (fifo_data_wr & ((wr_ptr_gray_cdc_chk == 4'b0000) | (wr_ptr_gray_cdc_chk == 4'b1100)) );
    assign fifo_data_en[1] = (fifo_data_wr & ((wr_ptr_gray_cdc_chk == 4'b0001) | (wr_ptr_gray_cdc_chk == 4'b1101)) );
    assign fifo_data_en[2] = (fifo_data_wr & ((wr_ptr_gray_cdc_chk == 4'b0011) | (wr_ptr_gray_cdc_chk == 4'b1111)) );
    assign fifo_data_en[3] = (fifo_data_wr & ((wr_ptr_gray_cdc_chk == 4'b0010) | (wr_ptr_gray_cdc_chk == 4'b1110)) );
    assign fifo_data_en[4] = (fifo_data_wr & ((wr_ptr_gray_cdc_chk == 4'b0110) | (wr_ptr_gray_cdc_chk == 4'b1010)) );
    assign fifo_data_en[5] = (fifo_data_wr & ((wr_ptr_gray_cdc_chk == 4'b0111) | (wr_ptr_gray_cdc_chk == 4'b1011)) );
    assign fifo_data_en[6] = (fifo_data_wr & ((wr_ptr_gray_cdc_chk == 4'b0101) | (wr_ptr_gray_cdc_chk == 4'b1001)) );
    assign fifo_data_en[7] = (fifo_data_wr & ((wr_ptr_gray_cdc_chk == 4'b0100) | (wr_ptr_gray_cdc_chk == 4'b1000)) );

    always @ (posedge clk)
    begin : s_fifodata
      if (fifo_data_en[0]) fifodata_cdc_chk[0] <= fifodata;
      if (fifo_data_en[1]) fifodata_cdc_chk[1] <= fifodata;
      if (fifo_data_en[2]) fifodata_cdc_chk[2] <= fifodata;
      if (fifo_data_en[3]) fifodata_cdc_chk[3] <= fifodata;
      if (fifo_data_en[4]) fifodata_cdc_chk[4] <= fifodata;
      if (fifo_data_en[5]) fifodata_cdc_chk[5] <= fifodata;
      if (fifo_data_en[6]) fifodata_cdc_chk[6] <= fifodata;
      if (fifo_data_en[7]) fifodata_cdc_chk[7] <= fifodata;
    end

  end
  endgenerate

  generate if (FF_SYNC_DEPTH == 2) begin : c_wrptr_encode_sync_depth2

    assign fifo_data_en[0] = (fifo_data_wr & ((wr_ptr_gray_cdc_chk == 4'b0000) | (wr_ptr_gray_cdc_chk == 4'b1111)) );
    assign fifo_data_en[1] = (fifo_data_wr & ((wr_ptr_gray_cdc_chk == 4'b0001) | (wr_ptr_gray_cdc_chk == 4'b1110)) );
    assign fifo_data_en[2] = (fifo_data_wr & ((wr_ptr_gray_cdc_chk == 4'b0011) | (wr_ptr_gray_cdc_chk == 4'b1010)) );
    assign fifo_data_en[3] = (fifo_data_wr & ((wr_ptr_gray_cdc_chk == 4'b0010) | (wr_ptr_gray_cdc_chk == 4'b1011)) );
    assign fifo_data_en[4] = (fifo_data_wr & ((wr_ptr_gray_cdc_chk == 4'b0110) | (wr_ptr_gray_cdc_chk == 4'b1001)) );
    assign fifo_data_en[5] = (fifo_data_wr & ((wr_ptr_gray_cdc_chk == 4'b0111) | (wr_ptr_gray_cdc_chk == 4'b1000)) );

    always @ (posedge clk)
    begin : s_fifodata
      if (fifo_data_en[0]) fifodata_cdc_chk[0] <= fifodata;
      if (fifo_data_en[1]) fifodata_cdc_chk[1] <= fifodata;
      if (fifo_data_en[2]) fifodata_cdc_chk[2] <= fifodata;
      if (fifo_data_en[3]) fifodata_cdc_chk[3] <= fifodata;
      if (fifo_data_en[4]) fifodata_cdc_chk[4] <= fifodata;
      if (fifo_data_en[5]) fifodata_cdc_chk[5] <= fifodata;
    end

  end
  endgenerate


  generate if (FF_SYNC_DEPTH == 3) begin : c_wr_ptr_gray_depth3
    always @ *
    begin : c_wrptr_encode
      case (wr_ptr_gray_cdc_chk)
        4'b0000 : nxt_wr_ptr_gray = 4'b0001;
        4'b0001 : nxt_wr_ptr_gray = 4'b0011;
        4'b0011 : nxt_wr_ptr_gray = 4'b0010;
        4'b0010 : nxt_wr_ptr_gray = 4'b0110;
        4'b0110 : nxt_wr_ptr_gray = 4'b0111;
        4'b0111 : nxt_wr_ptr_gray = 4'b0101;
        4'b0101 : nxt_wr_ptr_gray = 4'b0100;
        4'b0100 : nxt_wr_ptr_gray = 4'b1100;

        4'b1100 : nxt_wr_ptr_gray = 4'b1101;
        4'b1101 : nxt_wr_ptr_gray = 4'b1111;
        4'b1111 : nxt_wr_ptr_gray = 4'b1110;
        4'b1110 : nxt_wr_ptr_gray = 4'b1010;
        4'b1010 : nxt_wr_ptr_gray = 4'b1011;
        4'b1011 : nxt_wr_ptr_gray = 4'b1001;
        4'b1001 : nxt_wr_ptr_gray = 4'b1000;
        4'b1000 : nxt_wr_ptr_gray = 4'b0000;

        default : nxt_wr_ptr_gray = 4'bxxxx;
      endcase
    end
  end
  endgenerate


  generate if (FF_SYNC_DEPTH == 2) begin : c_wr_ptr_gray_depth2
    always @ *
    begin : c_wrptr_encode
      case (wr_ptr_gray_cdc_chk)
        4'b0000 : nxt_wr_ptr_gray = 4'b0001;
        4'b0001 : nxt_wr_ptr_gray = 4'b0011;
        4'b0011 : nxt_wr_ptr_gray = 4'b0010;
        4'b0010 : nxt_wr_ptr_gray = 4'b0110;
        4'b0110 : nxt_wr_ptr_gray = 4'b0111;
        4'b0111 : nxt_wr_ptr_gray = 4'b1111;

        4'b1111 : nxt_wr_ptr_gray = 4'b1110;
        4'b1110 : nxt_wr_ptr_gray = 4'b1010;
        4'b1010 : nxt_wr_ptr_gray = 4'b1011;
        4'b1011 : nxt_wr_ptr_gray = 4'b1001;
        4'b1001 : nxt_wr_ptr_gray = 4'b1000;
        4'b1000 : nxt_wr_ptr_gray = 4'b0000;
        4'b0100,
        4'b0101,
        4'b1100,
        4'b1101 : nxt_wr_ptr_gray = 4'bxxxx;
        default : nxt_wr_ptr_gray = 4'bxxxx;
      endcase
    end
  end
  endgenerate

  always @ (posedge clk or negedge reset_n)
  begin : s_wrptrgray
    if (!reset_n)
      wr_ptr_gray_cdc_chk <= 4'b0;
    else if (fifo_data_wr)
      wr_ptr_gray_cdc_chk <= nxt_wr_ptr_gray;
  end


  generate if (FF_SYNC_DEPTH == 3) begin : c_wb_ready_depth3
    assign data_buf_full     = 1'b0
                             |   ((wr_ptr_gray_cdc_chk == 4'b0000) & (rd_ptr_gray_sync == 4'b1100))
                             |   ((wr_ptr_gray_cdc_chk == 4'b0001) & (rd_ptr_gray_sync == 4'b1101))
                             |   ((wr_ptr_gray_cdc_chk == 4'b0011) & (rd_ptr_gray_sync == 4'b1111))
                             |   ((wr_ptr_gray_cdc_chk == 4'b0010) & (rd_ptr_gray_sync == 4'b1110))
                             |   ((wr_ptr_gray_cdc_chk == 4'b0110) & (rd_ptr_gray_sync == 4'b1010))
                             |   ((wr_ptr_gray_cdc_chk == 4'b0111) & (rd_ptr_gray_sync == 4'b1011))
                             |   ((wr_ptr_gray_cdc_chk == 4'b0101) & (rd_ptr_gray_sync == 4'b1001))
                             |   ((wr_ptr_gray_cdc_chk == 4'b0100) & (rd_ptr_gray_sync == 4'b1000))
                             |   ((wr_ptr_gray_cdc_chk == 4'b1100) & (rd_ptr_gray_sync == 4'b0000))
                             |   ((wr_ptr_gray_cdc_chk == 4'b1101) & (rd_ptr_gray_sync == 4'b0001))
                             |   ((wr_ptr_gray_cdc_chk == 4'b1111) & (rd_ptr_gray_sync == 4'b0011))
                             |   ((wr_ptr_gray_cdc_chk == 4'b1110) & (rd_ptr_gray_sync == 4'b0010))
                             |   ((wr_ptr_gray_cdc_chk == 4'b1010) & (rd_ptr_gray_sync == 4'b0110))
                             |   ((wr_ptr_gray_cdc_chk == 4'b1011) & (rd_ptr_gray_sync == 4'b0111))
                             |   ((wr_ptr_gray_cdc_chk == 4'b1001) & (rd_ptr_gray_sync == 4'b0101))
                             |   ((wr_ptr_gray_cdc_chk == 4'b1000) & (rd_ptr_gray_sync == 4'b0100))
                             ;
    assign data_buf_nearfull = data_buf_full
                             |   ((wr_ptr_gray_cdc_chk == 4'b0000) & (rd_ptr_gray_sync == 4'b1101))
                             |   ((wr_ptr_gray_cdc_chk == 4'b0001) & (rd_ptr_gray_sync == 4'b1111))
                             |   ((wr_ptr_gray_cdc_chk == 4'b0011) & (rd_ptr_gray_sync == 4'b1110))
                             |   ((wr_ptr_gray_cdc_chk == 4'b0010) & (rd_ptr_gray_sync == 4'b1010))
                             |   ((wr_ptr_gray_cdc_chk == 4'b0110) & (rd_ptr_gray_sync == 4'b1011))
                             |   ((wr_ptr_gray_cdc_chk == 4'b0111) & (rd_ptr_gray_sync == 4'b1001))
                             |   ((wr_ptr_gray_cdc_chk == 4'b0101) & (rd_ptr_gray_sync == 4'b1000))
                             |   ((wr_ptr_gray_cdc_chk == 4'b0100) & (rd_ptr_gray_sync == 4'b0000))
                             |   ((wr_ptr_gray_cdc_chk == 4'b1100) & (rd_ptr_gray_sync == 4'b0001))
                             |   ((wr_ptr_gray_cdc_chk == 4'b1101) & (rd_ptr_gray_sync == 4'b0011))
                             |   ((wr_ptr_gray_cdc_chk == 4'b1111) & (rd_ptr_gray_sync == 4'b0010))
                             |   ((wr_ptr_gray_cdc_chk == 4'b1110) & (rd_ptr_gray_sync == 4'b0110))
                             |   ((wr_ptr_gray_cdc_chk == 4'b1010) & (rd_ptr_gray_sync == 4'b0111))
                             |   ((wr_ptr_gray_cdc_chk == 4'b1011) & (rd_ptr_gray_sync == 4'b0101))
                             |   ((wr_ptr_gray_cdc_chk == 4'b1001) & (rd_ptr_gray_sync == 4'b0100))
                             |   ((wr_ptr_gray_cdc_chk == 4'b1000) & (rd_ptr_gray_sync == 4'b1100))
                             ;

    assign wb_ready          = dev_run & ~data_buf_full     & ~wb_flush_req_missing & (stop_state == ST_RUNNING);
    assign nxt_wb_ready      = dev_run & ~data_buf_nearfull & ~wb_flush_req_missing & (stop_state == ST_RUNNING);

      assign wr_ptr_gray  = wr_ptr_gray_cdc_chk;
      assign fifo_data[ ATB_DATA_WIDTH+2-1 + 0*(ATB_DATA_WIDTH+2) : 0*(ATB_DATA_WIDTH+2) ] = fifodata_cdc_chk[0];
      assign fifo_data[ ATB_DATA_WIDTH+2-1 + 1*(ATB_DATA_WIDTH+2) : 1*(ATB_DATA_WIDTH+2) ] = fifodata_cdc_chk[1];
      assign fifo_data[ ATB_DATA_WIDTH+2-1 + 2*(ATB_DATA_WIDTH+2) : 2*(ATB_DATA_WIDTH+2) ] = fifodata_cdc_chk[2];
      assign fifo_data[ ATB_DATA_WIDTH+2-1 + 3*(ATB_DATA_WIDTH+2) : 3*(ATB_DATA_WIDTH+2) ] = fifodata_cdc_chk[3];
      assign fifo_data[ ATB_DATA_WIDTH+2-1 + 4*(ATB_DATA_WIDTH+2) : 4*(ATB_DATA_WIDTH+2) ] = fifodata_cdc_chk[4];
      assign fifo_data[ ATB_DATA_WIDTH+2-1 + 5*(ATB_DATA_WIDTH+2) : 5*(ATB_DATA_WIDTH+2) ] = fifodata_cdc_chk[5];
      assign fifo_data[ ATB_DATA_WIDTH+2-1 + 6*(ATB_DATA_WIDTH+2) : 6*(ATB_DATA_WIDTH+2) ] = fifodata_cdc_chk[6];
      assign fifo_data[ ATB_DATA_WIDTH+2-1 + 7*(ATB_DATA_WIDTH+2) : 7*(ATB_DATA_WIDTH+2) ] = fifodata_cdc_chk[7];

  end
  endgenerate


  generate if (FF_SYNC_DEPTH == 2) begin : c_wb_ready_depth2
    assign data_buf_full     = 1'b0
                             |((wr_ptr_gray_cdc_chk == 4'b0000) & (rd_ptr_gray_sync == 4'b1111))
                             |((wr_ptr_gray_cdc_chk == 4'b0001) & (rd_ptr_gray_sync == 4'b1110))
                             |((wr_ptr_gray_cdc_chk == 4'b0011) & (rd_ptr_gray_sync == 4'b1010))
                             |((wr_ptr_gray_cdc_chk == 4'b0010) & (rd_ptr_gray_sync == 4'b1011))
                             |((wr_ptr_gray_cdc_chk == 4'b0110) & (rd_ptr_gray_sync == 4'b1001))
                             |((wr_ptr_gray_cdc_chk == 4'b0111) & (rd_ptr_gray_sync == 4'b1000))
                             |((wr_ptr_gray_cdc_chk == 4'b1111) & (rd_ptr_gray_sync == 4'b0000))
                             |((wr_ptr_gray_cdc_chk == 4'b1110) & (rd_ptr_gray_sync == 4'b0001))
                             |((wr_ptr_gray_cdc_chk == 4'b1010) & (rd_ptr_gray_sync == 4'b0011))
                             |((wr_ptr_gray_cdc_chk == 4'b1011) & (rd_ptr_gray_sync == 4'b0010))
                             |((wr_ptr_gray_cdc_chk == 4'b1001) & (rd_ptr_gray_sync == 4'b0110))
                             |((wr_ptr_gray_cdc_chk == 4'b1000) & (rd_ptr_gray_sync == 4'b0111))
                             ;
    assign data_buf_nearfull = data_buf_full
                             |((wr_ptr_gray_cdc_chk == 4'b0000) & (rd_ptr_gray_sync == 4'b1110))
                             |((wr_ptr_gray_cdc_chk == 4'b0001) & (rd_ptr_gray_sync == 4'b1010))
                             |((wr_ptr_gray_cdc_chk == 4'b0011) & (rd_ptr_gray_sync == 4'b1011))
                             |((wr_ptr_gray_cdc_chk == 4'b0010) & (rd_ptr_gray_sync == 4'b1001))
                             |((wr_ptr_gray_cdc_chk == 4'b0110) & (rd_ptr_gray_sync == 4'b1000))
                             |((wr_ptr_gray_cdc_chk == 4'b0111) & (rd_ptr_gray_sync == 4'b0000))
                             |((wr_ptr_gray_cdc_chk == 4'b1111) & (rd_ptr_gray_sync == 4'b0001))
                             |((wr_ptr_gray_cdc_chk == 4'b1110) & (rd_ptr_gray_sync == 4'b0011))
                             |((wr_ptr_gray_cdc_chk == 4'b1010) & (rd_ptr_gray_sync == 4'b0010))
                             |((wr_ptr_gray_cdc_chk == 4'b1011) & (rd_ptr_gray_sync == 4'b0110))
                             |((wr_ptr_gray_cdc_chk == 4'b1001) & (rd_ptr_gray_sync == 4'b0111))
                             |((wr_ptr_gray_cdc_chk == 4'b1000) & (rd_ptr_gray_sync == 4'b1111))
                             ;

    assign wb_ready          = dev_run & ~data_buf_full     & ~wb_flush_req_missing & (stop_state == ST_RUNNING);
    assign nxt_wb_ready      = dev_run & ~data_buf_nearfull & ~wb_flush_req_missing & (stop_state == ST_RUNNING);

      assign wr_ptr_gray  = wr_ptr_gray_cdc_chk;
      assign fifo_data[ ATB_DATA_WIDTH+2-1 + 0*(ATB_DATA_WIDTH+2) : 0*(ATB_DATA_WIDTH+2) ] = fifodata_cdc_chk[0];
      assign fifo_data[ ATB_DATA_WIDTH+2-1 + 1*(ATB_DATA_WIDTH+2) : 1*(ATB_DATA_WIDTH+2) ] = fifodata_cdc_chk[1];
      assign fifo_data[ ATB_DATA_WIDTH+2-1 + 2*(ATB_DATA_WIDTH+2) : 2*(ATB_DATA_WIDTH+2) ] = fifodata_cdc_chk[2];
      assign fifo_data[ ATB_DATA_WIDTH+2-1 + 3*(ATB_DATA_WIDTH+2) : 3*(ATB_DATA_WIDTH+2) ] = fifodata_cdc_chk[3];
      assign fifo_data[ ATB_DATA_WIDTH+2-1 + 4*(ATB_DATA_WIDTH+2) : 4*(ATB_DATA_WIDTH+2) ] = fifodata_cdc_chk[4];
      assign fifo_data[ ATB_DATA_WIDTH+2-1 + 5*(ATB_DATA_WIDTH+2) : 5*(ATB_DATA_WIDTH+2) ] = fifodata_cdc_chk[5];
  end
  endgenerate


endmodule


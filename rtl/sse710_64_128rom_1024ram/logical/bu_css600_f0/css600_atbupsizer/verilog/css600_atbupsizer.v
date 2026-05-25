//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2010-2012, 2016-2017 Arm Limited or its affiliates.
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
//   Top level of css600_atbupsizer
//
//----------------------------------------------------------------------------


module css600_atbupsizer #(parameter
  ATB_SLAVE_DATA_WIDTH  = 32,
  ATB_MASTER_DATA_WIDTH = 64)
(
    clk,
    reset_n,
    atwakeup_m,
    atvalid_m,
    atready_m,
    afvalid_m,
    afready_m,
    syncreq_m,
    atid_m,
    atdata_m,
    atbytes_m,
    atwakeup_s,
    atvalid_s,
    atready_s,
    afvalid_s,
    afready_s,
    syncreq_s,
    atid_s,
    atdata_s,
    atbytes_s,
    clk_qactive
);

function integer atb_clog2 (input integer num);
  integer i;
  begin
    atb_clog2 = 0;
    for(i=num; i>1; i=i>>1)
      atb_clog2 = atb_clog2 + 1;
  end
endfunction


  localparam ATB_SLAVE_DATA_WIDTH_LOC =  (
                                          (ATB_SLAVE_DATA_WIDTH ==  8)  ||
                                          (ATB_SLAVE_DATA_WIDTH == 16)  ||
                                          (ATB_SLAVE_DATA_WIDTH == 32)  ||
                                          (ATB_SLAVE_DATA_WIDTH == 64)
                                         ) ? ATB_SLAVE_DATA_WIDTH : 32;

  localparam ATB_MASTER_DATA_WIDTH_LOC = (
                                          (ATB_MASTER_DATA_WIDTH == 16)  ||
                                          (ATB_MASTER_DATA_WIDTH == 32)  ||
                                          (ATB_MASTER_DATA_WIDTH == 64)  ||
                                          (ATB_MASTER_DATA_WIDTH == 128)
                                         ) ? ATB_MASTER_DATA_WIDTH : 64;

  localparam ATBYTESS_WIDTH = (ATB_SLAVE_DATA_WIDTH_LOC < 32) ? 1 : atb_clog2(ATB_SLAVE_DATA_WIDTH_LOC)-3;


  localparam ATBYTESS_MAX = ATB_SLAVE_DATA_WIDTH_LOC/8-1;

  localparam ATBYTESM_WIDTH = (ATB_MASTER_DATA_WIDTH_LOC < 32) ? 1 : atb_clog2(ATB_MASTER_DATA_WIDTH_LOC)-3;

  localparam ATB_SLAVE_GT_8 = (ATB_SLAVE_DATA_WIDTH_LOC > 8) ? 1 : 0;

  localparam MASTER_SLAVE_PROP = ATB_MASTER_DATA_WIDTH_LOC/ATB_SLAVE_DATA_WIDTH_LOC;

  localparam ST_UPSIZER_IDLE = 2'h0;
  localparam ST_UPSIZER_FLUSH_WIDE_BUF = 2'h1;
  localparam ST_UPSIZER = 2'h2;

  localparam ST_UPSIZER_FLUSH_IDLE = 2'b00;
  localparam ST_UPSIZER_FLUSH_SLAVE = 2'b01;
  localparam ST_UPSIZER_FLUSH_ONE_TIME = 2'b10;
  localparam ST_UPSIZER_FLUSH_TWO_TIMES = 2'b11;


  input  wire                                   clk;
  input  wire                                   reset_n;

  output reg                                    atwakeup_m;

  output wire                                   atvalid_m;
  input  wire                                   atready_m;

  input  wire                                   afvalid_m;
  output wire                                   afready_m;

  input  wire                                   syncreq_m;

  output wire [6:0]                             atid_m;
  output wire [ATB_MASTER_DATA_WIDTH_LOC - 1:0] atdata_m;
  output wire [ATBYTESM_WIDTH-1:0]              atbytes_m;

  input  wire                                   atwakeup_s;

  input  wire                                   atvalid_s;
  output wire                                   atready_s;

  output wire                                   afvalid_s;
  input  wire                                   afready_s;

  output reg                                    syncreq_s;

  input  wire [6:0]                             atid_s;
  input  wire [ATB_SLAVE_DATA_WIDTH_LOC - 1:0]  atdata_s;
  input  wire [ATBYTESS_WIDTH-1:0]              atbytes_s;

  output wire                                   clk_qactive;


  wire      slave_atb_hand_shake;
  wire      master_atb_hand_shake;
  wire      write_narrow;
  wire      nxt_atready_s;
  reg       atready_s_int;
  wire      stop_merge;
  wire      stop_merge_cond;
  wire      nxt_stop_merge_cond_reg;
  wire      nxt_flush_narrow;
  wire      nxt_narrow_buf_data_valid;
  wire      stop_merge_atbytes_s_less;
  wire      stop_merge_atid_s;
  wire      stop_merge_flush;
  wire      nxt_narrow_buf_has_data;
  wire      upsizer_sm_flush_wide_buf;
  wire      upsizer_sm_idle;
  wire      reset_stop_merge_cond_reg;
  wire      set_flush_narrow;
  reg [3:0] nxt_iter;

  reg  [ATB_MASTER_DATA_WIDTH_LOC-1 : 0]  nxt_wide_fifo;
  reg  [ATB_MASTER_DATA_WIDTH_LOC-1 : 0]  wide_fifo;
  reg  [ATBYTESS_WIDTH-1 : 0]         atbytes_narrow;
  reg  [6:0]                          atid_narrow;
  reg  [ATB_SLAVE_DATA_WIDTH_LOC-1 : 0]  atdata_s_narrow;
  reg  [1:0] nxt_upsizer_sm;
  reg  [1:0] upsizer_sm;

  reg                                   stop_merge_cond_reg;
  reg [ATBYTESM_WIDTH-1 : 0]            nxt_atbytes_m;
  reg [ATBYTESM_WIDTH-1 : 0]            atbytes_m_int;
  reg                                   nxt_atvalid_m;
  reg                                   atvalid_m_int;
  reg [6:0]                             nxt_atid_m;
  reg [6:0]                             atid_m_int;
  reg                                   nxt_afvalid_s;
  reg                                   afvalid_s_int;
  reg                                   nxt_afready_m;
  reg                                   afready_m_int;
  reg                                   flush_narrow;
  reg                                   narrow_buf_data_valid;
  reg                                   narrow_buf_data_driven;
  reg                                   narrow_buf_has_data;
  reg  [1:0]                            nxt_upsizer_flush_sm;
  reg  [1:0]                            upsizer_flush_sm;
  reg  [3:0]                            iter;


  assign atready_s = atready_s_int;
  assign afready_m = afready_m_int;
  assign atvalid_m = atvalid_m_int;
  assign atbytes_m = atbytes_m_int;
  assign atid_m    = atid_m_int;
  assign afvalid_s = afvalid_s_int;


  assign slave_atb_hand_shake = atvalid_s & atready_s_int;
  assign master_atb_hand_shake = atvalid_m_int & atready_m;

 always @ *
   begin : p_upsizer_flush_sm_comb
     nxt_upsizer_flush_sm = upsizer_flush_sm;
     nxt_afready_m = 1'b0;
     nxt_afvalid_s = afvalid_s_int;

     case (upsizer_flush_sm)
       ST_UPSIZER_FLUSH_IDLE :
         begin
           if (afvalid_m && !afready_m_int)
             begin
               nxt_afvalid_s = 1'b1;
                nxt_upsizer_flush_sm = ST_UPSIZER_FLUSH_SLAVE;
             end
         end

       ST_UPSIZER_FLUSH_SLAVE :
         begin
           if (afready_s)
             begin
               nxt_afvalid_s = 1'b0;
               if (upsizer_sm == ST_UPSIZER_IDLE)
                 begin
                   nxt_afready_m = 1'b1;
                   nxt_upsizer_flush_sm = ST_UPSIZER_FLUSH_IDLE;
                 end
               else begin
                case ({narrow_buf_has_data, master_atb_hand_shake})
                  2'b01 : begin
                            nxt_afready_m = 1'b1;
                            nxt_upsizer_flush_sm = ST_UPSIZER_FLUSH_IDLE;
                          end
                  2'b10 : nxt_upsizer_flush_sm = ST_UPSIZER_FLUSH_TWO_TIMES;
                  2'b11 : nxt_upsizer_flush_sm = ST_UPSIZER_FLUSH_ONE_TIME;
                  2'b00 : nxt_upsizer_flush_sm = ST_UPSIZER_FLUSH_ONE_TIME;
                  default: nxt_upsizer_flush_sm = {2{1'bx}};
                endcase
               end
             end
         end

       ST_UPSIZER_FLUSH_TWO_TIMES :
         begin
           if (master_atb_hand_shake)
             begin
               nxt_upsizer_flush_sm = ST_UPSIZER_FLUSH_ONE_TIME;
             end
         end

       ST_UPSIZER_FLUSH_ONE_TIME :
         begin
           if (master_atb_hand_shake)
             begin
               nxt_upsizer_flush_sm = ST_UPSIZER_FLUSH_IDLE;
               nxt_afready_m = 1'b1;
             end
         end
       default :
         begin
           nxt_upsizer_flush_sm = 2'bxx;
           nxt_afready_m = 1'bx;
           nxt_afvalid_s = 1'bx;
         end

     endcase
   end

  always @ *
    begin : p_upsizer_sm_comb
      nxt_upsizer_sm = upsizer_sm;
      nxt_atvalid_m   = atvalid_m_int;
      nxt_atbytes_m   = atbytes_m_int;
      nxt_atid_m      = atid_m_int;
      nxt_wide_fifo  = wide_fifo;
      nxt_iter       = iter;

      narrow_buf_data_driven = 1'b0;

      case (upsizer_sm)
        ST_UPSIZER_IDLE :
          begin
          if (stop_merge_atbytes_s_less)
              begin
                nxt_upsizer_sm = ST_UPSIZER_FLUSH_WIDE_BUF;
                nxt_atvalid_m = 1'b1;
                nxt_atbytes_m = {{(ATBYTESM_WIDTH-ATBYTESS_WIDTH){1'b0}}, atbytes_s};
                nxt_atid_m    = atid_s;
                nxt_wide_fifo[ATB_SLAVE_DATA_WIDTH_LOC - 1: 0] = atdata_s;
              end
            else if (atvalid_s)
              begin
                nxt_upsizer_sm = ST_UPSIZER;
                nxt_atbytes_m = {{(ATBYTESM_WIDTH-ATBYTESS_WIDTH){1'b0}}, atbytes_s};
                nxt_atid_m    = atid_s;
                nxt_iter     = 4'b1;
                nxt_wide_fifo[ATB_SLAVE_DATA_WIDTH_LOC - 1: 0] = atdata_s;
              end
          end

        ST_UPSIZER :
          begin
            if (stop_merge)
              begin
                nxt_upsizer_sm = ST_UPSIZER_FLUSH_WIDE_BUF;
                nxt_atvalid_m = 1'b1;
                nxt_iter = 4'b0;
                if (stop_merge_atbytes_s_less && !stop_merge_atid_s && !stop_merge_flush)
                  begin
                    nxt_atbytes_m = atbytes_m_int + {{(ATBYTESM_WIDTH-ATBYTESS_WIDTH){1'b0}}, atbytes_s} + {{(ATBYTESM_WIDTH-1){1'b0}}, 1'b1};
                    nxt_wide_fifo[ATB_SLAVE_DATA_WIDTH_LOC*iter +: ATB_SLAVE_DATA_WIDTH_LOC] = atdata_s;
                  end
              end
            else if (atvalid_s)
              begin
                nxt_atbytes_m = atbytes_m_int + {{(ATBYTESM_WIDTH-ATBYTESS_WIDTH){1'b0}}, atbytes_s} + {{(ATBYTESM_WIDTH-1){1'b0}}, 1'b1};
                nxt_wide_fifo[ATB_SLAVE_DATA_WIDTH_LOC*iter +: ATB_SLAVE_DATA_WIDTH_LOC] = atdata_s;

                if (iter < MASTER_SLAVE_PROP[3:0]-4'b1)
                  begin
                    nxt_upsizer_sm = ST_UPSIZER;
                    nxt_iter       = iter + 4'b1;
                  end
                else
                  begin
                    nxt_upsizer_sm = ST_UPSIZER_FLUSH_WIDE_BUF;
                    nxt_iter       = 4'b0;
                    nxt_atvalid_m = 1'b1;
                  end
              end
          end

        ST_UPSIZER_FLUSH_WIDE_BUF :
          begin
            if (master_atb_hand_shake)
              begin
                nxt_atvalid_m = 1'b0;
                if (flush_narrow)
                  begin
                    nxt_upsizer_sm = ST_UPSIZER_FLUSH_WIDE_BUF;
                    nxt_atvalid_m = 1'b1;
                    nxt_atbytes_m = {{(ATBYTESM_WIDTH-ATBYTESS_WIDTH){1'b0}}, atbytes_narrow};
                    nxt_atid_m    = atid_narrow;
                    nxt_wide_fifo[ATB_SLAVE_DATA_WIDTH_LOC - 1: 0] = atdata_s_narrow;
                    narrow_buf_data_driven = 1'b1;
                  end
                else if (narrow_buf_data_valid )
                  begin
                    if (stop_merge_flush)
                      begin
                        nxt_atvalid_m = 1'b1;
                        nxt_upsizer_sm = ST_UPSIZER_FLUSH_WIDE_BUF;
                      end
                    else
                      begin
                        nxt_upsizer_sm = ST_UPSIZER;
                        nxt_iter       = 4'b1;
                       end
                    nxt_atbytes_m = {{(ATBYTESM_WIDTH-ATBYTESS_WIDTH){1'b0}}, atbytes_narrow};
                    nxt_atid_m    = atid_narrow;
                    nxt_wide_fifo[ATB_SLAVE_DATA_WIDTH_LOC - 1: 0] = atdata_s_narrow;
                    narrow_buf_data_driven = 1'b1;
                  end

                else if (narrow_buf_has_data)
                  begin
                    nxt_upsizer_sm = ST_UPSIZER_FLUSH_WIDE_BUF;
                    nxt_atvalid_m = 1'b1;
                    nxt_atbytes_m = {{(ATBYTESM_WIDTH-ATBYTESS_WIDTH){1'b0}}, atbytes_narrow};
                    nxt_atid_m    = atid_narrow;
                    nxt_wide_fifo[ATB_SLAVE_DATA_WIDTH_LOC - 1: 0] = atdata_s_narrow;
                    narrow_buf_data_driven = 1'b1;
                  end
                else if (atvalid_s)
                  begin
                    if (stop_merge_atbytes_s_less)
                      begin
                        nxt_upsizer_sm = ST_UPSIZER_FLUSH_WIDE_BUF;
                        nxt_atvalid_m = 1'b1;
                        nxt_atbytes_m = {{(ATBYTESM_WIDTH-ATBYTESS_WIDTH){1'b0}}, atbytes_s};
                        nxt_atid_m    = atid_s;
                        nxt_wide_fifo[ATB_SLAVE_DATA_WIDTH_LOC - 1: 0] = atdata_s;
                      end
                    else
                      begin
                        nxt_upsizer_sm = ST_UPSIZER;
                        nxt_iter      = 4'b1;
                        nxt_atbytes_m = {{(ATBYTESM_WIDTH-ATBYTESS_WIDTH){1'b0}}, atbytes_s};
                        nxt_atid_m    = atid_s;
                        nxt_wide_fifo[ATB_SLAVE_DATA_WIDTH_LOC - 1: 0] = atdata_s;
                      end
                  end
                else
                  begin
                    nxt_upsizer_sm = ST_UPSIZER_IDLE;
                  end
              end
          end
        default  :
          begin
            nxt_upsizer_sm = 2'bxx;
            nxt_atvalid_m   = 1'bx;
            nxt_atbytes_m   = {ATBYTESM_WIDTH{1'bx}};
            nxt_atid_m      = 7'bxxxxxxx;
            nxt_wide_fifo  = {ATB_MASTER_DATA_WIDTH_LOC{1'bx}};
          end

      endcase
    end

    assign stop_merge_atbytes_s_less = (slave_atb_hand_shake & (atbytes_s != ATBYTESS_MAX[ATBYTESS_WIDTH-1:0])) & ATB_SLAVE_GT_8[0];
    assign stop_merge_atid_s = (slave_atb_hand_shake & (upsizer_sm != ST_UPSIZER_IDLE) & (atid_s != atid_m_int));
    assign stop_merge_flush = afvalid_s_int & afready_s & (upsizer_sm != ST_UPSIZER_IDLE);

    assign stop_merge_cond = stop_merge_atbytes_s_less | stop_merge_atid_s & (upsizer_sm != ST_UPSIZER_FLUSH_WIDE_BUF) | stop_merge_flush & (upsizer_sm != ST_UPSIZER_FLUSH_WIDE_BUF);

    assign upsizer_sm_flush_wide_buf = (upsizer_sm == ST_UPSIZER_FLUSH_WIDE_BUF);
    assign upsizer_sm_idle = (upsizer_sm == ST_UPSIZER_IDLE);
    assign reset_stop_merge_cond_reg = ((upsizer_sm_flush_wide_buf & master_atb_hand_shake) | (upsizer_sm_idle));

    assign nxt_stop_merge_cond_reg =  stop_merge_cond | (~reset_stop_merge_cond_reg & stop_merge_cond_reg) ;

    assign stop_merge = stop_merge_cond | stop_merge_cond_reg;

    assign set_flush_narrow = ~flush_narrow & (upsizer_sm == ST_UPSIZER_FLUSH_WIDE_BUF) &
                                (~master_atb_hand_shake & stop_merge_atbytes_s_less |
                                 stop_merge_flush & narrow_buf_data_valid & ~narrow_buf_data_driven);

    assign nxt_flush_narrow = set_flush_narrow | (~narrow_buf_data_driven & flush_narrow);


    assign nxt_narrow_buf_data_valid = (~narrow_buf_data_valid & ~stop_merge_atbytes_s_less & write_narrow) | (~narrow_buf_data_driven & narrow_buf_data_valid);

    assign nxt_narrow_buf_has_data = (~narrow_buf_has_data & write_narrow) | (~narrow_buf_data_driven & narrow_buf_has_data);

    assign write_narrow = (upsizer_sm == ST_UPSIZER_FLUSH_WIDE_BUF) & slave_atb_hand_shake & ~master_atb_hand_shake |
                          ((upsizer_sm != ST_UPSIZER_IDLE) & (upsizer_sm != ST_UPSIZER_FLUSH_WIDE_BUF) & (stop_merge_atid_s | slave_atb_hand_shake & stop_merge_flush));

    assign nxt_atready_s = ((upsizer_sm != ST_UPSIZER_FLUSH_WIDE_BUF) & ~nxt_narrow_buf_has_data) |
                          ((upsizer_sm == ST_UPSIZER_FLUSH_WIDE_BUF) & ~nxt_flush_narrow & ~nxt_narrow_buf_has_data);


  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
        atwakeup_m <= 1'b0;
      else
        atwakeup_m <= atwakeup_s;
    end

  always @(posedge clk or negedge reset_n)
    begin : p_upsizer_sm_seq
      if (!reset_n)
        begin
          upsizer_sm     <= ST_UPSIZER_IDLE;
          atvalid_m_int   <= 1'b0;
          atid_m_int      <= 7'b0;
          atbytes_m_int   <= {(ATBYTESM_WIDTH){1'b0}};
          wide_fifo      <= {(ATB_MASTER_DATA_WIDTH_LOC){1'b0}};
          narrow_buf_has_data   <= 1'b0;
          iter           <= 4'b0;
        end
      else
        begin
          upsizer_sm     <= nxt_upsizer_sm;
          atvalid_m_int   <= nxt_atvalid_m;
          atbytes_m_int   <= nxt_atbytes_m;
          atid_m_int      <= nxt_atid_m;
          wide_fifo      <= nxt_wide_fifo;
          narrow_buf_has_data   <= nxt_narrow_buf_has_data;
          iter           <= nxt_iter;
        end
    end
  assign atdata_m = wide_fifo;

  always @(posedge clk or negedge reset_n)
    begin : p_upsizer_ctl_seq
      if (!reset_n)
        begin
          stop_merge_cond_reg     <= 1'b0;
          flush_narrow            <= 1'b0;
          narrow_buf_data_valid   <= 1'b0;
          atready_s_int           <= 1'b0;
        end
      else
        begin
          stop_merge_cond_reg     <= nxt_stop_merge_cond_reg;
          flush_narrow            <= nxt_flush_narrow;
          narrow_buf_data_valid   <= nxt_narrow_buf_data_valid;
          atready_s_int            <= nxt_atready_s;
        end
    end

  always @(posedge clk or negedge reset_n)
    begin : p_atbs_flush_seq
      if (!reset_n)
        begin
          upsizer_flush_sm <= ST_UPSIZER_FLUSH_IDLE;
          afvalid_s_int <= 1'b0;
          afready_m_int <= 1'b1;
        end
      else
        begin
          upsizer_flush_sm <= nxt_upsizer_flush_sm;
          afvalid_s_int <= nxt_afvalid_s;
          afready_m_int <= nxt_afready_m;
        end
    end

  always @(posedge clk or negedge reset_n)
    begin : p_narrow_buffer_seq
      if (!reset_n)
        begin
          atbytes_narrow <= {ATBYTESS_WIDTH{1'b0}};
          atid_narrow    <= 7'b0;
          atdata_s_narrow <= {ATB_SLAVE_DATA_WIDTH_LOC{1'b0}};
        end
      else if (write_narrow)
        begin
          atbytes_narrow <= atbytes_s;
          atid_narrow    <= atid_s;
          atdata_s_narrow <= atdata_s;
        end
    end

  always @(posedge clk or negedge reset_n)
    begin : p_syncreq_s_seq
      if (!reset_n)
        begin
          syncreq_s <= 1'b0;
        end
      else
        begin
          syncreq_s <= syncreq_m;
        end
    end

  css600_or_tree
  #(
    .NUM_OR_INPUTS (2)
  )
  u_qactive_async
  (
    .or_inputs({afvalid_m, atwakeup_s}),
    .or_output(clk_qactive)
  );

endmodule

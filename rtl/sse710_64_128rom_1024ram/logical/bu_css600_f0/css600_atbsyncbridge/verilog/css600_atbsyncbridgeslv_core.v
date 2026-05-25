//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017 Arm Limited or its affiliates.
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
//   Sub-module of css600_atbsyncbridge
//
//----------------------------------------------------------------------------


module css600_atbsyncbridgeslv_core # (
    parameter ATB_DATA_WIDTH = 32
)

(
  clk,

  reset_n,
  atvalid_s,
  atid_s,
  atbytes_s,
  atdata_s,
  afready_s,

  atready_s,
  afvalid_s,

  atb_fwd_data,
  flush_req,
  flush_done,
  wr_pointer,
  rd_pointer,
  sync_clear,
  sync_done,

  pwr_lp_request,
  pwr_lp_done,
  clk_lp_request,
  clk_lp_done,

  clk_qreq,
  clk_qaccept,

  dev_active

);

function integer atb_clog2 (input integer num);
  integer i;
  begin
    atb_clog2 = 0;
    for(i=num; i>1; i=i>>1)
      atb_clog2 = atb_clog2 + 1;
  end
endfunction


  localparam ATBYTES_WIDTH = (ATB_DATA_WIDTH > 8) ? (atb_clog2(ATB_DATA_WIDTH)-3) : 1;
  localparam PAYLD_WIDTH     = (ATBYTES_WIDTH+ATB_DATA_WIDTH+7);

  localparam FIFO_PTR_WIDTH = 1;
  localparam FIFO_DEPTH     = 2;


  input wire  clk;

  input  wire reset_n;
  input  wire atvalid_s;
  input  wire [6:0] atid_s;
  input  wire [ATBYTES_WIDTH-1:0] atbytes_s;
  input  wire [ATB_DATA_WIDTH-1:0] atdata_s;
  output wire atready_s;

  input  wire afready_s;
  output wire afvalid_s;

  output wire [2*PAYLD_WIDTH+1:0] atb_fwd_data;
  input  wire flush_req;
  output wire flush_done;
  output wire [FIFO_PTR_WIDTH:0] wr_pointer;
  input  wire [FIFO_PTR_WIDTH:0] rd_pointer;
  output reg  sync_clear;
  input wire  sync_done;

  input  wire pwr_lp_request;
  input  wire clk_lp_request;
  input  wire dev_active;
  output reg pwr_lp_done;
  output reg clk_lp_done;

  input wire clk_qreq;
  input wire clk_qaccept;


  wire                    valid_src;
  wire [PAYLD_WIDTH-1:0]  payload_src;

  wire                    load_en;
  wire                    iready_src;
  wire                    clk_on;

  wire                    iflush_req;

  reg [PAYLD_WIDTH-1 :0]      fifo_payload [FIFO_DEPTH-1 :0];
  reg [FIFO_DEPTH-1 :0]   fifo_load_en;
  wire                    nxt_fifo_full;
  wire [FIFO_PTR_WIDTH:0] nxt_wr_ptr;
  reg [FIFO_PTR_WIDTH:0]  wr_ptr;

  reg                     iafvalids;


  reg [1:0] nxt_clk_lpi_state;
  reg [1:0] clk_lpi_state;
  reg [2:0] nxt_pwr_lpi_state;
  reg [2:0] pwr_lpi_state;

  wire fifo_empty;
  reg nxt_sync_clear;
  reg nxt_clk_lp_done;
  reg nxt_pwr_lp_done;
  reg lpi_flush;
  reg nxt_lpi_flush;


  reg nxt_iafvalids;
  reg nxt_flush_done;
  reg [1:0] nxt_flush_state;

  reg  [1:0] flush_state;
  reg iflush_done;

  wire flush_end_wr_ptr_en;
  reg [1:0] flush_end_wr_ptr;
  wire lpi_state_en;


  localparam  C_LPI_IDLE          = 2'b00;
  localparam  CLK_DNY             = 2'b01;
  localparam  CLK_DWN             = 2'b10;
  localparam  CLK_WAIT_ACTIVE     = 2'b11;

  localparam  P_LPI_IDLE          = 3'b000;
  localparam  LPI_FLUSH_REQ       = 3'b001;
  localparam  LPI_WAIT_FOR_PWRDWN = 3'b010;
  localparam  PWR_DWN             = 3'b011;
  localparam  MST_RDY             = 3'b100;
  localparam  P_LPI_UNUSED1       = 3'b101;
  localparam  P_LPI_UNUSED2       = 3'b110;
  localparam  P_LPI_UNUSED3       = 3'b111;


  localparam  F_IDLE              = 2'b00;
  localparam  F_FLUSHING          = 2'b01;
  localparam  F_FLUSH_COMPLETE    = 2'b10;
  localparam  F_NO_FLUSH          = 2'b11;
  localparam  F_UNDEFINED         = 2'bxx;


  genvar i;
  genvar j;


  assign valid_src = atvalid_s;
  assign payload_src = {atbytes_s, atid_s, atdata_s};

  assign clk_on = clk_qreq | clk_qaccept;
  assign atready_s = (iready_src & (clk_lpi_state != CLK_DWN)) | sync_clear;


  generate
  for (i=0; i<FIFO_DEPTH; i=i+1)
  begin : p_fifo_load_en
    always @*
    begin
      fifo_load_en[i] = (i[FIFO_PTR_WIDTH-1:0] == wr_ptr[FIFO_PTR_WIDTH-1 :0] ) & load_en;
    end
  end
  endgenerate


  assign nxt_wr_ptr = load_en ? wr_ptr+2'b1 : wr_ptr;


  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n)
      wr_ptr <= {FIFO_PTR_WIDTH+1{1'b0}};
    else if (nxt_pwr_lpi_state == PWR_DWN)
      wr_ptr <= {FIFO_PTR_WIDTH+1{1'b0}};
    else
      wr_ptr <= nxt_wr_ptr;
  end

  assign wr_pointer = wr_ptr;


  assign lpi_state_en = ~(clk_lpi_state == CLK_DWN) &
                        (
                          ~(
                            (flush_state == F_FLUSH_COMPLETE) |
                            (flush_state == F_NO_FLUSH)
                           )
                         |

                         (pwr_lpi_state == P_LPI_IDLE)
                        );


  assign load_en = valid_src & ~nxt_fifo_full & lpi_state_en & clk_on;


  assign nxt_fifo_full = (rd_pointer[FIFO_PTR_WIDTH] != wr_ptr[FIFO_PTR_WIDTH] ) &
         (rd_pointer[FIFO_PTR_WIDTH-1 :0] == wr_ptr[FIFO_PTR_WIDTH-1 :0] );


  assign iready_src = ~nxt_fifo_full;


  generate
  for (j=0; j<FIFO_DEPTH; j=j+1)
  begin : gen_fifo

    always @(posedge clk or negedge reset_n)
    begin
    if (!reset_n)
      fifo_payload[j] <= {(PAYLD_WIDTH){1'b0}};
    else if (fifo_load_en[j])
      fifo_payload[j] <= payload_src;
    end
  end
  endgenerate

  assign flush_end_wr_ptr_en = nxt_flush_done & ~iflush_done;

  always @(posedge clk or negedge reset_n)
    begin
    if (!reset_n)
      flush_end_wr_ptr <= {FIFO_PTR_WIDTH+1{1'b0}};
    else if (nxt_pwr_lpi_state == PWR_DWN)
      flush_end_wr_ptr <= {FIFO_PTR_WIDTH+1{1'b0}};
    else if (flush_end_wr_ptr_en)
      flush_end_wr_ptr <= nxt_wr_ptr;
    end

  assign  atb_fwd_data[PAYLD_WIDTH-1:0]               = fifo_payload[0];
  assign  atb_fwd_data[2*PAYLD_WIDTH-1:PAYLD_WIDTH]   = fifo_payload[1];
  assign  atb_fwd_data[2*PAYLD_WIDTH+1:2*PAYLD_WIDTH] = flush_end_wr_ptr;


  assign fifo_empty = (rd_pointer == nxt_wr_ptr);

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n) begin
      clk_lpi_state <= CLK_DWN;
      pwr_lpi_state <= PWR_DWN;
      lpi_flush   <= 1'b0;
      sync_clear  <= 1'b1;
      pwr_lp_done <= 1'b1;
      clk_lp_done <= 1'b0;

    end
    else begin
      pwr_lpi_state   <= nxt_pwr_lpi_state;
      clk_lpi_state   <= nxt_clk_lpi_state;
      lpi_flush   <= nxt_lpi_flush;
      sync_clear  <= nxt_sync_clear;
      pwr_lp_done <= nxt_pwr_lp_done;
      clk_lp_done <= nxt_clk_lp_done;
    end
  end

always @* begin

    nxt_pwr_lpi_state = pwr_lpi_state;
    nxt_lpi_flush = lpi_flush;
    nxt_sync_clear = sync_clear;
    nxt_pwr_lp_done = pwr_lp_done;

    case (pwr_lpi_state)
      P_LPI_IDLE: begin
        if (pwr_lp_request) begin
          nxt_sync_clear = 1'b0;
          if (flush_state == F_IDLE) begin
            nxt_pwr_lpi_state = LPI_FLUSH_REQ;
            nxt_lpi_flush = 1'b1;
          end
          else begin
            nxt_pwr_lpi_state = P_LPI_IDLE;
            nxt_lpi_flush = 1'b0;
          end
        end
      end

      LPI_FLUSH_REQ: begin
        if (flush_state == F_NO_FLUSH) begin
          nxt_pwr_lpi_state = LPI_WAIT_FOR_PWRDWN;
          nxt_lpi_flush = 1'b0;
        end
      end

      LPI_WAIT_FOR_PWRDWN: begin
        if (fifo_empty) begin
          nxt_sync_clear = 1'b1;
        end

        if (sync_clear && sync_done) begin
          nxt_pwr_lpi_state = PWR_DWN;
          nxt_pwr_lp_done = 1'b1;
        end
        else
          nxt_pwr_lpi_state = LPI_WAIT_FOR_PWRDWN;
        end

      PWR_DWN: begin
        if (!pwr_lp_request) begin
          nxt_pwr_lpi_state = MST_RDY;
          nxt_sync_clear = 1'b0;
        end
        else begin
          nxt_sync_clear = 1'b1;
        end
      end

      MST_RDY: begin
        if (!sync_done) begin
          nxt_pwr_lp_done = 1'b0;
          nxt_pwr_lpi_state = P_LPI_IDLE;
        end
      end

      P_LPI_UNUSED1 : nxt_pwr_lpi_state = PWR_DWN;
      P_LPI_UNUSED2 : nxt_pwr_lpi_state = PWR_DWN;
      P_LPI_UNUSED3 : nxt_pwr_lpi_state = PWR_DWN;

      default: begin
        nxt_pwr_lpi_state = 3'bxxx;
        nxt_lpi_flush = 1'bx;
        nxt_sync_clear = 1'bx;
      end
    endcase
  end


always @* begin

    nxt_clk_lpi_state = clk_lpi_state;
    nxt_clk_lp_done = clk_lp_done;

    case (clk_lpi_state)
      C_LPI_IDLE: begin
        if (clk_lp_request) begin
          nxt_clk_lp_done = 1'b1;
          if (!dev_active)
            nxt_clk_lpi_state = CLK_WAIT_ACTIVE;
          else
            nxt_clk_lpi_state = CLK_DNY;
        end
      end

      CLK_WAIT_ACTIVE: begin
        nxt_clk_lp_done = 1'b1;
        if (dev_active)
          nxt_clk_lpi_state = CLK_DNY;
        else
          nxt_clk_lpi_state = CLK_DWN;
      end

      CLK_DWN: begin
        if (!clk_lp_request) begin
          nxt_clk_lp_done = 1'b0;
          nxt_clk_lpi_state = C_LPI_IDLE;
        end
        else begin
          nxt_clk_lp_done = 1'b1;
          nxt_clk_lpi_state = CLK_DWN;
        end
      end

      CLK_DNY : begin
        if (!clk_lp_request) begin
          nxt_clk_lp_done = 1'b0;
          nxt_clk_lpi_state = C_LPI_IDLE;
        end
        else begin
          nxt_clk_lp_done = 1'b1;
          nxt_clk_lpi_state = CLK_DNY;
        end
      end

      default: begin
        nxt_clk_lpi_state = 2'bxx;
      end
    endcase
  end


  assign iflush_req = (pwr_lpi_state != P_LPI_IDLE) ? 1'b0 : flush_req;

  always @*
  begin

    nxt_flush_state = flush_state;
    nxt_iafvalids   = iafvalids;
    nxt_flush_done  = flush_done;

    case (flush_state)

    F_IDLE            : begin
                          if (iflush_req || lpi_flush) begin
                            nxt_flush_state = F_FLUSHING;
                            nxt_iafvalids   = 1'b1;
                          end
                          else begin
                            nxt_flush_state = F_IDLE;
                            nxt_iafvalids   = 1'b0;
                            nxt_flush_done  = 1'b0;
                          end
                        end
    F_FLUSHING        : begin
                          if (afready_s) begin
                            nxt_flush_state = F_FLUSH_COMPLETE;
                            nxt_iafvalids   = 1'b0;
                            nxt_flush_done  = 1'b1;
                          end
                          else begin
                            nxt_flush_state = F_FLUSHING;
                            nxt_iafvalids   = iafvalids;
                            nxt_flush_done  = 1'b0;
                          end
                        end
    F_FLUSH_COMPLETE  : begin
                          if (lpi_flush) begin
                            nxt_flush_state = F_NO_FLUSH;
                            nxt_flush_done  = 1'b1;
                          end
                          else if (iflush_req) begin
                            nxt_flush_state = F_FLUSH_COMPLETE;
                            nxt_flush_done  = 1'b1;
                          end
                          else begin
                            nxt_flush_state = F_IDLE;
                            nxt_flush_done  = 1'b0;
                          end
                        end
    F_NO_FLUSH        : begin
                          if (pwr_lpi_state == P_LPI_IDLE) begin
                            nxt_flush_state = F_IDLE;
                            nxt_flush_done  = 1'b0;
                          end
                        end
    default           : begin
                          nxt_flush_state = F_UNDEFINED;
                          nxt_iafvalids   = 1'bx;
                          nxt_flush_done  = 1'bx;
                        end
   endcase
  end


  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n)
      flush_state <= F_NO_FLUSH;
    else
      flush_state <= nxt_flush_state;
  end

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n)
      iafvalids  <= 1'b0;
    else
      iafvalids <= nxt_iafvalids;
  end

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n)
      iflush_done <= 1'b1;
    else if (pwr_lpi_state == PWR_DWN)
      iflush_done <= 1'b1;
    else
      iflush_done <= nxt_flush_done;
  end

  assign afvalid_s = iafvalids;
  assign flush_done = iflush_done;

endmodule

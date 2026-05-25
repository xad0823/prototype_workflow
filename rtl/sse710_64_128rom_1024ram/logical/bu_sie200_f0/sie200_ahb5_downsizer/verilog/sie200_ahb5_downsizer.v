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
//      Checked In          : Fri Mar 3 12:23:56 2017 +0000
//
//      Revision            : 179e6c1
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_downsizer #(
    parameter ADDR_WIDTH            = 32,
    parameter DATA_WIDTH            = 64,
    parameter USER_WIDTH            =  1,
    parameter MASTER_WIDTH          =  4,
    parameter ERR_BURST_BLOCK_ALL   =  1,
    parameter ENDIANNESS            =  0
)(
    input  wire                     hclk        ,
    input  wire                     hresetn     ,

    input  wire                     hsel_s      ,
    input  wire                     hnonsec_s   ,
    input  wire [ADDR_WIDTH-1:0]    haddr_s     ,
    input  wire [1:0]               htrans_s    ,
    input  wire [2:0]               hsize_s     ,
    input  wire                     hwrite_s    ,
    input  wire                     hready_s    ,
    input  wire [6:0]               hprot_s     ,
    input  wire [2:0]               hburst_s    ,
    input  wire                     hmastlock_s ,
    input  wire [DATA_WIDTH  -1:0]  hwdata_s    ,
    input  wire                     hexcl_s     ,
    input  wire [MASTER_WIDTH-1:0]  hmaster_s   ,
    output wire [DATA_WIDTH  -1:0]  hrdata_s    ,
    output reg                      hreadyout_s ,
    output reg                      hresp_s     ,
    output reg                      hexokay_s   ,
    input  wire [USER_WIDTH-1:0]    hauser_s    ,
    input  wire [USER_WIDTH-1:0]    hwuser_s    ,
    output wire [USER_WIDTH-1:0]    hruser_s    ,

    output wire                     hsel_m      ,
    output reg                      hnonsec_m   ,
    output wire [ADDR_WIDTH-1:0]    haddr_m     ,
    output reg  [1:0]               htrans_m    ,
    output wire [2:0]               hsize_m     ,
    output reg                      hwrite_m    ,
    output wire                     hready_m    ,
    output reg  [6:0]               hprot_m     ,
    output reg  [2:0]               hburst_m    ,
    output reg                      hmastlock_m ,
    output wire [DATA_WIDTH/2-1:0]  hwdata_m    ,
    output reg                      hexcl_m     ,
    output reg  [MASTER_WIDTH-1:0]  hmaster_m   ,
    input  wire                     hreadyout_m ,
    input  wire                     hresp_m     ,
    input  wire [DATA_WIDTH/2-1:0]  hrdata_m    ,
    input  wire                     hexokay_m   ,
    output reg  [USER_WIDTH-1:0]    hauser_m    ,
    output wire [USER_WIDTH-1:0]    hwuser_m    ,
    input  wire [USER_WIDTH-1:0]    hruser_m
);

  localparam AHB_TRANS_IDLE        = 2'b00;
  localparam AHB_TRANS_BUSY        = 2'b01;
  localparam AHB_TRANS_NONSEQ      = 2'b10;
  localparam AHB_TRANS_SEQ         = 2'b11;

  localparam AHB_RESP_OKAY         = 1'b0;
  localparam AHB_RESP_ERR          = 1'b1;

  localparam AHB_BURST_SINGLE      = 3'b000;
  localparam AHB_BURST_INCR        = 3'b001;
  localparam AHB_BURST_WRAP4       = 3'b010;
  localparam AHB_BURST_INCR4       = 3'b011;
  localparam AHB_BURST_WRAP8       = 3'b100;
  localparam AHB_BURST_INCR8       = 3'b101;
  localparam AHB_BURST_WRAP16      = 3'b110;
  localparam AHB_BURST_INCR16      = 3'b111;

  localparam AHB_SIZE = (DATA_WIDTH == 1024) ? 3'b111 :
                        (DATA_WIDTH == 512 ) ? 3'b110 :
                        (DATA_WIDTH == 256 ) ? 3'b101 :
                        (DATA_WIDTH == 128 ) ? 3'b100 :
                        (DATA_WIDTH == 64  ) ? 3'b011 :
                        (DATA_WIDTH == 32  ) ? 3'b010 :
                        (DATA_WIDTH == 16  ) ? 3'b001 :
                                               3'b000 ;

  localparam AHB_HALF_SIZE         = AHB_SIZE-1;


  localparam BERR_FSM_NORMAL       = 2'b00;
  localparam BERR_FSM_ERR1         = 2'b01;
  localparam BERR_FSM_ERR2         = 2'b10;
  localparam BERR_FSM_BUSY         = 2'b11;

  localparam DS_FSM_IDLE           = 3'b000;
  localparam DS_FSM_CYC1           = 3'b001;
  localparam DS_FSM_CYC2           = 3'b010;
  localparam DS_FSM_DELAY          = 3'b011;
  localparam DS_FSM_ABORT          = 3'b101;


  reg [1:0]     berr_current_state;
  reg [1:0]     berr_next_state;
  wire          reg_seq_to_nseq;

  reg [2:0]     dsc_current_state;
  reg [2:0]     ds_next_state;

  reg           hsel_ds_in;
  reg [1:0]     htrans_ds_in;
  reg           hready_ds_out;
  reg           hexokay_ds_out;
  reg           hresp_ds_out;

  reg           htrans_ds_active;

  wire          next_wrapped;
  reg           wrapped;

  wire          exclusive_write_override;
  reg           exclusive_write_override_reg;

  reg           block_disable;
  wire          next_block_disable;

  reg [ADDR_WIDTH-1:0] haddr_reg;
  reg [2:0]     haddr_i16_reg;
  reg [1:0]     htrans_reg;
  reg [2:0]     hsize_reg;
  reg [2:0]     hburst_reg;
  reg [6:0]     hprot_reg;
  reg           hwrite_reg;
  reg           hmastlock_reg;
  reg           hnonsec_reg;
  reg           hexcl_reg;
  reg [USER_WIDTH-1:0]   hauser_reg;
  reg [MASTER_WIDTH-1:0] hmaster_reg;

  wire          haddr_i16_reg_en;
  wire [2:0]    haddr_i16_bound;

  reg [2:0]     hburst_mapped;
  reg [2:0]     hburst_mapped_reg;

  reg [ADDR_WIDTH-1:0] i_haddr_m;
  wire          i_hready_m;
  reg           i_hsel_m;

  reg           fwd_mux_ctrl;
  reg [DATA_WIDTH/2-1:0] hrdata_reg;
  reg           frd_mux_ctrl;
  reg           next_frd_mux_ctrl;
  wire          hrdata_sel;

  wire          s_not_sel_nxt;
  reg           s_not_sel;
  wire          m_not_sel_nxt;
  reg           m_not_sel;



  assign exclusive_write_override = (hsize_s == AHB_SIZE[2:0]) & hwrite_s & hexcl_s & htrans_ds_active;

  always @(posedge hclk or negedge hresetn)
    begin
      if (~hresetn)
        exclusive_write_override_reg <= 1'b0;
      else
        exclusive_write_override_reg <= exclusive_write_override;
    end

  always @ (htrans_s or hsel_s or hready_s or hresp_m or hreadyout_m or berr_current_state or
            block_disable or exclusive_write_override or m_not_sel)
    begin : p_berrcomb
      if ((~hsel_s) & hready_s)
        berr_next_state = BERR_FSM_NORMAL;
      else
        begin
          case (berr_current_state)
            BERR_FSM_NORMAL :
              begin
                if (block_disable | exclusive_write_override)
                  berr_next_state = BERR_FSM_NORMAL;
                else if ((hresp_m == AHB_RESP_ERR) & (~hreadyout_m) & (~m_not_sel))
                  berr_next_state = BERR_FSM_ERR2;
                else
                  berr_next_state = BERR_FSM_NORMAL;
              end

            BERR_FSM_ERR1 :
              begin
                berr_next_state = BERR_FSM_ERR2;
              end

            BERR_FSM_ERR2, BERR_FSM_BUSY:
              begin
                if (htrans_s == AHB_TRANS_SEQ)
                  berr_next_state = BERR_FSM_ERR1;
                else if (htrans_s == AHB_TRANS_BUSY)
                  berr_next_state = BERR_FSM_BUSY;
                else
                  berr_next_state = BERR_FSM_NORMAL;
              end
            default :
              berr_next_state = {2{1'bx}};
          endcase
        end
    end

  always @ (posedge hclk or negedge hresetn)
    begin : p_berrseq
      if (~hresetn)
        berr_current_state <= BERR_FSM_NORMAL;
      else
        berr_current_state <= berr_next_state;
    end

generate
if(ERR_BURST_BLOCK_ALL == 0) begin: NO_BURST_BLOCKING

  reg           reg_seq_to_nseq_i;
  reg           nxt_seq_to_nseq;

  always @(hresp_m or hreadyout_m or htrans_s or hsel_s or hready_s or reg_seq_to_nseq)
    begin
    if ((htrans_s==AHB_TRANS_IDLE)|(htrans_s==AHB_TRANS_NONSEQ)|((~hsel_s) & hready_s))
      nxt_seq_to_nseq = 1'b0;
    else if ((hresp_m==AHB_RESP_ERR) & (~hreadyout_m))
      nxt_seq_to_nseq = 1'b1;
    else
      nxt_seq_to_nseq = reg_seq_to_nseq;
    end

  always @ (posedge hclk or negedge hresetn)
    begin : p_burst_err_continue
      if (~hresetn)
        reg_seq_to_nseq_i <= 1'b0;
      else
        reg_seq_to_nseq_i <= nxt_seq_to_nseq;
    end

  assign reg_seq_to_nseq = reg_seq_to_nseq_i;

end else begin: BUSRT_BLOCKING

  assign reg_seq_to_nseq = 1'b0;

end
endgenerate


  always @ (berr_current_state or htrans_s or hsel_s)
    begin : p_hstdsin
      if (((berr_current_state == BERR_FSM_ERR1) |
          ((berr_current_state !=BERR_FSM_NORMAL) & (htrans_s !=AHB_TRANS_NONSEQ))
          ) & hsel_s)
        begin
          hsel_ds_in = 1'b0;
          htrans_ds_in = AHB_TRANS_IDLE;
        end
      else
        begin
          hsel_ds_in = hsel_s;
          htrans_ds_in = htrans_s & {2{hsel_s}};
        end
    end

  always @ (berr_current_state or hready_ds_out or hexokay_ds_out or hresp_ds_out)
    begin : p_berr_resp
      case (berr_current_state)

        BERR_FSM_NORMAL :
          begin
            hreadyout_s = hready_ds_out;
            hresp_s     = hresp_ds_out;
            hexokay_s   = hexokay_ds_out;
          end

        BERR_FSM_ERR1 :
          begin
            hreadyout_s = 1'b0;
            hresp_s     = AHB_RESP_ERR;
            hexokay_s   = 1'b0;
          end

        BERR_FSM_ERR2 :
          begin
            hreadyout_s = 1'b1;
            hresp_s     = AHB_RESP_ERR;
            hexokay_s   = 1'b0;
          end

        BERR_FSM_BUSY:
          begin
            hreadyout_s = 1'b1;
            hresp_s     = AHB_RESP_OKAY;
            hexokay_s   = 1'b0;
          end

        default:
          begin
            hreadyout_s = 1'bx;
            hresp_s     = 1'bx;
            hexokay_s   = 1'bx;
          end
      endcase
    end

  always @ (posedge hclk or negedge hresetn)
    begin : p_store_ctrls
      if (~hresetn)
        begin
          haddr_reg        <= {ADDR_WIDTH{1'b0}};
          htrans_reg       <= {2{1'b0}};
          hsize_reg        <= {3{1'b0}};
          hburst_reg       <= {3{1'b0}};
          hburst_mapped_reg<= {3{1'b0}};
          hprot_reg        <= {7{1'b0}};
          hwrite_reg       <= 1'b0;
          hmastlock_reg    <= 1'b0;
          hnonsec_reg      <= 1'b0;
          hexcl_reg        <= 1'b0;
          hmaster_reg      <= {MASTER_WIDTH{1'b0}};
          hauser_reg       <= {USER_WIDTH{1'b0}};
        end
      else
        begin
          if (hready_s)
            begin
              haddr_reg        <= haddr_s;
              htrans_reg       <= htrans_s;
              hsize_reg        <= hsize_s;
              hburst_reg       <= hburst_s;
              hburst_mapped_reg<= hburst_mapped;
              hprot_reg        <= hprot_s;
              hwrite_reg       <= hwrite_s;
              hmastlock_reg    <= hmastlock_s;
              hnonsec_reg      <= hnonsec_s;
              hexcl_reg        <= hexcl_s;
              hmaster_reg      <= hmaster_s;
              hauser_reg       <= hauser_s;
            end
        end
    end

  always @ (htrans_ds_in)
    begin : p_trans_active
      if ((htrans_ds_in == AHB_TRANS_NONSEQ) | (htrans_ds_in == AHB_TRANS_SEQ))
        htrans_ds_active = 1'b1;
      else
        htrans_ds_active = 1'b0;
    end

  assign haddr_i16_reg_en = (hready_s & hsel_ds_in & (htrans_ds_in == AHB_TRANS_NONSEQ) &
                            (hburst_s == AHB_BURST_INCR16));

  always @ (posedge hclk or negedge hresetn)
    begin : p_store_i16addr
      if (~hresetn)
        haddr_i16_reg <= {3{1'b0}};
      else
        if (haddr_i16_reg_en)
          haddr_i16_reg <= haddr_s[AHB_SIZE+2:AHB_SIZE];
    end

  always @ (dsc_current_state or hsel_ds_in or hsize_s or hsize_reg or i_hready_m or
            hresp_m or hready_s or htrans_ds_active or hexcl_s or hexcl_reg or hwrite_s or
            hwrite_reg or m_not_sel)
    begin : p_ds_fsm_comb
      case (dsc_current_state)

        DS_FSM_IDLE :
          begin
            if (hresp_m == AHB_RESP_ERR & ~m_not_sel)
              begin
                ds_next_state = DS_FSM_ABORT;
              end
            else if (hsel_ds_in & hready_s)
              begin
                if ((hsize_s == AHB_SIZE[2:0]) & htrans_ds_active & ~(hexcl_s & hwrite_s))
                  begin
                    ds_next_state = DS_FSM_CYC1;
                  end
                else
                  begin
                    ds_next_state = DS_FSM_IDLE;
                  end
              end
            else
              begin
                ds_next_state = DS_FSM_IDLE;
              end
          end

        DS_FSM_CYC1 :
          begin
            if (hresp_m == AHB_RESP_ERR)
              begin
                ds_next_state = DS_FSM_ABORT;
              end
            else if (i_hready_m)
              begin
                ds_next_state = DS_FSM_CYC2;
              end
            else
              begin
                ds_next_state = DS_FSM_CYC1;
              end
          end

        DS_FSM_CYC2 :
          begin
            if (hresp_m == AHB_RESP_ERR)
              begin
                ds_next_state = DS_FSM_ABORT;
              end
            else if (i_hready_m)
              begin
                if (hsel_ds_in)
                  begin
                    if ((hsize_s == AHB_SIZE[2:0]) & htrans_ds_active & ~(hexcl_s & hwrite_s))
                      begin
                        ds_next_state = DS_FSM_CYC1;
                      end
                    else
                      begin
                        ds_next_state = DS_FSM_IDLE;
                      end
                  end
                else
                  begin
                    ds_next_state = DS_FSM_IDLE;
                  end
              end
            else
              begin
                ds_next_state = DS_FSM_CYC2;
              end
          end

        DS_FSM_ABORT :
          begin
            if (hsel_ds_in & htrans_ds_active)
              ds_next_state = DS_FSM_DELAY;
            else
              begin
                ds_next_state = DS_FSM_IDLE;
              end
          end

        DS_FSM_DELAY :
          begin
            if (hsize_reg == AHB_SIZE[2:0] & ~(hexcl_reg & hwrite_reg))
              begin
                ds_next_state = DS_FSM_CYC1;
              end
            else
              begin
                ds_next_state = DS_FSM_IDLE;
              end
          end

        3'b100, 3'b110, 3'b111:
          begin
            ds_next_state = DS_FSM_IDLE;
          end
        default:
          begin
            ds_next_state = 3'bxxx;
          end
      endcase
    end

  always @ (posedge hclk or negedge hresetn)
    begin : p_ds_fsm_seq
      if (~hresetn)
        dsc_current_state <= DS_FSM_IDLE;
      else
        dsc_current_state <= ds_next_state;
    end

  assign  next_block_disable = ((htrans_s!=AHB_TRANS_IDLE) &
          ((hsize_s == AHB_SIZE[2:0])|(ERR_BURST_BLOCK_ALL!=1'b0))) ? 1'b0 : 1'b1;

  always @ (posedge hclk or negedge hresetn)
    begin : p_disable_seq
    if (~hresetn)
      block_disable <= 1'b1;
    else if (hready_s)
      block_disable <= next_block_disable;
    end

  always @ (dsc_current_state or hsel_ds_in)
    begin : p_i_hsel_m
      if ((dsc_current_state == DS_FSM_CYC1) | (dsc_current_state == DS_FSM_DELAY))
        begin
          i_hsel_m = 1'b1;
        end
      else
        begin
          i_hsel_m = hsel_ds_in;
        end
    end

  assign hsel_m = i_hsel_m;


  assign haddr_i16_bound = haddr_i16_reg - 3'b001;

  assign next_wrapped = (
                        (
                         (htrans_ds_active &
                          (haddr_s[AHB_SIZE+3:AHB_SIZE]== 4'b1111) & (hburst_s == AHB_BURST_WRAP16)) |
                         ((htrans_ds_in == AHB_TRANS_SEQ) &
                          (haddr_s[AHB_SIZE+2:AHB_SIZE]== haddr_i16_bound) &
                          (hburst_s == AHB_BURST_INCR16))
                         ) ? 1'b1 :
                        ((htrans_ds_in == AHB_TRANS_BUSY) ? wrapped : 1'b0)
                        );

  always @ (negedge hresetn or posedge hclk)
    begin : p_wrapped
      if (~hresetn)
        wrapped <= 1'b0;
      else
        if (hready_s)
          wrapped <= next_wrapped;
    end

  always @ (dsc_current_state or htrans_ds_in or wrapped or reg_seq_to_nseq or hsize_s or
            hsel_s or exclusive_write_override or exclusive_write_override_reg or s_not_sel or
            hready_s)
    begin : p_htrans
      if (dsc_current_state == DS_FSM_CYC1)
        begin
          htrans_m = AHB_TRANS_SEQ;
        end

      else if (dsc_current_state == DS_FSM_ABORT)
        begin
          htrans_m = AHB_TRANS_IDLE;
        end

      else if (dsc_current_state == DS_FSM_DELAY)
        begin
          if (exclusive_write_override_reg)
            begin
              htrans_m = AHB_TRANS_IDLE;
            end
          else
            begin
              htrans_m = AHB_TRANS_NONSEQ;
            end
        end

      else if ((wrapped & (hsize_s == AHB_SIZE[2:0]) & hsel_s))
        begin
          if (exclusive_write_override)
            begin
              htrans_m = AHB_TRANS_IDLE;
            end
          else
            begin
              htrans_m[1] = htrans_ds_in[1];
              htrans_m[0] = 1'b0;
            end
        end

      else
        begin
          if ((exclusive_write_override & hsel_s) | (s_not_sel & ~hready_s))
            begin
              htrans_m = AHB_TRANS_IDLE;
            end
          else
            begin
              htrans_m[1] = htrans_ds_in[1];
              htrans_m[0] = htrans_ds_in[0] & (~reg_seq_to_nseq);
            end
        end
    end

  always @ (dsc_current_state or haddr_s or haddr_reg)
    begin : p_haddr
      if (dsc_current_state == DS_FSM_DELAY)
        i_haddr_m = haddr_reg;
      else if (dsc_current_state == DS_FSM_CYC1)
        begin
          i_haddr_m = haddr_reg;
          i_haddr_m[AHB_HALF_SIZE] = 1'b1;
        end
      else
        i_haddr_m = haddr_s;
    end

  assign haddr_m = i_haddr_m;

  always @ (hburst_s)
    begin : p_burstmap
      case (hburst_s)
        AHB_BURST_WRAP4 : begin
          hburst_mapped = AHB_BURST_WRAP8;
        end
        AHB_BURST_INCR4 : begin
          hburst_mapped = AHB_BURST_INCR8;
        end
        AHB_BURST_WRAP8 : begin
          hburst_mapped = AHB_BURST_WRAP16;
        end
        AHB_BURST_INCR8 : begin
          hburst_mapped = AHB_BURST_INCR16;
        end
        AHB_BURST_WRAP16 : begin
          hburst_mapped = AHB_BURST_INCR;
        end
        AHB_BURST_INCR16 : begin
          hburst_mapped = AHB_BURST_INCR16;
        end
        AHB_BURST_INCR : begin
          hburst_mapped = AHB_BURST_INCR;
        end
        AHB_BURST_SINGLE : begin
          hburst_mapped = AHB_BURST_INCR;
        end
        default: begin
          hburst_mapped = {3{1'bx}};
        end
      endcase
    end

  always @ (dsc_current_state or hburst_mapped or hburst_reg or hburst_s or htrans_reg or
            hburst_mapped_reg or hsize_s or hsize_reg or hsel_s or reg_seq_to_nseq or htrans_ds_in)
    begin : p_hburstm
      if (reg_seq_to_nseq & (ERR_BURST_BLOCK_ALL==1'b0) & (htrans_ds_in[0]|
          ((dsc_current_state == DS_FSM_DELAY) & htrans_reg[0])))
        begin
        hburst_m = AHB_BURST_INCR;
        end
      else if (dsc_current_state == DS_FSM_DELAY)
        begin
          if (hsize_reg == AHB_SIZE[2:0])
            begin
              hburst_m = hburst_mapped_reg;
            end
          else
            begin
              hburst_m = hburst_reg;
            end
        end
      else if (dsc_current_state == DS_FSM_CYC1)
        begin
          hburst_m = hburst_mapped_reg;
        end
      else
        begin
          if ((hsize_s == AHB_SIZE[2:0]) & hsel_s)
            begin
              hburst_m = hburst_mapped;
            end
          else
            begin
              hburst_m = hburst_s;
            end
        end
    end

  always @ (dsc_current_state or hprot_reg or hprot_s)
    begin : p_hprotm
      if ((dsc_current_state == DS_FSM_CYC1) | (dsc_current_state == DS_FSM_DELAY))
        begin
          hprot_m = hprot_reg;
        end
      else
        begin
          hprot_m = hprot_s;
        end
    end

  always @ (dsc_current_state or hwrite_reg or hwrite_s)
    begin : p_hwritem
      if ((dsc_current_state == DS_FSM_CYC1) | (dsc_current_state == DS_FSM_DELAY))
        begin
          hwrite_m = hwrite_reg;
        end
      else
        begin
          hwrite_m = hwrite_s;
        end
    end

  always @ (dsc_current_state or hmastlock_reg or hmastlock_s)
    begin : p_hmastlockm
      if ((dsc_current_state == DS_FSM_CYC1) | (dsc_current_state == DS_FSM_DELAY))
        begin
          hmastlock_m = hmastlock_reg;
        end
      else
        begin
          hmastlock_m = hmastlock_s;
        end
    end

  always @ (dsc_current_state or hnonsec_reg or hnonsec_s)
    begin : p_hnonsecm
      if ((dsc_current_state == DS_FSM_CYC1) | (dsc_current_state == DS_FSM_DELAY))
        begin
          hnonsec_m = hnonsec_reg;
        end
      else
        begin
          hnonsec_m = hnonsec_s;
        end
    end

  always @ (dsc_current_state or hexcl_reg or hexcl_s or hsize_reg or hsize_s)
    begin : p_hexclm
      if ((dsc_current_state == DS_FSM_CYC1) | (dsc_current_state == DS_FSM_DELAY))
        begin
          if (hsize_reg == AHB_SIZE[2:0])
            begin
              hexcl_m = 1'b0;
            end
          else
            begin
              hexcl_m = hexcl_reg;
            end
        end
      else
        begin
          if (hsize_s == AHB_SIZE[2:0])
            begin
              hexcl_m = 1'b0;
            end
          else
            begin
              hexcl_m = hexcl_s;
            end
        end
    end

  always @ (dsc_current_state or hauser_reg or hauser_s)
    begin : p_hauserm
      if ((dsc_current_state == DS_FSM_CYC1) | (dsc_current_state == DS_FSM_DELAY))
        begin
          hauser_m = hauser_reg;
        end
      else
        begin
          hauser_m = hauser_s;
        end
    end

  reg [2:0] i_hsize_m;
  always @ (dsc_current_state or hsize_s or hsize_reg)
    begin : p_hsizem
      if ((dsc_current_state == DS_FSM_CYC1) | (dsc_current_state == DS_FSM_DELAY))
        begin
          i_hsize_m = hsize_reg;
        end
      else
        begin
          i_hsize_m = hsize_s;
        end
    end
  assign hsize_m = (i_hsize_m == AHB_SIZE[2:0]) ? AHB_HALF_SIZE[2:0] : i_hsize_m;

  always @ (dsc_current_state or hmaster_reg or hmaster_s)
    begin : p_hmasterm
      if ((dsc_current_state == DS_FSM_CYC1) | (dsc_current_state == DS_FSM_DELAY))
        begin
          hmaster_m = hmaster_reg;
        end
      else
        begin
          hmaster_m = hmaster_s;
        end
    end


  assign s_not_sel_nxt = ((hsel_s & hready_s) ? 1'b0
                       : (((~hsel_s) & hready_s) ? 1'b1
                          : s_not_sel)
                       );

  assign m_not_sel_nxt = ((i_hsel_m & i_hready_m) ? 1'b0
                       : (((~i_hsel_m) & i_hready_m) ? 1'b1
                          : m_not_sel)
                       );

  always@(negedge hresetn or posedge hclk)
    begin : p_hreadyseq
      if (~hresetn)
        begin
          s_not_sel <= 1'b1;
          m_not_sel <= 1'b1;
        end
      else
        begin
          s_not_sel <= s_not_sel_nxt;
          m_not_sel <= m_not_sel_nxt;
        end
    end

  always @ (dsc_current_state or hreadyout_m or s_not_sel or m_not_sel)
    begin : p_hreadyouts
      if ((dsc_current_state == DS_FSM_DELAY) | (dsc_current_state == DS_FSM_CYC1))
        hready_ds_out = 1'b0;
      else if (s_not_sel | m_not_sel)
        hready_ds_out = 1'b1;
      else
        hready_ds_out = hreadyout_m;
    end

  always @ (dsc_current_state or hexokay_m or s_not_sel or m_not_sel)
    begin : p_hexokays
      if ((dsc_current_state == DS_FSM_DELAY) | (dsc_current_state == DS_FSM_CYC1) | (dsc_current_state == DS_FSM_CYC2))
        hexokay_ds_out = 1'b0;
      else if (s_not_sel | m_not_sel)
        hexokay_ds_out = 1'b0;
      else
        hexokay_ds_out = hexokay_m;
    end

  always @ (hresp_m or s_not_sel or m_not_sel)
    begin : p_hresps
      if (s_not_sel | m_not_sel)
        hresp_ds_out = 1'b0;
      else
        hresp_ds_out = hresp_m;
    end

  assign hruser_s = hruser_m;

  assign hwuser_m = hwuser_s;

  assign i_hready_m = (m_not_sel ? 1'b1 : hreadyout_m);

  assign hready_m  = i_hready_m;

  always @ (negedge hresetn or posedge hclk)
    begin : p_data_muxctrl
      if (~hresetn)
        begin
          fwd_mux_ctrl <= 1'b0;
        end
      else
        begin
          if (i_hready_m)
            begin
              if ((ENDIANNESS == 2) && ((DATA_WIDTH == 32) || (DATA_WIDTH == 16)))
                fwd_mux_ctrl <= ~i_haddr_m[AHB_HALF_SIZE];
              else
                fwd_mux_ctrl <= i_haddr_m[AHB_HALF_SIZE];
            end
        end
    end

  assign hwdata_m = (fwd_mux_ctrl ? hwdata_s[DATA_WIDTH-1:DATA_WIDTH/2] : hwdata_s[DATA_WIDTH/2-1:0]);

  always @ (hsize_s or htrans_ds_in)
    begin : p_readmuxcomb
      if ((hsize_s == AHB_SIZE[2:0]) &
          ((htrans_ds_in == AHB_TRANS_NONSEQ) | (htrans_ds_in == AHB_TRANS_SEQ))
          )
        begin
          next_frd_mux_ctrl = 1'b1;
        end
      else
        begin
          next_frd_mux_ctrl = 1'b0;
        end
    end

  always @ (posedge hclk or negedge hresetn)
    begin : p_readmuxseq
      if (~hresetn)
        begin
          frd_mux_ctrl <= 1'b0;
        end
      else
        begin
          if (hready_s)
            begin
              frd_mux_ctrl <= next_frd_mux_ctrl;
            end
        end
    end

  generate
    if(ENDIANNESS == 2) begin: WORD_BIG_ENDIAN
      assign hrdata_sel = ((DATA_WIDTH == 32) || (DATA_WIDTH == 16)) ?  1'b1 : 1'b0;
    end
    else begin : LITTLE_OR_BYTE_BIG_ENDIAN
      assign hrdata_sel = 1'b0;
    end
  endgenerate

  assign hrdata_s = (frd_mux_ctrl ?
                      (hrdata_sel ? {hrdata_reg,hrdata_m} :
                      {hrdata_m,hrdata_reg}) :
                    {hrdata_m,hrdata_m});

  always @ (posedge hclk or negedge hresetn)
    begin : p_hrdataseq
      if (~hresetn)
        hrdata_reg <= {DATA_WIDTH/2{1'b0}};
      else
        if (i_hready_m & ~hwrite_reg & htrans_reg[1])
          hrdata_reg <= hrdata_m;
    end

























endmodule

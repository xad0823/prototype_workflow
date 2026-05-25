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
//      Checked In          : Fri Dec 2 18:41:32 2016 +0000
//
//      Revision            : bcd3fa1
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_timeout_mon #(

  parameter ADDR_WIDTH      = 32,
  parameter DATA_WIDTH      = 32,
  parameter MASTER_WIDTH    = 4,
  parameter USER_WIDTH      = 1,
  parameter TIMEOUT_VALUE   = 16,
  parameter STRICT_AHB_COMP = 1
)
(
  input  wire                    hclk,
  input  wire                    hresetn,

  input  wire                    hsel_s,
  input  wire                    hnonsec_s,
  input  wire [ADDR_WIDTH-1:0]   haddr_s,
  input  wire [1:0]              htrans_s,
  input  wire [2:0]              hsize_s,
  input  wire                    hwrite_s,
  input  wire                    hready_s,
  input  wire [6:0]              hprot_s,
  input  wire [2:0]              hburst_s,
  input  wire                    hmastlock_s,
  input  wire [DATA_WIDTH-1:0]   hwdata_s,
  input  wire                    hexcl_s,
  input  wire [MASTER_WIDTH-1:0] hmaster_s,
  output wire [DATA_WIDTH-1:0]   hrdata_s,
  output wire                    hreadyout_s,
  output wire                    hresp_s,
  output wire                    hexokay_s,
  input  wire [USER_WIDTH-1:0]   hauser_s,
  input  wire [USER_WIDTH-1:0]   hwuser_s,
  output wire [USER_WIDTH-1:0]   hruser_s,


  output wire                    hsel_m,
  output wire                    hnonsec_m,
  output wire [ADDR_WIDTH-1:0]   haddr_m,
  output wire [1:0]              htrans_m,
  output wire [2:0]              hsize_m,
  output wire                    hwrite_m,
  output wire                    hready_m,
  output wire [6:0]              hprot_m,
  output wire [2:0]              hburst_m,
  output wire                    hmastlock_m,
  output wire [DATA_WIDTH-1:0]   hwdata_m,
  output wire                    hexcl_m,
  output wire [MASTER_WIDTH-1:0] hmaster_m,
  input  wire [DATA_WIDTH-1:0]   hrdata_m,
  input  wire                    hreadyout_m,
  input  wire                    hresp_m,
  input  wire                    hexokay_m,
  output wire [USER_WIDTH-1:0]   hauser_m,
  output wire [USER_WIDTH-1:0]   hwuser_m,
  input  wire [USER_WIDTH-1:0]   hruser_m,

  output wire                    timeout

);


  localparam CNT_WIDTH = (TIMEOUT_VALUE <= 16 ) ?  4 :
                         (TIMEOUT_VALUE <= 32 ) ?  5 :
                         (TIMEOUT_VALUE <= 64 ) ?  6 :
                         (TIMEOUT_VALUE <= 128) ?  7 :
                         (TIMEOUT_VALUE <= 256) ?  8 :
                         (TIMEOUT_VALUE <= 512) ?  9 :
                                                   10;



  reg                 s_dphase_q;
  reg [CNT_WIDTH-1:0] timeout_cnt_q;
  reg                 s_err_cyc2_q;


  always @(posedge hclk or negedge hresetn)
     if (~hresetn)
        s_dphase_q <= 1'b0;
     else if (hready_s)
        s_dphase_q <= hsel_s && htrans_s[1];


  wire timeout_cnt_en = s_dphase_q;

  wire [CNT_WIDTH  :0] timeout_cnt_plus1 = timeout_cnt_q + {{(CNT_WIDTH-2){1'b0}},1'b1};
  wire [CNT_WIDTH-1:0] timeout_cnt_nxt   = hready_s ? {CNT_WIDTH{1'b0}} : timeout_cnt_plus1[CNT_WIDTH-1:0];

  always @(posedge hclk or negedge hresetn)
     if (~hresetn)
        timeout_cnt_q <= {CNT_WIDTH{1'b0}};
     else if (timeout_cnt_en)
        timeout_cnt_q <= timeout_cnt_nxt;

  wire unused = timeout_cnt_plus1[CNT_WIDTH];

  wire [CNT_WIDTH-1:0] timeout_value_minus1 = TIMEOUT_VALUE[CNT_WIDTH-1:0] - {{(CNT_WIDTH-2){1'b0}},1'b1};
  wire timeout_cnt_max = timeout_cnt_q == timeout_value_minus1;


  wire timeout_set = ~timeout && timeout_cnt_max && ~hreadyout_m && ~hresp_m;

  wire timeout_clr = hready_m && hready_s && ~htrans_s[0];

  localparam TO_FSM_DELAY   = 2'b00;
  localparam TO_FSM_TRANSP  = 2'b01;
  localparam TO_FSM_TIMEOUT = 2'b10;
  localparam TO_FSM_UNUSED  = 2'b11;

  reg [1:0] fsm_timeout;

  always @(posedge hclk or negedge hresetn)
     if (~hresetn)
        fsm_timeout <= TO_FSM_TRANSP;
     else begin
       case (fsm_timeout)
         TO_FSM_TRANSP  : if (timeout_set) fsm_timeout <= TO_FSM_TIMEOUT;
         TO_FSM_DELAY   :                  fsm_timeout <= TO_FSM_TRANSP;
         TO_FSM_TIMEOUT : if (timeout_clr) if (htrans_s[1] && hsel_s) fsm_timeout <= TO_FSM_DELAY;
                                           else                       fsm_timeout <= TO_FSM_TRANSP;
         TO_FSM_UNUSED  :                  fsm_timeout <= TO_FSM_TRANSP;
         default        :                  fsm_timeout <= 2'bXX;
       endcase
     end



  wire hreadyout_s_timeout = ~s_dphase_q | s_err_cyc2_q;

  always @(posedge hclk or negedge hresetn)
     if (~hresetn)
        s_err_cyc2_q <= 1'b0;
     else if (fsm_timeout[1])
        s_err_cyc2_q <= s_dphase_q && ~s_err_cyc2_q;


  reg                    reg_hnonsec_s   ;
  reg [ADDR_WIDTH-1:0]   reg_haddr_s     ;
  reg [1:0]              reg_htrans_s    ;
  reg [2:0]              reg_hsize_s     ;
  reg                    reg_hwrite_s    ;
  reg [6:0]              reg_hprot_s     ;
  reg [2:0]              reg_hburst_s    ;
  reg                    reg_hmastlock_s ;
  reg                    reg_hexcl_s     ;
  reg [MASTER_WIDTH-1:0] reg_hmaster_s   ;
  reg [USER_WIDTH-1:0]   reg_hauser_s    ;

  always @(posedge hclk or negedge hresetn)
     if (~hresetn) begin
        reg_hnonsec_s   <= 1'b0;
        reg_haddr_s     <= {ADDR_WIDTH{1'b0}};
        reg_htrans_s    <= 2'b0;
        reg_hsize_s     <= 3'b0;
        reg_hwrite_s    <= 1'b0;
        reg_hprot_s     <= 7'b0;
        reg_hburst_s    <= 3'b0;
        reg_hmastlock_s <= 1'b0;
        reg_hexcl_s     <= 1'b0;
        reg_hmaster_s   <= {MASTER_WIDTH{1'b0}};
        reg_hauser_s    <= {USER_WIDTH{1'b0}};
     end
     else if (timeout_clr) begin
        reg_hnonsec_s   <= hnonsec_s  ;
        reg_haddr_s     <= haddr_s    ;
        reg_htrans_s    <= htrans_s   ;
        reg_hsize_s     <= hsize_s    ;
        reg_hwrite_s    <= hwrite_s   ;
        reg_hprot_s     <= hprot_s    ;
        reg_hburst_s    <= hburst_s   ;
        reg_hmastlock_s <= hmastlock_s;
        reg_hexcl_s     <= hexcl_s    ;
        reg_hmaster_s   <= hmaster_s  ;
        reg_hauser_s    <= hauser_s   ;
     end


  assign timeout = fsm_timeout[1];
  wire timeout_d = fsm_timeout == TO_FSM_DELAY;


  assign hsel_m          = ~timeout ? hsel_s   : 1'b0;
  assign hready_m        = ~timeout ? hready_s : hreadyout_m;

  generate
    if (STRICT_AHB_COMP == 1) begin : STRICT_AHB_COMP_1
      localparam HTRANS_IDLE = 2'b00;
      localparam HTRANS_NSEQ = 2'b10;
      assign hburst_m    = 3'b000;
      assign htrans_m    = timeout_d ?         ((reg_htrans_s[1] == 1'b1) && hready_m) ? HTRANS_NSEQ : HTRANS_IDLE
                                     : (~timeout && (htrans_s[1] == 1'b1) && hready_m) ? HTRANS_NSEQ : HTRANS_IDLE;

      reg [DATA_WIDTH-1:0] reg_hwdata_s;
      reg [USER_WIDTH-1:0] reg_hwuser_s;
      reg                  hready_m_d;

      always @(posedge hclk or negedge hresetn)
        if (~hresetn)
          hready_m_d <= 1'b0;
        else
          hready_m_d <= hready_m;

      always @(posedge hclk or negedge hresetn)
        if (~hresetn) begin
          reg_hwdata_s <= {DATA_WIDTH{1'b0}};
          reg_hwuser_s <= {USER_WIDTH{1'b0}};
        end
        else if (hready_m_d) begin
          reg_hwdata_s <= hwdata_s;
          reg_hwuser_s <= hwuser_s;
        end

      assign hwuser_m = timeout ? reg_hwuser_s : hwuser_s;
      assign hwdata_m = timeout ? reg_hwdata_s : hwdata_s;
    end
    else begin : STRICT_AHB_COMP_0
      localparam HTRANS_IDLE = 2'b00;
      assign hburst_m    = timeout_d ? reg_hburst_s : hburst_s;
      assign htrans_m    = timeout_d ? reg_htrans_s : ~timeout ? htrans_s : HTRANS_IDLE;

      assign hwuser_m    = hwuser_s;
      assign hwdata_m    = hwdata_s;
    end
  endgenerate


  assign hnonsec_m       = timeout_d ? reg_hnonsec_s   : hnonsec_s;
  assign haddr_m         = timeout_d ? reg_haddr_s     : haddr_s;
  assign hsize_m         = timeout_d ? reg_hsize_s     : hsize_s;
  assign hwrite_m        = timeout_d ? reg_hwrite_s    : hwrite_s;
  assign hprot_m         = timeout_d ? reg_hprot_s     : hprot_s;
  assign hmastlock_m     = timeout_d ? reg_hmastlock_s : hmastlock_s;
  assign hexcl_m         = timeout_d ? reg_hexcl_s     : hexcl_s;
  assign hmaster_m       = timeout_d ? reg_hmaster_s   : hmaster_s;
  assign hauser_m        = timeout_d ? reg_hauser_s    : hauser_s;

  assign hreadyout_s     = timeout_d ? 1'b0
                                     : ~timeout ? hreadyout_m : hreadyout_s_timeout;
  assign hresp_s         = ~timeout ? hresp_m     : s_dphase_q;
  assign hexokay_s       = ~timeout ? hexokay_m   : 1'b0;

  assign hrdata_s        = hrdata_m;
  assign hruser_s        = hruser_m;























endmodule

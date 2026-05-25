//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//          (C) COPYRIGHT 2010-2013,2015-2016 ARM Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Tue Oct 18 12:12:14 2016 +0100
//
//      Revision            : 6a90cbd
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------


module sie200_ahb5_to_ahb5_sync_core #(

  parameter       ADDR_WIDTH    = 32,
  parameter       DATA_WIDTH    = 32,
  parameter       MASTER_WIDTH  = 4,
  parameter       USER_WIDTH    = 1,
  parameter       BURST         = 0)
 (
  input  wire                    hclk,
  input  wire                    hresetn,

  input  wire                    hsel_s,
  input  wire [ADDR_WIDTH-1:0]   haddr_s,
  input  wire    [1:0]           htrans_s,
  input  wire    [2:0]           hsize_s,
  input  wire                    hwrite_s,
  input  wire                    hready_s,
  input  wire    [6:0]           hprot_s,
  input  wire [MASTER_WIDTH-1:0] hmaster_s,
  input  wire                    hmastlock_s,
  input  wire [DATA_WIDTH-1:0]   hwdata_s,
  input  wire    [2:0]           hburst_s,
  input  wire                    hnonsec_s,
  input  wire                    hexcl_s,
  input  wire [USER_WIDTH-1:0]   hauser_s,
  input  wire [USER_WIDTH-1:0]   hwuser_s,

  output wire                    hreadyout_s,
  output wire                    hresp_s,
  output wire [DATA_WIDTH-1:0]   hrdata_s,
  output wire                    hexokay_s,
  output wire [USER_WIDTH-1:0]   hruser_s,


  output wire [ADDR_WIDTH-1:0]   haddr_m,
  output wire   [1:0]            htrans_m,
  output wire   [2:0]            hsize_m,
  output wire                    hwrite_m,
  output wire   [6:0]            hprot_m,
  output wire [MASTER_WIDTH-1:0] hmaster_m,
  output wire                    hmastlock_m,
  output wire [DATA_WIDTH-1:0]   hwdata_m,
  output wire   [2:0]            hburst_m,
  output wire                    hnonsec_m,
  output wire                    hexcl_m,
  output wire [USER_WIDTH-1:0]   hauser_m,
  output wire [USER_WIDTH-1:0]   hwuser_m,

  input  wire                    hready_m,
  input  wire                    hresp_m,
  input  wire [DATA_WIDTH-1:0]   hrdata_m,
  input  wire                    hexokay_m,
  input  wire [USER_WIDTH-1:0]   hruser_m,

  input  wire                    hold_en,
  output wire                    pend_trans,
  input  wire                    cfg_gate_resp

);


  localparam      HSIZE_W   = (DATA_WIDTH > 64) ? 3 : 2;
  localparam      HSIZE_MAX = HSIZE_W - 1;



  localparam TRN_IDLE       = 2'b00;
  localparam TRN_BUSY       = 2'b01;
  localparam TRN_NONSEQ     = 2'b10;
  localparam TRN_SEQ        = 2'b11;

  localparam RESP_OKAY      = 1'b0;
  localparam RESP_ERR       = 1'b1;

  localparam BUR_SINGLE     = 3'b000;
  localparam BUR_INCR       = 3'b001;
  localparam BUR_WRAP4      = 3'b010;
  localparam BUR_INCR4      = 3'b011;
  localparam BUR_WRAP8      = 3'b100;
  localparam BUR_INCR8      = 3'b101;
  localparam BUR_WRAP16     = 3'b110;
  localparam BUR_INCR16     = 3'b111;

  localparam FSM_IDLE       = 4'b0100;
  localparam FSM_ADDR       = 4'b0001;
  localparam FSM_UNLOCK     = 4'b0000;
  localparam FSM_WAIT       = 4'b0010;
  localparam FSM_DONE       = 4'b0110;
  localparam FSM_ERR1       = 4'b1000;
  localparam FSM_ERR2       = 4'b1100;
  localparam FSM_HOLD       = 4'b0011;
  localparam FSM_UNUSED1    = 4'b0101;
  localparam FSM_UNUSED2    = 4'b0111;
  localparam FSM_UNUSED3    = 4'b1001;
  localparam FSM_UNUSED4    = 4'b1010;
  localparam FSM_UNUSED5    = 4'b1011;
  localparam FSM_UNUSED6    = 4'b1101;
  localparam FSM_UNUSED7    = 4'b1110;
  localparam FSM_UNUSED8    = 4'b1111;

  reg [ADDR_WIDTH-1:0]         haddr_reg;
  reg                          hwrite_reg;
  reg [HSIZE_MAX:0]            hsize_reg;
  reg    [6:0]                 hprot_reg;
  reg [MASTER_WIDTH-1:0]       hmaster_reg;
  reg                          hmastlock_reg;
  reg    [2:0]                 hburst_reg;
  reg    [1:0]                 hold_htrans_reg;
  reg [USER_WIDTH-1:0]         hold_hauser_reg;
  reg                          hnonsec_reg;
  reg                          hexcl_reg;
  reg [USER_WIDTH-1:0]         hauser_reg;
  reg                          hexokay_reg;


  reg [USER_WIDTH-1:0]         huser_reg;
  reg                          gating_with_err_reg;

  reg    [3:0]                 reg_fsm_state;
  reg    [3:0]                 nxt_fsm_state;

  wire                         trans_finish_addr;
  reg                          gating_with_err;

  reg  [DATA_WIDTH-1:0]        hdata_reg;
  wire [DATA_WIDTH-1:0]        nxt_hdata_reg;
  wire [USER_WIDTH-1:0]        nxt_huser_reg;

  wire                         data_update_read;
  wire                         data_update_write;
  wire                         data_update_both;


  wire [1:0]                   next_htransm;
  wire [USER_WIDTH-1:0]        next_hauserm;
  reg  [1:0]                   htransm_reg;
  wire                         trans_update;

  wire [1:0]                   htransm_canc;
  wire                         hreadyoutm_canc;
  wire                         hrespm_canc;


  reg      lock_trans_valid;
  wire     unlock_idle_valid;

  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
      lock_trans_valid   <= 1'b0;
    end
    else if (trans_finish_addr & hmastlock_s)
      begin
        lock_trans_valid   <= 1'b1;
      end
    else if (hready_s &((hsel_s & (~hmastlock_s)) | (~hsel_s)))
      begin
        lock_trans_valid   <= 1'b0;
      end
    end

  assign   unlock_idle_valid =  hready_s & lock_trans_valid & (((~hmastlock_s) & hsel_s)
                              | (~hsel_s));

  assign trans_finish_addr = hsel_s & htrans_s[1] & hready_s;

  always @(*) begin
    gating_with_err = gating_with_err_reg;
    if(reg_fsm_state == FSM_IDLE || reg_fsm_state == FSM_DONE || reg_fsm_state == FSM_ERR2) begin
      if(trans_finish_addr) begin
        if(!htrans_s[0] & ({lock_trans_valid, hmastlock_s} != 2'b11)) begin
          if(hold_en & cfg_gate_resp)
            gating_with_err = 1'b1;
          else
            gating_with_err = 1'b0;
        end
      end
    end
  end


  always @(*) begin
    case (reg_fsm_state)
      FSM_IDLE: begin
                  if(trans_finish_addr) begin
                    if(!htrans_s[0] & ({lock_trans_valid, hmastlock_s} != 2'b11)) begin
                      if(hold_en & cfg_gate_resp) begin
                        nxt_fsm_state     = FSM_ADDR;
                      end else if(hold_en & !cfg_gate_resp) begin
                        nxt_fsm_state     = FSM_HOLD;
                      end else if(unlock_idle_valid & !gating_with_err_reg) begin
                        nxt_fsm_state       = FSM_UNLOCK;
                      end else begin
                        nxt_fsm_state     = FSM_ADDR;
                      end
                    end else begin
                      nxt_fsm_state       = FSM_ADDR;
                    end
                  end else begin
                    nxt_fsm_state = FSM_IDLE;
                  end
                end
      FSM_HOLD: begin
                  nxt_fsm_state = (hold_en | !hready_m) ? FSM_HOLD : FSM_ADDR;
                end
      FSM_UNLOCK: begin
                  nxt_fsm_state = FSM_ADDR;
                end
      FSM_ADDR: begin
                  nxt_fsm_state = FSM_WAIT;
                end
      FSM_WAIT: begin
                  nxt_fsm_state = (hrespm_canc | gating_with_err_reg)  ? FSM_ERR1 :
                                  hreadyoutm_canc                      ? FSM_DONE :
                                                                         FSM_WAIT;
                end
      FSM_DONE: begin
                  if(trans_finish_addr) begin
                    if(!htrans_s[0] & ({lock_trans_valid, hmastlock_s} != 2'b11)) begin
                      if(hold_en & cfg_gate_resp) begin
                        nxt_fsm_state     = FSM_ADDR;
                      end else if(hold_en & !cfg_gate_resp) begin
                        nxt_fsm_state     = FSM_HOLD;
                      end else if(unlock_idle_valid & !gating_with_err_reg) begin
                        nxt_fsm_state       = FSM_UNLOCK;
                      end else begin
                        nxt_fsm_state     = FSM_ADDR;
                      end
                    end else begin
                      nxt_fsm_state       = FSM_ADDR;
                    end
                  end else begin
                    nxt_fsm_state = FSM_IDLE;
                  end
                end
      FSM_ERR1: begin
                   nxt_fsm_state = FSM_ERR2;
                end
      FSM_ERR2: begin
                  if(trans_finish_addr) begin
                    if(!htrans_s[0] & ({lock_trans_valid, hmastlock_s} != 2'b11)) begin
                      if(hold_en & cfg_gate_resp) begin
                        nxt_fsm_state     = FSM_ADDR;
                      end else if(hold_en & !cfg_gate_resp) begin
                        nxt_fsm_state     = FSM_HOLD;
                      end else if(unlock_idle_valid & !gating_with_err_reg) begin
                        nxt_fsm_state       = FSM_UNLOCK;
                      end else begin
                        nxt_fsm_state     = FSM_ADDR;
                      end
                    end else begin
                      nxt_fsm_state       = FSM_ADDR;
                    end
                  end else begin
                    nxt_fsm_state = FSM_IDLE;
                  end
                end
      FSM_UNUSED1,
      FSM_UNUSED2,
      FSM_UNUSED3,
      FSM_UNUSED4,
      FSM_UNUSED5,
      FSM_UNUSED6,
      FSM_UNUSED7,
      FSM_UNUSED8: nxt_fsm_state = FSM_IDLE;
      default : begin
                   nxt_fsm_state = 4'bxxxx;
                end
    endcase
  end

  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn)
      reg_fsm_state <= FSM_IDLE;
    else
      reg_fsm_state <= nxt_fsm_state;
  end

  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
      hsize_reg       <= { HSIZE_W{1'b0}};
      hwrite_reg      <=     1'b0;
      hprot_reg       <= { 7{1'b0}};
      hmaster_reg     <= { MASTER_WIDTH{1'b0}};
      hold_htrans_reg <= TRN_NONSEQ;
      hold_hauser_reg <= {USER_WIDTH{1'b0}};
      hnonsec_reg     <= 1'b0;
    end
    else if (trans_finish_addr ) begin
      hsize_reg       <= hsize_s[HSIZE_MAX:0];
      hwrite_reg      <= hwrite_s;
      hprot_reg       <= hprot_s;
      hmaster_reg     <= hmaster_s;
      hold_htrans_reg <= htrans_s;
      hold_hauser_reg <= hauser_s;
      hnonsec_reg     <= hnonsec_s;
    end
  end

  assign data_update_read  = (reg_fsm_state == FSM_WAIT) & (hwrite_reg==1'b0) & (hreadyoutm_canc==1'b1);
  assign data_update_write = (reg_fsm_state == FSM_ADDR) & (hwrite_reg==1'b1);
  assign data_update_both  = data_update_read | data_update_write;
  assign nxt_hdata_reg     = (data_update_write) ? hwdata_s : hrdata_m ;
  assign nxt_huser_reg     = (data_update_write) ? hwuser_s : hruser_m ;


  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
      hdata_reg <= {DATA_WIDTH{1'b0}};
      huser_reg <= {USER_WIDTH{1'b0}};
    end else if (data_update_both) begin
      hdata_reg <= nxt_hdata_reg;
      huser_reg <= nxt_huser_reg;
    end
  end

  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn)
      hmastlock_reg <= 1'b0;
    else if (unlock_idle_valid)
      hmastlock_reg <= 1'b0;
    else if (trans_finish_addr)
      hmastlock_reg <= hmastlock_s;
  end

  assign   trans_update = (nxt_fsm_state == FSM_ADDR);

  generate
  if (BURST == 1)
    begin: gen_burst_support


    sie200_ahb5_error_canc
      u_ahb5_err_canc
      (
        .hclk      (hclk),
        .hresetn   (hresetn),

        .htrans_s   (htransm_reg),

        .hreadyout_s (hreadyoutm_canc),
        .hresp_s    (hrespm_canc),

        .htrans_m   (htransm_canc),

        .hready_m   (hready_m),
        .hresp_m    (hresp_m)
      );

  wire     busy_override;
  wire     transm_addr_update;

  assign   busy_override = htrans_s[0] & hsel_s;




  assign  next_htransm  =  ((reg_fsm_state == FSM_HOLD & !trans_update) | gating_with_err)? TRN_IDLE :
                           (unlock_idle_valid & !gating_with_err_reg) ? TRN_IDLE :
                           trans_update       ? ((reg_fsm_state == FSM_UNLOCK | reg_fsm_state == FSM_HOLD)? hold_htrans_reg :htrans_s):
                           busy_override      ? TRN_BUSY:
                                                TRN_IDLE;

  assign  next_hauserm  =  trans_update       ? ((reg_fsm_state == FSM_UNLOCK | reg_fsm_state == FSM_HOLD)? hold_hauser_reg :hauser_s):
                                                hauser_reg;

  always @ (posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
      htransm_reg   <= TRN_IDLE;
      hauser_reg    <= {USER_WIDTH{1'b0}};
    end else if (hreadyoutm_canc) begin
      htransm_reg   <= next_htransm;
      hauser_reg    <= next_hauserm;
    end
  end

  assign htrans_m        = htransm_canc;

  assign transm_addr_update = (trans_finish_addr |
                              ((reg_fsm_state == FSM_ADDR) & busy_override)
                              );

  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
      haddr_reg     <= {ADDR_WIDTH{1'b0}};
      hexcl_reg     <= 1'b0;
    end else if (transm_addr_update) begin
      haddr_reg     <= haddr_s;
      hexcl_reg     <= hexcl_s;
    end
  end

  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
      hburst_reg    <= BUR_SINGLE;
    end else if (trans_finish_addr) begin
      hburst_reg    <= hburst_s;
    end
  end

  assign hburst_m = hburst_reg;

  end

  else begin: gen_no_burst_support
  assign  next_htransm  =  ((reg_fsm_state == FSM_HOLD & !trans_update) | gating_with_err)? TRN_IDLE :
                           (unlock_idle_valid & !gating_with_err_reg)  ? TRN_IDLE :
                           trans_update       ? ((reg_fsm_state == FSM_UNLOCK | reg_fsm_state == FSM_HOLD)? {hold_htrans_reg[1],1'b0} :{htrans_s[1],1'b0}):
                                                TRN_IDLE;

  assign  next_hauserm  =  trans_update       ? ((reg_fsm_state == FSM_UNLOCK | reg_fsm_state == FSM_HOLD)? hold_hauser_reg :hauser_s):
                                                hauser_reg;

  always @ (posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
      htransm_reg   <= TRN_IDLE;
      hauser_reg    <= {USER_WIDTH{1'b0}};
    end else if (hready_m) begin
      htransm_reg   <= next_htransm;
      hauser_reg    <= next_hauserm;
    end
  end

  assign htrans_m        = {htransm_reg[1], 1'b0};
  assign htransm_canc    = TRN_IDLE;

  assign hrespm_canc     = hresp_m;
  assign hreadyoutm_canc = hready_m;


  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
      haddr_reg     <= {ADDR_WIDTH{1'b0}};
      hexcl_reg     <= 1'b0;
    end else if (trans_finish_addr) begin
      haddr_reg     <= haddr_s;
      hexcl_reg     <= hexcl_s;
    end
  end

  assign  hburst_m    = BUR_SINGLE;

  end
  endgenerate

  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
      hexokay_reg <= 1'b0;
    end else if (hready_m & !hresp_m) begin
      hexokay_reg <= hexokay_m;
    end else begin
      hexokay_reg <= 1'b0;
    end
  end

  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
      gating_with_err_reg <= 1'b0;
    end else begin
      gating_with_err_reg <= gating_with_err;
    end
  end

  assign hreadyout_s   = reg_fsm_state[2];
  assign hresp_s       = reg_fsm_state[3];
  assign hrdata_s      = hdata_reg;

  assign haddr_m       = haddr_reg;
  assign hsize_m[2]    = (DATA_WIDTH > 64) ? hsize_reg[HSIZE_MAX] : 1'b0;
  assign hsize_m[1:0]  = hsize_reg[1:0];
  assign hwrite_m      = hwrite_reg;
  assign hprot_m       = hprot_reg;
  assign hmaster_m     = hmaster_reg;
  assign hmastlock_m   = (reg_fsm_state == FSM_HOLD | gating_with_err_reg) ? 1'b0 : hmastlock_reg;
  assign hwdata_m      = hdata_reg;
  assign hnonsec_m     = hnonsec_reg;
  assign hexcl_m       = hexcl_reg;
  assign hexokay_s     = hexokay_reg;
  assign hauser_m      = hauser_reg;
  assign hwuser_m      = huser_reg;
  assign hruser_s      = huser_reg;

  assign pend_trans = (!hreadyout_s) |
                      (hmastlock_s & lock_trans_valid & hsel_s) |
                      (hsel_s & (htrans_s == TRN_SEQ || htrans_s == TRN_BUSY));




















endmodule

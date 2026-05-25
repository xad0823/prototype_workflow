//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2017 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Mon Mar 6 17:17:13 2017 +0100
//
//      Revision            : 5038e91
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------


module sie200_ahb5_to_ahb5_ll_sync_down_core #(

 parameter ADDR_WIDTH    = 32,
 parameter DATA_WIDTH    = 32,
 parameter MASTER_WIDTH  = 4,
 parameter USER_WIDTH    = 1,
 parameter BURST         = 0
 )
(
  input  wire                    hclk,
  input  wire                    hresetn,
  input  wire                    hclk_en,

  input  wire                    hsel_s,
  input  wire                    hnonsec_s,
  input  wire [ADDR_WIDTH-1:0]   haddr_s,
  input  wire    [1:0]           htrans_s,
  input  wire    [2:0]           hsize_s,
  input  wire                    hwrite_s,
  input  wire                    hready_s,
  input  wire    [6:0]           hprot_s,
  input  wire    [2:0]           hburst_s,
  input  wire                    hmastlock_s,
  input  wire                    hexcl_s,
  input  wire [DATA_WIDTH-1:0]   hwdata_s,
  input  wire [MASTER_WIDTH-1:0] hmaster_s,
  input  wire [USER_WIDTH-1:0]   hauser_s,
  input  wire [USER_WIDTH-1:0]   hwuser_s,

  output wire [DATA_WIDTH-1:0]   hrdata_s,
  output wire                    hreadyout_s,
  output wire                    hresp_s,
  output wire                    hexokay_s,
  output wire [USER_WIDTH-1:0]   hruser_s,


  output wire                    hnonsec_m,
  output wire [ADDR_WIDTH-1:0]   haddr_m,
  output wire   [1:0]            htrans_m,
  output wire   [2:0]            hsize_m,
  output wire                    hwrite_m,
  output wire   [6:0]            hprot_m,
  output wire   [2:0]            hburst_m,
  output wire                    hmastlock_m,
  output wire [DATA_WIDTH-1:0]   hwdata_m,
  output wire                    hexcl_m,
  output wire [MASTER_WIDTH-1:0] hmaster_m,
  output wire [USER_WIDTH-1:0]   hauser_m,
  output wire [USER_WIDTH-1:0]   hwuser_m,

  input  wire [DATA_WIDTH-1:0]   hrdata_m,
  input  wire                    hready_m,
  input  wire                    hresp_m,
  input  wire                    hexokay_m,
  input  wire [USER_WIDTH-1:0]   hruser_m
  );



  localparam      HSIZE_W   = (DATA_WIDTH > 64) ? 3 : 2;
  localparam      HSIZE_MAX = HSIZE_W - 1;



  localparam TRN_IDLE    = 2'b00;
  localparam TRN_BUSY    = 2'b01;
  localparam TRN_NONSEQ  = 2'b10;
  localparam TRN_SEQ     = 2'b11;

  localparam RESP_OKAY   = 1'b0;
  localparam RESP_ERR    = 1'b1;

  localparam FSM_IDLE    = 3'b000;
  localparam FSM_SYNC    = 3'b001;
  localparam FSM_ADDR    = 3'b010;
  localparam FSM_WAIT    = 3'b011;
  localparam FSM_ERR1    = 3'b100;
  localparam FSM_ERR2    = 3'b101;
  localparam FSM_UNLOCK  = 3'b110;

  reg                     hold_hnonsec_reg;
  reg  [ADDR_WIDTH-1:0]   hold_haddr_reg;
  reg                     hold_htransbit0_reg;
  reg                     hold_hwrite_reg;
  reg  [HSIZE_MAX:0]      hold_hsize_reg;
  reg  [6:0]              hold_hprot_reg;
  reg  [MASTER_WIDTH-1:0] hold_hmaster_reg;
  reg                     hold_hmastlock_reg;
  reg                     hold_hexcl_reg;
  reg  [USER_WIDTH-1:0]   hold_hauser_reg;

  wire                    next_hnonsecm_reg;
  wire [ADDR_WIDTH-1:0]   next_haddrm_reg;
  wire                    next_hwritem_reg;
  wire [HSIZE_MAX:0]      next_hsizem_reg;
  wire [6:0]              next_hprotm_reg;
  wire [MASTER_WIDTH-1:0] next_hmasterm_reg;
  wire                    next_hmastlockm_reg;
  wire [1:0]              next_htransm_reg;
  wire                    next_hexclm_reg;
  wire [USER_WIDTH-1:0]   next_hauserm_reg;

  reg                     hnonsecm_reg;
  reg  [ADDR_WIDTH-1:0]   haddrm_reg;
  reg                     hwritem_reg;
  reg  [HSIZE_MAX:0]      hsizem_reg;
  reg  [6:0]              hprotm_reg;
  reg  [MASTER_WIDTH-1:0] hmasterm_reg;
  reg                     hmastlockm_reg;
  reg  [1:0]              htransm_reg;
  reg                     hexclm_reg;
  reg  [USER_WIDTH-1:0]   hauserm_reg;


  wire                    hreadyouts_comb;

  reg  [2:0]              reg_fsm_state;
  reg  [2:0]              nxt_fsm_state;
  wire                    trans_update;

  wire                    trans_req;
  wire                    trans_finish_addr;

  reg  [DATA_WIDTH-1:0]   hwdata_reg;
  reg  [USER_WIDTH-1:0]   hwuser_reg;
  wire                    data_update_write;

  reg                     addr_hold_reg;

  wire                    addr_m_changeable;

  wire  [1:0]             htransm_canc;
  wire                    hreadyoutm_canc;
  wire                    hrespm_canc;


  reg                    lock_trans_valid;
  wire                   unlocks_idle_valid;
  reg                    unlockm_idle_pending;
  wire                   unlockm_idle_valid;


  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
       lock_trans_valid   <= 1'b0;
    end
    else if (trans_finish_addr & hmastlock_s) begin
       lock_trans_valid   <= 1'b1;
    end
    else if (hready_s &((hsel_s & (~hmastlock_s)) | (~hsel_s))) begin
       lock_trans_valid   <= 1'b0;
    end
  end

  assign   unlocks_idle_valid =  hready_s & lock_trans_valid & (((~hmastlock_s) & hsel_s)
                                 | (~hsel_s));

  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
       unlockm_idle_pending  <= 1'b0;
    end
    else if (hclk_en) begin
       unlockm_idle_pending  <= 1'b0;
    end
    else if (unlocks_idle_valid) begin
       unlockm_idle_pending  <= 1'b1;
    end
  end

  assign unlockm_idle_valid = (unlocks_idle_valid | unlockm_idle_pending) ;



  assign trans_req          = hsel_s & htrans_s[1];

  assign trans_finish_addr  = trans_req & hready_s;



  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
        addr_hold_reg <= 1'b0;
    end
    else if (hclk_en) begin
      if ((~trans_finish_addr) & (~unlockm_idle_valid)) begin
        addr_hold_reg <= 1'b0;
      end
      else if ((trans_finish_addr) & (unlockm_idle_valid)) begin
        addr_hold_reg <= 1'b1;
      end
    end
    else if (trans_finish_addr) begin
        addr_hold_reg <= 1'b1;
    end
  end

  assign  addr_m_changeable = (hclk_en & ((htransm_reg == TRN_IDLE) | hreadyoutm_canc));




  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
       hold_hnonsec_reg    <= 1'b0;
       hold_haddr_reg      <= {ADDR_WIDTH{1'b0}};
       hold_htransbit0_reg <= 1'b0;
       hold_hsize_reg      <= {HSIZE_W{1'b0}};
       hold_hwrite_reg     <= 1'b0;
       hold_hprot_reg      <= {7{1'b0}};
       hold_hmaster_reg    <= {MASTER_WIDTH{1'b0}};
       hold_hmastlock_reg  <= 1'b0;
       hold_hexcl_reg      <= 1'b0;
       hold_hauser_reg     <= {USER_WIDTH{1'b0}};
    end
    else if (trans_finish_addr) begin
       hold_hnonsec_reg    <= hnonsec_s;
       hold_haddr_reg      <= haddr_s;
       hold_htransbit0_reg <= htrans_s[0];
       hold_hsize_reg      <= hsize_s[HSIZE_MAX:0];
       hold_hwrite_reg     <= hwrite_s;
       hold_hprot_reg      <= hprot_s;
       hold_hmaster_reg    <= hmaster_s;
       hold_hmastlock_reg  <= hmastlock_s;
       hold_hexcl_reg      <= hexcl_s;
       hold_hauser_reg     <= hauser_s;
    end
  end





  assign data_update_write = (reg_fsm_state == FSM_ADDR) & hold_hwrite_reg & (hclk_en & hreadyoutm_canc);

  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
      hwdata_reg <= {DATA_WIDTH{1'b0}};
      hwuser_reg <= {USER_WIDTH{1'b0}};
    end
    else if (data_update_write ) begin
      hwdata_reg <= hwdata_s;
      hwuser_reg <= hwuser_s;
    end
  end



  always @ * begin
    case (reg_fsm_state)
      FSM_IDLE:begin
                 nxt_fsm_state = ~trans_finish_addr ? FSM_IDLE   :
                                 unlockm_idle_valid ? FSM_UNLOCK :
                                 (hclk_en)          ? FSM_ADDR   :
                                                      FSM_SYNC;
               end
      FSM_UNLOCK:begin
                 nxt_fsm_state = (hclk_en & hreadyoutm_canc & (~hmastlockm_reg)) ? FSM_ADDR :
                                                                                   FSM_UNLOCK;
               end
      FSM_SYNC:begin
                 nxt_fsm_state = hclk_en ? FSM_ADDR :
                                           FSM_SYNC;
               end
      FSM_ADDR:begin
                 nxt_fsm_state = hclk_en ? FSM_WAIT :
                                           FSM_ADDR;
               end
      FSM_WAIT:begin
                 nxt_fsm_state = ~hclk_en           ? FSM_WAIT   :
                                 hrespm_canc        ? FSM_ERR1   :
                                 ~hreadyoutm_canc   ? FSM_WAIT   :
                                 ~trans_finish_addr ? FSM_IDLE   :
                                 unlockm_idle_valid ? FSM_UNLOCK :
                                                      FSM_ADDR;
                end
      FSM_ERR1:begin
                 nxt_fsm_state = FSM_ERR2;
               end
      FSM_ERR2:begin
                 nxt_fsm_state = ~trans_finish_addr  ? FSM_IDLE   :
                                  unlockm_idle_valid ? FSM_UNLOCK :
                                  hclk_en            ? FSM_ADDR   :
                                                       FSM_SYNC   ;
               end
      default : nxt_fsm_state = 3'bxxx;
    endcase
  end

  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn)
      reg_fsm_state <= FSM_IDLE;
    else
      reg_fsm_state <= nxt_fsm_state;
  end


generate
 if (BURST == 1) begin:gen_burst_support

  wire          busy_override;
  wire   [2:0]  next_hburstm_reg;
  reg    [2:0]  hburstm_reg;
  reg    [2:0]  hold_hburst_reg;

 always @(posedge hclk or negedge hresetn) begin
   if (~hresetn) begin
     hold_hburst_reg    <= {3{1'b0}};
   end
   else if (trans_finish_addr) begin
     hold_hburst_reg    <= hburst_s;
   end
 end


  assign   busy_override      = ( hsel_s & ((htrans_s== TRN_BUSY) | (htrans_s== TRN_SEQ))) ;


  assign   next_htransm_reg    =
                               unlockm_idle_valid ? TRN_IDLE :
                               trans_update       ? (addr_hold_reg ? {1'b1, hold_htransbit0_reg} : htrans_s) :
                               busy_override      ? TRN_BUSY :
                                                    TRN_IDLE;

  assign   next_haddrm_reg     =
                               trans_update       ? (addr_hold_reg ? hold_haddr_reg : haddr_s) :
                               busy_override      ? haddr_s    :
                                                    haddrm_reg;

  assign   next_hmastlockm_reg =
                               unlockm_idle_valid ? 1'b0               :
                               ~trans_update      ? hmastlockm_reg     :
                               addr_hold_reg      ? hold_hmastlock_reg :
                                                    hmastlock_s;

  assign   next_hburstm_reg    =
                               ~trans_update      ? hburstm_reg     :
                               addr_hold_reg      ? hold_hburst_reg :
                                                    hburst_s;

  assign htrans_m     = htransm_canc;


  always @(posedge hclk or negedge hresetn)  begin
    if (~hresetn)  begin
      hburstm_reg    <= {3{1'b0}};
    end
    else if (addr_m_changeable) begin
      hburstm_reg    <= next_hburstm_reg;
    end
  end

  assign hburst_m = hburstm_reg;

 end
 else  begin: gen_burst_not_support
   assign      next_haddrm_reg     =
                                     ~trans_update ? haddrm_reg     :
                                     addr_hold_reg ? hold_haddr_reg :
                                                     haddr_s;

   assign      next_hmastlockm_reg =
                                     unlockm_idle_valid ? 1'b0               :
                                     ~trans_update      ? hmastlockm_reg     :
                                     addr_hold_reg      ? hold_hmastlock_reg :
                                                          hmastlock_s;

   assign      next_htransm_reg    =
                                     unlockm_idle_valid ? TRN_IDLE :
                                     ~trans_update      ? TRN_IDLE :
                                                          TRN_NONSEQ;


   assign htrans_m      = htransm_canc;

   assign hburst_m      = 3'b000;
 end
endgenerate


  assign   trans_update  =  (trans_finish_addr | addr_hold_reg);

  assign   next_hnonsecm_reg =  addr_hold_reg     ? hold_hnonsec_reg  :
                                trans_finish_addr ? hnonsec_s         :
                                                    hnonsecm_reg;

  assign   next_hsizem_reg   =  addr_hold_reg     ? hold_hsize_reg      :
                                trans_finish_addr ? hsize_s[HSIZE_MAX:0]:
                                                    hsizem_reg;

  assign   next_hwritem_reg  =  addr_hold_reg     ? hold_hwrite_reg :
                                trans_finish_addr ? hwrite_s        :
                                                    hwritem_reg;

  assign   next_hprotm_reg   =  addr_hold_reg     ? hold_hprot_reg :
                                trans_finish_addr ? hprot_s        :
                                                    hprotm_reg;

  assign   next_hmasterm_reg =  addr_hold_reg     ? hold_hmaster_reg :
                                trans_finish_addr ? hmaster_s        :
                                                    hmasterm_reg;

  assign   next_hexclm_reg   =  addr_hold_reg     ? hold_hexcl_reg  :
                                trans_finish_addr ? hexcl_s         :
                                                    hexclm_reg;

  assign   next_hauserm_reg  =  addr_hold_reg     ? hold_hauser_reg :
                                trans_finish_addr ? hauser_s        :
                                                    hauserm_reg;




  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
      hnonsecm_reg   <= 1'b0;
      hsizem_reg     <= {HSIZE_W{1'b0}};
      hwritem_reg    <= 1'b0;
      hprotm_reg     <= {7{1'b0}};
      hmasterm_reg   <= {MASTER_WIDTH{1'b0}};
      htransm_reg    <= 2'b00;
      haddrm_reg     <= {ADDR_WIDTH{1'b0}};
      hexclm_reg     <= 1'b0;
      hauserm_reg    <= {USER_WIDTH{1'b0}};
    end
    else if (addr_m_changeable) begin
      hnonsecm_reg   <= next_hnonsecm_reg;
      hsizem_reg     <= next_hsizem_reg ;
      hwritem_reg    <= next_hwritem_reg;
      hprotm_reg     <= next_hprotm_reg ;
      hmasterm_reg   <= next_hmasterm_reg;
      htransm_reg    <= next_htransm_reg;
      haddrm_reg     <= next_haddrm_reg;
      hexclm_reg     <= next_hexclm_reg;
      hauserm_reg    <= next_hauserm_reg;
    end
  end



   always @(posedge hclk or negedge hresetn) begin
     if (~hresetn) begin
        hmastlockm_reg <= 1'b0;
     end
     else if (addr_m_changeable) begin
        hmastlockm_reg <= next_hmastlockm_reg;
     end
   end



  assign  hreadyouts_comb = ~(((reg_fsm_state == FSM_SYNC)  |
                               (reg_fsm_state == FSM_UNLOCK)|
                               (reg_fsm_state == FSM_ADDR)  |
                               (reg_fsm_state == FSM_ERR1))
                               | ((reg_fsm_state == FSM_WAIT) & (~(hclk_en & hreadyoutm_canc))));


  assign hreadyout_s   = hreadyouts_comb;
  assign hresp_s       = ((reg_fsm_state == FSM_ERR1) | (reg_fsm_state == FSM_ERR2)) ? RESP_ERR : RESP_OKAY;
  assign hrdata_s      = hrdata_m;
  assign hexokay_s     = hreadyouts_comb & hexokay_m;
  assign hruser_s      = hruser_m;

  assign haddr_m       = haddrm_reg ;
  assign hnonsec_m     = hnonsecm_reg;
  assign hsize_m[2]    = (DATA_WIDTH > 64) ? hsizem_reg[HSIZE_MAX] : 1'b0;
  assign hsize_m[1:0]  = hsizem_reg[1:0];
  assign hwrite_m      = hwritem_reg;
  assign hprot_m       = hprotm_reg;
  assign hmaster_m     = hmasterm_reg;
  assign hmastlock_m   = hmastlockm_reg;
  assign hwdata_m      = hwdata_reg;
  assign hexcl_m       = hexclm_reg;
  assign hauser_m      = hauserm_reg;
  assign hwuser_m      = hwuser_reg;


generate
   if (BURST == 1)  begin: gen_with_error_canc


    sie200_ahb5_ll_error_canc
     u_ahb5_ll_error_canc
     (
      .hclk       (hclk),
      .hclk_en    (hclk_en),
      .hresetn    (hresetn),
      .htrans_s   (htransm_reg),
      .hready_m   (hready_m),
      .hresp_m    (hresp_m),
      .hreadyout_s(hreadyoutm_canc),
      .hresp_s    (hrespm_canc),
      .htrans_m   (htransm_canc)
     );
   end
   else begin: gen_no_error_canc
     assign  hrespm_canc     = hresp_m;
     assign  hreadyoutm_canc = hready_m;
     assign  htransm_canc    = htransm_reg;
   end
endgenerate















































endmodule

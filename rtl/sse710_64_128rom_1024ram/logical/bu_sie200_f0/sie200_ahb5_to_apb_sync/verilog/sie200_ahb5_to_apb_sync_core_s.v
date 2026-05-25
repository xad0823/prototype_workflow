//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2012, 2015-2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Mon Nov 28 10:36:15 2016 +0000
//
//      Revision            : 8ced0ca
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------
module sie200_ahb5_to_apb_sync_core_s #(
    parameter ADDR_WIDTH     = 32,
    parameter MASTER_WIDTH   =  4,
    parameter REGISTER_WDATA =  0
  )
 (
  input  wire                             hclk,
  input  wire                             hresetn,

  input  wire                             hsel,
  input  wire            [ADDR_WIDTH-1:0] haddr,
  input  wire                       [1:0] htrans,
  input  wire                       [2:0] hsize,
  input  wire                       [3:0] hprot,
  input  wire                             hwrite,
  input  wire                             hready,
  input  wire                      [31:0] hwdata,
  input  wire                             hnonsec,
  input  wire          [MASTER_WIDTH-1:0] hmaster,

  output wire                             hreadyout,
  output wire                      [31:0] hrdata,
  output wire                             hresp,

  output wire                             apb_trnf_req,
  input  wire                             apb_trnf_ack,

  input  wire                             cfg_gate_resp,
  input  wire                             pslverr,

  input  wire                      [31:0] prdata_r,
  input  wire                             hold_en,
  output wire                             pend_trans,
  output wire                             s_active,
  output wire          [MASTER_WIDTH-1:0] pmaster,
  output wire            [ADDR_WIDTH-1:0] paddr,
  output wire                             pwrite,
  output wire                       [3:0] pstrb,
  output wire                       [2:0] pprot,
  output wire                      [31:0] pwdata
  );


  wire                   cfg_gate_resp_l;
  wire                   start_trnf;
  wire                   trn_nseq;

  reg            [2:0]   next_state_ahb;
  reg            [2:0]   state_reg_ahb;
  reg                    apb_trnf_req_int;

  reg                    sample_wdata;
  reg                    hreadyout_int;
  wire                   hwrite_l;
  wire           [3:0]   unused = {hprot[3:2],hsize[2],htrans[0]};
  reg  apb_trnf_ack_r;
  wire sample_wdata_set;
  wire sample_wdata_clr;
  wire reg_wdata_cfg;
  wire trnf_done;

  reg  hold_en_r;
  wire hold_en_l;
  reg  cfg_gate_resp_r;
  reg  pslverr_r;
  wire pslverr_valid;
  reg  pslverr_valid_r;

  reg            [31:0]   hwdata_r;
  reg  [ADDR_WIDTH-3:0]   paddr_r;
  reg  [ADDR_WIDTH-3:0]   paddr_r2;
  wire [ADDR_WIDTH-3:0]   paddr_l;
  reg                     hwrite_r;
  reg                     pwrite_r2;
  wire                    pwrite_l;
  reg            [3:0]    pstrb_r;
  wire           [3:0]    pstrb_l;
  wire           [3:0]    pstrb_nxt;
  reg            [2:0]    pprot_r;
  reg            [2:0]    pprot_r2;
  wire           [2:0]    pprot_nxt;
  wire           [2:0]    pprot_l;
  reg  [MASTER_WIDTH-1:0] hmaster_r;
  reg  [MASTER_WIDTH-1:0] hmaster_r2;
  wire [MASTER_WIDTH-1:0] hmaster_l;

  localparam TRN_NONSEQ            = 2'b10;


   localparam [2:0]  AHB_IDLE     = 3'b000;
   localparam [2:0]  AHB_REG_WD   = 3'b001;
   localparam [2:0]  AHB_WAIT1    = 3'b010;
   localparam [2:0]  AHB_WAIT2    = 3'b011;
   localparam [2:0]  AHB_ERR1     = 3'b100;
   localparam [2:0]  AHB_ERR2     = 3'b101;
   localparam [2:0]  AHB_HOLD     = 3'b110;


  always @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn)
      pslverr_r <= 1'b0;
    else
      pslverr_r <= pslverr;
  end

  assign pslverr_valid = pslverr & ~pslverr_r;

  always @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn)
      pslverr_valid_r <= 1'b0;
    else
      pslverr_valid_r <= pslverr_valid;
  end

  assign reg_wdata_cfg = (REGISTER_WDATA==0) ? 1'b0 : 1'b1;

   assign pend_trans = ~hreadyout_int &
                       ~(~pslverr_valid_r & (state_reg_ahb ==  AHB_ERR1)) |
                       (hsel & htrans[0] & ~(hold_en_r & cfg_gate_resp_r));

   assign trn_nseq  =  hsel & (htrans==TRN_NONSEQ)  & hready;


  always @(posedge hclk or negedge hresetn)
  begin
  if (~hresetn) begin
    hold_en_r <= 1'b0;
    cfg_gate_resp_r <= 1'b0;
  end
  else if (trn_nseq) begin
    hold_en_r <= hold_en;
    cfg_gate_resp_r <= cfg_gate_resp;
  end
  end

  assign hold_en_l       = trn_nseq ? hold_en : hold_en_r;
  assign cfg_gate_resp_l = trn_nseq ? cfg_gate_resp : cfg_gate_resp_r;

  assign start_trnf  =  hsel & htrans[1] & hready;

  always @(posedge hclk or negedge hresetn)
  begin
  if (~hresetn)
    apb_trnf_ack_r   <= 1'b0;
  else
    apb_trnf_ack_r  <= apb_trnf_ack;
  end

  assign sample_wdata_set = start_trnf & hwrite & reg_wdata_cfg;
  assign sample_wdata_clr = apb_trnf_ack_r;

  assign trnf_done = apb_trnf_ack & ~apb_trnf_ack_r;

  always @(posedge hclk or negedge hresetn)
  begin
  if (~hresetn) begin
    sample_wdata <= 1'b0;
  end
  else if (sample_wdata_set)
    sample_wdata <= 1'b1;
  else if (sample_wdata_clr)
    sample_wdata <= 1'b0;
  end

  always @(*)
    begin
      case (state_reg_ahb)
        AHB_IDLE :
        begin
              if (start_trnf) begin
                if (hold_en_l) begin
                  apb_trnf_req_int  = 1'b0;
                  if (cfg_gate_resp_l) begin
                  next_state_ahb = AHB_ERR1;
                  end
                  else begin
                  next_state_ahb = AHB_HOLD;
                  end
                end
                else begin
                  if (reg_wdata_cfg & hwrite_l) begin
                    next_state_ahb = AHB_REG_WD;
                    apb_trnf_req_int  = 1'b0;
                  end
                  else begin
                    next_state_ahb = AHB_WAIT1;
                    apb_trnf_req_int  = 1'b1;
                  end
                end
              end
              else begin
                next_state_ahb = AHB_IDLE;
                apb_trnf_req_int  = 1'b0;
              end
        end
        AHB_HOLD:
        begin
              if (~hold_en & (reg_wdata_cfg & hwrite_l)) begin
                next_state_ahb = AHB_REG_WD;
                apb_trnf_req_int  = 1'b0;
              end
              else if (~hold_en & ~(reg_wdata_cfg & hwrite_l)) begin
                next_state_ahb = AHB_WAIT1;
                apb_trnf_req_int  = 1'b1;
              end
              else begin
                next_state_ahb = AHB_HOLD;
                apb_trnf_req_int  = 1'b0;
              end
        end
        AHB_REG_WD :
        begin
              next_state_ahb = AHB_WAIT1;
              apb_trnf_req_int  = 1'b1;
        end
        AHB_WAIT1 :
        begin
              next_state_ahb = AHB_WAIT2;
              apb_trnf_req_int  = 1'b1;
        end
        AHB_WAIT2 :
              begin
                if (trnf_done) begin
                  if (pslverr_valid) begin
                     next_state_ahb = AHB_ERR1;
                     apb_trnf_req_int  = 1'b0;
                  end
                  else if (start_trnf) begin
                    if (hold_en_l) begin
                      apb_trnf_req_int  = 1'b0;
                      if (cfg_gate_resp_l) begin
                         next_state_ahb = AHB_ERR1;
                      end
                      else begin
                         next_state_ahb = AHB_HOLD;
                      end
                    end
                    else begin
                      if (reg_wdata_cfg &  hwrite_l) begin
                        next_state_ahb = AHB_REG_WD;
                        apb_trnf_req_int  = 1'b0;
                      end
                      else begin
                         next_state_ahb = AHB_WAIT1;
                         apb_trnf_req_int  = 1'b1;
                      end
                    end
                  end
                  else begin
                    next_state_ahb = AHB_IDLE;
                    apb_trnf_req_int  = 1'b0;
                  end
                end
                else begin
                   next_state_ahb = AHB_WAIT2;
                   apb_trnf_req_int  = 1'b1;
                end
              end
        AHB_ERR1 :
              begin
                apb_trnf_req_int  = 1'b0;
                next_state_ahb = AHB_ERR2;
              end
        AHB_ERR2 :
              begin
                if (start_trnf) begin
                  if (hold_en_l) begin
                    apb_trnf_req_int  = 1'b0;
                    if (cfg_gate_resp_l) begin
                    next_state_ahb = AHB_ERR1;
                    end
                    else begin
                    next_state_ahb = AHB_HOLD;
                    end
                  end
                  else begin
                    if (reg_wdata_cfg & hwrite_l) begin
                      next_state_ahb = AHB_REG_WD;
                      apb_trnf_req_int  = 1'b0;
                    end
                    else begin
                      next_state_ahb = AHB_WAIT1;
                      apb_trnf_req_int  = 1'b1;
                    end
                  end
                end
                else begin
                  next_state_ahb = AHB_IDLE;
                  apb_trnf_req_int  = 1'b0;
                end
              end
        default :
        begin
          next_state_ahb = 3'bxxx;
          apb_trnf_req_int  = 1'b0;
        end
      endcase
  end

  always @(posedge hclk or negedge hresetn)
  begin
  if (~hresetn)
    state_reg_ahb <= AHB_IDLE;
  else
    state_reg_ahb <= next_state_ahb;
  end

  assign s_active   = pend_trans | start_trnf &
                      ((state_reg_ahb == AHB_IDLE)   | (state_reg_ahb == AHB_ERR2) |
                      (state_reg_ahb == AHB_WAIT2)) &
                      (~hold_en_l | (hold_en_l & ~cfg_gate_resp_l));

  always @(posedge hclk or negedge hresetn)
  begin
  if (~hresetn)
    begin
      hwrite_r      <= 1'b0;
    end
  else if (start_trnf)
    begin
      hwrite_r    <= hwrite;
    end
  end
  assign hwrite_l = start_trnf ? hwrite : hwrite_r;


  always @(posedge hclk or negedge hresetn)
  begin
  if (~hresetn)
    hwdata_r <= {32{1'b0}};
  else
    if (sample_wdata & reg_wdata_cfg)
      hwdata_r <= hwdata;
  end

  always @(*)
  begin
    case (state_reg_ahb)
      AHB_IDLE      : hreadyout_int = 1'b1;
      AHB_HOLD      : hreadyout_int = 1'b0;
      AHB_REG_WD    : hreadyout_int = 1'b0;
      AHB_WAIT1     : hreadyout_int = 1'b0;
      AHB_WAIT2     : hreadyout_int = (~pslverr_valid  & trnf_done) ? 1'b1 : 1'b0;
      AHB_ERR1      : hreadyout_int = 1'b0;
      AHB_ERR2      : hreadyout_int = 1'b1;
      default       : hreadyout_int = 1'bx;
    endcase
  end
  assign hreadyout = hreadyout_int;
  assign apb_trnf_req = apb_trnf_req_int & ~hold_en;
  assign hresp  = (state_reg_ahb==AHB_ERR1) | (state_reg_ahb==AHB_ERR2);

  assign pprot_nxt[0] =  hprot[1];
  assign pprot_nxt[1] =  hnonsec;
  assign pprot_nxt[2] = ~hprot[0];

  assign pstrb_nxt[0] = hwrite & ((hsize[1])|((hsize[0])&(~haddr[1]))|(haddr[1:0]==2'b00));
  assign pstrb_nxt[1] = hwrite & ((hsize[1])|((hsize[0])&(~haddr[1]))|(haddr[1:0]==2'b01));
  assign pstrb_nxt[2] = hwrite & ((hsize[1])|((hsize[0])&( haddr[1]))|(haddr[1:0]==2'b10));
  assign pstrb_nxt[3] = hwrite & ((hsize[1])|((hsize[0])&( haddr[1]))|(haddr[1:0]==2'b11));

  always @(posedge hclk or negedge hresetn)
  begin
  if (~hresetn)
    begin
      paddr_r    <= {(ADDR_WIDTH-2){1'b0}};
      pprot_r   <= {3{1'b0}};
      pstrb_r   <= {4{1'b0}};
      hmaster_r <= {(MASTER_WIDTH){1'b0}};
    end
  else if (start_trnf)
    begin
      paddr_r     <= haddr[ADDR_WIDTH-1:2];
      pprot_r     <= pprot_nxt;
      pstrb_r     <= pstrb_nxt;
      hmaster_r   <= hmaster;
    end
  end

  always @(posedge hclk or negedge hresetn)
  begin
  if (~hresetn) begin
    pwrite_r2  <= 1'b0;
    paddr_r2   <= {(ADDR_WIDTH-2){1'b0}};
    pprot_r2   <= {3{1'b0}};
    hmaster_r2 <= {(MASTER_WIDTH){1'b0}};
  end
  else if (apb_trnf_req) begin
    pwrite_r2  <= hwrite_r;
    paddr_r2   <= paddr_r;
    pprot_r2   <= pprot_r;
    hmaster_r2 <= hmaster_r;
  end
  end

  assign hrdata   = prdata_r;

  assign pwrite_l  = apb_trnf_ack ? pwrite_r2  : hwrite_r;
  assign paddr_l   = apb_trnf_ack ? paddr_r2   : paddr_r;
  assign pprot_l   = apb_trnf_ack ? pprot_r2   : pprot_r;


  assign hmaster_l = apb_trnf_ack ? hmaster_r2 : hmaster_r;


  assign paddr   = {paddr_l, 2'b00};
  assign pwrite  = pwrite_l;
  assign pprot   = pprot_l;
  assign pstrb   = pstrb_r;
  assign pmaster = hmaster_l;

  assign pwdata[7:0]     = reg_wdata_cfg ? {8{pstrb[0]}} & hwdata_r[7:0]   : {8{pstrb[0]}} & hwdata[7:0];
  assign pwdata[15:8]    = reg_wdata_cfg ? {8{pstrb[1]}} & hwdata_r[15:8]  : {8{pstrb[1]}} & hwdata[15:8];
  assign pwdata[23:16]   = reg_wdata_cfg ? {8{pstrb[2]}} & hwdata_r[23:16] : {8{pstrb[2]}} & hwdata[23:16];
  assign pwdata[31:24]   = reg_wdata_cfg ? {8{pstrb[3]}} & hwdata_r[31:24] : {8{pstrb[3]}} & hwdata[31:24];







endmodule


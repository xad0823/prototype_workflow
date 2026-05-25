//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2012, 2017 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Mon Mar 20 08:52:34 2017 +0000
//
//      Revision            : b65e8aa
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_to_apb_ll_sync #(
  parameter     ADDR_WIDTH     = 32,
  parameter     MASTER_WIDTH   = 4,
  parameter     REGISTER_RDATA = 1,
  parameter     REGISTER_WDATA = 0,
  parameter     REGISTER_CNTRL = 1)
 (

  input  wire                    hclk,
  input  wire                    hresetn,
  input  wire                    pclk_en,
  output wire                    apb_active,

  input  wire                    hsel,
  input  wire                    hnonsec,
  input  wire   [ADDR_WIDTH-1:0] haddr,
  input  wire              [1:0] htrans,
  input  wire              [2:0] hsize,
  input  wire                    hwrite,
  input  wire                    hready,
  input  wire              [6:0] hprot,
  input  wire             [31:0] hwdata,
  input  wire [MASTER_WIDTH-1:0] hmaster,

  output wire             [31:0] hrdata,
  output reg                     hreadyout,
  output wire                    hresp,
  output wire                    psel,
  output wire                    penable,
  output wire [ADDR_WIDTH-1:0]   paddr,
  output wire                    pwrite,
  output wire              [3:0] pstrb,
  output wire              [2:0] pprot,
  output wire             [31:0] pwdata,
  output wire [MASTER_WIDTH-1:0] pmaster,


  input  wire             [31:0] prdata,
  input  wire                    pready,
  input  wire                    pslverr);

   localparam REG_CNTRL_I = REGISTER_CNTRL > 1 ? REGISTER_WDATA : REGISTER_CNTRL;


  reg            [2:0]   state_reg;

  wire           [3:0]   pstrb_nxt;
  wire           [2:0]   pprot_nxt;

  reg  [ADDR_WIDTH-3:0]  addr_reg;
  reg                    wr_reg;
  reg            [3:0]   pstrb_reg;
  reg            [2:0]   pprot_reg;
  reg [MASTER_WIDTH-1:0] pmaster_reg;

  wire                   apb_select;
  wire                   apb_tran_end;
  reg            [2:0]   next_state;
  reg           [31:0]   rwdata_reg;

  wire                   reg_rdata_cfg;
  wire                   reg_wdata_cfg;
  wire                   reg_cntrl_cfg;

  reg                    sample_wdata_reg;

  wire           [6:0]   unused = {hprot[6:2],hsize[2],htrans[0]};

  reg                    pclk_en_r;
  wire                   pclk_en_d;


   localparam ST_BITS = 3;

   localparam [ST_BITS-1:0] ST_IDLE      = 3'b000;
   localparam [ST_BITS-1:0] ST_WAIT      = 3'b001;
   localparam [ST_BITS-1:0] ST_TRNF      = 3'b010;
   localparam [ST_BITS-1:0] ST_TRNF2     = 3'b011;
   localparam [ST_BITS-1:0] ST_ENDOK     = 3'b100;
   localparam [ST_BITS-1:0] ST_ERR1      = 3'b101;
   localparam [ST_BITS-1:0] ST_ERR2      = 3'b110;
   localparam [ST_BITS-1:0] ST_ILLEGAL   = 3'b111;

  assign reg_rdata_cfg = (REGISTER_RDATA==0) ? 1'b0 : 1'b1;
  assign reg_wdata_cfg = (REGISTER_WDATA==0) ? 1'b0 : 1'b1;
  assign reg_cntrl_cfg = (REG_CNTRL_I   ==0) ? 1'b0 : 1'b1;

  generate
  if (REG_CNTRL_I == 0)
  begin : pclk_en_delayed
    always @(posedge hclk or negedge hresetn)
    begin
    if (~hresetn)
      pclk_en_r   <= 1'b1;
    else
      pclk_en_r   <= pclk_en;
    end

    assign pclk_en_d = pclk_en_r;
  end
  else
  begin : no_pclk_en_delayed
    assign pclk_en_d = 1'b0;
  end
  endgenerate

  assign apb_select = hsel & htrans[1] & hready;
  assign apb_tran_end = (state_reg==3'b011) & pready;

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
      addr_reg    <= {(ADDR_WIDTH-2){1'b0}};
      wr_reg      <= 1'b0;
      pprot_reg   <= {3{1'b0}};
      pstrb_reg   <= {4{1'b0}};
      pmaster_reg <= {MASTER_WIDTH{1'b0}};
    end
  else if (apb_select)
    begin
      addr_reg    <= haddr[ADDR_WIDTH-1:2];
      wr_reg      <= hwrite;
      pprot_reg   <= pprot_nxt;
      pstrb_reg   <= pstrb_nxt;
      pmaster_reg <= hmaster;
    end
  end

  wire sample_wdata_set = apb_select & hwrite & reg_wdata_cfg;
  wire sample_wdata_clr = sample_wdata_reg & pclk_en;

  always @(posedge hclk or negedge hresetn)
  begin
  if (~hresetn)
    sample_wdata_reg <= 1'b0;
  else if (sample_wdata_set | sample_wdata_clr)
    sample_wdata_reg <= sample_wdata_set;
  end

  always @(state_reg or pready or pslverr or apb_select or
           pclk_en or hwrite or pwrite or pclk_en_d or
           reg_rdata_cfg or reg_wdata_cfg or reg_cntrl_cfg)
    begin
    case (state_reg)
     ST_IDLE :
     begin

        if (apb_select)
           if (~reg_cntrl_cfg && pclk_en_d & ~hwrite)
             if (pclk_en)
                next_state = ST_TRNF2;
             else
                 next_state = ST_TRNF;
           else
             if (pclk_en & apb_select & ~(reg_wdata_cfg & hwrite))
                next_state = ST_TRNF;
             else
                next_state = ST_WAIT;
        else
           next_state = ST_IDLE;

     end
     ST_WAIT :
     begin
        if (pclk_en)
           next_state = ST_TRNF;
        else
           next_state = ST_WAIT;
     end
     ST_TRNF :
     begin
        if (pclk_en)
           next_state = ST_TRNF2;
        else
           next_state = ST_TRNF;
     end
     ST_TRNF2 :
     begin
        if (pready & pslverr & pclk_en)
           next_state = ST_ERR1;
        else if (pready & (~pslverr) & pclk_en)
        begin
           if (reg_rdata_cfg & (~pwrite))
              next_state = ST_ENDOK;
           else
              if (pclk_en & apb_select & ~(reg_wdata_cfg & hwrite))
                 next_state = ST_TRNF;
              else if (apb_select)
                 next_state = ST_WAIT;
              else
                 next_state = ST_IDLE;
        end
        else
           next_state = ST_TRNF2;
     end
     ST_ENDOK :
     begin
       if (apb_select)
           if (~reg_cntrl_cfg && pclk_en_d & ~hwrite)
             if (pclk_en)
                next_state = ST_TRNF2;
             else
                 next_state = ST_TRNF;
           else
             if (pclk_en & apb_select & ~(reg_wdata_cfg & hwrite))
                next_state = ST_TRNF;
             else
                next_state = ST_WAIT;
        else
           next_state = ST_IDLE;

     end
     ST_ERR1 : next_state = ST_ERR2;
     ST_ERR2 :
     begin
       if (apb_select)
           if (~reg_cntrl_cfg && pclk_en_d & ~hwrite)
             if (pclk_en)
                next_state = ST_TRNF2;
             else
                 next_state = ST_TRNF;
           else
             if (pclk_en & apb_select & ~(reg_wdata_cfg & hwrite))
                next_state = ST_TRNF;
             else
                next_state = ST_WAIT;
        else
           next_state = ST_IDLE;
     end
     default :
            next_state = 3'bxxx;
    endcase
    end

  always @(posedge hclk or negedge hresetn)
  begin
  if (~hresetn)
    state_reg <= 3'b000;
  else
    state_reg <= next_state;
  end

  always @(posedge hclk or negedge hresetn)
  begin
  if (~hresetn)
    rwdata_reg <= {32{1'b0}};
  else
    if (sample_wdata_reg & reg_wdata_cfg & pclk_en)
      rwdata_reg <= hwdata;
    else if (apb_tran_end & reg_rdata_cfg & pclk_en)
      rwdata_reg <= prdata;
  end


  generate
  if (REG_CNTRL_I == 0)
  begin : direct_control
    wire direct_tr;
    assign direct_tr = (~REG_CNTRL_I && pclk_en_d && apb_select & ~hwrite) && (state_reg==ST_IDLE | state_reg==ST_ENDOK | state_reg==ST_ERR2);

    assign paddr[1:0] = 2'b00;
    sie200_mux #(.DATA_WIDTH(ADDR_WIDTH-2) ) u_paddr_mux   ( .in_a(addr_reg),          .in_b(haddr[ADDR_WIDTH-1:2]),          .sel(direct_tr), .out_y(paddr[ADDR_WIDTH-1:2]) );
    sie200_mux                               u_pwrite_mux  ( .in_a(wr_reg),            .in_b(hwrite),                         .sel(direct_tr), .out_y(pwrite) );

    assign psel    = (state_reg==ST_TRNF) | (state_reg==ST_TRNF2) | direct_tr;
    assign penable = (state_reg==ST_TRNF2);
    sie200_mux #(.DATA_WIDTH(           3) ) u_pprot_mux   ( .in_a(pprot_reg),         .in_b(pprot_nxt),                      .sel(direct_tr), .out_y(pprot) );
    sie200_mux #(.DATA_WIDTH(           4) ) u_pstrb_mux   ( .in_a(pstrb_reg[3:0]),    .in_b(pstrb_nxt),                      .sel(direct_tr), .out_y(pstrb) );
    sie200_mux #(.DATA_WIDTH(MASTER_WIDTH) ) u_pmaster_mux ( .in_a(pmaster_reg),       .in_b(hmaster),                        .sel(direct_tr), .out_y(pmaster) );
  end
  else
  begin : registered_control
    assign paddr   = {addr_reg, 2'b00};
    assign pwrite  = wr_reg;

    assign psel    = (state_reg==ST_TRNF) | (state_reg==ST_TRNF2);
    assign penable = (state_reg==ST_TRNF2);
    assign pprot   = pprot_reg;
    assign pstrb   = pstrb_reg[3:0];
    assign pmaster = pmaster_reg;
  end
  endgenerate

  assign pwdata  = (reg_wdata_cfg) ? rwdata_reg : hwdata;

  always @(state_reg or reg_rdata_cfg or pready or pslverr or pclk_en)
  begin
    case (state_reg)
      ST_IDLE      : hreadyout = 1'b1;
      ST_WAIT  : hreadyout = 1'b0;
      ST_TRNF  : hreadyout = 1'b0;
      ST_TRNF2 : hreadyout = (~reg_rdata_cfg) & pready & (~pslverr) & pclk_en;
      ST_ENDOK : hreadyout = reg_rdata_cfg;
      ST_ERR1  : hreadyout = 1'b0;
      ST_ERR2  : hreadyout = 1'b1;
      default: hreadyout = 1'bx;
    endcase
  end

  assign hrdata = (reg_rdata_cfg) ? rwdata_reg : prdata;
  assign hresp  = (state_reg==ST_ERR1) | (state_reg==ST_ERR2);

  assign apb_active = (hsel & htrans[1]) | (|state_reg);













endmodule

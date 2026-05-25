//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2010-2014, 2016-2017, 2019-2020 Arm Limited or its affiliates.
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
//   Sub-module of css600_axiap
//
//----------------------------------------------------------------------------


module css600_axiap_aximstr #(parameter
  AXI_ADDR_WIDTH        = 32,
  AXI_DATA_WIDTH        = 32,
  AXI_WSTRB_WIDTH       = 4,
  MTE_PRESENT           = 0,
  MTE_TAG_WIDTH         = 4,
  MTE_TAG_GRANULE       = 4
)
(
  clk,
  reset_n,

  awtagop,
  awaddr,
  awlen,
  awsize,
  awburst,
  awlock,
  awcache,
  awprot,
  awvalid,
  awready,

  wtagupdate,
  wtag,
  wdata,
  wstrb,
  wlast,
  wvalid,
  wready,

  bready,
  bresp,
  bvalid,

  artagop,
  araddr,
  arlen,
  arsize,
  arburst,
  arlock,
  arcache,
  arprot,
  arvalid,
  arready,

  rready,
  rtag,
  rdata,
  rresp,
  rlast,
  rvalid,


  awdomain,
  awsnoop,

  ardomain,
  arsnoop,

  mstr_tr_in_prog,
  mstr_tr_done,
  mstr_err,
  ap0_dword_inc,
  ap1_dword_inc,

  bd_sel,
  bd_dar_access,
  drw_sel,
  dar_sel,
  mstr_mte,
  mstr_wtag,
  mstr_rtag,
  mstr_rtag_transfer,
  mstr_tr_req,
  mstr_csw_req,
  mstr_nrd_wr,
  boss_twin,

  mstr_addr,
  mstr_size,
  mstr_cache,
  mstr_prot,
  mstr_ace_domain,

  mstr_rd_data,
  abort_req,


  pwdata,
  paddr_12
);

  localparam L_BUF_WIDTH       = (AXI_DATA_WIDTH      == 128) ? 64
                               : (AXI_DATA_WIDTH      == 64 ) ? 64
                               :                                32
                               ;
  localparam L_WTAGSROBE_WIDTH = (MTE_TAG_WIDTH/4)
                               ;

  input  wire                         clk;
  input  wire                         reset_n;

  output wire [1:0]                   awtagop;
  output wire [AXI_ADDR_WIDTH-1:0]    awaddr;
  output reg  [7:0]                   awlen;
  output wire [2:0]                   awsize;
  output wire [1:0]                   awburst;
  output reg                          awlock;
  output reg  [3:0]                   awcache;
  output reg  [2:0]                   awprot;
  output reg                          awvalid;
  input  wire                         awready;

  output wire [(MTE_TAG_WIDTH/4)-1:0] wtagupdate;
  output wire [MTE_TAG_WIDTH-1:0]     wtag;
  output wire [AXI_DATA_WIDTH-1:0]    wdata;
  output reg  [AXI_WSTRB_WIDTH-1:0]   wstrb;
  output wire                         wlast;
  output reg                          wvalid;
  input  wire                         wready;

  output wire                         bready;
  input  wire  [1:0]                  bresp;
  input  wire                         bvalid;

  output wire [1:0]                   artagop;
  output wire [AXI_ADDR_WIDTH-1:0]    araddr;
  output reg  [7:0]                   arlen;
  output wire [2:0]                   arsize;
  output wire [1:0]                   arburst;
  output reg                          arlock;
  output reg  [3:0]                   arcache;
  output reg  [2:0]                   arprot;
  output reg                          arvalid;
  input  wire                         arready;

  output wire                         rready;
  input  wire [MTE_TAG_WIDTH-1:0]     rtag;
  input  wire [AXI_DATA_WIDTH-1:0]    rdata;
  input  wire [1:0]                   rresp;
  input  wire                         rlast;
  input  wire                         rvalid;


  output reg  [1:0]                   awdomain;
  output reg  [2:0]                   awsnoop;

  output reg  [1:0]                   ardomain;
  output reg  [3:0]                   arsnoop;

  output reg                          mstr_tr_in_prog;
  output reg                          mstr_tr_done;
  output wire                         mstr_err;
  output wire                         ap0_dword_inc;
  output wire                         ap1_dword_inc;

  input  wire                         bd_sel;
  input  wire                         bd_dar_access;
  input  wire                         drw_sel;
  input  wire                         dar_sel;
  input  wire                         mstr_mte;
  input  wire [3:0]                   mstr_wtag;
  output wire [3:0]                   mstr_rtag;
  output wire                         mstr_rtag_transfer;
  input  wire                         mstr_tr_req;
  input  wire [1:0]                   mstr_csw_req;
  input  wire                         mstr_nrd_wr;
  input  wire                         boss_twin;

  input  wire [AXI_ADDR_WIDTH-1:0]    mstr_addr;
  input  wire [1:0]                   mstr_size;
  input  wire [3:0]                   mstr_cache;
  input  wire [2:0]                   mstr_prot;
  input  wire [1:0]                   mstr_ace_domain;

  output wire [31:0]                  mstr_rd_data;
  input  wire                         abort_req;

  input wire [31:0]                   pwdata;
  input wire                          paddr_12;


  localparam AXI_RESP_SLVERR = 2'b10;
  localparam AXI_RESP_DECERR = 2'b11;

  localparam DW_IDLE         = 3'b000;
  localparam DW_DRW_WR       = 3'b001;
  localparam DW_DRW_RD       = 3'b010;
  localparam DW_BD_WR        = 3'b011;
  localparam DW_BD_RD        = 3'b100;
  localparam DW_DAR_WR       = 3'b101;
  localparam DW_DAR_RD       = 3'b110;
  localparam DW_ERR          = 3'b111;

  localparam RDY             = 3'b000;
  localparam UNUSED1         = 3'b001;
  localparam UNUSED2         = 3'b010;
  localparam WR_CMD          = 3'b011;
  localparam WR_DT           = 3'b100;
  localparam W_RESP          = 3'b101;
  localparam RD_CMD          = 3'b110;
  localparam R_RESP          = 3'b111;

  localparam AXIAP_BYTE      = 2'b00;
  localparam AXIAP_HALF_WORD = 2'b01;
  localparam AXIAP_WORD      = 2'b10;
  localparam AXIAP_DWORD     = 2'b11;

  localparam AXI_BYTE        = {AXIAP_BYTE      };
  localparam AXI_HALF_WORD   = {AXIAP_HALF_WORD };
  localparam AXI_WORD        = {AXIAP_WORD      };
  localparam AXI_DWORD       = {AXIAP_DWORD     };


  wire                        mstr_wready;
  wire                        wr_resp;
  wire                        rd_resp;
  wire                        axi_err_resp;
  reg                         wstrb_next_en;
  wire                        arvalid_en;
  wire                        rd_wr_addr_en;
  wire                        mstr_state_en;
  wire                        axi_err_resp_rg_next;
  wire [6:0]                  last_dword_addr_selected;
  wire [1:0]                  dword_state_en;
  reg  [2:0]                  dword_state_fsm_next;
  wire [2:0]                  dword_state_fsm;
  wire [1:0]                  axi_wr_data_en;
  wire [1:0]                  rd_wr_data_en;
  wire [1:0]                  capture_dword_addr;

  wire [L_BUF_WIDTH-1:0]      dword_rd_data;
  wire [5:0]                  dword_state_next;
  wire                        drw_rd2_next;

  reg                         allow_axi_tran;
  wire                        allow_mte_size;
  reg                         allow_dword;
  reg                         axi_err_resp_rg;
  wire                        wvalid_sent_next_set;
  wire                        wvalid_sent_next_hold;
  wire                        wvalid_sent_next;
  reg                         wvalid_sent;
  wire                        wvalid_next;
  reg                         awprot_1_next;
  reg                         awprot_1;
  reg                         awvalid_next;
  reg                         aw_channel_en;
  reg                         arprot_1_next;
  reg                         arprot_1;
  reg                         arvalid_next;
  reg                         ar_channel_en;
  reg                         capture_dword_addr_int;
  reg                         mstr_tr_in_prog_next;
  reg                         mstr_tr_done_next;
  reg  [1:0]                  arsize_next;
  reg  [1:0]                  arsize_rg;
  reg  [1:0]                  awsize_rg;
  reg  [1:0]                  awsize_next;
  reg  [2:0]                  mstr_state;
  reg  [2:0]                  mstr_state_next;
  reg  [AXI_WSTRB_WIDTH-1:0]  wstrb_next;
  reg  [3:0]                  awcache_next;
  reg  [3:0]                  arcache_next;
  wire [1:0]                  rdata_vld;
  reg                         rdata_valid;
  wire                        wdata_valid;
  reg  [5:0]                  dword_state;
  reg  [13:0]                 last_dword_addr;
  reg  [L_BUF_WIDTH-1:0]      rd_wr_data_next;
  reg  [AXI_ADDR_WIDTH-1:0]   rd_wr_addr_next;
  reg  [AXI_ADDR_WIDTH-1:0]   rd_wr_addr;
  reg  [2*L_BUF_WIDTH-1:0]    rd_wr_data;
  reg                         drw_rd2;
  reg                         drw_rd2_set;
  wire                        mstr_tr_req_ok;


  assign mstr_tr_req_ok = mstr_tr_req & (drw_sel | bd_sel | dar_sel);

  always @ (*) begin
    mstr_tr_done_next           = 1'b0;
    mstr_tr_in_prog_next        = 1'b0;
    wstrb_next_en               = 1'b0;
    case (mstr_state)
      RDY : begin
        if (allow_dword && mstr_tr_req_ok && allow_axi_tran) begin
          mstr_tr_in_prog_next  = 1'b1;
          if (mstr_nrd_wr)
            mstr_state_next     = WR_CMD;
          else
            mstr_state_next     = RD_CMD;
        end
        else if (mstr_tr_req && (!allow_axi_tran || !allow_dword)) begin
          mstr_tr_done_next     = 1'b1;
          mstr_state_next       = RDY;
        end
        else begin
          mstr_tr_in_prog_next  = 1'b0;
          mstr_state_next       = RDY;
        end
      end
      WR_CMD : begin
        mstr_tr_in_prog_next    = 1'b1;
        wstrb_next_en           = ~awvalid;
       if(awready && awvalid)
          mstr_state_next       = WR_DT;
        else
          mstr_state_next       = mstr_state;
      end
      WR_DT : begin
        mstr_tr_in_prog_next    = 1'b1;
        if (mstr_wready)
          mstr_state_next       = W_RESP;
        else
          mstr_state_next       = mstr_state;
      end
      W_RESP : begin
        mstr_tr_in_prog_next = 1'b1;
        if (wr_resp || axi_err_resp) begin
          mstr_state_next = RDY;
          mstr_tr_done_next     = 1'b1;
        end
        else
          mstr_state_next       = mstr_state;
      end
      RD_CMD : begin
        mstr_tr_in_prog_next    = 1'b1;
        if (arready && arvalid)
          mstr_state_next       = R_RESP;
        else
          mstr_state_next       = mstr_state;
      end
      R_RESP : begin
        mstr_tr_in_prog_next    = 1'b1;
        if (rd_resp || axi_err_resp) begin
          mstr_state_next       = RDY;
          mstr_tr_done_next     = 1'b1;
        end
        else
          mstr_state_next       = mstr_state;
      end
      UNUSED1,
      UNUSED2 : begin
        mstr_state_next         = RDY;
      end
      default : mstr_state_next = {3{1'bx}};
    endcase
  end

  assign mstr_state_en = (mstr_state != mstr_state_next);

  always @ (posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      mstr_state <= RDY;
    end
    else if (mstr_state_en) begin
      mstr_state <= mstr_state_next;
    end
  end

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      mstr_tr_in_prog <= 1'b0;
      mstr_tr_done    <= 1'b0;
    end
    else begin
      mstr_tr_in_prog <= mstr_tr_in_prog_next;
      mstr_tr_done    <= mstr_tr_done_next;
    end
  end


  assign dword_state_fsm = boss_twin ? dword_state[5:3] : dword_state[2:0];
  assign last_dword_addr_selected = boss_twin ? last_dword_addr[13:7] : last_dword_addr[6:0];

  always @(*) begin
    dword_state_fsm_next = dword_state_fsm;
    capture_dword_addr_int = 1'b0;
    allow_dword = 1'b0;
    drw_rd2_set = 1'b0;
    case (dword_state_fsm)
      DW_IDLE: begin
        if (mstr_size < AXIAP_DWORD) begin
          allow_dword = 1'b1;
          dword_state_fsm_next = DW_IDLE;
        end
        else
        begin
          if (abort_req) begin
            dword_state_fsm_next = DW_IDLE;
            allow_dword = 1'b0;
          end
          else
          if (mstr_tr_req_ok) begin
            if (mstr_state == RDY) begin
              if(!allow_axi_tran)
                dword_state_fsm_next = DW_ERR;
              else begin
                capture_dword_addr_int = 1'b1;
                if (mstr_addr[2]) begin
                  dword_state_fsm_next = DW_ERR;
                  allow_dword      = 1'b0;
                end
                else begin
                    dword_state_fsm_next = (drw_sel &&  mstr_nrd_wr) ? DW_DRW_WR
                                         : (bd_sel  &&  mstr_nrd_wr) ? DW_BD_WR
                                         : (dar_sel &&  mstr_nrd_wr) ? DW_DAR_WR
                                         : (drw_sel && !mstr_nrd_wr) ? DW_DRW_RD
                                         : (bd_sel  && !mstr_nrd_wr) ? DW_BD_RD
                                         : (dar_sel && !mstr_nrd_wr) ? DW_DAR_RD
                                         :                             3'bxxx
                                         ;
                    allow_dword          = (drw_sel &&  mstr_nrd_wr) ? 1'b0
                                         : (bd_sel  &&  mstr_nrd_wr) ? 1'b0
                                         : (dar_sel &&  mstr_nrd_wr) ? 1'b0
                                         : (drw_sel && !mstr_nrd_wr) ? 1'b1
                                         : (bd_sel  && !mstr_nrd_wr) ? 1'b1
                                         : (dar_sel && !mstr_nrd_wr) ? 1'b1
                                         :                             1'bx
                                         ;
                end
              end
            end
            else if (mstr_nrd_wr) begin
              dword_state_fsm_next = DW_IDLE;
              allow_dword = 1'b0;
            end
            else begin
              dword_state_fsm_next = DW_ERR;
              allow_dword = 1'b0;
            end
          end
          else begin
            dword_state_fsm_next = DW_IDLE;
            allow_dword = 1'b0;
          end
        end
      end
      DW_DRW_WR: begin
        if (!mstr_tr_req)
          dword_state_fsm_next = dword_state_fsm;
        else if (!drw_sel)
          dword_state_fsm_next = DW_ERR;
        else if (!mstr_nrd_wr)
          dword_state_fsm_next = DW_ERR;
        else begin
          allow_dword = 1'b1;
          dword_state_fsm_next = DW_IDLE;
        end
      end
      DW_BD_WR: begin
          if (!mstr_tr_req)
            dword_state_fsm_next = dword_state_fsm;
          else if (!bd_sel)
            dword_state_fsm_next = DW_ERR;
          else if (!mstr_nrd_wr)
            dword_state_fsm_next = DW_ERR;
          else if (mstr_addr[3:2] == {last_dword_addr_selected[0], 1'b1}) begin
            allow_dword = 1'b1;
            dword_state_fsm_next = DW_IDLE;
          end
          else
            dword_state_fsm_next = DW_ERR;
        end
      DW_DAR_WR: begin
          if (!mstr_tr_req)
            dword_state_fsm_next = dword_state_fsm;
          else if (!dar_sel)
            dword_state_fsm_next = DW_ERR;
          else if (!mstr_nrd_wr)
            dword_state_fsm_next = DW_ERR;
          else if (mstr_addr[9:2] == {last_dword_addr_selected, 1'b1}) begin
            allow_dword = 1'b1;
            dword_state_fsm_next = DW_IDLE;
          end
          else
            dword_state_fsm_next = DW_ERR;
        end

      DW_DRW_RD: begin
        if (abort_req)
          dword_state_fsm_next = DW_IDLE;
        else if (mstr_state == RDY) begin
          if (!mstr_tr_req)
            dword_state_fsm_next = dword_state_fsm;
          else if (!drw_sel)
            dword_state_fsm_next = DW_ERR;
          else if (mstr_nrd_wr)
            dword_state_fsm_next = DW_ERR;
          else begin
            drw_rd2_set = 1'b1;
            dword_state_fsm_next = DW_IDLE;
          end
        end
        else if (axi_err_resp)
          dword_state_fsm_next = DW_IDLE;
        else
          dword_state_fsm_next = dword_state_fsm;
      end
      DW_BD_RD: begin
        if (abort_req)
          dword_state_fsm_next = DW_IDLE;
        else if (mstr_state == RDY) begin
          if (!mstr_tr_req)
            dword_state_fsm_next = dword_state_fsm;
          else if (!bd_sel )
            dword_state_fsm_next = DW_ERR;
          else if (mstr_nrd_wr)
            dword_state_fsm_next = DW_ERR;
          else begin
            if (mstr_addr[3:2] == {last_dword_addr_selected[0], 1'b1})
              dword_state_fsm_next = DW_IDLE;
            else
              dword_state_fsm_next = DW_ERR;
          end
        end
        else if (axi_err_resp)
          dword_state_fsm_next = DW_IDLE;
        else
          dword_state_fsm_next = dword_state_fsm;
      end
      DW_DAR_RD: begin
        if (abort_req)
          dword_state_fsm_next = DW_IDLE;
        else if (mstr_state == RDY) begin
          if (!mstr_tr_req)
            dword_state_fsm_next = dword_state_fsm;
          else if (!dar_sel)
            dword_state_fsm_next = DW_ERR;
          else if (mstr_nrd_wr)
            dword_state_fsm_next = DW_ERR;
          else begin
            if (mstr_addr[9:2] == {last_dword_addr_selected, 1'b1})
              dword_state_fsm_next = DW_IDLE;
            else
              dword_state_fsm_next = DW_ERR;
          end
        end
        else if (axi_err_resp)
          dword_state_fsm_next = DW_IDLE;
        else
          dword_state_fsm_next = dword_state_fsm;
      end

      DW_ERR: begin
        dword_state_fsm_next = DW_IDLE;
      end
      default: begin
        dword_state_fsm_next = 3'bxxx;
      end
    endcase
  end


  assign capture_dword_addr = {2{capture_dword_addr_int}} & {boss_twin, ~boss_twin};
  assign dword_state_en     = ({2{dword_state_fsm != dword_state_fsm_next}}
                            & {boss_twin, ~boss_twin}) | mstr_csw_req;
  assign dword_state_next[2:0] = mstr_csw_req[0] ? DW_IDLE : dword_state_fsm_next;
  assign dword_state_next[5:3] = mstr_csw_req[1] ? DW_IDLE : dword_state_fsm_next;

  assign ap0_dword_inc = (dword_state[2:0] == DW_IDLE);
  assign ap1_dword_inc = (dword_state[5:3] == DW_IDLE);

  assign drw_rd2_next = drw_rd2_set | drw_rd2 & ~mstr_tr_done;

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
      drw_rd2 <= 1'b0;
    else
      drw_rd2 <= drw_rd2_next;
  end

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      last_dword_addr[6+0:0+0]   <= 7'h00;
      last_dword_addr[6+7:0+7]   <= 7'h00;
    end else begin
      if (capture_dword_addr[0])
        last_dword_addr[6+0:0+0] <= mstr_addr[9:3];
      if (capture_dword_addr[1])
        last_dword_addr[6+7:0+7] <= mstr_addr[9:3];
    end
  end

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      dword_state[2+0:0+0]       <= DW_IDLE;
      dword_state[2+3:0+3]       <= DW_IDLE;
    end else begin
      if (dword_state_en[0])
        dword_state[2+0:0+0]     <= dword_state_next[2+0:0+0];
      if (dword_state_en[1])
        dword_state[2+3:0+3]     <= dword_state_next[2+3:0+3];
    end
  end


  assign axi_err_resp_rg_next = axi_err_resp & ~abort_req;

  always @ (posedge clk or negedge reset_n) begin : p_err_resp
    if (!reset_n) begin
      axi_err_resp_rg <= 1'b0;
    end
    else  begin
      axi_err_resp_rg <= axi_err_resp_rg_next;
    end
  end

  assign mstr_err = (dword_state_fsm == DW_ERR) | axi_err_resp_rg;


  assign dword_rd_data = boss_twin ? rd_wr_data[L_BUF_WIDTH +: L_BUF_WIDTH]
                                   : rd_wr_data[L_BUF_WIDTH-1:0];


  generate
    if (AXI_DATA_WIDTH == 128) begin: gen_rd_data_128
      assign mstr_rd_data = (drw_rd2 || mstr_addr[2])
                          ? dword_rd_data[63:32]
                          : dword_rd_data[31:0];
    end
    else if (AXI_DATA_WIDTH == 64) begin: gen_rd_data_64
      assign mstr_rd_data = (drw_rd2 || mstr_addr[2])
                          ? dword_rd_data[63:32]
                          : dword_rd_data[31:0];
    end
    else begin: gen_rd_data_32
      assign mstr_rd_data = dword_rd_data;
    end
  endgenerate

  assign axi_err_resp = ((mstr_state == W_RESP) & bvalid & (bresp == AXI_RESP_SLVERR))
                      | ((mstr_state == W_RESP) & bvalid & (bresp == AXI_RESP_DECERR))
                      | ((mstr_state == R_RESP) & rvalid & (rresp == AXI_RESP_SLVERR))
                      | ((mstr_state == R_RESP) & rvalid & (rresp == AXI_RESP_DECERR))
                      | ((mstr_state == RDY) & mstr_tr_req_ok & !allow_axi_tran);


  assign allow_mte_size = mstr_mte && (mstr_size >= AXIAP_DWORD);
  always @(*) begin
  if (mstr_mte && !allow_mte_size)
    allow_axi_tran              =                                1'b0;
  else
      case (mstr_cache[3:1])
        3'b000 : allow_axi_tran = (mstr_mte                   )? 1'b0
                                : (mstr_ace_domain==2'b00     )? 1'b0
                                : (mstr_ace_domain==2'b01     )? 1'b0
                                : (mstr_ace_domain==2'b10     )? 1'b0
                                :                                1'b1
                                ;
        3'b001 : allow_axi_tran = (mstr_mte                   )? 1'b0
                                : (mstr_ace_domain==2'b00     )? 1'b1
                                : (mstr_ace_domain==2'b01     )? 1'b1
                                : (mstr_ace_domain==2'b10     )? 1'b1
                                :                                1'b1
                                ;

        3'b011,
        3'b101,
        3'b111 : allow_axi_tran = (mstr_mte && !mstr_cache[0] )? 1'b0
                                : (mstr_ace_domain==2'b00     )? 1'b1
                                : (mstr_ace_domain==2'b01     )? 1'b1
                                : (mstr_ace_domain==2'b10     )? 1'b1
                                :                                1'b0
                                ;
        3'b010 ,
        3'b100 ,
        3'b110 : allow_axi_tran =                                1'b0;

        default: allow_axi_tran =                                1'bx;
      endcase
  end

  always @(*) begin : p_rd_wr_addr_cmb
    rd_wr_addr_next = mstr_addr;
    if ((mstr_state == WR_CMD) || (mstr_state == RD_CMD))
      rd_wr_addr_next = mstr_addr;
  end

  assign rd_wr_addr_en =
                         (mstr_state == WR_CMD) |
                         (mstr_state == RD_CMD);

  always @(posedge clk or negedge reset_n) begin : p_rd_wr_addr_seq
    if (!reset_n)
      rd_wr_addr  <= {AXI_ADDR_WIDTH{1'b0}};
    else if (rd_wr_addr_en)
      rd_wr_addr  <= rd_wr_addr_next;
  end


  assign awsize  = {1'b0,awsize_rg};

  assign awburst = {2'b01};

  always @(*) begin : p_aw_ch
    awlen            = 8'b00000000;
    awlock           = 1'b0;
    awcache_next     = mstr_cache;
    awprot[2]        = mstr_prot[2];
    awprot[1]        = awprot_1;
    awprot[0]        = mstr_prot[0];
    awvalid_next     = 1'b0;
    awdomain         = mstr_ace_domain;
    awsnoop          = 3'b000;
    awprot_1_next    = awvalid ? awprot_1 : mstr_prot[1];
    aw_channel_en    = 1'b0;
    awsize_next      = awsize_rg;
    if (mstr_state == WR_CMD) begin
       awvalid_next = awvalid ? ~awready : 1'b1;
       aw_channel_en = 1'b1;
       if (bd_dar_access)
         awsize_next   = (mstr_size == AXIAP_DWORD) ? 2'b11
                       :                              2'b10
                       ;
       else
         awsize_next   =                              mstr_size;
     end
  end

  assign awaddr = (mstr_size == AXIAP_DWORD)
                ? {rd_wr_addr[AXI_ADDR_WIDTH-1:3], 3'b000}
                : rd_wr_addr;

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      awsize_rg   <= 2'b00;
      awcache     <= 4'b0000;
      awprot_1    <= 1'b1;
    end
    else if (aw_channel_en) begin
      awsize_rg   <= awsize_next;
      awcache     <= awcache_next;
      awprot_1    <= awprot_1_next;
    end
  end

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
      awvalid <= 1'b0;
    else
      awvalid <= awvalid_next;
  end


  assign arsize  = {1'b0,arsize_rg};
  assign arburst = {2'b01};

  always @(*) begin
    arlen            = 8'b00000000;
    arlock           = 1'b0;
    arcache_next     = mstr_cache;
    arprot[2]        = mstr_prot[2];
    arprot[1]        = arprot_1;
    arprot[0]        = mstr_prot[0];
    arvalid_next     = 1'b0;
    ardomain         = mstr_ace_domain;
    arsnoop          = 4'b0000;
    arprot_1_next    = arvalid ? arprot_1 : mstr_prot[1];
    ar_channel_en    = 1'b0;
    arsize_next      = arsize_rg;
    if (mstr_state == RD_CMD) begin
      arvalid_next     = arvalid ? ~arready : 1'b1;
      ar_channel_en    = 1'b1;
      if (bd_dar_access)
         arsize_next   = (mstr_size == AXIAP_DWORD) ? 2'b11
                       :                              2'b10
                       ;
       else
         arsize_next   =                              mstr_size;
    end
  end

  assign araddr = rd_wr_addr;

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      arsize_rg <= 2'b00;
      arcache <= 4'b0000;
      arprot_1 <= 1'b1;
    end
    else if (ar_channel_en) begin
      arsize_rg <= arsize_next;
      arcache <= arcache_next;
      arprot_1 <= arprot_1_next;
    end
  end

  assign arvalid_en = arvalid_next ^ arvalid;

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
      arvalid <= 1'b0;
    else if (arvalid_en)
      arvalid <= arvalid_next;
  end

  assign bready = (mstr_state == W_RESP);

  assign rready = (mstr_state == R_RESP);

  assign mstr_wready = wready | wvalid_sent;

  assign wr_resp = bvalid;

  assign rd_resp = rvalid;


  wire [L_BUF_WIDTH-1:0] w_rd_wr_data;
  generate
      if (AXI_DATA_WIDTH == 128) begin: w_rd_wr_data_128
        assign w_rd_wr_data = boss_twin ? rd_wr_data[127:64] : rd_wr_data[63:0];
      end
      else if (AXI_DATA_WIDTH == 64) begin: w_rd_wr_data_64
        assign w_rd_wr_data = boss_twin ? rd_wr_data[127:64] : rd_wr_data[63:0];
      end
      else begin: w_rd_wr_data_32
        assign w_rd_wr_data = boss_twin ? rd_wr_data[63:32] : rd_wr_data[31:0];
      end
  endgenerate

  generate
      if (AXI_DATA_WIDTH == 128) begin: rd_wr_data_next_128
        always @(*) begin : p_incr_data_128
          rdata_valid                               = 1'b0;
          rd_wr_data_next                           = w_rd_wr_data;
          if (mstr_state == RDY) begin
            if (mstr_tr_req_ok && mstr_nrd_wr) begin
              case (mstr_size)
                AXIAP_BYTE,
                AXIAP_HALF_WORD,
                AXIAP_WORD : begin
                  case(mstr_addr[2])
                    1'b0:    rd_wr_data_next[31:0]  = pwdata;
                    1'b1:    rd_wr_data_next[63:32] = pwdata;
                    default: rd_wr_data_next        = {L_BUF_WIDTH{1'bx}};
                  endcase
                end
                AXIAP_DWORD : begin
                  if (dword_state_fsm != DW_IDLE)
                             rd_wr_data_next[63:32] = pwdata;
                  else
                             rd_wr_data_next[31:0]  = pwdata;
                end
                default :    rd_wr_data_next        = {L_BUF_WIDTH{1'bx}};
              endcase
            end
          end
          else if ((mstr_state == R_RESP) && rvalid && rlast) begin
            rdata_valid                             = 1'b1;
            if (drw_sel) begin
              case (mstr_size)
                AXIAP_BYTE : begin
                  case(mstr_addr[3:0])
                    4'b0000: rd_wr_data_next[ 7:0 ] = rdata[  7:0  ];
                    4'b0001: rd_wr_data_next[15:8 ] = rdata[ 15:8  ];
                    4'b0010: rd_wr_data_next[23:16] = rdata[ 23:16 ];
                    4'b0011: rd_wr_data_next[31:24] = rdata[ 31:24 ];
                    4'b0100: rd_wr_data_next[39:32] = rdata[ 39:32 ];
                    4'b0101: rd_wr_data_next[47:40] = rdata[ 47:40 ];
                    4'b0110: rd_wr_data_next[55:48] = rdata[ 55:48 ];
                    4'b0111: rd_wr_data_next[63:56] = rdata[ 63:56 ];
                    4'b1000: rd_wr_data_next[ 7:0 ] = rdata[ 71:64 ];
                    4'b1001: rd_wr_data_next[15:8 ] = rdata[ 79:72 ];
                    4'b1010: rd_wr_data_next[23:16] = rdata[ 87:80 ];
                    4'b1011: rd_wr_data_next[31:24] = rdata[ 95:88 ];
                    4'b1100: rd_wr_data_next[39:32] = rdata[103:96 ];
                    4'b1101: rd_wr_data_next[47:40] = rdata[111:104];
                    4'b1110: rd_wr_data_next[55:48] = rdata[119:112];
                    4'b1111: rd_wr_data_next[63:56] = rdata[127:120];
                    default: rd_wr_data_next        = {L_BUF_WIDTH{1'bx}};
                  endcase
                end
                AXIAP_HALF_WORD : begin
                  case(mstr_addr[3:1])
                    3'b000:  rd_wr_data_next[15:0 ] = rdata[ 15:0  ];
                    3'b001:  rd_wr_data_next[31:16] = rdata[ 31:16 ];
                    3'b010:  rd_wr_data_next[47:32] = rdata[ 47:32 ];
                    3'b011:  rd_wr_data_next[63:48] = rdata[ 63:48 ];
                    3'b100:  rd_wr_data_next[15:0 ] = rdata[ 79:64 ];
                    3'b101:  rd_wr_data_next[31:16] = rdata[ 95:80 ];
                    3'b110:  rd_wr_data_next[47:32] = rdata[111:96 ];
                    3'b111:  rd_wr_data_next[63:48] = rdata[127:112];
                    default: rd_wr_data_next        = {L_BUF_WIDTH{1'bx}};
                  endcase
                end
                AXIAP_WORD : begin
                  case(mstr_addr[3:2])
                    2'b00:   rd_wr_data_next[31:0 ] = rdata[ 31:0  ];
                    2'b01:   rd_wr_data_next[63:32] = rdata[ 63:32 ];
                    2'b10:   rd_wr_data_next[31:0 ] = rdata[ 95:64 ];
                    2'b11:   rd_wr_data_next[63:32] = rdata[127:96 ];
                    default: rd_wr_data_next        = {L_BUF_WIDTH{1'bx}};
                  endcase
                end
                AXIAP_DWORD : begin
                  case(mstr_addr[3])
                    1'b0:    rd_wr_data_next        = rdata[ 63:0  ];
                    1'b1:    rd_wr_data_next        = rdata[127:64 ];
                    default: rd_wr_data_next        = {L_BUF_WIDTH{1'bx}};
                  endcase
                end
                default:     rd_wr_data_next        = {L_BUF_WIDTH{1'bx}};
              endcase
            end
            else begin
                  case(mstr_addr[3])
                    1'b0:    rd_wr_data_next        = rdata[ 63:0  ];
                    1'b1:    rd_wr_data_next        = rdata[127:64 ];
                    default: rd_wr_data_next        = {L_BUF_WIDTH{1'bx}};
                  endcase
            end
          end
        end
      end
      else if (AXI_DATA_WIDTH == 64) begin: rd_wr_data_next_64
        always @(*) begin : p_incr_data_64
          rdata_valid                               = 1'b0;
          rd_wr_data_next                           = w_rd_wr_data;
          if (mstr_state == RDY) begin
            if (mstr_tr_req_ok && mstr_nrd_wr) begin
              case (mstr_size)
                AXIAP_BYTE,
                AXIAP_HALF_WORD,
                AXIAP_WORD : begin
                  case(mstr_addr[2])
                    1'b0:    rd_wr_data_next[31:0]  = pwdata;
                    1'b1:    rd_wr_data_next[63:32] = pwdata;
                    default: rd_wr_data_next        = {L_BUF_WIDTH{1'bx}};
                  endcase
                end
                AXIAP_DWORD : begin
                  if (dword_state_fsm != DW_IDLE)
                             rd_wr_data_next[63:32] = pwdata;
                  else
                             rd_wr_data_next[31:0]  = pwdata;
                end
                default :    rd_wr_data_next        = {L_BUF_WIDTH{1'bx}};
              endcase
            end
          end
          else if ((mstr_state == R_RESP) && rvalid && rlast) begin
            rdata_valid                             = 1'b1;
            if (drw_sel) begin
              case (mstr_size)
                AXIAP_BYTE : begin
                  case(mstr_addr[2:0])
                    3'b000:  rd_wr_data_next[ 7:0 ] = rdata[ 7:0 ];
                    3'b001:  rd_wr_data_next[15:8 ] = rdata[15:8 ];
                    3'b010:  rd_wr_data_next[23:16] = rdata[23:16];
                    3'b011:  rd_wr_data_next[31:24] = rdata[31:24];
                    3'b100:  rd_wr_data_next[39:32] = rdata[39:32];
                    3'b101:  rd_wr_data_next[47:40] = rdata[47:40];
                    3'b110:  rd_wr_data_next[55:48] = rdata[55:48];
                    3'b111:  rd_wr_data_next[63:56] = rdata[63:56];
                    default: rd_wr_data_next        = {L_BUF_WIDTH{1'bx}};
                  endcase
                end
                AXIAP_HALF_WORD : begin
                  case(mstr_addr[2:1])
                    2'b00:   rd_wr_data_next[15:0 ] = rdata[15:0 ];
                    2'b01:   rd_wr_data_next[31:16] = rdata[31:16];
                    2'b10:   rd_wr_data_next[47:32] = rdata[47:32];
                    2'b11:   rd_wr_data_next[63:48] = rdata[63:48];
                    default: rd_wr_data_next        = {L_BUF_WIDTH{1'bx}};
                  endcase
                end
                AXIAP_WORD : begin
                 case(mstr_addr[2])
                    1'b0:    rd_wr_data_next[31:0 ] = rdata[31:0];
                    1'b1:    rd_wr_data_next[63:32] = rdata[63:32];
                    default: rd_wr_data_next        = {L_BUF_WIDTH{1'bx}};
                  endcase
                end
                AXIAP_DWORD : begin
                             rd_wr_data_next        = rdata;
                end
                default:     rd_wr_data_next        = {L_BUF_WIDTH{1'bx}};
              endcase
            end
            else begin
                             rd_wr_data_next        = rdata;
            end
          end
        end
      end
      else begin: rd_wr_data_next_32
        always @(*) begin : p_incr_data_32
          rdata_valid                               = 1'b0;
          rd_wr_data_next                           = w_rd_wr_data;
          if (mstr_state == RDY) begin
            if (mstr_tr_req_ok && mstr_nrd_wr) begin
              case (mstr_size)
                AXIAP_BYTE,
                AXIAP_HALF_WORD,
                AXIAP_WORD,
                AXIAP_DWORD : begin
                             rd_wr_data_next        = pwdata;
                end
                default :    rd_wr_data_next        = {L_BUF_WIDTH{1'bx}};
              endcase
            end
          end
          else if ((mstr_state == R_RESP) && rvalid && rlast) begin
            rdata_valid                             = 1'b1;
            if (drw_sel) begin
              case (mstr_size)
                AXIAP_BYTE : begin
                  case(mstr_addr[1:0])
                    2'b00:   rd_wr_data_next[ 7:0 ] = rdata[7 :0];
                    2'b01:   rd_wr_data_next[15:8 ] = rdata[15:8];
                    2'b10:   rd_wr_data_next[23:16] = rdata[23:16];
                    2'b11:   rd_wr_data_next[31:24] = rdata[31:24];
                    default: rd_wr_data_next        = {L_BUF_WIDTH{1'bx}};
                  endcase
                end
                AXIAP_HALF_WORD : begin
                  case(mstr_addr[1])
                    1'b0 :   rd_wr_data_next[15:0 ] = rdata[15:0];
                    1'b1 :   rd_wr_data_next[31:16] = rdata[31:16];
                    default: rd_wr_data_next        = {L_BUF_WIDTH{1'bx}};
                  endcase
                end
                AXIAP_WORD : begin
                             rd_wr_data_next        = rdata;
                end
                AXIAP_DWORD : begin
                             rd_wr_data_next        = rdata;
                end
                default:     rd_wr_data_next        = {L_BUF_WIDTH{1'bx}};
              endcase
            end
            else begin
                             rd_wr_data_next        = rdata;
            end
          end
        end
      end
  endgenerate


   assign rdata_vld         = (!rdata_valid) ? 2'b00
                            : ( boss_twin  ) ? 2'b10 : 2'b01
                            ;
   assign wdata_valid       = (mstr_state == RDY)
                            & mstr_tr_req_ok
                            & mstr_nrd_wr
                            ;
   assign axi_wr_data_en[0] = ~paddr_12 & wdata_valid ;
   assign rd_wr_data_en[0]  = axi_wr_data_en[0]  | rdata_vld[0] ;

   assign axi_wr_data_en[1] = paddr_12 & wdata_valid;
   assign rd_wr_data_en[1]  = axi_wr_data_en[1]  | rdata_vld[1] ;

   always @(posedge clk or negedge reset_n) begin: p_rd_wr_data_reg
     if (!reset_n) begin
       rd_wr_data                                 <= {2*L_BUF_WIDTH{1'b0}};
     end else begin
       if (rd_wr_data_en[1])
         rd_wr_data[2*L_BUF_WIDTH-1:L_BUF_WIDTH]  <= rd_wr_data_next;
       if (rd_wr_data_en[0])
         rd_wr_data[  L_BUF_WIDTH-1:0          ]  <= rd_wr_data_next;
     end
   end


  generate
    if (AXI_WSTRB_WIDTH == 16) begin: gen_strb16
      always @(*) begin : p_wstrb_decode
        wstrb_next                          = {16{1'b0}};
        if (mstr_nrd_wr) begin
          case(awsize_next)
            AXI_BYTE : begin
              case(mstr_addr[3:0])
                4'b0000  : wstrb_next[ 0]    = 1'b1;
                4'b0001  : wstrb_next[ 1]    = 1'b1;
                4'b0010  : wstrb_next[ 2]    = 1'b1;
                4'b0011  : wstrb_next[ 3]    = 1'b1;
                4'b0100  : wstrb_next[ 4]    = 1'b1;
                4'b0101  : wstrb_next[ 5]    = 1'b1;
                4'b0110  : wstrb_next[ 6]    = 1'b1;
                4'b0111  : wstrb_next[ 7]    = 1'b1;
                4'b1000  : wstrb_next[ 8]    = 1'b1;
                4'b1001  : wstrb_next[ 9]    = 1'b1;
                4'b1010  : wstrb_next[10]    = 1'b1;
                4'b1011  : wstrb_next[11]    = 1'b1;
                4'b1100  : wstrb_next[12]    = 1'b1;
                4'b1101  : wstrb_next[13]    = 1'b1;
                4'b1110  : wstrb_next[14]    = 1'b1;
                4'b1111  : wstrb_next[15]    = 1'b1;
                default  : wstrb_next        = {16{1'bx}};
              endcase
            end
            AXI_HALF_WORD : begin
              case(mstr_addr[3:1])
                3'b000   : wstrb_next[ 1:0 ] = 2'b11;
                3'b001   : wstrb_next[ 3:2 ] = 2'b11;
                3'b010   : wstrb_next[ 5:4 ] = 2'b11;
                3'b011   : wstrb_next[ 7:6 ] = 2'b11;
                3'b100   : wstrb_next[ 9:8 ] = 2'b11;
                3'b101   : wstrb_next[11:10] = 2'b11;
                3'b110   : wstrb_next[13:12] = 2'b11;
                3'b111   : wstrb_next[15:14] = 2'b11;
                default  : wstrb_next        = {16{1'bx}};
              endcase
            end
            AXI_WORD : begin
              case(mstr_addr[3:2])
                2'b00    : wstrb_next[ 3:0 ] = {4{1'b1}};
                2'b01    : wstrb_next[ 7:4 ] = {4{1'b1}};
                2'b10    : wstrb_next[11:8 ] = {4{1'b1}};
                2'b11    : wstrb_next[15:12] = {4{1'b1}};
                default  : wstrb_next        = {16{1'bx}};
              endcase
            end
            AXI_DWORD  : begin
              case(mstr_addr[3])
                1'b0     : wstrb_next[ 7:0 ] = {8{1'b1}};
                1'b1     : wstrb_next[15:8 ] = {8{1'b1}};
                default  : wstrb_next        = {16{1'bx}};
              endcase
            end
            default      : wstrb_next        = {16{1'bx}};
          endcase
        end
        else begin
          wstrb_next                         = {16{1'bx}};
        end
      end
    end
    else if (AXI_WSTRB_WIDTH == 8) begin: gen_strb8
      always @(*) begin : p_wstrb_decode
        wstrb_next                         = {8{1'b0}};
        if ((drw_sel || dar_sel || bd_sel) && mstr_nrd_wr) begin
          case(awsize_next)
            AXI_BYTE : begin
              case(mstr_addr[2:0])
                3'b000   : wstrb_next[0]     = 1'b1;
                3'b001   : wstrb_next[1]     = 1'b1;
                3'b010   : wstrb_next[2]     = 1'b1;
                3'b011   : wstrb_next[3]     = 1'b1;
                3'b100   : wstrb_next[4]     = 1'b1;
                3'b101   : wstrb_next[5]     = 1'b1;
                3'b110   : wstrb_next[6]     = 1'b1;
                3'b111   : wstrb_next[7]     = 1'b1;
                default  : wstrb_next        = {8{1'b1}};
              endcase
            end
            AXI_HALF_WORD : begin
              case(mstr_addr[2:1])
                2'b00    : wstrb_next[1:0]   = 2'b11;
                2'b01    : wstrb_next[3:2]   = 2'b11;
                2'b10    : wstrb_next[5:4]   = 2'b11;
                2'b11    : wstrb_next[7:6]   = 2'b11;
                default  : wstrb_next        = {8{1'b1}};
              endcase
            end
            AXI_WORD : begin
              case(mstr_addr[2])
                1'b0     : wstrb_next[3:0]   = {4{1'b1}};
                1'b1     : wstrb_next[7:4]   = {4{1'b1}};
                default  : wstrb_next        = {8{1'b1}};
              endcase
            end
            AXI_DWORD    : wstrb_next        = {8{1'b1}};
            default      : wstrb_next        = {8{1'b1}};
          endcase
        end
        else begin
          wstrb_next                         = {8{1'b1}};
        end
      end
    end
    else begin: gen_strb4
      always @(*) begin : p_wstrb_decode
        wstrb_next                           = {4{1'b0}};
        if ((drw_sel || dar_sel || bd_sel) && mstr_nrd_wr) begin
          case(awsize_next)
            AXI_BYTE : begin
              case(mstr_addr[1:0])
                2'b00   : wstrb_next[0]      = 1'b1;
                2'b01   : wstrb_next[1]      = 1'b1;
                2'b10   : wstrb_next[2]      = 1'b1;
                2'b11   : wstrb_next[3]      = 1'b1;
                default : wstrb_next         = {4{1'b1}};
              endcase
            end
            AXI_HALF_WORD : begin
              case(mstr_addr[1])
                1'b0    : wstrb_next[1:0]    = 2'b11;
                1'b1    : wstrb_next[3:2]    = 2'b11;
                default : wstrb_next         = {4{1'b1}};
              endcase
            end
            AXI_WORD    : wstrb_next         = {4{1'b1}};
            default     : wstrb_next         = {4{1'b1}};
          endcase
        end
        else begin
          wstrb_next                         = {4{1'b1}};
        end
      end
    end
  endgenerate

  always @(posedge clk or negedge reset_n) begin : p_wstrb
    if (!reset_n)
      wstrb <= {AXI_WSTRB_WIDTH{1'b0}};
    else if (wstrb_next_en)
      wstrb <= wstrb_next;
  end

  generate
    if (AXI_DATA_WIDTH==128) begin: wdata128_gen
      assign wdata = {2{boss_twin ? rd_wr_data[L_BUF_WIDTH +: L_BUF_WIDTH]
                                  : rd_wr_data[L_BUF_WIDTH-1:0           ]
                     }}           ;
    end
    else if (AXI_DATA_WIDTH==64) begin: wdata64_gen
      assign wdata =    boss_twin ? rd_wr_data[L_BUF_WIDTH +: L_BUF_WIDTH]
                                  : rd_wr_data[L_BUF_WIDTH-1:0           ]
                                  ;
    end
    else begin: wdata32_gen
      assign wdata =    boss_twin ? rd_wr_data[L_BUF_WIDTH +: L_BUF_WIDTH]
                                  : rd_wr_data[L_BUF_WIDTH-1:0           ]
                                  ;
    end
  endgenerate

  assign wvalid_sent_next_set  = (mstr_state == WR_CMD) ? ~wvalid_sent & wvalid & wready
                               : (mstr_state == WR_DT ) ? ~wvalid_sent & wvalid & wready
                               :                          ~wvalid_sent & wvalid
                               ;

  assign wvalid_sent_next_hold = wvalid_sent & ((mstr_state == WR_CMD) | (mstr_state == WR_DT));
  assign wvalid_sent_next      = wvalid_sent_next_set ? 1'b1 : wvalid_sent_next_hold;

  always @(posedge clk or negedge reset_n) begin : p_wvalid_sent
    if (!reset_n) begin
      wvalid_sent <= 1'b0;
    end else begin
      wvalid_sent <= wvalid_sent_next;
    end
  end

  assign wvalid_next = wvalid_sent                         ? 1'b0
                     : (mstr_state == WR_CMD) && ~wvalid ? 1'b1
                     : (mstr_state == WR_CMD) &&  wvalid ? ~wready
                     : (mstr_state == WR_DT)               ? ~wready
                     :                                       1'b0
                     ;

  always @(posedge clk or negedge reset_n) begin : p_wvalid
    if (!reset_n) begin
      wvalid    <= 1'b0;
    end else begin
      wvalid    <= wvalid_next;
    end
  end

  assign wlast  = wvalid;

  generate
   if ((MTE_PRESENT>0) && (MTE_TAG_WIDTH>0) && (MTE_TAG_GRANULE>0))
      begin : cfg_mte
        wire       mstr_tr_in_prog_start;
        wire       mstr_tr_in_prog_mte_next;
        reg        mstr_tr_in_prog_mte;
        wire       wtag_update;
        wire       awtagop_update;
        wire       artagop_transfer;
        wire       tag_ce;
        wire [3:0] tag_next;
        reg  [3:0] tag;

        assign mstr_tr_in_prog_start    = (mstr_tr_in_prog_next & !mstr_tr_in_prog);
        assign mstr_tr_in_prog_mte_next = (mstr_tr_in_prog_start) ? mstr_mte
                                        : (mstr_tr_in_prog_next ) ? mstr_tr_in_prog_mte
                                        :                           1'b0
                                        ;

        always @(posedge clk or negedge reset_n) begin
          if (!reset_n) begin
            mstr_tr_in_prog_mte <= 1'b0;
          end
          else begin
            mstr_tr_in_prog_mte <= mstr_tr_in_prog_mte_next;
          end
        end

        assign tag_ce   = (mstr_tr_in_prog_mte_next                     && wdata_valid)
                        | (mstr_tr_in_prog_mte && !axi_err_resp_rg_next && rdata_valid)
                        ;
        assign tag_next = (mstr_nrd_wr) ? mstr_wtag & {MTE_TAG_WIDTH{mstr_tr_in_prog_mte_next}}
                        : rtag
                        ;

        always @(posedge clk or negedge reset_n) begin : p_wvalid
          if (!reset_n) begin
            tag    <= 4'b0;
          end else if (tag_ce) begin
            tag    <= tag_next;
          end
        end


        assign awtagop_update     = mstr_tr_in_prog_mte & awvalid;
        assign awtagop            = (awtagop_update)   ? 2'b10
                                  :                      2'b00
                                  ;
        assign wtag_update        = wvalid & mstr_tr_in_prog_mte;
        assign wtagupdate[0]      = wtag_update;
        assign wtag               = wtag_update ? tag : {MTE_TAG_WIDTH{1'b0}};

        assign artagop_transfer   = mstr_tr_in_prog_mte & arvalid;
        assign artagop            = (artagop_transfer) ? 2'b01
                                  :                      2'b00
                                  ;
        assign mstr_rtag_transfer = mstr_tr_in_prog_mte & mstr_tr_done & ~mstr_nrd_wr & ~axi_err_resp_rg & ~abort_req;
        assign mstr_rtag          = tag;

      end
    else
      begin : cfg_no_mte
        assign awtagop            = 2'b00;
        assign wtag               = {MTE_TAG_WIDTH{1'b0}};
        assign wtagupdate         = {L_WTAGSROBE_WIDTH{1'b0}};

        assign artagop            = 2'b0;
        assign mstr_rtag          = 4'b0;
        assign mstr_rtag_transfer = 1'b0;
      end
  endgenerate


endmodule


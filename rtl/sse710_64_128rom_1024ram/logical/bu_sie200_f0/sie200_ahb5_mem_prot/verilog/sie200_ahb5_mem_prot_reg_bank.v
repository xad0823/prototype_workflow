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
//      Checked In          : Wed Feb 1 08:27:54 2017 +0000
//
//      Revision            : 706c08a
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------
module sie200_ahb5_mem_prot_reg_bank #(
  parameter LUT_ADDR_WIDTH  = 5,
  parameter LUT_DATA_WIDTH  = 32,
  parameter ADDR_WIDTH      = 18,
  parameter MASTER_WIDTH    = 4,
  parameter BLK_SIZE        = 3,
  parameter GATE_PRESENT    = 1
)
(
  input  wire                       pclk,
  input  wire                       presetn,

  input  wire                       psel,
  input  wire [11:0]                paddr,
  input  wire [3:0]                 pstrb,
  input  wire                       pwrite,
  input  wire                       penable,
  input  wire [2:0]                 pprot,
  input  wire [31:0]                pwdata,

  output wire [31:0]                prdata,
  output wire                       pready,
  output wire                       pslverr,

  input  wire                       lut_init_done,
  output wire [11:0]                blk_idx,
  output wire [31:0]                blk_lut_out,
  output wire                       blk_lut_write,
  input  wire [31:0]                blk_lut_in,
  input  wire                       blk_lut_valid,
  input  wire                       lut_wr_disable,

  output reg                        cfg_sec_resp,
  output reg                        gate_req,
  input  wire                       gate_ack,
  input  wire [ADDR_WIDTH-1:0]      sec_info_haddr,
  input  wire [MASTER_WIDTH-1:0]    sec_info_hmaster,
  input  wire                       sec_info_hnonsec,
  input  wire                       sec_info_cfg_ns,
  input  wire                       mpc_irq_trigd,
  output reg                        mpc_irq_clear,
  output reg                        mpc_irq_set,
  output wire                       mpc_irq_mask

);




localparam  [31:0]  ARM_RSVD            = 32'h0;


localparam  [11:0]  ARM_ADDR_CTRL       = 12'h000,
                    ARM_ADDR_BLK_MAX    = 12'h010,
                    ARM_ADDR_BLK_CFG    = 12'h014,
                    ARM_ADDR_BLK_IDX    = 12'h018,
                    ARM_ADDR_BLK_LUT    = 12'h01C,
                    ARM_ADDR_INT_STAT   = 12'h020,
                    ARM_ADDR_INT_CLEAR  = 12'h024,
                    ARM_ADDR_INT_EN     = 12'h028,
                    ARM_ADDR_INT_INFO1  = 12'h02C,
                    ARM_ADDR_INT_INFO2  = 12'h030,
                    ARM_ADDR_INT_SET    = 12'h034,
                    ARM_ADDR_PIDR4      = 12'hFD0,
                    ARM_ADDR_PIDR5      = 12'hFD4,
                    ARM_ADDR_PIDR6      = 12'hFD8,
                    ARM_ADDR_PIDR7      = 12'hFDC,
                    ARM_ADDR_PIDR0      = 12'hFE0,
                    ARM_ADDR_PIDR1      = 12'hFE4,
                    ARM_ADDR_PIDR2      = 12'hFE8,
                    ARM_ADDR_PIDR3      = 12'hFEC,
                    ARM_ADDR_CIDR0      = 12'hFF0,
                    ARM_ADDR_CIDR1      = 12'hFF4,
                    ARM_ADDR_CIDR2      = 12'hFF8,
                    ARM_ADDR_CIDR3      = 12'hFFC;


localparam  [31:0]  ARM_BLK_MAX_VAL     = (1 << LUT_ADDR_WIDTH) - 1;

localparam  [3:0]   ARM_PIDR2_REVISION  = 4'h1;
localparam  [3:0]   ARM_PIDR3_REVAND    = 4'h0;
localparam  [3:0]   ARM_PIDR3_CUST_MOD  = 4'h0;

localparam  [7:0]   ARM_PIDR4_VAL       = 8'h04,
                    ARM_PIDR5_VAL       = 8'h00,
                    ARM_PIDR6_VAL       = 8'h00,
                    ARM_PIDR7_VAL       = 8'h00,
                    ARM_PIDR0_VAL       = 8'h60,
                    ARM_PIDR1_VAL       = 8'hB8,
                    ARM_PIDR2_VAL       = {ARM_PIDR2_REVISION, 4'hB},
                    ARM_PIDR3_VAL       = {ARM_PIDR3_REVAND, ARM_PIDR3_CUST_MOD},
                    ARM_CIDR0_VAL       = 8'h0D,
                    ARM_CIDR1_VAL       = 8'hF0,
                    ARM_CIDR2_VAL       = 8'h05,
                    ARM_CIDR3_VAL       = 8'hB1;

localparam UNUSED_WIDTH            =    2         + 1       + 1;
wire [UNUSED_WIDTH-1:0]     unused = {paddr[1:0], pprot[2], pprot[0]};


wire [11:0]                 addr;
wire                        read_en;
wire                        write_en;
wire [31:0]                 pstrb_mask;
wire [31:0]                 blk_lut_wr_mask;
wire                        blk_idx_autoinc;
reg                         blk_idx_autoinc_en;

reg                         mpc_irq_en;

reg                         sec_cfg_lock;

wire                        sel_addr_ctrl;
wire                        sel_addr_blk_max;
wire                        sel_addr_blk_cfg;
wire                        sel_addr_blk_idx;
wire                        sel_addr_blk_lut;
wire                        sel_addr_int_stat;
wire                        sel_addr_int_clear;
wire                        sel_addr_int_en;
wire                        sel_addr_int_info1;
wire                        sel_addr_int_info2;
wire                        sel_addr_int_set;
wire                        sel_addr_pidr4;
wire                        sel_addr_pidr5;
wire                        sel_addr_pidr6;
wire                        sel_addr_pidr7;
wire                        sel_addr_pidr0;
wire                        sel_addr_pidr1;
wire                        sel_addr_pidr2;
wire                        sel_addr_pidr3;
wire                        sel_addr_cidr0;
wire                        sel_addr_cidr1;
wire                        sel_addr_cidr2;
wire                        sel_addr_cidr3;

wire  [31:0]                rdata_ctrl;
wire  [31:0]                rdata_blk_max;
wire  [31:0]                rdata_blk_cfg;
wire  [31:0]                rdata_blk_idx;
wire  [31:0]                rdata_blk_lut;
wire  [31:0]                rdata_int_stat;
wire  [31:0]                rdata_int_clear;
wire  [31:0]                rdata_int_en;
wire  [31:0]                rdata_int_info1;
wire  [31:0]                rdata_int_info2;
wire  [31:0]                rdata_int_set;
wire  [31:0]                rdata_pidr4;
wire  [31:0]                rdata_pidr5;
wire  [31:0]                rdata_pidr6;
wire  [31:0]                rdata_pidr7;
wire  [31:0]                rdata_pidr0;
wire  [31:0]                rdata_pidr1;
wire  [31:0]                rdata_pidr2;
wire  [31:0]                rdata_pidr3;
wire  [31:0]                rdata_cidr0;
wire  [31:0]                rdata_cidr1;
wire  [31:0]                rdata_cidr2;
wire  [31:0]                rdata_cidr3;

wire  [31:0]                rdata_int_info1_val;

assign pstrb_mask = {{8{pstrb[3]}},{8{pstrb[2]}},{8{pstrb[1]}},{8{pstrb[0]}}};
assign pready     = ~(sel_addr_blk_lut & write_en & lut_wr_disable);
assign pslverr    = 1'b0;

assign read_en    = psel & !pwrite & penable;
assign write_en   = psel & pwrite & penable;
assign addr       = {paddr[11:2],2'b00};



assign sel_addr_ctrl        = ( addr == ARM_ADDR_CTRL       ) & ~pprot[1],
       sel_addr_blk_max     = ( addr == ARM_ADDR_BLK_MAX    ) & ~pprot[1],
       sel_addr_blk_cfg     = ( addr == ARM_ADDR_BLK_CFG    ) & ~pprot[1],
       sel_addr_blk_idx     = ( addr == ARM_ADDR_BLK_IDX    ) & ~pprot[1],
       sel_addr_blk_lut     = ( addr == ARM_ADDR_BLK_LUT    ) & ~pprot[1],
       sel_addr_int_stat    = ( addr == ARM_ADDR_INT_STAT   ) & ~pprot[1],
       sel_addr_int_clear   = ( addr == ARM_ADDR_INT_CLEAR  ) & ~pprot[1],
       sel_addr_int_en      = ( addr == ARM_ADDR_INT_EN     ) & ~pprot[1],
       sel_addr_int_info1   = ( addr == ARM_ADDR_INT_INFO1  ) & ~pprot[1],
       sel_addr_int_info2   = ( addr == ARM_ADDR_INT_INFO2  ) & ~pprot[1],
       sel_addr_int_set     = ( addr == ARM_ADDR_INT_SET    ) & ~pprot[1],
       sel_addr_pidr4       = ( addr == ARM_ADDR_PIDR4      ),
       sel_addr_pidr5       = ( addr == ARM_ADDR_PIDR5      ),
       sel_addr_pidr6       = ( addr == ARM_ADDR_PIDR6      ),
       sel_addr_pidr7       = ( addr == ARM_ADDR_PIDR7      ),
       sel_addr_pidr0       = ( addr == ARM_ADDR_PIDR0      ),
       sel_addr_pidr1       = ( addr == ARM_ADDR_PIDR1      ),
       sel_addr_pidr2       = ( addr == ARM_ADDR_PIDR2      ),
       sel_addr_pidr3       = ( addr == ARM_ADDR_PIDR3      ),
       sel_addr_cidr0       = ( addr == ARM_ADDR_CIDR0      ),
       sel_addr_cidr1       = ( addr == ARM_ADDR_CIDR1      ),
       sel_addr_cidr2       = ( addr == ARM_ADDR_CIDR2      ),
       sel_addr_cidr3       = ( addr == ARM_ADDR_CIDR3      );




always @ (posedge pclk or negedge presetn) begin
  if(!presetn) begin
    gate_req          <= 1'b0;
    cfg_sec_resp      <= 1'b0;
    blk_idx_autoinc_en<= LUT_ADDR_WIDTH > 0 ? 1'b1 : 1'b0;
    sec_cfg_lock      <= 1'b0;
  end
  else begin
    if(sel_addr_ctrl & write_en & ~sec_cfg_lock) begin
      if(pstrb[0]) begin
        gate_req      <= GATE_PRESENT ? pwdata[6] : 1'b0;
        cfg_sec_resp  <= pwdata[4];
      end
      if(pstrb[1]) begin
        blk_idx_autoinc_en <= LUT_ADDR_WIDTH > 0 ? pwdata[8] : 1'b0;
      end
      if(pstrb[3]) begin
        sec_cfg_lock  <= pwdata[31];
      end
    end
  end
end

generate
  if(LUT_ADDR_WIDTH > 0) begin: BLK_IDX_NOT_0
    reg  [LUT_ADDR_WIDTH-1:0] blk_idx_reg;
    always @ (posedge pclk or negedge presetn) begin
      if(!presetn) begin
        blk_idx_reg <= {LUT_ADDR_WIDTH{1'b0}};
      end
      else begin
        if(sel_addr_blk_idx & write_en) begin
          blk_idx_reg <= pstrb_mask[LUT_ADDR_WIDTH-1:0] & pwdata[LUT_ADDR_WIDTH-1:0] | (~pstrb_mask[LUT_ADDR_WIDTH-1:0] & blk_idx_reg);
        end
        else if (blk_idx_autoinc & blk_idx_autoinc_en) begin
          blk_idx_reg[LUT_ADDR_WIDTH-1:0] <= blk_idx_reg[LUT_ADDR_WIDTH-1:0] + 1'b1;
        end
      end
    end

    assign blk_idx[LUT_ADDR_WIDTH-1:0] = blk_idx_reg;
    if(LUT_ADDR_WIDTH < 12) begin: UNUSED_LUT_ADDR
      assign blk_idx[11:LUT_ADDR_WIDTH] = {(12-LUT_ADDR_WIDTH){1'b0}};
    end
    assign blk_idx_autoinc  = sel_addr_blk_lut & (read_en | (write_en & (&pstrb[3:0]) & ~lut_wr_disable & ~sec_cfg_lock));
  end
  else begin: BLK_IDX_IS_0
    assign blk_idx          = 12'h000;

    if(LUT_DATA_WIDTH < 32) begin: UNUSED_LUT_DATA
      assign blk_lut_out[31:LUT_DATA_WIDTH] = {(32-LUT_DATA_WIDTH){1'b0}};
      localparam UNUSED_2_WIDTH = 3 * (32-LUT_DATA_WIDTH);
      wire [UNUSED_2_WIDTH-1:0] unused_2 = {blk_lut_in[31:LUT_DATA_WIDTH],blk_lut_wr_mask[31:LUT_DATA_WIDTH], pwdata[31:LUT_DATA_WIDTH]};
    end
  end

endgenerate

assign blk_lut_write = sel_addr_blk_lut & write_en & ~lut_wr_disable & ~sec_cfg_lock;
assign blk_lut_wr_mask = {32{blk_lut_write}} & pstrb_mask;
assign blk_lut_out[LUT_DATA_WIDTH-1:0] = (blk_lut_wr_mask[LUT_DATA_WIDTH-1:0]  & pwdata[LUT_DATA_WIDTH-1:0])   |
                                         (~blk_lut_wr_mask[LUT_DATA_WIDTH-1:0] & blk_lut_in[LUT_DATA_WIDTH-1:0]);


always @ (posedge pclk or negedge presetn) begin
  if(!presetn) begin
    mpc_irq_clear      <= 1'b0;
  end
  else begin
    if(sel_addr_int_clear & write_en) begin
      if(pstrb[0]) begin
        mpc_irq_clear <= pwdata[0];
      end
      else begin
        mpc_irq_clear <= 1'b0;
      end
    end
    else begin
      mpc_irq_clear   <= 1'b0;
    end
  end
end

always @ (posedge pclk or negedge presetn) begin
  if(!presetn) begin
    mpc_irq_en     <= 1'b1;
  end
  else begin
    if(sel_addr_int_en & write_en & ~sec_cfg_lock) begin
      if(pstrb[0]) begin
        mpc_irq_en <= pwdata[0];
      end
    end
  end
end

assign mpc_irq_mask = ~mpc_irq_en;

always @ (posedge pclk or negedge presetn) begin
  if(!presetn) begin
    mpc_irq_set <= 1'b0;
  end
  else begin
    if(sel_addr_int_set & write_en & ~sec_cfg_lock) begin
      if(pstrb[0]) begin
        mpc_irq_set <= pwdata[0];
      end
      else begin
        mpc_irq_set <= 1'b0;
      end
    end
    else begin
      mpc_irq_set   <= 1'b0;
    end
  end
end


generate
if(ADDR_WIDTH==32) begin: GEN_INFO1_VAL_ADDR_IS_32
  assign rdata_int_info1_val  = sec_info_haddr[ADDR_WIDTH-1:0];
end
else begin:  GEN_INFO1_VAL_ADDR_LESS_32
  assign rdata_int_info1_val  = {ARM_RSVD[31:ADDR_WIDTH], sec_info_haddr[ADDR_WIDTH-1:0]};
end
endgenerate


//----------------------------------------------------------------------------
// u_static_reg needs to be preserved during implementation to enable ECO
// changes of PIDR revision and revand values
//----------------------------------------------------------------------------

localparam STAT_REG_WIDTH=12;
wire [STAT_REG_WIDTH-1:0] stat_reg_in;
wire [STAT_REG_WIDTH-1:0] stat_reg_out;

assign stat_reg_in = { ARM_PIDR2_REVISION,
                       ARM_PIDR3_VAL
                     };

sie200_static_reg #(.WIDTH(STAT_REG_WIDTH)) u_static_reg(.clk(pclk),.reset_n(presetn),.static_i(stat_reg_in),.static_o(stat_reg_out));

assign rdata_ctrl           =  {sec_cfg_lock, ARM_RSVD[30:9], ((LUT_ADDR_WIDTH > 0) ? blk_idx_autoinc_en : ARM_RSVD[8]), gate_ack, gate_req, ARM_RSVD[5], cfg_sec_resp, ARM_RSVD[3:0]},
       rdata_blk_max        =  {ARM_BLK_MAX_VAL[31:0]},
       rdata_blk_cfg        =  {~lut_init_done, ARM_RSVD[30:4], BLK_SIZE[3:0]},
       rdata_blk_idx        =  {ARM_RSVD[31:12], blk_idx},
       rdata_blk_lut        =  {32{blk_lut_valid}} & blk_lut_in,
       rdata_int_stat       =  {ARM_RSVD[31:1], mpc_irq_trigd},
       rdata_int_clear      =  {ARM_RSVD[31:0]},
       rdata_int_en         =  {ARM_RSVD[31:1], mpc_irq_en},
       rdata_int_info1      =  rdata_int_info1_val,
       rdata_int_info2      =  {ARM_RSVD[31:18], sec_info_cfg_ns, sec_info_hnonsec, ARM_RSVD[15:MASTER_WIDTH], sec_info_hmaster[MASTER_WIDTH-1:0]},
       rdata_int_set        =  {ARM_RSVD[31:0]},
       rdata_pidr4          =  {ARM_RSVD[31:8], ARM_PIDR4_VAL},
       rdata_pidr5          =  {ARM_RSVD[31:8], ARM_PIDR5_VAL},
       rdata_pidr6          =  {ARM_RSVD[31:8], ARM_PIDR6_VAL},
       rdata_pidr7          =  {ARM_RSVD[31:8], ARM_PIDR7_VAL},
       rdata_pidr0          =  {ARM_RSVD[31:8], ARM_PIDR0_VAL},
       rdata_pidr1          =  {ARM_RSVD[31:8], ARM_PIDR1_VAL},
       rdata_pidr2          =  {ARM_RSVD[31:8], stat_reg_out[11: 8], ARM_PIDR2_VAL[3:0]},
       rdata_pidr3          =  {ARM_RSVD[31:8], stat_reg_out[ 7: 0]},
       rdata_cidr0          =  {ARM_RSVD[31:8], ARM_CIDR0_VAL},
       rdata_cidr1          =  {ARM_RSVD[31:8], ARM_CIDR1_VAL},
       rdata_cidr2          =  {ARM_RSVD[31:8], ARM_CIDR2_VAL},
       rdata_cidr3          =  {ARM_RSVD[31:8], ARM_CIDR3_VAL};


assign prdata = {32{read_en}} & (
                ( {32{sel_addr_ctrl       }} & rdata_ctrl       ) |
                ( {32{sel_addr_blk_max    }} & rdata_blk_max    ) |
                ( {32{sel_addr_blk_cfg    }} & rdata_blk_cfg    ) |
                ( {32{sel_addr_blk_idx    }} & rdata_blk_idx    ) |
                ( {32{sel_addr_blk_lut    }} & rdata_blk_lut    ) |
                ( {32{sel_addr_int_stat   }} & rdata_int_stat   ) |
                ( {32{sel_addr_int_clear  }} & rdata_int_clear  ) |
                ( {32{sel_addr_int_en     }} & rdata_int_en     ) |
                ( {32{sel_addr_int_info1  }} & rdata_int_info1  ) |
                ( {32{sel_addr_int_info2  }} & rdata_int_info2  ) |
                ( {32{sel_addr_int_set    }} & rdata_int_set    ) |
                ( {32{sel_addr_pidr4      }} & rdata_pidr4      ) |
                ( {32{sel_addr_pidr5      }} & rdata_pidr5      ) |
                ( {32{sel_addr_pidr6      }} & rdata_pidr6      ) |
                ( {32{sel_addr_pidr7      }} & rdata_pidr7      ) |
                ( {32{sel_addr_pidr0      }} & rdata_pidr0      ) |
                ( {32{sel_addr_pidr1      }} & rdata_pidr1      ) |
                ( {32{sel_addr_pidr2      }} & rdata_pidr2      ) |
                ( {32{sel_addr_pidr3      }} & rdata_pidr3      ) |
                ( {32{sel_addr_cidr0      }} & rdata_cidr0      ) |
                ( {32{sel_addr_cidr1      }} & rdata_cidr1      ) |
                ( {32{sel_addr_cidr2      }} & rdata_cidr2      ) |
                ( {32{sel_addr_cidr3      }} & rdata_cidr3      )
                );









endmodule

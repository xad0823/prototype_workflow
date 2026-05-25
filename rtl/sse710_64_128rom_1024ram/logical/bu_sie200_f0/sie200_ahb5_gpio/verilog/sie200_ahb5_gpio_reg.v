//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2015-2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Checked In          : Thu Nov 24 15:58:29 2016 +0000
//
//      Revision            : e0ef05f
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_gpio_reg #(
  parameter  ALTERNATE_FUNC_MASK     = 16'hFFFF,

  parameter  ALTERNATE_FUNC_DEFAULT  = 16'h0000,

  parameter  PORT_NONSEC_MASK        = 16'h0000)
  (
    input  wire                   hclk,
    input  wire                   fclk,
    input  wire                   hresetn,

    input  wire [11:0]            addr,
    input  wire                   nonsec,
    input  wire                   trans_req,
    output wire                   sec_acc_err,

    input  wire [11:0]            addr_reg,
    input  wire                   read_en,
    input  wire                   write_en,
    input  wire [3:0]             byte_strobe,
    input  wire [31:0]            wdata,
    output wire [31:0]            rdata,


    input  wire [15:0]            port_in,
    output wire [15:0]            port_out,
    output wire [15:0]            port_en,
    output wire [15:0]            port_func,

    output wire [15:0]            gpio_sec_irq,
    output wire [15:0]            gpio_nonsec_irq,
    output wire                   comb_sec_irq,
    output wire                   comb_nonsec_irq,
    output wire                   sec_acc_irq,
    input  wire                   sec_acc_irq_enable
  );




localparam PW         = 16;

localparam  [31:0]  ARM_RSVD                    = 32'h0;


localparam  [11:0]  ARM_ADDR_DATA_IN            = 12'h000,
                    ARM_ADDR_DATA_OUT           = 12'h004,
                    ARM_ADDR_OUT_EN_SET         = 12'h010,
                    ARM_ADDR_OUT_EN_CLR         = 12'h014,
                    ARM_ADDR_ALT_FUNC_SET       = 12'h018,
                    ARM_ADDR_ALT_FUNC_CLR       = 12'h01C,
                    ARM_ADDR_INT_EN_SET         = 12'h020,
                    ARM_ADDR_INT_EN_CLR         = 12'h024,
                    ARM_ADDR_INT_TYPE_SET       = 12'h028,
                    ARM_ADDR_INT_TYPE_CLR       = 12'h02C,
                    ARM_ADDR_INT_POL_SET        = 12'h030,
                    ARM_ADDR_INT_POL_CLR        = 12'h034,
                    ARM_ADDR_INT_STATUS         = 12'h038,
                    ARM_ADDR_SEC_INT_STAT       = 12'h040,
                    ARM_ADDR_SEC_INT_CLR        = 12'h044,
                    ARM_ADDR_SEC_INT_MASK       = 12'h048,
                    ARM_ADDR_SEC_INT_INFO1      = 12'h04C,
                    ARM_ADDR_SEC_INT_INFO2      = 12'h050,
                    ARM_ADDR_SEC_INT_SET        = 12'h054,
                    ARM_ADDR_PORT_NONSEC_MASK   = 12'h058,
                    ARM_ADDR_MASK_LOW_BYTE_BASE = 12'h400,
                    ARM_ADDR_MASK_HIGH_BYTE_BASE= 12'h800,
                    ARM_ADDR_PIDR4              = 12'hFD0,
                    ARM_ADDR_PIDR5              = 12'hFD4,
                    ARM_ADDR_PIDR6              = 12'hFD8,
                    ARM_ADDR_PIDR7              = 12'hFDC,
                    ARM_ADDR_PIDR0              = 12'hFE0,
                    ARM_ADDR_PIDR1              = 12'hFE4,
                    ARM_ADDR_PIDR2              = 12'hFE8,
                    ARM_ADDR_PIDR3              = 12'hFEC,
                    ARM_ADDR_CIDR0              = 12'hFF0,
                    ARM_ADDR_CIDR1              = 12'hFF4,
                    ARM_ADDR_CIDR2              = 12'hFF8,
                    ARM_ADDR_CIDR3              = 12'hFFC;


localparam  [3:0]   ARM_PIDR2_REVISION          = 4'h0;
localparam  [3:0]   ARM_PIDR3_REVAND            = 4'h0;
localparam  [3:0]   ARM_PIDR3_CUST_MOD          = 4'h0;

localparam  [7:0]   ARM_PIDR4_VAL               = 8'h04,
                    ARM_PIDR5_VAL               = 8'h00,
                    ARM_PIDR6_VAL               = 8'h00,
                    ARM_PIDR7_VAL               = 8'h00,
                    ARM_PIDR0_VAL               = 8'h62,
                    ARM_PIDR1_VAL               = 8'hB8,
                    ARM_PIDR2_VAL               = {ARM_PIDR2_REVISION, 4'hB},
                    ARM_PIDR3_VAL               = {ARM_PIDR3_REVAND, ARM_PIDR3_CUST_MOD},
                    ARM_CIDR0_VAL               = 8'h0D,
                    ARM_CIDR1_VAL               = 8'hF0,
                    ARM_CIDR2_VAL               = 8'h05,
                    ARM_CIDR3_VAL               = 8'hB1;


localparam [11:0]   ARM_MASKBYTE_RANGE          = 12'hC00;




reg                         nonsec_reg;

wire                        sel_addr_datain;
wire                        sel_addr_dataout;
wire                        sel_addr_outenset;
wire                        sel_addr_outenclr;
wire                        sel_addr_altfuncset;
wire                        sel_addr_altfuncclr;
wire                        sel_addr_intenset;
wire                        sel_addr_intenclr;
wire                        sel_addr_inttypeset;
wire                        sel_addr_inttypeclr;
wire                        sel_addr_intpolset;
wire                        sel_addr_intpolclr;
wire                        sel_addr_intstatus;
wire                        sel_addr_secintstat;
wire                        sel_addr_secintclr;
wire                        sel_addr_secintmask;
wire                        sel_addr_secintinfo1;
wire                        sel_addr_secintinfo2;
wire                        sel_addr_secintset;
wire                        sel_addr_portnonsecmask;
wire                        sel_addr_masklowbyte;
wire                        sel_addr_maskhighbyte;
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

wire  [31:0]                rdata_datain;
wire  [31:0]                rdata_dataout;
wire  [31:0]                rdata_outenset;
wire  [31:0]                rdata_outenclr;
wire  [31:0]                rdata_altfuncset;
wire  [31:0]                rdata_altfuncclr;
wire  [31:0]                rdata_intenset;
wire  [31:0]                rdata_intenclr;
wire  [31:0]                rdata_inttypeset;
wire  [31:0]                rdata_inttypeclr;
wire  [31:0]                rdata_intpolset;
wire  [31:0]                rdata_intpolclr;
wire  [31:0]                rdata_intstatus;
wire  [31:0]                rdata_secintstat;
wire  [31:0]                rdata_secintmask;
wire  [31:0]                rdata_secintinfo1;
wire  [31:0]                rdata_secintinfo2;
wire  [31:0]                rdata_portnonsecmask;
wire  [31:0]                rdata_masklowbyte;
wire  [31:0]                rdata_maskhighbyte;
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

wire  [PW-1:0]              sec_acc_bitmask;
wire  [15:0]                sec_acc_din_mask;
reg                         sec_acc_err_reg;
wire                        sec_acc_bitmask_err;
wire                        sec_acc_setclr_err;
wire                        sec_acc_maskbyte_err;
reg                         sec_acc_irq_enable_reg;

wire  [15:0]                reg_din;
wire  [PW-1:0]              reg_din_d;
wire  [PW-1:0]              reg_din_d_en;
wire  [PW-1:0]              reg_din_d_inten;
wire  [PW-1:0]              reg_din_d_type;
reg   [PW-1:0]              reg_dout;
reg   [PW-1:0]              reg_douten;
reg   [PW-1:0]              reg_altfunc;
reg   [PW-1:0]              reg_inten;
reg   [PW-1:0]              reg_inttype;
reg   [PW-1:0]              reg_intpol;
reg   [PW-1:0]              reg_intstat;
wire  [PW-1:0]              reg_intstat_set;
wire  [PW-1:0]              high_level_int;
wire  [PW-1:0]              low_level_int;
wire  [PW-1:0]              rise_edge_int;
wire  [PW-1:0]              fall_edge_int;

reg                         sec_acc_irq_stat;
wire                        sec_acc_irq_clr;
wire                        sec_acc_irq_set;
reg                         sec_acc_irq_mask;
reg                         sec_acc_bitchk_mask;
reg   [17:0]                sec_acc_info1;
reg   [31:0]                sec_acc_info2;
wire  [PW-1:0]              sec_wdata_val;
wire  [PW-1:0]              wdata_val;



genvar i;
generate
  for(i=0;i<16;i=i+1) begin: GEN_IN_OUT_PORTS
    if(i < PW) begin: GEN_IN_OUT_UNTIL_PW_MAX
      sie200_sync     u_sync_datain   (.clk(fclk), .reset_n(hresetn), .d(port_in[i]), .q(reg_din[i]));
      sie200_flop_en  u_flop_datain_d (.clk(fclk), .reset_n(hresetn), .d(reg_din[i]), .q(reg_din_d[i]), .en(reg_din_d_en[i]));

      assign port_out[i]          = reg_dout[i];
      assign port_en[i]           = reg_douten[i];
      assign port_func[i]         = reg_altfunc[i];
      assign gpio_sec_irq[i]      = reg_intstat[i] & ~PORT_NONSEC_MASK[i];
      assign gpio_nonsec_irq[i]   = reg_intstat[i] & PORT_NONSEC_MASK[i];
      assign sec_acc_din_mask[i]  = sec_acc_bitmask[i];
    end
    else begin: GEN_IN_OUT_OVER_PW_MAX
      assign reg_din[i]           = 1'b0;
      assign port_out[i]          = 1'b0;
      assign port_en[i]           = 1'b0;
      assign port_func[i]         = 1'b0;
      assign gpio_sec_irq[i]      = 1'b0;
      assign gpio_nonsec_irq[i]   = 1'b0;
      assign sec_acc_din_mask[i]  = 1'b0;
    end
  end




  if(PW < 9) begin: GEN_SEC_ACC_PORT_WIDTH_MAX_8
    assign wdata_val[PW-1:0]      = wdata[PW-1:0] & {PW{byte_strobe[0]}};
    assign sec_acc_maskbyte_err   = write_en &
                                   (sel_addr_masklowbyte & byte_strobe[0] & |(addr_reg[PW+1:2] & (addr_reg[PW+1:2] ^ sec_acc_bitmask)));
  end
  else begin: GEN_SEC_ACC_PORT_WIDTH_MORE_THAN_8
    assign wdata_val[7:0]         = wdata[7:0]    & {8{byte_strobe[0]}};
    assign wdata_val[PW-1:8]      = wdata[PW-1:8] & {(PW-8){byte_strobe[1]}};
    assign sec_acc_maskbyte_err   = write_en &
                                   ((sel_addr_masklowbyte  & byte_strobe[0] & |(addr_reg[9:2]    & (addr_reg[9:2]    ^ sec_acc_bitmask[7:0])))   |
                                    (sel_addr_maskhighbyte & byte_strobe[1] & |(addr_reg[PW-7:2] & (addr_reg[PW-7:2] ^ sec_acc_bitmask[PW-1:8]))));
  end

endgenerate


assign sec_acc_bitmask      = nonsec_reg ? PORT_NONSEC_MASK[PW-1:0] : ~PORT_NONSEC_MASK[PW-1:0];
assign sec_wdata_val        = wdata_val & sec_acc_bitmask;
assign sec_acc_setclr_err   = write_en & |(wdata_val & (wdata_val ^ sec_acc_bitmask)) & (
                              sel_addr_outenset       |
                              sel_addr_outenclr       |
                              sel_addr_altfuncset     |
                              sel_addr_altfuncclr     |
                              sel_addr_intenset       |
                              sel_addr_intenclr       |
                              sel_addr_inttypeset     |
                              sel_addr_inttypeclr     |
                              sel_addr_intpolset      |
                              sel_addr_intpolclr      |
                              sel_addr_intstatus      );

assign sec_acc_bitmask_err  = (sec_acc_setclr_err | sec_acc_maskbyte_err) & ~sec_acc_bitchk_mask;


assign sec_acc_err = trans_req & nonsec & ((addr == ARM_ADDR_SEC_INT_STAT     ) ||
                                           (addr == ARM_ADDR_SEC_INT_CLR      ) ||
                                           (addr == ARM_ADDR_SEC_INT_MASK     ) ||
                                           (addr == ARM_ADDR_SEC_INT_INFO1    ) ||
                                           (addr == ARM_ADDR_SEC_INT_INFO2    ) ||
                                           (addr == ARM_ADDR_SEC_INT_SET      ) ||
                                           (addr == ARM_ADDR_PORT_NONSEC_MASK ));


assign sel_addr_datain            = ( addr_reg == ARM_ADDR_DATA_IN          ),
       sel_addr_dataout           = ( addr_reg == ARM_ADDR_DATA_OUT         ),
       sel_addr_outenset          = ( addr_reg == ARM_ADDR_OUT_EN_SET       ),
       sel_addr_outenclr          = ( addr_reg == ARM_ADDR_OUT_EN_CLR       ),
       sel_addr_altfuncset        = ( addr_reg == ARM_ADDR_ALT_FUNC_SET     ),
       sel_addr_altfuncclr        = ( addr_reg == ARM_ADDR_ALT_FUNC_CLR     ),
       sel_addr_intenset          = ( addr_reg == ARM_ADDR_INT_EN_SET       ),
       sel_addr_intenclr          = ( addr_reg == ARM_ADDR_INT_EN_CLR       ),
       sel_addr_inttypeset        = ( addr_reg == ARM_ADDR_INT_TYPE_SET     ),
       sel_addr_inttypeclr        = ( addr_reg == ARM_ADDR_INT_TYPE_CLR     ),
       sel_addr_intpolset         = ( addr_reg == ARM_ADDR_INT_POL_SET      ),
       sel_addr_intpolclr         = ( addr_reg == ARM_ADDR_INT_POL_CLR      ),
       sel_addr_intstatus         = ( addr_reg == ARM_ADDR_INT_STATUS       ),
       sel_addr_secintstat        = ( addr_reg == ARM_ADDR_SEC_INT_STAT     ) & !nonsec_reg,
       sel_addr_secintclr         = ( addr_reg == ARM_ADDR_SEC_INT_CLR      ) & !nonsec_reg,
       sel_addr_secintmask        = ( addr_reg == ARM_ADDR_SEC_INT_MASK     ) & !nonsec_reg,
       sel_addr_secintinfo1       = ( addr_reg == ARM_ADDR_SEC_INT_INFO1    ) & !nonsec_reg,
       sel_addr_secintinfo2       = ( addr_reg == ARM_ADDR_SEC_INT_INFO2    ) & !nonsec_reg,
       sel_addr_secintset         = ( addr_reg == ARM_ADDR_SEC_INT_SET      ) & !nonsec_reg,
       sel_addr_portnonsecmask    = ( addr_reg == ARM_ADDR_PORT_NONSEC_MASK ) & !nonsec_reg,
       sel_addr_masklowbyte       = ( (addr_reg & ARM_MASKBYTE_RANGE) == ARM_ADDR_MASK_LOW_BYTE_BASE  ),
       sel_addr_maskhighbyte      = ( (addr_reg & ARM_MASKBYTE_RANGE) == ARM_ADDR_MASK_HIGH_BYTE_BASE ),
       sel_addr_pidr4             = ( addr_reg == ARM_ADDR_PIDR4             ),
       sel_addr_pidr5             = ( addr_reg == ARM_ADDR_PIDR5             ),
       sel_addr_pidr6             = ( addr_reg == ARM_ADDR_PIDR6             ),
       sel_addr_pidr7             = ( addr_reg == ARM_ADDR_PIDR7             ),
       sel_addr_pidr0             = ( addr_reg == ARM_ADDR_PIDR0             ),
       sel_addr_pidr1             = ( addr_reg == ARM_ADDR_PIDR1             ),
       sel_addr_pidr2             = ( addr_reg == ARM_ADDR_PIDR2             ),
       sel_addr_pidr3             = ( addr_reg == ARM_ADDR_PIDR3             ),
       sel_addr_cidr0             = ( addr_reg == ARM_ADDR_CIDR0             ),
       sel_addr_cidr1             = ( addr_reg == ARM_ADDR_CIDR1             ),
       sel_addr_cidr2             = ( addr_reg == ARM_ADDR_CIDR2             ),
       sel_addr_cidr3             = ( addr_reg == ARM_ADDR_CIDR3             );



always @(posedge hclk or negedge hresetn) begin
  if (!hresetn) begin
    sec_acc_err_reg         <= 1'b0;
    nonsec_reg              <= 1'b0;
    sec_acc_irq_enable_reg  <= 1'b0;
  end
  else if (trans_req) begin
    sec_acc_err_reg         <= sec_acc_err;
    nonsec_reg              <= nonsec;
    sec_acc_irq_enable_reg  <= sec_acc_irq_enable;
  end
end




generate
  if(PW < 9) begin: GEN_DATA_OUT_PORT_WIDTH_MAX_8
    always @ (posedge hclk or negedge hresetn) begin
      if(!hresetn) begin
        reg_dout <= {PW{1'b0}};
      end
      else begin
        if((sel_addr_dataout | sel_addr_datain) & write_en) begin
          reg_dout <= sec_wdata_val;
        end
        else if(sel_addr_masklowbyte & write_en) begin
          reg_dout[PW-1:0]  <= (reg_dout[PW-1:0] & ~(addr_reg[PW+1:2] & sec_acc_bitmask)) | (sec_wdata_val[PW-1:0] & addr_reg[PW+1:2]);
        end
      end
    end
  end
  else begin: GEN_DATA_OUT_PORT_WIDTH_MORE_THAN_8
    always @ (posedge hclk or negedge hresetn) begin
      if(!hresetn) begin
        reg_dout <= {PW{1'b0}};
      end
      else begin
        if((sel_addr_dataout | sel_addr_datain) & write_en) begin
          reg_dout <= sec_wdata_val;
        end
        else if(sel_addr_masklowbyte & write_en) begin
          reg_dout[7:0]     <= (reg_dout[7:0] & ~(addr_reg[9:2] & sec_acc_bitmask[7:0])) | (sec_wdata_val[7:0] & addr_reg[9:2]);
        end
        else if(sel_addr_maskhighbyte & write_en) begin
          reg_dout[PW-1:8]  <= (reg_dout[PW-1:8] & ~(addr_reg[PW-7:2] & sec_acc_bitmask[PW-1:8])) | (sec_wdata_val[PW-1:8] & addr_reg[PW-7:2]);
        end
      end
    end
  end
endgenerate



always @ (posedge hclk or negedge hresetn) begin
  if(!hresetn) begin
    reg_douten <= {PW{1'b0}};
  end
  else begin
    if(sel_addr_outenset & write_en) begin
      reg_douten <= reg_douten | sec_wdata_val;
    end
    else if(sel_addr_outenclr & write_en) begin
      reg_douten <= reg_douten & ~sec_wdata_val;
    end
  end
end


always @ (posedge hclk or negedge hresetn) begin
  if(!hresetn) begin
    reg_altfunc <= ALTERNATE_FUNC_DEFAULT[PW-1:0] & ALTERNATE_FUNC_MASK[PW-1:0];
  end
  else begin
    if(sel_addr_altfuncset & write_en) begin
      reg_altfunc <= reg_altfunc | (sec_wdata_val & ALTERNATE_FUNC_MASK[PW-1:0]);
    end
    else if(sel_addr_altfuncclr & write_en) begin
      reg_altfunc <= reg_altfunc & ~(sec_wdata_val & ALTERNATE_FUNC_MASK[PW-1:0]);
    end
  end
end

always @ (posedge hclk or negedge hresetn) begin
  if(!hresetn) begin
    reg_inten <= {PW{1'b0}};
  end
  else begin
    if(sel_addr_intenset & write_en) begin
      reg_inten <= reg_inten | sec_wdata_val;
    end
    else if(sel_addr_intenclr & write_en) begin
      reg_inten <= reg_inten & ~sec_wdata_val;
    end
  end
end

always @ (posedge hclk or negedge hresetn) begin
  if(!hresetn) begin
    reg_inttype <= {PW{1'b0}};
  end
  else begin
    if(sel_addr_inttypeset & write_en) begin
      reg_inttype <= reg_inttype | sec_wdata_val;
    end
    else if(sel_addr_inttypeclr & write_en) begin
      reg_inttype <= reg_inttype & ~sec_wdata_val;
    end
  end
end

always @ (posedge hclk or negedge hresetn) begin
  if(!hresetn) begin
    reg_intpol <= {PW{1'b0}};
  end
  else begin
    if(sel_addr_intpolset & write_en) begin
      reg_intpol <= reg_intpol | sec_wdata_val;
    end
    else if(sel_addr_intpolclr & write_en) begin
      reg_intpol <= reg_intpol & ~sec_wdata_val;
    end
  end
end

integer j;

always @ (posedge fclk or negedge hresetn) begin
  if(!hresetn) begin
    reg_intstat <= {PW{1'b0}};
  end
  else begin
    for(j=0;j<PW;j=j+1) begin
      if(reg_intstat_set[j]) begin
        reg_intstat[j] <= reg_intstat[j] | reg_intstat_set[j];
      end
      else if(sel_addr_intstatus & write_en) begin
        reg_intstat[j] <= reg_intstat[j] & ~sec_wdata_val[j];
      end
    end
  end
end

assign high_level_int   =  reg_din[PW-1:0] &               reg_intpol & ~reg_inttype;
assign low_level_int    = ~reg_din[PW-1:0] &              ~reg_intpol & ~reg_inttype;
assign rise_edge_int    =  reg_din[PW-1:0] & ~reg_din_d &  reg_intpol &  reg_inttype;
assign fall_edge_int    = ~reg_din[PW-1:0] &  reg_din_d & ~reg_intpol &  reg_inttype;

assign reg_intstat_set  = (high_level_int | low_level_int | rise_edge_int | fall_edge_int) & reg_inten;


assign reg_din_d_inten  = sel_addr_intenset   & write_en ? (reg_inten   | sec_wdata_val)  : reg_inten;
assign reg_din_d_type   = sel_addr_inttypeset & write_en ? (reg_inttype | sec_wdata_val)  : reg_inttype;
assign reg_din_d_en     = reg_din_d_inten & reg_din_d_type;

always @ (posedge hclk or negedge hresetn) begin
  if(!hresetn) begin
    sec_acc_irq_stat  <= 1'b0;
  end
  else begin
    sec_acc_irq_stat  <= (sec_acc_irq_stat & ~sec_acc_irq_clr) | sec_acc_irq_set;
  end
end

assign sec_acc_irq_clr = sel_addr_secintclr & write_en & byte_strobe[0] & wdata[0];
assign sec_acc_irq_set = ((sec_acc_err_reg | sec_acc_bitmask_err) & sec_acc_irq_enable_reg) |
                          (sel_addr_secintset & write_en & byte_strobe[0] & wdata[0]);

always @ (posedge hclk or negedge hresetn) begin
  if(!hresetn) begin
    sec_acc_irq_mask    <= 1'b0;
    sec_acc_bitchk_mask <= 1'b0;
  end
  else begin
    if(sel_addr_secintmask & write_en & byte_strobe[0]) begin
      sec_acc_irq_mask    <= wdata[0];
      sec_acc_bitchk_mask <= wdata[1];
    end
  end
end


always @ (posedge hclk or negedge hresetn) begin
  if(!hresetn) begin
    sec_acc_info1   <= 18'h0;
    sec_acc_info2   <= 32'h0;
  end
  else begin
    if(sec_acc_irq_set & (~sec_acc_irq_stat | sec_acc_irq_clr)) begin
      sec_acc_info1   <= {write_en, nonsec_reg, byte_strobe, addr_reg};
      sec_acc_info2   <= wdata;
    end
  end
end





//----------------------------------------------------------------------------
// u_static_reg needs to be preserved during implementation to enable ECO
// changes of PIDR revision and revand values
//----------------------------------------------------------------------------

localparam STAT_REG_WIDTH = 12;
wire [STAT_REG_WIDTH-1:0] stat_reg_in;
wire [STAT_REG_WIDTH-1:0] stat_reg_out;

assign stat_reg_in = { ARM_PIDR2_REVISION,
                       ARM_PIDR3_VAL
                     };

sie200_static_reg #(.WIDTH(STAT_REG_WIDTH)) u_static_reg(.clk(hclk),.reset_n(hresetn),.static_i(stat_reg_in),.static_o(stat_reg_out));

assign rdata_datain               =  {ARM_RSVD[31:PW], sec_acc_bitmask & reg_din[PW-1:0]},
       rdata_dataout              =  {ARM_RSVD[31:PW], sec_acc_bitmask & reg_dout},
       rdata_outenset             =  {ARM_RSVD[31:PW], sec_acc_bitmask & reg_douten},
       rdata_outenclr             =  {ARM_RSVD[31:PW], sec_acc_bitmask & reg_douten},
       rdata_altfuncset           =  {ARM_RSVD[31:PW], sec_acc_bitmask & reg_altfunc},
       rdata_altfuncclr           =  {ARM_RSVD[31:PW], sec_acc_bitmask & reg_altfunc},
       rdata_intenset             =  {ARM_RSVD[31:PW], sec_acc_bitmask & reg_inten},
       rdata_intenclr             =  {ARM_RSVD[31:PW], sec_acc_bitmask & reg_inten},
       rdata_inttypeset           =  {ARM_RSVD[31:PW], sec_acc_bitmask & reg_inttype},
       rdata_inttypeclr           =  {ARM_RSVD[31:PW], sec_acc_bitmask & reg_inttype},
       rdata_intpolset            =  {ARM_RSVD[31:PW], sec_acc_bitmask & reg_intpol},
       rdata_intpolclr            =  {ARM_RSVD[31:PW], sec_acc_bitmask & reg_intpol},
       rdata_intstatus            =  {ARM_RSVD[31:PW], sec_acc_bitmask & reg_intstat},
       rdata_secintstat           =  {ARM_RSVD[31:1],  sec_acc_irq_stat},
       rdata_secintmask           =  {ARM_RSVD[31:1],  sec_acc_irq_mask},
       rdata_secintinfo1          =  {ARM_RSVD[31:18], sec_acc_info1},
       rdata_secintinfo2          =  {                 sec_acc_info2},
       rdata_portnonsecmask       =  {ARM_RSVD[31:PW], PORT_NONSEC_MASK},
       rdata_masklowbyte          =  {ARM_RSVD[31:8],  sec_acc_din_mask[7:0]  & reg_din[7:0]   & addr_reg[9:2]},
       rdata_maskhighbyte         =  {ARM_RSVD[31:16], sec_acc_din_mask[15:8] & reg_din[15:8]  & addr_reg[9:2], ARM_RSVD[7:0]},
       rdata_pidr4                =  {ARM_RSVD[31:8],  ARM_PIDR4_VAL},
       rdata_pidr5                =  {ARM_RSVD[31:8],  ARM_PIDR5_VAL},
       rdata_pidr6                =  {ARM_RSVD[31:8],  ARM_PIDR6_VAL},
       rdata_pidr7                =  {ARM_RSVD[31:8],  ARM_PIDR7_VAL},
       rdata_pidr0                =  {ARM_RSVD[31:8],  ARM_PIDR0_VAL},
       rdata_pidr1                =  {ARM_RSVD[31:8],  ARM_PIDR1_VAL},
       rdata_pidr2                =  {ARM_RSVD[31:8],  stat_reg_out[11: 8], ARM_PIDR2_VAL[3:0]},
       rdata_pidr3                =  {ARM_RSVD[31:8],  stat_reg_out[ 7: 0]},
       rdata_cidr0                =  {ARM_RSVD[31:8],  ARM_CIDR0_VAL},
       rdata_cidr1                =  {ARM_RSVD[31:8],  ARM_CIDR1_VAL},
       rdata_cidr2                =  {ARM_RSVD[31:8],  ARM_CIDR2_VAL},
       rdata_cidr3                =  {ARM_RSVD[31:8],  ARM_CIDR3_VAL};


assign rdata     = {32{read_en}} & (
                 ( {32{sel_addr_datain            }} & rdata_datain            ) |
                 ( {32{sel_addr_dataout           }} & rdata_dataout           ) |
                 ( {32{sel_addr_outenset          }} & rdata_outenset          ) |
                 ( {32{sel_addr_outenclr          }} & rdata_outenclr          ) |
                 ( {32{sel_addr_altfuncset        }} & rdata_altfuncset        ) |
                 ( {32{sel_addr_altfuncclr        }} & rdata_altfuncclr        ) |
                 ( {32{sel_addr_intenset          }} & rdata_intenset          ) |
                 ( {32{sel_addr_intenclr          }} & rdata_intenclr          ) |
                 ( {32{sel_addr_inttypeset        }} & rdata_inttypeset        ) |
                 ( {32{sel_addr_inttypeclr        }} & rdata_inttypeclr        ) |
                 ( {32{sel_addr_intpolset         }} & rdata_intpolset         ) |
                 ( {32{sel_addr_intpolclr         }} & rdata_intpolclr         ) |
                 ( {32{sel_addr_intstatus         }} & rdata_intstatus         ) |
                 ( {32{sel_addr_secintstat        }} & rdata_secintstat        ) |
                 ( {32{sel_addr_secintmask        }} & rdata_secintmask        ) |
                 ( {32{sel_addr_secintinfo1       }} & rdata_secintinfo1       ) |
                 ( {32{sel_addr_secintinfo2       }} & rdata_secintinfo2       ) |
                 ( {32{sel_addr_portnonsecmask    }} & rdata_portnonsecmask    ) |
                 ( {32{sel_addr_masklowbyte       }} & rdata_masklowbyte       ) |
                 ( {32{sel_addr_maskhighbyte      }} & rdata_maskhighbyte      ) |
                 ( {32{sel_addr_pidr4             }} & rdata_pidr4             ) |
                 ( {32{sel_addr_pidr5             }} & rdata_pidr5             ) |
                 ( {32{sel_addr_pidr6             }} & rdata_pidr6             ) |
                 ( {32{sel_addr_pidr7             }} & rdata_pidr7             ) |
                 ( {32{sel_addr_pidr0             }} & rdata_pidr0             ) |
                 ( {32{sel_addr_pidr1             }} & rdata_pidr1             ) |
                 ( {32{sel_addr_pidr2             }} & rdata_pidr2             ) |
                 ( {32{sel_addr_pidr3             }} & rdata_pidr3             ) |
                 ( {32{sel_addr_cidr0             }} & rdata_cidr0             ) |
                 ( {32{sel_addr_cidr1             }} & rdata_cidr1             ) |
                 ( {32{sel_addr_cidr2             }} & rdata_cidr2             ) |
                 ( {32{sel_addr_cidr3             }} & rdata_cidr3             )
                 );

assign comb_sec_irq     = |gpio_sec_irq;
assign comb_nonsec_irq  = |gpio_nonsec_irq;
assign sec_acc_irq      = sec_acc_irq_stat & ~sec_acc_irq_mask;









endmodule

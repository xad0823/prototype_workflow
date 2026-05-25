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
//      Checked In          : Thu Dec 1 16:03:15 2016 +0000
//
//      Revision            : 6ca04ec
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_eg_slave_reg
 (
  input  wire          hclk,
  input  wire          hresetn,

  input  wire [11:0]   addr,
  input  wire          nonsec,
  input  wire          trans_req,
  input  wire [11:0]   addr_reg,
  input  wire          read_en,
  input  wire          write_en,
  input  wire [3:0]    byte_strobe,
  input  wire [31:0]   wdata,
  output reg  [31:0]   rdata,
  output wire          sec_acc_err,

  input  wire                   eg_slv_irq_enable,
  output wire                   eg_slv_irq
  );


  reg    [31:0]  ns_data0;
  reg    [31:0]  ns_data1;
  reg    [31:0]  ns_data2;
  reg    [31:0]  ns_data3;
  reg    [31:0]  s_data0;
  reg    [31:0]  s_data1;
  reg    [31:0]  s_data2;
  reg    [31:0]  s_data3;
  reg    [31:0]  unchk_data0;
  reg    [31:0]  unchk_data1;
  reg    [31:0]  unchk_data2;
  reg    [31:0]  unchk_data3;
  reg            int_stat;
  reg            int_mask;
  reg            sec_acc_err_reg;

  wire [5:0]  unused = {addr[3:0],addr_reg[1:0]};

  localparam  [31:0] ARM_RSVD               = 32'h0;
  localparam  [3:0]  ARM_PIDR2_REVISION     = 4'h0;
  localparam  [3:0]  ARM_PIDR3_REVAND       = 4'h0;
  localparam  [3:0]  ARM_PIDR3_CUST_MOD     = 4'h0;

  localparam  [7:0] ARM_VAL_PIDR4 = 8'h04,
                    ARM_VAL_PIDR5 = 8'h00,
                    ARM_VAL_PIDR6 = 8'h00,
                    ARM_VAL_PIDR7 = 8'h00,
                    ARM_VAL_PIDR0 = 8'h61,
                    ARM_VAL_PIDR1 = 8'hB8,
                    ARM_VAL_PIDR2 = {ARM_PIDR2_REVISION, 4'hB},
                    ARM_VAL_PIDR3 = {ARM_PIDR3_REVAND, ARM_PIDR3_CUST_MOD},
                    ARM_VAL_CIDR0 = 8'h0D,
                    ARM_VAL_CIDR1 = 8'hF0,
                    ARM_VAL_CIDR2 = 8'h05,
                    ARM_VAL_CIDR3 = 8'hB1;


  localparam [3:0] ARM_ADDR_NS_DATA0    = 4'b0000,
                   ARM_ADDR_NS_DATA1    = 4'b0001,
                   ARM_ADDR_NS_DATA2    = 4'b0010,
                   ARM_ADDR_NS_DATA3    = 4'b0011,
                   ARM_ADDR_S_DATA0     = 4'b0100,
                   ARM_ADDR_S_DATA1     = 4'b0101,
                   ARM_ADDR_S_DATA2     = 4'b0110,
                   ARM_ADDR_S_DATA3     = 4'b0111,
                   ARM_ADDR_UNCHK_DATA0 = 4'b1000,
                   ARM_ADDR_UNCHK_DATA1 = 4'b1001,
                   ARM_ADDR_UNCHK_DATA2 = 4'b1010,
                   ARM_ADDR_UNCHK_DATA3 = 4'b1011,
                   ARM_ADDR_INT_STAT    = 4'b1100,
                   ARM_ADDR_INT_CLEAR   = 4'b1101,
                   ARM_ADDR_INT_MASK    = 4'b1110,
                   ARM_ADDR_INT_SET     = 4'b1111;

  localparam [3:0] ARM_ADDR_PIDR4 = 4'b0100,
                   ARM_ADDR_PIDR5 = 4'b0101,
                   ARM_ADDR_PIDR6 = 4'b0110,
                   ARM_ADDR_PIDR7 = 4'b0111,
                   ARM_ADDR_PIDR0 = 4'b1000,
                   ARM_ADDR_PIDR1 = 4'b1001,
                   ARM_ADDR_PIDR2 = 4'b1010,
                   ARM_ADDR_PIDR3 = 4'b1011,
                   ARM_ADDR_CIDR0 = 4'b1100,
                   ARM_ADDR_CIDR1 = 4'b1101,
                   ARM_ADDR_CIDR2 = 4'b1110,
                   ARM_ADDR_CIDR3 = 4'b1111;



  assign sec_acc_err  = ((addr[11:4] == {{6{1'b0}},{2'b00}}) && !nonsec && trans_req) ||
                        ((addr[11:4] == {{6{1'b0}},{2'b01}}) &&  nonsec && trans_req) ||
                        ((addr[11:4] == {{6{1'b0}},{2'b11}}) &&  nonsec && trans_req);

  always @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn) begin
      sec_acc_err_reg <= 1'b0;
    end
    else if (trans_req) begin
      sec_acc_err_reg  <= sec_acc_err;
    end
  end

  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
      int_stat <= 1'b0;
    end
    else if (sec_acc_err && eg_slv_irq_enable) begin
      int_stat <= 1'b1;
    end
    else if (write_en && !sec_acc_err_reg && (addr_reg[11:6] == {6{1'b0}})) begin
      if      ((addr_reg[5:2] == ARM_ADDR_INT_SET)   && byte_strobe[0] && wdata[0]) begin
        int_stat <= 1'b1;
      end
      else if ((addr_reg[5:2] == ARM_ADDR_INT_CLEAR) && byte_strobe[0] && wdata[0]) begin
        int_stat <= 1'b0;
      end
    end
  end

  assign eg_slv_irq = int_stat && !int_mask;

  always @(posedge hclk or negedge hresetn)
    begin
    if (~hresetn)
      begin
        ns_data0    <= {32{1'b0}};
        ns_data1    <= {32{1'b0}};
        ns_data2    <= {32{1'b0}};
        ns_data3    <= {32{1'b0}};
        s_data0     <= {32{1'b0}};
        s_data1     <= {32{1'b0}};
        s_data2     <= {32{1'b0}};
        s_data3     <= {32{1'b0}};
        unchk_data0 <= {32{1'b0}};
        unchk_data1 <= {32{1'b0}};
        unchk_data2 <= {32{1'b0}};
        unchk_data3 <= {32{1'b0}};
        int_mask    <= 1'b0;
      end
    else if (write_en && !sec_acc_err_reg && (addr_reg[11:6] == {6{1'b0}}))
      begin
        case (addr_reg[5:2])
          ARM_ADDR_NS_DATA0 : begin
            if (byte_strobe[0])
              ns_data0[ 7: 0] <= wdata[ 7: 0];
            if (byte_strobe[1])
              ns_data0[15: 8] <= wdata[15: 8];
            if (byte_strobe[2])
              ns_data0[23:16] <= wdata[23:16];
            if (byte_strobe[3])
              ns_data0[31:24] <= wdata[31:24];
          end
          ARM_ADDR_NS_DATA1 : begin
            if (byte_strobe[0])
              ns_data1[ 7: 0] <= wdata[ 7: 0];
            if (byte_strobe[1])
              ns_data1[15: 8] <= wdata[15: 8];
            if (byte_strobe[2])
              ns_data1[23:16] <= wdata[23:16];
            if (byte_strobe[3])
              ns_data1[31:24] <= wdata[31:24];
          end
          ARM_ADDR_NS_DATA2 : begin
            if (byte_strobe[0])
              ns_data2[ 7: 0] <= wdata[ 7: 0];
            if (byte_strobe[1])
              ns_data2[15: 8] <= wdata[15: 8];
            if (byte_strobe[2])
              ns_data2[23:16] <= wdata[23:16];
            if (byte_strobe[3])
              ns_data2[31:24] <= wdata[31:24];
          end
          ARM_ADDR_NS_DATA3 : begin
            if (byte_strobe[0])
              ns_data3[ 7: 0] <= wdata[ 7: 0];
            if (byte_strobe[1])
              ns_data3[15: 8] <= wdata[15: 8];
            if (byte_strobe[2])
              ns_data3[23:16] <= wdata[23:16];
            if (byte_strobe[3])
              ns_data3[31:24] <= wdata[31:24];
          end
          ARM_ADDR_S_DATA0 : begin
            if (byte_strobe[0])
              s_data0[ 7: 0] <= wdata[ 7: 0];
            if (byte_strobe[1])
              s_data0[15: 8] <= wdata[15: 8];
            if (byte_strobe[2])
              s_data0[23:16] <= wdata[23:16];
            if (byte_strobe[3])
              s_data0[31:24] <= wdata[31:24];
          end
          ARM_ADDR_S_DATA1 : begin
            if (byte_strobe[0])
              s_data1[ 7: 0] <= wdata[ 7: 0];
            if (byte_strobe[1])
              s_data1[15: 8] <= wdata[15: 8];
            if (byte_strobe[2])
              s_data1[23:16] <= wdata[23:16];
            if (byte_strobe[3])
              s_data1[31:24] <= wdata[31:24];
          end
          ARM_ADDR_S_DATA2 : begin
            if (byte_strobe[0])
              s_data2[ 7: 0] <= wdata[ 7: 0];
            if (byte_strobe[1])
              s_data2[15: 8] <= wdata[15: 8];
            if (byte_strobe[2])
              s_data2[23:16] <= wdata[23:16];
            if (byte_strobe[3])
              s_data2[31:24] <= wdata[31:24];
          end
          ARM_ADDR_S_DATA3 : begin
            if (byte_strobe[0])
              s_data3[ 7: 0] <= wdata[ 7: 0];
            if (byte_strobe[1])
              s_data3[15: 8] <= wdata[15: 8];
            if (byte_strobe[2])
              s_data3[23:16] <= wdata[23:16];
            if (byte_strobe[3])
              s_data3[31:24] <= wdata[31:24];
          end
          ARM_ADDR_UNCHK_DATA0 : begin
            if (byte_strobe[0])
              unchk_data0[ 7: 0] <= wdata[ 7: 0];
            if (byte_strobe[1])
              unchk_data0[15: 8] <= wdata[15: 8];
            if (byte_strobe[2])
              unchk_data0[23:16] <= wdata[23:16];
            if (byte_strobe[3])
              unchk_data0[31:24] <= wdata[31:24];
          end
          ARM_ADDR_UNCHK_DATA1 : begin
            if (byte_strobe[0])
              unchk_data1[ 7: 0] <= wdata[ 7: 0];
            if (byte_strobe[1])
              unchk_data1[15: 8] <= wdata[15: 8];
            if (byte_strobe[2])
              unchk_data1[23:16] <= wdata[23:16];
            if (byte_strobe[3])
              unchk_data1[31:24] <= wdata[31:24];
          end
          ARM_ADDR_UNCHK_DATA2 : begin
            if (byte_strobe[0])
              unchk_data2[ 7: 0] <= wdata[ 7: 0];
            if (byte_strobe[1])
              unchk_data2[15: 8] <= wdata[15: 8];
            if (byte_strobe[2])
              unchk_data2[23:16] <= wdata[23:16];
            if (byte_strobe[3])
              unchk_data2[31:24] <= wdata[31:24];
          end
          ARM_ADDR_UNCHK_DATA3 : begin
            if (byte_strobe[0])
              unchk_data3[ 7: 0] <= wdata[ 7: 0];
            if (byte_strobe[1])
              unchk_data3[15: 8] <= wdata[15: 8];
            if (byte_strobe[2])
              unchk_data3[23:16] <= wdata[23:16];
            if (byte_strobe[3])
              unchk_data3[31:24] <= wdata[31:24];
          end
          ARM_ADDR_INT_MASK  : begin
            if (byte_strobe[0])
              int_mask <= wdata[0];
          end
        endcase
      end
    end



  localparam STAT_REG_WIDTH = 12;
  wire [STAT_REG_WIDTH-1:0] stat_reg_in;
  wire [STAT_REG_WIDTH-1:0] stat_reg_out;
  assign stat_reg_in = {ARM_VAL_PIDR3, ARM_VAL_PIDR2[7:4]};

  sie200_static_reg #(.WIDTH(STAT_REG_WIDTH)) u_static_reg(.clk(hclk),.reset_n(hresetn),.static_i(stat_reg_in),.static_o(stat_reg_out));

  //----------------------------------------------------------------------------
  // u_static_reg needs to be preserved during implementation to enable ECO
  // changes of PIDR revision and revand values
  //----------------------------------------------------------------------------


  always @ (*)
   begin
     case (read_en)
       1'b1:
       begin
         if ((addr_reg[11:6] == {6{1'b0}}) && !sec_acc_err_reg) begin
           case(addr_reg[5:2])
             ARM_ADDR_NS_DATA0    : rdata = ns_data0;
             ARM_ADDR_NS_DATA1    : rdata = ns_data1;
             ARM_ADDR_NS_DATA2    : rdata = ns_data2;
             ARM_ADDR_NS_DATA3    : rdata = ns_data3;
             ARM_ADDR_S_DATA0     : rdata = s_data0;
             ARM_ADDR_S_DATA1     : rdata = s_data1;
             ARM_ADDR_S_DATA2     : rdata = s_data2;
             ARM_ADDR_S_DATA3     : rdata = s_data3;
             ARM_ADDR_UNCHK_DATA0 : rdata = unchk_data0;
             ARM_ADDR_UNCHK_DATA1 : rdata = unchk_data1;
             ARM_ADDR_UNCHK_DATA2 : rdata = unchk_data2;
             ARM_ADDR_UNCHK_DATA3 : rdata = unchk_data3;
             ARM_ADDR_INT_STAT    : rdata = {ARM_RSVD[31:1],int_stat};
             ARM_ADDR_INT_CLEAR   : rdata = ARM_RSVD[31:0];
             ARM_ADDR_INT_MASK    : rdata = {ARM_RSVD[31:1],int_mask};
             ARM_ADDR_INT_SET     : rdata = ARM_RSVD[31:0];
             default:  rdata = {32{1'bx}};
           endcase
         end
         else if (addr_reg[11:6] == {6{1'b1}}) begin
           case(addr_reg[5:2])
             ARM_ADDR_PIDR4 : rdata = {ARM_RSVD[31:8], ARM_VAL_PIDR4};
             ARM_ADDR_PIDR5 : rdata = {ARM_RSVD[31:8], ARM_VAL_PIDR5};
             ARM_ADDR_PIDR6 : rdata = {ARM_RSVD[31:8], ARM_VAL_PIDR6};
             ARM_ADDR_PIDR7 : rdata = {ARM_RSVD[31:8], ARM_VAL_PIDR7};
             ARM_ADDR_PIDR0 : rdata = {ARM_RSVD[31:8], ARM_VAL_PIDR0};
             ARM_ADDR_PIDR1 : rdata = {ARM_RSVD[31:8], ARM_VAL_PIDR1};
             ARM_ADDR_PIDR2 : rdata = {ARM_RSVD[31:8], stat_reg_out[3:0], ARM_VAL_PIDR2[3:0]};
             ARM_ADDR_PIDR3 : rdata = {ARM_RSVD[31:8], stat_reg_out[11:4]};
             ARM_ADDR_CIDR0 : rdata = {ARM_RSVD[31:8], ARM_VAL_CIDR0};
             ARM_ADDR_CIDR1 : rdata = {ARM_RSVD[31:8], ARM_VAL_CIDR1};
             ARM_ADDR_CIDR2 : rdata = {ARM_RSVD[31:8], ARM_VAL_CIDR2};
             ARM_ADDR_CIDR3 : rdata = {ARM_RSVD[31:8], ARM_VAL_CIDR3};
             4'b0000, 4'b0001,4'b0010,4'b0011: rdata = ARM_RSVD[31:0];
             default: rdata =  {32{1'bx}};
           endcase
         end
         else begin
           rdata = ARM_RSVD[31:0];
         end
       end
     1'b0:
       begin
         rdata = ARM_RSVD[31:0];
       end
     default:
       begin
         rdata =  {32{1'bx}};
       end
     endcase
   end
















endmodule

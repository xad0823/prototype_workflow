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
module sie200_ahb5_eg_slave_interface
 (
  input  wire                  hclk,
  input  wire                  hresetn,

  input wire                   cfg_sec_resp,

  input  wire         hsel,
  input  wire         hnonsec,
  input  wire [11:0]  haddr,
  input  wire [1:0]   htrans,
  input  wire [2:0]   hsize,
  input  wire         hwrite,
  input  wire         hready,
  input  wire [31:0]  hwdata,

  output wire         hreadyout,
  output wire         hresp,
  output wire [31:0]  hrdata,

  output wire [11:0]  addr,
  output wire         nonsec,
  output wire         trans_req,

  output wire [11:0]  addr_reg,
  output wire         read_en,
  output wire         write_en,
  output wire [3:0]   byte_strobe,
  output wire [31:0]  wdata,
  input  wire [31:0]  rdata,
  input  wire         sec_acc_err
  );


  wire         ahb5_read_req ;
  wire         ahb5_write_req;

  reg  [11:2]  haddr_reg;
  reg          read_en_reg;
  reg          write_en_reg;
  reg  [1:0]   err_state;

  reg  [3:0]   byte_strobe_reg;
  reg  [3:0]   byte_strobe_nxt;

  wire unused = htrans[0];


  assign  trans_req      = hready && hsel && htrans[1];
  assign  ahb5_read_req  = trans_req && (~hwrite);
  assign  ahb5_write_req = trans_req &&   hwrite;

  always @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn)
      haddr_reg <= {10{1'b0}};
    else if (trans_req)
      haddr_reg <= haddr[11:2];
  end

  always @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn)
      begin
        read_en_reg <= 1'b0;
      end
    else if (hready)
      begin
        read_en_reg  <= ahb5_read_req;
      end
  end

  always @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn)
      begin
        write_en_reg <= 1'b0;
      end
    else if (hready)
      begin
        write_en_reg  <= ahb5_write_req;
      end
  end

   always @(*)
  begin
    if (hsize == 3'b000)
      begin
        case(haddr[1:0])
          2'b00: byte_strobe_nxt = 4'b0001;
          2'b01: byte_strobe_nxt = 4'b0010;
          2'b10: byte_strobe_nxt = 4'b0100;
          2'b11: byte_strobe_nxt = 4'b1000;
          default: byte_strobe_nxt = 4'bxxxx;
        endcase
      end
    else if (hsize == 3'b001)
      begin
        if(haddr[1]==1'b1)
          byte_strobe_nxt = 4'b1100;
        else
          byte_strobe_nxt = 4'b0011;
      end
    else
      begin
          byte_strobe_nxt = 4'b1111;
      end
  end

  always @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn)
      byte_strobe_reg <= {4{1'b0}};
    else if (hready)
      byte_strobe_reg  <= byte_strobe_nxt;
  end

  always @(posedge hclk or negedge hresetn)
  begin
    if (!hresetn) begin
      err_state <= 2'b00;
    end
    else if (sec_acc_err && cfg_sec_resp) begin
      err_state <= 2'b01;
    end
    else begin
      err_state <= {err_state[0], 1'b0};
    end
  end


  assign addr_reg      = {haddr_reg[11:2], 2'b00};
  assign read_en       = read_en_reg;
  assign write_en      = write_en_reg;
  assign byte_strobe   = byte_strobe_reg;

  assign addr          = {haddr[11:2], 2'b00};
  assign nonsec        = hnonsec;
  assign wdata         = hwdata;

  assign hresp         = err_state != 2'h0;
  assign hreadyout     = (err_state != 2'b0) ? err_state[1] : 1'b1;
  assign hrdata        = rdata;















endmodule


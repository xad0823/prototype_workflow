//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//          (C) COPYRIGHT 2001-2013,2015-2016 ARM Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Wed Oct 12 10:54:01 2016 +0100
//
//      Revision            : 8d376ca
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------
<<template_begin>>
<<copyright_header>>
<<version_control_header>>
<<timescale_directive>>
module <<default_slave_name>> (


    input  wire       hclk,
    input  wire       hresetn,

    input  wire       hsel,
    input  wire[1:0]  htrans,
    input  wire       hready,

    output wire       hreadyout,
    output wire       hresp,
    output wire       hexokay

    );



localparam RSP_OKAY  =  1'b0;
localparam RSP_ERR   =  1'b1;


  wire          unused = htrans[0];


  wire          invalid;
  wire          hready_next;
  reg           i_hreadyout;
  wire          hresp_next;
  reg           i_hresp;



  assign invalid     = ( hready & hsel & htrans[1] );
  assign hready_next = i_hreadyout ?  ~invalid : 1'b1 ;
  assign hresp_next  = invalid ? RSP_ERR   : RSP_OKAY;

  always @(negedge hresetn or posedge hclk)
    begin : p_resp_seq
      if (~hresetn)
        begin
          i_hreadyout <= 1'b1;
          i_hresp     <= RSP_OKAY;
        end
      else
        begin
          i_hreadyout <= hready_next;

          if (i_hreadyout)
            i_hresp <= hresp_next;
        end
    end

  assign hreadyout = i_hreadyout;
  assign hresp     = i_hresp;

  assign hexokay   = 1'b0;

endmodule


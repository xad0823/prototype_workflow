// *********************************************************************
//  The confidential and proprietary information contained in this file may
//  only be used by a person authorised under and to the extent permitted
//  by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//             (C) COPYRIGHT 2012-2016 ARM Limited or its affiliates.
//                 ALL RIGHTS RESERVED
//
//  This entire notice must be reproduced on all copies of this file
//  and copies of this file may only be made by a person if such person is
//  permitted to do so under the terms of a subsisting license agreement
//  from ARM Limited or its affiliates.
//
//   File Revision       :$Revision: $
//   File Date           :$Date: $
//
//   Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
// *********************************************************************

`ifndef VIP_AHB5_INTERFACE_SVH
`define VIP_AHB5_INTERFACE_SVH


interface vip_ahb5_interface
     #(parameter int DATA_BITS = 32,
       parameter int HSEL_WIDTH = 1,
       parameter int HMASTER_WIDTH = 1,
       parameter int HAUSER_WIDTH = 1,
       parameter int HRUSER_WIDTH = 1,
       parameter int HWUSER_WIDTH = 1)
     (input HCLK, input HRESET_N );

     logic [63:0] HADDR;

     logic [2:0] HBURST;

     logic  HMASTLOCK;

     logic [6:0] HPROT;

     logic [2:0] HSIZE;

     logic [1:0] HTRANS;

     logic [DATA_BITS-1:0] HWDATA;

     logic HWRITE;

     logic [DATA_BITS-1:0] HRDATA;

     logic HRESP;

     logic [HSEL_WIDTH-1:0] HSELX;

     logic HSEL;

     logic HREADY;

     logic HREADYOUT;

     logic HEXCL;

     logic [HMASTER_WIDTH-1:0]HMASTER;


     logic HEXOKAY;

     logic HNONSEC;
     logic [HAUSER_WIDTH-1:0]HAUSER;

     logic [HRUSER_WIDTH-1:0]HRUSER;

     logic [HWUSER_WIDTH-1:0]HWUSER;


     assign HSEL = |(HSELX);

     clocking cb @(posedge HCLK);
         default input #1step output #0;

         input HADDR;
         input HBURST;
         input HMASTLOCK;
         input HPROT;
         input HSIZE;
         input HTRANS;
         input HWDATA;
         input HWRITE;
         input HRDATA;
         input HRESP;
         input HSELX;
         input HSEL;
         input HREADY;
         input HREADYOUT;
         input HEXCL;
         input HMASTER;
         input HEXOKAY;
         input HNONSEC;
         input HAUSER;
         input HRUSER;
         input HWUSER;
     endclocking :cb

    function unsigned get_thread_id_bits();
        return HMASTER_WIDTH;
    endfunction :  get_thread_id_bits

    function unsigned get_num_hauser_width();
        return HAUSER_WIDTH;
    endfunction : get_num_hauser_width


    function unsigned get_num_hruser_width();
        return HRUSER_WIDTH;
    endfunction : get_num_hruser_width

    function unsigned get_num_hwuser_width();
        return HWUSER_WIDTH;
    endfunction : get_num_hwuser_width

    function automatic int unsigned get_data_byte_width();
        int unsigned num_bytes;
        num_bytes = DATA_BITS/8;
        return num_bytes;
    endfunction : get_data_byte_width

    function automatic int unsigned get_number_of_slaves();
        return HSEL_WIDTH;
    endfunction : get_number_of_slaves

    function void bitstream_to_byte_array(bit [DATA_BITS-1:0] bit_stream,
                                          output bit [7:0] data[]
                                         );
        int unsigned byte_width;

        byte_width = get_data_byte_width();

        data = new[byte_width];
        for(int i = 0; i< byte_width;++i)
        begin
            data[i] = bit_stream[7:0];
            bit_stream >>= 8;
        end

    endfunction: bitstream_to_byte_array

    function bit [DATA_BITS-1:0] byte_array_to_bit_stream(bit [7:0] data[]);

        bit [DATA_BITS-1:0] bit_stream;
        int unsigned byte_width;

        byte_width = get_data_byte_width();

        for(int i = (byte_width-1); i>0;--i)
        begin
            bit_stream[7:0] = data[i];
            bit_stream <<= 8;
        end
        bit_stream[7:0] = data[0];

        return bit_stream;
    endfunction: byte_array_to_bit_stream


endinterface : vip_ahb5_interface

`endif

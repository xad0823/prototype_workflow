//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//          (C) COPYRIGHT 2015-2016 ARM Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Mon Nov 21 14:40:10 2016 +0000
//
//      Revision            : 853d071
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_ex_mon #(

    parameter ADDR_WIDTH                              = 32,
    parameter DATA_WIDTH                              = 32,
    parameter MASTER_WIDTH                            = 4,
    parameter USER_WIDTH                              = 1,
    parameter [(1<<MASTER_WIDTH)-1:0] ID_PRESENT      = {(1<<MASTER_WIDTH){1'b1}},
    parameter TAG_MSB                                 = ADDR_WIDTH-1,
    parameter BUFFER_ENABLE                           = 0
)
(

  input  wire hclk      ,
  input  wire hresetn   ,

  input  wire                    hsel_s      ,
  input  wire                    hnonsec_s   ,
  input  wire [ADDR_WIDTH-1:0]   haddr_s     ,
  input  wire [1:0]              htrans_s    ,
  input  wire [2:0]              hsize_s     ,
  input  wire                    hwrite_s    ,
  input  wire                    hready_s    ,
  input  wire [6:0]              hprot_s     ,
  input  wire [2:0]              hburst_s    ,
  input  wire                    hmastlock_s ,
  input  wire [DATA_WIDTH-1:0]   hwdata_s    ,
  input  wire                    hexcl_s     ,
  input  wire [MASTER_WIDTH-1:0] hmaster_s   ,
  output wire [DATA_WIDTH-1:0]   hrdata_s    ,
  output wire                    hreadyout_s ,
  output wire                    hresp_s     ,
  output wire                    hexokay_s   ,
  input  wire [USER_WIDTH-1:0]   hauser_s    ,
  input  wire [USER_WIDTH-1:0]   hwuser_s    ,
  output wire [USER_WIDTH-1:0]   hruser_s    ,



  output wire                    hsel_m      ,
  output wire                    hnonsec_m   ,
  output wire [ADDR_WIDTH-1:0]   haddr_m     ,
  output wire [1:0]              htrans_m    ,
  output wire [2:0]              hsize_m     ,
  output wire                    hwrite_m    ,
  output wire                    hready_m    ,
  output wire [6:0]              hprot_m     ,
  output wire [2:0]              hburst_m    ,
  output wire                    hmastlock_m ,
  output wire [DATA_WIDTH-1:0]   hwdata_m    ,
  output wire                    hexcl_m     ,
  output wire [MASTER_WIDTH-1:0] hmaster_m   ,
  input  wire                    hreadyout_m ,
  input  wire                    hresp_m     ,
  input  wire [DATA_WIDTH-1:0]   hrdata_m    ,
  input  wire                    hexokay_m   ,
  output wire [USER_WIDTH-1:0]   hauser_m    ,
  output wire [USER_WIDTH-1:0]   hwuser_m    ,
  input  wire [USER_WIDTH-1:0]   hruser_m
);


function [7:0] log2;
  input [31:0] a;
  begin
    log2 = (a<=     2) ?  8'd1 :
           (a<=     4) ?  8'd2 :
           (a<=     8) ?  8'd3 :
           (a<=    16) ?  8'd4 :
           (a<=    32) ?  8'd5 :
           (a<=    64) ?  8'd6 :
           (a<=   128) ?  8'd7 :
           (a<=   256) ?  8'd8 :
           (a<=   512) ?  8'd9 :
           (a<=  1024) ? 8'd10 :
           (a<=  2048) ? 8'd11 :
           (a<=  4096) ? 8'd12 :
           (a<=  8192) ? 8'd13 :
           (a<= 16384) ? 8'd14 :
           (a<= 32768) ? 8'd15 :
           (a<= 65536) ? 8'd16 :
           (a<=131072) ? 8'd17 :
                         8'd0 ;
  end
endfunction

function [7:0] address_mask;
  input [2:0] hsize;
  begin
    address_mask = (DATA_WIDTH >=   8 && hsize==0) ? 8'b1111_1111 :
                   (DATA_WIDTH >=  16 && hsize==1) ? 8'b1111_1110 :
                   (DATA_WIDTH >=  32 && hsize==2) ? 8'b1111_1100 :
                   (DATA_WIDTH >=  64 && hsize==3) ? 8'b1111_1000 :
                   (DATA_WIDTH >= 128 && hsize==4) ? 8'b1111_0000 :
                   (DATA_WIDTH >= 256 && hsize==5) ? 8'b1110_0000 :
                   (DATA_WIDTH >= 512 && hsize==6) ? 8'b1100_0000 :
                   (DATA_WIDTH >=1024 && hsize==7) ? 8'b1000_0000 :
                                                     8'b0000_0000 ;
  end
endfunction

localparam   TAG_LSB           = log2(DATA_WIDTH)-3;

localparam   EXCL_RESP_OKAY    = 2'b01;
localparam   EXCL_RESP_FAIL    = 2'b10;
localparam   EXCL_RESP_TRANS   = 2'b11;

reg     [(1<<MASTER_WIDTH)-1 :0] excl_state;
reg        [1+TAG_MSB-TAG_LSB:0] excl_tag     [(1<<MASTER_WIDTH)-1 :0];
reg             [TAG_LSB+13-1:0] excl_tag_ext [(1<<MASTER_WIDTH)-1 :0];
wire                             block_transfer;
wire                             matching_sequence;
reg                        [1:0] response_state;
reg                        [1:0] response_state_r;
wire                             transfer;

reg           [MASTER_WIDTH-1:0] hmaster_shadow;
reg                              hexcl_shadow;

wire    [(1<<MASTER_WIDTH)-1 :0] w_excl_state;
wire       [1+TAG_MSB-TAG_LSB:0] w_excl_tag     [(1<<MASTER_WIDTH)-1 :0];
wire            [TAG_LSB+13-1:0] w_excl_tag_ext [(1<<MASTER_WIDTH)-1 :0];

wire                             hsel_i;
wire            [ADDR_WIDTH-1:0] haddr_i;
wire                       [1:0] htrans_i;
wire                       [2:0] hsize_i;
wire                             hwrite_i;
wire                       [6:0] hprot_i;
wire                       [2:0] hburst_i;
wire                             hmastlock_i;
wire          [MASTER_WIDTH-1:0] hmaster_i;
wire                             hexcl_i;
wire                             hnonsec_i;
wire            [USER_WIDTH-1:0] hauser_i;

wire                             hready_i;
wire                             hresp_i;

wire                             transfer_i;



assign transfer = (hsel_s & htrans_s[1] & hready_s);


always @(posedge hclk or negedge hresetn)
begin
  if (~hresetn)
  begin
     hmaster_shadow <= {MASTER_WIDTH{1'b0}};
     hexcl_shadow   <= 1'b0;
  end

  else
     if (hready_i)
     begin
       hmaster_shadow <= hmaster_i;
       hexcl_shadow   <= hexcl_i & transfer_i;
     end
end

genvar i;
generate

  for ( i=0 ; i < (1 << MASTER_WIDTH) ; i = i +1 ) begin: master

    if (ID_PRESENT[i])
    begin : tag

      wire                    [2:0] tagged_hsize;
      wire            [TAG_LSB-1:0] tagged_haddr_low;
      wire                    [7:0] tag_mask;
      wire                    [7:0] cur_mask;
      wire                          byte_overlap;
      wire                          access_overlap;

      assign tagged_hsize     = excl_tag_ext[i][12:10];
      assign tagged_haddr_low = excl_tag_ext[i][13+TAG_LSB-1:13];

      assign tag_mask         = address_mask(tagged_hsize);
      assign cur_mask         = address_mask(hsize_i);

      assign byte_overlap     = ~ ( | ( (tagged_haddr_low      ^
                                         haddr_i[TAG_LSB-1:0]) &
                                         tag_mask[TAG_LSB-1:0] &
                                         cur_mask[TAG_LSB-1:0]   ) );

      assign access_overlap   = excl_tag[i] == {hnonsec_i,haddr_i[TAG_MSB:TAG_LSB]} && byte_overlap;

      always @(posedge hclk or negedge hresetn)
      begin
        if (~hresetn)
        begin
           excl_state[i]   <= 1'b0;
           excl_tag[i]     <= {(1+TAG_MSB-TAG_LSB+1){1'b0}};
           excl_tag_ext[i] <= {TAG_LSB+13{1'b0}};
        end
        else
        begin

          if ( (~hready_i & hresp_i) &&

               (hmaster_shadow == i) && hexcl_shadow )
            excl_state[i] <= 1'b0;

          else if (transfer_i)
          begin

            if (~hwrite_i && hexcl_i && hmaster_i==i)
            begin
              excl_state[i]   <= 1'b1;
              excl_tag[i]     <= {hnonsec_i,haddr_i[TAG_MSB:TAG_LSB]};
              excl_tag_ext[i] <= {haddr_i[TAG_LSB-1:0],hsize_i,hprot_i,hburst_i};
            end

            else if (excl_state[i] == 1)

              if (hwrite_i && ( (hexcl_i && hmaster_i==i && matching_sequence) ||
                               ( access_overlap && !block_transfer ) ) )
                excl_state[i] <= 1'b0;

          end

        end

      end

      assign w_excl_state[i]   = excl_state[i];
      assign w_excl_tag[i]     = excl_tag[i];
      assign w_excl_tag_ext[i] = excl_tag_ext[i];


    end

    else
    begin : not_implemented
      assign w_excl_state[i]   = 1'b0;
      assign w_excl_tag[i]     = {(1+TAG_MSB-TAG_LSB+1){1'b1}};
      assign w_excl_tag_ext[i] = {TAG_LSB+13{1'b1}};
    end

  end

endgenerate

assign matching_sequence = w_excl_state[hmaster_i] &&
                           w_excl_tag[hmaster_i]     == {hnonsec_i,haddr_i[TAG_MSB:TAG_LSB]} &&
                           w_excl_tag_ext[hmaster_i] == {haddr_i[TAG_LSB-1:0],hsize_i,hprot_i,hburst_i};

always @(*)
begin
   response_state = EXCL_RESP_TRANS;

   if (hsel_i && htrans_i[1] && ID_PRESENT[hmaster_i] && hexcl_i)
   begin

     if (~hwrite_i)
       response_state = EXCL_RESP_OKAY;

     else if (matching_sequence)
       response_state = EXCL_RESP_OKAY;

     else
       response_state = EXCL_RESP_FAIL;

   end
end

assign block_transfer = response_state == EXCL_RESP_FAIL;

generate
  if (BUFFER_ENABLE == 0)
  begin : direct_input

    assign hsel_i         = hsel_s;
    assign haddr_i        = haddr_s;
    assign htrans_i       = htrans_s;
    assign hsize_i        = hsize_s;
    assign hwrite_i       = hwrite_s;
    assign hprot_i        = hprot_s;
    assign hburst_i       = hburst_s;
    assign hmastlock_i    = hmastlock_s;
    assign hmaster_i      = hmaster_s;
    assign hnonsec_i      = hnonsec_s;
    assign hauser_i       = hauser_s;
    assign hexcl_i        = hexcl_s;

    assign hready_i       = hready_s;
    assign hresp_i        = hresp_s;

    assign transfer_i     = transfer;

    always @(posedge hclk or negedge hresetn)
    begin
      if (~hresetn)
        response_state_r <= EXCL_RESP_TRANS;

      else
        if (hready_s)
          response_state_r <= response_state;
    end

    if (TAG_MSB == ADDR_WIDTH-1)
    begin : unused_signals
      wire [1+1+USER_WIDTH-1:0] unused = {htrans_i[0],hmastlock_i,hauser_i};
    end
    else
    begin : unused_signals_with_tag_msb
      wire [1+1+USER_WIDTH+(ADDR_WIDTH-TAG_MSB-1)-1:0] unused = {htrans_i[0],hmastlock_i,hauser_i,haddr_i[ADDR_WIDTH-1:TAG_MSB+1]};
    end


    assign hsel_m      = hsel_s;
    assign haddr_m     = haddr_s;
    assign htrans_m    = htrans_s   & {2{~block_transfer}};
    assign hsize_m     = hsize_s;
    assign hwrite_m    = hwrite_s;
    assign hready_m    = hready_s;
    assign hprot_m     = hprot_s;
    assign hburst_m    = hburst_s;
    assign hmastlock_m = hmastlock_s;
    assign hwdata_m    = hwdata_s;
    assign hexcl_m     = hexcl_s;
    assign hmaster_m   = hmaster_s;
    assign hnonsec_m   = hnonsec_s;
    assign hauser_m    = hauser_s;
    assign hwuser_m    = hwuser_s;

    assign hexokay_s   = response_state_r == EXCL_RESP_TRANS ? hexokay_m :
                         response_state_r == EXCL_RESP_FAIL  ? 1'b0 :
                         response_state_r == EXCL_RESP_OKAY  ? 1'b1 & hready_s & ~hresp_m :
                                                               1'b0;
    assign hreadyout_s = hreadyout_m;
    assign hresp_s     = hresp_m;
    assign hrdata_s    = hrdata_m;
    assign hruser_s    = hruser_m;

  end else
  begin : registered_input

    reg                     hsel_reg;
    reg    [ADDR_WIDTH-1:0] haddr_reg;
    reg               [1:0] htrans_reg;
    reg               [2:0] hsize_reg;
    reg                     hwrite_reg;
    reg               [6:0] hprot_reg;
    reg               [2:0] hburst_reg;
    reg                     hmastlock_reg;
    reg  [MASTER_WIDTH-1:0] hmaster_reg;
    reg                     hexcl_reg;
    reg                     hnonsec_reg;
    reg    [USER_WIDTH-1:0] hauser_reg;

    reg                     allow_trans;

    reg                     hready_reg;
    reg                     hresp_reg;

    reg                     excl_buffered, excl_buffered_d;
    reg                     transparent;

    wire                    excl_wr;


    assign excl_wr  = hsel_s && htrans_s[1] && hexcl_s && hwrite_s;

    always @(posedge hclk or negedge hresetn)
    begin
      if (~hresetn)
      begin
        hsel_reg       <= 1'b0;
        haddr_reg      <= {ADDR_WIDTH{1'b0}};
        htrans_reg     <= 2'b00;
        hsize_reg      <= 3'b000;
        hwrite_reg     <= 1'b0;
        hprot_reg      <= 7'b0000000;
        hburst_reg     <= 3'b000;
        hmastlock_reg  <= 1'b0;
        hmaster_reg    <= {MASTER_WIDTH{1'b0}};
        hexcl_reg      <= 1'b0;
        hnonsec_reg    <= 1'b0;
        hauser_reg     <= {USER_WIDTH{1'b0}};

        excl_buffered  <= 1'b0;
        excl_buffered_d <= 1'b0;

        transparent    <= 1'b1;

        allow_trans    <= 1'b0;
      end
      else
      begin

        if (transfer)
        begin

          excl_buffered  <= hexcl_s & hwrite_s;
          excl_buffered_d<= hexcl_s & hwrite_s & ~ID_PRESENT[hmaster_s];

          hsel_reg       <= hsel_s;
          haddr_reg      <= haddr_s;
          htrans_reg     <= htrans_s;
          hsize_reg      <= hsize_s;
          hwrite_reg     <= hwrite_s;
          hprot_reg      <= hprot_s;
          hburst_reg     <= hburst_s;
          hmastlock_reg  <= hmastlock_s;
          hexcl_reg      <= hexcl_s;
          hmaster_reg    <= hmaster_s;
          hnonsec_reg    <= hnonsec_s;
          hauser_reg     <= hauser_s;

          transparent    <= ~hexcl_s | ~ID_PRESENT[hmaster_s];

          allow_trans    <= ~excl_wr | ~ID_PRESENT[hmaster_s];

        end else if (excl_buffered & ~excl_buffered_d)
        begin
          excl_buffered_d <= 1'b1;

          allow_trans    <= ~block_transfer;

        end else
        begin

          hsel_reg       <= 1'b0;
          haddr_reg      <= {ADDR_WIDTH{1'b0}};
          htrans_reg     <= 2'b00;
          hsize_reg      <= 3'b000;
          hwrite_reg     <= 1'b0;
          hprot_reg      <= 7'b0000000;
          hburst_reg     <= 3'b000;
          hmastlock_reg  <= 1'b0;
          hmaster_reg    <= {MASTER_WIDTH{1'b0}};
          hexcl_reg      <= 1'b0;
          hnonsec_reg    <= 1'b0;
          hauser_reg     <= {USER_WIDTH{1'b0}};

          excl_buffered  <= 1'b0;
          excl_buffered_d <= 1'b0;

          if (hready_s)
             allow_trans    <= 1'b0;

        end

      end

    end

    assign hsel_i         = hsel_reg;
    assign haddr_i        = haddr_reg;
    assign htrans_i       = htrans_reg;
    assign hsize_i        = hsize_reg;
    assign hwrite_i       = hwrite_reg;
    assign hprot_i        = hprot_reg;
    assign hburst_i       = hburst_reg;
    assign hmastlock_i    = hmastlock_reg;
    assign hmaster_i      = hmaster_reg;
    assign hnonsec_i      = hnonsec_reg;
    assign hauser_i       = hauser_reg;
    assign hexcl_i        = hexcl_reg;

    always @(posedge hclk or negedge hresetn)
    begin
      if (~hresetn)
      begin
        hready_reg     <= 1'b1;
        hresp_reg      <= 1'b0;
      end
      else
      begin
        hready_reg       <= hready_s;
        hresp_reg        <= hresp_s;
      end
    end

    assign hready_i       = hready_reg;
    assign hresp_i        = hresp_reg;

    assign transfer_i     = hsel_i & htrans_i[1] & hready_i;


    assign htrans_m    = excl_buffered_d ? allow_trans ? htrans_i
                                                       : {1'b0,htrans_i[0]}
                                         : excl_buffered ? {1'b0,htrans_i[0]}
                                                         : excl_wr ? {1'b0,htrans_s[0]}
                                                                   : htrans_s;

    assign hsel_m      = excl_buffered ?         1'b1 : hsel_s;
    assign haddr_m     = excl_buffered ?      haddr_i : haddr_s;
    assign hsize_m     = excl_buffered ?      hsize_i : hsize_s;
    assign hwrite_m    = excl_buffered ?     hwrite_i : hwrite_s;
    assign hprot_m     = excl_buffered ?      hprot_i : hprot_s;
    assign hburst_m    = excl_buffered ?     hburst_i : hburst_s;
    assign hmastlock_m = excl_buffered ?  hmastlock_i : hmastlock_s;
    assign hexcl_m     = excl_buffered ?         1'b1 : hexcl_s;
    assign hmaster_m   = excl_buffered ?    hmaster_i : hmaster_s;
    assign hnonsec_m   = excl_buffered ?    hnonsec_i : hnonsec_s;
    assign hauser_m    = excl_buffered ?     hauser_i : hauser_s;

    assign hready_m    = excl_buffered ?         1'b1 : hready_s;

    assign hwdata_m    = hwdata_s;
    assign hwuser_m    = hwuser_s;

    assign hexokay_s   = transparent   ?        hexokay_m : allow_trans & hready_s & ~hresp_m;
    assign hreadyout_s = excl_buffered ?             1'b0 : hreadyout_m;
    assign hresp_s     =                                    hresp_m;
    assign hrdata_s    =                                    hrdata_m;
    assign hruser_s    =                                    hruser_m;





  end
endgenerate




`ifdef ARM_ASSERT_ON


    if ( ADDR_WIDTH > 32 )
      assert_sie200_ex_mon_addr_width_check : assert property ( @(posedge hclk) !$rose(hresetn)  ) else $warning("HADDR is only supported up to 32 bits!");

    if ( ~(DATA_WIDTH == 8 || DATA_WIDTH == 16 || DATA_WIDTH == 32 || DATA_WIDTH == 64 || DATA_WIDTH == 128 || DATA_WIDTH == 256 || DATA_WIDTH == 512 || DATA_WIDTH == 1024) )
      assert_sie200_ex_mon_data_width_check : assert property ( @(posedge hclk) 0 ) else $error("Only 8, 16, 32, 64, 128, 256, 512, 1024 bits wide data bus is allowed!");

    if ( ID_PRESENT == 0 )
      assert_sie200_ex_mon_id_present_nonzero_check : assert property ( @(posedge hclk) 0 ) else $error("ID_PRESENT needs to be non-zero otherwise the Exclusive Access Monitor has no function");

    if ( TAG_MSB >= ADDR_WIDTH )
      assert_sie200_ex_mon_tag_msb_valid_check : assert property ( @(posedge hclk) 0 ) else $error("TAG_MSB parameter must be smaller than ADDR_WIDTH!");








`endif

endmodule



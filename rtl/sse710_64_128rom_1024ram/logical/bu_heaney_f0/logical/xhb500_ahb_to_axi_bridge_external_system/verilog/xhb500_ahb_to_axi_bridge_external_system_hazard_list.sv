//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2025 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//-----------------------------------------------------------------------------
//
//      Version Information
//
//      Checked In          : Fri Mar 29 11:15:40 2019 +0000
//
//      Revision            : 08e988e
//
//      Release Information : CoreLink XHB-500 Generic Global Bundle r0p0-00rel0
//

module xhb500_ahb_to_axi_bridge_external_system_hazard_list (

  input  wire logic                              clk,
  input  wire logic                              resetn,

  input  wire logic                              add,
  input  wire logic [32-1:0]                     add_addr,
  input  wire logic [1-1:0]                      add_id,

  input  wire logic [1-1:0]                      bid,
  input  wire logic                              b_done,
  output      logic                              b_ewr,

  output      logic                              empty,
  output      logic                              full,

  input  wire logic [32-1:0]                     chk_addr,
  output      logic                              hazard


  );

  localparam HAZARD_LIST_SIZE = 4;

  logic [32-1:12]                     hazard_list_addr [HAZARD_LIST_SIZE-1:0];
  logic [1-1:0]                       hazard_list_id   [HAZARD_LIST_SIZE-1:0];

  logic  [2:0]                        list_pointer;

  logic [HAZARD_LIST_SIZE-1:0]        match_addr_i;
  logic [HAZARD_LIST_SIZE-1:0]        match_bid_i;

  logic [HAZARD_LIST_SIZE-1:0]        match_before_i;

  logic                               remove;

  wire logic [12+12-1:0] unused = { add_addr[12-1:0], chk_addr[12-1:0] };

  assign remove = b_done & b_ewr;

  always_ff @ (posedge clk or negedge resetn)
  begin : list_pointer_reg
    if (~resetn)
    begin
      list_pointer <= 3'd0;
    end
    else
    begin
      if (add && ~remove)
        list_pointer <= list_pointer + 3'd1;
      else if (remove && ~add)
        list_pointer <= list_pointer - 3'd1;
    end
  end

  genvar i;
  generate

    for ( i=0 ; i < HAZARD_LIST_SIZE ; i = i +1 ) begin: hazard_list

      assign match_addr_i[i]   = (list_pointer > 3'(i)) & (hazard_list_addr[i] == chk_addr[32-1:12]);

      assign match_bid_i[i]    = (list_pointer > 3'(i)) & (hazard_list_id[i]   == bid);

      assign match_before_i[i] = |match_bid_i[i:0];

      always_ff @ (posedge clk or negedge resetn)
      begin : hazard_list_reg
        if (~resetn)
        begin
          hazard_list_addr[i] <= {32-12 { 1'b0 }};
          hazard_list_id[i]   <= {1 { 1'b0 }};
        end
        else
        begin


          if ( 3'(i+1)<list_pointer & match_before_i[i] )
          begin
            if ( (i+1)<HAZARD_LIST_SIZE )
              if ( remove )
                begin
                  hazard_list_addr[i] <= hazard_list_addr[i+1];
                  hazard_list_id[i]   <= hazard_list_id[i+1];
                end
          end

          else if ( 3'(i+1)==list_pointer )
          begin
            if ( add & remove )
            begin
              hazard_list_addr[i] <= add_addr[32-1:12];
              hazard_list_id[i]   <= add_id;
            end
          end

          else if ( 3'(i)==list_pointer )
          begin
            if ( add & ~remove )
            begin
              hazard_list_addr[i] <= add_addr[32-1:12];
              hazard_list_id[i]   <= add_id;
            end
          end

        end
      end
    end

  endgenerate

  assign empty  = list_pointer == 3'd0 ? 1'b1              : 1'b0;
  assign full   = list_pointer >= 3'd4 ? ~remove : 1'b0;

  assign b_ewr  = |match_bid_i;
  assign hazard = |match_addr_i;





endmodule

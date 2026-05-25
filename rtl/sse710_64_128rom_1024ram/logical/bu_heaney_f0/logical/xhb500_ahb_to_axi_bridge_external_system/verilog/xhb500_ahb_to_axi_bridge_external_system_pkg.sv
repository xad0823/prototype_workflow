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

package xhb500_ahb_to_axi_bridge_external_system_pkg;


  typedef enum logic [1:0]  {TR_IDLE    = 2'b00,
                             TR_BUSY    = 2'b01,
                             TR_NONSEQ  = 2'b10,
                             TR_SEQ     = 2'b11} transfer_type;

  typedef enum logic [2:0]  {BUR_SINGLE = 3'b000,
                             BUR_INCR   = 3'b001,
                             BUR_WRAP4  = 3'b010,
                             BUR_INCR4  = 3'b011,
                             BUR_WRAP8  = 3'b100,
                             BUR_INCR8  = 3'b101,
                             BUR_WRAP16 = 3'b110,
                             BUR_INCR16 = 3'b111} ahb_burst_type;


  typedef enum logic [1:0]  {XBUR_FIXED    = 2'b00,
                             XBUR_INCR     = 2'b01,
                             XBUR_WRAP     = 2'b10,
                             XBUR_RESERVED = 2'b11, XBUR_undef = 2'bxx } axburst_type;


  typedef enum logic        {RSP_OKAY   = 1'b0,
                             RSP_ERR    = 1'b1} resp_type ;


  function automatic [7:0] address_mask;
    input [1:0] hsize;
    begin
      case (hsize)
        2'd0   : address_mask = 8'b0000_0000;
        2'd1   : address_mask = 8'b0000_0001;
        2'd2   : address_mask = 8'b0000_0011;
        default: address_mask = 8'b0000_0000;
      endcase
    end
  endfunction

  function automatic [3:0] calculate_burst_length;
    input                             modifiable;
    input                             exclusive;
    input ahb_burst_type              burst_type;
    input [1:0]                       size;
    input [32-1:0]                    address;
    begin
      if (modifiable & !exclusive)
        case (burst_type)
          BUR_SINGLE : calculate_burst_length = 4'd0;
          BUR_INCR  :  calculate_burst_length = 4'd0;
          BUR_WRAP4,
          BUR_INCR4 :  calculate_burst_length = 4'd3;
          BUR_WRAP8,
          BUR_INCR8 :  calculate_burst_length = 4'd7;
          BUR_WRAP16,
          BUR_INCR16 : calculate_burst_length = 4'd15;
          default : calculate_burst_length = {4{1'bx}};
        endcase
      else
        calculate_burst_length = 4'd0;
    end
  endfunction


endpackage

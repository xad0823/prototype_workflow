//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2017 Arm Limited or its affiliates.
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
//   Functions for css600_ntsasyncbridge
//
//----------------------------------------------------------------------------


    function automatic [3:0] gray_to_bin_6;
    input [3:0] gray;

    begin
    case (gray)
        4'd0  : gray_to_bin_6 = 4'd0;
        4'd1  : gray_to_bin_6 = 4'd1;

        4'd3  : gray_to_bin_6 = 4'd2;
        4'd7  : gray_to_bin_6 = 4'd3;
        4'd6  : gray_to_bin_6 = 4'd4;
        4'd4  : gray_to_bin_6 = 4'd5;
        4'd12 : gray_to_bin_6 = 4'd0;
        4'd14 : gray_to_bin_6 = 4'd1;
        4'd15 : gray_to_bin_6 = 4'd2;
        4'd11 : gray_to_bin_6 = 4'd3;
        4'd9  : gray_to_bin_6 = 4'd4;
        4'd8  : gray_to_bin_6 = 4'd5;

        4'd2,
        4'd5,
        4'd10,
        4'd13 : gray_to_bin_6 = {4{1'b0}};

        default : gray_to_bin_6 = {4{1'bx}};
      endcase
    end
  endfunction


  function automatic [3:0] gray_to_bin_8;
    input [3:0] gray;

    begin
    case (gray)
        4'd0  : gray_to_bin_8 = 4'd0;
        4'd1  : gray_to_bin_8 = 4'd1;
        4'd3  : gray_to_bin_8 = 4'd2;
        4'd2  : gray_to_bin_8 = 4'd3;
        4'd6  : gray_to_bin_8 = 4'd4;
        4'd7  : gray_to_bin_8 = 4'd5;
        4'd5  : gray_to_bin_8 = 4'd6;
        4'd4  : gray_to_bin_8 = 4'd7;

        4'd12 : gray_to_bin_8 = 4'd0;
        4'd13 : gray_to_bin_8 = 4'd1;
        4'd15 : gray_to_bin_8 = 4'd2;
        4'd14 : gray_to_bin_8 = 4'd3;
        4'd10 : gray_to_bin_8 = 4'd4;
        4'd11 : gray_to_bin_8 = 4'd5;
        4'd9  : gray_to_bin_8 = 4'd6;
        4'd8  : gray_to_bin_8 = 4'd7;

        default : gray_to_bin_8 = {4{1'bx}};
      endcase
    end
  endfunction


  function automatic [3:0] gray_inc_6;
    input [3:0] gray;
    begin
      case (gray)
        4'd0  : gray_inc_6 = 4'd1;
        4'd1  : gray_inc_6 = 4'd3;

        4'd3  : gray_inc_6 = 4'd7;
        4'd7  : gray_inc_6 = 4'd6;
        4'd6  : gray_inc_6 = 4'd4;
        4'd4  : gray_inc_6 = 4'd12;
        4'd12 : gray_inc_6 = 4'd14;
        4'd14 : gray_inc_6 = 4'd15;
        4'd15 : gray_inc_6 = 4'd11;
        4'd11 : gray_inc_6 = 4'd9;
        4'd9  : gray_inc_6 = 4'd8;
        4'd8  : gray_inc_6 = 4'd0;

        4'd2,
        4'd5,
        4'd10,
        4'd13 : gray_inc_6 = {4{1'b0}};

        default : gray_inc_6 = {4{1'bx}};
      endcase
    end
  endfunction


  function automatic [3:0] gray_inc_8;
    input [3:0] gray;
    begin
      case (gray)
        4'd0  : gray_inc_8 = 4'd1;
        4'd1  : gray_inc_8 = 4'd3;
        4'd3  : gray_inc_8 = 4'd2;
        4'd2  : gray_inc_8 = 4'd6;
        4'd6  : gray_inc_8 = 4'd7;
        4'd7  : gray_inc_8 = 4'd5;
        4'd5  : gray_inc_8 = 4'd4;
        4'd4  : gray_inc_8 = 4'd12;

        4'd12 : gray_inc_8 = 4'd13;
        4'd13 : gray_inc_8 = 4'd15;
        4'd15 : gray_inc_8 = 4'd14;
        4'd14 : gray_inc_8 = 4'd10;
        4'd10 : gray_inc_8 = 4'd11;
        4'd11 : gray_inc_8 = 4'd9;
        4'd9  : gray_inc_8 = 4'd8;
        4'd8  : gray_inc_8 = 4'd0;

        default : gray_inc_8 = {4{1'bx}};
      endcase
    end
  endfunction



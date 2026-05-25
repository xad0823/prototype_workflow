//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------

 


module nic400_cd_a_cdc_comb_or_sse710_main
  (

    in_debug_axis,
    in_extsys0_axis,
    in_extsys1_axis,
    in_secenc_axis,
    in_expslv0_axis,
    in_expslv1_axis,
    in_hostcpu_axis,
    in_gpvmain_ahb_ib,   

    result
  );


  input             in_debug_axis;
  input             in_extsys0_axis;
  input             in_extsys1_axis;
  input             in_secenc_axis;
  input             in_expslv0_axis;
  input             in_expslv1_axis;
  input             in_hostcpu_axis;
  input             in_gpvmain_ahb_ib;   

  output            result;


  assign result = (in_debug_axis | in_extsys0_axis | in_extsys1_axis | in_secenc_axis | in_expslv0_axis | in_expslv1_axis | in_hostcpu_axis | in_gpvmain_ahb_ib);

  endmodule


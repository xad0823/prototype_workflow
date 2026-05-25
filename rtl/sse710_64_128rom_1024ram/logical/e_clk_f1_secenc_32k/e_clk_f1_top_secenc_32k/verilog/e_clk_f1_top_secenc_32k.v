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


module e_clk_f1_top_secenc_32k (
    input   wire                        RESETn,    


    input   wire                        S32KCLK,    

    output  wire                        S32KCLK_AON,   

    output  wire                        S32KCLK_SECENC,   

    input   wire                        S32KCLK_SECENC_DCT_CG,


    input   wire                        DFTCGEN,
    input   wire                        DFTRSTDISABLE
    
);


        

e_clk_f1_unit_s32kclk_aon_secenc_32k u_e_clk_f1_unit_s32kclk_aon_secenc_32k(
    .S32KCLK                                 (S32KCLK),
    .S32KCLK_AON                             (S32KCLK_AON)
);
  

        
 
     
e_clk_f1_unit_s32kclk_secenc_secenc_32k u_e_clk_f1_unit_s32kclk_secenc_secenc_32k(
    .RESETn                                  (RESETn),
    
    .S32KCLK                                 (S32KCLK),
 
    
    .S32KCLK_SECENC                          (S32KCLK_SECENC),

    .S32KCLK_SECENC_DCT_CG                   (S32KCLK_SECENC_DCT_CG),

    .DFTCGEN                                 (DFTCGEN),
    .DFTRSTDISABLE                           (DFTRSTDISABLE)
);


      

endmodule

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

module firewall_f0_resp_handler_write #(
  parameter FC_ME_LVL           = 0,
  parameter FC_PE_LVL           = 1,
  parameter FC_AXIID_WIDTH      = 9,
  parameter FC_AXIUSER_B_WIDTH  = 1,
  parameter FC_ID               = 1
)
(

    output  reg [FC_AXIID_WIDTH-1:0]         bid_s_o     ,
    output  reg [1:0]                        bresp_s_o   ,
    output  reg [FC_AXIUSER_B_WIDTH-1:0]     buser_s_o   ,
    output  reg                              bvalid_s_o  ,
    input  wire                              bready_s_i  ,

    input  wire [FC_AXIID_WIDTH-1:0]         bid_rm_i     ,
    input  wire [1:0]                        bresp_rm_i   ,
    input  wire [FC_AXIUSER_B_WIDTH-1:0]     buser_rm_i   ,
    input  wire                              bvalid_rm_i  ,
    output  reg                              bready_rm_o  ,

    input  wire [FC_AXIID_WIDTH-1:0]         bid_fh_i     ,
    input  wire [1:0]                        bresp_fh_i   ,
    input  wire [FC_AXIUSER_B_WIDTH-1:0]     buser_fh_i   ,
    input  wire                              bvalid_fh_i  ,
    output  reg                              bready_fh_o  ,

    input  wire [FC_AXIID_WIDTH-1:0]         bid_pchk_i     ,
    input  wire [1:0]                        bresp_pchk_i   ,
    input  wire [FC_AXIUSER_B_WIDTH-1:0]     buser_pchk_i   ,
    input  wire                              bvalid_pchk_i  ,
    output  reg                              bready_pchk_o  ,

    input  wire [FC_AXIID_WIDTH-1:0]         bid_cfg_i     ,
    input  wire [1:0]                        bresp_cfg_i   ,
    input  wire [FC_AXIUSER_B_WIDTH-1:0]     buser_cfg_i   ,
    input  wire                              bvalid_cfg_i  ,
    output  reg                              bready_cfg_o  ,

    input  wire                              fw_st_i , 
    input  wire                              pe_st_i,  
    input  wire                              pe_st_en_i
);

  always @*
  begin: resp

    bid_s_o    = {FC_AXIID_WIDTH{1'b0}};
    bresp_s_o  = 2'b00;
    buser_s_o  = {FC_AXIUSER_B_WIDTH{1'b0}};
    bvalid_s_o = 1'b0;
    bready_rm_o = 1'b0;
    bready_fh_o = 1'b0;
    bready_pchk_o = 1'b0;
    bready_cfg_o = 1'b0;


    if (bvalid_rm_i && !bvalid_fh_i) begin      
        bid_s_o    =  bid_rm_i;
        bresp_s_o  =  bresp_rm_i;
        buser_s_o  =  buser_rm_i;
        bvalid_s_o =  bvalid_rm_i;
        bready_rm_o = bready_s_i;

    end else if (bvalid_fh_i && FC_PE_LVL > 0) begin

      bid_s_o    =  bid_fh_i;
      bvalid_s_o =  bvalid_fh_i;
      bready_fh_o = bready_s_i;

      if (pe_st_i) begin 
        bresp_s_o  =  bresp_fh_i; 
        buser_s_o[0]  =  1'b1;
      end else begin
        bresp_s_o  =  2'b00; 
        buser_s_o[0]  =  1'b0;
      end


    end else if (bvalid_pchk_i && FC_ID == 0) begin
      if (bresp_pchk_i ==  2'b11 || bresp_pchk_i == 2'b10) begin 
        bid_s_o    =  bid_pchk_i;
        bvalid_s_o =  bvalid_pchk_i;
        bready_pchk_o = bready_s_i;

        if (fw_st_i) begin 
          bresp_s_o  =  bresp_pchk_i; 
          buser_s_o[0]  =  1'b1;
        end else begin
          bresp_s_o  =  2'b00; 
          buser_s_o[0]  =  1'b0;
        end

      end else begin
        bid_s_o    =  bid_pchk_i;
        bresp_s_o  =  bresp_pchk_i;
        buser_s_o  =  buser_pchk_i;
        bvalid_s_o =  bvalid_pchk_i;
        bready_pchk_o = bready_s_i;
      end
    end else if (bvalid_cfg_i && FC_ID == 0) begin
      if (bresp_cfg_i == 2'b10) begin 
        bid_s_o    =  bid_cfg_i;
        bvalid_s_o =  bvalid_cfg_i;
        bready_cfg_o = bready_s_i;

        if (fw_st_i) begin 
          bresp_s_o  =  bresp_cfg_i; 
          buser_s_o[0]  =  1'b1;
        end else begin
          bresp_s_o  =  2'b00; 
          buser_s_o[0]  =  1'b0;
        end

      end else begin
        bid_s_o    =  bid_cfg_i;
        bresp_s_o  =  bresp_cfg_i;
        buser_s_o  =  buser_cfg_i;
        bvalid_s_o =  bvalid_cfg_i;
        bready_cfg_o = bready_s_i;
      end
    end
  end 
endmodule

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

module firewall_f0_resp_handler_read #(
  parameter FC_ME_LVL           = 0,
  parameter FC_PE_LVL           = 1,
  parameter FC_AXIDATA_WIDTH    = 64,
  parameter FC_AXIID_WIDTH      = 9,
  parameter FC_AXIUSER_R_WIDTH  = 1,
  parameter FC_MST_ID_WIDTH     = 8,
  parameter FC_NUM_MST_ID       = 4,
  parameter FC_ID               = 1,
  parameter [FC_MST_ID_WIDTH*FC_NUM_MST_ID-1:0] FC_MST_ID_VAL = {FC_NUM_MST_ID*FC_MST_ID_WIDTH{1'b0}},
  parameter [FC_AXIDATA_WIDTH*FC_NUM_MST_ID-1:0] FC_ERR_RESP_PER_MST_ID = {FC_NUM_MST_ID*FC_AXIDATA_WIDTH{1'b0}},
  parameter [FC_AXIDATA_WIDTH-1:0] FC_ERR_RESP_DEF = {FC_AXIDATA_WIDTH{1'b0}},
  parameter FC_SINGLE_MST       = 1
)
(
    output  reg [FC_AXIID_WIDTH-1:0]         rid_s_o     ,
    output  reg [FC_AXIDATA_WIDTH-1:0]       rdata_s_o   ,
    output  reg [1:0]                        rresp_s_o   ,
    output  reg                              rlast_s_o   ,
    output  reg [FC_AXIUSER_R_WIDTH-1:0]     ruser_s_o   ,
    output  reg                              rvalid_s_o  ,
    input  wire                              rready_s_i  ,

    input  wire [FC_AXIID_WIDTH-1:0]         rid_rm_i     ,
    input  wire [FC_AXIDATA_WIDTH-1:0]       rdata_rm_i   ,
    input  wire [1:0]                        rresp_rm_i   ,
    input  wire                              rlast_rm_i   ,
    input  wire [FC_AXIUSER_R_WIDTH-1:0]     ruser_rm_i   ,
    input  wire                              rvalid_rm_i  ,
    input  wire [FC_MST_ID_WIDTH-1:0]        mst_id_rm_i  ,
    output  reg                              rready_rm_o  ,

    input  wire [FC_AXIID_WIDTH-1:0]         rid_fh_i     ,
    input  wire [FC_AXIDATA_WIDTH-1:0]       rdata_fh_i   ,
    input  wire [1:0]                        rresp_fh_i   ,
    input  wire                              rlast_fh_i   ,
    input  wire [FC_AXIUSER_R_WIDTH-1:0]     ruser_fh_i   ,
    input  wire                              rvalid_fh_i  ,
    input  wire [FC_MST_ID_WIDTH-1:0]        mst_id_fh_i  ,
    output  reg                              rready_fh_o  ,

    input  wire [FC_AXIID_WIDTH-1:0]         rid_pchk_i     ,
    input  wire [FC_AXIDATA_WIDTH-1:0]       rdata_pchk_i   ,
    input  wire [1:0]                        rresp_pchk_i   ,
    input  wire                              rlast_pchk_i   ,
    input  wire [FC_AXIUSER_R_WIDTH-1:0]     ruser_pchk_i   ,
    input  wire                              rvalid_pchk_i  ,
    input  wire [FC_MST_ID_WIDTH-1:0]        mst_id_pchk_i  ,
    output  reg                              rready_pchk_o  ,

    input  wire [FC_AXIID_WIDTH-1:0]         rid_cfg_i     ,
    input  wire [FC_AXIDATA_WIDTH-1:0]       rdata_cfg_i   ,
    input  wire [1:0]                        rresp_cfg_i   ,
    input  wire                              rlast_cfg_i   ,
    input  wire [FC_AXIUSER_R_WIDTH-1:0]     ruser_cfg_i   ,
    input  wire                              rvalid_cfg_i  ,
    input  wire [FC_MST_ID_WIDTH-1:0]        mst_id_cfg_i  ,
    output  reg                              rready_cfg_o  ,


    input  wire                              me_st_rdum_i ,
    input  wire                              me_st_en_i ,
    input  wire [1:0]                        fw_st_i , 
    input  wire [1:0]                        pe_st_i , 
    input  wire                              pe_st_en_i

);

integer i;
integer j_rm;
integer j_fh;
integer j_pchk;
integer j_cfg;
reg mst_id_matched_fh;
reg mst_id_matched_pchk;
reg mst_id_matched_cfg;

  always @*
  begin: resp

    mst_id_matched_fh = 1'b0;
    mst_id_matched_pchk = 1'b0;
    mst_id_matched_cfg = 1'b0;
    j_rm = 0;
    j_fh = 0;
    j_pchk = 0;
    j_cfg = 0;

    rid_s_o    =  {FC_AXIID_WIDTH{1'b0}};
    rdata_s_o  =  {FC_AXIDATA_WIDTH{1'b0}};
    rresp_s_o  =  2'b00;
    rlast_s_o  =  1'b0;
    ruser_s_o  =  {FC_AXIUSER_R_WIDTH{1'b0}};
    rvalid_s_o =  1'b0;
    rready_rm_o = 1'b0;
    rready_fh_o = 1'b0;
    rready_pchk_o = 1'b0;
    rready_cfg_o = 1'b0;

    if (rvalid_rm_i && !rvalid_fh_i) begin  
        rid_s_o    =  rid_rm_i;
        rdata_s_o  =  rdata_rm_i;
        rresp_s_o  =  rresp_rm_i;
        rlast_s_o  =  rlast_rm_i;
        ruser_s_o  =  ruser_rm_i;
        rvalid_s_o =  rvalid_rm_i;
        rready_rm_o = rready_s_i ;

    end else if (rvalid_fh_i && FC_PE_LVL > 0) begin
      rid_s_o    =  rid_fh_i;
      rlast_s_o  =  rlast_fh_i;
      rvalid_s_o =  rvalid_fh_i;
      rready_fh_o = rready_s_i;


      if (pe_st_i[0]) begin 
        rresp_s_o  =  rresp_fh_i; 
        ruser_s_o[0]  =  1'b1;
      end else begin
        rresp_s_o  =  2'b00; 
        ruser_s_o[0]  =  1'b0;
      end

      if (pe_st_i[1]) begin  
        rdata_s_o  =  {FC_AXIDATA_WIDTH{1'b0}};
      end else begin  

        for (i=0; i<FC_NUM_MST_ID; i=i+1) begin
          if (mst_id_fh_i == FC_MST_ID_VAL[i*FC_MST_ID_WIDTH+FC_MST_ID_WIDTH-1-: FC_MST_ID_WIDTH]) begin
            mst_id_matched_fh = 1'b1;
            j_fh=i;
          end
        end

        if (mst_id_matched_fh && (FC_SINGLE_MST == 0)) begin
          rdata_s_o = FC_ERR_RESP_PER_MST_ID[j_fh*FC_AXIDATA_WIDTH+FC_AXIDATA_WIDTH-1 -: FC_AXIDATA_WIDTH];
        end else begin
          rdata_s_o = FC_ERR_RESP_DEF;
        end
      end


    end else if (rvalid_pchk_i && FC_ID == 0) begin
      if (rresp_pchk_i ==  2'b11 || rresp_pchk_i == 2'b10) begin 
        rid_s_o    =  rid_pchk_i;
        rlast_s_o  =  rlast_pchk_i;
        rvalid_s_o =  rvalid_pchk_i;
        rready_pchk_o = rready_s_i;

        if (fw_st_i[0]) begin 
          rresp_s_o  =  rresp_pchk_i; 
          ruser_s_o[0]  =  1'b1; 
        end else begin
          rresp_s_o  =  2'b00; 
          ruser_s_o[0]  =  1'b0; 
        end

        if (fw_st_i[1]) begin  
          rdata_s_o  =  {FC_AXIDATA_WIDTH{1'b0}};
        end else begin  

          for (i=0; i<FC_NUM_MST_ID; i=i+1) begin
            if (mst_id_pchk_i == FC_MST_ID_VAL[i*FC_MST_ID_WIDTH+FC_MST_ID_WIDTH-1-: FC_MST_ID_WIDTH]) begin
              mst_id_matched_pchk = 1'b1;
              j_pchk=i;
            end
          end

          if (mst_id_matched_pchk && (FC_SINGLE_MST == 0)) begin
            rdata_s_o = FC_ERR_RESP_PER_MST_ID[j_pchk*FC_AXIDATA_WIDTH+FC_AXIDATA_WIDTH-1 -: FC_AXIDATA_WIDTH];
          end else begin
            rdata_s_o = FC_ERR_RESP_DEF;
          end
        end

      end else begin 
        rid_s_o    =  rid_pchk_i;
        rdata_s_o  =  rdata_pchk_i;
        rresp_s_o  =  rresp_pchk_i;
        rlast_s_o  =  rlast_pchk_i;
        ruser_s_o  =  ruser_pchk_i;
        rvalid_s_o =  rvalid_pchk_i;
        rready_pchk_o = rready_s_i;
      end

    end else if (rvalid_cfg_i  && FC_ID == 0) begin
      if (rresp_cfg_i == 2'b10) begin 
        rid_s_o    =  rid_cfg_i;
        rlast_s_o  =  rlast_cfg_i;
        rvalid_s_o =  rvalid_cfg_i;
        rready_cfg_o = rready_s_i;

        if (fw_st_i[0]) begin 
          rresp_s_o  =  rresp_cfg_i; 
          ruser_s_o[0]  =  1'b1; 
        end else begin
          rresp_s_o  =  2'b00; 
          ruser_s_o[0]  =  1'b0; 
        end

        if (fw_st_i[1]) begin  
          rdata_s_o  =  {FC_AXIDATA_WIDTH{1'b0}};
        end else begin  

          for (i=0; i<FC_NUM_MST_ID; i=i+1) begin
            if (mst_id_cfg_i == FC_MST_ID_VAL[i*FC_MST_ID_WIDTH+FC_MST_ID_WIDTH-1-: FC_MST_ID_WIDTH]) begin
              mst_id_matched_cfg = 1'b1;
              j_cfg=i;
            end
          end

          if (mst_id_matched_cfg && (FC_SINGLE_MST == 0)) begin
            rdata_s_o = FC_ERR_RESP_PER_MST_ID[j_cfg*FC_AXIDATA_WIDTH+FC_AXIDATA_WIDTH-1 -: FC_AXIDATA_WIDTH];
          end else begin
            rdata_s_o = FC_ERR_RESP_DEF;
          end
        end

      end else begin 
        rid_s_o    =  rid_cfg_i;
        rdata_s_o  =  rdata_cfg_i;
        rresp_s_o  =  rresp_cfg_i;
        rlast_s_o  =  rlast_cfg_i;
        ruser_s_o  =  ruser_cfg_i;
        rvalid_s_o =  rvalid_cfg_i;
        rready_cfg_o = rready_s_i;
      end

    end
  end 
endmodule

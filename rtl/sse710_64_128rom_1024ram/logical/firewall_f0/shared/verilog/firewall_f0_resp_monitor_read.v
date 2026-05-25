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

module firewall_f0_resp_monitor_read #(
  parameter FC_MST_ID_SINGLE_MST = 0,
  parameter FC_SINGLE_MST       = 1,
  parameter FC_ME_LVL           = 0,
  parameter FW_SE_LVL           = 2'h1, 
  parameter FC_INST_SPT         = 0,
  parameter FC_PRIV_SPT         = 0,
  parameter FC_ADDR_WIDTH       = 32,
  parameter FC_MST_ID_WIDTH     = 8,
  parameter FC_AXIDATA_WIDTH    = 64,
  parameter FC_AXIID_WIDTH      = 9,
  parameter FC_AXIUSER_R_WIDTH  = 1,
  parameter TRACKER_PAYLOAD_WIDTH_AR = 1,
  parameter FC_AXI_READ_RESP_INTRLV  = 1,  
  parameter NUM_OUTSTAND             = 4,
  parameter FC_NUM_MST_ID            = 4,
  parameter [FC_MST_ID_WIDTH*FC_NUM_MST_ID-1:0] FC_MST_ID_VAL = {FC_NUM_MST_ID*FC_MST_ID_WIDTH{1'b0}},
  parameter [FC_AXIDATA_WIDTH*FC_NUM_MST_ID-1:0] FC_ERR_RESP_PER_MST_ID = {FC_NUM_MST_ID*FC_AXIDATA_WIDTH{1'b0}},
  parameter [FC_AXIDATA_WIDTH-1:0] FC_ERR_RESP_DEF = {FC_AXIDATA_WIDTH{1'b0}}

)
(
    input  wire                                clk,
    input  wire                                reset_n,

    input  wire [FC_AXIID_WIDTH-1:0]           rid_m_i     ,
    input  wire [FC_AXIDATA_WIDTH-1:0]         rdata_m_i   ,
    input  wire [1:0]                          rresp_m_i   ,
    input  wire                                rlast_m_i   ,
    input  wire [FC_AXIUSER_R_WIDTH-1:0]       ruser_m_i   ,
    input  wire                                rvalid_m_i  ,
    output wire                                rready_m_o  ,

    input  wire                                rvalid_fh_i ,

    output wire [FC_AXIID_WIDTH-1:0]           rid_rh_o     ,
    output wire [FC_AXIDATA_WIDTH-1:0]         rdata_rh_o   ,
    output wire [1:0]                          rresp_rh_o   ,
    output wire                                rlast_rh_o   ,
    output reg  [FC_AXIUSER_R_WIDTH-1:0]       ruser_rh_o   ,
    output wire                                rvalid_rh_o  ,
    input  wire                                rready_rh_i  ,
    output wire [FC_MST_ID_WIDTH-1:0]          mst_id_rm_o  ,

    output wire [FC_AXIID_WIDTH-1:0]           tracker_id_rd_ch_o,
    output wire                                tracker_read_rd_ch_o,
    input  wire [TRACKER_PAYLOAD_WIDTH_AR-1:0] tracker_dout_rd_ch_i,
    input wire                                 tracker_dout_rd_ch_vld_i,

    input  wire                                rb_st_me_en_i,
    input  wire                                me_st_rdum_i,

    output wire                                rd_edr_wen_o,
    output wire [31:0]                         rd_edr_addr_lwr_o,
    output wire [31:0]                         rd_edr_addr_uppr_o,
    output wire [FC_MST_ID_WIDTH+4-1:0]        rd_edr_prop_o 
);

  `include "firewall_f0_log2.vh"
  localparam OUTST_PTR_WIDTH = firewall_f0_log2(NUM_OUTSTAND);
  localparam AW = (FC_ME_LVL == 1) ? 0 : FC_ADDR_WIDTH;

  localparam RSPQ_W = FC_AXIID_WIDTH+1; 
  localparam TID_STORE_W = TRACKER_PAYLOAD_WIDTH_AR+FC_AXIID_WIDTH+1; 

generate
  if (FC_ME_LVL == 0) begin : NO_MON
    assign rd_edr_wen_o           = 1'b0;
    assign rd_edr_addr_uppr_o     = {32 {1'b0}};
    assign rd_edr_addr_lwr_o      = {32 {1'b0}};
    assign rd_edr_prop_o          = {FC_MST_ID_WIDTH+4 {1'b0}};
    assign rid_rh_o               = rid_m_i;
    assign rdata_rh_o             = rdata_m_i;
    assign rresp_rh_o             = rresp_m_i;
    assign rlast_rh_o             = rlast_m_i;
    always@(ruser_m_i) ruser_rh_o = ruser_m_i;
    assign rvalid_rh_o            = rvalid_m_i;
    assign rready_m_o             = rready_rh_i;
    assign tracker_id_rd_ch_o     = {FC_AXIID_WIDTH {1'b0}};
    assign tracker_read_rd_ch_o   = 1'b0;
    assign mst_id_rm_o            = {FC_MST_ID_WIDTH {1'b0}};
  end else if (FC_ME_LVL > 0) begin : MON

    reg [FC_AXIDATA_WIDTH-1:0]         rdata_rh_reg;
    wire fault;
    reg  first_valid_in_burst; 
    reg  first_beat_in_burst; 
    wire has_faulted;
    reg  first_trkr_req_r;

    reg [TRACKER_PAYLOAD_WIDTH_AR-1:0] track_data;

    if ( FC_AXI_READ_RESP_INTRLV == 0) begin : NO_INTRLV 

      reg  track_data_is_valid;
      reg  has_faulted_reg;


      always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
          first_beat_in_burst  <= 1'b1;
          first_valid_in_burst <= 1'b1;
          has_faulted_reg      <= 1'b0;
          track_data_is_valid  <= 1'b0;
        end else begin
          if (rvalid_m_i) begin
            if (rvalid_m_i && rlast_m_i && rready_m_o) begin 
              first_beat_in_burst  <= 1'b1;
              first_valid_in_burst <= 1'b1;
            end else begin
              if (rready_m_o) begin
                first_beat_in_burst <= 1'b0;
              end

              first_valid_in_burst <= 1'b0;
            end
          end


          if (rvalid_m_i && rready_m_o && rlast_m_i) begin 
            has_faulted_reg <= 1'b0;
          end else if (fault) begin 
            has_faulted_reg <= 1'b1;
          end

        end
      end


      assign rvalid_rh_o   = rvalid_m_i;

      assign rready_m_o  = rready_rh_i;
      assign has_faulted = has_faulted_reg;
      assign mst_id_rm_o = {FC_MST_ID_WIDTH {1'b0}};

      always@* track_data = {TRACKER_PAYLOAD_WIDTH_AR {1'b0}};

    end else begin : INTRLV

      reg [RSPQ_W*NUM_OUTSTAND-1:0] resp_q;           
      reg [NUM_OUTSTAND-1:0]        has_faulted_all;  
      integer                       match_idx;
      reg                           match_found_wr;
      reg                           match_found_del;
      reg [NUM_OUTSTAND-1:0]        first_valid_in_burst_arr;
      reg                           has_faulted_reg;
      reg [NUM_OUTSTAND-1:0]        first_beat_in_burst_arr;

      reg [TID_STORE_W-1:0]         tracker_id_store [NUM_OUTSTAND-1:0]; 

      reg                           tracker_id_store_del;
      reg                           tracker_id_store_wr;
      integer                       tracker_id_store_idx;

      always @(posedge clk or negedge reset_n) begin: rq
        if (!reset_n) begin
          resp_q          <= {RSPQ_W*NUM_OUTSTAND{1'b0}};
        end else begin
          if (match_found_wr) begin
            resp_q[(RSPQ_W*match_idx)+RSPQ_W-1 -: RSPQ_W] <= {rid_m_i, 1'b1};  
          end else if (match_found_del) begin
            resp_q[(RSPQ_W*match_idx)+RSPQ_W-1 -: RSPQ_W] <= {rid_m_i, 1'b0};  
          end
        end
      end

      always @(posedge clk or negedge reset_n) begin: fa
      integer i;
        if (!reset_n) begin
          has_faulted_all <= {NUM_OUTSTAND{1'b0}};
        end else begin
          for (i=NUM_OUTSTAND-1;i>=0;i=i-1) begin
            if (rvalid_m_i && rready_m_o && rlast_m_i && ({rid_m_i, 1'b1} == resp_q[(RSPQ_W*i)+RSPQ_W-1 -: RSPQ_W])) begin
              has_faulted_all[i] <= 1'b0;
            end else if (fault && (({rid_m_i, 1'b1} == resp_q[(RSPQ_W*i)+RSPQ_W-1 -: RSPQ_W]) || (first_valid_in_burst && match_found_wr && (i == match_idx)))) begin
              has_faulted_all[i] <= 1'b1;
            end
          end 
        end
      end

      always @*
      begin: match
      integer i;
        match_found_wr = 1'b0;
        match_found_del = 1'b0;
        match_idx = 0;
        has_faulted_reg = 1'b0;

        for (i=NUM_OUTSTAND-1;i>=0;i=i-1) begin
          if(first_valid_in_burst && rvalid_m_i && !rvalid_fh_i && !resp_q[RSPQ_W*i] && !rlast_m_i ) begin 
            match_idx = i;
            match_found_wr = 1'b1;
          end else if (rvalid_m_i && rlast_m_i && rready_m_o && ({rid_m_i,1'b1} == resp_q[(RSPQ_W*i)+RSPQ_W-1 -: RSPQ_W])) begin
            match_idx = i;
            match_found_del = 1'b1;
          end

          if ({rid_m_i,1'b1} == resp_q[(RSPQ_W*i)+RSPQ_W-1 -: RSPQ_W]) begin
            has_faulted_reg = has_faulted_all[i];
          end
        end
      end

      assign has_faulted = has_faulted_reg;

      always @* begin: first_valid
      integer i;
        first_valid_in_burst_arr = {NUM_OUTSTAND{1'b1}};
        for (i=0;i<NUM_OUTSTAND;i=i+1) begin
          if ((rvalid_m_i && !rvalid_fh_i && ({rid_m_i, 1'b1} == resp_q[RSPQ_W*i+RSPQ_W-1 -: RSPQ_W])) ) begin
            first_valid_in_burst_arr[i] = 1'b0;  
          end
        end

        first_valid_in_burst = &first_valid_in_burst_arr;
      end


      assign rvalid_rh_o = rvalid_m_i;
      assign rready_m_o  = rready_rh_i;

      always @(posedge clk or negedge reset_n) begin : tracker_id_store_sync
        integer i;
        if (!reset_n) begin
          for(i=0;i<NUM_OUTSTAND;i=i+1) begin
            tracker_id_store[i] <= {TID_STORE_W {1'b0}};
          end
        end else begin
          if (tracker_id_store_del) begin 
            tracker_id_store[tracker_id_store_idx[OUTST_PTR_WIDTH-1:0]][0] <= 1'b0;

          end else if (tracker_id_store_wr) begin
            tracker_id_store[tracker_id_store_idx[OUTST_PTR_WIDTH-1:0]] <= {tracker_dout_rd_ch_i, rid_m_i, 1'b1};
          end
        end
      end


      always@* begin : tracker_id_store_async
        integer i;
        tracker_id_store_wr  = 1'b0;
        tracker_id_store_del = 1'b0;
        tracker_id_store_idx = 0;
        for (i=0;i<NUM_OUTSTAND;i=i+1) begin
          if (rvalid_m_i && rlast_m_i && rready_m_o && tracker_id_store[i][FC_AXIID_WIDTH+1-1:0] == {rid_m_i, 1'b1}) begin 
            tracker_id_store_del = 1'b1;
            tracker_id_store_idx = i;

          end else if (tracker_read_rd_ch_o && !(rlast_m_i && rvalid_m_i && rready_m_o)) begin   
            if (tracker_id_store[i][0] == 1'b0) begin 
              tracker_id_store_wr  = 1'b1;
              tracker_id_store_idx = i;
            end
          end
        end
      end

    if (FC_SINGLE_MST==1) begin : SM
      wire [FC_MST_ID_WIDTH-1:0]     mst_id_rm_o_reg;

      assign   mst_id_rm_o_reg = FC_MST_ID_SINGLE_MST[FC_MST_ID_WIDTH-1 : 0];

      always @* begin :MST_ID_NO_SM
        integer i;
        if (tracker_dout_rd_ch_vld_i) begin
          track_data      = tracker_dout_rd_ch_i;
        end else begin
          track_data    = {TRACKER_PAYLOAD_WIDTH_AR {1'b0}};
          for (i=0;i<NUM_OUTSTAND;i=i+1) begin
            if (tracker_id_store[i][FC_AXIID_WIDTH+1-1:0] == {rid_m_i, 1'b1}) begin
              track_data      = tracker_id_store[i][TID_STORE_W-1:TID_STORE_W-TRACKER_PAYLOAD_WIDTH_AR];
            end
          end
        end
      end

      assign mst_id_rm_o = mst_id_rm_o_reg;

    end else begin : NO_SM
      reg [FC_MST_ID_WIDTH-1:0]     mst_id_rm_o_reg;

      always @* begin :mst_id_no_sm
        integer i;
        if (tracker_dout_rd_ch_vld_i) begin
          mst_id_rm_o_reg = tracker_dout_rd_ch_i[FC_MST_ID_WIDTH+AW+3-1:AW+3];
          track_data      = tracker_dout_rd_ch_i;
        end else begin

          mst_id_rm_o_reg = {FC_MST_ID_WIDTH{1'b0}};

          track_data      = {TRACKER_PAYLOAD_WIDTH_AR {1'b0}};
          for (i=0;i<NUM_OUTSTAND;i=i+1) begin
            if (tracker_id_store[i][FC_AXIID_WIDTH+1-1:0] == {rid_m_i, 1'b1}) begin
              mst_id_rm_o_reg = tracker_id_store[i][TID_STORE_W-1:TID_STORE_W-FC_MST_ID_WIDTH];
              track_data      = tracker_id_store[i][TID_STORE_W-1:TID_STORE_W-TRACKER_PAYLOAD_WIDTH_AR];
            end
          end
        end
      end

      assign mst_id_rm_o = mst_id_rm_o_reg;

    end 


    end 



    assign fault = rvalid_m_i && (rresp_m_i == 2'b10 || rresp_m_i == 2'b11) && ~ruser_m_i[0];

    assign rd_edr_wen_o = rb_st_me_en_i &&
                          (rvalid_m_i && rready_m_o && rlast_m_i) &&
                          (fault || has_faulted); 


    if (FC_ME_LVL == 1) begin : MON1
      assign {rd_edr_addr_uppr_o, rd_edr_addr_lwr_o} = 64'b0;
    end else if (AW == 64) begin : MON2_AW_EQ_64
      assign {rd_edr_addr_uppr_o, rd_edr_addr_lwr_o} = (tracker_dout_rd_ch_vld_i) ? tracker_dout_rd_ch_i[AW+3-1:3] :
                                                                                    track_data[AW+3-1:3];
    end else begin : MON2_AW_LT_64
      assign {rd_edr_addr_uppr_o, rd_edr_addr_lwr_o} = (tracker_dout_rd_ch_vld_i) ? {{64-AW {1'b0}}, tracker_dout_rd_ch_i[AW+3-1:3]} :
                                                                                    {{64-AW {1'b0}}, track_data[AW+3-1:3]};
    end

    if (FC_SINGLE_MST == 0) begin : NO_SM_PROP
      if (FC_ME_LVL == 1) begin : ME1
        assign rd_edr_prop_o[FC_MST_ID_WIDTH+4-1:4]      = (tracker_dout_rd_ch_vld_i) ? tracker_dout_rd_ch_i[FC_MST_ID_WIDTH+3-1:3] : track_data[FC_MST_ID_WIDTH+3-1:3]; 

      end else begin : ME2 
        assign rd_edr_prop_o[FC_MST_ID_WIDTH+4-1:4]      = (tracker_dout_rd_ch_vld_i) ? tracker_dout_rd_ch_i[FC_MST_ID_WIDTH+AW+3-1:AW+3] : track_data[FC_MST_ID_WIDTH+AW+3-1:AW+3]; 
      end 
    end else begin : SM_PROP  
      assign rd_edr_prop_o[FC_MST_ID_WIDTH+4-1:4]      = FC_MST_ID_SINGLE_MST[FC_MST_ID_WIDTH-1:0]; 
    end

    assign rd_edr_prop_o[3]   = 1'b0; 
    assign rd_edr_prop_o[2] = (FC_INST_SPT == 1) ? (tracker_dout_rd_ch_vld_i) ? tracker_dout_rd_ch_i[2] : track_data[2] : 1'b0; 
    assign rd_edr_prop_o[1] = (FC_PRIV_SPT == 1) ? (tracker_dout_rd_ch_vld_i) ? tracker_dout_rd_ch_i[0] : track_data[0] : 1'b0; 
    assign rd_edr_prop_o[0] = (FW_SE_LVL   == 1) ? (tracker_dout_rd_ch_vld_i) ? tracker_dout_rd_ch_i[1] : track_data[1] : 1'b0; 

    always @ (posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        first_trkr_req_r <= 1'b1;
      end
      else begin
        if (rvalid_m_i & !rready_m_o && !rvalid_fh_i) begin
          first_trkr_req_r <= 1'b0;
        end
        else begin
          first_trkr_req_r <= 1'b1;
        end
      end
    end

    assign tracker_read_rd_ch_o = rvalid_m_i && !rvalid_fh_i && first_trkr_req_r && first_valid_in_burst;
    assign tracker_id_rd_ch_o   = rid_m_i;

    assign rid_rh_o   = rid_m_i;
    assign rdata_rh_o = rdata_rh_reg;
    assign rresp_rh_o = rresp_m_i;
    assign rlast_rh_o = rlast_m_i;
    always@(*) begin
      ruser_rh_o    = ruser_m_i;
      ruser_rh_o[0] = ruser_m_i[0] || (rb_st_me_en_i && fault); 
    end


  if (FC_SINGLE_MST == 0) begin : RD_NO_SM
    reg mst_id_matched_rm;
    integer j_rm;

    always @*
    begin: resp
    integer i;
      rdata_rh_reg = rdata_m_i;
      mst_id_matched_rm = 1'b0;
      j_rm = 0;
      if (rvalid_m_i && (rresp_m_i == 2'b11 || rresp_m_i == 2'b10) && rb_st_me_en_i && !ruser_m_i[0] && !me_st_rdum_i) begin
        for (i=0; i<FC_NUM_MST_ID; i=i+1) begin
          if (mst_id_rm_o == FC_MST_ID_VAL[i*FC_MST_ID_WIDTH+FC_MST_ID_WIDTH-1-: FC_MST_ID_WIDTH]) begin
            mst_id_matched_rm = 1'b1;
            j_rm=i;
          end
        end
        if (mst_id_matched_rm) begin
          rdata_rh_reg = FC_ERR_RESP_PER_MST_ID[j_rm*FC_AXIDATA_WIDTH+FC_AXIDATA_WIDTH-1 -: FC_AXIDATA_WIDTH];
        end else begin
          rdata_rh_reg = FC_ERR_RESP_DEF;
        end
      end
    end

  end else begin : RD_SM 
    always @*
    begin: resp
    integer i;
      rdata_rh_reg = rdata_m_i;
      if (rvalid_m_i && (rresp_m_i == 2'b11 || rresp_m_i == 2'b10) && rb_st_me_en_i && !ruser_m_i[0] && !me_st_rdum_i) begin
          rdata_rh_reg = FC_ERR_RESP_DEF;
      end
    end

  end  
  end
endgenerate
endmodule

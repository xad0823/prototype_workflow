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

module firewall_f0_wr_data_handler #(
  parameter FC_PE_LVL = 0,
  parameter FC_AXIDATA_WIDTH    = 64,
  parameter FC_AXIUSER_W_WIDTH = 1
)
(
    input  wire                       clk,
    input  wire                       reset_n,

    input  wire [FC_AXIDATA_WIDTH-1:0]            wdata_s_i   ,
    input  wire [FC_AXIDATA_WIDTH/8-1:0]          wstrb_s_i   ,
    input  wire                                   wlast_s_i   ,
    input  wire [FC_AXIUSER_W_WIDTH-1:0]          wuser_s_i   ,
    input  wire                                   wvalid_s_i  ,
    output reg                                    wready_s_o  ,
    input  wire                                   awvalid_i   ,
    input  wire                                   awready_i   ,

    output reg  [FC_AXIDATA_WIDTH-1:0]            wdata_m_o   ,
    output reg  [FC_AXIDATA_WIDTH/8-1:0]          wstrb_m_o   ,
    output reg                                    wlast_m_o   ,
    output reg  [FC_AXIUSER_W_WIDTH-1:0]          wuser_m_o   ,
    output reg                                    wvalid_m_o  ,
    input  wire                                   wready_m_i  ,

    input  wire                                   pe_rse_st_vld,
    input  wire [1:0]                             pe_rse_st_val

);

generate

  if (FC_PE_LVL == 0 ) begin : NO_PE
    always @*
    begin: fthru
      wdata_m_o = wdata_s_i;
      wstrb_m_o = wstrb_s_i;
      wlast_m_o = wlast_s_i;
      wuser_m_o = wuser_s_i;
      wvalid_m_o = wvalid_s_i;
      wready_s_o = wready_m_i;
    end

  end else begin : PE


    reg [1:0] pe_rse_st_val_reg;
    reg wdata_allow;
    reg axready_done;
    reg aw_single_done;
    reg single_data_late_aw;

    always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         pe_rse_st_val_reg <= 2'b00;  
         single_data_late_aw <= 1'b0;
      end else begin
        if (wvalid_s_i && wlast_s_i && wready_s_o && pe_rse_st_vld) begin
          single_data_late_aw <= 1'b1;     
        end else if (!pe_rse_st_vld) begin
          single_data_late_aw <= 1'b0;
        end

        if (wvalid_s_i && wlast_s_i && wready_s_o) begin 
          pe_rse_st_val_reg <= 2'b00;  
        end else if (pe_rse_st_vld && !single_data_late_aw ) begin
          pe_rse_st_val_reg <= pe_rse_st_val;
        end
      end
    end



    always @*
    begin : wdata_chk
    if (FC_PE_LVL > 0 ) begin
        if (pe_rse_st_vld) begin
          wdata_allow = (pe_rse_st_val == 2'b11);
        end else begin
          wdata_allow = (pe_rse_st_val_reg == 2'b11);
        end
    end else begin
        wdata_allow = 1'b0;
      end
    end


    always @* begin
      if (wdata_allow && wvalid_s_i) begin
        wdata_m_o = wdata_s_i;
        wstrb_m_o = wstrb_s_i;
        wlast_m_o = wlast_s_i;
        wuser_m_o = wuser_s_i;
        wvalid_m_o = wvalid_s_i;
        wready_s_o = wready_m_i;
      end else if ((axready_done || aw_single_done) && (pe_rse_st_val == 2'b01 || pe_rse_st_val_reg == 2'b01 || pe_rse_st_val == 2'b10 || pe_rse_st_val_reg == 2'b10  )) begin
        wdata_m_o = {FC_AXIDATA_WIDTH{1'b0}};
        wstrb_m_o = {FC_AXIDATA_WIDTH/8{1'b0}};
        wlast_m_o = 1'b0;
        wuser_m_o = {FC_AXIUSER_W_WIDTH{1'b0}};
        wvalid_m_o = 1'b0;
        wready_s_o = 1'b1;
      end else begin
        wdata_m_o = {FC_AXIDATA_WIDTH{1'b0}};
        wstrb_m_o = {FC_AXIDATA_WIDTH/8{1'b0}};
        wlast_m_o = 1'b0;
        wuser_m_o = {FC_AXIUSER_W_WIDTH{1'b0}};
        wvalid_m_o = 1'b0;
        wready_s_o = 1'b0;
      end
    end

    always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        axready_done <= 1'b0;
        aw_single_done <= 1'b0;
      end else begin
        if (awready_i && awvalid_i && wvalid_s_i && wlast_s_i && !aw_single_done) begin
          aw_single_done <= 1'b1;
        end else if (aw_single_done) begin
          aw_single_done <= 1'b0;
        end


        if (awready_i && awvalid_i && !(wvalid_s_i && wlast_s_i)) begin
          axready_done <= 1'b1;
        end else if ((wvalid_s_i && wready_s_o && wlast_s_i) || single_data_late_aw ) begin
          axready_done <= 1'b0;
        end
      end
    end
  end 
endgenerate
endmodule

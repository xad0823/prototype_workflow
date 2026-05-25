//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017, 2019-2020 Arm Limited or its affiliates.
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
//   Sub-module of css600_atbreplicator
//
//----------------------------------------------------------------------------


module css600_atbreplicator_core# (
    parameter ATB_DATA_WIDTH = 32,
    parameter ATBYTES_WIDTH = 2)
(
  clk,
  reset_n,


  psel,
  penable,
  pwrite,
  paddr,
  pwdata,
  pready,
  pslverr,
  prdata,


  atvalid_s,
  atid_s,

  atbytes_s,
  atdata_s,

  afready_s,
  atready_m,
  afvalid_m,
  syncreq_m,

  atready_s,
  afvalid_s,
  atvalid_m,
  atid_m,

  atbytes_m,
  atdata_m,

  afready_m,
  syncreq_s,
  atwakeup_s,
  atwakeup_m,

  revand

);


  localparam CSR_F_IDLE       = 3'b000;
  localparam CSR_F_REQ_0      = 3'b001;
  localparam CSR_F_REQ_1      = 3'b010;
  localparam CSR_F_REQ_01     = 3'b011;
  localparam CSR_F_REQ_10     = 3'b100;
  localparam CSR_F_REQ_A      = 3'b101;
  localparam CSR_F_REQ_U0     = 3'b110;
  localparam CSR_F_REQ_U1     = 3'b111;
  localparam CSR_F_UNDEF      = 3'bXXX;

  localparam CSR_T_UNDEF      = 2'bXX;
  localparam CSR_T_IDLE       = 2'b00;
  localparam CSR_T_PEND_A     = 2'b01;
  localparam CSR_T_PEND_0     = 2'b10;
  localparam CSR_T_PEND_1     = 2'b11;

  localparam CSR_IDFILTER_0     = 12'h000;
  localparam CSR_IDFILTER_1     = 12'h004;
  localparam CSR_IT_ATB_CTR_0   = 12'hEF8;
  localparam CSR_IT_ATB_CTR_1   = 12'hEFC;
  localparam CSR_IT_CTRL        = 12'hF00;
  localparam CSR_CLAIMSET       = 12'hFA0;
  localparam CSR_CLAIMCLR       = 12'hFA4;
  localparam CSR_AUTHSTATUS     = 12'hFB8;
  localparam CSR_DEVARCH        = 12'hFBC;
  localparam CSR_DEVICEID       = 12'hFC8;
  localparam CSR_DEVICEID1      = 12'hFC4;
  localparam CSR_DEVICEID2      = 12'hFC0;
  localparam CSR_DEVICETYPE     = 12'hFCC;
  localparam CSR_DEVICEAFF0     = 12'hFA8;
  localparam CSR_DEVICEAFF1     = 12'hFAC;
  localparam CSR_PERIPH_ID_4    = 12'hFD0;
  localparam CSR_PERIPH_ID_5    = 12'hFD4;
  localparam CSR_PERIPH_ID_6    = 12'hFD8;
  localparam CSR_PERIPH_ID_7    = 12'hFDC;
  localparam CSR_PERIPH_ID_0    = 12'hFE0;
  localparam CSR_PERIPH_ID_1    = 12'hFE4;
  localparam CSR_PERIPH_ID_2    = 12'hFE8;
  localparam CSR_PERIPH_ID_3    = 12'hFEC;
  localparam CSR_COMP_ID_0      = 12'hFF0;
  localparam CSR_COMP_ID_1      = 12'hFF4;
  localparam CSR_COMP_ID_2      = 12'hFF8;
  localparam CSR_COMP_ID_3      = 12'hFFC;


  localparam CSR_CLAIMSET_VAL           = 4'hF;
  localparam CSR_DEVAFF0_VAL            = 4'h0;
  localparam CSR_DEVAFF1_VAL            = 4'h0;
  localparam CSR_DEVTYPE_VAL            = 8'h22;
  localparam CSR_DEVARCH_VAL            = 8'h00;
  localparam CSR_DEVICEID_VAL           = 8'h32;
  localparam CSR_DEVICEID1_VAL          = 8'h00;
  localparam CSR_DEVICEID2_VAL          = 8'h00;
  localparam CSR_PERIPHID4_VAL          = 8'h04;
  localparam CSR_PERIPHID5_VAL          = 8'h00;
  localparam CSR_PERIPHID6_VAL          = 8'h00;
  localparam CSR_PERIPHID7_VAL          = 8'h00;
  localparam CSR_PERIPHID0_VAL          = 8'hEC;
  localparam CSR_PERIPHID1_VAL          = 8'hB9;
  localparam CSR_PERIPHID2_VAL          = 8'h2B;
  localparam PERIPHID3_CUSTOM           = 4'h0;
  localparam CSR_COMPID0_VAL            = 8'h0D;
  localparam CSR_COMPID1_VAL            = 8'h90;
  localparam CSR_COMPID2_VAL            = 8'h05;
  localparam CSR_COMPID3_VAL            = 8'hB1;

  localparam CSR_AUTHSTATUS_HNID_VAL    = 1'b0;
  localparam CSR_AUTHSTATUS_HID_VAL     = 1'b0;
  localparam CSR_AUTHSTATUS_SNID_VAL    = 1'b0;
  localparam CSR_AUTHSTATUS_SID_VAL     = 1'b0;
  localparam CSR_AUTHSTATUS_NSNID_VAL   = 1'b0;
  localparam CSR_AUTHSTATUS_NSID_VAL    = 1'b0;


  input wire         clk;
  input wire         reset_n;

  input wire         psel;
  input wire         penable;
  input wire         pwrite;
  input wire  [11:0] paddr;
  input wire  [7:0]  pwdata;

  output wire        pready;
  output wire        pslverr;
  output wire [31:0] prdata;

  input wire         atvalid_s;
  input wire   [6:0] atid_s;

  input wire  [ATBYTES_WIDTH:0]         atbytes_s;
  input wire  [ATB_DATA_WIDTH-1:0]  atdata_s;
  input wire         afready_s;
  input wire  [1:0]  atready_m;
  input wire  [1:0]  afvalid_m;
  input wire  [1:0]  syncreq_m;
  output wire        atready_s;
  output wire        afvalid_s;
  output wire [1:0]  atvalid_m;
  output wire [13:0] atid_m;

  output wire [2*ATBYTES_WIDTH+1:0] atbytes_m;
  output wire [2*ATB_DATA_WIDTH-1:0] atdata_m;

  output wire [1:0]  afready_m;
  output reg         syncreq_s;
  input  wire        atwakeup_s;
  output wire [1:0]  atwakeup_m;

  input  wire [3:0]  revand;

  reg         rst_state;
  reg [11:0]  paddrdbg_r;
  wire        apb_setup;
  wire        nxt_apb_valid;
  wire [31:0] read_data;
  reg         apb_valid;
  wire [11:0] apb_addr;
  reg  [7:0]  apb_wdata;
  reg         pseldbg_r;
  reg         pwritedbg_r;
  wire        reg_wr_en;
  wire [3:0]  nxt_claim_tag;
  wire idfilter_0_sel;
  wire idfilter_1_sel;
  wire it_atb_ctr_1_sel;
  wire it_atb_ctr_0_sel;
  wire it_ctrl_sel;
  reg  it_ctrl;
  wire claim_tag_set_sel;
  wire claim_tag_clr_sel;
  wire device_aff0_sel;
  wire device_aff1_sel;
  wire device_arch_sel;
  wire device_id_sel;
  wire device_id1_sel;
  wire device_id2_sel;
  wire device_type_sel;
  wire periph_id_0_sel;
  wire periph_id_1_sel;
  wire periph_id_2_sel;
  wire periph_id_3_sel;
  wire periph_id_4_sel;
  wire periph_id_5_sel;
  wire periph_id_6_sel;
  wire periph_id_7_sel;
  wire comp_id_0_sel;
  wire comp_id_1_sel;
  wire comp_id_2_sel;
  wire comp_id_3_sel;
  wire idfilter_0_wr_en;
  wire idfilter_1_wr_en;
  wire it_ctrl_wr_en;
  wire claim_tag_wr_en;
  wire it_atb_ctr_0_wr_en;
  wire reg_write;
  wire reg_read;
  wire idfilter_0_rd_en;
  wire idfilter_1_rd_en;
  wire it_atb_ctr_1_rd_en;
  wire it_atb_ctr_0_rd_en;
  wire it_ctrl_rd_en;
  wire claim_tag_set_rd_en;
  wire claim_tag_clr_rd_en;
  wire device_aff0_rd_en;
  wire device_aff1_rd_en;
  wire auth_status_rd_en;
  wire device_arch_rd_en;
  wire device_id_rd_en;
  wire device_id1_rd_en;
  wire device_id2_rd_en;
  wire device_type_rd_en;
  wire periph_id_0_rd_en;
  wire periph_id_1_rd_en;
  wire periph_id_2_rd_en;
  wire periph_id_3_rd_en;
  wire periph_id_4_rd_en;
  wire periph_id_5_rd_en;
  wire periph_id_6_rd_en;
  wire periph_id_7_rd_en;
  wire comp_id_0_rd_en;
  wire comp_id_1_rd_en;
  wire comp_id_2_rd_en;
  wire comp_id_3_rd_en;
  wire [2:0] it_atb_ctr_0_wr_data;
  wire [31:0] it_atb_ctr_1_rd_data;
  wire [31:0] it_atb_ctr_0_rd_data;
  wire [31:0] it_ctrl_rd_data;
  wire [31:0] claim_tag_set_rd_data;
  wire [31:0] claim_tag_clr_rd_data;
  wire [31:0] auth_status_rd_data;
  wire [31:0] device_id_rd_data;
  wire [31:0] device_id1_rd_data;
  wire [31:0] device_id2_rd_data;
  wire [31:0] device_type_rd_data;
  wire [31:0] periph_id_0_rd_data;
  wire [31:0] periph_id_1_rd_data;
  wire [31:0] periph_id_2_rd_data;
  wire [31:0] periph_id_4_rd_data;
  wire [31:0] periph_id_3_rd_data;
  wire [31:0] periph_id_5_rd_data;
  wire [31:0] periph_id_6_rd_data;
  wire [31:0] periph_id_7_rd_data;
  wire [31:0] comp_id_0_rd_data;
  wire [31:0] comp_id_1_rd_data;
  wire [31:0] comp_id_2_rd_data;
  wire [31:0] comp_id_3_rd_data;
  wire [31:0] device_aff0_rd_data;
  wire [31:0] device_aff1_rd_data;
  wire [31:0] device_arch_rd_data;
  reg [3:0]  claim_tag;
  reg [7:0]  idfilter_0;
  reg [7:0]  idfilter_1;
  wire discard_master_0;
  wire discard_master_1;
  reg       it_atb_ctr_1_atreadym0_reg;
  reg       it_atb_ctr_1_atreadym1_reg;
  reg       it_atb_ctr_1_atvalids_reg;
  reg       it_atb_ctr_0_atreadys;
  reg       it_atb_ctr_0_atvalidm1;
  reg       it_atb_ctr_0_atvalidm0;
  reg       atwakeup_q;

  wire atreadym0_mod;
  wire atreadym1_mod;
  wire nxt_syncreqs;

  reg [2:0] flush_state;
  reg [2:0] nxt_flush_state;
  reg [1:0] transfer_state;
  reg [1:0] nxt_transfer_state;
  wire      sync_flag_m0_we;
  wire      sync_flag_m1_we;
  reg       sync_req_m0_reg;
  reg       sync_req_m1_reg;
  reg       sync_flag_m0;
  reg       sync_flag_m1;


  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n) begin
      paddrdbg_r        <= {12{1'b0}};
      apb_wdata         <= {8{1'b0}};
    end
    else if (psel) begin
      paddrdbg_r        <= paddr;
      apb_wdata         <= pwdata;
    end
  end

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n) begin
      pwritedbg_r <= 1'b0;
      pseldbg_r  <= 1'b0;
    end
    else begin
      pseldbg_r     <= psel;
      pwritedbg_r   <= pwrite;
    end
  end

  assign prdata[31:0] = (reg_read) ? read_data[31:0] : 32'b0;

  assign apb_setup = (psel & ~penable)
                   | (psel &  penable & ~apb_valid)
                   ;
  assign nxt_apb_valid = apb_setup;

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n)
      apb_valid  <= 1'b0;
    else
      apb_valid  <= nxt_apb_valid;
  end

  assign pready  = apb_valid;
  assign pslverr = 1'b0;

  assign apb_addr = paddrdbg_r & {12{pseldbg_r}};


  assign idfilter_0_sel    = (apb_addr[11:2] == CSR_IDFILTER_0[11:2]);
  assign idfilter_1_sel    = (apb_addr[11:2] == CSR_IDFILTER_1[11:2]);
  assign it_atb_ctr_1_sel  = (apb_addr[11:2] == CSR_IT_ATB_CTR_1[11:2]);
  assign it_atb_ctr_0_sel  = (apb_addr[11:2] == CSR_IT_ATB_CTR_0[11:2]);
  assign it_ctrl_sel       = (apb_addr[11:2] == CSR_IT_CTRL[11:2]);
  assign claim_tag_set_sel = (apb_addr[11:2] == CSR_CLAIMSET[11:2]);
  assign claim_tag_clr_sel = (apb_addr[11:2] == CSR_CLAIMCLR[11:2]);
  assign device_aff0_sel   = (apb_addr[11:2] == CSR_DEVICEAFF0[11:2]);
  assign device_aff1_sel   = (apb_addr[11:2] == CSR_DEVICEAFF1[11:2]);
  assign device_arch_sel   = (apb_addr[11:2] == CSR_DEVARCH[11:2]);
  assign device_id_sel     = (apb_addr[11:2] == CSR_DEVICEID[11:2]);
  assign device_id1_sel    = (apb_addr[11:2] == CSR_DEVICEID1[11:2]);
  assign device_id2_sel    = (apb_addr[11:2] == CSR_DEVICEID2[11:2]);
  assign device_type_sel   = (apb_addr[11:2] == CSR_DEVICETYPE[11:2]);
  assign periph_id_0_sel   = (apb_addr[11:2] == CSR_PERIPH_ID_0[11:2]);
  assign periph_id_1_sel   = (apb_addr[11:2] == CSR_PERIPH_ID_1[11:2]);
  assign periph_id_2_sel   = (apb_addr[11:2] == CSR_PERIPH_ID_2[11:2]);
  assign periph_id_3_sel   = (apb_addr[11:2] == CSR_PERIPH_ID_3[11:2]);
  assign periph_id_4_sel   = (apb_addr[11:2] == CSR_PERIPH_ID_4[11:2]);
  assign periph_id_5_sel   = (apb_addr[11:2] == CSR_PERIPH_ID_5[11:2]);
  assign periph_id_6_sel   = (apb_addr[11:2] == CSR_PERIPH_ID_6[11:2]);
  assign periph_id_7_sel   = (apb_addr[11:2] == CSR_PERIPH_ID_7[11:2]);
  assign comp_id_0_sel     = (apb_addr[11:2] == CSR_COMP_ID_0[11:2]);
  assign comp_id_1_sel     = (apb_addr[11:2] == CSR_COMP_ID_1[11:2]);
  assign comp_id_2_sel     = (apb_addr[11:2] == CSR_COMP_ID_2[11:2]);
  assign comp_id_3_sel     = (apb_addr[11:2] == CSR_COMP_ID_3[11:2]);

  assign reg_write =  pwritedbg_r & apb_valid;
  assign reg_read  = ~pwritedbg_r & apb_valid;
  assign reg_wr_en = reg_write;


  assign idfilter_0_wr_en = reg_wr_en & idfilter_0_sel & ~it_ctrl;
  assign idfilter_1_wr_en = reg_wr_en & idfilter_1_sel & ~it_ctrl;

  always @(posedge clk or negedge reset_n)
  begin : p_idfilter0_seq
      if (!reset_n)
        begin
          idfilter_0 <= 8'b0;
        end
      else if (idfilter_0_wr_en)
        begin
          idfilter_0 <= apb_wdata[7:0];
        end
    end

  always @(posedge clk or negedge reset_n)
  begin : p_idfilter1_seq
      if (!reset_n)
        begin
          idfilter_1 <= 8'b0;
        end
      else if (idfilter_1_wr_en)
        begin
          idfilter_1 <= apb_wdata[7:0];
        end
    end

  assign it_atb_ctr_0_wr_en = reg_wr_en & it_atb_ctr_0_sel;

  assign it_atb_ctr_0_wr_data = {apb_wdata[4], apb_wdata[2], apb_wdata[0]};

  always @(posedge clk or negedge reset_n)
  begin : p_it_ctr0_reg
    if (!reset_n)
      {it_atb_ctr_0_atreadys,
       it_atb_ctr_0_atvalidm1,
       it_atb_ctr_0_atvalidm0} <= 3'd0;
    else if (it_atb_ctr_0_wr_en)
      {it_atb_ctr_0_atreadys,
       it_atb_ctr_0_atvalidm1,
       it_atb_ctr_0_atvalidm0} <= it_atb_ctr_0_wr_data;
  end

  assign it_ctrl_wr_en = reg_wr_en & it_ctrl_sel;

  always @(posedge clk or negedge reset_n)
  begin : p_it_ctrl
    if (!reset_n)
      it_ctrl <= 1'b0;
    else if (it_ctrl_wr_en)
      it_ctrl <= apb_wdata[0];
  end

  assign claim_tag_wr_en = reg_wr_en &
                           (claim_tag_set_sel | claim_tag_clr_sel);

  assign  nxt_claim_tag = claim_tag_set_sel ?
                              (claim_tag | apb_wdata[3:0]):
                              (claim_tag & ~apb_wdata[3:0]);

  always @(posedge clk or negedge reset_n)
  begin : p_claim_tag_wr
    if (!reset_n)
      claim_tag <= {4{1'b0}};
    else if(claim_tag_wr_en)
      claim_tag <=  nxt_claim_tag;
   end

assign idfilter_0_rd_en = reg_read & idfilter_0_sel;

assign idfilter_1_rd_en = reg_read & idfilter_1_sel;

assign it_atb_ctr_1_rd_en = reg_read & it_atb_ctr_1_sel;

assign it_atb_ctr_0_rd_en = reg_read & it_atb_ctr_0_sel;

assign it_ctrl_rd_en = reg_read & it_ctrl_sel;

assign claim_tag_set_rd_en = reg_read & claim_tag_set_sel;

assign claim_tag_clr_rd_en = reg_read & claim_tag_clr_sel;

assign device_aff0_rd_en = reg_read & device_aff0_sel;

assign device_aff1_rd_en = reg_read & device_aff1_sel;

assign auth_status_rd_en = reg_read & (apb_addr[11:2] == CSR_AUTHSTATUS[11:2]);

assign device_arch_rd_en = reg_read & device_arch_sel;

assign device_id_rd_en = reg_read & device_id_sel;

assign device_id1_rd_en = reg_read & device_id1_sel;

assign device_id2_rd_en = reg_read & device_id2_sel;


assign device_type_rd_en = reg_read & device_type_sel;

assign periph_id_0_rd_en = reg_read & periph_id_0_sel;
assign periph_id_1_rd_en = reg_read & periph_id_1_sel;
assign periph_id_2_rd_en = reg_read & periph_id_2_sel;
assign periph_id_3_rd_en = reg_read & periph_id_3_sel;
assign periph_id_4_rd_en = reg_read & periph_id_4_sel;
assign periph_id_5_rd_en = reg_read & periph_id_5_sel;
assign periph_id_6_rd_en = reg_read & periph_id_6_sel;
assign periph_id_7_rd_en = reg_read & periph_id_7_sel;

assign comp_id_0_rd_en = reg_read & comp_id_0_sel;
assign comp_id_1_rd_en = reg_read & comp_id_1_sel;
assign comp_id_2_rd_en = reg_read & comp_id_2_sel;
assign comp_id_3_rd_en = reg_read & comp_id_3_sel;

      always @(posedge clk or negedge reset_n)
      begin : p_it_atbm_ctr1_reg
        if (!reset_n)
          begin
            it_atb_ctr_1_atreadym0_reg <= 1'b0;
            it_atb_ctr_1_atreadym1_reg <= 1'b0;
            it_atb_ctr_1_atvalids_reg  <= 1'b0;
          end
        else
          begin
            it_atb_ctr_1_atreadym0_reg <= atready_m[0];
            it_atb_ctr_1_atreadym1_reg <= atready_m[1];
            it_atb_ctr_1_atvalids_reg  <= atvalid_s;
          end
      end

assign it_atb_ctr_1_rd_data = {{28{1'b0}}, it_atb_ctr_1_atvalids_reg, 1'b0, it_atb_ctr_1_atreadym1_reg, it_atb_ctr_1_atreadym0_reg};

assign it_atb_ctr_0_rd_data = {{27{1'b0}}, it_atb_ctr_0_atreadys, 1'b0, it_atb_ctr_0_atvalidm1, 1'b0, it_atb_ctr_0_atvalidm0};

assign it_ctrl_rd_data = {{31{1'b0}}, it_ctrl};

assign claim_tag_set_rd_data = {{28{1'b0}}, CSR_CLAIMSET_VAL};

assign claim_tag_clr_rd_data = {{28{1'b0}}, claim_tag};

assign device_aff0_rd_data = {{28{1'b0}}, CSR_DEVAFF0_VAL};

assign device_aff1_rd_data = {{28{1'b0}}, CSR_DEVAFF1_VAL};


assign auth_status_rd_data = {{20{1'b0}},
                                 1'b0,CSR_AUTHSTATUS_HNID_VAL,
                                 1'b0,CSR_AUTHSTATUS_HID_VAL,
                                 1'b0,CSR_AUTHSTATUS_SNID_VAL,
                                 1'b0,CSR_AUTHSTATUS_SID_VAL,
                                 1'b0,CSR_AUTHSTATUS_NSNID_VAL,
                                 1'b0,CSR_AUTHSTATUS_NSID_VAL};

assign device_arch_rd_data = {{24{1'b0}}, CSR_DEVARCH_VAL};

assign device_id_rd_data = {{24{1'b0}}, CSR_DEVICEID_VAL};

assign device_id1_rd_data = {{24{1'b0}}, CSR_DEVICEID1_VAL};

assign device_id2_rd_data = {{24{1'b0}}, CSR_DEVICEID2_VAL};

assign device_type_rd_data = {{24{1'b0}}, CSR_DEVTYPE_VAL};

assign periph_id_0_rd_data = {{24{1'b0}}, CSR_PERIPHID0_VAL};
assign periph_id_1_rd_data = {{24{1'b0}}, CSR_PERIPHID1_VAL};
assign periph_id_2_rd_data = {{24{1'b0}}, CSR_PERIPHID2_VAL};
  assign periph_id_3_rd_data[31:0] = {{24{1'b0}},
                                      revand,
                                      PERIPHID3_CUSTOM[3:0]
                                      };

assign periph_id_4_rd_data = {{24{1'b0}}, CSR_PERIPHID4_VAL};
assign periph_id_5_rd_data = {{24{1'b0}}, CSR_PERIPHID5_VAL};
assign periph_id_6_rd_data = {{24{1'b0}}, CSR_PERIPHID6_VAL};
assign periph_id_7_rd_data = {{24{1'b0}}, CSR_PERIPHID7_VAL};

assign comp_id_0_rd_data = {{24{1'b0}}, CSR_COMPID0_VAL};
assign comp_id_1_rd_data = {{24{1'b0}}, CSR_COMPID1_VAL};
assign comp_id_2_rd_data = {{24{1'b0}}, CSR_COMPID2_VAL};
assign comp_id_3_rd_data = {{24{1'b0}}, CSR_COMPID3_VAL};


  assign read_data   = (
                        ({32{idfilter_0_rd_en}}   & {24'b0, idfilter_0}) |
                        ({32{idfilter_1_rd_en}}   & {24'b0, idfilter_1}) |
                        ({32{it_atb_ctr_1_rd_en}} & it_atb_ctr_1_rd_data) |
                        ({32{it_atb_ctr_0_rd_en}} & it_atb_ctr_0_rd_data) |
                        ({32{it_ctrl_rd_en}}      & it_ctrl_rd_data) |
                        ({32{claim_tag_set_rd_en}}& claim_tag_set_rd_data) |
                        ({32{claim_tag_clr_rd_en}}& claim_tag_clr_rd_data) |
                        ({32{device_aff0_rd_en}}  & device_aff0_rd_data) |
                        ({32{device_aff1_rd_en}}  & device_aff1_rd_data) |
                        ({32{auth_status_rd_en}}  & auth_status_rd_data)   |
                        ({32{device_arch_rd_en}}  & device_arch_rd_data) |
                        ({32{device_id_rd_en}}    & device_id_rd_data) |
                        ({32{device_id1_rd_en}}   & device_id1_rd_data) |
                        ({32{device_id2_rd_en}}   & device_id2_rd_data) |
                        ({32{device_type_rd_en}}  & device_type_rd_data) |
                        ({32{periph_id_0_rd_en}}  & periph_id_0_rd_data) |
                        ({32{periph_id_1_rd_en}}  & periph_id_1_rd_data) |
                        ({32{periph_id_2_rd_en}}  & periph_id_2_rd_data) |
                        ({32{periph_id_3_rd_en}}  & periph_id_3_rd_data) |
                        ({32{periph_id_4_rd_en}}  & periph_id_4_rd_data) |
                        ({32{periph_id_5_rd_en}}  & periph_id_5_rd_data) |
                        ({32{periph_id_6_rd_en}}  & periph_id_6_rd_data) |
                        ({32{periph_id_7_rd_en}}  & periph_id_7_rd_data) |
                        ({32{comp_id_0_rd_en}}    & comp_id_0_rd_data) |
                        ({32{comp_id_1_rd_en}}    & comp_id_1_rd_data) |
                        ({32{comp_id_2_rd_en}}    & comp_id_2_rd_data) |
                        ({32{comp_id_3_rd_en}}    & comp_id_3_rd_data)
                       );

  assign atid_m[6:0]                                          = atid_s;
  assign atid_m[13:7]                                         = atid_s;
  assign atbytes_m[ATBYTES_WIDTH:0]                           = atbytes_s;
  assign atbytes_m[2*ATBYTES_WIDTH+1:ATBYTES_WIDTH+1]         = atbytes_s;
  assign atdata_m[ATB_DATA_WIDTH-1:0]                     = atdata_s;
  assign atdata_m[2*ATB_DATA_WIDTH-1:ATB_DATA_WIDTH]  = atdata_s;

  assign discard_master_0 = idfilter_0[0] & (atid_s < 7'h10) |
                            idfilter_0[1] & ((atid_s < 7'h20) && (atid_s >= 7'h10)) |
                            idfilter_0[2] & ((atid_s < 7'h30) && (atid_s >= 7'h20)) |
                            idfilter_0[3] & ((atid_s < 7'h40) && (atid_s >= 7'h30)) |
                            idfilter_0[4] & ((atid_s < 7'h50) && (atid_s >= 7'h40)) |
                            idfilter_0[5] & ((atid_s < 7'h60) && (atid_s >= 7'h50)) |
                            idfilter_0[6] & ((atid_s < 7'h70) && (atid_s >= 7'h60)) |
                            idfilter_0[7] & (atid_s >= 7'h70);

  assign atreadym0_mod = discard_master_0 | atready_m[0];

  assign discard_master_1 = idfilter_1[0] & (atid_s < 7'h10) |
                            idfilter_1[1] & ((atid_s < 7'h20) && (atid_s >= 7'h10)) |
                            idfilter_1[2] & ((atid_s < 7'h30) && (atid_s >= 7'h20)) |
                            idfilter_1[3] & ((atid_s < 7'h40) && (atid_s >= 7'h30)) |
                            idfilter_1[4] & ((atid_s < 7'h50) && (atid_s >= 7'h40)) |
                            idfilter_1[5] & ((atid_s < 7'h60) && (atid_s >= 7'h50)) |
                            idfilter_1[6] & ((atid_s < 7'h70) && (atid_s >= 7'h60)) |
                            idfilter_1[7] & (atid_s >= 7'h70);

  assign atreadym1_mod = discard_master_1 | atready_m[1];


  always @(posedge clk or negedge reset_n)
  begin : atwakeup_flop
    if (!reset_n)
      atwakeup_q <= 1'b0;
    else
      atwakeup_q <= atwakeup_s;
  end

  assign atwakeup_m = {atwakeup_q, atwakeup_q};


  always @ *
  begin : p_transfer_fsm_comb
    case (transfer_state)
      CSR_T_IDLE :
        if (atvalid_s)
          begin
            case ({atreadym0_mod,atreadym1_mod})
              2'b00 : nxt_transfer_state = CSR_T_PEND_A;
              2'b01 : nxt_transfer_state = CSR_T_PEND_0;
              2'b10 : nxt_transfer_state = CSR_T_PEND_1;
              2'b11 : nxt_transfer_state = CSR_T_IDLE;
              default : nxt_transfer_state = CSR_T_UNDEF;
            endcase
          end
        else nxt_transfer_state = CSR_T_IDLE;
      CSR_T_PEND_0 :
        nxt_transfer_state = atready_m[0] ? CSR_T_IDLE : CSR_T_PEND_0;
      CSR_T_PEND_1 :
        nxt_transfer_state = atready_m[1] ? CSR_T_IDLE : CSR_T_PEND_1;
      CSR_T_PEND_A :
        case ({atready_m[0],atready_m[1]})
          2'b00 : nxt_transfer_state = CSR_T_PEND_A;
          2'b01 : nxt_transfer_state = CSR_T_PEND_0;
          2'b10 : nxt_transfer_state = CSR_T_PEND_1;
          2'b11 : nxt_transfer_state = CSR_T_IDLE;
          default : nxt_transfer_state = CSR_T_UNDEF;
        endcase
      default : nxt_transfer_state = CSR_T_UNDEF;
    endcase
  end

  always @(posedge clk or negedge reset_n)
  begin : p_transfer_fsm_seq
    if (!reset_n)
      transfer_state <= CSR_T_IDLE;
    else
      transfer_state <= nxt_transfer_state;
  end


  assign atready_s = (it_ctrl ? it_atb_ctr_0_atreadys : (nxt_transfer_state == CSR_T_IDLE)) & ~rst_state;


  assign atvalid_m[0] = it_ctrl ? it_atb_ctr_0_atvalidm0 :
                      atvalid_s &
                       ((transfer_state == CSR_T_PEND_0) |
                        (transfer_state == CSR_T_PEND_A) |
                        (transfer_state == CSR_T_IDLE) & ~discard_master_0);


  assign atvalid_m[1] = it_ctrl ? it_atb_ctr_0_atvalidm1 :
                      atvalid_s &
                       ((transfer_state == CSR_T_PEND_1) |
                        (transfer_state == CSR_T_PEND_A) |
                        (transfer_state == CSR_T_IDLE) & ~discard_master_1);


  always @ *
  begin : p_flush_fsm_comb
    case (flush_state)
      CSR_F_IDLE :
        case ({afvalid_m[0],afvalid_m[1]})
          2'b00 : nxt_flush_state = CSR_F_IDLE;
          2'b01 : nxt_flush_state = CSR_F_REQ_1;
          2'b10 : nxt_flush_state = CSR_F_REQ_0;
          2'b11 : nxt_flush_state = CSR_F_REQ_A;
          default : nxt_flush_state = CSR_F_UNDEF;
        endcase
      CSR_F_REQ_0 :
        case ({afready_s,afvalid_m[1]})
          2'b00 : nxt_flush_state = CSR_F_REQ_0;
          2'b01 : nxt_flush_state = CSR_F_REQ_01;
          2'b10 : nxt_flush_state = CSR_F_IDLE;
          2'b11 : nxt_flush_state = CSR_F_REQ_1;
          default : nxt_flush_state = CSR_F_UNDEF;
        endcase
      CSR_F_REQ_1 :
        case ({afready_s,afvalid_m[0]})
          2'b00 : nxt_flush_state = CSR_F_REQ_1;
          2'b01 : nxt_flush_state = CSR_F_REQ_10;
          2'b10 : nxt_flush_state = CSR_F_IDLE;
          2'b11 : nxt_flush_state = CSR_F_REQ_0;
          default : nxt_flush_state = CSR_F_UNDEF;
        endcase
      CSR_F_REQ_01 : nxt_flush_state = afready_s ? CSR_F_REQ_1 : CSR_F_REQ_01;
      CSR_F_REQ_10 : nxt_flush_state = afready_s ? CSR_F_REQ_0 : CSR_F_REQ_10;
      CSR_F_REQ_A : nxt_flush_state = afready_s ? CSR_F_IDLE : CSR_F_REQ_A;
      default : nxt_flush_state = CSR_F_UNDEF;
    endcase
  end


  always @(posedge clk or negedge reset_n)
  begin : p_flush_fsm_seq
    if (!reset_n)
      flush_state <= CSR_F_IDLE;
    else
      flush_state <= nxt_flush_state;
  end

  assign afvalid_s = (flush_state != CSR_F_IDLE);


  always @(posedge clk or negedge reset_n)
  begin : p_rst_state
    if (!reset_n)
      rst_state <= 1'b1;
    else
      rst_state <= 1'b0;
  end

  assign afready_m[0] = rst_state |
                     (
                      (flush_state == CSR_F_REQ_0)  |
                      (flush_state == CSR_F_REQ_01) |
                      (flush_state == CSR_F_REQ_A)
                     ) & afready_s;

  assign afready_m[1] = rst_state |
                     (
                      (flush_state == CSR_F_REQ_1)  |
                      (flush_state == CSR_F_REQ_10) |
                      (flush_state == CSR_F_REQ_A)
                     ) & afready_s;


  always @(posedge clk or negedge reset_n)
  begin : p_sync_req_seq
    if (!reset_n)
      begin
        sync_req_m0_reg <= 1'b0;
        sync_req_m1_reg <= 1'b0;
      end
    else
      begin
        sync_req_m0_reg <= syncreq_m[0];
        sync_req_m1_reg <= syncreq_m[1];
      end
  end

  assign sync_flag_m0_we  = sync_req_m0_reg |
                            (sync_req_m1_reg & sync_flag_m1);


  assign sync_flag_m1_we  = sync_req_m1_reg |
                            (sync_req_m0_reg & sync_flag_m0);

  always @(posedge clk or negedge reset_n)
  begin : p_sync_flag_m0_seq
    if (!reset_n)
      begin
        sync_flag_m0 <= 1'b1;
      end
    else if (sync_flag_m0_we)
      begin
        sync_flag_m0 <= sync_req_m0_reg;
      end
  end

  always @(posedge clk or negedge reset_n)
  begin : p_sync_flag_m1_seq
    if (!reset_n)
      begin
        sync_flag_m1 <= 1'b1;
      end
    else if (sync_flag_m1_we)
      begin
        sync_flag_m1 <= sync_req_m1_reg;
      end
  end

  assign nxt_syncreqs = ((sync_req_m0_reg & sync_flag_m0) |
                         (sync_req_m1_reg & sync_flag_m1));


  always @(posedge clk or negedge reset_n)
  begin : p_syncreqs
    if (!reset_n)
      syncreq_s <= 1'b0;
    else
      syncreq_s <= nxt_syncreqs;
  end

endmodule

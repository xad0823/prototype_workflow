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




`ifndef INT_RTR_PARAMS
`include "interrupt_router_f0_params.v"
`endif

`ifndef INT_RTR_UNIT_PARAMS
`include "interrupt_router_f0_unit_params.v"
`endif

module interrupt_router_f0_reg_bank
#(

  parameter NUM_SHD_INT = 416,
  parameter LDE_LVL     = 2,
  parameter NUM_ICI     = 4,
  parameter MASTER_ID_WIDTH = 8,
  parameter SECURE_MASTER_ID = 0,

  parameter INT_RTR_CTRL   = 12'h000,
  parameter LD_CTRL        = 12'h010,
  parameter SHD_INT_CFG    = 12'h104,
  parameter SHD_INT_LCTRL  = 12'h108,
  parameter SHD_INT_SEL    = 12'h10C,
  parameter INT_RTR_TMP_ST = 12'hE90,

  parameter SHD_INT_INFO  = 12'h100,
  parameter INT_RTR_CAP   = 12'hFA0,
  parameter INT_RTR_CFG   = 12'hFB0,

  parameter PID0 = 12'hFE0,
  parameter PID1 = 12'hFE4,
  parameter PID2 = 12'hFE8,
  parameter PID3 = 12'hFEC,
  parameter PID4 = 12'hFD0,
  parameter PID5 = 12'hFD4,
  parameter PID6 = 12'hFD8,
  parameter PID7 = 12'hFDC,

  parameter ID0 = 12'hFF0,
  parameter ID1 = 12'hFF4,
  parameter ID2 = 12'hFF8,
  parameter ID3 = 12'hFFC
)

(
  `SI_DEF_ICI_EN_inputs
  `SI_DEF_ICI_DST_inputs

  input  wire               pclk,
  input  wire               presetn,

  input  wire                    psel_i,
  input  wire                    penable_i,
  input  wire [2:0]              pprot_i,
  input  wire [3:0]              pstrb_i,
  input  wire [11:0]             paddr_i,
  input  wire                    pwrite_i,
  input  wire [31:0]             pwdata_i,
  output wire [31:0]             prdata_o,
  output wire                    pready_o,
  output wire                    pslverr_o,
  input  wire                    lock_i,
  input  wire                    tamper_i,

  input  wire [MASTER_ID_WIDTH-1:0] master_id_i,

  output wire [11:0]             paddr_r_o,
  output wire [MASTER_ID_WIDTH-1:0] master_id_r_o,
  output wire [1:0]              pprot_r_o,
  output wire [1:0]              ld_ctrl_lock_o,
  output wire                    shd_int_lctrl_lock_o,

  output wire                    int_rtr_tmp_st_vld_o,
  output wire                    int_rtr_tmp_st_ovrflw_o,

  output wire [NUM_SHD_INT-1:0]  shd_int_cfg_ici0_en_o,
  output wire [NUM_SHD_INT-1:0]  shd_int_cfg_ici1_en_o,
  output wire [NUM_SHD_INT-1:0]  shd_int_cfg_ici2_en_o,
  output wire [NUM_SHD_INT-1:0]  shd_int_cfg_ici3_en_o,

  output wire                    prdata_en_o,
  output wire                    global_write_en_o

);




localparam THIRTY_TWO_MINUS_NUM_ICI = 32-NUM_ICI;



localparam SM_IDLE = 2'b00;
localparam SM_SETUP = 2'b01;
localparam SM_ACCESS = 2'b10;


localparam PID4_SIZE_DES_2           = 8'h04;
localparam PID0_PART_0               = 8'h74;
localparam PID1_DES_0_PART_1         = 8'hB0;
localparam PID2_JEDEC_DES_1          = 4'hB;
localparam PID3_CMOD                 = 4'h0;

wire [3:0] pid2_revision_eco;
wire [3:0] pid3_revand_eco;

localparam CID0_PRMBL_0              = 8'h0D;
localparam CID1_CLASS_PRMBL_1        = 8'hF0;
localparam CID2_PRMBL_2              = 8'h05;
localparam CID3_PRMBL_3              = 8'hB1;


localparam INT_SEL_WIDTH             = 5'h10; 


  reg                     int_rtr_ctrl_err_rw_r;

  reg                     ld_ctrl_ldi_st_ro_r;
  reg [1:0]               ld_ctrl_lock_rw_r;


  reg [NUM_ICI-1:0]              shd_int_cfg_ici_en_rw_r [NUM_SHD_INT-1:0];

  reg [NUM_SHD_INT-1:0]      shd_int_lctrl_lock_rw_r;

  reg [INT_SEL_WIDTH-1:0]              shd_int_sel_int_sel_rw_r;

  reg                     int_rtr_tmp_st_vld_rw_r;
  reg                     int_rtr_tmp_st_ovrflw_rw_r;
  reg [9:0]               int_rtr_tmp_st_trans_addr_ro_r;




  reg  [7:0]              cid0; 
  reg  [7:0]              cid1; 
  reg  [7:0]              cid2; 
  reg  [7:0]              cid3; 

  genvar I;

  wire  [31:0]            global_read_data;

  reg [MASTER_ID_WIDTH-1:0] master_id_r;

  reg [11:0]              paddr_r;
  reg                     pwrite_r;
  reg [31:0]              pwdata_r;
  reg [2:0]               pprot_r;
  reg [3:0]               pstrb_r;

  reg [1:0]               state;
  reg [1:0]               nxt_state;
  reg [11:0]              nxt_paddr;
  reg                     nxt_pwrite;
  reg [31:0]              nxt_pwdata;
  reg [2:0]               nxt_pprot;
  reg [3:0]               nxt_pstrb;

  reg [MASTER_ID_WIDTH-1:0] master_id_nxt;
  reg                     prdata_en;
  reg                     global_write_en;
  wire                    pslverr_int;

  wire                    unused;

always @(posedge pclk or negedge presetn)
begin
  if (!presetn)
  begin
    state     <= SM_IDLE;

    paddr_r   <= 12'h000;
    pwrite_r  <= 1'b0;
    pwdata_r  <= 32'h0000_0000;
    pprot_r   <= 3'b001;
    pstrb_r   <= 4'b1111;

    master_id_r <= {MASTER_ID_WIDTH{1'b0}};
  end
  else
  begin
    state     <= nxt_state;

    paddr_r   <= nxt_paddr;
    pwrite_r  <= nxt_pwrite;
    pwdata_r  <= nxt_pwdata;
    pprot_r   <= nxt_pprot;
    pstrb_r   <= nxt_pstrb;

    master_id_r <= master_id_nxt;
  end
end


always @*
begin
  case (state[1:0])
  SM_IDLE:
  begin
    nxt_state  = (psel_i & ~penable_i) ? SM_SETUP : SM_IDLE;

    nxt_paddr  = (psel_i & ~penable_i) ? paddr_i : 12'h000;
    nxt_pwrite = (psel_i & ~penable_i) ? pwrite_i : 1'b0;
    nxt_pwdata = (psel_i & ~penable_i & pwrite_i) ? pwdata_i : 32'h0000_0000;
    nxt_pprot  = (psel_i & ~penable_i) ? pprot_i : 3'b001;
    nxt_pstrb  = (psel_i & ~penable_i) ? pstrb_i : 4'b1111;
    prdata_en  = 1'b0;
    global_write_en = 1'b0;
    master_id_nxt = (psel_i & ~penable_i) ? master_id_i : {MASTER_ID_WIDTH{1'b0}};
  end
  SM_SETUP:
  begin
    nxt_state = SM_ACCESS;

    nxt_paddr  = paddr_i;
    nxt_pwrite = pwrite_i;
    nxt_pwdata = pwrite_i ? pwdata_i : 32'h0000_0000;
    nxt_pprot  = pprot_i;
    nxt_pstrb  = pstrb_i;
    prdata_en  = ~pwrite_r;
    global_write_en = pwrite_r;
    master_id_nxt = master_id_r;
  end
  SM_ACCESS:
  begin
    nxt_state  = psel_i ? SM_SETUP : SM_IDLE;

    nxt_paddr  = psel_i ? paddr_i : 12'h000;
    nxt_pwrite = psel_i ? pwrite_i : 1'b0;
    nxt_pwdata = (psel_i & pwrite_i) ? pwdata_i : 32'h0000_0000;
    nxt_pprot  = psel_i ? pprot_i : 3'b001;
    nxt_pstrb  = psel_i ? pstrb_i : 4'b1111;
    prdata_en  = 1'b0;
    global_write_en = 1'b0;
    master_id_nxt = psel_i ? master_id_i : {MASTER_ID_WIDTH{1'b0}};
  end

  default:
  begin
    nxt_state  = 2'bxx;

    nxt_paddr  = 12'hxxx;
    nxt_pwrite = 1'bx;
    nxt_pwdata = 32'hxxxx_xxxx;
    nxt_pprot  = 3'bxxx;
    nxt_pstrb  = 4'bxxxx;
    prdata_en  = 1'bx;
    global_write_en = 1'bx;
    master_id_nxt = {MASTER_ID_WIDTH{1'bx}};
  end
  endcase
end


  wire                    ld_ctrl_read_en;
  wire                    int_rtr_ctrl_read_en;
  wire                    shd_int_info_read_en;
  wire                    shd_int_cfg_read_en;
  wire                    shd_int_lctrl_read_en;
  wire                    shd_int_sel_read_en;
  wire                    int_rtr_tmp_st_read_en;
  wire                    int_rtr_cap_read_en;
  wire                    int_rtr_cfg_read_en;
  wire                    pid0_read_en;
  wire                    pid1_read_en;
  wire                    pid2_read_en;
  wire                    pid3_read_en;
  wire                    pid4_read_en;
  wire                    pid5_read_en;
  wire                    pid6_read_en;
  wire                    pid7_read_en;
  wire                    cid0_read_en;
  wire                    cid1_read_en;
  wire                    cid2_read_en;
  wire                    cid3_read_en;

  assign int_rtr_ctrl_read_en = (paddr_r == INT_RTR_CTRL) & prdata_en;
  assign ld_ctrl_read_en = (paddr_r == LD_CTRL) & prdata_en;
  assign shd_int_info_read_en = (paddr_r == SHD_INT_INFO) & prdata_en;
  assign shd_int_cfg_read_en = (paddr_r == SHD_INT_CFG) & prdata_en;
  assign shd_int_lctrl_read_en = (paddr_r == SHD_INT_LCTRL) & prdata_en;
  assign shd_int_sel_read_en = (paddr_r == SHD_INT_SEL) & prdata_en;
  assign int_rtr_tmp_st_read_en = ((paddr_r == INT_RTR_TMP_ST) & (master_id_r == SECURE_MASTER_ID[MASTER_ID_WIDTH-1:0]) & (pprot_r[1:0] == 2'b01)) & prdata_en;
  assign int_rtr_cap_read_en = (paddr_r == INT_RTR_CAP) & prdata_en;
  assign int_rtr_cfg_read_en = (paddr_r == INT_RTR_CFG) & prdata_en;
  assign pid0_read_en = (paddr_r == PID0) & prdata_en;
  assign pid1_read_en = (paddr_r == PID1) & prdata_en;
  assign pid2_read_en = (paddr_r == PID2) & prdata_en;
  assign pid3_read_en = (paddr_r == PID3) & prdata_en;
  assign pid4_read_en = (paddr_r == PID4) & prdata_en;
  assign pid5_read_en = (paddr_r == PID5) & prdata_en;
  assign pid6_read_en = (paddr_r == PID6) & prdata_en;
  assign pid7_read_en = (paddr_r == PID7) & prdata_en;
  assign cid0_read_en = (paddr_r == ID0) & prdata_en;
  assign cid1_read_en = (paddr_r == ID1) & prdata_en;
  assign cid2_read_en = (paddr_r == ID2) & prdata_en;
  assign cid3_read_en = (paddr_r == ID3) & prdata_en;


  reg   ld_ctrl_write_en;
  reg   shd_int_cfg_write_en;
  reg   shd_int_lctrl_write_en;
  reg   shd_int_sel_write_en;
  reg   int_rtr_tmp_st_write_en;
  reg   int_rtr_ctrl_write_en;


  always @*
  begin
    if (paddr_r == LD_CTRL)
    begin
      if ((LDE_LVL >= 1) & (lock_i) & (ld_ctrl_lock_rw_r > 2'b01))
      begin
        ld_ctrl_write_en = 1'b0;
      end
      else
      begin
        ld_ctrl_write_en = global_write_en;
      end
    end
    else
    begin
      ld_ctrl_write_en = 1'b0;
    end
  end

  always @*
  begin
    if (paddr_r == SHD_INT_CFG)
    begin
      if (LDE_LVL == 2)
      begin
        if (ld_ctrl_lock_rw_r == 2'b11)
        begin
          shd_int_cfg_write_en = 1'b0;
        end
        else
        begin
          if (shd_int_sel_int_sel_rw_r[((NUM_SHD_INT > 1) ? $clog2(NUM_SHD_INT)-1 : 0):0] >= NUM_SHD_INT)
          begin
            shd_int_cfg_write_en = 1'b0;
          end
          else if (shd_int_lctrl_lock_rw_r[shd_int_sel_int_sel_rw_r[((NUM_SHD_INT > 1) ? $clog2(NUM_SHD_INT)-1 : 0):0]])
          begin
            shd_int_cfg_write_en = 1'b0;
          end
          else
          begin
            shd_int_cfg_write_en = global_write_en;
          end
        end
      end
      else if (LDE_LVL == 1)
      begin
        if (ld_ctrl_lock_rw_r == 2'b11)
        begin
          shd_int_cfg_write_en = 1'b0;
        end
        else
        begin
          shd_int_cfg_write_en = global_write_en;
        end
      end
      else
      begin
        shd_int_cfg_write_en = global_write_en;
      end
    end
    else
    begin
      shd_int_cfg_write_en = 1'b0;
    end
  end

  always @*
  begin
    if (paddr_r == SHD_INT_LCTRL)
    begin
      if (LDE_LVL == 2)
      begin
        if (ld_ctrl_lock_rw_r == 2'b11)
        begin
          shd_int_lctrl_write_en = 1'b0;
        end
        else if (ld_ctrl_lock_rw_r == 2'b10)
        begin
          if (shd_int_sel_int_sel_rw_r[((NUM_SHD_INT > 1) ? $clog2(NUM_SHD_INT)-1 : 0):0] >= NUM_SHD_INT)
          begin
            shd_int_lctrl_write_en = 1'b0;
          end
          else if (shd_int_lctrl_lock_rw_r[shd_int_sel_int_sel_rw_r[((NUM_SHD_INT > 1) ? $clog2(NUM_SHD_INT)-1 : 0):0]])
          begin
            shd_int_lctrl_write_en = 1'b0;
          end
          else
          begin
            shd_int_lctrl_write_en = global_write_en;
          end
        end
        else
        begin
          shd_int_lctrl_write_en = global_write_en;
        end
      end
      else
      begin
        shd_int_lctrl_write_en = 1'b0;
      end
    end
    else
    begin
      shd_int_lctrl_write_en = 1'b0;
    end
  end

  always @*
  begin
    if (paddr_r == SHD_INT_SEL)
    begin
      shd_int_sel_write_en = global_write_en;
    end
    else
    begin
      shd_int_sel_write_en = 1'b0;
    end
  end

  always @*
  begin
    if ((paddr_r == INT_RTR_TMP_ST) & ((master_id_r == SECURE_MASTER_ID[MASTER_ID_WIDTH-1:0]) & pprot_r[1:0] == 2'b01))
    begin
      int_rtr_tmp_st_write_en = global_write_en;
    end
    else
    begin
      int_rtr_tmp_st_write_en = 1'b0;
    end
  end

  always @*
  begin
    if (paddr_r == INT_RTR_CTRL)
    begin
      int_rtr_ctrl_write_en = global_write_en;
    end
    else
    begin
      int_rtr_ctrl_write_en = 1'b0;
    end
  end


  wire  [31:0]            int_rtr_ctrl_read_data;
  wire  [31:0]            ld_ctrl_read_data;
  wire  [31:0]            shd_int_info_read_data;
  wire  [31:0]            shd_int_cfg_read_data;
  wire  [31:0]            shd_int_lctrl_read_data;
  wire  [31:0]            shd_int_sel_read_data;
  wire  [31:0]            int_rtr_tmp_st_read_data;
  wire  [31:0]            int_rtr_cap_read_data;
  wire  [31:0]            int_rtr_cfg_read_data;
  wire  [31:0]            pid0_read_data;
  wire  [31:0]            pid1_read_data;
  wire  [31:0]            pid2_read_data;
  wire  [31:0]            pid3_read_data;
  wire  [31:0]            pid4_read_data;
  wire  [31:0]            pid5_read_data;
  wire  [31:0]            pid6_read_data;
  wire  [31:0]            pid7_read_data;
  wire  [31:0]            cid0_read_data;
  wire  [31:0]            cid1_read_data;
  wire  [31:0]            cid2_read_data;
  wire  [31:0]            cid3_read_data;

 assign global_read_data = ( ({32{int_rtr_ctrl_read_en  }} & int_rtr_ctrl_read_data  )
                           | ({32{ld_ctrl_read_en       }} & ld_ctrl_read_data       )
                           | ({32{shd_int_info_read_en  }} & shd_int_info_read_data  )
                           | ({32{shd_int_cfg_read_en   }} & shd_int_cfg_read_data   )
                           | ({32{shd_int_lctrl_read_en }} & shd_int_lctrl_read_data )
                           | ({32{shd_int_sel_read_en   }} & shd_int_sel_read_data   )
                           | ({32{int_rtr_tmp_st_read_en}} & int_rtr_tmp_st_read_data)
                           | ({32{int_rtr_cap_read_en   }} & int_rtr_cap_read_data   )
                           | ({32{int_rtr_cfg_read_en   }} & int_rtr_cfg_read_data   )
                           | ({32{pid0_read_en          }} & pid0_read_data          )
                           | ({32{pid1_read_en          }} & pid1_read_data          )
                           | ({32{pid2_read_en          }} & pid2_read_data          )
                           | ({32{pid3_read_en          }} & pid3_read_data          )
                           | ({32{pid4_read_en          }} & pid4_read_data          )
                           | ({32{pid5_read_en          }} & pid5_read_data          )
                           | ({32{pid6_read_en          }} & pid6_read_data          )
                           | ({32{pid7_read_en          }} & pid7_read_data          )
                           | ({32{cid0_read_en          }} & cid0_read_data          )
                           | ({32{cid1_read_en          }} & cid1_read_data          )
                           | ({32{cid2_read_en          }} & cid2_read_data          )
                           | ({32{cid3_read_en          }} & cid3_read_data          )
                           );


  assign int_rtr_ctrl_read_data   = {31'h0000_0000, int_rtr_ctrl_err_rw_r};


  assign ld_ctrl_read_data        = {28'h000_0000, 1'b0, ld_ctrl_ldi_st_ro_r, ld_ctrl_lock_rw_r };


  assign shd_int_sel_read_data    = {{(32-INT_SEL_WIDTH){1'b0}}, shd_int_sel_int_sel_rw_r};


  assign int_rtr_tmp_st_read_data = {int_rtr_tmp_st_vld_rw_r, int_rtr_tmp_st_ovrflw_rw_r, 16'h0000, 2'b00, int_rtr_tmp_st_trans_addr_ro_r, 2'b00};


  assign int_rtr_cap_read_data    = {28'h000_0000, LDE_LVL[3:0]};

localparam NUM_ICI_MINUS_1 = NUM_ICI - 1;
localparam NUM_SHD_INT_MINUS_1 = NUM_SHD_INT - 1;

  assign int_rtr_cfg_read_data    = {12'h000, NUM_ICI_MINUS_1[3:0], NUM_SHD_INT_MINUS_1[15:0]};

  wire [NUM_ICI-1:0] si_ici_dst_wire [NUM_SHD_INT-1:0];

  assign si_ici_dst_wire[0] = SI0_ICI_DST;
  assign si_ici_dst_wire[1] = SI1_ICI_DST;
  assign si_ici_dst_wire[2] = SI2_ICI_DST;
  assign si_ici_dst_wire[3] = SI3_ICI_DST;
  assign si_ici_dst_wire[4] = SI4_ICI_DST;
  assign si_ici_dst_wire[5] = SI5_ICI_DST;
  assign si_ici_dst_wire[6] = SI6_ICI_DST;
  assign si_ici_dst_wire[7] = SI7_ICI_DST;
  assign si_ici_dst_wire[8] = SI8_ICI_DST;
  assign si_ici_dst_wire[9] = SI9_ICI_DST;
  assign si_ici_dst_wire[10] = SI10_ICI_DST;
  assign si_ici_dst_wire[11] = SI11_ICI_DST;
  assign si_ici_dst_wire[12] = SI12_ICI_DST;
  assign si_ici_dst_wire[13] = SI13_ICI_DST;
  assign si_ici_dst_wire[14] = SI14_ICI_DST;
  assign si_ici_dst_wire[15] = SI15_ICI_DST;
  assign si_ici_dst_wire[16] = SI16_ICI_DST;
  assign si_ici_dst_wire[17] = SI17_ICI_DST;
  assign si_ici_dst_wire[18] = SI18_ICI_DST;
  assign si_ici_dst_wire[19] = SI19_ICI_DST;
  assign si_ici_dst_wire[20] = SI20_ICI_DST;
  assign si_ici_dst_wire[21] = SI21_ICI_DST;
  assign si_ici_dst_wire[22] = SI22_ICI_DST;
  assign si_ici_dst_wire[23] = SI23_ICI_DST;
  assign si_ici_dst_wire[24] = SI24_ICI_DST;
  assign si_ici_dst_wire[25] = SI25_ICI_DST;
  assign si_ici_dst_wire[26] = SI26_ICI_DST;
  assign si_ici_dst_wire[27] = SI27_ICI_DST;
  assign si_ici_dst_wire[28] = SI28_ICI_DST;
  assign si_ici_dst_wire[29] = SI29_ICI_DST;
  assign si_ici_dst_wire[30] = SI30_ICI_DST;
  assign si_ici_dst_wire[31] = SI31_ICI_DST;
  assign si_ici_dst_wire[32] = SI32_ICI_DST;
  assign si_ici_dst_wire[33] = SI33_ICI_DST;
  assign si_ici_dst_wire[34] = SI34_ICI_DST;
  assign si_ici_dst_wire[35] = SI35_ICI_DST;
  assign si_ici_dst_wire[36] = SI36_ICI_DST;
  assign si_ici_dst_wire[37] = SI37_ICI_DST;
  assign si_ici_dst_wire[38] = SI38_ICI_DST;
  assign si_ici_dst_wire[39] = SI39_ICI_DST;
  assign si_ici_dst_wire[40] = SI40_ICI_DST;
  assign si_ici_dst_wire[41] = SI41_ICI_DST;
  assign si_ici_dst_wire[42] = SI42_ICI_DST;
  assign si_ici_dst_wire[43] = SI43_ICI_DST;
  assign si_ici_dst_wire[44] = SI44_ICI_DST;
  assign si_ici_dst_wire[45] = SI45_ICI_DST;
  assign si_ici_dst_wire[46] = SI46_ICI_DST;
  assign si_ici_dst_wire[47] = SI47_ICI_DST;
  assign si_ici_dst_wire[48] = SI48_ICI_DST;
  assign si_ici_dst_wire[49] = SI49_ICI_DST;
  assign si_ici_dst_wire[50] = SI50_ICI_DST;
  assign si_ici_dst_wire[51] = SI51_ICI_DST;
  assign si_ici_dst_wire[52] = SI52_ICI_DST;
  assign si_ici_dst_wire[53] = SI53_ICI_DST;
  assign si_ici_dst_wire[54] = SI54_ICI_DST;
  assign si_ici_dst_wire[55] = SI55_ICI_DST;
  assign si_ici_dst_wire[56] = SI56_ICI_DST;
  assign si_ici_dst_wire[57] = SI57_ICI_DST;
  assign si_ici_dst_wire[58] = SI58_ICI_DST;
  assign si_ici_dst_wire[59] = SI59_ICI_DST;
  assign si_ici_dst_wire[60] = SI60_ICI_DST;
  assign si_ici_dst_wire[61] = SI61_ICI_DST;
  assign si_ici_dst_wire[62] = SI62_ICI_DST;
  assign si_ici_dst_wire[63] = SI63_ICI_DST;
  assign si_ici_dst_wire[64] = SI64_ICI_DST;
  assign si_ici_dst_wire[65] = SI65_ICI_DST;
  assign si_ici_dst_wire[66] = SI66_ICI_DST;
  assign si_ici_dst_wire[67] = SI67_ICI_DST;
  assign si_ici_dst_wire[68] = SI68_ICI_DST;
  assign si_ici_dst_wire[69] = SI69_ICI_DST;
  assign si_ici_dst_wire[70] = SI70_ICI_DST;
  assign si_ici_dst_wire[71] = SI71_ICI_DST;
  assign si_ici_dst_wire[72] = SI72_ICI_DST;
  assign si_ici_dst_wire[73] = SI73_ICI_DST;
  assign si_ici_dst_wire[74] = SI74_ICI_DST;
  assign si_ici_dst_wire[75] = SI75_ICI_DST;
  assign si_ici_dst_wire[76] = SI76_ICI_DST;
  assign si_ici_dst_wire[77] = SI77_ICI_DST;
  assign si_ici_dst_wire[78] = SI78_ICI_DST;
  assign si_ici_dst_wire[79] = SI79_ICI_DST;
  assign si_ici_dst_wire[80] = SI80_ICI_DST;
  assign si_ici_dst_wire[81] = SI81_ICI_DST;
  assign si_ici_dst_wire[82] = SI82_ICI_DST;
  assign si_ici_dst_wire[83] = SI83_ICI_DST;
  assign si_ici_dst_wire[84] = SI84_ICI_DST;
  assign si_ici_dst_wire[85] = SI85_ICI_DST;
  assign si_ici_dst_wire[86] = SI86_ICI_DST;
  assign si_ici_dst_wire[87] = SI87_ICI_DST;
  assign si_ici_dst_wire[88] = SI88_ICI_DST;
  assign si_ici_dst_wire[89] = SI89_ICI_DST;
  assign si_ici_dst_wire[90] = SI90_ICI_DST;
  assign si_ici_dst_wire[91] = SI91_ICI_DST;
  assign si_ici_dst_wire[92] = SI92_ICI_DST;
  assign si_ici_dst_wire[93] = SI93_ICI_DST;
  assign si_ici_dst_wire[94] = SI94_ICI_DST;
  assign si_ici_dst_wire[95] = SI95_ICI_DST;

  assign shd_int_info_read_data   = (shd_int_sel_int_sel_rw_r >= NUM_SHD_INT) ? 32'h00000000 : {{THIRTY_TWO_MINUS_NUM_ICI{1'b0}}, si_ici_dst_wire[shd_int_sel_int_sel_rw_r[((NUM_SHD_INT > 1) ? $clog2(NUM_SHD_INT)-1 : 0):0]]};
  assign shd_int_cfg_read_data    = (shd_int_sel_int_sel_rw_r >= NUM_SHD_INT) ? 32'h00000000 : {{THIRTY_TWO_MINUS_NUM_ICI{1'b0}}, (shd_int_cfg_ici_en_rw_r[shd_int_sel_int_sel_rw_r[((NUM_SHD_INT > 1) ? $clog2(NUM_SHD_INT)-1 : 0):0]] & si_ici_dst_wire[shd_int_sel_int_sel_rw_r[((NUM_SHD_INT > 1) ? $clog2(NUM_SHD_INT)-1 : 0):0]])};


  assign shd_int_lctrl_read_data  = ((LDE_LVL < 2) | (shd_int_sel_int_sel_rw_r >= NUM_SHD_INT)) ? 32'h00000000 : {shd_int_lctrl_lock_rw_r[shd_int_sel_int_sel_rw_r[((NUM_SHD_INT > 1) ? $clog2(NUM_SHD_INT)-1 : 0):0]], {31{1'b0}}};


  assign pid0_read_data = {24'h00_0000, PID0_PART_0};
  assign pid1_read_data = {24'h00_0000, PID1_DES_0_PART_1};
  assign pid2_read_data = {24'h00_0000, pid2_revision_eco, PID2_JEDEC_DES_1};
  assign pid3_read_data = {24'h00_0000, pid3_revand_eco, PID3_CMOD};
  assign pid4_read_data = {24'h00_0000, PID4_SIZE_DES_2};
  assign pid5_read_data = 32'h0000_0000;
  assign pid6_read_data = 32'h0000_0000;
  assign pid7_read_data = 32'h0000_0000;


  assign cid0_read_data = {24'h00_0000, CID0_PRMBL_0};
  assign cid1_read_data = {24'h00_0000, CID1_CLASS_PRMBL_1};
  assign cid2_read_data = {24'h00_0000, CID2_PRMBL_2};
  assign cid3_read_data = {24'h00_0000, CID3_PRMBL_3};


  wire pslverr_oob;
  wire pslverr_strb;
  wire pslverr_rsvd;
  wire pslverr_tamper_access;

  assign pslverr_strb = ((psel_i & global_write_en) & (pstrb_r != 4'b1111));
  assign pslverr_tamper_access = (paddr_r == INT_RTR_TMP_ST) & ((pprot_r != 2'b01) | (master_id_r != SECURE_MASTER_ID[MASTER_ID_WIDTH-1:0]));
  assign pslverr_oob = ((psel_i & (prdata_en | global_write_en)) & (shd_int_sel_int_sel_rw_r >= NUM_SHD_INT) & ((paddr_r == SHD_INT_CFG) | (paddr_r == SHD_INT_INFO) | (paddr_r == SHD_INT_LCTRL)));
  assign pslverr_rsvd = ( (psel_i & (prdata_en | global_write_en)) &
                   (paddr_r != INT_RTR_CTRL) &
                   (paddr_r != LD_CTRL) &
                   (paddr_r != SHD_INT_CFG) &
                   (paddr_r != SHD_INT_LCTRL) &
                   (paddr_r != SHD_INT_SEL) &
                   (paddr_r != INT_RTR_TMP_ST) &
                   (paddr_r != SHD_INT_INFO) &
                   (paddr_r != INT_RTR_CAP) &
                   (paddr_r != INT_RTR_CFG) &
                   (paddr_r != PID0) &
                   (paddr_r != PID1) &
                   (paddr_r != PID2) &
                   (paddr_r != PID3) &
                   (paddr_r != PID4) &
                   (paddr_r != PID5) &
                   (paddr_r != PID6) &
                   (paddr_r != PID7) &
                   (paddr_r != ID0) &
                   (paddr_r != ID1) &
                   (paddr_r != ID2) &
                   (paddr_r != ID3) );



  arm_element_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'h0)
  ) u_arm_element_ecorevnum_0 (
    .ecorevnum (pid2_revision_eco)
    );

  arm_element_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'h0)
  ) u_arm_element_ecorevnum_1 (
    .ecorevnum (pid3_revand_eco)
  );





  reg ld_ctrl_ldi_st_ro_r_next;
  reg [9:0] int_rtr_tmp_st_trans_addr_ro_r_next;

  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      ld_ctrl_ldi_st_ro_r <= 1'b0;
      int_rtr_tmp_st_trans_addr_ro_r <= 10'b00000_00000;
    end
    else
    begin
      ld_ctrl_ldi_st_ro_r <= ld_ctrl_ldi_st_ro_r_next;
      int_rtr_tmp_st_trans_addr_ro_r <= int_rtr_tmp_st_trans_addr_ro_r_next;
    end
  end

  always @*
  begin
    ld_ctrl_ldi_st_ro_r_next = lock_i;
    int_rtr_tmp_st_trans_addr_ro_r_next = int_rtr_tmp_st_vld_rw_r ? int_rtr_tmp_st_trans_addr_ro_r : paddr_r[11:2];
  end


  reg int_rtr_ctrl_err_rw_r_nxt;

  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      int_rtr_ctrl_err_rw_r <= 1'b1;
    end
    else
    begin
      int_rtr_ctrl_err_rw_r <= int_rtr_ctrl_err_rw_r_nxt;
    end
  end

  always @*
  begin
    int_rtr_ctrl_err_rw_r_nxt = int_rtr_ctrl_write_en ? pwdata_r[0] : int_rtr_ctrl_err_rw_r;
  end


  reg [1:0] ld_ctrl_lock_rw_r_next;

  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      ld_ctrl_lock_rw_r <= 2'b00;
    end
    else
    begin
      ld_ctrl_lock_rw_r <= ld_ctrl_lock_rw_r_next;
    end
  end

  always @*
  begin
    ld_ctrl_lock_rw_r_next = ld_ctrl_write_en ? pwdata_r[1:0] : ld_ctrl_lock_rw_r;
  end


  reg [INT_SEL_WIDTH-1:0] shd_int_sel_int_sel_rw_r_next;

  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_sel_int_sel_rw_r <= {INT_SEL_WIDTH{1'b0}};
    end
    else
    begin
      shd_int_sel_int_sel_rw_r <= shd_int_sel_int_sel_rw_r_next;
    end
  end

  always @*
  begin
    shd_int_sel_int_sel_rw_r_next = shd_int_sel_write_en ? pwdata_r[INT_SEL_WIDTH-1:0] : shd_int_sel_int_sel_rw_r;
  end


  reg int_rtr_tmp_st_vld_rw_r_next;
  reg int_rtr_tmp_st_ovrflw_rw_r_next;

  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      int_rtr_tmp_st_vld_rw_r <= 1'b0;
      int_rtr_tmp_st_ovrflw_rw_r <= 1'b0;
    end
    else
    begin
      int_rtr_tmp_st_vld_rw_r <= int_rtr_tmp_st_vld_rw_r_next;
      int_rtr_tmp_st_ovrflw_rw_r <= int_rtr_tmp_st_ovrflw_rw_r_next;
    end
  end

  always @*
  begin
    int_rtr_tmp_st_vld_rw_r_next = int_rtr_tmp_st_write_en ? (pwdata_r[31] ? 1'b0 : int_rtr_tmp_st_vld_rw_r) : (int_rtr_tmp_st_vld_rw_r ? int_rtr_tmp_st_vld_rw_r : tamper_i);
    int_rtr_tmp_st_ovrflw_rw_r_next = int_rtr_tmp_st_write_en ? (pwdata_r[30] ? 1'b0 : int_rtr_tmp_st_ovrflw_rw_r) : (int_rtr_tmp_st_ovrflw_rw_r ? int_rtr_tmp_st_ovrflw_rw_r : (int_rtr_tmp_st_vld_rw_r & tamper_i)) ;
  end

  reg [NUM_ICI-1:0] shd_int_cfg_ici_en_rw_r_next [NUM_SHD_INT-1:0];


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[0][3:0] <= SI0_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[0][3:0] <= shd_int_cfg_ici_en_rw_r_next[0];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[0] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 0)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[0];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[1][3:0] <= SI1_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[1][3:0] <= shd_int_cfg_ici_en_rw_r_next[1];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[1] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 1)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[1];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[2][3:0] <= SI2_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[2][3:0] <= shd_int_cfg_ici_en_rw_r_next[2];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[2] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 2)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[2];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[3][3:0] <= SI3_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[3][3:0] <= shd_int_cfg_ici_en_rw_r_next[3];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[3] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 3)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[3];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[4][3:0] <= SI4_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[4][3:0] <= shd_int_cfg_ici_en_rw_r_next[4];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[4] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 4)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[4];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[5][3:0] <= SI5_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[5][3:0] <= shd_int_cfg_ici_en_rw_r_next[5];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[5] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 5)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[5];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[6][3:0] <= SI6_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[6][3:0] <= shd_int_cfg_ici_en_rw_r_next[6];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[6] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 6)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[6];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[7][3:0] <= SI7_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[7][3:0] <= shd_int_cfg_ici_en_rw_r_next[7];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[7] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 7)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[7];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[8][3:0] <= SI8_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[8][3:0] <= shd_int_cfg_ici_en_rw_r_next[8];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[8] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 8)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[8];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[9][3:0] <= SI9_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[9][3:0] <= shd_int_cfg_ici_en_rw_r_next[9];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[9] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 9)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[9];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[10][3:0] <= SI10_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[10][3:0] <= shd_int_cfg_ici_en_rw_r_next[10];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[10] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 10)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[10];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[11][3:0] <= SI11_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[11][3:0] <= shd_int_cfg_ici_en_rw_r_next[11];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[11] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 11)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[11];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[12][3:0] <= SI12_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[12][3:0] <= shd_int_cfg_ici_en_rw_r_next[12];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[12] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 12)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[12];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[13][3:0] <= SI13_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[13][3:0] <= shd_int_cfg_ici_en_rw_r_next[13];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[13] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 13)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[13];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[14][3:0] <= SI14_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[14][3:0] <= shd_int_cfg_ici_en_rw_r_next[14];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[14] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 14)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[14];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[15][3:0] <= SI15_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[15][3:0] <= shd_int_cfg_ici_en_rw_r_next[15];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[15] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 15)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[15];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[16][3:0] <= SI16_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[16][3:0] <= shd_int_cfg_ici_en_rw_r_next[16];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[16] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 16)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[16];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[17][3:0] <= SI17_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[17][3:0] <= shd_int_cfg_ici_en_rw_r_next[17];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[17] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 17)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[17];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[18][3:0] <= SI18_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[18][3:0] <= shd_int_cfg_ici_en_rw_r_next[18];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[18] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 18)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[18];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[19][3:0] <= SI19_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[19][3:0] <= shd_int_cfg_ici_en_rw_r_next[19];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[19] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 19)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[19];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[20][3:0] <= SI20_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[20][3:0] <= shd_int_cfg_ici_en_rw_r_next[20];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[20] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 20)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[20];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[21][3:0] <= SI21_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[21][3:0] <= shd_int_cfg_ici_en_rw_r_next[21];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[21] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 21)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[21];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[22][3:0] <= SI22_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[22][3:0] <= shd_int_cfg_ici_en_rw_r_next[22];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[22] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 22)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[22];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[23][3:0] <= SI23_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[23][3:0] <= shd_int_cfg_ici_en_rw_r_next[23];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[23] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 23)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[23];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[24][3:0] <= SI24_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[24][3:0] <= shd_int_cfg_ici_en_rw_r_next[24];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[24] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 24)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[24];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[25][3:0] <= SI25_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[25][3:0] <= shd_int_cfg_ici_en_rw_r_next[25];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[25] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 25)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[25];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[26][3:0] <= SI26_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[26][3:0] <= shd_int_cfg_ici_en_rw_r_next[26];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[26] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 26)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[26];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[27][3:0] <= SI27_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[27][3:0] <= shd_int_cfg_ici_en_rw_r_next[27];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[27] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 27)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[27];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[28][3:0] <= SI28_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[28][3:0] <= shd_int_cfg_ici_en_rw_r_next[28];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[28] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 28)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[28];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[29][3:0] <= SI29_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[29][3:0] <= shd_int_cfg_ici_en_rw_r_next[29];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[29] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 29)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[29];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[30][3:0] <= SI30_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[30][3:0] <= shd_int_cfg_ici_en_rw_r_next[30];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[30] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 30)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[30];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[31][3:0] <= SI31_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[31][3:0] <= shd_int_cfg_ici_en_rw_r_next[31];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[31] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 31)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[31];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[32][3:0] <= SI32_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[32][3:0] <= shd_int_cfg_ici_en_rw_r_next[32];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[32] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 32)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[32];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[33][3:0] <= SI33_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[33][3:0] <= shd_int_cfg_ici_en_rw_r_next[33];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[33] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 33)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[33];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[34][3:0] <= SI34_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[34][3:0] <= shd_int_cfg_ici_en_rw_r_next[34];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[34] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 34)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[34];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[35][3:0] <= SI35_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[35][3:0] <= shd_int_cfg_ici_en_rw_r_next[35];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[35] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 35)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[35];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[36][3:0] <= SI36_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[36][3:0] <= shd_int_cfg_ici_en_rw_r_next[36];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[36] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 36)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[36];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[37][3:0] <= SI37_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[37][3:0] <= shd_int_cfg_ici_en_rw_r_next[37];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[37] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 37)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[37];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[38][3:0] <= SI38_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[38][3:0] <= shd_int_cfg_ici_en_rw_r_next[38];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[38] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 38)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[38];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[39][3:0] <= SI39_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[39][3:0] <= shd_int_cfg_ici_en_rw_r_next[39];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[39] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 39)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[39];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[40][3:0] <= SI40_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[40][3:0] <= shd_int_cfg_ici_en_rw_r_next[40];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[40] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 40)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[40];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[41][3:0] <= SI41_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[41][3:0] <= shd_int_cfg_ici_en_rw_r_next[41];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[41] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 41)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[41];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[42][3:0] <= SI42_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[42][3:0] <= shd_int_cfg_ici_en_rw_r_next[42];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[42] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 42)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[42];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[43][3:0] <= SI43_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[43][3:0] <= shd_int_cfg_ici_en_rw_r_next[43];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[43] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 43)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[43];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[44][3:0] <= SI44_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[44][3:0] <= shd_int_cfg_ici_en_rw_r_next[44];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[44] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 44)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[44];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[45][3:0] <= SI45_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[45][3:0] <= shd_int_cfg_ici_en_rw_r_next[45];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[45] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 45)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[45];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[46][3:0] <= SI46_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[46][3:0] <= shd_int_cfg_ici_en_rw_r_next[46];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[46] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 46)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[46];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[47][3:0] <= SI47_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[47][3:0] <= shd_int_cfg_ici_en_rw_r_next[47];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[47] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 47)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[47];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[48][3:0] <= SI48_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[48][3:0] <= shd_int_cfg_ici_en_rw_r_next[48];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[48] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 48)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[48];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[49][3:0] <= SI49_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[49][3:0] <= shd_int_cfg_ici_en_rw_r_next[49];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[49] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 49)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[49];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[50][3:0] <= SI50_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[50][3:0] <= shd_int_cfg_ici_en_rw_r_next[50];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[50] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 50)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[50];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[51][3:0] <= SI51_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[51][3:0] <= shd_int_cfg_ici_en_rw_r_next[51];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[51] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 51)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[51];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[52][3:0] <= SI52_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[52][3:0] <= shd_int_cfg_ici_en_rw_r_next[52];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[52] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 52)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[52];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[53][3:0] <= SI53_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[53][3:0] <= shd_int_cfg_ici_en_rw_r_next[53];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[53] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 53)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[53];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[54][3:0] <= SI54_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[54][3:0] <= shd_int_cfg_ici_en_rw_r_next[54];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[54] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 54)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[54];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[55][3:0] <= SI55_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[55][3:0] <= shd_int_cfg_ici_en_rw_r_next[55];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[55] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 55)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[55];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[56][3:0] <= SI56_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[56][3:0] <= shd_int_cfg_ici_en_rw_r_next[56];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[56] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 56)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[56];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[57][3:0] <= SI57_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[57][3:0] <= shd_int_cfg_ici_en_rw_r_next[57];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[57] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 57)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[57];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[58][3:0] <= SI58_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[58][3:0] <= shd_int_cfg_ici_en_rw_r_next[58];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[58] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 58)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[58];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[59][3:0] <= SI59_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[59][3:0] <= shd_int_cfg_ici_en_rw_r_next[59];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[59] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 59)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[59];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[60][3:0] <= SI60_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[60][3:0] <= shd_int_cfg_ici_en_rw_r_next[60];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[60] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 60)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[60];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[61][3:0] <= SI61_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[61][3:0] <= shd_int_cfg_ici_en_rw_r_next[61];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[61] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 61)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[61];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[62][3:0] <= SI62_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[62][3:0] <= shd_int_cfg_ici_en_rw_r_next[62];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[62] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 62)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[62];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[63][3:0] <= SI63_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[63][3:0] <= shd_int_cfg_ici_en_rw_r_next[63];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[63] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 63)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[63];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[64][3:0] <= SI64_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[64][3:0] <= shd_int_cfg_ici_en_rw_r_next[64];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[64] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 64)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[64];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[65][3:0] <= SI65_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[65][3:0] <= shd_int_cfg_ici_en_rw_r_next[65];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[65] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 65)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[65];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[66][3:0] <= SI66_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[66][3:0] <= shd_int_cfg_ici_en_rw_r_next[66];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[66] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 66)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[66];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[67][3:0] <= SI67_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[67][3:0] <= shd_int_cfg_ici_en_rw_r_next[67];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[67] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 67)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[67];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[68][3:0] <= SI68_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[68][3:0] <= shd_int_cfg_ici_en_rw_r_next[68];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[68] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 68)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[68];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[69][3:0] <= SI69_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[69][3:0] <= shd_int_cfg_ici_en_rw_r_next[69];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[69] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 69)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[69];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[70][3:0] <= SI70_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[70][3:0] <= shd_int_cfg_ici_en_rw_r_next[70];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[70] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 70)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[70];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[71][3:0] <= SI71_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[71][3:0] <= shd_int_cfg_ici_en_rw_r_next[71];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[71] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 71)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[71];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[72][3:0] <= SI72_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[72][3:0] <= shd_int_cfg_ici_en_rw_r_next[72];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[72] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 72)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[72];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[73][3:0] <= SI73_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[73][3:0] <= shd_int_cfg_ici_en_rw_r_next[73];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[73] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 73)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[73];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[74][3:0] <= SI74_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[74][3:0] <= shd_int_cfg_ici_en_rw_r_next[74];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[74] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 74)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[74];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[75][3:0] <= SI75_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[75][3:0] <= shd_int_cfg_ici_en_rw_r_next[75];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[75] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 75)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[75];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[76][3:0] <= SI76_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[76][3:0] <= shd_int_cfg_ici_en_rw_r_next[76];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[76] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 76)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[76];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[77][3:0] <= SI77_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[77][3:0] <= shd_int_cfg_ici_en_rw_r_next[77];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[77] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 77)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[77];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[78][3:0] <= SI78_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[78][3:0] <= shd_int_cfg_ici_en_rw_r_next[78];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[78] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 78)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[78];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[79][3:0] <= SI79_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[79][3:0] <= shd_int_cfg_ici_en_rw_r_next[79];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[79] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 79)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[79];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[80][3:0] <= SI80_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[80][3:0] <= shd_int_cfg_ici_en_rw_r_next[80];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[80] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 80)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[80];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[81][3:0] <= SI81_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[81][3:0] <= shd_int_cfg_ici_en_rw_r_next[81];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[81] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 81)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[81];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[82][3:0] <= SI82_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[82][3:0] <= shd_int_cfg_ici_en_rw_r_next[82];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[82] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 82)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[82];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[83][3:0] <= SI83_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[83][3:0] <= shd_int_cfg_ici_en_rw_r_next[83];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[83] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 83)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[83];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[84][3:0] <= SI84_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[84][3:0] <= shd_int_cfg_ici_en_rw_r_next[84];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[84] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 84)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[84];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[85][3:0] <= SI85_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[85][3:0] <= shd_int_cfg_ici_en_rw_r_next[85];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[85] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 85)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[85];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[86][3:0] <= SI86_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[86][3:0] <= shd_int_cfg_ici_en_rw_r_next[86];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[86] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 86)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[86];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[87][3:0] <= SI87_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[87][3:0] <= shd_int_cfg_ici_en_rw_r_next[87];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[87] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 87)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[87];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[88][3:0] <= SI88_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[88][3:0] <= shd_int_cfg_ici_en_rw_r_next[88];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[88] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 88)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[88];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[89][3:0] <= SI89_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[89][3:0] <= shd_int_cfg_ici_en_rw_r_next[89];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[89] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 89)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[89];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[90][3:0] <= SI90_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[90][3:0] <= shd_int_cfg_ici_en_rw_r_next[90];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[90] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 90)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[90];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[91][3:0] <= SI91_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[91][3:0] <= shd_int_cfg_ici_en_rw_r_next[91];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[91] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 91)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[91];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[92][3:0] <= SI92_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[92][3:0] <= shd_int_cfg_ici_en_rw_r_next[92];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[92] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 92)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[92];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[93][3:0] <= SI93_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[93][3:0] <= shd_int_cfg_ici_en_rw_r_next[93];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[93] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 93)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[93];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[94][3:0] <= SI94_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[94][3:0] <= shd_int_cfg_ici_en_rw_r_next[94];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[94] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 94)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[94];
  end


  always @(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      shd_int_cfg_ici_en_rw_r[95][3:0] <= SI95_DEF_ICI;
    end
    else
    begin
      shd_int_cfg_ici_en_rw_r[95][3:0] <= shd_int_cfg_ici_en_rw_r_next[95];
    end
  end
  always @*
  begin
    shd_int_cfg_ici_en_rw_r_next[95] = (shd_int_cfg_write_en & (shd_int_sel_int_sel_rw_r == 95)) ? pwdata_r[NUM_ICI-1:0] : shd_int_cfg_ici_en_rw_r[95];
  end


  reg shd_int_lctrl_lock_rw_r_next [NUM_SHD_INT-1:0];

  generate
    for(I=0; I < NUM_SHD_INT; I=I+1)
    begin:lctrl_lock_generate_block
      always @(posedge pclk or negedge presetn)
      begin
        if(!presetn)
        begin
          shd_int_lctrl_lock_rw_r[I] <= 1'b0;
        end
        else
        begin
          shd_int_lctrl_lock_rw_r[I] <= shd_int_lctrl_lock_rw_r_next[I];
        end
      end

      always @*
      begin
        shd_int_lctrl_lock_rw_r_next[I] = (shd_int_lctrl_write_en & (I == shd_int_sel_int_sel_rw_r)) ? pwdata_r[31] : shd_int_lctrl_lock_rw_r[I];
      end
    end
  endgenerate

  assign paddr_r_o               = paddr_r;
  assign master_id_r_o           = master_id_r;
  assign pprot_r_o               = pprot_r[1:0];
  assign ld_ctrl_lock_o          = ld_ctrl_lock_rw_r;
  assign shd_int_lctrl_lock_o    = (shd_int_sel_int_sel_rw_r[((NUM_SHD_INT > 1) ? $clog2(NUM_SHD_INT)-1 : 0):0] >= NUM_SHD_INT) ? 1'b0 : shd_int_lctrl_lock_rw_r[shd_int_sel_int_sel_rw_r[((NUM_SHD_INT > 1) ? $clog2(NUM_SHD_INT)-1 : 0):0]];

  assign int_rtr_tmp_st_vld_o    = int_rtr_tmp_st_vld_rw_r;
  assign int_rtr_tmp_st_ovrflw_o = int_rtr_tmp_st_ovrflw_rw_r;
  assign global_write_en_o       = global_write_en;
  assign prdata_en_o             = prdata_en;
  assign shd_int_cfg_ici0_en_o    = { shd_int_cfg_ici_en_rw_r[95][0], shd_int_cfg_ici_en_rw_r[94][0], shd_int_cfg_ici_en_rw_r[93][0], shd_int_cfg_ici_en_rw_r[92][0], shd_int_cfg_ici_en_rw_r[91][0], shd_int_cfg_ici_en_rw_r[90][0], shd_int_cfg_ici_en_rw_r[89][0], shd_int_cfg_ici_en_rw_r[88][0], shd_int_cfg_ici_en_rw_r[87][0], shd_int_cfg_ici_en_rw_r[86][0], shd_int_cfg_ici_en_rw_r[85][0], shd_int_cfg_ici_en_rw_r[84][0], shd_int_cfg_ici_en_rw_r[83][0], shd_int_cfg_ici_en_rw_r[82][0], shd_int_cfg_ici_en_rw_r[81][0], shd_int_cfg_ici_en_rw_r[80][0], shd_int_cfg_ici_en_rw_r[79][0], shd_int_cfg_ici_en_rw_r[78][0], shd_int_cfg_ici_en_rw_r[77][0], shd_int_cfg_ici_en_rw_r[76][0], shd_int_cfg_ici_en_rw_r[75][0], shd_int_cfg_ici_en_rw_r[74][0], shd_int_cfg_ici_en_rw_r[73][0], shd_int_cfg_ici_en_rw_r[72][0], shd_int_cfg_ici_en_rw_r[71][0], shd_int_cfg_ici_en_rw_r[70][0], shd_int_cfg_ici_en_rw_r[69][0], shd_int_cfg_ici_en_rw_r[68][0], shd_int_cfg_ici_en_rw_r[67][0], shd_int_cfg_ici_en_rw_r[66][0], shd_int_cfg_ici_en_rw_r[65][0], shd_int_cfg_ici_en_rw_r[64][0], shd_int_cfg_ici_en_rw_r[63][0], shd_int_cfg_ici_en_rw_r[62][0], shd_int_cfg_ici_en_rw_r[61][0], shd_int_cfg_ici_en_rw_r[60][0], shd_int_cfg_ici_en_rw_r[59][0], shd_int_cfg_ici_en_rw_r[58][0], shd_int_cfg_ici_en_rw_r[57][0], shd_int_cfg_ici_en_rw_r[56][0], shd_int_cfg_ici_en_rw_r[55][0], shd_int_cfg_ici_en_rw_r[54][0], shd_int_cfg_ici_en_rw_r[53][0], shd_int_cfg_ici_en_rw_r[52][0], shd_int_cfg_ici_en_rw_r[51][0], shd_int_cfg_ici_en_rw_r[50][0], shd_int_cfg_ici_en_rw_r[49][0], shd_int_cfg_ici_en_rw_r[48][0], shd_int_cfg_ici_en_rw_r[47][0], shd_int_cfg_ici_en_rw_r[46][0], shd_int_cfg_ici_en_rw_r[45][0], shd_int_cfg_ici_en_rw_r[44][0], shd_int_cfg_ici_en_rw_r[43][0], shd_int_cfg_ici_en_rw_r[42][0], shd_int_cfg_ici_en_rw_r[41][0], shd_int_cfg_ici_en_rw_r[40][0], shd_int_cfg_ici_en_rw_r[39][0], shd_int_cfg_ici_en_rw_r[38][0], shd_int_cfg_ici_en_rw_r[37][0], shd_int_cfg_ici_en_rw_r[36][0], shd_int_cfg_ici_en_rw_r[35][0], shd_int_cfg_ici_en_rw_r[34][0], shd_int_cfg_ici_en_rw_r[33][0], shd_int_cfg_ici_en_rw_r[32][0], shd_int_cfg_ici_en_rw_r[31][0], shd_int_cfg_ici_en_rw_r[30][0], shd_int_cfg_ici_en_rw_r[29][0], shd_int_cfg_ici_en_rw_r[28][0], shd_int_cfg_ici_en_rw_r[27][0], shd_int_cfg_ici_en_rw_r[26][0], shd_int_cfg_ici_en_rw_r[25][0], shd_int_cfg_ici_en_rw_r[24][0], shd_int_cfg_ici_en_rw_r[23][0], shd_int_cfg_ici_en_rw_r[22][0], shd_int_cfg_ici_en_rw_r[21][0], shd_int_cfg_ici_en_rw_r[20][0], shd_int_cfg_ici_en_rw_r[19][0], shd_int_cfg_ici_en_rw_r[18][0], shd_int_cfg_ici_en_rw_r[17][0], shd_int_cfg_ici_en_rw_r[16][0], shd_int_cfg_ici_en_rw_r[15][0], shd_int_cfg_ici_en_rw_r[14][0], shd_int_cfg_ici_en_rw_r[13][0], shd_int_cfg_ici_en_rw_r[12][0], shd_int_cfg_ici_en_rw_r[11][0], shd_int_cfg_ici_en_rw_r[10][0], shd_int_cfg_ici_en_rw_r[9][0], shd_int_cfg_ici_en_rw_r[8][0], shd_int_cfg_ici_en_rw_r[7][0], shd_int_cfg_ici_en_rw_r[6][0], shd_int_cfg_ici_en_rw_r[5][0], shd_int_cfg_ici_en_rw_r[4][0], shd_int_cfg_ici_en_rw_r[3][0], shd_int_cfg_ici_en_rw_r[2][0], shd_int_cfg_ici_en_rw_r[1][0],  shd_int_cfg_ici_en_rw_r[0][0]};
  assign shd_int_cfg_ici1_en_o    = { shd_int_cfg_ici_en_rw_r[95][1], shd_int_cfg_ici_en_rw_r[94][1], shd_int_cfg_ici_en_rw_r[93][1], shd_int_cfg_ici_en_rw_r[92][1], shd_int_cfg_ici_en_rw_r[91][1], shd_int_cfg_ici_en_rw_r[90][1], shd_int_cfg_ici_en_rw_r[89][1], shd_int_cfg_ici_en_rw_r[88][1], shd_int_cfg_ici_en_rw_r[87][1], shd_int_cfg_ici_en_rw_r[86][1], shd_int_cfg_ici_en_rw_r[85][1], shd_int_cfg_ici_en_rw_r[84][1], shd_int_cfg_ici_en_rw_r[83][1], shd_int_cfg_ici_en_rw_r[82][1], shd_int_cfg_ici_en_rw_r[81][1], shd_int_cfg_ici_en_rw_r[80][1], shd_int_cfg_ici_en_rw_r[79][1], shd_int_cfg_ici_en_rw_r[78][1], shd_int_cfg_ici_en_rw_r[77][1], shd_int_cfg_ici_en_rw_r[76][1], shd_int_cfg_ici_en_rw_r[75][1], shd_int_cfg_ici_en_rw_r[74][1], shd_int_cfg_ici_en_rw_r[73][1], shd_int_cfg_ici_en_rw_r[72][1], shd_int_cfg_ici_en_rw_r[71][1], shd_int_cfg_ici_en_rw_r[70][1], shd_int_cfg_ici_en_rw_r[69][1], shd_int_cfg_ici_en_rw_r[68][1], shd_int_cfg_ici_en_rw_r[67][1], shd_int_cfg_ici_en_rw_r[66][1], shd_int_cfg_ici_en_rw_r[65][1], shd_int_cfg_ici_en_rw_r[64][1], shd_int_cfg_ici_en_rw_r[63][1], shd_int_cfg_ici_en_rw_r[62][1], shd_int_cfg_ici_en_rw_r[61][1], shd_int_cfg_ici_en_rw_r[60][1], shd_int_cfg_ici_en_rw_r[59][1], shd_int_cfg_ici_en_rw_r[58][1], shd_int_cfg_ici_en_rw_r[57][1], shd_int_cfg_ici_en_rw_r[56][1], shd_int_cfg_ici_en_rw_r[55][1], shd_int_cfg_ici_en_rw_r[54][1], shd_int_cfg_ici_en_rw_r[53][1], shd_int_cfg_ici_en_rw_r[52][1], shd_int_cfg_ici_en_rw_r[51][1], shd_int_cfg_ici_en_rw_r[50][1], shd_int_cfg_ici_en_rw_r[49][1], shd_int_cfg_ici_en_rw_r[48][1], shd_int_cfg_ici_en_rw_r[47][1], shd_int_cfg_ici_en_rw_r[46][1], shd_int_cfg_ici_en_rw_r[45][1], shd_int_cfg_ici_en_rw_r[44][1], shd_int_cfg_ici_en_rw_r[43][1], shd_int_cfg_ici_en_rw_r[42][1], shd_int_cfg_ici_en_rw_r[41][1], shd_int_cfg_ici_en_rw_r[40][1], shd_int_cfg_ici_en_rw_r[39][1], shd_int_cfg_ici_en_rw_r[38][1], shd_int_cfg_ici_en_rw_r[37][1], shd_int_cfg_ici_en_rw_r[36][1], shd_int_cfg_ici_en_rw_r[35][1], shd_int_cfg_ici_en_rw_r[34][1], shd_int_cfg_ici_en_rw_r[33][1], shd_int_cfg_ici_en_rw_r[32][1], shd_int_cfg_ici_en_rw_r[31][1], shd_int_cfg_ici_en_rw_r[30][1], shd_int_cfg_ici_en_rw_r[29][1], shd_int_cfg_ici_en_rw_r[28][1], shd_int_cfg_ici_en_rw_r[27][1], shd_int_cfg_ici_en_rw_r[26][1], shd_int_cfg_ici_en_rw_r[25][1], shd_int_cfg_ici_en_rw_r[24][1], shd_int_cfg_ici_en_rw_r[23][1], shd_int_cfg_ici_en_rw_r[22][1], shd_int_cfg_ici_en_rw_r[21][1], shd_int_cfg_ici_en_rw_r[20][1], shd_int_cfg_ici_en_rw_r[19][1], shd_int_cfg_ici_en_rw_r[18][1], shd_int_cfg_ici_en_rw_r[17][1], shd_int_cfg_ici_en_rw_r[16][1], shd_int_cfg_ici_en_rw_r[15][1], shd_int_cfg_ici_en_rw_r[14][1], shd_int_cfg_ici_en_rw_r[13][1], shd_int_cfg_ici_en_rw_r[12][1], shd_int_cfg_ici_en_rw_r[11][1], shd_int_cfg_ici_en_rw_r[10][1], shd_int_cfg_ici_en_rw_r[9][1], shd_int_cfg_ici_en_rw_r[8][1], shd_int_cfg_ici_en_rw_r[7][1], shd_int_cfg_ici_en_rw_r[6][1], shd_int_cfg_ici_en_rw_r[5][1], shd_int_cfg_ici_en_rw_r[4][1], shd_int_cfg_ici_en_rw_r[3][1], shd_int_cfg_ici_en_rw_r[2][1], shd_int_cfg_ici_en_rw_r[1][1],  shd_int_cfg_ici_en_rw_r[0][1]};
  assign shd_int_cfg_ici2_en_o    = { shd_int_cfg_ici_en_rw_r[95][2], shd_int_cfg_ici_en_rw_r[94][2], shd_int_cfg_ici_en_rw_r[93][2], shd_int_cfg_ici_en_rw_r[92][2], shd_int_cfg_ici_en_rw_r[91][2], shd_int_cfg_ici_en_rw_r[90][2], shd_int_cfg_ici_en_rw_r[89][2], shd_int_cfg_ici_en_rw_r[88][2], shd_int_cfg_ici_en_rw_r[87][2], shd_int_cfg_ici_en_rw_r[86][2], shd_int_cfg_ici_en_rw_r[85][2], shd_int_cfg_ici_en_rw_r[84][2], shd_int_cfg_ici_en_rw_r[83][2], shd_int_cfg_ici_en_rw_r[82][2], shd_int_cfg_ici_en_rw_r[81][2], shd_int_cfg_ici_en_rw_r[80][2], shd_int_cfg_ici_en_rw_r[79][2], shd_int_cfg_ici_en_rw_r[78][2], shd_int_cfg_ici_en_rw_r[77][2], shd_int_cfg_ici_en_rw_r[76][2], shd_int_cfg_ici_en_rw_r[75][2], shd_int_cfg_ici_en_rw_r[74][2], shd_int_cfg_ici_en_rw_r[73][2], shd_int_cfg_ici_en_rw_r[72][2], shd_int_cfg_ici_en_rw_r[71][2], shd_int_cfg_ici_en_rw_r[70][2], shd_int_cfg_ici_en_rw_r[69][2], shd_int_cfg_ici_en_rw_r[68][2], shd_int_cfg_ici_en_rw_r[67][2], shd_int_cfg_ici_en_rw_r[66][2], shd_int_cfg_ici_en_rw_r[65][2], shd_int_cfg_ici_en_rw_r[64][2], shd_int_cfg_ici_en_rw_r[63][2], shd_int_cfg_ici_en_rw_r[62][2], shd_int_cfg_ici_en_rw_r[61][2], shd_int_cfg_ici_en_rw_r[60][2], shd_int_cfg_ici_en_rw_r[59][2], shd_int_cfg_ici_en_rw_r[58][2], shd_int_cfg_ici_en_rw_r[57][2], shd_int_cfg_ici_en_rw_r[56][2], shd_int_cfg_ici_en_rw_r[55][2], shd_int_cfg_ici_en_rw_r[54][2], shd_int_cfg_ici_en_rw_r[53][2], shd_int_cfg_ici_en_rw_r[52][2], shd_int_cfg_ici_en_rw_r[51][2], shd_int_cfg_ici_en_rw_r[50][2], shd_int_cfg_ici_en_rw_r[49][2], shd_int_cfg_ici_en_rw_r[48][2], shd_int_cfg_ici_en_rw_r[47][2], shd_int_cfg_ici_en_rw_r[46][2], shd_int_cfg_ici_en_rw_r[45][2], shd_int_cfg_ici_en_rw_r[44][2], shd_int_cfg_ici_en_rw_r[43][2], shd_int_cfg_ici_en_rw_r[42][2], shd_int_cfg_ici_en_rw_r[41][2], shd_int_cfg_ici_en_rw_r[40][2], shd_int_cfg_ici_en_rw_r[39][2], shd_int_cfg_ici_en_rw_r[38][2], shd_int_cfg_ici_en_rw_r[37][2], shd_int_cfg_ici_en_rw_r[36][2], shd_int_cfg_ici_en_rw_r[35][2], shd_int_cfg_ici_en_rw_r[34][2], shd_int_cfg_ici_en_rw_r[33][2], shd_int_cfg_ici_en_rw_r[32][2], shd_int_cfg_ici_en_rw_r[31][2], shd_int_cfg_ici_en_rw_r[30][2], shd_int_cfg_ici_en_rw_r[29][2], shd_int_cfg_ici_en_rw_r[28][2], shd_int_cfg_ici_en_rw_r[27][2], shd_int_cfg_ici_en_rw_r[26][2], shd_int_cfg_ici_en_rw_r[25][2], shd_int_cfg_ici_en_rw_r[24][2], shd_int_cfg_ici_en_rw_r[23][2], shd_int_cfg_ici_en_rw_r[22][2], shd_int_cfg_ici_en_rw_r[21][2], shd_int_cfg_ici_en_rw_r[20][2], shd_int_cfg_ici_en_rw_r[19][2], shd_int_cfg_ici_en_rw_r[18][2], shd_int_cfg_ici_en_rw_r[17][2], shd_int_cfg_ici_en_rw_r[16][2], shd_int_cfg_ici_en_rw_r[15][2], shd_int_cfg_ici_en_rw_r[14][2], shd_int_cfg_ici_en_rw_r[13][2], shd_int_cfg_ici_en_rw_r[12][2], shd_int_cfg_ici_en_rw_r[11][2], shd_int_cfg_ici_en_rw_r[10][2], shd_int_cfg_ici_en_rw_r[9][2], shd_int_cfg_ici_en_rw_r[8][2], shd_int_cfg_ici_en_rw_r[7][2], shd_int_cfg_ici_en_rw_r[6][2], shd_int_cfg_ici_en_rw_r[5][2], shd_int_cfg_ici_en_rw_r[4][2], shd_int_cfg_ici_en_rw_r[3][2], shd_int_cfg_ici_en_rw_r[2][2], shd_int_cfg_ici_en_rw_r[1][2],  shd_int_cfg_ici_en_rw_r[0][2]};
  assign shd_int_cfg_ici3_en_o    = { shd_int_cfg_ici_en_rw_r[95][3], shd_int_cfg_ici_en_rw_r[94][3], shd_int_cfg_ici_en_rw_r[93][3], shd_int_cfg_ici_en_rw_r[92][3], shd_int_cfg_ici_en_rw_r[91][3], shd_int_cfg_ici_en_rw_r[90][3], shd_int_cfg_ici_en_rw_r[89][3], shd_int_cfg_ici_en_rw_r[88][3], shd_int_cfg_ici_en_rw_r[87][3], shd_int_cfg_ici_en_rw_r[86][3], shd_int_cfg_ici_en_rw_r[85][3], shd_int_cfg_ici_en_rw_r[84][3], shd_int_cfg_ici_en_rw_r[83][3], shd_int_cfg_ici_en_rw_r[82][3], shd_int_cfg_ici_en_rw_r[81][3], shd_int_cfg_ici_en_rw_r[80][3], shd_int_cfg_ici_en_rw_r[79][3], shd_int_cfg_ici_en_rw_r[78][3], shd_int_cfg_ici_en_rw_r[77][3], shd_int_cfg_ici_en_rw_r[76][3], shd_int_cfg_ici_en_rw_r[75][3], shd_int_cfg_ici_en_rw_r[74][3], shd_int_cfg_ici_en_rw_r[73][3], shd_int_cfg_ici_en_rw_r[72][3], shd_int_cfg_ici_en_rw_r[71][3], shd_int_cfg_ici_en_rw_r[70][3], shd_int_cfg_ici_en_rw_r[69][3], shd_int_cfg_ici_en_rw_r[68][3], shd_int_cfg_ici_en_rw_r[67][3], shd_int_cfg_ici_en_rw_r[66][3], shd_int_cfg_ici_en_rw_r[65][3], shd_int_cfg_ici_en_rw_r[64][3], shd_int_cfg_ici_en_rw_r[63][3], shd_int_cfg_ici_en_rw_r[62][3], shd_int_cfg_ici_en_rw_r[61][3], shd_int_cfg_ici_en_rw_r[60][3], shd_int_cfg_ici_en_rw_r[59][3], shd_int_cfg_ici_en_rw_r[58][3], shd_int_cfg_ici_en_rw_r[57][3], shd_int_cfg_ici_en_rw_r[56][3], shd_int_cfg_ici_en_rw_r[55][3], shd_int_cfg_ici_en_rw_r[54][3], shd_int_cfg_ici_en_rw_r[53][3], shd_int_cfg_ici_en_rw_r[52][3], shd_int_cfg_ici_en_rw_r[51][3], shd_int_cfg_ici_en_rw_r[50][3], shd_int_cfg_ici_en_rw_r[49][3], shd_int_cfg_ici_en_rw_r[48][3], shd_int_cfg_ici_en_rw_r[47][3], shd_int_cfg_ici_en_rw_r[46][3], shd_int_cfg_ici_en_rw_r[45][3], shd_int_cfg_ici_en_rw_r[44][3], shd_int_cfg_ici_en_rw_r[43][3], shd_int_cfg_ici_en_rw_r[42][3], shd_int_cfg_ici_en_rw_r[41][3], shd_int_cfg_ici_en_rw_r[40][3], shd_int_cfg_ici_en_rw_r[39][3], shd_int_cfg_ici_en_rw_r[38][3], shd_int_cfg_ici_en_rw_r[37][3], shd_int_cfg_ici_en_rw_r[36][3], shd_int_cfg_ici_en_rw_r[35][3], shd_int_cfg_ici_en_rw_r[34][3], shd_int_cfg_ici_en_rw_r[33][3], shd_int_cfg_ici_en_rw_r[32][3], shd_int_cfg_ici_en_rw_r[31][3], shd_int_cfg_ici_en_rw_r[30][3], shd_int_cfg_ici_en_rw_r[29][3], shd_int_cfg_ici_en_rw_r[28][3], shd_int_cfg_ici_en_rw_r[27][3], shd_int_cfg_ici_en_rw_r[26][3], shd_int_cfg_ici_en_rw_r[25][3], shd_int_cfg_ici_en_rw_r[24][3], shd_int_cfg_ici_en_rw_r[23][3], shd_int_cfg_ici_en_rw_r[22][3], shd_int_cfg_ici_en_rw_r[21][3], shd_int_cfg_ici_en_rw_r[20][3], shd_int_cfg_ici_en_rw_r[19][3], shd_int_cfg_ici_en_rw_r[18][3], shd_int_cfg_ici_en_rw_r[17][3], shd_int_cfg_ici_en_rw_r[16][3], shd_int_cfg_ici_en_rw_r[15][3], shd_int_cfg_ici_en_rw_r[14][3], shd_int_cfg_ici_en_rw_r[13][3], shd_int_cfg_ici_en_rw_r[12][3], shd_int_cfg_ici_en_rw_r[11][3], shd_int_cfg_ici_en_rw_r[10][3], shd_int_cfg_ici_en_rw_r[9][3], shd_int_cfg_ici_en_rw_r[8][3], shd_int_cfg_ici_en_rw_r[7][3], shd_int_cfg_ici_en_rw_r[6][3], shd_int_cfg_ici_en_rw_r[5][3], shd_int_cfg_ici_en_rw_r[4][3], shd_int_cfg_ici_en_rw_r[3][3], shd_int_cfg_ici_en_rw_r[2][3], shd_int_cfg_ici_en_rw_r[1][3],  shd_int_cfg_ici_en_rw_r[0][3]};
  assign prdata_o                = global_read_data;
  assign pslverr_int             = (tamper_i | pslverr_rsvd | pslverr_oob | pslverr_strb | pslverr_tamper_access) & int_rtr_ctrl_err_rw_r;
  assign pslverr_o               = pslverr_int & penable_i & psel_i;
  assign pready_o                = 1'b1;

endmodule

`ifdef INT_RTR_PARAMS
`include "interrupt_router_f0_undefs.v"
`endif



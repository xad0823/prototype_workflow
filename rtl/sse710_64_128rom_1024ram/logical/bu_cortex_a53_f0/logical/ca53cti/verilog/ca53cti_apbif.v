//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2013-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

`include "cortexa53params.v"


module ca53cti_apbif
#(
  parameter ECT_TR_WIDTH = 8,
  parameter ECT_CH_WIDTH = 4,
  parameter ECT_GATE_CHIN = 0,
  parameter ECT_CLAIM_CNT = 4
)
 (
  input                     clk,
  input                     clk_cti,
  input                     reset_n,

  input                     pseldbg_i,
  input                     penabledbg_i,
  input                     pwritedbg_i,
  input                     paddrdbg31_i,
  input              [11:2] paddrdbg_i,
  input              [31:0] pwdatadbg_i,

  input  [ECT_TR_WIDTH-1:0] ctitriginstatus_i,
  input  [ECT_TR_WIDTH-1:0] ctitrigoutstatus_i,
  input  [ECT_CH_WIDTH-1:0] ctichinstatus_i,
  input  [ECT_CH_WIDTH-1:0] ctichoutstatus_i,

  input                     map_rdata_valid_i,
  input              [31:0] map_rdata_i,

  output                    preadydbg_o,
  output             [31:0] prdatadbg_o,

  output                    glben_o,
  output [ECT_CH_WIDTH-1:0] apptrigpulse_o,
  output [ECT_CH_WIDTH-1:0] ctigate_o,
  output [ECT_TR_WIDTH-1:0] intack_o,

  output                    bus_read_o,
  output                    bus_write_unlocked_o,

  output                    bus_act_early_o
);

  wire                      bus_read_early;

  wire                      bus_read;
  wire                      bus_write;
  wire                      bus_write_unlocked;
  wire                      unlocked;

  wire                      preadydbg_nxt;
  reg                       preadydbg_r;

  wire               [31:0] prdatadbg;

  // LSR, LAR
  reg                       lsr_slk_n_r;
  wire                      lsr_slk_n_nxt;
  wire                      lsr_slk_wren;
  wire                      lsr_slk_en;
  wire               [31:0] lsr_rdata;
  wire                      lsr_rdata_valid;

  // ITCTRL
  reg                       it_itctrl_r;
  wire                      it_itctrl_nxt;
  wire                      it_itctrl_en;
  wire                      it_itctrl_wren;
  wire               [31:0] it_itctrl_rdata;
  wire                      it_itctrl_rdata_valid;

  // CTICONTROL.GLBEN
  reg                       glben_r;
  wire                      glben_nxt;
  wire                      glben_en;
  wire                      glben_wren;
  wire               [31:0] glben_rdata;
  wire                      glben_rdata_valid;

  // CTIGATE
  reg    [ECT_CH_WIDTH-1:0] ctigate_r;
  wire   [ECT_CH_WIDTH-1:0] ctigate_nxt;
  wire                      ctigate_en;
  wire                      ctigate_wren;
  wire               [31:0] ctigate_rdata;
  wire                      ctigate_rdata_valid;

  // APPTRIG clr,set
  reg    [ECT_CH_WIDTH-1:0] apptrig_r;
  wire   [ECT_CH_WIDTH-1:0] apptrig_nxt;
  wire   [ECT_CH_WIDTH-1:0] apptrig_setmask_nxt;
  wire   [ECT_CH_WIDTH-1:0] apptrig_clrmask_nxt;
  wire                      apptrig_set_en;
  wire                      apptrig_clr_en;
  wire                      apptrig_set_wren;
  wire                      apptrig_clr_wren;
  wire                      apptrig_wren;
  wire               [31:0] apptrig_set_rdata;
  wire                      apptrig_set_rdata_valid;

  wire                      claimtag_set_en;
  wire                      claimtag_clr_en;
  wire                      claimtag_set_wren;
  wire                      claimtag_clr_wren;
  wire                      claimtag_wren;
  wire               [31:0] claimtag_set_rdata;
  wire               [31:0] claimtag_clr_rdata;
  wire                      claimtag_set_rdata_valid;
  wire                      claimtag_clr_rdata_valid;

  // CTIINEN/CTIOUTEN are not implemented here.

  // pass-through outputs (wo):
  // INTACK
  wire                      intack_wren;

  // APPPULSE
  wire                      apppulse_wren;
  wire   [ECT_CH_WIDTH-1:0] apppulse;

  // Read-only "registers":
  wire                      devid_rdata_valid;
  wire               [31:0] devid_rdata;

  wire                      devid2_rdata_valid;
  wire               [31:0] devid2_rdata;
  wire                      devid1_rdata_valid;
  wire               [31:0] devid1_rdata;

  wire                      devtype_rdata_valid;
  wire               [31:0] devtype_rdata;

  wire                      devarch_rdata_valid;
  wire               [31:0] devarch_rdata;

  wire                      triginstatus_rdata_valid;
  wire               [31:0] triginstatus_rdata;

  wire                      trigoutstatus_rdata_valid;
  wire               [31:0] trigoutstatus_rdata;

  wire                      chinstatus_rdata_valid;
  wire               [31:0] chinstatus_rdata;

  wire                      choutstatus_rdata_valid;
  wire               [31:0] choutstatus_rdata;



//------------------------------------------------------------------
// Actual APB interface
//       bus_act_early is asserted during SETUP phase
//       read/write occurs during ACCESS phase
//       response for writes always in the first ACCESS cycle
//       response for reads is delayed an extra cycle so that the
//        ctichinstatus/ctitriginstatus registers get refreshed
//------------------------------------------------------------------
  assign bus_act_early_o = pseldbg_i & ~penabledbg_i;
  assign bus_read_early  = pseldbg_i & ~penabledbg_i & ~pwritedbg_i;

  assign bus_read  = pseldbg_i & penabledbg_i & ~pwritedbg_i;
  assign bus_write = pseldbg_i & penabledbg_i &  pwritedbg_i;

  assign bus_write_unlocked = bus_write & unlocked;

  assign bus_read_o           = bus_read;
  assign bus_write_unlocked_o = bus_write_unlocked;

  assign preadydbg_nxt  = ~bus_read_early;

  always @(posedge clk, negedge reset_n)
    if (~reset_n)
      preadydbg_r <= 1'b0;
    else
      preadydbg_r <= preadydbg_nxt;

  assign preadydbg_o = preadydbg_r;
  assign prdatadbg_o = prdatadbg;



//------------------------------------------------------------------
// Internal "unlocked" signal
//       - Most registers can only be written when unlocked
//       - unlocked means either external write (paddrdbg31_i) or
//         a cleared LSR.SLK (set ~LSR.SLK)
//------------------------------------------------------------------
  assign unlocked      = lsr_slk_n_r | paddrdbg31_i;



//------------------------------------------------------------------
// Outputs from registers, and combined outputs
//------------------------------------------------------------------
  assign apptrigpulse_o  = apptrig_r | apppulse;
  assign ctigate_o       = ctigate_r;
  assign glben_o         = glben_r;



//------------------------------------------------------------------
// Write-Only signals that aren't registered
//       these don't need to be registered either because they are
//       architecturally self-clearing or are registered elsewhere.
//       All of these require LSR.SLK to be unlocked or to be an
//       external write.
//------------------------------------------------------------------
  assign intack_wren      = bus_write_unlocked & (paddrdbg_i == `CA53_CTI_INTACK_ADD);
  assign apppulse_wren    = bus_write_unlocked & (paddrdbg_i == `CA53_CTI_APPPULSE_ADD);



//------------------------------------------------------------------
// INTACK and APPULSE "registers"
//       - "self-clearing"
//------------------------------------------------------------------
  assign intack_o    = {ECT_TR_WIDTH{intack_wren}}   & pwdatadbg_i[ECT_TR_WIDTH-1:0];
  assign apppulse    = {ECT_CH_WIDTH{apppulse_wren}} & pwdatadbg_i[ECT_CH_WIDTH-1:0];



//------------------------------------------------------------------
// LSR and LAR registers
//       - LAR as such doesn't exist - it affects the LSR.SLK bit
//       - When read externally (paddrdbg31_i), register must be RAZ
//       - LSR.SLK not affected when write is external (paddrdbg31_i)
//       - LSR.SLK is implemented as negated register to avoid
//         needing a set FF
//------------------------------------------------------------------
  assign lsr_slk_en       = (paddrdbg_i == `CA53_CTI_LOCKSTATUS_ADD);
  assign lsr_slk_wren     = bus_write & (paddrdbg_i == `CA53_CTI_LOCKACCESS_ADD) & ~paddrdbg31_i;
  assign lsr_slk_n_nxt    = (pwdatadbg_i == 32'hC5ACCE55);
  assign lsr_rdata_valid  = lsr_slk_en;
  assign lsr_rdata[31:2]  = {30{1'b0}};
  assign lsr_rdata[1]     = ~paddrdbg31_i & ~lsr_slk_n_r;
  assign lsr_rdata[0]     = ~paddrdbg31_i;

  always @(posedge clk_cti, negedge reset_n)
    if (~reset_n)
      lsr_slk_n_r <= 1'b0;
    else if (lsr_slk_wren)
      lsr_slk_n_r <= lsr_slk_n_nxt;



//------------------------------------------------------------------
// ITCTRL register
//       - can only be written externally (paddrdbg31_i) or when LSR.SLK
//         is unlocked.
//------------------------------------------------------------------
  assign it_itctrl_en           = (paddrdbg_i == `CA53_CTI_ITCONTROL_ADD);
  assign it_itctrl_wren         = bus_write_unlocked & it_itctrl_en;
  assign it_itctrl_nxt          = pwdatadbg_i[0];

  assign it_itctrl_rdata_valid  = it_itctrl_en;
  assign it_itctrl_rdata        = { {31{1'b0}} , it_itctrl_r };

  always @(posedge clk_cti, negedge reset_n)
    if (~reset_n)
      it_itctrl_r <= 1'b0;
    else if (it_itctrl_wren)
      it_itctrl_r <= it_itctrl_nxt;



//------------------------------------------------------------------
// GLBEN register
//       - can only be written externally (paddrdbg31_i) or when LSR.SLK
//         is unlocked.
//------------------------------------------------------------------
  assign glben_en           = (paddrdbg_i == `CA53_CTI_CONTROL_ADD);
  assign glben_wren         = bus_write_unlocked & glben_en;
  assign glben_nxt          = pwdatadbg_i[0];

  assign glben_rdata_valid  = glben_en;
  assign glben_rdata        = { {31{1'b0}} , glben_r };

  always @(posedge clk_cti, negedge reset_n)
    if (~reset_n)
      glben_r <= 1'b0;
    else if (glben_wren)
      glben_r <= glben_nxt;



//------------------------------------------------------------------
// CTIGATE register
//       - can only be written externally (paddrdbg31_i) or when LSR.SLK
//         is unlocked.
//------------------------------------------------------------------
  assign ctigate_en           = (paddrdbg_i == `CA53_CTI_CHANNELGATE_ADD);
  assign ctigate_wren         = bus_write_unlocked & ctigate_en;
  assign ctigate_nxt          = pwdatadbg_i[ECT_CH_WIDTH-1:0];

  assign ctigate_rdata_valid  = ctigate_en;
  assign ctigate_rdata        = { {(32-ECT_CH_WIDTH){1'b0}} , ctigate_r };

  always @(posedge clk_cti, negedge reset_n)
    if (~reset_n)
      ctigate_r <= {ECT_CH_WIDTH{1'b1}};
    else if (ctigate_wren)
      ctigate_r <= ctigate_nxt;



//------------------------------------------------------------------
// APPTRIG clear and set registers
//       - both are actually just one register
//       - can only be written externally (paddrdbg31_i) or when LSR.SLK
//         is unlocked.
//       - CLR is WO
//       - reading from SET gives the current status of the register
//------------------------------------------------------------------
  assign apptrig_set_en           = (paddrdbg_i == `CA53_CTI_APPSET_ADD);
  assign apptrig_clr_en           = (paddrdbg_i == `CA53_CTI_APPCLR_ADD);

  assign apptrig_set_wren         = bus_write_unlocked & apptrig_set_en;
  assign apptrig_clr_wren         = bus_write_unlocked & apptrig_clr_en;
  assign apptrig_wren             = apptrig_set_wren | apptrig_clr_wren;

  assign apptrig_setmask_nxt      = {ECT_CH_WIDTH{apptrig_set_wren}} & pwdatadbg_i[ECT_CH_WIDTH-1:0];
  assign apptrig_clrmask_nxt      = {ECT_CH_WIDTH{apptrig_clr_wren}} & pwdatadbg_i[ECT_CH_WIDTH-1:0];
  assign apptrig_nxt              = (apptrig_r | apptrig_setmask_nxt) & ~apptrig_clrmask_nxt;

  assign apptrig_set_rdata        = { {(32-ECT_CH_WIDTH){1'b0}} , apptrig_r };
  assign apptrig_set_rdata_valid  = apptrig_set_en;

  always @(posedge clk_cti, negedge reset_n)
    if (~reset_n)
      apptrig_r <= {ECT_CH_WIDTH{1'b0}};
    else if (apptrig_wren)
      apptrig_r <= apptrig_nxt;



//------------------------------------------------------------------
// CLAIMSET and CLAIMCLR registers
//       - both are actually just one register
//       - can only be written externally (paddrdbg31_i) or when LSR.SLK
//         is unlocked.
//       - reading from SET gives the number of implemented claim tags
//       - reading from CLR gives the current status of the register
//------------------------------------------------------------------
  generate if (ECT_CLAIM_CNT > 0) begin : CTI_CLAIMTAG

    reg   [ECT_CLAIM_CNT-1:0] claimtag_r;
    wire  [ECT_CLAIM_CNT-1:0] claimtag_nxt;
    wire  [ECT_CLAIM_CNT-1:0] claimtag_setmask_nxt;
    wire  [ECT_CLAIM_CNT-1:0] claimtag_clrmask_nxt;

    assign claimtag_set_rdata[31:ECT_CLAIM_CNT]  = {(32-ECT_CLAIM_CNT){1'b0}};
    assign claimtag_set_rdata[ECT_CLAIM_CNT-1:0] = {ECT_CLAIM_CNT{1'b1}};

    assign claimtag_clr_rdata[31:ECT_CLAIM_CNT]  = {(32-ECT_CLAIM_CNT){1'b0}};
    assign claimtag_clr_rdata[ECT_CLAIM_CNT-1:0] = claimtag_r[ECT_CLAIM_CNT-1:0];

    assign claimtag_setmask_nxt = {ECT_CLAIM_CNT{claimtag_set_wren}} & pwdatadbg_i[ECT_CLAIM_CNT-1:0];
    assign claimtag_clrmask_nxt = {ECT_CLAIM_CNT{claimtag_clr_wren}} & pwdatadbg_i[ECT_CLAIM_CNT-1:0];
    assign claimtag_nxt         = (claimtag_r | claimtag_setmask_nxt) & ~claimtag_clrmask_nxt;

    always @(posedge clk_cti, negedge reset_n)
      if (~reset_n)
        claimtag_r <= {ECT_CLAIM_CNT{1'b0}};
      else if (claimtag_wren)
        claimtag_r <= claimtag_nxt;

  end else begin : CTI_NO_CLAIMTAG

    assign claimtag_set_rdata[31:0] = 32'h00000000;
    assign claimtag_clr_rdata[31:0] = 32'h00000000;

  end
  endgenerate

  assign claimtag_set_en          = (paddrdbg_i == `CA53_CTI_CLAIMSET_ADD);
  assign claimtag_clr_en          = (paddrdbg_i == `CA53_CTI_CLAIMCLR_ADD);

  assign claimtag_set_wren        = bus_write_unlocked & claimtag_set_en;
  assign claimtag_clr_wren        = bus_write_unlocked & claimtag_clr_en;
  assign claimtag_wren            = claimtag_set_wren | claimtag_clr_wren;

  assign claimtag_set_rdata_valid = claimtag_set_en;
  assign claimtag_clr_rdata_valid = claimtag_clr_en;



//------------------------------------------------------------------
// DEVID register
//       - read-only
//------------------------------------------------------------------
  assign devid_rdata_valid   = (paddrdbg_i == `CA53_CTI_DEVID_ADD);
  assign devid_rdata[31:26]  = 6'b000000;
  assign devid_rdata[25:24]  = ECT_GATE_CHIN ? 2'b01 : 2'b00;
  assign devid_rdata[23:22]  = 2'b00;
  assign devid_rdata[21:16]  = ECT_CH_WIDTH[5:0];
  assign devid_rdata[15:14]  = 2'b00;
  assign devid_rdata[13: 8]  = ECT_TR_WIDTH[5:0];
  assign devid_rdata[ 7: 0]  = 8'h00 /* number of ASICCTL bits implemented */;


//------------------------------------------------------------------
// DEVID2 register
//       - read-only
//------------------------------------------------------------------
  assign devid2_rdata_valid  = (paddrdbg_i == `CA53_CTI_DEVID2_ADD);
  assign devid2_rdata[31:0]  = 32'h00000000;


//------------------------------------------------------------------
// DEVID1 register
//       - read-only
//------------------------------------------------------------------
  assign devid1_rdata_valid  = (paddrdbg_i == `CA53_CTI_DEVID1_ADD);
  assign devid1_rdata[31:0]  = 32'h00000000;


//------------------------------------------------------------------
// DEVTYPE register
//       - read-only
//------------------------------------------------------------------
  assign devtype_rdata_valid  = (paddrdbg_i == `CA53_CTI_DEVTYPE_ADD);
  assign devtype_rdata[31:0]  = { {24{1'b0}}, `CA53_CTI_DEVTYPE_VAL };


//------------------------------------------------------------------
// DEVARCH register
//       - read-only
//       - if not implemented, must RAZ
//------------------------------------------------------------------
  assign devarch_rdata_valid  = (paddrdbg_i == `CA53_CTI_DEVARCH_ADD);
  assign devarch_rdata[31:0]  = `CA53_CTI_DEVARCH_VAL;


//------------------------------------------------------------------
// TRIGINSTATUS register
//       - read-only
//------------------------------------------------------------------
  assign triginstatus_rdata_valid   = (paddrdbg_i == `CA53_CTI_TRIGINSTATUS_ADD);
  assign triginstatus_rdata[31:0]   = { {(32-ECT_TR_WIDTH){1'b0}} , ctitriginstatus_i  };


//------------------------------------------------------------------
// TRIGOUTSTATUS register
//       - read-only
//------------------------------------------------------------------
  assign trigoutstatus_rdata_valid  = (paddrdbg_i == `CA53_CTI_TRIGOUTSTATUS_ADD);
  assign trigoutstatus_rdata[31:0]  = { {(32-ECT_TR_WIDTH){1'b0}} , ctitrigoutstatus_i };


//------------------------------------------------------------------
// CHINSTATUS register
//       - read-only
//------------------------------------------------------------------
  assign chinstatus_rdata_valid     = (paddrdbg_i == `CA53_CTI_CHINSTATUS_ADD);
  assign chinstatus_rdata[31:0]     = { {(32-ECT_CH_WIDTH){1'b0}} , ctichinstatus_i  };


//------------------------------------------------------------------
// CHOUTSTATUS register
//       - read-only
//------------------------------------------------------------------
  assign choutstatus_rdata_valid    = (paddrdbg_i == `CA53_CTI_CHOUTSTATUS_ADD);
  assign choutstatus_rdata[31:0]    = { {(32-ECT_CH_WIDTH){1'b0}} , ctichoutstatus_i };


//------------------------------------------------------------------
// Bus interface read data
//       The bus interface read data is a big or-of-and structure
//       using the individual rdata_valid bits.
//------------------------------------------------------------------

  // 17 read data sources - keep in sync with OVL!
  assign prdatadbg      = ({32{map_rdata_valid_i}}          & map_rdata_i         ) |
                          ({32{lsr_rdata_valid}}            & lsr_rdata           ) |
                          ({32{it_itctrl_rdata_valid}}      & it_itctrl_rdata     ) |
                          ({32{glben_rdata_valid}}          & glben_rdata         ) |
                          ({32{ctigate_rdata_valid}}        & ctigate_rdata       ) |
                          ({32{apptrig_set_rdata_valid}}    & apptrig_set_rdata   ) |
                          ({32{claimtag_set_rdata_valid}}   & claimtag_set_rdata  ) |
                          ({32{claimtag_clr_rdata_valid}}   & claimtag_clr_rdata  ) |
                          ({32{devid_rdata_valid}}          & devid_rdata         ) |
                          ({32{devid2_rdata_valid}}         & devid2_rdata        ) |
                          ({32{devid1_rdata_valid}}         & devid1_rdata        ) |
                          ({32{devtype_rdata_valid}}        & devtype_rdata       ) |
                          ({32{devarch_rdata_valid}}        & devarch_rdata       ) |
                          ({32{triginstatus_rdata_valid}}   & triginstatus_rdata  ) |
                          ({32{trigoutstatus_rdata_valid}}  & trigoutstatus_rdata ) |
                          ({32{chinstatus_rdata_valid}}     & chinstatus_rdata    ) |
                          ({32{choutstatus_rdata_valid}}    & choutstatus_rdata   ) ;



`ifdef ARM_ASSERT_ON

  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------
  `include "std_ovl_defines.h"

  assert_zero_one_hot
     #(.severity_level(`OVL_FATAL), .property_type(`OVL_ASSERT), .width(17),
       .msg("apbif read enables are not zero or one hot"))
   u_ovl_rden_one_hot
     (.clk(clk), .reset_n(reset_n),
      .test_expr({15{bus_read}} & {map_rdata_valid_i, lsr_rdata_valid,
                  it_itctrl_rdata_valid, glben_rdata_valid,
                  ctigate_rdata_valid, apptrig_set_rdata_valid,
                  devid_rdata_valid, devid2_rdata_valid, devid1_rdata_valid,
                  devtype_rdata_valid, devarch_rdata_valid,
                  triginstatus_rdata_valid, trigoutstatus_rdata_valid,
                  chinstatus_rdata_valid, choutstatus_rdata_valid,
                  claimtag_set_rdata_valid, claimtag_clr_rdata_valid
      }));

  assert_zero_one_hot
     #(.severity_level(`OVL_FATAL), .property_type(`OVL_ASSERT), .width(10),
       .msg("apbif write enables are not zero or one hot"))
   u_ovl_wren_one_hot
     (.clk(clk), .reset_n(reset_n),
      .test_expr({lsr_slk_wren,
                  it_itctrl_wren, glben_wren, ctigate_wren,
                  apptrig_set_wren, apptrig_clr_wren, intack_wren,
                  apppulse_wren, claimtag_set_wren, claimtag_clr_wren
      }));

  assert_never
     #(.severity_level(`OVL_FATAL), .property_type(`OVL_ASSERT),
       .msg("apbif both apptrig setmask and clrmask have bits set!"))
   u_ovl_apptrig_mask_setclr_never
     (.clk(clk_cti), .reset_n(reset_n),
      .test_expr((apptrig_setmask_nxt & apptrig_clrmask_nxt) != 0));

`endif //  `ifdef ARM_ASSERT_ON


endmodule // ca53cti_apbif

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/

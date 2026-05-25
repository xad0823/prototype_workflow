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



module reset_controller_f1_fsm #(
  parameter SOC_RST_DLY   = 3'b111,
  parameter NUM_EXT_SYS   = 2
)

(
  input  wire                         clk,
  input  wire                         resetn,
  input  wire                         secenc_cae_rst_req,
  input  wire                         soc_wdog_rst_req,
  input  wire                         secenc_wdog_rst_req,
  input  wire                         cdbgrstreq_dp,
  input  wire                         soc_rst_req,
  input  wire                         secenc_sw_rst_req,
  input  wire                         nsrst,
  input  wire                         csysrstreq_dprom,
  input  wire                         host_sys_rst_req,
  input  wire [NUM_EXT_SYS-1:0]       extsys_rst_req,
  output wire                         aontopporesetn,
  output wire                         aontopwarmresetn,
  output wire                         secporesetn,
  output wire [NUM_EXT_SYS-1:0]       extsysporesetn,
  output wire                         cdbgrstack_dp,
  output wire                         csysrstack_dprom,
  output wire [1:0]                   host_sys_rst_ack,
  output wire [(NUM_EXT_SYS*2)-1:0]   extsys_rst_ack,
  output wire                         secenccpuwait,
  output wire [NUM_EXT_SYS-1:0]       extsyscpuwait,
  output wire [4:0]                   soc_rst_syn,
  output wire [3:0]                   host_rst_syn,
  output wire [(NUM_EXT_SYS*5)-1:0]   extsys_rst_syn,
  output wire [2:0]                   se_rst_syn,
  output wire                         aontoppo_aontopwarm_qreqn,
  input  wire                         aontoppo_aontopwarm_qacceptn,
  input  wire                         aontoppo_aontopwarm_qdeny,

  output wire                         secenc_hostsys_qreqn,
  input  wire                         secenc_hostsys_qacceptn, 
  input  wire                         secenc_hostsys_qdeny, 

  output wire [NUM_EXT_SYS-1:0]        extsys_hostsys_qreqn,
  input  wire [NUM_EXT_SYS-1:0]        extsys_hostsys_qacceptn,
  input  wire [NUM_EXT_SYS-1:0]        extsys_hostsys_qdeny

);

  localparam IDLE  = 3'b000; 
  localparam RESET  = 3'b001; 
  localparam RESET_ASSERT = 3'b010; 
  localparam WAIT_DEASSERT  = 3'b011; 
  localparam RESET_DEASSERT = 3'b100; 
  localparam WAIT_QACCEPT = 3'b101; 
  localparam Q_DENIED = 3'b110; 

  reg                         aontopporesetn_r;
  reg                         aontopwarmresetn_r;
  reg                         secporesetn_r;
  reg [NUM_EXT_SYS-1:0]       extsysporesetn_r;

  reg                         cdbgrstack_dp_r;
  reg                         csysrstack_dprom_r;
  reg [1:0]                   host_sys_rst_ack_r;

  reg                         secenccpuwait_r;

  reg                   reset_syndrome_poresetn_r;
  reg                   reset_syndrome_secenc_cae_rst_req_r;
  reg                   reset_syndrome_soc_wdog_rst_req_r;
  reg                   reset_syndrome_secenc_wdog_rst_req_r;
  reg                   reset_syndrome_cdbgrstreq_dp_r;
  reg                   reset_syndrome_soc_rst_req_r;
  reg                   reset_syndrome_secenc_sw_rst_req_r;
  reg                   reset_syndrome_nsrst_r;
  reg                   reset_syndrome_csysrstreq_dprom_r;
  reg                   reset_syndrome_host_sys_rst_req_r;
  
  reg [2:0]                   current_state_r;
  reg                         host_sys_rst_req_flag_r;
  reg [NUM_EXT_SYS-1:0]       extsys_rst_req_flag_r;
  reg [2:0]                   downcount_r;
  wire [3:0]                  extsys_rst_req_int;
  
generate 
  if(NUM_EXT_SYS < 4) begin : gen_padding_extsys_rst_req
    assign extsys_rst_req_int = {{(4-NUM_EXT_SYS){1'b0}}, extsys_rst_req};
  end else begin : gen_no_padding_extsys_rst_req
    assign extsys_rst_req_int = extsys_rst_req;
  end
endgenerate

  reg                    aontoppo_aontopwarm_qreqn_r;
  reg                    secenc_hostsys_qreqn_r;
  reg [NUM_EXT_SYS-1:0]  extsys_hostsys_qreqn_r;

  reg                    aontopporesetn_nxt;
  reg                    aontopwarmresetn_nxt;
  reg                    secporesetn_nxt;
  reg [NUM_EXT_SYS-1:0]  extsysporesetn_nxt;
  reg                    cdbgrstack_dp_nxt;
  reg                    csysrstack_dprom_nxt;
  reg [1:0]              host_sys_rst_ack_nxt;
  reg                    secenccpuwait_nxt;
  reg [NUM_EXT_SYS-1:0]  extsyscpuwait_nxt;
  reg [2:0]              state_nxt;
  reg [2:0]              downcount_nxt;
  reg                    host_sys_rst_req_flag_nxt;
  reg [NUM_EXT_SYS-1:0]  extsys_rst_req_flag_nxt;
  reg                    aontoppo_aontopwarm_qreqn_nxt;
  reg [NUM_EXT_SYS-1:0]  extsys_hostsys_qreqn_nxt;
  reg                    secenc_hostsys_qreqn_nxt;
  reg                   reset_syndrome_poresetn_r_nxt;
  reg                   reset_syndrome_secenc_cae_rst_req_r_nxt;
  reg                   reset_syndrome_soc_wdog_rst_req_r_nxt;
  reg                   reset_syndrome_secenc_wdog_rst_req_r_nxt;
  reg                   reset_syndrome_cdbgrstreq_dp_r_nxt;
  reg                   reset_syndrome_soc_rst_req_r_nxt;
  reg                   reset_syndrome_secenc_sw_rst_req_r_nxt;
  reg                   reset_syndrome_nsrst_r_nxt;
  reg                   reset_syndrome_csysrstreq_dprom_r_nxt;
  reg                   reset_syndrome_host_sys_rst_req_r_nxt;


  reg [3:0]  fsm_en_r;
  reg [3:0]  fsm_en_nxt;

  wire [NUM_EXT_SYS-1:0]   extsysfsm_extsysporesetn;
  wire [NUM_EXT_SYS-1:0]   extsysfsm_reset_syndrome_extsys_rst_req;

  reg [1:0]   reset_req_type_r;
  reg         cdbgrstreq_r;
  reg         secenc_wdog_rst_req_r;
  reg         secenc_cae_rst_req_r;
  reg         soc_wdog_rst_req_r;
  reg         soc_rst_req_r;
  reg         nsrst_r;
  reg         csysrstreq_dprom_r;
  reg         secenc_sw_rst_req_r;
  reg         host_sys_rst_req_r;

  reg         nsrst_nxt;
  reg         csysrstreq_dprom_nxt;
  reg         secenc_sw_rst_req_nxt;
  reg         host_sys_rst_req_nxt;
  reg [1:0]   reset_req_type_nxt;

  wire        aontop_qch_okay;
  wire        secenc_qch_okay;
  wire        aontop_qch_qstopped;
  wire        secenc_qch_qstopped;
  wire        extsys_qch_qstopped;
  wire        all_qch_qstopped;
  wire        unused;

  assign aontop_qch_okay = (((aontoppo_aontopwarm_qreqn & aontoppo_aontopwarm_qacceptn) | (~aontoppo_aontopwarm_qreqn & ~aontoppo_aontopwarm_qacceptn))& ~aontoppo_aontopwarm_qdeny);
  assign secenc_qch_okay = (((secenc_hostsys_qreqn & secenc_hostsys_qacceptn) | (~secenc_hostsys_qreqn & ~secenc_hostsys_qacceptn)) & ~secenc_hostsys_qdeny);

  assign aontop_qch_qstopped = (~aontoppo_aontopwarm_qreqn & ~aontoppo_aontopwarm_qacceptn & ~aontoppo_aontopwarm_qdeny);
  assign secenc_qch_qstopped = (~secenc_hostsys_qreqn      & ~secenc_hostsys_qacceptn      & ~secenc_hostsys_qdeny);
  assign extsys_qch_qstopped = (~(|(extsys_hostsys_qreqn)) & ~(|(extsys_hostsys_qacceptn)) & ~(|(extsys_hostsys_qdeny)));

  assign all_qch_qstopped    = aontop_qch_qstopped & secenc_qch_qstopped & extsys_qch_qstopped;



  always @(posedge clk or negedge resetn)
  begin
    if (~resetn)
    begin
      aontopporesetn_r                   <= 1'b0;
      aontopwarmresetn_r                 <= 1'b0;
      secporesetn_r                      <= 1'b0;
      extsysporesetn_r                   <= {NUM_EXT_SYS{1'b0}};

      cdbgrstack_dp_r                    <= 1'b0;
      csysrstack_dprom_r                 <= 1'b0;
      host_sys_rst_ack_r                 <= 2'b00;

      secenccpuwait_r                    <= 1'b0;

      aontoppo_aontopwarm_qreqn_r        <= 1'b0;
      secenc_hostsys_qreqn_r             <= 1'b0;
      extsys_hostsys_qreqn_r             <= {NUM_EXT_SYS{1'b0}};

      current_state_r                    <= RESET;
      downcount_r                        <= 3'h0;
      host_sys_rst_req_flag_r            <= 1'b0;
      reset_req_type_r                   <= 2'b00;
      nsrst_r                            <= 1'b1;
      csysrstreq_dprom_r                 <= 1'b0;
      secenc_sw_rst_req_r                <= 1'b0;
      host_sys_rst_req_r                 <= 1'b0;
      fsm_en_r                           <= {4{1'b0}};

      reset_syndrome_poresetn_r            <= 1'b1;
      reset_syndrome_secenc_cae_rst_req_r  <= 1'b0;
      reset_syndrome_soc_wdog_rst_req_r    <= 1'b0;
      reset_syndrome_secenc_wdog_rst_req_r <= 1'b0;
      reset_syndrome_cdbgrstreq_dp_r       <= 1'b0;
      reset_syndrome_soc_rst_req_r         <= 1'b0;
      reset_syndrome_secenc_sw_rst_req_r   <= 1'b0;
      reset_syndrome_nsrst_r               <= 1'b0;
      reset_syndrome_csysrstreq_dprom_r    <= 1'b0;
      reset_syndrome_host_sys_rst_req_r    <= 1'b0;
    end                                 
    else                               
    begin
      aontopporesetn_r                   <= aontopporesetn_nxt;
      aontopwarmresetn_r                 <= aontopwarmresetn_nxt;
      secporesetn_r                      <= secporesetn_nxt;
      extsysporesetn_r                   <= extsysporesetn_nxt;

      cdbgrstack_dp_r                    <= cdbgrstack_dp_nxt;
      csysrstack_dprom_r                 <= csysrstack_dprom_nxt;
      host_sys_rst_ack_r                 <= host_sys_rst_ack_nxt;

      secenccpuwait_r                    <= secenccpuwait_nxt;

      aontoppo_aontopwarm_qreqn_r        <= aontoppo_aontopwarm_qreqn_nxt;
      secenc_hostsys_qreqn_r             <= secenc_hostsys_qreqn_nxt;
      extsys_hostsys_qreqn_r             <= extsys_hostsys_qreqn_nxt;

      current_state_r                    <= state_nxt;
      downcount_r                        <= downcount_nxt;
      host_sys_rst_req_flag_r            <= host_sys_rst_req_flag_nxt;
      reset_req_type_r                   <= reset_req_type_nxt;
      nsrst_r                            <= nsrst_nxt;
      csysrstreq_dprom_r                 <= csysrstreq_dprom_nxt;
      secenc_sw_rst_req_r                <= secenc_sw_rst_req_nxt;
      host_sys_rst_req_r                 <= host_sys_rst_req_nxt;

      fsm_en_r                           <= fsm_en_nxt;

      reset_syndrome_poresetn_r            <= reset_syndrome_poresetn_r_nxt;
      reset_syndrome_secenc_cae_rst_req_r  <= reset_syndrome_secenc_cae_rst_req_r_nxt;
      reset_syndrome_soc_wdog_rst_req_r    <= reset_syndrome_soc_wdog_rst_req_r_nxt;
      reset_syndrome_secenc_wdog_rst_req_r <= reset_syndrome_secenc_wdog_rst_req_r_nxt;
      reset_syndrome_cdbgrstreq_dp_r       <= reset_syndrome_cdbgrstreq_dp_r_nxt;
      reset_syndrome_soc_rst_req_r         <= reset_syndrome_soc_rst_req_r_nxt;
      reset_syndrome_secenc_sw_rst_req_r   <= reset_syndrome_secenc_sw_rst_req_r_nxt;
      reset_syndrome_nsrst_r               <= reset_syndrome_nsrst_r_nxt;
      reset_syndrome_csysrstreq_dprom_r    <= reset_syndrome_csysrstreq_dprom_r_nxt;
      reset_syndrome_host_sys_rst_req_r    <= reset_syndrome_host_sys_rst_req_r_nxt;
    end
  end

  
  always @*
  begin
    case (current_state_r)
    IDLE: 
    begin
      if (soc_rst_req | secenc_wdog_rst_req | secenc_cae_rst_req | soc_wdog_rst_req | cdbgrstreq_dp)
      begin
          state_nxt = RESET_ASSERT;
      end
      else if (((secenc_sw_rst_req | ~nsrst | csysrstreq_dprom) & (aontop_qch_okay)) | (host_sys_rst_req & ~host_sys_rst_req_flag_r & (aontop_qch_okay & secenc_qch_okay)))
      begin
        state_nxt = WAIT_QACCEPT;
      end
      else
      begin
        state_nxt = current_state_r;
      end
      
      if ((state_nxt == RESET_ASSERT))
      begin
        aontopporesetn_nxt = 1'b0;
        aontopwarmresetn_nxt = 1'b0;
        secporesetn_nxt = 1'b0;
        extsysporesetn_nxt = {NUM_EXT_SYS{1'b0}};

        cdbgrstack_dp_nxt  = 1'b0;
        csysrstack_dprom_nxt  = 1'b0;
        host_sys_rst_ack_nxt = 2'b00;

        secenccpuwait_nxt  = 1'b0;

        aontoppo_aontopwarm_qreqn_nxt = 1'b0;
        secenc_hostsys_qreqn_nxt = 1'b0;
        extsys_hostsys_qreqn_nxt = {NUM_EXT_SYS{1'b0}};

        downcount_nxt      = 3'h0;
        host_sys_rst_req_flag_nxt = host_sys_rst_req_flag_r ? host_sys_rst_req : host_sys_rst_req_flag_r;
        reset_req_type_nxt = 2'b00;
        nsrst_nxt = 1'b1;
        csysrstreq_dprom_nxt = 1'b0;
        secenc_sw_rst_req_nxt = 1'b0;
        host_sys_rst_req_nxt = 1'b0;
        fsm_en_nxt = {4{1'b0}};

        reset_syndrome_poresetn_r_nxt = 1'b0;
        reset_syndrome_secenc_cae_rst_req_r_nxt = (secenc_cae_rst_req) ? 1'b1 : 1'b0;
        reset_syndrome_soc_wdog_rst_req_r_nxt = (~secenc_cae_rst_req & soc_wdog_rst_req) ? 1'b1 : 1'b0;
        reset_syndrome_secenc_wdog_rst_req_r_nxt = (~secenc_cae_rst_req & ~soc_wdog_rst_req & secenc_wdog_rst_req) ? 1'b1 : 1'b0;
        reset_syndrome_cdbgrstreq_dp_r_nxt = (~secenc_cae_rst_req & ~soc_wdog_rst_req & ~secenc_wdog_rst_req & cdbgrstreq_dp) ? 1'b1 : 1'b0;
        reset_syndrome_soc_rst_req_r_nxt = (~secenc_cae_rst_req & ~soc_wdog_rst_req & ~secenc_wdog_rst_req & ~cdbgrstreq_dp & soc_rst_req) ? 1'b1 : 1'b0;
        reset_syndrome_secenc_sw_rst_req_r_nxt = 1'b0;
        reset_syndrome_nsrst_r_nxt = 1'b0;
        reset_syndrome_csysrstreq_dprom_r_nxt = 1'b0;
        reset_syndrome_host_sys_rst_req_r_nxt = 1'b0;
      end
      else if (state_nxt == WAIT_QACCEPT)
      begin
        aontopporesetn_nxt = aontopporesetn_r;
        aontopwarmresetn_nxt = aontopwarmresetn_r;
        secporesetn_nxt = secporesetn_r;
        extsysporesetn_nxt = extsysporesetn_r;

        cdbgrstack_dp_nxt = 1'b0;
        csysrstack_dprom_nxt = 1'b0;
        host_sys_rst_ack_nxt = host_sys_rst_req_flag_r & host_sys_rst_req ? 2'b01 : 2'b00;

        secenccpuwait_nxt = 1'b0;

        aontoppo_aontopwarm_qreqn_nxt = 1'b0;
        secenc_hostsys_qreqn_nxt = (~(secenc_sw_rst_req | ~nsrst | csysrstreq_dprom ) & (host_sys_rst_req & ~host_sys_rst_req_flag_r)) ? 1'b0 : 1'b1;
        extsys_hostsys_qreqn_nxt = extsys_hostsys_qreqn_r;

        downcount_nxt = downcount_r;
        host_sys_rst_req_flag_nxt = host_sys_rst_req_flag_r ? host_sys_rst_req : host_sys_rst_req_flag_r;
        reset_req_type_nxt = (secenc_sw_rst_req | ~nsrst | csysrstreq_dprom) ? 2'b01 : 2'b10;
        nsrst_nxt = nsrst;
        csysrstreq_dprom_nxt = csysrstreq_dprom;
        secenc_sw_rst_req_nxt = secenc_sw_rst_req;
        host_sys_rst_req_nxt = host_sys_rst_req;
        fsm_en_nxt = fsm_en_r;

        reset_syndrome_poresetn_r_nxt = reset_syndrome_poresetn_r; 
        reset_syndrome_secenc_cae_rst_req_r_nxt = reset_syndrome_secenc_cae_rst_req_r;
        reset_syndrome_soc_wdog_rst_req_r_nxt = reset_syndrome_soc_wdog_rst_req_r;
        reset_syndrome_secenc_wdog_rst_req_r_nxt = reset_syndrome_secenc_wdog_rst_req_r;
        reset_syndrome_cdbgrstreq_dp_r_nxt = reset_syndrome_cdbgrstreq_dp_r;
        reset_syndrome_soc_rst_req_r_nxt = reset_syndrome_soc_rst_req_r;
        reset_syndrome_secenc_sw_rst_req_r_nxt = reset_syndrome_secenc_sw_rst_req_r;
        reset_syndrome_nsrst_r_nxt = reset_syndrome_nsrst_r;
        reset_syndrome_csysrstreq_dprom_r_nxt = reset_syndrome_csysrstreq_dprom_r;
        reset_syndrome_host_sys_rst_req_r_nxt = reset_syndrome_host_sys_rst_req_r;
      end
      else
      begin
        aontopporesetn_nxt = aontopporesetn_r;
        aontopwarmresetn_nxt = aontopwarmresetn_r;
        secporesetn_nxt = secporesetn_r;
        extsysporesetn_nxt = extsysporesetn_r;

        cdbgrstack_dp_nxt = 1'b0;
        csysrstack_dprom_nxt = 1'b0;
        host_sys_rst_ack_nxt = (host_sys_rst_req_flag_r & ~host_sys_rst_req) ? 2'b00 : host_sys_rst_ack_r;

        secenccpuwait_nxt = 1'b0;

        aontoppo_aontopwarm_qreqn_nxt = 1'b1;
        secenc_hostsys_qreqn_nxt = 1'b1;
        extsys_hostsys_qreqn_nxt = {NUM_EXT_SYS{1'b1}};

        downcount_nxt = 3'h0;
        host_sys_rst_req_flag_nxt = host_sys_rst_req_flag_r ? host_sys_rst_req : host_sys_rst_req_flag_r;
        reset_req_type_nxt = reset_req_type_r;
        nsrst_nxt = 1'b1;
        csysrstreq_dprom_nxt = 1'b0;
        secenc_sw_rst_req_nxt = 1'b0;
        host_sys_rst_req_nxt = 1'b0;
        fsm_en_nxt[0] = ~fsm_en_r[0] ? extsys_rst_req_int[0] : fsm_en_r[0];
        if(NUM_EXT_SYS > 1) begin
          fsm_en_nxt[1] = ~fsm_en_r[1] ? extsys_rst_req_int[1] : fsm_en_r[1];
        end else begin
          fsm_en_nxt[1] = 1'b0;
        end
        if(NUM_EXT_SYS > 2) begin
          fsm_en_nxt[2] = ~fsm_en_r[2] ? extsys_rst_req_int[2] : fsm_en_r[2];
        end else begin
          fsm_en_nxt[2] = 1'b0;
        end
        if(NUM_EXT_SYS > 3) begin
          fsm_en_nxt[3] = ~fsm_en_r[3] ? extsys_rst_req_int[3] : fsm_en_r[3];
        end else begin
          fsm_en_nxt[3] = 1'b0;
        end

        reset_syndrome_poresetn_r_nxt = reset_syndrome_poresetn_r; 
        reset_syndrome_secenc_cae_rst_req_r_nxt = reset_syndrome_secenc_cae_rst_req_r;
        reset_syndrome_soc_wdog_rst_req_r_nxt = reset_syndrome_soc_wdog_rst_req_r;
        reset_syndrome_secenc_wdog_rst_req_r_nxt = reset_syndrome_secenc_wdog_rst_req_r;
        reset_syndrome_cdbgrstreq_dp_r_nxt = reset_syndrome_cdbgrstreq_dp_r;
        reset_syndrome_soc_rst_req_r_nxt = reset_syndrome_soc_rst_req_r;
        reset_syndrome_secenc_sw_rst_req_r_nxt = reset_syndrome_secenc_sw_rst_req_r;
        reset_syndrome_nsrst_r_nxt = reset_syndrome_nsrst_r;
        reset_syndrome_csysrstreq_dprom_r_nxt = reset_syndrome_csysrstreq_dprom_r;
        reset_syndrome_host_sys_rst_req_r_nxt = reset_syndrome_host_sys_rst_req_r;
      end
    end 

    RESET:
    begin
      state_nxt = WAIT_DEASSERT;

      aontopporesetn_nxt = 1'b0;
      aontopwarmresetn_nxt = 1'b0;
      secporesetn_nxt = 1'b0;
      extsysporesetn_nxt = {NUM_EXT_SYS{1'b0}};

      cdbgrstack_dp_nxt  = 1'b0;
      csysrstack_dprom_nxt = 1'b0;
      host_sys_rst_ack_nxt = 2'b00;

      secenccpuwait_nxt  = 1'b0;

      aontoppo_aontopwarm_qreqn_nxt = 1'b0;
      secenc_hostsys_qreqn_nxt = 1'b0;
      extsys_hostsys_qreqn_nxt = {NUM_EXT_SYS{1'b0}};

      downcount_nxt      = SOC_RST_DLY[2:0];
      host_sys_rst_req_flag_nxt = 1'b0;
      reset_req_type_nxt = 2'b00;
      nsrst_nxt = 1'b1;
      csysrstreq_dprom_nxt = 1'b0;
      secenc_sw_rst_req_nxt = 1'b0;
      host_sys_rst_req_nxt = 1'b0;
      fsm_en_nxt = {4{1'b0}};

      reset_syndrome_poresetn_r_nxt = reset_syndrome_poresetn_r; 
      reset_syndrome_secenc_cae_rst_req_r_nxt = reset_syndrome_secenc_cae_rst_req_r;
      reset_syndrome_soc_wdog_rst_req_r_nxt = reset_syndrome_soc_wdog_rst_req_r;
      reset_syndrome_secenc_wdog_rst_req_r_nxt = reset_syndrome_secenc_wdog_rst_req_r;
      reset_syndrome_cdbgrstreq_dp_r_nxt = reset_syndrome_cdbgrstreq_dp_r;
      reset_syndrome_soc_rst_req_r_nxt = reset_syndrome_soc_rst_req_r;
      reset_syndrome_secenc_sw_rst_req_r_nxt = reset_syndrome_secenc_sw_rst_req_r;
      reset_syndrome_nsrst_r_nxt = reset_syndrome_nsrst_r;
      reset_syndrome_csysrstreq_dprom_r_nxt = reset_syndrome_csysrstreq_dprom_r;
      reset_syndrome_host_sys_rst_req_r_nxt = reset_syndrome_host_sys_rst_req_r;
    end 

    WAIT_DEASSERT:
    begin
      downcount_nxt = (downcount_r > 3'h0) ? (downcount_r - 3'b001) : 3'h0;

      if ((reset_syndrome_secenc_sw_rst_req_r | reset_syndrome_nsrst_r | reset_syndrome_csysrstreq_dprom_r | reset_syndrome_host_sys_rst_req_r) & (soc_rst_req | secenc_wdog_rst_req | secenc_cae_rst_req | soc_wdog_rst_req | cdbgrstreq_dp)) 
      begin
          state_nxt = RESET_ASSERT;
      end
      else if ((reset_syndrome_csysrstreq_dprom_r & (downcount_nxt != 3'b000) & (secenc_sw_rst_req | ~nsrst)) | (reset_syndrome_nsrst_r & secenc_sw_rst_req & (downcount_nxt != 3'b000)) | (reset_syndrome_host_sys_rst_req_r & (secenc_sw_rst_req | ~nsrst | csysrstreq_dprom)))
      begin
        state_nxt = RESET_ASSERT;
      end
      else
      begin
        state_nxt = ((downcount_nxt == 3'h0) & (
                    (reset_syndrome_poresetn_r & all_qch_qstopped) | 
                    (reset_syndrome_secenc_cae_rst_req_r & ~secenc_cae_rst_req & all_qch_qstopped) | 
                    (reset_syndrome_soc_wdog_rst_req_r & ~soc_wdog_rst_req & all_qch_qstopped) | 
                    (reset_syndrome_secenc_wdog_rst_req_r & ~secenc_wdog_rst_req & all_qch_qstopped) | 
                    (reset_syndrome_cdbgrstreq_dp_r & ~cdbgrstreq_dp & all_qch_qstopped) | 
                    (reset_syndrome_soc_rst_req_r & ~soc_rst_req & all_qch_qstopped) | 
                    (reset_syndrome_secenc_sw_rst_req_r & ~secenc_sw_rst_req & all_qch_qstopped) | 
                    (reset_syndrome_nsrst_r & nsrst & (all_qch_qstopped | (aontoppo_aontopwarm_qreqn & secenc_hostsys_qreqn & (&extsys_hostsys_qreqn)))) | 
                    (reset_syndrome_csysrstreq_dprom_r & ~csysrstreq_dprom & (all_qch_qstopped | (aontoppo_aontopwarm_qreqn & secenc_hostsys_qreqn & (&extsys_hostsys_qreqn)))) | 
                    (reset_syndrome_host_sys_rst_req_r & ~host_sys_rst_req & all_qch_qstopped)
                    )) ? RESET_DEASSERT : WAIT_DEASSERT;
      end

      if (state_nxt == RESET_ASSERT)
      begin
        aontopporesetn_nxt = (soc_rst_req | secenc_wdog_rst_req | secenc_cae_rst_req | soc_wdog_rst_req | cdbgrstreq_dp) ? 1'b0 : 1'b1;
        aontopwarmresetn_nxt = 1'b0;
        secporesetn_nxt = 1'b0;
        extsysporesetn_nxt = {NUM_EXT_SYS{1'b0}};

        cdbgrstack_dp_nxt = 1'b0;
        csysrstack_dprom_nxt = 1'b0;
        host_sys_rst_ack_nxt = 2'b00;

        secenccpuwait_nxt = ((~soc_wdog_rst_req & ~secenc_wdog_rst_req & ~secenc_cae_rst_req & ~cdbgrstreq_dp & ~soc_rst_req & ~secenc_sw_rst_req) & (~nsrst | csysrstreq_dprom)) ? 1'b1 : 1'b0;

        aontoppo_aontopwarm_qreqn_nxt = 1'b0;
        secenc_hostsys_qreqn_nxt = 1'b0;
        extsys_hostsys_qreqn_nxt = {NUM_EXT_SYS{1'b0}};

        host_sys_rst_req_flag_nxt = host_sys_rst_req_flag_r ? host_sys_rst_req : host_sys_rst_req_flag_r;
        reset_req_type_nxt = (soc_rst_req | secenc_wdog_rst_req | secenc_cae_rst_req | soc_wdog_rst_req | cdbgrstreq_dp) ? 2'b00 : 2'b01;
        nsrst_nxt = 1'b1;
        csysrstreq_dprom_nxt = 1'b0;
        secenc_sw_rst_req_nxt = 1'b0;
        host_sys_rst_req_nxt = 1'b0;
        fsm_en_nxt = {4{1'b0}};

        reset_syndrome_poresetn_r_nxt = 1'b0;
        reset_syndrome_secenc_cae_rst_req_r_nxt = (secenc_cae_rst_req) ? 1'b1 : 1'b0;
        reset_syndrome_soc_wdog_rst_req_r_nxt = (~secenc_cae_rst_req & soc_wdog_rst_req) ? 1'b1 : 1'b0; 
        reset_syndrome_secenc_wdog_rst_req_r_nxt = (~secenc_cae_rst_req & ~soc_wdog_rst_req & secenc_wdog_rst_req) ? 1'b1 : 1'b0;
        reset_syndrome_cdbgrstreq_dp_r_nxt = (~secenc_cae_rst_req & ~soc_wdog_rst_req & ~secenc_wdog_rst_req & cdbgrstreq_dp) ? 1'b1 : 1'b0;
        reset_syndrome_soc_rst_req_r_nxt = (~secenc_cae_rst_req & ~soc_wdog_rst_req & ~secenc_wdog_rst_req & ~cdbgrstreq_dp & soc_rst_req) ? 1'b1 : 1'b0;
        reset_syndrome_secenc_sw_rst_req_r_nxt = (~secenc_cae_rst_req & ~soc_wdog_rst_req & ~secenc_wdog_rst_req & ~cdbgrstreq_dp & ~soc_rst_req & secenc_sw_rst_req) ? 1'b1: 1'b0;
        reset_syndrome_nsrst_r_nxt = (~secenc_cae_rst_req & ~soc_wdog_rst_req & ~secenc_wdog_rst_req & ~cdbgrstreq_dp & ~soc_rst_req & ~secenc_sw_rst_req & ~nsrst) ? 1'b1 : 1'b0;
        reset_syndrome_csysrstreq_dprom_r_nxt = (~secenc_cae_rst_req & ~soc_wdog_rst_req & ~secenc_wdog_rst_req & ~cdbgrstreq_dp & ~soc_rst_req & ~secenc_sw_rst_req & nsrst & csysrstreq_dprom) ? 1'b1 : 1'b0;
        reset_syndrome_host_sys_rst_req_r_nxt = 1'b0;
      end
      else if (state_nxt == RESET_DEASSERT)
      begin
        aontopporesetn_nxt = 1'b1;
        aontopwarmresetn_nxt = 1'b1;
        secporesetn_nxt = 1'b1;
        extsysporesetn_nxt = {NUM_EXT_SYS{1'b1}};

        cdbgrstack_dp_nxt = 1'b0;
        csysrstack_dprom_nxt = 1'b0;
        host_sys_rst_ack_nxt = 2'b00;

        secenccpuwait_nxt = 1'b0;

        aontoppo_aontopwarm_qreqn_nxt = 1'b1;
        secenc_hostsys_qreqn_nxt = 1'b1;
        extsys_hostsys_qreqn_nxt = {NUM_EXT_SYS{1'b1}};

        host_sys_rst_req_flag_nxt = host_sys_rst_req_flag_r ? host_sys_rst_req : host_sys_rst_req_flag_r;
        reset_req_type_nxt = reset_req_type_r;
        nsrst_nxt = 1'b1;
        csysrstreq_dprom_nxt = 1'b0;
        secenc_sw_rst_req_nxt = 1'b0;
        host_sys_rst_req_nxt = 1'b0;
        fsm_en_nxt = fsm_en_r;

        reset_syndrome_poresetn_r_nxt = reset_syndrome_poresetn_r; 
        reset_syndrome_secenc_cae_rst_req_r_nxt = reset_syndrome_secenc_cae_rst_req_r;
        reset_syndrome_soc_wdog_rst_req_r_nxt = reset_syndrome_soc_wdog_rst_req_r;
        reset_syndrome_secenc_wdog_rst_req_r_nxt = reset_syndrome_secenc_wdog_rst_req_r;
        reset_syndrome_cdbgrstreq_dp_r_nxt = reset_syndrome_cdbgrstreq_dp_r;
        reset_syndrome_soc_rst_req_r_nxt = reset_syndrome_soc_rst_req_r;
        reset_syndrome_secenc_sw_rst_req_r_nxt = reset_syndrome_secenc_sw_rst_req_r;
        reset_syndrome_nsrst_r_nxt = reset_syndrome_nsrst_r;
        reset_syndrome_csysrstreq_dprom_r_nxt = reset_syndrome_csysrstreq_dprom_r;
        reset_syndrome_host_sys_rst_req_r_nxt =  reset_syndrome_host_sys_rst_req_r;
      end
      else
      begin
        aontopporesetn_nxt = aontopporesetn_r;
        aontopwarmresetn_nxt = ((downcount_nxt == 3'h0) & (reset_syndrome_nsrst_r | reset_syndrome_csysrstreq_dprom_r)) ? 1'b1 : aontopwarmresetn_r;
        secporesetn_nxt = ((downcount_nxt == 3'h0) & (reset_syndrome_nsrst_r |reset_syndrome_csysrstreq_dprom_r)) ? 1'b1 : secporesetn_r;
        extsysporesetn_nxt = ((downcount_nxt == 3'h0) & (reset_syndrome_nsrst_r |reset_syndrome_csysrstreq_dprom_r)) ? {NUM_EXT_SYS{1'b1}} : extsysporesetn_r;

        cdbgrstack_dp_nxt  = ((downcount_nxt == 3'h0) & reset_syndrome_cdbgrstreq_dp_r) ? 1'b1 : 1'b0;
        csysrstack_dprom_nxt = ((downcount_r == 3'b0) & reset_syndrome_csysrstreq_dprom_r) ? 1'b1 : 1'b0; 
        host_sys_rst_ack_nxt = ((downcount_nxt == 3'h0) & reset_syndrome_host_sys_rst_req_r) ? 2'b10 : 2'b00;

        secenccpuwait_nxt  = ((downcount_nxt == 3'h0) & ((reset_syndrome_nsrst_r & nsrst) | (reset_syndrome_csysrstreq_dprom_r & ~csysrstreq_dprom))) ? 1'b0 : secenccpuwait_r;

        aontoppo_aontopwarm_qreqn_nxt = ((downcount_nxt == 3'h0) & (reset_syndrome_nsrst_r | reset_syndrome_csysrstreq_dprom_r) & aontop_qch_qstopped) ? 1'b1 : aontoppo_aontopwarm_qreqn_r;
        secenc_hostsys_qreqn_nxt = ((downcount_nxt == 3'h0) & (reset_syndrome_nsrst_r | reset_syndrome_csysrstreq_dprom_r) & secenc_qch_qstopped) ? 1'b1 : secenc_hostsys_qreqn_r;
        extsys_hostsys_qreqn_nxt = ((downcount_nxt == 3'h0) & (reset_syndrome_nsrst_r | reset_syndrome_csysrstreq_dprom_r) & extsys_qch_qstopped) ? {NUM_EXT_SYS{1'b1}} : extsys_hostsys_qreqn_r;
        host_sys_rst_req_flag_nxt = host_sys_rst_req_flag_r ? host_sys_rst_req : host_sys_rst_req_flag_r;
        reset_req_type_nxt = reset_req_type_r;
        nsrst_nxt = 1'b1;
        csysrstreq_dprom_nxt = 1'b0;
        secenc_sw_rst_req_nxt = 1'b0;
        host_sys_rst_req_nxt = 1'b0;
        fsm_en_nxt = fsm_en_r;

        reset_syndrome_poresetn_r_nxt = reset_syndrome_poresetn_r; 
        reset_syndrome_secenc_cae_rst_req_r_nxt = reset_syndrome_secenc_cae_rst_req_r;
        reset_syndrome_soc_wdog_rst_req_r_nxt = reset_syndrome_soc_wdog_rst_req_r;
        reset_syndrome_secenc_wdog_rst_req_r_nxt = reset_syndrome_secenc_wdog_rst_req_r;
        reset_syndrome_cdbgrstreq_dp_r_nxt = reset_syndrome_cdbgrstreq_dp_r;
        reset_syndrome_soc_rst_req_r_nxt = reset_syndrome_soc_rst_req_r;
        reset_syndrome_secenc_sw_rst_req_r_nxt = reset_syndrome_secenc_sw_rst_req_r;
        reset_syndrome_nsrst_r_nxt = reset_syndrome_nsrst_r;
        reset_syndrome_csysrstreq_dprom_r_nxt = reset_syndrome_csysrstreq_dprom_r;
        reset_syndrome_host_sys_rst_req_r_nxt =  reset_syndrome_host_sys_rst_req_r;
      end
    end 

    RESET_DEASSERT:
    begin
      downcount_nxt = downcount_r;

      state_nxt = (soc_rst_req | secenc_wdog_rst_req | secenc_cae_rst_req | soc_wdog_rst_req | cdbgrstreq_dp) ? RESET_ASSERT : 
                  (((secenc_sw_rst_req | ~nsrst | csysrstreq_dprom) & aontop_qch_okay)
                  | (host_sys_rst_req & ~host_sys_rst_req_flag_r & (aontop_qch_okay & secenc_qch_okay))) ? WAIT_QACCEPT : IDLE ;

      if (state_nxt == RESET_ASSERT)
      begin
        aontopporesetn_nxt = 1'b0;
        aontopwarmresetn_nxt = 1'b0;
        secporesetn_nxt = 1'b0;
        extsysporesetn_nxt = {NUM_EXT_SYS{1'b0}};

        cdbgrstack_dp_nxt  = 1'b0;
        csysrstack_dprom_nxt = 1'b0;
        host_sys_rst_ack_nxt = 2'b00;

        secenccpuwait_nxt  = 1'b0;

        aontoppo_aontopwarm_qreqn_nxt = 1'b0;
        secenc_hostsys_qreqn_nxt = 1'b0;
        extsys_hostsys_qreqn_nxt = {NUM_EXT_SYS{1'b0}};

        host_sys_rst_req_flag_nxt = host_sys_rst_req_flag_r ? host_sys_rst_req : host_sys_rst_req_flag_r;
        reset_req_type_nxt = 2'b00;
        nsrst_nxt = 1'b1;
        csysrstreq_dprom_nxt = 1'b0;
        secenc_sw_rst_req_nxt = 1'b0;
        host_sys_rst_req_nxt = 1'b0;
        fsm_en_nxt = {4{1'b0}};

        reset_syndrome_poresetn_r_nxt = 1'b0;
        reset_syndrome_secenc_cae_rst_req_r_nxt = (secenc_cae_rst_req) ? 1'b1 : 1'b0;
        reset_syndrome_soc_wdog_rst_req_r_nxt = (~secenc_cae_rst_req & soc_wdog_rst_req) ? 1'b1 : 1'b0;
        reset_syndrome_secenc_wdog_rst_req_r_nxt = (~secenc_cae_rst_req & ~soc_wdog_rst_req & secenc_wdog_rst_req) ? 1'b1 : 1'b0;
        reset_syndrome_cdbgrstreq_dp_r_nxt = (~secenc_cae_rst_req & ~soc_wdog_rst_req & ~secenc_wdog_rst_req & cdbgrstreq_dp) ? 1'b1 : 1'b0;
        reset_syndrome_soc_rst_req_r_nxt = (~secenc_cae_rst_req & ~soc_wdog_rst_req & ~secenc_wdog_rst_req & ~cdbgrstreq_dp & soc_rst_req) ? 1'b1 : 1'b0;
        reset_syndrome_secenc_sw_rst_req_r_nxt = 1'b0;
        reset_syndrome_nsrst_r_nxt = 1'b0;
        reset_syndrome_csysrstreq_dprom_r_nxt = 1'b0;
        reset_syndrome_host_sys_rst_req_r_nxt =  1'b0;
      end
      else if (state_nxt == WAIT_QACCEPT)
      begin
        aontopporesetn_nxt = aontopporesetn_r;
        aontopwarmresetn_nxt = aontopwarmresetn_r;
        secporesetn_nxt = secporesetn_r;
        extsysporesetn_nxt = extsysporesetn_r;

        cdbgrstack_dp_nxt = 1'b0;
        csysrstack_dprom_nxt = 1'b0;
        host_sys_rst_ack_nxt = 2'b00;

        secenccpuwait_nxt = 1'b0;

        aontoppo_aontopwarm_qreqn_nxt = 1'b0;
        secenc_hostsys_qreqn_nxt = (~(secenc_sw_rst_req | ~nsrst | csysrstreq_dprom) & host_sys_rst_req) ? 1'b0 : 1'b1;
        extsys_hostsys_qreqn_nxt = {NUM_EXT_SYS{1'b1}};

        host_sys_rst_req_flag_nxt = host_sys_rst_req_flag_r ? host_sys_rst_req : host_sys_rst_req_flag_r;
        reset_req_type_nxt = (secenc_sw_rst_req | ~nsrst | csysrstreq_dprom) ? 2'b01 : 2'b10;
        nsrst_nxt = nsrst;
        csysrstreq_dprom_nxt = csysrstreq_dprom;
        secenc_sw_rst_req_nxt = secenc_sw_rst_req;
        host_sys_rst_req_nxt = host_sys_rst_req;
        fsm_en_nxt = fsm_en_r;

        reset_syndrome_poresetn_r_nxt = reset_syndrome_poresetn_r; 
        reset_syndrome_secenc_cae_rst_req_r_nxt = reset_syndrome_secenc_cae_rst_req_r;
        reset_syndrome_soc_wdog_rst_req_r_nxt = reset_syndrome_soc_wdog_rst_req_r;
        reset_syndrome_secenc_wdog_rst_req_r_nxt = reset_syndrome_secenc_wdog_rst_req_r;
        reset_syndrome_cdbgrstreq_dp_r_nxt = reset_syndrome_cdbgrstreq_dp_r;
        reset_syndrome_soc_rst_req_r_nxt = reset_syndrome_soc_rst_req_r;
        reset_syndrome_secenc_sw_rst_req_r_nxt = reset_syndrome_secenc_sw_rst_req_r;
        reset_syndrome_nsrst_r_nxt = reset_syndrome_nsrst_r;
        reset_syndrome_csysrstreq_dprom_r_nxt = reset_syndrome_csysrstreq_dprom_r;
        reset_syndrome_host_sys_rst_req_r_nxt =  reset_syndrome_host_sys_rst_req_r;
      end
      else
      begin
        aontopporesetn_nxt = 1'b1;
        aontopwarmresetn_nxt = 1'b1;
        secporesetn_nxt = 1'b1;
        extsysporesetn_nxt = {NUM_EXT_SYS{1'b1}};

        cdbgrstack_dp_nxt  = 1'b0;
        csysrstack_dprom_nxt = 1'b0;
        host_sys_rst_ack_nxt = (~host_sys_rst_req & host_sys_rst_req_flag_r) ? 2'b00 : host_sys_rst_ack_r;

        secenccpuwait_nxt  = 1'b0;

        aontoppo_aontopwarm_qreqn_nxt = 1'b1;
        secenc_hostsys_qreqn_nxt = 1'b1;
        extsys_hostsys_qreqn_nxt = {NUM_EXT_SYS{1'b1}};

        host_sys_rst_req_flag_nxt = host_sys_rst_req_flag_r ? host_sys_rst_req : host_sys_rst_req_flag_r;
        reset_req_type_nxt = reset_req_type_r;
        nsrst_nxt = 1'b1;
        csysrstreq_dprom_nxt = 1'b0;
        secenc_sw_rst_req_nxt = 1'b0;
        host_sys_rst_req_nxt = 1'b0;
        
        fsm_en_nxt[0] = ((~soc_wdog_rst_req & ~secenc_wdog_rst_req & ~secenc_cae_rst_req & ~cdbgrstreq_dp & ~soc_rst_req & ~secenc_sw_rst_req & nsrst & ~csysrstreq_dprom & ~host_sys_rst_req) & extsys_rst_req_int[0]);
        if(NUM_EXT_SYS > 1) begin 
          fsm_en_nxt[1] = ((~soc_wdog_rst_req & ~secenc_wdog_rst_req & ~secenc_cae_rst_req & ~cdbgrstreq_dp & ~soc_rst_req & ~secenc_sw_rst_req & nsrst & ~csysrstreq_dprom & ~host_sys_rst_req) & extsys_rst_req_int[1]);
        end else begin 
          fsm_en_nxt[1] = 1'b0;
        end
        if(NUM_EXT_SYS > 2) begin 
          fsm_en_nxt[2] = ((~soc_wdog_rst_req & ~secenc_wdog_rst_req & ~secenc_cae_rst_req & ~cdbgrstreq_dp & ~soc_rst_req & ~secenc_sw_rst_req & nsrst & ~csysrstreq_dprom & ~host_sys_rst_req) & extsys_rst_req_int[2]);
        end else begin 
          fsm_en_nxt[2] = 1'b0;
        end
        if(NUM_EXT_SYS > 3) begin 
          fsm_en_nxt[3] = ((~soc_wdog_rst_req & ~secenc_wdog_rst_req & ~secenc_cae_rst_req & ~cdbgrstreq_dp & ~soc_rst_req & ~secenc_sw_rst_req & nsrst & ~csysrstreq_dprom & ~host_sys_rst_req) & extsys_rst_req_int[3]);
        end else begin 
          fsm_en_nxt[3] = 1'b0;
        end
        
        reset_syndrome_poresetn_r_nxt = reset_syndrome_poresetn_r; 
        reset_syndrome_secenc_cae_rst_req_r_nxt = reset_syndrome_secenc_cae_rst_req_r;
        reset_syndrome_soc_wdog_rst_req_r_nxt = reset_syndrome_soc_wdog_rst_req_r;
        reset_syndrome_secenc_wdog_rst_req_r_nxt = reset_syndrome_secenc_wdog_rst_req_r;
        reset_syndrome_cdbgrstreq_dp_r_nxt = reset_syndrome_cdbgrstreq_dp_r;
        reset_syndrome_soc_rst_req_r_nxt = reset_syndrome_soc_rst_req_r;
        reset_syndrome_secenc_sw_rst_req_r_nxt = reset_syndrome_secenc_sw_rst_req_r;
        reset_syndrome_nsrst_r_nxt = reset_syndrome_nsrst_r;
        reset_syndrome_csysrstreq_dprom_r_nxt = reset_syndrome_csysrstreq_dprom_r;
        reset_syndrome_host_sys_rst_req_r_nxt =  reset_syndrome_host_sys_rst_req_r;
      end
    end 

    RESET_ASSERT:
    begin
      if ((reset_syndrome_secenc_sw_rst_req_r | reset_syndrome_nsrst_r | reset_syndrome_csysrstreq_dprom_r | reset_syndrome_host_sys_rst_req_r) & (soc_rst_req | secenc_wdog_rst_req | secenc_cae_rst_req | soc_wdog_rst_req | cdbgrstreq_dp))
      begin
        state_nxt = RESET_ASSERT;

        downcount_nxt = SOC_RST_DLY[2:0];
        aontopporesetn_nxt = 1'b0;
        aontopwarmresetn_nxt = 1'b0;
        secporesetn_nxt = 1'b0;
        extsysporesetn_nxt = {NUM_EXT_SYS{1'b0}};

        cdbgrstack_dp_nxt = 1'b0;
        csysrstack_dprom_nxt =  1'b0;
        host_sys_rst_ack_nxt = 2'b00;

        secenccpuwait_nxt = 1'b0;

        aontoppo_aontopwarm_qreqn_nxt = 1'b0;
        secenc_hostsys_qreqn_nxt = 1'b0;
        extsys_hostsys_qreqn_nxt = {NUM_EXT_SYS{1'b0}};

        reset_req_type_nxt = 2'b00;
        host_sys_rst_req_flag_nxt = host_sys_rst_req_flag_r ? host_sys_rst_req : host_sys_rst_req_flag_r;
        nsrst_nxt = 1'b1;
        csysrstreq_dprom_nxt = 1'b0;
        secenc_sw_rst_req_nxt = 1'b0;
        host_sys_rst_req_nxt = 1'b0;
        fsm_en_nxt = {4{1'b0}};

        reset_syndrome_poresetn_r_nxt = 1'b0;
        reset_syndrome_secenc_cae_rst_req_r_nxt = (secenc_cae_rst_req) ? 1'b1 : 1'b0;
        reset_syndrome_soc_wdog_rst_req_r_nxt = (~secenc_cae_rst_req & soc_wdog_rst_req) ? 1'b1 : 1'b0;
        reset_syndrome_secenc_wdog_rst_req_r_nxt = (~secenc_cae_rst_req & ~soc_wdog_rst_req & secenc_wdog_rst_req) ? 1'b1 : 1'b0;
        reset_syndrome_cdbgrstreq_dp_r_nxt = (~secenc_cae_rst_req & ~soc_wdog_rst_req & ~secenc_wdog_rst_req & cdbgrstreq_dp) ? 1'b1 : 1'b0;
        reset_syndrome_soc_rst_req_r_nxt = (~secenc_cae_rst_req & ~soc_wdog_rst_req & ~secenc_wdog_rst_req & ~cdbgrstreq_dp & soc_rst_req) ? 1'b1 : 1'b0;
        reset_syndrome_secenc_sw_rst_req_r_nxt = 1'b0;
        reset_syndrome_nsrst_r_nxt = 1'b0;
        reset_syndrome_csysrstreq_dprom_r_nxt = 1'b0;
        reset_syndrome_host_sys_rst_req_r_nxt = 1'b0;
      end
      else if ((reset_syndrome_csysrstreq_dprom_r & (secenc_sw_rst_req | ~nsrst)) | (reset_syndrome_nsrst_r & secenc_sw_rst_req) | (reset_syndrome_host_sys_rst_req_r & (secenc_sw_rst_req | ~nsrst | csysrstreq_dprom)))
      begin
        state_nxt = RESET_ASSERT;

        downcount_nxt = SOC_RST_DLY[2:0];
        aontopporesetn_nxt = 1'b1;
        aontopwarmresetn_nxt = 1'b0;
        secporesetn_nxt = 1'b0;
        extsysporesetn_nxt = {NUM_EXT_SYS{1'b0}};

        cdbgrstack_dp_nxt = 1'b0;
        csysrstack_dprom_nxt = 1'b0;
        host_sys_rst_ack_nxt = 2'b00;

        secenccpuwait_nxt =(~secenc_sw_rst_req & (~nsrst | csysrstreq_dprom)) ? 1'b1 : 1'b0;

        aontoppo_aontopwarm_qreqn_nxt = 1'b0;
        secenc_hostsys_qreqn_nxt = 1'b0;
        extsys_hostsys_qreqn_nxt = {NUM_EXT_SYS{1'b0}};

        reset_req_type_nxt = 2'b01;
        host_sys_rst_req_flag_nxt = host_sys_rst_req_flag_r;
        nsrst_nxt = 1'b1;
        csysrstreq_dprom_nxt = 1'b0;
        secenc_sw_rst_req_nxt = 1'b0;
        host_sys_rst_req_nxt = 1'b0;
        fsm_en_nxt = {4{1'b0}};

        reset_syndrome_poresetn_r_nxt= 1'b0; 
        reset_syndrome_secenc_cae_rst_req_r_nxt= 1'b0;
        reset_syndrome_soc_wdog_rst_req_r_nxt= 1'b0;
        reset_syndrome_secenc_wdog_rst_req_r_nxt= 1'b0;
        reset_syndrome_cdbgrstreq_dp_r_nxt= 1'b0;
        reset_syndrome_soc_rst_req_r_nxt= 1'b0;
        reset_syndrome_secenc_sw_rst_req_r_nxt = (secenc_sw_rst_req) ? 1'b1 : 1'b0;
        reset_syndrome_nsrst_r_nxt = (~secenc_sw_rst_req & ~nsrst) ? 1'b1 : 1'b0;
        reset_syndrome_csysrstreq_dprom_r_nxt = (~secenc_sw_rst_req & nsrst & csysrstreq_dprom) ? 1'b1 : 1'b0;
        reset_syndrome_host_sys_rst_req_r_nxt = 1'b0;
      end
      else
      begin
        state_nxt = WAIT_DEASSERT;

        downcount_nxt = SOC_RST_DLY[2:0];
        aontopporesetn_nxt = aontopporesetn_r;
        aontopwarmresetn_nxt = aontopwarmresetn_r;
        secporesetn_nxt = secporesetn_r;
        extsysporesetn_nxt = extsysporesetn_r;

        cdbgrstack_dp_nxt = cdbgrstack_dp_r;
        csysrstack_dprom_nxt =  csysrstack_dprom_r;
        host_sys_rst_ack_nxt = host_sys_rst_ack_r;

        secenccpuwait_nxt = secenccpuwait_r;

        aontoppo_aontopwarm_qreqn_nxt = 1'b0;
        secenc_hostsys_qreqn_nxt = 1'b0;
        extsys_hostsys_qreqn_nxt = {NUM_EXT_SYS{1'b0}};

        reset_req_type_nxt = reset_req_type_r;
        host_sys_rst_req_flag_nxt = host_sys_rst_req_flag_r ? host_sys_rst_req : host_sys_rst_req_flag_r;
        nsrst_nxt = 1'b1;
        csysrstreq_dprom_nxt = 1'b0;
        secenc_sw_rst_req_nxt = 1'b0;
        host_sys_rst_req_nxt = 1'b0;
        fsm_en_nxt = {4{1'b0}};
  
        reset_syndrome_poresetn_r_nxt = reset_syndrome_poresetn_r; 
        reset_syndrome_secenc_cae_rst_req_r_nxt = reset_syndrome_secenc_cae_rst_req_r;
        reset_syndrome_soc_wdog_rst_req_r_nxt = reset_syndrome_soc_wdog_rst_req_r;
        reset_syndrome_secenc_wdog_rst_req_r_nxt = reset_syndrome_secenc_wdog_rst_req_r;
        reset_syndrome_cdbgrstreq_dp_r_nxt = reset_syndrome_cdbgrstreq_dp_r;
        reset_syndrome_soc_rst_req_r_nxt = reset_syndrome_soc_rst_req_r;
        reset_syndrome_secenc_sw_rst_req_r_nxt = reset_syndrome_secenc_sw_rst_req_r;
        reset_syndrome_nsrst_r_nxt = reset_syndrome_nsrst_r;
        reset_syndrome_csysrstreq_dprom_r_nxt = reset_syndrome_csysrstreq_dprom_r;
        reset_syndrome_host_sys_rst_req_r_nxt = reset_syndrome_host_sys_rst_req_r;
      end
    end 

    WAIT_QACCEPT:
    begin
      if (soc_rst_req | secenc_wdog_rst_req | secenc_cae_rst_req | soc_wdog_rst_req | cdbgrstreq_dp)
      begin
        state_nxt = RESET_ASSERT;
      end
      else if (((reset_req_type_r == 2'b10) & (~nsrst | secenc_sw_rst_req | csysrstreq_dprom)) | (reset_req_type_r == 2'b01))
      begin
        if (~aontoppo_aontopwarm_qacceptn)
        begin
          state_nxt = RESET_ASSERT;
        end
        else if (aontoppo_aontopwarm_qdeny & ((~secenc_hostsys_qreqn & ((~secenc_hostsys_qacceptn) | secenc_hostsys_qdeny)) | secenc_hostsys_qreqn))
        begin
          state_nxt = Q_DENIED;
        end
        else
        begin
          state_nxt = WAIT_QACCEPT;
        end
      end
      else
      begin
        if (~aontoppo_aontopwarm_qacceptn & ~secenc_hostsys_qacceptn)
        begin
          state_nxt = RESET_ASSERT;
        end
        else if ((secenc_hostsys_qdeny | ~secenc_hostsys_qacceptn) & (aontoppo_aontopwarm_qdeny | ~aontoppo_aontopwarm_qacceptn) & (secenc_hostsys_qdeny | aontoppo_aontopwarm_qdeny))
        begin
          state_nxt = Q_DENIED;
        end
        else 
        begin
          state_nxt = WAIT_QACCEPT;
        end
      end

      if (state_nxt == RESET_ASSERT)
      begin
        if (soc_rst_req | secenc_wdog_rst_req | secenc_cae_rst_req | soc_wdog_rst_req | cdbgrstreq_dp)
        begin
          downcount_nxt = SOC_RST_DLY[2:0];
          aontopporesetn_nxt = 1'b0;
          aontopwarmresetn_nxt = 1'b0;
          secporesetn_nxt = 1'b0;
          extsysporesetn_nxt = {NUM_EXT_SYS{1'b0}};

          cdbgrstack_dp_nxt = 1'b0;
          csysrstack_dprom_nxt = 1'b0;
          host_sys_rst_ack_nxt = 2'b00;

          secenccpuwait_nxt = 1'b0;

          aontoppo_aontopwarm_qreqn_nxt = 1'b0;
          secenc_hostsys_qreqn_nxt = 1'b0;
          extsys_hostsys_qreqn_nxt = {NUM_EXT_SYS{1'b0}};

          host_sys_rst_req_flag_nxt = host_sys_rst_req_flag_r ? host_sys_rst_req : host_sys_rst_req_flag_r;
          reset_req_type_nxt = 2'b00;
          nsrst_nxt = 1'b1;
          csysrstreq_dprom_nxt = 1'b0;
          secenc_sw_rst_req_nxt = 1'b0;
          host_sys_rst_req_nxt = 1'b0;
          fsm_en_nxt = {4{1'b0}};

          reset_syndrome_poresetn_r_nxt = 1'b0;
          reset_syndrome_secenc_cae_rst_req_r_nxt = (secenc_cae_rst_req) ? 1'b1 : 1'b0;
          reset_syndrome_soc_wdog_rst_req_r_nxt = (~secenc_cae_rst_req & soc_wdog_rst_req) ? 1'b1 : 1'b0;
          reset_syndrome_secenc_wdog_rst_req_r_nxt = (~secenc_cae_rst_req & ~soc_wdog_rst_req & secenc_wdog_rst_req) ? 1'b1 : 1'b0;
          reset_syndrome_cdbgrstreq_dp_r_nxt = (~secenc_cae_rst_req & ~soc_wdog_rst_req & ~secenc_wdog_rst_req & cdbgrstreq_dp) ? 1'b1 : 1'b0;
          reset_syndrome_soc_rst_req_r_nxt = (~secenc_cae_rst_req & ~soc_wdog_rst_req & ~secenc_wdog_rst_req & ~cdbgrstreq_dp & soc_rst_req) ? 1'b1 : 1'b0;
          reset_syndrome_secenc_sw_rst_req_r_nxt = 1'b0;
          reset_syndrome_nsrst_r_nxt = 1'b0;
          reset_syndrome_csysrstreq_dprom_r_nxt = 1'b0;
          reset_syndrome_host_sys_rst_req_r_nxt = 1'b0;
        end
        else
        begin
          downcount_nxt = SOC_RST_DLY[2:0];
          aontopporesetn_nxt = aontopporesetn_r;
          aontopwarmresetn_nxt = 1'b0;
          secporesetn_nxt = ((secenc_sw_rst_req | secenc_sw_rst_req_r) | (~nsrst_r | ~nsrst) | (csysrstreq_dprom_r | csysrstreq_dprom)) ? 1'b0 : 1'b1;
          extsysporesetn_nxt = {NUM_EXT_SYS{1'b0}};

          cdbgrstack_dp_nxt = 1'b0;
          csysrstack_dprom_nxt = 1'b0;
          host_sys_rst_ack_nxt = 2'b00;

          secenccpuwait_nxt = (~(secenc_sw_rst_req_r | secenc_sw_rst_req) & ((~nsrst_r | ~nsrst)  | (csysrstreq_dprom_r | csysrstreq_dprom))) ? 1'b1 : 1'b0;

          aontoppo_aontopwarm_qreqn_nxt = aontoppo_aontopwarm_qreqn_r;
          secenc_hostsys_qreqn_nxt = 1'b0;
          extsys_hostsys_qreqn_nxt = {NUM_EXT_SYS{1'b0}};

          reset_req_type_nxt = (secenc_sw_rst_req | ~nsrst | csysrstreq_dprom) ? 2'b01 : reset_req_type_r;
          host_sys_rst_req_flag_nxt = host_sys_rst_req_flag_r ? host_sys_rst_req : host_sys_rst_req_flag_r;
          nsrst_nxt = 1'b1;
          csysrstreq_dprom_nxt = 1'b0;
          secenc_sw_rst_req_nxt = 1'b0;
          host_sys_rst_req_nxt = 1'b0;
          fsm_en_nxt = {4{1'b0}};
  
          reset_syndrome_poresetn_r_nxt= 1'b0;
          reset_syndrome_secenc_cae_rst_req_r_nxt= 1'b0;
          reset_syndrome_soc_wdog_rst_req_r_nxt= 1'b0;
          reset_syndrome_secenc_wdog_rst_req_r_nxt= 1'b0;
          reset_syndrome_cdbgrstreq_dp_r_nxt= 1'b0;
          reset_syndrome_soc_rst_req_r_nxt= 1'b0;
          reset_syndrome_secenc_sw_rst_req_r_nxt = ((secenc_sw_rst_req_r | secenc_sw_rst_req) & ~aontoppo_aontopwarm_qacceptn) ? 1'b1 : 1'b0;
          reset_syndrome_nsrst_r_nxt = (~(secenc_sw_rst_req | secenc_sw_rst_req_r) & ((~nsrst_r | ~nsrst) & ~aontoppo_aontopwarm_qacceptn)) ? 1'b1 : 1'b0;
          reset_syndrome_csysrstreq_dprom_r_nxt = (~(secenc_sw_rst_req |secenc_sw_rst_req_r) & (nsrst & nsrst_r) & ((csysrstreq_dprom_r | csysrstreq_dprom) & ~aontoppo_aontopwarm_qacceptn)) ? 1'b1 : 1'b0;
          reset_syndrome_host_sys_rst_req_r_nxt = (~(secenc_sw_rst_req |secenc_sw_rst_req_r) & (nsrst & nsrst_r) & ~(csysrstreq_dprom_r | csysrstreq_dprom) & ((host_sys_rst_req_r | host_sys_rst_req) & ~aontoppo_aontopwarm_qacceptn & ~secenc_hostsys_qacceptn )) ? 1'b1 : 1'b0;
        end
      end
      else if (state_nxt == Q_DENIED)
      begin
        downcount_nxt = SOC_RST_DLY[2:0];
        aontopporesetn_nxt = aontopporesetn_r;
        aontopwarmresetn_nxt = aontopwarmresetn_r;
        secporesetn_nxt = secporesetn_r;
        extsysporesetn_nxt = extsysporesetn_r;

        cdbgrstack_dp_nxt = cdbgrstack_dp_r;
        csysrstack_dprom_nxt = csysrstack_dprom_r;
        host_sys_rst_ack_nxt = host_sys_rst_req_flag_r ? (host_sys_rst_req ? host_sys_rst_ack_r : 2'b00) : ((reset_req_type_r == 2'b01) ? 2'b00 : ((~(~nsrst | secenc_sw_rst_req | csysrstreq_dprom) & (host_sys_rst_req)) ? 2'b01 : 2'b00)) ;

        secenccpuwait_nxt = secenccpuwait_r;

        aontoppo_aontopwarm_qreqn_nxt = 1'b1;
        secenc_hostsys_qreqn_nxt = 1'b1;
        extsys_hostsys_qreqn_nxt = {NUM_EXT_SYS{1'b1}};

        host_sys_rst_req_flag_nxt = host_sys_rst_req_flag_r ? host_sys_rst_req : ((reset_req_type_r == 2'b01) ? 1'b0 : (~(~nsrst | secenc_sw_rst_req | csysrstreq_dprom) & (host_sys_rst_req)));
        reset_req_type_nxt = ((reset_req_type_r == 2'b10) & (~nsrst | secenc_sw_rst_req | csysrstreq_dprom)) ? 2'b01 : reset_req_type_r;
        nsrst_nxt = 1'b1;
        csysrstreq_dprom_nxt = 1'b0;
        secenc_sw_rst_req_nxt = 1'b0;
        host_sys_rst_req_nxt = 1'b0;
        fsm_en_nxt = fsm_en_r;

        reset_syndrome_poresetn_r_nxt = reset_syndrome_poresetn_r; 
        reset_syndrome_secenc_cae_rst_req_r_nxt = reset_syndrome_secenc_cae_rst_req_r;
        reset_syndrome_soc_wdog_rst_req_r_nxt = reset_syndrome_soc_wdog_rst_req_r;
        reset_syndrome_secenc_wdog_rst_req_r_nxt = reset_syndrome_secenc_wdog_rst_req_r;
        reset_syndrome_cdbgrstreq_dp_r_nxt = reset_syndrome_cdbgrstreq_dp_r;
        reset_syndrome_soc_rst_req_r_nxt = reset_syndrome_soc_rst_req_r;
        reset_syndrome_secenc_sw_rst_req_r_nxt = reset_syndrome_secenc_sw_rst_req_r;
        reset_syndrome_nsrst_r_nxt = reset_syndrome_nsrst_r;
        reset_syndrome_csysrstreq_dprom_r_nxt = reset_syndrome_csysrstreq_dprom_r;
        reset_syndrome_host_sys_rst_req_r_nxt = reset_syndrome_host_sys_rst_req_r;
      end
      else
      begin
        downcount_nxt = downcount_r;
        aontopporesetn_nxt = aontopporesetn_r;
        aontopwarmresetn_nxt = aontopwarmresetn_r;
        secporesetn_nxt = secporesetn_r;
        extsysporesetn_nxt = extsysporesetn_r;

        cdbgrstack_dp_nxt = cdbgrstack_dp_r;
        csysrstack_dprom_nxt = csysrstack_dprom_r;
        host_sys_rst_ack_nxt = host_sys_rst_req_flag_r ? (host_sys_rst_req ? host_sys_rst_ack_r : 2'b00) : 2'b00;

        secenccpuwait_nxt = secenccpuwait_r;

        aontoppo_aontopwarm_qreqn_nxt = aontoppo_aontopwarm_qreqn_r;
        secenc_hostsys_qreqn_nxt = secenc_hostsys_qreqn_r;
        extsys_hostsys_qreqn_nxt = {NUM_EXT_SYS{1'b1}};

        host_sys_rst_req_flag_nxt = host_sys_rst_req_flag_r ? host_sys_rst_req : host_sys_rst_req_flag_r;
        reset_req_type_nxt = reset_req_type_r;
        nsrst_nxt = nsrst_r;
        csysrstreq_dprom_nxt = csysrstreq_dprom_r;
        secenc_sw_rst_req_nxt = secenc_sw_rst_req_r;
        host_sys_rst_req_nxt = host_sys_rst_req_r;
        fsm_en_nxt = fsm_en_r;

        reset_syndrome_poresetn_r_nxt = reset_syndrome_poresetn_r; 
        reset_syndrome_secenc_cae_rst_req_r_nxt = reset_syndrome_secenc_cae_rst_req_r;
        reset_syndrome_soc_wdog_rst_req_r_nxt = reset_syndrome_soc_wdog_rst_req_r;
        reset_syndrome_secenc_wdog_rst_req_r_nxt = reset_syndrome_secenc_wdog_rst_req_r;
        reset_syndrome_cdbgrstreq_dp_r_nxt = reset_syndrome_cdbgrstreq_dp_r;
        reset_syndrome_soc_rst_req_r_nxt = reset_syndrome_soc_rst_req_r;
        reset_syndrome_secenc_sw_rst_req_r_nxt = reset_syndrome_secenc_sw_rst_req_r;
        reset_syndrome_nsrst_r_nxt = reset_syndrome_nsrst_r;
        reset_syndrome_csysrstreq_dprom_r_nxt = reset_syndrome_csysrstreq_dprom_r;
        reset_syndrome_host_sys_rst_req_r_nxt = reset_syndrome_host_sys_rst_req_r;
     end
    end 

    Q_DENIED:
    begin
      if (soc_wdog_rst_req | secenc_wdog_rst_req | secenc_cae_rst_req | cdbgrstreq_dp | soc_rst_req)
      begin
        state_nxt = RESET_ASSERT;
      end
      else if (((reset_req_type_r == 2'b01) | ((reset_req_type_r == 2'b10) & (secenc_sw_rst_req | ~nsrst | csysrstreq_dprom))) & ~aontoppo_aontopwarm_qdeny)
      begin
        state_nxt = ((secenc_sw_rst_req | ~nsrst | csysrstreq_dprom) & aontop_qch_okay) ? WAIT_QACCEPT : IDLE;
      end
      else if ((reset_req_type_r == 2'b10) & (~aontoppo_aontopwarm_qdeny & aontoppo_aontopwarm_qacceptn & ~secenc_hostsys_qdeny & secenc_hostsys_qacceptn))
      begin
        state_nxt = IDLE;
      end
      else
      begin
        state_nxt = Q_DENIED;
      end

      if (state_nxt == RESET_ASSERT)
      begin
        downcount_nxt = SOC_RST_DLY[2:0];
        aontopporesetn_nxt = 1'b0;
        aontopwarmresetn_nxt = 1'b0;
        secporesetn_nxt = 1'b0;
        extsysporesetn_nxt = {NUM_EXT_SYS{1'b0}};

        cdbgrstack_dp_nxt = 1'b0; 
        csysrstack_dprom_nxt = 1'b0;
        host_sys_rst_ack_nxt = 2'b00;

        secenccpuwait_nxt = 1'b0;

        aontoppo_aontopwarm_qreqn_nxt = 1'b0;
        secenc_hostsys_qreqn_nxt = 1'b0;
        extsys_hostsys_qreqn_nxt = {NUM_EXT_SYS{1'b0}};

        host_sys_rst_req_flag_nxt = host_sys_rst_req_flag_r ? host_sys_rst_req : host_sys_rst_req_flag_r;
        reset_req_type_nxt = 2'b00;
        nsrst_nxt = 1'b0;
        csysrstreq_dprom_nxt = 1'b0;
        secenc_sw_rst_req_nxt = 1'b0;
        host_sys_rst_req_nxt = 1'b0;
        fsm_en_nxt = {4{1'b0}};

        reset_syndrome_poresetn_r_nxt = 1'b0;
        reset_syndrome_secenc_cae_rst_req_r_nxt = (secenc_cae_rst_req) ? 1'b1 : 1'b0;
        reset_syndrome_soc_wdog_rst_req_r_nxt = (~secenc_cae_rst_req & soc_wdog_rst_req) ? 1'b1 : 1'b0;
        reset_syndrome_secenc_wdog_rst_req_r_nxt = (~secenc_cae_rst_req & ~soc_wdog_rst_req & secenc_wdog_rst_req) ? 1'b1 : 1'b0;
        reset_syndrome_cdbgrstreq_dp_r_nxt = (~secenc_cae_rst_req & ~soc_wdog_rst_req & ~secenc_wdog_rst_req & cdbgrstreq_dp) ? 1'b1 : 1'b0;
        reset_syndrome_soc_rst_req_r_nxt = (~secenc_cae_rst_req & ~soc_wdog_rst_req & ~secenc_wdog_rst_req & ~cdbgrstreq_dp & soc_rst_req) ? 1'b1 : 1'b0;
        reset_syndrome_secenc_sw_rst_req_r_nxt = 1'b0;
        reset_syndrome_nsrst_r_nxt = 1'b0;
        reset_syndrome_csysrstreq_dprom_r_nxt = 1'b0;
        reset_syndrome_host_sys_rst_req_r_nxt = 1'b0;
      end
      else if (state_nxt == WAIT_QACCEPT)
      begin
        downcount_nxt = downcount_r;
        aontopporesetn_nxt = aontopporesetn_r;
        aontopwarmresetn_nxt = aontopwarmresetn_r;
        secporesetn_nxt = secporesetn_r;
        extsysporesetn_nxt = extsysporesetn_r;

        cdbgrstack_dp_nxt = 1'b0;
        csysrstack_dprom_nxt = 1'b0;
        host_sys_rst_ack_nxt = host_sys_rst_req ? host_sys_rst_ack_r : 2'b00;

        secenccpuwait_nxt = 1'b0;

        aontoppo_aontopwarm_qreqn_nxt = 1'b0;
        secenc_hostsys_qreqn_nxt = 1'b1;
        extsys_hostsys_qreqn_nxt = {NUM_EXT_SYS{1'b1}};

        host_sys_rst_req_flag_nxt = host_sys_rst_req_flag_r ? host_sys_rst_req : host_sys_rst_req_flag_r;
        reset_req_type_nxt = 2'b01;
        nsrst_nxt = nsrst;
        csysrstreq_dprom_nxt = csysrstreq_dprom;
        secenc_sw_rst_req_nxt = secenc_sw_rst_req;
        host_sys_rst_req_nxt = host_sys_rst_req;
        fsm_en_nxt = fsm_en_r;

        reset_syndrome_poresetn_r_nxt = reset_syndrome_poresetn_r; 
        reset_syndrome_secenc_cae_rst_req_r_nxt = reset_syndrome_secenc_cae_rst_req_r;
        reset_syndrome_soc_wdog_rst_req_r_nxt = reset_syndrome_soc_wdog_rst_req_r;
        reset_syndrome_secenc_wdog_rst_req_r_nxt = reset_syndrome_secenc_wdog_rst_req_r;
        reset_syndrome_cdbgrstreq_dp_r_nxt = reset_syndrome_cdbgrstreq_dp_r;
        reset_syndrome_soc_rst_req_r_nxt = reset_syndrome_soc_rst_req_r;
        reset_syndrome_secenc_sw_rst_req_r_nxt = reset_syndrome_secenc_sw_rst_req_r;
        reset_syndrome_nsrst_r_nxt = reset_syndrome_nsrst_r;
        reset_syndrome_csysrstreq_dprom_r_nxt = reset_syndrome_csysrstreq_dprom_r;
        reset_syndrome_host_sys_rst_req_r_nxt = reset_syndrome_host_sys_rst_req_r;
      end
      else
      begin
        downcount_nxt = downcount_r;
        aontopporesetn_nxt = aontopporesetn_r;
        aontopwarmresetn_nxt = aontopwarmresetn_r;
        secporesetn_nxt = secporesetn_r;
        extsysporesetn_nxt = extsysporesetn_r;

        cdbgrstack_dp_nxt = cdbgrstack_dp_r;
        csysrstack_dprom_nxt = csysrstack_dprom_r;
        host_sys_rst_ack_nxt = host_sys_rst_req ? host_sys_rst_ack_r : 2'b00;

        secenccpuwait_nxt = secenccpuwait_r;

        aontoppo_aontopwarm_qreqn_nxt = aontoppo_aontopwarm_qreqn_r;
        secenc_hostsys_qreqn_nxt = secenc_hostsys_qreqn_r;
        extsys_hostsys_qreqn_nxt = extsys_hostsys_qreqn_r;

        host_sys_rst_req_flag_nxt = host_sys_rst_req_flag_r ? host_sys_rst_req : host_sys_rst_req_flag_r;
        reset_req_type_nxt = reset_req_type_r;
        nsrst_nxt = 1'b0;
        csysrstreq_dprom_nxt = 1'b0;
        secenc_sw_rst_req_nxt = 1'b0;
        host_sys_rst_req_nxt = 1'b0;
        fsm_en_nxt = fsm_en_r;

        reset_syndrome_poresetn_r_nxt = reset_syndrome_poresetn_r; 
        reset_syndrome_secenc_cae_rst_req_r_nxt = reset_syndrome_secenc_cae_rst_req_r;
        reset_syndrome_soc_wdog_rst_req_r_nxt = reset_syndrome_soc_wdog_rst_req_r;
        reset_syndrome_secenc_wdog_rst_req_r_nxt = reset_syndrome_secenc_wdog_rst_req_r;
        reset_syndrome_cdbgrstreq_dp_r_nxt = reset_syndrome_cdbgrstreq_dp_r;
        reset_syndrome_soc_rst_req_r_nxt = reset_syndrome_soc_rst_req_r;
        reset_syndrome_secenc_sw_rst_req_r_nxt = reset_syndrome_secenc_sw_rst_req_r;
        reset_syndrome_nsrst_r_nxt = reset_syndrome_nsrst_r;
        reset_syndrome_csysrstreq_dprom_r_nxt = reset_syndrome_csysrstreq_dprom_r;
        reset_syndrome_host_sys_rst_req_r_nxt = reset_syndrome_host_sys_rst_req_r;
      end
    end 

    default:
    begin
      state_nxt[2:0] = 3'bxxx;

      aontopporesetn_nxt = 1'bx;
      aontopwarmresetn_nxt = 1'bx;
      secporesetn_nxt = 1'bx;
      extsysporesetn_nxt = {NUM_EXT_SYS{1'bx}};

      cdbgrstack_dp_nxt  = 1'bx;
      csysrstack_dprom_nxt = 1'bx;
      host_sys_rst_ack_nxt = 2'bxx;

      secenccpuwait_nxt = 1'bx;

      aontoppo_aontopwarm_qreqn_nxt = 1'bx;
      secenc_hostsys_qreqn_nxt = 1'bx;
      extsys_hostsys_qreqn_nxt = {NUM_EXT_SYS{1'bx}};

      downcount_nxt = 3'bxxx;
      host_sys_rst_req_flag_nxt = 1'bx;
      reset_req_type_nxt = 2'bxx;
      nsrst_nxt = 1'bx;
      csysrstreq_dprom_nxt = 1'bx;
      secenc_sw_rst_req_nxt = 1'bx;
      host_sys_rst_req_nxt = 1'bx;
      fsm_en_nxt = {4{1'bx}};

      reset_syndrome_poresetn_r_nxt = 1'bx; 
      reset_syndrome_secenc_cae_rst_req_r_nxt = 1'bx;
      reset_syndrome_soc_wdog_rst_req_r_nxt = 1'bx;
      reset_syndrome_secenc_wdog_rst_req_r_nxt = 1'bx;
      reset_syndrome_cdbgrstreq_dp_r_nxt = 1'bx;
      reset_syndrome_soc_rst_req_r_nxt = 1'bx;
      reset_syndrome_secenc_sw_rst_req_r_nxt = 1'bx;
      reset_syndrome_nsrst_r_nxt = 1'bx;
      reset_syndrome_csysrstreq_dprom_r_nxt = 1'bx;
      reset_syndrome_host_sys_rst_req_r_nxt = 1'bx;
    end
    endcase
  end


wire [(2*NUM_EXT_SYS)-1:0] extsys_rst_ack_int;
wire [NUM_EXT_SYS-1:0]     extsyscpuwait_int;
wire [NUM_EXT_SYS-1:0]     extsys_hostsys_qreqn_int;

  genvar J;
  generate
  for (J=0; J<NUM_EXT_SYS; J=J+1)
  begin:extsys_fsm
  reset_controller_f1_extsys_fsm #(
    .SOC_RST_DLY (SOC_RST_DLY)
  ) u_extsysrst_fsm (
    .clk (clk),
    .resetn (resetn),
    .fsm_en (fsm_en_r[J]),
    .rst_req (extsys_rst_req_int[J]),

    .resetn_out (extsysfsm_extsysporesetn[J]),
    .cpuwait (extsyscpuwait_int[J]),
    .rst_ack (extsys_rst_ack_int[2*J+1:2*J]),

    .qreqn (extsys_hostsys_qreqn_int[J]),
    .qacceptn (extsys_hostsys_qacceptn[J]),
    .qdeny (extsys_hostsys_qdeny[J]),

    .rst_syndrome (extsysfsm_reset_syndrome_extsys_rst_req[J])
  );
  end
  endgenerate

  wire [NUM_EXT_SYS-1:0]  extsysporesetn_int;
  assign extsysporesetn = extsysporesetn_int;  
  assign aontopporesetn = aontopporesetn_r;
  assign aontopwarmresetn = aontopwarmresetn_r;
  assign secporesetn = secporesetn_r;




  assign cdbgrstack_dp = cdbgrstack_dp_r;
  assign csysrstack_dprom = csysrstack_dprom_r;
  assign host_sys_rst_ack = host_sys_rst_ack_r;

  assign secenccpuwait = secenccpuwait_r;

  assign aontoppo_aontopwarm_qreqn = aontoppo_aontopwarm_qreqn_r;
  assign secenc_hostsys_qreqn = secenc_hostsys_qreqn_r;


  wire [NUM_EXT_SYS-1:0]  extsys_rst_syn_muxsel;
  wire                    nsrst_csysrst_rstsyn;
  wire                    other_rstsyn;
  wire                    secenc_req_rstsyn;
  wire                    por_cdbg_socrst_rstsyn;

  arm_element_cdc_comb_and2 #(
    .WIDTH (NUM_EXT_SYS)
  ) u_extsys_rst_syn_muxsel_and2 (
    .din1_async (fsm_en_r[(NUM_EXT_SYS-1):0]),
    .din2_async (extsysfsm_reset_syndrome_extsys_rst_req),

    .dout_async (extsys_rst_syn_muxsel)
  );

  arm_element_or_tree #(
    .NUM_OR_TREE_INPUTS (2)
  ) u_nsrst_csysrst_rstsyn_or (
    .or_tree_i ({reset_syndrome_nsrst_r, reset_syndrome_csysrstreq_dprom_r}),

    .or_tree_o (nsrst_csysrst_rstsyn)
  );

  arm_element_or_tree #(
    .NUM_OR_TREE_INPUTS (7)
  ) u_other_rstsyn_or (
    .or_tree_i ({reset_syndrome_poresetn_r, reset_syndrome_cdbgrstreq_dp_r, reset_syndrome_secenc_wdog_rst_req_r, reset_syndrome_secenc_cae_rst_req_r,
                 reset_syndrome_soc_wdog_rst_req_r, reset_syndrome_soc_rst_req_r, reset_syndrome_secenc_sw_rst_req_r}),

    .or_tree_o (other_rstsyn)
  );

  arm_element_or_tree #(
    .NUM_OR_TREE_INPUTS (3)
  ) u_secenc_req_rstsyn_or (
    .or_tree_i ({reset_syndrome_secenc_sw_rst_req_r, reset_syndrome_secenc_wdog_rst_req_r, reset_syndrome_secenc_cae_rst_req_r}),

    .or_tree_o (secenc_req_rstsyn)
  );

  arm_element_or_tree #(
    .NUM_OR_TREE_INPUTS (3)
  ) u_por_cdbg_socrst_rstsyn_or (
    .or_tree_i ({reset_syndrome_poresetn_r, reset_syndrome_cdbgrstreq_dp_r, reset_syndrome_soc_rst_req_r}),

    .or_tree_o (por_cdbg_socrst_rstsyn)
  );

  assign host_rst_syn[0]    = other_rstsyn;
  assign host_rst_syn[1]    = nsrst_csysrst_rstsyn;
  assign host_rst_syn[2]    = 1'b0;
  assign host_rst_syn[3]    = reset_syndrome_host_sys_rst_req_r;

  reg [4:0] soc_rst_syn_int;
  reg [4:0] soc_rst_syn_r;
  wire [2:0] se_rst_syn_int;
  reg [2:0] se_rst_syn_r;

  always @(posedge clk or negedge resetn)
  begin
    if (~resetn)
    begin
      soc_rst_syn_r <= 5'b00001;
    end
    else if (~reset_syndrome_host_sys_rst_req_r)
    begin
      soc_rst_syn_r <=  soc_rst_syn_int;
    end
  end

  always @*
  begin
    soc_rst_syn_int[0] = por_cdbg_socrst_rstsyn;
    soc_rst_syn_int[1] = nsrst_csysrst_rstsyn;
    soc_rst_syn_int[2] = 1'b0; 
    soc_rst_syn_int[3] = reset_syndrome_soc_wdog_rst_req_r;
    soc_rst_syn_int[4] = secenc_req_rstsyn;
  end

  arm_element_cdc_comb_mux2 #(
    .WIDTH (5)
  ) u_soc_rst_syn_mux (
    .din1_async  (soc_rst_syn_int),
    .din2_async  (soc_rst_syn_r),
    .sel         (reset_syndrome_host_sys_rst_req_r),
    .dout_async  (soc_rst_syn)
  );



  always @(posedge clk or negedge resetn)
  begin
    if (~resetn)
      begin
        se_rst_syn_r <= 3'b00;
      end
    else if (~reset_syndrome_host_sys_rst_req_r)
      begin
        se_rst_syn_r <= se_rst_syn_int;
      end
  end

  assign se_rst_syn_int[0]      = reset_syndrome_secenc_sw_rst_req_r;
  assign se_rst_syn_int[1]      = reset_syndrome_secenc_wdog_rst_req_r;
  assign se_rst_syn_int[2]      = reset_syndrome_secenc_cae_rst_req_r;

  arm_element_cdc_comb_mux2 #(
    .WIDTH (3)
  ) u_se_rst_syn_mux (
    .din1_async  (se_rst_syn_int),
    .din2_async  (se_rst_syn_r),
    .sel         (reset_syndrome_host_sys_rst_req_r),
    .dout_async  (se_rst_syn)
  );

  genvar I;
  generate
  for (I=0; I<NUM_EXT_SYS; I=I+1)
  begin:extsys_reset_syndrome

    arm_element_cdc_comb_mux2 #(
      .WIDTH (5)
    ) u_extsys_rst_syn_mux (
      .din1_async  ({1'b0,reset_syndrome_host_sys_rst_req_r, 1'b0, nsrst_csysrst_rstsyn, other_rstsyn}),
      .din2_async  (5'b10000),
      .sel         (extsys_rst_syn_muxsel[I]),
      .dout_async  (extsys_rst_syn[5*I+4:5*I])
    );

    arm_element_cdc_comb_mux2 #(
      .WIDTH (2)
    ) u_extsys_rst_ack_mux (
      .din1_async  (2'b00),
      .din2_async  (extsys_rst_ack_int[2*I+1:2*I]),
      .sel         (fsm_en_r[I]),
      .dout_async  (extsys_rst_ack[2*I+1:2*I])
    );

    arm_element_cdc_comb_mux2 u_extsysporesetn_mux (
      .din1_async  (extsysporesetn_r[I]),
      .din2_async  (extsysfsm_extsysporesetn[I]),
      .sel         (fsm_en_r[I]),
      .dout_async  (extsysporesetn_int[I])
    );

    arm_element_cdc_comb_mux2 u_extsys_cpuwait_mux (
      .din1_async  (1'b0),
      .din2_async  (extsyscpuwait_int[I]),
      .sel         (fsm_en_r[I]),
      .dout_async  (extsyscpuwait[I])
    );

    arm_element_cdc_comb_mux2 u_extsys_hostsys_qreqn_mux (
      .din1_async  (extsys_hostsys_qreqn_r[I]),
      .din2_async  (extsys_hostsys_qreqn_int[I]),
      .sel         (fsm_en_r[I]),
      .dout_async  (extsys_hostsys_qreqn[I])
    );

  end
  endgenerate

  
  generate 
    if(NUM_EXT_SYS < 4) begin : gen_unused
      assign unused = |{fsm_en_r[3:NUM_EXT_SYS], extsys_rst_req_int[3:NUM_EXT_SYS]};
    end else begin : gen_unused_tie
      assign unused = 1'b0;
    end
  endgenerate

endmodule



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
 

module host_control 
#(
    parameter HOST_CPU_NUM_CORES = 4
)
(
    input wire                 clk,
    input wire                 resetn,
    
    
    input wire                 penable,
    input wire [11:0]          paddr,
    input wire                 pwrite,
    input wire [31:0]          pwdata,
    
    input wire                 psel,
    output wire                pready,
    output wire [31:0]         prdata,
    output wire                pslverr,
        
    

    output reg  cluster_config_cryptodisable,
    output wire  pe0_config_aa64naa32,
    output reg  pe0_config_vinithi,
    output reg  pe0_config_cfgte,
    output reg  pe0_config_cfgend,
    output wire [29:0] pe0_rvbaraddr_lw_rvbar31_2,
    input wire [11:0] pe0_rvbaraddr_up_rvbar43_32,
    output wire  pe1_config_aa64naa32,
    output wire  pe1_config_vinithi,
    output wire  pe1_config_cfgte,
    output wire  pe1_config_cfgend,
    output wire [29:0] pe1_rvbaraddr_lw_rvbar31_2,
    input wire [11:0] pe1_rvbaraddr_up_rvbar43_32,
    output wire  pe2_config_aa64naa32,
    output wire  pe2_config_vinithi,
    output wire  pe2_config_cfgte,
    output wire  pe2_config_cfgend,
    output wire [29:0] pe2_rvbaraddr_lw_rvbar31_2,
    input wire [11:0] pe2_rvbaraddr_up_rvbar43_32,
    output wire  pe3_config_aa64naa32,
    output wire  pe3_config_vinithi,
    output wire  pe3_config_cfgte,
    output wire  pe3_config_cfgend,
    output wire [29:0] pe3_rvbaraddr_lw_rvbar31_2,
    input wire [11:0] pe3_rvbaraddr_up_rvbar43_32,
    input wire [3:0] host_rst_syn_syn,
    output wire [3:0] host_cpu_boot_msk_boot_msk,
    output reg  host_cpu_clus_pwr_req_mem_ret_req,
    output reg  host_cpu_clus_pwr_req_pwr_req,
    output reg  host_cpu_wake_up_core3_wakeup,
    output reg  host_cpu_wake_up_core2_wakeup,
    output reg  host_cpu_wake_up_core1_wakeup,
    output reg  host_cpu_wake_up_core0_wakeup,
    output reg  ext_sys0_rst_ctrl_rst_req,
    output wire  ext_sys0_rst_ctrl_cpuwait,
    input wire [1:0] ext_sys0_rst_st_rst_ack,
    input wire       set_extsys0_cpuwait,
    input  wire      extsys0_cpuwait_wen,
    output reg  ext_sys1_rst_ctrl_rst_req,
    output wire  ext_sys1_rst_ctrl_cpuwait,
    input wire [1:0] ext_sys1_rst_st_rst_ack,
    input wire       set_extsys1_cpuwait,
    input  wire      extsys1_cpuwait_wen,
    output reg [2:0] bsys_pwr_req_systop_pwr_req,
    output reg  bsys_pwr_req_dbgtop_pwr_req,
    output reg  bsys_pwr_req_refclk_req,
    output reg  bsys_pwr_req_wakeup_en,
    input wire [2:0] bsys_pwr_st_systop_pwr_st,
    input wire  bsys_pwr_st_dbgtop_pwr_st,
    output wire  host_sys_lctrl_st_int_rtr_lock,
    output wire  host_sys_lctrl_st_host_fw_lock,
    input wire [7:0] hostcpuclk_ctrl_clkselect_cur,
    output reg [7:0] hostcpuclk_ctrl_clkselect,
    input wire [4:0] hostcpuclk_div0_clkdiv_cur,
    output reg [4:0] hostcpuclk_div0_clkdiv,
    input wire [4:0] hostcpuclk_div1_clkdiv_cur,
    output reg [4:0] hostcpuclk_div1_clkdiv,
    output reg [7:0] gicclk_ctrl_entrydelay,
    input wire [7:0] gicclk_ctrl_clkselect_cur,
    output reg [7:0] gicclk_ctrl_clkselect,
    input wire [4:0] gicclk_div0_clkdiv_cur,
    output reg [4:0] gicclk_div0_clkdiv,
    output reg [7:0] aclk_ctrl_entrydelay,
    input wire [7:0] aclk_ctrl_clkselect_cur,
    output reg [7:0] aclk_ctrl_clkselect,
    input wire [4:0] aclk_div0_clkdiv_cur,
    output reg [4:0] aclk_div0_clkdiv,
    output reg [7:0] ctrlclk_ctrl_entrydelay,
    input wire [7:0] ctrlclk_ctrl_clkselect_cur,
    output reg [7:0] ctrlclk_ctrl_clkselect,
    input wire [4:0] ctrlclk_div0_clkdiv_cur,
    output reg [4:0] ctrlclk_div0_clkdiv,
    output reg [7:0] dbgclk_ctrl_entrydelay,
    input wire [7:0] dbgclk_ctrl_clkselect_cur,
    output reg [7:0] dbgclk_ctrl_clkselect,
    input wire [4:0] dbgclk_div0_clkdiv_cur,
    output reg [4:0] dbgclk_div0_clkdiv,
    input wire [2:0] hostuartclk_ctrl_clkselect_cur,
    output reg [2:0] hostuartclk_ctrl_clkselect,
    input wire [4:0] hostuartclk_div0_clkdiv_cur,
    output reg [4:0] hostuartclk_div0_clkdiv,
    output reg [7:0] refclk_ctrl_entrydelay,
    output wire  clkforce_st_refclk_force_st,
    output wire  clkforce_st_dbgclk_force_st,
    output wire  clkforce_st_ctrlclk_force_st,
    output wire  clkforce_st_aclk_force_st,
    output wire  clkforce_st_gicclk_force_st,
    input wire  pll_st_cpuplllock_st,
    input wire  pll_st_sysplllock_st,
    input wire  host_ppu_int_st_core3_int_st,
    input wire  host_ppu_int_st_core2_int_st,
    input wire  host_ppu_int_st_core1_int_st,
    input wire  host_ppu_int_st_core0_int_st,
    input wire  host_ppu_int_st_clustop_int_st,
    input wire  host_ppu_int_st_systop_int_st,
    input wire  host_ppu_int_st_dbgtop_int_st,
    input wire  host_ppu_int_st_fw_int_st,
    
    output reg   [9:0]  modify_lock_req,
    input  wire  [9:0]  modify_lock_ack,
    input  wire  [4:0]  host_lock_cpu
        
);

    reg [11:0] paddr_reg;
    reg        pready_reg;
    reg        pwrite_reg;
    reg        second_phase_reg;
    
       
    wire       is_valid_write;
    wire       is_lock_down;
    wire       [31:0] read_data;
    
    
    wire  host_sys_lctrl_st_lock_clr_dis;
    wire  host_sys_lctrl_st_host_lock;
    wire [4:0] host_sys_lctrl_st_host_lock_cpu;
    wire [31:0] host_sys_lctrl_set_set;
    wire [31:0] host_sys_lctrl_clr_set;
    wire [5:0] clkforce_set_set;
    wire [5:0] clkforce_clr_clr;

    reg pe0_config_aa64naa32_int;
    reg pe1_config_aa64naa32_int;
    reg pe1_config_vinithi_int;
    reg pe1_config_cfgte_int;
    reg pe1_config_cfgend_int;
    reg pe2_config_aa64naa32_int;
    reg pe2_config_vinithi_int;
    reg pe2_config_cfgte_int;
    reg pe2_config_cfgend_int;
    reg pe3_config_aa64naa32_int;
    reg pe3_config_vinithi_int;
    reg pe3_config_cfgte_int;
    reg pe3_config_cfgend_int;

    reg [29:0] pe0_rvbaraddr_lw_rvbar31_2_int;
    reg [29:0] pe1_rvbaraddr_lw_rvbar31_2_int;
    reg [29:0] pe2_rvbaraddr_lw_rvbar31_2_int;
    reg [29:0] pe3_rvbaraddr_lw_rvbar31_2_int;
    

    always @(posedge clk or negedge resetn)
    begin
      if (!resetn)
      begin
       second_phase_reg<=1'b0;
       pwrite_reg<=1'b0;
       paddr_reg<=12'd0;
       pready_reg<=1'b0;
       
        cluster_config_cryptodisable<=1'b0;
        pe0_config_aa64naa32_int<=1'd0;
        pe0_config_vinithi<=1'd0;
        pe0_config_cfgte<=1'd0;
        pe0_config_cfgend<=1'd0;
        pe0_rvbaraddr_lw_rvbar31_2_int<=30'd0;
        pe1_config_aa64naa32_int<=1'd0;
        pe1_config_vinithi_int<=1'd0;
        pe1_config_cfgte_int<=1'd0;
        pe1_config_cfgend_int<=1'd0;
        pe1_rvbaraddr_lw_rvbar31_2_int<=30'd0;
        pe2_config_aa64naa32_int<=1'd0;
        pe2_config_vinithi_int<=1'd0;
        pe2_config_cfgte_int<=1'd0;
        pe2_config_cfgend_int<=1'd0;
        pe2_rvbaraddr_lw_rvbar31_2_int<=30'd0;
        pe3_config_aa64naa32_int<=1'd0;
        pe3_config_vinithi_int<=1'd0;
        pe3_config_cfgte_int<=1'd0;
        pe3_config_cfgend_int<=1'd0;
        pe3_rvbaraddr_lw_rvbar31_2_int<=30'd0;
        host_cpu_clus_pwr_req_mem_ret_req<=1'b0;
        host_cpu_clus_pwr_req_pwr_req<=1'b0;
        host_cpu_wake_up_core3_wakeup<=1'b0;
        host_cpu_wake_up_core2_wakeup<=1'b0;
        host_cpu_wake_up_core1_wakeup<=1'b0;
        host_cpu_wake_up_core0_wakeup<=1'b0;
        ext_sys0_rst_ctrl_rst_req<=1'b0;
        ext_sys1_rst_ctrl_rst_req<=1'b0;
        bsys_pwr_req_systop_pwr_req<=3'b000;
        bsys_pwr_req_dbgtop_pwr_req<=1'b0;
        bsys_pwr_req_refclk_req<=1'b0;
        bsys_pwr_req_wakeup_en<=1'b0;
        hostcpuclk_ctrl_clkselect<=8'h01;
        hostcpuclk_div0_clkdiv<=5'h00;
        hostcpuclk_div1_clkdiv<=5'h00;
        gicclk_ctrl_entrydelay<=8'h00;
        gicclk_ctrl_clkselect<=8'h01;
        gicclk_div0_clkdiv<=5'h00;
        aclk_ctrl_entrydelay<=8'h00;
        aclk_ctrl_clkselect<=8'h01;
        aclk_div0_clkdiv<=5'h00;
        ctrlclk_ctrl_entrydelay<=8'h00;
        ctrlclk_ctrl_clkselect<=8'h01;
        ctrlclk_div0_clkdiv<=5'h00;
        dbgclk_ctrl_entrydelay<=8'h00;
        dbgclk_ctrl_clkselect<=8'h01;
        dbgclk_div0_clkdiv<=5'h00;
        hostuartclk_ctrl_clkselect<=3'b001;
        hostuartclk_div0_clkdiv<=5'h00;
        refclk_ctrl_entrydelay<=8'h00;
    
      end
      else
      begin       
  
        second_phase_reg<=psel && !penable;
        
        if(psel)
        begin
          if(!penable)
          begin
            paddr_reg<=paddr[11:0];                
            pwrite_reg<=pwrite;            
            pready_reg<=1'b1;
          end
          else
          begin 
            pready_reg<=1'b0;
            if(pready)
            begin
                pwrite_reg<=1'b0;
            end
          end
        end
        
        if(is_valid_write)
        begin          
         
                  
          if (paddr_reg == 12'h000)
          begin                
                    cluster_config_cryptodisable<=pwdata[0:0];
          end
                  
          if (paddr_reg == 12'h010)
          begin                
                    
                    pe0_config_aa64naa32_int<=pwdata[3:3];
                    pe0_config_vinithi<=pwdata[2:2];
                    pe0_config_cfgte<=pwdata[1:1];
                    pe0_config_cfgend<=pwdata[0:0];
          end
          
          if (paddr_reg == 12'h014)
          begin                
                    pe0_rvbaraddr_lw_rvbar31_2_int<=pwdata[31:2];
          end

          if (paddr_reg == 12'h020)
          begin                
                    pe1_config_aa64naa32_int<=pwdata[3:3];
                    pe1_config_vinithi_int<=pwdata[2:2];
                    pe1_config_cfgte_int<=pwdata[1:1];
                    pe1_config_cfgend_int<=pwdata[0:0];
          end

          if (paddr_reg == 12'h024)
          begin                
                    pe1_rvbaraddr_lw_rvbar31_2_int<=pwdata[31:2];
          end
                  
                  
          if (paddr_reg == 12'h030)
          begin                
                    pe2_config_aa64naa32_int<=pwdata[3:3];
                    pe2_config_vinithi_int<=pwdata[2:2];
                    pe2_config_cfgte_int<=pwdata[1:1];
                    pe2_config_cfgend_int<=pwdata[0:0];
          end

          if (paddr_reg == 12'h034)
          begin                
                    pe2_rvbaraddr_lw_rvbar31_2_int<=pwdata[31:2];
          end
                  
                  
          if (paddr_reg == 12'h040)
          begin                
                    pe3_config_aa64naa32_int<=pwdata[3:3];
                    pe3_config_vinithi_int<=pwdata[2:2];
                    pe3_config_cfgte_int<=pwdata[1:1];
                    pe3_config_cfgend_int<=pwdata[0:0];
          end
          
          if (paddr_reg == 12'h044)
          begin                
                    pe3_rvbaraddr_lw_rvbar31_2_int<=pwdata[31:2];
          end
                  
                  
          if (paddr_reg == 12'h304)
          begin                
                    host_cpu_clus_pwr_req_mem_ret_req<=pwdata[1:1];
                    host_cpu_clus_pwr_req_pwr_req<=pwdata[0:0];
          end
                  
          if (paddr_reg == 12'h308)
          begin                

                    host_cpu_wake_up_core0_wakeup<=pwdata[0:0];

                    if (HOST_CPU_NUM_CORES >= 2)
                    begin 
                        host_cpu_wake_up_core1_wakeup<=pwdata[1:1];
                    end
                    else
                    begin
                        host_cpu_wake_up_core1_wakeup<=1'b0;
                    end 

                    if (HOST_CPU_NUM_CORES >= 3)
                    begin 
                        host_cpu_wake_up_core2_wakeup<=pwdata[2:2];
                    end
                    else
                    begin
                        host_cpu_wake_up_core2_wakeup<=1'b0;
                    end 

                    if (HOST_CPU_NUM_CORES == 4)
                    begin 
                        host_cpu_wake_up_core3_wakeup<=pwdata[3:3];
                    end
                    else
                    begin
                        host_cpu_wake_up_core3_wakeup<=1'b0;
                    end 

          end
                  
          if (paddr_reg == 12'h310)
          begin                
                    ext_sys0_rst_ctrl_rst_req<=pwdata[1:1];
          end
                  
          if (paddr_reg == 12'h318)
          begin                
                    ext_sys1_rst_ctrl_rst_req<=pwdata[1:1];
          end
                  

                  
          if (paddr_reg == 12'h400)
          begin                
                    bsys_pwr_req_systop_pwr_req<=pwdata[5:3];
                    bsys_pwr_req_dbgtop_pwr_req<=pwdata[2:2];
                    bsys_pwr_req_refclk_req<=pwdata[1:1];
                    bsys_pwr_req_wakeup_en<=pwdata[0:0];
          end
                  
          if (paddr_reg == 12'h800)
          begin                
                    hostcpuclk_ctrl_clkselect<=pwdata[7:0];
          end
                  
          if (paddr_reg == 12'h804)
          begin                
                    hostcpuclk_div0_clkdiv<=pwdata[4:0];
          end
                  
          if (paddr_reg == 12'h808)
          begin                
                    hostcpuclk_div1_clkdiv<=pwdata[4:0];
          end
                  
          if (paddr_reg == 12'h810)
          begin                
                    gicclk_ctrl_entrydelay<=pwdata[31:24];
                    gicclk_ctrl_clkselect<=pwdata[7:0];
          end
                  
          if (paddr_reg == 12'h814)
          begin                
                    gicclk_div0_clkdiv<=pwdata[4:0];
          end
                  
          if (paddr_reg == 12'h820)
          begin                
                    aclk_ctrl_entrydelay<=pwdata[31:24];
                    aclk_ctrl_clkselect<=pwdata[7:0];
          end
                  
          if (paddr_reg == 12'h824)
          begin                
                    aclk_div0_clkdiv<=pwdata[4:0];
          end
                  
          if (paddr_reg == 12'h830)
          begin                
                    ctrlclk_ctrl_entrydelay<=pwdata[31:24];
                    ctrlclk_ctrl_clkselect<=pwdata[7:0];
          end
                  
          if (paddr_reg == 12'h834)
          begin                
                    ctrlclk_div0_clkdiv<=pwdata[4:0];
          end
                  
          if (paddr_reg == 12'h840)
          begin                
                    dbgclk_ctrl_entrydelay<=pwdata[31:24];
                    dbgclk_ctrl_clkselect<=pwdata[7:0];
          end
                  
          if (paddr_reg == 12'h844)
          begin                
                    dbgclk_div0_clkdiv<=pwdata[4:0];
          end
                  
          if (paddr_reg == 12'h850)
          begin                
                    hostuartclk_ctrl_clkselect<=pwdata[2:0];
          end
                  
          if (paddr_reg == 12'h854)
          begin                
                    hostuartclk_div0_clkdiv<=pwdata[4:0];
          end
                  
          if (paddr_reg == 12'h860)
          begin                
                    refclk_ctrl_entrydelay<=pwdata[31:24];
          end
        end
      end
    end

  wire [31:0] cluster_config_val;
  assign cluster_config_val[31:1]= 31'h0000000;
  assign cluster_config_val[0:0]= cluster_config_cryptodisable;

  wire [31:0] pe0_config_val;
  assign pe0_config_val[31:4]= 28'h0000000;
  assign pe0_config_val[3:3]= pe0_config_aa64naa32_int;
  assign pe0_config_aa64naa32 = pe0_config_aa64naa32_int;
  assign pe0_config_val[2:2]= pe0_config_vinithi;
  assign pe0_config_val[1:1]= pe0_config_cfgte;
  assign pe0_config_val[0:0]= pe0_config_cfgend;

  wire [31:0] pe0_rvbaraddr_lw_val;
  assign pe0_rvbaraddr_lw_val[31:2]= pe0_rvbaraddr_lw_rvbar31_2_int;
  assign pe0_rvbaraddr_lw_rvbar31_2 = pe0_rvbaraddr_lw_rvbar31_2_int;
  assign pe0_rvbaraddr_lw_val[1:0]= 2'b00;

  wire [31:0] pe0_rvbaraddr_up_val;
  assign pe0_rvbaraddr_up_val[31:12]= 20'h00000;
  assign pe0_rvbaraddr_up_val[11:0]= pe0_rvbaraddr_up_rvbar43_32;

  wire [31:0] pe1_config_val;
  assign pe1_config_val[31:4] = 28'h0000000;
    assign pe1_config_val[3:3]  = pe1_config_aa64naa32_int;
  assign pe1_config_aa64naa32 = pe1_config_aa64naa32_int;
    assign pe1_config_val[2:2] = pe1_config_vinithi_int;
  assign pe1_config_vinithi  = pe1_config_vinithi_int;
  assign pe1_config_val[1:1] = pe1_config_cfgte_int;
  assign pe1_config_cfgte    = pe1_config_cfgte_int;
  assign pe1_config_val[0:0] = pe1_config_cfgend_int;
  assign pe1_config_cfgend   = pe1_config_cfgend_int;
  
  wire [31:0] pe1_rvbaraddr_lw_val;
  assign pe1_rvbaraddr_lw_val[31:2] = pe1_rvbaraddr_lw_rvbar31_2_int;
  assign pe1_rvbaraddr_lw_rvbar31_2 = pe1_rvbaraddr_lw_rvbar31_2_int;
  assign pe1_rvbaraddr_lw_val[1:0]= 2'b00;
  wire [31:0] pe1_rvbaraddr_up_val;
  assign pe1_rvbaraddr_up_val[31:12]= 20'h00000;
  assign pe1_rvbaraddr_up_val[11:0] = pe1_rvbaraddr_up_rvbar43_32;

  wire [31:0] pe2_config_val;
  assign pe2_config_val[31:4] = 28'h0000000;
    assign pe2_config_val[3:3]  = pe2_config_aa64naa32_int;
  assign pe2_config_aa64naa32 = pe2_config_aa64naa32_int;
    assign pe2_config_val[2:2] = pe2_config_vinithi_int;
  assign pe2_config_vinithi  = pe2_config_vinithi_int;
  assign pe2_config_val[1:1] = pe2_config_cfgte_int;
  assign pe2_config_cfgte    = pe2_config_cfgte_int;
  assign pe2_config_val[0:0] = pe2_config_cfgend_int;
  assign pe2_config_cfgend   = pe2_config_cfgend_int;

  wire [31:0] pe2_rvbaraddr_lw_val;
  assign pe2_rvbaraddr_lw_val[31:2] = pe2_rvbaraddr_lw_rvbar31_2_int;
  assign pe2_rvbaraddr_lw_rvbar31_2 = pe2_rvbaraddr_lw_rvbar31_2_int;
  assign pe2_rvbaraddr_lw_val[1:0]= 2'b00;
  wire [31:0] pe2_rvbaraddr_up_val;
  assign pe2_rvbaraddr_up_val[31:12]= 20'h00000;
  assign pe2_rvbaraddr_up_val[11:0] = pe2_rvbaraddr_up_rvbar43_32;

  wire [31:0] pe3_config_val;
  assign pe3_config_val[31:4] = 28'h0000000;
    assign pe3_config_val[3:3]  = pe3_config_aa64naa32_int;
  assign pe3_config_aa64naa32 = pe3_config_aa64naa32_int;
    assign pe3_config_val[2:2] = pe3_config_vinithi_int;
  assign pe3_config_vinithi  = pe3_config_vinithi_int;
  assign pe3_config_val[1:1] = pe3_config_cfgte_int;
  assign pe3_config_cfgte    = pe3_config_cfgte_int;
  assign pe3_config_val[0:0] = pe3_config_cfgend_int;
  assign pe3_config_cfgend   = pe3_config_cfgend_int;

  wire [31:0] pe3_rvbaraddr_lw_val;
  assign pe3_rvbaraddr_lw_val[31:2] = pe3_rvbaraddr_lw_rvbar31_2_int;
  assign pe3_rvbaraddr_lw_rvbar31_2 = pe3_rvbaraddr_lw_rvbar31_2_int;
  assign pe3_rvbaraddr_lw_val[1:0]= 2'b00;
  wire [31:0] pe3_rvbaraddr_up_val;
  assign pe3_rvbaraddr_up_val[31:12]= 20'h00000;
  assign pe3_rvbaraddr_up_val[11:0] = pe3_rvbaraddr_up_rvbar43_32;

  wire [31:0] host_rst_syn_val;
  assign host_rst_syn_val[31:4]= 28'h0000000;
  wire [3:0] host_rst_syn_syn_dd;
  arm_element_cdc_capt_sync u_host_rst_syn_syn_0_sync ( .clk(clk), .nreset(resetn), .d_async (host_rst_syn_syn[0]),   .q(host_rst_syn_syn_dd[0]) );
  arm_element_cdc_capt_sync u_host_rst_syn_syn_1_sync ( .clk(clk), .nreset(resetn), .d_async (host_rst_syn_syn[1]),   .q(host_rst_syn_syn_dd[1]) );
  assign host_rst_syn_syn_dd[2] = 1'b0; 
  arm_element_cdc_capt_sync u_host_rst_syn_syn_3_sync ( .clk(clk), .nreset(resetn), .d_async (host_rst_syn_syn[3]),   .q(host_rst_syn_syn_dd[3]) );
  assign host_rst_syn_val[3:0]= host_rst_syn_syn_dd;

  wire [31:0] host_cpu_boot_msk_val;
  wire   host_cpu_boot_msk_pslverr;
  assign host_cpu_boot_msk_val[31:4]= 28'h0000000;
  wire   host_cpu_boot_msk_psel;
  assign host_cpu_boot_msk_psel = psel && (paddr == 12'h300);
  assign host_cpu_boot_msk_boot_msk  = host_cpu_boot_msk_val[3:0];

  wire [31:0] host_cpu_clus_pwr_req_val;
  assign host_cpu_clus_pwr_req_val[31:2]= 30'h00000000;
  assign host_cpu_clus_pwr_req_val[1:1]= host_cpu_clus_pwr_req_mem_ret_req;
  assign host_cpu_clus_pwr_req_val[0:0]= host_cpu_clus_pwr_req_pwr_req;

  wire [31:0] host_cpu_wake_up_val;
  assign host_cpu_wake_up_val[31:4]= 28'h0000000;
  assign host_cpu_wake_up_val[3:3]= host_cpu_wake_up_core3_wakeup;
  assign host_cpu_wake_up_val[2:2]= host_cpu_wake_up_core2_wakeup;
  assign host_cpu_wake_up_val[1:1]= host_cpu_wake_up_core1_wakeup;
  assign host_cpu_wake_up_val[0:0]= host_cpu_wake_up_core0_wakeup;

  wire [31:0] ext_sys0_rst_ctrl_val;
  assign ext_sys0_rst_ctrl_val[31:2]= 30'h00000000;
  assign ext_sys0_rst_ctrl_val[1:1]= ext_sys0_rst_ctrl_rst_req;
  wire   ext_sys0_rst_ctrl_psel;
  assign ext_sys0_rst_ctrl_psel = psel && (paddr == 12'h310);
  assign ext_sys0_rst_ctrl_cpuwait  = ext_sys0_rst_ctrl_val[0:0];

  wire [31:0] ext_sys0_rst_st_val;
  assign ext_sys0_rst_st_val[31:3]= 29'h000000;
  wire [1:0] ext_sys0_rst_st_rst_ack_dd;
  arm_element_cdc_capt_sync u_ext_sys0_rst_st_rst_ack_0_sync ( .clk(clk), .nreset(resetn), .d_async (ext_sys0_rst_st_rst_ack[0]),   .q(ext_sys0_rst_st_rst_ack_dd[0]) );
  arm_element_cdc_capt_sync u_ext_sys0_rst_st_rst_ack_1_sync ( .clk(clk), .nreset(resetn), .d_async (ext_sys0_rst_st_rst_ack[1]),   .q(ext_sys0_rst_st_rst_ack_dd[1]) );
  assign ext_sys0_rst_st_val[2:1]= ext_sys0_rst_st_rst_ack_dd;
  assign ext_sys0_rst_st_val[0:0]= 1'b0;

  wire [31:0] ext_sys1_rst_ctrl_val;
  assign ext_sys1_rst_ctrl_val[31:2]= 30'h00000000;
  assign ext_sys1_rst_ctrl_val[1:1]= ext_sys1_rst_ctrl_rst_req;
  wire   ext_sys1_rst_ctrl_psel;
  assign ext_sys1_rst_ctrl_psel = psel && (paddr == 12'h318);
  assign ext_sys1_rst_ctrl_cpuwait  = ext_sys1_rst_ctrl_val[0:0];

  wire [31:0] ext_sys1_rst_st_val;
  assign ext_sys1_rst_st_val[31:3]= 29'h000000;
  wire [1:0] ext_sys1_rst_st_rst_ack_dd;
  arm_element_cdc_capt_sync u_ext_sys1_rst_st_rst_ack_0_sync ( .clk(clk), .nreset(resetn), .d_async (ext_sys1_rst_st_rst_ack[0]),   .q(ext_sys1_rst_st_rst_ack_dd[0]) );
  arm_element_cdc_capt_sync u_ext_sys1_rst_st_rst_ack_1_sync ( .clk(clk), .nreset(resetn), .d_async (ext_sys1_rst_st_rst_ack[1]),   .q(ext_sys1_rst_st_rst_ack_dd[1]) );
  assign ext_sys1_rst_st_val[2:1]= ext_sys1_rst_st_rst_ack_dd;
  assign ext_sys1_rst_st_val[0:0]= 1'b0;

  wire [31:0] bsys_pwr_req_val;
  assign bsys_pwr_req_val[31:6]= 26'h0000000;
  assign bsys_pwr_req_val[5:3]= bsys_pwr_req_systop_pwr_req;
  assign bsys_pwr_req_val[2:2]= bsys_pwr_req_dbgtop_pwr_req;
  assign bsys_pwr_req_val[1:1]= bsys_pwr_req_refclk_req;
  assign bsys_pwr_req_val[0:0]= bsys_pwr_req_wakeup_en;

  wire [31:0] bsys_pwr_st_val;
  assign bsys_pwr_st_val[31:6]= 26'h0000000;
  assign bsys_pwr_st_val[5:3]= bsys_pwr_st_systop_pwr_st;
  assign bsys_pwr_st_val[2:2]= bsys_pwr_st_dbgtop_pwr_st;
  assign bsys_pwr_st_val[1:1]= 1'b0;
  assign bsys_pwr_st_val[0:0]= 1'b0;

  wire [31:0] host_sys_lctrl_st_val;
  assign host_sys_lctrl_st_lock_clr_dis  = host_sys_lctrl_st_val[31:31];
  assign host_sys_lctrl_st_val[30:8]= 23'b00000000000000000000000;
  assign host_sys_lctrl_st_host_lock  = host_sys_lctrl_st_val[7:7];
  assign host_sys_lctrl_st_host_lock_cpu  = host_sys_lctrl_st_val[6:2];
  assign host_sys_lctrl_st_int_rtr_lock  = host_sys_lctrl_st_val[1:1];
  assign host_sys_lctrl_st_host_fw_lock  = host_sys_lctrl_st_val[0:0];

  wire [31:0] host_sys_lctrl_set_val;
  wire   host_sys_lctrl_set_pready;
  wire   host_sys_lctrl_set_psel;
  assign host_sys_lctrl_set_psel = psel && (paddr == 12'h504);

  wire [31:0] host_sys_lctrl_clr_val;
  wire   host_sys_lctrl_clr_pready;
  wire   host_sys_lctrl_clr_psel;
  assign host_sys_lctrl_clr_psel = psel && (paddr == 12'h508);

  wire [31:0] hostcpuclk_ctrl_val;
  assign hostcpuclk_ctrl_val[31:16]= 16'h0000;
  wire [7:0] hostcpuclk_ctrl_clkselect_cur_dd;
  arm_element_cdc_capt_sync u_hostcpuclk_ctrl_clkselect_cur_0_sync ( .clk(clk), .nreset(resetn), .d_async (hostcpuclk_ctrl_clkselect_cur[0]),   .q(hostcpuclk_ctrl_clkselect_cur_dd[0]) );
  arm_element_cdc_capt_sync u_hostcpuclk_ctrl_clkselect_cur_1_sync ( .clk(clk), .nreset(resetn), .d_async (hostcpuclk_ctrl_clkselect_cur[1]),   .q(hostcpuclk_ctrl_clkselect_cur_dd[1]) );
  arm_element_cdc_capt_sync u_hostcpuclk_ctrl_clkselect_cur_2_sync ( .clk(clk), .nreset(resetn), .d_async (hostcpuclk_ctrl_clkselect_cur[2]),   .q(hostcpuclk_ctrl_clkselect_cur_dd[2]) );
  assign hostcpuclk_ctrl_clkselect_cur_dd[7:3] = 5'h0; 
  assign hostcpuclk_ctrl_val[15:8]= hostcpuclk_ctrl_clkselect_cur_dd;
  assign hostcpuclk_ctrl_val[7:0]= hostcpuclk_ctrl_clkselect;

  wire [31:0] hostcpuclk_div0_val;
  assign hostcpuclk_div0_val[31:21]= 11'h000;
  wire [4:0] hostcpuclk_div0_clkdiv_cur_dd;
  arm_element_cdc_capt_sync u_hostcpuclk_div0_clkdiv_cur_0_sync ( .clk(clk), .nreset(resetn), .d_async (hostcpuclk_div0_clkdiv_cur[0]),   .q(hostcpuclk_div0_clkdiv_cur_dd[0]) );
  arm_element_cdc_capt_sync u_hostcpuclk_div0_clkdiv_cur_1_sync ( .clk(clk), .nreset(resetn), .d_async (hostcpuclk_div0_clkdiv_cur[1]),   .q(hostcpuclk_div0_clkdiv_cur_dd[1]) );
  arm_element_cdc_capt_sync u_hostcpuclk_div0_clkdiv_cur_2_sync ( .clk(clk), .nreset(resetn), .d_async (hostcpuclk_div0_clkdiv_cur[2]),   .q(hostcpuclk_div0_clkdiv_cur_dd[2]) );
  arm_element_cdc_capt_sync u_hostcpuclk_div0_clkdiv_cur_3_sync ( .clk(clk), .nreset(resetn), .d_async (hostcpuclk_div0_clkdiv_cur[3]),   .q(hostcpuclk_div0_clkdiv_cur_dd[3]) );
  arm_element_cdc_capt_sync u_hostcpuclk_div0_clkdiv_cur_4_sync ( .clk(clk), .nreset(resetn), .d_async (hostcpuclk_div0_clkdiv_cur[4]),   .q(hostcpuclk_div0_clkdiv_cur_dd[4]) );
  assign hostcpuclk_div0_val[20:16]= hostcpuclk_div0_clkdiv_cur_dd;
  assign hostcpuclk_div0_val[15:5]= 11'h000;
  assign hostcpuclk_div0_val[4:0]= hostcpuclk_div0_clkdiv;

  wire [31:0] hostcpuclk_div1_val;
  assign hostcpuclk_div1_val[31:21]= 11'h000;
  wire [4:0] hostcpuclk_div1_clkdiv_cur_dd;
  arm_element_cdc_capt_sync u_hostcpuclk_div1_clkdiv_cur_0_sync ( .clk(clk), .nreset(resetn), .d_async (hostcpuclk_div1_clkdiv_cur[0]),   .q(hostcpuclk_div1_clkdiv_cur_dd[0]) );
  arm_element_cdc_capt_sync u_hostcpuclk_div1_clkdiv_cur_1_sync ( .clk(clk), .nreset(resetn), .d_async (hostcpuclk_div1_clkdiv_cur[1]),   .q(hostcpuclk_div1_clkdiv_cur_dd[1]) );
  arm_element_cdc_capt_sync u_hostcpuclk_div1_clkdiv_cur_2_sync ( .clk(clk), .nreset(resetn), .d_async (hostcpuclk_div1_clkdiv_cur[2]),   .q(hostcpuclk_div1_clkdiv_cur_dd[2]) );
  arm_element_cdc_capt_sync u_hostcpuclk_div1_clkdiv_cur_3_sync ( .clk(clk), .nreset(resetn), .d_async (hostcpuclk_div1_clkdiv_cur[3]),   .q(hostcpuclk_div1_clkdiv_cur_dd[3]) );
  arm_element_cdc_capt_sync u_hostcpuclk_div1_clkdiv_cur_4_sync ( .clk(clk), .nreset(resetn), .d_async (hostcpuclk_div1_clkdiv_cur[4]),   .q(hostcpuclk_div1_clkdiv_cur_dd[4]) );
  assign hostcpuclk_div1_val[20:16]= hostcpuclk_div1_clkdiv_cur_dd;
  assign hostcpuclk_div1_val[15:5]= 11'h000;
  assign hostcpuclk_div1_val[4:0]= hostcpuclk_div1_clkdiv;

  wire [31:0] gicclk_ctrl_val;
  assign gicclk_ctrl_val[31:24]= gicclk_ctrl_entrydelay;
  assign gicclk_ctrl_val[23:16]= 8'h0;
  wire [7:0] gicclk_ctrl_clkselect_cur_dd;
  arm_element_cdc_capt_sync u_gicclk_ctrl_clkselect_cur_0_sync ( .clk(clk), .nreset(resetn), .d_async (gicclk_ctrl_clkselect_cur[0]),   .q(gicclk_ctrl_clkselect_cur_dd[0]) );
  arm_element_cdc_capt_sync u_gicclk_ctrl_clkselect_cur_1_sync ( .clk(clk), .nreset(resetn), .d_async (gicclk_ctrl_clkselect_cur[1]),   .q(gicclk_ctrl_clkselect_cur_dd[1]) );
  assign gicclk_ctrl_clkselect_cur_dd[7:2] = 6'h0;  
  assign gicclk_ctrl_val[15:8]= gicclk_ctrl_clkselect_cur_dd;
  assign gicclk_ctrl_val[7:0]= gicclk_ctrl_clkselect;

  wire [31:0] gicclk_div0_val;
  assign gicclk_div0_val[31:21]= 11'h000;
  wire [4:0] gicclk_div0_clkdiv_cur_dd;
  arm_element_cdc_capt_sync u_gicclk_div0_clkdiv_cur_0_sync ( .clk(clk), .nreset(resetn), .d_async (gicclk_div0_clkdiv_cur[0]),   .q(gicclk_div0_clkdiv_cur_dd[0]) );
  arm_element_cdc_capt_sync u_gicclk_div0_clkdiv_cur_1_sync ( .clk(clk), .nreset(resetn), .d_async (gicclk_div0_clkdiv_cur[1]),   .q(gicclk_div0_clkdiv_cur_dd[1]) );
  arm_element_cdc_capt_sync u_gicclk_div0_clkdiv_cur_2_sync ( .clk(clk), .nreset(resetn), .d_async (gicclk_div0_clkdiv_cur[2]),   .q(gicclk_div0_clkdiv_cur_dd[2]) );
  arm_element_cdc_capt_sync u_gicclk_div0_clkdiv_cur_3_sync ( .clk(clk), .nreset(resetn), .d_async (gicclk_div0_clkdiv_cur[3]),   .q(gicclk_div0_clkdiv_cur_dd[3]) );
  arm_element_cdc_capt_sync u_gicclk_div0_clkdiv_cur_4_sync ( .clk(clk), .nreset(resetn), .d_async (gicclk_div0_clkdiv_cur[4]),   .q(gicclk_div0_clkdiv_cur_dd[4]) );
  assign gicclk_div0_val[20:16]= gicclk_div0_clkdiv_cur_dd;
  assign gicclk_div0_val[15:5]= 11'h000;
  assign gicclk_div0_val[4:0]= gicclk_div0_clkdiv;

  wire [31:0] aclk_ctrl_val;
  assign aclk_ctrl_val[31:24]= aclk_ctrl_entrydelay;
  assign aclk_ctrl_val[23:16]= 8'h0;
  wire [7:0] aclk_ctrl_clkselect_cur_dd;
  arm_element_cdc_capt_sync u_aclk_ctrl_clkselect_cur_0_sync ( .clk(clk), .nreset(resetn), .d_async (aclk_ctrl_clkselect_cur[0]),   .q(aclk_ctrl_clkselect_cur_dd[0]) );
  arm_element_cdc_capt_sync u_aclk_ctrl_clkselect_cur_1_sync ( .clk(clk), .nreset(resetn), .d_async (aclk_ctrl_clkselect_cur[1]),   .q(aclk_ctrl_clkselect_cur_dd[1]) );
  assign aclk_ctrl_clkselect_cur_dd[7:2] = 6'h0; 
  assign aclk_ctrl_val[15:8]= aclk_ctrl_clkselect_cur_dd;
  assign aclk_ctrl_val[7:0]= aclk_ctrl_clkselect;

  wire [31:0] aclk_div0_val;
  assign aclk_div0_val[31:21]= 11'h000;
  wire [4:0] aclk_div0_clkdiv_cur_dd;
  arm_element_cdc_capt_sync u_aclk_div0_clkdiv_cur_0_sync ( .clk(clk), .nreset(resetn), .d_async (aclk_div0_clkdiv_cur[0]),   .q(aclk_div0_clkdiv_cur_dd[0]) );
  arm_element_cdc_capt_sync u_aclk_div0_clkdiv_cur_1_sync ( .clk(clk), .nreset(resetn), .d_async (aclk_div0_clkdiv_cur[1]),   .q(aclk_div0_clkdiv_cur_dd[1]) );
  arm_element_cdc_capt_sync u_aclk_div0_clkdiv_cur_2_sync ( .clk(clk), .nreset(resetn), .d_async (aclk_div0_clkdiv_cur[2]),   .q(aclk_div0_clkdiv_cur_dd[2]) );
  arm_element_cdc_capt_sync u_aclk_div0_clkdiv_cur_3_sync ( .clk(clk), .nreset(resetn), .d_async (aclk_div0_clkdiv_cur[3]),   .q(aclk_div0_clkdiv_cur_dd[3]) );
  arm_element_cdc_capt_sync u_aclk_div0_clkdiv_cur_4_sync ( .clk(clk), .nreset(resetn), .d_async (aclk_div0_clkdiv_cur[4]),   .q(aclk_div0_clkdiv_cur_dd[4]) );
  assign aclk_div0_val[20:16]= aclk_div0_clkdiv_cur_dd;
  assign aclk_div0_val[15:5]= 11'h000;
  assign aclk_div0_val[4:0]= aclk_div0_clkdiv;

  wire [31:0] ctrlclk_ctrl_val;
  assign ctrlclk_ctrl_val[31:24]= ctrlclk_ctrl_entrydelay;
  assign ctrlclk_ctrl_val[23:16]= 8'h0;
  wire [7:0] ctrlclk_ctrl_clkselect_cur_dd;
  arm_element_cdc_capt_sync u_ctrlclk_ctrl_clkselect_cur_0_sync ( .clk(clk), .nreset(resetn), .d_async (ctrlclk_ctrl_clkselect_cur[0]),   .q(ctrlclk_ctrl_clkselect_cur_dd[0]) );
  arm_element_cdc_capt_sync u_ctrlclk_ctrl_clkselect_cur_1_sync ( .clk(clk), .nreset(resetn), .d_async (ctrlclk_ctrl_clkselect_cur[1]),   .q(ctrlclk_ctrl_clkselect_cur_dd[1]) );
  assign ctrlclk_ctrl_clkselect_cur_dd[7:2] = 6'h0; 
  assign ctrlclk_ctrl_val[15:8]= ctrlclk_ctrl_clkselect_cur_dd;
  assign ctrlclk_ctrl_val[7:0]= ctrlclk_ctrl_clkselect;

  wire [31:0] ctrlclk_div0_val;
  assign ctrlclk_div0_val[31:21]= 11'h000;
  wire [4:0] ctrlclk_div0_clkdiv_cur_dd;
  arm_element_cdc_capt_sync u_ctrlclk_div0_clkdiv_cur_0_sync ( .clk(clk), .nreset(resetn), .d_async (ctrlclk_div0_clkdiv_cur[0]),   .q(ctrlclk_div0_clkdiv_cur_dd[0]) );
  arm_element_cdc_capt_sync u_ctrlclk_div0_clkdiv_cur_1_sync ( .clk(clk), .nreset(resetn), .d_async (ctrlclk_div0_clkdiv_cur[1]),   .q(ctrlclk_div0_clkdiv_cur_dd[1]) );
  arm_element_cdc_capt_sync u_ctrlclk_div0_clkdiv_cur_2_sync ( .clk(clk), .nreset(resetn), .d_async (ctrlclk_div0_clkdiv_cur[2]),   .q(ctrlclk_div0_clkdiv_cur_dd[2]) );
  arm_element_cdc_capt_sync u_ctrlclk_div0_clkdiv_cur_3_sync ( .clk(clk), .nreset(resetn), .d_async (ctrlclk_div0_clkdiv_cur[3]),   .q(ctrlclk_div0_clkdiv_cur_dd[3]) );
  arm_element_cdc_capt_sync u_ctrlclk_div0_clkdiv_cur_4_sync ( .clk(clk), .nreset(resetn), .d_async (ctrlclk_div0_clkdiv_cur[4]),   .q(ctrlclk_div0_clkdiv_cur_dd[4]) );
  assign ctrlclk_div0_val[20:16]= ctrlclk_div0_clkdiv_cur_dd;
  assign ctrlclk_div0_val[15:5]= 11'h000;
  assign ctrlclk_div0_val[4:0]= ctrlclk_div0_clkdiv;

  wire [31:0] dbgclk_ctrl_val;
  assign dbgclk_ctrl_val[31:24]= dbgclk_ctrl_entrydelay;
  assign dbgclk_ctrl_val[23:16]= 8'h0;
  wire [7:0] dbgclk_ctrl_clkselect_cur_dd;
  arm_element_cdc_capt_sync u_dbgclk_ctrl_clkselect_cur_0_sync ( .clk(clk), .nreset(resetn), .d_async (dbgclk_ctrl_clkselect_cur[0]),   .q(dbgclk_ctrl_clkselect_cur_dd[0]) );
  arm_element_cdc_capt_sync u_dbgclk_ctrl_clkselect_cur_1_sync ( .clk(clk), .nreset(resetn), .d_async (dbgclk_ctrl_clkselect_cur[1]),   .q(dbgclk_ctrl_clkselect_cur_dd[1]) );
  assign dbgclk_ctrl_clkselect_cur_dd[7:2] = 6'h0; 
  assign dbgclk_ctrl_val[15:8]= dbgclk_ctrl_clkselect_cur_dd;
  assign dbgclk_ctrl_val[7:0]= dbgclk_ctrl_clkselect;

  wire [31:0] dbgclk_div0_val;
  assign dbgclk_div0_val[31:21]= 11'h000;
  wire [4:0] dbgclk_div0_clkdiv_cur_dd;
  arm_element_cdc_capt_sync u_dbgclk_div0_clkdiv_cur_0_sync ( .clk(clk), .nreset(resetn), .d_async (dbgclk_div0_clkdiv_cur[0]),   .q(dbgclk_div0_clkdiv_cur_dd[0]) );
  arm_element_cdc_capt_sync u_dbgclk_div0_clkdiv_cur_1_sync ( .clk(clk), .nreset(resetn), .d_async (dbgclk_div0_clkdiv_cur[1]),   .q(dbgclk_div0_clkdiv_cur_dd[1]) );
  arm_element_cdc_capt_sync u_dbgclk_div0_clkdiv_cur_2_sync ( .clk(clk), .nreset(resetn), .d_async (dbgclk_div0_clkdiv_cur[2]),   .q(dbgclk_div0_clkdiv_cur_dd[2]) );
  arm_element_cdc_capt_sync u_dbgclk_div0_clkdiv_cur_3_sync ( .clk(clk), .nreset(resetn), .d_async (dbgclk_div0_clkdiv_cur[3]),   .q(dbgclk_div0_clkdiv_cur_dd[3]) );
  arm_element_cdc_capt_sync u_dbgclk_div0_clkdiv_cur_4_sync ( .clk(clk), .nreset(resetn), .d_async (dbgclk_div0_clkdiv_cur[4]),   .q(dbgclk_div0_clkdiv_cur_dd[4]) );
  assign dbgclk_div0_val[20:16]= dbgclk_div0_clkdiv_cur_dd;
  assign dbgclk_div0_val[15:5]= 11'h000;
  assign dbgclk_div0_val[4:0]= dbgclk_div0_clkdiv;

  wire [31:0] hostuartclk_ctrl_val;
  assign hostuartclk_ctrl_val[31:11]= 21'h0000;
  wire [2:0] hostuartclk_ctrl_clkselect_cur_dd;
  arm_element_cdc_capt_sync u_hostuartclk_ctrl_clkselect_cur_0_sync ( .clk(clk), .nreset(resetn), .d_async (hostuartclk_ctrl_clkselect_cur[0]),   .q(hostuartclk_ctrl_clkselect_cur_dd[0]) );
  arm_element_cdc_capt_sync u_hostuartclk_ctrl_clkselect_cur_1_sync ( .clk(clk), .nreset(resetn), .d_async (hostuartclk_ctrl_clkselect_cur[1]),   .q(hostuartclk_ctrl_clkselect_cur_dd[1]) );
  arm_element_cdc_capt_sync u_hostuartclk_ctrl_clkselect_cur_2_sync ( .clk(clk), .nreset(resetn), .d_async (hostuartclk_ctrl_clkselect_cur[2]),   .q(hostuartclk_ctrl_clkselect_cur_dd[2]) );
  assign hostuartclk_ctrl_val[10:8]= hostuartclk_ctrl_clkselect_cur_dd;
  assign hostuartclk_ctrl_val[7:3]= 5'b00000;
  assign hostuartclk_ctrl_val[2:0]= hostuartclk_ctrl_clkselect;

  wire [31:0] hostuartclk_div0_val;
  assign hostuartclk_div0_val[31:21]= 11'h000;
  wire [4:0] hostuartclk_div0_clkdiv_cur_dd;
  arm_element_cdc_capt_sync u_hostuartclk_div0_clkdiv_cur_0_sync ( .clk(clk), .nreset(resetn), .d_async (hostuartclk_div0_clkdiv_cur[0]),   .q(hostuartclk_div0_clkdiv_cur_dd[0]) );
  arm_element_cdc_capt_sync u_hostuartclk_div0_clkdiv_cur_1_sync ( .clk(clk), .nreset(resetn), .d_async (hostuartclk_div0_clkdiv_cur[1]),   .q(hostuartclk_div0_clkdiv_cur_dd[1]) );
  arm_element_cdc_capt_sync u_hostuartclk_div0_clkdiv_cur_2_sync ( .clk(clk), .nreset(resetn), .d_async (hostuartclk_div0_clkdiv_cur[2]),   .q(hostuartclk_div0_clkdiv_cur_dd[2]) );
  arm_element_cdc_capt_sync u_hostuartclk_div0_clkdiv_cur_3_sync ( .clk(clk), .nreset(resetn), .d_async (hostuartclk_div0_clkdiv_cur[3]),   .q(hostuartclk_div0_clkdiv_cur_dd[3]) );
  arm_element_cdc_capt_sync u_hostuartclk_div0_clkdiv_cur_4_sync ( .clk(clk), .nreset(resetn), .d_async (hostuartclk_div0_clkdiv_cur[4]),   .q(hostuartclk_div0_clkdiv_cur_dd[4]) );
  assign hostuartclk_div0_val[20:16]= hostuartclk_div0_clkdiv_cur_dd;
  assign hostuartclk_div0_val[15:5]= 11'h000;
  assign hostuartclk_div0_val[4:0]= hostuartclk_div0_clkdiv;

  wire [31:0] refclk_ctrl_val;
  assign refclk_ctrl_val[31:24]= refclk_ctrl_entrydelay;
  assign refclk_ctrl_val[23:16]= 8'h0;
  assign refclk_ctrl_val[15:8]= 8'd01;
  assign refclk_ctrl_val[7:0]= 8'd01;

  wire [31:0] clkforce_st_val;
  assign clkforce_st_val[31:7]= 25'h0000000;
  assign clkforce_st_refclk_force_st  = clkforce_st_val[6:6];
  assign clkforce_st_val[5:5]= 1'b0;
  assign clkforce_st_dbgclk_force_st  = clkforce_st_val[4:4];
  assign clkforce_st_ctrlclk_force_st  = clkforce_st_val[3:3];
  assign clkforce_st_aclk_force_st  = clkforce_st_val[2:2];
  assign clkforce_st_val[1:1]= 1'd0;
  assign clkforce_st_gicclk_force_st = 1'b0;
  assign clkforce_st_val[0:0]= 1'b0;

  wire [31:0] clkforce_set_val;
  assign clkforce_set_val[31:7]= 25'h0000000;
  wire   clkforce_set_psel;
  assign clkforce_set_psel = psel && (paddr == 12'hA04);
  assign clkforce_set_val[0:0]= 1'b0;

  wire [31:0] clkforce_clr_val;
  assign clkforce_clr_val[31:7]= 25'h0000000;
  wire   clkforce_clr_psel;
  assign clkforce_clr_psel = psel && (paddr == 12'hA08);
  assign clkforce_clr_val[0:0]= 1'b0;

  wire [31:0] pll_st_val;
  assign pll_st_val[31:2]= 30'h0000000;
  wire  pll_st_cpuplllock_st_dd;
  arm_element_cdc_capt_sync u_pll_st_cpuplllock_st_sync ( .clk(clk), .nreset(resetn), .d_async (pll_st_cpuplllock_st),   .q(pll_st_cpuplllock_st_dd) );
  assign pll_st_val[1:1]= pll_st_cpuplllock_st_dd;
  wire  pll_st_sysplllock_st_dd;
  arm_element_cdc_capt_sync u_pll_st_sysplllock_st_sync ( .clk(clk), .nreset(resetn), .d_async (pll_st_sysplllock_st),   .q(pll_st_sysplllock_st_dd) );
  assign pll_st_val[0:0]= pll_st_sysplllock_st_dd;

  wire [31:0] host_ppu_int_st_val;
  assign host_ppu_int_st_val[31:8]= 24'h000000;
  wire  host_ppu_int_st_core3_int_st_dd;
  arm_element_cdc_capt_sync u_host_ppu_int_st_core3_int_st_sync ( .clk(clk), .nreset(resetn), .d_async (host_ppu_int_st_core3_int_st),   .q(host_ppu_int_st_core3_int_st_dd) );
  assign host_ppu_int_st_val[7:7]= host_ppu_int_st_core3_int_st_dd;
  wire  host_ppu_int_st_core2_int_st_dd;
  arm_element_cdc_capt_sync u_host_ppu_int_st_core2_int_st_sync ( .clk(clk), .nreset(resetn), .d_async (host_ppu_int_st_core2_int_st),   .q(host_ppu_int_st_core2_int_st_dd) );
  assign host_ppu_int_st_val[6:6]= host_ppu_int_st_core2_int_st_dd;
  wire  host_ppu_int_st_core1_int_st_dd;
  arm_element_cdc_capt_sync u_host_ppu_int_st_core1_int_st_sync ( .clk(clk), .nreset(resetn), .d_async (host_ppu_int_st_core1_int_st),   .q(host_ppu_int_st_core1_int_st_dd) );
  assign host_ppu_int_st_val[5:5]= host_ppu_int_st_core1_int_st_dd;
  wire  host_ppu_int_st_core0_int_st_dd;
  arm_element_cdc_capt_sync u_host_ppu_int_st_core0_int_st_sync ( .clk(clk), .nreset(resetn), .d_async (host_ppu_int_st_core0_int_st),   .q(host_ppu_int_st_core0_int_st_dd) );
  assign host_ppu_int_st_val[4:4]= host_ppu_int_st_core0_int_st_dd;
  wire  host_ppu_int_st_clustop_int_st_dd;
  arm_element_cdc_capt_sync u_host_ppu_int_st_clustop_int_st_sync ( .clk(clk), .nreset(resetn), .d_async (host_ppu_int_st_clustop_int_st),   .q(host_ppu_int_st_clustop_int_st_dd) );
  assign host_ppu_int_st_val[3:3]= host_ppu_int_st_clustop_int_st_dd;
  wire  host_ppu_int_st_systop_int_st_dd;
  arm_element_cdc_capt_sync u_host_ppu_int_st_systop_int_st_sync ( .clk(clk), .nreset(resetn), .d_async (host_ppu_int_st_systop_int_st),   .q(host_ppu_int_st_systop_int_st_dd) );
  assign host_ppu_int_st_val[2:2]= host_ppu_int_st_systop_int_st_dd;
  wire  host_ppu_int_st_dbgtop_int_st_dd;
  arm_element_cdc_capt_sync u_host_ppu_int_st_dbgtop_int_st_sync ( .clk(clk), .nreset(resetn), .d_async (host_ppu_int_st_dbgtop_int_st),   .q(host_ppu_int_st_dbgtop_int_st_dd) );
  assign host_ppu_int_st_val[1:1]= host_ppu_int_st_dbgtop_int_st_dd;
  wire  host_ppu_int_st_fw_int_st_dd;
  arm_element_cdc_capt_sync u_host_ppu_int_st_fw_int_st_sync ( .clk(clk), .nreset(resetn), .d_async (host_ppu_int_st_fw_int_st),   .q(host_ppu_int_st_fw_int_st_dd) );
  assign host_ppu_int_st_val[0:0]= host_ppu_int_st_fw_int_st_dd;

  wire [31:0] pid4_val;
  assign pid4_val[31:8]= 24'h000000;
  assign pid4_val[7:4]= 4'h0;
  assign pid4_val[3:0]= 4'h4;

  wire [31:0] pid5_val;
  assign pid5_val[31:0]= 32'h00000000;

  wire [31:0] pid6_val;
  assign pid6_val[31:0]= 32'h00000000;

  wire [31:0] pid7_val;
  assign pid7_val[31:0]= 32'h00000000;

  wire [31:0] pid0_val;
  assign pid0_val[31:8]= 24'h000000;
  assign pid0_val[7:0]= 8'h78;

  wire [31:0] pid1_val;
  assign pid1_val[31:8]= 24'h000000;
  assign pid1_val[7:4]= 4'hB;
  assign pid1_val[3:0]= 4'h0;

  wire [31:0] pid2_val;
  assign pid2_val[31:8]= 24'h000000;
 arm_element_ecorevnum #( .WIDTH (4), .ECOREVVAL(4'h0) ) u_pid2_0( .ecorevnum( pid2_val[7:4]) );
  assign pid2_val[3:3]= 1'b1;
  assign pid2_val[2:0]= 3'b011;

  wire [31:0] pid3_val;
  assign pid3_val[31:8]= 24'h000000;
 arm_element_ecorevnum #( .WIDTH (4), .ECOREVVAL(4'h0) ) u_pid3_0( .ecorevnum( pid3_val[7:4]) );
  assign pid3_val[3:0]= 4'h0;

  wire [31:0] cid0_val;
  assign cid0_val[31:8]= 24'h000000;
  assign cid0_val[7:0]= 8'h0D;

  wire [31:0] cid1_val;
  assign cid1_val[31:8]= 24'h000000;
  assign cid1_val[7:4]= 4'hF;
  assign cid1_val[3:0]= 4'h0;

  wire [31:0] cid2_val;
  assign cid2_val[31:8]= 24'h000000;
  assign cid2_val[7:0]= 8'h05;

  wire [31:0] cid3_val;
  assign cid3_val[31:8]= 24'h000000;
  assign cid3_val[7:0]= 8'hB1;
  
  assign is_lock_down =
          paddr_reg ==  12'h000 ? host_sys_lctrl_st_host_lock:
          paddr_reg ==  12'h010 ? host_sys_lctrl_st_host_lock:
          paddr_reg ==  12'h014 ? host_sys_lctrl_st_host_lock:
          paddr_reg ==  12'h018 ? host_sys_lctrl_st_host_lock:
          paddr_reg ==  12'h020 ? host_sys_lctrl_st_host_lock:
          paddr_reg ==  12'h024 ? host_sys_lctrl_st_host_lock:
          paddr_reg ==  12'h028 ? host_sys_lctrl_st_host_lock:
          paddr_reg ==  12'h030 ? host_sys_lctrl_st_host_lock:
          paddr_reg ==  12'h034 ? host_sys_lctrl_st_host_lock:
          paddr_reg ==  12'h038 ? host_sys_lctrl_st_host_lock:
          paddr_reg ==  12'h040 ? host_sys_lctrl_st_host_lock:
          paddr_reg ==  12'h044 ? host_sys_lctrl_st_host_lock:
          paddr_reg ==  12'h048 ? host_sys_lctrl_st_host_lock:
          paddr_reg ==  12'h300 ? host_sys_lctrl_st_host_lock:
          1'b0;

  
  
  assign read_data = 
         paddr_reg ==  12'h000 ? cluster_config_val:
         paddr_reg ==  12'h010 ? pe0_config_val:
         paddr_reg ==  12'h014 ? pe0_rvbaraddr_lw_val:
         paddr_reg ==  12'h018 ? pe0_rvbaraddr_up_val:
         paddr_reg ==  12'h020 ? pe1_config_val:
         paddr_reg ==  12'h024 ? pe1_rvbaraddr_lw_val:
         paddr_reg ==  12'h028 ? pe1_rvbaraddr_up_val:
         paddr_reg ==  12'h030 ? pe2_config_val:
         paddr_reg ==  12'h034 ? pe2_rvbaraddr_lw_val:
         paddr_reg ==  12'h038 ? pe2_rvbaraddr_up_val:
         paddr_reg ==  12'h040 ? pe3_config_val:
         paddr_reg ==  12'h044 ? pe3_rvbaraddr_lw_val:
         paddr_reg ==  12'h048 ? pe3_rvbaraddr_up_val:
         paddr_reg ==  12'h200 ? host_rst_syn_val:
         paddr_reg ==  12'h300 ? host_cpu_boot_msk_val:
         paddr_reg ==  12'h304 ? host_cpu_clus_pwr_req_val:
         paddr_reg ==  12'h308 ? host_cpu_wake_up_val:
         paddr_reg ==  12'h310 ? ext_sys0_rst_ctrl_val:
         paddr_reg ==  12'h314 ? ext_sys0_rst_st_val:
         paddr_reg ==  12'h318 ? ext_sys1_rst_ctrl_val:
         paddr_reg ==  12'h31C ? ext_sys1_rst_st_val:
         paddr_reg ==  12'h400 ? bsys_pwr_req_val:
         paddr_reg ==  12'h404 ? bsys_pwr_st_val:
         paddr_reg ==  12'h500 ? host_sys_lctrl_st_val:
         paddr_reg ==  12'h504 ? host_sys_lctrl_set_val:
         paddr_reg ==  12'h508 ? host_sys_lctrl_clr_val:
         paddr_reg ==  12'h800 ? hostcpuclk_ctrl_val:
         paddr_reg ==  12'h804 ? hostcpuclk_div0_val:
         paddr_reg ==  12'h808 ? hostcpuclk_div1_val:
         paddr_reg ==  12'h810 ? gicclk_ctrl_val:
         paddr_reg ==  12'h814 ? gicclk_div0_val:
         paddr_reg ==  12'h820 ? aclk_ctrl_val:
         paddr_reg ==  12'h824 ? aclk_div0_val:
         paddr_reg ==  12'h830 ? ctrlclk_ctrl_val:
         paddr_reg ==  12'h834 ? ctrlclk_div0_val:
         paddr_reg ==  12'h840 ? dbgclk_ctrl_val:
         paddr_reg ==  12'h844 ? dbgclk_div0_val:
         paddr_reg ==  12'h850 ? hostuartclk_ctrl_val:
         paddr_reg ==  12'h854 ? hostuartclk_div0_val:
         paddr_reg ==  12'h860 ? refclk_ctrl_val:
         paddr_reg ==  12'hA00 ? clkforce_st_val:
         paddr_reg ==  12'hA04 ? clkforce_set_val:
         paddr_reg ==  12'hA08 ? clkforce_clr_val:
         paddr_reg ==  12'hA10 ? pll_st_val:
         paddr_reg ==  12'hB00 ? host_ppu_int_st_val:
         paddr_reg ==  12'hFD0 ? pid4_val:
         paddr_reg ==  12'hFD4 ? pid5_val:
         paddr_reg ==  12'hFD8 ? pid6_val:
         paddr_reg ==  12'hFDC ? pid7_val:
         paddr_reg ==  12'hFE0 ? pid0_val:
         paddr_reg ==  12'hFE4 ? pid1_val:
         paddr_reg ==  12'hFE8 ? pid2_val:
         paddr_reg ==  12'hFEC ? pid3_val:
         paddr_reg ==  12'hFF0 ? cid0_val:
         paddr_reg ==  12'hFF4 ? cid1_val:
         paddr_reg ==  12'hFF8 ? cid2_val:
         paddr_reg ==  12'hFFC ? cid3_val:
         32'd0;
  assign prdata = second_phase_reg && (!pwrite_reg) ? read_data : 32'd0;

  
  assign is_valid_write = second_phase_reg && pwrite_reg && (!is_lock_down);
  
  assign pslverr = second_phase_reg   == 1'b0         ? 1'b0 :                    
                   (is_lock_down & pwrite_reg)        ? 1'b1 : 
                   (
                 paddr_reg ==  12'h000 ? 1'b0 :
                   paddr_reg ==  12'h010 ? 1'b0 :
                   paddr_reg ==  12'h014 ? 1'b0 :
                   paddr_reg ==  12'h018 ? 1'b0 :
                   paddr_reg ==  12'h020 ? 1'b0 :
                   paddr_reg ==  12'h024 ? 1'b0 :
                   paddr_reg ==  12'h028 ? 1'b0 :
                   paddr_reg ==  12'h030 ? 1'b0 :
                   paddr_reg ==  12'h034 ? 1'b0 :
                   paddr_reg ==  12'h038 ? 1'b0 :
                   paddr_reg ==  12'h040 ? 1'b0 :
                   paddr_reg ==  12'h044 ? 1'b0 :
                   paddr_reg ==  12'h048 ? 1'b0 :
                   paddr_reg ==  12'h200 ? 1'b0 :
                   paddr_reg ==  12'h300 ? host_cpu_boot_msk_pslverr :
                   paddr_reg ==  12'h304 ? 1'b0 :
                   paddr_reg ==  12'h308 ? 1'b0 :
                   paddr_reg ==  12'h310 ? 1'b0 :
                   paddr_reg ==  12'h314 ? 1'b0 :
                   paddr_reg ==  12'h318 ? 1'b0 :
                   paddr_reg ==  12'h31C ? 1'b0 :
                   paddr_reg ==  12'h400 ? 1'b0 :
                   paddr_reg ==  12'h404 ? 1'b0 :
                   paddr_reg ==  12'h500 ? 1'b0 :
                   paddr_reg ==  12'h504 ? 1'b0 :
                   paddr_reg ==  12'h508 ? 1'b0 :
                   paddr_reg ==  12'h800 ? 1'b0 :
                   paddr_reg ==  12'h804 ? 1'b0 :
                   paddr_reg ==  12'h808 ? 1'b0 :
                   paddr_reg ==  12'h810 ? 1'b0 :
                   paddr_reg ==  12'h814 ? 1'b0 :
                   paddr_reg ==  12'h820 ? 1'b0 :
                   paddr_reg ==  12'h824 ? 1'b0 :
                   paddr_reg ==  12'h830 ? 1'b0 :
                   paddr_reg ==  12'h834 ? 1'b0 :
                   paddr_reg ==  12'h840 ? 1'b0 :
                   paddr_reg ==  12'h844 ? 1'b0 :
                   paddr_reg ==  12'h850 ? 1'b0 :
                   paddr_reg ==  12'h854 ? 1'b0 :
                   paddr_reg ==  12'h860 ? 1'b0 :
                   paddr_reg ==  12'hA00 ? 1'b0 :
                   paddr_reg ==  12'hA04 ? 1'b0 :
                   paddr_reg ==  12'hA08 ? 1'b0 :
                   paddr_reg ==  12'hA10 ? 1'b0 :
                   paddr_reg ==  12'hB00 ? 1'b0 :
                   paddr_reg ==  12'hFD0 ? 1'b0 :
                   paddr_reg ==  12'hFD4 ? 1'b0 :
                   paddr_reg ==  12'hFD8 ? 1'b0 :
                   paddr_reg ==  12'hFDC ? 1'b0 :
                   paddr_reg ==  12'hFE0 ? 1'b0 :
                   paddr_reg ==  12'hFE4 ? 1'b0 :
                   paddr_reg ==  12'hFE8 ? 1'b0 :
                   paddr_reg ==  12'hFEC ? 1'b0 :
                   paddr_reg ==  12'hFF0 ? 1'b0 :
                   paddr_reg ==  12'hFF4 ? 1'b0 :
                   paddr_reg ==  12'hFF8 ? 1'b0 :
                   paddr_reg ==  12'hFFC ? 1'b0 :
          1'b0);
      
  assign pready = 
                   paddr_reg ==  12'h504 ? host_sys_lctrl_set_pready : 
                   paddr_reg ==  12'h508 ? host_sys_lctrl_clr_pready : 
    
        pready_reg;
      
  
   
    
  
  reg [3:0]  boot_msk;
  reg        boot_msk_write_err;
  reg [4:0]  clkforce;  
  reg [3:0]  host_lock_fw_gic_clrdis;
  wire [4:0] host_lock_cpu_ss;

  wire extsys0_cpuwait_wen_dd;
  reg  extsys0_cpuwait;
  reg  set_extsys0_cpuwait_edge_detect;
  wire set_extsys0_cpuwait_rising;
  wire set_extsys0_cpuwait_ss;

  assign ext_sys0_rst_ctrl_val[0] = extsys0_cpuwait;

  assign set_extsys0_cpuwait_rising = set_extsys0_cpuwait_ss && (!set_extsys0_cpuwait_edge_detect);
  arm_element_cdc_capt_sync u_set_extsys0_cpuwait_ss (.clk(clk), .nreset(resetn), .d_async(set_extsys0_cpuwait), .q(set_extsys0_cpuwait_ss) );
  arm_element_cdc_capt_sync u_extsys0_cpuwait_wen_dd (.clk(clk), .nreset(resetn), .d_async(extsys0_cpuwait_wen), .q(extsys0_cpuwait_wen_dd) );

  wire extsys1_cpuwait_wen_dd;
  reg  extsys1_cpuwait;
  reg  set_extsys1_cpuwait_edge_detect;
  wire set_extsys1_cpuwait_rising;
  wire set_extsys1_cpuwait_ss;

  assign ext_sys1_rst_ctrl_val[0] = extsys1_cpuwait;

  assign set_extsys1_cpuwait_rising = set_extsys1_cpuwait_ss && (!set_extsys1_cpuwait_edge_detect);
  arm_element_cdc_capt_sync u_set_extsys1_cpuwait_ss (.clk(clk), .nreset(resetn), .d_async(set_extsys1_cpuwait), .q(set_extsys1_cpuwait_ss) );
  arm_element_cdc_capt_sync u_extsys1_cpuwait_wen_dd (.clk(clk), .nreset(resetn), .d_async(extsys1_cpuwait_wen), .q(extsys1_cpuwait_wen_dd) );


  arm_element_cdc_capt_sync u_host_lock_core0_ss (.clk(clk), .nreset(resetn), .d_async(host_lock_cpu[0]), .q(host_lock_cpu_ss[0]) );
  arm_element_cdc_capt_sync u_host_lock_core1_ss (.clk(clk), .nreset(resetn), .d_async(host_lock_cpu[1]), .q(host_lock_cpu_ss[1]) );
  arm_element_cdc_capt_sync u_host_lock_core2_ss (.clk(clk), .nreset(resetn), .d_async(host_lock_cpu[2]), .q(host_lock_cpu_ss[2]) );
  arm_element_cdc_capt_sync u_host_lock_core3_ss (.clk(clk), .nreset(resetn), .d_async(host_lock_cpu[3]), .q(host_lock_cpu_ss[3]) );
  arm_element_cdc_capt_sync u_host_lock_gic_ss (.clk(clk), .nreset(resetn), .d_async(host_lock_cpu[4]), .q(host_lock_cpu_ss[4]) );
  
  
  assign host_sys_lctrl_st_val[31]  = host_lock_fw_gic_clrdis[3];
  assign host_sys_lctrl_st_val[7]   = host_lock_fw_gic_clrdis[2];
  assign host_sys_lctrl_st_val[6:2] = host_lock_cpu_ss;
  assign host_sys_lctrl_st_val[1:0] = host_lock_fw_gic_clrdis[1:0];
  
  assign host_sys_lctrl_set_val = 32'd0;
  assign host_sys_lctrl_clr_val = 32'd0;
  
  assign clkforce_clr_val[6:1] = 6'd0;
  assign clkforce_set_val[6:1] = 6'd0;
  assign clkforce_st_val[6] = clkforce[4];
  assign clkforce_st_val[4:2] = clkforce[3:1];
    
  assign host_cpu_boot_msk_pslverr =  boot_msk_write_err;
                                      
  assign host_cpu_boot_msk_val[3:0] = boot_msk;
  
  wire [3:0] host_cpu_wake_up;  
    
    
  wire [9:0] nx_modify_lock_val;
  wire [9:0] nx_modify_lock_req;
  wire [9:0] modify_lock_ack_ss;
  
  assign nx_modify_lock_val = {{5{host_sys_lctrl_clr_psel & pwrite &(~host_sys_lctrl_st_lock_clr_dis)}} & {pwdata[6], pwdata[5:2]}, 
                               {5{host_sys_lctrl_set_psel & pwrite                                   }} & {pwdata[6], pwdata[5:2]}};
                                                                                       
  assign nx_modify_lock_req = penable         == 1'b0               ? nx_modify_lock_val : 
                              modify_lock_req == modify_lock_ack_ss ? 10'd0              : 
                              modify_lock_req;                                             

  assign host_sys_lctrl_set_pready = modify_lock_req == 10'd0 && modify_lock_ack_ss == 10'd0;
  assign host_sys_lctrl_clr_pready = modify_lock_req == 10'd0 && modify_lock_ack_ss == 10'd0;

    arm_element_cdc_capt_sync u_modify_lock_ack_ss_0 (.clk(clk), .nreset(resetn), .d_async(modify_lock_ack[0]), .q(modify_lock_ack_ss[0]) );
    arm_element_cdc_capt_sync u_modify_lock_ack_ss_1 (.clk(clk), .nreset(resetn), .d_async(modify_lock_ack[1]), .q(modify_lock_ack_ss[1]) );
    arm_element_cdc_capt_sync u_modify_lock_ack_ss_2 (.clk(clk), .nreset(resetn), .d_async(modify_lock_ack[2]), .q(modify_lock_ack_ss[2]) );
    arm_element_cdc_capt_sync u_modify_lock_ack_ss_3 (.clk(clk), .nreset(resetn), .d_async(modify_lock_ack[3]), .q(modify_lock_ack_ss[3]) );
    arm_element_cdc_capt_sync u_modify_lock_ack_ss_4 (.clk(clk), .nreset(resetn), .d_async(modify_lock_ack[4]), .q(modify_lock_ack_ss[4]) );
    arm_element_cdc_capt_sync u_modify_lock_ack_ss_5 (.clk(clk), .nreset(resetn), .d_async(modify_lock_ack[5]), .q(modify_lock_ack_ss[5]) );
    arm_element_cdc_capt_sync u_modify_lock_ack_ss_6 (.clk(clk), .nreset(resetn), .d_async(modify_lock_ack[6]), .q(modify_lock_ack_ss[6]) );
    arm_element_cdc_capt_sync u_modify_lock_ack_ss_7 (.clk(clk), .nreset(resetn), .d_async(modify_lock_ack[7]), .q(modify_lock_ack_ss[7]) );
    arm_element_cdc_capt_sync u_modify_lock_ack_ss_8 (.clk(clk), .nreset(resetn), .d_async(modify_lock_ack[8]), .q(modify_lock_ack_ss[8]) );
    arm_element_cdc_capt_sync u_modify_lock_ack_ss_9 (.clk(clk), .nreset(resetn), .d_async(modify_lock_ack[9]), .q(modify_lock_ack_ss[9]) );
  

  always @(posedge clk or negedge resetn)
  begin
        if(!resetn)
        begin
            clkforce<=5'd0;
            extsys0_cpuwait<=1'b1;
            set_extsys0_cpuwait_edge_detect<=1'b0;
            extsys1_cpuwait<=1'b1;
            set_extsys1_cpuwait_edge_detect<=1'b0;
            boot_msk_write_err<=1'b0;
            boot_msk<=4'b0001;
            modify_lock_req<=10'd0;            
            host_lock_fw_gic_clrdis<=4'd0;
        end
        else
        begin
            if( host_sys_lctrl_set_psel | host_sys_lctrl_clr_psel)
                modify_lock_req<=nx_modify_lock_req;
            set_extsys0_cpuwait_edge_detect<=set_extsys0_cpuwait_ss;
            set_extsys1_cpuwait_edge_detect<=set_extsys1_cpuwait_ss;
            if(host_cpu_boot_msk_psel)
            begin
               if( second_phase_reg )
               begin
                 if( boot_msk_write_err == 1'b0 && is_valid_write)
                    boot_msk<=pwdata[3:0];
                
                boot_msk_write_err<=1'b0;
               end 
               else
               begin
                 if( (HOST_CPU_NUM_CORES == 1 && pwdata[3:1] != 3'd0) ||
                     (HOST_CPU_NUM_CORES == 2 && pwdata[3:2] != 2'd0) ||
                     (HOST_CPU_NUM_CORES == 3 && pwdata[3:3] != 1'd0) ||
                     pwdata[3:0] == 4'd0 )
                    boot_msk_write_err<=pwrite;
                 else
                    boot_msk_write_err<=1'b0;
               end
               
            end        
            
            if(host_sys_lctrl_set_psel  && is_valid_write)
                host_lock_fw_gic_clrdis<=host_lock_fw_gic_clrdis | ({pwdata[31],pwdata[7],pwdata[1:0]});
            else
            if(host_sys_lctrl_clr_psel  && is_valid_write && (!host_sys_lctrl_st_lock_clr_dis))
                host_lock_fw_gic_clrdis<=host_lock_fw_gic_clrdis & (~({pwdata[31],pwdata[7],pwdata[1:0]}));

            if(clkforce_set_psel  && is_valid_write )
                clkforce<=clkforce | {pwdata[6],pwdata[4:1]};
            else
            if(clkforce_clr_psel  && is_valid_write)
                clkforce<=clkforce & (~({pwdata[6],pwdata[4:1]}));
            
            if(ext_sys0_rst_ctrl_psel && is_valid_write && extsys0_cpuwait_wen_dd && extsys0_cpuwait )
                extsys0_cpuwait<=pwdata[0];
            else
            if(set_extsys0_cpuwait_rising == 1'b1)
                extsys0_cpuwait<=1'b1;

            if(ext_sys1_rst_ctrl_psel && is_valid_write && extsys1_cpuwait_wen_dd && extsys1_cpuwait )
                extsys1_cpuwait<=pwdata[0];
            else
            if(set_extsys1_cpuwait_rising == 1'b1)
                extsys1_cpuwait<=1'b1;

                              
        end
  end


  
    
  wire unused = (|host_sys_lctrl_st_host_lock_cpu) |
                (host_rst_syn_syn[2]) |
                (|hostcpuclk_ctrl_clkselect_cur[7:3]) |
                (|gicclk_ctrl_clkselect_cur[7:2]) |
                (|aclk_ctrl_clkselect_cur[7:2]) |
                (|ctrlclk_ctrl_clkselect_cur[7:2]) |
                (|dbgclk_ctrl_clkselect_cur[7:2]) |
                (|pwdata[30:5]);   
                
        
      
endmodule


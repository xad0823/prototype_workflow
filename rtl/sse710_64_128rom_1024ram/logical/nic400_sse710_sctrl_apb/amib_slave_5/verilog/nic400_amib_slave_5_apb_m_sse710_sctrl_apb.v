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




`include "Axi.v"
`include "nic400_amib_slave_5_defs_sse710_sctrl_apb.v"


module nic400_amib_slave_5_apb_m_sse710_sctrl_apb
(
  aclk,
  aresetn,

  awrite,
  aid,
  aaddr,
  alen,
  asize,
  aburst,
  aprot,

  avalid,
  aready,

  dbnr,
  did,
  ddata,
  dresp,
  dlast,
  dvalid,
  dready,

  wdata,
  wstrb,
  wlast,
  wvalid,
  wready,

  pclken,
  psel_sysctrl_apb_i,
  pready_sysctrl_apb_i,
  pslverr_sysctrl_apb_i,
  prdata_sysctrl_apb_i,
  penable,
  pwrite,
  paddr,
  pwdata,
  pprot,
  pstrb

);



  parameter ID_WIDTH   = `ID_WIDTH;           
  parameter ADDR_WIDTH = `ADDR_BUS_MAX + 1;   

  localparam ID_MAX     = (ID_WIDTH - 1);      
  localparam ADDR_MAX   = (ADDR_WIDTH - 1);    
  localparam A4K_WIDTH  = 12;                  
  localparam A4K_MAX    = (A4K_WIDTH - 1);     



  input                 aclk;                 
  input                 aresetn;              

  input                 awrite;               
  input     [ID_MAX:0]  aid;                  
  input   [ADDR_MAX:0]  aaddr;                
  input          [7:0]     alen;                 
  input          [2:0]  asize;                
  input          [1:0]  aburst;               
  input          [2:0]  aprot;                

  input                 avalid;               
  output                aready;               

  output                dbnr;                 
  output    [ID_MAX:0]  did;                  
  output        [31:0]  ddata;                
  output         [1:0]  dresp;                
  output                dlast;                
  output                dvalid;               
  input                 dready;               

  input         [31:0]  wdata;                
  input          [3:0]  wstrb;                
  input                 wlast;                
  input                 wvalid;               
  output                wready;               

  input                 pclken;               
  output                psel_sysctrl_apb_i;     
  input                 pready_sysctrl_apb_i;   
  input                 pslverr_sysctrl_apb_i;  
  input         [31:0]  prdata_sysctrl_apb_i;   
  output                penable;              
  output                pwrite;               
  output  [ADDR_MAX:0]  paddr;                
  output        [31:0]  pwdata;               
  output         [2:0]  pprot;                
  output         [3:0]  pstrb;                



  wire                  aclk;                 
  wire                  aresetn;              

  wire                  awrite;               
  wire      [ID_MAX:0]  aid;                  
  wire    [ADDR_MAX:0]  aaddr;                
  wire           [7:0]     alen;                 
  wire           [2:0]  asize;                
  wire           [1:0]  aburst;               
  wire           [2:0]  aprot;                

  wire                  avalid;               
  wire                  aready;               

  wire                  dbnr;                 
  wire      [ID_MAX:0]  did;                  
  wire          [31:0]  ddata;                
  wire           [1:0]  dresp;                
  wire                  dlast;                
  wire                  dvalid;               
  wire                  dready;               

  wire          [31:0]  wdata;                
  wire           [3:0]  wstrb;                
  wire                  wlast;                
  wire                  wvalid;               
  wire                  wready;               

  wire                  pclken;               
  wire                  psel_sysctrl_apb_i;     
  wire                  pready_sysctrl_apb_i;   
  wire                  pslverr_sysctrl_apb_i;  
  wire          [31:0]  prdata_sysctrl_apb_i;   
  wire                  penable;              
  wire                  pwrite;               
  wire    [ADDR_MAX:0]  paddr;                
  wire          [31:0]  pwdata;               

  wire           [2:0]  pprot;                
  wire           [3:0]  pstrb;                




  wire    [ADDR_MAX:0]  incremented_addr;     


  reg           bridge_state;       
  reg           nxt_bridge_state;   
  wire          bridge_state_en;    
  
  

  reg  [ADDR_MAX:0]    nxt_paddr;
  reg  [ADDR_MAX:0]    paddr_i;
  reg  [1:0]             psel_i;
  reg  [1:0]             nxt_psel;
  wire [1:0]             psel_dec;

  reg                  nxt_penable;
  reg                  penable_i;
  reg                  nxt_pwrite;
  reg                  pwrite_i;
  reg [2:0]            pprot_i;
  reg [2:0]            nxt_pprot;
  reg [3:0]            nxt_pstrb;
  reg [3:0]            pstrb_i;
  reg [31:0]           nxt_pwdata;
  reg [31:0]           pwdata_i;
 
  reg                  last_beat;
  reg                  nxt_last_beat;
  reg [2:0]            axi_size;
  reg [2:0]            nxt_axi_size;
  reg [1:0]            axi_burst;
  reg [1:0]            nxt_axi_burst;
  
  reg [ID_MAX:0]           axi_id;
  reg [ID_MAX:0]           nxt_axi_id;
  reg [7:0]               axi_len;
  reg [7:0]               nxt_axi_len;
  reg [7:0]               axi_len_count;
  reg [7:0]               nxt_axi_len_count;
  
  wire                 ok_to_start_nxt_apb_trans;
  reg                  abeat_used_axi;
  reg                  abeat_used_apb;
  reg                  nxt_abeat_used_apb;
  reg                  wbeat_used_axi;
  reg                  wbeat_used_apb;
  reg                  nxt_wbeat_used_apb;
  wire                 pready_or_idle;
  wire                 no_strb_write;                 
  wire                 burst_in_progress;
  wire                 pready;
  wire                 pslverr;
  wire [31:0]          prdata;

  wire                 data_capture_en;
  reg [31:0]           apb_prdata_reg;
  reg                  apb_pslverr_reg;
  reg                  apb_last_reg;
  reg                  apb_pwrite_reg;
  
  reg [ID_MAX:0]            apb_id_reg;
  
  reg                  data_avail_apb;
  wire                 nxt_data_avail_apb;

  wire                 apb_data_accept;
  reg                  data_avail_axi;
  wire                 axi_resp_valid;
  wire                 axi_resp_ready;

  wire                 err_acc_en;
  wire                 next_accumulated_err;
  reg                  accumulated_err;
  wire [46:0]       axi_resp_payload_in;
  wire [46:0]       axi_resp_payload_out;

  nic400_amib_slave_5_a_gen_sse710_sctrl_apb #(
    .ADDR_WIDTH     (A4K_WIDTH)
  ) u_a_gen
  (
    .addr_in        (paddr_i[A4K_MAX:0]),
    .alen           (axi_len[3:0]),
    .asize          (axi_size),
    .aburst         (axi_burst),

    .addr_out       (incremented_addr[A4K_MAX:0])
  );

  assign incremented_addr[ADDR_MAX:A4K_WIDTH] = paddr_i[ADDR_MAX:A4K_WIDTH];

  assign burst_in_progress = |axi_len_count;

  assign no_strb_write = (burst_in_progress) ? pwrite_i & ~|wstrb :
                                               ((wvalid & ~|wstrb) & (avalid & awrite));

  assign psel_dec[0] = ~no_strb_write;
  assign psel_dec[1] = ~psel_dec[0];


  assign pready_or_idle = pready | ~(|psel_i);

  assign ok_to_start_nxt_apb_trans = axi_resp_ready & pready_or_idle &
                                     ((burst_in_progress) ? (~pwrite_i | wvalid) : (avalid & (~awrite | wvalid)));
                                     

  always @*
    begin : app_bridge_sm_comb
    
      nxt_bridge_state   = bridge_state;   
      nxt_psel           = psel_i;         
      nxt_penable        = penable_i;
      nxt_paddr          = paddr_i;        
      nxt_pwrite         = pwrite_i;       
      nxt_pprot          = pprot_i;        
      nxt_pstrb          = pstrb_i;        
      nxt_pwdata         = pwdata_i;       

      nxt_last_beat      = last_beat;
      nxt_axi_size       = axi_size;
      nxt_axi_burst      = axi_burst;
      nxt_axi_len        = axi_len;
      nxt_axi_len_count  = axi_len_count;
      
      nxt_axi_id         = axi_id;

      nxt_abeat_used_apb = abeat_used_apb; 
      nxt_wbeat_used_apb = wbeat_used_apb;

      
      case (bridge_state)
      
        1'b0 : 
          begin
          
            if (ok_to_start_nxt_apb_trans) begin
                
               nxt_psel     = psel_dec;
               nxt_penable  = 1'b0;
               nxt_paddr    = (burst_in_progress) ? incremented_addr : aaddr;
               nxt_pwrite   = (burst_in_progress) ? pwrite_i : awrite;
               nxt_pprot    = (burst_in_progress) ? pprot_i : aprot;

               nxt_last_beat     = (burst_in_progress) ? (axi_len_count == 'd1) : ~|alen;
               nxt_axi_burst     = (burst_in_progress) ? axi_burst : aburst;     
               nxt_axi_len       = (burst_in_progress) ? axi_len : alen;
               nxt_axi_size      = (burst_in_progress) ? axi_size : asize;
               nxt_axi_len_count = (burst_in_progress) ? axi_len_count - 'd1 : alen;
               
               nxt_axi_id        = (burst_in_progress) ? axi_id : aid;
               

               nxt_abeat_used_apb = (burst_in_progress) ? abeat_used_apb : ~abeat_used_apb;

               if (nxt_pwrite) begin
                   
                  nxt_pwdata = wdata;
                  nxt_pstrb  = wstrb;

                  nxt_wbeat_used_apb = ~wbeat_used_apb;
                   
               end  else begin
                   
                   nxt_pstrb  = 4'b0000;
                   
               end 
                
               nxt_bridge_state = 1'b1;
              
            end else begin

                nxt_psel     = (|psel_i) ? {2{~pready}} & psel_i : {2{1'b0}};
                nxt_penable  = (|psel_i) ? ~pready : 1'b0;

            end    
          end
 
        1'b1:
          begin
                nxt_penable = 1'b1;
                nxt_bridge_state = 1'b0;
          end

        default :
             nxt_bridge_state = 1'bx;

      endcase
    end 


  assign bridge_state_en = pclken & (avalid | (|psel_i) | burst_in_progress);

  always @(posedge aclk or negedge aresetn)
    begin : p_bridge_apb_sm_seq
      if (!aresetn)
        begin
           bridge_state   <= 1'b0; 
           psel_i         <= 'd0;    
           penable_i      <= 1'b0;
           paddr_i        <= 'd0;
           pwrite_i       <= 1'd0;
           pprot_i        <= 3'b0;       
           pstrb_i        <= 4'b0;
           pwdata_i       <= 32'b0;
           last_beat      <= 1'b0;
           axi_size       <= 3'b0;
           axi_burst      <= 2'b0;
           axi_len        <= 'd0;
           axi_len_count  <= 'd0;
           axi_id         <= 'd0;
           wbeat_used_apb <= 1'b0;
           abeat_used_apb <= 1'b0;
        end
      else if (bridge_state_en) 
        begin
           bridge_state   <= nxt_bridge_state;
           psel_i         <= nxt_psel;       
           penable_i      <= nxt_penable;
           paddr_i        <= nxt_paddr;     
           pwrite_i       <= nxt_pwrite;
           pprot_i        <= nxt_pprot;      
           pstrb_i        <= nxt_pstrb; 
           pwdata_i       <= nxt_pwdata;       
           last_beat      <= nxt_last_beat;
           axi_size       <= nxt_axi_size;
           axi_burst      <= nxt_axi_burst;
           axi_len        <= nxt_axi_len;
           axi_len_count  <= nxt_axi_len_count;
           axi_id         <= nxt_axi_id;
           wbeat_used_apb <= nxt_wbeat_used_apb;
           abeat_used_apb <= nxt_abeat_used_apb;
        end
    end 

  assign aready  = abeat_used_apb ^ abeat_used_axi;

  always @(posedge aclk or negedge aresetn)
    begin : p_bridge_abeat_use
      if (!aresetn)
        begin
           abeat_used_axi <= 1'b0;
        end
      else if (aready)
        begin
           abeat_used_axi <= ~abeat_used_axi;
        end
    end 

  assign wready  = wbeat_used_apb ^ wbeat_used_axi;

  always @(posedge aclk or negedge aresetn)
    begin : p_bridge_wbeat_use
      if (!aresetn)
        begin
           wbeat_used_axi <= 1'b0;
        end
      else if (wready)
        begin
           wbeat_used_axi <= ~wbeat_used_axi;
        end
    end 

  
  assign psel_sysctrl_apb_i = psel_i[0];

  assign prdata  = prdata_sysctrl_apb_i;
  assign pslverr = pslverr_sysctrl_apb_i & psel_i[0];
  assign pready  = pready_sysctrl_apb_i | psel_i[1];
  
  

  assign data_capture_en = pclken & |psel_i & penable_i;
  assign nxt_data_avail_apb = data_avail_apb ^ pready;
 
  always @(posedge aclk or negedge aresetn)
    begin : p_bridge_data_capture
      if (!aresetn)
        begin
          apb_prdata_reg  <= {32{1'b0}};
          apb_pslverr_reg <= 1'b0;
          apb_last_reg    <= 1'b0;
          apb_pwrite_reg  <= 1'b0;
          apb_id_reg      <= 'd0;
          data_avail_apb  <= 1'b0;
        end
      else if (data_capture_en)
        begin
          apb_prdata_reg  <= prdata;
          apb_pslverr_reg <= pslverr;
          apb_last_reg    <= last_beat;
          apb_pwrite_reg  <= pwrite_i;
          apb_id_reg      <= axi_id;
          data_avail_apb  <= nxt_data_avail_apb;
        end
    end 


  assign err_acc_en = apb_pwrite_reg & (data_avail_apb ^ data_avail_axi) & (axi_resp_ready | ~apb_last_reg);

  assign next_accumulated_err = (apb_last_reg) ? 1'b0 : accumulated_err | apb_pslverr_reg;

  always @(posedge aclk or negedge aresetn)
    begin : p_bridge_err_acc
      if (!aresetn)
        begin
           accumulated_err <= 1'b0;
        end
      else if (err_acc_en)
        begin
           accumulated_err <= next_accumulated_err;
        end
    end 

  assign axi_resp_valid = (data_avail_apb ^ data_avail_axi) & (~apb_pwrite_reg | apb_last_reg);

  assign axi_resp_payload_in = {apb_pwrite_reg, 
                                apb_last_reg, 
                                apb_pslverr_reg | accumulated_err,
                                apb_id_reg,
                                apb_prdata_reg};


  assign apb_data_accept = (data_avail_apb ^ data_avail_axi) & ((axi_resp_valid & axi_resp_ready) || (apb_pwrite_reg & ~apb_last_reg));

  always @(posedge aclk or negedge aresetn)
    begin : p_bridge_apb_data_accept
      if (!aresetn)
        begin
           data_avail_axi <= 1'b0;
        end
      else if (apb_data_accept)
        begin
           data_avail_axi <= ~data_avail_axi;
        end
    end 

  nic400_rev_regd_slice_sse710_sctrl_apb #(47) u_axi_resp_ouput_buffer
  (
    .aresetn           (aresetn),
    .aclk              (aclk),

    .valid_src         (axi_resp_valid),
    .ready_dst         (dready),
    .payload_src       (axi_resp_payload_in),

    .valid_dst         (dvalid),
    .ready_src         (axi_resp_ready),
    .payload_dst       (axi_resp_payload_out)
  );

  assign {dbnr, dlast, dresp[1], did, ddata} = axi_resp_payload_out;
  assign dresp[0] = 1'b0;

  assign pwrite  = pwrite_i;
  assign paddr   = paddr_i;
  assign penable = penable_i;
  assign pwdata  = pwdata_i;

  assign pprot   = pprot_i;
  assign pstrb   = pstrb_i;





`ifdef ARM_ASSERT_ON

`include "std_ovl_defines.h"


  assert_never #(`OVL_ERROR, `OVL_ASSERT,
                 "Value of asize not supported")
  amib_apb_illegal_asize
  (
    .clk            (aclk),
    .reset_n        (aresetn),
    .test_expr      (avalid && aready &&
                     ((asize == `AXI_ASIZE_64)  || 
                      (asize == `AXI_ASIZE_128) ||
                      (asize == `AXI_ASIZE_256) ||
                      (asize == `AXI_ASIZE_512) ||
                      (asize == `AXI_ASIZE_1024)))
  );

   assert_zero_one_hot #(0,2,0,"ERROR, More than one psel selected")
     ovl_multi_psel_output
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (psel_i)
        );


`ifdef ARM_OVL_IGNORE_UNALIGN
  initial
    begin : p_arm_ovl_ignore_unalign
      $display("ARM_OVL_IGNORE_UNALIGN: Unalignment OVLs are disabled in %m");
    end 
`else
  assert_never #(`OVL_WARNING, `OVL_ASSERT,
                 "Zero-strobe writes will be ignored by APB MIB")
  amib_apb_zero_wstrb
  (
    .clk            (aclk),
    .reset_n        (aresetn),
    .test_expr      (wvalid && wready && (wstrb == 4'b0000))
  );

  assert_never #(`OVL_WARNING, `OVL_ASSERT,
                 "apb capture when axi not ready")
  amib_axi_apb_hshake
  (
    .clk            (aclk),
    .reset_n        (aresetn),
    .test_expr      (data_capture_en && (data_avail_apb != data_avail_axi))
  );


`endif 

`endif 


endmodule 


`include "nic400_amib_slave_5_undefs_sse710_sctrl_apb.v"
`include "Axi_undefs.v"




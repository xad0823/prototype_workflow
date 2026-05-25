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

module sse710_integration_example_f0_ahb_to_apb #(
  parameter     ADDRWIDTH = 16,
  parameter     REGISTER_RDATA = 1,
  parameter     REGISTER_WDATA = 0)
 (
  input  wire                 HCLK,      
  input  wire                 HRESETn,   
  input  wire                 PCLKEN,    

  input  wire                 HSEL,      
  input  wire [ADDRWIDTH-1:0] HADDR,     
  input  wire           [1:0] HTRANS,    
  input  wire           [2:0] HSIZE,     
  input  wire           [3:0] HPROT,     
  input  wire                 HWRITE,    
  input  wire                 HREADY,    
  input  wire          [31:0] HWDATA,    

  output reg                  HREADYOUT, 
  output wire          [31:0] HRDATA,    
  output wire                 HRESP,     
  output wire [ADDRWIDTH-1:0] PADDR,     
  output wire                 PENABLE,   
  output wire                 PWRITE,    
  output wire           [3:0] PSTRB,     
  output wire           [2:0] PPROT,     
  output wire          [31:0] PWDATA,    
  output wire                 PSEL,      

  output wire                 APBACTIVE, 

  input  wire          [31:0] PRDATA,    
  input  wire                 PREADY,    
  input  wire                 PSLVERR);  


  reg  [ADDRWIDTH-3:0]   addr_reg;    
  reg                    wr_reg;      
  reg            [2:0]   state_reg;   

  reg            [3:0]   pstrb_reg;   
  wire           [3:0]   pstrb_nxt;   
  reg            [1:0]   pprot_reg;   
  wire           [1:0]   pprot_nxt;   

  wire                   apb_select;   
  wire                   apb_tran_end; 
  reg            [2:0]   next_state;   
  reg           [31:0]   rwdata_reg;   

  wire                   reg_rdata_cfg; 
  wire                   reg_wdata_cfg; 

  reg                    sample_wdata_reg; 


   localparam ST_BITS = 3;

   localparam [ST_BITS-1:0] ST_IDLE      = 3'b000; 
   localparam [ST_BITS-1:0] ST_APB_WAIT  = 3'b001; 
   localparam [ST_BITS-1:0] ST_APB_TRNF  = 3'b010; 
   localparam [ST_BITS-1:0] ST_APB_TRNF2 = 3'b011; 
   localparam [ST_BITS-1:0] ST_APB_ENDOK = 3'b100; 
   localparam [ST_BITS-1:0] ST_APB_ERR1  = 3'b101; 
   localparam [ST_BITS-1:0] ST_APB_ERR2  = 3'b110; 
   localparam [ST_BITS-1:0] ST_ILLEGAL   = 3'b111; 

  assign reg_rdata_cfg = (REGISTER_RDATA==0) ? 1'b0 : 1'b1;
  assign reg_wdata_cfg = (REGISTER_WDATA==0) ? 1'b0 : 1'b1;

  assign apb_select = HSEL & HTRANS[1] & HREADY;
  assign apb_tran_end = (state_reg==3'b011) & PREADY;

  assign pprot_nxt[0] =  HPROT[1];  
  assign pprot_nxt[1] = ~HPROT[0];  

  assign pstrb_nxt[0] = HWRITE & ((HSIZE[1])|((HSIZE[0])&(~HADDR[1]))|(HADDR[1:0]==2'b00));
  assign pstrb_nxt[1] = HWRITE & ((HSIZE[1])|((HSIZE[0])&(~HADDR[1]))|(HADDR[1:0]==2'b01));
  assign pstrb_nxt[2] = HWRITE & ((HSIZE[1])|((HSIZE[0])&( HADDR[1]))|(HADDR[1:0]==2'b10));
  assign pstrb_nxt[3] = HWRITE & ((HSIZE[1])|((HSIZE[0])&( HADDR[1]))|(HADDR[1:0]==2'b11));

  always @(posedge HCLK or negedge HRESETn)
  begin
  if (~HRESETn)
    begin
    addr_reg  <= {(ADDRWIDTH-2){1'b0}};
    wr_reg    <= 1'b0;
    pprot_reg <= {2{1'b0}};
    pstrb_reg <= {4{1'b0}};
    end
  else if (apb_select) 
    begin
    addr_reg  <= HADDR[ADDRWIDTH-1:2];
    wr_reg    <= HWRITE;
    pprot_reg <= pprot_nxt;
    pstrb_reg <= pstrb_nxt;
    end
  end

  wire sample_wdata_set = apb_select & HWRITE & reg_wdata_cfg;
  wire sample_wdata_clr = sample_wdata_reg & PCLKEN;

  always @(posedge HCLK or negedge HRESETn)
  begin
  if (~HRESETn)
    sample_wdata_reg <= 1'b0;
  else if (sample_wdata_set | sample_wdata_clr)
    sample_wdata_reg <= sample_wdata_set;
  end

  always @(state_reg or PREADY or PSLVERR or apb_select or reg_rdata_cfg or
           PCLKEN or reg_wdata_cfg or HWRITE)
    begin
    case (state_reg)
     ST_IDLE :
     begin
        if (PCLKEN & apb_select & ~(reg_wdata_cfg & HWRITE))
           next_state = ST_APB_TRNF; 
        else if (apb_select)
           next_state = ST_APB_WAIT; 
        else
           next_state = ST_IDLE; 
     end
     ST_APB_WAIT :
     begin
        if (PCLKEN)
           next_state = ST_APB_TRNF; 
        else
           next_state = ST_APB_WAIT; 
     end
     ST_APB_TRNF :
     begin
        if (PCLKEN)
           next_state = ST_APB_TRNF2;   
        else
           next_state = ST_APB_TRNF;   
     end
     ST_APB_TRNF2 :
     begin
        if (PREADY & PSLVERR & PCLKEN) 
           next_state = ST_APB_ERR1; 
        else if (PREADY & (~PSLVERR) & PCLKEN) 
        begin
           if (reg_rdata_cfg)
              next_state = ST_APB_ENDOK; 
           else
              next_state = {2'b00, apb_select}; 
        end
        else 
           next_state = ST_APB_TRNF2; 
     end
     ST_APB_ENDOK :
     begin
         if (PCLKEN & apb_select & ~(reg_wdata_cfg & HWRITE))
            next_state = ST_APB_TRNF; 
         else if (apb_select)
            next_state = ST_APB_WAIT; 
         else
            next_state = ST_IDLE; 
     end
     ST_APB_ERR1 : next_state = ST_APB_ERR2; 
     ST_APB_ERR2 :
     begin
        if (PCLKEN & apb_select & ~(reg_wdata_cfg & HWRITE))
           next_state = ST_APB_TRNF; 
        else if (apb_select)
           next_state = ST_APB_WAIT; 
        else
           next_state = ST_IDLE; 
     end
     default : 
            next_state = 3'bxxx; 
    endcase
    end

  always @(posedge HCLK or negedge HRESETn)
  begin
  if (~HRESETn)
    state_reg <= 3'b000;
  else
    state_reg <= next_state;
  end

  always @(posedge HCLK or negedge HRESETn)
  begin
  if (~HRESETn)
    rwdata_reg <= {32{1'b0}};
  else
    if (sample_wdata_reg & reg_wdata_cfg & PCLKEN)
      rwdata_reg <= HWDATA;
    else if (apb_tran_end & reg_rdata_cfg & PCLKEN)
      rwdata_reg <= PRDATA;
  end

  assign PADDR   = {addr_reg, 2'b00}; 
  assign PWRITE  = wr_reg;            
  assign PWDATA  = (reg_wdata_cfg) ? rwdata_reg : HWDATA;
  assign PSEL    = (state_reg==ST_APB_TRNF) | (state_reg==ST_APB_TRNF2);
  assign PENABLE = (state_reg==ST_APB_TRNF2);
  assign PPROT   = {pprot_reg[1], 1'b0, pprot_reg[0]};
  assign PSTRB   = pstrb_reg[3:0];

  always @(state_reg or reg_rdata_cfg or PREADY or PSLVERR or PCLKEN)
  begin
    case (state_reg)
      ST_IDLE      : HREADYOUT = 1'b1; 
      ST_APB_WAIT  : HREADYOUT = 1'b0; 
      ST_APB_TRNF  : HREADYOUT = 1'b0; 
      ST_APB_TRNF2 : HREADYOUT = (~reg_rdata_cfg) & PREADY & (~PSLVERR) & PCLKEN;
      ST_APB_ENDOK : HREADYOUT = reg_rdata_cfg; 
      ST_APB_ERR1  : HREADYOUT = 1'b0; 
      ST_APB_ERR2  : HREADYOUT = 1'b1; 
      default: HREADYOUT = 1'bx; 
    endcase
  end

  assign HRDATA = (reg_rdata_cfg) ? rwdata_reg : PRDATA;
  assign HRESP  = (state_reg==ST_APB_ERR1) | (state_reg==ST_APB_ERR2);

  assign APBACTIVE = (HSEL & HTRANS[1]) | (|state_reg);

`ifdef ARM_AHB_ASSERT_ON
`include "std_ovl_defines.h"
  reg [31:0] ovl_last_read_apb_data_reg;
  always @(posedge HCLK or negedge HRESETn)
  begin
  if (~HRESETn)
    ovl_last_read_apb_data_reg <= {32{1'b0}};
  else if (PREADY & PENABLE & (~PWRITE) & PSEL & PCLKEN)
    ovl_last_read_apb_data_reg <= PRDATA;
  end

  reg        ovl_last_read_apb_resp_reg;
  always @(posedge HCLK or negedge HRESETn)
  begin
  if (~HRESETn)
    ovl_last_read_apb_resp_reg <= 1'b0;
  else
    begin
    if (PCLKEN)
      begin
      if (PREADY & PSEL)
         ovl_last_read_apb_resp_reg <= PSLVERR & PENABLE;
      else if (PSEL)
         ovl_last_read_apb_resp_reg <= 1'b0;
      end
    end
  end

  reg        ovl_ahb_data_phase_reg;
  wire       ovl_ahb_data_phase_nxt = HSEL & HTRANS[1];

  always @(posedge HCLK or negedge HRESETn)
  begin
  if (~HRESETn)
    ovl_ahb_data_phase_reg <= 1'b0;
  else if (HREADY)
    ovl_ahb_data_phase_reg <= ovl_ahb_data_phase_nxt;
  end

generate
      if(REGISTER_RDATA!=0) begin : gen_ovl_read_data_mistmatch

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "Read data mismatch")
   u_ovl_read_data_mistmatch
     (.clk(HCLK), .reset_n(HRESETn),
      .antecedent_expr(ovl_ahb_data_phase_reg & (~wr_reg) & HREADYOUT & (~HRESP)),
      .consequent_expr(ovl_last_read_apb_data_reg==HRDATA)
      );
      end
endgenerate

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "Response mismatch")
   u_ovl_resp_mistmatch
     (.clk(HCLK), .reset_n(HRESETn),
      .antecedent_expr(ovl_ahb_data_phase_reg & HREADYOUT),
      .consequent_expr(ovl_last_read_apb_resp_reg==HRESP)
      );

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "APBACTIVE should be active when PSEL is high")
   u_ovl_apbactive_1
     (.clk(HCLK), .reset_n(HRESETn),
      .antecedent_expr(PSEL),
      .consequent_expr(APBACTIVE)
      );

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "APBACTIVE should be active when there is an active transfer (data phase)")
   u_ovl_apbactive_2
     (.clk(HCLK), .reset_n(HRESETn),
      .antecedent_expr(~HREADYOUT),
      .consequent_expr(APBACTIVE)
      );

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "APBACTIVE should be active when AHB to APB bridge is selected")
   u_ovl_apbactive_3
     (.clk(HCLK), .reset_n(HRESETn),
      .antecedent_expr((HSEL & HTRANS[1])),
      .consequent_expr(APBACTIVE)
      );

  reg        ovl_transfer_started_reg;
  wire       ovl_transfer_started_nxt = (HREADY & ovl_ahb_data_phase_nxt) |
                                    (ovl_transfer_started_reg & (~PSEL));

  always @(posedge HCLK or negedge HRESETn)
  begin
  if (~HRESETn)
    ovl_transfer_started_reg <= 1'b0;
  else
    ovl_transfer_started_reg <= ovl_transfer_started_nxt;
  end

   assert_never
     #(`OVL_ERROR,`OVL_ASSERT,
       "APB transfer missing.")
   u_ovl_apb_transfer_missing
     (.clk(HCLK), .reset_n(HRESETn),
      .test_expr(HREADY & ovl_ahb_data_phase_nxt & ovl_transfer_started_reg)
      );

   assert_never
     #(`OVL_ERROR,`OVL_ASSERT,
       "state_reg in illegal state")
   u_ovl_rx_state_illegal
     (.clk(HCLK), .reset_n(HRESETn),
      .test_expr(state_reg==ST_ILLEGAL));

`endif

endmodule

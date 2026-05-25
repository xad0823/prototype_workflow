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


`timescale 1ns/1ps


module sse710_integration_example_f0_ahb_mtx_output_stageTARGEXP1 (

    HCLK,
    HRESETn,

    sel_op0,
    addr_op0,
    auser_op0,
    trans_op0,
    write_op0,
    size_op0,
    burst_op0,
    prot_op0,
    master_op0,
    mastlock_op0,
    wdata_op0,
    wuser_op0,
    held_tran_op0,

    sel_op1,
    addr_op1,
    auser_op1,
    trans_op1,
    write_op1,
    size_op1,
    burst_op1,
    prot_op1,
    master_op1,
    mastlock_op1,
    wdata_op1,
    wuser_op1,
    held_tran_op1,

    sel_op2,
    addr_op2,
    auser_op2,
    trans_op2,
    write_op2,
    size_op2,
    burst_op2,
    prot_op2,
    master_op2,
    mastlock_op2,
    wdata_op2,
    wuser_op2,
    held_tran_op2,

    sel_op3,
    addr_op3,
    auser_op3,
    trans_op3,
    write_op3,
    size_op3,
    burst_op3,
    prot_op3,
    master_op3,
    mastlock_op3,
    wdata_op3,
    wuser_op3,
    held_tran_op3,

    HREADYOUTM,

    active_op0,
    active_op1,
    active_op2,
    active_op3,

    HSELM,
    HADDRM,
    HAUSERM,
    HTRANSM,
    HWRITEM,
    HSIZEM,
    HBURSTM,
    HPROTM,
    HMASTERM,
    HMASTLOCKM,
    HREADYMUXM,
    HWUSERM,
    HWDATAM

    );



    input         HCLK;       
    input         HRESETn;    

    input         sel_op0;       
    input [31:0]  addr_op0;      
    input [3:0]  auser_op0;     
    input  [1:0]  trans_op0;     
    input         write_op0;     
    input  [2:0]  size_op0;      
    input  [2:0]  burst_op0;     
    input  [3:0]  prot_op0;      
    input  [3:0]  master_op0;    
    input         mastlock_op0;  
    input [31:0]  wdata_op0;     
    input [3:0]  wuser_op0;     
    input         held_tran_op0;  

    input         sel_op1;       
    input [31:0]  addr_op1;      
    input [3:0]  auser_op1;     
    input  [1:0]  trans_op1;     
    input         write_op1;     
    input  [2:0]  size_op1;      
    input  [2:0]  burst_op1;     
    input  [3:0]  prot_op1;      
    input  [3:0]  master_op1;    
    input         mastlock_op1;  
    input [31:0]  wdata_op1;     
    input [3:0]  wuser_op1;     
    input         held_tran_op1;  

    input         sel_op2;       
    input [31:0]  addr_op2;      
    input [3:0]  auser_op2;     
    input  [1:0]  trans_op2;     
    input         write_op2;     
    input  [2:0]  size_op2;      
    input  [2:0]  burst_op2;     
    input  [3:0]  prot_op2;      
    input  [3:0]  master_op2;    
    input         mastlock_op2;  
    input [31:0]  wdata_op2;     
    input [3:0]  wuser_op2;     
    input         held_tran_op2;  

    input         sel_op3;       
    input [31:0]  addr_op3;      
    input [3:0]  auser_op3;     
    input  [1:0]  trans_op3;     
    input         write_op3;     
    input  [2:0]  size_op3;      
    input  [2:0]  burst_op3;     
    input  [3:0]  prot_op3;      
    input  [3:0]  master_op3;    
    input         mastlock_op3;  
    input [31:0]  wdata_op3;     
    input [3:0]  wuser_op3;     
    input         held_tran_op3;  

    input         HREADYOUTM; 

    output        active_op0;    
    output        active_op1;    
    output        active_op2;    
    output        active_op3;    

    output        HSELM;      
    output [31:0] HADDRM;     
    output [3:0] HAUSERM;    
    output  [1:0] HTRANSM;    
    output        HWRITEM;    
    output  [2:0] HSIZEM;     
    output  [2:0] HBURSTM;    
    output  [3:0] HPROTM;     
    output  [3:0] HMASTERM;   
    output        HMASTLOCKM; 
    output        HREADYMUXM; 
    output [3:0] HWUSERM;    
    output [31:0] HWDATAM;    


    wire        HCLK;       
    wire        HRESETn;    

    wire        sel_op0;       
    wire [31:0] addr_op0;      
    wire [3:0] auser_op0;     
    wire  [1:0] trans_op0;     
    wire        write_op0;     
    wire  [2:0] size_op0;      
    wire  [2:0] burst_op0;     
    wire  [3:0] prot_op0;      
    wire  [3:0] master_op0;    
    wire        mastlock_op0;  
    wire [31:0] wdata_op0;     
    wire [3:0] wuser_op0;     
    wire        held_tran_op0;  
    reg         active_op0;    

    wire        sel_op1;       
    wire [31:0] addr_op1;      
    wire [3:0] auser_op1;     
    wire  [1:0] trans_op1;     
    wire        write_op1;     
    wire  [2:0] size_op1;      
    wire  [2:0] burst_op1;     
    wire  [3:0] prot_op1;      
    wire  [3:0] master_op1;    
    wire        mastlock_op1;  
    wire [31:0] wdata_op1;     
    wire [3:0] wuser_op1;     
    wire        held_tran_op1;  
    reg         active_op1;    

    wire        sel_op2;       
    wire [31:0] addr_op2;      
    wire [3:0] auser_op2;     
    wire  [1:0] trans_op2;     
    wire        write_op2;     
    wire  [2:0] size_op2;      
    wire  [2:0] burst_op2;     
    wire  [3:0] prot_op2;      
    wire  [3:0] master_op2;    
    wire        mastlock_op2;  
    wire [31:0] wdata_op2;     
    wire [3:0] wuser_op2;     
    wire        held_tran_op2;  
    reg         active_op2;    

    wire        sel_op3;       
    wire [31:0] addr_op3;      
    wire [3:0] auser_op3;     
    wire  [1:0] trans_op3;     
    wire        write_op3;     
    wire  [2:0] size_op3;      
    wire  [2:0] burst_op3;     
    wire  [3:0] prot_op3;      
    wire  [3:0] master_op3;    
    wire        mastlock_op3;  
    wire [31:0] wdata_op3;     
    wire [3:0] wuser_op3;     
    wire        held_tran_op3;  
    reg         active_op3;    

    wire        HSELM;      
    reg  [31:0] HADDRM;     
    reg  [3:0] HAUSERM;    
    wire  [1:0] HTRANSM;    
    reg         HWRITEM;    
    reg   [2:0] HSIZEM;     
    wire  [2:0] HBURSTM;    
    reg   [3:0] HPROTM;     
    reg   [3:0] HMASTERM;   
    wire        HMASTLOCKM; 
    wire        HREADYMUXM; 
    reg  [3:0] HWUSERM;    
    reg  [31:0] HWDATAM;    
    wire        HREADYOUTM; 


    wire        req_port0;     
    wire        req_port1;     
    wire        req_port2;     
    wire        req_port3;     

    wire  [1:0] addr_in_port;   
    reg   [1:0] data_in_port;   
    wire        no_port;       
    reg         slave_sel;     
    reg         wdata_phase;   

    reg         hsel_lock;     
    wire        next_hsel_lock; 
    wire        hlock_arb;     

    reg         i_hselm;       
    reg   [1:0] i_htransm;     
    reg   [2:0] i_hburstm;     
    wire        i_hreadymuxm;  
    reg         i_hmastlockm;  




  assign req_port0 = held_tran_op0 & sel_op0;
  assign req_port1 = held_tran_op1 & sel_op1;
  assign req_port2 = held_tran_op2 & sel_op2;
  assign req_port3 = held_tran_op3 & sel_op3;

  sse710_integration_example_f0_ahb_mtx_arbiterTARGEXP1 u_output_arb (

    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    .req_port0   (req_port0),
    .req_port1   (req_port1),
    .req_port2   (req_port2),
    .req_port3   (req_port3),

    .HREADYM    (i_hreadymuxm),
    .HSELM      (i_hselm),
    .HTRANSM    (i_htransm),
    .HBURSTM    (i_hburstm),
    .HMASTLOCKM (hlock_arb),

    .addr_in_port (addr_in_port),
    .no_port     (no_port)

    );


  always @ (addr_in_port or no_port)
    begin : p_active_comb
      active_op0 = 1'b0;
      active_op1 = 1'b0;
      active_op2 = 1'b0;
      active_op3 = 1'b0;

      if (~no_port)
        case (addr_in_port)
          2'b00 : active_op0 = 1'b1;
          2'b01 : active_op1 = 1'b1;
          2'b10 : active_op2 = 1'b1;
          2'b11 : active_op3 = 1'b1;
          default : begin
            active_op0 = 1'bx;
            active_op1 = 1'bx;
            active_op2 = 1'bx;
            active_op3 = 1'bx;
          end
        endcase 
    end 


  always @ (
             sel_op0 or addr_op0 or trans_op0 or write_op0 or
             size_op0 or burst_op0 or prot_op0 or
             auser_op0 or
             master_op0 or mastlock_op0 or
             sel_op1 or addr_op1 or trans_op1 or write_op1 or
             size_op1 or burst_op1 or prot_op1 or
             auser_op1 or
             master_op1 or mastlock_op1 or
             sel_op2 or addr_op2 or trans_op2 or write_op2 or
             size_op2 or burst_op2 or prot_op2 or
             auser_op2 or
             master_op2 or mastlock_op2 or
             sel_op3 or addr_op3 or trans_op3 or write_op3 or
             size_op3 or burst_op3 or prot_op3 or
             auser_op3 or
             master_op3 or mastlock_op3 or
             addr_in_port or no_port
           )
    begin : p_addr_mux
      i_hselm     = 1'b0;
      HADDRM      = {32{1'b0}};
      HAUSERM     = {4{1'b0}};
      i_htransm   = 2'b00;
      HWRITEM     = 1'b0;
      HSIZEM      = 3'b000;
      i_hburstm   = 3'b000;
      HPROTM      = {4{1'b0}};
      HMASTERM    = 4'b0000;
      i_hmastlockm= 1'b0;

      if (~no_port)
        case (addr_in_port)
          2'b00 :
            begin
              i_hselm     = sel_op0;
              HADDRM      = addr_op0;
              HAUSERM     = auser_op0;
              i_htransm   = trans_op0;
              HWRITEM     = write_op0;
              HSIZEM      = size_op0;
              i_hburstm   = burst_op0;
              HPROTM      = prot_op0;
              HMASTERM    = master_op0;
              i_hmastlockm= mastlock_op0;
            end 

          2'b01 :
            begin
              i_hselm     = sel_op1;
              HADDRM      = addr_op1;
              HAUSERM     = auser_op1;
              i_htransm   = trans_op1;
              HWRITEM     = write_op1;
              HSIZEM      = size_op1;
              i_hburstm   = burst_op1;
              HPROTM      = prot_op1;
              HMASTERM    = master_op1;
              i_hmastlockm= mastlock_op1;
            end 

          2'b10 :
            begin
              i_hselm     = sel_op2;
              HADDRM      = addr_op2;
              HAUSERM     = auser_op2;
              i_htransm   = trans_op2;
              HWRITEM     = write_op2;
              HSIZEM      = size_op2;
              i_hburstm   = burst_op2;
              HPROTM      = prot_op2;
              HMASTERM    = master_op2;
              i_hmastlockm= mastlock_op2;
            end 

          2'b11 :
            begin
              i_hselm     = sel_op3;
              HADDRM      = addr_op3;
              HAUSERM     = auser_op3;
              i_htransm   = trans_op3;
              HWRITEM     = write_op3;
              HSIZEM      = size_op3;
              i_hburstm   = burst_op3;
              HPROTM      = prot_op3;
              HMASTERM    = master_op3;
              i_hmastlockm= mastlock_op3;
            end 

          default :
            begin
              i_hselm     = 1'bx;
              HADDRM      = {32{1'bx}};
              HAUSERM     = {4{1'bx}};
              i_htransm   = 2'bxx;
              HWRITEM     = 1'bx;
              HSIZEM      = 3'bxxx;
              i_hburstm   = 3'bxxx;
              HPROTM      = {4{1'bx}};
              HMASTERM    = 4'bxxxx;
              i_hmastlockm= 1'bx;
            end 
        endcase 
    end 

  assign next_hsel_lock = (i_hselm & i_htransm[1] & i_hmastlockm) ? 1'b1 :
                         (i_hmastlockm == 1'b0) ? 1'b0 :
                          hsel_lock;

  always @ (negedge HRESETn or posedge HCLK)
    begin : p_hsel_lock
      if (~HRESETn)
        hsel_lock <= 1'b0;
      else
        if (i_hreadymuxm)
          hsel_lock <= next_hsel_lock;
    end

  assign hlock_arb = i_hmastlockm & (hsel_lock | i_hselm);

  assign HTRANSM    = i_htransm;
  assign HBURSTM    = i_hburstm;
  assign HSELM      = i_hselm;
  assign HMASTLOCKM = i_hmastlockm;

  always @ (negedge HRESETn or posedge HCLK)
    begin : p_data_in_port_reg
      if (~HRESETn)
        data_in_port <= 2'b11;
      else
        if (i_hreadymuxm)
          data_in_port <= addr_in_port;
    end

  always @ (negedge HRESETn or posedge HCLK)
    begin : p_wdata_phase_reg
      if (~HRESETn)
        wdata_phase <= 1'b0;
      else
        if (i_hreadymuxm)
          wdata_phase <= i_hselm & i_htransm[1];
    end


  always @ (
             wdata_op0 or
             wdata_op1 or
             wdata_op2 or
             wdata_op3 or
             data_in_port or wdata_phase
           )
    begin : p_data_mux
      HWDATAM = {32{1'b0}};

      if (wdata_phase)
        case (data_in_port)
          2'b00 : HWDATAM  = wdata_op0;
          2'b01 : HWDATAM  = wdata_op1;
          2'b10 : HWDATAM  = wdata_op2;
          2'b11 : HWDATAM  = wdata_op3;
          default : HWDATAM = {32{1'bx}};
        endcase 
    end 

  always @ (
             wuser_op0 or
             wuser_op1 or
             wuser_op2 or
             wuser_op3 or
             data_in_port or wdata_phase
           )
    begin : p_wuser_mux
      HWUSERM  = {4{1'b0}};

      if (wdata_phase)
        case (data_in_port)
          2'b00 : HWUSERM  = wuser_op0;
          2'b01 : HWUSERM  = wuser_op1;
          2'b10 : HWUSERM  = wuser_op2;
          2'b11 : HWUSERM  = wuser_op3;
          default : HWUSERM  = {4{1'bx}};
        endcase 
    end 

  always @ (negedge HRESETn or posedge HCLK)
    begin : p_slave_sel_reg
      if (~HRESETn)
         slave_sel <= 1'b0;
      else
        if (i_hreadymuxm)
           slave_sel  <= i_hselm;
    end

  assign i_hreadymuxm = (slave_sel) ? HREADYOUTM : 1'b1;

  assign HREADYMUXM = i_hreadymuxm;


endmodule


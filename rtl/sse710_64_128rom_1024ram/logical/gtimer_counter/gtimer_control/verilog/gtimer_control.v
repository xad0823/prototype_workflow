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


module gtimer_control #(
  parameter TIMER0_FI        = 1'b1,
  parameter TIMER0_FVI       = 1'b1,
  parameter TIMER0_FPL0      = 1'b1,
  parameter TIMER0_CFGBL_ACC = 1'b1,
  parameter TIMER0_NONSECURE = 1'b0,
  parameter TIMER1_FI        = 1'b1,
  parameter TIMER1_FVI       = 1'b1,
  parameter TIMER1_FPL0      = 1'b1,
  parameter TIMER1_CFGBL_ACC = 1'b1,
  parameter TIMER1_NONSECURE = 1'b0,
  parameter TIMER2_FI        = 1'b1,
  parameter TIMER2_FVI       = 1'b1,
  parameter TIMER2_FPL0      = 1'b1,
  parameter TIMER2_CFGBL_ACC = 1'b1,
  parameter TIMER2_NONSECURE = 1'b0,
  parameter TIMER3_FI        = 1'b1,
  parameter TIMER3_FVI       = 1'b1,
  parameter TIMER3_FPL0      = 1'b1,
  parameter TIMER3_CFGBL_ACC = 1'b1,
  parameter TIMER3_NONSECURE = 1'b0,
  parameter TIMER4_FI        = 1'b1,
  parameter TIMER4_FVI       = 1'b1,
  parameter TIMER4_FPL0      = 1'b1,
  parameter TIMER4_CFGBL_ACC = 1'b1,
  parameter TIMER4_NONSECURE = 1'b0,
  parameter TIMER5_FI        = 1'b1,
  parameter TIMER5_FVI       = 1'b1,
  parameter TIMER5_FPL0      = 1'b1,
  parameter TIMER5_CFGBL_ACC = 1'b1,
  parameter TIMER5_NONSECURE = 1'b0,
  parameter TIMER6_FI        = 1'b1,
  parameter TIMER6_FVI       = 1'b1,
  parameter TIMER6_FPL0      = 1'b1,
  parameter TIMER6_CFGBL_ACC = 1'b1,
  parameter TIMER6_NONSECURE = 1'b0,
  parameter TIMER7_FI        = 1'b1,
  parameter TIMER7_FVI       = 1'b1,
  parameter TIMER7_FPL0      = 1'b1,
  parameter TIMER7_CFGBL_ACC = 1'b1,
  parameter TIMER7_NONSECURE = 1'b0
  )(
  input  wire         PCLK,                
  input  wire         PRESETn,             

  input  wire         PSEL,                
  input  wire  [11:2] PADDR,               
  input  wire         PENABLE,             
  input  wire         PWRITE,              
  input  wire   [2:0] PPROT,               
  input  wire   [3:0] PSTRB,               
  input  wire  [31:0] PWDATA,              
  output wire         PREADY,              
  output wire  [31:0] PRDATA,              
  output wire         PSLVERR,             

  output wire   [5:0] CNTACR0,             
  output wire  [63:0] CNTVOFF0,            

  output wire   [5:0] CNTACR1,             
  output wire  [63:0] CNTVOFF1,            
  
  output wire   [5:0] CNTACR2,             
  output wire  [63:0] CNTVOFF2,            
  
  output wire   [5:0] CNTACR3,             
  output wire  [63:0] CNTVOFF3,            
  
  output wire   [5:0] CNTACR4,             
  output wire  [63:0] CNTVOFF4,            
  
  output wire   [5:0] CNTACR5,             
  output wire  [63:0] CNTVOFF5,            
  
  output wire   [5:0] CNTACR6,             
  output wire  [63:0] CNTVOFF6,            
  
  output wire   [5:0] CNTACR7,             
  output wire  [63:0] CNTVOFF7,            

  output wire         TIMER0FVIREG,        
  output wire         TIMER0FPL0REG,       
  
  output wire         TIMER1FVIREG,        
  output wire         TIMER1FPL0REG,       
  
  output wire         TIMER2FVIREG,        
  output wire         TIMER2FPL0REG,       
  
  output wire         TIMER3FVIREG,        
  output wire         TIMER3FPL0REG,       
  
  output wire         TIMER4FVIREG,        
  output wire         TIMER4FPL0REG,       
  
  output wire         TIMER5FVIREG,        
  output wire         TIMER5FPL0REG,       
  
  output wire         TIMER6FVIREG,        
  output wire         TIMER6FPL0REG,       
  
  output wire         TIMER7FVIREG,        
  output wire         TIMER7FPL0REG        
);



wire [3:0]   tieoff1;           
wire [3:0]   tieoff2;           
wire [3:0]   revision;          
                                
wire [7:0]   dum;               
wire         TIMER0_FI_REG;
wire         TIMER1_FI_REG;
wire         TIMER2_FI_REG;
wire         TIMER3_FI_REG;
wire         TIMER4_FI_REG;
wire         TIMER5_FI_REG;
wire         TIMER6_FI_REG;
wire         TIMER7_FI_REG;




reg  [3:0]       tieoff1_static_r;
wire [3:0]       tieoff1_static_o;
reg              tieoff1_static_up;
wire             tieoff1_static_en;

always@(posedge PCLK)
begin
  if(tieoff1_static_en)
  begin
    tieoff1_static_r <= 4'b0000;
  end
end

always@(posedge PCLK or negedge PRESETn)
begin
  if(!PRESETn)
  begin
    tieoff1_static_up <= 1'b1;
  end
  else if(tieoff1_static_en)
  begin
    tieoff1_static_up <= 1'b0;
  end
end

assign tieoff1_static_en = tieoff1_static_up;

assign tieoff1_static_o = tieoff1_static_r;


reg  [3:0]       tieoff2_static_r;
wire [3:0]       tieoff2_static_o;
reg              tieoff2_static_up;
wire             tieoff2_static_en;

always@(posedge PCLK)
begin
  if(tieoff2_static_en)
  begin
    tieoff2_static_r <= 4'b0000;
  end
end

always@(posedge PCLK or negedge PRESETn)
begin
  if(!PRESETn)
  begin
    tieoff2_static_up <= 1'b1;
  end
  else if(tieoff2_static_en)
  begin
    tieoff2_static_up <= 1'b0;
  end
end

assign tieoff2_static_en = tieoff2_static_up;

assign tieoff2_static_o = tieoff2_static_r;


assign tieoff1          = tieoff1_static_o;
assign tieoff2          = tieoff2_static_o;

gtimer_control_revision  u_gtimer_control_revision_0 (
                    .tieoff1           ( tieoff1[0]        ),  
                    .tieoff2           ( tieoff2[0]        ),  
                    .revision          ( revision[0]       )   
                     );

gtimer_control_revision  u_gtimer_control_revision_1 (
                    .tieoff1           ( tieoff1[1]        ),  
                    .tieoff2           ( tieoff2[1]        ),  
                    .revision          ( revision[1]       )   
                     );

gtimer_control_revision  u_gtimer_control_revision_2 (
                    .tieoff1           ( tieoff1[2]        ),  
                    .tieoff2           ( tieoff2[2]        ),  
                    .revision          ( revision[2]       )   
                     );

gtimer_control_revision  u_gtimer_control_revision_3 (
                    .tieoff1           ( tieoff1[3]        ),  
                    .tieoff2           ( tieoff2[3]        ),  
                    .revision          ( revision[3]       )   
                     );

gtimer_control_apbif #(
                     .TIMER0_FI(TIMER0_FI), .TIMER0_FVI(TIMER0_FVI), .TIMER0_FPL0(TIMER0_FPL0),
                     .TIMER0_CFGBL_ACC(TIMER0_CFGBL_ACC), .TIMER0_NONSECURE(TIMER0_NONSECURE),
                     .TIMER1_FI(TIMER1_FI), .TIMER1_FVI(TIMER1_FVI), .TIMER1_FPL0(TIMER1_FPL0),
                     .TIMER1_CFGBL_ACC(TIMER1_CFGBL_ACC), .TIMER1_NONSECURE(TIMER1_NONSECURE),
                     .TIMER2_FI(TIMER2_FI), .TIMER2_FVI(TIMER2_FVI), .TIMER2_FPL0(TIMER2_FPL0),
                     .TIMER2_CFGBL_ACC(TIMER2_CFGBL_ACC), .TIMER2_NONSECURE(TIMER2_NONSECURE),
                     .TIMER3_FI(TIMER3_FI), .TIMER3_FVI(TIMER3_FVI), .TIMER3_FPL0(TIMER3_FPL0),
                     .TIMER3_CFGBL_ACC(TIMER3_CFGBL_ACC), .TIMER3_NONSECURE(TIMER3_NONSECURE),
                     .TIMER4_FI(TIMER4_FI), .TIMER4_FVI(TIMER4_FVI), .TIMER4_FPL0(TIMER4_FPL0),
                     .TIMER4_CFGBL_ACC(TIMER4_CFGBL_ACC), .TIMER4_NONSECURE(TIMER4_NONSECURE),
                     .TIMER5_FI(TIMER5_FI), .TIMER5_FVI(TIMER5_FVI), .TIMER5_FPL0(TIMER5_FPL0),
                     .TIMER5_CFGBL_ACC(TIMER5_CFGBL_ACC), .TIMER5_NONSECURE(TIMER5_NONSECURE),
                     .TIMER6_FI(TIMER6_FI), .TIMER6_FVI(TIMER6_FVI), .TIMER6_FPL0(TIMER6_FPL0),
                     .TIMER6_CFGBL_ACC(TIMER6_CFGBL_ACC), .TIMER6_NONSECURE(TIMER6_NONSECURE),
                     .TIMER7_FI(TIMER7_FI), .TIMER7_FVI(TIMER7_FVI), .TIMER7_FPL0(TIMER7_FPL0),
                     .TIMER7_CFGBL_ACC(TIMER7_CFGBL_ACC), .TIMER7_NONSECURE(TIMER7_NONSECURE)
                     ) u_gtimer_control_apbif (
                    .PCLK              ( PCLK              ),  
                    .PRESETn           ( PRESETn           ),  

                    .PADDR             ( PADDR             ),  
                    .PSEL              ( PSEL              ),  
                    .PENABLE           ( PENABLE           ),  
                    .PWRITE            ( PWRITE            ),  
                    .PPROT             ( PPROT             ),  
                    .PSTRB             ( PSTRB             ),  
                    .PWDATA            ( PWDATA            ),  

                    .PREADY            ( PREADY            ),  
                    .PRDATA            ( PRDATA            ),  
                    .PSLVERR           ( PSLVERR           ),  
                    
                    .revision          ( revision          ),  
                    
                    .cnttidr           ({dum[7], TIMER7FPL0REG, TIMER7FVIREG, TIMER7_FI_REG,
                                         dum[6], TIMER6FPL0REG, TIMER6FVIREG, TIMER6_FI_REG,
                                         dum[5], TIMER5FPL0REG, TIMER5FVIREG, TIMER5_FI_REG,
                                         dum[4], TIMER4FPL0REG, TIMER4FVIREG, TIMER4_FI_REG,
                                         dum[3], TIMER3FPL0REG, TIMER3FVIREG, TIMER3_FI_REG,
                                         dum[2], TIMER2FPL0REG, TIMER2FVIREG, TIMER2_FI_REG,
                                         dum[1], TIMER1FPL0REG, TIMER1FVIREG, TIMER1_FI_REG,
                                         dum[0], TIMER0FPL0REG, TIMER0FVIREG, TIMER0_FI_REG}
                                                           ), 


                    .CNTACR0           ( CNTACR0           ),  
                    .CNTVOFF0          ( CNTVOFF0          ),  
                    
                    .CNTACR1           ( CNTACR1           ),  
                    .CNTVOFF1          ( CNTVOFF1          ),  
                    
                    .CNTACR2           ( CNTACR2           ),  
                    .CNTVOFF2          ( CNTVOFF2          ),  
                    
                    .CNTACR3           ( CNTACR3           ),  
                    .CNTVOFF3          ( CNTVOFF3          ),  
                    
                    .CNTACR4           ( CNTACR4           ),  
                    .CNTVOFF4          ( CNTVOFF4          ),  
                    
                    .CNTACR5           ( CNTACR5           ),  
                    .CNTVOFF5          ( CNTVOFF5          ),  
                    
                    .CNTACR6           ( CNTACR6           ),  
                    .CNTVOFF6          ( CNTVOFF6          ),  
                    
                    .CNTACR7           ( CNTACR7           ),  
                    .CNTVOFF7          ( CNTVOFF7          )   
                     );
                     

endmodule


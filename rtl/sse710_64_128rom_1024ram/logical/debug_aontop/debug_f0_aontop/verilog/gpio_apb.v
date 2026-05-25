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

module gpio_apb
#(
    parameter GPIO_INPUT     = 1,
    parameter GPIO_OUTPUT    = 1,
    
    parameter GPIO_INPUT_W     = GPIO_INPUT  == 0 ? 1 : GPIO_INPUT, 
    parameter GPIO_OUTPUT_W    = GPIO_OUTPUT == 0 ? 1 : GPIO_OUTPUT
    
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
    
    input wire                 dbgen,
    
    output wire [GPIO_OUTPUT_W-1:0]  gpio_out,
    input  wire [GPIO_INPUT_W-1:0]   gpio_in
    

);  

    reg [11:0]  paddr_reg;
    
    reg    [GPIO_OUTPUT_W-1:0] gpio_out_reg;
    wire   [GPIO_OUTPUT_W-1:0] nx_gpio_out_reg;
    wire   [GPIO_OUTPUT_W-1:0] prdata_gpioin;
    wire   [GPIO_INPUT_W-1:0]  prdata_gpioout;
    


    localparam PID4 = 32'h04;
    localparam PID5 = 32'h00;
    localparam PID6 = 32'h00;
    localparam PID7 = 32'h00;
    localparam PID0 = 32'hF0;
    localparam PID1 = 32'hB9;
    
    localparam CID0 = 32'h0D;
    localparam CID1 = 32'h90;
    localparam CID2 = 32'h05;
    localparam CID3 = 32'hB1;
    
    wire [31:0] pid2;
    wire [31:0] pid3;
    
    wire [3:0] pid2_eco;
    wire [3:0] pid3_eco;
        
    assign pid2 = {24'd0,pid2_eco,4'hB};
    assign pid3 = {24'd0,pid3_eco,4'h0};
    
    arm_element_ecorevnum #( .WIDTH(4), .ECOREVVAL(0) ) u_pid2 ( .ecorevnum(pid2_eco) );
    arm_element_ecorevnum #( .WIDTH(4), .ECOREVVAL(0) ) u_pid3 ( .ecorevnum(pid3_eco) );
    
    always @(posedge clk or negedge resetn)
    begin
      if (!resetn)
      begin           
       paddr_reg<=12'd0;
       gpio_out_reg<={GPIO_OUTPUT_W{1'b0}};
      end
      else
      begin       
  
        if(psel) 
        begin
            if(!penable)
            begin
                paddr_reg<=paddr;             
            end
            else 
            begin
                if(pwrite && dbgen)
                begin
                    gpio_out_reg<=nx_gpio_out_reg;
                end
            end
        end
      end
    end
    
    
    
    genvar i;
    generate
    for(i=0;i<GPIO_INPUT;i=i+1) begin : prdata_in    
      assign prdata_gpioin[i] = paddr_reg == (12'h100+(i*4)) ? gpio_in[i] : 1'b0;      
    end
    endgenerate
    
    generate
    for(i=0;i<GPIO_OUTPUT;i=i+1) begin: prdata_out
    
      assign nx_gpio_out_reg[i] = paddr_reg == (i*4) ? pwdata[0]       : gpio_out_reg[i];
      assign prdata_gpioout[i]  = paddr_reg == (i*4) ? gpio_out_reg[i] : 1'b0;
    end
    endgenerate
  
    assign gpio_out = gpio_out_reg;
    
    assign pready = 1'b1;    
    
    assign pslverr = 1'b0;
        
    assign prdata = paddr_reg <  12'h80                         ? {31'd0,(|prdata_gpioout)}   :
                    paddr_reg >= 12'h100 && paddr_reg < 12'h180 ? {31'd0,(|prdata_gpioin ) & dbgen}   :
                    paddr_reg == 12'hFB8                        ? {30'd0,1'b1,dbgen} :
                    paddr_reg == 12'hFC8                        ? {16'd0,2'd0,GPIO_INPUT[5:0],2'd0,GPIO_OUTPUT[5:0]} : 
                    paddr_reg == 12'hFD0                        ? PID4 :
                    paddr_reg == 12'hFD4                        ? PID5 :
                    paddr_reg == 12'hFD8                        ? PID6 :
                    paddr_reg == 12'hFDC                        ? PID7 :
                    paddr_reg == 12'hFE0                        ? PID0 :
                    paddr_reg == 12'hFE4                        ? PID1 :
                    paddr_reg == 12'hFE8                        ? pid2 :
                    paddr_reg == 12'hFEC                        ? pid3 :
                    paddr_reg == 12'hFF0                        ? CID0 :
                    paddr_reg == 12'hFF4                        ? CID1 :
                    paddr_reg == 12'hFF8                        ? CID2 :
                    paddr_reg == 12'hFFC                        ? CID3 :                    
                    32'd0;
    
              
    if(GPIO_OUTPUT == 0)
    begin : gpio_output_zero
        assign prdata_gpioout = 1'b0;
        assign nx_gpio_out_reg = 1'b0;
    end
    if(GPIO_INPUT == 0)
    begin : gpio_input_zero
        assign prdata_gpioin = 1'b0;
    end
    
    wire unused;
    
    assign unused = (|pwdata) | 
                    (|gpio_in);
    
endmodule


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




module clkrst_f1_clkdiv_modulate
#(
    parameter DISABLE_NEGEDGE_5050MARK = 0,
    parameter PIPELINE_DEPTH           = 0,
    parameter DISABLE_COMBO_GATELOGIC  = 0 

) 

(
  input   wire                          clkin,          
  input   wire                          clkin_divctrl,  
  input   wire                          clkin_n,        
  input   wire  [4:0]                   divratio,       

  input   wire  [7:0]                   numerator,      
  input   wire  [7:0]                   denominator,    
  input   wire                          stop_divider,   


  input   wire                          resetn_sync,    
  input   wire                          resetn_sync_n,  

  input   wire                          dftdivbypass,   
  input   wire                          dftcgen,        

  output  wire  [4:0]                   divratio_cur,   

  output  reg   [7:0]                   numerator_cur,  
  output  reg   [7:0]                   denominator_cur,

  output  wire                          divclk,         
  output  wire                          hintclken_clk   

);


  reg                                   reset_cycle_complete;       
  reg  [4:0]                            idivratio_cur;     
  reg  [4:0]                            idivratio_cur_delay; 
  reg  [5:0]                            gatecounter;       
  reg  [4:0]                            top_count;         

  reg                                   gateclkcomb;       
  wire                                  gatedclk;          
  wire                                  gatedclk_enable;   
  reg                                   gatedclk_enable_reg;
  reg                                   gatedclk_enable_hintclk_reg;
  reg                                   clockdivcomb_even;      
  reg                                   clockdiv_even;          

  reg                                   clockdivcomb_odd;  
  reg                                   clockdiv_odd;      
  reg                                   clockdiv_odd_neg;  
  wire                                  clockdiv_full;     

  wire                                  iclockdiv_full;
  wire                                  dftdivbypass_inverted;

  wire                                  idivclk;           
  reg                                   assert_enable;

  reg  [7:0]                            denominator_counter;
  reg  [7:0]                            numerator_count;
  wire                                  modulate;

  wire                                  stop_divider_sync;
  reg                                   div_clock_enable; 


  clkrst_f1_cdc_capt_sync u_clkrst_f1_cdc_capt_sync (
    .clk            (clkin),
    .nreset         (resetn_sync),
    .d_async        (stop_divider),
    .q              (stop_divider_sync));

  always @(posedge clkin or negedge resetn_sync)
  begin
    if (!resetn_sync)
    begin
      div_clock_enable       <= 1'b1;
    end
     else if (assert_enable == 1'b1)
     begin
       if (stop_divider_sync == 1'b1)
       begin
        div_clock_enable <= 1'b0;
       end 
       else
       begin
        div_clock_enable <= 1'b1;
       end
     end
     else
     begin
      div_clock_enable <= div_clock_enable;
     end
  end



  always @(posedge clkin_divctrl or negedge resetn_sync)
  begin
    if (!resetn_sync)
    begin
      numerator_count      <= 8'b00000001;
      denominator_counter  <= 8'b00000001;
       numerator_cur       <= 8'b00000001;
       denominator_cur     <= 8'b00000001;
    end
     else if (assert_enable == 1'b1)
     begin
       if (denominator_counter == 8'b00000001)
       begin
        numerator_count      <= numerator;
        denominator_counter  <= denominator;
        numerator_cur        <= numerator;
        denominator_cur      <= denominator;
       end 
       else
       begin
        denominator_counter <= denominator_counter - 8'b00000001;
       end
     end
     else
     begin
      denominator_counter <= denominator_counter;
     end
  end

  assign modulate = ((denominator_counter <= numerator_count) & div_clock_enable);



  wire  [5:0] gatecounter_pipe[PIPELINE_DEPTH:0];
  assign gatecounter_pipe[0] = gatecounter;
  
    generate
      genvar i;
      if (PIPELINE_DEPTH > 0)
        for (i=0; i<PIPELINE_DEPTH; i=i+1)
        begin : gatecounter_pipeline
          clkrst_f1_clkdiv_pipeline #(
            .COUNTER_WIDTH  (6)
          ) u_clkrst_f1_clkdiv_pipeline_gatecount (
            .clk            (clkin_divctrl),
            .nreset         (resetn_sync),
            .data_in        (gatecounter_pipe[i]),
            .data_out       (gatecounter_pipe[i+1]));
        end
    endgenerate


  wire  [4:0] idivratio_cur_pipe[PIPELINE_DEPTH:0];
  assign idivratio_cur_pipe[0] = idivratio_cur;

    generate
      genvar k;
      if (PIPELINE_DEPTH > 0)
        for (k=0; k<PIPELINE_DEPTH; k=k+1)
        begin : current_divratio_pipeline
          clkrst_f1_clkdiv_pipeline #(
            .COUNTER_WIDTH  (5)
          ) u_clkrst_f1_clkdiv_pipeline_idivratio_cur (
            .clk            (clkin_divctrl),
            .nreset         (resetn_sync),
            .data_in        (idivratio_cur_pipe[k]),
            .data_out       (idivratio_cur_pipe[k+1]));
          end
    endgenerate


  wire   reset_cycle_complete_pipe[PIPELINE_DEPTH:0];
  assign reset_cycle_complete_pipe[0] = reset_cycle_complete;

    generate
      genvar j;
      if (PIPELINE_DEPTH > 0)
        for (j=0; j<PIPELINE_DEPTH; j=j+1)
        begin : reset_inital_cycle_pipeline
          clkrst_f1_clkdiv_pipeline #(
            .COUNTER_WIDTH  (1)
          ) u_clkrst_f1_clkdiv_pipeline_reset_cycle_complete (
            .clk            (clkin_divctrl),
            .nreset         (resetn_sync),
            .data_in        (reset_cycle_complete_pipe[j]),
            .data_out       (reset_cycle_complete_pipe[j+1]));
        end
    endgenerate

 localparam PIPELINE_DEPTH_MOD1 = 1;


  wire   modulate_pipe1[PIPELINE_DEPTH_MOD1:0];
  assign modulate_pipe1[0] = modulate;

    generate
      genvar l;
      if (PIPELINE_DEPTH_MOD1 > 0)
        for (l=0; l<PIPELINE_DEPTH_MOD1; l=l+1)
        begin : reset_inital_cycle_pipeline_mod1
          clkrst_f1_clkdiv_pipeline_enable #(
            .COUNTER_WIDTH  (1)
          ) u_clkrst_f1_clkdiv_pipeline_modulate1 (
            .clk            (clkin_divctrl),
            .enable         (assert_enable),
            .nreset         (resetn_sync),
            .data_in        (modulate_pipe1[l]),
            .data_out       (modulate_pipe1[l+1]));
        end
    endgenerate


localparam PIPELINE_DEPTH_MOD2 = PIPELINE_DEPTH+1;

  wire   modulate_pipe2[PIPELINE_DEPTH_MOD2:0];
  assign modulate_pipe2[0] = modulate_pipe1[PIPELINE_DEPTH_MOD1];

    generate
      genvar m;
      if (PIPELINE_DEPTH_MOD2 > 0)
        for (m=0; m<PIPELINE_DEPTH_MOD2; m=m+1)
        begin : reset_inital_cycle_pipeline_mod2
          clkrst_f1_clkdiv_pipeline_enable #(
            .COUNTER_WIDTH  (1)
          ) u_clkrst_f1_clkdiv_pipeline_modulate2 (
            .clk            (clkin_divctrl),
            .enable         (1'b1),
            .nreset         (resetn_sync),
            .data_in        (modulate_pipe2[m]),
            .data_out       (modulate_pipe2[m+1]));
        end
    endgenerate




  always @(posedge clkin_divctrl or negedge resetn_sync)
  begin : pgate_counter
    if (!resetn_sync)
    begin
      reset_cycle_complete <= 1'b0;
      gatecounter          <= 6'b100000;
      top_count            <= 5'b11111;
      idivratio_cur        <= 5'b11111;
      idivratio_cur_delay  <= 5'b11111;

    end
     else if (gatecounter == 6'b000010)
     begin
      top_count  <= divratio;
      gatecounter <= gatecounter - 6'b000001;
     end
    else if (gatecounter < 6'b000010)
    begin
      reset_cycle_complete <= 1'b1;

      idivratio_cur <= top_count;

      idivratio_cur_delay <= idivratio_cur_pipe[PIPELINE_DEPTH];

      case ({top_count})
        5'b00000 : gatecounter <= 6'b000010; 
        5'b00001 : gatecounter <= 6'b000010; 
        5'b00010 : gatecounter <= 6'b000011; 
        5'b00011 : gatecounter <= 6'b000100; 
        5'b00100 : gatecounter <= 6'b000101; 
        5'b00101 : gatecounter <= 6'b000110; 
        5'b00110 : gatecounter <= 6'b000111; 
        5'b00111 : gatecounter <= 6'b001000; 
        5'b01000 : gatecounter <= 6'b001001; 
        5'b01001 : gatecounter <= 6'b001010; 
        5'b01010 : gatecounter <= 6'b001011; 
        5'b01011 : gatecounter <= 6'b001100; 
        5'b01100 : gatecounter <= 6'b001101; 
        5'b01101 : gatecounter <= 6'b001110; 
        5'b01110 : gatecounter <= 6'b001111; 
        5'b01111 : gatecounter <= 6'b010000; 
        5'b10000 : gatecounter <= 6'b010001; 
        5'b10001 : gatecounter <= 6'b010010; 
        5'b10010 : gatecounter <= 6'b010011; 
        5'b10011 : gatecounter <= 6'b010100; 
        5'b10100 : gatecounter <= 6'b010101; 
        5'b10101 : gatecounter <= 6'b010110; 
        5'b10110 : gatecounter <= 6'b010111; 
        5'b10111 : gatecounter <= 6'b011000; 
        5'b11000 : gatecounter <= 6'b011001; 
        5'b11001 : gatecounter <= 6'b011010; 
        5'b11010 : gatecounter <= 6'b011011; 
        5'b11011 : gatecounter <= 6'b011100; 
        5'b11100 : gatecounter <= 6'b011101; 
        5'b11101 : gatecounter <= 6'b011110; 
        5'b11110 : gatecounter <= 6'b011111; 
        5'b11111 : gatecounter <= 6'b100000; 
        default : gatecounter <= 6'bxxxxxx; 
      endcase
    end
    else if ((gatecounter  != 6'b000000))
    begin
     gatecounter <= gatecounter - 6'b000001;
    end
  end



  always @(idivratio_cur_pipe[PIPELINE_DEPTH] or reset_cycle_complete_pipe[PIPELINE_DEPTH]) begin : p_pclkgatecomb
    if (reset_cycle_complete_pipe[PIPELINE_DEPTH] == 1'b0)
    begin
      gateclkcomb = 1'b0;
    end
    else
    begin
      case (idivratio_cur_pipe[PIPELINE_DEPTH])
        5'b00000: 
          begin
              gateclkcomb = 1'b1;
          end  
      default :  gateclkcomb  = 1'b0;      
      endcase
    end
  end 



generate
if (DISABLE_NEGEDGE_5050MARK == 0)
begin : enable_negedge_flops
  assign gatedclk_enable = gateclkcomb & modulate_pipe2[PIPELINE_DEPTH_MOD2];
end 
else
begin : disable_negedge_flops
  assign gatedclk_enable = (gateclkcomb | clockdivcomb_even) & modulate_pipe2[PIPELINE_DEPTH_MOD2];
end 
endgenerate

generate
if (DISABLE_COMBO_GATELOGIC == 1)
begin : disable_combo_clkgate
  always @(posedge clkin_divctrl or negedge resetn_sync)
  begin
    if (!resetn_sync)
    begin
      gatedclk_enable_reg <= 1'b0;
    end
    else
    begin
      gatedclk_enable_reg <= gatedclk_enable;
    end
  end

  clkrst_f1_clkgate u_div_clkgate(
    .clk_in                             (clkin),
    .enable                             (gatedclk_enable_reg),
    .clk_out                            (gatedclk),
    .dftcgen                            (dftdivbypass));

end 
else
begin : enable_combo_clkgate

  clkrst_f1_clkgate u_div_clkgate(
    .clk_in                             (clkin),
    .enable                             (gatedclk_enable),
    .clk_out                            (gatedclk),
    .dftcgen                            (dftdivbypass));

end 
endgenerate

    


generate
if (DISABLE_NEGEDGE_5050MARK == 0)
begin : negedge_clock_divider_comb

  always @(gatecounter_pipe[PIPELINE_DEPTH]    or
           idivratio_cur_pipe[PIPELINE_DEPTH]  or
           reset_cycle_complete_pipe[PIPELINE_DEPTH])
    begin : p_pulse_ext_comb
      if (reset_cycle_complete_pipe[PIPELINE_DEPTH] == 1'b0)
      begin
        clockdivcomb_even = 1'b0;
      end
      else
      begin
        case (idivratio_cur_pipe[PIPELINE_DEPTH])
          5'b00000:  
            begin
                clockdivcomb_even  = 1'b0;
            end

          5'b00001:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b000010 :  clockdivcomb_even  = 1'b1;
              default   :  clockdivcomb_even  = 1'b0;
              endcase
            end


          5'b00010:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b000011 :  clockdivcomb_even  = 1'b1;
              default   :  clockdivcomb_even  = 1'b0;
              endcase
            end


          5'b00011:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b000100,
              6'b000011 :  clockdivcomb_even  = 1'b1;
              default   :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b00100:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b000101,
              6'b000100 :  clockdivcomb_even  = 1'b1;
              default   :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b00101:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b000110,
              6'b000101,
              6'b000100 :  clockdivcomb_even  = 1'b1;
              default   :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b00110:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b000111,
              6'b000110,
              6'b000101 :  clockdivcomb_even  = 1'b1;
              default   :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b00111:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001000,
              6'b000111,
              6'b000110,
              6'b000101 :  clockdivcomb_even  = 1'b1;
              default   :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b01000:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001001,
              6'b001000,
              6'b000111,
              6'b000110  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b01001:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001010,
              6'b001001,
              6'b001000,
              6'b000111,
              6'b000110  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b01010:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001011,
              6'b001010,
              6'b001001,
              6'b001000,
              6'b000111  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b01011:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001100,
              6'b001011,
              6'b001010,
              6'b001001,
              6'b001000,
              6'b000111  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b01100:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001101,
              6'b001100,
              6'b001011,
              6'b001010,
              6'b001001,
              6'b001000  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b01101:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001110,
              6'b001101,
              6'b001100,
              6'b001011,
              6'b001010,
              6'b001001,
              6'b001000  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b01110:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001111,
              6'b001110,
              6'b001101,
              6'b001100,
              6'b001011,
              6'b001010,
              6'b001001  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b01111:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b010000,
              6'b001111,
              6'b001110,
              6'b001101,
              6'b001100,
              6'b001011,
              6'b001010,
              6'b001001  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b10000:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b010001,
              6'b010000,
              6'b001111,
              6'b001110,
              6'b001101,
              6'b001100,
              6'b001011,
              6'b001010 :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b10001:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b010010,
              6'b010001,
              6'b010000,
              6'b001111,
              6'b001110,
              6'b001101,
              6'b001100,
              6'b001011,
              6'b001010:  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b10010:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b010011,
              6'b010010,
              6'b010001,
              6'b010000,
              6'b001111,
              6'b001110,
              6'b001101,
              6'b001100,
              6'b001011 :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b10011:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b010100,
              6'b010011,
              6'b010010,
              6'b010001,
              6'b010000,
              6'b001111,
              6'b001110,
              6'b001101,
              6'b001100,
              6'b001011  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b10100:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b010101,
              6'b010100,
              6'b010011,
              6'b010010,
              6'b010001,
              6'b010000,
              6'b001111,
              6'b001110,
              6'b001101,
              6'b001100:  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b10101:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b010110,
              6'b010101,
              6'b010100,
              6'b010011,
              6'b010010,
              6'b010001,
              6'b010000,
              6'b001111,
              6'b001110,
              6'b001101,
              6'b001100  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b10110:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b010111,
              6'b010110,
              6'b010101,
              6'b010100,
              6'b010011,
              6'b010010,
              6'b010001,
              6'b010000,
              6'b001111,
              6'b001110,
              6'b001101  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b10111:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b011000,
              6'b010111,
              6'b010110,
              6'b010101,
              6'b010100,
              6'b010011,
              6'b010010,
              6'b010001,
              6'b010000,
              6'b001111,
              6'b001110,
              6'b001101  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b11000:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b011001,
              6'b011000,
              6'b010111,
              6'b010110,
              6'b010101,
              6'b010100,
              6'b010011,
              6'b010010,
              6'b010001,
              6'b010000,
              6'b001111,
              6'b001110  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end


          5'b11001:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b011010,
              6'b011001,
              6'b011000,
              6'b010111,
              6'b010110,
              6'b010101,
              6'b010100,
              6'b010011,
              6'b010010,
              6'b010001,
              6'b010000,
              6'b001111,
              6'b001110  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end


          5'b11010:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b011011,
              6'b011010,
              6'b011001,
              6'b011000,
              6'b010111,
              6'b010110,
              6'b010101,
              6'b010100,
              6'b010011,
              6'b010010,
              6'b010001,
              6'b010000,
              6'b001111  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end


          5'b11011:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b011100,
              6'b011011,
              6'b011010,
              6'b011001,
              6'b011000,
              6'b010111,
              6'b010110,
              6'b010101,
              6'b010100,
              6'b010011,
              6'b010010,
              6'b010001,
              6'b010000,
              6'b001111  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end


          5'b11100:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b011101,
              6'b011100,
              6'b011011,
              6'b011010,
              6'b011001,
              6'b011000,
              6'b010111,
              6'b010110,
              6'b010101,
              6'b010100,
              6'b010011,
              6'b010010,
              6'b010001,
              6'b010000  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b11101:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b011110,
              6'b011101,
              6'b011100,
              6'b011011,
              6'b011010,
              6'b011001,
              6'b011000,
              6'b010111,
              6'b010110,
              6'b010101,
              6'b010100,
              6'b010011,
              6'b010010,
              6'b010001,
              6'b010000  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b11110:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b011111,
              6'b011110,
              6'b011101,
              6'b011100,
              6'b011011,
              6'b011010,
              6'b011001,
              6'b011000,
              6'b010111,
              6'b010110,
              6'b010101,
              6'b010100,
              6'b010011,
              6'b010010,
              6'b010001 :  clockdivcomb_even  = 1'b1;
              default   :  clockdivcomb_even  = 1'b0;
              endcase
            end


          5'b11111:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b100000,
              6'b011111,
              6'b011110,
              6'b011101,
              6'b011100,
              6'b011011,
              6'b011010,
              6'b011001,
              6'b011000,
              6'b010111,
              6'b010110,
              6'b010101,
              6'b010100,
              6'b010011,
              6'b010010,
              6'b010001 :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end
          default :  clockdivcomb_even  = 1'b0;
        endcase
      end
    end
end 
else
begin : posedge_clock_divider_comb

  always @(gatecounter_pipe[PIPELINE_DEPTH]    or
           idivratio_cur_pipe[PIPELINE_DEPTH]  or
           reset_cycle_complete_pipe[PIPELINE_DEPTH])
    begin : p_pulse_ext_comb
      if (reset_cycle_complete_pipe[PIPELINE_DEPTH] == 1'b0)
      begin
        clockdivcomb_even = 1'b0;
      end
      else
      begin
        case (idivratio_cur_pipe[PIPELINE_DEPTH])
          5'b00000:  
            begin
                clockdivcomb_even  = 1'b0;
            end

          5'b00001:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b000010 :  clockdivcomb_even  = 1'b1;
              default   :  clockdivcomb_even  = 1'b0;
              endcase
            end


          5'b00010:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b000011 :  clockdivcomb_even  = 1'b1;
              default   :  clockdivcomb_even  = 1'b0;
              endcase
            end


          5'b00011:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b000100 :  clockdivcomb_even  = 1'b1;
              default   :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b00100:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b000101 :  clockdivcomb_even  = 1'b1;
              default   :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b00101:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b000110 :  clockdivcomb_even  = 1'b1;
              default   :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b00110:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b000111 :  clockdivcomb_even  = 1'b1;
              default   :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b00111:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001000 :  clockdivcomb_even  = 1'b1;
              default   :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b01000:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001001  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b01001:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001010  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b01010:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001011  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b01011:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001100  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b01100:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001101  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b01101:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001110  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b01110:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001111  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b01111:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b010000  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b10000:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b010001 :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b10001:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b010010  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b10010:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b010011  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b10011:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b010100  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b10100:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b010101  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b10101:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b010110  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b10110:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b010111  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b10111:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b011000  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b11000:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b011001  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end


          5'b11001:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b011010  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end


          5'b11010:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b011011  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end


          5'b11011:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b011100  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end


          5'b11100:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b011101  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b11101:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b011110  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end

          5'b11110:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b011111 :  clockdivcomb_even  = 1'b1;
              default   :  clockdivcomb_even  = 1'b0;
              endcase
            end


          5'b11111:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b100000  :  clockdivcomb_even  = 1'b1;
              default    :  clockdivcomb_even  = 1'b0;
              endcase
            end
          default :  clockdivcomb_even  = 1'b0;
        endcase
      end
    end
end 
endgenerate


generate
if (DISABLE_NEGEDGE_5050MARK == 0)
begin : clockpath_logic

  always @(posedge clkin or negedge resetn_sync)
    begin : p_pulse_ext
      if (!resetn_sync)
          clockdiv_even    = 1'b0;
      else
          clockdiv_even    = clockdivcomb_even & modulate_pipe2[PIPELINE_DEPTH_MOD2-1];
    end




  always @(gatecounter_pipe[PIPELINE_DEPTH]   or
           idivratio_cur_pipe[PIPELINE_DEPTH] or
           reset_cycle_complete_pipe[PIPELINE_DEPTH])
    begin : p_pulse_ext_comb_odd
      if (reset_cycle_complete_pipe[PIPELINE_DEPTH] == 1'b0)
      begin
        clockdivcomb_odd = 1'b0;
      end
      else
      begin
        case (idivratio_cur_pipe[PIPELINE_DEPTH])
          5'b00010:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b000011 :  clockdivcomb_odd  = 1'b1;
              default   :  clockdivcomb_odd  = 1'b0;
              endcase
            end

          5'b00100:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b000100  :  clockdivcomb_odd  = 1'b1;
              default   :  clockdivcomb_odd  = 1'b0;
              endcase
            end

          5'b00110:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b000101  :  clockdivcomb_odd  = 1'b1;
              default   :  clockdivcomb_odd  = 1'b0;
              endcase
            end

          5'b01000:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b000110 :  clockdivcomb_odd  = 1'b1;
              default   :  clockdivcomb_odd  = 1'b0;
              endcase
            end

          5'b01010:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b000111 :  clockdivcomb_odd  = 1'b1;
              default   :  clockdivcomb_odd  = 1'b0;
              endcase
            end

          5'b01100:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001000 :  clockdivcomb_odd  = 1'b1;
              default   :  clockdivcomb_odd  = 1'b0;
              endcase
            end

          5'b01110:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001001 :  clockdivcomb_odd  = 1'b1;
              default   :  clockdivcomb_odd  = 1'b0;
              endcase
            end

          5'b10000:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001010 :  clockdivcomb_odd  = 1'b1;
              default   :  clockdivcomb_odd  = 1'b0;
              endcase
            end

          5'b10010:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001011 :  clockdivcomb_odd  = 1'b1;
              default   :  clockdivcomb_odd  = 1'b0;
              endcase
            end

          5'b10100:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001100 :  clockdivcomb_odd  = 1'b1;
              default   :  clockdivcomb_odd  = 1'b0;
              endcase
            end


          5'b10110:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001101 :  clockdivcomb_odd  = 1'b1;
              default   :  clockdivcomb_odd  = 1'b0;
              endcase
            end

          5'b11000:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001110 :  clockdivcomb_odd  = 1'b1;
              default   :  clockdivcomb_odd  = 1'b0;
              endcase
            end

          5'b11010:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b001111 :  clockdivcomb_odd  = 1'b1;
              default   :  clockdivcomb_odd  = 1'b0;
              endcase
            end

          5'b11100:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b010000 :  clockdivcomb_odd  = 1'b1;
              default   :  clockdivcomb_odd  = 1'b0;
              endcase
            end

          5'b11110:  
            begin
              case (gatecounter_pipe[PIPELINE_DEPTH])
              6'b010001 :  clockdivcomb_odd  = 1'b1;
              default   :  clockdivcomb_odd  = 1'b0;
              endcase
            end


          default :  clockdivcomb_odd  = 1'b0;
        endcase
      end
    end

  always @(posedge clkin or negedge resetn_sync)
    begin
      if (!resetn_sync)
          clockdiv_odd    <= 1'b0;
      else
          clockdiv_odd    <= clockdivcomb_odd & modulate_pipe2[PIPELINE_DEPTH_MOD2-1];
    end


   always @(posedge clkin_n or negedge resetn_sync_n)
     begin
       if (!resetn_sync_n)
           clockdiv_odd_neg    = 1'b0;
       else
           clockdiv_odd_neg    = clockdiv_odd;
     end



  clkrst_f1_clkinv u_clkrst_f1_clkinv_dftdivbypass (
    .clk_in                             (dftdivbypass),                                
    .clk_out                            (dftdivbypass_inverted)
  );

  clkrst_f1_clkor2 u_clkrst_f1_clkor2_clockdiv_even(
    .clk0_in                            (clockdiv_even),
    .clk1_in                            (clockdiv_odd_neg),
    .clk_out                            (iclockdiv_full)
  );
    
  clkrst_f1_clkand2 u_clkrst_f1_clkand2_clockdiv_full(
    .clk0_in                            (iclockdiv_full),
    .clk1_in                            (dftdivbypass_inverted),
    .clk_out                            (clockdiv_full)
  );


  clkrst_f1_clkor2 u_clkrst_f1_clkor2(
    .clk0_in                            (gatedclk),
    .clk1_in                            (clockdiv_full),
    .clk_out                            (idivclk)
    
  );

  
  assign divclk       = idivclk;

end 
else
begin : disable_clockpath_logic
  assign divclk       = gatedclk;
end 
endgenerate





  assign divratio_cur = idivratio_cur_delay;


  always @(top_count or gatecounter)
  begin
    assert_enable = 1'b0;
    case (top_count)
      5'b00000:assert_enable = 1'b1;
      default:
      begin
            case (gatecounter)
            6'b000010: assert_enable = 1'b1;
            default: assert_enable = 1'b0;
            endcase
       end
    endcase
  end

generate
if (DISABLE_COMBO_GATELOGIC == 1)
begin : disable_combo_clkgate_hintclk
  always @(posedge clkin_divctrl or negedge resetn_sync)
  begin
    if (!resetn_sync)
    begin
      gatedclk_enable_hintclk_reg <= 1'b0;
    end
    else
    begin
      gatedclk_enable_hintclk_reg <= (assert_enable & modulate);
    end
  end

  clkrst_f1_clkgate u_hintclk_clkgate(
    .clk_in                             (clkin),
    .enable                             (gatedclk_enable_hintclk_reg),
    .clk_out                            (hintclken_clk),
    .dftcgen                            (dftcgen));
    

end 
else
begin : enable_combo_clkgate_hintclk

  clkrst_f1_clkgate u_hintclk_clkgate(
    .clk_in                             (clkin),
    .enable                             (assert_enable & modulate),
    .clk_out                            (hintclken_clk),
    .dftcgen                            (dftcgen));

end 
endgenerate

  
endmodule
 

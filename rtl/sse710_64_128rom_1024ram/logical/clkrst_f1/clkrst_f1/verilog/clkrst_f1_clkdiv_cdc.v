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

module clkrst_f1_clkdiv_cdc
  #(parameter
      CLKRST_ASYNC_SIGNAL_WIDTH = 5,
      ASYNC_SIGNAL_SKEWDEPTH    = 4,
      RESET_VALUE               = 1
 )
  (
  input   wire                          clkin,         
  input   wire                          resetn_sync,    

  input   wire  [CLKRST_ASYNC_SIGNAL_WIDTH-1:0]                   asyncbus,        
  input   wire  [CLKRST_ASYNC_SIGNAL_WIDTH-1:0]                   current_setting,        
  output  reg   [CLKRST_ASYNC_SIGNAL_WIDTH-1:0]                   asyncbus_stable

);

  function integer clog2(input integer num_to_log);
  begin:f_clog2
    for(clog2=0; (1<<clog2)<num_to_log; clog2=clog2+1)
    begin
    end
  end 
  endfunction


  localparam ASYNC_SIGNAL_COUNT_WIDTH = clog2(ASYNC_SIGNAL_SKEWDEPTH+1);
  localparam RESET_OUTPUT  = (RESET_VALUE==1) ? {CLKRST_ASYNC_SIGNAL_WIDTH{1'b1}} : {{CLKRST_ASYNC_SIGNAL_WIDTH-1{1'b0}},1'b1};

  wire [CLKRST_ASYNC_SIGNAL_WIDTH-1:0]                            asyncbus_sync;      

  reg                                                             new_setting;        
  reg  [ASYNC_SIGNAL_COUNT_WIDTH-1:0]                             wait_counter;       


  reg                                                             asyncbusload_enable;


generate
if (RESET_VALUE==1)
begin : async_synchronisers_set1
      genvar j;
        for (j=0; j<CLKRST_ASYNC_SIGNAL_WIDTH; j=j+1)
        begin : async_sync_flops
          clkrst_f1_cdc_capt_sync_set u_clkrst_f1_cdc_capt_sync_set (
            .clk            (clkin),
            .nset           (resetn_sync),
            .d_async        (asyncbus[j]),
            .q              (asyncbus_sync[j]));
        end
end
else
begin : async_synchronisers_topvalue
      genvar i;
        for (i=0; i<CLKRST_ASYNC_SIGNAL_WIDTH; i=i+1)
        begin : async_sync_flops
        if (i == 0)
          begin
          clkrst_f1_cdc_capt_sync_set u_clkrst_f1_cdc_capt_sync_set (
            .clk            (clkin),
            .nset           (resetn_sync),
            .d_async        (asyncbus[i]),
            .q              (asyncbus_sync[i]));
          end
          else
          begin
          clkrst_f1_cdc_capt_sync u_clkrst_f1_cdc_capt_sync (
            .clk            (clkin),
            .nreset         (resetn_sync),
            .d_async        (asyncbus[i]),
            .q              (asyncbus_sync[i]));
          end
        end
end
endgenerate

  always @(posedge clkin or negedge resetn_sync)
  begin
    if (!resetn_sync)
    begin   
      new_setting <= 1'b0;
    end
    else
    begin
      if (asyncbus_sync != current_setting)
        new_setting <= 1'b1;
      else
        new_setting <= 1'b0;
    end        
  end



  always @(posedge clkin or negedge resetn_sync)
  begin
    if (!resetn_sync)
     begin
        wait_counter <= ASYNC_SIGNAL_SKEWDEPTH;
     end
     else if ((wait_counter != 0) & new_setting)
     begin
      wait_counter <= wait_counter - {{ASYNC_SIGNAL_COUNT_WIDTH-1{1'b0}},1'b1};
     end
     else
     begin
      if (new_setting == 1'b0)
      begin
        wait_counter <= ASYNC_SIGNAL_SKEWDEPTH;
       end
     end
  end





  always @(*)
  begin
    if (wait_counter == {CLKRST_ASYNC_SIGNAL_WIDTH{1'b0}})
      asyncbusload_enable = 1'b1;
    else
      asyncbusload_enable = 1'b0;      
  end


  always @(posedge clkin or negedge resetn_sync)
  begin : stable_cdc
    if (!resetn_sync)
    begin   
      asyncbus_stable <= RESET_OUTPUT;
    end
    else
    begin
      if (asyncbusload_enable)
        asyncbus_stable <= asyncbus_sync;        
    end
  end
  
endmodule
 

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


module clkselNway_f0_3 (
  input   wire                          clk0, 
  input   wire                          clk1, 
  input   wire                          clk2, 
  

  input   wire  [2:0]                   clksel,              
  output  wire  [2:0]                   select_cur,          
  input   wire  [2:0]                   dftclksel,           


  input   wire                          resetn,              

  input   wire                          dftclkselen,         
  input   wire                          dftrstdisable,       

  output  wire                          selected_clk         
 
);

  reg            clk0state;         
  reg            clk0nextstate;     
  reg            iclk0off_delay;
  reg            nclk0off;          
  reg    [2:0]   clk0selsync_valid;
  wire   [2:0]   clk0selsync;       
  wire           iclk0off;          
  wire           clk0off;           
  wire           clk0off_delay;
  wire           iclk0;             
  wire           resetn_sync_clk0;
  reg            clk1state;         
  reg            clk1nextstate;     
  reg            iclk1off_delay;
  reg            nclk1off;          
  reg    [2:0]   clk1selsync_valid;
  wire   [2:0]   clk1selsync;       
  wire           iclk1off;          
  wire           clk1off;           
  wire           clk1off_delay;
  wire           iclk1;             
  wire           resetn_sync_clk1;
  reg            clk2state;         
  reg            clk2nextstate;     
  reg            iclk2off_delay;
  reg            nclk2off;          
  reg    [2:0]   clk2selsync_valid;
  wire   [2:0]   clk2selsync;       
  wire           iclk2off;          
  wire           clk2off;           
  wire           clk2off_delay;
  wire           iclk2;             
  wire           resetn_sync_clk2;
  
  wire           clk0offclk1sync;   
  wire           clk0offclk2sync;   
  
  wire           clk1offclk0sync;   
  wire           clk1offclk2sync;   
  
  wire           clk2offclk0sync;   
  wire           clk2offclk1sync;   
  
  


  wire           selected_clk_0;
  
  wire [2:0]     iselect_cur;


  localparam CLK0_ON      =     1'b0;    
  localparam CLK0_OFF     =     1'b1;
  localparam CLK1_ON      =     1'b0;    
  localparam CLK1_OFF     =     1'b1;
  localparam CLK2_ON      =     1'b0;    
  localparam CLK2_OFF     =     1'b1;








  clkselNway_f0_rstsync_3 u_clkselNway_f0_rstsync_clk0(
    .clk                                (clk0),             
    .resetn_async                       (resetn),           
    .resetn_sync                        (resetn_sync_clk0), 

    .dftrstdisable                      (dftrstdisable)     
  );









  clkselNway_f0_cdc_capt_sync_3 u_clkselNway_f0_cdc_capt_sync_select0clk0(
    .clk            (clk0),
    .nreset         (resetn_sync_clk0),
    .d_async        (clksel[0]),
    .q              (clk0selsync[0]));

  clkselNway_f0_cdc_capt_sync_3 u_clkselNway_f0_cdc_capt_sync_select1clk0(
    .clk            (clk0),
    .nreset         (resetn_sync_clk0),
    .d_async        (clksel[1]),
    .q              (clk0selsync[1]));

  clkselNway_f0_cdc_capt_sync_3 u_clkselNway_f0_cdc_capt_sync_select2clk0(
    .clk            (clk0),
    .nreset         (resetn_sync_clk0),
    .d_async        (clksel[2]),
    .q              (clk0selsync[2]));





  always @(clk0selsync)
  begin
    case ({clk0selsync})
    3'd1: clk0selsync_valid = clk0selsync;
    3'd2: clk0selsync_valid = clk0selsync;
    3'd4: clk0selsync_valid = clk0selsync;
    default: clk0selsync_valid = 3'd0;
    endcase
  end

  clkselNway_f0_cdc_capt_sync_3 u_clkselNway_f0_cdc_capt_sync_clk1Offclk0(
    .clk            (clk0),
    .nreset         (resetn_sync_clk0),
    .d_async        (clk1off_delay),
    .q              (clk1offclk0sync));

  clkselNway_f0_cdc_capt_sync_3 u_clkselNway_f0_cdc_capt_sync_clk2Offclk0(
    .clk            (clk0),
    .nreset         (resetn_sync_clk0),
    .d_async        (clk2off_delay),
    .q              (clk2offclk0sync));



  always @(posedge clk0 or negedge resetn_sync_clk0)
  begin
    if (!resetn_sync_clk0)
      clk0state <=  CLK0_OFF;
    else
      clk0state <=  clk0nextstate;
  end

  always @(clk0selsync_valid     or
           clk1offclk0sync or
           clk2offclk0sync or
           clk0state)
  begin

    clk0nextstate = clk0state; 
 
    case (clk0state)
      CLK0_OFF:
          if (
              (clk1offclk0sync  == 1'b1)  &&
              (clk2offclk0sync  == 1'b1)  &&
              (clk0selsync_valid== 3'd1))


            clk0nextstate = CLK0_ON;    
      CLK0_ON:
          if (clk0selsync_valid  != 3'd1)
            clk0nextstate = CLK0_OFF;   
    endcase
  end

  assign iclk0off = (clk0state == CLK0_ON) ? 1'b0 : 1'b1;



  always @(posedge clk0 or negedge resetn_sync_clk0)
  begin
    if (!resetn_sync_clk0)
      iclk0off_delay <=  1'b1;
    else
      iclk0off_delay <=  iclk0off;
  end



  clkselNway_f0_rstsync_3 u_clkselNway_f0_rstsync_clk1(
    .clk                                (clk1),             
    .resetn_async                       (resetn),           
    .resetn_sync                        (resetn_sync_clk1), 

    .dftrstdisable                      (dftrstdisable)     
  );









  clkselNway_f0_cdc_capt_sync_3 u_clkselNway_f0_cdc_capt_sync_select0clk1(
    .clk            (clk1),
    .nreset         (resetn_sync_clk1),
    .d_async        (clksel[0]),
    .q              (clk1selsync[0]));

  clkselNway_f0_cdc_capt_sync_3 u_clkselNway_f0_cdc_capt_sync_select1clk1(
    .clk            (clk1),
    .nreset         (resetn_sync_clk1),
    .d_async        (clksel[1]),
    .q              (clk1selsync[1]));

  clkselNway_f0_cdc_capt_sync_3 u_clkselNway_f0_cdc_capt_sync_select2clk1(
    .clk            (clk1),
    .nreset         (resetn_sync_clk1),
    .d_async        (clksel[2]),
    .q              (clk1selsync[2]));





  always @(clk1selsync)
  begin
    case ({clk1selsync})
    3'd1: clk1selsync_valid = clk1selsync;
    3'd2: clk1selsync_valid = clk1selsync;
    3'd4: clk1selsync_valid = clk1selsync;
    default: clk1selsync_valid = 3'd0;
    endcase
  end

  clkselNway_f0_cdc_capt_sync_3 u_clkselNway_f0_cdc_capt_sync_clk0Offclk1(
    .clk            (clk1),
    .nreset         (resetn_sync_clk1),
    .d_async        (clk0off_delay),
    .q              (clk0offclk1sync));

  clkselNway_f0_cdc_capt_sync_3 u_clkselNway_f0_cdc_capt_sync_clk2Offclk1(
    .clk            (clk1),
    .nreset         (resetn_sync_clk1),
    .d_async        (clk2off_delay),
    .q              (clk2offclk1sync));



  always @(posedge clk1 or negedge resetn_sync_clk1)
  begin
    if (!resetn_sync_clk1)
      clk1state <=  CLK1_OFF;
    else
      clk1state <=  clk1nextstate;
  end

  always @(clk1selsync_valid     or
           clk0offclk1sync or
           clk2offclk1sync or
           clk1state)
  begin

    clk1nextstate = clk1state; 
 
    case (clk1state)
      CLK1_OFF:
          if (
              (clk0offclk1sync  == 1'b1)  &&
              (clk2offclk1sync  == 1'b1)  &&
              (clk1selsync_valid== 3'd2))


            clk1nextstate = CLK1_ON;    
      CLK1_ON:
          if (clk1selsync_valid  != 3'd2)
            clk1nextstate = CLK1_OFF;   
    endcase
  end

  assign iclk1off = (clk1state == CLK1_ON) ? 1'b0 : 1'b1;



  always @(posedge clk1 or negedge resetn_sync_clk1)
  begin
    if (!resetn_sync_clk1)
      iclk1off_delay <=  1'b1;
    else
      iclk1off_delay <=  iclk1off;
  end



  clkselNway_f0_rstsync_3 u_clkselNway_f0_rstsync_clk2(
    .clk                                (clk2),             
    .resetn_async                       (resetn),           
    .resetn_sync                        (resetn_sync_clk2), 

    .dftrstdisable                      (dftrstdisable)     
  );









  clkselNway_f0_cdc_capt_sync_3 u_clkselNway_f0_cdc_capt_sync_select0clk2(
    .clk            (clk2),
    .nreset         (resetn_sync_clk2),
    .d_async        (clksel[0]),
    .q              (clk2selsync[0]));

  clkselNway_f0_cdc_capt_sync_3 u_clkselNway_f0_cdc_capt_sync_select1clk2(
    .clk            (clk2),
    .nreset         (resetn_sync_clk2),
    .d_async        (clksel[1]),
    .q              (clk2selsync[1]));

  clkselNway_f0_cdc_capt_sync_3 u_clkselNway_f0_cdc_capt_sync_select2clk2(
    .clk            (clk2),
    .nreset         (resetn_sync_clk2),
    .d_async        (clksel[2]),
    .q              (clk2selsync[2]));





  always @(clk2selsync)
  begin
    case ({clk2selsync})
    3'd1: clk2selsync_valid = clk2selsync;
    3'd2: clk2selsync_valid = clk2selsync;
    3'd4: clk2selsync_valid = clk2selsync;
    default: clk2selsync_valid = 3'd0;
    endcase
  end

  clkselNway_f0_cdc_capt_sync_3 u_clkselNway_f0_cdc_capt_sync_clk0Offclk2(
    .clk            (clk2),
    .nreset         (resetn_sync_clk2),
    .d_async        (clk0off_delay),
    .q              (clk0offclk2sync));

  clkselNway_f0_cdc_capt_sync_3 u_clkselNway_f0_cdc_capt_sync_clk1Offclk2(
    .clk            (clk2),
    .nreset         (resetn_sync_clk2),
    .d_async        (clk1off_delay),
    .q              (clk1offclk2sync));



  always @(posedge clk2 or negedge resetn_sync_clk2)
  begin
    if (!resetn_sync_clk2)
      clk2state <=  CLK2_OFF;
    else
      clk2state <=  clk2nextstate;
  end

  always @(clk2selsync_valid     or
           clk0offclk2sync or
           clk1offclk2sync or
           clk2state)
  begin

    clk2nextstate = clk2state; 
 
    case (clk2state)
      CLK2_OFF:
          if (
              (clk0offclk2sync  == 1'b1)  &&
              (clk1offclk2sync  == 1'b1)  &&
              (clk2selsync_valid== 3'd4))


            clk2nextstate = CLK2_ON;    
      CLK2_ON:
          if (clk2selsync_valid  != 3'd4)
            clk2nextstate = CLK2_OFF;   
    endcase
  end

  assign iclk2off = (clk2state == CLK2_ON) ? 1'b0 : 1'b1;



  always @(posedge clk2 or negedge resetn_sync_clk2)
  begin
    if (!resetn_sync_clk2)
      iclk2off_delay <=  1'b1;
    else
      iclk2off_delay <=  iclk2off;
  end





  assign clk0off       =  iclk0off;
  assign clk0off_delay =  iclk0off_delay;


  assign clk1off       =  iclk1off;
  assign clk1off_delay =  iclk1off_delay;


  assign clk2off       =  iclk2off;
  assign clk2off_delay =  iclk2off_delay;





  always @(dftclksel   or
           clk0off     or
           clk1off     or
           clk2off     or
           dftclkselen)
  begin
    if (dftclkselen)
    begin
      {nclk2off,nclk1off,nclk0off} = dftclksel;
    end
    else
    begin
      nclk0off = ~clk0off;
      nclk1off = ~clk1off;
      nclk2off = ~clk2off;
    end
  end




    clkselNway_f0_clkgate_3 u_clkselNway_f0_clkgate_clk_0(
      .clk_in                           (clk0),
      .enable                           (nclk0off),
      .clk_out                          (iclk0),
      .dftcgen                          (1'b0)
 
    );
    clkselNway_f0_clkgate_3 u_clkselNway_f0_clkgate_clk_1(
      .clk_in                           (clk1),
      .enable                           (nclk1off),
      .clk_out                          (iclk1),
      .dftcgen                          (1'b0)
 
    );
    clkselNway_f0_clkgate_3 u_clkselNway_f0_clkgate_clk_2(
      .clk_in                           (clk2),
      .enable                           (nclk2off),
      .clk_out                          (iclk2),
      .dftcgen                          (1'b0)
 
    );

 
    clkselNway_f0_clkor2_3 u_clkoutor_3(
      .clk0_in                          (iclk0),
      .clk1_in                          (iclk1),
      .clk_out                          (selected_clk_0)
     );


    clkselNway_f0_clkor2_3 u_clkoutor_1(
      .clk0_in                          (selected_clk_0),
      .clk1_in                          (iclk2),
      .clk_out                          (selected_clk)
 
    );

  assign iselect_cur  = {
                         ~iclk2off_delay ,
                         ~iclk1off_delay ,
                         ~iclk0off_delay
                         };



  assign select_cur = iselect_cur;
  

endmodule

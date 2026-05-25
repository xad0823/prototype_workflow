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

module nic400_ib_ib4_downsize_wr_resp_block_sse710_main
  (
  bvalid_m,
  bready_s,
  bresp_m,
  buser_m,
  bid_m,

  bchannel_ready,

  bchannel_valid,
  bchannel_data,

  bvalid_s,
  bready_m,
  buser_s,
  bid_s,
  bresp_s,

  aclk,
  aresetn
  );

`include "nic400_ib_ib4_defs_sse710_main.v"

  input                   aclk;
  input                   aresetn;

  output                  bchannel_ready;   

  output                  bvalid_s;          
  output                  bready_m;          
  output [11:0]           bid_s;             
  output                  buser_s;           
  output [1:0]            bresp_s;           

  input                   bvalid_m;
  input                   bready_s;
  input                   buser_m;
  input [11:0]            bid_m;
  input [1:0]             bresp_m;

  input                   bchannel_valid;
  input [15:0]            bchannel_data;


   wire [17:0]            match_bus;
   wire [17:0]            hazard_bus;

   wire [17:0]            valid_bus;
   wire                   match;              
   wire                   hazard;             

   wire                   bready_m_i;
   wire                   bhndshk;

   wire                   push_slice;
   wire                   pop_slice;          
   wire                   update;
   

   wire [11:0]            awid;
   wire [3:0]             n_response;
   wire                   next_bchannel_ready;
   
   wire [1:0]             bresp_out_0;
   wire [1:0]             bresp_out_1;
   wire [1:0]             bresp_out_2;
   wire [1:0]             bresp_out_3;
   wire [1:0]             bresp_out_4;
   wire [1:0]             bresp_out_5;
   wire [1:0]             bresp_out_6;
   wire [1:0]             bresp_out_7;
   wire [1:0]             bresp_out_8;
   wire [1:0]             bresp_out_9;
   wire [1:0]             bresp_out_10;
   wire [1:0]             bresp_out_11;
   wire [1:0]             bresp_out_12;
   wire [1:0]             bresp_out_13;
   wire [1:0]             bresp_out_14;
   wire [1:0]             bresp_out_15;
   wire [1:0]             bresp_out_16;
   wire [1:0]             bresp_out_17;
    

   reg [4:0]              hazard_pointer;
   reg [4:0]              match_pointer;

   reg [17:0]             store;

   reg                    bchannel_ready_i;  


   assign awid = bchannel_data[15:4];
   assign n_response = bchannel_data[3:0];

   assign match = |match_bus;

   assign hazard = |hazard_bus;

   assign next_bchannel_ready = ~(&(valid_bus | (store & {18{push_slice}}))) || (pop_slice);

   always @(posedge aclk or negedge aresetn)
    begin : bchannel_seq
      if (!aresetn)
         bchannel_ready_i <= 1'b0;
      else
         bchannel_ready_i <= next_bchannel_ready;
    end 

   assign bchannel_ready = bchannel_ready_i;
   always @(valid_bus or match_bus)
     begin : store_decode
        if (!valid_bus[0])
           store = 18'b000000000000000001;
         else if (!valid_bus[1])
            store = 18'b000000000000000010;
         else if (!valid_bus[2])
            store = 18'b000000000000000100;
         else if (!valid_bus[3])
            store = 18'b000000000000001000;
         else if (!valid_bus[4])
            store = 18'b000000000000010000;
         else if (!valid_bus[5])
            store = 18'b000000000000100000;
         else if (!valid_bus[6])
            store = 18'b000000000001000000;
         else if (!valid_bus[7])
            store = 18'b000000000010000000;
         else if (!valid_bus[8])
            store = 18'b000000000100000000;
         else if (!valid_bus[9])
            store = 18'b000000001000000000;
         else if (!valid_bus[10])
            store = 18'b000000010000000000;
         else if (!valid_bus[11])
            store = 18'b000000100000000000;
         else if (!valid_bus[12])
            store = 18'b000001000000000000;
         else if (!valid_bus[13])
            store = 18'b000010000000000000;
         else if (!valid_bus[14])
            store = 18'b000100000000000000;
         else if (!valid_bus[15])
            store = 18'b001000000000000000;
         else if (!valid_bus[16])
            store = 18'b010000000000000000;
         else if (!valid_bus[17])
            store = 18'b100000000000000000;
        else
            store = match_bus;
      end 

   always @(hazard_bus)
     begin : hazard_num_distibution
       case (hazard_bus)
          18'b0 : hazard_pointer = 5'b0;
           18'd1 : hazard_pointer = 5'd0;
          18'd2 : hazard_pointer = 5'd1;
          18'd4 : hazard_pointer = 5'd2;
          18'd8 : hazard_pointer = 5'd3;
          18'd16 : hazard_pointer = 5'd4;
          18'd32 : hazard_pointer = 5'd5;
          18'd64 : hazard_pointer = 5'd6;
          18'd128 : hazard_pointer = 5'd7;
          18'd256 : hazard_pointer = 5'd8;
          18'd512 : hazard_pointer = 5'd9;
          18'd1024 : hazard_pointer = 5'd10;
          18'd2048 : hazard_pointer = 5'd11;
          18'd4096 : hazard_pointer = 5'd12;
          18'd8192 : hazard_pointer = 5'd13;
          18'd16384 : hazard_pointer = 5'd14;
          18'd32768 : hazard_pointer = 5'd15;
          18'd65536 : hazard_pointer = 5'd16;
          18'd131072 : hazard_pointer = 5'd17;
         default : hazard_pointer = 5'bx;
       endcase
     end

   always @(match_bus)
     begin : match_num_distibution
       case (match_bus)
          18'b0 : match_pointer = 5'b0;
           18'd1 : match_pointer = 5'd0;
          18'd2 : match_pointer = 5'd1;
          18'd4 : match_pointer = 5'd2;
          18'd8 : match_pointer = 5'd3;
          18'd16 : match_pointer = 5'd4;
          18'd32 : match_pointer = 5'd5;
          18'd64 : match_pointer = 5'd6;
          18'd128 : match_pointer = 5'd7;
          18'd256 : match_pointer = 5'd8;
          18'd512 : match_pointer = 5'd9;
          18'd1024 : match_pointer = 5'd10;
          18'd2048 : match_pointer = 5'd11;
          18'd4096 : match_pointer = 5'd12;
          18'd8192 : match_pointer = 5'd13;
          18'd16384 : match_pointer = 5'd14;
          18'd32768 : match_pointer = 5'd15;
          18'd65536 : match_pointer = 5'd16;
          18'd131072 : match_pointer = 5'd17;
         default : match_pointer = 5'bx;
       endcase
     end

    assign push_slice = bchannel_ready_i && bchannel_valid;

    assign bhndshk = bvalid_m && bready_m_i;
    assign update = bhndshk;
    assign pop_slice = update && match;


    assign bready_m_i = bvalid_m && (bready_s || ~match);
    assign bready_m   = bready_m_i;
    assign bid_s = bid_m;
    assign buser_s = buser_m;
    assign bresp_s = (bresp_m
                      |  bresp_out_0
                      |  bresp_out_1
                      |  bresp_out_2
                      |  bresp_out_3
                      |  bresp_out_4
                      |  bresp_out_5
                      |  bresp_out_6
                      |  bresp_out_7
                      |  bresp_out_8
                      |  bresp_out_9
                      |  bresp_out_10
                      |  bresp_out_11
                      |  bresp_out_12
                      |  bresp_out_13
                      |  bresp_out_14
                      |  bresp_out_15
                      |  bresp_out_16
                      |  bresp_out_17 );

    assign bvalid_s = (bvalid_m && match);



    

     nic400_ib_ib4_downsize_resp_cam_slice_sse710_main u_downsize_resp_cam_slice_0
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .matchid              (bid_m),
        .hazardid             (awid),

        .store                (store[0]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .n_response           (n_response),
        .bresp_in             (bresp_m),

        .hazard               (hazard_bus[0]),
        .match                (match_bus[0]),
        .valid                (valid_bus[0]),
        .bresp_out            (bresp_out_0)
     );
     

     nic400_ib_ib4_downsize_resp_cam_slice_sse710_main u_downsize_resp_cam_slice_1
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .matchid              (bid_m),
        .hazardid             (awid),

        .store                (store[1]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .n_response           (n_response),
        .bresp_in             (bresp_m),

        .hazard               (hazard_bus[1]),
        .match                (match_bus[1]),
        .valid                (valid_bus[1]),
        .bresp_out            (bresp_out_1)
     );
     

     nic400_ib_ib4_downsize_resp_cam_slice_sse710_main u_downsize_resp_cam_slice_2
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .matchid              (bid_m),
        .hazardid             (awid),

        .store                (store[2]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .n_response           (n_response),
        .bresp_in             (bresp_m),

        .hazard               (hazard_bus[2]),
        .match                (match_bus[2]),
        .valid                (valid_bus[2]),
        .bresp_out            (bresp_out_2)
     );
     

     nic400_ib_ib4_downsize_resp_cam_slice_sse710_main u_downsize_resp_cam_slice_3
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .matchid              (bid_m),
        .hazardid             (awid),

        .store                (store[3]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .n_response           (n_response),
        .bresp_in             (bresp_m),

        .hazard               (hazard_bus[3]),
        .match                (match_bus[3]),
        .valid                (valid_bus[3]),
        .bresp_out            (bresp_out_3)
     );
     

     nic400_ib_ib4_downsize_resp_cam_slice_sse710_main u_downsize_resp_cam_slice_4
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .matchid              (bid_m),
        .hazardid             (awid),

        .store                (store[4]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .n_response           (n_response),
        .bresp_in             (bresp_m),

        .hazard               (hazard_bus[4]),
        .match                (match_bus[4]),
        .valid                (valid_bus[4]),
        .bresp_out            (bresp_out_4)
     );
     

     nic400_ib_ib4_downsize_resp_cam_slice_sse710_main u_downsize_resp_cam_slice_5
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .matchid              (bid_m),
        .hazardid             (awid),

        .store                (store[5]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .n_response           (n_response),
        .bresp_in             (bresp_m),

        .hazard               (hazard_bus[5]),
        .match                (match_bus[5]),
        .valid                (valid_bus[5]),
        .bresp_out            (bresp_out_5)
     );
     

     nic400_ib_ib4_downsize_resp_cam_slice_sse710_main u_downsize_resp_cam_slice_6
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .matchid              (bid_m),
        .hazardid             (awid),

        .store                (store[6]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .n_response           (n_response),
        .bresp_in             (bresp_m),

        .hazard               (hazard_bus[6]),
        .match                (match_bus[6]),
        .valid                (valid_bus[6]),
        .bresp_out            (bresp_out_6)
     );
     

     nic400_ib_ib4_downsize_resp_cam_slice_sse710_main u_downsize_resp_cam_slice_7
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .matchid              (bid_m),
        .hazardid             (awid),

        .store                (store[7]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .n_response           (n_response),
        .bresp_in             (bresp_m),

        .hazard               (hazard_bus[7]),
        .match                (match_bus[7]),
        .valid                (valid_bus[7]),
        .bresp_out            (bresp_out_7)
     );
     

     nic400_ib_ib4_downsize_resp_cam_slice_sse710_main u_downsize_resp_cam_slice_8
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .matchid              (bid_m),
        .hazardid             (awid),

        .store                (store[8]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .n_response           (n_response),
        .bresp_in             (bresp_m),

        .hazard               (hazard_bus[8]),
        .match                (match_bus[8]),
        .valid                (valid_bus[8]),
        .bresp_out            (bresp_out_8)
     );
     

     nic400_ib_ib4_downsize_resp_cam_slice_sse710_main u_downsize_resp_cam_slice_9
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .matchid              (bid_m),
        .hazardid             (awid),

        .store                (store[9]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .n_response           (n_response),
        .bresp_in             (bresp_m),

        .hazard               (hazard_bus[9]),
        .match                (match_bus[9]),
        .valid                (valid_bus[9]),
        .bresp_out            (bresp_out_9)
     );
     

     nic400_ib_ib4_downsize_resp_cam_slice_sse710_main u_downsize_resp_cam_slice_10
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .matchid              (bid_m),
        .hazardid             (awid),

        .store                (store[10]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .n_response           (n_response),
        .bresp_in             (bresp_m),

        .hazard               (hazard_bus[10]),
        .match                (match_bus[10]),
        .valid                (valid_bus[10]),
        .bresp_out            (bresp_out_10)
     );
     

     nic400_ib_ib4_downsize_resp_cam_slice_sse710_main u_downsize_resp_cam_slice_11
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .matchid              (bid_m),
        .hazardid             (awid),

        .store                (store[11]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .n_response           (n_response),
        .bresp_in             (bresp_m),

        .hazard               (hazard_bus[11]),
        .match                (match_bus[11]),
        .valid                (valid_bus[11]),
        .bresp_out            (bresp_out_11)
     );
     

     nic400_ib_ib4_downsize_resp_cam_slice_sse710_main u_downsize_resp_cam_slice_12
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .matchid              (bid_m),
        .hazardid             (awid),

        .store                (store[12]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .n_response           (n_response),
        .bresp_in             (bresp_m),

        .hazard               (hazard_bus[12]),
        .match                (match_bus[12]),
        .valid                (valid_bus[12]),
        .bresp_out            (bresp_out_12)
     );
     

     nic400_ib_ib4_downsize_resp_cam_slice_sse710_main u_downsize_resp_cam_slice_13
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .matchid              (bid_m),
        .hazardid             (awid),

        .store                (store[13]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .n_response           (n_response),
        .bresp_in             (bresp_m),

        .hazard               (hazard_bus[13]),
        .match                (match_bus[13]),
        .valid                (valid_bus[13]),
        .bresp_out            (bresp_out_13)
     );
     

     nic400_ib_ib4_downsize_resp_cam_slice_sse710_main u_downsize_resp_cam_slice_14
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .matchid              (bid_m),
        .hazardid             (awid),

        .store                (store[14]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .n_response           (n_response),
        .bresp_in             (bresp_m),

        .hazard               (hazard_bus[14]),
        .match                (match_bus[14]),
        .valid                (valid_bus[14]),
        .bresp_out            (bresp_out_14)
     );
     

     nic400_ib_ib4_downsize_resp_cam_slice_sse710_main u_downsize_resp_cam_slice_15
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .matchid              (bid_m),
        .hazardid             (awid),

        .store                (store[15]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .n_response           (n_response),
        .bresp_in             (bresp_m),

        .hazard               (hazard_bus[15]),
        .match                (match_bus[15]),
        .valid                (valid_bus[15]),
        .bresp_out            (bresp_out_15)
     );
     

     nic400_ib_ib4_downsize_resp_cam_slice_sse710_main u_downsize_resp_cam_slice_16
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .matchid              (bid_m),
        .hazardid             (awid),

        .store                (store[16]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .n_response           (n_response),
        .bresp_in             (bresp_m),

        .hazard               (hazard_bus[16]),
        .match                (match_bus[16]),
        .valid                (valid_bus[16]),
        .bresp_out            (bresp_out_16)
     );
     

     nic400_ib_ib4_downsize_resp_cam_slice_sse710_main u_downsize_resp_cam_slice_17
     (
        .aresetn              (aresetn),
        .aclk                 (aclk),

        .matchid              (bid_m),
        .hazardid             (awid),

        .store                (store[17]),
        .push_slice           (push_slice),
        .pop_slice            (pop_slice),
        .update               (update),
        .match_pointer        (match_pointer),

        .hazard_in            (hazard),
        .hazard_pointer       (hazard_pointer),

        .n_response           (n_response),
        .bresp_in             (bresp_m),

        .hazard               (hazard_bus[17]),
        .match                (match_bus[17]),
        .valid                (valid_bus[17]),
        .bresp_out            (bresp_out_17)
     );
     


`ifdef ARM_ASSERT_ON
`include "std_ovl_defines.h"


  assert_zero_one_hot #(`OVL_FATAL,18,0,"More than one B Channel Slice matched")
  ovl_single_ID_match
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .test_expr        ({18{bvalid_m}} & match_bus)
     );


  assert_zero_one_hot #(`OVL_FATAL,18,0,"More than one B Channel Slice hazard")
  ovl_single_hazard
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .test_expr        ({18{bchannel_valid}} & hazard_bus)
     );


  assert_never #(`OVL_FATAL,`OVL_ASSERT,"No slices are valid and there is an incoming transaction")
  ovl_bslice_none_valid
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .test_expr        (~|valid_bus && bvalid_m)
     );


  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"ex_okay reponses lost")
  ovl_exokay_lost
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (bvalid_m && bresp_m == 2'b01),
     .consequent_expr  (match && bresp_s == 2'b01)
     );


  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"B Channel HndShk Error")
  ovl_input_hndshk_error
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (bchannel_valid),
     .consequent_expr  (bchannel_ready_i)
     );


   assert_fifo_index #(`OVL_FATAL, 18, 1, 1, 0,"ERROR, BChannel Look-Up under or overflowed")
      ovl_bchannel_fifo_index
         (
           .clk       (aclk),
           .reset_n   (aresetn),
           .push      (bchannel_ready_i && bchannel_valid),
           .pop       (bvalid_s && bready_s)
         );


  wire [11:0] cam_id_reg [0:17];

  assign cam_id_reg[0] = u_downsize_resp_cam_slice_0.id_reg;


  assert_implication #(`OVL_FATAL,0,"CAM 0 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_0_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[0] && u_downsize_resp_cam_slice_0.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_resp_cam_slice_0.pointer_reg] && (cam_id_reg[0] == cam_id_reg[u_downsize_resp_cam_slice_0.pointer_reg]))
     );


  assert_implication #(`OVL_FATAL,0,"CAM 0 is last but is pointed to by another valid CAM")
  ovl_cam_0_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[0] && u_downsize_resp_cam_slice_0.last_reg),
     .consequent_expr  (!(
                          (valid_bus[1] && u_downsize_resp_cam_slice_1.hazard_reg && u_downsize_resp_cam_slice_1.pointer_reg == 0) ||
                          (valid_bus[2] && u_downsize_resp_cam_slice_2.hazard_reg && u_downsize_resp_cam_slice_2.pointer_reg == 0) ||
                          (valid_bus[3] && u_downsize_resp_cam_slice_3.hazard_reg && u_downsize_resp_cam_slice_3.pointer_reg == 0) ||
                          (valid_bus[4] && u_downsize_resp_cam_slice_4.hazard_reg && u_downsize_resp_cam_slice_4.pointer_reg == 0) ||
                          (valid_bus[5] && u_downsize_resp_cam_slice_5.hazard_reg && u_downsize_resp_cam_slice_5.pointer_reg == 0) ||
                          (valid_bus[6] && u_downsize_resp_cam_slice_6.hazard_reg && u_downsize_resp_cam_slice_6.pointer_reg == 0) ||
                          (valid_bus[7] && u_downsize_resp_cam_slice_7.hazard_reg && u_downsize_resp_cam_slice_7.pointer_reg == 0) ||
                          (valid_bus[8] && u_downsize_resp_cam_slice_8.hazard_reg && u_downsize_resp_cam_slice_8.pointer_reg == 0) ||
                          (valid_bus[9] && u_downsize_resp_cam_slice_9.hazard_reg && u_downsize_resp_cam_slice_9.pointer_reg == 0) ||
                          (valid_bus[10] && u_downsize_resp_cam_slice_10.hazard_reg && u_downsize_resp_cam_slice_10.pointer_reg == 0) ||
                          (valid_bus[11] && u_downsize_resp_cam_slice_11.hazard_reg && u_downsize_resp_cam_slice_11.pointer_reg == 0) ||
                          (valid_bus[12] && u_downsize_resp_cam_slice_12.hazard_reg && u_downsize_resp_cam_slice_12.pointer_reg == 0) ||
                          (valid_bus[13] && u_downsize_resp_cam_slice_13.hazard_reg && u_downsize_resp_cam_slice_13.pointer_reg == 0) ||
                          (valid_bus[14] && u_downsize_resp_cam_slice_14.hazard_reg && u_downsize_resp_cam_slice_14.pointer_reg == 0) ||
                          (valid_bus[15] && u_downsize_resp_cam_slice_15.hazard_reg && u_downsize_resp_cam_slice_15.pointer_reg == 0) ||
                          (valid_bus[16] && u_downsize_resp_cam_slice_16.hazard_reg && u_downsize_resp_cam_slice_16.pointer_reg == 0) ||
                          (valid_bus[17] && u_downsize_resp_cam_slice_17.hazard_reg && u_downsize_resp_cam_slice_17.pointer_reg == 0)))
     );
  
  assign cam_id_reg[1] = u_downsize_resp_cam_slice_1.id_reg;


  assert_implication #(`OVL_FATAL,0,"CAM 1 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_1_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[1] && u_downsize_resp_cam_slice_1.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_resp_cam_slice_1.pointer_reg] && (cam_id_reg[1] == cam_id_reg[u_downsize_resp_cam_slice_1.pointer_reg]))
     );


  assert_implication #(`OVL_FATAL,0,"CAM 1 is last but is pointed to by another valid CAM")
  ovl_cam_1_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[1] && u_downsize_resp_cam_slice_1.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_resp_cam_slice_0.hazard_reg && u_downsize_resp_cam_slice_0.pointer_reg == 1) ||
                          (valid_bus[2] && u_downsize_resp_cam_slice_2.hazard_reg && u_downsize_resp_cam_slice_2.pointer_reg == 1) ||
                          (valid_bus[3] && u_downsize_resp_cam_slice_3.hazard_reg && u_downsize_resp_cam_slice_3.pointer_reg == 1) ||
                          (valid_bus[4] && u_downsize_resp_cam_slice_4.hazard_reg && u_downsize_resp_cam_slice_4.pointer_reg == 1) ||
                          (valid_bus[5] && u_downsize_resp_cam_slice_5.hazard_reg && u_downsize_resp_cam_slice_5.pointer_reg == 1) ||
                          (valid_bus[6] && u_downsize_resp_cam_slice_6.hazard_reg && u_downsize_resp_cam_slice_6.pointer_reg == 1) ||
                          (valid_bus[7] && u_downsize_resp_cam_slice_7.hazard_reg && u_downsize_resp_cam_slice_7.pointer_reg == 1) ||
                          (valid_bus[8] && u_downsize_resp_cam_slice_8.hazard_reg && u_downsize_resp_cam_slice_8.pointer_reg == 1) ||
                          (valid_bus[9] && u_downsize_resp_cam_slice_9.hazard_reg && u_downsize_resp_cam_slice_9.pointer_reg == 1) ||
                          (valid_bus[10] && u_downsize_resp_cam_slice_10.hazard_reg && u_downsize_resp_cam_slice_10.pointer_reg == 1) ||
                          (valid_bus[11] && u_downsize_resp_cam_slice_11.hazard_reg && u_downsize_resp_cam_slice_11.pointer_reg == 1) ||
                          (valid_bus[12] && u_downsize_resp_cam_slice_12.hazard_reg && u_downsize_resp_cam_slice_12.pointer_reg == 1) ||
                          (valid_bus[13] && u_downsize_resp_cam_slice_13.hazard_reg && u_downsize_resp_cam_slice_13.pointer_reg == 1) ||
                          (valid_bus[14] && u_downsize_resp_cam_slice_14.hazard_reg && u_downsize_resp_cam_slice_14.pointer_reg == 1) ||
                          (valid_bus[15] && u_downsize_resp_cam_slice_15.hazard_reg && u_downsize_resp_cam_slice_15.pointer_reg == 1) ||
                          (valid_bus[16] && u_downsize_resp_cam_slice_16.hazard_reg && u_downsize_resp_cam_slice_16.pointer_reg == 1) ||
                          (valid_bus[17] && u_downsize_resp_cam_slice_17.hazard_reg && u_downsize_resp_cam_slice_17.pointer_reg == 1)))
     );
  
  assign cam_id_reg[2] = u_downsize_resp_cam_slice_2.id_reg;


  assert_implication #(`OVL_FATAL,0,"CAM 2 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_2_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[2] && u_downsize_resp_cam_slice_2.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_resp_cam_slice_2.pointer_reg] && (cam_id_reg[2] == cam_id_reg[u_downsize_resp_cam_slice_2.pointer_reg]))
     );


  assert_implication #(`OVL_FATAL,0,"CAM 2 is last but is pointed to by another valid CAM")
  ovl_cam_2_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[2] && u_downsize_resp_cam_slice_2.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_resp_cam_slice_0.hazard_reg && u_downsize_resp_cam_slice_0.pointer_reg == 2) ||
                          (valid_bus[1] && u_downsize_resp_cam_slice_1.hazard_reg && u_downsize_resp_cam_slice_1.pointer_reg == 2) ||
                          (valid_bus[3] && u_downsize_resp_cam_slice_3.hazard_reg && u_downsize_resp_cam_slice_3.pointer_reg == 2) ||
                          (valid_bus[4] && u_downsize_resp_cam_slice_4.hazard_reg && u_downsize_resp_cam_slice_4.pointer_reg == 2) ||
                          (valid_bus[5] && u_downsize_resp_cam_slice_5.hazard_reg && u_downsize_resp_cam_slice_5.pointer_reg == 2) ||
                          (valid_bus[6] && u_downsize_resp_cam_slice_6.hazard_reg && u_downsize_resp_cam_slice_6.pointer_reg == 2) ||
                          (valid_bus[7] && u_downsize_resp_cam_slice_7.hazard_reg && u_downsize_resp_cam_slice_7.pointer_reg == 2) ||
                          (valid_bus[8] && u_downsize_resp_cam_slice_8.hazard_reg && u_downsize_resp_cam_slice_8.pointer_reg == 2) ||
                          (valid_bus[9] && u_downsize_resp_cam_slice_9.hazard_reg && u_downsize_resp_cam_slice_9.pointer_reg == 2) ||
                          (valid_bus[10] && u_downsize_resp_cam_slice_10.hazard_reg && u_downsize_resp_cam_slice_10.pointer_reg == 2) ||
                          (valid_bus[11] && u_downsize_resp_cam_slice_11.hazard_reg && u_downsize_resp_cam_slice_11.pointer_reg == 2) ||
                          (valid_bus[12] && u_downsize_resp_cam_slice_12.hazard_reg && u_downsize_resp_cam_slice_12.pointer_reg == 2) ||
                          (valid_bus[13] && u_downsize_resp_cam_slice_13.hazard_reg && u_downsize_resp_cam_slice_13.pointer_reg == 2) ||
                          (valid_bus[14] && u_downsize_resp_cam_slice_14.hazard_reg && u_downsize_resp_cam_slice_14.pointer_reg == 2) ||
                          (valid_bus[15] && u_downsize_resp_cam_slice_15.hazard_reg && u_downsize_resp_cam_slice_15.pointer_reg == 2) ||
                          (valid_bus[16] && u_downsize_resp_cam_slice_16.hazard_reg && u_downsize_resp_cam_slice_16.pointer_reg == 2) ||
                          (valid_bus[17] && u_downsize_resp_cam_slice_17.hazard_reg && u_downsize_resp_cam_slice_17.pointer_reg == 2)))
     );
  
  assign cam_id_reg[3] = u_downsize_resp_cam_slice_3.id_reg;


  assert_implication #(`OVL_FATAL,0,"CAM 3 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_3_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[3] && u_downsize_resp_cam_slice_3.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_resp_cam_slice_3.pointer_reg] && (cam_id_reg[3] == cam_id_reg[u_downsize_resp_cam_slice_3.pointer_reg]))
     );


  assert_implication #(`OVL_FATAL,0,"CAM 3 is last but is pointed to by another valid CAM")
  ovl_cam_3_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[3] && u_downsize_resp_cam_slice_3.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_resp_cam_slice_0.hazard_reg && u_downsize_resp_cam_slice_0.pointer_reg == 3) ||
                          (valid_bus[1] && u_downsize_resp_cam_slice_1.hazard_reg && u_downsize_resp_cam_slice_1.pointer_reg == 3) ||
                          (valid_bus[2] && u_downsize_resp_cam_slice_2.hazard_reg && u_downsize_resp_cam_slice_2.pointer_reg == 3) ||
                          (valid_bus[4] && u_downsize_resp_cam_slice_4.hazard_reg && u_downsize_resp_cam_slice_4.pointer_reg == 3) ||
                          (valid_bus[5] && u_downsize_resp_cam_slice_5.hazard_reg && u_downsize_resp_cam_slice_5.pointer_reg == 3) ||
                          (valid_bus[6] && u_downsize_resp_cam_slice_6.hazard_reg && u_downsize_resp_cam_slice_6.pointer_reg == 3) ||
                          (valid_bus[7] && u_downsize_resp_cam_slice_7.hazard_reg && u_downsize_resp_cam_slice_7.pointer_reg == 3) ||
                          (valid_bus[8] && u_downsize_resp_cam_slice_8.hazard_reg && u_downsize_resp_cam_slice_8.pointer_reg == 3) ||
                          (valid_bus[9] && u_downsize_resp_cam_slice_9.hazard_reg && u_downsize_resp_cam_slice_9.pointer_reg == 3) ||
                          (valid_bus[10] && u_downsize_resp_cam_slice_10.hazard_reg && u_downsize_resp_cam_slice_10.pointer_reg == 3) ||
                          (valid_bus[11] && u_downsize_resp_cam_slice_11.hazard_reg && u_downsize_resp_cam_slice_11.pointer_reg == 3) ||
                          (valid_bus[12] && u_downsize_resp_cam_slice_12.hazard_reg && u_downsize_resp_cam_slice_12.pointer_reg == 3) ||
                          (valid_bus[13] && u_downsize_resp_cam_slice_13.hazard_reg && u_downsize_resp_cam_slice_13.pointer_reg == 3) ||
                          (valid_bus[14] && u_downsize_resp_cam_slice_14.hazard_reg && u_downsize_resp_cam_slice_14.pointer_reg == 3) ||
                          (valid_bus[15] && u_downsize_resp_cam_slice_15.hazard_reg && u_downsize_resp_cam_slice_15.pointer_reg == 3) ||
                          (valid_bus[16] && u_downsize_resp_cam_slice_16.hazard_reg && u_downsize_resp_cam_slice_16.pointer_reg == 3) ||
                          (valid_bus[17] && u_downsize_resp_cam_slice_17.hazard_reg && u_downsize_resp_cam_slice_17.pointer_reg == 3)))
     );
  
  assign cam_id_reg[4] = u_downsize_resp_cam_slice_4.id_reg;


  assert_implication #(`OVL_FATAL,0,"CAM 4 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_4_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[4] && u_downsize_resp_cam_slice_4.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_resp_cam_slice_4.pointer_reg] && (cam_id_reg[4] == cam_id_reg[u_downsize_resp_cam_slice_4.pointer_reg]))
     );


  assert_implication #(`OVL_FATAL,0,"CAM 4 is last but is pointed to by another valid CAM")
  ovl_cam_4_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[4] && u_downsize_resp_cam_slice_4.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_resp_cam_slice_0.hazard_reg && u_downsize_resp_cam_slice_0.pointer_reg == 4) ||
                          (valid_bus[1] && u_downsize_resp_cam_slice_1.hazard_reg && u_downsize_resp_cam_slice_1.pointer_reg == 4) ||
                          (valid_bus[2] && u_downsize_resp_cam_slice_2.hazard_reg && u_downsize_resp_cam_slice_2.pointer_reg == 4) ||
                          (valid_bus[3] && u_downsize_resp_cam_slice_3.hazard_reg && u_downsize_resp_cam_slice_3.pointer_reg == 4) ||
                          (valid_bus[5] && u_downsize_resp_cam_slice_5.hazard_reg && u_downsize_resp_cam_slice_5.pointer_reg == 4) ||
                          (valid_bus[6] && u_downsize_resp_cam_slice_6.hazard_reg && u_downsize_resp_cam_slice_6.pointer_reg == 4) ||
                          (valid_bus[7] && u_downsize_resp_cam_slice_7.hazard_reg && u_downsize_resp_cam_slice_7.pointer_reg == 4) ||
                          (valid_bus[8] && u_downsize_resp_cam_slice_8.hazard_reg && u_downsize_resp_cam_slice_8.pointer_reg == 4) ||
                          (valid_bus[9] && u_downsize_resp_cam_slice_9.hazard_reg && u_downsize_resp_cam_slice_9.pointer_reg == 4) ||
                          (valid_bus[10] && u_downsize_resp_cam_slice_10.hazard_reg && u_downsize_resp_cam_slice_10.pointer_reg == 4) ||
                          (valid_bus[11] && u_downsize_resp_cam_slice_11.hazard_reg && u_downsize_resp_cam_slice_11.pointer_reg == 4) ||
                          (valid_bus[12] && u_downsize_resp_cam_slice_12.hazard_reg && u_downsize_resp_cam_slice_12.pointer_reg == 4) ||
                          (valid_bus[13] && u_downsize_resp_cam_slice_13.hazard_reg && u_downsize_resp_cam_slice_13.pointer_reg == 4) ||
                          (valid_bus[14] && u_downsize_resp_cam_slice_14.hazard_reg && u_downsize_resp_cam_slice_14.pointer_reg == 4) ||
                          (valid_bus[15] && u_downsize_resp_cam_slice_15.hazard_reg && u_downsize_resp_cam_slice_15.pointer_reg == 4) ||
                          (valid_bus[16] && u_downsize_resp_cam_slice_16.hazard_reg && u_downsize_resp_cam_slice_16.pointer_reg == 4) ||
                          (valid_bus[17] && u_downsize_resp_cam_slice_17.hazard_reg && u_downsize_resp_cam_slice_17.pointer_reg == 4)))
     );
  
  assign cam_id_reg[5] = u_downsize_resp_cam_slice_5.id_reg;


  assert_implication #(`OVL_FATAL,0,"CAM 5 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_5_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[5] && u_downsize_resp_cam_slice_5.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_resp_cam_slice_5.pointer_reg] && (cam_id_reg[5] == cam_id_reg[u_downsize_resp_cam_slice_5.pointer_reg]))
     );


  assert_implication #(`OVL_FATAL,0,"CAM 5 is last but is pointed to by another valid CAM")
  ovl_cam_5_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[5] && u_downsize_resp_cam_slice_5.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_resp_cam_slice_0.hazard_reg && u_downsize_resp_cam_slice_0.pointer_reg == 5) ||
                          (valid_bus[1] && u_downsize_resp_cam_slice_1.hazard_reg && u_downsize_resp_cam_slice_1.pointer_reg == 5) ||
                          (valid_bus[2] && u_downsize_resp_cam_slice_2.hazard_reg && u_downsize_resp_cam_slice_2.pointer_reg == 5) ||
                          (valid_bus[3] && u_downsize_resp_cam_slice_3.hazard_reg && u_downsize_resp_cam_slice_3.pointer_reg == 5) ||
                          (valid_bus[4] && u_downsize_resp_cam_slice_4.hazard_reg && u_downsize_resp_cam_slice_4.pointer_reg == 5) ||
                          (valid_bus[6] && u_downsize_resp_cam_slice_6.hazard_reg && u_downsize_resp_cam_slice_6.pointer_reg == 5) ||
                          (valid_bus[7] && u_downsize_resp_cam_slice_7.hazard_reg && u_downsize_resp_cam_slice_7.pointer_reg == 5) ||
                          (valid_bus[8] && u_downsize_resp_cam_slice_8.hazard_reg && u_downsize_resp_cam_slice_8.pointer_reg == 5) ||
                          (valid_bus[9] && u_downsize_resp_cam_slice_9.hazard_reg && u_downsize_resp_cam_slice_9.pointer_reg == 5) ||
                          (valid_bus[10] && u_downsize_resp_cam_slice_10.hazard_reg && u_downsize_resp_cam_slice_10.pointer_reg == 5) ||
                          (valid_bus[11] && u_downsize_resp_cam_slice_11.hazard_reg && u_downsize_resp_cam_slice_11.pointer_reg == 5) ||
                          (valid_bus[12] && u_downsize_resp_cam_slice_12.hazard_reg && u_downsize_resp_cam_slice_12.pointer_reg == 5) ||
                          (valid_bus[13] && u_downsize_resp_cam_slice_13.hazard_reg && u_downsize_resp_cam_slice_13.pointer_reg == 5) ||
                          (valid_bus[14] && u_downsize_resp_cam_slice_14.hazard_reg && u_downsize_resp_cam_slice_14.pointer_reg == 5) ||
                          (valid_bus[15] && u_downsize_resp_cam_slice_15.hazard_reg && u_downsize_resp_cam_slice_15.pointer_reg == 5) ||
                          (valid_bus[16] && u_downsize_resp_cam_slice_16.hazard_reg && u_downsize_resp_cam_slice_16.pointer_reg == 5) ||
                          (valid_bus[17] && u_downsize_resp_cam_slice_17.hazard_reg && u_downsize_resp_cam_slice_17.pointer_reg == 5)))
     );
  
  assign cam_id_reg[6] = u_downsize_resp_cam_slice_6.id_reg;


  assert_implication #(`OVL_FATAL,0,"CAM 6 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_6_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[6] && u_downsize_resp_cam_slice_6.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_resp_cam_slice_6.pointer_reg] && (cam_id_reg[6] == cam_id_reg[u_downsize_resp_cam_slice_6.pointer_reg]))
     );


  assert_implication #(`OVL_FATAL,0,"CAM 6 is last but is pointed to by another valid CAM")
  ovl_cam_6_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[6] && u_downsize_resp_cam_slice_6.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_resp_cam_slice_0.hazard_reg && u_downsize_resp_cam_slice_0.pointer_reg == 6) ||
                          (valid_bus[1] && u_downsize_resp_cam_slice_1.hazard_reg && u_downsize_resp_cam_slice_1.pointer_reg == 6) ||
                          (valid_bus[2] && u_downsize_resp_cam_slice_2.hazard_reg && u_downsize_resp_cam_slice_2.pointer_reg == 6) ||
                          (valid_bus[3] && u_downsize_resp_cam_slice_3.hazard_reg && u_downsize_resp_cam_slice_3.pointer_reg == 6) ||
                          (valid_bus[4] && u_downsize_resp_cam_slice_4.hazard_reg && u_downsize_resp_cam_slice_4.pointer_reg == 6) ||
                          (valid_bus[5] && u_downsize_resp_cam_slice_5.hazard_reg && u_downsize_resp_cam_slice_5.pointer_reg == 6) ||
                          (valid_bus[7] && u_downsize_resp_cam_slice_7.hazard_reg && u_downsize_resp_cam_slice_7.pointer_reg == 6) ||
                          (valid_bus[8] && u_downsize_resp_cam_slice_8.hazard_reg && u_downsize_resp_cam_slice_8.pointer_reg == 6) ||
                          (valid_bus[9] && u_downsize_resp_cam_slice_9.hazard_reg && u_downsize_resp_cam_slice_9.pointer_reg == 6) ||
                          (valid_bus[10] && u_downsize_resp_cam_slice_10.hazard_reg && u_downsize_resp_cam_slice_10.pointer_reg == 6) ||
                          (valid_bus[11] && u_downsize_resp_cam_slice_11.hazard_reg && u_downsize_resp_cam_slice_11.pointer_reg == 6) ||
                          (valid_bus[12] && u_downsize_resp_cam_slice_12.hazard_reg && u_downsize_resp_cam_slice_12.pointer_reg == 6) ||
                          (valid_bus[13] && u_downsize_resp_cam_slice_13.hazard_reg && u_downsize_resp_cam_slice_13.pointer_reg == 6) ||
                          (valid_bus[14] && u_downsize_resp_cam_slice_14.hazard_reg && u_downsize_resp_cam_slice_14.pointer_reg == 6) ||
                          (valid_bus[15] && u_downsize_resp_cam_slice_15.hazard_reg && u_downsize_resp_cam_slice_15.pointer_reg == 6) ||
                          (valid_bus[16] && u_downsize_resp_cam_slice_16.hazard_reg && u_downsize_resp_cam_slice_16.pointer_reg == 6) ||
                          (valid_bus[17] && u_downsize_resp_cam_slice_17.hazard_reg && u_downsize_resp_cam_slice_17.pointer_reg == 6)))
     );
  
  assign cam_id_reg[7] = u_downsize_resp_cam_slice_7.id_reg;


  assert_implication #(`OVL_FATAL,0,"CAM 7 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_7_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[7] && u_downsize_resp_cam_slice_7.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_resp_cam_slice_7.pointer_reg] && (cam_id_reg[7] == cam_id_reg[u_downsize_resp_cam_slice_7.pointer_reg]))
     );


  assert_implication #(`OVL_FATAL,0,"CAM 7 is last but is pointed to by another valid CAM")
  ovl_cam_7_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[7] && u_downsize_resp_cam_slice_7.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_resp_cam_slice_0.hazard_reg && u_downsize_resp_cam_slice_0.pointer_reg == 7) ||
                          (valid_bus[1] && u_downsize_resp_cam_slice_1.hazard_reg && u_downsize_resp_cam_slice_1.pointer_reg == 7) ||
                          (valid_bus[2] && u_downsize_resp_cam_slice_2.hazard_reg && u_downsize_resp_cam_slice_2.pointer_reg == 7) ||
                          (valid_bus[3] && u_downsize_resp_cam_slice_3.hazard_reg && u_downsize_resp_cam_slice_3.pointer_reg == 7) ||
                          (valid_bus[4] && u_downsize_resp_cam_slice_4.hazard_reg && u_downsize_resp_cam_slice_4.pointer_reg == 7) ||
                          (valid_bus[5] && u_downsize_resp_cam_slice_5.hazard_reg && u_downsize_resp_cam_slice_5.pointer_reg == 7) ||
                          (valid_bus[6] && u_downsize_resp_cam_slice_6.hazard_reg && u_downsize_resp_cam_slice_6.pointer_reg == 7) ||
                          (valid_bus[8] && u_downsize_resp_cam_slice_8.hazard_reg && u_downsize_resp_cam_slice_8.pointer_reg == 7) ||
                          (valid_bus[9] && u_downsize_resp_cam_slice_9.hazard_reg && u_downsize_resp_cam_slice_9.pointer_reg == 7) ||
                          (valid_bus[10] && u_downsize_resp_cam_slice_10.hazard_reg && u_downsize_resp_cam_slice_10.pointer_reg == 7) ||
                          (valid_bus[11] && u_downsize_resp_cam_slice_11.hazard_reg && u_downsize_resp_cam_slice_11.pointer_reg == 7) ||
                          (valid_bus[12] && u_downsize_resp_cam_slice_12.hazard_reg && u_downsize_resp_cam_slice_12.pointer_reg == 7) ||
                          (valid_bus[13] && u_downsize_resp_cam_slice_13.hazard_reg && u_downsize_resp_cam_slice_13.pointer_reg == 7) ||
                          (valid_bus[14] && u_downsize_resp_cam_slice_14.hazard_reg && u_downsize_resp_cam_slice_14.pointer_reg == 7) ||
                          (valid_bus[15] && u_downsize_resp_cam_slice_15.hazard_reg && u_downsize_resp_cam_slice_15.pointer_reg == 7) ||
                          (valid_bus[16] && u_downsize_resp_cam_slice_16.hazard_reg && u_downsize_resp_cam_slice_16.pointer_reg == 7) ||
                          (valid_bus[17] && u_downsize_resp_cam_slice_17.hazard_reg && u_downsize_resp_cam_slice_17.pointer_reg == 7)))
     );
  
  assign cam_id_reg[8] = u_downsize_resp_cam_slice_8.id_reg;


  assert_implication #(`OVL_FATAL,0,"CAM 8 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_8_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[8] && u_downsize_resp_cam_slice_8.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_resp_cam_slice_8.pointer_reg] && (cam_id_reg[8] == cam_id_reg[u_downsize_resp_cam_slice_8.pointer_reg]))
     );


  assert_implication #(`OVL_FATAL,0,"CAM 8 is last but is pointed to by another valid CAM")
  ovl_cam_8_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[8] && u_downsize_resp_cam_slice_8.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_resp_cam_slice_0.hazard_reg && u_downsize_resp_cam_slice_0.pointer_reg == 8) ||
                          (valid_bus[1] && u_downsize_resp_cam_slice_1.hazard_reg && u_downsize_resp_cam_slice_1.pointer_reg == 8) ||
                          (valid_bus[2] && u_downsize_resp_cam_slice_2.hazard_reg && u_downsize_resp_cam_slice_2.pointer_reg == 8) ||
                          (valid_bus[3] && u_downsize_resp_cam_slice_3.hazard_reg && u_downsize_resp_cam_slice_3.pointer_reg == 8) ||
                          (valid_bus[4] && u_downsize_resp_cam_slice_4.hazard_reg && u_downsize_resp_cam_slice_4.pointer_reg == 8) ||
                          (valid_bus[5] && u_downsize_resp_cam_slice_5.hazard_reg && u_downsize_resp_cam_slice_5.pointer_reg == 8) ||
                          (valid_bus[6] && u_downsize_resp_cam_slice_6.hazard_reg && u_downsize_resp_cam_slice_6.pointer_reg == 8) ||
                          (valid_bus[7] && u_downsize_resp_cam_slice_7.hazard_reg && u_downsize_resp_cam_slice_7.pointer_reg == 8) ||
                          (valid_bus[9] && u_downsize_resp_cam_slice_9.hazard_reg && u_downsize_resp_cam_slice_9.pointer_reg == 8) ||
                          (valid_bus[10] && u_downsize_resp_cam_slice_10.hazard_reg && u_downsize_resp_cam_slice_10.pointer_reg == 8) ||
                          (valid_bus[11] && u_downsize_resp_cam_slice_11.hazard_reg && u_downsize_resp_cam_slice_11.pointer_reg == 8) ||
                          (valid_bus[12] && u_downsize_resp_cam_slice_12.hazard_reg && u_downsize_resp_cam_slice_12.pointer_reg == 8) ||
                          (valid_bus[13] && u_downsize_resp_cam_slice_13.hazard_reg && u_downsize_resp_cam_slice_13.pointer_reg == 8) ||
                          (valid_bus[14] && u_downsize_resp_cam_slice_14.hazard_reg && u_downsize_resp_cam_slice_14.pointer_reg == 8) ||
                          (valid_bus[15] && u_downsize_resp_cam_slice_15.hazard_reg && u_downsize_resp_cam_slice_15.pointer_reg == 8) ||
                          (valid_bus[16] && u_downsize_resp_cam_slice_16.hazard_reg && u_downsize_resp_cam_slice_16.pointer_reg == 8) ||
                          (valid_bus[17] && u_downsize_resp_cam_slice_17.hazard_reg && u_downsize_resp_cam_slice_17.pointer_reg == 8)))
     );
  
  assign cam_id_reg[9] = u_downsize_resp_cam_slice_9.id_reg;


  assert_implication #(`OVL_FATAL,0,"CAM 9 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_9_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[9] && u_downsize_resp_cam_slice_9.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_resp_cam_slice_9.pointer_reg] && (cam_id_reg[9] == cam_id_reg[u_downsize_resp_cam_slice_9.pointer_reg]))
     );


  assert_implication #(`OVL_FATAL,0,"CAM 9 is last but is pointed to by another valid CAM")
  ovl_cam_9_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[9] && u_downsize_resp_cam_slice_9.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_resp_cam_slice_0.hazard_reg && u_downsize_resp_cam_slice_0.pointer_reg == 9) ||
                          (valid_bus[1] && u_downsize_resp_cam_slice_1.hazard_reg && u_downsize_resp_cam_slice_1.pointer_reg == 9) ||
                          (valid_bus[2] && u_downsize_resp_cam_slice_2.hazard_reg && u_downsize_resp_cam_slice_2.pointer_reg == 9) ||
                          (valid_bus[3] && u_downsize_resp_cam_slice_3.hazard_reg && u_downsize_resp_cam_slice_3.pointer_reg == 9) ||
                          (valid_bus[4] && u_downsize_resp_cam_slice_4.hazard_reg && u_downsize_resp_cam_slice_4.pointer_reg == 9) ||
                          (valid_bus[5] && u_downsize_resp_cam_slice_5.hazard_reg && u_downsize_resp_cam_slice_5.pointer_reg == 9) ||
                          (valid_bus[6] && u_downsize_resp_cam_slice_6.hazard_reg && u_downsize_resp_cam_slice_6.pointer_reg == 9) ||
                          (valid_bus[7] && u_downsize_resp_cam_slice_7.hazard_reg && u_downsize_resp_cam_slice_7.pointer_reg == 9) ||
                          (valid_bus[8] && u_downsize_resp_cam_slice_8.hazard_reg && u_downsize_resp_cam_slice_8.pointer_reg == 9) ||
                          (valid_bus[10] && u_downsize_resp_cam_slice_10.hazard_reg && u_downsize_resp_cam_slice_10.pointer_reg == 9) ||
                          (valid_bus[11] && u_downsize_resp_cam_slice_11.hazard_reg && u_downsize_resp_cam_slice_11.pointer_reg == 9) ||
                          (valid_bus[12] && u_downsize_resp_cam_slice_12.hazard_reg && u_downsize_resp_cam_slice_12.pointer_reg == 9) ||
                          (valid_bus[13] && u_downsize_resp_cam_slice_13.hazard_reg && u_downsize_resp_cam_slice_13.pointer_reg == 9) ||
                          (valid_bus[14] && u_downsize_resp_cam_slice_14.hazard_reg && u_downsize_resp_cam_slice_14.pointer_reg == 9) ||
                          (valid_bus[15] && u_downsize_resp_cam_slice_15.hazard_reg && u_downsize_resp_cam_slice_15.pointer_reg == 9) ||
                          (valid_bus[16] && u_downsize_resp_cam_slice_16.hazard_reg && u_downsize_resp_cam_slice_16.pointer_reg == 9) ||
                          (valid_bus[17] && u_downsize_resp_cam_slice_17.hazard_reg && u_downsize_resp_cam_slice_17.pointer_reg == 9)))
     );
  
  assign cam_id_reg[10] = u_downsize_resp_cam_slice_10.id_reg;


  assert_implication #(`OVL_FATAL,0,"CAM 10 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_10_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[10] && u_downsize_resp_cam_slice_10.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_resp_cam_slice_10.pointer_reg] && (cam_id_reg[10] == cam_id_reg[u_downsize_resp_cam_slice_10.pointer_reg]))
     );


  assert_implication #(`OVL_FATAL,0,"CAM 10 is last but is pointed to by another valid CAM")
  ovl_cam_10_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[10] && u_downsize_resp_cam_slice_10.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_resp_cam_slice_0.hazard_reg && u_downsize_resp_cam_slice_0.pointer_reg == 10) ||
                          (valid_bus[1] && u_downsize_resp_cam_slice_1.hazard_reg && u_downsize_resp_cam_slice_1.pointer_reg == 10) ||
                          (valid_bus[2] && u_downsize_resp_cam_slice_2.hazard_reg && u_downsize_resp_cam_slice_2.pointer_reg == 10) ||
                          (valid_bus[3] && u_downsize_resp_cam_slice_3.hazard_reg && u_downsize_resp_cam_slice_3.pointer_reg == 10) ||
                          (valid_bus[4] && u_downsize_resp_cam_slice_4.hazard_reg && u_downsize_resp_cam_slice_4.pointer_reg == 10) ||
                          (valid_bus[5] && u_downsize_resp_cam_slice_5.hazard_reg && u_downsize_resp_cam_slice_5.pointer_reg == 10) ||
                          (valid_bus[6] && u_downsize_resp_cam_slice_6.hazard_reg && u_downsize_resp_cam_slice_6.pointer_reg == 10) ||
                          (valid_bus[7] && u_downsize_resp_cam_slice_7.hazard_reg && u_downsize_resp_cam_slice_7.pointer_reg == 10) ||
                          (valid_bus[8] && u_downsize_resp_cam_slice_8.hazard_reg && u_downsize_resp_cam_slice_8.pointer_reg == 10) ||
                          (valid_bus[9] && u_downsize_resp_cam_slice_9.hazard_reg && u_downsize_resp_cam_slice_9.pointer_reg == 10) ||
                          (valid_bus[11] && u_downsize_resp_cam_slice_11.hazard_reg && u_downsize_resp_cam_slice_11.pointer_reg == 10) ||
                          (valid_bus[12] && u_downsize_resp_cam_slice_12.hazard_reg && u_downsize_resp_cam_slice_12.pointer_reg == 10) ||
                          (valid_bus[13] && u_downsize_resp_cam_slice_13.hazard_reg && u_downsize_resp_cam_slice_13.pointer_reg == 10) ||
                          (valid_bus[14] && u_downsize_resp_cam_slice_14.hazard_reg && u_downsize_resp_cam_slice_14.pointer_reg == 10) ||
                          (valid_bus[15] && u_downsize_resp_cam_slice_15.hazard_reg && u_downsize_resp_cam_slice_15.pointer_reg == 10) ||
                          (valid_bus[16] && u_downsize_resp_cam_slice_16.hazard_reg && u_downsize_resp_cam_slice_16.pointer_reg == 10) ||
                          (valid_bus[17] && u_downsize_resp_cam_slice_17.hazard_reg && u_downsize_resp_cam_slice_17.pointer_reg == 10)))
     );
  
  assign cam_id_reg[11] = u_downsize_resp_cam_slice_11.id_reg;


  assert_implication #(`OVL_FATAL,0,"CAM 11 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_11_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[11] && u_downsize_resp_cam_slice_11.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_resp_cam_slice_11.pointer_reg] && (cam_id_reg[11] == cam_id_reg[u_downsize_resp_cam_slice_11.pointer_reg]))
     );


  assert_implication #(`OVL_FATAL,0,"CAM 11 is last but is pointed to by another valid CAM")
  ovl_cam_11_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[11] && u_downsize_resp_cam_slice_11.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_resp_cam_slice_0.hazard_reg && u_downsize_resp_cam_slice_0.pointer_reg == 11) ||
                          (valid_bus[1] && u_downsize_resp_cam_slice_1.hazard_reg && u_downsize_resp_cam_slice_1.pointer_reg == 11) ||
                          (valid_bus[2] && u_downsize_resp_cam_slice_2.hazard_reg && u_downsize_resp_cam_slice_2.pointer_reg == 11) ||
                          (valid_bus[3] && u_downsize_resp_cam_slice_3.hazard_reg && u_downsize_resp_cam_slice_3.pointer_reg == 11) ||
                          (valid_bus[4] && u_downsize_resp_cam_slice_4.hazard_reg && u_downsize_resp_cam_slice_4.pointer_reg == 11) ||
                          (valid_bus[5] && u_downsize_resp_cam_slice_5.hazard_reg && u_downsize_resp_cam_slice_5.pointer_reg == 11) ||
                          (valid_bus[6] && u_downsize_resp_cam_slice_6.hazard_reg && u_downsize_resp_cam_slice_6.pointer_reg == 11) ||
                          (valid_bus[7] && u_downsize_resp_cam_slice_7.hazard_reg && u_downsize_resp_cam_slice_7.pointer_reg == 11) ||
                          (valid_bus[8] && u_downsize_resp_cam_slice_8.hazard_reg && u_downsize_resp_cam_slice_8.pointer_reg == 11) ||
                          (valid_bus[9] && u_downsize_resp_cam_slice_9.hazard_reg && u_downsize_resp_cam_slice_9.pointer_reg == 11) ||
                          (valid_bus[10] && u_downsize_resp_cam_slice_10.hazard_reg && u_downsize_resp_cam_slice_10.pointer_reg == 11) ||
                          (valid_bus[12] && u_downsize_resp_cam_slice_12.hazard_reg && u_downsize_resp_cam_slice_12.pointer_reg == 11) ||
                          (valid_bus[13] && u_downsize_resp_cam_slice_13.hazard_reg && u_downsize_resp_cam_slice_13.pointer_reg == 11) ||
                          (valid_bus[14] && u_downsize_resp_cam_slice_14.hazard_reg && u_downsize_resp_cam_slice_14.pointer_reg == 11) ||
                          (valid_bus[15] && u_downsize_resp_cam_slice_15.hazard_reg && u_downsize_resp_cam_slice_15.pointer_reg == 11) ||
                          (valid_bus[16] && u_downsize_resp_cam_slice_16.hazard_reg && u_downsize_resp_cam_slice_16.pointer_reg == 11) ||
                          (valid_bus[17] && u_downsize_resp_cam_slice_17.hazard_reg && u_downsize_resp_cam_slice_17.pointer_reg == 11)))
     );
  
  assign cam_id_reg[12] = u_downsize_resp_cam_slice_12.id_reg;


  assert_implication #(`OVL_FATAL,0,"CAM 12 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_12_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[12] && u_downsize_resp_cam_slice_12.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_resp_cam_slice_12.pointer_reg] && (cam_id_reg[12] == cam_id_reg[u_downsize_resp_cam_slice_12.pointer_reg]))
     );


  assert_implication #(`OVL_FATAL,0,"CAM 12 is last but is pointed to by another valid CAM")
  ovl_cam_12_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[12] && u_downsize_resp_cam_slice_12.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_resp_cam_slice_0.hazard_reg && u_downsize_resp_cam_slice_0.pointer_reg == 12) ||
                          (valid_bus[1] && u_downsize_resp_cam_slice_1.hazard_reg && u_downsize_resp_cam_slice_1.pointer_reg == 12) ||
                          (valid_bus[2] && u_downsize_resp_cam_slice_2.hazard_reg && u_downsize_resp_cam_slice_2.pointer_reg == 12) ||
                          (valid_bus[3] && u_downsize_resp_cam_slice_3.hazard_reg && u_downsize_resp_cam_slice_3.pointer_reg == 12) ||
                          (valid_bus[4] && u_downsize_resp_cam_slice_4.hazard_reg && u_downsize_resp_cam_slice_4.pointer_reg == 12) ||
                          (valid_bus[5] && u_downsize_resp_cam_slice_5.hazard_reg && u_downsize_resp_cam_slice_5.pointer_reg == 12) ||
                          (valid_bus[6] && u_downsize_resp_cam_slice_6.hazard_reg && u_downsize_resp_cam_slice_6.pointer_reg == 12) ||
                          (valid_bus[7] && u_downsize_resp_cam_slice_7.hazard_reg && u_downsize_resp_cam_slice_7.pointer_reg == 12) ||
                          (valid_bus[8] && u_downsize_resp_cam_slice_8.hazard_reg && u_downsize_resp_cam_slice_8.pointer_reg == 12) ||
                          (valid_bus[9] && u_downsize_resp_cam_slice_9.hazard_reg && u_downsize_resp_cam_slice_9.pointer_reg == 12) ||
                          (valid_bus[10] && u_downsize_resp_cam_slice_10.hazard_reg && u_downsize_resp_cam_slice_10.pointer_reg == 12) ||
                          (valid_bus[11] && u_downsize_resp_cam_slice_11.hazard_reg && u_downsize_resp_cam_slice_11.pointer_reg == 12) ||
                          (valid_bus[13] && u_downsize_resp_cam_slice_13.hazard_reg && u_downsize_resp_cam_slice_13.pointer_reg == 12) ||
                          (valid_bus[14] && u_downsize_resp_cam_slice_14.hazard_reg && u_downsize_resp_cam_slice_14.pointer_reg == 12) ||
                          (valid_bus[15] && u_downsize_resp_cam_slice_15.hazard_reg && u_downsize_resp_cam_slice_15.pointer_reg == 12) ||
                          (valid_bus[16] && u_downsize_resp_cam_slice_16.hazard_reg && u_downsize_resp_cam_slice_16.pointer_reg == 12) ||
                          (valid_bus[17] && u_downsize_resp_cam_slice_17.hazard_reg && u_downsize_resp_cam_slice_17.pointer_reg == 12)))
     );
  
  assign cam_id_reg[13] = u_downsize_resp_cam_slice_13.id_reg;


  assert_implication #(`OVL_FATAL,0,"CAM 13 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_13_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[13] && u_downsize_resp_cam_slice_13.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_resp_cam_slice_13.pointer_reg] && (cam_id_reg[13] == cam_id_reg[u_downsize_resp_cam_slice_13.pointer_reg]))
     );


  assert_implication #(`OVL_FATAL,0,"CAM 13 is last but is pointed to by another valid CAM")
  ovl_cam_13_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[13] && u_downsize_resp_cam_slice_13.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_resp_cam_slice_0.hazard_reg && u_downsize_resp_cam_slice_0.pointer_reg == 13) ||
                          (valid_bus[1] && u_downsize_resp_cam_slice_1.hazard_reg && u_downsize_resp_cam_slice_1.pointer_reg == 13) ||
                          (valid_bus[2] && u_downsize_resp_cam_slice_2.hazard_reg && u_downsize_resp_cam_slice_2.pointer_reg == 13) ||
                          (valid_bus[3] && u_downsize_resp_cam_slice_3.hazard_reg && u_downsize_resp_cam_slice_3.pointer_reg == 13) ||
                          (valid_bus[4] && u_downsize_resp_cam_slice_4.hazard_reg && u_downsize_resp_cam_slice_4.pointer_reg == 13) ||
                          (valid_bus[5] && u_downsize_resp_cam_slice_5.hazard_reg && u_downsize_resp_cam_slice_5.pointer_reg == 13) ||
                          (valid_bus[6] && u_downsize_resp_cam_slice_6.hazard_reg && u_downsize_resp_cam_slice_6.pointer_reg == 13) ||
                          (valid_bus[7] && u_downsize_resp_cam_slice_7.hazard_reg && u_downsize_resp_cam_slice_7.pointer_reg == 13) ||
                          (valid_bus[8] && u_downsize_resp_cam_slice_8.hazard_reg && u_downsize_resp_cam_slice_8.pointer_reg == 13) ||
                          (valid_bus[9] && u_downsize_resp_cam_slice_9.hazard_reg && u_downsize_resp_cam_slice_9.pointer_reg == 13) ||
                          (valid_bus[10] && u_downsize_resp_cam_slice_10.hazard_reg && u_downsize_resp_cam_slice_10.pointer_reg == 13) ||
                          (valid_bus[11] && u_downsize_resp_cam_slice_11.hazard_reg && u_downsize_resp_cam_slice_11.pointer_reg == 13) ||
                          (valid_bus[12] && u_downsize_resp_cam_slice_12.hazard_reg && u_downsize_resp_cam_slice_12.pointer_reg == 13) ||
                          (valid_bus[14] && u_downsize_resp_cam_slice_14.hazard_reg && u_downsize_resp_cam_slice_14.pointer_reg == 13) ||
                          (valid_bus[15] && u_downsize_resp_cam_slice_15.hazard_reg && u_downsize_resp_cam_slice_15.pointer_reg == 13) ||
                          (valid_bus[16] && u_downsize_resp_cam_slice_16.hazard_reg && u_downsize_resp_cam_slice_16.pointer_reg == 13) ||
                          (valid_bus[17] && u_downsize_resp_cam_slice_17.hazard_reg && u_downsize_resp_cam_slice_17.pointer_reg == 13)))
     );
  
  assign cam_id_reg[14] = u_downsize_resp_cam_slice_14.id_reg;


  assert_implication #(`OVL_FATAL,0,"CAM 14 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_14_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[14] && u_downsize_resp_cam_slice_14.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_resp_cam_slice_14.pointer_reg] && (cam_id_reg[14] == cam_id_reg[u_downsize_resp_cam_slice_14.pointer_reg]))
     );


  assert_implication #(`OVL_FATAL,0,"CAM 14 is last but is pointed to by another valid CAM")
  ovl_cam_14_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[14] && u_downsize_resp_cam_slice_14.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_resp_cam_slice_0.hazard_reg && u_downsize_resp_cam_slice_0.pointer_reg == 14) ||
                          (valid_bus[1] && u_downsize_resp_cam_slice_1.hazard_reg && u_downsize_resp_cam_slice_1.pointer_reg == 14) ||
                          (valid_bus[2] && u_downsize_resp_cam_slice_2.hazard_reg && u_downsize_resp_cam_slice_2.pointer_reg == 14) ||
                          (valid_bus[3] && u_downsize_resp_cam_slice_3.hazard_reg && u_downsize_resp_cam_slice_3.pointer_reg == 14) ||
                          (valid_bus[4] && u_downsize_resp_cam_slice_4.hazard_reg && u_downsize_resp_cam_slice_4.pointer_reg == 14) ||
                          (valid_bus[5] && u_downsize_resp_cam_slice_5.hazard_reg && u_downsize_resp_cam_slice_5.pointer_reg == 14) ||
                          (valid_bus[6] && u_downsize_resp_cam_slice_6.hazard_reg && u_downsize_resp_cam_slice_6.pointer_reg == 14) ||
                          (valid_bus[7] && u_downsize_resp_cam_slice_7.hazard_reg && u_downsize_resp_cam_slice_7.pointer_reg == 14) ||
                          (valid_bus[8] && u_downsize_resp_cam_slice_8.hazard_reg && u_downsize_resp_cam_slice_8.pointer_reg == 14) ||
                          (valid_bus[9] && u_downsize_resp_cam_slice_9.hazard_reg && u_downsize_resp_cam_slice_9.pointer_reg == 14) ||
                          (valid_bus[10] && u_downsize_resp_cam_slice_10.hazard_reg && u_downsize_resp_cam_slice_10.pointer_reg == 14) ||
                          (valid_bus[11] && u_downsize_resp_cam_slice_11.hazard_reg && u_downsize_resp_cam_slice_11.pointer_reg == 14) ||
                          (valid_bus[12] && u_downsize_resp_cam_slice_12.hazard_reg && u_downsize_resp_cam_slice_12.pointer_reg == 14) ||
                          (valid_bus[13] && u_downsize_resp_cam_slice_13.hazard_reg && u_downsize_resp_cam_slice_13.pointer_reg == 14) ||
                          (valid_bus[15] && u_downsize_resp_cam_slice_15.hazard_reg && u_downsize_resp_cam_slice_15.pointer_reg == 14) ||
                          (valid_bus[16] && u_downsize_resp_cam_slice_16.hazard_reg && u_downsize_resp_cam_slice_16.pointer_reg == 14) ||
                          (valid_bus[17] && u_downsize_resp_cam_slice_17.hazard_reg && u_downsize_resp_cam_slice_17.pointer_reg == 14)))
     );
  
  assign cam_id_reg[15] = u_downsize_resp_cam_slice_15.id_reg;


  assert_implication #(`OVL_FATAL,0,"CAM 15 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_15_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[15] && u_downsize_resp_cam_slice_15.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_resp_cam_slice_15.pointer_reg] && (cam_id_reg[15] == cam_id_reg[u_downsize_resp_cam_slice_15.pointer_reg]))
     );


  assert_implication #(`OVL_FATAL,0,"CAM 15 is last but is pointed to by another valid CAM")
  ovl_cam_15_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[15] && u_downsize_resp_cam_slice_15.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_resp_cam_slice_0.hazard_reg && u_downsize_resp_cam_slice_0.pointer_reg == 15) ||
                          (valid_bus[1] && u_downsize_resp_cam_slice_1.hazard_reg && u_downsize_resp_cam_slice_1.pointer_reg == 15) ||
                          (valid_bus[2] && u_downsize_resp_cam_slice_2.hazard_reg && u_downsize_resp_cam_slice_2.pointer_reg == 15) ||
                          (valid_bus[3] && u_downsize_resp_cam_slice_3.hazard_reg && u_downsize_resp_cam_slice_3.pointer_reg == 15) ||
                          (valid_bus[4] && u_downsize_resp_cam_slice_4.hazard_reg && u_downsize_resp_cam_slice_4.pointer_reg == 15) ||
                          (valid_bus[5] && u_downsize_resp_cam_slice_5.hazard_reg && u_downsize_resp_cam_slice_5.pointer_reg == 15) ||
                          (valid_bus[6] && u_downsize_resp_cam_slice_6.hazard_reg && u_downsize_resp_cam_slice_6.pointer_reg == 15) ||
                          (valid_bus[7] && u_downsize_resp_cam_slice_7.hazard_reg && u_downsize_resp_cam_slice_7.pointer_reg == 15) ||
                          (valid_bus[8] && u_downsize_resp_cam_slice_8.hazard_reg && u_downsize_resp_cam_slice_8.pointer_reg == 15) ||
                          (valid_bus[9] && u_downsize_resp_cam_slice_9.hazard_reg && u_downsize_resp_cam_slice_9.pointer_reg == 15) ||
                          (valid_bus[10] && u_downsize_resp_cam_slice_10.hazard_reg && u_downsize_resp_cam_slice_10.pointer_reg == 15) ||
                          (valid_bus[11] && u_downsize_resp_cam_slice_11.hazard_reg && u_downsize_resp_cam_slice_11.pointer_reg == 15) ||
                          (valid_bus[12] && u_downsize_resp_cam_slice_12.hazard_reg && u_downsize_resp_cam_slice_12.pointer_reg == 15) ||
                          (valid_bus[13] && u_downsize_resp_cam_slice_13.hazard_reg && u_downsize_resp_cam_slice_13.pointer_reg == 15) ||
                          (valid_bus[14] && u_downsize_resp_cam_slice_14.hazard_reg && u_downsize_resp_cam_slice_14.pointer_reg == 15) ||
                          (valid_bus[16] && u_downsize_resp_cam_slice_16.hazard_reg && u_downsize_resp_cam_slice_16.pointer_reg == 15) ||
                          (valid_bus[17] && u_downsize_resp_cam_slice_17.hazard_reg && u_downsize_resp_cam_slice_17.pointer_reg == 15)))
     );
  
  assign cam_id_reg[16] = u_downsize_resp_cam_slice_16.id_reg;


  assert_implication #(`OVL_FATAL,0,"CAM 16 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_16_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[16] && u_downsize_resp_cam_slice_16.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_resp_cam_slice_16.pointer_reg] && (cam_id_reg[16] == cam_id_reg[u_downsize_resp_cam_slice_16.pointer_reg]))
     );


  assert_implication #(`OVL_FATAL,0,"CAM 16 is last but is pointed to by another valid CAM")
  ovl_cam_16_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[16] && u_downsize_resp_cam_slice_16.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_resp_cam_slice_0.hazard_reg && u_downsize_resp_cam_slice_0.pointer_reg == 16) ||
                          (valid_bus[1] && u_downsize_resp_cam_slice_1.hazard_reg && u_downsize_resp_cam_slice_1.pointer_reg == 16) ||
                          (valid_bus[2] && u_downsize_resp_cam_slice_2.hazard_reg && u_downsize_resp_cam_slice_2.pointer_reg == 16) ||
                          (valid_bus[3] && u_downsize_resp_cam_slice_3.hazard_reg && u_downsize_resp_cam_slice_3.pointer_reg == 16) ||
                          (valid_bus[4] && u_downsize_resp_cam_slice_4.hazard_reg && u_downsize_resp_cam_slice_4.pointer_reg == 16) ||
                          (valid_bus[5] && u_downsize_resp_cam_slice_5.hazard_reg && u_downsize_resp_cam_slice_5.pointer_reg == 16) ||
                          (valid_bus[6] && u_downsize_resp_cam_slice_6.hazard_reg && u_downsize_resp_cam_slice_6.pointer_reg == 16) ||
                          (valid_bus[7] && u_downsize_resp_cam_slice_7.hazard_reg && u_downsize_resp_cam_slice_7.pointer_reg == 16) ||
                          (valid_bus[8] && u_downsize_resp_cam_slice_8.hazard_reg && u_downsize_resp_cam_slice_8.pointer_reg == 16) ||
                          (valid_bus[9] && u_downsize_resp_cam_slice_9.hazard_reg && u_downsize_resp_cam_slice_9.pointer_reg == 16) ||
                          (valid_bus[10] && u_downsize_resp_cam_slice_10.hazard_reg && u_downsize_resp_cam_slice_10.pointer_reg == 16) ||
                          (valid_bus[11] && u_downsize_resp_cam_slice_11.hazard_reg && u_downsize_resp_cam_slice_11.pointer_reg == 16) ||
                          (valid_bus[12] && u_downsize_resp_cam_slice_12.hazard_reg && u_downsize_resp_cam_slice_12.pointer_reg == 16) ||
                          (valid_bus[13] && u_downsize_resp_cam_slice_13.hazard_reg && u_downsize_resp_cam_slice_13.pointer_reg == 16) ||
                          (valid_bus[14] && u_downsize_resp_cam_slice_14.hazard_reg && u_downsize_resp_cam_slice_14.pointer_reg == 16) ||
                          (valid_bus[15] && u_downsize_resp_cam_slice_15.hazard_reg && u_downsize_resp_cam_slice_15.pointer_reg == 16) ||
                          (valid_bus[17] && u_downsize_resp_cam_slice_17.hazard_reg && u_downsize_resp_cam_slice_17.pointer_reg == 16)))
     );
  
  assign cam_id_reg[17] = u_downsize_resp_cam_slice_17.id_reg;


  assert_implication #(`OVL_FATAL,0,"CAM 17 is valid but does not point to another valid CAM with the same ID")
  ovl_cam_17_valid_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[17] && u_downsize_resp_cam_slice_17.hazard_reg),
     .consequent_expr  (valid_bus[u_downsize_resp_cam_slice_17.pointer_reg] && (cam_id_reg[17] == cam_id_reg[u_downsize_resp_cam_slice_17.pointer_reg]))
     );


  assert_implication #(`OVL_FATAL,0,"CAM 17 is last but is pointed to by another valid CAM")
  ovl_cam_17_no_last_link
    (
     .clk              (aclk),
     .reset_n          (aresetn),
     .antecedent_expr  (valid_bus[17] && u_downsize_resp_cam_slice_17.last_reg),
     .consequent_expr  (!(
                          (valid_bus[0] && u_downsize_resp_cam_slice_0.hazard_reg && u_downsize_resp_cam_slice_0.pointer_reg == 17) ||
                          (valid_bus[1] && u_downsize_resp_cam_slice_1.hazard_reg && u_downsize_resp_cam_slice_1.pointer_reg == 17) ||
                          (valid_bus[2] && u_downsize_resp_cam_slice_2.hazard_reg && u_downsize_resp_cam_slice_2.pointer_reg == 17) ||
                          (valid_bus[3] && u_downsize_resp_cam_slice_3.hazard_reg && u_downsize_resp_cam_slice_3.pointer_reg == 17) ||
                          (valid_bus[4] && u_downsize_resp_cam_slice_4.hazard_reg && u_downsize_resp_cam_slice_4.pointer_reg == 17) ||
                          (valid_bus[5] && u_downsize_resp_cam_slice_5.hazard_reg && u_downsize_resp_cam_slice_5.pointer_reg == 17) ||
                          (valid_bus[6] && u_downsize_resp_cam_slice_6.hazard_reg && u_downsize_resp_cam_slice_6.pointer_reg == 17) ||
                          (valid_bus[7] && u_downsize_resp_cam_slice_7.hazard_reg && u_downsize_resp_cam_slice_7.pointer_reg == 17) ||
                          (valid_bus[8] && u_downsize_resp_cam_slice_8.hazard_reg && u_downsize_resp_cam_slice_8.pointer_reg == 17) ||
                          (valid_bus[9] && u_downsize_resp_cam_slice_9.hazard_reg && u_downsize_resp_cam_slice_9.pointer_reg == 17) ||
                          (valid_bus[10] && u_downsize_resp_cam_slice_10.hazard_reg && u_downsize_resp_cam_slice_10.pointer_reg == 17) ||
                          (valid_bus[11] && u_downsize_resp_cam_slice_11.hazard_reg && u_downsize_resp_cam_slice_11.pointer_reg == 17) ||
                          (valid_bus[12] && u_downsize_resp_cam_slice_12.hazard_reg && u_downsize_resp_cam_slice_12.pointer_reg == 17) ||
                          (valid_bus[13] && u_downsize_resp_cam_slice_13.hazard_reg && u_downsize_resp_cam_slice_13.pointer_reg == 17) ||
                          (valid_bus[14] && u_downsize_resp_cam_slice_14.hazard_reg && u_downsize_resp_cam_slice_14.pointer_reg == 17) ||
                          (valid_bus[15] && u_downsize_resp_cam_slice_15.hazard_reg && u_downsize_resp_cam_slice_15.pointer_reg == 17) ||
                          (valid_bus[16] && u_downsize_resp_cam_slice_16.hazard_reg && u_downsize_resp_cam_slice_16.pointer_reg == 17)))
     );
  

`endif

`include "nic400_ib_ib4_undefs_sse710_main.v"

endmodule

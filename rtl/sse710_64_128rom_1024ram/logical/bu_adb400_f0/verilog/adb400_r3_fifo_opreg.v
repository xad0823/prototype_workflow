//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
// (C) COPYRIGHT 2011-2016 ARM Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
// Checked In :  2016-01-21 15:26:03 +0000 (Thu, 21 Jan 2016)
// Revision : 205793
//
// Release Information : PL405-r3p0-01rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// File: adb400_r3_fifo_opreg.v
//-----------------------------------------------------------------------------
// Purpose : A FIFO with an output register
//-----------------------------------------------------------------------------

module adb400_r3_fifo_opreg
  #(parameter
    FIFO_WIDTH = 40,
    FIFO_DEPTH = 6
  )
  (
    input  wire                  aclk,
    input  wire                  aresetn,

    input  wire                  push_i,
    input  wire                  pop_i,

    input  wire [FIFO_WIDTH-1:0] push_data_i,
    output wire [FIFO_WIDTH-1:0] pop_data_o,
    
    output wire                  empty_o
  );

  localparam FIFO_DEPTH_INT      = FIFO_DEPTH - 2;

  //-----------------------------------------------------------------------------
  // The output register
  //-----------------------------------------------------------------------------

  // Use a full register slice to ensure complete timing isolation.

  // When things enter and leave the output register
  wire opreg_push;
  wire opreg_pop;

  // Track the occupancy of the output register
  wire opreg_full_n;
  wire opreg_empty_n;

  // Data movement
  wire [FIFO_WIDTH-1:0] opreg_push_data;

  adb400_r3_ful_regd_slice
    #(.PAYLD_WIDTH(FIFO_WIDTH))
  u_opreg
    (
      .aclk (aclk),
      .aresetn (aresetn),
      .valid_src (opreg_push),
      .ready_src (opreg_full_n),
      .payld_src (opreg_push_data),
      .valid_dst (opreg_empty_n),
      .ready_dst (opreg_pop),
      .payld_dst (pop_data_o)
    );

  //-----------------------------------------------------------------------------
  // The core, circular payload FIFO part
  //-----------------------------------------------------------------------------

  genvar i, j, k, l, m;

  generate
    if (FIFO_DEPTH_INT == 0)
      begin : g_FIFO_DEPTH_INT_eq_0
 
        //-----------------------------------------------------------------------------
        // Connect all the bits together
        //-----------------------------------------------------------------------------
       
        assign opreg_push = // There is space in the opreg
                            (opreg_full_n &
                            // Something needs sending somewhere
                             push_i);
       
        assign opreg_pop  = // There is something to pop and ...
                            opreg_empty_n &
                            // ... a transfer is sent
                            pop_i;
       
        assign opreg_push_data = push_data_i;
       
        assign empty_o = ~opreg_empty_n;

      end
    else if (FIFO_DEPTH_INT == 1)
      begin : g_FIFO_DEPTH_INT_eq_1
 
        reg  fifo_occupied;

        //-----------------------------------------------------------------------------
        // Connect all the bits together
        //-----------------------------------------------------------------------------
      
        wire fifo_push    = // Something needs sending somewhere
                            push_i &
                            // There is something already in the FIFO or ...
                            (fifo_occupied |
                             // The opreg has no space
                             ~opreg_full_n);
      
        wire fifo_pop     = // There is something to pop and ...
                            fifo_occupied &
                            // ... there is somewhere to pop it to
                            opreg_full_n;
      
        assign opreg_push = ~fifo_occupied ?
                            // There is space in the opreg
                            (opreg_full_n &
                            // Something needs sending somewhere
                             push_i) :
                            // If the FIFO is not empty, push something from there
                            opreg_full_n;
      
        assign opreg_pop  = // There is something to pop and ...
                            opreg_empty_n &
                            // ... a transfer is sent
                            pop_i;
      
        //-----------------------------------------------------------------------------
        // Track occupancy
        //-----------------------------------------------------------------------------
      
        wire fifo_occupied_nxt = fifo_push | (fifo_occupied & ~fifo_pop);
        wire fifo_occupied_upd_en = fifo_push | fifo_pop;
        always @(posedge aclk or negedge aresetn)
          begin : p_fifo_occupied
            if (!aresetn)
              fifo_occupied <= 1'b0;
            else if (fifo_occupied_upd_en)
              fifo_occupied <= fifo_occupied_nxt;
          end
        reg  [FIFO_WIDTH-1:0] fifo_q;

        wire fifo_upd_pl_en = fifo_push & ~fifo_pop;

        always @(posedge aclk)
          begin : p_fifo_q_pl
            if (fifo_upd_pl_en)
              fifo_q <= push_data_i;
          end

        assign opreg_push_data = fifo_pop ? fifo_q : push_data_i;
      
        assign empty_o = ~fifo_occupied & ~opreg_empty_n;

      end
    else
      begin : g_FIFO_DEPTH_INT_gt_1

        reg  fifo_empty_q;

        wire [FIFO_WIDTH-1:0] fifo_pop_data;

        //-----------------------------------------------------------------------------
        // Connect all the bits together
        //-----------------------------------------------------------------------------
      
        wire fifo_push    = // Something needs sending somewhere
                            push_i &
                            // There is something already in the FIFO or ...
                            (~fifo_empty_q |
                             // The opreg has no space
                             ~opreg_full_n);
      
        wire fifo_pop     = // There is something to pop and ...
                            ~fifo_empty_q &
                            // ... there is somewhere to pop it to
                            opreg_full_n;
      
        assign opreg_push = fifo_empty_q ?
                            // There is space in the opreg
                            (opreg_full_n &
                            // Something needs sending somewhere
                             push_i) :
                            // If the FIFO is not empty, push something from there
                            opreg_full_n;
      
        assign opreg_pop  = // There is something to pop and ...
                            opreg_empty_n &
                            // ... a transfer is sent
                            pop_i;
      
        assign opreg_push_data = fifo_pop ? fifo_pop_data : push_data_i;
      
        assign empty_o = fifo_empty_q & ~opreg_empty_n;
      

        // Reset wflag to first entry
        // Update on push
        reg  [FIFO_DEPTH_INT-1:0] wflag; // 1-hot write pointer
        wire [FIFO_DEPTH_INT-1:0] wflag_nxt = {wflag[0 +: FIFO_DEPTH_INT-1],wflag[FIFO_DEPTH_INT-1]}; // shift up
        wire                      wflag_upd_en = fifo_push;
        always @(posedge aclk or negedge aresetn)
        begin : update_wflag
          if (!aresetn)
            wflag <= {{FIFO_DEPTH_INT-1{1'b0}},1'b1};
          else if (wflag_upd_en)
            wflag <= wflag_nxt;// shift up
        end
      
        // Reset rflag to first entry
        // Update on pop
        reg  [FIFO_DEPTH_INT-1:0] rflag;// 1-hot read pointer
        wire [FIFO_DEPTH_INT-1:0] rflag_nxt = {rflag[0 +: FIFO_DEPTH_INT-1],rflag[FIFO_DEPTH_INT-1]};// shift up
        wire                      rflag_upd_en = fifo_pop;
        always @(posedge aclk or negedge aresetn)
        begin : update_rflag
          if (!aresetn)
            rflag <= {{FIFO_DEPTH_INT-1{1'b0}},1'b1};
          else if (rflag_upd_en)
            rflag <= rflag_nxt;// shift up
        end
      
        // Going empty if fifo_pop & ~fifo_push (so emptying) and pointers going equal.
        wire fifo_empty_nxt    = ~fifo_push &  fifo_pop & (rflag_nxt==wflag);
        wire fifo_empty_upd_en = (fifo_push & fifo_empty_q) | fifo_empty_nxt;
        always @(posedge aclk or negedge aresetn)
        begin : update_empty
          if (!aresetn)
            fifo_empty_q <= 1'b1;
          else if (fifo_empty_upd_en)
            fifo_empty_q <= fifo_empty_nxt;
        end
      
// ACS_off UNRESET_REGISTER Validity is explicitly indicated
        reg  [FIFO_WIDTH-1:0]     fifo_q   [FIFO_DEPTH_INT-1:0]; // array of payloads

        wire [FIFO_DEPTH_INT-1:0] fifo_upd_pl_en; // update enable for the non-qv part

        for (k=0;k<FIFO_DEPTH_INT;k=k+1)
          begin : g_fifo_q_pl
            assign fifo_upd_pl_en[k] = (fifo_push & wflag[k]) &
                                       ~(fifo_pop & rflag[k]);
            // FIFO contents needs no reset as always written before reading.
            always @(posedge aclk)
              begin : update_fifo_pl_no_reset
                if (fifo_upd_pl_en[k])
// ACS_off UNRESETTABLE_REGISTER CDC_END Payload rather than control ; Where this register exists, it is an expected CDC endpoint.
                  fifo_q[k] <= push_data_i;
              end

          end

        // Rotate the fifo 2D array fifo into fifo_q_t so that a line of fifo_q_t is the same
        // as a column of fifo_q. This does not add any storage, it is done to enable
        // a bit column of fifo_q to be accessed in a way that verilog does not permit.
        wire [FIFO_DEPTH_INT-1:0] fifo_q_t [FIFO_WIDTH-1:0];     // same array accessed by bit address
        for (i=0;i<FIFO_DEPTH_INT;i=i+1)
          begin : g_fifo_remap_outer
            for (j=0;j<FIFO_WIDTH;j=j+1)
            begin : g_fifo_remap_inner
              assign fifo_q_t[j][i] = fifo_q[i][j];
            end
          end

        // Use rflag 1hot vector as an enable term when access storage array:
        // For each bit in the output word we AND the corresponding bit from each entry with rflag.
        // This enables only the entry indicated by rflag.
        // The result is then ORed together to generate one output bit.
        for (l=0;l<FIFO_WIDTH;l=l+1)
          begin : g_drive_pop_data
            assign fifo_pop_data[l] = |(rflag & fifo_q_t[l]);
          end
      
      end
  endgenerate     

endmodule

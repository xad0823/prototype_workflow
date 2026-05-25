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
// File: adb400_r3_qv_update_fifo.v
//-----------------------------------------------------------------------------
// Purpose : A FIFO to keep QVs updated when higher priority things are behind
//           them.
//-----------------------------------------------------------------------------

module adb400_r3_qv_update_fifo
  #(parameter
    FIFO_DEPTH = 6,
    FIFO_WIDTH = 4
  )
  (
    input  wire       aclk,
    input  wire       aresetn,

    input  wire       push_i,
    input  wire       pop_i,
    input  wire       update_i,

    input  wire [FIFO_WIDTH-1:0] push_data_i,
    output wire [FIFO_WIDTH-1:0] pop_data_o,
    
    output wire       empty_o
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

  //----------------------------------------------------------------------------
  // internal signals declarations
  //----------------------------------------------------------------------------
  reg        wr_sel;    // select receiver of opreg_push_data
  wire [1:0] wr_valid;  // valid to each payload register
  // NOTE: no wr_ready needed as is implicit in there being a non-occupied slot

  reg        rd_sel;    // select driver for pop_data_o
  wire [1:0] rd_ready;  // ready to each payload register
  reg  [1:0] rd_valid;  // valid content of the payload registers

  //----------------------------------------------------------------------------
  // Destination of opreg_push depends on wr_sel
  //----------------------------------------------------------------------------

  assign wr_valid[0] = (~wr_sel & opreg_push);
  assign wr_valid[1] = ( wr_sel & opreg_push);

  //----------------------------------------------------------------------------
  // Destination of opreg_pop depends on rd_sel
  //----------------------------------------------------------------------------

  assign rd_ready[0] = ~rd_sel & opreg_pop;
  assign rd_ready[1] =  rd_sel & opreg_pop;

  //----------------------------------------------------------------------------
  // Select which register to write to
  //----------------------------------------------------------------------------

  wire wr_sel_upd_en = opreg_push & opreg_full_n;
  always @(posedge aclk or negedge aresetn)
  begin : p_wr_sel
    if (! aresetn)
      wr_sel <= 1'b0;
    else if (wr_sel_upd_en)
      wr_sel <= ~wr_sel;
  end

  //----------------------------------------------------------------------------
  // Enable to write into payload registers
  //----------------------------------------------------------------------------

  reg  [FIFO_WIDTH-1:0]  payld [1:0];  // payload storage register

  // Which payloads can be updated
  wire [1:0] opreg_push_data_gt_opreg_payld;
  assign opreg_push_data_gt_opreg_payld[0] = (opreg_push_data > payld[0]);
  assign opreg_push_data_gt_opreg_payld[1] = (opreg_push_data > payld[1]);

  wire [1:0] wr_en = // Can write into it if selected and not already full.
                     (wr_valid & ~rd_valid) |
                     // Or if updating, it is occupied and the new value is greater
                     ((push_i || update_i) ? (rd_valid & opreg_push_data_gt_opreg_payld) : 2'b00);

  //----------------------------------------------------------------------------
  // Store the payload
  //----------------------------------------------------------------------------

  // NOTE: need to be reset as the value is used before any writes occur

  always @(posedge aclk or negedge aresetn)
  begin : p_payld_0
    if (! aresetn)
      payld[0] <= {FIFO_WIDTH{1'b0}};
    else if (wr_en[0])
      payld[0] <= opreg_push_data;
  end

  always @(posedge aclk or negedge aresetn)
  begin : p_payld_1
    if (! aresetn)
      payld[1] <= {FIFO_WIDTH{1'b0}};
    else if (wr_en[1])
      payld[1] <= opreg_push_data;
  end

  //----------------------------------------------------------------------------
  // Track occupancy of the payload registers
  //----------------------------------------------------------------------------

  // If the payload register is written, or is occupied and not emptied it will
  // be valid next.
  wire[1:0] rd_valid_nxt = ((~rd_valid & wr_en) | (rd_valid & ~rd_ready));

  always @(posedge aclk or negedge aresetn)
  begin : p_rd_valid_0
    if (! aresetn)
      rd_valid[0] <= 1'b0;
    else
      rd_valid[0] <= rd_valid_nxt[0];
  end

  always @(posedge aclk or negedge aresetn)
  begin : p_rd_valid_1
    if (! aresetn)
      rd_valid[1] <= 1'b0;
    else
      rd_valid[1] <= rd_valid_nxt[1];
  end

  //----------------------------------------------------------------------------
  // Select which register to read from
  //----------------------------------------------------------------------------

  wire rd_sel_upd_en = |(rd_valid & rd_ready);

  always @(posedge aclk or negedge aresetn)
  begin : p_rd_sel
    if (! aresetn)
      rd_sel <= 1'b0;
    else if (rd_sel_upd_en)
      rd_sel <= ~rd_sel;
  end

  //----------------------------------------------------------------------------
  // Drive payload output
  //----------------------------------------------------------------------------

  // If rd_sel driven high, drive the contents of payld[1] onto the output.
  // If rd_sel not driven high, drive the contents of payld[0] onto the output.
  assign pop_data_o = rd_sel ? payld[1] : payld[0];

  //----------------------------------------------------------------------------
  // Interface handshake outputs
  //----------------------------------------------------------------------------

  // opreg_full_n when one of the internal registers is not occupied
  assign opreg_full_n = |(~rd_valid);

  // opreg_empty_n when one of the internal registers is occupied
  assign opreg_empty_n = |( rd_valid);


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
       
        assign opreg_push = // there is space
                            opreg_full_n &
                            // unless the opreg is empty and there is a simultaneous pop
                            ~(pop_i & ~opreg_empty_n) &
                            // Something is arriving
                            push_i;

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
      
        assign opreg_push = // there is space
                            opreg_full_n &
                            // unless the opreg is empty and there is a simultaneous pop
                            ~(pop_i & ~opreg_empty_n) &
                            // something can move from the FIFO or
                            (fifo_occupied |
                            // Something is arriving
                             push_i);

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
            if (! aresetn)
              fifo_occupied <= 1'b0;
            else if (fifo_occupied_upd_en)
              fifo_occupied <= fifo_occupied_nxt;
          end

        reg  [FIFO_WIDTH-1:0] fifo_q;

        // FIFO *payload* contents needs no reset as always written before reading.
        wire fifo_src_qv_gt_reg = (push_data_i > fifo_q);
        wire fifo_upd_pl_en = (fifo_push |
                               (update_i & fifo_occupied & fifo_src_qv_gt_reg)) &
                              ~fifo_pop;

        always @(posedge aclk)
          begin : p_fifo_q_pl
            if (fifo_upd_pl_en)
              fifo_q <= push_data_i;
          end

        assign opreg_push_data = 
                  (fifo_pop & ~(update_i & fifo_occupied & fifo_src_qv_gt_reg)) ?
                  fifo_q :
                  push_data_i;
      
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
      
        assign opreg_push = // there is space
                            opreg_full_n &
                            // unless the opreg is empty and there is a simultaneous pop
                            ~(pop_i & ~opreg_empty_n) &
                            // something can move from the FIFO or
                            (~fifo_empty_q |
                            // Something is arriving
                             push_i);
      
        assign opreg_pop  = // There is something to pop and ...
                            opreg_empty_n &
                            // ... a transfer is sent
                            pop_i;
      
        wire fifo_src_qv_gt_fifo_pop_data = (push_data_i > fifo_pop_data);
        assign opreg_push_data = 
                  (fifo_pop && ~(update_i && ~fifo_empty_q && fifo_src_qv_gt_fifo_pop_data)) ?
                  fifo_pop_data :
                  push_data_i;
      
        assign empty_o = fifo_empty_q & ~opreg_empty_n;
      

        // Reset wflag to first entry
        // Update on push
        reg  [FIFO_DEPTH_INT-1:0] wflag; // 1-hot write pointer
        wire [FIFO_DEPTH_INT-1:0] wflag_nxt = {wflag[0 +: FIFO_DEPTH_INT-1],wflag[FIFO_DEPTH_INT-1]}; // shift up
        wire                      wflag_upd_en = fifo_push;
        always @(posedge aclk or negedge aresetn)
        begin : update_wflag
          if (! aresetn)
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
          if (! aresetn)
            rflag <= {{FIFO_DEPTH_INT-1{1'b0}},1'b1};
          else if (rflag_upd_en)
            rflag <= rflag_nxt;// shift up
        end
      
        //-----------------------------------------------------------------------------
        // Track which slots are occupied for finding the highest QoS value
        //-----------------------------------------------------------------------------
      
        reg  [FIFO_DEPTH_INT-1:0] fifo_occupied;
        wire [FIFO_DEPTH_INT-1:0] fifo_occupied_nxt = (fifo_occupied |
                                                       (wflag_upd_en ? wflag :  {FIFO_DEPTH_INT{1'b0}})) &
                                                      ~(rflag_upd_en ? rflag :  {FIFO_DEPTH_INT{1'b0}});
        wire                      fifo_occupied_upd_en = wflag_upd_en | rflag_upd_en;
        always @(posedge aclk or negedge aresetn)
          begin : p_fifo_occupied
            if (! aresetn)
              fifo_occupied <= {FIFO_DEPTH_INT{1'b0}};
            else if (fifo_occupied_upd_en)
              fifo_occupied <= fifo_occupied_nxt;
          end


        // Going empty if fifo_pop & ~fifo_push (so emptying) and pointers going equal.
        wire fifo_empty_nxt    = ~fifo_push &  fifo_pop & (rflag_nxt==wflag);
        wire fifo_empty_upd_en = (fifo_push & fifo_empty_q) | fifo_empty_nxt;
        always @(posedge aclk or negedge aresetn)
        begin : update_empty
          if (! aresetn)
            fifo_empty_q <= 1'b1;
          else if (fifo_empty_upd_en)
            fifo_empty_q <= fifo_empty_nxt;
        end
      
// ACS_off UNRESET_REGISTER Validity is explicitly indicated
        reg  [FIFO_WIDTH-1:0]     fifo_q   [FIFO_DEPTH_INT-1:0]; // array of payloads

        wire [FIFO_DEPTH_INT-1:0] fifo_src_qv_gt_reg; // the new qv is greater than what is in the slot
        wire [FIFO_DEPTH_INT-1:0] fifo_upd_pl_en; // update enable for the non-qv part

        for (k=0;k<FIFO_DEPTH_INT;k=k+1)
          begin : g_fifo_q_pl
            assign fifo_src_qv_gt_reg[k] = (push_data_i > fifo_q[k]);
            assign fifo_upd_pl_en[k] = ((fifo_push & wflag[k]) |
                                        ((push_i | update_i) & fifo_occupied[k] & fifo_src_qv_gt_reg[k])) &
                                       ~(fifo_pop & rflag[k]);
            // FIFO contents needs no reset as always written before reading.
            always @(posedge aclk)
              begin : update_fifo_pl_no_reset
                if (fifo_upd_pl_en[k])
// ACS_off UNRESETTABLE_REGISTER Payload rather than control
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

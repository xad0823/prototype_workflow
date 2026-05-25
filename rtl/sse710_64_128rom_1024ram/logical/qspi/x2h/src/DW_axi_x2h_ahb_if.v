// ---------------------------------------------------------------------
//
// ------------------------------------------------------------------------------
// 
// Copyright 2005 - 2022 Synopsys, INC.
// 
// This Synopsys IP and all associated documentation are proprietary to
// Synopsys, Inc. and may only be used pursuant to the terms and conditions of a
// written license agreement with Synopsys, Inc. All other use, reproduction,
// modification, or distribution of the Synopsys IP or the associated
// documentation is strictly prohibited.
// Inclusivity & Diversity - Visit SolvNetPlus to read the "Synopsys Statement on
//            Inclusivity and Diversity" (Refer to article 000036315 at
//                        https://solvnetplus.synopsys.com)
// 
// Component Name   : DW_axi_x2h
// Component Version: 2.05a
// Release Type     : GA
// Build ID         : 13.18.16.11
// ------------------------------------------------------------------------------

// 
// Release version :  2.05a
// File Version     :        $Revision: #15 $ 
// Revision: $Id: //dwh/DW_ocb/DW_axi_x2h/axi_dev_br/src/DW_axi_x2h_ahb_if.v#15 $
//
// -------------------------------------------------------------------------
// Filename    : DW_axi_x2h_ahb_if.v
//
// Description : Final interface to AHB. Gets told what to do by the CGEN
//               (via the CPIPE, for timing), and deals with AHB.
//
//               This module can be configured for either full AHB or AHB-Lite
//               operation (this is done by "ifdef X2H_AHB_LITE_TRUE"
//               statements.)
//
//               This IF module writes to the RDFIFO.
//
//               However, this IF module does NOT interface to the WDFIFO or
//               or the Write Response Buffer. (The CGEN module does instead.)
//-----------------------------------------------------------------------------

`include "DW_axi_x2h_all_includes.vh"

module DW_axi_x2h_ahb_if (

// Inputs

   clk, 
                          rst_n,
                          cpipe_if_valid,
                          cpipe_if_ahb_haddr, 
                          cpipe_if_ahb_hwrite,
                          cpipe_if_ahb_hsize, 
                          cpipe_if_ahb_hburst,
                          cpipe_if_ahb_hprot, 
                          cpipe_if_ahb_hwdata,
                          cpipe_if_axi_last,
                          cpipe_if_rdfifo_req, 
                          cpipe_if_axi_id,
                          cpipe_if_axi_size,
                          mhready, 
                          mhresp, 
                          mhrdata,
                          hrdata_push_cnt,
                          // Outputs
                          if_cpipe_ready, 
                          if_cpipe_xfr_pending,
                          if_cgen_wr_err, 
                          mhaddr, 
                          mhsize, 
                          mhtrans,
                          mhburst, 
                          mhwrite, 
                          mhprot, 
                          mhwdata,
                          hrid_int, 
                          hrdata_int, 
                          hrstatus_int, 
                          hrlast_int, 
                          push_data_int_n
                          );


   input                              clk;
   input                              rst_n;

   // Interface to CGEN (mostly via CPIPE)

   input                              cpipe_if_valid;

   output                             if_cpipe_ready;


   input    [`X2H_CMD_ADDR_WIDTH-1:0] cpipe_if_ahb_haddr;
   input                              cpipe_if_ahb_hwrite;
   input                        [2:0] cpipe_if_ahb_hsize;
   input                        [2:0] cpipe_if_ahb_hburst;
   input                        [3:0] cpipe_if_ahb_hprot;
   input    [`X2H_AHB_DATA_WIDTH-1:0] cpipe_if_ahb_hwdata;

   input                              cpipe_if_axi_last;
   input                        [4:0] cpipe_if_rdfifo_req;

   input      [`X2H_AXI_ID_WIDTH-1:0] cpipe_if_axi_id;
   input                        [2:0] cpipe_if_axi_size;

   output                             if_cpipe_xfr_pending;
   output                             if_cgen_wr_err;




   // The AHB signals


   input                              mhready;
   input       [`X2H_HRESP_WIDTH-1:0] mhresp;
   input    [`X2H_AHB_DATA_WIDTH-1:0] mhrdata;




   output   [`X2H_AHB_ADDR_WIDTH-1:0] mhaddr;
   output                       [2:0] mhsize;
   output                       [1:0] mhtrans;
   output                       [2:0] mhburst;
   output                             mhwrite;

   output                       [3:0] mhprot;
   output   [`X2H_AHB_DATA_WIDTH-1:0] mhwdata;


   // Interface to the RDFIFO

   input                        [7:0] hrdata_push_cnt;

   output     [`X2H_AXI_ID_WIDTH-1:0] hrid_int;
   output   [`X2H_AXI_DATA_WIDTH-1:0] hrdata_int;
   output                             hrlast_int;
   output                       [1:0] hrstatus_int;

   output                             push_data_int_n;





   // THESE ARE FLIP-FLOPS:

   reg                       [1:0] if_state;
   reg                       [3:0] burst_rem;

   reg   [`X2H_CMD_ADDR_WIDTH-1:0] mhaddr_reg;
   reg                       [2:0] mhsize;
   reg                       [1:0] mhtrans;
   reg                       [2:0] mhburst;
   reg                             mhwrite;
   reg                       [3:0] mhprot;

   reg   [`X2H_AHB_DATA_WIDTH-1:0] aphase_wdata;
   reg                             aphase_write;
   reg                             aphase_read;
   reg                             aphase_push_read;
   reg     [`X2H_AXI_ID_WIDTH-1:0] aphase_axi_id;
   reg                             aphase_axi_last;
   reg                       [2:0] dphase_size;
   reg     [`X2H_AXI_ID_WIDTH-1:0] dphase_axi_id;
   reg                             pushed;
   reg     [`X2H_AXI_ID_WIDTH-1:0] new_aphase_axi_id;


   reg   [`X2H_AHB_DATA_WIDTH-1:0] mhwdata;
   reg                             dphase_write;
   reg                             dphase_read;
   reg                             dphase_push_read;
   reg                             dphase_axi_last;

   reg                             push_rdfifo;
   reg     [`X2H_AXI_ID_WIDTH-1:0] hrid_int;
   reg   [`X2H_AXI_DATA_WIDTH-1:0] hrdata_int;
   reg                       [1:0] hrstatus_int;
   reg                             hrlast_int;


   // These will be flip-flops if "X2H_PASS_LOCK" is set




   // These are NOT flip-flops:

   wire   [`X2H_AHB_ADDR_WIDTH-1:0] mhaddr;

   reg                       [1:0] new_if_state;
   reg                       [3:0] new_burst_rem;

   reg                             adv_cgen_if_myhready;

   reg                       [1:0] pending_rdfifo_push_count;
   reg                       [8:0] adjusted_rdfifo_count;
   reg                             rdfifo_has_16;
   reg                             rdfifo_has_8;
   reg                             rdfifo_has_4;
   reg                             rdfifo_has_2;
   reg                             rdfifo_has_1;
   reg                             rdfifo_ok_to_start;

   reg                       [9:0] next_baddr;
   reg                             next_baddr_read_push;
   reg                             next_haddr_read_push;


   reg   [`X2H_CMD_ADDR_WIDTH-1:0] new_mhaddr_reg;
   reg                       [2:0] new_mhsize;
   reg                       [1:0] new_mhtrans;
   reg                       [2:0] new_mhburst;
   reg                             new_mhwrite;
   reg                       [3:0] new_mhprot;
   reg   [`X2H_AHB_DATA_WIDTH-1:0] new_aphase_wdata;
   reg                             new_aphase_write;
   reg                             new_aphase_read;
   reg                             new_aphase_push_read;
   reg                             new_aphase_axi_last;




   wire  [`X2H_AXI_DATA_WIDTH-1:0] new_hrdata_int;
   wire                      [1:0] new_hrstatus_int;


   // In AHB-Lite mode, only a few bits of address are carried
   // into dphase

   wire                      [4:0] dphase_addr_in;
   reg                       [4:0] dphase_addr;



   // Note: these RETRY-associated wires do stay around for
   // AHB-Lite, but they all get tied to 0

   wire                            my_retry;
   wire                            retry_active;






   parameter  ST_IF_NEW_CGEN       = 2'b00;
   parameter  ST_IF_AFTER_BURST    = 2'b01;
   parameter  ST_IF_BURST          = 2'b10;





////////////////////////////////////////////////////////
// ARBITRATION




////////////////////////////////////////////////////////
// MHTRANS and MHBURST
   always @(posedge clk or negedge rst_n)
     if ( !rst_n )
       mhtrans            <= `X2H_AHB_HTRANS_IDLE;
     else
       begin
         if (my_retry)
           mhtrans            <= `X2H_AHB_HTRANS_IDLE;
         else
         if (~retry_active & mhready)
           mhtrans            <= new_mhtrans;
       end

   always @(posedge clk or negedge rst_n)
     if ( !rst_n )
       mhburst            <= `X2H_AHB_HBURST_SINGLE;
     else
       begin
         if (~retry_active & mhready)
           mhburst            <= new_mhburst;
       end


////////////////////////////////////////////////////////
// "ACTION BITS"

   always @(posedge clk or negedge rst_n)
     if ( !rst_n )
       begin
         aphase_write       <= 1'b0;
         aphase_read        <= 1'b0;
         aphase_push_read   <= 1'b0;
       end
     else
       begin
         if (my_retry)
           begin
             aphase_write       <= 1'b0;
             aphase_read        <= 1'b0;
             aphase_push_read   <= 1'b0;
           end
         else if (~retry_active & mhready)
           begin
             aphase_write       <= new_aphase_write;
             aphase_read        <= new_aphase_read;
             aphase_push_read   <= new_aphase_push_read;
           end
       end


   always @(posedge clk or negedge rst_n)
     if ( !rst_n )
       begin
         dphase_write       <= 1'b0;
         dphase_read        <= 1'b0;
         dphase_push_read   <= 1'b0;
       end
     else
       begin
         if (my_retry)
           begin
             dphase_write       <= 1'b0;
             dphase_read        <= 1'b0;
             dphase_push_read   <= 1'b0;
           end
         else if (mhready)
           begin
             dphase_write       <= aphase_write;
             dphase_read        <= aphase_read;
             dphase_push_read   <= aphase_push_read;
           end
       end


////////////////////////////////////////////////////////
// ADDRESS, SIZE, "PROT", etc
// those characteristics of each transfer which do
// NOT change even if the transfer gets RETRY

   always @(posedge clk or negedge rst_n)
     if ( !rst_n )
       begin
         mhaddr_reg         <= {`X2H_CMD_ADDR_WIDTH{1'b0}};
         mhsize             <= 3'b000;
         mhwrite            <= 1'b0;
         mhprot             <= 4'b0000;
         aphase_axi_id      <= {`X2H_AXI_ID_WIDTH{1'b0}};
         aphase_axi_last    <= 1'b0;
     end
     else
       begin
         if (~retry_active & mhready)
           begin
             mhaddr_reg         <= new_mhaddr_reg;
             mhsize             <= new_mhsize;
             mhwrite            <= new_mhwrite;
             mhprot             <= new_mhprot;
             aphase_axi_id      <= new_aphase_axi_id;
             aphase_axi_last    <= new_aphase_axi_last;
           end
       end


   always @(posedge clk or negedge rst_n)
     if ( !rst_n )
       begin
         dphase_addr       <= 5'b00000;
         dphase_size       <= 3'b000;
         dphase_axi_id     <= {`X2H_AXI_ID_WIDTH{1'b0}};
         dphase_axi_last   <= 1'b0;
       end
     else
       begin
         if ((~retry_active) & mhready)
           begin
             dphase_addr       <= dphase_addr_in;
             dphase_size       <= mhsize;
             dphase_axi_id     <= aphase_axi_id;
             dphase_axi_last   <= aphase_axi_last;
           end
       end



   // In AHB-Lite mode, don't need to keep MHPROT, MHWRITE, OTRANS
   // in data phase. And, only need to keep 5 bits of MHADDR

   assign  dphase_addr_in     = mhaddr_reg[4:0];

//   assign  dphase_addr_fb     = {`X2H_CMD_ADDR_WIDTH{1'b0}};
//   assign  dphase_mhwrite_fb  = 1'b0;
//   assign  dphase_mhprot_fb   = 4'b0000;




   // mhaddr_reg is only 64-bit if the entire path is 64-bit.
   // Otherwise, it's 32-bit but might need to be extended
   // for AHB
//   always @(mhaddr_reg)
//     begin
//       if ( (`X2H_CMD_ADDR_WIDTH == 32) & (`X2H_AXI_ADDR_WIDTH == 64) )
//         mhaddr  = {32'b0, mhaddr_reg};
//       else
//         mhaddr  = mhaddr_reg;
//     end

    assign mhaddr = mhaddr_reg;
/*
   always @(mhaddr_reg)
     begin
       if (`X2H_AHB_ADDR_WIDTH == 64)
         begin
           if (`X2H_AXI_ADDR_WIDTH == 64)
             mhaddr  =  mhaddr_reg;
           else
             mhaddr  = {{(64-`X2H_AXI_ADDR_WIDTH){1'b0}},mhaddr_reg};
         end
       else
         mhaddr  = mhaddr_reg;
     end
*/

////////////////////////////////////////////////////////
// WRITE DATA

   always @(posedge clk or negedge rst_n)
     if ( !rst_n )
       aphase_wdata       <= {`X2H_AHB_DATA_WIDTH{1'b0}};
     else
       begin
         if (~retry_active & mhready)
           aphase_wdata       <= new_aphase_wdata;
       end

   always @(posedge clk or negedge rst_n)
     if ( !rst_n )
       mhwdata           <= {`X2H_AHB_DATA_WIDTH{1'b0}};
     else
       begin
         if (mhready)
           mhwdata           <= aphase_wdata;
       end


////////////////////////////////////////////////////////
// REGISTERS for "main" state machine
// The IF state and etc get updated when the main state
// machine successfully puts something into address phase
// but does NOT advance when "mhgrant & mhready" is not
// true, or when the bridge is dealing with a RETRY
   always @(posedge clk or negedge rst_n)
     if ( !rst_n )
       begin
         if_state           <= ST_IF_NEW_CGEN;
         burst_rem          <= 4'b0000;
       end

     else
       begin
         if (mhready & (~my_retry) & (~retry_active))
           begin
             if_state           <= new_if_state;
             burst_rem          <= new_burst_rem;
           end
       end


// The "adv_cgen_if_myhready" also gets sent to actually advance the CGEN
// under the same conditions that the IF state and etc advance

assign if_cpipe_ready   = adv_cgen_if_myhready & mhready
                          & (~my_retry) & (~retry_active);



////////////////////////////////////////////////////////
// LOGIC for the main state machine. This figures out
// the next "new_" transfer to put into the address
// phase

always @(*)

  begin : next_move_PROC

    new_if_state          = if_state;
    new_burst_rem         = burst_rem;


    new_mhaddr_reg        = mhaddr_reg;
    new_mhsize            = mhsize;
    new_mhburst           = mhburst;
    new_mhwrite           = mhwrite;
    new_mhprot            = mhprot;
    new_aphase_wdata      = aphase_wdata;

    new_aphase_write      = 1'b0;
    new_aphase_read       = 1'b0;
    new_aphase_push_read  = 1'b0;

    new_aphase_axi_id     = aphase_axi_id;
    new_aphase_axi_last   = 1'b0;

    adv_cgen_if_myhready  = 1'b0;



    pending_rdfifo_push_count =   {1'b0, aphase_push_read}
                                + {1'b0, dphase_push_read}
                                + {1'b0, push_rdfifo};

    // The TRUE count of what's in the read FIFO, including any reads
    // launched to AHB that aren't yet reflected in the FIFO's count

    adjusted_rdfifo_count = {1'b0, hrdata_push_cnt}
                            + {7'b000000, pending_rdfifo_push_count};


    // Is there enough FIFO space to START a proposed read command?
    //
    // The CGEN sends warning about how much space is required
    // (because of downshifting, it's not the same as the burst
    // length). The bad news is that this indication (cpipe_if_rdfifo_req)
    // comes hideously late. The good news is, it will always be a
    // power of 2. So, can kind of pre-analyze how many spaces are
    // available and then quickly combine that with cpipe_if_rdfifo_req

    if (   (`X2H_READ_BUFFER_DEPTH > 15)
         & (adjusted_rdfifo_count < (`X2H_READ_BUFFER_DEPTH - 15)) )
      rdfifo_has_16  = 1'b1;
    else
      rdfifo_has_16  = 1'b0;

    if (   (`X2H_READ_BUFFER_DEPTH > 7)
         & (adjusted_rdfifo_count < (`X2H_READ_BUFFER_DEPTH - 7)) )
      rdfifo_has_8   = 1'b1;
    else
      rdfifo_has_8   = 1'b0;

    if (   (`X2H_READ_BUFFER_DEPTH > 3)
         & (adjusted_rdfifo_count < (`X2H_READ_BUFFER_DEPTH - 3)) )
      rdfifo_has_4   = 1'b1;
    else
      rdfifo_has_4   = 1'b0;

    if (   (`X2H_READ_BUFFER_DEPTH > 1)
         & (adjusted_rdfifo_count < (`X2H_READ_BUFFER_DEPTH - 1)) )
      rdfifo_has_2   = 1'b1;
    else
      rdfifo_has_2   = 1'b0;

    if (adjusted_rdfifo_count < `X2H_READ_BUFFER_DEPTH)
      rdfifo_has_1   = 1'b1;
    else
      rdfifo_has_1   = 1'b0;

    if ( cpipe_if_rdfifo_req[4] & (~rdfifo_has_16)
         | cpipe_if_rdfifo_req[3] & (~rdfifo_has_8)
         | cpipe_if_rdfifo_req[2] & (~rdfifo_has_4)
         | cpipe_if_rdfifo_req[1] & (~rdfifo_has_2)
         | cpipe_if_rdfifo_req[0] & (~rdfifo_has_1) )

      rdfifo_ok_to_start    = 1'b0;

    else
      rdfifo_ok_to_start    = 1'b1;



    // For use during bursts, figure out the next burst address,
    // and whether or not it's going to involve a RDFIFO push

    next_baddr  = mhaddr_reg[9:0] + (10'd1 << mhsize);

    next_baddr_read_push  = nxt_rd_push_function( next_baddr[4:0],
                                                  mhsize,
                                                  cpipe_if_axi_size );

    next_haddr_read_push  = nxt_rd_push_function( cpipe_if_ahb_haddr[4:0],
                                                  cpipe_if_ahb_hsize,
                                                  cpipe_if_axi_size );
    case (if_state)

      ST_IF_NEW_CGEN,
      ST_IF_AFTER_BURST :

        begin
          new_if_state          = ST_IF_NEW_CGEN;

          if ( cpipe_if_valid
               & (cpipe_if_ahb_hwrite | rdfifo_ok_to_start))

            begin
              // Got a valid command. Either it's a WRITE (which carries
              // the data with it), or the RDFIFO is OK to do a read.
              // In either case, get started.

              if (cpipe_if_ahb_hburst == `X2H_AHB_HBURST_SINGLE)

                begin
                  // Processing for commands that come from CGEN as
                  // singles. All writes and some reads fall into this
                  // category. THIS BLOCK determines whether to put them
                  // on AHB as SINGLES or with an undefined-length INCR


                    begin
                      new_mhtrans           = `X2H_AHB_HTRANS_NONSEQ;
                      new_mhburst           = `X2H_AHB_HBURST_SINGLE;
                    end

                  // This single might be the "axi_last". Also,
                  // it's time to tell the CGEN we are taking this command.

                  new_aphase_axi_last   = cpipe_if_axi_last;
                  adv_cgen_if_myhready  = 1'b1;
                end

              else  // cpipe_if_ahb_hburst is not "`X2H_AHB_HBURST_SINGLE"

                begin
                  // But, STILL inside the clause where there is a new, valid
                  // command from CGEN. It's not single, so must be a burst read.
                  // Have already checked that the RDFIFO is good to go.


                  new_mhtrans           = `X2H_AHB_HTRANS_NONSEQ;
                  new_mhburst           = cpipe_if_ahb_hburst;

                  if (cpipe_if_ahb_hburst == `X2H_AHB_HBURST_INCR16)
                    new_burst_rem         = 4'd15;
                  else if (cpipe_if_ahb_hburst == `X2H_AHB_HBURST_INCR8)
                    new_burst_rem         = 4'd7;
                  else if (cpipe_if_ahb_hburst == `X2H_AHB_HBURST_INCR4)
                    new_burst_rem         = 4'd3;

                  new_if_state          = ST_IF_BURST;
                end


              // Do this the same on any ready-to-go command, whether it's
              // a single or a burst...

              new_mhaddr_reg        = cpipe_if_ahb_haddr;
              new_mhsize            = cpipe_if_ahb_hsize;
              new_mhwrite           = cpipe_if_ahb_hwrite;
              new_mhprot            = cpipe_if_ahb_hprot;
              new_aphase_wdata      = cpipe_if_ahb_hwdata;
              new_aphase_axi_id     = cpipe_if_axi_id;
              if (cpipe_if_ahb_hwrite) begin
                new_aphase_write      = 1'b1;
              end
              else
                begin
                  new_aphase_read       = 1'b1;
                  new_aphase_push_read  = next_haddr_read_push;
                end
            end

          else // no command to do from cgen... not VALID, or
               // a read that needs more RDFIFO space to start
            begin
              new_mhtrans           = `X2H_AHB_HTRANS_IDLE;
            end
        end

      ST_IF_BURST :

        begin

          // Will initially come here as the NONSEQ to start a
          // fixed-length read goes out. May complete the burst,
          // or may have to "rebuild" due to RETRY or SPLIT or an
          // Early Burst Termination. First thing to do is find
          // out if this happened:

          if (   (mhburst != `X2H_AHB_HBURST_SINGLE)
               & (mhburst != `X2H_AHB_HBURST_INCR)
               & (mhtrans != `X2H_AHB_HTRANS_IDLE))

            // ORIGINAL FIXED-LENGTH BURST still in progress
            // Continue with SEQ

            begin

              // Set all this "new" stuff, but none of it's going to
              // happen until we get (mhgrant & mhready)

              new_mhtrans           = `X2H_AHB_HTRANS_SEQ;
              new_mhaddr_reg[9:0]   = next_baddr;
              new_aphase_read       = 1'b1;
              new_aphase_push_read  = next_baddr_read_push;

              new_burst_rem         = burst_rem - 1;

              if (burst_rem == 1)
                begin
                  new_aphase_axi_last   = cpipe_if_axi_last;
                  adv_cgen_if_myhready  = 1'b1;
                  new_if_state          = ST_IF_AFTER_BURST;
                end
            end


          else if (   (mhburst == `X2H_AHB_HBURST_SINGLE)
                    | (mhtrans == `X2H_AHB_HTRANS_IDLE))

            // REBUILDING - NEXT OUT: NONSEQ

            begin

              new_mhtrans           = `X2H_AHB_HTRANS_NONSEQ;
              new_mhaddr_reg[9:0]   = next_baddr;

                new_mhburst           = `X2H_AHB_HBURST_SINGLE;

              new_aphase_read       = 1'b1;
              new_aphase_push_read  = next_baddr_read_push;

              new_burst_rem         = burst_rem - 1;

              if (burst_rem == 1)
                begin
                  new_aphase_axi_last   = cpipe_if_axi_last;
                  adv_cgen_if_myhready  = 1'b1;
                  new_if_state          = ST_IF_AFTER_BURST;
                end
            end


          else

            // REBUILDING - NEXT OUT: SEQ of INCR

            begin
              new_mhtrans           = `X2H_AHB_HTRANS_SEQ;
              new_mhaddr_reg[9:0]   = next_baddr;

              new_aphase_read       = 1'b1;
              new_aphase_push_read  = next_baddr_read_push;

              new_burst_rem         = burst_rem - 1;

              if (burst_rem == 1)
                begin
                  new_aphase_axi_last   = cpipe_if_axi_last;
                  adv_cgen_if_myhready  = 1'b1;
                  new_if_state          = ST_IF_AFTER_BURST;
                end
            end
        end


      default :

        new_mhtrans   = `X2H_AHB_HTRANS_IDLE;
        // Should never get into default state:
        /* ova
           bind assert_never #(0,1,"OVA ERROR: IF SM in undefined state")
                              OVA_check_ifsm (clk, rst_n,
                              (   (if_state != ST_IF_NEW_CGEN)
                                & (if_state != ST_IF_BURST)
                                & (if_state != ST_IF_AFTER_BURST)));
        */

    endcase

  end  // of "next_move_PROC"



assign if_cpipe_xfr_pending   =   aphase_write | aphase_read
                                | dphase_write | dphase_read
                                | retry_active;



////////////////////////////////////////////////////////
// RETRY


   // Lots of stuff gets left out if the bridge is configured
   // to "AHB Lite" mode...

//In AHB_LITE mode, these signals are unused and are tied to zeros. This is not an issue as the synthesis tool will optimize.
   assign my_retry                 = 1'b0;
   assign retry_active             = 1'b0;

//   assign retry_swap_addr          = 1'b0;

//   assign retry_mhtrans            = `X2H_AHB_HTRANS_IDLE;
//   assign retry_mhburst            = `X2H_AHB_HBURST_SINGLE;
//   assign retry_aphase_write       = 1'b0;
//   assign retry_aphase_read        = 1'b0;
//   assign retry_aphase_push_read   = 1'b0;

//   assign retry_hold_wdata         = 1'b0;




assign if_cgen_wr_err  = dphase_write & (mhresp == `X2H_AHB_RESP_ERROR);

////////////////////////////////////////////////////////
// RDFIFO interface

  assign new_hrdata_int  = rdata_function( hrdata_int, mhrdata,
                                           push_rdfifo, pushed,
                                           dphase_addr[4:0], dphase_size );

  assign new_hrstatus_int  = rresp_function( hrstatus_int, mhresp,
                                             push_rdfifo, pushed );



   always @(posedge clk or negedge rst_n)
     if ( !rst_n )
       begin
         push_rdfifo   <= 1'b0;
         hrid_int      <= {`X2H_AXI_ID_WIDTH{1'b0}};
         hrdata_int    <= {`X2H_AXI_DATA_WIDTH{1'b0}};
         hrstatus_int  <= 2'b00;
         hrlast_int    <= 1'b0;
         pushed        <= 1'b0;
       end
     else
       begin

         // push_rdfifo loads EVERY CLOCK, but only loads a
         // 1 when a "push_read" completes the data phase
               push_rdfifo     <= dphase_push_read
                              & mhready
                              & (mhresp != `X2H_AHB_RESP_RETRY)
                              & (mhresp != `X2H_AHB_RESP_SPLIT)
;


         // Data and response ONLY load when a read completes
         // the data phase, but they load on ANY read, not just
         // a "push_read".
         if (dphase_read & mhready)
           begin
             hrid_int      <= dphase_axi_id;
             hrdata_int    <= new_hrdata_int;
             hrstatus_int  <= new_hrstatus_int;
             hrlast_int    <= dphase_axi_last;
           end

         // When stuff gets pushed to the RDFIFO, it's essential to
         // clean out "rdfifo_resp", and seems kind of nice to clean
         // out "hrdata_int". Yet, these only change at all on
         // HREADY cycles. So, if need be, remember that a push
         // happened until the next HREADY cycle comes.
         if (dphase_read & mhready)
           pushed          <= 1'b0;
         else if (push_rdfifo)
           pushed          <= 1'b1;
       end


   // Module output name, per spec...

   assign push_data_int_n    = ~push_rdfifo;


// ASSERTIONS
//
`ifndef SYNTHESIS
   // Derive some independent regs to indicate when this AHB
   // master owns the address phase, data phase.

   reg  my_aphase, my_dphase;

   always @(posedge clk or negedge rst_n)
     if ( !rst_n )
       begin
         my_aphase      <= 1'b0;
         my_dphase      <= 1'b0;
       end
     else if (mhready)
       begin
         my_aphase      <= 1'b1;
         my_dphase      <= my_aphase;
       end


   // Basic sanity checks of aphase_read/write "action bits" vs bus ownership...
   /* ova
   bind assert_never #(0,1,"OVA ERROR: aphase_write illegally asserted")
                      OVA_check_aw (clk, rst_n,
                      (aphase_write & ~my_aphase));

   bind assert_never #(0,1,"OVA ERROR: aphase_read illegally asserted")
                      OVA_check_ar (clk, rst_n,
                      (aphase_read & ~my_aphase));

   bind assert_never #(0,1,"OVA ERROR: aphase_push_read illegally asserted")
                      OVA_check_apr (clk, rst_n,
                      (aphase_push_read & ~aphase_read));
   */


   // Basic sanity checks of dphase_read/write "action bits" vs bus ownership...
   /* ova
   bind assert_never #(0,1,"OVA ERROR: dphase_write illegally asserted")
                      OVA_check_dw (clk, rst_n,
                      (dphase_write & ~my_dphase));

   bind assert_never #(0,1,"OVA ERROR: dphase_read illegally asserted")
                      OVA_check_dr (clk, rst_n,
                      (dphase_read & ~my_dphase));

   bind assert_never #(0,1,"OVA ERROR: dphase_push_read illegally asserted")
                      OVA_check_dpr (clk, rst_n,
                      (dphase_push_read & ~dphase_read));
   */


   // Never get a RETRY or SPLIT when not expecting it.
   // Only check first cycle of 2-cycle response since that's all
   // "my_retry" is expected to last
   /* ova
   bind assert_never #(0,1,"OVA ERROR: RETRY at unexpected time")
                      OVA_check_rty (clk, rst_n,
                      (`ifndef X2H_HAS_SCALAR_HRESP (mhresp == `X2H_AHB_RESP_RETRY) &
                       `endif 
                       ~mhready & my_dphase & ~my_retry));

   bind assert_never #(0,1,"OVA ERROR: SPLIT at unexpected time")
                      OVA_check_spt (clk, rst_n,
                      (`ifndef X2H_HAS_SCALAR_HRESP (mhresp == `X2H_AHB_RESP_SPLIT) & 
                       `endif
                        ~mhready & my_dphase & ~my_retry));
   */


`endif



function automatic [`X2H_AXI_DATA_WIDTH-1:0] rdata_function;
  input [`X2H_AXI_DATA_WIDTH-1:0] current_rdata_reg;
  input [`X2H_AHB_DATA_WIDTH-1:0] ahb_rdata;
  input push_rdfifo;
  input pushed_rdfifo;
  input [4:0] addr;
  input [2:0] size;

  reg [31:0]  byte_enab;
  reg [255:0] ahb_in_256;
  reg [`X2H_AXI_DATA_WIDTH-1:0] working_reg;
  integer     i, j;
  begin


      case (size)
        `X2H_AMBA_SIZE_16BYTE : byte_enab = 32'h0000_FFFF;
        `X2H_AMBA_SIZE_8BYTE  : byte_enab = 32'h0000_00FF << addr[3:0];
        `X2H_AMBA_SIZE_4BYTE  : byte_enab = 32'h0000_000F << addr[3:0];
        `X2H_AMBA_SIZE_2BYTE  : byte_enab = 32'h0000_0003 << addr[3:0];
        default :               byte_enab = 32'h0000_0001 << addr[3:0];
      endcase



    // Repeat AHB RDATA to make 256-bit version
      ahb_in_256 = {(256/`X2H_AHB_DATA_WIDTH){ahb_rdata}};

    // "Normally", retain current values of any bytes not updated.
    working_reg = current_rdata_reg;

    // Update bytes per "byte_enab". If this word is being/has been
    // pushed to the RDFIFO, zero out any bytes that aren't being
    // written

    for (i = 0; i < `X2H_AXI_WSTRB_WIDTH; i = i+1)
      begin
        if (byte_enab[i])
          for (j = 0; j < 8; j = j+1)
// spyglass disable_block SelfDeterminedExpr-ML
// SMD: Self determined expression found
// SJ: The expression indexing the vector/array will never exceed the bound of the vector/array.
            working_reg[j + 8*i] = ahb_in_256[j + 8*i];
// spyglass enable_block SelfDeterminedExpr-ML              
        else if (push_rdfifo | pushed_rdfifo)
          for (j = 0; j < 8; j = j+1)
            working_reg[j + 8*i] = 1'b0;
      end

    rdata_function = working_reg;
  end
endfunction


//rresp function definition.
function automatic [1:0] rresp_function;
  input [1:0] old_rresp;
  input [`X2H_HRESP_WIDTH-1:0] ahb_hresp;
  input push_rdfifo;
  input pushed_rdfifo;

  begin
      if (ahb_hresp == `X2H_AHB_RESP_ERROR)
      rresp_function = `X2H_AXI_RESP_SLVERR;
    else if (push_rdfifo | pushed_rdfifo)
      rresp_function = `X2H_AXI_RESP_OKAY;
    else
      rresp_function = old_rresp;
  end
endfunction

//next_rd_push function definition.
function automatic nxt_rd_push_function;
  input [4:0] ahb_addr;
  input [2:0] ahb_size;
  input [2:0] axi_size;

  reg [4:0] masked_addr;

  begin
    case (ahb_size)
      `X2H_AMBA_SIZE_1BYTE  :  masked_addr = ahb_addr | 5'b00000;
      `X2H_AMBA_SIZE_2BYTE  :  masked_addr = ahb_addr | 5'b00001;
      `X2H_AMBA_SIZE_4BYTE  :  masked_addr = ahb_addr | 5'b00011;
      `X2H_AMBA_SIZE_8BYTE  :  masked_addr = ahb_addr | 5'b00111;
      `X2H_AMBA_SIZE_16BYTE :  masked_addr = ahb_addr | 5'b01111;
      default :                masked_addr = ahb_addr | 5'b11111;
    endcase

    case (axi_size)
      `X2H_AMBA_SIZE_1BYTE  :  masked_addr = masked_addr | 5'b11111;
      `X2H_AMBA_SIZE_2BYTE  :  masked_addr = masked_addr | 5'b11110;
      `X2H_AMBA_SIZE_4BYTE  :  masked_addr = masked_addr | 5'b11100;
      `X2H_AMBA_SIZE_8BYTE  :  masked_addr = masked_addr | 5'b11000;
      `X2H_AMBA_SIZE_16BYTE :  masked_addr = masked_addr | 5'b10000;
      default :                masked_addr = masked_addr | 5'b00000;
    endcase

    if (masked_addr == 5'b11111)
      nxt_rd_push_function = 1'b1;
    else
      nxt_rd_push_function = 1'b0;
  end
endfunction


endmodule




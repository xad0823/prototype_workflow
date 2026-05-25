//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2010-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

// Permit file to be called by undefs, but do nothing
`ifdef CA53_SVA_ON
`ifndef CA53_UNDEFINE
// For formal proofs
`ifdef OVL_SYNTHESIS
 `ifdef _SVA_MACRO_DEFINED_
 `else
  `define _SVA_MACRO_DEFINED_
  `define SVA_FATAL(msg)
  `define SVA_ERROR(msg)
  `define SVA_WARN(msg)
  `define SVA_INFO(msg)
  //see full define below for explanation
  `define _
 `endif

`else // !`ifdef OVL_SYNTHESIS

 `ifdef _SVA_MACRO_DEFINED_
 `else
  `define _SVA_MACRO_DEFINED_

// message print limits
`define MAX_ERRORS 10
`define MAX_WARNS 10
`define MAX_INFOS 10

// severity levels
  `define OVL_FATAL 0
  `define OVL_ERROR 1
  `define OVL_WARN  2
  `define OVL_INFO  3

// assert macros to simplify calling sva_msg
  `define SVA_MSG_FATAL(msg) sva_msg(`OVL_FATAL, $psprintf("%m"), $psprintf(msg))
  `define SVA_MSG_ERROR(msg) sva_msg(`OVL_ERROR, $psprintf("%m"), $psprintf(msg))
  `define SVA_MSG_WARN(msg) sva_msg(`OVL_WARN, $psprintf("%m"), $psprintf(msg))
  `define SVA_FATAL(msg) else sva_msg(`OVL_FATAL, $psprintf("%m"), $psprintf(msg))
  `define SVA_ERROR(msg) else sva_msg(`OVL_ERROR, $psprintf("%m"), $psprintf(msg))
  `define SVA_WARN(msg) else sva_msg(`OVL_WARN, $psprintf("%m"), $psprintf(msg))
  `define SVA_INFO(msg) else sva_msg(`OVL_INFO, $psprintf("%m"), $psprintf(msg))
  //NB this very odd define is how to insert a ',' thus multiple arguments
  // into the SVA msg so you can print out signal values, eg:
  // `SVA_FATAL("CCB state was %b, but it should be onehot"`_ $sampled(state));
  `define _ ,
`endif // !`ifdef _SVA_MACRO_DEFINED_


int error_count = 0;
int warn_count = 0;
int info_count = 0;


// generic task to print out the messages in a chosen format
// and stop the sim if necessary

task sva_msg (input int severity,
              input string path,
              input string msg);

string err_typ;

$timeformat(-9,0, " ns", 14);

case (severity)
  default    : err_typ = "OVL_FATAL";
  `OVL_FATAL : err_typ = "OVL_FATAL";
  `OVL_ERROR : begin err_typ = "OVL_ERROR"; error_count++; end
  `OVL_WARN  : begin err_typ = "OVL_WARNING"; warn_count++; end
  `OVL_INFO  : begin err_typ = "OVL_INFO"; info_count++; end
endcase

// for FATALs print message and stop
if (severity == `OVL_FATAL) begin
  $display("%t: %0s : %0s : %s", $time, err_typ, msg, path);
  #250 $stop;
end

// for others print message only if count limits not reached
else if (severity == `OVL_ERROR && error_count <= `MAX_ERRORS ||
         severity == `OVL_WARN  && warn_count  <= `MAX_WARNS ||
         severity == `OVL_INFO  && info_count  <= `MAX_INFOS) begin
  $display("%t: %0s : %0s : %s", $time, err_typ, msg, path);

  if (error_count == `MAX_ERRORS) $display("%t: *** MAX_ERRORS reached ***", $time);
  if (warn_count == `MAX_WARNS) $display("%t: *** MAX_WARNS reached ***", $time);
  if (info_count == `MAX_INFOS) $display("%t: *** MAX_INFOS reached ***", $time);

end

endtask

`endif // !`ifdef OVL_SYNTHESIS
`endif //  `ifndef CA53_UNDEFINE
`endif //  `ifdef CA53_SVA_ON


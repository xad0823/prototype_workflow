//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2015 ARM Limited.
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

// This is the specification for the interface between the DPU
// and the ETM.

`ifndef CA53_UNDEFINE

`define CA53_ETM_WPT_DIRECTBRANCH    3'b000
`define CA53_ETM_WPT_INDIRECT        3'b001
`define CA53_ETM_WPT_EXCEPTION       3'b010
`define CA53_ETM_WPT_ISB             3'b011
`define CA53_ETM_WPT_DBGENTRY        3'b100
`define CA53_ETM_WPT_DBGEXIT         3'b101
`define CA53_ETM_WPT_EXCP_RETURN     3'b110
`define CA53_ETM_RESET_EXCP              4'b0000           //Reset
`define CA53_ETM_DEBUG_HALT              4'b0001           //Debug Halt
`define CA53_ETM_CALL_EXCP               4'b0010           //SVC, HVC, SMC
`define CA53_ETM_TRAP_EXCP               4'b0011           //Trap
`define CA53_ETM_SYS_ERR_EXCP            4'b0100           //System Error
`define CA53_ETM_INST_DEBUG_EXCP         4'b0110           //Instruction Debug, for V8 AA64: BKPT, Hardware breakpoint, Vector catch, Step.
`define CA53_ETM_DATA_DEBUG_EXCP         4'b0111           //Data Debug, for V8 AA64: Hardware watchpoint
`define CA53_ETM_ALIGN_EXCP              4'b1010           //PC, SP alignment
`define CA53_ETM_INST_FAULT_EXCP         4'b1011           //Instruction abort, BKPT, Hardware breakpoint
`define CA53_ETM_DATA_FAULT_EXCP         4'b1100           //Data abort, Hardware watchpoint
`define CA53_ETM_IRQ_EXCP                4'b1110           //IRQ
`define CA53_ETM_FIQ_EXCP                4'b1111           //FIQ

`else

`undef CA53_ETM_WPT_DIRECTBRANCH
`undef CA53_ETM_WPT_INDIRECT
`undef CA53_ETM_WPT_EXCEPTION
`undef CA53_ETM_WPT_ISB
`undef CA53_ETM_WPT_DBGENTRY
`undef CA53_ETM_WPT_DBGEXIT
`undef CA53_ETM_WPT_EXCP_RETURN
`undef CA53_ETM_RESET_EXCP
`undef CA53_ETM_DEBUG_HALT
`undef CA53_ETM_CALL_EXCP
`undef CA53_ETM_TRAP_EXCP
`undef CA53_ETM_SYS_ERR_EXCP
`undef CA53_ETM_INST_DEBUG_EXCP
`undef CA53_ETM_DATA_DEBUG_EXCP
`undef CA53_ETM_ALIGN_EXCP
`undef CA53_ETM_INST_FAULT_EXCP
`undef CA53_ETM_DATA_FAULT_EXCP
`undef CA53_ETM_IRQ_EXCP
`undef CA53_ETM_FIQ_EXCP

`endif

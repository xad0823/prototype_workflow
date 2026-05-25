//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2012  ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2011-03-13 18:00:46 +0000 (Sun, 13 Mar 2011) $
//
//      Revision            : $Revision: 164412 $
//
//      Release Information : GIC-400-r0p1-00rel0
//
//-----------------------------------------------------------------------------

parameter NUM_CPUS = 4,     // Number of cores
parameter NUM_SPIS = 224,   // Number of SPIs
parameter NUM_WID_BITS = 4, // Width of AWID and BID
parameter NUM_RID_BITS = 4, // Width of ARID and RID
// Note: Trailing comma is required on last line. Do not remove

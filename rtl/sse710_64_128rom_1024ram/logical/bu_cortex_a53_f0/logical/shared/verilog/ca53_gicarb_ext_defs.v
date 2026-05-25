//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2015 ARM Limited.
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

// This is the specification for the interface between the GIC Arbiter and the
// top level.

`ifndef CA53_UNDEFINE

  `define CA53_GIC_ICC_ACTIVATE_ID            4'd1
  `define CA53_GIC_ICC_CLEAR_ACK_ID           4'd4
  `define CA53_GIC_ICC_DEACTIVATE_ID          4'd6
  `define CA53_GIC_ICC_DOWNSTREAM_WR_ACK_ID   4'd11
  `define CA53_GIC_ICC_QUIESCE_ACK_ID         4'd9
  `define CA53_GIC_ICC_RELEASE_ID             4'd3
  `define CA53_GIC_ICC_SGI_ID                 4'd7
  `define CA53_GIC_ICC_UPSTREAM_WR_ID         4'd8
  `define CA53_GIC_ICC_ACTIVATE_LEN           3'd2
  `define CA53_GIC_ICC_CLEAR_ACK_LEN          3'd1
  `define CA53_GIC_ICC_DEACTIVATE_LEN         3'd2
  `define CA53_GIC_ICC_DOWNSTREAM_WR_ACK_LEN  3'd1
  `define CA53_GIC_ICC_QUIESCE_ACK_LEN        3'd1
  `define CA53_GIC_ICC_RELEASE_LEN            3'd2
  `define CA53_GIC_ICC_SGI_LEN                3'd3
  `define CA53_GIC_ICC_UPSTREAM_WR_LEN        3'd2
  `define CA53_GIC_ICC_MAX_LEN                3
  `define CA53_GIC_ICD_ACTIVATE_ACK_ID      4'd12
  `define CA53_GIC_ICD_CLEAR_ID             4'd3
  `define CA53_GIC_ICD_DEACTIVATE_ACK_ID    4'd10
  `define CA53_GIC_ICD_DOWNSTREAM_WR_ID     4'd8
  `define CA53_GIC_ICD_QUIESCE_ID           4'd4
  `define CA53_GIC_ICD_SEI_ID               4'd5
  `define CA53_GIC_ICD_SET_ID               4'd1
  `define CA53_GIC_ICD_SGI_ACK_ID           4'd9
  `define CA53_GIC_ICD_UPSTREAM_WR_ACK_ID   4'd11
  `define CA53_GIC_ICD_VCLEAR_ID            4'd7
  `define CA53_GIC_ICD_VSET_ID              4'd6
  `define CA53_GIC_ICD_ACTIVATE_ACK_LEN     3'd1
  `define CA53_GIC_ICD_CLEAR_LEN            3'd2
  `define CA53_GIC_ICD_DEACTIVATE_ACK_LEN   3'd1
  `define CA53_GIC_ICD_DOWNSTREAM_WR_LEN    3'd2
  `define CA53_GIC_ICD_QUIESCE_LEN          3'd1
  `define CA53_GIC_ICD_SEI_LEN              3'd2
  `define CA53_GIC_ICD_SET_LEN              3'd2
  `define CA53_GIC_ICD_SGI_ACK_LEN          3'd1
  `define CA53_GIC_ICD_UPSTREAM_WR_ACK_LEN  3'd1
  `define CA53_GIC_ICD_VCLEAR_LEN           3'd2
  `define CA53_GIC_ICD_VSET_LEN             3'd2
  `define CA53_GIC_ICD_MAX_LEN              3'd2

`else

`undef CA53_GIC_ICC_ACTIVATE_ID
`undef CA53_GIC_ICC_CLEAR_ACK_ID
`undef CA53_GIC_ICC_DEACTIVATE_ID
`undef CA53_GIC_ICC_DOWNSTREAM_WR_ACK_ID
`undef CA53_GIC_ICC_QUIESCE_ACK_ID
`undef CA53_GIC_ICC_RELEASE_ID
`undef CA53_GIC_ICC_SGI_ID
`undef CA53_GIC_ICC_UPSTREAM_WR_ID
`undef CA53_GIC_ICC_ACTIVATE_LEN
`undef CA53_GIC_ICC_CLEAR_ACK_LEN
`undef CA53_GIC_ICC_DEACTIVATE_LEN
`undef CA53_GIC_ICC_DOWNSTREAM_WR_ACK_LEN
`undef CA53_GIC_ICC_QUIESCE_ACK_LEN
`undef CA53_GIC_ICC_RELEASE_LEN
`undef CA53_GIC_ICC_SGI_LEN
`undef CA53_GIC_ICC_UPSTREAM_WR_LEN
`undef CA53_GIC_ICC_MAX_LEN
`undef CA53_GIC_ICD_ACTIVATE_ACK_ID
`undef CA53_GIC_ICD_CLEAR_ID
`undef CA53_GIC_ICD_DEACTIVATE_ACK_ID
`undef CA53_GIC_ICD_DOWNSTREAM_WR_ID
`undef CA53_GIC_ICD_QUIESCE_ID
`undef CA53_GIC_ICD_SEI_ID
`undef CA53_GIC_ICD_SET_ID
`undef CA53_GIC_ICD_SGI_ACK_ID
`undef CA53_GIC_ICD_UPSTREAM_WR_ACK_ID
`undef CA53_GIC_ICD_VCLEAR_ID
`undef CA53_GIC_ICD_VSET_ID
`undef CA53_GIC_ICD_ACTIVATE_ACK_LEN
`undef CA53_GIC_ICD_CLEAR_LEN
`undef CA53_GIC_ICD_DEACTIVATE_ACK_LEN
`undef CA53_GIC_ICD_DOWNSTREAM_WR_LEN
`undef CA53_GIC_ICD_QUIESCE_LEN
`undef CA53_GIC_ICD_SEI_LEN
`undef CA53_GIC_ICD_SET_LEN
`undef CA53_GIC_ICD_SGI_ACK_LEN
`undef CA53_GIC_ICD_UPSTREAM_WR_ACK_LEN
`undef CA53_GIC_ICD_VCLEAR_LEN
`undef CA53_GIC_ICD_VSET_LEN
`undef CA53_GIC_ICD_MAX_LEN

`endif

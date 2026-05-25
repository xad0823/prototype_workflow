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

//-----------------------------------------------------------------------------
// Abstract : STB block internal definitions
//-----------------------------------------------------------------------------

`ifndef CA53_UNDEFINE

// Byte to bit strobe expansion
`define CA53_STB_BYTE_TO_BIT_STROBES(bytes) ({{8{bytes[15]}}, \
                                              {8{bytes[14]}}, \
                                              {8{bytes[13]}}, \
                                              {8{bytes[12]}}, \
                                              {8{bytes[11]}}, \
                                              {8{bytes[10]}}, \
                                              {8{bytes[9]}},  \
                                              {8{bytes[8]}},  \
                                              {8{bytes[7]}},  \
                                              {8{bytes[6]}},  \
                                              {8{bytes[5]}},  \
                                              {8{bytes[4]}},  \
                                              {8{bytes[3]}},  \
                                              {8{bytes[2]}},  \
                                              {8{bytes[1]}},  \
                                              {8{bytes[0]}}})

`define CA53_SLOT_WIDTH 12

// FSM states
//
// These states are encoded such that:
// - Not IDLE can be decoded trivially.
// - CP15REQ, CP15RESP, SYNCREQ, BIUDATA, SPECIAL can be decoded trivially.
// - The following transitions only change one bit (bit [8]),
//   so dcu_stb_tag_has_priority_m0_i only has to factor into one bit:
//   - LOOKUPREQ -> LOOKUPM1
//   - TAGWRITE  -> CACHEWRITEREQ
// - The following transitions only change one bit (bit [9]),
//   so dcu_stb_data_has_priority_m0_i only has to factor into one bit:
//   - CACHEREADM0   -> CACHEREADM1
//   - CACHEWRITEREQ -> CACHEWRITEM1
`define CA53_SLOT_IDLE               12'b00000_0_00000_0
`define CA53_SLOT_LOOKUPREQ          12'b00001_0_00000_1
`define CA53_SLOT_LOOKUPM1           12'b00011_0_00000_1
`define CA53_SLOT_LOOKUPM2           12'b00010_0_00000_1
`define CA53_SLOT_CACHEMERGE         12'b00100_0_00000_1
`define CA53_SLOT_CACHEREADM0        12'b10001_0_00000_1
`define CA53_SLOT_CACHEREADM1        12'b10101_0_00000_1
`define CA53_SLOT_CACHEREADM2        12'b00101_0_00000_1
`define CA53_SLOT_CACHEECC           12'b00110_0_00000_1
`define CA53_SLOT_CACHEWRITEREQ      12'b01011_0_00000_1
`define CA53_SLOT_CACHEWRITEM1       12'b01111_0_00000_1
`define CA53_SLOT_CACHEECC_WAIT      12'b00111_0_00000_1
`define CA53_SLOT_LFREQ              12'b01000_0_00000_1
`define CA53_SLOT_BIUMERGE           12'b01010_0_00000_1
`define CA53_SLOT_BIUREQ             12'b01100_0_00000_1
`define CA53_SLOT_BIUACK             12'b00000_1_00000_1
`define CA53_SLOT_BIURESP            12'b01101_0_00000_1
`define CA53_SLOT_BIUDATA            12'b00000_0_10000_1
`define CA53_SLOT_CLEANUNIQUE_REQ    12'b01110_0_00000_1
`define CA53_SLOT_CLEANUNIQUE_ACK    12'b00001_1_00000_1
`define CA53_SLOT_CLEANUNIQUE_RESP   12'b10000_0_00000_1
`define CA53_SLOT_TAGWRITE           12'b01001_0_00000_1
`define CA53_SLOT_CP15REQ            12'b00000_0_00001_1
`define CA53_SLOT_CP15ACK            12'b00010_1_00000_1
`define CA53_SLOT_CP15RESP           12'b00000_0_00010_1
`define CA53_SLOT_DVMDATA            12'b10010_0_00000_1
`define CA53_SLOT_SYNCREQ            12'b00000_0_00100_1
`define CA53_SLOT_SYNCACK            12'b00011_1_00000_1
`define CA53_SLOT_SYNCRESP1          12'b10011_0_00000_1
`define CA53_SLOT_SYNCRESP2          12'b10100_0_00000_1
`define CA53_SLOT_BARRIER_REQ        12'b10110_0_00000_1
`define CA53_SLOT_BARRIER_ACK        12'b00100_1_00000_1
`define CA53_SLOT_BARRIER_RESP       12'b10111_0_00000_1
`define CA53_SLOT_SPECIAL            12'b00000_0_01000_1
`define CA53_SLOT_X                  12'bxxxxx_x_xxxxx_x

`define CA53_SLOT_VALID(slot_state)                                                              (slot_state[0])
`define CA53_SLOT_STATE_IDLE(slot_state)                                                         (~slot_state[0])
`define CA53_SLOT_STATE_LOOKUPREQ(slot_state, taghit, tag_err, no_alloc, ev_hz_seen)             (({slot_state[11:6], 6'b000001} == `CA53_SLOT_LOOKUPREQ) | \
                                                                                                  (`CA53_SLOT_STATE_SPECIAL(slot_state) & ~taghit & ~tag_err & no_alloc & (&ev_hz_seen)))
`define CA53_SLOT_STATE_LOOKUPM1(slot_state)                                                     ({slot_state[11:6], 6'b000001} == `CA53_SLOT_LOOKUPM1)
`define CA53_SLOT_STATE_LOOKUPM2(slot_state)                                                     ({slot_state[11:6], 6'b000001} == `CA53_SLOT_LOOKUPM2)
`define CA53_SLOT_STATE_CACHEMERGE(slot_state, mergeable, taghit_excl, tag_err)                  (({slot_state[11:6], 6'b000001} == `CA53_SLOT_CACHEMERGE) | \
                                                                                                  (`CA53_SLOT_STATE_SPECIAL(slot_state) & taghit_excl & ~tag_err & mergeable))
`define CA53_SLOT_STATE_CACHEREADM0(slot_state, taghit_shared, tag_err, cache_read_required)     (({slot_state[11:6], 6'b000001} == `CA53_SLOT_CACHEREADM0) | \
                                                                                                  (`CA53_SLOT_STATE_SPECIAL(slot_state) & taghit_shared & ~tag_err & cache_read_required))
`define CA53_SLOT_STATE_CACHEREADM1(slot_state)                                                  ({slot_state[11:6], 6'b000001} == `CA53_SLOT_CACHEREADM1)
`define CA53_SLOT_STATE_CACHEREADM2(slot_state)                                                  ({slot_state[11:6], 6'b000001} == `CA53_SLOT_CACHEREADM2)
`define CA53_SLOT_STATE_CACHEECC(slot_state)                                                     ({slot_state[11:6], 6'b000001} == `CA53_SLOT_CACHEECC)
`define CA53_SLOT_STATE_CACHEWRITEREQ(slot_state, mergeable, taghit_excl, tag_err)               (({slot_state[11:6], 6'b000001} == `CA53_SLOT_CACHEWRITEREQ) | \
                                                                                                  (`CA53_SLOT_STATE_SPECIAL(slot_state) & taghit_excl & ~tag_err & ~mergeable))
`define CA53_SLOT_STATE_CACHEWRITEM1(slot_state)                                                 ({slot_state[11:6], 6'b000001} == `CA53_SLOT_CACHEWRITEM1)
`define CA53_SLOT_STATE_CACHEECC_WAIT(slot_state, tag_err)                                       (({slot_state[11:6], 6'b000001} == `CA53_SLOT_CACHEECC_WAIT) | \
                                                                                                  (`CA53_SLOT_STATE_SPECIAL(slot_state) & tag_err))
`define CA53_SLOT_STATE_LFREQ(slot_state, taghit, tag_err, no_alloc)                             (({slot_state[11:6], 6'b000001} == `CA53_SLOT_LFREQ) | \
                                                                                                  (`CA53_SLOT_STATE_SPECIAL(slot_state) & ~taghit & ~tag_err & ~no_alloc))
`define CA53_SLOT_STATE_BIUMERGE(slot_state)                                                     ({slot_state[11:6], 6'b000001} == `CA53_SLOT_BIUMERGE)
`define CA53_SLOT_STATE_BIUREQ(slot_state, taghit, tag_err, no_alloc, ev_hz_seen)                (({slot_state[11:6], 6'b000001} == `CA53_SLOT_BIUREQ) | \
                                                                                                  (`CA53_SLOT_STATE_SPECIAL(slot_state) & ~taghit & ~tag_err & no_alloc & ~ev_hz_seen))
`define CA53_SLOT_STATE_BIUACK(slot_state)                                                       ({slot_state[11:6], 6'b000001} == `CA53_SLOT_BIUACK)
`define CA53_SLOT_STATE_BIURESP(slot_state)                                                      ({slot_state[11:6], 6'b000001} == `CA53_SLOT_BIURESP)
`define CA53_SLOT_STATE_BIUDATA(slot_state)                                                      (slot_state[5])
`define CA53_SLOT_STATE_CLEANUNIQUE_REQ(slot_state, taghit_shared, tag_err, cache_read_required) (({slot_state[11:6], 6'b000001} == `CA53_SLOT_CLEANUNIQUE_REQ) | \
                                                                                                  (`CA53_SLOT_STATE_SPECIAL(slot_state) & taghit_shared & ~tag_err & ~cache_read_required))
`define CA53_SLOT_STATE_CLEANUNIQUE_ACK(slot_state)                                              ({slot_state[11:6], 6'b000001} == `CA53_SLOT_CLEANUNIQUE_ACK)
`define CA53_SLOT_STATE_CLEANUNIQUE_RESP(slot_state)                                             ({slot_state[11:6], 6'b000001} == `CA53_SLOT_CLEANUNIQUE_RESP)
`define CA53_SLOT_STATE_TAGWRITE(slot_state)                                                     ({slot_state[11:6], 6'b000001} == `CA53_SLOT_TAGWRITE)
`define CA53_SLOT_STATE_CP15REQ(slot_state)                                                      (slot_state[1])
`define CA53_SLOT_STATE_CP15ACK(slot_state)                                                      ({slot_state[11:6], 6'b000001} == `CA53_SLOT_CP15ACK)
`define CA53_SLOT_STATE_CP15RESP(slot_state)                                                     (slot_state[2])
`define CA53_SLOT_STATE_DVMDATA(slot_state)                                                      ({slot_state[11:6], 6'b000001} == `CA53_SLOT_DVMDATA)
`define CA53_SLOT_STATE_SYNCREQ(slot_state)                                                      (slot_state[3])
`define CA53_SLOT_STATE_SYNCACK(slot_state)                                                      ({slot_state[11:6], 6'b000001} == `CA53_SLOT_SYNCACK)
`define CA53_SLOT_STATE_SYNCRESP1(slot_state)                                                    ({slot_state[11:6], 6'b000001} == `CA53_SLOT_SYNCRESP1)
`define CA53_SLOT_STATE_SYNCRESP2(slot_state)                                                    ({slot_state[11:6], 6'b000001} == `CA53_SLOT_SYNCRESP2)
`define CA53_SLOT_STATE_BARRIER_REQ(slot_state)                                                  ({slot_state[11:6], 6'b000001} == `CA53_SLOT_BARRIER_REQ)
`define CA53_SLOT_STATE_BARRIER_ACK(slot_state)                                                  ({slot_state[11:6], 6'b000001} == `CA53_SLOT_BARRIER_ACK)
`define CA53_SLOT_STATE_BARRIER_RESP(slot_state)                                                 ({slot_state[11:6], 6'b000001} == `CA53_SLOT_BARRIER_RESP)
`define CA53_SLOT_STATE_SPECIAL(slot_state)                                                      (slot_state[4])

`define CA53_SLOT_ALREADY_HAS_AR(slot_state)                                                     (slot_state[6])

`define CA53_SLOT_MODIFIED_STATE(slot_state, mergeable, taghit_shared, tag_err, full_cache_read_required, no_alloc, ev_hz_seen) (slot_state[4] ? \
                                                                                                                                 (tag_err ? `CA53_SLOT_CACHEECC_WAIT : \
                                                                                                                                  taghit_shared[0] ? (full_cache_read_required ? \
                                                                                                                                                      `CA53_SLOT_CACHEREADM0 : \
                                                                                                                                                      `CA53_SLOT_CLEANUNIQUE_REQ) : \
                                                                                                                                  taghit_shared[1] ? (mergeable ? \
                                                                                                                                                      `CA53_SLOT_CACHEMERGE : \
                                                                                                                                                      `CA53_SLOT_CACHEWRITEREQ) : \
                                                                                                                                  no_alloc ? (ev_hz_seen ? \
                                                                                                                                              `CA53_SLOT_LOOKUPREQ : \
                                                                                                                                              `CA53_SLOT_BIUREQ) : \
                                                                                                                                  `CA53_SLOT_LFREQ) : \
                                                                                                                                 slot_state)

// Undefs
`else
/*ARMAUTO_UNDEF*/
`undef CA53_STB_BYTE_TO_BIT_STROBES
`undef CA53_SLOT_WIDTH
`undef CA53_SLOT_IDLE
`undef CA53_SLOT_LOOKUPREQ
`undef CA53_SLOT_LOOKUPM1
`undef CA53_SLOT_LOOKUPM2
`undef CA53_SLOT_CACHEMERGE
`undef CA53_SLOT_CACHEREADM0
`undef CA53_SLOT_CACHEREADM1
`undef CA53_SLOT_CACHEREADM2
`undef CA53_SLOT_CACHEECC
`undef CA53_SLOT_CACHEWRITEREQ
`undef CA53_SLOT_CACHEWRITEM1
`undef CA53_SLOT_CACHEECC_WAIT
`undef CA53_SLOT_LFREQ
`undef CA53_SLOT_BIUMERGE
`undef CA53_SLOT_BIUREQ
`undef CA53_SLOT_BIUACK
`undef CA53_SLOT_BIURESP
`undef CA53_SLOT_BIUDATA
`undef CA53_SLOT_CLEANUNIQUE_REQ
`undef CA53_SLOT_CLEANUNIQUE_ACK
`undef CA53_SLOT_CLEANUNIQUE_RESP
`undef CA53_SLOT_TAGWRITE
`undef CA53_SLOT_CP15REQ
`undef CA53_SLOT_CP15ACK
`undef CA53_SLOT_CP15RESP
`undef CA53_SLOT_DVMDATA
`undef CA53_SLOT_SYNCREQ
`undef CA53_SLOT_SYNCACK
`undef CA53_SLOT_SYNCRESP1
`undef CA53_SLOT_SYNCRESP2
`undef CA53_SLOT_BARRIER_REQ
`undef CA53_SLOT_BARRIER_ACK
`undef CA53_SLOT_BARRIER_RESP
`undef CA53_SLOT_SPECIAL
`undef CA53_SLOT_X
`undef CA53_SLOT_VALID
`undef CA53_SLOT_STATE_IDLE
`undef CA53_SLOT_STATE_LOOKUPREQ
`undef CA53_SLOT_STATE_LOOKUPM1
`undef CA53_SLOT_STATE_LOOKUPM2
`undef CA53_SLOT_STATE_CACHEMERGE
`undef CA53_SLOT_STATE_CACHEREADM0
`undef CA53_SLOT_STATE_CACHEREADM1
`undef CA53_SLOT_STATE_CACHEREADM2
`undef CA53_SLOT_STATE_CACHEECC
`undef CA53_SLOT_STATE_CACHEWRITEREQ
`undef CA53_SLOT_STATE_CACHEWRITEM1
`undef CA53_SLOT_STATE_CACHEECC_WAIT
`undef CA53_SLOT_STATE_LFREQ
`undef CA53_SLOT_STATE_BIUMERGE
`undef CA53_SLOT_STATE_BIUREQ
`undef CA53_SLOT_STATE_BIUACK
`undef CA53_SLOT_STATE_BIURESP
`undef CA53_SLOT_STATE_BIUDATA
`undef CA53_SLOT_STATE_CLEANUNIQUE_REQ
`undef CA53_SLOT_STATE_CLEANUNIQUE_ACK
`undef CA53_SLOT_STATE_CLEANUNIQUE_RESP
`undef CA53_SLOT_STATE_TAGWRITE
`undef CA53_SLOT_STATE_CP15REQ
`undef CA53_SLOT_STATE_CP15ACK
`undef CA53_SLOT_STATE_CP15RESP
`undef CA53_SLOT_STATE_DVMDATA
`undef CA53_SLOT_STATE_SYNCREQ
`undef CA53_SLOT_STATE_SYNCACK
`undef CA53_SLOT_STATE_SYNCRESP1
`undef CA53_SLOT_STATE_SYNCRESP2
`undef CA53_SLOT_STATE_BARRIER_REQ
`undef CA53_SLOT_STATE_BARRIER_ACK
`undef CA53_SLOT_STATE_BARRIER_RESP
`undef CA53_SLOT_STATE_SPECIAL
`undef CA53_SLOT_ALREADY_HAS_AR
`undef CA53_SLOT_MODIFIED_STATE
/*END*/

`endif

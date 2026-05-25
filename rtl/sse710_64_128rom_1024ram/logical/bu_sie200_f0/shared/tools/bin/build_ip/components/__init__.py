#!/usr/bin/env python
#-----------------------------------------------------------------------------
#  The confidential and proprietary information contained in this file may
#  only be used by a person authorised under and to the extent permitted
#  by a subsisting licensing agreement from ARM Limited or its affiliates.
#
#             (C) COPYRIGHT 2016-2017 ARM Limited or its affiliates.
#                 ALL RIGHTS RESERVED
#
#  This entire notice must be reproduced on all copies of this file
#  and copies of this file may only be made by a person if such person is
#  permitted to do so under the terms of a subsisting license agreement
#  from ARM Limited or its affiliates.
#
#     Checked In : Thu Jan 19 14:38:44 2017 +0000
#     Revision   : deb41b1
#     Release    : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
# ----------------------------------------------------------------------------
#  Purpose :
# ----------------------------------------------------------------------------


__comps__ = ["sie200_ahb5_ex_mon",
           "sie200_ahb5_to_apb_sync",
           "sie200_ahb5_to_apb_async",
           "sie200_ahb5_to_apb_ll_sync",
           "sie200_ahb5_to_rom",
           "sie200_ahb5_to_sram",
           "sie200_ahb5_to_extmem16",
           "sie200_ahb5_default_slave",
           "sie200_ahb5_master_mux",
           "sie200_ahb5_slave_mux",
           "sie200_ahb5_to_ahb5_sync_up",
           "sie200_ahb5_to_ahb5_sync_down",
           "sie200_ahb5_to_ahb5_ll_sync_up",
           "sie200_ahb5_to_ahb5_ll_sync_down",
           "sie200_ahb5_upsizer",
           "sie200_ahb5_downsizer",
           "sie200_ahb5_access_ctrl",
           "sie200_ahb5_timeout_mon",
           "sie200_ahb5_to_ahb5_sync",
           "sie200_ahb5_to_ahb5_apb_async",
           "sie200_ahb5_mem_prot",
           "sie200_apb_periph_prot",
           "sie200_ahb5_periph_prot",
           "sie200_ahb5_master_sec",
           "sie200_ahb5_fileread_master",
           "sie200_ahb5_eg_slave",
           "sie200_ahb5_gpio",
           "sie200_m3_m4_ahb5_adapter",
          ]

__subcomps__ = [
           "sie200_ahb5_to_apb_sync_s",
           "sie200_ahb5_to_apb_sync_m",
           "sie200_ahb5_to_apb_async_s",
           "sie200_ahb5_to_apb_async_m",
           "sie200_ahb5_to_ahb5_sync_up_s",
           "sie200_ahb5_to_ahb5_sync_up_m",
           "sie200_ahb5_to_ahb5_sync_down_s",
           "sie200_ahb5_to_ahb5_sync_down_m",
           "sie200_ahb5_access_ctrl_s",
           "sie200_ahb5_access_ctrl_m",
           "sie200_ahb5_to_ahb5_apb_async_s",
           "sie200_ahb5_to_ahb5_apb_async_m",
          ]

__all__ = __comps__ + __subcomps__

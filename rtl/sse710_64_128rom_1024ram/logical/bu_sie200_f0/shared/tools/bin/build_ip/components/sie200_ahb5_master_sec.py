#!/usr/bin/env python
#-----------------------------------------------------------------------------
#  The confidential and proprietary information contained in this file may
#  only be used by a person authorised under and to the extent permitted
#  by a subsisting licensing agreement from ARM Limited or its affiliates.
#
#             (C) COPYRIGHT 2016 ARM Limited or its affiliates.
#                 ALL RIGHTS RESERVED
#
#  This entire notice must be reproduced on all copies of this file
#  and copies of this file may only be made by a person if such person is
#  permitted to do so under the terms of a subsisting license agreement
#  from ARM Limited or its affiliates.
#
#     Checked In : Mon Dec 5 12:00:25 2016 +0000
#     Revision   : dd9c468
#     Release    : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
# ----------------------------------------------------------------------------
#  Purpose :
# ----------------------------------------------------------------------------

import base
import sie200_base

class sie200_ahb5_master_sec(sie200_base.BridgeComponent):
    def __init__(self):
        super(sie200_ahb5_master_sec, self).__init__()

        self.name = "sie200_ahb5_master_sec"
        self.version = "r0p0_0"
        self.description = "AHB5 Master Security Controller"


        self.GetParameter("ADDR_WIDTH").usage = "constant"

        ahbif_s = sie200_base.ahbinitif("_s","",0,0)
        ahbif_m = sie200_base.ahbinitif("_m","",1,1)
        ahbif_s.bridges.append((ahbif_m.name, "true"))
        subspaceMaps = [
            base.SubspaceMap(ahbif_m.name,"0",ahbif_s.name),
        ]
        self.submaps.extend(subspaceMaps)

        interfaces = [
            ahbif_s,
            ahbif_m,
            sie200_base.irqif("msc","hclk"),
            sie200_base.internalInterrupt("msc",sig_clear=1,sig_enable=1,clk_name="hclk"),
            sie200_base.dyncfgif("cfg_sec_resp","hclk"),
            sie200_base.dyncfgif("cfg_nonsec","hclk"),
            sie200_base.idauif(27),
        ]
        self.interfaces.extend(interfaces)



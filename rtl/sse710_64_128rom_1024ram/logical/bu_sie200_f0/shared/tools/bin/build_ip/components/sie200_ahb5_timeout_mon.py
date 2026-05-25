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

class sie200_ahb5_timeout_mon(sie200_base.BridgeComponent):
    def __init__(self):
        super(sie200_ahb5_timeout_mon, self).__init__()

        self.name = "sie200_ahb5_timeout_mon"
        self.version = "r0p0_0"
        self.description = "AHB5 Timeout Monitor"

        parameter = base.Parameter("TIMEOUT_VALUE")
        parameter.description = "Number of wait cycles that trigger timeout"
        parameter.value = "16"
        parameter.minimum = "2"
        parameter.maximum = "1024"
        self.parameters.append(parameter)

        parameter = base.Parameter("STRICT_AHB_COMP")
        parameter.description = "Strict AHB compliance 0: Let the HTRANS, HBURST, HWDATA and HWUSER signals go through, 1: Break up bursts, keep data phase signals stable in timeout."
        parameter.value = "1"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        ahbif_s = sie200_base.ahbif("_s", "")
        ahbif_m = sie200_base.ahbif("_m", "")
        ahbif_s.bridges.append((ahbif_m.name, "true"))
        subspaceMaps = [
            base.SubspaceMap(ahbif_m.name,"0",ahbif_s.name),
        ]
        self.submaps.extend(subspaceMaps)

        interfaces = [
            sie200_base.statusif("timeout","hclk","hresetn",1),
            ahbif_s,
            ahbif_m,
        ]
        self.interfaces.extend(interfaces)

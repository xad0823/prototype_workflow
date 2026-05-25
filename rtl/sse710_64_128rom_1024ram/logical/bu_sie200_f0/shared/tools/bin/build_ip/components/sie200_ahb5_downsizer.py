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


class sie200_ahb5_downsizer(sie200_base.BridgeComponent):
    def __init__(self):
        super(sie200_ahb5_downsizer, self).__init__()

        self.name = "sie200_ahb5_downsizer"
        self.version = "r0p0_0"
        self.description = "AHB5 Downsizer"

        parameter = base.Parameter("ERR_BURST_BLOCK_ALL")
        parameter.description = "Burst blocking policy, 1: if an error response is received during a burst sequence, the remaining transfers in the burst sequence are blocked by the AHB downsizer and do not reach the downstream AHB, 0: the same blocking behavior applies to full-width burst transfers only"
        parameter.value = "1"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        parameter = base.Parameter("ENDIANNESS")
        parameter.description = "Defines the endianness of the AHB interfaces: 0-little endian, 1:byte-invariant big endian, 2: word-invariant big endian"
        parameter.value = "0"
        parameter.minimum = "0"
        parameter.maximum = "2"
        parameter.enumerations = ["0", "1", "2"]
        self.parameters.append(parameter)

        # DATA_WIDTH
        self.GetParameter("DATA_WIDTH").value = "64"

        ahbif_s = sie200_base.ahbif("_s", "")
        ahbif_m = sie200_base.ahbif_ds("_m", "")
        ahbif_s.bridges.append((ahbif_m.name, "true"))
        subspaceMaps = [
            base.SubspaceMap(ahbif_m.name,"0",ahbif_s.name),
        ]
        self.submaps.extend(subspaceMaps)

        interfaces = [
            ahbif_s,
            ahbif_m
        ]
        self.interfaces.extend(interfaces)

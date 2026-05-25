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
#     Checked In : Mon Dec 5 12:19:13 2016 +0000
#     Revision   : 8d9942f
#     Release    : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
# ----------------------------------------------------------------------------
#  Purpose :
# ----------------------------------------------------------------------------

import os
import base
import sie200_base


class sie200_ahb5_to_ahb5_sync_down_m(sie200_base.AcgMasterComponent):
    def __init__(self):
        super(sie200_ahb5_to_ahb5_sync_down_m, self).__init__()

        self.name = "sie200_ahb5_to_ahb5_sync_down_m"
        self.version = "r0p0_1"
        self.description = "AHB5 to AHB5 Sync Down Bridge Master"


        parameter = base.Parameter("BURST")
        parameter.description = "Burst transfers are supported"
        parameter.value = "0"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        intif_s = sie200_base.internal_sie200_ahb5_to_ahb5_sync_down_if(1)
        ahbif_m = sie200_base.ahbinitif("_m","_m",1,1)
        intif_s.bridges.append((ahbif_m.name, "true"))
        subspaceMaps = [
            base.SubspaceMap(ahbif_m.name,"0",intif_s.name),
        ]
        self.submaps.extend(subspaceMaps)

        interfaces = [
            ahbif_m,
            intif_s
        ]
        self.interfaces.extend(interfaces)

        files = [
            os.path.join("..","..",self.name[:-2],"verilog",self.name[:-2] + "_core_m.v"),
        ]
        self.files.extend(files)


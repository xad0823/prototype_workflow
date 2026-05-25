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
#     Checked In : Fri Feb 3 15:54:58 2017 +0000
#     Revision   : fd6a20f
#     Release    : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
# ----------------------------------------------------------------------------
#  Purpose :
# ----------------------------------------------------------------------------

import os
import base
import sie200_base

class ahb5_to_apb_sync_adhoc_if_m(base.Interface):
    def __init__(self):
        super(ahb5_to_apb_sync_adhoc_if_m, self).__init__()
        self.mwidth = "$MASTER_WIDTH"

    def Configure(self, parameters):
        self.mwidth = base.SubstituteParam(self.mwidth, parameters)

        scalarPorts = [
            ("apb_active", "out")
        ]
        self.scalarPorts.extend(scalarPorts)

        vectorPorts = [
            ("pmaster", "out",   int(self.mwidth, 0) - 1, 0)
        ]
        self.vectorPorts.extend(vectorPorts)


class sie200_ahb5_to_apb_sync_m(sie200_base.AcgMasterComponent):
    def __init__(self):
        super(sie200_ahb5_to_apb_sync_m, self).__init__("pclk")

        self.name = "sie200_ahb5_to_apb_sync_m"
        self.version = "r0p0_1"
        self.description = "AHB5 to APB Synchronous Bridge Master"

        self.GetParameter("DATA_WIDTH").usage = "constant"
        self.GetParameter("DATA_WIDTH").value = "32"
        self.GetParameter("USER_WIDTH").usage = "constant"
        self.GetParameter("USER_WIDTH").value = "0"
        self.GetParameter("USER_WIDTH").minimum = ""
        self.GetParameter("USER_WIDTH").maximum = ""

        intif_s = sie200_base.internal_sie200_ahb5_to_apb_sync_if(1)
        apbif_m = sie200_base.apbif(1,"")
        intif_s.bridges.append((apbif_m.name, "true"))
        subspaceMaps = [
            base.SubspaceMap(apbif_m.name,"0",intif_s.name),
        ]
        self.submaps.extend(subspaceMaps)

        interfaces = [
            apbif_m,
            intif_s,
            ahb5_to_apb_sync_adhoc_if_m()
        ]

        self.interfaces.extend(interfaces)

        files = [
            os.path.join("..","..",self.name[:-2],"verilog",self.name[:-2] + "_core_m.v"),
        ]
        self.files.extend(files)

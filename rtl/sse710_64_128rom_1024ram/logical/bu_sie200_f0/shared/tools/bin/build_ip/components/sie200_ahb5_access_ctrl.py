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
#     Checked In : Mon Dec 5 10:35:33 2016 +0000
#     Revision   : 8da1d99
#     Release    : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
# ----------------------------------------------------------------------------
#  Purpose :
# ----------------------------------------------------------------------------

import os
import base
import sie200_base

class sie200_ahb5_access_ctrl(sie200_base.AcgComponent):
    def __init__(self):
        super(sie200_ahb5_access_ctrl, self).__init__()

        self.name = "sie200_ahb5_access_ctrl"
        self.version = "r0p0_1"
        self.description = "AHB5 Access Control Gate"

        ahbif_s = sie200_base.ahbif("_s","_s")
        ahbif_m = sie200_base.ahbif("_m","_m")
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

        files = [
            os.path.join("..","..","models","cells","generic","sie200_and.v"),
            os.path.join("..","..",self.name,"verilog",self.name + "_hold.v"),
            os.path.join("..","..",self.name,"verilog",self.name + "_iso_m.v"),
            os.path.join("..","..",self.name,"verilog",self.name + "_m.v"),
            os.path.join("..","..",self.name,"verilog",self.name + "_s.v")
        ]
        self.files.extend(files)

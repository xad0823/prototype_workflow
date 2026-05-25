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


class sie200_ahb5_to_ahb5_sync_down_s(sie200_base.AcgSlaveComponent):
    def __init__(self):
        super(sie200_ahb5_to_ahb5_sync_down_s, self).__init__()

        self.name = "sie200_ahb5_to_ahb5_sync_down_s"
        self.version = "r0p0_1"
        self.description = "AHB5 to AHB5 Sync Down Bridge Slave"


        parameter = base.Parameter("BURST")
        parameter.description = "Burst transfers are supported"
        parameter.value = "0"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)


        parameter = base.Parameter("WRITE_BUFFER")
        parameter.description = "Write Buffer supported"
        parameter.value = "0"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        ahbif_s = sie200_base.ahbif("_s","_s")
        intif_m = sie200_base.internal_sie200_ahb5_to_ahb5_sync_down_if(0)
        ahbif_s.bridges.append((intif_m.name, "true"))
        subspaceMaps = [
            base.SubspaceMap(intif_m.name,"0",ahbif_s.name),
        ]
        self.submaps.extend(subspaceMaps)

        interfaces = [
            ahbif_s,
            sie200_base.irqif("ahb5_sync_down"),
            sie200_base.internalInterrupt("ahb5_sync_down", sig_clear = 1),
            intif_m
        ]

        self.interfaces.extend(interfaces)

        files = [
            os.path.join("..","..","shared","verilog","sie200_ahb5_error_canc","verilog","sie200_ahb5_error_canc.v"),
            os.path.join("..","..","shared","verilog","sie200_ahb5_write_buffer","verilog","sie200_ahb5_write_buffer.v"),
            os.path.join("..","..",self.name[:-2],"verilog",self.name[:-2] + "_core_s.v"),
        ]
        self.files.extend(files)




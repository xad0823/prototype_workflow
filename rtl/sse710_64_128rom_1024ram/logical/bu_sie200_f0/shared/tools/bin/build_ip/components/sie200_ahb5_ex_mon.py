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

import base
import sie200_base


class sie200_ahb5_ex_mon(sie200_base.BridgeComponent):
    def __init__(self):
        super(sie200_ahb5_ex_mon, self).__init__()

        self.name = "sie200_ahb5_ex_mon"
        self.version = "r0p0_1"
        self.description = "AHB5 Exclusive Access Monitor"


        parameter = base.Parameter("TAG_MSB")
        parameter.description = "MSB of Address Tag. Can be used to reduce the Address tag if the subsystem downstream of it does not use the higher bits of the address. Should default to ADDR_WIDTH-1 if not specified"
        parameter.value = str(int(self.GetParameter("ADDR_WIDTH").value, 0) - 1)
        parameter.minimum = "2"
        parameter.maximum = "31"
        self.parameters.append(parameter)

        parameter = base.Parameter("ID_PRESENT")
        parameter.description = "2^MASTER_WIDTH bit wide mask value, one bit per master enables the EAM feature for that master, otherwise the logic is not generated. Should always be defined"
        parameter.value = "0"
        # parameter.minimum = "0"
        # parameter.maximum = str(hex((2 ** (2 ** 8)) - 1))
        self.parameters.append(parameter)

        parameter = base.Parameter("BUFFER_ENABLE")
        parameter.description = "Adds buffering and a 2 cycle latency to exclusive write (only 1 if not set in ID_PRESENT). Greatly improves synthesis timing result"
        parameter.value = "0"
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
            ahbif_s,
            ahbif_m
        ]
        self.interfaces.extend(interfaces)

    def ValidateParameters(self):

        tag_msb   = int(self.GetParameter("TAG_MSB").value, 0)
        aw        = int(self.GetParameter("ADDR_WIDTH").value, 0)
        dw        = int(self.GetParameter("DATA_WIDTH").value, 0)
        if (dw == 32):
            log2dw = 5
        elif (dw == 64):
            log2dw = 6
        elif (dw == 128):
            log2dw = 7
        else:
            print "ERROR: Wrong DATA_WIDTH parameter (%d), available options are 32,64 or 128" % (dw)
            return False
        if(tag_msb >= aw):
            print "ERROR: Parameter TAG_MSB (%d) must be less then ADDR_WIDTH (%d)" % (tag_msb, aw)
            return False
        elif ((log2dw - 3) > tag_msb):
            print "ERROR: Parameter TAG_MSB (%d) must be larger or equal to log2(DATA_WIDTH)-3 = %d where DATA_WIDTH (%d)" % (tag_msb, log2dw-3, dw)
            return False
        else:
            return True

    def RecalculateDefaultParameters(self):
        if (self.GetParameter("TAG_MSB").default == "True"):
            self.GetParameter("TAG_MSB").value = str(int(self.GetParameter("ADDR_WIDTH").value, 0) - 1)


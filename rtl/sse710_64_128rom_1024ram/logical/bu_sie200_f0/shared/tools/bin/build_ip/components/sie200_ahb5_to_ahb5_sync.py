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


class sie200_ahb5_to_ahb5_sync(sie200_base.BridgeComponent):
    def __init__(self):
        super(sie200_ahb5_to_ahb5_sync, self).__init__()

        self.name = "sie200_ahb5_to_ahb5_sync"
        self.version = "r0p0_0"
        self.description = "AHB5 to AHB5 Sync Bridge"

        parameter = base.Parameter("BURST")
        parameter.description = "Burst transfers are supported"
        parameter.value = "0"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        parameter = base.Parameter("EXT_GATE_SYNC")
        parameter.description = "External Gating Request signal is synchronous"
        parameter.value = "0"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        ahbif_s = sie200_base.ahbif("_s","")
        ahbif_m = sie200_base.ahbinitif("_m","",1,1)
        ahbif_s.bridges.append((ahbif_m.name, "true"))
        subspaceMaps = [
            base.SubspaceMap(ahbif_m.name,"0",ahbif_s.name),
        ]
        self.submaps.extend(subspaceMaps)

        interfaces = [
            sie200_base.dyncfgif("cfg_gate_resp","hclk"),
            sie200_base.handshakeif("ext_gate"),
            ahbif_s,
            ahbif_m
        ]

        self.interfaces.extend(interfaces)

        files = [
            os.path.join("..","..","models","cells","generic","sie200_or.v"),
            os.path.join("..","..","models","cells","generic","sie200_xor.v"),
            os.path.join("..","..","models","cells","generic","sie200_flop.v"),
            os.path.join("..","..","models","cells","generic","sie200_sync.v"),
            os.path.join("..","..","shared","verilog","sie200_cdc","verilog","sie200_launch.v"),
            os.path.join("..","..","shared","verilog","sie200_ahb5_access_ctrl_core","verilog","sie200_ahb5_access_ctrl_core_s.v"),
            os.path.join("..","..","shared","verilog","sie200_ahb5_error_canc","verilog","sie200_ahb5_error_canc.v"),
            os.path.join("..","..",self.name,"verilog",self.name + "_core.v")
        ]
        self.files.extend(files)

        self.vc_files.append(os.path.join("..","..","shared","verilog","sie200_ahb5_error_canc","verilog","sie200_ahb5_error_canc.vc"))
        self.vc_files.append(os.path.join("..","..","shared","verilog","sie200_ahb5_access_ctrl_core","verilog","sie200_ahb5_access_ctrl_core.vc"))

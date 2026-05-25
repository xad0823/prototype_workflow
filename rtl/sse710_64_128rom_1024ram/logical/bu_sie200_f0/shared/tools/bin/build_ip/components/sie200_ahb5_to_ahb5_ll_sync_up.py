#!/usr/bin/env python
#-----------------------------------------------------------------------------
#  The confidential and proprietary information contained in this file may
#  only be used by a person authorised under and to the extent permitted
#  by a subsisting licensing agreement from ARM Limited or its affiliates.
#
#             (C) COPYRIGHT 2017 ARM Limited or its affiliates.
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


class sie200_ahb5_to_ahb5_ll_sync_up(sie200_base.BridgeComponent):
    def __init__(self):
        super(sie200_ahb5_to_ahb5_ll_sync_up, self).__init__()

        self.name = "sie200_ahb5_to_ahb5_ll_sync_up"
        self.version = "r0p0_0"
        self.description = "AHB5 to AHB5 Low Latency Sync Up Bridge"


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

        ahbif_s = sie200_base.ahbif(suffix="_s", clkrst_suffix="")
        ahbif_m = sie200_base.ahbinitif(suffix="_m", clkrst_suffix="", master=1, nonsec=1, clken=1)
        ahbif_s.bridges.append((ahbif_m.name, "true"))
        subspaceMaps = [
            base.SubspaceMap(ahbif_m.name,"0",ahbif_s.name),
        ]
        self.submaps.extend(subspaceMaps)

        interfaces = [
            ahbif_s,
            ahbif_m,
            sie200_base.irqif("ahb5_ll_sync_up", clk_name="hclk"),
            sie200_base.internalInterrupt("ahb5_ll_sync_up", sig_clear = 1, clk_name="hclk")
        ]

        self.interfaces.extend(interfaces)

        files = [
            os.path.join("..","..",self.name,"verilog",self.name + "_core.v"),
            os.path.join("..","..","shared","verilog","sie200_ahb5_ll_error_canc","verilog","sie200_ahb5_ll_error_canc.v"),
            os.path.join("..","..","shared","verilog","sie200_ahb5_ll_write_buffer","verilog","sie200_ahb5_ll_write_buffer.v")
        ]
        self.files.extend(files)

        self.vc_files.append(os.path.join("..","..","shared","verilog","sie200_ahb5_ll_error_canc","verilog","sie200_ahb5_ll_error_canc.vc"))
        self.vc_files.append(os.path.join("..","..","shared","verilog","sie200_ahb5_ll_write_buffer","verilog","sie200_ahb5_ll_write_buffer.vc"))

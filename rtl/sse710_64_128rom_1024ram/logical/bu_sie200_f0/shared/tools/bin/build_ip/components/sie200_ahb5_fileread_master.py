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
#     Checked In : Mon Mar 20 09:30:35 2017 +0000
#     Revision   : 1cf3d94
#     Release    : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
# ----------------------------------------------------------------------------
#  Purpose :
# ----------------------------------------------------------------------------

import os
import base
import sie200_base

class ahb5_fileread_master_adhoc_if(base.Interface):
    def __init__(self):
        super(ahb5_fileread_master_adhoc_if, self).__init__()

    def Configure(self, parameters):

        vectorPorts = [
            ("linenum", "out",   31, 0)
        ]
        self.vectorPorts.extend(vectorPorts)


class sie200_ahb5_fileread_master(sie200_base.BridgeComponent):
    def __init__(self):
        super(sie200_ahb5_fileread_master, self).__init__()

        self.name = "sie200_ahb5_fileread_master"
        self.version = "r0p0_0"
        self.description = "AHB5 Fileread Master"


        self.GetParameter("ADDR_WIDTH").usage = "constant"
        self.GetParameter("DATA_WIDTH").enumerations = ["32", "64"]
        self.GetParameter("DATA_WIDTH").minimum = "32"
        self.GetParameter("DATA_WIDTH").maximum = "64"


        parameter = base.Parameter("MASTER_VALUE")
        parameter.description = "Value driven to hmaster port"
        parameter.value = "1"
        parameter.minimum = "0"
        parameter.maximum = "15"
        self.parameters.append(parameter)

        parameter = base.Parameter("STIM_ARRAY_SIZE")
        parameter.description = "stimulus data array size: should be large enough to hold entire stimulus data file"
        parameter.value = "5000"
        parameter.minimum = ""
        parameter.maximum = ""
        self.parameters.append(parameter)

        parameter = base.Parameter("STIMULUS_FILE_NAME","required","string")
        parameter.description = "stimulus data file name"
        parameter.value = "filestim.m3d"
        parameter.minimum = ""
        parameter.maximum = ""
        self.parameters.append(parameter)

        parameter = base.Parameter("MESSAGE_TAG","required","string")
        parameter.description = "tag on each FileReader message"
        parameter.value = "FileReader:"
        parameter.minimum = ""
        parameter.maximum = ""
        self.parameters.append(parameter)

        interfaces = [
            sie200_base.ahbinitif("","",1,1),
            ahb5_fileread_master_adhoc_if()
        ]
        self.interfaces.extend(interfaces)

        files = [
            os.path.join("..","..",self.name,"verilog","sie200_ahb5_fileread_core.v"),
            os.path.join("..","..",self.name,"verilog","sie200_ahb5_fileread_funnel.v")
        ]
        self.files.extend(files)


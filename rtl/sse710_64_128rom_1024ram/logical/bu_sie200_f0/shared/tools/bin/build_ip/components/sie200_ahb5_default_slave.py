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
#     Checked In : Tue Aug 9 08:12:07 2016 +0100
#     Revision   : 8ac0ed4
#     Release    : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
# ----------------------------------------------------------------------------
#  Purpose :
# ----------------------------------------------------------------------------

import base
import sie200_base

class sie200_ahb5_default_slave(base.Component):
    def __init__(self):
        super(sie200_ahb5_default_slave, self).__init__()

        self.name = "sie200_ahb5_default_slave"
        self.version = "r0p0_0"
        self.description = "AHB5 Default Slave"

        interfaces = [
            sie200_base.ahbdefslvif()
        ]
        self.interfaces.extend(interfaces)

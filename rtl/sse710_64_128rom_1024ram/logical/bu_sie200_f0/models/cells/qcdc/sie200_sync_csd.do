# -----------------------------------------------------------------------------
#  The confidential and proprietary information contained in this file may
#  only be used by a person authorised under and to the extent permitted
#  by a subsisting licensing agreement from Arm Limited or its affiliates.
# 
#         (C) COPYRIGHT 2017-2019 Arm Limited or its affiliates.
#             ALL RIGHTS RESERVED
# 
#  This entire notice must be reproduced on all copies of this file
#  and copies of this file may only be made by a person if such person is
#  permitted to do so under the terms of a subsisting license agreement
#  from Arm Limited or its affiliates.
# 
# 
# 
# 
#       Release Information : SSE710-r0p0-00eac0
# 
# -----------------------------------------------------------------------------


# This is the custom synchroniser definition file for the synchroniser module sie200_sync

# sie200_sync is a custom synchroniser. This is the module that instantiates 2ffs as synchronisers.
cdc custom sync   sie200_sync -type custom_2dff
# The synchroniser synchronises its d input to its q output.
cdc custom sync   data                      -from d -to q -module sie200_sync
# Clock port of the sync module is clk.
hier clock        clk       -module sie200_sync
# Clock port of the sync module is vclk. This port doesn't exist actually but is virtual.
hier clock        vclk      -module sie200_sync -virtual
# Asynch reset port of the sync module is reset_n
hier reset        reset_n    -module sie200_sync -active_low -async
# Report all synchroniser
# d is assigned to the virtual clock, hence QCDC will analyse every path towards d.
# The virtual clock created for each instance of the synchroniser is unique and asynchronous to other clock groups.
hier port domain  d   -module sie200_sync -clock vclk 
# Clock group of q synchronised output will inherit clock group of the clk input of the module instance.
hier port domain  q         -module sie200_sync -clock clk 
# Combo logic before the synchroniser generates violation. These violations have to be reviewed manually on the schematic viewer,
# and waived as 'verified' or marked as 'bug'.
hier assume port  d   -module sie200_sync -no_combo 

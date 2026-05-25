#!/usr/bin/env sh
# -----------------------------------------------------------------------------
# The confidential and proprietary information contained in this file may
# only be used by a person authorised under and to the extent permitted
# by a subsisting licensing agreement from Arm Limited or its affiliates.
#
#               (C) COPYRIGHT 2012-2021 Arm Limited or its affiliates.
#                   ALL RIGHTS RESERVED
#
# This entire notice must be reproduced on all copies of this file
# and copies of this file may only be made by a person if such person is
# permitted to do so under the terms of a subsisting license agreement
# from Arm Limited or its affiliates.
#
#
#
# Release Information : SSE710-r0p0-00eac0
#
# ------------------------------------------------------------------------------
# Purpose : Return the list of available packages for a given configuration.yaml
#
# -----------------------------------------------------------------------------

set -e 
YAML_FILE=`echo $@ | sed -re "s|^([^:]+):?.*|\1|"`
if [ -e "$LUNA_WORK_PATH/$YAML_FILE" ]; then
  grep -e "^[{a-z}|{A-Z}|{0-9}|_]*:" $YAML_FILE | sed -e 's/://g' -e "s/^/$YAML_FILE:/g"
fi

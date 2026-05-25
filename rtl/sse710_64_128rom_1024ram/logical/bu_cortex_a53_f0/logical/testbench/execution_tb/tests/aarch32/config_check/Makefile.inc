#-----------------------------------------------------------------------------
# The confidential and proprietary information contained in this file may
# only be used by a person authorised under and to the extent permitted
# by a subsisting licensing agreement from ARM Limited.
#
#            (C) COPYRIGHT 2013-2014 ARM Limited.
#                ALL RIGHTS RESERVED
#
# This entire notice must be reproduced on all copies of this file
# and copies of this file may only be made by a person if such person is
# permitted to do so under the terms of a subsisting license agreement
# from ARM Limited.
#
#      SVN Information
#
#      Checked In          : $Date: 2013-02-07 13:41:55 +0000 (Thu, 07 Feb 2013) $
#
#      Revision            : $Revision: 236479 $
#
#      Release Information : CORTEXA53-r0p4-00rel0
#
#-----------------------------------------------------------------------------
# Makefile include file for AArch32 config_check. This must be included from the
# top-level Makefile; it is not a standalone Makefile.
#-----------------------------------------------------------------------------

# Note these variables must only be used in places where Make reads their
# immediate values rather than their deferred values.  This is because all
# the include files use the same variables and the deferred evaluation will
# yeild the last values set by the last include file.  They can be used in the
# target and prerequisite sections of rule definitions, which are evaluated
# immediately, but not in the recipe, where evaluation is deferred.
srcdir := aarch32/config_check
dstdir := aarch32/config_check
target := $(dstdir)/config_check.elf
srcs   := $(wildcard $(srcdir)/*.s)
objs   := $(patsubst %.s,%.o,$(srcs))

$(objs): %.o: %.s
	@echo " [ASM ] $<"
	@$(ASM32) $(ASM_OPTS_AARCH32) $< -o $@

$(target): $(objs) $(aarch32_bootobj)
	@echo " [LINK] $<"
	@$(LINK32) $(LINK_OPTS_ASM_AARCH32) $^ -o $@


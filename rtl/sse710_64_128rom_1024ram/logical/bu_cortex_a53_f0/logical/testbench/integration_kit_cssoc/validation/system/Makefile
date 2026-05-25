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
#      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
#
#      Revision            : $Revision: 283836 $
#
#      Release Information : CORTEXA53-r0p4-00rel0
#-----------------------------------------------------------------------------

################################################################################
#
# Makefile for test images
#
# This Makefile defines the paths to source files and then calls
# the necessary Makefiles for each image
#


################################################################################
#
# Remove any current implicit rules and ensure intermediate files are kept
.SUFFIXES:
.SECONDARY:
.IMPLICIT:


################################################################################
#
# Set sensible default values - these should be overriden when called
#
TESTNAME := discovery
OBJDIR	 := .


################################################################################
#
# Test Source Locations
#
TESTDIR         = ${CSSOC_INSTALL_DIR}/shared/validation/tests

INCLUDES	= -I . \
		-I $(TESTDIR)/cxdt \
		-I $(TESTDIR)/generic \
		-I $(TESTDIR)/partlib \
		-I $(TESTDIR)/src

VPATH		= ./:$(TESTDIR)/cxdt:$(TESTDIR)/generic:$(TESTDIR)/partlib:$(TESTDIR)/src


################################################################################
#
# Dependencies
#
DEPS		=	Makefile

# Processor Necessities
DEPS		+=	cx_types.h cx_generic.h

# Component Library
DEPS		+=	cx_components.h


################################################################################
#
# Objects
#
OBJS		=	select_cpu.o cx_components.o cx_system.o common.o cx_enums.o


################################################################################
#
# TESTDEFINES - Convert Make Variables to C preprocessor #define values
#
TESTDEFINES	= -DTESTNAME=$(TESTNAME)

# Default: If CPU is not defined test will run in the CXDT
ifndef CPU
TESTDEFINES 	+= -DCPUEXE=0 -DCPU=0 -DCXDT=1
else
TESTDEFINES	+= -DCPUEXE=1 -DCPU=$(CPU) 

ifndef CXDT
TESTDEFINES	+= -DCXDT=0
else
TESTDEFINES	+= -DCXDT=$(CXDT)
endif
endif

ifdef DBG
TESTDEFINES += -DCX_MSG_DBG=${DBG}
endif

################################################################################
#
# Image Creation
#
# Build one image for each separate memory in the SoC
#
SUBMAKEFILES = Makefile.CXDT $(wildcard Makefile.IMAGE*)
SUBMAKECLEAN = $(addsuffix .clean, $(SUBMAKEFILES))

#
# Export required variables to the sub-make files
#
export TESTNAME OBJDIR TESTDIR INCLUDES VPATH TESTDEFINES DEPS OBJS

#
# All targets are PHONY - dependencies are handled by the sub-make files
#
.PHONY: clean $(SUBMAKECLEAN) $(SUBMAKEFILES)


#
# Make <testname> must call all sub-make files and create the OBJDIR
#
$(TESTNAME): $(OBJDIR) $(SUBMAKEFILES)


$(SUBMAKEFILES):
	@echo "TESTDEFINE = $(TESTDEFINES)"
	make -k -i -j -e -f $@


$(OBJDIR):
	@echo "Creating Object Dir"
	mkdir -p $(OBJDIR)


################################################################################
#
# Clean
#
clean: $(SUBMAKECLEAN)

$(SUBMAKECLEAN): %.clean:
	make -j -e -f $* clean


# EOF

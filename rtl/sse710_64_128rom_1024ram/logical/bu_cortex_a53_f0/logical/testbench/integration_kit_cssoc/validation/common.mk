#-----------------------------------------------------------------------------
# The confidential and proprietary information contained in this file may
# only be used by a person authorised under and to the extent permitted
# by a subsisting licensing agreement from ARM Limited.
#
# (C) COPYRIGHT 2013-2014 ARM Limited.
# ALL RIGHTS RESERVED
#
# This entire notice must be reproduced on all copies of this file
# and copies of this file may only be made by a person if such person is
# permitted to do so under the terms of a subsisting license agreement
# from ARM Limited.
#
#  SVN Information
#
#  File Name : common.mk
#
#  Checked In : $Date: 2014-07-25 11:01:14 +0100 (Fri, 25 Jul 2014) $
#
#  Revision : $Revision: 285802 $
#
#  Release Information : CORTEXA53-r0p4-00rel0
#
#-----------------------------------------------------------------------------
#
# <soc_tb>/validation/common.mk
#
# This (Make) include file controls:
#
# - Construction of the TEST_CASE list of tests to execute on the SoC.
#
# - Generation of binaries for each TEST_CASE by executing
#   <soc_tb>/validation/system/Makefile
#
#
# If the following variables are defined, the generated TEST_CASE list will
# be constrained accordingly.
#
# TESTNAME
# CXDT
# CPU
#
#
# You must modify this file if your SoC contains more than 40 processors
#


##############################################################################
# MODIFICATION: OPTIONAL
#-----------------------------------------------------------------------------
# Set or constrain values for CPU
#
# Possible values for CPU: NONE 0 1 ... <number of processors -1>
#
##############################################################################

ifndef CPU
CPU = NONE
else
CPU += NONE
override CPU := $(filter NONE 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39, $(sort ${CPU}))
endif


##############################################################################
# MODIFICATION: NONE
#-----------------------------------------------------------------------------
# Set or constrain values for CXDT
#
# Possible values for CXDT: 0 1
#
##############################################################################

ifndef CXDT
CXDT = 0 1
else
override CXDT := $(filter 0 1, ${CXDT})
ifeq (,${CXDT})
override CXDT := 1
endif
endif


##############################################################################
# MODIFICATION: NONE
#-----------------------------------------------------------------------------
# Add CoreSight Soc-400 test names to TESTNAME and TEST_LIST_*
#
##############################################################################

TESTNAME += discovery helloworld integration_triggers integration_atb cross_halt trace partlibcheck interrupt memap_check

# list of tests with CPU and CXDT enabled at the same time
TEST_LIST_CXDTCPU += trace trace_all

# list of tests with only CXDT enabled
TEST_LIST_CXDTONLY += partlibcheck memap_check

# list of tests with only CPU enabled
TEST_LIST_CPUONLY += interrupt

# list of tests valid with either CXDT or CPU enabled
TEST_LIST_NORMAL += discovery helloworld integration_triggers integration_atb cross_halt


##############################################################################
# MODIFICATION: NONE
#-----------------------------------------------------------------------------
# Set or constrain Verilog Simulator
#
##############################################################################

ifndef SIMULATOR
SIMULATOR = VCS
else
override SIMULATOR := $(filter VCS MTI IUS, ${SIMULATOR})
ifeq (,${SIMULATOR})
override SIMULATOR := VCS
endif
endif


##############################################################################
# MODIFICATION: NONE
#-----------------------------------------------------------------------------
# Construct TEST_CASE list of all test combinations to run
#
##############################################################################

#CXDTCPU cases
ifneq (,$(findstring 1,${CXDT}))
TEST_CASE += $(foreach test, $(filter ${TEST_LIST_CXDTCPU}, ${TESTNAME}), $(foreach cpu, $(filter-out NONE, ${CPU}), ${test}-CXDT-1-CPU-${cpu}))
endif

#CXDTONLY cases
ifneq (,$(findstring 1,${CXDT}))
ifneq (,$(findstring NONE,${CPU}))
TEST_CASE += $(foreach test, $(filter ${TEST_LIST_CXDTONLY}, ${TESTNAME}), ${test}-CXDT-1-CPU-NONE)
endif
endif

#CPUONLY cases
ifneq (,$(findstring 0,${CXDT}))
TEST_CASE += $(foreach test, $(filter ${TEST_LIST_CPUONLY}, ${TESTNAME}), $(foreach cpu, $(filter-out NONE, ${CPU}), ${test}-CXDT-0-CPU-${cpu}))
endif

#NORMAL cases
ifneq (,$(findstring 1,${CXDT}))
ifneq (,$(findstring NONE,${CPU}))
TEST_CASE += $(foreach test, $(filter ${TEST_LIST_NORMAL}, ${TESTNAME}), ${test}-CXDT-1-CPU-NONE)
endif
endif
ifneq (,$(findstring 0,${CXDT}))
TEST_CASE += $(foreach test, $(filter ${TEST_LIST_NORMAL}, ${TESTNAME}), $(foreach cpu, $(filter-out NONE, ${CPU}), ${test}-CXDT-0-CPU-${cpu}))
endif

override TEST_CASE := $(sort ${TEST_CASE})


##############################################################################
# MODIFICATION: NONE
#-----------------------------------------------------------------------------
# Set or constrain test DBG debugging option
#
##############################################################################

# DBG construction to be used on c compilation
ifdef DBG
DBG := $(filter 0 1, ${DBG})
ifeq (,${DBG})
DBG := 0
endif
else
DBG := 0
endif



##############################################################################
# MODIFICATION: NONE
#-----------------------------------------------------------------------------
# Help information target
#
##############################################################################

.PHONY: help
help :
	@echo "####################################################################################"; \
	echo ""; \
	echo "CoreSight SoC-400 validation/Makefile HELP information (from common.mk)"; \
	echo ""; \
	echo "Usage: Make [options] target"; \
	echo ""; \
	echo "OPTIONS:"; \
	echo ""; \
	echo "	TESTNAME=<name>"; \
	echo "		Constrain to specific test or tests. Available tests are:"; \
	echo "		${TESTNAME}"; \
	echo ""; \
	echo "	CXDT=(0|1)"; \
	echo "		Constrain to testcases that run with CXDT=0 or CXDT=1."; \
	echo ""; \
	echo "	CPU=(NONE|0..n-1)"; \
	echo "		Constrain to testcases that run with no CPU (CPU=NONE) or with given CPU number."; \
	echo ""; \
	echo "	SIMULATOR=(VCS|MTI|IUS)"; \
	echo "		Select Verilog simulator."; \
	echo ""; \
	echo "	GUI=(0|1)"; \
	echo "		GUI=1 selects Verilog simulation interactive mode (for debugging)."; \
	echo ""; \
	echo "	DBG=(0|1)"; \
	echo "		Set DBG=1 during test compilation to enable additional low-level debugging messages."; \
	echo ""; \
	echo ""; \
	echo "TARGET:"; \
	echo ""; \
	echo "	all"; \
	echo "		Compile and simulate all tests."; \
	echo ""; \
	echo "	run"; \
	echo "		Run (simulate) tests. Perform rtl_compile and image steps if required."; \
	echo ""; \
	echo "	image"; \
	echo "		Compile test images."; \
	echo ""; \
	echo "	rtl_compile"; \
	echo "		Compile Verilog for the SoC and testbench."; \
	echo ""; \
	echo "	query"; \
	echo "		List the tests that will run. Use this option to check the effect of any OPTIONS specified."; \
	echo ""; \
	echo "	report"; \
	echo "		Summarise the results of all executed tests."; \
	echo ""; \
	echo "	clean_all"; \
	echo "		Delete all generated logfiles, test and simulation binaries."; \
	echo ""; \
	echo "	clean_image"; \
	echo "		Cleans the bin directory."; \
	echo ""; \
	echo "	clean_run"; \
	echo "		Cleans the run directory."; \
	echo ""; \
	echo "	clean_logs"; \
	echo "		Cleans log files."; \
	echo ""; \
	echo "	help"; \
	echo "		Display this help information."; \
	echo ""; \
	echo "####################################################################################"

##############################################################################
# MODIFICATION: NONE
#-----------------------------------------------------------------------------
# Query target lists the testcases that will be executed
#
##############################################################################

.PHONY: $(foreach test, ${TEST_CASE}, query/${test})
$(foreach test, ${TEST_CASE}, query/${test}) : query/% :
	@echo "$*"

.PHONY: query
query: $(foreach test, ${TEST_CASE}, query/${test})
	@echo SIMULATOR: ${SIMULATOR}; \
	 echo DBG: ${DBG}


##############################################################################
# MODIFICATION: NONE
#-----------------------------------------------------------------------------
# Rules and targets to generate binary images for each test case
#
##############################################################################

# the MAKEFLAGS variable stores the variables to be passed to the sub-Make on the system dir
# it basically chop the TEST_CASE variable to accomodate the pieces in the right place

bin/%/compilation_complete: override MAKEFLAGS = $(strip $(subst CPU=NONE,,TESTNAME=$(word 1, $(subst -, , $*)) CXDT=$(word 3, $(subst -, , $*)) CPU=$(word 5, $(subst -, , $*)) OBJDIR=../bin/$* DBG=${DBG}))

# rule to construct the image/binary files

#.PRECIOUS: bin/%/compilation_complete
bin/%/compilation_complete :
	@echo "Image: bin/$*"; \
	rm -rf bin/$*; \
	mkdir -p bin/$*; \
	cd ${PWD}/system; \
	echo "make -j -f Makefile ${MAKEFLAGS}"; \
	make -j -f Makefile ${MAKEFLAGS}; \
	if [ $$? -eq 0 ];then touch ../$@;else echo "$* COMPILATION FAILED: do \> more logs/$*.log"; exit 1;fi;

# construct the image for all test cases

.PHONY: image
image : $(foreach test, ${TEST_CASE}, bin/${test}/compilation_complete)


##############################################################################
# MODIFICATION: NONE
#-----------------------------------------------------------------------------
# Rules and targets to generate test report
#
##############################################################################

logs/%.xml:
	@if [ -e "logs/$*.log" ]; then \
		echo "${CSSOC_INSTALL_DIR}/shared/tools/bin/gen_simulation_result.pl logs/$*.log $@"; \
		${CSSOC_INSTALL_DIR}/shared/tools/bin/gen_simulation_result.pl logs/$*.log $@; \
		exit 0; \
	fi

.PHONY: report
report: $(foreach test, $(TEST_CASE), clean_logs/${test}.xml) | $(foreach test, $(TEST_CASE), logs/${test}.xml)
	@${CSSOC_INSTALL_DIR}/shared/tools/bin/merge_results.pl ${TEST_CASE} > report.csv; \
	column -t -s , report.csv; \
	if [ -e "$(EXE_DIR)/$(WORK)" ]; then \
		echo "  RTL Compilation: $(EXE_DIR)/$(WORK)"; \
	else \
		echo "  RTL Compilation: Not available for ${SIMULATOR}"; \
	fi


##############################################################################
# MODIFICATION: NONE
#-----------------------------------------------------------------------------
# Rules and targets for cleaning
#
##############################################################################

.PHONY: $(foreach test, ${TEST_CASE}, clean_logs/${test}.log clean_run/${test} clean_bin/${test}) clean_logs clean_image clean_run
$(foreach test, ${TEST_CASE}, clean_logs/${test}.log clean_logs/${test}.xml clean_run/${test} clean_bin/${test}) : clean_% :
	@echo "Cleaning: $*"; \
	rm -rf $*;

clean_image : $(foreach test, ${TEST_CASE}, clean_bin/${test})

clean_logs : $(foreach test, ${TEST_CASE}, clean_logs/${test}.log clean_logs/${test}.xml)

clean_run : $(foreach test, ${TEST_CASE}, clean_run/${test})


##############################################################################
# MODIFICATION: NONE
#-----------------------------------------------------------------------------
# Rules and targets to run tests
#
##############################################################################

# run simulation for each test case
.PHONY: run
run : clean_logs | $(foreach test, ${TEST_CASE}, logs/${test}.log)


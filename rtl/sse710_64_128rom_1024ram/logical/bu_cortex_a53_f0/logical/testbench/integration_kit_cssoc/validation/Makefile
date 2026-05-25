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
#      Checked In          : $Date: 2014-07-25 11:01:14 +0100 (Fri, 25 Jul 2014) $
#
#      Revision            : $Revision: 285802 $
#
#      Release Information : CORTEXA53-r0p4-00rel0
#-----------------------------------------------------------------------------

# *********************************************************************
# Top Makefile
# 
# This is the top makefile for compiling the testbech, setting up various defines for 
# the sub makefile in the validation/system directory for compiling the test, and running 
# the test
# *********************************************************************

#  check CSSOC_INSTALL_DIR defined
ifeq ($(CSSOC_INSTALL_DIR), )
  $(error "The variable CSSOC_INSTALL_DIR not defined yet! please first define it")
endif

#  check CSSYS_UPV8_RTL defined, you may use a different varialbe for your 
#  CoreSight system
ifeq ($(CSSYS_UPV8_RTL), )
  $(error "The variable CSSYS_UPV8_RTL not defined yet! please first define it")
endif

#setup the path for the Cortex-A53 RTL path, you may need to modify this for your system
export CA53_RTL     := $(PWD)/../../../../logical
 
##############################################################################
# MODIFICATION: MANDATORY
#-----------------------------------------------------------------------------
# Number of processors in your SoC under test
#
# CPU Must list the indices for each processor in your SoC
#
# Example: For a SoC with a single processor
# CPU = 0
#
# Example: For a SoC with one MP4 proceesor plus a single processor subsystem
# CPU = 0 1 2 3 4 5
#
##############################################################################

CPU = 0


##############################################################################
# MODIFICATION: OPTIONAL
#-----------------------------------------------------------------------------
# Tests that are not part of the CoreSight SoC-400 product deliverables
#
# For each new test that you create, you must add the testname to the
# approptiate TEST_LIST_* variable below and to the TESTNAME variable,
# if it is intended to run by default when calling Makefile.
#
# Any tests listed here will be executed in addition to the standard
# CoreSight SoC-400 tests.
#
#
# *********************************************************************
# Example: Test must run on each CPU and CXDT in turn
# TEST_LIST_NORMAL = mytest
#
# Example: Test must run only on the CXDT (CXDT=1 and CPU=NONE)
# TEST_LIST_CXDTONLY = mytest
#
# Example: Test must run only on each CPU (CXDT=0 and CPU != NONE)
# TEST_LIST_CPUONLY = mytest
#
# Example: Test must run on each CPU and CXDT concurrently (CXDT=1 and CPU != NONE)
# TEST_LIST_CXDTCPU = mytest
#
##############################################################################

TEST_LIST_NORMAL 	=
TEST_LIST_CXDTONLY	=
TEST_LIST_CPUONLY	=
TEST_LIST_CXDTCPU =

TESTNAME =

# *********************************************************************
# For the IK testbench, it only support CXDT=1 and CPU=NONE, test will be running on the CXDT,
# you can extend the IK testbench to support running tests on CPU by providing a suitable 
# interconnection for CPU to access the Debug APB interface
#
#


# Directory from where the simulations are run
MAINDIR = $(PWD)

# Directory where the tbench files are present
RTL_DIR = $(PWD)/../verilog

# Platform on which testcases are run
PLATFORM = linux

# Directory where the RTL executable is present
EXE_DIR = $(PWD)/${SIMULATOR}/${PLATFORM}

SIMULATOR = VCS

# WORK variable is used to construct the tool simulation command
ifeq (${SIMULATOR},VCS)
  WORK = simv
else
  ifeq (${SIMULATOR},MTI)
    WORK = work
  else
    WORK = INCA_libs
  endif
endif


# *********************************************************************
# simulator commands for rtl simulation
# *********************************************************************

# Include user options from the make.cfg configuration file
# this can setup the options for tarmac, OVL, 64 bit simulation 
# etc
include ../make.cfg

# Tools
# testbench render tool
TB_GENERATOR  := ../../shared/tools/bin/execution_tb_generator.pl

# Files
rtl_config    := ../../../config/CORTEXA53.cfg
intkit_config := ../intkit_tb.cfg
tb_unrendered := ../../execution_tb/verilog/cortexa53_execution_tb_unconfigured.v
tb_rendered   := ../verilog/cortexa53_intkit_tb.v

vcfiles       := ../../../verilog/intkit_tb.vc

# Options (modified depending on configuration) 
BUILDOPTS :=
PLUSARGS  :=

# Setup DSM model related variables
ifeq ($(strip $(USE_DSM)), yes)
  ifeq ($(DSM_MODEL_PATH), )
    $(error "The variable DSM_MODEL_PATH not defined yet! please first define it")
  endif
  export LD_LIBRARY_PATH:= $(LD_LIBRARY_PATH):$(DSM_MODEL_PATH)
  export DSM_MODEL_PATH_CORTEXA53_DSM= $(DSM_MODEL_PATH)
endif


# If tarmac is enabled define the shared object location, depending on whether
# the testbench is configured for 32-bit or 64-bit simulation, and add the
# necessary options to the environment.
ifeq ($(strip $(TARMAC)), yes)
  ifeq ($(strip $(SIM_64BIT)), yes)
    tarmac_so := $(CA53_RTL)/ca53univent/build_x86_64/lib/ca53_tarmac_dpi.so
  else
    tarmac_so := $(CA53_RTL)/ca53univent/build_x86_32/lib/ca53_tarmac_dpi.so
  endif

  # Export the tarmac location so that sub-processes can find it
  ifeq ($(strip $(USE_DSM)), yes)
    export CA53_TARMAC_EXECUTABLE= $(DSM_MODEL_PATH)/ca53_tarmac_decode --plain
  else 
    # Always add the tarmac VC file when tarmac is selected
    override vcfiles  += ../../../verilog/intkit_tb_tarmac.vc 
    export CA53_TARMAC_EXECUTABLE = $(CA53_RTL)/ca53univent/build_x86_32/bin/ca53_tarmac_decode --plain
  endif

  # Set plusarg to enable tarmac
  override PLUSARGS += +ca53_tarmac_enable
endif


# If OVLs are enabled then we add the OVL defines to BUILDOPTS.  
ifeq ($(strip $(OVL_ASSERTIONS)), yes)
  override BUILDOPTS += +define+ARM_ASSERT_ON +define+ASSERT_ON+OVL_ASSERT_ON +define+OVL_VERILOG
endif

# Construct sequence of '-f <vcfile>' for every VC file used. This is a
# recursively-expanded variable so that any additional VC files will be
# represented when the variable is used.
VC_OPTS = $(patsubst %,-f %,$(vcfiles))



################################################################################
# Simulator-specific setup
#
#   Construct simulator compile-time and run-time arguments based on the
#   configuration options
################################################################################

# Basic options
MTI_COMPILE_OPTS := -quiet +acc=blnr -noincr -timescale 1ns/10ps -l ${PWD}/rtl_compile_mti.log
MTI_RUN_OPTS     := -quiet cortexa53_intkit_tb -lib ${EXE_DIR}/${WORK} -suppress 2129 -suppress 3691
VCS_COMPILE_OPTS := +v2k -noIncrComp -q -sverilog -debug_all -timescale=1ns/10ps -l ${PWD}/rtl_compile_vcs.log
VCS_RUN_OPTS     := 
IUS_COMPILE_OPTS := -elaborate -q +access+rwc -timescale 1ns/10ps
IUS_RUN_OPTS     := -R -nclibdirname ${EXE_DIR}/${WORK} -access +rwc

# Tarmac options
ifeq ($(strip $(TARMAC)), yes)
  MTI_RUN_OPTS     += -sv_lib $(basename $(tarmac_so))
  VCS_COMPILE_OPTS += -sverilog $(tarmac_so)
  IUS_COMPILE_OPTS += -sv $(tarmac_so)
endif

# 64-bit simulation
ifeq ($(strip $(SIM_64BIT)), yes)
  VCS_COMPILE_OPTS += -full64
  MTI_COMPILE_OPTS += -64
  MTI_RUN_OPTS     += -64
  IUS_COMPILE_OPTS += -64bit
  IUS_RUN_OPTS     += -64bit
endif

# DSM options
ifeq ($(strip $(USE_DSM)), yes)
  VCS_COMPILE_OPTS +=  +acc -P $(DSM_MODEL_PATH)/CORTEXA53_DSM.tab $(DSM_MODEL_PATH)/CORTEXA53_DSM.so
  MTI_RUN_OPTS += -pli $(DSM_MODEL_PATH)/CORTEXA53_DSM.so
  IUS_COMPILE_OPTS += +loadvpi=$(DSM_MODEL_PATH)/CORTEXA53_DSM.so:registerVPI
endif

ifeq ($(strip $(USE_DSM)), yes)
  VCS_CMD = vcs $(VC_OPTS)  -y $(DSM_MODEL_PATH) $(VCS_COMPILE_OPTS) $(BUILDOPTS)
  MTI_CMD = vlib ${WORK}; vlog $(VC_OPTS) -y $(DSM_MODEL_PATH) $(MTI_COMPILE_OPTS) $(BUILDOPTS)
  IUS_CMD = irun $(VC_OPTS) -y $(DSM_MODEL_PATH) $(IUS_COMPILE_OPTS) $(BUILDOPTS)
else
  VCS_CMD = vcs $(VC_OPTS) $(VCS_COMPILE_OPTS) $(BUILDOPTS)
  MTI_CMD = vlib ${WORK}; vlog $(VC_OPTS) $(MTI_COMPILE_OPTS) $(BUILDOPTS)
  IUS_CMD = irun $(VC_OPTS) $(IUS_COMPILE_OPTS) $(BUILDOPTS)
endif

# GUI variable construction to be used on simualtion execution
ifdef GUI
  override GUI = -gui
else
  ifeq (${SIMULATOR},MTI)
    GUI = -c
  endif
endif



# AARCH64/AARCH32 Mode Selection to be used on Top-Makefile/System-Makefile
# TEST_ARCH is set to aarch64 for the A53_System to run on AARCH64 mode --> Default Mode
# TEST_ARCH is set to aarch32 for the A53_System to run on AARCH32 mode
ifndef TEST_ARCH
  TEST_ARCH := aarch64
else
  override TEST_ARCH := $(filter aarch64 aarch32, ${TEST_ARCH})
endif

# Check for valid architecture
ifneq ($(TEST_ARCH), aarch32)
ifneq ($(TEST_ARCH), aarch64)
  $(error "TEST_ARCH must be aarch32 or aarch64")
endif
endif

# If the testcase is an AArch64 test we automatically add the plusarg to
# start in AArch64.  Use 'override' so that command-line arguments are
# honored but don't prevent internal modification.
ifeq ($(TEST_ARCH), aarch64)
  override PLUSARGS += +arch64
endif

#export the PLUSARGS for sub-makefiles
export PLUSARGS

# User help menu
ik_help: help
	@echo ; \
	 echo "This is the top Makefile for CA53 Integration Kit"; \
	 echo "make or make ik_help shows this extra information"; \
	 echo; \
	 echo "The extra command line options for CA53 Integration Kit are: "; \
	 echo "  TEST_ARCH=<aarch64 | aarch32>"; \
	 echo "            To choose the Cortex-A53 arch state";  \
	 echo ""; \
	 echo "  PLUSARGS=\"<plusarg options>\""; \
	 echo "  suppported options are:\"+dumpon=<time> +dumpoff=<time> +bigend\""; \
	 echo "                          +dumpon/off to enable VCD dump and specify the on and off time"; \
	 echo "                          +bigend to enable big-endian mode"; \
	 echo ""; \
	 echo "ALL THE TARGETS WORKS UPON THE POSSIBLE COMBINATIONS OF THE OPTIONS"; \
	 echo "####################################################################################"

##############################################################################
# MODIFICATION: NONE
#-----------------------------------------------------------------------------
# Include common.mk makefile that controls testcase generation
#
# Do not modify this section.
#
##############################################################################
include ./common.mk

################################################################################
# Create testbench
################################################################################

# Render the testbench RTL. The dependency on the parameters file ensures that
# the testbench is re-rendered if the processor configuration or intkit configuration 
# changes.
#
$(tb_rendered): $(tb_unrendered) $(rtl_config) $(intkit_config) ../make.cfg
	@echo " >> Generating testbench" ; \
	$(TB_GENERATOR) -intkit $< $@ ; \
	if [ $(strip $(USE_DSM)) = yes ] ; then \
	  echo "replace the cortex-A53 RTL model CORTEXA53 with DSM model CORTEXA53_DSM" ; \
	  echo "You may use a different name for the DSM model" ; \
	  perl -p -i -e 's/\s+CORTEXA53\s+/CORTEXA53_DSM/g' ../verilog/cortexa53_intkit_tb.v ; \
	fi




##############################################################################
# MODIFICATION: NONE
#-----------------------------------------------------------------------------
# Targets, rules and additional variables for rtl compilation
#
# Do not modify this section.
#
##############################################################################

.PHONY: rtl_compile clean_exe all


# rule to execute rtl compilation
$(EXE_DIR)/$(WORK):$(tb_rendered)
	@rm -rf ${SIMULATOR}; \
	rm -rf ${EXE_DIR}; \
	mkdir -p logs; \
	mkdir -p ${EXE_DIR}; \
	cd ${EXE_DIR}; \
	echo "Compiling testbench ....${SIMULATOR}"; \
	${${SIMULATOR}_CMD}

# compile the rtl
rtl_compile: $(EXE_DIR)/$(WORK)

# clean simulator directory/compilation
clean_exe :
	@echo "Cleaning exe: ${PWD}/${SIMULATOR}, rtl_compile*.log"; \
	rm -rf ${PWD}/${SIMULATOR}; \
	rm -rf rtl_compile*.log;

##############################################################################
# MODIFICATION: OPTIONAL
#-----------------------------------------------------------------------------
# Targets for rtl simulation
#
# Modify this section if you need to change Verilog simulation options
#
##############################################################################

# # target shall have the following name pattern and dependency:
#
#     $(logs) : logs/%.log : bin/%/compilation_complete rtl_compile
#
# # $(logs) variable stores the list of targets for simualtion, each element
#   in the following format:
#
#     logs/<$(TESTNAME)>-CXDT-<$(CXDT)>-CPU-<$(CPU)>.log
#     log files shall be generated under this kind of name
#
# # simulations shal run in dirs with the following name pattern:
#
#     run/<$(TESTNAME)>-CXDT-<$(CXDT)>-CPU-<$(CPU)>

# the _RUN variable stores the command to execute simulation depending on the SIMULATOR variable
# GUI option is also included or not
logs/%.log: VCS_RUN  = ${EXE_DIR}/${WORK} $(VCS_RUN_OPTS) $(PLUSARGS) -l ../../logs/$*.log -ucli -i simulator.cmds
logs/%.log: VCS_RUN += ${GUI}
logs/%.log: IUS_RUN  = irun $(IUS_RUN_OPTS) $(PLUSARGS) -l ../../logs/$*.log  -input simulator.cmds
logs/%.log: IUS_RUN += ${GUI}
logs/%.log: MTI_RUN  = vsim $(MTI_RUN_OPTS) ${GUI} $(PLUSARGS) -l ../../logs/$*.log -do simulator_mti.cmds


##############################################################################
# MODIFICATION: OPTIONAL
#-----------------------------------------------------------------------------
# Targets, rules and additional variables for simulation execution
#
# Modify the run/% target to create the correct links to the binary files
#
# Modify this section to execute trace port-processing for the valid cases
# of trace test, add conditions to the if clause in line 265, modify the path
# for the correct ATB log file for each processor, modify the parameter for
# the trace_post_process.pl script
#
##############################################################################


# ***********************************************************************
# bin/% is the real target to construct the image files to each test case
# ***********************************************************************

# the MAKEFLAGS variable stores the variables to be passed to the sub-Make on the system dir
# it basically chop the TEST_CASE variable to accomodate the pieces in the right place
bin/%/compilation_complete: override MAKEFLAGS += $(strip TEST_ARCH=${TEST_ARCH})

# ***********************************************************************
# run/% is the real target that executes the simulations
# ***********************************************************************


# rule to execute simulation
# trace_all test needs to trace the code running
# on CPU, suppose the CPU image file is in tests/cpu_image.vhx
.PRECIOUS: run/%
ifeq (${TESTNAME},trace_all)
run/%:
	@echo "Simulation: $@, with $(PLUSARGS) "; \
	rm $@ -rf; \
	mkdir -p $@; \
	ln -s ../../simulator.cmds $@/simulator.cmds; \
	ln -s ../../simulator_mti.cmds $@/simulator_mti.cmds; \
	ln -s ../../bin/$*/CXDT_$(word 1, $(subst -, , $(subst run/,,$@))).bin $@/cxdt.bin; \
	ln -s ../../../tests/cpu_image.vhx $@/image.vhx
else
run/%: 
	@echo "Simulation: $@, with $(PLUSARGS) "; \
	rm $@ -rf; \
	mkdir -p $@; \
	ln -s ../../simulator.cmds $@/simulator.cmds; \
	ln -s ../../simulator_mti.cmds $@/simulator_mti.cmds; \
	ln -s ../../bin/$*/CXDT_$(word 1, $(subst -, , $(subst run/,,$@))).bin $@/cxdt.bin; \
	ln -s ../../bin/$*/IMAGE0_$(word 1, $(subst -, , $(subst run/,,$@))).vhx $@/image.vhx
endif


# simulation and trace comparison
# For trace comparison, you may need to modify this to suit your own system.
# for example, the TPIU port size, TPIU format mode, ATID value and the corresponding file name.
.PRECIOUS: $(foreach test, ${TEST_CASE}, logs/${test}.log)
.FORCE:
$(foreach test, ${TEST_CASE}, logs/${test}.log) : .FORCE

logs/%.log : rtl_compile bin/%/compilation_complete run/% 
	@echo "Simulation: $*"; \
	mkdir -p logs; \
	cd run/$*; \
	echo "${${SIMULATOR}_RUN}"; \
	${${SIMULATOR}_RUN}; \
        echo "PARAM_SW_SUITE a53_system" >> ../../$@;   \
        echo "PARAM_SW_TEST $*" >> ../../$@;   \
        echo "PARAM_COMMAND ${${SIMULATOR}_RUN}" >> ../../$@;   \
	if [ $(word 1, $(subst -, , $*)) = trace ] ; then \
	  echo "Trace compare for: $*"; \
	  echo "You may need to modify the TPIU port size, TPIU format mode, ATID value in this Makefile to suit your system"; \
	  if [ -e log.tpiu ]; then \
	    cp log.tpiu ${CSSOC_INSTALL_DIR}/shared/tools/bin/; \
	  else \
	    echo "***ERROR*** log.tpiu file does not exist" >> ../../logs/$*.log; \
	  fi;\
	  cd ${CSSOC_INSTALL_DIR}/shared/tools/bin/; \
	  ./CSCompare -extracttpiu -tpiu_formatmode=1 -tpiu_portsize=32 ; \
	  cp log_ID2.atb $(MAINDIR)/run/$*/. ; \
	  cd $(MAINDIR) ; \
	  $(CA53_RTL)/testbench/shared/tools/bin/ca53etm_ik_compare -atb run/$*/log_ID2.atb -atid 2 -ref $(CA53_RTL)/testbench/integration_kit_cssoc/tests/cssoc_Cortex-A53_trace.ref >> logs/$*.log ; \
	  echo "trace comparison complete" ; \
	fi


clean_all : clean_exe clean_image clean_run clean_logs

all       : clean_all run report

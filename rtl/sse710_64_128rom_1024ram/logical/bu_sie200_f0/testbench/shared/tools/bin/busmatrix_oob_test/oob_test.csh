#!/bin/tcsh -f
# -----------------------------------------------------------------------------
# The confidential and proprietary information contained in this file may
# only be used by a person authorised under and to the extent permitted
# by a subsisting licensing agreement from ARM Limited or its affiliates.
#
#               (C) COPYRIGHT 2016 ARM Limited or its affiliates.
#                   ALL RIGHTS RESERVED
#
# This entire notice must be reproduced on all copies of this file
# and copies of this file may only be made by a person if such person is
# permitted to do so under the terms of a subsisting license agreement
# from ARM Limited or its affiliates.
#
# Checked In : Wed Oct 5 12:29:17 2016 +0100
# Revision : d690f1c
#
# Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
# -----------------------------------------------------------------------------
# Purpose : Test run script
#
# -----------------------------------------------------------------------------

set SCRIPT_NAME="oob_test.csh"


# Flags default value
set RUN_MODE = "-c"         # Test run mode
set RUN_MODE_OPTION="-c"  # Test run mode option
set SV_SEED="random"      # systemverilog random number generator seed
set XML_PATH=""
set SIMULATOR=""
set MODULE_NAME="ERROR"
set ADDR_WIDTH="ERROR"
set STATUS=1
set MACHINE=""
set RUN_MODE="batch"
set SIM_ONLY=0
# Capture additional flags and path
foreach ARG ($*)
    # if the previous flag was "--xml_path", capture the path
    if ( "$XML_PATH" == "next" ) then
        set XML_PATH="$ARG"
    # XML_PATH value
    else if  ( "$ARG" == "--config" ) then
        set XML_PATH="next"
  # if the previous flag was "--simulator", capture the simulator
    else if ( "$SIMULATOR" == "next" ) then
        set SIMULATOR="$ARG"
    # SIMULATOR value
    else if  ( "$ARG" == "--tool" ) then
        set SIMULATOR="next"
  else if ( "$MACHINE" == "next" ) then
        set MACHINE="$ARG"
    # MACHINE value
    else if  ( "$ARG" == "--cmode" ) then
        set MACHINE="next"
  else if  ( "$ARG" == "--gui" ) then
        set RUN_MODE="gui"
    endif
end

#cleanup log
truncate log_files/oob_test.csh.log --size 0

if ( -f "./$SCRIPT_NAME" ) then
  set STATUS=1  #Do nothing
else
  echo "** Error: Please start OOB test directly from script's directory!" | tee -a log_files/oob_test.csh.log
  exit 1
endif



if ( "$XML_PATH" == "" ) then
  set STATUS = 0
  echo "** Error: Please specify configuration XML file path: --config <PATH_TO_CONFIGURATION_FILE>" | tee -a log_files/oob_test.csh.log
else
  if ( -f "$XML_PATH" ) then
    setenv XML_PATH $XML_PATH
  else
    set STATUS=0
    echo "** Error: File not exists: $XML_PATH" | tee -a log_files/oob_test.csh.log
  endif
endif


if ( "$SIMULATOR" == "" ) then
  set STATUS=0
  echo "** Error: Please specify which simulator to use: --simulator <{mti,vcs,nc}>" | tee -a log_files/oob_test.csh.log
else if (( $SIMULATOR != "mti" ) && ( $SIMULATOR != "vcs" ) && ( $SIMULATOR != "nc" )) then
  set STATUS=0
  echo "** Error: Simulator must be one of the followings: --simulator <{mti,vcs,nc}>" | tee -a log_files/oob_test.csh.log
endif

if ( "$MACHINE" == "" ) then
  set STATUS=0
  echo "** Error: Please specify a machine to use: --cmode <{32,64}>" | tee -a log_files/oob_test.csh.log
else if (( $MACHINE != "32" ) && ( $MACHINE != "64" )) then
  set STATUS=0
  echo "** Error: Machine must be one of the followings: --cmode <{32,64}>" | tee -a log_files/oob_test.csh.log
endif

if ( $STATUS == 1 ) then

  set MODULE_NAME=`eval "perl ./get_module_name.pl -xml=$XML_PATH"`
  echo $MODULE_NAME | tee -a log_files/oob_test.csh.log

  if ( $? == 0 ) then
    setenv MODULE_NAME $MODULE_NAME
    echo "MODULE NAME : ${MODULE_NAME}" | tee -a log_files/oob_test.csh.log
  else
    set STATUS=0
    echo "Error occured, OOB test stopped!" | tee -a log_files/oob_test.csh.log
  endif
endif



if ( $STATUS == 1 ) then

  set ADDR_WIDTH=`eval "perl ./get_addr_width.pl -xml=$XML_PATH"`

  if ( $? == 0 ) then
    setenv ADDR_WIDTH $ADDR_WIDTH
    echo "ADDR_WIDTH : ${ADDR_WIDTH}" | tee -a log_files/oob_test.csh.log
  else
    set STATUS=0
    echo "Error occured, OOB test stopped!" | tee -a log_files/oob_test.csh.log
  endif
endif

if ( $STATUS == 1 ) then

  echo "############## Environment Setup Start ---" | tee -a log_files/oob_test.csh.log

  # Logical path - relative to this would the whole structure be described -should be defined by the user
  set SIE200_LOGICAL_PATH="${PWD}/../../../../.."
  setenv SIE200_LOGICAL_PATH "${PWD}/../../../../.."
  echo "The SIE200_LOGICAL_PATH is set to $SIE200_LOGICAL_PATH" | tee -a log_files/oob_test.csh.log

  # SIE-200 TB path
  set SIE200_BUSMATRIX_TB_PATH="$SIE200_LOGICAL_PATH/testbench"
  setenv SIE200_BUSMATRIX_TB_PATH "$SIE200_LOGICAL_PATH/testbench"
  echo "The SIE200_BUSMATRIX_TB_PATH is set to $SIE200_BUSMATRIX_TB_PATH" | tee -a log_files/oob_test.csh.log

  # Execution TB path
  set SIE200_BUSMATRIX_ETB_PATH="$SIE200_BUSMATRIX_TB_PATH/execution_tb"
  setenv SIE200_BUSMATRIX_ETB_PATH "$SIE200_BUSMATRIX_TB_PATH/execution_tb"
  echo "The SIE200_BUSMATRIX_ETB_PATH is set to $SIE200_BUSMATRIX_ETB_PATH" | tee -a log_files/oob_test.csh.log

  # tb directory path
  set SIE200_BUSMATRIX_OOB_TB_PATH="$SIE200_BUSMATRIX_ETB_PATH/verilog"
  setenv  SIE200_BUSMATRIX_OOB_TB_ROOT_PATH "$SIE200_BUSMATRIX_ETB_PATH/verilog"
  echo "The SIE200_BUSMATRIX_OOB_TB_ROOT_PATH is set to $SIE200_BUSMATRIX_OOB_TB_ROOT_PATH" | tee -a log_files/oob_test.csh.log

  # test directory path
  set SIE200_BUSMATRIX_OOB_TEST_PATH="$SIE200_BUSMATRIX_ETB_PATH/tests/generic_busmatrix_oob"
  setenv SIE200_BUSMATRIX_OOB_TEST_PATH "$SIE200_BUSMATRIX_ETB_PATH/tests/generic_busmatrix_oob"
  echo "The SIE200_BUSMATRIX_OOB_TEST_PATH is set to $SIE200_BUSMATRIX_OOB_TEST_PATH" | tee -a log_files/oob_test.csh.log

  # Scripts
  set SIE200_BUSMATRIX_OOB_TB_SCRIPTS_PATH="$SIE200_BUSMATRIX_TB_PATH/shared/tools/bin/busmatrix_oob_test"
  setenv SIE200_BUSMATRIX_OOB_TB_SCRIPTS_PATH "$SIE200_BUSMATRIX_TB_PATH/shared/tools/bin/busmatrix_oob_test"
  echo "The SIE200_BUSMATRIX_OOB_TB_SCRIPTS_PATH is set to $SIE200_BUSMATRIX_OOB_TB_SCRIPTS_PATH" | tee -a log_files/oob_test.csh.log

  # Log files
  set SIE200_BUSMATRIX_OOB_LOG_FILES_PATH="$SIE200_BUSMATRIX_OOB_TB_SCRIPTS_PATH/log_files"
  setenv  SIE200_BUSMATRIX_OOB_LOG_FILES_PATH "$SIE200_BUSMATRIX_OOB_TB_SCRIPTS_PATH/log_files"
  echo "The SIE200_BUSMATRIX_OOB_LOG_FILES_PATH is set to $SIE200_BUSMATRIX_OOB_LOG_FILES_PATH" | tee -a log_files/oob_test.csh.log

  # tb directory path - directory should be created in gen_busmatrix.pl script
  set SIE200_BUSMATRIX_OOB_TB_PATH="$SIE200_BUSMATRIX_OOB_TB_ROOT_PATH/$MODULE_NAME"
  setenv  SIE200_BUSMATRIX_OOB_TB_PATH "$SIE200_BUSMATRIX_OOB_TB_ROOT_PATH/$MODULE_NAME"
  echo "The SIE200_BUSMATRIX_OOB_TB_PATH is set to $SIE200_BUSMATRIX_OOB_TB_PATH" | tee -a log_files/oob_test.csh.log

  # Logical directory - this is where the .v files are
  set SIE200_BUSMATRIX_LOGICAL_PATH="$SIE200_LOGICAL_PATH/$MODULE_NAME/verilog"
  setenv  SIE200_BUSMATRIX_LOGICAL_PATH "$SIE200_LOGICAL_PATH/$MODULE_NAME/verilog"
  echo "The SIE200_BUSMATRIX_LOGICAL_PATH is set to $SIE200_BUSMATRIX_LOGICAL_PATH" | tee -a log_files/oob_test.csh.log

  echo "--- Environment Setup Complete ##############" | tee -a log_files/oob_test.csh.log


endif


if ( $STATUS == 1 ) then

  if ( -f "$SIE200_BUSMATRIX_LOGICAL_PATH/$MODULE_NAME.vc" ) then
    set STATUS=1
  else
    set STATUS=0
    echo "** Error: File not $SIE200_BUSMATRIX_LOGICAL_PATH/$MODULE_NAME.vc" | tee -a log_files/oob_test.csh.log
  endif

endif

if ( $STATUS == 1 ) then

  setenv  ARM_AHB_VIP_HOME "$SIE200_BUSMATRIX_OOB_TB_SCRIPTS_PATH/AHB5_UVC"
  setenv  ARM_AHB_UVC_HOME "$ARM_AHB_VIP_HOME/ahb5uvc"

  # Path required by AHB VIP
  setenv  UVC_DIR "$ARM_AHB_VIP_HOME/ahb5uvc"


  #Compile and optimise environment
  printf "\n############## COMPILE & SIMULATION START ---\n" | tee -a log_files/oob_test.csh.log
  eval "make -f $SIE200_BUSMATRIX_OOB_TB_PATH/ggve_makefile run simulator=$SIMULATOR machine=$MACHINE run_mode=$RUN_MODE"
  printf "\n--- COMPILE&SIMULATION END ##############\n" | tee -a log_files/oob_test.csh.log

  if ( $? != 0 ) then
    set STATUS=0
    echo "Error  OOB test stopped!" | tee -a log_files/oob_test.csh.log
  endif

endif

#Evaluating resutls
if (( $STATUS == 1 ) && ( "$RUN_MODE" != "gui" )) then

  printf "\n############## EVALUATING RESULTS ---\n" | tee -a log_files/oob_test.csh.log

  echo "$SIE200_BUSMATRIX_OOB_TB_SCRIPTS_PATH/eval_result.pl  --compile --simulation -simulator=$SIMULATOR" | tee -a log_files/oob_test.csh.log
  eval "$SIE200_BUSMATRIX_OOB_TB_SCRIPTS_PATH/eval_result.pl  --compile --simulation -simulator=$SIMULATOR"

  if ( $? != 0 ) then
    set STATUS=0
  endif


  if ( $STATUS == 1 ) then
    #Quick check if there were started and finished transactions

    set STARTED_TRANS = `grep "\[PT\]Transaction started" $SIE200_BUSMATRIX_OOB_LOG_FILES_PATH/sim_$SIMULATOR.log  | wc -l `
    set FINISHED_TRANS = `grep "\[PT\]Transaction finished" $SIE200_BUSMATRIX_OOB_LOG_FILES_PATH/sim_$SIMULATOR.log  | wc -l `

    if ( $STARTED_TRANS == 0 ) then
      set STATUS=0
      echo "** Error: No transaction started" | tee -a log_files/oob_test.csh.log
    else if ( "$STARTED_TRANS" != "$FINISHED_TRANS" ) then
      set STATUS=0
      echo "** Error: The number of finished transactions during the test is not equal to the number of the transactions started" | tee -a log_files/oob_test.csh.log
    else
      echo "#Number of transactions transferred during the test: $STARTED_TRANS" | tee -a log_files/oob_test.csh.log
    endif
  endif


  printf "\n--- END OF EVALUATING RESULTS ##############\n" | tee -a log_files/oob_test.csh.log


endif


if ( $STATUS == 1 ) then

  printf "\n\n" | tee -a log_files/oob_test.csh.log
  echo "##########################################" | tee -a log_files/oob_test.csh.log
  echo "#                                        #" | tee -a log_files/oob_test.csh.log
  echo "# Out Of Box test finished without error #" | tee -a log_files/oob_test.csh.log
  echo "#                                        #" | tee -a log_files/oob_test.csh.log
  echo "##########################################" | tee -a log_files/oob_test.csh.log
  printf "\n\n" | tee -a log_files/oob_test.csh.log


else

  printf "\n\n" | tee -a log_files/oob_test.csh.log
  echo "#############################################################" | tee -a log_files/oob_test.csh.log
  echo "#                                                           #" | tee -a log_files/oob_test.csh.log
  echo "# Out Of Box test FAILED due to previous errors or warnings #" | tee -a log_files/oob_test.csh.log
  echo "#                                                           #" | tee -a log_files/oob_test.csh.log
  echo "#############################################################" | tee -a log_files/oob_test.csh.log
  printf "\n\n"  | tee -a log_files/oob_test.csh.log

endif





# ******************************************************************************
# Exit run
# ******************************************************************************

exit 1

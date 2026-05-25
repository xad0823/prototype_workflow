#!/bin/env sh
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

SCRIPT_NAME="oob_test.bash"

# Flags default value
RUN_MODE="-c"         # Test run mode
RUN_MODE_OPTION="-c"  # Test run mode option
SV_SEED="random"      # systemverilog random number generator seed
XML_PATH=""
SIMULATOR=""    #Specified in --tool
MODULE_NAME="ERROR"
ADDR_WIDTH="ERROR"
STATUS=1
MACHINE=""    #specified in --cmode
RUN_MODE="batch"
SIM_ONLY=0
# Capture additional flags and path
for ARG in "$@"
do
    # if the previous flag was "--xml_path", capture the path
    if [ "$XML_PATH" = "next" ]; then
        XML_PATH="$ARG"
    # XML_PATH value
    elif  [ "$ARG" = "--config" ]; then
        XML_PATH="next"
  # if the previous flag was "--simulator", capture the simulator
    elif [ "$SIMULATOR" = "next" ]; then
        SIMULATOR="$ARG"
    # SIMULATOR value
    elif  [ "$ARG" = "--tool" ]; then
        SIMULATOR="next"
  elif [ "$MACHINE" = "next" ]; then
        MACHINE="$ARG"
    # MACHINE value
    elif  [ "$ARG" = "--cmode" ]; then
        MACHINE="next"
    elif  [ "$ARG" = "--gui" ]; then
        RUN_MODE="gui"
    fi
done

#cleanup log
truncate log_files/oob_test.bash.log --size 0

if [ -f ./$SCRIPT_NAME ]; then
  STATUS=1  #Do nothing
else
  echo "** Error: Please start OOB test directly from script's directory!" | tee -a log_files/oob_test.bash.log
  exit 1
fi



if [ -z $XML_PATH ]; then
  STATUS=0
  echo "** Error: Please specify configuration XML file path: --config <PATH_TO_CONFIGURATION_FILE>" | tee -a log_files/oob_test.bash.log
else
  if [ -f $XML_PATH ]; then
    export XML_PATH
  else
    STATUS=0
    echo "** Error: File not exists: $XML_PATH" | tee -a log_files/oob_test.bash.log
  fi
fi

if [ -z $SIMULATOR ]; then
  STATUS=0
  echo "** Error: Please specify which simulator to use: --simulator <{mti,vcs,nc}>" | tee -a log_files/oob_test.bash.log
elif [ $SIMULATOR != "mti" ] && [ $SIMULATOR != "vcs" ] && [ $SIMULATOR != "nc" ]; then
  STATUS=0
  echo "** Error: Simulator must be one of the followings: --simulator <{mti,vcs,nc}>" | tee -a log_files/oob_test.bash.log
fi


if [ -z $MACHINE ]; then
  STATUS=0
  echo "** Error: Please specify a machine type to use: --cmode <{32,64}>" | tee -a log_files/oob_test.bash.log
elif [ $MACHINE != "32" ] && [ $MACHINE != "64" ]; then
  STATUS=0
  echo "** Error: Machine must be one of the followings: --cmode <{32,62}>" | tee -a log_files/oob_test.bash.log
fi



if [ $STATUS -eq 1 ]; then

  MODULE_NAME=$(eval "perl ./get_module_name.pl -xml=$XML_PATH")

  if [ $? -eq 0 ]; then
    export MODULE_NAME=$MODULE_NAME
    echo "MODULE NAME : ${MODULE_NAME}" | tee -a log_files/oob_test.bash.log
  else
    STATUS=0
    echo "Error occured, OOB test stopped!" | tee -a log_files/oob_test.bash.log
  fi
fi

if [ $STATUS -eq 1 ]; then

  ADDR_WIDTH=$(eval "perl ./get_addr_width.pl -xml=$XML_PATH")

  if [ $? -eq 0 ]; then
    export ADDR_WIDTH=$ADDR_WIDTH
    echo "ADDR_WIDTH : ${ADDR_WIDTH}" | tee -a log_files/oob_test.bash.log
  else
    STATUS=0
    echo "Error occured, OOB test stopped!" | tee -a log_files/oob_test.bash.log
  fi
fi


if [ $STATUS -eq 1 ]; then

  echo "############## environment variable setup start ---" | tee -a log_files/oob_test.bash.log

  # Logical path - relative to this would the whole structure be described -should be defined by the user
  SIE200_LOGICAL_PATH="${PWD}/../../../../.."
  export  SIE200_LOGICAL_PATH="${PWD}/../../../../.."
  echo "The SIE200_LOGICAL_PATH is set to ${SIE200_LOGICAL_PATH}" | tee -a log_files/oob_test.bash.log


  # SIE-200 TB path
  SIE200_BUSMATRIX_TB_PATH="$SIE200_LOGICAL_PATH/testbench"
  export  SIE200_BUSMATRIX_TB_PATH="$SIE200_LOGICAL_PATH/testbench"
  echo "The SIE200_BUSMATRIX_TB_PATH is set to $SIE200_BUSMATRIX_TB_PATH" | tee -a log_files/oob_test.bash.log

  # Execution TB path
  SIE200_BUSMATRIX_ETB_PATH="$SIE200_BUSMATRIX_TB_PATH/execution_tb"
  export  SIE200_BUSMATRIX_ETB_PATH="$SIE200_BUSMATRIX_TB_PATH/execution_tb"
  echo "The SIE200_BUSMATRIX_ETB_PATH is set to $SIE200_BUSMATRIX_ETB_PATH" | tee -a log_files/oob_test.bash.log


  # tb directory path
  SIE200_BUSMATRIX_OOB_TB_ROOT_PATH="$SIE200_BUSMATRIX_ETB_PATH/verilog"
  export  SIE200_BUSMATRIX_OOB_TB_ROOT_PATH="$SIE200_BUSMATRIX_ETB_PATH/verilog"
  echo "The SIE200_BUSMATRIX_OOB_TB_ROOT_PATH is set to $SIE200_BUSMATRIX_OOB_TB_ROOT_PATH" | tee -a log_files/oob_test.bash.log

  # test directory path
  SIE200_BUSMATRIX_OOB_TEST_PATH="$SIE200_BUSMATRIX_ETB_PATH/tests/generic_busmatrix_oob"
  export  SIE200_BUSMATRIX_OOB_TEST_PATH="$SIE200_BUSMATRIX_ETB_PATH/tests/generic_busmatrix_oob"
  echo "The SIE200_BUSMATRIX_OOB_TEST_PATH is set to $SIE200_BUSMATRIX_OOB_TEST_PATH" | tee -a log_files/oob_test.bash.log

  # Scripts
  SIE200_BUSMATRIX_OOB_TB_SCRIPTS_PATH="$SIE200_BUSMATRIX_TB_PATH/shared/tools/bin/busmatrix_oob_test"
  export  SIE200_BUSMATRIX_OOB_TB_SCRIPTS_PATH="$SIE200_BUSMATRIX_TB_PATH/shared/tools/bin/busmatrix_oob_test"
  echo "The SIE200_BUSMATRIX_OOB_TB_SCRIPTS_PATH is set to $SIE200_BUSMATRIX_OOB_TB_SCRIPTS_PATH" | tee -a log_files/oob_test.bash.log


  # Log files
  SIE200_BUSMATRIX_OOB_LOG_FILES_PATH="$SIE200_BUSMATRIX_OOB_TB_SCRIPTS_PATH/log_files"
  export  SIE200_BUSMATRIX_OOB_LOG_FILES_PATH="$SIE200_BUSMATRIX_OOB_TB_SCRIPTS_PATH/log_files"
  echo "The SIE200_BUSMATRIX_OOB_LOG_FILES_PATH is set to $SIE200_BUSMATRIX_OOB_LOG_FILES_PATH" | tee -a log_files/oob_test.bash.log

  # tb directory path
  SIE200_BUSMATRIX_OOB_TB_PATH="$SIE200_BUSMATRIX_OOB_TB_ROOT_PATH/${MODULE_NAME}"
  export  SIE200_BUSMATRIX_OOB_TB_PATH="$SIE200_BUSMATRIX_OOB_TB_ROOT_PATH/${MODULE_NAME}"
  echo "The SIE200_BUSMATRIX_OOB_TB_PATH is set to $SIE200_BUSMATRIX_OOB_TB_PATH" | tee -a log_files/oob_test.bash.log

  # Logical directory - this is where the .v files are
  SIE200_BUSMATRIX_LOGICAL_PATH="$SIE200_LOGICAL_PATH/${MODULE_NAME}/verilog"
  export  SIE200_BUSMATRIX_LOGICAL_PATH="$SIE200_LOGICAL_PATH/${MODULE_NAME}/verilog"
  echo "The SIE200_BUSMATRIX_LOGICAL_PATH is set to $SIE200_BUSMATRIX_LOGICAL_PATH" | tee -a log_files/oob_test.bash.log

  echo "--- Environment Setup Complete ##############" | tee -a log_files/oob_test.bash.log


fi


#Test whether RTL is generated before OOB test
if [ $STATUS -eq 1 ]; then


  if [ -f "${SIE200_BUSMATRIX_LOGICAL_PATH}/${MODULE_NAME}.vc" ]; then
    STATUS=1
  else
    STATUS=0
    printf "\n** Error: File not exists: ${SIE200_BUSMATRIX_LOGICAL_PATH}/${MODULE_NAME}.vc. \nMake sure RTL is generated before testing!\n" | tee -a log_files/oob_test.bash.log
  fi

fi


#compile and run
if [ $STATUS -eq 1 ]; then


  export  ARM_AHB_VIP_HOME="$SIE200_BUSMATRIX_OOB_TB_SCRIPTS_PATH/AHB5_UVC"
  export  ARM_AHB_UVC_HOME="$ARM_AHB_VIP_HOME/ahb5uvc"

  # Path required by AHB VIP
  export  UVC_DIR="$ARM_AHB_VIP_HOME/ahb5uvc"

  #Compile and optimise environment
  printf "\n############## COMPILE & SIMULATION START ---\n" | tee -a log_files/oob_test.bash.log
  eval "make -f ${SIE200_BUSMATRIX_OOB_TB_PATH}/ggve_makefile run simulator=$SIMULATOR machine=$MACHINE run_mode=$RUN_MODE"
  printf "\n--- COMPILE&SIMULATION END ##############\n" | tee -a log_files/oob_test.bash.log

  if [ $? -ne 0 ]; then
    STATUS=0
    echo "Error  OOB test stopped!" | tee -a log_files/oob_test.bash.log
  fi

fi


#Evaluating results
if [ $STATUS -eq 1 ] && [ "$RUN_MODE" != "gui" ] ; then


       printf "\n############## EVALUATING RESULTS ---\n" | tee -a log_files/oob_test.bash.log

       echo "$SIE200_BUSMATRIX_OOB_TB_SCRIPTS_PATH/eval_result.pl  --compile --simulation -simulator=$SIMULATOR" | tee -a log_files/oob_test.bash.log
       eval "$SIE200_BUSMATRIX_OOB_TB_SCRIPTS_PATH/eval_result.pl  --compile --simulation -simulator=$SIMULATOR"

       if [ $? -ne 0 ]; then
               STATUS=0
       fi


       if [ $STATUS -eq 1 ]; then
               #Quick check if there were started and finished transactions

               STARTED_TRANS=$(grep "\[PT\]Transaction started" ${SIE200_BUSMATRIX_OOB_LOG_FILES_PATH}/sim_$SIMULATOR.log  | wc -l)
               FINISHED_TRANS=$(grep "\[PT\]Transaction finished" ${SIE200_BUSMATRIX_OOB_LOG_FILES_PATH}/sim_$SIMULATOR.log  | wc -l)

               if [ $STARTED_TRANS -eq 0 ]; then
                 STATUS=0
                 echo "** Error: No transaction started" | tee -a log_files/oob_test.bash.log
               elif [ $STARTED_TRANS -ne $FINISHED_TRANS ]; then
                 STATUS=0
                 echo "** Error: The number of finished transactions during the test is not equal to the number of the transactions started" | tee -a log_files/oob_test.bash.log
               else
                 echo "#Number of transactions transferred during the test: $STARTED_TRANS" | tee -a log_files/oob_test.bash.log
               fi


       fi
       printf "\n--- END OF EVALUATING RESULTS ##############\n" | tee -a log_files/oob_test.bash.log
fi


if [ $STATUS -eq 1 ]; then
       printf "\n\n" | tee -a log_files/oob_test.bash.log
       echo "##########################################" | tee -a log_files/oob_test.bash.log
       echo "#                                        #" | tee -a log_files/oob_test.bash.log
       echo "# Out Of Box test finished without error #" | tee -a log_files/oob_test.bash.log
       echo "#                                        #" | tee -a log_files/oob_test.bash.log
       echo "##########################################" | tee -a log_files/oob_test.bash.log
       printf "\n\n" | tee -a log_files/oob_test.bash.log

else
       printf "\n\n" | tee -a log_files/oob_test.bash.log
       echo "#############################################################" | tee -a log_files/oob_test.bash.log
       echo "#                                                           #" | tee -a log_files/oob_test.bash.log
       echo "# Out Of Box test FAILED due to previous errors or warnings #" | tee -a log_files/oob_test.bash.log
       echo "#                                                           #" | tee -a log_files/oob_test.bash.log
       echo "#############################################################" | tee -a log_files/oob_test.bash.log
       printf "\n\n" | tee -a log_files/oob_test.bash.log


fi




# ******************************************************************************
# Exit run
# ******************************************************************************

exit 1

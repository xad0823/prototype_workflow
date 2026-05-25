#!/usr/bin/env sh
set -e # Exit script upon error

# -----------------------------------------------------------------------------
# The confidential and proprietary information contained in this file may
# only be used by a person authorised under and to the extent permitted
# by a subsisting licensing agreement from Arm Limited or its affiliates.
# 
#        (C) COPYRIGHT 2016-2021 Arm Limited or its affiliates.
#            ALL RIGHTS RESERVED
# 
# This entire notice must be reproduced on all copies of this file
# and copies of this file may only be made by a person if such person is
# permitted to do so under the terms of a subsisting license agreement
# from Arm Limited or its affiliates.
# 
# 
# 
# 
#      Release Information : SSE710-r0p0-00eac0
# 
# -----------------------------------------------------------------------------
# Purpose : Script to render a yaml file
# -----------------------------------------------------------------------------
# The script does not checks source/target files/directory accessibility and 
# permissions. It has to be done on the script calling side


#
#
#
#
#


print_error () {
  echo "" 
  echo "ERROR:    $ERROR_MSG" 
  echo ""
}

print_help () {
  echo ""
  echo " The purpose of this script to renred complex/full yaml configuration file a yaml php template using a simplified yaml configuration file."
  echo ""
  echo "   Usage :"
  echo "   render_yaml [-help] -system <.yaml> -design <.yaml.php> -out <.yaml> [-trunk]"
  echo ""
  echo "   -help             : Prints this help message!"
  echo "   -system           : yaml configuration file for configuring the system described by design yaml file"
  echo "   -design           : PHP yaml file of the design"
  echo "   -out              : output yaml configuration file"
  echo "   -tmp              : location for temporal files"  
  echo ""
  if [ -n "$ERROR_MSG" ]; then
    exit 1
  else
    exit 0
  fi
}


# -----------------------------------------------------------------------------
# Initialisation
# -----------------------------------------------------------------------------
# Mandatory parameters
SOURCE_YAML_CFG=""
SOURCE_YAML_TEMP=""
TARGET_YAML_FILE=""

# Optional parameters/switches
VERBOSE=""
ERROR_MSG=""


# -----------------------------------------------------------------------------
# Process command line argument
# -----------------------------------------------------------------------------
while [ -n "$1" ]; do

    case $1 in 

        -h )      print_help ;;

        -help )   print_help ;;

        -system ) 

             if [ -n "$2" ]; then
                SOURCE_YAML_CFG=$2
                shift
             else
                ERROR_MSG="No configuration YAML file is given for -cfg"
                print_error
                print_help
             fi ;;

        -design )

             if [ -n "$2" ]; then
                SOURCE_YAML_TEMP=$2
                shift
             else
                ERROR_MSG="No PHP template YAML file is given for -tmp"
                print_error
                print_help
             fi ;;

        -out )

             if [ -n "$2" ]; then
                TARGET_YAML_FILE=$2
                shift
             else
                ERROR_MSG="No target YAML file is given for -out"
                print_error
                print_help
             fi ;;

        -tmp )

             if [ -n "$2" ]; then
                TMP_DIR=$2
                shift
             else
                ERROR_MSG="No no directory path is given for -tmp"
                print_error
                print_help
             fi ;;


        -verbose ) VERBOSE="TRUE" ;;

        *  ) 
             ERROR_MSG="Unknown argument given: $1"
             print_error
             print_help ;;
    esac

    shift

done


# Check parameters
if [ "$SOURCE_YAML_CFG" == "" ] || [ "$SOURCE_YAML_TEMP" == "" ] || [ "$TARGET_YAML_FILE" == "" ]; then
   ERROR_MSG="ERROR: One or more mandatory parameters not set!"
   print_error
   print_help
fi


# Print calling information
if [ -n "$VERBOSE" -a "$VERBOSE" = "TRUE" ]; then
  echo ""
  echo "      Render yaml configuration file"
  echo "      with the following options:"
  echo "      -----------------------------------------------"  
  echo -e "          SOURCE YAML CONFIGURATION : $SOURCE_YAML_CFG\t-> `ls  -oh $SOURCE_YAML_CFG  | cut -d'>' -f2 -s`"
  echo -e "          SOURCE YAML TEMPLATE      : $SOURCE_YAML_TEMP\t-> `ls -oh $SOURCE_YAML_TEMP | cut -d'>' -f2 -s`"
  echo "          TARGET YAML OUTPUT        : $TARGET_YAML_FILE"
  echo "      -----------------------------------------------"  
  echo ""
fi


# -----------------------------------------------------------------------------
# Convert YAML to JSON
# -----------------------------------------------------------------------------
if [ -n "$VERBOSE" -a "$VERBOSE" = "TRUE" ]; then
  echo "Convert $SOURCE_YAML_CFG into $TMP_DIR/configuration.json"
fi

   perl  -MJSON\
         -MYAML\
         -MFile::Slurp\
         -e "my \$i = Load scalar read_file('$SOURCE_YAML_CFG'); 
             print encode_json \$i->{CG071_CONFIG};" > $TMP_DIR/configuration.json 


# -----------------------------------------------------------------------------
# Render PHP template (.yaml.php) to .yaml
# -----------------------------------------------------------------------------
echo ""
echo "Creating $TARGET_YAML_FILE"
echo ""

php -d display_errors=stderr $SOURCE_YAML_TEMP $TMP_DIR/configuration.json > $TARGET_YAML_FILE

if [ -n "$TRUNK" -a "$TRUNK" = "TRUE" ]; then
  sed -i ./configuration_rtl.yaml -e 's|tags/.*|trunk|'
  sed -i ./configuration_rtl.yaml -e 's|branches/.*|trunk|'
fi

# -----------------------------------------------------------------------------
# Cleanup
# -----------------------------------------------------------------------------
if [ -n "$VERBOSE" -a "$VERBOSE" = "TRUE" ]; then
  echo "Removing temprary $TMP_DIR/configuration.json file"
fi

rm $TMP_DIR/configuration.json

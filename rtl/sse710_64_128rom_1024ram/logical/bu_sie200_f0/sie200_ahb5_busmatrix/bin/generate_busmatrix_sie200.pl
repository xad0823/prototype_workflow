#!/usr/bin/env perl
#-------------------------------------------------------------------------------
# The confidential and proprietary information contained in this file may
# only be used by a person authorised under and to the extent permitted
# by a subsisting licensing agreement from ARM Limited or its affiliates.
#
#            (C) COPYRIGHT 2001-2013,2015-2017 ARM ARM Limited or its affiliates.
#                ALL RIGHTS RESERVED
#
# This entire notice must be reproduced on all copies of this file
# and copies of this file may only be made by a person if such person is
# permitted to do so under the terms of a subsisting license agreement
# from ARM Limited or its affiliates.
#-------------------------------------------------------------------------------
#
# Version and Release Control Information:
#
#      File Name           : $RCSfile: generate_busmatrix.pl,v $
#
#      Version Information
#
#      Checked In          : Thu Jun 1 08:30:31 2017 +0100
#
#      Revision            : ff06b35
#
#      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
# Purpose             : Builds particular configurations of the AHB5 BusMatrix
#
#-------------------------------------------------------------------------------
# Usage:
#    Builds an AHB Bus Matrix component with a given number of input ports,
#    a given number of output ports, a particular arbitration scheme and ARM
#    processor interface.
#
# Notes: This version of the script uses an interface information hash with
#         the following structure:
#
#         my %InterfaceInfo = (
#                               SLAVES  => {
#                                 SI<n> => {
#                                   NAME => '@name',
#                                   CONNECTIONS => [ @MI<n> ... ],
#                                   ADDRESS_MAP => {
#                                     NORMAL => [ <address_info> ... ],
#                                     REMAP => [ <remap_info> ... ]
#                                   }
#                                 }
#                               },
#
#                               MASTERS => {
#                                 MI<n> => {
#                                   NAME        => '@name',
#                                   CONNECTIONS => [ @SI<n> ... ]
#                                 }
#                               }
#                             );
#
# Options: See the ShowHelp() function.
#
#-------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
#   Load PERL libraries
# ------------------------------------------------------------------------------

use strict;
use warnings;
use Getopt::Long;
use Cwd 'abs_path';

use Data::Dumper;


# ------------------------------------------------------------------------------
#   Declare global variables
# ------------------------------------------------------------------------------

# General script variables
my $Debug         = 0;
my $RenderDebug   = 0;
my $Errors        = 0;
my $HdlType       = 'verilog';
my $HdlExt        = '.v';
my $Connections   = '';
my $Sparse        = 0;
my $Product       = 'sie200';
my $DefaultSlave  = $Product.'_ahb_bm_default_slave';

# Parameter legal ranges
my $MinSlaveIF    = 1;
my $MaxSlaveIF    = 16;
my $MinMasterIF   = 1;
my $MaxMasterIF   = 16;
my $DataWidths    = '32|64';
my $MinNameLength = 1;
my $MaxNameLength = 128;
my $MinUserWidth  = 0;
my $MaxUserWidth  = 32;
my $MinAddrWidth  = 32;
my $MaxAddrWidth  = 64;
my $MinRemapWidth = 0;
my $MaxRemapWidth = 16;
my $MinMasterWidth = 1;
my $MaxMasterWidth = 16;

# Interface ID tags (updated later)
my $IdWidthMI = 4;
my $IdWidthSI = 4;

# Interface information hash
my %InterfaceInfo = ();

# Remap state information hash
my %RemapStates = ();

# Address space information hash
my %AddressSpace = ();

# Get the run date and correct offset
my ( $Sec, $Min, $Hour, $Mday, $Mon, $Year ) = localtime(time); $Year+=1900; $Mon++;

# Filename variables
my %FileList = ();
my ($Scriptname) = $0 =~ /([\w\.]+)$/;

# Hash for search and replacement of macros
my %Macro = ();

$Macro{'product'} = $Product;

# Hash for processing text sections
my %Section = ();

# Arrays of instance names
my @MatrixDecodeNames = ();
my @OutputArbNames    = ();
my @OutputStageNames  = ();

# Hash for remapping information
my %RemapInfo = ();

# Hash array of name aliases
my %NameAliases = ();

# IP-XACT component name - default value is set later
my $ComponentName = '';


# ------------------------------------------------------------------------------
#   Check for pre-requisites
# ------------------------------------------------------------------------------

# Check for the supported OS platform(s)
unless ( $^O =~ /(solaris|linux)\b/ ) {
  die "Error: This script does not support the '$^0' OS!\n\n";
}

# Check for the required version of PERL
unless ( $] >= 5.005 ) {
  die "Error: This script requires PERL version >= 5.005!\n\n";
}

# Check system clock for inappropriate roll-back - the date is used
#  in the copyright field of file headers
unless ( $Year >= 2016 ) {
  warn "Warning: The system clock is incorrectly set to '$Year'!\n";
  $Year = 2016;
}


# ------------------------------------------------------------------------------
#   Parse the command line
# ------------------------------------------------------------------------------

# Default values for command-line options
my $SlaveInterfaces      = 0;
my $MasterInterfaces     = 0;
my $Connectivity         = 'full';
my $ArbiterType          = 'round';
my $ArchitectureType     = 'ahb5';
my $XmlConfigFile        = '';
my $RoutingDataWidth     = 32;
my $RoutingAddressWidth  = 32;
my $UserSignalWidth      = 0;
my $BusMatrixName        = '';                  # Default value is set later
my $OutputArbName        = '';
my $OutputStageName      = '';
my $MatrixDecodeName     = '';
my $InputStageName       = '';
my $Help                 = 0;
my $Verbose              = 0;
my $Quiet                = 0;
my $SourceDir            = '';
my $TargetDir            = '';
my $XmlDir               = '';
my $LibDir               = '';
my $Overwrite            = 0;
my $Timescales           = 0;
my $NoTimescales         = 0;
my $XmlTimescales        = 0;
my $CheckMode            = 0;
my $IPXACT               = 0;
my $RemapBitWidth        = 0;
my $MasterBitWidth       = 4;
my $Slave_Type           = 'initiator';

# if no command line arguments are given, show help
if ( not @ARGV) { $Help = 1; }

# Get command line arguments
GetOptions( 'cfg=s'          => \$XmlConfigFile,
            'overwrite'      => \$Overwrite,
            'ipxact'         => \$IPXACT,
            'verbose'        => \$Verbose,
            'quiet'          => \$Quiet,
            'help'           => \$Help,
            'srcdir=s'       => \$SourceDir,
            'tgtdir=s'       => \$TargetDir,
            'xmldir=s'       => \$XmlDir,
            'libdir=s'       => \$LibDir,
            'timescales'     => \$Timescales, 'notimescales'   => \$NoTimescales,
            'check'          => \$CheckMode,
            'debug'          => \$Debug,
            'renderdebug'    => \$RenderDebug
          );

use lib 'bin/lib';

if ($LibDir and (!$SourceDir or !$TargetDir)) {
  die "Error: Please provide source and target dir also if you provide library directory.\n";
}

if ( $Timescales and $NoTimescales ) {
  die "Error: Can't use --timescales and --notimescales at the same time\n";
}

# Add user provided library path
unshift @INC, $LibDir;

# Load the XML parser module
if (eval("require xmlparser")) {
  xmlparser->import();
} else {
   die "Error: Can't find the library \"xmlparser at \./bin/lib/\". Please make sure you call the script from the root folder of the busmatrix package.\n" .
         "    or provide the library path with the --libdir option\n";
}

# Display script header when in verbose mode
if ( !$Quiet ) {
  printf "\n//=============================================================================\n" .
         "= The confidential and proprietary information contained in this file may\n" .
         "= only be used by a person authorised under and to the extent permitted\n" .
         "= by a subsisting licensing agreement from ARM Limited or its affiliates.\n" .
         "=\n" .
         "=            (C) COPYRIGHT 2001-2016 ARM Limited or its affiliates.\n" .
         "=                ALL RIGHTS RESERVED\n" .
         "=\n" .
         "= This entire notice must be reproduced on all copies of this file\n" .
         "= and copies of this file may only be made by a person if such person is\n" .
         "= permitted to do so under the terms of a subsisting license agreement\n" .
         "= from ARM Limited or its affiliates.\n" .
         "==============================================================================\n" .
         "=\n" .
         "= $Scriptname\n" .
         "=\n" .
         "= Run Date : %02d/%02d/%04d %02d:%02d:%02d\n" .
         "==============================================================================\n\n",
         $Mday, $Mon, $Year, $Hour, $Min, $Sec;
}

# Display usage message if requested
if ( $Help ) { ShowHelp(); }

$SourceDir            = "." if $SourceDir eq '';
$TargetDir            = "./built" if $TargetDir eq '';
my $env_TargetDir     = '';

# The TargetDir is relative to LOGICAL_PATH;
$env_TargetDir = '$SIE200_LOGICAL_PATH';
print ".vc file using TargetDir: ".$env_TargetDir."\n" if $Debug;
print "Generating to  TargetDir: ".$TargetDir."\n\n" if $Debug;

# ------------------------------------------------------------------------------
#   Parse the configuration file if specified, or initialise by elaborating
#    the '-connectivity' command-line argument and calculating an address map
# ------------------------------------------------------------------------------

if ( $XmlConfigFile ne '' ) {

  # Conditionally prepend the XML directory path to the filename
  if ( $XmlConfigFile !~ /^$XmlDir/ ) { $XmlConfigFile = "$XmlDir/$XmlConfigFile"; }
  $XmlConfigFile = TidyPath($XmlConfigFile);
  # Configure and run the XML parser
  ProcessXmlConfigFile();

} else {

  print "\nPlease provide an xml config file to generate a busmatrix.\n\n";
  exit (0);
}

# Set the default top-level name if required
if ( $BusMatrixName eq '' ) {
  $BusMatrixName = sprintf( $Product."_ahb_busmatrix_%dx%d%s%dd%da%du", $SlaveInterfaces,
                     $MasterInterfaces, substr($ArbiterType, 0, 1),
                     $RoutingDataWidth, $RoutingAddressWidth, $UserSignalWidth );
}

$OutputArbName        = $BusMatrixName.'_output_arb' if $OutputArbName eq '';
$OutputStageName      = $BusMatrixName.'_output_stage' if $OutputStageName eq '';
$MatrixDecodeName     = $BusMatrixName.'_decode' if $MatrixDecodeName eq '';
$InputStageName       = $BusMatrixName.'_input_stage' if $InputStageName eq '';


# Set the default IP-XACT component name if required
if ( $ComponentName eq '' ) { $ComponentName = $BusMatrixName; }


# ------------------------------------------------------------------------------
#   Validate the parameters and abort if necessary
# ------------------------------------------------------------------------------

ValidateParameters();
if ( $Errors ) { die "\nBuild not started because of parameter errors!\n\n"; }


# ------------------------------------------------------------------------------
#   Determine calculated parameters
# ------------------------------------------------------------------------------

SelectParameters();


# ------------------------------------------------------------------------------
#   Display settings when in verbose mode
# ------------------------------------------------------------------------------

my $XmlTimescales_interpreted = ($XmlTimescales eq 'yes' || $XmlTimescales eq 'no') ? $XmlTimescales
                                                                                   : "no ($XmlTimescales)";

if ( !$Quiet ) {
  printf "Script accepted the following parameters:\n\n" .
         "%s - Top-level name          : '$BusMatrixName'\n" .
         " - Slave interfaces        : $SlaveInterfaces\n" .
         " - Master interfaces       : $MasterInterfaces\n" .
         " - Architecture type       : '$ArchitectureType'\n" .
         " - Arbitration scheme      : '$ArbiterType'\n" .
         " - Remap signal width      : '$RemapBitWidth'\n" .
         " - Master signal width     : '$MasterBitWidth'\n" .
         " - Connectivity mapping    : %s\n" .
         " - Connectivity type       : %s\n" .
         " - Routing data width      : $RoutingDataWidth\n" .
         " - Routing address width   : $RoutingAddressWidth\n" .
         " - User signal width       : $UserSignalWidth\n" .
         " - Timescales              : ". ($Timescales ? "yes" :
                                                         $NoTimescales ? "no" :
                                                                         '') .
                                       ( $XmlTimescales ? $Timescales || $NoTimescales ? " - overriding $XmlTimescales_interpreted setting from XML"
                                                                                       : "$XmlTimescales_interpreted (from XML)"
                                                         : '' ) .
                                       ( ! ($XmlTimescales || $Timescales || $NoTimescales) ? 'no (default)' : '') . "\n" .
         " - Overwrite               : %s\n" .
         " - Output directory        : '$TargetDir/'\n\n",
         ( $XmlConfigFile ne '' ) ? " - Configuration file      : '$XmlConfigFile'\n" : " - Configuration through command line options\n",
         ( $Connectivity ne 'full' ) ? $Connections : 'automatic',
         ( $Sparse ) ? 'sparse' : 'full',
         ( $Overwrite ) ? 'enabled' : 'disabled';
}


# ------------------------------------------------------------------------------
#   Expand template macros if not in check mode
# ------------------------------------------------------------------------------

unless ( $CheckMode ) { CreateBusMatrix(); }


################################################################################
### Subroutines and Functions ##################################################
################################################################################

# ------------------------------------------------------------------------------
#   SelectParameters - Selects the corresponding parameter set according to
#                       the fundamental specification
# ------------------------------------------------------------------------------
sub SelectParameters {

  # Local variable(s)
  my $Instance     = '';
  my $Index        = 0;
  my $Interface    = '';
  my %Arbiter      = ( fixed => $Product.'_ahb_bm_fixed_arb',
                       fixed_nolat => $Product.'_ahb_bm_fixed_nolat_arb',
                       burst => $Product.'_ahb_bm_burst_arb',
                       burst_nolat => $Product.'_ahb_bm_burst_nolat_arb',
                       round => $Product.'_ahb_bm_round_arb',
                       round_nolat => $Product.'_ahb_bm_round_nolat_arb' );
  my $ArbType      = '';
  my $OutType      = '';
  my $MakefileName = 'makefile';
  my $MkfileName   = $Product.'_ahb_busmatrix.mk';
  my $IPXACTFile   = $Product.'_ahb_busmatrix_ipxact.xml';
  my $vcfileName   = $Product.'_ahb_busmatrix.vc';
  my $Mappings     = $Connections;
  my $Packing      = ' ' x 14;
  my $RemapBit     = 0;
  my $OpenBr       = '';
  my $CloseBr      = '';
  my @RemapBits    = ();

  # Determine the connectivity type
  $Sparse = IsSparse();

  # Determine the slave interface ID width
  $IdWidthSI = NumberOfDigits($SlaveInterfaces - 1, 2);

  # Determine the master interface ID width, including an MSbit for
  #  selecting the default slave
  $IdWidthMI = NumberOfDigits($MasterInterfaces - 1, 2) + 1;

  # Format the mappings
  $Mappings =~ s/\n/\n\/\//g;

  # Determine single entity filenames
  $FileList{$ComponentName.'.mk'} = $MkfileName if (-e "$SourceDir/verilog/$MkfileName") and $Debug;
  $FileList{'Makefile'} = $MakefileName if (-e "$SourceDir/verilog/$MakefileName") and $Debug;
  $FileList{$ComponentName.'.vc'} = $vcfileName;
  $DefaultSlave = $BusMatrixName . '_default_slave';
  $FileList{$BusMatrixName . $HdlExt} = $Product.'_ahb_busmatrix' . $HdlExt;
  #$FileList{$ComponentName . $HdlExt} = $Product.'_ahb_busmatrix_lite' . $HdlExt; # Rolled into main file
  $FileList{$InputStageName . $HdlExt} = $Product.'_ahb_bm_input_stage' . $HdlExt;
  $FileList{$DefaultSlave . $HdlExt} = $Product.'_ahb_bm_default_slave' . $HdlExt;
  if ( $IPXACT ) {
     $FileList{$ComponentName . '.xml'} = $IPXACTFile;
     #
     #if ( $RemapBitWidth ) {
     #   $FileList{$Product . '_busmatrix_busdef.xml'} = $Product.'_ahb_busmatrix_busdef_remap.xml';
     #   $FileList{$Product . '_busmatrix_busdef_rtl.xml'} = $Product.'_ahb_busmatrix_busdef_remap_rtl.xml';
     #}
  }

  # Generate filenames and macro names for each instance of bm_decode
  #  and process any REMAP declarations accordingly
  $Section{'remap_used'} = '0';
  $Section{'no_remap_used'} = '1';
  for ( $Index = 0; $Index < $SlaveInterfaces; $Index++ ) {
    $Interface = 'SI' . $Index;

    $Instance = $MatrixDecodeName . '_' . $InterfaceInfo{SLAVES}{$Interface}{NAME};
    $FileList{$Instance . $HdlExt} = $Product.'_ahb_bm_decode' . $HdlExt;
    push @MatrixDecodeNames, $Instance;

    $RemapInfo{$Interface}{REMAP_BITS} = [];
    $RemapInfo{$Interface}{REMAP_WIDTH} = 0;
    $RemapInfo{$Interface}{REMAP_MAPPING} = {};
    @RemapBits = ();
    for ( $RemapBit = 0; $RemapBit < $RemapBitWidth; $RemapBit++ ) {
      if ( ( grep /:remap$RemapBit:/,
             @{ $InterfaceInfo{SLAVES}{$Interface}{ADDRESS_MAP}{REMAP} } ) ||
           ( grep /:.*(del|_|,|\s)$RemapBit(_|,|\s|:|$)/,
             @{ $InterfaceInfo{SLAVES}{$Interface}{ADDRESS_MAP}{NORMAL} } ) ) {
        push @RemapBits, "remap[$RemapBit]";
        push @{ $RemapInfo{$Interface}{REMAP_BITS} }, $RemapBit;
        $RemapInfo{$Interface}{REMAP_MAPPING}{$RemapBit} = $RemapInfo{$Interface}{REMAP_WIDTH};
        $RemapInfo{$Interface}{REMAP_WIDTH}++;
        $Section{'remap_used'} = '1';
        $Section{'no_remap_used'} = '0';
      }
    }
    $OpenBr = ( $RemapInfo{$Interface}{REMAP_WIDTH} > 1 ) ? '{ ' : '';
    $CloseBr = ( $RemapInfo{$Interface}{REMAP_WIDTH} > 1 ) ? ' }' : '';
    $RemapInfo{$Interface}{REMAP_PORT} = $OpenBr . join( ', ', reverse @RemapBits ) . $CloseBr;
  }

  print "RemapInfo:\n" if $Debug;
  print Dumper(\%RemapInfo) if $Debug;

  # Determine names for the output_arb and output_stage instances
  if ( $Sparse ) {

    # Generate filenames and macro names for each instance of output_stage and
    #  output_arb modules
    for ( $Index = 0; $Index < $MasterInterfaces; $Index++ ) {
      $Interface = 'MI' . $Index;

      # If the current output stage has only one connection, then override
      #  the template selection for the arbiter type and output stage
      $ArbType = $Arbiter{$ArbiterType}; $OutType = $Product.'_ahb_bm_output_stage';
      if ( @{ $InterfaceInfo{MASTERS}{$Interface}{CONNECTIONS} } > 1 ) {
        $Instance = $OutputArbName . '_' . $InterfaceInfo{MASTERS}{$Interface}{NAME};
        $FileList{$Instance . $HdlExt} = $ArbType . $HdlExt;
        push @OutputArbNames, $Instance;
      } else
      {
        $OutType = $Product.'_ahb_bm_single_output_stage';
      }

      $Instance = $OutputStageName . '_' . $InterfaceInfo{MASTERS}{$Interface}{NAME};
      $FileList{$Instance . $HdlExt} = $OutType . $HdlExt;
      push @OutputStageNames, $Instance;

    }

  } else {

    # The same output_stage and output_arb modules are used in a fully connected
    #  bus matrix
    $FileList{$OutputArbName . $HdlExt} = $Arbiter{$ArbiterType} . ${HdlExt};
    push @OutputArbNames, $OutputArbName;
    $FileList{$OutputStageName . $HdlExt} = $Product.'_ahb_bm_output_stage' . ${HdlExt};
    push @OutputStageNames, $OutputStageName;

    # Initialise particular static instance names
    $Macro{'output_arb_name'} = $OutputArbName;
    $Macro{'output_stage_name'} = $OutputStageName;
    $Macro{'output_stage_name_lc'} = lc($Macro{'output_stage_name'});

  }

  $Macro{'tgt_dir'} = $env_TargetDir;

  print "FileList:\n" if $Debug;
  print Dumper(\%FileList) if $Debug;

  # Conditionally initialise the macro and section control hashes

  $Macro{'prot'}           = 6;
  $Macro{'prot_v'}         = 7;     #HPROT is extended in AHB5

  if ( !($Slave_Type eq 'target') ){
    $Section{'m_hsel'}       = 0;
    $Section{'no_m_hsel'}    = 1;     # to generate tie-offs
  } else {
    $Section{'m_hsel'}       = 1;
    $Section{'no_m_hsel'}    = 0;
  }

  if ($Slave_Type eq 'target') {
    $Section{'target_slave'}    = 1;
    $Section{'initiator_slave'} = 0;
  } else {
    $Section{'target_slave'}    = 0;
    $Section{'initiator_slave'} = 1;
  }

  # sections that depend on arbiter type
  my $arb_type_i;
  foreach $arb_type_i (keys(%Arbiter)) {
    $Section{      "$arb_type_i"."_arb"} =    $arb_type_i eq $ArbiterType;
    $Section{"no_"."$arb_type_i"."_arb"} = !( $arb_type_i eq $ArbiterType );
  }
  (my $nolat_arb_i) = $ArbiterType =~ /.*_nolat$/ ;
  $Section{"nolat_arb"}      =  $nolat_arb_i;
  $Section{"registered_arb"} = !$nolat_arb_i;


  # Determine xUSER width
  $Section{'user'}    = ( $UserSignalWidth > 0 ) ? 1 : 0;

  # Bus width fields
  $Macro{'data'}    = $RoutingDataWidth - 1;
  $Macro{'data_v'}  = $RoutingDataWidth;
  $Macro{'addr'}    = $RoutingAddressWidth - 1;
  $Macro{'addr_v'}  = $RoutingAddressWidth;
  $Macro{'address_space_range'} = $RoutingAddressWidth >= 40 ? (2**($RoutingAddressWidth-40) )."T" :
                                  $RoutingAddressWidth >= 30 ? (2**($RoutingAddressWidth-30) )."G" :
                                  $RoutingAddressWidth >= 20 ? (2**($RoutingAddressWidth-20) )."M" :
                                  $RoutingAddressWidth >= 10 ? (2**($RoutingAddressWidth-10) )."K" :
                                                                2**$RoutingAddressWidth ;    # P and E not supported by IP-XACT standard
  $Macro{'user'}    = $UserSignalWidth<=100 ? sprintf("%2d",$UserSignalWidth - 1) : $UserSignalWidth - 1;
  $Macro{'user_v'}  = $UserSignalWidth;

  # Interface ID-width fields
  $Macro{'idw_si'}   = $IdWidthSI - 1;
  $Macro{'idw_si_v'} = $IdWidthSI;
  $Macro{'idw_mi'}   = $IdWidthMI - 1;
  $Macro{'idw_mi_v'} = $IdWidthMI;

  # Determine default slave selection encoding (can be up to 5 bits)
  $Macro{'dsid_bin'} = substr('10000', 0, $IdWidthMI);

  # Determine a list of sub-module names
  $Macro{'other_module_names'} = $DefaultSlave . " \\\n$Packing" .
                                 $InputStageName . " \\\n$Packing" .
                                 join( " \\\n$Packing", @MatrixDecodeNames ) .
                                 " \\\n$Packing" .
                                 join( " \\\n$Packing", @OutputArbNames ) .
                                 " \\\n$Packing" .
                                 join( " \\\n$Packing", @OutputStageNames );

  # Determine a list of sub-module names
  $Macro{'file_list'} = "$env_TargetDir/$ComponentName/verilog/". $DefaultSlave . "$HdlExt\n" .
                        "$env_TargetDir/$ComponentName/verilog/". $InputStageName . "$HdlExt\n" .
                        sprintf("$env_TargetDir/$ComponentName/verilog/%s$HdlExt\n" x @MatrixDecodeNames , @MatrixDecodeNames ) .
                        sprintf("$env_TargetDir/$ComponentName/verilog/%s$HdlExt\n" x @OutputArbNames ,    @OutputArbNames ) .
                        sprintf("$env_TargetDir/$ComponentName/verilog/%s$HdlExt\n" x @OutputStageNames ,  @OutputStageNames ) .
                        "$env_TargetDir/$ComponentName/verilog/". $BusMatrixName . "$HdlExt\n" ;

  # Initialise the static instance names
  $Macro{'bus_matrix_name'} = $BusMatrixName;
  $Macro{'input_stage_name'} = $InputStageName;
  $Macro{'output_arb_stemname'} = $OutputArbName;
  $Macro{'output_stage_stemname'} = $OutputStageName;
  $Macro{'matrix_decode_stemname'} = $MatrixDecodeName;
  $Macro{'component_name'} = $ComponentName;

  # Miscellaneous fields
  $Macro{'copyright_year'} = $Year;
  $Macro{'timescale_directive'} = ( $Timescales || ( ($XmlTimescales eq 'yes') && !$NoTimescales )) ? "\n`timescale 1ns/1ps\n" : '' ;
  $Macro{'arbiter_type'} = $ArbiterType;
  $Macro{'architecture_type'} = $ArchitectureType;
  $Macro{'total_si'} = $SlaveInterfaces;
  $Macro{'total_mi'} = $MasterInterfaces;
  $Macro{'connectivity'} = ( $Sparse ) ? 'sparse' : 'full';
  $Macro{'mappings'} = ( $Sparse ) ? $Mappings :
    sprintf("S<0..%d> -> M<0..%d>", $SlaveInterfaces - 1, $MasterInterfaces - 1);

  $Macro{'remap_width'} = $RemapBitWidth-1;
  $Macro{'remap_width_v'} = $RemapBitWidth;
  $Macro{'master_width'} = $MasterBitWidth-1;
  $Macro{'master_width_v'} = $MasterBitWidth;
  $Section{'remap_port'} = $RemapBitWidth;


}


# ------------------------------------------------------------------------------
#   CreateBusMatrix - Creates a version of the Bus Matrix using the currently
#                      selected parameter set
# ------------------------------------------------------------------------------
sub CreateBusMatrix {

  # Local variable(s)
  my $VariantDir    = "$TargetDir/$BusMatrixName";
  my @ExistingFiles = glob( "$VariantDir/$HdlType/* $VariantDir/ipxact/*" );
  my @NewFiles      = keys( %FileList );
  my $File          = '';
  my $SourceType    = '';
  my $OutDir        = '';

  if ( !( -e $TargetDir ) ) {
    die "Error: The target director '$TargetDir' does not exist.\n";
  }

  # Determine target preparation
  if ( -e $VariantDir ) {
    # Delete files when in overwrite mode, otherwise display an error
    if ( $Overwrite ) {
      foreach $File ( @ExistingFiles ) {
        print "Deleting the '$File' file...\n" if ( $Verbose );
        unlink $File or die "Error: Could not delete the file!\n\n";
      }
      if ( !($IPXACT) ) {
        -e "$VariantDir/ipxact" and rmdir "$VariantDir/ipxact" and print "Deleting the '$VariantDir/ipxact' directory...\n" if ( $Verbose );
      } else {
        -e "$VariantDir/ipxact" or mkdir "$VariantDir/ipxact" or
         die "Error: Could not create the ipxact directory '$VariantDir/ipxact'!\n\n";
       }
      print "\n" if ( @ExistingFiles and $Verbose );
    } else {
      die "Error: This variant of the bus matrix already exists!\n\n";
    }
  } else {
    # Create the output directory for this Bus Matrix variant
    mkdir $VariantDir or
     die "Error: Could not create the output directory '$VariantDir'!\n\n";
    mkdir "$VariantDir/$HdlType" or
     die "Error: Could not create the $HdlType directory '$VariantDir/$HdlType'!\n\n";
    if ($IPXACT) {
      mkdir "$VariantDir/ipxact" or
       die "Error: Could not create the ipxact directory '$VariantDir/ipxact'!\n\n";
    }
  }

  # Process all required files
  print "Creating the bus matrix variant...\n" if !$Quiet;
  foreach $File ( @NewFiles ) {
    ($SourceType) = $File =~ /\.?([^.\/]*)$/ ;
    if ($SourceType eq 'v') {
      $OutDir = 'verilog';
      print "\n - Rendering verilog file '$File'" if ( $Verbose );
    } elsif ($SourceType eq 'xml') {
      $OutDir = 'ipxact';
      print "\n - Rendering ipxact file '$File'" if ( $Verbose );
    } elsif ($SourceType eq 'mk') {
      $OutDir = 'verilog';
      print "\n - Rendering mk file '$File'" if ( $Verbose );
    } elsif ($SourceType eq 'Makefile') {
      $OutDir = 'verilog';
      print "\n - Rendering makefile file '$File'" if ( $Verbose );
    } elsif ($SourceType eq 'vc') {
      $OutDir = 'verilog';
      print "\n - Rendering filelist (vc) file '$File'" if ( $Verbose );
    } else {
      die "Unexpected source file extension $SourceType of file $File";
    }

    RenderFile( "$SourceDir/$OutDir/$FileList{$File}", "$VariantDir/$OutDir/$File" );
  }

  print "\n" if $Verbose;
  print "\nDone!\n\n" if !( $Quiet );

}


# ------------------------------------------------------------------------------
#   RenderFile - Processes nested sections embedded hierarchically within the
#                 specified template file, and expands macros accordingly. The
#                 variables '$SlaveIF' and '$MasterIF' have a reserved use
#                 depending upon the template being rendered. The variables may
#                 be assigned values from 'in' or 'out' sections, or assigned
#                 to a value extracted from a port-specific target filename. In
#                 all other cases, these variables just retain their values
# ------------------------------------------------------------------------------
sub RenderFile {

  # Passed parameter 1 is the template filename
  my $TemplateFile = shift;
  # Passed parameter 2 is the rendered output filename
  my $RenderedFile = shift;

  # Local variable(s)
  my $TextLine     = '';
  my $Field        = '';
  my $Type         = '';
  my $Level        = 0;
  my $LineNum      = 0;
  my $SectionName  = '';
  my $SectionStartOrEnd  = '';
  my $SectionStart = 0;
  my $SectionEnd   = 0;
  my @Section      = ( { LINE => 0, PTR => 0, NAME => '', COPIES => 0, COUNT => 0, EN => 0 } );
  my ($SourceFile) = $TemplateFile =~ /([\w\.]+)$/;
  my $RefId        = 0;
  my $Interface    = '';
  my $SlaveIF      = '';
  my $MasterIF     = '';
  my @MIRegions    = ();
  my @FoundRegions = ();
  my $Decodings    = 0;
  my $AddrLo       = '';
  my $AddrHi       = '';
  my $Remapping    = '';
  my $Unmapping    = '';
  my $RemapBit     = 0;
  my $Bit          = 0;
  my $RemapState   = 0;
  my @ActiveRemap  = ();
  my $GotFirst     = 0;
  my $Arbiters     = $Product.'_ahb_bm_burst_arb|'.
                     $Product.'_ahb_bm_burst_nolat_arb|'.
                     $Product.'_ahb_bm_fixed_arb|'.
                     $Product.'_ahb_bm_fixed_nolat_arb|'.
                     $Product.'_ahb_bm_round_arb|'.
                     $Product.'_ahb_bm_round_nolat_arb';
  my @PortIds      = ();
  my $TotalIds     = 0;
  my @IPXACTFiles  = ( $BusMatrixName, $DefaultSlave, $InputStageName,
                       @MatrixDecodeNames, @OutputArbNames, @OutputStageNames );
  my %RemapTypes   = ( none => 'Static', alias => 'Alias', move => 'Unmoved' );
  my $Debug        = $RenderDebug;
  my @i_remapstate = ();

  # Open the template file for reading
  open( IN, "<$TemplateFile")
    or die "Error: Cannot open input template file '$TemplateFile'!\n\n";

  # Open the output file for writing the rendered text
  open( OUT, ">$RenderedFile" )
    or die "Error: Cannot write output file '$RenderedFile'!\n\n";

  my $comment = '';
  my $comment_end = '';
  (my $TemplateExt) =  $TemplateFile =~ /\.?([^.\/]*)$/;
  print "Found template extension: $TemplateExt" if $Debug;
  if (($TemplateExt eq 'v') ||
      ($TemplateExt eq 'vc'))         { $comment = '//';    $comment_end = '';   }
  elsif ($TemplateExt eq 'mk' ||
         $TemplateExt eq 'makefile')  { $comment = '#';     $comment_end = '';   }
  elsif ($TemplateExt eq 'xml')       { $comment = '<!--';  $comment_end = '-->';}

  $Macro{'copyright_header'} =   ($TemplateExt eq 'xml'?
    "$comment - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - $comment_end\n" :
    "$comment-----------------------------------------------------------------------------$comment_end\n"     ).
    "$comment The confidential and proprietary information contained in this file may     $comment_end\n".
    "$comment only be used by a person authorised under and to the extent permitted       $comment_end\n".
    "$comment by a subsisting licensing agreement from ARM Limited or its affiliates.     $comment_end\n".
    "$comment                                                                             $comment_end\n".
    "$comment            (C) COPYRIGHT 2001-$Year ARM Limited or its affiliates.           $comment_end\n".
    "$comment                ALL RIGHTS RESERVED                                          $comment_end\n".
    "$comment                                                                             $comment_end\n".
    "$comment This entire notice must be reproduced on all copies of this file            $comment_end\n".
    "$comment and copies of this file may only be made by a person if such person is      $comment_end\n".
    "$comment permitted to do so under the terms of a subsisting license agreement        $comment_end\n".
    "$comment from ARM Limited or its affiliates.                                         $comment_end\n". ($TemplateExt eq 'xml'?
    "$comment - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - $comment_end" :
    "$comment-----------------------------------------------------------------------------$comment_end"     );

  # Remove extra spaces if no commend_nd required
  $Macro{'copyright_header'} =~ s/\s*\n/\n/gi;

  $Macro{'version_control_header'} =
    "$comment                                                                             $comment_end\n".
    "$comment      Version Information                                                        $comment_end\n".
    "$comment                                                                             $comment_end\n".
    "$comment      Checked In          : Thu Jun 1 08:30:31 2017 +0100                                          $comment_end\n".
    "$comment                                                                             $comment_end\n".
    "$comment      Revision            : ff06b35                                      $comment_end\n".
    "$comment                                                                             $comment_end\n".
    "$comment      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0                                         $comment_end\n".
    "$comment                                                                             $comment_end";

  # Remove extra spaces if no commend_nd required
  $Macro{'version_control_header'} =~ s/\s*\n/\n/gi;

  # For the bm_decode template only, initialise specific macros and variables
  if ( $TemplateFile =~ /.*ahb_bm_decode$HdlExt$/ ) {

    # Set the current instance name for search and replacement, and also extract
    #  the slave interface number for reference use
    if ( ($SlaveIF) = $RenderedFile =~ /$MatrixDecodeName\_(\w+)$HdlExt$/ ) {
      $Macro{'matrix_decode_name'} = $MatrixDecodeName . '_' . $SlaveIF;
      $Macro{'matrix_decode_name_lc'} = lc($Macro{'matrix_decode_name'});
      $SlaveIF = $NameAliases{$SlaveIF} if ( $XmlConfigFile ne '' );
    }

    # Initialise macros for search and replace, then determine if the map or
    #  remap section is to be processed
    $Section{'remap'} = 0;
    $Macro{'idw_remap'} = '';
    $Macro{'idw_remap_v'} = '';
    $Macro{'bin_remapstate'} = '';
    $Macro{'remapping_vector'} = '';
    $Macro{'region_type'} = '';
    if ( $RemapInfo{$SlaveIF}{REMAP_WIDTH} > 0 ) {
      $Section{'remap'} = 1;
      $Macro{'idw_remap'} = $RemapInfo{$SlaveIF}{REMAP_WIDTH} - 1;
      $Macro{'address_map'} = '';
      $Macro{'mem_lo'} = '';
      $Macro{'mem_hi'} = '';
      $Macro{'remapping_vector'} = $RemapInfo{$SlaveIF}{REMAP_PORT};
    }
    $Section{'map'} = ( $Section{'remap'} ) ? 0 : 1;

  }

  # For a sparse bus matrix only, and concerning the output_arb or output_stage
  #  only, set the current instance names for search and replacement. Also
  #  extract the master interface number for reference use
  if ( $Sparse ) {
    if ( $TemplateFile =~ /($Arbiters)$HdlExt$/ ) {
      if ( ($MasterIF) = $RenderedFile =~ /$OutputArbName\_(\w+)$HdlExt$/ ) {
        $Macro{'output_arb_name'} = $OutputArbName . '_' . $MasterIF;
        $MasterIF = $NameAliases{$MasterIF} if ( $XmlConfigFile ne '' );
      }
    } elsif ( $TemplateFile =~ /.*_ahb_bm(_single)?_output_stage$HdlExt$/ ) {
      if ( ($MasterIF) = $RenderedFile =~ /$OutputStageName\_(\w+)$HdlExt$/ ) {
        $Macro{'output_stage_name'} = $OutputStageName . '_' . $MasterIF;
        $Macro{'output_stage_name_lc'} = lc($Macro{'output_stage_name'});
        if ($TemplateFile =~ /.*_ahb_bm_output_stage$HdlExt$/) {
          $Macro{'output_arb_name'} = $OutputArbName . '_' . $MasterIF;
        }
        $MasterIF = $NameAliases{$MasterIF} if ( $XmlConfigFile ne '' );
        $MasterIF =~ /([0-9]+)$/;

      }
    }
  }

  # Convert default slave name
  $Macro{'default_slave_name'} = $DefaultSlave;

  # Process each line of the template file
  while ( $TextLine = <IN> ) {

    # Increment the source file line number
    $LineNum++;

    print sprintf("%5s:",$LineNum) . $TextLine if ( $Debug );

    # Expand any macro found in the line
    unless ( $TextLine !~ /<<[^<>]+>>/ ) {

      # Search for all replaceable macros within the line
      # Field is the entire tag including <<>>, Type is the text inside
      while ( ($Field, $Type) = $TextLine =~ /(<<(\w+)>>)/gc ) {

        if ($Type eq 'template_begin') {
          print "Found template begin mark, starting processing\n" if ( $Debug );
          $Section[$Level]{EN} = -1;    # skip this line but delay enable

        } elsif ( exists $Macro{$Type} or ($Type eq 'mdelse') ) {
          if ($Type eq 'mdelse') {
            $Macro{'mdelse'} = ( $Decodings > 0 ) ? 'else ' : '';
            $Decodings++ if $Section[$Level]{EN};
          }
          #Replace the entire tag (Field) with the macro corresponding to the text inside (Type)
          $TextLine =~ s/$Field/$Macro{$Type}/;
          print "Replaced '$Field' on line $LineNum of '$SourceFile' with '$Macro{$Type}'...\n" if ( $Debug );

          if ( ($Type eq 'rrelse') and ($Section[$Level]{EN}) ){
            $Macro{'rrelse'} = 'else ';
          }

        } else {
          warn "Warning: Unidentified field '$Field' on line $LineNum of '$SourceFile'...\n" if $Section[$Level]{EN} > 0;
        }
      }

      # Extract sections and store the current file pointer position
      if ( ($SectionStartOrEnd,$SectionName) = $TextLine =~ /<<\s+(start|end)\s+(.+)\s+>>/ ) {

        print $SectionStartOrEnd . " " . $SectionName ."\n" if $Debug;

        $SectionStart = $SectionStartOrEnd eq 'start';
        $SectionEnd   = $SectionStartOrEnd eq 'end';

        if (!$Section[$Level]{EN} & !($SectionEnd and $SectionName eq $Section[$Level]{NAME}) ) {
          printf ("Not using line ".$LineNum."\n") if $Debug;
          $SectionName = '';
        }

        if ($SectionStart) {

          # Store the information onto the section stack
          $Section[++$Level] = {
                                 LINE   => $LineNum,
                                 PTR    => tell(IN),
                                 NAME   => $SectionName,
                                 COPIES => 0,
                                 COUNT  => 0,
                                 EN     => 1
                               };

          print "Found start section $Level '$SectionName'\n" if ( $Debug );

          # Exclude child sections if the parent section was excluded, otherwise
          #  conditionally process specificaly named sections of the template
          if ( $Section[$Level - 1]{EN} == 0 ) {

            $Section[$Level]{EN} = 0;

          } elsif ( $Section{$SectionName} ) {  # Optional section

            $Section[$Level]{EN} = ( $Section{$SectionName} ) ? -1 : 0;

          } else {
            # Undefined section
            $Section[$Level]{EN} = 0;
          }
        }

        if ($SectionEnd) {

          print "Found end section $Level '$SectionName'\n" if ( $Debug );

          # Check for matching section markers
          unless ( $SectionName eq $Section[$Level]{NAME} ) {
            die "Error: Unexpected section end on line $LineNum of '$SourceFile'...\n\n";
          }

          # Determine if the section is to be repeated
          if ( $Section[$Level]{COUNT} < $Section[$Level]{COPIES} ) {

            # Adjust input file pointer and line number
            seek( IN, $Section[$Level]{PTR}, 0 );
            $LineNum = $Section[$Level]{LINE};

            printf ("Reversing back to line %d...\n", $LineNum + 1) if ( $Debug );

            $Section[$Level]{COUNT}++;

          } elsif ( $Level > 0 )  {
            $Level--;
            $SectionName = '';
          }

          # Do not include this line in the output
          unless ($Section[$Level]{EN} == 0) { $Section[$Level]{EN} = -1; }

        }


        if ( $SectionStart and $SectionName eq 'connection' ) {  # Optional section

          # Determine template specific settings
          if ( ($TemplateFile =~ /(${Product}_ahb_busmatrix|$Arbiters|${Product}_ahb_bm(_single)?_output_stage)$HdlExt$/) or
               ($TemplateFile =~ /${Product}_ahb_busmatrix_ipxact\.xml$/) ){
            $SlaveIF = 'SI' . $Macro{'in'};
          }
          $Interface = ( $TemplateFile =~ /($Arbiters|${Product}_ahb_bm(_single)?_output_stage)$HdlExt$/ ) ?
            $MasterIF : 'MI' . $Macro{'out'};

          # For sparse bus matrix only, check for at least one connection
          $Section[$Level]{EN} = ( grep /^$Interface$/,
            @{ $InterfaceInfo{SLAVES}{$SlaveIF}{CONNECTIONS} } or !$Sparse ) ? -1 : 0;

          # Indicate the first connection for the round_arb template
          if ( $TemplateFile =~ /${Product}_ahb_bm_round(_nolat)?_arb$HdlExt$/ and $Section[$Level]{EN} ) {
            $GotFirst = 1;
          }

        } elsif ( $SectionName eq 'in' ) {  # Common macro

          # Set the number of times this section will be repeated
          if ($SectionStart) {
            $Section[$Level]{COPIES} = $SlaveInterfaces - 1;
            $Section[$Level]{EN} = -1;
            $Macro{'colon_remap'}        = ($Section{'remap_port'} || ($Section[$Level]{COPIES} > 0)) ? ',' : '';
            $Macro{'colon_remap_user'}   = $Section{'user'} || $Section{'remap_port'} || $Section[$Level]{COPIES} > 0 ? ',' : '';
          } else {
            if ($Section[$Level]{COUNT} == $Section[$Level]{COPIES}) {
              $Macro{'colon_remap'}        = $Section{'remap_port'} ? ',' : '';
              $Macro{'colon_remap_user'}   = $Section{'user'} || $Section{'remap_port'} ? ',' : '';
            }
          }

          # Set the current slave interface number and macros
          $Macro{'in'} = $Section[$Level]{COUNT};
          $Interface = 'SI' . $Section[$Level]{COUNT};
          $Macro{'si_name'} = $InterfaceInfo{SLAVES}{$Interface}{NAME};
          $SlaveIF = $Interface;

          # Determine template specific settings
          if ( $TemplateFile =~ /($Arbiters|${Product}_ahb_bm(_single)?_output_stage)$HdlExt$/ ) {
            $Macro{'bin_in'} = ToBinary($Section[$Level]{COUNT}, $IdWidthSI);
            $GotFirst = 0 if $SectionStart;

          } elsif ( $TemplateFile =~ /${Product}_ahb_busmatrix$HdlExt$/ ) {

            $Macro{'matrix_decode_name'} = $MatrixDecodeNames[$Section[$Level]{COUNT}];
            $Macro{'matrix_decode_name_lc'} = lc($Macro{'matrix_decode_name'});
          }

          $Macro{'rrelse'} = '' if $SectionStart;

          # Determine if the remap section should be processed
          $Section{'remap'} = 0;
          $Macro{'remapping_vector'} = '';
          if ( $RemapInfo{$Interface}{REMAP_WIDTH} > 0 ) {
            $Section{'remap'} = 1;
            $Macro{'remapping_vector'} = $RemapInfo{$Interface}{REMAP_PORT};
          }

          $Section{'map'} = ( $Section{'remap'} ) ? 0 : 1;

          if ( ($Slave_Type eq 'target' && !$InterfaceInfo{SLAVES}{$SlaveIF}{SLAVE_TYPE} ) ||
               ($InterfaceInfo{SLAVES}{$SlaveIF}{SLAVE_TYPE} eq 'target') ) {
            $Section{'m_hsel'}       = 1;
            $Section{'no_m_hsel'}    = 0;
            $Section{'target_slave'}    = 1;
            $Section{'initiator_slave'} = 0;
          } else {
            $Section{'m_hsel'}       = 0;
            $Section{'no_m_hsel'}    = 1;
            $Section{'target_slave'}    = 0;
            $Section{'initiator_slave'} = 1;
          }

        } elsif ( $SectionName eq 'out' ) {  # Common macro

          # Set the number of times this section will be repeated
          if ($SectionStart) {
            $Section[$Level]{COPIES} = $MasterInterfaces - 1;
            $Section[$Level]{EN} = -1;
          } else {
          }

          # Set the current master interface number and macros
          $Macro{'out'} = $Section[$Level]{COUNT};
          $Interface = 'MI' . $Section[$Level]{COUNT};
          $Macro{'mi_name'} = $InterfaceInfo{MASTERS}{$Interface}{NAME};
          $Macro{'mi_name_lc'} = lc($Macro{'mi_name'});

          $Macro{'bin_out'} = ToBinary($Section[$Level]{COUNT}, $IdWidthMI - 1);

          # Full matrix uses the same output stage
          if ($Sparse) {
            $Macro{'output_stage_name'} = $OutputStageNames[$Section[$Level]{COUNT}];
            $Macro{'output_stage_name_lc'} = lc($Macro{'output_stage_name'});
          }

        } elsif ( $SectionName eq 'rrin' ) {  # Used in round_arb only

          if ($SectionStart) {

            # Determine the port ID enumeration and the total number
            if ( $Sparse ) {
              @PortIds = @{ $InterfaceInfo{MASTERS}{$MasterIF}{CONNECTIONS} };
              @PortIds = grep s/^SI//, @PortIds; # Remove all 'SI' prefixes
            } else {
              @PortIds = ( 0..$SlaveInterfaces-1 );
            }
            $TotalIds = scalar @PortIds;

            # Set the number of times this section will be repeated, and determine
            #  the slave interface ID macros for the round_arb template
            $Section[$Level]{COPIES} = $TotalIds - 1;
            $Section[$Level]{EN} = -1;

          } else {
          }

          $Macro{'rrin'} = $PortIds[$Section[$Level]{COUNT}];
          $Macro{'rrin_name'} = $InterfaceInfo{SLAVES}{ 'SI' . $PortIds[$Section[$Level]{COUNT}] }{NAME};
          $Macro{'bin_rrin'} = ToBinary($PortIds[$Section[$Level]{COUNT}], $IdWidthSI);

        } elsif ( $SectionName eq 'rridx' ) {  # Used in round_arb only

          if ($SectionStart) {

            # Set the number of times this section will be repeated, and determine
            #  the slave interface ID macros for the round_arb template
            $Section[$Level]{COPIES} = $TotalIds - 2;
            $Section[$Level]{EN} = -1;
            $Macro{'rrelse'} = '';

            $RefId = ($Section[$Level - 1]{COUNT} + 1) % $TotalIds;
          } else {
            $Macro{'rrelse'} = 'else ';

            # Determine next round robin port
            $RefId = ++$RefId % $TotalIds;
          }

          $Macro{'rridx'} = $PortIds[$RefId];
          $Macro{'rridx_name'} = $InterfaceInfo{SLAVES}{ 'SI' . $PortIds[$RefId] }{NAME};
          $Macro{'bin_rridx'} = ToBinary($PortIds[$RefId], $IdWidthSI);

        } elsif ( $SectionStart and $SectionName eq 'addr_map' ) {  # Used in bm_decode only

          # All normal (non-remap) regions
          @MIRegions = @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{NORMAL} };

          # Initialise macros in preparation for search and replace
          $Macro{'address_map'} = '';
          $Macro{'mem_lo'} = '';
          $Macro{'mem_hi'} = '';

          # Include this section if a mapping exists
          $Section[$Level]{EN} = ( @MIRegions > 0 ) ? -1 : 0;

        } elsif ( $SectionName eq 'segments' ) {

          if ($SectionStart) {

            $Section[$Level]{COPIES} = scalar @{$AddressSpace{$Interface}} - 1;
            $Section[$Level]{EN} = -1;

          } else {
          }

          $Macro{'segment_name'} = '0x'.$AddressSpace{$Interface}[$Section[$Level]{COUNT}][0]."_".'0x'.$AddressSpace{$Interface}[$Section[$Level]{COUNT}][1];
          $Macro{'segment_offset'} = '0x'.$AddressSpace{$Interface}[$Section[$Level]{COUNT}][0];
          $Macro{'segment_range'} = '0x' . HexAdd(  '0'. HexSubstract($AddressSpace{$Interface}[$Section[$Level]{COUNT}][1],
                                                                      $AddressSpace{$Interface}[$Section[$Level]{COUNT}][0]) , 1 );

        } elsif ( $SectionName =~ /^(addr|remap)_region$/ ) {  # Used bm_decode and IPXACT file only

          # Conditionally reference the first address/remap region and extract its info
          if ( @MIRegions > 0 ) {

            if ($SectionStart) {
              # Set the number of copies
              $Section[$Level]{COPIES} = scalar @MIRegions - 1;
              $Section[$Level]{EN} = -1;
            } else {
            }

            ($MasterIF, $Remapping, $AddrLo, $AddrHi, $Unmapping) = split(/:/, $MIRegions[$Section[$Level]{COUNT}]);
            $Macro{'address_block_name'} = 'Default';
            $Macro{'address_block_remap'} = ($Remapping eq "move") ? 'TRUE' : 'FALSE';
            $Macro{'base_address'} = "0x$AddrLo";
            $Macro{'end_address'} = "0x$AddrHi";
            $Macro{'address_range'} = '0x' . HexSubstract($AddrHi, HexSubstract($AddrLo,1));
            $Macro{'address_map'} = "0x$AddrLo-0x$AddrHi";
            $Macro{'mem_lo'} = ToDecodeAddr($AddrLo);
            $Macro{'mem_hi'} = ToDecodeAddr($AddrHi);
            $Macro{'out'} = substr($MasterIF, 2);
            $Macro{'bin_out'} = ToBinary( substr($MasterIF, 2), $IdWidthMI - 1);
            $Macro{'mi_name'} = $InterfaceInfo{MASTERS}{$MasterIF}{NAME};
            $Macro{'mi_name_lc'} = lc($Macro{'mi_name'});
            if ($SectionEnd) {
              $Section{'remapped'} = ($Remapping =~ /^(move|remap).*/) ? 1 : 0;
              $Section{'not_remapped'} = !$Section{'remapped'};
            }

            my @bits = GetRemapBits ($Remapping, $Unmapping);

            my $remap_name = join( '_' , @bits );
            # Change ! to n
            $remap_name =~ s/!/n/g ;
            $Macro{'remap_name'} = "remap_".$remap_name;

            my $bit;
            $Macro{'active_cond'} = '';

            foreach $bit (@bits) {
              if (substr($bit,0,1) eq '!') {
                $Macro{'active_cond'} .= "\n" . ' 'x25 . ' & !remapping_dec['.$RemapInfo{$SlaveIF}{REMAP_MAPPING}{substr($bit,1)} .']';
              } else {
                $Macro{'active_cond'} .= "\n" . ' 'x25 . ' &  remapping_dec['.$RemapInfo{$SlaveIF}{REMAP_MAPPING}{$bit} .']';
              }
            }
            $Macro{'remapping_bit'} = $remap_name;

            $Section{'remap_static'} = @bits ? 0 : 1;
            $Section{'remap_conditional'} = @bits ? 1 : 0;

            if (@bits) {
              if ( substr($Remapping,0,5) eq 'remap' ) {
                $Macro{'region_type'} = "Remapped region, active when REMAP bitcombination is " . $remap_name;
                $Macro{'region_type_sanitized'} = "Remapped_" . $remap_name;
              } else {
                $Macro{'region_type'} = "Removable region, active only when REMAP bitcombination is " . $remap_name;
                $Macro{'region_type_sanitized'} = "Removable_" . $remap_name;
              }
            } else {
              $Macro{'region_type'} = "Static";
              $Macro{'region_type_sanitized'} = $Macro{'region_type'};
            }

          }

        } elsif ( $SectionName eq 'remap_state' ) {

          if ($SectionStart) {

            @i_remapstate = keys( %RemapStates );
            #$Macro{'remapping_bit'} = '';
            #$Macro{'idw_remap_v'} = $RemapInfo{$SlaveIF}{REMAP_WIDTH};

            # Initialise variables used in remap processing and calculate the required
            #  number of section copies

            $Section[$Level]{COPIES} = scalar @i_remapstate -1;
            $Section[$Level]{EN} = ($Section{'remap_used'} > 0) ? -1 : 0;

            #$Macro{'bin_remapstate'} = ToBinary(0, $RemapInfo{$SlaveIF}{REMAP_WIDTH});
          } else {
            #$RemapState++;
          }

          $RemapState = $Section[$Level]{COUNT};

          $Macro{'remap_name'} = $i_remapstate[$RemapState];
          print "Processing remap state: $Macro{'remap_name'}\n" if ( $Debug );
          #$Macro{'bin_remapstate'} = ToBinary($Section[$Level]{COUNT}, $RemapInfo{$SlaveIF}{REMAP_WIDTH});


          #$Macro{'top_remap_bin'} = '0' x $RemapBitWidth;
          #my $rbit;
          #my $cnt = 0;
          #foreach $rbit ( @{ $RemapInfo{$SlaveIF}{REMAP_BITS} } ) {
          #   substr($Macro{'top_remap_bin'}, -$rbit-1, 1, ( substr $Macro{'bin_remapstate'}, -$cnt-1, 1 ));
          #   $cnt++;
          #}
          #$Macro{'top_remap_hex'} = sprintf("%X", oct( "0b$Macro{'top_remap_bin'}" ) );

        } elsif ( $SectionName eq 'remap_bit' ) {  # Used in bm_decode only

          if ($SectionStart) {

            # Set the number of copies
            $Section[$Level]{COPIES} = scalar @{$RemapStates{$i_remapstate[$RemapState]}} -1;
            $Section[$Level]{EN} = -1;
            $Bit = 0;
          } else {
            $Bit++;
          }

          my $r_bit = @{$RemapStates{$i_remapstate[$RemapState]}}[$Section[$Level]{COUNT}];

          if (substr($r_bit,0,1) eq '!') {
            $Macro{'top_remap_bit'} = substr($r_bit,1);
            $Macro{'top_remap_bitvalue'} = 0;
          } else {
            $Macro{'top_remap_bit'} = $r_bit;
            $Macro{'top_remap_bitvalue'} = 1;
          }

        } elsif ( $SectionStart and $SectionName eq 'addr_remap_all' ) {

          # All remap regions
          @MIRegions = @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{REMAP} };

          # Initialise macros in preparation for search and replace
          $Macro{'address_map'} = '';
          $Macro{'mem_lo'} = '';
          $Macro{'mem_hi'} = '';

          # Include this section if a mapping exists
          $Section[$Level]{EN} = ( @MIRegions > 0 ) ? -1 : 0;

        } elsif ( $SectionStart and $SectionName eq 'addr_remap_and_normal_all_this_remap' ) {

          @MIRegions = ();

          # All remap regions
          my @allRegions = @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{REMAP} };
          push (@allRegions, @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{NORMAL} });
          foreach my $address_region ( @allRegions ) {

            ($MasterIF, $Remapping, $AddrLo, $AddrHi, $Unmapping) = split(/:/,$address_region);

            # get canonical name for remap state
            my @bits = GetRemapBits ($Remapping, $Unmapping);
            my $i_remap_name = join( '_' , @bits );
            # Change ! to n
            $i_remap_name =~ s/!/n/g ;

            if ($Macro{'remap_name'} eq "remap_".$i_remap_name) {
               push (@MIRegions,$address_region);
            }
          }

          # Initialise macros in preparation for search and replace
          $Macro{'address_map'} = '';
          $Macro{'mem_lo'} = '';
          $Macro{'mem_hi'} = '';

          # Include this section if a mapping exists
          $Section[$Level]{EN} = ( @MIRegions > 0 ) ? -1 : 0;

        } elsif ( $SectionName eq 'file' ) {  # Used in ipxact file only

          if ($SectionStart) {

            $Macro{'filename'} = $IPXACTFiles[0];
            $Section[$Level]{COPIES} = scalar @IPXACTFiles - 1;
            $Section[$Level]{EN} = -1;
          } else {
            $Macro{'filename'} = $IPXACTFiles[$Section[$Level]{COUNT}];
          }
        } elsif ( $SectionName eq 'topfile' ) {

            $Section[$Level]{EN} = ( $Macro{'filename'} eq $BusMatrixName ) ? -1 : 0;

        } elsif ( $SectionName eq 'vendor_extension' ) {  # Optional section

            # This is a dummy section
            $Section[$Level]{EN} = 0;

        } elsif ( $SectionName && ! exists $Section{$SectionName} ) {

           print "Warning: unknown section $SectionName on line $LineNum of '$SourceFile'...\n";
        }

        if ($SectionStart) {
          print "Section copies: $Section[$Level]{COPIES}\n" if ( $Debug );
        }
      }

    }

    # Write the line(s) to the rendered output file when (delay) enabled
    if ( $Section[$Level]{EN} ) {
      print OUT $TextLine if ( $Section[$Level]{EN} > 0 );
      $Section[$Level]{EN} = 1;
    } else {
      printf ("Not using line ".$LineNum."\n") if $Debug;
    }

  }

  # Close the template file and rendered output file
  close(IN);
  close(OUT);

  # If still inside a nested section, there were too few end macros
  unless ( $Level == 0 ) {
    die "Error: Section '$Section[$Level]{NAME}' expected in '$SourceFile'!\n\n";
  }

}


# ------------------------------------------------------------------------------
#   IsSparse - Determines the connectivity completeness
# ------------------------------------------------------------------------------
sub IsSparse {

  # Local variable(s)
  my $SlaveIF   = '';
  my @SlaveIFs  = keys( %{ $InterfaceInfo{SLAVES} } );
  my @MasterIFs = keys( %{ $InterfaceInfo{MASTERS} } );
  my $Mappings  = '';
  my $Result    = 0;

  # Check each mapping
  foreach $SlaveIF ( @SlaveIFs ) {
    $Mappings = join( '|', @{ $InterfaceInfo{SLAVES}{$SlaveIF}{CONNECTIONS} } );
    if ( grep $_ !~ /^($Mappings)$/, @MasterIFs ) { $Result = 1; last; }
  }

  return ($Result);
}


# ------------------------------------------------------------------------------
#   HexSubstract - Does argument1 - argument2 substraction in hex.
#                  Assumes argument1 >= argument2
# ------------------------------------------------------------------------------
sub HexSubstract {

  # Passed parameter 1 is the LHS hexadecimal operand value
  my $Value1 = shift;
  # Passed parameter 2 is the RHS hexadecimal operand value
  my $Value2 = shift;

  # Local variable(s)
  my $Len1   = length($Value1);
  my $Len2   = length($Value2);
  my $Index  = 0;
  my $Char1  = '';
  my $Char2  = '';
  my $Borrow = 0;
  my $Result = '';

  # Append zeros to the 2nd operand
  if ( $Len1 > $Len2 ) { $Value2 = '0' x ($Len1 - $Len2) . $Value2; }

   # Substract using strings instead of conversion to decimal to support 64 bit numbers
   for ( $Index = 1; $Index <= $Len1; $Index++ ) {
     $Char1 = hex substr($Value1, $Len1 - $Index, 1);
     $Char2 = hex substr($Value2, $Len1 - $Index, 1);
     if ( $Char1 < ($Char2 + $Borrow) ) {
       $Char1 = $Char1 + 16;
       $Result = sprintf("%1x", $Char1 - $Char2 - $Borrow) . $Result;
       $Borrow = 1;
     } else {
       $Result = sprintf("%1x", $Char1 - $Char2 - $Borrow) . $Result;
       $Borrow = 0;
     }
   }

   return ($Result);
}


# ------------------------------------------------------------------------------
#   HexAdd - Does argument1 + argument2 substraction in hex.
# ------------------------------------------------------------------------------
sub HexAdd {

  # Passed parameter 1 is the LHS hexadecimal operand value
  my $Value1 = shift;
  # Passed parameter 2 is the RHS hexadecimal operand value
  my $Value2 = shift;

  # Local variable(s)
  my $Len1   = length($Value1);
  my $Len2   = length($Value2);
  my $Index  = 0;
  my $Char1  = '';
  my $Char2  = '';
  my $Carry  = 0;
  my $Result = '';

  # Append zeros to the 2nd operand
  if ( $Len1 > $Len2 ) { $Value2 = '0' x ($Len1 - $Len2) . $Value2; }

   # Substract using strings instead of conversion to decimal to support 64 bit numbers
   for ( $Index = 1; $Index <= $Len1; $Index++ ) {
     $Char1 = hex substr($Value1, $Len1 - $Index, 1);
     $Char2 = hex substr($Value2, $Len1 - $Index, 1);
     if ( $Char1 +$Char2 + $Carry > 15) {
       $Result = sprintf("%1x", $Char1 + $Char2 + $Carry - 16) . $Result;
       $Carry = 1;
     } else {
       $Result = sprintf("%1x", $Char1 + $Char2 + $Carry) . $Result;
       $Carry = 0;
     }
   }

   return ($Result);
}


# ------------------------------------------------------------------------------
#   NumberOfDigits - Calculates the number of digits required to describe
#                     the specified integer value in the specified base
# ------------------------------------------------------------------------------
sub NumberOfDigits {

  # Passed parameter 1 is the integer value
  my $Value = shift;
  # Passed parameter 2 is the base
  my $Base = shift;

  # Local variable(s)
  my $Result  = 1;
  my $XToTheY = 0;

  # Determine the number of digits for values greater than the radix
  unless ( $Base < 2 or $Value < $Base ) {
    while ( $Value > $XToTheY ) { $XToTheY = $Base ** $Result++; }
    if ( $Value != $XToTheY ) { $Result--; }
  }

  return ( $Result );
}


# ------------------------------------------------------------------------------
#   NumberOfHexChars - Calculates the number of hexadecimal characters
#                       required to describe the specified number of bits
# ------------------------------------------------------------------------------
sub NumberOfHexChars {

  # Passed parameter 1 is the integer value
  my $Value = shift;

  # Local variable(s)
  my $Result   = $Value / 4.0;
  my $Integer  = int($Result);
  my $Fraction = $Result - $Integer;

  # Determine the number of digits
  $Result = ($Fraction > 0) ? $Integer + 1 : $Integer;

  return ( $Result );
}


# ------------------------------------------------------------------------------
#   ToBinary - Converts the specified integer into an n-bit binary string
# ------------------------------------------------------------------------------
sub ToBinary {

  # Passed parameter 1 is the integer value
  my $Value = shift;
  # Passed parameter 2 is the binary string length
  my $Length = shift;

  # Local variable(s)
  my $Format = "%0${Length}b";
  my $Result = ( $Value =~ /^\d+$/ ) ? sprintf($Format, $Value) : '';

  return ( substr($Result, -$Length, $Length) );
}


# ------------------------------------------------------------------------------
#   ToDecodeAddr - Shifts the specified n-bit address to the correct alignment
#                   for the Matrix Decoder because HADDR[9:0] is not decoded
# ------------------------------------------------------------------------------
sub ToDecodeAddr {

  # Passed parameter 1 is the address value
  my $FullAddr = shift;

  # Local variable(s)
  my $AddrBits = $RoutingAddressWidth - 10;
  my $HexChars = NumberOfHexChars($AddrBits);
  my $Length   = length($FullAddr);
  my $BinAddr  = sprintf( "%032b%032b", hex substr($FullAddr, 0, $Length - 8),
                                        hex substr($FullAddr, $Length - 8) );
  my $Result    = '';

  # Right-shift the binary string to remove the non-decoded bits, and repack
  #  it into 32-bit chunks for reformatting into a hexadecimal representation
  $BinAddr = '0' x 10 . substr($BinAddr, 0, -10);
  $Result  = sprintf( "%08lx%08lx",
               unpack( 'N', pack('B32', substr($BinAddr, 0, 32)) ),
               unpack( 'N', pack('B32', substr($BinAddr, 32)) ) );

  return ( sprintf("%d'h%s", $AddrBits, substr($Result, 16 - $HexChars)) );
}


# ------------------------------------------------------------------------------
#   UnsignedFloatToHex - Converts the specified float value into a hex string
# ------------------------------------------------------------------------------
sub UnsignedFloatToHex {

  # Passed parameter 1 is the float value
  my $Value = shift;

  # Local variable(s)
  my $HexDigits = NumberOfDigits($Value, 16);
  my $Divisor   = 16 ** ($HexDigits - 1);
  my $Dividend  = 0;
  my $Result    = '';

  # Determine number sequence
  while ( length($Result) < $HexDigits ) {
    $Dividend = int( $Value / $Divisor );
    if ( $Dividend > 0 ) {
      $Result = $Result . substr('0123456789abcdef', $Dividend, 1);
      $Value -= ($Divisor * $Dividend);
    } else {
      $Result = $Result . '0';
    }
    $Divisor /= 16;
  }

  return ($Result);
}


# ------------------------------------------------------------------------------
#   IsGtOrEq - Operator '>=' test for up to 64-bit hexadecimal numbers
# ------------------------------------------------------------------------------
sub IsGtOrEq {

  # Passed parameter 1 is the LHS value
  my $OperandLHS = shift;
  # Passed parameter 2 is the RHS value
  my $OperandRHS = shift;

  # Local variable(s)
  my $LengthLHS = length($OperandLHS);
  my @LHS       = ( hex substr($OperandLHS, 0, $LengthLHS - 8),
                    hex substr($OperandLHS, $LengthLHS - 8) );
  my $LengthRHS = length($OperandRHS);
  my @RHS       = ( hex substr($OperandRHS, 0, $LengthRHS - 8),
                    hex substr($OperandRHS, $LengthRHS - 8) );
  my $Result = ( $LHS[0] > $RHS[0] or
                 ($LHS[0] == $RHS[0] and $LHS[1] >= $RHS[1]) ) ? 1 : 0;

  return ($Result);
}


# ------------------------------------------------------------------------------
#   IsLtOrEq - Operator '<=' test for up to 64-bit hexadecimal numbers
# ------------------------------------------------------------------------------
sub IsLtOrEq {

  # Passed parameter 1 is the LHS value
  my $OperandLHS = shift;
  # Passed parameter 2 is the RHS value
  my $OperandRHS = shift;

  # Local variable(s)
  my $LengthLHS = length($OperandLHS);
  my @LHS       = ( hex substr($OperandLHS, 0, $LengthLHS - 8),
                    hex substr($OperandLHS, $LengthLHS - 8) );
  my $LengthRHS = length($OperandRHS);
  my @RHS       = ( hex substr($OperandRHS, 0, $LengthRHS - 8),
                    hex substr($OperandRHS, $LengthRHS - 8) );
  my $Result = ( $LHS[0] < $RHS[0] or
                 ($LHS[0] == $RHS[0] and $LHS[1] <= $RHS[1]) ) ? 1 : 0;

  return ($Result);
}

# ------------------------------------------------------------------------------
#   IsGt - Operator '>' test for up to 64-bit hexadecimal numbers
# ------------------------------------------------------------------------------
sub IsGt {

  # Passed parameter 1 is the LHS value
  my $OperandLHS = shift;
  # Passed parameter 2 is the RHS value
  my $OperandRHS = shift;

  # Local variable(s)
  my $LengthLHS = length($OperandLHS);
  my @LHS       = ( hex substr($OperandLHS, 0, $LengthLHS - 8),
                    hex substr($OperandLHS, $LengthLHS - 8) );
  my $LengthRHS = length($OperandRHS);
  my @RHS       = ( hex substr($OperandRHS, 0, $LengthRHS - 8),
                    hex substr($OperandRHS, $LengthRHS - 8) );
  my $Result = ( $LHS[0] > $RHS[0] or
                 ($LHS[0] == $RHS[0] and $LHS[1] > $RHS[1]) ) ? 1 : 0;

  return ($Result);
}


# ------------------------------------------------------------------------------
#   IsLt - Operator '<' test for up to 64-bit hexadecimal numbers
# ------------------------------------------------------------------------------
sub IsLt {

  # Passed parameter 1 is the LHS value
  my $OperandLHS = shift;
  # Passed parameter 2 is the RHS value
  my $OperandRHS = shift;

  # Local variable(s)
  my $LengthLHS = length($OperandLHS);
  my @LHS       = ( hex substr($OperandLHS, 0, $LengthLHS - 8),
                    hex substr($OperandLHS, $LengthLHS - 8) );
  my $LengthRHS = length($OperandRHS);
  my @RHS       = ( hex substr($OperandRHS, 0, $LengthRHS - 8),
                    hex substr($OperandRHS, $LengthRHS - 8) );
  my $Result = ( $LHS[0] < $RHS[0] or
                 ($LHS[0] == $RHS[0] and $LHS[1] < $RHS[1]) ) ? 1 : 0;

  return ($Result);
}

# ------------------------------------------------------------------------------
#   IsEq - Operator '=' test for up to 64-bit hexadecimal numbers
# ------------------------------------------------------------------------------
sub IsEq {

  # Passed parameter 1 is the LHS value
  my $OperandLHS = shift;
  # Passed parameter 2 is the RHS value
  my $OperandRHS = shift;

  # Local variable(s)
  my $LengthLHS = length($OperandLHS);
  my @LHS       = ( hex substr($OperandLHS, 0, $LengthLHS - 8),
                    hex substr($OperandLHS, $LengthLHS - 8) );
  my $LengthRHS = length($OperandRHS);
  my @RHS       = ( hex substr($OperandRHS, 0, $LengthRHS - 8),
                    hex substr($OperandRHS, $LengthRHS - 8) );
  my $Result = ($LHS[0] == $RHS[0] and $LHS[1] == $RHS[1]) ? 1 : 0;

  return ($Result);
}

# ------------------------------------------------------------------------------
#   TidyPath - Removes double and trailing slash characters from filename paths
# ------------------------------------------------------------------------------
sub TidyPath {

  # Passed parameter 1 is the filepath string
  my $Filepath = shift;

  $Filepath =~ s/(\/\/|\\)/\//g; $Filepath =~ s/\/$//;

  return ($Filepath);
}

# ------------------------------------------------------------------------------
#   GetRemapBits - Takes the Remapping and Unmapping (if exists) of an
#     address_region or remap_region and returns a sorted list of the bits
#     when the region is enabled. Returns an empty list if the region is always
#     enabled. Negative bits are marked with an exclamation mark
#   example:
#      a remap region that is activated by bit 3
#      but is eclipsed when bit 1 is active will return:
#     [
#       '!1',
#       '3'
#     ],
# ------------------------------------------------------------------------------
sub GetRemapBits {
  my $Remapping = shift;
  my $Unmapping = shift;
  my @bits = ();
  my @c_bits = ();
  my $r_bit;
  if (substr($Remapping,0,3) eq "del") {
     @c_bits = split ( /,| |_/,substr($Remapping,3)) ;
     foreach $r_bit (@c_bits) {
        if (!($r_bit eq '')) { # need to ignore leading empty characters generated by a leading separator
          push @bits, '!'.$r_bit;
        }
     }
  }
  if (substr($Remapping,0,5) eq "remap") {
     @c_bits = split ( /,| |_/,substr($Remapping,5)) ;
     foreach $r_bit (@c_bits) {
        if (!($r_bit eq '')) { # need to ignore leading empty characters generated by a leading separator
          push @bits, $r_bit;
        }
     }
  }
  if ($Unmapping) {
     @c_bits = split ( /,| |_/,substr($Unmapping,5)) ;
     foreach $r_bit (@c_bits) {
        if (!($r_bit eq '')) { # need to ignore leading empty characters generated by a leading separator
          push @bits, '!'.$r_bit;
        }
     }
  }

  # Sort bits in order, so they are easier to match
  @bits = sort {
        my $c = $a;
        my $d = $b;
        if ( substr($a,0,1) eq '!') {
          $c = substr($a,1)
        }
        if ( substr($b,0,1) eq '!') {
          $d = substr($b,1)
        }

        $c <=> $d
      } @bits;
  return (@bits);
}


# ------------------------------------------------------------------------------
#   ValidateParameters - Checks the value of user configurable script parameters
# ------------------------------------------------------------------------------
sub ValidateParameters {

  # Local variable(s)
  my %Names         = (
                        bus_matrix_name     => \$BusMatrixName,
                        input_stage_name    => \$InputStageName,
                        matrix_decode_name  => \$MatrixDecodeName,
                        output_arbiter_name => \$OutputArbName,
                        output_stage_name   => \$OutputStageName
                      );
  my @NameKeys      = keys( %Names );
  my $Name          = '';
  my $NameLength    = 0;
  my $ShowName      = '';
  my @OtherNameKeys = ();
  my $OtherName     = '';
  my $Type          = '';
  my @Interfaces    = ();
  my $Interface     = '';

  # Validate permitted values for the total slave interfaces
  unless ( $SlaveInterfaces >= $MinSlaveIF and $SlaveInterfaces <= $MaxSlaveIF ) {
    warn "Error: The number of slave ports must be in the range from $MinSlaveIF to $MaxSlaveIF \n";
    $Errors++;
  }

  # Validate permitted values for the total master interfaces
  unless ( $MasterInterfaces >= $MinMasterIF and $MasterInterfaces <= $MaxMasterIF ) {
    warn "Error: The number of master ports must be in the range from $MinMasterIF to $MaxMasterIF \n";
    $Errors++;
  }

  # Raise a warning about the '1 x n' bus matrix configuration
  if ( $SlaveInterfaces == 1 ) {
    warn "Warning: This configuration has one slave port and will use 'single' output\n" .
         " and arbiter stage(s) only.\n";
  }

  # Validate permitted values of arbitration scheme
  unless ( $ArbiterType =~ /^(fixed|fixed_nolat|round|round_nolat|burst|burst_nolat)$/ ) {
    warn "Error: Invalid type of arbitration-scheme '$ArbiterType'!\n";
    $Errors++;
  }

  # Validate permitted values of arbitration scheme
  unless ( $Slave_Type =~ /^(target|initiator)$/ ) {
    warn "Error: Invalid slave type '$Slave_Type'! Only target or initiator allowed.\n";
    $Errors++;
  }

  # Validate permitted values of architecture version
  unless ( $ArchitectureType =~ /^(ahb5)$/ ) {
    warn "Error: Invalid type of architecture '$ArchitectureType'! Only 'ahb5' is supported.\n";
    $Errors++;
  }

  # Validate permitted values of routing-data width
  unless ( $RoutingDataWidth =~ /^($DataWidths)$/ ) {
    warn "Error: Invalid routing-data width '$RoutingDataWidth'!\n";
    $Errors++;
  }

  # Validate permitted values of user-signal width
  if ( $RoutingAddressWidth =~ /[^0-9]/ ) {
    warn "Error: Invalid routing-address width '$RoutingAddressWidth'!\n";
    $Errors++;
  } elsif ( $RoutingAddressWidth < $MinAddrWidth or $RoutingAddressWidth > $MaxAddrWidth ) {
    warn "Error: Routing-address width must be in the range $MinAddrWidth..$MaxAddrWidth!\n";
    $Errors++;
  }

  # Validate permitted values of remap-signal width
  if ( $RemapBitWidth =~ /[^0-9]/ ) {
    warn "Error: Invalid remap signal width '$RemapBitWidth'!\n";
    $Errors++;
  } elsif ( $RemapBitWidth < $MinRemapWidth or $RemapBitWidth > $MaxRemapWidth ) {
    warn "Error: Remap signal width must be in the range $MinRemapWidth..$MaxRemapWidth!\n";
    $Errors++;
  }

  # Validate permitted values of master signal width
  if ( $MasterBitWidth =~ /[^0-9]/ ) {
    warn "Error: Invalid master signal width '$MasterBitWidth'!\n";
    $Errors++;
  } elsif ( $MasterBitWidth < $MinMasterWidth or $MasterBitWidth > $MaxMasterWidth ) {
    warn "Error: Master signal width must be in the range $MinMasterWidth..$MaxMasterWidth!\n";
    $Errors++;
  }

  # Validate permitted values of user-signal width
  if ( $UserSignalWidth =~ /[^0-9]/ ) {
    warn "Error: Invalid user-signal width '$UserSignalWidth'!\n";
    $Errors++;
  } elsif ( $UserSignalWidth < $MinUserWidth or $UserSignalWidth > $MaxUserWidth ) {
    warn "Error: User-signal width must be in the range $MinUserWidth..$MaxUserWidth!\n";
    $Errors++;
  }

  # Validate permitted values of module names
  foreach $Name ( @NameKeys ) {
    $ShowName = $Name; $ShowName =~ s/_/ /g;
    $NameLength = length( ${ $Names{$Name} } );

    # Check for illegal characters and then check the string length
    if ( ${ $Names{$Name} } =~ /[^\w]/ ) {
      warn "Error: The $ShowName contains illegal characters!\n";
      $Errors++;
    } elsif ( $NameLength < $MinNameLength or $NameLength > $MaxNameLength ) {
      warn "Error: The $ShowName is incorrect length ($MinNameLength..$MaxNameLength characters)!\n";
      $Errors++;
    }

    # Check for unique name
    @OtherNameKeys = grep $_ ne $Name , @NameKeys;
    foreach $OtherName ( @OtherNameKeys ) {
      if ( ${ $Names{$OtherName} } eq ${ $Names{$Name} } ) {
        warn "Error: The $ShowName is not assigned a unique value!\n";
        $Errors++;
      }
    }
  }

  # Check interface information
  foreach $Type ( ('SLAVES', 'MASTERS') ) {

    @Interfaces = keys( %{ $InterfaceInfo{$Type} } );
    foreach $Interface ( @Interfaces ) {
      # Inspect interface names
      $Name = $InterfaceInfo{$Type}{$Interface}{NAME};
      if ( $Name =~ /[^\w]/ ) {
        warn "Error: Interface $Interface name '$Name' contains illegal characters!\n";
        $Errors++;
      }
      if ( length($Name) > $MaxNameLength ) {
        warn "Error: Interface $Interface name '$Name' is too long ($MaxNameLength" .
             " characters max)!\n";
        $Errors++;
      }

      # Inspect connectivity for isolated nodes resulting from an
      #  incomplete sparse mapping
      if ( @{ $InterfaceInfo{$Type}{$Interface}{CONNECTIONS} } == 0 ) {
        warn "Error: Interface $Interface has no connectivity mapping and is isolated!\n";
        $Errors++;
      }

      # If this is a slave, then check its address map
      if ( $Type eq 'SLAVES' ) { CheckAddressMap($Interface); }
    }

  }

}


# ------------------------------------------------------------------------------
#   CheckAddressMap - Checks the address map of the specified slave interface
#                      for tags and overlapping regions
# ------------------------------------------------------------------------------
sub CheckAddressMap {

  # Passed parameter 1 is the integer value
  my $SlaveIF = shift;

  # Local variable(s)
  my $Class       = '';
  my $Index       = 0;
  my $MasterIF    = '';
  my @MIRegions   = ();
  my $Region      = '';
  my $MI          = '';
  my $Tag         = '';
  my $RegionHi    = '';
  my $RegionLo    = '';
  my $RegionHiLSW = 0;
  my $RegionLoLSW = 0;
  my $CheckBound  = '';
  my $OtherRegion = '';
  my $OtherMI     = '';
  my $OtherHi     = '';
  my $OtherLo     = '';
  my $OtherTag    = 0;
  my $Exclusions  = '';
  my $HexChars    = NumberOfHexChars($RoutingAddressWidth);
  my %Tags        = ( NORMAL => 'none|move|alias|del(_|,|\s)?(1[0-5]|[0-9])((_|,|\s)(1[0-5]|[0-9]))*',  REMAP => 'remap([0-9]|1[0-5])' );
  my %TagMessages = ( NORMAL => 'remapping action', REMAP => 'REMAP bit' );
  my %WarnType    = ( NORMAL => 'address', REMAP => 'remap' );

  # Process each mapping type
  foreach $Class ( ('REMAP','NORMAL') ) {

    # Check the address map for each master interface
    for ( $Index = 0; $Index < $MasterInterfaces; $Index++ ) {
      $MasterIF = 'MI' . $Index;

      # Find regions matching the master interface under inspection
      @MIRegions = grep /^$MasterIF:/, @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{$Class} };

      # Determine if this slave interface has connectivity with the master interface
      if ( grep $_ eq $MasterIF, @{ $InterfaceInfo{SLAVES}{$SlaveIF}{CONNECTIONS} } ) {

        ## Check for expected address regions
        #unless ( $Class eq 'REMAP' or @MIRegions > 0 ) {
        #  warn "Error: Interface $SlaveIF has no address regions defined for the $MasterIF interface!\n";
        #  $Errors++;
        #}

        # Inspect each region mapped to the master interface
        foreach $Region ( @MIRegions ) {

          # Split the region into its constituent parts
          ($MI, $Tag, $RegionLo, $RegionHi) = split(/:/, $Region);

          # Extract and remove the expected prefix, then check its type
          unless ( $Tag =~ /^($Tags{$Class})$/ ) {
            warn "Error: Interface $SlaveIF address region '$MI: $RegionLo-$RegionHi'" .
                 " declares\n unsupported $TagMessages{$Class}!\n";
            $Errors++;
          }

          # Check that each bound only consists of hexadecimal characters
          #  and is the expected number of hexadecimal digits
          foreach $CheckBound ( $RegionLo, $RegionHi ) {
            if ( length($CheckBound) != $HexChars ) {
              warn "Error: Interface $SlaveIF address bound '$MI: $CheckBound' is incorrect length should be $HexChars characters!\n";
              $Errors++;
            }
            if ( $CheckBound =~ /[^a-f0-9]+/i ) {
              warn "Error: Interface $SlaveIF address bound '$MI: $CheckBound' contains illegal characters!\n";
              $Errors++;
            }
          }

          # Check the region syntax
          if ( IsGtOrEq($RegionLo, $RegionHi) ) {
            warn "Error: Interface $SlaveIF address region '$MI: $RegionLo-$RegionHi' is invalid!\n";
            $Errors++;
          }

          # Check the region size - minimum is 1kBytes
          $RegionHiLSW = hex substr($RegionHi, length($RegionHi) - 8);
          $RegionLoLSW = hex substr($RegionLo, length($RegionLo) - 8);
          if ( abs( $RegionHiLSW - $RegionLoLSW ) < 1023 ) {
            warn "Error: Interface $SlaveIF address region '$MI: $RegionLo-$RegionHi' is < 1kBytes!\n";
            $Errors++;
          }

          # Check alignment of lower address bound
          if ( ( hex(substr($RegionLo, -3, 3)) & 0x3ff ) != 0x000 ) {
            warn "Error: Interface $SlaveIF address bound '$MI: $RegionLo' is misaligned!\n";
            $Errors++;
          }

          # Check alignment of upper address bound
          if ( ( hex(substr($RegionHi, -3, 3)) & 0x3ff ) != 0x3ff ) {
            warn "Error: Interface $SlaveIF address bound '$MI: $RegionHi' is misaligned!\n";
            $Errors++;
          }

          # Check the current region against all others for illegal overlap
          foreach $OtherRegion ( @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{$Class} } ) {

            # Split the other region into its constituent parts
            ($OtherMI, $OtherTag, $OtherLo, $OtherHi) = split(/:/, $OtherRegion);

            # Exclude remap regions with different remap bits
            if ( $Class eq 'REMAP' and $Tag ne $OtherTag ) { next; }

            # Filter out the current region and any previously reported ones
            unless ( $OtherRegion =~ /^($Region$Exclusions)$/ ) {

              # Check bounds for overlap
              if ( (IsGtOrEq($OtherLo, $RegionLo) and IsLtOrEq($OtherLo, $RegionHi)) or
                   (IsGtOrEq($OtherHi, $RegionLo) and IsLtOrEq($OtherHi, $RegionHi)) ) {

                warn "Error: Interface $SlaveIF $WarnType{$Class} region '$OtherMI: $OtherLo-$OtherHi'" .
                  " overlaps\n with another $WarnType{$Class} region '$MI: $RegionLo-$RegionHi'!\n";
                $Errors++;

                # Suppress multiple messages that show the same error
                $Exclusions = $Exclusions . "|$MI:[^:]+:$RegionLo:$RegionHi";
              }

            }
          }

        }

      } elsif ( @MIRegions > 0 ) {
        # This slave interface is not connected to the master interface and
        #  therefore should not have any address map information
        warn "Error: Interface $SlaveIF has an address map for $MasterIF interface,\n" .
             " while not connected!\n";
        $Errors++;
      }
    }

    # Clear the exclusions for checking the next class
    $Exclusions = '';

  }

}


# ------------------------------------------------------------------------------
#   ProcessXmlConfigFile - Reads the specified XML configuration file and
#                           assigns values to the global variables including
#                           the interface information hash
# ------------------------------------------------------------------------------
sub ProcessXmlConfigFile {

  # Local variable(s)
  my @Elements    = ();
  my $XmlItem     = '';
  my $XmlElement  = '';
  my @SlavePorts  = ();
  my @MasterPorts = ();
  my $Index1      = 1;
  my $Index2      = 0;
  my $SlaveIF     = '';
  my $MasterIF    = '';
  my $Name        = '';
  my $Region      = '';

  # Configure the XML parser
  ConfigureXmlParser( show_ids => 0, verbose => 0, show_warnings => 0 );

  # Read the specified configuration file
  RunXmlParser($XmlConfigFile);

  print "------------------------------XML structure loaded:------------------------------\n" if $Debug;
  ListXmlHash('ROOT') if $Debug;
  print "---------------------------------------------------------------------------------\n" if $Debug;

  # Access mandatory items of information (bus matrix dimensions)
  @SlavePorts = GetXmlNodeList('//cfgfile/slave_interface');
  $SlaveInterfaces = scalar @SlavePorts;
  @MasterPorts = GetXmlNodeList('//cfgfile/master_interface');
  $MasterInterfaces = scalar @MasterPorts;

  # Access optional items of information
  @Elements = GetXmlNodeList('/cfgfile');
  foreach $XmlElement ( @Elements ) {
    # Assign the extracted value to the appropriate parameter name
    $XmlItem = GetXmlValue("/cfgfile/$XmlElement");
    if ( $XmlElement =~ /arbitration_scheme\[1\]$/ ) {
      $ArbiterType = $XmlItem;
    } elsif ( $XmlElement =~ /architecture_version\[1\]$/ ) {
      $ArchitectureType = $XmlItem;
    } elsif ( $XmlElement =~ /remap_width\[1\]$/ ) {
      $RemapBitWidth = $XmlItem;
    } elsif ( $XmlElement =~ /master_width\[1\]$/ ) {
      $MasterBitWidth = $XmlItem;
    } elsif ( $XmlElement =~ /routing_data_width\[1\]$/ ) {
      $RoutingDataWidth = $XmlItem;
    } elsif ( $XmlElement =~ /routing_address_width\[1\]$/ ) {
      $RoutingAddressWidth = $XmlItem;
    } elsif ( $XmlElement =~ /user_signal_width\[1\]$/ ) {
      $UserSignalWidth = $XmlItem;
    } elsif ( $XmlElement =~ /timescales\[1\]$/ ) {
      $XmlTimescales = $XmlItem;
    } elsif ( $XmlElement =~ /bus_matrix_name\[1\]$/ ) {
      $BusMatrixName = $XmlItem;
    } elsif ( $XmlElement =~ /input_stage_name\[1\]$/ ) {
      $InputStageName = $XmlItem;
    } elsif ( $XmlElement =~ /matrix_decode_name\[1\]$/ ) {
      $MatrixDecodeName = $XmlItem;
    } elsif ( $XmlElement =~ /output_arbiter_name\[1\]$/ ) {
      $OutputArbName = $XmlItem;
    } elsif ( $XmlElement =~ /output_stage_name\[1\]$/ ) {
      $OutputStageName = $XmlItem;
    } elsif ( $XmlElement =~ /product_version_info\[1\]$/ ) {
      $ComponentName = GetXmlValue("/cfgfile/$XmlElement" . '@component_name');
    } elsif ( $XmlElement =~ /slave_type\[1\]$/ ) {
      $Slave_Type = lc($XmlItem);
    } elsif ( $XmlElement !~ /(slave|master)_interface\[\d+\]/ ) {
      warn "Error: Unknown XML option '$XmlElement'!\n";
      $Errors++;
    }
  }

  # Extract master interface parameter(s) first to simplify the sequence
  foreach $XmlElement ( @MasterPorts ) {

    # Initialise information container and increment the count
    $MasterIF = sprintf("MI%d", $Index2++);
    $Name = GetXmlValue($XmlElement . '@name');
    $InterfaceInfo{MASTERS}{$MasterIF}{NAME} = $Name;
    $InterfaceInfo{MASTERS}{$MasterIF}{CONNECTIONS} = [];

    # Add the name to the master alias lookup hash
    if ( ! exists( $NameAliases{$Name} ) ) {
      $NameAliases{$Name} = $MasterIF;
    } else {
      warn "Error: Interface $MasterIF name '$Name' is not unique!\n";
      $Errors++;
    }

  }

  # Extract slave interface parameter(s)
  foreach $XmlElement ( @SlavePorts ) {

    # Initialise information container
    $SlaveIF = sprintf("SI%d", $Index1 - 1);
    $Name = GetXmlValue($XmlElement . '@name');
    $InterfaceInfo{SLAVES}{$SlaveIF}{NAME} = $Name;
    $InterfaceInfo{SLAVES}{$SlaveIF}{SLAVE_TYPE} = GetXmlValue("//cfgfile/slave_interface[$Index1]/slave_type");
    $InterfaceInfo{SLAVES}{$SlaveIF}{CONNECTIONS} = [];
    $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{NORMAL} = [];
    $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{REMAP} = [];

    # Add the name to the slave alias lookup hash
    if ( ! exists( $NameAliases{$Name} ) ) {
      $NameAliases{$Name} = $SlaveIF;
    } else {
      warn "Error: Interface $SlaveIF name '$Name' is not unique!\n";
      $Errors++;
    }

    # Extract connectivity information or assign full connectivity as default
    @Elements = GetXmlNodeList("//cfgfile/slave_interface[$Index1]/sparse_connect");
    if ( @Elements > 0 ) {
      # Initialise or concatenate the connection description string
      $Connectivity = 'sparse';
      $Connections = $Connections . sprintf("%s%s -> ", ($Connections eq '') ?
        '' : "\n" . ' ' x 29, $InterfaceInfo{SLAVES}{$SlaveIF}{NAME});

      # Convert the symbolic interface names to the MI<n> notation
      foreach $XmlItem ( @Elements ) {
        # Extract sparse connection attribute and check for existence of the
        #  named interface
        $MasterIF = GetXmlValue($XmlItem . '@interface');
        if ( exists( $NameAliases{$MasterIF} ) ) {
          push @{ $InterfaceInfo{SLAVES}{$SlaveIF}{CONNECTIONS} }, $NameAliases{$MasterIF};
        } else {
          warn "Error: Interface '$Name' has an unresolved sparse connection '$MasterIF'!\n";
          $Errors++;
        }
        # Append this sparse connection detail
        $Connections = $Connections . "$MasterIF, ";
      }

    } else {
      # Full connectivity is default
      for ( $Index2 = 0; $Index2 < $MasterInterfaces; $Index2++ ) {
        push @{ $InterfaceInfo{SLAVES}{$SlaveIF}{CONNECTIONS} }, 'MI' . $Index2;
      }
    }

    # Extract address mapping information
    @Elements = GetXmlNodeList("//cfgfile/slave_interface[$Index1]/address_region");
    if ( @Elements > 0 ) {
      foreach $XmlItem ( @Elements ) {
        # Determine which master interface this address region is for, and
        #  check that it exists
        $MasterIF = GetXmlValue($XmlItem . '@interface');
        if ( exists( $NameAliases{$MasterIF} ) ) {
          $Region = sprintf("%s:%s:%s:%s", $NameAliases{$MasterIF},
                                           GetXmlValue($XmlItem . '@remapping') || 'none',   #obsolete
                                           GetXmlValue($XmlItem . '@mem_lo'),
                                           GetXmlValue($XmlItem . '@mem_hi'));
          # Check for duplicated definitions
          if ( grep $_ eq $Region, @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{NORMAL} } ) {
            warn "Error: Interface '$Name' has duplicated address region for master interface '$MasterIF'\n";
            $Errors++;
          } else {
            push @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{NORMAL} }, $Region;
          }

        } else {
          warn "Error: Address region maps to unknown master interface '$MasterIF'\n";
          $Errors++;
        }
      }
    } else {
      if (!GetXmlNodeList("//cfgfile/slave_interface[$Index1]/remap_region")) {
        warn "Error: No address or remap regions defined for interface '$SlaveIF'\n";
        $Errors++;
      }
    }

    # Extract the optional remapped address information
    @Elements = GetXmlNodeList("//cfgfile/slave_interface[$Index1]/remap_region");
    if ($RemapBitWidth == 0 && @Elements) {
      warn "Error: Remap regions defined, but the remap bus is not enabled. Please set a non-zero remap_bus_width.\n";
      $Errors++;
    } else {
    foreach $XmlItem ( @Elements ) {

        # Determine which master interface this remap region is for, and
        #  check that it exists
        $MasterIF = GetXmlValue($XmlItem . '@interface');
        if ( exists( $NameAliases{$MasterIF} ) ) {
          $Region = sprintf("%s:remap%s:%s:%s", $NameAliases{$MasterIF},
                                                GetXmlValue($XmlItem . '@bit'),
                                                GetXmlValue($XmlItem . '@mem_lo'),
                                                GetXmlValue($XmlItem . '@mem_hi'));
          if (GetXmlValue($XmlItem . '@bit') > $RemapBitWidth-1) {
            warn "A remap region tries to use bit ".GetXmlValue($XmlItem . '@bit')." but the remap bus is only ".$RemapBitWidth." wide. (remap [".($RemapBitWidth-1).":0])\n";
            $Errors++;
          }
          # Check for duplicated definitions
          if ( grep $_ eq $Region, @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{REMAP} } ) {
            warn "Error: Interface '$Name' has duplicated remap region for master interface '$MasterIF'\n";
            $Errors++;
          } else {
            push @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{REMAP} }, $Region;
          }

        } else {
          warn "Error: Remap region maps to unknown master interface '$MasterIF'\n";
          $Errors++;
        }
      }
    }

    # Increment index
    $Index1++;
  }

  my @address_regions = ();
  my $address_region;
  my $remap_region;
  my $AddrLo       = '';
  my $AddrHi       = '';
  my $Remapping    = '';
  my $r_MasterIF   = '';
  my $r_AddrLo     = '';
  my $r_AddrHi     = '';
  my $r_Remapping  = '';
  my $new_Remapping= '';
  my $split_done   = '';
  my $r_bit        = '';
  my $r2_bit       = '';
  my $Unmapping    = '';
  my $new_Unmapping= '';

  # Convert move to del
  foreach $SlaveIF (keys %{$InterfaceInfo{SLAVES}} ) {
    @address_regions = @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{NORMAL} };
    foreach $address_region (@address_regions) {
      ($MasterIF, $Remapping, $AddrLo, $AddrHi) = split(/:/, $address_region);
      $new_Remapping = $Remapping;
      if ($Remapping eq 'move') {
        foreach $remap_region (@{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{REMAP} }) {
          ($r_MasterIF, $r_Remapping, $r_AddrLo, $r_AddrHi) = split(/:/, $remap_region);
          $r_bit = substr($r_Remapping, 5);
          if ($r_MasterIF eq $MasterIF) {
            if (substr($new_Remapping,0,3) eq "del") {
              # Check if it's already in the _del_
              if ($new_Remapping =~ m/.*(del|_|,|\s)$r_bit(_|,|\s|$)/ ) {
                $new_Remapping = $new_Remapping;
              } else {
                $new_Remapping = $new_Remapping . "," . $r_bit;
              }
            } else {
              $new_Remapping = "del" . $r_bit;
            }
          }
        }
        if ( !($new_Remapping eq $Remapping) ) {
          $address_region = $MasterIF .":". $new_Remapping .":". $AddrLo .":". $AddrHi;
          print "Converted " . $MasterIF .":". $Remapping .":". $AddrLo .":". $AddrHi . " to " . $new_Remapping . "\n" if $Debug;
        }
      }
    }
    @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{NORMAL} } = @address_regions;
  }

  ############################ ADDRESS REGION ############################
  # Cut address_regions if remap_regions overlap
  foreach $SlaveIF (keys %{$InterfaceInfo{SLAVES}} ) {

     # Cut address_regions
     @address_regions = @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{NORMAL} };
     foreach $remap_region (@{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{REMAP} }) {
       ($r_MasterIF, $r_Remapping, $r_AddrLo, $r_AddrHi) = split(/:/, $remap_region);
       $r_bit = substr($r_Remapping, 5);
       foreach $address_region (@address_regions) {
         ($MasterIF, $Remapping, $AddrLo, $AddrHi) = split(/:/, $address_region);
         # Make new address region remapping type
         if (substr($Remapping,0,3) eq "del") {
           # Check if it's already in the _del_
           if ($Remapping =~ m/.*(del|_|,|\s)$r_bit(_|,|\s|$)/ ) {
             $new_Remapping = $Remapping;
           } else {
             $new_Remapping = $Remapping . "," . $r_bit;
           }
         } else {
           $new_Remapping = "del" . $r_bit;
         }
         # Split the address region that is covered by a remap region
         if ( IsLt( $AddrLo , $r_AddrLo) && IsLt( $r_AddrHi, $AddrHi) ) {
           $address_region = $MasterIF .":". $new_Remapping .":". $r_AddrLo .":". $r_AddrHi;
           push (@address_regions, $MasterIF .":". $Remapping .":". $AddrLo .":". HexSubstract($r_AddrLo,1));
           push (@address_regions, $MasterIF .":". $Remapping .":". HexAdd($r_AddrHi,1) .":". $AddrHi);

           if ($Debug) {
             print "Splitting for encapsulated  " . $MasterIF .":". $Remapping .":". $AddrLo .":". $AddrHi . "\n";
             print "  Into                      " . $MasterIF .":". $Remapping .":". $AddrLo .":". HexSubstract($r_AddrLo,1) . "\n";
             print "  Add                       " . $MasterIF .":". $new_Remapping .":". $r_AddrLo .":". $r_AddrHi . "\n";
             print "  And                       " . $MasterIF .":". $Remapping .":". HexAdd($r_AddrHi,1) .":". $AddrHi . "\n";
             if (substr($Remapping,0,3) eq "del") {
               print "^ (Double Del)\n";
             }
             print "---------------------------------------------------------------------\n";
           }
           redo;
         } elsif ( IsLt( $AddrLo , $r_AddrLo) && IsLt( $r_AddrLo , $AddrHi) ) {
           $address_region = $MasterIF .":". $Remapping .":". $AddrLo .":". HexSubstract($r_AddrLo,1);
           push (@address_regions, $MasterIF .":". $new_Remapping .":". $r_AddrLo .":". $AddrHi);

           if ($Debug) {
             print "Splitting low region        " . $MasterIF .":". $Remapping .":". $AddrLo .":". $AddrHi . "\n";
             print "  Into                      " . $MasterIF .":". $Remapping .":". $AddrLo .":". HexSubstract($r_AddrLo,1) . "\n";
             print "  And                       " . $MasterIF .":". $new_Remapping .":". $r_AddrLo .":". $AddrHi . "\n";
             if (substr($Remapping,0,3) eq "del") {
               print "^ (Double Del)\n";
             }
             print "---------------------------------------------------------------------\n";
           }
           redo;
         } elsif ( IsLt( $AddrLo , $r_AddrHi) && IsLt( $r_AddrHi , $AddrHi) ) {
           $address_region = $MasterIF .":". $new_Remapping .":". $AddrLo .":". $r_AddrHi;
           push (@address_regions, $MasterIF .":". $Remapping .":". HexAdd($r_AddrHi,1) .":". $AddrHi);
           if ($Debug) {
             print "Splitting high region       " . $MasterIF .":". $Remapping .":". $AddrLo .":". $AddrHi . "\n";
             print "  Into                      " . $MasterIF .":". $new_Remapping .":". $AddrLo .":". $r_AddrHi . "\n";
             print "  And                       " . $MasterIF .":". $Remapping .":". HexAdd($r_AddrHi,1) .":". $AddrHi . "\n";
             if (substr($Remapping,0,3) eq "del") {
               print "^ (Double Del)\n";
             }
             print "---------------------------------------------------------------------\n";
           }
           redo;
         } elsif ( IsGtOrEq( $AddrLo , $r_AddrLo) && IsGtOrEq( $r_AddrHi , $AddrHi) && !($new_Remapping eq $Remapping) ) {
           $address_region = $MasterIF .":". $new_Remapping .":". $AddrLo .":". $AddrHi;
           if ($Debug) {
             print "Changed region to deletable " . $MasterIF .":". $Remapping .":". $AddrLo .":". $AddrHi . "\n";
             print "  Into                      " . $MasterIF .":". $new_Remapping .":". $AddrLo .":". $AddrHi . "\n";
             if (substr($Remapping,0,3) eq "del") {
               print "^ (Double Del)\n";
             }
             print "---------------------------------------------------------------------\n";
           }

         }
       }
     }
     @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{NORMAL} } =
       sort {
              my @split_a = split /:/, $a;
              my @split_b = split /:/, $b;
              my $c;
              my $d;
              if ( IsLt($split_a[2],$split_b[2]) ) {
                $c = 1;
                $d = 2;
              } else {
                $c = 2;
                $d = 1;
              }
              $c <=> $d
#              (hex $split_a[2]) <=> (hex $split_b[2] )
            } @address_regions;

     ############################ REMAP ############################
     # Cut remap_regions
     @address_regions = @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{REMAP} };  # reusing address_region for remaps
     foreach $remap_region (@{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{REMAP} }) {
       ($r_MasterIF, $r_Remapping, $r_AddrLo, $r_AddrHi) = split(/:/, $remap_region);
       $r_bit = substr($r_Remapping, 5);
       foreach $address_region (@address_regions) {
         ($MasterIF, $Remapping, $AddrLo, $AddrHi, $Unmapping) = split(/:/, $address_region);
         $r2_bit = substr($Remapping, 5);

         if ($r_bit<$r2_bit) {

           # If there is already an Unmapping defined
           if ($Unmapping) {
             # Check if it's already in the _del_
             if ($Unmapping =~ m/.*(unmap|_|,|\s)$r_bit(_|,|\s|$)/ ) {
               $new_Unmapping = $Unmapping;
             } else {
               $new_Unmapping = $r_bit < $r2_bit ? $Unmapping . "," . $r_bit : $Unmapping;
             }
           } else {
             $new_Unmapping = "unmap " . $r_bit;
             $Unmapping = '';
           }
           # Lower remap bit has higher priority

           # Split the remap region that is covered by another remap region of higher priority
           if ( IsLt( $AddrLo , $r_AddrLo) && IsLt( $r_AddrHi, $AddrHi) ) {
             $address_region = $MasterIF .":". $Remapping .":". $r_AddrLo .":". $r_AddrHi.":".$new_Unmapping;
             push (@address_regions, $MasterIF .":". $Remapping .":". $AddrLo .":". HexSubstract($r_AddrLo,1).":".$Unmapping);
             push (@address_regions, $MasterIF .":". $Remapping .":". HexAdd($r_AddrHi,1) .":". $AddrHi.":".$Unmapping);
             if ($Debug) {
               print "Splitting remap for encapsulated   " . $MasterIF .":". $Remapping .":". $AddrLo .":". $AddrHi .":".$Unmapping. "\n";
               print "  Into                             " . $MasterIF .":". $Remapping .":". $AddrLo .":". HexSubstract($r_AddrLo,1) .":".$Unmapping. "\n";
               print "  Add                              " . $MasterIF .":". $Remapping .":". $r_AddrLo .":". $r_AddrHi . ":".$new_Unmapping . "\n";
               print "  And                              " . $MasterIF .":". $Remapping .":". HexAdd($r_AddrHi,1) .":". $AddrHi .":".$Unmapping. "\n";
               print "---------------------------------------------------------------------\n";
             }
             redo;
           } elsif ( IsLt( $AddrLo , $r_AddrLo) && IsLt( $r_AddrLo , $AddrHi) ) {
             $address_region = $MasterIF .":". $Remapping .":". $AddrLo .":". HexSubstract($r_AddrLo,1).":".$Unmapping;
             push (@address_regions, $MasterIF .":". $Remapping .":". $r_AddrLo .":". $AddrHi.":".$new_Unmapping);
             if ($Debug) {
               print "Splitting low remap region         " . $MasterIF .":". $Remapping .":". $AddrLo .":". $AddrHi .":".$Unmapping. "\n";
               print "  Into                             " . $MasterIF .":". $Remapping .":". $AddrLo .":". HexSubstract($r_AddrLo,1) .":".$Unmapping. "\n";
               print "  And                              " . $MasterIF .":". $Remapping .":". $r_AddrLo .":". $AddrHi .":".$new_Unmapping. "\n";
               print "---------------------------------------------------------------------\n";
             }
             redo;
           } elsif ( IsLt( $AddrLo , $r_AddrHi) && IsLt( $r_AddrHi , $AddrHi) ) {
             $address_region = $MasterIF .":". $Remapping .":". $AddrLo .":". $r_AddrHi.":".$new_Unmapping;
             push (@address_regions, $MasterIF .":". $Remapping .":". HexAdd($r_AddrHi,1) .":". $AddrHi.":".$Unmapping);
             if ($Debug) {
               print "Splitting high remap region        " . $MasterIF .":". $Remapping .":". $AddrLo .":". $AddrHi .":".$Unmapping. "\n";
               print "  Into                             " . $MasterIF .":". $Remapping .":". $AddrLo .":". $r_AddrHi .":".$new_Unmapping. "\n";
               print "  And                              " . $MasterIF .":". $Remapping .":". HexAdd($r_AddrHi,1) .":". $AddrHi .":".$Unmapping. "\n";
               print "---------------------------------------------------------------------\n";
             }
             redo;
           } elsif ( IsGtOrEq( $AddrLo , $r_AddrLo) && IsGtOrEq( $r_AddrHi , $AddrHi) && !($new_Unmapping eq $Unmapping) ) {
             $address_region = $MasterIF .":". $Remapping .":". $AddrLo .":". $AddrHi.":".$new_Unmapping;
             if ($Debug) {
               print "Changed remap region to unmappable " . $MasterIF .":". $Remapping .":". $AddrLo .":". $AddrHi .":".$Unmapping. "\n";
               print "  Into                             " . $MasterIF .":". $Remapping .":". $AddrLo .":". $AddrHi .":".$new_Unmapping. "\n";
               print "---------------------------------------------------------------------\n";
             }

           }
         }
       }
     }
     @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{REMAP} } =
       sort {
              my @split_a = split /:/, $a;
              my @split_b = split /:/, $b;
              my $c;
              my $d;
              if ( IsLt($split_a[2],$split_b[2]) ) {
                $c = 1;
                $d = 2;
              } else {
                $c = 2;
                $d = 1;
              }
              $c <=> $d
#              (hex $split_a[2]) <=> (hex $split_b[2] )
            } @address_regions;




    # Sort remap in order of priority
    @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{REMAP} } =
      sort {
             my @split_a = split /:/, $a;
             my @split_b = split /:/, $b;
             substr($split_a[1],5) <=> substr($split_b[1],5)
           } @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{REMAP} };

  }

  # Generate Remapstates
  my @bits;
  my @c_bits;
  my $remap_name;
  foreach $SlaveIF (keys %{$InterfaceInfo{SLAVES}} ) {
     @address_regions = @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{NORMAL} };
     push (@address_regions, @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{REMAP} });
     foreach $address_region (@address_regions) {
        $Unmapping = '';
        ($MasterIF, $Remapping, $AddrLo, $AddrHi,$Unmapping) = split(/:/, $address_region);
        @bits = GetRemapBits ($Remapping, $Unmapping);
        $remap_name = "remap_".join( '_' , @bits );
        # Change ! to n
        $remap_name =~ s/!/n/g ;

        # don't put in duplicates
        if ( @bits && !$RemapStates{$remap_name}) {
           @{ $RemapStates{$remap_name}} = @bits;
        }
     }
  }

  print "RemapStates:\n" if $Debug;
  print Dumper(\%RemapStates) if $Debug;

  # Generate AddressSpace regions
  foreach $SlaveIF (keys %{$InterfaceInfo{SLAVES}} ) {
     @address_regions = @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{NORMAL} };
     push (@address_regions, @{ $InterfaceInfo{SLAVES}{$SlaveIF}{ADDRESS_MAP}{REMAP} });
     foreach $address_region (@address_regions) {
        ($MasterIF, $Remapping, $AddrLo, $AddrHi) = split(/:/, $address_region);
        if ( !( grep {(@{$_}[0] eq $AddrLo) && (@{$_}[1] eq $AddrHi)} @{ $AddressSpace{$MasterIF} } ) ) {
           push @{ $AddressSpace{$MasterIF}}, [$AddrLo,$AddrHi];
        }
     }
  }

  # Sort the AddressSpace
  foreach $MasterIF (keys %AddressSpace) {
    @{ $AddressSpace{$MasterIF}} = sort {
              my $c;
              my $d;
              if ( IsLt(@{$a}[0],@{$b}[0]) ) {
                $c = 1;
                $d = 2;
              } else {
                $c = 2;
                $d = 1;
              }
              $c <=> $d
            } @{ $AddressSpace{$MasterIF}};
  }

  print "AddressSpace:\n" if $Debug;
  print Dumper(\%AddressSpace) if $Debug;

  # Remove leading whitespace from the connections detail
  $Connections =~ s/,\s+$//;

  # Determine connectivity information from master interface perspective
  for ( $Index1 = 0; $Index1 < $MasterInterfaces; $Index1++ ) {
    $MasterIF = 'MI' . $Index1;
    for ( $Index2 = 0; $Index2 < $SlaveInterfaces; $Index2++ ) {
      $SlaveIF = 'SI' . $Index2;
      if ( grep $_ eq $MasterIF, @{ $InterfaceInfo{SLAVES}{$SlaveIF}{CONNECTIONS} } ) {
        push @{ $InterfaceInfo{MASTERS}{$MasterIF}{CONNECTIONS} }, $SlaveIF;
      }
    }
  }

  print "InterfaceInfo:\n" if $Debug;
  print Dumper(\%InterfaceInfo) if $Debug;

}


# ------------------------------------------------------------------------------
#   ShowHelp - Displays help dialogue (developer's options are not advertised)
# ------------------------------------------------------------------------------
sub ShowHelp {

  print "Purpose:\n" .
        "   Builds particular configurations of the AHB5 BusMatrix component.\n\n" .
        "Usage:\n" .
        "   > bin/generate_busmatrix_$Product.pl -cfg ../config/sie200_ahb5_busmatrix/example2x3_sparse.xml -tgtdir ./built -ipxact -overwrite \n\n" .
        "Options:\n" .
        "   --cfg=FILENAME          Name of an XML configuration file that defines the bus matrix specification.\n\n".

        "   --overwrite             Overwrites existing bus matrix of the same name.\n" .
        "   --ipxact                Also generates IP-XACT file.\n\n" .

        "   --verbose               Prints more run information.\n" .
        "   --quiet                 Prints no information if rendering completed without problems.\n" .
        "   --help                  Prints this help.\n" .
        "   --srcdir=DIRNAME        Directory where source template files (verilog and ipxact directory) are located (defaults to ./ )\n" .
        "   --tgtdir=DIRNAME        Directory where the busmatrix should be generated in (defaults to ./built and must exist)\n".
        "   --xmldir=DIRNAME        Directory where the XML configuration files are located (defaults to ./xml)\n".
        "                            - you don't need to define this if you provide the full path to the --cfg switch\n".
        "   --libdir=DIRNAME        Directory where the xmlparser library is located\n" .
        "                            - needed if not calling the script from the default location (defaults to ./bin/lib)\n" .
        "   --(no)timescales        Adds or suppressed the '`timescale' directive in the rendered Verilog files.\n" .
        "                            Overrides the configuration in the XML, if present. No timescales is the default.\n" .
        "   --check                 Disables file generation and just checks the XML configuration file.\n\n";

  # Abort session with exit code = 0
  exit (0);
}

#!/usr/bin/env perl
#-----------------------------------------------------------------------------
#   The confidential and proprietary information contained in this file may
#   only be used by a person authorised under and to the extent permitted
#   by a subsisting licensing agreement from ARM Limited or its affiliates.
#
#          (C) COPYRIGHT 2015-2016 ARM Limited or its affiliates.
#              ALL RIGHTS RESERVED
#
#   This entire notice must be reproduced on all copies of this file
#   and copies of this file may only be made by a person if such person is
#   permitted to do so under the terms of a subsisting license agreement
#   from ARM Limited or its affiliates.
#
#     Checked In          : Fri Nov 25 15:35:47 2016 +0000
#     Revision            : 94095e2
#
#     Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
#-----------------------------------------------------------------------------
# README
#
#-----------------------------------------------------------------------------

use Getopt::Long;
use Data::Dumper;
use File::Basename;
use strict;
use warnings;
use Cwd;
#use File::Slurp qw/:edit/;
use File::Copy;


#--------------------------------------
# Usage
#--------------------------------------
my $usage = "

Usage:

multisim_update.pl -rgr <rgr_system>
 -help          : Print usage
 -xml           : top level busmatrix file name

Script must be run from trunk directory, just above regression dir
";


#--------------------------------------
# Parsing Command line arguments
#--------------------------------------
my $help;
my $parameter_xml;

if ( !GetOptions (
                    "h|help|?"        => \$help,
                    "xml=s"       => \$parameter_xml,
                  )
    or @ARGV ne 0
    or $help
   ) {
  print $usage;
  exit;
}

#--------------------------------------
# AHB Interface signals
#--------------------------------------

my @slave_if_signals = ( "hrdata", "hreadyout", "hresp", "hexokay", "hruser", "hsel", "haddr", "htrans", "hwrite", "hsize", "hburst", "hprot", "hmaster", "hwdata", "hmastlock", "hreadymux", "hnonsec", "hexcl", "hauser", "hwuser" );
my @master_if_signals = ( "hsel", "haddr", "htrans", "hwrite", "hsize", "hburst", "hprot", "hmaster", "hwdata", "hmastlock", "hready", "hnonsec", "hexcl", "hauser", "hwuser", "hrdata", "hreadyout", "hresp", "hexokay", "hruser" );
#--------------------------------------
# Directory paths
#--------------------------------------

my $file_in;
my $file_out;

my $module_name = $ENV{"MODULE_NAME"};
my $tgtdir = $ENV{"TGTDIR"};

my $test_path     = $tgtdir."/testbench/execution_tb/tests/generic_busmatrix_oob";
my $script_dir    = $tgtdir."/testbench/shared/tools/bin/busmatrix_oob_test";
my $templates_dir = $tgtdir."/testbench/shared/tools/bin/busmatrix_oob_test/templates";

#output
my $tbench_dir    = $tgtdir."/testbench/execution_tb/verilog/".$module_name;

#---------------------------------------------------
# Obtaining parameter values from configuration XML  |
#---------------------------------------------------

my $slave_num = 0;
my $master_num = 0;
my $addr_width = 32;
my $data_width = 32;
my $remap_width = 0;                  #default value - gets overwritten if defined
my $slave_type = "initiator";       #default value - gets overwritten if defined
my $user_sig_width = 0;                #default value - gets overwritten if defined
my $master_width = 4;                #default value - gets overwritten if defined
my $xml_opening = '^\s*<[a-z_]+>';
my $xml_closing = '<\/[a-z_]+>\R';
my @slave_names;
my @master_names;
my $test_name     = "generic_busmatrix_oob_test.sv";

my %master_index;
my %slave_index;
my %slave_type_index;

open $file_in, '<', "$parameter_xml" or die "Can't read input file: $!";

while ( my $line = <$file_in> )  {      # Goes through original file line by line

    if ($line =~ /<slave_interface name=['"]([0-9a-zA-Z_]+)['"]/) {
        $master_index{$1} = $master_num;
        $master_num ++;
        push @master_names, $1;

    }

    if ($line =~ /<master_interface name=['"]([0-9a-zA-Z_]+)['"]/) {
        $slave_index{$1} = $slave_num;
        $slave_num ++;
        push @slave_names, $1;
    }

    if ($line =~ /address_width>([0-9]+)</) {
        $addr_width = $1;
    }

    if ($line =~ /data_width>([0-9]+)</) {
        $data_width = $1;
    }

    if ($line =~ /user_signal_width>([0-9]+)</) {
        $user_sig_width = $1;
    }

    if ($line =~ /remap_width>([0-9]+)</) {
        $remap_width = $1;
    }

    if ($line =~ /slave_type>([a-zA-Z0-9_]+)</) {
        if ( !@master_names ) {
           $slave_type = $1;  # global
        } else {
           $slave_type_index{$master_names[-1]} = $1;  # individual setting
        }

    }

    if ($line =~ /master_width>([0-9]+)</) {
        $master_width = $1;
    }



} # while ( my $line = <$file_in> )

close $file_in or die "can't close file: $!";


#------------------------------------
# Create test directory, and contents |
#------------------------------------

copy("$templates_dir/ggve_makefile", "$tbench_dir/ggve_makefile");
copy("$parameter_xml", "$tbench_dir/dut_config.cfg");
copy("$templates_dir/test_template.sv","$test_path/$test_name");


#----------------------------------------------------
# Creating parameter file with configured parameters |
#----------------------------------------------------


#if (-f "$tbench_dir/ggve_defines.sv") {
#    die "ERROR: Remove failed, $!\n" if ( system "rm -f $tbench_dir/ggve_defines.sv" );
#}

system "mkdir -p $tbench_dir";

open $file_in,  '<', "$templates_dir/defines_template.sv" or die "Can't read input file: $!";
open $file_out, '>', "$tbench_dir/ggve_defines.sv" or die "Can't read input file: $!";

while ( my $line = <$file_in> )  {      # Goes through original file line by line

    if ($line =~ /<master_num>/) {
        $line =~ s/<master_num>/$master_num/;
    }
    elsif ($line =~ /<slave_num>/) {
        $line =~ s/<slave_num>/$slave_num/;
    }
    elsif ($line =~ /<address_width>/) {
        $line =~ s/<address_width>/$addr_width/;
    }
    elsif ($line =~ /<data_width>/) {
        $line =~ s/<data_width>/$data_width/;
    }
    elsif ($line =~ /<module_name>/) {
        $line =~ s/<module_name>/$module_name/;
    }
    elsif ($line =~ /<remap_width>/) {
        $line =~ s/<remap_width>/$remap_width/;
    }
    elsif ($line =~ /<user_width>/) {
        $line =~ s/<user_width>/$user_sig_width/;
    }
    elsif ($line =~ /<master_width>/) {
        $line =~ s/<master_width>/$master_width/;
    }

    print $file_out $line;

} # while ( my $line = <$file_in> )

close $file_in or die "cannot close file: $!";
close $file_out or die "cannot close file: $!";

#------------------------------------------------------------------------
# Obtaining important data from top level RTL file (ports, module name) |
#------------------------------------------------------------------------
# Editing tbench.vc filelist template to contain all generated busmatrix file paths



if (-e "$tbench_dir/tbench.vc") {
    die "ERROR: Remove failed, $!\n" if ( system "rm -f $tbench_dir/tbench.vc" );
}

open $file_in, '<', "$templates_dir/tbench_template.vc" or die "Cannot read input file: $!";
open $file_out,'>', "$tbench_dir/tbench.vc" or die "Cannot write output file: $!";
my $string_out ="";

while ( my $line = <$file_in> )  {

    while ($line =~ /<module_name>/) {
        $line =~ s/<module_name>/$module_name/;
    }


    print $file_out $line;


}

close $file_in or die "cannot close file: $!";
close $file_out or die "cannot close file: $!";

#-------------------------------------------------
# Instantiating generated busmatrix in testbench |
#-------------------------------------------------

if (-e "$tbench_dir/tb_sie200_ahb5_busmatrix.sv") {
    die "ERROR: Remove failed, $!\n" if ( system "rm -f $tbench_dir/tb_sie200_ahb5_busmatrix.sv" );
}

# Opening template testbench file for editing
open $file_in, '<', "$templates_dir/tb_template.sv" or die "Can't read input file: $!";
open $file_out,'>', "$tbench_dir/tb_sie200_ahb5_busmatrix.sv" or die "Can't write output file: $!";

my $dut_inst_start = 0;
my $uc_dut_port;
my $prev_if_name = "01234";
my $orig_if_num;
my $if_name;

sub is_slave {
    my $internal = 0;
    foreach my $element (@slave_names) {
       if ($element eq $_[0]) {
            $internal = 1 ;
       }
    }
    return $internal;
}

sub is_master {
    my $internal = 0;
    foreach my $element (@master_names) {
       if ($element eq $_[0]) {
            $internal = 1 ;
       }
    }
    return $internal;
}

while ( my $line = <$file_in> )  {

    if ($line =~ /<module_name>/) {
        $line =~ s/<module_name>/$module_name/g;
    }

    if ($dut_inst_start) {

        print $file_out $line;



        print $file_out "   $module_name busmatrix (\n";
        print $file_out "      .hclk     (ggve_clk),\n";
        print $file_out "      .hresetn   (ggve_resetn),\n";

        my $string_with_comma ="";
        my $string_without_comma ="";


        my $if_signal = "";
        my $dut_signal = "";

        foreach my $if_name (@master_names){
            foreach my $signal_element (@master_if_signals){
                my $write_out_signal = 1;

                $if_signal  = uc $signal_element;
                $dut_signal =    $signal_element;

                if ( $user_sig_width == 0 ){
                    if ($signal_element eq "hauser"){
                        $write_out_signal = 0;
                    }
                    if ($signal_element eq "hwuser"){
                        $write_out_signal = 0;
                    }
                    if ($signal_element eq "hruser"){
                        $write_out_signal = 0;
                    }
                }
                if ( ( !(exists $slave_type_index{$if_name}) && ($slave_type eq "initiator")) ||
                     (  (exists $slave_type_index{$if_name}) && $slave_type_index{$if_name} eq "initiator") ) {
                    if ($signal_element eq "hsel"){
                        $write_out_signal = 0;
                    }
                    if ($signal_element eq "hreadyout"){
                        $write_out_signal = 0;
                    }
                }
                else{
                    if ($signal_element eq "hsel"){
                        $if_signal = "HSELX";
                    }

                }

                if (($signal_element eq "haddr") && ($addr_width<64)){
                        $if_signal = "HADDR[$addr_width-1:0]";
                }

                if($write_out_signal) {
                    $string_without_comma = $string_with_comma."\n      .".$dut_signal."_".$if_name."     (ahb5_mstr_rtl_if[$master_index{$if_name}].$if_signal)";
                    $string_with_comma    = $string_with_comma."\n      .".$dut_signal."_".$if_name."     (ahb5_mstr_rtl_if[$master_index{$if_name}].$if_signal),";

                }
            }
            $string_with_comma .= "\n";
            $string_without_comma .= "\n";

        }
            $string_with_comma .= "\n\n";
            $string_without_comma .= "\n\n";
        foreach my $if_name (@slave_names){
            foreach my $signal_element (@slave_if_signals){
                my $write_out_signal = 1;

                $if_signal  =uc $signal_element;
                $dut_signal =   $signal_element;


                if ( $user_sig_width == 0 ){
                    if ($signal_element eq "hauser"){
                        $write_out_signal = 0;
                    }
                    if ($signal_element eq "hwuser"){
                        $write_out_signal = 0;
                    }
                    if ($signal_element eq "hruser"){
                        $write_out_signal = 0;
                    }
                }

                if ($signal_element eq "hreadymux"){
                    $if_signal = "HREADY";
                }
                if ($signal_element eq "hsel"){
                        $if_signal = "HSELX";
                }
                if (($signal_element eq "haddr") && ($addr_width<64)){
                        $if_signal = "HADDR[$addr_width-1:0]";
                }


                if($write_out_signal) {
                    $string_without_comma = $string_with_comma."\n      .".$dut_signal."_".$if_name."     (ahb5_slv_rtl_if[$slave_index{$if_name}].$if_signal)";
                    $string_with_comma    = $string_with_comma."\n      .".$dut_signal."_".$if_name."     (ahb5_slv_rtl_if[$slave_index{$if_name}].$if_signal),";
                }
            }

            $string_with_comma .= "\n";
            $string_without_comma .= "\n";

        }

        if ($remap_width) {
            $string_without_comma = $string_with_comma."\n\n      .remap(remap_if.REMAP)  \n";

        }
        print $file_out $string_without_comma;

        print $file_out "\n   );\n";
        print $file_out "\n";
        $dut_inst_start = 0;
        for (my $master_idx = 0; $master_idx < $master_num; $master_idx++) {
            if ( ( !(exists $slave_type_index{$master_names[$master_idx]}) && ($slave_type eq "target")) ||
                 (  (exists $slave_type_index{$master_names[$master_idx]}) && $slave_type_index{$master_names[$master_idx]} eq "target") ) {
                print $file_out "      assign ahb5_mstr_rtl_if[$master_idx].HREADY  = ahb5_mstr_rtl_if[$master_idx].HREADYOUT;\n";
            }
        }

      if ($addr_width<64){
      print $file_out "\n";
      for (my $master_idx = 0; $master_idx < $master_num; $master_idx++) {
         print $file_out "      assign ahb5_mstr_rtl_if[$master_idx].HADDR[63:$addr_width] = 0;\n";
       }

       for (my $slave_idx = 0; $slave_idx < $slave_num; $slave_idx++) {
        print $file_out "      assign ahb5_slv_rtl_if[$slave_idx].HADDR[63:$addr_width] = 0;\n";
       }
      }

    }
    else {
        print $file_out $line;
    }

    if ($line =~ /END_OF_DUT_INST/) {
        $dut_inst_start = 0
    }

    if ($line =~ /START_OF_DUT_INST/) {
        $dut_inst_start = 1
    }
}

close $file_in or die "cannot close file: $!";
close $file_out or die "cannot close file: $!";



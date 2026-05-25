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
#     Checked In          : Sun Sep 25 00:16:27 2016 +0100
#     Revision            : 6e8b83e
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
my $xml;
my $compile;
my $simulation;
my $module_name="$ENV{MODULE_NAME}";
my $simulator="mti";
if ( !GetOptions (
                    "h|help|?"        => \$help,
                    "compile"   => \$compile,
                    "simulation"   => \$simulation,
                    "simulator=s" => \$simulator,

                  )
    or @ARGV ne 0
    or $help
   ) {
  print $usage;
  exit;
}





my $message_exceptions_dir = "$ENV{SIE200_BUSMATRIX_OOB_TB_SCRIPTS_PATH}/err_exceptions";

my $log_path = "$ENV{SIE200_BUSMATRIX_OOB_LOG_FILES_PATH}";
#my $sim_log_path = "$test_dir/generic_busmatrix_oob/uvm.$module_name";
my $sim_log = "$log_path/sim_$simulator.log";
#my $compile_log_path = "$tb_dir/luna-log";
my $compile_log = "$log_path/compile_$simulator.log";




# Build black/white lists
my $error_wl_file = "$message_exceptions_dir/error_wl.txt";
my $error_bl_file = "$message_exceptions_dir/error_bl.txt";
my $warning_bl_file = "$message_exceptions_dir/warning_bl.txt";
my $warning_wl_file = "$message_exceptions_dir/warning_wl.txt";
my @error_wl;
my @error_bl;
my @warning_wl;
my @warning_bl;

sub read_exception_file {
    my $filename = shift;
    my $exception_array = shift;

    open my $file_in, '<', $filename or die ("Cannot open file: $filename\n");
    while ( my $line = <$file_in> ) {
        if ( $line !~ /^\s*#/ and $line !~ /^\s*$/) {   # If not a comment or empty line
            push @$exception_array, $line;
        }
    }
    close $file_in;
}

read_exception_file($error_wl_file, \@error_wl);
read_exception_file($error_bl_file, \@error_bl);
read_exception_file($warning_wl_file, \@warning_wl);
read_exception_file($warning_bl_file, \@warning_bl);

my %error_lists;


sub match_line_with_exceptions{
    my $file_in;
    my $is_exception=0;

    if ($_[0] eq "error_wl"){
        foreach my $line (@error_wl) {
            if ( $_[1] =~ /$line/ ) {
                $is_exception = 1;
                last;
            }
        }
    }
    if ($_[0] eq "error_bl"){
        foreach my $line (@error_bl) {
            if ( $_[1] =~ /$line/ ) {
                $is_exception = 1;
                last;
            }
        }
    }
    if ($_[0] eq "warning_wl"){
        foreach my $line (@warning_wl) {
            if ( $_[1] =~ /$line/ ) {
                $is_exception = 1;
                last;
            }
        }
    }
    if ($_[0] eq "warning_bl"){
        foreach my $line (@warning_bl) {
            if ( $_[1] =~ /$line/ ) {
                $is_exception = 1;
                last;
            }
        }
    }

    return $is_exception;

}



my $error_pattern = 'error|fatal|[Cc]ommand not found';
my $warning_pattern = 'warning';


# Add pattern for these kind of errors:  irun: *E,NOSTUP: A problem was detected in the setup for simulation.
if ( $simulator eq "nc" ) {
    $error_pattern .= '|\*E,[A-Z]*\:';
    $warning_pattern .= '|\*W,[A-Z]*\:';
}

sub do_check{
    my $log_file = $_[0];
    my $file_in;
    my @context=("","");
    my $error_counter=0;
    my $context_counter=0;
    my @errors=();

    print "\n Checking for errors: $_[0]\n\n";
    open $file_in, '<', $log_file or die "Can't read input file: $!\nfile should be at : $log_file\n";

    while ( my $line = <$file_in> )  {      # Goes through original file line by line
        if ($line =~ /$error_pattern/i){
            if(not match_line_with_exceptions("error_wl",$line)){
                if ($context_counter == 0){
                    $errors[$error_counter] .= "$context[0]\n$context[1]\n";
                }

                $context_counter=2;
            }
            else{
                #Maybe doing some statistics
            }
        }
        elsif ($line =~ /$warning_pattern/i){
            if(match_line_with_exceptions("warning_bl",$line)){
                if ($context_counter == 0){
                    $errors[$error_counter] .= "$context[0]\n$context[1]\n";
                }
                $context_counter=2;
            }
            elsif(not match_line_with_exceptions("warning_wl",$line)){
                print "Not whitelisted nor blacklisted warning found: \n$line\n"
            }
        }


        if ($context_counter != 0){
            $errors[$error_counter] .= "$line\n";
            $context_counter -= 1;
            if ($context_counter == 0) {
                $error_counter += 1;
            }
        }

        shift @context;
        push @context, $line;

    }
    if ($context_counter != 0){
        $error_counter += 1;
    }



    close $file_in or die "can't close file: $!";


    if ($error_counter == 0){
        return undef;

    }
    else {
        return @errors;

    }

}



if ($compile){
    my @compile_error_list= undef;
    @compile_error_list = do_check($compile_log);
    if (@compile_error_list){
        $error_lists{"compile"} = \@compile_error_list;
    }
}

if ($simulation){
    my @sim_error_list=undef;
    @sim_error_list=do_check($sim_log);
    if (@sim_error_list){
        $error_lists{"simulation"} = \@sim_error_list;
    }
}

my $has_error=0;
foreach my $stage ( keys %error_lists) {
    my $stage_has_error=0;
    print "The following ERRORs and warnings found during ".uc $stage." STAGE: \n";
    foreach my $err_item (@{$error_lists{$stage}}){
        if (defined $err_item){
            $has_error=1;
            $stage_has_error=1;
            print "\n############ ERROR ITEM ############\n";
            print $err_item;
        }
    }
    if (not $stage_has_error){
        print "-No error or warning found!\n"
    }
}


if ($has_error){

    die "Log file contains not whitelisted errors!\n"
}


1;

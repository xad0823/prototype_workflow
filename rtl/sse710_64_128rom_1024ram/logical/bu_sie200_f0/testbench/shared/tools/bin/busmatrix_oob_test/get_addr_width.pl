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
#     Checked In          : Mon Sep 12 15:21:46 2016 +0100
#     Revision            : 3ed9556
#
#     Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
#-----------------------------------------------------------------------------
# README
#
#-----------------------------------------------------------------------------

use Getopt::Long;
use File::Basename;
use strict;
use warnings;
#use File::Slurp qw/:edit/;
use File::Copy;




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
  exit;
}


my $file_in;
my $file_out;

my $addr_width = "32";

my $xml_opening = '^\s*<[a-z_]+>';
my $xml_closing = '<\/[a-z_]+>\R';

open $file_in, '<', "$parameter_xml" or die("\nCan't read input file: $parameter_xml : $!\n");

while ( my $line = <$file_in> )  {      # Goes through original file line by line


  if ($line =~ /address_width>([0-9]+)</) {
        $addr_width = $1;
    }
}




close $file_in or die("\nCan't close input file: $parameter_xml : $!\n");


print $addr_width;


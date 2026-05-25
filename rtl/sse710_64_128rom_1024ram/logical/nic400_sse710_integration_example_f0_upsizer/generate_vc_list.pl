#!/usr/bin/env perl

=head1 COPYRIGHT

 The confidential and proprietary information contained in this file may
 only be used by a person authorised under and to the extent permitted
 by a subsisting licensing agreement from Arm Limited or its affiliates.

               (C) COPYRIGHT 2015-2017 Arm Limited or its affiliates.
                   ALL RIGHTS RESERVED

 This entire notice must be reproduced on all copies of this file
 and copies of this file may only be made by a person if such person is
 permitted to do so under the terms of a subsisting license agreement
 from Arm Limited or its affiliates.



 Release Information : SSE710-r0p0-00eac0

=head1 NAME

 extract_ipxact - Get IPXACT from verilog file.

=cut 

# ------------------------------------------------------------------------------
# Process verilog file
# ------------------------------------------------------------------------------

use strict;
use warnings;
use YAML;
use File::Slurp;

my $yaml =  Load scalar read_file("$ARGV[0]");

sub get_vc_list {
        my @ret;
        foreach(@{$yaml->{$_[0]}{package_dependency}}){
                push @ret, @{get_vc_list($_)};
                push @ret, "\$LOGICAL_PATH/$_/package.vc";
        }

        return \@ret;
}

my %hash = map { $_ => 1} @{get_vc_list($ARGV[1])};

print join "\n", sort keys %hash;
print "\n";

# ------------------------------------------------------------------------------
# End of file
# ------------------------------------------------------------------------------

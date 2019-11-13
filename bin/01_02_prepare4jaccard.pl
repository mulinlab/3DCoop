#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use FindBin;
use lib "$FindBin::Bin/../lib";
use TDCoop;

my $fi_cfg = $ARGV[0];
my %conf   = parse_configure($fi_cfg);
my $mode   = $conf{mode};

my $dib = "$FindBin::Bin/../scripts";

if ( $mode =~ /1D/i ) {
    system "perl $dib/1D_01_intersect_bin_peaks.pl $fi_cfg";
}
elsif ( $mode =~ /3D/i ) {
    system "perl $dib/01_intersect_interactions_peaks.pl $fi_cfg";
    system "perl $dib/02_class_intersections.pl $fi_cfg";
}
else {
    print STDERR
"Please set the 'mode' to '1D' or '3D' in the configure file ($fi_cfg)!\n";
    exit;
}

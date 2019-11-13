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
    system "perl $dib/1D_03_jaccard_in_parallel.pl $fi_cfg";
}
elsif ( $mode =~ /3D/i ) {
    system "perl $dib/03_jaccard_in_parallel.pl $fi_cfg";
}
else {
    print STDERR
"Please set the 'mode' to '1D' or '3D' in the configure file ($fi_cfg)!\n";
    exit;
}

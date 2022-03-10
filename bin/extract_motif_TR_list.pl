#!/usr/bin/perl

use warnings;
use strict;
use utf8;

if ( @ARGV < 2 ) {
    print STDERR "$ARGV[0] should be the path to the motif file!\n";
    print STDERR "$ARGV[1] should be the path to the output file!\n";
    exit;
}

my $fi = $ARGV[0];
my $fo = $ARGV[1];

open my $I, '<', $fi or die "$0 : failed to open input file '$fi' : $!\n";
open my $O, '>', $fo or die "$0 : failed to open output file '$fo' : $!\n";
select $O;
print "motif\tTR\n";
while (<$I>) {
    if (/^>/) {
        s/>//;
        s/ /\t/;
        print;
    }
}
close $I or warn "$0 : failed to close input file '$fi' : $!\n";
close $O or warn "$0 : failed to close output file '$fo' : $!\n";


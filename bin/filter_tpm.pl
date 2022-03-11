#!/usr/bin/perl

use warnings;
use strict;
use utf8;

if ( @ARGV < 3 ) {
    print STDERR "$ARGV[0] should be the TPM cutoff!\n";
    print STDERR "$ARGV[1] should be the path to the input TPM expression!\n";
    print STDERR "$ARGV[2] should be the path to the output TPM expression!\n";
    exit;
}

my $cutoff = $ARGV[0];
my $fi     = $ARGV[1];
my $fo     = $ARGV[2];

open my $I, '<', $fi or die "$0 : failed to open input file '$fi' : $!\n";
open my $O, '>', $fo or die "$0 : failed to open output file '$fo' : $!\n";
select $O;
while (<$I>) {
    if (/^gene/) {
        print;
    }
    else {
        chomp;
        my @f = split /\t/;
        if ( $f[-1] >= $cutoff ) {
            print join "\t", @f;
            print "\n";
        }
    }
}
close $I or warn "$0 : failed to close input file '$fi' : $!\n";
close $O or warn "$0 : failed to close output file '$fo' : $!\n";

#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use File::Basename;

if ( @ARGV < 2 ) {
    print STDERR "$ARGV[0] should be the weight file (Jaccard/Glasso)!\n";
    print STDERR "\@ARGV[1..N] should be TF names (no matter case)!\n";
    exit;
}

my $fi  = shift @ARGV;
my @tfs = @ARGV;

for ( my $i = 0 ; $i < $#tfs ; $i++ ) {
    for ( my $j = $i + 1 ; $j <= $#tfs ; $j++ ) {
        my $tfa = uc( $tfs[$i] );
        my $tfb = uc( $tfs[$j] );
        if ( basename($fi) =~ /jaccard/ ) {
            system "grep -w $tfa $fi | grep -w $tfb | cut -f1,2,5";
        }
        else {
            system "grep -w $tfa $fi | grep -w $tfb";
        }
    }
}

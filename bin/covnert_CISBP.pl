#!/usr/bin/perl

use warnings;
use strict;
use utf8;

if ( @ARGV < 2 ) {
    print STDERR
      "$ARGV[0] should be the path to the downloaded CISBP database!\n";
    print STDERR "$ARGV[1] should be the path to the output file!\n";
    exit;
}

my $din = $ARGV[0];
my $fo  = $ARGV[1];

my %motif2tf;
my $fi_info = "$din/TF_Information.txt";
open my $II, '<', $fi_info
  or die "$0 : failed to open input file '$fi_info' : $!\n";
while (<$II>) {
    unless (/^TF_ID/) {
        chomp;
        my @f     = split /\t/;
        my $motif = $f[3];
        my $tf    = $f[6];
        $tf =~ s/_\w+$//;
        if ( $tf !~ /-/ ) {
            $motif2tf{$motif} = $tf;
        }
    }
}
close $II or warn "$0 : failed to close input file '$fi_info' : $!\n";

open my $O, '>', $fo or die "$0 : failed to open output file '$fo' : $!\n";
select $O;
foreach my $motif ( sort keys %motif2tf ) {
    my $fi = "$din/pwms_all_motifs/${motif}.txt";
    if ( -f $fi ) {
        open my $I, '<', $fi
          or die "$0 : failed to open input file '$fi' : $!\n";
        my ( @baseA, @baseC, @baseG, @baseT );
        while (<$I>) {
            unless (/^Pos/) {
                chomp;
                my @f = split /\t/;
                push @baseA, $f[1];
                push @baseC, $f[2];
                push @baseG, $f[3];
                push @baseT, $f[4];
            }
        }
        close $I or warn "$0 : failed to close input file '$fi' : $!\n";

        if ( @baseA > 2 ) {
            my $motif_id = $motif;
            $motif_id =~ s/_.+?$//;
            print ">$motif_id $motif2tf{$motif}\n";
            print "A  [ " . ( join " ", @baseA ) . " ]\n";
            print "C  [ " . ( join " ", @baseC ) . " ]\n";
            print "G  [ " . ( join " ", @baseG ) . " ]\n";
            print "T  [ " . ( join " ", @baseT ) . " ]\n";
        }
    }
}
close $O or warn "$0 : failed to close output file '$fo' : $!\n";

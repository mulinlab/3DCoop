#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use File::Basename;

if ( @ARGV < 1 ) {
    print STDERR
"$ARGV[0] should be the directory containing BEDPE file(s) with 'bedpe' suffix!\n";
    exit;
}

my $ver = `bedtools --version`;
unless ( $ver =~ /^bedtools/ ) {
    print STDERR "bedtools must be installed!\n";
    exit;
}

my $dio = shift @ARGV;

my @pes = glob "$dio/*.bedpe";
foreach my $pe (@pes) {
    my $bed = $pe;
    $bed =~ s/pe$//;

    my $tmp = $pe;
    $tmp =~ s/bedpe$/tmp/;

    system "cut -f1-3 $pe | sort | uniq > $tmp";
    system "cut -f4-6 $pe | sort | uniq >> $tmp";
    system "bedtools sort -i $tmp | uniq > $bed";
    unlink($tmp);
}

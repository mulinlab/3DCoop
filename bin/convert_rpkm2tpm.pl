#!/usr/bin/perl

use warnings;
use strict;
use utf8;

if ( @ARGV < 2 ) {
    print STDERR
      "$ARGV[0] should be the path to the input RPKM/FPKM expression!\n";
    print STDERR "$ARGV[1] should be the path to the output TPM expression!\n";
    exit;
}

my $fi = $ARGV[0];
my $fo = $ARGV[1];

open my $I, '<', $fi or die "$0 : failed to open input file '$fi' : $!\n";
my @lines = <$I>;
close $I or warn "$0 : failed to close input file '$fi' : $!\n";

my $total = cal_total_expression(@lines);

open my $O, '>', $fo or die "$0 : failed to open output file '$fo' : $!\n";
select $O;
print "geneID\ttpm\n";
foreach my $line (@lines) {
    unless ( $line =~ /^gene/ ) {
        chomp($line);
        my @f   = split /\t/, $line;
        my $tpm = sprintf( "%.3f", $f[-1] / $total * 10**6 );
        print join "\t", $f[0], $tpm;
        print "\n";
    }
}
close $O or warn "$0 : failed to close output file '$fo' : $!\n";

sub cal_total_expression {
    my @lines = @_;
    my $total;
    foreach my $line (@lines) {
        unless ( $line =~ /^gene/ ) {
            chomp($line);
            my @f = split /\t/, $line;
            $total += $f[-1];
        }
    }
    return ($total);
}

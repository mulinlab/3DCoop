#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use File::Basename;
use FindBin;
use lib "$FindBin::Bin/../lib";
use TDCoop;

my $fi_cfg = $ARGV[0];
my %conf   = parse_configure($fi_cfg);

my $dout     = $conf{dir_out};
my @cells    = sort @{ $conf{cells} };
my $num_cell = @cells;

my $din_jaccard = "$dout/03_jaccard";
my $din_glasso  = "$dout/04_glasso";
my $din_co      = "$dout/05_clusterone";
my $din_clique  = "$din_co/05_max_cliques";
my $dout_pair   = "$din_co/06_pairs";
mkdir $dout_pair unless -d $dout_pair;

foreach my $cell (@cells) {
    my %jaccard;
    my $fij = "$din_jaccard/jaccard_${cell}.txt";
    open my $IJ, '<', $fij
      or die "$0 : failed to open input file '$fij' : $!\n";
    while (<$IJ>) {
        unless (/^TF1/) {
            chomp;
            my @f = split /\t/;
            my $tfp = join "\t", sort @f[ 0, 1 ];
            $jaccard{$tfp} = $f[4];
        }
    }
    close $IJ or warn "$0 : failed to close input file '$fij' : $!\n";

    my %glasso;
    my $fig = "$din_glasso/glasso_${cell}.txt";
    open my $IG, '<', $fig
      or die "$0 : failed to open input file '$fig' : $!\n";
    while (<$IG>) {
        chomp;
        unless (/#/) {
            chomp;
            my @f = split /\t/;
            my $tfp = join "\t", sort @f[ 0, 1 ];
            $glasso{$tfp} = $f[2];
        }
    }
    close $IG or warn "$0 : failed to close input file '$fig' : $!\n";

    my %pairs;
    my $fi = "$din_clique/${cell}_max_cliques.txt";
    open my $IC, '<', $fi or die "$0 : failed to open input file '$fi' : $!\n";
    while (<$IC>) {
        unless (/^clique/) {
            chomp;
            my @f = split /\t/;
            my @tfs = split /-/, $f[0];
            for ( my $i = 0 ; $i < @tfs - 1 ; $i++ ) {
                for ( my $j = $i + 1 ; $j < @tfs ; $j++ ) {
                    my $tfp = join "\t", sort ( $tfs[$i], $tfs[$j] );
                    $pairs{$tfp} = 1;
                }
            }
        }
    }
    close $IC or warn "$0 : failed to close input file '$fi' : $!\n";

    my $fop = "$dout_pair/${cell}_pairs.txt";
    open my $OP, '>', $fop
      or die "$0 : failed to open output file '$fop' : $!\n";
    select $OP;
    print "TF1\tTF2\tjaccard\tglasso\n";
    foreach my $tfp ( sort keys %pairs ) {
        print "$tfp\t$jaccard{$tfp}\t$glasso{$tfp}\n";
    }
    close $OP or warn "$0 : failed to close output file '$fop' : $!\n";
}

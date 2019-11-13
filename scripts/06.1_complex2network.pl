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

my $din_glasso   = "$dout/04_glasso";
my $din_co       = "$dout/05_clusterone";
my $din_result   = "$din_co/08_results";
my $dout_network = "$dout/06_network";
mkdir $dout_network unless -d $dout_network;

foreach my $cell (@cells) {
    my %glasso;
    my $fig = "$din_glasso/glasso_${cell}.txt";
    open my $IG, '<', $fig
      or die "$0 : failed to open input file '$fig' : $!\n";
    while (<$IG>) {
        unless (/^#/) {
            chomp;
            my @f = split /\t/;
            my $tfp = join "\t", sort @f[ 0, 1 ];
            $glasso{$tfp} = $f[2];
        }
    }
    close $IG or warn "$0 : failed to close input file '$fig' : $!\n";

    my %link;
    my %node;
    my %complex;
    my $fic = "$din_result/${cell}_clusters_list.txt";
    open my $IC, '<', $fic
      or die "$0 : failed to open input file '$fic' : $!\n";
    my $cid = 0;
    while (<$IC>) {
        $cid++;
        chomp;
        my @tfs = split /\t/;
        foreach my $tf (@tfs) {
            $node{$tf} += 1;
            $complex{$tf} = $cid;
        }
        for ( my $i = 0 ; $i < @tfs - 1 ; $i++ ) {
            for ( my $j = $i + 1 ; $j < @tfs ; $j++ ) {
                my $tfp = join "\t", sort ( $tfs[$i], $tfs[$j] );
                $link{$tfp} = 1;
            }
        }
    }
    close $IC or warn "$0 : failed to close input file '$fic' : $!\n";

    my $fol = "$dout_network/${cell}_links.txt";
    open my $OL, '>', $fol
      or die "$0 : failed to open output file '$fol' : $!\n";
    select $OL;
    print "tf1\ttf2\tweight\n";
    foreach my $tfp ( sort keys %link ) {
        if ( exists $glasso{$tfp} ) {
            print "$tfp\t$glasso{$tfp}\n";
        }
    }
    close $OL or warn "$0 : failed to close output file '$fol' : $!\n";

    my $fon = "$dout_network/${cell}_nodes.txt";
    open my $ON, '>', $fon
      or die "$0 : failed to open output file '$fon' : $!\n";
    select $ON;
    print "tf\tcid\tshare\n";
    foreach my $tf ( sort keys %node ) {
        if ( $node{$tf} > 1 ) {

            # print "$tf\t0\t1\n";
            print "$tf\t$complex{$tf}\t1\n";
        }
        else {
            print "$tf\t$complex{$tf}\t0\n";
        }
    }
    close $ON or warn "$0 : failed to close output file '$fon' : $!\n";
}

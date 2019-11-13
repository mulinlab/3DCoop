#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use FindBin;
use lib "$FindBin::Bin/../lib";
use TDCoop;

my $fi_cfg = $ARGV[0];
my %conf   = parse_configure($fi_cfg);

my $dout     = $conf{dir_out};
my @cells    = sort @{ $conf{cells} };
my $num_cell = @cells;

my $dio = "$dout/05_clusterone/02_number";

foreach my $cell (@cells) {
    my %hash;
    my $fi = "$dio/${cell}_clique_number.txt";
    open my $I, '<', $fi or die "$0 : failed to open input file '$fi' : $!\n";
    while (<$I>) {
        unless (/^cell/) {
            chomp;
            my @f = split /\t/;
            $hash{ $f[0] }->{ $f[2] } += $f[3];
        }
    }
    close $I or warn "$0 : failed to close input file '$fi' : $!\n";

    my $fo = "$dio/${cell}_selected_density.txt";
    open my $O, '>', $fo or die "$0 : failed to open output file '$fo' : $!\n";
    select $O;
    print "cell\tdensity\tcliques\torder\n";
    foreach my $class ( sort keys %hash ) {
        my %d   = %{ $hash{$class} };
        my $cnt = 0;
        foreach my $density ( sort { $d{$b} <=> $d{$a} || $a <=> $b } keys %d )
        {
            $cnt++;
            print "$class\t$density\t$d{$density}\t$cnt\n";
        }
    }
    close $O or warn "$0 : failed to close output file '$fo' : $!\n";
}

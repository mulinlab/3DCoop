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

my $dio         = "$dout/05_clusterone";
my $din_test    = "$dio/01_test";
my $dout_number = "$dio/02_number";
mkdir $dout_number unless -d $dout_number;

foreach my $cell (@cells) {
    my $fo = "$dout_number/${cell}_clique_number.txt";
    open my $O, '>', $fo or die "$0 : failed to open output file '$fo' : $!\n";
    select $O;
    print "cell\tk\tdensity\tnumber\n";
    my @files = glob "$din_test/$cell/*.txt";
    foreach my $fi (@files) {
        my $bn = basename($fi);
        my $d = $1 if ( $bn =~ /density_(.+?)\.txt/ );
        open my $I, '<', $fi
          or die "$0 : failed to open input file '$fi' : $!\n";
        my %hash;
        while (<$I>) {
            chomp;
            my @f = split /\t/;
            my $k = @f;
            $hash{$k}++;
        }
        close $I or warn "$0 : failed to close input file '$fi' : $!\n";
        foreach my $k ( sort keys %hash ) {
            print "$cell\t$k\t$d\t$hash{$k}\n";
        }
    }
    close $O or warn "$0 : failed to close output file '$fo' : $!\n";
}

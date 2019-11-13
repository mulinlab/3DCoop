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

my $din  = $conf{dir_in};
my $dout = $conf{dir_out};
mkdir $dout unless -d $dout;
my @cells    = sort @{ $conf{cells} };
my $num_cell = @cells;

my $fin_bin = "$FindBin::Bin/../resource/hg19_bins_5kb.bed";

foreach my $cell (@cells) {
    my $frac     = $conf{fraction}->{$cell};
    my $din_cell = "$din/peaks/$cell";
    my $dout_bin = "$dout/01_intersection_bed";
    mkdir $dout_bin unless -d $dout_bin;
    my $dout_cell = "$dout_bin/$cell";
    mkdir $dout_cell unless -d $dout_cell;

    my @files = glob "$din_cell/*.bed";
    foreach my $fip (@files) {
        my $bn = basename($fip);
        $bn =~ s/\.bed/_bin.bed/;
        my $fo = "$dout_cell/$bn";

# system "bedtools intersect -a $fip -b $fib -f $frac -wa -wb > $fo";
# system "bedtools intersect -a $fip -b $fin_bin -f $frac -wa -wb | cut -f6-8 | sort | uniq | bedtools sort -i stdin > $fo";
        system
"cut -f1-3 $fip | bedtools intersect -a stdin -b $fin_bin -f $frac -wa -wb | cut -f4-6 | sort | uniq | bedtools sort -i stdin > $fo";
    }

}


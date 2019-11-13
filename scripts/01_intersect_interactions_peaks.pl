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

# mininum overlap of ChIP-seq peaks required as a fraction of Hi-C interactions (bed format)

foreach my $cell (@cells) {
    my $frac     = $conf{fraction}->{$cell};
    my $cnt_cell = 0;

    # folder saving ChIP-seq peaks
    # each file in "${cell}_${tf}.bed" format, such as K562_CTCF.bed
    my $din_peak = "$din/peaks/$cell";

# folder saving Hi-C/HiChIP/ChIA-PET interactions
# pair files in "${cell}.bed" and "${cell}.bedpe" format, such as K562.bed & K562.bedpe
    my $din_interaction = "$din/interactions/$cell";

    # folder to save intersection results: each folder per cell
    my $dout_it = "$dout/01_intersection_bed";
    mkdir $dout_it unless -d $dout_it;
    my $dout_cell = "$dout_it/$cell";
    mkdir $dout_cell unless -d $dout_cell;

    $cnt_cell++;
    print STDERR "Processing cell [$cnt_cell/$num_cell]:\t$cell\n";
    my $fih    = "$din_interaction/${cell}.bed";
    my @files  = glob "$din_peak/${cell}_*.bed";
    my $num_tf = @files;
    my $cnt_tf = 0;
    foreach my $fip (@files) {
        my $bn = basename($fip);
        my $tf;
        $tf = $1 if ( $bn =~ /_(.+?)\.bed/ );
        $cnt_tf++;
        print STDERR "\tProcessing TF [$cnt_tf/$num_tf]:\t$tf\r";
        my $fo = "$dout_cell/$cell" . "_" . "$tf" . "_hic.bed";
        system "bedtools intersect -a $fih -b $fip -wa -u -F $frac > $fo";
    }
    print STDERR "\n";
}

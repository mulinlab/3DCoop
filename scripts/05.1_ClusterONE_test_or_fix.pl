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

my $jar = "$FindBin::Bin/../tools/cluster_one-1.0.jar";

my $din_glasso = "$dout/04_glasso";
my $dout_co    = "$dout/05_clusterone";
mkdir $dout_co unless -d $dout_co;

foreach my $cell (@cells) {
    my $fi = "$din_glasso/glasso_${cell}.txt";
    if ( $conf{cutoff_clusterone}->{$cell} eq "auto" ) {
        my $dout_cot = "$dout_co/01_test";
        mkdir $dout_cot unless -d $dout_cot;
        my $doc = "$dout_cot/${cell}";
        mkdir $doc unless -d $doc;

        my $start = 0;
        my $end   = 0.5;
        my $step  = 0.01;

        for ( my $int = $start ; $int <= $end ; $int += $step ) {
            my $fot     = "$doc/density_${int}.txt";
            my $cmd_txt = "java -jar $jar $fi -d $int -s 3 > $fot";
            system "$cmd_txt";
            my $foc     = "$doc/density_${int}.csv";
            my $cmd_csv = "java -jar $jar $fi -d $int -s 3 -F csv > $foc";
            system "$cmd_csv";
        }

        system "perl $FindBin::Bin/05.2.1_gather_number.pl $fi_cfg";
        system "perl $FindBin::Bin/05.2.2_select_density.pl $fi_cfg";
        system "Rscript $FindBin::Bin/05.2.3_plot_number.R $fi_cfg";
    }
    else {
        my $int      = $conf{cutoff_clusterone}->{$cell};
        my $dout_cof = "$dout_co/01_fix";
        mkdir $dout_cof unless -d $dout_cof;
        my $doc = "$dout_cof/${cell}";
        mkdir $doc unless -d $doc;

        my $fot     = "$doc/density_${int}.txt";
        my $cmd_txt = "java -jar $jar $fi -d $int -s 3 > $fot";
        system "$cmd_txt";
        my $foc     = "$doc/density_${int}.csv";
        my $cmd_csv = "java -jar $jar $fi -d $int -s 3 -F csv > $foc";
        system "$cmd_csv";
    }
}

#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use FindBin;
use lib "$FindBin::Bin/../lib";
use TDCoop;

my $fi_cfg = $ARGV[0];
my %conf   = parse_configure($fi_cfg);

# my $species   = $conf{species};
my $pie = $conf{pie};

my $dib = "$FindBin::Bin/../scripts";

system "perl $dib/06.1_complex2network.pl $fi_cfg";

# if($species eq "human" && $pie eq "true"){
if ( $pie eq "true" ) {
    system "perl $dib/06.2.1_prepare4pie.pl $fi_cfg";
    system "Rscript $dib/06.2.2_plot_network_pie.R $fi_cfg";
}
else {
    system "Rscript $dib/06.2_plot_network.R $fi_cfg";
}

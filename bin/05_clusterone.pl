#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use FindBin;

my $fi_cfg = $ARGV[0];
my $dib    = "$FindBin::Bin/../scripts";

system "perl $dib/05.1_ClusterONE_test_or_fix.pl $fi_cfg";
system "perl $dib/05.3_get_clusters.pl $fi_cfg";
system "perl $dib/05.4_extract_clique.pl $fi_cfg";
system "perl $dib/05.5_extract_max_clique.pl $fi_cfg";
system "perl $dib/05.6_maxclique2pair.pl $fi_cfg";
system "perl $dib/05.7_score_clutser.pl $fi_cfg";
system "bash $dib/05.8_collect_results.sh $fi_cfg";

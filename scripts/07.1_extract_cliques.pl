#!/usr/bin/perl

use warnings;
use strict;
use utf8;

my $dir_work = shift @ARGV;
my $cell     = shift @ARGV;
my @tfs      = @ARGV;

my $din = "$dir_work/05_clusterone/08_results";
my $fi  = "$din/${cell}_clusters_list.txt";

my $dout = "$dir_work/07_cliques";
mkdir $dout unless -d $dout;
my $dout_cell = "$dout/$cell";
mkdir $dout_cell unless -d $dout_cell;

my $fop = "$dout_cell/pattern.tmp";
open my $OP, '>', $fop or die "$0 : failed to open output file '$fop' : $!\n";
select $OP;
foreach my $tf (@tfs) {
    print "$tf\n";
}
close $OP or warn "$0 : failed to close output file '$fop' : $!\n";

my $fo = "$dout_cell/cliques.txt";
system "grep -f $fop -w $fi | sort | uniq > $fo";
unlink($fop);

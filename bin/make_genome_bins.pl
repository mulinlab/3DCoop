#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use File::Basename;
use FindBin;

if ( @ARGV != 2 ) {
    print STDERR "$ARGV[0] should be the genome build (hg19/hg38/mm10)!\n";
    print STDERR
"$ARGV[1] should be the bin size in 'Xkb' format (1kb/5kb/10kb/1Mb/...)!\n";
    exit;
}

my $ver = `bedtools --version`;
unless ( $ver =~ /^bedtools/ ) {
    print STDERR "bedtools must be installed!\n";
    exit;
}

my $dir_resource = "$FindBin::Bin/../resource";

my $build   = $ARGV[0];
my $binname = $ARGV[1];
my $bin     = $binname;
$bin =~ s/kb/000/;
$bin =~ s/Mb/000000/;

system
"bedtools makewindows -g $dir_resource/${build}_chrom_size.txt -w $bin > $dir_resource/${build}_bins_${binname}.bed";

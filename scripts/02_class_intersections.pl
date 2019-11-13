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

my $din      = $conf{dir_in};
my $dout     = $conf{dir_out};
my @cells    = sort @{ $conf{cells} };
my $num_cell = @cells;

foreach my $cell (@cells) {
    my $num_cell = @cells;
    my $cnt_cell = 0;

    my $din_intersection = "$dout/01_intersection_bed/$cell";
    my $din_interaction  = "$din/interactions/$cell";
    my $dout_bedpe       = "$dout/02_intersection_bedpe";
    mkdir $dout_bedpe unless -d $dout_bedpe;

    my $dout_cell = "$dout_bedpe/${cell}";
    mkdir $dout_cell unless -d $dout_cell;

    $cnt_cell++;
    print STDERR "Processing cell [$cnt_cell/$num_cell]:\t$cell\n";
    my $fih = "$din_interaction/${cell}.bedpe";
    open my $IH, '<', $fih
      or die "$0 : failed to open input file '$fih' : $!\n";
    my @bedpe = <$IH>;
    close $IH or warn "$0 : failed to close input file '$fih' : $!\n";
    my @files  = glob "$din_intersection/${cell}_*_hic.bed";
    my $num_tf = @files;
    my $cnt_tf = 0;

    foreach my $fi (@files) {
        my $bn = basename($fi);
        my %hash;
        open my $I, '<', $fi
          or die "$0 : failed to open input file '$fi' : $!\n";
        while (<$I>) {
            chomp;
            $hash{$_} = 1;
        }
        close $I or warn "$0 : failed to close input file '$fi' : $!\n";
        my $tf;
        $tf = $1 if ( $bn =~ /_(.+?)_hic/ );
        $cnt_tf++;
        print STDERR "\tProcessing TF [$cnt_tf/$num_tf]:\t$tf\r";

        my $fo = "$dout_cell/$cell" . "_" . "$tf" . ".bedpe";
        open my $O, '>', $fo
          or die "$0 : failed to open output file '$fo' : $!\n";
        foreach my $line (@bedpe) {
            chomp($line);
            my @f = split /\t/, $line;
            my $x = join "\t", @f[ 0 .. 2 ];
            my $y = join "\t", @f[ 3 .. 5 ];
            if ( exists $hash{$x} && $hash{$y} ) {
                print $O "$line\t11\n";
            }
            else {
                if ( exists $hash{$x} ) {
                    print $O "$line\t10\n";
                }
                if ( exists $hash{$y} ) {
                    print $O "$line\t01\n";
                }
            }
        }
        close $O or warn "$0 : failed to close output file '$fo' : $!\n";
    }
}

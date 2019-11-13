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

my $dout         = $conf{dir_out};
my @cells        = sort @{ $conf{cells} };
my $num_cell     = @cells;
my $din_test     = "$dout/05_clusterone/01_test";
my $din_fix      = "$dout/05_clusterone/01_fix";
my $din_number   = "$dout/05_clusterone/02_number";
my $dout_cluster = "$dout/05_clusterone/03_clusters";
mkdir $dout_cluster unless -d $dout_cluster;

foreach my $cell (@cells) {
    my $density;
    my $din_clusterone;

    if ( $conf{cutoff_clusterone}->{$cell} eq "auto" ) {
        $din_clusterone = $din_test;
        my $fin = "$din_number/${cell}_selected_density.txt";
        open my $IN, '<', $fin
          or die "$0 : failed to open input file '$fin' : $!\n";
        while (<$IN>) {
            chomp;
            my @f = split /\t/;
            if ( $f[0] eq $cell && $f[-1] == 1 ) {
                $density = $f[1];
            }
        }
        close $IN or warn "$0 : failed to close input file '$fin' : $!\n";
    }
    else {
        $din_clusterone = $din_fix;
        $density        = $conf{cutoff_clusterone}->{$cell};
    }

    my $fi = "$din_clusterone/$cell/density_${density}.txt";
    open my $I, '<', $fi or die "$0 : failed to open input file '$fi' : $!\n";
    my %hash;
    while (<$I>) {
        chomp;
        my @f = split /\t/;
        if ( @f == 3 ) {
            push @{ $hash{"3"} },   $_;
            push @{ $hash{"all"} }, $_;
        }
        elsif ( @f == 4 ) {
            push @{ $hash{"4"} },   $_;
            push @{ $hash{"all"} }, $_;
        }
        elsif ( @f == 5 ) {
            push @{ $hash{"5"} },   $_;
            push @{ $hash{"all"} }, $_;
        }
        elsif ( @f == 6 ) {
            push @{ $hash{"6"} },   $_;
            push @{ $hash{"all"} }, $_;
        }
        elsif ( @f == 7 ) {
            push @{ $hash{"7"} },   $_;
            push @{ $hash{"all"} }, $_;
        }
        else {
            push @{ $hash{"other"} }, $_;
            push @{ $hash{"all"} },   $_;
        }
    }
    close $I or warn "$0 : failed to close input file '$fi' : $!\n";

    my @files_old = glob "$dout_cluster/${cell}_clusters_*.txt";
    foreach my $fio (@files_old) {
        unlink($fio);
    }

    foreach my $k ( sort keys %hash ) {
        my $fo = "$dout_cluster/${cell}_clusters_${k}.txt";
        open my $O, '>', $fo
          or die "$0 : failed to open output file '$fo' : $!\n";
        select $O;
        foreach my $cluster ( @{ $hash{$k} } ) {
            print "$cluster\n";
        }
        close $O or warn "$0 : failed to close output file '$fo' : $!\n";
    }
}

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

my $dout       = $conf{dir_out};
my @cells      = sort @{ $conf{cells} };
my $num_cell   = @cells;
my $din_glasso = "$dout/04_glasso";
my $din_test   = "$dout/05_clusterone/01_test";
my $din_fix    = "$dout/05_clusterone/01_fix";
my $din_number = "$dout/05_clusterone/02_number";
my $dout_score = "$dout/05_clusterone/07_score";
mkdir $dout_score unless -d $dout_score;

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

    my %glasso;
    my $fig = "$din_glasso/glasso_${cell}.txt";
    open my $IG, '<', $fig
      or die "$0 : failed to open input file '$fig' : $!\n";
    while (<$IG>) {
        unless (/^#TF1/) {
            chomp;
            my @f = split /\t/;
            my $key = join "\t", @f[ 0, 1 ];
            $glasso{$key} = $f[2];
        }
    }
    close $IG or warn "$0 : failed to close input file '$fig' : $!\n";

    my %info;
    my %score;
    my $fic = "$din_clusterone/$cell/density_${density}.csv";
    open my $IC, '<', $fic
      or die "$0 : failed to open input file '$fic' : $!\n";
    while (<$IC>) {
        unless (/^Cluster/) {
            chomp;
            my @f = split /,/;
            $f[-1] =~ s/"//g;
            my @tfs = split / /, $f[-1];
            my $cluster = join "-", sort @tfs;
            my $glasso = mean_glasso( \@tfs, \%glasso );
            $info{$cluster} = join "\t", @f[ 1, 2, 5, 6 ], $glasso;
            $score{$cluster} = $glasso;
        }
    }
    close $IC or warn "$0 : failed to close input file '$fic' : $!\n";

    my $fo = "$dout_score/${cell}_cluster_scores.txt";
    open my $O, '>', $fo or die "$0 : failed to open output file '$fo' : $!\n";
    select $O;
    print "cluster\tsize\tdensity\tquality\tpvalue\tglasso\n";
    foreach my $key ( sort { $score{$b} <=> $score{$a} } keys %score ) {
        print "$key\t$info{$key}\n";
    }
    close $O or warn "$0 : failed to close output file '$fo' : $!\n";
}

sub mean_glasso {
    my ( $ref_array, $ref_hash ) = @_;
    my @tfs    = @$ref_array;
    my %glasso = %$ref_hash;
    my ( $num, $sum );
    for ( my $i = 0 ; $i < @tfs - 1 ; $i++ ) {
        for ( my $j = $i + 1 ; $j < @tfs ; $j++ ) {
            my $k = join "\t", sort ( $tfs[$i], $tfs[$j] );
            if ( exists $glasso{$k} ) {
                $num++;
                $sum += $glasso{$k};
            }
        }
    }
    my $mean = sprintf "%.5f", $sum / $num;
    return ($mean);
}

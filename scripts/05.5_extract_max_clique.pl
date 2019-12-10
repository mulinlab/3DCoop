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

my $din_jaccard = "$dout/03_jaccard";
my $din_glasso  = "$dout/04_glasso";
my $din_co      = "$dout/05_clusterone";
my $din_cluster = "$din_co/03_clusters";
my $dout_clique = "$din_co/05_max_cliques";
mkdir $dout_clique unless -d $dout_clique;

my $r = "$FindBin::Bin/05.5.0_cluster2maxclique.R";

foreach my $cell (@cells) {
    my %output;

    my %glasso;
    my $fig = "$din_glasso/glasso_${cell}.txt";
    open my $IG, '<', $fig
      or die "$0 : failed to open input file '$fig' : $!\n";
    while (<$IG>) {
        unless (/^#/) {
            chomp;
            my @f = split /\t/;
            my $key = join "\t", sort( @f[ 0, 1 ] );
            $glasso{$key} = $f[2];
        }
    }
    close $IG or warn "$0 : failed to close input file '$fig' : $!\n";

    my %jaccard;
    my $fij = "$din_jaccard/jaccard_${cell}.txt";
    open my $IJ, '<', $fij
      or die "$0 : failed to open input file '$fij' : $!\n";
    while (<$IJ>) {
        unless (/Jaccard/) {
            chomp;
            my @f = split /\t/;
            my $key = join "\t", sort( @f[ 0, 1 ] );
            $jaccard{$key} = $f[4];
        }
    }
    close $IJ or warn "$0 : failed to close input file '$fij' : $!\n";

    my $dot = "$dout_clique/tmp_$cell";
    mkdir $dot unless -d $dot;
    my $fic = "$din_cluster/${cell}_clusters_all.txt";
    open my $IC, '<', $fic
      or die "$0 : failed to open input file '$fic' : $!\n";
    while (<$IC>) {
        my $fog = "$dot/graph.txt";
        my $fc  = "$dot/clique.txt";
        open my $OG, '>', $fog
          or die "$0 : failed to open output file '$fog' : $!\n";
        chomp;
        my @tfs = split /\t/;
        my $min = 3;
        my $max = @tfs;
        for ( my $i = 0 ; $i < $#tfs ; $i++ ) {

            for ( my $j = $i + 1 ; $j <= $#tfs ; $j++ ) {
                my $key = join "\t", sort ( @tfs[ $i, $j ] );
                if ( exists $jaccard{$key} && $glasso{$key} ) {
                    print $OG "$tfs[$i]\t$tfs[$j]\n";
                }
            }
        }
        close $OG or warn "$0 : failed to close output file '$fog' : $!\n";
        system "Rscript $r $fog $min $max $fc";
        open my $IT, '<', $fc
          or die "$0 : failed to open input file '$fc' : $!\n";
        while (<$IT>) {
            chomp;
            my @tfs = split /\t/;
            my $num = @tfs;
            my ( $sum_jaccard, $mean_jaccard, $sum_glasso, $mean_glasso );
            for ( my $i = 0 ; $i < $#tfs ; $i++ ) {
                for ( my $j = $i + 1 ; $j <= $#tfs ; $j++ ) {
                    my $key = join "\t", sort ( @tfs[ $i, $j ] );
                    if ( exists $jaccard{$key} && $glasso{$key} ) {
                        $sum_jaccard += $jaccard{$key};
                        $sum_glasso  += $glasso{$key};
                    }
                    else {
                        print STDERR "Not exists:\t$key\n";
                    }
                }
            }
            $mean_jaccard = $sum_jaccard / ( $num * ( $num - 1 ) / 2 );
            $mean_glasso  = $sum_glasso /  ( $num * ( $num - 1 ) / 2 );
            my $clique = join "-", sort @tfs;
            $sum_jaccard  = sprintf( "%.10f", $sum_jaccard );
            $sum_glasso   = sprintf( "%.10f", $sum_glasso );
            $mean_jaccard = sprintf( "%.10f", $mean_jaccard );
            $mean_glasso  = sprintf( "%.10f", $mean_glasso );
            my $op = join "\t", $clique, $num, $sum_jaccard, $mean_jaccard,
              $sum_glasso, $mean_glasso;
            $output{$op} = 1;
        }
        close $IT or warn "$0 : failed to close input file '$fc' : $!\n";
        unlink($fog);
        unlink($fc);
    }
    close $IC or warn "$0 : failed to close input file '$fic' : $!\n";

    rmdir($dot);

    my $fo = "$dout_clique/${cell}_max_cliques.txt";
    open my $O, '>', $fo or die "$0 : failed to open output file '$fo' : $!\n";
    select $O;
    print "clique\tnumber\tjaccardSum\tjaccardMean\tglassoSum\tglassoMean\n";
    foreach my $line ( sort keys %output ) {
        print "$line\n";
    }
    close $O or warn "$0 : failed to close output file '$fo' : $!\n";
}

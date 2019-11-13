#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use File::Basename;
use List::Util qw(uniq);
use Parallel::ForkManager;
use FindBin;
use lib "$FindBin::Bin/../lib";
use TDCoop;

my $fi_cfg = $ARGV[0];
my %conf   = parse_configure($fi_cfg);

my $din      = $conf{dir_in};
my $dout     = $conf{dir_out};
my @cells    = sort @{ $conf{cells} };
my $num_cell = @cells;

my $cnt_cell = 0;
foreach my $cell (@cells) {
    my $cpu = $conf{cpus}->{$cell};
    my $pm  = Parallel::ForkManager->new($cpu);

    my $din          = "$dout/01_intersection_bed/${cell}";
    my $dout_jaccard = "$dout/03_jaccard";
    mkdir $dout_jaccard unless -d $dout_jaccard;

    $cnt_cell++;
    print STDERR "Processing cell [$cnt_cell/$num_cell]:\t$cell\n";

    my @files = glob "$din/*.bed";
    my @tfs;
    my %number_bins;
    my %bins;
    foreach my $file (@files) {
        my $bn = basename($file);
        my $tf = $1 if ( $bn =~ /${cell}_(.+?)_bin\.bed/ );
        push @tfs, $tf;
        open my $I, '<', $file
          or die "$0 : failed to open input file '$file' : $!\n";
        my $num = 0;
        while (<$I>) {
            chomp;
            $num++;
            $bins{$tf}->{$_} = 1;
        }
        close $I or warn "$0 : failed to close input file '$file' : $!\n";
    }

    my @lines_all;
    $pm->run_on_finish(
        sub {
   # my ( $pid, $exit_code, $ident, $exit_signal, $core_dump, $ref_lines ) = @_;
            my $ref_lines = pop @_;
            push @lines_all, @$ref_lines;
        }
    );

  JACCARD:
    for ( my $i = 0 ; $i < $#tfs ; $i++ ) {
        my $tfa   = $tfs[$i];
        my @binsa = keys %{ $bins{$tfa} };
        $pm->start and next JACCARD;

        # print "Processing:\t$tfa\r";
        my @lines = get_jaccard( $i, $tfa, \@binsa, \@tfs, \%bins );
        $pm->finish( 0, \@lines );

    }
    $pm->wait_all_children;

    my $fo = "$dout_jaccard/jaccard_${cell}_full.txt";
    open my $O, '>', $fo or die "$0 : failed to open output file '$fo' : $!\n";
    select $O;
    print join "\t", "TF1", "TF2", "peaks1", "peaks2", "intersection", "union",
      "Jaccard";
    print "\n";
    foreach my $line ( sort @lines_all ) {
        print "$line\n";
    }
    close $O or warn "$0 : failed to close output file '$fo' : $!\n";

    my $fo2 = "$dout_jaccard/jaccard_${cell}.txt";
    system "cut -f1,2,5,6,7 $fo > $fo2";
}

sub get_jaccard {
    my ( $i, $tfa, $ref_binsa, $ref_tfs, $ref_bins ) = @_;
    my $n_tfa = scalar(@$ref_binsa);
    my @tfs   = @$ref_tfs;
    my %bins  = %$ref_bins;
    my @lines_tfa;
    for ( my $j = $i + 1 ; $j <= $#tfs ; $j++ ) {
        my $tfb   = $tfs[$j];
        my @binsb = keys %{ $bins{$tfb} };
        my $n_tfb = scalar(@binsb);
        my @bins  = uniq( @$ref_binsa, @binsb );
        my ( $n_intersection, $n_union ) = 0;
        $n_union = scalar(@bins);
        foreach my $bin (@bins) {
            if ( exists $bins{$tfa}->{$bin} && exists $bins{$tfb}->{$bin} ) {
                $n_intersection++;
            }
        }
        if ( $n_union == 0 ) {
            $n_union = 1;
        }
        my $jaccard = sprintf( "%.5f", $n_intersection / $n_union );
        my $line = join "\t", $tfa, $tfb, $n_tfa, $n_tfb, $n_intersection,
          $n_union, $jaccard;
        push @lines_tfa, $line;
    }
    return (@lines_tfa);
}


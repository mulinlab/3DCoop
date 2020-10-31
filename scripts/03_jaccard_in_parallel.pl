#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use File::Basename;
use List::Util qw(min max uniq);
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

    my $din          = "$dout/02_intersection_bedpe/${cell}";
    my $dout_jaccard = "$dout/03_jaccard";
    mkdir $dout_jaccard unless -d $dout_jaccard;

    $cnt_cell++;
    print STDERR "Processing cell [$cnt_cell/$num_cell]:\t$cell\n";

    my @files = glob "$din/*.bedpe";

    my @tfs;
    my %hic;
    foreach my $fi (@files) {
        my $bn = basename($fi);
        my $tf;
        $tf = $1 if ( $bn =~ /_(.+?)\./ );
        push @tfs, $tf;
        open my $I, '<', $fi
          or die "$0 : failed to open input file '$fi' : $!\n";
        while (<$I>) {
            chomp;
            my @f = split /\t/;
            $hic{$tf}->{ $f[6] } = $f[7];
        }
        close $I or warn "$0 : failed to close input file '$fi' : $!\n";
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
        my @binsa = keys %{ $hic{$tfa} };
        $pm->start and next JACCARD;

        # print "Processing:\t$tfa\r";
        my @lines = get_jaccard( $i, $tfa, \@binsa, \@tfs, \%hic );
        $pm->finish( 0, \@lines );

    }
    $pm->wait_all_children;

    my $fo = "$dout_jaccard/jaccard_${cell}.txt";
    open my $O, '>', $fo or die "$0 : failed to open output file '$fo' : $!\n";
    select $O;
    print "TF1\tTF2\tcumMin\tcumMax\tJaccard\n";
    foreach my $line ( sort @lines_all ) {
        print "$line\n";
    }
    close $O or warn "$0 : failed to close output file '$fo' : $!\n";
}

sub get_jaccard {
    my ( $i, $tfa, $ref_binsa, $ref_tfs, $ref_hic ) = @_;
    my @tfs = @$ref_tfs;
    my %hic = %$ref_hic;
    my @lines_tfa;
    for ( my $j = $i + 1 ; $j <= $#tfs ; $j++ ) {
        my $tfb   = $tfs[$j];
        my @binsb = keys %{ $hic{$tfb} };
        my @bins  = uniq( @$ref_binsa, @binsb );
        my ( $min, $max ) = 0;
        foreach my $bin (@bins) {
            if ( exists $hic{$tfa}->{$bin} && $hic{$tfb}->{$bin} ) {
                $min += min( $hic{$tfa}->{$bin}, $hic{$tfb}->{$bin} );
                $max += max( $hic{$tfa}->{$bin}, $hic{$tfb}->{$bin} );
            }
            elsif ( exists $hic{$tfa}->{$bin} ) {
                $min += 0;
                $max += $hic{$tfa}->{$bin};
            }
            else {
                $min += 0;
                $max += $hic{$tfb}->{$bin};
            }
        }
        if ( $max == 0 ) {
            $max = 1;
        }
        my $jaccard = sprintf( "%.5f", $min / $max );
        my $line = join "\t", $tfa, $tfb, $min, $max, $jaccard;
        push @lines_tfa, $line;
    }
    return (@lines_tfa);
}

#!/usr/bin/perl

use warnings;
use strict;
use utf8;

sub parse_configure {
    my $fi_cfg = shift @_;

    my ( @cells, @fractions, @cpus, @cutoffs );
    my %hash;
    open my $IC, '<', $fi_cfg
      or die "$0 : failed to open input file '$fi_cfg' : $!\n";
    while (<$IC>) {
        unless (/^key\t/) {
            chomp;
            my @f = split /\t/;
            if (/^cells/) {
                if ( $f[1] =~ /,/ ) {
                    @cells = split /,/, $f[1];
                    @{ $hash{"cells"} } = unique_cells( $f[1] );
                }
                else {
                    push @cells, $f[1];
                    push @{ $hash{"cells"} }, $f[1];
                }
            }
            elsif (/^fraction/) {
                if ( $f[1] =~ /,/ ) {
                    @fractions = split /,/, $f[1];
                }
                else {
                    push @fractions, $f[1];
                }

            }
            elsif (/^cpus/) {
                if ( $f[1] =~ /,/ ) {
                    @cpus = split /,/, $f[1];
                }
                else {
                    push @cpus, $f[1];
                }

            }
            elsif (/^cutoffs/) {
                if ( $f[1] =~ /,/ ) {
                    @cutoffs = split /,/, $f[1];
                }
                else {
                    push @cutoffs, $f[1];
                }
            }
            else {
                $hash{ $f[0] } = $f[1];
            }
        }
    }
    close $IC or warn "$0 : failed to close input file '$fi_cfg' : $!\n";

    for ( my $i = 0 ; $i < @cells ; $i++ ) {
        $hash{fraction}->{ $cells[$i] } = $fractions[$i];
    }

    for ( my $i = 0 ; $i < @cells ; $i++ ) {
        $hash{cpus}->{ $cells[$i] } = $cpus[$i];
    }

    for ( my $i = 0 ; $i < @cells ; $i++ ) {
        $hash{cutoff_clusterone}->{ $cells[$i] } = $cutoffs[$i];
    }

    return (%hash);
}

sub unique_cells {
    my $str = shift @_;
    my %tmp;
    my @cs = split /,/, $str;
    foreach my $c (@cs) {
        $tmp{$c} = 1;
    }
    return ( keys %tmp );
}

1;

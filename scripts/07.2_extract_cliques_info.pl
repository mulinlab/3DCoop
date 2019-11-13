#!/usr/bin/perl

use warnings;
use strict;
use utf8;

my $dir_work = $ARGV[0];
my $cell     = $ARGV[1];

my $din = "$dir_work/06_network";
my $dio = "$dir_work/07_cliques/$cell";

my ( $header_node, $header_link );
my %node;
my $fin = "$din/${cell}_nodes4pie.txt";
open my $IN, '<', $fin or die "$0 : failed to open input file '$fin' : $!\n";
while (<$IN>) {
    chomp;
    if (/^tf/) {
        $header_node = $_;
    }
    else {
        my @f = split /\t/;
        $node{ $f[0] } = $_;
    }
}
close $IN or warn "$0 : failed to close input file '$fin' : $!\n";

my %link;
my $fil = "$din/${cell}_links4pie.txt";
open my $IL, '<', $fil or die "$0 : failed to open input file '$fil' : $!\n";
while (<$IL>) {
    chomp;
    if (/^tf1/) {
        $header_link = $_;
    }
    else {
        my @f = split /\t/;
        my $key = join "\t", sort ( @f[ 0, 1 ] );
        $link{$key} = $f[2];
    }
}
close $IL or warn "$0 : failed to close input file '$fil' : $!\n";

my $fic = "$dio/cliques.txt";
open my $IC, '<', $fic or die "$0 : failed to open input file '$fic' : $!\n";
while (<$IC>) {
    chomp;
    clique2node($_);
    clique2link($_);
}
close $IC or warn "$0 : failed to close input file '$fic' : $!\n";

sub clique2node {
    my $s    = shift @_;
    my @f    = split /\t/, $s;
    my $name = join "_", @f;
    my $fo   = "$dio/${name}.nodes";
    open my $O, '>', $fo or die "$0 : failed to open output file '$fo' : $!\n";
    select $O;
    print "$header_node\n";
    foreach my $c (@f) {
        print "$node{$c}\n";
    }
    close $O or warn "$0 : failed to close output file '$fo' : $!\n";
}

sub clique2link {
    my $s    = shift @_;
    my @f    = split /\t/, $s;
    my $name = join "_", @f;
    my $fo   = "$dio/${name}.links";
    open my $O, '>', $fo or die "$0 : failed to open output file '$fo' : $!\n";
    select $O;
    print "$header_link\n";
    for ( my $i = 0 ; $i < @f - 1 ; $i++ ) {

        for ( my $j = $i + 1 ; $j < @f ; $j++ ) {
            my $key = join "\t", sort ( $f[$i], $f[$j] );
            if ( exists $link{$key} ) {
                print "$key\t$link{$key}\n";
            }
        }
    }
    close $O or warn "$0 : failed to close output file '$fo' : $!\n";
}


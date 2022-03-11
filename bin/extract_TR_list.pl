#!/usr/bin/perl

use warnings;
use strict;
use utf8;

if ( @ARGV < 4 ) {
    print STDERR "$ARGV[0] should be the path to the whole-genome TRs!\n";
    print STDERR
      "$ARGV[1] should be the path to the whole-genome gene id-symbol pairs!\n";
    print STDERR
      "$ARGV[2] should be the path to the filtered TPM expression!\n";
    print STDERR "$ARGV[3] should be the path to the output TR list!\n";
    exit;
}

my $fi_tr   = $ARGV[0];
my $fi_gene = $ARGV[1];
my $fi_tpm  = $ARGV[2];
my $fo      = $ARGV[3];

my %tr_all       = get_human_tr($fi_tr);
my %gene_id2name = map_gene_id2name($fi_gene);

my %tr;
open my $I, '<', $fi_tpm
  or die "$0 : failed to open input file '$fi_tpm' : $!\n";
while (<$I>) {
    unless (/^gene/) {
        chomp;
        my @f = split /\t/;
        if ( exists $gene_id2name{ $f[0] } ) {
            my $name = $gene_id2name{ $f[0] };
            if ( exists $tr_all{$name} ) {
                $tr{$name} = 1;
            }
        }
    }
}
close $I or warn "$0 : failed to close input file '$fi_tpm' : $!\n";

open my $O, '>', $fo or die "$0 : failed to open output file '$fo' : $!\n";
select $O;
foreach my $name ( sort keys %tr ) {
    print "$name\n";
}
close $O or warn "$0 : failed to close output file '$fo' : $!\n";

sub get_human_tr {
    my $fi = shift;
    my %tr;

    open my $I, '<', $fi or die "$0 : failed to open input file '$fi' : $!\n";
    while (<$I>) {
        unless (/^motif/) {
            chomp;
            my @f = split /\t/;
            $tr{ $f[1] } = 1;
        }
    }
    close $I or warn "$0 : failed to close input file '$fi' : $!\n";

    return %tr;
}

sub map_gene_id2name {
    my $fi = shift;
    my %id2name;

    open my $I, '<', $fi or die "$0 : failed to open input file '$fi' : $!\n";
    while (<$I>) {
        unless (/^ID/) {
            chomp;
            my @f = split /\t/;
            $id2name{ $f[0] } = $f[1];
        }
    }
    close $I or warn "$0 : failed to close input file '$fi' : $!\n";

    return %id2name;
}

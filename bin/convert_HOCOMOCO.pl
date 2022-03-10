#!/usr/bin/perl

use warnings;
use strict;
use utf8;

if ( @ARGV < 2 ) {
    print STDERR
      "$ARGV[0] should be the path to the raw file downloaded from JASPAR!\n";
    print STDERR "$ARGV[1] should be the path to the output file!\n";
    exit;
}

my $fi = $ARGV[0];
my $fo = $ARGV[1];

my $idx = 1;
open my $I, '<', $fi or die "$0 : failed to open input file '$fi' : $!\n";
open my $O, '>', $fo or die "$0 : failed to open output file '$fo' : $!\n";
select $O;
while (<$I>) {
    my $header = $_;
    chomp($header);
    if ( $header =~ /^>/ ) {
        my $motif_idx = "H" . sprintf( "%05d", $idx++ );
        $header =~ s/^>//;
        $header =~ s/_.+?$//;
        print ">$motif_idx $header\n";

        my @lines_raw;
        for ( my $i = 0 ; $i < 4 ; $i++ ) {
            my $tmp = <$I>;
            push @lines_raw, $tmp;
        }
        my @lines_clean = clean_raw_lines(@lines_raw);
        my @lines       = jaspar_RAW2PPM(@lines_clean);
        my @bases       = ( "A", "C", "G", "T" );
        foreach my $line (@lines) {
            $line =~ s/\t/ /g;
            my $base = shift @bases;
            print "$base  [ $line ]\n";
        }
    }
}
close $I or warn "$0 : failed to close input file '$fi' : $!\n";
close $O or warn "$0 : failed to close output file '$fo' : $!\n";

sub clean_raw_lines {
    my @lines_raw = @_;
    my @lines_clean;
    foreach my $line (@lines_raw) {
        chomp($line);
        $line =~ s/\s+/\t/g;
        $line =~ s/^[ACGT]\t//;
        $line =~ s/\[\t?//;
        $line =~ s/\t\]$//;
        push @lines_clean, $line;
    }
    return (@lines_clean);
}

sub jaspar_RAW2PPM {
    my @lines_raw = @_;
    my @total;
    foreach my $line (@lines_raw) {
        chomp($line);
        my @f = split /\t/, $line;
        for ( my $i = 0 ; $i < @f ; $i++ ) {
            $total[$i] += $f[$i];
        }
    }

    my @lines_ppm;
    foreach my $line (@lines_raw) {
        chomp($line);
        my @ps;
        my @f = split /\t/, $line;
        for ( my $i = 0 ; $i < @f ; $i++ ) {
            my $p = sprintf( "%.10f", $f[$i] / $total[$i] );
            push @ps, $p;
        }
        my $line = join "\t", @ps;
        push @lines_ppm, $line;
    }
    return (@lines_ppm);
}


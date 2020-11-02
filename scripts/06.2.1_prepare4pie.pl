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

my $dout     = $conf{dir_out};
my @cells    = sort @{ $conf{cells} };
my $num_cell = @cells;

my $dio_network = "$dout/06_network";
mkdir $dio_network unless -d $dio_network;

my $din_resource = "$FindBin::Bin/../resource";
my %code;
my $fic = "$din_resource/$conf{species}". "_TR_category.txt";
open my $IC, '<', $fic
  or die "$0 : failed to open input file '$fic' : $!\n";
while (<$IC>) {
    unless (/^gene/) {
        chomp;
        my @f = split /\t/;
        $code{ $f[0] } = $f[2];
    }
}
close $IC or warn "$0 : failed to close input file '$fic' : $!\n";

my @colors = (
    "#D95757", "#3366CC", "#DD4477", "#109618",
    "#FF9900", "#0099C6", "#990099"
);
my $color_na = "#9D9D9D";

foreach my $cell (@cells) {
    my %degree;
    my $fil = "$dio_network/${cell}_links.txt";
    open my $IL, '<', $fil
      or die "$0 : failed to open input file '$fil' : $!\n";
    my $fol = "$dio_network/${cell}_links4pie.txt";
    open my $OL, '>', $fol
      or die "$0 : failed to open output file '$fol' : $!\n";
    select $OL;
    while (<$IL>) {
        print;
        unless (/^tf1/) {
            chomp;
            my @f = split /\t/;
            $degree{ $f[0] }++;
            $degree{ $f[1] }++;

            # $degree{ $f[0] } += $f[2];
            # $degree{ $f[1] } += $f[2];
        }
    }
    close $IL or warn "$0 : failed to close input file '$fil' : $!\n";
    close $OL or warn "$0 : failed to close output file '$fol' : $!\n";

    my $fin = "$dio_network/${cell}_nodes.txt";
    open my $IN, '<', $fin
      or die "$0 : failed to open input file '$fin' : $!\n";
    my $fon = "$dio_network/${cell}_nodes4pie.txt";
    open my $ON, '>', $fon
      or die "$0 : failed to open output file '$fon' : $!\n";
    select $ON;
    print "tf\tdegree\tcode\thub\tvalue\tcolor\n";

    while (<$IN>) {
        unless (/^tf/) {
            chomp;
            my @f = split /\t/;
            my ( $degree, $code, $value, $color );
            if ( exists $degree{ $f[0] } ) {
                $degree = $degree{ $f[0] };
            }
            else {
                $degree = 0;
                print STDERR "Degree for $f[0] does not exist!\n";
            }

            if ( exists $code{ $f[0] } ) {
                $code  = $code{ $f[0] };
                $value = code2value($code);
                $color = code2color($code);
            }
            else {
                $code = "0000000";
                print STDERR "Code for $f[0] does not exist!\n";
                $value = 1;
                $color = $color_na;
            }
            print "$f[0]\t$degree\t$code\t$f[2]\t$value\t$color\n";
        }
    }
    close $IN or warn "$0 : failed to close input file '$fin' : $!\n";
    close $ON or warn "$0 : failed to close output file '$fon' : $!\n";
}

sub code2value {
    my $code = shift @_;
    my @cs = split //, $code;
    my $cnt;
    foreach my $c (@cs) {
        if ( $c == 1 ) {
            $cnt++;
        }
    }
    my @values;
    for ( my $i = 0 ; $i < $cnt ; $i++ ) {
        push @values, 1 / $cnt;
    }
    my $value = join "\,", @values;
    return ($value);
}

sub code2color {
    my $code = shift @_;
    my @cs = split //, $code;
    my @cols;
    for ( my $i = 0 ; $i < @cs ; $i++ ) {
        if ( $cs[$i] == 1 ) {
            push @cols, $colors[$i];
        }
    }
    my $color = join ",", @cols;
    return ($color);
}

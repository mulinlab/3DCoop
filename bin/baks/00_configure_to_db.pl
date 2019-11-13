#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use File::Basename;
use DB_File;

my %hash;

my $fi_cfg = $ARGV[0];
open my $IC, '<', $fi_cfg
  or die "$0 : failed to open input file '$fi_cfg' : $!\n";
while (<$IC>) {
    unless (/^#/) {
        chomp;
        my @f = split /\t/;
        if (/^cells/) {
            if ( $f[1] =~ /,/ ) {
                @{ $hash{"cells"} } = unique_cells( $f[1] );
            }
            else {
                push @{ $hash{"cells"} }, $f[1];
            }
        }
        else {
            $hash{ $f[0] } = $f[1];
        }
    }
}
close $IC or warn "$0 : failed to close input file '$fi_cfg' : $!\n";

my $dout = $hash{"dir_out"};
mkdir $dout unless -d $dout;

my $id = basename($fi_cfg);
$id =~ s/\.conf//;
my $db = "$dout/${id}.db";
unlink($db);

tie %hash, "DB_File", "$db", O_RDWR | O_CREAT, 0644, $DB_HASH
  or die "Cannot open file '$db': $!\n";
untie %hash;

sub unique_cells {
    my $str = shift @_;
    my %tmp;
    my @cs = split /,/, $str;
    foreach my $c (@cs) {
        $tmp{$c} = 1;
    }
    return ( keys %tmp );
}


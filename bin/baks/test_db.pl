#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use lib 'bin';
use TDCoop;

my $fi_cfg = $ARGV[0];

my %conf=parse_configure($fi_cfg);

while ( my ( $k, $v ) = each %conf ) {
    print "$k -> $v\n";
}
print "@{$conf{cells}}\n";


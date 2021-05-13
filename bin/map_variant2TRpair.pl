#!/usr/bin/perl

use warnings;
use strict;
use utf8;
use File::Basename;
use FindBin;
use lib "$FindBin::Bin/../lib";
use TDCoop;

if ( @ARGV < 3 ) {
    print STDERR "$ARGV[0] should be the configure file!\n";
    print STDERR "$ARGV[1] should be the cell name!\n";
    print STDERR "$ARGV[2] should be the variants file in BED format!\n";
    exit;
}

my $fi_cfg   = $ARGV[0];
my $cell     = $ARGV[1];
my $file_snp = $ARGV[2];

my %conf       = parse_configure($fi_cfg);
my $din_input  = $conf{dir_in};
my $din_output = $conf{dir_out};
my $dout       = "$din_output/07_variants2TRs";
mkdir $dout unless -d $dout;

print STDERR "Step 1/6: Gather information ...\n";
my %snp_bed2record = map_snp_bed3_to_record($file_snp);
my %pairs_3dcoop   = extract_tr_pairs_3dcoop(
    "$din_output/05_clusterone/08_results/${cell}_pairs.txt");
my %loop2trs = map_loop_to_trs("$din_output/02_intersection_bedpe/${cell}");
my @trs      = extract_trs("$din_input/peaks/${cell}");

print STDERR "Step 2/6: Map variants to TR peaks ...\n";
my $fo_s2p = "$dout/tmp_01_snp2peak.txt";
open my $O_S2P, '>', $fo_s2p
  or die "$0 : failed to open output file '$fo_s2p' : $!\n";
foreach my $tr (@trs) {
    my @snp2peak = map_snp_to_peak( "$file_snp",
        "$din_input/peaks/${cell}/${cell}_${tr}.bed" );
    foreach my $l (@snp2peak) {
        chomp($l);
        print $O_S2P "$l\t$tr\n";
    }
}
close $O_S2P or warn "$0 : failed to close output file '$fo_s2p' : $!\n";

print STDERR "Step 3/6: Map TR peaks to loop bins ...\n";
my @trs_s2p = `cat $fo_s2p | cut -f7 | sort | uniq`;
my $fo_p2b  = "$dout/tmp_02_peak2bin.txt";
open my $O_P2B, '>', $fo_p2b
  or die "$0 : failed to open output file '$fo_p2b' : $!\n";
foreach my $tr (@trs_s2p) {
    chomp($tr);
    my @peak2bin = map_peak_to_bin( "$tr", "$fo_s2p",
        "$din_output/01_intersection_bed/$cell/${cell}_${tr}_hic.bed" );
    foreach my $l (@peak2bin) {
        chomp($l);
        print $O_P2B "$l\t$tr\n";
    }
}
close $O_P2B or warn "$0 : failed to close output file '$fo_p2b' : $!\n";

print STDERR "Step 4/6: Map loop bins to chromatin loops ...\n";
my @trs_p2b = `cat $fo_p2b | cut -f7 | sort | uniq`;
my $fo_b2l  = "$dout/tmp_03_bin2loop.txt";
open my $O_B2L, '>', $fo_b2l
  or die "$0 : failed to open output file '$fo_b2l' : $!\n";
foreach my $tr (@trs_p2b) {
    chomp($tr);
    my @bin2loop = map_bin_to_loop( "$tr", "$fo_p2b",
        "$din_output/02_intersection_bedpe/${cell}/${cell}_${tr}.bedpe" );
    foreach my $l (@bin2loop) {
        print $O_B2L "$l\t$tr\n";
    }
}
close $O_B2L or warn "$0 : failed to close output file '$fo_b2l' : $!\n";

print STDERR
"Step 5/6: Combine information of variants, TR peaks, loop bins, and chromatin loops ...\n";
map_snp2peak2bin2loop();

print STDERR "Step 6/6: Report variants-associated TRs and TR paris ...\n";
report_association();

### functions ###

sub map_snp_bed3_to_record {
    my $fi = shift;
    my %hash;
    open my $I, '<', $fi or die "$0 : failed to open input file '$fi' : $!\n";
    while (<$I>) {
        chomp;
        my @f   = split /\t/;
        my $key = join "\t", @f[ 0, 1, 2 ];
        $hash{$key} = $_;
    }
    close $I or warn "$0 : failed to close input file '$fi' : $!\n";
    return (%hash);
}

sub extract_tr_pairs_3dcoop {
    my $fi = shift;
    my %hash;
    open my $I, '<', $fi or die "$0 : failed to open input file '$fi' : $!\n";
    while (<$I>) {
        unless (/^TF1/) {
            chomp;
            my @f   = split /\t/;
            my $key = join "-", sort @f[ 0, 1 ];
            $hash{$key} = $f[3];
        }
    }
    close $I or warn "$0 : failed to close input file '$fi' : $!\n";
    return (%hash);
}

sub map_loop_to_trs {
    my $dir = shift;
    my %hash;
    my @files = glob "$dir/*.bedpe";
    foreach my $fi (@files) {
        my $tf = basename($fi);
        $tf =~ s/${cell}_//;
        $tf =~ s/\.bedpe//;
        open my $I, '<', $fi
          or die "$0 : failed to open input file '$fi' : $!\n";
        while (<$I>) {
            chomp;
            my @f = split /\t/;
            my $k = join "\t", @f[ 0 .. 5 ];
            push @{ $hash{$k} }, $tf;
        }
        close $I or warn "$0 : failed to close input file '$fi' : $!\n";
    }
    return (%hash);
}

sub extract_trs {
    my $dir = shift;
    my @tfs;
    my @files = glob "$dir/*.bed";
    foreach my $f (@files) {
        my $bn = basename($f);
        $bn =~ s/${cell}_//;
        $bn =~ s/\.bed//;
        push @tfs, $bn;
    }
    return (@tfs);
}

sub map_snp_to_peak {
    my ( $fi_snp, $fi_tf ) = @_;
    my @lines =
`cut -f1-3 $fi_snp | bedtools sort -i stdin | bedtools intersect -a stdin -b $fi_tf -wa -wb | cut -f1-6`;
    return (@lines);
}

sub map_peak_to_bin {
    my ( $tf, $fi_s2p, $fi_bin ) = @_;
    my @lines =
`grep -w $tf $fi_s2p | cut -f4-6 | bedtools sort -i stdin | bedtools intersect -a stdin -b $fi_bin -wa -wb | cut -f1-6`;
    return (@lines);
}

sub map_bin_to_loop {
    my ( $tf, $fi_p2b, $fi_loop ) = @_;
    my %bins;
    open my $I_P2B, '<', $fi_p2b
      or die "$0 : failed to open input file '$fi_p2b' : $!\n";
    while (<$I_P2B>) {
        chomp;
        my @f = split /\t/;
        if ( $f[6] eq $tf ) {
            my $k = join "\t", @f[ 3, 4, 5 ];
            $bins{$k} = 1;
        }
    }
    close $I_P2B or warn "$0 : failed to close input file '$fi_p2b' : $!\n";

    my @lines;
    open my $I_L, '<', $fi_loop
      or die "$0 : failed to open input file '$fi_loop' : $!\n";
    while (<$I_L>) {
        chomp;
        my @f  = split /\t/;
        my $k1 = join "\t", @f[ 0, 1, 2 ];
        my $k2 = join "\t", @f[ 3, 4, 5 ];
        if ( exists $bins{$k1} ) {
            push @lines, join "\t", $k1, $k1, $k2;
        }
        if ( exists $bins{$k2} ) {
            push @lines, join "\t", $k2, $k1, $k2;
        }
    }
    close $I_L or warn "$0 : failed to close input file '$fi_loop' : $!\n";
    return (@lines);
}

sub map_snp2peak2bin2loop {
    my %snp2peak;
    my $fi_s2p = "$dout/tmp_01_snp2peak.txt";
    open my $I_S2P, '<', $fi_s2p
      or die "$0 : failed to open input file '$fi_s2p' : $!\n";
    while (<$I_S2P>) {
        chomp;
        my @f = split /\t/;
        my $k = join "\t", @f[ 0, 1, 2, 6 ];
        my $v = join "\t", @f[ 3, 4, 5, 6 ];
        $snp2peak{$k} = $v;
    }
    close $I_S2P or warn "$0 : failed to close input file '$fi_s2p' : $!\n";

    my %peak2bin;
    my $fi_p2b = "$dout/tmp_02_peak2bin.txt";
    open my $I_P2B, '<', $fi_p2b
      or die "$0 : failed to open input file '$fi_p2b' : $!\n";
    while (<$I_P2B>) {
        chomp;
        my @f = split /\t/;
        my $k = join "\t", @f[ 0, 1, 2, 6 ];
        my $v = join "\t", @f[ 3, 4, 5, 6 ];
        $peak2bin{$k} = $v;
    }
    close $I_P2B or warn "$0 : failed to close input file '$fi_p2b' : $!\n";

    my %bin2loop;
    my $fi_b2l = "$dout/tmp_03_bin2loop.txt";
    open my $I_B2L, '<', $fi_b2l
      or die "$0 : failed to open input file '$fi_b2l' : $!\n";
    while (<$I_B2L>) {
        chomp;
        my @f = split /\t/;
        my $k = join "\t", @f[ 0, 1, 2, 9 ];
        my $v = join "\t", @f[ 3 .. 8, 9 ];
        push @{ $bin2loop{$k} }, $v;
    }
    close $I_B2L or warn "$0 : failed to close input file '$fi_b2l' : $!\n";

    my $fo = "$dout/snp2peak2bin2loop.txt";
    open my $O, '>', $fo or die "$0 : failed to open output file '$fo' : $!\n";
    select $O;
    print
"snpChr\tsnpStart\tsnpEnd\tpeakChr\tpeakStart\tpeakEnd\tbinChr\tbinStart\tbinEnd\tloop1Chr\tloop1Start\tloop1End\tloop2Chr\tloop2Start\tloop2End\tTF\n";
    foreach my $snp ( sort keys %snp2peak ) {
        my $peak = $snp2peak{$snp};
        if ( exists $peak2bin{$peak} ) {
            my $bin = $peak2bin{$peak};
            if ( exists $bin2loop{$bin} ) {
                my @loops = @{ $bin2loop{$bin} };
                foreach my $loop (@loops) {
                    my $line = join "\t",  $snp, $peak, $bin, $loop;
                    my @f    = split /\t/, $line;
                    print join "\t",
                      @f[ 0, 1, 2, 4, 5, 6, 8, 9, 10, 12, 13, 14, 15, 16, 17,
                      18 ];
                    print "\n";
                }
            }
        }
    }
    close $O or warn "$0 : failed to close output file '$fo' : $!\n";
}

sub report_association {
    my @lines;
    my @cols_snp;
    my $fi = "$dout/snp2peak2bin2loop.txt";
    open my $I, '<', $fi or die "$0 : failed to open input file '$fi' : $!\n";
    while (<$I>) {
        unless (/^snpChr/) {
            chomp;
            my @f       = split /\t/;
            my $snp_bed = join "\t", @f[ 0, 1, 2 ];
            my $snp     = $snp_bed2record{$snp_bed};
            @cols_snp = split /\t/, $snp;
            my $loop = join "\t", @f[ 9 .. 14 ];
            my $tf   = $f[15];
            my @trs  = @{ $loop2trs{$loop} };

            foreach my $tr (@trs) {
                if ( $tr ne $tf ) {
                    my $pair = join "-", sort( $tr, $tf );
                    if ( exists $pairs_3dcoop{$pair} ) {
                        push @lines, join "\t", $snp, $tf, $pair, "3DCoop";
                    }
                    else {
                        push @lines, join "\t", $snp, $tf, $pair, "loop";
                    }
                }
            }
        }
    }
    close $I or warn "$0 : failed to close input file '$fi' : $!\n";

    my $fo = "$dout/variants2TRpairs.txt";
    open my $O, '>', $fo or die "$0 : failed to open output file '$fo' : $!\n";
    select $O;
    print "snpChr\tsnpStart\tsnpEnd";
    for ( my $i = 4 ; $i <= @cols_snp ; $i++ ) {
        print "\tsnpC$i";
    }
    print "\tTR\tTRpair\tdetectedBy\n";
    foreach my $l (@lines) {
        print "$l\n";
    }
    close $O or warn "$0 : failed to close output file '$fo' : $!\n";
}


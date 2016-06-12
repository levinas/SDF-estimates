#! /usr/bin/env perl

use strict;

my $usage = "Usage: $0 input_tab out_prefix contiguity_threshold\n\n";

my $input_file = shift @ARGV or die $usage;
my $out_prefix = shift @ARGV or die $usage;
my $contiguity = shift @ARGV || 3;

open(IN, "<$input_file") or die "Could not open $input_file";

open(TAB, ">>$out_prefix.tab") or die "Could not open $out_prefix.tab";
open(FNA, ">>$out_prefix.fna") or die "Could not open $out_prefix.fna";
open(FAA, ">>$out_prefix.faa") or die "Could not open $out_prefix.faa";

my $prev_contig;
my $nth_in_contig;
my $fna_buf;
my $faa_buf;
my $tab_buf;
my $i;
while (<IN>) {
    chomp;
    my @cols = split /\t/;
    my ($id, $contig, $nt, $aa, $nt_md5, $aa_md5) = @cols[0, 5, 14..17];
    if ($contig eq $prev_contig) {
        $nth_in_contig++;
        $fna_buf .= ">$id $nt_md5\n$nt\n";
        $faa_buf .= ">$id $aa_md5\n$aa\n";
        $tab_buf .= $_."\n";
        # print STDERR join("\t", $contig, $nth_in_contig) . "\n";
    } else {
        if ($nth_in_contig >= $contiguity) {
            print FNA $fna_buf;
            print FAA $faa_buf;
            print TAB $tab_buf;
        }
        $nth_in_contig = 0;
        $prev_contig = $contig;
        $fna_buf = '';
        $faa_buf = '';
        $tab_buf = '';
    }
    # last if $i++ > 100000;
}
close(IN);

close(FAA);
close(FNA);
close(TAB);

print STDERR "Added $input_file to table: $out_prefix.tab\n";

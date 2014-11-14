#! /usr/bin/env perl

use strict;

my $usage = "Usage: $0 SDF-data-set-ID assembler binner gene-caller input-dir output-prefix\n\n";

@ARGV == 6 or die $usage;

my ($sdf, $assembler, $binner, $caller, $input_dir, $output_prefix) = @ARGV;


my $inF = "$input_dir/$binner.$caller.tab";
open(IN, "<$inF") or die "Could not open $inF";

open(TAB, ">>$output_prefix.tab") or die "Could not open $output_prefix.tab";
open(FNA, ">>$output_prefix.fna") or die "Could not open $output_prefix.fna";
open(FAA, ">>$output_prefix.faa") or die "Could not open $output_prefix.faa";

while (<IN>) {
    chomp;
    my @cols = split /\t/;
    my $id = join('~', $sdf, $assembler, $binner, @cols[0..3]);
    my ($nt, $aa, $nt_md5, $aa_md5) = @cols[10, 11, 12, 13];
    print FNA ">$id $nt_md5\n$nt\n";
    print FAA ">$id $aa_md5\n$aa\n";
    print TAB join("\t", $id, $sdf, $assembler, $binner, @cols)."\n";
    # last;
}
close(IN);

close(FAA);
close(FNA);
close(TAB);

print "Added $input_dir to table: $output_prefix.tab\n";


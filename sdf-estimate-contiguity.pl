#! /usr/bin/env perl

use strict;

$|++;

my $usage = "Usage: $0 mg.prodigal.tab mg-DB36.k1.m8\n\n";

my ($f1, $f2) = @ARGV;
$f1 && $f2 or die $usage;

open(F1, "<$f1") or die "Could not open $f1";
open(F2, "<$f2") or die "Could not open $f2";

my $period = 100000;
my $min_cluster = 3;

# all following counts are about novel proteins in a contig with >= $min_cluster proteins
my $c1;       # total 
my $c2;       # all other proteins in the contig are novel
my $c3;       # all other proteins within $min_cluster distance are novel
my $c4;       # some proteins in the contig have defined functions
my $c5;       # some proteins within $min_cluster distance have defined functions

my $anno_old;
my $anno = get_anno_hit();

my $total = 0;
my $n = 0;
my $ctg;
my @list;
while (<F1>) {
    $n++;
    my ($fid, undef, undef, undef, undef, $contig) = split/\t/;
    # print join("\t", $fid, $contig) . "\n";

    if ($contig ne $ctg) {
        if (@list >= $min_cluster) {
            $total += @list;

            my $all_novel = 1;
            my $some_known = 0;
            for (@list) {
                $c1++ if $_ == 0;
                $all_novel = 0 if $_ > 0;
                $some_known = 1 if $_ == 2;
            }
            
            $c2 += @list if $all_novel;

            for (my $i = 0; $i < @list; $i++) {
                # print "i=$i,$list[$i]\n";
                next if $list[$i];
                my $novel = 1;
                my $known = 0;
                for (my $j = max(0, $i-$min_cluster); $j < min(scalar@list, $i+$min_cluster+1); $j++) {
                    # print "i=$i,j=$j\n";
                    my $jj = $list[$j];
                    $novel = 0 if $jj > 0;
                    $known = 1 if $jj == 2;
                }
                $c3++ if $novel;
                $c4++ if $some_known;
                $c5++ if $known;
            }

            # print join(",", @list, '|', $all_novel, $some_known) . "\n";
            # print join("\t", $total, $c1, $c2, $c3, $c4, $c5, s5f($c2/$c1), s5f($c3/$c1), s5f($c4/$c1), s5f($c5/$c1)) . "\n\n";
        }
        @list = ();
        $ctg = $contig;
    }

    if ($anno->[0] eq $fid) {
        push @list, $anno->[1];
        do {
            $anno_old = $anno; $anno = get_anno_hit();
        } while ($anno && $anno_old && $anno->[0] eq $anno_old->[0]); 
    } else {
        push @list, 0;
    }

    print join("\t", $n, $total, $c1, $c2, $c3, $c4, $c5, s5f($c2/$c1), s5f($c3/$c1), s5f($c4/$c1), s5f($c5/$c1)) . "\n" unless $n % $period;

    # last if $n > 30;
}

close(F2);
close(F1);


sub summarize_cluster {
    my ($list) = @_;
    
}

sub get_anno_hit {
    my $line = <F2>; chomp($line);
    my ($qid, $sid, $ident, $len, undef, undef, $q1, $q2, $s1, $s2, $eval, $bs) = split(/\t/, $line);
    my $cov = $len / (abs($s1-$s2) + 1);
    my $role = $sid =~ /(hypothetical|putative)/ ? 1 : 2;
    # print join("\t", $qid, $role, $ident, $cov, $bs) . "\n";
    return [$qid, $role, $ident, $cov, $bs];
}

sub s5f { sprintf("%.5f", $_[0]) }

sub min { $_[0] < $_[1] ? $_[0] : $_[1] }
sub max { $_[0] > $_[1] ? $_[0] : $_[1] }

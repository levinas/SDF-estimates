#! /usr/bin/env perl

use strict;

$|++;

my $usage = "Usage: $0 mg.prodigal.tab mg-DB36.k1.m8 mg-self.k1M.m8\n\n";

my ($f1, $f2, $f3) = @ARGV;
$f1 && $f2 && $f3 or die $usage;

open(F1, "<$f1") or die "Could not open $f1";
open(F2, "<$f2") or die "Could not open $f2";
open(F3, "<$f3") or die "Could not open $f3";

my $period = 10000;

my $c1;       # any hit against reference
my $c2;       # non-hypothetical hit
my $c3;       # confident non-hypothetical hit (identity 50%, len cov 70%, bit score 70 (roughly 1e-10))
my $c8;       # novel proteins in a group
my $c9;       # novel proteins with no internal match
my $n = 0;

my $anno_old;
my $self_old;
my $anno = get_anno_hit();
my $self = get_self_hit();
while (<F1>) {
    $n++;
    my ($fid) = split/\t/;
    # print $fid."\n";

    my $double = 0;

    while ($self eq $fid) {
        $double = 1 if $self_old eq $fid;
        $self_old = $self; $self = get_self_hit();
    }

    if ($anno->[0] eq $fid) {
        $c1++;
        $c2++ if $anno->[1];
        $c3++ if $anno->[1] && $anno->[2] >= 50 && $anno->[3] >= 0.7 && $anno->[4] >= 70;
        do {
            $anno_old = $anno; $anno = get_anno_hit();
        } while ($anno && $anno_old && $anno->[0] eq $anno_old->[0]); 
    } else {
        if ($double) {
            # print "$fid\n";
            $c8++;
        } else {
            $c9++;
        }
    }

    print join("\t", $n, $c1, $c2, $c3, $c8, $c9, s5f($c1/$n), s5f($c2/$n), s5f($c3/$n), s5f($c8/$n), s5f($c9/$n)) . "\n" unless $n % $period;
    # last if $n > 1000;
}

close(F3);
close(F2);
close(F1);


sub get_anno_hit {
    my $line = <F2>; chomp($line);
    my ($qid, $sid, $ident, $len, undef, undef, $q1, $q2, $s1, $s2, $eval, $bs) = split(/\t/, $line);
    my $cov = $len / (abs($s1-$s2) + 1);
    my $role = $sid =~ /(hypothetical|putative)/ ? 0 : 1;
    # print join("\t", $qid, $role, $ident, $cov, $bs) . "\n";
    return [$qid, $role, $ident, $cov, $bs];
}

sub get_self_hit {
    my $line = <F3>; 
    my ($qid) = split(/\t/, $line);
    return $qid;
}

sub s5f { sprintf("%.5f", $_[0]) }

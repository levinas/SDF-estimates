#! /usr/bin/env perl

use strict vars;
use Carp;
use Cwd 'abs_path';
use Data::Dumper;
use Getopt::Long;

use Digest::MD5 qw(md5_hex);

my $usage = <<"End_of_Usage";

usage: $0 [options] contigs.fa

       -d dir           - work directory (D = contigs_data)
       -o out           - output table (D = contigs.tab)
       -r               - redo computation
       -t int           - number of threads (D = 8)

End_of_Usage

my ($help, $algo, $nthread, $outdir, $redo, $callers);

GetOptions("h|help"        => \$help,
           "c|callers=s@"  => \$callers,
           "d|outdir=s"    => \$outdir,
           "r|redo"        => \$redo,
           "t|threads=i"   => \$nthread);


my $contigs = shift @ARGV or die $usage;

my $prefix = path_to_prefix($contigs);

$contigs = abs_path($contigs);
$nthread ||= 8;
$outdir ||= "$prefix\_data";

check_dependencies();

run("mkdir -p $outdir");
chdir($outdir);

my @binners = qw(GCbin);
my @callers = $callers ? @$callers : qw(prodigal);

# my @callers = qw(fgs prodigal);
# my @callers = qw(glimmer fgs prodigal prodigal_meta);


for my $binner (@binners) {
    my $run_binner = "bin_contigs_with_$binner";
    print "Binning $contigs with $binner..\n";
    &$run_binner($contigs) if defined &$run_binner;
    for my $caller (@callers) {
        next if -s "$binner.$caller.tab" && !$redo;
        print "  Calling genes with $caller..\n";
        my $run_caller = "call_genes_with_$caller";
        &$run_caller($binner) if defined &$run_caller;
    }
}

sub bin_contigs_with_GCbin {
    my ($contigs) = @_;
    sort_contigs($contigs);
    split_contigs('GCbin');
}

sub sort_contigs {
    my ($contigs) = @_;
    -s "contigs.fa"         or run("ln -s $contigs contigs.fa");
    -s "contigs.sorted.tab" or run("fa2tab.pl -r <contigs.fa |sort -k5n -k2nr >contigs.sorted.tab");
}

sub split_contigs {
    my ($binner) = @_;
    my $binD = "$binner.tbs";
    my $binF = "$binner.tb.list";
    return if -e $binF;
    run("mkdir -p $binD");
    # run("split -l 200 -a 3 contigs.sorted.tab $binD/tb.");
    run("split -l 5000 -a 3 contigs.sorted.tab $binD/tb.");
    my @files = grep { /tb\.[0-9a-z]+$/ } files_in_dir("$binD/tb.*");
    run("tab2fa.pl < $_ > $_.fa") for @files;
    run("echo -n '$_\t' |sed 's|split/||' >> $binF; cut -f 1 $_ |tr '\n' ',' >> $binF; echo >> $binF") for @files;
}

sub call_genes_with_glimmer {
    my ($binner) = @_;
    my $pattern = "$binner.tbs/tb.*.fa";
    my @files = files_in_dir($pattern);
    for my $f (@files) {
        run("run_glimmer3.pl -minlen=1000 666666.1 $f >$f.glimmer 2>$f.glimmer.log");
        process_called_genes_in_tb($f, 'glimmer', $binner);
    }
}


sub call_genes_with_fgs {
    my ($binner) = @_;
    my $pattern = "$binner.tbs/tb.*.fa";
    my @files = files_in_dir($pattern);
    for my $f (@files) {
        run("run_FragGeneScan.pl -genome $f -out $f.fgs -complete 0 -train illumina_10 -thread $nthread >$f.fgs.log");
        process_called_genes($f, 'fgs', $binner);
    }    
}

sub call_genes_with_prodigal {
    my ($binner) = @_;
    my $pattern = "$binner.tbs/tb.*.fa";
    my @files = files_in_dir($pattern);
    for my $f (@files) {
        run("prodigal -m -i $f -f gff -o $f.prodigal.gff -a $f.prodigal.faa -d $f.prodigal.fna 2>$f.prodigal.log");
        process_called_genes($f, 'prodigal', $binner);
    }    
}

sub call_genes_with_prodigal_meta {
    my ($binner) = @_;
    my $pattern = "$binner.tbs/tb.*.fa";
    my @files = files_in_dir($pattern);
    for my $f (@files) {
        run("prodigal -p meta -m -i $f -f gff -o $f.prodigal_meta.gff -a $f.prodigal_meta.faa -d $f.prodigal_meta.fna 2>$f.prodigal_meta.log");
        process_called_genes($f, 'prodigal_meta', $binner);
    }    
}

sub process_called_genes_in_tb {
    my ($f, $caller) = @_;
    my ($tab) = $f; $tab =~ s/\.fa//;
    my ($tb)  = ($f =~ /tb\.(\w+)\.fa/); 
    my %ctgs  = map { chomp; my ($id, $seq) = split/\t/; $id => $seq } `cut -f1,7 $tab`;
    my @lines = `cat $f.$caller`;
    my $dnaF  = "$f.$caller.fna"; 
    my $protF = "$f.$caller.faa";
    open(DNA, ">$dnaF") or die "Could not open $dnaF";
    for my $line (@lines) {
        chomp($line);
        my ($fid, $loc) = split(/\t/, $line);
        my ($contig) = $loc =~ /^(\S+)_\d+_\d+$/;
        my $seq = extract_seq(\%ctgs, $loc);
        my $sid = "$contig.tb.$tb.dna.$fid";
        print DNA join("\n", ">$sid $loc", $seq) . "\n";
    }
    close(DNA);
    run("transeq -table 11 -sequence $dnaF -outseq $protF 2>$f.transeq.log");
    run("ssed -i -r 's/_[0-9]+ / /g' $protF");
    run("ssed -i 's/.dna./.prot./g'  $protF");
        
    run("cat $dnaF  >>split/../$caller.fna");
    run("cat $protF >>split/../$caller.faa");
}


sub process_called_genes {
    my ($f, $caller, $prefix) = @_;
    my ($tab) = $f; $tab =~ s/\.fa//;
    my ($tb)  = ($f =~ /tb\.(\w+)\.fa/); 
    my %ctgs  = map { chomp; my ($id, $seq) = split/\t/; $id => $seq } `cut -f1,7 $tab`;
    my @lines = `grep -v "^#" $f.$caller.gff`;
    my $i;
    my $tabF = "$prefix.$caller.tab";
    open(TAB, ">>$tabF") or die "Could not open $tabF";
    for (@lines) {
        # http://useast.ensembl.org/info/website/upload/gff.html
        my ($contig, $caller_v, $feature, $start, $end, $score, $strand, $frame) = split /\t/;
        next unless $feature eq 'CDS' && $start && $end;
        ($contig) = split(/\s+/, $contig);
        $start += $frame if $strand eq '+';
        $end   -= $frame if $strand eq '-';
        my $cds_id = "CDS.". ++$i;
        my ($b, $e) = $strand eq '+' ? ($start, $end) : ($end, $start);
        my $loc = "$contig\_$b\_$e";
        my $nt = extract_seq(\%ctgs, $loc);
        my $gc = calc_gc($nt);
        my $aa = translate($nt);
        my $nt_md5 = md5_hex(uc $nt);
        my $aa_md5 = md5_hex(uc $aa);
        print TAB join("\t", "tb.$tb", $contig, $caller, $cds_id, $feature, $start, $end, $strand, $score, $gc, $nt, $aa, $nt_md5, $aa_md5)."\n";
    }
    close(TAB);
}

sub combine_features_from_tb {
    my ($f, $caller) = @_;
    my $dnaF  = "$f.$caller.fna"; 
    my $protF = "$f.$caller.faa";
    run("cat $dnaF  >>split/../$caller.fna");
    run("cat $protF >>split/../$caller.faa");
}

# sort-by-GC,len
# call_with_genemark,...
# 

sub files_in_dir {
    my ($path) = @_;
    my @files = map { chomp; $_ } `ls $path`;
}

sub check_dependencies {
    my $all = 1;
    my @progs = qw(fa2tab.pl tab2fa.pl
                   transeq
                   elph long-orfs extract build-icm glimmer3
                 );
    foreach my $prog (@progs) {
        my $found;
        foreach my $bin (split /:/, $ENV{PATH}) {
            $found = 1 if defined $bin && -d $bin && -x "$bin/$prog";
        }    
        $found or print STDERR "Not found: $prog\n";
        $all &&= $found;
    }
    $all or die "Please resolve the dependencies.\n";
}

sub path_to_prefix {
    my ($file) = @_;
    $file =~ s|^.*/||;
    $file =~ s/\.(fasta|fa)$//i;
    return $file;
}

sub run { system($_[0]) == 0 or confess("FAILED: $_[0]"); }

# ------------ SEED routines -------------

sub extract_seq {
    my($contigs, $loc) = @_;
    my($contig, $beg, $end, $contig_seq);
    my($plus, $minus);

    $plus = $minus = 0;
    my $strand = "";
    my @loc = split(/,/,$loc);
    my @seq = ();
    foreach $loc (@loc)
    {
        if ($loc =~ /^\S+_(\d+)_(\d+)$/)
        {
            if ($1 < $2)
            {
                $plus++;
            }
            elsif ($2 < $1)
            {
                $minus++;
            }
        }
    }
    if ($plus > $minus)
    {
        $strand = "+";
    }
    elsif ($plus < $minus)
    {
        $strand = "-";
    }

    foreach $loc (@loc)
    {
        if ($loc =~ /^(\S+)_(\d+)_(\d+)$/)
        {
            ($contig, $beg, $end) = ($1, $2, $3);

            my $len = length($contigs->{$contig});
            if (!$len)
            {
                carp "Undefined or zero-length contig $contig";
                return "";
            }

            if (($beg > $len) || ($end > $len))
            {
                carp "Region $loc out of bounds (contig len=$len)";
            }
            else
            {
                if (($beg < $end) || (($beg == $end) && ($strand eq "+")))
                {
                    push(@seq, substr($contigs->{$contig},$beg-1,($end+1-$beg)));
                }
                else
                {
                    $strand = "-";
                    push(@seq, complement_DNA_seq(substr($contigs->{$contig},$end-1,($beg+1-$end))));
                }
            }
        }
    }
    return join("",@seq);
}

sub complement_DNA_seq {
    my $seq = reverse shift;
    $seq =~ tr[ACGTUKMRSWYBDHVNacgtukmrswybdhvn]
              [TGCAAMKYSWRVHDBNtgcaamkyswrvhdbn];
    return $seq;
}

sub calc_gc {
    my ($nt) = @_;
    return undef unless $nt;
    my $len = length $nt;
    my $cnt = $nt =~ tr/GCgc//;
    return sprintf "%.3f", $cnt/$len;
}

# remove trailing *
sub translate {
    my( $dna,$code,$start ) = @_;
    my( $i,$j,$ln );
    my( $x,$y );
    my( $prot );

    if (! defined($code)) {
        $code = &standard_genetic_code;
    }
    $ln = length($dna);
    $prot = "X" x ($ln/3);
    $dna =~ tr/a-z/A-Z/;

    for ($i=0,$j=0; ($i < ($ln-2)); $i += 3,$j++) {
        $x = substr($dna,$i,3);
        if ($y = $code->{$x}) {
            substr($prot,$j,1) = $y;
        }
    }

    if (($start) && ($ln >= 3) && (substr($dna,0,3) =~ /^[GT]TG$/)) {
        substr($prot,0,1) = 'M';
    }

    # remove trailing *
    $prot =~ s/\*$//;

    return $prot;
}

sub standard_genetic_code {

    my $code = {};

    $code->{"AAA"} = "K";
    $code->{"AAC"} = "N";
    $code->{"AAG"} = "K";
    $code->{"AAT"} = "N";
    $code->{"ACA"} = "T";
    $code->{"ACC"} = "T";
    $code->{"ACG"} = "T";
    $code->{"ACT"} = "T";
    $code->{"AGA"} = "R";
    $code->{"AGC"} = "S";
    $code->{"AGG"} = "R";
    $code->{"AGT"} = "S";
    $code->{"ATA"} = "I";
    $code->{"ATC"} = "I";
    $code->{"ATG"} = "M";
    $code->{"ATT"} = "I";
    $code->{"CAA"} = "Q";
    $code->{"CAC"} = "H";
    $code->{"CAG"} = "Q";
    $code->{"CAT"} = "H";
    $code->{"CCA"} = "P";
    $code->{"CCC"} = "P";
    $code->{"CCG"} = "P";
    $code->{"CCT"} = "P";
    $code->{"CGA"} = "R";
    $code->{"CGC"} = "R";
    $code->{"CGG"} = "R";
    $code->{"CGT"} = "R";
    $code->{"CTA"} = "L";
    $code->{"CTC"} = "L";
    $code->{"CTG"} = "L";
    $code->{"CTT"} = "L";
    $code->{"GAA"} = "E";
    $code->{"GAC"} = "D";
    $code->{"GAG"} = "E";
    $code->{"GAT"} = "D";
    $code->{"GCA"} = "A";
    $code->{"GCC"} = "A";
    $code->{"GCG"} = "A";
    $code->{"GCT"} = "A";
    $code->{"GGA"} = "G";
    $code->{"GGC"} = "G";
    $code->{"GGG"} = "G";
    $code->{"GGT"} = "G";
    $code->{"GTA"} = "V";
    $code->{"GTC"} = "V";
    $code->{"GTG"} = "V";
    $code->{"GTT"} = "V";
    $code->{"TAA"} = "*";
    $code->{"TAC"} = "Y";
    $code->{"TAG"} = "*";
    $code->{"TAT"} = "Y";
    $code->{"TCA"} = "S";
    $code->{"TCC"} = "S";
    $code->{"TCG"} = "S";
    $code->{"TCT"} = "S";
    $code->{"TGA"} = "*";
    $code->{"TGC"} = "C";
    $code->{"TGG"} = "W";
    $code->{"TGT"} = "C";
    $code->{"TTA"} = "L";
    $code->{"TTC"} = "F";
    $code->{"TTG"} = "L";
    $code->{"TTT"} = "F";

    return $code;
}

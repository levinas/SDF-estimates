#! /usr/bin/env perl

use strict vars;
use Carp;
use Data::Dumper;
use Digest::MD5 qw(md5_hex);

use gjoseqlib;

my $usage = "Usage: $0 path\n\n";

my $path = shift @ARGV || '/bigdata/PUP/MEGAHIT';

my @dirs = grep { chomp; /^mgm\d/ && -d "$path/$_" } `ls $path`;

my $caller = 'prodigal';
my $outdir = "MGRAST";
my $assembler = 'MEGAHIT';

my @tabs;

for my $sample (@dirs) {
    my $fna = "$path/$sample/final.contigs.fa";
    my $gff = "$path/$sample/final.contigs.gene_calls.faa.coords.gff";
    -s $fna and -s $gff or next;

    my $tabF = process_called_genes_in_mgrast_sample($fna, $gff, $caller, $sample, $outdir);

    collect_mg_features($sample, $assembler, 'NObin', $caller, $tabF, 'mgrast');
}

sub collect_mg_features {
    my ($sdf, $assembler, $binner, $caller, $input_file, $output_prefix) = @_;

    open(IN, "<$input_file") or die "Could not open $input_file";

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

    print "Added $input_file to table: $output_prefix.tab\n";
}

sub process_called_genes_in_mgrast_sample {
    my ($fna, $gff, $caller, $sample, $outdir) = @_;
    $outdir ||= '.';
    my @seqs = gjoseqlib::read_fasta($fna);
    my %ctgs = map { $_->[0] => $_->[2] } @seqs;
    my @lines = `grep -v "^#" $gff`;
    print STDERR join("\t", $sample, scalar@lines)."\n";
    my $tabF = "$outdir/$sample.$caller.tab";
    open(TAB, ">$tabF") or die "Could not open $tabF";
    my $i;
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
        print TAB join("\t", 'tb.0', $contig, $caller, $cds_id, $feature, $start, $end, $strand, $score, $gc, $nt, $aa, $nt_md5, $aa_md5)."\n";
    }
    close(TAB);
    return $tabF;
}

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

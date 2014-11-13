
## Summary

1. List of which similarity blocks have been computed and an estimate for when the entire set might be completed
   - [ ] Revised size estimate for the N x N matrix and output size
   - [ ] Revised computational effort (cup hours) estimate for N x N matrix

2. Summary statistics on the metagenome assemblies for each block
   - [ ] Number of reads input
   - [ ] Number of contigs output and N50
   - [ ] Number of proteins called from each caller
   - [ ] Number of unique proteins in the block
   - [ ] Mean number of internally similar proteins at X cutoff (distribution)
   - [ ] Size distribution and GC ratios
   - [ ] Fraction with confident function assignments
   - [ ] Fraction with no similar hits in sample and DB36
   - [ ] Estimate of number of novel proteins

3. Contiguity and pathway related estimates
   - [ ] Fraction of proteins on a contig with > x orfs (2, ..., n)
   - [ ] Fraction estimated to be novel operons (all novel orfs)
   - [ ] Fraction estimated to linked to known pathways

4. Rates of discovery
   - [ ] Rate of novel proteins per megabase of assembled contigs (MoAC)
   - [ ] Rate of novel operons per MoAC
   - [ ] Expansion rate of known protein family members per MoAC
   - [ ] Global estimate of novel proteins
   - [ ] Global estimate of unique proteins

## Explanations for Estimates

##### 1.1 Revised size estimate for the N x N matrix and output size

DB36: 22,676,465 proteins
DB36-to-DB36: ~  hits (above 40 bits, k = 10<sup>6</sup>)

Soil9 (prodigal): 114,236,642 proteins
soil-to-soil: 67,798,709,206 hits (above 40 bits, k = 10<sup>6</sup>)

Notes from the [FastBLAST paper](http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0003589):

NR at the time: 6.53 M proteins, all-to-all blast would take ~126,000 CPU-hours.

> Our limit of 1/2,000 may not seem stringent, but some proteins are
> homologous to over 1/100 of all proteins (e.g., gi 16121781 has
> 107,873 homologs at 45 bits or above, which represents about 2% of
> Genbank NR).

##### 1.2 Revised computational effort (cup hours) estimate for N x N matrix

##### 2.1 Number of reads input
##### 2.2 Number of contigs output and N50
##### 2.3 Number of proteins called from each caller
##### 2.4 Number of unique proteins in the block
##### 2.5 Mean number of internally similar proteins at X cutoff (distribution)
##### 2.6 Size distribution and GC ratios
##### 2.7 Fraction with confident function assignments
##### 2.8 Fraction with no similar hits in sample and DB36
##### 2.9 Estimate of number of novel proteins

##### 3.1 Fraction of proteins on a contig with > x orfs (2, ..., n)
##### 3.2 Fraction estimated to be novel operons (all novel orfs)
##### 3.3 Fraction estimated to linked to known pathways

##### 4.1 Rate of novel proteins per megabase of assembled contigs (MoAC)
##### 4.2 Rate of novel operons per MoAC
##### 4.3 Expansion rate of known protein family members per MoAC
##### 4.4 Global estimate of novel proteins
##### 4.5 Global estimate of unique proteins

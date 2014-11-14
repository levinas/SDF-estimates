
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
Density: 

Soil9 (prodigal): 57,118,321 proteins
soil-to-soil: 67,798,709,206 hits (above 40 bits, k = 10<sup>6</sup>)
Density: 67B/(57M<sup>2</sup>) = 2.08e-5 

Notes from the [FastBLAST paper](http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0003589):

> "Our limit of 1/2,000 may not seem stringent, but some proteins are
> homologous to over 1/100 of all proteins (e.g., gi 16121781 has
> 107,873 homologs at 45 bits or above, which represents about 2% of
> Genbank NR)."

This protein alone would account for 0.0004 of the matrix density.

In the future, the matrix for reference NRs will be dominated by close strains.

Suppose:  
(1) we have 1000 taxonomic groups each containing 1000 close strains  
(2) two genomes from the same group share half of the proteins  
(3) two genomes from different groups share 1/5 of the proteins  
(4) 300 proteins (10% out of ~3,000 proteins in a genome) are universally shared  

This would mean a 1M x 1M matrix with density:
0.5 * 0.5<sup>2</sup> + 0.4 * 0.2<sup>2</sup> + 0.1 * 1<sup>2</sup> = 0.24

##### 1.2 Revised computational effort (cup hours) estimate for N x N matrix



FastBLAST paper:
> NR: 6.53 M proteins, all-to-all blast would take ~126,000 CPU-hours.

If diamond is [20,000 times faster than blast](http://ab.inf.uni-tuebingen.de/software/diamond/),
that means it would only take 126,000/20,000 = 6 CPU-hours for the all-to-all comparison of a 6M-protein NR.
It's definitely not that fast. 

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

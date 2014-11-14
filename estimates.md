
## Summary

1. List of which similarity blocks have been computed and an estimate for when the entire set might be completed
   - [x] Revised size estimate for the N x N matrix and output size  
         N = 1 B; output size: [1 PB, 1000 PB]
   - [x] Revised computational effort (cup hours) estimate for N x N matrix  
         2 million CPU-hours

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

#### 1.1 Revised size estimate for the N x N matrix and output size

N = 1 billion  
Output size: [1 PB, 1000 PB]  
Matrix density: [2e-6, 1e-4], ~2e-5 on average (bit score >= 40), ~2e-6 (bit score >= 55)

DB36: 11,338,218 proteins  
Query sample: 993,049 sequences (9% of all DB36)  
Sample-DB36 to DB36: 1,327,695,951 hits (above 40 bits, for each query keep as many as a million hits: k = 10<sup>6</sup>)  
Matrix density: 1.3B / (1M * 11M) = 1.18e-4  
Estimated output size for full all-to-all: ~1 TB

SEED NR in 2012: 22,291,704 unique proteins  
All-to-all blast: 736,909,504 hits (triangle, e-value below 1e-5 (roughly 54 bits))  
Matrix ensity: 736M / (22M * 22M/2) = 2.97e-6

[UniParc Oct-2014](http://www.uniprot.org/statistics/UniParc): 71,788,376 proteins  
Estiamted all-to-all output size: (71M/11M)<sup>2</sup> * 1 = ~42 TB

Soil9 (prodigal): 57,118,321 proteins (44,004,484 are unique)  
soil-to-soil: 67,798,709,206 hits (above 40 bits, k = 10<sup>6</sup>)  
Matrix density: 67B/(57M<sup>2</sup>) = 2.08e-5 (overestimating because of redundancy)  
Output size: 18 TB

Cow (~10% reads, prodigal), 29,717,714 proteins  



Notes from the [FastBLAST paper](http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0003589):

> "Our limit of 1/2,000 may not seem stringent, but some proteins are
> homologous to over 1/100 of all proteins (e.g., gi 16121781 has
> 107,873 homologs at 45 bits or above, which represents about 2% of
> Genbank NR)."

This protein alone would account for 0.0004 of the matrix density.

In the near future, the matrix density will go up as a small set of
overly sampled strains dominate the matrix. In the long run, the
density should come down if the sequencing bias diminishes.

Suppose:  
(1) we have 1000 taxonomic groups each containing 1000 close strains  
(2) each genome contains 3000 proteins of which 1/3 are unique  
(3) 300 proteins (10% out of ~3,000 proteins in a genome) are universally shared  
(4) two genomes from the same group share half of the proteins  
(5) two genomes from different groups share 1/5 of the proteins  

This would mean a 1B x 1B protein matrix with density:  
(0.5 * 0.5/1000 + 0.2 + 0.1) / 1000 = 3e-4


#### 1.2 Revised computational effort (cup hours) estimate for N x N matrix

Overall estimate: 2 million CPU-hours

Sample DB36 (9% query) vs DB36: 60 CPU-hours  
Estimated full DB36 vs DB36: 660 CPU-hours  

Soil9 all-to-all: 1500 CPU-hours

Estimated reference NR all-to-all: 660 * (100M/11)<sup>2</sup> = ~50K CPU-hours  
Estimated metagenome all-to-all: 1500 * (1B/57M)<sup>2</sup> * 2 = ~1M CPU-hours  
(x2 because most metagenome protein matrix are denser than soil)

FastBLAST paper:
> NR: 6.53 M proteins, all-to-all blast would take ~126,000 CPU-hours.

If diamond is [20,000 times faster than blast](http://ab.inf.uni-tuebingen.de/software/diamond/),
that means it would only take 126,000/20,000 = 6 CPU-hours for the all-to-all comparison of a 6M-protein NR.
It's definitely not that fast. 

#### 2.1 Number of reads input


#### 2.2 Number of contigs output and N50

#### 2.3 Number of proteins called from each caller

43,940,826 unique proteins called by Prodigal.
41,593,694 unique proteins called by FragGeneScan.

?? unique proteins called by both Prodigal and FragGeneScan.


#### 2.4 Number of unique proteins in the block
#### 2.5 Mean number of internally similar proteins at X cutoff (distribution)
#### 2.6 Size distribution and GC ratios
#### 2.7 Fraction with confident function assignments
#### 2.8 Fraction with no similar hits in sample and DB36
#### 2.9 Estimate of number of novel proteins

#### 3.1 Fraction of proteins on a contig with > x orfs (2, ..., n)
#### 3.2 Fraction estimated to be novel operons (all novel orfs)
#### 3.3 Fraction estimated to linked to known pathways

#### 4.1 Rate of novel proteins per megabase of assembled contigs (MoAC)
#### 4.2 Rate of novel operons per MoAC
#### 4.3 Expansion rate of known protein family members per MoAC
#### 4.4 Global estimate of novel proteins
#### 4.5 Global estimate of unique proteins

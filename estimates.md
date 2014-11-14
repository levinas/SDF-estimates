
## Summary

1. List of which similarity blocks have been computed and an estimate for when the entire set might be completed
   - [x] Revised size estimate for the N x N matrix and output size  
         N = 1 B; output size: [10 PB, 1000 PB]
		 
   - [x] Revised computational effort (cup hours) estimate for N x N matrix  
         2 million CPU-hours

2. Summary statistics on the metagenome assemblies for each block
   - [x] Number of reads input  
         soil9: 20 billion reads, 5 TB fastq  
		 cow: ~200 million reads, 150 GB MiSeq fastq
		 
   - [x] Number of contigs output and N50  
         soil9: 33 million, 21 GB, N50 = 550  
		 cow: 25 million, 16 GB, N50 = 439
		 
   - [x] Size distribution and GC ratios  
         soil9: GC%=62.2%, length: [300, 396K], average: 567  
		 cow: GC%=45.4%, length: [300, 913K], average: 540
		 
   - [x] Number of proteins called from each caller  
         soil9: 5% difference between Prodigal (44.0 M) and FragGeneScan (41.6 M)
		 
   - [x] Number of unique proteins in the block  
         soil9: 99.9% unique proteins, ~20% unique protein calls shared by Prodigal and FragGeneScan
		 
   - [x] Mean number of internally similar proteins at X cutoff (distribution)  
         [see two distributions below](.#26-mean-number-of-internally-similar-proteins-at-x-cutoff)

   - [x] Fraction with confident function assignments  
         soil9: 29%
		 
   - [x] Fraction with no similar hits in sample and DB36  
         soil9: 11%
   
   - [x] Estimate of number of novel proteins  
         soil9: 17 million (38%) against DB36  
		 For a larger reference DB, the fraction of novel soil proteins may be around 30%.

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
Output size: [10 PB, 1000 PB]  
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
Output size: ~8 TB

Cow (~10% reads, prodigal), 29,717,714 proteins  

Esitimated proteins for DB36 + KB-all + M5NR + UniParc = 100 M  
Esitimated proteins for Soil9 + ALER + ForestSoil + Cow Rumen + HMP + Other MG samples = 1000 M

Total proteins: 1 B for one gene caller

##### Matrix density

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
(x 2 because most metagenome protein matrix are denser than soil)

FastBLAST paper:
> NR: 6.53 M proteins, all-to-all blast would take ~126,000 CPU-hours.

If diamond is [20,000 times faster than blast](http://ab.inf.uni-tuebingen.de/software/diamond/),
that means it would only take 126,000/20,000 = 6 CPU-hours for the all-to-all comparison of a 6M-protein NR.
It's definitely not that fast. 

#### 2.1 Number of reads input

Soil9: 20 billion reads, 5 TB uncompressed fastq files

```
Iowa continuous corn:       2,055,601,258 reads,  196,708,830,076 bp
Iowa native prairie:        3,750,844,486 reads,  326,986,888,235 bp
Kansas cultivated corn:     2,677,222,281 reads,  272,276,185,410 bp
Wisconsin continous corn:   1,912,865,700 reads,  192,128,891,088 bp
Wisconsin native prairie:   2,098,317,886 reads,  211,016,377,208 bp
Wisconsin restored prairie:   347,778,670 reads,   52,514,579,170 bp
Great Prairie Total:       12,842,630,281 reads, 1251,631,751,187 bp

Arable soil:     ~1.0 B reads
BareFallow soil: ~5.0 B reads
Grassland soil:  ~3.8 B reads

Combined 9 soil sample total: 20 B reads, 5 TB
```

Cow rumen: ~200 M reads, 150 GB, MiSeq reads (~250 bp), ~5% of all JGI cow rumen data

#### 2.2 Number of contigs output and N50

Soil9: 33 M contigs, 21 GB fasta, N50 = 550  
Cow: 25 M contigs, 16 GB fasta, N50 = 439

Soil9: Number of Contigs=33,825,769, Total bp=19,162,572,560  
Cow: Number of Contigs=25,092,056, Total bp=13,551,414,369

#### 2.3 Size distribution and GC ratios

Soil9: Average length=566.5, Average GC%=62.2%, Shortest=300, Longest=396,247  
Cow: Average length=540.1, Average GC%=45.4%, Shortest=300, Longest=913,566

#### 2.4 Number of proteins called from each caller

Soil9: 5% difference between two callers  
Prodigal: 44,004,484 proteins (99.86% unique)  
FragGeneScan: 41,603,612 proteins (99.976% unique)

#### 2.5 Number of unique proteins in the block

Soil9: ~43 million

43,940,826 unique proteins called by Prodigal.  
41,593,694 unique proteins called by FragGeneScan.

8,626,555 (~20%) unique protein calls shared by both Prodigal and FragGeneScan.

#### 2.6 Mean number of internally similar proteins at X cutoff

Here's the breakdown of the percent identity of all 68 B hits from the
all-to-all soil9 diamond run.

| Identity % | Hits % | Aggregate % |
| :---: | ----: | ----: |
| 100   |   0.1 |   0.1 |
| 90-99 |   0.5 |   0.6 |
| 80-89 |   1.8 |   2.3 |
| 70-79 |   4.7 |   7.0 |
| 60-69 |  11.3 |  18.2 |
| 50-59 |  22.8 |  41.0 |
| 40-49 |  31.1 |  72.1 |
| 30-39 |  24.0 |  96.1 |
| 20-29 |   3.9 | 100.0 |


Here's the distribution of the numbers of hits for each protein in the
soil9 comparison. Proteins with one match are singletons as each protein
always matches itself.

```
Hits |Percent  Histogram
1    | 12.43%  ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
2    |  6.42%  ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
4    |  5.79%  ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
8    |  5.88%  ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
16   |  6.97%  ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
32   |  8.40%  ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
64   | 10.34%  ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
128  | 10.81%  ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
256  |  8.86%  ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
512  |  8.02%  ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
1024 |  7.09%  ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
2048 |  5.38%  ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
4096 |  2.34%  ▬▬▬▬▬▬▬▬▬▬▬▬
8192 |  0.96%  ▬▬▬▬▬
16384|  0.28%  ▬▬
```

#### 2.7 Fraction with confident function assignments

Mapping 44M soil9 proteins to DB36:

```
29.1%  has a confident function assigment
44.9%  matches a non-hypothetical protein
63.6%  matches any reference protein
```
Criteria for *confident function assignment*:
 * identity >= 50%
 * mapped region covers >= 70% sequence length
 * bit score >= 70 (roughly 1e-10)

Estimated based on a sample of 5 million proteins from soil9 (12%).

#### 2.8 Fraction with no similar hits in sample and DB36

```
13% proteins (5.7 million) has no similar hits in sample and DB36
25% proteins (11 million) has no hits in DB36 but has hits in sample
```

Estimated based on a sample of 5 million proteins from soil9 (12%).

#### 2.9 Estimate of number of novel proteins

Soil9: 16,846,818 proteins (38%) has no hits in DB36  
For a larger reference DB, the fraction of novel soil proteins may be around 30%.

Cow: 14,905,829 proteins (48%) has no hits in DB36  
It is puzzling that the cow rumen has a higher fraction of unmatched proteins.

#### 3.1 Fraction of proteins on a contig with > x orfs (2, ..., n)
#### 3.2 Fraction estimated to be novel operons (all novel orfs)
#### 3.3 Fraction estimated to linked to known pathways

#### 4.1 Rate of novel proteins per megabase of assembled contigs (MoAC)
#### 4.2 Rate of novel operons per MoAC
#### 4.3 Expansion rate of known protein family members per MoAC
#### 4.4 Global estimate of novel proteins
#### 4.5 Global estimate of unique proteins

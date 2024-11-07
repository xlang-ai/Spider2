# Copy Number Variations

Copy number variation (abbreviated CNV) refers to a circumstance in which the number of copies of a specific segment of DNA varies among different individuals’ genomes. The individual variants may be short or include thousands of bases. These structural differences may have come about through duplications, deletions or other changes and can affect long stretches of DNA. Such regions may or may not contain a gene(s).


## How Copy Number is Calculated

- For each case, we only care about the maximum copy number for a specific chromosome region;
- The overlap between a cytoband (a defined region on a chromosome) and a copy number segment is calculated using:
$$\text{overlap}=\frac{|\text{hg38\_stop}−\text{hg38\_start}| + |\text{end\_pos}−\text{start\_pos}| − |\text{hg38\_stop}−\text{end\_pos}| − |\text{hg38\_start}−\text{start\_pos}|}{2}$$
This measures how much of the copy number segment overlaps with the cytoband.
- The weighted average copy number for each cytoband is calculated by
$$\text{weighted copy number}=\frac{\sum (\text{overlap} \times \text{copy\_number})}{\sum \text{overlap}}$$
- Usually, the weighted average is rounded to produce the final copy mumber for each cytoband.


## Five Types of Genomic Alterations

Here’s an explanation of the five types of genomic alterations as represented by copy number variations (CNVs):

### Homozygous Deletions

- Definition: A homozygous deletion (often called a complete deletion) occurs when both copies of a gene are lost, resulting in a copy number of 0.
- Criteria: copy number = 0 identifies homozygous deletions.
- Biological Significance: Homozygous deletions can lead to the loss of tumor suppressor genes (genes that normally prevent cancer growth). Without these protective genes, cells can more easily progress toward cancer.


### Heterozygous Deletions

- Definition: A heterozygous deletion involves the loss of one copy of a gene, while the other copy remains intact. The copy number is 1 in this case.
- Criteria: copy number = 1 indicates a heterozygous deletion.
- Biological Significance: While less severe than a homozygous deletion, heterozygous deletions can still disrupt cellular function, especially if the remaining copy of the gene is mutated or insufficient to maintain normal function.


### Normal Diploid

- Definition: A normal diploid region has the standard two copies of a gene, as is typical in most healthy human cells.
- Criteria: copy number = 2 is used to identify regions with a normal diploid copy number.
- Biological Significance: Diploid regions are expected in non-cancerous cells and represent the baseline state of the genome, where two functional copies of each gene are present.


### Gains

- Definition: A gain is an increase in the number of copies of a region of the genome, but it's less severe than amplification. Gains involve having up to two additional copies beyond the diploid state, resulting in a copy number of 3.
- Criteria: One extra copy beyond the normal two.
- Biological Significance: Gains can be associated with increased expression of genes that promote cancer, but the effects may be more moderate compared to amplifications.


###  Amplifications

- Definition: Amplifications refer to regions of the genome where the number of copies of a gene is much higher than usual. For a diploid cell (a normal cell with two copies of each chromosome), amplifications involve having more than four copies of a gene.
- Criteria: There are at least 4 copies of a gene in the region.
- Biological Significance: Amplifications are common in cancer, where extra copies of oncogenes (genes that can promote cancer growth) may drive uncontrolled cell proliferation.


These categories help identify patterns in the genomic alterations present in cancer cells, providing insight into the molecular mechanisms driving cancer progression.
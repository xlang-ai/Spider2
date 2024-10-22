# Calculation Details for Gene Expression Analysis in TCGA-UCEC Project

## Introduction

This document outlines the calculation details for analyzing gene expression data related to the PARP1 gene in the TCGA-UCEC (The Cancer Genome Atlas - Uterine Corpus Endometrial Carcinoma) project. The analysis focuses on two groups of samples: those with significant mutations in the PARP1 gene and those without.

## Sample Selection

### Step 1: Identifying Tumor Samples

The analysis begins by identifying tumor samples from the `Somatic Mutation` dataset. Each tumor sample is represented by a unique barcode, referred to as `sample_barcode`.

**Mathematical Representation:**

Let \( S \) be the set of all sample barcodes from the Somatic Mutation dataset for TCGA-UCEC:

\[
S = \{ \text{sample\_barcode} \mid \text{project\_short\_name} = \text{TCGA-UCEC} \}
\]

### Step 2: Filtering RNA Expression Samples

Next, we filter the RNA expression dataset to include only samples that are present in the set of tumor samples identified in Step 1.

Let \( R \) be the set of RNA expression sample barcodes:

\[
R = \{ \text{sample\_barcode} \mid \text{sample\_barcode} \in S \text{ and } \text{project\_short\_name} = \text{TCGA-UCEC} \}
\]

### Step 3: Grouping by PARP1 Mutations

From the filtered RNA expression samples, we identify samples that have mutations in the PARP1 gene. We specifically focus on non-synonymous mutations, defined mathematically as follows:

Let \( M \) be the set of sample barcodes with significant PARP1 mutations:

\[
M = \{ \text{sample\_barcode} \mid \text{Hugo\_Symbol} = \text{PARP1} \text{ and } \text{One\_Consequence} \neq \text{synonymous\_variant} \text{ and } \text{sample\_barcode} \in R \}
\]

### Step 4: Identifying Samples Without PARP1 Mutations

We then define a second group of samples that do not have any mutations in PARP1. This group is represented as:

Let \( N \) be the set of sample barcodes without PARP1 mutations:

\[
N = R - M
\]

## Gene Expression Calculation

### Step 5: Calculating Gene Expression Metrics

For both groups \( M \) and \( N \), we calculate the following metrics for gene expression:

1. **Mean Expression**: The mean expression level for each gene \( g \) is computed as:

\[
\text{Mean}(g) = \frac{1}{n} \sum_{i=1}^{n} \log_{10}(\text{FPKM}_{i} + 1)
\]

where \( n \) is the number of samples in the group (either \( M \) or \( N \)), and \( \text{FPKM}_{i} \) is the FPKM value for sample \( i \).

2. **Variance of Expression**: The variance of expression levels is calculated as:

\[
\text{Variance}(g) = \frac{1}{n-1} \sum_{i=1}^{n} \left( \log_{10}(\text{FPKM}_{i} + 1) - \text{Mean}(g) \right)^2
\]

3. **Count of Samples**: The number of samples contributing to the mean and variance calculations is simply:

\[
\text{Count}(g) = n
\]

### Step 6: Aggregating Results

The final output consists of aggregated results for each gene in both groups, represented as follows:

For group \( M \):

\[
\text{Summary}(M) = \{ \text{gene\_name}, \text{Mean}(g), \text{Variance}(g), \text{Count}(g) \}
\]

For group \( N \):

\[
\text{Summary}(N) = \{ \text{gene\_name}, \text{Mean}(g), \text{Variance}(g), \text{Count}(g) \}
\]

## Conclusion

This document provides a comprehensive overview of the calculations performed to analyze gene expression data related to the PARP1 gene within the TCGA-UCEC project. The methodology includes sample selection based on mutation status, followed by the computation of statistical metrics for gene expression, which can aid in further biological interpretation and research.
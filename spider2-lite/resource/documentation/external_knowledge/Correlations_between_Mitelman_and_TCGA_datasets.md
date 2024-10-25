# Correlations between Mitelman and TCGA datasets

Check out other notebooks at our [Community Notebooks Repository](https://github.com/isb-cgc/Community-Notebooks)!

- **Title:** Correlations between Mitelman DB and TCGA datasets
- **Author:** Boris Aguilar
- **Created:** 04-23-2022
- **Purpose:** Compare Mitelman DB and TCGA datasets
- **URL:**

This notebook demonstrates how to compute correlations between Mitelman DB and TCGa datasets. The Mitelman DB is hosted by ISB-CGC and can be accessed at this URL: https://mitelmandatabase.isb-cgc.org/. This notebook replicates some of the analyses from the paper by Denomy et al: https://cancerres.aacrjournals.org/content/79/20/5181. Note, however that results are not replicated exactly as some of the underlying data has changed since publication.



# Calculate Frequency of Gains and Losses of breast cancer samples in Mitelman DB

We can use CytoConverter genomic coordinates to calculate the frequency of chromosomal gains and losses across a cohort of samples, e.g., across all breast cancer samples.

In [ ]:

```
# Set parameters for this query
cancer_type = 'BRCA' # Cancer type for TCGA
bq_project = 'mitelman-db'  # project name of Mitelman-DB BigQuery table
bq_dataset = 'prod' # Name of the dataset containing Mitelman-DB BigQuery tables
morphology = '3111' # Breast cancer
topology = '0401' # Adenocarcinoma
```

First, we identify all Mitelman DB cases related to the morphology and topology of interest.

This query was copied from the new feature of the MitelmanDB interface: View Overall Gain/Loss in chromosome.

```
case_query = """
# sql here
"""

# Run the query and put results in a data frame
mysql = ( "WITH " + case_query + """
SELECT *
FROM mitelman
""" )
final_mitelman = client.query(mysql).result().to_dataframe()
```

# Calculate Frequency of TCGA Copy Number Gains and Losses in breast cancer samples.

As a comparison to Mitelman DB gain and loss frequency, we can calculate similar frequencies using TCGA Copy Number data.

```
cnv_query = """
# sql here
"""

# Execute query and put results into a data frame
mysql = ( "WITH " + cnv_query + """
SELECT *
FROM tcga
""" )
cnv = client.query(mysql).result().to_dataframe()
```

|      | chromosome | cytoband_name | hg38_start | hg38_stop | total |  freq_amp | freq_gain | freq_homodel | freq_heterodel | freq_normal |
| ---: | ---------: | ------------: | ---------: | --------: | ----: | --------: | --------: | -----------: | -------------: | ----------: |
|    0 |       chr1 |          1p36 |          0 |  27600000 |  1067 | 11.902530 | 19.962512 |     0.000000 |      13.120900 |   55.014058 |
|    1 |       chr1 |          1p35 |   27600000 |  34300000 |  1067 | 13.214620 | 21.462043 |     0.000000 |       9.372071 |   55.951265 |
|    2 |       chr1 |          1p34 |   34300000 |  46300000 |  1067 | 18.650422 | 21.743205 |     0.000000 |       5.716963 |   53.889410 |
|    3 |       chr1 |          1p33 |   46300000 |  50200000 |  1067 | 17.525773 | 22.774133 |     0.000000 |       6.373008 |   53.327085 |
|    4 |       chr1 |          1p32 |   50200000 |  60800000 |  1067 | 19.119025 | 21.462043 |     0.000000 |       6.279288 |   53.139644 |
|  ... |        ... |           ... |        ... |       ... |   ... |       ... |       ... |          ... |            ... |         ... |
|  300 |       chrX |          Xq27 |  138900000 | 148000000 |  1067 | 24.273664 | 14.058107 |     0.281162 |      10.496720 |   50.890347 |
|  301 |       chrX |          Xq28 |  148000000 | 156040895 |  1067 | 23.711340 | 14.526710 |     0.187441 |      10.309278 |   51.265230 |
|  302 |       chrY |          Yp11 |          0 |  10400000 |  1067 |  0.374883 |  0.281162 |    96.438613 |       2.624180 |    0.281162 |
|  303 |       chrY |          Yq11 |   10400000 |  26600000 |  1067 |  0.281162 |  0.281162 |    97.469541 |       1.593252 |    0.374883 |
|  304 |       chrY |          Yq12 |   26600000 |  57227415 |  1067 |  0.281162 |  0.187441 |    96.438613 |       2.811621 |    0.281162 |

305 rows × 10 columns

# Compute Pearson correlation and p-values

The following query compute Pearson correlation for each chromosome comparing Mitelman DB frequencies with those computed from TCGA. Moreover, for each correlation values, its respective p-values is computed by using the BigQuery function `isb-cgc-bq.functions.corr_pvalue_current`. The minimum number of cases for correlation computation was 5.

```
mysql = ( "WITH " + case_query + "," + cnv_query + """
# sql here
""")
```

The non a value results (NaN) represent cases in which the computed frequencies of TCGA are zero for all the cytobands.

# Conclusion

This notebook demonstrated usage of the Mitelman BigQuery dataset, which includes CytoConverter chromosomal coordinate data, in combination with TCGA BigQuery tables for a comparative analysis. Specifically, the notebook computes correlation (Pearson) coefficients between gains and losses obtained with Mitelam DB and TCGA datasets.

We observed that the mayority (but not all) of the significan correlation shown in Denomy et al. paper (Table 1, https://doi.org/10.1158/0008-5472.CAN-19-0585) are also significan in this analysis.
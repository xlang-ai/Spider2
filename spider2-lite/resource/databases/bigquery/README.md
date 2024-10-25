# Bigquery database

We have gathered the schema metadata and descriptions for all the included BigQuery databases, enabling you to explore them in detail.

For example, the structure of `bigquery-public-data.idc_v15`

```
.
├── DDL.csv  # All table names and table DDL
├── dicom_all
├── dicom_derived_all.json
├── ...         
```

In each `xxx.json`,

- `table_name`: (str)
- `table_fullname`: (str) - project_id.dataset_id.table_id
- `column_names`: (List)
- `column_types`: (str) - A wide variety of column types
- `nested_column_names`: (str) -: The unnested columns of some nested dataset, such as Google Analytics 4 and Google Patents
- `nested_column_types`: (str) -: Column types of nested columns
- `description`: (str) -: Collected from bigquery metadata and the website of each apps.
- `sample_rows`: (str): Sample 5 rows for each table


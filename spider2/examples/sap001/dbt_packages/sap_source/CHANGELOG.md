# dbt_sap_source v0.1.0
🎉 Initial Release 🎉
- This is the initial release of this package. 

## 📣 What does this dbt package do?
This package is designed to enrich your Fivetran SAP data by doing the following:

- Materializes [SAP staging tables](https://fivetran.github.io/dbt_sap_source/#!/overview/sap_source/models/?g_v=1&g_e=seeds) that are intended to reproduce crucial source tables that funnel into important SAP reports.
- These tables will flow up to replicate SAP extractor reports that are provided in our transformation package, while not applying any renaming to the fields.
- These staging tables clean, test, and prepare your SAP data from [Fivetran's SAP connectors, like LDP SAP Netweaver](https://fivetran.com/docs/local-data-processing/requirements/source-and-target-requirements/sap-netweaver-requirements), [HVA SAP ECC](https://fivetran.com/docs/databases/sap-erp/high-volume-agent/hva-sap-ecc-hana) or [SAP ERP on HANA](https://fivetran.com/docs/databases/sap-erp/sap-erp-hana) for analysis by doing the following:
  - Name columns for consistency across all packages and for easier analysis
  - Adds freshness tests to source data
  - Adds column-level testing where applicable. For example, all primary keys are tested for uniqueness and non-null values.
- Generates a comprehensive data dictionary of your sap data through the [dbt docs site](https://fivetran.github.io/dbt_sap_source/).
- These tables are designed to work simultaneously with our [SAP transformation package](https://github.com/fivetran/dbt_sap).
- Currently the package supports Postgres, Redshift, BigQuery, Databricks, and Snowflake. Additionally, this package is designed to work with dbt versions [">=1.3.0", "<2.0.0"].

For more information refer to the [README](https://github.com/fivetran/dbt_sap_source/blob/main/README.md).

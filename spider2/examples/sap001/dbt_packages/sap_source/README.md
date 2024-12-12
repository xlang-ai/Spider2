<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_sap_source/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
</p>

# SAP Source dbt Package ([Docs](https://fivetran.github.io/dbt_sap_source/))
# 📣 What does this dbt package do?
- Materializes [SAP staging tables](https://fivetran.github.io/dbt_sap_source/#!/overview/sap_source/models/?g_v=1&g_e=seeds) that are intended to reproduce crucial source tables that funnel into important SAP reports.
- These tables will flow up to replicate SAP extractor reports that are provided in our transformation package, while not applying any renaming to the fields.
- These staging tables clean, test, and prepare your SAP data from [Fivetran's SAP connectors, like LDP SAP Netweaver](https://fivetran.com/docs/local-data-processing/requirements/source-and-target-requirements/sap-netweaver-requirements), [HVA SAP ECC](https://fivetran.com/docs/databases/sap-erp/high-volume-agent/hva-sap-ecc-hana) or [SAP ERP on HANA](https://fivetran.com/docs/databases/sap-erp/sap-erp-hana) for analysis by doing the following:
  - Name columns for consistency across all packages and for easier analysis
  - Adds freshness tests to source data
  - Adds column-level testing where applicable. For example, all primary keys are tested for uniqueness and non-null values.
- Generates a comprehensive data dictionary of your sap data through the [dbt docs site](https://fivetran.github.io/dbt_sap_source/).
- These tables are designed to work simultaneously with our [SAP transformation package](https://github.com/fivetran/dbt_sap).

# 🎯 How do I use the dbt package?
## Step 1: Prerequisites
To use this dbt package, you must have the following:
- At least one Fivetran of the following SAP connectors:
   - [LDP SAP Netweaver](https://fivetran.com/docs/local-data-processing/requirements/source-and-target-requirements/sap-netweaver-requirements)
   - [HVA SAP ECC](https://fivetran.com/docs/databases/sap-erp/high-volume-agent/hva-sap-ecc-hana)
   - [SAP ERP on HANA](https://fivetran.com/docs/databases/sap-erp/sap-erp-hana) 
- Within the connector, syncing the following respective tables into your destination:
   - bkpf
   - bseg
   - faglflexa
   - faglflext
   - kna1
   - lfa1
   - mara
   - pa0000
   - pa0001
   - pa0007
   - pa0008
   - pa0031
   - ska1
   - t001
   - t503
   - t880
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, **Databricks** destination.

### Databricks Dispatch Configuration
If you are using a Databricks destination with this package you will need to add the below (or a variation of the below) dispatch configuration within your `dbt_project.yml`. This is required for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

## Step 2: Install the package
If you  are **not** using the [SAP transformation package](https://github.com/fivetran/dbt_sap), include the following sap_source package version in your `packages.yml` file. 
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yaml
packages:
  - package: fivetran/sap_source
    version: [">=0.1.0", "<0.2.0"]
```

## Step 3: Define database and schema variables
By default, this package runs using your destination and the `sap` schema. If this is not where your SAP data is (for example, if your sap schema is named `sap_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
    sap_database: your_destination_name
    sap_schema: your_schema_name 
```

## (Optional) Step 4: Additional configurations 
<details><summary>Expand to view details</summary>
<br>

### Change the build schema
By default, this package builds the SAP staging models within a schema titled (`<target_schema>` + `_sap_source`) in your destination. If this is not where you would like your sap staging data to be written to, add the following configuration to your root `dbt_project.yml` file:

```yml
models:
    sap_source:
      +schema: my_new_schema_name # leave blank for just the target_schema
```
    
### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:
> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_sap_source/blob/main/dbt_project.yml) variable declarations to see the expected names.
    
```yml
vars:
    # For all SAP source tables
    sap_<default_source_table_name>_identifier: your_table_name 
```
</details>

## (Optional) Step 5: Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand to view details</summary>
<br>
    
Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core™ setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).
</details>

# 🔍 Does this package have dependencies?
This dbt package is dependent on the following dbt packages. Please be aware that these dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.

```yml
packages:
    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.3.0", "<2.0.0"]

    - package: dbt-labs/spark_utils
      version: [">=0.3.0", "<0.4.0"]
```
          
# 🙌 How is this package maintained and can I contribute?
## Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend that you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/sap_source/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_sap_source/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

## Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions! 

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) to learn how to contribute to a dbt package!

# 🏪 Are there any resources available?
- If you have questions or want to reach out for help, please refer to the [GitHub Issue](https://github.com/fivetran/dbt_sap_source/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
- Submit any questions you have about our packages [in our Fivetran dbt community](https://community.fivetran.com/t5/user-group-for-dbt/gh-p/dbt-user-group) so our Engineering team can provide guidance as quickly as possible!
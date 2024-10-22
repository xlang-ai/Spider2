<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_pendo_source/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
</p>

# Pendo Source dbt Package ([Docs](https://fivetran.github.io/dbt_pendo_source/))
# 📣 What does this dbt package do?
- Materializes [Pendo staging tables](https://fivetran.github.io/dbt_pendo_source/#!/overview/pendo_source/models/?g_v=1) which beverage data in the format described by [this ERD](https://fivetran.com/docs/applications/pendo/#schemainformation). These staging tables clean, test, and prepare your Pendo data from [Fivetran's connector](https://fivetran.com/docs/applications/pendo) for analysis by doing the following:
  - Name columns for consistency across all packages and for easier analysis
  - Adds freshness tests to source data
  - Adds column-level testing where applicable. For example, all primary keys are tested for uniqueness and non-null values.
- Generates a comprehensive data dictionary of your Pendo data through the [dbt docs site](https://fivetran.github.io/dbt_pendo_source/).
- These tables are designed to work simultaneously with our [Pendo transformation package](https://github.com/fivetran/dbt_pendo).

# 🎯 How do I use the dbt package?
## Step 1: Prerequisites
To use this dbt package, you must have the following:
- At least one Fivetran Pendo connector syncing data into your destination. 
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, or **Databricks** destination.

### Databricks Additional Configuration
If you are using a Databricks destination with this package you will need to add the below (or a variation of the below) dispatch configuration within your root `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```
## Step 2: Install the package
Include the following pendo_source package version in your `packages.yml` file.
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yaml
packages:
  - package: fivetran/pendo_source
    version: [">=0.5.0", "<0.6.0"]
```

## Step 3: Define database and schema variables
By default, this package runs using your destination and the `pendo` schema. If this is not where your Pendo data is (for example, if your Pendo schema is named `pendo_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
    pendo_database: your_database_name
    pendo_schema: your_schema_name 
```
## (Optional) Step 4: Additional configurations
<details><summary>Expand to view configurations</summary>

### Passthrough Columns

This package includes all of the source columns that are defined in the macros folder. We recommend including custom columns in this package because the staging models only bring in the standard columns for the `EVENT`, `FEATURE_EVENT`, `PAGE_EVENT`, `ACCOUNT_HISTORY`, and `VISITOR_HISTORY` tables.

You can add more columns using our passthrough column variables. These variables allow the passthrough columns to be aliased (`alias`) and casted (`transform_sql`) if you want, although it is not required. You can configure datatype casting by using a SQL snippet within the `transform_sql` key. You may add the desired SQL snippet while omitting the `as field_name` part of the casting statement - we rename this column with the alias attribute - and your custom passthrough columns will be casted accordingly.

Use the following format for declaring the respective passthrough variables:

```yml
vars:

  pendo__feature_event_pass_through_columns:
    - name:           "custom_field_name"
      alias:          "normal_field_name"
  pendo__page_event_pass_through_columns:
    - name:           "property_field_id"
      alias:          "new_name_for_this_field_id"
      transform_sql:  "cast(new_name_for_this_field as int64)"
    - name:           "this_other_field"
      transform_sql:  "cast(this_other_field as string)"
  pendo__event_pass_through_columns:
    - name:           "well_named_field_1"
  pendo__account_history_pass_through_columns:
    - name:           "well_named_field_2"
  pendo__visitor_history_pass_through_columns:
    - name:           "well_named_field_3"
```

### Changing the Build Schema

By default, this package builds the Pendo staging models within a schema titled (`<target_schema>` + `_stg_pendo`) in your target database. If this is not where you would like your Pendo staging data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
models:
  pendo_source:
    +schema: my_new_schema_name # leave blank for just the target_schema
```

### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:
> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_pendo_source/blob/main/dbt_project.yml) variable declarations to see the expected names.
    
```yml
vars:
  pendo_source:
    pendo_<default_source_table_name>_identifier: "your_table_name" 
```
#### 🚨 Snowflake Users 🚨
You may need to provide the case-sensitive spelling of your source tables that are also Snowflake reserved words.

In this package, this would apply to the `GROUP` source. If you are receiving errors for this source, include the following in your `dbt_project.yml` file:
```yml
vars:
  pendo_group_identifier: '"Group"' # as an example, must include this quoting pattern and adjust for your exact casing
```


**Note!** if you have sources defined in one of your project's yml files, for example if you have a yml file with a `sources` level like in the following example, the prior code will not work. 

Instead you will need to add the following where your group source table is defined in your yml:
```yml
sources:
  tables:
    - name: group 
      # Add the below
      identifier: GROUP # Or what your group table is named, being mindful of casing
      quoting:
        identifier: true
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
      version: [">=1.0.0", "<2.0.0"]

    - package: dbt-labs/spark_utils
      version: [">=0.3.0", "<0.4.0"]
```

# 🙌 How is this package maintained and can I contribute?
## Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend that you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/pendo_source/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_pendo_source/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

## Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions! 

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) to learn how to contribute to a dbt package!

# 🏪 Are there any resources available?
- If you have questions or want to reach out for help, please refer to the [GitHub Issue](https://github.com/fivetran/dbt_pendo_source/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
- Have questions or want to just say hi? Book a time during our office hours [on Calendly](https://calendly.com/fivetran-solutions-team/fivetran-solutions-team-office-hours) or email us at solutions@fivetran.com.

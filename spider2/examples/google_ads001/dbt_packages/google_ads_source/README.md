<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_google_ads_source/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_,<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
</p>

# Google Ads Source dbt Package ([Docs](https://fivetran.github.io/dbt_google_ads_source/))
# 📣 What does this dbt package do?
- Materializes [Google Ads staging tables](https://fivetran.github.io/dbt_google_ads_source/#!/overview/google_ads_source/models/?g_v=1&g_e=seeds) which leverage data in the format described by [this ERD](https://fivetran.com/docs/applications/google-ads#schemainformation). These staging tables clean, test, and prepare your Google Ads data from [Fivetran's connector](https://fivetran.com/docs/applications/google-ads) for analysis by doing the following:
  - Name columns for consistency across all packages and for easier analysis
  - Adds freshness tests to source data
  - Adds column-level testing where applicable. For example, all primary keys are tested for uniqueness and non-null values.
- Generates a comprehensive data dictionary of your google_ads data through the [dbt docs site](https://fivetran.github.io/dbt_google_ads_source/).
- These tables are designed to work simultaneously with our [Google Ads transformation package](https://github.com/fivetran/dbt_google_ads).

# 🎯 How do I use the dbt package?
## Step 1: Prerequisites
To use this dbt package, you must have the following:
- At least one Fivetran Google Ads connector syncing data into your destination. 
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, or **Databricks** destination.

### Databricks Dispatch Configuration
If you are using a Databricks destination with this package you will need to add the below (or a variation of the below) dispatch configuration within your `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils`.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

## Step 2: Install the package (skip if also using the `google_ads` transformation or `ad_reportin` combination package)
If you  are **not** using the [Google Ads transformation package](https://github.com/fivetran/dbt_google_ads) or the [Ad Reporting combination package](https://github.com/fivetran/dbt_ad_reporting), include the following package version in your `packages.yml` file. If you are installing the transform package, the source package is automatically installed as a dependency.
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

```yml
packages:
  - package: fivetran/google_ads_source
    version: [">=0.11.0", "<0.12.0"] # we recommend using ranges to capture non-breaking changes automatically
```
## Step 3: Define database and schema variables
By default, this package runs using your destination and the `google_ads` schema. If this is not where your Google Ads data is (for example, if your google_ads schema is named `google_ads_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
    google_ads_database: your_destination_name
    google_ads_schema: your_schema_name 
```

## (Optional) Step 4: Additional configurations
### Union multiple connectors
If you have multiple google_ads connectors in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. The package will union all of the data together and pass the unioned table into the transformations. You will be able to see which source it came from in the `source_relation` column of each model. To use this functionality, you will need to set either the `google_ads_union_schemas` OR `google_ads_union_databases` variables (cannot do both) in your root `dbt_project.yml` file:

```yml
vars:
    google_ads_union_schemas: ['google_ads_usa','google_ads_canada'] # use this if the data is in different schemas/datasets of the same database/project
    google_ads_union_databases: ['google_ads_usa','google_ads_canada'] # use this if the data is in different databases/projects but uses the same schema name
```
Please be aware that the native `source.yml` connection set up in the package will not function when the union schema/database feature is utilized. Although the data will be correctly combined, you will not observe the sources linked to the package models in the Directed Acyclic Graph (DAG). This happens because the package includes only one defined `source.yml`.

To connect your multiple schema/database sources to the package models, follow the steps outlined in the [Union Data Defined Sources Configuration](https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union_data-source) section of the Fivetran Utils documentation for the union_data macro. This will ensure a proper configuration and correct visualization of connections in the DAG.

### Passing Through Additional Metrics
By default, this package will select `clicks`, `impressions`, `cost`, `conversions`, `conversions_value`, and `view_through_conversions` from the source reporting tables to store into the staging models. If you would like to pass through additional metrics to the staging models, add the below configurations to your `dbt_project.yml` file. These variables allow for the pass-through fields to be aliased (`alias`) if desired, but not required. Use the below format for declaring the respective pass-through variables:

>**Note** Please ensure you exercised due diligence when adding metrics to these models. The metrics added by default (taps, impressions, and spend) have been vetted by the Fivetran team maintaining this package for accuracy. There are metrics included within the source reports, for example metric averages, which may be inaccurately represented at the grain for reports created in this package. You will want to ensure whichever metrics you pass through are indeed appropriate to aggregate at the respective reporting levels provided in this package.

```yml
vars:
    google_ads__account_stats_passthrough_metrics: 
      - name: "new_custom_field"
        alias: "custom_field"
    google_ads__campaign_stats_passthrough_metrics:
      - name: "this_field"
    google_ads__ad_group_stats_passthrough_metrics:
      - name: "unique_string_field"
        alias: "field_id"
    google_ads__keyword_stats_passthrough_metrics:
      - name: "that_field"
    google_ads__ad_stats_passthrough_metrics:
      - name: "other_id"
        alias: "another_id"
```

### Change the build schema
By default, this package builds the Google Ads staging models (10 views, 10 tables) within a schema titled (`<target_schema>` + `_google_ads_source`) in your destination. If this is not where you would like your google_ads staging data to be written to, add the following configuration to your root `dbt_project.yml` file:

```yml
models:
    google_ads_source:
      +schema: my_new_schema_name # leave blank for just the target_schema
```
    
### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable. This is not available when running the package on multiple unioned connectors.
> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_google_ads_source/blob/main/dbt_project.yml) variable declarations to see the expected names.
    
```yml
vars:
    google_ads_<default_source_table_name>_identifier: your_table_name 
```

## (Optional) Step 5: Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for more details</summary>

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
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend that you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/google_ads_source/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_google_ads_source/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

## Opinionated Decisions
In creating this package, which is meant for a wide range of use cases, we had to take opinionated stances on a few different questions we came across during development. We've consolidated significant choices we made in the [DECISIONLOG.md](https://github.com/fivetran/dbt_google_ads_source/blob/main/DECISIONLOG.md), and will continue to update as the package evolves. We are always open to and encourage feedback on these choices, and the package in general.

## Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions!

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) to learn how to contribute to a dbt package!

# 🏪 Are there any resources available?
- If you have questions or want to reach out for help, please refer to the [GitHub Issue](https://github.com/fivetran/dbt_google_ads_source/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
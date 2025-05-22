<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_qualtrics_source/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
</p>
 
# Qualtrics Source dbt Package ([Docs](https://fivetran.github.io/dbt_qualtrics_source/))
# 📣 What does this dbt package do?
<!--section="qualtrics_source_model"-->
- Materializes [Qualtrics staging tables](https://fivetran.github.io/dbt_qualtrics_source/#!/overview/github_source/models/?g_v=1) which leverage data in the format described by [this ERD](https://fivetran.com/docs/applications/qualtrics/#schemainformation). These staging tables clean, test, and prepare your Qualtrics data from [Fivetran's connector](https://fivetran.com/docs/applications/qualtrics) for analysis by doing the following:
  - Name columns for consistency across all packages and for easier analysis
    - Primary keys are renamed from `id` to `<table name>_id`. 
    - Foreign key names explicitly map onto their related tables (ie `owner_id` -> `owner_user_id`).
    - Datetime fields are renamed to `<event happened>_at`.
  - Adds column-level testing where applicable. For example, all primary keys are tested for uniqueness and non-null values.
- Generates a comprehensive data dictionary of your Qualtrics data through the [dbt docs site](https://fivetran.github.io/dbt_qualtrics_source/).
- These tables are designed to work simultaneously with our [Qualtrics transformation package](https://github.com/fivetran/dbt_qualtrics).

> This package does not apply freshness tests to source data due to the variability of survey cadences.
<!--section-end-->

# 🎯 How do I use the dbt package?
## Step 1: Prerequisites
To use this dbt package, you must have the following:
- At least one Fivetran Qualtrics connector syncing data into your destination. 
- A **BigQuery**, **Snowflake**, **Redshift**, **Databricks**, or **PostgreSQL** destination.

### Databricks dispatch configuration
If you are using a Databricks destination with this package, you must add the following (or a variation of the following) dispatch configuration within your `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

## Step 2: Install the package (skip if also using the `qualtrics` transformation package)
If you  are **not** using the [Qualtrics transformation package](https://github.com/fivetran/dbt_qualtrics), include the following package version in your `packages.yml` file. If you are installing the transform package, the source package is automatically installed as a dependency.
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yml
packages:
  - package: fivetran/qualtrics_source
    version: [">=0.2.0", "<0.3.0"] # we recommend using ranges to capture non-breaking changes automatically
```

## Step 3: Define database and schema variables
### Single connector
By default, this package runs using your destination and the `qualtrics` schema. If this is not where your Qualtrics data is (for example, if your Qualtrics schema is named `qualtrics_fivetran` and your `issue` table is named `usa_issue`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
    qualtrics_database: your_destination_name
    qualtrics_schema: your_schema_name 
```

### Union multiple connectors
If you have multiple Qualtrics connectors in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. The package will union all of the data together and pass the unioned table into the transformations. You will be able to see which source it came from in the `source_relation` column of each model. To use this functionality, you will need to set either the `qualtrics_union_schemas` OR `qualtrics_union_databases` variables (cannot do both) in your root `dbt_project.yml` file:

```yml
# dbt_project.yml

vars:
    qualtrics_union_schemas: ['qualtrics_usa','qualtrics_canada'] # use this if the data is in different schemas/datasets of the same database/project
    qualtrics_union_databases: ['qualtrics_usa','qualtrics_canada'] # use this if the data is in different databases/projects but uses the same schema name
```

Please be aware that the native `source.yml` connection set up in the package will not function when the union schema/database feature is utilized. Although the data will be correctly combined, you will not observe the sources linked to the package models in the Directed Acyclic Graph (DAG). This happens because the package includes only one defined `source.yml`.

To connect your multiple schema/database sources to the package models, follow the steps outlined in the [Union Data Defined Sources Configuration](https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union_data-source) section of the Fivetran Utils documentation for the union_data macro. This will ensure a proper configuration and correct visualization of connections in the DAG.

## Step 4: Enable Research Core Contacts API
By default, this package does not bring in data from the Qualtrics Research Core Contacts [Endpoint](https://api.qualtrics.com/10b9ce5afbf17-research-core-contacts), as this API is set to be [deprecated](https://api.qualtrics.com/10b9ce5afbf17-research-core-contacts#deprecation-notice) by Qualtrics. However, if you would like the package to bring in Core **contacts** and **mailing lists** in addition to XM Directory data, add the following configuration to your `dbt_project.yml`:

```yml
vars:
    qualtrics__using_core_contacts: False # default = True
    qualtrics__using_core_mailing_lists: False # default = True
```

## (Optional) Step 5: Additional configurations
<details><summary>Expand to view configurations</summary>
    
### Passing Through Additional Fields
This package includes all source columns defined in the macros folder. You can add more columns using our pass-through column variables. These variables allow for the pass-through fields to be aliased (`alias`) and casted (`transform_sql`) if desired, but not required. Datatype casting is configured via a sql snippet within the `transform_sql` key. You may add the desired sql while omitting the `as field_name` at the end and your custom pass-though fields will be casted accordingly. Use the below format for declaring the respective pass-through variables:

```yml
# dbt_project.yml

vars:
  qualtrics__survey_pass_through_columns:
    - name: "that_field"
      alias: "renamed_to_this_field"
      transform_sql: "cast(renamed_to_this_field as string)"
  qualtrics__directory_pass_through_columns:
    - name: "this_field"
  qualtrics__directory_contact_pass_through_columns:
    - name: "old_name"
      alias: "new_name"
  qualtrics__distribution_pass_through_columns:
    - name: "unique_string_field"
      transform_sql: "cast(unique_string_field as string)"
  qualtrics__core_contact_pass_through_columns: # relevant only if you have `core_*` tables enabled
    - name: "pass_this_through"
```

> Please create an [issue](https://github.com/fivetran/dbt_qualtrics_source/issues) if you'd like to see passthrough column support for other tables in the Qualtrics schema.

### Changing the Build Schema
By default this package will build the Qualtrics staging models within a schema titled (<target_schema> + `_qualtrics_source`) in your target database. If this is not where you would like your staging qualtrics data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

models:
  qualtrics_source:
    +schema: my_new_schema_name # leave blank for just the target_schema
```

### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:
> IMPORTANT: See this project's [`src_qualtrics.yml`](https://github.com/fivetran/dbt_qualtrics_source/blob/main/models/src_qualtrics.yml) for the default names.
    
```yml
# dbt_project.yml

vars:
    qualtrics_<default_source_table_name>_identifier: your_table_name 
```

</details>

## (Optional) Step 6: Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand to view details</summary>
<br>
    
Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).
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
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend that you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/qualtrics_source/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_qualtrics_source/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

## Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions! 

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) to learn how to contribute to a dbt package!

# 🏪 Are there any resources available?
- If you have questions or want to reach out for help, please refer to the [GitHub Issue](https://github.com/fivetran/dbt_qualtrics_source/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
- Have questions or want to be part of the community discourse? Create a post in the [Fivetran community](https://community.fivetran.com/t5/user-group-for-dbt/gh-p/dbt-user-group) and our team along with the community can join in on the discussion!

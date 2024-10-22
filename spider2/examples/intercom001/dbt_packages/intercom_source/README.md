<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_intercom_source/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_,<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
    <a alt="Fivetran Quickstart Compatible"
        href="https://fivetran.com/docs/transformations/dbt/quickstart">
        <img src="https://img.shields.io/badge/Fivetran_Quickstart_Compatible%3F-yes-green.svg" /></a>
</p>

# Intercom Source dbt Package ([Docs](https://fivetran.github.io/dbt_intercom_source/))

> NOTE: Our Intercom [model](https://github.com/fivetran/dbt_intercom) and [source](https://github.com/fivetran/dbt_intercom_source) dbt packages only work with connectors that were [created in July 2020](https://fivetran.com/docs/applications/intercom/changelog) or later. If you created your connector before July 2020, you must set up a new Intercom connector to use these dbt packages.

# 📣 What does this dbt package do?
<!--section="intercom_source_model"-->
- Materializes [Intercom staging tables](https://fivetran.github.io/dbt_intercom_source/#!/overview/intercom_source/models/?g_v=1&g_e=seeds) which leverage data in the format described by [this ERD](https://fivetran.com/docs/applications/intercom#schemainformation). These staging tables clean, test, and prepare your Intercom data from [Fivetran's connector](https://fivetran.com/docs/applications/intercom) for analysis by doing the following:
  - Names columns for consistency across all packages and for easier analysis
  - Adds freshness tests to source data
  - Adds column-level testing where applicable. For example, all primary keys are tested for uniqueness and non-null values.
- Generates a comprehensive data dictionary of your intercom data through the [dbt docs site](https://fivetran.github.io/dbt_intercom_source/).
- These tables are designed to work simultaneously with our [Intercom transformation package](https://github.com/fivetran/dbt_intercom).
<!--section-end-->

# 🎯 How do I use the dbt package?
## Step 1: Prerequisites
To use this dbt package, you must have the following:
- At least one Fivetran Intercom connector syncing data into your destination. 
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, or **Databricks** destination.
## Step 2: Install the package
Include the following intercom_source package version in your `packages.yml` file.
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yaml
packages:
  - package: fivetran/intercom_source
    version: [">=0.8.0", "<0.9.0"]
```
## Step 3: Define database and schema variables
By default, this package runs using your destination and the `intercom` schema. If this is not where your Intercom data is (for example, if your Intercom schema is named `intercom_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
    intercom_database: your_database_name
    intercom_schema: your_schema_name
```
## (Optional) Step 4: Additional configurations
<details><summary>Expand for configurations</summary>

### Passthrough Columns

This package includes all source columns defined in the macros folder. You can add more columns using our pass-through column variables. These variables allow for the pass-through fields to be aliased (`alias`) and casted (`transform_sql`) if desired, but not required. Datatype casting is configured via a sql snippet within the `transform_sql` key. You may add the desired sql while omitting the `as field_name` at the end and your custom pass-though fields will be casted accordingly. Use the below format for declaring the respective pass-through variables in your root `dbt_project.yml`.

```yml
vars:
  intercom__company_history_pass_through_columns: 
    - name: company_history_custom_field
      alias: new_name_for_this_field
      transform_sql: "cast(new_name_for_this_field as int64)"
    - name: this_other_field
      transform_sql: "cast(this_other_field as string)"
    - name: custom_monthly_spend
    - name: custom_paid_subscriber
  # a similar pattern can be applied to the rest of the following variables.
  intercom__contact_history_pass_through_columns:
  intercom__conversation_history_pass_through_columns:
```

### Disabling Models
This package includes Intercom's `company tag`, `contact tag`, `contact company`,`conversation tag`, `team` and `team admin` mapping tables.

It's possible that your connector does not sync every table that this package expects. If your syncs exclude certain tables, it is because you either don't use that functionality or actively excluded some tables from your syncs. To disable the corresponding functionality in the package, you must add the relevant variables. By default, the package assumes that all variables are true. Add variables for only the tables you want to disable. 

```yml
# dbt_project.yml

...
vars:
  intercom__using_contact_company: False
  intercom__using_company_tags: False
  intercom__using_contact_tags: False
  intercom__using_conversation_tags: False
  intercom__using_team: False
```

### Changing the Build Schema
By default this package will build the Intercom staging models within a schema titled (`<target_schema>` + `_stg_intercom`) in your target database. If this is not where you would like your Intercom staging data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

...
models:
    intercom_source:
      +schema: my_new_schema_name # leave blank for just the target_schema
```
</details>

## (Optional) Step 5: Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for more details</summary>

Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core™ setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).
    
# 🔍 Does this package have dependencies?
This dbt package is dependent on the following dbt packages. Please be aware that these dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.
```yml
packages:
    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]
```
### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:
> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_intercom_source/blob/main/dbt_project.yml) variable declarations to see the expected names.
    
```yml
vars:
    intercom_<default_source_table_name>_identifier: your_table_name
```
</details>

# 🙌 How is this package maintained and can I contribute?
## Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend that you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/intercom_source/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_intercom_source/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

## Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions! 

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) to learn how to contribute to a dbt package!

# 🏪 Are there any resources available?
- If you have questions or want to reach out for help, please refer to the [GitHub Issue](https://github.com/fivetran/dbt_intercom_source/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
- Have questions or want to be part of the community discourse? Create a post in the [Fivetran community](https://community.fivetran.com/t5/user-group-for-dbt/gh-p/dbt-user-group) and our team along with the community can join in on the discussion!

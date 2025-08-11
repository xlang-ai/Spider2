<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_salesforce_source/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_,<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
    <a alt="Fivetran Quickstart Compatibile"
        href="https://fivetran.com/docs/transformations/dbt/quickstart">
        <img src="https://img.shields.io/badge/Fivetran_Quickstart_Compatible%3F-yes-green.svg" /></a>
</p>

# Salesforce Source dbt Package ([Docs](https://fivetran.github.io/dbt_salesforce_source/)) 
# 📣 What does this dbt package do?
<!--section="salesforce_source_model"-->
- Cleans, tests, and prepares your Salesforce data from [Fivetran's connector](https://fivetran.com/docs/applications/salesforce) for analysis.
- Generates a comprehensive data dictionary of your Salesforce data via the [dbt docs site](https://fivetran.github.io/dbt_salesforce_source/)
- Materializes staging tables which leverage data in the format described by [this ERD](https://fivetran.com/docs/applications/salesforce/#schemainformation) and is intended to work simultaneously with our [Salesforce modeling package](https://github.com/fivetran/dbt_salesforce)
    - Refer to our [Docs site](https://fivetran.github.io/dbt_salesforce_source/#!/overview/salesforce_source/models/?g_v=1) for more details about these materialized models. 
- Optional: You can also bring in Salesforce history mode models utilizing [Fivetran's History Mode](https://fivetran.com/docs/core-concepts/sync-modes/history-mode).
<!--section-end-->

# 🎯 How do I use the dbt package?
## Step 1: Pre-Requisites
- **Connector**: Have the Fivetran Salesforce connector syncing data into your warehouse. 
- **Database support**: This package has been tested on **Postgres**, **Databricks**, **Redshift**, **Snowflake**, and **BigQuery**.

### Databricks Dispatch Configuration
If you are using a Databricks destination with this package you will need to add the below (or a variation of the below) dispatch configuration within your `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

### Database Incremental Strategies 
The history models in this package are materialized incrementally. We have chosen `insert_overwrite` as the default strategy for **BigQuery** and **Databricks** databases, as it is only available for these dbt adapters. For **Snowflake**, **Redshift**, and **Postgres** databases, we have chosen `delete+insert` as the default strategy.

`insert_overwrite` is our preferred incremental strategy because it will be able to properly handle updates to records that exist outside the immediate incremental window. That is, because it leverages partitions, `insert_overwrite` will appropriately update existing rows that have been changed upstream instead of inserting duplicates of them--all without requiring a full table scan.

`delete+insert` is our second-choice as it resembles `insert_overwrite` but lacks partitions. This strategy works most of the time and appropriately handles incremental loads that do not contain changes to past records. However, if a past record has been updated and is outside of the incremental window, `delete+insert` will insert a duplicate record. 😱
> Because of this, we highly recommend that **Snowflake**, **Redshift**, and **Postgres** users periodically run a `--full-refresh` to ensure a high level of data quality and remove any possible duplicates.

## Step 2: Installing the Package (skip if also using the `salesforce` transformation package)
If you are **not** using the [Salesforce transformation package](https://github.com/fivetran/dbt_salesforce), include the following `salesforce_source` package version in your `packages.yml`
> Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions, or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

```yaml
packages:
  - package: fivetran/salesforce_source
    version: [">=1.1.0", "<1.2.0"] # we recommend using ranges to capture non-breaking changes automatically
```
## Step 3: Configure Your Variables
### Database and Schema Variables (Using the standard Salesforce schema only)
By default, this package will run using your target database and the `salesforce` schema. If this is not where your Salesforce data is (perhaps your Salesforce schema is `salesforce_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
    salesforce_database: your_database_name
    salesforce_schema: your_schema_name
```

### Disabling Models
It is possible that your Salesforce connector does not sync every table that this package expects. If your syncs exclude certain tables, it is because you either don't use that functionality in Salesforce or actively excluded some tables from your syncs. 

To disable the corresponding functionality in this package, you must add the corresponding variable(s) to your `dbt_project.yml`, which are listed below. By default, that is if none of these variables are added, all variables are assumed to be true. Add variables only for the tables you would like to disable:

```yml
vars:
  salesforce__user_role_enabled: false # Disable if you do not have the user_role table
  salesforce__lead_enabled: false # Disable if you do not have the lead table
  salesforce__event_enabled: false # Disable if you do not have the event table
  salesforce__task_enabled: false # Disable if you do not have the task table
  salesforce__opportunity_line_item_enabled: false # Disable if you do not have the opportunity_line_item table
  salesforce__order_enabled: false # Disable if you do not have the order table
  salesforce__product_2_enabled: false # Disable if you do not have the product_2 table
```
The corresponding metrics from the disabled tables will not populate in the downstream models.

## (Optional) Step 4: Utilizing Salesforce History Mode records
If you have Salesforce [History Mode](https://fivetran.com/docs/using-fivetran/features#historymode) enabled for your connector, we now include support for the `account`, `contact`, and `opportunity` tables directly. This will allow you access to your historical data for these tables while taking advantage of incremental loads to help with compute.

### Configuring Your Salesforce History Mode Database and Schema Variables
Customers leveraging the Salesforce connector generally fall into one of two categories when taking advantage of History mode. They either have one connector that is syncing non-historical records and a separate connector that syncs historical records, **or** they have one connector that is syncing historical records. We have designed this feature to support both scenarios.

#### Option 1: Two connectors, one with non-historical data and another with historical data
If you are gathering data from both standard Salesforce as well as Salesforce History Mode, and your target database and schema differ as well, you will need to add an additional configuration for the history schema and database to your `dbt_project.yml`.

```yml
vars:
    salesforce_database: your_database_name # salesforce by default
    salesforce_schema: your_schema_name

    salesforce_history_database: your_history_database_name # salesforce_history by default
    salesforce_history_schema: your_history_schema_name
```

#### Option 2: One connector being used to sync historical data
Perhaps you may only want to use the Salesforce History Mode to bring in your data. Because the Salesforce schema is pointing to the default `salesforce` schema and database, you will want to add the following variable into your `dbt_project.yml` to point it to the `salesforce_history` equivalents.

```yml
vars:
    salesforce_database: your_history_database_name # salesforce by default
    salesforce_schema: your_history_schema_name

    salesforce_history_database: your_history_database_name # salesforce_history by default
    salesforce_history_schema: your_history_schema_name
```

**IMPORTANT**: If you utilize Option 2 and are also using the `dbt_salesforce` package, you must sync the equivalent enabled tables and fields in your history mode connector that are being brought into your end reports. Examine your data lineage and the model fields within the `salesforce` folder to see which tables and fields you are using and need to bring in and sync in the history mode connector. 

### Enabling Salesforce History Mode Models  
The History Mode models can get quite expansive since it will take in **ALL** historical records, so we've disabled them by default. You can enable the history models you'd like to utilize by adding the below variable configurations within your `dbt_project.yml` file for the equivalent models.

```yml
# dbt_project.yml

...
vars:
  salesforce__account_history_enabled: true  # False by default. Only use if you have history mode enabled and wish to view the full historical record of all your synced account fields.
  salesforce__contact_history_enabled: true  # False by default. Only use if you have history mode enabled and wish to view the full historical record of all your synced contact fields.
  salesforce__opportunity_history_enabled: true  # False by default. Only use if you have history mode enabled and wish to view the full historical record of all your synced opportunity fields.
```

Daily account, contact and opportunity history tables that are created from these history tables are available [in our `dbt_salesforce` package](https://github.com/fivetran/dbt_salesforce/blob/main/README.md#-what-does-this-dbt-package-do).


### Filter your Salesforce History Mode models with field variable conditionals
By default, these models are set to bring in all your data from Salesforce History, but you may be interested in bringing in only a smaller sample of historical records, given the relative size of the Salesforce History source tables.

We have set up where conditions in our staging models to allow you to bring in only the data you need to run in. You can set a global history filter that would apply to all of our staging history models in your `dbt_project.yml`:


```yml 
vars:
    global_history_start_date: 'YYYY-MM-DD' # The first `_fivetran_start` date you'd like to filter data on in all your history models.
```

If you'd like to apply model-specific conditionals, configure the below variables in your `dbt_project.yml`:

```yml 
vars:
    account_history_start_date: 'YYYY-MM-DD' # The first date in account history you wish to pull records from, filtering on `_fivetran_start`.
    contact_history_start_date: 'YYYY-MM-DD' # The first date in contact history you wish to pull records from, filtering on `_fivetran_start`.
    opportunity_history_start_date: 'YYYY-MM-DD' # The first date in opportunity history you wish to pull records from, filtering on `_fivetran_start`.
```

### IMPORTANT: How To Update Your History Models
To ensure maximum value for these history mode models and avoid messy historical data that could come with picking and choosing which fields you bring in, **all fields in your Salesforce history mode connector are being synced into your end staging models**. That means all custom fields you picked to sync are being brought in to the final models. [See our DECISIONLOG for more details on why we are bringing in all fields](https://github.com/fivetran/dbt_salesforce_source/blob/main/DECISIONLOG.md). 

To update the history mode models, you must follow these steps: 
1) Go to your Fivetran Salesforce History Mode connector page.
2) Update the fields that you are bringing into the model. 
3) Run a `dbt run --full-refresh` on the specific staging models you've updated to bring in these fields and all the historical data available with these fields.

We are aware that bringing in additional fields will be very process-heavy, so we do emphasize caution in making changes to your history mode connector. It would be best to batch as many field changes as possible before executing a `--full-refresh` to save on processing. 

## (Optional) Step 5: Additional Configurations
### Change the Build Schema
By default, this package builds the Salesforce staging models within a schema titled (<target_schema> + `_stg_salesforce`) in your target database. If this is not where you would like your Salesforce staging data to be written to, add the following configuration to your root `dbt_project.yml` file:

```yml
models:
    salesforce_source:
      +schema: my_new_schema_name # leave blank for just the target_schema
```

### Change the Source Table References
If an individual source table has a different name than expected, provide the name of the table as it appears in your warehouse to the respective variable:
> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_salesforce_source/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
# dbt_project.yml
...
config-version: 2
vars:
    salesforce_<default_source_table_name>_identifier: your_table_name
```  

### 🚨 Snowflake Users
If you do **not** use the default all-caps naming conventions for Snowflake, you may need to provide the case-sensitive spelling of your source tables that are also Snowflake reserved words. 

In this package, this would apply to the `ORDER` source. If you are receiving errors for this source, include the below identifier in your `dbt_project.yml` file:

```yml
vars:
    salesforce_order_identifier: "Order" # as an example, must include the double-quotes and correct case!
```  

### Adding Formula Fields as Pass Through Columns 
The source tables Fivetran syncs do not include formula fields. If your company uses them, you can generate them by referring to the [Salesforce Formula Utils](https://github.com/fivetran/dbt_salesforce_formula_utils) package. To pass through the fields, add the [latest version of the package](https://github.com/fivetran/dbt_salesforce_formula_utils#installing-the-macro-package). We recommend confirming your formula field models successfully populate before integrating with the Salesforce package. 

Include the following within your `dbt_project.yml` file:
```yml
# Using the opportunity source table as example, update the opportunity variable to reference your newly created model that contains the formula fields:
  salesforce_opportunity_identifier: "my_new_opportunity_formula_table"

# In addition, add the desired field names as pass through columns
  salesforce__opportunity_pass_through_columns:
    - name: "salesforce__opportunity_field"
      alias: "opportunity_field_x"
```

### Adding Passthrough Columns
This package includes all source columns defined in the `generate_columns.sql` macro.  You can add more columns using our passthrough column variables. These variables allow for the passthrough fields to be aliased (`alias`) and casted (`transform_sql`) if desired, but not required. Datatype casting is configured via a sql snippet within the `transform_sql` key. You may add the desired sql while omitting the `as field_name` at the end and your custom pass-though fields will be casted accordingly. Use the below format for declaring the respective pass-through variables:


```yml
# dbt_project.yml

...
vars:
  salesforce__account_pass_through_columns: 
    - name: "salesforce__account_field"
      alias: "renamed_field"
      transform_sql: "cast(renamed_field as string)"
  salesforce__contact_pass_through_columns: 
    - name: "salesforce__contact_field"
      alias: "contact_field_x"
  salesforce__event_pass_through_columns: 
    - name: "salesforce__event_field"
      transform_sql: "cast(salesforce__event_field as int64)"
  salesforce__lead_pass_through_columns: 
    - name: "salesforce__lead_field"
  salesforce__opportunity_pass_through_columns: 
    - name: "salesforce__opportunity_field"
      alias: "opportunity_field_x"
  salesforce__opportunity_line_item_pass_through_columns: 
    - name: "salesforce__opportunity_line_item_field"
      alias: "opportunity_line_item_field_x"
    - name: "field_name_2"
  salesforce__order_pass_through_columns: 
    - name: "salesforce__order_field"
      alias: "order_field_x"
    - name: "another_field"
      alias: "field_abc"
  salesforce__product_2_pass_through_columns: 
    - name: "salesforce__product_2_field"
      alias: "product_2_field_x"
  salesforce__task_pass_through_columns: 
    - name: "salesforce__task_field"
      alias: "task_field_x"
  salesforce__user_role_pass_through_columns: 
    - name: "salesforce__user_role_field"
      alias: "user_role_field_x"
  salesforce__user_pass_through_columns: 
    - name: "salesforce__user_field"
```

## (Optional) Step 6: Orchestrate your models with Fivetran Transformations for dbt Core™
Fivetran offers the ability for you to orchestrate your dbt project through the [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt) product. Refer to the linked docs for more information on how to setup your project for orchestration through Fivetran. 
# 🔍 Does this package have dependencies?
This dbt package is dependent on the following dbt packages. For more information on the below packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> **If you have any of these dependent packages in your own `packages.yml` I highly recommend you remove them to ensure there are no package version conflicts.**
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
The Fivetran team maintaining this package **only** maintains the latest version of the package. We highly recommend you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/salesforce_source/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_salesforce_source/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

## Contributions
These dbt packages are developed by a small team of analytics engineers at Fivetran. However, the packages are made better by community contributions! 

We highly encourage and welcome contributions to this package. Check out [this post](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package!

# 🏪 Are there any resources available?
- If you encounter any questions or want to reach out for help, please refer to the [GitHub Issue](https://github.com/fivetran/dbt_salesforce_source/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran, or would like to request a future dbt package to be developed, then feel free to fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
- Have questions or want to be part of the community discourse? Create a post in the [Fivetran community](https://community.fivetran.com/t5/user-group-for-dbt/gh-p/dbt-user-group) and our team along with the community can join in on the discussion!

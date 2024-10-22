<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_shopify_source/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
    <a alt="Fivetran Quickstart Compatible"
        href="https://fivetran.com/docs/transformations/dbt/quickstart">
        <img src="https://img.shields.io/badge/Fivetran_Quickstart_Compatible%3F-yes-green.svg" /></a>
</p>

# Shopify Source dbt Package ([Docs](https://fivetran.github.io/dbt_shopify_source/))
# 📣 What does this dbt package do?
<!--section="shopify_source_model"-->
- Materializes [Shopify staging tables](https://fivetran.github.io/dbt_shopify_source/#!/overview/github_source/models/?g_v=1) which leverage data in the format described by [this ERD](https://fivetran.com/docs/applications/shopify/#schemainformation). These staging tables clean, test, and prepare your Shopify data from [Fivetran's connector](https://fivetran.com/docs/applications/shopify) for analysis by doing the following:
  - Name columns for consistency across all packages and for easier analysis
  - Adds freshness tests to source data
  - Adds column-level testing where applicable. For example, all primary keys are tested for uniqueness and non-null values.
- Generates a comprehensive data dictionary of your Shopify data through the [dbt docs site](https://fivetran.github.io/dbt_shopify_source/).
- These tables are designed to work simultaneously with our [Shopify transformation package](https://github.com/fivetran/dbt_shopify).
<!--section-end-->

# 🎯 How do I use the dbt package?
## Step 1: Prerequisites
To use this dbt package, you must have the following:
- At least one Fivetran Shopify connector syncing data into your destination. 
- A **BigQuery**, **Snowflake**, **Redshift**, **Databricks**, or **PostgreSQL** destination.

### Databricks dispatch configuration
If you are using a Databricks destination with this package, you must add the following (or a variation of the following) dispatch configuration within your `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

## Step 2: Install the package (skip if also using the `shopify` transformation package)
If you  are **not** using the [Shopify transformation package](https://github.com/fivetran/dbt_shopify), include the following package version in your `packages.yml` file. 
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yml
packages:
  - package: fivetran/shopify_source
    version: [">=0.12.0", "<0.13.0"] # we recommend using ranges to capture non-breaking changes automatically
```

## Step 3: Define database and schema variables
### Single connector
By default, this package runs using your destination and the `shopify` schema. If this is not where your Shopify data is (for example, if your Shopify schema is named `shopify_fivetran` and your `issue` table is named `usa_issue`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
    shopify_database: your_destination_name
    shopify_schema: your_schema_name 
```

### Union multiple connectors
If you have multiple Shopify connectors in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. The package will union all of the data together and pass the unioned table into the transformations. You will be able to see which source it came from in the `source_relation` column of each model. To use this functionality, you will need to set either the `shopify_union_schemas` OR `shopify_union_databases` variables (cannot do both) in your root `dbt_project.yml` file:

```yml
# dbt_project.yml

vars:
    shopify_union_schemas: ['shopify_usa','shopify_canada'] # use this if the data is in different schemas/datasets of the same database/project
    shopify_union_databases: ['shopify_usa','shopify_canada'] # use this if the data is in different databases/projects but uses the same schema name
```

Please be aware that the native `source.yml` connection set up in the package will not function when the union schema/database feature is utilized. Although the data will be correctly combined, you will not observe the sources linked to the package models in the Directed Acyclic Graph (DAG). This happens because the package includes only one defined `source.yml`.

To connect your multiple schema/database sources to the package models, follow the steps outlined in the [Union Data Defined Sources Configuration](https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union_data-source) section of the Fivetran Utils documentation for the union_data macro. This will ensure a proper configuration and correct visualization of connections in the DAG.

## Step 4: Enable `fulfillment_event` data

The package takes into consideration that not every Shopify connector may have `fulfillment_event` data enabled. However, this table does hold valuable information that is leveraged in the `shopify__daily_shop` model in the transformation package. `fulfillment_event` data is **disabled by default**. 

Add the following variable to your `dbt_project.yml` file to enable the modeling of fulfillment events: 
```yml
# dbt_project.yml

vars:
    shopify_using_fulfillment_event: true # false by default
```

## Step 5: Setting your timezone
By default, the data in your Shopify schema is in UTC. However, you may want reporting to reflect a specific timezone for more realistic analysis or data validation. 

To convert the timezone of **all** timestamps in the package, update the `shopify_timezone` variable to your target zone in [IANA tz Database format](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones):
```yml
# dbt_project.yml

vars:
    shopify_timezone: "America/New_York" # Replace with your timezone
```

> **Note**: This will only **numerically** convert timestamps to your target timezone. They will however have a "UTC" appended to them. This is a current limitation of the dbt-date `convert_timezone` [macro](https://github.com/calogica/dbt-date#convert_timezone-column-target_tznone-source_tznone) we leverage. 

## (Optional) Step 6: Additional configurations
<details open><summary>Expand/Collapse configurations</summary>
    
### Passing Through Additional Fields
This package includes all source columns defined in the macros folder. You can add more columns using our pass-through column variables. These variables allow for the pass-through fields to be aliased (`alias`) and casted (`transform_sql`) if desired, but not required. Datatype casting is configured via a sql snippet within the `transform_sql` key. You may add the desired sql while omitting the `as field_name` at the end and your custom pass-though fields will be casted accordingly. Use the below format for declaring the respective pass-through variables:

```yml
# dbt_project.yml

vars:
  shopify_source:
    customer_pass_through_columns:
      - name: "customer_custom_field"
        alias: "customer_field"
    order_line_refund_pass_through_columns:
      - name: "unique_string_field"
        alias: "field_id"
        transform_sql: "cast(field_id as string)"
    order_line_pass_through_columns:
      - name: "that_field"
    order_pass_through_columns:
      - name: "sub_field"
        alias: "subsidiary_field"
    product_pass_through_columns:
      - name: "this_field"
        transform_sql: "cast(this_field as string)"
    product_variant_pass_through_columns:
      - name: "new_custom_field"
        alias: "custom_field"
```

### Changing the Build Schema
By default this package will build the Shopify staging models within a schema titled (<target_schema> + `_stg_shopify`) in your target database. If this is not where you would like your staging Shopify data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

models:
  shopify_source:
    +schema: my_new_schema_name # leave blank for just the target_schema
```

### Change the source table references (not available if unioning multiple Shopify connectors)
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:
> IMPORTANT: See this project's [`src_shopify.yml`](https://github.com/fivetran/dbt_shopify_source/blob/main/models/src_shopify.yml) for the default names.
    
```yml
# dbt_project.yml

vars:
    shopify_<default_source_table_name>_identifier: your_table_name 
```

If you are making use of the `shopify_union_schemas` or `shopify_union_databases` variables, the package will assume individual tables to have their default names.

### Disable Compiler Warnings for Empty Tables

Empty staging models are created in the Shopify schema dynamically if the respective source tables do not exist in your raw source schema. For example, if your shop has not incurred any refunds, you will not have a `refund` table yet until you do refund an order, and the package will create an empty `stg_shopify__refund` model.

The source package will will return **completely** empty staging models (ie `limit 0`) if these source tables do not exist in your Shopify schema yet, and the transform package will work seamlessly with these empty models. Once an anticipated source table exists in your schema, the source and transform packages will automatically reference the new populated table(s). ([example](https://github.com/fivetran/dbt_shopify_source/blob/main/models/tmp/stg_shopify__refund_tmp.sql)). 

The package will raise a compiler warning message that the respective staging model is empty. The compiler warning can be turned off by the end user by setting the `fivetran__remove_empty_table_warnings` variable to `True`.

```yml
# dbt_project.yml

vars:
    fivetran__remove_empty_table_warnings: true # default = false 
```

</details>

## (Optional) Step 7: Orchestrate your models with Fivetran Transformations for dbt Core™
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

    - package: calogica/dbt_date
      version: [">=0.9.0", "<1.0.0"]
      
    - package: dbt-labs/spark_utils
      version: [">=0.3.0", "<0.4.0"]
```
          
# 🙌 How is this package maintained and can I contribute?
## Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend that you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/shopify_source/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_shopify_source/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

## Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions! 

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) to learn how to contribute to a dbt package!

# 🏪 Are there any resources available?
- If you have questions or want to reach out for help, please refer to the [GitHub Issue](https://github.com/fivetran/dbt_shopify_source/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
- Have questions or want to be part of the community discourse? Create a post in the [Fivetran community](https://community.fivetran.com/t5/user-group-for-dbt/gh-p/dbt-user-group) and our team along with the community can join in on the discussion!

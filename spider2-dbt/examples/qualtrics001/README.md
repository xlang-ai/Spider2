<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_qualtrics/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
</p>

# Qualtrics Transformation dbt Package ([Docs](https://fivetran.github.io/dbt_qualtrics/))

## What does this dbt package do?

This package models Qualtrics data from [Fivetran's connector](https://fivetran.com/docs/applications/qualtrics). It uses data in the format described by [this ERD](https://fivetran.com/docs/applications/qualtrics#schemainformation) and builds off the output of our [Qualtrics source package](https://github.com/fivetran/dbt_qualtrics_source).

The main focus of the package is to transform the core object tables into analytics-ready models, including:
- A Response breakdown model which consolidates all survey responses joined with users, questions, and survey details.
- Overview models for Surveys, Contacts, Directories, and Distributions which help to understand the nuances of each and how they affect key survey aggregations.
- A daily breakdown model which provides a high level view of a variety of Qualtrics account metrics at a daily level.

<!--section="qualtrics_transformation_model"-->
The following table provides a detailed list of all tables materialized within this package by default.
> TIP: See more details about these tables in the package's [dbt docs site](https://fivetran.github.io/dbt_qualtrics/#!/overview/qualtrics).

| **Table**                 | **Description**                                                                                                    |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| [qualtrics__contact](https://fivetran.github.io/dbt_qualtrics/#!/model/model.qualtrics.qualtrics__contact)  | Detailed view of all contacts (from both the XM Directory and Research Core contact endpoints), ehanced with response and mailing list metrics.   |
| [qualtrics__daily_breakdown](https://fivetran.github.io/dbt_qualtrics/#!/model/model.qualtrics.qualtrics__daily_breakdown)        | Daily breakdown of activities related to surveys and distribution in your Qualtrics instance.            |
| [qualtrics__directory](https://fivetran.github.io/dbt_qualtrics/#!/model/model.qualtrics.qualtrics__directory)  | A directory is an address book for the entire brand and contains all of the contacts that have been added by your users. This model provides a detailed view of each directory, enhanced with metrics regarding contacts, survey distribution, and engagement.     |
| [qualtrics__distribution](https://fivetran.github.io/dbt_qualtrics/#!/model/model.qualtrics.qualtrics__distribution)  | Table of each survey's distribution (method of reaching out to XM directory contacts) enhanced with survey response and status metrics.    |
| [qualtrics__response](https://fivetran.github.io/dbt_qualtrics/#!/model/model.qualtrics.qualtrics__response)        | Breakdown of responses to individual questions (and their sub-questions). Enhanced with information regarding the survey-level response and the survey.            |
| [qualtrics__survey](https://fivetran.github.io/dbt_qualtrics/#!/model/model.qualtrics.qualtrics__survey)           | Detailed view of all surveys created, enhanced with distribution and response metrics.           |
<!--section-end-->

## How do I use the dbt package?

### Step 1: Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran Qualtrics connector syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **Databricks**, or **PostgreSQL** destination.

#### Databricks dispatch configuration
If you are using a Databricks destination with this package, you must add the following (or a variation of the following) dispatch configuration within your `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

### Step 2: Install the package
Include the following qualtrics package version in your `packages.yml` file:
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yml
packages:
  - package: fivetran/qualtrics
    version: [">=0.2.0", "<0.3.0"] # we recommend using ranges to capture non-breaking changes automatically
```

Do **NOT** include the `qualtrics_source` package in this file. The transformation package itself has a dependency on it and will install the source package as well.

### Step 3: Define database and schema variables
#### Single connector
By default, this package runs using your destination and the `qualtrics` schema. If this is not where your qualtrics data is (for example, if your qualtrics schema is named `qualtrics_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
# dbt_project.yml

vars:
    qualtrics_database: your_database_name
    qualtrics_schema: your_schema_name
```
#### Union multiple connectors
If you have multiple Qualtrics connectors in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. The package will union all of the data together and pass the unioned table into the transformations. You will be able to see which source it came from in the `source_relation` column of each model. To use this functionality, you will need to set either the `qualtrics_union_schemas` OR `qualtrics_union_databases` variables (cannot do both) in your root `dbt_project.yml` file:

```yml
# dbt_project.yml

vars:
    qualtrics_union_schemas: ['qualtrics_usa','qualtrics_canada'] # use this if the data is in different schemas/datasets of the same database/project
    qualtrics_union_databases: ['qualtrics_usa','qualtrics_canada'] # use this if the data is in different databases/projects but uses the same schema name
```

> NOTE: The native `source.yml` connection set up in the package will not function when the union schema/database feature is utilized. Although the data will be correctly combined, you will not observe the sources linked to the package models in the Directed Acyclic Graph (DAG). This happens because the package includes only one defined `source.yml`.

To connect your multiple schema/database sources to the package models, follow the steps outlined in the [Union Data Defined Sources Configuration](https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union_data-source) section of the Fivetran Utils documentation for the union_data macro. This will ensure a proper configuration and correct visualization of connections in the DAG.


### Step 4: Enable Research Core Contacts API
By default, this package does not bring in data from the Qualtrics Research Core Contacts [Endpoint](https://api.qualtrics.com/10b9ce5afbf17-research-core-contacts), as this API is set to be [deprecated](https://api.qualtrics.com/10b9ce5afbf17-research-core-contacts#deprecation-notice) by Qualtrics. However, if you would like the package to bring in Core **contacts** and **mailing lists** in addition to XM Directory data, add the following configuration to your `dbt_project.yml`:

```yml
vars:
    qualtrics__using_core_contacts: True # default = False
    qualtrics__using_core_mailing_lists: True # default = False
```

### (Optional) Step 5: Additional configurations
    
#### Passing Through Additional Fields
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

#### Changing the Build Schema
By default this package will build the Qualtrics staging models within a schema titled (<target_schema> + `_stg_qualtrics`) and the qualtrics final models within a schema titled (<target_schema> + `_qualtrics`) in your target database. If this is not where you would like your modeled qualtrics data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

models:
  qualtrics:
    +schema: my_new_schema_name # leave blank for just the target_schema
  qualtrics_source:
    +schema: my_new_schema_name # leave blank for just the target_schema
```

#### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:

> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_qualtrics_source/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
# dbt_project.yml

vars:
    qualtrics_<default_source_table_name>_identifier: your_table_name 
```


### (Optional) Step 6: Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for details</summary>
<br>
    
Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).
</details>


## Does this package have dependencies?
This dbt package is dependent on the following dbt packages. These dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.
    
```yml
packages:
    - package: fivetran/qualtrics_source
      version: [">=0.2.0", "<0.3.0"]

    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]

    - package: dbt-labs/spark_utils
      version: [">=0.3.0", "<0.4.0"]
```
## How is this package maintained and can I contribute?
### Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/qualtrics/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_qualtrics/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package.

## Are there any resources available?
- If you have questions or want to reach out for help, see the [GitHub Issue](https://github.com/fivetran/dbt_qualtrics/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
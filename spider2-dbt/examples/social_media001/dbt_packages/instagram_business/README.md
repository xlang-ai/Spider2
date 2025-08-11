<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_instagram_business/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_,<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
</p>

# Instagram Business Modeling dbt Package ([Docs](https://fivetran.github.io/dbt_instagram_business/))

# 📣 What does this dbt package do?

- Produces modeled tables that leverage Instagram Business data from [Fivetran's connector](https://fivetran.com/docs/applications/instagram-business) in the format described by [this ERD](https://fivetran.com/docs/applications/instagram-business#schemainformation) and builds off the output of our [Instagram Business source package](https://github.com/fivetran/dbt_instagram_business_source).

The main focus of the package is to transform the core social media object tables into analytics-ready models that can be easily unioned in to other social media platform packages to get a single view. This is aided by our [Social Media Reporting package](https://github.com/fivetran/dbt_social_media_reporting).

This package also generates a comprehensive data dictionary of your source and modeled Instagram Business data via the [dbt docs site](https://fivetran.github.io/dbt_instagram_business/).

You can also refer to the table below for a detailed view of all models materialized by default within this package.

| **model**                    | **description**                                                                                                        |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| [instagram_business__posts](https://github.com/fivetran/dbt_instagram_business/blob/main/models/instagram_business__posts.sql)         | Each record represents the daily performance of a post or story. |

# 🎯 How do I use the dbt package?
## Step 1: Pre-Requisites
You will need to ensure you have the following before leveraging the dbt package.
- **Connector**: Have the Fivetran Instagram Business connector syncing data into your warehouse. 
- **Database support**: This package has been tested on **BigQuery**, **Snowflake**, **Redshift**, **Databricks**, and **Postgres**. Ensure you are using one of these supported databases.

### Databricks Additional Configuration
If you are using a Databricks destination with this package you will need to add the below (or a variation of the below) dispatch configuration within your root `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```
 
## Step 2: Installing the Package
Include the following Instagram Business package version in your `packages.yml`
> Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions, or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

```yaml
packages:
  - package: fivetran/instagram_business
    version: [">=0.2.0", "<0.3.0"]
```

## Step 3: Configure Your Variables
### Database and Schema Variables
By default, this package will look for your Instagram Business data in the `instagram_business` schema of your [target database](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/configure-your-profile). If this is not where your Instagram Business data is, add the following configuration to your `dbt_project.yml` file:

```yml
vars:
    instagram_business_schema: your_schema_name
    instagram_business_database: your_database_name 
```

## (Optional) Step 4: Additional Configurations
<details><summary>Expand for configurations</summary>

### Change the Build Schema
By default, this package builds the GitHub staging models within a schema titled (<target_schema> + `_stg_instagram_business`) in your target database. If this is not where you would like your GitHub staging data to be written to, add the following configuration to your root `dbt_project.yml` file:

```yml
models:
    instagram_business:
      +schema: my_new_schema_name # leave blank for just the target_schema
    instagram_business_source:
      +schema: my_new_schema_name # leave blank for just the target_schema
```

### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:
> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_instagram_business_source/blob/main/dbt_project.yml) variable declarations to see the expected names.
    
```yml
vars:
    instagram_business_<default_source_table_name>_identifier: your_table_name 
```

### Unioning Multiple Instagram Business Connectors
If you have multiple Instagram Business connectors in Fivetran and want to use this package on all of them simultaneously, we have provided functionality to do so. The package will union all of the data together and pass the unioned table(s) into the final models. You will be able to see which source it came from in the `source_relation` column(s) of each model. To use this functionality, you will need to set either (**note that you cannot use both**) the `union_schemas` or `union_databases` variables:

```yml
# dbt_project.yml
...
config-version: 2
vars:
    ##You may set EITHER the schemas variables below
    instagram_business_union_schemas: ['instagram_business_one','instagram_business_two']

    ##Or may set EITHER the databases variables below
    instagram_business_union_databases: ['instagram_business_one','instagram_business_two']
```
</details>

## (Optional) Step 5: Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for configurations</summary>
<br>
Fivetran offers the ability for you to orchestrate your dbt project through the [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt) product. Refer to the linked docs for more information on how to setup your project for orchestration through Fivetran. 
</details>

# 🔍 Does this package have dependencies?
This dbt package is dependent on the following dbt packages. Please be aware that these dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.
    
```yml
packages:
    - package: fivetran/instagram_business_source
      version: [">=0.2.0", "<0.3.0"]

    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]

    - package: dbt-labs/spark_utils
      version: [">=0.3.0", "<0.4.0"]
```

# 🙌 How is this package maintained and can I contribute?
## Package Maintenance
The Fivetran team maintaining this package **only** maintains the latest version of the package. We highly recommend you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/instagram_business/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_instagram_business/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

## Contributions
These dbt packages are developed by a small team of analytics engineers at Fivetran. However, the packages are made better by community contributions! 

We highly encourage and welcome contributions to this package. Check out [this post](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package!

# 🏪 Are there any resources available?
- If you encounter any questions or want to reach out for help, please refer to the [GitHub Issue](https://github.com/fivetran/dbt_instagram_business/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran, or would like to request a future dbt package to be developed, then feel free to fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
- Have questions or want to just say hi? Book a time during our office hours [here](https://calendly.com/fivetran-solutions-team/fivetran-solutions-team-office-hours) or send us an email at solutions@fivetran.com.
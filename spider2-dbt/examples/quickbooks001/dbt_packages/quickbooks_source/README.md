<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_netsuite_source/blob/main/LICENSE">
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

# QuickBooks Source dbt Package ([Docs](https://fivetran.github.io/dbt_quickbooks_source/))

# 📖 Table of Contents 
- [📣 What does this dbt package do?](https://github.com/fivetran/dbt_quickbooks_source/#-what-does-this-dbt-package-do)
- [🎯 How do I use the dbt package?](https://github.com/fivetran/dbt_quickbooks_source/#-how-do-i-use-the-dbt-package) 
    - [Required steps](https://github.com/fivetran/dbt_quickbooks_source/#step-1-prerequisites)
    - [Additional options](https://github.com/fivetran/dbt_quickbooks_source/#optional-step-5-additional-configurations)
- [🔍 Does this package have dependencies?](https://github.com/fivetran/dbt_quickbooks_source/#-does-this-package-have-dependencies)
- [🙌 How is this package maintained and can I contribute?](https://github.com/fivetran/dbt_quickbooks_source/#-how-is-this-package-maintained-and-can-i-contribute)
    - [Package Maintenance](https://github.com/fivetran/dbt_quickbooks_source/#package-maintenance)
    - [Contributions](https://github.com/fivetran/dbt_quickbooks_source/#contributions)
- [🏪 Are there any resources available?](https://github.com/fivetran/dbt_quickbooks_source/#-are-there-any-resources-available)

# 📣 What does this dbt package do?
<!--section="quickbooks_source_model"-->
- Materializes [QuickBooks staging tables](https://fivetran.github.io/dbt_quickbooks_source/#!/overview/quickbooks_source/models/?g_v=1&g_e=seeds) which leverage data in the format described by [this ERD](https://fivetran.com/docs/applications/quickbooks#schemainformation). These staging tables clean, test, and prepare your QuickBooks data from
from [Fivetran's connector](https://fivetran.com/docs/applications/quickbooks) for analysis by doing the following:
    - Name columns for consistency across all packages and for easier analysis.
    - Adds descriptions to tables and columns that are synced using Fivetran
    - Models staging tables, which will be used in our transform package.
    - Adds column-level testing where applicable. For example, all primary keys are tested for uniqueness and non-null values. 
- Generates a comprehensive data dictionary of your source and modeled QuickBooks data through the [dbt docs site](https://fivetran.github.io/dbt_quickbooks_source/).
- These tables are designed to work simultaneously with our [QuickBooks transformation package](https://github.com/fivetran/dbt_quickbooks/)
<!--section-end-->

# 🎯 How do I use the dbt package?
## Step 1: Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran QuickBooks connector syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, or **Databricks** destination.

## Step 2: Install the package (skip if also using the `quickbooks` transformation package)
If you are **not** using the [QuickBooks transformation package](https://github.com/fivetran/dbt_quickbooks), include the following `quickbooks_source` package version in your `packages.yml` file.
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

```yaml
packages:
  - package: fivetran/quickbooks_source
    version: [">=0.9.0", "<0.10.0"] # we recommend using ranges to capture non-breaking changes automatically
```

## Step 3: Define database and schema variables
By default, this package runs using your destination and the `quickbooks` schema of your [target database](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/configure-your-profile). If this is not where your QuickBooks data is (for example, if your QuickBooks schema is named `quickbooks_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
    quickbooks_database: your_destination_name
    quickbooks_schema: your_schema_name 
```

## Step 4: Enabling/Disabling Models 
Your QuickBooks connector might not sync every table that this package expects. This package takes into consideration that not every QuickBooks account utilizes the same transactional tables.

By default, most variables' values are assumed to be `true` (with exception of  `using_purchase_order` and `using_credit_card_payment_txn`). In other to enable or disable the relevant functionality in the package, you will need to add the relevant variables:

```yml
vars:
  using_address: false # disable if you don't have addresses in QuickBooks
  using_bill: false # disable if you don't have bills or bill payments in QuickBooks
  using_credit_memo: false # disable if you don't have credit memos in QuickBooks
  using_department: false # disable if you don't have departments in QuickBooks
  using_deposit: false # disable if you don't have deposits in QuickBooks
  using_estimate: false # disable if you don't have estimates in QuickBooks
  using_invoice: false # disable if you don't have estimates in QuickBooks
  using_invoice_bundle: false # disable if you don't have estimates in QuickBooks
  using_journal_entry: false # disable if you don't have estimates in QuickBooks
  using_payment: false # disable if you don't have estimates in QuickBooks
  using_refund_receipt: false # disable if you don't have estimates in QuickBooks
  using_transfer: false # disable if you don't have estimates in QuickBooks
  using_vendor_credit: false # disable if you don't have estimates in QuickBooks
  using_sales_receipt: false # disable if you don't have estimates in QuickBooks
  using_purchase_order: true # enable if you want to include purchase orders in your staging models
  using_credit_card_payment_txn: true # enable if you want to include credit card payment transactions in your staging models
``` 

## (Optional) Step 5: Additional Configurations
<details><summary>Expand for configurations</summary>

### Unioning Multiple QuickBooks Connectors
If you have multiple QuickBooks connectors in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. The package will union all of the data together and pass the unioned table into the transformations. You will be able to see which source it came from in the `source_relation` column of each model. To use this functionality, you will need to set **either** (**note that you cannot use both**) the `quickbooks_union_schemas` or `quickbooks_union_databases` variables:

```yml
# dbt_project.yml
...
config-version: 2
vars:
  quickbooks_union_schemas: ['quickbooks_us','quickbooks_ca'] # use this if the data is in different schemas/datasets of the same database/project
  quickbooks_union_databases: ['quickbooks_us','quickbooks_ca'] # use this if the data is in different databases/projects but uses the same schema name
```

### Changing the Build Schema
By default this package will build the QuickBooks staging models within a schema titled (<target_schema> + `_quickbooks_staging`) in your target database. If this is not where you would like you QuickBooks staging data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

...
models:
    quickbooks_source:
        +schema: my_new_schema_name
```

### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:
> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_quickbooks_source/blob/main/dbt_project.yml) variable declarations to see the expected names.
    
```yml
vars:
    quickbooks_<default_source_table_name>_identifier: your_table_name 
```
</details>

## (Optional) Step 6: Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for details</summary>
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
```

# 🙌 How is this package maintained and can I contribute?
## Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend that you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/quickbooks_source/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_quickbooks_source/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

## Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions! 

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) to learn how to contribute to a dbt package!

# 🏪 Are there any resources available?
- If you have questions or want to reach out for help, please refer to the [GitHub Issue](https://github.com/fivetran/dbt_quickbooks_source/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
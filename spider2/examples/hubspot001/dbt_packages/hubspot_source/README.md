<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_hubspot_source/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_,<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
    <a alt="Fivetran Quickstart Compatible"
        href="https://fivetran.com/docs/transformations/dbt/quickstart">
        <img src="https://img.shields.io/badge/Fivetran_Quickstart_Compatible%3F-yes-green.svg" /></a>
</p>


# HubSpot Source dbt Package ([Docs](https://fivetran.github.io/dbt_hubspot_source/))
# 📣 What does this dbt package do?
<!--section="hubspot_source_model"-->
- Materializes [HubSpot staging tables](https://fivetran.github.io/dbt_hubspot_source/#!/overview/hubspot_source/models/?g_v=1) which leverage data in the format described by [this ERD](https://fivetran.com/docs/applications/hubspot#schemainformation). These staging tables clean, test, and prepare your HubSpot data from [Fivetran's connector](https://fivetran.com/docs/applications/hubspot) for analysis by doing the following:
  - Name columns for consistency across all packages and for easier analysis
  - Adds freshness tests to source data
  - Adds column-level testing where applicable. For example, all primary keys are tested for uniqueness and non-null values.
- Generates a comprehensive data dictionary of your HubSpot data through the [dbt docs site](https://fivetran.github.io/dbt_hubspot_source/).
- These tables are designed to work simultaneously with our [HubSpot transformation package](https://github.com/fivetran/dbt_hubspot).
<!--section-end-->

# 🎯 How do I use the dbt package?
## Step 1: Prerequisites
To use this dbt package, you must have the following:
- At least one Fivetran HubSpot connector syncing data into your destination. 
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, or **Databricks** destination.

### Databricks Dispatch Configuration
If you are using a Databricks destination with this package you will need to add the below (or a variation of the below) dispatch configuration within your `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

## Step 2: Install the package (skip if also using the `hubspot` transformation package)
Include the following hubspot_source package version in your `packages.yml` file.
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yaml
packages:
  - package: fivetran/hubspot_source
    version: [">=0.15.0", "<0.16.0"]
```
## Step 3: Define database and schema variables
By default, this package runs using your destination and the `hubspot` schema. If this is not where your HubSpot data is (for example, if your HubSpot schema is named `hubspot_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
    hubspot_database: your_destination_name
    hubspot_schema: your_schema_name 
```
## Step 4: Disable models for non-existent sources
When setting up your Hubspot connection in Fivetran, it is possible that not every table this package expects will be synced. This can occur because you either don't use that functionality in Hubspot or have actively decided to not sync some tables. Therefore we have added enable/disable configs in the `src.yml` to allow you to disable certain sources not present. Downstream models are automatically disabled as well. In order to disable the relevant functionality in the package, you will need to add the relevant variables in your root `dbt_project.yml`. By default, all variables are assumed to be `true` (with exception of `hubspot_service_enabled`, `hubspot_ticket_deal_enabled`, `hubspot_contact_merge_audit_enabled`, and `hubspot_merged_deal_enabled`). You only need to add variables for the tables different from default:

```yml
# dbt_project.yml
vars:
  # Marketing

  hubspot_marketing_enabled: false                        # Disables all marketing models
  hubspot_contact_enabled: false                          # Disables the contact models
  hubspot_contact_list_enabled: false                     # Disables contact list models
  hubspot_contact_list_member_enabled: false              # Disables contact list member models
  hubspot_contact_property_enabled: false                 # Disables the contact property models
  hubspot_contact_property_history_enabled: false         # Disables the contact property history models
  hubspot_email_event_enabled: false                      # Disables all email_event models and functionality
  hubspot_email_event_bounce_enabled: false
  hubspot_email_event_click_enabled: false
  hubspot_email_event_deferred_enabled: false
  hubspot_email_event_delivered_enabled: false
  hubspot_email_event_dropped_enabled: false
  hubspot_email_event_forward_enabled: false
  hubspot_email_event_click_enabled: false
  hubspot_email_event_open_enabled: false
  hubspot_email_event_print_enabled: false
  hubspot_email_event_sent_enabled: false
  hubspot_email_event_spam_report_enabled: false
  hubspot_email_event_status_change_enabled: false
  
  hubspot_contact_merge_audit_enabled: true               # Enables the use of the CONTACT_MERGE_AUDIT table (deprecated by Hubspot v3 API) for removing merged contacts in the final models.
                                                          # If false, ~~~contacts will still be merged~~~, but using the CONTACT.property_hs_calculated_merged_vids field (introduced in v3 of the Hubspot CRM API)
                                                          # Default = false
  # Sales

  hubspot_sales_enabled: false                            # Disables all sales models
  hubspot_company_enabled: false
  hubspot_company_property_history_enabled: false         # Disable the company property history models
  hubspot_deal_enabled: false
  hubspot_merged_deal_enabled: true                       # Enables the merged_deal table, which will be used to filter out merged deals from the final deal models. False by default. Note that `hubspot_sales_enabled` and `hubspot_deal_enabled` must not be set to False.
  hubspot_deal_company_enabled: false
  hubspot_deal_contact_enabled: false
  hubspot_deal_property_history_enabled: false            # Disables the deal property history tables
  hubspot_engagement_enabled: false                       # Disables all engagement models and functionality
  hubspot_engagement_contact_enabled: false
  hubspot_engagement_company_enabled: false
  hubspot_engagement_deal_enabled: false
  hubspot_engagement_call_enabled: false
  hubspot_engagement_email_enabled: false
  hubspot_engagement_meeting_enabled: false
  hubspot_engagement_note_enabled: false
  hubspot_engagement_task_enabled: false
  hubspot_owner_enabled: false
  hubspot_property_enabled: false                         # Disables property and property_option tables

  # Service
  hubspot_service_enabled: true                           # Enables all service models
  hubspot_ticket_deal_enabled: true
```

### Dbt-core Version Requirement for disabling freshness tests
If you are not using a source table that involves freshness tests, please be aware that the feature to disable freshness was only introduced in dbt-core 1.1.0. Therefore ensure the dbt version you're using is v1.1.0 or greater for this config to work.

## (Optional) Step 5: Additional configurations

### Adding passthrough columns
This package includes all source columns defined in the macros folder. Models by default only bring in a few fields for the `company`, `contact`, `deal`, and `ticket` tables. You can add more columns using our pass-through column variables. These variables allow for the pass-through fields to be aliased (`alias`) and casted (`transform_sql`) if desired, but not required. Datatype casting is configured via a sql snippet within the `transform_sql` key. You may add the desired sql while omitting the `as field_name` at the end and your custom pass-though fields will be casted accordingly. Use the below format for declaring the respective pass-through variables within your root `dbt_project.yml`.

```yml
vars:
  hubspot__deal_pass_through_columns:
    - name:           "property_field_new_id"
      alias:          "new_name_for_this_field_id"
      transform_sql:  "cast(new_name_for_this_field as int64)"
    - name:           "this_other_field"
      transform_sql:  "cast(this_other_field as string)"
  hubspot__contact_pass_through_columns:
    - name:           "wow_i_can_add_all_my_custom_fields"
  hubspot__company_pass_through_columns:
    - name:           "this_is_radical"
      alias:          "radical_field"
      transform_sql:  "cast(radical_field as string)"
  hubspot__ticket_pass_through_columns:
    - name:           "property_mmm"
      alias:          "mmm"
    - name:           "property_hs_bop"
      alias:          "bop"
```
**Alternatively**, if you would like to simply pass through **all columns** in the above four tables, add the following configuration to your dbt_project.yml. Note that this will override any `hubspot__[table_name]_pass_through_columns` variables.

```yml
vars:
  hubspot__pass_through_all_columns: true # default is false
```

### Adding property label
For `property_hs_*` columns, you can enable the corresponding, human-readable `property_option`.`label` to be included in the staging models. 

#### Important! 
- You must have sources `property` and `property_option` enabled to enable labels. By default, these sources are enabled.  
- You CANNOT enable labels if using `hubspot__pass_through_all_columns: true`.` 
- We recommend being selective with the label columns you add. As you add more label columns, your run time will increase due to the underlying logic requirements.

To enable labels for a given property, set the property attribute `add_property_label: true`, using the below format.

```yml
vars:
  hubspot__ticket_pass_through_columns:
    - name: "property_hs_fieldname"
      alias: "fieldname"
      add_property_label: true
```

Alternatively, you can enable labels for all passthrough properties by using variable `hubspot__enable_all_property_labels: true`, formatted like the below example. 

```yml
vars:
  hubspot__enable_all_property_labels: true # cannot use in conjunction with `hubspot__pass_through_all_columns: true`
  hubspot__ticket_pass_through_columns:
    - name: "property_hs_fieldname1"
    - name: "property_hs_fieldname2"
```
### Including calculated fields
This package also provides the ability to pass calculated fields through to the `company`, `contact`, `deal`, and `ticket` staging models. If you would like to add a calculated field to any of the mentioned staging models, you may configure the respective `hubspot__[table_name]_calculated_fields` variables with the `name` of the field you would like to create, and the `transform_sql` which will be the actual calculation that will make up the calculated field.
```yml
vars:
  hubspot__deal_calculated_fields:
    - name:          "deal_calculated_field"
      transform_sql: "existing_field * other_field"
  hubspot__company_calculated_fields:
    - name:          "company_calculated_field"
      transform_sql: "concat(name_field, '_company_name')"
  hubspot__contact_calculated_fields:
    - name:          "contact_calculated_field"
      transform_sql: "contact_revenue - contact_expense"
  hubspot__ticket_calculated_fields:
    - name:          "ticket_calculated_field"
      transform_sql: "total_field / other_total_field"
```
### Filter email events
When leveraging email events, HubSpot customers may take advantage of filtering out specified email events. These filtered email events are present within the `stg_hubspot__email_events` model and are identified by the `is_filtered_event` boolean field. By default, these events are included in the staging and downstream models generated from this package. However, if you wish to remove these filtered events you may do so by setting the `hubspot_using_all_email_events` variable to false. See below for exact configurations you may provide in your `dbt_project.yml` file:
```yml
vars:
  hubspot_using_all_email_events: false # True by default
```

### Change the build schema
By default, this package builds the hubspot staging models within a schema titled (`<target_schema>` + `_stg_hubspot`) in your destination. If this is not where you would like your hubspot staging data to be written to, add the following configuration to your root `dbt_project.yml` file:

```yml
models:
    hubspot_source:
      +schema: my_new_schema_name # leave blank for just the target_schema
```
    
### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:
> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_hubspot_source/blob/main/dbt_project.yml) variable declarations to see the expected names.
    
```yml
vars:
    hubspot_<default_source_table_name>_identifier: your_table_name 
```

## (Optional) Step 6: Orchestrate your models with Fivetran Transformations for dbt Core™

Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).

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
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend that you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/hubspot_source/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_hubspot_source/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

## Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions! 

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) to learn how to contribute to a dbt package!

# 🏪 Are there any resources available?
- If you have questions or want to reach out for help, please refer to the [GitHub Issue](https://github.com/fivetran/dbt_hubspot_source/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
- Have questions or want to be part of the community discourse? Create a post in the [Fivetran community](https://community.fivetran.com/t5/user-group-for-dbt/gh-p/dbt-user-group) and our team along with the community can join in on the discussion!

<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_fivetran_utils/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
</p>

# Fivetran Utility Macros for dbt

# 🤔 Who are the intended users of this package?
- The Fivetran team to leverage across Fivetran dbt packages
- It is not recommend to use this package outside of the Fivetran dbt packages

# 📣 What does this dbt package do?
This package includes macros that are used across Fivetran's dbt packages. This package is comprised primarily of cross database compatible macros and macros specific for dbt package maintenance. See the **Contents** below for the macros available within this package.

# 🎯 How do I use the dbt package?
## Step 1: Installing the Package
Include the following fivetran_utils package version in your `packages.yml` if you do not have any other Fivetran dbt packag dependencies. Please note that this package is installed by default within **all** Fivetran dbt packages.
> Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions, or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yaml
packages:
  - package: fivetran/fivetran_utils
    version: [">=0.4.0", "<0.5.0"]
```
## Step 2: Using the Macros
Call any of the below listed macros within the **Contents** section in your models. See the specific details for each macro below.

Additionally, in order to use macros from this package with other utility packages, you can set a [`dispatch` config](https://docs.getdbt.com/reference/project-configs/dispatch-config) in your root `dbt_project.yml`. For example:

```yml
dispatch:
  - macro_namespace: fivetran_utils
    search_order: ['spark_utils', 'fivetran_utils']
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'fivetran_utils', 'dbt_utils']
```

----
# 📋 Contents

- [Fivetran Utility Macros for dbt](#fivetran-utility-macros-for-dbt)
- [🤔 Who are the intended users of this package?](#-who-are-the-intended-users-of-this-package)
- [📣 What does this dbt package do?](#-what-does-this-dbt-package-do)
- [🎯 How do I use the dbt package?](#-how-do-i-use-the-dbt-package)
  - [Step 1: Installing the Package](#step-1-installing-the-package)
  - [Step 2: Using the Macros](#step-2-using-the-macros)
- [📋 Contents](#-contents)
  - [Tests and helpers](#tests-and-helpers)
    - [collect\_freshness (source)](#collect_freshness-source)
    - [seed\_data\_helper (source)](#seed_data_helper-source)
    - [snowflake\_seed\_data (source)](#snowflake_seed_data-source)
  - [Cross-database compatibility](#cross-database-compatibility)
    - [array\_agg (source)](#array_agg-source)
    - [ceiling (source)](#ceiling-source)
    - [extract\_url\_parameter (source)](#extract_url_parameter-source)
    - [first\_value (source)](#first_value-source)
    - [json\_extract (source)](#json_extract-source)
    - [json\_parse (source)](#json_parse-source)
    - [max\_bool (source)](#max_bool-source)
    - [percentile (source)](#percentile-source)
    - [pivot\_json\_extract (source)](#pivot_json_extract-source)
    - [string\_agg (source)](#string_agg-source)
    - [timestamp\_add (source)](#timestamp_add-source)
    - [timestamp\_diff (source)](#timestamp_diff-source)
    - [try\_cast (source)](#try_cast-source)
    - [wrap\_in\_quotes (source)](#wrap_in_quotes-source)
  - [SQL and field generators](#sql-and-field-generators)
    - [add\_dbt\_source\_relation (source)](#add_dbt_source_relation-source)
    - [add\_pass\_through\_columns (source)](#add_pass_through_columns-source)
    - [calculated\_fields (source)](#calculated_fields-source)
    - [fivetran\_date\_spine (source)](#fivetran_date_spine-source)
    - [drop\_schemas\_automation (source)](#drop_schemas_automation-source)
    - [dummy\_coalesce\_value (source)](#dummy_coalesce_value-source)
    - [fill\_pass\_through\_columns (source)](#fill_pass_through_columns-source)
    - [fill\_staging\_columns (source)](#fill_staging_columns-source)
    - [persist\_pass\_through\_columns (source)](#persist_pass_through_columns-source)
    - [remove\_prefix\_from\_columns (source)](#remove_prefix_from_columns-source)
    - [source\_relation (source)](#source_relation-source)
    - [union\_data (source)](#union_data-source)
      - [Union Data Defined Sources Configuration](#union-data-defined-sources-configuration)
    - [union\_relations (source)](#union_relations-source)
  - [Variable Checks](#variable-checks)
    - [empty\_variable\_warning (source)](#empty_variable_warning-source)
    - [enabled\_vars (source)](#enabled_vars-source)
    - [enabled\_vars\_one\_true (source)](#enabled_vars_one_true-source)
- [🔍 Does this package have dependencies?](#-does-this-package-have-dependencies)
- [🙌 How is this package maintained and can I contribute?](#-how-is-this-package-maintained-and-can-i-contribute)
  - [Package Maintenance](#package-maintenance)
  - [Contributions](#contributions)
- [🏪 Are there any resources available?](#-are-there-any-resources-available)

----

## Tests and helpers
These macros help run or assist tests.
### collect_freshness ([source](macros/collect_freshness.sql))
This macro overrides dbt's default [`collect_freshness` macro](https://github.com/fishtown-analytics/dbt/blob/0.19.latest/core/dbt/include/global_project/macros/adapters/common.sql#L257-L273) that is called when running `dbt source snapshot-freshness`. It allows you to incorporate model enabling/disabling variables into freshness tests, so that, if a source table does not exist, dbt will not run (and error on) a freshness test on the table. **Any package that has a dependency on fivetran_utils will use this version of the macro. If no `meta.is_enabled` field is provided, the `collect_freshness` should run exactly like dbt's default version.**

**Usage:**
```yml
# in the sources.yml
sources:
  - name: source_name
    freshness:
      warn_after: {count: 84, period: hour}
      error_after: {count: 168, period: hour}
    tables:
      - name: table_that_might_not_exist
        meta:
          is_enabled: "{{ var('package__using_this_table', true) }}"
```
**Args (sorta):**
* `meta.is_enabled` (optional): The variable(s) you would like to reference to determine if dbt should include this table in freshness tests.

----
### seed_data_helper ([source](macros/seed_data_helper.sql))
This macro is intended to be used when a source table column is a reserved keyword in a warehouse, and Circle CI is throwing a fit.
It simply chooses which version of the data to seed. Also note the `warehouses` argument is a list and multiple warehouses may be added based on the number of warehouse
specific seed data files you need for integration testing.

***Usage:**
```yml
    # in integration_tests/dbt_project.yml
    vars:
        table_name: "{{ fivetran_utils.seed_data_helper(seed_name='user_data', warehouses=['snowflake', 'postgres']) }}"
```
**Args:**
* `seed_name` (required): Name of the seed that has separate postgres seed data.
* `warehouses` (required): List of the warehouses for which you want CircleCi to use the helper seed data.

----
### snowflake_seed_data ([source](macros/snowflake_seed_data.sql))
This macro is intended to be used when a source table column is a reserved keyword in Snowflake, and Circle CI is throwing a fit.
It simply chooses which version of the data to seed (the Snowflake copy should capitalize and put three pairs of quotes around the problematic column).

***Usage:**
```yml
    # in integration_tests/dbt_project.yml
    vars:
        table_name: "{{ fivetran_utils.snowflake_seed_data(seed_name='user_data') }}"
```
**Args:**
* `seed_name` (required): Name of the seed that has separate snowflake seed data.

----
## Cross-database compatibility
These macros allows functions to prevail across the different databases. 
### array_agg ([source](macros/array_agg.sql))
This macro allows for cross database field aggregation. The macro contains the database specific field aggregation function for 
BigQuery, Snowflake, Redshift, and Postgres. By default a comma `,` is used as a delimiter in the aggregation.

**Usage:**
```sql
{{ fivetran_utils.array_agg(field_to_agg="teams") }}
```
**Args:**
* `field_to_agg` (required): Field within the table you are wishing to aggregate.

----
### ceiling ([source](macros/ceiling.sql))
This macro allows for cross database use of the ceiling function. The ceiling function returns the smallest integer greater 
than, or equal to, the specified numeric expression. The ceiling macro is compatible with BigQuery, Redshift, Postgres, and Snowflake.

**Usage:**
```sql
{{ fivetran_utils.ceiling(num="target/total_days") }}
```
**Args:**
* `num` (required): The integer field you wish to apply the ceiling function.

----
### extract_url_parameter ([source](macros/extract_url_parameter.sql))
This macro extracts a url parameter from a column containing a url. It is an expansion of `dbt_utils.get_url_parameter()` to add support for Databricks SQL. 

**Usage:**
```sql
{{ fivetran_utils.extract_url_parameter(field="url_field", url_parameter="utm_source") }}
```
**Args:**
* `field` (required): The name of the column containing the url.
* `url_parameter` (required): The parameter you want to extract. 

----
### first_value ([source](macros/first_value.sql))
This macro returns the value_expression for the first row in the current window frame with cross db functionality. This macro ignores null values. The default first_value calculation within the macro is the `first_value` function. The Redshift first_value calculation is the `first_value` function, with the inclusion of a frame_clause `{{ partition_field }} rows unbounded preceding`.

**Usage:**
```sql
{{ fivetran_utils.first_value(first_value_field="created_at", partition_field="id", order_by_field="created_at", order="asc") }}
```
**Args:**
* `first_value_field` (required): The value expression which you want to determine the first value for.
* `partition_field`   (required): Name of the field you want to partition by to determine the first_value.
* `order_by_field`    (required): Name of the field you wish to sort on to determine the first_value.
* `order`             (optional): The order of which you want to partition the window frame. The order argument by default is `asc`. If you wish to get the last_value, you may change the argument to `desc`.

----
### json_extract ([source](macros/json_extract.sql))
This macro allows for cross database use of the json extract function. The json extract allows the return of data from a json object.
The data is returned by the path you provide as the argument. The json_extract macro is compatible with BigQuery, Redshift, Postgres, and Snowflake.

**Usage:**
```sql
{{ fivetran_utils.json_extract(string="value", string_path="in_business_hours") }}
```
**Args:**
* `string` (required): Name of the field which contains the json object.
* `string_path`  (required): Name of the path in the json object which you want to extract the data from.

----
### json_parse ([source](macros/json_parse.sql))
This macro allows for cross database use of the json extract function, specifically used to parse and extract a nested value from a json object.
The data is returned by the path you provide as the list within the `string_path` argument. The json_parse macro is compatible with BigQuery, Redshift, Postgres, Snowflake and Databricks.

**Usage:**
```sql
{{ fivetran_utils.json_parse(string="receipt", string_path=["charges","data",0,"balance_transaction","exchange_rate"]) }}
```
**Args:**
* `string` (required): Name of the field which contains the json object.
* `string_path`  (required): List of item(s) that derive the path in the json object which you want to extract the data from.

----
### max_bool ([source](macros/max_bool.sql))
This macro allows for cross database use of obtaining the max boolean value of a field. This macro recognizes true = 1 and false = 0. The macro will aggregate the boolean_field and return the max boolean value. The max_bool macro is compatible with BigQuery, Redshift, Postgres, and Snowflake.

**Usage:**
```sql
{{ fivetran_utils.max_bool(boolean_field="is_breach") }}
```
**Args:**
* `boolean_field` (required): Name of the field you are obtaining the max boolean record from.

----
### percentile ([source](macros/percentile.sql))
This macro is used to return the designated percentile of a field with cross db functionality. The percentile function stems from percentile_cont across db's. For Snowflake and Redshift this macro uses the window function opposed to the aggregate for percentile. For Postgres, this macro uses the aggregate, as it does not support a percentile window function. Thus, you will need to add a target-dependent `group by` in the query you are calling this macro in.

**Usage:**
```sql
select id,
{{ fivetran_utils.percentile(percentile_field='time_to_close', partition_field='id', percent='0.5') }}
from your_cte
{% if target.type == 'postgres' %} group by id {% endif %}
```
**Args:**
* `percentile_field` (required): Name of the field of which you are determining the desired percentile.
* `partition_field`  (required): Name of the field you want to partition by to determine the designated percentile. You will need to group by this for Postgres.
* `percent`          (required): The percent necessary for `percentile_cont` to determine the percentile. If you want to find the median, you will input `0.5` for the percent. 

----
### pivot_json_extract ([source](macros/pivot_json_extract.sql))
This macro builds off of the `json_extract` macro in order to extract a list of fields from a json object and pivot the fields out into columns. The `pivot_json_extract` macro is compatible with BigQuery, Redshift, Postgres, and Snowflake.

**Usage:**
```sql
{{ fivetran_utils.pivot_json_extract(string="json_value", list_of_properties=["field 1", "field 2"]) }}
```
**Args:**
* `string` (required): Name of the field which contains the json object.
* `list_of_properties`  (required): List of the fields that you want to extract from the json object and pivot out into columns.

----
### string_agg ([source](macros/string_agg.sql))
This macro allows for cross database field aggregation and delimiter customization. Supported database specific field aggregation functions include 
BigQuery, Snowflake, Redshift, Postgres, and Spark.

**Usage:**
```sql
{{ fivetran_utils.string_agg(field_to_agg="issues_opened", delimiter='|') }}
```
**Args:**
* `field_to_agg` (required): Field within the table you are wishing to aggregate.
* `delimiter`    (required): Character you want to be used as the delimiter between aggregates.
----
### timestamp_add ([source](macros/timestamp_add.sql))
This macro allows for cross database addition of a timestamp field and a specified datepart and interval for BigQuery, Redshift, Postgres, and Snowflake.

**Usage:**
```sql
{{ fivetran_utils.timestamp_add(datepart="day", interval="1", from_timestamp="last_ticket_timestamp") }}
```
**Args:**
* `datepart`       (required): The datepart you are adding to the timestamp field.
* `interval`       (required): The interval in relation to the datepart you are adding to the timestamp field.
* `from_timestamp` (required): The timestamp field you are adding the datepart and interval.

----
### timestamp_diff ([source](macros/timestamp_diff.sql))
This macro allows for cross database timestamp difference calculation for BigQuery, Redshift, Postgres, and Snowflake.

**Usage:**
```sql
{{ fivetran_utils.timestamp_diff(first_date="first_ticket_timestamp", second_date="last_ticket_timestamp", datepart="day") }}
```
**Args:**
* `first_date`       (required): The first timestamp field for the difference calculation.
* `second_date`      (required): The second timestamp field for the difference calculation.
* `datepart`         (required): The date part applied to the timestamp difference calculation.

----
### try_cast ([source](macros/try_cast.sql))
This macro allows a field to be cast to a specified datatype. If the datatype is incompatible then a `null` value is provided. This macro is compatible with BigQuery, Redshift, Postgres, Snowflake, and Databricks.
> Please note: For Postgres and Redshift destinations the `numeric` datatype is only supported to try_cast.
**Usage:**
```sql
{{ fivetran_utils.try_cast(field="amount", type="numeric") }}
```
**Args:**
* `field`       (required): The base field you are trying to cast.
* `type`        (required): The datatype you want to try and cast the base field.

----
### wrap_in_quotes ([source](macros/wrap_in_quotes.sql))
This macro takes a SQL object (ie database, schema, column) and returns it wrapped in database-appropriate quotes (and casing for Snowflake). 

**Usage:**
```sql
{{ fivetran_utils.wrap_in_quotes(object_to_quote="reserved_keyword_mayhaps") }}
```
**Args:**
* `object_to_quote` (required): SQL object you want to quote.
----
## SQL and field generators
These macros create SQL or fields to be included when running the package.
### add_dbt_source_relation ([source](macros/add_dbt_source_relation.sql))
This macro is intended to be used within the second CTE (typically named `fields`) of non-tmp staging models. 
It simply passes through the `_dbt_source_relation` column produced by `union_data()` in the tmp staging model, so that `source_relation()` can work in the final CTE of the staging model.

**Usage:**
```sql
{{ fivetran_utils.add_dbt_source_relation() }}
```
----
### add_pass_through_columns ([source](macros/add_pass_through_columns.sql))
This macro creates the proper name, datatype, and aliasing for user defined pass through column variable. This
macro allows for pass through variables to be more dynamic and allow users to alias custom fields they are 
bringing in. This macro is typically used within staging models of a fivetran dbt source package to pass through
user defined custom fields. Works for older and newer versions of passthrough columns.

**Usage:**
```sql
{{ fivetran_utils.add_pass_through_columns(base_columns=columns, pass_through_var=var('hubspot__deal_pass_through_columns')) }}
```
**Args:**
* `base_columns` (required): The name of the variable where the base columns are contained. This is typically `columns`.
* `pass_through_var` (required): The variable which contains the user defined pass through fields.

----
### calculated_fields ([source](macros/calculated_fields.sql))
This macro allows for calculated fields within a variable to be passed through to a model. The format of the variable **must** be in the following format:
```yml
vars:
  calculated_fields_variable:
    - name:          "new_calculated_field_name"
      transform_sql: "existing_field * other_field"
```

**Usage:**
```sql
{{ fivetran_utils.calculated_fields(variable="calculated_fields_variable") }}
```
**Args:**
* `variable` (required): The variable containing the calculated field `name` and `transform_sql`.

----
### fivetran_date_spine ([source](macros/fivetran_date_spine.sql))
This macro returns the sql required to build a date spine. The spine will include the `start_date` (if it is aligned to the `datepart`), but it will not include the `end_date`.

For non-SQL Server databases, this will simply call [`dbt_utils.date_spine()`](https://github.com/dbt-labs/dbt-utils#date_spine-source). For SQL Server targets, this will manually create a spine, with code heavily leveraged from [`tsql-utils.date_spine()`](https://github.com/dbt-msft/tsql-utils/blob/main/macros/dbt_utils/datetime/date_spine.sql) but [adjusted for recent changes to dbt_utils](https://github.com/dbt-msft/tsql-utils/issues/96).

**Usage:**
```sql
{{ fivetran_utils.fivetran_date_spine(
    datepart="day",
    start_date="cast('2019-01-01' as date)",
    end_date="cast('2020-01-01' as date)"
   )
}}
```
**Args:**
* `datepart` (required): The grain at which you would like to create the date spine. 
* `start_date` (required): The date (inclusive if it is aligned to the `datepart`) at which you'd like the date spine to start.
* `end_date` (required): The date (excusive) at which you'd like the date spine to end.

----

### drop_schemas_automation ([source](macros/drop_schemas_automation.sql))
This macro was created to help clean up the schemas in our integration test environments. It drops schemas that are `like` the `target.schema`. By default it will drop the target schema as well but this can be configured.

**Usage:**
At the end of a Buildkite integration test job in `.buildkite/scripts/run_models.sh`:
```sh
# do all the setup, dbt seed, compile, run, test steps beforehand...
dbt run-operation fivetran_utils.drop_schemas_automation --target "$db"
```

As a Fivetran Transformation job step in a `deployment.yml`:
```yml
jobs:
 - name: cleanup
   schedule: '0 0 * * 0' # The example will run once a week at 00:00 on Sunday.
   steps:
    - name: drop schemas but leave target
      command: dbt run-operation fivetran_utils.drop_schemas_automation --vars '{"drop_target_schema": False}'
    - name: drop schemas including target
      command: dbt run-operation fivetran_utils.drop_schemas_automation
```
**Args:**
* `drop_target_schema` (optional): Boolean that is `true` by default. If `false`, the target schema will not be dropped.

----

### dummy_coalesce_value ([source](macros/dummy_coalesce_value.sql))
This macro creates a dummy coalesce value based on the data type of the field. See below for the respective data type and dummy values:
- String    = 'DUMMY_STRING'
- Boolean   = null
- Int       = 999999999
- Float     = 999999999.99
- Timestamp = cast("2099-12-31" as timestamp)
- Date      = cast("2099-12-31" as date)
**Usage:**
```sql
{{ fivetran_utils.dummy_coalesce_value(column="user_rank") }}
```
**Args:**
* `column` (required): Field you are applying the dummy coalesce.

----
### fill_pass_through_columns ([source](macros/fill_pass_through_columns.sql))
This macro is used to generate the correct sql for package staging models for user defined pass through columns. Works for older and newer versions of passthrough columns.

**Usage:**
```sql
{{ fivetran_utils.fill_pass_through_columns(pass_through_variable='hubspot__contact_pass_through_columns') }}
```
**Args:**
* `pass_through_variable` (required): Name of the variable which contains the respective pass through fields for the staging model.

----
### fill_staging_columns ([source](macros/fill_staging_columns.sql))
This macro is used to generate the correct SQL for package staging models. It takes a list of columns that are expected/needed (`staging_columns`) 
and compares it with columns in the source (`source_columns`). 

**Usage:**
```sql
select

    {{
        fivetran_utils.fill_staging_columns(
            source_columns=adapter.get_columns_in_relation(ref('stg_twitter_ads__account_history_tmp')),
            staging_columns=get_account_history_columns()
        )
    }}

from source
```
**Args:**
* `source_columns`  (required): Will call the [get_columns_in_relation](https://docs.getdbt.com/reference/dbt-jinja-functions/adapter/#get_columns_in_relation) macro as well requires a `ref()` or `source()` argument for the staging models within the `_tmp` directory.
* `staging_columns` (required): Created as a result of running the [generate_columns_macro](https://github.com/fivetran/dbt_fivetran_utils#generate_columns_macro-source) for the respective table.

----
### persist_pass_through_columns ([source](macros/persist_pass_through_columns.sql))
This macro is used to persist pass through columns from the staging model to the **transform** package. This is particularly helpful when a `select *` is not feasible.

**Usage:**
```sql
{{ fivetran_utils.persist_pass_through_columns(pass_through_variable='hubspot__contact_pass_through_columns', identifier='cte_name', transform='') }}
```
**Args:**
* `pass_through_variable` (required): Name of the variable which contains the respective pass through fields for the model.
* `identifier` (optional): Relation-identifier to prefix (followed by `'.'`) each column with (ie in case of ambiguous column join errors).
* `transform` (optional): SQL function you would like to apply to the passed through columns.

----
### remove_prefix_from_columns ([source](macros/remove_prefix_from_columns.sql))
This macro removes desired prefixes from specified columns. Additionally, a for loop is utilized which allows for adding multiple columns to remove prefixes.

**Usage:**
```sql
{{ fivetran_utils.remove_prefix_from_columns(columns="names", prefix='', exclude=[]) }}
```
**Args:**
* `columns` (required): The desired columns you wish to remove prefixes.
* `prefix`  (optional): The prefix the macro will search for and remove. By default the prefix = ''.
* `exclude` (optional): The columns you wish to exclude from this macro. By default no columns are excluded.

----
### source_relation ([source](macros/source_relation.sql))
This macro creates a new column that signifies with database/schema a record came from when using the `union_data` macro above. 
It should be added to all non-tmp staging models when using the `union_data` macro. 

**Usage:**
```sql
{{ fivetran_utils.source_relation() }}
```

**Args:**
* `union_schema_variable` (optional): The name of the union schema variable. By default the macro will look for `union_schemas`.
* `union_database_variable` (optional): The name of the union database variable. By default the macro will look for `union_databases`.

----
### union_data ([source](macros/union_data.sql))
This macro unions together tables of the same structure so that users can treat data from multiple connectors as the 'source' to a package.
Depending on which macros are set, it will either look for schemas of the same name across multiple databases, or schemas with different names in the same database.

If the `var` with the name of the `schema_variable` argument is set, the macro will union the `table_identifier` tables from each respective schema within the target database (or source database if set by a variable).
If the `var` with the name of the `database_variable` argument is set, the macro will union the `table_identifier` tables from the source schema in each respective database.

When using this functionality, every `_tmp` table should use this macro as described below.

To create dependencies between the unioned model and its *sources*, you **must define** the source tables in a `.yml` file in your project and set the `has_defined_sources` variable (scoped to the source package in which the macro is being called) to `True` in your `dbt_project.yml` file. If you set `has_defined_sources` to true and do not define sources (at least adding the `name` of each table in the source), dbt will throw an error. Please see the below [Union Data Defined Sources Configuration](https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union-data-defined-sources-configuration) section for details on how to configure this ability in your project.

If the source table is not found in any of the provided schemas/databases, `union_data` will return a **completely** empty table (ie `limit 0`) with just one string column (`_dbt_source_relation`). A compiler warning message will be output, highlighting that the expected source table was not found and its respective staging model is empty. The compiler warning can be turned off by the end user by setting the `fivetran__remove_empty_table_warnings` variable to `True`.

**Usage:**
```sql
-- in model.sql file
{{
    fivetran_utils.union_data(
        table_identifier='customer', 
        database_variable='shopify_database', 
        schema_variable='shopify_schema', 
        default_database=target.database,
        default_schema='shopify',
        default_variable='customer_source'
    )
}}
```
**Args:**
* `table_identifier`: The name of the table that will be unioned. This maps onto the table's `name` as it is defined in the `src.yml` file, _not_ the `identifier`.
* `database_variable`: The name of the variable that users can populate to union data from multiple databases.
* `schema_variable`: The name of the variable that users can populate to union data from multiple schemas.
* `default_database`: The default database where source data should be found. This is used when unioning schemas.
* `default_schema`: The default schema where source data should be found. This is used when unioning databases.
* `default_variable`: The name of the variable that users should populate when they want to pass one specific relation to this model (mostly used for CI)
* `union_schema_variable` (optional): The name of the union schema variable. By default the macro will look for `union_schemas`.
* `union_database_variable` (optional): The name of the union database variable. By default the macro will look for `union_databases`.

#### Union Data Defined Sources Configuration
```yml
# in root dbt_project.yml file
vars:
  shopify_source:
    has_defined_sources: true
  
  fivetran__remove_empty_table_warnings: true # false by default
```

```yml
# in a root-project schema.yml file 
version: 2

sources:
  - name: shopify_us
    schema: shopify_us
    database: "{{ var('shopify_database', target.database) }}"
    loader: Fivetran
    loaded_at_field: _fivetran_synced
    tables:
      - name: account
      - name: customer 
      ...
  
  - name: shopify_mx
    schema: shopify_mx
    database: "{{ var('shopify_database', target.database) }}"
    loader: Fivetran
    loaded_at_field: _fivetran_synced
    tables:
      - name: account
      - name: customer 
      ...
```
----
### union_relations ([source](macros/union_relations.sql))
This macro unions together an array of [Relations](https://docs.getdbt.com/docs/writing-code-in-dbt/class-reference/#relation),
even when columns have differing orders in each Relation, and/or some columns are
missing from some relations. Any columns exclusive to a subset of these
relations will be filled with `null` where not present. An new column
(`_dbt_source_relation`) is also added to indicate the source for each record.

**Usage:**
```sql
{{ dbt_utils.union_relations(
    relations=[ref('my_model'), source('my_source', 'my_table')],
    exclude=["_loaded_at"]
) }}
```
**Args:**
* `relations`          (required): An array of [Relations](https://docs.getdbt.com/docs/writing-code-in-dbt/class-reference/#relation).
* `aliases`            (optional): An override of the relation identifier. This argument should be populated with the overwritten alias for the relation. If not populated `relations` will be the default.
* `exclude`            (optional): A list of column names that should be excluded from the final query.
* `include`            (optional): A list of column names that should be included in the final query. Note the `include` and `exclude` parameters are mutually exclusive.
* `column_override`    (optional): A dictionary of explicit column type overrides, e.g. `{"some_field": "varchar(100)"}`.``
* `source_column_name` (optional): The name of the column that records the source of this row. By default this argument is set to `none`.

----

## Variable Checks
These macros tests if a variable meets given conditions.
### empty_variable_warning ([source](macros/empty_variable_warning.sql))
This macro checks a declared variable and returns an error message if the variable is empty before running the models within the `dbt_project.yml` file.

**Usage:**
```yml
on-run-start: '{{ fivetran_utils.empty_variable_warning(variable="ticket_field_history_columns", downstream_model="zendesk_ticket_field_history") }}'
```
**Args:**
* `variable`            (required): The variable you want to check if it is empty.
* `downstream_model`    (required): The downstream model that is affected if the variable is empty.

----
### enabled_vars ([source](macros/enabled_vars.sql))
This macro references a set of specified boolean variable and returns `false` if any variable value is equal to false.

**Usage:**
```sql
{{ fivetran_utils.enabled_vars(vars=["using_department_table", "using_customer_table"]) }}
```
**Args:**
* `vars` (required): Variable you are referencing to return the declared variable value.

----
### enabled_vars_one_true ([source](macros/enabled_vars_one_true.sql))
This macro references a set of specified boolean variable and returns `true` if any variable value is equal to true.

**Usage:**
```sql
{{ fivetran_utils.enabled_vars_one_true(vars=["using_department_table", "using_customer_table"]) }}
```
**Args:**
* `vars` (required): Variable(s) you are referencing to return the declared variable value.

# 🔍 Does this package have dependencies?
This dbt package is dependent on the following dbt packages. Please be aware that these dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.
```yml
packages:
    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]
```

# 🙌 How is this package maintained and can I contribute?
## Package Maintenance
The Fivetran team maintaining this package **only** maintains the latest version of the package. We highly recommend you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/jira/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_jira/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

## Contributions
These dbt packages are developed by a small team of analytics engineers at Fivetran. However, the packages are made better by community contributions! 

We highly encourage and welcome contributions to this package. Check out [this post](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package!

# 🏪 Are there any resources available?
- If you encounter any questions or want to reach out for help, please refer to the [GitHub Issue](https://github.com/fivetran/dbt_fivetran_utils/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran, or would like to request a future dbt package to be developed, then feel free to fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
- Have questions or want to just say hi? Book a time during our office hours [here](https://calendly.com/fivetran-solutions-team/fivetran-solutions-team-office-hours) or send us an email at solutions@fivetran.com.

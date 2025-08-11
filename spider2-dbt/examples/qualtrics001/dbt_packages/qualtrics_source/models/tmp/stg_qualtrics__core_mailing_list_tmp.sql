{{ config(enabled=var('qualtrics__using_core_mailing_lists', false)) }}
-- can disable
{{
    fivetran_utils.union_data(
        table_identifier='core_mailing_list', 
        database_variable='qualtrics_database', 
        schema_variable='qualtrics_schema', 
        default_database=target.database,
        default_schema='qualtrics',
        default_variable='core_mailing_list',
        union_schema_variable='qualtrics_union_schemas',
        union_database_variable='qualtrics_union_databases'
    )
}}
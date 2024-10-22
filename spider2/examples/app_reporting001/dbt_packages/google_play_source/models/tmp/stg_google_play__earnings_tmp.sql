{{ config(enabled=var('google_play__using_earnings', False)) }}

{{
    fivetran_utils.union_data(
        table_identifier='earnings', 
        database_variable='google_play_database', 
        schema_variable='google_play_schema', 
        default_database=target.database,
        default_schema='google_play',
        default_variable='earnings',
        union_schema_variable='google_play_union_schemas',
        union_database_variable='google_play_union_databases'
    )
}}
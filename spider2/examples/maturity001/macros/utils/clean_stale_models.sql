{# clean_stale_models

This macro queries all tables and views within a database that are stale to "clean" the workspace. Use the dry_run param to see the schemas that will be dropped before dropping them.
The schemas to drop will be those that match the schema_like (if provided) AND do not match the schema_not_like (if provided). The information_schema is always
excluded as it is not droppable in snowflake. 

More info in this discourse article! https://discourse.getdbt.com/t/faq-cleaning-up-removed-models-from-your-production-schema/113

Args:
    - database: string        -- the name of the database to clean. By default the target.database is used
    - dry_run: bool           -- dry run flag. When dry_run is true, the cleanup commands are printed to stdout rather than executed. This is true by default
    - schema_like: string     -- case-insensitive like pattern of schema names to include. This is None by default. 
    - schema_not_like: string -- case-insensitive like pattern of schema names to exclude. This is None by default 
    - look_back_hours: int -- number of hours to lookback to define an active table or view in the specified db/schema. This is 24 hours by default.  

Example 1 - dry run of all tables in the target database
    dbt run-operation clean_workspace    
    
Example 2 - drop any tables or views in a given database that match a given schema_like string and a 24 hour lookback window for freshness
    dbt run-operation clean_workspace --args '{database: my_database, dry_run: False, schema_like: "cool_schema_%", look_back_hours: 24 }'
    
#}

{% macro clean_stale_models(database=target.database, dry_run=True, schema_like=None, schema_not_like=None, look_back_hours=24) %}
    {%- set msg -%}
        Starting clean_workspace...
          database:        {{database}} 
          dry_run:         {{dry_run}} 
          schema_like:     {{schema_like}} 
          schema_not_like: {{schema_not_like}} 
          look_back period: {{ look_back_hours }} hours
    {%- endset -%}
    {{ log(msg, info=True) }}


    {% set get_drop_commands_query %}
        SELECT
            case 
                when table_type = 'VIEW' 
                    then table_type
                else 'TABLE'
            end as drop_object,
            'DROP ' || drop_object || ' {{ database | upper }}.' || TABLE_SCHEMA || '.' || TABLE_NAME ||';' AS DROP_QUERY
        FROM
            {{database}}.INFORMATION_SCHEMA.TABLES
        WHERE
            TABLE_SCHEMA != 'INFORMATION_SCHEMA'
        {%- if schema_like -%}
            AND TABLE_SCHEMA ILIKE '{{schema_like}}' 
        {%- endif -%}
        {%- if schema_not_like -%}
            AND NOT TABLE_SCHEMA ILIKE '{{schema_not_like}}' 
        {%- endif -%}
            -- last_altered is in sys timezone, so use ucrrent_timestamp()
            AND last_altered < dateadd(hour, -{{ look_back_hours }},  current_timestamp())
    {% endset %}


    {{ log('\nGenerating cleanup queries...\n', info=True) }}
    {% set drop_queries = run_query(get_drop_commands_query).columns[1].values() %}


    {% for drop_query in drop_queries %}
        {% if execute and not dry_run %}
            {{ log('Dropping table/view with command: ' ~ drop_query, info=True) }}
            {% do run_query(drop_query) %}    
        {% else %}
            {{ log(drop_query, info=True) }}
        {% endif %}
    {% endfor %}
{% endmacro %}
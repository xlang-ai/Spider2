{%- macro union_data(table_identifier, database_variable, schema_variable, default_database, default_schema, default_variable, union_schema_variable='union_schemas', union_database_variable='union_databases') -%}

{{ adapter.dispatch('union_data', 'fivetran_utils') (
    table_identifier, 
    database_variable, 
    schema_variable, 
    default_database, 
    default_schema, 
    default_variable,
    union_schema_variable,
    union_database_variable
    ) }}

{%- endmacro -%}

{%- macro default__union_data(
    table_identifier, 
    database_variable, 
    schema_variable, 
    default_database, 
    default_schema, 
    default_variable,
    union_schema_variable,
    union_database_variable
    ) -%}

{%- if var(union_schema_variable, none) -%}

    {%- set relations = [] -%}
    
    {%- if var(union_schema_variable) is string -%}
    {%- set trimmed = var(union_schema_variable)|trim('[')|trim(']') -%}
    {%- set schemas = trimmed.split(',')|map('trim'," ")|map('trim','"')|map('trim',"'") -%}
    {%- else -%}
    {%- set schemas = var(union_schema_variable) -%}
    {%- endif -%}

    {%- for schema in var(union_schema_variable) -%}
    {%- set relation=adapter.get_relation(
        database=source(schema, table_identifier).database if var('has_defined_sources', false) else var(database_variable, default_database),
        schema=source(schema, table_identifier).schema if var('has_defined_sources', false) else schema,
        identifier=source(schema, table_identifier).identifier if var('has_defined_sources', false) else table_identifier
    ) -%}
    
    {%- set relation_exists=relation is not none -%}

    {%- if relation_exists -%}
        {%- do relations.append(relation) -%}
    {%- endif -%}

    {%- endfor -%}
    
    {%- if relations != [] -%}
        {{ dbt_utils.union_relations(relations) }}
    {%- else -%}
    {% if execute and not var('fivetran__remove_empty_table_warnings', false) -%}
    {{ exceptions.warn("\n\nPlease be aware: The " ~ table_identifier|upper ~ " table was not found in your " ~ default_schema|upper ~ " schema(s). The Fivetran dbt package will create a completely empty " ~ table_identifier|upper ~ " staging model as to not break downstream transformations. To turn off these warnings, set the `fivetran__remove_empty_table_warnings` variable to TRUE (see https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union_data-source for details).\n") }}
    {% endif -%}
    select 
        cast(null as {{ dbt.type_string() }}) as _dbt_source_relation
    limit 0
    {%- endif -%}

{%- elif var(union_database_variable, none) -%}

    {%- set relations = [] -%}

    {%- for database in var(union_database_variable) -%}
    {%- set relation=adapter.get_relation(
        database=source(schema, table_identifier).database if var('has_defined_sources', false) else database,
        schema=source(schema, table_identifier).schema if var('has_defined_sources', false) else var(schema_variable, default_schema),
        identifier=source(schema, table_identifier).identifier if var('has_defined_sources', false) else table_identifier
    ) -%}

    {%- set relation_exists=relation is not none -%}

    {%- if relation_exists -%}
        {%- do relations.append(relation) -%}
    {%- endif -%}

    {%- endfor -%}

    {%- if relations != [] -%}
        {{ dbt_utils.union_relations(relations) }}
    {%- else -%}
    {% if execute and not var('fivetran__remove_empty_table_warnings', false) -%}
    {{ exceptions.warn("\n\nPlease be aware: The " ~ table_identifier|upper ~ " table was not found in your " ~ default_schema|upper ~ " schema(s). The Fivetran dbt package will create a completely empty " ~ table_identifier|upper ~ " staging model as to not break downstream transformations. To turn off these warnings, set the `fivetran__remove_empty_table_warnings` variable to TRUE (see https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union_data-source for details).\n") }}
    {% endif -%}
    select 
        cast(null as {{ dbt.type_string() }}) as _dbt_source_relation
    limit 0
    {%- endif -%}

{%- else -%}
    {% set exception_schemas = {"linkedin_company_pages": "linkedin_pages", "instagram_business_pages": "instagram_business"} %}
    {% set relation = namespace(value="") %}
    {% if default_schema in exception_schemas.keys() %}
        {% for corrected_schema_name in exception_schemas.items() %}   
            {% if default_schema in corrected_schema_name %}
                {# In order for this macro to effectively work within upstream integration tests (mainly used by the Fivetran dbt package maintainers), this identifier variable selection is required to use the macro with different identifier names. #}
                {% set identifier_var = corrected_schema_name[1] + "_" + table_identifier + "_identifier"  %}
                {%- set relation.value=adapter.get_relation(
                    database=source(corrected_schema_name[1], table_identifier).database,
                    schema=source(corrected_schema_name[1], table_identifier).schema,
                    identifier=var(identifier_var, table_identifier)
                ) -%}
            {% endif %}
        {% endfor %}
    {% else %}
        {# In order for this macro to effectively work within upstream integration tests (mainly used by the Fivetran dbt package maintainers), this identifier variable selection is required to use the macro with different identifier names. #}
        {% set identifier_var = default_schema + "_" + table_identifier + "_identifier"  %}
        {# Unfortunately the Twitter Organic identifiers were misspelled. As such, we will need to account for this in the model. This will be adjusted in the Twitter Organic package, but to ensure backwards compatibility, this needs to be included. #}
        {% if var(identifier_var, none) is none %} 
            {% set identifier_var = default_schema + "_" + table_identifier + "_identifer"  %}
        {% endif %}
        {%- set relation.value=adapter.get_relation(
            database=source(default_schema, table_identifier).database,
            schema=source(default_schema, table_identifier).schema,
            identifier=var(identifier_var, table_identifier)
        ) -%}
    {% endif %}
{%- set table_exists=relation.value is not none -%}

{%- if table_exists -%}
    select * 
    from {{ relation.value }}
{%- else -%}
    {% if execute and not var('fivetran__remove_empty_table_warnings', false) -%}
    {{ exceptions.warn("\n\nPlease be aware: The " ~ table_identifier|upper ~ " table was not found in your " ~ default_schema|upper ~ " schema(s). The Fivetran dbt package will create a completely empty " ~ table_identifier|upper ~ " staging model as to not break downstream transformations. To turn off these warnings, set the `fivetran__remove_empty_table_warnings` variable to TRUE (see https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union_data-source for details).\n") }}
    {% endif -%}
    select 
        cast(null as {{ dbt.type_string() }}) as _dbt_source_relation
    limit 0
{%- endif -%}
{%- endif -%}

{%- endmacro -%}

{%- set cols = adapter.get_columns_in_relation(ref('sp_event')) -%}
{%- set col_list = [] -%}

{% set type_overrides = {
    "br_cookies": "boolean",
    "br_features_director": "boolean",
    "br_features_flash": "boolean",
    "br_features_gears": "boolean",
    "br_features_java": "boolean",
    "br_features_pdf": "boolean",
    "br_features_quicktime": "boolean",
    "br_features_realplayer": "boolean",
    "br_features_silverlight": "boolean",
    "br_features_windowsmedia": "boolean",
    "collector_tstamp": "timestamp",
    "derived_tstamp": "timestamp",
    "dvce_ismobile": "boolean"
} %}

{%- for col in cols -%}
    {%- set col_statement -%}
    {%- if col.column in type_overrides.keys() %}
    cast({{col.column}} as {{type_overrides[col.column]}}) as {{col.column}}
    {% else %}
    {{col.column}}
    {% endif -%}
    {%- endset -%}
    {%- do col_list.append(col_statement) -%}
{%- endfor -%}

{%- set col_list_csv = col_list|join(',') -%}

select {{col_list_csv}} from {{ ref('sp_event') }}

{% if var('update', False) %}

    union all

    select {{col_list_csv}} from {{ ref('sp_event_update') }}

{% endif %}

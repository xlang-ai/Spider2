
with base as (

    select * 
    from {{ ref('stg_greenhouse__job_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_greenhouse__job_tmp')),
                staging_columns=get_job_columns()
            )
        }}

        {% if var('greenhouse_job_custom_columns', []) != [] %}
        ,
        {{ var('greenhouse_job_custom_columns', [] )  | join(', ') }}
        {% endif %}
        
    from base
),

final as (
    
    select 
        _fivetran_synced,
        cast(closed_at as {{ dbt.type_timestamp() }}) as last_opening_closed_at,
        confidential as is_confidential,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        id as job_id,
        name as job_title,
        notes,
        requisition_id,
        status,
        cast(updated_at as {{ dbt.type_timestamp() }}) as last_updated_at
        
        {% if var('greenhouse_job_custom_columns', []) != [] %}
        ,
        {{ var('greenhouse_job_custom_columns', [] )  | join(', ') }}
        {% endif %}

    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * from final

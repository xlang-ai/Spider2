
with base as (

    select * 
    from {{ ref('stg_greenhouse__candidate_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_greenhouse__candidate_tmp')),
                staging_columns=get_candidate_columns()
            )
        }}
        
        {% if var('greenhouse_candidate_custom_columns', []) != [] %}
        ,
        {{ var('greenhouse_candidate_custom_columns', [] )  | join(', ') }}
        {% endif %}

    from base
),

final as (
    
    select 
        _fivetran_synced,
        company as current_company,
        coordinator_id as coordinator_user_id,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        first_name || ' ' || last_name as full_name,
        id as candidate_id,
        is_private,
        cast(last_activity as {{ dbt.type_timestamp() }}) as last_activity_at,
        new_candidate_id,
        recruiter_id as recruiter_user_id,
        title as current_title,
        cast(updated_at as {{ dbt.type_timestamp() }}) as last_updated_at

        {% if var('greenhouse_candidate_custom_columns', []) != [] %}
        ,
        {{ var('greenhouse_candidate_custom_columns', [] )  | join(', ') }}
        {% endif %}

    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * from final

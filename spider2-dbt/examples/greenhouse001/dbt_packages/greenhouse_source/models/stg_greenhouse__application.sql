
with base as (

    select * 
    from {{ ref('stg_greenhouse__application_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_greenhouse__application_tmp')),
                staging_columns=get_application_columns()
            )
        }}
    
        {% if var('greenhouse_application_custom_columns', []) != [] %}
        ,
        {{ var('greenhouse_application_custom_columns', [] )  | join(', ') }}
        {% endif %}
        
    from base
),

final as (
    
    select 
        _fivetran_synced,
        cast(applied_at as {{ dbt.type_timestamp() }}) as applied_at,
        candidate_id,
        credited_to_user_id,
        current_stage_id,
        id as application_id,

        cast(last_activity_at as {{ dbt.type_timestamp() }}) as last_activity_at,
        location_address,
        prospect as is_prospect,
        prospect_owner_id as prospect_owner_user_id,
        prospect_pool_id,
        prospect_stage_id,
        cast(rejected_at as {{ dbt.type_timestamp() }}) as rejected_at,
        rejected_reason_id,
        source_id,
        status

        {% if var('greenhouse_application_custom_columns', []) != [] %}
        ,
        {{ var('greenhouse_application_custom_columns', [] )  | join(', ') }}
        {% endif %}

    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * from final

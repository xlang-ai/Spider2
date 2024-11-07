with base as (

    select *
    from {{ ref('stg_marketo__email_template_history_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_marketo__email_template_history_tmp')),
                staging_columns=get_email_template_history_columns()
            )
        }}
    from base

), fields as (

    select 
        created_at as created_timestamp,
        description,
        folder_folder_name as folder_name,
        folder_id,
        folder_type,
        folder_value,
        from_email,
        from_name,
        id as email_template_id,
        name as email_template_name,
        operational as is_operational,
        program_id,
        publish_to_msi,
        reply_email,
        status as email_template_status,
        subject as email_subject,
        template as parent_template_id,
        text_only as is_text_only,
        updated_at as updated_timestamp,
        url as email_template_url,
        version as version_type,
        web_view as has_web_view_enabled,
        workspace as workspace_name
    from macro

), versions as (

    select  
        *,
        row_number() over (partition by email_template_id order by updated_timestamp) as inferred_version,
        count(*) over (partition by email_template_id) as total_count_of_versions
    from fields

), valid as (

    select 
        *, 
        case
            when inferred_version = 1 then created_timestamp
            else updated_timestamp
        end as valid_from,
        lead(updated_timestamp) over (partition by email_template_id order by updated_timestamp) as valid_to,
        inferred_version = total_count_of_versions as is_most_recent_version
    from versions

), surrogate_key as (

    select 
        *,
        {{ dbt_utils.generate_surrogate_key(['email_template_id','inferred_version'] )}} as email_template_history_id
    from valid

)

select *
from surrogate_key




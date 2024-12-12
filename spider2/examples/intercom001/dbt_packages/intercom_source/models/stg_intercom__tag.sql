with base as (

    select * 
    from {{ ref('stg_intercom__tag_tmp') }}

),

fields as (

    select
    /*
    The below macro is used to generate the correct SQL for package staging models. It takes a list of columns 
    that are expected/needed (staging_columns from dbt_intercom_source/models/tmp/) and compares it with columns 
    in the source (source_columns from dbt_intercom_source/macros/).
    For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
    */

        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_intercom__tag_tmp')),
                staging_columns=get_tag_columns()
            )
        }}
    from base
),

final as (
    
    select 
        id as tag_id,
        trim(name) as name,
        _fivetran_deleted
    from fields
)

select *
from final
where not coalesce(_fivetran_deleted, false)
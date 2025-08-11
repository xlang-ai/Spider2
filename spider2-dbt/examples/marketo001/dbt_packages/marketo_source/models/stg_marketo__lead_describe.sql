with base as (

    select *
    from {{ ref('stg_marketo__lead_describe_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_marketo__lead_describe_tmp')),
                staging_columns=get_lead_describe_columns()
            )
        }}
    from base

), fields as (

    select
        data_type,
        display_name,
        id as lead_describe_id,
        length as field_max_length,
        restname as rest_name,
        restread_only as is_rest_readonly,
        soapname as soap_name,
        soapread_only as is_soap_readonly
    from macro

), regex as (

    select 
        *,
        case
            when rest_name like '%\\_\\_c%' then lower(rest_name)
            else ltrim(lower(regexp_replace(rest_name, '[A-Z]','_\\0')),'_')
        end as rest_name_xf
    from fields

)

select *
from regex



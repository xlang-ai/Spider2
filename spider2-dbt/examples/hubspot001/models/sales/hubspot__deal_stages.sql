{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_deal_enabled'])) }}

with deals_enhanced as (

    select *
    from {{ ref('int_hubspot__deals_enhanced') }}

), deal_stage as (

    select *
    from {{ var('deal_stage') }}

), pipeline_stage as (

    select *
    from {{ var('deal_pipeline_stage') }}

), pipeline as (

    select *
    from {{ var('deal_pipeline') }}

), final as (

    select
        deal_stage.deal_id || '-' || row_number() over(partition by deal_stage.deal_id order by deal_stage.date_entered asc) as deal_stage_id,
        deals_enhanced.deal_id,
        deals_enhanced.deal_name,

        {% if var('hubspot_merged_deal_enabled', false) %}
        deals_enhanced.merged_deal_ids,
        {% endif %}
        
        deal_stage._fivetran_start as date_stage_entered,
        deal_stage._fivetran_end as date_stage_exited,
        deal_stage._fivetran_active as is_stage_active,
        deal_stage.deal_stage_name as pipeline_stage_id,
        pipeline_stage.pipeline_stage_label,
        pipeline_stage.deal_pipeline_id as pipeline_id,
        pipeline.pipeline_label,
        deal_stage.source,
        deal_stage.source_id,
        pipeline_stage.is_active as is_pipeline_stage_active,
        pipeline.is_active as is_pipeline_active,
        pipeline_stage.is_closed_won as is_pipeline_stage_closed_won,
        pipeline_stage.display_order as pipeline_stage_display_order,
        pipeline.display_order as pipeline_display_order,
        pipeline_stage.probability as pipeline_stage_probability,
        coalesce(pipeline.is_deal_pipeline_deleted, false) as is_deal_pipeline_deleted,
        coalesce(pipeline_stage.is_deal_pipeline_stage_deleted, false) as is_deal_pipeline_stage_deleted,
        coalesce(deals_enhanced.is_deal_deleted, false) as is_deal_deleted,
        pipeline_stage.deal_pipeline_stage_created_at,
        pipeline_stage.deal_pipeline_stage_updated_at

    from deal_stage

    left join pipeline_stage
        on deal_stage.deal_stage_name = pipeline_stage.deal_pipeline_stage_id
    
    left join pipeline
        on pipeline_stage.deal_pipeline_id = pipeline.deal_pipeline_id

    left join deals_enhanced
        on deal_stage.deal_id = deals_enhanced.deal_id
)

select * 
from final
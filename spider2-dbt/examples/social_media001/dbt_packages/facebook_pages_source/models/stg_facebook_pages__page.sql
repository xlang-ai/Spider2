
with base as (

    select * 
    from {{ ref('stg_facebook_pages__page_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_facebook_pages__page_tmp')),
                staging_columns=get_page_columns()
            )
        }}
                
        {{ fivetran_utils.source_relation(
            union_schema_variable='facebook_pages_union_schemas', 
            union_database_variable='facebook_pages_union_databases') 
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_deleted,
        _fivetran_synced,
        affiliation,
        app_id,
        artists_we_like,
        attire,
        awards,
        band_interests,
        band_members,
        bio,
        birthday,
        booking_agent,
        built,
        can_checkin,
        can_post,
        category,
        category_list,
        checkins,
        company_overview,
        culinary_team,
        current_location,
        description as page_description,
        directed_by,
        display_subtext,
        emails,
        fan_count,
        features,
        food_styles,
        founded,
        general_info,
        general_manager,
        genre,
        global_brand_page_name,
        has_added_app,
        has_transitioned_to_new_page_experience,
        has_whatsapp_number,
        hometown,
        id as page_id,
        impressum,
        influences,
        is_always_open,
        is_chain,
        is_community_page,
        is_eligible_for_branded_content,
        is_messenger_bot_get_started_enabled,
        is_messenger_platform_bot,
        is_owned,
        is_permanently_closed,
        is_published,
        is_unclaimed,
        members,
        mission,
        mpg,
        name as page_name,
        network,
        new_like_count,
        overall_star_rating,
        personal_info,
        personal_interests,
        pharma_safety_info,
        phone,
        place_type,
        plot_outline,
        press_contact,
        price_range,
        produced_by,
        products,
        promotion_eligible,
        promotion_ineligible_reason,
        public_transit,
        rating_count,
        record_label,
        release_date,
        schedule,
        screenplay_by,
        season,
        single_line_address,
        starring,
        store_number,
        studio,
        talking_about_count,
        username,
        website,
        were_here_count,
        whatsapp_number,
        written_by,
        source_relation
    from fields
)

select * from final

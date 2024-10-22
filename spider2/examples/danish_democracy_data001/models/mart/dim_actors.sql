with

actors as (
    select * from {{ ref('stg_actors') }}
),

actor_types as (
    select * from {{ ref('stg_actor_types') }}
),

final as (
    select
        -- key
        {{ dbt_utils.generate_surrogate_key(['actor_id']) }} as actor_sk,

        -- attributes
        actors.full_name,
        actors.gender,
        actors.birth_date,
        actors.death_date,
        actors.group_short_name,
        actors.party_name,
        actors.party_short_name,
        actor_types.actor_type,

        -- meta
        actors.updated_at
    from actors
    left join actor_types
        on actors.actor_type_id = actor_types.actor_type_id
)

select * from final

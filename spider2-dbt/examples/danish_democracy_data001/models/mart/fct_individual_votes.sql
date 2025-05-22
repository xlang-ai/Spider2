with

individual_votes as (
    select * from {{ ref('stg_individual_votes') }}
),

votes as (
    select * from {{ ref('stg_votes') }}
),

meetings as (
    select * from {{ ref('stg_meetings') }}
),

individual_voting_types as (
    select * from {{ ref('stg_individual_voting_types') }}
),

final as (
    select
        -- surrogate keys
        {{ dbt_utils.generate_surrogate_key(
                ['individual_votes.individual_vote_id']
            ) 
        }} as individual_vote_sk,
        {{ dbt_utils.generate_surrogate_key(
                ['individual_votes.vote_id']
            ) 
        }} as vote_sk,
        {{ dbt_utils.generate_surrogate_key(
                ['individual_votes.actor_id']
            ) 
        }} as actor_sk,
        {{ dbt_utils.generate_surrogate_key(
                ['votes.meeting_id']
            ) 
        }} as meeting_sk,
        {{ dbt_utils.generate_surrogate_key(
                ['votes.case_step_id']
            ) 
        }} as case_sk,
        {{ dbt_utils.generate_surrogate_key(
                ['cast(meetings.meeting_date as date)']
            ) 
        }} as date_sk,

        -- degenerate dimension
        individual_voting_types.individual_voting_type,

        -- meta
        individual_votes.individual_votes_updated_at
    from individual_votes
    left join votes
        on individual_votes.vote_id = votes.vote_id
    left join meetings
        on votes.meeting_id = meetings.meeting_id
    left join individual_voting_types
        on
            individual_votes.individual_voting_type_id
            = individual_voting_types.individual_voting_type_id
)

select * from final

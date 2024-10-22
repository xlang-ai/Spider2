{{
    config(
        materialized='table',
        unique_key='order_lines_unique_key',
        incremental_strategy='delete+insert',
        cluster_by=['order_line_id']
        ) 
}}

with transactions as (
    select 
        *,
        {{ dbt_utils.generate_surrogate_key(['source_relation', 'transaction_id'])}} as transactions_unique_id
    from {{ var('shopify_transaction') }}

    {% if is_incremental() %}
-- use created_timestamp instead of processed_at since a record could be created but not processed
    where cast(created_timestamp as date) >= {{ shopify.shopify_lookback(from_date="max(cast(created_timestamp as date))", interval=var('lookback_window', 7), datepart='day') }}
    {% endif %}

), tender_transactions as (

    select *
    from {{ var('shopify_tender_transaction') }}

), joined as (
    select 
        transactions.*,
        tender_transactions.payment_method,
        parent_transactions.created_timestamp as parent_created_timestamp,
        parent_transactions.kind as parent_kind,
        parent_transactions.amount as parent_amount,
        parent_transactions.status as parent_status
    from transactions
    left join tender_transactions
        on transactions.transaction_id = tender_transactions.transaction_id
        and transactions.source_relation = tender_transactions.source_relation
    left join transactions as parent_transactions
        on transactions.parent_id = parent_transactions.transaction_id
        and transactions.source_relation = parent_transactions.source_relation

), exchange_rate as (

    select
        *
    from joined

)

select *
from exchange_rate
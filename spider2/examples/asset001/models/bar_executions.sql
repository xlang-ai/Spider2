select 
    date, 
    concat(ticker, ts) as tt_key, 
    ts, 
    ticker, 
    aggregate_qty
from (
    select 
        cast(ts as date) as date, 
        ts::timestamp as ts,
        ticker,
        sum(case when side_cd = 'B' then quantity else -1 * quantity end) as aggregate_qty
    from {{ ref('stg_executions') }}

    group by 
        cast(ts as date), 
        ts::timestamp,
        ticker
) as foo

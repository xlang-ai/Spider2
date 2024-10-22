select x.*, dollar_value / agg_quantity as vwap
from (
    select 
        ticker, 
        event_ts, 
        sum(size) over (partition by ticker order by event_ts) as agg_quantity, 
        sum(size * price) over (partition by ticker order by event_ts) as dollar_value,
        avg(price) over (partition by ticker order by extract(epoch from event_ts) range between 20 preceding and current row) as sma
    from {{ ref('stg_market_trades') }} 
) x

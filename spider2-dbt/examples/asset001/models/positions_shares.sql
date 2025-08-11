select date, tt_key, ts, ticker, sum(aggregate_qty) over (partition by ticker order by ts) shares
from 
{{ ref('bar_executions')}}
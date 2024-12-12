select * from {{ source("nba", "xf_series_to_seed") }} group by all

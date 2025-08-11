select series_id, seed from {{ ref("nba_raw_xf_series_to_seed") }}

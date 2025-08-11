select
    id,
    type,
    strptime("Year" || "Date", '%Y %b %-d')::date as "date",
    "Start (ET)",
    "Visitor/Neutral" as "VisTm",
    "Home/Neutral" as "HomeTm",
    "Attend.",
    arena,
    notes,
    series_id
from 'data/nba/nba_schedule.csv'
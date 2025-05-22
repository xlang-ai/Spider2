with salesforce_opportunity_enhanced as (
    
    select *
    from {{ ref('salesforce__opportunity_enhanced') }}
), 

pipeline as (

    select 
        round(sum(created_amount_this_month)) as pipeline_created_amount_this_month,
        round(sum(created_amount_this_quarter)) as pipeline_created_amount_this_quarter,
        round(sum(created_amount_this_month * probability)) as pipeline_created_forecast_amount_this_month,
        round(sum(created_amount_this_quarter * probability)) as pipeline_created_forecast_amount_this_quarter,
        sum(created_count_this_month) as pipeline_count_created_this_month,
        sum(created_count_this_quarter) as pipeline_count_created_this_quarter,
        count(*) as total_number_pipeline,
        round(sum(amount)) as total_pipeline_amount,
        round(sum(amount * probability)) as total_pipeline_forecast_amount,
        round(avg(amount)) as avg_pipeline_opp_amount,
        max(amount) as largest_deal_in_pipeline,
        avg(days_since_created) as avg_days_open
    from salesforce_opportunity_enhanced
    where status = 'Pipeline'
), 

bookings as (

    select 
        round(sum(closed_amount_this_month)) as bookings_amount_closed_this_month,
        round(sum(closed_amount_this_quarter)) as bookings_amount_closed_this_quarter,
        count(*) as total_number_bookings,
        round(sum(amount)) as total_bookings_amount,
        sum(closed_count_this_month) as bookings_count_closed_this_month,
        sum(closed_count_this_quarter) as bookings_count_closed_this_quarter,
        round(avg(amount)) as avg_bookings_amount,
        max(amount) as largest_booking,
        avg(days_to_close) as avg_days_to_close
    from salesforce_opportunity_enhanced
    where status = 'Won'
), 

lost as (

    select 
        round(sum(closed_amount_this_month)) as lost_amount_this_month,
        round(sum(closed_amount_this_quarter)) as lost_amount_this_quarter,
        count(*) as total_number_lost,
        round(sum(amount)) as total_lost_amount,
        sum(closed_count_this_month) as lost_count_this_month,
        sum(closed_count_this_quarter) as lost_count_this_quarter
    from salesforce_opportunity_enhanced
    where status = 'Lost'
)

select 
    bookings.*,
    pipeline.*,
    lost.*,
    case 
        when (bookings.bookings_amount_closed_this_month + lost.lost_amount_this_month) = 0 then null
        else round( (bookings.bookings_amount_closed_this_month / (bookings.bookings_amount_closed_this_month + lost.lost_amount_this_month) ) * 100, 2 )
    end as win_percent_this_month,
    case 
        when (bookings.bookings_amount_closed_this_quarter + lost.lost_amount_this_quarter) = 0 then null
        else round( (bookings.bookings_amount_closed_this_quarter / (bookings.bookings_amount_closed_this_quarter + lost.lost_amount_this_quarter) ) * 100, 2 ) 
    end as win_percent_this_quarter,
    case 
        when (bookings.total_bookings_amount + lost.total_lost_amount) = 0 then null 
        else round( (bookings.total_bookings_amount / (bookings.total_bookings_amount + lost.total_lost_amount) ) * 100, 2) 
    end as total_win_percent
from bookings, pipeline, lost
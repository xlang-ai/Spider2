with contact as (

    select *
    from {{ var('contact') }}
), 

account as (

    select *
    from {{ var('account') }}
),

salesforce_user as (

    select *
    from {{ var('user') }}
)

select 
    contact.contact_id,
    contact.contact_name,
    contact.account_id,
    contact.department,
    contact.contact_description,
    contact.email,
    contact.individual_id,
    contact.is_deleted as contact_is_deleted,
    contact.last_activity_date,
    contact.lead_source,
    contact.mailing_city,
    contact.mailing_country,
    contact.mailing_country_code,
    contact.mailing_postal_code,
    contact.mailing_state,
    contact.mailing_state_code,
    contact.mailing_street,
    contact.master_record_id,
    contact.mobile_phone,
    contact.owner_id as contact_owner_id,
    contact.phone,
    contact.reports_to_id,
    salesforce_user.user_name as contact_owner_name,
    account.account_name,
    account.account_number,
    account.account_source,
    account.annual_revenue as account_annual_revenue,
    account.account_description,
    account.industry as account_industry,
    account.is_deleted as account_is_deleted,
    account.number_of_employees as account_number_of_employees,
    account.owner_id as account_owner_id,
    account.parent_id as account_parent_id,
    account.rating as account_rating,
    account.type as account_type

        --The below scripts allows for pass through columns.
    {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='salesforce__contact_pass_through_columns', identifier='contact') }}
    {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='salesforce__account_pass_through_columns', identifier='account') }}
    {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='salesforce__user_pass_through_columns', identifier='salesforce_user') }}

from contact
left join account 
    on contact.account_id = account.account_id
left join salesforce_user
    on contact.owner_id = salesforce_user.user_id
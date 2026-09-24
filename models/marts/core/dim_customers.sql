with int_customers as (
    select * from {{ ref('int_customers_cleaned') }}
),

subscription_states as (
    select * from {{ ref('int_customer_subscription_states') }}
),

conversion_cohorts as (
    select * from {{ ref('int_customer_conversions') }}
),

final as (
    select
        c.customer_id,
        c.customer_email,
        c.is_valid_email_format,
        c.country_code,
        c.acquisition_channel_id,
        c.signed_up_at,
        coalesce(ss.current_plan_id, 'unsubscribed') as current_plan_id,
        coalesce(ss.current_status, 'inactive') as current_status,
        coalesce(ss.normalized_customer_lifecycle_state, 'inactive') as lifecycle_state,
        coalesce(ss.current_mrr, 0.00) as current_mrr,
        coalesce(ch.trial_conversion_cohort, 'Unknown') as trial_conversion_cohort
    from int_customers c
    left join subscription_states ss
        on c.customer_id = ss.customer_id
    left join conversion_cohorts ch
        on c.customer_id = ch.customer_id
)

select * from final

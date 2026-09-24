{{
  config(
    materialized='table'
  )
}}

with customers as (
    select * from {{ ref('dim_customers') }}
),

plans as (
    select * from {{ ref('dim_plans') }}
),

marketing_channels as (
    select * from {{ ref('dim_marketing_channels') }}
),

final as (
    select
        c.customer_id,
        c.customer_email,
        c.country_code,
        mc.channel_name,
        c.signed_up_at,
        coalesce(p.plan_name, 'unsubscribed') as current_plan,
        c.current_status,
        c.current_mrr,
        c.trial_conversion_cohort
    from customers c
    left join plans p
        on c.current_plan_id = p.plan_id
    left join marketing_channels mc
        on c.acquisition_channel_id = mc.channel_id
)

select * from final

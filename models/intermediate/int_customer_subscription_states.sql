with subscriptions as (
    select * from {{ ref('int_subscriptions_enriched') }}
),

ranked_historical_states as (
    select
        customer_id,
        plan_id,
        clear_mrr_amount,
        subscription_status,
        -- Window function to rank subscriptions by timeline
        row_number() over (
            partition by customer_id
            order by valid_from_date desc, subscription_id desc
        ) as state_rank
    from subscriptions
)

select
    customer_id,
    plan_id as current_plan_id,
    clear_mrr_amount as current_mrr,
    subscription_status as current_status,
    case
        when subscription_status = 'cancelled' then 'churned'
        when subscription_status = 'upgraded' then 'active'
        else subscription_status
    end as normalized_customer_lifecycle_state
from ranked_historical_states
where state_rank = 1

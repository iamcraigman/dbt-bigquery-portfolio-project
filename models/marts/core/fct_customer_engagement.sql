with customers as (
    select * from {{ ref('dim_customers') }}
),

usage_logs as (
    select * from {{ ref('stg_subscription_platform__usage_logs') }}
),

customer_usage as (
    select
        customer_id,
        count(*) as total_events,
        countif(event_action = 'login') as login_count,
        countif(event_action != 'login') as feature_action_count,
        count(distinct feature_name) as distinct_features_used,
        min(event_at) as first_event_at,
        max(event_at) as last_event_at
    from usage_logs
    group by customer_id
),

final as (
    select
        c.customer_id,
        c.lifecycle_state,
        c.current_mrr,
        coalesce(u.total_events, 0) as total_events,
        coalesce(u.login_count, 0) as login_count,
        coalesce(u.feature_action_count, 0) as feature_action_count,
        coalesce(u.distinct_features_used, 0) as distinct_features_used,
        u.first_event_at,
        u.last_event_at,
        u.customer_id is not null as has_product_activity
    from customers c
    left join customer_usage u
        on c.customer_id = u.customer_id
)

select * from final

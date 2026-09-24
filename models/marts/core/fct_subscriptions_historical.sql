{{
  config(
    materialized='incremental',
    unique_key='subscription_id',
    incremental_strategy='merge'
  )
}}

with subscriptions as (
    select * from {{ ref('stg_subscription_platform__subscriptions') }}
),

final as (
    select
        subscription_id,
        customer_id,
        subscription_plan,
        mrr_amount,
        subscription_status,
        valid_from_date,
        valid_to_date,
        case
            when subscription_status = 'active' then true
            else false
        end as is_currently_active
    from subscriptions
)

select * from final

-- The engine room of incremental loading:
{% if is_incremental() %}
  -- Pick up new subscriptions, plus any subscription still open in the target:
  -- open rows are the only ones that can later be cancelled, upgraded or end-dated,
  -- so re-merging them keeps status and valid_to_date current.
  where valid_from_date >= (select max(valid_from_date) from {{ this }})
     or subscription_id in (select subscription_id from {{ this }} where valid_to_date is null)
{% endif %}

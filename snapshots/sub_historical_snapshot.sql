{% snapshot sub_historical_snapshot %}

{{
    config(
      schema='snapshots',
      unique_key='subscription_id',
      strategy='check',
      check_cols=['status', 'monthly_amount'],
    )
}}

select * from {{ source('subscription_platform', 'raw_subscriptions') }}

{% endsnapshot %}

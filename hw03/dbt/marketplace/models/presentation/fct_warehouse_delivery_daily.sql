{{
  config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    partition_by=['shipment_date'],
    on_schema_change='sync_all_columns',
    schema='presentation',
    tags=['presentation', 'warehouse_delivery']
  )
}}

{% set business_date_var = var('business_date', none) %}
{% set delay_threshold_min = var('warehouse_processing_delay_min', 1440) %}

with params as (
    select
        {% if business_date_var %}
        to_date('{{ business_date_var }}') as business_date,
        {% else %}
        date_sub(current_date, 1) as business_date,
        {% endif %}
        cast({{ delay_threshold_min }} as double) as delay_threshold_min
),

shipments_dedup as (
    select
        l.SHIPMENT_EXTERNAL_ID,
        l.ORDER_EXTERNAL_ID,
        l.WAREHOUSE_CODE,
        l.DISPATCHED_DATE,
        l.PACKAGE_COUNT,
        row_number() over (
            partition by l.SHIPMENT_EXTERNAL_ID
            order by l.SOURCE_TIMESTAMP desc, l.EFFECTIVE_FROM desc
        ) as rn
    from {{ ref('v_stg_logistics') }} l
    where coalesce(cast(l.IS_DELETED as boolean), false) = false
),

shipments_for_day as (
    select
        to_date(s.DISPATCHED_DATE) as shipment_date,
        cast(s.WAREHOUSE_CODE as string) as warehouse_id,
        s.ORDER_EXTERNAL_ID,
        s.PACKAGE_COUNT,
        s.DISPATCHED_DATE
    from shipments_dedup s
    cross join params p
    where s.rn = 1
      and s.DISPATCHED_DATE is not null
      and to_date(s.DISPATCHED_DATE) = p.business_date
),

orders_dedup as (
    select
        o.ORDER_EXTERNAL_ID,
        o.USER_EXTERNAL_ID,
        o.ORDER_DATE,
        row_number() over (
            partition by o.ORDER_EXTERNAL_ID
            order by o.SOURCE_TIMESTAMP desc, o.ORDER_EFFECTIVE_FROM desc
        ) as rn
    from {{ ref('v_stg_orders') }} o
    where coalesce(cast(o.IS_DELETED as boolean), false) = false
),

orders_latest as (
    select
        ORDER_EXTERNAL_ID,
        USER_EXTERNAL_ID,
        ORDER_DATE
    from orders_dedup
    where rn = 1
),

warehouses_dedup as (
    select
        w.WAREHOUSE_CODE,
        w.WAREHOUSE_NAME,
        row_number() over (
            partition by w.WAREHOUSE_CODE
            order by w.SOURCE_TIMESTAMP desc, w.WAREHOUSE_EFFECTIVE_FROM desc
        ) as rn
    from {{ ref('v_stg_warehouses') }} w
    where coalesce(cast(w.IS_DELETED as boolean), false) = false
),

warehouses_latest as (
    select
        WAREHOUSE_CODE,
        WAREHOUSE_NAME
    from warehouses_dedup
    where rn = 1
),

shipment_facts as (
    select
        s.shipment_date,
        s.warehouse_id,
        coalesce(w.WAREHOUSE_NAME, s.warehouse_id) as warehouse_name,
        s.ORDER_EXTERNAL_ID,
        o.USER_EXTERNAL_ID,
        cast(coalesce(s.PACKAGE_COUNT, 0) as decimal(18, 2)) as shipment_qty,
        case
            when o.ORDER_DATE is not null and s.DISPATCHED_DATE is not null
            then (unix_timestamp(s.DISPATCHED_DATE) - unix_timestamp(o.ORDER_DATE)) / 60.0
            else null
        end as processing_time_min
    from shipments_for_day s
    left join orders_latest o
      on s.ORDER_EXTERNAL_ID = o.ORDER_EXTERNAL_ID
    left join warehouses_latest w
      on s.warehouse_id = w.WAREHOUSE_CODE
),

aggregated as (
    select
        f.shipment_date,
        f.warehouse_id,
        f.warehouse_name,
        cast(count(distinct f.ORDER_EXTERNAL_ID) as int) as order_count,
        cast(sum(f.shipment_qty) as decimal(18, 2)) as total_shipment_qty,
        cast(avg(f.processing_time_min) as decimal(18, 2)) as avg_processing_time_min,
        cast(
            sum(
                case
                    when f.processing_time_min > p.delay_threshold_min then 1
                    else 0
                end
            ) as int
        ) as delayed_orders_count,
        cast(count(distinct f.USER_EXTERNAL_ID) as int) as unique_customers_count
    from shipment_facts f
    cross join params p
    group by f.shipment_date, f.warehouse_id, f.warehouse_name
)

select
    shipment_date,
    warehouse_id,
    warehouse_name,
    order_count,
    total_shipment_qty,
    avg_processing_time_min,
    delayed_orders_count,
    unique_customers_count
from aggregated

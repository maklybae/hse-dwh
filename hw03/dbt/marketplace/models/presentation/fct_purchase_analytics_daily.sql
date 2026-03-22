{{
  config(
    materialized='table',
    on_schema_change='sync_all_columns',
    schema='presentation',
    tags=['presentation', 'purchase_analytics']
  )
}}

with order_items_dedup as (
    select
        o.ORDER_EXTERNAL_ID,
        o.ORDER_ITEM_ID,
        o.PRODUCT_SKU,
        o.PRODUCT_NAME,
        o.PRODUCT_CATEGORY,
        o.PRODUCT_BRAND,
        o.PRODUCT_NAME_SNAPSHOT,
        o.PRODUCT_CATEGORY_SNAPSHOT,
        o.PRODUCT_BRAND_SNAPSHOT,
        o.ORDER_DATE,
        o.QUANTITY,
        o.UNIT_PRICE,
        o.TOTAL_PRICE,
        row_number() over (
            partition by coalesce(cast(o.ORDER_ITEM_ID as string), concat_ws('|', o.ORDER_EXTERNAL_ID, o.PRODUCT_SKU))
            order by o.SOURCE_TIMESTAMP desc, o.ORDER_EFFECTIVE_FROM desc
        ) as rn
    from {{ ref('v_stg_orders') }} o
    where coalesce(cast(o.IS_DELETED as boolean), false) = false
      and o.ORDER_DATE is not null
      and o.PRODUCT_SKU is not null
),

order_items_latest as (
    select
        to_date(from_unixtime(cast(ORDER_DATE / 1000000 as bigint))) as purchase_date,
        cast(pmod(hash(cast(PRODUCT_SKU as string)), 2147483647) as int) as product_id,
        coalesce(PRODUCT_NAME, PRODUCT_NAME_SNAPSHOT, cast(PRODUCT_SKU as string)) as product_name,
        coalesce(PRODUCT_CATEGORY, PRODUCT_CATEGORY_SNAPSHOT, 'UNKNOWN') as category,
        coalesce(PRODUCT_BRAND, PRODUCT_BRAND_SNAPSHOT, 'UNKNOWN') as supplier_name,
        cast(coalesce(QUANTITY, 0) as decimal(18, 2)) as quantity,
        cast(coalesce(UNIT_PRICE, 0) as decimal(18, 2)) as unit_price,
        cast(coalesce(TOTAL_PRICE, 0) as decimal(18, 2)) as total_price
    from order_items_dedup
    where rn = 1
),

aggregated as (
    select
        purchase_date,
        product_id,
        product_name,
        category,
        concat('SUP_', cast(pmod(hash(supplier_name), 2147483647) as string)) as supplier_id,
        supplier_name,
        cast(sum(quantity) as decimal(18, 2)) as purchase_qty,
        cast(sum(total_price) as decimal(18, 2)) as total_purchase_amount,
        cast(
            case
                when sum(quantity) = 0 then 0
                else sum(total_price) / sum(quantity)
            end as decimal(18, 2)
        ) as avg_unit_price
    from order_items_latest
    group by purchase_date, product_id, product_name, category, supplier_name
)

select
    purchase_date,
    product_id,
    product_name,
    category,
    supplier_id,
    supplier_name,
    purchase_qty,
    total_purchase_amount,
    avg_unit_price
from aggregated

-- Wide feed: ORDERS joined with ORDER_ITEMS and PRODUCTS.
-- Pass --vars '{"load_date": "YYYY-MM-DD"}' for incremental load (filters by CDC event date).
-- Omit the variable for a full initial load.
{% set load_date = var("load_date", none) %}

SELECT
    -- ORDERS
    o.order_external_id                     AS ORDER_EXTERNAL_ID,
    o.user_external_id                      AS USER_EXTERNAL_ID,
    o.order_number                          AS ORDER_NUMBER,
    o.order_date                            AS ORDER_DATE,
    o.status                                AS ORDER_STATUS,
    o.subtotal                              AS SUBTOTAL,
    o.tax_amount                            AS TAX_AMOUNT,
    o.shipping_cost                         AS SHIPPING_COST,
    o.discount_amount                       AS DISCOUNT_AMOUNT,
    o.total_amount                          AS TOTAL_AMOUNT,
    o.currency                              AS CURRENCY,
    o.delivery_address_external_id          AS DELIVERY_ADDRESS_EXTERNAL_ID,
    o.delivery_type                         AS DELIVERY_TYPE,
    o.expected_delivery_date                AS EXPECTED_DELIVERY_DATE,
    o.actual_delivery_date                  AS ACTUAL_DELIVERY_DATE,
    o.payment_method                        AS PAYMENT_METHOD,
    o.payment_status                        AS PAYMENT_STATUS,
    o.effective_from                        AS ORDER_EFFECTIVE_FROM,
    o.created_at                            AS ORDER_CREATED_AT,

    -- ORDER_ITEMS
    oi.order_item_id                        AS ORDER_ITEM_ID,
    oi.product_sku                          AS PRODUCT_SKU,
    oi.quantity                             AS QUANTITY,
    oi.unit_price                           AS UNIT_PRICE,
    oi.total_price                          AS TOTAL_PRICE,
    oi.product_name_snapshot                AS PRODUCT_NAME_SNAPSHOT,
    oi.product_category_snapshot            AS PRODUCT_CATEGORY_SNAPSHOT,
    oi.product_brand_snapshot               AS PRODUCT_BRAND_SNAPSHOT,

    -- PRODUCTS
    p.product_name                          AS PRODUCT_NAME,
    p.category                              AS PRODUCT_CATEGORY,
    p.brand                                 AS PRODUCT_BRAND,
    p.price                                 AS PRODUCT_PRICE,
    p.currency                              AS PRODUCT_CURRENCY,
    p.weight_grams                          AS PRODUCT_WEIGHT_GRAMS,
    p.dimensions_length_cm                  AS PRODUCT_DIM_LENGTH_CM,
    p.dimensions_width_cm                   AS PRODUCT_DIM_WIDTH_CM,
    p.dimensions_height_cm                  AS PRODUCT_DIM_HEIGHT_CM,

    -- CDC metadata
    COALESCE(o.__deleted, false)              AS IS_DELETED,
    CAST(o.__source_ts_ms / 1000 AS TIMESTAMP) AS SOURCE_TIMESTAMP

FROM {{ source('order_service', 'orders') }} AS o
LEFT JOIN {{ source('order_service', 'order_items') }} AS oi
    ON oi.order_external_id = o.order_external_id
LEFT JOIN {{ source('order_service', 'products') }} AS p
    ON p.product_sku = oi.product_sku
{% if load_date %}
WHERE CAST(o.__source_ts_ms / 1000 AS TIMESTAMP)::DATE = '{{ load_date }}'::DATE
{% endif %}

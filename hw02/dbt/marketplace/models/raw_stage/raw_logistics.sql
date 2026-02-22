-- Wide feed: SHIPMENTS joined with WAREHOUSES (origin) and PICKUP_POINTS (destination).
-- Pass --vars '{"load_date": "YYYY-MM-DD"}' for incremental load.
-- Omit the variable for a full initial load.
{% set load_date = var("load_date", none) %}

SELECT
    -- SHIPMENTS
    s.shipment_external_id                  AS SHIPMENT_EXTERNAL_ID,
    s.order_external_id                     AS ORDER_EXTERNAL_ID,
    s.tracking_number                       AS TRACKING_NUMBER,
    s.status                                AS SHIPMENT_STATUS,
    s.weight_grams                          AS WEIGHT_GRAMS,
    s.volume_cubic_cm                       AS VOLUME_CUBIC_CM,
    s.package_count                         AS PACKAGE_COUNT,
    s.origin_warehouse_code                 AS ORIGIN_WAREHOUSE_CODE,
    s.destination_type                      AS DESTINATION_TYPE,
    s.destination_pickup_point_code         AS DESTINATION_PICKUP_POINT_CODE,
    s.destination_address_external_id       AS DESTINATION_ADDRESS_EXTERNAL_ID,
    s.created_date                          AS SHIPMENT_CREATED_DATE,
    s.dispatched_date                       AS DISPATCHED_DATE,
    s.estimated_delivery_date               AS ESTIMATED_DELIVERY_DATE,
    s.actual_delivery_date                  AS ACTUAL_DELIVERY_DATE,
    s.recipient_name                        AS RECIPIENT_NAME,
    s.effective_from                        AS SHIPMENT_EFFECTIVE_FROM,

    -- WAREHOUSES (origin)
    w.warehouse_code                        AS WAREHOUSE_CODE,
    w.warehouse_name                        AS WAREHOUSE_NAME,
    w.warehouse_type                        AS WAREHOUSE_TYPE,
    w.country                               AS WAREHOUSE_COUNTRY,
    w.city                                  AS WAREHOUSE_CITY,
    w.max_capacity_cubic_meters             AS WAREHOUSE_MAX_CAPACITY,
    w.operating_hours                       AS WAREHOUSE_OPERATING_HOURS,
    w.contact_phone                         AS WAREHOUSE_CONTACT_PHONE,

    -- PICKUP_POINTS (destination)
    pp.pickup_point_code                    AS PICKUP_POINT_CODE,
    pp.pickup_point_name                    AS PICKUP_POINT_NAME,
    pp.pickup_point_type                    AS PICKUP_POINT_TYPE,
    pp.partner_name                         AS PICKUP_POINT_PARTNER_NAME,
    pp.operating_hours                      AS PICKUP_POINT_OPERATING_HOURS,
    pp.contact_phone                        AS PICKUP_POINT_CONTACT_PHONE,
    pp.country                              AS PICKUP_POINT_COUNTRY,
    pp.city                                 AS PICKUP_POINT_CITY

FROM {{ source('logistics_service', 'shipments') }} AS s
LEFT JOIN {{ source('logistics_service', 'warehouses') }} AS w
    ON w.warehouse_code = s.origin_warehouse_code
LEFT JOIN {{ source('logistics_service', 'pickup_points') }} AS pp
    ON pp.pickup_point_code = s.destination_pickup_point_code
{% if load_date %}
WHERE s.created_date::DATE = '{{ load_date }}'::DATE
{% endif %}

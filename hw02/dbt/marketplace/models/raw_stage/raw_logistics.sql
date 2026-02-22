-- Shipment feed from SHIPMENTS table only.
-- Warehouse and pickup point data loaded via separate raw feeds (raw_warehouses, raw_pickup_points).
-- Pass --vars '{"load_date": "YYYY-MM-DD"}' for incremental load.
-- Omit the variable for a full initial load.
{% set load_date = var("load_date", none) %}

SELECT
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
    s.delivery_notes                        AS DELIVERY_NOTES,
    s.delivery_signature                    AS DELIVERY_SIGNATURE,
    s.effective_from                        AS SHIPMENT_EFFECTIVE_FROM

FROM {{ source('logistics_service', 'shipments') }} AS s
{% if load_date %}
WHERE s.created_date::DATE = '{{ load_date }}'::DATE
{% endif %}

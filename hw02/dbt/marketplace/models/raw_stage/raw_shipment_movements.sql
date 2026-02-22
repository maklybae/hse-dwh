-- Shipment movement events.
-- Pass --vars '{"load_date": "YYYY-MM-DD"}' for incremental load.
-- Omit the variable for a full initial load.
{% set load_date = var("load_date", none) %}

SELECT
    m.shipment_external_id                  AS SHIPMENT_EXTERNAL_ID,
    m.movement_type                         AS MOVEMENT_TYPE,
    m.location_type                         AS LOCATION_TYPE,
    m.location_code                         AS LOCATION_CODE,
    m.movement_datetime                     AS MOVEMENT_DATETIME,
    m.operator_name                         AS OPERATOR_NAME,
    m.latitude                              AS LATITUDE,
    m.longitude                             AS LONGITUDE,
    m.notes                                 AS NOTES

FROM {{ source('logistics_service', 'shipment_movements') }} AS m
{% if load_date %}
WHERE m.movement_datetime::DATE = '{{ load_date }}'::DATE
{% endif %}

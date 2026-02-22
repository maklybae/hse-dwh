-- Shipment status change events.
-- Pass --vars '{"load_date": "YYYY-MM-DD"}' for incremental load.
-- Omit the variable for a full initial load.
{% set load_date = var("load_date", none) %}

SELECT
    h.shipment_external_id                  AS SHIPMENT_EXTERNAL_ID,
    h.old_status                            AS OLD_STATUS,
    h.new_status                            AS NEW_STATUS,
    h.change_reason                         AS CHANGE_REASON,
    h.location_type                         AS LOCATION_TYPE,
    h.location_code                         AS LOCATION_CODE,
    h.changed_at                            AS CHANGED_AT,
    h.changed_by                            AS CHANGED_BY,
    h.notes                                 AS NOTES,
    h.customer_notified                     AS CUSTOMER_NOTIFIED

FROM {{ source('logistics_service', 'shipment_status_history') }} AS h
{% if load_date %}
WHERE h.changed_at::DATE = '{{ load_date }}'::DATE
{% endif %}

-- Direct feed from pickup_points table (no join required).
-- Pass --vars '{"load_date": "YYYY-MM-DD"}' for incremental load (filters by CDC event date).
-- Omit the variable for a full initial load.
{% set load_date = var("load_date", none) %}

SELECT
    pp.pickup_point_code    AS PICKUP_POINT_CODE,
    pp.pickup_point_name    AS PICKUP_POINT_NAME,
    pp.pickup_point_type    AS PICKUP_POINT_TYPE,
    pp.country              AS PICKUP_POINT_COUNTRY,
    pp.region               AS PICKUP_POINT_REGION,
    pp.city                 AS PICKUP_POINT_CITY,
    pp.street_address       AS PICKUP_POINT_STREET_ADDRESS,
    pp.postal_code          AS PICKUP_POINT_POSTAL_CODE,
    pp.is_active            AS PICKUP_POINT_IS_ACTIVE,
    pp.max_capacity_packages AS PICKUP_POINT_MAX_CAPACITY,
    pp.operating_hours      AS PICKUP_POINT_OPERATING_HOURS,
    pp.contact_phone        AS PICKUP_POINT_CONTACT_PHONE,
    pp.partner_name         AS PICKUP_POINT_PARTNER_NAME,
    pp.effective_from       AS PICKUP_POINT_EFFECTIVE_FROM,
    pp.created_at           AS PICKUP_POINT_CREATED_AT,

    -- CDC metadata
    COALESCE(pp.__deleted, false) AS IS_DELETED,
    CAST(pp.__source_ts_ms / 1000 AS TIMESTAMP) AS SOURCE_TIMESTAMP
FROM {{ source('logistics_service', 'pickup_points') }} AS pp
{% if load_date %}
WHERE CAST(pp.__source_ts_ms / 1000 AS TIMESTAMP)::DATE = '{{ load_date }}'::DATE
{% endif %}

-- Direct feed from warehouses table (no join required).
-- Pass --vars '{"load_date": "YYYY-MM-DD"}' for incremental load (filters by CDC event date).
-- Omit the variable for a full initial load.
{% set load_date = var("load_date", none) %}

SELECT
    w.warehouse_code        AS WAREHOUSE_CODE,
    w.warehouse_name        AS WAREHOUSE_NAME,
    w.warehouse_type        AS WAREHOUSE_TYPE,
    w.country               AS WAREHOUSE_COUNTRY,
    w.region                AS WAREHOUSE_REGION,
    w.city                  AS WAREHOUSE_CITY,
    w.street_address        AS WAREHOUSE_STREET_ADDRESS,
    w.postal_code           AS WAREHOUSE_POSTAL_CODE,
    w.is_active             AS WAREHOUSE_IS_ACTIVE,
    w.max_capacity_cubic_meters AS WAREHOUSE_MAX_CAPACITY,
    w.operating_hours       AS WAREHOUSE_OPERATING_HOURS,
    w.contact_phone         AS WAREHOUSE_CONTACT_PHONE,
    w.manager_name          AS WAREHOUSE_MANAGER_NAME,
    w.effective_from        AS WAREHOUSE_EFFECTIVE_FROM,
    w.created_at            AS WAREHOUSE_CREATED_AT,

    -- CDC metadata
    COALESCE(w.__deleted, false) AS IS_DELETED,
    CAST(w.__source_ts_ms / 1000 AS TIMESTAMP) AS SOURCE_TIMESTAMP
FROM {{ source('logistics_service', 'warehouses') }} AS w
{% if load_date %}
WHERE CAST(w.__source_ts_ms / 1000 AS TIMESTAMP)::DATE = '{{ load_date }}'::DATE
{% endif %}

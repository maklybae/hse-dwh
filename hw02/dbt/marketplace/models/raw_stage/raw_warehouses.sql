-- Direct feed from warehouses table (no join required).
-- Warehouses have their own effective_from independent of shipments.
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
    w.created_at            AS WAREHOUSE_CREATED_AT
FROM {{ source('logistics_service', 'warehouses') }} AS w

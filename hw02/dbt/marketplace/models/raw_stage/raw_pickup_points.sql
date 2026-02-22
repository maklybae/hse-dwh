-- Direct feed from pickup_points table (no join required).
-- Pickup points have their own effective_from independent of shipments.
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
    pp.created_at           AS PICKUP_POINT_CREATED_AT
FROM {{ source('logistics_service', 'pickup_points') }} AS pp

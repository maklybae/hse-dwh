-- Wide feed: USERS joined with USER_ADDRESSES.
-- Contains user profiles and their registered addresses.
-- Pass --vars '{"load_date": "YYYY-MM-DD"}' for incremental load (filters by CDC event date).
-- Omit the variable for a full initial load.
{% set load_date = var("load_date", none) %}

SELECT
    -- USERS
    u.user_external_id                      AS USER_EXTERNAL_ID,
    u.email                                 AS EMAIL,
    u.first_name                            AS FIRST_NAME,
    u.last_name                             AS LAST_NAME,
    u.phone                                 AS PHONE,
    u.date_of_birth                         AS DATE_OF_BIRTH,
    u.registration_date                     AS REGISTRATION_DATE,
    u.status                                AS USER_STATUS,
    u.effective_from                        AS USER_EFFECTIVE_FROM,
    u.created_at                            AS USER_CREATED_AT,

    -- USER_ADDRESSES
    ua.address_external_id                  AS ADDRESS_EXTERNAL_ID,
    ua.address_type                         AS ADDRESS_TYPE,
    ua.country                              AS COUNTRY,
    ua.city                                 AS CITY,
    ua.region                               AS REGION,
    ua.street_address                       AS STREET_ADDRESS,
    ua.postal_code                          AS POSTAL_CODE,
    ua.apartment                            AS APARTMENT,
    ua.is_default                           AS IS_DEFAULT_ADDRESS,
    ua.effective_from                       AS ADDRESS_EFFECTIVE_FROM,

    -- CDC metadata
    COALESCE(CAST(u.__deleted AS BOOLEAN), false) AS IS_DELETED,
    CAST(u.__source_ts_ms / 1000 AS TIMESTAMP) AS SOURCE_TIMESTAMP

FROM {{ source('user_service', 'users') }} AS u
LEFT JOIN {{ source('user_service', 'user_addresses') }} AS ua
    ON ua.user_external_id = u.user_external_id
{% if load_date %}
WHERE CAST(u.__source_ts_ms / 1000 AS TIMESTAMP)::DATE = '{{ load_date }}'::DATE
{% endif %}

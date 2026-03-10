-- User status change events.
-- Pass --vars '{"load_date": "YYYY-MM-DD"}' for incremental load (filters by CDC event date).
-- Omit the variable for a full initial load.
{% set load_date = var("load_date", none) %}

SELECT
    h.user_external_id                      AS USER_EXTERNAL_ID,
    h.old_status                            AS OLD_STATUS,
    h.new_status                            AS NEW_STATUS,
    h.change_reason                         AS CHANGE_REASON,
    h.changed_at                            AS CHANGED_AT,
    h.changed_by                            AS CHANGED_BY,
    h.session_id                            AS SESSION_ID,
    h.ip_address                            AS IP_ADDRESS,
    h.user_agent                            AS USER_AGENT,

    -- CDC metadata
    CAST(h.__source_ts_ms / 1000 AS TIMESTAMP) AS SOURCE_TIMESTAMP

FROM {{ source('user_service', 'user_status_history') }} AS h
{% if load_date %}
WHERE CAST(h.__source_ts_ms / 1000 AS TIMESTAMP)::DATE = '{{ load_date }}'::DATE
{% endif %}

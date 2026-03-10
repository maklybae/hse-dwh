{%- set source_model = "v_stg_order_status_history" -%}
{%- set src_pk = "ORDER_HK" -%}
{%- set src_hashdiff = "SAT_ORDER_STATUS_HISTORY_HASHDIFF" -%}
{%- set src_payload = ["NEW_STATUS", "CHANGE_REASON", "NOTES",
                       "CHANGED_BY", "SESSION_ID", "IP_ADDRESS"] -%}
{%- set src_eff = "EFFECTIVE_FROM" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.sat(src_pk=src_pk, src_hashdiff=src_hashdiff,
                   src_payload=src_payload, src_eff=src_eff,
                   src_ldts=src_ldts, src_source=src_source,
                   source_model=source_model) }}

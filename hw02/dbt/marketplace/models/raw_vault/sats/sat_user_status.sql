{%- set source_model = "v_stg_user_status_history" -%}
{%- set src_pk = "USER_HK" -%}
{%- set src_hashdiff = "SAT_USER_STATUS_HASHDIFF" -%}
{%- set src_payload = ["OLD_STATUS", "NEW_STATUS", "CHANGE_REASON",
                       "CHANGED_BY", "SESSION_ID", "IP_ADDRESS", "USER_AGENT"] -%}
{%- set src_eff = "EFFECTIVE_FROM" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.sat(src_pk=src_pk, src_hashdiff=src_hashdiff,
                   src_payload=src_payload, src_eff=src_eff,
                   src_ldts=src_ldts, src_source=src_source,
                   source_model=source_model) }}

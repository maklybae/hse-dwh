{%- set source_model = "v_stg_logistics" -%}
{%- set src_pk = "PICKUP_POINT_HK" -%}
{%- set src_hashdiff = "SAT_PICKUP_POINT_DETAILS_HASHDIFF" -%}
{%- set src_payload = ["PICKUP_POINT_NAME", "PARTNER_NAME", "OPERATING_HOURS"] -%}
{%- set src_eff = "EFFECTIVE_FROM" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.sat(src_pk=src_pk, src_hashdiff=src_hashdiff,
                   src_payload=src_payload, src_eff=src_eff,
                   src_ldts=src_ldts, src_source=src_source,
                   source_model=source_model) }}

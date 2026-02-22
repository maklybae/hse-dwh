{%- set source_model = "v_stg_users" -%}
{%- set src_pk = "ADDRESS_HK" -%}
{%- set src_hashdiff = "SAT_ADDRESS_DETAILS_HASHDIFF" -%}
{%- set src_payload = ["COUNTRY", "CITY", "STREET_ADDRESS", "POSTAL_CODE"] -%}
{%- set src_eff = "EFFECTIVE_FROM" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.sat(src_pk=src_pk, src_hashdiff=src_hashdiff,
                   src_payload=src_payload, src_eff=src_eff,
                   src_ldts=src_ldts, src_source=src_source,
                   source_model=source_model) }}

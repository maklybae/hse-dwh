{%- set source_model = "v_stg_user_addresses" -%}
{%- set src_pk = "ADDRESS_HK" -%}
{%- set src_hashdiff = "SAT_ADDRESS_DETAILS_HASHDIFF" -%}
{%- set src_payload = ["ADDRESS_TYPE", "COUNTRY", "REGION", "CITY",
                       "STREET_ADDRESS", "POSTAL_CODE", "APARTMENT",
                       "IS_DEFAULT_ADDRESS"] -%}
{%- set src_eff = "EFFECTIVE_FROM" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.sat(src_pk=src_pk, src_hashdiff=src_hashdiff,
                   src_payload=src_payload, src_eff=src_eff,
                   src_ldts=src_ldts, src_source=src_source,
                   source_model=source_model) }}

{%- set source_model = "v_stg_warehouses" -%}
{%- set src_pk = "WAREHOUSE_HK" -%}
{%- set src_hashdiff = "SAT_WAREHOUSE_DETAILS_HASHDIFF" -%}
{%- set src_payload = ["WAREHOUSE_NAME", "WAREHOUSE_TYPE", "WAREHOUSE_COUNTRY",
                       "WAREHOUSE_REGION", "WAREHOUSE_CITY", "WAREHOUSE_STREET_ADDRESS",
                       "WAREHOUSE_POSTAL_CODE", "WAREHOUSE_IS_ACTIVE",
                       "WAREHOUSE_MAX_CAPACITY", "WAREHOUSE_OPERATING_HOURS",
                       "WAREHOUSE_CONTACT_PHONE", "WAREHOUSE_MANAGER_NAME"] -%}
{%- set src_eff = "EFFECTIVE_FROM" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.sat(src_pk=src_pk, src_hashdiff=src_hashdiff,
                   src_payload=src_payload, src_eff=src_eff,
                   src_ldts=src_ldts, src_source=src_source,
                   source_model=source_model) }}

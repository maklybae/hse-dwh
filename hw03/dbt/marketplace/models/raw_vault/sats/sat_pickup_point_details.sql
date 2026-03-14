{%- set source_model = "v_stg_pickup_points" -%}
{%- set src_pk = "PICKUP_POINT_HK" -%}
{%- set src_hashdiff = "SAT_PICKUP_POINT_DETAILS_HASHDIFF" -%}
{%- set src_payload = ["PICKUP_POINT_NAME", "PICKUP_POINT_TYPE",
                       "PICKUP_POINT_COUNTRY", "PICKUP_POINT_REGION",
                       "PICKUP_POINT_CITY", "PICKUP_POINT_STREET_ADDRESS",
                       "PICKUP_POINT_POSTAL_CODE", "PICKUP_POINT_IS_ACTIVE",
                       "PICKUP_POINT_MAX_CAPACITY", "PICKUP_POINT_OPERATING_HOURS",
                       "PICKUP_POINT_CONTACT_PHONE", "PICKUP_POINT_PARTNER_NAME"] -%}
{%- set src_eff = "EFFECTIVE_FROM" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.sat(src_pk=src_pk, src_hashdiff=src_hashdiff,
                   src_payload=src_payload, src_eff=src_eff,
                   src_ldts=src_ldts, src_source=src_source,
                   source_model=source_model) }}

{%- set source_model = "v_stg_pickup_points" -%}
{%- set src_pk = "PICKUP_POINT_HK" -%}
{%- set src_hashdiff = "RTS_PICKUP_POINT_HASHDIFF" -%}
{%- set src_payload = ["IS_DELETED"] -%}
{%- set src_eff = "SOURCE_TIMESTAMP" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.sat(src_pk=src_pk, src_hashdiff=src_hashdiff,
                   src_payload=src_payload, src_eff=src_eff,
                   src_ldts=src_ldts, src_source=src_source,
                   source_model=source_model) }}

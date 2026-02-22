{%- set source_model = "v_stg_logistics" -%}
{%- set src_pk = "PICKUP_POINT_HK" -%}
{%- set src_nk = "PICKUP_POINT_CODE" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.hub(src_pk=src_pk, src_nk=src_nk, src_ldts=src_ldts,
                   src_source=src_source, source_model=source_model) }}

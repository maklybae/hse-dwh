{%- set source_model = "v_stg_shipment_movements" -%}
{%- set src_pk = "SHIPMENT_MOVEMENT_HK" -%}
{%- set src_fk = ["SHIPMENT_HK"] -%}
{%- set src_payload = ["MOVEMENT_TYPE", "LOCATION_CODE", "MOVEMENT_DATETIME",
                       "LATITUDE", "LONGITUDE"] -%}
{%- set src_eff = "MOVEMENT_DATETIME" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.t_link(src_pk=src_pk, src_fk=src_fk, src_ldts=src_ldts,
                      src_payload=src_payload, src_eff=src_eff,
                      src_source=src_source, source_model=source_model) }}

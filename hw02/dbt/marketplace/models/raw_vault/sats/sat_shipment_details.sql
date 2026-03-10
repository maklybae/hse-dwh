{%- set source_model = "v_stg_logistics" -%}
{%- set src_pk = "SHIPMENT_HK" -%}
{%- set src_hashdiff = "SAT_SHIPMENT_DETAILS_HASHDIFF" -%}
{%- set src_payload = ["SHIPMENT_STATUS", "TRACKING_NUMBER", "WEIGHT_GRAMS",
                       "VOLUME_CUBIC_CM", "PACKAGE_COUNT", "DISPATCHED_DATE",
                       "ESTIMATED_DELIVERY_DATE", "ACTUAL_DELIVERY_DATE",
                       "RECIPIENT_NAME", "DELIVERY_NOTES", "DELIVERY_SIGNATURE"] -%}
{%- set src_eff = "EFFECTIVE_FROM" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.sat(src_pk=src_pk, src_hashdiff=src_hashdiff,
                   src_payload=src_payload, src_eff=src_eff,
                   src_ldts=src_ldts, src_source=src_source,
                   source_model=source_model) }}

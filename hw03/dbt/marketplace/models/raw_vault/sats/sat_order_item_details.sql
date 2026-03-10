{%- set source_model = "v_stg_orders" -%}
{%- set src_pk = "LNK_ORDER_ITEM_HK" -%}
{%- set src_hashdiff = "SAT_ORDER_ITEM_DETAILS_HASHDIFF" -%}
{%- set src_payload = ["QUANTITY", "UNIT_PRICE", "TOTAL_PRICE",
                       "PRODUCT_NAME_SNAPSHOT", "PRODUCT_CATEGORY_SNAPSHOT",
                       "PRODUCT_BRAND_SNAPSHOT"] -%}
{%- set src_eff = "EFFECTIVE_FROM" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.sat(src_pk=src_pk, src_hashdiff=src_hashdiff,
                   src_payload=src_payload, src_eff=src_eff,
                   src_ldts=src_ldts, src_source=src_source,
                   source_model=source_model) }}

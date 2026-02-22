{%- set yaml_metadata -%}
source_model: 'raw_orders'
derived_columns:
  RECORD_SOURCE: '!ORDER_SERVICE'
  EFFECTIVE_FROM: 'ORDER_EFFECTIVE_FROM'
hashed_columns:
  ORDER_HK: 'ORDER_EXTERNAL_ID'
  USER_HK: 'USER_EXTERNAL_ID'
  ADDRESS_HK: 'DELIVERY_ADDRESS_EXTERNAL_ID'
  PRODUCT_HK: 'PRODUCT_SKU'
  LNK_ORDER_USER_HK:
    - 'ORDER_EXTERNAL_ID'
    - 'USER_EXTERNAL_ID'
  LNK_ORDER_ADDRESS_HK:
    - 'ORDER_EXTERNAL_ID'
    - 'DELIVERY_ADDRESS_EXTERNAL_ID'
  LNK_ORDER_ITEM_HK:
    - 'ORDER_EXTERNAL_ID'
    - 'PRODUCT_SKU'
  SAT_ORDER_DETAILS_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TOTAL_AMOUNT'
      - 'CURRENCY'
      - 'PAYMENT_METHOD'
      - 'ORDER_STATUS'
  SAT_ORDER_ITEM_DETAILS_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ORDER_EXTERNAL_ID'
      - 'PRODUCT_SKU'
      - 'QUANTITY'
      - 'UNIT_PRICE'
      - 'PRODUCT_NAME_SNAPSHOT'
  SAT_PRODUCT_DETAILS_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PRODUCT_NAME'
      - 'PRODUCT_CATEGORY'
      - 'PRODUCT_BRAND'
      - 'PRODUCT_PRICE'
  SAT_PRODUCT_LOGISTICS_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PRODUCT_WEIGHT_GRAMS'
      - 'PRODUCT_DIM_LENGTH_CM'
      - 'PRODUCT_DIM_WIDTH_CM'
      - 'PRODUCT_DIM_HEIGHT_CM'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{% set source_model    = metadata_dict['source_model'] %}
{% set derived_columns = metadata_dict['derived_columns'] %}
{% set hashed_columns  = metadata_dict['hashed_columns'] %}

WITH staging AS (
{{ automate_dv.stage(include_source_columns=true,
                     source_model=source_model,
                     derived_columns=derived_columns,
                     null_columns=none,
                     hashed_columns=hashed_columns,
                     ranked_columns=none) }}
)

SELECT *,
       ('{{ var("load_date") }}')::DATE AS LOAD_DATE
FROM staging

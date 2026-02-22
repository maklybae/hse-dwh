{%- set yaml_metadata -%}
source_model: 'raw_logistics'
derived_columns:
  RECORD_SOURCE: '!LOGISTICS_SERVICE'
  EFFECTIVE_FROM: 'SHIPMENT_EFFECTIVE_FROM'
hashed_columns:
  SHIPMENT_HK: 'SHIPMENT_EXTERNAL_ID'
  ORDER_HK: 'ORDER_EXTERNAL_ID'
  ADDRESS_HK: 'DESTINATION_ADDRESS_EXTERNAL_ID'
  WAREHOUSE_HK: 'ORIGIN_WAREHOUSE_CODE'
  PICKUP_POINT_HK: 'DESTINATION_PICKUP_POINT_CODE'
  LNK_SHIPMENT_ORDER_HK:
    - 'SHIPMENT_EXTERNAL_ID'
    - 'ORDER_EXTERNAL_ID'
  LNK_SHIPMENT_ADDRESS_HK:
    - 'SHIPMENT_EXTERNAL_ID'
    - 'DESTINATION_ADDRESS_EXTERNAL_ID'
  LNK_SHIPMENT_WAREHOUSE_HK:
    - 'SHIPMENT_EXTERNAL_ID'
    - 'ORIGIN_WAREHOUSE_CODE'
  LNK_SHIPMENT_PICKUP_POINT_HK:
    - 'SHIPMENT_EXTERNAL_ID'
    - 'DESTINATION_PICKUP_POINT_CODE'
  SAT_SHIPMENT_DETAILS_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SHIPMENT_STATUS'
      - 'WEIGHT_GRAMS'
      - 'ESTIMATED_DELIVERY_DATE'
      - 'RECIPIENT_NAME'
  SAT_WAREHOUSE_DETAILS_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'WAREHOUSE_NAME'
      - 'WAREHOUSE_MAX_CAPACITY'
      - 'WAREHOUSE_CONTACT_PHONE'
  SAT_PICKUP_POINT_DETAILS_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PICKUP_POINT_NAME'
      - 'PICKUP_POINT_PARTNER_NAME'
      - 'PICKUP_POINT_OPERATING_HOURS'
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

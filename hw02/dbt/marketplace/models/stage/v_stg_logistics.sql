{%- set yaml_metadata -%}
source_model: 'raw_logistics'
derived_columns:
  RECORD_SOURCE: '!LOGISTICS_SERVICE'
  EFFECTIVE_FROM: 'SHIPMENT_EFFECTIVE_FROM'
  ADDRESS_EXTERNAL_ID: 'DESTINATION_ADDRESS_EXTERNAL_ID'
  WAREHOUSE_CODE: 'ORIGIN_WAREHOUSE_CODE'
  PICKUP_POINT_CODE: 'DESTINATION_PICKUP_POINT_CODE'
null_columns:
  DESTINATION_ADDRESS_EXTERNAL_ID: 'DESTINATION_ADDRESS_EXTERNAL_ID'
  DESTINATION_PICKUP_POINT_CODE: 'DESTINATION_PICKUP_POINT_CODE'
hashed_columns:
  SHIPMENT_HK: 'SHIPMENT_EXTERNAL_ID'
  ORDER_HK: 'ORDER_EXTERNAL_ID'
  ADDRESS_HK: 'DESTINATION_ADDRESS_EXTERNAL_ID'
  WAREHOUSE_HK: 'WAREHOUSE_CODE'
  PICKUP_POINT_HK: 'PICKUP_POINT_CODE'
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
      - 'TRACKING_NUMBER'
      - 'WEIGHT_GRAMS'
      - 'VOLUME_CUBIC_CM'
      - 'PACKAGE_COUNT'
      - 'DISPATCHED_DATE'
      - 'ESTIMATED_DELIVERY_DATE'
      - 'ACTUAL_DELIVERY_DATE'
      - 'RECIPIENT_NAME'
      - 'DELIVERY_NOTES'
      - 'DELIVERY_SIGNATURE'
  RTS_SHIPMENT_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'IS_DELETED'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{% set source_model    = metadata_dict['source_model'] %}
{% set derived_columns = metadata_dict['derived_columns'] %}
{% set null_columns    = metadata_dict['null_columns'] %}
{% set hashed_columns  = metadata_dict['hashed_columns'] %}

WITH staging AS (
{{ automate_dv.stage(include_source_columns=true,
                     source_model=source_model,
                     derived_columns=derived_columns,
                     null_columns=null_columns,
                     hashed_columns=hashed_columns,
                     ranked_columns=none) }}
)

SELECT *,
       {% if var("load_date", none) %}
       ('{{ var("load_date") }}')::DATE AS LOAD_DATE
       {% else %}
       CURRENT_DATE AS LOAD_DATE
       {% endif %}
FROM staging

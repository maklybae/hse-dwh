{%- set yaml_metadata -%}
source_model: 'raw_shipment_movements'
derived_columns:
  RECORD_SOURCE: '!LOGISTICS_SERVICE'
  EFFECTIVE_FROM: 'MOVEMENT_DATETIME'
hashed_columns:
  SHIPMENT_HK: 'SHIPMENT_EXTERNAL_ID'
  SHIPMENT_MOVEMENT_HK:
    - 'SHIPMENT_EXTERNAL_ID'
    - 'MOVEMENT_DATETIME'
    - 'LOCATION_CODE'
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

{%- set yaml_metadata -%}
source_model: 'raw_shipment_status_history'
derived_columns:
  RECORD_SOURCE: '!LOGISTICS_SERVICE'
  EFFECTIVE_FROM: 'CHANGED_AT'
hashed_columns:
  SHIPMENT_HK: 'SHIPMENT_EXTERNAL_ID'
  SAT_SHIPMENT_STATUS_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'OLD_STATUS'
      - 'NEW_STATUS'
      - 'CHANGE_REASON'
      - 'CHANGED_BY'
      - 'LOCATION_TYPE'
      - 'LOCATION_CODE'
      - 'CUSTOMER_NOTIFIED'
      - 'CHANGED_AT'
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
       {% if var("load_date", none) %}
       ('{{ var("load_date") }}')::DATE AS LOAD_DATE
       {% else %}
       CURRENT_DATE AS LOAD_DATE
       {% endif %}
FROM staging

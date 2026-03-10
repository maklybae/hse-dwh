{%- set yaml_metadata -%}
source_model: 'raw_order_status_history'
derived_columns:
  RECORD_SOURCE: '!ORDER_SERVICE'
  EFFECTIVE_FROM: 'CHANGED_AT'
hashed_columns:
  ORDER_HK: 'ORDER_EXTERNAL_ID'
  SAT_ORDER_STATUS_HISTORY_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NEW_STATUS'
      - 'CHANGE_REASON'
      - 'NOTES'
      - 'CHANGED_BY'
      - 'SESSION_ID'
      - 'IP_ADDRESS'
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

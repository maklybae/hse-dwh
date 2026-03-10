{%- set yaml_metadata -%}
source_model: 'raw_warehouses'
derived_columns:
  RECORD_SOURCE: '!LOGISTICS_SERVICE'
  EFFECTIVE_FROM: 'WAREHOUSE_EFFECTIVE_FROM'
hashed_columns:
  WAREHOUSE_HK: 'WAREHOUSE_CODE'
  SAT_WAREHOUSE_DETAILS_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'WAREHOUSE_NAME'
      - 'WAREHOUSE_TYPE'
      - 'WAREHOUSE_COUNTRY'
      - 'WAREHOUSE_REGION'
      - 'WAREHOUSE_CITY'
      - 'WAREHOUSE_STREET_ADDRESS'
      - 'WAREHOUSE_POSTAL_CODE'
      - 'WAREHOUSE_IS_ACTIVE'
      - 'WAREHOUSE_MAX_CAPACITY'
      - 'WAREHOUSE_OPERATING_HOURS'
      - 'WAREHOUSE_CONTACT_PHONE'
      - 'WAREHOUSE_MANAGER_NAME'
  RTS_WAREHOUSE_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'IS_DELETED'
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

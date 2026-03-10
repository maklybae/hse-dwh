{%- set yaml_metadata -%}
source_model: 'raw_pickup_points'
derived_columns:
  RECORD_SOURCE: '!LOGISTICS_SERVICE'
  EFFECTIVE_FROM: 'PICKUP_POINT_EFFECTIVE_FROM'
hashed_columns:
  PICKUP_POINT_HK: 'PICKUP_POINT_CODE'
  SAT_PICKUP_POINT_DETAILS_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PICKUP_POINT_NAME'
      - 'PICKUP_POINT_TYPE'
      - 'PICKUP_POINT_COUNTRY'
      - 'PICKUP_POINT_REGION'
      - 'PICKUP_POINT_CITY'
      - 'PICKUP_POINT_STREET_ADDRESS'
      - 'PICKUP_POINT_POSTAL_CODE'
      - 'PICKUP_POINT_IS_ACTIVE'
      - 'PICKUP_POINT_MAX_CAPACITY'
      - 'PICKUP_POINT_OPERATING_HOURS'
      - 'PICKUP_POINT_CONTACT_PHONE'
      - 'PICKUP_POINT_PARTNER_NAME'
  RTS_PICKUP_POINT_HASHDIFF:
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

{%- set yaml_metadata -%}
source_model: 'raw_users'
derived_columns:
  RECORD_SOURCE: '!USER_SERVICE'
  EFFECTIVE_FROM: 'ADDRESS_EFFECTIVE_FROM'
null_columns:
  ADDRESS_EXTERNAL_ID: 'ADDRESS_EXTERNAL_ID'
hashed_columns:
  ADDRESS_HK: 'ADDRESS_EXTERNAL_ID'
  USER_HK: 'USER_EXTERNAL_ID'
  LNK_USER_ADDRESS_HK:
    - 'USER_EXTERNAL_ID'
    - 'ADDRESS_EXTERNAL_ID'
  SAT_ADDRESS_DETAILS_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADDRESS_TYPE'
      - 'COUNTRY'
      - 'REGION'
      - 'CITY'
      - 'STREET_ADDRESS'
      - 'POSTAL_CODE'
      - 'APARTMENT'
      - 'IS_DEFAULT_ADDRESS'
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

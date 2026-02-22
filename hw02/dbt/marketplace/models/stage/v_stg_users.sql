{%- set yaml_metadata -%}
source_model: 'raw_users'
derived_columns:
  RECORD_SOURCE: '!USER_SERVICE'
  EFFECTIVE_FROM: 'USER_EFFECTIVE_FROM'
hashed_columns:
  USER_HK: 'USER_EXTERNAL_ID'
  ADDRESS_HK: 'ADDRESS_EXTERNAL_ID'
  LNK_USER_ADDRESS_HK:
    - 'USER_EXTERNAL_ID'
    - 'ADDRESS_EXTERNAL_ID'
  SAT_USER_DETAILS_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FIRST_NAME'
      - 'LAST_NAME'
      - 'EMAIL'
      - 'PHONE'
  SAT_ADDRESS_DETAILS_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COUNTRY'
      - 'CITY'
      - 'STREET_ADDRESS'
      - 'POSTAL_CODE'
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

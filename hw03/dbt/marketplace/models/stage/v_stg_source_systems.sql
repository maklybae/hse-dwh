{%- set yaml_metadata -%}
source_model: 'source_systems'
derived_columns:
  RECORD_SOURCE: '!DWH_SEED'
  EFFECTIVE_FROM: '!1900-01-01'
hashed_columns:
  SOURCE_SYSTEM_HK: 'SOURCE_SYSTEM_CODE'
  SAT_SOURCE_SYSTEM_DETAILS_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SOURCE_SYSTEM_NAME'
      - 'SOURCE_SYSTEM_TYPE'
      - 'CONTACT_OWNER'
      - 'DESCRIPTION'
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
       CURRENT_DATE AS LOAD_DATE
FROM staging

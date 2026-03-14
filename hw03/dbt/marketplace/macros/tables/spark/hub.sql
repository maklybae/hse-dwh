{#
    Spark override for automate_dv hub macro.
    Replaces QUALIFY with ROW_NUMBER() subquery + WHERE (vanilla Spark doesn't support QUALIFY).
    Uses LEFT ANTI JOIN (Spark-native) from Databricks variant.
#}

{%- macro spark__hub(src_pk, src_nk, src_extra_columns, src_ldts, src_source, source_model) -%}

{%- set source_cols = automate_dv.expand_column_list(columns=[src_pk, src_nk, src_extra_columns, src_ldts, src_source]) -%}

{%- if model.config.materialized == 'vault_insert_by_rank' %}
    {%- set source_cols_with_rank = source_cols + [automate_dv.config_meta_get('rank_column')] -%}
{%- endif %}

{{ 'WITH ' -}}

{%- set stage_count = source_model | length -%}

{%- set ns = namespace(last_cte= "") -%}

{%- for src in source_model -%}

{%- set source_number = loop.index | string -%}

row_rank_{{ source_number }} AS (
    {%- if model.config.materialized == 'vault_insert_by_rank' %}
    SELECT {{ automate_dv.prefix(source_cols_with_rank, 'rr') }}
    {%- else %}
    SELECT {{ automate_dv.prefix(source_cols, 'rr') }}
    {%- endif %}
    FROM (
        {%- if model.config.materialized == 'vault_insert_by_rank' %}
        SELECT {{ automate_dv.prefix(source_cols_with_rank, 'rr_inner') }},
        {%- else %}
        SELECT {{ automate_dv.prefix(source_cols, 'rr_inner') }},
        {%- endif %}
               ROW_NUMBER() OVER(
                   PARTITION BY {{ automate_dv.prefix([src_pk], 'rr_inner') }}
                   ORDER BY {{ automate_dv.prefix([src_ldts], 'rr_inner') }}
               ) AS _rn_
        FROM {{ ref(src) }} AS rr_inner
        WHERE {{ automate_dv.multikey(src_pk, prefix='rr_inner', condition='IS NOT NULL') }}
    ) AS rr
    WHERE rr._rn_ = 1
    {%- set ns.last_cte = "row_rank_{}".format(source_number) %}
),{{ "\n" if not loop.last }}
{% endfor -%}
{% if stage_count > 1 %}
stage_union AS (
    {%- for src in source_model %}
    SELECT * FROM row_rank_{{ loop.index | string }}
    {%- if not loop.last %}
    UNION ALL
    {%- endif %}
    {%- endfor %}
    {%- set ns.last_cte = "stage_union" %}
),
{%- endif -%}

{%- if model.config.materialized == 'vault_insert_by_period' %}
stage_mat_filter AS (
    SELECT *
    FROM {{ ns.last_cte }}
    WHERE __PERIOD_FILTER__
    {%- set ns.last_cte = "stage_mat_filter" %}
),
{%- elif model.config.materialized == 'vault_insert_by_rank' %}
stage_mat_filter AS (
    SELECT *
    FROM {{ ns.last_cte }}
    WHERE __RANK_FILTER__
    {%- set ns.last_cte = "stage_mat_filter" %}
),
{%- endif -%}

{%- if stage_count > 1 %}

row_rank_union AS (
    SELECT {{ automate_dv.prefix(source_cols, 'ru_outer') }}
    FROM (
        SELECT ru.*,
               ROW_NUMBER() OVER(
                   PARTITION BY {{ automate_dv.prefix([src_pk], 'ru') }}
                   ORDER BY {{ automate_dv.prefix([src_ldts], 'ru') }}, {{ automate_dv.prefix([src_source], 'ru') }} ASC
               ) AS _rn_
        FROM {{ ns.last_cte }} AS ru
        WHERE {{ automate_dv.multikey(src_pk, prefix='ru', condition='IS NOT NULL') }}
    ) AS ru_outer
    WHERE ru_outer._rn_ = 1
    {%- set ns.last_cte = "row_rank_union" %}
),
{% endif %}
records_to_insert AS (
    SELECT {{ automate_dv.prefix(source_cols, 'a', alias_target='target') }}
    FROM {{ ns.last_cte }} AS a
    {%- if automate_dv.is_any_incremental() %}
    LEFT ANTI JOIN {{ this }} AS d
    ON {{ automate_dv.multikey(src_pk, prefix=['a','d'], condition='=') }}
    {%- endif %}
)

SELECT * FROM records_to_insert

{%- endmacro -%}

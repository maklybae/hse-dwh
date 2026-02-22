{#
    Spark dispatch overrides for automate_dv.
    automate_dv 0.11.5 does not ship spark__ implementations for these 3 macros.
    Spark SQL dialect matches Databricks, so we delegate to the existing databricks__ versions.
#}

{%- macro spark__get_escape_characters() %}
    {%- do return(('`', '`')) -%}
{%- endmacro %}

{%- macro spark__cast_date(column_str, as_string=false, alias=none) -%}
    {{ automate_dv.snowflake__cast_date(column_str=column_str, as_string=as_string, alias=alias) }}
{%- endmacro -%}

{%- macro spark__cast_datetime(column_str, as_string=false, alias=none, date_type=none) -%}
    {{ automate_dv.snowflake__cast_datetime(column_str=column_str, as_string=as_string, alias=alias, date_type=date_type) }}
{%- endmacro -%}

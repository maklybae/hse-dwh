{#
    Spark override: cast_date.
    Spark SQL CAST(... AS DATE) works the same as Snowflake's TO_DATE.
    Delegate to snowflake__ variant which uses compatible syntax.
#}

{%- macro spark__cast_date(column_str, as_string=false, alias=none) -%}
    {{ automate_dv.snowflake__cast_date(column_str=column_str, as_string=as_string, alias=alias) }}
{%- endmacro -%}

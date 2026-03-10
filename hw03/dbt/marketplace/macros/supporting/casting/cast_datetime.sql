{#
    Spark override: cast_datetime.
    Spark SQL CAST(... AS TIMESTAMP) works the same as Snowflake's TO_TIMESTAMP.
    Delegate to snowflake__ variant which uses compatible syntax.
#}

{%- macro spark__cast_datetime(column_str, as_string=false, alias=none, date_type=none) -%}
    {{ automate_dv.snowflake__cast_datetime(column_str=column_str, as_string=as_string, alias=alias, date_type=date_type) }}
{%- endmacro -%}

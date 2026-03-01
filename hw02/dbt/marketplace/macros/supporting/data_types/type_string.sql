{#
    Spark override: type_string.
    Spark uses STRING, not VARCHAR (same as Databricks).
#}

{%- macro spark__type_string() -%}
    {{ automate_dv.databricks__type_string() }}
{%- endmacro -%}

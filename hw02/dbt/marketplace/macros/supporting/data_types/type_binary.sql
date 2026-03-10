{#
    Spark override: type_binary.
    Spark does not support BINARY(16). Uses STRING for hash output (same as Databricks).
#}

{%- macro spark__type_binary(for_dbt_compare=false) -%}
    {{ automate_dv.databricks__type_binary(for_dbt_compare=for_dbt_compare) }}
{%- endmacro -%}

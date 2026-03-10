{#
    Spark override: get_escape_characters.
    Spark uses backtick quoting for identifiers (same as Databricks).
#}

{%- macro spark__get_escape_characters() %}
    {%- do return(('`', '`')) -%}
{%- endmacro %}

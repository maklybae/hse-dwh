{#
    Spark overrides for hash algorithm selection.
    Spark does not support MD5_BINARY (Snowflake-specific).
    Delegates to databricks__ variants which use UPPER(MD5(...)) / SHA2(...) / SHA1(...).
#}

{%- macro spark__hash_alg_md5() -%}
    {{ automate_dv.databricks__hash_alg_md5() }}
{%- endmacro -%}

{%- macro spark__hash_alg_sha256() -%}
    {{ automate_dv.databricks__hash_alg_sha256() }}
{%- endmacro -%}

{%- macro spark__hash_alg_sha1() -%}
    {{ automate_dv.databricks__hash_alg_sha1() }}
{%- endmacro -%}

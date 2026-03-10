{#
    Spark override for automate_dv nh_link macro.
    Databricks nh_link does not use QUALIFY, so we delegate directly.
#}

{%- macro spark__nh_link(src_pk, src_fk, src_payload, src_extra_columns, src_eff, src_ldts, src_source, source_model) -%}
    {{ automate_dv.databricks__nh_link(src_pk=src_pk, src_fk=src_fk, src_payload=src_payload, src_extra_columns=src_extra_columns, src_eff=src_eff, src_ldts=src_ldts, src_source=src_source, source_model=source_model) }}
{%- endmacro -%}

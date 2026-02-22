{%- set source_model = "v_stg_users" -%}
{%- set src_pk = "LNK_USER_ADDRESS_HK" -%}
{%- set src_fk = ["USER_HK", "ADDRESS_HK"] -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.link(src_pk=src_pk, src_fk=src_fk, src_ldts=src_ldts,
                    src_source=src_source, source_model=source_model) }}

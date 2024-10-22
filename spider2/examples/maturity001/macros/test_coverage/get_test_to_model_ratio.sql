{%- macro get_test_to_model_ratio() -%}

    {%- set model_count = get_enabled_models() | length -%}
    {%- set test_count = get_enabled_tests() | length -%}

    {%- do log("Project Test to Model Ratio: " ~ ((test_count/model_count) | round(3)), info=True) -%}
    
{%- endmacro -%}
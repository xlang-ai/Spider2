{%- macro get_test_coverage() -%}

    {%- set enabled_models = get_enabled_models() -%}    
    {%- set enabled_models_count = enabled_models | length -%}    
    {%- set enabled_models_names = [] -%}
    
    {%- for model in enabled_models -%}

        {%- do enabled_models_names.append(model.name) -%}

    {%- endfor -%}

    {%- set enabled_tests = get_enabled_tests() -%}

    {%- set all_tested_nodes = [] -%}
    
    {%- for test in enabled_tests -%}

        {%- for node in test.depends_on.nodes -%}

            {%- set node_name = node.split('.')[2] -%}

            {%- if node_name in enabled_models_names -%}

                {%- do all_tested_nodes.append(node_name) -%}
            
            {%- endif -%}
        
        {%- endfor -%}

    {%- endfor -%}

    {%- set unique_tested_nodes_count = all_tested_nodes | unique | list | length -%}
    {%- set pct = (unique_tested_nodes_count/enabled_models_count * 100) | round(2) -%}

    {% do log("Project Test Coverage: " ~ pct ~ "%", info=True) %}

{%- endmacro -%}
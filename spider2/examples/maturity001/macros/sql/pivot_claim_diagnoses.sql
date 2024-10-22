{# 
    this macro accepts an integer argument to pivot the claim diagnoses and descriptions to that depth
    i.e. pivot_claim_diagnoses(3) returns the claims top 3 diagnoses and descriptions in columns

 #}

{%- macro pivot_claim_diagnoses(diagnosis_depth) -%}

    {%- for n in range(diagnosis_depth) -%}
        {%- set claim_line = n+1 %}

        max(case when diagnosis_number = {{ claim_line }} then icd_10_code else null end) as diagnosis_{{ claim_line }},
        max(case when diagnosis_number = {{ claim_line }} then icd_10_code_descrip else null end) as diagnosis_description_{{ claim_line }}{%- if not loop.last -%},{%- endif -%}       
      
    {%- endfor %}
  
{%- endmacro -%}
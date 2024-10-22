{%- macro generate_md5() -%}
    {{log('Genrating Hash Key',info = True)}}
    {%- set column_to_md5 = [] -%}
    {%- for key, value in kwargs.items() -%}
        {%-do column_to_md5.append("NVL(CAST("~value~" as VARCHAR),'UNKNOW')") -%}      
    {%- endfor -%}
    {{'MD5(CONCAT(' ~ column_to_md5|join(",'_',") ~ '))'}}
    {{log('Hash Key Has Been Generate',info = True)}}
{%- endmacro -%}
{% macro get_lfa1_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_rowid", "datatype": dbt.type_numeric()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "actss", "datatype": dbt.type_string()},
    {"name": "adrnr", "datatype": dbt.type_string()},
    {"name": "alc", "datatype": dbt.type_string()},
    {"name": "anred", "datatype": dbt.type_string()},
    {"name": "bahns", "datatype": dbt.type_string()},
    {"name": "bbbnr", "datatype": dbt.type_string()},
    {"name": "bbsnr", "datatype": dbt.type_string()},
    {"name": "begru", "datatype": dbt.type_string()},
    {"name": "brsch", "datatype": dbt.type_string()},
    {"name": "bubkz", "datatype": dbt.type_string()},
    {"name": "carrier_conf", "datatype": dbt.type_string()},
    {"name": "cnae", "datatype": dbt.type_string()},
    {"name": "comsize", "datatype": dbt.type_string()},
    {"name": "confs", "datatype": dbt.type_string()},
    {"name": "crc_num", "datatype": dbt.type_string()},
    {"name": "crtn", "datatype": dbt.type_string()},
    {"name": "cvp_xblck", "datatype": dbt.type_string()},
    {"name": "datlt", "datatype": dbt.type_string()},
    {"name": "decregpc", "datatype": dbt.type_string()},
    {"name": "dlgrp", "datatype": dbt.type_string()},
    {"name": "dtams", "datatype": dbt.type_string()},
    {"name": "dtaws", "datatype": dbt.type_string()},
    {"name": "duefl", "datatype": dbt.type_string()},
    {"name": "emnfr", "datatype": dbt.type_string()},
    {"name": "erdat", "datatype": dbt.type_string()},
    {"name": "ernam", "datatype": dbt.type_string()},
    {"name": "esrnr", "datatype": dbt.type_string()},
    {"name": "exp", "datatype": dbt.type_string()},
    {"name": "fiskn", "datatype": dbt.type_string()},
    {"name": "fisku", "datatype": dbt.type_string()},
    {"name": "fityp", "datatype": dbt.type_string()},
    {"name": "gbdat", "datatype": dbt.type_string()},
    {"name": "gbort", "datatype": dbt.type_string()},
    {"name": "icmstaxpay", "datatype": dbt.type_string()},
    {"name": "indtyp", "datatype": dbt.type_string()},
    {"name": "ipisp", "datatype": dbt.type_string()},
    {"name": "j_1kfrepre", "datatype": dbt.type_string()},
    {"name": "j_1kftbus", "datatype": dbt.type_string()},
    {"name": "j_1kftind", "datatype": dbt.type_string()},
    {"name": "j_sc_capital", "datatype": dbt.type_numeric()},
    {"name": "j_sc_currency", "datatype": dbt.type_string()},
    {"name": "konzs", "datatype": dbt.type_string()},
    {"name": "kraus", "datatype": dbt.type_string()},
    {"name": "ktock", "datatype": dbt.type_string()},
    {"name": "ktokk", "datatype": dbt.type_string()},
    {"name": "kunnr", "datatype": dbt.type_string()},
    {"name": "land1", "datatype": dbt.type_string()},
    {"name": "legalnat", "datatype": dbt.type_string()},
    {"name": "lfurl", "datatype": dbt.type_string()},
    {"name": "lifnr", "datatype": dbt.type_string()},
    {"name": "lnrza", "datatype": dbt.type_string()},
    {"name": "loevm", "datatype": dbt.type_string()},
    {"name": "ltsna", "datatype": dbt.type_string()},
    {"name": "lzone", "datatype": dbt.type_string()},
    {"name": "mandt", "datatype": dbt.type_string()},
    {"name": "mcod1", "datatype": dbt.type_string()},
    {"name": "mcod2", "datatype": dbt.type_string()},
    {"name": "mcod3", "datatype": dbt.type_string()},
    {"name": "min_comp", "datatype": dbt.type_string()},
    {"name": "name1", "datatype": dbt.type_string()},
    {"name": "name2", "datatype": dbt.type_string()},
    {"name": "name3", "datatype": dbt.type_string()},
    {"name": "name4", "datatype": dbt.type_string()},
    {"name": "nodel", "datatype": dbt.type_string()},
    {"name": "ort01", "datatype": dbt.type_string()},
    {"name": "ort02", "datatype": dbt.type_string()},
    {"name": "pfach", "datatype": dbt.type_string()},
    {"name": "pfort", "datatype": dbt.type_string()},
    {"name": "plkal", "datatype": dbt.type_string()},
    {"name": "pmt_office", "datatype": dbt.type_string()},
    {"name": "podkzb", "datatype": dbt.type_string()},
    {"name": "ppa_relevant", "datatype": dbt.type_string()},
    {"name": "profs", "datatype": dbt.type_string()},
    {"name": "psofg", "datatype": dbt.type_string()},
    {"name": "psohs", "datatype": dbt.type_string()},
    {"name": "psois", "datatype": dbt.type_string()},
    {"name": "pson1", "datatype": dbt.type_string()},
    {"name": "pson2", "datatype": dbt.type_string()},
    {"name": "pson3", "datatype": dbt.type_string()},
    {"name": "psost", "datatype": dbt.type_string()},
    {"name": "psotl", "datatype": dbt.type_string()},
    {"name": "psovn", "datatype": dbt.type_string()},
    {"name": "pstl2", "datatype": dbt.type_string()},
    {"name": "pstlz", "datatype": dbt.type_string()},
    {"name": "qssys", "datatype": dbt.type_string()},
    {"name": "qssysdat", "datatype": dbt.type_string()},
    {"name": "regio", "datatype": dbt.type_string()},
    {"name": "regss", "datatype": dbt.type_string()},
    {"name": "revdb", "datatype": dbt.type_string()},
    {"name": "rg", "datatype": dbt.type_string()},
    {"name": "rgdate", "datatype": dbt.type_string()},
    {"name": "ric", "datatype": dbt.type_string()},
    {"name": "rne", "datatype": dbt.type_string()},
    {"name": "rnedate", "datatype": dbt.type_string()},
    {"name": "scacd", "datatype": dbt.type_string()},
    {"name": "scheduling_type", "datatype": dbt.type_string()},
    {"name": "sexkz", "datatype": dbt.type_string()},
    {"name": "sfrgr", "datatype": dbt.type_string()},
    {"name": "sortl", "datatype": dbt.type_string()},
    {"name": "sperm", "datatype": dbt.type_string()},
    {"name": "sperq", "datatype": dbt.type_string()},
    {"name": "sperr", "datatype": dbt.type_string()},
    {"name": "sperz", "datatype": dbt.type_string()},
    {"name": "spras", "datatype": dbt.type_string()},
    {"name": "staging_time", "datatype": dbt.type_numeric()},
    {"name": "stcd1", "datatype": dbt.type_string()},
    {"name": "stcd2", "datatype": dbt.type_string()},
    {"name": "stcd3", "datatype": dbt.type_string()},
    {"name": "stcd4", "datatype": dbt.type_string()},
    {"name": "stcd5", "datatype": dbt.type_string()},
    {"name": "stcdt", "datatype": dbt.type_string()},
    {"name": "stceg", "datatype": dbt.type_string()},
    {"name": "stenr", "datatype": dbt.type_string()},
    {"name": "stgdl", "datatype": dbt.type_string()},
    {"name": "stkza", "datatype": dbt.type_string()},
    {"name": "stkzn", "datatype": dbt.type_string()},
    {"name": "stkzu", "datatype": dbt.type_string()},
    {"name": "stras", "datatype": dbt.type_string()},
    {"name": "submi_relevant", "datatype": dbt.type_string()},
    {"name": "taxbs", "datatype": dbt.type_string()},
    {"name": "tdt", "datatype": dbt.type_string()},
    {"name": "telbx", "datatype": dbt.type_string()},
    {"name": "telf1", "datatype": dbt.type_string()},
    {"name": "telf2", "datatype": dbt.type_string()},
    {"name": "telfx", "datatype": dbt.type_string()},
    {"name": "teltx", "datatype": dbt.type_string()},
    {"name": "telx1", "datatype": dbt.type_string()},
    {"name": "term_li", "datatype": dbt.type_string()},
    {"name": "transport_chain", "datatype": dbt.type_string()},
    {"name": "txjcd", "datatype": dbt.type_string()},
    {"name": "uf", "datatype": dbt.type_string()},
    {"name": "updat", "datatype": dbt.type_string()},
    {"name": "uptim", "datatype": dbt.type_string()},
    {"name": "vbund", "datatype": dbt.type_string()},
    {"name": "werkr", "datatype": dbt.type_string()},
    {"name": "werks", "datatype": dbt.type_string()},
    {"name": "xcpdk", "datatype": dbt.type_string()},
    {"name": "xlfza", "datatype": dbt.type_string()},
    {"name": "xzemp", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
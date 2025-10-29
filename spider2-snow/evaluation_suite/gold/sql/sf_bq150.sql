with expr as (
    select
        "sample_barcode",
        ln("normalized_count") / ln(10) as log_expr
    from "TCGA_HG19_DATA_V0"."TCGA_HG19_DATA_V0"."RNASEQ_GENE_EXPRESSION_UNC_RSEM"
    where "project_short_name" = 'TCGA-BRCA'
      and "HGNC_gene_symbol" = 'TP53'
      and "normalized_count" > 0
      and substr("sample_barcode", 14, 2) = '01'
),
mut as (
    select
        "sample_barcode_tumor" as sample_barcode,
        case
            when count(distinct "Variant_Classification") = 1 then max("Variant_Classification")
            else 'Multiple'
        end as mutation_type
    from "TCGA_HG19_DATA_V0"."TCGA_HG19_DATA_V0"."SOMATIC_MUTATION_MC3"
    where "project_short_name" = 'TCGA-BRCA'
      and "Hugo_Symbol" = 'TP53'
    group by "sample_barcode_tumor"
),
combined as (
    select
        e."sample_barcode",
        coalesce(m.mutation_type, 'No Mutation') as mutation_type,
        e.log_expr
    from expr e
    left join mut m
        on e."sample_barcode" = m.sample_barcode
),
group_stats as (
    select
        mutation_type,
        count(*) as n_j,
        avg(log_expr) as mean_j
    from combined
    group by mutation_type
),
overall as (
    select
        count(*) as N,
        avg(log_expr) as grand_mean
    from combined
),
ss_between as (
    select
        sum(gs.n_j * power(gs.mean_j - o.grand_mean, 2)) as ssb
    from group_stats gs
    cross join overall o
),
ss_within as (
    select
        sum(power(c.log_expr - gs.mean_j, 2)) as ssw
    from combined c
    join group_stats gs
        on c.mutation_type = gs.mutation_type
),
group_count as (
    select count(*) as k
    from group_stats
)
select
    o.N as total_samples,
    gc.k as mutation_types,
    ssb.ssb / nullif(gc.k - 1, 0) as mean_square_between,
    ssw.ssw / nullif(o.N - gc.k, 0) as mean_square_within,
    (ssb.ssb / nullif(gc.k - 1, 0)) / (ssw.ssw / nullif(o.N - gc.k, 0)) as f_statistic
from overall o
cross join group_count gc
cross join ss_between ssb
cross join ss_within ssw;
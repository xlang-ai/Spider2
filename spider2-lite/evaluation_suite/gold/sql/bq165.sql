WITH cyto_cases AS (
    SELECT DISTINCT
        c.Refno,
        c.CaseNo,
        c.InvNo
    FROM
        `mitelman-db.prod.CytogenInvValid` c
    JOIN `mitelman-db.prod.Reference` Reference ON c.Refno = Reference.Refno
    JOIN `mitelman-db.prod.Cytogen` Cytogen ON Cytogen.RefNo = c.RefNo AND Cytogen.CaseNo = c.CaseNo
    LEFT JOIN `mitelman-db.prod.Koder` KoderM ON Cytogen.Morph = KoderM.Kod AND KoderM.KodTyp = 'MORPH'
    LEFT JOIN `mitelman-db.prod.Koder` KoderT ON Cytogen.Topo = KoderT.Kod AND KoderT.KodTyp = 'TOP'
    WHERE
        Cytogen.Morph IN ('3111')
        AND Cytogen.Topo IN ('0401')
),
SampleCount AS (
    SELECT COUNT(*) AS sCount
    FROM cyto_cases
),
Case_CC_Kary_Result AS (
    SELECT cc_result.*
    FROM cyto_cases
    LEFT JOIN `mitelman-db.prod.CytoConverted` AS cc_result
    ON cc_result.RefNo = cyto_cases.RefNo
       AND cc_result.CaseNo = cyto_cases.CaseNo
       AND cc_result.InvNo = cyto_cases.InvNo
),
Clone_imbal_sums AS (
    SELECT
        cytoBands.chromosome,
        cytoBands.cytoband_name,
        cytoBands.hg38_start,
        cytoBands.hg38_stop,
        Case_CC_Kary_Result.RefNo,
        Case_CC_Kary_Result.CaseNo,
        Case_CC_Kary_Result.InvNo,
        Case_CC_Kary_Result.Clone,
        SUM(CASE WHEN type = 'Gain' THEN 1 ELSE 0 END) AS totalGain,
        SUM(CASE WHEN type = 'Loss' THEN 1 ELSE 0 END) AS totalLoss
    FROM `mitelman-db.prod.CytoBands_hg38` AS cytoBands
    INNER JOIN Case_CC_Kary_Result ON cytoBands.chromosome = Case_CC_Kary_Result.Chr
    WHERE cytoBands.hg38_start >= Case_CC_Kary_Result.Start
          AND cytoBands.hg38_stop <= Case_CC_Kary_Result.End
    GROUP BY
        cytoBands.chromosome,
        cytoBands.cytoband_name,
        cytoBands.hg38_start,
        cytoBands.hg38_stop,
        Case_CC_Kary_Result.RefNo,
        Case_CC_Kary_Result.CaseNo,
        Case_CC_Kary_Result.InvNo,
        Case_CC_Kary_Result.Clone
),
AMP_DEL_counts AS (
    SELECT
        Clone_imbal_sums.chromosome,
        Clone_imbal_sums.cytoband_name,
        Clone_imbal_sums.hg38_start,
        Clone_imbal_sums.hg38_stop,
        Clone_imbal_sums.RefNo,
        Clone_imbal_sums.CaseNo,
        Clone_imbal_sums.InvNo,
        Clone_imbal_sums.Clone,
        CASE WHEN Clone_imbal_sums.totalGain > 1 THEN Clone_imbal_sums.totalGain ELSE 0 END AS amplified,
        CASE WHEN Clone_imbal_sums.totalLoss > 1 THEN Clone_imbal_sums.totalLoss ELSE 0 END AS hozy_deleted,
        CASE WHEN Clone_imbal_sums.totalGain > 1 THEN 1 ELSE 0 END AS amp_count,
        CASE WHEN Clone_imbal_sums.totalLoss > 1 THEN 1 ELSE 0 END AS hozy_del_count
    FROM Clone_imbal_sums
),
Singular_imbal AS (
    SELECT
        Clone_imbal_sums.chromosome,
        Clone_imbal_sums.cytoband_name,
        Clone_imbal_sums.hg38_start,
        Clone_imbal_sums.hg38_stop,
        Clone_imbal_sums.RefNo,
        Clone_imbal_sums.CaseNo,
        Clone_imbal_sums.InvNo,
        Clone_imbal_sums.Clone,
        Clone_imbal_sums.totalGain - AMP_DEL_counts.amplified AS Singular_gain,
        Clone_imbal_sums.totalLoss - AMP_DEL_counts.hozy_deleted AS Singular_loss,
        AMP_DEL_counts.amp_count,
        AMP_DEL_counts.hozy_del_count
    FROM Clone_imbal_sums
    INNER JOIN AMP_DEL_counts ON
        Clone_imbal_sums.chromosome = AMP_DEL_counts.chromosome AND
        Clone_imbal_sums.cytoband_name = AMP_DEL_counts.cytoband_name AND
        Clone_imbal_sums.hg38_start = AMP_DEL_counts.hg38_start AND
        Clone_imbal_sums.hg38_stop = AMP_DEL_counts.hg38_stop AND
        Clone_imbal_sums.RefNo = AMP_DEL_counts.RefNo AND
        Clone_imbal_sums.CaseNo = AMP_DEL_counts.CaseNo AND
        Clone_imbal_sums.InvNo = AMP_DEL_counts.InvNo AND
        Clone_imbal_sums.Clone = AMP_DEL_counts.Clone
),
Sample_dist_count AS (
    SELECT
        Singular_imbal.chromosome,
        Singular_imbal.cytoband_name,
        Singular_imbal.hg38_start,
        Singular_imbal.hg38_stop,
        Singular_imbal.RefNo,
        Singular_imbal.CaseNo,
        Singular_imbal.InvNo,
        CASE WHEN SUM(Singular_imbal.Singular_gain) > 0 THEN 1 ELSE 0 END AS Sample_dist_singular_gain,
        CASE WHEN SUM(Singular_imbal.Singular_loss) > 0 THEN 1 ELSE 0 END AS Sample_dist_singular_loss,
        CASE WHEN SUM(Singular_imbal.amp_count) > 0 THEN 1 ELSE 0 END AS Sample_dist_amp,
        CASE WHEN SUM(Singular_imbal.hozy_del_count) > 0 THEN 1 ELSE 0 END AS Sample_dist_del
    FROM Singular_imbal
    GROUP BY
        Singular_imbal.chromosome,
        Singular_imbal.cytoband_name,
        Singular_imbal.hg38_start,
        Singular_imbal.hg38_stop,
        Singular_imbal.RefNo,
        Singular_imbal.CaseNo,
        Singular_imbal.InvNo
)
SELECT
    Sample_dist_count.chromosome,
    CASE
        WHEN SUBSTRING(Sample_dist_count.chromosome, 4) = 'X' THEN 23
        WHEN SUBSTRING(Sample_dist_count.chromosome, 4) = 'Y' THEN 24
        ELSE CAST(SUBSTRING(Sample_dist_count.chromosome, 4) AS INT64)
    END AS chr_ord,
    Sample_dist_count.cytoband_name,
    Sample_dist_count.hg38_start,
    Sample_dist_count.hg38_stop,
    SampleCount.sCount,
    SUM(Sample_dist_count.Sample_dist_singular_gain) AS total_gain,
    SUM(Sample_dist_count.Sample_dist_singular_loss) AS total_loss,
    SUM(Sample_dist_count.Sample_dist_amp) AS total_amp,
    SUM(Sample_dist_count.Sample_dist_del) AS total_del,
    ROUND(SUM(Sample_dist_count.Sample_dist_singular_gain) / SampleCount.sCount * 100, 2) AS gain_freq,
    ROUND(SUM(Sample_dist_count.Sample_dist_singular_loss) / SampleCount.sCount * 100, 2) AS loss_freq,
    ROUND(SUM(Sample_dist_count.Sample_dist_amp) / SampleCount.sCount * 100, 2) AS amp_freq,
    ROUND(SUM(Sample_dist_count.Sample_dist_del) / SampleCount.sCount * 100, 2) AS del_freq
FROM
    Sample_dist_count,
    SampleCount
GROUP BY
    Sample_dist_count.chromosome,
    Sample_dist_count.cytoband_name,
    Sample_dist_count.hg38_start,
    Sample_dist_count.hg38_stop,
    SampleCount.sCount
ORDER BY
    chr_ord,
    Sample_dist_count.hg38_start,
    Sample_dist_count.hg38_stop
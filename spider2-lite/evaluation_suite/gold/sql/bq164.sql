WITH l1 AS (
    SELECT Filename,
        HTAN_Parent_Biospecimen_ID,
        Component,
        File_Format,
        entityId,
        Run_ID
    FROM `spider2-public-data.HTAN.10xvisium_spatialtranscriptomics_scRNAseq_level1_metadata_current`
    WHERE RUN_ID = 'HT264P1-S1H2Fc2U1Z1Bs1-H2Bs2-Test'
),
l2 AS (
    SELECT Filename,
        HTAN_Parent_Biospecimen_ID,
        Component,
        File_Format,
        entityId,
        Run_ID
    FROM `spider2-public-data.HTAN.10xvisium_spatialtranscriptomics_scRNAseq_level2_metadata_current`
    WHERE RUN_ID = 'HT264P1-S1H2Fc2U1Z1Bs1-H2Bs2-Test'
),
l3 AS (
    SELECT Filename,
        HTAN_Parent_Biospecimen_ID,
        Component,
        File_Format,
        entityId,
        Run_ID
    FROM `spider2-public-data.HTAN.10xvisium_spatialtranscriptomics_scRNAseq_level3_metadata_current`
    WHERE RUN_ID = 'HT264P1-S1H2Fc2U1Z1Bs1-H2Bs2-Test'
),
l4 AS (
    SELECT Filename,
        HTAN_Parent_Biospecimen_ID,
        Component,
        File_Format,
        entityId,
        Run_ID
    FROM `spider2-public-data.HTAN.10xvisium_spatialtranscriptomics_scRNAseq_level4_metadata_current`
    WHERE RUN_ID = 'HT264P1-S1H2Fc2U1Z1Bs1-H2Bs2-Test'
),
aux AS (
    SELECT Filename,
        HTAN_Parent_Biospecimen_ID,
        Component,
        File_Format,
        entityId,
        Run_ID
    FROM `spider2-public-data.HTAN.10xvisium_spatialtranscriptomics_auxiliaryfiles_metadata_current`
    WHERE RUN_ID = 'HT264P1-S1H2Fc2U1Z1Bs1-H2Bs2-Test'
)
SELECT * FROM l1
UNION ALL 
SELECT * FROM l2
UNION ALL 
SELECT * FROM l3
UNION ALL 
SELECT * FROM l4
UNION ALL
SELECT * FROM aux
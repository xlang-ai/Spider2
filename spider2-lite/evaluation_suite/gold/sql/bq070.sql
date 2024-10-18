WITH
  sm_images AS (
    SELECT
      SeriesInstanceUID AS digital_slide_id, 
      StudyInstanceUID AS case_id,
      ContainerIdentifier AS physical_slide_id,
      PatientID AS patient_id,
      TotalPixelMatrixColumns AS width, 
      TotalPixelMatrixRows AS height,
      collection_id,
      crdc_instance_uuid,
      gcs_url, 
      CAST(SharedFunctionalGroupsSequence[SAFE_OFFSET(0)].
              PixelMeasuresSequence[SAFE_OFFSET(0)].
              PixelSpacing[SAFE_OFFSET(0)] AS FLOAT64) AS pixel_spacing, 
      CASE TransferSyntaxUID
          WHEN '1.2.840.10008.1.2.4.50' THEN 'jpeg'
          WHEN '1.2.840.10008.1.2.4.91' THEN 'jpeg2000'
          ELSE 'other'
      END AS compression,
    FROM
      spider2-public-data.idc_v17.dicom_all
    WHERE
      Modality = 'SM' AND ImageType[OFFSET(2)] = 'VOLUME'
  ),

  tissue_types AS (
    SELECT DISTINCT *
    FROM (
      SELECT
        SeriesInstanceUID AS digital_slide_id,
        CASE steps_unnested2.CodeValue
            WHEN '17621005' THEN 'normal' -- meaning: 'Normal' (i.e., non neoplastic)
            WHEN '86049000' THEN 'tumor' -- meaning: 'Neoplasm, Primary'
            ELSE 'other' -- meaning: 'Neoplasm, Metastatic'
        END AS tissue_type
      FROM
        spider2-public-data.idc_v17.dicom_all
        CROSS JOIN
          UNNEST (SpecimenDescriptionSequence[SAFE_OFFSET(0)].PrimaryAnatomicStructureSequence) AS steps_unnested1
        CROSS JOIN
          UNNEST (steps_unnested1.PrimaryAnatomicStructureModifierSequence) AS steps_unnested2
    )
  ),

  specimen_preparation_sequence_items AS (
    SELECT DISTINCT *
    FROM (
      SELECT
        SeriesInstanceUID AS digital_slide_id,
        steps_unnested2.ConceptNameCodeSequence[SAFE_OFFSET(0)].CodeMeaning AS item_name,
        steps_unnested2.ConceptCodeSequence[SAFE_OFFSET(0)].CodeMeaning AS item_value
      FROM
        spider2-public-data.idc_v17.dicom_all
        CROSS JOIN
          UNNEST (SpecimenDescriptionSequence[SAFE_OFFSET(0)].SpecimenPreparationSequence) AS steps_unnested1
        CROSS JOIN
          UNNEST (steps_unnested1.SpecimenPreparationStepContentItemSequence) AS steps_unnested2
    )
  )


SELECT
  a.*,
  b.tissue_type,
  (REPLACE (REPLACE(a.collection_id, 'tcga_luad', 'luad'), 'tcga_lusc', 'lscc')) AS cancer_subtype
FROM 
  sm_images AS a
  JOIN tissue_types AS b ON b.digital_slide_id = a.digital_slide_id
  JOIN specimen_preparation_sequence_items AS c ON c.digital_slide_id = a.digital_slide_id 
WHERE
  (a.collection_id = 'tcga_luad' OR a.collection_id = 'tcga_lusc')
  AND a.compression != 'other'
  AND (b.tissue_type = 'normal' OR b.tissue_type = 'tumor')
  AND (c.item_name = 'Embedding medium' AND c.item_value = 'Tissue freezing medium')
ORDER BY crdc_instance_uuid
The assumptions include:
- consider only those series that have CT modality and do not belong to the NLST collection
- filter out DICOM images that use the following two compression formats:
    - JPEG Lossless, Non-Hierarchical, First-Order Prediction, 1.2.840.10008.1.2.4.70;
    - JPEG Baseline (Process 1), 1.2.840.10008.1.2.4.51;
- do not contain localizer image type
- all instances in a series have identical values for image orientation (patient) and pixel spacing (converted to string before comparison)
- all instances in a series have 1 ± 0.01 as the dot product between the two vectors below:
    - cross product of first and second vectors;
    - vector [0, 0, 1];
- have number of instances in the series equal to the number of distinct values of Image Position (Patient) attribute (converted to string for comparison)
- all instances in a series have identical values for the first two components of Image Position (Patient)
- all instances in a series have identical pixel rows, and similarly identical pixel columns
- for the difference between the values of the 3rd component of Image Position (Patient), after sorting all instances by that third component


BTW, the desired output report should contain:
1. The unique identifier for each image series;
2. The number assigned to the series within a study;
3. The unique identifier for the study that the series belongs to;
4. The unique identifier for the patient;
5. The maximum dot product value between the cross product of image orientation vectors and a reference vector, indicating geometric alignment;
6. The total number of SOP instances (individual images) in each series;
7. The number of distinct slice thickness values within the series;
8. The maximum and minimum difference between consecutive slice intervals (the z-coordinate spacing);
9. The tolerance value for slice interval differences (the z-coordinate spacing);
10. The number of distinct exposure values;
11. The maximum and minimum exposure value recorded for the images;
12. The difference between the maximum and minimum exposure values within the series, indicating the range of exposure variation;
13. The total size of the image series in megabytes (MiB).
And please sort the final output by slice interval difference tolerance, maximum exposure difference and series unique ID (all in descending order).
Detailed requirements include:
- The slides must belong to the TCGA-LUAD or TCGA-LUSC collections;
- The slides must be JPEG or JPEG2000 compressed;
- The slides must be digital images and exclude non-volume ones;
- The slides must contain either normal (`17621005`) or tumor (`86049000`) tissue, identified by specific DICOM codes;
- The slides must be prepared using the "Tissue freezing medium" embedding method;

With respect to the output, it should contain the following basic metadata and attributes related to slide microscopy images. Concretely,
- digital slide ID: unique numeric identifier of a digital slide, i.e., a digital image of a physical slide;
- case ID: unique numeric identifier of the study in the context of which the ditial slide was created;
- physical slide ID: unique numeric identifier of the physical slide as prepared in the wet lab; 
- patient ID: unique numeric identifier of the patient from whose tissue the physical slide was obtained;
- collection ID: numeric or character sequence describing the dataset the physical slide is part of;
- instance ID: universally unique identifier of the DICOM instance;
- GCS URL: how to access the DICOM file;
- width/height: image width and height in pixels, respectively;
- pixel spacing: image pixel spacing in mm/px;
- compression type (either value `jpeg`, `jpeg2000`, or `other`).

And the target two labels are:
- tissue_type: either `normal` or `tumor`;
- cancer_subtype: either `luad` or `lscc`.
Sort the results according to instance ID in ascending order.
### IPC Codes: Handling Main IPC Code Selection

When dealing with the `ipc` field in the `patents-public-data.patents.publications` dataset, it is important to understand the structure of this field, especially the subfield `first`. This subfield is a boolean that indicates whether a given IPC code is the main code for the publication number in question. This is crucial because each patent publication can be associated with multiple IPC codes, signifying the various aspects of the technology covered by the patent.

However, not every publication in the dataset has a designated main IPC code. This lack of a clearly identified main IPC code complicates the process of determining the most relevant IPC code for each publication, as selecting a single IPC code from multiple possibilities without clear prioritization can lead to inconsistent or skewed analyses.

This approach ensures a more consistent and representative selection of IPC codes across the dataset, facilitating more accurate and meaningful analysis of patent trends and classifications. By focusing on the most frequently occurring 4-digit IPC code, the view helps overcome the limitations posed by the absence of a designated main IPC code, thereby enhancing the reliability of patent-related studies and insights derived from this data.

Here is an example

```
SELECT 
    t1.publication_number, 
    SUBSTR(ipc_u.code, 0, 4) as ipc4, 
    COUNT(
    SUBSTR(ipc_u.code, 0, 4)
    ) as ipc4_count 
FROM 
    `patents-public-data.patents.publications` t1, 
    UNNEST(ipc) AS ipc_u 
GROUP BY 
    t1.publication_number, 
    ipc4

```



# Text Embeddings (Similarity)

Patent documents are rich with textual data. In fact, most of the information contained in a patent document is text. This includes the `abstract_localized`, `description_localized`, and `claims_localized`. Textual data can be a powerful tool to analyze and compare patent scope and content across patents. However, before being able to use textual data, it needs to be vectorized or transformed into text embeddings that can be used by machine learning models. Therefore, creating text embeddings from the textual data of patents is necessary to compare patent contents. Technically speaking, running an NLP algorithm that creates embeddings for all U.S. patents is computationally difficult.

Nevertheless, Google runs their own machine learning algorithm which transforms patent text metadata into text embeddings which they report in `patents-public-data.google_patents_research.publications` table. The textual embeddings of one patent, without any knowledge on the algorithm being used to create them, are meaningless on their own. However, the embeddings are powerful when it comes to comparing textual content of two or more patents. Embeddings can be used to calculate a similarity score between any two patents. This similarity score is calculated by applying the dot product of the embeddings vector of the patents, as shown below:

The similarity \( \text{Similarty}_{i,k} \) between two patents \( i \) and \( k \) is calculated as the dot product of their embedding vectors:

\[
\text{Similarty}_{i,k} = \mathbf{v}_i \cdot \mathbf{v}_k
\]

where

\[
\mathbf{v}_i = [v_{i1}, v_{i2}, v_{i3}, \ldots, v_{iN}]
\]
and
\[
\mathbf{v}_k = [v_{k1}, v_{k2}, v_{k3}, \ldots, v_{kN}]
\]

are the embedding vectors for patents \( i \) and \( k \) respectively. The higher the dot product, the more similar the patents.





# Originality (Trajtenberg)

One of the most important measures of a patent is "basicness". The aspects of basicness are tough to measure. Nevertheless, some literature finds that important aspects of these measures are embodied in the relationship between the invention and the technological predcessors and successors it is connected to through, for example, patent citations. We can thus use patent citations to construct measures that identify basicness and appropriability. Trajtenberg et al. 1997 provide a number of these measures. They distinguish between:

1. Forward-looking measures: measures that are derived from the relationship between an invention and subsequent technologies that build upon it. These measures are thus constructed from the forward citations. One example of a forward-looking basicness measure they provide is Generality, which is calculated as:

\[
\text{GENERALITY}_i = 1 - \sum_{k=1}^{N_i} \left( \frac{\text{NCITING}_{G_k}}{\text{NCITING}_i} \right)
\]


2. Backward-looking measures: measures that are derived from the relationship between a given patent and the body of knowledge that preceded it. These measure are thus constructed from the backward citations. One example of a backward-looking basicness measure they provide is Orginality, which is calculated as:

\[
\text{ORIGINALITY}_i = 1 - \sum_{k=1}^{N_i} \left( \frac{\text{NCITED}_{i,k}}{\text{NCITED}_i} \right)
\]

With **NCITING** and **NCITED** defined as the number of patents citing the focal patent and the number of patents cited by the focal patent, respectively. Index `i` corresponds to the focal patent considered, and `k` is the index of patent classes. For example, **NCITED_2,3** refers to the number of patents in patent class 3 and cited by our focal patent 2.



<!-- README.md is generated from README.Rmd. Please edit that file -->

# embedcode package

<!-- badges: start -->
<!-- badges: end -->

This package provides a solution for performing code embedding on EHR
data, specifically for medical codes such as ICD (International
Classification of Diseases) codes, CPT (Current Procedural Terminology)
codes, and national drug codes. The goal is to translate these codes
into embedding vectors to better capture their underlying correlations,
facilitating downstream analysis. The method used in developing this
package is based on the GloVe (Global Vectors for Word Representation)
algorithm, which leverages global statistical information by analyzing
code-to-code co-occurrence patterns across the entire dataset.

## Installation

## Functions included

The package includes the following functions, outlined as steps to
follow for embedding the codes: 1. Create code co-occurrence matrix This
steps allow users to obtain a sparse matrix that record the
co-occurrence of the codes in the dataset. users may choose to decide
visualing code occurrance pattern by creating heatmap or decide dealing
with rare codes based on the resulting matrix. - cooccur_hpc() This
function computes a co-occurrence matrix for a dataset that containing
medical codes, based on the time window for each patient’s data. It is
optimized for high-performance computing (HPC) environments using the
`slurmR` package. - coccur_local() This function computes a
co-occurrence matrix for a dataset that containing medical codes, based
on the time window for each patient’s data. It is optimized for local
computing environments.

2.  Create sparse matrix for co-occurence pattern.

- cooccur_pairs() This function takes an input symmetric co-occurrence
  matrix and returns a data frame representing the co-occurrences
  between pairs of items. Each pair consists of a row index and a column
  index (i.e., co-occurring pairs) with an associated count,
  representing the number of co-occurrences.

3.  Derive Marginal Counts for Codes and Joint Counts for Code Pairs

- getsg() This function calculates the marginal counts for each code and
  the joint counts for each pair of codes in the co-occurrence matrix.

4.  Calculate the Pointwise Mutual Information (PMI) value for code
    pair. -pmi_df() This function computes the Pointwise Mutual
    Information (PMI) value for each code in the co-occurrence matrix.
    It returns a data frame that includes the following details: the
    code, its co-occurring codes, the marginal count for each code, the
    joint count for the code pairs, and the PMI value for each pair.

5.  Transform Code-Code PMI into Matrix In this step, the PMI values
    from the previous step are transformed into a symmetric matrix. This
    can be done in two ways: using the raw PMI values directly or
    applying the shifted positive PMI (SPPMI) method, commonly used in
    word embedding for paragraphs and notes. SPPMI is calculated as
    max(PMI - log(k), 0).

- pmi_matrix() This function transforms the information obtained in the
  previous step into a symmetric matrix, where each row/column
  represents a code, and each entry contains the corresponding PMI value
  for each code pair.
- sppmi_matrix() This function transforms the information obtained in
  the previous step into a symmetric matrix, where each row/column
  represents a code, and each entry contains the corresponding SPPMI
  value for each code pair.

6.  Embedding the codes

- truncated_svd() This function performs truncated Singular Value
  Decomposition (SVD) on the PMI/SPPMI matrix to generate code embedding
  vectors. Users can specify the number of dimensions and the maximum
  number of iterations for the embedding process. Additionally, they can
  choose to perform a full SVD and decide whether to remove
  zero-information vectors.

## Example data

This package includes an example dataset specifically designed for
testing and demonstration purposes, it comprises 2,000 unique patient
IDs, 500 unique ICD-9 codes, and time sequences corresponding to each
patient’s recorded events.

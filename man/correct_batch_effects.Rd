% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/correct_batch_effects.R
\name{correct_batch_effects}
\alias{correct_batch_effects}
\title{Batch correction method allows correction of 
continuous sigal drift within batch and 
discrete difference across batches.}
\usage{
correct_batch_effects(data_matrix, sample_annotation,
  fitFunc = "loess_regression", discreteFunc = c("MedianCentering",
  "ComBat"), batch_col = "MS_batch",
  feature_id_col = "peptide_group_label",
  sample_id_col = "FullRunName", measure_col = "Intensity",
  sample_order_col = "order", abs_threshold = 5, pct_threshold = 0.2,
  ...)
}
\arguments{
\item{data_matrix}{features (in rows) vs samples (in columns) matrix, with
feature IDs in rownames and file/sample names as colnames. Usually the log
transformed version of the original data}

\item{sample_annotation}{data frame with sample ID, technical (e.g. MS batches) 
and biological (e.g. Diet) covariates}

\item{fitFunc}{function to use for the fit (currently 
only \code{loess_regression} available)}

\item{discreteFunc}{function to use for discrete 
batch correction (\code{MedianCentering} or \code{ComBat})}

\item{batch_col}{column in \code{sample_annotation} that should be 
used for batch comparison}

\item{feature_id_col}{name of the column with feature/gene/peptide/protein ID 
used in the long format representation df_long. In the wide formatted 
representation data_matrix this corresponds to the row names.}

\item{sample_id_col}{name of the column in sample_annotation file, where the
filenames (colnames of the data matrix are found)}

\item{measure_col}{if \code{df_long} is among the parameters, it is the column
with expression/abundance/intensity, otherwise, it is used internally for
consistency}

\item{sample_order_col}{column, determining the order of sample MS run, used
as covariate to fit the non-linear fit}

\item{abs_threshold}{the absolute threshold to filter data for curve fitting}

\item{pct_threshold}{the percentage threshold to filter data for curve fitting}

\item{...}{other parameters, usually of \code{normalize_custom_fit}, and \code{fit_func}}
}
\value{
\code{data_matrix}-size data matrix with batch-effect 
corrected by fit and discrete functions
}
\description{
Batch correction method allows correction of 
continuous sigal drift within batch and 
discrete difference across batches.
}
\examples{
batch_corrected_matrix <- correct_batch_effects(
example_proteome_matrix, example_sample_annotation, 
discreteFunc = 'MedianCentering', 
batch_col = 'MS_batch',  
span = 0.7,
abs_threshold = 5, pct_threshold = 0.20)

}

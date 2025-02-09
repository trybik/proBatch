% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/correct_batch_effects.R
\name{adjust_batch_trend}
\alias{adjust_batch_trend}
\title{adjust batch signal trend with the custom (continuous) fit}
\usage{
adjust_batch_trend(data_matrix, sample_annotation,
  batch_col = "MS_batch", feature_id_col = "peptide_group_label",
  sample_id_col = "FullRunName", measure_col = "Intensity",
  sample_order_col = "order", fit_func = fit_nonlinear,
  abs_threshold = 5, pct_threshold = 0.2, ...)
}
\arguments{
\item{data_matrix}{features (in rows) vs samples (in columns) matrix, with
feature IDs in rownames and file/sample names as colnames. Usually the log
transformed version of the original data}

\item{sample_annotation}{data frame with sample ID, technical (e.g. MS batches) 
and biological (e.g. Diet) covariates}

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

\item{fit_func}{function to fit the (non)-linear trend}

\item{abs_threshold}{the absolute threshold to filter data for curve fitting}

\item{pct_threshold}{the percentage threshold to filter data for curve fitting}

\item{...}{other parameters, usually those of the \code{fit_func}}
}
\value{
list of two items: 1) \code{data_matrix}, adjusted with continious fit; 
2) fit_df, used to examine the fitting curves
}
\description{
adjust batch signal trend with the custom (continuous) fit
}
\examples{
trend_corrected_matrix <- adjust_batch_trend(example_proteome_matrix, 
example_sample_annotation, span = 0.7, 
abs_threshold = 5, pct_threshold = 0.20)

}
\seealso{
\code{\link{fit_nonlinear}}
}

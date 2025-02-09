% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/proBatch.R
\docType{package}
\name{proBatch}
\alias{proBatch}
\alias{proBatch-package}
\title{proBatch: A package for diagnostics and correction of batch effects,
primarily in proteomics}
\arguments{
\item{df_long}{data frame where each row is a single feature in a single
sample. It minimally has a \code{sample_id_col}, a \code{feature_id_col} and a
\code{measure_col}, but usually also an \code{m_score} (in OpenSWATH output result
file)}

\item{data_matrix}{features (in rows) vs samples (in columns) matrix, with
feature IDs in rownames and file/sample names as colnames. Usually the log
transformed version of the original data}

\item{sample_annotation}{data matrix with: \enumerate{ \item \code{sample_id_col}
(this can be repeated as row names) \item biological covariates \item
technical covariates (batches etc) }}

\item{sample_id_col}{name of the column in sample_annotation file, where the
filenames (colnames of the data matrix are found)}

\item{batch_col}{column in \code{sample_annotation} that should be used for
batch comparison}

\item{order_col}{column in \code{sample_annotation} that determines sample order. It is
used for certain diagnostics and normalisations.}

\item{measure_col}{if \code{df_long} is among the parameters, it is the
column with expression/abundance/intensity; otherwise, it is used
internally for consistency}

\item{feature_id_col}{name of the column with feature/gene/peptide/protein
ID used in the long format representation \code{df_long}. In the wide
formatted representation \code{data_matrix} this corresponds to the row
names.}

\item{plot_title}{Title of the plot (usually, processing step + representation
level (fragments, transitions, proteins))}

\item{theme}{ggplot theme, by default \code{classic}. Can be easily overriden}
}
\description{
The proBatch package contains functions for analyzing and correcting batch effects 
and other unwanted technical variation from high-thoughput experiments. Although 
the package has primarily been developed for mass spectrometry proteomics (DIA/SWATH),
it should also be applicable to most omic data with minor adaptations.
It addresses the following needs: \itemize{ \item prepare the data for analysis
\item Visualize batch effects in sample-wide and feature-level;
\item Normalize and correct for batch effects.
}
}
\details{
To learn more about proBatch, start with the vignettes:
\code{browseVignettes(package = "proBatch")}
}
\section{Section}{

Common arguments to the functions.
}


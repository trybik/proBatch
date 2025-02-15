% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/date_conversion.R
\name{dates_to_posix}
\alias{dates_to_posix}
\title{Convert data/time to POSIXct}
\usage{
dates_to_posix(sample_annotation, time_column = c("RunDate", "RunTime"),
  new_time_column = "DateTime", dateTimeFormat = c("\%b_\%d",
  "\%H:\%M:\%S"))
}
\arguments{
\item{sample_annotation}{data matrix with: \enumerate{ \item \code{sample_id_col}
(this can be repeated as row names) \item biological covariates \item
technical covariates (batches etc) }}

\item{time_column}{name of the column(s) where run date & time are specified.
These will be used to determine the run order}

\item{new_time_column}{name of the new column to which date&time will be
converted to}

\item{dateTimeFormat}{POSIX format of the date and time. 
See \code{\link{as.POSIXct}} from base R for details}
}
\value{
sample annotation file with a new column \code{new_time_column} with
  POSIX-formatted date
}
\description{
convert date/time column of sample_annotation to POSIX format required to
keep number-like behaviour
}
\examples{
date_to_posix <- dates_to_posix(example_sample_annotation, 
time_column = c('RunDate','RunTime'),
new_time_column = 'DateTime', 
dateTimeFormat = c("\%b_\%d", "\%H:\%M:\%S"))

}
\concept{date}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_elan.R
\name{read_elan}
\alias{read_elan}
\title{Read ELAN data (.eaf)}
\usage{
read_elan(path)
}
\arguments{
\item{path}{The path to a single ELAN .eaf file or a directory with .eaf files}
}
\value{
A data frame containing the ELAN data
}
\description{
This function reads ELAN annotation files (.eaf) in a directory,
or a single ELAN file, and outputs a data frame
}

#' Find ID number from ID gloss
#'
#' This function inputs an ID gloss and outputs an
#' ID number linked to the same sign (its dictionary entry).
#'
#' @param gloss ID gloss for the sign
#' @param acronym The acronym for the target sign language (e.g. "STS")
#' @return The unique ID gloss linked to the sign used as its label in Signbank
#' @export
gloss2id <- function(gloss, acronym="sts") {
  sequence <- c()
  for (g in strsplit(gloss, "\\s+")[[1]]) {
    sequence <- c(sequence, signglossR::gloss2id1(g, acronym))
  }
  return(sequence)
}
